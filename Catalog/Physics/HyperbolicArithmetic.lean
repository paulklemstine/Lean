import Mathlib

/-!
# A Möbius–Diophantine bridge

The one-dimensional diameter `(-1,1)` of the Poincaré disk carries the Möbius
(or Einstein velocity) sum `x ⊞ y = (x+y)/(1+xy)`.  Iterating translation by
`1/2` admits homogeneous integer coordinates.  The same coordinates satisfy
an exact exponential norm equation, connecting hyperbolic translation with
Diophantine arithmetic.
-/

namespace HyperbolicArithmetic

/-- Möbius addition on rational points of a diameter of the Poincaré disk. -/
def mobiusAdd (x y : ℚ) : ℚ := (x + y) / (1 + x * y)

/-- Homogeneous integer coordinates for repeated translation by `1/2`. -/
def coordinates : ℕ → ℤ × ℤ
  | 0 => (0, 1)
  | n + 1 =>
      let p := coordinates n
      (2 * p.1 + p.2, p.1 + 2 * p.2)

/-- Homogeneous numerator of the orbit. -/
def numerator (n : ℕ) : ℤ := (coordinates n).1

/-- Homogeneous denominator of the orbit. -/
def denominator (n : ℕ) : ℤ := (coordinates n).2

@[simp] lemma numerator_zero : numerator 0 = 0 := rfl
@[simp] lemma denominator_zero : denominator 0 = 1 := rfl
@[simp] lemma numerator_succ (n : ℕ) : numerator (n + 1) = 2 * numerator n + denominator n := by
  simp [numerator, denominator, coordinates]
@[simp] lemma denominator_succ (n : ℕ) : denominator (n + 1) = numerator n + 2 * denominator n := by
  simp [numerator, denominator, coordinates]

/-
The denominator coordinates are strictly positive.
-/
lemma denominator_pos (n : ℕ) : 0 < denominator n := by
  -- By definition of coordinates, we know that both the numerator and denominator are positive for all $n$.
  have h_pos : ∀ n, 0 ≤ numerator n ∧ 0 < denominator n := by
    intro n; induction n <;> simp_all +decide [ numerator_succ, denominator_succ ] ;
    constructor <;> linarith;
  exact h_pos _ |>.2

/-
The numerator coordinates are nonnegative.
-/
lemma numerator_nonneg (n : ℕ) : 0 ≤ numerator n := by
  -- We will prove this inductively on n.
  induction' n with n ih;
  · decide +revert;
  · exact add_nonneg ( mul_nonneg zero_le_two ih ) ( denominator_pos n |> le_of_lt )

/-
The orbit coordinates have an exact exponential closed form.
-/
lemma coordinate_closed_form (n : ℕ) :
    2 * numerator n = (3 : ℤ) ^ n - 1 ∧
    2 * denominator n = (3 : ℤ) ^ n + 1 := by
  induction n <;> simp_all +decide [ pow_succ' ];
  grind

/-
The Lorentzian norm of the integer coordinates is exactly `3^n`.
-/
lemma lorentz_norm (n : ℕ) :
    denominator n ^ 2 - numerator n ^ 2 = (3 : ℤ) ^ n := by
  induction n <;> simp_all +decide [ pow_succ' ] ; nlinarith;

/-
Every orbit point lies strictly inside the rational Poincaré diameter.
-/
lemma orbit_in_disk (n : ℕ) :
    |(numerator n : ℚ) / denominator n| < 1 := by
  rw [ abs_div ];
  rw [ div_lt_iff₀ ] <;> norm_cast <;> norm_num [ denominator_pos, numerator_nonneg ];
  · rw [ abs_of_nonneg, abs_of_nonneg ] <;> nlinarith [ numerator_nonneg n, denominator_pos n, lorentz_norm n, pow_pos ( show 0 < 3 by decide ) n ];
  · exact ne_of_gt ( denominator_pos n )

/-
One recurrence step is exactly Möbius translation by `1/2`.
-/
lemma orbit_step (n : ℕ) :
    ((numerator (n + 1) : ℚ) / denominator (n + 1)) =
      mobiusAdd ((numerator n : ℚ) / denominator n) (1 / 2) := by
  unfold mobiusAdd;
  simp +zetaDelta at *;
  rw [ div_eq_div_iff ] <;> ring;
  · simpa [ ne_of_gt ( HyperbolicArithmetic.denominator_pos n ) ] using by ring;
  · exact mod_cast ne_of_gt ( add_pos_of_nonneg_of_pos ( numerator_nonneg n ) ( mul_pos ( denominator_pos n ) zero_lt_two ) );
  · exact ne_of_gt ( add_pos_of_pos_of_nonneg zero_lt_one ( mul_nonneg ( mul_nonneg ( mod_cast numerator_nonneg n ) ( inv_nonneg.mpr ( mod_cast denominator_pos n |> le_of_lt ) ) ) ( by norm_num ) ) )

/--
**Möbius–Diophantine bridge.**  Iterated hyperbolic translation by the rational
point `1/2` stays in the Poincaré disk, is represented by an integral linear
recurrence, and its homogeneous coordinates solve the exponential norm equation
`b² - a² = 3ⁿ` at every step.
-/
theorem hyperbolic_translation_diophantine_bridge (n : ℕ) :
    |(numerator n : ℚ) / denominator n| < 1 ∧
    ((numerator (n + 1) : ℚ) / denominator (n + 1)) =
      mobiusAdd ((numerator n : ℚ) / denominator n) (1 / 2) ∧
    denominator n ^ 2 - numerator n ^ 2 = (3 : ℤ) ^ n ∧
    2 * numerator n = (3 : ℤ) ^ n - 1 ∧
    2 * denominator n = (3 : ℤ) ^ n + 1 := by
  exact ⟨orbit_in_disk n, orbit_step n, lorentz_norm n,
    (coordinate_closed_form n).1, (coordinate_closed_form n).2⟩

end HyperbolicArithmetic