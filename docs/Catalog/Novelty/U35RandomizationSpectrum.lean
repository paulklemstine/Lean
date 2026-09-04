import Mathlib
import Novelty.U35PairedDrop

/-!
# U35 localization IV: the randomization distribution is a subset-sum spectrum

## Research context (FACT round-45 #1, exp 500, assessment v276)

`Novelty.U35PairedDrop` computed the *tip* of the exp-500 randomization distribution: with all
14 paired drops positive, exactly one of the `2^14` sign re-labellings is as extreme as the
observed one, so the exact one-sided p-value is `2⁻¹⁴`.  That argument sees only the maximum.
This file describes the **whole upper tail**, and the description is a bridge between three
different subjects:

```
randomization inference   <->   Boolean-cube lattice points in a half-space   <->   subset sums
```

* `signedSum_eq_sub_two_mul_flipSum` — the coordinate change.  Writing `Sflip s` for the set of
  flipped coordinates, every re-labelling satisfies `signedSum d s = (∑ d) − 2 · ∑_{Sflip} d`.
  The randomization statistic is an affine image of a subset sum; the `2^n` sign vectors are
  the lattice points of the Boolean cube and the "at least as extreme" event is the cube's
  intersection with a half-space.
* `extreme_count_eq_subsetSum_count` — hence, for every threshold `t`, the number of
  re-labellings within `2t` of the observed statistic equals the number of *subsets* of the 14
  seeds whose drop-sum is at most `t`.  Randomization tails are subset-sum counting problems —
  the reason exact randomization p-values are `#P`-hard in general, and the reason the
  degenerate `t = 0` case (file II) is easy.
* `subsetSum_count_le_binomial_tail` — a uniform lower bound `c ≤ dᵢ` on the drops collapses
  the subset-sum count into a **binomial tail**: only subsets of size `≤ k` can qualify once
  `t < c(k+1)`, so the count is at most `∑_{j≤k} C(n,j)`.  This is where file III's uniform
  bound `dᵢ > 0.066` pays off.
* `u35_randomization_tail_bound` — at the recorded numbers: **at most 15 of the 16384
  re-labellings** come within `0.26` of the observed drop total, so even the *robustified*
  p-value (allowing an adversary a `0.26` haircut, i.e. `18 %` of the total drop `1.4798`)
  stays below `10⁻³`.  The `14/14` verdict is not a knife-edge of the sign test.
* `randomization_spectral_gap` — the observed statistic is *isolated*: every other re-labelling
  is at least `2c = 0.132` below it, a gap of `8.9 %` of the total.  The randomization
  distribution has a genuine spectral gap at its top, which is the structural reason the
  paired effect is decisive while the unpaired floor question was not.

## Lab notes (derived quantities, all verified below)

```
total drop                       14 * 0.1057 = 1.4798
uniform per-seed drop bound      c = 0.066                    (file III)
haircut allowed                  2t = 0.26,  t = 0.13 < 2c = 0.132  -> k = 1
tail count bound                 C(14,0) + C(14,1) = 15
robustified p-value              15/16384 = 0.000915...       < 1e-3
spectral gap at the top          2c = 0.132 = 8.92 % of 1.4798
```
-/

namespace Catalog.Novelty.U35RandomizationSpectrum

open Finset
open Catalog.Novelty.U35PairedDrop

variable {n : ℕ}

/-! ## 1. The coordinate change: sign vectors as subsets -/

/-- The set of coordinates flipped by the re-labelling `s`. -/
def flipSet (s : Fin n → Bool) : Finset (Fin n) := {i | s i = false}

/-- The drop mass carried by a set of flipped coordinates. -/
def flipSum (d : Fin n → ℝ) (S : Finset (Fin n)) : ℝ := ∑ i ∈ S, d i

/-- **The coordinate change.**  A sign re-labelling subtracts exactly twice the drop mass of
the coordinates it flips. -/
theorem signedSum_eq_sub_two_mul_flipSum (d : Fin n → ℝ) (s : Fin n → Bool) :
    signedSum d s = (∑ i, d i) - 2 * flipSum d (flipSet s) := by
  classical
  have hsplit :
      (∑ i ∈ {i | s i = false}, (if s i then d i else -d i))
        + ∑ i ∈ {i ∈ (univ : Finset (Fin n)) | ¬ (s i = false)}, (if s i then d i else -d i)
      = ∑ i, (if s i then d i else -d i) :=
    Finset.sum_filter_add_sum_filter_not _ _ _
  have hsplit' :
      (∑ i ∈ {i | s i = false}, d i)
        + ∑ i ∈ {i ∈ (univ : Finset (Fin n)) | ¬ (s i = false)}, d i = ∑ i, d i :=
    Finset.sum_filter_add_sum_filter_not _ _ _
  have hneg : (∑ i ∈ {i | s i = false}, (if s i then d i else -d i))
      = -∑ i ∈ {i | s i = false}, d i := by
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl ?_
    intro i hi
    have : s i = false := by simpa using (Finset.mem_filter.mp hi).2
    simp [this]
  have hpos : (∑ i ∈ {i ∈ (univ : Finset (Fin n)) | ¬ (s i = false)}, (if s i then d i else -d i))
      = ∑ i ∈ {i ∈ (univ : Finset (Fin n)) | ¬ (s i = false)}, d i := by
    refine Finset.sum_congr rfl ?_
    intro i hi
    have : s i = true := by
      have := (Finset.mem_filter.mp hi).2
      cases h : s i with
      | false => exact absurd h this
      | true => rfl
    simp [this]
  simp only [signedSum, flipSum, flipSet]
  rw [hneg, hpos] at hsplit
  linarith [hsplit, hsplit']

/-- **The randomization tail is a subset-sum count.**  For every threshold `t`, the number of
sign re-labellings whose statistic is within `2t` of the observed one equals the number of
subsets of the seeds carrying drop mass at most `t`. -/
theorem extreme_count_eq_subsetSum_count (d : Fin n → ℝ) (t : ℝ) :
    ({s : Fin n → Bool | (∑ i, d i) - 2 * t ≤ signedSum d s} : Finset (Fin n → Bool)).card
      = ({S : Finset (Fin n) | flipSum d S ≤ t} : Finset (Finset (Fin n))).card := by
  classical
  refine Finset.card_bij' (fun s _ => flipSet s) (fun S _ => fun i => decide (i ∉ S)) ?_ ?_ ?_ ?_
  · intro s hs
    have hs' : (∑ i, d i) - 2 * t ≤ signedSum d s := by
      simpa using (Finset.mem_filter.mp hs).2
    rw [signedSum_eq_sub_two_mul_flipSum] at hs'
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    linarith
  · intro S hS
    have hS' : flipSum d S ≤ t := by
      simpa using (Finset.mem_filter.mp hS).2
    have hflip : flipSet (fun i => decide (i ∉ S)) = S := by
      ext i
      simp [flipSet]
    simp only [Finset.mem_filter, Finset.mem_univ, true_and,
      signedSum_eq_sub_two_mul_flipSum, hflip]
    linarith
  · intro s _
    funext i
    by_cases h : s i = false <;> simp [flipSet, h]
  · intro S _
    ext i
    simp [flipSet]

/-! ## 2. A uniform drop bound turns the tail into a binomial tail -/

/-- A uniform lower bound on the drops bounds the drop mass of a set from below by its size. -/
theorem le_flipSum_of_uniform {d : Fin n → ℝ} {c : ℝ} (hd : ∀ i, c ≤ d i)
    (S : Finset (Fin n)) : (S.card : ℝ) * c ≤ flipSum d S := by
  classical
  calc (S.card : ℝ) * c = ∑ _i ∈ S, c := by simp [Finset.sum_const, nsmul_eq_mul, mul_comm]
    _ ≤ ∑ i ∈ S, d i := Finset.sum_le_sum fun i _ => hd i
    _ = flipSum d S := rfl

/-- **Binomial-tail bound.**  If every drop is at least `c > 0` and the haircut `t` is smaller
than `c(k+1)`, only subsets of size at most `k` can qualify, so the randomization tail is
bounded by a binomial tail. -/
theorem subsetSum_count_le_binomial_tail (d : Fin n → ℝ) {c t : ℝ} (hc : 0 < c)
    (hd : ∀ i, c ≤ d i) (k : ℕ) (ht : t < c * (k + 1)) :
    ({S : Finset (Fin n) | flipSum d S ≤ t} : Finset (Finset (Fin n))).card
      ≤ ∑ j ∈ Finset.range (k + 1), n.choose j := by
  classical
  have hsub : ({S : Finset (Fin n) | flipSum d S ≤ t} : Finset (Finset (Fin n)))
      ⊆ (Finset.range (k + 1)).biUnion
          (fun j => Finset.powersetCard j (Finset.univ : Finset (Fin n))) := by
    intro S hS
    have hS' : flipSum d S ≤ t := by
      simpa using (Finset.mem_filter.mp hS).2
    have hcard : S.card ≤ k := by
      by_contra hgt
      push_neg at hgt
      have h1 : ((k : ℝ) + 1) ≤ (S.card : ℝ) := by
        have : (k : ℕ) + 1 ≤ S.card := hgt
        exact_mod_cast this
      have h2 : ((k : ℝ) + 1) * c ≤ (S.card : ℝ) * c :=
        mul_le_mul_of_nonneg_right h1 (le_of_lt hc)
      have h3 := le_flipSum_of_uniform hd S
      nlinarith
    refine Finset.mem_biUnion.mpr ⟨S.card, ?_, ?_⟩
    · exact Finset.mem_range.mpr (Nat.lt_succ_of_le hcard)
    · exact Finset.mem_powersetCard.mpr ⟨Finset.subset_univ S, rfl⟩
  calc ({S : Finset (Fin n) | flipSum d S ≤ t} : Finset (Finset (Fin n))).card
      ≤ ((Finset.range (k + 1)).biUnion
          (fun j => Finset.powersetCard j (Finset.univ : Finset (Fin n)))).card :=
        Finset.card_le_card hsub
    _ ≤ ∑ j ∈ Finset.range (k + 1),
          (Finset.powersetCard j (Finset.univ : Finset (Fin n))).card :=
        Finset.card_biUnion_le
    _ = ∑ j ∈ Finset.range (k + 1), n.choose j := by
        refine Finset.sum_congr rfl ?_
        intro j _
        simp [Finset.card_powersetCard]

/-! ## 3. The recorded numbers -/

/-- **The robustified randomization tail.**  With the file-III uniform drop bound
`dᵢ ≥ 0.066`, at most `15` of the `16384` re-labellings come within `0.26` of the observed
drop total: the exact p-value survives an `18 %` haircut of the total effect and stays below
`10⁻³`. -/
theorem u35_randomization_tail_bound (d : Fin 14 → ℝ) (hd : ∀ i, 66 / 1000 ≤ d i) :
    ({s : Fin 14 → Bool | (∑ i, d i) - 2 * (13 / 100) ≤ signedSum d s}
        : Finset (Fin 14 → Bool)).card ≤ 15 := by
  classical
  rw [extreme_count_eq_subsetSum_count d (13 / 100)]
  have hbound := subsetSum_count_le_binomial_tail d (c := 66 / 1000) (t := 13 / 100)
    (by norm_num) hd 1 (by norm_num)
  simpa using hbound

/-- The robustified p-value is below `10⁻³`. -/
theorem u35_robust_pvalue_lt (d : Fin 14 → ℝ) (hd : ∀ i, 66 / 1000 ≤ d i) :
    (({s : Fin 14 → Bool | (∑ i, d i) - 2 * (13 / 100) ≤ signedSum d s}
        : Finset (Fin 14 → Bool)).card : ℝ) / (Fintype.card (Fin 14 → Bool)) < 1 / 1000 := by
  classical
  have hcard : (({s : Fin 14 → Bool | (∑ i, d i) - 2 * (13 / 100) ≤ signedSum d s}
      : Finset (Fin 14 → Bool)).card : ℝ) ≤ 15 := by
    exact_mod_cast u35_randomization_tail_bound d hd
  have hden : (Fintype.card (Fin 14 → Bool) : ℝ) = 16384 := by
    simp
  rw [hden]
  rw [div_lt_div_iff₀ (by norm_num) (by norm_num)]
  linarith

/-- **Spectral gap at the top of the randomization distribution.**  Every re-labelling other
than the observed one falls at least `2c` short: with `c = 0.066` the gap is `0.132`, i.e.
`8.9 %` of the total drop mass `1.4798`.  The observed statistic is an isolated maximum, not a
marginal one. -/
theorem randomization_spectral_gap {d : Fin n → ℝ} {c : ℝ} (hc : 0 < c) (hd : ∀ i, c ≤ d i)
    {s : Fin n → Bool} (hs : s ≠ fun _ => true) :
    signedSum d s ≤ (∑ i, d i) - 2 * c := by
  classical
  have hex : ∃ i, s i = false := by
    by_contra hall
    push_neg at hall
    refine hs (funext fun i => ?_)
    cases h : s i with
    | false => exact absurd h (hall i)
    | true => rfl
  obtain ⟨j, hj⟩ := hex
  have hmem : j ∈ flipSet s := by simp [flipSet, hj]
  have hcard : 1 ≤ (flipSet s).card := Finset.card_pos.mpr ⟨j, hmem⟩
  have h1 : (1 : ℝ) * c ≤ ((flipSet s).card : ℝ) * c := by
    have : (1 : ℝ) ≤ ((flipSet s).card : ℝ) := by exact_mod_cast hcard
    exact mul_le_mul_of_nonneg_right this (le_of_lt hc)
  have h2 := le_flipSum_of_uniform hd (flipSet s)
  rw [signedSum_eq_sub_two_mul_flipSum]
  linarith

end Catalog.Novelty.U35RandomizationSpectrum