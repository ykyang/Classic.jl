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

struct Cluster{P<:DataPoint}
    point::Vector{P}
    centroid::P
end

struct KMeans{P<:DataPoint}
    pointvec::Vector{P}
    clustervec::Vector{Cluster{P}}
end

function KMeans(k::Int64, pointvec::Vector{P}) where {P<:DataPoint}
    clustervec = Vector{Cluster{P}}()
    me = KMeans(pointvec, clustervec)

    

    return me
end

"""
    slice_derived(pointvec::Vector{P}, dimension) where {P<:DataPoint}

Cut a slice out of `DataPoint` at the specified dimension.

`dimensionSlice` in Java
"""
function slice_derived(pointvec::Vector{P}, dimension) where {P<:DataPoint}
    derivedvec = Vector{Float64}(undef, length(pointvec))
    
    for (i,p) in enumerate(pointvec)
        derivedvec[i] = p.derived[dimension]
    end

    return derivedvec
end

"""

`zScoreNormalize` in Java
"""
function normalize_zscore(pointvec::Vector{P}) where {P<:DataPoint}
    zscored = Vector{Vector{Float64}}()
    for i in 1:length(pointvec)
        push!(zscored, Vector{Float64}())
    end

    dimension = pointvec[1].dimension
    for dim_ind = 1:dimension
        dimension_slice = slice_derived(pointvec, dimension)
        mu = mean(dimension_slice)
        sigma = std(dimension_slice, corrected=false)
        zscores = zscore(dimension_slice, mu, sigma)
        for ind in 1:length(zscores)
            push!(zscored[ind], zscores[ind])
        end
        
    end
    
    for i in 1:length(pointvec)
        pointvec[i].derived = zscored[i]
    end
end