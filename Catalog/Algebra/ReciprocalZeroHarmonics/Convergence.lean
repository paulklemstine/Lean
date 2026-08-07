import Algebra.ReciprocalZeroHarmonics.Core

/-!
# Reciprocal-Zero Harmonics III: renormalised convergence and a quantitative tail bound

Direction 1 of the programme asks for an explicit renormalisation under which the
multiplicity-sensitive, conjugate-symmetric sum `H(T) = Σ_{|Im ρ| ≤ T} 1/ρ` converges, with an
error term controlled by zero counting.  `Core.lean` supplies the renormalisation: conjugate
pairing replaces `1/ρ + 1/ρ̄` by the positive real number `1/(1/4 + t²)`.  This file supplies
the analytic half.

Throughout, `g : ℕ → ℝ` is an increasing enumeration of the positive ordinates of the zeros.
The Riemann–von Mangoldt formula `N(T) = (T/2π)·log(T/2πe) + O(log T)` is equivalent to a lower
bound of the shape `g n ≥ a·(n+1)/log(n+2)`, and this is exactly the hypothesis we take as
input; no unproved analytic statement about `ζ` is assumed anywhere.

## Main results

* `summable_renormalized_of_rvm` — **renormalised convergence.**  Under the
  Riemann–von Mangoldt-type lower bound `g n ≥ a·(n+1)/log(n+2)` (`a > 0`) the paired series
  `Σ_n 1/(1/4 + g(n)²)` converges absolutely.
* `tendsto_pairedHarmonic` — consequently the conjugate-paired window sums
  `Re H(Z_N) = Σ_{n<N} 1/(1/4 + g(n)²)` of `Core.harmonicSum` converge to a finite limit; this is
  the renormalised value of `H(T)`.
* `tail_bound_of_separated` — **quantitative error term.**  Under the stronger separation
  hypothesis `g n ≥ a·(n+1)` the truncation error is explicit:
  `Σ_{n ≥ N} 1/(1/4 + g(n)²) ≤ 1/(a²N)`.
* `not_summable_unpaired` — **the renormalisation is necessary.**  If the ordinates do not grow
  faster than linearly (`g n ≤ b·(n+1)`), the unpaired series `Σ_n 1/g(n)` diverges.  Absolute
  convergence of `Σ 1/ρ` genuinely fails; only the conjugate-paired sum converges.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Conjugate pairing gains one power of the ordinate
  (`1/ρ + 1/ρ̄ ≍ 1/t²` instead of `1/t`), and zero counting shows `t ≍ n/log n`; the paired sum
  should therefore converge while the unpaired one diverges.
* **Experiment (Experimenter).** Convergence: `1/(1/4+g²) ≤ log(n+2)²/(a²(n+1)²)` and
  `log x ≤ 4x^{1/4}` (from `log y ≤ y - 1` applied to `y = x^{1/4}`) give the summable majorant
  `32·(n+1)^{-3/2}`.  Divergence: comparison with the harmonic series.  The error term is a
  telescoping estimate `1/(n+N)(n+N+1) = 1/(n+N) - 1/(n+N+1)`.
* **Analysis (Analyst).** Both phenomena are quantitative expressions of the same fact: the
  ordinate sequence grows essentially linearly.  The gap between the two theorems
  (`Σ 1/g` diverges, `Σ 1/(1/4+g²)` converges) is precisely the analytic content of the
  conjugation principle: the renormalisation is not cosmetic.
* **Critique (Critic).** No statement is vacuous: `summable_renormalized_of_rvm` and
  `not_summable_unpaired` have overlapping hypotheses (e.g. `g n = n+1` satisfies both), so the
  two conclusions apply simultaneously to genuine sequences, showing the contrast is real.
-/

namespace ReciprocalZeroHarmonics

open Filter

/-! ## A summable majorant -/

/-- `log x ≤ 4·x^{1/4}` for `x > 0`, obtained from `log y ≤ y - 1` at `y = x^{1/4}`. -/
theorem log_le_four_rpow (x : ℝ) (hx : 0 < x) : Real.log x ≤ 4 * x ^ (1 / 4 : ℝ) := by
  have h1 : Real.log (x ^ (1 / 4 : ℝ)) ≤ x ^ (1 / 4 : ℝ) - 1 :=
    Real.log_le_sub_one_of_pos (Real.rpow_pos_of_pos hx _)
  rw [Real.log_rpow hx] at h1
  nlinarith [Real.rpow_pos_of_pos hx (1 / 4 : ℝ)]

theorem log_sq_le (n : ℕ) : Real.log ((n : ℝ) + 2) ^ 2 ≤ 16 * ((n : ℝ) + 2) ^ (1 / 2 : ℝ) := by
  have hx : (0 : ℝ) < (n : ℝ) + 2 := by positivity
  have h := log_le_four_rpow ((n : ℝ) + 2) hx
  have hpos : 0 ≤ Real.log ((n : ℝ) + 2) :=
    Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) n])
  have h2 : Real.log ((n : ℝ) + 2) ^ 2 ≤ (4 * ((n : ℝ) + 2) ^ (1 / 4 : ℝ)) ^ 2 := by nlinarith
  calc Real.log ((n : ℝ) + 2) ^ 2 ≤ (4 * ((n : ℝ) + 2) ^ (1 / 4 : ℝ)) ^ 2 := h2
    _ = 16 * (((n : ℝ) + 2) ^ (1 / 4 : ℝ)) ^ 2 := by ring
    _ = 16 * ((n : ℝ) + 2) ^ (1 / 2 : ℝ) := by
        rw [← Real.rpow_natCast (((n : ℝ) + 2) ^ (1 / 4 : ℝ)) 2, ← Real.rpow_mul (le_of_lt hx)]
        norm_num

theorem log_sq_div_le (n : ℕ) :
    Real.log ((n : ℝ) + 2) ^ 2 / ((n : ℝ) + 1) ^ 2 ≤ 32 / ((n : ℝ) + 1) ^ (3 / 2 : ℝ) := by
  have h1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hsq : ((n : ℝ) + 2) ^ (1 / 2 : ℝ) ≤ 2 * ((n : ℝ) + 1) ^ (1 / 2 : ℝ) := by
    have h4 : ((n : ℝ) + 2) ≤ 4 * ((n : ℝ) + 1) := by linarith [Nat.cast_nonneg (α := ℝ) n]
    calc ((n : ℝ) + 2) ^ (1 / 2 : ℝ) ≤ (4 * ((n : ℝ) + 1)) ^ (1 / 2 : ℝ) :=
          Real.rpow_le_rpow (by positivity) h4 (by norm_num)
      _ = 4 ^ (1 / 2 : ℝ) * ((n : ℝ) + 1) ^ (1 / 2 : ℝ) :=
          Real.mul_rpow (by norm_num) (le_of_lt h1)
      _ = 2 * ((n : ℝ) + 1) ^ (1 / 2 : ℝ) := by norm_num
  have key : ((n : ℝ) + 1) ^ (1 / 2 : ℝ) / ((n : ℝ) + 1) ^ 2 = 1 / ((n : ℝ) + 1) ^ (3 / 2 : ℝ) := by
    rw [show ((n : ℝ) + 1) ^ 2 = ((n : ℝ) + 1) ^ (2 : ℝ) by rw [← Real.rpow_natCast]; norm_num,
      ← Real.rpow_sub h1, eq_div_iff (by positivity), ← Real.rpow_add h1]
    norm_num
  calc Real.log ((n : ℝ) + 2) ^ 2 / ((n : ℝ) + 1) ^ 2
      ≤ (16 * ((n : ℝ) + 2) ^ (1 / 2 : ℝ)) / ((n : ℝ) + 1) ^ 2 := by
        gcongr
        exact log_sq_le n
    _ ≤ (16 * (2 * ((n : ℝ) + 1) ^ (1 / 2 : ℝ))) / ((n : ℝ) + 1) ^ 2 := by gcongr
    _ = 32 * (((n : ℝ) + 1) ^ (1 / 2 : ℝ) / ((n : ℝ) + 1) ^ 2) := by ring
    _ = 32 / ((n : ℝ) + 1) ^ (3 / 2 : ℝ) := by rw [key]; ring

/-- The Riemann–von Mangoldt majorant `log(n+2)²/(n+1)²` is summable. -/
theorem summable_log_sq_div :
    Summable fun n : ℕ => Real.log ((n : ℝ) + 2) ^ 2 / ((n : ℝ) + 1) ^ 2 := by
  have hs : Summable fun n : ℕ => 32 / ((n : ℝ) + 1) ^ (3 / 2 : ℝ) := by
    have h : Summable fun n : ℕ => 1 / (n : ℝ) ^ (3 / 2 : ℝ) :=
      Real.summable_one_div_nat_rpow.mpr (by norm_num)
    simpa using ((summable_nat_add_iff 1).mpr h).mul_left 32
  exact Summable.of_nonneg_of_le (fun n => by positivity) (fun n => log_sq_div_le n) hs

/-! ## Renormalised convergence -/

/-- The renormalised (conjugate-paired) contribution of the zero pair `1/2 ± i·g n`. -/
noncomputable def pairedTerm (g : ℕ → ℝ) (n : ℕ) : ℝ := 1 / (1 / 4 + g n ^ 2)

theorem pairedTerm_pos (g : ℕ → ℝ) (n : ℕ) : 0 < pairedTerm g n := by
  unfold pairedTerm; positivity

/-- **Renormalised zeta-harmonic convergence.**  If the ordinates obey the Riemann–von
Mangoldt-type lower bound `g n ≥ a·(n+1)/log(n+2)` with `a > 0`, then the conjugate-paired
harmonic series `Σ_n 1/(1/4 + g(n)²)` converges. -/
theorem summable_renormalized_of_rvm (a : ℝ) (ha : 0 < a) (g : ℕ → ℝ)
    (hg : ∀ n : ℕ, a * ((n : ℝ) + 1) / Real.log ((n : ℝ) + 2) ≤ g n) :
    Summable (pairedTerm g) := by
  refine Summable.of_nonneg_of_le (fun n => (pairedTerm_pos g n).le) (fun n => ?_)
    ((summable_log_sq_div).mul_left (1 / a ^ 2))
  have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hL : 0 < Real.log ((n : ℝ) + 2) := Real.log_pos (by linarith)
  set c : ℝ := a * ((n : ℝ) + 1) / Real.log ((n : ℝ) + 2) with hc
  have hcpos : 0 < c := by rw [hc]; positivity
  have hcg : c ≤ g n := hg n
  have hcsq : c ^ 2 ≤ g n ^ 2 := by nlinarith
  have hcsq' : c ^ 2 = a ^ 2 * ((n : ℝ) + 1) ^ 2 / Real.log ((n : ℝ) + 2) ^ 2 := by
    rw [hc, div_pow]; ring
  have hmaj : (1 / a ^ 2) * (Real.log ((n : ℝ) + 2) ^ 2 / ((n : ℝ) + 1) ^ 2)
      = 1 / (a ^ 2 * ((n : ℝ) + 1) ^ 2 / Real.log ((n : ℝ) + 2) ^ 2) := by
    field_simp
  unfold pairedTerm
  rw [hmaj]
  refine one_div_le_one_div_of_le (by positivity) ?_
  rw [← hcsq']
  nlinarith

/-- The window sums of the conjugate-paired critical-line zeros with ordinates `g 0, …, g (N-1)`,
as computed by `Core.harmonicSum`, are the partial sums of the renormalised series. -/
theorem harmonicSum_range_eq_sum (g : ℕ → ℝ) (N : ℕ) :
    (harmonicSum (pairedOrdinates ((Multiset.range N).map g))).re
      = ∑ n ∈ Finset.range N, pairedTerm g n := by
  rw [harmonicSum_pairedOrdinates, Complex.ofReal_re, Multiset.map_map]
  rfl

/-- **The renormalised harmonic sum converges.**  Under the Riemann–von Mangoldt-type lower
bound the finite-window conjugate-paired harmonic sums converge to a finite real limit. -/
theorem tendsto_pairedHarmonic (a : ℝ) (ha : 0 < a) (g : ℕ → ℝ)
    (hg : ∀ n : ℕ, a * ((n : ℝ) + 1) / Real.log ((n : ℝ) + 2) ≤ g n) :
    Tendsto (fun N => (harmonicSum (pairedOrdinates ((Multiset.range N).map g))).re)
      atTop (nhds (∑' n, pairedTerm g n)) := by
  have h := (summable_renormalized_of_rvm a ha g hg).hasSum.tendsto_sum_nat
  refine h.congr (fun N => ?_)
  exact (harmonicSum_range_eq_sum g N).symm

/-! ## A quantitative truncation error -/

/-- **Explicit error term under separation.**  If the ordinates are linearly separated,
`g n ≥ a·(n+1)` with `a > 0`, the tail of the renormalised harmonic sum past the `N`-th zero
is at most `1/(a²N)`. -/
theorem tail_bound_of_separated (a : ℝ) (ha : 0 < a) (g : ℕ → ℝ)
    (hg : ∀ n : ℕ, a * ((n : ℝ) + 1) ≤ g n) (N : ℕ) (hN : 1 ≤ N) :
    ∑' n : ℕ, pairedTerm g (n + N) ≤ 1 / (a ^ 2 * N) := by
  have hNR : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  refine Real.tsum_le_of_sum_range_le (fun n => (pairedTerm_pos g _).le) ?_
  intro M
  have step : ∀ n : ℕ, pairedTerm g (n + N)
      ≤ (1 / a ^ 2) * (1 / ((n : ℝ) + N) - 1 / (((n + 1 : ℕ) : ℝ) + N)) := by
    intro n
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    have hb : a * ((n : ℝ) + N + 1) ≤ g (n + N) := by
      have := hg (n + N); push_cast at this ⊢; linarith
    have hap : 0 < a * ((n : ℝ) + N + 1) := by positivity
    have hsq : (a * ((n : ℝ) + N + 1)) ^ 2 ≤ g (n + N) ^ 2 := by nlinarith
    have h1 : (1 / a ^ 2) * (1 / ((n : ℝ) + N) - 1 / (((n + 1 : ℕ) : ℝ) + N))
        = 1 / (a ^ 2 * (((n : ℝ) + N) * ((n : ℝ) + N + 1))) := by
      push_cast; field_simp; ring
    unfold pairedTerm
    rw [h1]
    refine one_div_le_one_div_of_le (by positivity) ?_
    nlinarith
  calc ∑ n ∈ Finset.range M, pairedTerm g (n + N)
      ≤ ∑ n ∈ Finset.range M, (1 / a ^ 2) * (1 / ((n : ℝ) + N) - 1 / (((n + 1 : ℕ) : ℝ) + N)) :=
        Finset.sum_le_sum fun n _ => step n
    _ = (1 / a ^ 2) * ∑ n ∈ Finset.range M,
          (1 / ((n : ℝ) + N) - 1 / (((n + 1 : ℕ) : ℝ) + N)) := by rw [Finset.mul_sum]
    _ = (1 / a ^ 2) * (1 / (((0 : ℕ) : ℝ) + N) - 1 / ((M : ℝ) + N)) := by
        rw [Finset.sum_range_sub' (fun i : ℕ => 1 / ((i : ℝ) + N)) M]
    _ ≤ 1 / (a ^ 2 * N) := by
        have h2 : (0 : ℝ) < (M : ℝ) + N := by linarith [Nat.cast_nonneg (α := ℝ) M]
        have h3 : (0 : ℝ) < 1 / ((M : ℝ) + N) := by positivity
        have h4 : (1 / a ^ 2) * (1 / (N : ℝ) - 1 / ((M : ℝ) + N)) ≤ (1 / a ^ 2) * (1 / (N : ℝ)) :=
          mul_le_mul_of_nonneg_left (by linarith) (by positivity)
        calc (1 / a ^ 2) * (1 / (((0 : ℕ) : ℝ) + N) - 1 / ((M : ℝ) + N))
            = (1 / a ^ 2) * (1 / (N : ℝ) - 1 / ((M : ℝ) + N)) := by norm_num
          _ ≤ (1 / a ^ 2) * (1 / (N : ℝ)) := h4
          _ = 1 / (a ^ 2 * N) := by field_simp

/-- Under linear separation the renormalised series is summable. -/
theorem summable_of_separated (a : ℝ) (ha : 0 < a) (g : ℕ → ℝ)
    (hg : ∀ n : ℕ, a * ((n : ℝ) + 1) ≤ g n) : Summable (pairedTerm g) := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  refine summable_renormalized_of_rvm (a * Real.log 2) (by positivity) g
    fun n => le_trans ?_ (hg n)
  have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hlog : Real.log 2 ≤ Real.log ((n : ℝ) + 2) := Real.log_le_log (by norm_num) (by linarith)
  have hpos : 0 < Real.log ((n : ℝ) + 2) := lt_of_lt_of_le hlog2 hlog
  rw [div_le_iff₀ hpos]
  nlinarith [mul_nonneg (mul_pos ha (show (0:ℝ) < (n : ℝ) + 1 by linarith)).le
    (sub_nonneg.mpr hlog)]

/-! ## Why the renormalisation is necessary -/

/-- **Divergence of the unpaired sum.**  If the ordinates grow at most linearly then
`Σ_n 1/g(n)` diverges: the sum `Σ_ρ 1/ρ` is not absolutely convergent, and the conjugate
pairing of `Core.criticalZero_pair_inv` is genuinely responsible for convergence. -/
theorem not_summable_unpaired (b : ℝ) (g : ℕ → ℝ) (hpos : ∀ n, 0 < g n)
    (hub : ∀ n : ℕ, g n ≤ b * ((n : ℝ) + 1)) : ¬ Summable fun n : ℕ => 1 / g n := by
  intro hS
  have hb0 : 0 < b := by
    have h := hub 0
    have h0 := hpos 0
    norm_num at h
    linarith
  have h1 : Summable fun n : ℕ => 1 / (b * ((n : ℝ) + 1)) :=
    Summable.of_nonneg_of_le (fun n => by
        have hb : 0 < b * ((n : ℝ) + 1) := lt_of_lt_of_le (hpos n) (hub n)
        positivity)
      (fun n => one_div_le_one_div_of_le (hpos n) (hub n)) hS
  have h2 : Summable fun n : ℕ => 1 / ((n : ℝ) + 1) := by
    refine (h1.mul_left b).congr fun n => ?_
    field_simp
  have h3 : Summable fun n : ℕ => ((n : ℝ))⁻¹ := by
    refine (summable_nat_add_iff 1).mp (h2.congr fun n => ?_)
    push_cast; rw [one_div]
  exact Real.not_summable_natCast_inv h3

end ReciprocalZeroHarmonics