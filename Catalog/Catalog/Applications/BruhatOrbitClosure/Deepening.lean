import Mathlib

/-!
# Closure relations from graph embeddings of ordered parameters

This file isolates and strengthens the order-theoretic mechanism behind two-projection
parametrisations of orbit strata.  Given a relation `r` and a self-map `ι` preserving and
reflecting it, the graph map `x ↦ (x, ι x)` embeds `r` into the componentwise product
relation.  Moreover, it identifies every principal closure with the corresponding principal
closure inside its graph image, and it transports arbitrary lower sets exactly.

For Bruhat order, the intended self-map is inversion.  Thus the results apply once inversion
invariance of Bruhat order has been established, independently of a particular geometric
realisation of the orbit set.
-/

namespace BruhatOrbitDeepening

universe u v

variable {α : Type u} {β : Type v}

/-- Componentwise extension of a relation to a product. -/
def ProductRel (r : α → α → Prop) (s : β → β → Prop) (x y : α × β) : Prop :=
  r x.1 y.1 ∧ s x.2 y.2

/-- The graph parametrisation associated to a self-map. -/
def graphParam (ι : α → α) (x : α) : α × α := (x, ι x)

/-- The principal closure (principal lower set) determined by a relation. -/
def principalClosure (r : α → α → Prop) (x : α) : Set α :=
  {y | r y x}

/-- A map preserving and reflecting a relation gives an exact graph realisation in the
componentwise product relation. -/
theorem graph_productRel_iff (r : α → α → Prop) (ι : α → α)
    (hι : ∀ {x y}, r (ι x) (ι y) ↔ r x y) (x y : α) :
    ProductRel r r (graphParam ι x) (graphParam ι y) ↔ r x y := by
  unfold ProductRel graphParam
  grind

/-- The graph parametrisation is injective, without any assumption on its second coordinate. -/
theorem graphParam_injective (ι : α → α) : Function.Injective (graphParam ι) := by
  exact fun x y h => by injection h

/-- In a preorder, inclusion of principal closures is equivalent to the original relation. -/
theorem principalClosure_subset_iff (r : α → α → Prop)
    (hrefl : Reflexive r) (htrans : Transitive r) (x y : α) :
    principalClosure r x ⊆ principalClosure r y ↔ r x y := by
  exact ⟨ fun h => h ( hrefl _ ), fun h z hz => htrans hz h ⟩

/-- The preimage under the graph parametrisation of a product-principal closure is exactly
its original principal closure.  This is the set-level closure correspondence. -/
theorem preimage_product_principalClosure (r : α → α → Prop) (ι : α → α)
    (hι : ∀ {x y}, r (ι x) (ι y) ↔ r x y) (x : α) :
    graphParam ι ⁻¹' principalClosure (ProductRel r r) (graphParam ι x) =
      principalClosure r x := by
  ext y
  exact graph_productRel_iff r ι hι y x

/-- Intersecting a product-principal closure with the graph image produces precisely the
image of the original principal closure. -/
theorem product_closure_inter_graph (r : α → α → Prop) (ι : α → α)
    (hι : ∀ {x y}, r (ι x) (ι y) ↔ r x y) (x : α) :
    principalClosure (ProductRel r r) (graphParam ι x) ∩ Set.range (graphParam ι) =
      graphParam ι '' principalClosure r x := by
  ext ⟨y, z⟩
  unfold principalClosure ProductRel graphParam
  aesop

/-- A subset is lower for the original relation exactly when its graph image is lower inside
that graph for the componentwise product relation.  This extends the pointwise closure
statement to arbitrary unions of orbit closures. -/
theorem lowerSet_graph_iff (r : α → α → Prop) (ι : α → α)
    (hι : ∀ {x y}, r (ι x) (ι y) ↔ r x y) (S : Set α) :
    (∀ ⦃x y⦄, r x y → y ∈ S → x ∈ S) ↔
      (∀ ⦃p q⦄, p ∈ Set.range (graphParam ι) → q ∈ Set.range (graphParam ι) →
        ProductRel r r p q → q ∈ graphParam ι '' S → p ∈ graphParam ι '' S) := by
  simp_all +decide [graphParam]
  unfold ProductRel
  aesop

/-- For a preorder, closure inclusion among graph-parametrised strata is equivalent to
componentwise product order. -/
theorem graph_closure_inclusion_iff (r : α → α → Prop) (ι : α → α)
    (hrefl : Reflexive r) (htrans : Transitive r) (x y : α) :
    (principalClosure (ProductRel r r) (graphParam ι x) ∩ Set.range (graphParam ι) ⊆
      principalClosure (ProductRel r r) (graphParam ι y) ∩ Set.range (graphParam ι)) ↔
      ProductRel r r (graphParam ι x) (graphParam ι y) := by
  constructor <;> intro h
  · simp_all +decide [Set.subset_def, graphParam]
    exact h x (ι x) ⟨hrefl _, hrefl _⟩ rfl
  · intro z hz
    cases hz.2
    simp_all +decide [ProductRel]
    exact ⟨htrans hz.1.1 h.1, htrans hz.1.2 h.2⟩

end BruhatOrbitDeepening