import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialEnvelope
import Cryptography.BalancedBKeyDialRobustness

/-!
# BALANCED-BKEY, second cycle: fixed-weight (balanced) keys and the two-sided pin

## Research context (FACT round-54 #1, exp 523)

The first cycle (`Cryptography.BalancedBKeyDialRobustness`) showed that for *uniform* keys the
tie ceiling of the capped trailing-zero dial factorises over the two knobs, and that the
recorded `0.53` floor is guaranteed by a distribution-free *balance* condition.  The name of the
experiment, however, is `BALANCED-BKEY`: the keys are drawn **balanced**, i.e. with a fixed
Hamming weight `w`.  That changes the tie profile completely — it is binomial, not dyadic — so
none of the closed forms of cycle 1 apply.

This file settles the balanced case.

## Main results

* `weightBlocks`, `weightBlocks_sum` — the tie profile of the trailing-zero statistic on
  weight-`w` `b`-bit keys is `C(b-1-k, w-1)` for `k = 0,…,b-w`, and it sums to `C(b,w)`
  (a hockey-stick identity).
* `card_lowestOneBlock`, `weightBlocks_eq_census` — the **combinatorial bridge**: those binomials
  really are the block sizes of the lowest-set-bit statistic on the `w`-subsets of `{0,…,b-1}`.
* `weightBlocks_balanced`, `fixedWeight_no_cliff`, `fixedWeight_no_cliff_real` — the **balanced
  floor**: for `2w ≤ b` the modal block carries a fraction `w/b ≤ 1/2` of the keys, so the
  ceiling exceeds `3/4` in `ρ²` and `0.866` in `ρ`.  Every balanced-key cell of the recorded
  envelope clears the `0.53` floor, exactly as the uniform cells did.
* `half_weight_modal_half`, `fixedWeight_two_sided_pin` — at the *exactly* balanced weight
  `w = b/2` the modal block carries exactly half the keys, so the ceiling is pinned from **both**
  sides: `3/4 < ρ² ≤ 7/8 + 7/(8(n²-1))`.
* `law_change_capacity` — the payoff: at `w = b/2` the balanced ceiling and the uniform (dyadic)
  ceiling differ by less than `0.07` in `ρ`.  Swapping the draw law cannot move the dial by more
  than tie granularity allows, so a recorded balanced-versus-uniform difference above `0.07` is
  not a tie artefact.

## The scientific payload

Cycle 1 proved robustness *inside* the uniform law (across `bitlen × u`).  Cycle 2 proves
robustness *across* the law: the binomial profile of balanced keys obeys the same floor, is
pinned above by the same modal-block mechanism, and sits within `0.07` of the dyadic ceiling.
The `w/b` law (`modal_fraction_law`) identifies the exact mechanism: the modal trailing-zero
class of a weight-`w` key set is a `w/b` fraction of it, so balance in the *key* sense
(`2w ≤ b`) implies balance in the *tie* sense (no majority class), which is what the floor law
of cycle 1 consumes.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.MachineLearning.ZeroFitDialEnvelope

open Catalog.Cryptography.BalancedBKeyDialRobustness

namespace Catalog.Cryptography.BalancedBKeyFixedWeight

/-! ## 1. The binomial tie profile of balanced keys -/

/-- Tie profile of the trailing-zero statistic on the weight-`w` keys of `b` bits: the keys whose
lowest set bit is at position `k` number `C(b-1-k, w-1)`, for `k = 0,…,b-w`. -/
def weightBlocks (b w : ℕ) : List ℕ :=
  (List.range (b - w + 1)).map fun k => Nat.choose (b - 1 - k) (w - 1)

lemma list_map_range_sum (f : ℕ → ℕ) (n : ℕ) :
    ((List.range n).map f).sum = ∑ i ∈ Finset.range n, f i := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [List.range_succ, List.map_append, List.sum_append, ih, Finset.sum_range_succ]
      simp

/-- **Hockey stick.**  The binomial profile accounts for all `C(b,w)` balanced keys. -/
theorem weightBlocks_sum {b w : ℕ} (hw : 1 ≤ w) (hwb : w ≤ b) :
    (weightBlocks b w).sum = Nat.choose b w := by
  rw [weightBlocks, list_map_range_sum]
  have hrefl : ∑ k ∈ Finset.range (b - w + 1), Nat.choose (b - 1 - k) (w - 1)
      = ∑ j ∈ Finset.range (b - w + 1), Nat.choose (w - 1 + j) (w - 1) := by
    rw [← Finset.sum_range_reflect]
    refine Finset.sum_congr rfl ?_
    intro j hj
    have hj' : j < b - w + 1 := Finset.mem_range.1 hj
    congr 1
    omega
  rw [hrefl]
  have hIco : ∑ i ∈ Finset.Ico (w - 1) b, Nat.choose i (w - 1)
      = ∑ j ∈ Finset.range (b - (w - 1)), Nat.choose (w - 1 + j) (w - 1) :=
    Finset.sum_Ico_eq_sum_range (fun i => Nat.choose i (w - 1)) (w - 1) b
  have hlen : b - (w - 1) = b - w + 1 := by omega
  rw [hlen] at hIco
  rw [← hIco]
  have hIcc : Finset.Ico (w - 1) b = Finset.Icc (w - 1) (b - 1) := by
    ext i
    simp only [Finset.mem_Ico, Finset.mem_Icc]
    omega
  rw [hIcc, Nat.sum_Icc_choose]
  congr 1 <;> omega

/-- **Modal fraction law.**  The modal trailing-zero class of the weight-`w` keys is the class of
odd keys, and it carries a fraction `w/b` of them: `b·C(b-1,w-1) = w·C(b,w)`. -/
theorem modal_fraction_law {b w : ℕ} (hw : 1 ≤ w) (hwb : w ≤ b) :
    b * Nat.choose (b - 1) (w - 1) = w * Nat.choose b w := by
  obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
  obtain ⟨v, rfl⟩ : ∃ v, w = v + 1 := ⟨w - 1, by omega⟩
  simpa [Nat.succ_eq_add_one, mul_comm] using Nat.add_one_mul_choose_eq c v

/-- Every block of the binomial profile is at most the modal one. -/
theorem weightBlocks_le_modal (b w : ℕ) :
    ∀ m ∈ weightBlocks b w, m ≤ Nat.choose (b - 1) (w - 1) := by
  intro m hm
  rw [weightBlocks, List.mem_map] at hm
  obtain ⟨k, _, rfl⟩ := hm
  exact Nat.choose_le_choose (w - 1) (by omega)

/-- **Balance transfer.**  Key balance (`2w ≤ b`) implies tie balance: no trailing-zero class of
the weight-`w` keys carries more than half of them. -/
theorem weightBlocks_balanced {b w : ℕ} (hw : 1 ≤ w) (h2w : 2 * w ≤ b) :
    ∀ m ∈ weightBlocks b w, 2 * m ≤ (weightBlocks b w).sum := by
  intro m hm
  have hwb : w ≤ b := by omega
  have hb : 0 < b := by omega
  have hmax := weightBlocks_le_modal b w m hm
  have hkey := modal_fraction_law hw hwb
  have hmodal : 2 * Nat.choose (b - 1) (w - 1) ≤ Nat.choose b w := by
    have h1 : b * (2 * Nat.choose (b - 1) (w - 1)) = 2 * w * Nat.choose b w := by
      rw [show b * (2 * Nat.choose (b - 1) (w - 1)) = 2 * (b * Nat.choose (b - 1) (w - 1)) by ring,
        hkey]
      ring
    have h2 : 2 * w * Nat.choose b w ≤ b * Nat.choose b w := Nat.mul_le_mul_right _ h2w
    have h3 : b * (2 * Nat.choose (b - 1) (w - 1)) ≤ b * Nat.choose b w := by omega
    exact Nat.le_of_mul_le_mul_left h3 hb
  rw [weightBlocks_sum hw hwb]
  omega

/-- Balanced key sets are big enough for the correlation to be defined. -/
theorem two_le_weightBlocks_sum {b w : ℕ} (hw : 1 ≤ w) (h2w : 2 * w ≤ b) :
    2 ≤ (weightBlocks b w).sum := by
  have hwb : w ≤ b := by omega
  rw [weightBlocks_sum hw hwb]
  have hkey := modal_fraction_law hw hwb
  have hpos : 0 < Nat.choose (b - 1) (w - 1) := Nat.choose_pos (by omega)
  have h1 : b ≤ w * Nat.choose b w := by
    calc b = b * 1 := (Nat.mul_one b).symm
      _ ≤ b * Nat.choose (b - 1) (w - 1) := Nat.mul_le_mul_left _ hpos
      _ = w * Nat.choose b w := hkey
  nlinarith [h1, h2w, hw]

/-- **Balanced floor (rational form).**  For balanced keys with `2w ≤ b` the tie ceiling of the
trailing-zero dial exceeds `3/4`, exactly as in the uniform case. -/
theorem fixedWeight_no_cliff {b w : ℕ} (hw : 1 ≤ w) (h2w : 2 * w ≤ b) :
    3 / 4 < spearmanSq (weightBlocks b w) :=
  balanced_no_cliff _ (two_le_weightBlocks_sum hw h2w) (weightBlocks_balanced hw h2w)

/-- **Balanced floor (recorded form).**  Every balanced-key cell clears the recorded `0.53`
floor, with the same `0.866` margin as the uniform cells. -/
theorem fixedWeight_no_cliff_real {b w : ℕ} (hw : 1 ≤ w) (h2w : 2 * w ≤ b) :
    (53 : ℝ) / 100 < spearman (weightBlocks b w) :=
  (balanced_no_cliff_real _ (two_le_weightBlocks_sum hw h2w) (weightBlocks_balanced hw h2w)).1

/-! ## 2. The exactly balanced weight `w = b/2`: a two-sided pin -/

/-- At the exactly balanced weight the modal class carries exactly half the keys. -/
theorem half_weight_modal_half {v : ℕ} (hv : 1 ≤ v) :
    2 * Nat.choose (2 * v - 1) (v - 1) = Nat.choose (2 * v) v := by
  have hkey := modal_fraction_law (b := 2 * v) (w := v) hv (by omega)
  have hpos : 0 < v := hv
  have h : v * (2 * Nat.choose (2 * v - 1) (v - 1)) = v * Nat.choose (2 * v) v := by
    calc v * (2 * Nat.choose (2 * v - 1) (v - 1))
        = 2 * v * Nat.choose (2 * v - 1) (v - 1) := by ring
      _ = v * Nat.choose (2 * v) v := hkey
  exact Nat.eq_of_mul_eq_mul_left hpos h

/-- For `v ≥ 2` the modal block of the exactly balanced profile has at least two keys. -/
lemma two_le_modal {v : ℕ} (hv : 2 ≤ v) : 2 ≤ Nat.choose (2 * v - 1) (v - 1) := by
  obtain ⟨c, rfl⟩ : ∃ c, v = c + 2 := ⟨v - 2, by omega⟩
  have h : 2 * (c + 2) - 1 = (2 * c + 2) + 1 := by omega
  have hk : (c + 2) - 1 = c + 1 := by omega
  rw [h, hk, Nat.choose_succ_succ]
  simp only [Nat.succ_eq_add_one]
  have h1 : 0 < Nat.choose (2 * c + 2) c := Nat.choose_pos (by omega)
  have h2 : 0 < Nat.choose (2 * c + 2) (c + 1) := Nat.choose_pos (by omega)
  omega

/-- The modal block occurs in the profile. -/
theorem modal_mem_weightBlocks (b w : ℕ) :
    Nat.choose (b - 1) (w - 1) ∈ weightBlocks b w := by
  rw [weightBlocks, List.mem_map]
  exact ⟨0, List.mem_range.2 (by omega), by simp⟩

/-- **Two-sided pin at `w = b/2`.**  The exactly balanced profile has a modal class of exactly
half the mass, so its ceiling is bounded above by the half-mass cap as well as below by the
floor: `3/4 < ρ² ≤ 7/8 + 7/(8(n²-1))`. -/
theorem fixedWeight_two_sided_pin {v : ℕ} (hv : 1 ≤ v) :
    3 / 4 < spearmanSq (weightBlocks (2 * v) v) ∧
      spearmanSq (weightBlocks (2 * v) v)
        ≤ 7 / 8 + 7 / (8 * (((weightBlocks (2 * v) v).sum : ℚ) ^ 2 - 1)) := by
  have hsum2 : 2 ≤ (weightBlocks (2 * v) v).sum := two_le_weightBlocks_sum hv (by omega)
  refine ⟨fixedWeight_no_cliff hv (by omega), ?_⟩
  have hmem : Nat.choose (2 * v - 1) (v - 1) ∈ weightBlocks (2 * v) v :=
    modal_mem_weightBlocks _ _
  have hhalf : ((weightBlocks (2 * v) v).sum : ℚ) ≤ 2 * (Nat.choose (2 * v - 1) (v - 1) : ℚ) := by
    rw [weightBlocks_sum hv (by omega)]
    have := half_weight_modal_half hv
    have hq : ((Nat.choose (2 * v) v : ℕ) : ℚ) = ((2 * Nat.choose (2 * v - 1) (v - 1) : ℕ) : ℚ) := by
      rw [this]
    push_cast at hq
    linarith
  exact half_mass_ceiling _ _ hmem hsum2 hhalf

/-! ## 3. The combinatorial bridge: lowest-set-bit blocks of balanced keys -/

/-- Balanced `b`-bit keys of weight `w` whose lowest set bit is at position `k`, modelled as
`w`-element subsets of `{0,…,b-1}` with minimum `k`. -/
def lowestOneBlock (b w k : ℕ) : Finset (Finset ℕ) :=
  ((range b).powersetCard w).filter fun S => k ∈ S ∧ ∀ x ∈ S, k ≤ x

/-- **Block census for balanced keys.**  Exactly `C(b-1-k, w-1)` of the weight-`w` keys below
`2^b` have their lowest set bit at position `k`. -/
theorem card_lowestOneBlock {b w k : ℕ} (hw : 1 ≤ w) (hk : k < b) :
    (lowestOneBlock b w k).card = Nat.choose (b - 1 - k) (w - 1) := by
  classical
  have hcard : ((Ico (k + 1) b).powersetCard (w - 1)).card = Nat.choose (b - 1 - k) (w - 1) := by
    rw [card_powersetCard, Nat.card_Ico]
    congr 1
    omega
  rw [← hcard]
  refine Finset.card_bij' (fun S _ => S.erase k) (fun T _ => insert k T) ?_ ?_ ?_ ?_
  · -- forward map lands in the target
    intro S hS
    simp only [lowestOneBlock, mem_filter, mem_powersetCard] at hS
    obtain ⟨⟨hsub, hcardS⟩, hkS, hmin⟩ := hS
    rw [mem_powersetCard]
    constructor
    · intro x hx
      have hxS : x ∈ S := mem_of_mem_erase hx
      have hxk : x ≠ k := ne_of_mem_erase hx
      have hxb : x < b := mem_range.1 (hsub hxS)
      have hkx : k ≤ x := hmin x hxS
      exact mem_Ico.2 ⟨by omega, hxb⟩
    · rw [card_erase_of_mem hkS, hcardS]
  · -- backward map lands in the source
    intro T hT
    rw [mem_powersetCard] at hT
    obtain ⟨hsub, hcardT⟩ := hT
    have hkT : k ∉ T := fun hc => by
      have := mem_Ico.1 (hsub hc)
      omega
    simp only [lowestOneBlock, mem_filter, mem_powersetCard]
    refine ⟨⟨?_, ?_⟩, mem_insert_self _ _, ?_⟩
    · intro x hx
      rcases mem_insert.1 hx with rfl | hxT
      · exact mem_range.2 hk
      · exact mem_range.2 (mem_Ico.1 (hsub hxT)).2
    · rw [card_insert_of_notMem hkT, hcardT]
      omega
    · intro x hx
      rcases mem_insert.1 hx with rfl | hxT
      · exact le_rfl
      · exact le_of_lt (mem_Ico.1 (hsub hxT)).1
  · -- left inverse
    intro S hS
    simp only [lowestOneBlock, mem_filter] at hS
    exact insert_erase hS.2.1
  · -- right inverse
    intro T hT
    rw [mem_powersetCard] at hT
    have hkT : k ∉ T := fun hc => by
      have := mem_Ico.1 (hT.1 hc)
      omega
    exact erase_insert hkT

/-- **Bridge.**  The binomial profile used above is literally the census of lowest-set-bit blocks
of the balanced key space. -/
theorem weightBlocks_eq_census {b w : ℕ} (hw : 1 ≤ w) (hwb : w ≤ b) :
    weightBlocks b w
      = (List.range (b - w + 1)).map fun k => (lowestOneBlock b w k).card := by
  rw [weightBlocks]
  refine List.map_congr_left ?_
  intro k hk
  have hk' : k < b - w + 1 := List.mem_range.1 hk
  exact (card_lowestOneBlock hw (by omega)).symm

/-! ## 4. Changing the draw law moves the ceiling by less than the recorded effects -/

/-- **Law-change capacity.**  At the exactly balanced weight `w = b/2` (bitlen `b = 2v ≥ 4`) the
balanced ceiling and the uniform (dyadic) ceiling differ by less than `0.07` in `ρ`, in both
directions.  Tie structure therefore cannot account for a balanced-versus-uniform difference
above `0.07`. -/
theorem law_change_capacity {v : ℕ} (hv : 2 ≤ v) :
    |spearman (weightBlocks (2 * v) v) - spearman (dyadicBlocks (2 * v))| < 7 / 100 := by
  have hv1 : 1 ≤ v := by omega
  have hb : 1 ≤ 2 * v := by omega
  have hsumW : 2 ≤ (weightBlocks (2 * v) v).sum := two_le_weightBlocks_sum hv1 (by omega)
  have hsumD : 2 ≤ (dyadicBlocks (2 * v)).sum := by
    rw [dyadicBlocks_sum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ (2 * v) := Nat.pow_le_pow_right (by norm_num) (by omega)
  -- rational bounds on the two ceilings
  have hWlow : (3 : ℚ) / 4 < spearmanSq (weightBlocks (2 * v) v) := fixedWeight_no_cliff hv1 (by omega)
  have hWhigh : spearmanSq (weightBlocks (2 * v) v) ≤ 15 / 16 := by
    obtain ⟨-, hpin⟩ := fixedWeight_two_sided_pin hv1
    have hnat : 4 ≤ (weightBlocks (2 * v) v).sum := by
      rw [weightBlocks_sum hv1 (by omega), ← half_weight_modal_half hv1]
      have := two_le_modal hv
      omega
    have hn : (4 : ℚ) ≤ ((weightBlocks (2 * v) v).sum : ℚ) := by exact_mod_cast hnat
    have hsq : (15 : ℚ) ≤ ((weightBlocks (2 * v) v).sum : ℚ) ^ 2 - 1 := by nlinarith
    have hfrac : 7 / (8 * (((weightBlocks (2 * v) v).sum : ℚ) ^ 2 - 1)) ≤ 7 / 120 := by
      apply div_le_div_of_nonneg_left (by norm_num) (by norm_num) (by linarith)
    linarith
  have hDlow : (6 : ℚ) / 7 < spearmanSq (dyadicBlocks (2 * v)) := dyadic_ceiling_gt _ (by omega)
  have hDhigh : spearmanSq (dyadicBlocks (2 * v)) ≤ 6 / 7 + 1 / 256 := by
    have hclose := dyadic_ceiling_close (2 * v) (by omega)
    have hpow : ((1 : ℚ) / 4) ^ (2 * v) ≤ (1 / 4 : ℚ) ^ 4 :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
    norm_num at hpow
    linarith
  -- pass to real square roots
  rw [spearman_eq_sqrt _ hsumW, spearman_eq_sqrt _ hsumD, abs_lt]
  set X : ℝ := ((spearmanSq (weightBlocks (2 * v) v) : ℚ) : ℝ) with hX
  set Y : ℝ := ((spearmanSq (dyadicBlocks (2 * v)) : ℚ) : ℝ) with hY
  have hXlow : (3 : ℝ) / 4 < X := by
    have hc : (((3 : ℚ) / 4 : ℚ) : ℝ) < ((spearmanSq (weightBlocks (2 * v) v) : ℚ) : ℝ) := by
      exact_mod_cast hWlow
    rw [hX]; push_cast at hc; linarith
  have hXhigh : X ≤ 15 / 16 := by
    have hc : ((spearmanSq (weightBlocks (2 * v) v) : ℚ) : ℝ) ≤ (((15 : ℚ) / 16 : ℚ) : ℝ) := by
      exact_mod_cast hWhigh
    rw [hX]; push_cast at hc; linarith
  have hYlow : (6 : ℝ) / 7 < Y := by
    have hc : (((6 : ℚ) / 7 : ℚ) : ℝ) < ((spearmanSq (dyadicBlocks (2 * v)) : ℚ) : ℝ) := by
      exact_mod_cast hDlow
    rw [hY]; push_cast at hc; linarith
  have hYhigh : Y ≤ 6 / 7 + 1 / 256 := by
    have hc : ((spearmanSq (dyadicBlocks (2 * v)) : ℚ) : ℝ)
        ≤ (((6 : ℚ) / 7 + 1 / 256 : ℚ) : ℝ) := by exact_mod_cast hDhigh
    rw [hY]; push_cast at hc; linarith
  have hX0 : (0 : ℝ) ≤ X := by linarith
  have hY0 : (0 : ℝ) ≤ Y := by linarith
  have hsqX : Real.sqrt X ^ 2 = X := Real.sq_sqrt hX0
  have hsqY : Real.sqrt Y ^ 2 = Y := Real.sq_sqrt hY0
  have hsX0 : 0 ≤ Real.sqrt X := Real.sqrt_nonneg X
  have hsY0 : 0 ≤ Real.sqrt Y := Real.sqrt_nonneg Y
  have hsXlow : (866 : ℝ) / 1000 ≤ Real.sqrt X := by
    rw [Real.le_sqrt (by norm_num) hX0]; nlinarith
  have hsYlow : (925 : ℝ) / 1000 ≤ Real.sqrt Y := by
    rw [Real.le_sqrt (by norm_num) hY0]; nlinarith
  have hsXhigh : Real.sqrt X < 969 / 1000 := by
    rw [Real.sqrt_lt' (by norm_num)]; nlinarith
  have hsYhigh : Real.sqrt Y < 928 / 1000 := by
    rw [Real.sqrt_lt' (by norm_num)]; nlinarith
  constructor <;> linarith

/-!
## Lab notes (cycle 2, balanced key draws)

Exact rational evaluations of the binomial profile (Lean `#eval`, exact `ℚ`):

| `b` | `w` | profile `weightBlocks b w` | `n = C(b,w)` | `ρ²` | `ρ` |
|---|---|---|---|---|---|
| 6 | 3 | `[10, 6, 3, 1]` | 20 | `563/665 = 0.846617` | `0.920118` |
| 8 | 4 | `[35, 20, 10, 4, 1]` | 70 | `1386/1633 = 0.848745` | `0.921274` |

Uniform comparison at the same bitlens: `ρ²(dyadicBlocks 8) = 28197/32896 = 0.857154`,
`ρ = 0.925826`.  The balanced-versus-uniform movement at `b = 8` is `0.004552` in `ρ`, well
inside the `0.07` capacity proved in `law_change_capacity`.

Both balanced rows satisfy the two-sided pin: `0.75 < ρ² ≤ 7/8 + 7/(8(n²-1))`, i.e.
`ρ² ≤ 0.877193` at `n = 20` and `ρ² ≤ 0.875179` at `n = 70` (`fixedWeight_two_sided_pin`).
The hockey-stick check `10 + 6 + 3 + 1 = 20 = C(6,3)` is the content of `weightBlocks_sum`, and
`2·10 = 20 = C(6,3)` is the exact half-mass identity `half_weight_modal_half`.
-/

end Catalog.Cryptography.BalancedBKeyFixedWeight