
"""
Node

TODO: make this immutable

Record path in a maze
"""
mutable struct Node{P}
point::P #Tuple{Int64,Int64}  # MazeLocation
parent::Union{Node{P},Nothing}
cost::Float64
heuristic::Float64

# Node() = ( # incomplete initialization
#     me = new();
#     #me.cost = 0.0;
#     #me.heuristic = 0.0;
#     me
# )
function Node{P}() where {P}
    me = new()
    return me
end
# Node(point) = (
#     me = new();
#     me.point = point;
#     me.parent = nothing;
#     me
# )
function Node{P}(point::P) where {P}
      me = new();
      me.point = point;
      me.parent = nothing;
      me
end
# Node(point,parent) = (
#     me = new();
#     me.point = point;
#     me.parent = parent;
#     me
# )
function Node{P}(point::P, parent::Node{P}) where {P}
      me = new();
      me.point = point;
      me.parent = parent;
      me
end
# Node(point,parent,cost,heuristic) = (
#     me = new();
#     me.point = point;
#     me.parent = parent;
#     me.cost = cost;
#     me.heuristic = heuristic;
#     me
# )
end
#Base.:(<)(x::Node, y::Node) = x.id < y.id
Base.:(==)(x::Node,y::Node) = x.point == y.point

"""
DijkstraNode

Node for use in Dijkstra algorithm
"""
struct DijkstraNode
    index::Int64
    distance::Float64
    # function DijkstraNode(index, distance)
    #     new(index, distance)
    # end
end
# make sure not mis-use these 2 functions
Base.:(<)(x::DijkstraNode, y::DijkstraNode) = error("Unsupported operation")# x.distance < y.distance
Base.:(==)(x::DijkstraNode, y::DijkstraNode) = error("Unsupported operation") #x.distance == y.distance #error("Unsupported operation") #x.index == y.index
# to make Dict and PriorityQueue behavior the way we wanted
Base.isequal(x::DijkstraNode, y::DijkstraNode) = isequal(x.index, y.index) #x.index == y.index #error("Unsupported operation") 
Base.hash(x::DijkstraNode, h::UInt64=UInt64(13)) = hash(x.index,h)


function node_to_path(node::Node{P}) where {P}
    path = Vector{P}()
    push!(path, node.point)
    while !isnothing(node.parent)
        node = node.parent
        #push!(path, node.point)
        insert!(path, 1, node.point)
    end

    return path
end