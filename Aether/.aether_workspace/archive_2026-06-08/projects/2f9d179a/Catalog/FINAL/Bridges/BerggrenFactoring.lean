import Mathlib

/-! # Berggren Tree and Integer Factoring

The Berggren tree enumerates all primitive Pythagorean triples via three
matrix transformations. This structure can be exploited for integer factoring.

## Research Direction 3.4: Berggren Tree Factoring Algorithms
-/

/-- A Pythagorean triple -/
def IsPythTriple' (a b c : ℤ) : Prop := a^2 + b^2 = c^2

/-- The base triple (3, 4, 5) is Pythagorean -/
theorem base_triple_pyth : IsPythTriple' 3 4 5 := by unfold IsPythTriple'; norm_num

/-- Pythagorean triples are symmetric in a, b -/
theorem pyth_triple_symm {a b c : ℤ} (h : IsPythTriple' a b c) :
    IsPythTriple' b a c := by unfold IsPythTriple' at *; linarith

/-- Scaling preserves Pythagorean triples -/
theorem pyth_triple_scale {a b c : ℤ} (h : IsPythTriple' a b c) (k : ℤ) :
    IsPythTriple' (k * a) (k * b) (k * c) := by
  unfold IsPythTriple' at *; ring_nf; nlinarith [sq_nonneg k]

/-- If d divides both a and b, then d² divides a² + b² -/
theorem sum_two_squares_gcd (a b d : ℤ) (hd : d ∣ a) (hd2 : d ∣ b) :
    d^2 ∣ a^2 + b^2 := by
  obtain ⟨x, rfl⟩ := hd; obtain ⟨y, rfl⟩ := hd2; exact ⟨x^2 + y^2, by ring⟩

/-- Fermat's factoring via difference of squares -/
theorem fermat_factor (n a b : ℤ) (h : n = a^2 - b^2) :
    n = (a - b) * (a + b) := by rw [h]; ring

/-- Connection to factoring: nontrivial GCD gives a factor -/
theorem pyth_factor_connection (n a : ℕ) (_hn : 1 < n) (ha : 1 < Nat.gcd a n)
    (ha2 : Nat.gcd a n < n) : ∃ d, 1 < d ∧ d < n ∧ d ∣ n :=
  ⟨Nat.gcd a n, ha, ha2, Nat.gcd_dvd_right a n⟩

/-- The Lorentz form characterizes Pythagorean triples -/
def lorentzForm (a b c : ℤ) : ℤ := c^2 - a^2 - b^2

theorem pyth_iff_lorentz (a b c : ℤ) :
    IsPythTriple' a b c ↔ lorentzForm a b c = 0 := by
  unfold IsPythTriple' lorentzForm; constructor <;> intro h <;> linarith

/-- Berggren matrix A preserves Pythagorean property -/
theorem berggren_A_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Berggren matrix B preserves Pythagorean property -/
theorem berggren_B_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Berggren matrix C preserves Pythagorean property -/
theorem berggren_C_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Hypotenuse grows under Berggren B -/
theorem berggren_B_hyp_growth (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : c < 2*a + 2*b + 3*c := by linarith

/-- Primitive triple: coprime legs -/
def IsPrimitivePythTriple' (a b c : ℕ) : Prop :=
  IsPythTriple' (a : ℤ) (b : ℤ) (c : ℤ) ∧ Nat.Coprime a b

/-- The base triple (3, 4, 5) is primitive -/
theorem base_triple_primitive : IsPrimitivePythTriple' 3 4 5 :=
  ⟨base_triple_pyth, by decide⟩