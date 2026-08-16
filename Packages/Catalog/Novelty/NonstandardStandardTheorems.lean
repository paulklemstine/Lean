/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Standard theorems with nonstandard proofs

The point of a non-Archimedean model is not only that classical theorems
survive inside it, but that reasoning inside it *proves* classical theorems.
This file gives two such proofs.

* `infinite_iff_exists_unlimited_mem` : a set of naturals is infinite iff its
  star-extension contains an unlimited element.  This is the nonstandard
  dictionary entry for infinitude.
* `infinite_pigeonhole` : if finitely many sets cover `ℕ`, one of them is
  infinite.  Proof: `ω` is unlimited and lands in one of the star-extensions,
  because an ultrafilter is constant on a finite partition.
* `exists_cluster_pt_of_bounded` : **Bolzano–Weierstrass** for real sequences.
  Proof: the value of the sequence at the nonstandard index `ω` is a finite
  hyperreal; its standard part is a cluster point of the sequence.

Both conclusions are ordinary statements about `ℕ` and `ℝ` — only the proofs
live in the nonstandard model.
-/

import Novelty.NonstandardConvergence
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-! ## Star extensions of standard sets -/

/-- The star-extension of an ordinary set of naturals: the constant internal
set. -/
def starSet (S : Set ℕ) : InternalSet := ((fun _ : ℕ => S : ℕ → Set ℕ) : InternalSet)

theorem mem_starSet_coe (S : Set ℕ) (f : ℕ → ℕ) :
    (f : HyperNat) ∈* starSet S ↔ ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i ∈ S :=
  internalMem_coe f _

/-- **The nonstandard criterion for infinitude.** -/
theorem infinite_iff_exists_unlimited_mem (S : Set ℕ) :
    S.Infinite ↔ ∃ H : HyperNat, IsUnlimited H ∧ H ∈* starSet S := by
  constructor
  · intro hS
    choose f hf1 hf2 using Set.Infinite.exists_gt hS
    refine ⟨(f : HyperNat), ?_, ?_⟩
    · rw [isUnlimited_coe]
      intro n
      filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
      have := hf2 i
      omega
    · rw [mem_starSet_coe]
      exact Filter.Eventually.of_forall hf1
  · rintro ⟨H, hU, hmem⟩
    refine Filter.Germ.inductionOn H (fun f hU hmem => ?_) hU hmem
    rw [isUnlimited_coe] at hU
    rw [mem_starSet_coe] at hmem
    intro hfin
    obtain ⟨N, hN⟩ := hfin.bddAbove
    have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
      filter_upwards [hmem, hU N] with i h1 h2
      exact absurd (hN h1) (by omega)
    rw [Filter.eventually_false_iff_eq_bot] at hfalse
    exact Filter.NeBot.ne inferInstance hfalse

/-- An ultrafilter is concentrated on a single value of any function into a
finite type. -/
theorem hyperfilter_eventually_const {β : Type*} [Finite β] (j : ℕ → β) :
    ∃ b : β, ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), j i = b := by
  obtain ⟨b, hb⟩ := Ultrafilter.eq_pure_of_finite (Ultrafilter.map j (hyperfilter ℕ))
  refine ⟨b, ?_⟩
  have hmem : {b} ∈ Ultrafilter.map j (hyperfilter ℕ) := by
    rw [hb]
    exact Filter.mem_pure.mpr rfl
  exact hmem

/-- **The infinite pigeonhole principle, proved nonstandardly.**  If finitely
many sets cover `ℕ` then one of them is infinite: the unlimited element `ω`
must belong to the star-extension of one of them. -/
theorem infinite_pigeonhole {k : ℕ} (S : Fin k → Set ℕ) (hcov : ∀ n : ℕ, ∃ j, n ∈ S j) :
    ∃ j : Fin k, (S j).Infinite := by
  choose j hj using hcov
  obtain ⟨b, hb⟩ := hyperfilter_eventually_const j
  refine ⟨b, ?_⟩
  rw [infinite_iff_exists_unlimited_mem]
  refine ⟨omega, isUnlimited_omega, ?_⟩
  show ((fun i : ℕ => i : ℕ → ℕ) : HyperNat) ∈* starSet (S b)
  rw [mem_starSet_coe]
  filter_upwards [hb] with i hi
  have := hj i
  rwa [hi] at this

/-! ## Bolzano–Weierstrass through the standard part map -/

/-- A bounded sequence has a finite value at the nonstandard index: the
hyperreal `ofSeq a` is not infinite. -/
theorem not_infinite_ofSeq_of_bounded {a : ℕ → ℝ} {C : ℝ} (hC : ∀ n, |a n| ≤ C) :
    ¬ Hyperreal.Infinite (Hyperreal.ofSeq a) := by
  rw [Hyperreal.not_infinite_iff_exist_lt_gt]
  refine ⟨-(C + 1), C + 1, ?_, ?_⟩
  · show Hyperreal.ofSeq (fun _ => -(C + 1)) < Hyperreal.ofSeq a
    rw [Hyperreal.ofSeq_lt_ofSeq]
    refine Filter.Eventually.of_forall (fun i => ?_)
    have := abs_le.mp (hC i)
    linarith [this.1]
  · show Hyperreal.ofSeq a < Hyperreal.ofSeq (fun _ => C + 1)
    rw [Hyperreal.ofSeq_lt_ofSeq]
    refine Filter.Eventually.of_forall (fun i => ?_)
    have := abs_le.mp (hC i)
    linarith [this.2]

/-- **Bolzano–Weierstrass, proved nonstandardly.**  Every bounded real sequence
has a cluster point, namely the standard part of its value at a nonstandard
index. -/
theorem exists_cluster_pt_of_bounded {a : ℕ → ℝ} {C : ℝ} (hC : ∀ n, |a n| ≤ C) :
    ∃ L : ℝ, ∀ ε > 0, ∀ N : ℕ, ∃ n ≥ N, |a n - L| < ε := by
  set L : ℝ := Hyperreal.st (Hyperreal.ofSeq a) with hL
  have hst : Hyperreal.IsSt (Hyperreal.ofSeq a) L :=
    Hyperreal.isSt_st' (not_infinite_ofSeq_of_bounded hC)
  refine ⟨L, ?_⟩
  intro ε hε N
  by_contra hc
  push_neg at hc
  -- the sequence stays `ε`-away from `L` from `N` on, hence also at the
  -- nonstandard index, contradicting the standard part property
  have hfar : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), ε ≤ |a i - L| :=
    Nat.hyperfilter_le_atTop (by
      filter_upwards [Filter.eventually_ge_atTop N] with i hi using hc i hi)
  obtain ⟨h1, h2⟩ := hst ε hε
  have e1 : ((L : ℝ*) - (ε : ℝ*)) = Hyperreal.ofSeq (fun _ => L - ε) := by
    rw [← Hyperreal.coe_sub]; rfl
  have e2 : ((L : ℝ*) + (ε : ℝ*)) = Hyperreal.ofSeq (fun _ => L + ε) := by
    rw [← Hyperreal.coe_add]; rfl
  rw [e1, Hyperreal.ofSeq_lt_ofSeq] at h1
  rw [e2, Hyperreal.ofSeq_lt_ofSeq] at h2
  have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
    filter_upwards [hfar, h1, h2] with i hi hi1 hi2
    have habs : |a i - L| < ε := abs_lt.mpr ⟨by linarith, by linarith⟩
    exact absurd hi (not_le.mpr habs)
  rw [Filter.eventually_false_iff_eq_bot] at hfalse
  exact Filter.NeBot.ne inferInstance hfalse

end NonstandardArithmetic