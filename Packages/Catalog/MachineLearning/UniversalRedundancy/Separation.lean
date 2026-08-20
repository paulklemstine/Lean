/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VI: parametric versus unrestricted classes

Final instalment: the answer to the research question of Phase A / Question 1,
*is a specialised decompressor worth pursuing?*

## Central Idea

Two extreme classes on the same message space `Bits n = Fin n → Bool` of
`n`-bit files:

* the **memoryless class** (one unknown bias): the price of universality is
  sandwiched between `½ log₂ n − 2` and `log₂ (n+1)` bits
  (`bernoulli_price_sandwich`);
* the **deterministic class** `{δ_y}` — one source per file, the richest
  possible class, i.e. "a decompressor specialised to each individual file":
  here the price is exactly `n` bits (`price_deltaClass_bits`).

So the transfer of bits from the message into a shared decompressor is governed
entirely by the *complexity of the class*, not by the length of the data: a
`d`-parameter class moves `Θ(log n)` bits, while a class rich enough to name
every file moves nothing at all — the `n` bits that a specialised decompressor
saves on its own file are exactly the `n` bits the universal scheme must spend
to say which decompressor was used.

## Main Results

* `deltaClass` — the class of deterministic (point-mass) sources
* `shtarkovSum_deltaClass` — `Cₛ = #X` exactly
* `price_deltaClass_bits` — on `n`-bit files the price is exactly `n` bits
* `price_separation` — the separation: on the same message space, the
  memoryless class costs `≤ log₂ (n+1)` bits while the unrestricted
  deterministic class costs exactly `n` bits
* `savings_fraction_tendsto_zero` — the fraction of the message that a
  memoryless-specialised decompressor can absorb tends to `0`

## Application Keywords

class complexity, universal coding, specialised decompressor, pigeonhole bound,
minimax redundancy separation
-/

import MachineLearning.UniversalRedundancy.Bernoulli

open Finset Real

namespace UniversalRedundancy

/-- The class of deterministic sources: one point mass per message. -/
noncomputable def deltaClass (X : Type*) [Fintype X] [DecidableEq X] :
    SourceClass X X where
  prob θ x := if x = θ then 1 else 0
  nonneg θ x := by split <;> norm_num
  sum_one θ := by simp

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

lemma maxLik_deltaClass (x : X) : (deltaClass X).maxLik x = 1 := by
  refine le_antisymm ((deltaClass X).maxLik_le fun θ => (deltaClass X).prob_le_one θ x) ?_
  have h := (deltaClass X).le_maxLik x x
  simpa [deltaClass] using h

/-- **The deterministic class has maximal Shtarkov sum.**  Nothing at all can be
shared: `Cₛ = #X`. -/
theorem shtarkovSum_deltaClass : (deltaClass X).shtarkovSum = (Fintype.card X : ℝ) := by
  unfold SourceClass.shtarkovSum
  rw [Finset.sum_congr rfl fun x _ => maxLik_deltaClass x]
  simp

/-- On `n`-bit files, the price of universality of the deterministic class is
exactly `n` bits: the shared decompressor saves nothing. -/
theorem price_deltaClass_bits (n : ℕ) :
    logb 2 (deltaClass (Fin n → Bool)).shtarkovSum = (n : ℝ) := by
  rw [shtarkovSum_deltaClass]
  have hcard : (Fintype.card (Fin n → Bool) : ℝ) = (2 : ℝ) ^ n := by
    simp
  rw [hcard, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-- **Separation.**  On the same `n`-bit message space the memoryless class
costs at most `log₂ (n+1)` bits of universality, while the deterministic class
costs exactly `n` bits.  Specialising the decompressor is worthwhile only to the
extent that the data class is genuinely low-complexity. -/
theorem price_separation (n : ℕ) (hn : 2 ≤ n) :
    logb 2 (iidClass Bool n).shtarkovSum ≤ logb 2 ((n : ℝ) + 1) ∧
      logb 2 (deltaClass (Fin n → Bool)).shtarkovSum = (n : ℝ) ∧
      (1 / 2) * logb 2 n - 2 ≤ logb 2 (iidClass Bool n).shtarkovSum :=
  ⟨(bernoulli_price_sandwich n hn).2, price_deltaClass_bits n,
    (bernoulli_price_sandwich n hn).1⟩

/-- **The savings fraction vanishes.**  The share of an `n`-bit message that a
memoryless-specialised decompressor can absorb, `log₂(n+1)/n`, tends to `0`. -/
theorem savings_fraction_tendsto_zero :
    Filter.Tendsto (fun n : ℕ => logb 2 ((n : ℝ) + 1) / (n : ℝ)) Filter.atTop (nhds 0) := by
  have h := redundancy_rate_tendsto_zero 1
  have hinv : Filter.Tendsto (fun n : ℕ => 1 / (n : ℝ)) Filter.atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hsub := h.sub hinv
  rw [sub_zero] at hsub
  refine hsub.congr fun n => ?_
  rcases Nat.eq_zero_or_pos n with rfl | hpos
  · simp
  · have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hpos
    field_simp
    ring

end UniversalRedundancy