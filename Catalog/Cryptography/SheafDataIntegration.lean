/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.CellularSheafCohomology

/-!
# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

This file formalizes the precise sense in which distributed databases assemble into a
**sheaf**, and connects *data integration* to the cellular-sheaf cohomology framework
developed in `Cryptography.CellularSheafCohomology`.

There are two complementary pictures of "databases as a sheaf":

1. **The presheaf of records over a key space.** Fix a space of keys `K` and a value
   type `Val`. A *database over `U ⊆ K`* is a record assignment `U → Val`. Restricting
   to a smaller key set is the presheaf structure. The headline theorem
   `DatabaseSheaf.exists_unique_glue` says this presheaf is a **sheaf**: any family of
   local databases over a cover that is *pairwise consistent on shared keys* glues to a
   unique global database. This is exactly the mathematical content of "consistent data
   integration always succeeds and is unique".

2. **The cellular sheaf of a schema graph.** A schema graph `G` has data sources at
   vertices and agreement constraints along edges (`CellularSheaf.GraphSheaf`). A
   *consistent integration* is a global section. We package these as a submodule
   `CellularSheaf.globalSections` and show it recovers `H0` for the constant sheaf,
   giving a cohomological reading of integration: the integrations are the kernel of the
   consistency (coboundary) constraints.

## Main results

* `DatabaseSheaf.restrict_restrict` / `restrict_self` — presheaf functoriality.
* `DatabaseSheaf.exists_unique_glue` — **gluing axiom**: pairwise-consistent local
  databases over a cover have a unique integration (databases form a sheaf).
* `DatabaseSheaf.glue_eq_of_locally_eq` — **separation axiom**: a global database is
  determined by its restrictions to a cover.
* `CellularSheaf.globalSections` — the submodule of consistent integrations of a graph
  sheaf.
* `CellularSheaf.globalSections_constantSheaf` — integrations of the constant sheaf are
  exactly `H0`.
* `CellularSheaf.globalSections_eval_injective_of_connected` — over a connected schema a
  consistent integration is determined by its value at any single source.

-- !-- Lab Notes -- !--
Hypothesis: "databases form a sheaf" is not a metaphor but a theorem — the presheaf of
partial records is a genuine sheaf (gluing + separation). We test this directly via
`exists_unique_glue`. We then test the cohomological hypothesis that *consistent
integration over a connected schema collapses to a single shared record* (rigidity),
proved via the existing `H0_eq_const_of_connected`.
-/

open SimpleGraph

namespace DatabaseSheaf

/-! ### The presheaf of records over a key space -/

/-- A *record set* over a set of keys `U`: a value assignment to each key in `U`.
    Databases over `U` are exactly the inhabitants of `Record K Val U`. -/
abbrev Record (K Val : Type*) (U : Set K) : Type _ := ↑U → Val

variable {K Val : Type*}

/-- Restriction of a database along an inclusion of key sets `W ⊆ U`. -/
def restrict {U W : Set K} (h : W ⊆ U) (s : Record K Val U) : Record K Val W :=
  fun x => s ⟨x.1, h x.2⟩

/-
!-- Lab Notes -- !--
Functoriality (presheaf laws): restriction along the identity is the identity, and
restriction is contravariantly compatible with composition of inclusions.
-/
theorem restrict_self {U : Set K} (s : Record K Val U) :
    restrict (le_refl U) s = s := by
      funext x; rfl;

theorem restrict_restrict {U W X : Set K} (h₁ : W ⊆ U) (h₂ : X ⊆ W)
    (s : Record K Val U) :
    restrict h₂ (restrict h₁ s) = restrict (h₂.trans h₁) s := by
      funext x; exact rfl

/-! ### The sheaf condition: gluing and separation -/

-- !-- Lab Notes -- !--
-- A family of local databases `r i : Record (S i)` is *consistent* when any two agree on
-- their shared keys. This is the database-overlap-consistency condition.
/-- A family of local databases over sets `S i` is *consistent on overlaps*. -/
def Consistent {I : Type*} (S : I → Set K) (r : ∀ i, Record K Val (S i)) : Prop :=
  ∀ i j (x : K) (hi : x ∈ S i) (hj : x ∈ S j), r i ⟨x, hi⟩ = r j ⟨x, hj⟩

/-
**Separation axiom.** A global database over the union of a cover is determined by its
    restrictions to the pieces of the cover.
-/
theorem glue_eq_of_locally_eq {I : Type*} (S : I → Set K)
    (g g' : Record K Val (⋃ i, S i))
    (h : ∀ i, restrict (Set.subset_iUnion S i) g = restrict (Set.subset_iUnion S i) g') :
    g = g' := by
      ext ⟨x, hx⟩; have := Set.mem_iUnion.mp hx; obtain ⟨i, hi⟩ := this; specialize h i; replace h := congr_fun h ⟨x, hi⟩; aesop;

/-
**Gluing axiom — databases form a sheaf.** Any family of local databases over a cover
    that is pairwise consistent on shared keys glues to a *unique* global database whose
    restriction to each piece is the given local database.
-/
theorem exists_unique_glue {I : Type*} (S : I → Set K) (r : ∀ i, Record K Val (S i))
    (hr : Consistent S r) :
    ∃! g : Record K Val (⋃ i, S i),
      ∀ i, restrict (Set.subset_iUnion S i) g = r i := by
        -- Define the global database \(g\) by choosing any index \(i\) such that \(x \in S_i\) for each \(x\) in the union.
        have hdehyde : ∃ g : Record K Val (⋃ i, S i), ∀ i, restrict (Set.subset_iUnion S i) g = r i := by
          refine' ⟨ fun x => r ( Classical.choose ( Set.mem_iUnion.mp x.2 ) ) ⟨ x.1, Classical.choose_spec ( Set.mem_iUnion.mp x.2 ) ⟩, fun i => funext fun x => _ ⟩
          generalize_proofs at *;
          exact hr _ _ _ ( Classical.choose_spec ( Set.mem_iUnion.mp ( Set.mem_iUnion_of_mem i x.2 ) ) ) x.2;
        exact ⟨ hdehyde.choose, hdehyde.choose_spec, fun g hg => DatabaseSheaf.glue_eq_of_locally_eq S g _ fun i => hg i ▸ hdehyde.choose_spec i ▸ rfl ⟩

/-
!-- Lab Notes -- !--
The two results below sharpen the sheaf condition into an *exact* characterization:
a family of local databases is integrable (glues) **iff** it is overlap-consistent.
Forward direction is pure separation (restrictions of a single record always agree);
backward is the gluing axiom. This is the database-administrator's decision procedure:
"can these tables be merged?" reduces to "do they agree on shared keys?".

Restrictions of a single global database are always overlap-consistent.
-/
theorem consistent_of_restrict {U : Set K} (g : Record K Val U) {I : Type*}
    (S : I → Set K) (hSU : ∀ i, S i ⊆ U) :
    Consistent S (fun i => restrict (hSU i) g) := by
      intro i j x hi hj; have := hSU i hi; have := hSU j hj; simp +decide [ restrict, * ] ;

/-
**Integrability ⇔ consistency.** A family of local databases over a cover extends to a
    (necessarily unique) global database exactly when it is pairwise overlap-consistent.
-/
theorem exists_glue_iff_consistent {I : Type*} (S : I → Set K)
    (r : ∀ i, Record K Val (S i)) :
    (∃ g : Record K Val (⋃ i, S i), ∀ i, restrict (Set.subset_iUnion S i) g = r i)
      ↔ Consistent S r := by
        constructor;
        · rintro ⟨ g, hg ⟩;
          exact fun i j x hi hj => hg i ▸ hg j ▸ rfl;
        · exact fun hr => ExistsUnique.exists ( exists_unique_glue S r hr )

/-
**Two-table merge.** Two databases on key sets `S₀`, `S₁` that agree on the shared
    keys `S₀ ∩ S₁` merge to a unique database on `S₀ ∪ S₁`. This is the join/union of two
    consistent tables, the most common data-integration primitive.
-/
theorem exists_unique_merge_two (S₀ S₁ : Set K)
    (r₀ : Record K Val S₀) (r₁ : Record K Val S₁)
    (hagree : ∀ (x : K) (h0 : x ∈ S₀) (h1 : x ∈ S₁), r₀ ⟨x, h0⟩ = r₁ ⟨x, h1⟩) :
    ∃! g : Record K Val (S₀ ∪ S₁),
      restrict Set.subset_union_left g = r₀ ∧ restrict Set.subset_union_right g = r₁ := by
  obtain ⟨g, hg⟩ : ∃ g : Record K Val (S₀ ∪ S₁), restrict (Set.subset_union_left : S₀ ⊆ S₀ ∪ S₁) g = r₀ ∧ restrict (Set.subset_union_right : S₁ ⊆ S₀ ∪ S₁) g = r₁ := by
    refine' ⟨ _, _, _ ⟩;
    intro ⟨ x, hx ⟩;
    by_cases h : x ∈ S₀;
    exact r₀ ⟨ x, h ⟩;
    exact r₁ ⟨ x, hx.resolve_left h ⟩; all_goals unfold restrict; aesop;
  refine' ⟨ g, hg, _ ⟩;
  rintro y ⟨ hy₀, hy₁ ⟩;
  exact funext fun x => by cases' x with x hx; cases' hx with hx₀ hx₁ <;> simp_all +decide [ funext_iff, restrict ] ;

end DatabaseSheaf

/-! ### Integration as global sections of a schema sheaf -/

namespace CellularSheaf

variable {V : Type*} [DecidableEq V] {R : Type*} [CommRing R] {G : SimpleGraph V}

/-
The submodule of **consistent integrations** of a schema sheaf `F`: dependent records
    at each data source that agree under every edge comparison map.
-/
def globalSections (F : GraphSheaf R G) : Submodule R (∀ v, F.Stalk v) where
  carrier := {s | F.IsGlobalSection s}
  zero_mem' := fun v w h => by simp
  add_mem' := fun {a b} ha hb v w h => by
    have h1 := ha v w h; have h2 := hb v w h
    simp only [GraphSheaf.IsGlobalSection, Pi.add_apply, map_add] at *
    rw [h1, h2]
  smul_mem' := fun c a ha v w h => by
    have h1 := ha v w h
    simp only [GraphSheaf.IsGlobalSection, Pi.smul_apply, map_smul] at *
    rw [h1]

omit [DecidableEq V] in
theorem mem_globalSections_iff (F : GraphSheaf R G) (s : ∀ v, F.Stalk v) :
    s ∈ globalSections F ↔ F.IsGlobalSection s := Iff.rfl

/-
For the constant sheaf, the consistent integrations are exactly `H0`.
-/
omit [DecidableEq V] in
theorem globalSections_constantSheaf (G : SimpleGraph V) :
    globalSections (mkConstantSheaf R G) = H0 G R := by
      ext f;
      convert mkConstantSheaf_section_iff_H0 G f

/-
**Rigidity of integration over a connected schema.** A consistent integration of the
    constant sheaf over a connected schema graph is determined by its value at any single
    data source: distributed consistency forces a single shared record.
-/
theorem globalSections_eval_injective_of_connected (hconn : G.Connected) (v₀ : V) :
    Function.Injective
      (fun s : globalSections (mkConstantSheaf R G) => s.val v₀) := by
        intro s t hst
        apply Subtype.ext
        funext v
        have hs : s.val ∈ H0 G R := (mkConstantSheaf_section_iff_H0 G s.val).1 s.2
        have ht : t.val ∈ H0 G R := (mkConstantSheaf_section_iff_H0 G t.val).1 t.2
        have hreach := hconn.preconnected v₀ v
        have e1 := (mem_H0_iff_reachable s.val).1 hs v₀ v hreach
        have e2 := (mem_H0_iff_reachable t.val).1 ht v₀ v hreach
        rw [← e1, ← e2]
        exact hst

end CellularSheaf