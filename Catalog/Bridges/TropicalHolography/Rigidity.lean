/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalHolography.Defs

/-!
# Tropical Holographic Rigidity and Reconstruction

This file proves the central **boundary rigidity theorem**: two weighted closure systems
in normal form with identical boundary data are gauge-equivalent (isomorphic via a
generator bijection preserving signatures and weights).

It also provides a **reconstruction** algorithm that, given admissible boundary data,
constructs a canonical bulk system realizing that data, and proves uniqueness up to gauge.

## Main Results

* `equiv_of_injective_image_eq` — general lemma: injective functions with equal
  Finset images yield domain equivalences.
* `boundary_rigidity_normal_form` — the central rigidity theorem.
* `boundaryKernel_eq_of_gaugeEquiv` — gauge-equivalent systems have equal kernels.
* `entropy_eq_of_gaugeEquiv` — gauge-equivalent systems have equal entropy profiles.
* `reconstructBulk_boundaryData` — reconstruction realizes the given boundary data.
* `reconstructBulk_isNormalForm` — reconstructed systems are in normal form.
* `reconstruction_unique_mod_gauge` — any normal-form realization is gauge-equivalent
  to the canonical reconstruction.
-/

noncomputable section

open Finset ENNReal

namespace TropicalHolography

variable {X : Type*} [DecidableEq X] [Fintype X]

/-! ## Gauge Equivalence -/

/-- A **gauge equivalence** between two weighted closure systems w.r.t. boundary `B`:
    a bijection on generators preserving boundary signatures and weights. -/
structure BulkGaugeEquiv
    {G₁ G₂ : Type*} [DecidableEq G₁] [Fintype G₁] [DecidableEq G₂] [Fintype G₂]
    (B : Finset X)
    (S₁ : WeightedClosureSystem X G₁)
    (S₂ : WeightedClosureSystem X G₂) where
  /-- The underlying bijection on generators. -/
  equiv : G₁ ≃ G₂
  /-- The bijection preserves boundary signatures. -/
  sig_preserved : ∀ g, boundarySig B S₁ g = boundarySig B S₂ (equiv g)
  /-- The bijection preserves weights. -/
  weight_preserved : ∀ g, S₁.weight g = S₂.weight (equiv g)

/-! ## Key Technical Lemma -/

/-
If two injective functions from finite types into the same codomain
    have equal Finset images, then there exists an equivalence between
    the domains that intertwines them.
-/
theorem equiv_of_injective_image_eq
    {α β γ : Type*} [DecidableEq γ] [Fintype α] [Fintype β]
    (f : α → γ) (g : β → γ)
    (hf : Function.Injective f) (hg : Function.Injective g)
    (him : Finset.univ.image f = Finset.univ.image g) :
    ∃ e : α ≃ β, ∀ a, f a = g (e a) := by
  have h_equiv : ∀ a : α, ∃ b : β, f a = g b := by
    intro a
    have h_exists_b : f a ∈ Finset.image g Finset.univ := by
      grind;
    grind;
  choose e he using h_equiv;
  have h_equiv : Function.Injective e := by
    exact fun a b hab => hf <| by simp +decide [ he, hab ] ;
  have h_equiv : Function.Surjective e := by
    have h_card : Fintype.card α = Fintype.card β := by
      have := Finset.card_image_of_injective ( Finset.univ : Finset α ) hf; have := Finset.card_image_of_injective ( Finset.univ : Finset β ) hg; aesop;
    exact ( Fintype.bijective_iff_injective_and_card e ).mpr ⟨ h_equiv, h_card ⟩ |>.2;
  exact ⟨ Equiv.ofBijective e ⟨ by assumption, by assumption ⟩, he ⟩

/-! ## Boundary Rigidity -/

/-
**Boundary Rigidity (Normal Form)**: Two weighted closure systems in normal form
    with identical boundary data are gauge-equivalent.

    This is the discrete tropical analogue of holographic reconstruction:
    the boundary response data uniquely determines the bulk generator structure
    up to relabeling.
-/
omit [Fintype X] in
theorem boundary_rigidity_normal_form
    {G₁ G₂ : Type*} [DecidableEq G₁] [Fintype G₁] [DecidableEq G₂] [Fintype G₂]
    (B : Finset X)
    (S₁ : WeightedClosureSystem X G₁)
    (S₂ : WeightedClosureSystem X G₂)
    (hnf₁ : S₁.IsNormalForm B)
    (hnf₂ : S₂.IsNormalForm B)
    (hdata : boundaryDataSet B S₁ = boundaryDataSet B S₂) :
    Nonempty (BulkGaugeEquiv B S₁ S₂) := by
  obtain ⟨ e, he ⟩ := equiv_of_injective_image_eq ( fun g => ( boundarySig B S₁ g, S₁.weight g ) ) ( fun g => ( boundarySig B S₂ g, S₂.weight g ) ) hnf₁ hnf₂ hdata;
  exact ⟨ ⟨ e, fun g => by simpa using congr_arg Prod.fst ( he g ), fun g => by simpa using congr_arg Prod.snd ( he g ) ⟩ ⟩

/-! ## Gauge Equivalence Preserves Observables -/

variable {G₁ G₂ : Type*} [DecidableEq G₁] [Fintype G₁] [DecidableEq G₂] [Fintype G₂]

/-
Gauge-equivalent systems have equal boundary kernels.
-/
omit [Fintype X] in
theorem boundaryKernel_eq_of_gaugeEquiv
    {B : Finset X}
    {S₁ : WeightedClosureSystem X G₁}
    {S₂ : WeightedClosureSystem X G₂}
    (e : BulkGaugeEquiv B S₁ S₂) (b : X) :
    boundaryKernel B S₁ b = boundaryKernel B S₂ b := by
  refine' le_antisymm _ _;
  · refine' iInf_mono' fun g => _;
    use e.equiv.symm g;
    simp +decide [ e.sig_preserved, e.weight_preserved ];
  · refine' iInf_mono' _;
    intro g₁; use e.equiv g₁; simp +decide [ e.sig_preserved, e.weight_preserved ] ;

/-
Gauge-equivalent systems have equal entropy profiles.
-/
omit [Fintype X] in
theorem entropy_eq_of_gaugeEquiv
    {B : Finset X}
    {S₁ : WeightedClosureSystem X G₁}
    {S₂ : WeightedClosureSystem X G₂}
    (e : BulkGaugeEquiv B S₁ S₂) (k : ℕ) :
    boundaryEntropyProfile B S₁ k = boundaryEntropyProfile B S₂ k := by
  convert ( Equiv.iInf_congr e.equiv _ ) using 1;
  intro g; rw [ e.sig_preserved g, e.weight_preserved g ] ;

/-! ## Reconstruction -/

/-- **Admissible** boundary data: all signature sets are subsets of `B`. -/
def Admissible (B : Finset X) (d : Finset (Finset X × ℝ≥0∞)) : Prop :=
  ∀ p ∈ d, p.1 ⊆ B

/-- Reconstruct a bulk system from boundary data. The generators are indexed
    by the elements of `d` itself (as a subtype). -/
def reconstructBulk (d : Finset (Finset X × ℝ≥0∞)) :
    WeightedClosureSystem X {p // p ∈ d} where
  out := fun ⟨p, _⟩ => p.1
  weight := fun ⟨p, _⟩ => p.2

/-
The boundary signature of a reconstructed generator, under admissibility.
-/
omit [Fintype X] in
theorem reconstructBulk_boundarySig (B : Finset X) (d : Finset (Finset X × ℝ≥0∞))
    (hadm : Admissible B d) (p : {p // p ∈ d}) :
    boundarySig B (reconstructBulk d) p = p.1.1 := by
  exact Finset.filter_eq_self.mpr fun x hx => hadm _ p.2 hx

/-
The reconstructed system is always in normal form.
-/
omit [Fintype X] in
theorem reconstructBulk_isNormalForm (B : Finset X) (d : Finset (Finset X × ℝ≥0∞))
    (hadm : Admissible B d) :
    (reconstructBulk d).IsNormalForm B := by
  intro p q h;
  simp_all +decide [ reconstructBulk_boundarySig ];
  exact Subtype.ext ( Prod.ext h.1 h.2 )

/-
The reconstructed system realizes the given boundary data.
-/
omit [Fintype X] in
theorem reconstructBulk_boundaryData (B : Finset X) (d : Finset (Finset X × ℝ≥0∞))
    (hadm : Admissible B d) :
    boundaryDataSet B (reconstructBulk d) = d := by
  ext ⟨x, y⟩; simp [boundaryDataSet, reconstructBulk];
  constructor;
  · rintro ⟨ a, ha, rfl ⟩;
    convert ha using 1;
    exact congr_arg₂ _ ( Finset.ext fun x => by unfold boundarySig; aesop ) rfl;
  · exact fun h => ⟨ x, h, by simpa [ boundarySig ] using hadm _ h ⟩

/-
**Reconstruction Uniqueness**: Any system in normal form that realizes
    boundary data `d` is gauge-equivalent to the canonical reconstruction.
-/
omit [Fintype X] in
theorem reconstruction_unique_mod_gauge
    {G : Type*} [DecidableEq G] [Fintype G]
    (B : Finset X) (d : Finset (Finset X × ℝ≥0∞))
    (hadm : Admissible B d)
    (S : WeightedClosureSystem X G)
    (hnf : S.IsNormalForm B)
    (hreal : boundaryDataSet B S = d) :
    Nonempty (BulkGaugeEquiv B S (reconstructBulk d)) := by
  apply boundary_rigidity_normal_form B S (reconstructBulk d) hnf (reconstructBulk_isNormalForm B d hadm) (by
  rw [ hreal, reconstructBulk_boundaryData B d hadm ])

end TropicalHolography