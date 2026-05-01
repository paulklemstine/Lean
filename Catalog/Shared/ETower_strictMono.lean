import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5
-/

noncomputable section

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem eTower_strictMono : StrictMono eTower := by
  refine' strictMono_nat_of_lt_succ _;
  intro n;
  exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

/-- The e-tower is strictly positive. -/
theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => exact Real.exp_pos _

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5] -/
theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2^n := by
  induction' hn with n hn ih <;> simp_all +decide [ pow_succ', eTower ];
  · linarith [ Real.add_one_le_exp 1 ];
  · have h_exp_growth : Real.exp (2^n) ≥ 2 * 2^n := by
      exact?;
    exact le_trans h_exp_growth ( Real.exp_le_exp.mpr ih )

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    simp [eTower]
    linarith [Real.add_one_le_exp (eTower n)]

/-- The e-tower: e↑↑n. -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

end

end

end