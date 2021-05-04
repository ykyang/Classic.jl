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

function Base.:(==)(x::DataPoint, y::DataPoint)
    return x.derived == y.derived
end

function set_original!(x::P, initial) where {P<:DataPoint}
    if x.dimension != length(initial)
        throws(DomainError("Dimension mismatching"))
    end
    
    x.original .= initial
    x.derived .= initial
end

function distance(x::P, y::P) where {P<:DataPoint}
    if x.dimension != y.dimension
        throw(DomainError("Mis-matching dimensions: $(x.dimension), $(y.dimension)"))
    end

    diff2 = @. (x.derived - y.derived) ^ 2

    return sqrt(sum(diff2))
end

struct Cluster{P<:DataPoint}
    pointvec::Vector{P}
    centroid::P
end

struct KMeans{P<:DataPoint}
    pointvec::Vector{P}
    clustervec::Vector{Cluster{P}}
end

function KMeans(k::Int64, pointvec::Vector{P}) where {P<:DataPoint}
    # TODO: Check k

    clustervec = Vector{Cluster{P}}()
    me = KMeans(pointvec, clustervec)
    
    # initialize with random clusters
    normalize_zscore!(me.pointvec)
    dimension_count = pointvec[1].dimension
    for i in 1:k
        rand_point = random_point(pointvec)
        cluster = Cluster(Vector{P}(), rand_point)
        push!(me.clustervec,cluster)
    end

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
function normalize_zscore!(pointvec::Vector{P}) where {P<:DataPoint}
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
        pointvec[i].derived .= zscored[i]
    end
end

function random_point(pointvec::Vector{P}) where {P<:DataPoint}
    rand_derived = Vector{Float64}()
    dimension_count = pointvec[1].dimension
    for i in 1:dimension_count
        values = slice_derived(pointvec, i)
        Max = maximum(values)
        Min = minimum(values)
        rand_value = Min + rand() * (Max-Min)
        push!(rand_derived, rand_value)
    end

    return P(rand_derived)
end

function assign_clusters!(kmeans::KMeans)
    for point in kmeans.pointvec
        lowest_distance = typemax(Float64)
        cloest_cluster = kmeans.clustervec[1]
        for cluster in kmeans.clustervec
            centroid_distance = distance(point, cluster.centroid)
            if centroid_distance < lowest_distance
                lowest_distance = centroid_distance
                cloest_cluster = cluster
            end
        end

        # pointvec was cleared outside
        push!(cloest_cluster.pointvec, point)
    end
end

function centroids(kmeans::KMeans)
    [c.centroid for c in kmeans.clustervec]
end

function generate_centroids!(kmeans::KMeans)
    for cluster in kmeans.clustervec
        if isempty(cluster.pointvec)
            continue
        end

        means = Vector{Float64}()
        dimension_count = cluster.pointvec[1].dimension
        for dimension in 1:dimension_count

            # TODO: use slice_derived
            #dimension_mean = 
            derived = [p.derived[dimension] for p in cluster.pointvec]
            derived_mean = mean(derived)
            push!(means, derived_mean)
        end

        set_original!(cluster.centroid, means)
    end
end

function run!(kmeans::KMeans, maxIt::Int64)
    for it in 1:maxIt
        for cluster in kmeans.clustervec
            resize!(cluster.pointvec,0) # clear
        end

        assign_clusters!(kmeans)
        old_centroids = centroids(kmeans)
        generate_centroids!(kmeans)
        if old_centroids == centroids(kmeans)
            println("Converged after $it iterations.")
            return
        end
    end

    #error("Not supported operation")
end