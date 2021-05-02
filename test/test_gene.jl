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
    # Test Nucleotide(x::Char)
    @test Classic.A == Nucleotide('A')
    @test Classic.C == Nucleotide('C')
    @test Classic.G == Nucleotide('G')
    @test Classic.T == Nucleotide('T')
    @test_throws DomainError Nucleotide('Z')
    @test Nucleotide.(['A', 'C', 'G']) == [Classic.A, Classic.C, Classic.G]

    # Test Nucleotide(Int)
    @test Classic.A == Nucleotide(1)
    @test Classic.C == Nucleotide(2)
    @test Classic.G == Nucleotide(3)
    @test Classic.T == Nucleotide(4)
    @test_throws ArgumentError Nucleotide(5)
    @test Nucleotide.([1,2,3]) == [Classic.A, Classic.C, Classic.G]

    # Test Int(Nucleotide)
    @test 1 == Int(Nucleotide('A'))
    @test [1,2] == Int.([Nucleotide('A'), Nucleotide('C')])

    # convert()
    @test ['A', 'C'] == convert(Vector{Char}, [Nucleotide('A'), Nucleotide('C')])
    @test ['A', 'C'] == convert(Vector{Char}, [Classic.A, Classic.C])

    # Test <, ==, etc
    @test Nucleotide(1) == Nucleotide(1)
    @test Nucleotide(1) != Nucleotide(2)
    @test Nucleotide(1) < Nucleotide(2)
    @test Nucleotide(2) > Nucleotide(1)
    
    # isequal
    @test isequal(Nucleotide(1), Nucleotide(1))

    # hash
    @test hash(Nucleotide(1)) == hash(Nucleotide(1))
end

function test_Codon()
    # Test Codon(String)
    codon = Codon("AGT")
    @test [Classic.A, Classic.G, Classic.T] == codon.nucleotide
    codon = Codon("AGT1@#")
    @test [Classic.A, Classic.G, Classic.T] == codon.nucleotide
    @test_throws DomainError Codon("ZZZ")
    @test_throws BoundsError Codon("AG")

    # Test ==
    @test Codon("AGT") == Codon("AGT")
    @test Codon("ACT") != Codon("AGT")
    
    # isequal
    @test isequal(Codon("AGT"), Codon("AGT"))
    @test !isequal(Codon("ACT"), Codon("AGT"))

    # hash
    @test hash(Codon("AGT")) == hash(Codon("AGT"))
    @test hash(Codon("ACT")) != hash(Codon("AGT"))

    # <
    @test Codon("ACT") < Codon("AGT")
    @test Codon("AGT") > Codon("ACT")
    # isless
    @test isless(Codon("ACT"), Codon("AGT"))
    @test !isless(Codon("AGT"), Codon("ACT"))
end

function test_Gene()
    gene = Gene("AGTTGC")
    @test 2 == length(gene.codons)
    @test Codon("AGT") == gene.codons[1]
    @test Codon("TGC") == gene.codons[2]

    @test isempty(Gene("").codons)
    @test_throws BoundsError Gene("AGTT")
    @test_throws MethodError Gene()

    # linear search
    gene_str = "ACGTGGCTCTCTAACGTACGTACGTACGGGGTTTATATATACCCTAGGACTCCCTTT"
    @test linear_contains(Gene(gene_str), Codon("ACG"))
    @test !linear_contains(Gene(gene_str), Codon("GAT"))

    # binary search
    gene_str = "ACGTGGCTCTCTAACGTACGTACGTACGGGGTTTATATATACCCTAGGACTCCCTTT"
    @test true == binary_contains(Gene(gene_str), Codon("ACT"))
    @test false == binary_contains(Gene(gene_str), Codon("GAT"))

end


@testset "Gene" begin
    test_Nucleotide()
    test_Codon()
    test_Gene()
end

nothing