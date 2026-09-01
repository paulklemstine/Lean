import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.TDialU100RangeShape

/-!
# Dyadic domination: a sampler-free lower bound for the zero-fit dial's tie ceiling

## Research context (FACT round-67 #2, exp 540, `TDIAL-U100`)

`Novelty.TDialU100RangeShape` computes the tie ceiling of the trailing-zero statistic
exactly, for uniform draws from `{0,…,n−1}`, and finds it to be `6/7 + O(1/n)` for **every**
`n`.  That still assumes the sampler starts at `0`.  Real bitlen-100 draws are usually taken
from an *offset* window such as `[2⁹⁹, 2¹⁰⁰)`, from a residue class, or from a stream whose
tie blocks are only *approximately* geometric.

This file removes the assumption.  Call a tie profile `L` **dyadically dominated at scale `x`
with slack `C`** when its `i`-th block obeys `mᵢ ≤ x/2^{i+1} + C`.  Every sampler drawing from
an interval of length `x` satisfies this with a small `C`, because the draws of 2-adic
valuation `i` inside an interval are `2^{i+1}`-separated.

## Main results

* `cubeSum_le_of_dominated` — the cube-sum bound
  `Σ mᵢ³ ≤ x³/7 + C·x² + 3C²·x + C³·(#blocks)`.
  The induction balances *all four* coefficients exactly:
  `1/8 + 1/56 = 1/7`, `3C/4 + C/4 = C`, `3C²/2 + 3C²/2 = 3C²`, `C³ + C³·len' = C³·len`;
  the `x³/7` term is the geometric-series fixed point that produces the `6/7` ceiling.
* `dominated_spearmanSq_lower` — hence for any dominated profile with `n = Σ mᵢ ≥ 2`,
  `ρ² ≥ 6/7 − (C n² + 3C² n + C³ · #blocks)/(n³ − n)`.
* `rangeBlocks_entry_le`, `rangeBlocks_dominated` — the profiles of
  `Novelty.TDialU100RangeShape` are dominated with slack `1`, so the abstract bound is
  non-vacuous and re-derives the lower half of the universal range law by an independent
  route (`rangeBlocks_dominated_lower`).
* `u100_below_every_dominated_ceiling` — the recorded bitlen-100 pooled value `0.544` is below
  the ceiling of **every** dyadically dominated sampler at bitlen 100 with slack `C ≤ 4`.
  Together with the range-shape theorem this closes the "the sampler did it" family of
  explanations for the first band miss on uniform draws.
-/

open Finset

namespace Catalog.Novelty.TDialU100DyadicDomination

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.TDialU100RangeShape

/-! ## 1. Dyadic domination -/

/-- A tie profile is *dyadically dominated at scale `x` with slack `C`* when its `i`-th block
has size at most `x/2^{i+1} + C` (blocks past the end of the list count as empty).  This is
exactly the geometry produced by drawing from an interval of length `x`: the draws of 2-adic
valuation `i` are `2^{i+1}`-separated. -/
def DyadicDominated (L : List ℕ) (x C : ℚ) : Prop :=
  ∀ i : ℕ, ((L.getD i 0 : ℕ) : ℚ) ≤ x / 2 ^ (i + 1) + C

lemma dominated_head {m : ℕ} {L : List ℕ} {x C : ℚ} (h : DyadicDominated (m :: L) x C) :
    (m : ℚ) ≤ x / 2 + C := by
  have h0 := h 0
  simpa using h0

lemma dominated_tail {m : ℕ} {L : List ℕ} {x C : ℚ} (h : DyadicDominated (m :: L) x C) :
    DyadicDominated L (x / 2) C := by
  intro i
  have h1 := h (i + 1)
  have hget : (m :: L).getD (i + 1) 0 = L.getD i 0 := by simp
  rw [hget] at h1
  calc ((L.getD i 0 : ℕ) : ℚ) ≤ x / 2 ^ (i + 1 + 1) + C := h1
    _ = x / 2 / 2 ^ (i + 1) + C := by rw [pow_succ]; ring_nf

/-- **The dyadic cube-sum bound.**  Every dyadically dominated profile has cube sum at most
`x³/7 + C x² + 3C² x + C³·(#blocks)`. -/
theorem cubeSum_le_of_dominated :
    ∀ (L : List ℕ) (x C : ℚ), 0 ≤ x → 0 ≤ C → DyadicDominated L x C →
      cubeSum L ≤ x ^ 3 / 7 + C * x ^ 2 + 3 * C ^ 2 * x + C ^ 3 * (L.length : ℚ) := by
  intro L
  induction L with
  | nil =>
      intro x C hx hC _
      simp only [cubeSum, List.length_nil, Nat.cast_zero]
      positivity
  | cons m L ih =>
      intro x C hx hC h
      have hhead : (m : ℚ) ≤ x / 2 + C := dominated_head h
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hcube : (m : ℚ) ^ 3 ≤ (x / 2 + C) ^ 3 := by
        have := pow_le_pow_left₀ hm0 hhead 3
        simpa using this
      have htail := ih (x / 2) C (by linarith) hC (dominated_tail h)
      have hlen : ((m :: L).length : ℚ) = (L.length : ℚ) + 1 := by
        simp
      rw [cubeSum_cons, hlen]
      nlinarith [hcube, htail]

/-- **Sampler-free ceiling bound.**  Any dyadically dominated tie profile with sample size
`n = Σ mᵢ ≥ 2` has Spearman tie ceiling at least `6/7` minus an explicit `O(1/n)` term. -/
theorem dominated_spearmanSq_lower (L : List ℕ) (C : ℚ) (hC : 0 ≤ C) (h2 : 2 ≤ L.sum)
    (hdom : DyadicDominated L (L.sum : ℚ) C) :
    6 / 7 - (C * ((L.sum : ℚ)) ^ 2 + 3 * C ^ 2 * (L.sum : ℚ) + C ^ 3 * (L.length : ℚ))
        / (((L.sum : ℚ)) ^ 3 - (L.sum : ℚ))
      ≤ spearmanSq L := by
  set n : ℚ := (L.sum : ℚ) with hn
  set B : ℚ := C * n ^ 2 + 3 * C ^ 2 * n + C ^ 3 * (L.length : ℚ) with hB
  have hq : (2 : ℚ) ≤ n := by rw [hn]; exact_mod_cast h2
  have hden : (0 : ℚ) < n ^ 3 - n := cube_sub_self_pos hq
  have hn0 : n ≠ 0 := by positivity
  have hnn : n ^ 2 - 1 ≠ 0 := by nlinarith [sq_nonneg (n - 2)]
  have hcube : cubeSum L ≤ n ^ 3 / 7 + B := by
    have := cubeSum_le_of_dominated L n C (by linarith) hC hdom
    rw [hB]; linarith
  rw [spearmanSq_eq _ h2, tieCorr_eq_cubeSum, ← hn]
  have hstep : 12 * ((cubeSum L - n) / 12) / (n ^ 3 - n)
      ≤ (n ^ 3 / 7 + B - n) / (n ^ 3 - n) := by
    gcongr
    linarith
  have hkey : (n ^ 3 / 7 + B - n) / (n ^ 3 - n) + (6 * n / 7) / (n ^ 3 - n)
      = 1 / 7 + B / (n ^ 3 - n) := by
    field_simp
    ring
  have hpos : 0 ≤ (6 * n / 7) / (n ^ 3 - n) := by
    apply div_nonneg (by linarith) (le_of_lt hden)
  linarith

/-! ## 2. The range profiles are dominated -/

/-- The `i`-th block of the range profile of `{0,…,n−1}` is at most `(x−1)/2^{i+1} + 1`
whenever `x ≥ n`.  The shifted numerator `(x−1)` is what makes the induction close exactly:
the tail is the profile of `⌈n/2⌉`, and `(x+1)/2 − 1 = (x−1)/2`. -/
theorem rangeBlocks_entry_le :
    ∀ (n : ℕ) (x : ℚ), (n : ℚ) ≤ x → 0 ≤ x →
      ∀ i : ℕ, (((rangeBlocks n).getD i 0 : ℕ) : ℚ) ≤ (x - 1) / 2 ^ (i + 1) + 1 := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n, ih with
    | 0, _ =>
        intro x _ hx0 i
        have hzero : ((rangeBlocks 0).getD i 0 : ℕ) = 0 := by simp [rangeBlocks]
        rw [hzero]
        have hp : (0 : ℚ) < 2 ^ (i + 1) := by positivity
        have h1 : (2 : ℚ) ≤ 2 ^ (i + 1) := by
          calc (2 : ℚ) = 2 ^ 1 := by norm_num
            _ ≤ 2 ^ (i + 1) := by
                apply pow_le_pow_right₀ (by norm_num) (by omega)
        have h2 : (-1 : ℚ) / 2 ^ (i + 1) ≤ (x - 1) / 2 ^ (i + 1) := by
          gcongr
          linarith
        have h3 : (-1 : ℚ) / 2 ^ (i + 1) ≥ -1 / 2 := by
          rw [ge_iff_le, div_le_div_iff₀ (by norm_num) hp]
          linarith
        linarith
    | 1, _ =>
        intro x hx hx0 i
        have hx1 : (1 : ℚ) ≤ x := by simpa using hx
        have hp : (0 : ℚ) < 2 ^ (i + 1) := by positivity
        have hnonneg : (0 : ℚ) ≤ (x - 1) / 2 ^ (i + 1) := by
          apply div_nonneg (by linarith) (le_of_lt hp)
        match i with
        | 0 =>
            have hval : ((rangeBlocks 1).getD 0 0 : ℕ) = 1 := by simp [rangeBlocks]
            rw [hval]
            push_cast
            linarith
        | (j + 1) =>
            have hval : ((rangeBlocks 1).getD (j + 1) 0 : ℕ) = 0 := by simp [rangeBlocks]
            rw [hval]
            push_cast
            linarith
    | (k + 2), ih =>
        intro x hx hx0 i
        set n : ℕ := k + 2 with hndef
        have hrec : rangeBlocks n = n / 2 :: rangeBlocks ((n + 1) / 2) :=
          rangeBlocks_ge_two (by omega)
        match i with
        | 0 =>
            have hval : ((rangeBlocks n).getD 0 0 : ℕ) = n / 2 := by rw [hrec]; simp
            rw [hval]
            have hdiv : ((n / 2 : ℕ) : ℚ) ≤ (n : ℚ) / 2 := Nat.cast_div_le
            have hxn : (n : ℚ) ≤ x := hx
            have : (n : ℚ) / 2 ≤ (x - 1) / 2 ^ (0 + 1) + 1 := by
              simp only [pow_one, zero_add]
              linarith
            linarith
        | (j + 1) =>
            have hval : ((rangeBlocks n).getD (j + 1) 0 : ℕ)
                = ((rangeBlocks ((n + 1) / 2)).getD j 0 : ℕ) := by rw [hrec]; simp
            rw [hval]
            have hm : (((n + 1) / 2 : ℕ) : ℚ) ≤ (x + 1) / 2 := by
              have h1 : (((n + 1) / 2 : ℕ) : ℚ) ≤ ((n + 1 : ℕ) : ℚ) / 2 := Nat.cast_div_le
              have h2 : ((n + 1 : ℕ) : ℚ) = (n : ℚ) + 1 := by push_cast; ring
              rw [h2] at h1
              have h3 : (n : ℚ) + 1 ≤ x + 1 := by linarith
              linarith
            have hIH := ih ((n + 1) / 2) (by omega) ((x + 1) / 2) hm (by linarith) j
            calc (((rangeBlocks ((n + 1) / 2)).getD j 0 : ℕ) : ℚ)
                ≤ ((x + 1) / 2 - 1) / 2 ^ (j + 1) + 1 := hIH
              _ = (x - 1) / 2 ^ (j + 1 + 1) + 1 := by
                  rw [pow_succ]
                  have hp : (0 : ℚ) < 2 ^ (j + 1) := by positivity
                  field_simp
                  ring

/-- The range profiles are dyadically dominated with slack `1`. -/
theorem rangeBlocks_dominated (n : ℕ) : DyadicDominated (rangeBlocks n) ((n : ℚ)) 1 := by
  intro i
  have h := rangeBlocks_entry_le n (n : ℚ) le_rfl (by positivity) i
  have hpow : (0 : ℚ) < 2 ^ (i + 1) := by positivity
  have hmono : ((n : ℚ) - 1) / 2 ^ (i + 1) ≤ (n : ℚ) / 2 ^ (i + 1) := by
    gcongr
    linarith
  linarith

/-- The abstract bound applied to the concrete range profiles: an independent second proof
that every uniform range has ceiling at least `6/7 − O(1/n)` (up to the block-count term,
which the exact computation of `Novelty.TDialU100RangeShape` removes). -/
theorem rangeBlocks_dominated_lower (n : ℕ) (hn : 2 ≤ n) :
    6 / 7 - ((n : ℚ) ^ 2 + 3 * (n : ℚ) + ((rangeBlocks n).length : ℚ))
        / ((n : ℚ) ^ 3 - (n : ℚ))
      ≤ spearmanSq (rangeBlocks n) := by
  have hsum : (rangeBlocks n).sum = n := rangeBlocks_sum n
  have h2 : 2 ≤ (rangeBlocks n).sum := by rw [hsum]; exact hn
  have hdom : DyadicDominated (rangeBlocks n) (((rangeBlocks n).sum : ℚ)) 1 := by
    rw [hsum]; exact rangeBlocks_dominated n
  have h := dominated_spearmanSq_lower (rangeBlocks n) 1 (by norm_num) h2 hdom
  rw [hsum] at h
  simpa using h

/-! ## 3. The bitlen-100 application -/

/-- **No dominated sampler explains the band miss.**  For every tie profile at bitlen 100
(sample size `n ≥ 2¹⁰⁰`) that is dyadically dominated with slack `C ≤ 4` and has at most `n`
blocks, the Spearman ceiling stays above `6/7 − 1/100 > 0.85`, while the recorded pooled
reading squares to `0.544² ≈ 0.296`.  The first band miss on uniform draws is not a sampler
artefact. -/
theorem u100_below_every_dominated_ceiling (L : List ℕ) (C : ℚ) (hC0 : 0 ≤ C) (hC : C ≤ 4)
    (hn : 2 ^ 100 ≤ L.sum) (hlen : L.length ≤ L.sum)
    (hdom : DyadicDominated L (L.sum : ℚ) C) :
    pooled100 ^ 2 < spearmanSq L := by
  have h2 : 2 ≤ L.sum := le_trans (by norm_num) hn
  have hq : ((2 : ℚ)) ^ 100 ≤ (L.sum : ℚ) := by exact_mod_cast hn
  have hlenq : ((L.length : ℚ)) ≤ (L.sum : ℚ) := by exact_mod_cast hlen
  set n : ℚ := (L.sum : ℚ) with hndef
  have hn2 : (2 : ℚ) ≤ n := by rw [hndef]; exact_mod_cast h2
  have hbig : (10 : ℚ) ^ 4 ≤ n := by
    have h : (10 : ℚ) ^ 4 ≤ (2 : ℚ) ^ 100 := by norm_num
    linarith
  have hden : (0 : ℚ) < n ^ 3 - n := cube_sub_self_pos hn2
  have hmain := dominated_spearmanSq_lower L C hC0 h2 hdom
  have hlen0 : (0 : ℚ) ≤ (L.length : ℚ) := by positivity
  have herr : (C * n ^ 2 + 3 * C ^ 2 * n + C ^ 3 * (L.length : ℚ)) / (n ^ 3 - n) ≤ 1 / 100 := by
    rw [div_le_div_iff₀ hden (by norm_num)]
    have hnpos : (0 : ℚ) < n := by linarith
    have h1 : C * n ^ 2 ≤ 4 * n ^ 2 := by nlinarith [sq_nonneg n]
    have h2 : 3 * C ^ 2 * n ≤ 48 * n := by nlinarith
    have hC3 : C ^ 3 ≤ 64 := by nlinarith
    have h3 : C ^ 3 * (L.length : ℚ) ≤ 64 * n := by nlinarith
    have hn3 : 10000 * n ^ 2 ≤ n ^ 3 := by nlinarith [sq_nonneg n]
    have hn2' : 10000 * n ≤ n ^ 2 := by nlinarith
    linarith
  have hp : pooled100 ^ 2 < 6 / 7 - 1 / 100 := by norm_num [pooled100]
  linarith

end Catalog.Novelty.TDialU100DyadicDomination