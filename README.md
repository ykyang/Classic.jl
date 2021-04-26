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
## Test code completion and tooltip problem
The code completion and code tooltip does not work in VS Code without
the following at the top of `runtests.jl`.  In order to run individual
tests, also include this in individual test files.
```julia
if isdefined(@__MODULE__, :LanguageServer)
    # invoked by VS Code
    include("../src/Classic.jl")
    using .Classic
else
    # invoked during test
    using Classic
end
```
This workaround is from [Writing tests in VS Code](https://discourse.julialang.org/t/writing-tests-in-vs-code-workflow-autocomplete-and-tooltips/57488) and subsequently from [None of the symbols in my package seem to be recognized](https://github.com/julia-vscode/julia-vscode/issues/800).