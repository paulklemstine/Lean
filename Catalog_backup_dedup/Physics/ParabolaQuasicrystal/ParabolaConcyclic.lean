import Mathlib

/-!
# Parabola-Circumscribed Quadrilaterals: the Concyclicity Condition

A quadrilateral with vertices `(a, a²), (b, b²), (c, c²), (d, d²)` on the standard
parabola `y = x²` is *inscribed in a circle* (concyclic) **iff** the abscissae sum
to zero: `a + b + c + d = 0`.

This is the algebraic heart of "parabola-circumscribed quadrilaterals": substituting
`y = x²` into a circle `x² + y² + g·x + h·y + k = 0` yields a quartic
`t⁴ + (1+h)·t² + g·t + k = 0` whose cubic coefficient vanishes, so by Vieta the four
roots (the vertices' abscissae) sum to zero.

## Main results

* `ParabolaCircle.root_pair_relation` : the divided-difference identity for two
  distinct vertices on a common circle.
* `parabola_concyclic_sum_zero` : four distinct concyclic vertices have `a+b+c+d=0`.
* `parabola_sum_zero_concyclic` : conversely `a+b+c+d=0` exhibits a circle through
  all four points.

-- !-- Lab Notes -- !--
Hypothesis H1 (geometry): the locus condition for four parabola points to be
concyclic is purely the symmetric-function constraint `e₁ = a+b+c+d = 0`.
Experiment: substitute `y=t²` into the generic circle; the `t³` coefficient is
forced to `0` because the circle's `x²` and `y²` coefficients are equal (=1).
Outcome: confirmed.  The cleanest Lean route avoids polynomial/Vieta machinery and
instead uses the divided-difference relation `R(x,y)=0` (see
`ParabolaCircle.root_pair_relation`); taking three relations sharing a vertex `a`
and eliminating the unknown circle coefficients `g, 1+h` collapses to
`(c-d)·(a+b+c+d)=0`, whence the result by distinctness.
Failure analysis: a direct `nlinarith` on the four quartic equations is brittle;
the divided-difference factorisation is the load-bearing idea.
-/

namespace ParabolaConcyclic

/-- A real `t` is a "circle abscissa" for the circle `x² + y² + g·x + h·y + k = 0`
when the parabola point `(t, t²)` lies on that circle, i.e. it is a root of the
quartic obtained by substituting `y = t²`. -/
def OnParabolaCircle (g h k t : ℝ) : Prop :=
  t ^ 4 + (1 + h) * t ^ 2 + g * t + k = 0

/-- `OnParabolaCircle` is exactly the statement that `(t, t²)` lies on the circle
`x² + y² + g·x + h·y + k = 0`. -/
theorem onParabolaCircle_iff (g h k t : ℝ) :
    OnParabolaCircle g h k t ↔
      t ^ 2 + (t ^ 2) ^ 2 + g * t + h * (t ^ 2) + k = 0 := by
  unfold OnParabolaCircle; constructor <;> intro hh <;> nlinarith [hh]

/-
Divided-difference relation: for two distinct vertices on a common parabola
circle, `x³ + x²y + xy² + y³ + (1+h)(x+y) + g = 0`.
-/
theorem root_pair_relation (g h k x y : ℝ)
    (hx : OnParabolaCircle g h k x) (hy : OnParabolaCircle g h k y)
    (hxy : x ≠ y) :
    x ^ 3 + x ^ 2 * y + x * y ^ 2 + y ^ 3 + (1 + h) * (x + y) + g = 0 := by
  exact mul_left_cancel₀ ( sub_ne_zero_of_ne hxy ) ( by linarith [ hx.symm, hy.symm ] )

/-
**Forward direction.** Four distinct vertices of a parabola-inscribed
quadrilateral that are concyclic have abscissae summing to zero.
-/
theorem parabola_concyclic_sum_zero (g h k a b c d : ℝ)
    (ha : OnParabolaCircle g h k a) (hb : OnParabolaCircle g h k b)
    (hc : OnParabolaCircle g h k c) (hd : OnParabolaCircle g h k d)
    (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    a + b + c + d = 0 := by
  -- Eliminate the circle coefficients `g, 1+h` from the divided-difference
  -- relations on vertex pairs; the constraint collapses to `a+b+c+d = 0`.
  have eq1 := root_pair_relation g h k a b ha hb hab
  have eq2 := root_pair_relation g h k a c ha hc hac
  have eq3 := root_pair_relation g h k a d ha hd had
  have eq4 := root_pair_relation g h k b c hb hc hbc
  have eq5 := root_pair_relation g h k b d hb hd hbd
  have eq6 := root_pair_relation g h k c d hc hd hcd
  grind

/-
**Converse direction.** If the abscissae sum to zero then the four parabola
points are concyclic: an explicit circle passes through all of them.
-/
theorem parabola_sum_zero_concyclic (a b c d : ℝ) (h0 : a + b + c + d = 0) :
    ∃ g h k : ℝ,
      OnParabolaCircle g h k a ∧ OnParabolaCircle g h k b ∧
      OnParabolaCircle g h k c ∧ OnParabolaCircle g h k d := by
  unfold OnParabolaCircle;
  -- Set $g := -e3$, $h := e2 - 1$, and $k := e4$.
  use -(a * b * c + a * b * d + a * c * d + b * c * d), (a * b + a * c + a * d + b * c + b * d + c * d) - 1, a * b * c * d;
  grind +ring

/-- Combined characterisation (for pairwise-distinct vertices): concyclic ⟺ the
abscissae sum to zero. -/
theorem parabola_concyclic_iff_sum_zero (a b c d : ℝ)
    (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    (∃ g h k : ℝ,
        OnParabolaCircle g h k a ∧ OnParabolaCircle g h k b ∧
        OnParabolaCircle g h k c ∧ OnParabolaCircle g h k d)
      ↔ a + b + c + d = 0 := by
  constructor
  · rintro ⟨g, h, k, ha, hb, hc, hd⟩
    exact parabola_concyclic_sum_zero g h k a b c d ha hb hc hd hab hac had hbc hbd hcd
  · intro h0
    exact parabola_sum_zero_concyclic a b c d h0

end ParabolaConcyclic