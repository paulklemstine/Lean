/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IV: average-case separation between source classes

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`NumberTheory.UniversalRedundancyAverage` builds the Bayes (average-case)
theory of universal coding: Gibbs' inequality, the compensation identity, the
redundancy ≥ capacity lower bound, the two-part-code upper bound, and the exact
value `log₂ #Θ` for mutually singular classes.  This file *instantiates* that
theory on the three classes of the catalog and extracts the answer to the
research question.

## Main results

* `klDiv_deltaClass` — the divergence of a point mass from a coding
  distribution is the code length it assigns to that message.
* `deterministic_average_price` — the class of deterministic sources costs
  exactly `log₂ #X` bits on average: no universal code can do better anywhere.
* `kraft_exists_long_codeword` — the pigeonhole bound recovered as a corollary:
  every Kraft-compliant code on `n`-bit files has a file needing `≥ n` bits.
* `iid_average_price_le`, `markov_average_price_le` — the memoryless and
  first-order Markov classes cost only `#A log₂ (n+1)` and
  `log₂ #A + #A² log₂ (n+1)` bits *on average*, for every parameter.
* `average_price_separation` — the two sides side by side on the same `n`-bit
  message space: `Θ(log n)` versus exactly `n`.
* `average_price_gap_tendsto_top` — the gap between the two prices diverges,
  so specialising the decompressor to a genuinely low-complexity class does
  move a growing number of bits out of the message.

## Application keywords

universal compression, minimax redundancy, Bayes redundancy, method of types,
Markov sources, price of universality, pigeonhole bound
-/

import Catalog.MachineLearning.UniversalRedundancy.Markov
import Catalog.NumberTheory.UniversalRedundancyAverage

open Finset Real

namespace UniversalRedundancy

/-! ## Deterministic sources: the average price is the full `log₂ #X` -/

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

omit [Nonempty X] in
/-- The Kullback–Leibler divergence of the point mass at `θ` from a coding
distribution `q` is exactly the ideal code length `log₂ (1 / q θ)`. -/
lemma klDiv_deltaClass (θ : X) (q : X → ℝ) :
    klDiv ((deltaClass X).prob θ) q = logb 2 (1 / q θ) := by
  unfold klDiv
  rw [Finset.sum_eq_single θ]
  · simp [deltaClass]
  · intro x _ hx
    simp [deltaClass, hx]
  · intro h
    exact absurd (Finset.mem_univ θ) h

/-- **The average-case price of universality of the deterministic class is
exactly `log₂ #X`.**  The uniform mixture attains it, and every strictly
positive coding sub-probability loses at least that much against some point
mass.  Specialising a decompressor to "all data" buys nothing. -/
theorem deterministic_average_price :
    (∀ θ : X, klDiv ((deltaClass X).prob θ)
        ((deltaClass X).mix (uniformPrior X)) ≤ logb 2 (Fintype.card X)) ∧
      (∀ q : X → ℝ, (∀ x, 0 < q x) → ∑ x, q x ≤ 1 →
        ∃ θ : X, logb 2 (Fintype.card X) ≤ klDiv ((deltaClass X).prob θ) q) := by
  refine (deltaClass X).singular_minimax_average_exact (fun θ => {θ}) ?_ ?_
  · intro θ θ' h
    simpa using h
  · intro θ
    simp [deltaClass]

/-- **Pigeonhole bound, recovered from the average-case theory.**  Every
Kraft-compliant code on `n`-bit files assigns at least `n` bits to some file. -/
theorem kraft_exists_long_codeword (n : ℕ) (ℓ : (Fin n → Bool) → ℕ)
    (hℓ : SourceClass.Kraft ℓ) : ∃ x : Fin n → Bool, (n : ℝ) ≤ (ℓ x : ℝ) := by
  classical
  set q : (Fin n → Bool) → ℝ := fun x => (2 : ℝ) ^ (-(ℓ x : ℤ)) with hq
  have hq0 : ∀ x, 0 < q x := fun x => by rw [hq]; positivity
  obtain ⟨θ, hθ⟩ := (deterministic_average_price (X := Fin n → Bool)).2 q hq0 hℓ
  refine ⟨θ, ?_⟩
  rw [klDiv_deltaClass] at hθ
  have hcard : logb 2 (Fintype.card (Fin n → Bool)) = (n : ℝ) := by
    have : (Fintype.card (Fin n → Bool) : ℝ) = (2 : ℝ) ^ n := by simp
    rw [this, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
    ring
  have hlen : logb 2 (1 / q θ) = (ℓ θ : ℝ) := by
    have hpow : (0 : ℝ) < (2 : ℝ) ^ (ℓ θ) := by positivity
    have h1 : 1 / q θ = (2 : ℝ) ^ (ℓ θ) := by
      rw [hq]
      simp [zpow_neg, zpow_natCast]
    rw [h1, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
    ring
  rw [hcard, hlen] at hθ
  exact hθ

/-! ## Parametric classes: the average price is logarithmic in the length -/

variable {A : Type*} [Fintype A] [DecidableEq A] [Nonempty A]

/-- **Memoryless sources, average case.**  The NML code of the i.i.d. class is
within `#A · log₂ (n+1)` bits of the code tailored to the true parameter, on
average, for *every* memoryless source. -/
theorem iid_average_price_le (n : ℕ) (θ : Simplex A) :
    klDiv ((iidClass A n).prob θ) (iidClass A n).nml
      ≤ (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
  have h1 := (iidClass A n).klDiv_nml_le_logb_shtarkovSum (maxLik_iidClass_pos n) θ
  have hC := shtarkovSum_iidClass_le (A := A) n
  have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
  rw [hbase] at hC
  have hle : logb 2 (iidClass A n).shtarkovSum
      ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A)) :=
    Real.logb_le_logb_of_le (by norm_num) (iidClass A n).shtarkovSum_pos hC
  rw [Real.logb_pow] at hle
  linarith

/-- **First-order Markov sources, average case.**  The NML code of the Markov
class is within `log₂ #A + #A² · log₂ (n+1)` bits of the code tailored to the
true chain, on average, for *every* chain. -/
theorem markov_average_price_le (n : ℕ) (θ : MarkovParam A) :
    klDiv ((markovClass A n).prob θ) (markovClass A n).nml
      ≤ logb 2 (Fintype.card A)
        + (Fintype.card A : ℝ) * (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
  have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  have h1 := (markovClass A n).klDiv_nml_le_logb_shtarkovSum (maxLik_markovClass_pos n) θ
  have hC := shtarkovSum_markovClass_le (A := A) n
  have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
  rw [hbase] at hC
  have hle : logb 2 (markovClass A n).shtarkovSum
      ≤ logb 2 ((Fintype.card A : ℝ) * ((n : ℝ) + 1) ^ (Fintype.card A * Fintype.card A)) :=
    Real.logb_le_logb_of_le (by norm_num) (markovClass A n).shtarkovSum_pos hC
  rw [Real.logb_mul (ne_of_gt hcard) (by positivity), Real.logb_pow] at hle
  push_cast at hle
  linarith

/-! ## The separation -/

/-- **Average-case separation of source classes.**  On the same space of
`n`-bit messages:

* the memoryless class costs at most `2 log₂ (n+1)` bits on average, for every
  parameter (the universal code is almost as good as the specialised one);
* the deterministic class costs exactly `n` bits — the whole message.

So the price of universality is governed by the *complexity of the class*, not
by the length of the data: moving bits from the message into a shared
decompressor is worthwhile exactly when the data class is genuinely
low-complexity. -/
theorem average_price_separation (n : ℕ) :
    (∀ θ : Simplex Bool, klDiv ((iidClass Bool n).prob θ) (iidClass Bool n).nml
        ≤ 2 * logb 2 ((n : ℝ) + 1)) ∧
      (∀ q : (Fin n → Bool) → ℝ, (∀ x, 0 < q x) → ∑ x, q x ≤ 1 →
        ∃ x : Fin n → Bool, (n : ℝ) ≤ klDiv ((deltaClass (Fin n → Bool)).prob x) q) := by
  constructor
  · intro θ
    have h := iid_average_price_le (A := Bool) n θ
    have hcard : (Fintype.card Bool : ℝ) = 2 := by simp
    rwa [hcard] at h
  · intro q hq0 hq1
    obtain ⟨x, hx⟩ := (deterministic_average_price (X := Fin n → Bool)).2 q hq0 hq1
    refine ⟨x, ?_⟩
    have hcard : logb 2 (Fintype.card (Fin n → Bool)) = (n : ℝ) := by
      have : (Fintype.card (Fin n → Bool) : ℝ) = (2 : ℝ) ^ n := by simp
      rw [this, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
      ring
    rwa [hcard] at hx

/-- **The separation grows without bound.**  The number of bits that a
decompressor specialised to the memoryless class saves over the universal
"all data" decompressor, `n - 2 log₂ (n+1)`, tends to infinity. -/
theorem average_price_gap_tendsto_top :
    Filter.Tendsto (fun n : ℕ => (n : ℝ) - 2 * logb 2 ((n : ℝ) + 1))
      Filter.atTop Filter.atTop := by
  have hfrac : Filter.Tendsto (fun n : ℕ => logb 2 ((n : ℝ) + 1) / (n : ℝ))
      Filter.atTop (nhds 0) := savings_fraction_tendsto_zero
  have hn : Filter.Tendsto (fun n : ℕ => (n : ℝ)) Filter.atTop Filter.atTop :=
    tendsto_natCast_atTop_atTop
  have hhalf : Filter.Tendsto (fun n : ℕ => 1 - 2 * (logb 2 ((n : ℝ) + 1) / (n : ℝ)))
      Filter.atTop (nhds 1) := by
    have := (hfrac.const_mul (2 : ℝ)).const_sub (1 : ℝ)
    simpa using this
  have hpos : Filter.Tendsto
      (fun n : ℕ => (n : ℝ) * (1 - 2 * (logb 2 ((n : ℝ) + 1) / (n : ℝ))))
      Filter.atTop Filter.atTop :=
    hn.atTop_mul_pos (by norm_num) hhalf
  refine hpos.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with n hn0
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn0
  field_simp

end UniversalRedundancy