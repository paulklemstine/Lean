/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Min-Plus Algebra and Tropical Expression Evaluation

This file establishes the foundational min-plus (tropical) algebra infrastructure
for the Tropical Satake Skeleton theory. We define min-plus expressions as an
inductive type, prove their evaluation is well-defined, and establish key
structural properties including concavity (the dual of convexity for min-plus).

## Main definitions

* `MinPlusExpr` — inductive type of min-plus expressions over `Fin n` variables
* `MinPlusExpr.eval` — evaluation at a real-valued coordinate vector
* `TropRelation` — a tropicalized semiring relation (equality of two min-plus expressions)
* `tropRelationLocus` — the set of points satisfying a list of tropical relations

## Main results

* `eval_concave` — every min-plus expression evaluates to a concave function
* `affine_eval_combination` — affine expressions evaluate to affine functions
* `tropRelationLocus_cons` — the locus is built by successive intersections
* `heckeFixedPoint_iff_diagonal` — fixed points = diagonal of correspondence
* `eigencharacter_zero_iff_fixedPoint` — eigenvalue-0 characters = fixed points
* `normalized_eigencharacter_zero` — normalization forces eigenvalue 0
-/

noncomputable section

open Set Function Finset

/-! ## §1. Min-Plus Expressions -/

/-- A **min-plus expression** in `n` variables. These are the basic building blocks
    of tropicalized semiring relations. -/
inductive MinPlusExpr (n : ℕ) : Type where
  /-- A real constant. -/
  | const : ℝ → MinPlusExpr n
  /-- The i-th variable. -/
  | var : Fin n → MinPlusExpr n
  /-- Tropical addition: min of two expressions. -/
  | trop_add : MinPlusExpr n → MinPlusExpr n → MinPlusExpr n
  /-- Tropical multiplication: sum of two expressions. -/
  | trop_mul : MinPlusExpr n → MinPlusExpr n → MinPlusExpr n

namespace MinPlusExpr

/-- Evaluate a min-plus expression at a coordinate vector `v : Fin n → ℝ`. -/
def eval {n : ℕ} : MinPlusExpr n → (Fin n → ℝ) → ℝ
  | const c, _ => c
  | var i, v => v i
  | trop_add e₁ e₂, v => min (eval e₁ v) (eval e₂ v)
  | trop_mul e₁ e₂, v => eval e₁ v + eval e₂ v

@[simp] theorem eval_const {n : ℕ} (c : ℝ) (v : Fin n → ℝ) :
    (const c).eval v = c := rfl

@[simp] theorem eval_var {n : ℕ} (i : Fin n) (v : Fin n → ℝ) :
    (var i).eval v = v i := rfl

@[simp] theorem eval_trop_add {n : ℕ} (e₁ e₂ : MinPlusExpr n) (v : Fin n → ℝ) :
    (trop_add e₁ e₂).eval v = min (e₁.eval v) (e₂.eval v) := rfl

@[simp] theorem eval_trop_mul {n : ℕ} (e₁ e₂ : MinPlusExpr n) (v : Fin n → ℝ) :
    (trop_mul e₁ e₂).eval v = e₁.eval v + e₂.eval v := rfl

/-- Shift an expression by a constant (tropical scalar multiplication). -/
def shift {n : ℕ} (e : MinPlusExpr n) (c : ℝ) : MinPlusExpr n :=
  trop_mul e (const c)

@[simp] theorem eval_shift {n : ℕ} (e : MinPlusExpr n) (c : ℝ) (v : Fin n → ℝ) :
    (e.shift c).eval v = e.eval v + c := rfl

/-! ## §2. Structural Properties -/

/-- The **depth** of a min-plus expression. -/
def depth {n : ℕ} : MinPlusExpr n → ℕ
  | const _ => 0
  | var _ => 0
  | trop_add e₁ e₂ => 1 + max (depth e₁) (depth e₂)
  | trop_mul e₁ e₂ => 1 + max (depth e₁) (depth e₂)

/-- A min-plus expression without any `trop_add` (min) nodes is **affine**. -/
def isAffine {n : ℕ} : MinPlusExpr n → Prop
  | const _ => True
  | var _ => True
  | trop_add _ _ => False
  | trop_mul e₁ e₂ => isAffine e₁ ∧ isAffine e₂

/-- Affine min-plus expressions satisfy the affine combination property. -/
theorem affine_eval_combination {n : ℕ} (e : MinPlusExpr n) (he : e.isAffine)
    (v w : Fin n → ℝ) (t : ℝ) :
    e.eval (fun i => (1 - t) * v i + t * w i) =
    (1 - t) * e.eval v + t * e.eval w := by
  induction e with
  | const c => simp; ring
  | var i => simp
  | trop_add _ _ => exact absurd he (by simp [isAffine])
  | trop_mul e₁ e₂ ih₁ ih₂ =>
    obtain ⟨h1, h2⟩ : e₁.isAffine ∧ e₂.isAffine := he
    rw [eval_trop_mul, eval_trop_mul, eval_trop_mul, ih₁ h1, ih₂ h2]
    ring

/-- Every min-plus expression is **concave** (as a function ℝⁿ → ℝ).
    `min` preserves concavity and `+` of concave functions is concave. -/
theorem eval_concave {n : ℕ} (e : MinPlusExpr n) (v w : Fin n → ℝ)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    e.eval (fun i => (1 - t) * v i + t * w i) ≥
    (1 - t) * e.eval v + t * e.eval w := by
  induction e with
  | const c =>
    simp; nlinarith
  | var i =>
    simp
  | trop_add e₁ e₂ ih₁ ih₂ =>
    simp only [eval_trop_add, ge_iff_le]
    have h1 := ih₁
    have h2 := ih₂
    have hmm : min (e₁.eval (fun i => (1 - t) * v i + t * w i))
                   (e₂.eval (fun i => (1 - t) * v i + t * w i)) ≥
               min ((1 - t) * e₁.eval v + t * e₁.eval w)
                   ((1 - t) * e₂.eval v + t * e₂.eval w) :=
      min_le_min (by linarith) (by linarith)
    have hconv : min ((1 - t) * e₁.eval v + t * e₁.eval w)
                     ((1 - t) * e₂.eval v + t * e₂.eval w) ≥
                 (1 - t) * min (e₁.eval v) (e₂.eval v) +
                 t * min (e₁.eval w) (e₂.eval w) := by
      simp only [min_def]; split_ifs <;> nlinarith
    linarith
  | trop_mul e₁ e₂ ih₁ ih₂ =>
    simp only [eval_trop_mul, ge_iff_le]
    nlinarith

end MinPlusExpr

/-! ## §4. Tropical Relations and Relation Loci -/

/-- A **tropical relation** is an equality between two min-plus expressions. -/
structure TropRelation (n : ℕ) where
  /-- Left-hand side of the relation. -/
  lhs : MinPlusExpr n
  /-- Right-hand side of the relation. -/
  rhs : MinPlusExpr n

/-- A point satisfies a tropical relation if both sides evaluate equally. -/
def TropRelation.satisfiedAt {n : ℕ} (r : TropRelation n) (v : Fin n → ℝ) : Prop :=
  r.lhs.eval v = r.rhs.eval v

/-- The **locus** of a single tropical relation. -/
def TropRelation.locus {n : ℕ} (r : TropRelation n) : Set (Fin n → ℝ) :=
  {v | r.satisfiedAt v}

/-- The **tropical relation locus** of a list of relations: the intersection
    of all individual loci. -/
def tropRelationLocus {n : ℕ} (rels : List (TropRelation n)) : Set (Fin n → ℝ) :=
  {v | ∀ r ∈ rels, r.satisfiedAt v}

/-- Membership in the tropical relation locus. -/
theorem mem_tropRelationLocus {n : ℕ} (rels : List (TropRelation n)) (v : Fin n → ℝ) :
    v ∈ tropRelationLocus rels ↔ ∀ r ∈ rels, r.satisfiedAt v := by
  simp [tropRelationLocus]

/-- The empty relation system is satisfied everywhere. -/
@[simp] theorem tropRelationLocus_nil {n : ℕ} :
    tropRelationLocus ([] : List (TropRelation n)) = Set.univ := by
  ext v; simp [tropRelationLocus]

/-- Adding a relation restricts the locus. -/
theorem tropRelationLocus_cons {n : ℕ} (r : TropRelation n) (rels : List (TropRelation n)) :
    tropRelationLocus (r :: rels) = r.locus ∩ tropRelationLocus rels := by
  ext v; simp only [tropRelationLocus, TropRelation.locus, TropRelation.satisfiedAt,
    Set.mem_setOf_eq, Set.mem_inter_iff, List.mem_cons]
  constructor
  · intro h; exact ⟨h r (Or.inl rfl),
      fun r' hr' => h r' (Or.inr hr')⟩
  · intro ⟨h1, h2⟩ r' hr'
    rcases hr' with rfl | h
    · exact h1
    · exact h2 r' h

/-- More relations means a smaller locus. -/
theorem tropRelationLocus_mono {n : ℕ}
    (rels₁ rels₂ : List (TropRelation n))
    (h : ∀ r, r ∈ rels₁ → r ∈ rels₂) :
    tropRelationLocus rels₂ ⊆ tropRelationLocus rels₁ := by
  intro v hv; simp [tropRelationLocus] at *
  exact fun r hr => hv r (h r hr)

/-! ## §5. Normalized Character Vectors -/

/-- A **normalized vector** has a specified base coordinate equal to 0. -/
def NormalizedVectors (n : ℕ) (base : Fin n) : Set (Fin n → ℝ) :=
  {v : Fin n → ℝ | v base = 0}

/-- The normalized tropical relation locus. -/
def normalizedTropRelationLocus {n : ℕ} (rels : List (TropRelation n))
    (base : Fin n) : Set (Fin n → ℝ) :=
  tropRelationLocus rels ∩ NormalizedVectors n base

theorem mem_normalizedTropRelationLocus {n : ℕ} (rels : List (TropRelation n))
    (base : Fin n) (v : Fin n → ℝ) :
    v ∈ normalizedTropRelationLocus rels base ↔
    (∀ r ∈ rels, r.satisfiedAt v) ∧ v base = 0 := by
  simp [normalizedTropRelationLocus, tropRelationLocus, NormalizedVectors]

/-! ## §6. Hecke Correspondences -/

/-- The **Hecke map** defined by min-plus expressions on each coordinate. -/
def heckeMap {n : ℕ} (action : Fin n → MinPlusExpr n) : (Fin n → ℝ) → (Fin n → ℝ) :=
  fun v i => (action i).eval v

/-- The **Hecke correspondence** is the graph of the Hecke map. -/
def heckeCorrespondence {n : ℕ}
    (action : Fin n → MinPlusExpr n) : Set ((Fin n → ℝ) × (Fin n → ℝ)) :=
  {p | p.2 = heckeMap action p.1}

/-- The Hecke correspondence is functional (graph of a function). -/
theorem heckeCorrespondence_functional {n : ℕ}
    (action : Fin n → MinPlusExpr n) :
    ∀ v : Fin n → ℝ, ∃! w : Fin n → ℝ, (v, w) ∈ heckeCorrespondence action := by
  intro v
  refine ⟨heckeMap action v, rfl, fun w (hw : (v, w) ∈ heckeCorrespondence action) => ?_⟩
  simp only [heckeCorrespondence, Set.mem_setOf_eq] at hw
  exact hw

/-- A **fixed point** of the Hecke map. -/
def isHeckeFixedPoint {n : ℕ} (action : Fin n → MinPlusExpr n)
    (v : Fin n → ℝ) : Prop :=
  heckeMap action v = v

/-- Fixed points correspond to the diagonal of the correspondence. -/
theorem heckeFixedPoint_iff_diagonal {n : ℕ}
    (action : Fin n → MinPlusExpr n) (v : Fin n → ℝ) :
    isHeckeFixedPoint action v ↔ (v, v) ∈ heckeCorrespondence action := by
  simp only [isHeckeFixedPoint, heckeCorrespondence, Set.mem_setOf_eq]
  exact ⟨fun h => h.symm, fun h => h.symm⟩

/-! ## §7. Eigencharacter Fixed-Point Theorem -/

/-- A **tropical eigencharacter** with eigenvalue `eigval`: applying the action
    shifts all coordinates uniformly by `eigval`. -/
def isTropicalEigencharacter {n : ℕ} (action : Fin n → MinPlusExpr n)
    (v : Fin n → ℝ) (eigval : ℝ) : Prop :=
  ∀ i, (action i).eval v = v i + eigval

/-- Tropical eigencharacters with eigenvalue 0 are exactly the fixed points
    of the Hecke map. -/
theorem eigencharacter_zero_iff_fixedPoint {n : ℕ}
    (action : Fin n → MinPlusExpr n) (v : Fin n → ℝ) :
    isTropicalEigencharacter action v 0 ↔ isHeckeFixedPoint action v := by
  constructor
  · intro h
    ext i
    simp [heckeMap]
    linarith [h i]
  · intro h i
    have : heckeMap action v i = v i := congr_fun h i
    simp [heckeMap] at this
    linarith

/-- For normalized vectors, eigenvalue is forced to 0 if the base coordinate
    is preserved by the action. -/
theorem normalized_eigencharacter_zero {n : ℕ}
    (action : Fin n → MinPlusExpr n) (base : Fin n)
    (v : Fin n → ℝ) (_hv : v base = 0) (eigval : ℝ)
    (heig : isTropicalEigencharacter action v eigval)
    (hbase : (action base).eval v = v base) :
    eigval = 0 := by
  have h := heig base
  linarith

/-! ## §8. Composition of Hecke Maps -/

/-- The composition of two Hecke maps corresponds to the composition of the
    underlying actions. -/
theorem heckeMap_comp {n : ℕ}
    (action₁ action₂ : Fin n → MinPlusExpr n) (v : Fin n → ℝ) :
    heckeMap action₂ (heckeMap action₁ v) =
    (fun i => (action₂ i).eval (heckeMap action₁ v)) := by
  ext i; simp [heckeMap]

/-- The identity action: each coordinate maps to itself. -/
def idAction (n : ℕ) : Fin n → MinPlusExpr n :=
  fun i => MinPlusExpr.var i

/-- The identity action gives the identity map. -/
@[simp] theorem heckeMap_id {n : ℕ} (v : Fin n → ℝ) :
    heckeMap (idAction n) v = v := by
  ext i; simp [heckeMap, idAction]

/-- Every point is a fixed point of the identity action. -/
theorem id_isHeckeFixedPoint {n : ℕ} (v : Fin n → ℝ) :
    isHeckeFixedPoint (idAction n) v := by
  simp [isHeckeFixedPoint]

end