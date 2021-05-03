abstract type DataPoint end


struct SimpleDataPoint <: DataPoint
    dimension::Int64
    original::Vector{Float64}
    derived::Vector{Float64}
    function SimpleDataPoint(initial::Vector{Float64})
        dimension = length(initial)
        original = initial # reference to input array
        derived = copy(initial)

        new(dimension, original, derived)
    end
end

function distance(x::P, y::P) where {P<:DataPoint}
    if x.dimension != y.dimension
        throw(DomainError("Mis-matching dimensions: $(x.dimension), $(y.dimension)"))
    end

    diff2 = @. (x.derived - y.derived) ^ 2

    return sqrt(sum(diff2))
end

struct Cluster{P} where {P<:DataPoint}
    point::Vector{P}
    centroid::P
end

