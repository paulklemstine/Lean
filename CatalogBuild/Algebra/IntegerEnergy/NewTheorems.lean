/-! # CatalogBuild.Algebra.IntegerEnergy.NewTheorems

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 19
-/

import Mathlib

noncomputable section

/-- [Section: ## Section 1: Pell Sequence Definitions] -/
theorem pellH_rec (n : ℕ) : pellH (n + 2) = 2 * pellH (n + 1) + pellH n := rfl


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.NewTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 19] -/
theorem pellP_rec (n : ℕ) : pellP (n + 2) = 2 * pellP (n + 1) + pellP n := rfl


/-- The fundamental identity: H(n)² - 2·P(n)² = (-1)^n -/
theorem pell_fundamental (n : ℕ) :
    pellH n ^ 2 - 2 * pellP n ^ 2 = (-1 : ℤ) ^ n :=
  (pell_joint n).1


/-- [Section: ## Section 4: Positivity] -/
theorem pellH_pos (n : ℕ) : 0 < pellH n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ * ];
  exact add_pos ( mul_pos zero_lt_two ( ih _ ( Nat.lt_succ_self _ ) ) ) ( ih _ ( Nat.lt_succ_of_lt ( Nat.lt_succ_self _ ) ) )


theorem pellP_nonneg (n : ℕ) : 0 ≤ pellP n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ * ];
  exact add_nonneg ( mul_nonneg zero_le_two ( ih _ ( Nat.lt_succ_self _ ) ) ) ( ih _ ( Nat.lt_succ_of_lt ( Nat.lt_succ_self _ ) ) )


theorem pellP_pos {n : ℕ} (hn : 0 < n) : 0 < pellP n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pellP ];
  exact add_pos_of_pos_of_nonneg ( mul_pos zero_lt_two ( ih _ le_rfl ( Nat.succ_pos _ ) ) ) ( pellP_nonneg _ )


/-- [Section: ## Section 5: Pell Addition Formulas] -/
theorem pellH_add (m n : ℕ) :
    pellH (m + n) = pellH m * pellH n + 2 * pellP m * pellP n := by
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with ( _ | _ | n );
  · norm_num [ pellH, pellP ];
  · induction' m using Nat.strong_induction_on with m ih;
    rcases m with ( _ | _ | m ) <;> simp_all +decide [ pellH, pellP ];
    linarith [ ih m ( by linarith ), ih ( m + 1 ) ( by linarith ), pellH_rec m, pellP_rec m ];
  · have := ih _ ( Nat.lt_succ_self _ ) m; have := ih _ ( Nat.lt_succ_of_lt <| Nat.lt_succ_self _ ) m; simp_all +decide [ Nat.add_comm, Nat.add_left_comm, pellH_rec, pellP_rec ] ;
    rw [ show m + ( n + 2 ) = ( m + n ) + 2 by ring, pellH_rec ] ; simp_all +decide [ Nat.add_comm, Nat.add_left_comm, Nat.add_assoc ] ; linarith


/-- First leg of the n-th ghost ancestor -/
def ghostP (n : ℕ) (a b c : ℤ) : ℤ :=
  pellH n ^ 2 * a + 2 * pellP n ^ 2 * b - 2 * pellP n * pellH n * c


/-- Second leg of the n-th ghost ancestor -/
def ghostQ (n : ℕ) (a b c : ℤ) : ℤ :=
  2 * pellP n ^ 2 * a + pellH n ^ 2 * b - 2 * pellP n * pellH n * c


/-- Hypotenuse of the n-th ghost ancestor -/
def ghostHyp (n : ℕ) (a b c : ℤ) : ℤ :=
  -2 * pellP n * pellH n * a - 2 * pellP n * pellH n * b +
  (4 * pellP n ^ 2 + (-1 : ℤ) ^ n) * c


/-- If (a,b,c) is Pythagorean, so is the n-th ghost ancestor -/
theorem ghost_preserves_pyth (n : ℕ) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ghostP n a b c ^ 2 + ghostQ n a b c ^ 2 = ghostHyp n a b c ^ 2 := by
  have := ghost_preserves_lorentz n a b c
  linarith


/-- The ghost matrix (inverse of Berggren B₂). -/
def ghostMat : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); 2, 1, (-2); (-2), (-2), 3]


/-- Closed form for M^n using Pell sequences -/
noncomputable def ghostMatClosed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  let H := pellH n
  let P := pellP n
  let ε := (-1 : ℤ) ^ n
  !![H ^ 2,         2 * P ^ 2,     -(2 * P * H);
     2 * P ^ 2,     H ^ 2,         -(2 * P * H);
     -(2 * P * H),  -(2 * P * H),  4 * P ^ 2 + ε]


/-- det(M) = -1 -/
theorem ghostMat_det : det ghostMat = -1 := by native_decide


/-- The trace of M^n equals 4H(n)² - (-1)^n, using H²-2P²=(-1)^n -/
theorem ghostMatClosed_trace (n : ℕ) :
    pellH n ^ 2 + pellH n ^ 2 + (4 * pellP n ^ 2 + (-1 : ℤ) ^ n) =
    4 * pellH n ^ 2 - (-1 : ℤ) ^ n := by
  have := pell_fundamental n; nlinarith


/-- [Section: ## Section 11: Ghost Ancestor Composition] -/
theorem ghost_ancestor_compose_p (m n : ℕ) (a b c : ℤ) :
    ghostP (m + n) a b c =
    ghostP m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostP ghostQ ghostHyp;
  rw [ pellH_add, pellP_add ];
  rw [ show ( -1 : ℤ ) ^ n = pellH n ^ 2 - 2 * pellP n ^ 2 by linarith [ pell_fundamental n ] ] ; ring


theorem ghost_ancestor_compose_q (m n : ℕ) (a b c : ℤ) :
    ghostQ (m + n) a b c =
    ghostQ m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostQ ghostP ghostHyp;
  rw [ pellP_add, pellH_add ] ; ring;
  rw [ show pellH n ^ 2 = 2 * pellP n ^ 2 + ( -1 ) ^ n by linarith [ pell_fundamental n ] ] ; ring


theorem ghost_ancestor_compose_h (m n : ℕ) (a b c : ℤ) :
    ghostHyp (m + n) a b c =
    ghostHyp m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostHyp ghostP ghostQ; ring;
  rw [ pellP_add, pellH_add ] ; ring;
  rw [ show pellH m ^ 2 = 2 * pellP m ^ 2 + ( -1 ) ^ m by linarith [ pell_fundamental m ] ] ; ring;
  rw [ show pellH n ^ 2 = 2 * pellP n ^ 2 + ( -1 ) ^ n by linarith [ pell_fundamental n ] ] ; ring


/-- [Section: ## Section 12: Pell Periodicity Modulo m (Pigeonhole)] -/
theorem pell_eventually_periodic (m : ℕ) (hm : 2 ≤ m) :
    ∃ i j : ℕ, i < j ∧ j ≤ m ^ 2 + 1 ∧
    pellH i % (m : ℤ) = pellH j % m ∧ pellP i % (m : ℤ) = pellP j % m := by
  by_contra! h;
  exact absurd ( Finset.card_le_card ( show Finset.image ( fun n : ℕ => ( pellH n % m, pellP n % m ) ) ( Finset.range ( m ^ 2 + 1 ) ) ⊆ Finset.product ( Finset.Ico 0 m ) ( Finset.Ico 0 m ) from Finset.image_subset_iff.mpr fun n hn => Finset.mem_product.mpr ⟨ Finset.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩, Finset.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩ ⟩ ) ) ( by erw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( Nat.le_of_not_lt fun hi' => h _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ( by aesop ) <| by aesop ) ( Nat.le_of_not_lt fun hj' => h _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ( by aesop ) <| by aesop ) ] ; norm_num ; nlinarith )


end
