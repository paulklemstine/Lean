# Summary of changes for run 3821fdd7-cff2-4b21-84b5-caf2f31f57f5
# Newton Hierarchy for Interacting Fermions via Determinantal Approximation

## Formally Verified Mathematics (Lean 4)

Created `Catalog/Pythagorean/NewtonInteractingFermions.lean` — a complete, sorry-free, warning-free Lean 4 development proving perturbative stability of Newton-ratio observables under spectral deformation. All proofs are verified against Mathlib and use only standard axioms (propext, Classical.choice, Quot.sound).

### New Definitions
- **`WeaklyInteractingApprox`** — Structure modeling an interacting entanglement spectrum close to a free-fermion reference, with nonnegativity and sup-norm closeness guarantees.
- **`NewtonRatioDeviation'`** — Measures |ρ_k(p) - ρ_k(q)| between two spectra.
- **`NewtonStableToOrder'`** — Predicate: all Newton ratio deviations up to level K are bounded by C·ε.
- **`ApproxAreaLawCompatible'`** — Approximate area-law bound with controlled deformation.
- **`computeNewtonProfileSpec`** / **`certifiedNewtonDeviationBoundSpec`** — Specification-level algorithms for Newton profiles and certified bounds.

### Proved Theorems (all sorry-free)
1. **`esymm_lipschitz_supnorm`** — Lipschitz stability of elementary symmetric polynomials: if |p_i - q_i| ≤ ε for all i, then |e_k(p) - e_k(q)| ≤ C·ε for some C ≥ 0.
2. **`newton_ratio_lipschitz`** — Newton ratio stability under weak perturbation with denominator nondegeneracy: |ρ_k(p) - ρ_k(q)| ≤ C·ε.
3. **`approx_area_law_of_weakly_interacting`** — Area-law compatibility survives interaction: if fermionEntropy(q) ≤ C_orig and p is ε-close, then fermionEntropy(p) ≤ C_orig + D·ε.
4. **`interacting_fermion_newton_control`** — Cross-domain physics corollary: WeaklyInteractingApprox implies global Newton stability to any order K.
5. **`div_sub_div_bound`** — Generic rational perturbation estimate with explicit denominator control: |a/b - a'/b'| ≤ α/δ + |a'|·β/δ².
6. **Helper lemmas:** `spectra_eq_of_zero_distance`, `esymm_eq_of_eq_spectra`, `NewtonRatioDeviation'_triangle`, `certifiedNewtonDeviationBound_is_bound`, plus symmetry/nonnegativity/self properties.

## Other Deliverables

- **`ARTICLE.md`** — Popular-science article (~2000 words) on stable algebraic fingerprints of quantum matter.
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, definitions, theorem statements, proof sketches, algorithms with complexity analysis, computational experiments, and the weak-coupling Newton universality conjecture.
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format, including bridges to random matrix theory, tropical geometry, quantum chemistry, and complexity theory.
- **`demo.py`** — Interactive demonstration with 3 experiments: basic stability, Hubbard-inspired coupling scan with log-log slope analysis, and Lipschitz constant estimation.
- **`algorithms.py`** — Core algorithms (O(n·K) DP for elementary symmetric polynomials, Newton profile computation, certified deviation bounds) with docstrings and type hints.
- **`applications.py`** — Applications to phase detection, entanglement compression, and interaction strength estimation.
- **`viz_newton_stability.py`**, **`viz_esymm_lipschitz.py`**, **`viz_area_law_stability.py`** — Three self-contained visualization scripts.
- **`PACKAGE.json`** — Complete JSON data package with all content for web templating, including an interactive HTML Newton ratio explorer with slider control.