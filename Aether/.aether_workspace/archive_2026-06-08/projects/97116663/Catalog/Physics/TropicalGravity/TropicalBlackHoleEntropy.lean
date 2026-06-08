/-
# Tropical Black Hole Entropy

A rigorous mathematical framework for tropical (min-plus) thermodynamics,
formalizing the analogy between black hole entropy and tropical information theory.

## Main results

1. **Tropical partition function** equals the minimal horizon action (extremal microstate cost).
2. **Idempotent conservation**: tropical entropy is invariant under duplication of microstates.
3. **Tropical data-processing inequality**: channel composition cannot decrease extremal cost
   below input minimum plus kernel minimum.
4. **Area law**: if microstate energy is affine in area, tropical entropy is affine in area.

## Cross-domain connections

- **Information theory**: tropical channel inequality as min-plus data processing.
- **Statistical mechanics**: zero-temperature / large-deviation shadow of partition functions.
- **Tropical geometry**: optimization over microstate energy landscapes.
- **Idempotent analysis**: `min` as tropical addition, `+` as tropical multiplication.

## References to catalog infrastructure

- `tropical_universal_idempotent` (scalar idempotence of min)
- `tropical_interference_min` (extremal path selection in semiclassical limit)
- `tropical_plus_distributes_over_min` (distributivity of + over min)
- `tropical_horizon_exists_unique` (unique effective horizon parameter)
-/

import Mathlib

open Finset

noncomputable section

/-! ## Section 1: Tropical Partition Function -/

/-- The tropical partition function of a finite microstate ensemble.
    In the tropical (min-plus) semiring, summation becomes minimization.
    This is the zero-temperature / large-deviation shadow of the
    classical statistical-mechanical partition function `Z = Σ exp(-βE)`. -/
def tropicalPartition {ι : Type*} [Fintype ι] [Nonempty ι] (E : ι → ℝ) : ℝ :=
  Finset.univ.inf' (univ_nonempty) E

/-- Tropical entropy of a finite microstate ensemble.
    In the tropical regime, entropy is identified with the extremal (minimal) cost. -/
def tropicalEntropy {ι : Type*} [Fintype ι] [Nonempty ι] (E : ι → ℝ) : ℝ :=
  tropicalPartition E

/-- Tropical entropy equals the tropical partition function (definitional). -/
theorem tropical_entropy_eq_partition
    {ι : Type*} [Fintype ι] [Nonempty ι] (E : ι → ℝ) :
    tropicalEntropy E = tropicalPartition E := rfl

/-! ## Section 2: Extremal Characterization Theorems -/

/-
The tropical partition function is a lower bound for every microstate energy.
    This is the tropical analogue of "the partition function dominates each Boltzmann weight."
-/
theorem tropicalPartition_le_of_mem
    {ι : Type*} [Fintype ι] [Nonempty ι] (E : ι → ℝ) (i : ι) :
    tropicalPartition E ≤ E i := by
  exact Finset.inf'_le _ ( Finset.mem_univ i )

/-
When a unique minimizer exists, the tropical partition function equals its energy.
    This is the extremal characterization: the dominant microstate determines the partition.
-/
theorem tropicalPartition_eq_of_unique_min
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (E : ι → ℝ) (i₀ : ι)
    (hmin : ∀ i, E i₀ ≤ E i) :
    tropicalPartition E = E i₀ := by
  exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun i _ => hmin i )

/-
There exists a microstate achieving the tropical partition function value.
-/
theorem tropicalPartition_achieved
    {ι : Type*} [Fintype ι] [Nonempty ι] (E : ι → ℝ) :
    ∃ i₀ : ι, tropicalPartition E = E i₀ := by
  have h_inf : ∃ i₀, ∀ i, E i₀ ≤ E i := by
    simpa using Finset.exists_min_image Finset.univ ( fun i => E i ) ( Finset.univ_nonempty );
  exact ⟨ h_inf.choose, le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun i _ => h_inf.choose_spec i ) ⟩

/-! ## Section 3: Translation Invariance and Area Law -/

/-
Adding a constant to all microstate energies shifts the tropical partition by that constant.
    This is the key algebraic fact behind the area law: `min(Eᵢ + c) = min(Eᵢ) + c`.
    It follows from the distributivity of `+` over `min` (cf. `tropical_plus_distributes_over_min`).
-/
theorem tropicalPartition_add_constant
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (E : ι → ℝ) (c : ℝ) :
    tropicalPartition (fun i => E i + c) = tropicalPartition E + c := by
  -- The infimum of a set of numbers plus a constant is the infimum of the original set plus the constant.
  apply le_antisymm;
  · obtain ⟨ i₀, hi₀ ⟩ := tropicalPartition_achieved E;
    exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ i₀ ) ) ( by simp +decide [ hi₀ ] );
  · unfold tropicalPartition;
    simp +decide;
    exact fun i => ⟨ i, le_rfl ⟩

/-- **Tropical Area Law**: If microstate energies are affine in area,
    `E_A(i) = base(i) + λ * A`, then tropical entropy is affine in area:
    `tropicalPartition(E_A) = tropicalPartition(base) + λ * A`.

    This is the rigorous tropical shadow of the Bekenstein-Hawking entropy law `S = kA/4`:
    whenever the horizon microstate landscape carries a universal area shift,
    the tropical entropy obeys an area law exactly. -/
theorem tropical_area_law
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (base : ι → ℝ) (lam A : ℝ) :
    tropicalPartition (fun i => base i + lam * A)
      = tropicalPartition base + lam * A := by
  exact tropicalPartition_add_constant base (lam * A)

/-- **Bekenstein-Hawking form**: specialized to coefficient `k/4`.
    `tropicalPartition(base + (k/4)*A) = tropicalPartition(base) + (k/4)*A`. -/
theorem tropical_bekenstein_hawking_form
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (base : ι → ℝ) (k A : ℝ) :
    tropicalPartition (fun i => base i + (k / 4) * A)
      = tropicalPartition base + (k / 4) * A :=
  tropical_area_law base (k / 4) A

/-! ## Section 4: Idempotent Conservation (Duplication Invariance) -/

/-- Energy function on a sum type, combining two ensembles. -/
def sumEnergy {α β : Type*} (Eα : α → ℝ) (Eβ : β → ℝ) : Sum α β → ℝ
  | Sum.inl a => Eα a
  | Sum.inr b => Eβ b

/-
**Idempotent conservation**: Duplicating an ensemble does not change tropical entropy.
    This is the finite-type manifestation of `min(a, a) = a` (tropical idempotence).
    In the information-paradox analogy: duplicating radiation channels with the same
    extremal costs adds no new tropical information.
-/
theorem tropicalPartition_sum_same
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (E : ι → ℝ) :
    tropicalPartition (sumEnergy E E) = tropicalPartition E := by
  unfold tropicalPartition;
  unfold sumEnergy;
  refine' le_antisymm _ _ <;> simp +decide;
  · exact fun b => ⟨ b, le_rfl ⟩;
  · exact fun a => ⟨ a, le_rfl ⟩

/-
**Spectrum equivalence**: Two ensembles with the same energy spectrum
    (every energy in one is achieved in the other) have equal tropical partition functions.
    This captures the essential idempotent principle: only the extremal frontier matters.
-/
theorem tropicalPartition_image_eq
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (Eι : ι → ℝ) (Eκ : κ → ℝ)
    (hleft : ∀ i, ∃ k, Eκ k = Eι i)
    (hright : ∀ k, ∃ i, Eι i = Eκ k) :
    tropicalPartition Eι = tropicalPartition Eκ := by
  refine' le_antisymm _ _ <;> simp_all +decide [ tropicalPartition ];
  · exact fun k => by obtain ⟨ i, hi ⟩ := hright k; exact ⟨ i, hi.le ⟩ ;
  · exact fun i => by obtain ⟨ k, hk ⟩ := hleft i; exact ⟨ k, hk.le ⟩ ;

/-! ## Section 5: Tropical Radiation Channel -/

/-- The tropical channel output cost at radiation state `b`:
    the minimum over input microstates of `E(a) + K(a,b)`.
    This models Hawking radiation as a tropical noisy channel
    where cost replaces probability. -/
def tropicalChannel
    {α β : Type*} [Fintype α] [Nonempty α]
    (E : α → ℝ) (K : α → β → ℝ) (b : β) : ℝ :=
  Finset.univ.inf' univ_nonempty (fun a => E a + K a b)

/-- The tropical output entropy: minimum output cost over all radiation states. -/
def tropicalOutputEntropy
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (E : α → ℝ) (K : α → β → ℝ) : ℝ :=
  tropicalPartition (tropicalChannel E K)

/-- The minimum channel cost over all input-output pairs. -/
def kernelMin
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (K : α → β → ℝ) : ℝ :=
  (Finset.univ.product Finset.univ).inf'
    (by simp [Finset.Nonempty])
    (fun p => K p.1 p.2)

/-
**Tropical Data-Processing Inequality**: The minimum output cost is at least
    the minimum input cost plus the minimum channel cost.
    `min_b min_a (E(a) + K(a,b)) ≥ min_a E(a) + min_{a,b} K(a,b)`

    This is the fundamental information-theoretic inequality:
    a tropical noisy channel cannot create extremal information from nothing.
    It only shifts the extremal cost by the best available channel cost.
-/
theorem tropical_output_ge_input_plus_kernelMin
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (E : α → ℝ) (K : α → β → ℝ) :
    tropicalOutputEntropy E K ≥ tropicalPartition E + kernelMin K := by
  refine' Finset.le_inf' _ _ fun b _ => _;
  · exact ⟨ Classical.arbitrary β, Finset.mem_univ _ ⟩;
  · refine' Finset.le_inf' _ _ fun a _ => _;
    exact add_le_add ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.inf'_le _ ( Finset.mk_mem_product ( Finset.mem_univ _ ) ( Finset.mem_univ _ ) ) )

/-
**Equality in the tropical data-processing inequality**: When there exist
    jointly minimizing states `a₀, b₀` that simultaneously minimize E and K,
    the data-processing bound is tight.
-/
theorem tropical_output_eq_if_joint_minimizer
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (E : α → ℝ) (K : α → β → ℝ)
    (a₀ : α) (b₀ : β)
    (hE : ∀ a, E a₀ ≤ E a)
    (hK : ∀ a b, K a₀ b₀ ≤ K a b) :
    tropicalOutputEntropy E K = tropicalPartition E + kernelMin K := by
  refine' le_antisymm _ _;
  · refine' le_trans ( Finset.inf'_le _ _ ) _;
    exact b₀;
    · exact Finset.mem_univ _;
    · refine' le_trans ( Finset.inf'_le _ _ ) _;
      exact a₀;
      · exact Finset.mem_univ a₀;
      · refine' add_le_add _ _;
        · exact Finset.le_inf' _ _ fun a _ => hE a;
        · exact Finset.le_inf' _ _ fun p hp => hK p.1 p.2;
  · exact tropical_output_ge_input_plus_kernelMin E K

/-! ## Section 6: Monotonicity of Tropical Partition -/

/-
Pointwise domination of energies implies domination of partition functions.
-/
theorem tropicalPartition_mono
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (E₁ E₂ : ι → ℝ) (h : ∀ i, E₁ i ≤ E₂ i) :
    tropicalPartition E₁ ≤ tropicalPartition E₂ := by
  unfold tropicalPartition;
  simp +decide;
  exact fun i => ⟨ i, h i ⟩

end