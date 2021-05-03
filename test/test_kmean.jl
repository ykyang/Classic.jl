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

@testset "DataPoint" begin
    test_SimpleDataPoint()
end

nothing