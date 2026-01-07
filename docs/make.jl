using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=joinpath(@__DIR__, "..")))
using VerifyMacros
using Documenter

DocMeta.setdocmeta!(VerifyMacros, :DocTestSetup, :(using VerifyMacros); recursive=true)

makedocs(;
    modules=[VerifyMacros],
    authors="Joris Pinkse <pinkse@gmail.com> and contributors",
    sitename="VerifyMacros.jl",
    format=Documenter.HTML(;
        canonical="https://NittanyLion.github.io/VerifyMacros.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/NittanyLion/VerifyMacros.jl",
    devbranch="main",
)
