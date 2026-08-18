/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VII: constant-composition sources — an exactly solvable class

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

For the memoryless class the catalog gives the two-sided estimate
`½ log₂ n - 2 ≤ price ≤ log₂ (n+1)` (`bernoulli_price_sandwich`), of Rissanen
type but with a constant gap.  Here we exhibit a *natural* class of sources on
`n`-bit strings whose price of universality is known **exactly**, and is of the
same `Θ(log n)` order: the **constant-composition** (type-uniform) sources, the
source `P_j` being uniform on the strings with exactly `j` ones.  These are the
conditional laws of any memoryless source given its empirical type, and they are
the sources that method-of-types codes actually model.

Because distinct compositions have disjoint supports, the exact results of the
average-case theory apply verbatim and give

`price(compositionClass n) = log₂ (n+1)` — worst case *and* on average,

so the logarithmic Rissanen rate is not an artefact of the upper-bound
technique: it is attained on the nose by a natural class.  Moreover the
conservation law of `NumberTheory.UniversalRedundancyConservation` becomes the
familiar two-part code accounting `log₂ C(n,j) + log₂ (n+1)`: the universal code
must spend the entropy of the type *plus* the description of the type.

## Main results

* `compositionClass` — the class of constant-composition sources;
* `compositionClass_price_exact` — average-case price exactly `log₂ (n+1)`;
* `shtarkovSum_compositionClass` — worst-case Shtarkov sum exactly `n+1`;
* `compositionClass_conservation` — for every Kraft code some composition costs
  at least `log₂ C(n,j) + log₂ (n+1)` bits on average;
* `composition_price_is_logarithmic` — the price is `Θ(log n)`, matching the
  memoryless upper bound up to a factor `2`.

## Application keywords

method of types, constant composition, universal compression, minimax
redundancy, Rissanen rate, price of universality
-/

import MachineLearning.UniversalRedundancy.Bernoulli
import NumberTheory.UniversalRedundancyConservation

open Finset Real

namespace UniversalRedundancy

variable {n : ℕ}

/-- The composition (type) of a binary string, as an element of `Fin (n+1)`. -/
def typeStat (n : ℕ) (x : Fin n → Bool) : Fin (n + 1) :=
  ⟨ones x, Nat.lt_succ_of_le (ones_le x)⟩

lemma typeStat_fiber_eq (n : ℕ) (c : Fin (n + 1)) :
    (univ.filter (fun y : Fin n → Bool => typeStat n y = c))
      = univ.filter (fun y : Fin n → Bool => ones y = (c : ℕ)) := by
  refine Finset.filter_congr fun y _ => ?_
  constructor
  · intro h
    exact congrArg Fin.val h
  · intro h
    exact Fin.ext h

lemma card_typeStat_fiber (n : ℕ) (c : Fin (n + 1)) :
    (univ.filter (fun y : Fin n → Bool => typeStat n y = c)).card = n.choose (c : ℕ) := by
  rw [typeStat_fiber_eq, card_ones_fiber]

lemma typeStat_fiber_nonempty (n : ℕ) (c : Fin (n + 1)) :
    (univ.filter (fun y : Fin n → Bool => typeStat n y = c)).Nonempty := by
  have hpos : 0 < n.choose (c : ℕ) := Nat.choose_pos (Nat.lt_succ_iff.mp c.isLt)
  rw [← Finset.card_pos, card_typeStat_fiber]
  exact hpos

/-- The class of **constant-composition sources** on `n`-bit strings: the source
of type `j` is uniform on the strings with exactly `j` ones. -/
noncomputable def compositionClass (n : ℕ) : SourceClass (Fin n → Bool) (Fin (n + 1)) :=
  fiberClass (typeStat n) (typeStat_fiber_nonempty n)

/-- **The average-case price of universality of the constant-composition class
is exactly `log₂ (n+1)`.** -/
theorem compositionClass_price_exact (n : ℕ) :
    (∀ c : Fin (n + 1), klDiv ((compositionClass n).prob c)
        ((compositionClass n).mix (uniformPrior (Fin (n + 1)))) ≤ logb 2 ((n : ℝ) + 1)) ∧
      (∀ q : (Fin n → Bool) → ℝ, (∀ x, 0 < q x) → ∑ x, q x ≤ 1 →
        ∃ c : Fin (n + 1), logb 2 ((n : ℝ) + 1) ≤ klDiv ((compositionClass n).prob c) q) := by
  have h := fiberClass_price_exact (typeStat n) (typeStat_fiber_nonempty n)
  have hcard : ((Fintype.card (Fin (n + 1)) : ℕ) : ℝ) = (n : ℝ) + 1 := by
    simp
  rw [hcard] at h
  exact h

/-- **The worst-case (Shtarkov) price is also exactly `log₂ (n+1)`**: for a
mutually singular class the worst-case and average-case prices coincide. -/
theorem shtarkovSum_compositionClass (n : ℕ) :
    (compositionClass n).shtarkovSum = (n : ℝ) + 1 := by
  have h := (compositionClass n).shtarkovSum_eq_card_of_disjoint_supports
    (fun c => univ.filter (fun y : Fin n → Bool => typeStat n y = c))
    (fiberClass_disjoint (typeStat n))
    (fiberClass_mass (typeStat n) (typeStat_fiber_nonempty n))
  rw [h]
  simp

/-- **Conservation of bits for types.**  Every Kraft-compliant code has a
composition `j` on which it spends, on average, at least the entropy
`log₂ C(n,j)` of that composition *plus* the `log₂ (n+1)` bits that name the
composition: the classical two-part code accounting is optimal. -/
theorem compositionClass_conservation (n : ℕ) (ℓ : (Fin n → Bool) → ℕ)
    (hℓ : SourceClass.Kraft ℓ) :
    ∃ c : Fin (n + 1), logb 2 (n.choose (c : ℕ)) + logb 2 ((n : ℝ) + 1)
      ≤ avgLen ((compositionClass n).prob c) (fun x => (ℓ x : ℝ)) := by
  obtain ⟨c, hc⟩ := fiberClass_conservation (typeStat n) (typeStat_fiber_nonempty n) ℓ hℓ
  refine ⟨c, ?_⟩
  rw [card_typeStat_fiber] at hc
  have hcard : ((Fintype.card (Fin (n + 1)) : ℕ) : ℝ) = (n : ℝ) + 1 := by
    simp
  rw [hcard] at hc
  exact hc

/-- **The price of the constant-composition class is genuinely logarithmic.**
It is at least `log₂ n` and at most `log₂ n + 1` bits for `n ≥ 1`, so the
`Θ(log n)` Rissanen rate of the memoryless upper bounds is attained exactly by a
natural class of sources: universality over a class of parametric complexity
`Θ(n)` costs `Θ(log n)` bits, not `Θ(n)`. -/
theorem composition_price_is_logarithmic (n : ℕ) (hn : 1 ≤ n) :
    logb 2 n ≤ logb 2 (compositionClass n).shtarkovSum ∧
      logb 2 (compositionClass n).shtarkovSum ≤ logb 2 n + 1 := by
  have hn' : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  rw [shtarkovSum_compositionClass]
  constructor
  · exact Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  · have h2 : logb 2 ((n : ℝ) + 1) ≤ logb 2 (2 * (n : ℝ)) :=
      Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
    rw [Real.logb_mul (by norm_num) (by linarith), Real.logb_self_eq_one (by norm_num)] at h2
    linarith

end UniversalRedundancy