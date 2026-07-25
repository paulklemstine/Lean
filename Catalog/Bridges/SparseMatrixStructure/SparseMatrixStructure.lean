import Mathlib

/-!
# Sparse Matrix Structure Preservation under Tensor Rewrites

## Overview

This file formalizes a **support-sensitive denotational invariant** for a three-sorted
tensor rewrite calculus with sorts `{Scal, Vec, Mat}`. While semantic correctness
(preservation of denotation under rewrites) is established in `TensorSortedRewrite.lean`,
this file proves a qualitatively stronger property: rewriting preserves a computable
*row-sparsity bound*.

The key mathematical insight is that the distributive rewrite system cannot introduce
qualitatively new fill-in. Addition is the only source of support growth (additive),
while scalar multiplication preserves support exactly (for nonzero scalars).

## Main results

- `RowSparse.add`: row-`s`-sparse + row-`t`-sparse ⟹ row-`(s+t)`-sparse (Theorem 1)
- `RowSparse.smul`: scalar mult preserves row sparsity (Theorem 2)
- `rowSupport_smul_eq`: nonzero scalar preserves row support exactly (Theorem 2')
- `evalMat_rowSparse_bound`: semantic support bound via `matLeafCount` (Theorem 3)
- `rewrite_preserves_matLeafCount`: one-step mat rewrite preserves leaf count (Theorem 4)
- `normStepMat_preserves_matLeafCount`: normalization preserves leaf count (Theorem 5a)
- `normalize_rowSparse_bound`: normalization inherits support bound (Theorem 5)
- `rowSupport_add_eq_of_disjoint`: exact support under disjoint entries (Theorem 6)
-/

open Finset Matrix BigOperators

namespace SparseMatrix

/-! ## Part 0: Self-contained fragment of the tensor rewrite calculus -/

/-- The three sorts of the tensor calculus. -/
inductive TSort | scal | vec | mat
  deriving DecidableEq

/-- Terms of the tensor language, indexed by sort. -/
inductive TTerm : TSort → Type
  | scalVar  : ℕ → TTerm .scal
  | vecVar   : ℕ → TTerm .vec
  | matVar   : ℕ → TTerm .mat
  | scalAdd  : TTerm .scal → TTerm .scal → TTerm .scal
  | scalMul  : TTerm .scal → TTerm .scal → TTerm .scal
  | vecAdd   : TTerm .vec → TTerm .vec → TTerm .vec
  | matAdd   : TTerm .mat → TTerm .mat → TTerm .mat
  | smulVec  : TTerm .scal → TTerm .vec → TTerm .vec
  | smulMat  : TTerm .scal → TTerm .mat → TTerm .mat
  | mulVec   : TTerm .mat → TTerm .vec → TTerm .vec
  | dot      : TTerm .vec → TTerm .vec → TTerm .scal

/-- Semantic environment. -/
structure TEnv (R : Type*) (n : ℕ) where
  scalAssign : ℕ → R
  vecAssign  : ℕ → (Fin n → R)
  matAssign  : ℕ → Matrix (Fin n) (Fin n) R

variable {R : Type*} {n : ℕ} [CommRing R]

mutual
noncomputable def evalScal (env : TEnv R n) : TTerm .scal → R
  | .scalVar k    => env.scalAssign k
  | .scalAdd a b  => evalScal env a + evalScal env b
  | .scalMul a b  => evalScal env a * evalScal env b
  | .dot v w      => ∑ i : Fin n, evalVec env v i * evalVec env w i
noncomputable def evalVec (env : TEnv R n) : TTerm .vec → (Fin n → R)
  | .vecVar k    => env.vecAssign k
  | .vecAdd v w  => evalVec env v + evalVec env w
  | .smulVec a v => evalScal env a • evalVec env v
  | .mulVec A v  => Matrix.mulVec (evalMat env A) (evalVec env v)
noncomputable def evalMat (env : TEnv R n) : TTerm .mat → Matrix (Fin n) (Fin n) R
  | .matVar k    => env.matAssign k
  | .matAdd A B  => evalMat env A + evalMat env B
  | .smulMat a A => evalScal env a • evalMat env A
end

/-- One-step normalization for mat-sorted terms. -/
def normStepMat : TTerm .mat → TTerm .mat
  | .smulMat a (.matAdd A B) => .matAdd (.smulMat a A) (.smulMat a B)
  | t => t

theorem normStepMat_sound (env : TEnv R n) (t : TTerm .mat) :
    evalMat env (normStepMat t) = evalMat env t := by
  match t with
  | .matVar _ => rfl
  | .matAdd _ _ => rfl
  | .smulMat a t' =>
    match t' with
    | .matVar _ => rfl
    | .matAdd A B => simp [normStepMat, evalMat, smul_add]
    | .smulMat _ _ => rfl

/-- The mat-sorted rewrite rule. -/
inductive MatRewrite : TTerm .mat → TTerm .mat → Prop
  | smulMat_matAdd (a : TTerm .scal) (A B : TTerm .mat) :
      MatRewrite (.smulMat a (.matAdd A B)) (.matAdd (.smulMat a A) (.smulMat a B))

/-! ## Section 1: Row Support and Row Sparsity -/

variable [DecidableEq R]

/-- Row support of matrix `A` at row `i`. -/
def rowSupport (A : Matrix (Fin n) (Fin n) R) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j => A i j ≠ 0)

/-- A matrix is **row-`s`-sparse** if every row has at most `s` nonzero entries. -/
def RowSparse (s : ℕ) (A : Matrix (Fin n) (Fin n) R) : Prop :=
  ∀ i : Fin n, (rowSupport A i).card ≤ s

/-- Environment row-sparsity. -/
def EnvRowSparse (ρ : ℕ → Matrix (Fin n) (Fin n) R) (s : ℕ) : Prop :=
  ∀ x, RowSparse s (ρ x)

/-- Row-disjoint matrices. -/
def RowDisjoint (A B : Matrix (Fin n) (Fin n) R) : Prop :=
  ∀ i j, A i j ≠ 0 → B i j = 0

/-! ## Section 2: Support Containment Lemmas -/

theorem rowSupport_add_subset
    (A B : Matrix (Fin n) (Fin n) R) (i : Fin n) :
    rowSupport (A + B) i ⊆ rowSupport A i ∪ rowSupport B i := by
  intro j hj
  simp only [rowSupport, Finset.mem_filter, Finset.mem_univ, true_and] at hj ⊢
  simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
  by_contra h
  push_neg at h
  exact hj (show (A + B) i j = 0 by simp [h.1, h.2])

/-- Scalar multiple has support contained in the original. -/
theorem rowSupport_smul_subset
    (c : R) (A : Matrix (Fin n) (Fin n) R) (i : Fin n) :
    rowSupport (c • A) i ⊆ rowSupport A i := by
  intro j hj
  simp only [rowSupport, Finset.mem_filter, Finset.mem_univ, true_and] at hj ⊢
  intro heq
  exact hj (show (c • A) i j = 0 by simp [Matrix.smul_apply, heq])

/-- **Theorem 2'.** Nonzero scalar preserves row support exactly (for fields). -/
theorem rowSupport_smul_eq [NoZeroDivisors R]
    {c : R} (hc : c ≠ 0)
    (A : Matrix (Fin n) (Fin n) R) (i : Fin n) :
    rowSupport (c • A) i = rowSupport A i := by
  ext j
  simp only [rowSupport, Finset.mem_filter, Finset.mem_univ, true_and, Matrix.smul_apply,
    smul_eq_mul, ne_eq]
  constructor
  · exact fun h heq => h (by rw [heq, mul_zero])
  · exact fun h heq => h ((mul_eq_zero.mp heq).resolve_left hc)

/-! ## Section 3: Core Sparsity Theorems -/

/-- **Theorem 1.** Addition gives controlled support growth. -/
theorem RowSparse.add
    {s t : ℕ} {A B : Matrix (Fin n) (Fin n) R}
    (hA : RowSparse s A) (hB : RowSparse t B) :
    RowSparse (s + t) (A + B) := by
  intro i
  calc (rowSupport (A + B) i).card
      ≤ (rowSupport A i ∪ rowSupport B i).card :=
        Finset.card_le_card (rowSupport_add_subset A B i)
    _ ≤ (rowSupport A i).card + (rowSupport B i).card :=
        Finset.card_union_le _ _
    _ ≤ s + t := Nat.add_le_add (hA i) (hB i)

/-- **Theorem 2.** Scalar multiplication preserves row sparsity. -/
theorem RowSparse.smul
    {s : ℕ} {c : R} {A : Matrix (Fin n) (Fin n) R}
    (hA : RowSparse s A) :
    RowSparse s (c • A) := by
  intro i
  calc (rowSupport (c • A) i).card
      ≤ (rowSupport A i).card := Finset.card_le_card (rowSupport_smul_subset c A i)
    _ ≤ s := hA i

/-- Zero matrix is row-sparse. -/
theorem RowSparse.zero {s : ℕ} : RowSparse s (0 : Matrix (Fin n) (Fin n) R) := by
  intro i; simp [rowSupport]

/-- Monotonicity of RowSparse. -/
theorem RowSparse.mono {s t : ℕ} {A : Matrix (Fin n) (Fin n) R}
    (hA : RowSparse s A) (hst : s ≤ t) : RowSparse t A :=
  fun i => le_trans (hA i) hst

/-! ## Section 4: Exact Support under Disjoint Entries -/

/-- **Theorem 6.** Exact support under disjoint entries. -/
theorem rowSupport_add_eq_of_disjoint
    {A B : Matrix (Fin n) (Fin n) R}
    (hdisj : RowDisjoint A B) (i : Fin n) :
    rowSupport (A + B) i = rowSupport A i ∪ rowSupport B i := by
  apply Finset.Subset.antisymm (rowSupport_add_subset A B i)
  intro j hj
  simp only [rowSupport, Finset.mem_filter, Finset.mem_univ, true_and] at hj ⊢
  simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and] at hj
  rcases hj with h | h
  · have := hdisj i j h
    simp [this, h]
  · by_cases hA : A i j = 0
    · simp [hA, h]
    · exact absurd (hdisj i j hA) (by push_neg; exact h)

/-! ## Section 5: Syntactic Sparsity Budget -/

/-- Matrix leaf count — the sparsity budget multiplier. -/
def matLeafCount : TTerm .mat → ℕ
  | .matVar _ => 1
  | .matAdd A B => matLeafCount A + matLeafCount B
  | .smulMat _ A => matLeafCount A

/-- **Theorem 3.** Semantic support bound for all mat-sorted terms. -/
theorem evalMat_rowSparse_bound
    {s : ℕ}
    (env : TEnv ℝ n)
    (hρ : EnvRowSparse env.matAssign s) :
    ∀ t : TTerm .mat,
      RowSparse (matLeafCount t * s) (evalMat env t)
  | .matVar k => by
    simp [matLeafCount, evalMat, one_mul]
    exact hρ k
  | .matAdd A B => by
    simp only [matLeafCount, evalMat, add_mul]
    exact (evalMat_rowSparse_bound env hρ A).add (evalMat_rowSparse_bound env hρ B)
  | .smulMat a A => by
    simp only [matLeafCount, evalMat]
    exact (evalMat_rowSparse_bound env hρ A).smul

/-! ## Section 6: Rewrite-Step Invariance -/

/-- **Theorem 4.** Mat rewrite preserves leaf count. -/
theorem rewrite_preserves_matLeafCount
    {t u : TTerm .mat}
    (h : MatRewrite t u) :
    matLeafCount t = matLeafCount u := by
  cases h with
  | smulMat_matAdd a A B => simp [matLeafCount]

/-! ## Section 7: Normalization -/

/-- **Theorem 5a.** Normalization preserves leaf count. -/
theorem normStepMat_preserves_matLeafCount (t : TTerm .mat) :
    matLeafCount (normStepMat t) = matLeafCount t := by
  match t with
  | .matVar _ => rfl
  | .matAdd _ _ => rfl
  | .smulMat a t' =>
    match t' with
    | .matVar _ => rfl
    | .matAdd A B => simp [normStepMat, matLeafCount]
    | .smulMat _ _ => rfl

/-- **Theorem 5.** Normalization inherits the support bound. -/
theorem normalize_rowSparse_bound
    {s : ℕ}
    (env : TEnv ℝ n)
    (hρ : EnvRowSparse env.matAssign s) :
    ∀ t : TTerm .mat,
      RowSparse (matLeafCount t * s) (evalMat env (normStepMat t)) := by
  intro t
  rw [normStepMat_sound env t]
  exact evalMat_rowSparse_bound env hρ t

end SparseMatrix