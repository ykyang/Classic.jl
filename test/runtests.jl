# run
using Test

# see https://discourse.julialang.org/t/writing-tests-in-vs-code-workflow-autocomplete-and-tooltips/57488
# see https://github.com/julia-vscode/julia-vscode/issues/800
if isdefined(@__MODULE__, :LanguageServer)
    # invoked by VS Code
    include("../src/Classic.jl")
    using .Classic
else
    # invoked during test
    using Classic
end

include("test_ch2.jl")
include("test_ch4.jl")
