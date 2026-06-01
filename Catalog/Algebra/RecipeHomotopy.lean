/-
# Homotopy Type Theory of Cooking Recipes: Algebraic Structure of Recipe Spaces

## Overview
We formalize the recipe substitution graph as a Hamming graph and prove structural
theorems about its combinatorics. The key insight is that the space of recipes
for a dish, modeled as an assignment of ingredient choices to slots, carries the
structure of a Hamming graph H(n,m), connecting it to coding theory and metric
geometry.

## Main Results
1. The substitution graph has no triangles for m = 2 (hypercube is bipartite)
2. Translation maps preserve Hamming distance (vertex transitivity)
3. Disjoint substitutions commute (geodesic factorization)
4. Additive flavor maps have independent slot contributions
5. The substitution spectrum sums to m^n (binomial theorem application)
-/

import Mathlib

namespace RecipeHomotopy

open Finset Function

/-! ## Core Definitions -/

/-- A recipe with n ingredient slots and m choices per slot. -/
abbrev Recipe (n m : ℕ) := Fin n → Fin m

/-- The set of differing slots between two recipes. -/
def diffSet {n m : ℕ} (r₁ r₂ : Recipe n m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => r₁ i ≠ r₂ i)

/-- The Hamming distance between two recipes. -/
def hdist {n m : ℕ} (r₁ r₂ : Recipe n m) : ℕ := (diffSet r₁ r₂).card

theorem diffSet_comm {n m : ℕ} (r₁ r₂ : Recipe n m) : diffSet r₁ r₂ = diffSet r₂ r₁ := by
  ext i; simp [diffSet, ne_comm]

theorem diffSet_self {n m : ℕ} (r : Recipe n m) : diffSet r r = ∅ := by
  simp [diffSet]

theorem hdist_self {n m : ℕ} (r : Recipe n m) : hdist r r = 0 := by
  simp [hdist, diffSet_self]

theorem hdist_comm {n m : ℕ} (r₁ r₂ : Recipe n m) : hdist r₁ r₂ = hdist r₂ r₁ := by
  simp [hdist, diffSet_comm]

/-- The substitution graph: two recipes are adjacent iff they differ in exactly one slot. -/
def SubstGraph (n m : ℕ) : SimpleGraph (Recipe n m) where
  Adj r₁ r₂ := hdist r₁ r₂ = 1
  symm := by
    intro x y h
    show hdist y x = 1
    rw [hdist_comm]; exact h
  loopless := ⟨by
    intro x h
    have : hdist x x = 0 := hdist_self x
    omega⟩

instance {n m : ℕ} : DecidableRel (SubstGraph n m).Adj := by
  intro r₁ r₂; unfold SubstGraph hdist diffSet; exact inferInstance

/-! ## Basic Hamming Distance Properties -/

theorem hdist_eq_zero_iff {n m : ℕ} (r₁ r₂ : Recipe n m) :
    hdist r₁ r₂ = 0 ↔ r₁ = r₂ := by
  simp [hdist, diffSet, Finset.filter_eq_empty_iff, funext_iff]

theorem hdist_le_n {n m : ℕ} (r₁ r₂ : Recipe n m) : hdist r₁ r₂ ≤ n := by
  simp only [hdist, diffSet]
  calc (univ.filter (fun i => r₁ i ≠ r₂ i)).card
      ≤ univ.card := card_filter_le _ _
    _ = n := card_fin n

/-
Triangle inequality for Hamming distance.
-/
theorem hdist_triangle {n m : ℕ} (r₁ r₂ r₃ : Recipe n m) :
    hdist r₁ r₃ ≤ hdist r₁ r₂ + hdist r₂ r₃ := by
  -- The set of slots where r₁ differs from� r�� ⊃� is contained in the union of ( �slots� where r₁ differs from r�₂) and (slots where r₂ differs from r₃).
  have h_subset : diffSet r₁ r₃ ⊆ diffSet r₁ r₂ ∪ diffSet r₂ r₃ := by
    intro i hi; simp_all +decide [ Finset.subset_iff, diffSet ];
    grind;
  exact le_trans ( Finset.card_le_card h_subset ) ( Finset.card_union_le _ _ )

/-! ## Disjoint Substitutions Commute -/

/-
**Disjoint Substitutions Commute**: Updating different slots commutes.
    This is the foundation for geodesic factorization — shortest paths between
    recipes can be rearranged arbitrarily when substitutions act on disjoint slots.
-/
theorem disjoint_update_comm {n m : ℕ} (r : Recipe n m)
    (i j : Fin n) (vi vj : Fin m) (hij : i ≠ j) :
    Function.update (Function.update r i vi) j vj =
    Function.update (Function.update r j vj) i vi := by
  grind

/-! ## Translation Preserves Distance -/

/-- Translate a recipe by componentwise addition in Fin m. -/
def translate {n m : ℕ} (offset : Fin n → Fin m) (r : Recipe n m) : Recipe n m :=
  fun i => r i + offset i

/-
**Translation Invariance**: Translation preserves Hamming distance.
    Since addition in Fin m is a bijection for each slot, the set of
    differing slots is unchanged by translation.
-/
theorem translate_preserves_hdist {n m : ℕ} (offset : Fin n → Fin m)
    (r₁ r₂ : Recipe n m) :
    hdist (translate offset r₁) (translate offset r₂) = hdist r₁ r₂ := by
  unfold hdist translate;
  congr 1 with i ; simp +decide [ Fin.ext_iff, diffSet ]

/-- Translation preserves adjacency. -/
theorem translate_adj_iff {n m : ℕ} (offset : Fin n → Fin m)
    (r₁ r₂ : Recipe n m) :
    (SubstGraph n m).Adj (translate offset r₁) (translate offset r₂) ↔
    (SubstGraph n m).Adj r₁ r₂ := by
  simp [SubstGraph, translate_preserves_hdist]

/-
**Vertex Transitivity**: Any recipe can be mapped to any other
    by a distance-preserving bijection.
-/
theorem vertex_transitive {n m : ℕ} (r₁ r₂ : Recipe n m) :
    ∃ f : Recipe n m ≃ Recipe n m,
      f r₁ = r₂ ∧
      ∀ a b, (SubstGraph n m).Adj (f a) (f b) ↔ (SubstGraph n m).Adj a b := by
  use Equiv.ofBijective (fun r => translate (fun i => r₂ i - r₁ i) r) (by
  -- To prove bijectivity, we show that the translation function is both injective and surjective.
  have h_inj : Function.Injective (fun r => translate (fun i => r₂ i - r₁ i) r) := by
    intro r₁ r₂ h; ext i; replace h := congr_fun h i; simp_all +decide [ translate ] ;
  grind +suggestions)
  generalize_proofs at *;
  simp +decide [ translate_adj_iff ];
  ext i; simp +decide [ translate ] ;
  simp +decide [ Fin.val_add, Fin.val_sub ];
  simp +decide [ ← add_assoc, Nat.mod_eq_of_lt ]

/-! ## Triangle-Freeness for m = 2

For m = 2 the substitution graph is the hypercube graph Q_n.
The hypercube is bipartite (partitioned by Hamming weight parity),
hence triangle-free.

**Proof**: Suppose a, b, c pairwise adjacent. Let a,b differ at slot i
and a,c differ at slot j. If i ≠ j: b agrees with a except at i, c agrees
with a except at j. So b,c differ at both i and j → hdist(b,c) ≥ 2,
contradiction. If i = j: with m=2, b i ≠ a i and c i ≠ a i forces b i = c i,
so b = c, but hdist(b,c) = 1 is impossible.
-/

/-
**Triangle-Free Hypercube**: For m = 2, the substitution graph has no triangles.
-/
theorem triangle_free_m2 {n : ℕ} (a b c : Recipe n 2)
    (hab : (SubstGraph n 2).Adj a b)
    (hbc : (SubstGraph n 2).Adj b c)
    (hac : (SubstGraph n 2).Adj a c) : False := by
  -- By definition of adjacency in the � substitution� graph, we know that $hdist(a, b) = 1$, $hdist(b, c) = 1$, and $hdist(a, c) = 1$.
  have h_hdist_ab : hdist a b = 1 := by
    exact hab
  have h_hdist_bc : hdist b c = 1 := by
    exact hbc
  have h_hdist_ac : hdist a c = 1 := by
    exact hac;
  -- Since $hdist(a �,� b) = 1$, there exists a unique index $i$ such that $a i \neq b i$.
  obtain ⟨i, hi⟩ : ∃! i, a i ≠ b i := by
    exact?;
  obtain ⟨j, hj⟩ : ∃! j, a j ≠ c j := by
    unfold hdist at h_hdist_ac;
    rw [ Finset.card_eq_one ] at h_hdist_ac;
    exact?;
  by_cases hij : i = j <;> simp_all +decide [ SubstGraph ];
  · grind +suggestions;
  · contrapose! h_hdist_bc; simp_all +decide [ hdist ] ;
    refine' ne_of_gt ( Finset.one_lt_card.mpr ⟨ i, _, j, _, _ ⟩ ) <;> simp_all +decide [ diffSet ]; all_goals grind +ring

/-
For m ≥ 3 and n ≥ 1, the substitution graph contains triangles:
    three recipes that pairwise differ at the same single slot with
    three distinct values.
-/
theorem triangle_exists_m3 {n m : ℕ} (hn : 1 ≤ n) (hm : 3 ≤ m) :
    ∃ a b c : Recipe n m,
      (SubstGraph n m).Adj a b ∧
      (SubstGraph n m).Adj b c ∧
      (SubstGraph n m).Adj a c ∧
      a ≠ b ∧ b ≠ c ∧ a ≠ c := by
  use fun _ => ⟨0, by omega⟩, fun i => if i = ⟨0, by omega⟩ then ⟨1, by omega⟩ else ⟨0, by omega⟩, fun i => if i = ⟨0, by omega⟩ then ⟨2, by omega⟩ else ⟨0, by omega⟩;
  simp +decide [ funext_iff, SubstGraph ];
  unfold hdist; simp +decide [ Finset.card_eq_one ] ;
  unfold diffSet; simp +decide [ Finset.eq_singleton_iff_unique_mem ] ;
  exact ⟨ ⟨ ⟨ 0, by linarith ⟩, by aesop ⟩, ⟨ ⟨ 0, by linarith ⟩, by aesop ⟩ ⟩

/-! ## Additive Flavor Maps and Slot Independence -/

/-- An additive flavor map: per-slot contributions summed for total flavor. -/
structure AdditiveFlavorMap (n m d : ℕ) where
  contrib : Fin n → Fin m → Fin d → ℝ

/-- Evaluate an additive flavor map on a recipe. -/
noncomputable def AdditiveFlavorMap.eval {n m d : ℕ} (A : AdditiveFlavorMap n m d)
    (r : Recipe n m) (k : Fin d) : ℝ :=
  ∑ i : Fin n, A.contrib i (r i) k

/-
**Slot Independence Theorem**: For an additive flavor map, changing slot i
    affects the flavor by exactly the difference of that slot's contributions.
    This formalizes the culinary principle that "each ingredient contributes
    independently to taste" when the flavor map is additive.
-/
theorem slot_independence {n m d : ℕ} (A : AdditiveFlavorMap n m d)
    (r : Recipe n m) (i : Fin n) (v : Fin m) (k : Fin d) :
    A.eval (Function.update r i v) k - A.eval r k =
    A.contrib i v k - A.contrib i (r i) k := by
  unfold AdditiveFlavorMap.eval;
  rw [ ← Finset.sum_sub_distrib, Finset.sum_eq_single i ] <;> simp +contextual

/-! ## The Substitution Spectrum -/

/-- The count of recipes at Hamming distance k: C(n,k)*(m-1)^k. -/
def spectrumCount (n m k : ℕ) : ℕ :=
  Nat.choose n k * (m - 1) ^ k

/-
**Vandermonde-Culinary Identity**: The spectrum sums to m^n.
    This is the binomial theorem: m^n = ((m-1) + 1)^n = Σ C(n,k)(m-1)^k.
-/
theorem spectrum_sum (n m : ℕ) (hm : 1 ≤ m) :
    ∑ k ∈ Finset.range (n + 1), spectrumCount n m k = m ^ n := by
  rw [ ← Nat.add_sub_cancel' hm, add_pow ];
  simp +decide [ add_comm 1, spectrumCount ];
  rw [ ← Finset.sum_flip ];
  exact Finset.sum_congr rfl fun x hx => by rw [ Nat.choose_symm ( Finset.mem_range_succ_iff.mp hx ), mul_comm ] ;

/-! ## Four-Cycle Existence -/

/-
The substitution graph contains 4-cycles when n ≥ 2, m ≥ 2.
    The 4-cycle: r → (change slot 0) → (change slot 1) →
    (revert slot 0) → (revert slot 1) = r.
-/
theorem four_cycle_exists {n m : ℕ} (hn : 2 ≤ n) (hm : 2 ≤ m) :
    ∃ a b c d : Recipe n m,
      (SubstGraph n m).Adj a b ∧
      (SubstGraph n m).Adj b c ∧
      (SubstGraph n m).Adj c d ∧
      (SubstGraph n m).Adj d a ∧
      a ≠ c ∧ b ≠ d := by
  unfold SubstGraph;
  rcases n with ( _ | _ | n ) <;> rcases m with ( _ | _ | m ) <;> simp_all +decide [ hdist ];
  refine' ⟨ fun _ => 0, fun i => if i = ⟨ 0, by linarith ⟩ then 1 else 0, _, fun i => if i = ⟨ 0, by linarith ⟩ then 1 else if i = ⟨ 1, by linarith ⟩ then 1 else 0, _, fun i => if i = ⟨ 1, by linarith ⟩ then 1 else 0, _, _ ⟩ <;> simp +decide [ diffSet ];
  · simp +decide [ Finset.card_filter ];
  · rw [ Finset.card_eq_one ] ; use 1 ; ext i ; aesop;
  · simp +decide [ Finset.filter_eq', Finset.filter_and ];
  · exact ⟨ by rw [ Finset.card_filter ] ; aesop, fun h => by have := congr_fun h 0; aesop, fun h => by have := congr_fun h 0; aesop ⟩

/-! ## Recipe Space Cardinality -/

/-
The recipe space has m^n elements.
-/
theorem recipe_card {n m : ℕ} :
    Fintype.card (Recipe n m) = m ^ n := by
  simp +decide [ Fintype.card_pi ]

/-! ## Flavor Fiber Structure -/

/-- A flavor map assigns flavor profiles to recipes. -/
structure FlavorMap (n m d : ℕ) where
  toFun : Recipe n m → (Fin d → ℝ)

/-- The flavor fiber: all recipes producing a given flavor profile. -/
def FlavorFiber {n m d : ℕ} (F : FlavorMap n m d) (p : Fin d → ℝ) : Set (Recipe n m) :=
  {r | F.toFun r = p}

/-- Flavor equivalence is an equivalence relation. -/
theorem flavorEquiv_equiv {n m d : ℕ} (F : FlavorMap n m d) :
    Equivalence (fun r₁ r₂ : Recipe n m => F.toFun r₁ = F.toFun r₂) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- An injective flavor map has singleton fibers. -/
theorem fiber_subsingleton_of_injective {n m d : ℕ} (F : FlavorMap n m d)
    (hF : Function.Injective F.toFun) (p : Fin d → ℝ) :
    Set.Subsingleton (FlavorFiber F p) :=
  fun _ hr₁ _ hr₂ => hF (hr₁.trans hr₂.symm)

end RecipeHomotopy