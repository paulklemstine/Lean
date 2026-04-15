/-! # CatalogBuild.ComplexityTheory.Foundations

Auto-generated from theorem catalog database.
Domain: ComplexityTheory
Declarations: 10
-/

import Mathlib

/-- [Section: ## Boolean Functions and Basic Combinatorics] -/
theorem hammingWeight_le {n : ℕ} (x : BoolFn n) : hammingWeight x ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )


theorem hammingDist_triangle {n : ℕ} (x y z : BoolFn n) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
      -- If x_i ≠ z_i, then either x_i ≠ y_i or y_i ≠ z_i. So the filter set for x,z is contained in the union of filter sets for x,y and y,z. Then use card_union_le.
      have h_filter : Finset.univ.filter (fun i => x i ≠ z i) ⊆ Finset.univ.filter (fun i => x i ≠ y i) ∪ Finset.univ.filter (fun i => y i ≠ z i) := by
        grind;
      exact le_trans ( Finset.card_le_card h_filter ) ( Finset.card_union_le _ _ )


theorem hammingDist_eq_zero_iff {n : ℕ} (x y : BoolFn n) :
    hammingDist x y = 0 ↔ x = y := by
      simp +decide [ hammingDist, funext_iff ]


/-- [Section: ## Certificate Complexity] -/
theorem empty_certificate_of_const {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n)
    (hconst : ∀ y, f y = f x) : IsCertificate f x ∅ := by
      exact fun y hy => hconst y


theorem full_certificate {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n) :
    IsCertificate f x Finset.univ := by
      exact fun y _ => by simp +decide [ show y = x from funext fun i => by simpa using ‹∀ i ∈ Finset.univ, y i = x i› i ( Finset.mem_univ i ) ] ;


/-- Pointwise ordering on Boolean strings -/
def boolLE {n : ℕ} (x y : BoolFn n) : Prop :=
  ∀ i : Fin n, x i = true → y i = true


/-- [Section: ## Monotone Boolean Functions] -/
theorem boolLE_refl {n : ℕ} (x : BoolFn n) : boolLE x x := by
  exact fun i hi => hi


theorem boolLE_trans {n : ℕ} (x y z : BoolFn n) :
    boolLE x y → boolLE y z → boolLE x z := by
      exact fun hxy hyz i hi => hyz i ( hxy i hi )


theorem boolLE_antisymm {n : ℕ} (x y : BoolFn n) :
    boolLE x y → boolLE y x → x = y := by
      intros hxy hyx
      funext i
      by_cases hxi : x i = true;
      · have := hxy i; have := hyx i; aesop;
      · cases h : x i <;> cases h' : y i <;> simp_all +decide [ boolLE ]


/-- [Section: ## Influence of Variables] -/
theorem influence_const {n : ℕ} (b : Bool) (i : Fin n) :
    influence (fun _ : BoolFn n => b) i = 0 := by
      unfold influence; aesop;

