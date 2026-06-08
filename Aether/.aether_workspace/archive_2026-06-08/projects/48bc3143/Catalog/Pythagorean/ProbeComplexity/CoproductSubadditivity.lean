/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Subadditivity of Sheaf Compression under Coproducts

This file establishes that the sheaf compression number `κ_sh` is **subadditive**
under coproducts of presheaves on finite sites. This is the geometric analogue
of entropy subadditivity in information theory.

## Main Definitions

* `PresheafCoprod F G` — the pointwise coproduct presheaf `X ↦ F(X) ⊕ G(X)`.
* `CompressionWitness J F` — a structure packaging a topology-compatible
  separating probe family.
* `JointlyAdmissible J F G R` — a single probe family that separates both
  summands, enabling strict subadditivity analysis.
* `compressionDefect J F G` — the gap `κ(F) + κ(G) - κ(F ⊕ G)`, a
  categorical analogue of mutual information.

## Main Theorems

* `presheafSeparated_coprod_of_union` — union of separating families separates
  the coproduct presheaf (given probe reachability via topology compatibility).
* `sheafCompressionNumber_coprod_le` — **subadditivity**:
  `κ_sh(J, F⊕G) ≤ κ_sh(J,F) + κ_sh(J,G)`.
* `compressionDefect_nonneg` — nonnegativity of the compression defect.
* `sheafCompressionNumber_coprod_lt_of_jointlyAdmissible` — **strict subadditivity**.
* `compressionDefect_pos_of_jointlyAdmissible` — positive mutual information
  from shared probe structure.

## Catalog References

* `Pythagorean/ProbeComplexity/Defs.lean` — probe families, `IsSeparating`
* `FINAL/Bridges/SheafCompressionFiniteSite.lean` — `PresheafSeparatedByProbes`,
  `TopologyCompatibleProbes`, `sheafCompressionNumber`, monotonicity
-/

open CategoryTheory Finset Opposite

noncomputable section

universe u v

namespace SheafCompressionCoprod

variable {C : Type u} [Category.{v} C] [DecidableEq C]

/-! ## Core Definitions (self-contained) -/

/-- A finset of objects `P` **separates** a presheaf `F` if for every object `X`
and every pair of sections, agreement under all restriction maps from probe objects
implies equality. -/
def PresheafSeparatedByProbes (P : Finset C) (F : Cᵒᵖ ⥤ Type v) : Prop :=
  ∀ (X : C) (s t : F.obj (Opposite.op X)),
    (∀ Z ∈ P, ∀ (f : Z ⟶ X), F.map f.op s = F.map f.op t) → s = t

/-- A probe family `P` is **topology-compatible** with `J` if every covering sieve
contains a morphism from some probe object. -/
def TopologyCompatibleProbes (J : GrothendieckTopology C) (P : Finset C) : Prop :=
  ∀ (X : C) (S : Sieve X), S ∈ J X → ∃ Z ∈ P, ∃ (f : Z ⟶ X), S.arrows f

/-- Cardinalities of topology-compatible separating probe families. -/
def sheafCompressionCards (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F ∧
    TopologyCompatibleProbes J P}

/-- **Sheaf compression number** `κ_sh(J, F)`. -/
def sheafCompressionNumber [Fintype C] (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (sheafCompressionCards J F)

/-! ## Monotonicity -/

omit [DecidableEq C] in
theorem PresheafSeparatedByProbes.mono {P Q : Finset C} {F : Cᵒᵖ ⥤ Type v}
    (hPQ : P ⊆ Q) (hP : PresheafSeparatedByProbes P F) :
    PresheafSeparatedByProbes Q F :=
  fun X s t hall => hP X s t (fun Z hZ f => hall Z (hPQ hZ) f)

omit [DecidableEq C] in
theorem TopologyCompatibleProbes.mono {J : GrothendieckTopology C}
    {P Q : Finset C} (hPQ : P ⊆ Q)
    (hP : TopologyCompatibleProbes J P) :
    TopologyCompatibleProbes J Q :=
  fun X S hS => let ⟨Z, hZ, f, hf⟩ := hP X S hS; ⟨Z, hPQ hZ, f, hf⟩

/-! ## Pointwise Coproduct Presheaf -/

/-- The **pointwise coproduct** of presheaves `F` and `G`, sending `X` to `F(X) ⊕ G(X)`. -/
@[simps]
def PresheafCoprod (F G : Cᵒᵖ ⥤ Type v) : Cᵒᵖ ⥤ Type v where
  obj X := Sum (F.obj X) (G.obj X)
  map f := Sum.map (F.map f) (G.map f)
  map_id X := by ext x; cases x <;> simp
  map_comp f g := by ext x; cases x <;> simp [types_comp]

/-! ## New Definitions -/

/-- A **compression witness** packages a probe family with proofs of separation
and topology compatibility. -/
structure CompressionWitness
    (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) where
  probes : Finset C
  separates : PresheafSeparatedByProbes probes F
  compatible : TopologyCompatibleProbes J probes

/-- A probe family `R` is **jointly admissible** for `F` and `G` if it separates
both and is topology-compatible. -/
def JointlyAdmissible
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (R : Finset C) : Prop :=
  PresheafSeparatedByProbes R F ∧
  PresheafSeparatedByProbes R G ∧
  TopologyCompatibleProbes J R

/-! ## Key Lemma: Topology Compatibility Implies Reachability -/

omit [DecidableEq C] in
/-- Topology-compatible probe families reach every object. -/
theorem topologyCompatible_implies_reachable
    {J : GrothendieckTopology C} {P : Finset C}
    (hP : TopologyCompatibleProbes J P) :
    ∀ X : C, ∃ Z ∈ P, Nonempty (Z ⟶ X) := by
  intro X
  obtain ⟨Z, hZ, f, _⟩ := hP X ⊤ (J.top_mem X)
  exact ⟨Z, hZ, ⟨f⟩⟩

/-! ## Theorem 1: Separation for Coproducts -/

/-- **Theorem 1 (Coproduct separation).**
If `P` separates `F`, `Q` separates `G`, and `P` is topology-compatible
(ensuring probe reachability for the mixed-summand case), then `P ∪ Q`
separates the coproduct presheaf.

The proof case-splits on the Sum structure of coproduct sections:
- Same-summand (inl/inl or inr/inr): use the corresponding separation hypothesis.
- Mixed-summand (inl/inr or inr/inl): derive contradiction from tag preservation
  under restriction maps, using reachability to produce a witness morphism. -/
theorem presheafSeparated_coprod_of_union
    {J : GrothendieckTopology C}
    {P Q : Finset C} {F G : Cᵒᵖ ⥤ Type v}
    (hF : PresheafSeparatedByProbes P F)
    (hG : PresheafSeparatedByProbes Q G)
    (hcompat : TopologyCompatibleProbes J P) :
    PresheafSeparatedByProbes (P ∪ Q) (PresheafCoprod F G) := by
  intro X s t hst
  cases s with
  | inl sF =>
    cases t with
    | inl tF =>
      -- Both left: use P-separation of F
      congr 1
      apply hF X sF tF
      intro Z hZ f
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h
      exact h
    | inr tG =>
      -- Left vs right: tag mismatch gives contradiction
      exfalso
      obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h
  | inr sG =>
    cases t with
    | inl tF =>
      -- Right vs left: symmetric tag mismatch
      exfalso
      obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h
    | inr tG =>
      -- Both right: use Q-separation of G
      congr 1
      apply hG X sG tG
      intro Z hZ f
      have h := hst Z (Finset.mem_union_right P hZ) f
      simp [PresheafCoprod] at h
      exact h

/-- Union of topology-compatible families is topology-compatible. -/
theorem topologyCompatible_union {J : GrothendieckTopology C}
    {P Q : Finset C}
    (hP : TopologyCompatibleProbes J P) :
    TopologyCompatibleProbes J (P ∪ Q) :=
  hP.mono Finset.subset_union_left

/-! ## Theorem 2: Subadditivity -/

/-- Witness combination: union of witnesses for summands gives a witness
for the coproduct. -/
def CompressionWitness.coprod
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    (wF : CompressionWitness J F)
    (wG : CompressionWitness J G) :
    CompressionWitness J (PresheafCoprod F G) where
  probes := wF.probes ∪ wG.probes
  separates := presheafSeparated_coprod_of_union wF.separates wG.separates wF.compatible
  compatible := topologyCompatible_union wF.compatible

/-- The combined witness has cardinality at most the sum. -/
theorem CompressionWitness.coprod_card_le
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    (wF : CompressionWitness J F)
    (wG : CompressionWitness J G) :
    (wF.coprod wG).probes.card ≤ wF.probes.card + wG.probes.card :=
  Finset.card_union_le wF.probes wG.probes

omit [DecidableEq C] in
/-- A witness gives an upper bound on the compression number. -/
theorem sheafCompressionNumber_le_of_witness [Fintype C]
    {J : GrothendieckTopology C} {F : Cᵒᵖ ⥤ Type v}
    (w : CompressionWitness J F) :
    sheafCompressionNumber J F ≤ w.probes.card :=
  Nat.sInf_le ⟨w.probes, rfl, w.separates, w.compatible⟩

/-- **Theorem 2 (Subadditivity of sheaf compression).**
`κ_sh(J, F ⊕ G) ≤ κ_sh(J, F) + κ_sh(J, G)`.

The proof extracts optimal witnesses, combines them via union, and bounds
the cardinality. This is the categorical analogue of `H(X,Y) ≤ H(X) + H(Y)`. -/
theorem sheafCompressionNumber_coprod_le [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    sheafCompressionNumber J (PresheafCoprod F G) ≤
      sheafCompressionNumber J F + sheafCompressionNumber J G := by
  obtain ⟨PF, hPF_card, hPF_sep, hPF_compat⟩ := Nat.sInf_mem hF
  obtain ⟨PG, hPG_card, hPG_sep, hPG_compat⟩ := Nat.sInf_mem hG
  let wF : CompressionWitness J F := ⟨PF, hPF_sep, hPF_compat⟩
  let wG : CompressionWitness J G := ⟨PG, hPG_sep, hPG_compat⟩
  calc sheafCompressionNumber J (PresheafCoprod F G)
      ≤ (wF.coprod wG).probes.card := sheafCompressionNumber_le_of_witness (wF.coprod wG)
    _ ≤ wF.probes.card + wG.probes.card := wF.coprod_card_le wG
    _ = sheafCompressionNumber J F + sheafCompressionNumber J G := by
        unfold sheafCompressionNumber; rw [← hPF_card, ← hPG_card]

/-! ## Theorem 3: Compression Defect (Mutual Information Analogue) -/

/-- The **compression defect** measures how much the subadditivity inequality
is not tight. Defined over ℤ to avoid ℕ subtraction truncation. This is the
sheaf-theoretic analogue of mutual information `I(X;Y) = H(X) + H(Y) - H(X,Y)`. -/
def compressionDefect [Fintype C] (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v) : ℤ :=
  (sheafCompressionNumber J F : ℤ) + (sheafCompressionNumber J G : ℤ) -
  (sheafCompressionNumber J (PresheafCoprod F G) : ℤ)

/-- **Theorem 3 (Nonnegativity of compression defect).**
The compression defect is nonnegative, establishing it as a valid
information-theoretic quantity. This is the `I(X;Y) ≥ 0` of sheaf compression. -/
theorem compressionDefect_nonneg [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    0 ≤ compressionDefect J F G := by
  unfold compressionDefect
  have h := sheafCompressionNumber_coprod_le J F G hF hG
  omega

/-! ## Theorem 4: Strict Subadditivity -/

/-- A jointly admissible family yields a compression witness for the coproduct. -/
theorem jointlyAdmissible_gives_coprod_witness
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    {R : Finset C} (hR : JointlyAdmissible J F G R) :
    PresheafSeparatedByProbes R (PresheafCoprod F G) ∧
    TopologyCompatibleProbes J R := by
  obtain ⟨hRF, hRG, hRcompat⟩ := hR
  refine ⟨?_, hRcompat⟩
  have hRR : R ∪ R = R := Finset.union_self R
  rw [← hRR]
  exact presheafSeparated_coprod_of_union hRF hRG hRcompat

/-- **Theorem 4 (Strict subadditivity).**
If a jointly admissible family `R` exists with `|R| < κ_sh(F) + κ_sh(G)`,
then `κ_sh(F ⊕ G) < κ_sh(F) + κ_sh(G)`. This detects geometric redundancy —
shared probes serving both presheaves simultaneously. -/
theorem sheafCompressionNumber_coprod_lt_of_jointlyAdmissible [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    {R : Finset C}
    (hR : JointlyAdmissible J F G R)
    (hR_small : R.card < sheafCompressionNumber J F + sheafCompressionNumber J G) :
    sheafCompressionNumber J (PresheafCoprod F G) <
      sheafCompressionNumber J F + sheafCompressionNumber J G := by
  obtain ⟨hsep, hcompat⟩ := jointlyAdmissible_gives_coprod_witness hR
  calc sheafCompressionNumber J (PresheafCoprod F G)
      ≤ R.card := Nat.sInf_le ⟨R, rfl, hsep, hcompat⟩
    _ < sheafCompressionNumber J F + sheafCompressionNumber J G := hR_small

/-- **Positive defect from joint admissibility.** -/
theorem compressionDefect_pos_of_jointlyAdmissible [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    {R : Finset C}
    (hR : JointlyAdmissible J F G R)
    (hR_small : R.card < sheafCompressionNumber J F + sheafCompressionNumber J G) :
    0 < compressionDefect J F G := by
  unfold compressionDefect
  have h := sheafCompressionNumber_coprod_lt_of_jointlyAdmissible J F G hR hR_small
  omega

/-! ## Theorem 5: Section Count for Coproducts -/

omit [DecidableEq C] in
/-- The number of sections of a coproduct equals the sum of section counts
of the summands. Combined with subadditivity, this gives entropy-style bounds. -/
theorem card_coprod_sections
    (F G : Cᵒᵖ ⥤ Type v) (X : Cᵒᵖ)
    [hF : Fintype (F.obj X)] [hG : Fintype (G.obj X)] :
    @Fintype.card ((PresheafCoprod F G).obj X) (instFintypeSum _ _) =
      Fintype.card (F.obj X) + Fintype.card (G.obj X) := by
  exact Fintype.card_sum

/-! ## Additional Results -/

omit [DecidableEq C] in
/-- Jointly admissible families are monotone. -/
theorem JointlyAdmissible.mono
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    {R S : Finset C} (hRS : R ⊆ S) (hR : JointlyAdmissible J F G R) :
    JointlyAdmissible J F G S :=
  ⟨hR.1.mono hRS, hR.2.1.mono hRS, hR.2.2.mono hRS⟩

/-- Every compression witness for a coproduct yields one for each summand
(by monotonicity). -/
def CompressionWitness.toLeft
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    {R : Finset C} (hR : JointlyAdmissible J F G R) :
    CompressionWitness J F :=
  ⟨R, hR.1, hR.2.2⟩

def CompressionWitness.toRight
    {J : GrothendieckTopology C} {F G : Cᵒᵖ ⥤ Type v}
    {R : Finset C} (hR : JointlyAdmissible J F G R) :
    CompressionWitness J G :=
  ⟨R, hR.2.1, hR.2.2⟩

end SheafCompressionCoprod

end