/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite-Field Kakeya: Definitions and Core Infrastructure

This file establishes the foundational definitions for the finite-field Kakeya problem:
- Affine lines over finite fields
- Kakeya sets (containing a line in every direction)
- Incidence counting for point-line configurations

These definitions serve as the formal backbone for the polynomial method proof
of the finite-field Kakeya lower bound (Dvir 2008).
-/
import Mathlib

open Finset MvPolynomial BigOperators

/-- An affine line in `F^n` parameterized by a base point and a nonzero direction. -/
structure AffineLine (F : Type*) (n : ℕ) [Field F] where
  base : Fin n → F
  dir  : Fin n → F
  dir_ne_zero : dir ≠ 0

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F] {n : ℕ}

/-- The set of points on an affine line over a finite field. -/
def AffineLine.pointSet (ℓ : AffineLine F n) : Set (Fin n → F) :=
  { p | ∃ t : F, p = ℓ.base + t • ℓ.dir }

/-- The finset of points on an affine line over a finite field. -/
noncomputable def AffineLine.points (ℓ : AffineLine F n) : Finset (Fin n → F) :=
  Finset.univ.image (fun t : F => ℓ.base + t • ℓ.dir)

/-- A subset `K` of `F^n` is Kakeya if it contains a full affine line
    in every nonzero direction. -/
def IsKakeya (n : ℕ) (K : Set (Fin n → F)) : Prop :=
  ∀ v : Fin n → F, v ≠ 0 →
    ∃ x : Fin n → F, ∀ t : F, (x + t • v) ∈ K

/-- Finset version: A finset `K` of `F^n` is Kakeya if it contains a full
    affine line in every nonzero direction. -/
def IsKakeyaFinset (n : ℕ) (K : Finset (Fin n → F)) : Prop :=
  ∀ v : Fin n → F, v ≠ 0 →
    ∃ x : Fin n → F, ∀ t : F, (x + t • v) ∈ K

/-- The number of incidences between a point set and a line family:
    the sum over all points of the number of lines passing through that point. -/
noncomputable def incidenceCount (P : Finset (Fin n → F)) (L : Finset (AffineLine F n)) : ℕ :=
  P.sum (fun p => (L.filter (fun ℓ => p ∈ ℓ.points)).card)