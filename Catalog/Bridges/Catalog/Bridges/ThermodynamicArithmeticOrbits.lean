/-
# Thermodynamic Formalism for Arithmetic Orbits

This file establishes a rigorous bridge between discounted arithmetic-orbit
value functions and thermodynamic partition-function formalism. The central
result is an exact decomposition of the "free energy" of an arithmetic
system as a generating function of stopping-time tail masses, together
with comparison theorems that relate the divergence rate of this free
energy as γ → 1⁻ to tail-exponent statistics of the stopping time.

## Main results

* `discounted_cost_eq_geometric_sum` — geometric-sum identity for discounted orbit cost
* `freeEnergyTrunc_eq_tail_sum` — exact decomposition of truncated free energy
* `freeEnergyTrunc_nonneg` — positivity under nonneg weights
* `tailMassTrunc_antitone` — tail masses are nonincreasing
* `freeEnergyTrunc_upper_bound_of_tail_upper` — upper comparison from tail bounds
* `freeEnergyTrunc_lower_bound_of_tail_lower` — lower comparison from tail bounds
* `freeEnergyTrunc_sandwich` — two-sided sandwich theorem
-/

import Mathlib

open Finset BigOperators

noncomputable section

-- The discounted cost of orbit n: sum of γᵏ for k < τ(n).
def discountedCost (τ : ℕ → ℕ) (γ : ℝ) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range (τ n), γ ^ k

-- Truncated free energy: weighted sum of discounted costs over {1, ..., N}.
def freeEnergyTrunc (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (γ : ℝ) : ℝ :=
  ∑ n ∈ Finset.Icc 1 N, w n * discountedCost τ γ n

-- Tail mass at level m: total weight of n ∈ {1,...,N} with τ(n) > m.
def tailMassTrunc (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (m : ℕ) : ℝ :=
  ∑ n ∈ (Finset.Icc 1 N).filter (fun n => m < τ n), w n

-- The reference partition function: Σ_{m<M} γᵐ (m+1)⁻ᵝ.
def polylogPartition (γ β : ℝ) (M : ℕ) : ℝ :=
  ∑ m ∈ Finset.range M, γ ^ m / (↑m + 1) ^ β

/-
════════════════════════════════════════════════════════════════════════
§ Geometric sum identity
════════════════════════════════════════════════════════════════════════

The discounted cost equals the closed-form geometric sum (1 - γ^τ)/(1 - γ).
-/
theorem discounted_cost_eq_geometric_sum
    (τ : ℕ → ℕ) (γ : ℝ) (hγ1 : γ ≠ 1) (n : ℕ) :
    discountedCost τ γ n = (1 - γ ^ (τ n)) / (1 - γ) := by
  -- By definition of `discountedCost`, we can write it as $\sum_{k=0}^{\tau(n)-1} \gamma^k$.
  simp [discountedCost];
  rw [ ← neg_div_neg_eq, geom_sum_eq ] <;> aesop

/-
════════════════════════════════════════════════════════════════════════
§ Exact decomposition: free energy = generating function of tails
════════════════════════════════════════════════════════════════════════

**Main decomposition theorem** (bounded-support variant).
When all stopping times satisfy τ(n) ≤ M for n ∈ {1,...,N}, the free energy
decomposes exactly as Σ_{m<M} γᵐ · tailMassTrunc(m).
-/
theorem freeEnergyTrunc_eq_tail_sum
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N M : ℕ) (γ : ℝ)
    (hM : ∀ n ∈ Finset.Icc 1 N, τ n ≤ M) :
    freeEnergyTrunc τ w N γ
      = ∑ m ∈ Finset.range M, γ ^ m * tailMassTrunc τ w N m := by
  unfold freeEnergyTrunc tailMassTrunc;
  simp +decide only [discountedCost, sum_filter];
  simp +decide only [Finset.mul_sum _ _ _];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ];
  intro n hn; rw [ ← Finset.sum_subset ( Finset.range_mono ( hM n hn ) ) ] <;> simp +contextual [ mul_comm ] ;
  exact Finset.sum_congr rfl fun x hx => by rw [ if_pos ( Finset.mem_range.mp hx ) ] ;

/-
════════════════════════════════════════════════════════════════════════
§ Positivity and monotonicity
════════════════════════════════════════════════════════════════════════

Free energy is nonneg when weights and γ are nonneg.
-/
theorem freeEnergyTrunc_nonneg
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (γ : ℝ)
    (hγ : 0 ≤ γ) (hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n) :
    0 ≤ freeEnergyTrunc τ w N γ := by
  exact Finset.sum_nonneg fun n hn => mul_nonneg ( hw n hn ) ( Finset.sum_nonneg fun _ _ => pow_nonneg hγ _ )

/-
Tail masses are nonneg when weights are nonneg.
-/
theorem tailMassTrunc_nonneg
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (m : ℕ)
    (hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n) :
    0 ≤ tailMassTrunc τ w N m := by
  exact Finset.sum_nonneg fun n hn => hw n <| Finset.mem_filter.mp hn |>.1

/-
Tail masses are nonincreasing: if m₁ ≤ m₂ then tail(m₂) ≤ tail(m₁).
-/
theorem tailMassTrunc_antitone
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ)
    (hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n) :
    Antitone (tailMassTrunc τ w N) := by
  refine' fun m₁ m₂ h => Finset.sum_le_sum_of_subset_of_nonneg _ _;
  · exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, lt_of_le_of_lt h ( Finset.mem_filter.mp hx |>.2 ) ⟩;
  · aesop

/-
════════════════════════════════════════════════════════════════════════
§ Comparison bounds
════════════════════════════════════════════════════════════════════════

**Upper comparison**: if tail masses are bounded above by B·(m+1)⁻ᵝ,
then the free energy is bounded above by B times the polylog partition function.
-/
theorem freeEnergyTrunc_upper_bound_of_tail_upper
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N M : ℕ) (γ B β : ℝ)
    (hγ0 : 0 ≤ γ) (_hγ1 : γ < 1) (_hB : 0 ≤ B)
    (hM : ∀ n ∈ Finset.Icc 1 N, τ n ≤ M)
    (_hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n)
    (htail : ∀ m : ℕ, tailMassTrunc τ w N m ≤ B * (1 / (↑m + 1) ^ β)) :
    freeEnergyTrunc τ w N γ ≤ B * polylogPartition γ β M := by
  convert Finset.sum_le_sum fun m hm => mul_le_mul_of_nonneg_left ( htail m ) ( pow_nonneg hγ0 m ) using 1;
  convert freeEnergyTrunc_eq_tail_sum τ w N M γ hM using 1;
  unfold polylogPartition; simp +decide [ div_eq_mul_inv, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-
**Lower comparison**: if tail masses are bounded below by A·(m+1)⁻ᵝ for m < M,
then the free energy is bounded below by A times the polylog partition function.
-/
theorem freeEnergyTrunc_lower_bound_of_tail_lower
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N M : ℕ) (γ A β : ℝ)
    (hγ0 : 0 ≤ γ) (_hγ1 : γ < 1) (_hA : 0 ≤ A)
    (hM : ∀ n ∈ Finset.Icc 1 N, τ n ≤ M)
    (_hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n)
    (htail : ∀ m : ℕ, m < M → A * (1 / (↑m + 1) ^ β) ≤ tailMassTrunc τ w N m) :
    A * polylogPartition γ β M ≤ freeEnergyTrunc τ w N γ := by
  convert Finset.sum_le_sum fun m hm => mul_le_mul_of_nonneg_left ( htail m ( Finset.mem_range.mp hm ) ) ( pow_nonneg hγ0 m ) using 1;
  · unfold polylogPartition; simp +decide [ div_eq_mul_inv, mul_left_comm, Finset.mul_sum _ _ _ ] ;
  · grind +suggestions

/-
════════════════════════════════════════════════════════════════════════
§ Sandwich theorem
════════════════════════════════════════════════════════════════════════

**Sandwich theorem**: two-sided power-law tail bounds yield two-sided
free-energy bounds. This identifies the critical exponent of free-energy
divergence with the tail exponent of stopping times.
-/
theorem freeEnergyTrunc_sandwich
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N M : ℕ) (γ A B β : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hM : ∀ n ∈ Finset.Icc 1 N, τ n ≤ M)
    (hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n)
    (htail_lo : ∀ m : ℕ, m < M → A * (1 / (↑m + 1) ^ β) ≤ tailMassTrunc τ w N m)
    (htail_hi : ∀ m : ℕ, tailMassTrunc τ w N m ≤ B * (1 / (↑m + 1) ^ β)) :
    A * polylogPartition γ β M ≤ freeEnergyTrunc τ w N γ ∧
    freeEnergyTrunc τ w N γ ≤ B * polylogPartition γ β M := by
  exact ⟨ freeEnergyTrunc_lower_bound_of_tail_lower τ w N M γ A β hγ0 hγ1 hA hM hw htail_lo, freeEnergyTrunc_upper_bound_of_tail_upper τ w N M γ B β hγ0 hγ1 hB hM hw htail_hi ⟩

-- ════════════════════════════════════════════════════════════════════════
-- § Collatz specialization interface
-- ════════════════════════════════════════════════════════════════════════

/-- Abstract arithmetic transition map. -/
structure ArithTransition where
  /-- One-step map on natural numbers. -/
  step : ℕ → ℕ

/-- The Collatz map as an arithmetic transition. -/
def collatzStep : ArithTransition where
  step := fun n => if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Bounded Collatz stopping time: first k ≤ bound with iterate reaching ≤ 1. -/
def collatzStoppingTimeBounded (bound : ℕ) (n : ℕ) : ℕ :=
  let step := collatzStep.step
  let rec go : ℕ → ℕ → ℕ
    | 0, _ => bound
    | fuel + 1, m => if m ≤ 1 then 0 else 1 + go fuel (step m)
  go bound n

/-- Free energy specialized to the Collatz system. -/
def collatzFreeEnergy (w : ℕ → ℝ) (N : ℕ) (γ : ℝ) (bound : ℕ) : ℝ :=
  freeEnergyTrunc (collatzStoppingTimeBounded bound) w N γ

end