import Mathlib

/-!
# Total variation toolkit for de-quantization lower bounds

A minimal, self-contained total-variation calculus for finitely supported
probability distributions on a `Finset ℕ` of outcomes, together with the
combinatorial lower bound that drives every "no `r`-free classical sampler"
statement:

* `Dequant.DistOn` — a probability vector on a finite outcome set `s`.
* `Dequant.tv` — total variation distance, `½ ∑ |p - q|`.
* `Dequant.tv_ge_event` — the event bound `P(A) - Q(A) ≤ TV(P, Q)`.
* `Dequant.tv_triangle`, `Dequant.tv_comm`, `Dequant.tv_nonneg`, `Dequant.tv_le_one`.
* `Dequant.exists_far_candidate` — **the pigeonhole seal**: if `k` candidate
  distributions each put mass `≥ c` on pairwise disjoint events, then *every*
  single distribution `D` (in particular every candidate-oblivious classical
  sampler) is at total variation `≥ c - 1/k` from one of them.
-/

namespace Dequant

open Finset

/-- A probability distribution supported on the finite outcome set `s`. -/
structure DistOn (s : Finset ℕ) where
  /-- The probability mass function. -/
  p : ℕ → ℝ
  /-- Masses are nonnegative on the outcome set. -/
  nonneg : ∀ y ∈ s, 0 ≤ p y
  /-- Masses sum to one. -/
  total : ∑ y ∈ s, p y = 1

/-- Total variation distance between two distributions on the same outcome set. -/
noncomputable def tv {s : Finset ℕ} (D E : DistOn s) : ℝ :=
  (∑ y ∈ s, |D.p y - E.p y|) / 2

theorem tv_nonneg {s : Finset ℕ} (D E : DistOn s) : 0 ≤ tv D E := by
  unfold tv
  positivity

theorem tv_comm {s : Finset ℕ} (D E : DistOn s) : tv D E = tv E D := by
  unfold tv
  congr 1
  exact Finset.sum_congr rfl fun y _ => abs_sub_comm _ _

theorem tv_self {s : Finset ℕ} (D : DistOn s) : tv D D = 0 := by
  simp [tv]

theorem tv_triangle {s : Finset ℕ} (D E F : DistOn s) : tv D F ≤ tv D E + tv E F := by
  unfold tv
  rw [← add_div, div_le_div_iff_of_pos_right (by norm_num), ← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun y _ => ?_
  calc |D.p y - F.p y| = |(D.p y - E.p y) + (E.p y - F.p y)| := by ring_nf
  _ ≤ |D.p y - E.p y| + |E.p y - F.p y| := abs_add_le _ _

/-- **Event bound**: total variation dominates the discrepancy on any event. -/
theorem tv_ge_event {s : Finset ℕ} (D E : DistOn s) {A : Finset ℕ} (hA : A ⊆ s) :
    (∑ y ∈ A, D.p y) - (∑ y ∈ A, E.p y) ≤ tv D E := by
  set f : ℕ → ℝ := fun y => D.p y - E.p y with hf
  have hzero : ∑ y ∈ s, f y = 0 := by
    simp only [hf, Finset.sum_sub_distrib, D.total, E.total, sub_self]
  have hsplit : ∑ y ∈ s \ A, f y + ∑ y ∈ A, f y = ∑ y ∈ s, f y := Finset.sum_sdiff hA
  have hsplit' : ∑ y ∈ s \ A, |f y| + ∑ y ∈ A, |f y| = ∑ y ∈ s, |f y| :=
    Finset.sum_sdiff hA
  have h1 : ∑ y ∈ A, f y ≤ ∑ y ∈ A, |f y| :=
    Finset.sum_le_sum fun y _ => le_abs_self _
  have h2 : -(∑ y ∈ s \ A, f y) ≤ ∑ y ∈ s \ A, |f y| := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_le_sum fun y _ => neg_le_abs _
  have hAf : ∑ y ∈ s \ A, f y = -(∑ y ∈ A, f y) := by
    have := hsplit
    rw [hzero] at this
    linarith
  have key : 2 * (∑ y ∈ A, f y) ≤ ∑ y ∈ s, |f y| := by
    rw [← hsplit']
    rw [hAf] at h2
    simp only [neg_neg] at h2
    linarith
  have hsum : (∑ y ∈ A, D.p y) - (∑ y ∈ A, E.p y) = ∑ y ∈ A, f y := by
    simp [hf, Finset.sum_sub_distrib]
  rw [hsum, tv, le_div_iff₀ (by norm_num : (0:ℝ) < 2)]
  linarith

theorem tv_le_one {s : Finset ℕ} (D E : DistOn s) : tv D E ≤ 1 := by
  have h : ∑ y ∈ s, |D.p y - E.p y| ≤ ∑ y ∈ s, (D.p y + E.p y) := by
    refine Finset.sum_le_sum fun y hy => ?_
    have h1 := D.nonneg y hy
    have h2 := E.nonneg y hy
    rw [abs_sub_le_iff]
    constructor <;> linarith
  rw [Finset.sum_add_distrib, D.total, E.total] at h
  rw [tv, div_le_one (by norm_num)]
  linarith

/-- **The pigeonhole seal.**  Suppose `k ≥ 1` candidate distributions `P i` each put
mass at least `c` on events `A i` that are pairwise disjoint.  Then *any* single
distribution `D` — in particular any classical sampler that does not depend on the
hidden parameter `i` — is at total variation at least `c - 1/k` from one of the
candidates.  Averaging cannot beat the union bound: mass `1` must be spread over `k`
disjoint targets. -/
theorem exists_far_candidate {s : Finset ℕ} {k : ℕ} (hk : 0 < k)
    (D : DistOn s) (P : Fin k → DistOn s) (A : Fin k → Finset ℕ)
    (hsub : ∀ i, A i ⊆ s)
    (hdisj : ∀ i j, i ≠ j → Disjoint (A i) (A j))
    (c : ℝ) (hmass : ∀ i, c ≤ ∑ y ∈ A i, (P i).p y) :
    ∃ i, c - 1 / k ≤ tv D (P i) := by
  by_contra hcon
  push_neg at hcon
  -- each candidate event carries more than `1/k` of `D`'s mass
  have hbig : ∀ i : Fin k, 1 / (k : ℝ) < ∑ y ∈ A i, D.p y := by
    intro i
    have h1 : (∑ y ∈ A i, (P i).p y) - (∑ y ∈ A i, D.p y) ≤ tv (P i) D :=
      tv_ge_event (P i) D (hsub i)
    have h2 : tv (P i) D = tv D (P i) := tv_comm _ _
    have h3 := hcon i
    have h4 := hmass i
    linarith [h1, h4, h3, h2 ▸ h1]
  -- but the disjoint events cannot carry more than the total mass `1`
  have hpd : Set.PairwiseDisjoint (↑(Finset.univ : Finset (Fin k))) A := by
    intro i _ j _ hij
    exact hdisj i j hij
  have hunion : ∑ i : Fin k, ∑ y ∈ A i, D.p y = ∑ y ∈ Finset.univ.biUnion A, D.p y :=
    (Finset.sum_biUnion hpd).symm
  have hsubU : Finset.univ.biUnion A ⊆ s := by
    intro y hy
    obtain ⟨i, -, hi⟩ := Finset.mem_biUnion.mp hy
    exact hsub i hi
  have hle : ∑ y ∈ Finset.univ.biUnion A, D.p y ≤ 1 := by
    rw [← D.total]
    exact Finset.sum_le_sum_of_subset_of_nonneg hsubU fun y hy _ => D.nonneg y hy
  have hgt : (1 : ℝ) < ∑ i : Fin k, ∑ y ∈ A i, D.p y := by
    have : ∑ i : Fin k, (1 / (k:ℝ)) < ∑ i : Fin k, ∑ y ∈ A i, D.p y := by
      refine Finset.sum_lt_sum_of_nonempty ?_ fun i _ => hbig i
      exact Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp hk)
    simpa [Finset.sum_const, Finset.card_univ, mul_one_div,
      mul_inv_cancel₀ (show (k:ℝ) ≠ 0 by positivity)] using this
  rw [hunion] at hgt
  linarith

end Dequant