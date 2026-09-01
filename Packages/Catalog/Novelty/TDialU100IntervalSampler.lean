import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.TDialU100RangeShape
import Novelty.TDialU100DyadicDomination

/-!
# Offset windows: the arithmetic bridge from 2-adic valuations to the dial's tie ceiling

## Research context (FACT round-67 #2, exp 540, `TDIAL-U100`)

`Novelty.TDialU100DyadicDomination` proves a ceiling bound for every *dyadically dominated*
tie profile, but domination was a hypothesis.  Here it becomes a **theorem** about the actual
arithmetic of the sampler: for an arbitrary window `[A, A+n)` of the integers the draws of
2-adic valuation `k` are exactly the elements congruent to `2^k` modulo `2^{k+1}`, hence
`2^{k+1}`-separated, hence at most `n/2^{k+1} + 2` of them.

This is the piece that upgrades the bitlen-100 conclusion from "ranges starting at 0" to
"every uniform window whatsoever", including the canonical bitlen-100 window `[2⁹⁹, 2¹⁰⁰)`.

## Main results

* `mod_eq_of_padicValNat` — `v₂(x) = k → x ≡ 2^k (mod 2^{k+1})`, the separation mechanism.
* `intervalBlock_le` — the counting bound `#{x ∈ [A,A+n) : v₂(x) = k} ≤ n/2^{k+1} + 2`,
  proved by injecting the block into an interval of quotients.
* `intervalBlocks_sum` — the blocks partition the window: `Σ_{k<K} mₖ = n` whenever
  `1 ≤ A` and `A + n ≤ 2^K`.
* `intervalBlocks_dominated` — hence the window profile is dyadically dominated with slack `2`.
* `interval_window_ceiling` — the resulting ceiling bound
  `ρ² ≥ 6/7 − (2n² + 12n + 8K)/(n³ − n)` for every offset window.
* `interval_window_below_pooled`, `u100_canonical_window` — the recorded bitlen-100 pooled
  reading `0.544` is below the tie ceiling of every offset window of length `n ≥ 10⁴`, and in
  particular below that of the canonical window `[2⁹⁹, 2¹⁰⁰)`.  The band miss at bitlen 100
  survives every re-description of the sampler.
-/

open Finset

namespace Catalog.Novelty.TDialU100IntervalSampler

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.TDialU100RangeShape
open Catalog.Novelty.TDialU100DyadicDomination

/-! ## 1. The separation mechanism -/

/-- If `x` has 2-adic valuation `k` then `x ≡ 2^k (mod 2^{k+1})`.  Consequently two draws of
the same valuation differ by at least `2^{k+1}`. -/
theorem mod_eq_of_padicValNat {x k : ℕ} (hx : x ≠ 0) (h : padicValNat 2 x = k) :
    x % 2 ^ (k + 1) = 2 ^ k := by
  obtain ⟨m, hm⟩ : 2 ^ k ∣ x := by rw [← h]; exact pow_padicValNat_dvd
  have hmodd : m % 2 = 1 := by
    rcases Nat.even_or_odd m with ⟨t, ht⟩ | ho
    · exfalso
      have hdvd : 2 ^ (k + 1) ∣ x := ⟨t, by rw [hm, ht]; ring⟩
      have hle := (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hx).1 hdvd
      rw [Nat.factorization_def _ Nat.prime_two, h] at hle
      omega
    · exact Nat.odd_iff.mp ho
  rw [hm]
  have h2 : (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := by ring
  rw [h2, Nat.mul_mod_mul_left, hmodd, mul_one]

/-! ## 2. The tie profile of an offset window -/

/-- The `k`-th tie block of the window `[A, A+n)`: the draws of 2-adic valuation `k`. -/
def intervalBlock (A n k : ℕ) : ℕ :=
  ((Finset.Ico A (A + n)).filter (fun x => padicValNat 2 x = k)).card

/-- **Counting bound.**  A window of length `n` contains at most `n/2^{k+1} + 2` draws of
2-adic valuation `k`, because they are `2^{k+1}`-separated. -/
theorem intervalBlock_le (A n k : ℕ) (hA : 1 ≤ A) :
    (intervalBlock A n k : ℚ) ≤ (n : ℚ) / 2 ^ (k + 1) + 2 := by
  set d : ℕ := 2 ^ (k + 1) with hd
  have hdpos : 0 < d := by rw [hd]; positivity
  set S : Finset ℕ := (Finset.Ico A (A + n)).filter (fun x => padicValNat 2 x = k) with hS
  have hmaps : ∀ x ∈ S, x / d ∈ Finset.Icc (A / d) ((A + n) / d) := by
    intro x hx
    rw [hS, Finset.mem_filter, Finset.mem_Ico] at hx
    refine Finset.mem_Icc.2 ⟨Nat.div_le_div_right hx.1.1, Nat.div_le_div_right (le_of_lt hx.1.2)⟩
  have hinj : ∀ x ∈ S, ∀ y ∈ S, x / d = y / d → x = y := by
    intro x hx y hy hxy
    rw [hS, Finset.mem_filter, Finset.mem_Ico] at hx hy
    have hx0 : x ≠ 0 := by omega
    have hy0 : y ≠ 0 := by omega
    have hxm : x % d = 2 ^ k := mod_eq_of_padicValNat hx0 hx.2
    have hym : y % d = 2 ^ k := mod_eq_of_padicValNat hy0 hy.2
    have hx' : d * (x / d) + x % d = x := Nat.div_add_mod x d
    have hy' : d * (y / d) + y % d = y := Nat.div_add_mod y d
    rw [hxy, hxm] at hx'
    rw [hym] at hy'
    omega
  have hcard : S.card ≤ (Finset.Icc (A / d) ((A + n) / d)).card :=
    Finset.card_le_card_of_injOn (fun x => x / d) hmaps hinj
  have hIcc : (Finset.Icc (A / d) ((A + n) / d)).card = (A + n) / d + 1 - A / d := by
    rw [Nat.card_Icc]
  set p : ℕ := (A + n) / d with hp
  set q : ℕ := A / d with hq
  have hqp : q ≤ p := Nat.div_le_div_right (by omega)
  have hcard' : (intervalBlock A n k : ℕ) ≤ p + 1 - q := by
    rw [intervalBlock, ← hS]
    calc S.card ≤ (Finset.Icc q p).card := hcard
      _ = p + 1 - q := by rw [Nat.card_Icc]
  -- numeric bounds on the quotients
  have hdp : d * p ≤ A + n := by
    have := Nat.div_mul_le_self (A + n) d
    calc d * p = p * d := by ring
      _ ≤ A + n := this
  have hqd : A < d * q + d := by
    have h1 : d * q + A % d = A := Nat.div_add_mod A d
    have h2 : A % d < d := Nat.mod_lt _ hdpos
    omega
  have hdq : (d : ℚ) * (p : ℚ) ≤ (A : ℚ) + (n : ℚ) := by exact_mod_cast hdp
  have hqq : (A : ℚ) < (d : ℚ) * (q : ℚ) + (d : ℚ) := by exact_mod_cast hqd
  have hdq0 : (0 : ℚ) < (d : ℚ) := by exact_mod_cast hdpos
  have hcast : ((p + 1 - q : ℕ) : ℚ) = (p : ℚ) + 1 - (q : ℚ) := by
    have : q ≤ p + 1 := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hkey : (p : ℚ) + 1 - (q : ℚ) ≤ (n : ℚ) / (d : ℚ) + 2 := by
    rw [div_add' _ _ _ (ne_of_gt hdq0), le_div_iff₀ hdq0]
    nlinarith
  have hfin : (intervalBlock A n k : ℚ) ≤ (p : ℚ) + 1 - (q : ℚ) := by
    have : ((intervalBlock A n k : ℕ) : ℚ) ≤ ((p + 1 - q : ℕ) : ℚ) := by exact_mod_cast hcard'
    rw [hcast] at this
    exact this
  have hdcast : ((d : ℕ) : ℚ) = (2 : ℚ) ^ (k + 1) := by rw [hd]; push_cast; ring
  rw [hdcast] at hkey
  linarith

/-- The window profile, as a list of `K` blocks. -/
def intervalBlocks (A n K : ℕ) : List ℕ := (List.range K).map (fun k => intervalBlock A n k)

lemma intervalBlocks_length (A n K : ℕ) : (intervalBlocks A n K).length = K := by
  simp [intervalBlocks]

lemma intervalBlocks_getD (A n K i : ℕ) :
    (intervalBlocks A n K).getD i 0 = if i < K then intervalBlock A n i else 0 := by
  by_cases h : i < K
  · have hlt : i < (intervalBlocks A n K).length := by
      rw [intervalBlocks_length]; exact h
    rw [List.getD_eq_getElem _ _ hlt]
    simp [intervalBlocks, h]
  · have : (intervalBlocks A n K).length ≤ i := by
      rw [intervalBlocks_length]; omega
    rw [List.getD_eq_default _ _ this]
    simp [h]

/-- **The blocks partition the window.**  If the window avoids `0` and fits below `2^K`, the
`K` valuation blocks account for all `n` draws. -/
theorem intervalBlocks_sum (A n K : ℕ) (hA : 1 ≤ A) (hK : A + n ≤ 2 ^ K) :
    (intervalBlocks A n K).sum = n := by
  have hmaps : Set.MapsTo (fun x => padicValNat 2 x) (Finset.Ico A (A + n) : Finset ℕ)
      (Finset.range K : Finset ℕ) := by
    intro x hx
    simp only [Finset.coe_Ico, Set.mem_Ico] at hx
    have hx0 : x ≠ 0 := by omega
    have hdvd : 2 ^ padicValNat 2 x ∣ x := pow_padicValNat_dvd
    have hle : 2 ^ padicValNat 2 x ≤ x := Nat.le_of_dvd (by omega) hdvd
    have hlt : (2 : ℕ) ^ padicValNat 2 x < 2 ^ K := by omega
    have : padicValNat 2 x < K := by
      exact (Nat.pow_lt_pow_iff_right (by norm_num)).1 hlt
    simpa using this
  have hcard := Finset.card_eq_sum_card_fiberwise hmaps
  have hIco : (Finset.Ico A (A + n)).card = n := by rw [Nat.card_Ico]; omega
  have hsum : ∀ m : ℕ, (intervalBlocks A n m).sum = ∑ k ∈ Finset.range m, intervalBlock A n k := by
    intro m
    induction m with
    | zero => simp [intervalBlocks]
    | succ t ih =>
        rw [intervalBlocks, List.range_succ, List.map_append, List.sum_append,
          Finset.sum_range_succ, ← intervalBlocks, ih]
        simp
  have hfib : ∑ k ∈ Finset.range K, intervalBlock A n k = (Finset.Ico A (A + n)).card := by
    rw [hcard]
    rfl
  rw [hsum K, hfib, hIco]

/-- **Windows are dyadically dominated with slack 2.** -/
theorem intervalBlocks_dominated (A n K : ℕ) (hA : 1 ≤ A) :
    DyadicDominated (intervalBlocks A n K) ((n : ℚ)) 2 := by
  intro i
  rw [intervalBlocks_getD]
  by_cases h : i < K
  · simp only [h, if_true]
    exact intervalBlock_le A n i hA
  · simp only [h, if_false, Nat.cast_zero]
    have : (0 : ℚ) ≤ (n : ℚ) / 2 ^ (i + 1) := by positivity
    linarith

/-! ## 3. The ceiling of an offset window -/

/-- **Ceiling bound for an arbitrary offset window.**  Every uniform window `[A, A+n)` with
`1 ≤ A` and `A + n ≤ 2^K` has Spearman tie ceiling at least `6/7 − (2n² + 12n + 8K)/(n³ − n)`. -/
theorem interval_window_ceiling (A n K : ℕ) (hA : 1 ≤ A) (hK : A + n ≤ 2 ^ K) (hn : 2 ≤ n) :
    6 / 7 - (2 * (n : ℚ) ^ 2 + 12 * (n : ℚ) + 8 * (K : ℚ)) / ((n : ℚ) ^ 3 - (n : ℚ))
      ≤ spearmanSq (intervalBlocks A n K) := by
  have hsum : (intervalBlocks A n K).sum = n := intervalBlocks_sum A n K hA hK
  have h2 : 2 ≤ (intervalBlocks A n K).sum := by rw [hsum]; exact hn
  have hdom : DyadicDominated (intervalBlocks A n K) (((intervalBlocks A n K).sum : ℚ)) 2 := by
    rw [hsum]; exact intervalBlocks_dominated A n K hA
  have h := dominated_spearmanSq_lower (intervalBlocks A n K) 2 (by norm_num) h2 hdom
  rw [hsum, intervalBlocks_length] at h
  have hnorm : (2 : ℚ) * (n : ℚ) ^ 2 + 3 * (2 : ℚ) ^ 2 * (n : ℚ) + (2 : ℚ) ^ 3 * (K : ℚ)
      = 2 * (n : ℚ) ^ 2 + 12 * (n : ℚ) + 8 * (K : ℚ) := by ring
  rw [hnorm] at h
  exact h

/-- **The recorded reading is below every window ceiling.**  For every offset window of length
`n ≥ 10⁴` described by at most `n` valuation blocks, the tie ceiling exceeds `6/7 − 1/100`,
while the recorded bitlen-100 pooled reading squares to `0.544² ≈ 0.296`. -/
theorem interval_window_below_pooled (A n K : ℕ) (hA : 1 ≤ A) (hK : A + n ≤ 2 ^ K)
    (hn : 10 ^ 4 ≤ n) (hKn : K ≤ n) :
    pooled100 ^ 2 < spearmanSq (intervalBlocks A n K) := by
  have h2 : 2 ≤ n := by omega
  have hq : ((10 : ℚ)) ^ 4 ≤ (n : ℚ) := by exact_mod_cast hn
  have hKq : ((K : ℚ)) ≤ (n : ℚ) := by exact_mod_cast hKn
  have hn2 : (2 : ℚ) ≤ (n : ℚ) := by linarith
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - (n : ℚ) := cube_sub_self_pos hn2
  have hmain := interval_window_ceiling A n K hA hK h2
  have herr : (2 * (n : ℚ) ^ 2 + 12 * (n : ℚ) + 8 * (K : ℚ)) / ((n : ℚ) ^ 3 - (n : ℚ))
      ≤ 1 / 100 := by
    rw [div_le_div_iff₀ hden (by norm_num)]
    have hn3 : 10000 * (n : ℚ) ^ 2 ≤ (n : ℚ) ^ 3 := by nlinarith [sq_nonneg ((n : ℚ))]
    have hn2' : 10000 * (n : ℚ) ≤ (n : ℚ) ^ 2 := by nlinarith
    linarith
  have hp : pooled100 ^ 2 < 6 / 7 - 1 / 100 := by norm_num [pooled100]
  linarith

/-- The canonical bitlen-100 window `[2⁹⁹, 2¹⁰⁰)`: its tie ceiling is far above the recorded
pooled reading, so the first band miss on uniform draws is not produced by the offset. -/
theorem u100_canonical_window :
    pooled100 ^ 2 < spearmanSq (intervalBlocks (2 ^ 99) (2 ^ 99) 100) := by
  refine interval_window_below_pooled (2 ^ 99) (2 ^ 99) 100 (Nat.one_le_two_pow) ?_ ?_ ?_
  · have : (2 : ℕ) ^ 99 + 2 ^ 99 = 2 ^ 100 := by ring
    omega
  · have h1 : (10 : ℕ) ^ 4 ≤ 2 ^ 14 := by norm_num
    have h2 : (2 : ℕ) ^ 14 ≤ 2 ^ 99 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
    omega
  · have h1 : (100 : ℕ) ≤ 2 ^ 7 := by norm_num
    have h2 : (2 : ℕ) ^ 7 ≤ 2 ^ 99 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
    omega

end Catalog.Novelty.TDialU100IntervalSampler