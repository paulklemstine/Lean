/-! # CatalogBuild.Pythagorean.Berggren.BerggrenPellClosedForm

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 30
-/

import Mathlib

/-- [Section: ## Section 1: Pell Sequence Definitions] -/
def pellX : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellX (n + 1) - pellX n


def pellY : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 6 * pellY (n + 1) - pellY n


/-- [Section: ## Section 2: Basic Values] -/
theorem pellX_2 : pellX 2 = 17 := by native_decide

theorem pellX_3 : pellX 3 = 99 := by native_decide

theorem pellX_4 : pellX 4 = 577 := by native_decide

@[simp] theorem pellY_0 : pellY 0 = 0 := rfl
@[simp] theorem pellY_1 : pellY 1 = 1 := rfl

theorem pellY_2 : pellY 2 = 6 := by native_decide

theorem pellY_3 : pellY 3 = 35 := by native_decide

theorem pellY_4 : pellY 4 = 204 := by native_decide


/-- [Section: ## Section 3: Recurrence Relations] -/
theorem pellX_rec (n : ℕ) : pellX (n + 2) = 6 * pellX (n + 1) - pellX n := rfl

theorem pellY_rec (n : ℕ) : pellY (n + 2) = 6 * pellY (n + 1) - pellY n := rfl


/-- The fundamental Pell identity: pellX(n)² - 8·pellY(n)² = 1 -/
theorem pell_identity (n : ℕ) : pellX n ^ 2 - 8 * pellY n ^ 2 = 1 := (pell_both n).1


/-- The cross identity: pellX(n+1)·pellX(n) - 8·pellY(n+1)·pellY(n) = 3 -/
theorem pell_cross (n : ℕ) : pellX (n+1) * pellX n - 8 * pellY (n+1) * pellY n = 3 :=
  (pell_both n).2


/-- [Section: ## Section 5: Pell Cross Identity (alternate form)] -/
theorem pell_cross_identity (n : ℕ) :
    pellX (n + 1) * pellY n - pellX n * pellY (n + 1) = -1 := by
  induction' n with n ih <;> norm_num [ pellX_rec, pellY_rec ] at * ; linarith


/-- [Section: ## Section 6: Positivity and Growth] -/
theorem pellX_pos (n : ℕ) : 0 < pellX n := (pellX_pos_and_mono n).1

theorem pellX_strict_mono (n : ℕ) : pellX n < pellX (n + 1) := (pellX_pos_and_mono n).2


theorem pellY_nonneg (n : ℕ) : 0 ≤ pellY n := by
  -- We will prove this by induction on $n$.
  have h_ind : ∀ n, 0 ≤ pellY n ∧ pellY n < pellY (n + 1) := by
    intro n; induction n <;> simp_all +decide [ pellY_rec ] ;
    constructor <;> linarith;
  exact h_ind n |>.1


theorem pellY_pos (n : ℕ) (hn : 0 < n) : 0 < pellY n := by
  induction hn <;> simp +decide [ *, pellY_rec ];
  rename_i k hk ih;
  -- By the properties of the Pell sequence, we know that $pellY (k + 1) > pellY k$.
  have h_pellY_inc : ∀ k, pellY (k + 1) > pellY k := by
    intro k; induction' k with k ih <;> simp_all +decide [ pellY_rec ] ;
    linarith [ pellY_nonneg k ];
  linarith [ h_pellY_inc k ]


theorem pellY_strict_mono (n : ℕ) : pellY n < pellY (n + 1) := by
  induction' n with n ih <;> norm_num [ pellY ] at *;
  linarith [ pellY_nonneg n ]


/-- [Section: ## Section 7: Matrix Form] -/
def pellMatrix : Matrix (Fin 2) (Fin 2) ℤ := !![6, -1; 1, 0]

theorem pellMatrix_det : det pellMatrix = 1 := by native_decide


theorem BN₂_trace : trace BN₂ = 5 := by native_decide

theorem BN₂_det : det BN₂ = -1 := by native_decide

theorem BN₂_sq_trace : trace (BN₂ ^ 2) = 35 := by native_decide

theorem BN₂_cube_trace : trace (BN₂ ^ 3) = 197 := by native_decide


/-- tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ for n = 0,1,2,3 -/
theorem traceB2_pellX_connection :
    trace (BN₂ ^ 0) = 2 * pellX 0 + (-1 : ℤ)^0 ∧
    trace (BN₂ ^ 1) = 2 * pellX 1 + (-1 : ℤ)^1 ∧
    trace (BN₂ ^ 2) = 2 * pellX 2 + (-1 : ℤ)^2 ∧
    trace (BN₂ ^ 3) = 2 * pellX 3 + (-1 : ℤ)^3 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide


/-- [Section: ## Section 9: Addition Formulas (conjectured)] -/
theorem pellX_add (m n : ℕ) :
    pellX (m + n) = pellX m * pellX n + 8 * pellY m * pellY n := by
  -- By induction on $n$, we can show that the addition formula holds.
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with _ | _ | n;
  · norm_num [ pellX_0, pellY_0 ];
  · grind +suggestions;
  · erw [ show m + ( n + 2 ) = ( m + n ) + 2 from by ring, pellX_rec, ih _ ( by linarith ) m ];
    have := ih n ( by linarith ) m; have := ih ( n + 1 ) ( by linarith ) m; simp_all +decide [ Nat.add_assoc, pellX_rec, pellY_rec ] ; ring;


theorem pellY_add (m n : ℕ) :
    pellY (m + n) = pellX m * pellY n + pellY m * pellX n := by
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with ( _ | _ | n );
  · norm_num [ pellX_0, pellY_0 ];
  · grind +suggestions;
  · have := ih n ( by linarith ) ( m + 1 ) ; have := ih ( n + 1 ) ( by linarith ) m ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    have := ih n ( by linarith ) ( m + 2 ) ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    have := pellX_rec n; have := pellY_rec n; have := pellX_rec m; have := pellY_rec m; norm_num [ pellX, pellY ] at * ; linarith;


/-- B₂³ = 5·B₂² + 5·B₂ - I (Cayley-Hamilton) -/
theorem BN₂_cayley_hamilton : BN₂ ^ 3 = 5 • BN₂ ^ 2 + 5 • BN₂ - 1 := by
  native_decide


/-- Consequence: trace satisfies tr(n+3) = 5·tr(n+2) + 5·tr(n+1) - tr(n) -/
theorem BN₂_trace_recurrence :
    trace (BN₂ ^ 4) = 5 * trace (BN₂ ^ 3) + 5 * trace (BN₂ ^ 2) - trace (BN₂ ^ 1) := by
  native_decide


/-- [Section: ## Section 10: Cayley-Hamilton for B₂] -/
theorem pellX_ge_one (n : ℕ) : 1 ≤ pellX n := by
  linarith [pellX_pos n]
