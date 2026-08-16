/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A bridge between the ultrapower of `ℕ` and real analysis

The ultrapower `HyperNat` of `Novelty.NonstandardArithmetic` and Mathlib's
hyperreals `ℝ*` are built along the *same* ultrafilter, so a real sequence
`a : ℕ → ℝ` extends canonically to a map `starSeq a : HyperNat → ℝ*`.

This file proves Robinson's characterizations of limits, which convert
topological statements about `atTop` into purely algebraic statements about
values at unlimited (i.e. nonstandard) indices:

* `tendsto_iff_isSt` : `a` converges to `L` **iff** `starSeq a H` has standard
  part `L` for every unlimited hypernatural `H`;
* `tendsto_atTop_iff_infinitePos` : `a` diverges to `+∞` **iff** `starSeq a H`
  is positive infinite for every unlimited `H`;
* `alternating_not_convergent` : the criterion in action — the two unlimited
  hypernaturals `[2i]` and `[2i+1]` witness the divergence of `(-1)^n`.

These are genuine transfer results, not definitional unfoldings: the reverse
implications need a choice-based construction of an unlimited index at which
the sequence misbehaves.
-/

import Novelty.NonstandardInternalSets
import Mathlib.Analysis.Real.Hyperreal
import Mathlib.Tactic

open Filter Topology

namespace NonstandardArithmetic

/-- The nonstandard extension of a real sequence: a map from hypernaturals to
hyperreals, obtained by lifting `a` to germs along the same ultrafilter. -/
noncomputable def starSeq (a : ℕ → ℝ) (H : HyperNat) : ℝ* := Filter.Germ.map a H

@[simp] theorem starSeq_coe (a : ℕ → ℝ) (f : ℕ → ℕ) :
    starSeq a (f : HyperNat) = Hyperreal.ofSeq (a ∘ f) := rfl

/-- The extension agrees with `a` on standard indices. -/
theorem starSeq_standard (a : ℕ → ℝ) (n : ℕ) : starSeq a (standard n) = (a n : ℝ*) := rfl

/-- **Robinson's criterion for convergence.** A real sequence converges to `L`
exactly when its nonstandard extension has standard part `L` at *every*
unlimited hypernatural index. -/
theorem tendsto_iff_isSt (a : ℕ → ℝ) (L : ℝ) :
    Tendsto a atTop (𝓝 L) ↔ ∀ H : HyperNat, IsUnlimited H → Hyperreal.IsSt (starSeq a H) L := by
  constructor
  · intro h H hH
    refine Filter.Germ.inductionOn H (fun f hf => ?_) hH
    rw [starSeq_coe, Hyperreal.isSt_ofSeq_iff_tendsto, Metric.tendsto_nhds]
    intro ε hε
    obtain ⟨N, hN⟩ := Metric.tendsto_atTop.mp h ε hε
    rw [isUnlimited_coe] at hf
    filter_upwards [hf N] with i hi
    exact hN (f i) (le_of_lt hi)
  · intro h
    by_contra hnt
    rw [Metric.tendsto_atTop] at hnt
    push_neg at hnt
    obtain ⟨ε, hε, hbad⟩ := hnt
    choose f hf1 hf2 using hbad
    have hU : IsUnlimited (f : HyperNat) := by
      rw [isUnlimited_coe]
      intro n
      filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
      have := hf1 i
      omega
    have hst := h _ hU
    rw [starSeq_coe, Hyperreal.isSt_ofSeq_iff_tendsto, Metric.tendsto_nhds] at hst
    have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
      filter_upwards [hst ε hε] with i hi
      exact absurd hi (not_lt.mpr (hf2 i))
    rw [Filter.eventually_false_iff_eq_bot] at hfalse
    exact Filter.NeBot.ne inferInstance hfalse

/-- **Robinson's criterion for divergence to `+∞`.** -/
theorem tendsto_atTop_iff_infinitePos (a : ℕ → ℝ) :
    Tendsto a atTop atTop ↔
      ∀ H : HyperNat, IsUnlimited H → Hyperreal.InfinitePos (starSeq a H) := by
  constructor
  · intro h H hH
    refine Filter.Germ.inductionOn H (fun f hf => ?_) hH
    intro r
    rw [starSeq_coe]
    have hr : ((r : ℝ) : ℝ*) = Hyperreal.ofSeq (fun _ => r) := rfl
    rw [hr, Hyperreal.ofSeq_lt_ofSeq]
    obtain ⟨N, hN⟩ := (Filter.eventually_atTop.mp (Filter.tendsto_atTop.mp h (r + 1)))
    rw [isUnlimited_coe] at hf
    filter_upwards [hf N] with i hi
    have := hN (f i) (le_of_lt hi)
    simp only [Function.comp_apply]
    linarith
  · intro h
    by_contra hnt
    rw [Filter.tendsto_atTop] at hnt
    push_neg at hnt
    obtain ⟨b, hb⟩ := hnt
    rw [Filter.frequently_atTop] at hb
    choose f hf1 hf2 using hb
    have hU : IsUnlimited (f : HyperNat) := by
      rw [isUnlimited_coe]
      intro n
      filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
      have := hf1 i
      omega
    have hinf := h _ hU b
    rw [starSeq_coe] at hinf
    have hr : ((b : ℝ) : ℝ*) = Hyperreal.ofSeq (fun _ => b) := rfl
    rw [hr, Hyperreal.ofSeq_lt_ofSeq] at hinf
    have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
      filter_upwards [hinf] with i hi
      exact absurd hi (not_lt.mpr (le_of_lt (hf2 i)))
    rw [Filter.eventually_false_iff_eq_bot] at hfalse
    exact Filter.NeBot.ne inferInstance hfalse

/-- The doubling hypernatural `[2i]` is unlimited. -/
theorem isUnlimited_double : IsUnlimited ((fun i => 2 * i : ℕ → ℕ) : HyperNat) := by
  rw [isUnlimited_coe]
  intro n
  filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
  omega

/-- The odd hypernatural `[2i+1]` is unlimited. -/
theorem isUnlimited_double_succ : IsUnlimited ((fun i => 2 * i + 1 : ℕ → ℕ) : HyperNat) := by
  rw [isUnlimited_coe]
  intro n
  filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
  omega

/-- **The criterion in action.** The alternating sequence `(-1)^n` diverges,
because two unlimited hypernaturals assign it different standard parts. -/
theorem alternating_not_convergent :
    ¬ ∃ L : ℝ, Tendsto (fun n : ℕ => (-1 : ℝ) ^ n) atTop (𝓝 L) := by
  rintro ⟨L, hL⟩
  rw [tendsto_iff_isSt] at hL
  have h1 := hL _ isUnlimited_double
  have h2 := hL _ isUnlimited_double_succ
  rw [starSeq_coe, Hyperreal.isSt_ofSeq_iff_tendsto] at h1 h2
  have e1 : (fun n : ℕ => (-1 : ℝ) ^ n) ∘ (fun i => 2 * i) = fun _ : ℕ => (1 : ℝ) := by
    funext i
    simp [pow_mul]
  have e2 : (fun n : ℕ => (-1 : ℝ) ^ n) ∘ (fun i => 2 * i + 1) = fun _ : ℕ => (-1 : ℝ) := by
    funext i
    simp [pow_succ, pow_mul]
  rw [e1] at h1
  rw [e2] at h2
  have hL1 : L = 1 := tendsto_nhds_unique h1 tendsto_const_nhds
  have hL2 : L = -1 := tendsto_nhds_unique h2 tendsto_const_nhds
  rw [hL1] at hL2
  norm_num at hL2

end NonstandardArithmetic