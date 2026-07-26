/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# A finite infinitesimal probability model

This file builds, for each `n : ℕ`, a concrete finitely additive probability measure whose
values live in an ordered ring of *infinitesimals* rather than in `ℝ`.  The value type is the
ring of pairs `LexRat = ℚ × ℚ`, where a pair `(a, b)` is interpreted as the formal expression
`a + b·ε` with `ε` a positive infinitesimal.  Addition, subtraction and negation are the usual
componentwise operations on pairs, but the order is **lexicographic**: `(a₁, b₁) ≤ (a₂, b₂)` iff
`a₁ < a₂`, or `a₁ = a₂` and `b₁ ≤ b₂`.  Under this order `ε = (0, 1)` is positive but smaller than
every positive rational `(q, 0)`, i.e. it is a genuine infinitesimal.

## The model

The sample space for parameter `n` is `Option (Fin n)`.  The `n` "visible" atoms `some i` each
carry the infinitesimal weight `ε`, while the single "reservoir" atom `none` carries weight
`1 - n·ε`.  The reservoir weight is chosen exactly so that the total mass is

  `n · ε + (1 - n·ε) = 1`,

making the measure normalized.  Because the reservoir absorbs the deficit `-n·ε` in its
infinitesimal component while keeping a real component equal to `1`, it remains lexicographically
positive; meanwhile each visible atom has probability `ε`, which is positive yet infinitesimally
small — strictly below `1` and below every positive standard probability.

## Main results

* `LexRat.eps_infinitesimal` : `ε` is below every positive rational.
* `prob_eq_closed_form` : a closed form for the probability of an arbitrary event.
* `prob_nonneg` : every event has lexicographically nonnegative probability.
* `prob_union_disjoint` : finite additivity.
* `prob_univ` : the total mass is `1`.
* `visible_singleton_infinitesimal` : each visible atom has infinitesimal probability `ε < 1`.
-/

/-- The value type of the infinitesimal probability model: a pair `(a, b)` read as `a + b·ε`. -/
abbrev LexRat := ℚ × ℚ

namespace LexRat

/-- Lexicographic `≤` on `LexRat`. -/
def lexLe (x y : LexRat) : Prop := x.1 < y.1 ∨ x.1 = y.1 ∧ x.2 ≤ y.2

/-- Lexicographic `<` on `LexRat`. -/
def lexLt (x y : LexRat) : Prop := x.1 < y.1 ∨ x.1 = y.1 ∧ x.2 < y.2

/-- Lexicographic nonnegativity: `(0,0) ≤ x`. -/
def Nonneg (x : LexRat) : Prop := lexLe (0, 0) x

/-- The unit `1 = (1, 0)`. -/
def one : LexRat := ((1 : ℚ), (0 : ℚ))

/-- The infinitesimal `ε = (0, 1)`. -/
def eps : LexRat := ((0 : ℚ), (1 : ℚ))

/-- Embedding of a rational `q` as the standard value `(q, 0)`. -/
def ofRat (q : ℚ) : LexRat := (q, 0)

@[simp] lemma one_fst : one.1 = 1 := rfl
@[simp] lemma one_snd : one.2 = 0 := rfl
@[simp] lemma eps_fst : eps.1 = 0 := rfl
@[simp] lemma eps_snd : eps.2 = 1 := rfl
@[simp] lemma ofRat_fst (q : ℚ) : (ofRat q).1 = q := rfl
@[simp] lemma ofRat_snd (q : ℚ) : (ofRat q).2 = 0 := rfl

/-- `ε` is strictly positive. -/
theorem eps_pos : lexLt (0, 0) eps := by
  right
  exact ⟨rfl, by norm_num⟩

/-- `ε` is nonnegative. -/
theorem eps_nonneg : Nonneg eps := by
  right
  exact ⟨rfl, by norm_num⟩

/-- `ε` is below every positive rational: it is a genuine infinitesimal. -/
theorem eps_infinitesimal : ∀ q : ℚ, 0 < q → lexLt eps (ofRat q) := by
  intro q hq
  left
  simpa using hq

end LexRat

namespace InfinitesimalProbability

open LexRat

/-- The atom weights for parameter `n`: the reservoir atom `none` carries `1 - n·ε`, while each
visible atom `some i` carries `ε`. -/
def atomWeight (n : ℕ) : Option (Fin n) → LexRat
  | none => ((1 : ℚ), -(n : ℚ))
  | some _ => ((0 : ℚ), (1 : ℚ))

@[simp] lemma atomWeight_none (n : ℕ) : atomWeight n none = ((1 : ℚ), -(n : ℚ)) := rfl
@[simp] lemma atomWeight_some (n : ℕ) (i : Fin n) : atomWeight n (some i) = ((0 : ℚ), (1 : ℚ)) := rfl

/-- The probability of an event is the finite sum of its atom weights. -/
def prob (n : ℕ) (A : Finset (Option (Fin n))) : LexRat := A.sum (atomWeight n)

/-- The visible part of an event: the set of `Fin n` indices whose atom belongs to the event. -/
def visiblePart (n : ℕ) (A : Finset (Option (Fin n))) : Finset (Fin n) :=
  Finset.univ.filter fun i => some i ∈ A

@[simp] lemma mem_visiblePart (n : ℕ) (A : Finset (Option (Fin n))) (i : Fin n) :
    i ∈ visiblePart n A ↔ some i ∈ A := by
  simp [visiblePart]

lemma visiblePart_card_le (n : ℕ) (A : Finset (Option (Fin n))) :
    (visiblePart n A).card ≤ n := by
  calc (visiblePart n A).card ≤ (Finset.univ : Finset (Fin n)).card := Finset.card_le_card (by
        simp [visiblePart])
    _ = n := by simp

@[simp] lemma visiblePart_univ (n : ℕ) : visiblePart n Finset.univ = Finset.univ := by
  ext i; simp

lemma visiblePart_univ_card (n : ℕ) : (visiblePart n (Finset.univ)).card = n := by
  simp

/-
**Closed form for event probabilities.**  The real (first) component of `prob n A` records
whether the reservoir atom `none` is present, while the infinitesimal (second) component counts the
visible atoms and subtracts `n` once if the reservoir is present.  We prove this by induction on the
finite event `A`, tracking how inserting each atom changes both the reservoir indicator, the visible
cardinality and the running sum.
-/
theorem prob_eq_closed_form (n : ℕ) (A : Finset (Option (Fin n))) :
    prob n A =
      ((if none ∈ A then (1 : ℚ) else 0),
       ((visiblePart n A).card : ℚ) - (if none ∈ A then (n : ℚ) else 0)) := by
  induction A using Finset.induction <;> simp_all +decide;
  · unfold prob visiblePart; aesop;
  · rename_i a s ha hs;
    rcases a with ( _ | i ) <;> simp_all +decide [ prob, visiblePart ];
    · ring;
    · rw [ show ( Finset.filter ( fun x => x = i ∨ some x ∈ s ) Finset.univ : Finset ( Fin n ) ) = Finset.filter ( fun x => some x ∈ s ) Finset.univ ∪ { i } from ?_, Finset.card_union ] <;> norm_num [ ha ] ; ring;
      grind

@[simp] theorem prob_empty (n : ℕ) : prob n ∅ = (0, 0) := by
  rw [prob, Finset.sum_empty]; rfl

theorem prob_singleton_none (n : ℕ) : prob n {none} = ((1 : ℚ), -(n : ℚ)) := by
  simp [prob]

theorem prob_singleton_visible (n : ℕ) (i : Fin n) : prob n {some i} = eps := by
  simp [prob, eps]

/-- Each atom weight is lexicographically nonnegative.  The reservoir atom has a *negative*
infinitesimal component `-n`, but its real component `1` is strictly positive, so it is
lexicographically positive; the visible atoms have real component `0` and infinitesimal
component `1`. -/
theorem atomWeight_nonneg (n : ℕ) : ∀ x : Option (Fin n), Nonneg (atomWeight n x) := by
  intro x
  cases x with
  | none =>
    left
    simp
  | some i =>
    right
    refine ⟨by simp, by simp⟩

/-- **Nonnegativity of the measure.**  Using the closed form: if the reservoir atom `none` is in
the event then the real component is `1 > 0`; otherwise the real component is `0` and the
infinitesimal component is the (nonnegative) cardinality of the visible part. -/
theorem prob_nonneg (n : ℕ) : ∀ A : Finset (Option (Fin n)), Nonneg (prob n A) := by
  intro A
  rw [prob_eq_closed_form]
  by_cases h : none ∈ A
  · left
    simp [h]
  · right
    refine ⟨by simp [h], ?_⟩
    simp only [h, if_false, sub_zero]
    positivity

/-- **Finite additivity** for disjoint events. -/
theorem prob_union_disjoint (n : ℕ) (A B : Finset (Option (Fin n))) (h : Disjoint A B) :
    prob n (A ∪ B) = prob n A + prob n B := by
  simp [prob, Finset.sum_union h]

/-- **Normalization**: the total mass is `1`.  By the closed form, `none ∈ univ` so the real
component is `1`, and the visible cardinality of `Fin n` is `n`, so the infinitesimal component is
`n - n = 0`. -/
theorem prob_univ (n : ℕ) : prob n Finset.univ = one := by
  rw [prob_eq_closed_form]
  simp [one]

/-- Each visible atom has probability exactly `ε`, which is strictly below `1`: a positive but
infinitesimal probability. -/
theorem visible_singleton_infinitesimal (n : ℕ) (i : Fin n) :
    prob n {some i} = eps ∧ lexLt (prob n {some i}) one := by
  refine ⟨prob_singleton_visible n i, ?_⟩
  rw [prob_singleton_visible]
  left
  simp [eps, one]

end InfinitesimalProbability