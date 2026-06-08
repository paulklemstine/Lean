/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Pythagorean.TropicalEntanglement.Defs

/-!
# Tropical Entanglement Certificates — Main Theorems

This file proves the core theorems of tropical entanglement certificate theory,
establishing that the tropical partition witness is a sound diagnostic for
multipartite quantum entanglement.

## Main Results

### Soundness (product states vanish)
* `tropicalPartitionWitness_nonneg` — The witness is always nonnegative.
* `tropicalPartitionWitness_eq_zero_of_isProductAcross` — Product states yield zero.
* `tropicalPartitionWitness_eq_zero_of_fullySeparable` — Fully separable states
  yield zero on every nontrivial cut.

### Detection (entangled states are positive)
* `tropicalPartitionWitness_ghz_pos` — GHZ states have positive witness on all
  nontrivial bipartitions.
* `tropicalPartitionWitness_w_pos` — W states have positive witness on all
  nontrivial bipartitions.
* `genuineTropicalEntangled_ghz` — GHZ states are genuinely tropical entangled.

### Cross-domain bridge (support combinatorics)
* `crossSupportCount_pos_of_ghz` — GHZ support is non-rectangular across every cut.
* `tropicalPartitionWitness_pos_of_crossSupport` — Positive cross-support count
  with uniform nonzero amplitudes implies positive witness.

## Scientific Significance

These theorems establish the first rigorous connection between tropical coefficient
geometry and quantum entanglement detection. The key insight is that:

> **Factorization across a partition forces tropical witness collapse, while
> canonical genuinely entangled states force tropical witness positivity.**

This creates bridges between quantum information, tropical geometry, spectral theory,
and algebraic complexity.

### Falsifiable Conjecture (Tropical Genuine Entanglement Criterion)

For `n ≥ 3` and a pure state `ψ : (Fin n → Fin 2) → ℂ` with positive magnitude on
its support, if the tropical partition witness is positive on every nontrivial
bipartition, then `ψ` is genuinely multipartite entangled.

**Testable prediction**: For `n = 3, 4`, exhaustive scans over GHZ, W, product,
biseparable, and Dicke states should show: fully separable → zero witness on every cut;
GHZ and W → positive on every cut; biseparable → zero on at least one cut.
-/

open Finset BigOperators Complex

noncomputable section

namespace TropicalEntanglement

/-! ## §1. Nonnegativity -/

/-
The tropical partition witness is always nonnegative.
    This follows immediately from its definition as a sum of
    `max(·, 0)` terms.
-/
theorem tropicalPartitionWitness_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (d : Type*) [Fintype d]
    (A : Finset ι) (ψ : (ι → d) → ℂ) :
    0 ≤ tropicalPartitionWitness d A ψ := by
  exact Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => le_max_right _ _

/-! ## §2. Product State Vanishing -/

/-
Key algebraic lemma: for a product state, mixing configurations preserves
    the magnitude product. This is the heart of the soundness theorem.
-/
theorem product_magnitude_mix {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (φ χ : (ι → d) → ℂ)
    (hφ : ∀ s t, (∀ i ∈ A, s i = t i) → φ s = φ t)
    (hχ : ∀ s t, (∀ i, i ∉ A → s i = t i) → χ s = χ t)
    (s t : ι → d) :
    norm (φ s * χ s) * norm (φ t * χ t) =
    norm (φ (mixConfig A s t) * χ (mixConfig A s t)) *
    norm (φ (mixConfig A t s) * χ (mixConfig A t s)) := by
  -- Using the properties of φ and χ, we can simplify the expressions for φ(mixConfig A s t) and χ(mixConfig A s t).
  have hφ_simp : φ (mixConfig A s t) = φ s ∧ φ (mixConfig A t s) = φ t := by
    exact ⟨ hφ _ _ fun i hi => by unfold mixConfig; aesop, hφ _ _ fun i hi => by unfold mixConfig; aesop ⟩
  have hχ_simp : χ (mixConfig A s t) = χ t ∧ χ (mixConfig A t s) = χ s := by
    exact ⟨ hχ _ _ fun i hi => by unfold mixConfig; aesop, hχ _ _ fun i hi => by unfold mixConfig; aesop ⟩;
  simp +decide only [norm_mul, hφ_simp, hχ_simp] ; ring;

/-
**Theorem 1 (Soundness)**: If a state `ψ` factors as a product across
    partition `A`, then the tropical partition witness vanishes.

    This is the foundational theorem of tropical entanglement certificate theory.
    It shows that the witness is a genuine obstruction to partition-separability.

    **Proof sketch**: For a product state `ψ = φ_A ⊗ χ_{Aᶜ}`, the mixing operation
    preserves the magnitude factorization:
    `|ψ(s)| · |ψ(t)| = |φ(s)| · |χ(s)| · |φ(t)| · |χ(t)|
                      = |φ(s)| · |χ(t)| · |φ(t)| · |χ(s)|
                      = |ψ(mix(s,t))| · |ψ(mix(t,s))|`
    so each term in the sum vanishes.
-/
theorem tropicalPartitionWitness_eq_zero_of_isProductAcross
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} [Fintype d]
    (A : Finset ι)
    (ψ : (ι → d) → ℂ)
    (hprod : IsProductAcross A ψ) :
    tropicalPartitionWitness d A ψ = 0 := by
  obtain ⟨ φ, χ, h₁, h₂, h₃ ⟩ := hprod;
  have h_zero : ∀ s t : ι → d, norm (ψ s) * norm (ψ t) = norm (ψ (mixConfig A s t)) * norm (ψ (mixConfig A t s)) := by
    intro s t;
    convert product_magnitude_mix A φ χ h₂ h₃ s t using 1 <;> simp +decide [ h₁ ];
  exact Finset.sum_eq_zero fun s _ => Finset.sum_eq_zero fun t _ => max_eq_right ( sub_nonpos_of_le ( h_zero s t ▸ le_rfl ) )

/-
Product states constructed from local amplitudes are product across any partition.
-/
theorem productState_isProductAcross {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} (φ : ι → d → ℂ) (A : Finset ι) :
    IsProductAcross A (productState φ) := by
  refine' ⟨ fun s => ∏ i ∈ A, φ i ( s i ), fun s => ∏ i ∈ ( Finset.univ \ A ), φ i ( s i ), _, _, _ ⟩;
  · exact fun s => by rw [ ← Finset.prod_union Finset.disjoint_sdiff, Finset.union_sdiff_of_subset ( Finset.subset_univ _ ) ] ; rfl;
  · exact fun s t h => Finset.prod_congr rfl fun i hi => by rw [ h i hi ] ;
  · exact fun s t h => Finset.prod_congr rfl fun i hi => by aesop;

/-
Fully separable states are product across every partition.
-/
theorem fullySeparable_isProductAcross {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*}
    (ψ : (ι → d) → ℂ) (hsep : FullySeparable ψ) (A : Finset ι) :
    IsProductAcross A ψ := by
  convert TropicalEntanglement.productState_isProductAcross ( hsep.choose ) A using 1;
  exact funext fun s => hsep.choose_spec s

/-- **Theorem 4 (Fully Separable Vanishing)**: Fully separable states have
    zero tropical partition witness on every nontrivial bipartition.

    This iterates Theorem 1 over all cuts, providing the precise formalization
    of "separable states have no tropical entanglement signal." -/
theorem tropicalPartitionWitness_eq_zero_of_fullySeparable
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} [Fintype d]
    (ψ : (ι → d) → ℂ)
    (hsep : FullySeparable ψ)
    (A : Finset ι) (hA₁ : A.Nonempty) (hA₂ : A ≠ Finset.univ) :
    tropicalPartitionWitness d A ψ = 0 := by
  exact tropicalPartitionWitness_eq_zero_of_isProductAcross A ψ
    (fullySeparable_isProductAcross ψ hsep A)

/-! ## §3. GHZ State Positivity -/

/-
The GHZ state vanishes on mixed configurations that are neither all-zeros nor all-ones.
-/
theorem ghzState_mix_eq_zero {n : ℕ}
    (A : Finset (Fin n)) (hA₁ : A.Nonempty) (hA₂ : A ≠ Finset.univ) :
    ghzState n (mixConfig A (fun _ => 0) (fun _ => 1)) = 0 := by
  convert TropicalEntanglement.tropicalPartitionWitness_eq_zero_of_fullySeparable _ _ _ _;
  rotate_left;
  exact Fin 2;
  exact inferInstance;
  exact inferInstance;
  exact Fin 2;
  exact inferInstance;
  exact fun _ => 1;
  exact ⟨ fun _ => 1, fun _ => by norm_num ⟩;
  exact { 0 };
  · norm_num;
  · unfold ghzState mixConfig; simp +decide [ Finset.ext_iff ] ;
    unfold tropicalPartitionWitness; simp +decide [ Finset.sum_ite ] ;
    exact ⟨ not_forall.mp fun h => hA₂ <| Finset.eq_univ_of_forall h, hA₁ ⟩

/-- The GHZ state is nonzero on the all-zeros configuration. -/
theorem ghzState_allZeros (n : ℕ) :
    ghzState n (fun _ => 0) = 1 := by
  simp [ghzState]

/-- The GHZ state is nonzero on the all-ones configuration. -/
theorem ghzState_allOnes (n : ℕ) :
    ghzState n (fun _ => 1) = 1 := by
  simp [ghzState]

/-
**Theorem 3a (GHZ Positivity)**: The GHZ state has strictly positive
    tropical partition witness across every nontrivial bipartition.

    **Proof sketch**: Take `s = (0,...,0)` and `t = (1,...,1)`.
    Both have `|ψ_GHZ| = 1`. The mixed configuration `mixConfig A s t`
    takes 0 on `A` and 1 on `Aᶜ`, which is neither all-zeros nor all-ones
    when `A` is nontrivial. So `ψ_GHZ(mix) = 0`. The corresponding term
    contributes `max(1 · 1 - 0 · 0, 0) = 1 > 0` to the sum.
    Since all terms are nonneg, the total is `≥ 1 > 0`.
-/
theorem tropicalPartitionWitness_ghz_pos
    (n : ℕ) (hn : 3 ≤ n)
    (A : Finset (Fin n))
    (hA₁ : A.Nonempty) (hA₂ : A ≠ Finset.univ) :
    0 < tropicalPartitionWitness (Fin 2) A (ghzState n) := by
  refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun s _ => _ ) ( Finset.mem_univ ( fun _ => 0 ) ) );
  · refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun t _ => _ ) ( Finset.mem_univ ( fun _ => 1 ) ) ) <;> norm_num [ ghzState_allZeros, ghzState_allOnes, ghzState_mix_eq_zero, hA₁, hA₂ ];
  · exact Finset.sum_nonneg fun _ _ => le_max_right _ _

/-! ## §4. W State Positivity -/

/-
Helper: a unit vector `e_i` is in the support of the W state.
-/
theorem wState_unitVec {n : ℕ} (i : Fin n) :
    wState n (fun j => if j = i then 1 else 0) = 1 := by
  -- The set {j | s j = 1} is exactly {i}, which has cardinality 1.
  have h_filter : Finset.filter (fun j => (fun j => if j = i then 1 else 0) j = 1) Finset.univ = {i} := by
    grind;
  unfold wState; aesop

/-
Helper: the zero configuration is not in the support of the W state (for n ≥ 1).
-/
theorem wState_zero {n : ℕ} (hn : 1 ≤ n) :
    wState n (fun _ : Fin n => (0 : Fin 2)) = 0 := by
  -- By definition of wState, the zero configuration is not in the support.
  simp [wState]

/-
Helper: configurations with two or more 1s are not in W state support.
-/
theorem wState_two_ones_eq_zero {n : ℕ} (s : Fin n → Fin 2)
    (hs : 2 ≤ (Finset.univ.filter (fun i => s i = 1)).card) :
    wState n s = 0 := by
  exact if_neg ( by omega )

/-
**Theorem 3b (W-State Positivity)**: The W state has strictly positive
    tropical partition witness across every nontrivial bipartition.

    **Proof sketch**: Since `A` is nonempty and not `univ`, pick `i ∈ A`
    and `j ∉ A`. Let `s = e_i` and `t = e_j` (unit vectors with a single 1).
    Both are in the W state's support with `|ψ_W| = 1`.
    `mixConfig A s t` has 1s at both `i` and `j` (two 1s), so `ψ_W(mix) = 0`.
    `mixConfig A t s` has 0s everywhere (since `j ∉ A` gives 0 on `A`, and
    `i ∈ A` gives 0 on `Aᶜ`), so `ψ_W(mix) = 0`.
    The term contributes `max(1 - 0, 0) = 1 > 0`.
-/
theorem tropicalPartitionWitness_w_pos
    (n : ℕ) (hn : 3 ≤ n)
    (A : Finset (Fin n))
    (hA₁ : A.Nonempty) (hA₂ : A ≠ Finset.univ) :
    0 < tropicalPartitionWitness (Fin 2) A (wState n) := by
  -- Pick $i \in A$ and $j \notin A$.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, i ∈ A := by
    exact hA₁
  obtain ⟨j, hj⟩ : ∃ j : Fin n, j ∉ A := by
    exact not_forall.mp fun h => hA₂ <| Finset.eq_univ_of_forall h;
  refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => by positivity ) ( Finset.mem_univ ( fun k => if k = i then 1 else 0 ) ) );
  refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => by positivity ) ( Finset.mem_univ ( fun k => if k = j then 1 else 0 ) ) );
  simp +decide [ wState_unitVec, wState_zero, wState_two_ones_eq_zero, mixConfig ];
  unfold wState mixConfig; simp +decide [ hi, hj ] ;
  split_ifs <;> norm_num;
  rename_i h₁ h₂;
  contrapose! h₁;
  refine' ne_of_gt ( Finset.one_lt_card.mpr ⟨ i, _, j, _, _ ⟩ ) <;> aesop

/-! ## §5. Genuine Tropical Entanglement -/

/-- GHZ states are genuinely tropical entangled for n ≥ 3. -/
theorem genuineTropicalEntangled_ghz (n : ℕ) (hn : 3 ≤ n) :
    GenuineTropicalEntangled (Fin 2) (ghzState n) := by
  intro A hA₁ hA₂
  exact tropicalPartitionWitness_ghz_pos n hn A hA₁ hA₂

/-- W states are genuinely tropical entangled for n ≥ 3. -/
theorem genuineTropicalEntangled_w (n : ℕ) (hn : 3 ≤ n) :
    GenuineTropicalEntangled (Fin 2) (wState n) := by
  intro A hA₁ hA₂
  exact tropicalPartitionWitness_w_pos n hn A hA₁ hA₂

/-! ## §6. Cross-Domain Bridge: Support Combinatorics -/

/-
**Theorem 5 (Cross-Domain Bridge)**: If a state has positive cross-support count
    on a partition and all nonzero amplitudes have the same absolute value `c > 0`,
    then the tropical partition witness is positive.

    This connects quantum entanglement detection to sparse tensor support geometry
    and algebraic complexity. A positive cross-support count means the state's support
    is not a Cartesian product when projected onto `A` and `Aᶜ`, which is a fundamental
    obstruction to rank-1 tensor factorization.

    **Cross-domain significance**: This theorem bridges:
    - **Quantum information** ↔ **Combinatorics**: support non-rectangularity detects entanglement
    - **Quantum information** ↔ **Algebraic complexity**: tensor rank obstructions become witness positivity
    - **Tropical geometry** ↔ **Tensor theory**: max-plus support analysis certifies non-factorizability
-/
theorem tropicalPartitionWitness_pos_of_crossSupport
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} [Fintype d] [DecidableEq d]
    (A : Finset ι) (ψ : (ι → d) → ℂ)
    (c : ℝ) (hc : 0 < c)
    (hamp : ∀ s, ψ s ≠ 0 → norm (ψ s) = c)
    (hcross : 0 < crossSupportCount A ψ) :
    0 < tropicalPartitionWitness d A ψ := by
  -- By definition of crossSupportCount, there exists at least one pair (s, t) in the support of ψ such that ψ(mixConfig A s t) = 0 or ψ(mixConfig A t s) = 0.
  obtain ⟨p, hp⟩ : ∃ p : (ι → d) × (ι → d), p ∈ Finset.univ.filter (fun p : (ι → d) × (ι → d) => ψ p.1 ≠ 0 ∧ ψ p.2 ≠ 0 ∧ (ψ (mixConfig A p.1 p.2) = 0 ∨ ψ (mixConfig A p.2 p.1) = 0)) := by
    exact Finset.card_pos.mp hcross |> Exists.imp fun p hp => by simpa using hp;
  refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun s _ => Finset.sum_nonneg fun t _ => _ ) ( Finset.mem_univ p.1 ) |> le_trans ( Finset.single_le_sum ( fun t _ => _ ) ( Finset.mem_univ p.2 ) ) ) <;> simp_all +decide;
  cases hp.2.2 <;> simp_all +decide

/-
GHZ states have positive cross-support count on every nontrivial partition.
    This shows the GHZ support is genuinely non-rectangular.
-/
theorem crossSupportCount_pos_of_ghz
    (n : ℕ) (_hn : 3 ≤ n)
    (A : Finset (Fin n))
    (hA₁ : A.Nonempty) (hA₂ : A ≠ Finset.univ) :
    0 < crossSupportCount A (ghzState n) := by
  refine' Finset.card_pos.mpr ⟨ ( fun _ => 0, fun _ => 1 ), _ ⟩ ; simp_all +decide;
  exact ⟨ by rw [ ghzState_allZeros ] ; norm_num, by rw [ ghzState_allOnes ] ; norm_num, Or.inl <| ghzState_mix_eq_zero A hA₁ hA₂ ⟩

end TropicalEntanglement
end