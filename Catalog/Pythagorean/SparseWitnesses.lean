import Pythagorean.DigitStatistics

/-!
# Two irrational witnesses with opposite digit statistics

We construct two explicit real numbers whose decimal expansions we control completely:

* `Pyth.sparseReal = 0.1101000100000001000…` — digit `1` exactly at the positions `2^i - 1`,
  digit `0` everywhere else.  It is irrational, and the density of its nonzero digits is `0`.
* `Pyth.denseReal = sparseReal + 1/9` — digit `2` at the positions `2^i - 1`, digit `1`
  everywhere else.  It is irrational, and *all* of its digits are nonzero.

Both numbers are irrational, so irrationality alone constrains the asymptotic digit
statistics not at all: it is compatible with nonzero-digit density `0` and with density `1`.
Neither number is simply normal.

The lacunary positions `2^i - 1` are what makes both the irrationality proof (arbitrarily long
runs of zeros, `Pyth.irrational_ofDigits_of_gaps`) and the counting bound
(`Pyth.card_powTwoSucc_le`) work.
-/

namespace Pyth

open Filter Real

/-! ## The lacunary position set -/

/-- `IsPowTwoSucc m` says that `m + 1` is a power of two, i.e. `m ∈ {0,1,3,7,15,…}`. -/
def IsPowTwoSucc (m : ℕ) : Prop := 2 ^ (Nat.log 2 (m + 1)) = m + 1

instance : DecidablePred IsPowTwoSucc := fun m => by
  unfold IsPowTwoSucc; infer_instance

theorem isPowTwoSucc_iff (m : ℕ) : IsPowTwoSucc m ↔ ∃ i, 2 ^ i = m + 1 := by
  constructor
  · intro h; exact ⟨_, h⟩
  · rintro ⟨i, hi⟩
    unfold IsPowTwoSucc
    rw [← hi, Nat.log_pow (by norm_num)]

theorem isPowTwoSucc_pow (M : ℕ) : IsPowTwoSucc (2 ^ M - 1) := by
  rw [isPowTwoSucc_iff]
  refine ⟨M, ?_⟩
  have : 1 ≤ 2 ^ M := Nat.one_le_two_pow
  omega

/-- Between two consecutive powers of two there is no power of two. -/
theorem not_isPowTwoSucc_of_between {N m : ℕ} (h1 : 2 ^ N < m + 1) (h2 : m + 1 < 2 ^ (N + 1)) :
    ¬ IsPowTwoSucc m := by
  rw [isPowTwoSucc_iff]
  rintro ⟨i, hi⟩
  rw [← hi] at h1 h2
  have hN : N < i := (Nat.pow_lt_pow_iff_right (by norm_num)).mp h1
  have hi' : i < N + 1 := (Nat.pow_lt_pow_iff_right (by norm_num)).mp h2
  omega

/-- The number of lacunary positions below `M` is at most `log₂ M + 1`. -/
theorem card_powTwoSucc_le (M : ℕ) :
    ((Finset.range M).filter IsPowTwoSucc).card ≤ Nat.log 2 M + 1 := by
  rcases Nat.eq_zero_or_pos M with hM | hM
  · subst hM; simp
  have hcard : ((Finset.range M).filter IsPowTwoSucc).card
      ≤ (Finset.range (Nat.log 2 M + 1)).card := by
    refine Finset.card_le_card_of_injOn (fun m => Nat.log 2 (m + 1))
      (fun m hm => ?_) (fun m hm m' hm' hmm' => ?_)
    · obtain ⟨hmM0, hpow⟩ := Finset.mem_filter.mp (Finset.mem_coe.mp hm)
      have hmM : m < M := Finset.mem_range.mp hmM0
      have hle : 2 ^ (Nat.log 2 (m + 1)) ≤ M := by
        rw [show 2 ^ (Nat.log 2 (m + 1)) = m + 1 from hpow]; omega
      have hlog : Nat.log 2 (m + 1) ≤ Nat.log 2 M :=
        (Nat.le_log_iff_pow_le (by norm_num) (by omega)).mpr hle
      show Nat.log 2 (m + 1) ∈ Finset.range (Nat.log 2 M + 1)
      exact Finset.mem_range.mpr (by omega)
    · simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range] at hm hm'
      have h1 : 2 ^ (Nat.log 2 (m + 1)) = m + 1 := hm.2
      have h2 : 2 ^ (Nat.log 2 (m' + 1)) = m' + 1 := hm'.2
      have hmm'' : Nat.log 2 (m + 1) = Nat.log 2 (m' + 1) := hmm'
      rw [hmm''] at h1
      omega
  simpa using hcard

/-! ## The sparse witness -/

/-- The lacunary digit sequence `1` at positions `2^i - 1`, `0` elsewhere. -/
def sparseSeq (m : ℕ) : Fin 10 := if IsPowTwoSucc m then 1 else 0

theorem sparseSeq_le (m : ℕ) : (sparseSeq m : ℕ) ≤ 8 := by
  unfold sparseSeq; split <;> simp

theorem sparseSeq_eq_zero_of_not {m : ℕ} (h : ¬ IsPowTwoSucc m) : (sparseSeq m : ℕ) = 0 := by
  simp [sparseSeq, h]

theorem sparseSeq_ne_zero_of {m : ℕ} (h : IsPowTwoSucc m) : (sparseSeq m : ℕ) ≠ 0 := by
  simp [sparseSeq, h]

/-- `0.1101000100000001…`: the real number with digit `1` exactly at positions `2^i - 1`. -/
noncomputable def sparseReal : ℝ := Real.ofDigits sparseSeq

theorem digits_sparseReal : Real.digits sparseReal 10 = sparseSeq :=
  digits_ofDigits sparseSeq sparseSeq_le

theorem sparseReal_nonneg : 0 ≤ sparseReal := Real.ofDigits_nonneg _

theorem sparseReal_lt_one : sparseReal < 1 :=
  ofDigits_lt_one_of_le_eight _ sparseSeq_le

/-- **The sparse witness is irrational.**  Its digit sequence has arbitrarily long runs of
zeros yet never terminates, so it cannot be eventually periodic — indeed it is irrational by
the Liouville-type gap criterion. -/
theorem irrational_sparseReal : Irrational sparseReal := by
  refine irrational_ofDigits_of_gaps sparseSeq sparseSeq_le (fun L => ?_)
  refine ⟨2 ^ (L + 2), ?_, 2 ^ (2 ^ (L + 2) + L) - 1, ?_, ?_⟩
  · intro j hj1 hj2
    refine sparseSeq_eq_zero_of_not (not_isPowTwoSucc_of_between (N := L + 2) (by omega) ?_)
    have hL : L + 1 < 2 ^ (L + 1) := Nat.lt_two_pow_self
    have h2 : 2 ^ (L + 2) = 2 * 2 ^ (L + 1) := by ring
    have h3 : 2 ^ (L + 3) = 2 * 2 ^ (L + 2) := by ring
    have h4 : (2:ℕ) ^ (L + 1) ≤ 2 ^ (L + 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  · have h := Nat.lt_two_pow_self (n := 2 ^ (L + 2) + L)
    omega
  · exact sparseSeq_ne_zero_of (isPowTwoSucc_pow _)

/-! ## The dense witness -/

/-- The digit sequence `2` at positions `2^i - 1`, `1` elsewhere. -/
def denseSeq (m : ℕ) : Fin 10 := if IsPowTwoSucc m then 2 else 1

theorem denseSeq_le (m : ℕ) : (denseSeq m : ℕ) ≤ 8 := by
  unfold denseSeq; split <;> simp

theorem denseSeq_ne_zero (m : ℕ) : denseSeq m ≠ 0 := by
  unfold denseSeq; split <;> decide

theorem denseSeq_val (m : ℕ) : (denseSeq m : ℕ) = (sparseSeq m : ℕ) + 1 := by
  unfold denseSeq sparseSeq; split <;> simp

/-- `denseReal = 0.2212111211111112…`. -/
noncomputable def denseReal : ℝ := Real.ofDigits denseSeq

theorem digits_denseReal : Real.digits denseReal 10 = denseSeq :=
  digits_ofDigits denseSeq denseSeq_le

theorem denseReal_nonneg : 0 ≤ denseReal := Real.ofDigits_nonneg _

theorem denseReal_lt_one : denseReal < 1 :=
  ofDigits_lt_one_of_le_eight _ denseSeq_le

/-- The two witnesses differ by the rational number `1/9 = 0.111…`. -/
theorem denseReal_eq : denseReal = sparseReal + 1 / 9 := by
  have hsum1 : Summable (Real.ofDigitsTerm sparseSeq) := Real.summable_ofDigitsTerm
  have hsum2 : Summable (fun n : ℕ => ((10:ℝ) ^ (n + 1))⁻¹) := by
    have : Summable (fun n : ℕ => (10:ℝ)⁻¹ * ((10:ℝ)⁻¹) ^ n) :=
      (summable_geometric_of_lt_one (by norm_num) (by norm_num)).mul_left _
    refine this.congr (fun n => ?_)
    rw [← inv_pow, ← pow_succ']
  have hterm : ∀ n, Real.ofDigitsTerm denseSeq n
      = Real.ofDigitsTerm sparseSeq n + ((10:ℝ) ^ (n + 1))⁻¹ := by
    intro n
    simp only [Real.ofDigitsTerm, denseSeq_val]
    push_cast
    ring
  have hgeom : ∑' n : ℕ, ((10:ℝ) ^ (n + 1))⁻¹ = 1 / 9 := by
    have : ∀ n : ℕ, ((10:ℝ) ^ (n + 1))⁻¹ = (10:ℝ)⁻¹ * ((10:ℝ)⁻¹) ^ n := by
      intro n; rw [← inv_pow, ← pow_succ']
    rw [tsum_congr this, tsum_mul_left, tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
    norm_num
  calc denseReal = ∑' n, Real.ofDigitsTerm denseSeq n := rfl
    _ = ∑' n, (Real.ofDigitsTerm sparseSeq n + ((10:ℝ) ^ (n + 1))⁻¹) := tsum_congr hterm
    _ = (∑' n, Real.ofDigitsTerm sparseSeq n) + ∑' n : ℕ, ((10:ℝ) ^ (n + 1))⁻¹ :=
        hsum1.tsum_add hsum2
    _ = sparseReal + 1 / 9 := by rw [hgeom]; rfl

/-- **The dense witness is irrational** — it differs from the sparse one by a rational. -/
theorem irrational_denseReal : Irrational denseReal := by
  rw [denseReal_eq]
  have : ((1 / 9 : ℚ) : ℝ) = (1 / 9 : ℝ) := by norm_num
  simpa [this] using irrational_sparseReal.add_ratCast (1 / 9 : ℚ)

/-! ## Density criteria -/

/-- If the nonzero digits below `M` are at most `n + log₂ M + 1` in number, the density of
nonzero digits is zero. -/
theorem nonzeroDensity_zero_of_log_bound {y : ℝ} {n : ℕ}
    (h : ∀ M : ℕ, nonzeroCount y M ≤ n + (Nat.log 2 M + 1)) : NonzeroDensity y 0 := by
  have hn : Tendsto (fun M : ℕ => ((n : ℝ) + 1) / M) atTop (nhds 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have hlog := tendsto_natLog_div_atTop
  have hsum : Tendsto (fun M : ℕ => (Nat.log 2 M : ℝ) / M + ((n : ℝ) + 1) / M) atTop
      (nhds (0 + 0)) := hlog.add hn
  rw [add_zero] at hsum
  refine squeeze_zero' ?_ ?_ hsum
  · filter_upwards [eventually_gt_atTop 0] with M hM
    positivity
  · filter_upwards [eventually_gt_atTop 0] with M hM
    have hM0 : (0:ℝ) < M := by exact_mod_cast hM
    have h1 : (nonzeroCount y M : ℝ) ≤ (Nat.log 2 M : ℝ) + ((n : ℝ) + 1) := by
      have := h M
      have : (nonzeroCount y M : ℝ) ≤ ((n + (Nat.log 2 M + 1) : ℕ) : ℝ) := by exact_mod_cast this
      push_cast at this
      linarith
    rw [← add_div]
    gcongr

/-- If digit `0` occurs at most `n` times in total, the density of nonzero digits is one. -/
theorem nonzeroDensity_one_of_zero_bound {y : ℝ} {n : ℕ}
    (h : ∀ M : ℕ, digitCount y 0 M ≤ n) : NonzeroDensity y 1 := by
  have hzero : Tendsto (fun M : ℕ => (digitCount y 0 M : ℝ) / M) atTop (nhds 0) := by
    have hn : Tendsto (fun M : ℕ => (n : ℝ) / M) atTop (nhds 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    refine squeeze_zero' ?_ ?_ hn
    · filter_upwards [eventually_gt_atTop 0] with M hM
      positivity
    · filter_upwards [eventually_gt_atTop 0] with M hM
      have hM0 : (0:ℝ) < M := by exact_mod_cast hM
      have h1 : (digitCount y 0 M : ℝ) ≤ (n : ℝ) := by exact_mod_cast h M
      gcongr
  have hEq : ∀ᶠ M : ℕ in atTop,
      (nonzeroCount y M : ℝ) / M = 1 - (digitCount y 0 M : ℝ) / M := by
    filter_upwards [eventually_gt_atTop 0] with M hM
    have hMR : (M : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    have h3 := digitCount_zero_add_nonzeroCount y M
    have h4 : ((digitCount y 0 M : ℝ)) + (nonzeroCount y M : ℝ) = (M : ℝ) := by exact_mod_cast h3
    field_simp
    linarith
  have h5 : Tendsto (fun M : ℕ => 1 - (digitCount y 0 M : ℝ) / M) atTop (nhds (1 - 0)) :=
    tendsto_const_nhds.sub hzero
  rw [sub_zero] at h5
  exact h5.congr' (hEq.mono fun M hM => hM.symm)

end Pyth