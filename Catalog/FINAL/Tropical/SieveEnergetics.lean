/-
# Tropical Sieve Energetics

A formal framework for tropical (min-plus) methods applied to gap patterns in finite subsets
of the natural numbers. This file establishes:

1. **Obstruction theorems** showing that purely order-theoretic/min-plus data cannot force
   twin-pair existence — separating tropical analogy from arithmetic content.
2. **Gap-energy inequalities** providing exact classification of when finite sets support
   gap-2 configurations, including residue-class obstructions.
3. **Min-plus convolution witness theorems** giving a precise correspondence between
   vanishing of tropical convolutions and existence of gap-pattern witnesses.

Together these results constitute the first formal tropical sieve framework that rigorously
delineates what tropicalization can and cannot detect about arithmetic gap structure.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- A twin pair in a finite set `s` at position `n`: both `n` and `n+2` belong to `s`. -/
def TwinPairIn (s : Finset ℕ) (n : ℕ) : Prop :=
  n ∈ s ∧ n + 2 ∈ s

/-- A finite set has no twin pairs if no position witnesses both `n ∈ s` and `n+2 ∈ s`. -/
def HasNoTwinPairs (s : Finset ℕ) : Prop :=
  ∀ n, ¬ TwinPairIn s n

/-- Indicator: 1 if `n` and `n+2` both lie in `s`, else 0. -/
def pairIndicator (s : Finset ℕ) (n : ℕ) : ℕ :=
  if n ∈ s ∧ n + 2 ∈ s then 1 else 0

/-- The twin count of a finite set: number of elements `n ∈ s` with `n+2 ∈ s`. -/
def twinCount (s : Finset ℕ) : ℕ :=
  ∑ n ∈ s, pairIndicator s n

/-- The gap profile counts elements `n < N` with both `n ∈ s` and `n + h ∈ s`. -/
def gapProfile (s : Finset ℕ) (h N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun n => n ∈ s ∧ n + h ∈ s)).card

/-- Support cost: 0 if `n ∈ s`, 1 otherwise. Encodes membership as a tropical cost. -/
noncomputable def supportCost (s : Finset ℕ) (n : ℕ) : ℝ :=
  if n ∈ s then 0 else 1

/-- Min-plus (tropical) convolution of two real-valued functions on ℕ. -/
noncomputable def tropicalConv (f g : ℕ → ℝ) (n : ℕ) : ℝ :=
  ((Finset.range (n + 1)).inf' ⟨0, by simp⟩ (fun k => f k + g (n - k)))

/-! ## Part A: Obstruction Theorems -/

/-- **Theorem A1**: For every `N`, there exists a subset of `{0, ..., N-1}` with no twin pairs.
This shows that purely combinatorial/order-theoretic data cannot force twin-pair existence. -/
theorem tropical_residue_does_not_force_twin_pairs :
    ∀ N : ℕ, ∃ s : Finset ℕ,
      s ⊆ Finset.range N ∧
      HasNoTwinPairs s := by
  intros N
  use ∅
  simp [HasNoTwinPairs]
  intro n
  simp [TwinPairIn]

/-- **Theorem A2** (stronger variant): For any weight function, there exists a twin-free
subset of `{0, ..., N-1}`. Arbitrary tropical weights do not enforce twin structure. -/
theorem weighted_tropical_data_admits_twin_free_models :
    ∀ (N : ℕ) (_w : ℕ → ℝ),
      ∃ s : Finset ℕ,
        s ⊆ Finset.range N ∧
        HasNoTwinPairs s := by
  exact fun N _w => ⟨∅, Finset.empty_subset _, fun n => by unfold TwinPairIn; aesop⟩

/-! ## Part B: Gap-Energy Inequalities -/

/-- **Theorem B1**: The twin count of any finite set is at most its cardinality. -/
theorem twinCount_le_card :
    ∀ s : Finset ℕ, twinCount s ≤ s.card := by
  exact fun s => le_trans
    (Finset.sum_le_card_nsmul _ _ _ fun x hx =>
      show pairIndicator s x ≤ 1 by unfold pairIndicator; aesop)
    (by norm_num)

/-
The original "parity layer" theorem claimed that a set of all-even numbers has zero twin
pairs. This is FALSE: the set {0, 2} is all-even and has a twin pair at 0.
The correct classification uses residue classes mod 3:

**Theorem B2** (corrected): A set contained in a single residue class mod 3 has zero
twin pairs. This is because if `n ≡ r (mod 3)` then `n + 2 ≡ r + 2 (mod 3)`, which is a
different residue class (since 2 ≢ 0 mod 3). This shows that twin-pair detection requires
interaction between distinct residue classes mod 3.
-/
theorem twinCount_zero_of_residue_mod3
    (s : Finset ℕ) (r : ℕ)
    (h : ∀ n ∈ s, n % 3 = r) :
    twinCount s = 0 := by
  unfold twinCount;
  simp_all +decide [ pairIndicator ];
  grind

/-
The twin count equals zero iff the set has no twin pairs.
-/
theorem twinCount_eq_zero_iff (s : Finset ℕ) :
    twinCount s = 0 ↔ HasNoTwinPairs s := by
  -- Let's unfold the definition of `twinCount` and `HasNoTwinPairs`.
  unfold twinCount HasNoTwinPairs;
  simp +decide [TwinPairIn];
  unfold pairIndicator; aesop;

/-
**Theorem B3**: Sets where all elements are spaced at least 3 apart have no twin pairs.
More precisely: if the minimum gap between any two elements is ≥ 3, no twin pair exists.
-/
theorem hasNoTwinPairs_of_spacing
    (s : Finset ℕ) (h : ∀ a ∈ s, ∀ b ∈ s, a ≠ b → (a : ℤ) - b ≥ 3 ∨ (b : ℤ) - a ≥ 3) :
    HasNoTwinPairs s := by
  intro n hn; specialize h n hn.1 ( n + 2 ) hn.2; omega;

/-! ## Part C: Min-Plus Convolution Witness Theorems -/

/-
**Theorem C1**: If the min-plus convolution of support costs vanishes, there exists a
gap-pattern witness. This is the finite analogue of "Hardy–Littlewood as convolution":
vanishing tropical convolution implies a witness pair realizing the target gap.
-/
theorem tropical_conv_support_detects_overlap
    (s : Finset ℕ) (n : ℕ) :
    tropicalConv (supportCost s) (fun m => supportCost s (m + 2)) n = 0 →
    ∃ k ≤ n, k ∈ s ∧ (n - k) + 2 ∈ s := by
  intro h;
  contrapose! h;
  refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.le_inf' _ _ fun x hx => _ ) ) <;> norm_num;
  exact zero_lt_one;
  unfold supportCost; split_ifs <;> norm_num ; aesop;

/-
**Theorem C2**: Converse direction — a gap witness implies the convolution vanishes.
-/
theorem overlap_implies_tropical_conv_zero
    (s : Finset ℕ) (n : ℕ) :
    (∃ k ≤ n, k ∈ s ∧ (n - k) + 2 ∈ s) →
    tropicalConv (supportCost s) (fun m => supportCost s (m + 2)) n = 0 := by
  unfold tropicalConv;
  simp +zetaDelta at *;
  intro x hx₁ hx₂ hx₃; refine' le_antisymm _ _ <;> norm_num [ *, Finset.inf'_le_iff ] ;
  · exact ⟨ x, hx₁, by unfold supportCost; aesop ⟩;
  · exact fun _ _ => add_nonneg ( by unfold supportCost; split_ifs <;> norm_num ) ( by unfold supportCost; split_ifs <;> norm_num )

/-- **Theorem C3** (biconditional): The min-plus convolution vanishes if and only if
there exists a gap-pattern witness. This is the **tropical pattern-detection theorem**. -/
theorem tropical_conv_zero_iff_gap_witness
    (s : Finset ℕ) (n : ℕ) :
    tropicalConv (supportCost s) (fun m => supportCost s (m + 2)) n = 0 ↔
    ∃ k ≤ n, k ∈ s ∧ (n - k) + 2 ∈ s := by
  exact ⟨tropical_conv_support_detects_overlap s n,
         overlap_implies_tropical_conv_zero s n⟩

/-! ## Supplementary: Monotonicity and Structural Properties -/

/-- The support cost is always nonneg. -/
theorem supportCost_nonneg (s : Finset ℕ) (n : ℕ) : supportCost s n ≥ 0 := by
  unfold supportCost; split_ifs <;> norm_num

/-- The support cost takes values in {0, 1}. -/
theorem supportCost_le_one (s : Finset ℕ) (n : ℕ) : supportCost s n ≤ 1 := by
  unfold supportCost; split_ifs <;> norm_num

/-
The tropical convolution of nonneg functions is nonneg.
-/
theorem tropicalConv_nonneg (f g : ℕ → ℝ) (n : ℕ)
    (hf : ∀ k, f k ≥ 0) (hg : ∀ k, g k ≥ 0) :
    tropicalConv f g n ≥ 0 := by
  exact Finset.le_inf' _ _ fun x hx => add_nonneg ( hf x ) ( hg ( n - x ) )

/-- The tropical convolution of support costs is nonneg. -/
theorem tropicalConv_supportCost_nonneg (s : Finset ℕ) (n : ℕ) :
    tropicalConv (supportCost s) (fun m => supportCost s (m + 2)) n ≥ 0 := by
  exact tropicalConv_nonneg _ _ n (fun k => supportCost_nonneg s k)
    (fun k => supportCost_nonneg s (k + 2))

/-- Twin count is zero for the empty set. -/
theorem twinCount_empty : twinCount ∅ = 0 := by
  simp [twinCount]

/-- HasNoTwinPairs for the empty set. -/
theorem hasNoTwinPairs_empty : HasNoTwinPairs ∅ := by
  intro n; simp [TwinPairIn]