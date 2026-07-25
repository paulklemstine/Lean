/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Fano-plane threshold for (additive) strong blocking sets, `h = 1` case

A **strong blocking set** (also *cutting blocking set*) of a projective space `PG(N, q)`
is a set of points that meets every hyperplane in a *spanning* subset of that hyperplane.
Strong blocking sets are exactly the geometric duals of **minimal linear codes**, and the
*additive* variant over `GF(q^h)` specialises, in the `h = 1` case, to the ordinary
(`GF(q)`-linear) strong blocking sets.  This file treats the smallest non-degenerate
projective plane, the **Fano plane** `PG(2, 2)` (`q = 2`, `N = 2`).

In a projective *plane* every hyperplane is a *line* (a `1`-dimensional projective subspace),
which is spanned by any two of its distinct points.  Hence a strong blocking set of a plane
is precisely a set meeting **every line in at least two points** (a *double blocking set*).

## Model

We use the cyclic (Singer) model of the Fano plane:

* points  `= ZMod 7`;
* lines   `= {i, i+1, i+3}` for `i : ZMod 7`,

which is the development of the perfect difference set `{0, 1, 3} (mod 7)`.

## Main results

* `FanoStrongBlocking.fanoLine_card` — every line has exactly `3` points.
* `FanoStrongBlocking.two_points_collinear` — any two distinct points lie on a common line
  (the projective-plane incidence axiom for this model).
* `FanoStrongBlocking.sb6_isStrongBlocking` — the `6`-point set `univ \ {0}` is a strong
  blocking set, witnessing the upper bound.
* `FanoStrongBlocking.strongBlocking_card_ge_six` — every strong blocking set has `≥ 6`
  points (the lower bound).
* `FanoStrongBlocking.fano_threshold_isLeast` — the minimum size of a strong blocking set of
  the Fano plane is exactly `6`.
* `FanoStrongBlocking.fano_threshold_eq_formula` — `6 = (k-1)(q+1)` for `k = 3`, `q = 2`,
  realising with equality the general strong-blocking-set lower bound `(k-1)(q+1)`.

## Catalog connections

* `Mathlib.Data.ZMod.Basic`, `Mathlib.Data.Finset.Card` supply the finite-incidence
  combinatorics.
* The `(k-1)(q+1)` formula links this plane instance to the general minimal-code /
  strong-blocking-set lower bound of Alfarano–Borello–Neri and Davydov–Giulietti–Marcugini–
  Pambianco; the Fano plane realises the bound with equality.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): In the `h = 1` (linear) case, an additive strong blocking set of
  `PG(2, q)` is a double blocking set, and for the Fano plane `q = 2` its minimum size should
  equal the general lower bound `(k-1)(q+1) = 2·3 = 6`, i.e. the bound is *tight* in the
  smallest plane.
Experiment (Experimenter): Modelled the Fano plane cyclically (`ZMod 7`, lines `{i,i+1,i+3}`).
  A brute-force enumeration of all `2^7 = 128` point sets (via `decide`) confirmed: (a) every
  line has `3` points; (b) `univ \ {0}` blocks every line twice; (c) NO set of size `≤ 5`
  blocks every line twice; hence the threshold is exactly `6`.
Analysis (Analyst): The lower bound has a clean conceptual proof: if `S` meets every line in
  `≥ 2` of its `3` points, its complement `T` meets every line in `≤ 1` point; but in the Fano
  plane *any two distinct points are collinear* (`two_points_collinear`), so `T` cannot contain
  two points — `|T| ≤ 1`, whence `|S| ≥ 6`.  This is the plane shadow of the general
  `(k-1)(q+1)` bound, here attained with equality.
Critique (Critic): The headline numbers (`3`, `6`) are finite checks; the load-bearing
  mathematical statement is the incidence axiom `two_points_collinear` together with the
  tightness identity `6 = (k-1)(q+1)`, which is what certifies that the Fano plane *saturates*
  the general strong-blocking-set bound rather than merely satisfying it.  Future cycles should
  test whether saturation persists for `PG(2, q)`, `q > 2`, where double-blocking minima are
  known to *exceed* `2(q+1)`.
-/
import Mathlib

set_option maxHeartbeats 4000000
set_option maxRecDepth 10000

namespace FanoStrongBlocking

open Finset

/-- The `i`-th line of the cyclic (Singer) model of the Fano plane `PG(2,2)`:
the development of the perfect difference set `{0,1,3} (mod 7)`. -/
def fanoLine (i : ZMod 7) : Finset (ZMod 7) := {i, i + 1, i + 3}

/-- A set of points is a **strong blocking set** of the Fano plane iff it meets every line in
at least two points (equivalently, in a spanning subset of the line). -/
def IsStrongBlocking (S : Finset (ZMod 7)) : Prop :=
  ∀ i : ZMod 7, 2 ≤ (fanoLine i ∩ S).card

/-- Every line of the Fano plane contains exactly `3` points. -/
theorem fanoLine_card (i : ZMod 7) : (fanoLine i).card = 3 := by
  revert i; decide

/-- **Incidence axiom.** Any two distinct points of the Fano plane lie on a common line. -/
theorem two_points_collinear {a b : ZMod 7} (hab : a ≠ b) :
    ∃ i : ZMod 7, a ∈ fanoLine i ∧ b ∈ fanoLine i := by
  revert a b
  decide

/-- The explicit `6`-point witness `univ \ {0}`. -/
def sb6 : Finset (ZMod 7) := Finset.univ \ {0}

/-- The witness has exactly `6` points. -/
theorem sb6_card : sb6.card = 6 := by decide

/-- **Upper bound.** The `6`-point set `univ \ {0}` is a strong blocking set. -/
theorem sb6_isStrongBlocking : IsStrongBlocking sb6 := by
  unfold IsStrongBlocking sb6 fanoLine
  decide

/-- **Lower bound.** Every strong blocking set of the Fano plane has at least `6` points. -/
theorem strongBlocking_card_ge_six (S : Finset (ZMod 7)) (hS : IsStrongBlocking S) :
    6 ≤ S.card := by
  revert hS
  unfold IsStrongBlocking fanoLine
  revert S
  decide

/-- **The Fano-plane threshold.** The minimum size of a strong blocking set of `PG(2,2)` is
exactly `6`. -/
theorem fano_threshold_isLeast :
    IsLeast {n : ℕ | ∃ S : Finset (ZMod 7), IsStrongBlocking S ∧ S.card = n} 6 := by
  constructor
  · exact ⟨sb6, sb6_isStrongBlocking, sb6_card⟩
  · rintro n ⟨S, hS, rfl⟩
    exact strongBlocking_card_ge_six S hS

/-- **Structure of the extremal sets.** A strong blocking set attains the threshold `6` iff it
is the complement of a single point.  Thus the minimum strong blocking sets of the Fano plane
are exactly the `7` sets `univ \ {p}`. -/
theorem minimum_strongBlocking_iff (S : Finset (ZMod 7)) :
    (IsStrongBlocking S ∧ S.card = 6) ↔ ∃ p : ZMod 7, S = Finset.univ \ {p} := by
  revert S
  unfold IsStrongBlocking fanoLine
  decide

/-- **Count of extremal sets.** There are exactly `7` strong blocking sets of minimum size `6`,
one for each point of the plane. -/
theorem minimum_strongBlocking_count :
    (Finset.univ.filter
      (fun S : Finset (ZMod 7) =>
        (∀ i : ZMod 7, 2 ≤ (({i, i + 1, i + 3} : Finset (ZMod 7)) ∩ S).card)
          ∧ S.card = 6)).card = 7 := by
  decide

/-- **Tightness of the general bound.** The threshold `6` equals `(k-1)(q+1)` for the Fano-plane
parameters `k = 3` (code dimension / `PG(k-1,q) = PG(2,q)`) and `q = 2`, so the Fano plane
*saturates* the general strong-blocking-set lower bound `(k-1)(q+1)`. -/
theorem fano_threshold_eq_formula : (3 - 1) * (2 + 1) = 6 := by decide

end FanoStrongBlocking