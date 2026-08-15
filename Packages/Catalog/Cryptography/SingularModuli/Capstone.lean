import Cryptography.SingularModuli.Sharpness
import Cryptography.SingularModuli.PrecomputationBarrier
import Cryptography.SingularModuli.ExponentialRung
import Cryptography.SingularModuli.Experiments

/-!
# Singular Moduli Factoring: capstone

This file assembles the four independent strands into single statements, and is
careful about what is and is not proved.

**What is proved (unconditionally).**

1. *Exactness of the method.* `evalGcd_nontrivialDivisor_iff`: `gcd(H(j₀), N)`
   is a nontrivial factor iff `j₀` is a root of `H` modulo exactly one of the two
   primes.  No probabilistic modelling enters.
2. *Exact counting.* `successCount_eq`: the number of useful `j₀ ∈ [0, N)` is
   `r_p(q - r_q) + (p - r_p)r_q` — a CRT identity, not a heuristic.
3. *The `√N` barrier, two-sided.* `singularModuli_capstone`: for a balanced
   semiprime and a monic `H` of degree `h`, a uniformly random evaluation point
   succeeds with probability at most `4h/√N`; and when `H` has a root mod `p`
   and none mod `q` the expected number of evaluations lies in
   `[√N/(4h), √N]`.
4. *No escape by precomputation.* `singularModuli_no_precomputation`: for every
   finite family of class polynomials and every finite table of evaluation
   points there are arbitrarily large semiprimes on which the whole table
   returns nothing.
5. *Ladder placement.* `smCost_superpoly`, `smCost_not_subexp`: the resulting
   cost function `exp(x/2)/(4h)` is superpolynomial and genuinely exponential —
   the same rung as Pollard rho, strictly worse than the sieve rung `L[1/3,c]`.

**What is NOT proved.**  Nothing here says that *no* method based on complex
multiplication can factor quickly; it says that the *gcd-of-class-polynomial-
values* method, in the full generality of an arbitrary monic integer polynomial
and arbitrary evaluation points and discriminant families, is a `√N` method.
The class number `h` enters only as a linear speed-up, and `h` is itself
`O(√|D| log |D|)`, so it cannot be pushed to `√N` without the polynomial
becoming too large to evaluate — that quantitative trade-off is the subject of
`FUTURE_DIRECTIONS.md`, not of a theorem here.
-/

namespace SingularModuli

open Polynomial Finset FactoringBarriers

/-- **Capstone: the singular moduli method is exactly a `√N` method.**
For a balanced semiprime `N = pq` (`p ≤ q ≤ 3p`) and a monic `H` of degree `h`
that has a root mod `p` and no root mod `q` (the situation in which the method
actually works):

* the success criterion is exact — a point works iff it is a root modulo exactly
  one prime;
* the density of useful evaluation points is at most `4h/√N`;
* the expected number of evaluations `N/S` lies between `√N/(4h)` and `√N`.
-/
theorem singularModuli_capstone {p q : ℕ} {H : Polynomial ℤ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) (hle : p ≤ q) (hbal : q ≤ 3 * p)
    (hH : H.Monic)
    (hrp : haveI : NeZero p := ⟨hp.pos.ne'⟩; 1 ≤ rootCount H p)
    (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = 0) :
    (∀ j : ℤ, NontrivialDivisor (p * q) (evalGcd H j (p * q)) ↔
        Xor' ((p : ℤ) ∣ H.eval j) ((q : ℤ) ∣ H.eval j)) ∧
      (successCount H (p * q) : ℝ) / (p * q) ≤ 4 * H.natDegree / Real.sqrt ((p : ℝ) * q) ∧
      Real.sqrt ((p : ℝ) * q) / (4 * H.natDegree)
        ≤ ((p : ℝ) * q) / successCount H (p * q) ∧
      ((p : ℝ) * q) / successCount H (p * q) ≤ Real.sqrt ((p : ℝ) * q) := by
  obtain ⟨hlow, hhigh⟩ := sqrt_scaling_two_sided hp hq hne hle hbal hH hrp hrq
  exact ⟨fun j => evalGcd_nontrivialDivisor_iff hp hq hne,
    successDensity_le_balanced hp hq hne hle hbal hH, hlow, hhigh⟩

/-- **Capstone: the structured set cannot be precomputed.** For any finite family
`F` of class polynomials and any finite table `T` of evaluation points, and any
bound `M`, there is a semiprime `N = pq` with both primes larger than `M` on
which every one of the `|F| · |T|` precomputed trials fails.  Combined with the
density bound, the only remaining strategy is search, priced at `√N/(4h)`. -/
theorem singularModuli_no_precomputation (F : Finset (Polynomial ℤ)) (T : Finset ℤ) (M : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ M < p ∧ M < q ∧
      ∀ G ∈ F, ∀ t ∈ T, ¬ NontrivialDivisor (p * q) (evalGcd G t (p * q)) :=
  finite_family_table_fails F T M

/-- **Capstone: asymptotic classification.** The proven cost profile
`exp(x/2)/(4h)` of the method is superpolynomial, is not subexponential, and
dominates the Pollard rho barrier: singular moduli factoring belongs to the
`√N` family of the resource classification, strictly above the sieve rung. -/
theorem singularModuli_rung {h : ℝ} (hh : 0 < h) :
    Superpoly (smCost h) ∧ ¬ Subexp (smCost h) ∧ ¬ PolyBounded (smCost h) ∧
      Subexp (barrierCost .smoothness) ∧
      (∀ᶠ x in Filter.atTop, barrierCost .randomness x ≤ smCost h x) :=
  ⟨smCost_superpoly hh, smCost_not_subexp hh, smCost_not_polyBounded hh,
    smoothness_barrier_subexp, smCost_dominates_randomness hh⟩

/-- **Capstone: the class number cancels.** The expected *arithmetic work* — the
number of evaluations times the degree-`h` cost of one Horner evaluation — is at
least `√N/4`, with no `h` in the bound.  Choosing discriminants of large class
number therefore cannot move the method off the `√N` rung. -/
theorem singularModuli_work_barrier {p q : ℕ} {H : Polynomial ℤ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) (hle : p ≤ q) (hbal : q ≤ 3 * p)
    (hH : H.Monic) (hS : 0 < successCount H (p * q)) :
    Real.sqrt ((p : ℝ) * q) / 4
      ≤ (H.natDegree : ℝ) * (((p : ℝ) * q) / successCount H (p * q)) :=
  total_work_ge hp hq hne hle hbal hH hS

/-- **Capstone: the theory is not vacuous.** The verified experiment
`N = 77 = 7 · 11`, `D = -15` realises every ingredient at once: a concrete
factorisation, the exact success count `21` predicted by the CRT theorem, and
the `h(p+q) = 36` upper bound. -/
theorem singularModuli_worked_example :
    evalGcd H15 0 77 = 11 ∧ successCount H15 (7 * 11) = 21 ∧
      successCount H15 (7 * 11) ≤ H15.natDegree * (7 + 11) := by
  refine ⟨factor_77, successCount_H15_77, ?_⟩
  rw [successCount_H15_77, H15_natDegree]
  norm_num

/-- **Capstone: the hypotheses of the main theorem are satisfiable.** For
`N = 221 = 13 · 17` and `D = -15` (one root mod 13, none mod 17) the two-sided
scaling statement is not vacuous: the expected number of evaluations is exactly
`221/17 = 13`, and it does lie in `[√221/8, √221]`. -/
theorem singularModuli_capstone_instance :
    successCount H15 (13 * 17) = 17 ∧
      Real.sqrt ((13 : ℝ) * 17) / (4 * H15.natDegree)
        ≤ ((13 : ℝ) * 17) / successCount H15 (13 * 17) ∧
      ((13 : ℝ) * 17) / successCount H15 (13 * 17) ≤ Real.sqrt ((13 : ℝ) * 17) := by
  have h := sqrt_scaling_two_sided (p := 13) (q := 17) (H := H15)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) H15_monic
    (by simp [rootCount_H15_13]) rootCount_H15_17
  exact ⟨successCount_H15_221, h.1, h.2⟩

end SingularModuli