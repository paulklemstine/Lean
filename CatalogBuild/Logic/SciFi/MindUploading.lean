/-! # CatalogBuild.Logic.SciFi.MindUploading

Auto-generated from theorem catalog database.
Domain: Logic/SciFi
Declarations: 3
-/

import Mathlib

/-- A presheaf on a topological space X -/
structure Presheaf' (X : Type u) [TopologicalSpace X] where
  obj : TopologicalSpace.Opens X → Type u
  map {U V : TopologicalSpace.Opens X} (h : U ≤ V) : obj V → obj U


/-- A sheaf: presheaf with gluing -/
structure Sheaf' (X : Type u) [TopologicalSpace X] extends Presheaf'.{u} X where
  gluing : ∀ {ι : Type u} [DecidableEq ι] (U : ι → TopologicalSpace.Opens X)
    (s : ∀ i, obj (U i)),
    (∀ i j, map inf_le_left (s i) = map inf_le_right (s j)) →
    ∃! s_global : obj (⨆ i, U i), ∀ i, map (le_iSup U i) s_global = s i


/-- Mind Upload Gluing: compatible local sections glue uniquely. -/
theorem mind_upload_gluing {X : Type u} [TopologicalSpace X]
    (F : Sheaf'.{u} X) {ι : Type u} [DecidableEq ι]
    (U : ι → TopologicalSpace.Opens X) (s : ∀ i, F.obj (U i))
    (hcompat : ∀ i j, F.map inf_le_left (s i) = F.map inf_le_right (s j)) :
    ∃! s_global : F.obj (⨆ i, U i), ∀ i, F.map (le_iSup U i) s_global = s i :=
  F.gluing U s hcompat

