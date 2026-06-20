import Mathlib

/-!
# Paraconsistent Paradox Theories — Belnap-Valued Foundations

This file develops the small amount of paraconsistent-logic infrastructure used by
`Logic.ParadoxSelfSoundness` and `Computation.ParadoxesAsTheorems`.

The core object is `BelnapVal`, the four-valued truth set of Belnap–Dunn logic
(First Degree Entailment):

* `T` — true only,
* `F` — false only,
* `B` — *both* (a glut / dialetheia: asserted and denied),
* `N` — *neither* (a gap).

A value is **designated** (`isTrue = true`) exactly when it is `T` or `B`.  Negation
swaps `T`/`F` and fixes the two "impossible" values `B` and `N`.  Conjunction and
disjunction are meet and join in the truth order `F ≤ B,N ≤ T` (the diamond lattice).

A `ParaconsistentTheory` over a sentence type `S` assigns each sentence a Belnap value
together with a syntactic negation operation.  We record the basic notions of
soundness, inconsistency degree, the Liar fixed point, classicality, and the FDE
formula algebra.
-/

/-- Belnap's four truth values (FDE / `FOUR`). -/
inductive BelnapVal
  | T
  | F
  | B
  | N
  deriving DecidableEq, Repr, Fintype

namespace BelnapVal

/-- Belnap negation: swaps `T`/`F`, fixes the impossible values `B` and `N`. -/
def neg : BelnapVal → BelnapVal
  | T => F
  | F => T
  | B => B
  | N => N

/-- A value is *designated* (at-least-true / asserted) iff it is `T` or `B`. -/
def isTrue : BelnapVal → Bool
  | T => true
  | F => false
  | B => true
  | N => false

/-- Disjunction = join in the truth order `F ≤ B,N ≤ T`, with `B ⊔ N = T`. -/
def disj : BelnapVal → BelnapVal → BelnapVal
  | T, _ => T
  | _, T => T
  | F, x => x
  | x, F => x
  | B, B => B
  | N, N => N
  | B, N => T
  | N, B => T

/-- Conjunction = meet in the truth order `F ≤ B,N ≤ T`, with `B ⊓ N = F`. -/
def conj : BelnapVal → BelnapVal → BelnapVal
  | F, _ => F
  | _, F => F
  | T, x => x
  | x, T => x
  | B, B => B
  | N, N => N
  | B, N => F
  | N, B => F

@[simp] theorem neg_neg (v : BelnapVal) : v.neg.neg = v := by cases v <;> rfl

@[simp] theorem neg_both : B.neg = B := rfl

@[simp] theorem neg_neither : N.neg = N := rfl

end BelnapVal

/-- A paraconsistent theory over a sentence type `S`: every sentence receives a
Belnap truth value, and there is a syntactic negation on sentences. -/
structure ParaconsistentTheory (S : Type*) where
  /-- The Belnap truth value assigned to each sentence. -/
  truth : S → BelnapVal
  /-- Syntactic negation of a sentence. -/
  sentNeg : S → S

namespace ParaconsistentTheory

variable {S : Type*}

/-- A set of provable sentences is *sound* when every provable sentence is
at-least-true (designated). -/
def isSound (T : ParaconsistentTheory S) (provable : Set S) : Prop :=
  ∀ s ∈ provable, (T.truth s).isTrue = true

end ParaconsistentTheory

/-- The inconsistency degree of a finite theory: the number of glut (`B`) sentences. -/
def inconsistencyDegree {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S) : ℕ :=
  (Finset.univ.filter (fun s => T.truth s = BelnapVal.B)).card

/-- A Liar sentence: a sentence whose truth value is a fixed point of negation
(forced to be `B` or `N`). -/
structure HasLiar {S : Type*} (T : ParaconsistentTheory S) where
  /-- The Liar sentence. -/
  liar : S
  /-- The Liar is a negation fixed point: it has the same value as its own negation. -/
  liar_fixed : T.truth liar = (T.truth liar).neg

/-- A theory is *classical* (bivalent) when every sentence is exactly `T` or `F`. -/
def IsClassical {S : Type*} (T : ParaconsistentTheory S) : Prop :=
  ∀ s, T.truth s = BelnapVal.T ∨ T.truth s = BelnapVal.F

/-- **No Liar in a classical theory**: bivalence is incompatible with a negation
fixed point, since `neg` has no fixed point among `{T, F}`. -/
theorem classical_no_liar {S : Type*} (T : ParaconsistentTheory S)
    (h : ∀ s, T.truth s = BelnapVal.T ∨ T.truth s = BelnapVal.F)
    (hL : HasLiar T) : False := by
  have hf := hL.liar_fixed
  rcases h hL.liar with hv | hv <;> rw [hv] at hf <;> simp [BelnapVal.neg] at hf

/-- **Berry-style pigeonhole bound**: if there are more objects than descriptions and
every object maps to a description, two distinct objects share a description. -/
theorem berry_definability_bound {S : Type*} [DecidableEq S]
    (descs objects : Finset S) (definability : S → S)
    (defn_range : ∀ o ∈ objects, definability o ∈ descs)
    (overflow : descs.card < objects.card) :
    ∃ o₁ ∈ objects, ∃ o₂ ∈ objects, o₁ ≠ o₂ ∧ definability o₁ = definability o₂ :=
  Finset.exists_ne_map_eq_of_card_lt_of_maps_to overflow defn_range

/-! ## FDE formula algebra -/

/-- Formulas of First Degree Entailment over countably many atoms. -/
inductive FDEFormula
  | atom (n : ℕ)
  | neg (φ : FDEFormula)
  | disj (φ ψ : FDEFormula)
  | conj (φ ψ : FDEFormula)

/-- Belnap-valued evaluation of an FDE formula under a valuation `v`. -/
def FDEFormula.eval (v : ℕ → BelnapVal) : FDEFormula → BelnapVal
  | .atom n => v n
  | .neg φ => (φ.eval v).neg
  | .disj φ ψ => (φ.eval v).disj (ψ.eval v)
  | .conj φ ψ => (φ.eval v).conj (ψ.eval v)