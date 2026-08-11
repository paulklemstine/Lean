/-
# The metric groupoid of ε-approximate structural analogies

Building on `Catalog/Probability/QuantitativeCopycat.lean`, this file shows that
ε-approximate structural analogies ("Copycat maps") between finite probabilistic
transition systems form a *groupoid graded by a metric*:

* `overlapDefect_eq_half_l1` : the overlap defect used in `ApproxAnalogy` is exactly
  the total variation distance of the two transported one-step distributions.
* `overlapDefect_triangle` : the defect satisfies the triangle inequality.
* `ApproxAnalogy.refl`, `ApproxAnalogy.symm`, `ApproxAnalogy.comp`,
  `ApproxAnalogy.mono` : identities are exact, inverses keep the same defect, and
  composition adds defects.
* `transport_comp_le` : the resulting quantitative transport bound along a composite
  analogy, and `holonomy_bound` : a *semantic holonomy* estimate — traversing a
  two-step loop of ε-analogies moves the depth-`d` truth probability of any world by
  at most `1 - (1-2ε)^d`, so exact analogies have trivial holonomy and approximate
  ones have holonomy controlled by the accumulated defect.

This makes precise, in the probabilistic setting, the passage from single analogies
to networks of analogies: the obstruction to globally consistent meaning around a
cycle is bounded by the geometric accumulation of the local defects.
-/
import Probability.QuantitativeCopycat

namespace Catalog.Probability.QuantitativeCopycat

open Finset

/-! ## The overlap defect is the total variation distance -/

/-- Overlap defect of two distributions: `1 - ∑ min`. -/
def overlapDefect {S : Type*} [Fintype S] (P Q : S → ℝ) : ℝ :=
  1 - ∑ t, min (P t) (Q t)

variable {S : Type*} [Fintype S]

theorem abs_sub_eq_add_sub_two_min (a b : ℝ) : |a - b| = a + b - 2 * min a b := by
  rcases le_total a b with h | h
  · rw [abs_of_nonpos (by linarith), min_eq_left h]; ring
  · rw [abs_of_nonneg (by linarith), min_eq_right h]; ring

/-- The overlap defect of two probability vectors is their total variation distance. -/
theorem overlapDefect_eq_half_l1 (P Q : S → ℝ) (hP : ∑ t, P t = 1) (hQ : ∑ t, Q t = 1) :
    overlapDefect P Q = (∑ t, |P t - Q t|) / 2 := by
  have hsum : ∑ t, |P t - Q t| = ∑ t, (P t + Q t - 2 * min (P t) (Q t)) :=
    Finset.sum_congr rfl fun t _ => abs_sub_eq_add_sub_two_min _ _
  rw [hsum]
  simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hP, hQ,
    overlapDefect]
  ring

/-- Triangle inequality for the overlap defect on probability vectors. -/
theorem overlapDefect_triangle (P Q R : S → ℝ)
    (hP : ∑ t, P t = 1) (hQ : ∑ t, Q t = 1) (hR : ∑ t, R t = 1) :
    overlapDefect P R ≤ overlapDefect P Q + overlapDefect Q R := by
  rw [overlapDefect_eq_half_l1 P R hP hR, overlapDefect_eq_half_l1 P Q hP hQ,
    overlapDefect_eq_half_l1 Q R hQ hR]
  have h : ∑ t, |P t - R t| ≤ ∑ t, (|P t - Q t| + |Q t - R t|) :=
    Finset.sum_le_sum fun t _ => by
      simpa using abs_sub_le (P t) (Q t) (R t)
  rw [Finset.sum_add_distrib] at h
  linarith

/-- The overlap defect is nonnegative on probability vectors. -/
theorem overlapDefect_nonneg (P Q : S → ℝ) (hP : ∑ t, P t = 1) :
    0 ≤ overlapDefect P Q := by
  have : ∑ t, min (P t) (Q t) ≤ ∑ t, P t :=
    Finset.sum_le_sum fun t _ => min_le_left _ _
  rw [hP] at this
  simp only [overlapDefect]
  linarith

/-! ## Groupoid structure -/

variable {ι S' S'' : Type*} [Fintype S'] [Fintype S'']

namespace ApproxAnalogy

/-- Every structure is exactly analogous to itself. -/
def refl (M : PModalStructure ι S) : ApproxAnalogy M M 0 where
  toEquiv := Equiv.refl S
  atoms _ _ := rfl
  defect s := by
    have h : ∑ t, min (M.step s t) (M.step ((Equiv.refl S) s) ((Equiv.refl S) t)) = 1 := by
      simp only [Equiv.refl_apply, min_self]
      exact M.step_sum s
    rw [h]
    norm_num

/-- Weakening: an ε-analogy is an ε'-analogy for any larger ε'. -/
def mono {M : PModalStructure ι S} {N : PModalStructure ι S'} {ε ε' : ℝ}
    (A : ApproxAnalogy M N ε) (h : ε ≤ ε') : ApproxAnalogy M N ε' where
  toEquiv := A.toEquiv
  atoms := A.atoms
  defect s := le_trans (A.defect s) h

/-- Analogies are symmetric with the same defect. -/
def symm {M : PModalStructure ι S} {N : PModalStructure ι S'} {ε : ℝ}
    (A : ApproxAnalogy M N ε) : ApproxAnalogy N M ε where
  toEquiv := A.toEquiv.symm
  atoms p u := by
    have := A.atoms p (A.toEquiv.symm u)
    rw [Equiv.apply_symm_apply] at this
    exact this.symm
  defect u := by
    have hre : ∑ t, min (N.step u (A.toEquiv t)) (M.step (A.toEquiv.symm u) t)
        = ∑ v, min (N.step u v) (M.step (A.toEquiv.symm u) (A.toEquiv.symm v)) := by
      refine Fintype.sum_equiv A.toEquiv _ _ fun t => ?_
      rw [Equiv.symm_apply_apply]
    have hA := A.defect (A.toEquiv.symm u)
    rw [Equiv.apply_symm_apply] at hA
    rw [← hre]
    calc 1 - ∑ t, min (N.step u (A.toEquiv t)) (M.step (A.toEquiv.symm u) t)
        = 1 - ∑ t, min (M.step (A.toEquiv.symm u) t) (N.step u (A.toEquiv t)) := by
          simp [min_comm]
      _ ≤ ε := hA

/-- Composition of analogies adds defects. -/
def comp {M : PModalStructure ι S} {N : PModalStructure ι S'} {K : PModalStructure ι S''}
    {ε₁ ε₂ : ℝ} (A : ApproxAnalogy M N ε₁) (B : ApproxAnalogy N K ε₂) :
    ApproxAnalogy M K (ε₁ + ε₂) where
  toEquiv := A.toEquiv.trans B.toEquiv
  atoms p s := by
    have h1 := B.atoms p (A.toEquiv s)
    have h2 := A.atoms p s
    simpa [Equiv.trans_apply] using h1.trans h2
  defect s := by
    set f := A.toEquiv
    set g := B.toEquiv
    set P : S → ℝ := fun t => M.step s t with hP
    set Q : S → ℝ := fun t => N.step (f s) (f t) with hQ
    set R : S → ℝ := fun t => K.step (g (f s)) (g (f t)) with hR
    have hPs : ∑ t, P t = 1 := M.step_sum s
    have hQs : ∑ t, Q t = 1 := by
      rw [hQ, show (∑ t, N.step (f s) (f t)) = ∑ u, N.step (f s) u from
        Equiv.sum_comp f (fun u => N.step (f s) u)]
      exact N.step_sum (f s)
    have hRs : ∑ t, R t = 1 := by
      have h1 : (∑ t, K.step (g (f s)) (g (f t))) = ∑ u, K.step (g (f s)) (g u) :=
        Equiv.sum_comp f (fun u => K.step (g (f s)) (g u))
      have h2 : (∑ u, K.step (g (f s)) (g u)) = ∑ w, K.step (g (f s)) w :=
        Equiv.sum_comp g (fun w => K.step (g (f s)) w)
      rw [hR, h1, h2]
      exact K.step_sum (g (f s))
    have hAd : overlapDefect P Q ≤ ε₁ := A.defect s
    have hBd : overlapDefect Q R ≤ ε₂ := by
      have hB := B.defect (f s)
      have hre : ∑ u, min (N.step (f s) u) (K.step (g (f s)) (g u))
          = ∑ t, min (Q t) (R t) :=
        (Equiv.sum_comp f (fun u => min (N.step (f s) u) (K.step (g (f s)) (g u)))).symm
      simp only [overlapDefect]
      rw [← hre]
      exact hB
    have := overlapDefect_triangle P Q R hPs hQs hRs
    have hgoal : 1 - ∑ t, min (M.step s t) (K.step ((A.toEquiv.trans B.toEquiv) s)
        ((A.toEquiv.trans B.toEquiv) t)) = overlapDefect P R := rfl
    rw [hgoal]
    linarith

end ApproxAnalogy

/-- Quantitative transport along a composite of two approximate analogies. -/
theorem transport_comp_le {M : PModalStructure ι S} {N : PModalStructure ι S'}
    {K : PModalStructure ι S''} {ε₁ ε₂ : ℝ} (h1 : 0 ≤ ε₁) (h2 : 0 ≤ ε₂)
    (hsum : ε₁ + ε₂ ≤ 1) (A : ApproxAnalogy M N ε₁) (B : ApproxAnalogy N K ε₂)
    (φ : PForm ι) (s : S) :
    |M.eval φ s - K.eval φ (B.toEquiv (A.toEquiv s))|
      ≤ 1 - (1 - (ε₁ + ε₂)) ^ φ.depth := by
  have := M.transport_le K (by linarith) hsum (A.comp B) φ s
  simpa [ApproxAnalogy.comp, Equiv.trans_apply] using this

/-- **Semantic holonomy bound.** Going around a two-step loop of ε-approximate
analogies (`M → N → M`) moves the depth-`d` truth probability of every world by at
most `1 - (1-2ε)^d`; in particular exact analogies (`ε = 0`) have trivial
holonomy. -/
theorem holonomy_bound {M : PModalStructure ι S} {N : PModalStructure ι S'} {ε : ℝ}
    (h0 : 0 ≤ ε) (h1 : 2 * ε ≤ 1) (A : ApproxAnalogy M N ε) (B : ApproxAnalogy N M ε)
    (φ : PForm ι) (s : S) :
    |M.eval φ s - M.eval φ (B.toEquiv (A.toEquiv s))| ≤ 1 - (1 - 2 * ε) ^ φ.depth := by
  have := transport_comp_le h0 h0 (by linarith) A B φ s
  have hrw : ε + ε = 2 * ε := by ring
  rwa [hrw] at this

/-- Exact loops have trivial semantic holonomy: composing two exact analogies
returns every world to one with the same truth probabilities. -/
theorem holonomy_trivial {M : PModalStructure ι S} {N : PModalStructure ι S'}
    (A : ApproxAnalogy M N 0) (B : ApproxAnalogy N M 0) (φ : PForm ι) (s : S) :
    M.eval φ s = M.eval φ (B.toEquiv (A.toEquiv s)) := by
  have h := holonomy_bound le_rfl (by norm_num) A B φ s
  have hz : (1 : ℝ) - (1 - 2 * 0) ^ φ.depth = 0 := by norm_num
  rw [hz] at h
  exact sub_eq_zero.1 (abs_eq_zero.1
    (le_antisymm h (abs_nonneg _)))

end Catalog.Probability.QuantitativeCopycat