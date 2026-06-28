/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Fano-plane threshold for strong blocking sets (the `h = 1` case)

This file proves the `h = 1` specialization of the additive strong-blocking-set
problem: in the Fano plane `PG(2,2)` a finite set of points is a **strong blocking
set** (a *cutting blocking set*: it meets every line in a spanning subset) **iff it
contains at least `6` of the `7` points**.

## Model

We represent `PG(2,2)` by the nonzero vectors of `V = (ZMod 2)^3`.  Over `ZMod 2`
the only nonzero scalar is `1`, so the `7` projective points are exactly the `7`
nonzero vectors.  Three distinct nonzero points `a, b, c` are **collinear** iff
`a + b + c = 0` (equivalently `c = a + b`); each of the `7` lines has `3` points.

A line of `PG(2,2)` has `3` points, and a 3-point projective line is *spanned* by a
subset iff that subset has at least `2` points.  Hence a strong blocking set is a
set `S` meeting every line in `≥ 2` points, which we phrase as: for every line
`{a,b,c}`, at least two of `a, b, c` lie in `S`.

## Main result

`fano_strongBlocking_iff_six` : for `S ⊆ Pts`,
`StrongBlocking S ↔ 6 ≤ S.card`.

The crux is the structural lemma `card_le_five_of_two_missing` / `two_missing`:
two distinct missing points `p, q` create the "starved" line `{p, q, p+q}` that
contains at most one point of `S`.  This replaces a brute-force enumeration with a
genuine incidence argument.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the strong-blocking threshold in `PG(2,2)` should be
  the codimension bound `3(q+1) - 1 = 6` specialized to `q = 2`; equivalently every
  minimal binary `[n,3]` code that is *minimal* (every codeword minimal) has
  `n ≥ 6`, with equality attained.  Bold form: the threshold is sharp at `6`, never
  `5`.
* Experiment (Experimenter): modelled points as nonzero vectors of `(ZMod 2)^3`,
  lines as zero-sum triples.  Proved the "unique third point" lemma `isLine_add`
  (two points `p ≠ q` span the line `{p, q, p+q}`) by `ZMod 2` arithmetic
  (`p + p = 0`).  The threshold reduces to a counting argument via
  `Finset.card_sdiff` against `Pts.card = 7`.
* Analysis (Analyst): both directions of the iff funnel through *one* bridge —
  "`S` misses two distinct points  ↔  `S.card ≤ 5`".  Forward (blocking ⇒ large):
  a missing pair starves their common line.  Reverse (large ⇒ blocking): a starved
  line would force two missing points hence `card ≤ 5`.
* Critique (Critic): the statement is not vacuous — `Pts.card = 7 ≥ 6`, so strong
  blocking sets exist (`Corollaries.lean`).  The main theorem is not `decide`-only:
  it uses `card_sdiff`, an existence-of-two-elements argument, and field arithmetic
  over `ZMod 2`.  The spanning condition `≥ 2` is exactly faithful to "`S ∩ ℓ`
  spans the projective line `ℓ`".
* Synthesis (PI): `fano_strongBlocking_iff_six` is the headline; `isLine_add` and
  the counting bridge are the reusable engines exported to `Corollaries.lean`.
-/

open Finset

namespace FanoStrongBlocking

/-- The ambient vector space `(ZMod 2)^3`; its `7` nonzero vectors are the points of
`PG(2,2)`. -/
abbrev V : Type := Fin 3 → ZMod 2

/-- The `7` projective points of the Fano plane: the nonzero vectors of `(ZMod 2)^3`. -/
def Pts : Finset V := Finset.univ.filter (· ≠ 0)

/-- A point lies in `Pts` iff it is nonzero. -/
@[simp] lemma mem_Pts {v : V} : v ∈ Pts ↔ v ≠ 0 := by
  simp [Pts]

/-- The Fano plane has exactly `7` points. -/
lemma Pts_card : Pts.card = 7 := by decide

/-- `a, b, c` form a line of `PG(2,2)`: three distinct nonzero points summing to
zero (i.e. collinear). -/
def IsLine (a b c : V) : Prop :=
  a ≠ 0 ∧ b ≠ 0 ∧ c ≠ 0 ∧ a ≠ b ∧ a ≠ c ∧ b ≠ c ∧ a + b + c = 0

/-- Two distinct nonzero points `p, q` span the line `{p, q, p+q}`: the third point
`p + q` is the unique remaining point of the line through `p` and `q`. -/
lemma isLine_add {p q : V} (hp : p ≠ 0) (hq : q ≠ 0) (hpq : p ≠ q) :
    IsLine p q (p + q) := by
  unfold IsLine;
  grind +qlia

/-- A set `S` of points is **strong blocking** (a cutting blocking set) if every
line meets `S` in a spanning subset; for the 3-point lines of `PG(2,2)` this means
at least two of the three points of each line lie in `S`. -/
def StrongBlocking (S : Finset V) : Prop :=
  ∀ a b c, IsLine a b c →
    (a ∈ S ∧ b ∈ S) ∨ (a ∈ S ∧ c ∈ S) ∨ (b ∈ S ∧ c ∈ S)

/-- Counting bridge (one direction): if two distinct projective points are missing
from `S ⊆ Pts`, then `S` has at most `5` points. -/
lemma card_le_five_of_two_missing {S : Finset V} (hS : S ⊆ Pts) {p q : V}
    (hp : p ∈ Pts) (hq : q ∈ Pts) (hps : p ∉ S) (hqs : q ∉ S) (hpq : p ≠ q) :
    S.card ≤ 5 := by
  have h_card : (Pts \ S).card ≥ 2 := by
    exact Finset.one_lt_card.2 ⟨ p, by aesop, q, by aesop ⟩;
  grind +suggestions

/-- Counting bridge (other direction): if `S ⊆ Pts` has at most `5` points then `S`
misses two distinct projective points. -/
lemma two_missing {S : Finset V} (hS : S ⊆ Pts) (h : S.card ≤ 5) :
    ∃ p q, p ∈ Pts ∧ q ∈ Pts ∧ p ∉ S ∧ q ∉ S ∧ p ≠ q := by
  have hcard : (Pts \ S).card = Pts.card - S.card := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 hS]
  have hle : S.card ≤ Pts.card := Finset.card_le_card hS
  rw [Pts_card] at hcard hle
  have h1 : 1 < (Pts \ S).card := by omega
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.mp h1
  rw [Finset.mem_sdiff] at hp hq
  exact ⟨p, q, hp.1, hq.1, hp.2, hq.2, hpq⟩

/-- **Main theorem (Fano-plane threshold).**  A set `S` of points of `PG(2,2)` is a
strong blocking set iff it contains at least `6` of the `7` points. -/
theorem fano_strongBlocking_iff_six {S : Finset V} (hS : S ⊆ Pts) :
    StrongBlocking S ↔ 6 ≤ S.card := by
  constructor <;> intro h;
  · by_contra h_contra;
    obtain ⟨ p, q, hp, hq, hps, hqs, hpq ⟩ := two_missing hS ( by linarith );
    have := h p q ( p + q ) ( isLine_add ( mem_Pts.mp hp ) ( mem_Pts.mp hq ) hpq ) ; simp_all +decide ;
  · intro a b c hline
    by_cases ha : a ∈ S
    by_cases hb : b ∈ S
    by_cases hc : c ∈ S
    aesop;
    · tauto;
    · by_cases hc : c ∈ S <;> simp_all +decide [ IsLine ];
      have := card_le_five_of_two_missing hS ( show b ∈ Pts from by aesop ) ( show c ∈ Pts from by aesop ) hb hc ( by aesop ) ; linarith;
    · by_cases hb : b ∈ S <;> by_cases hc : c ∈ S <;> simp_all +decide [ IsLine ];
      · have := FanoStrongBlocking.card_le_five_of_two_missing hS ( show a ∈ Pts from by aesop ) ( show c ∈ Pts from by aesop ) ha hc ( by aesop ) ; linarith;
      · have : S.card ≤ 5 := card_le_five_of_two_missing hS ( by simp +decide [ Pts, hline ] ) ( by simp +decide [ Pts, hline ] ) ha hb ( by aesop ) ; linarith;
      · have h_card : S.card ≤ 5 := by
          exact le_trans ( Finset.card_le_card ( show S ⊆ Finset.univ \ { a, b, c } from fun x hx => by aesop ) ) ( by simp +decide [ *, Finset.card_sdiff ] );
        linarith

end FanoStrongBlocking