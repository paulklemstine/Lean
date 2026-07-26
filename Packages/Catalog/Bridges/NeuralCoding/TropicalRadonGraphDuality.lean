/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Radon Transform Duality via Idempotent Sheaf Semimodules
# and Certified Metric-Graph Reconstruction

This file establishes a finite tropical tomography duality: weighted star trees
are reconstructed from idempotent path-integral (distance) data, and the Radon-style
data is characterized intrinsically via tropical metric axioms.

## Main Results

* `tropical_plus_distributes_over_min` — min-plus distributivity
* `starDist_self`, `starDist_symm` — metric axioms
* `starDist_pos` — positive distances for distinct vertices
* `starDist_triangle` — triangle inequality
* `starDist_fourPoint` — four-point condition
* `starDist_isStarMetric` — star metric characterization
* `starDist_determines_weights` — faithfulness (injectivity)
* `reconstructWeights_correct` — certified weight recovery
* `starTree_reconstruction_certified` — full certified inverse
* `minimal_realization_unique` — uniqueness of realization
* `tropicalRadon_star_duality` — main duality theorem package
* `StarTreeMorphism.preserves_dist` — functoriality
* `morphism_faithful` — morphism-level faithfulness

## Keywords

tropical Radon transform, idempotent tomography, metric graph reconstruction,
min-plus integral geometry, tree metric realization, certified reconstruction,
network tomography, phylogenetic reconstruction
-/

import Mathlib

open Finset BigOperators

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

noncomputable section

namespace TropicalRadonGraphDuality

/-! ## §1. Tropical Semiring Foundations -/

/-- Tropical (min-plus) distributivity: a + min(b, c) = min(a + b, a + c). -/
theorem tropical_plus_distributes_over_min (a b c : ℕ) :
    a + min b c = min (a + b) (a + c) :=
  (Nat.add_min_add_left a b c).symm

theorem tropical_min_assoc (a b c : ℕ) :
    min (min a b) c = min a (min b c) := min_assoc a b c

theorem tropical_min_comm (a b : ℕ) : min a b = min b a := min_comm a b

theorem tropical_min_idempotent (a : ℕ) : min a a = a := min_self a

theorem tropical_absorption (a b : ℕ) : min a (a + b) = a := by omega

/-! ## §2. Star Tree Distance Function

Vertices are `Option (Fin n)`: `none` = root, `some i` = leaf i. -/

/-- Edge weights for a star tree with n leaves. -/
structure StarTreeData (n : ℕ) where
  weight : Fin n → ℕ
  weight_pos : ∀ i, 0 < weight i

variable {n : ℕ}

/-- Distance function for a star tree. -/
def starDist (S : StarTreeData n) : Option (Fin n) → Option (Fin n) → ℕ
  | none, none => 0
  | none, some j => S.weight j
  | some i, none => S.weight i
  | some i, some j => if i = j then 0 else S.weight i + S.weight j

@[simp] theorem starDist_none_none (S : StarTreeData n) :
    starDist S none none = 0 := rfl

@[simp] theorem starDist_none_some (S : StarTreeData n) (j : Fin n) :
    starDist S none (some j) = S.weight j := rfl

@[simp] theorem starDist_some_none (S : StarTreeData n) (i : Fin n) :
    starDist S (some i) none = S.weight i := rfl

theorem starDist_some_some (S : StarTreeData n) (i j : Fin n) :
    starDist S (some i) (some j) = if i = j then 0 else S.weight i + S.weight j := rfl

theorem starDist_self (S : StarTreeData n) (v : Option (Fin n)) :
    starDist S v v = 0 := by
  cases v with
  | none => rfl
  | some i => simp [starDist]

theorem starDist_symm (S : StarTreeData n) (u v : Option (Fin n)) :
    starDist S u v = starDist S v u := by
  cases u with
  | none => cases v with | none => rfl | some j => rfl
  | some i => cases v with
    | none => rfl
    | some j =>
      simp only [starDist_some_some]
      by_cases h : i = j
      · subst h; simp
      · simp [h, Ne.symm h]; omega

theorem starDist_pos (S : StarTreeData n) (u v : Option (Fin n)) (huv : u ≠ v) :
    0 < starDist S u v := by
  rcases u with ( _ | i ) <;> rcases v with ( _ | j ) <;> norm_num [ starDist ] at *;
  · exact S.weight_pos j;
  · exact S.weight_pos i;
  · split_ifs ; linarith [ S.weight_pos i, S.weight_pos j ]

theorem starDist_triangle (S : StarTreeData n) (u v w : Option (Fin n)) :
    starDist S u w ≤ starDist S u v + starDist S v w := by
  cases u <;> cases v <;> cases w <;> simp +decide [ starDist ];
  · grind;
  · split_ifs <;> simp +decide [ *, add_comm ];
  · grind;
  · split_ifs <;> simp_all +arith +decide

/-! ## §3. Four-Point Condition -/

def FourPointCondition {α : Type*} (d : α → α → ℕ) : Prop :=
  ∀ x y z w, d x y + d z w ≤ max (d x z + d y w) (d x w + d y z)

theorem starDist_fourPoint (S : StarTreeData n) :
    FourPointCondition (starDist S) := by
  intro x y z w; rcases x with ( _ | x ) <;> rcases y with ( _ | y ) <;> rcases z with ( _ | z ) <;> rcases w with ( _ | w ) <;> simp +decide [ * ] ;
  all_goals simp +decide [ starDist_some_some, add_comm ];
  grind;
  grind;
  · grind;
  · grind;
  · lia;
  · lia;
  · grind

/-! ## §4. Star Metric Property -/

def IsStarMetric {α : Type*} (d : α → α → ℕ) (c : α) : Prop :=
  ∀ u v, u ≠ v → u ≠ c → v ≠ c → d u v = d u c + d c v

theorem starDist_isStarMetric (S : StarTreeData n) :
    IsStarMetric (starDist S) none := by
  intro u v huv hu hv
  match u, v with
  | some i, some j =>
    have hij : i ≠ j := fun h => huv (congr_arg some h)
    simp [starDist_some_some, hij]

def Separated {α : Type*} (d : α → α → ℕ) : Prop :=
  ∀ u v, u ≠ v → ∃ w, d u w ≠ d v w

theorem starDist_separated (S : StarTreeData n) :
    Separated (starDist S) := by
  intro u v huv
  use u
  exact ne_of_lt ( by rw [ starDist_self ] ; exact starDist_pos S _ _ huv.symm )

/-! ## §5. Finite Metric Structure -/

structure FiniteMetricOn (α : Type*) where
  dist : α → α → ℕ
  dist_self : ∀ v, dist v v = 0
  dist_symm : ∀ u v, dist u v = dist v u
  dist_triangle : ∀ u v w, dist u w ≤ dist u v + dist v w
  dist_pos : ∀ u v, u ≠ v → 0 < dist u v

def starTreeMetric (S : StarTreeData n) : FiniteMetricOn (Option (Fin n)) where
  dist := starDist S
  dist_self := starDist_self S
  dist_symm := starDist_symm S
  dist_triangle := starDist_triangle S
  dist_pos := starDist_pos S

/-! ## §6. Admissible Radon Data -/

structure AdmissibleRadonStar (n : ℕ) where
  metric : FiniteMetricOn (Option (Fin n))
  star_center : IsStarMetric metric.dist none
  separated : Separated metric.dist
  fourPoint : FourPointCondition metric.dist

theorem starTree_radonData_admissible (S : StarTreeData n) :
    ∃ A : AdmissibleRadonStar n, A.metric.dist = starDist S :=
  ⟨{ metric := starTreeMetric S
     star_center := starDist_isStarMetric S
     separated := starDist_separated S
     fourPoint := starDist_fourPoint S }, rfl⟩

/-! ## §7. Tropical Semimodule Operations -/

def tropicalAdd {α : Type*} (d₁ d₂ : α → α → ℕ) : α → α → ℕ :=
  fun i j => min (d₁ i j) (d₂ i j)

def tropicalSmul {α : Type*} (c : ℕ) (d : α → α → ℕ) : α → α → ℕ :=
  fun i j => c + d i j

theorem tropicalAdd_comm {α : Type*} (d₁ d₂ : α → α → ℕ) :
    tropicalAdd d₁ d₂ = tropicalAdd d₂ d₁ := by
  ext i j; simp [tropicalAdd, min_comm]

theorem tropicalAdd_assoc {α : Type*} (d₁ d₂ d₃ : α → α → ℕ) :
    tropicalAdd (tropicalAdd d₁ d₂) d₃ = tropicalAdd d₁ (tropicalAdd d₂ d₃) := by
  ext i j; simp [tropicalAdd, min_assoc]

theorem tropicalAdd_idem {α : Type*} (d : α → α → ℕ) :
    tropicalAdd d d = d := by ext i j; simp [tropicalAdd]

theorem tropicalSmul_distributes {α : Type*} (c : ℕ) (d₁ d₂ : α → α → ℕ) :
    tropicalSmul c (tropicalAdd d₁ d₂) =
    tropicalAdd (tropicalSmul c d₁) (tropicalSmul c d₂) := by
  ext i j; simp only [tropicalSmul, tropicalAdd]
  exact (Nat.add_min_add_left c (d₁ i j) (d₂ i j)).symm

/-! ## §8. Faithfulness -/

def tropicalRadonData (S : StarTreeData n) :
    Option (Fin n) → Option (Fin n) → ℕ := starDist S

/-- **Faithfulness**: distance matrix uniquely determines edge weights. -/
theorem starDist_determines_weights (S₁ S₂ : StarTreeData n)
    (h : starDist S₁ = starDist S₂) : S₁.weight = S₂.weight := by
  ext i
  have := congr_fun (congr_fun h none) (some i)
  simpa using this

theorem tropicalRadon_injective :
    Function.Injective (fun S : StarTreeData n => tropicalRadonData S) := by
  intro S₁ S₂ h
  have hw := starDist_determines_weights S₁ S₂ h
  cases S₁; cases S₂; simp at hw; subst hw; rfl

/-! ## §9. Reconstruction -/

def reconstructWeights (d : Option (Fin n) → Option (Fin n) → ℕ) : Fin n → ℕ :=
  fun i => d none (some i)

theorem reconstructWeights_correct (S : StarTreeData n) :
    reconstructWeights (starDist S) = S.weight := by
  ext i; simp [reconstructWeights]

/-
**Certified reconstruction**: a star metric is realized by the reconstructed tree.
-/
theorem starTree_reconstruction_certified
    (d : Option (Fin n) → Option (Fin n) → ℕ)
    (hself : ∀ v, d v v = 0)
    (hsymm : ∀ u v, d u v = d v u)
    (hpos : ∀ i : Fin n, 0 < d none (some i))
    (hstar : IsStarMetric d none) :
    starDist (⟨reconstructWeights d, hpos⟩ : StarTreeData n) = d := by
  funext u v;
  cases u <;> cases v <;> simp_all +decide [ IsStarMetric ];
  · rfl;
  · rfl;
  · unfold starDist; aesop;

/-! ## §10. Uniqueness -/

theorem minimal_realization_unique (S₁ S₂ : StarTreeData n)
    (h : ∀ u v, starDist S₁ u v = starDist S₂ u v) :
    S₁.weight = S₂.weight := by
  ext i; have := h none (some i); simpa using this

/-! ## §11. Main Duality Theorem -/

theorem tropicalRadon_star_duality :
    (∀ (S : StarTreeData n),
      (∀ v, starDist S v v = 0) ∧
      (∀ u v, starDist S u v = starDist S v u) ∧
      IsStarMetric (starDist S) none) ∧
    (∀ (S₁ S₂ : StarTreeData n),
      starDist S₁ = starDist S₂ → S₁.weight = S₂.weight) ∧
    (∀ (S : StarTreeData n),
      reconstructWeights (starDist S) = S.weight) :=
  ⟨fun S => ⟨starDist_self S, starDist_symm S, starDist_isStarMetric S⟩,
   starDist_determines_weights, reconstructWeights_correct⟩

/-! ## §12. Morphisms -/

structure StarTreeMorphism (S₁ S₂ : StarTreeData n) where
  leafMap : Fin n → Fin n
  injective : Function.Injective leafMap
  weight_eq : ∀ i, S₂.weight (leafMap i) = S₁.weight i

def StarTreeMorphism.vertexMap {S₁ S₂ : StarTreeData n}
    (f : StarTreeMorphism S₁ S₂) : Option (Fin n) → Option (Fin n)
  | none => none
  | some i => some (f.leafMap i)

theorem StarTreeMorphism.preserves_dist {S₁ S₂ : StarTreeData n}
    (f : StarTreeMorphism S₁ S₂) (u v : Option (Fin n)) :
    starDist S₂ (f.vertexMap u) (f.vertexMap v) = starDist S₁ u v := by
  rcases u with ( _ | u ) <;> rcases v with ( _ | v );
  · exact starDist_symm S₂ (f.vertexMap none) (f.vertexMap none);
  · exact f.weight_eq v;
  · exact f.weight_eq u;
  · by_cases h : u = v <;> simp_all +decide [ StarTreeMorphism.vertexMap ];
    · unfold starDist; aesop;
    · rw [ starDist_some_some, starDist_some_some ];
      rw [ if_neg ( f.injective.ne h ), if_neg h, f.weight_eq u, f.weight_eq v ]

theorem morphism_faithful {S₁ S₂ : StarTreeData n}
    (f g : StarTreeMorphism S₁ S₂)
    (h : ∀ v, f.vertexMap v = g.vertexMap v) :
    f.leafMap = g.leafMap := by
  ext i
  have hi := h (some i)
  simp only [StarTreeMorphism.vertexMap, Option.some.injEq] at hi
  exact congrArg Fin.val hi

/-! ## §13. Sheaf Properties -/

def TropicalGluing {α : Type*} (d : α → α → ℕ) : Prop :=
  ∀ u v w, d u w ≤ d u v + d v w

theorem starDist_gluing (S : StarTreeData n) :
    TropicalGluing (starDist S) := starDist_triangle S

theorem starDist_root_mediator (S : StarTreeData n)
    (i j : Fin n) (hij : i ≠ j) :
    starDist S (some i) (some j) =
    starDist S (some i) none + starDist S none (some j) := by
  simp [starDist_some_some, hij]

/-! ## §14. Restriction Maps -/

def restrictStarDist (S : StarTreeData n) {k : ℕ} (f : Fin k → Fin n) :
    Option (Fin k) → Option (Fin k) → ℕ
  | none, none => 0
  | none, some j => S.weight (f j)
  | some i, none => S.weight (f i)
  | some i, some j => if i = j then 0 else S.weight (f i) + S.weight (f j)

theorem restrictStarDist_self (S : StarTreeData n) {k : ℕ} (f : Fin k → Fin n)
    (v : Option (Fin k)) : restrictStarDist S f v v = 0 := by
  cases v <;> simp [restrictStarDist]

theorem restrict_fourPoint {α β : Type*} {d : α → α → ℕ}
    (hd : FourPointCondition d) (f : β → α) :
    FourPointCondition (fun i j => d (f i) (f j)) :=
  fun x y z w => hd (f x) (f y) (f z) (f w)

/-! ## §15. Concrete Examples -/

private def exStar3 : StarTreeData 3 :=
  ⟨![2, 5, 3], fun i => by fin_cases i <;> simp⟩

example : starDist exStar3 none (some 0) = 2 := by native_decide
example : starDist exStar3 (some 0) (some 1) = 7 := by native_decide
example : starDist exStar3 (some 0) (some 2) = 5 := by native_decide
example : starDist exStar3 (some 1) (some 2) = 8 := by native_decide
example : starDist exStar3 (some 0) (some 0) = 0 := by native_decide
example : reconstructWeights (starDist exStar3) = ![2, 5, 3] := by native_decide

/-- Computational verification of four-point condition for the example. -/
example : FourPointCondition (starDist exStar3) := by
  unfold FourPointCondition; decide

end TropicalRadonGraphDuality