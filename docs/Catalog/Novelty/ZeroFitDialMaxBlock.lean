import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialU76

/-!
# The dominant-block law: how concentrated a tie profile must be to attenuate the dial

Cycle 4 of the round-65 (bitlen-76) investigation.

Earlier cycles computed exact ceilings for *specific* tie profiles (dyadic, `p`-adic,
capped, nested).  This file removes the profile from the hypotheses entirely and
bounds the ceiling by a single scalar: the size `M` of the largest tie class.

## Main results

* `twelve_tieCorr_le_of_bound` — a uniform bound on `m² - 1` over the blocks bounds the
  Kendall tie correction linearly in the sample size.
* `spearmanSq_ge_of_max_block` — the **dominant-block law**
  `ρ² ≥ 1 - (M² - 1)/(n² - 1)`, valid for *every* tie profile; and the corollary
  `spearmanSq_ge_one_sub_sq_frac`: `ρ² ≥ 1 - (M/n)²`.
* `balanced_profile_ge_three_quarters` — any statistic whose largest tie class holds at
  most half the sample has `ρ² ≥ 3/4`, i.e. `ρ ≥ 0.866`.
* `u76_requires_dominant_block` — the **impossibility statement** for the recorded
  bitlen-76 dial: a tie profile realising `ρ² ≤ 0.608²` must put more than `79 %` of the
  sample into a single tie class.
* `dyadic_block_le_half`, `u76_zero_count_profile_excluded` — the trailing-zero statistic
  puts exactly `50 %` in its largest class, so it fails that requirement by a wide
  margin: tie attenuation alone can never produce the recorded dial, at bitlen 76 or at
  any other bitlen.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialMaxBlock

open Catalog.Novelty.ZeroFitDialU64 Catalog.Novelty.ZeroFitDialU76

/-! ## 1. A uniform bound on the tie correction -/

/-- If `m² - 1 ≤ c` for every block size `m`, the tie correction obeys
`12·T ≤ c·n`. -/
lemma twelve_tieCorr_le_of_bound (c : ℚ) :
    ∀ L : List ℕ, (∀ m ∈ L, ((m : ℚ) ^ 2 - 1) ≤ c) → 12 * tieCorr L ≤ c * (L.sum : ℚ) := by
  intro L
  induction L with
  | nil => intro _; simp [tieCorr]
  | cons m L ih =>
      intro hbound
      have hm : ((m : ℚ) ^ 2 - 1) ≤ c := hbound m (by simp)
      have hrest : ∀ k ∈ L, ((k : ℚ) ^ 2 - 1) ≤ c := fun k hk => hbound k (by simp [hk])
      have hIH := ih hrest
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hterm : ((m : ℚ) ^ 3 - m) ≤ c * (m : ℚ) := by nlinarith
      have hcast : (((m + L.sum : ℕ)) : ℚ) = (m : ℚ) + (L.sum : ℚ) := by push_cast; ring
      rw [tieCorr_cons, List.sum_cons, hcast]
      have : 12 * (((m : ℚ) ^ 3 - m) / 12 + tieCorr L)
          = ((m : ℚ) ^ 3 - m) + 12 * tieCorr L := by ring
      rw [this]
      nlinarith

/-! ## 2. The dominant-block law -/

/-- **Dominant-block law.**  For *any* tie profile with largest block `M` and sample
size `n ≥ 2`, the attainable Spearman coefficient satisfies `ρ² ≥ 1 - (M²-1)/(n²-1)`. -/
theorem spearmanSq_ge_of_max_block (L : List ℕ) (M : ℕ) (hM : ∀ m ∈ L, m ≤ M)
    (hMpos : 1 ≤ M) (h : 2 ≤ L.sum) :
    1 - ((M : ℚ) ^ 2 - 1) / ((L.sum : ℚ) ^ 2 - 1) ≤ spearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hMq : (1 : ℚ) ≤ (M : ℚ) := by exact_mod_cast hMpos
  have hbound : ∀ m ∈ L, ((m : ℚ) ^ 2 - 1) ≤ (M : ℚ) ^ 2 - 1 := by
    intro m hm
    have : (m : ℚ) ≤ (M : ℚ) := by exact_mod_cast hM m hm
    have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
    nlinarith
  have hT := twelve_tieCorr_le_of_bound ((M : ℚ) ^ 2 - 1) L hbound
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hden2 : (0 : ℚ) < (L.sum : ℚ) ^ 2 - 1 := by nlinarith
  rw [spearmanSq_eq L h]
  have hratio : 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      ≤ ((M : ℚ) ^ 2 - 1) / ((L.sum : ℚ) ^ 2 - 1) := by
    rw [div_le_div_iff₀ hden hden2]
    have hfac : (L.sum : ℚ) ^ 3 - (L.sum : ℚ) = (L.sum : ℚ) * ((L.sum : ℚ) ^ 2 - 1) := by ring
    rw [hfac]
    nlinarith
  linarith

/-- Fractional form of the dominant-block law: `ρ² ≥ 1 - (M/n)²`. -/
theorem spearmanSq_ge_one_sub_sq_frac (L : List ℕ) (M : ℕ) (hM : ∀ m ∈ L, m ≤ M)
    (hMpos : 1 ≤ M) (hMn : M ≤ L.sum) (h : 2 ≤ L.sum) :
    1 - ((M : ℚ) / (L.sum : ℚ)) ^ 2 ≤ spearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hMq : (1 : ℚ) ≤ (M : ℚ) := by exact_mod_cast hMpos
  have hMnq : (M : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast hMn
  have hbase := spearmanSq_ge_of_max_block L M hM hMpos h
  have hden2 : (0 : ℚ) < (L.sum : ℚ) ^ 2 - 1 := by nlinarith
  have hstep : ((M : ℚ) ^ 2 - 1) / ((L.sum : ℚ) ^ 2 - 1) ≤ ((M : ℚ) / (L.sum : ℚ)) ^ 2 := by
    rw [div_pow, div_le_div_iff₀ hden2 (by positivity)]
    nlinarith
  linarith

/-- **Balanced statistics cannot attenuate below `ρ = 0.866`.**  If no tie class holds
more than half the sample, then `ρ² ≥ 3/4`. -/
theorem balanced_profile_ge_three_quarters (L : List ℕ) (h : 2 ≤ L.sum)
    (hhalf : ∀ m ∈ L, 2 * m ≤ L.sum) :
    3 / 4 ≤ spearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hbound : ∀ m ∈ L, ((m : ℚ) ^ 2 - 1) ≤ ((L.sum : ℚ) ^ 2 - 1) / 4 := by
    intro m hm
    have h2m : (2 : ℚ) * (m : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast hhalf m hm
    have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
    nlinarith
  have hT := twelve_tieCorr_le_of_bound (((L.sum : ℚ) ^ 2 - 1) / 4) L hbound
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  rw [spearmanSq_eq L h]
  have hratio : 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) ≤ 1 / 4 := by
    rw [div_le_div_iff₀ hden (by norm_num)]
    have hfac : (L.sum : ℚ) ^ 3 - (L.sum : ℚ) = (L.sum : ℚ) * ((L.sum : ℚ) ^ 2 - 1) := by ring
    rw [hfac]
    linarith
  linarith

/-! ## 3. Consequences for the recorded bitlen-76 dial -/

/-- **Impossibility statement.**  A tie profile whose ceiling is as low as the recorded
pooled dial `0.608` must concentrate more than `79 %` of the sample in a single tie
class. -/
theorem u76_requires_dominant_block (L : List ℕ) (M : ℕ) (hM : ∀ m ∈ L, m ≤ M)
    (hMpos : 1 ≤ M) (hMn : M ≤ L.sum) (h : 2 ≤ L.sum)
    (hlow : spearmanSq L ≤ pooled76 ^ 2) :
    (79 / 100 : ℚ) * (L.sum : ℚ) < (M : ℚ) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hMq : (1 : ℚ) ≤ (M : ℚ) := by exact_mod_cast hMpos
  have hbase := spearmanSq_ge_one_sub_sq_frac L M hM hMpos hMn h
  have hp : pooled76 ^ 2 = 369664 / 1000000 := by norm_num [pooled76]
  rw [hp] at hlow
  have hfrac : (630336 : ℚ) / 1000000 ≤ ((M : ℚ) / (L.sum : ℚ)) ^ 2 := by linarith
  have hnpos : (0 : ℚ) < (L.sum : ℚ) := by linarith
  rw [div_pow, le_div_iff₀ (by positivity)] at hfrac
  nlinarith [sq_nonneg ((M : ℚ) - 79 / 100 * (L.sum : ℚ)), sq_nonneg (L.sum : ℚ)]

/-- Every block of the dyadic (trailing-zero) profile holds at most half the sample. -/
theorem dyadic_block_le_half (b : ℕ) (hb : 1 ≤ b) :
    ∀ m ∈ dyadicBlocks b, 2 * m ≤ (dyadicBlocks b).sum := by
  intro m hm
  rw [dyadicBlocks_sum b]
  induction b with
  | zero => omega
  | succ k ih =>
      rw [dyadicBlocks, List.mem_cons] at hm
      rcases hm with rfl | hm
      · rw [pow_succ]; omega
      · rcases Nat.eq_zero_or_pos k with hk | hk
        · subst hk
          simp only [dyadicBlocks, List.mem_singleton] at hm
          subst hm
          norm_num
        · have := ih hk hm
          have h2 : (2 : ℕ) ^ k ≤ 2 ^ (k + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
          have hle : m ≤ 2 ^ k := by
            have := (dyadicBlocks_sum k) ▸ this
            omega
          calc 2 * m ≤ 2 * 2 ^ k := by omega
            _ = 2 ^ (k + 1) := by rw [pow_succ]; ring

/-- **The zero-count statistic is excluded at every bitlen.**  Its largest tie class is
exactly half the sample, so its ceiling never drops below `ρ² = 3/4` — far above the
recorded `0.608² ≈ 0.370`.  Combined with `Novelty.ZeroFitDialEffectiveBase`
(response ties only raise the ceiling) and `Novelty.ZeroFitDialPerturbation` (a rank-level
mechanism must re-rank a fixed fraction of the sample), the tie-theoretic explanations of
the round-65 measurement are exhausted. -/
theorem u76_zero_count_profile_excluded (b : ℕ) (hb : 1 ≤ b) :
    pooled76 ^ 2 < 3 / 4 ∧ 3 / 4 ≤ spearmanSq (dyadicBlocks b) := by
  refine ⟨by norm_num [pooled76], ?_⟩
  have h2 : 2 ≤ (dyadicBlocks b).sum := by
    rw [dyadicBlocks_sum b]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  exact balanced_profile_ge_three_quarters _ h2 (dyadic_block_le_half b hb)

end Catalog.Novelty.ZeroFitDialMaxBlock