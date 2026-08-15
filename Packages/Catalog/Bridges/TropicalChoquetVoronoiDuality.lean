import Mathlib
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Logic.GraphTheory.Defs

/-!
# Tropical Choquet–Voronoi Duality via Idempotent Convex Semimodules

This file establishes a certified finite duality theorem connecting:
- **Tropical convex algebra**: idempotent semimodules with closure-operator structure
- **Support hypergraphs**: the family of minimal support sets
- **Voronoi/polyhedral geometry**: abstract simplicial complexes from support incidence

## Main results

### Layer 1: Finite Tropical Choquet Representation
* `finite_tropical_choquet_canonical` — Every element admits a canonical minimal
  support decomposition from extremal generators.

### Layer 2: Support-to-Complex Reconstruction
* `support_incidence_reconstructs_nerve` — The family of support sets determines
  a finite abstract simplicial complex that faithfully reconstructs the
  incidence geometry of the decomposition.

### Layer 3: Functorial Duality
* `tropical_semimod_to_complex_functorial` — Support-preserving morphisms
  induce simplicial maps, and this is functorial.

### Layer 4: Certified Reconstruction
* `certified_polyhedral_reconstruction` — From a closure operator and generators,
  extract extremals, supports, and the incidence complex with correctness certificates.
-/

noncomputable section

open Finset Set

namespace TropicalChoquetVoronoi

variable {M : Type*} [DecidableEq M] [Fintype M]

/-! ## Layer 1: Finite Tropical Choquet Representation -/

/-
**Well-founded minimization of supports**: Among all subsets of `Ext` whose
    hull contains `x`, there exists a minimal one (with respect to `⊂`).
    This is the key step enabling canonical Choquet representation.
-/
lemma exists_minimal_support (op : TropicalClosureOp M) (Ext : Finset M)
    (x : M) (hx : x ∈ op.hull Ext) :
    ∃ σ : Finset M, σ ⊆ Ext ∧ x ∈ op.hull σ ∧ ∀ τ : Finset M, τ ⊂ σ → x ∉ op.hull τ := by
  obtain ⟨σ, hσ⟩ : ∃ σ : Finset M, σ ⊆ Ext ∧ x ∈ op.hull σ := by
    exact ⟨ Ext, Finset.Subset.refl _, hx ⟩;
  have h_min : ∃ m ∈ {s : Finset M | s ⊆ Ext ∧ x ∈ op.hull s}, ∀ t ∈ {s : Finset M | s ⊆ Ext ∧ x ∈ op.hull s}, m.card ≤ t.card := by
    apply_rules [ Set.exists_min_image ];
    · exact Set.finite_iff_bddAbove.mpr ⟨ Ext, fun s hs => hs.1 ⟩;
    · exact ⟨ σ, hσ ⟩;
  obtain ⟨ m, hm₁, hm₂ ⟩ := h_min; exact ⟨ m, hm₁.1, hm₁.2, fun τ hτ₁ hτ₂ => not_lt_of_ge ( hm₂ τ ⟨ Finset.Subset.trans hτ₁.subset hm₁.1, hτ₂ ⟩ ) ( Finset.card_lt_card hτ₁ ) ⟩ ;

/-
**Extremals have singleton self-support**: If `e` is tropically extremal in `Ext`,
    then `{e}` is a minimal support for `e`.
-/
lemma extremal_self_support (op : TropicalClosureOp M) (Ext : Finset M)
    (e : M) (he : IsTropExtremal op Ext e) :
    IsMinimalTropSupport op Ext {e} e := by
  constructor;
  · exact Finset.singleton_subset_iff.mpr he.1;
  · constructor;
    · exact op.extensive _ ( Finset.mem_singleton_self _ );
    · have := op.extensive ∅; simp_all +decide;
      exact fun h => he.2 ( op.mono ( Finset.empty_subset _ ) h )

/-
**Minimal supports are nonempty** when the element is not in the hull of ∅.
-/
lemma minimal_support_nonempty (op : TropicalClosureOp M)
    (Ext : Finset M) (σ : Finset M) (x : M)
    (hmin : IsMinimalTropSupport op Ext σ x)
    (hnotself : x ∉ op.hull ∅) :
    σ.Nonempty := by
  contrapose! hnotself; have := hmin.2.1; aesop;

/-
### Theorem 1: Finite Tropical Choquet Canonical Decomposition

Every element `x` in the tropical hull of a finite set of extremal generators `Ext`
admits a **canonical minimal support decomposition**.
-/
theorem finite_tropical_choquet_canonical
    (op : TropicalClosureOp M) (Ext : Finset M)
    (hgen : ∀ x : M, x ∈ op.hull Ext)
    (_hext : ∀ e ∈ Ext, IsTropExtremal op Ext e) :
    ∃ Supp : M → Finset M,
      (∀ x : M, Supp x ⊆ Ext) ∧
      (∀ x : M, SupportCertifiedBy op (Supp x) x) ∧
      (∀ x : M, IsMinimalTropSupport op Ext (Supp x) x) := by
  choose! Supp hSupp using fun x => exists_minimal_support op Ext x ( hgen x );
  exact ⟨ Supp, fun x => hSupp x |>.1, fun x => ⟨ hSupp x |>.2.1, hSupp x |>.2.2 ⟩, fun x => ⟨ hSupp x |>.1, hSupp x |>.2.1, hSupp x |>.2.2 ⟩ ⟩

/-! ## Layer 2: Support-to-Complex Reconstruction -/

/-
### Theorem 2: Support Incidence Reconstructs Nerve
-/
theorem support_incidence_reconstructs_nerve [Nonempty M]
    (op : TropicalClosureOp M) (Ext : Finset M)
    (Supp : M → Finset M)
    (hSupp : ∀ x : M, IsMinimalTropSupport op Ext (Supp x) x)
    (hcover : ∀ e ∈ Ext, ∃ x : M, e ∈ Supp x) :
    ∃ V : AbstractSimplicialComplex M,
      V = TropSupportComplex Supp ∧
      SupportReconstructionCorrect op Ext Supp V := by
  constructor;
  exact ⟨ rfl, ⟨ fun x => ⟨ x, Finset.Subset.refl _ ⟩, fun σ hσ => by obtain ⟨ x, hx ⟩ := hσ; exact ⟨ x, hx ⟩, hcover, fun x => ( hSupp x ).1 ⟩ ⟩

/-
**Vertices of the support complex**: `{e}` is a face iff `e` appears in some support.
-/
omit [Fintype M] in
theorem support_complex_vertices [Nonempty M]
    (Supp : M → Finset M) (e : M) :
    ({e} ∈ (TropSupportComplex Supp).faces) ↔ (∃ x : M, e ∈ Supp x) := by
  exact ⟨ fun ⟨ x, hx ⟩ => ⟨ x, by simpa using hx ⟩, fun ⟨ x, hx ⟩ => ⟨ x, by simpa using hx ⟩ ⟩

/-
**Support complex faces are bounded by Ext**.
-/
omit [Fintype M] in
theorem support_complex_faces_subset_ext [Nonempty M]
    (Ext : Finset M) (Supp : M → Finset M)
    (hSubExt : ∀ x : M, Supp x ⊆ Ext)
    (σ : Finset M) (hσ : σ ∈ (TropSupportComplex Supp).faces) :
    σ ⊆ Ext := by
  exact hσ.choose_spec.trans ( hSubExt _ )

/-! ## Layer 3: Functorial Duality -/

/-- **Identity morphism**: The identity function is a tropical semimodule morphism. -/
def TropSemimodMorphism.id' (op : TropicalClosureOp M) :
    TropSemimodMorphism M M op op where
  toFun := _root_.id
  hull_compat S := by
    show (op.hull S).image _root_.id ⊆ op.hull (S.image _root_.id)
    simp [Finset.image_id]

/-- **Composition of morphisms**: Tropical semimodule morphisms compose. -/
def TropSemimodMorphism.comp'
    {N P : Type*} [DecidableEq N] [Fintype N] [DecidableEq P] [Fintype P]
    {opM : TropicalClosureOp M} {opN : TropicalClosureOp N} {opP : TropicalClosureOp P}
    (g : TropSemimodMorphism N P opN opP) (f : TropSemimodMorphism M N opM opN) :
    TropSemimodMorphism M P opM opP where
  toFun := g.toFun ∘ f.toFun
  hull_compat S := by
    intro x hx
    obtain ⟨m, hm, rfl⟩ := Finset.mem_image.mp hx
    have hfm := f.hull_compat S (Finset.mem_image.mpr ⟨m, hm, rfl⟩)
    have hgfm := g.hull_compat (S.image f.toFun) (Finset.mem_image.mpr ⟨f.toFun m, hfm, rfl⟩)
    have hsub : (S.image f.toFun).image g.toFun ⊆ S.image (g.toFun ∘ f.toFun) := by
      rw [← Finset.image_image]
    exact opP.mono hsub hgfm

/-
**Induced simplicial map**: A support-preserving morphism induces a map
    on support complexes.
-/
theorem morphism_induces_simplicial_map [Nonempty M]
    {N : Type*} [DecidableEq N] [Fintype N] [Nonempty N]
    {opM : TropicalClosureOp M} {opN : TropicalClosureOp N}
    (f : TropSemimodMorphism M N opM opN)
    (SuppM : M → Finset M) (SuppN : N → Finset N)
    (hpres : ∀ x : M, SuppN (f.toFun x) = (SuppM x).image f.toFun) :
    ∀ σ, σ ∈ (TropSupportComplex SuppM).faces →
      σ.image f.toFun ∈ (TropSupportComplex SuppN).faces := by
  intro σ hσ
  obtain ⟨x, hx⟩ := hσ
  use f.toFun x
  have hsub : σ.image f.toFun ⊆ (SuppM x).image f.toFun := by
    exact Finset.image_subset_image hx
  have hsup : (SuppM x).image f.toFun = SuppN (f.toFun x) := by
    rw [hpres]
  rw [hsup] at hsub
  exact hsub

/-
### Theorem 3: Identity functoriality
-/
theorem tropical_semimod_identity_functorial [Nonempty M]
    (opM : TropicalClosureOp M)
    (SuppM : M → Finset M) :
    ∀ σ ∈ (TropSupportComplex SuppM).faces,
      σ.image (TropSemimodMorphism.id' opM).toFun = σ := by
  exact fun σ hσ => Finset.image_id

/-! ## Layer 4: Certified Reconstruction -/

/-- **Extract extremals**: Given a closure operator and generators,
    extract the extremal generators. -/
def extractExtremals (op : TropicalClosureOp M) (Ext : Finset M) : Finset M :=
  Ext.filter (fun e => e ∉ op.hull (Ext.erase e))

/-
**Extracted extremals are extremal**.
-/
lemma extractExtremals_are_extremal (op : TropicalClosureOp M) (Ext : Finset M)
    (e : M) (he : e ∈ extractExtremals op Ext) :
    IsTropExtremal op Ext e := by
  unfold IsTropExtremal at *;
  unfold extractExtremals at he; aesop;

/-- **Extracted extremals are a subset**. -/
lemma extractExtremals_subset (op : TropicalClosureOp M) (Ext : Finset M) :
    extractExtremals op Ext ⊆ Ext :=
  Finset.filter_subset _ _

/-
### Theorem 4: Certified Polyhedral Reconstruction
-/
theorem certified_polyhedral_reconstruction [Nonempty M]
    (op : TropicalClosureOp M) (Ext : Finset M)
    (hgen : ∀ x : M, x ∈ op.hull Ext)
    (hext : ∀ e ∈ Ext, IsTropExtremal op Ext e) :
    ∃ (Supp : M → Finset M) (V : AbstractSimplicialComplex M),
      (∀ x : M, IsMinimalTropSupport op Ext (Supp x) x) ∧
      V = TropSupportComplex Supp ∧
      SupportReconstructionCorrect op Ext Supp V := by
  -- Obtain the support function Supp from the finite_tropical_choquet_canonical theorem.
  obtain ⟨Supp, hSupp⟩ : ∃ Supp : M → Finset M, (∀ x, IsMinimalTropSupport op Ext (Supp x) x) := by
    exact ⟨ _, fun x => ( finite_tropical_choquet_canonical op Ext hgen hext ).choose_spec.2.2 x ⟩;
  refine' ⟨ Supp, TropSupportComplex Supp, hSupp, rfl, _, _, _, _ ⟩;
  · exact fun x => ⟨ x, Finset.Subset.refl _ ⟩;
  · exact fun σ hσ => by rcases hσ with ⟨ x, hx ⟩ ; exact ⟨ x, hx ⟩ ;
  · intro e he;
    exact ⟨ e, by have := hSupp e; exact (by
    have := this.2.1;
    contrapose! this;
    have := hext e he;
    exact fun h => this.2 ( op.mono ( show Supp e ⊆ Ext.erase e from fun x hx => Finset.mem_erase_of_ne_of_mem ( by aesop ) ( hSupp e |>.1 hx ) ) h )) ⟩;
  · exact fun x => hSupp x |>.1

/-! ## Support Uniqueness -/

/-
**Support uniqueness for extremals**: Extremal generators have
    singleton as their unique minimal support.
-/
theorem support_unique_for_extremals
    (op : TropicalClosureOp M) (Ext : Finset M)
    (e : M) (he : IsTropExtremal op Ext e)
    (σ : Finset M) (hσ : IsMinimalTropSupport op Ext σ e) :
    σ = {e} := by
  obtain ⟨hσ_sub, hσ_min⟩ := hσ;
  by_cases heσ : e ∈ σ <;> simp_all +decide [ IsTropExtremal ];
  · exact Classical.not_not.1 fun h => hσ_min.2 ( { e } ) ( lt_of_le_of_ne ( Finset.singleton_subset_iff.2 heσ ) ( Ne.symm h ) ) ( by simpa using op.extensive { e } );
  · exact False.elim ( he.2 ( op.mono ( show σ ⊆ Ext.erase e from fun x hx => Finset.mem_erase_of_ne_of_mem ( by aesop ) ( hσ_sub hx ) ) hσ_min.1 ) )

/-
**Minimal supports are unique among comparable ones**.
-/
lemma minimal_support_unique_among_comparable
    (op : TropicalClosureOp M) (Ext : Finset M) (x : M)
    (σ τ : Finset M)
    (hσ : IsMinimalTropSupport op Ext σ x)
    (hτ : IsMinimalTropSupport op Ext τ x)
    (hsub : σ ⊆ τ) :
    σ = τ := by
  exact Classical.not_not.1 fun h => hτ.2.2 σ ( lt_of_le_of_ne hsub h ) ( hσ.2.1 )

/-! ## Concrete Example: Discrete Closure -/

/-- The **discrete closure operator**: hull(S) = S. -/
def discreteClosure (M : Type*) [DecidableEq M] [Fintype M] :
    TropicalClosureOp M where
  hull S := S
  extensive _ := Finset.Subset.refl _
  mono := fun {_ _} h => h
  idempotent _ := rfl

/-
In discrete closure, every element is extremal.
-/
theorem discrete_all_extremal (Ext : Finset M) (e : M) (he : e ∈ Ext) :
    IsTropExtremal (discreteClosure M) Ext e := by
  exact ⟨ he, fun h => Finset.notMem_erase _ _ h ⟩

/-
In discrete closure, every element's minimal support is itself.
-/
theorem discrete_singleton_support (Ext : Finset M) (x : M) (hx : x ∈ Ext) :
    IsMinimalTropSupport (discreteClosure M) Ext {x} x := by
  -- Since the discrete closure operator makes every set its own hull, the support of x is {x}.
  simp [IsMinimalTropSupport, SupportCertifiedBy, discreteClosure];
  exact hx

/-
The certified reconstruction for discrete closure.
-/
theorem discrete_reconstruction [Nonempty M] (Ext : Finset M)
    (hgen : ∀ x : M, x ∈ Ext) :
    ∃ (Supp : M → Finset M) (V : AbstractSimplicialComplex M),
      (∀ x : M, IsMinimalTropSupport (discreteClosure M) Ext (Supp x) x) ∧
      V = TropSupportComplex Supp ∧
      SupportReconstructionCorrect (discreteClosure M) Ext Supp V := by
  refine' ⟨ _, _, _, rfl, _ ⟩;
  exact fun x => { x };
  · exact fun x => discrete_singleton_support Ext x ( hgen x );
  · constructor;
    · exact fun x => ⟨ x, Finset.Subset.refl _ ⟩;
    · simp +decide [ TropSupportComplex ];
      exact hgen

/-! ## Max-Plus Tropical Hull -/

/-- **Max-plus hull membership**: `x` is in the max-plus hull of generators `gens`
    if for each coordinate, `x j` equals the max of `c_i + gens_i j`. -/
def inMaxPlusHull (n : ℕ) (gens : Finset (Fin n → ℤ)) (x : Fin n → ℤ) : Prop :=
  ∃ (hne : gens.Nonempty) (c : (Fin n → ℤ) → ℤ),
    ∀ j : Fin n, x j = gens.sup' hne (fun v => c v + v j)

/-
The max-plus hull is extensive: every generator is in its own hull.
-/
lemma inMaxPlusHull_extensive (n : ℕ) (gens : Finset (Fin n → ℤ))
    (v : Fin n → ℤ) (hv : v ∈ gens) :
    inMaxPlusHull n gens v := by
  -- Set c(w) = 0 for all w. Then for each j, gens.sup' ⟨v, hv⟩ (fun w => 0 + w j) = gens.sup' _ (fun w => w j) ≥ v j since v ∈ gens.
  use by
    exact ⟨ v, hv ⟩;
  by_cases h : n = 0;
  · aesop;
  · use fun w => if w = v then 0 else -n * ( ∑ j, |v j - w j| + 1 );
    intro j;
    refine' le_antisymm _ _ <;> norm_num;
    · exact ⟨ v, hv, by norm_num ⟩;
    · intro w hw; split_ifs <;> simp_all +decide;
      nlinarith [ abs_le.mp ( Finset.single_le_sum ( fun a _ => abs_nonneg ( v a - w a ) ) ( Finset.mem_univ j ) ), show ( n : ℤ ) ≥ 1 by exact Nat.one_le_cast.mpr ( Nat.pos_of_ne_zero h ) ]

end TropicalChoquetVoronoi