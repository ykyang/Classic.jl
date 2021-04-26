# Classic Computer Science Problems in Julia
Follows the book [Classic Computer Science Problems in Java](https://livebook.manning.com/book/classic-computer-science-problems-in-java) and translated into Julia.

# Test
## Setup
Create test directory `test/` and test script `test/runtests.jl`.  Start `Julia` in `test/` with
```
julia --project=test
```
Add `Test` package and any packages required only during testing
```
]
add Test
```
## Run test
Run all tests from command line
```
cd Classic/
julia --project=@. test/runtests.jl
```
or from REPL
```julia
julia> pwd()
".../.../Classic"
include("test/runtests.jl")
```
Run individual tests from REPL
```julia
julia> pwd()
".../.../Classic"
include("test/test_ch4.jl")
```
Run test in package mode
```julia
julia> ]
(Classic) pkg> test Classic
```