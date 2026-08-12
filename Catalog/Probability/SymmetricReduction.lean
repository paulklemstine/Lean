/-
# Symmetric Reduction in Arbitrary Degree (Factoring Lab, Phase A v19c — cycle 2)

The general-degree mechanism behind the multiplicative dichotomy.

`Catalog/Probability/QuadraticDichotomy.lean` proves the dichotomy for
`F(r) = a r² + b r + c` by an explicit expansion of `F(p)F(q)` in the
elementary symmetric functions `s = p + q` and `N = pq`.  That expansion is not
an accident of degree `2`: for **every** `F ∈ ℤ[X]`, reduction modulo the
minimal polynomial `(X − p)(X − q) = X² − sX + N` of the factor pair replaces
`F` by its degree-`≤ 1` remainder `B X + A`, and then

`F(p) = B p + A`,  `F(q) = B q + A`,  `F(p) F(q) = A² + A B s + B² N`.

So the value of *any* polynomial multiplicative invariant on a semiprime is the
same universal quadratic form `A² + A B s + B² N` in the symmetric data; the
degree of `F` only affects how `A` and `B` are computed.  The results are:

* `FactoringLab.symmetric_reduction_identity` — the identity above, for
  arbitrary `F` and arbitrary integers `p`, `q`;
* `FactoringLab.reduction_slope_eq_zero_iff` — the reduction slope `B` vanishes
  exactly when `F` fails to separate the two factors, `F(p) = F(q)`; this is
  the general form of the degenerate ("`N`-only") side of the dichotomy;
* `FactoringLab.symmetric_reduction_of_slope_zero` — in that case the invariant
  collapses to the perfect square `A²`;
* `FactoringLab.symmetric_reduction_determines_sum` — when `B ≠ 0` the sum
  `s = p + q` is recovered from `(N, T)` and the reduction data by a single
  division, and hence, via `FactoringLab.recovery_from_sum`, so is the
  factorization.

What is *not* claimed: `A` and `B` are here computed from `p` and `q`, not from
`N` alone.  Turning the identity into a genuine algorithmic dichotomy for every
degree requires tracking `A` and `B` as polynomials in `(N, s)`; that step is
recorded as a next-cycle sub-conjecture in `FUTURE_DIRECTIONS.md`, and is
carried out explicitly for degree `≤ 2` in `QuadraticDichotomy.lean`.
-/
import Mathlib
import Probability.QuadraticDichotomy

open Polynomial

namespace FactoringLab

/-- The minimal polynomial of the factor pair: `(X − p)(X − q) = X² − sX + N`. -/
noncomputable def pairPoly (p q : ℤ) : Polynomial ℤ := (X - C p) * (X - C q)

theorem pairPoly_monic (p q : ℤ) : (pairPoly p q).Monic :=
  (monic_X_sub_C p).mul (monic_X_sub_C q)

theorem pairPoly_degree (p q : ℤ) : (pairPoly p q).degree = 2 := by
  unfold pairPoly
  rw [degree_mul, degree_X_sub_C, degree_X_sub_C]
  rfl

theorem pairPoly_eval_left (p q : ℤ) : (pairPoly p q).eval p = 0 := by
  simp [pairPoly]

theorem pairPoly_eval_right (p q : ℤ) : (pairPoly p q).eval q = 0 := by
  simp [pairPoly]

/-- The remainder of `F` modulo the pair polynomial is affine: `B X + A`. -/
theorem modByMonic_pairPoly_eq (F : Polynomial ℤ) (p q : ℤ) :
    F %ₘ pairPoly p q
      = C ((F %ₘ pairPoly p q).coeff 1) * X + C ((F %ₘ pairPoly p q).coeff 0) := by
  refine eq_X_add_C_of_degree_le_one ?_
  have hlt : (F %ₘ pairPoly p q).degree < (pairPoly p q).degree :=
    degree_modByMonic_lt F (pairPoly_monic p q)
  rw [pairPoly_degree] at hlt
  exact Order.le_of_lt_succ hlt

/-- **Symmetric reduction identity (arbitrary degree).**  Writing
`B X + A` for the remainder of `F` modulo `(X − p)(X − q)`, the values of `F`
at the two factors are the affine values `B p + A` and `B q + A`, and their
product — the multiplicative invariant at the semiprime — is the universal
quadratic form `A² + A B (p + q) + B² (p q)` in the elementary symmetric
functions of the factor pair. -/
theorem symmetric_reduction_identity (F : Polynomial ℤ) (p q : ℤ) :
    let A := (F %ₘ pairPoly p q).coeff 0
    let B := (F %ₘ pairPoly p q).coeff 1
    F.eval p = B * p + A ∧ F.eval q = B * q + A ∧
      F.eval p * F.eval q = A ^ 2 + A * B * (p + q) + B ^ 2 * (p * q) := by
  intro A B
  have hdecomp : F %ₘ pairPoly p q + pairPoly p q * (F /ₘ pairPoly p q) = F :=
    modByMonic_add_div F (pairPoly_monic p q)
  have hrem : F %ₘ pairPoly p q = C B * X + C A := modByMonic_pairPoly_eq F p q
  have hp : F.eval p = B * p + A := by
    conv_lhs => rw [← hdecomp]
    rw [eval_add, eval_mul, pairPoly_eval_left, zero_mul, add_zero, hrem]
    simp
  have hq : F.eval q = B * q + A := by
    conv_lhs => rw [← hdecomp]
    rw [eval_add, eval_mul, pairPoly_eval_right, zero_mul, add_zero, hrem]
    simp
  refine ⟨hp, hq, ?_⟩
  rw [hp, hq]; ring

/-- The reduction slope vanishes exactly when the invariant fails to separate
the two prime factors. -/
theorem reduction_slope_eq_zero_iff (F : Polynomial ℤ) {p q : ℤ} (hpq : p ≠ q) :
    (F %ₘ pairPoly p q).coeff 1 = 0 ↔ F.eval p = F.eval q := by
  obtain ⟨hp, hq, -⟩ := symmetric_reduction_identity F p q
  constructor
  · intro h
    rw [hp, hq, h]
    ring
  · intro h
    rw [hp, hq] at h
    have hsub : (F %ₘ pairPoly p q).coeff 1 * (p - q) = 0 := by linarith
    rcases mul_eq_zero.1 hsub with h1 | h2
    · exact h1
    · exact absurd (sub_eq_zero.1 h2) hpq

/-- Degenerate side, arbitrary degree: a vanishing reduction slope collapses the
invariant to the perfect square `A²`, the same value at both factors. -/
theorem symmetric_reduction_of_slope_zero (F : Polynomial ℤ) (p q : ℤ)
    (hB : (F %ₘ pairPoly p q).coeff 1 = 0) :
    F.eval p * F.eval q = ((F %ₘ pairPoly p q).coeff 0) ^ 2 := by
  obtain ⟨-, -, hprod⟩ := symmetric_reduction_identity F p q
  rw [hprod, hB]
  ring

/-- Recovery side, arbitrary degree: a nonzero reduction slope makes the sum
`p + q` an explicit quotient of the invariant value by the reduction data, and
therefore — through `recovery_from_sum` — yields the factorization in closed
form. -/
theorem symmetric_reduction_determines_sum (F : Polynomial ℤ) {p q : ℤ} (hpq : p ≤ q)
    (hA : (F %ₘ pairPoly p q).coeff 0 ≠ 0)
    (hB : (F %ₘ pairPoly p q).coeff 1 ≠ 0) :
    let A := (F %ₘ pairPoly p q).coeff 0
    let B := (F %ₘ pairPoly p q).coeff 1
    let N := p * q
    let T := F.eval p * F.eval q
    let s := (T - A ^ 2 - B ^ 2 * N) / (A * B)
    s = p + q ∧
      (s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = p ∧
      (s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = q := by
  intro A B N T s
  obtain ⟨-, -, hprod⟩ := symmetric_reduction_identity F p q
  have hAB : A * B ≠ 0 := mul_ne_zero hA hB
  have hs : s = p + q := by
    have hnum : T - A ^ 2 - B ^ 2 * N = A * B * (p + q) := by
      simp only [T, N]
      rw [hprod]
      ring
    simp only [s, hnum]
    exact Int.mul_ediv_cancel_left _ hAB
  obtain ⟨-, h1, h2⟩ := recovery_from_sum hpq (rfl : N = p * q) hs
  exact ⟨hs, h1, h2⟩

/-- Consistency with the degree-`2` computation: for `F = aX² + bX + c` the
reduction slope and constant are `a s + b` and `c − a N`, so the general
identity specializes to the explicit quadratic expansion used in
`QuadraticDichotomy.lean`. -/
theorem symmetric_reduction_quadratic (a b c p q : ℤ) :
    let F : Polynomial ℤ := C a * X ^ 2 + C b * X + C c
    F.eval p * F.eval q
      = a * c * (p + q) ^ 2 + (a * b * (p * q) + b * c) * (p + q)
        + (a ^ 2 * (p * q) ^ 2 + (b ^ 2 - 2 * (a * c)) * (p * q) + c ^ 2) := by
  intro F
  have hp : F.eval p = a * p ^ 2 + b * p + c := by simp [F]
  have hq : F.eval q = a * q ^ 2 + b * q + c := by simp [F]
  rw [hp, hq]
  exact quadratic_invariant_identity a b c p q

end FactoringLab