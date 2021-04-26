#include("Classic.jl")

using Test

import Classic
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
run_bfs()

nothing

#A = test_manhattan_distance()
#A # Test.Pass or not
