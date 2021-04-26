"""
    Edge

An abstract edge for working with graph

* `getindex` : get the first and second nodes
* `string` : pretty print

"""
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

# function reverse(e::SimpleEdge)
#     return SimpleEdge(Base.reverse(e.vertices))
# end

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
