module Classic

using DataStructures

include("ch2.jl")

include("ch4.jl")
export add!, array_to_db, bfs, dijkstra, index_of, is_goal, path_db_to_path
export mst, node_to_path, reverse, weight
export Edge, Graph, UnweightedGraph, SimpleEdge, WeightedGraph, WeightedEdge
export DijkstraNode

end