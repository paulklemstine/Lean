# Summary of changes for run a9d30e60-aa6e-476e-bfe0-235d0d485032
## Research cycle: Tropical geometry of deep ReLU networks (MachineLearning)

### New verified Lean file
`Catalog/MachineLearning/TropicalReLUDeep.lean` — builds cleanly with **0 sorries** (axioms: only `propext`, `Classical.choice`, `Quot.sound`). It extends the catalog's existing one-hidden-layer bridge `Catalog/MachineLearning/TropicalReLUBridge.lean` to the **full, arbitrary-depth Zhang–Naitzat–Lim correspondence**.

Main results proved:
- **Closure algebra of tropical rational functions** (`IsTropRational`): closed under addition, negation, subtraction, scaling by *any* real (sign handled by swapping numerator/denominator polynomials), finite affine combinations, pointwise `max`, pointwise `min` (via `min = -max(-·,-·)`), and `ReLU`. This shows the class is a lattice-ordered ℝ-vector space closed under ReLU.
- **`deepReLUNetFns_isTropRational`**: every output coordinate of a depth-`L`, width-`w` ReLU MLP (defined by `Nat`-recursion on depth) is a tropical rational function of the input.
- **`deepReLUNetReadout_isTropRational`**: the scalar output with a linear read-out head is tropical rational at any depth — the complete deep theorem.
- **Regularity corollaries**: `affEval_continuous`, `IsTropPoly.continuous`, `IsTropRational.continuous`, and `deepReLUNetReadout_continuous` — deep ReLU read-outs are continuous "for free" from the bridge.

### Lab Notes
Inline `-- !-- Lab Notes -- !--` blocks document the hypotheses, the key additive-shift identity `max(p₁-q₁, p₂-q₂) = max(p₁+q₂, p₂+q₁) - (q₁+q₂)`, the negative-scaling and `min` constructions, and a failure analysis explaining why depth genuinely requires the *rational* (difference) class rather than just tropical polynomials (min of convex functions need not be convex).

### FUTURE_DIRECTIONS.md
Five falsifiable follow-up conjectures: (C1) exactness `IsTropRational = finite-piece CPWL`; (C2) provable depth-vs-width linear-region separation; (C3) Lipschitz constant = tropical coefficient spread, sharpening the existing margin Lipschitz lemma; (C4) decision boundaries as measure-zero polyhedral complexes; (C5) composition/residual closure removing the equal-width restriction.

### Build fix
The shipped `lakefile.toml` referenced source roots (e.g. `Algebra`, `MachineLearning`) at the package root, but all sources live under `Catalog/`, so the project did not build at all. Added `srcDir = "Catalog"` to the package config, after which the targets resolve and the new module compiles.