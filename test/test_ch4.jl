#include("Classic.jl")

using Test, DataStructures
#using Classic
#import Classic as cc
cc = Classic

function init!(g::Classic.Graph{V,E}) where {V,E<:Classic.Edge}
    #cc = Classic

    cities = Vector{String}(["Seattle", "San Francisco",  
    "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston",
    "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit",
    "Philadelphia", "Washington",
    ])
    
    append!(g,cities)

    add!(g, "Seattle", "Chicago")
    add!(g, "Seattle","San Francisco")
    add!(g, "San Francisco", "Riverside")
    add!(g, "San Francisco", "Los Angeles")
    add!(g, "Los Angeles", "Riverside")
    add!(g, "Los Angeles", "Phoenix")
    add!(g, "Riverside", "Phoenix")
    add!(g, "Riverside", "Chicago")
    add!(g, "Phoenix", "Houston")
    add!(g, "Dallas", "Chicago")
    add!(g, "Dallas", "Atlanta")
    add!(g, "Dallas", "Houston")
    add!(g, "Houston", "Atlanta")
    cc.add!(g, "Houston", "Miami")
    cc.add!(g, "Atlanta", "Chicago")
    cc.add!(g, "Atlanta", "Washington")
    cc.add!(g, "Atlanta", "Miami")
    cc.add!(g, "Miami", "Washington")
    cc.add!(g, "Chicago", "Detroit")
    cc.add!(g, "Detroit", "Boston")
    cc.add!(g, "Detroit", "Washington")
    cc.add!(g, "Detroit", "Washington")
    cc.add!(g, "Detroit", "New York")
    cc.add!(g, "Boston", "New York")
    cc.add!(g, "New York", "Philadelphia")
    cc.add!(g, "Philadelphia", "Washington")

    return cities
end

function init!(g::Classic.WeightedGraph{V,E}) where {V,E<:Classic.WeightedEdge}
    #cc = Classic

    cities = Vector{String}(["Seattle", "San Francisco",  
    "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston",
    "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit",
    "Philadelphia", "Washington",
    ])
    
    append!(g,cities)

    cc.add!(g, "Seattle", "Chicago", 1737);
    cc.add!(g, "Seattle", "San Francisco", 678);
    cc.add!(g, "San Francisco", "Riverside", 386);
    cc.add!(g, "San Francisco", "Los Angeles", 348);
    cc.add!(g, "Los Angeles", "Riverside", 50);
    cc.add!(g, "Los Angeles", "Phoenix", 357);
    cc.add!(g, "Riverside", "Phoenix", 307);
    cc.add!(g, "Riverside", "Chicago", 1704);
    cc.add!(g, "Phoenix", "Dallas", 887);
    cc.add!(g, "Phoenix", "Houston", 1015);
    cc.add!(g, "Dallas", "Chicago", 805);
    cc.add!(g, "Dallas", "Atlanta", 721);
    cc.add!(g, "Dallas", "Houston", 225);
    cc.add!(g, "Houston", "Atlanta", 702);
    cc.add!(g, "Houston", "Miami", 968);
    cc.add!(g, "Atlanta", "Chicago", 588);
    cc.add!(g, "Atlanta", "Washington", 543);
    cc.add!(g, "Atlanta", "Miami", 604);
    cc.add!(g, "Miami", "Washington", 923);
    cc.add!(g, "Chicago", "Detroit", 238);
    cc.add!(g, "Detroit", "Boston", 613);
    cc.add!(g, "Detroit", "Washington", 396);
    cc.add!(g, "Detroit", "New York", 482);
    cc.add!(g, "Boston", "New York", 190);
    cc.add!(g, "New York", "Philadelphia", 81);
    cc.add!(g, "Philadelphia", "Washington", 123);

    return cities
end

function test_SimpleEdge(io::IO)
    #cc = Classic

    e = SimpleEdge(2, 7)
    @test 2 == e[1]
    @test 7 == e[2]
    @test "2 -> 7" == string(e)
    @test 2 == e[1]
    @test 7 == e[2]

    r = cc.reverse(e)
    @test e[1] == r[2]
    @test e[2] == r[1]
end

function test_UnweightedGraph(io::IO)
    #cc = Classic

    @test_throws TypeError cc.UnweightedGraph{Int64,Int64}()
    @test cc.UnweightedGraph{Int64,cc.SimpleEdge}() isa Any

    # V::Int64, E::Edge
    g = cc.UnweightedGraph{Int64,cc.SimpleEdge}()
    @test isempty(g.vertices)
    @test isempty(g.edges_lists)

    g = cc.UnweightedGraph{Int64,cc.SimpleEdge}([1,2,3])
    @test 3 == length(g.vertices)
    @test [1,2,3] == g.vertices
    @test 3 == length(g.edges_lists)

    # V::String, E::Edge
    g = cc.UnweightedGraph{String,cc.SimpleEdge}()
    @test isempty(g.vertices)
    @test isempty(g.edges_lists)

    g = cc.UnweightedGraph{String,cc.SimpleEdge}(["apple", "orange", "guava"])
    @test 3 == length(g.vertices)
    @test ["apple", "orange", "guava"] == g.vertices
    @test 3 == length(g.edges_lists)

    # Learn types
    @test cc.UnweightedGraph{Int64,cc.Edge} <: cc.Graph{Int64,cc.Edge}
    @test isa(cc.UnweightedGraph{Int64,cc.Edge}(), cc.Graph{Int64,cc.Edge})
end

"""

Sovle shortest route of `UnweightedGraph`
"""
function test_bfs(io::IO)
    #cc = Classic

    g = Classic.UnweightedGraph{String,cc.SimpleEdge}()
    cities = init!(g)
    @test length(cities) == length(g.vertices)
    @test length(cities) == length(g.edges_lists)
   
    for edges in g.edges_lists
        @test !isempty(edges)
    end

    #show(g)

    is_goal(pt) = cc.is_goal("Miami", pt)
    neighbor_of(v) = cc.neighbor_of(g, v)

    node = cc.bfs("Boston", is_goal, neighbor_of)
    @test ["Boston", "Detroit", "Washington", "Miami"] == cc.node_to_path(node)
    #println("Shortest route: $(cc.node_to_path(node))")

    nothing
end

function test_WeightedEdge(io::IO)
    #cc = Classic

    e = cc.WeightedEdge((3,7),13.0)
    @test 3 == e[1]
    @test 7 == e[2]
    @test 13 == cc.weight(e)

    e = cc.WeightedEdge(3,7,13.0)
    @test 3 == e[1]
    @test 7 == e[2]
    @test 13 == cc.weight(e)

    e = cc.reverse(e)
    @test 3 == e[2]
    @test 7 == e[1]
    @test 13 == cc.weight(e)

    # sum() and +operator
    edges = Vector{cc.WeightedEdge}([
        cc.WeightedEdge(3,7,13.0),
        cc.WeightedEdge(4,8,17.0),
        cc.WeightedEdge(5,9,19.0)
    ])
    @test 49 == sum(edges)
    
end

function test_WeightedGraph(io::IO)
    #cc = Classic

    @test_throws TypeError Classic.WeightedGraph{Int64,Int64}()
    @test cc.WeightedGraph{Int64,cc.WeightedEdge}() isa Any # @test_nothrows

    g = cc.WeightedGraph{Int64,cc.WeightedEdge}([1,2,3])
    @test 3 == length(g.vertices)
    @test [1,2,3] == g.vertices
    @test 3 == length(g.edges_lists)

    g = cc.WeightedGraph{String,cc.WeightedEdge}(["apple", "orange", "guava"])
    @test 3 == length(g.vertices)
    @test ["apple", "orange", "guava"] == g.vertices
    @test 3 == length(g.edges_lists)

    cc.add!(g, "apple", "orange", 13)
    @test 1 == length(g.edges_lists[1])
    @test 1 == length(g.edges_lists[2])
    @test 0 == length(g.edges_lists[3])
end

function test_mst(io::IO)
    #cc = Classic

    city_graph = cc.WeightedGraph{String,cc.WeightedEdge}()
    cities = init!(city_graph)
    @test length(cities) == length(city_graph.vertices)
    @test length(cities) == length(city_graph.edges_lists)

    #show(city_graph)

    mst_path = cc.mst(city_graph, 1)

    #cc.print_weighted_path(city_graph, mst_path)
    print(io, city_graph, mst_path)
    @test 14 == length(mst_path)
    #println("Total Weight: $(sum(mst_path))")
end

function test_DijkstraNode(io::IO)
    #cc = Classic

    node = DijkstraNode(13, 0.1)
    @test 13 == node.index 
    @test 0.1 == node.distance

    que = PriorityQueue{cc.DijkstraNode,Float64}()
    enqueue!(que, DijkstraNode(17, 1.2), 1.2)
    enqueue!(que, DijkstraNode(19, 2.3), 2.3)
    @test 2 == length(que)
    
    # the new node is considered duplicated because
    # its index is 17 even its distance is different
    # this is implemented by isequal
    @test_throws ArgumentError enqueue!(que, cc.DijkstraNode(17, 3.3), 1.1)

    @test 2 == length(que)
    node = dequeue!(que)
    @test 1.2 == node.distance
    node = dequeue!(que)
    @test 2.3 == node.distance
end

function test_dijkstra(io::IO)
    #cc = Classic

    city_graph = cc.WeightedGraph{String,cc.WeightedEdge}()
    cities = init!(city_graph)
    @test length(cities) == length(city_graph.vertices)
    @test length(cities) == length(city_graph.edges_lists)
   
    # Just a reminder
    # struct DijkstraResult
    #     distances::Vector{Float64}
    #     path_db::Dict{Int64,WeightedEdge}
    # end
    dijkstra_result = cc.dijkstra(city_graph, "Los Angeles")
    println(io, dijkstra_result)
    #@show dijkstra_result

    #ditance_db = Dict{V,Float64}()
    distance_db = cc.array_to_db(city_graph, dijkstra_result.distances)
    println(io, "Distance from Los Angeles:")
    println(io, distance_db)
    #@show distance_db

    # path::Vector{E}
    path = cc.path_db_to_path(
            city_graph, dijkstra_result.path_db, 
            cc.index_of(city_graph, "Los Angeles"),
            cc.index_of(city_graph, "Boston")
        )
    #@show path

    #cc.print_weighted_path(city_graph, path)
    print(io, stdout, city_graph, path)
    println(io, "Total Weight: $(sum(path))")
    # TODO show better

    @test nothing != dijkstra_result
end

io = devnull
#io = stdout

@testset "Unweighted Graph" begin
    test_SimpleEdge(io)
    test_UnweightedGraph(io)
    test_bfs(io)
end

@testset "Weighted Graph" begin
    test_WeightedEdge(io)
    test_WeightedGraph(io)
    test_mst(io)
end

@testset "Dijkstra" begin
    test_DijkstraNode(io)
    # test_dijkstra(io)
end

nothing
# print("""
# # --------------- #
# # Test completed! #
# # --------------- #
# """)
