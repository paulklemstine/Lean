import Mathlib
import Probability.TDialBoundedDriftLaw

/-!
# Block-balanced reweighting of a rebound ladder: the conjectured `O(1/c)` rate is false

## Research context (FACT round-71 #2, exp 553; fifth cycle)

The fourth cycle proved the **majority-count drift law**
(`Probability.TDialBoundedDriftLaw.bounded_amplitude_drift_bound`): residuals bounded by `η`
whose sign pattern has block sums `A` and `B` drift by at most `η · max(A, B)`, and this is
attained.  Consequently the *unweighted* mean of `K + 1` rungs has worst-case error
`η · max(A,B)/(K+1)`, which does not decay when the pattern is unbalanced.

That left the direction recorded as *"Block-Balanced Reweighting of Rebound Ladders"*: give
every rung of a maximal constant-sign block of length `nᵢ` the weight `1/nᵢ`, so that each of
the `m` blocks carries total weight `1`, and ask whether the resulting estimator has worst-case
error `O(1/m)` — the conjectured bound was `2η/m`.

**This file refutes that conjecture and replaces it by the sharp law.**  The mechanism is the
same exact-vs-bounded dichotomy that governed the fourth cycle, one level up: the block means
`Sᵢ/nᵢ` inherit only `|Sᵢ/nᵢ| ≤ η` and the *sign* of their block, and an alternating sequence of
merely bounded terms does not cancel — one may zero out every second block.  Hence:

* the sharp worst case of the block-weighted estimator is `η ⌈m/2⌉ / m`, which is `≥ η/2` for
  every `m`, so **no decay at all**;
* if instead the residuals have *exact* amplitude `η`, the block means are exactly `±η`, the
  alternating sum telescopes, and the error is `≤ η/m` — the conjectured decay, valid only
  under the exact-amplitude hypothesis.

## Main results

* `alternating_bounded_partial_sums` — the two-sided invariant for an alternating-sign sequence
  of terms bounded by `η`: `−η⌊m/2⌋ ≤ ∑_{i<m} aᵢ ≤ η⌈m/2⌉`.  Unlike the exact-amplitude case
  the two sides do not collapse to `±η`; the asymmetry is by a whole half of the length.
* `alternating_bounded_sum_abs_le` — the sign-symmetric form `|∑_{i<m} aᵢ| ≤ η⌈m/2⌉`.
* `blockWeightedMean_bound` — hence the block-balanced estimator obeys
  `|estimator| ≤ η ⌈m/2⌉ / m`, and `blockWeightedMean_bound_sharp` shows this is an equality
  for an explicit ladder, so the bound is the worst case, not an artefact of the proof.
* `block_reweighting_rate_conjecture_false` — for every `m ≥ 5` that worst case *exceeds* the
  conjectured `2η/m`: the conjecture is false, and `block_reweighting_no_decay` shows the
  failure is not quantitative but structural — the error stays `≥ η/2` for all `m`.
* `exact_amplitude_blockWeightedMean_decays` — the salvage: under exact amplitude the same
  estimator does achieve `η/m`.
* `block_reweighting_dichotomy` — the two statements side by side at a common `m`, with the
  same block lengths and the same amplitude bound: `≥ η/2` versus `≤ η/m`.
* `no_weighting_beats_half` — the failure is not an artefact of the `1/nᵢ` weights: *no*
  nonnegative weighting of the blocks estimates the floor better than `η/2`.
* `minimax_half_amplitude_barrier`, `midrange_attains_barrier` — and it is not an artefact of
  linearity either.  The observation `collidingObservation` is realised exactly by the floor `L`
  with saturating positive blocks *and* by the floor `L + η` with saturating negative ones, so
  every procedure whatsoever errs by `η/2` on one of them; the nonlinear midrange attains that
  bound.  The minimax floor error for bounded alternating residuals is therefore exactly `η/2`.
* `u116_block_reweighting_floor` — applied to the record: at the measured rebound size
  `η = 0.0226`, no number of blocks brings the worst-case block-balanced floor estimate below
  `± 0.0113`.  This reproduces, from a purely combinatorial route, the resolution floor
  `u116_resolution_floor` obtained in the third cycle from the fade model.

## Lab notes

```
m (blocks)   worst-case block-weighted error / eta   conjectured 2/m   verdict
    1                    1                                2.000        conjecture holds
    2                    1/2                              1.000        conjecture holds
    3                    2/3                              0.667        equality-ish, holds
    4                    1/2                              0.500        boundary case
    5                    3/5 = 0.600                      0.400        CONJECTURE FALSE
    6                    1/2 = 0.500                      0.333        CONJECTURE FALSE
   10                    3/5 -> 1/2                       0.200        CONJECTURE FALSE
    m                    ceil(m/2)/m -> 1/2               2/m -> 0     no decay
exact-amplitude residuals, same block data : error <= eta/m  (decay restored)
recorded rebound eta = 226/10000 : worst case >= 113/10000 for every m
```
-/

open Finset

namespace Catalog.Probability.TDialBlockReweighting

/-! ## 1. Alternating sequences of bounded terms barely cancel -/

/-- **The propagating invariant for bounded alternating terms.**  If `|aᵢ| ≤ η` and the signs
alternate starting positive, then `−η⌊m/2⌋ ≤ ∑_{i<m} aᵢ ≤ η⌈m/2⌉`.  The proof is an induction in
which an even index consumes the upper budget and an odd index the lower one; no cancellation
between neighbours is available, because a term of the "wrong" sign may vanish. -/
theorem alternating_bounded_partial_sums {a : ℕ → ℝ} {eta : ℝ}
    (hb : ∀ i, |a i| ≤ eta) (hsg : ∀ i, 0 ≤ (-1 : ℝ) ^ i * a i) (m : ℕ) :
    -(eta * ((m / 2 : ℕ) : ℝ)) ≤ ∑ i ∈ range m, a i ∧
      ∑ i ∈ range m, a i ≤ eta * ((((m + 1) / 2 : ℕ)) : ℝ) := by
  have hnn : (0 : ℝ) ≤ eta := le_trans (abs_nonneg _) (hb 0)
  induction m with
  | zero => simp
  | succ m ih =>
      obtain ⟨ih1, ih2⟩ := ih
      have habs := abs_le.mp (hb m)
      have hsm := hsg m
      rw [sum_range_succ]
      rcases Nat.even_or_odd m with he | ho
      · have hpar : m % 2 = 0 := Nat.even_iff.mp he
        have hp : (-1 : ℝ) ^ m = 1 := he.neg_one_pow
        rw [hp, one_mul] at hsm
        have h1 : (m + 1) / 2 = m / 2 := by omega
        have h2 : (m + 1 + 1) / 2 = m / 2 + 1 := by omega
        rw [h1] at ih2
        rw [h1, h2]
        push_cast
        constructor <;> nlinarith [habs.1, habs.2]
      · have hpar : m % 2 = 1 := Nat.odd_iff.mp ho
        have hp : (-1 : ℝ) ^ m = -1 := ho.neg_one_pow
        rw [hp] at hsm
        have hle0 : a m ≤ 0 := by nlinarith
        have h1 : (m + 1) / 2 = m / 2 + 1 := by omega
        have h2 : (m + 1 + 1) / 2 = m / 2 + 1 := by omega
        rw [h1] at ih2
        rw [h1, h2]
        push_cast at ih2 ⊢
        constructor <;> nlinarith [habs.1]

/-- Sign-symmetric form: an alternating sequence of terms bounded by `η` — of either starting
sign — has partial sums bounded by `η⌈m/2⌉`, i.e. by half its length, not by `η`. -/
theorem alternating_bounded_sum_abs_le {a : ℕ → ℝ} {eps eta : ℝ}
    (heps : eps = 1 ∨ eps = -1) (hb : ∀ i, |a i| ≤ eta)
    (hsg : ∀ i, 0 ≤ eps * ((-1 : ℝ) ^ i * a i)) (m : ℕ) :
    |∑ i ∈ range m, a i| ≤ eta * ((((m + 1) / 2 : ℕ)) : ℝ) := by
  have habs : |eps| = 1 := by rcases heps with h | h <;> rw [h] <;> norm_num
  have hb' : ∀ i, |eps * a i| ≤ eta := by
    intro i; rw [abs_mul, habs, one_mul]; exact hb i
  have hsg' : ∀ i, 0 ≤ (-1 : ℝ) ^ i * (eps * a i) := by
    intro i; have := hsg i; nlinarith [this]
  obtain ⟨h1, h2⟩ := alternating_bounded_partial_sums hb' hsg' m
  have hsum : ∑ i ∈ range m, eps * a i = eps * ∑ i ∈ range m, a i := by rw [mul_sum]
  rw [hsum] at h1 h2
  have hmono : ((m / 2 : ℕ) : ℝ) ≤ (((m + 1) / 2 : ℕ) : ℝ) := by
    exact_mod_cast Nat.div_le_div_right (Nat.le_succ m)
  have hnn : (0 : ℝ) ≤ eta := le_trans (abs_nonneg _) (hb 0)
  have hkey : |eps * ∑ i ∈ range m, a i| ≤ eta * ((((m + 1) / 2 : ℕ)) : ℝ) := by
    rw [abs_le]
    constructor
    · nlinarith
    · exact h2
  rwa [abs_mul, habs, one_mul] at hkey

/-! ## 2. The block-balanced estimator -/

/-- The sum of the residuals in block `i`, whose length is `n i`. -/
noncomputable def blockSum (n : ℕ → ℕ) (s : ℕ → ℕ → ℝ) (i : ℕ) : ℝ :=
  ∑ j ∈ range (n i), s i j

/-- **The block-balanced estimator.**  Each rung of block `i` receives weight `1 / n i`, so each
of the `m` maximal constant-sign blocks carries total weight `1`; the estimator is the average
of the `m` block means. -/
noncomputable def blockWeightedMean (n : ℕ → ℕ) (s : ℕ → ℕ → ℝ) (m : ℕ) : ℝ :=
  (∑ i ∈ range m, blockSum n s i / (n i : ℝ)) / m

/-- A block mean of residuals bounded by `η` is bounded by `η`. -/
theorem blockMean_abs_le {n : ℕ → ℕ} {s : ℕ → ℕ → ℝ} {eta : ℝ} (hn : ∀ i, 0 < n i)
    (hb : ∀ i j, |s i j| ≤ eta) (i : ℕ) : |blockSum n s i / (n i : ℝ)| ≤ eta := by
  have hpos : (0 : ℝ) < (n i : ℝ) := by exact_mod_cast hn i
  have hsum : |blockSum n s i| ≤ (n i : ℝ) * eta := by
    calc |blockSum n s i| ≤ ∑ j ∈ range (n i), |s i j| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j ∈ range (n i), eta := Finset.sum_le_sum (fun j _ => hb i j)
      _ = (n i : ℝ) * eta := by rw [sum_const, card_range, nsmul_eq_mul]
  rw [abs_div, abs_of_pos hpos, div_le_iff₀ hpos]
  linarith [hsum]

/-- A block mean carries the sign of its block. -/
theorem blockMean_sign {n : ℕ → ℕ} {s : ℕ → ℕ → ℝ} {eps : ℝ} (hn : ∀ i, 0 < n i)
    (hsg : ∀ i j, 0 ≤ eps * ((-1 : ℝ) ^ i * s i j)) (i : ℕ) :
    0 ≤ eps * ((-1 : ℝ) ^ i * (blockSum n s i / (n i : ℝ))) := by
  have hpos : (0 : ℝ) < (n i : ℝ) := by exact_mod_cast hn i
  have hsum : 0 ≤ eps * ((-1 : ℝ) ^ i * blockSum n s i) := by
    have : eps * ((-1 : ℝ) ^ i * blockSum n s i)
        = ∑ j ∈ range (n i), eps * ((-1 : ℝ) ^ i * s i j) := by
      rw [blockSum, mul_sum, mul_sum]
    rw [this]
    exact Finset.sum_nonneg fun j _ => hsg i j
  have hrw : eps * ((-1 : ℝ) ^ i * (blockSum n s i / (n i : ℝ)))
      = (eps * ((-1 : ℝ) ^ i * blockSum n s i)) / (n i : ℝ) := by
    field_simp
  rw [hrw]
  positivity

/-- **The block-balanced law.**  For residuals bounded by `η` distributed in `m` alternating
blocks of arbitrary lengths, the block-balanced estimator is at most `η⌈m/2⌉/m` in absolute
value.  Note the striking feature: the block *lengths* have disappeared entirely — only their
number matters. -/
theorem blockWeightedMean_bound {n : ℕ → ℕ} {s : ℕ → ℕ → ℝ} {eps eta : ℝ}
    (heps : eps = 1 ∨ eps = -1) (hn : ∀ i, 0 < n i) (hb : ∀ i j, |s i j| ≤ eta)
    (hsg : ∀ i j, 0 ≤ eps * ((-1 : ℝ) ^ i * s i j)) {m : ℕ} (hm : 0 < m) :
    |blockWeightedMean n s m| ≤ eta * ((((m + 1) / 2 : ℕ)) : ℝ) / m := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcore := alternating_bounded_sum_abs_le heps (blockMean_abs_le hn hb)
      (blockMean_sign hn hsg) m
  rw [blockWeightedMean, abs_div, abs_of_pos hmpos, div_le_div_iff_of_pos_right hmpos]
  exact hcore

/-! ## 3. The conjectured `O(1/m)` rate is false -/

/-- The extremal ladder: `m` singleton blocks, in which every block of positive sign carries a
residual of full size `η` and every block of negative sign carries a residual of size `0`.
This is legal for *bounded* residuals and is the obstruction to any decay. -/
noncomputable def worstLadder (eta : ℝ) : ℕ → ℕ → ℝ := fun i _ => if Even i then eta else 0

/-- Counting the positive blocks: `⌈m/2⌉` of the first `m` indices are even. -/
theorem sum_indicator_even (eta : ℝ) (m : ℕ) :
    ∑ i ∈ range m, (if Even i then eta else 0) = eta * ((((m + 1) / 2 : ℕ)) : ℝ) := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [sum_range_succ, ih]
      rcases Nat.even_or_odd m with he | ho
      · have hpar : m % 2 = 0 := Nat.even_iff.mp he
        have h1 : (m + 1) / 2 = m / 2 := by omega
        have h2 : (m + 1 + 1) / 2 = m / 2 + 1 := by omega
        rw [h1, h2, if_pos he]
        push_cast
        ring
      · have hpar : m % 2 = 1 := Nat.odd_iff.mp ho
        have h1 : (m + 1) / 2 = m / 2 + 1 := by omega
        have h2 : (m + 1 + 1) / 2 = m / 2 + 1 := by omega
        rw [h1, h2, if_neg (Nat.not_even_iff_odd.mpr ho)]
        ring

/-- The extremal ladder has residuals bounded by `η`. -/
theorem worstLadder_bounded {eta : ℝ} (heta : 0 ≤ eta) (i j : ℕ) :
    |worstLadder eta i j| ≤ eta := by
  unfold worstLadder
  split_ifs with h
  · rw [abs_of_nonneg heta]
  · simpa using heta

/-- The extremal ladder has the alternating sign pattern (positive-first). -/
theorem worstLadder_sign {eta : ℝ} (heta : 0 ≤ eta) (i j : ℕ) :
    0 ≤ (1 : ℝ) * ((-1 : ℝ) ^ i * worstLadder eta i j) := by
  unfold worstLadder
  rcases Nat.even_or_odd i with he | ho
  · rw [he.neg_one_pow, if_pos he]
    simpa using heta
  · rw [ho.neg_one_pow, if_neg (Nat.not_even_iff_odd.mpr ho)]
    norm_num

/-- **The bound of `blockWeightedMean_bound` is exactly the worst case.**  With singleton blocks
and the extremal ladder the estimator equals `η⌈m/2⌉/m`. -/
theorem blockWeightedMean_bound_sharp (eta : ℝ) (m : ℕ) :
    blockWeightedMean (fun _ => 1) (worstLadder eta) m
      = eta * ((((m + 1) / 2 : ℕ)) : ℝ) / m := by
  have hblock : ∀ i, blockSum (fun _ => 1) (worstLadder eta) i / ((1 : ℕ) : ℝ)
      = if Even i then eta else 0 := by
    intro i
    simp [blockSum, worstLadder]
  rw [blockWeightedMean]
  simp only [hblock]
  rw [sum_indicator_even]

/-- **The conjectured rate `2η/m` is false.**  From five blocks on, the true worst case of the
block-balanced estimator strictly exceeds it. -/
theorem block_reweighting_rate_conjecture_false {eta : ℝ} (heta : 0 < eta) {m : ℕ} (hm : 5 ≤ m) :
    2 * eta / m < blockWeightedMean (fun _ => 1) (worstLadder eta) m := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by
    have : 0 < m := by omega
    exact_mod_cast this
  rw [blockWeightedMean_bound_sharp, div_lt_div_iff_of_pos_right hmpos]
  have hcount : (3 : ℕ) ≤ (m + 1) / 2 := by omega
  have hcast : (3 : ℝ) ≤ ((((m + 1) / 2 : ℕ)) : ℝ) := by exact_mod_cast hcount
  nlinarith

/-- **No decay at all.**  For every number of blocks the worst-case block-balanced error is at
least `η/2`: reweighting by block length cannot beat the majority-count law by more than a
factor of two, and in particular is not consistent. -/
theorem block_reweighting_no_decay {eta : ℝ} (heta : 0 ≤ eta) {m : ℕ} (hm : 0 < m) :
    eta / 2 ≤ blockWeightedMean (fun _ => 1) (worstLadder eta) m := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [blockWeightedMean_bound_sharp, le_div_iff₀ hmpos]
  have hcount : m ≤ 2 * ((m + 1) / 2) := by omega
  have hcast : (m : ℝ) ≤ 2 * ((((m + 1) / 2 : ℕ)) : ℝ) := by exact_mod_cast hcount
  nlinarith

/-! ## 4. The salvage: exact amplitude restores the decay -/

/-- **Exact amplitude restores the conjectured rate.**  If every residual has amplitude exactly
`η` (and the blocks alternate), the block means are exactly `±η`, their alternating sum
telescopes to `0` or `η`, and the estimator is within `η/m` of the truth — for *any* block
lengths.  Together with `block_reweighting_no_decay` this is the exact-versus-bounded dichotomy
of the fourth cycle, transported to the reweighted estimator. -/
theorem exact_amplitude_blockWeightedMean_decays {n : ℕ → ℕ} {eta : ℝ} (hn : ∀ i, 0 < n i)
    (heta : 0 ≤ eta) {m : ℕ} (hm : 0 < m) :
    |blockWeightedMean n (fun i _ => (-1 : ℝ) ^ i * eta) m| ≤ eta / m := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hblock : ∀ i, blockSum n (fun i _ => (-1 : ℝ) ^ i * eta) i / (n i : ℝ)
      = (-1 : ℝ) ^ i * eta := by
    intro i
    have hne : ((n i : ℝ)) ≠ 0 := by
      have : (0 : ℝ) < (n i : ℝ) := by exact_mod_cast hn i
      exact ne_of_gt this
    rw [blockSum, sum_const, card_range, nsmul_eq_mul]
    field_simp
  have hsum : ∑ i ∈ range m, (-1 : ℝ) ^ i * eta = (if Even m then (0 : ℝ) else 1) * eta := by
    rw [← sum_mul,
      Catalog.Probability.TDialU116FloorIdentifiability.alternating_signs_partial_sum_eq]
  rw [blockWeightedMean]
  simp only [hblock]
  rw [hsum, abs_div, abs_of_pos hmpos, div_le_div_iff_of_pos_right hmpos]
  split_ifs <;> simp [abs_of_nonneg heta, heta]

/-! ### The failure is not specific to the `1/nᵢ` weights -/

/-- A general linear estimator of the floor: an arbitrary weighting of the block means. -/
noncomputable def weightedBlockMean (w : ℕ → ℝ) (n : ℕ → ℕ) (s : ℕ → ℕ → ℝ) (m : ℕ) : ℝ :=
  ∑ i ∈ range m, w i * (blockSum n s i / (n i : ℝ))

/-- The block-balanced estimator is the uniform member of this family. -/
theorem blockWeightedMean_eq_weighted (n : ℕ → ℕ) (s : ℕ → ℕ → ℝ) (m : ℕ) :
    blockWeightedMean n s m = weightedBlockMean (fun _ => 1 / m) n s m := by
  rw [blockWeightedMean, weightedBlockMean, sum_div]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

/-- The mirror image of `worstLadder`: the negative blocks saturate, the positive ones vanish. -/
noncomputable def worstLadderNeg (eta : ℝ) : ℕ → ℕ → ℝ := fun i _ => if Even i then 0 else -eta

/-- The mirror ladder also has residuals bounded by `η`. -/
theorem worstLadderNeg_bounded {eta : ℝ} (heta : 0 ≤ eta) (i j : ℕ) :
    |worstLadderNeg eta i j| ≤ eta := by
  unfold worstLadderNeg
  split_ifs
  · simpa using heta
  · rw [abs_neg, abs_of_nonneg heta]

/-- The mirror ladder has the same alternating sign pattern. -/
theorem worstLadderNeg_sign {eta : ℝ} (heta : 0 ≤ eta) (i j : ℕ) :
    0 ≤ (1 : ℝ) * ((-1 : ℝ) ^ i * worstLadderNeg eta i j) := by
  unfold worstLadderNeg
  rcases Nat.even_or_odd i with he | ho
  · rw [he.neg_one_pow, if_pos he]
    norm_num
  · rw [ho.neg_one_pow, if_neg (Nat.not_even_iff_odd.mpr ho)]
    simpa using heta

/-- **Minimax: no weighting whatsoever beats `η/2`.**  For *any* nonnegative weights summing to
one, one of the two extremal bounded ladders — saturate the positive blocks, or saturate the
negative ones — is estimated with error at least `η/2`.  So the failure of the block-balanced
rate is not a defect of the choice `1/nᵢ`: under bounded residuals with an alternating block
pattern the floor cannot be averaged to better than half the amplitude, however many blocks are
observed. -/
theorem no_weighting_beats_half {w : ℕ → ℝ} {eta : ℝ} {m : ℕ} (heta : 0 ≤ eta)
    (hw : ∀ i, 0 ≤ w i) (hsum : ∑ i ∈ range m, w i = 1) :
    eta / 2 ≤ max |weightedBlockMean w (fun _ => 1) (worstLadder eta) m|
        |weightedBlockMean w (fun _ => 1) (worstLadderNeg eta) m| := by
  have hP : weightedBlockMean w (fun _ => 1) (worstLadder eta) m
      = ∑ i ∈ range m, w i * (if Even i then eta else 0) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases h : Even i <;> simp [blockSum, worstLadder, h]
  have hN : weightedBlockMean w (fun _ => 1) (worstLadderNeg eta) m
      = -∑ i ∈ range m, w i * (if Even i then 0 else eta) := by
    rw [weightedBlockMean, ← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases h : Even i <;> simp [blockSum, worstLadderNeg, h]
  have hPnn : 0 ≤ ∑ i ∈ range m, w i * (if Even i then eta else 0) :=
    Finset.sum_nonneg fun i _ => by
      have := hw i; split_ifs <;> nlinarith
  have hNnn : 0 ≤ ∑ i ∈ range m, w i * (if Even i then 0 else eta) :=
    Finset.sum_nonneg fun i _ => by
      have := hw i; split_ifs <;> nlinarith
  have htot : (∑ i ∈ range m, w i * (if Even i then eta else 0))
      + (∑ i ∈ range m, w i * (if Even i then 0 else eta)) = eta := by
    rw [← Finset.sum_add_distrib]
    have hpt : ∀ i ∈ range m,
        w i * (if Even i then eta else 0) + w i * (if Even i then 0 else eta) = w i * eta := by
      intro i _
      by_cases h : Even i <;> simp [h]
    rw [Finset.sum_congr rfl hpt, ← sum_mul, hsum, one_mul]
  rw [hP, hN, abs_of_nonneg hPnn, abs_neg, abs_of_nonneg hNnn]
  rcases le_total (∑ i ∈ range m, w i * (if Even i then eta else 0))
      (∑ i ∈ range m, w i * (if Even i then 0 else eta)) with h | h
  · rw [max_eq_right h]; linarith
  · rw [max_eq_left h]; linarith

/-- **The dichotomy at a fixed configuration.**  Same number of blocks, same block lengths, same
amplitude bound `η`: the bounded-amplitude ladder keeps an error of at least `η/2` while the
exact-amplitude ladder is already within `η/m`.  The gap between the two grows without bound in
`m`, so "how large are the residuals" is not the relevant question — "are they saturated" is. -/
theorem block_reweighting_dichotomy {eta : ℝ} (heta : 0 ≤ eta) {m : ℕ} (hm : 0 < m) :
    eta / 2 ≤ blockWeightedMean (fun _ => 1) (worstLadder eta) m ∧
      |blockWeightedMean (fun _ => 1) (fun i _ => (-1 : ℝ) ^ i * eta) m| ≤ eta / m :=
  ⟨block_reweighting_no_decay heta hm,
    exact_amplitude_blockWeightedMean_decays (fun _ => Nat.one_pos) heta hm⟩

/-- **Applied to the record.**  At the measured U116 rebound size `η = 0.0226`, the worst-case
block-balanced floor estimate is off by at least `0.0113`, for *every* number of blocks.  This
reproduces the resolution floor of `u116_resolution_floor` — obtained there from the fade model
— by a purely combinatorial route that makes no reference to a ratio `λ`. -/
theorem u116_block_reweighting_floor {m : ℕ} (hm : 0 < m) :
    (113 / 10000 : ℝ)
      ≤ blockWeightedMean (fun _ => 1) (worstLadder (226 / 10000 : ℝ)) m := by
  have h := block_reweighting_no_decay (by norm_num : (0 : ℝ) ≤ 226 / 10000) hm
  norm_num at h ⊢
  linarith

/-! ## 5. The barrier is information-theoretic, and the midrange attains it -/

/-- The observation produced by the floor `L` together with the saturating ladder
`worstLadder η` — equivalently, by the floor `L + η` together with its mirror image. -/
noncomputable def collidingObservation (L eta : ℝ) : ℕ → ℝ := fun k => if Even k then L + eta else L

/-- The collision: one and the same ladder of readings is an exact realisation of the floor `L`
with saturating positive blocks, and of the floor `L + η` with saturating negative blocks. -/
theorem collidingObservation_two_ways (L eta : ℝ) (k : ℕ) :
    collidingObservation L eta k = L + worstLadder eta k 0 ∧
      collidingObservation L eta k = (L + eta) + worstLadderNeg eta k 0 := by
  unfold collidingObservation worstLadder worstLadderNeg
  by_cases h : Even k <;> simp [h]

/-- **The half-amplitude barrier is information-theoretic.**  Let `E` be *any* procedure at all
turning a ladder of readings into a floor estimate — linear or not, measurable or not.  On the
colliding observation it must be wrong by at least `η/2` for one of the two floors `L`, `L + η`,
because both explain that observation exactly, with residuals bounded by `η` and with the same
alternating block pattern.  This removes the linearity hypothesis from
`no_weighting_beats_half`. -/
theorem minimax_half_amplitude_barrier (L eta : ℝ) (E : (ℕ → ℝ) → ℝ) :
    eta / 2 ≤ max |E (collidingObservation L eta) - L|
        |E (collidingObservation L eta) - (L + eta)| := by
  set y := E (collidingObservation L eta) with hy
  rcases le_total (eta / 2) |y - L| with h | h
  · exact le_trans h (le_max_left _ _)
  · refine le_trans ?_ (le_max_right _ _)
    have h1 : y - L ≤ eta / 2 := le_trans (le_abs_self _) h
    have h2 : -(eta / 2) ≤ y - L := neg_le_of_abs_le h
    rw [le_abs]
    right
    linarith

/-- The midrange of the first `m + 1` readings: the estimator that ignores everything except the
largest and the smallest rung. -/
noncomputable def midrange (x : ℕ → ℝ) (m : ℕ) : ℝ :=
  ((range (m + 1)).sup' Finset.nonempty_range_add_one x
    + (range (m + 1)).inf' Finset.nonempty_range_add_one x) / 2

/-- **The midrange attains the barrier.**  For readings `L + sₖ` with residuals bounded by `η`
and the alternating block pattern, the midrange of any window containing at least one positive
and one negative block is within `η/2` of the floor.  Together with
`minimax_half_amplitude_barrier` this pins the minimax floor error at exactly `η/2`: no
procedure does better, and this very simple nonlinear one does that well — whereas by
`no_weighting_beats_half` no weighted mean does. -/
theorem midrange_attains_barrier {L eta : ℝ} {s : ℕ → ℝ} (hb : ∀ k, |s k| ≤ eta)
    (hsg : ∀ k, 0 ≤ (-1 : ℝ) ^ k * s k) {m : ℕ} (hm : 1 ≤ m) :
    |midrange (fun k => L + s k) m - L| ≤ eta / 2 := by
  have h0 : (0 : ℕ) ∈ range (m + 1) := by simp
  have h1 : (1 : ℕ) ∈ range (m + 1) := by simp; omega
  have hs0 : 0 ≤ s 0 := by simpa using hsg 0
  have hs1 : s 1 ≤ 0 := by
    have h := hsg 1
    norm_num at h
    linarith
  have hAlow : L + s 0
      ≤ (range (m + 1)).sup' Finset.nonempty_range_add_one (fun k => L + s k) :=
    Finset.le_sup' (fun k => L + s k) h0
  have hAhigh : (range (m + 1)).sup' Finset.nonempty_range_add_one (fun k => L + s k)
      ≤ L + eta :=
    Finset.sup'_le _ _ fun k _ => by have := (abs_le.mp (hb k)).2; linarith
  have hBhigh : (range (m + 1)).inf' Finset.nonempty_range_add_one (fun k => L + s k)
      ≤ L + s 1 :=
    Finset.inf'_le (fun k => L + s k) h1
  have hBlow : L - eta
      ≤ (range (m + 1)).inf' Finset.nonempty_range_add_one (fun k => L + s k) :=
    Finset.le_inf' _ _ fun k _ => by have := (abs_le.mp (hb k)).1; linarith
  rw [midrange, abs_le]
  constructor <;> linarith

end Catalog.Probability.TDialBlockReweighting