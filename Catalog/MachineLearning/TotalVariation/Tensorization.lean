/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharp `n`-sample amplification: `d_TV(p^{⊗n}, q^{⊗n}) ≤ 1 − (1 − d_TV)^n`

`Testing` derived the textbook hybrid bound `d_TV(p^{⊗n}, q^{⊗n}) ≤ n·d_TV(p, q)`.
That bound is *vacuous* as soon as `n ≥ 1/d_TV`: it exceeds `1`, while total
variation never does.  This file replaces it by the sharp geometric law

`d_TV(p^{⊗n}, q^{⊗n}) ≤ 1 − (1 − d_TV(p, q))^n`,

which stays inside `[0, 1]` for every `n`, is strictly stronger than the linear
bound for all `n ≥ 2` (`one_sub_pow_lt_nsmul`), and has the right asymptotics:
`n` samples buy an advantage `1 − e^{−n d_TV}`, not `n d_TV`.

The proof is a genuine *transport* argument and is only available because
`Coupling` supplied the maximal coupling: couple each of the `n` coordinates
maximally and independently.  The resulting product coupling agrees in every
coordinate with probability exactly `(1 − d_TV)^n`, and `tvDist_le_disagreeProb`
converts that into the bound.  Neither the `ℓ¹` estimate nor the event
supremum alone can see this.

## Main results

* `powCoupling`, `isCoupling_powCoupling` — independent product of couplings;
* `sum_diag_powCoupling` — its agreement probability is the `n`-th power;
* `tvDist_powLaw_le_one_sub_pow` — the sharp amplification law;
* `tvDist_powLaw_le_one` — `n` samples never distinguish perfectly unless one
  sample already does;
* `one_sub_pow_le_nsmul`, `one_sub_pow_lt_nsmul` — the new bound dominates the
  hybrid bound, strictly for `n ≥ 2`.

## Application keywords

tensorization, hybrid argument, maximal coupling, sample complexity,
amplification, indistinguishability
-/

import MachineLearning.TotalVariation.Coupling
import MachineLearning.TotalVariation.Testing

open Finset

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## Independent products of couplings -/

/-- Couple `n` independent copies by using the coupling `c` in each coordinate,
independently. -/
def powCoupling (c : X → X → ℝ) (n : ℕ) : (Fin n → X) → (Fin n → X) → ℝ :=
  fun v w => ∏ i, c (v i) (w i)

omit [DecidableEq X] in
/-- The independent product of couplings couples the product laws. -/
theorem isCoupling_powCoupling {p q : X → ℝ} {c : X → X → ℝ} (hc : IsCoupling p q c)
    (n : ℕ) : IsCoupling (powLaw p n) (powLaw q n) (powCoupling c n) := by
  refine ⟨?_, ?_, ?_⟩
  · intro v w
    exact Finset.prod_nonneg fun i _ => hc.nonneg (v i) (w i)
  · intro v
    have h := Fintype.prod_sum (fun (i : Fin n) (y : X) => c (v i) y)
    simp only [powCoupling, powLaw]
    rw [← h]
    exact Finset.prod_congr rfl fun i _ => hc.left (v i)
  · intro w
    have h := Fintype.prod_sum (fun (i : Fin n) (x : X) => c x (w i))
    simp only [powCoupling, powLaw]
    rw [← h]
    exact Finset.prod_congr rfl fun i _ => hc.right (w i)

omit [DecidableEq X] in
/-- The `n` coordinates agree simultaneously with probability `(∑ₓ c x x)^n`. -/
theorem sum_diag_powCoupling (c : X → X → ℝ) (n : ℕ) :
    ∑ v, powCoupling c n v v = (∑ x, c x x) ^ n := by
  have h := Fintype.prod_sum (fun (_ : Fin n) (x : X) => c x x)
  simp only [powCoupling]
  rw [← h, Finset.prod_const, Finset.card_univ, Fintype.card_fin]

/-! ## The sharp amplification law -/

/-- **Sharp `n`-sample bound.**  Total variation amplifies geometrically, not
linearly: `d_TV(p^{⊗n}, q^{⊗n}) ≤ 1 − (1 − d_TV(p, q))^n`.  The witness is the
`n`-fold independent product of the maximal coupling. -/
theorem tvDist_powLaw_le_one_sub_pow {p q : X → ℝ} (hp : ∑ x, p x = 1)
    (hq : ∑ x, q x = 1) (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) (n : ℕ) :
    tvDist (powLaw p n) (powLaw q n) ≤ 1 - (1 - tvDist p q) ^ n := by
  have hcoup : IsCoupling p q (maxCoupling p q) :=
    isCoupling_maxCoupling hp hq hp0 hq0
  have hdiag : ∑ x, maxCoupling p q x x = 1 - tvDist p q := by
    have h1 := disagreeProb_eq_one_sub_diag hcoup hp
    have h2 := disagreeProb_maxCoupling hp hq hp0 hq0
    linarith [h1, h2]
  have hn := isCoupling_powCoupling hcoup n
  have hle := tvDist_le_disagreeProb (sum_powLaw hp n) (sum_powLaw hq n) hn
  have hdis : disagreeProb (powCoupling (maxCoupling p q) n)
      = 1 - (1 - tvDist p q) ^ n := by
    rw [disagreeProb_eq_one_sub_diag hn (sum_powLaw hp n),
      sum_diag_powCoupling, hdiag]
  linarith [hle, hdis.le, hdis.ge]

/-- Consequence: the `n`-sample distance never exceeds `1`, however large `n` is
— in sharp contrast with the linear hybrid bound. -/
theorem tvDist_powLaw_le_one {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) (n : ℕ) :
    tvDist (powLaw p n) (powLaw q n) ≤ 1 := by
  have h := tvDist_powLaw_le_one_sub_pow hp hq hp0 hq0 n
  have ht0 : 0 ≤ tvDist p q := tvDist_nonneg p q
  have ht1 : tvDist p q ≤ 1 := tvDist_le_one hp hq hp0 hq0
  have hpow : 0 ≤ (1 - tvDist p q) ^ n := pow_nonneg (by linarith) n
  linarith

/-! ## The geometric bound dominates the linear one -/

/-- Bernoulli's inequality in the form we need: the geometric amplification law
is never worse than the hybrid bound. -/
theorem one_sub_pow_le_nsmul {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    ∀ n : ℕ, 1 - (1 - t) ^ n ≤ n * t := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      have hb0 : (0:ℝ) ≤ 1 - t := by linarith
      have hb1 : (1 - t) ^ n ≤ 1 := pow_le_one₀ hb0 (by linarith)
      have hb0n : (0:ℝ) ≤ (1 - t) ^ n := pow_nonneg hb0 n
      have hstep : (1 - t) ^ (n + 1) = (1 - t) ^ n - t * (1 - t) ^ n := by
        rw [pow_succ]; ring
      rw [hstep]
      push_cast
      nlinarith [ih, hb1, hb0n]

/-- For two or more samples and a nondegenerate pair the geometric law is
*strictly* stronger than the hybrid bound: the linear bound systematically
over-counts the amplification. -/
theorem one_sub_pow_lt_nsmul {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) :
    ∀ n : ℕ, 2 ≤ n → 1 - (1 - t) ^ n < n * t := by
  intro n hn
  induction n with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge n 2 with hlt | hge
      · -- then `n + 1 = 2`
        have hn2 : n = 1 := by omega
        subst hn2
        have : (1:ℝ) - (1 - t) ^ 2 = 2 * t - t ^ 2 := by ring
        push_cast
        nlinarith [sq_nonneg t]
      · have hb0 : (0:ℝ) ≤ 1 - t := by linarith
        have hb1 : (1 - t) ^ n ≤ 1 := pow_le_one₀ hb0 (by linarith)
        have hb0n : (0:ℝ) ≤ (1 - t) ^ n := pow_nonneg hb0 n
        have hstep : (1 - t) ^ (n + 1) = (1 - t) ^ n - t * (1 - t) ^ n := by
          rw [pow_succ]; ring
        have hprev := ih hge
        rw [hstep]
        push_cast
        nlinarith [hprev, hb1, hb0n]

/-- The sharp law implies the hybrid bound of `Testing`, so nothing is lost. -/
theorem tvDist_powLaw_le_of_sharp {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) (n : ℕ) :
    tvDist (powLaw p n) (powLaw q n) ≤ n * tvDist p q := by
  have h1 := tvDist_powLaw_le_one_sub_pow hp hq hp0 hq0 n
  have h2 := one_sub_pow_le_nsmul (tvDist_nonneg p q) (tvDist_le_one hp hq hp0 hq0) n
  linarith

/-- **Sharp sample-complexity floor.**  After `n` i.i.d. samples every test still
errs with probability at least `(1 − t)^n / 2` where `t = d_TV(p, q)`: the error
floor decays geometrically in `n`, and stays *strictly positive* for every finite
`n` whenever the two sources are not mutually singular. -/
theorem bayesError_powLaw_ge_pow {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) (n : ℕ) (f : (Fin n → X) → Bool) :
    (1 - tvDist p q) ^ n / 2 ≤ bayesError (powLaw p n) (powLaw q n) f := by
  have h1 := bayesError_ge_half_one_sub_tvDist (sum_powLaw hp n) (sum_powLaw hq n) f
  have h2 := tvDist_powLaw_le_one_sub_pow hp hq hp0 hq0 n
  linarith

end UniversalRedundancy