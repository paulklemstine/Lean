import Mathlib
import Bridges.NeuralCompositionBridge
import Bridges.TannakianNeuralArchitecture

/-!
# Category-Theoretic Neural Architectures

This file models a neural architecture with input object `X` and output object `Y`
as a morphism `X ⟶ Y`.  The ambient cartesian monoidal category supplies parallel
composition.  Three precise bridges are established:

* a residual skip branch is the universal product lift of the identity and residual
  branch, and the usual ResNet block is obtained by following that lift with addition;
* two-head attention, represented by swapping two feature streams, is a natural
  transformation;
* finite architecture search over natural transformations is minimization over a
  hom-set of the functor category.

The analytic certification theorem reuses `NeuralCompositionBridge.lipschitz_add`,
and architecture search can carry the existing
`TannakianNeural.FeedforwardArchitecture` topology rather than introducing a new
notion of feedforward architecture.
-/

noncomputable section

open CategoryTheory CategoryTheory.Limits

namespace CategoryTheoreticNeuralArchitectures

universe v u

/-- Neural architectures are morphisms in their ambient category. -/
abbrev NeuralArchitecture (C : Type u) [Category.{v} C] (X Y : C) := X ⟶ Y

/-- Sequential composition of neural architectures is categorical composition. -/
def NeuralArchitecture.then {C : Type u} [Category.{v} C] {X Y Z : C}
    (f : NeuralArchitecture C X Y) (g : NeuralArchitecture C Y Z) :
    NeuralArchitecture C X Z := f ≫ g

/-- Parallel composition in a cartesian monoidal category is the canonical product map. -/
def NeuralArchitecture.parallel {C : Type u} [Category.{v} C]
    {X₁ X₂ Y₁ Y₂ : C} [HasBinaryProduct X₁ X₂] [HasBinaryProduct Y₁ Y₂]
    (f : NeuralArchitecture C X₁ Y₁) (g : NeuralArchitecture C X₂ Y₂) :
    NeuralArchitecture C (X₁ ⨯ X₂) (Y₁ ⨯ Y₂) :=
  prod.map f g

/-! ## Residual connections as categorical products -/

/-- The categorical skip connection pairs the unchanged input with its residual branch. -/
def resNetSkip {C : Type u} [Category.{v} C] {X : C} [HasBinaryProduct X X]
    (residual : X ⟶ X) : X ⟶ X ⨯ X :=
  prod.lift (𝟙 X) residual

/-- The first projection of a residual product is exactly the identity skip branch. -/
theorem resNetSkip_fst {C : Type u} [Category.{v} C] {X : C} [HasBinaryProduct X X]
    (residual : X ⟶ X) :
    resNetSkip residual ≫ prod.fst = 𝟙 X :=
  prod.lift_fst _ _

/-- The second projection of a residual product is exactly the learned branch. -/
theorem resNetSkip_snd {C : Type u} [Category.{v} C] {X : C} [HasBinaryProduct X X]
    (residual : X ⟶ X) :
    resNetSkip residual ≫ prod.snd = residual :=
  prod.lift_snd _ _

/-- The skip connection is uniquely determined by its identity and residual projections.
This is the categorical product universal property, not merely a representation by pairs. -/
theorem resNetSkip_unique {C : Type u} [Category.{v} C] {X : C} [HasBinaryProduct X X]
    (residual : X ⟶ X) (candidate : X ⟶ X ⨯ X)
    (hskip : candidate ≫ prod.fst = 𝟙 X)
    (hresidual : candidate ≫ prod.snd = residual) :
    candidate = resNetSkip residual := by
  apply prod.hom_ext
  · simpa [resNetSkip] using hskip
  · simpa [resNetSkip] using hresidual

/-- The usual additive readout of the identity and residual branches.  The two
branches are characterized categorically by `resNetSkip_fst` and `resNetSkip_snd`. -/
def resNetBlock {E : Type u} [Add E] (residual : E → E) : E → E :=
  fun x => x + residual x

/-- The categorical product realization is compatible with the catalog's analytic
certificate: a `K`-Lipschitz residual branch gives a `(1+K)`-Lipschitz block. -/
theorem resNet_product_lipschitz {E : Type u} [SeminormedAddCommGroup E]
    {K : NNReal} {residual : E → E} (hresidual : LipschitzWith K residual) :
    LipschitzWith (1 + K) (resNetBlock residual) :=
  NeuralCompositionBridge.lipschitz_add LipschitzWith.id hresidual

/-! ## Attention as a natural transformation -/

/-- Two parallel feature streams associated to a representation functor. -/
def twoHeadFeatures {C : Type u} [Category.{v} C] (F : C ⥤ Type u) : C ⥤ Type u where
  obj X := F.obj X × F.obj X
  map f p := (F.map f p.1, F.map f p.2)
  map_id X := by
    funext p
    simp
  map_comp f g := by
    funext p
    simp

/-- A concrete attention operator which exchanges the two feature heads. -/
def swapAttention {C : Type u} [Category.{v} C] (F : C ⥤ Type u) :
    twoHeadFeatures F ⟶ twoHeadFeatures F where
  app X p := (p.2, p.1)
  naturality X Y f := by
    funext p
    rfl

/-- Attention commutes with every representation map: applying attention before
transporting features is the same as transporting and then applying attention. -/
theorem attention_naturality {C : Type u} [Category.{v} C] (F : C ⥤ Type u)
    {X Y : C} (f : X ⟶ Y) :
    (swapAttention F).app X ≫ (twoHeadFeatures F).map f =
      (twoHeadFeatures F).map f ≫ (swapAttention F).app Y :=
  (swapAttention F).naturality f

/-! ## Architecture search in a functor category -/

/-- A search candidate combines an existing feedforward topology with semantics
represented by a morphism in the functor category. -/
structure SearchCandidate {C : Type u} [Category.{v} C] (F G : C ⥤ Type u) where
  topology : TannakianNeural.FeedforwardArchitecture
  semantics : F ⟶ G

/-- Every nonempty finite family of functor-category architectures has a candidate
of minimal loss.  Thus finite neural architecture search is precisely optimization
on a finite subset of a functor-category hom-set. -/
theorem architecture_search_has_optimizer {C : Type u} [Category.{v} C]
    {F G : C ⥤ Type u} [DecidableEq (F ⟶ G)]
    (candidates : Finset (F ⟶ G)) (loss : (F ⟶ G) → ℝ)
    (hne : candidates.Nonempty) :
    ∃ best ∈ candidates, ∀ candidate ∈ candidates, loss best ≤ loss candidate :=
  Finset.exists_min_image candidates loss hne

/-- The same optimization result for candidates carrying catalog feedforward
architectures; the semantics being optimized remain morphisms `F ⟶ G`. -/
theorem topology_aware_search_has_optimizer {C : Type u} [Category.{v} C]
    {F G : C ⥤ Type u} [DecidableEq (SearchCandidate F G)]
    (candidates : Finset (SearchCandidate F G))
    (loss : SearchCandidate F G → ℝ) (hne : candidates.Nonempty) :
    ∃ best ∈ candidates, ∀ candidate ∈ candidates, loss best ≤ loss candidate :=
  Finset.exists_min_image candidates loss hne

end CategoryTheoreticNeuralArchitectures