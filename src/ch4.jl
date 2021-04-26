# https://livebook.manning.com/book/classic-computer-science-problems-in-java/chapter-4/

abstract type Edge end

function Base.getindex(edge::Edge, i::Int64) #where {E<:Edge}
    return edge.vertices[i]
end

function reverse(e::E) where {E<:Edge}
    return E(Base.reverse(e.vertices))
end

Base.string(e::Edge) = "$(e[1]) -> $(e[2])"
Base.show(io::IO, x::Edge) = print(io, string(x))

struct SimpleEdge <: Edge
    # u::Int64
    # v::Int64
    vertices::Tuple{Int64,Int64}
    function SimpleEdge(vertices)
        new(vertices)
    end
    function SimpleEdge(u,v)
        new((u,v))
    end
end

struct WeightedEdge <: Edge
    vertices::Tuple{Int64,Int64}
    weight::Float64
    function WeightedEdge(vertices::Tuple{Int64,Int64}, weight)
        new(vertices, weight)
    end
    function WeightedEdge(u::Int64, v::Int64, weight)
        new((u,v), weight)
    end
end

Base.:(<)(x::WeightedEdge, y::WeightedEdge) = error("Unsupported operation")
Base.:(==)(x::WeightedEdge, y::WeightedEdge) = x.vertices == y.vertices #error("Unsupported operation")
# for sum(), Java.totalWeight()
Base.:(+)(x::WeightedEdge, y::WeightedEdge) = weight(x) + weight(y)
Base.:(+)(x::Float64, y::WeightedEdge) = x + weight(y)


function weight(e::WeightedEdge)
    e.weight
end
function reverse(e::WeightedEdge)
    WeightedEdge(e[2], e[1], weight(e))
end


    
abstract type Graph{V,E} end


function add!(g::Graph{V,E}, u::Int64, v::Int64) where {V,E<:Edge}
    add!(g, E(u,v))
end

"""

This is why cities cannot have the same name.
"""
function add!(g::Graph{V,E}, u::V, v::V) where {V,E<:Edge}
    add!(g, index_of(g, u), index_of(g, v))
end

function add!(g::Graph{V,E}, edge::Edge) where {V,E<:Edge}
    edges = edges_of(g, edge[1]) #g.edges_lists[edge.u]
    push!(edges, edge)

    edges = edges_of(g, edge[2]) #g.edges_lists[edge.v]
    push!(edges, reverse(edge))

    nothing
end


"""
    Base.append!(g::Graph{V,E}, vertices) where {V,E<:Edge}

Append vertices to a graph.  Creates empty edge lists for each vertex.
"""
function Base.append!(g::Graph{V,E}, vertices) where {V,E<:Edge} # is <:Edge necessary, could be more generic later
    append!(g.vertices, vertices)

    # One list of edges for each vertex
    for i in 1:length(vertices)
        push!(g.edges_lists, Vector{Vector{E}}())
    end
end

function edges_of(g::Graph{V,E}, v::V) where {V,E<:Edge}
    index = index_of(g, v)
    return edges_of(g, index)
end

function edges_of(g::Graph{V,E}, index::Int64)  where {V,E<:Edge}
    return g.edges_lists[index]
end

"""

This is why cities cannot have the same name.
"""
function index_of(g::Graph{V,E}, v::V) where {V,E<:Edge}
    findfirst(x->x==v, g.vertices)
end

function neighbor_of(g::Graph{V,E}, v::V) where {V,E<:Edge}
    index = index_of(g, v)
    return neighbor_of(g, index)
end

function neighbor_of(g::Graph{V,E}, index::Int64) where {V,E<:Edge}
    edges = g.edges_lists[index]
    
    neighbors = Vector{V}()
    for edge in edges
        push!(neighbors, vertex_at(g, edge[2]))
    end

    return neighbors
end

function vertex_at(g::Graph{V,E}, index::Int64) where {V,E<:Edge}
    return g.vertices[index]
end

function vertex_at(g::Graph{V,E}, v::V) where {V,E<:Edge}
    return g.vertices[index_of(v)]
end

function Base.show(io::IO, g::Graph)
    for v in g.vertices
        print(io, "$v -> [")
        neighbors = neighbor_of(g,v)
        for neighbor in neighbor_of(g,v)
            print(io, "$neighbor")
            
            if neighbor != neighbors[end]
                print(io, ", ")
            end
        end
        print(io, "]")

        #print(io, "$v -> $(neighbor_of(g, v))")
        
        println(io)
    end 
end



struct UnweightedGraph{V,E<:Edge} <: Graph{V,E}
    vertices::Vector{V}            # list of vertices
    edges_lists::Vector{Vector{E}} # edges_lists[i] -> list of edges that connects to vertices[i]

    function UnweightedGraph{V,E}() where {V,E<:Edge} # is E<:Edge necessary
        new(Vector{V}(), Vector{Vector{E}}())        
    end
end

function UnweightedGraph{V,E}(v::Vector{V}) where {V,E<:Edge}
    me = UnweightedGraph{V,E}()
    append!(me, v)
    
    return me
end

struct WeightedGraph{V,E<:WeightedEdge} <: Graph{V,E}
    vertices::Vector{V}            # list of vertices
    edges_lists::Vector{Vector{E}} # edges_lists[i] -> list of edges that connects to vertices[i]

    function WeightedGraph{V,E}() where {V,E<:WeightedEdge} # is E<:Edge necessary
        new(Vector{V}(), Vector{Vector{E}}())        
    end
end

function WeightedGraph{V,E}(v::Vector{V}) where {V,E<:WeightedEdge}
    me = WeightedGraph{V,E}()
    append!(me, v)
    
    return me
end

function add!(g::WeightedGraph{V,E}, u::Int64, v::Int64, w) where {V,E<:WeightedEdge}
    add!(g, E(u,v,w))
end

function add!(g::WeightedGraph{V,E}, u::V, v::V, w) where {V,E<:WeightedEdge}
    add!(g, index_of(g, u), index_of(g, v), w)
end
function Base.show(io::IO, g::WeightedGraph)
    for v in g.vertices
        print(io, "$v -> [")
        edges = edges_of(g, v)
        for edge in edges
            print(io, "($(vertex_at(g, edge[2])), $(weight(edge)))")
            if edge != edges[end]
                print(io, ", ")
            end
        end
        # neighbors = neighbor_of(g,v)
        # for neighbor in neighbor_of(g,v)
        #     print(io, "($neighbor, )")
        #     if neighbor != neighbors[end]
        #         print(io, ", ")
        #     end
        # end
        print(io, "]")

        #print(io, "$v -> $(neighbor_of(g, v))")
        
        println(io)
    end 
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

function Base.print(io::IO, g::WeightedGraph, edges::Vector{WeightedEdge})
    for edge in edges
        println(io, "$(vertex_at(g, edge[1])) $(weight(edge)) > $(vertex_at(g, edge[2]))")
    end
end


struct DijkstraNode
    index::Int64
    distance::Float64
    # function DijkstraNode(index, distance)
    #     new(index, distance)
    # end
end
# make sure not mis-use these 2 functions
Base.:(<)(x::DijkstraNode, y::DijkstraNode) = error("Unsupported operation")# x.distance < y.distance
Base.:(==)(x::DijkstraNode, y::DijkstraNode) = error("Unsupported operation") #x.distance == y.distance #error("Unsupported operation") #x.index == y.index
# to make Dict and PriorityQueue behavior the way we wanted
Base.isequal(x::DijkstraNode, y::DijkstraNode) = isequal(x.index, y.index) #x.index == y.index #error("Unsupported operation") 
Base.hash(x::DijkstraNode, h::UInt64=UInt64(13)) = hash(x.index,h)

struct DijkstraResult
    distances::Vector{Float64}
    path_db::Dict{Int64,WeightedEdge}
end

function dijkstra(g::WeightedGraph{V,E}, start::V) where {V,E<:WeightedEdge}
    start_ind = index_of(g, start)
    vertex_count = length(g.vertices)

    # TODO: initialization to what?
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

Convert the distance array to distance map.
"""
function array_to_db(g::WeightedGraph{V,E}, distances::Vector{Float64}) where {V,E<:WeightedEdge}
    db = Dict{V,Float64}()

    for (i,dist) in enumerate(distances)
        db[vertex_at(g,i)] = dist
    end

    return db
end

function path_db_to_path(g::WeightedGraph{V,E}, path_db::Dict{Int64,E}, start::Int64, finish::Int64) where {V,E<:WeightedEdge}
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