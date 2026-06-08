/-
  # Orbit Classification by Energy Sign

  The sign of energy determines the orbit type:
  E < 0 ⟹ e < 1 (ellipse), E = 0 ⟹ e = 1 (parabola), E > 0 ⟹ e > 1 (hyperbola).
-/
import Mathlib
import Pythagorean.KeplerDefs
import Pythagorean.KeplerEccentricity

open Real

/-- The argument inside the sqrt for the eccentricity is monotone in E. -/
private theorem eccentricity_arg_pos_factor {m k l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    2 * l ^ 2 / (m * k ^ 2) > 0 := by positivity

/-
E < 0 implies e < 1 (elliptic orbit), given that the orbit is bound
    (i.e., E ≥ V_min so the eccentricity argument is nonneg).
-/
theorem energy_neg_implies_eccentricity_lt_one {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0)
    (hE : E < 0)
    (_hbound : 0 ≤ 1 + 2 * E * l ^ 2 / (m * k ^ 2)) :
    keplerEccentricity m k E l < 1 := by
  exact Real.sqrt_lt' zero_lt_one |>.2 <| by nlinarith [ show ( 2 * E * l ^ 2 ) / ( m * k ^ 2 ) < 0 by exact div_neg_of_neg_of_pos ( mul_neg_of_neg_of_pos ( mul_neg_of_pos_of_neg ( by norm_num ) hE ) ( sq_pos_of_pos hl ) ) ( by positivity ) ] ;

/-
e < 1 implies E < 0 (bound orbits have negative energy).
-/
theorem eccentricity_lt_one_implies_energy_neg {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0)
    (_hbound : 0 ≤ 1 + 2 * E * l ^ 2 / (m * k ^ 2))
    (he : keplerEccentricity m k E l < 1) :
    E < 0 := by
  contrapose! he;
  exact Real.le_sqrt_of_sq_le ( by linarith [ show 0 ≤ 2 * E * l ^ 2 / ( m * k ^ 2 ) by positivity ] )

/-
E = 0 iff e = 1 (parabolic orbit).
-/
theorem energy_zero_iff_eccentricity_one {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    E = 0 ↔ keplerEccentricity m k E l = 1 := by
  constructor <;> intro h <;> simp_all +decide [ keplerEccentricity ];
  grind

/-
E > 0 implies e > 1 (hyperbolic orbit).
-/
theorem energy_pos_implies_eccentricity_gt_one {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0)
    (hE : E > 0) :
    keplerEccentricity m k E l > 1 := by
  exact Real.lt_sqrt_of_sq_lt ( by norm_num; positivity )

/-
e > 1 implies E > 0.
-/
theorem eccentricity_gt_one_implies_energy_pos {m k E l : ℝ}
    (_hm : m > 0) (_hk : k > 0) (_hl : l > 0)
    (he : keplerEccentricity m k E l > 1) :
    E > 0 := by
  -- By squaring both sides of the inequality he, we get 1 + 2 * E * l ^ 2 / (m * k ^ 2) > 1.
  have h_sq : 1 + 2 * E * l ^ 2 / (m * k ^ 2) > 1 := by
    contrapose! he;
    exact Real.sqrt_le_iff.mpr ⟨ by positivity, by linarith ⟩;
  contrapose! h_sq; exact le_trans ( add_le_of_nonpos_right <| div_nonpos_of_nonpos_of_nonneg ( by nlinarith ) <| mul_nonneg _hm.le <| sq_nonneg _ ) <| by norm_num;