import Mathlib

/-! # CatalogBuild.Speculative.BerggrenGeneralTheorems

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 20
-/

/-- [Section: # CatalogBuild.Speculative.BerggrenGeneralTheorems
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 20] -/
def b2_step (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 + t.2.1 + 2 * t.2.2,
   2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- [Section: # CatalogBuild.Speculative.BerggrenGeneralTheorems
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 20] -/
def b2n : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => b2_step (b2n n)

theorem b2n_pythagorean : ∀ n : ℕ, (b2n n).1 ^ 2 + (b2n n).2.1 ^ 2 = (b2n n).2.2 ^ 2 := by
  intro n; induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2n, b2_step]
    nlinarith [ih]

theorem b2n_leg_diff : ∀ n : ℕ, (b2n n).1 - (b2n n).2.1 = (-1) ^ (n + 1) := by
  intro n; induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2n, b2_step]
    grind

def pellPair : ℕ → ℤ × ℤ
  | 0 => (1, 0)
  | n + 1 => (3 * (pellPair n).1 + 4 * (pellPair n).2,
              2 * (pellPair n).1 + 3 * (pellPair n).2)

theorem pell_equation_all (n : ℕ) : (pellPair n).1 ^ 2 - 2 * (pellPair n).2 ^ 2 = 1 := by
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [pellPair]
    nlinarith [ih]

theorem b2n_pos : ∀ n : ℕ, 0 < (b2n n).1 ∧ 0 < (b2n n).2.1 ∧ 0 < (b2n n).2.2 := by
  intro n; induction n with
  | zero => simp [b2n]
  | succ n ih =>
    simp only [b2n, b2_step]
    obtain ⟨h1, h2, h3⟩ := ih
    exact ⟨by linarith, by linarith, by linarith⟩

theorem b2_hyp_growth (n : ℕ) : (b2n n).2.2 < (b2n (n + 1)).2.2 := by
  simp only [b2n, b2_step]
  obtain ⟨h1, h2, h3⟩ := b2n_pos n
  linarith

def compPell : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * compPell (n + 1) - compPell n

theorem compPell_mod4 : ∀ n : ℕ, compPell n % 4 = 1 := by
  intro n
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => native_decide
    | 1 => native_decide
    | n + 2 =>
      simp only [compPell]
      have h1 := ih (n + 1) (by omega)
      have h0 := ih n (by omega)
      omega

theorem B2_preserves_pythagorean (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 = (2*a + 2*b + 3*c)^2 := by
  nlinarith [h]

theorem B2_char_poly_factored (x : ℤ) :
    x^3 - 5*x^2 - 5*x + 1 = (x + 1) * (x^2 - 6*x + 1) := by ring

theorem a_branch_formula_pyth (n : ℕ) :
    (2 * (n : ℤ) + 3) ^ 2 + (2 * (↑n + 1) * (↑n + 2)) ^ 2 = (2 * ↑n ^ 2 + 6 * ↑n + 5) ^ 2 := by
  ring

theorem a_branch_hyp_minus_leg (n : ℕ) :
    2 * (n : ℤ) ^ 2 + 6 * ↑n + 5 - 2 * (↑n + 1) * (↑n + 2) = 1 := by ring

theorem a_branch_odd (n : ℕ) : Odd (2 * n + 3) := ⟨n + 1, by omega⟩

theorem a_branch_even (n : ℕ) : Even (2 * (n + 1) * (n + 2)) := ⟨(n + 1) * (n + 2), by ring⟩

theorem compPell_recurrence (n : ℕ) :
    compPell (n + 2) = 6 * compPell (n + 1) - compPell n := by
  simp [compPell]

/-- compPell is positive and strictly increasing, proved simultaneously -/
theorem compPell_pos_and_growth :
    ∀ n : ℕ, 0 < compPell n ∧ compPell n < compPell (n + 1) := by
  intro n
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => constructor <;> simp [compPell]
    | 1 => exact ⟨by simp [compPell], by simp [compPell]⟩
    | n + 2 =>
      constructor
      · -- Positivity: compPell (n+2) = 6 * compPell (n+1) - compPell n
        simp only [compPell]
        have ⟨hp1, hg1⟩ := ih (n + 1) (by omega)
        have ⟨hp0, _⟩ := ih n (by omega)
        -- compPell n < compPell (n+1) < 6 * compPell (n+1)
        linarith
      · -- Growth: compPell (n+2) < compPell (n+3)
        -- compPell (n+3) = 6 * compPell (n+2) - compPell (n+1)
        -- compPell (n+2) = 6 * compPell (n+1) - compPell n
        simp only [compPell]
        have ⟨hp1, hg1⟩ := ih (n + 1) (by omega)
        have ⟨hp0, _⟩ := ih n (by omega)
        linarith

theorem compPell_pos' : ∀ n : ℕ, 0 < compPell n := fun n => (compPell_pos_and_growth n).1

theorem compPell_growth' : ∀ n : ℕ, compPell n < compPell (n + 1) :=
  fun n => (compPell_pos_and_growth n).2