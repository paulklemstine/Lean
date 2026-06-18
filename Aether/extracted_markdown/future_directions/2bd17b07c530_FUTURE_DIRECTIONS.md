# Future Directions: BSD Formalization Program

This document outlines 5 testable scientific hypotheses emerging from the formal BSD scaffold. Each is falsifiable with a clear computational or formal test.

---

### Direction 1: Low-Rank Mordell–Weil Growth from Local Trace Statistics

**Conjecture.** For elliptic curves E/ℚ of conductor N ≤ 10⁶ with analytic rank 0, the distribution of normalized Frobenius traces aₚ/√p over good primes p ≤ X converges to the Sato–Tate distribution faster (in Kolmogorov–Smirnov distance) than for curves of analytic rank ≥ 2, with a quantitative gap of at least O(1/log X).

**Test.** Compute the Kolmogorov–Smirnov statistic D_X between the empirical trace distribution and the semicircular (Sato–Tate) density for all curves in the LMFDB with conductor ≤ 10⁶, stratified by analytic rank. Compare convergence rates across rank strata. A clear rank-dependent gap would confirm; identical convergence rates would refute.

**Why it matters.** If true, this would provide a computational criterion for predicting analytic rank from finite local data, creating a bridge between the local Euler factor formalization and the global rank statement in BSD. It would also connect the `LocalEulerData` interface to statistical inference about Mordell–Weil rank.

---

### Direction 2: Euler Factor Product Convergence and BSD Quotient Stability

**Conjecture.** For any elliptic curve E/ℚ with analytic rank 0, the partial BSD quotient
  Q(X) = Ω · Reg · |Ш| · ∏_{p ≤ X} cₚ / |E(ℚ)_tors|²
converges to L(E,1) monotonically from below when the partial Euler product ∏_{p ≤ X} (1 - aₚp⁻¹ + p⁻¹)⁻¹ is used. More precisely, the ratio Q(X)/L(E,1) is increasing in X for X beyond the conductor.

**Test.** For 100 rank-0 curves from the LMFDB, compute Q(X) for X = 10², 10³, 10⁴, 10⁵ using verified Tamagawa numbers and known |Ш|. Plot Q(X)/L(E,1) vs. X. Monotonicity would confirm; oscillation would refute.

**Why it matters.** Monotone convergence would enable certified numerical BSD verification: one could formally bound L(E,1) from below using finitely many primes, turning the `BSDLeadingTermStatement` into a finitely verifiable certificate. This connects the `localEulerPoly_at_inv` bridge theorem to global BSD verification.

---

### Direction 3: Regulator Nondegeneracy from Height Pairing Spectral Gaps

**Conjecture.** For elliptic curves E/ℚ of Mordell–Weil rank r ≥ 2, the smallest eigenvalue λ_min of the Néron–Tate height pairing Gram matrix (with respect to any Mordell–Weil basis) satisfies λ_min ≥ c · log(N)⁻ᵟ for universal constants c > 0 and δ > 0, where N is the conductor.

**Test.** For all rank-2 and rank-3 curves in the LMFDB (approximately 2000 curves), compute the Néron–Tate height pairing matrix using known Mordell–Weil generators, extract its eigenvalues, and fit the minimum eigenvalue against log(N). A power-law lower bound would confirm; curves with exponentially small eigenvalues (relative to conductor) would refute.

**Why it matters.** This would formalize the intuition that regulators don't degenerate pathologically, making the `gramDet_nonneg` and `gramDet_one_nonneg` results of the Regulator module the first steps toward quantitative regulator bounds. If true, it would reduce BSD verification to bounding |Ш|, since the regulator would be controlled.

---

### Direction 4: Information-Theoretic Complexity of Local-to-Global BSD Data

**Conjecture.** The Kolmogorov complexity K(B) of the BSD data (Reg, |Ш|, ∏cₚ, |E_tors|) for an elliptic curve E/ℚ of conductor N is bounded by K(B) ≤ C · log(N)² for a universal constant C, and the BSD quotient L*(E,1) can be reconstructed from O(log(N)²) bits of local data with bounded error.

**Test.** For 500 curves from the LMFDB, compute the bit-lengths of each BSD invariant (using exact rational arithmetic for the regulator, verified orders for Ш and torsion). Fit total bit-length against log(N)². A quadratic bound would confirm; superpolynomial growth would refute.

**Why it matters.** This connects BSD to algorithmic information theory and suggests that the BSD formula is an efficient compression of arithmetic complexity. It would motivate formal interfaces between `BSDData` and computational complexity classes, potentially leading to polynomial-time BSD verification algorithms for specific curve families.

---

### Direction 5: Isogeny Class Size and BSD Quotient Variance

**Conjecture.** Within an isogeny class of elliptic curves over ℚ, the individual BSD factors (Ω, Reg, |Ш|, ∏cₚ, |E_tors|) can vary by factors up to the isogeny degree, but the BSD quotient Ω·Reg·|Ш|·∏cₚ/|E_tors|² is invariant. More precisely, for any isogeny φ: E → E' of degree d, the ratios Ω_E/Ω_{E'}, Reg_E/Reg_{E'}, etc., are all bounded by d, while their product in the BSD quotient is exactly 1.

**Test.** For all isogeny classes in the LMFDB with class size ≥ 3 and conductor ≤ 10⁵, compute each BSD factor for every curve in the class. Verify:
  (a) the BSD quotient is identical across the class (to machine precision),
  (b) individual factor ratios are bounded by the maximal isogeny degree in the class.
Exact invariance of (a) is the `bsd_isogeny_invariant` theorem incarnated numerically. Violation of (b) would suggest previously unknown cancellation phenomena.

**Why it matters.** This directly tests the `IsogenyBSDRel` and `bsd_isogeny_invariant` formalization against real arithmetic data. Numerical confirmation would validate the abstract scaffold; unexpected factor ratios would reveal structure beyond the standard isogeny transformation laws and could lead to new conjectures about Tamagawa number behavior under isogeny.
