import Mathlib

/-!
# Contrarian results for finite-volume Ising symmetry

A frequently stated but false finite-volume version of spontaneous symmetry
breaking says that a zero-field Gibbs state can already have nonzero expected
magnetization.  The theorem below proves the opposite in a model-independent
finite setting: any finite Gibbs ensemble with a fixed-point-free or non-fixed-
point-free involutive spin flip, flip-invariant energy, and odd magnetization has
exactly zero expected magnetization.

This does not contradict the infinite-volume Ising transition.  Spontaneous
magnetization requires first selecting plus boundary conditions (or a positive
field) and then taking a thermodynamic limit; the symmetric finite-volume state
is always the equal mixture of its two flipped phases.
-/

noncomputable section

namespace Ising.Contrarian

open scoped BigOperators

variable {Ω : Type*} [Fintype Ω]

/-- Finite-volume zero-field partition function. -/
def partition (β : ℝ) (energy : Ω → ℝ) : ℝ :=
  ∑ ω, Real.exp (-β * energy ω)

/-- Unnormalised first moment of an observable. -/
def numerator (β : ℝ) (energy observable : Ω → ℝ) : ℝ :=
  ∑ ω, Real.exp (-β * energy ω) * observable ω

/-- Finite-volume Gibbs expectation. -/
def gibbsExpectation (β : ℝ) (energy observable : Ω → ℝ) : ℝ :=
  numerator β energy observable / partition β energy

/-- Every finite partition function built from real energies is strictly positive. -/
theorem partition_pos [Nonempty Ω] (β : ℝ) (energy : Ω → ℝ) :
    0 < partition β energy := by
  unfold partition
  exact Finset.sum_pos (fun _ _ => Real.exp_pos _) (Finset.univ_nonempty)

/-- Reindexing by an involutive symmetry and using oddness makes the
unnormalised magnetization vanish exactly. -/
theorem numerator_eq_zero_of_flip
    (flip : Ω → Ω) (energy observable : Ω → ℝ) (β : ℝ)
    (hflip : Function.Involutive flip)
    (henergy : ∀ ω, energy (flip ω) = energy ω)
    (hodd : ∀ ω, observable (flip ω) = -observable ω) :
    numerator β energy observable = 0 := by
  unfold numerator
  -- Reindex the sum by flip
  have h : ∑ ω, Real.exp (-β * energy ω) * observable ω = ∑ ω, Real.exp (-β * energy (flip ω)) * observable (flip ω) := by
    rw [← Equiv.sum_comp (Equiv.ofBijective flip (hflip.bijective))]
    simp
  -- Use the symmetry properties to rewrite the reindexed sum as the negative
  have h' : ∑ ω, Real.exp (-β * energy (flip ω)) * observable (flip ω) = ∑ ω, -Real.exp (-β * energy ω) * observable ω := by
    simp [henergy, hodd]
  have h'' : ∑ ω, -Real.exp (-β * energy ω) * observable ω = -∑ ω, Real.exp (-β * energy ω) * observable ω := by
    simp [neg_mul]
  linarith [h, h', h'']

/-- **Disproof of finite-volume spontaneous magnetization.** In a finite,
zero-field, spin-flip symmetric Gibbs ensemble, every odd order parameter has
expectation exactly zero, at every inverse temperature. -/
theorem finite_volume_magnetization_eq_zero
    (flip : Ω → Ω) (energy magnetization : Ω → ℝ) (β : ℝ)
    (hflip : Function.Involutive flip)
    (henergy : ∀ ω, energy (flip ω) = energy ω)
    (hodd : ∀ ω, magnetization (flip ω) = -magnetization ω) :
    gibbsExpectation β energy magnetization = 0 := by
  rw [gibbsExpectation, numerator_eq_zero_of_flip flip energy magnetization β hflip henergy hodd]
  exact zero_div _

/-- Thus the bold conjecture that the symmetric finite-volume state has
strictly positive magnetization below some temperature is false. -/
theorem not_finite_volume_positive_magnetization
    (flip : Ω → Ω) (energy magnetization : Ω → ℝ)
    (hflip : Function.Involutive flip)
    (henergy : ∀ ω, energy (flip ω) = energy ω)
    (hodd : ∀ ω, magnetization (flip ω) = -magnetization ω) :
    ¬ ∃ β : ℝ, 0 < gibbsExpectation β energy magnetization := by
  intro ⟨β, hβ⟩
  rw [finite_volume_magnetization_eq_zero flip energy magnetization β hflip henergy hodd] at hβ
  exact not_lt.mpr le_rfl hβ

/-- Algebraic endpoint of the Peierls argument: if the probability `p` of a
minus spin is controlled by a contour majorant strictly below `1/2`, then the
local magnetization `1-2p` is positive. -/
theorem peierls_probability_implies_positive_magnetization
    {p contourBound : ℝ} (hp : p ≤ contourBound) (hcontour : contourBound < 1 / 2) :
    0 < 1 - 2 * p := by
  linarith

end Ising.Contrarian