/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Closure-Hankel Realization Theory: Definitions

This file introduces the core definitions for the closure-Hankel realization
theory over idempotent semirings, establishing the idempotent/EML analogue
of classical Kalman realization theory.

## Main definitions

* `IdempotentAdd` — typeclass for types with idempotent addition
* `IsEMLClosure` — properties of a closure operator on behaviors
* `dotProd` — inner product of finite vectors
* `wordAction` — composition of transition maps along a word
* `evalLinearSystem` — evaluation of a linear system on a word
* `hankelEntry`, `hankelRow` — Hankel matrix entries and rows
* `FiniteHankelRank` — finiteness of the Hankel row space
* `FiniteClosureHankelRank` — closure-Hankel rank finiteness
* `IsLinearRealization` — a linear system realizes a behavior
* `IsClosureRealization` — realization up to closure
-/

noncomputable section

open Finset BigOperators

universe u v

/-! ## Idempotent Addition -/

/-- A type with idempotent addition: `a + a = a` for all `a`. -/
class IdempotentAdd (S : Type*) [Add S] : Prop where
  add_idem : ∀ a : S, a + a = a

/-! ## Closure Operators on Behaviors -/

variable {Alpha : Type u} {S : Type v}

/-- An EML-style closure operator on behaviors `List Alpha → S`.
Bundles extensiveness (pointwise), monotonicity, idempotence,
and compatibility with left-shifts. -/
structure IsEMLClosure [Preorder S]
    (cl : (List Alpha → S) → (List Alpha → S)) : Prop where
  /-- Closure is extensive: `B w ≤ cl B w` for all `w`. -/
  extensive : ∀ (B : List Alpha → S) (w : List Alpha), B w ≤ cl B w
  /-- Closure is monotone: if `B ≤ C` pointwise, then `cl B ≤ cl C`. -/
  monotone : ∀ (B C : List Alpha → S), (∀ w, B w ≤ C w) → ∀ w, cl B w ≤ cl C w
  /-- Closure is idempotent: `cl (cl B) = cl B`. -/
  idempotent : ∀ (B : List Alpha → S), cl (cl B) = cl B
  /-- Closure commutes with left-shifts: `cl (shift_a B) = shift_a (cl B)`. -/
  shift_compat : ∀ (B : List Alpha → S) (a : Alpha) (w : List Alpha),
    cl (fun v => B (a :: v)) w = cl B (a :: w)

/-! ## Linear System Evaluation -/

/-- Dot product of two vectors indexed by `Fin n`. -/
def dotProd [Semiring S] {n : ℕ} (α β : Fin n → S) : S :=
  ∑ i : Fin n, α i * β i

/-- Compose transition maps along a word (left-to-right reading).
`wordAction A [a, b, c] x = A c (A b (A a x))`. -/
def wordAction [Semiring S] {n : ℕ}
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) :
    List Alpha → (Fin n → S) →ₗ[S] (Fin n → S)
  | [] => LinearMap.id
  | a :: w => (wordAction A w).comp (A a)

/-- Evaluate a linear system `(α, β, A)` on a word `w`.
Returns `α · (A_w β)` where `A_w` is the composition of transitions along `w`. -/
def evalLinearSystem [Semiring S] {n : ℕ}
    (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) :
    List Alpha → S :=
  fun w => dotProd α (wordAction A w β)

/-! ## Hankel Matrix -/

/-- Hankel entry for a behavior `B`. -/
def hankelEntry (B : List Alpha → S) (u v : List Alpha) : S :=
  B (u ++ v)

/-- Hankel row at prefix `u`: the function `v ↦ B(u ++ v)`. -/
def hankelRow (B : List Alpha → S) (u : List Alpha) : List Alpha → S :=
  fun v => B (u ++ v)

/-- Closure-Hankel entry: `cl(B)(u ++ v)`. -/
def closureHankelEntry
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S)
    (u v : List Alpha) : S :=
  cl B (u ++ v)

/-- Closure-Hankel row at prefix `u`: the function `v ↦ cl(B)(u ++ v)`. -/
def closureHankelRow
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S)
    (u : List Alpha) : List Alpha → S :=
  fun v => cl B (u ++ v)

/-! ## Finite Hankel Rank -/

/-- The Hankel row space of `B` has finite rank (general generators):
there exist `n` generating functions such that every Hankel row
is an `S`-linear combination of these generators. -/
def FiniteHankelGeneratorRank [Semiring S] (B : List Alpha → S) : Prop :=
  ∃ (n : ℕ) (generators : Fin n → (List Alpha → S)),
    ∀ (u : List Alpha), ∃ (coeffs : Fin n → S),
      ∀ (v : List Alpha), B (u ++ v) = ∑ i, coeffs i * generators i v

/-- The Hankel row space of `B` has finite rank (Hankel row generators):
there exist `n` basis prefixes such that every Hankel row is an
`S`-linear combination of the Hankel rows at these basis prefixes.
This is the standard weighted automata definition. -/
def FiniteHankelRank [Semiring S] (B : List Alpha → S) : Prop :=
  ∃ (n : ℕ) (bases : Fin n → List Alpha),
    ∀ (u : List Alpha), ∃ (coeffs : Fin n → S),
      ∀ (v : List Alpha), B (u ++ v) = ∑ i, coeffs i * B (bases i ++ v)

/-- Hankel row generators imply general generator rank. -/
lemma FiniteHankelRank.toGeneratorRank [Semiring S] {B : List Alpha → S}
    (h : FiniteHankelRank B) : FiniteHankelGeneratorRank B := by
  obtain ⟨n, bases, hspan⟩ := h
  exact ⟨n, fun i v => B (bases i ++ v), hspan⟩

/-- The closure-Hankel row space of `B` has finite rank. -/
def FiniteClosureHankelRank [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S) : Prop :=
  FiniteHankelRank (cl B)

/-! ## Linear Realizations -/

/-- A linear realization of dimension `n` realizes behavior `B`:
`B(w) = α · A_w β` for all words `w`. -/
structure IsLinearRealization [Semiring S]
    (B : List Alpha → S) (n : ℕ) (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) : Prop where
  realizes : ∀ w : List Alpha, B w = evalLinearSystem α β A w

/-- A closure-linear realization: `cl(B)(w) = evalLinearSystem α β A w`. -/
structure IsClosureRealization [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S))
    (B : List Alpha → S) (n : ℕ) (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) : Prop where
  realizes : ∀ w : List Alpha, cl B w = evalLinearSystem α β A w

/-- A bundled realization structure. -/
structure ClosureRealization [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S) where
  dim : ℕ
  initVec : Fin dim → S
  finalVec : Fin dim → S
  transition : Alpha → (Fin dim → S) →ₗ[S] (Fin dim → S)
  isRealization : IsClosureRealization cl B dim initVec finalVec transition

/-! ## Reachability and Observability -/

/-- The reachable states of a realization: vectors of the form `A_w β`
for some word `w`. -/
def reachableStates [Semiring S] {n : ℕ}
    (β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) :
    Set (Fin n → S) :=
  { x | ∃ w : List Alpha, x = wordAction A w β }

/-- Two states are closure-indistinguishable if they produce the same
closed future behavior under all continuations. -/
def closureIndistinguishable [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S))
    {n : ℕ} (α : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (x y : Fin n → S) : Prop :=
  ∀ v : List Alpha, cl (fun w => dotProd α (wordAction A w x)) v =
                cl (fun w => dotProd α (wordAction A w y)) v

/-- A realization is observable if closure-indistinguishable states are equal. -/
structure IsClosureObservable [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S))
    {n : ℕ} (α : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) : Prop where
  observable : ∀ x y : Fin n → S,
    closureIndistinguishable cl α A x y → x = y

/-! ## Minimal Realizations -/

/-- A realization is minimal if it has the smallest dimension among
all realizations of the same closed behavior. -/
structure IsMinimalClosureRealization [Semiring S]
    (cl : (List Alpha → S) → (List Alpha → S))
    (B : List Alpha → S)
    (R : ClosureRealization (Alpha := Alpha) cl B) : Prop where
  minimal : ∀ R' : ClosureRealization (Alpha := Alpha) cl B, R.dim ≤ R'.dim

/-! ## Closure-Hankel Row Semimodule -/

/-- The set of all closure-Hankel rows of a behavior. -/
def closureHankelRowSet
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S) :
    Set (List Alpha → S) :=
  { f | ∃ u : List Alpha, f = closureHankelRow cl B u }

/-! ## Stabilization for Finite-Window Reconstruction -/

/-- The closure-Hankel rank is stable on finite prefix/suffix sets `P, Q`:
extending by one-letter shifts does not increase the rank. -/
def ClosureHankelRankStableOn [Semiring S] [Fintype Alpha]
    (cl : (List Alpha → S) → (List Alpha → S)) (B : List Alpha → S)
    (P Q : Finset (List Alpha)) : Prop :=
  ∃ (rank : ℕ) (generatorPrefixes : Fin rank → List Alpha),
    (∀ i, (generatorPrefixes i) ∈ P) ∧
    (∀ u ∈ P, ∃ coeffs : Fin rank → S,
      ∀ v ∈ Q, cl B (u ++ v) = ∑ i, coeffs i * cl B (generatorPrefixes i ++ v)) ∧
    (∀ u ∈ P, ∀ a : Alpha, ∃ coeffs : Fin rank → S,
      ∀ v ∈ Q, cl B ((u ++ [a]) ++ v) = ∑ i, coeffs i * cl B (generatorPrefixes i ++ v))

end