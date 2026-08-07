import Applications.AdjacentSumPolytopes.GaussCongruence
import Applications.AdjacentSumPolytopes.SecantSpectrum

/-!
# Aperiodic density: almost every cyclic adjacent-sum point is aperiodic

`GaussCongruence.lean` proved the exact necklace decomposition

`tr(Mⁿ) = ∑_{d ∣ n} aperN s d`,   `n ∣ aperN s n`,

where `aperN s n` counts the cyclic adjacent-sum lattice points of length `n` whose
rotation orbit has exactly `n` elements, and `SecantSpectrum.lean` proved the sharp
asymptotics `tr(Mⁿ) ~ λ₀ⁿ` with `λ₀ = 1/(2 sin(π/(2(2s+3))))` the dominant cosecant
eigenvalue.  This file combines the two: the *periodic* points are counted by the proper
divisors, whose total is at most `n · (s+1)^{⌊n/2⌋}`, and `√(s+1) < λ₀` for every
`s ≥ 1`, so the periodic points are exponentially negligible.

## Main results

* `AdjSum.traceCount` : `tr(Mⁿ)` as a natural number, i.e. the number of cyclic points
  of length `n`.
* `AdjSum.traceCount_le_aperN_add` : **the periodic-point bound**
  `tr(Mⁿ) ≤ aperN s n + n · (s+1)^{⌊n/2⌋}` — a purely combinatorial statement.
* `AdjSum.sqrt_lt_secEigval_zero` : `√(s+1) < λ₀` for `s ≥ 1`, via `sin x < x` and
  `π < 3.15`.
* `AdjSum.tendsto_aperN_div_dominant` : `aperN s n / λ₀ⁿ → 1`.
* `AdjSum.tendsto_aperN_div_traceCount` : **aperiodic density one**,
  `aperN s n / tr(Mⁿ) → 1` for every `s ≥ 1`.
* `AdjSum.tendsto_necklaceCount` : the number of adjacent-sum *necklaces* of length `n`
  is asymptotically `λ₀ⁿ / n`.
* `AdjSum.aperN_zero_slack_eq_zero` : the hypothesis `s ≥ 1` is sharp — for `s = 0` the
  aperiodic counts vanish identically from length `2` on, so the density is `0`, not `1`.

-- !-- Lab Notes -- !--
* **Hypothesis.** (Conjecture 4 of the previous cycle.)  `aperN s n / tr(Mⁿ) → 1`.
* **Experiment.** `s = 1`: `tr(Mⁿ) = 1, 3, 4, 7, 11, 18, 29, 47, 76, 123` (Lucas), and the
  aperiodic counts are `1, 2, 3, 4, 10, 12, 28, 40, 72, 110`, ratios
  `1, .67, .75, .57, .91, .67, .97, .85, .95, .89`, oscillating upward with the divisor
  structure of `n`, exactly as the `n·(s+1)^{n/2}` error term predicts (the dips are at
  highly composite `n`).
* **Analysis.** The error term is *not* `O(λ₁ⁿ)`: it is `O(n λ₀^{n/2})`, dominated by the
  single divisor `n/2`.  This is why the bound needs `√(s+1) < λ₀` rather than the weaker
  spectral gap `|λ₁| < λ₀` used for the trace asymptotics.
* **Critique.** For `s = 0` the transfer matrix is `1×1`, `tr(Mⁿ) = 1`, and every cyclic
  point of length `n ≥ 2` is periodic; the theorem is therefore false at `s = 0` and the
  hypothesis is recorded as a proved boundary case rather than an assumption of
  convenience.
-/

namespace AdjSum

open Finset Filter

/-! ## The trace counts -/

/-- The number of cyclic adjacent-sum lattice points of length `n`, i.e. `tr(Mⁿ)`. -/
def traceCount (s n : ℕ) : ℕ := Matrix.trace (adjMat s ^ n)

lemma traceCount_succ (s q : ℕ) : traceCount s (q + 1) = cycCount s q := by
  rw [traceCount, cycCount, card_cycSet]

/-- Natural-number form of the necklace decomposition. -/
theorem sum_divisors_aperN_nat (s n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, aperN s d = traceCount s n := by
  have h := sum_divisors_aperN s n hn
  have hcast : ((∑ d ∈ n.divisors, aperN s d : ℕ) : ℤ) = (traceCount s n : ℤ) := by
    push_cast
    rw [h, traceSeq, trace_adjMatZ_pow, traceCount]
  exact_mod_cast hcast

/-- Every aperiodic count is at most the total count of the same length. -/
theorem aperN_le_traceCount (s n : ℕ) (hn : 0 < n) : aperN s n ≤ traceCount s n := by
  rw [← sum_divisors_aperN_nat s n hn]
  exact Finset.single_le_sum (f := fun d => aperN s d) (fun _ _ => Nat.zero_le _)
    (Nat.mem_divisors_self n hn.ne')

/-- The total count grows at most like `(s+1)ⁿ`. -/
theorem traceCount_le_pow (s n : ℕ) (hn : 0 < n) : traceCount s n ≤ (s + 1) ^ n := by
  obtain ⟨q, rfl⟩ : ∃ q, n = q + 1 := ⟨n - 1, by omega⟩
  rw [traceCount_succ]
  exact cycCount_upper s q

/-- A proper divisor is at most half of the number. -/
lemma le_half_of_proper_divisor {d n : ℕ} (hd : d ∣ n) (hne : d ≠ n) (hn : 0 < n) :
    d ≤ n / 2 := by
  obtain ⟨k, rfl⟩ := hd
  have hk : 2 ≤ k := by
    rcases Nat.lt_or_ge k 2 with h | h
    · interval_cases k <;> omega
    · exact h
  rw [Nat.le_div_iff_mul_le (by norm_num)]
  exact Nat.mul_le_mul_left d hk

lemma card_divisors_le_self (n : ℕ) : n.divisors.card ≤ n := by
  unfold Nat.divisors
  exact le_trans (Finset.card_filter_le _ _) (by simp)

/-- **The periodic-point bound.**  The cyclic points of length `n` that are *not*
aperiodic number at most `n · (s+1)^{⌊n/2⌋}`: they are grouped by their exact period,
which is a proper divisor of `n`, hence at most `n/2`. -/
theorem traceCount_le_aperN_add (s n : ℕ) (hn : 0 < n) :
    traceCount s n ≤ aperN s n + n * (s + 1) ^ (n / 2) := by
  rw [← sum_divisors_aperN_nat s n hn, ← Finset.add_sum_erase _ _ (Nat.mem_divisors_self n hn.ne')]
  refine Nat.add_le_add_left ?_ _
  have hterm : ∀ d ∈ n.divisors.erase n, aperN s d ≤ (s + 1) ^ (n / 2) := by
    intro d hd
    rw [Finset.mem_erase, Nat.mem_divisors] at hd
    obtain ⟨hne, hdvd, -⟩ := hd
    have hd0 : 0 < d := Nat.pos_of_mem_divisors (Nat.mem_divisors.mpr ⟨hdvd, hn.ne'⟩)
    calc aperN s d ≤ traceCount s d := aperN_le_traceCount s d hd0
      _ ≤ (s + 1) ^ d := traceCount_le_pow s d hd0
      _ ≤ (s + 1) ^ (n / 2) :=
          Nat.pow_le_pow_right (by omega) (le_half_of_proper_divisor hdvd hne hn)
  calc ∑ d ∈ n.divisors.erase n, aperN s d
      ≤ ∑ _d ∈ n.divisors.erase n, (s + 1) ^ (n / 2) := Finset.sum_le_sum hterm
    _ = (n.divisors.erase n).card * (s + 1) ^ (n / 2) := by
        rw [Finset.sum_const, smul_eq_mul]
    _ ≤ n * (s + 1) ^ (n / 2) :=
        Nat.mul_le_mul_right _ (le_trans (Finset.card_erase_le) (card_divisors_le_self n))

/-! ## The spectral comparison `√(s+1) < λ₀` -/

/-- The dominant cosecant eigenvalue dominates `(2s+3)/π`, because `sin x < x`. -/
theorem secEigval_zero_gt (s : ℕ) : (2 * (s : ℝ) + 3) / Real.pi < secEigval s 0 := by
  have hpi := Real.pi_pos
  have hhalf : secAngle s 0 / 2 = Real.pi / (2 * (2 * (s : ℝ) + 3)) := by
    unfold secAngle
    push_cast
    field_simp
    ring
  have hpos : 0 < secAngle s 0 / 2 := by
    have := secAngle_pos (s := s) (t := 0)
    linarith
  have hsin : Real.sin (secAngle s 0 / 2) < secAngle s 0 / 2 := Real.sin_lt hpos
  have hsinpos : 0 < Real.sin (secAngle s 0 / 2) := sin_secAngle_half_pos (Nat.zero_le s)
  have hden : (0 : ℝ) < 2 * (s : ℝ) + 3 := by positivity
  have hsin2 : Real.sin (secAngle s 0 / 2) < Real.pi / (2 * (2 * (s : ℝ) + 3)) := by
    rw [← hhalf]
    exact hsin
  have hlin : Real.sin (secAngle s 0 / 2) * (2 * (2 * (s : ℝ) + 3)) < Real.pi :=
    (lt_div_iff₀ (by positivity)).mp hsin2
  have hval : secEigval s 0 = 1 / (2 * Real.sin (secAngle s 0 / 2)) := by
    unfold secEigval
    rw [pow_zero]
  rw [hval, div_lt_div_iff₀ hpi (by linarith)]
  nlinarith

/-- **The key spectral inequality.**  For positive slack the dominant eigenvalue exceeds
`√(s+1)`, the square root of the trivial upper bound for the growth rate. -/
theorem sqrt_lt_secEigval_zero {s : ℕ} (hs : 1 ≤ s) :
    Real.sqrt ((s : ℝ) + 1) < secEigval s 0 := by
  have hpi := Real.pi_pos
  have hpi2 : Real.pi < 3.15 := Real.pi_lt_d2
  have hs' : (1 : ℝ) ≤ (s : ℝ) := by exact_mod_cast hs
  have hquot : (0 : ℝ) < (2 * (s : ℝ) + 3) / Real.pi := by positivity
  have hpisq : Real.pi ^ 2 < 9.9225 := by nlinarith
  have hsq : Real.sqrt ((s : ℝ) + 1) < (2 * (s : ℝ) + 3) / Real.pi := by
    rw [Real.sqrt_lt' hquot, div_pow, lt_div_iff₀ (by positivity)]
    nlinarith [sq_nonneg ((s : ℝ) - 1)]
  exact lt_trans hsq (secEigval_zero_gt s)

/-! ## The density-one theorem -/

/-- `(s+1)^{⌊n/2⌋} ≤ (√(s+1))ⁿ`. -/
lemma pow_half_le_sqrt_pow (s n : ℕ) :
    ((s : ℝ) + 1) ^ (n / 2) ≤ (Real.sqrt ((s : ℝ) + 1)) ^ n := by
  have hs0 : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
  have hb : (1 : ℝ) ≤ (s : ℝ) + 1 := by linarith
  have hA : (0 : ℝ) ≤ ((s : ℝ) + 1) ^ (n / 2) := by positivity
  have hB : (0 : ℝ) ≤ (Real.sqrt ((s : ℝ) + 1)) ^ n := by positivity
  have hB2 : ((Real.sqrt ((s : ℝ) + 1)) ^ n) ^ 2 = ((s : ℝ) + 1) ^ n := by
    rw [← pow_mul, mul_comm, pow_mul, Real.sq_sqrt (by linarith)]
  have hA2 : (((s : ℝ) + 1) ^ (n / 2)) ^ 2 ≤ ((s : ℝ) + 1) ^ n := by
    rw [← pow_mul]
    exact pow_le_pow_right₀ hb (by omega)
  have hkey := Real.sqrt_le_sqrt (le_trans hA2 (le_of_eq hB2.symm))
  rwa [Real.sqrt_sq hA, Real.sqrt_sq hB] at hkey

/-- The trace counts, reindexed by length, are asymptotic to `λ₀ⁿ`. -/
theorem tendsto_traceCount_div_dominant (s : ℕ) :
    Tendsto (fun n : ℕ => (traceCount s n : ℝ) / (secEigval s 0) ^ n) atTop (nhds 1) := by
  have hbase := tendsto_card_cycSet_div_dominant s
  have hshift : Tendsto (fun n : ℕ => n - 1) atTop atTop := by
    apply Filter.tendsto_atTop_atTop.2
    intro b
    exact ⟨b + 1, fun a ha => by omega⟩
  have hcomp := hbase.comp hshift
  refine hcomp.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 1] with n hn
  have hn' : n - 1 + 1 = n := by omega
  have hval : traceCount s n = (cycSet s (n - 1)).card := by
    conv_lhs => rw [← hn']
    rw [traceCount_succ, cycCount]
  simp only [Function.comp_apply, hn', hval]

/-- **Aperiodic counts have the dominant exponential asymptotics.** -/
theorem tendsto_aperN_div_dominant {s : ℕ} (hs : 1 ≤ s) :
    Tendsto (fun n : ℕ => (aperN s n : ℝ) / (secEigval s 0) ^ n) atTop (nhds 1) := by
  have hlam : 0 < secEigval s 0 := secEigval_zero_pos s
  set r : ℝ := Real.sqrt ((s : ℝ) + 1) / secEigval s 0 with hr
  have hr0 : 0 ≤ r := by positivity
  have hr1 : r < 1 := by
    rw [hr, div_lt_one hlam]
    exact sqrt_lt_secEigval_zero hs
  -- error term
  have herr : ∀ n : ℕ, 1 ≤ n →
      ‖(aperN s n : ℝ) / (secEigval s 0) ^ n - (traceCount s n : ℝ) / (secEigval s 0) ^ n‖
        ≤ (s : ℝ) * ((n : ℝ) * r ^ n) := by
    intro n hn
    have hpow : (0 : ℝ) < (secEigval s 0) ^ n := by positivity
    have hle1 : (aperN s n : ℝ) ≤ (traceCount s n : ℝ) := by
      exact_mod_cast aperN_le_traceCount s n hn
    have hle2 : (traceCount s n : ℝ) ≤ (aperN s n : ℝ) + (n : ℝ) * ((s : ℝ) + 1) ^ (n / 2) := by
      have := traceCount_le_aperN_add s n hn
      have hcast : ((traceCount s n : ℕ) : ℝ)
          ≤ ((aperN s n + n * (s + 1) ^ (n / 2) : ℕ) : ℝ) := by exact_mod_cast this
      push_cast at hcast
      exact hcast
    have hsqrt : (n : ℝ) * ((s : ℝ) + 1) ^ (n / 2)
        ≤ (n : ℝ) * (Real.sqrt ((s : ℝ) + 1)) ^ n :=
      mul_le_mul_of_nonneg_left (pow_half_le_sqrt_pow s n) (by positivity)
    have hdiff : |(aperN s n : ℝ) / (secEigval s 0) ^ n
        - (traceCount s n : ℝ) / (secEigval s 0) ^ n|
        ≤ ((n : ℝ) * (Real.sqrt ((s : ℝ) + 1)) ^ n) / (secEigval s 0) ^ n := by
      rw [div_sub_div_same, abs_div, abs_of_pos hpow]
      gcongr
      rw [abs_le]
      constructor <;> linarith
    have hfinal : ((n : ℝ) * (Real.sqrt ((s : ℝ) + 1)) ^ n) / (secEigval s 0) ^ n
        = (n : ℝ) * r ^ n := by
      rw [hr, div_pow, mul_div_assoc]
    have hs1 : (1 : ℝ) ≤ (s : ℝ) := by exact_mod_cast hs
    have hnn : (0 : ℝ) ≤ (n : ℝ) * r ^ n := by positivity
    rw [Real.norm_eq_abs]
    calc |(aperN s n : ℝ) / (secEigval s 0) ^ n - (traceCount s n : ℝ) / (secEigval s 0) ^ n|
        ≤ (n : ℝ) * r ^ n := by rw [← hfinal]; exact hdiff
      _ ≤ (s : ℝ) * ((n : ℝ) * r ^ n) := le_mul_of_one_le_left hnn hs1
  have hzero : Tendsto (fun n : ℕ => (s : ℝ) * ((n : ℝ) * r ^ n)) atTop (nhds 0) := by
    have := tendsto_self_mul_const_pow_of_lt_one hr0 hr1
    simpa using this.const_mul (s : ℝ)
  have hdiff0 : Tendsto
      (fun n : ℕ => (aperN s n : ℝ) / (secEigval s 0) ^ n
        - (traceCount s n : ℝ) / (secEigval s 0) ^ n) atTop (nhds 0) := by
    refine squeeze_zero_norm' ?_ hzero
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn using herr n hn
  have := hdiff0.add (tendsto_traceCount_div_dominant s)
  simpa using this

/-- **Aperiodic density one** (Conjecture 4 of the previous cycle).  For every positive
slack, the proportion of cyclic adjacent-sum lattice points of length `n` whose rotation
orbit is free tends to `1`. -/
theorem tendsto_aperN_div_traceCount {s : ℕ} (hs : 1 ≤ s) :
    Tendsto (fun n : ℕ => (aperN s n : ℝ) / (traceCount s n : ℝ)) atTop (nhds 1) := by
  have hlam : 0 < secEigval s 0 := secEigval_zero_pos s
  have hnum := tendsto_aperN_div_dominant hs
  have hden := tendsto_traceCount_div_dominant s
  have hquot := hnum.div hden one_ne_zero
  rw [div_one] at hquot
  refine hquot.congr (fun n => ?_)
  have hpow : ((secEigval s 0) ^ n) ≠ 0 := by positivity
  rcases eq_or_ne ((traceCount s n : ℝ)) 0 with h0 | h0
  · have hz : traceCount s n = 0 := by exact_mod_cast h0
    rw [Pi.div_apply, hz]
    simp
  · have hcancel : (aperN s n : ℝ) / (secEigval s 0) ^ n
        / ((traceCount s n : ℝ) / (secEigval s 0) ^ n)
        = (aperN s n : ℝ) / (traceCount s n : ℝ) := by
      field_simp
    simpa [Pi.div_apply] using hcancel

/-! ## Necklaces -/

/-- The number of *necklaces*: aperiodic cyclic points of length `n` up to rotation. -/
noncomputable def necklaceCount (s n : ℕ) : ℕ := aperN s n / n

lemma necklaceCount_mul (s n : ℕ) : n * necklaceCount s n = aperN s n :=
  Nat.mul_div_cancel' (dvd_aperN s n)

/-- **Necklace asymptotics.**  The number of adjacent-sum necklaces of length `n` is
asymptotically `λ₀ⁿ / n`. -/
theorem tendsto_necklaceCount {s : ℕ} (hs : 1 ≤ s) :
    Tendsto (fun n : ℕ => (n : ℝ) * (necklaceCount s n : ℝ) / (secEigval s 0) ^ n)
      atTop (nhds 1) := by
  refine (tendsto_aperN_div_dominant hs).congr (fun n => ?_)
  have : ((n * necklaceCount s n : ℕ) : ℝ) = ((aperN s n : ℕ) : ℝ) := by
    rw [necklaceCount_mul]
  push_cast at this
  rw [this]

/-! ## The boundary case `s = 0` -/

theorem adjMat_zero_eq_one : adjMat 0 = 1 := by
  ext a b
  fin_cases a
  fin_cases b
  simp [adjMat]

theorem traceCount_zero_slack (n : ℕ) : traceCount 0 n = 1 := by
  rw [traceCount, adjMat_zero_eq_one, one_pow]
  simp

theorem aperN_zero_slack_one : aperN 0 1 = 1 := by
  have h := sum_divisors_aperN_nat 0 1 Nat.one_pos
  rw [traceCount_zero_slack] at h
  simpa using h

/-- **Sharpness of the hypothesis `s ≥ 1`.**  For zero slack there is a unique cyclic point
of each length (the all-zero one), it is periodic as soon as the length exceeds `1`, and
so the aperiodic density is `0` rather than `1`. -/
theorem aperN_zero_slack_eq_zero (n : ℕ) (hn : 2 ≤ n) : aperN 0 n = 0 := by
  have hn0 : 0 < n := by omega
  have hsub : ({1, n} : Finset ℕ) ⊆ n.divisors := by
    intro d hd
    rw [Finset.mem_insert, Finset.mem_singleton] at hd
    rcases hd with h | h
    · rw [h]
      exact Nat.one_mem_divisors.mpr hn0.ne'
    · rw [h]
      exact Nat.mem_divisors_self n hn0.ne'
  have hle : ∑ d ∈ ({1, n} : Finset ℕ), aperN 0 d ≤ ∑ d ∈ n.divisors, aperN 0 d :=
    Finset.sum_le_sum_of_subset hsub
  rw [sum_divisors_aperN_nat 0 n hn0, traceCount_zero_slack,
    Finset.sum_pair (by omega : (1 : ℕ) ≠ n), aperN_zero_slack_one] at hle
  omega

/-- The zero-slack density is identically `0` from length `2` on, in contrast with
`tendsto_aperN_div_traceCount`. -/
theorem aperN_div_traceCount_zero_slack (n : ℕ) (hn : 2 ≤ n) :
    (aperN 0 n : ℝ) / (traceCount 0 n : ℝ) = 0 := by
  rw [aperN_zero_slack_eq_zero n hn]
  simp

end AdjSum