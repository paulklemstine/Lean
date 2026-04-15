/-
  The Oracle's Secret: Formal Foundations
  ========================================
  Machine-verified components of three conjectures linking
  number theory, physics, and logic.
-/
import Mathlib

open Nat Finset BigOperators

/-! ## Part 1: Divisor Function and Egyptian Fractions -/

/-
PROBLEM
The number of divisors function is multiplicative for coprime arguments.

PROVIDED SOLUTION
Use Nat.Coprime.divisors_mul and Finset.card_product or the multiplicativity of the divisors finset for coprime arguments. Try Nat.divisors_mul_of_coprime or similar.
-/
theorem divisor_count_multiplicative (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcoprime : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card := by
  exact?

/-
PROBLEM
Every unit fraction 1/n with n ≥ 2 can be written as a sum of two distinct
    unit fractions: 1/n = 1/(n+1) + 1/(n(n+1)). This is the simplest Egyptian
    fraction decomposition.

PROVIDED SOLUTION
We need 1/n = 1/(n+1) + 1/(n(n+1)). The RHS = (n + 1)/(n(n+1)(n+1)) + 1/(n(n+1)) ... actually just use field_simp and ring. Cast n to ℚ, the denominators are nonzero since n ≥ 2.
-/
theorem egyptian_two_term (n : ℕ) (hn : 2 ≤ n) :
    (1 : ℚ) / n = 1 / (n + 1) + 1 / (n * (n + 1)) := by
  rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity;

/-
PROBLEM
For any fraction p/q with 0 < p < q, the greedy algorithm produces
    a valid unit fraction: ceil(q/p) gives a denominator d with 1/d ≤ p/q.

PROVIDED SOLUTION
d = ceil(q/p). Then d ≥ q/p, so 1/d ≤ p/q. Use Nat.div_le properties and cast to ℚ. Key: (q + p - 1) / p ≥ q / p (as naturals, this is the ceiling). Then 1/d ≤ 1/(q/p) = p/q.
-/
theorem greedy_step_valid (p q : ℕ) (hp : 0 < p) (hpq : p < q) :
    let d := (q + p - 1) / p  -- This is ceil(q/p)
    (1 : ℚ) / d ≤ p / q := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  · linarith [ Nat.div_add_mod ( q + p - 1 ) p, Nat.mod_lt ( q + p - 1 ) hp, Nat.sub_add_cancel ( by linarith : 1 ≤ q + p ) ];
  · exact Nat.div_pos ( Nat.le_sub_one_of_lt ( by linarith ) ) hp;
  · linarith

/-! ## Part 2: Decidability-Regularity Principle (Core Logic) -/

/-- If a property is always false, the corresponding predicate is decidable.
    This captures: "if blow-up never occurs, blow-up prediction is trivially decidable." -/
def never_blowup_decidable {α : Type*} (P : α → Prop) (hP : ∀ a, ¬ P a) :
    DecidablePred P :=
  fun a => isFalse (hP a)

/-- If a property is always true, the corresponding predicate is decidable.
    This captures: "if regularity always holds, regularity checking is trivially decidable." -/
def always_regular_decidable {α : Type*} (P : α → Prop) (hP : ∀ a, P a) :
    DecidablePred P :=
  fun a => isTrue (hP a)

/-- The blow-up question for the 1D heat equation is decidable:
    the maximum principle guarantees solutions remain bounded,
    so blow-up never occurs and the question is trivially decidable.

    We model this abstractly: if we have a bound on the solution
    (the maximum principle), then the blow-up predicate is decidable. -/
def heat_equation_blowup_decidable
    {InitData : Type*}
    (_solution_bound : InitData → ℝ)
    (blows_up : InitData → Prop)
    (maximum_principle : ∀ u₀, ¬ blows_up u₀) :
    DecidablePred blows_up :=
  never_blowup_decidable blows_up maximum_principle

/-! ## Part 3: Spectral Gap Properties -/

/-
PROBLEM
If two eigenvalues satisfy l₀ < l₁, then the spectral gap is positive.

PROVIDED SOLUTION
Simple: 0 < l1 - l0 follows from h : l0 < l1 by linarith or sub_pos.mpr
-/
theorem spectral_gap_positive (l0 l1 : ℝ) (h : l0 < l1) :
    0 < l1 - l0 := by
  linarith

/-
PROBLEM
The 't Hooft large-N scaling: if a sequence converges to a limit L,
    then dividing by N² gives a sequence converging to 0 (when L is finite).

PROVIDED SOLUTION
Since f N → L, f is eventually bounded. The denominator N^2 → ∞. Use Filter.Tendsto.div_atTop or tendsto_const_div_atTop_nhds_0_nat or similar. Concretely: f N / N^2 = (f N) * (1/N^2), f N → L, and 1/N^2 → 0, so the product → L * 0 = 0. Use Filter.Tendsto.mul with tendsto_one_div_atTop_nhds_0_nat squared, or tendsto_div_pow_mul_atTop_of_tendsto.
-/
theorem thooft_scaling_to_zero {f : ℕ → ℝ} {L : ℝ}
    (hf : Filter.Tendsto f Filter.atTop (nhds L)) :
    Filter.Tendsto (fun N => f N / (N : ℝ)^2) Filter.atTop (nhds 0) := by
  simpa using hf.div_atTop ( by exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )

/-! ## Part 4: Sub-Multiplicativity (New Hypothesis) -/

/-
PROBLEM
For any n ≥ 2, there exist natural numbers a, b with a < b such that
    1/n = 1/a + 1/b. Specifically, a = n+1 and b = n(n+1) work.

PROVIDED SOLUTION
Use a = n+1, b = n*(n+1). Then a < b since n ≥ 2 implies n+1 < n*(n+1) = n²+n. And 1/n = 1/(n+1) + 1/(n*(n+1)) by egyptian_two_term.
-/
theorem egyptian_two_term_exists (n : ℕ) (hn : 2 ≤ n) :
    ∃ a b : ℕ, a < b ∧ (1 : ℚ) / n = 1 / a + 1 / b := by
  exact ⟨ n + 1, n * ( n + 1 ), by nlinarith, by push_cast; rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity ⟩

/-! ## Part 5: Convergence Characterization -/

/-
PROBLEM
If a sequence of ratios f(delta_N)/N² converges to 0, and each delta_N > 0,
    then the gaps grow strictly sub-quadratically.

PROVIDED SOLUTION
This follows from the definition of Filter.Tendsto to nhds 0. hconv says f(delta N)/N^2 → 0. By the definition of convergence, for any ε > 0, eventually f(delta N)/N^2 < ε, i.e., f(delta N) < ε * N^2. Use Filter.Tendsto.eventually with Iio_mem_nhds or ball_mem_nhds.
-/
theorem mass_gap_subquadratic {delta : ℕ → ℝ} {f : ℝ → ℝ}
    (_hdelta : ∀ N, 0 < delta N)
    (_hf_mono : Monotone f)
    (_hf_pos : ∀ x, 0 < x → 0 < f x)
    (hconv : Filter.Tendsto (fun N => f (delta N) / (N : ℝ)^2) Filter.atTop (nhds 0)) :
    ∀ ε > 0, ∃ N₀, ∀ N ≥ N₀, f (delta N) < ε * (N : ℝ)^2 := by
  intro ε hε_pos
  obtain ⟨N₀, hN₀⟩ : ∃ N₀ : ℕ, ∀ N ≥ N₀, f (delta N) / (N : ℝ) ^ 2 < ε := by
    simpa using hconv.eventually ( gt_mem_nhds hε_pos ) |> fun h => Filter.eventually_atTop.mp h |> fun ⟨ N₀, hN₀ ⟩ => ⟨ N₀, fun N hN => hN₀ N hN ⟩ ;
  use N₀ + 1
  intro N hN
  have hN_ge_1 : 1 ≤ N := by
    linarith
  have hN_sq_pos : 0 < (N : ℝ) ^ 2 := by
    positivity
  have h_f_lt_eps : f (delta N) < ε * (N : ℝ) ^ 2 := by
    simpa only [ div_lt_iff₀ hN_sq_pos ] using hN₀ N ( Nat.le_of_succ_le hN )
  exact h_f_lt_eps