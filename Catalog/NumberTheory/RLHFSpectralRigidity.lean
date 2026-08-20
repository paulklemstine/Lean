import Catalog.NumberTheory.RLHFGibbsVariational

/-!
# The reward spectrum of an RLHF problem and its rigidity

The partition function `Z(t) = ∑_y p y · exp (r y · t)` of an RLHF problem only sees the
reward `r` through the *reward spectrum*: the finitely many reward levels together with the
probability mass the reference policy puts on each of them.  This file introduces that
spectrum and proves the two structural facts used downstream
(`Catalog/NumberTheory/RLHFPronySampling.lean`,
`Catalog/NumberTheory/RLHFChebyshevSystem.lean`):

* `RLHF.rewardMass` — the mass `∑_{y : r y = w} p y` carried by the level `w`;
* `RLHF.rewardMass_eq_zero` — levels outside the range of the reward carry no mass;
* `RLHF.sum_exp_eq_rewardMass_sum` — **spectral form of the partition function**: for any
  finite list of candidate levels containing the range of `r`, the exponential sum
  `∑_y p y exp (r y t)` collapses to the sum over levels `∑_w rewardMass r p w · exp (w t)`.
  This is the fibrewise decomposition of the response space over the reward levels.
* `RLHF.spectral_rigidity` — the qualitative rigidity statement: if two RLHF problems have
  the same reward spectrum, their partition functions agree at every temperature; and the
  spectral form shows the partition function depends on `(r, p)` only through the spectrum.

Everything here is elementary but load-bearing: it is the dictionary that turns statements
about partition functions into statements about (generalized) exponential sums.
-/

namespace RLHF

open Finset

variable {Ω Ω₁ Ω₂ ι : Type*} [Fintype Ω] [Fintype Ω₁] [Fintype Ω₂] [Fintype ι]

/-- The probability mass that the reference policy `p` puts on the reward level `w`. -/
noncomputable def rewardMass (r p : Ω → ℝ) (w : ℝ) : ℝ :=
  ∑ y ∈ univ.filter (fun y => r y = w), p y

/-- A level outside the range of the reward carries no mass. -/
theorem rewardMass_eq_zero {r p : Ω → ℝ} {w : ℝ} (hw : w ∉ image r univ) :
    rewardMass r p w = 0 := by
  have hempty : (univ.filter (fun y => r y = w)) = ∅ := by
    refine Finset.eq_empty_of_forall_notMem fun y hy => ?_
    have hry : r y = w := (Finset.mem_filter.1 hy).2
    exact hw (hry ▸ Finset.mem_image_of_mem r (Finset.mem_univ y))
  rw [rewardMass, hempty, Finset.sum_empty]

/-- **Spectral form of the exponential sum.**  If every reward value occurs among the
candidate levels `v`, the exponential sum over responses collapses to a sum over levels
weighted by the reward masses. -/
theorem sum_exp_eq_rewardMass_sum {r p : Ω → ℝ} {v : ι → ℝ}
    (hsub : image r univ ⊆ image v univ) (t : ℝ) :
    ∑ y, p y * Real.exp (r y * t)
      = ∑ w ∈ image v univ, rewardMass r p w * Real.exp (w * t) := by
  have hmaps : ∀ y ∈ (univ : Finset Ω), r y ∈ image v univ := fun y _ =>
    hsub (Finset.mem_image_of_mem r (Finset.mem_univ y))
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun y => p y * Real.exp (r y * t))]
  refine Finset.sum_congr rfl fun w _ => ?_
  rw [rewardMass, Finset.sum_mul]
  refine Finset.sum_congr rfl fun y hy => ?_
  rw [(Finset.mem_filter.1 hy).2]

/-- **Spectral rigidity, easy direction.**  Two RLHF problems whose reward spectra agree on
a common list of candidate levels have the same partition function at every inverse
temperature. -/
theorem spectral_rigidity {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ} {v : ι → ℝ}
    (h₁ : image r₁ univ ⊆ image v univ) (h₂ : image r₂ univ ⊆ image v univ)
    (hmass : ∀ w : ℝ, rewardMass r₁ p₁ w = rewardMass r₂ p₂ w) (t : ℝ) :
    ∑ y, p₁ y * Real.exp (r₁ y * t) = ∑ y, p₂ y * Real.exp (r₂ y * t) := by
  rw [sum_exp_eq_rewardMass_sum h₁ t, sum_exp_eq_rewardMass_sum h₂ t]
  exact Finset.sum_congr rfl fun w _ => by rw [hmass w]

end RLHF