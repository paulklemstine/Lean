/-
  # Reed–Muller Evaluation Codes — Core Definitions

  This file defines the fundamental objects for Reed–Muller evaluation codes
  over finite fields: zero counting, Hamming weight of evaluation codewords,
  and the extremal witness polynomial.

  ## Main definitions

  - `ReedMuller.zeroCount`: number of zeros of a polynomial over the finite domain
  - `ReedMuller.hammingWeight`: number of nonzero evaluations (Hamming weight)
  - `ReedMuller.witnessPoly`: the extremal polynomial ∏_{a ∈ s} (X₀ - a)
-/

import Mathlib

open MvPolynomial Finset BigOperators

namespace ReedMuller

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-- The zero count of a multivariate polynomial: the number of points in 𝔽^n
    where the polynomial evaluates to zero. -/
noncomputable def zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)).card

/-- The Hamming weight of the evaluation codeword: the number of points in 𝔽^n
    where the polynomial evaluates to a nonzero value. -/
noncomputable def hammingWeight {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f ≠ 0)).card

/-- The extremal witness polynomial: the product ∏_{a ∈ s} (X₀ - C a),
    a polynomial in (n+1) variables that depends only on the first coordinate.
    This is the polynomial that attains the minimum distance of the Reed–Muller code. -/
noncomputable def witnessPoly {n : ℕ} (s : Finset 𝔽) : MvPolynomial (Fin (n + 1)) 𝔽 :=
  ∏ a ∈ s, (MvPolynomial.X (0 : Fin (n + 1)) - MvPolynomial.C a)

end ReedMuller