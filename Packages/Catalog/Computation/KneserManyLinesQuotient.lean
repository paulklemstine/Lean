/-
# What the conjectured bound *does* buy: surjectivity onto every quotient line

`Catalog/Computation/KneserManyLinesSharpness.lean` shows that the hypothesis
`∑ i (p - #(S i)) ≤ (k-2)(p-1)` is **not** enough to force
`Reach v S = 𝔽_p²`.  This file isolates what the hypothesis *does* give, for
every `k` and with no extra assumption on the sets:

`reach_meets_every_line` : under `∑ i (p - #(S i)) ≤ (k-2)(p-1)` the reach meets
every line parallel to `v i₀`, for every index `i₀`.  Equivalently, the image of
`Reach v S` in the quotient `𝔽_p² / ⟨v i₀⟩ ≅ 𝔽_p` is everything.

This is exactly iterated Cauchy–Davenport in the quotient line, and the numerics
are tight: the bound `(k-2)(p-1)` is *precisely* the largest deficiency for which
the Cauchy–Davenport estimate `∑_{i ≠ i₀} #(S i) + 1 - (k-1) ≥ p` still holds.

Two consequences are recorded:

* `reach_no_missing_line` : the complement of the reach contains no full line in
  any of the `k` directions.  In particular the harmonic counterexamples of
  `KneserManyLinesSharpness` must miss a *sparse* set of points — and indeed
  they miss exactly one.

Together with `reach_eq_univ_of_exists_full` (which lifts this surjectivity to
the whole plane when one of the sets is all of `𝔽_p`), this delimits precisely
how much of the conjecture survives.
-/
import Mathlib
import Computation.KneserManyLines

namespace KneserLines

open Finset

variable {p : ℕ}

/-- **Surjectivity onto every quotient line.**  Under the conjectured deficiency
bound `∑ i (p - #(S i)) ≤ (k-2)(p-1)`, for every direction `v i₀` and every
scalar `c` there is a reachable point `r` with `det r (v i₀) = c`; that is, the
reach meets every line parallel to `v i₀`. -/
theorem reach_meets_every_line {k : ℕ} (hp : p.Prime) (hk : 2 ≤ k)
    (v : Fin k → Plane p) (hv : PairwiseIndep v) (S : Fin k → Finset (ZMod p))
    (h0 : ∀ i, (0 : ZMod p) ∈ S i) (hd : defSum S ≤ (k - 2) * (p - 1))
    (i₀ : Fin k) (c : ZMod p) :
    ∃ r ∈ Reach v S, det r (v i₀) = c := by
  haveI : Fact p.Prime := ⟨hp⟩
  classical
  have hp2 : 2 ≤ p := hp.two_le
  set I : Finset (Fin k) := Finset.univ.erase i₀ with hI
  have hcard_I : #I = k - 1 := by
    rw [hI, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, Fintype.card_fin]
  have hne : ∀ i ∈ I, (S i).Nonempty := fun i _ => ⟨0, h0 i⟩
  have hcne : ∀ i ∈ I, det (v i) (v i₀) ≠ 0 := fun i hi => hv i i₀ (Finset.ne_of_mem_erase hi)
  have hcardS : ∀ i, #(S i) ≤ p := by
    intro i; simpa [ZMod.card] using (S i).card_le_univ
  -- the deficiency restricted to `I` is at most the total deficiency
  have hdI : (∑ i ∈ I, (p - #(S i))) ≤ defSum S := by
    rw [defSum]
    exact Finset.sum_le_sum_of_subset (Finset.subset_univ I)
  have hn : p + (k - 1) ≤ (∑ i ∈ I, #(S i)) + 1 := by
    have hsplit : (∑ i ∈ I, #(S i)) + (∑ i ∈ I, (p - #(S i))) = (k - 1) * p := by
      rw [← Finset.sum_add_distrib,
        Finset.sum_congr rfl (fun i _ => Nat.add_sub_cancel' (hcardS i)),
        Finset.sum_const, hcard_I, smul_eq_mul]
    obtain ⟨m, rfl⟩ : ∃ m, k = m + 2 := ⟨k - 2, by omega⟩
    obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
    simp only [Nat.add_sub_cancel] at hd hsplit ⊢
    have hexp : (m + 2 - 1) * (q + 1) = m * q + m + q + 1 := by
      have h' : m + 2 - 1 = m + 1 := by omega
      rw [h']; ring
    rw [hexp] at hsplit
    omega
  obtain ⟨A, hA, hcardA⟩ := exists_big_repr_set hp I (fun i => det (v i) (v i₀)) S hne hcne
  have hAuniv : A = Finset.univ := by
    have hge : p ≤ #A := le_trans (le_min le_rfl (by omega)) hcardA
    have hle : #A ≤ p := by simpa [ZMod.card] using A.card_le_univ
    refine Finset.eq_univ_of_card A ?_
    rw [ZMod.card]
    omega
  obtain ⟨s, hs, hsum⟩ := hA c (hAuniv ▸ Finset.mem_univ c)
  refine ⟨∑ i, (Function.update s i₀ 0) i • v i, ⟨Function.update s i₀ 0, ?_, rfl⟩, ?_⟩
  · intro i
    by_cases hi : i = i₀
    · rw [hi, Function.update_self]; exact h0 i₀
    · rw [Function.update_of_ne hi]
      exact hs i (Finset.mem_erase.2 ⟨hi, Finset.mem_univ i⟩)
  · rw [det_sum]
    have hterm : ∀ i, det ((Function.update s i₀ 0) i • v i) (v i₀)
        = (Function.update s i₀ 0) i * det (v i) (v i₀) := fun i => det_smul _ _ _
    rw [Finset.sum_congr rfl (fun i _ => hterm i),
      ← Finset.sum_erase_add _ _ (Finset.mem_univ i₀)]
    have hzero : (Function.update s i₀ 0) i₀ * det (v i₀) (v i₀) = 0 := by
      simp [det]
    rw [hzero, add_zero, ← hI]
    rw [← hsum]
    refine Finset.sum_congr rfl (fun i hi => ?_)
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hi), mul_comm]

/-- **No missing line.**  Under the conjectured deficiency bound, the complement
of the reach cannot contain a whole line in any of the `k` directions. -/
theorem reach_no_missing_line {k : ℕ} (hp : p.Prime) (hk : 2 ≤ k)
    (v : Fin k → Plane p) (hv : PairwiseIndep v) (S : Fin k → Finset (ZMod p))
    (h0 : ∀ i, (0 : ZMod p) ∈ S i) (hd : defSum S ≤ (k - 2) * (p - 1))
    (i₀ : Fin k) (b : Plane p) :
    ∃ t : ZMod p, b + t • v i₀ ∈ Reach v S := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨r, hr, hdet⟩ := reach_meets_every_line hp hk v hv S h0 hd i₀ (det b (v i₀))
  have hvi : v i₀ ≠ 0 := by
    obtain ⟨j, hj⟩ : ∃ j : Fin k, j ≠ i₀ := by
      by_contra hcon
      push_neg at hcon
      have h1 : (⟨0, by omega⟩ : Fin k) = i₀ := hcon _
      have h2 : (⟨1, by omega⟩ : Fin k) = i₀ := hcon _
      rw [← h2] at h1
      simp [Fin.ext_iff] at h1
    intro hz
    exact hv j i₀ hj (by simp [hz, det])
  have hzero : det (r - b) (v i₀) = 0 := by
    have hadd := det_add (r - b) b (v i₀)
    rw [sub_add_cancel, hdet] at hadd
    linear_combination -hadd
  obtain ⟨a, ha⟩ := exists_smul_of_det_eq_zero (r - b) (v i₀) hvi hzero
  exact ⟨a, by rw [← ha]; simpa using hr⟩

end KneserLines