# Chapter 2
# https://livebook.manning.com/book/classic-computer-science-problems-in-java/chapter-2/v-4/7

"""
    Nucleotide

Nucleotide
"""
@enum Nucleotide begin
    A = 1
    C = 2
    G = 3
    T = 4
end

function Nucleotide(x::Char)
    if 'A' == x
        return A::Nucleotide
    elseif 'C' == x
        return C::Nucleotide
    elseif 'G' == x
        return G::Nucleotide
    elseif 'T' == x
        return T::Nucleotide
    end

    throw(DomainError("Unknown nucleotide $x"))
end

function Base.convert(::Type{Char}, x::Nucleotide)
    if A == x
        return 'A'
    elseif C == x
        return 'C'
    elseif G == x
        return 'G'
    elseif T == x
        return 'T'
    end

    throw(DomainError("Unknown nucleotide $x"))
end

struct Codon
    nucleotide::Vector{Nucleotide}
end
function Codon(x::String)
    v = Vector{Nucleotide}([
        Nucleotide(x[1]),
        Nucleotide(x[2]),
        Nucleotide(x[3]),
    ])
    Codon(v)
end
Base.:(==)(x::Codon,y::Codon) = x.nucleotide == y.nucleotide
Base.:(<)(x::Codon,y::Codon) = x.nucleotide < y.nucleotide
Base.isless(x::Codon,y::Codon) = isless(x.nucleotide,y.nucleotide)
Base.hash(x::Codon, h::UInt64=UInt64(13)) = hash(x.nucleotide,h)


struct Gene
    codons::Vector{Codon}
end

function Gene(x::String)
    codons = Vector{Codon}()
    for i in 1:3:length(x)
        codon = Codon(x[i:i+2])
        push!(codons, codon)
    end

    return Gene(codons)
end

function linear_contains(gene::Gene, key::Codon)
    for codon in gene.codons
        if key == codon
            return true
        end
    end

    return false
end

function binary_contains(gene::Gene, key::Codon)
    codons = sort(gene.codons)
    low = 1
    high = length(codons)

    while low <= high
        middle = div(low+high, 2) #(low+high) ÷ 2 # integer divide
        
        if codons[middle] < key
            low = middle + 1
        elseif codons[middle] > key
            high = middle -1
        else # codons[middle] == key
            return true
        end
    end

    return false
end