# Chapter 2
# https://livebook.manning.com/book/classic-computer-science-problems-in-java/chapter-2/



# export Maze, Node
# export dfs
#import DataStructures
#using DataStructures

# export Cell
# export EMPTY

"""
    Cell

Cell type of a maze
"""
@enum Cell begin
    EMPTY
    BLOCKED
    START
    GOAL
    PATH
end



mutable struct Maze
    Maze() = (
        me = new();
        me
    )
    start::Tuple{Int64,Int64}
    goal::Tuple{Int64,Int64}
    grid::Matrix{Cell}
end


"""

TODO: relax the parameter type
"""
function manhattan_distance(point::Tuple{Int64,Int64}, goal::Tuple{Int64,Int64})
    delta = @. abs(point - goal) # abs.(point .- goal)
    distance = sum(delta)

    return distance
end

function new_maze(row_count, col_count, start, goal, sparseness)
    maze = Maze()

    grid = Array{Cell,2}(undef, row_count,col_count)
    grid .= EMPTY::Cell
    
    random_fill!(grid, sparseness)

    grid[start...] = START # same as setindex!(grid, START, start...)
    setindex!(grid, GOAL, goal...)
    
    maze.grid = grid
    maze.start = start
    maze.goal = goal

    return maze
end

function new_maze()
    return new_maze(10, 10, (1,1), (10,10), 0.2)
end

function new_maze(smaze::String)
    matrix::Vector{String} = split(smaze, "\n")

    row_length = length(matrix[1])
    for row in matrix
        if row_length != length(row)
            error("All rows must be the same length")
        end
    end

    row_count = length(matrix)
    col_count = row_length

    grid = Matrix{Cell}(undef, row_count,col_count)
    grid .= EMPTY::Cell
    for (row_ind,row) in enumerate(matrix)
        for col_ind in 1:length(row)
            grid[row_ind,col_ind] = to_cell(row[col_ind])
        end
    end
    
    maze = Maze()
    
    maze.grid = grid
    @show grid
    maze.start = findfirst(x -> x == START, grid)
    maze.goal = findfirst(x -> x == GOAL, grid)


    return maze
end

"""
Get predefined maze
"""
function new_maze(index::Integer)

    if 1 == index
        maze = new_maze(
        """SOOOOXOOOOOOOOOOXXOO
        OXOXOOXXOOOOOOXOOOOO
        OOOOXOXXOOOXOOOOOOOO
        OOOOOOOOOOOOOOOOOXOX
        OOOOOOOOOOOOOOOOOOXX
        XOXOOOXOOOOOOOXXOOOO
        OXOXOOOXOOOXOXXOOOOO
        XOOOOXOOOOXOOOOOOXXO
        OOOXOOOOOOOOOOOOOOOO
        XOOXOOOXOOOOOXOOOOOO
        OXXOOOOXOOOOOXOOOOXO
        OOOOOOXOOOXOOOOOOOOO
        OOOXOOOXOOOOXOOOXOOO
        OOOXXOOOOOOOOOXXOOOO
        OXOOOOOOOXOOOOOXXOOO
        XOOXOXOXOXOOOOOOOOOO
        XOOOOOXOOOOOOOOOOXOO
        OOOXXXOOOOOOOOOXOOOO
        OOOOOOXOXOOXXOOOOOOO
        OOOOOXOOOOOOOXOOXOOG"""
        )
    end

    return maze
end

function random_fill!(grid, sparseness) 
    for j in 1:size(grid)[2]
        for i in 1:size(grid)[1]
            if rand(Float64) < sparseness 
            #if rand(0:1.e-15:1) < sparseness
                grid[i,j] = BLOCKED::Cell
            end
        end
    end
end





#function is_goal(goal::V, here::V)

"""
    mark_path!(grid, node::Node; start=nothing, goal=nothing)

Mark PATH to `grid` starting from `node` and go back up to its `parent`
until the parent is `nothing`.  The `node` is usually pointed to `goal` of
the `grid`.
"""
function mark_path!(grid, node::Node; start=nothing, goal=nothing)
    if isnothing(goal)
        grid[node.point...] = PATH
    end

    while !isnothing(node.parent)
        node = node.parent
        if node.point != start        
            grid[node.point...] = PATH
        end
    end
end



function Base.show(io::IO, x::Cell)
    print(io, string(x))
end

function Base.display(x::Array{Cell})
    if ndims(x) == 2
        for i in 1:size(x)[1]
            for j in 1:size(x)[2]
                print(string(x[i,j]))
            end
            println()
        end
    end
    
end

"""
    string(x::Cell)

Convert enumeration `Cell` to an one character string.
"""
function Base.string(x::Cell)
    # TODO: use Swicth.jl
    if x == EMPTY
        return  "O" #"□" #"◻" #"▢" #"□"
    elseif x == BLOCKED
        return "X" #"■" #"■" #"▮" #"■" #"◾" #"■" # "X" #"■" #"▮"
    elseif x == START
        return "S" #"►" #"S"
    elseif x == GOAL
        return "G" #"◎" #"G"
    elseif x == PATH
        return "+" #"●" #"*" #"◘" #"*"
    end

    return "?"
end

function to_cell(x::Char)
    if 'O' == x
        return EMPTY
    elseif 'X' == x
        return BLOCKED
    elseif 'S' == x
        return START
    elseif 'G' == x
        return GOAL
    elseif '+' == x
        return PATH
    end

    return EMPTY
end