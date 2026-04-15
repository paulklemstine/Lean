/-
# Berggren General Theorems: B₂ Sequence Properties

## Key results:
1. B₂ leg difference alternation for all n
2. B₂ Pythagorean for all n
3. Companion Pell sequence ≡ 1 (mod 4) for all n
4. Companion Pell strictly increasing and positive

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

/-! ## B₂ Iteration Sequence -/

/-- The B₂ iteration: returns (a_n, b_n, c_n) -/
def b2n : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := b2n n
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-! ## Computational Checks -/

theorem b2n_0 : b2n 0 = (3, 4, 5) := rfl
theorem b2n_1 : b2n 1 = (21, 20, 29) := by native_decide
theorem b2n_2 : b2n 2 = (119, 120, 169) := by native_decide
theorem b2n_3 : b2n 3 = (697, 696, 985) := by native_decide

/-! ## Leg Difference Alternation -/

theorem b2n_leg_diff : ∀ n : ℕ, (b2n n).1 - (b2n n).2.1 = (-1) ^ (n + 1) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2n]
    set t := b2n n with ht
    have : (t.1 + 2 * t.2.1 + 2 * t.2.2) - (2 * t.1 + t.2.1 + 2 * t.2.2) =
           -(t.1 - t.2.1) := by ring
    rw [this, ih]; ring

/-! ## B₂ Pythagorean for all n -/

theorem b2n_pythagorean : ∀ n : ℕ, (b2n n).1 ^ 2 + (b2n n).2.1 ^ 2 = (b2n n).2.2 ^ 2 := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2n]
    set t := b2n n with ht
    nlinarith [sq_nonneg t.1, sq_nonneg t.2.1, sq_nonneg t.2.2,
               sq_nonneg (t.1 - t.2.1), sq_nonneg (t.1 + t.2.1)]

/-! ## B₂ Component Positivity -/

theorem b2n_all_pos : ∀ n : ℕ, 0 < (b2n n).1 ∧ 0 < (b2n n).2.1 ∧ 0 < (b2n n).2.2 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih =>
    simp only [b2n]
    set t := b2n n with ht
    obtain ⟨ha, hb, hc⟩ := ih
    exact ⟨by nlinarith, by nlinarith, by nlinarith⟩

/-! ## Companion Pell Sequence -/

/-- The companion Pell sequence: hypotenuses of B₂ iterates -/
def compPell : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * compPell (n + 1) - compPell n

theorem compPell_0 : compPell 0 = 5 := rfl
theorem compPell_1 : compPell 1 = 29 := rfl
theorem compPell_2 : compPell 2 = 169 := by native_decide
theorem compPell_3 : compPell 3 = 985 := by native_decide

/-! ## CompPell mod 4 -/

theorem compPell_mod4 : ∀ n : ℕ, compPell n % 4 = 1 := by
  intro n
  induction n using compPell.induct with
  | case1 => decide
  | case2 => decide
  | case3 n ih1 ih2 =>
    simp only [compPell]
    omega

/-! ## CompPell Positivity and Growth

We prove positivity and growth together by strong induction. -/

private theorem compPell_pos_growth :
    ∀ n : ℕ, 0 < compPell n ∧ compPell n < compPell (n + 1) := by
  intro n
  induction n using compPell.induct with
  | case1 => constructor <;> decide
  | case2 =>
    constructor
    · decide
    · show compPell 1 < compPell 2; native_decide
  | case3 n ih1 ih2 =>
    obtain ⟨hpos1, hgr1⟩ := ih1
    obtain ⟨hpos2, hgr2⟩ := ih2
    constructor
    · -- compPell (n+2) = 6 * compPell (n+1) - compPell n > 0
      -- since compPell (n+1) > compPell n and compPell (n+1) > 0
      simp only [compPell] at *; nlinarith
    · -- compPell (n+2) < compPell (n+3)
      -- compPell (n+3) = 6 * compPell (n+2) - compPell (n+1)
      -- need: compPell (n+2) < 6 * compPell (n+2) - compPell (n+1)
      -- i.e., compPell (n+1) < 5 * compPell (n+2)
      -- Since compPell (n+2) > compPell (n+1), this is clear.
      simp only [compPell] at *; nlinarith

theorem compPell_pos : ∀ n : ℕ, 0 < compPell n := fun n => (compPell_pos_growth n).1

theorem compPell_growth : ∀ n : ℕ, compPell n < compPell (n + 1) :=
  fun n => (compPell_pos_growth n).2

/-! ## B₂ hypotenuse growth -/

theorem b2n_hyp_growth : ∀ n : ℕ, (b2n n).2.2 < (b2n (n+1)).2.2 := by
  intro n
  have h := b2n_all_pos n
  simp only [b2n]
  set t := b2n n with ht
  obtain ⟨ha, hb, hc⟩ := h
  nlinarith
