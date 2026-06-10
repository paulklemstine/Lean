import Bridges.EBC.Defs

/-!
# Entropy-Bounded Computation (EBC): Core Theorems

This file proves the main results of the EBC framework:

* `tempFactor_pos` — the per-bit Landauer cost is strictly positive.
* `totalCost_append` — total cost is additive over concatenation (the cost
  model is an additive monoid homomorphism).
* `totalCost_le_append_right` — appending steps can only increase cost (budget
  monotonicity).
* `step_count_bounded_by_budget` — a budget `B` admits at most `B / tf`
  unit-erasure steps: a thermodynamic *upper* bound on computation length.
* `bruteForce_cost` — brute-forcing an `n`-bit key space costs `2 ^ n · tf`.
* `demon_cost_additive` — a Maxwell demon's cost is additive over composition.
* `reversible_comp_bijective` — reversible computations compose to bijections.
* `poly_isLittleO_exp` / `entropy_gap_unbounded` — polynomial entropy budgets
  are asymptotically dominated by exponential brute-force cost.
* `search_cost_exceeds_poly_budget` — the thermodynamic separation: for large
  key sizes, brute-force search cost exceeds any fixed polynomial budget.
* `entropy_gap_const` — the gap survives an arbitrary constant multiplier
  (generalization seeding the entropy-hierarchy program).
-/

namespace EBC

open Filter Topology Asymptotics

-- !-- Lab Notebook: tempFactor_pos -- !--
-- !-- Hypothesis: kB·T·ln2 > 0 since all three factors are positive. -- !--
-- !-- Result: Proved from positivity of kB, T and log 2 (> 0 since 1 < 2). -- !--
-- !-- Insight: This is the load-bearing positivity used to convert cost lower -- !--
-- !-- bounds into step-count upper bounds throughout the framework. -- !--
-- !-- Failure analysis: none; direct. -- !--
-- !-- End Lab Notebook -- !--

/-- The per-bit Landauer cost `kB · T · ln 2` is strictly positive. -/
theorem tempFactor_pos (p : LandauerParams) : 0 < p.tempFactor :=
  mul_pos (mul_pos p.kB_pos p.T_pos) (Real.log_pos one_lt_two)

/-- Total bits erased is additive over concatenation. -/
theorem totalBits_append (a b : StepSequence) :
    (a ++ b).totalBits = a.totalBits + b.totalBits := by
  unfold StepSequence.totalBits
  simp [List.map_append, List.sum_append]

-- !-- Lab Notebook: totalCost_append -- !--
-- !-- Hypothesis: Landauer cost is additive: cost(a ++ b) = cost a + cost b. -- !--
-- !-- Result: Proved via totalBits_append and right-distributivity (add_mul). -- !--
-- !-- Insight: The cost model is a monoid hom (List, ++) → (ℝ, +); this is what -- !--
-- !-- makes sequential reasoning about budgets compositional. -- !--
-- !-- Failure analysis: none; reduces to ℕ→ℝ cast of an additive identity. -- !--
-- !-- End Lab Notebook -- !--

/-- Total Landauer cost is additive over concatenation of step sequences. -/
theorem totalCost_append (a b : StepSequence) (tf : ℝ) :
    (a ++ b).totalCost tf = a.totalCost tf + b.totalCost tf := by
  unfold StepSequence.totalCost
  rw [totalBits_append, Nat.cast_add, add_mul]

/-- Cost is nonnegative for a nonnegative per-bit factor. -/
theorem totalCost_nonneg (a : StepSequence) (tf : ℝ) (htf : 0 ≤ tf) :
    0 ≤ a.totalCost tf :=
  mul_nonneg (Nat.cast_nonneg _) htf

/-- Appending more steps can only increase the total cost (budget monotonicity). -/
theorem totalCost_le_append_right (a b : StepSequence) (tf : ℝ) (htf : 0 ≤ tf) :
    a.totalCost tf ≤ (a ++ b).totalCost tf := by
  rw [totalCost_append]
  exact le_add_of_nonneg_right (totalCost_nonneg b tf htf)

-- !-- Lab Notebook: step_count_bounded_by_budget -- !--
-- !-- Hypothesis: With a budget B and each step erasing ≥ 1 bit, the number of -- !--
-- !-- steps is at most B / tf — a thermodynamic upper bound on computation length. -- !--
-- !-- Result: Proved by length ≤ totalBits (each step ≥ 1 bit), then scaling by tf. -- !--
-- !-- Insight: This is Landauer's principle as a *complexity* statement: energy -- !--
-- !-- budget directly caps how many irreversible operations you may perform. -- !--
-- !-- Failure analysis: needs the per-bit factor positive to keep the inequality -- !--
-- !-- direction when multiplying; that is exactly tempFactor_pos's role. -- !--
-- !-- End Lab Notebook -- !--

/-- **Thermodynamic step-count bound.** If every step erases at least one bit and
the total Landauer cost is within budget `B`, then the number of steps, scaled by
the per-bit cost, is at most `B`. Hence at most `B / tf` steps are possible. -/
theorem step_count_bounded_by_budget (seq : StepSequence) (tf : ℝ) (htf : 0 < tf)
    (hmin : ∀ s ∈ seq, 1 ≤ s.bitsErased) (B : ℝ) (hB : seq.totalCost tf ≤ B) :
    (seq.length : ℝ) * tf ≤ B := by
  refine le_trans ?_ hB
  exact mul_le_mul_of_nonneg_right (by exact_mod_cast (by simpa using List.sum_le_sum hmin)) htf.le

/-- Brute-forcing an `n`-bit key space costs exactly `2 ^ n · tf`. -/
theorem bruteForce_cost (P : SearchProblem) (tf : ℝ) :
    P.bruteForce.totalCost tf = (2 ^ P.keyBits : ℝ) * tf := by
  unfold SearchProblem.bruteForce StepSequence.totalCost StepSequence.totalBits
  norm_num [SearchProblem.candidates]

-- !-- Lab Notebook: demon_cost_additive -- !--
-- !-- Hypothesis: A Maxwell demon's erasure cost adds over sequential composition. -- !--
-- !-- Result: Proved by unfolding append (measurement counts add, 1 bit each). -- !--
-- !-- Insight: Information gathered must be erased; the cost of "knowing" is -- !--
-- !-- cumulative — exorcising Maxwell's demon one measurement at a time. -- !--
-- !-- Failure analysis: none; arithmetic on ℕ cast to ℝ. -- !--
-- !-- End Lab Notebook -- !--

/-- A Maxwell demon's Landauer cost is additive over composition (each combined
measurement erasing one bit). -/
theorem demon_cost_additive (d e : MaxwellDemon) (tf : ℝ) :
    (d.append e).cost tf
      = ((d.measurementCount : ℝ) + (e.measurementCount : ℝ)) * tf := by
  unfold MaxwellDemon.cost MaxwellDemon.totalBits
  simp [MaxwellDemon.append, Nat.cast_add, add_mul]

/-- Reversible computations compose to a bijection (zero-cost, information
preserving). -/
theorem reversible_comp_bijective {α : Type*} (g f : ReversibleComputation α) :
    Function.Bijective (g.comp f).forward :=
  Equiv.bijective _

/-- The composite of two reversible computations still has zero Landauer cost. -/
theorem reversible_comp_cost_zero {α : Type*} (g f : ReversibleComputation α) :
    (g.comp f).cost = 0 := rfl

-- !-- Lab Notebook: poly_isLittleO_exp / entropy_gap_unbounded -- !--
-- !-- Hypothesis: Any polynomial entropy budget n^k is eventually dwarfed by the -- !--
-- !-- exponential brute-force cost 2^n. -- !--
-- !-- Result: Proved from Mathlib's isLittleO_pow_exp_pos_mul_atTop with b = ln 2, -- !--
-- !-- rewriting exp(x·ln2) = 2^x (rpow), then specialising to integers. -- !--
-- !-- Insight: This little-o relation is the analytic engine behind every -- !--
-- !-- complexity separation in this framework (search vs. polynomial budgets). -- !--
-- !-- Failure analysis: the discrete (ℕ) form needs care converting an eventual -- !--
-- !-- real inequality along atTop to integer arguments via Nat.cast / ceiling. -- !--
-- !-- End Lab Notebook -- !--

/-- **Polynomial-versus-exponential little-o.** For any degree `k`, the monomial
`x ^ k` is little-o of `2 ^ x` as `x → ∞`. -/
theorem poly_isLittleO_exp (k : ℕ) :
    (fun x : ℝ => x ^ k) =o[atTop] fun x : ℝ => (2 : ℝ) ^ x := by
  simpa only [Real.rpow_def_of_pos (show (0 : ℝ) < 2 by norm_num)] using
    isLittleO_pow_exp_pos_mul_atTop k (Real.log_pos one_lt_two)

/-- **Entropy gap (discrete).** For any polynomial degree `k`, eventually
`n ^ k < 2 ^ n`: exponential brute-force cost outstrips polynomial budgets. -/
theorem entropy_gap_unbounded (k : ℕ) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (n : ℝ) ^ k < 2 ^ n := by
  have h := (poly_isLittleO_exp k).tendsto_div_nhds_zero
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp (h.eventually (gt_mem_nhds zero_lt_one))
  exact ⟨⌈N⌉₊, fun n hn => by
    have := hN n (Nat.le_of_ceil_le hn)
    rw [div_lt_one (by positivity)] at this
    exact_mod_cast this⟩

-- !-- Lab Notebook: search_cost_exceeds_poly_budget -- !--
-- !-- Hypothesis: For large key sizes the brute-force Landauer cost exceeds any -- !--
-- !-- fixed polynomial-in-key-size budget. -- !--
-- !-- Result: Combine bruteForce_cost (cost = 2^n·tf) with entropy_gap_unbounded -- !--
-- !-- (n^k < 2^n) and positivity of tf. -- !--
-- !-- Insight: This is the *cryptographic* payoff — brute force is thermodynamically -- !--
-- !-- infeasible: a 2^n energy wall no polynomial attacker can scale. -- !--
-- !-- Failure analysis: requires tf > 0 to preserve the inequality under scaling. -- !--
-- !-- End Lab Notebook -- !--

/-- **Thermodynamic search separation.** For per-bit cost `tf > 0` and any
polynomial degree `k`, eventually the brute-force Landauer cost over an `n`-bit
key space, `2 ^ n · tf`, exceeds the polynomial budget `n ^ k · tf`. -/
theorem search_cost_exceeds_poly_budget (tf : ℝ) (htf : 0 < tf) (k : ℕ) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ((n : ℝ) ^ k) * tf < (SearchProblem.bruteForce ⟨n⟩).totalCost tf := by
  obtain ⟨N, hN⟩ := entropy_gap_unbounded k
  exact ⟨N, fun n hn => by
    rw [bruteForce_cost]
    exact mul_lt_mul_of_pos_right (hN n hn) htf⟩

-- !-- Lab Notebook: entropy_gap_const (generalization) -- !--
-- !-- Hypothesis: The polynomial-vs-exponential gap is robust to any constant -- !--
-- !-- multiplier C on the polynomial side. -- !--
-- !-- Result: Proved by scaling the little-o limit by C (const_mul) and reusing -- !--
-- !-- the ceiling/exact_mod_cast extraction. -- !--
-- !-- Insight: A simulator with budget n^(k+1) can absorb the polynomial overhead -- !--
-- !-- (constant C) of universal simulation — the boundary needed for a future -- !--
-- !-- entropy-hierarchy theorem (see FUTURE_DIRECTIONS.md). -- !--
-- !-- Failure analysis: for C ≤ 0 the statement is trivially true; the analytic -- !--
-- !-- content is entirely in the C > 0 regime captured by the limit. -- !--
-- !-- End Lab Notebook -- !--

/-- **Generalization (boundary case).** The gap survives an arbitrary constant
multiplier on the polynomial side: for any constant `C` and degree `k`,
eventually `C · n ^ k < 2 ^ n`. This is the form needed for a universal-simulator
entropy-hierarchy theorem (see `FUTURE_DIRECTIONS.md`). -/
theorem entropy_gap_const (C : ℝ) (k : ℕ) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → C * (n : ℝ) ^ k < 2 ^ n := by
  have h_lim : Filter.Tendsto (fun x : ℝ => C * x ^ k / 2 ^ x) atTop (nhds 0) := by
    convert ((poly_isLittleO_exp k).tendsto_div_nhds_zero).const_mul C using 2 with x
    · ring
    · norm_num
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp (h_lim.eventually (gt_mem_nhds zero_lt_one))
  exact ⟨⌈N⌉₊, fun n hn => by
    have := hN n (Nat.le_of_ceil_le hn)
    rw [div_lt_one (by positivity)] at this
    exact_mod_cast this⟩

end EBC