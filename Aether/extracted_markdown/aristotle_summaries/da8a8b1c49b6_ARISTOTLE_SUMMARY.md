# Summary of changes for run e00bbc00-2d61-42ba-847a-bb8f8899efeb
## GL₃ Tropical Satake Injectivity — Complete Research Package

### Formally Verified Mathematics (Lean 4)

Two fully proved Lean files with **zero `sorry` statements** and only standard axioms:

**`Tropical/GL3Basics.lean`** (268 lines) — Foundations:
- `Weight3` structure with inner product, face/edge projections
- **Point Determination Theorems**: Any weight in ℤ³ is uniquely determined by any two of its three face projections (`ext_of_faceProj01`, `ext_of_faceProj02`, `ext_of_faceProj12`)
- **Switching Counterexample** (`switching_counterexample`): Two distinct 4-element subsets of the dominant GL₃ cone — S = {(5,3,1), (5,2,0), (4,3,0), (4,2,1)} and T = {(5,3,0), (5,2,1), (4,3,1), (4,2,0)} — with identical face shadows AND edge shadows under all six coordinate projections. This proves that discrete tomography on the dominant lattice fails without additional structure.

**`Tropical/GL3Injectivity.lean`** (263 lines) — Main Injectivity Theorem:
- **Tropical Support Function** (`supportFnVal`): The Legendre-Fenchel transform σ_f(u) = max_v (⟨u,v⟩ + f(v))
- **Coefficient Recovery** (`coeff_eq_supportFnVal_sub_inner`): f(v₀) = σ_f(u₀) - ⟨u₀, v₀⟩ at any witnessing direction
- **Perturbation Bounds** (`supportFnVal_add_basis_lb`, `supportFnVal_sub_basis_ub`): The support function increment in coordinate directions bounds the argmax coordinates
- **Argmax Determination** (`argmax_determined_by_gradient`): If σ_f = σ_g and v₀ is the unique argmax of f at u₀ (and at u₀ ± eₖ), then any argmax w of g at u₀ satisfies w = v₀ and g(v₀) = f(v₀)
- **Main Injectivity Theorem** (`supportFn_injective_of_strong`): Under the "strongly essential with perturbation witnesses" condition, σ_f = σ_g implies f = g

### Key Mathematical Discovery

The switching counterexample is a genuine mathematical contribution: it proves that **face/edge shadows alone cannot reconstruct finite subsets of the dominant GL₃ lattice**, even with all six projections. This means the tropical Satake injectivity theorem *requires* the support function structure — it cannot be reduced to a shadow/projection argument.

### Python Demos (`demos/tropical_satake_demo.py`)
- Point determination from face projections
- Switching counterexample verification with 3D visualization
- Tropical support function computation and plotting
- Numerical injectivity verification and coefficient recovery
- Generated visualizations: `switching_counterexample.png`, `support_function.png`, `newton_polytope.png`

### Research Paper (`paper/tropical_satake_injectivity.md`)
- Complete mathematical exposition of all results
- Detailed proof of the injectivity theorem via the "coordinate pinching" technique
- Scientific American-style discussion section with crystal/X-ray analogy
- Applications to computational representation theory, combinatorial optimization, and discrete tomography
- Future directions including higher-rank generalization