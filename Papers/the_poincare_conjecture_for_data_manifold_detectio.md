# Computational Evidence

## Small-case calculations

Consider the indexed two-point cloud `X(0)=0`, `X(1)=2` in the real line. At scale `1`, its Rips graph has no edge, so its flag complex consists of the empty simplex and two vertices: three simplices in total. At scale `2`, the edge appears and the flag complex is the full simplex on two vertices: four simplices. These two boundary claims are instantiated in `PoincareThresholdStability.lean`.

For three collinear points at `0,1,2`, the edge counts at scales below `1`, from `1` to below `2`, and at least `2` are respectively `0`, `2`, and `3`. The corresponding clique counts are `4`, `6`, and `8`. This illustrates that edge and simplex thresholds are controlled by pair distances, while homology may appear and disappear at different scales.

## OEIS search results

No sequence arose that would materially constrain the metric-stability theorems. Consequently no OEIS identification is asserted. The basic full-simplex count `2^n` is standard subset enumeration rather than evidence for the proposed sphere-detection scaling law.

## Counterexample hunt

The unguarded inference “sphere homology of one Rips complex implies geometric nearness to a sphere” is not supported by the finite combinatorial data considered here. Homology does not characterize general spaces, and a single-scale flag complex does not retain a unique Euclidean realization. The formal development therefore proves guarded metric and combinatorial statements only.

The proposed universal threshold `C sqrt(d) n^(-1/d)` also requires a sampling distribution and a precise threshold event. For uniform random coverage of a compact `d`-dimensional space, extreme gaps generally suggest a logarithmic correction, unlike typical nearest-neighbor spacing. This distinction motivates a separate probabilistic conjecture rather than an unconditional theorem.

## Table

| Cloud | Scale | Edges | Flag-complex simplices | Full simplex? |
|---|---:|---:|---:|---|
| `{0,2}` | `1` | `0` | `3` | no |
| `{0,2}` | `2` | `1` | `4` | yes |
| `{0,1,2}` | `<1` | `0` | `4` | no |
| `{0,1,2}` | `1` | `2` | `6` | no |
| `{0,1,2}` | `2` | `3` | `8` | yes |
