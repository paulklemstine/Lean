/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Min-plus (tropical) expression algebra

This file provides the min-plus expression algebra that underlies the
`Bridges.Skeleton` development of the tropical Satake skeleton.

An element of `MinPlusExpr n` is a formal expression in `n` variables built from
variables, tropical addition (`min`) and tropical multiplication (ordinary `+`),
i.e. the **min-plus** semiring.  Its evaluation `eval` at a real vector realises
the tropical semantics, and `eval_concave` records that every min-plus expression
is a concave function of the evaluation point (min is concave, `+` is affine).

`TropRelation` packages an equation `lhs = rhs` between two expressions; a real
vector *satisfies* the relation when both sides evaluate equally.  The
`(normalized) tropRelationLocus` of a list of relations is the polyhedral set of
vectors satisfying them (with a chosen base coordinate normalized to `0`).

Finally we record the Hecke-operator dynamics `heckeMap`, its fixed points, and
tropical eigencharacters, together with the basic lemmas relating eigenvalue `0`
to fixed points.
-/

noncomputable section

/-- A formal min-plus (tropical) expression in `n` variables. -/
inductive MinPlusExpr (n : ℕ) where
  | var : Fin n → MinPlusExpr n
  | trop_add : MinPlusExpr n → MinPlusExpr n → MinPlusExpr n
  | trop_mul : MinPlusExpr n → MinPlusExpr n → MinPlusExpr n

namespace MinPlusExpr

/-- Evaluate a min-plus expression at a real vector: `trop_add` is `min`,
`trop_mul` is ordinary addition. -/
def eval {n : ℕ} : MinPlusExpr n → (Fin n → ℝ) → ℝ
  | var i, v => v i
  | trop_add a b, v => min (a.eval v) (b.eval v)
  | trop_mul a b, v => a.eval v + b.eval v

@[simp] lemma eval_var {n : ℕ} (i : Fin n) (v : Fin n → ℝ) : (var i).eval v = v i := rfl

@[simp] lemma eval_trop_add {n : ℕ} (a b : MinPlusExpr n) (v : Fin n → ℝ) :
    (trop_add a b).eval v = min (a.eval v) (b.eval v) := rfl

@[simp] lemma eval_trop_mul {n : ℕ} (a b : MinPlusExpr n) (v : Fin n → ℝ) :
    (trop_mul a b).eval v = a.eval v + b.eval v := rfl

/-
Every min-plus expression is concave in the evaluation point.
-/
theorem eval_concave {n : ℕ} (e : MinPlusExpr n) (v w : Fin n → ℝ) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    e.eval (fun j => (1 - t) * v j + t * w j) ≥ (1 - t) * e.eval v + t * e.eval w := by
  induction' e with i a b ih_a ih_b;
  · simp [MinPlusExpr.eval];
  · simp [MinPlusExpr.eval];
    constructor <;> nlinarith [ min_le_left ( a.eval v ) ( b.eval v ), min_le_right ( a.eval v ) ( b.eval v ), min_le_left ( a.eval w ) ( b.eval w ), min_le_right ( a.eval w ) ( b.eval w ) ];
  · simp_all +decide [ MinPlusExpr.eval ] ; linarith!

end MinPlusExpr

/-- A tropical relation is an equation `lhs = rhs` between two min-plus
expressions. -/
structure TropRelation (n : ℕ) where
  lhs : MinPlusExpr n
  rhs : MinPlusExpr n

/-- A vector satisfies a tropical relation when both sides evaluate equally. -/
def TropRelation.satisfiedAt {n : ℕ} (r : TropRelation n) (v : Fin n → ℝ) : Prop :=
  r.lhs.eval v = r.rhs.eval v

/-- Apply a family of min-plus expressions coordinatewise (a Hecke operator). -/
def heckeMap {n : ℕ} (action : Fin n → MinPlusExpr n) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => (action i).eval v

/-- The locus of vectors satisfying every relation in a list. -/
def tropRelationLocus {n : ℕ} (rels : List (TropRelation n)) : Set (Fin n → ℝ) :=
  {v | ∀ r ∈ rels, r.satisfiedAt v}

/-- Vectors whose chosen `base` coordinate is normalized to `0`. -/
def NormalizedVectors {n : ℕ} (base : Fin n) : Set (Fin n → ℝ) :=
  {v | v base = 0}

/-- The relation locus intersected with the normalization slice. -/
def normalizedTropRelationLocus {n : ℕ} (rels : List (TropRelation n)) (base : Fin n) :
    Set (Fin n → ℝ) :=
  tropRelationLocus rels ∩ NormalizedVectors base

theorem mem_normalizedTropRelationLocus {n : ℕ} (rels : List (TropRelation n)) (base : Fin n)
    (v : Fin n → ℝ) :
    v ∈ normalizedTropRelationLocus rels base ↔
      (∀ r ∈ rels, r.satisfiedAt v) ∧ v base = 0 :=
  Iff.rfl

/-- A vector is a fixed point of a Hecke operator when it is unchanged. -/
def isHeckeFixedPoint {n : ℕ} (action : Fin n → MinPlusExpr n) (v : Fin n → ℝ) : Prop :=
  heckeMap action v = v

/-- A tropical eigencharacter: every coordinate is shifted by the eigenvalue. -/
def isTropicalEigencharacter {n : ℕ} (action : Fin n → MinPlusExpr n) (v : Fin n → ℝ)
    (eigval : ℝ) : Prop :=
  ∀ i, (action i).eval v = v i + eigval

theorem eigencharacter_zero_iff_fixedPoint {n : ℕ} (action : Fin n → MinPlusExpr n)
    (v : Fin n → ℝ) :
    isTropicalEigencharacter action v 0 ↔ isHeckeFixedPoint action v := by
  unfold isTropicalEigencharacter isHeckeFixedPoint heckeMap
  simp [funext_iff]

theorem normalized_eigencharacter_zero {n : ℕ} (action : Fin n → MinPlusExpr n) (base : Fin n)
    (v : Fin n → ℝ) (_hnorm : v base = 0) (eigval : ℝ)
    (heig : isTropicalEigencharacter action v eigval)
    (hbase : (action base).eval v = v base) : eigval = 0 := by
  have h := heig base
  rw [hbase] at h
  linarith

end