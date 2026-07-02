/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# Tropical Satake Skeleton: Character Space Realization

This file establishes the **Tropical Satake Skeleton Reconstruction** theorem:
the normalized tropical character space of an idempotent semiring presentation
is realized as a polyhedral complex defined by tropicalized relations.

## Main results

* `charVectorMap_range_eq_skeleton` — characters biject onto the skeleton
* `rank2_satake_skeleton` — explicit skeleton for rank-2 Satake presentation
* `rank3_skeleton` — Weyl chamber skeleton for rank-3
* `skeleton_eq_of_same_locus` — presentation independence
* `skeleton_add_redundant` — redundant relations don't change the skeleton
-/

noncomputable section

open Set Function Finset MinPlusExpr

/-! ## §1. Hecke Semiring Presentations -/

structure HeckeSemiringPresentation (n : ℕ) where
  relations : List (TropRelation n)
  base : Fin n

def BuildingSkeleton {n : ℕ} (P : HeckeSemiringPresentation n) : Set (Fin n → ℝ) :=
  normalizedTropRelationLocus P.relations P.base

theorem mem_buildingSkeleton {n : ℕ} (P : HeckeSemiringPresentation n) (v : Fin n → ℝ) :
    v ∈ BuildingSkeleton P ↔
    (∀ r ∈ P.relations, r.satisfiedAt v) ∧ v P.base = 0 :=
  mem_normalizedTropRelationLocus P.relations P.base v

/-! ## §2. Characters and the Realization Theorem -/

structure TropChar {n : ℕ} (P : HeckeSemiringPresentation n) where
  val : Fin n → ℝ
  respects_rels : ∀ r ∈ P.relations, r.satisfiedAt val
  normalized : val P.base = 0

def charVectorMap {n : ℕ} (P : HeckeSemiringPresentation n) (χ : TropChar P) : Fin n → ℝ :=
  χ.val

theorem charVector_in_skeleton {n : ℕ} (P : HeckeSemiringPresentation n) (χ : TropChar P) :
    charVectorMap P χ ∈ BuildingSkeleton P := by
  rw [mem_buildingSkeleton]; exact ⟨χ.respects_rels, χ.normalized⟩

theorem skeleton_subset_range {n : ℕ} (P : HeckeSemiringPresentation n) :
    BuildingSkeleton P ⊆ Set.range (charVectorMap P) := by
  intro v hv; rw [mem_buildingSkeleton] at hv; exact ⟨⟨v, hv.1, hv.2⟩, rfl⟩

/-- **Realization theorem**: characters biject onto the skeleton. -/
theorem charVectorMap_range_eq_skeleton {n : ℕ} (P : HeckeSemiringPresentation n) :
    Set.range (charVectorMap P) = BuildingSkeleton P :=
  Set.Subset.antisymm
    (fun _ ⟨χ, hχ⟩ => hχ ▸ charVector_in_skeleton P χ)
    (skeleton_subset_range P)

theorem charVectorMap_injective {n : ℕ} (P : HeckeSemiringPresentation n) :
    Function.Injective (charVectorMap P) := by
  intro χ₁ χ₂ h; cases χ₁; cases χ₂; simp [charVectorMap] at h; congr

/-! ## §3. Hecke Generator Actions -/

structure HeckeGeneratorAction (n : ℕ) where
  action : Fin n → MinPlusExpr n

def HeckeGeneratorAction.toMap {n : ℕ} (T : HeckeGeneratorAction n) :
    (Fin n → ℝ) → (Fin n → ℝ) := heckeMap T.action

/-- The Hecke map is concave in each coordinate. -/
theorem HeckeGeneratorAction.map_concave {n : ℕ} (T : HeckeGeneratorAction n)
    (v w : Fin n → ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (i : Fin n) :
    (T.toMap (fun j => (1 - t) * v j + t * w j)) i ≥
    (1 - t) * (T.toMap v) i + t * (T.toMap w) i :=
  MinPlusExpr.eval_concave (T.action i) v w t ht0 ht1

/-! ## §4. Concrete Examples -/

/-- Rank-2 Satake: min(x₀, x₁) = x₁, forcing x₁ ≤ x₀. -/
def rank2_satake : HeckeSemiringPresentation 2 where
  relations := [{ lhs := .trop_add (.var 0) (.var 1), rhs := .var 1 }]
  base := 0

/-- The Satake skeleton is the non-positive ray. -/
theorem rank2_satake_skeleton :
    BuildingSkeleton rank2_satake = {v : Fin 2 → ℝ | v 0 = 0 ∧ v 1 ≤ 0} := by
  ext v
  rw [mem_buildingSkeleton]
  simp only [rank2_satake, Set.mem_setOf_eq]
  constructor
  · intro ⟨hrel, hbase⟩
    refine ⟨hbase, ?_⟩
    have h := hrel _ List.mem_cons_self
    simp only [TropRelation.satisfiedAt, eval_trop_add, eval_var] at h
    -- h : min (v 0) (v 1) = v 1, so v 1 ≤ v 0
    rw [hbase] at h
    -- h : min 0 (v 1) = v 1
    have : min (0 : ℝ) (v 1) = v 1 := h
    linarith [min_le_left (0 : ℝ) (v 1)]
  · intro ⟨hbase, hle⟩
    refine ⟨?_, hbase⟩
    intro r hr
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hr
    subst hr
    simp only [TropRelation.satisfiedAt, eval_trop_add, eval_var]
    rw [hbase, min_eq_right (by linarith)]

/-- Rank-3 Weyl chamber: min(x₀ + x₂, 2x₁) = 2x₁. -/
def rank3_weyl : HeckeSemiringPresentation 3 where
  relations := [{ lhs := .trop_add (.trop_mul (.var 0) (.var 2))
                                    (.trop_mul (.var 1) (.var 1)),
                  rhs := .trop_mul (.var 1) (.var 1) }]
  base := 0

/-- The rank-3 skeleton is the Weyl chamber. -/
theorem rank3_skeleton :
    BuildingSkeleton rank3_weyl = {v : Fin 3 → ℝ | v 0 = 0 ∧ v 1 + v 1 ≤ v 0 + v 2} := by
  ext v
  rw [mem_buildingSkeleton]
  simp only [rank3_weyl, Set.mem_setOf_eq]
  constructor
  · intro ⟨hrel, hbase⟩
    refine ⟨hbase, ?_⟩
    have h := hrel _ List.mem_cons_self
    simp only [TropRelation.satisfiedAt, eval_trop_add, eval_trop_mul, eval_var] at h
    -- h : min (v 0 + v 2) (v 1 + v 1) = v 1 + v 1
    linarith [min_le_left (v 0 + v 2) (v 1 + v 1)]
  · intro ⟨hbase, hineq⟩
    refine ⟨?_, hbase⟩
    intro r hr
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hr
    subst hr
    simp only [TropRelation.satisfiedAt, eval_trop_add, eval_trop_mul, eval_var]
    exact min_eq_right (by linarith)

/-! ## §5. Hecke Actions on Rank-2 -/

/-- Min action: x₁ ↦ min(x₀, x₁). Fixed points: x₁ ≤ x₀. -/
def rank2_min_act : HeckeGeneratorAction 2 where
  action := ![.var 0, .trop_add (.var 0) (.var 1)]

theorem rank2_min_fp_iff (v : Fin 2 → ℝ) :
    isHeckeFixedPoint rank2_min_act.action v ↔ v 1 ≤ v 0 := by
  unfold isHeckeFixedPoint; simp +decide [ rank2_min_act ] ;
  unfold heckeMap; simp +decide [ funext_iff, Fin.forall_fin_two ] ;

/-! ## §6. Presentation Independence -/

/-- Presentations with the same locus give the same skeleton. -/
theorem skeleton_eq_of_same_locus {n : ℕ}
    (P₁ P₂ : HeckeSemiringPresentation n) (hbase : P₁.base = P₂.base)
    (hlocus : tropRelationLocus P₁.relations = tropRelationLocus P₂.relations) :
    BuildingSkeleton P₁ = BuildingSkeleton P₂ := by
  simp only [BuildingSkeleton, normalizedTropRelationLocus, hlocus, hbase]

/-- Redundant relations don't change the skeleton. -/
theorem skeleton_add_redundant {n : ℕ} (P : HeckeSemiringPresentation n)
    (r : TropRelation n)
    (hredundant : ∀ v ∈ tropRelationLocus P.relations, r.satisfiedAt v) :
    BuildingSkeleton ⟨r :: P.relations, P.base⟩ = BuildingSkeleton P := by
  ext v
  simp only [BuildingSkeleton, normalizedTropRelationLocus, Set.mem_inter_iff,
    NormalizedVectors, Set.mem_setOf_eq, tropRelationLocus]
  constructor
  · intro ⟨hrel, hbase⟩
    exact ⟨fun r' hr' => hrel r' (List.mem_cons_of_mem r hr'), hbase⟩
  · intro ⟨hrel, hbase⟩
    exact ⟨fun r' hr' => by
      rcases List.mem_cons.mp hr' with rfl | h
      · exact hredundant v hrel
      · exact hrel r' h, hbase⟩

/-! ## §7. Eigencharacter Fixed-Point Connection -/

/-- Fixed points in the skeleton are eigencharacters with eigenvalue 0. -/
theorem skeleton_fixedPoint_is_eigencharacter {n : ℕ}
    (T : HeckeGeneratorAction n) (v : Fin n → ℝ)
    (hfp : isHeckeFixedPoint T.action v) :
    isTropicalEigencharacter T.action v 0 := by
  rwa [eigencharacter_zero_iff_fixedPoint]

/-- Eigencharacters in the skeleton have eigenvalue 0 when the base is preserved. -/
theorem skeleton_eigenvalue_zero {n : ℕ}
    (P : HeckeSemiringPresentation n) (T : HeckeGeneratorAction n)
    (v : Fin n → ℝ) (eigval : ℝ)
    (hv : v ∈ BuildingSkeleton P)
    (heig : isTropicalEigencharacter T.action v eigval)
    (hbase : (T.action P.base).eval v = v P.base) :
    eigval = 0 := by
  rw [mem_buildingSkeleton] at hv
  exact normalized_eigencharacter_zero T.action P.base v hv.2 eigval heig hbase

end