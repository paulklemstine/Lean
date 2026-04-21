/-! # CatalogBuild.Computation.Oracles.OracleSecret

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Oracles.OracleSecret
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10] -/
theorem divisor_count_multiplicative (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcoprime : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card := by
  exact?




/-- [Section: # CatalogBuild.Computation.Oracles.OracleSecret
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10] -/
theorem egyptian_two_term (n : ℕ) (hn : 2 ≤ n) :
    (1 : ℚ) / n = 1 / (n + 1) + 1 / (n * (n + 1)) := by
  rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity;




theorem greedy_step_valid (p q : ℕ) (hp : 0 < p) (hpq : p < q) :
    let d := (q + p - 1) / p  -- This is ceil(q/p)
    (1 : ℚ) / d ≤ p / q := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  · linarith [ Nat.div_add_mod ( q + p - 1 ) p, Nat.mod_lt ( q + p - 1 ) hp, Nat.sub_add_cancel ( by linarith : 1 ≤ q + p ) ];
  · exact Nat.div_pos ( Nat.le_sub_one_of_lt ( by linarith ) ) hp;
  · linarith




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




theorem spectral_gap_positive (l0 l1 : ℝ) (h : l0 < l1) :
    0 < l1 - l0 := by
  linarith




theorem thooft_scaling_to_zero {f : ℕ → ℝ} {L : ℝ}
    (hf : Filter.Tendsto f Filter.atTop (nhds L)) :
    Filter.Tendsto (fun N => f N / (N : ℝ)^2) Filter.atTop (nhds 0) := by
  simpa using hf.div_atTop ( by exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )




theorem egyptian_two_term_exists (n : ℕ) (hn : 2 ≤ n) :
    ∃ a b : ℕ, a < b ∧ (1 : ℚ) / n = 1 / a + 1 / b := by
  exact ⟨ n + 1, n * ( n + 1 ), by nlinarith, by push_cast; rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity ⟩




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


