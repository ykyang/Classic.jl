using Test, DataStructures

# see https://discourse.julialang.org/t/writing-tests-in-vs-code-workflow-autocomplete-and-tooltips/57488
# see https://github.com/julia-vscode/julia-vscode/issues/800
if isdefined(@__MODULE__, :LanguageServer)
    include("../src/Classic.jl")
    using .Classic
else
    # invoked during test
    using Classic
end

"""
    init!(g::Classic.Graph{V,E}) where {V,E<:Classic.Edge}

Create an example graph with unweighted edges
"""
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
    add!(g, "Houston", "Miami")
    add!(g, "Atlanta", "Chicago")
    add!(g, "Atlanta", "Washington")
    add!(g, "Atlanta", "Miami")
    add!(g, "Miami", "Washington")
    add!(g, "Chicago", "Detroit")
    add!(g, "Detroit", "Boston")
    add!(g, "Detroit", "Washington")
    add!(g, "Detroit", "Washington")
    add!(g, "Detroit", "New York")
    add!(g, "Boston", "New York")
    add!(g, "New York", "Philadelphia")
    add!(g, "Philadelphia", "Washington")

    return cities
end

"""
    init!(g::Classic.WeightedGraph{V,E}) where {V,E<:Classic.WeightedEdge}

Create a example graph with weighted edges
"""
function init!(g::Classic.WeightedGraph{V,E}) where {V,E<:Classic.WeightedEdge}
    #cc = Classic

    cities = Vector{String}(["Seattle", "San Francisco",  
    "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston",
    "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit",
    "Philadelphia", "Washington",
    ])
    
    append!(g,cities)

    add!(g, "Seattle", "Chicago", 1737);
    add!(g, "Seattle", "San Francisco", 678);
    add!(g, "San Francisco", "Riverside", 386);
    add!(g, "San Francisco", "Los Angeles", 348);
    add!(g, "Los Angeles", "Riverside", 50);
    add!(g, "Los Angeles", "Phoenix", 357);
    add!(g, "Riverside", "Phoenix", 307);
    add!(g, "Riverside", "Chicago", 1704);
    add!(g, "Phoenix", "Dallas", 887);
    add!(g, "Phoenix", "Houston", 1015);
    add!(g, "Dallas", "Chicago", 805);
    add!(g, "Dallas", "Atlanta", 721);
    add!(g, "Dallas", "Houston", 225);
    add!(g, "Houston", "Atlanta", 702);
    add!(g, "Houston", "Miami", 968);
    add!(g, "Atlanta", "Chicago", 588);
    add!(g, "Atlanta", "Washington", 543);
    add!(g, "Atlanta", "Miami", 604);
    add!(g, "Miami", "Washington", 923);
    add!(g, "Chicago", "Detroit", 238);
    add!(g, "Detroit", "Boston", 613);
    add!(g, "Detroit", "Washington", 396);
    add!(g, "Detroit", "New York", 482);
    add!(g, "Boston", "New York", 190);
    add!(g, "New York", "Philadelphia", 81);
    add!(g, "Philadelphia", "Washington", 123);

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

    r = Classic.reverse(e)
    @test e[1] == r[2]
    @test e[2] == r[1]
end

function test_UnweightedGraph(io::IO)
    #cc = Classic

    @test_throws TypeError UnweightedGraph{Int64,Int64}()
    @test UnweightedGraph{Int64,SimpleEdge}() isa Any

    # V::Int64, E::Edge
    g = UnweightedGraph{Int64,SimpleEdge}()
    @test isempty(g.vertices)
    @test isempty(g.edges_lists)

    g = UnweightedGraph{Int64,SimpleEdge}([1,2,3])
    @test 3 == length(g.vertices)
    @test [1,2,3] == g.vertices
    @test 3 == length(g.edges_lists)

    # V::String, E::Edge
    g = UnweightedGraph{String,SimpleEdge}()
    @test isempty(g.vertices)
    @test isempty(g.edges_lists)

    g = UnweightedGraph{String,SimpleEdge}(["apple", "orange", "guava"])
    @test 3 == length(g.vertices)
    @test ["apple", "orange", "guava"] == g.vertices
    @test 3 == length(g.edges_lists)

    # Learn types
    @test UnweightedGraph{Int64,Edge} <: Graph{Int64,Edge}
    @test isa(UnweightedGraph{Int64,Edge}(), Graph{Int64,Edge})
end

"""

Sovle shortest route of `UnweightedGraph`
"""
function test_bfs(io::IO)
    #cc = Classic

    g = UnweightedGraph{String,SimpleEdge}()
    cities = init!(g)
    @test length(cities) == length(g.vertices)
    @test length(cities) == length(g.edges_lists)
   
    for edges in g.edges_lists
        @test !isempty(edges)
    end

    #show(g)

    # `Classic.` is necessary because `is_goal` is ambiguous.
    is_goal(pt) = Classic.is_goal("Miami", pt)
    neighbor_of(v) = Classic.neighbor_of(g, v)

    node = bfs("Boston", is_goal, neighbor_of)
    @test ["Boston", "Detroit", "Washington", "Miami"] == node_to_path(node)
    #println("Shortest route: $(node_to_path(node))")

    nothing
end

function test_WeightedEdge(io::IO)
    #cc = Classic

    e = WeightedEdge((3,7),13.0)
    @test 3 == e[1]
    @test 7 == e[2]
    @test 13 == weight(e)

    e = WeightedEdge(3,7,13.0)
    @test 3 == e[1]
    @test 7 == e[2]
    @test 13 == weight(e)

    e = Classic.reverse(e)
    @test 3 == e[2]
    @test 7 == e[1]
    @test 13 == weight(e)

    # sum() and +operator
    edges = Vector{WeightedEdge}([
        WeightedEdge(3,7,13.0),
        WeightedEdge(4,8,17.0),
        WeightedEdge(5,9,19.0)
    ])
    @test 49 == sum(edges)
    
end

function test_WeightedGraph(io::IO)
    #cc = Classic

    @test_throws TypeError Classic.WeightedGraph{Int64,Int64}()
    @test WeightedGraph{Int64,WeightedEdge}() isa Any # @test_nothrows

    g = WeightedGraph{Int64,WeightedEdge}([1,2,3])
    @test 3 == length(g.vertices)
    @test [1,2,3] == g.vertices
    @test 3 == length(g.edges_lists)

    g = WeightedGraph{String,WeightedEdge}(["apple", "orange", "guava"])
    @test 3 == length(g.vertices)
    @test ["apple", "orange", "guava"] == g.vertices
    @test 3 == length(g.edges_lists)

    add!(g, "apple", "orange", 13)
    @test 1 == length(g.edges_lists[1])
    @test 1 == length(g.edges_lists[2])
    @test 0 == length(g.edges_lists[3])
end

function test_mst(io::IO)
    #cc = Classic

    city_graph = WeightedGraph{String,WeightedEdge}()
    cities = init!(city_graph)
    @test length(cities) == length(city_graph.vertices)
    @test length(cities) == length(city_graph.edges_lists)

    #show(city_graph)

    mst_path = mst(city_graph, 1)

    #print_weighted_path(city_graph, mst_path)
    print(io, city_graph, mst_path)
    @test 14 == length(mst_path)
    #println("Total Weight: $(sum(mst_path))")
end

function test_DijkstraNode(io::IO)
    #cc = Classic

    node = DijkstraNode(13, 0.1)
    @test 13 == node.index 
    @test 0.1 == node.distance

    que = PriorityQueue{DijkstraNode,Float64}()
    enqueue!(que, DijkstraNode(17, 1.2), 1.2)
    enqueue!(que, DijkstraNode(19, 2.3), 2.3)
    @test 2 == length(que)
    
    # the new node is considered duplicated because
    # its index is 17 even its distance is different
    # this is implemented by isequal
    @test_throws ArgumentError enqueue!(que, DijkstraNode(17, 3.3), 1.1)

    @test 2 == length(que)
    node = dequeue!(que)
    @test 1.2 == node.distance
    node = dequeue!(que)
    @test 2.3 == node.distance
end

function test_dijkstra(io::IO)
    # Create a default graph
    city_graph = WeightedGraph{String,WeightedEdge}()
    cities = init!(city_graph)
    @test length(cities) == length(city_graph.vertices)
    @test length(cities) == length(city_graph.edges_lists)
   
    # Just a reminder
    # struct DijkstraResult
    #     distances::Vector{Float64}
    #     path_db::Dict{Int64,WeightedEdge}
    # end
    dijkstra_result = dijkstra(city_graph, "Los Angeles")
    println(io, dijkstra_result)
    #@show dijkstra_result

    #ditance_db = Dict{V,Float64}()
    distance_db = array_to_db(city_graph, dijkstra_result.distances)
    println(io, "Distance from Los Angeles:")
    println(io, distance_db)
    #@show distance_db

    # path::Vector{E}
    path = path_db_to_path(
            city_graph, dijkstra_result.path_db, 
            index_of(city_graph, "Los Angeles"),
            index_of(city_graph, "Boston")
        )
    #@show path

    #print_weighted_path(city_graph, path)
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
    test_dijkstra(io)
end

nothing
# print("""
# # --------------- #
# # Test completed! #
# # --------------- #
# """)
