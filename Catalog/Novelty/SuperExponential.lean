/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Super-exponential growth: the analytic engine

This file isolates the notion of *super-exponential* growth of a natural-number
sequence and proves the facts that drive the rest of the project:

* `factorial_superexp` : the factorial `n ↦ n!` is super-exponential.
* `perm_card_superexp` : the number of permutations of an `n`-element set,
  `Fintype.card (Equiv.Perm (Fin n)) = n!`, is super-exponential.

`SuperExp f` is defined as: for every base `c`, the sequence `f` eventually
exceeds `c ^ n`.  This is precisely the property "grows faster than any fixed
exponential" used in the conjecture on the number of symmetric chain
decompositions of `M(n)`.

We also record:

* `SuperExp.of_eventually_le` : super-exponential growth transfers upward along
  an eventual pointwise inequality (used to push a *lower bound* on a count to
  super-exponential growth of the count itself);
* `pow_const_not_superexp` : a fixed polynomial `m ↦ m ^ k` is *not*
  super-exponential — the sharp contrast that makes the super-exponential claim
  non-vacuous.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): "Super-exponential" should mean: dominates every
exponential `c^n`.  Conjecture: factorial witnesses this, and so does any count
bounded below by a factorial.
EXPERIMENT (Experimenter): `FloorSemiring.tendsto_pow_div_factorial_atTop`
provides `c^n / n! → 0`, from which the discrete inequality `c^n < n!` for large
`n` falls out by unpacking the metric definition of the limit.
ANALYSIS (Analyst): the analytic limit is the cleanest engine — an elementary
induction needs a base case `c^{N} < N!` whose threshold `N ≈ e·c` is awkward to
pin down uniformly in `c`.  The limit sidesteps the base case entirely.
CRITIQUE (Critic): is the statement vacuous?  No: `pow_const_not_superexp`
exhibits explicit functions (`m^k`) that fail `SuperExp`, so the predicate is a
genuine dividing line, not satisfied by everything.
-/
import Mathlib

open Filter Topology

namespace Novelty.SCD

/-- A sequence `f : ℕ → ℕ` grows **super-exponentially** if it eventually exceeds
every fixed exponential `c ^ n`. -/
def SuperExp (f : ℕ → ℕ) : Prop :=
  ∀ c : ℕ, ∃ N, ∀ n, N ≤ n → c ^ n < f n

/-- The factorial is super-exponential.  Proof: for fixed base `c`, the real
sequence `c^n / n!` tends to `0`, so it is eventually `< 1`, i.e. `c^n < n!`. -/
theorem factorial_superexp : SuperExp Nat.factorial := by
  intro c
  have h := FloorSemiring.tendsto_pow_div_factorial_atTop (c : ℝ)
  rw [Metric.tendsto_atTop] at h
  obtain ⟨N, hN⟩ := h 1 (by norm_num)
  refine ⟨N, fun n hn => ?_⟩
  have hd := hN n hn
  simp only [Real.dist_eq, sub_zero] at hd
  have hpos : (0 : ℝ) < n.factorial := by positivity
  have hcn : (c : ℝ) ^ n / n.factorial < 1 := by
    have := (abs_lt.mp hd).2
    linarith [abs_nonneg ((c : ℝ) ^ n / n.factorial)]
  rw [div_lt_one hpos] at hcn
  have hcast : ((c ^ n : ℕ) : ℝ) < ((n.factorial : ℕ) : ℝ) := by push_cast; exact hcn
  exact_mod_cast hcast

/-- Super-exponential growth transfers upward along an eventual pointwise
inequality: if `f` is super-exponential and `f n ≤ g n` for all large `n`, then
`g` is super-exponential.  This is the bridge from a factorial *lower bound* on a
combinatorial count to super-exponential growth of the count. -/
theorem SuperExp.of_eventually_le {f g : ℕ → ℕ} (hf : SuperExp f)
    (h : ∃ M, ∀ n, M ≤ n → f n ≤ g n) : SuperExp g := by
  obtain ⟨M, hM⟩ := h
  intro c
  obtain ⟨N, hN⟩ := hf c
  refine ⟨max N M, fun n hn => ?_⟩
  have hn1 : N ≤ n := le_trans (le_max_left _ _) hn
  have hn2 : M ≤ n := le_trans (le_max_right _ _) hn
  exact lt_of_lt_of_le (hN n hn1) (hM n hn2)

/-- The number of permutations of `Fin n` is `n!`. -/
theorem perm_card_eq_factorial (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  rw [Fintype.card_perm, Fintype.card_fin]

/-- The number of permutations of an `n`-element set is super-exponential. -/
theorem perm_card_superexp :
    SuperExp (fun n => Fintype.card (Equiv.Perm (Fin n))) := by
  have : (fun n => Fintype.card (Equiv.Perm (Fin n))) = Nat.factorial := by
    funext n; exact perm_card_eq_factorial n
  rw [this]; exact factorial_superexp

/-
A fixed polynomial `m ↦ m ^ k` is **not** super-exponential: taking base
`c = 2`, the exponential `2 ^ m` eventually overtakes `m ^ k`, so `m ^ k` fails to
exceed `2 ^ m` for large `m`.  This guarantees `SuperExp` is a strict dividing
line (it rules out every polynomial).
-/
theorem pow_const_not_superexp (k : ℕ) : ¬ SuperExp (fun m => m ^ k) := by
  intro h
  obtain ⟨N, hN⟩ := h 2
  have h_contra : ∃ n ≥ N, n ^ k < 2 ^ n := by
    have h_lim : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ k / 2 ^ n) Filter.atTop (nhds 0) := by
      -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
      suffices h_log : Filter.Tendsto (fun m : ℝ => (m / Real.log 2) ^ k / Real.exp m) Filter.atTop (nhds 0) by
        convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
      -- We can factor out $(1 / \log 2)^k$ from the limit.
      suffices h_factor : Filter.Tendsto (fun m : ℝ => m ^ k / Real.exp m) Filter.atTop (nhds 0) by
        convert h_factor.div_const ( Real.log 2 ^ k ) using 2 <;> ring;
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
    have := h_lim.eventually ( gt_mem_nhds zero_lt_one ) ; have := this.and ( Filter.eventually_ge_atTop N ) ; obtain ⟨ n, hn₁, hn₂ ⟩ := this.exists; use n; norm_num at *; rw [ div_lt_iff₀ ] at * <;> norm_cast at * <;> aesop;
  obtain ⟨n, hn1, hn2⟩ := h_contra
  linarith [hN n hn1]

end Novelty.SCD