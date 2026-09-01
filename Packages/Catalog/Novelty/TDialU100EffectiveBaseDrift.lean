import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialU76
import Novelty.TDialU100RangeShape
import Novelty.TDialU100DyadicDomination

/-!
# Base-`p` domination and the effective-base drift `7 → 9` between bitlen 76 and 100

## Research context (FACT round-67 #2, exp 540, cycle 3)

Round 65 (`Novelty.ZeroFitDialU76`) observed that the bitlen-76 dial matches the *asymptotic
`p`-adic ceiling* `3p/(p²+p+1)` at the unique base `p = 7`: the measured attenuation looks like
a 7-adic, not a 2-adic, valuation profile.  The bitlen-100 reading is lower, so if the
effective-base description is more than numerology the effective base must have *moved*, and
the amount it moved must match the recorded drop.

This file does two things.

1. **Base-`p` domination.**  `Novelty.TDialU100DyadicDomination` is generalised from the ratio
   `1/2` to an arbitrary base: a profile whose `i`-th block obeys `mᵢ ≤ x(p−1)/p^{i+1} + C` has
   cube sum at most `((p−1)³/(p³−1))x³ + 3Cx² + 3C²x + C³·(#blocks)`, and hence tie ceiling at
   least `3p/(p²+p+1) − O(1/n)`.  Again every coefficient balances exactly, now with the
   base-`p` geometric fixed point `(p−1)³/(p³−1)`; the identity
   `1 − (p−1)³/(p³−1) = 3p/(p²+p+1)` (`one_sub_padicCube`) is what ties the two descriptions
   together.  The `p`-adic ceiling of round 65 is therefore *sampler-independent*: it does not
   presuppose a sample size of the form `p^b`.
2. **The drift.**  `effective_base_nine`: base `9` is the unique base whose asymptotic ceiling
   lies inside the squared bitlen-100 seed window `[0.528², 0.549²]`, exactly as base `7` was
   for the bitlen-76 window.  `effective_base_drift_matches_drop`: the ceiling gap between the
   two effective bases, `7/19 − 27/91 = 124/1729 ≈ 0.0717`, agrees with the recorded drop in
   `ρ²` from bitlen 76 to bitlen 100, `0.608² − 0.544² ≈ 0.0737`, to within `0.003`.
   The dial's erosion is thus quantitatively equivalent to a **drift of the effective base**,
   at a rate of about one base unit per twelve bitlens.
-/

open Finset

namespace Catalog.Novelty.TDialU100EffectiveBaseDrift

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.ZeroFitDialU76
open Catalog.Novelty.TDialU100RangeShape
open Catalog.Novelty.TDialU100DyadicDomination

/-! ## 1. Base-`p` domination -/

/-- `q ≥ 2` forces `q³ ≥ 8`; used repeatedly to keep denominators positive. -/
lemma eight_le_cube {q : ℚ} (hq : 2 ≤ q) : (8 : ℚ) ≤ q ^ 3 := by
  have h1 : (0 : ℚ) ≤ q - 2 := by linarith
  have h2 : (0 : ℚ) ≤ q ^ 2 + 2 * q + 4 := by nlinarith
  nlinarith [mul_nonneg h1 h2]

/-- The base-`p` geometric fixed point of the cube-sum recursion. -/
def padicCube (p : ℕ) : ℚ := ((p : ℚ) - 1) ^ 3 / ((p : ℚ) ^ 3 - 1)

lemma padicCube_id (p : ℕ) (hp : 2 ≤ p) :
    padicCube p * ((p : ℚ) ^ 3 - 1) = ((p : ℚ) - 1) ^ 3 := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have h : ((p : ℚ) ^ 3 - 1) ≠ 0 := ne_of_gt (by linarith [eight_le_cube hq])
  rw [padicCube, div_mul_cancel₀ _ h]

/-- The complement of the fixed point is exactly the `p`-adic ceiling of round 65. -/
theorem one_sub_padicCube (p : ℕ) (hp : 2 ≤ p) : 1 - padicCube p = padicLimit p := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have h1 : ((p : ℚ) ^ 3 - 1) ≠ 0 := ne_of_gt (by linarith [eight_le_cube hq])
  have h2 : ((p : ℚ) ^ 2 + (p : ℚ) + 1) ≠ 0 := ne_of_gt (by nlinarith)
  rw [padicCube, padicLimit]
  field_simp
  ring

lemma padicCube_nonneg (p : ℕ) (hp : 2 ≤ p) : 0 ≤ padicCube p := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  rw [padicCube]
  exact div_nonneg (pow_nonneg (by linarith) 3) (by linarith [eight_le_cube hq])

lemma padicCube_le_one (p : ℕ) (hp : 2 ≤ p) : padicCube p ≤ 1 := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  rw [padicCube, div_le_one (by linarith [eight_le_cube hq])]
  nlinarith

/-- A profile is *base-`p` dominated at scale `x` with slack `C`* when its `i`-th block has at
most `x(p−1)/p^{i+1} + C` elements — the geometry of the `p`-adic valuation on a window. -/
def PadicDominated (p : ℕ) (L : List ℕ) (x C : ℚ) : Prop :=
  ∀ i : ℕ, ((L.getD i 0 : ℕ) : ℚ) ≤ x * ((p : ℚ) - 1) / (p : ℚ) ^ (i + 1) + C

lemma padicDominated_head {p m : ℕ} {L : List ℕ} {x C : ℚ}
    (h : PadicDominated p (m :: L) x C) : (m : ℚ) ≤ x * ((p : ℚ) - 1) / (p : ℚ) + C := by
  have h0 := h 0
  simpa using h0

lemma padicDominated_tail {p m : ℕ} {L : List ℕ} {x C : ℚ} (hp : 2 ≤ p)
    (h : PadicDominated p (m :: L) x C) : PadicDominated p L (x / (p : ℚ)) C := by
  intro i
  have h1 := h (i + 1)
  have hget : (m :: L).getD (i + 1) 0 = L.getD i 0 := by simp
  rw [hget] at h1
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hp0 : ((p : ℚ)) ≠ 0 := by positivity
  calc ((L.getD i 0 : ℕ) : ℚ) ≤ x * ((p : ℚ) - 1) / (p : ℚ) ^ (i + 1 + 1) + C := h1
    _ = x / (p : ℚ) * ((p : ℚ) - 1) / (p : ℚ) ^ (i + 1) + C := by
        rw [pow_succ]
        field_simp

/-- **Base-`p` cube-sum bound.**  The `x³` coefficient is the geometric fixed point
`(p−1)³/(p³−1)`, and the three error coefficients balance exactly. -/
theorem padic_cubeSum_le (p : ℕ) (hp : 2 ≤ p) :
    ∀ (L : List ℕ) (x C : ℚ), 0 ≤ x → 0 ≤ C → PadicDominated p L x C →
      cubeSum L ≤ padicCube p * x ^ 3 + 3 * C * x ^ 2 + 3 * C ^ 2 * x + C ^ 3 * (L.length : ℚ) := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hp0 : (0 : ℚ) < (p : ℚ) := by linarith
  intro L
  induction L with
  | nil =>
      intro x C hx hC _
      have hK := padicCube_nonneg p hp
      have h0 : cubeSum ([] : List ℕ) = 0 := by simp [cubeSum]
      rw [h0]
      simp only [List.length_nil, Nat.cast_zero]
      have h1 : (0 : ℚ) ≤ padicCube p * x ^ 3 := by positivity
      nlinarith [mul_nonneg hC (sq_nonneg x), mul_nonneg (sq_nonneg C) hx]
  | cons m L ih =>
      intro x C hx hC h
      have hhead : (m : ℚ) ≤ x * ((p : ℚ) - 1) / (p : ℚ) + C := padicDominated_head h
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hcube : (m : ℚ) ^ 3 ≤ (x * ((p : ℚ) - 1) / (p : ℚ) + C) ^ 3 := by
        have := pow_le_pow_left₀ hm0 hhead 3
        simpa using this
      have htail := ih (x / (p : ℚ)) C (by positivity) hC (padicDominated_tail hp h)
      have hlen : ((m :: L).length : ℚ) = (L.length : ℚ) + 1 := by
        push_cast [List.length_cons]
        ring
      rw [cubeSum_cons, hlen]
      -- the three coefficient balances
      have hK := padicCube_id p hp
      have hpne : ((p : ℚ)) ≠ 0 := by positivity
      have hne3 : ((p : ℚ) ^ 3 - 1) ≠ 0 := ne_of_gt (by linarith [eight_le_cube hq])
      have hx3 : (x * ((p : ℚ) - 1) / (p : ℚ)) ^ 3 + padicCube p * (x / (p : ℚ)) ^ 3
          = padicCube p * x ^ 3 := by
        rw [padicCube]
        field_simp
        ring
      have hsq : (x * ((p : ℚ) - 1) / (p : ℚ)) ^ 2 + (x / (p : ℚ)) ^ 2 ≤ x ^ 2 := by
        rw [div_pow, div_pow, mul_pow, ← add_div, div_le_iff₀ (by positivity)]
        nlinarith [sq_nonneg x, mul_nonneg (sq_nonneg x) (sub_nonneg.2 hq)]
      have hx2 : 3 * C * (x * ((p : ℚ) - 1) / (p : ℚ)) ^ 2 + 3 * C * (x / (p : ℚ)) ^ 2
          ≤ 3 * C * x ^ 2 := by nlinarith [hsq, hC]
      have hx1 : 3 * C ^ 2 * (x * ((p : ℚ) - 1) / (p : ℚ)) + 3 * C ^ 2 * (x / (p : ℚ))
          = 3 * C ^ 2 * x := by
        field_simp
        ring
      have hexp : (x * ((p : ℚ) - 1) / (p : ℚ) + C) ^ 3
          = (x * ((p : ℚ) - 1) / (p : ℚ)) ^ 3 + 3 * C * (x * ((p : ℚ) - 1) / (p : ℚ)) ^ 2
            + 3 * C ^ 2 * (x * ((p : ℚ) - 1) / (p : ℚ)) + C ^ 3 := by ring
      linarith [hcube, htail, hx3, hx2, hx1, hexp]

/-- **Base-`p` sampler-free ceiling bound.**  A base-`p` dominated profile with `n = Σ mᵢ ≥ 2`
has Spearman tie ceiling at least `3p/(p²+p+1)` minus an explicit `O(1/n)` term.  In
particular the `p`-adic ceiling law of round 65 does not depend on the sample size being a
power of `p`. -/
theorem padic_dominated_spearmanSq_lower (p : ℕ) (hp : 2 ≤ p) (L : List ℕ) (C : ℚ) (hC : 0 ≤ C)
    (h2 : 2 ≤ L.sum) (hdom : PadicDominated p L (L.sum : ℚ) C) :
    padicLimit p
        - (3 * C * ((L.sum : ℚ)) ^ 2 + 3 * C ^ 2 * (L.sum : ℚ) + C ^ 3 * (L.length : ℚ))
          / (((L.sum : ℚ)) ^ 3 - (L.sum : ℚ))
      ≤ spearmanSq L := by
  set n : ℚ := (L.sum : ℚ) with hn
  set B : ℚ := 3 * C * n ^ 2 + 3 * C ^ 2 * n + C ^ 3 * (L.length : ℚ) with hB
  set K : ℚ := padicCube p with hK
  have hqn : (2 : ℚ) ≤ n := by rw [hn]; exact_mod_cast h2
  have hden : (0 : ℚ) < n ^ 3 - n := cube_sub_self_pos hqn
  have hn0 : n ≠ 0 := by positivity
  have hnn : n ^ 2 - 1 ≠ 0 := by nlinarith [sq_nonneg (n - 2)]
  have hK1 : K ≤ 1 := padicCube_le_one p hp
  have hcube : cubeSum L ≤ K * n ^ 3 + B := by
    have := padic_cubeSum_le p hp L n C (by linarith) hC hdom
    rw [hB, hK]; linarith
  rw [spearmanSq_eq _ h2, tieCorr_eq_cubeSum, ← hn]
  have hstep : 12 * ((cubeSum L - n) / 12) / (n ^ 3 - n)
      ≤ (K * n ^ 3 + B - n) / (n ^ 3 - n) := by
    gcongr
    linarith
  have hkey : (K * n ^ 3 + B - n) / (n ^ 3 - n) + ((1 - K) * n) / (n ^ 3 - n)
      = K + B / (n ^ 3 - n) := by
    field_simp
    ring
  have hpos : 0 ≤ ((1 - K) * n) / (n ^ 3 - n) := by
    apply div_nonneg (by nlinarith) (le_of_lt hden)
  have hlim : padicLimit p = 1 - K := (one_sub_padicCube p hp).symm ▸ rfl
  rw [hlim]
  linarith

/-! ## 2. The effective base at bitlen 100 -/

/-- Squared lower end of the bitlen-100 seed window (`0.528²`). -/
def seedWindow100Low : ℚ := seedB100 ^ 2
/-- Squared upper end of the bitlen-100 seed window (`0.549²`). -/
def seedWindow100High : ℚ := seedC100 ^ 2

lemma padicLimit_nine : padicLimit 9 = 27 / 91 := by norm_num [padicLimit]

/-- **Effective-base inversion at bitlen 100.**  Base `9` is the *unique* base whose asymptotic
`p`-adic ceiling `3p/(p²+p+1)` lies inside the squared seed window `[0.528², 0.549²]` recorded
at bitlen 100 — the exact analogue of `effective_base_seven` at bitlen 76. -/
theorem effective_base_nine :
    (seedWindow100Low ≤ padicLimit 9 ∧ padicLimit 9 ≤ seedWindow100High) ∧
    ∀ p : ℕ, 2 ≤ p → p ≠ 9 →
      ¬ (seedWindow100Low ≤ padicLimit p ∧ padicLimit p ≤ seedWindow100High) := by
  have h9 : padicLimit 9 = 27 / 91 := padicLimit_nine
  have h8 : padicLimit 8 = 24 / 73 := by norm_num [padicLimit]
  have h10 : padicLimit 10 = 30 / 111 := by norm_num [padicLimit]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · rw [h9]; norm_num [seedWindow100Low, seedB100]
  · rw [h9]; norm_num [seedWindow100High, seedC100]
  · rintro p hp hne ⟨hlo, hhi⟩
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · -- p ≤ 8: the ceiling is at least `padicLimit 8 > 0.549²`
      have hle : padicLimit 8 ≤ padicLimit p := by
        rcases eq_or_lt_of_le (Nat.lt_succ_iff.mp hlt) with h | h
        · exact le_of_eq (by rw [h])
        · exact le_of_lt (padicLimit_strict_anti (by omega) h)
      have h1 : (24 : ℚ) / 73 ≤ padicLimit p := by rw [← h8]; exact hle
      have hbad : seedWindow100High < 24 / 73 := by
        norm_num [seedWindow100High, seedC100]
      linarith
    · -- p ≥ 10: the ceiling is at most `padicLimit 10 < 0.528²`
      have hge : padicLimit p ≤ padicLimit 10 := by
        rcases eq_or_lt_of_le (show (10 : ℕ) ≤ p by omega) with h | h
        · exact le_of_eq (by rw [← h])
        · exact le_of_lt (padicLimit_strict_anti (by omega) h)
      have h1 : padicLimit p ≤ 30 / 111 := by rw [← h10]; exact hge
      have hbad : (30 : ℚ) / 111 < seedWindow100Low := by
        norm_num [seedWindow100Low, seedB100]
      linarith

/-- The effective base rose strictly between bitlen 76 and bitlen 100. -/
theorem effective_base_rose : padicLimit 9 < padicLimit 7 :=
  padicLimit_strict_anti (by norm_num) (by norm_num)

/-- **The drift accounts for the drop.**  The gap between the two effective-base ceilings,
`7/19 − 27/91 = 124/1729 ≈ 0.0717`, matches the recorded fall in `ρ²` from bitlen 76 to bitlen
100, `0.608² − 0.544² ≈ 0.0737`, to within `0.003`.  Twenty-four bitlens of erosion are
quantitatively one-and-a-bit units of effective base. -/
theorem effective_base_drift_matches_drop :
    |(padicLimit 7 - padicLimit 9) - (pooled76 ^ 2 - pooled100 ^ 2)| ≤ 3 / 1000 := by
  rw [padicLimit_seven, padicLimit_nine, abs_le]
  constructor <;> norm_num [pooled76, pooled100]

/-- **Consistency of the base-9 description with every recorded seed.**  All three bitlen-100
seeds, squared, lie between the base-10 and base-8 ceilings, i.e. the whole seed spread is
explained by an effective base in `(8, 10)`. -/
theorem seeds_bracketed_by_bases :
    padicLimit 10 < seedA100 ^ 2 ∧ seedA100 ^ 2 < padicLimit 8 ∧
    padicLimit 10 < seedB100 ^ 2 ∧ seedB100 ^ 2 < padicLimit 8 ∧
    padicLimit 10 < seedC100 ^ 2 ∧ seedC100 ^ 2 < padicLimit 8 := by
  have h8 : padicLimit 8 = 24 / 73 := by norm_num [padicLimit]
  have h10 : padicLimit 10 = 30 / 111 := by norm_num [padicLimit]
  rw [h8, h10]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [seedA100, seedB100, seedC100]

/-- The dyadic (true) ceiling remains far above every recorded seed: the effective base is a
description of the *response*, not of the statistic, whose base is and remains `2`. -/
theorem dyadic_far_above_seeds : 2 * seedC100 ^ 2 < padicLimit 2 := by
  rw [padicLimit_two]
  norm_num [seedC100]

end Catalog.Novelty.TDialU100EffectiveBaseDrift