/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Pontryagin–Mellin Duality: Core Definitions

This file introduces the foundational definitions for tropical harmonic analysis
on commutative semirings:

* `TropicalMellin.TropChar` — tropical characters (semiring homomorphisms to the
  tropical semifield `WithTop ℝ`)
* `TropicalMellin.EMLClosure` — closure operators compatible with finite generation
* `TropicalMellin.radicalSetoid` — the radical congruence
* `TropicalMellin.mellinTransform` — the tropical Mellin transform
* `TropicalMellin.tropConvVal` — min-plus convolution value

## Mathematical context

A tropical character converts semiring addition to `min` and semiring multiplication
to `+` in the tropical semifield `WithTop ℝ`. The radical congruence identifies elements
that no character can distinguish. The Mellin transform diagonalizes min-plus convolution.
-/

namespace TropicalMellin

noncomputable section
open scoped Classical

/-- The tropical value type: `WithTop ℝ` with `⊤ = +∞`. -/
abbrev TropVal := WithTop ℝ

/-! ## Tropical characters -/

/-- A tropical character on a commutative semiring `S` converts:
- `0 ↦ ⊤`, `1 ↦ 0`, `a + b ↦ min(χ(a), χ(b))`, `a * b ↦ χ(a) + χ(b)`.
This is the idempotent-semiring analogue of a Pontryagin character. -/
structure TropChar (S : Type*) [CommSemiring S] where
  toFun : S → TropVal
  map_zero' : toFun 0 = ⊤
  map_one' : toFun 1 = (0 : TropVal)
  map_add' : ∀ a b, toFun (a + b) = min (toFun a) (toFun b)
  map_mul' : ∀ a b, toFun (a * b) = toFun a + toFun b

variable {S : Type*} [CommSemiring S]

instance : FunLike (TropChar S) S TropVal where
  coe := TropChar.toFun
  coe_injective' f g h := by cases f; cases g; simp_all

@[ext]
theorem TropChar.ext {χ ψ : TropChar S} (h : ∀ s, χ s = ψ s) : χ = ψ :=
  DFunLike.ext χ ψ h

@[simp] theorem TropChar.map_zero (χ : TropChar S) : χ 0 = ⊤ := χ.map_zero'
@[simp] theorem TropChar.map_one (χ : TropChar S) : χ 1 = (0 : TropVal) := χ.map_one'

@[simp] theorem TropChar.map_add (χ : TropChar S) (a b : S) :
    χ (a + b) = min (χ a) (χ b) := χ.map_add' a b

@[simp] theorem TropChar.map_mul (χ : TropChar S) (a b : S) :
    χ (a * b) = χ a + χ b := χ.map_mul' a b

/-- `χ(a + a) = χ(a)` by idempotence of min. -/
theorem TropChar.map_add_self (χ : TropChar S) (a : S) : χ (a + a) = χ a := by
  simp [min_self]

/-! ## EML Closure operator -/

/-- An EML closure operator on a commutative semiring, axiomatizing a semantic
regularity condition for selecting "meaningful" subsets. -/
class EMLClosure (S : Type*) [CommSemiring S] where
  cl : Set S → Set S
  extensive : ∀ A : Set S, A ⊆ cl A
  mono : ∀ {A B : Set S}, A ⊆ B → cl A ⊆ cl B
  idem : ∀ A : Set S, cl (cl A) ⊆ cl A
  finite_gen_compat : ∀ A : Set S, ∃ T : Finset S, cl A = cl (↑T : Set S)

/-- The closure of a closed set equals itself. -/
theorem cl_eq_cl_cl [EMLClosure S] (A : Set S) :
    EMLClosure.cl (EMLClosure.cl A) = EMLClosure.cl (S := S) A :=
  Set.Subset.antisymm (EMLClosure.idem A) (EMLClosure.extensive (EMLClosure.cl A))

/-! ## Radical congruence -/

/-- The radical congruence: `s ~ t` iff every tropical character gives `χ(s) = χ(t)`.
This is the semiring analogue of the intersection of all character kernels. -/
def radicalSetoid (S : Type*) [CommSemiring S] : Setoid S where
  r s t := ∀ χ : TropChar S, χ s = χ t
  iseqv := {
    refl := fun _ _ => rfl
    symm := fun h χ => (h χ).symm
    trans := fun h₁ h₂ χ => (h₁ χ).trans (h₂ χ)
  }

/-- Definitional unfolding of radical equivalence. -/
theorem radical_equiv_iff (s t : S) :
    (radicalSetoid S).r s t ↔ ∀ χ : TropChar S, χ s = χ t :=
  Iff.rfl

/-! ## Mellin transform -/

/-- The tropical Mellin transform of `f : S → TropVal` over a finite set `A`:
  `M(f)(χ) = inf_{s ∈ A} (f(s) + χ(s))`
This is the min-plus analogue of the multiplicative Mellin transform. -/
def mellinTransform (f : S → TropVal) (A : Finset S) (χ : TropChar S) : TropVal :=
  if h : A.Nonempty then
    A.inf' h (fun s => f s + χ s)
  else ⊤

/-! ## Min-plus convolution -/

/-- The value of min-plus convolution at a point `t`:
  `(f ⋆ g)(t) = inf_{(a,b) ∈ A × B, a*b = t} (f(a) + g(b))` -/
def tropConvVal [DecidableEq S] (f g : S → TropVal) (A B : Finset S) (t : S) : TropVal :=
  let pairs := (A ×ˢ B).filter (fun p => p.1 * p.2 = t)
  if h : pairs.Nonempty then
    pairs.inf' h (fun p => f p.1 + g p.2)
  else ⊤

/-- The support of the convolution is contained in the product of supports. -/
def tropConvSupp [DecidableEq S] (A B : Finset S) : Finset S :=
  (A ×ˢ B).image (fun p => p.1 * p.2)

/-! ## Sparse encoding infrastructure -/

/-- The character matrix: `A(i,j) = χᵢ(gⱼ)` -/
def characterMatrix {n m : ℕ} (chars : Fin m → TropChar S)
    (gens : Fin n → S) : Fin m → Fin n → TropVal :=
  fun i j => chars i (gens j)

/-- Transform measurement: `measurement(i) = inf_j (x(j) + χᵢ(gⱼ))` -/
def transformMeasurement {n m : ℕ} [NeZero n] (chars : Fin m → TropChar S)
    (gens : Fin n → S) (x : Fin n → TropVal) : Fin m → TropVal :=
  fun i => Finset.inf' Finset.univ ⟨0, Finset.mem_univ _⟩
    (fun j => x j + chars i (gens j))

/-- Tropical nondegeneracy: the character family separates all k-sparse signals. -/
def TropicallyNondegenerate {n m : ℕ} [NeZero n] (chars : Fin m → TropChar S)
    (gens : Fin n → S) (k : ℕ) : Prop :=
  ∀ (x y : Fin n → TropVal),
    (Finset.filter (fun j => x j ≠ ⊤) Finset.univ).card ≤ k →
    (Finset.filter (fun j => y j ≠ ⊤) Finset.univ).card ≤ k →
    transformMeasurement chars gens x = transformMeasurement chars gens y →
    x = y

end
end TropicalMellin