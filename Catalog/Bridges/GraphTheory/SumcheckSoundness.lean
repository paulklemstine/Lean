/-
  # Sum-Check Protocol: Inductive Soundness

  This file formalizes the core algebraic detection theorem underlying the
  sum-check interactive proof protocol. The key insight is that a cheating
  prover who sends an incorrect round polynomial is caught with high
  probability because a nonzero low-degree polynomial cannot vanish at
  too many points of a finite field.

  ## Main results

  * `eval_eq_iff_eval_sub_eq_zero` — pointwise equivalence between
    agreement of two polynomials and vanishing of their difference.
  * `poly_sub_ne_zero_of_ne` — `p ≠ q → p - q ≠ 0`.
  * `card_roots_le_natDegree` — the univariate Schwartz–Zippel root bound.
  * `card_eq_eval_le_natDegree_sub` — the number of field elements where
    `p` and `q` agree is at most `natDegree (p - q)`.
  * `affine_disagreement_le_one` — specialization to degree ≤ 1 polynomials.
  * `sumcheck_round_soundness_degree_one` — one-round sum-check soundness
    for multilinear polynomials.
  * `cheating_prob_le` — probabilistic cheating bound.
  * `sumcheck_inductive_soundness_step` — general degree-`d` soundness step.
-/

import Mathlib

open Polynomial Finset

namespace SumcheckSoundness

/-! ### Foundational lemmas -/

section Basic

variable {F : Type*} [Field F]

/-- Pointwise: `p` and `q` agree at `x` iff their difference vanishes at `x`. -/
theorem eval_eq_iff_eval_sub_eq_zero (p q : Polynomial F) (x : F) :
    p.eval x = q.eval x ↔ (p - q).eval x = 0 := by
  simp [eval_sub, sub_eq_zero]

/-- If `p ≠ q` as polynomials then `p - q ≠ 0`. -/
theorem poly_sub_ne_zero_of_ne {p q : Polynomial F} (h : p ≠ q) : p - q ≠ 0 :=
  sub_ne_zero.mpr h

/-- The number of roots of a nonzero polynomial is at most its `natDegree`.
    This is the univariate Schwartz–Zippel lemma. -/
theorem card_roots_le_natDegree (f : Polynomial F) (hf : f ≠ 0) :
    f.roots.card ≤ f.natDegree := by
  have h := Polynomial.card_roots hf
  rw [Polynomial.degree_eq_natDegree hf] at h
  exact WithBot.coe_le_coe.mp h

/-- `natDegree (p - q) ≤ max (natDegree p) (natDegree q)`. -/
theorem natDegree_sub_le_max' (p q : Polynomial F) :
    (p - q).natDegree ≤ max p.natDegree q.natDegree :=
  Polynomial.natDegree_sub_le p q

end Basic

/-! ### Main theorems over finite fields -/

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- **Schwartz–Zippel root bound (agreement form).**
The number of field elements at which two distinct polynomials `p` and `q`
agree is at most `natDegree (p - q)`.

This is the core algebraic detection theorem: a nonzero discrepancy polynomial
`p - q` can vanish at no more points than its degree. -/
theorem card_eq_eval_le_natDegree_sub
    (p q : Polynomial F) (hne : p ≠ q) :
    (univ.filter fun x : F => p.eval x = q.eval x).card ≤ (p - q).natDegree := by
  have hsub : p - q ≠ 0 := poly_sub_ne_zero_of_ne hne
  have hroots : (p - q).roots.toFinset.card ≤ (p - q).natDegree :=
    le_trans (Multiset.toFinset_card_le _) (card_roots_le_natDegree _ hsub)
  apply le_trans _ hroots
  apply Finset.card_le_card
  intro x hx
  simp only [mem_filter, mem_univ, true_and] at hx
  rw [Multiset.mem_toFinset, Polynomial.mem_roots hsub]
  exact (eval_eq_iff_eval_sub_eq_zero p q x).mp hx

/-- If two distinct polynomials both have degree ≤ 1, then they agree at most
    at one point. -/
theorem affine_disagreement_le_one
    (p q : Polynomial F) (hne : p ≠ q)
    (hp : p.natDegree ≤ 1) (hq : q.natDegree ≤ 1) :
    (univ.filter fun x : F => p.eval x = q.eval x).card ≤ 1 := by
  calc (univ.filter fun x : F => p.eval x = q.eval x).card
      ≤ (p - q).natDegree := card_eq_eval_le_natDegree_sub p q hne
    _ ≤ max p.natDegree q.natDegree := natDegree_sub_le_max' p q
    _ ≤ max 1 1 := by omega
    _ = 1 := by simp

/-- **Sum-check one-round soundness (degree 1).**
If the prover sends a polynomial `sent` that differs from the true polynomial
`truePoly`, and both have degree ≤ 1, then a uniformly random verifier challenge
`r ∈ F` satisfies `sent.eval r = truePoly.eval r` for at most one value of `r`. -/
theorem sumcheck_round_soundness_degree_one
    (sent truePoly : Polynomial F)
    (hne : sent ≠ truePoly)
    (hs : sent.natDegree ≤ 1)
    (ht : truePoly.natDegree ≤ 1) :
    (univ.filter fun r : F => sent.eval r = truePoly.eval r).card ≤ 1 :=
  affine_disagreement_le_one sent truePoly hne hs ht

/-- **Sum-check inductive soundness step (general degree).**
If the prover's polynomial differs from the true polynomial and their difference
has degree ≤ `d`, then a random challenge hits an agreement point for at most `d`
values. -/
theorem sumcheck_inductive_soundness_step
    (d : ℕ)
    (sent truePoly : Polynomial F)
    (hne : sent ≠ truePoly)
    (hdeg : (sent - truePoly).natDegree ≤ d) :
    (univ.filter fun r : F => sent.eval r = truePoly.eval r).card ≤ d :=
  le_trans (card_eq_eval_le_natDegree_sub sent truePoly hne) hdeg

/-! ### Probabilistic form -/

/-- **Cheating success probability bound.**
The fraction of field elements where two distinct polynomials agree is at most
`natDegree (p - q) / |F|`. -/
theorem cheating_prob_le
    (p q : Polynomial F) (hne : p ≠ q) :
    ((univ.filter fun x : F => p.eval x = q.eval x).card : ℚ) / Fintype.card F
      ≤ (p - q).natDegree / Fintype.card F := by
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast card_eq_eval_le_natDegree_sub p q hne

/-- **Affine-linear cheating probability bound.**
For degree ≤ 1 polynomials, the cheating success probability is at most `1 / |F|`. -/
theorem cheating_prob_degree_one_le
    (p q : Polynomial F) (hne : p ≠ q)
    (hp : p.natDegree ≤ 1) (hq : q.natDegree ≤ 1) :
    ((univ.filter fun x : F => p.eval x = q.eval x).card : ℚ) / Fintype.card F
      ≤ 1 / Fintype.card F := by
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast affine_disagreement_le_one p q hne hp hq

end SumcheckSoundness