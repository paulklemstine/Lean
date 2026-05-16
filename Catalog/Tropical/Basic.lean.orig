import Mathlib

/-!
# Bellman Duality for Amortized Complexity Certificates

This module establishes **strong duality between amortized charge schedules and
potential-function certificates** for finite execution traces. The main results are:

1. `feasibleRate_iff_bellmanFeasible` — A constant rate `r` bounds all prefix averages
   if and only if there exists a nonneg potential satisfying the Bellman inequality.

2. `amortized_rate_strong_duality_fin` — The infimum over primal feasible rates equals
   the infimum over dual (Bellman) feasible rates.

3. `optimal_rate_eq_maxPrefixAvg` — The optimal rate equals the maximum
   prefix average `max_{1 ≤ k ≤ n} (1/k) ∑_{i<k} cost_i`.

4. `exists_optimal_bellman_potential` — An explicit optimal potential witness exists.

## Mathematical significance

This converts the informal "find a good potential function" heuristic of amortized
analysis into a precise duality theorem: **optimal amortized bounds equal optimal
dual Bellman certificates**. The Bellman inequality `cost_i + φ(i+1) - φ(i) ≤ r`
is exactly a reduced-cost constraint, connecting amortized analysis to LP duality,
min-cost flow, and tropical optimization.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- Extend a `Fin n → ℝ` function to `ℕ → ℝ` by zero-padding. -/
def extendCost {n : ℕ} (cost : Fin n → ℝ) : ℕ → ℝ :=
  fun i => if h : i < n then cost ⟨i, h⟩ else 0

/-- Prefix sum of `cost` over the first `k` steps. For `k ≤ n`, this equals
    `∑_{i<k} cost_i`. -/
def prefixSum {n : ℕ} (cost : Fin n → ℝ) (k : ℕ) : ℝ :=
  ∑ i ∈ Finset.range k, extendCost cost i

theorem prefixSum_zero {n : ℕ} (cost : Fin n → ℝ) : prefixSum cost 0 = 0 := by
  simp [prefixSum]

theorem prefixSum_succ {n : ℕ} (cost : Fin n → ℝ) (k : ℕ) (hk : k < n) :
    prefixSum cost (k + 1) = prefixSum cost k + cost ⟨k, hk⟩ := by
  simp [prefixSum, Finset.sum_range_succ, extendCost, hk]

/-- A rate `r` is primal-feasible if every prefix average is at most `r`:
    `∀ k ∈ {0,...,n}, ∑_{i<k} cost_i ≤ r * k`. -/
def feasibleRate {n : ℕ} (cost : Fin n → ℝ) (r : ℝ) : Prop :=
  ∀ k : Fin (n + 1), prefixSum cost k.1 ≤ r * k.1

/-- A rate `r` is Bellman-feasible (dual-feasible) if there exists a nonnegative
    potential `φ` with `φ 0 = 0` satisfying the one-step Bellman inequality. -/
def bellmanFeasible {n : ℕ} (cost : Fin n → ℝ) (r : ℝ) : Prop :=
  ∃ φ : Fin (n + 1) → ℝ,
    φ 0 = 0 ∧
    (∀ k : Fin (n + 1), 0 ≤ φ k) ∧
    ∀ i : Fin n, cost i + φ i.succ - φ i.castSucc ≤ r

/-! ## Direction 1: Bellman feasible → Rate feasible (Telescoping) -/

/-
Key telescoping lemma: summing the Bellman inequalities gives prefix bounds.
-/
theorem bellman_telescope {n : ℕ} {cost : Fin n → ℝ} {r : ℝ}
    {φ : Fin (n + 1) → ℝ} (hφ0 : φ 0 = 0)
    (hstep : ∀ i : Fin n, cost i + φ i.succ - φ i.castSucc ≤ r)
    (k : ℕ) (hk : k ≤ n) :
    prefixSum cost k + φ ⟨k, by omega⟩ ≤ r * k := by
      induction' k with k ih;
      · -- The prefix sum at 0 is 0, and φ 0 is 0 by hφ0.
        simp [prefixSum_zero, hφ0];
      · have := ih ( Nat.le_of_succ_le hk ) ; have := hstep ⟨ k, hk ⟩ ; simp_all +decide [ mul_add, add_assoc, prefixSum_succ ];
        linarith! [ prefixSum_succ cost k ( Nat.lt_of_succ_le hk ) ]

/-
From a Bellman certificate, we can telescope to get prefix bounds.
-/
theorem bellmanFeasible_imp_feasibleRate
    {n : ℕ} {cost : Fin n → ℝ} {r : ℝ}
    (h : bellmanFeasible cost r) :
    feasibleRate cost r := by
      obtain ⟨ φ, hφ0, hφnn, hstep ⟩ := h;
      exact fun k => by have := bellman_telescope hφ0 hstep k ( Nat.le_of_lt_succ k.2 ) ; linarith [ hφnn ⟨ k, by linarith [ Fin.is_lt k ] ⟩ ] ;

/-! ## Direction 2: Rate feasible → Bellman feasible (Constructive potential) -/

/-- The canonical potential witness: `φ_k = r * k - prefixSum cost k`. -/
def canonicalPotential {n : ℕ} (cost : Fin n → ℝ) (r : ℝ) : Fin (n + 1) → ℝ :=
  fun k => r * k.1 - prefixSum cost k.1

/-
Given prefix bounds, the canonical potential is a valid Bellman certificate.
-/
theorem feasibleRate_imp_bellmanFeasible
    {n : ℕ} {cost : Fin n → ℝ} {r : ℝ}
    (h : feasibleRate cost r) :
    bellmanFeasible cost r := by
      -- Let's choose the canonical potential function as our witness.
      use fun k => r * k.1 - prefixSum cost k.1;
      simp_all +decide [ prefixSum_zero, prefixSum_succ ];
      exact ⟨ fun k => h k, fun i => by linarith ⟩

/-! ## Main Duality Theorem -/

/-- **Bellman strong duality for amortized rates.**
    A constant rate bounds all prefix averages if and only if
    there exists a nonneg Bellman potential certificate. -/
theorem feasibleRate_iff_bellmanFeasible
    {n : ℕ} (cost : Fin n → ℝ) (r : ℝ) :
    feasibleRate cost r ↔ bellmanFeasible cost r :=
  ⟨feasibleRate_imp_bellmanFeasible, bellmanFeasible_imp_feasibleRate⟩

/-! ## Strong Duality: Equality of Infima -/

/-- The primal and dual infima coincide. -/
theorem amortized_rate_strong_duality_fin
    {n : ℕ} (cost : Fin n → ℝ) :
    sInf {r : ℝ | feasibleRate cost r} = sInf {r : ℝ | bellmanFeasible cost r} := by
  congr 1; ext r; exact feasibleRate_iff_bellmanFeasible cost r

/-! ## Optimal Rate = Max Prefix Average -/

/-- The maximum prefix average over `k ∈ {1,...,n}`. -/
def maxPrefixAvg {n : ℕ} (cost : Fin n → ℝ) : ℝ :=
  if hn : n = 0 then 0
  else Finset.sup' (Finset.Icc 1 n)
    (by rw [Finset.nonempty_Icc]; omega)
    (fun k => prefixSum cost k / k)

/-
The maximum prefix average is feasible.
-/
theorem maxPrefixAvg_feasible {n : ℕ} (cost : Fin n → ℝ) :
    feasibleRate cost (maxPrefixAvg cost) := by
      intro k;
      by_cases hk : 1 ≤ k.val <;> by_cases hn : n = 0 <;> simp_all +decide [ maxPrefixAvg ];
      · grind;
      · have := Finset.le_sup' ( f := fun k : ℕ => prefixSum cost k / ( k : ℝ ) ) ( show k.val ∈ Finset.Icc 1 n from Finset.mem_Icc.mpr ⟨ hk, by linarith [ Fin.is_lt k ] ⟩ ) ; simp_all +decide [ div_le_iff₀ ] ;
        obtain ⟨ b, hb₁, hb₂ ⟩ := this; rw [ div_le_iff₀ ( by positivity ) ] at hb₂; exact le_trans hb₂ ( mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun k : ℕ => prefixSum cost k / ( k : ℝ ) ) ( Finset.mem_Icc.mpr hb₁ ) ) ( by positivity ) ) ;
      · exact prefixSum_zero cost ▸ le_rfl;
      · exact prefixSum_zero cost ▸ le_rfl

/-
Every feasible rate is at least the maximum prefix average.
-/
theorem feasibleRate_le_maxPrefixAvg {n : ℕ} (hn : 0 < n) (cost : Fin n → ℝ) (r : ℝ)
    (hr : feasibleRate cost r) :
    maxPrefixAvg cost ≤ r := by
      unfold maxPrefixAvg;
      split_ifs <;> simp_all +decide [ Nat.lt_succ_iff ];
      exact fun k hk₁ hk₂ => by rw [ div_le_iff₀ ( by positivity ) ] ; exact hr ⟨ k, by linarith ⟩ ;

/-
**The optimal amortized rate equals the maximum prefix average.**
-/
theorem optimal_rate_eq_maxPrefixAvg {n : ℕ} (hn : 0 < n) (cost : Fin n → ℝ) :
    sInf {r : ℝ | feasibleRate cost r} = maxPrefixAvg cost := by
      rw [ @IsGLB.csInf_eq ];
      · exact ⟨ fun r hr => feasibleRate_le_maxPrefixAvg hn cost r hr, fun r hr => hr ( maxPrefixAvg_feasible cost ) ⟩;
      · exact ⟨ _, maxPrefixAvg_feasible cost ⟩

/-! ## Existence of Optimal Bellman Potential -/

/-- **There exists an optimal Bellman potential witness.** -/
theorem exists_optimal_bellman_potential
    {n : ℕ} (_hn : 0 < n) (cost : Fin n → ℝ) :
    ∃ φ : Fin (n + 1) → ℝ,
      φ 0 = 0 ∧
      (∀ k : Fin (n + 1), 0 ≤ φ k) ∧
      (∀ i : Fin n, cost i + φ i.succ - φ i.castSucc ≤ maxPrefixAvg cost) := by
  exact (feasibleRate_iff_bellmanFeasible cost (maxPrefixAvg cost)).mp (maxPrefixAvg_feasible cost)

/-! ## Representation Theorem: Schedule ↔ Potential -/

/-
**Amortized schedule ↔ potential equivalence.**
    A schedule `a` prefix-dominates `cost` iff there exists a nonneg potential
    with `φ 0 = 0` decomposing `a` as `cost + Δφ`.
-/
theorem amortized_schedule_iff_potential
    {n : ℕ} (cost a : Fin n → ℝ) :
    (∀ k : Fin (n + 1),
      prefixSum cost k.1 ≤ prefixSum a k.1) ↔
    ∃ φ : Fin (n + 1) → ℝ,
      φ 0 = 0 ∧
      (∀ k : Fin (n + 1), 0 ≤ φ k) ∧
      ∀ i : Fin n, a i = cost i + φ i.succ - φ i.castSucc := by
        constructor;
        · intro h
          use fun k => prefixSum a k - prefixSum cost k;
          simp_all +decide [ prefixSum_succ, Finset.sum_range_succ ];
          exact ⟨ by unfold prefixSum; norm_num, fun i => by ring ⟩;
        · intro h;
          -- By definition of $prefixSum$, we can expand both sides.
          have h_expand : ∀ k : (Fin (n + 1)), prefixSum a k.1 = prefixSum cost k.1 + (h.choose k) := by
            intro k;
            induction' k using Fin.inductionOn with k ih;
            · simp +decide [ prefixSum, h.choose_spec.1 ];
            · grind +suggestions;
          grind

/-! ## Optimal Total Charge = Total Cost -/

/-
The optimal total amortized charge (under prefix dominance) equals the total cost.
-/
theorem amortized_optimal_value_eq_total_cost
    {n : ℕ} (cost : Fin n → ℝ) :
    sInf {B : ℝ | ∃ a : Fin n → ℝ,
      (∀ k : Fin (n + 1),
        prefixSum cost k.1 ≤ prefixSum a k.1) ∧
      (∑ i, a i) = B}
    = ∑ i, cost i := by
      refine' le_antisymm ( csInf_le _ _ ) _;
      · refine' ⟨ ∑ i : Fin n, cost i, fun B hB => _ ⟩;
        obtain ⟨ a, ha₁, rfl ⟩ := hB;
        convert ha₁ ⟨ n, Nat.lt_succ_self n ⟩ using 1 <;> simp +decide [ Finset.sum_range, prefixSum ];
        · exact Finset.sum_congr rfl fun i hi => by unfold extendCost; aesop;
        · exact Finset.sum_congr rfl fun i hi => by unfold extendCost; aesop;
      · refine' ⟨ cost, _, _ ⟩ <;> aesop;
      · refine' le_csInf _ _ <;> norm_num;
        · exact ⟨ _, ⟨ cost, fun k => by rfl, rfl ⟩ ⟩;
        · intro a ha; specialize ha ⟨ n, Nat.lt_succ_self n ⟩ ; simp_all +decide [ prefixSum ] ;
          convert ha using 1 <;> simp +decide [ Finset.sum_range, extendCost ]

end