import Mathlib
import Tropical.Core.TropicalSemiringProperties

/-! # `tropical_simp`: a sound simplification tactic for the min-plus semiring

This file develops a custom Lean 4 tactic, `tropical_simp`, that normalises
expressions in the **min-plus (tropical) semiring** `(ℝ, min, +)`, where tropical
addition is `min` and tropical multiplication is ordinary `+`.

The tactic is built only from *proven* rewrite lemmas, so every rewrite it
performs is a genuine equality of real numbers.  We make this precise:

* `trop_scalar_min`, `trop_scalar_min_right` : tropical multiplication
  distributes over tropical addition (the only non-formal rewrite rules).
* `tropical_simp` : the macro bundling these distributivity rules together with
  the associative–commutative laws of `min` and the monoid laws of `+`.
* `scalar_foldr_min` : the main *insight-bearing* theorem — tropical scalars
  distribute over a whole tropical sum (a `min`-fold over a list), proved by
  induction.  This is the closed-form correctness certificate that
  `tropical_simp` realises for finite tropical polynomials.

We also connect the file to the existing catalog development
(`Tropical.Core.TropicalSemiringProperties`, the *max-plus* convention) via the
order-reversing `min`/`max` duality, proving the min-plus distributivity law
*from* the catalog's max-plus distributivity law.

-- !-- Lab Notes -- !--
Hypothesis: "All finite min-plus identities built from `+`/`min` and the
distributive law reduce to a canonical `min`-of-sums normal form, and a single
simp-based tactic over a small set of proven equations can decide them."
Experiment: Implemented `tropical_simp` as `simp only [...]` over the
distributivity lemmas plus the AC-laws of `min`.  Tested on scalar/vector
distribution and nested `min` chains (see `examples` below).
Analysis: Distribution + AC-normalisation suffices for the *flat* identities;
the genuinely new content is the inductive `scalar_foldr_min`, which lifts the
one-step law `trop_scalar_min` to arbitrary-length tropical sums.  The AC-laws
alone do NOT close goals unless `min_left_comm` is included — without it `simp`
fails to canonicalise re-bracketed `min` trees (observed failure, then fixed).
Critique: The tactic is *sound by construction* (it only rewrites with theorems)
but not complete: it cannot, e.g., evaluate `min a b` when the order of `a,b`
is unknown — that is a case split, not a rewrite.  We therefore state the honest
scope: it is a *normalising* tactic, certified by `scalar_foldr_min`.
Synthesis: A min-plus simplifier whose soundness is a corollary of two proved
distributivity lemmas, with an inductive correctness theorem for tropical
polynomials and a duality bridge to the catalog's max-plus file.
-- !-- end Lab Notes -- !--
-/

namespace Bridges.TropicalSimpTactic

/-! ## Soundness lemmas: tropical multiplication distributes over `min` -/

/-- Tropical scalar multiplication (ordinary `+`) distributes over tropical
addition (`min`) on the left.  This is one of the two non-formal rewrite rules
used by `tropical_simp`; the rest are the AC-laws of `min` and `+`. -/
theorem trop_scalar_min (a b c : ℝ) : a + min b c = min (a + b) (a + c) := by
  rcases le_total b c with h | h
  · rw [min_eq_left h, min_eq_left (by linarith)]
  · rw [min_eq_right h, min_eq_right (by linarith)]

/-- Right-hand distributivity of tropical multiplication over `min`. -/
theorem trop_scalar_min_right (a b c : ℝ) : min a b + c = min (a + c) (b + c) := by
  rw [add_comm a c, add_comm b c, add_comm _ c]
  exact trop_scalar_min c a b

/-! ## The `tropical_simp` tactic

`tropical_simp` rewrites with the two distributivity lemmas above and the
associative/commutative laws of `min` (and the monoid laws of `+`).  Because
every lemma in the set is a proved equality, any goal it closes is true: the
tactic is *sound by construction*. -/
macro "tropical_simp" : tactic =>
  `(tactic| simp only [trop_scalar_min, trop_scalar_min_right, min_comm, min_assoc,
      min_left_comm, min_self, add_zero, zero_add, add_assoc])

/-! ## Worked examples discharged by `tropical_simp` -/

/-- Pushing a tropical scalar into a binary tropical sum. -/
example (a b c : ℝ) : a + min b c = min (a + b) (a + c) := by tropical_simp

/-- Pushing a tropical scalar into a ternary tropical sum (nested `min`). -/
example (a b c d : ℝ) :
    a + min (min b c) d = min (a + b) (min (a + c) (a + d)) := by tropical_simp

/-- Right distribution, with the summands re-ordered: AC-normalisation closes it. -/
example (a b c : ℝ) : min a b + c = min (b + c) (a + c) := by tropical_simp

/-- Idempotency: a tropical sum of a value with itself is the value. -/
example (a b : ℝ) : a + min b b = a + b := by tropical_simp

/-! ## Main theorem: scalars distribute over a whole tropical sum

A tropical "polynomial value" is a `min`-fold over a list of monomials.  The
following theorem certifies that multiplying such a value by a tropical scalar
`c` is the same as multiplying every monomial by `c` — the closed-form law that
`tropical_simp` realises one step at a time.  Proved by induction on the list
using `trop_scalar_min`. -/
theorem scalar_foldr_min (c d : ℝ) (l : List ℝ) :
    c + l.foldr min d = (l.map (c + ·)).foldr min (c + d) := by
  induction l with
  | nil => simp
  | cons a t ih =>
    simp only [List.foldr_cons, List.map_cons]
    rw [trop_scalar_min, ih]

/-- Specialisation to the empty list: the tropical scalar law holds trivially on
the neutral element. -/
example (c d : ℝ) : c + ([] : List ℝ).foldr min d = c + d := by
  simp

/-! ## Bridge to the catalog max-plus development

The catalog file `Tropical.Core.TropicalSemiringProperties` develops the dual
*max-plus* semiring.  Min-plus and max-plus are interchanged by negation
(`min a b = -max (-a) (-b)`).  We use this to derive our min-plus distributivity
law *from* the catalog's `tropical_scalar_distrib`, demonstrating the two
conventions are equivalent. -/
theorem minplus_via_maxplus (a b c : ℝ) : a + min b c = min (a + b) (a + c) := by
  have h := TropicalSemiringProperties.tropical_scalar_distrib (-a) (-b) (-c)
  have hmin : min b c = -max (-b) (-c) := by
    rw [← neg_neg (min b c)]; congr 1; rw [← max_neg_neg]
  have hmin2 : min (a + b) (a + c) = -max (-(a + b)) (-(a + c)) := by
    rw [← neg_neg (min (a + b) (a + c))]; congr 1; rw [← max_neg_neg]
  rw [hmin, hmin2]
  have e : (-(a + b)) = -a + -b := by ring
  have e2 : (-(a + c)) = -a + -c := by ring
  rw [e, e2, ← h]; ring

end Bridges.TropicalSimpTactic