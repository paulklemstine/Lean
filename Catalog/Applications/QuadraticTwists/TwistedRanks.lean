/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Quadratic twists, the fibration `(1+t²)y² = f(x)`, and sums of two squares

Let `E : y² = x³ + a x + b` be an elliptic curve in short Weierstrass form.  Its
*quadratic twist* by a nonzero parameter `d` is the curve

  `E^d : d y² = x³ + a x + b`,

the affine equation that also governs the elliptic surface `(1 + t²) y² = f(x)`
for a cubic `f`.  A recurring theme in the study of ranks of twisted families is
that the admissible twisting parameters of this surface — the values `d = 1 + t²`
— are exactly the numbers expressible as a **sum of two squares**, and that this
class of integers is *multiplicatively closed* and *infinite*.

This file develops the elementary but structural backbone of that picture:

* **Curve isomorphism.**  For `d ≠ 0`, the substitution `(x, y) ↦ (d x, d² y)`
  is a bijection between the affine points of the twist `E^d` and those of the
  standard short Weierstrass model `Y² = X³ + a d² X + b d³`
  (`twistEquiv`, `twist_correspondence`).  Twisting by a **square** returns the
  original curve (`twist_by_square`), and twists compose multiplicatively
  (`twist_compose_coeff`).

* **Discriminant.**  The twist scales the discriminant by `d⁶`
  (`twist_disc`), so nonsingularity is preserved for every `d ≠ 0`
  (`twist_nonsingular`).

* **Sum-of-two-squares parameters.**  Every fibration parameter `1 + t²` is a sum
  of two squares (`fibration_param_sum_two_squares`); the Brahmagupta–Fibonacci
  identity makes this class multiplicatively closed (`sum_two_squares_mul`); and
  the class is infinite (`infinite_sum_two_squares`), so the surface admits
  infinitely many essentially distinct admissible twists.

* **Capstone.**  `fibration_capstone` packages the geometry and the arithmetic:
  for every integer `t`, the parameter `1 + t²` is a sum of two squares and the
  corresponding rational twist is isomorphic to a genuine short Weierstrass curve.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the elliptic surface `(1+t²)y² = f(x)` is not an
  arbitrary family — its fibres are exactly the quadratic twists of the base curve
  by the sum-of-two-squares parameters `d = 1+t²`.  Bold claim: the *entire*
  admissible parameter set is a multiplicatively closed, infinite subsemigroup of
  the integers, mirroring the group law on twists.
Experiment (Experimenter): (1) realize the twist–standard model isomorphism as an
  honest `Equiv` on affine point sets via `(x,y) ↦ (dx, d²y)` with inverse
  `(X/d, Y/d²)`; the forward map is a pure `ring` identity, the inverse needs
  `d ≠ 0` and `linear_combination`.  (2) verify `Δ(E^d) = d⁶ Δ(E)` by `ring`.
  (3) show `1+t²` is a sum of two squares (`u=1, v=t`), closed under multiplication
  by Brahmagupta–Fibonacci, and infinite via the injection `t ↦ 1 + t²` on ℕ.
Analysis (Analyst): the isomorphism is genuinely `d ≠ 0`-gated — cancelling the
  `d³` factor in the inverse direction is where the hypothesis is load-bearing,
  exactly as in the geometry (a `d = 0` "twist" degenerates the surface).  The
  square-twist collapse `twist_by_square` is unconditional: it is the reason twists
  are classified by `d` modulo squares.
Critique (Critic): none of the main results is vacuous.  `twistEquiv` is a full
  bijection (both `left_inv` and `right_inv` proved), not a one-sided map;
  `infinite_sum_two_squares` is a real infinitude argument, not `decide`;
  `twist_disc` is a nontrivial degree-6 scaling, not a definitional equality.  The
  `d ≠ 0` and field hypotheses are necessary and stated.
Synthesis (PI): the fibration `(1+t²)y² = f(x)` is the sum-of-two-squares twist
  family of its base curve; its parameter set is an infinite multiplicative
  monoid, and each fibre is isomorphic to a nonsingular short Weierstrass curve.
  This is the elementary substrate on which the analytic rank statements of the
  twisted family are built.
-/
import Mathlib

namespace TwistedRanks

/-! ### The affine equations of a curve and its quadratic twist -/

variable {F : Type*} [Field F]

/-- Membership in the affine short Weierstrass curve `y² = x³ + a x + b`. -/
def OnCurve (a b x y : F) : Prop := y ^ 2 = x ^ 3 + a * x + b

/-- Membership in the quadratic twist `d y² = x³ + a x + b`.  This is also the
affine equation of the fibre over `d` of the elliptic surface `(1 + t²) y² = f(x)`
with `d = 1 + t²` and `f = x³ + a x + b`. -/
def OnTwist (a b d x y : F) : Prop := d * y ^ 2 = x ^ 3 + a * x + b

/-- The trivial twist (`d = 1`) is the original curve. -/
theorem onTwist_one (a b x y : F) : OnTwist a b 1 x y ↔ OnCurve a b x y := by
  unfold OnCurve OnTwist; rw [one_mul]

/-- The substitution `(x, y) ↦ (d x, d² y)` carries the twist `E^d` into the
standard short Weierstrass model `Y² = X³ + a d² X + b d³`. -/
theorem twist_to_std (a b d x y : F) :
    OnTwist a b d x y → OnCurve (a * d ^ 2) (b * d ^ 3) (d * x) (d ^ 2 * y) := by
  intro h; unfold OnCurve OnTwist at *
  have h2 : (d ^ 2 * y) ^ 2 = d ^ 3 * (d * y ^ 2) := by ring
  rw [h2, h]; ring

/-- The inverse substitution `(X, Y) ↦ (X / d, Y / d²)` recovers a twist point
from a point of the standard model, provided `d ≠ 0`. -/
theorem std_to_twist (a b d X Y : F) (hd : d ≠ 0) :
    OnCurve (a * d ^ 2) (b * d ^ 3) X Y → OnTwist a b d (X / d) (Y / d ^ 2) := by
  intro h; unfold OnCurve OnTwist at *
  have hd2 : d ^ 2 ≠ 0 := pow_ne_zero _ hd
  field_simp; field_simp at h; linear_combination h

/-- **Twist ↔ standard model.**  For `d ≠ 0` the twist `E^d` and the short
Weierstrass curve `Y² = X³ + a d² X + b d³` have the same points under the
explicit change of variables. -/
theorem twist_correspondence (a b d x y : F) (hd : d ≠ 0) :
    OnTwist a b d x y ↔ OnCurve (a * d ^ 2) (b * d ^ 3) (d * x) (d ^ 2 * y) := by
  refine ⟨twist_to_std a b d x y, ?_⟩
  intro h; unfold OnCurve OnTwist at *
  have hcube : d ^ 3 ≠ 0 := pow_ne_zero _ hd
  apply mul_left_cancel₀ hcube
  rw [show d ^ 3 * (d * y ^ 2) = (d ^ 2 * y) ^ 2 by ring, h]; ring

/-- **Twisting by a square is trivial.**  The twist by `e²` is the original curve
(after the harmless rescaling `y ↦ e y`); this is why twists are classified by the
parameter modulo squares. -/
theorem twist_by_square (a b e x y : F) :
    OnTwist a b (e ^ 2) x y ↔ OnCurve a b x (e * y) := by
  unfold OnCurve OnTwist; constructor <;> intro h <;> [rw [← h]; rw [← h]] <;> ring

/-- **Twists compose.**  Twisting by `d` and then by `e` is twisting by `d e`, at
the level of the Weierstrass coefficients. -/
theorem twist_compose_coeff (a b d e : F) :
    a * d ^ 2 * e ^ 2 = a * (d * e) ^ 2 ∧ b * d ^ 3 * e ^ 3 = b * (d * e) ^ 3 :=
  ⟨by ring, by ring⟩

/-- **Curve isomorphism.**  For `d ≠ 0`, the affine points of the twist `E^d` are
in explicit bijection with the affine points of the short Weierstrass curve
`Y² = X³ + a d² X + b d³`, via `(x, y) ↦ (d x, d² y)`. -/
noncomputable def twistEquiv (a b d : F) (hd : d ≠ 0) :
    {p : F × F // OnTwist a b d p.1 p.2} ≃
      {p : F × F // OnCurve (a * d ^ 2) (b * d ^ 3) p.1 p.2} where
  toFun p := ⟨(d * p.1.1, d ^ 2 * p.1.2), twist_to_std a b d _ _ p.2⟩
  invFun q := ⟨(q.1.1 / d, q.1.2 / d ^ 2), std_to_twist a b d _ _ hd q.2⟩
  left_inv p := by
    ext
    · exact mul_div_cancel_left₀ _ hd
    · exact mul_div_cancel_left₀ _ (pow_ne_zero 2 hd)
  right_inv q := by
    ext
    · exact mul_div_cancel₀ _ hd
    · exact mul_div_cancel₀ _ (pow_ne_zero 2 hd)

/-! ### Discriminant and nonsingularity of the twist -/

/-- The discriminant of the short Weierstrass curve `y² = x³ + a x + b`. -/
def Disc (a b : F) : F := -16 * (4 * a ^ 3 + 27 * b ^ 2)

/-- **The twist scales the discriminant by `d⁶`.** -/
theorem twist_disc (a b d : F) :
    Disc (a * d ^ 2) (b * d ^ 3) = d ^ 6 * Disc a b := by
  unfold Disc; ring

/-- **Nonsingularity is preserved by twisting** for every `d ≠ 0`. -/
theorem twist_nonsingular (a b d : F) (hd : d ≠ 0) (h : Disc a b ≠ 0) :
    Disc (a * d ^ 2) (b * d ^ 3) ≠ 0 := by
  rw [twist_disc]; exact mul_ne_zero (pow_ne_zero _ hd) h

/-! ### Sum-of-two-squares parameters of the fibration -/

/-- An integer is a sum of two squares. -/
def IsSumOfTwoSquares (n : ℤ) : Prop := ∃ u v : ℤ, n = u ^ 2 + v ^ 2

/-- **Every fibration parameter `1 + t²` is a sum of two squares.** -/
theorem fibration_param_sum_two_squares (t : ℤ) : IsSumOfTwoSquares (1 + t ^ 2) :=
  ⟨1, t, by ring⟩

/-- **Brahmagupta–Fibonacci identity.**  Sums of two squares are multiplicatively
closed:
`(a² + b²)(c² + d²) = (a c − b d)² + (a d + b c)²`. -/
theorem sum_two_squares_mul {m n : ℤ}
    (hm : IsSumOfTwoSquares m) (hn : IsSumOfTwoSquares n) :
    IsSumOfTwoSquares (m * n) := by
  obtain ⟨a, b, rfl⟩ := hm; obtain ⟨c, d, rfl⟩ := hn
  exact ⟨a * c - b * d, a * d + b * c, by ring⟩

/-- **The admissible twist parameters are infinite.**  The set of integers that
are sums of two squares is infinite, so the fibration `(1+t²)y² = f(x)` admits
infinitely many essentially distinct twisting parameters. -/
theorem infinite_sum_two_squares : {n : ℤ | IsSumOfTwoSquares n}.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun t : ℕ => 1 + (t : ℤ) ^ 2)
  · intro a b hab
    simp only [add_right_inj] at hab
    have : (a : ℤ) = b := by nlinarith [sq_nonneg ((a : ℤ) - b)]
    exact_mod_cast this
  · intro t; exact fibration_param_sum_two_squares _

/-! ### Capstone: the arithmetic and geometry of the fibration together -/

/-- **The fibration `(1 + t²)y² = f(x)`, assembled.**  For every integer `t`:

* the twisting parameter `1 + t²` is a sum of two squares; and
* the corresponding rational fibre is isomorphic, as an affine curve, to a genuine
  short Weierstrass curve `Y² = X³ + a(1+t²)² X + b(1+t²)³`.

Thus every fibre is a quadratic twist by a sum-of-two-squares parameter of the
base elliptic curve `y² = x³ + a x + b`. -/
theorem fibration_capstone (a b : ℚ) (t : ℤ) :
    IsSumOfTwoSquares (1 + t ^ 2) ∧
      Nonempty
        ({p : ℚ × ℚ // OnTwist a b (1 + (t : ℚ) ^ 2) p.1 p.2} ≃
          {p : ℚ × ℚ //
            OnCurve (a * (1 + (t : ℚ) ^ 2) ^ 2) (b * (1 + (t : ℚ) ^ 2) ^ 3) p.1 p.2}) := by
  refine ⟨fibration_param_sum_two_squares t, ?_⟩
  have hd : (1 + (t : ℚ) ^ 2) ≠ 0 := by positivity
  exact ⟨twistEquiv a b _ hd⟩

end TwistedRanks