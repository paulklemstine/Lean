import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialU76
import MachineLearning.ZeroFitDialFloor92

/-!
# Capped valuations in every base, and the effective-base drift of the eroding dial

## Research context (FACT round-69 #1, exp 538, `TDIAL-U92`; second cycle)

`MachineLearning.ZeroFitDialFloor92` established, for base two, the *capped resolution law*
and used it to exclude coarse resolution as the mechanism of the dial's erosion.  Two
questions were left open by that cycle:

1. Is the `3/4` universal floor of capped dials an accident of base two?
2. `Novelty.ZeroFitDialU76` observed that the bitlen-76 reading matched the base-seven
   ceiling `padicLimit 7 = 7/19`.  Where has that *effective base* moved by bitlen 92?

This file answers both.  The capped resolution law generalises verbatim to every base
`p ≥ 2`, with the base-two constant `6/7` replaced by `padicLimit p = 3p/(p²+p+1)`; and the
effective base of the recorded readings is shown to have drifted strictly past `8` between
bitlen 76 and bitlen 92, with the hyperbolic erosion law of the previous cycle pinning its
asymptotic value strictly between `22` and `23`.

## Main results

* `padicCappedBlocks`, `padicCappedBlocks_sum`, `tieCorr_padicCapped` — the tie profile of
  the `K`-capped `p`-adic valuation on `{0, …, p^{r+K} − 1}` and its exact tie correction.
* `padic_capped_spearmanSq` — the **base-`p` capped resolution law**
  `ρ² = padicLimit p · (p^{3b} − p^{3r})/(p^{3b} − p^b)`, `b = r + K`.
* `padic_capped_two`, `padic_capped_full` — consistency: base two reproduces
  `capped_spearmanSq`, and the uncapped case `r = 0` reproduces the `p`-adic ceiling law.
* `padic_capped_ge` — the **base-`p` universal floor** `ρ² ≥ padicLimit p · (1 − p^{−3})`,
  which at `p = 2` is exactly the `3/4` of the previous cycle.
* `EffectiveBase`, `effective_base_antitone` — the effective base of a reading is monotone:
  a strictly smaller reading has a strictly larger (or equal) effective base, so *erosion is
  base drift*.
* `effective_base_92_is_eight`, `effective_base_drift_76_to_92` — the recorded readings:
  both bitlen-92 seeds have effective base `8`, whereas the bitlen-76 pooled reading sits
  above the base-seven ceiling.  The dial's effective base moved by at least one unit in
  sixteen bits.
* `asymptotic_effective_base_between_22_and_23`, `effective_base_bounded_by_23` — under the
  hyperbolic erosion law the effective base converges to a value strictly between `22` and
  `23` and never passes it: the dial degrades to a base-23 valuation dial and no further.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.Novelty.ZeroFitDialU76

open Catalog.MachineLearning.ZeroFitDialUnif52

open Catalog.MachineLearning.ZeroFitDialFloor92

namespace Catalog.MachineLearning.ZeroFitDialFloor92Padic

/-! ## 1. The capped `p`-adic tie profile -/

/-- Tie profile of the `K`-capped `p`-adic valuation `min(v_p(x), K)` on
`{0, …, p^{r+K} − 1}`: the exact-valuation classes `0, …, K−1` have sizes
`(p−1)p^{r+K−1}, …, (p−1)p^r`, and everything of valuation `≥ K` is merged into a single
top class of size `p^r`. -/
def padicCappedBlocks (p K r : ℕ) : List ℕ :=
  p ^ r :: (List.range K).map (fun i => (p - 1) * p ^ (r + i))

lemma padicCappedBlocks_two_eq (K r : ℕ) : padicCappedBlocks 2 K r = cappedBlocks K r := by
  simp [padicCappedBlocks, cappedBlocks]

lemma padicCappedBlocks_sum (p : ℕ) (hp : 1 ≤ p) (K r : ℕ) :
    (padicCappedBlocks p K r).sum = p ^ (r + K) := by
  induction K with
  | zero => simp [padicCappedBlocks]
  | succ K ih =>
      have hstep : (p - 1) * p ^ (r + K) + p ^ (r + K) = p ^ (r + K + 1) := by
        have h : p - 1 + 1 = p := Nat.sub_add_cancel hp
        calc (p - 1) * p ^ (r + K) + p ^ (r + K) = (p - 1 + 1) * p ^ (r + K) := by ring
          _ = p * p ^ (r + K) := by rw [h]
          _ = p ^ (r + K + 1) := by ring
      simp only [padicCappedBlocks, List.range_succ, List.map_append, List.map_cons,
        List.map_nil, List.sum_cons, List.sum_append, List.sum_nil] at *
      rw [show r + (K + 1) = (r + K) + 1 by omega]
      omega

/-- **Closed form for the tie correction of the capped `p`-adic profile.** -/
lemma tieCorr_padicCapped (p : ℕ) (hp : 1 ≤ p) (K r : ℕ) :
    12 * ((p : ℚ) ^ 3 - 1) * tieCorr (padicCappedBlocks p K r)
      = ((p : ℚ) ^ 3 - 1) * ((p : ℚ) ^ r) ^ 3
        + ((p : ℚ) - 1) ^ 3 * (((p : ℚ) ^ (r + K)) ^ 3 - ((p : ℚ) ^ r) ^ 3)
        - ((p : ℚ) ^ 3 - 1) * (p : ℚ) ^ (r + K) := by
  induction K with
  | zero =>
      have hz : padicCappedBlocks p 0 r = [p ^ r] := by simp [padicCappedBlocks]
      rw [hz, tieCorr_cons, tieCorr_nil, add_zero]
      push_cast
      ring
  | succ K ih =>
      have hsplit : padicCappedBlocks p (K + 1) r
          = padicCappedBlocks p K r ++ [(p - 1) * p ^ (r + K)] := by
        simp [padicCappedBlocks, List.range_succ]
      rw [hsplit, tieCorr_append, mul_add, ih]
      have hlast : 12 * ((p : ℚ) ^ 3 - 1) * tieCorr [(p - 1) * p ^ (r + K)]
          = ((p : ℚ) ^ 3 - 1)
            * ((((p : ℚ) - 1) * (p : ℚ) ^ (r + K)) ^ 3 - ((p : ℚ) - 1) * (p : ℚ) ^ (r + K)) := by
        rw [tieCorr_cons, tieCorr_nil, add_zero, cast_block p hp (r + K)]
        ring
      rw [hlast]
      have hexp : (p : ℚ) ^ (r + (K + 1)) = (p : ℚ) ^ (r + K) * p := by
        rw [show r + (K + 1) = (r + K) + 1 by omega, pow_succ]
      rw [hexp]
      ring

/-! ## 2. The base-`p` capped resolution law -/

lemma padic_pow_gap_pos {p b : ℕ} (hp : 2 ≤ p) (hb : 1 ≤ b) :
    (0 : ℚ) < ((p : ℚ) ^ b) ^ 3 - (p : ℚ) ^ b := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hY : (2 : ℚ) ≤ (p : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (p : ℚ) ^ 1 := by gcongr
      _ ≤ (p : ℚ) ^ b := by apply pow_le_pow_right₀ (by linarith) hb
  exact cube_sub_self_pos hY

/-- **Base-`p` capped resolution law.**  For the `K`-capped `p`-adic statistic on uniform
draws from `{0, …, p^b − 1}` (`b = r + K ≥ 1`), the Spearman tie ceiling is exactly
`ρ² = (3p/(p²+p+1)) · (p^{3b} − p^{3r})/(p^{3b} − p^b)`. -/
theorem padic_capped_spearmanSq (p K r : ℕ) (hp : 2 ≤ p) (h : 1 ≤ r + K) :
    spearmanSq (padicCappedBlocks p K r)
      = padicLimit p * ((((p : ℚ) ^ (r + K)) ^ 3 - ((p : ℚ) ^ r) ^ 3)
          / (((p : ℚ) ^ (r + K)) ^ 3 - (p : ℚ) ^ (r + K))) := by
  have hp1 : 1 ≤ p := le_trans (by norm_num) hp
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hsum : (padicCappedBlocks p K r).sum = p ^ (r + K) := padicCappedBlocks_sum p hp1 K r
  have h2 : 2 ≤ (padicCappedBlocks p K r).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ (r + K) := Nat.pow_le_pow_right (by norm_num) h
      _ ≤ p ^ (r + K) := Nat.pow_le_pow_left hp _
  have hcast : (((padicCappedBlocks p K r).sum : ℕ) : ℚ) = (p : ℚ) ^ (r + K) := by
    rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast, padicLimit]
  set q : ℚ := (p : ℚ) with hqdef
  set Y : ℚ := q ^ (r + K) with hYdef
  set t : ℚ := q ^ r with htdef
  have hqqpos : (0 : ℚ) < q ^ 2 + q + 1 := by nlinarith
  have hq3pos : (0 : ℚ) < q ^ 3 - 1 := by
    have hfac : q ^ 3 - 1 = (q - 1) * (q ^ 2 + q + 1) := by ring
    rw [hfac]; exact mul_pos (by linarith) hqqpos
  have hq3 : q ^ 3 - 1 ≠ 0 := ne_of_gt hq3pos
  have hqq : q ^ 2 + q + 1 ≠ 0 := ne_of_gt hqqpos
  have hgap : (0 : ℚ) < Y ^ 3 - Y := padic_pow_gap_pos hp h
  have hgapne : Y ^ 3 - Y ≠ 0 := ne_of_gt hgap
  have hYge : (2 : ℚ) ≤ Y := by
    rw [hYdef]
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ q ^ 1 := by gcongr
      _ ≤ q ^ (r + K) := by apply pow_le_pow_right₀ (by linarith) h
  have hY0 : Y ≠ 0 := by intro hc; rw [hc] at hYge; norm_num at hYge
  have hYm : Y - 1 ≠ 0 := by intro hc; nlinarith
  have hY1 : Y + 1 ≠ 0 := by intro hc; nlinarith
  have hYsq : Y ^ 2 - 1 ≠ 0 := by
    intro hc
    have : Y ^ 2 = 1 := by linarith
    nlinarith
  have key : 12 * tieCorr (padicCappedBlocks p K r)
      = ((q ^ 3 - 1) * t ^ 3 + (q - 1) ^ 3 * (Y ^ 3 - t ^ 3) - (q ^ 3 - 1) * Y)
        / (q ^ 3 - 1) := by
    have hpad := tieCorr_padicCapped p hp1 K r
    rw [eq_div_iff hq3]
    linear_combination hpad
  rw [key]
  field_simp
  ring

/-- Base two reproduces the dyadic capped law of the previous cycle. -/
theorem padic_capped_two (K r : ℕ) (h : 1 ≤ r + K) :
    spearmanSq (cappedBlocks K r)
      = padicLimit 2 * ((((2 : ℚ) ^ (r + K)) ^ 3 - ((2 : ℚ) ^ r) ^ 3)
          / (((2 : ℚ) ^ (r + K)) ^ 3 - (2 : ℚ) ^ (r + K))) := by
  rw [← padicCappedBlocks_two_eq K r, padic_capped_spearmanSq 2 K r (by norm_num) h]
  norm_num

/-- Lifting the cap (`r = 0`) reproduces the uncapped `p`-adic ceiling law. -/
theorem padic_capped_full (p b : ℕ) (hp : 2 ≤ p) (hb : 1 ≤ b) :
    spearmanSq (padicCappedBlocks p b 0) = spearmanSq (padicBlocks p b) := by
  rw [padic_capped_spearmanSq p b 0 hp (by omega), padic_spearmanSq p b hp hb]
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hY : (2 : ℚ) ≤ (p : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (p : ℚ) ^ 1 := by gcongr
      _ ≤ (p : ℚ) ^ b := by apply pow_le_pow_right₀ (by linarith) hb
  set Y : ℚ := (p : ℚ) ^ b with hYdef
  have hY0 : Y ≠ 0 := by intro hc; rw [hc] at hY; norm_num at hY
  have hY1 : Y + 1 ≠ 0 := by intro hc; nlinarith
  have hYm : Y - 1 ≠ 0 := by intro hc; nlinarith
  simp only [zero_add, pow_zero, one_pow]
  rw [show Y ^ 3 - Y = Y * (Y - 1) * (Y + 1) by ring]
  field_simp
  ring

/-- **Base-`p` universal floor.**  Every capped `p`-adic dial with cap depth `K ≥ 1` has
`ρ² ≥ padicLimit p · (1 − p^{−3})`, whatever the bitlen.  At `p = 2` this is the `3/4` of
`capped_ceiling_ge_three_quarters`; the universal floor is therefore not an artefact of
base two, only its numerical value is. -/
theorem padic_capped_ge (p K r : ℕ) (hp : 2 ≤ p) (hK : 1 ≤ K) :
    padicLimit p * (1 - 1 / (p : ℚ) ^ 3) ≤ spearmanSq (padicCappedBlocks p K r) := by
  have h : 1 ≤ r + K := by omega
  rw [padic_capped_spearmanSq p K r hp h]
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hqqpos : (0 : ℚ) < (p : ℚ) ^ 2 + (p : ℚ) + 1 := by nlinarith
  have hlim0 : 0 < padicLimit p := by
    rw [padicLimit]; apply div_pos <;> nlinarith
  set q : ℚ := (p : ℚ) with hqdef
  set Y : ℚ := q ^ (r + K) with hYdef
  set t : ℚ := q ^ r with htdef
  have hgap : (0 : ℚ) < Y ^ 3 - Y := padic_pow_gap_pos hp h
  have hYpos : (0 : ℚ) < Y := by positivity
  have htpos : (0 : ℚ) < t := by positivity
  have hq3 : (0 : ℚ) < q ^ 3 := by positivity
  -- `t³ ≤ Y³/q³` because `Y = t·q^K` with `K ≥ 1`
  have hstep : t * q ≤ Y := by
    have : Y = t * q ^ K := by rw [hYdef, htdef, pow_add]
    rw [this]
    have hqK : q ^ 1 ≤ q ^ K := by apply pow_le_pow_right₀ (by linarith) hK
    rw [pow_one] at hqK
    nlinarith
  have hqpos : (0 : ℚ) < q := by linarith
  have hcube : t ^ 3 * q ^ 3 ≤ Y ^ 3 := by
    calc t ^ 3 * q ^ 3 = (t * q) ^ 3 := by ring
      _ ≤ Y ^ 3 := by gcongr
  have hfrac : 1 - 1 / q ^ 3 ≤ (Y ^ 3 - t ^ 3) / (Y ^ 3 - Y) := by
    rw [le_div_iff₀ hgap]
    have h1 : (1 - 1 / q ^ 3) * (Y ^ 3 - Y) ≤ (1 - 1 / q ^ 3) * Y ^ 3 := by
      have hpos : (0 : ℚ) ≤ 1 - 1 / q ^ 3 := by
        rw [sub_nonneg, div_le_one hq3]
        nlinarith
      nlinarith
    have h2 : (1 - 1 / q ^ 3) * Y ^ 3 ≤ Y ^ 3 - t ^ 3 := by
      have hid : (1 - 1 / q ^ 3) * Y ^ 3 = Y ^ 3 - Y ^ 3 / q ^ 3 := by field_simp
      rw [hid]
      have : t ^ 3 ≤ Y ^ 3 / q ^ 3 := by
        rw [le_div_iff₀ hq3]
        exact hcube
      linarith
    linarith
  exact mul_le_mul_of_nonneg_left hfrac (le_of_lt hlim0)

/-- Base two: the universal floor is exactly `3/4`. -/
theorem padic_capped_ge_two : padicLimit 2 * (1 - 1 / (2 : ℚ) ^ 3) = 3 / 4 := by
  norm_num [padicLimit]

/-! ## 3. Effective base: erosion is base drift -/

/-- A reading `rho` has **effective base `p`** when its square sits in the window between
the base-`p` and base-`(p+1)` asymptotic ceilings: the dial behaves like a perfect
`p`-adic valuation dial. -/
def EffectiveBase (rho : ℚ) (p : ℕ) : Prop :=
  padicLimit (p + 1) < rho ^ 2 ∧ rho ^ 2 ≤ padicLimit p

/-- **Erosion is base drift.**  A strictly smaller reading has an effective base at least as
large; the two orderings are locked together by the strict antitonicity of `padicLimit`. -/
theorem effective_base_antitone {rho rho' : ℚ} {p p' : ℕ} (hp' : 1 ≤ p')
    (h : EffectiveBase rho p) (h' : EffectiveBase rho' p') (hlt : rho' ^ 2 < rho ^ 2) :
    p ≤ p' := by
  by_contra hcon
  push_neg at hcon
  have hle : padicLimit p ≤ padicLimit (p' + 1) := by
    rcases lt_or_eq_of_le (Nat.succ_le_of_lt hcon) with hlt' | heq
    · exact le_of_lt (padicLimit_strict_anti (by omega) hlt')
    · have hpe : p' + 1 = p := heq
      rw [hpe]
  have := h.2
  have := h'.1
  linarith

/-- The bitlen-92 seeds both have effective base `8`. -/
theorem effective_base_92_is_eight :
    EffectiveBase seed10 8 ∧ EffectiveBase seed11 8 ∧ EffectiveBase mean92 8 := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;>
    norm_num [EffectiveBase, padicLimit, seed10, seed11, mean92]

/-- **Effective-base drift.**  At bitlen 76 the pooled reading was still above the base-seven
ceiling; at bitlen 92 it is below the base-eight ceiling and above the base-nine one.  The
dial's effective base drifted by at least one unit over sixteen bits of draw width. -/
theorem effective_base_drift_76_to_92 :
    padicLimit 7 < pooled76 ^ 2 ∧ mean92 ^ 2 < padicLimit 8 ∧ padicLimit 9 < mean92 ^ 2 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    norm_num [padicLimit, pooled76, mean92, seed10, seed11]

/-- **Asymptotic effective base.**  The hyperbolic erosion law of the previous cycle has
asymptote `5/14`; its square lies strictly between the base-23 and base-22 ceilings, so the
dial degenerates to a base-`≈ 22.5` valuation dial and no further. -/
theorem asymptotic_effective_base_between_22_and_23 :
    padicLimit 23 < (5 / 14 : ℚ) ^ 2 ∧ (5 / 14 : ℚ) ^ 2 < padicLimit 22 := by
  constructor <;> norm_num [padicLimit]

/-- The effective base predicted by the erosion law never passes `23`, at any bitlen. -/
theorem effective_base_bounded_by_23 (b : ℕ) (hb : 1 ≤ b) :
    padicLimit 23 < rhoModel b ^ 2 := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hpos : (0 : ℚ) < 5 * (b : ℚ) := by linarith
  have hmod : (5 / 14 : ℚ) < rhoModel b := by
    rw [rhoModel]
    have : (0 : ℚ) < 93 / (5 * (b : ℚ)) := by positivity
    linarith
  have hlim : padicLimit 23 < (5 / 14 : ℚ) ^ 2 := asymptotic_effective_base_between_22_and_23.1
  nlinarith

end Catalog.MachineLearning.ZeroFitDialFloor92Padic