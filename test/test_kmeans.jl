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

function test_Governor()
    p = Governor(-89.79113, 72, "Alabama")
    @test 2 == p.dimension
    @test [-89.79113, 72] == p.original
    @test [-89.79113, 72] == p.derived
    @test -89.79113       == p.longitude
    @test 72              == p.age
    @test "Alabama"       == p.state

    data = Float64.([7, 13])
    p = Governor(data)
    @test 2    == p.dimension
    @test data == p.original
    @test data == p.derived
end

function test_kmeans_governor(io::IO)
    pointvec = Vector{Governor}()
    begin # add data
        push!(pointvec, Governor(-86.79113, 72, "Alabama"))
        push!(pointvec, Governor(-152.404419, 66, "Alaska"))
        push!(pointvec, Governor(-111.431221, 53, "Arizona"))
        push!(pointvec, Governor(-92.373123, 66, "Arkansas"))
        push!(pointvec, Governor(-119.681564, 79, "California"))
        push!(pointvec, Governor(-105.311104, 65, "Colorado"))
        push!(pointvec, Governor(-72.755371, 61, "Connecticut"))
        push!(pointvec, Governor(-75.507141, 61, "Delaware"))
        push!(pointvec, Governor(-81.686783, 64, "Florida"))
        push!(pointvec, Governor(-83.643074, 74, "Georgia"))
        push!(pointvec, Governor(-157.498337, 60, "Hawaii"))
        push!(pointvec, Governor(-114.478828, 75, "Idaho"))
        push!(pointvec, Governor(-88.986137, 60, "Illinois"))
        push!(pointvec, Governor(-86.258278, 49, "Indiana"))
        push!(pointvec, Governor(-93.210526, 57, "Iowa"))
        push!(pointvec, Governor(-96.726486, 60, "Kansas"))
        push!(pointvec, Governor(-84.670067, 50, "Kentucky"))
        push!(pointvec, Governor(-91.867805, 50, "Louisiana"))
        push!(pointvec, Governor(-69.381927, 68, "Maine"))
        push!(pointvec, Governor(-76.802101, 61, "Maryland"))
        push!(pointvec, Governor(-71.530106, 60, "Massachusetts"))
        push!(pointvec, Governor(-84.536095, 58, "Michigan"))
        push!(pointvec, Governor(-93.900192, 70, "Minnesota"))
        push!(pointvec, Governor(-89.678696, 62, "Mississippi"))
        push!(pointvec, Governor(-92.288368, 43, "Missouri"))
        push!(pointvec, Governor(-110.454353, 51, "Montana"))
        push!(pointvec, Governor(-98.268082, 52, "Nebraska"))
        push!(pointvec, Governor(-117.055374, 53, "Nevada"))
        push!(pointvec, Governor(-71.563896, 42, "New Hampshire"))
        push!(pointvec, Governor(-74.521011, 54, "New Jersey"))
        push!(pointvec, Governor(-106.248482, 57, "New Mexico"))
        push!(pointvec, Governor(-74.948051, 59, "New York"))
        push!(pointvec, Governor(-79.806419, 60, "North Carolina"))
        push!(pointvec, Governor(-99.784012, 60, "North Dakota"))
        push!(pointvec, Governor(-82.764915, 65, "Ohio"))
        push!(pointvec, Governor(-96.928917, 62, "Oklahoma"))
        push!(pointvec, Governor(-122.070938, 56, "Oregon"))
        push!(pointvec, Governor(-77.209755, 68, "Pennsylvania"))
        push!(pointvec, Governor(-71.51178, 46, "Rhode Island"))
        push!(pointvec, Governor(-80.945007, 70, "South Carolina"))
        push!(pointvec, Governor(-99.438828, 64, "South Dakota"))
        push!(pointvec, Governor(-86.692345, 58, "Tennessee"))
        push!(pointvec, Governor(-97.563461, 59, "Texas"))
        push!(pointvec, Governor(-111.862434, 70, "Utah"))
        push!(pointvec, Governor(-72.710686, 58, "Vermont"))
        push!(pointvec, Governor(-78.169968, 60, "Virginia"))
        push!(pointvec, Governor(-121.490494, 66, "Washington"))
        push!(pointvec, Governor(-80.954453, 66, "West Virginia"))
        push!(pointvec, Governor(-89.616508, 49, "Wisconsin"))
        push!(pointvec, Governor(-107.30249, 55, "Wyoming"))
    end

    #println(io, pointvec)
    kmeans = KMeans(2, pointvec)
    run!(kmeans, 100)
    for (ind,cluster) in enumerate(kmeans.clustervec)
        println(io, "Cluster $(ind):")
        for point in cluster.pointvec
            println(io, "$(point.state)\t\t$(point.age)\t\t$(point.longitude)")
        end
    end
end

io = stdout
#io = devnull

@testset "DataPoint" begin
    test_SimpleDataPoint()
    test_Cluster()
    test_KMeans()
    test_Governor()

    test_distance()
    test_set_original!()
    test_slice_derived()
    test_slice_original()
    test_kmeans(io)
    test_kmeans_governor(io)
end

nothing