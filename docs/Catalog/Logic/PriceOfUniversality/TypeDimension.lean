/-
# The Price of Universality V: the exact Rissanen dimension of the type bound

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`MachineLearning.UniversalRedundancy.Types` bounds the Shtarkov sum of the
memoryless class over an alphabet `A` by `(n+1) ^ #A`, i.e. the price of
universality by `#A · log₂ (n+1)` bits.  Rissanen's asymptotics say the true
rate is `(d/2) · log₂ n` with `d = #A − 1` the *dimension of the parameter
space* — one less than the alphabet size, because the parameters of a
probability vector satisfy one linear constraint.

This file removes the spurious dimension: the letter counts of a message of
length `n` are determined by all but one of them, so the type statistic really
has only `(n+1) ^ (#A − 1)` values.  The resulting bound

`log₂ Cₛ ≤ (#A − 1) · log₂ (n + 1)`

matches the Rissanen dimension `d = #A − 1` exactly (and the rate up to the
constant factor `2`).  For a binary alphabet it reproduces the sharp
`log₂ (n+1)` of `MachineLearning.UniversalRedundancy.Bernoulli`, but now for
every alphabet.

## Main results

* `sum_countStat` — the letter counts of a word of length `m` sum to `m`
* `shtarkovSum_iidClass_le_dim` — `Cₛ ≤ (n+1) ^ (#A − 1)`
* `iid_price_le_dim_bits` — bit form of the same bound
* `iid_price_dimension_sandwich` — combined with the packing bound of
  `Logic.PriceOfUniversality.Packing`: `log₂ #A ≤ log₂ Cₛ ≤ (#A − 1) log₂ (n+1)`

## Application keywords

method of types, Rissanen redundancy, parameter dimension, sufficient
statistic, universal coding
-/

import Logic.PriceOfUniversality.Packing

open Finset Real

namespace UniversalRedundancy

/-- The letter counts of a word of length `m` sum to `m`. -/
lemma sum_countStat {B : Type*} [Fintype B] [DecidableEq B] {m : ℕ} (w : Fin m → B) :
    ∑ b, ((countStat w b : Fin (m + 1)) : ℕ) = m := by
  classical
  have h := Finset.card_eq_sum_card_fiberwise
    (f := w) (s := (univ : Finset (Fin m))) (t := (univ : Finset B))
    (fun j _ => Finset.mem_univ _)
  simpa [countStat] using h.symm

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- Two words with the same counts on every letter except one have the same
counts, period: the missing count is recovered from the total length. -/
lemma countStat_eq_of_eq_off {n : ℕ} (a₀ : A) (x y : Fin n → A)
    (h : ∀ b : A, b ≠ a₀ → countStat x b = countStat y b) :
    countStat x = countStat y := by
  classical
  funext b
  by_cases hb : b = a₀
  · subst hb
    refine Fin.ext ?_
    have hx := sum_countStat x
    have hy := sum_countStat y
    have hxe : ((countStat x b : Fin (n + 1)) : ℕ)
        + ∑ c ∈ univ.erase b, ((countStat x c : Fin (n + 1)) : ℕ) = n := by
      rw [Finset.add_sum_erase (univ : Finset A)
        (fun c => ((countStat x c : Fin (n + 1)) : ℕ)) (Finset.mem_univ b)]
      exact hx
    have hye : ((countStat y b : Fin (n + 1)) : ℕ)
        + ∑ c ∈ univ.erase b, ((countStat y c : Fin (n + 1)) : ℕ) = n := by
      rw [Finset.add_sum_erase (univ : Finset A)
        (fun c => ((countStat y c : Fin (n + 1)) : ℕ)) (Finset.mem_univ b)]
      exact hy
    have hsum : ∑ c ∈ univ.erase b, ((countStat x c : Fin (n + 1)) : ℕ)
        = ∑ c ∈ univ.erase b, ((countStat y c : Fin (n + 1)) : ℕ) :=
      Finset.sum_congr rfl fun c hc => by
        rw [h c (Finset.mem_erase.mp hc).1]
    omega
  · exact h b hb

/-- **The type bound at the right dimension.**  The Shtarkov sum of the
memoryless class over the alphabet `A` on messages of length `n` is at most
`(n+1) ^ (#A − 1)`: the parameter dimension, not the alphabet size, is what the
universal code must pay for. -/
theorem shtarkovSum_iidClass_le_dim [Nonempty A] (n : ℕ) :
    (iidClass A n).shtarkovSum ≤ ((n : ℝ) + 1) ^ (Fintype.card A - 1) := by
  classical
  set a₀ : A := Classical.arbitrary A with ha₀
  have hstat := (iidClass A n).shtarkovSum_le_card_statistic
    (σ := {a : A // a ≠ a₀} → Fin (n + 1))
    (T := fun x b => countStat x b.1) ?_
  · refine hstat.trans (le_of_eq ?_)
    rw [Fintype.card_fun]
    have hcard : Fintype.card {a : A // a ≠ a₀} = Fintype.card A - 1 := by
      simp [Fintype.card_subtype_compl (p := fun b : A => b = a₀)]
    rw [hcard, Fintype.card_fin]
    push_cast
    ring
  · intro θ x y hxy
    have hcount : countStat x = countStat y :=
      countStat_eq_of_eq_off a₀ x y fun b hb => congrFun hxy ⟨b, hb⟩
    show (∏ i, θ.1 (x i)) = ∏ i, θ.1 (y i)
    rw [prod_eq_prod_pow_countStat (g := fun a : A => θ.1 a) (w := x),
      prod_eq_prod_pow_countStat (g := fun a : A => θ.1 a) (w := y), hcount]

/-- **The price of universality for memoryless sources, in bits, at the Rissanen
dimension.**  A single universal code pays at most `(#A − 1) · log₂ (n+1)` bits
against the best code for the true memoryless source. -/
theorem iid_price_le_dim_bits [Nonempty A] (n : ℕ) :
    logb 2 (iidClass A n).shtarkovSum
      ≤ ((Fintype.card A : ℝ) - 1) * logb 2 ((n : ℝ) + 1) := by
  have hC := shtarkovSum_iidClass_le_dim (A := A) n
  have hle : logb 2 (iidClass A n).shtarkovSum
      ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A - 1)) :=
    Real.logb_le_logb_of_le (by norm_num) (iidClass A n).shtarkovSum_pos hC
  rw [Real.logb_pow] at hle
  have hcard : ((Fintype.card A - 1 : ℕ) : ℝ) = (Fintype.card A : ℝ) - 1 := by
    have : 1 ≤ Fintype.card A := Fintype.card_pos
    push_cast [Nat.cast_sub this]
    ring
  rwa [hcard] at hle

/-- **Dimension sandwich.**  For every alphabet and every `n ≥ 1` the minimax
price of universality of the memoryless class satisfies

`log₂ #A ≤ log₂ Cₛ ≤ (#A − 1) · log₂ (n + 1)`.

The upper bound has exactly the Rissanen parameter dimension `d = #A − 1`; the
lower bound shows the price never drops to zero. -/
theorem iid_price_dimension_sandwich [Nonempty A] (n : ℕ) (hn : 1 ≤ n) :
    logb 2 (Fintype.card A : ℝ) ≤ logb 2 (iidClass A n).shtarkovSum ∧
      logb 2 (iidClass A n).shtarkovSum
        ≤ ((Fintype.card A : ℝ) - 1) * logb 2 ((n : ℝ) + 1) :=
  ⟨(iid_price_two_sided n hn).1, iid_price_le_dim_bits n⟩

end UniversalRedundancy