import Shared.TieBlockRankCeiling
import Shared.RankSpreadLowerBound

/-!
# The starved-regime ceiling on a rank dial (T-DIAL-56, paper 178)

Synthesis of `Shared.TieBlockRankCeiling` (the conditional-expectation ceiling)
and `Shared.RankSpreadLowerBound` (the discrete spread bound).

Experimental setting (exp 511, seed 20261030).  `n = 1200` moduli are sampled at
bit length `56`; for each one a dial statistic `T(N)` and a smooth-hit `rate(N)`
are recorded, and the score is `Spearman(T, rate)`, i.e. the Pearson correlation
of the two rank vectors.  At bit length `56` the sieve is *starved*: the mean rate
is `0.89 %` and `m = 194` of the `1200` moduli record **zero** hits.  Those `194`
moduli all carry the same measured rate, so their ranks are tied.

Main results.

* `cov_sq_le` — the Cauchy–Schwarz baseline `Cov² ≤ Var X · Var Y`.
* `varOf_rankVec` — a rank vector on `n` points has variance exactly `(n³ - n)/12`.
* `spearman_ceiling_of_tie_block` — **the ceiling**: if the response is tied on a
  block of `m` of the `n` points, then for every dial whatsoever,
  `Cov(T-rank, rate)² ≤ ((n³ - n)/12 - (m³ - m)/12) · Var(rate)`.
* `spearman_sq_le_one_sub_ratio` — normalised: `ρ² ≤ 1 - (m³ - m)/(n³ - n)`.
* `spearman_ceiling_of_tie_partition` — the strengthening to the *full* tie
  partition (the classical Spearman tie correction): every tie block of the
  response subtracts its own `(mₖ³ - mₖ)/12` from the achievable numerator.

## Critic stage — the recorded numbers do *not* fit the tie explanation

* `tie_ceiling_1200_194_not_binding` — at `m = 194`, `n = 1200` the ceiling is
  `ρ² ≤ 0.99578…`, which is *above* the lower edge `0.55` of the target band.
  So the zero-hit block, on its own, is mathematically incapable of dragging the
  Spearman coefficient out of the band; the reported `0.405` needs a second
  mechanism.
* `starvation_threshold` / `starvation_fraction_lower_bound` — quantifying the
  boundary: for ties alone to force `ρ ≤ 0.55` the zero-hit block must satisfy
  `m³ - m ≥ 0.6975 (n³ - n)`, i.e. a starvation fraction of at least `88 %`.
  The `16.2 %` observed at bit length `56` is far from that.

This is the precise sense in which "the bit-length dial has a practical floor":
the *tie* part of the floor is a cubic threshold at roughly `88 %` starvation,
and everything observed before that threshold must be attributed to within-block
noise in the rate estimate rather than to loss of rank resolution.
-/

namespace TieCeiling

open Finset

/-! ## Baseline -/

/-- Cauchy–Schwarz: the unconditional bound with no tie structure. -/
theorem cov_sq_le {ι : Type*} [Fintype ι] (X Y : ι → ℝ) :
    cov X Y ^ 2 ≤ varOf X * varOf Y :=
  Finset.sum_mul_sq_le_sq_mul_sq _ _ _

/-! ## Rank vectors -/

/-- The rank vector attached to a permutation `σ`: point `i` has rank `σ i`. -/
noncomputable def rankVec {n : ℕ} (σ : Equiv.Perm (Fin n)) : Fin n → ℝ :=
  fun i => ((σ i : ℕ) : ℝ)

lemma mean_rankVec {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    mean (rankVec σ) = (∑ a : Fin n, (a : ℝ)) / n := by
  simp only [mean, rankVec, Fintype.card_fin]
  rw [Equiv.sum_comp σ (fun a : Fin n => ((a : ℕ) : ℝ))]

/-- A rank vector on `n` points has variance exactly `(n³ - n)/12`. -/
theorem varOf_rankVec {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    varOf (rankVec σ) = ((n : ℝ) ^ 3 - n) / 12 := by
  rw [varOf, mean_rankVec]
  simp only [rankVec]
  rw [Equiv.sum_comp σ (fun a : Fin n => (((a : ℕ) : ℝ) - (∑ b : Fin n, (b : ℝ)) / n) ^ 2)]
  exact spread_eq_of_ranks n

/-- The integer form of a rank vector, injective by construction. -/
lemma rankVec_cast {n : ℕ} (σ : Equiv.Perm (Fin n)) (i : Fin n) :
    rankVec σ i = (((σ i : ℕ) : ℤ) : ℝ) := by
  simp [rankVec]

lemma rankInt_injective {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    Function.Injective (fun i => ((σ i : ℕ) : ℤ)) := by
  intro i j hij
  have h2 : (((σ i : ℕ)) : ℤ) = (((σ j : ℕ)) : ℤ) := hij
  exact σ.injective (Fin.ext (by exact_mod_cast h2))

/-! ## The single tie block -/

/-- The block labelling that collapses `S` to one block and leaves every other
point alone. -/
def blockOf {n : ℕ} (S : Finset (Fin n)) : Fin n → Option (Fin n) :=
  fun i => if i ∈ S then none else some i

lemma fiber_blockOf_none {n : ℕ} (S : Finset (Fin n)) : fiber (blockOf S) none = S := by
  ext i
  by_cases h : i ∈ S <;> simp [mem_fiber, blockOf, h]

/-- **The starved-regime ceiling.**  Let `Y` be any response that is *tied* on a
block `S` of size `m` (the moduli with zero smooth hits), and let `X = rankVec σ`
be the rank vector of an arbitrary dial.  Then

`Cov(X, Y)² ≤ ((n³ - n)/12 - (m³ - m)/12) · Var Y`.

Every unit of rank spread inside the tie block is invisible to the correlation:
the dial is penalised for resolving distinctions the measurement cannot see. -/
theorem spearman_ceiling_of_tie_block {n : ℕ} (σ : Equiv.Perm (Fin n)) (Y : Fin n → ℝ)
    (S : Finset (Fin n)) (hY : ∀ i ∈ S, ∀ j ∈ S, Y i = Y j) :
    cov (rankVec σ) Y ^ 2
      ≤ (((n : ℝ) ^ 3 - n) / 12 - (((S.card : ℝ)) ^ 3 - S.card) / 12) * varOf Y := by
  classical
  rcases Finset.eq_empty_or_nonempty S with rfl | ⟨i₀, hi₀⟩
  · simpa [varOf_rankVec] using cov_sq_le (rankVec σ) Y
  set X : Fin n → ℝ := rankVec σ with hX
  set b : Fin n → Option (Fin n) := blockOf S with hb
  -- `Y` factors through the block labelling
  set g : Option (Fin n) → ℝ := fun k => k.elim (Y i₀) Y with hg
  have hYfac : Y = fun i => g (b i) := by
    funext i
    by_cases h : i ∈ S
    · simp [hg, hb, blockOf, h, hY i h i₀ hi₀]
    · simp [hg, hb, blockOf, h]
  -- the within-block spread of the rank vector is at least `(m³ - m)/12`
  have hfib : fiber b none = S := fiber_blockOf_none S
  have hce : ∀ i ∈ S, condExp X b i = (∑ j ∈ S, X j) / S.card := by
    intro i hi
    have hbi : b i = none := by simp [hb, blockOf, hi]
    simp [condExp, hbi, blockAvg, hfib]
  have hspread : (((S.card : ℝ)) ^ 3 - S.card) / 12
      ≤ ∑ i ∈ S, (X i - condExp X b i) ^ 2 := by
    have hinj : Set.InjOn (fun i => ((σ i : ℕ) : ℤ)) S :=
      (rankInt_injective σ).injOn
    refine (spread_ge_of_injOn S (fun i => ((σ i : ℕ) : ℤ)) hinj).trans
      (le_of_eq (Finset.sum_congr rfl fun i hi => ?_))
    rw [hce i hi, hX]
    simp only [rankVec]
    push_cast
    ring
  have hW : (((S.card : ℝ)) ^ 3 - S.card) / 12 ≤ ∑ i, (X i - condExp X b i) ^ 2 :=
    hspread.trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      (fun i _ _ => sq_nonneg _))
  -- apply the ceiling
  have hmain := cov_sq_le_explained X b g
  rw [← hYfac] at hmain
  have hvY : 0 ≤ varOf Y := varOf_nonneg Y
  have hvX : varOf X = ((n : ℝ) ^ 3 - n) / 12 := by rw [hX, varOf_rankVec]
  refine hmain.trans ?_
  apply mul_le_mul_of_nonneg_right _ hvY
  rw [hvX]
  linarith [hW]

/-- Normalised form: the squared Spearman coefficient obeys
`ρ² ≤ 1 - (m³ - m)/(n³ - n)`. -/
theorem spearman_sq_le_one_sub_ratio {n : ℕ} (σ : Equiv.Perm (Fin n)) (Y : Fin n → ℝ)
    (S : Finset (Fin n)) (hY : ∀ i ∈ S, ∀ j ∈ S, Y i = Y j)
    (hn : 0 < (n : ℝ) ^ 3 - n) (hYv : 0 < varOf Y) :
    cov (rankVec σ) Y ^ 2 / (varOf (rankVec σ) * varOf Y)
      ≤ 1 - (((S.card : ℝ)) ^ 3 - S.card) / ((n : ℝ) ^ 3 - n) := by
  have hbase := spearman_ceiling_of_tie_block σ Y S hY
  have hvX : varOf (rankVec σ) = ((n : ℝ) ^ 3 - n) / 12 := varOf_rankVec σ
  have hne : ((n : ℝ) ^ 3 - n) ≠ 0 := ne_of_gt hn
  rw [hvX, div_le_iff₀ (by positivity)]
  have heq : (1 - (((S.card : ℝ)) ^ 3 - S.card) / ((n : ℝ) ^ 3 - n)) *
        (((n : ℝ) ^ 3 - n) / 12 * varOf Y)
      = (((n : ℝ) ^ 3 - n) / 12 - (((S.card : ℝ)) ^ 3 - S.card) / 12) * varOf Y := by
    have hd : (((S.card : ℝ)) ^ 3 - S.card) / ((n : ℝ) ^ 3 - n) * ((n : ℝ) ^ 3 - n)
        = ((S.card : ℝ)) ^ 3 - S.card := div_mul_cancel₀ _ hne
    linear_combination (-(varOf Y) / 12) * hd
  rw [heq]
  exact hbase

/-! ## The full tie partition (classical Spearman tie correction) -/

/-- **Every tie block costs.**  If the response `Y` is constant on each fiber of a
block labelling `b`, the achievable covariance loses `(mₖ³ - mₖ)/12` for *every*
block, not just the starved one. -/
theorem spearman_ceiling_of_tie_partition {n : ℕ} {κ : Type*} [Fintype κ] [DecidableEq κ]
    (σ : Equiv.Perm (Fin n)) (b : Fin n → κ) (g : κ → ℝ) :
    cov (rankVec σ) (fun i => g (b i)) ^ 2
      ≤ (((n : ℝ) ^ 3 - n) / 12
          - ∑ k : κ, (((fiber b k).card : ℝ) ^ 3 - (fiber b k).card) / 12)
        * varOf (fun i => g (b i)) := by
  classical
  set X : Fin n → ℝ := rankVec σ with hX
  have hinj : Function.Injective (fun i => ((σ i : ℕ) : ℤ)) := rankInt_injective σ
  -- block by block, the within-block spread is at least the consecutive-integers value
  have hblock : ∀ k : κ, (((fiber b k).card : ℝ) ^ 3 - (fiber b k).card) / 12
      ≤ ∑ i ∈ fiber b k, (X i - condExp X b i) ^ 2 := by
    intro k
    have hce : ∀ i ∈ fiber b k, condExp X b i
        = (∑ j ∈ fiber b k, X j) / (fiber b k).card := by
      intro i hi
      simp [condExp, mem_fiber.1 hi, blockAvg]
    refine (spread_ge_of_injOn (fiber b k) (fun i => ((σ i : ℕ) : ℤ)) hinj.injOn).trans
      (le_of_eq (Finset.sum_congr rfl fun i hi => ?_))
    rw [hce i hi, hX]
    simp only [rankVec]
    push_cast
    ring
  have hsum : ∑ k : κ, (((fiber b k).card : ℝ) ^ 3 - (fiber b k).card) / 12
      ≤ ∑ i, (X i - condExp X b i) ^ 2 := by
    calc ∑ k : κ, (((fiber b k).card : ℝ) ^ 3 - (fiber b k).card) / 12
        ≤ ∑ k : κ, ∑ i ∈ fiber b k, (X i - condExp X b i) ^ 2 :=
          Finset.sum_le_sum fun k _ => hblock k
      _ = ∑ i, (X i - condExp X b i) ^ 2 :=
          Finset.sum_fiberwise Finset.univ b (fun i => (X i - condExp X b i) ^ 2)
  have hmain := cov_sq_le_explained X b g
  refine hmain.trans (mul_le_mul_of_nonneg_right ?_ (varOf_nonneg _))
  rw [hX, varOf_rankVec]
  linarith [hsum]

/-! ## Critic stage: the recorded numbers -/

/-- **The tie block observed at bit length 56 is not binding.**  With `n = 1200`
sampled moduli and `m = 194` zero-hit moduli, the tie ceiling is
`ρ² ≤ 1 - (194³ - 194)/(1200³ - 1200) = 0.99577…`, comfortably above `0.55² =
0.3025`.  Hence the reported collapse of `Spearman(T, rate)` to `0.405` cannot be
attributed to the zero-hit tie block: some other mechanism (within-block noise in
the rate estimate) must supply the rest. -/
theorem tie_ceiling_1200_194_not_binding :
    (0.55 : ℝ) ^ 2 < 1 - (((194 : ℝ)) ^ 3 - 194) / (((1200 : ℝ)) ^ 3 - 1200) ∧
    1 - (((194 : ℝ)) ^ 3 - 194) / (((1200 : ℝ)) ^ 3 - 1200) < 0.9958 := by
  constructor <;> norm_num

/-- The reported value `0.405` sits strictly below the tie ceiling, so it is not
in contradiction with the theory — it is simply unexplained by it. -/
theorem observed_405_below_tie_ceiling :
    (0.405 : ℝ) ^ 2 < 1 - (((194 : ℝ)) ^ 3 - 194) / (((1200 : ℝ)) ^ 3 - 1200) := by
  norm_num

/-- **The cubic starvation threshold.**  For the tie mechanism *alone* to push the
Spearman coefficient down to the band edge `0.55`, the zero-hit block must satisfy
`m³ - m ≥ 0.6975 (n³ - n)`. -/
theorem starvation_threshold (n m : ℕ) (hn : 0 < (n : ℝ) ^ 3 - n)
    (h : 1 - ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) ≤ 0.3025) :
    0.6975 * ((n : ℝ) ^ 3 - n) ≤ (m : ℝ) ^ 3 - m := by
  have h' : 0.6975 ≤ ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) := by linarith
  rw [le_div_iff₀ hn] at h'
  linarith

/-- **The `88 %` starvation fraction.**  Translating the cubic threshold into a
fraction: once `n ≥ 10`, the tie mechanism can only be responsible for a Spearman
coefficient at or below `0.55` if at least `88 %` of the sampled moduli record
zero hits.  At bit length `56` the observed fraction is `194/1200 ≈ 16.2 %`. -/
theorem starvation_fraction_lower_bound (n m : ℕ) (hn : 10 ≤ n)
    (h : 1 - ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) ≤ 0.3025) :
    0.88 * (n : ℝ) ≤ (m : ℝ) := by
  have hnR : (10 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hprod : (n : ℝ) * 100 ≤ (n : ℝ) * (n : ℝ) ^ 2 := by nlinarith
  have hn3 : 0 < (n : ℝ) ^ 3 - n := by nlinarith
  have hkey := starvation_threshold n m hn3 h
  have hm0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  -- `n³ - n ≥ 0.99 n³` once `n ≥ 10`
  have h99 : 0.99 * (n : ℝ) ^ 3 ≤ (n : ℝ) ^ 3 - n := by nlinarith
  have hcube : 0.6975 * (0.99 * (n : ℝ) ^ 3) ≤ (m : ℝ) ^ 3 := by nlinarith
  by_contra hcon
  push_neg at hcon
  have hlt : (m : ℝ) ^ 3 < (0.88 * (n : ℝ)) ^ 3 := pow_lt_pow_left₀ hcon hm0 (by norm_num)
  nlinarith [hlt, hcube]

end TieCeiling