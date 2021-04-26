"""
    Edge

An abstract edge for working with graph

* `getindex` : get the first and second nodes
* `string` : pretty print
* `reverse` : reverse the 2 ends

"""
abstract type Edge end

function Base.getindex(edge::Edge, i::Int64) #where {E<:Edge}
    return edge.vertices[i]
end

function Base.reverse(e::E) where {E<:Edge}
    return E(Base.reverse(e.vertices))
end

Base.string(e::Edge) = "$(e[1]) -> $(e[2])"
Base.show(io::IO, x::Edge) = print(io, string(x))

"""
    SimpleEdge <: Edge

A simple implementation of `Edge` which only has 2 points
"""
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

"""
    WeightedEdge <: Edge

A weighted version of `Edge` that has 2 points and a weight

* `weight`
* `reverse`
"""
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

function Base.reverse(e::WeightedEdge)
    WeightedEdge(e[2], e[1], weight(e))
end
