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

cc = Classic


function run_astar()
    maze = cc.new_maze(10, 10, (1,1), (10,10), 0.2)

    # create functions for bfs()
    is_goal(pt)     = cc.is_goal(maze.goal, pt)
    next_points(pt) = cc.next_points(maze.grid, pt)
    heuristic(pt)   = cc.manhattan_distance(pt, maze.goal)

    node = cc.a_star((1,1), is_goal, next_points, heuristic)

    if isnothing(node)
        println("Path not found")
        display(maze.grid) # print the unsovled maze
    else
        cc.mark_path!(maze.grid, node, start=maze.start, goal=maze.goal)
        display(maze.grid) # print the maze and the path
    end
end

function run_bfs()
    maze = cc.new_maze(10, 10, (1,1), (10,10), 0.2)
    #maze = cc.new_maze(1)
    #maze = cc.new_maze(2)

    # create functions for bfs()
    is_goal(pt)     = cc.is_goal(maze.goal, pt)
    next_points(pt) = cc.next_points(maze.grid, pt)

    node = cc.bfs((1,1), is_goal, next_points)

    if isnothing(node)
        println("Path not found")
        display(maze.grid) # print the unsovled maze
    else
        cc.mark_path!(maze.grid, node, start=maze.start, goal=maze.goal)
        display(maze.grid) # print the maze and the path
    end
end

function run_cell()
    x = cc.EMPTY
    y = cc.START

    println("x = $(string(x)), y = $(string(y))")
end

"""
    run_dfs()

Use depth-first search to solve a maze.
"""
function run_dfs()
    maze = cc.new_maze() #new_maze(10,10, [1,1], [10,10], 0.2)
    #@show maze
    #display(maze.grid)

    #node = ch2.Node()
    #locations = ch2.successors(maze.grid, (2,2))
    #@show locations

    # pass this to dfs(..., successors)
    successors(here) = cc.successors(maze.grid, here)
    # pass this to dfs(..., goal_test, ...)
    is_goal(here) = cc.is_goal(maze.goal, here)

    node = cc.dfs((1,1), is_goal, successors)
    if isnothing(node)
        println("Path not found")
        display(maze.grid)
    else
        cc.mark_path!(maze.grid, node, start=maze.start, goal=maze.goal)
        #@show maze
        display(maze.grid)
    end
    #@show node
end

function test_bfs()
    for grid_ind = 1:2
        maze = new_maze(new_grid(grid_ind))

        # create functions for bfs()
        is_goal(pt)     = cc.is_goal(maze.goal, pt)
        next_points(pt) = cc.next_points(maze.grid, pt)

        node = bfs(maze.start, is_goal, next_points)
        @test !isnothing(node)
        
        mark_path!(maze.grid, node, start=maze.start, goal=maze.goal)
        #display(maze.grid)
        sol = new_maze(solution_grid(grid_ind))
        @test sol.grid == maze.grid
    end
end

function test_convert()
    # Char -> Cell
    x = 'O'
    @test Classic.EMPTY == Base.convert(Cell, x) # EMPTY not exported so must use Classic.EMPTY
    x = 'X'
    @test Classic.BLOCKED == Base.convert(Cell, x)
    x = 'S'
    @test Classic.START == Base.convert(Cell, x)
    x = 'G'
    @test Classic.GOAL == Base.convert(Cell, x)
    x = '+'
    @test Classic.PATH == Base.convert(Cell, x)

    x = fill('X', (30,30))
    y = fill(Classic.BLOCKED, (30,30))
    @test y == convert(Matrix{Cell}, x)

    x = fill('X', (30,30))
    x[16:end,16:end] .= '+'
    y = fill(Classic.BLOCKED, (30,30))
    y[16:end,16:end] .= Classic.PATH
    @test y == convert(Matrix{Cell}, x)

    # Cell -> Int
    x = Classic.EMPTY
    @test 0 == Base.convert(Int64, x)
    x = Classic.BLOCKED
    @test 1 == Base.convert(Int64, x)
    x = Classic.START
    @test 2 == Base.convert(Int64, x)
    x = Classic.GOAL
    @test 3 == Base.convert(Int64, x)
    x = Classic.PATH
    @test 4 == Base.convert(Int64, x)

    x = fill(Classic.BLOCKED, (30,30))
    y = fill(1, (30,30))
    @test y == convert(Matrix{Int64}, x)
end

function test_manhattan_distance()
    goal = (12,13)
    pt = (1,1)
    @test 23 == cc.manhattan_distance(pt, goal)
    
    goal = (1,1)
    pt = (12,13)
    @test 23 == cc.manhattan_distance(pt, goal)

    goal = (1,1)
    pt = (-12,-13)
    @test 27 == cc.manhattan_distance(pt, goal)
end



#run_astar()
#run_cell()
#run_dfs()
#run_bfs()
@testset "Maze" begin
    test_convert()
end

@testset "Breadth-first search" begin
    test_bfs()
end

@testset "A-star search" begin
    test_manhattan_distance()
end

nothing

#A = test_manhattan_distance()
#A # Test.Pass or not
