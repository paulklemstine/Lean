import Mathlib
import Novelty.ZeroFitDialU64
import Cryptography.BalancedBKeyDialRobustness
import Combinatorics.BKeyMixedZoneGradualDecline
import Combinatorics.BKeyMixedZoneGridLaw

/-!
# BKEY-MIXED-ZONE III: no convention artifact, and no sharp edge at the practical floor

## Research context (FACT round-55 #1, exp 523, `BALANCED-BKEY`, paper 182 addendum)

The round-55 verdict has three clauses: the decline of the `T`-dial is (i) **gradual**,
(ii) not a **threshold effect**, and (iii) not a **convention artifact**.  Clauses (i) and
(ii) are handled in `Combinatorics.BKeyMixedZoneGridLaw`.  This file settles (iii) and gives
the quantitative form of paper 178's "practical floor at bitlen ≈ 54 is a gradual
transition".

A *convention* here is a choice of how a single boundary key (typically `x = 0`, whose
2-adic valuation is conventionally `∞` or `b`) is assigned to a tie class of the capped
statistic `T_u`.  Changing the convention moves **one key** between two tie blocks.

## Main results

* `spearmanSq_sub`, `ceiling_perturbation_bound` — the exact and the bounded form of how the
  Spearman ceiling responds to an edit of the tie profile that preserves the sample size.
* `tieCorr_move_diff` — the **exact** Kendall change caused by moving one key from a block of
  size `m + 1` to a block of size `m'`: `3(m² + m) - 3(m'² + m')`.
* `convention_move_bound` — for a *balanced* profile (no block above half the sample) a
  one-key convention change moves the ceiling by less than `4 / N`, `N` the sample size.
* `capped_profile_convention_stability` — instantiated on the recorded envelope
  (`b ≥ 32`, active cap): **any** one-key convention change moves the ceiling by less than
  `10^{-9}`, i.e. eight orders of magnitude below the recorded `0.26` decline.  The decline
  cannot be a convention artifact.
* `transition_width`, `floor_transition_at_least_two_notches` — the **transition-width law**:
  crossing a band of half-width `η` around a practical floor takes at least `2η / d` notches
  when no notch exceeds `d`.  With the recorded notch bound `0.09` and the band `±0.05`,
  paper 178's floor is crossed over at least two bitlen notches — it is not an edge.
* `geometric_descent_needs_three_notches` — with a per-notch retention of `7/8` the dial
  cannot fall from the recorded top `0.79` to the recorded bottom `0.53` in two notches.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Cryptography.BalancedBKeyDialRobustness
open Catalog.Combinatorics.BKeyMixedZoneGradualDecline
open Catalog.Combinatorics.BKeyMixedZoneGridLaw

namespace Catalog.Combinatorics.BKeyMixedZoneConventionStability

/-! ## 1. How the ceiling responds to an edit of the tie profile -/

/-- **Exact response of the ceiling to a size-preserving profile edit.** -/
theorem spearmanSq_sub (L L' : List ℕ) (hsum : L.sum = L'.sum) (h2 : 2 ≤ L.sum) :
    spearmanSq L - spearmanSq L'
      = (12 * tieCorr L' - 12 * tieCorr L) / ((L.sum : ℚ) ^ 3 - L.sum) := by
  have h2' : 2 ≤ L'.sum := by omega
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  have hcast : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by exact_mod_cast hsum.symm
  rw [spearmanSq_eq L h2, spearmanSq_eq L' h2', hcast]
  field_simp
  ring

/-- **Bounded response.**  If the edit changes `12·tieCorr` by at most `Δ`, the ceiling moves
by at most `Δ / (N³ - N)`. -/
theorem ceiling_perturbation_bound (L L' : List ℕ) (Δ : ℚ) (hsum : L.sum = L'.sum)
    (h2 : 2 ≤ L.sum) (hΔ : |12 * tieCorr L' - 12 * tieCorr L| ≤ Δ) :
    |spearmanSq L - spearmanSq L'| ≤ Δ / ((L.sum : ℚ) ^ 3 - L.sum) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  rw [spearmanSq_sub L L' hsum h2, abs_div, abs_of_pos hden]
  exact div_le_div_of_nonneg_right hΔ (le_of_lt hden)

/-! ## 2. A one-key convention change -/

/-- A convention change moves one key between two tie blocks; the sample size is unchanged. -/
lemma move_sum_eq (A B : List ℕ) (m m' : ℕ) :
    (A ++ (m + 1) :: m' :: B).sum = (A ++ m :: (m' + 1) :: B).sum := by
  simp [List.sum_append]
  omega

/-- **Exact Kendall change of a one-key convention move.** -/
theorem tieCorr_move_diff (A B : List ℕ) (m m' : ℕ) :
    12 * tieCorr (A ++ m :: (m' + 1) :: B) - 12 * tieCorr (A ++ (m + 1) :: m' :: B)
      = 3 * ((m' : ℚ) ^ 2 + m') - 3 * ((m : ℚ) ^ 2 + m) := by
  rw [tieCorr_append, tieCorr_append, tieCorr_cons, tieCorr_cons, tieCorr_cons, tieCorr_cons]
  push_cast
  ring

/-- **A one-key convention change barely moves the ceiling.**  For a *balanced* profile — no
tie block carries more than half of the `N` keys, which is exactly the situation of the
capped trailing-zero statistic — the ceiling moves by less than `4 / N`. -/
theorem convention_move_bound (A B : List ℕ) (m m' : ℕ)
    (hbal : 2 * (m + 1) ≤ (A ++ (m + 1) :: m' :: B).sum)
    (hbal' : 2 * m' ≤ (A ++ (m + 1) :: m' :: B).sum)
    (hN : 2 ≤ (A ++ (m + 1) :: m' :: B).sum) :
    |spearmanSq (A ++ (m + 1) :: m' :: B) - spearmanSq (A ++ m :: (m' + 1) :: B)|
      < 4 / ((A ++ (m + 1) :: m' :: B).sum : ℚ) := by
  set L := A ++ (m + 1) :: m' :: B with hL
  set L' := A ++ m :: (m' + 1) :: B with hL'
  have hN2 : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast hN
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hN2
  have hc1 : ((2 * (m + 1) : ℕ) : ℚ) = 2 * ((m : ℚ) + 1) := by push_cast; ring
  have hc2 : ((2 * m' : ℕ) : ℚ) = 2 * (m' : ℚ) := by push_cast; ring
  have hmq : 2 * ((m : ℚ) + 1) ≤ (L.sum : ℚ) := hc1 ▸ (Nat.cast_le.mpr hbal)
  have hm'q : 2 * (m' : ℚ) ≤ (L.sum : ℚ) := hc2 ▸ (Nat.cast_le.mpr hbal')
  have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
  have hm'0 : (0 : ℚ) ≤ (m' : ℚ) := by positivity
  -- the Kendall change is at most `3(N²/4 + N/2)` in absolute value
  have hdiff := tieCorr_move_diff A B m m'
  have habs : |12 * tieCorr L' - 12 * tieCorr L|
      ≤ 3 * ((L.sum : ℚ) ^ 2 / 4 + (L.sum : ℚ) / 2) := by
    rw [hL, hL', hdiff, abs_le]
    constructor <;> nlinarith
  have hbound := ceiling_perturbation_bound L L'
    (3 * ((L.sum : ℚ) ^ 2 / 4 + (L.sum : ℚ) / 2)) (move_sum_eq A B m m') hN habs
  have hfinal : 3 * ((L.sum : ℚ) ^ 2 / 4 + (L.sum : ℚ) / 2) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      < 4 / (L.sum : ℚ) := by
    rw [div_lt_div_iff₀ hden (by linarith)]
    nlinarith
  exact lt_of_le_of_lt hbound hfinal

/-- **No convention artifact.**  At any recorded bit length (`b ≥ 32`) and any active cap,
moving a single key between two tie classes of the capped statistic changes the Spearman
ceiling by less than `10^{-9}` — eight orders of magnitude below the recorded `0.26`
decline.  The recorded decline cannot be produced by a convention choice. -/
theorem capped_profile_convention_stability {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) (hb : 32 ≤ b)
    (A B : List ℕ) (m m' : ℕ) (hdec : capBlocks u b = A ++ (m + 1) :: m' :: B) :
    |spearmanSq (capBlocks u b) - spearmanSq (A ++ m :: (m' + 1) :: B)| < 1 / 10 ^ 9 := by
  have hsum : (capBlocks u b).sum = 2 ^ b := capBlocks_sum' hub
  have hmem1 : (m + 1) ∈ capBlocks u b := by rw [hdec]; simp
  have hmem2 : m' ∈ capBlocks u b := by rw [hdec]; simp
  have hbal1 : 2 * (m + 1) ≤ (capBlocks u b).sum := capBlocks_balanced hu hub _ hmem1
  have hbal2 : 2 * m' ≤ (capBlocks u b).sum := capBlocks_balanced hu hub _ hmem2
  have hpow : (2 : ℕ) ^ 32 ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hN : 2 ≤ (capBlocks u b).sum := by rw [hsum]; omega
  have hkey := convention_move_bound A B m m' (by rw [← hdec]; exact hbal1)
    (by rw [← hdec]; exact hbal2) (by rw [← hdec]; exact hN)
  rw [← hdec] at hkey
  have hNbig : (4294967296 : ℚ) ≤ ((capBlocks u b).sum : ℚ) := by
    have : (4294967296 : ℕ) ≤ (capBlocks u b).sum := by
      rw [hsum]; simpa using hpow
    exact_mod_cast this
  have hlast : 4 / ((capBlocks u b).sum : ℚ) < 1 / 10 ^ 9 := by
    rw [div_lt_div_iff₀ (by linarith) (by norm_num)]
    linarith
  exact lt_trans hkey hlast

/-! ## 3. The practical floor is a transition of positive width -/

/-- The one-dial view of a grid: a bit-length dial with the cap held fixed. -/
def dialOf (s : ℕ → ℚ) : ℕ → ℕ → ℚ := fun b _ => s b

lemma dialOf_rowStep (s : ℕ → ℚ) (b u : ℕ) : rowStep (dialOf s) b u = s b - s (b + 1) := rfl

/-- **Transition-width law.**  If no notch of the dial drops by more than `d`, then crossing
a band of half-width `η` around the practical floor `τ` takes at least `2η / d` notches:
a floor with `d < 2η` can never be a sharp edge. -/
theorem transition_width (s : ℕ → ℚ) (d τ η : ℚ) (k m : ℕ)
    (hd : ∀ j, s j - s (j + 1) ≤ d) (hup : τ + η ≤ s k) (hdown : s (k + m) ≤ τ - η) :
    2 * η ≤ (m : ℚ) * d := by
  have htel := rowRun_telescope (dialOf s) k 0 m
  have hle : ∀ x ∈ ((List.range m).map fun i => rowStep (dialOf s) (k + i) 0), x ≤ d := by
    intro x hx
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
    rw [dialOf_rowStep]
    exact hd (k + i)
  have hsum := List.sum_le_card_nsmul
    (((List.range m).map fun i => rowStep (dialOf s) (k + i) 0)) d hle
  rw [htel] at hsum
  simp only [List.length_map, List.length_range, nsmul_eq_mul] at hsum
  have : s k - s (k + m) = s k - s (k + m) := rfl
  have hdrop : 2 * η ≤ s k - s (k + m) := by
    simp only [dialOf] at hsum
    linarith
  simp only [dialOf] at hsum
  linarith

/-- **Paper 178's practical floor is not an edge.**  With the recorded per-notch bound
`0.09` and a band of half-width `0.05` around the floor, the dial needs at least two bitlen
notches to cross the band. -/
theorem floor_transition_at_least_two_notches (s : ℕ → ℚ) (τ : ℚ) (k m : ℕ)
    (hd : ∀ j, s j - s (j + 1) ≤ 9 / 100)
    (hup : τ + 5 / 100 ≤ s k) (hdown : s (k + m) ≤ τ - 5 / 100) : 2 ≤ m := by
  have h := transition_width s (9 / 100) τ (5 / 100) k m hd hup hdown
  by_contra hcon
  push_neg at hcon
  interval_cases m <;> norm_num at h

/-- **Geometric descent needs three notches.**  If each bitlen notch retains at least `7/8`
of the correlation, the dial cannot fall from the recorded top `0.79` to the recorded
bottom `0.53` in two notches. -/
theorem geometric_descent_needs_three_notches (s : ℕ → ℚ) (n : ℕ)
    (hstep : ∀ k, 7 / 8 * s k ≤ s (k + 1)) (h0 : s n = 79 / 100) :
    53 / 100 < s (n + 2) := by
  apply slow_descent s (7 / 8) (53 / 100) (by norm_num) hstep n 2
  rw [h0]; norm_num

end Catalog.Combinatorics.BKeyMixedZoneConventionStability