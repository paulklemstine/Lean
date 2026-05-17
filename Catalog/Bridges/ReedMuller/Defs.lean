/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Generalized Reed–Muller Codes — Core Definitions

This file defines the fundamental objects for generalized Reed–Muller evaluation codes
over arbitrary finite fields, extending the classical case (degree < q) to arbitrary
degree d = a(q-1) + b.

## Main definitions

- `GRM.hammingWeight`: number of nonzero evaluations of a polynomial on 𝔽^n
- `GRM.zeroCount`: number of zeros of a polynomial on 𝔽^n
- `GRM.extremalPoly`: the extremal polynomial achieving minimum weight

## References

* Kasami, T., Lin, S., Peterson, W. (1968). New generalizations of the Reed-Muller codes.
* Delsarte, P., Goethals, J.M., Mac Williams, F.J. (1970). On generalized Reed-Muller codes
  and their relatives.
-/

open MvPolynomial Finset BigOperators Fintype

namespace GRM

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-- The Hamming weight of the evaluation codeword of a multivariate polynomial:
    the number of points in 𝔽^n where the polynomial evaluates to a nonzero value. -/
noncomputable def hammingWeight {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f ≠ 0)).card

/-- The zero count of a multivariate polynomial: the number of points in 𝔽^n
    where the polynomial evaluates to zero. -/
noncomputable def zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)).card

/-
Weight plus zero count equals the total number of points.
-/
theorem hammingWeight_add_zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f + zeroCount f = card (Fin n → 𝔽) := by
  rw [ show hammingWeight f = Finset.card ( Finset.univ.filter ( fun x : Fin n → 𝔽 => ¬MvPolynomial.eval x f = 0 ) ) by rfl, show zeroCount f = Finset.card ( Finset.univ.filter ( fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0 ) ) by rfl ];
  rw [ add_comm, Finset.card_filter_add_card_filter_not ];
  rfl

/-- The total number of points in 𝔽^n equals q^n. -/
theorem card_fin_arrow (n : ℕ) (𝔽 : Type*) [Fintype 𝔽] :
    card (Fin n → 𝔽) = (card 𝔽) ^ n := by
  simp [Fintype.card_fun, Fintype.card_fin]

/-
Hamming weight in terms of total minus zero count.
-/
theorem hammingWeight_eq {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f = (card 𝔽) ^ n - zeroCount f := by
  exact eq_tsub_of_add_eq ( by rw [ ← card_fin_arrow n 𝔽 ] ; exact hammingWeight_add_zeroCount f )

end GRM