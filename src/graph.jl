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

"""
    edges_of(g::Graph{V,E}, v::V) where {V,E<:Edge}

Get the edges of a node (vertex).

...
# Arguments
- `g`: Graph
- `v`: Node (vertex)
...
"""
function edges_of(g::Graph{V,E}, v::V) where {V,E<:Edge}
    index = index_of(g, v)
    return edges_of(g, index)
end

"""
    edges_of(g::Graph{V,E}, index::Int64)  where {V,E<:Edge}

Get the edges of a node (vertex).

...
# Arguments
- `g`: Graph
- `index`: Index of the node (vertex)
...
"""
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


"""
    UnweightedGraph{V,E<:Edge} <: Graph{V,E}

An unweighted graph that uses any type of node and `Edge`
"""
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

"""
    WeightedGraph{V,E<:WeightedEdge} <: Graph{V,E}

A weighted graph that uses any type of node with `WeightedEdge`
"""
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

function Base.print(io::IO, g::WeightedGraph, edges::Vector{WeightedEdge})
    for edge in edges
        println(io, "$(vertex_at(g, edge[1])) $(weight(edge)) > $(vertex_at(g, edge[2]))")
    end
end


function next_points(grid, here)
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

"""
Deprecated, use next_points
"""
successors(grid, pt) = next_points(grid, pt)

function is_goal(goal, here)
    #return (goal[1] == here[1]) && (goal[2] == here[2])
    #@show goal, here
    return goal == here
end