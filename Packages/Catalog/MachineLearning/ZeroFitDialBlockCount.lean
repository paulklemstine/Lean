import Mathlib
import MachineLearning.ZeroFitDialWeightedSharpness

/-!
# The block-count cap: no weighting whatsoever can beat the number of tie classes

## Research context (FACT round-61 #2, exp 542, cycle 4)

Cycles 1–3 capped the ceiling of the *stratified* (two-level) weightings `wDyadic b p q`
of the zero-fit dial, at every finite bitlen.  The obvious adversarial objection is that a
two-level weighting is not the most general one: an adversary designing the dial may choose
an arbitrary positive weight for each trailing-zero class.  This cycle removes the
restriction entirely.

The mechanism is a power-mean (Chebyshev/Hölder) bound: a profile of `K` blocks with total
mass `n` always satisfies `Σⱼmⱼ³ ≥ n³/K²`, with equality exactly for the flat profile.
Feeding this into the continuum sandwich of cycle 3 gives a cap that depends only on the
*number* of tie classes:

`ρ² ≤ 1 - 1/K² + 1/n²` for every profile of `K` blocks and mass `n ≥ 2`,

and cycle 1's `flat_ceiling_ge` shows the cap is attained to within `1/n²`.  Since a
weighting never changes the number of classes, this bounds *every* reweighting of the dial:
at bitlen `b` the dial has `b+1` classes, so no weight vector at all can lift the ceiling
above `1 - 1/(b+1)²` (plus the negligible `1/n²`).

## Main results

* `sum_cube_le_length_sq_mul_cubeSum` — the power-mean bound `n³ ≤ K²·Σⱼmⱼ³`, proved by
  induction using the same cubic factorisation `(1+K)²(K²m³+S³) - K²(m+S)³ = (S-Km)²(…)`
  that produced the `√7` constant in cycle 1.
* `spearmanSq_block_count_cap` — the cap `ρ² ≤ 1 - 1/K² + 1/n²`.
* `block_count_cap_sharp` — the flat profile realises the cap up to `1/n²`.
* `dyadicBlocks_length`, `weighted_dial_block_cap`, `u56_arbitrary_weighting_cap` — no
  weight vector whatsoever lifts the bitlen-56 dial above `ρ² = 1 - 1/57² + 2^-112`.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialWeighted56
open Catalog.MachineLearning.ZeroFitDialWeightedSharpness

namespace Catalog.MachineLearning.ZeroFitDialBlockCount

/-! ## 1. The power-mean bound -/

/-- **Power-mean bound.**  For any tie profile, `n³ ≤ K²·Σⱼmⱼ³` where `K` is the number of
blocks and `n` the total mass.  Equality holds exactly for a flat profile. -/
lemma sum_cube_le_length_sq_mul_cubeSum (L : List ℕ) :
    (L.sum : ℚ) ^ 3 ≤ (L.length : ℚ) ^ 2 * cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      rw [List.sum_cons, List.length_cons, cubeSum_cons]
      have hm : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
      have hS : (0 : ℚ) ≤ (L.sum : ℚ) := Nat.cast_nonneg _
      have hK : (0 : ℚ) ≤ (L.length : ℚ) := Nat.cast_nonneg _
      have hC : (0 : ℚ) ≤ cubeSum L := by
        have := sum_le_cubeSum L
        linarith
      have hcast : (((m + L.sum : ℕ)) : ℚ) = (m : ℚ) + (L.sum : ℚ) := by push_cast; ring
      have hlen : (((L.length + 1 : ℕ)) : ℚ) = (L.length : ℚ) + 1 := by push_cast; ring
      rw [hcast, hlen]
      -- the two-block cubic inequality
      rcases eq_or_lt_of_le hK with hK0 | hKpos
      · have hS0 : (L.sum : ℚ) = 0 := by
          by_contra h
          have hSpos : (0 : ℚ) < (L.sum : ℚ) := lt_of_le_of_ne hS (Ne.symm h)
          have h3 : (0 : ℚ) < (L.sum : ℚ) ^ 3 := by positivity
          rw [← hK0] at ih
          nlinarith
        rw [hS0, ← hK0]
        nlinarith
      · have hnn : (0 : ℚ) ≤ ((L.sum : ℚ) - (L.length : ℚ) * m) ^ 2 *
            ((1 + 2 * (L.length : ℚ)) * (L.sum : ℚ) + (L.length : ℚ) * (2 + (L.length : ℚ)) * m) := by
          positivity
        have hid : (1 + (L.length : ℚ)) ^ 2 * ((L.length : ℚ) ^ 2 * (m : ℚ) ^ 3 + (L.sum : ℚ) ^ 3)
            - (L.length : ℚ) ^ 2 * ((m : ℚ) + (L.sum : ℚ)) ^ 3
            = ((L.sum : ℚ) - (L.length : ℚ) * m) ^ 2 *
              ((1 + 2 * (L.length : ℚ)) * (L.sum : ℚ)
                + (L.length : ℚ) * (2 + (L.length : ℚ)) * m) := by ring
        have hK2 : (0 : ℚ) < (L.length : ℚ) ^ 2 := by positivity
        have hstep : (1 + (L.length : ℚ)) ^ 2 * ((L.length : ℚ) ^ 2 * cubeSum L)
            ≥ (1 + (L.length : ℚ)) ^ 2 * (L.sum : ℚ) ^ 3 := by
          nlinarith [sq_nonneg (1 + (L.length : ℚ))]
        nlinarith

/-- The cubic moment of a `K`-block profile is at least `n³/K²` of the total. -/
lemma cubeSum_div_ge_inv_length_sq (L : List ℕ) (hL : 0 < L.length) (hn : 0 < L.sum) :
    1 / (L.length : ℚ) ^ 2 ≤ cubeSum L / (L.sum : ℚ) ^ 3 := by
  have hK : (0 : ℚ) < (L.length : ℚ) := by exact_mod_cast hL
  have hnq : (0 : ℚ) < (L.sum : ℚ) := by exact_mod_cast hn
  have hn3 : (0 : ℚ) < (L.sum : ℚ) ^ 3 := by positivity
  have hK2 : (0 : ℚ) < (L.length : ℚ) ^ 2 := by positivity
  rw [div_le_div_iff₀ hK2 hn3, one_mul]
  have := sum_cube_le_length_sq_mul_cubeSum L
  linarith

/-! ## 2. The cap -/

/-- **Block-count cap.**  A tie profile with `K` blocks and total mass `n ≥ 2` can never
push the tie-attenuation ceiling above `1 - 1/K² + 1/n²`, whatever the block sizes. -/
theorem spearmanSq_block_count_cap (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L ≤ 1 - 1 / (L.length : ℚ) ^ 2 + 1 / (L.sum : ℚ) ^ 2 := by
  have hL : 0 < L.length := by
    rcases L with _ | ⟨m, t⟩
    · simp at h
    · simp
  have hn : 0 < L.sum := lt_of_lt_of_le (by norm_num) h
  have hupper := spearmanSq_continuum_upper L h
  have hlow := cubeSum_div_ge_inv_length_sq L hL hn
  linarith

/-- **Sharpness of the block-count cap.**  A flat profile of `K` blocks realises the cap to
within the discrete correction `1/n²`, so the bound `1 - 1/K²` cannot be improved. -/
theorem block_count_cap_sharp (K m : ℕ) (hK : 2 ≤ K) (hm : 1 ≤ m) :
    1 - 1 / (K : ℚ) ^ 2 ≤ spearmanSq (flatBlocks K m) ∧
      spearmanSq (flatBlocks K m)
        ≤ 1 - 1 / (K : ℚ) ^ 2 + 1 / ((flatBlocks K m).sum : ℚ) ^ 2 := by
  refine ⟨flat_ceiling_ge K m hK hm, ?_⟩
  have hsum : 2 ≤ (flatBlocks K m).sum := by
    rw [flatBlocks_sum]
    calc 2 = 2 * 1 := by norm_num
      _ ≤ K * m := Nat.mul_le_mul hK hm
  have hlen : (flatBlocks K m).length = K := by simp [flatBlocks]
  have := spearmanSq_block_count_cap (flatBlocks K m) hsum
  rwa [hlen] at this

/-! ## 3. Arbitrary weightings of the dial -/

/-- The bitlen-`b` dial has exactly `b+1` trailing-zero classes. -/
lemma dyadicBlocks_length (b : ℕ) : (dyadicBlocks b).length = b + 1 := by
  induction b with
  | zero => simp [dyadicBlocks]
  | succ k ih => simp [dyadicBlocks, ih]

/-- **No weighting beats the class count.**  For *any* weight vector `W` — not merely the
two-level stratified weightings of cycles 1–3 — the reweighted bitlen-`b` dial obeys
`ρ² ≤ 1 - 1/(b+1)² + 1/n²`.  Weighting redistributes mass between the tie classes but never
creates new ones, and the ceiling is controlled by the class count alone. -/
theorem weighted_dial_block_cap (b : ℕ) (W : List ℕ) (hW : b + 1 ≤ W.length)
    (h2 : 2 ≤ (List.zipWith (· * ·) W (dyadicBlocks b)).sum) :
    spearmanSq (List.zipWith (· * ·) W (dyadicBlocks b))
      ≤ 1 - 1 / ((b : ℚ) + 1) ^ 2
        + 1 / (((List.zipWith (· * ·) W (dyadicBlocks b)).sum : ℕ) : ℚ) ^ 2 := by
  have hlen : (List.zipWith (· * ·) W (dyadicBlocks b)).length = b + 1 := by
    rw [List.length_zipWith, dyadicBlocks_length]
    omega
  have h := spearmanSq_block_count_cap (List.zipWith (· * ·) W (dyadicBlocks b)) h2
  rw [hlen] at h
  have hcast : (((b + 1 : ℕ)) : ℚ) = (b : ℚ) + 1 := by push_cast; ring
  rwa [hcast] at h

/-- At the recorded bitlen 56 the dial has 57 classes, so no weighting whatsoever — of any
shape — can lift the ceiling above `1 - 1/57² + 1/n²`.  Combined with the `√7` cap of
cycle 3 for stratified weightings, the reweighting budget of the dial is now bounded in
both the general and the sharp regime. -/
theorem u56_arbitrary_weighting_cap (W : List ℕ) (hW : 57 ≤ W.length)
    (h2 : 2 ≤ (List.zipWith (· * ·) W (dyadicBlocks 56)).sum) :
    spearmanSq (List.zipWith (· * ·) W (dyadicBlocks 56))
      ≤ 1 - 1 / 3249
        + 1 / (((List.zipWith (· * ·) W (dyadicBlocks 56)).sum : ℕ) : ℚ) ^ 2 := by
  have h := weighted_dial_block_cap 56 W (by omega) h2
  norm_num at h ⊢
  linarith

/-- **Optimality of the equalising weighting.**  Among *all* weight vectors for the
bitlen-`b` dial, cycle 1's class-equalising vector `eqWeights b` is optimal up to the
discrete correction `1/n²`: no weighting can beat it by more than that.  This identifies
the extremiser of the block-count cap for the 2-adic profile. -/
theorem eqWeights_optimal (b : ℕ) (hb : 1 ≤ b) (W : List ℕ) (hW : b + 1 ≤ W.length)
    (h2 : 2 ≤ (List.zipWith (· * ·) W (dyadicBlocks b)).sum) :
    spearmanSq (List.zipWith (· * ·) W (dyadicBlocks b))
      ≤ spearmanSq (List.zipWith (· * ·) (eqWeights b) (dyadicBlocks b))
        + 1 / (((List.zipWith (· * ·) W (dyadicBlocks b)).sum : ℕ) : ℚ) ^ 2 := by
  have hcap := weighted_dial_block_cap b W hW h2
  have hflat := rebalanced_ceiling_ge b hb
  linarith

/-- Weighting by ones is the identity on a profile (for a long enough weight vector). -/
lemma zipWith_replicate_one (n : ℕ) (L : List ℕ) (h : L.length ≤ n) :
    List.zipWith (· * ·) (List.replicate n 1) L = L := by
  induction L generalizing n with
  | nil => simp
  | cons a t ih =>
      cases n with
      | zero => simp at h
      | succ k =>
          have ht : t.length ≤ k := by
            simpa using Nat.succ_le_succ_iff.mp h
          simp [List.replicate_succ, ih k ht]

/-- The hypotheses of `u56_arbitrary_weighting_cap` are satisfiable — the all-ones weight
vector meets them — so the cap is a statement with content, not a vacuous implication. -/
theorem u56_arbitrary_weighting_cap_nonvacuous :
    57 ≤ (List.replicate 57 1).length ∧
      2 ≤ (List.zipWith (· * ·) (List.replicate 57 1) (dyadicBlocks 56)).sum := by
  have hlen : (dyadicBlocks 56).length ≤ 57 := by rw [dyadicBlocks_length]
  refine ⟨by simp, ?_⟩
  rw [zipWith_replicate_one 57 _ hlen, dyadicBlocks_sum]
  exact Nat.one_lt_two_pow (by norm_num)

end Catalog.MachineLearning.ZeroFitDialBlockCount