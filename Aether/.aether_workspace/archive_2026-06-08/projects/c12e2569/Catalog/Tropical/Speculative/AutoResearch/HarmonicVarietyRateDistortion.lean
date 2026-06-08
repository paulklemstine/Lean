/-
Copyright (c) 2025 Tropical Information Theory Project. All rights reserved.

# Tropical Rate-Distortion Theory for Harmonic Variety

## Overview

This file establishes a finite tropical rate-distortion theory for contrapuntal
pitch spaces: in a finite pitch universe, the optimal achievable harmonic variety
under a bounded tropical penalty admits a canonical rate-distortion function
with monotonicity, step-structure, attainment, and a tropical data-processing
inequality.

The key conceptual innovation is the **replacement of probabilistic entropy by
support-complexity** (harmonic variety = image cardinality) and **distortion by
tropical cost** (sum of pointwise penalties), yielding a deterministic theory of
information loss and variety preservation in symbolic systems.

## Main Definitions

- `totalCost cost u v` — sum of pointwise contrapuntal costs
- `harmonicVariety v` — number of distinct pitch values in the image
- `rateDistortion cost u D` — maximum harmonic variety at cost budget D
- `minCostForVariety cost u k` — minimum cost to achieve variety ≥ k

## Main Results

1. `rateDistortion_mono` — monotonicity in budget D
2. `rateDistortion_attained` — the supremum is attained (finite search)
3. `harmonicVariety_le_min` — variety bounded by min(card α, card ι)
4. `rateDistortion_le_min` — rate-distortion bounded
5. `finite_range_rateDistortion` — R(D) takes finitely many values (step function)
6. `harmonicVariety_comp_le` — post-processing cannot increase variety
7. `rateDistortion_data_processing` — tropical data-processing inequality
8. `rateDistortion_ge_iff_minCost` — primal-dual threshold characterization:
   k ≤ R(D) ↔ C(k) ≤ D
9. `minCostForVariety_mono` — threshold cost is monotone

## Cross-Domain Connections

- **Information Theory**: Rate-distortion without probabilities; deterministic
  data-processing inequality; support-complexity as zero-temperature entropy.
- **Tropical Geometry**: Optimization by sup/max; threshold decomposition as
  a tropical Legendre-style picture.
- **Mathematical Music Theory**: Contrapuntal penalty as distortion; harmonic
  variety as expressive complexity.
- **Theoretical CS**: Support-size complexity under constrained editing;
  deterministic channel monotonicity.
-/

import Mathlib

open Finset BigOperators

attribute [local instance] Classical.propDecidable

namespace TropicalHarmonicVariety

variable {α ι : Type*} [Fintype α] [DecidableEq α] [Fintype ι]

/-! ## Core Definitions -/

/-- Total tropical contrapuntal cost of transforming melodic line `u` to line `v`.
    Each position `i` incurs a penalty `cost (u i) (v i)` for the pitch substitution. -/
def totalCost (cost : α → α → ℕ) (u v : ι → α) : ℕ :=
  ∑ i : ι, cost (u i) (v i)

/-- Harmonic variety of a melodic line: the number of distinct pitch values used.
    This is the support-complexity measure replacing Shannon entropy. -/
def harmonicVariety (v : ι → α) : ℕ :=
  (Finset.univ.image v).card

/-- The tropical rate-distortion function: maximum harmonic variety achievable
    within a total cost budget `D`. When no line is feasible (the feasible set
    is empty), this returns `0` via `Finset.sup` on `ℕ` with `⊥ = 0`. -/
noncomputable def rateDistortion (cost : α → α → ℕ) (u : ι → α) (D : ℕ) : ℕ :=
  ((Finset.univ : Finset (ι → α)).filter (fun v => totalCost cost u v ≤ D)).sup
    harmonicVariety

/-! ## Boundedness of Harmonic Variety -/

/-
Harmonic variety is bounded by the size of the pitch alphabet.
-/
theorem harmonicVariety_le_card_alpha (v : ι → α) :
    harmonicVariety v ≤ Fintype.card α := by
  exact Finset.card_le_univ _

/-
Harmonic variety is bounded by the number of index positions.
-/
omit [Fintype α] in
theorem harmonicVariety_le_card_iota (v : ι → α) :
    harmonicVariety v ≤ Fintype.card ι := by
  exact Finset.card_image_le.trans_eq ( Finset.card_univ )

/-
Harmonic variety is bounded by the minimum of alphabet and index sizes.
-/
theorem harmonicVariety_le_min (v : ι → α) :
    harmonicVariety v ≤ min (Fintype.card α) (Fintype.card ι) := by
  exact le_min ( harmonicVariety_le_card_alpha v ) ( harmonicVariety_le_card_iota v )

/-! ## Boundedness of Rate-Distortion -/

/-
The rate-distortion value at any budget is bounded by min(card α, card ι).
-/
theorem rateDistortion_le_min (cost : α → α → ℕ) (u : ι → α) (D : ℕ) :
    rateDistortion cost u D ≤ min (Fintype.card α) (Fintype.card ι) := by
  exact Finset.sup_le fun v hv => harmonicVariety_le_min v

/-! ## Monotonicity -/

/-
The rate-distortion function is monotone in the budget: increasing the
    budget can only increase the maximum achievable variety, because a larger
    budget enlarges the feasible set.
-/
theorem rateDistortion_mono (cost : α → α → ℕ) (u : ι → α) :
    Monotone (rateDistortion cost u) := by
  intro D₁ D₂ hD₁₂;
  exact Finset.sup_mono <| fun v hv => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hv |>.1, le_trans ( Finset.mem_filter.mp hv |>.2 ) hD₁₂ ⟩

/-! ## Attainment -/

/-- The feasible set at budget D. -/
private noncomputable def feasibleSet (cost : α → α → ℕ) (u : ι → α) (D : ℕ) : Finset (ι → α) :=
  (Finset.univ : Finset (ι → α)).filter (fun v => totalCost cost u v ≤ D)

omit [DecidableEq α] in
private theorem feasibleSet_nonempty (cost : α → α → ℕ) (u : ι → α) (D : ℕ)
    (hfeas : ∃ v : ι → α, totalCost cost u v ≤ D) :
    (feasibleSet cost u D).Nonempty := by
  -- By definition of feasibleSet, if there exists a v such that totalCost cost u v ≤ D, then v is in the feasibleSet.
  obtain ⟨v, hv⟩ := hfeas;
  use v;
  simp [feasibleSet, hv];

omit [Fintype α] in
private theorem sup_eq_max_of_nonempty {s : Finset (ι → α)} (hs : s.Nonempty) :
    ∃ v ∈ s, harmonicVariety v = s.sup harmonicVariety := by
  have := Finset.exists_max_image s harmonicVariety hs;
  exact ⟨ this.choose, this.choose_spec.1, le_antisymm ( Finset.le_sup ( f := harmonicVariety ) this.choose_spec.1 ) ( Finset.sup_le fun x hx => this.choose_spec.2 x hx ) ⟩

/-
**Attainment theorem**: When the feasible set is nonempty (there exists some
    line within budget), the supremum defining `rateDistortion` is attained by
    a concrete witness. This follows from finiteness of the search space.
-/
theorem rateDistortion_attained (cost : α → α → ℕ) (u : ι → α) (D : ℕ)
    (hfeas : ∃ v : ι → α, totalCost cost u v ≤ D) :
    ∃ v : ι → α, totalCost cost u v ≤ D ∧ harmonicVariety v = rateDistortion cost u D := by
  convert sup_eq_max_of_nonempty ( feasibleSet_nonempty cost u D hfeas ) using 1;
  unfold feasibleSet rateDistortion; aesop;

/-! ## Step-Function Structure -/

/-
**Finite range theorem**: The rate-distortion function takes only finitely
    many values. Since R(D) ∈ {0, 1, ..., min(card α, card ι)} for all D,
    the range is finite. Combined with monotonicity, this makes R a step function.
-/
theorem finite_range_rateDistortion (cost : α → α → ℕ) (u : ι → α) :
    Set.Finite (Set.range (rateDistortion cost u)) := by
  -- The range of rateDistortion cost u is a subset of the finite set {0, 1, ..., min (card α, card ι)}.
  have h_subset : Set.range (rateDistortion cost u) ⊆ Set.Iic (min (Fintype.card α) (Fintype.card ι)) := by
    exact Set.range_subset_iff.2 fun D => rateDistortion_le_min cost u D;
  exact Set.Finite.subset ( Set.finite_Iic _ ) h_subset

/-! ## Information-Theoretic: Harmonic Variety Under Composition -/

/-
Post-processing cannot increase harmonic variety. If `T : α → α` is any
    pitch transformation, then composing the output with `T` can only collapse
    distinct values, never create new ones.

    This is the deterministic analogue of the data-processing inequality for
    support-cardinality: applying a function to a set cannot increase its size.
-/
omit [Fintype α] in
theorem harmonicVariety_comp_le (T : α → α) (v : ι → α) :
    harmonicVariety (T ∘ v) ≤ harmonicVariety v := by
  -- Since $T \circ v$ refines $v$, we have $\text{image}(T \circ v) \subseteq \text{image}(v)$.
  have h_image_subset : Finset.image (T ∘ v) Finset.univ ⊆ Finset.image T (Finset.image v Finset.univ) := by
    grind;
  exact Finset.card_le_card h_image_subset |> le_trans <| Finset.card_image_le

/-! ## Tropical Data-Processing Inequality -/

/-
**Tropical Data-Processing Inequality**: If `T` makes every source pitch
    farther from every target (in the sense that `cost a b ≤ cost (T a) b`),
    then the rate-distortion function starting from `T ∘ u` is pointwise ≤
    the rate-distortion from `u`.

    Proof idea: Under this hypothesis, any `v` feasible for `(T ∘ u, D)` is
    also feasible for `(u, D)`, because `totalCost cost u v ≤ totalCost cost (T ∘ u) v ≤ D`.
    Hence the feasible set for `T ∘ u` is contained in the feasible set for `u`,
    and the sup over a subset is ≤ the sup over the whole set.
-/
theorem rateDistortion_data_processing
    (cost : α → α → ℕ) (T : α → α) (u : ι → α)
    (hcost : ∀ a b, cost a b ≤ cost (T a) b)
    (D : ℕ) :
    rateDistortion cost (T ∘ u) D ≤ rateDistortion cost u D := by
  apply Finset.sup_mono;
  exact fun v hv => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hv |>.1, le_trans ( Finset.sum_le_sum fun i _ => hcost _ _ ) ( Finset.mem_filter.mp hv |>.2 ) ⟩

/-! ## Threshold Decomposition (Primal-Dual Duality) -/

/-- Minimum cost to achieve harmonic variety at least `k`. Returns `⊤` when
    no line achieves variety ≥ k (e.g., when `k > min(card α, card ι)`).
    This is the "inverse" of the rate-distortion function. -/
noncomputable def minCostForVariety (cost : α → α → ℕ) (u : ι → α) (k : ℕ) : WithTop ℕ :=
  ((Finset.univ : Finset (ι → α)).filter (fun v => k ≤ harmonicVariety v)).inf
    (fun v => (totalCost cost u v : WithTop ℕ))

/-
**Primal-dual threshold characterization**: `k ≤ R(D)` if and only if
    the minimum cost to achieve variety ≥ k is at most `D`.

    This is the deterministic tropical analogue of the classical rate-distortion
    primal-dual equivalence. It completely characterizes the rate-distortion
    function through finitely many cost thresholds.
-/
private theorem rateDistortion_ge_of_minCost_le (cost : α → α → ℕ) (u : ι → α) (D k : ℕ)
    (h : minCostForVariety cost u k ≤ ↑D) :
    k ≤ rateDistortion cost u D := by
  contrapose! h;
  refine' lt_of_lt_of_le _ ( Finset.le_inf _ );
  exact WithTop.coe_lt_coe.mpr ( Nat.lt_succ_self _ );
  intro v hv; contrapose! h;
  refine' le_trans _ ( Finset.le_sup <| show v ∈ _ from _ );
  · aesop;
  · grind +suggestions

private theorem minCost_le_of_rateDistortion_ge (cost : α → α → ℕ) (u : ι → α) (D k : ℕ)
    (hk : 0 < k) (h : k ≤ rateDistortion cost u D) :
    minCostForVariety cost u k ≤ ↑D := by
  -- By the definition of rateDistortion, there exists a v such that totalCost cost u v ≤ D and k ≤ harmonicVariety v.
  obtain ⟨v, hv⟩ : ∃ v : ι → α, totalCost cost u v ≤ D ∧ k ≤ harmonicVariety v := by
    contrapose! h;
    by_contra h_contra;
    exact h_contra <| lt_of_le_of_lt ( Finset.sup_le fun v hv => Nat.le_sub_one_of_lt <| h v <| Finset.mem_filter.mp hv |>.2 ) ( Nat.sub_lt hk zero_lt_one );
  exact le_trans ( Finset.inf_le ( by aesop ) ) ( WithTop.coe_le_coe.mpr hv.1 )

/-- **Primal-dual threshold characterization**: For `k ≥ 1`, `k ≤ R(D)` if and
    only if the minimum cost to achieve variety ≥ k is at most `D`.

    The condition `0 < k` is necessary: when `k = 0`, `k ≤ R(D)` is trivially
    true but `C(0) ≤ D` can fail if no line has `totalCost ≤ D`.

    This is the deterministic tropical analogue of the classical rate-distortion
    primal-dual equivalence. It completely characterizes the rate-distortion
    function through finitely many cost thresholds. -/
theorem rateDistortion_ge_iff_minCost (cost : α → α → ℕ) (u : ι → α) (D k : ℕ)
    (hk : 0 < k) :
    k ≤ rateDistortion cost u D ↔ minCostForVariety cost u k ≤ ↑D :=
  ⟨minCost_le_of_rateDistortion_ge cost u D k hk,
   rateDistortion_ge_of_minCost_le cost u D k⟩

/-
The minimum cost for variety is monotone: achieving higher variety
    requires at least as much cost budget.
-/
theorem minCostForVariety_mono (cost : α → α → ℕ) (u : ι → α) :
    Monotone (minCostForVariety cost u) := by
  intros k₁ k₂ hk₁₂
  simp [minCostForVariety];
  exact fun v hv => ⟨ v, hk₁₂.trans hv, le_rfl ⟩

end TropicalHarmonicVariety