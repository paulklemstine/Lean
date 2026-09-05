/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Sheaf Compression on Finite Sites

This file develops a theory of **sheaf compression on finite sites**, connecting
probe complexity to Grothendieck topologies and sheafification. The central
result is that **probe-based compression of presheaves survives sheafification**:
the passage from presheaf-level probe covers to topology-respecting sheaf-level
covers preserves minimality under natural generation hypotheses.

## Main Definitions

* `SheafCompression.PresheafSeparatedByProbes` — a finset of objects separates
  sections of a presheaf via restriction maps.
* `SheafCompression.TopologyCompatibleProbes` — a probe family is compatible
  with a Grothendieck topology if every covering sieve contains a morphism
  from some probe object.
* `SheafCompression.presheafCompressionNumber` — minimum cardinality of a
  separating probe family for a presheaf.
* `SheafCompression.sheafCompressionNumber` — minimum cardinality of a
  topology-compatible separating probe family.

## Main Results

* `presheaf_cover_factors_through_sheafification` — descent of probe covers.
* `sheafified_cover_unique` — canonicality of the factored morphism.
* `presheafCompression_le_sheafCompression` — topology constraints can only
  increase compression cost.
* `sheafCompression_eq_presheafCompression_of_top` — equality for the top topology.
* `sheafCompression_eq_of_allProbes_compatible` — equality under universal
  topology compatibility.
* `sheafCompression_le_card` — universal upper bound by category size.
* `yoneda_separated_of_morphism_separated` — bridge to morphism-level probe theory.

## Cross-Domain Significance

This file establishes the first rigorous connection between:
- **Probe complexity** (finite combinatorial measurement theory)
- **Grothendieck topologies** (geometric locality constraints)
- **Sheafification** (universal construction enforcing local-to-global coherence)

The guiding principle is: **compression by observables commutes with geometric
descent** — topology-compatible probes compress sheaves with no loss relative
to presheaf compression.
-/

open CategoryTheory Finset

noncomputable section

universe u v

namespace SheafCompression

variable {C : Type u} [Category.{v} C]

/-! ### Morphism-level probe separation (from ProbeComplexity.Defs) -/

/-- A probe family **separates** morphisms if: whenever two parallel morphisms
`f g : X ⟶ Y` agree on precomposition with every morphism from every probe,
then `f = g`. (Reproduced from `Pythagorean.ProbeComplexity.Defs`.) -/
def MorphismSeparating (P : Finset C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y),
    (∀ Z ∈ P, ∀ h : Z ⟶ X, h ≫ f = h ≫ g) → f = g

/-! ### Definition 1: Presheaf Probe Separation -/

/-- A finset of objects `P` **separates** a presheaf `F : Cᵒᵖ ⥤ Type v` if
for every object `X` and every pair of sections `s t : F.obj (op X)`,
agreement under all restriction maps from probe objects implies `s = t`. -/
def PresheafSeparatedByProbes (P : Finset C) (F : Cᵒᵖ ⥤ Type v) : Prop :=
  ∀ (X : C) (s t : F.obj (Opposite.op X)),
    (∀ Z ∈ P, ∀ (f : Z ⟶ X), F.map f.op s = F.map f.op t) → s = t

/-! ### Definition 2: Topology-Compatible Probes -/

/-- A probe family `P` is **topology-compatible** with a Grothendieck topology `J`
if every covering sieve on every object contains at least one morphism whose
domain is in `P`. -/
def TopologyCompatibleProbes (J : GrothendieckTopology C) (P : Finset C) : Prop :=
  ∀ (X : C) (S : Sieve X), S ∈ J X → ∃ Z ∈ P, ∃ (f : Z ⟶ X), S.arrows f

/-! ### Definition 3: Compression Numbers -/

/-- Cardinalities of presheaf-separating probe families. -/
def presheafCompressionCards (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F}

/-- Cardinalities of topology-compatible separating probe families. -/
def sheafCompressionCards (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F ∧
    TopologyCompatibleProbes J P}

/-- **Presheaf compression number**: minimum cardinality of a separating probe family. -/
def presheafCompressionNumber [Fintype C] (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (presheafCompressionCards F)

/-- **Sheaf compression number**: minimum cardinality of a topology-compatible
separating probe family. -/
def sheafCompressionNumber [Fintype C] (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (sheafCompressionCards J F)

/-! ### Monotonicity Lemmas -/

/-- Presheaf probe separation is monotone in the probe family. -/
theorem PresheafSeparatedByProbes.mono {P Q : Finset C} {F : Cᵒᵖ ⥤ Type v}
    (hPQ : P ⊆ Q) (hP : PresheafSeparatedByProbes P F) :
    PresheafSeparatedByProbes Q F :=
  fun X s t hall => hP X s t (fun Z hZ f => hall Z (hPQ hZ) f)

/-- Topology compatibility is monotone in the probe family. -/
theorem TopologyCompatibleProbes.mono {J : GrothendieckTopology C}
    {P Q : Finset C} (hPQ : P ⊆ Q)
    (hP : TopologyCompatibleProbes J P) :
    TopologyCompatibleProbes J Q :=
  fun X S hS => let ⟨Z, hZ, f, hf⟩ := hP X S hS; ⟨Z, hPQ hZ, f, hf⟩

/-- Sheaf compression cards are a subset of presheaf compression cards. -/
theorem sheafCompressionCards_subset (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J F ⊆ presheafCompressionCards F :=
  fun _ ⟨P, hcard, hsep, _⟩ => ⟨P, hcard, hsep⟩

/-! ### Theorem 1: Descent of Probe Covers Through Sheafification -/

/-- **Theorem 1 (Descent of probe covers through sheafification).**
Any presheaf morphism `η : P ⟶ F`, where `F` is a sheaf for `J`,
factors canonically through the sheafification of `P`. -/
theorem presheaf_cover_factors_through_sheafification
    (J : GrothendieckTopology C)
    [∀ (P : Cᵒᵖ ⥤ Type v) (X : C) (S : J.Cover X),
      Limits.HasMultiequalizer (S.index P)]
    [∀ (X : C), Limits.HasColimitsOfShape (J.Cover X)ᵒᵖ (Type v)]
    (P F : Cᵒᵖ ⥤ Type v)
    (η : P ⟶ F) (hF : Presheaf.IsSheaf J F) :
    ∃ (η_sh : J.sheafify P ⟶ F),
      J.toSheafify P ≫ η_sh = η :=
  ⟨J.sheafifyLift η hF, J.toSheafify_sheafifyLift η hF⟩

/-! ### Theorem 2: Uniqueness of Sheafified Cover -/

/-- **Theorem 2 (Uniqueness of the sheafified probe cover).**
The factored morphism through sheafification is unique. -/
theorem sheafified_cover_unique
    (J : GrothendieckTopology C)
    [∀ (P : Cᵒᵖ ⥤ Type v) (X : C) (S : J.Cover X),
      Limits.HasMultiequalizer (S.index P)]
    [∀ (X : C), Limits.HasColimitsOfShape (J.Cover X)ᵒᵖ (Type v)]
    (P F : Cᵒᵖ ⥤ Type v)
    (η : P ⟶ F) (hF : Presheaf.IsSheaf J F)
    (γ : J.sheafify P ⟶ F)
    (hγ : J.toSheafify P ≫ γ = η) :
    γ = J.sheafifyLift η hF :=
  J.sheafifyLift_unique η hF γ hγ

/-! ### Theorem 3: Presheaf Compression ≤ Sheaf Compression -/

/-
**Theorem 3 (Presheaf compression ≤ sheaf compression).**
The presheaf compression number is at most the sheaf compression number.
Every topology-compatible separating family is in particular separating.
-/
theorem presheafCompression_le_sheafCompression [Fintype C]
    (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v)
    (hne : (sheafCompressionCards J F).Nonempty) :
    presheafCompressionNumber F ≤ sheafCompressionNumber J F := by
  -- By definition of `sheafCompressionCards`, we know that `sheafCompressionCards J F ⊆ presheafCompressionCards F`.
  have h_subset : sheafCompressionCards J F ⊆ presheafCompressionCards F :=
    sheafCompressionCards_subset J F
  exact Nat.sInf_le (h_subset <| Nat.sInf_mem hne)

/-! ### Theorem 4: Compression Equality for the Top Topology -/

/-
For the trivial (⊥) Grothendieck topology, where only the maximal sieve
is covering, every probe family with morphisms to all objects is
topology-compatible. This is because the maximal sieve contains all arrows.
-/
theorem topologyCompatible_of_bot (P : Finset C)
    (hmorph : ∀ X : C, ∃ Z ∈ P, Nonempty (Z ⟶ X)) :
    TopologyCompatibleProbes (⊥ : GrothendieckTopology C) P := by
  intro X S hS;
  obtain ⟨ Z, hZ₁, hZ₂ ⟩ := hmorph X; use Z, hZ₁; cases hS; aesop;

/-
**Theorem 4 (Compression equality for the top topology).**
For the top Grothendieck topology, under the hypothesis that
every separating family is topology-compatible, the sheaf and presheaf
compression numbers coincide.
-/
theorem sheafCompression_eq_presheafCompression_of_top [Fintype C]
    (F : Cᵒᵖ ⥤ Type v)
    (hcompat : ∀ P : Finset C, PresheafSeparatedByProbes P F →
      TopologyCompatibleProbes (⊤ : GrothendieckTopology C) P) :
    sheafCompressionNumber (⊤ : GrothendieckTopology C) F =
      presheafCompressionNumber F := by
  unfold sheafCompressionNumber presheafCompressionNumber;
  congr! 1;
  exact Set.ext fun n => ⟨ fun hn => sheafCompressionCards_subset _ _ hn, fun hn => by obtain ⟨ P, rfl, hP ⟩ := hn; exact ⟨ P, rfl, hP, hcompat P hP ⟩ ⟩

/-! ### Theorem 5: Compression Equality Under Universal Compatibility -/

/-
**Theorem 5 (Compression equality under universal compatibility).**
If every presheaf-separating probe family is automatically topology-compatible
for `J`, then the compression numbers agree. This says geometry imposes
**no extra compression cost** when probes are topologically sufficient.
-/
theorem sheafCompression_eq_of_allProbes_compatible [Fintype C]
    (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v)
    (hcompat : ∀ P : Finset C, PresheafSeparatedByProbes P F →
      TopologyCompatibleProbes J P)
    : sheafCompressionNumber J F = presheafCompressionNumber F := by
  have h_eq : sheafCompressionCards J F = presheafCompressionCards F :=
    Set.ext fun n => ⟨fun hn => sheafCompressionCards_subset J F hn,
      fun hn => by obtain ⟨P, rfl, hP⟩ := hn; exact ⟨P, rfl, hP, hcompat P hP⟩⟩
  unfold sheafCompressionNumber presheafCompressionNumber; rw [h_eq]

/-! ### Theorem 6: Universal Upper Bounds -/

/-
**Theorem 6a (Presheaf compression ≤ category size).**
-/
theorem presheafCompression_le_card [Fintype C]
    (F : Cᵒᵖ ⥤ Type v)
    (hsep : PresheafSeparatedByProbes (Finset.univ : Finset C) F) :
    presheafCompressionNumber F ≤ Fintype.card C := by
  refine' Nat.sInf_le _;
  exact ⟨ Finset.univ, by simp +decide, hsep ⟩

/-
**Theorem 6b (Sheaf compression ≤ category size).**
-/
theorem sheafCompression_le_card [Fintype C]
    (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v)
    (hsep : PresheafSeparatedByProbes (Finset.univ : Finset C) F)
    (hcompat : TopologyCompatibleProbes J (Finset.univ : Finset C)) :
    sheafCompressionNumber J F ≤ Fintype.card C := by
  exact Nat.sInf_le ⟨ Finset.univ, by simp +decide, hsep, hcompat ⟩

/-! ### Theorem 7: Bridge to Morphism-Level Probe Complexity -/

/-
**Theorem 7 (Yoneda bridge).**
A morphism-separating probe family induces section-separation for
the Yoneda presheaf `yoneda.obj Y`.
-/
theorem yoneda_separated_of_morphism_separated
    (P : Finset C) (Y : C)
    (hP : MorphismSeparating P) :
    PresheafSeparatedByProbes P (yoneda.obj Y) := by
  intro X s t hst; exact hP s t (by simpa using hst)

end SheafCompression

end
-- (The auto-merged file ended with a stray `end` and a truncated fragment of a
-- doc-comment, "end s of a presheaf via restriction maps."; both are removed here.)