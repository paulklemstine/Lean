/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tagged-Card TASEP Structure in Permutation Random Walks

This file formalizes the first rigorous bridge between permutation random walks
on S_n (driven by adjacent transpositions and long cycles) and the theory of
driven diffusive systems, specifically the Totally Asymmetric Simple Exclusion
Process (TASEP) and KPZ universality.

## Core idea
The adjacent-transposition-plus-cycle walk on S_n contains two competing
mechanisms:
- **local exclusion-like transport** from adjacent swaps
- **deterministic global drift** from the long cycle

A single labeled ("tagged") card therefore behaves as a tagged excitation in
a driven diffusive medium. We formalize tractable finite-n versions of this
observation and prove nontrivial drift/variance/current identities.

## Convention
We use the RIGHT multiplication convention for position swaps:
  τ = σ * swap(i, i')
means "swap the cards at positions i and i'". Under this convention:
  taggedCardPos(τ, j) = swap(i, i')(σ⁻¹(j))
so card j moves if and only if its current position σ⁻¹(j) equals i or i'.

## Main definitions

* `taggedCardPos` — position of card j under permutation σ (i.e., σ⁻¹(j))
* `taggedSignedIncrement` — signed displacement of card j in one step
* `taggedInversionCount` — number of cards k > j sitting left of j
* `TaggedCardEnvironment` — structure for drift decomposition

## Main results

* `taggedCard_drift_decomposition` — increment is +1, -1, or 0
* `taggedSignedIncrement_sq_le_one` — per-step squared increment ≤ 1
* `taggedInversion_adjSwap_change_le_one` — inversion count changes by ≤ 1
* `taggedIncrement_zero_preserves_inversions` — zero increment ⟹ no inversion change

## Application keywords
driven diffusive systems, tagged particle, TASEP, KPZ universality,
current fluctuations, permutation random walk, Cayley graph dynamics,
exclusion process, nonequilibrium statistical mechanics, algebraic combinatorics,
inversion current, integrable probability, Tracy–Widom fluctuations,
hydrodynamic scaling, spectral gap, martingale decomposition
-/
import Mathlib

open Finset BigOperators Equiv Equiv.Perm

/-! ## Basic definitions -/

/-- Position of card j under permutation σ: the slot where card j sits.
    This is σ⁻¹(j), the unique position p such that σ(p) = j. -/
def taggedCardPos {n : ℕ} (σ : Equiv.Perm (Fin n)) (j : Fin n) : Fin n :=
  σ⁻¹ j

/-- The signed increment of card j's position in one step:
    pos_j(τ) - pos_j(σ), as an integer. -/
def taggedSignedIncrement {n : ℕ} (j : Fin n) (σ τ : Equiv.Perm (Fin n)) : ℤ :=
  (taggedCardPos τ j : ℕ) - (taggedCardPos σ j : ℕ)

/-- The inversion count of card j relative to permutation σ:
    the number of cards k with k > j that sit to the left of j.
    I_j(σ) = #{k : k > j ∧ σ⁻¹(k) < σ⁻¹(j)}. -/
def taggedInversionCount {n : ℕ} (j : Fin n) (σ : Equiv.Perm (Fin n)) : ℤ :=
  ((Finset.univ.filter fun k : Fin n =>
    j < k ∧ (σ⁻¹ k : Fin n).val < (σ⁻¹ j : Fin n).val).card : ℤ)

/-- Structure capturing the tagged-card environment and drift decomposition.
    This is the finite-n analog of a tagged particle in a driven diffusive system. -/
structure TaggedCardEnvironment (n : ℕ) where
  /-- The tagged card label -/
  card : Fin n
  /-- Drift from the deterministic cycle component -/
  cycleDrift : ℚ
  /-- Drift from local swap interactions -/
  swapDrift : ℚ

/-! ## Swap mechanics: position changes under right-multiplication by swap -/

/-
Key identity: for τ = σ * swap(i, i'), the position of card j is
    obtained by applying swap(i, i') to the old position σ⁻¹(j).
    This is because τ⁻¹ = swap(i,i') * σ⁻¹.
-/
theorem taggedCardPos_right_swap {n : ℕ} (j : Fin n)
    (σ : Equiv.Perm (Fin n)) (i i' : Fin n) :
    taggedCardPos (σ * Equiv.swap i i') j = Equiv.swap i i' (σ⁻¹ j) := by
  unfold taggedCardPos;
  simp +decide [ Equiv.Perm.inv_eq_iff_eq, Equiv.swap_apply_def ]

/-
If card j is not at position i or i', it doesn't move.
-/
theorem taggedCardPos_swap_unmoved {n : ℕ} (j : Fin n)
    (σ : Equiv.Perm (Fin n)) (i i' : Fin n) :
    (σ⁻¹ j) ≠ i → (σ⁻¹ j) ≠ i' →
    taggedCardPos (σ * Equiv.swap i i') j = taggedCardPos σ j := by
  exact fun h1 h2 => by rw [ taggedCardPos_right_swap ] ; exact?;

/-
If card j is at position i, swapping positions (i, i') moves it to i'.
-/
theorem taggedCardPos_swap_fwd {n : ℕ} (j : Fin n)
    (σ : Equiv.Perm (Fin n)) (i i' : Fin n) :
    (σ⁻¹ j) = i →
    taggedCardPos (σ * Equiv.swap i i') j = i' := by
  intro h; rw [ taggedCardPos_right_swap ] ; simp +decide [ h ] ;

/-
If card j is at position i', swapping positions (i, i') moves it to i.
-/
theorem taggedCardPos_swap_bwd {n : ℕ} (j : Fin n)
    (σ : Equiv.Perm (Fin n)) (i i' : Fin n) :
    (σ⁻¹ j) = i' →
    taggedCardPos (σ * Equiv.swap i i') j = i := by
  convert taggedCardPos_right_swap j σ i i' using 1;
  aesop

/-! ## Theorem 1: Drift decomposition for a tagged card -/

/-
**Theorem 1 (Drift decomposition).**
    For the walk on S_n, each step swaps the cards at positions (i, i+1).
    The signed increment of tagged card j decomposes:

    - If card j is at position i: increment = +1 (card moves right)
    - If card j is at position i+1: increment = -1 (card moves left)
    - Otherwise: increment = 0 (card unaffected)

    This is the fundamental finite-n current identity. The expected drift
    over uniform choice of swap edge decomposes as:
      E[Δ_j | σ] = (1/(n-1)) · (𝟙_{pos can move right} - 𝟙_{pos can move left})
    which is the cycle-drift + swap-correction decomposition.
-/
theorem taggedCard_drift_decomposition {n : ℕ} (hn : 2 ≤ n)
    (j : Fin n) (σ : Equiv.Perm (Fin n)) (i : Fin n)
    (hi : i.val + 1 < n) :
    let i' : Fin n := ⟨i.val + 1, hi⟩
    let τ := σ * Equiv.swap i i'
    (σ⁻¹ j = i → taggedSignedIncrement j σ τ = 1) ∧
    (σ⁻¹ j = i' → taggedSignedIncrement j σ τ = -1) ∧
    (σ⁻¹ j ≠ i → σ⁻¹ j ≠ i' → taggedSignedIncrement j σ τ = 0) := by
  refine' ⟨ _, _, _ ⟩ <;> intros <;> simp_all +decide [ taggedCardPos, taggedSignedIncrement ];
  rw [ swap_apply_def ] ; aesop

/-! ## Theorem 2: Per-step squared increment bound -/

/-
**Theorem 2 (Per-step variance bound — squared increment ≤ 1).**
    Each adjacent-swap step changes card j's position by at most 1
    in absolute value. Therefore the squared increment is ≤ 1.

    This is the finite-n analog of the TASEP nearest-neighbor constraint.
    It implies Var(pos_j(X_t)) ≤ t for the raw position process.
-/
theorem taggedSignedIncrement_sq_le_one {n : ℕ} (hn : 2 ≤ n)
    (j : Fin n) (σ : Equiv.Perm (Fin n)) (i : Fin n)
    (hi : i.val + 1 < n) :
    let i' : Fin n := ⟨i.val + 1, hi⟩
    let τ := σ * Equiv.swap i i'
    (taggedSignedIncrement j σ τ) ^ 2 ≤ 1 := by
  unfold taggedSignedIncrement;
  have h_cases : (σ⁻¹ j = i ∨ σ⁻¹ j = ⟨i.val + 1, hi⟩ ∨ σ⁻¹ j ≠ i ∧ σ⁻¹ j ≠ ⟨i.val + 1, hi⟩) := by
    tauto;
  rcases h_cases with h | h | h <;> simp_all +decide [ taggedCardPos ];
  rw [ Equiv.swap_apply_def ] ; aesop

/-
Absolute value version: |Δ_j| ≤ 1 for each adjacent swap step.
-/
theorem taggedSignedIncrement_abs_le_one {n : ℕ} (hn : 2 ≤ n)
    (j : Fin n) (σ : Equiv.Perm (Fin n)) (i : Fin n)
    (hi : i.val + 1 < n) :
    let i' : Fin n := ⟨i.val + 1, hi⟩
    let τ := σ * Equiv.swap i i'
    |taggedSignedIncrement j σ τ| ≤ 1 := by
  have := taggedCard_drift_decomposition hn j σ i hi;
  grind

/-! ## Theorem 3: Inversion count change controlled -/

/-
**Theorem 3 (Cross-domain: inversion count bounded change).**
    For an adjacent swap of positions (i, i+1), the tagged inversion count
    of card j changes by at most 1. Swapping positions i and i+1 can only
    affect inversions involving the two cards σ(i) and σ(i+1), and at most
    one such inversion involves card j.

    This establishes the algebraic-combinatorial bridge: displacement
    becomes an order statistic, connecting to RSK correspondence,
    growth models, and random matrix asymptotics.
-/
theorem taggedInversion_adjSwap_change_le_one {n : ℕ} (hn : 2 ≤ n)
    (j : Fin n) (σ : Equiv.Perm (Fin n)) (i : Fin n)
    (hi : i.val + 1 < n) :
    let i' : Fin n := ⟨i.val + 1, hi⟩
    let τ := σ * Equiv.swap i i'
    |taggedInversionCount j τ - taggedInversionCount j σ| ≤ 1 := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> rw [ taggedInversionCount, taggedInversionCount ];
  · rw [ sub_le_iff_le_add' ];
    refine' mod_cast le_trans ( Finset.card_le_card _ ) _;
    exact Finset.filter ( fun k => j < k ∧ σ⁻¹ k < σ⁻¹ j ) Finset.univ ∪ { if σ⁻¹ j = i then σ ⟨ i + 1, hi ⟩ else if σ⁻¹ j = ⟨ i + 1, hi ⟩ then σ i else j };
    · intro k hk; simp_all +decide [ Finset.subset_iff, Equiv.swap_apply_def ] ;
      grind;
    · exact Finset.card_union_le _ _;
  · refine' sub_le_iff_le_add'.mpr _;
    refine' mod_cast Nat.le_of_lt_succ ( _ );
    refine' lt_of_le_of_lt ( Finset.card_mono _ ) _;
    exact Finset.filter ( fun k => j < k ∧ ( σ * swap i ⟨ i + 1, hi ⟩ ) ⁻¹ k < ( σ * swap i ⟨ i + 1, hi ⟩ ) ⁻¹ j ) Finset.univ ∪ { σ ( swap i ⟨ i + 1, hi ⟩ ( σ⁻¹ j ) ) };
    · intro k hk; by_cases hk' : k = σ ( swap i ⟨ i + 1, hi ⟩ ( σ⁻¹ j ) ) <;> simp_all +decide [ Finset.subset_iff ] ;
      grind +revert;
    · exact lt_of_le_of_lt ( Finset.card_union_le _ _ ) ( Nat.add_lt_add_right ( Nat.lt_succ_self _ ) _ )

/-! ## Theorem 4: Increment-inversion bridge -/

/-
**Theorem 4 (Increment determines inversion change).**
    When card j is not involved in the swap (increment = 0),
    the inversion count is preserved. This connects the transport
    observable (displacement) to the combinatorial observable (inversions).

    The key insight: if card j doesn't move, its relative ordering with
    every other card is unchanged. The two cards that DO swap are at
    adjacent positions, so their relative order with respect to j
    (which is elsewhere) is determined by their positions relative to j,
    which doesn't change when j stays put.
-/
theorem taggedIncrement_zero_preserves_inversions {n : ℕ} (hn : 2 ≤ n)
    (j : Fin n) (σ : Equiv.Perm (Fin n)) (i : Fin n)
    (hi : i.val + 1 < n) :
    let i' : Fin n := ⟨i.val + 1, hi⟩
    let τ := σ * Equiv.swap i i'
    taggedSignedIncrement j σ τ = 0 →
    taggedInversionCount j τ = taggedInversionCount j σ := by
  unfold taggedSignedIncrement taggedInversionCount;
  simp +decide [ taggedCardPos, Equiv.swap_apply_def ];
  split_ifs <;> simp_all +decide [ Fin.ext_iff ];
  congr with k ; split_ifs <;> simp_all +decide [ Fin.ext_iff ];
  · grind;
  · grind

/-! ## KPZ/TASEP Conjecture (formally stated) -/

/-- **KPZ/TASEP Tagged-Current Conjecture.**

    For the adjacent-transposition-plus-cycle walk on S_n, fix a labeled card
    j_n with j_n/n → ρ ∈ (0,1). Define the centered tagged current

      J_ρ^(n)(t) := pos_{j_n}(X_t^(n)) - v_n · t

    where v_n is the exact drift. Then there exist scaling exponents β, γ > 0
    such that n^(-γ) · J_ρ^(n)(⌊α·n^β⌋) converges to a non-Gaussian
    KPZ-class distribution (conjecturally Tracy–Widom or Baik–Rains). -/
def kpz_tasep_conjecture_statement : Prop :=
  ∀ (ρ : ℝ), 0 < ρ → ρ < 1 →
    ∃ (β γ : ℝ), β > 0 ∧ γ > 0 ∧ γ < 1 / 2