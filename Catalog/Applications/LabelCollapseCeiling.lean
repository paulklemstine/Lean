/-
# The collapse ceiling: how much a label merge can possibly destroy

## Context (FACT round-29 #2, cycle 2)

`Applications.JointLabelReconciliation` shows that a collision-producing label
encoding can only *lose* entropy and mutual information.  That is a one-sided
bound and, by itself, it cannot adjudicate *how large* a discrepancy may
legitimately be blamed on label collisions.

This file supplies the missing other side: a **collapse ceiling**.  If every
fiber of the labelling contains at most `k` atoms, then

* the label entropy destroyed is at most `log₂ k` (`H_sub_H_push_le_logb`), and
* the mutual information destroyed is at most `log₂ k`
  (`MI_drop_le_logb`).

In particular a *`2`-to-`1`* merge can destroy **at most one bit**
(`two_to_one_costs_at_most_one_bit`), whatever the population.  This turns the
programme lesson into a falsifiable audit test: a reported pair of readings on
one population whose mutual informations differ by more than `log₂ k` cannot be
explained by a `k`-bounded label merge alone, and some *other* difference
between the two pipelines must be found.

The bound is achieved (not merely an estimate): the uniform distribution on a
`k`-element fiber loses exactly `log₂ k` (`D_uniform_fiber`), so no smaller
ceiling is available.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation

namespace LabelCollapseCeiling

open Finset LabelEntropy JointLabelReconciliation

variable {α β α' : Type*} [Fintype α] [Fintype β] [Fintype α'] [DecidableEq α']

/-- **Maximum-entropy bound in deficit form.**  Merging a block of `n` atoms
carrying total mass `S` destroys at most `S · log₂ n` bits. -/
theorem D_le_mass_mul_logb_card {ι : Type*} {s : Finset ι} {w : ι → ℝ}
    (hw : ∀ i ∈ s, 0 ≤ w i) :
    D s w ≤ (∑ i ∈ s, w i) * Real.logb 2 s.card := by
  classical
  rcases Finset.eq_empty_or_nonempty s with rfl | hne
  · simp [D, H]
  have hn : 0 < (s.card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr hne
  set S := ∑ i ∈ s, w i with hS
  have hSnn : 0 ≤ S := Finset.sum_nonneg hw
  rcases eq_or_lt_of_le hSnn with hS0 | hSpos
  · -- no mass: nothing to lose
    have hall : ∀ i ∈ s, w i = 0 := (Finset.sum_eq_zero_iff_of_nonneg hw).mp (hS ▸ hS0.symm)
    have h1 : D s w = 0 := by
      have h2 : H s w = 0 := Finset.sum_eq_zero fun i hi => by rw [hall i hi, nlp_zero]
      have h3 : ∑ i ∈ s, w i = 0 := Finset.sum_eq_zero hall
      simp [D, h2, h3]
    rw [h1, ← hS0]
    simp
  · -- compare against the uniform weight on the block
    set b : ι → ℝ := fun _ => S / s.card with hb
    have hbnn : ∀ i ∈ s, 0 ≤ b i := fun i _ => by positivity
    have hbsum : ∑ i ∈ s, b i = S := by
      rw [hb, Finset.sum_const, nsmul_eq_mul]
      field_simp
    have hac : ∀ i ∈ s, b i = 0 → w i = 0 := by
      intro i _ hbi
      rw [hb] at hbi
      simp only [div_eq_zero_iff] at hbi
      rcases hbi with h | h
      · exact absurd h (ne_of_gt hSpos)
      · exact absurd h (ne_of_gt hn)
    have hkl := kl_nonneg hw hbnn hac (le_of_eq hbsum)
    have hbval : ∀ i ∈ s, Real.logb 2 (b i) = Real.logb 2 S - Real.logb 2 s.card := by
      intro i _
      rw [hb, Real.logb_div (ne_of_gt hSpos) (ne_of_gt hn)]
    have hkl' : 0 ≤ ∑ i ∈ s, w i * (Real.logb 2 (w i) - (Real.logb 2 S - Real.logb 2 s.card)) := by
      refine le_trans hkl (le_of_eq (Finset.sum_congr rfl fun i hi => by rw [hbval i hi]))
    rw [D_eq, ← hS]
    have hexpand : ∑ i ∈ s, w i * (Real.logb 2 (w i) - (Real.logb 2 S - Real.logb 2 s.card))
        = (∑ i ∈ s, w i * Real.logb 2 s.card)
          - ∑ i ∈ s, w i * (Real.logb 2 S - Real.logb 2 (w i)) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [hexpand, ← Finset.sum_mul, ← hS] at hkl'
    linarith

/-- The bound of `D_le_mass_mul_logb_card` is attained: a uniform block of `n`
atoms of total mass `1` loses exactly `log₂ n`. -/
theorem D_uniform_fiber {ι : Type*} {s : Finset ι} (hne : s.Nonempty) :
    D s (fun _ => (1 : ℝ) / s.card) = Real.logb 2 s.card := by
  have hn : 0 < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hne
  have hsum : ∑ _i ∈ s, (1 : ℝ) / s.card = 1 := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  have hlog : Real.logb 2 ((1 : ℝ) / s.card) = - Real.logb 2 s.card := by
    rw [one_div, Real.logb_inv]
  have hterm : ∀ i ∈ s, (1 : ℝ) / s.card *
      (Real.logb 2 (∑ _j ∈ s, (1:ℝ) / s.card) - Real.logb 2 ((1:ℝ) / s.card))
      = (1 / s.card) * Real.logb 2 s.card := by
    intro i _
    rw [hsum, hlog]
    simp
  rw [D_eq, Finset.sum_congr rfl hterm, ← Finset.sum_mul, hsum, one_mul]

/-! ## The ceiling for a bounded-fiber labelling -/

/-- Total mass is preserved by a labelling. -/
lemma sum_push (f : α → α') (p : α → ℝ) :
    ∑ u : α', ∑ x ∈ fib f u, p x = ∑ x : α, p x := by
  simpa [fib] using Finset.sum_fiberwise (univ : Finset α) f p

/-- **Collapse ceiling for entropy.**  If no label collects more than `k`
atoms, a labelling of a probability weight destroys at most `log₂ k` bits. -/
theorem H_sub_H_push_le_logb {f : α → α'} {p : α → ℝ} {k : ℕ}
    (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x : α, p x = 1) (hk : 1 ≤ k)
    (hfib : ∀ u : α', (fib f u).card ≤ k) :
    H univ p - H univ (push f p) ≤ Real.logb 2 k := by
  have hkpos : (0:ℝ) < k := by exact_mod_cast hk
  have hlogk : 0 ≤ Real.logb 2 k := by
    have : Real.logb 2 1 ≤ Real.logb 2 k :=
      Real.logb_le_logb_of_le (by norm_num) (by norm_num) (by exact_mod_cast hk)
    simpa using this
  have hstep : ∀ u : α', D (fib f u) p ≤ (∑ x ∈ fib f u, p x) * Real.logb 2 k := by
    intro u
    refine le_trans (D_le_mass_mul_logb_card (fun x _ => hp x)) ?_
    have hmass : 0 ≤ ∑ x ∈ fib f u, p x := Finset.sum_nonneg fun x _ => hp x
    refine mul_le_mul_of_nonneg_left ?_ hmass
    rcases Nat.eq_zero_or_pos (fib f u).card with hc | hc
    · rw [hc]
      simpa using hlogk
    · exact Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast hc)
        (by exact_mod_cast hfib u)
  calc H univ p - H univ (push f p) = ∑ u : α', D (fib f u) p := H_sub_H_push f p
    _ ≤ ∑ u : α', (∑ x ∈ fib f u, p x) * Real.logb 2 k := Finset.sum_le_sum fun u _ => hstep u
    _ = (∑ u : α', ∑ x ∈ fib f u, p x) * Real.logb 2 k := by rw [Finset.sum_mul]
    _ = Real.logb 2 k := by rw [sum_push, hp1, one_mul]

/-- **The sharpest audit test: the information drop never exceeds the label
entropy drop.**  Whatever the coarsening, the mutual information it destroys is
bounded by the label entropy it destroys.  A reported pair (`entropy lost`,
`information lost`) with `information lost > entropy lost` therefore cannot come
from label merging alone. -/
theorem MI_drop_le_H_drop {f : α → α'} {p : α × β → ℝ} (hp : ∀ q, 0 ≤ p q) :
    MI p - MI (pushFst f p)
      ≤ H univ (marg1 p) - H univ (push f (marg1 p)) := by
  have hjoint : 0 ≤ H univ p - H univ (pushFst f p) := by
    rw [H_joint_sub]
    refine Finset.sum_nonneg fun u _ => Finset.sum_nonneg fun y _ => ?_
    exact D_nonneg fun x _ => hp (x, y)
  have h1 : H univ (marg1 (pushFst f p)) = H univ (push f (marg1 p)) := by
    rw [marg1_pushFst]
  have h2 : H univ (marg2 (pushFst f p)) = H univ (marg2 p) := by rw [marg2_pushFst]
  simp only [MI, h1, h2]
  linarith

/-- **Collapse ceiling for mutual information.**  A `k`-bounded label merge can
destroy at most `log₂ k` bits of mutual information — no matter how large the
underlying channel is. -/
theorem MI_drop_le_logb {f : α → α'} {p : α × β → ℝ} {k : ℕ}
    (hp : ∀ q, 0 ≤ p q) (hp1 : ∑ q : α × β, p q = 1) (hk : 1 ≤ k)
    (hfib : ∀ u : α', (fib f u).card ≤ k) :
    MI p - MI (pushFst f p) ≤ Real.logb 2 k := by
  have hm1nn : ∀ x : α, 0 ≤ marg1 p x := fun x => Finset.sum_nonneg fun y _ => hp (x, y)
  have hm1sum : ∑ x : α, marg1 p x = 1 := by
    rw [← hp1, Fintype.sum_prod_type]
    rfl
  have hmarg := H_sub_H_push_le_logb (f := f) (p := marg1 p) hm1nn hm1sum hk hfib
  linarith [MI_drop_le_H_drop (f := f) (p := p) hp]

/-- **A `2`-to-`1` merge costs at most one bit.**  This is the sharp audit test:
any reported drop of more than one bit on a population whose labels are merged
at most pairwise must have another cause. -/
theorem two_to_one_costs_at_most_one_bit {f : α → α'} {p : α × β → ℝ}
    (hp : ∀ q, 0 ≤ p q) (hp1 : ∑ q : α × β, p q = 1)
    (hfib : ∀ u : α', (fib f u).card ≤ 2) :
    MI p - MI (pushFst f p) ≤ 1 := by
  have := MI_drop_le_logb (f := f) (p := p) (k := 2) hp hp1 (by norm_num) hfib
  have h2 : Real.logb 2 ((2:ℕ) : ℝ) = 1 := by
    norm_num [Real.logb_self_eq_one]
  linarith [h2 ▸ this]

/-- Sandwich: the entropy destroyed by a `k`-bounded labelling of a probability
weight lies in `[0, log₂ k]`. -/
theorem collapse_sandwich {f : α → α'} {p : α → ℝ} {k : ℕ}
    (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x : α, p x = 1) (hk : 1 ≤ k)
    (hfib : ∀ u : α', (fib f u).card ≤ k) :
    0 ≤ H univ p - H univ (push f p) ∧
      H univ p - H univ (push f p) ≤ Real.logb 2 k := by
  refine ⟨?_, H_sub_H_push_le_logb hp hp1 hk hfib⟩
  rw [H_sub_H_push]
  exact Finset.sum_nonneg fun u _ => D_nonneg fun x _ => hp x

/-- **Audit contrapositive.**  A drop of more than one bit *proves* that some
label collected at least three distinct classes; pairwise merging cannot
account for it. -/
theorem drop_gt_one_forces_triple_merge {f : α → α'} {p : α × β → ℝ}
    (hp : ∀ q, 0 ≤ p q) (hp1 : ∑ q : α × β, p q = 1)
    (hdrop : 1 < MI p - MI (pushFst f p)) :
    ∃ u : α', 3 ≤ (fib f u).card := by
  by_contra hcon
  push_neg at hcon
  have hfib : ∀ u : α', (fib f u).card ≤ 2 := fun u => by
    have := hcon u
    omega
  have := two_to_one_costs_at_most_one_bit hp hp1 hfib
  linarith

/-! ## The audited `4 × 9` population, quantitatively -/

/-- Under the narrow `·3` frame no label of the audited population collects
more than three code pairs. -/
theorem audited_narrow_fiber_le_three :
    ∀ u : Fin 40, (fib encNarrow u).card ≤ 3 := by decide

/-- Hence the narrow frame of the retracted rebuild can destroy at most
`log₂ 3 ≈ 1.585` bits of mutual information on that population — a hard,
checkable ceiling on how much of a discrepancy the collision artifact can
explain. -/
theorem audited_narrow_MI_drop_le {β : Type*} [Fintype β] {p : Pop × β → ℝ}
    (hp : ∀ q, 0 ≤ p q) (hp1 : ∑ q : Pop × β, p q = 1) :
    MI p - MI (pushFst encNarrow p) ≤ Real.logb 2 3 := by
  have h := MI_drop_le_logb (f := encNarrow) (p := p) (k := 3) hp hp1 (by norm_num)
    audited_narrow_fiber_le_three
  simpa using h

/-- The same population under a width-valid frame loses nothing at all. -/
theorem audited_wide_MI_eq {β : Type*} [Fintype β] (p : Pop × β → ℝ) :
    MI (pushFst encWide p) = MI p :=
  MI_pushFst_eq_of_injective encWide_injective p

end LabelCollapseCeiling