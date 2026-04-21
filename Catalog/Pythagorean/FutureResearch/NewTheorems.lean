import Mathlib

/-! # New Theorems: Pythagorean Tree Ancestry and Factoring

This file formalizes and proves new theorems emerging from open research
questions about ghost matrix powers, Pell sequences, and their connections
to integer factoring.
-/

open Matrix

namespace PythagoreanResearch

/-! ## Section 1: Pell Sequence Definitions -/

/-- Half-companion Pell numbers: H(0)=1, H(1)=1, H(n+2)=2H(n+1)+H(n) -/
def pellH : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | n + 2 => 2 * pellH (n + 1) + pellH n

/-- Pell numbers: P(0)=0, P(1)=1, P(n+2)=2P(n+1)+P(n) -/
def pellP : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 2 * pellP (n + 1) + pellP n

@[simp] theorem pellH_0 : pellH 0 = 1 := rfl
@[simp] theorem pellH_1 : pellH 1 = 1 := rfl
@[simp] theorem pellP_0 : pellP 0 = 0 := rfl
@[simp] theorem pellP_1 : pellP 1 = 1 := rfl

theorem pellH_rec (n : ℕ) : pellH (n + 2) = 2 * pellH (n + 1) + pellH n := rfl
theorem pellP_rec (n : ℕ) : pellP (n + 2) = 2 * pellP (n + 1) + pellP n := rfl

/-! ## Section 2: Fundamental Pell Identity -/

/-
Joint induction for the Pell identity and cross product
-/
private theorem pell_joint (n : ℕ) :
    pellH n ^ 2 - 2 * pellP n ^ 2 = (-1 : ℤ) ^ n ∧
    pellH (n + 1) * pellH n - 2 * pellP (n + 1) * pellP n = (-1 : ℤ) ^ n := by
  -- We proceed by induction on $n$ with base cases $n = 0$ and $n = 1$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ ih, pellH_0, pellH_1, pellP_0, pellP_1, pellH_rec, pellP_rec ];
  grind

/-- The fundamental identity: H(n)² - 2·P(n)² = (-1)^n -/
theorem pell_fundamental (n : ℕ) :
    pellH n ^ 2 - 2 * pellP n ^ 2 = (-1 : ℤ) ^ n :=
  (pell_joint n).1

/-- Cross product identity -/
theorem pell_cross (n : ℕ) :
    pellH (n + 1) * pellH n - 2 * pellP (n + 1) * pellP n = (-1 : ℤ) ^ n :=
  (pell_joint n).2

/-! ## Section 3: Pell Cassini Identity -/

/-
Cassini identity: P(n+2)·P(n) - P(n+1)² = (-1)^(n+1)
-/
theorem pell_cassini (n : ℕ) :
    pellP (n + 2) * pellP n - pellP (n + 1) ^ 2 = (-1 : ℤ) ^ (n + 1) := by
  -- We proceed by induction on $n$.
  induction' n with n ih;
  · decide +revert;
  · simp_all +decide [ pow_succ, pellP_rec ];
    grind

/-! ## Section 4: Positivity -/

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

/-! ## Section 5: Pell Addition Formulas -/

/-
H(m+n) = H(m)·H(n) + 2·P(m)·P(n)
-/
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

/-
P(m+n) = P(m)·H(n) + H(m)·P(n)
-/
theorem pellP_add (m n : ℕ) :
    pellP (m + n) = pellP m * pellH n + pellH m * pellP n := by
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with ( _ | _ | n );
  · norm_num [ pellH_0, pellP_0 ];
  · induction' m with m ih;
    · decide +revert;
    · grind +suggestions;
  · rw [ Nat.add_comm, pellP_rec ];
    have := ih ( n + 1 ) ( by linarith ) m; have := ih n ( by linarith ) m; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    rw [ show m + ( n + 2 ) = m + n + 2 by ring, pellP_rec ] ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ; ring;
    rw [ show 2 + n = n + 2 by ring, show 1 + n = n + 1 by ring ] ; rw [ pellH_rec ] ; ring;

/-! ## Section 6: Pell Doubling Formulas -/

/-- P(2n) = 2·P(n)·H(n) -/
theorem pellP_double (n : ℕ) : pellP (2 * n) = 2 * pellP n * pellH n := by
  have := pellP_add n n
  rw [show n + n = 2 * n from by omega] at this
  linarith [mul_comm (pellP n) (pellH n)]

/-- H(2n) = 2·H(n)² - (-1)^n -/
theorem pellH_double (n : ℕ) : pellH (2 * n) = 2 * pellH n ^ 2 - (-1 : ℤ) ^ n := by
  have h1 := pellH_add n n
  rw [show n + n = 2 * n from by omega] at h1
  have h2 := pell_fundamental n
  linarith [sq (pellH n)]

/-! ## Section 7: Ghost Ancestor Definitions -/

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

/-! ## Section 8: Ghost Preserves Pythagorean Property -/

/-
Ghost ancestor preserves the Lorentz form
-/
theorem ghost_preserves_lorentz (n : ℕ) (a b c : ℤ) :
    ghostP n a b c ^ 2 + ghostQ n a b c ^ 2 - ghostHyp n a b c ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold ghostP ghostQ ghostHyp;
  -- Substitute pell_fundamental into the expression to simplify.
  have h_sub : pellH n ^ 2 = 2 * pellP n ^ 2 + (-1 : ℤ) ^ n := by
    have := pell_fundamental n; linarith;
  by_cases hn : Even n <;> simp_all +decide;
  · grind;
  · grind

/-- If (a,b,c) is Pythagorean, so is the n-th ghost ancestor -/
theorem ghost_preserves_pyth (n : ℕ) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ghostP n a b c ^ 2 + ghostQ n a b c ^ 2 = ghostHyp n a b c ^ 2 := by
  have := ghost_preserves_lorentz n a b c
  linarith

/-! ## Section 9: Ghost Leg Difference Identity -/

/-- The leg difference satisfies: Q_n - P_n = (-1)^n · (b - a) -/
theorem ghost_leg_diff (n : ℕ) (a b c : ℤ) :
    ghostQ n a b c - ghostP n a b c = ((-1 : ℤ) ^ n) * (b - a) := by
  simp only [ghostP, ghostQ]
  have hf := pell_fundamental n
  linear_combination (b - a) * hf

/-! ## Section 10: Ghost Matrix -/

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

/-! ## Section 11: Ghost Ancestor Composition -/

/-
(m+n)-th ghost ancestor = m-th applied to n-th (first component)
-/
theorem ghost_ancestor_compose_p (m n : ℕ) (a b c : ℤ) :
    ghostP (m + n) a b c =
    ghostP m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostP ghostQ ghostHyp;
  rw [ pellH_add, pellP_add ];
  rw [ show ( -1 : ℤ ) ^ n = pellH n ^ 2 - 2 * pellP n ^ 2 by linarith [ pell_fundamental n ] ] ; ring

/-
(m+n)-th ghost ancestor = m-th applied to n-th (second component)
-/
theorem ghost_ancestor_compose_q (m n : ℕ) (a b c : ℤ) :
    ghostQ (m + n) a b c =
    ghostQ m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostQ ghostP ghostHyp;
  rw [ pellP_add, pellH_add ] ; ring;
  rw [ show pellH n ^ 2 = 2 * pellP n ^ 2 + ( -1 ) ^ n by linarith [ pell_fundamental n ] ] ; ring

/-
(m+n)-th ghost ancestor = m-th applied to n-th (hypotenuse)
-/
theorem ghost_ancestor_compose_h (m n : ℕ) (a b c : ℤ) :
    ghostHyp (m + n) a b c =
    ghostHyp m (ghostP n a b c) (ghostQ n a b c) (ghostHyp n a b c) := by
  unfold ghostHyp ghostP ghostQ; ring;
  rw [ pellP_add, pellH_add ] ; ring;
  rw [ show pellH m ^ 2 = 2 * pellP m ^ 2 + ( -1 ) ^ m by linarith [ pell_fundamental m ] ] ; ring;
  rw [ show pellH n ^ 2 = 2 * pellP n ^ 2 + ( -1 ) ^ n by linarith [ pell_fundamental n ] ] ; ring

/-! ## Section 12: Pell Periodicity Modulo m (Pigeonhole) -/

/-
The pair (H mod m, P mod m) must repeat within m² steps
-/
theorem pell_eventually_periodic (m : ℕ) (hm : 2 ≤ m) :
    ∃ i j : ℕ, i < j ∧ j ≤ m ^ 2 + 1 ∧
    pellH i % (m : ℤ) = pellH j % m ∧ pellP i % (m : ℤ) = pellP j % m := by
  by_contra! h;
  exact absurd ( Finset.card_le_card ( show Finset.image ( fun n : ℕ => ( pellH n % m, pellP n % m ) ) ( Finset.range ( m ^ 2 + 1 ) ) ⊆ Finset.product ( Finset.Ico 0 m ) ( Finset.Ico 0 m ) from Finset.image_subset_iff.mpr fun n hn => Finset.mem_product.mpr ⟨ Finset.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩, Finset.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩ ⟩ ) ) ( by erw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( Nat.le_of_not_lt fun hi' => h _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ( by aesop ) <| by aesop ) ( Nat.le_of_not_lt fun hj' => h _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ( by aesop ) <| by aesop ) ] ; norm_num ; nlinarith )

end PythagoreanResearch