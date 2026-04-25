/-! # CatalogBuild.Geometry.Stereographic.ConformalAnalysis

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 9
-/

import Geometry.Stereographic.Basic
import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.ConformalAnalysis
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 9] -/
theorem stereoDenom_continuous {N : ℕ} : Continuous (@stereoDenom N) := by
  refine' continuous_const.add ( continuous_finset_sum _ fun i _ ↦ Continuous.pow ?_ 2 );
  fun_prop




/-- [Section: # CatalogBuild.Geometry.Stereographic.ConformalAnalysis
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 9] -/
theorem invStereoN_continuous {N : ℕ} : Continuous (@invStereoN N) := by
  have h_cont : ∀ i : Fin (N + 1), Continuous (fun y : Fin N → ℝ => if h : i.val < N then 2 * y ⟨i.val, h⟩ / stereoDenom y else (sqNormFin y - 1) / stereoDenom y) := by
    intro i; split_ifs;
    · exact Continuous.div ( continuous_const.mul ( continuous_apply _ ) ) ( continuous_const.add ( continuous_finset_sum _ fun _ _ => continuous_pow 2 |> Continuous.comp <| continuous_apply _ ) ) fun y => by exact ne_of_gt <| add_pos_of_pos_of_nonneg zero_lt_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _;
    · exact Continuous.div ( by exact Continuous.sub ( continuous_finset_sum _ fun _ _ => Continuous.pow ( continuous_apply _ ) _ ) continuous_const ) ( by exact Continuous.add continuous_const ( continuous_finset_sum _ fun _ _ => Continuous.pow ( continuous_apply _ ) _ ) ) fun y => by unfold stereoDenom; exact ne_of_gt <| add_pos_of_pos_of_nonneg zero_lt_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _;
  exact?




theorem invStereoN_last_coord_range {N : ℕ} (y : Fin N → ℝ) :
    -1 ≤ invStereoN y (lastIdx N) ∧ invStereoN y (lastIdx N) < 1 := by
      unfold invStereoN;
      unfold lastIdx;
      norm_num [ stereoDenom ];
      exact ⟨ by rw [ le_div_iff₀ ] <;> linarith [ show 0 ≤ sqNormFin y by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ], by rw [ div_lt_iff₀ ] <;> linarith [ show 0 ≤ sqNormFin y by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ⟩




theorem invStereoN_coord_bounded {N : ℕ} (y : Fin N → ℝ) (i : Fin (N + 1)) :
    |invStereoN y i| ≤ 1 := by
      convert Real.abs_le_sqrt ?_;
      rw [ Real.sqrt_one ];
      exact le_trans ( Finset.single_le_sum ( fun a _ => sq_nonneg ( invStereoN y a ) ) ( Finset.mem_univ i ) ) ( by rw [ invStereoN_norm_sq ] )




theorem stereoDenom_eq_one_add_sum {N : ℕ} (y : Fin N → ℝ) :
    stereoDenom y = 1 + ∑ i, y i ^ 2 := by
      rfl




theorem invStereoN_last_mono {N : ℕ} (y z : Fin N → ℝ)
    (h : sqNormFin y ≤ sqNormFin z) :
    invStereoN y (lastIdx N) ≤ invStereoN z (lastIdx N) := by
      rw [ invStereoN_last_coord, invStereoN_last_coord ];
      rw [ div_le_div_iff₀ ] <;> try linarith [ stereoDenom_pos y, stereoDenom_pos z ];
      unfold stereoDenom; nlinarith [ sqNormFin_nonneg y, sqNormFin_nonneg z ] ;




theorem unit_ball_to_southern {N : ℕ} (y : Fin N → ℝ) (h : sqNormFin y ≤ 1) :
    invStereoN y (lastIdx N) ≤ 0 := by
      rw [ StereographicProjection.invStereoN_last_coord ];
      exact div_nonpos_of_nonpos_of_nonneg ( sub_nonpos_of_le h ) ( stereoDenom_pos y |> le_of_lt )




theorem unit_sphere_to_equator {N : ℕ} (y : Fin N → ℝ) (h : sqNormFin y = 1) :
    invStereoN y (lastIdx N) = 0 := by
      rw [ StereographicProjection.invStereoN_last_coord, StereographicProjection.stereoDenom ];
      norm_num [ h ]




theorem exterior_to_northern {N : ℕ} (y : Fin N → ℝ) (h : 1 < sqNormFin y) :
    0 < invStereoN y (lastIdx N) := by
      rw [ StereographicProjection.invStereoN_last_coord ];
      exact div_pos ( sub_pos.mpr h ) ( stereoDenom_pos _ )




end
