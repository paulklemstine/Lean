import Mathlib
import Novelty.ZeroFitDialU64

/-!
# The zero-fit dial at bitlen 52: the count baseline has the *higher* tie ceiling

## Research context (FACT round-58 #1, exp 528, `CELL-CLOSED-DIAL-HOLDS-UNIF-52`)

The recorded measurement is a Spearman rank correlation between the zero-count
statistic `T` (the number of trailing binary zeros, i.e. the 2-adic valuation, of a
uniformly drawn 52-bit integer) and a downstream `rate`:

* seeds 20261120/21/22 give `0.698 / 0.697 / 0.720`, all inside the validation band
  `[0.55, 0.85]`;
* the pooled advantage of `T` over a plain *count* statistic is `+0.070`,
  CI `[0.046, 0.093]`.

`Novelty.ZeroFitDialU64` supplies the tie-attenuation calculus (midrank collapse,
tie decomposition, the law `ρ² = 1 - 12·Σⱼ(mⱼ³-mⱼ)/(n³-n)`, and the *dyadic* ceiling
`ρ² = (6/7)(1 + 1/(2^b(2^b+1)))` of the trailing-zero statistic).  What was missing
was the other half of the round-58 claim: the **count baseline** itself.  This file
computes the tie geometry of the Hamming-weight ("popcount") statistic and settles
whether the recorded `+0.070` advantage of `T` over count could be a tie artefact.

## Main results

* `binomBlocks`, `binomBlocks_sum`, `binomBlocks_eq_hamming_profile` — the tie profile
  of the popcount statistic on `b`-bit words is `(C(b,0), …, C(b,b))`, of total mass
  `2^b`; the combinatorial bridge identifies the blocks with the `k`-slices of the
  Boolean cube `Finset (Fin b)`.
* `centralBinom_sq_bound` — the sharp arithmetic input
  `C(2n,n)² · (3n+1) ≤ 16ⁿ`, proved by induction from
  `Nat.succ_mul_centralBinom_succ` (equivalently `C(2n,n) ≤ 4ⁿ/√(3n+1)`).
* `franel_le` — `Σₖ C(b,k)³ ≤ (max_k C(b,k))² · 2^b`, the cube-to-square collapse.
* `binom_tieCorr_bound`, `count_ceiling_ge` — the **count ceiling law**:
  for every even bitlen `b = 2m ≥ 2`,
  `ρ²_count ≥ 1 - 2/(3m+1) = 1 - 4/(3b+2)`.
* `count_ceiling_tendsto_one` — hence `ρ²_count → 1`: the popcount statistic is
  asymptotically tie-transparent, in sharp contrast with the dyadic ceiling `→ 6/7`.
* `ceiling_inversion` — the **inversion law**: for every even bitlen `b ≥ 10` the
  count ceiling *strictly exceeds* the trailing-zero ceiling.
* `unif52_inside_band`, `unif52_pooled_is_seed_mean`, `unif52_below_tie_ceiling`,
  `count_advantage_not_tie_artefact`, `count_deficit_exceeds_dial_deficit` — the
  recorded round-58 numbers checked against the theory.

## The scientific payload

`ceiling_inversion` is the adversarial content.  If the observed `+0.070` advantage of
the zero-fit dial over the count baseline were an artefact of rank ties (a plausible
prior: the count statistic has enormous tie classes, `C(52,26) ≈ 5·10¹⁴`), then the
count baseline would have to be the *more* attenuated of the two.  It is not: the
Hamming profile is spread over `53` blocks whose cube-sum is only `Θ(8^b/b)`, so its
ceiling is `≥ 0.974` at bitlen 52, while the trailing-zero profile, which is dominated
by a single block of mass `2^{b-1}`, is capped at `6/7 ≈ 0.857`.  The measured ordering
(`0.705` for `T` versus `0.635` for count) is therefore *opposite* to the ordering of
the two tie ceilings: the advantage is signal, not granularity
(`count_advantage_not_tie_artefact`), and the count statistic squanders a strictly
larger share of its resolving power (`count_deficit_exceeds_dial_deficit`).
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

namespace Catalog.MachineLearning.ZeroFitDialUnif52

/-! ## 1. List/Finset plumbing for tie profiles given by a formula -/

/-- Sum of a formula-defined profile as a `Finset` sum. -/
lemma list_range_map_sum {M : Type*} [AddCommMonoid M] (n : ℕ) (f : ℕ → M) :
    ((List.range n).map f).sum = ∑ k ∈ range n, f k := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [List.range_succ, List.map_append, List.sum_append, Finset.sum_range_succ, ih]
      simp

/-- The tie correction is additive along concatenation of profiles. -/
lemma tieCorr_append (L M : List ℕ) : tieCorr (L ++ M) = tieCorr L + tieCorr M := by
  simp [tieCorr]

/-- Tie correction of a formula-defined profile, as a `Finset` sum. -/
lemma tieCorr_range_map (f : ℕ → ℕ) (n : ℕ) :
    tieCorr ((List.range n).map f) = ∑ k ∈ range n, (((f k : ℚ)) ^ 3 - (f k : ℚ)) / 12 := by
  induction n with
  | zero => simp [tieCorr]
  | succ k ih =>
      rw [List.range_succ, List.map_append, tieCorr_append, ih, Finset.sum_range_succ]
      simp [tieCorr]

/-! ## 2. The Hamming-weight ("count") tie profile -/

/-- Tie profile of the Hamming-weight (popcount) statistic on `b`-bit words:
the block of weight `k` has size `C(b,k)`. -/
def binomBlocks (b : ℕ) : List ℕ := (List.range (b + 1)).map fun k => b.choose k

lemma binomBlocks_sum (b : ℕ) : (binomBlocks b).sum = 2 ^ b := by
  rw [binomBlocks, list_range_map_sum, Nat.sum_range_choose]

/-- **Combinatorial bridge.**  The tie blocks of the Hamming-weight statistic on the
Boolean cube `Finset (Fin b)` are its `k`-slices, of cardinality `C(b,k)`; so the
profile really is `binomBlocks b`. -/
theorem binomBlocks_eq_hamming_profile (b : ℕ) :
    binomBlocks b
      = (List.range (b + 1)).map fun k =>
          ((univ : Finset (Finset (Fin b))).filter fun S => S.card = k).card := by
  rw [binomBlocks]
  refine List.map_congr_left fun k _ => ?_
  have h : ((univ : Finset (Finset (Fin b))).filter fun S => S.card = k)
      = Finset.powersetCard k (univ : Finset (Fin b)) := by
    rw [Finset.powersetCard_eq_filter, Finset.powerset_univ]
  rw [h, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]

/-- The Franel-type cube sum of a binomial row. -/
def franel (b : ℕ) : ℕ := ∑ k ∈ range (b + 1), (b.choose k) ^ 3

/-- **Cube-to-square collapse.**  `Σₖ C(b,k)³ ≤ (max_k C(b,k))² · 2^b`. -/
theorem franel_le (b : ℕ) : franel b ≤ (b.choose (b / 2)) ^ 2 * 2 ^ b := by
  have hterm : ∀ k ∈ range (b + 1),
      (b.choose k) ^ 3 ≤ (b.choose (b / 2)) ^ 2 * b.choose k := by
    intro k _
    have h := Nat.choose_le_middle k b
    calc (b.choose k) ^ 3 = (b.choose k) ^ 2 * b.choose k := by ring
      _ ≤ (b.choose (b / 2)) ^ 2 * b.choose k := by
          exact Nat.mul_le_mul_right _ (Nat.pow_le_pow_left h 2)
  calc franel b ≤ ∑ k ∈ range (b + 1), (b.choose (b / 2)) ^ 2 * b.choose k :=
        Finset.sum_le_sum hterm
    _ = (b.choose (b / 2)) ^ 2 * ∑ k ∈ range (b + 1), b.choose k := by
        rw [Finset.mul_sum]
    _ = (b.choose (b / 2)) ^ 2 * 2 ^ b := by rw [Nat.sum_range_choose]

/-! ## 3. The central binomial bound `C(2n,n)² (3n+1) ≤ 16ⁿ` -/

/-- **Sharp central-binomial bound**, in a division-free form:
`C(2n,n)² · (3n+1) ≤ 16ⁿ`, i.e. `C(2n,n) ≤ 4ⁿ/√(3n+1)`.  Proved by induction using
`(n+1)·C(2n+2,n+1) = 2(2n+1)·C(2n,n)`; the inductive step reduces to the polynomial
inequality `(2n+1)²(3n+4) ≤ (2n+2)²(3n+1)`. -/
theorem centralBinom_sq_bound (n : ℕ) : (Nat.centralBinom n) ^ 2 * (3 * n + 1) ≤ 16 ^ n := by
  induction n with
  | zero => simp [Nat.centralBinom_zero]
  | succ n ih =>
      have hrec : (n + 1) * Nat.centralBinom (n + 1) = 2 * (2 * n + 1) * Nat.centralBinom n :=
        Nat.succ_mul_centralBinom_succ n
      have hstep : (2 * n + 1) ^ 2 * (3 * n + 4) ≤ (2 * n + 2) ^ 2 * (3 * n + 1) := by nlinarith
      have hpos : 0 < (n + 1) ^ 2 * (3 * n + 1) := by positivity
      have key :
          (Nat.centralBinom (n + 1)) ^ 2 * (3 * (n + 1) + 1) * ((n + 1) ^ 2 * (3 * n + 1))
            ≤ 16 ^ (n + 1) * ((n + 1) ^ 2 * (3 * n + 1)) := by
        calc (Nat.centralBinom (n + 1)) ^ 2 * (3 * (n + 1) + 1) * ((n + 1) ^ 2 * (3 * n + 1))
            = ((n + 1) * Nat.centralBinom (n + 1)) ^ 2 * ((3 * n + 4) * (3 * n + 1)) := by ring
          _ = (2 * (2 * n + 1) * Nat.centralBinom n) ^ 2 * ((3 * n + 4) * (3 * n + 1)) := by
              rw [hrec]
          _ = 4 * ((2 * n + 1) ^ 2 * (3 * n + 4)) * ((Nat.centralBinom n) ^ 2 * (3 * n + 1)) := by
              ring
          _ ≤ 4 * ((2 * n + 1) ^ 2 * (3 * n + 4)) * 16 ^ n := Nat.mul_le_mul_left _ ih
          _ ≤ 4 * ((2 * n + 2) ^ 2 * (3 * n + 1)) * 16 ^ n := by
              exact Nat.mul_le_mul_right _ (Nat.mul_le_mul_left _ hstep)
          _ = 16 ^ (n + 1) * ((n + 1) ^ 2 * (3 * n + 1)) := by ring
      exact Nat.le_of_mul_le_mul_right key hpos

/-- The Hamming profile at even bitlen `b = 2m` has cube sum at most `8^b/(3m+1)`. -/
theorem franel_even_bound (m : ℕ) : franel (2 * m) * (3 * m + 1) ≤ 8 ^ (2 * m) := by
  have hmid : (2 * m).choose (2 * m / 2) = Nat.centralBinom m := by
    rw [Nat.centralBinom_eq_two_mul_choose]
    congr 1
    omega
  have h1 : franel (2 * m) ≤ (Nat.centralBinom m) ^ 2 * 2 ^ (2 * m) := by
    have := franel_le (2 * m)
    rwa [hmid] at this
  calc franel (2 * m) * (3 * m + 1)
      ≤ (Nat.centralBinom m) ^ 2 * 2 ^ (2 * m) * (3 * m + 1) :=
        Nat.mul_le_mul_right _ h1
    _ = (Nat.centralBinom m) ^ 2 * (3 * m + 1) * 2 ^ (2 * m) := by ring
    _ ≤ 16 ^ m * 2 ^ (2 * m) := Nat.mul_le_mul_right _ (centralBinom_sq_bound m)
    _ = 8 ^ (2 * m) := by
        rw [show (16 : ℕ) = 2 ^ 4 by norm_num, show (8 : ℕ) = 2 ^ 3 by norm_num,
          ← pow_mul, ← pow_mul, ← pow_add]
        ring_nf

/-! ## 4. The tie correction and the ceiling of the count baseline -/

lemma tieCorr_binomBlocks (b : ℕ) :
    12 * tieCorr (binomBlocks b) = (franel b : ℚ) - 2 ^ b := by
  have h : tieCorr (binomBlocks b)
      = ∑ k ∈ range (b + 1), (((b.choose k : ℚ)) ^ 3 - (b.choose k : ℚ)) / 12 :=
    tieCorr_range_map b.choose (b + 1)
  rw [h, Finset.mul_sum]
  have h2 : ∀ k ∈ range (b + 1),
      12 * ((((b.choose k : ℚ)) ^ 3 - (b.choose k : ℚ)) / 12)
        = (((b.choose k) ^ 3 : ℕ) : ℚ) - ((b.choose k : ℕ) : ℚ) := by
    intro k _; push_cast; ring
  rw [Finset.sum_congr rfl h2, Finset.sum_sub_distrib]
  have h3 : ∑ k ∈ range (b + 1), (((b.choose k) ^ 3 : ℕ) : ℚ) = (franel b : ℚ) := by
    rw [franel]; push_cast; ring
  have h4 : ∑ k ∈ range (b + 1), ((b.choose k : ℕ) : ℚ) = (2 : ℚ) ^ b := by
    have := Nat.sum_range_choose b
    have hc : ((∑ k ∈ range (b + 1), b.choose k : ℕ) : ℚ) = ((2 ^ b : ℕ) : ℚ) := by
      exact_mod_cast congrArg (fun x : ℕ => (x : ℚ)) this
    push_cast at hc
    exact hc
  rw [h3, h4]

/-- **Count ceiling law.**  At every even bitlen `b = 2m ≥ 2`, the Spearman ceiling of the
Hamming-weight statistic against any refining response obeys
`ρ² ≥ 1 - 2/(3m+1) = 1 - 4/(3b+2)`. -/
theorem count_ceiling_ge (m : ℕ) (hm : 1 ≤ m) :
    1 - 2 / (3 * (m : ℚ) + 1) ≤ spearmanSq (binomBlocks (2 * m)) := by
  set b := 2 * m with hb
  have hb1 : 1 ≤ b := by omega
  have hsum : (binomBlocks b).sum = 2 ^ b := binomBlocks_sum b
  have h2 : 2 ≤ (binomBlocks b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb1
  have hcast : (((binomBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  -- the two exponential quantities
  have h8 : (4 : ℚ) ≤ (4 : ℚ) ^ b := by
    calc (4 : ℚ) = 4 ^ 1 := (pow_one 4).symm
      _ ≤ 4 ^ b := by apply pow_le_pow_right₀ (by norm_num) hb1
  have hpow2 : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have hden : ((2 : ℚ) ^ b) ^ 3 - 2 ^ b > 0 := by
    have : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
    rw [this]
    have : (2 : ℚ) ^ b * 4 ^ b = 8 ^ b := by
      rw [← mul_pow]; norm_num
    nlinarith
  -- the Franel bound, transported to ℚ
  have hfr : (franel b : ℚ) * (3 * (m : ℚ) + 1) ≤ (8 : ℚ) ^ b := by
    have hn : franel (2 * m) * (3 * m + 1) ≤ 8 ^ (2 * m) := franel_even_bound m
    have := (Nat.cast_le (α := ℚ)).2 hn
    push_cast at this
    rw [hb]
    convert this using 2
  have hm1 : (0 : ℚ) < 3 * (m : ℚ) + 1 := by positivity
  have hfr' : (franel b : ℚ) ≤ (8 : ℚ) ^ b / (3 * (m : ℚ) + 1) :=
    (le_div_iff₀ hm1).2 hfr
  -- the attenuation law
  have hlaw : spearmanSq (binomBlocks b)
      = 1 - 12 * tieCorr (binomBlocks b) / (((binomBlocks b).sum : ℚ) ^ 3 - (binomBlocks b).sum) :=
    spearmanSq_eq _ h2
  rw [hlaw, hcast, tieCorr_binomBlocks]
  have hcube : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have hhalf : (2 : ℚ) * 2 ^ b ≤ 8 ^ b := by
    have h : (2 : ℚ) ^ b * 4 ^ b = 8 ^ b := by rw [← mul_pow]; norm_num
    nlinarith
  have hkey : ((franel b : ℚ) - 2 ^ b) / (((2 : ℚ) ^ b) ^ 3 - 2 ^ b) ≤ 2 / (3 * (m : ℚ) + 1) := by
    rw [div_le_div_iff₀ (by rw [hcube] at hden ⊢; linarith) hm1]
    rw [hcube]
    have h1 : ((franel b : ℚ) - 2 ^ b) * (3 * (m : ℚ) + 1) ≤ (8 : ℚ) ^ b := by
      nlinarith [Nat.cast_nonneg (α := ℚ) (franel b)]
    nlinarith
  linarith

/-- Restatement of the count ceiling law directly in the bitlen. -/
theorem count_ceiling_ge_bitlen (m : ℕ) (hm : 1 ≤ m) :
    1 - 4 / (3 * ((2 * m : ℕ) : ℚ) + 2) ≤ spearmanSq (binomBlocks (2 * m)) := by
  have h := count_ceiling_ge m hm
  have : 1 - 4 / (3 * ((2 * m : ℕ) : ℚ) + 2) = 1 - 2 / (3 * (m : ℚ) + 1) := by
    have hm1 : (3 * (m : ℚ) + 1) ≠ 0 := by positivity
    push_cast
    field_simp
    ring
  rw [this]
  exact h

/-! ## 5. The inversion law: count has the higher ceiling -/

/-- The dyadic (trailing-zero) ceiling is below `6/7 + 2⁻ᵇ` for every bitlen. -/
lemma dyadic_ceiling_le (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks b) ≤ 6 / 7 + 1 / (2 : ℚ) ^ b := by
  rw [dyadic_spearmanSq b hb]
  have hpow : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := by apply pow_le_pow_right₀ (by norm_num) hb
  have hp : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have h1 : 1 / ((2 : ℚ) ^ b * (2 ^ b + 1)) ≤ 1 / (2 : ℚ) ^ b := by
    apply one_div_le_one_div_of_le hp
    nlinarith
  have h2 : (0 : ℚ) < 1 / (2 : ℚ) ^ b := by positivity
  nlinarith

/-- **Ceiling inversion.**  At every even bitlen `b = 2m ≥ 10`, the Hamming-weight (count)
statistic has a *strictly higher* tie ceiling than the trailing-zero statistic: the count
baseline is the less attenuated of the two, not the more attenuated one. -/
theorem ceiling_inversion (m : ℕ) (hm : 5 ≤ m) :
    spearmanSq (dyadicBlocks (2 * m)) < spearmanSq (binomBlocks (2 * m)) := by
  have hb1 : 1 ≤ 2 * m := by omega
  have hpow : (1024 : ℚ) ≤ (2 : ℚ) ^ (2 * m) := by
    calc (1024 : ℚ) = 2 ^ 10 := by norm_num
      _ ≤ 2 ^ (2 * m) := by apply pow_le_pow_right₀ (by norm_num) (by omega)
  have hup : spearmanSq (dyadicBlocks (2 * m)) ≤ 6 / 7 + 1 / (2 : ℚ) ^ (2 * m) :=
    dyadic_ceiling_le _ hb1
  have hsmall : 1 / (2 : ℚ) ^ (2 * m) ≤ 1 / 1024 := by
    apply one_div_le_one_div_of_le (by norm_num) hpow
  have hlow : 1 - 2 / (3 * (m : ℚ) + 1) ≤ spearmanSq (binomBlocks (2 * m)) :=
    count_ceiling_ge m (by omega)
  have hm5 : (5 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hden : (0 : ℚ) < 3 * (m : ℚ) + 1 := by positivity
  have hfrac : 2 / (3 * (m : ℚ) + 1) ≤ 1 / 8 := by
    rw [div_le_div_iff₀ hden (by norm_num)]
    linarith
  linarith

/-- The count ceiling converges to `1`: the popcount statistic is asymptotically
tie-transparent, whereas the trailing-zero ceiling stalls at `6/7`. -/
theorem count_ceiling_tendsto_one :
    Filter.Tendsto (fun m : ℕ => ((spearmanSq (binomBlocks (2 * m)) : ℚ) : ℝ))
      Filter.atTop (nhds 1) := by
  have hlow : Filter.Tendsto (fun m : ℕ => 1 - 2 / (3 * (m : ℝ) + 1)) Filter.atTop (nhds 1) := by
    have h0 : Filter.Tendsto (fun m : ℕ => 2 / (3 * (m : ℝ) + 1)) Filter.atTop (nhds 0) := by
      have := Filter.Tendsto.const_div_atTop
        (Filter.tendsto_atTop_add_const_right Filter.atTop (1 : ℝ)
          (Filter.Tendsto.const_mul_atTop (by norm_num : (0:ℝ) < 3) tendsto_natCast_atTop_atTop))
        (2 : ℝ)
      exact this
    simpa using Filter.Tendsto.const_sub (1 : ℝ) h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop 1] with m hm
    have := count_ceiling_ge m hm
    have := (Rat.cast_le (K := ℝ)).2 this
    push_cast at this ⊢
    exact this
  · filter_upwards [Filter.eventually_ge_atTop 1] with m hm
    have hb1 : 1 ≤ 2 * m := by omega
    have h2 : 2 ≤ (binomBlocks (2 * m)).sum := by
      rw [binomBlocks_sum]
      calc 2 = 2 ^ 1 := rfl
        _ ≤ 2 ^ (2 * m) := Nat.pow_le_pow_right (by norm_num) hb1
    have := spearmanSq_le_one _ h2
    exact_mod_cast (Rat.cast_le (K := ℝ)).2 this

/-! ## 6. The recorded round-58 numbers -/

/-- Seed 20261120. -/
def seed20 : ℚ := 698 / 1000
/-- Seed 20261121. -/
def seed21 : ℚ := 697 / 1000
/-- Seed 20261122. -/
def seed22 : ℚ := 720 / 1000
/-- Pooled dial reading at bitlen 52. -/
def pooled52 : ℚ := 705 / 1000
/-- Pooled advantage of the dial over the count baseline. -/
def advantage : ℚ := 70 / 1000
/-- Lower endpoint of the advantage CI. -/
def advLow : ℚ := 46 / 1000
/-- Upper endpoint of the advantage CI. -/
def advHigh : ℚ := 93 / 1000
/-- The implied pooled reading of the count baseline. -/
def countPooled : ℚ := pooled52 - advantage

theorem unif52_inside_band :
    (55 / 100 : ℚ) ≤ seed20 ∧ seed20 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ seed21 ∧ seed21 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ seed22 ∧ seed22 ≤ 85 / 100 := by
  refine ⟨by norm_num [seed20], by norm_num [seed20], by norm_num [seed21], by norm_num [seed21],
    by norm_num [seed22], by norm_num [seed22]⟩

theorem unif52_pooled_is_seed_mean : pooled52 = (seed20 + seed21 + seed22) / 3 := by
  norm_num [pooled52, seed20, seed21, seed22]

theorem unif52_advantage_inside_ci : advLow ≤ advantage ∧ advantage ≤ advHigh ∧ 0 < advLow := by
  refine ⟨by norm_num [advLow, advantage], by norm_num [advantage, advHigh],
    by norm_num [advLow]⟩

/-- The pooled reading sits strictly below the exact dyadic tie ceiling at bitlen 52. -/
theorem unif52_below_tie_ceiling : pooled52 ^ 2 < spearmanSq (dyadicBlocks 52) := by
  rw [dyadic_spearmanSq 52 (by norm_num)]
  have h : (0 : ℚ) < 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1)) := by positivity
  have : pooled52 ^ 2 ≤ 6 / 7 := by norm_num [pooled52]
  nlinarith

/-- Every individual seed reading is below the dyadic ceiling as well. -/
theorem unif52_seeds_below_tie_ceiling :
    seed20 ^ 2 < spearmanSq (dyadicBlocks 52) ∧
    seed21 ^ 2 < spearmanSq (dyadicBlocks 52) ∧
    seed22 ^ 2 < spearmanSq (dyadicBlocks 52) := by
  rw [dyadic_spearmanSq 52 (by norm_num)]
  have h : (0 : ℚ) < 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1)) := by positivity
  refine ⟨?_, ?_, ?_⟩ <;>
    [ (have : seed20 ^ 2 ≤ 6 / 7 := by norm_num [seed20]);
      (have : seed21 ^ 2 ≤ 6 / 7 := by norm_num [seed21]);
      (have : seed22 ^ 2 ≤ 6 / 7 := by norm_num [seed22]) ] <;> nlinarith

/-- The count ceiling at bitlen 52 is at least `0.974`. -/
theorem count_ceiling_52 : (1 - 2 / 79 : ℚ) ≤ spearmanSq (binomBlocks 52) := by
  have h := count_ceiling_ge 26 (by norm_num)
  norm_num at h
  linarith

/-- At bitlen 52 the count baseline sits far below *its own* ceiling. -/
theorem count_below_its_ceiling : countPooled ^ 2 < spearmanSq (binomBlocks 52) := by
  have h := count_ceiling_52
  have : countPooled ^ 2 = (635 / 1000 : ℚ) ^ 2 := by norm_num [countPooled, pooled52, advantage]
  rw [this]
  norm_num at h ⊢
  linarith

/-- **The advantage is not a tie artefact.**  The zero-fit dial reads `0.070` *higher* than
the count baseline, yet the count baseline is the statistic with the *higher* tie ceiling.
So the observed ordering of the two readings is opposite to the ordering forced by rank
ties; no amount of tie/quantisation bookkeeping can produce the recorded advantage. -/
theorem count_advantage_not_tie_artefact :
    countPooled < pooled52 ∧
      spearmanSq (dyadicBlocks 52) < spearmanSq (binomBlocks 52) := by
  refine ⟨by norm_num [countPooled, pooled52, advantage], ?_⟩
  have h := ceiling_inversion 26 (by norm_num)
  norm_num at h
  exact h

/-- **Deficit comparison.**  Measured against its own tie ceiling, the count baseline wastes
strictly more resolving power than the dial does: the gap between the two deficits exceeds
`1/5`. -/
theorem count_deficit_exceeds_dial_deficit :
    (1 : ℚ) / 5 <
      (spearmanSq (binomBlocks 52) - countPooled ^ 2)
        - (spearmanSq (dyadicBlocks 52) - pooled52 ^ 2) := by
  have hcount : (1 - 2 / 79 : ℚ) ≤ spearmanSq (binomBlocks 52) := count_ceiling_52
  have hdy : spearmanSq (dyadicBlocks 52) ≤ 6 / 7 + 1 / (2 : ℚ) ^ 52 :=
    dyadic_ceiling_le 52 (by norm_num)
  have hsmall : 1 / (2 : ℚ) ^ 52 ≤ 1 / 1024 := by
    apply one_div_le_one_div_of_le (by norm_num)
    calc (1024 : ℚ) = 2 ^ 10 := by norm_num
      _ ≤ 2 ^ 52 := by apply pow_le_pow_right₀ (by norm_num) (by norm_num)
  have hc : countPooled ^ 2 = (635 / 1000 : ℚ) ^ 2 := by
    norm_num [countPooled, pooled52, advantage]
  rw [hc]
  norm_num [pooled52] at *
  linarith

end Catalog.MachineLearning.ZeroFitDialUnif52