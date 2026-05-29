/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Periodic Mean-Zero Logarithmic Weighted Sums are Bounded

This file proves a cross-domain theorem connecting periodic arithmetic functions
to bounded weighted sums, establishing a formal bridge between:
- **Harmonic analysis**: periodic structures and Fourier-theoretic cancellation
- **Analytic number theory**: convergence of Dirichlet L-series L(1,χ)
- **Euler–Mascheroni constant**: contrast with the non-canceling harmonic sum

## Main results

* `periodic_partial_sum_periodic` — partial sums of periodic mean-zero functions are periodic
* `periodic_partial_sum_bounded` — periodic ℕ → ℝ functions are bounded
* `periodic_mean_zero_log_weighted_bounded` — the main theorem: ∑_{k=1}^{n} f(k)/k is bounded

## Mathematical significance

The convergence of ∑ f(k)/k for periodic mean-zero f models the convergence mechanism
behind Dirichlet L-series L(1,χ) for non-principal characters χ. The harmonic sum
H_n = ∑ 1/k diverges precisely because the constant function f(k) = 1 has nonzero mean.
This theorem isolates mean-zero periodicity as the structural mechanism for convergence,
creating a conceptual bridge from γ (which arises from the divergent bulk) to L-function
special values (which arise from the convergent periodic part).
-/

namespace PeriodicSums

open Finset BigOperators

/-! ## Periodic functions on ℕ -/

/-- A function f : ℕ → ℝ is periodic with period q if f(n + q) = f(n) for all n. -/
def IsPeriodic (f : ℕ → ℝ) (q : ℕ) : Prop := ∀ n, f (n + q) = f n

/-- The partial sum F(n) = ∑_{k=0}^{n-1} f(k). -/
def partialSum (f : ℕ → ℝ) (n : ℕ) : ℝ := ∑ k ∈ Finset.range n, f k

/-
If f is periodic with period q and has mean zero over one period,
    then its partial sums are also periodic with period q.
-/
theorem periodic_partial_sum_periodic (f : ℕ → ℝ) (q : ℕ)
    (hper : IsPeriodic f q) (hmean : ∑ i ∈ Finset.range q, f i = 0) :
    IsPeriodic (partialSum f) q := by
  unfold IsPeriodic at *; (
  intro n; rw [ partialSum, partialSum ] ; induction n <;> simp_all +decide [ Nat.succ_add, Finset.sum_range_succ ] ;);

/-
A periodic function on ℕ is bounded.
-/
theorem periodic_bounded (g : ℕ → ℝ) (q : ℕ) (hq : 0 < q)
    (hper : IsPeriodic g q) :
    ∃ M : ℝ, ∀ n, |g n| ≤ M := by
  -- By � definition� of periodicity, we have g(n) = g(n % q) for all n.
  have h_mod : ∀ n, g n = g (n % q) := by
    intro n; rw [ ← Nat.mod_add_div n q ] ; induction' n/q with k hk <;> simp_all +decide [ Nat.mul_succ, ← add_assoc, IsPeriodic ] ;
  -- � The� set {g(0), g(1), ..., g(q-1)} is finite, so its maximum absolute value M exists.
  use sSup (Set.image (fun k => |g k|) (Finset.range q));
  exact fun n => by rw [ h_mod n ] ; exact le_csSup ( by exact Set.Finite.bddAbove <| Set.toFinite _ ) <| Set.mem_image_of_mem _ <| Finset.mem_coe.mpr <| Finset.mem_range.mpr <| Nat.mod_lt _ hq;

/-
Summation by parts (Abel summation) for finite sums.
-/
theorem abel_summation (a : ℕ → ℝ) (b : ℕ → ℝ) (n : ℕ) :
    ∑ k ∈ Finset.range n, a k * b k =
      partialSum a n * b n -
      ∑ k ∈ Finset.range n, partialSum a (k + 1) * (b (k + 1) - b k) := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ, partialSum ] ; ring

/-
**Main theorem: Periodic mean-zero log-weighted sums are bounded.**

    If f : ℕ → ℝ is periodic with period q > 0 and has mean zero
    (∑_{i=0}^{q-1} f(i) = 0), then the weighted sum ∑_{k=1}^{n} f(k)/k
    is uniformly bounded in n.

    This is the formal shadow of convergence of L(1,χ) for non-principal
    Dirichlet characters. The proof uses Abel summation (summation by parts)
    and the boundedness of partial sums of periodic mean-zero functions.
-/
theorem periodic_mean_zero_log_weighted_bounded
    (f : ℕ → ℝ) (q : ℕ) (hq : 0 < q)
    (hper : ∀ n, f (n + q) = f n)
    (hmean : ∑ i ∈ Finset.range q, f i = 0) :
    ∃ C : ℝ, ∀ n : ℕ, 1 ≤ n →
      |∑ k ∈ Finset.Icc 1 n, f k / k| ≤ C := by
  -- Let F = partialSum f. By periodic_partial_sum_periodic, F is periodic with period q.
  set F : ℕ → ℝ := partialSum f
  have hF_periodic : IsPeriodic F q := by
    apply periodic_partial_sum_periodic f q hper hmean

  -- By periodic_bounded, ∃ M, ∀ k, |F k| ≤ M.
  obtain ⟨M, hM⟩ : ∃ M, ∀ k, |F k| ≤ M := by
    exact?

  -- We'll use the fact that |F(n+1)/(n+1) - F(1)/1 + ∑_{k=1}^{n} F(k+1)/(k(k+1))| ≤ 2M.
  have h_bound : ∀ n, 1 ≤ n → abs (∑ k ∈ Finset.Icc 1 n, f k / (k : ℝ)) ≤ 2 * M := by
    -- By Abel's summation formula, � we� have $\sum_{k=1}^{n} \frac{f(k)}{k} = \frac{F(n+1)}{n+1} - \frac{F(1)} �{�1} + \sum_{k=1}^{n} \frac{F(k+1)}{k(k+1)}$.
    have h_abel : ∀ n, 1 ≤ n → ∑ k ∈ Finset.Icc 1 n, f k / (k : ℝ) = (F (n + 1)) / (n + 1) - (F 1) / 1 + ∑ k ∈ Finset.Icc 1 n, (F (k + 1)) / (k * (k + 1) : ℝ) := by
      intro n hn
      have h_abel : ∑ k ∈ Finset.Icc 1 n, f k / (k : ℝ) = ∑ k ∈ Finset.Icc 1 n, (F (k + 1) - F k) / (k : ℝ) := by
        simp +zetaDelta at *;
        unfold partialSum; simp +decide [ Finset.sum_range_succ ] ;
      have h_abel_sum : ∀ k ∈ Finset.Icc 1 n, (F (k + 1) - F k) / (k : ℝ) = (F (k + 1)) / (k * (k + 1) : ℝ) + (F (k + 1)) / (k + 1 : ℝ) - (F k) / (k : ℝ) := by
        intro k hk; rw [ div_add_div, div_sub_div, div_eq_div_iff ] <;> ring <;> norm_cast <;> nlinarith [ Finset.mem_Icc.mp hk ] ;
      rw [ h_abel, Finset.sum_congr rfl h_abel_sum ] ; clear h_abel h_abel_sum ; induction hn <;> norm_num [ Finset.sum_Ioc_succ_top, (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc) ] at * ; linarith;
      grind;
    -- We'll use the fact that |∑_{k=1}^{n} F(k+1)/(k(k+1))| ≤ M *_{k=1}^{n} (1/k - 1/(k+1)) = M * (1 - 1/(n+1)).
    have h_sum_bound : ∀ n, 1 ≤ n → abs (∑ k ∈ Finset.Icc 1 n, (F (k + 1)) / (k * (k + 1) : ℝ)) ≤ M * (1 - 1 / (n + 1)) := by
      intros n hn
      have h_sum_bound_step : ∀ k ∈ Finset.Icc 1 n, abs ((F (k + 1)) / (k * (k + 1) : ℝ)) ≤ M * (1 / (k : ℝ) - 1 / (k + 1 : ℝ)) := by
        intro k hk; rw [ abs_div ] ; norm_cast ; norm_num;
        exact le_trans ( div_le_div_of_nonneg_right ( hM _ ) ( by positivity ) ) ( by rw [ inv_sub_inv, div_eq_mul_inv ] <;> ring <;> norm_num <;> linarith [ Finset.mem_Icc.mp hk ] );
      convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum h_sum_bound_step using 1 ; norm_num [ Finset.sum_Ioc_succ_top, (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc) ] ; ring;
      exact Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ add_assoc, Finset.sum_Ioc_succ_top ] at * ; linear_combination ihn;
    intro n hn; rw [ h_abel n hn ] ; rw [ abs_le ] ; constructor <;> nlinarith [ abs_le.mp ( hM ( n + 1 ) ), abs_le.mp ( hM 1 ), abs_le.mp ( h_sum_bound n hn ), show ( 1 : ℝ ) ≤ n by norm_cast, one_div_mul_cancel ( by positivity : ( n : ℝ ) + 1 ≠ 0 ), div_mul_cancel₀ ( F ( n + 1 ) ) ( by positivity : ( n : ℝ ) + 1 ≠ 0 ) ] ;
  exact ⟨ _, h_bound ⟩

end PeriodicSums