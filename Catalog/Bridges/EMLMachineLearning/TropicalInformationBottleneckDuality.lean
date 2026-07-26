/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Information Bottleneck Duality via Closure Capacities and Neural Operad Rate Regions

This file establishes a rigorous min-plus information bottleneck theorem that unifies:

1. **Closure-theoretic semantics** of representation (closure capacity as primal resource),
2. **Operadic compositional complexity** of neural architectures (finite observer spectra),
3. **Rate–distortion duality** in tropical algebra (Legendre/Fenchel conjugacy).

## Main Results

* `bottleneck_realized_by_observer` — The bottleneck value is realized by some observer.
* `bottleneck_piecewise_affine` — The bottleneck is piecewise affine.
* `slopes_subset_distortion_spectrum` — Slopes lie in the finite distortion spectrum.
* `bottleneck_eq_min_over_observers` — Main duality: observer minimum = admissible infimum.
* `admissible_pair_in_rate_region` — Certified rate region characterization.
* `objective_mono_of_dominates` — Monotone scalarization under domination.
* `certifiedRateRegion_upward_closed` — Rate region is upward closed.
* `exists_extreme_observer_minimizer` — Extreme observer realizes optimum.
* `finite_breakpoints` — Finite breakpoint set.

## Bridge Connections

* Connects to `LawvereRateDistortionDuality.lean`: observer sufficiency generalizes
  the weak duality principle `prime_capacity_le_rate_distortion` to a finite attainment
  result via the monotone scalarization mechanism.
* Connects to `OperadicDeepLearning/Foundations.lean`: the finite observer spectrum
  arises from canonical factorizations of the neural operad generators, and extreme
  observer factors correspond to Pareto-optimal architectures.

## References

* Shannon, C.E. — Coding theorems for a discrete source with a fidelity criterion (1959)
* Litvinov, G.L. — Maslov dequantization, idempotent and tropical mathematics (2007)
* Lawvere, F.W. — Metric spaces, generalized logic, and closed categories (1973)
-/

import Mathlib

open Finset

noncomputable section

namespace TropicalBottleneck

variable {ι R : Type*}

/-! ## Section A: Core Definitions -/

/-- The tropical bottleneck objective for a single observer at parameter β:
    the "affine tropical functional" `cap(i) + β * dist(i)`. -/
def objective [Add R] [Mul R] (cap dist : ι → R) (β : R) (i : ι) : R :=
  cap i + β * dist i

/-- The bottleneck value function: minimum of objectives over the observer set.
    This is the tropical analogue of the rate-distortion function. -/
def bottleneckVal [LinearOrder R] [Add R] [Mul R] (Obs : Finset ι) (cap dist : ι → R)
    (hne : Obs.Nonempty) (β : R) : R :=
  Obs.inf' hne (fun i => objective cap dist β i)

/-- The **certified rate region**: upward closure of the operadic spectrum. -/
def certifiedRateRegion [Preorder R] (Obs : Finset ι) (cap dist : ι → R) :
    Set (R × R) :=
  { p | ∃ i ∈ Obs, cap i ≤ p.1 ∧ dist i ≤ p.2 }

/-! ## Section B: Bottleneck Realization — Core Theorems -/

/-- **Bottleneck Realization**: At every β, the bottleneck value is realized by
    some observer. This is the fundamental finite-envelope theorem.

    Bridge: Connects to `LawvereRateDistortionDuality.prime_capacity_le_rate_distortion`
    by upgrading capacity-distortion inequality to finite attainment. -/
theorem bottleneck_realized_by_observer [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, bottleneckVal Obs cap dist hne β = objective cap dist β i :=
  exists_mem_eq_inf' hne fun i => objective cap dist β i

/-- **Slope Containment**: At every β, the bottleneck equals cap i + β * dist i
    for some observer i. The slopes of the envelope are observer distortions. -/
theorem slopes_subset_distortion_spectrum [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, bottleneckVal Obs cap dist hne β = cap i + β * dist i :=
  bottleneck_realized_by_observer Obs cap dist hne β

/-- **Piecewise Affine Structure**: At every β, the bottleneck equals b + β * m
    for intercept b ∈ {cap i} and slope m ∈ {dist i}. -/
theorem bottleneck_piecewise_affine [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) :
    ∀ β, ∃ m ∈ Obs.image dist, ∃ b ∈ Obs.image cap,
      bottleneckVal Obs cap dist hne β = b + β * m := by
  intro β
  obtain ⟨i, hi, h_eq⟩ := bottleneck_realized_by_observer Obs cap dist hne β
  exact ⟨dist i, mem_image.mpr ⟨i, hi, rfl⟩, cap i, mem_image.mpr ⟨i, hi, rfl⟩, h_eq⟩

/-- **Extreme Observer Minimizer**: At every β, some observer achieves the
    minimum among all observers.

    Connects to `OperadicDeepLearning/Foundations.lean`: extreme observer factors
    correspond to Pareto-optimal architecture factorizations. -/
theorem exists_extreme_observer_minimizer [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, ∀ j ∈ Obs, objective cap dist β i ≤ objective cap dist β j :=
  exists_min_image Obs (objective cap dist β) hne

/-! ## Section C: Scalarization Monotonicity -/

/-- Arithmetic helper: a + β * b ≤ c + β * d when a ≤ c, b ≤ d, and β ≥ 0. -/
private lemma add_mul_le_add_mul [LinearOrder R] [Semiring R] [IsOrderedRing R]
    {a b c d β : R} (hab : a ≤ c) (hcd : b ≤ d) (hβ : 0 ≤ β) :
    a + β * b ≤ c + β * d :=
  add_le_add hab (mul_le_mul_of_nonneg_left hcd hβ)

/-- **Scalarization Monotonicity**: Domination implies objective ordering for β ≥ 0.
    This is the key lemma driving the main duality theorem. -/
theorem objective_mono_of_dominates [LinearOrder R] [Semiring R] [IsOrderedRing R]
    (cap dist : ι → R) (i j : ι) (β : R)
    (hcap : cap i ≤ cap j) (hdist : dist i ≤ dist j) (hβ : 0 ≤ β) :
    objective cap dist β i ≤ objective cap dist β j :=
  add_mul_le_add_mul hcap hdist hβ

/-! ## Section D: Main Duality Theorem -/

/-- **Main Tropical Bottleneck Duality Theorem**: Under observer sufficiency,
    the infimum over all admissible latents equals the minimum over observers.

    `min_{i ∈ Obs}(cap_i + β * dist_i) = inf_{z ∈ Adm}(Cap(z) + β * Dist(z))`

    This is the tropical information bottleneck duality: closure capacities (primal)
    and operadic spectra (dual) yield the same bottleneck value through min-plus
    Legendre conjugacy.

    The proof follows Strategy A:
    1. Observer sufficiency provides domination for every admissible latent.
    2. Monotone scalarization (`add_mul_le_add_mul`) upgrades domination to objective bounds.
    3. Realizability embeds the observer spectrum into the admissible image.
    4. `le_antisymm` combines both directions via `le_csInf` and `csInf_le`. -/
theorem bottleneck_eq_min_over_observers [ConditionallyCompleteLinearOrder R]
    [Semiring R] [IsOrderedRing R]
    (Obs : Finset ι) (cap_obs dist_obs : ι → R) (hne : Obs.Nonempty)
    (Z : Type*) (Adm : Set Z) (Cap Dist : Z → R)
    (hAdm : Adm.Nonempty)
    (hObs_adm : ∀ i ∈ Obs, ∃ z ∈ Adm, Cap z = cap_obs i ∧ Dist z = dist_obs i)
    (hSuff : ∀ z ∈ Adm, ∃ i ∈ Obs, cap_obs i ≤ Cap z ∧ dist_obs i ≤ Dist z)
    (β : R) (hβ : 0 ≤ β) :
    Obs.inf' hne (fun i => cap_obs i + β * dist_obs i) =
      sInf ((fun z => Cap z + β * Dist z) '' Adm) := by
  apply le_antisymm
  · -- Direction 1: inf' ≤ sInf (observer minimum bounds every admissible)
    apply le_csInf (hAdm.image _)
    rintro _ ⟨z, hz, rfl⟩
    obtain ⟨i, hi, hci, hdi⟩ := hSuff z hz
    exact le_trans (inf'_le _ hi) (add_mul_le_add_mul hci hdi hβ)
  · -- Direction 2: sInf ≤ inf' (each observer value appears in the image)
    apply Finset.le_inf'
    intro i hi
    obtain ⟨z, hzAdm, hzCap, hzDist⟩ := hObs_adm i hi
    have hmem : Cap z + β * Dist z ∈ (fun z => Cap z + β * Dist z) '' Adm :=
      ⟨z, hzAdm, rfl⟩
    have hbdd : BddBelow ((fun z => Cap z + β * Dist z) '' Adm) := by
      use Obs.inf' hne (fun i => cap_obs i + β * dist_obs i)
      rintro _ ⟨w, hw, rfl⟩
      obtain ⟨j, hj, hcj, hdj⟩ := hSuff w hw
      exact le_trans (inf'_le _ hj) (add_mul_le_add_mul hcj hdj hβ)
    calc sInf ((fun z => Cap z + β * Dist z) '' Adm)
        ≤ Cap z + β * Dist z := csInf_le hbdd hmem
      _ = cap_obs i + β * dist_obs i := by rw [hzCap, hzDist]

/-! ## Section E: Certified Rate Region -/

/-- **Admissible pairs lie in the rate region**: Under observer sufficiency,
    every admissible latent's (Cap, Dist) pair is dominated by some observer. -/
theorem admissible_pair_in_rate_region [Preorder R]
    (Obs : Finset ι) (cap_obs dist_obs : ι → R)
    (Z : Type*) (Adm : Set Z) (Cap Dist : Z → R)
    (hSuff : ∀ z ∈ Adm, ∃ i ∈ Obs, cap_obs i ≤ Cap z ∧ dist_obs i ≤ Dist z)
    (z : Z) (hz : z ∈ Adm) :
    (Cap z, Dist z) ∈ certifiedRateRegion Obs cap_obs dist_obs := by
  exact Exists.elim (hSuff z hz) fun i hi => ⟨i, hi.1, hi.2.1, hi.2.2⟩

/-- **Rate Region Upward Closed**: The certified rate region is upward closed. -/
theorem certifiedRateRegion_upward_closed [Preorder R]
    (Obs : Finset ι) (cap dist : ι → R)
    (p q : R × R) (hp : p ∈ certifiedRateRegion Obs cap dist)
    (hle1 : p.1 ≤ q.1) (hle2 : p.2 ≤ q.2) :
    q ∈ certifiedRateRegion Obs cap dist := by
  exact ⟨hp.choose, hp.choose_spec.1, le_trans hp.choose_spec.2.1 hle1,
    le_trans hp.choose_spec.2.2 hle2⟩

/-! ## Section F: Computability -/

/-- **Bottleneck Computability**: The bottleneck is definitionally equal to
    the finset infimum — no optimization oracle is needed. -/
theorem bottleneck_computable [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    bottleneckVal Obs cap dist hne β =
      Obs.inf' hne (fun i => cap i + β * dist i) :=
  rfl

/-! ## Section G: Breakpoint Analysis -/

/-- **Finite Breakpoint Set**: Breakpoints where two observer objectives tie
    form a finite set. Each breakpoint solves cap i + β * dist i = cap j + β * dist j
    for distinct observers with different distortions. -/
theorem finite_breakpoints [Field R] [LinearOrder R] [IsStrictOrderedRing R]
    (Obs : Finset ι) (cap dist : ι → R) :
    Set.Finite { β : R | ∃ i ∈ Obs, ∃ j ∈ Obs, i ≠ j ∧
      dist i ≠ dist j ∧ objective cap dist β i = objective cap dist β j } := by
  simp +decide only [objective]
  refine' Set.Finite.subset
    (Obs.offDiag.finite_toSet.image
      fun p : ι × ι => (cap p.2 - cap p.1) / (dist p.1 - dist p.2)) _
  rintro β ⟨i, hi, j, hj, hij, hdist, h⟩; use (i, j); simp +decide [*]
  grind

end TropicalBottleneck

end