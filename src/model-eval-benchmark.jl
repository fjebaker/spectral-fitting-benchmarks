using SpectralFitting
using BenchmarkTools
using Plots

energy = collect(range(1e-3, 10.0, 10_000))

model1a = XS_Gaussian(1.0, 3.0, 2.0)
model1b = GaussianLine(1.0, 3.0, 2.0)
flux = similar(energy)[1:end-1]
info1a = @benchmark invokemodel!($flux, $energy, $model1a)
info1b = @benchmark invokemodel!($flux, $energy, $model1b)

model2a = sum(XS_Gaussian() for i in 1:2)
model2b = sum(GaussianLine() for i in 1:2)
flux = SpectralFitting.construct_objective_cache(model2a, energy)
info2a = @benchmark invokemodel!($flux, $energy, $model2a)
info2b = @benchmark invokemodel!($flux, $energy, $model2b)

model3a = sum(XS_Gaussian() for i in 1:8)
model3b = sum(GaussianLine() for i in 1:8)
flux = SpectralFitting.construct_objective_cache(model3a, energy)
info3a = @benchmark invokemodel!($flux, $energy, $model3a)
info3b = @benchmark invokemodel!($flux, $energy, $model3b)

all_times = (
    median.((info1a.times, info1b.times)),
    median.((info2a.times, info2b.times)),
    median.((info3a.times, info3b.times)),
)

begin
    bar(
        [0, 1, 2],
        [t[1] / 1e6 for t in all_times],
        ylabel = "Evaluation time (ms)",
        xticks = ([0, 1, 2], ["1 Model", "2 Models", "8 Models"]),
        label = "XSPEC",
        title = "Model Evaluation Time on 10⁴ bins (lower is better)"
    )
    bar!(
        [0, 1, 2],
        [t[2] / 1e6 for t in all_times],
        label = "SpectralFitting.jl"
    )
end

savefig("figs/spectral-fitting-benchmark-model-eval-speed.pdf")