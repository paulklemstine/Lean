# Future Directions: BB84 QKD Security Formalization

## Synthesis

This cycle established the foundational information-theoretic framework for BB84 QKD security in Lean 4. We formalized the binary entropy function in bits (`binEntropyBits = binEntropy / log 2`), the BB84 key rate (`keyRate Q = 1 - 2 H₂(Q)`), and proved existence/uniqueness of the QBER threshold Q* via the intermediate value theorem combined with strict monotonicity of binary entropy. The key structural insight is that Mathlib's `binEntropy` infrastructure—including strict monotonicity on [0, 1/2], strict concavity on [0, 1], and continuity—makes IVT-based threshold arguments entirely mechanical once the conversion to bits is set up correctly.

We also formalized statistical distance as a pseudometric on finite probability distributions, proving nonnegativity, symmetry, and the triangle inequality. These three properties establish the metric space structure needed for privacy amplification bounds. The triangle inequality proof is elementary (absolute value triangle inequality summed pointwise) but forms the critical foundation for composable security arguments.

The main limitation of this cycle is that the QBER threshold is proved to exist but its numerical value is not pinned down. We also lack the data processing inequality for statistical distance, which is essential for privacy amplification. Both are tractable next steps.

## Results Summary

- `QKD.qberThreshold_exists`: proved — There exists a unique Q* ∈ (0, 1/2) with H₂(Q*) = 1/2 (equivalently, keyRate(Q*) = 0), establishing the fundamental security boundary for BB84.
- `QKD.keyRate_strictAntiOn`: proved — The BB84 key rate is strictly decreasing on [0, 1/2], meaning higher QBER always yields lower key rate.
- `QKD.keyRate_pos_iff_below_threshold`: proved — The key rate is positive iff H₂(Q) < 1/2, giving an exact algebraic characterization of the secure operating regime.
- `QKD.statDistance_nonneg`: proved — Statistical distance is nonneg.
- `QKD.statDistance_symm`: proved — Statistical distance is symmetric.
- `QKD.statDistance_triangle`: proved — Statistical distance satisfies the triangle inequality, establishing pseudometric structure.

## Research Directions

### Direction 1: Numerical Bounds on Q* (the ≈11% threshold)
**Hypothesis**: The unique Q* satisfying binEntropyBits(Q*) = 1/2 lies in the interval (0.110, 0.111), i.e., `0.110 < Q* ∧ Q* < 0.111`.
**Test**: Compute `binEntropyBits(0.110)` and `binEntropyBits(0.111)` numerically and show they bracket 1/2. Then use strict monotonicity to conclude Q* lies between them. This requires verified bounds on `Real.log` at specific rational points.
**Why now**: We already have `qberThreshold_exists` and `binEntropyBits_strictMonoOn`. The remaining ingredient is numerical bounds on `log(0.110)`, `log(0.890)`, etc., which can be obtained from Mathlib's `Real.add_one_le_exp` and Taylor series bounds.
**If true**: Gives the first formally verified value of the BB84 security threshold, directly comparable to the textbook value Q* ≈ 11.0%.
**If false**: Would indicate an error in the standard QKD literature (extremely unlikely, but the formal verification would be valuable precisely for this reason).

### Direction 2: Data Processing Inequality for Statistical Distance
**Hypothesis**: For any deterministic function f and distributions p, q: `statDistance (p ∘ f⁻¹) (q ∘ f⁻¹) ≤ statDistance p q`, where the pushforward is defined via summing over preimages.
**Test**: Formalize the pushforward distribution and prove the inequality using the triangle inequality and the fact that partitioning the sum cannot increase total variation.
**Why now**: We have `statDistance_triangle` and the basic metric structure. The data processing inequality is a direct consequence of the convexity of absolute value applied to grouped sums.
**If true**: Enables the "lifting lemma" for composable security: classical post-processing cannot increase Eve's distinguishing advantage.
**If false**: Would indicate the formalization of pushforward is incorrect (the mathematical statement is a well-known theorem).

### Direction 3: Privacy Amplification via Universal Hashing
**Hypothesis**: If a random variable X has min-entropy at least k (i.e., max_x P(X=x) ≤ 2^{-k}), and H is a universal hash function mapping to {0,1}^l, then `statDistance (H(X), uniform) ≤ 2^{-(k-l)/2}`.
**Test**: Define min-entropy for finite distributions, define universal hash families, and prove the leftover hash lemma. The proof uses Markov's inequality applied to the collision probability.
**Why now**: Our `statDistance` infrastructure provides the target metric. The proof reduces to bounding `∑_y (∑_{x: H(x)=y} p(x))²` using the universal hash property, which is algebraic.
**If true**: Completes the classical privacy amplification step of BB84 security, connecting min-entropy to composable key security.
**If false**: Would indicate the min-entropy condition is insufficient (contradicting well-established information theory).

### Direction 4: Finite-Key Corrections via Concentration Inequalities
**Hypothesis**: For n-bit key generation with parameter estimation on m samples, the effective QBER confidence interval satisfies `Q_est - Q_true ≤ √(ln(1/ε) / (2m))` with probability at least 1-ε (Hoeffding bound).
**Test**: Apply Mathlib's Hoeffding inequality (if available) or formalize it for Bernoulli random variables. Combine with the key rate formula to get `r_n ≈ 1 - 2 H₂(Q + δ(n))`.
**Why now**: The asymptotic key rate is now formalized. The finite-key correction is an additive perturbation that composes cleanly with `keyRate_strictAntiOn`.
**If true**: Gives the first formally verified finite-key security bound for BB84.
**If false**: Would indicate the concentration inequality is too loose for practical key lengths (possible but would still yield a valid, if weak, bound).

### Direction 5: CSS Code Reduction (Shor-Preskill)
**Hypothesis**: The security of BB84 reduces to the error-correcting capability of CSS codes over GF(2). Specifically: if a CSS code with parameters [n, k, d] exists, then BB84 is secure for QBER ≤ (d-1)/(2n).
**Test**: Define CSS codes as pairs of linear codes C₁ ⊆ C₂ over ZMod 2, define the error-correcting radius, and prove the reduction assuming the quantum measurement commutation lemma as an axiom (since full quantum mechanics is out of scope).
**Why now**: Mathlib has extensive `ZMod 2` linear algebra. The algebraic core of CSS codes (dual code containment, syndrome decoding) is formalizable without quantum mechanics.
**If true**: Connects our information-theoretic results to the quantum-mechanical security guarantee, completing the BB84 security proof modulo one quantum axiom.
**If false**: Would indicate the CSS code parameters are insufficient (unlikely, as this is the standard Shor-Preskill argument).
