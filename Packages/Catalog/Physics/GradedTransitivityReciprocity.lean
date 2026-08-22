import Physics.GradedTransitivityResidue

/-!
# Reciprocity for transitivity partition functions

`Physics.GradedTransitivityResidue` computes the residue of the partition function
`Z(q) = ∑ₙ P(n) qⁿ` of a polynomial grade count at the "infinite-temperature" point `q = 1`
and finds the *zeta-regularised* value `−P(−1)`: the grade-counting polynomial evaluated at a
**negative** grade.  Why should a negative grade appear at all?

This file gives the structural answer, an **Ehrhart-style reciprocity law**.  The closed form
`polyZeta P` is a rational function, so it may be evaluated at `q⁻¹`, and the result is
exactly the generating function of the *negative* grades:

`polyZeta P q⁻¹ = − ∑_{n ≥ 1} P(−n) qⁿ`   (`polyZeta_reciprocity_neg`)

for `0 < ‖q‖ < 1`.  In particular the coefficient of `q¹` on the right is `−P(−1)`, the very
number that the contour integral at `q = 1` produces: the residue is not a coincidence of the
Newton expansion but the *first reflected grade*.

The proof runs through the binomial basis.  The key combinatorial input is the negative-argument
evaluation of the binomial polynomial,

`(−n−1 choose k) = (−1)^k · C(n+k, k)`   (`binomPoly_eval_neg_natCast_sub_one`),

whose generating function `∑ₙ C(n+k,k) qⁿ = (1−q)^{-(k+1)}` is precisely the reflection of
`∑ₙ C(n,k) qⁿ = qᵏ (1−q)^{-(k+1)}` used in the residue computation.  Gregory–Newton then
transports the identity from the basis to an arbitrary polynomial.

## Main results

* `Physics.GradedTransitivity.binomPoly_eval_neg_natCast_sub_one` — the negative-argument
  binomial identity.
* `Physics.GradedTransitivity.hasSum_reflected` — the reflected series `∑ₙ P(−n−1) qⁿ`
  converges to `∑ₖ Δᵏ P(0)·(−1)^k (1−q)^{-(k+1)}` on the unit disc.
* `Physics.GradedTransitivity.polyZeta_inv_eq` — the algebraic reflection formula for the
  rational function `polyZeta P` at `q⁻¹`.
* `Physics.GradedTransitivity.polyZeta_reciprocity`,
  `Physics.GradedTransitivity.polyZeta_reciprocity_neg` — the reciprocity law.
* `Physics.GradedTransitivity.polyZeta_inv_eq_comp` — the same statement with the reflected
  polynomial `P(−X−1)`, exhibiting reciprocity as an involution on grade counts.
* `Physics.GradedTransitivity.residue_eq_reflected_first_grade` — the residue `−P(−1)` of the
  partition function at `q = 1` *is* the first reflected grade.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology

/-! ### The binomial polynomial at negative arguments -/

/-- `descPochhammer` at `−n−1`: `(−n−1)(−n−2)⋯(−n−k) = (−1)^k · C(n+k,k) · k!`. -/
theorem descPochhammer_eval_neg_natCast_sub_one (k n : ℕ) :
    (descPochhammer ℂ k).eval (-(n : ℂ) - 1)
      = (-1 : ℂ) ^ k * ((n + k).choose k : ℂ) * ((Nat.factorial k : ℕ) : ℂ) := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hstep : ((n + k + 1) * ((n + k).choose k) : ℕ) = ((n + k + 1).choose (k + 1)) * (k + 1) :=
      Nat.add_one_mul_choose_eq (n + k) k
    have hstepC : ((n : ℂ) + k + 1) * (((n + k).choose k : ℕ) : ℂ)
        = (((n + k + 1).choose (k + 1) : ℕ) : ℂ) * ((k : ℂ) + 1) := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℂ)) hstep
    rw [descPochhammer_succ_right, eval_mul, eval_sub, eval_X, eval_natCast, ih]
    have hfac : ((Nat.factorial (k+1) : ℕ) : ℂ) = ((k : ℂ) + 1) * ((Nat.factorial k : ℕ) : ℂ) := by
      rw [Nat.factorial_succ]; push_cast; ring
    have hidx : n + (k + 1) = n + k + 1 := by omega
    rw [hidx, hfac]
    calc (-1 : ℂ) ^ k * (((n + k).choose k : ℕ) : ℂ) * ((Nat.factorial k : ℕ) : ℂ) * (-(n : ℂ) - 1 - (k : ℂ))
        = (-1) ^ k * ((Nat.factorial k : ℕ) : ℂ) * (-(((n : ℂ) + k + 1) * (((n + k).choose k : ℕ) : ℂ))) := by ring
      _ = (-1) ^ k * ((Nat.factorial k : ℕ) : ℂ) * (-((((n + k + 1).choose (k + 1) : ℕ) : ℂ) * ((k : ℂ) + 1))) := by
            rw [hstepC]
      _ = (-1) ^ (k + 1) * (((n + k + 1).choose (k + 1) : ℕ) : ℂ) * (((k : ℂ) + 1) * ((Nat.factorial k : ℕ) : ℂ)) := by
            ring

/-- **The negative-argument binomial identity**: `(−n−1 choose k) = (−1)^k · C(n+k, k)`. -/
theorem binomPoly_eval_neg_natCast_sub_one (k n : ℕ) :
    (binomPoly k).eval (-(n : ℂ) - 1) = (-1 : ℂ) ^ k * ((n + k).choose k : ℂ) := by
  have hk : ((Nat.factorial k : ℕ) : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero k)
  rw [binomPoly, eval_mul, eval_C, descPochhammer_eval_neg_natCast_sub_one]
  field_simp

/-- Gregory–Newton at a negative argument. -/
theorem eval_neg_natCast_sub_one (P : Polynomial ℂ) (n : ℕ) :
    P.eval (-(n : ℂ) - 1)
      = ∑ k ∈ range (P.natDegree + 1),
          newtonCoeff P k * ((-1 : ℂ) ^ k * ((n + k).choose k : ℂ)) := by
  conv_lhs => rw [newton_polynomial_eq P]
  simp only [eval_finset_sum, eval_mul, eval_C, binomPoly_eval_neg_natCast_sub_one]

/-! ### The reflected partition function -/

/-- The **reflected partition function** `∑ₙ P(−n−1) qⁿ`, in closed form.  Compare
`tsum_polyZeta`: reflection replaces the factor `qᵏ` by the sign `(−1)^k`. -/
theorem hasSum_reflected (P : Polynomial ℂ) {q : ℂ} (hq : ‖q‖ < 1) :
    HasSum (fun n : ℕ => P.eval (-(n : ℂ) - 1) * q ^ n)
      (∑ k ∈ range (P.natDegree + 1), newtonCoeff P k * ((-1 : ℂ) ^ k / (1 - q) ^ (k + 1))) := by
  have hterm : ∀ k ∈ range (P.natDegree + 1),
      HasSum (fun n : ℕ => newtonCoeff P k * ((-1 : ℂ) ^ k * ((n + k).choose k : ℂ)) * q ^ n)
        (newtonCoeff P k * ((-1 : ℂ) ^ k / (1 - q) ^ (k + 1))) := by
    intro k _
    have h0 := hasSum_choose_mul_geometric_of_norm_lt_one (𝕜 := ℂ) k hq
    have h1 := h0.mul_left (newtonCoeff P k * (-1 : ℂ) ^ k)
    have h2 : newtonCoeff P k * (-1 : ℂ) ^ k * (1 / (1 - q) ^ (k + 1))
        = newtonCoeff P k * ((-1 : ℂ) ^ k / (1 - q) ^ (k + 1)) := by
      rw [mul_assoc, one_div, ← div_eq_mul_inv]
    rw [← h2]
    refine h1.congr_fun ?_
    intro n
    ring
  have hsum := hasSum_sum hterm
  refine hsum.congr_fun ?_
  intro n
  rw [eval_neg_natCast_sub_one P n, Finset.sum_mul]

/-! ### Reciprocity -/

/-- The algebraic reflection formula: evaluating the rational function `polyZeta P` at `q⁻¹`
turns each Newton term `qᵏ/(1−q)^{k+1}` into `−q·(−1)^k/(1−q)^{k+1}`. -/
theorem polyZeta_inv_eq (P : Polynomial ℂ) {q : ℂ} (hq0 : q ≠ 0) (hq1 : q ≠ 1) :
    polyZeta P q⁻¹
      = -q * ∑ k ∈ range (P.natDegree + 1),
          newtonCoeff P k * ((-1 : ℂ) ^ k / (1 - q) ^ (k + 1)) := by
  have hqu : q - 1 ≠ 0 := sub_ne_zero.mpr hq1
  rw [polyZeta, Finset.mul_sum]
  refine Finset.sum_congr rfl fun k _ => ?_
  have hne : ((-1 : ℂ)) ^ k ≠ 0 := pow_ne_zero _ (by norm_num)
  have hkey : (q⁻¹) ^ k / (1 - q⁻¹) ^ (k + 1)
      = -q * ((-1 : ℂ) ^ k / (1 - q) ^ (k + 1)) := by
    have hs : (1 : ℂ) - q⁻¹ = (q - 1) / q := by field_simp
    have hL : (q⁻¹) ^ k / (1 - q⁻¹) ^ (k + 1) = q / (q - 1) ^ (k + 1) := by
      rw [hs, div_pow, inv_pow]
      field_simp
      ring
    have hsign : ((1 : ℂ) - q) ^ (k + 1) = -(((-1 : ℂ)) ^ k * (q - 1) ^ (k + 1)) := by
      rw [show (1 : ℂ) - q = -(q - 1) by ring, neg_pow, pow_succ]
      ring
    rw [hL, hsign]
    field_simp
  rw [hkey]
  ring

/-- **Reciprocity for the transitivity partition function.**  For `0 < ‖q‖ < 1` the value of the
continued partition function at `q⁻¹` is `−q` times the generating function of the reflected
grade counts `P(−n−1)`. -/
theorem polyZeta_reciprocity (P : Polynomial ℂ) {q : ℂ} (hq0 : q ≠ 0) (hq : ‖q‖ < 1) :
    polyZeta P q⁻¹ = -q * ∑' n : ℕ, P.eval (-(n : ℂ) - 1) * q ^ n := by
  have hq1 : q ≠ 1 := by
    intro h; rw [h] at hq; simp at hq
  rw [polyZeta_inv_eq P hq0 hq1, (hasSum_reflected P hq).tsum_eq]

/-- **Reciprocity, negative-grade form.**  `polyZeta P q⁻¹ = − ∑_{n ≥ 1} P(−n) qⁿ`. -/
theorem polyZeta_reciprocity_neg (P : Polynomial ℂ) {q : ℂ} (hq0 : q ≠ 0) (hq : ‖q‖ < 1) :
    polyZeta P q⁻¹ = -∑' n : ℕ, P.eval (-((n : ℂ) + 1)) * q ^ (n + 1) := by
  have hstep : ∑' n : ℕ, P.eval (-((n : ℂ) + 1)) * q ^ (n + 1)
      = q * ∑' n : ℕ, P.eval (-(n : ℂ) - 1) * q ^ n := by
    rw [← tsum_mul_left]
    refine tsum_congr fun n => ?_
    have h : -((n : ℂ) + 1) = -(n : ℂ) - 1 := by ring
    rw [h, pow_succ]
    ring
  rw [polyZeta_reciprocity P hq0 hq, hstep]
  ring

/-- Reciprocity with the **reflected polynomial** `P(−X−1)`: the two partition functions are
exchanged by `q ↦ q⁻¹` up to the factor `−q`.  Applying the statement twice returns `P`, so
reflection is an involution on grade counts. -/
theorem polyZeta_inv_eq_comp (P : Polynomial ℂ) {q : ℂ} (hq0 : q ≠ 0) (hq : ‖q‖ < 1) :
    polyZeta P q⁻¹ = -q * polyZeta (P.comp (-Polynomial.X - 1)) q := by
  rw [polyZeta_reciprocity P hq0 hq, ← tsum_polyZeta _ hq]
  congr 1
  refine tsum_congr fun n => ?_
  congr 1
  rw [eval_comp]
  simp

/-- **Reflection is an involution on grade counts.**  Together with `polyZeta_inv_eq_comp` this
says that `q ↦ q⁻¹` acts on transitivity partition functions as an involution twisted by the
factor `−q`. -/
theorem reflect_involutive (P : Polynomial ℂ) :
    (P.comp (-Polynomial.X - 1)).comp (-Polynomial.X - 1) = P := by
  rw [Polynomial.comp_assoc]
  have h : (-Polynomial.X - 1 : Polynomial ℂ).comp (-Polynomial.X - 1) = Polynomial.X := by
    simp [sub_comp, neg_comp, X_comp, one_comp]
  rw [h, Polynomial.comp_X]

end Physics.GradedTransitivity