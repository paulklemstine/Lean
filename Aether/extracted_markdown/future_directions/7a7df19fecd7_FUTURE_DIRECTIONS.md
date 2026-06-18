# Future Directions: The BSD Formal Verification Program

This document identifies falsifiable conjectures and testable hypotheses emerging from our formal BSD scaffold. Each direction is designed to advance the machine-checked arithmetic geometry program.

---

### Direction 1: Low-Rank Curve Density and BSD Verification Coverage

**Conjecture.** For at least 99% of elliptic curves E/ℚ with conductor N ≤ 10⁶ and analytic rank 0 or 1, the BSD leading-term formula can be numerically verified to 50 decimal digits using the formal `BSDData` interface — specifically, the ratio `L*(E,1) / bsdAlgebraicSide(E)` equals 1.0000... to that precision.

**Test.** Using databases such as the LMFDB, extract the BSD invariants (regulator, |Sha|, Tamagawa numbers, torsion order, real period, leading coefficient) for all curves with conductor ≤ 10⁶ and analytic rank ≤ 1. Populate `BSDData` structures and compute the ratio. Flag any curve where the ratio deviates from 1 by more than 10⁻⁵⁰. A single such curve would refute the conjecture (or indicate a computational error).

**Why it matters.** This would be the first systematic computational validation of the formal BSD interface against real-world data. It bridges the abstract scaffold to concrete arithmetic geometry and establishes the `BSDData` structure as a reliable computational contract for future verified proofs.

---

### Direction 2: Frobenius Trace Distribution and Sato–Tate Convergence Rates

**Conjecture.** For a non-CM elliptic curve E/ℚ, the normalized Frobenius traces θ_p (where a_p = 2√p cos θ_p) converge to the Sato–Tate distribution sin²θ with Kolmogorov–Smirnov statistic D_N = O(N⁻⁰·⁴⁹) when computed over the first N good primes. Specifically, for N = 10⁶ primes, D_N < 0.002 for all curves in the LMFDB with conductor ≤ 10⁵.

**Test.** For each curve, compute the Frobenius traces a_p for primes p ≤ the N-th prime (N = 10⁶), normalize to get θ_p, and compute the KS statistic against the Sato–Tate density. Plot D_N vs. N on a log-log scale. The conjecture predicts slope approximately −0.49. A slope significantly different (say < −0.45 or > −0.53) would refute the specific rate. The formal `LocalEulerData` structure and `frobenius_trace_unique_value` theorem provide a verified pipeline for extracting a_p from point-count data.

**Why it matters.** The rate of convergence to Sato–Tate is not fully understood. Precise computational evidence would inform whether the formal local Euler factor package needs to incorporate error-term bounds, and would guide the design of formal analytic number theory interfaces for L-function coefficient distributions.

---

### Direction 3: Regulator Growth and Height Pairing Nondegeneracy

**Conjecture.** For elliptic curves E/ℚ of Mordell–Weil rank r ≥ 2, the regulator R(E) satisfies R(E) ≥ c · (log N_E)^{−r(r−1)/2} for a universal constant c > 0, where N_E is the conductor. In particular, regulators do not degenerate faster than a polynomial function of log-conductor.

**Test.** Compute regulators for all rank-2 and rank-3 curves in the LMFDB with conductor ≤ 10⁸. Plot log R(E) against log log N_E. The conjecture predicts a lower bound with slope ≥ −r(r−1)/2. Finding a family of curves where log R(E) / log log N_E → −∞ would refute it. The formal `bsd_algebraic_side_scale_regulator` theorem shows that regulator scaling propagates cleanly through the BSD formula, so any lower bound on R(E) directly constrains the leading coefficient.

**Why it matters.** Nondegeneracy of the Néron–Tate height pairing is a crucial input for BSD in higher rank. Our formal regulator interface (the scaling lemma and rank-zero simplification) is designed to accommodate such bounds. A verified lower bound would be the first step toward formalizing the regulator factor in the BSD formula for rank ≥ 2 curves.

---

### Direction 4: Arithmetic Complexity of BSD Quotients and Information-Theoretic Bounds

**Conjecture.** The bit complexity of the BSD quotient Q(E) = Ω·R·|Sha|·∏c_p / |E(ℚ)_tors|² for an elliptic curve E/ℚ of conductor N grows as O(N^ε) for any ε > 0 — that is, the numerator and denominator of Q(E) (as a rational number, when all terms are rational or algebraic) have numerator and denominator bounded by exp(N^ε). More precisely: for rank-0 curves, the numerator of L(E,1)/Ω (a rational number by Manin's theorem) has height bounded by O(log N)².

**Test.** For rank-0 curves with conductor N ≤ 10⁵, compute the exact rational value L(E,1)/Ω and measure the bit-length of its numerator and denominator. Plot against log N. The conjecture predicts the bit-length grows at most quadratically in log N. A superpolynomial growth family would refute the conjecture. This connects the formal `bsd_rhs_positive` theorem (which guarantees positivity) to the quantitative question of how large the BSD quotient can be.

**Why it matters.** This connects BSD to computational complexity theory. If the BSD quotient has controlled arithmetic complexity, then verified numerical BSD checks can be performed in polynomial time in the conductor. This would make large-scale formal BSD verification feasible and connects arithmetic geometry to complexity-theoretic questions about the hardness of computing L-values.

---

### Direction 5: Isogeny Class Uniformity of BSD Verification Error

**Conjecture.** Within an isogeny class of elliptic curves over ℚ, the numerical BSD verification error (the deviation of the computed ratio L*(E,1)/bsdAlgebraicSide(E) from 1) is identical to machine precision — that is, isogenous curves produce bit-identical BSD ratios when computed with the same precision arithmetic.

**Test.** For each isogeny class in the LMFDB with conductor ≤ 10⁵, compute the BSD ratio for all curves in the class to 100 decimal digits. Compare the ratios pairwise within each class. The conjecture predicts exact agreement. Any discrepancy, even in the last digit, would indicate either a computational error or a subtle failure of our formal `IsogenyBSDRel` abstraction (which requires `quotient_eq` and `leading_eq`). The formal theorem `bsd_isogeny_invariant` guarantees that if one curve in the class satisfies BSD, all do — this test verifies the numerical counterpart.

**Why it matters.** This is a direct computational test of the isogeny invariance principle formalized in our scaffold. It validates the `IsogenyBSDRel` structure against real data and would expose any gap between the abstract formal interface and the actual arithmetic behavior of isogenous curves. A positive result would strongly support the design of our formal BSD architecture.
