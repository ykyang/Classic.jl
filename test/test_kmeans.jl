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
    p = SimpleDataPoint(Float64.([1,2]))
    @test 2 == p.dimension
    @test Float64.([1,2]) == p.original
    @test Float64.([1,2]) == p.derived


    # distance
    p1 = SimpleDataPoint(Float64.([1,2]))
    p2 = SimpleDataPoint(Float64.([2,1]))
    @test sqrt(2) ≈ distance(p1,p2)
    p3 = SimpleDataPoint(Float64.([2]))
    @test_throws DomainError distance(p1,p3)
end

function test_Cluster()
end

function test_KMeans()
    # Constructor
    datapointvec = Vector{SimpleDataPoint}()
    @test KMeans(13, datapointvec) isa Any
end

function test_slice_derived()
    # Setup
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint([1.0,4.0]))
    push!(pointvec, SimpleDataPoint([2.0,5.0]))
    push!(pointvec, SimpleDataPoint([3.0,6.0]))

    # Test
    derivedvec = slice_derived(pointvec, 1)
    @test Float64.([1,2,3]) == derivedvec
    derivedvec = slice_derived(pointvec, 2)
    @test Float64.([4,5,6]) == derivedvec
end

function test_kmeans()
    pointvec = Vector{SimpleDataPoint}()
    push!(pointvec, SimpleDataPoint(Float64.([2,1,1])))
    push!(pointvec, SimpleDataPoint(Float64.([2,2,5])))
    push!(pointvec, SimpleDataPoint(Float64.([3,1.5,2.5])))
    
    kmeans = KMeans(2, pointvec)
    run(kmeans, 100)
end

@testset "DataPoint" begin
    test_SimpleDataPoint()
    test_Cluster()
    test_KMeans()

    test_slice_derived()
    test_kmeans()
end

nothing