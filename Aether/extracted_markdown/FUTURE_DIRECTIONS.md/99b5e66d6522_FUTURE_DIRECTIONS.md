# Future Directions: BB84 QKD Security Formalization

## 1. Continuous Monotonicity and Exact QBER Threshold Computation

The current formalization proves existence of a QBER threshold Q* via the intermediate value theorem but does not pin down its exact value. A natural next step is to prove that binEntropy₂ is strictly increasing on [0, 1/2] and strictly decreasing on [1/2, 1], which would give uniqueness of Q*. Combined with numerical bounds on log, one could prove 0.110 < Q* < 0.111, formalizing the well-known ≈11% threshold.

The key insight is that strict monotonicity of h₂ on [0, 1/2] follows from the strict concavity of binEntropy, which in turn follows from the strict convexity of x ↦ x log x (whose second derivative is 1/x > 0).

Why now? Mathlib already has `Real.binEntropy_nonneg` and `Real.binEntropy_le_log_two`. The concavity/convexity infrastructure for `Real.log` is well-developed (`Real.strictConvexOn_mul_log`), so the strict monotonicity proof is within reach.

## 2. Finite-Key Security Bounds

The current key rate theorem is asymptotic: r = 1 - 2h₂(Q) applies in the limit n → ∞. Real implementations use finite key lengths, where the key rate must account for statistical fluctuations in parameter estimation. The finite-key formula involves tail bounds (Serfling's inequality or Azuma-Hoeffding) and produces a key rate r_n ≈ 1 - 2h₂(Q + δ(n)) - O(1/√n) where δ(n) is the statistical confidence interval.

The key insight is that formalizing the finite-key correction separates into three independent components: (1) a concentration inequality for hypergeometric sampling, (2) the smooth min-entropy chain rule, and (3) the finite-size privacy amplification bound. Each is a self-contained mathematical result.

Why now? Mathlib has strong measure-theoretic probability foundations and many concentration inequalities. The modular structure means each component can be formalized independently and composed.

## 3. Entanglement-Based QKD and the CSS Code Reduction

The Shor-Preskill proof reduces BB84 security to the security of an entanglement-based protocol via CSS (Calderbank-Shor-Steane) error-correcting codes. Formalizing this reduction would connect our information-theoretic results to the quantum-mechanical security guarantee. The reduction shows that if a CSS code can correct t errors, then BB84 with QBER ≤ t/n is secure.

The key insight is that the CSS code reduction is primarily algebraic (over GF(2)) rather than quantum-mechanical. The quantum part reduces to the statement that measuring in conjugate bases commutes with CSS encoding — which can be stated as a linear-algebraic fact over F₂.

Why now? Mathlib has extensive support for linear algebra over finite fields (`ZMod 2`), making the algebraic core of the CSS reduction formalizable without quantum mechanics infrastructure.

## 4. Composable Security and the Universal Composability Framework

Our current security definition is stand-alone: it bounds Eve's information about a single key. Modern QKD security proofs use the universal composability (UC) framework, where security means the real protocol is indistinguishable from an ideal key-generation functionality. The composable security bound involves trace distance between quantum states, generalizing our classical statistical distance.

The key insight is that composable security follows from the stand-alone bound plus a "lifting lemma" showing that statistical distance in the classical post-processing is preserved under composition. This lifting lemma is a purely classical result about statistical distance and can be formalized using our `statDistance_triangle`.

Why now? The `statDistance` metric space structure we formalized provides the foundation. The lifting lemma is a direct consequence of the triangle inequality and data processing inequality for statistical distance.

## 5. Privacy Amplification Against Quantum Adversaries

Our privacy amplification result treats the security parameter classically. Against quantum adversaries, the leftover hash lemma requires quantum min-entropy (conditional on Eve's quantum side information). The quantum leftover hash lemma states: if ρ_AE has conditional min-entropy H_min(A|E) ≥ k, then hashing A to l bits leaves Eve with trace distance ≤ 2^{-(k-l)/2} from uniform.

The key insight is that the quantum leftover hash lemma's proof reduces to a bound on the operator norm of ρ_AE, which can be stated as: Tr(ρ_AE²) ≤ 2^{-k}. This "collision entropy" characterization is a finite-dimensional matrix inequality that could be formalized using Mathlib's matrix analysis.

Why now? Mathlib's `Matrix` library includes trace, operator norms, and positive semidefiniteness. The key inequality is a consequence of the Cauchy-Schwarz inequality for the Hilbert-Schmidt inner product, which is available in Mathlib.
