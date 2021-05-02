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

function test_Nucleotide()
    @test Classic.A == Nucleotide('A')
    @test Classic.C == Nucleotide('C')
    @test Classic.G == Nucleotide('G')
    @test Classic.T == Nucleotide('T')
    @test_throws DomainError Nucleotide('Z')

    @test Classic.A == Nucleotide(1)
    @test Classic.C == Nucleotide(2)
    @test Classic.G == Nucleotide(3)
    @test Classic.T == Nucleotide(4)
    @test_throws ArgumentError Nucleotide(5)

    @test Nucleotide.([1,2,3]) == [Classic.A, Classic.C, Classic.G]
    @test Nucleotide.(['A', 'C', 'G']) == [Classic.A, Classic.C, Classic.G]
end

function test_Codon()
    codon = Codon("AGT")
    @test [Classic.A, Classic.G, Classic.T] == codon.nucleotide
    @test [1,3,4] == Int64.(codon.nucleotide)
    @test ['A', 'G', 'T'] == convert(Vector{Char}, codon.nucleotide)

    codon = Codon("AGT1@#")
    @test [Classic.A, Classic.G, Classic.T] == codon.nucleotide

    @test_throws DomainError Codon("ZZZ")
    @test_throws BoundsError Codon("AG")
end

function test_Gene()
    gene = Gene("AGTTGC")
    @test 2 == length(gene.codons)
    @test Codon("AGT") == gene.codons[1]
    @test Codon("TGC") == gene.codons[2]

    @test isempty(Gene("").codons)
    @test_throws BoundsError Gene("AGTT")
    @test_throws MethodError Gene()
end

@testset "Gene" begin
    test_Nucleotide()
    test_Codon()
    test_Gene()
end

nothing