/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsRigidity
import Applications.InvisibleWeightsL1

/-!
# Improving the lower bound: `ℓ¹ ≥ K + 2`, and `K + 3` for odd windows

The catalog bound for an integral vector invisible to the power-sum window `k < K` is
`ℓ¹ ≥ K + 1` (`l1_ge_of_invisible_int`), obtained by counting nodes.  This file shows the
bound is *never* attained for `K ≥ 2`, using the rigidity theorem of
`Applications/InvisibleWeightsRigidity.lean`.

The mechanism: equality `ℓ¹ = K + 1` would force the vector to occupy exactly `K + 1` nodes
with every entry of absolute value `1`.  But at the sharp support bound the entries are the
divided-difference weights of the node set, so `|e i| · ∏_{j ≠ i} |i - j|` is the same number
for every node `i`; with all `|e i| = 1` this makes all the node products equal — impossible,
because the product at the smallest node strictly dominates the product at the second
smallest whenever there are at least three nodes.

## Main results

* `prod_dist_min_lt` — the geometric obstruction: in any node set with `≥ 3` elements the
  products `∏_{j ≠ i} |i - j|` are not all equal.
* `l1_ge_window_add_two` — **`ℓ¹ ≥ K + 2` for every `K ≥ 2`.**
* `l1_ge_window_add_three_of_odd` — **`ℓ¹ ≥ K + 3` for odd `K ≥ 3`**, combining the previous
  bound with the evenness of the norm.
* `l1_sharp_at_three` — at `K = 3` the improved bound `ℓ¹ ≥ 6` is *attained* by the witness
  `(-1, 2, 0, -2, 1)`, so the result is sharp at the first window where it bites.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  The node-counting bound `K + 1` should never be sharp beyond the
trivial window `K = 1`, because attaining it demands a maximally rigid configuration — unit
weights on a minimal node set — and rigidity fixes those weights to be reciprocals of node
products, which cannot all be units.

EXPERIMENT (Experimenter).  Confirmed and formalised.  The obstruction is one strict
inequality: with `i₀ < i₁` the two smallest nodes, every remaining node `j` satisfies
`|i₀ - j| > |i₁ - j| > 0`, so `∏_{j ≠ i₀} |i₀ - j| > ∏_{j ≠ i₁} |i₁ - j|`.  Numerically, at
`S = {0,1,3,4}` the four products are `12, 6, 6, 12` — unequal, as predicted, and indeed the
corresponding invisible vector `(-1, 2, -2, 1)` has entries `12/12, 12/6, 12/6, 12/12` of
absolute values `1, 2, 2, 1`, giving `ℓ¹ = 6 = K + 3` rather than `K + 1 = 4`.

ANALYSIS (Analyst).  Combined with the parity refinement, the lower bound is now
`K + 2` for even `K ≥ 2` and `K + 3` for odd `K ≥ 3`, against the exhaustive-search values
`2, 4, 6, 8, ≤14` for `K = 1,…,5`: the bound is *sharp* at `K = 1, 2, 3` and off by `2` at
`K = 4`.  The gap to the conjectured `2K` is now a genuinely quantitative question about how
unequal the node products must be, not a structural one.

CRITIQUE (Critic).  The improvement is guarded by `2 ≤ K`: at `K = 1` the bound `K + 1 = 2`
*is* attained (by `(1, -1)`), and the proof correctly fails there, since a two-node set has no
third node to make the products unequal.  The statement is about integral vectors only —
over `ℚ` no lower bound on `ℓ¹` can hold at all, since invisible vectors scale.
-/

open Finset

namespace InvisibleWeights

/-- **The geometric obstruction.**  In a node set with at least three elements the products
`∏_{j ≠ i} |i - j|` are not all equal: the product at the smallest node strictly exceeds the
product at the second smallest. -/
theorem prod_dist_min_lt {S : Finset ℕ} (hcard : 3 ≤ S.card) :
    ∃ i₀ ∈ S, ∃ i₁ ∈ S,
      ∏ j ∈ S.erase i₁, |(i₁ : ℚ) - (j : ℚ)| < ∏ j ∈ S.erase i₀, |(i₀ : ℚ) - (j : ℚ)| := by
  classical
  have hSne : S.Nonempty := Finset.card_pos.mp (by omega)
  set i₀ := S.min' hSne with hi₀def
  have hi₀ : i₀ ∈ S := S.min'_mem hSne
  have hi₀le : ∀ j ∈ S, i₀ ≤ j := fun j hj => S.min'_le j hj
  have hS'ne : (S.erase i₀).Nonempty := by
    rw [← Finset.card_pos, Finset.card_erase_of_mem hi₀]
    omega
  set i₁ := (S.erase i₀).min' hS'ne with hi₁def
  have hi₁' : i₁ ∈ S.erase i₀ := (S.erase i₀).min'_mem hS'ne
  have hi₁ : i₁ ∈ S := Finset.mem_of_mem_erase hi₁'
  have hi₁ne : i₁ ≠ i₀ := (Finset.mem_erase.mp hi₁').1
  have hi₀i₁ : i₀ < i₁ := lt_of_le_of_ne (hi₀le i₁ hi₁) (Ne.symm hi₁ne)
  have hi₁le : ∀ j ∈ S.erase i₀, i₁ ≤ j := fun j hj => (S.erase i₀).min'_le j hj
  set T := (S.erase i₀).erase i₁ with hT
  have hTne : T.Nonempty := by
    rw [← Finset.card_pos, hT, Finset.card_erase_of_mem hi₁', Finset.card_erase_of_mem hi₀]
    omega
  have hTmem : ∀ j ∈ T, i₁ < j := by
    intro j hj
    have hj1 : j ≠ i₁ := (Finset.mem_erase.mp hj).1
    have hj2 : j ∈ S.erase i₀ := Finset.mem_of_mem_erase hj
    exact lt_of_le_of_ne (hi₁le j hj2) (Ne.symm hj1)
  have hA : S.erase i₀ = insert i₁ T := (Finset.insert_erase hi₁').symm
  have hB : S.erase i₁ = insert i₀ T := by
    have hi₀' : i₀ ∈ S.erase i₁ := Finset.mem_erase.mpr ⟨Ne.symm (by omega), hi₀⟩
    rw [hT, Finset.erase_right_comm]
    exact (Finset.insert_erase hi₀').symm
  have hi₁T : i₁ ∉ T := Finset.notMem_erase _ _
  have hi₀T : i₀ ∉ T := fun hc => absurd (hTmem i₀ hc) (by omega)
  refine ⟨i₀, hi₀, i₁, hi₁, ?_⟩
  rw [hA, hB, Finset.prod_insert hi₀T, Finset.prod_insert hi₁T]
  have hkey : ∏ j ∈ T, |(i₁ : ℚ) - (j : ℚ)| < ∏ j ∈ T, |(i₀ : ℚ) - (j : ℚ)| := by
    refine Finset.prod_lt_prod_of_nonempty (fun j hj => ?_) (fun j hj => ?_) hTne
    · have h1 : (i₁ : ℚ) < (j : ℚ) := by exact_mod_cast hTmem j hj
      rw [abs_sub_comm, abs_of_pos (by linarith)]
      linarith
    · have h1 : (i₁ : ℚ) < (j : ℚ) := by exact_mod_cast hTmem j hj
      have h0 : (i₀ : ℚ) < (i₁ : ℚ) := by exact_mod_cast hi₀i₁
      rw [abs_sub_comm, abs_of_pos (by linarith), abs_sub_comm ((i₀ : ℚ)),
        abs_of_pos (by linarith)]
      linarith
  have hpos : (0 : ℚ) < |(i₀ : ℚ) - (i₁ : ℚ)| := by
    have h0 : (i₀ : ℚ) < (i₁ : ℚ) := by exact_mod_cast hi₀i₁
    rw [abs_of_neg (by linarith)]
    linarith
  rw [abs_sub_comm ((i₁ : ℚ))]
  exact mul_lt_mul_of_pos_left hkey hpos

/-- **The node-counting bound is never sharp for `K ≥ 2`.** -/
theorem l1_ge_window_add_two {N K : ℕ} (hK : 2 ≤ K) {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ((K : ℤ) + 2) ≤ ∑ j ∈ range (N + 1), |e j| := by
  classical
  by_contra hcon
  push_neg at hcon
  have hge := l1_ge_of_invisible_int he hj₀ hne
  set f : ℕ → ℚ := fun j => (e j : ℚ) with hf
  have hfinv : Invisible N K f := by
    intro k hk
    have := congrArg (fun z : ℤ => (z : ℚ)) (he k hk)
    simpa [moment, hf] using this
  have hfne : f j₀ ≠ 0 := by
    simp only [hf, ne_eq, Rat.intCast_eq_zero_iff]
    exact hne
  set S := nodeSupport N f with hS
  have hcard := card_nodeSupport_ge hfinv hj₀ hfne
  have hsub : S ⊆ range (N + 1) := nodeSupport_subset N f
  have hzne : ∀ j ∈ S, e j ≠ 0 := by
    intro j hj hc
    exact (mem_nodeSupport.mp hj).2 (by simp [hf, hc])
  have hone : ∀ j ∈ S, (1 : ℤ) ≤ |e j| := fun j hj => Int.one_le_abs (hzne j hj)
  have hsplit : ∑ j ∈ S, |e j| ≤ ∑ j ∈ range (N + 1), |e j| :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun j _ _ => abs_nonneg _)
  have hcardle : ((S.card : ℤ)) ≤ ∑ j ∈ S, |e j| := by
    calc ((S.card : ℤ)) = ∑ j ∈ S, (1 : ℤ) := by simp
      _ ≤ ∑ j ∈ S, |e j| := Finset.sum_le_sum hone
  have hcardZ : ((K : ℤ) + 1) ≤ (S.card : ℤ) := by exact_mod_cast hcard
  -- everything is squeezed: the support has exactly `K + 1` nodes, all entries are units
  have hcardeq : S.card = K + 1 := by
    have : (S.card : ℤ) = (K : ℤ) + 1 := by omega
    exact_mod_cast this
  have hunits : ∀ j ∈ S, |e j| = 1 := by
    have hsum0 : ∑ j ∈ S, (|e j| - 1) = 0 := by
      have h1 : ∑ j ∈ S, (|e j| - 1) = (∑ j ∈ S, |e j|) - (S.card : ℤ) := by
        rw [Finset.sum_sub_distrib]
        simp
      omega
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun j hj => by
      have := hone j hj
      omega)).mp hsum0
    intro j hj
    have := this j hj
    omega
  -- rigidity: all node products are equal to the absolute value of the top moment
  have hvan : ∀ k < K, ∑ j ∈ S, f j * (j : ℚ) ^ k = 0 := by
    intro k hk
    rw [← moment_eq_sum_nodeSupport]
    exact hfinv k hk
  have hprod : ∀ i ∈ S, ∏ j ∈ S.erase i, |(i : ℚ) - (j : ℚ)|
      = |∑ j ∈ S, f j * (j : ℚ) ^ K| := by
    intro i hi
    have hrig := minimal_support_divided_difference hcardeq hvan hi
    have habs := congrArg (fun x : ℚ => |x|) hrig
    simp only [abs_mul, Finset.abs_prod] at habs
    have hfi : |f i| = 1 := by
      have : |e i| = 1 := hunits i hi
      simp only [hf]
      rw [← Int.cast_abs, this]
      norm_num
    rw [hfi, one_mul] at habs
    exact habs
  obtain ⟨i₀, hi₀, i₁, hi₁, hlt⟩ := prod_dist_min_lt (S := S) (by omega)
  rw [hprod i₀ hi₀, hprod i₁ hi₁] at hlt
  exact absurd hlt (lt_irrefl _)

/-- **Odd windows cost one more.**  For odd `K ≥ 3` the norm is even and at least `K + 2`,
hence at least `K + 3`. -/
theorem l1_ge_window_add_three_of_odd {N K : ℕ} (hK : 3 ≤ K) (hodd : ¬ Even K) {e : ℕ → ℤ}
    (he : Invisible N K e) {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ((K : ℤ) + 3) ≤ ∑ j ∈ range (N + 1), |e j| := by
  have h2 := l1_ge_window_add_two (by omega) he hj₀ hne
  obtain ⟨c, hc⟩ := l1_even_of_invisible_int (by omega) he
  have hmod : K % 2 = 1 := Nat.odd_iff.mp (Nat.not_even_iff_odd.mp hodd)
  have hKm : (K : ℤ) = 2 * (K / 2) + 1 := by exact_mod_cast (by omega : K = 2 * (K / 2) + 1)
  omega

/-- At `K = 3` the improved bound is attained: the witness `(-1, 2, 0, -2, 1)` is invisible to
the window `k < 3` and has `ℓ¹ = 6 = K + 3`. -/
theorem l1_sharp_at_three :
    Invisible 4 3 pteWitness ∧ pteWitness 0 ≠ 0 ∧ ∑ j ∈ range 5, |pteWitness j| = 6 := by
  refine ⟨pteWitness_invisible, ?_, pteWitness_l1⟩
  simp [pteWitness]

end InvisibleWeights