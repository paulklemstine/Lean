/-
# What to do instead: optimal weights for legs that are not independent

## Provenance (round-75 #3, exp 569b, paper 220)

The audit retracted one joint and repaired another, both times because inverse-variance
weighting assumes a covariance of zero.  Once the covariance is *known* — and the companion
files make it known, both for shared draws (`Design.cov_mean`) and for shared populations
(`PopDesign.cov_legMean`) — the right weight is no longer a matter of convention.

This file proves the generalised-least-squares rule for two legs and reads off what it says
about the round's two configurations.  For legs of variances `v₁, v₂` and covariance `c`, the
pooled variance is the quadratic

  `f w = w² v₁ + (1-w)² v₂ + 2w(1-w) c`,

and completing the square gives everything at once.

## Main results

* `pool_var_completed_square` — the exact identity
  `f w = (v₁ + v₂ - 2c)(w - w*)² + (v₁v₂ - c²)/(v₁ + v₂ - 2c)` with
  `w* = (v₂ - c)/(v₁ + v₂ - 2c)`.
* `pool_var_ge_floor`, `pool_var_eq_floor_iff` — the floor `(v₁v₂ - c²)/(v₁ + v₂ - 2c)` is
  attained exactly at `w*`, so `w*` is the unique optimum.
* `ivw_eq_gls_iff` — **inverse-variance weighting is optimal iff `c(v₂ - v₁) = 0`**: for legs
  of unequal precision, zero covariance is not merely convenient, it is the exact condition
  under which the published weights are the right ones.
* `Design.gls_weight_of_nested_eq_zero` — for a prefix leg nested in a longer run the optimum
  is `w* = 0` with floor `σ²/|T|`: *discard the prefix* is not a heuristic, it is the GLS
  solution.
* `Design.gls_weight_of_disjoint_eq_ivw` — for genuinely disjoint legs the GLS weight is the
  familiar inverse-variance weight, so a fresh master seed restores the published procedure
  exactly.
-/
import Physics.PoolingIndependenceAudit

namespace Catalog.Physics.PoolingAudit

open Finset RealInnerProductSpace

/-- The pooled variance of two legs with variances `v₁, v₂` and covariance `c`, as a function of
the weight on the first leg. -/
noncomputable def poolVar (v₁ v₂ c w : ℝ) : ℝ := w ^ 2 * v₁ + (1 - w) ^ 2 * v₂ + 2 * w * (1 - w) * c

/-- The generalised-least-squares weight. -/
noncomputable def glsWeight (v₁ v₂ c : ℝ) : ℝ := (v₂ - c) / (v₁ + v₂ - 2 * c)

/-- The GLS variance floor. -/
noncomputable def glsFloor (v₁ v₂ c : ℝ) : ℝ := (v₁ * v₂ - c ^ 2) / (v₁ + v₂ - 2 * c)

/-- **Completing the square.**  Everything about pooling two correlated legs is in this
identity. -/
theorem pool_var_completed_square {v₁ v₂ c : ℝ} (hpos : 0 < v₁ + v₂ - 2 * c) (w : ℝ) :
    poolVar v₁ v₂ c w
      = (v₁ + v₂ - 2 * c) * (w - glsWeight v₁ v₂ c) ^ 2 + glsFloor v₁ v₂ c := by
  rw [poolVar, glsWeight, glsFloor]
  field_simp
  ring

/-- The GLS weight attains the floor. -/
theorem pool_var_at_gls {v₁ v₂ c : ℝ} (hpos : 0 < v₁ + v₂ - 2 * c) :
    poolVar v₁ v₂ c (glsWeight v₁ v₂ c) = glsFloor v₁ v₂ c := by
  rw [pool_var_completed_square hpos]
  ring

/-- No weighting beats the GLS floor. -/
theorem pool_var_ge_floor {v₁ v₂ c : ℝ} (hpos : 0 < v₁ + v₂ - 2 * c) (w : ℝ) :
    glsFloor v₁ v₂ c ≤ poolVar v₁ v₂ c w := by
  rw [pool_var_completed_square hpos]
  nlinarith [sq_nonneg (w - glsWeight v₁ v₂ c)]

/-- …and the GLS weight is the unique minimiser. -/
theorem pool_var_eq_floor_iff {v₁ v₂ c : ℝ} (hpos : 0 < v₁ + v₂ - 2 * c) (w : ℝ) :
    poolVar v₁ v₂ c w = glsFloor v₁ v₂ c ↔ w = glsWeight v₁ v₂ c := by
  rw [pool_var_completed_square hpos]
  constructor
  · intro h
    have hsq : (w - glsWeight v₁ v₂ c) ^ 2 = 0 := by
      have := sq_nonneg (w - glsWeight v₁ v₂ c)
      nlinarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
    linarith
  · intro h
    rw [h]
    ring

/-- **When is the published weight the right one?**  Inverse-variance weighting `v₂/(v₁ + v₂)`
coincides with the GLS weight exactly when `c (v₂ - v₁) = 0`: for legs of unequal precision
this forces zero covariance. -/
theorem ivw_eq_gls_iff {v₁ v₂ c : ℝ} (hpos : 0 < v₁ + v₂ - 2 * c) (hv : 0 < v₁ + v₂) :
    v₂ / (v₁ + v₂) = glsWeight v₁ v₂ c ↔ c * (v₂ - v₁) = 0 := by
  rw [glsWeight, div_eq_div_iff (ne_of_gt hv) (ne_of_gt hpos)]
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

namespace Design

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (D : Design E)

/-- The honest pooled variance of two legs is the quadratic `poolVar` in the weight. -/
theorem trueVar_eq_poolVar {w : ℝ} {S T : Finset ℕ} (hS : S.Nonempty) (hT : T.Nonempty) :
    D.trueVar w S T
      = poolVar (D.sigma ^ 2 / (S.card : ℝ)) (D.sigma ^ 2 / (T.card : ℝ))
          (D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ))) w := by
  have hcS : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hS)
  have hcT : (T.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hT)
  rw [D.trueVar_eq_naiveVar_add hS hT, naiveVar, poolVar]
  field_simp

/-- **Discard the prefix, as a theorem of optimal estimation.**  For a leg nested in a longer
run the GLS weight on the prefix is exactly `0` and the floor is the long leg's own variance:
the lineage adds nothing. -/
theorem gls_weight_of_nested_eq_zero {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty)
    (hlt : S.card < T.card) :
    glsWeight (D.sigma ^ 2 / (S.card : ℝ)) (D.sigma ^ 2 / (T.card : ℝ))
        (D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ))) = 0
      ∧ glsFloor (D.sigma ^ 2 / (S.card : ℝ)) (D.sigma ^ 2 / (T.card : ℝ))
          (D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ)))
        = D.sigma ^ 2 / (T.card : ℝ) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hT : T.Nonempty := Finset.card_pos.1 (lt_of_le_of_lt (Nat.zero_le _) hlt)
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hcast : (S.card : ℝ) < (T.card : ℝ) := by exact_mod_cast hlt
  have hσ : (0 : ℝ) < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  have hcov : D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ))
      = D.sigma ^ 2 / (T.card : ℝ) := by
    rw [Finset.inter_eq_left.2 hST]
    field_simp
  have hd : (0 : ℝ) < (T.card : ℝ) - (S.card : ℝ) := sub_pos.2 hcast
  have hne : D.sigma ^ 2 / (S.card : ℝ) + D.sigma ^ 2 / (T.card : ℝ)
      - 2 * (D.sigma ^ 2 / (T.card : ℝ)) ≠ 0 := by
    have hgap : D.sigma ^ 2 / (T.card : ℝ) < D.sigma ^ 2 / (S.card : ℝ) :=
      div_lt_div_of_pos_left hσ hcS hcast
    have hrw : D.sigma ^ 2 / (S.card : ℝ) + D.sigma ^ 2 / (T.card : ℝ)
        - 2 * (D.sigma ^ 2 / (T.card : ℝ))
        = D.sigma ^ 2 / (S.card : ℝ) - D.sigma ^ 2 / (T.card : ℝ) := by ring
    rw [hrw]
    exact ne_of_gt (by linarith)
  rw [hcov]
  refine ⟨by rw [glsWeight, sub_self, zero_div], ?_⟩
  rw [glsFloor, div_eq_iff hne]
  field_simp
  ring

/-- For genuinely disjoint legs — a fresh master seed — the GLS weight *is* the inverse-variance
weight, so the published procedure is exactly right once the streams are separated. -/
theorem gls_weight_of_disjoint_eq_ivw {S T : Finset ℕ} (hdisj : Disjoint S T) (hS : S.Nonempty)
    (hT : T.Nonempty) :
    glsWeight (D.sigma ^ 2 / (S.card : ℝ)) (D.sigma ^ 2 / (T.card : ℝ))
        (D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ)))
      = ivw S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hσ : (0 : ℝ) < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  rw [Finset.disjoint_iff_inter_eq_empty.1 hdisj]
  simp only [Finset.card_empty, Nat.cast_zero, mul_zero, zero_div]
  rw [glsWeight, ivw]
  field_simp
  ring

end Design

end Catalog.Physics.PoolingAudit