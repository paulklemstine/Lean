/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MDS Matrices and the Discrete Uncertainty Principle — Definitions

This file defines the core concepts relating MDS (Maximum Distance Separable)
matrices to the discrete uncertainty principle.

## Main Definitions

* `vecSupport` — the support of a vector f : Fin n → F as a Finset
* `vecZeros` — the zero set of a vector
* `IsMDS` — the MDS property: every square submatrix is nonsingular
* `SatisfiesUP` — the uncertainty principle: |supp(f)| + |supp(Mf)| ≥ n + 1
* `CriticalSubmatrix` — a certificate witnessing failure of the MDS property

## References

* Donoho–Stark, "Uncertainty principles and signal recovery" (1989)
* Tao, "An uncertainty principle for cyclic groups of prime order" (2005)
-/

import Mathlib

open Matrix Finset BigOperators Function

noncomputable section

variable {F : Type*} [Field F] [DecidableEq F]

/-! ## Vector support and zero set -/

/-- The support of a vector `f : Fin n → F`: the set of indices where `f` is nonzero. -/
def vecSupport {n : ℕ} (f : Fin n → F) : Finset (Fin n) :=
  Finset.univ.filter (fun i => f i ≠ 0)

/-- The zero set of a vector `f : Fin n → F`: the set of indices where `f` vanishes. -/
def vecZeros {n : ℕ} (f : Fin n → F) : Finset (Fin n) :=
  Finset.univ.filter (fun i => f i = 0)

theorem vecSupport_union_vecZeros {n : ℕ} (f : Fin n → F) :
    vecSupport f ∪ vecZeros f = Finset.univ := by
  ext i; simp [vecSupport, vecZeros]; tauto

theorem vecSupport_disjoint_vecZeros {n : ℕ} (f : Fin n → F) :
    Disjoint (vecSupport f) (vecZeros f) :=
  Finset.disjoint_filter.mpr (fun _ _ h1 h2 => h1 h2)

@[simp]
theorem vecSupport_card_add_vecZeros_card {n : ℕ} (f : Fin n → F) :
    (vecSupport f).card + (vecZeros f).card = n := by
  rw [← Finset.card_union_of_disjoint (vecSupport_disjoint_vecZeros f),
      vecSupport_union_vecZeros, Finset.card_fin]

theorem vecSupport_nonempty_of_ne_zero {n : ℕ} {f : Fin n → F} (hf : f ≠ 0) :
    (vecSupport f).Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  apply hf; ext i
  have : ¬(f i ≠ 0) := by
    intro hfi
    have : i ∈ vecSupport f := by simp [vecSupport, hfi]
    rw [h] at this; simp at this
  push_neg at this; exact this

theorem mem_vecSupport_iff {n : ℕ} {f : Fin n → F} {i : Fin n} :
    i ∈ vecSupport f ↔ f i ≠ 0 := by
  simp [vecSupport]

theorem mem_vecZeros_iff {n : ℕ} {f : Fin n → F} {i : Fin n} :
    i ∈ vecZeros f ↔ f i = 0 := by
  simp [vecZeros]

/-! ## MDS property -/

/-- A matrix `M` over a field `F` is **MDS** (Maximum Distance Separable) if every
square submatrix has nonzero determinant. Formally, for every `k > 0` and every
pair of injections `r, c : Fin k ↪ Fin n`, `det(M.submatrix r c) ≠ 0`.

This is the algebraic characterization underlying Reed-Solomon codes and
the Singleton bound in coding theory. -/
def IsMDS {n : ℕ} (M : Matrix (Fin n) (Fin n) F) : Prop :=
  ∀ (k : ℕ) (_ : 0 < k) (r : Fin k ↪ Fin n) (c : Fin k ↪ Fin n),
    (M.submatrix r c).det ≠ 0

/-- A matrix satisfies the **discrete uncertainty principle** if for every nonzero
vector `f`, the supports of `f` and `Mf` together cover more than `n` positions:
`|supp(f)| + |supp(Mf)| ≥ n + 1`.

This is the strongest form of the discrete uncertainty principle, and it is
equivalent to the MDS property. -/
def SatisfiesUP {n : ℕ} (M : Matrix (Fin n) (Fin n) F) : Prop :=
  ∀ f : Fin n → F, f ≠ 0 →
    n + 1 ≤ (vecSupport f).card + (vecSupport (M.mulVec f)).card

/-! ## Critical submatrix certificate -/

/-- A **critical submatrix** certificate witnesses that a matrix `M` fails to be MDS.
It provides:
- A size `k > 0` and injections `rows, cols : Fin k ↪ Fin n`
  selecting a square submatrix
- A nonzero vector `witness` in the kernel of that submatrix

This structure enables constructive refutation of the MDS property and
directly yields a counterexample to the uncertainty principle. -/
structure CriticalSubmatrix {n : ℕ} (M : Matrix (Fin n) (Fin n) F) where
  /-- Size of the critical submatrix -/
  k : ℕ
  /-- The submatrix has positive size -/
  hk : 0 < k
  /-- Row injection selecting rows of the submatrix -/
  rows : Fin k ↪ Fin n
  /-- Column injection selecting columns of the submatrix -/
  cols : Fin k ↪ Fin n
  /-- A nonzero vector in the kernel of the submatrix -/
  witness : Fin k → F
  /-- The witness is nonzero -/
  witness_ne_zero : witness ≠ 0
  /-- The witness lies in the kernel of the submatrix -/
  kernel_eq : (M.submatrix rows cols).mulVec witness = 0

end