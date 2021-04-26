module Classic

using DataStructures

# Order matters

include("node.jl")
export Node, DijkstraNode
export node_to_path

include("maze.jl")
export Cell, Maze

include("edge.jl")
export Edge, UnweightedGraph, SimpleEdge, WeightedGraph, WeightedEdge
export reverse, weight

include("graph.jl")
export Graph
export add!, index_of, is_goal, next_points

include("algorithm.jl")
export array_to_db, a_star, bfs, dfs, dijkstra, mst, path_db_to_path

end