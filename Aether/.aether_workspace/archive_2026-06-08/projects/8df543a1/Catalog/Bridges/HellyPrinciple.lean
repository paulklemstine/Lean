/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# A Categorical Helly Principle for Probe Families

This file establishes a **local-to-global finite generation principle** for
probe-separated presheaves on finite discrete categories. The central idea is
that a separating probe family P of size k creates a "measurement window" of
bounded size: to control the global representable dimension of a presheaf F,
it suffices to check fiber sizes on subsets of size at most k + 1.

This is a categorical analogue of **Helly's theorem** from convex geometry.

## Main Definitions

* `restrictedRepDim` — the representable dimension restricted to a subset S.
* `Presheaf.LocallyRepFinGenUpTo` — locally representably finitely generated.
* `probeCapacity` — product of fiber sizes at probe objects.
* `categoricalHellyNumber` — the Helly number |P| + 1.
* `MinimalNonSeparatedWitness` — obstruction witness.

## Main Results

* `fiber_le_probe_capacity` — fiber bound under separation. (**Theorem 1**)
* `repFinGen_of_local_on_helly_bound` — categorical Helly theorem. (**Theorem 2**)
* `separation_supset_presheaf` — separation preserved by enlargement. (**Theorem 3**)
* `obstruction_localized_to_helly_number` — obstruction localization. (**Theorem 4**)
-/

open Finset Fintype CategoryTheory

noncomputable section

universe u v

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ### Inherited Definitions (from ProbeComplexity.RepresentableDimension) -/

/-- A probe family for the discrete presheaf model. -/
abbrev ObProbeFamilyH (Ob : Type u) := Finset Ob

/-- The probe signature of an element `x ∈ F(Y)` records its image under
restriction maps `r Y Z` for each probe object `Z ∈ P`. -/
def probeSignatureH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) (x : F Y) : ∀ Z : ↥P, F (↑Z) :=
  fun ⟨Z, _⟩ => r Y Z x

/-- The probe signature map is injective at object Y. -/
def ProbeSignatureInjectiveH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) : Prop :=
  Function.Injective (probeSignatureH P r Y)

/-- A probe family separates a presheaf F if probe signatures are
injective at every object. -/
def PresheafProbeSeparatesH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ Y, ProbeSignatureInjectiveH P r Y

/-- Total objectwise cardinality of a presheaf. -/
def objectwiseTotalCardH
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] : ℕ :=
  ∑ Y : Ob, Fintype.card (F Y)

/-! ### New Definitions -/

/-- The **restricted representable dimension** on a subset S: the sum of
fiber cardinalities over objects in S. -/
def restrictedRepDim (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (S : Finset Ob) : ℕ :=
  S.sum fun Y => Fintype.card (F Y)

/-- A presheaf is **locally representably finitely generated up to k** with
bound n if every restriction to at most k objects has total fiber size ≤ n. -/
def Presheaf.LocallyRepFinGenUpTo
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] (k n : ℕ) : Prop :=
  ∀ S : Finset Ob, S.card ≤ k → restrictedRepDim F S ≤ n

/-- The **probe capacity** of F w.r.t. P: the product of fiber sizes at
probe objects. Under separation, this bounds each individual fiber. -/
def probeCapacity
    (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) : ℕ :=
  ∏ Z : ↥P, Fintype.card (F ↑Z)

/-- The **categorical Helly number** of a probe family P is |P| + 1. -/
def categoricalHellyNumber (P : ObProbeFamilyH Ob) : ℕ := P.card + 1

/-- A **minimal non-separated witness** at object Y: a pair of distinct
elements with identical probe signatures. -/
def MinimalNonSeparatedWitness
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z) (Y : Ob) : Prop :=
  ∃ (x y : F Y), x ≠ y ∧ probeSignatureH P r Y x = probeSignatureH P r Y y

/-! ### Helper Lemmas -/

/-- Restricted representable dimension on a singleton equals the fiber size. -/
theorem restrictedRepDim_singleton (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (Z : Ob) : restrictedRepDim F {Z} = Fintype.card (F Z) := by
  simp [restrictedRepDim]

/-- Restricted representable dimension is monotone under subset inclusion. -/
theorem restrictedRepDim_mono (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {S T : Finset Ob} (hST : S ⊆ T) :
    restrictedRepDim F S ≤ restrictedRepDim F T := by
  exact Finset.sum_le_sum_of_subset hST

/-- Restricted representable dimension on univ equals objectwise total card. -/
theorem restrictedRepDim_univ (F : Ob → Type v) [∀ Y, Fintype (F Y)] :
    restrictedRepDim F Finset.univ = objectwiseTotalCardH F := by
  simp [restrictedRepDim, objectwiseTotalCardH]

/-- Each probe-object fiber is bounded by the local bound n. -/
theorem probe_fiber_le_of_local_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (categoricalHellyNumber P) n)
    (Z : Ob) (hZ : Z ∈ P) :
    Fintype.card (F Z) ≤ n := by
  have h1 : ({Z} : Finset Ob).card ≤ categoricalHellyNumber P := by
    simp [categoricalHellyNumber]
  have h2 := hlocal {Z} h1
  rwa [restrictedRepDim_singleton] at h2

/-- Every fiber is bounded by the local bound n when k ≥ 1. -/
theorem every_fiber_le_of_local_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (k n : ℕ) (hk : 1 ≤ k)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F k n)
    (Y : Ob) :
    Fintype.card (F Y) ≤ n := by
  have h1 : ({Y} : Finset Ob).card ≤ k := by simp; omega
  have h2 := hlocal {Y} h1
  rwa [restrictedRepDim_singleton] at h2

/-
The probe capacity is bounded by n^|P| when each probe fiber is ≤ n.
-/
theorem probe_capacity_le_pow
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (n : ℕ)
    (hbound : ∀ Z : Ob, Z ∈ P → Fintype.card (F Z) ≤ n) :
    probeCapacity F P ≤ n ^ P.card := by
  convert Finset.prod_le_prod' fun Z hZ => hbound Z <| Finset.mem_coe.mp hZ;
  · refine' Finset.prod_bij ( fun x hx => x ) _ _ _ _ <;> simp +decide;
  · rw [ Finset.prod_const, Finset.card_eq_sum_ones ]

/-! ### Theorem 1: Fiber Capacity Bound -/

/-
**Theorem 1 (Fiber Capacity Bound — the Helly Engine).**

Under probe separation, each fiber |F(Y)| is bounded by the product
of fiber sizes at probe objects: |F(Y)| ≤ ∏_{Z ∈ P} |F(Z)|.
-/
theorem fiber_le_probe_capacity
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    (hsep : PresheafProbeSeparatesH P r) (Y : Ob) :
    Fintype.card (F Y) ≤ probeCapacity F P := by
  convert Fintype.card_le_of_injective _ ( hsep Y ) using 1;
  rw [ Fintype.card_pi ];
  rfl

/-! ### Theorem 2: The Categorical Helly Theorem -/

/-- **Theorem 2 (The Categorical Helly Theorem).**

If P separates F and every subset of Ob of size ≤ |P| + 1 has restricted
representable dimension ≤ n, then the global representable dimension is
at most |Ob| · n^|P|.

**Proof architecture:**
1. Each probe-object fiber |F(Z)| ≤ n (from local bound on singletons).
2. Probe capacity ∏_{Z ∈ P} |F(Z)| ≤ n^|P| (product of bounded terms).
3. Each fiber |F(Y)| ≤ n^|P| (from Theorem 1 + step 2).
4. Sum: ∑_Y |F(Y)| ≤ |Ob| · n^|P|. -/
theorem repFinGen_of_local_on_helly_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    (hsep : PresheafProbeSeparatesH P r)
    (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (categoricalHellyNumber P) n) :
    objectwiseTotalCardH F ≤ Fintype.card Ob * n ^ P.card := by
  have hprobe_bound : ∀ Z : Ob, Z ∈ P → Fintype.card (F Z) ≤ n :=
    fun Z hZ => probe_fiber_le_of_local_bound P n hlocal Z hZ
  have hcap : probeCapacity F P ≤ n ^ P.card :=
    probe_capacity_le_pow P n hprobe_bound
  have hfiber : ∀ Y : Ob, Fintype.card (F Y) ≤ n ^ P.card :=
    fun Y => le_trans (fiber_le_probe_capacity P r hsep Y) hcap
  unfold objectwiseTotalCardH
  calc ∑ Y : Ob, Fintype.card (F Y)
      ≤ ∑ _Y : Ob, n ^ P.card :=
        Finset.sum_le_sum (fun Y _ => hfiber Y)
    _ = Fintype.card Ob * n ^ P.card := by
        simp [Finset.sum_const, Finset.card_univ]

/-! ### Theorem 3: Monotonicity -/

/-- **Monotonicity of Local Generation Bounds.** -/
theorem locallyRepFinGen_mono
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {k l n : ℕ} (hkl : k ≤ l) :
    Presheaf.LocallyRepFinGenUpTo F l n →
    Presheaf.LocallyRepFinGenUpTo F k n := by
  intro h S hS
  exact h S (le_trans hS hkl)

/-! ### Theorem 4: Separation Preserved by Probe Enlargement -/

/-
**Separation Preserved by Probe Enlargement.**

If P separates F and Q ⊇ P, then Q also separates F.
Presheaf-level analogue of `ProbeFamily.IsSeparating.supset`.
-/
theorem separation_supset_presheaf
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P Q : ObProbeFamilyH Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPQ : P ⊆ Q)
    (hsep : PresheafProbeSeparatesH P r) :
    PresheafProbeSeparatesH Q r := by
  intro Y y hxy; have := @hsep Y; simp_all +decide [ funext_iff, Finset.subset_iff ] ;
  exact fun h => this <| funext fun ⟨ Z, hZ ⟩ => h Z ( hPQ hZ )

/-! ### Theorem 5: Helly Bound Strengthens with More Probes -/

/-- If P ⊆ Q, then Q's Helly bound applies whenever P separates. -/
theorem helly_bound_strengthens_with_more_probes
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P Q : ObProbeFamilyH Ob}
    (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    [DecidableEq (∀ Z : ↥Q, F ↑Z)]
    (hPQ : P ⊆ Q)
    (hsep : PresheafProbeSeparatesH P r)
    (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (categoricalHellyNumber Q) n) :
    objectwiseTotalCardH F ≤ Fintype.card Ob * n ^ Q.card :=
  repFinGen_of_local_on_helly_bound Q r
    (separation_supset_presheaf r hPQ hsep) n hlocal

/-! ### Obstruction Theory -/

/-
**Obstruction Localization.**

If P does not separate F, then there exists an object Y and a non-separated
pair, whose support is contained in {Y} ∪ P (size ≤ |P| + 1).
-/
theorem obstruction_localized_to_helly_number
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    (hfail : ¬PresheafProbeSeparatesH P r) :
    ∃ Y : Ob, MinimalNonSeparatedWitness P r Y := by
  contrapose! hfail;
  exact fun Y => fun x y hxy => Classical.not_not.1 fun h => hfail Y ⟨ x, y, h, hxy ⟩

/-
The support of a non-separation witness is bounded by the Helly number.
-/
theorem witness_support_bounded
    (P : ObProbeFamilyH Ob) (Y : Ob) :
    ({Y} ∪ P).card ≤ categoricalHellyNumber P := by
  exact le_trans ( Finset.card_union_le _ _ ) ( by simp +arith +decide [ categoricalHellyNumber ] )

/-! ### Global Bounds -/

/-- If n bounds the restricted rep dim on ALL subsets of size ≤ |Ob|,
then n bounds the global rep dim. -/
theorem repDim_le_of_local_bound_on_all
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (Fintype.card Ob) n) :
    objectwiseTotalCardH F ≤ n := by
  have : restrictedRepDim F Finset.univ ≤ n :=
    hlocal Finset.univ (by simp)
  rwa [restrictedRepDim_univ] at this

/-
Under separation, the representable dimension is at most
|Ob| times the probe capacity.
-/
theorem repDim_le_card_mul_probe_capacity
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    (hsep : PresheafProbeSeparatesH P r) :
    objectwiseTotalCardH F ≤ Fintype.card Ob * probeCapacity F P := by
  -- Apply the bound on each fiber to the sum.
  have h_sum : ∑ Y : Ob, Fintype.card (F Y) ≤ ∑ Y : Ob, probeCapacity F P := by
    exact Finset.sum_le_sum fun Y _ => fiber_le_probe_capacity P r hsep Y;
  aesop

/-! ### Connection to Existing Theory -/

/-- The Helly number of the total probe family equals |Ob| + 1. -/
theorem categoricalHellyNumber_total :
    categoricalHellyNumber (Finset.univ : ObProbeFamilyH Ob) =
      Fintype.card Ob + 1 := by
  simp [categoricalHellyNumber]

/-- For the empty probe family, the Helly number is 1. -/
theorem categoricalHellyNumber_empty :
    categoricalHellyNumber (∅ : ObProbeFamilyH Ob) = 1 := by
  simp [categoricalHellyNumber]

/-
When every fiber equals the probe capacity, the representable dimension
exactly equals |Ob| * probeCapacity.
-/
theorem repDim_eq_of_all_fibers_maximal
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob)
    (hmax : ∀ Y : Ob, Fintype.card (F Y) = probeCapacity F P) :
    objectwiseTotalCardH F = Fintype.card Ob * probeCapacity F P := by
  unfold objectwiseTotalCardH; simp +decide [ hmax, Finset.sum_const ] ;

end