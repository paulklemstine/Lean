/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Quantum Surreal Numbers: superposition of surreal kets with hyperreal amplitudes

A **quantum surreal state** is a finite formal superposition

  `|ψ⟩ = Σ_i a_i |Noᵢ⟩`

where the kets `|Noᵢ⟩` are indexed by *surreal numbers* `Noᵢ : Surreal` and the amplitudes
`a_i` live in the ordered, non-Archimedean field of *hyperreals* `ℝ*`.  Formally this is the free
`ℝ*`-module on the surreal numbers, i.e. a finitely supported map `Surreal →₀ ℝ*`.

The novelty is the **measurement rule**.  Because amplitudes are hyperreal, the Born weight
`|a_i|² / ‖ψ‖²` of a branch can be a genuine *infinitesimal*.  The *observed* probability of a
branch is defined to be the **standard part** of its Born weight,

  `observedProb ψ s = st ( (ψ s)² / ‖ψ‖² )`,

using `Hyperreal.st : ℝ* → ℝ`.  This gives infinitesimal probabilities a rigorous meaning: a
branch carried by an infinitesimal amplitude is *unobservable*, its observed probability being
exactly `0`, even though its exact (hyperreal) Born weight is strictly positive.

## Main results

* `bornProb_sum_eq_one` — the exact hyperreal Born weights of a nonzero state sum to `1`
  (normalization inside the non-Archimedean field).
* `observedProb_infinitesimal_eq_zero` — **unobservability of infinitesimal branches**: if the
  amplitude on a ket is infinitesimal and the total weight is appreciable, the observed
  probability of that ket is `0`.
* `epsilon_test` — the corrected worked example `|ψ⟩ = |0⟩ + ε|1⟩` (with `ε` the canonical
  positive infinitesimal): the standard branch `|0⟩` is observed with probability `1` and the
  infinitesimal branch `|1⟩` with probability `0`.

## Relation to the catalog

This file is the *quantum / spectral* half of a two-file study.  Its companion,
`Catalog/Geometry/QuantumSurreal/StandardPartMeasure.lean`, revisits the infinitesimal
probability model of `Catalog/Novelty/InfinitesimalFiniteProbability.lean` and proves that the
standard-part functional collapses that infinitesimal measure onto a genuine real (Dirac)
measure — exactly the classical shadow of the quantum collapse proved here.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): amplitudes valued in a non-Archimedean field let a superposition
carry branches whose Born weight is a positive infinitesimal.  Conjecture: under the
standard-part measurement rule such branches are *observationally invisible* while total
probability is preserved.

Experiment (Experimenter): computed the two-branch state `|0⟩ + ε|1⟩`.  Exact Born weights are
`1/(1+ε²)` and `ε²/(1+ε²)`; their standard parts are `1` and `0`.  This validated both the
normalization and the collapse before formalization.

Analysis (Analyst): the original mission "test" was internally inconsistent — it assigned the
infinitesimal branch the *appreciable* amplitude `1/√2` yet claimed observed probability `0`.
The mathematically consistent statement puts the *infinitesimal* on the amplitude, not merely on
the ket label.  `epsilon_test` records the corrected version.

Critique (Critic): none of the three main theorems is vacuous.  `bornProb_sum_eq_one` needs the
genuine hypothesis `normSq ψ ≠ 0`; `observedProb_infinitesimal_eq_zero` needs the total weight to
be *appreciable* (`¬ Infinitesimal (normSq ψ)`) — dropping it makes the claim false, since an
infinitesimal branch inside an even-more-infinitesimal total can have observed probability `1`.
Proofs use `st_mul`, `st_inv`, `Infinitesimal.mul` and a Finsupp support computation, not `decide`.

Synthesis (PI): the standard part `st : ℝ* → ℝ` is precisely the "observation" map that turns a
non-Archimedean amplitude field into ordinary quantum statistics.
-- !-- Lab Notes -- !--
-/

open Hyperreal Finsupp

namespace QuantumSurreal

/-- A **quantum surreal state**: a finitely supported assignment of hyperreal amplitudes to
surreal-number basis kets.  This is the free `ℝ*`-module on `Surreal`. -/
abbrev QSurreal := Surreal.{0} →₀ ℝ*

/-- The (squared) norm of a state: the finite sum of squared amplitudes, a hyperreal. -/
noncomputable def normSq (ψ : QSurreal) : ℝ* := ψ.sum (fun _ a => a ^ 2)

/-- The exact **Born weight** of the ket `|s⟩` in the state `ψ`, valued in the hyperreals. -/
noncomputable def bornProb (ψ : QSurreal) (s : Surreal.{0}) : ℝ* := (ψ s) ^ 2 / normSq ψ

/-- The **observed probability** of the ket `|s⟩`: the standard part of its Born weight. -/
noncomputable def observedProb (ψ : QSurreal) (s : Surreal.{0}) : ℝ := st (bornProb ψ s)

/-- **Born normalization in the non-Archimedean field.**  For any nonzero-weight state the exact
hyperreal Born weights over the support sum to `1`. -/
theorem bornProb_sum_eq_one (ψ : QSurreal) (h : normSq ψ ≠ 0) :
    ∑ s ∈ ψ.support, bornProb ψ s = 1 := by
  unfold bornProb
  rw [← Finset.sum_div, div_eq_one_iff_eq h]
  rfl

/-- **Unobservability of infinitesimal branches.**  If the amplitude on the ket `|s⟩` is
infinitesimal and the total weight `normSq ψ` is appreciable (not infinitesimal), then the
observed probability of `|s⟩` is exactly `0`: the infinitesimal branch is invisible. -/
theorem observedProb_infinitesimal_eq_zero (ψ : QSurreal) (s : Surreal.{0})
    (hs : Infinitesimal (ψ s)) (hnz : ¬ Infinitesimal (normSq ψ)) :
    observedProb ψ s = 0 := by
  unfold observedProb bornProb
  rw [div_eq_mul_inv]
  have hsq : Infinitesimal ((ψ s) ^ 2) := by rw [sq]; exact hs.mul hs
  have hinvfin : ¬ Hyperreal.Infinite (normSq ψ)⁻¹ := by
    intro hinf
    have h := infinitesimal_inv_of_infinite hinf
    rw [inv_inv] at h
    exact hnz h
  rw [st_mul hsq.not_infinite hinvfin, hsq.st_eq, zero_mul]

/-- The squared norm of a two-branch state `a|s⟩ + b|t⟩` (with `s ≠ t`) is `a² + b²`. -/
theorem normSq_pair (s t : Surreal.{0}) (a b : ℝ*) (hst : s ≠ t) :
    normSq (single s a + single t b) = a ^ 2 + b ^ 2 := by
  have hsub : (single s a + single t b).support ⊆ {s, t} := by
    apply Finsupp.support_add.trans
    apply Finset.union_subset
    · exact (Finsupp.support_single_subset).trans (by intro x hx; simp at hx; simp [hx])
    · exact (Finsupp.support_single_subset).trans (by intro x hx; simp at hx; simp [hx])
  unfold normSq
  rw [Finsupp.sum_of_support_subset _ hsub _ (by intro i _; simp)]
  rw [Finset.sum_pair hst]
  simp [hst, Ne.symm hst]

/-- The corrected worked example `|ψ⟩ = |0⟩ + ε|1⟩` with `ε` the canonical positive infinitesimal. -/
noncomputable def psiTest : QSurreal := single (0 : Surreal.{0}) 1 + single (1 : Surreal.{0}) ε

/-- **The ε-test.**  Measuring `|ψ⟩ = |0⟩ + ε|1⟩` yields the standard branch `|0⟩` with observed
probability `1` and the infinitesimal branch `|1⟩` with observed probability `0`. -/
theorem epsilon_test :
    observedProb psiTest 0 = 1 ∧ observedProb psiTest 1 = 0 := by
  have h01 : (0 : Surreal.{0}) ≠ 1 := by norm_num
  have hval0 : psiTest 0 = 1 := by unfold psiTest; simp
  have hval1 : psiTest 1 = ε := by unfold psiTest; simp
  have hnorm : normSq psiTest = 1 + ε ^ 2 := by
    unfold psiTest; rw [normSq_pair 0 1 1 ε h01]; ring
  have heps2 : Infinitesimal (ε ^ 2) := by
    rw [sq]; exact infinitesimal_epsilon.mul infinitesimal_epsilon
  have h1 : IsSt (1 : ℝ*) 1 := by simpa using isSt_refl_real 1
  have hst_norm : st (normSq psiTest) = 1 := by
    rw [hnorm]; simpa using (h1.add heps2).st_eq
  have hinvfin : ¬ Hyperreal.Infinite (normSq psiTest)⁻¹ := by
    intro hinf
    have h := infinitesimal_inv_of_infinite hinf
    rw [inv_inv] at h
    rw [h.st_eq] at hst_norm
    norm_num at hst_norm
  refine ⟨?_, ?_⟩
  · unfold observedProb bornProb
    rw [hval0, one_pow, div_eq_mul_inv, one_mul, st_inv, hst_norm, inv_one]
  · unfold observedProb bornProb
    rw [hval1, div_eq_mul_inv, st_mul heps2.not_infinite hinvfin, heps2.st_eq, zero_mul]

end QuantumSurreal