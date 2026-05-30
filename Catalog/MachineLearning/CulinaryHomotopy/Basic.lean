/-
# Homotopy Type Theory of Cooking Recipes: Paths Between Dishes

## Overview
We formalize the idea that the space of recipes producing a given flavor profile
has rich combinatorial and topological structure. Recipes are modeled as selections
from ingredient slots, and the "substitution graph" (a Hamming graph) captures
single-ingredient changes. We prove structural theorems about this graph and
connect it to coding theory and metric geometry.

## Cross-Domain Connection
The substitution graph on recipes is precisely the Hamming graph H(n,m),
connecting culinary science to coding theory.
-/

import Mathlib

namespace CulinaryHomotopy

open Finset

/-! ## Core Definitions -/

/-- A flavor profile in n-dimensional taste space. -/
abbrev FlavorProfile (n : ℕ) := Fin n → ℝ

/-- A recipe selects one of m possible ingredients for each of n ingredient slots. -/
abbrev Recipe (n m : ℕ) := Fin n → Fin m

/-- The Hamming distance between two recipes. -/
noncomputable def hammingDist {n m : ℕ} (r₁ r₂ : Recipe n m) : ℕ :=
  (Finset.univ.filter (fun i => r₁ i ≠ r₂ i)).card

/-- Two recipes are *adjacent* if they differ in exactly one ingredient slot. -/
def adjacent {n m : ℕ} (r₁ r₂ : Recipe n m) : Prop :=
  hammingDist r₁ r₂ = 1

/-- A flavor map assigns a real-valued flavor profile to each recipe. -/
structure FlavorMap (n m d : ℕ) where
  map : Recipe n m → FlavorProfile d

/-- Two recipes are *flavor-equivalent* if they produce the same flavor profile. -/
def flavorEquiv {n m d : ℕ} (F : FlavorMap n m d) (r₁ r₂ : Recipe n m) : Prop :=
  F.map r₁ = F.map r₂

/-- The fiber of a flavor profile: all recipes that produce it. -/
def flavorFiber {n m d : ℕ} (F : FlavorMap n m d) (p : FlavorProfile d) : Set (Recipe n m) :=
  {r | F.map r = p}

/-- The set of neighbors of a recipe in the substitution graph. -/
def neighbors {n m : ℕ} (r : Recipe n m) : Set (Recipe n m) :=
  {r' | adjacent r r'}

/-! ## Fundamental Theorems -/

/-- Hamming distance of a recipe with itself is zero. -/
theorem hammingDist_self {n m : ℕ} (r : Recipe n m) :
    hammingDist r r = 0 := by
  simp [hammingDist]

/-- Hamming distance is symmetric. -/
theorem hammingDist_symm {n m : ℕ} (r₁ r₂ : Recipe n m) :
    hammingDist r₁ r₂ = hammingDist r₂ r₁ := by
  simp [hammingDist, ne_comm]

/-- Hamming distance is at most n (the number of ingredient slots). -/
theorem hammingDist_le {n m : ℕ} (r₁ r₂ : Recipe n m) :
    hammingDist r₁ r₂ ≤ n := by
  unfold hammingDist
  calc (Finset.univ.filter (fun i => r₁ i ≠ r₂ i)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-- Zero Hamming distance iff recipe equality. -/
theorem hammingDist_eq_zero_iff {n m : ℕ} (r₁ r₂ : Recipe n m) :
    hammingDist r₁ r₂ = 0 ↔ r₁ = r₂ := by
  simp [hammingDist, Finset.filter_eq_empty_iff, funext_iff]

/-- Flavor equivalence is an equivalence relation. -/
theorem flavorEquiv_equivalence {n m d : ℕ} (F : FlavorMap n m d) :
    Equivalence (flavorEquiv F) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-! ## Hamming Triangle Inequality -/

/-
The Hamming distance satisfies the triangle inequality.
Proof idea: if r₁ i ≠ r₃ i, then either r₁ i ≠ r₂ i or r₂ i ≠ r₃ i.
-/
theorem hammingDist_triangle {n m : ℕ} (r₁ r₂ r₃ : Recipe n m) :
    hammingDist r₁ r₃ ≤ hammingDist r₁ r₂ + hammingDist r₂ r₃ := by
  exact le_trans ( Finset.card_mono fun i hi => by by_cases hi1 : r₁ i = r₂ i <;> by_cases hi2 : r₂ i = r₃ i <;> aesop ) ( Finset.card_union_le _ _ )

/-! ## Fiber Structure Theorems -/

/-- If the flavor map is injective, every fiber has at most one element. -/
theorem fiber_subsingleton_of_injective {n m d : ℕ} (F : FlavorMap n m d)
    (hF : Function.Injective F.map) (p : FlavorProfile d) :
    Set.Subsingleton (flavorFiber F p) := by
  intro r₁ hr₁ r₂ hr₂
  exact hF (hr₁.trans hr₂.symm)

/-- If the flavor map is surjective, every fiber is nonempty. -/
theorem fiber_nonempty_of_surjective {n m d : ℕ} (F : FlavorMap n m d)
    (hF : Function.Surjective F.map) (p : FlavorProfile d) :
    (flavorFiber F p).Nonempty := by
  obtain ⟨r, hr⟩ := hF p
  exact ⟨r, hr⟩

/-! ## Diameter -/

/-
For m ≥ 2, there exist two recipes at maximum Hamming distance n.
-/
theorem diameter_achieved {n : ℕ} {m : ℕ} (hm : 2 ≤ m) :
    ∃ r₁ r₂ : Recipe n m, hammingDist r₁ r₂ = n := by
  use fun _ => ⟨ 0, by linarith ⟩, fun _ => ⟨ 1, by linarith ⟩;
  unfold hammingDist; aesop;

/-! ## Flavor Lipschitz Continuity -/

/-- A flavor map is K-Lipschitz w.r.t. Hamming metric and norm on ℝ^d. -/
def isLipschitz {n m d : ℕ} (F : FlavorMap n m d) (K : ℝ) : Prop :=
  ∀ r₁ r₂ : Recipe n m,
    ‖F.map r₁ - F.map r₂‖ ≤ K * (hammingDist r₁ r₂ : ℝ)

/-- A Lipschitz flavor map sends adjacent recipes to nearby profiles. -/
theorem lipschitz_adjacent_bound {n m d : ℕ} (F : FlavorMap n m d) (K : ℝ)
    (hK : isLipschitz F K)
    (r₁ r₂ : Recipe n m) (hadj : adjacent r₁ r₂) :
    ‖F.map r₁ - F.map r₂‖ ≤ K := by
  have h := hK r₁ r₂
  unfold adjacent at hadj
  rw [hadj] at h
  simp only [Nat.cast_one, mul_one] at h
  exact h

/-- Lipschitz continuity gives a diameter bound on flavor space. -/
theorem lipschitz_diameter_bound {n m d : ℕ} (F : FlavorMap n m d) (K : ℝ)
    (hK : isLipschitz F K) (hKnn : 0 ≤ K) (r₁ r₂ : Recipe n m) :
    ‖F.map r₁ - F.map r₂‖ ≤ K * n := by
  calc ‖F.map r₁ - F.map r₂‖
      ≤ K * (hammingDist r₁ r₂ : ℝ) := hK r₁ r₂
    _ ≤ K * n := by
        apply mul_le_mul_of_nonneg_left _ hKnn
        exact_mod_cast hammingDist_le r₁ r₂

/-! ## The Substitution Monoid -/

/-- A substitution operation: change slot i to value v. -/
def Substitution (n m : ℕ) := Fin n × Fin m

/-- Apply a substitution to a recipe. -/
def applySubst {n m : ℕ} (s : Substitution n m) (r : Recipe n m) : Recipe n m :=
  Function.update r s.1 s.2

/-- Applying a substitution that matches the current value is the identity. -/
theorem applySubst_noop {n m : ℕ} (s : Substitution n m) (r : Recipe n m)
    (h : r s.1 = s.2) : applySubst s r = r := by
  simp [applySubst, h]

/-- Substitution sequences by list. -/
def applySubstSeq {n m : ℕ} (ss : List (Substitution n m)) (r : Recipe n m) : Recipe n m :=
  ss.foldl (fun r s => applySubst s r) r

/-- The empty substitution sequence is the identity. -/
theorem applySubstSeq_nil {n m : ℕ} (r : Recipe n m) :
    applySubstSeq [] r = r := rfl

/-- Substitution sequences compose by list concatenation. -/
theorem applySubstSeq_append {n m : ℕ} (ss₁ ss₂ : List (Substitution n m))
    (r : Recipe n m) :
    applySubstSeq (ss₁ ++ ss₂) r = applySubstSeq ss₂ (applySubstSeq ss₁ r) := by
  simp [applySubstSeq, List.foldl_append]

/-! ## Recipe Space Cardinality -/

/-
The total number of recipes is m^n.
-/
theorem recipe_space_card {n m : ℕ} :
    Fintype.card (Recipe n m) = m ^ n := by
  convert Fintype.card_pi; aesop;

/-! ## Hamming Ball Structure -/

/-- The Hamming ball of radius r. -/
def hammingBall {n m : ℕ} (center : Recipe n m) (r : ℕ) : Set (Recipe n m) :=
  {r' | hammingDist center r' ≤ r}

/-- Every recipe is in its own Hamming ball. -/
theorem mem_hammingBall_self {n m : ℕ} (r : Recipe n m) (k : ℕ) :
    r ∈ hammingBall r k := by
  simp [hammingBall, hammingDist_self]

/-- The Hamming ball of radius 0 is a singleton. -/
theorem hammingBall_zero {n m : ℕ} (center : Recipe n m) :
    hammingBall center 0 = {center} := by
  ext r'
  simp only [hammingBall, Set.mem_setOf_eq, Nat.le_zero, Set.mem_singleton_iff]
  constructor
  · intro h; exact ((hammingDist_eq_zero_iff center r').mp h).symm
  · intro h; rw [h]; exact hammingDist_self center

/-- The Hamming ball of radius n is the entire space. -/
theorem hammingBall_full {n m : ℕ} (center : Recipe n m) :
    hammingBall center n = Set.univ := by
  ext r'
  simp [hammingBall]
  exact hammingDist_le center r'

/-! ## Constant Flavor Map Fiber -/

/-- For a constant flavor map, the fiber is the entire recipe space. -/
theorem constant_map_full_fiber (n m d : ℕ) (v : FlavorProfile d) :
    flavorFiber (⟨fun _ => v⟩ : FlavorMap n m d) v = Set.univ := by
  ext r
  simp [flavorFiber]

/-! ## Adjacency Symmetry -/

/-- Adjacency in the substitution graph is symmetric. -/
theorem adjacent_symm {n m : ℕ} (r₁ r₂ : Recipe n m) :
    adjacent r₁ r₂ ↔ adjacent r₂ r₁ := by
  simp [adjacent, hammingDist_symm]

/-! ## Novel Structure: The Flavor Groupoid -/

/-- Two recipes differ at exactly position i and agree elsewhere. -/
def diffAtExactly {n m : ℕ} (r₁ r₂ : Recipe n m) (i : Fin n) : Prop :=
  r₁ i ≠ r₂ i ∧ ∀ j, j ≠ i → r₁ j = r₂ j

/-- A *flavor-preserving substitution* changes one ingredient without changing flavor. -/
def isFlavorPreservingSub {n m d : ℕ} (F : FlavorMap n m d) (r₁ r₂ : Recipe n m) : Prop :=
  adjacent r₁ r₂ ∧ flavorEquiv F r₁ r₂

/-- A flavor-preserving substitution stays within a single fiber. -/
theorem flavorPreserving_in_fiber {n m d : ℕ} (F : FlavorMap n m d)
    (r₁ r₂ : Recipe n m) (h : isFlavorPreservingSub F r₁ r₂) :
    r₂ ∈ flavorFiber F (F.map r₁) := by
  exact h.2.symm

end CulinaryHomotopy