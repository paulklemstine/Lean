/-
# Infinite Chess: Advanced Ordinal Arithmetic Theorems

Additional results on ordinal arithmetic and game complexity.
These theorems do not depend on Defs.lean imports.
-/
import Mathlib

open Ordinal

/-! ## Ordinal arithmetic: properties of ω^n hierarchy -/

/-
ω^n is strictly increasing in n.
-/
theorem omega0_pow_strictMono :
    StrictMono (fun n : ℕ => omega0 ^ (n : Ordinal)) := by
  exact fun m n hmn => Ordinal.opow_lt_opow_iff_right ( by exact Ordinal.one_lt_omega0 ) |>.2 <| Nat.cast_lt.2 hmn

/-
The set {ω^n | n : ℕ} is cofinal below ω^ω.
-/
theorem omega0_pow_cofinal (α : Ordinal) (hα : α < omega0 ^ omega0) :
    ∃ n : ℕ, α < omega0 ^ (n : Ordinal) := by
  -- Assume for contradiction that for all n, omega0^n ≤ α.
  by_contra h_contra
  push_neg at h_contra
  -- Then, since omega0^omega0 = iSup_{n:ℕ} omega0^n, we have omega0^omega0 ≤ α.
  have h_omega0_omega0_le_alpha : omega0 ^ omega0 ≤ α := by
    rw [ Ordinal.opow_le_iff_le_log ] <;> norm_num;
    · refine' le_of_forall_lt fun n hn => _;
      refine' lt_of_not_ge fun h => _;
      -- Since $n < \omega$, there exists some $m \in \mathbb{N}$ such that $n = m$.
      obtain ⟨m, rfl⟩ : ∃ m : ℕ, n = m := by
        exact lt_omega0.mp hn;
      exact not_lt_of_ge h ( lt_of_lt_of_le ( by aesop ) ( Ordinal.le_log_of_opow_le ( by aesop ) ( h_contra ( m + 1 ) ) ) );
    · exact ne_of_gt ( lt_of_lt_of_le ( by simp +decide ) ( h_contra 0 ) )
  -- This contradicts hα.
  exact hα.not_ge h_omega0_omega0_le_alpha

/-
ω + ω = ω · 2.
-/
theorem omega0_add_omega0 : omega0 + omega0 = omega0 * 2 := by
  rw [ show ( 2 : Ordinal ) = 1 + 1 by norm_num, mul_add, mul_one ]

/-
ω · n < ω² for any finite n.
-/
theorem omega0_mul_nat_lt_sq (n : ℕ) :
    omega0 * (n : Ordinal) < omega0 ^ 2 := by
  rw [ pow_two ] ; exact mul_lt_mul_of_pos_left ( by aesop ) ( Ordinal.omega0_pos ) ;

/-
For n ≥ 1, ω^n is a limit ordinal (not a successor).
-/
theorem omega0_pow_isSuccPrelimit (n : ℕ) (hn : 1 ≤ n) :
    Order.IsSuccPrelimit (omega0 ^ (n : Ordinal)) := by
  induction' n with n ih <;> simp_all +decide [ pow_succ' ];
  rcases n with ( _ | n ) <;> simp_all +decide [ Order.IsSuccPrelimit ];
  · intro b hb; rcases hb with ⟨ hb₁, hb₂ ⟩ ; rcases Ordinal.lt_omega0.1 hb₁ with ⟨ n, rfl ⟩ ; simp_all +decide [ Order.IsSuccPrelimit ] ;
    exact absurd ( @hb₂ ( n + 1 ) ( by norm_cast; linarith ) ) ( by exact not_le_of_gt ( by simpa using Ordinal.nat_lt_omega0 ( n + 1 ) ) );
  · intro b;
    contrapose! ih;
    refine' ⟨ b / ω, _, _ ⟩;
    · rw [ Ordinal.div_lt ] <;> norm_num;
      convert ih.1 using 1 ; rw [ ← pow_succ' ];
      rw [ pow_succ ];
    · intro c hc₁ hc₂; have := ih.2; simp_all +decide [ Ordinal.div_lt ] ;
      refine' not_lt_of_ge ( this hc₁ ) _;
      refine' lt_of_lt_of_le ( mul_lt_mul_of_pos_left hc₂ ( Ordinal.omega0_pos ) ) _;
      rw [ ← pow_succ' ];
      rw [ pow_succ ]

/-! ## Connection to Cantor Normal Form

Every ordinal below ε₀ has a unique Cantor normal form
  α = ω^β₁ · c₁ + ω^β₂ · c₂ + ... + ω^βₖ · cₖ
where β₁ > β₂ > ... > βₖ and each cᵢ is a positive natural number.
For game values, this means every game of finite "nesting depth"
has a complexity expressible in terms of the ω^n hierarchy. -/

/-
The ordinal ω · n + m for natural n, m gives the "two-level" game values:
    first solve m finite moves, then n copies of an ω-game.
-/
theorem omega0_mul_add_nat (n m : ℕ) :
    omega0 * (n : Ordinal) + (m : Ordinal) < omega0 * ((n : Ordinal) + 1) := by
  rw [ mul_add, mul_one ];
  exact lt_of_lt_of_le ( add_lt_add_right ( Nat.cast_lt.2 <| Nat.lt_succ_self m ) _ ) ( by simp +decide )

/-
ω^0 = 1
-/
theorem omega0_pow_zero : omega0 ^ (0 : Ordinal) = 1 := by
  norm_num +zetaDelta at *

/-
ω^1 = ω
-/
theorem omega0_pow_one : omega0 ^ (1 : Ordinal) = omega0 := by
  norm_num +zetaDelta at *

/-
ω^(n+1) > ω^n for positive base
-/
theorem omega0_pow_succ_gt (n : ℕ) :
    omega0 ^ (n : Ordinal) < omega0 ^ ((n : Ordinal) + 1) := by
  exact_mod_cast omega0_pow_strictMono ( Nat.lt_succ_self n )

/-- ω^ω > ω^n for any finite n -/
theorem omega0_pow_omega0_gt' (n : ℕ) :
    omega0 ^ (n : Ordinal) < omega0 ^ omega0 := by
  exact (Ordinal.opow_lt_opow_iff_right Ordinal.one_lt_omega0).2 (Ordinal.nat_lt_omega0 n)