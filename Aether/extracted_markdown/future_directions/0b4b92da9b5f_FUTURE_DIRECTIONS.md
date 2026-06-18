# Future Directions: BSD Formal Verification Program

## Hypothesis 1: Low-Rank BSD Numerical Verification at 50-Digit Precision

**Conjecture.** For at least 99% of elliptic curves E/ℚ with conductor N ≤ 10⁶ and analytic rank 0 or 1, the BSD leading-term formula can be numerically verified to 50 decimal digits:

|L*(E,1) / bsdAlgebraicSide(E) − 1| < 10⁻⁵⁰

**Test.** Populate `BSDData` from LMFDB invariants for all rank-0 and rank-1 curves with conductor ≤ 10⁶. Use the formally verified `bsdAlgebraicSide_pos` theorem to certify the denominator is positive before computing the ratio. Compute L*(E,1) via interval arithmetic (using e.g. Arb or FLINT) to 60 digits of precision. Report any curve where the ratio deviates from 1 by more than 10⁻⁵⁰.

**Refutation criterion.** Finding even one curve in this range where the deviation exceeds 10⁻⁵⁰ would either (a) falsify the precision claim, (b) indicate a data or import inconsistency, or (c) reveal that |Sha| is not what LMFDB reports.

**Impact.** This would constitute the first systematic validation of the formal BSD contract against real arithmetic data with a theorem-certified denominator and canonical local factor semantics.

---

## Hypothesis 2: Sato-Tate KS Convergence Rate for Non-CM Curves

**Conjecture.** For any non-CM elliptic curve E/ℚ, if θ_p ∈ [0,π] is defined by a_p = 2√p cos(θ_p), then for the first N good primes, the Kolmogorov-Smirnov statistic against the Sato-Tate measure satisfies D_N = O(N⁻⁰·⁴⁹). Concretely, for N = 10⁶, one has D_N < 0.002 for all non-CM curves in LMFDB with conductor ≤ 10⁵.

**Test.** For each non-CM curve in the LMFDB database with conductor ≤ 10⁵:
1. Compute a_p for the first 10⁶ good primes using the formally verified trace pipeline (`local_euler_factor_ext_of_trace` guarantees canonicality).
2. Derive θ_p = arccos(a_p / 2√p).
3. Compute the KS statistic against the Sato-Tate CDF.
4. Fit the exponent on a log-log plot of D_N vs N.

**Refutation criterion.** A slope outside [-0.53, -0.45] in the log-log fit, or D_N ≥ 0.002 at N = 10⁶ for any non-CM curve, refutes the stated rate law.

**Impact.** This informs whether future formal L-function layers should encode explicit coefficient-distribution error terms and calibrates expectations for certified Sato-Tate verification.

---

## Hypothesis 3: Regulator Growth and Height Pairing Condition Number

**Conjecture.** For elliptic curves E/ℚ of Mordell-Weil rank r ≤ 3 and conductor N ≤ 10⁶, there exist constants C, k > 0 such that Reg(E) ≤ C(log N)^k for at least 95% of curves in each fixed rank stratum. Moreover, for all such curves with explicitly computed generators, the height pairing matrix is positive definite with condition number below 10⁸.

**Test.** For curves with rank 1, 2, and 3 in the LMFDB database with conductor ≤ 10⁶:
1. Use the formally verified `regulator_pos_of_posDef` theorem to certify that the height pairing matrix is positive definite.
2. Compute the regulator (= det of the Gram matrix).
3. Fit regulator growth against log N for each rank stratum.
4. Record the condition number of every height pairing matrix.

**Refutation criterion.** If more than 5% of curves in any rank stratum have Reg(E) > C(log N)^k for all reasonable C, k, or if any certified height matrix has condition number ≥ 10⁸, the hypothesis is refuted.

**Impact.** This calibrates the expected scale of the regulator term in formal BSD verification and indicates whether average-case certification strategies are feasible.

---

## Hypothesis 4: Tamagawa Product Growth and Bad Reduction Density

**Conjecture.** For elliptic curves E/ℚ with conductor N ≤ 10⁶, the Tamagawa product ∏ c_p satisfies ∏ c_p ≤ N^ε for any fixed ε > 0 and sufficiently large N. More precisely, for 99% of curves with conductor ≤ 10⁶, one has ∏ c_p ≤ N^{0.1}.

**Test.** For all curves in the LMFDB database with conductor ≤ 10⁶:
1. Use the formally verified `finset_prod_pos_of_pos` to certify that ∏ c_p > 0.
2. Use `tamagawa_product_invariant` to verify database consistency (different presentations of bad prime data give the same product).
3. Compute ∏ c_p / N^{0.1} and check it is ≤ 1 for 99% of curves.

**Refutation criterion.** More than 1% of curves with ∏ c_p > N^{0.1} refutes the claim.

**Impact.** Bounds on Tamagawa products are essential for estimating the size of the BSD algebraic side and for calibrating interval arithmetic precision requirements in formal BSD verification.

---

## Hypothesis 5: Formal BSD Pipeline Completeness for Rank ≤ 1

**Conjecture.** The formal BSD scaffold (Definitions + LocalEulerExt + Positivity + RegulatorPosDef + ProductCoherence) is sufficient to state and verify, in a machine-checked setting, the BSD leading-term formula for any rank-0 or rank-1 elliptic curve over ℚ, given:
- a certified point count at each good prime (providing Euler factors via `local_euler_factor_ext_of_trace`),
- a certified height pairing matrix (providing the regulator via `regulator_pos_of_posDef`),
- certified values of |Sha|, ∏ c_p, |E_tors|,
- and a certified computation of L*(E,1) to sufficient precision.

**Test.** Select 10 well-known rank-0 and rank-1 curves. For each:
1. Instantiate `BSDData` with LMFDB values.
2. Prove `bsdAlgebraicSide_pos` from the instantiated data.
3. Provide a certified computation of L*(E,1) (via Arb/FLINT interval arithmetic).
4. Verify |L*(E,1) / bsdAlgebraicSide(E) − 1| < 10⁻³⁰ as a machine-checked inequality.

**Refutation criterion.** If any of the four steps fails to produce a machine-checked certificate, the pipeline has a gap that must be filled.

**Impact.** This would demonstrate that the formal BSD scaffold is not merely a passive record structure but an active theorem-producing interface capable of certifying real arithmetic data.
