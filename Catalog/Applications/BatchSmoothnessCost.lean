import Mathlib

/-!
# Cost models for batch smoothness testing: amortization, reversal, and the Amdahl cap

Companion to `Catalog/Applications/BatchSmoothnessCorrectness.lean`, which shows
that product-tree batch smoothness testing decides exactly the same predicate as
solo trial division.  Here we formalise *what it costs*, reproducing the three
quantitative phenomena measured in exp 561 (`B = 100`, bit length `40`, pools
`k ∈ {1, 8, 64, 512}`):

1. **Flat op model: batch wins at every pool size, and the win grows with `k`.**
   Batch work splits into a one-off setup `A` (building the factor-base product
   tree) plus a per-candidate cost `c`; solo work is `s` per candidate.  The
   relative saving is `(s - c)/s - A/(s·k)`, strictly increasing in `k` and
   converging to the ceiling `(s - c)/s` (`flatSaving_strictMono`,
   `flatSaving_tendsto`).  If `A < s - c` there is *no crossover*: batch is
   cheaper already at `k = 1` (`flat_batch_lt_solo`).

2. **Word model: the sign reverses at large pools.**  With schoolbook
   arithmetic a product tree over `2 ^ L` leaves of `w` words costs
   `w² (4 ^ L - 2 ^ L)/2` word operations (`treeWordCost_closed`), i.e.
   *quadratic* in the pool size, against solo's linear cost.  Hence batch loses
   for every pool beyond an explicit threshold (`word_batch_reversal`), and in
   the two-parameter continuous model the crossover is unique and given in
   closed form (`word_crossover`).  Calibrating the model to the measured
   crossover `M* ≈ 1715` is `word_crossover_calibrated`.

3. **E1 / Amdahl cap.**  Testing is only a fraction `f` of per-factor work
   (measured `f = 11.56 %`), so *no* testing improvement can save more than `f`
   overall (`overall_saving_le_testing_share`), and the end-to-end speedup
   factor is capped by `1/(1 - f)` (`speedup_factor_le`) — a constant, hence
   zero class movement.  Conversely the measured overall `+0.104` pins the
   testing phase down to `29/289 ≈ 10.03 %` of its former cost
   (`exp561_phase_residual`).

All cost quantities are exact (`ℕ` counts, `ℚ` ratios); nothing here is
numerical simulation.
-/

namespace BatchCost

/-! ## Product trees: node counts and word counts -/

/-- Number of multiplications in a balanced product tree over `2 ^ L` leaves
(one op per internal node — the *flat* op model). -/
def treeFlatOps : ℕ → ℕ
  | 0 => 0
  | L + 1 => 2 * treeFlatOps L + 1

/-- A balanced product tree over `2 ^ L` leaves has `2 ^ L - 1` internal nodes. -/
theorem treeFlatOps_succ_eq (L : ℕ) : treeFlatOps L + 1 = 2 ^ L := by
  induction L with
  | zero => simp [treeFlatOps]
  | succ L ih => simp [treeFlatOps, pow_succ]; omega

/-- Word-operation cost of a balanced product tree over `2 ^ L` leaves, each of
`w` machine words, with schoolbook multiplication: the top multiplication
combines two `2 ^ L · w`-word operands at cost `(2 ^ L · w) ^ 2`. -/
def treeWordCost (w : ℕ) : ℕ → ℕ
  | 0 => 0
  | L + 1 => 2 * treeWordCost w L + (2 ^ L * w) ^ 2

/-- **Closed form.**  `treeWordCost w L = w² (4 ^ L - 2 ^ L) / 2`, stated without
truncated subtraction.  The `4 ^ L` term is the source of the word-model
reversal: the product tree is *quadratic* in the pool size `2 ^ L`. -/
theorem treeWordCost_closed (w L : ℕ) :
    2 * treeWordCost w L + w ^ 2 * 2 ^ L = w ^ 2 * 4 ^ L := by
  induction L with
  | zero => simp [treeWordCost]
  | succ L ih =>
      have h4 : (4 : ℕ) ^ (L + 1) = 4 * 4 ^ L := by ring
      have h2 : (2 : ℕ) ^ (L + 1) = 2 * 2 ^ L := by ring
      have hpow : (4 : ℕ) ^ L = 2 ^ L * 2 ^ L := by
        rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow]
      have hsq : (2 ^ L * w) ^ 2 = w ^ 2 * 4 ^ L := by
        rw [mul_pow, hpow]; ring
      rw [treeWordCost, h4, h2, hsq]
      nlinarith [ih]

/-- The product tree over `2 ^ L` leaves costs at least `w² · 2^L (2^L - 1) / 2`
word operations; in the form `2 · cost ≥ w² · 2^L · (2^L - 1)`. -/
theorem treeWordCost_lower (w L : ℕ) :
    w ^ 2 * (2 ^ L * (2 ^ L - 1)) ≤ 2 * treeWordCost w L := by
  have h := treeWordCost_closed w L
  have h4 : (4 : ℕ) ^ L = 2 ^ L * 2 ^ L := by
    rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow]
  have hpos : 1 ≤ (2 : ℕ) ^ L := Nat.one_le_two_pow
  have : w ^ 2 * (2 ^ L * (2 ^ L - 1)) = w ^ 2 * 4 ^ L - w ^ 2 * 2 ^ L := by
    rw [h4, Nat.mul_sub, Nat.mul_sub]
    ring_nf
  omega

/-! ## Flat op model: batch amortizes, with no crossover -/

section Flat

variable (A c s : ℚ)

/-- Flat-model cost of testing a pool of `k` candidates in batch: a one-off
setup `A` (factor-base product tree) plus `c` per candidate (remainder-tree node
and repeated squarings). -/
def batchFlat (k : ℚ) : ℚ := A + c * k

/-- Flat-model cost of solo trial division: `s` operations per candidate. -/
def soloFlat (k : ℚ) : ℚ := s * k

/-- Relative saving of batch over solo on a pool of `k` candidates. -/
noncomputable def flatSaving (k : ℚ) : ℚ := 1 - batchFlat A c k / soloFlat s k

/-- Explicit form of the relative saving: a ceiling `(s - c)/s` minus an
amortized setup term `A/(s·k)`. -/
theorem flatSaving_eq (hs : 0 < s) {k : ℚ} (hk : 0 < k) :
    flatSaving A c s k = (s - c) / s - A / (s * k) := by
  unfold flatSaving batchFlat soloFlat
  field_simp
  ring

/-- **No crossover.**  If the setup cost is smaller than the per-candidate
advantage, batch is strictly cheaper at *every* pool size `k ≥ 1` — matching the
measurement that batch beats solo at all of `k = 1, 8, 64, 512`. -/
theorem flat_batch_lt_solo (hA0 : 0 ≤ A) (hA : A < s - c) {k : ℚ} (hk : 1 ≤ k) :
    batchFlat A c k < soloFlat s k := by
  unfold batchFlat soloFlat
  nlinarith [mul_nonneg (show (0:ℚ) ≤ s - c by linarith) (sub_nonneg.mpr hk)]

/-- **Amortization is monotone.**  The relative saving strictly increases with
the pool size (for positive setup cost). -/
theorem flatSaving_strictMono (hs : 0 < s) (hA : 0 < A) {k₁ k₂ : ℚ}
    (hk₁ : 0 < k₁) (h : k₁ < k₂) :
    flatSaving A c s k₁ < flatSaving A c s k₂ := by
  have hk₂ : 0 < k₂ := lt_trans hk₁ h
  rw [flatSaving_eq A c s hs hk₁, flatSaving_eq A c s hs hk₂]
  have h1 : A / (s * k₂) < A / (s * k₁) := by
    apply div_lt_div_of_pos_left hA (by positivity)
    exact mul_lt_mul_of_pos_left h hs
  linarith

/-- **The ceiling.**  The saving never reaches `(s - c)/s`, the ratio it would
have with free setup. -/
theorem flatSaving_lt_ceiling (hs : 0 < s) (hA : 0 < A) {k : ℚ} (hk : 0 < k) :
    flatSaving A c s k < (s - c) / s := by
  rw [flatSaving_eq A c s hs hk]
  have : 0 < A / (s * k) := by positivity
  linarith

/-- **Asymptotics of amortization.**  As the pool grows the relative saving
converges to `(s - c)/s`: batching can remove the setup cost entirely but never
the per-candidate cost. -/
theorem flatSaving_tendsto (hs : 0 < s) :
    Filter.Tendsto (fun n : ℕ => flatSaving A c s (n + 1)) Filter.atTop
      (nhds ((s - c) / s)) := by
  have hEq : ∀ n : ℕ, flatSaving A c s (n + 1)
      = (s - c) / s - A / s * (1 / ((n : ℚ) + 1)) := by
    intro n
    have hk : (0 : ℚ) < (n : ℚ) + 1 := by positivity
    rw [flatSaving_eq A c s hs hk]
    field_simp
  simp only [hEq]
  have h0 : Filter.Tendsto (fun n : ℕ => 1 / ((n : ℚ) + 1)) Filter.atTop (nhds 0) := by
    have : Filter.Tendsto (fun n : ℕ => ((n : ℚ) + 1)) Filter.atTop Filter.atTop := by
      apply Filter.tendsto_atTop_add_const_right
      exact tendsto_natCast_atTop_atTop
    simpa using this.inv_tendsto_atTop
  have := (h0.const_mul (A / s))
  simpa using (Filter.Tendsto.const_sub ((s - c) / s) this)

end Flat

/-! ## Word model: the sign reverses -/

/-- **Word-model reversal (from the exact tree cost).**  Once the pool `2 ^ L`
is large enough that `w² (2 ^ L - 1) > 2 s`, the product tree alone costs more
word operations than *all* of solo trial division on the same pool.  Since the
threshold depends only on `s/w²`, the reversal is unavoidable for schoolbook
big-integer arithmetic. -/
theorem word_batch_reversal {w L s : ℕ} (h : 2 * s + w ^ 2 < w ^ 2 * 2 ^ L) :
    s * 2 ^ L < treeWordCost w L := by
  have hc := treeWordCost_closed w L
  have hpow : (4 : ℕ) ^ L = 2 ^ L * 2 ^ L := by
    rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow]
  have hpos : 0 < (2 : ℕ) ^ L := Nat.two_pow_pos L
  have hmul := Nat.mul_lt_mul_of_lt_of_le h (le_refl (2 ^ L)) hpos
  rw [hpow] at hc
  nlinarith [hc, hmul]

/-- Concrete instance of the reversal at `w = 8` words (a 512-bit intermediate
unit) against a solo cost of `s = 1000` word ops per candidate: pools of
`2 ^ 6 = 64` or more already lose in the word model. -/
theorem word_batch_reversal_64 : 1000 * 2 ^ 6 < treeWordCost 8 6 := by
  apply word_batch_reversal
  norm_num

section Word

variable (q c₁ s₁ : ℚ)

/-- Continuous two-parameter word model: batch pays a quadratic big-integer term
`q·k(k-1)` (product and remainder trees) plus `c₁` per candidate. -/
def batchWord (k : ℚ) : ℚ := q * k * (k - 1) + c₁ * k

/-- Solo word cost stays linear. -/
def soloWord (k : ℚ) : ℚ := s₁ * k

/-- **Unique crossover in closed form.**  Batch is at most as expensive as solo
exactly for pools up to `M* = 1 + (s₁ - c₁)/q`, and strictly more expensive
beyond it: the sign of the comparison changes exactly once. -/
theorem word_crossover (hq : 0 < q) {k : ℚ} (hk : 0 < k) :
    batchWord q c₁ k ≤ soloWord s₁ k ↔ k ≤ 1 + (s₁ - c₁) / q := by
  unfold batchWord soloWord
  have hrw : 1 + (s₁ - c₁) / q = (q + s₁ - c₁) / q := by field_simp; ring
  rw [hrw, le_div_iff₀ hq]
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

/-- **Calibration to the measured crossover.**  Exp 561 reports a word-model
crossover at `M* ≈ 1715` candidates.  In the two-parameter model that is exactly
the statement `(s₁ - c₁)/q = 1714`; the model then predicts batch wins for every
pool of at most 1715 candidates and loses for every larger one. -/
theorem word_crossover_calibrated (hq : 0 < q) (hcal : s₁ - c₁ = 1714 * q)
    {k : ℚ} (hk : 0 < k) :
    batchWord q c₁ k ≤ soloWord s₁ k ↔ k ≤ 1715 := by
  rw [word_crossover q c₁ s₁ hq hk, hcal]
  rw [mul_div_assoc, div_self hq.ne']
  norm_num

/-- At the measured pool `k = 512` the calibrated word model is still favourable,
while at `k = 4096` it is not: the reversal is a genuine sign change inside the
deployment range. -/
theorem word_model_sign_change (hq : 0 < q) (hcal : s₁ - c₁ = 1714 * q) :
    batchWord q c₁ 512 ≤ soloWord s₁ 512 ∧ ¬ (batchWord q c₁ 4096 ≤ soloWord s₁ 4096) := by
  refine ⟨?_, ?_⟩
  · rw [word_crossover_calibrated q c₁ s₁ hq hcal (by norm_num)]; norm_num
  · rw [word_crossover_calibrated q c₁ s₁ hq hcal (by norm_num)]; norm_num

end Word

/-! ## The E1 / Amdahl cap on a testing-phase improvement -/

section Amdahl

variable (F S S' : ℚ)

/-- **Amdahl cap (E1 bound).**  If per-factor work splits as finding `F` plus
testing `S`, then replacing testing by any nonnegative cost `S'` saves at most
the testing share `S/(F + S)` of the total.  Measured share: `11.56 %`; realized
overall gain `+10.4 %` therefore sits below the cap by necessity, not by
accident. -/
theorem overall_saving_le_testing_share (hF : 0 ≤ F) (hS : 0 < S) (hS' : 0 ≤ S') :
    ((F + S) - (F + S')) / (F + S) ≤ S / (F + S) := by
  have hT : 0 < F + S := by linarith
  gcongr
  linarith

/-- **Bounded speedup factor.**  Even with a *free* testing phase the end-to-end
speedup factor is at most `1/(1 - f)` where `f` is the testing share: a constant
factor, hence no movement of the complexity class. -/
theorem speedup_factor_le (hF : 0 < F) (hS : 0 < S) (hS' : 0 ≤ S') :
    (F + S) / (F + S') ≤ (F + S) / F := by
  have hT : 0 < F + S := by linarith
  gcongr
  linarith

/-- **Inverting the measurement.**  If the overall saving is `d` and the testing
share is `f = S/(F+S)`, then the surviving testing cost is exactly
`S' = S·(1 - d/f)`. -/
theorem phase_residual (hS : 0 < S) (hT : 0 < F + S) {d : ℚ}
    (hd : ((F + S) - (F + S')) / (F + S) = d) :
    S' / S = 1 - d * ((F + S) / S) := by
  have hS'eq : S' = S - d * (F + S) := by
    field_simp at hd
    linarith
  rw [hS'eq]
  field_simp

end Amdahl

/-! ## Exp 561 numbers -/

/-- Measured testing share of per-factor work. -/
def e1Share : ℚ := 1156 / 10000

/-- Measured overall improvement of the batch arm. -/
def measuredDelta : ℚ := 104 / 1000

/-- The realized gain lies strictly under the E1 cap, as it must. -/
theorem exp561_under_cap : measuredDelta < e1Share := by
  unfold measuredDelta e1Share; norm_num

/-- **What the measurement pins down.**  An overall gain of `+0.104` against a
testing share of `11.56 %` forces the batch testing phase to cost exactly
`29/289 ≈ 10.03 %` of the solo testing phase — i.e. a `≈ 9.97×` speedup *of its
own phase*, not of the factorization. -/
theorem exp561_phase_residual {F S S' : ℚ} (hS : 0 < S) (hT : 0 < F + S)
    (hshare : S / (F + S) = e1Share)
    (hd : ((F + S) - (F + S')) / (F + S) = measuredDelta) :
    S' / S = 29 / 289 := by
  have h := phase_residual F S S' hS hT hd
  have hinv : (F + S) / S = 10000 / 1156 := by
    have hs2 : S = e1Share * (F + S) := by rw [← hshare]; field_simp
    unfold e1Share at hs2
    rw [div_eq_iff hS.ne']
    linarith
  rw [h, hinv]
  unfold measuredDelta
  norm_num

/-- Even the *ideal* batch arm (free testing) could not have reached `+0.12`
overall: the reported `+0.104` is within `1.16` percentage points of the
absolute ceiling. -/
theorem exp561_ceiling_blocks_twelve_percent {F S S' : ℚ} (hF : 0 ≤ F) (hS : 0 < S)
    (hS' : 0 ≤ S') (hshare : S / (F + S) = e1Share) :
    ((F + S) - (F + S')) / (F + S) < 12 / 100 := by
  have hT : 0 < F + S := by linarith
  have hcap := overall_saving_le_testing_share F S S' hF hS hS'
  rw [hshare] at hcap
  have : e1Share < 12 / 100 := by unfold e1Share; norm_num
  linarith

end BatchCost