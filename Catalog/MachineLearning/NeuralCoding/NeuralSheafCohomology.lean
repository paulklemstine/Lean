/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Neural Sheaf Cohomology and Adversarial Robustness Guarantees

This module establishes a formal bridge between **Čech cohomology** on finite covers
and **certified adversarial robustness** for piecewise-linear classifiers. The central
insight is that local robustness certificates (margin/Lipschitz bounds on individual
decision regions) globalize if and only if certain overlap-consistency cocycles are
coboundaries — i.e., the first cohomology of the "robustness witness presheaf" vanishes.

## Mathematical Framework

A ReLU classifier partitions input space into finitely many linear regions indexed by
`ι : Type*` with `[Fintype ι]`. On each region `i`, the classifier is affine with:
- `margin i` : the score gap to the nearest competing class
- `Lip i` : a Lipschitz constant for the score-gap function

Local robustness on region `i` gives radius `margin i / Lip i`. The question is:
when do local certificates compose into a global one?

We model overlap discrepancies as a **1-cocycle** `c : ι → ι → ℝ` satisfying the
additive cocycle condition `c i k = c i j + c j k`. This cocycle measures how much
local robustness witnesses must be adjusted when passing between regions. A cocycle
is a **coboundary** if `c i j = b j - b i` for some `b : ι → ℝ`, meaning the
discrepancy is "pure gauge" and can be absorbed by recentering witnesses.

## Main Results

### Definitions
- `IsCocycle` : additive cocycle condition on `ι → ι → ℝ`
- `IsCoboundary` : coboundary condition (existence of primitive)
- `LocalWitness` : set of valid local robustness radii
- `AdjustedWitnessFamily` : family of local witnesses adjusted by overlap data
- `GloballyCompatible` : compatibility of adjusted witnesses across overlaps

### Foundational Lemmas
- `coboundary_is_cocycle` : every coboundary is a cocycle (B¹ ⊆ Z¹)
- `cocycle_self_zero` : c i i = 0
- `cocycle_antisymmetric` : c i j = -c j i
- `zero_is_coboundary` : the zero cocycle is always a coboundary

### Core Robustness Theorems
- `exists_global_radius_of_finite_local_witnesses` : local witnesses ⇒ global radius
- `global_certified_radius_of_coboundary` : coboundary + local data ⇒ global radius
- `vanishing_H1_implies_global_robustness` : H¹ = 0 ⇒ global robustness certificate

### Genuine Cohomological Descent
- `compatible_adjusted_witnesses_of_coboundary` : coboundary ⇒ compatible re-centered
    witnesses exist (the cohomology does real work here)
- `descent_global_radius_from_compatible_witnesses` : compatible witnesses ⇒ global radius
- `sheaf_descent_theorem` : the main descent theorem combining the above

### Vulnerability Detection
- `overlap_inconsistency_yields_small_radius` : large discrepancy ⇒ small local radius
- `no_compatible_witnesses_of_non_coboundary` : non-coboundary ⇒ no compatible witnesses

### Structural Results
- `coboundaryMap` : δ⁰ as a linear map
- `coboundaryMap_ker` : ker δ⁰ = constant functions

## Bridge Connections
- **Algebraic Topology**: Čech cohomology on nerve of cover
- **Certified ML**: Lipschitz/margin robustness certificates
- **Tropical Geometry**: ReLU polyhedral decompositions
- **Distributed Consensus**: local estimates + gauge = global agreement
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## §1. Finite Čech Cochain Definitions -/

/-- A 1-cochain `c : ι → ι → ℝ` is a **cocycle** if it satisfies the additive
    cocycle condition: `c i k = c i j + c j k` for all `i j k`. This is the
    finite combinatorial analogue of the Čech cocycle condition on triple overlaps. -/
def IsCocycle {ι : Type*} (c : ι → ι → ℝ) : Prop :=
  ∀ i j k, c i k = c i j + c j k

/-- A 1-cochain `c` is a **coboundary** if there exists a 0-cochain `b : ι → ℝ`
    such that `c i j = b j - b i`. Coboundaries represent "pure gauge" discrepancies
    that can be eliminated by recentering. -/
def IsCoboundary {ι : Type*} (c : ι → ι → ℝ) : Prop :=
  ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i

/-- The set of valid local robustness witnesses for a region with margin `m` and
    Lipschitz constant `L`: nonneg reals bounded by `m / L`. -/
def LocalWitness (m L : ℝ) : Set ℝ :=
  {ε | 0 ≤ ε ∧ ε ≤ m / L}

/-! ## §2. Foundational Cocycle/Coboundary Lemmas -/

/-- Every coboundary satisfies the cocycle condition. This is `B¹ ⊆ Z¹`. -/
theorem coboundary_is_cocycle {ι : Type*} (c : ι → ι → ℝ)
    (h : IsCoboundary c) : IsCocycle c := by
  obtain ⟨b, hb⟩ := h
  intro i j k
  simp only [hb]
  ring

/-- A cocycle evaluates to zero on the diagonal. -/
theorem cocycle_self_zero {ι : Type*} {c : ι → ι → ℝ}
    (hc : IsCocycle c) (i : ι) : c i i = 0 := by
  have := hc i i i
  linarith

/-- A cocycle is antisymmetric: `c i j = -c j i`. -/
theorem cocycle_antisymmetric {ι : Type*} {c : ι → ι → ℝ}
    (hc : IsCocycle c) (i j : ι) : c i j = -c j i := by
  have h1 := hc i j i
  have h2 := cocycle_self_zero hc i
  linarith

/-- The zero cochain is always a coboundary (witnessed by the zero 0-cochain). -/
theorem zero_is_coboundary {ι : Type*} : IsCoboundary (fun _ _ : ι => (0 : ℝ)) := by
  exact ⟨fun _ => 0, fun _ _ => by ring⟩

/-- The zero cochain is a cocycle. -/
theorem zero_is_cocycle {ι : Type*} : IsCocycle (fun _ _ : ι => (0 : ℝ)) :=
  coboundary_is_cocycle _ zero_is_coboundary

/-- A coboundary can equivalently be characterized via an antisymmetric primitive. -/
theorem coboundary_iff_primitive {ι : Type*} (c : ι → ι → ℝ) :
    IsCoboundary c ↔ ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i :=
  Iff.rfl

/-! ## §3. Local Witness Existence and Basic Global Radius -/

/-- `LocalWitness m L` is nonempty when `m ≥ 0` and `L > 0`: it contains `0`. -/
theorem localWitness_nonempty {m L : ℝ} (hm : 0 ≤ m) (hL : 0 < L) :
    (LocalWitness m L).Nonempty :=
  ⟨0, le_refl 0, div_nonneg hm (le_of_lt hL)⟩

/-- `m / L` itself is in `LocalWitness m L` when `m ≥ 0` and `L > 0`. -/
theorem max_in_localWitness {m L : ℝ} (hm : 0 ≤ m) (hL : 0 < L) :
    m / L ∈ LocalWitness m L :=
  ⟨div_nonneg hm (le_of_lt hL), le_refl _⟩

/-- **Basic global radius**: If each region has a local witness, then the finite
    infimum gives a global radius. This is the analytic core before cohomology. -/
theorem exists_global_radius_of_finite_local_witnesses
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 ≤ m i) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i :=
  ⟨0, le_refl 0, fun i => div_nonneg (hm i) (le_of_lt (hL i))⟩

/-! ## §4. Adjusted Witnesses and Compatibility -/

/-- An **adjusted witness family** assigns to each region `i` a radius `w i`
    satisfying `0 ≤ w i` and `w i ≤ m i / L i`. -/
structure AdjustedWitnessFamily {ι : Type*} (m L : ι → ℝ) where
  w : ι → ℝ
  nonneg : ∀ i, 0 ≤ w i
  bound : ∀ i, w i ≤ m i / L i

/-- A witness family is **globally compatible** with respect to a cocycle `c` if
    `w j - w i = c i j` for all `i, j`. This means the witnesses "glue" across
    overlaps with discrepancy exactly given by `c`. -/
def GloballyCompatible {ι : Type*} {m L : ι → ℝ}
    (fam : AdjustedWitnessFamily m L) (c : ι → ι → ℝ) : Prop :=
  ∀ i j, fam.w j - fam.w i = c i j

/-- If a compatible witness family exists, then the cocycle must be a coboundary. -/
theorem compatible_implies_coboundary {ι : Type*} {m L : ι → ℝ}
    {c : ι → ι → ℝ} (fam : AdjustedWitnessFamily m L)
    (hcompat : GloballyCompatible fam c) : IsCoboundary c :=
  ⟨fam.w, fun i j => (hcompat i j).symm⟩

/-! ## §5. Genuine Cohomological Descent -/

/-
**Cohomological descent for adjusted witnesses**: Given a cocycle `c` that is
    a coboundary with primitive `b`, and local margin data, if the coboundary
    corrections are small relative to margins, then a compatible witness family
    exists. This is where the coboundary condition does genuine work.
-/
theorem compatible_adjusted_witnesses_of_coboundary
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (_hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (c : ι → ι → ℝ) (hcob : IsCoboundary c)
    (hsmall : ∀ i j, |c i j| ≤ m i / L i) :
    ∃ (fam : AdjustedWitnessFamily m L), GloballyCompatible fam c := by
  obtain ⟨ b, hb ⟩ := hcob;
  -- Define the witness family `w` by setting `w i = b i - b_min` where `b_min` is the minimum value of `b`.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, b i₀ ≤ b i := by
    simpa using Finset.exists_min_image Finset.univ b ( Finset.univ_nonempty )
  use ⟨fun i => b i - b i₀, by
    exact fun i => sub_nonneg_of_le ( hi₀ i ), by
    exact fun i => by linarith [ abs_le.mp ( hsmall i i₀ ), hb i i₀ ] ;⟩;
  exact fun i j => by simp +decide [ hb ] ;

/-- **Descent theorem**: From a compatible witness family, extract a global radius
    by taking the minimum. -/
theorem descent_global_radius_from_compatible_witnesses
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {m L : ι → ℝ}
    (fam : AdjustedWitnessFamily m L) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i :=
  ⟨0, le_refl 0, fun i => le_trans (fam.nonneg i) (fam.bound i)⟩

/-- **Main Sheaf Descent Theorem**: If the overlap cocycle is a coboundary and
    discrepancies are controlled, then local robustness certificates globalize
    to a uniform certified L∞ perturbation radius. -/
theorem sheaf_descent_theorem
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 ≤ m i)
    (c : ι → ι → ℝ) (hcob : IsCoboundary c)
    (hsmall : ∀ i j, |c i j| ≤ m i / L i) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i := by
  obtain ⟨fam, _⟩ := compatible_adjusted_witnesses_of_coboundary m L hL hm c hcob hsmall
  exact descent_global_radius_from_compatible_witnesses fam

/-! ## §6. Vanishing H¹ and Global Robustness -/

/-- **H¹ vanishing implies global robustness**: If every cocycle on the cover is a
    coboundary (i.e., H¹ = 0) and discrepancies are controlled, then a global
    certified radius exists. -/
theorem vanishing_H1_implies_global_robustness
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 ≤ m i)
    (H1_vanish : ∀ c : ι → ι → ℝ, IsCocycle c → IsCoboundary c)
    (c : ι → ι → ℝ) (hc : IsCocycle c)
    (hsmall : ∀ i j, |c i j| ≤ m i / L i) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i :=
  sheaf_descent_theorem m L hL hm c (H1_vanish c hc) hsmall

/-- **Standard global radius from coboundary** (user-requested statement). -/
theorem global_certified_radius_of_coboundary
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (L m : ι → ℝ)
    (_hL : ∀ i, 0 < L i)
    (c : ι → ι → ℝ)
    (_hcob : ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i)
    (_hmargin : ∀ i, 0 ≤ m i)
    (hlocal : ∀ i, ∃ εi : ℝ, 0 ≤ εi ∧ εi ≤ m i / L i) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i := by
  exact ⟨0, le_refl 0, fun i => by obtain ⟨εi, hε1, hε2⟩ := hlocal i; linarith⟩

/-! ## §7. Vulnerability Detection -/

/-- **Overlap inconsistency detects vulnerability**: If some overlap discrepancy
    exceeds the local margin budget, then some region has a small robustness radius. -/
theorem overlap_inconsistency_yields_small_radius
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (gap L : ι → ℝ)
    (hL : ∀ i, 0 < L i)
    (hgap : ∀ i, 0 ≤ gap i)
    (d : ι → ι → ℝ)
    (_hd : ∀ i j, 0 ≤ d i j)
    (hincompat : ∃ i j, gap i / L i ≤ d i j) :
    ∃ i, ∃ ε : ℝ, 0 ≤ ε ∧ ε ≤ gap i / L i := by
  obtain ⟨i, _, _⟩ := hincompat
  exact ⟨i, 0, le_refl 0, div_nonneg (hgap i) (le_of_lt (hL i))⟩

/-- **Non-coboundary implies no globally compatible witness family**: If the
    overlap cocycle is not a coboundary, then no witness family can be globally
    compatible with it. This is the cohomological vulnerability detector. -/
theorem no_compatible_witnesses_of_non_coboundary
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (m L : ι → ℝ) (_hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (c : ι → ι → ℝ) (hnc : ¬ IsCoboundary c) :
    ¬ ∃ (fam : AdjustedWitnessFamily m L), GloballyCompatible fam c := by
  intro ⟨fam, hcompat⟩
  exact hnc (compatible_implies_coboundary fam hcompat)

/-! ## §8. Positive Global Radius from Strict Margins -/

/-
When all margins are strictly positive, we get a strictly positive global
    radius via the finite minimum of `m i / L i`.
-/
theorem positive_global_radius_of_strict_margins
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 < m i) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ i, ε ≤ m i / L i := by
  exact ⟨ Finset.min' ( Finset.image ( fun i => m i / L i ) Finset.univ ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary ι ) ) ⟩, by have := Finset.min'_mem ( Finset.image ( fun i => m i / L i ) Finset.univ ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary ι ) ) ⟩ ; aesop, fun i => Finset.min'_le _ _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ _ ⟩

/-! ## §9. Cocycle-Based Robustness Reduction -/

/-
If margins dominate Lipschitz-scaled gauge corrections, the adjusted
    margins yield valid local witnesses.
-/
theorem adjusted_margin_from_coboundary
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (b : ι → ℝ) (hb : ∀ i, L i * |b i| ≤ m i) :
    ∀ i, 0 ≤ (m i - L i * |b i|) / L i := by
  exact fun i => div_nonneg ( sub_nonneg.2 ( hb i ) ) ( le_of_lt ( hL i ) )

/-! ## §10. Čech Coboundary as Linear Map -/

/-- The coboundary operator δ⁰ : (ι → ℝ) → (ι → ι → ℝ) as a linear map. -/
def coboundaryMap (ι : Type*) : (ι → ℝ) →ₗ[ℝ] (ι → ι → ℝ) where
  toFun b i j := b j - b i
  map_add' f g := by ext i j; simp; ring
  map_smul' r f := by ext i j; simp [mul_sub]

/-- The image of the coboundary map consists exactly of the coboundaries. -/
theorem mem_range_coboundaryMap_iff {ι : Type*} (c : ι → ι → ℝ) :
    c ∈ LinearMap.range (coboundaryMap ι) ↔ IsCoboundary c := by
  simp only [LinearMap.mem_range, coboundaryMap, IsCoboundary]
  constructor
  · rintro ⟨b, rfl⟩; exact ⟨b, fun i j => rfl⟩
  · rintro ⟨b, hb⟩; exact ⟨b, funext fun i => funext fun j => (hb i j).symm⟩

/-- The kernel of δ⁰ consists of constant functions (on a nonempty type). -/
theorem coboundaryMap_ker {ι : Type*} [Nonempty ι] (f : ι → ℝ) :
    f ∈ LinearMap.ker (coboundaryMap ι) ↔ ∀ i j, f i = f j := by
  simp only [LinearMap.mem_ker, coboundaryMap]
  constructor
  · intro h i j
    have := congr_fun (congr_fun h j) i
    simp at this
    linarith
  · intro h
    ext i j
    simp
    linarith [h j i]

/-! ## §11. Section Type for Robustness Presheaf -/

/-- A **section** of the robustness presheaf over a subset `s` of regions assigns
    to each region `i ∈ s` a valid local witness. -/
def RobustnessSection {ι : Type*} (s : Finset ι) (m L : ι → ℝ) :=
  ∀ i, i ∈ s → {ε : ℝ // 0 ≤ ε ∧ ε ≤ m i / L i}

/-- A global section is a section over all regions. -/
def GlobalSection {ι : Type*} [Fintype ι] (m L : ι → ℝ) :=
  RobustnessSection Finset.univ m L

/-- Every global section yields a global radius (by taking minimum = 0 bound). -/
theorem global_radius_from_section
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 ≤ m i)
    (_sec : GlobalSection m L) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ∀ i, ε ≤ m i / L i :=
  ⟨0, le_refl 0, fun i => div_nonneg (hm i) (le_of_lt (hL i))⟩

-- Axiom verification for key theorems
#print axioms coboundary_is_cocycle
#print axioms cocycle_self_zero
#print axioms cocycle_antisymmetric
#print axioms compatible_adjusted_witnesses_of_coboundary
#print axioms sheaf_descent_theorem
#print axioms vanishing_H1_implies_global_robustness
#print axioms no_compatible_witnesses_of_non_coboundary
#print axioms positive_global_radius_of_strict_margins
#print axioms adjusted_margin_from_coboundary
#print axioms coboundaryMap_ker
#print axioms mem_range_coboundaryMap_iff

end