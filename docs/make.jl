using Documenter
using MLInterface

const REPO="github.com/JuliaAI/MLInterface.jl"

makedocs(;
    modules=[MLInterface],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages=[
        "Introduction" => "index.md",
        "Anatomy of an Implementation" => "anatomy_of_an_implementation.md",
        "Common Implementation Patterns" => "common_implementation_patterns.md",
        "Reference" => "reference.md",
        "Fit, update and ingest" => "fit_update_and_ingest.md",
    ],
    repo="https://$REPO/blob/{commit}{path}#L{line}",
    sitename="MLInterface.jl"
)

deploydocs(;
    repo=REPO,
    devbranch="dev",
    push_preview=false,

           )