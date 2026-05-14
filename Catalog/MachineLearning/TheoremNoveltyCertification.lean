import Mathlib

/-!
# Certified Novelty Detection via Theorem Embedding Uniqueness

This module formalizes a **metric-geometric certification architecture** for detecting
novelty of mathematical theorems relative to a finite catalog of known results.

## Main Results

1. `novelty_of_far_from_catalog`: Sound novelty certification via metric separation.
2. `novelty_of_nearestDist_gt`: Nearest-neighbor novelty certification.
3. `exists_nearest_in_finset`: Finite catalogs always have a nearest element.
4. `not_equivalent_of_coordinate_gap`: Feature-gap obstruction theorem.
5. `novelty_converse`: Completeness direction.
6. Concrete `TheoremDescriptor` model with coordinate-gap theorems.
-/

open scoped BigOperators

/-! ## Section 1: Abstract Novelty Framework -/

section NoveltyFramework

variable {σ α : Type*}
variable [PseudoMetricSpace α]
-- `Equivalent x y` means descriptors represent the same theorem up to certification granularity.
variable (Equivalent : σ → σ → Prop)
-- Embedding of theorem descriptors into a metric feature space.
variable (E : σ → α)

/-- A theorem descriptor `x` is **novel** with respect to catalog `K` if it is not
equivalent to any element of `K`. -/
def Novel (K : Finset σ) (x : σ) : Prop :=
  ∀ a ∈ K, ¬ Equivalent x a

/-
**Sound novelty certification.** If equivalent descriptors map within distance `δ`
under the embedding `E`, and every catalog point is at distance greater than `δ` from
the candidate `x`, then `x` is novel (not equivalent to any catalog theorem).

*Proof strategy*: Assume for contradiction that `x` is equivalent to some `a ∈ K`.
Then `dist(E x, E a) ≤ δ` by the embedding soundness axiom, contradicting `δ < dist(E x, E a)`.
-/
theorem novelty_of_far_from_catalog
    (K : Finset σ) (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ) :
    ∀ x, (∀ a ∈ K, δ < dist (E x) (E a)) → Novel Equivalent K x := by
  exact fun x hx a ha => fun h => not_lt_of_ge ( hEq x a h ) ( hx a ha )

/-- The **nearest-neighbor distance** (novelty score) of a candidate `x` to a nonempty
finite catalog `K`. -/
noncomputable def nearestDist (K : Finset σ) (x : σ) (hK : K.Nonempty) : ℝ :=
  K.inf' hK (fun a => dist (E x) (E a))

/-
Every nonempty finite set has a nearest element.
-/
theorem exists_nearest_in_finset
    (K : Finset σ) (hK : K.Nonempty) (x : σ) :
    ∃ a ∈ K, ∀ b ∈ K, dist (E x) (E a) ≤ dist (E x) (E b) := by
  exact Finset.exists_min_image K (fun x_1 => dist (E x) (E x_1)) hK

/-
The nearest distance equals the distance to some catalog element.
-/
theorem nearestDist_eq_nearest
    (K : Finset σ) (hK : K.Nonempty) (x : σ) :
    ∃ a ∈ K, nearestDist E K x hK = dist (E x) (E a) := by
  exact Finset.exists_mem_eq_inf' hK fun a => dist (E x) (E a)

/-
The nearest distance is a lower bound on all catalog distances.
-/
theorem nearestDist_le_dist
    (K : Finset σ) (hK : K.Nonempty) (x : σ) (a : σ) (ha : a ∈ K) :
    nearestDist E K x hK ≤ dist (E x) (E a) := by
  exact Finset.inf'_le _ ha

/-
**Nearest-neighbor novelty certification.** If the novelty score exceeds `δ`, then
the candidate is novel.
-/
theorem novelty_of_nearestDist_gt
    (K : Finset σ) (hK : K.Nonempty) (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ)
    (x : σ)
    (hfar : δ < nearestDist E K x hK) :
    Novel Equivalent K x := by
  -- By definition of nearest distance, for any $a \in K$, we have $dist (E x) (E a) \geq nearestDist E K x hK$.
  have h_dist_ge_nearest : ∀ a ∈ K, dist (E x) (E a) ≥ nearestDist E K x hK := by
    exact fun a a_1 => nearestDist_le_dist E K hK x a a_1
  exact fun a ha h => not_lt_of_ge ( hEq x a h ) ( lt_of_lt_of_le hfar ( h_dist_ge_nearest a ha ) )

/-
**Novelty converse (completeness).** If `x` is not novel, then it is within
distance `δ` of some catalog element.
-/
theorem novelty_converse
    (K : Finset σ) (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ)
    (x : σ)
    (hnotnovel : ¬ Novel Equivalent K x) :
    ∃ a ∈ K, dist (E x) (E a) ≤ δ := by
  grind +locals

/-
**Catalog class separation implies equivalence transitivity.**
If distinct classes are metrically separated by more than `2δ`, and equivalent
descriptors are within `δ`, then if `x` is equivalent to both `a` and `b` in `K`,
then `a` and `b` must be equivalent.
-/
theorem catalog_separation_disjoint
    (K : Finset σ) (δ : ℝ)
    (hEq_dist : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ)
    (hsep : ∀ a ∈ K, ∀ b ∈ K, ¬ Equivalent a b → 2 * δ < dist (E a) (E b))
    (x : σ) (a b : σ) (ha : a ∈ K) (hb : b ∈ K)
    (hxa : Equivalent x a) (hxb : Equivalent x b) :
    Equivalent a b := by
  exact not_not.mp fun h => by linarith [ hsep a ha b hb h, hEq_dist _ _ hxa, hEq_dist _ _ hxb, dist_triangle_left ( E a ) ( E b ) ( E x ), dist_triangle_right ( E a ) ( E b ) ( E x ) ] ;

end NoveltyFramework

/-! ## Section 2: Feature-Gap Obstruction Theorems -/

section FeatureGap

variable {σ : Type*}

/-
**Feature-gap obstruction.** If equivalent descriptors have a feature `f` differing
by at most `δ`, then any pair differing by more than `δ` is non-equivalent.
-/
theorem not_equivalent_of_coordinate_gap
    (Equivalent : σ → σ → Prop)
    (f : σ → ℝ)
    (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → |f x - f y| ≤ δ)
    {x y : σ}
    (hgap : δ < |f x - f y|) :
    ¬ Equivalent x y := by
  grind

/-
Variant with natural-number-valued features.
-/
theorem not_equivalent_of_nat_gap
    (Equivalent : σ → σ → Prop)
    (f : σ → ℕ)
    (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → |(f x : ℝ) - (f y : ℝ)| ≤ δ)
    {x y : σ}
    (hgap : δ < |(f x : ℝ) - (f y : ℝ)|) :
    ¬ Equivalent x y := by
  exact not_equivalent_of_coordinate_gap Equivalent (fun x => ↑(f x)) δ hEq hgap

end FeatureGap

/-! ## Section 3: Concrete Theorem Descriptor Model -/

section ConcreteDescriptor

/-- A concrete theorem descriptor capturing syntactic/structural features. -/
structure TheoremDescriptor where
  arity : ℕ
  symbolCount : ℕ
  quantifierDepth : ℕ
  dependencyCount : ℕ
  hasInduction : Bool
  hasContradiction : Bool
deriving DecidableEq, Repr

/-- Embedding a theorem descriptor into ℝ⁶ (as a nested product). -/
noncomputable def descVec (d : TheoremDescriptor) : ℝ × ℝ × ℝ × ℝ × ℝ × ℝ :=
  (d.arity, d.symbolCount, d.quantifierDepth, d.dependencyCount,
   if d.hasInduction then 1 else 0,
   if d.hasContradiction then 1 else 0)

/-
Non-equivalence from symbol count gap.
-/
theorem nonequiv_of_symbolCount_gap
    (Equivalent : TheoremDescriptor → TheoremDescriptor → Prop)
    (δs : ℝ)
    (hEq : ∀ x y, Equivalent x y → |(x.symbolCount : ℝ) - y.symbolCount| ≤ δs)
    {x y : TheoremDescriptor}
    (hgap : δs < |(x.symbolCount : ℝ) - y.symbolCount|) :
    ¬ Equivalent x y := by
  exact not_equivalent_of_coordinate_gap Equivalent (fun x => ↑x.symbolCount) δs hEq hgap

/-
Non-equivalence from arity gap.
-/
theorem nonequiv_of_arity_gap
    (Equivalent : TheoremDescriptor → TheoremDescriptor → Prop)
    (δa : ℝ)
    (hEq : ∀ x y, Equivalent x y → |(x.arity : ℝ) - y.arity| ≤ δa)
    {x y : TheoremDescriptor}
    (hgap : δa < |(x.arity : ℝ) - y.arity|) :
    ¬ Equivalent x y := by
  grind +extAll

/-
Non-equivalence from quantifier depth gap.
-/
theorem nonequiv_of_quantifierDepth_gap
    (Equivalent : TheoremDescriptor → TheoremDescriptor → Prop)
    (δq : ℝ)
    (hEq : ∀ x y, Equivalent x y → |(x.quantifierDepth : ℝ) - y.quantifierDepth| ≤ δq)
    {x y : TheoremDescriptor}
    (hgap : δq < |(x.quantifierDepth : ℝ) - y.quantifierDepth|) :
    ¬ Equivalent x y := by
  grind +splitIndPred

end ConcreteDescriptor

/-! ## Section 4: Reconstruction-Uniqueness Bridge -/

section ReconstructionBridge

variable {σ τ α : Type*} [PseudoMetricSpace α]

/-- Two descriptors are equivalent if they reconstruct to the same identity. -/
def ReconstructionEquiv (reconstruct : σ → τ) (x y : σ) : Prop :=
  reconstruct x = reconstruct y

/-
Novelty under reconstruction equivalence: a descriptor is novel if its
reconstruction differs from all catalog reconstructions.
-/
theorem reconstruction_novelty
    (reconstruct : σ → τ)
    (E : σ → α) (K : Finset σ) (δ : ℝ)
    (hEq : ∀ x y, reconstruct x = reconstruct y → dist (E x) (E y) ≤ δ)
    (x : σ) (hfar : ∀ a ∈ K, δ < dist (E x) (E a)) :
    ∀ a ∈ K, reconstruct x ≠ reconstruct a := by
  exact fun a ha h => not_lt_of_ge ( hEq x a h ) ( hfar a ha )

end ReconstructionBridge

/-! ## Section 5: Injectivity from Separation -/

section Separation

/-
**Injectivity from strict separation.** If all distinct catalog elements are
mapped to points at positive distance, the embedding is injective on the catalog.
-/
theorem embedding_injective_of_separated
    {σ α : Type*} [PseudoMetricSpace α]
    (E : σ → α) (K : Finset σ)
    (hsep : ∀ a ∈ K, ∀ b ∈ K, a ≠ b → 0 < dist (E a) (E b))
    {a b : σ} (ha : a ∈ K) (hb : b ∈ K) (heq : E a = E b) :
    a = b := by
  exact Classical.not_not.1 fun hab => ne_of_gt ( hsep a ha b hb hab ) ( by simp +decide [ heq ] )

end Separation