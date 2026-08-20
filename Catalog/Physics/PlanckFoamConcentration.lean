import Physics.PlanckFoamStochastic

/-!
# Concentration of the branch density of a stochastic Planck foam

The Bernoulli foam measure `weightOn p s A` of `Physics.PlanckFoamStochastic`
has mean branch number `|s| * p`.  Here we compute its **second moment** and
deduce a Chebyshev concentration estimate: the density of Planck branch points
in a large region is essentially deterministic.

## Main results

* `PlanckFoam.Stochastic.sum_weightOn_mul_card_sq` — the exact second moment
  `∑ w(A) |A|² = |s| p (1-p) + (|s| p)²`, by induction on the cell set.
* `PlanckFoam.Stochastic.variance_branch_count` — hence the variance is
  `|s| p (1-p)`.
* `PlanckFoam.Stochastic.chebyshev_branch_count` — Chebyshev's inequality for
  the foam measure.
* `PlanckFoam.Stochastic.branch_density_concentration` — for a fixed relative
  tolerance `ε`, the probability that the branch density deviates from `p` by
  more than `ε` is at most `p (1-p) / (N ε²)`, hence tends to `0` as the number
  of Planck cells grows: **the foam has a well defined branch density**.
-/

open Finset

namespace PlanckFoam
namespace Stochastic

variable {α : Type*} [DecidableEq α]

theorem weightOn_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (s A : Finset α) :
    0 ≤ weightOn p s A := by
  refine Finset.prod_nonneg fun i _ => ?_
  by_cases h : i ∈ A
  · simpa [h] using hp0
  · simpa [h] using by linarith

/-- The exact second moment of the branch number. -/
theorem sum_weightOn_mul_card_sq (p : ℝ) (s : Finset α) :
    ∑ A ∈ s.powerset, weightOn p s A * (A.card : ℝ) ^ 2
      = s.card * p * (1 - p) + (s.card * p) ^ 2 := by
  induction s using Finset.induction_on with
  | empty => simp [weightOn]
  | insert a s has ih =>
      rw [Finset.sum_powerset_insert has]
      have h₁ : ∀ A ∈ s.powerset, weightOn p (insert a s) A * (A.card : ℝ) ^ 2
          = (1 - p) * (weightOn p s A * (A.card : ℝ) ^ 2) := by
        intro A hA
        rw [weightOn_insert_notMem has (Finset.mem_powerset.1 hA)]
        ring
      have h₂ : ∀ A ∈ s.powerset,
          weightOn p (insert a s) (insert a A) * ((insert a A).card : ℝ) ^ 2
            = p * (weightOn p s A * (A.card : ℝ) ^ 2)
              + (2 * p) * (weightOn p s A * (A.card : ℝ)) + p * weightOn p s A := by
        intro A hA
        have hAs : A ⊆ s := Finset.mem_powerset.1 hA
        have haA : a ∉ A := fun h => has (hAs h)
        rw [weightOn_insert_mem has, Finset.card_insert_of_notMem haA]
        push_cast
        ring
      rw [Finset.sum_congr rfl h₁, Finset.sum_congr rfl h₂]
      simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      rw [ih, sum_weightOn_mul_card p s, sum_weightOn p s, Finset.card_insert_of_notMem has]
      push_cast
      ring

/-- The variance of the number of Planck branch points is `|s| p (1 - p)`. -/
theorem variance_branch_count (p : ℝ) (s : Finset α) :
    ∑ A ∈ s.powerset, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2
      = s.card * p * (1 - p) := by
  have hexpand : ∀ A ∈ s.powerset,
      weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2
        = weightOn p s A * (A.card : ℝ) ^ 2
          - 2 * (s.card * p) * (weightOn p s A * (A.card : ℝ))
          + (s.card * p) ^ 2 * weightOn p s A := by
    intro A _
    ring
  rw [Finset.sum_congr rfl hexpand]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    sum_weightOn_mul_card_sq p s, sum_weightOn_mul_card p s, sum_weightOn p s]
  ring

/-- **Chebyshev's inequality for the Planck foam measure.** -/
theorem chebyshev_branch_count {p t : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (ht : 0 < t)
    (s : Finset α) :
    ∑ A ∈ s.powerset.filter (fun A => t ≤ |(A.card : ℝ) - s.card * p|), weightOn p s A
      ≤ s.card * p * (1 - p) / t ^ 2 := by
  classical
  set T := s.powerset.filter (fun A => t ≤ |(A.card : ℝ) - s.card * p|) with hT
  have hkey : t ^ 2 * ∑ A ∈ T, weightOn p s A
      ≤ ∑ A ∈ T, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2 := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun A hA => ?_
    have hA' : t ≤ |(A.card : ℝ) - s.card * p| := (Finset.mem_filter.1 hA).2
    have hsq : t ^ 2 ≤ ((A.card : ℝ) - s.card * p) ^ 2 := by
      rw [← sq_abs ((A.card : ℝ) - s.card * p)]
      exact pow_le_pow_left₀ ht.le hA' 2
    have hw : 0 ≤ weightOn p s A := weightOn_nonneg hp0 hp1 s A
    nlinarith [hw, hsq]
  have hsub : ∑ A ∈ T, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2
      ≤ ∑ A ∈ s.powerset, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2 := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) fun A _ _ => ?_
    have hw : 0 ≤ weightOn p s A := weightOn_nonneg hp0 hp1 s A
    positivity
  have hvar := variance_branch_count p s
  rw [le_div_iff₀ (by positivity : (0:ℝ) < t ^ 2)]
  calc (∑ A ∈ T, weightOn p s A) * t ^ 2
      = t ^ 2 * ∑ A ∈ T, weightOn p s A := by ring
    _ ≤ ∑ A ∈ T, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2 := hkey
    _ ≤ ∑ A ∈ s.powerset, weightOn p s A * ((A.card : ℝ) - s.card * p) ^ 2 := hsub
    _ = s.card * p * (1 - p) := hvar

/-! ### Concentration of the branch density -/

variable {N : ℕ}

/-- **The Planck foam has a well defined branch density.** The probability that
the observed density of branch points deviates from `p` by more than `ε` is at
most `p (1 - p) / (N ε²)`. -/
theorem branch_density_concentration {p ε : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hε : 0 < ε)
    (hN : 0 < N) :
    ∑ A ∈ (Finset.univ : Finset (Fin N)).powerset.filter
        (fun A => ε ≤ |(A.card : ℝ) / N - p|), cellWeight p A
      ≤ p * (1 - p) / (N * ε ^ 2) := by
  classical
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hcard : ((Finset.univ : Finset (Fin N)).card : ℝ) = N := by simp
  have hfilter : (Finset.univ : Finset (Fin N)).powerset.filter
      (fun A => ε ≤ |(A.card : ℝ) / N - p|)
      = (Finset.univ : Finset (Fin N)).powerset.filter
        (fun A => N * ε ≤ |(A.card : ℝ)
          - ((Finset.univ : Finset (Fin N)).card : ℝ) * p|) := by
    refine Finset.filter_congr fun A _ => ?_
    rw [hcard]
    have hEq : (A.card : ℝ) - N * p = N * ((A.card : ℝ) / N - p) := by
      field_simp
    rw [hEq, abs_mul, abs_of_pos hNpos]
    exact ⟨fun h => mul_le_mul_of_nonneg_left h hNpos.le,
      fun h => le_of_mul_le_mul_left (by linarith) hNpos⟩
  rw [hfilter]
  simp only [cellWeight]
  refine (chebyshev_branch_count (p := p) (t := (N : ℝ) * ε) hp0 hp1 (by positivity)
    (Finset.univ : Finset (Fin N))).trans (le_of_eq ?_)
  rw [hcard]
  field_simp

end Stochastic
end PlanckFoam