/-
Copyright (c) 2025. All rights reserved.

# Tropical Grassmannians and Dressians: Core Definitions

## Main definitions

* `PluckerVec r n` — a weight function on subsets of `Fin n`
* `MinAttainedTwice3` — minimum of three values is attained ≥ 2 times
* `InDressian r n w` — `w` satisfies all 3-term tropical Plücker relations
* `FourPointCondition n w` — four-point condition for rank-2 Plücker vectors
* `InTropicalGrassmannian r n w` — `w` is tropically realizable over ℝ
-/

import Mathlib

open Finset

/-! ### Plücker vectors -/

/-- A Plücker vector of rank `r` on `n` elements. -/
def PluckerVec (_r n : ℕ) := Finset (Fin n) → ℝ

/-! ### The minimum-attained-twice predicate -/

/-- The minimum of three reals is attained at least twice. -/
def MinAttainedTwice3 (a b c : ℝ) : Prop :=
  (a = b ∧ a ≤ c) ∨ (a = c ∧ a ≤ b) ∨ (b = c ∧ b ≤ a)

lemma MinAttainedTwice3.all_eq (a : ℝ) : MinAttainedTwice3 a a a :=
  Or.inl ⟨rfl, le_refl a⟩

lemma MinAttainedTwice3.perm23 {a b c : ℝ} (h : MinAttainedTwice3 a b c) :
    MinAttainedTwice3 a c b := by
  rcases h with ⟨hab, hac⟩ | ⟨hac, hab⟩ | ⟨hbc, ha⟩
  · exact Or.inr (Or.inl ⟨hab, hac⟩)
  · exact Or.inl ⟨hac, hab⟩
  · exact Or.inr (Or.inr ⟨hbc.symm, hbc ▸ ha⟩)

/-! ### The Dressian -/

/-- `w` is in the **Dressian** `Dr(r,n)`: all 3-term tropical Plücker relations hold. -/
def InDressian (r n : ℕ) (w : PluckerVec r n) : Prop :=
  ∀ (S : Finset (Fin n)), S.card = r - 2 →
  ∀ (a b c d : Fin n),
    a ∉ S → b ∉ S → c ∉ S → d ∉ S →
    a ≠ b → a ≠ c → a ≠ d → b ≠ c → b ≠ d → c ≠ d →
    MinAttainedTwice3
      (w (S ∪ {a, b}) + w (S ∪ {c, d}))
      (w (S ∪ {a, c}) + w (S ∪ {b, d}))
      (w (S ∪ {a, d}) + w (S ∪ {b, c}))

/-! ### Four-point condition (rank-2 specialization) -/

/-- The four-point condition for rank-2 Plücker vectors. -/
def FourPointCondition (n : ℕ) (w : PluckerVec 2 n) : Prop :=
  ∀ (a b c d : Fin n),
    a ≠ b → a ≠ c → a ≠ d → b ≠ c → b ≠ d → c ≠ d →
    MinAttainedTwice3
      (w {a, b} + w {c, d})
      (w {a, c} + w {b, d})
      (w {a, d} + w {b, c})

/-! ### Tropical Grassmannian -/

/-- Direct 3×3 determinant of columns `i, j, k` of a matrix `A`. -/
def detCols3 (A : Matrix (Fin 3) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  Matrix.det !![A 0 i, A 0 j, A 0 k;
                 A 1 i, A 1 j, A 1 k;
                 A 2 i, A 2 j, A 2 k]

/-- `w` is in the **tropical Grassmannian** `Trop(Gr(r,n))`: the matroid of
    weight-minimizing subsets is representable over `ℝ`.

    For rank 3 (the main case of interest), we define this using `detCols3`:
    there exists a 3×n real matrix such that the matroid of nonzero
    maximal minors matches the weight-minimal subsets. -/
noncomputable def InTropicalGrassmannian3 (n : ℕ) (w : PluckerVec 3 n) : Prop :=
  ∃ (A : Matrix (Fin 3) (Fin n) ℝ),
    (∀ (i j k : Fin n), i < j → j < k →
      (∀ (J : Finset (Fin n)), J.card = 3 → w {i, j, k} ≤ w J) →
        detCols3 A i j k ≠ 0) ∧
    (∀ (i j k : Fin n), i < j → j < k →
      (∃ (J : Finset (Fin n)), J.card = 3 ∧ w J < w {i, j, k}) →
        detCols3 A i j k = 0)

/-- General tropical Grassmannian (for arbitrary rank, using extractSubmatrix). -/
noncomputable def extractSubmatrix {r n : ℕ} {F : Type*}
    (A : Matrix (Fin r) (Fin n) F) (I : Finset (Fin n)) (hI : I.card = r) :
    Matrix (Fin r) (Fin r) F :=
  A.submatrix id (fun j => (I.orderIsoOfFin hI j))

noncomputable def pluckerMinor {r n : ℕ}
    (A : Matrix (Fin r) (Fin n) ℝ) (I : Finset (Fin n)) (hI : I.card = r) : ℝ :=
  (extractSubmatrix A I hI).det

noncomputable def InTropicalGrassmannian (r n : ℕ) (w : PluckerVec r n) : Prop :=
  ∃ (A : Matrix (Fin r) (Fin n) ℝ),
    (∀ (I : Finset (Fin n)) (hI : I.card = r),
      (∀ (J : Finset (Fin n)), J.card = r → w I ≤ w J) →
        pluckerMinor A I hI ≠ 0) ∧
    (∀ (I : Finset (Fin n)) (hI : I.card = r),
      (∃ (J : Finset (Fin n)), J.card = r ∧ w J < w I) →
        pluckerMinor A I hI = 0)