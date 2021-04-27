module Classic

using DataStructures

# Order matters

include("node.jl")
export Node, DijkstraNode
export node_to_path

include("maze.jl")
export Cell, Maze
export new_maze

include("edge.jl")
export Edge, UnweightedGraph, SimpleEdge, WeightedEdge, WeightedGraph
#export reverse, weight
export weight

include("graph.jl")
export Graph
export add!, index_of, is_goal, next_points

include("algorithm.jl")
export DijkstraResult
export distances_to_distance_db, a_star, bfs, dfs, dijkstra, mst, shortest_path

end