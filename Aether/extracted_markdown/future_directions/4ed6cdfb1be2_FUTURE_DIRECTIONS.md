# Future Directions: LWE Hardness Reductions

## 1. Formal Verification of the Full Regev Quantum Reduction

The current formalization captures the algebraic and analytic *ingredients* of the LWE search-to-decision reduction — affine bijections over Z_p, noise accumulation bounds, rounding correctness, and the pigeonhole advantage decomposition. The natural next step is to close the loop by formalizing the **quantum reduction from GapSVP to LWE** itself, which requires modeling the quantum step where a BDD oracle is used to sample from a discrete Gaussian.

The key insight is that the quantum step can be decomposed into a classical "iterative rounding" procedure plus a single quantum Fourier sampling step. The iterative rounding is purely algebraic and amenable to formalization; the quantum sampling can be abstracted as an oracle satisfying a distributional specification (certified approximate discrete Gaussian). This decomposition avoids formalizing quantum circuits entirely.

Why now? The `ApproxDiscreteGaussian` structure in `RegevReduction/Theorems.lean` already provides the right abstraction for the quantum oracle, and the `ModuleReductionStep` framework can compose the classical reduction steps. The missing piece is the distributional analysis connecting the BDD oracle to Gaussian sampling — specifically, proving that the smoothing parameter η_ε(Λ) controls the quality of the resulting samples.

## 2. Ring-LWE and Module-LWE Search-to-Decision Reductions

The coordinate-by-coordinate search-to-decision strategy formalized here works for standard LWE but fails for structured variants. For **Ring-LWE** (Lyubashevsky-Peikert-Regev 2010), the reduction requires the algebraic structure of number fields — specifically, the Chinese Remainder Theorem for splitting R_q = Z_q[X]/(f(X)) when f splits modulo q.

The key insight is that the affine bijection `ZMod.affine_bijective` generalizes from Z_p to Z_p[X]/(f) when f is irreducible mod p, but the search-to-decision reduction uses the *splitting* structure rather than irreducibility. Formalizing this requires Mathlib's `Polynomial.Splits` and the CRT for polynomial quotients, both of which exist in Mathlib.

Why now? The `ZMod.sum_affine_eq` theorem (showing sums are invariant under affine rerandomization) is the template for the Ring-LWE analogue, where the sum runs over elements of R_q instead of Z_q. The module-level abstractions in `SearchDecision.lean` (e.g., `abstract_hybrid_telescope`) already handle the case of arbitrary finite indexing sets, so the hybrid argument infrastructure is ready.

## 3. Tightness of the Factor-n Loss in Search-to-Decision

The `search_to_decision_advantage_bound` theorem shows that the coordinate-by-coordinate reduction loses a factor of n in advantage. A natural question is whether this loss is **tight** — i.e., whether there exists an LWE instance where the best coordinate-by-coordinate strategy indeed loses exactly a factor of n.

The key insight is that tightness should follow from a **probabilistic construction**: for a uniformly random secret s, with high probability, all coordinates of s contribute roughly equally to the decision advantage. A formal proof would show that for the discrete Gaussian error distribution, the per-coordinate advantages concentrate around δ/n with deviation O(δ/n^{3/2}).

Why now? The pigeonhole argument in `search_to_decision_advantage_bound` is tight as a combinatorial statement (it just says "some coordinate has advantage ≥ δ/n"). The concentration argument would use the existing Gaussian tail bounds from `HardnessReduction.lean` combined with the Azuma-Hoeffding inequality, which exists in Mathlib as `measure_norm_le_of_martingale`.

## 4. Noise Flooding with Explicit Rényi Divergence Bounds

The current `NoiseFloodingLemma` (in `HardnessReduction.lean`) asserts that large Gaussian noise "floods" a bounded signal, making the sum statistically close to a pure Gaussian. A more precise and practically useful statement would give the bound in terms of **Rényi divergence** rather than statistical distance.

The key insight is that Rényi divergence of order α between D_{Z,s}(x + ·) and D_{Z,s} can be bounded as R_α ≤ exp(π α B²/s²) for |x| ≤ B. This multiplicative bound composes perfectly under independent sampling (R_α of products = product of R_α's), giving much tighter bounds for the multi-sample setting used in LWE encryption.

Why now? The `LeftoverHash.lean` module already formalizes collision probability (which is exp(R_2)), and the Cauchy-Schwarz bridge (`l1_le_sqrt_card_mul_l2`) connects ℓ² bounds to statistical distance. Extending this to Rényi divergence of general order requires only the Hölder inequality (available in Mathlib) and the explicit Gaussian moment computation.

## 5. Verified Parameter Selection for NIST Standards (Kyber/ML-KEM)

The theorems in this module can be instantiated with **concrete parameters** to verify the security claims of NIST post-quantum standards. For ML-KEM (formerly CRYSTALS-Kyber), the parameters are n=256, q=3329, k∈{2,3,4}, with centered binomial error distribution of parameter η∈{2,3}.

The key insight is that the `decryption_correct_after_switching` theorem, combined with the `noise_accumulation_subset_bound`, can produce a **verified bound on the decryption failure probability** for specific ML-KEM parameter sets. This requires: (1) computing the exact noise bound B for the centered binomial distribution (B = η), (2) computing the subset sum bound for k·n error terms, and (3) verifying B + nδ < q/4.

Why now? All the analytic machinery is in place: the rounding correctness (`regev_rounding_bit1`), noise accumulation (`noise_accumulation_bound`), and modulus switching (`combined_noise_after_switching`) theorems compose directly. The concrete computation can be done with `#eval` in Lean and verified with `native_decide` for the specific parameter choices. This would produce the first machine-verified security proof for a NIST post-quantum standard.
