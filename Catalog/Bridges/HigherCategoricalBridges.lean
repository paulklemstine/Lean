import Mathlib

/-! # CatalogBuild.Bridges.HigherCategoricalBridges

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 16
-/

noncomputable section

open CategoryTheory

/-- Adjunctions compose: a fundamental 2-categorical fact. -/
def adjunction_compose {C D E : Type*}
    [Category C] [Category D] [Category E]
    {F1 : C ⥤ D} {G1 : D ⥤ C}
    {F2 : D ⥤ E} {G2 : E ⥤ D}
    (adj1 : F1 ⊣ G1) (adj2 : F2 ⊣ G2) :
    (F1 ⋙ F2) ⊣ (G2 ⋙ G1) :=
  adj1.comp adj2

/-- The triangle identities for an adjunction. -/
theorem triangle_identity_left {C D : Type*}
    [Category C] [Category D]
    {F : C ⥤ D} {G : D ⥤ C}
    (adj : F ⊣ G) (X : C) :
    F.map (adj.unit.app X) ≫ adj.counit.app (F.obj X) = 𝟙 _ :=
  adj.left_triangle_components X

/-- [Section: # CatalogBuild.Bridges.HigherCategoricalBridges
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 16] -/
theorem triangle_identity_right {C D : Type*}
    [Category C] [Category D]
    {F : C ⥤ D} {G : D ⥤ C}
    (adj : F ⊣ G) (Y : D) :
    adj.unit.app (G.obj Y) ≫ G.map (adj.counit.app Y) = 𝟙 _ :=
  adj.right_triangle_components Y

/-- Every adjunction induces a monad GF on C. -/
def bridge_monad {C D : Type*} [Category C] [Category D]
    {F : C ⥤ D} {G : D ⥤ C} (adj : F ⊣ G) : Monad C :=
  adj.toMonad

/-- Every adjunction induces a comonad FG on D. -/
def bridge_comonad {C D : Type*} [Category C] [Category D]
    {F : C ⥤ D} {G : D ⥤ C} (adj : F ⊣ G) : Comonad D :=
  adj.toComonad

/-- A simplicial type: a functor from Δ^op to Type.
This is the combinatorial model for ∞-categories (quasi-categories). -/
structure SimplicialType where
  simplices : ℕ → Type
  face : ∀ {n : ℕ}, Fin (n + 2) → simplices (n + 1) → simplices n
  degen : ∀ {n : ℕ}, Fin (n + 1) → simplices n → simplices (n + 1)

/-- A simplicial map between simplicial types. -/
structure SimplicialMap (X Y : SimplicialType) where
  map : ∀ n, X.simplices n → Y.simplices n
  commutes_face : ∀ {n} (i : Fin (n + 2)) (s : X.simplices (n + 1)),
    map n (X.face i s) = Y.face i (map (n + 1) s)

/-- Composition of simplicial maps. -/
def SimplicialMap.comp {X Y Z : SimplicialType}
    (f : SimplicialMap X Y) (g : SimplicialMap Y Z) : SimplicialMap X Z where
  map n := g.map n ∘ f.map n
  commutes_face i s := by
    simp [Function.comp, f.commutes_face, g.commutes_face]

/-- Identity simplicial map. -/
def SimplicialMap.id (X : SimplicialType) : SimplicialMap X X where
  map _ := _root_.id
  commutes_face _ _ := rfl

/-- The Langlands correspondence as a bridge between two categories. -/
structure LanglandsBridge where
  automorphic_objects : Type
  galois_objects : Type
  correspondence : automorphic_objects → galois_objects → Prop

/-- The bridge strength: the unit of the adjunction at an object. -/
def bridgeStrength {C D : Type*}
    [Category C] [Category D]
    {F : C ⥤ D} {G : D ⥤ C}
    (adj : F ⊣ G) (X : C) : (X ⟶ G.obj (F.obj X)) :=
  adj.unit.app X

/-- A 2-morphism between bridges is a natural transformation. -/
def bridge_2morphism {C D : Type*}
    [Category C] [Category D]
    {F1 F2 : C ⥤ D}
    (alpha : F1 ⟶ F2) (X : C) :
    (F1.obj X ⟶ F2.obj X) :=
  alpha.app X

/-- Vertical composition of 2-morphisms. -/
def bridge_2morphism_vcomp {C D : Type*}
    [Category C] [Category D]
    {F1 F2 F3 : C ⥤ D}
    (alpha : F1 ⟶ F2) (beta : F2 ⟶ F3) :
    F1 ⟶ F3 :=
  alpha ≫ beta

/-- Horizontal composition of 2-morphisms via whiskering. -/
def bridge_2morphism_hcomp {C D E : Type*}
    [Category C] [Category D] [Category E]
    {F1 F2 : C ⥤ D} {G1 G2 : D ⥤ E}
    (alpha : F1 ⟶ F2) (beta : G1 ⟶ G2) :
    (F1 ⋙ G1) ⟶ (F2 ⋙ G2) :=
  alpha.hcomp beta

/-- A triangulated category structure (simplified). -/
structure TriangulatedData (C : Type*) [Category C] where
  shift : C ⥤ C
  distinguished : Set (C × C × C)

/-- A derived functor between triangulated categories. -/
structure DerivedFunctor {C D : Type*} [Category C] [Category D]
    (TC : TriangulatedData C) (TD : TriangulatedData D) where
  func : C ⥤ D
  preserves_triangles : ∀ t ∈ TC.distinguished,
    (func.obj t.1, func.obj t.2.1, func.obj t.2.2) ∈ TD.distinguished

end