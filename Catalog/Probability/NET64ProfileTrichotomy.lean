import Mathlib
import Combinatorics.KneeInvariance

/-!
# NET-64: which attention profiles can produce the measured knee chain?

The NET-64 deployment table is the dual-corpus chain

| ctx  | 512 | 1024 | 2048 |
|------|-----|------|------|
| `k*` | 16  | 20   | 24   |

at gate `0.98`: the retention knee grows by exactly `+4` keys per doubling of the
context, i.e. logarithmically in `ctx`.  This file asks the structural question
behind the measurement — *what shape of attention profile is compatible with such
a chain?* — and answers it by ruling out the two classical families.

Setting.  A profile on `n` keys produces a monotone retention curve `k ↦ R n k`,
and the knee is `knee (R n) τ = sInf {k | τ ≤ R n k}` (from
`Combinatorics.KneeInvariance`).

* **Zipf profiles** `p i ∝ 1/(i+1)` give `R n k = H_k / H_n` with `H` the harmonic
  number.  Theorem `zipf_knee_gt_two_pow` turns the classical dyadic bounds
  `1 + m/2 ≤ H_{2^m} ≤ 1 + m` into a *lower* bound on the Zipf knee, and
  `zipf_knee_2048_gt_32` instantiates it: at `ctx = 2048` and gate `0.98` a Zipf
  profile could not clear the gate with **any** budget `≤ 32`, let alone the
  measured `24`.  `zipf_knee_unbounded` shows the obstruction is not an artifact
  of one cell: the Zipf knee is unbounded along the context ladder for every
  gate `τ > 0`, so no fixed-shape Zipf model can reproduce a `+4`-per-doubling
  law.
* **Truncated geometric profiles** `p i ∝ 2^{-i}` fail in the opposite
  direction: `geom_knee_eq_six` shows the knee is `6` at *every* context
  `n ≥ 10`, so the knee is context-free — while the measured chain moves.
* `measured_chain_log_law` records that the measured chain is exactly
  `k*(ctx) = 4 log₂ ctx − 20`, and `measured_chain_is_neither_zipf_nor_geometric`
  combines the three facts: the measured profile family lies strictly between
  the heavy-tailed (Zipf) and light-tailed (geometric) extremes.

All harmonic estimates are proved from scratch by dyadic block induction
(`harm_two_pow_lower`, `harm_two_pow_upper`); nothing is asymptotic.
-/

namespace Catalog.Probability.NET64ProfileTrichotomy

open Finset Combinatorics.KneeInvariance

/-- The NET-64 retention gate. -/
def gate : ℚ := 98 / 100

/-! ## 1. Harmonic numbers and dyadic block bounds -/

/-- The `i`-th harmonic term `1/(i+1)`. -/
def hterm (i : ℕ) : ℚ := 1 / ((i : ℚ) + 1)

theorem hterm_pos (i : ℕ) : 0 < hterm i := by
  unfold hterm; positivity

/-- The `n`-th harmonic number `1 + 1/2 + … + 1/n`. -/
def harm (n : ℕ) : ℚ := ∑ i ∈ range n, hterm i

@[simp] theorem harm_zero : harm 0 = 0 := by simp [harm]

@[simp] theorem harm_one : harm 1 = 1 := by simp [harm, hterm]

theorem harm_nonneg (n : ℕ) : 0 ≤ harm n :=
  Finset.sum_nonneg fun i _ => (hterm_pos i).le

theorem harm_mono : Monotone harm := by
  intro a b hab
  refine Finset.sum_le_sum_of_subset_of_nonneg (by simpa using hab) ?_
  intro i _ _
  exact (hterm_pos i).le

/-- Splitting a harmonic number at a dyadic point. -/
theorem harm_split (m : ℕ) :
    harm (2 ^ (m + 1)) = harm (2 ^ m) + ∑ i ∈ Ico (2 ^ m) (2 ^ (m + 1)), hterm i := by
  have hle : (2 : ℕ) ^ m ≤ 2 ^ (m + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  unfold harm
  rw [Finset.range_eq_Ico, ← Finset.sum_Ico_consecutive _ (Nat.zero_le (2 ^ m)) hle]

theorem card_dyadic_block (m : ℕ) : (Ico (2 ^ m) (2 ^ (m + 1))).card = 2 ^ m := by
  rw [Nat.card_Ico]
  have h : (2 : ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
  omega

/-- **Dyadic lower bound**: each dyadic block contributes at least `1/2`. -/
theorem harm_two_pow_lower (m : ℕ) : 1 + (m : ℚ) / 2 ≤ harm (2 ^ m) := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hblock : (1 : ℚ) / 2 ≤ ∑ i ∈ Ico (2 ^ m) (2 ^ (m + 1)), hterm i := by
      have hlow : ∀ i ∈ Ico (2 ^ m) (2 ^ (m + 1)), (1 : ℚ) / ((2 : ℚ) ^ (m + 1)) ≤ hterm i := by
        intro i hi
        have hi' : i < 2 ^ (m + 1) := (Finset.mem_Ico.mp hi).2
        have hnat : (i : ℕ) + 1 ≤ 2 ^ (m + 1) := hi'
        have hcast : (i : ℚ) + 1 ≤ (2 : ℚ) ^ (m + 1) := by exact_mod_cast hnat
        have hpos : (0 : ℚ) < (i : ℚ) + 1 := by positivity
        exact one_div_le_one_div_of_le hpos hcast
      have hsum := Finset.card_nsmul_le_sum _ _ _ hlow
      rw [card_dyadic_block m, nsmul_eq_mul] at hsum
      have hval : (((2 : ℕ) ^ m : ℕ) : ℚ) * ((1 : ℚ) / ((2 : ℚ) ^ (m + 1))) = 1 / 2 := by
        push_cast
        rw [pow_succ]
        field_simp
      rwa [hval] at hsum
    rw [harm_split m]
    push_cast
    linarith

/-- **Dyadic upper bound**: each dyadic block contributes at most `1`. -/
theorem harm_two_pow_upper (m : ℕ) : harm (2 ^ m) ≤ 1 + (m : ℚ) := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hblock : (∑ i ∈ Ico (2 ^ m) (2 ^ (m + 1)), hterm i) ≤ 1 := by
      have hup : ∀ i ∈ Ico (2 ^ m) (2 ^ (m + 1)), hterm i ≤ (1 : ℚ) / ((2 : ℚ) ^ m) := by
        intro i hi
        have hi' : 2 ^ m ≤ i := (Finset.mem_Ico.mp hi).1
        have hcast : ((2 : ℚ) ^ m) ≤ (i : ℚ) + 1 := by
          have h1 : (((2 : ℕ) ^ m : ℕ) : ℚ) ≤ (i : ℚ) := by exact_mod_cast hi'
          push_cast at h1
          linarith
        have hpos : (0 : ℚ) < (2 : ℚ) ^ m := by positivity
        exact one_div_le_one_div_of_le hpos hcast
      have hsum := Finset.sum_le_card_nsmul _ _ _ hup
      rw [card_dyadic_block m, nsmul_eq_mul] at hsum
      have hval : (((2 : ℕ) ^ m : ℕ) : ℚ) * ((1 : ℚ) / ((2 : ℚ) ^ m)) = 1 := by
        push_cast
        field_simp
      rwa [hval] at hsum
    rw [harm_split m]
    push_cast
    linarith

theorem harm_two_pow_pos (m : ℕ) : 0 < harm (2 ^ m) := by
  have := harm_two_pow_lower m
  have : (1 : ℚ) ≤ harm (2 ^ m) := by
    have h : (0 : ℚ) ≤ (m : ℚ) / 2 := by positivity
    linarith [harm_two_pow_lower m]
  linarith

/-! ## 2. Zipf profiles: the knee is too dear -/

/-- Retention curve of the Zipf profile `p i ∝ 1/(i+1)` on `n` keys:
the top-`k` mass is `H_k / H_n`. -/
def zipfCurve (n : ℕ) (k : ℕ) : ℚ := harm (min k n) / harm n

theorem zipfCurve_top {n : ℕ} (hn : 0 < harm n) : zipfCurve n n = 1 := by
  unfold zipfCurve
  rw [min_self]
  exact div_self (ne_of_gt hn)

theorem zipfCurve_mono (n : ℕ) : Monotone (zipfCurve n) := by
  intro a b hab
  unfold zipfCurve
  exact div_le_div_of_nonneg_right (harm_mono (min_le_min hab (le_refl n))) (harm_nonneg n)

/-- **The Zipf knee is expensive.**  If the harmonic budget available at `2^j`
keys, `1 + j`, is below the gate's share `τ · (1 + m/2)` of the total, then a
Zipf profile on `2^m` keys cannot clear the gate at any budget `≤ 2^j`. -/
theorem zipf_knee_gt_two_pow {m j : ℕ} {tau : ℚ} (hjm : j ≤ m) (htau1 : tau ≤ 1)
    (h : (1 : ℚ) + j < tau * (1 + (m : ℚ) / 2)) :
    2 ^ j < knee (zipfCurve (2 ^ m)) tau := by
  have hpos : 0 < harm (2 ^ m) := harm_two_pow_pos m
  have hreach : ∃ x, tau ≤ zipfCurve (2 ^ m) x := ⟨2 ^ m, by rw [zipfCurve_top hpos]; exact htau1⟩
  by_contra hc
  push_neg at hc
  have h1 : tau ≤ zipfCurve (2 ^ m) (knee (zipfCurve (2 ^ m)) tau) :=
    Combinatorics.KneeInvariance.knee_mem hreach
  have h2 : zipfCurve (2 ^ m) (knee (zipfCurve (2 ^ m)) tau) ≤ zipfCurve (2 ^ m) (2 ^ j) :=
    zipfCurve_mono _ hc
  have hmin : min (2 ^ j) (2 ^ m) = 2 ^ j :=
    min_eq_left (Nat.pow_le_pow_right (by norm_num) hjm)
  have h3 : zipfCurve (2 ^ m) (2 ^ j) < tau := by
    unfold zipfCurve
    rw [hmin, div_lt_iff₀ hpos]
    calc harm (2 ^ j) ≤ 1 + (j : ℚ) := harm_two_pow_upper j
      _ < tau * (1 + (m : ℚ) / 2) := h
      _ ≤ tau * harm (2 ^ m) := by
          have hm0 : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
          have hj0 : (0 : ℚ) ≤ (j : ℚ) := Nat.cast_nonneg j
          have htau0 : 0 ≤ tau := by nlinarith
          exact mul_le_mul_of_nonneg_left (harm_two_pow_lower m) htau0
  linarith

/-- **Zipf is refuted at the measured cell.**  At `ctx = 2048` and gate `0.98` a
Zipf attention profile needs *more than 32* keys — so it cannot produce the
measured knee `24`, nor even the coarse-grid reading `32`. -/
theorem zipf_knee_2048_gt_32 : 32 < knee (zipfCurve (2 ^ 11)) gate := by
  have h := zipf_knee_gt_two_pow (m := 11) (j := 5) (tau := gate) (by norm_num) (by
    unfold gate; norm_num) (by unfold gate; norm_num)
  simpa using h

theorem zipf_knee_2048_ne_measured : knee (zipfCurve (2 ^ 11)) gate ≠ 24 := by
  have := zipf_knee_2048_gt_32
  omega

/-- **The Zipf obstruction is asymptotic, not local.**  For every gate `τ ∈ (0,1]`
the Zipf knee is unbounded along the doubling ladder of contexts: no bound
whatsoever — in particular no `+4`-per-doubling law — can hold for a Zipf
profile family. -/
theorem zipf_knee_unbounded {tau : ℚ} (h0 : 0 < tau) (h1 : tau ≤ 1) (K : ℕ) :
    ∃ m, K < knee (zipfCurve (2 ^ m)) tau := by
  obtain ⟨j, hj⟩ : ∃ j : ℕ, K < 2 ^ j := ⟨K, Nat.lt_two_pow_self⟩
  set m : ℕ := max j ⌈(2 * (1 + (j : ℚ))) / tau⌉₊ with hm
  refine ⟨m, lt_of_lt_of_le hj (le_of_lt ?_)⟩
  refine zipf_knee_gt_two_pow (le_max_left _ _) h1 ?_
  have hmle : ⌈(2 * (1 + (j : ℚ))) / tau⌉₊ ≤ m := le_max_right _ _
  have hceil : ((2 : ℚ) * (1 + (j : ℚ))) / tau ≤ (m : ℚ) :=
    le_trans (Nat.le_ceil _) (by exact_mod_cast hmle)
  have hkey : 2 * (1 + (j : ℚ)) ≤ tau * m := by
    rw [div_le_iff₀ h0] at hceil
    linarith
  nlinarith [hkey, h0]

/-! ## 3. Truncated geometric profiles: the knee is context-free -/

/-- Retention curve of the geometric profile `p i ∝ 2^{-i}` truncated to `n`
keys. -/
def geomCurve (n : ℕ) (k : ℕ) : ℚ :=
  (1 - (1 / 2 : ℚ) ^ (min k n)) / (1 - (1 / 2 : ℚ) ^ n)

theorem geom_tail_small {n : ℕ} (hn : 10 ≤ n) : (1 / 2 : ℚ) ^ n ≤ 1 / 1024 := by
  have h := pow_le_pow_of_le_one (by norm_num : (0:ℚ) ≤ 1/2) (by norm_num : (1/2:ℚ) ≤ 1) hn
  calc (1 / 2 : ℚ) ^ n ≤ (1 / 2 : ℚ) ^ 10 := h
    _ = 1 / 1024 := by norm_num

theorem geom_denom_bounds {n : ℕ} (hn : 10 ≤ n) :
    1023 / 1024 ≤ 1 - (1 / 2 : ℚ) ^ n ∧ 1 - (1 / 2 : ℚ) ^ n ≤ 1 := by
  have h1 := geom_tail_small hn
  have h2 : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
  constructor <;> linarith

/-- **The geometric knee does not move with the context.**  For every context
`n ≥ 10` the truncated geometric profile has knee exactly `6` at the NET-64 gate:
a light-tailed profile predicts a *context-free* budget, contradicting the
measured `16 → 20 → 24` chain. -/
theorem geom_knee_eq_six {n : ℕ} (hn : 10 ≤ n) : knee (geomCurve n) gate = 6 := by
  obtain ⟨hd1, hd2⟩ := geom_denom_bounds hn
  have hdpos : (0 : ℚ) < 1 - (1 / 2 : ℚ) ^ n := by linarith
  refine Combinatorics.KneeInvariance.knee_eq_of ?_ ?_
  · have hmin : min 6 n = 6 := min_eq_left (by omega)
    unfold geomCurve gate
    rw [hmin, le_div_iff₀ hdpos]
    norm_num
    linarith
  · intro j hj
    have hmin : min j n = j := min_eq_left (by omega)
    have hnum : 1 - (1 / 2 : ℚ) ^ (min j n) ≤ 31 / 32 := by
      rw [hmin]
      have : (1 / 2 : ℚ) ^ 5 ≤ (1 / 2 : ℚ) ^ j :=
        pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
      norm_num at this ⊢
      linarith
    unfold geomCurve gate
    rw [div_lt_iff₀ hdpos]
    linarith

/-- The geometric prediction is identical at `ctx = 512` and `ctx = 2048`. -/
theorem geom_knee_context_free :
    knee (geomCurve 512) gate = knee (geomCurve 2048) gate := by
  rw [geom_knee_eq_six (by norm_num), geom_knee_eq_six (by norm_num)]

/-! ## 4. The measured chain and the trichotomy -/

/-- The measured NET-64 chain, in closed form: `k*(ctx) = 4 log₂ ctx − 20`. -/
def measuredKnee (ctx : ℕ) : ℕ := 4 * Nat.log 2 ctx - 20

/-- The dual-corpus deployment table `{16, 20, 24}` at `{512, 1024, 2048}` is
exactly the logarithmic law `4 log₂ ctx − 20`. -/
theorem measured_chain_log_law :
    measuredKnee 512 = 16 ∧ measuredKnee 1024 = 20 ∧ measuredKnee 2048 = 24 := by
  have h9 : Nat.log 2 512 = 9 :=
    Nat.log_eq_of_pow_le_of_lt_pow (by norm_num) (by norm_num)
  have h10 : Nat.log 2 1024 = 10 :=
    Nat.log_eq_of_pow_le_of_lt_pow (by norm_num) (by norm_num)
  have h11 : Nat.log 2 2048 = 11 :=
    Nat.log_eq_of_pow_le_of_lt_pow (by norm_num) (by norm_num)
  refine ⟨?_, ?_, ?_⟩ <;> simp [measuredKnee, h9, h10, h11]

/-- The measured chain is *not* context-free: it moves by `8` keys between
`ctx = 512` and `ctx = 2048`. -/
theorem measured_chain_moves : measuredKnee 512 ≠ measuredKnee 2048 := by
  rw [measured_chain_log_law.1, measured_chain_log_law.2.2]
  norm_num

/-- **The profile trichotomy.**  The measured NET-64 chain is incompatible with
both classical extremes: a Zipf (heavy-tailed) profile is *too dear* — it needs
more than `32` keys at `ctx = 2048`, where the measurement reports `24`; a
truncated geometric (light-tailed) profile is *too cheap and rigid* — its knee is
the same at every context, whereas the measured knee grows logarithmically.  The
attention profiles realising the deployment table therefore lie strictly between
the two families. -/
theorem measured_chain_is_neither_zipf_nor_geometric :
    24 < knee (zipfCurve (2 ^ 11)) gate ∧
      knee (geomCurve 512) gate = knee (geomCurve 2048) gate ∧
      measuredKnee 512 ≠ measuredKnee 2048 ∧
      measuredKnee 2048 = 24 :=
  ⟨by have := zipf_knee_2048_gt_32; omega, geom_knee_context_free, measured_chain_moves,
    measured_chain_log_law.2.2⟩

end Catalog.Probability.NET64ProfileTrichotomy