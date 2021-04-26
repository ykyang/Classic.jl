# Chapter 2
# https://livebook.manning.com/book/classic-computer-science-problems-in-java/chapter-2/



# export Maze, Node
# export dfs
#import DataStructures
#using DataStructures

# export Cell
# export EMPTY

"""
    Cell

Cell type of a maze
"""
@enum Cell begin
    EMPTY
    BLOCKED
    START
    GOAL
    PATH
end

"""
    Node

TODO: make this immutable

Record path in a maze
"""
mutable struct Node{P}
    point::P #Tuple{Int64,Int64}  # MazeLocation
    parent::Union{Node{P},Nothing}
    cost::Float64
    heuristic::Float64

    # Node() = ( # incomplete initialization
    #     me = new();
    #     #me.cost = 0.0;
    #     #me.heuristic = 0.0;
    #     me
    # )
    function Node{P}() where {P}
        me = new()
        return me
    end
    # Node(point) = (
    #     me = new();
    #     me.point = point;
    #     me.parent = nothing;
    #     me
    # )
    function Node{P}(point::P) where {P}
          me = new();
          me.point = point;
          me.parent = nothing;
          me
    end
    # Node(point,parent) = (
    #     me = new();
    #     me.point = point;
    #     me.parent = parent;
    #     me
    # )
    function Node{P}(point::P, parent::Node{P}) where {P}
          me = new();
          me.point = point;
          me.parent = parent;
          me
    end
    # Node(point,parent,cost,heuristic) = (
    #     me = new();
    #     me.point = point;
    #     me.parent = parent;
    #     me.cost = cost;
    #     me.heuristic = heuristic;
    #     me
    # )
end
#Base.:(<)(x::Node, y::Node) = x.id < y.id
Base.:(==)(x::Node,y::Node) = x.point == y.point

mutable struct Maze
    Maze() = (
        me = new();
        me
    )
    start::Tuple{Int64,Int64}
    goal::Tuple{Int64,Int64}
    grid::Array{Cell,2}
end

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

# function bfs(initial::Tuple{Int64,Int64}, goal_test, next_points)
#     frontier = Queue{Node}()
#     enqueue!(frontier, Node(initial)) # starts with initial guess

#     # Positions where we have been to
#     explored = Set{Tuple{Int64,Int64}}()
#     push!(explored, initial)

#     while !isempty(frontier)
#         current_node = dequeue!(frontier)
#         current_pt = current_node.point

#         if goal_test(current_pt)
#             return current_node
#         end

#         for next_pt in next_points(current_pt)
#             if in(next_pt, explored)
#                 continue
#             end

#             push!(explored, next_pt)
#             enqueue!(frontier, Node(next_pt, current_node))
#         end

#         #empty!(frontier)
#     end
    
#     # no solution
#     return nothing
# end


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


"""

TODO: relax the parameter type
"""
function manhattan_distance(point::Tuple{Int64,Int64}, goal::Tuple{Int64,Int64})
    delta = @. abs(point - goal) # abs.(point .- goal)
    distance = sum(delta)

    return distance
end

function new_maze(row_count, col_count, start, goal, sparseness)
    maze = Maze()

    grid = Array{Cell,2}(undef, row_count,col_count)
    grid .= EMPTY::Cell
    
    random_fill!(grid, sparseness)

    grid[start...] = START # same as setindex!(grid, START, start...)
    setindex!(grid, GOAL, goal...)
    
    maze.grid = grid
    maze.start = start
    maze.goal = goal

    return maze
end

function new_maze()
    return new_maze(10, 10, (1,1), (10,10), 0.2)
end

function random_fill!(grid, sparseness) 
    for j in 1:size(grid)[2]
        for i in 1:size(grid)[1]
            if rand(Float64) < sparseness 
            #if rand(0:1.e-15:1) < sparseness
                grid[i,j] = BLOCKED::Cell
            end
        end
    end
end

function successors(grid, here)
    locations = Vector{Tuple{Int64,Int64}}()

    hr = here[1] # row index
    hc = here[2] # col index
    rcount = size(grid)[1]
    ccount = size(grid)[2]

    nr = hr + 1 # next row index
    nc = hc
    if (nr <= rcount) && (grid[nr,nc] != BLOCKED) # () is not necessary, but make it clear
        push!(locations, (nr,nc))
    end

    nr = hr - 1
    nc = hc
    if (1 <= nr) && (grid[nr,nc] != BLOCKED)
        push!(locations, (nr,nc))
    end

    nr = hr
    nc = hc + 1
    if (nc <= ccount) && (grid[nr,nc] != BLOCKED)
        push!(locations, (nr,nc))
    end

    nr = hr
    nc = hc - 1
    if (1 <= nc) && (grid[nr,nc] != BLOCKED)
        push!(locations, (nr,nc))
    end

    return locations
end

next_points(grid, pt) = successors(grid, pt)

function is_goal(goal, here)
    #return (goal[1] == here[1]) && (goal[2] == here[2])
    #@show goal, here
    return goal == here
end

#function is_goal(goal::V, here::V)

"""
    mark_path!(grid, node::Node; start=nothing, goal=nothing)

Mark PATH to `grid` starting from `node` and go back up to its `parent`
until the parent is `nothing`.  The `node` is usually pointed to `goal` of
the `grid`.
"""
function mark_path!(grid, node::Node; start=nothing, goal=nothing)
    if isnothing(goal)
        grid[node.point...] = PATH
    end

    while !isnothing(node.parent)
        node = node.parent
        if node.point != start        
            grid[node.point...] = PATH
        end
    end
end

function node_to_path(node::Node{P}) where {P}
    path = Vector{P}()
    push!(path, node.point)
    while !isnothing(node.parent)
        node = node.parent
        #push!(path, node.point)
        insert!(path, 1, node.point)
    end

    return path
end

function Base.show(io::IO, x::Cell)
    print(io, string(x))
end

function Base.display(x::Array{Cell})
    if ndims(x) == 2
        for i in 1:size(x)[1]
            for j in 1:size(x)[2]
                print(string(x[i,j]))
            end
            println()
        end
    end
    
end

"""
    string(x::Cell)

Convert enumeration `Cell` to an one character string.
"""
function Base.string(x::Cell)
    # TODO: use Swicth.jl
    if x == EMPTY
        return  "□" #"◻" #"▢" #"□"
    elseif x == BLOCKED
        return "■" #"■" #"▮" #"■" #"◾" #"■" # "X" #"■" #"▮"
    elseif x == START
        return "►" #"S"
    elseif x == GOAL
        return "◎" #"G"
    elseif x == PATH
        return "●" #"*" #"◘" #"*"
    end

    return "?"
end

