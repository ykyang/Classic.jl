
function a_star(initial, goal_test, next_points, heuristic)
    node = nothing
    # value = Node.cost + Node.heuristic
    frontier = PriorityQueue{Node,Float64}() # value from low -> high
    node = Node(initial, nothing, 0, heuristic(initial))
    enqueue!(frontier, node, node.cost+node.heuristic)

    explored = Dict{Tuple{Int64,Int64}, Float64}() # Node.point,Node.cost

    while !isempty(frontier)
        current_node = dequeue!(frontier)
        current_pt = current_node.point

        if goal_test(current_pt)
            return current_node
        end

        for next_pt in next_points(current_pt)
            next_cost = current_node.cost + 1
            
            if !in(next_pt,keys(explored)) # has not visited next_pt or
                explored[next_pt] = next_cost
                node = Node(next_pt, current_node, next_cost, heuristic(next_pt))
                enqueue!(frontier, node, node.cost+node.heuristic)
            elseif next_cost < explored[next_pt] # next_pt is lower cost
                explored[next_pt] = next_cost
                node = Node(next_pt, current_node, next_cost, heuristic(next_pt))
                frontier[node] = node.cost+node.heuristic
            end
        end

        #empty!(frontier)
    end

    # solution not found
    return nothing
end


"""
    bfs(initial::Tuple{Int64,Int64}, goal_test, next_ponts)

Solve a maze using breadth-first search algorithm.  Returns the `Node` at the 
goal or nothing is no solution found.  Use the parent of `Node` to trace back 
to the start.

...
# Arguments
- `initial`: Starting point in the maze
- `goal_test`: Function`(Tuple{Int64,Int64})` to test if the goal has reached
- `next_points`: Function`(Tuple{Int64,Int64}) -> Vector{Tuple{Int64,Int64}}` to get next points to move to
...
"""
function bfs(initial::P, goal_test, next_points) where {P} # point type
    # P = Tuple{Int64,Int64} # point type
    frontier = Queue{Node{P}}()
    enqueue!(frontier, Node{P}(initial)) # starts with initial guess

    # Positions where we have been to
    explored = Set{P}()
    push!(explored, initial)

    while !isempty(frontier)
        current_node = dequeue!(frontier)
        current_pt = current_node.point
        #@show current_pt
        if goal_test(current_pt)
            #@show current_pt
            return current_node
        end

        for next_pt in next_points(current_pt)
            if in(next_pt, explored)
                continue
            end

            push!(explored, next_pt)
            enqueue!(frontier, Node{P}(next_pt, current_node))
        end

        #empty!(frontier)
    end
    
    # no solution
    return nothing
end

"""
    dfs(initial, goal_test, successors)

Depth-first search

...
# Arguments
- `initial`: Starting point in the maze
- `goal_test`: Function to test if goal has reached
- `successors`: Function to get a list of next locations to try
...
"""
function dfs(
    initial::Tuple{Int64,Int64}, # MazeLocation, 
    goal_test, # function to test if goal reached
    successors, # function that takes MazeLocation and returns a list of next MazeLocations
    )
    
    ds = DataStructures
    
    frontier = ds.Stack{Node}()
    push!(frontier, Node(initial))

    explored = Set{Tuple{Int64,Int64}}()
    push!(explored, initial)

    while !isempty(frontier)
        current_node = pop!(frontier) # Node
        current_pt = current_node.point
        if goal_test(current_pt)
            return current_node # break
        end
        
        for nextPoint in successors(current_pt)
            if in(nextPoint, explored)
                continue
            end
            push!(explored, nextPoint)
            push!(frontier, Node(nextPoint, current_node))
        end

        # @show explored
        # empty!(explored)
    end

    # no solution
    return nothing
end

function mst(g::WeightedGraph{V,E}, start::Int64) where {V,E<:WeightedEdge}
    vertex_count = length(g.vertices)

    result = Vector{WeightedEdge}()
    if !(1 <= start <= vertex_count)
        return result
    end

    que = PriorityQueue{WeightedEdge,Float64}()
    visited = zeros(Bool, vertex_count) #Vector{Bool}(undef, vertex_count)

    # Internal function has access to local variables
    # such as `visited`.
    function visit(index) 
        visited[index] = true
        for edge in edges_of(g, index)
            if !visited[edge[2]] # neighbor not yet visited
                enqueue!(que, edge, weight(edge))
            end
        end
    end

    visit(start)
    while !isempty(que)
        edge = dequeue!(que)
        if visited[edge[2]]
            continue
        end

        push!(result, edge)
        visit(edge[2])
    end

    return result
end

# function print_weighted_path(g::WeightedGraph, edges::Vector{WeightedEdge})
#     for edge in edges
#         println("$(vertex_at(g, edge[1])) $(weight(edge)) > $(vertex_at(g, edge[2]))")
#     end
# end



"""
    DijkstraResult

Results from Dijkstra algorithm
"""
struct DijkstraResult
    """
    Distance to each node from the starting node
    """
    distances::Vector{Float64}
    """
    node index => edge that leads to the node in the shortest path
    """
    path_db::Dict{Int64,WeightedEdge}
end

function dijkstra(g::WeightedGraph{V,E}, start::V)::DijkstraResult where {V,E<:WeightedEdge}
    start_ind = index_of(g, start)
    vertex_count = length(g.vertices)

    # Initialization to `undef` is fine
    distances = Vector{Float64}(undef, vertex_count)
    distances[start_ind] = 0
    visited = zeros(Bool, vertex_count)
    visited[start_ind] = true

    path_db = Dict{Int64,WeightedEdge}()
    que = PriorityQueue{DijkstraNode,Float64}()
    enqueue!(que, DijkstraNode(start_ind, 0), 0)

    while !isempty(que)
        node = dequeue!(que)
        distance2node = distances[node.index]

        for edge in edges_of(g, node.index)
            next_index = edge[2] # neighbor
            
            distance_to_next_index1 = distances[next_index] # undef || current distance
            distance_to_next_index2 = distance2node + weight(edge) # new distance

            if !visited[next_index] 
                visited[next_index] = true
                distances[next_index] = distance_to_next_index2 # so undef is fine
                # Record the edge that has the shortest distance to next node
                path_db[next_index] = edge
                enqueue!(que, DijkstraNode(next_index, distance_to_next_index2), distance_to_next_index2)
            elseif distance_to_next_index2 < distance_to_next_index1
                visited[next_index] = true # not necessary
                distances[next_index] = distance_to_next_index2 # so undef is fine
                # Record the edge that has the shortest distance to next node
                path_db[next_index] = edge
                delete!(que, DijkstraNode(next_index, distance_to_next_index1))
                enqueue!(que, DijkstraNode(next_index, distance_to_next_index2), distance_to_next_index2)
            end
        end

        #empty!(que) #avoid infinite loop during construction
    end

    return DijkstraResult(distances, path_db)
end

"""
    distances_to_distance_db(g::WeightedGraph{V,E}, distances::Vector{Float64})::Dict{V,Float64} where {V,E<:WeightedEdge}

Convert the distance array to distance map.  Return mapping of
```
Node -> distance to Node from starting Node
```
Notice the starting `Node` was specified during the solution process and not here.
"""
function distances_to_distance_db(g::WeightedGraph{V,E}, distances::Vector{Float64})::Dict{V,Float64} where {V,E<:WeightedEdge}
    db = Dict{V,Float64}()

    for (i,dist) in enumerate(distances)
        db[vertex_at(g,i)] = dist
    end

    return db
end


"""
    shortest_path(g::WeightedGraph{V,E}, path_db::Dict{Int64,E}, start::Int64, finish::Int64)::Vector{E} where {V,E<:WeightedEdge}

Calculate the shortest path from `start` to `finish` using `path_db`.
"""
function shortest_path(path_db::Dict{Int64,E}, start::Int64, finish::Int64)::Vector{E} where {E<:WeightedEdge}
    path = Vector{E}()
    
    if isempty(path_db)
        return path
    end

    edge = path_db[finish]
    push!(path, edge)
    while edge[1] != start
        edge = path_db[edge[1]]
        push!(path, edge)
    end

    path = Base.reverse(path)

    return path

end