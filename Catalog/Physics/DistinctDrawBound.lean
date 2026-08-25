/-
# The only resource is the set of distinct draws

## Provenance (round-75 #3, exp 569b, paper 220)

The pooling audit found two ways of over-counting one random stream: a strict-superset leg
pooled with its own prefix, and a pilot population reconstructed inside the later pool.  Both
are instances of a single principle, and this file proves the principle in the sharpest form
available.

Let a lab cut *any* finite family of measurement legs `S l` out of one stream and pool them
with *any* weights summing to `1` — nested, overlapping, partially shared, re-sliced,
re-weighted, it does not matter.  Write `U = ⋃ l, S l` for the set of stream positions the lab
has actually consumed.  Then

  `Var(pool) ≥ σ² / |U|`.

The bound depends on **nothing but the number of distinct draws**: not on the number of legs,
not on how they are weighted, not on how the analysis slices them.  A lineage of runs from one
master seed can only ever be as good as the union of its draws, and the "three-leg joint" that
was retracted this round could not have beaten the single longest leg no matter how the
inverse-variance weights had been repaired.

## Main results

* `Design.combo_eq_sum_coeff` — any weighted pool of legs is a single linear form
  `∑_{i ∈ U} c i • draw i` in the distinct draws, with `c i` the total weight landing on
  position `i`.
* `sum_poolCoeff` — the coefficients of a convex pool sum to `1`; unbiasedness survives
  arbitrary overlap.
* `Design.var_linear_form` — the variance of such a linear form is `σ² ∑ c i ²`.
* `Design.var_combo_ge_distinct_draws` — **the master information bound** `σ²/|U| ≤ Var(pool)`,
  by Chebyshev/Cauchy–Schwarz on the coefficient vector.
* `Design.var_uniform_eq_distinct_draws` — the bound is attained by the uniform pool over `U`,
  so it is sharp: the honest thing to do with overlapping legs is to average the *distinct
  draws*.
-/
import Physics.PoolingIndependenceAudit

namespace Catalog.Physics.PoolingAudit

open Finset RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

namespace Design

variable (D : Design E)

/-- Variance of an arbitrary linear form in the stream: `σ² ∑ c i ²`. -/
theorem var_linear_form (U : Finset ℕ) (c : ℕ → ℝ) :
    ⟪∑ i ∈ U, c i • D.draw i, ∑ j ∈ U, c j • D.draw j⟫
      = D.sigma ^ 2 * ∑ i ∈ U, (c i) ^ 2 := by
  rw [sum_inner, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [real_inner_smul_left, inner_sum]
  rw [Finset.sum_eq_single_of_mem i hi ?_]
  · rw [real_inner_smul_right, D.scale i]; ring
  · intro b _ hb
    rw [real_inner_smul_right, D.orth i b (Ne.symm hb), mul_zero]

/-- A weighted pool of legs `S l`, `l ∈ L`. -/
noncomputable def combo (L : Finset ℕ) (w : ℕ → ℝ) (S : ℕ → Finset ℕ) : E :=
  ∑ l ∈ L, w l • D.mean (S l)

/-- The total weight the pool puts on stream position `i`. -/
noncomputable def poolCoeff (L : Finset ℕ) (w : ℕ → ℝ) (S : ℕ → Finset ℕ) (i : ℕ) : ℝ :=
  ∑ l ∈ L, if i ∈ S l then w l / ((S l).card : ℝ) else 0

/-- **Any pool is a linear form in the distinct draws.** -/
theorem combo_eq_sum_coeff (L : Finset ℕ) (w : ℕ → ℝ) (S : ℕ → Finset ℕ) :
    D.combo L w S = ∑ i ∈ L.biUnion S, poolCoeff L w S i • D.draw i := by
  rw [combo]
  have h1 : ∀ l ∈ L, w l • D.mean (S l)
      = ∑ i ∈ L.biUnion S, (if i ∈ S l then w l / ((S l).card : ℝ) else 0) • D.draw i := by
    intro l hl
    simp only [ite_smul, zero_smul]
    rw [Finset.sum_ite_mem, Finset.inter_eq_right.2 (Finset.subset_biUnion_of_mem S hl),
      mean, smul_smul, Finset.smul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [div_eq_mul_inv]
  rw [Finset.sum_congr rfl h1, Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [poolCoeff, Finset.sum_smul]

/-- **Unbiasedness survives overlap.**  The coefficients of a pool sum to the total weight. -/
theorem sum_poolCoeff {L : Finset ℕ} {w : ℕ → ℝ} {S : ℕ → Finset ℕ}
    (hne : ∀ l ∈ L, (S l).Nonempty) :
    ∑ i ∈ L.biUnion S, poolCoeff L w S i = ∑ l ∈ L, w l := by
  simp only [poolCoeff]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun l hl => ?_
  have hc : ((S l).card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 (hne l hl))
  rw [Finset.sum_ite_mem, Finset.inter_eq_right.2 (Finset.subset_biUnion_of_mem S hl),
    Finset.sum_const, nsmul_eq_mul]
  field_simp

/-- **The master information bound.**  However a lab slices and weights the legs it cut from a
single stream, the honest variance of the pooled estimator is at least `σ²` over the number of
*distinct draws consumed*. -/
theorem var_combo_ge_distinct_draws {L : Finset ℕ} {w : ℕ → ℝ} {S : ℕ → Finset ℕ}
    (hne : ∀ l ∈ L, (S l).Nonempty) (hL : L.Nonempty) (hsum : ∑ l ∈ L, w l = 1) :
    D.sigma ^ 2 / ((L.biUnion S).card : ℝ) ≤ ⟪D.combo L w S, D.combo L w S⟫ := by
  set U := L.biUnion S with hU
  set c := poolCoeff L w S with hc
  have hUne : U.Nonempty := by
    obtain ⟨l, hl⟩ := hL
    obtain ⟨i, hi⟩ := hne l hl
    exact ⟨i, Finset.mem_biUnion.2 ⟨l, hl, hi⟩⟩
  have hcard : (0 : ℝ) < (U.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hUne
  have hσ : (0 : ℝ) < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  have hvar : ⟪D.combo L w S, D.combo L w S⟫ = D.sigma ^ 2 * ∑ i ∈ U, (c i) ^ 2 := by
    rw [D.combo_eq_sum_coeff L w S, D.var_linear_form U c]
  have hone : ∑ i ∈ U, c i = 1 := by rw [hc, sum_poolCoeff hne, hsum]
  have hcheb : (∑ i ∈ U, c i) ^ 2 ≤ (U.card : ℝ) * ∑ i ∈ U, (c i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  rw [hone, one_pow] at hcheb
  rw [hvar, div_le_iff₀ hcard]
  nlinarith [hσ, hcheb]

/-- Sharpness: the uniform average over all distinct draws attains the bound.  Together with
the previous theorem this identifies the *only* efficient use of an overlapping family of
legs. -/
theorem var_uniform_eq_distinct_draws {U : Finset ℕ} (hU : U.Nonempty) :
    ⟪∑ i ∈ U, ((U.card : ℝ)⁻¹) • D.draw i, ∑ j ∈ U, ((U.card : ℝ)⁻¹) • D.draw j⟫
      = D.sigma ^ 2 / ((U.card : ℝ)) := by
  have hcard : (0 : ℝ) < (U.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hU
  rw [D.var_linear_form U (fun _ => ((U.card : ℝ)⁻¹)), Finset.sum_const, nsmul_eq_mul]
  field_simp

end Design

end Catalog.Physics.PoolingAudit