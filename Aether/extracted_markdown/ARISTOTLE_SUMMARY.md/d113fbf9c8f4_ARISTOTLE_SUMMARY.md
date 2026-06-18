# Summary of changes for run 75039e60-d929-49dc-a9ae-7d6c63a442dd
## Learning with Errors: Hardness Reductions — Lean 4 Formalization

Created `Computation/LWEBasic.lean` (297 lines) containing a complete, sorry-free formalization of the mathematical foundations of the Learning with Errors (LWE) problem and its connections to worst-case lattice problems.

### Definitions
- **`LWEInstance`**: Matrix A ∈ ℤ_q^{m×n} and target vector b ∈ ℤ_q^m
- **`IntLatticeBasis`**: Integer lattice basis representation
- **`intVecNormSq`**, **`isLatticePoint`**, **`hasShortVector`**: Lattice geometry primitives
- **`regev_parameter_valid`**: The condition αq ≥ 2√n from Regev's reduction
- **`regev_approx_factor`**: The GapSVP approximation factor γ = n/α

### Theorems (all proven, all with PEGB)

1. **LWE Sample Reduction** (`lwe_sample_reduction`): LWE with m samples reduces to m' ≤ m samples by row extraction. Generalized to arbitrary injections (`lwe_sample_injection_reduction`). Boundary: 0-sample instances are trivially equal.

2. **Modulus Switching** (`zmod_quotient_surjective`, `lwe_modulus_switch`): When p ∣ q, the canonical map ZMod q → ZMod p is surjective, inducing an LWE instance reduction. Generalized to transitive modulus switching (`modulus_switch_transitive`). Boundary: switching to modulus 1 collapses all information.

3. **Error Rate Parameter Bounds** (`regev_alpha_lower_bound`): The Regev parameter condition implies α ≥ 2√n/q. Anti-monotonicity of approximation factor (`approx_factor_anti_monotone`): larger error → smaller γ → easier lattice problem. Scaling law (`approx_factor_scaling`). Boundary: divergence as α → 0⁺ (`approx_factor_diverges`).

4. **Information-Theoretic Sample Bounds** (`lwe_min_samples_bound`): With fewer than n samples, at least q consistent secrets exist. Monotonicity in samples (`lwe_secrets_monotone_samples`). Boundary: exactly n samples determine the secret (`lwe_exact_n_samples`).

5. **Dimension-Approximation Factor Tradeoff** (`approx_factor_ratio_invariance`, `dimension_doubling`): The approximation factor depends only on n/α; doubling both dimension and error preserves security. Boundary: α ≥ 1 implies γ ≤ n (`approx_factor_large_alpha`).

All proofs use only standard axioms (propext, Classical.choice, Quot.sound). The file includes 5 future directions as falsifiable conjectures.