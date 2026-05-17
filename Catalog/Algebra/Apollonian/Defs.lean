/-
Copyright (c) 2025 Apollonian Spectral Transfer Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Apollonian Gasket: Core Definitions

This file defines the fundamental objects for the Apollonian gasket dynamics:
- The Descartes quadratic form and its matrix representation
- The four Apollonian reflection generators
- Word-level orbit actions
- Polynomial observable spaces of bounded degree
-/

import Mathlib

open Matrix Finset BigOperators

/-! ## The Descartes Quadratic Form -/

/-- The Descartes quadratic form matrix `J = 2I₄ - 𝟙𝟙ᵀ`.
    Entries: `J_ii = 1`, `J_ij = -1` for `i ≠ j`. -/
def descartesMatrix : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, -1, -1, -1;
     -1, 1, -1, -1;
     -1, -1, 1, -1;
     -1, -1, -1, 1]

/-- The Descartes quadratic form: `Q(v) = 2∑ vᵢ² - (∑ vᵢ)²`.
    Equivalently, `Q(v) = vᵀ J v` where `J = descartesMatrix`. -/
def descartesQ (v : Fin 4 → ℤ) : ℤ :=
  dotProduct v (descartesMatrix.mulVec v)

/-! ## Apollonian Generators -/

/-- The `i`-th Apollonian generator `S_i`. This is the reflection that replaces
    the `i`-th curvature by `2 ∑_{j≠i} bⱼ - bᵢ`, keeping all other curvatures fixed.
    Each `S_i` is an involution preserving the Descartes form. -/
def apollonianGen : Fin 4 → Matrix (Fin 4) (Fin 4) ℤ
  | 0 => !![-1,  2,  2,  2;
             0,  1,  0,  0;
             0,  0,  1,  0;
             0,  0,  0,  1]
  | 1 => !![ 1,  0,  0,  0;
             2, -1,  2,  2;
             0,  0,  1,  0;
             0,  0,  0,  1]
  | 2 => !![ 1,  0,  0,  0;
             0,  1,  0,  0;
             2,  2, -1,  2;
             0,  0,  0,  1]
  | 3 => !![ 1,  0,  0,  0;
             0,  1,  0,  0;
             0,  0,  1,  0;
             2,  2,  2, -1]

/-- Apply the `i`-th Apollonian generator to a curvature vector. -/
def applyGen (i : Fin 4) (v : Fin 4 → ℤ) : Fin 4 → ℤ :=
  (apollonianGen i).mulVec v

/-- Apply a word (sequence of generator indices) to a curvature vector,
    reading left-to-right as outermost-first. -/
def applyWord : List (Fin 4) → (Fin 4 → ℤ) → (Fin 4 → ℤ)
  | [], v => v
  | i :: w, v => applyGen i (applyWord w v)

/-- The matrix corresponding to a word of generators (left-to-right product). -/
def wordMatrix : List (Fin 4) → Matrix (Fin 4) (Fin 4) ℤ
  | [] => 1
  | i :: w => apollonianGen i * wordMatrix w

/-! ## Polynomial Observables -/

/-- Precomposition of a multivariate polynomial with an Apollonian generator.
    Given `p : MvPolynomial (Fin 4) R` and generator index `i`,
    substitutes each variable `Xⱼ` by the linear form corresponding to
    the `j`-th row of `S_i`. -/
noncomputable def precomposeApollonian (R : Type*) [CommRing R]
    (i : Fin 4) (p : MvPolynomial (Fin 4) R) : MvPolynomial (Fin 4) R :=
  MvPolynomial.aeval
    (fun j => ∑ l : Fin 4,
      (MvPolynomial.C ((apollonianGen i j l : ℤ) : R)) * MvPolynomial.X l) p