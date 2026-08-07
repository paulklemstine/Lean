/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.NeuralCoding

/-!
# Information per expected spike: nonuniform concepts and neuron-dependent costs

`Catalog/Novelty/NeuralCoding.lean` compares *dense* and *one-hot* codes under a
uniform concept distribution and a uniform cost of one unit of energy per spike.
This file removes both restrictions.

## Model

Concepts are drawn from a finite set `α` with an arbitrary strictly positive
distribution `w`.  Each neuron `i` has its own metabolic cost `cst i > 0` per
spike, so a pattern `x : NeuralCode N` costs `energyCost cst x = ∑_{i active} cst i`.
An encoder is an injection `enc : α → NeuralCode N`.

## Results

1. `gibbs_le` — Gibbs' inequality (`∑ w log (1/w) ≤ ∑ w log (1/q)` for a
   sub-probability `q`), proved from `log t ≤ t - 1`.
2. `partition_eq_prod` — the **energy partition function factorises**:
   `∑_x exp (-β * energyCost cst x) = ∏_i (1 + exp (-β * cst i))`.
3. `entropy_le_energy_bound` — **the rate/energy trade-off.**  For every
   inverse temperature `β > 0`,
   `H(w) ≤ β * E[cost] + ∑_i log (1 + exp (-β * cst i))`,
   with `E[cost]` the expected metabolic cost per concept.  Optimising over `β`
   gives the best information-per-spike bound available for the given cost
   profile.
4. `entropy_le_expected_spikes` — the uniform-cost corollary: with unit cost per
   spike, `H(w) ≤ E[spikes] * log (N + 1) + 1` nats, i.e. a neural population
   transmits at most `log (N+1)` nats per spike plus one nat of overhead.
-/

open Finset NeuralCoding

namespace Catalog.Probability.NeuralCoding.Energy

/-- The metabolic cost of an activity pattern when neuron `i` costs `cst i` per
spike. -/
noncomputable def energyCost {N : ℕ} (cst : Fin N → ℝ) (x : NeuralCode N) : ℝ :=
  ∑ i ∈ active x, cst i

/-- With unit costs the metabolic cost is the spike count (`weight`). -/
theorem energyCost_one {N : ℕ} (x : NeuralCode N) :
    energyCost (fun _ => (1 : ℝ)) x = weight x := by
  simp [energyCost, weight]

/-- **Gibbs' inequality.**  If `w` is a strictly positive probability vector and
`q` a strictly positive sub-probability vector on a finite set, the entropy of
`w` is at most its cross-entropy with `q`. -/
theorem gibbs_le {α : Type*} [Fintype α] (w q : α → ℝ) (hw : ∀ a, 0 < w a)
    (hq : ∀ a, 0 < q a) (hw1 : ∑ a, w a = 1) (hq1 : ∑ a, q a ≤ 1) :
    ∑ a, w a * Real.log (1 / w a) ≤ ∑ a, w a * Real.log (1 / q a) := by
  have hkey : ∑ a, w a * Real.log (q a / w a) ≤ 0 := by
    have hstep : ∀ a ∈ (univ : Finset α),
        w a * Real.log (q a / w a) ≤ q a - w a := by
      intro a _
      have hpos : 0 < q a / w a := div_pos (hq a) (hw a)
      have hlog : Real.log (q a / w a) ≤ q a / w a - 1 :=
        Real.log_le_sub_one_of_pos hpos
      have hmul := mul_le_mul_of_nonneg_left hlog (hw a).le
      have hwne : w a ≠ 0 := (hw a).ne'
      have hcancel : w a * (q a / w a - 1) = q a - w a := by
        field_simp
      linarith [hmul, hcancel.le, hcancel.ge]
    calc ∑ a, w a * Real.log (q a / w a) ≤ ∑ a, (q a - w a) := Finset.sum_le_sum hstep
      _ = (∑ a, q a) - ∑ a, w a := by rw [Finset.sum_sub_distrib]
      _ ≤ 0 := by rw [hw1]; linarith
  have hsplit : ∀ a, w a * Real.log (q a / w a)
      = w a * Real.log (1 / w a) - w a * Real.log (1 / q a) := by
    intro a
    have h1 : Real.log (q a / w a) = Real.log (q a) - Real.log (w a) :=
      Real.log_div (hq a).ne' (hw a).ne'
    have h2 : Real.log (1 / w a) = -Real.log (w a) := by
      rw [one_div, Real.log_inv]
    have h3 : Real.log (1 / q a) = -Real.log (q a) := by
      rw [one_div, Real.log_inv]
    rw [h1, h2, h3]; ring
  rw [Finset.sum_congr rfl (fun a _ => hsplit a), Finset.sum_sub_distrib] at hkey
  linarith

/-- **The energy partition function factorises over neurons.** -/
theorem partition_eq_prod {N : ℕ} (beta : ℝ) (cst : Fin N → ℝ) :
    ∑ x : NeuralCode N, Real.exp (-beta * energyCost cst x)
      = ∏ i, (1 + Real.exp (-beta * cst i)) := by
  classical
  have hterm : ∀ x : NeuralCode N,
      Real.exp (-beta * energyCost cst x)
        = ∏ i, (if x i = true then Real.exp (-beta * cst i) else 1) := by
    intro x
    have hsum : -beta * energyCost cst x
        = ∑ i, (if x i = true then -beta * cst i else 0) := by
      rw [energyCost, Finset.mul_sum, active, Finset.sum_filter]
    rw [hsum, Real.exp_sum]
    exact Finset.prod_congr rfl (fun i _ => by by_cases h : x i = true <;> simp [h])
  have hfac : ∀ i : Fin N, (1 + Real.exp (-beta * cst i))
      = ∑ b : Bool, (if b = true then Real.exp (-beta * cst i) else 1) := by
    intro i; simp [add_comm]
  rw [Finset.sum_congr rfl (fun x _ => hterm x),
    Finset.prod_congr rfl (fun i _ => hfac i), ← Fintype.piFinset_univ,
    Finset.prod_univ_sum]

/-- **The rate/energy trade-off with neuron-dependent costs.**  For any strictly
positive concept distribution `w`, any injective encoder and any inverse
temperature `β`, the entropy of the concept distribution is bounded by the
expected metabolic cost times `β` plus the free energy of the population. -/
theorem entropy_le_energy_bound {N : ℕ} {α : Type*} [Fintype α] (w : α → ℝ)
    (hw : ∀ a, 0 < w a) (hw1 : ∑ a, w a = 1) (cst : Fin N → ℝ) (beta : ℝ)
    (enc : α → NeuralCode N) (hinj : Function.Injective enc) :
    ∑ a, w a * Real.log (1 / w a) ≤
      beta * (∑ a, w a * energyCost cst (enc a)) +
        Real.log (∏ i, (1 + Real.exp (-beta * cst i))) := by
  classical
  set Z : ℝ := ∑ x : NeuralCode N, Real.exp (-beta * energyCost cst x) with hZ
  have hZpos : 0 < Z := by
    rw [hZ]
    apply Finset.sum_pos (fun x _ => Real.exp_pos _)
    exact ⟨fun _ => false, Finset.mem_univ _⟩
  set q : α → ℝ := fun a => Real.exp (-beta * energyCost cst (enc a)) / Z with hq
  have hqpos : ∀ a, 0 < q a := fun a => div_pos (Real.exp_pos _) hZpos
  have hqsum : ∑ a, q a ≤ 1 := by
    have himg : ∑ a, Real.exp (-beta * energyCost cst (enc a))
        = ∑ x ∈ Finset.image enc univ, Real.exp (-beta * energyCost cst x) := by
      rw [Finset.sum_image (fun a _ b _ h => hinj h)]
    have hle : ∑ x ∈ Finset.image enc univ, Real.exp (-beta * energyCost cst x) ≤ Z := by
      rw [hZ]
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun x _ _ => (Real.exp_pos _).le)
    have : ∑ a, q a = (∑ a, Real.exp (-beta * energyCost cst (enc a))) / Z := by
      rw [hq, Finset.sum_div]
    rw [this, div_le_one hZpos, himg]
    exact hle
  have hgibbs := gibbs_le w q hw hqpos hw1 hqsum
  have hcross : ∀ a, w a * Real.log (1 / q a)
      = w a * (beta * energyCost cst (enc a)) + w a * Real.log Z := by
    intro a
    have hlog : Real.log (1 / q a) = beta * energyCost cst (enc a) + Real.log Z := by
      rw [hq]
      simp only [one_div]
      rw [inv_div, Real.log_div hZpos.ne' (Real.exp_ne_zero _), Real.log_exp]
      ring
    rw [hlog]; ring
  rw [Finset.sum_congr rfl (fun a _ => hcross a), Finset.sum_add_distrib] at hgibbs
  have hZeq : Z = ∏ i, (1 + Real.exp (-beta * cst i)) := partition_eq_prod beta cst
  have hlast : ∑ a, w a * Real.log Z = Real.log Z := by
    rw [← Finset.sum_mul, hw1, one_mul]
  rw [hlast, hZeq] at hgibbs
  calc ∑ a, w a * Real.log (1 / w a)
      ≤ (∑ a, w a * (beta * energyCost cst (enc a)))
        + Real.log (∏ i, (1 + Real.exp (-beta * cst i))) := hgibbs
    _ = beta * (∑ a, w a * energyCost cst (enc a))
        + Real.log (∏ i, (1 + Real.exp (-beta * cst i))) := by
          rw [Finset.mul_sum]
          congr 1
          exact Finset.sum_congr rfl (fun a _ => by ring)

/-- **Information per expected spike.**  With unit cost per spike, the entropy of
the concept distribution is at most `E[spikes] * log (N + 1) + 1` nats: a
population of `N` neurons carries at most `log (N + 1)` nats per spike, plus one
nat of overhead, whatever the concept distribution and encoder. -/
theorem entropy_le_expected_spikes {N : ℕ} {α : Type*} [Fintype α] (w : α → ℝ)
    (hw : ∀ a, 0 < w a) (hw1 : ∑ a, w a = 1)
    (enc : α → NeuralCode N) (hinj : Function.Injective enc) :
    ∑ a, w a * Real.log (1 / w a) ≤
      (∑ a, w a * (weight (enc a) : ℝ)) * Real.log (N + 1) + 1 := by
  classical
  set beta : ℝ := Real.log (N + 1) with hbeta
  have hbase := entropy_le_energy_bound w hw hw1 (fun _ => (1 : ℝ)) beta enc hinj
  have hcost : ∀ a, energyCost (fun _ => (1 : ℝ)) (enc a) = (weight (enc a) : ℝ) :=
    fun a => energyCost_one (enc a)
  -- the free energy of the uniform-cost population is at most one nat
  have hexp : Real.exp (-beta * 1) = 1 / (N + 1) := by
    have hN : (0 : ℝ) < (N : ℝ) + 1 := by positivity
    rw [mul_one, Real.exp_neg, hbeta, Real.exp_log hN, one_div]
  have hfree : Real.log (∏ _i : Fin N, (1 + Real.exp (-beta * 1))) ≤ 1 := by
    have hN : (0 : ℝ) < (N : ℝ) + 1 := by positivity
    rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin, hexp, Real.log_pow]
    have hlog : Real.log (1 + 1 / ((N : ℝ) + 1)) ≤ 1 / ((N : ℝ) + 1) := by
      have h := Real.log_le_sub_one_of_pos (x := 1 + 1 / ((N : ℝ) + 1)) (by positivity)
      simpa using h
    have hmul : (N : ℝ) * Real.log (1 + 1 / ((N : ℝ) + 1)) ≤ (N : ℝ) * (1 / ((N : ℝ) + 1)) :=
      mul_le_mul_of_nonneg_left hlog (Nat.cast_nonneg N)
    have hfrac : (N : ℝ) * (1 / ((N : ℝ) + 1)) ≤ 1 := by
      rw [mul_one_div, div_le_one hN]
      linarith
    linarith
  have hrewrite : ∑ a, w a * energyCost (fun _ => (1 : ℝ)) (enc a)
      = ∑ a, w a * (weight (enc a) : ℝ) :=
    Finset.sum_congr rfl (fun a _ => by rw [hcost a])
  rw [hrewrite] at hbase
  calc ∑ a, w a * Real.log (1 / w a)
      ≤ beta * (∑ a, w a * (weight (enc a) : ℝ))
        + Real.log (∏ _i : Fin N, (1 + Real.exp (-beta * 1))) := hbase
    _ ≤ beta * (∑ a, w a * (weight (enc a) : ℝ)) + 1 := by linarith
    _ = (∑ a, w a * (weight (enc a) : ℝ)) * Real.log (N + 1) + 1 := by
        rw [hbeta]; ring

end Catalog.Probability.NeuralCoding.Energy