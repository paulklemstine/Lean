import Logic.BasicMonotoneCircuit.Basic
-- import Geometry.Stereographic.MetricGeometry  -- (module absent from the catalog; import removed so the file compiles)
import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.GeodesicTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/


noncomputable section

theorem invStereoN_sum_sq_first {N : ℕ} (y : Fin N → ℝ) :
    ∑ i : Fin N, (invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ^ 2 =
    4 * sqNormFin y / (stereoDenom y) ^ 2 := by
      unfold invStereoN sqNormFin stereoDenom;
      simp +decide [ div_pow, Finset.mul_sum _ _ _, mul_pow ];
      norm_num [ Finset.sum_div _ _ _ ]


theorem pullback_metric_conformal {N : ℕ} (y : Fin N → ℝ) :
    (2 / stereoDenom y) ^ 2 = 4 / (stereoDenom y) ^ 2 := by
      ring


theorem conformal_factor_product_bound {N : ℕ} (y z : Fin N → ℝ) :
    (2 / stereoDenom y) * (2 / stereoDenom z) ≤ 4 := by
      rw [ div_mul_div_comm ];
      exact le_trans ( div_le_self ( by norm_num ) ( one_le_mul_of_one_le_of_one_le ( stereoDenom_ge_one y ) ( stereoDenom_ge_one z ) ) ) ( by norm_num )


theorem sphere_diameter_bound {N : ℕ} (y z : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 ≤ 4 := by
      rw [ StereographicProjection.invStereoN_chordal_sq ];
      have := StereographicProjection.chordal_le_euclidean y z;
      rw [ div_le_iff₀ ] at *;
      · have := StereographicProjection.invStereoN_chordal_sq y z;
        have := StereographicProjection.invStereoN_norm_sq y;
        have := StereographicProjection.invStereoN_norm_sq z;
        have := Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( invStereoN y i + invStereoN z i );
        simp_all +decide [ Finset.sum_add_distrib, add_mul, mul_add, sub_mul, mul_sub, sq ];
        rw [ eq_div_iff ] at * <;> nlinarith [ show 0 < stereoDenom y * stereoDenom z by exact mul_pos ( stereoDenom_pos y ) ( stereoDenom_pos z ) ];
      · exact mul_pos ( stereoDenom_pos y ) ( stereoDenom_pos z );
      · exact mul_pos ( stereoDenom_pos y ) ( stereoDenom_pos z )


theorem stereoDenom_of_sum {N : ℕ} (y z : Fin N → ℝ) :
    stereoDenom (fun i => y i + z i) =
    stereoDenom y + stereoDenom z + 2 * dotProdFin y z - 1 := by
      unfold stereoDenom dotProdFin;
      unfold sqNormFin; norm_num [ add_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ; ring;


theorem stereoDenom_diff {N : ℕ} (y z : Fin N → ℝ) :
    stereoDenom y - stereoDenom z = sqNormFin y - sqNormFin z := by
      unfold stereoDenom; ring;


theorem sphere_orthogonality {N : ℕ} (y z : Fin N → ℝ) :
    (∑ i : Fin (N + 1), invStereoN y i * invStereoN z i = 0) ↔
    4 * dotProdFin y z + (sqNormFin y - 1) * (sqNormFin z - 1) = 0 := by
      rw [ StereographicProjection.invStereoN_dot_product ];
      exact div_eq_zero_iff.trans <| or_iff_left <| mul_ne_zero ( ne_of_gt <| stereoDenom_pos _ ) ( ne_of_gt <| stereoDenom_pos _ )


theorem midpoint_last_coord {N : ℕ} (y z : Fin N → ℝ) :
    invStereoN (fun i => (y i + z i) / 2) (lastIdx N) =
    ((sqNormFin y + 2 * dotProdFin y z + sqNormFin z) / 4 - 1) /
    (1 + (sqNormFin y + 2 * dotProdFin y z + sqNormFin z) / 4) := by
      unfold invStereoN;
      unfold sqNormFin stereoDenom dotProdFin;
      unfold lastIdx at * ; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, add_sq, mul_pow, div_pow ] ; ring;
      unfold sqNormFin; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
      norm_num [ Finset.sum_add_distrib, mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ; ring


theorem chordal_decomposition {N : ℕ} (y z : Fin N → ℝ) :
    ∑ i : Fin (N + 1), (invStereoN y i - invStereoN z i) ^ 2 =
    (∑ i : Fin N, (invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ -
                   invStereoN z ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ^ 2) +
    (invStereoN y (lastIdx N) - invStereoN z (lastIdx N)) ^ 2 := by
      convert Fin.sum_univ_castSucc _ using 1


theorem invStereoN_scale_first {N : ℕ} (y : Fin N → ℝ) (r : ℝ) (i : Fin N) :
    invStereoN (fun j => r * y j) ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ =
    2 * r * y i / (1 + r ^ 2 * sqNormFin y) := by
      unfold invStereoN;
      unfold stereoDenom; norm_num [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
      unfold sqNormFin; norm_num [ Finset.mul_sum _ _ _, mul_pow ] ;


theorem great_circle_through_NP_last {N : ℕ} (y : Fin N → ℝ) (t : ℝ) :
    invStereoN (fun i => t * y i) (lastIdx N) =
    (t ^ 2 * sqNormFin y - 1) / (1 + t ^ 2 * sqNormFin y) := by
      unfold invStereoN lastIdx;
      unfold sqNormFin stereoDenom; norm_num [ Finset.mul_sum _ _ _, mul_pow ] ; ring;
      unfold sqNormFin; norm_num [ Finset.mul_sum _ _ _, mul_pow ] ;


theorem equator_identity {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y = 1) (i : Fin N) :
    invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ = y i := by
      unfold sqNormFin at hy;
      unfold invStereoN;
      unfold stereoDenom; unfold sqNormFin; split_ifs <;> simp_all +decide [ Finset.sum_div _ _ _, div_eq_iff ] ; ring;


end