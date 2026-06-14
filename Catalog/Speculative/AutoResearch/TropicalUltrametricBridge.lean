import Mathlib

/-!
# Tropical–Ultrametric Bridge: arithmetic heights as tropical valuations

This file isolates the abstract object that the catalog's "arithmetic height = tropical
valuation" theme rests on: a **non-archimedean (ultrametric) norm** `NonArchNorm K` on a
field `K`, together with the concrete `p`-adic realisation `padicHeightNorm p` on `ℚ`.

The headline *duality* is the **tropical dictionary**
`padicHeightNorm_eq_zpow`:

  `(padicHeightNorm p).N q = (p : ℝ) ^ (-(padicTropicalValuation p q))`   (`q ≠ 0`),

which exhibits the multiplicative non-archimedean *norm* (an element of the ultrametric
world) as the exponential `p^(−v)` of the additive **tropical valuation**
`padicTropicalValuation p q = padicValRat p q` (an element of the min-plus / tropical
world).  Multiplication of norms ↦ addition of valuations, and the ultrametric
inequality `N(x+y) ≤ max (N x) (N y)` is the dual of the tropical `min` rule
`v(x+y) ≥ min (v x) (v y)`.

The downstream file `Speculative/AutoResearch/FibonacciApparitionDuality.lean` feeds the
concrete Fibonacci sequence into `padicHeightNorm`, so that the rank of apparition
becomes the exact combinatorial controller of the non-archimedean size of Fibonacci
numbers.

-- !-- Lab Notebook -- !--
-- Hypothesis:  A `p`-adic absolute value is simultaneously an ultrametric norm and the
--   exponential of a tropical (min-plus) valuation; the two pictures should be
--   interchangeable by a single `zpow` dictionary.
-- Result:  `NonArchNorm` packages the ultrametric axioms; `padicHeightNorm p` realises
--   them from `padicNorm`; `padicHeightNorm_eq_zpow` is the tropical dictionary;
--   `padicHeightNorm_lt_one_iff_dvd` reads off "norm < 1 ↔ p ∣ z" for integers.  All
--   `sorry`-free, axioms `propext / Classical.choice / Quot.sound`.
-- Insight:  Everything is a cast of the corresponding `padicNorm` lemma; the only real
--   content is `padicNorm.nonarchimedean`, and the valuation/norm duality is literally
--   the definitional `padicNorm p q = p ^ (-padicValRat p q)` for `q ≠ 0`.
-- Failure analysis:  Casting `max` and `zpow` across `ℚ → ℝ` is the only friction;
--   `Rat.cast_max` and `Rat.cast_zpow` resolve it.
-- !-- Lab Notebook -- !--
-/

open Classical

namespace TropUltra

/-- A **non-archimedean (ultrametric) norm** on a field `K`, valued in `ℝ`.
This is the abstract "arithmetic-height" object: multiplicative, nonnegative, and
satisfying the strong (ultrametric) triangle inequality. -/
structure NonArchNorm (K : Type*) [Field K] where
  /-- The underlying real-valued size function. -/
  N : K → ℝ
  nonneg : ∀ x, 0 ≤ N x
  eq_zero : ∀ x, N x = 0 ↔ x = 0
  map_one : N 1 = 1
  map_mul : ∀ x y, N (x * y) = N x * N y
  nonarch : ∀ x y, N (x + y) ≤ max (N x) (N y)

/-- The **`p`-adic tropical valuation** of a rational: the additive (min-plus) datum
underlying the non-archimedean norm. -/
def padicTropicalValuation (p : ℕ) (q : ℚ) : ℤ := padicValRat p q

/-- The **`p`-adic arithmetic-height norm** on `ℚ`, realised from `padicNorm`. -/
noncomputable def padicHeightNorm (p : ℕ) [Fact p.Prime] : NonArchNorm ℚ where
  N q := ((padicNorm p q : ℚ) : ℝ)
  nonneg q := by exact_mod_cast padicNorm.nonneg q
  eq_zero q := by
    constructor
    · intro h
      have : padicNorm p q = 0 := by exact_mod_cast h
      exact (IsAbsoluteValue.abv_eq_zero (padicNorm p)).1 this
    · intro h; subst h; simp [padicNorm.zero]
  map_one := by
    show ((padicNorm p 1 : ℚ) : ℝ) = 1
    rw [padicNorm.one]; norm_num
  map_mul x y := by
    show ((padicNorm p (x * y) : ℚ) : ℝ)
        = ((padicNorm p x : ℚ) : ℝ) * ((padicNorm p y : ℚ) : ℝ)
    rw [padicNorm.mul]; push_cast; ring
  nonarch x y := by
    have h := padicNorm.nonarchimedean (p := p) (q := x) (r := y)
    calc ((padicNorm p (x + y) : ℚ) : ℝ)
        ≤ ((max (padicNorm p x) (padicNorm p y) : ℚ) : ℝ) := by exact_mod_cast h
      _ = max ((padicNorm p x : ℚ) : ℝ) ((padicNorm p y : ℚ) : ℝ) := by
            rw [Rat.cast_max]

/-- **Tropical dictionary.** The non-archimedean *norm* of a nonzero rational is the
exponential `p^(−v)` of the additive tropical *valuation* `v = padicTropicalValuation`.
This is the precise duality between the ultrametric (multiplicative) and tropical
(min-plus, additive) worlds. -/
theorem padicHeightNorm_eq_zpow (p : ℕ) [Fact p.Prime] {q : ℚ} (hq : q ≠ 0) :
    (padicHeightNorm p).N q = (p : ℝ) ^ (-(padicTropicalValuation p q)) := by
  show ((padicNorm p q : ℚ) : ℝ) = _
  rw [padicNorm, if_neg hq, padicTropicalValuation]
  push_cast
  rfl

/-- **Height reads off divisibility.** For a nonzero integer `z`, the `p`-adic height is
strictly below `1` exactly when `p ∣ z`. -/
theorem padicHeightNorm_lt_one_iff_dvd (p : ℕ) [Fact p.Prime] (z : ℤ) :
    (padicHeightNorm p).N (z : ℚ) < 1 ↔ (p : ℤ) ∣ z := by
  show ((padicNorm p (z : ℚ) : ℚ) : ℝ) < 1 ↔ _
  rw [show (1 : ℝ) = ((1 : ℚ) : ℝ) by norm_num, Rat.cast_lt]
  exact padicNorm.int_lt_one_iff z

end TropUltra