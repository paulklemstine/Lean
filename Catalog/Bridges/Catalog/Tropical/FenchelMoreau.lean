import Mathlib
import Tropical.LegendreDuality

/-!
# General Fenchel–Moreau Theory of the Legendre–Fenchel Transform

This file **generalizes** the catalog's Legendre–Fenchel development
(`Catalog/Tropical/LegendreDuality.lean`), which established duality only for the
quadratic seed `f(x) = x²/2`.  Here we lift those one-off computations to an
arbitrary function `f : ℝ → ℝ`, recovering the catalog results as instances.

The Legendre–Fenchel transform `legendreTransform f` (the convex conjugate `f★`)
is imported unchanged from `Tropical.LegendreDuality`:
`legendreTransform f y = sSup {x·y - f x | x}`.

## Cross-domain bridge

The headline structural result `legendreTransform_convexOn` shows that **every**
conjugate is a convex function — i.e. `f ↦ f★★` is the *convex-envelope closure
operator*.  This connects the Legendre duality domain with the closure-operator /
Galois-connection domain of `Catalog/EML/GaloisDuality.lean`: the biconjugate is
extensive-from-below (`biconjugate_le_self`), order-reversing per transform
(`legendreTransform_antitone`), and lands in the convex cone (idempotent fixed
points are exactly the closed = convex elements, partly captured by
`convexOn_of_biconjugate_eq`).

## Main results

* `fenchel_young` — General Fenchel–Young inequality `x·y ≤ f x + f★ y`.
* `legendreTransform_antitone` — The conjugate is order-reversing: `f ≤ g ⟹ g★ ≤ f★`.
* `biconjugate_le_self` — **General biconjugate inequality** `f★★ x ≤ f x` for all `x`
  (generalizes the catalog's `legendre_biconjugate_half_sq`).
* `legendreTransform_convexOn` — **Every conjugate is convex** (sup of affine maps).
* `convexOn_of_biconjugate_eq` — Fenchel–Moreau necessity: a biconjugate fixed point
  must be convex.
* `halfSq_biconjugate_le`, `halfSq_conjugate_convexOn` — non-vacuous instances built on
  the catalog's `legendre_quad_bddAbove`.

-- !-- Lab Notebook -- !--
Hypothesis: The catalog proved `f★★ = f` only for `f = x²/2` by direct computation.
  We hypothesised the inequality `f★★ ≤ f` holds for *any* `f` whose conjugate is a
  genuine supremum (range bounded above), with no convexity assumption, and that the
  whole Legendre apparatus reduces to two Mathlib facts: `le_csSup` and `csSup_le`.
Result: Confirmed.  Fenchel–Young, order-reversal, the biconjugate inequality, and
  (crucially) convexity of every conjugate all follow from `BddAbove` bookkeeping
  plus a single completing-of-the-affine-combination identity (`a + b = 1`).
Insight: The conjugate is a pointwise supremum of *affine* functions of the dual
  variable, so convexity is structural, not analytic — no derivatives needed.  This
  reveals `f ↦ f★★` as a closure operator (extensive `≤`, lands in convex functions),
  bridging `LegendreDuality` and `GaloisDuality`.
Failure analysis: The naive statement without `BddAbove` is false in Lean because
  `sSup` of an unbounded set is the junk value `0`; e.g. `f = -id` gives an unbounded
  difference quotient.  We therefore thread an explicit `BddAbove` hypothesis, which is
  satisfied by the catalog's `legendre_quad_bddAbove`, keeping every theorem non-vacuous.
-- !-- end Lab Notebook -- !--
-/

noncomputable section
open Set

namespace FenchelMoreau

/-! ## §1. The general Fenchel–Young inequality -/

-- !-- For the supremum `f★ y` to dominate the particular slice `x·y - f x`, the
-- defining range must be bounded above; then `le_csSup` finishes immediately. -- !--
theorem fenchel_young (f : ℝ → ℝ) {y : ℝ}
    (hb : BddAbove (Set.range fun x => x * y - f x)) (x : ℝ) :
    x * y ≤ f x + legendreTransform f y := by
  have h : x * y - f x ≤ legendreTransform f y := le_csSup hb ⟨x, rfl⟩
  linarith

/-! ## §2. The conjugate is order-reversing -/

-- !-- Each slice `x·y - g x ≤ x·y - f x ≤ f★ y` (using `f ≤ g` then `le_csSup`),
-- so `csSup_le` pushes the bound through the supremum defining `g★ y`. -- !--
theorem legendreTransform_antitone (f g : ℝ → ℝ) {y : ℝ}
    (hfg : ∀ x, f x ≤ g x)
    (hb : BddAbove (Set.range fun x => x * y - f x)) :
    legendreTransform g y ≤ legendreTransform f y := by
  apply csSup_le (Set.range_nonempty _)
  rintro _ ⟨x, rfl⟩
  have h : x * y - g x ≤ x * y - f x := by linarith [hfg x]
  exact h.trans (le_csSup hb ⟨x, rfl⟩)

/-! ## §3. The general biconjugate inequality `f★★ ≤ f` -/

-- !-- Each dual slice `y·x - f★ y ≤ f x` is exactly Fenchel–Young (`§1`); since this
-- bounds every member of the range defining `f★★ x`, `csSup_le` gives `f★★ x ≤ f x`. -- !--
theorem biconjugate_le_self (f : ℝ → ℝ)
    (hb : ∀ y, BddAbove (Set.range fun x => x * y - f x)) (x : ℝ) :
    legendreTransform (legendreTransform f) x ≤ f x := by
  apply csSup_le (Set.range_nonempty _)
  rintro _ ⟨y, rfl⟩
  have h := fenchel_young f (hb y) x
  nlinarith [h]

/-! ## §4. Every conjugate is convex -/

-- !-- `f★` is a pointwise sup of affine maps `y ↦ x·y - f x`. For `a+b=1` the slice
-- splits as `a·(x·y₁-f x)+b·(x·y₂-f x)` (identity via `a+b=1`), each piece bounded by
-- `f★ y₁`, `f★ y₂` through `le_csSup`; `csSup_le` then yields the convexity inequality. -- !--
theorem legendreTransform_convexOn (f : ℝ → ℝ)
    (hb : ∀ y, BddAbove (Set.range fun x => x * y - f x)) :
    ConvexOn ℝ Set.univ (legendreTransform f) := by
  refine ⟨convex_univ, ?_⟩
  intro y1 _ y2 _ a b ha hb' hab
  simp only [smul_eq_mul]
  apply csSup_le (Set.range_nonempty _)
  rintro _ ⟨x, rfl⟩
  have e1 : x * y1 - f x ≤ legendreTransform f y1 := le_csSup (hb y1) ⟨x, rfl⟩
  have e2 : x * y2 - f x ≤ legendreTransform f y2 := le_csSup (hb y2) ⟨x, rfl⟩
  show x * (a * y1 + b * y2) - f x
      ≤ a * legendreTransform f y1 + b * legendreTransform f y2
  have key : x * (a * y1 + b * y2) - f x
      = a * (x * y1 - f x) + b * (x * y2 - f x) := by
    linear_combination (f x) * hab
  rw [key]
  have := add_le_add (mul_le_mul_of_nonneg_left e1 ha)
    (mul_le_mul_of_nonneg_left e2 hb')
  linarith

/-! ## §5. Fenchel–Moreau necessity: biconjugate fixed points are convex -/

-- !-- If `f = f★★` then `f` is the conjugate of `f★`, so it is convex by `§4` applied
-- to the function `f★`. -- !--
theorem convexOn_of_biconjugate_eq (f : ℝ → ℝ)
    (hb : ∀ y, BddAbove (Set.range fun x => x * y - legendreTransform f x))
    (hfix : legendreTransform (legendreTransform f) = f) :
    ConvexOn ℝ Set.univ f := by
  rw [← hfix]
  exact legendreTransform_convexOn (legendreTransform f) hb

/-! ## §6. Non-vacuity: instances on the catalog's quadratic seed -/

-- !-- Direct specialisation of the general theorems to `f = x²/2`, whose conjugate
-- range is bounded above by the catalog lemma `legendre_quad_bddAbove`. -- !--
theorem halfSq_biconjugate_le (x : ℝ) :
    legendreTransform (legendreTransform fun x : ℝ => x ^ 2 / 2) x ≤ x ^ 2 / 2 :=
  biconjugate_le_self _ legendre_quad_bddAbove x

theorem halfSq_conjugate_convexOn :
    ConvexOn ℝ Set.univ (legendreTransform fun x : ℝ => x ^ 2 / 2) :=
  legendreTransform_convexOn _ legendre_quad_bddAbove

end FenchelMoreau

end