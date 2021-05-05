using Test

# see https://discourse.julialang.org/t/writing-tests-in-vs-code-workflow-autocomplete-and-tooltips/57488
# see https://github.com/julia-vscode/julia-vscode/issues/800
if isdefined(@__MODULE__, :LanguageServer)
    include("../src/Classic.jl")
    using .Classic
else
    # invoked during test
    using Classic
end

function test_SimpleDataPoint()
    # Constructor
    data = Float64.([1,2])
    p = SimpleDataPoint(data)
    @test length(data) == p.dimension
    @test data == p.original
    @test data == p.derived

    # (==) checks `derived` for equality
    x = SimpleDataPoint(Float64.([1,2]))
    y = SimpleDataPoint(Float64.([1,2]))
    @test x == y

    x = SimpleDataPoint(Float64.([1,2]))
    y = SimpleDataPoint(Float64.([1,2]))
    x.original[1] = 13
    @test x == y
    
    x = SimpleDataPoint(Float64.([1,2]))
    y = SimpleDataPoint(Float64.([1,2]))
    x.derived[1] = 13
    @test x != y

end

function test_set_original!()
    data = Float64.([1,2])
    p = SimpleDataPoint(data)
    @test data == p.original
    @test data == p.derived

    data = Float64.([7,13])
    set_original!(p, data)
    @test data == p.original
    @test data == p.derived
end

function test_distance()
    # distance
    p1 = SimpleDataPoint(Float64.([1,2]))
    p2 = SimpleDataPoint(Float64.([2,1]))
    @test sqrt(2) ≈ distance(p1,p2)

    # Error: Points with different dimension
    p3 = SimpleDataPoint(Float64.([2]))
    @test_throws DomainError distance(p1,p3)
end

function test_Cluster()
end

function test_KMeans()
    # Constructor
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint([1.0,4.0]))
    @test KMeans(13, pointvec) isa Any

    # Error
    @test_throws DomainError KMeans(0, pointvec)
end

function test_slice_derived()
    # Setup
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint([1.0,4.0]))
    push!(pointvec, SimpleDataPoint([2.0,5.0]))
    push!(pointvec, SimpleDataPoint([3.0,6.0]))
    pointvec[1].derived .= [7.0, 10.0]
    pointvec[2].derived .= [8.0, 11.0]
    pointvec[3].derived .= [9.0, 12.0]
    # Test
    data = slice_derived(pointvec, 1)
    @test Float64.([7,8,9]) == data
    data = slice_derived(pointvec, 2)
    @test Float64.([10,11,12]) == data
end

function test_slice_original()
    # Setup
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint([1.0,4.0]))
    push!(pointvec, SimpleDataPoint([2.0,5.0]))
    push!(pointvec, SimpleDataPoint([3.0,6.0]))
    pointvec[1].derived .= [7.0, 10.0]
    pointvec[2].derived .= [8.0, 11.0]
    pointvec[3].derived .= [9.0, 12.0]

    # Test
    data = slice_original(pointvec, 1)
    @test Float64.([1,2,3]) == data
    data = slice_original(pointvec, 2)
    @test Float64.([4,5,6]) == data
end

function test_kmeans(io::IO)
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint(Float64.([2,1,1])))
    push!(pointvec, SimpleDataPoint(Float64.([2,2,5])))
    push!(pointvec, SimpleDataPoint(Float64.([3,1.5,2.5])))
    
    kmeans = KMeans(2, pointvec)
    run!(kmeans, 100)
    for (ind,cluster) in enumerate(kmeans.clustervec)
        println(io, "Cluster $(ind): $(cluster.pointvec)")
    end
    for cluster in kmeans.clustervec
        if 1 == length(cluster.pointvec) 
            point = cluster.pointvec[1]
            @test point.original == Float64.([2,2,5])
        elseif 2 == length(cluster.pointvec)
            for point in cluster.pointvec
                @test point.original == Float64.([2,1,1]) || point.original == Float64.([3,1.5,2.5])
            end
        end
    end
end

io = stdout
io = devnull

@testset "DataPoint" begin
    test_SimpleDataPoint()
    test_Cluster()
    test_KMeans()

    test_distance()
    test_set_original!()
    test_slice_derived()
    test_slice_original()
    test_kmeans(io)
end

nothing