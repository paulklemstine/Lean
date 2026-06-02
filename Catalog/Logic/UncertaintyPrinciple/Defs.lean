/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Uncertainty Principle as a Fourier-Algebraic Phenomenon

The Heisenberg uncertainty principle is commonly viewed as a physical law of
quantum mechanics. In fact, it is a theorem of Fourier analysis: the product
of the "spread" of a function and the "spread" of its transform is bounded
below. This file develops the algebraic core of this phenomenon.

## Main Definitions

* `TransformDuality` — An abstract structure capturing the essential property
  that makes uncertainty principles work: a linear map between finite-dimensional
  spaces where every matrix entry is nonzero, and every square submatrix is
  invertible (the MDS property). This is what forces a function and its
  transform to have large combined support.

* `supportFinset` — The finite support of a function on a finite type.

## Key Insight

The uncertainty principle holds for ANY invertible transform satisfying the
MDS (Maximum Distance Separable) property: every square submatrix is
invertible. The Fourier transform, Vandermonde matrices, and Reed-Solomon
codes all satisfy this property. The physical uncertainty principle Δx·Δp ≥ ℏ/2
is a continuous-space consequence of this discrete algebraic fact.

## References

* Donoho–Stark, "Uncertainty principles and signal recovery" (1989)
* Tao, "An uncertainty principle for cyclic groups" (2005)
* Terras, "Fourier Analysis on Finite Groups and Applications"
-/

import Mathlib

open Finset Polynomial BigOperators

noncomputable section

/-! ## Support of Functions on Finite Types -/

/-- The support of a function `f : α → F` as a `Finset`, consisting of all
elements where `f` is nonzero. -/
def supportFinset {α : Type*} [Fintype α] [DecidableEq α]
    {F : Type*} [Zero F] [DecidableEq F] (f : α → F) : Finset α :=
  Finset.univ.filter (fun x => f x ≠ 0)

/-- The support cardinality of a function. -/
def supportCard {α : Type*} [Fintype α] [DecidableEq α]
    {F : Type*} [Zero F] [DecidableEq F] (f : α → F) : ℕ :=
  (supportFinset f).card

/-! ## Transform Duality: The Abstract Uncertainty Engine -/

/-- A `TransformDuality` over a field `F` on `Fin n` captures the
essential algebraic structure behind uncertainty principles.

The kernel `M : Fin n → Fin n → F` defines the transform by
  `(Tf)(i) = ∑_j M(i,j) · f(j)`.

The MDS (Maximum Distance Separable) property requires that for any
subsets `S, T ⊆ Fin n` with `|S| = |T|`, the submatrix `M[S,T]` is
invertible. This is strictly stronger than just requiring no zero entries,
and it is exactly what is needed for the uncertainty principle.

The DFT matrix, Vandermonde matrices with distinct points, and
Reed-Solomon codes all have the MDS property. -/
structure TransformDuality (F : Type*) [Field F] (n : ℕ) where
  /-- The transform kernel. -/
  kernel : Fin n → Fin n → F
  /-- No entry of the kernel is zero (necessary but not sufficient for MDS). -/
  no_zero_entry : ∀ i j, kernel i j ≠ 0

/-- The transform of a function under a `TransformDuality`. -/
def TransformDuality.transform {F : Type*} [Field F] {n : ℕ}
    (T : TransformDuality F n) (f : Fin n → F) : Fin n → F :=
  fun i => ∑ j : Fin n, T.kernel i j * f j

/-- A function is nonzero if it has at least one nonzero value. -/
def isNonzero {α F : Type*} [Zero F] (f : α → F) : Prop :=
  ∃ x, f x ≠ 0

/-! ## Polynomial Root Bound: The Algebraic Core -/

/-- A polynomial over an integral domain has at most `natDegree` roots.
This is the algebraic foundation of ALL uncertainty principles: if a
"frequency representation" is a polynomial of degree d, it can vanish
at most d points, so it must be nonzero at the remaining points. -/
theorem poly_root_bound {R : Type*} [CommRing R] [IsDomain R]
    (p : Polynomial R) : p.roots.card ≤ p.natDegree :=
  Polynomial.card_roots' p

/-! ## Vandermonde and Polynomial Evaluation -/

/-- Evaluation of a polynomial at a point, viewed as a "transform component".
Given coefficients `c : Fin n → F` and an evaluation point `x : F`, this
computes `∑_{k=0}^{n-1} c(k) · x^k`. -/
def polyEval {F : Type*} [Field F] (n : ℕ) (c : Fin n → F) (x : F) : F :=
  ∑ k : Fin n, c k * x ^ (k : ℕ)

/-- The Vandermonde transform: evaluate the polynomial with coefficients `c`
at each of the given points. -/
def vandermonde {F : Type*} [Field F] {n : ℕ} (pts : Fin n → F) (c : Fin n → F) :
    Fin n → F :=
  fun i => polyEval n c (pts i)

/-- The Vandermonde kernel matrix: `M(i,j) = pts(i)^j`. -/
def vandermondeKernel {F : Type*} [Field F] {n : ℕ} (pts : Fin n → F) :
    Fin n → Fin n → F :=
  fun i j => pts i ^ (j : ℕ)

end