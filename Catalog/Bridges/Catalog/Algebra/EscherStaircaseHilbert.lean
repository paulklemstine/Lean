/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Escher Height, part II: finitely many variables admit no staircase

This file completes the "Escher height = number of variables" contrast begun in
`Algebra.EscherStaircasePolynomial`.  Whereas `k[x₀, x₁, …]` (countably many
variables) carries an explicit Escher staircase, the **Hilbert basis theorem** shows
that with only finitely many variables the ascending chain condition holds, so there
is no Escher staircase at all.

## Main results

* `Escher.not_escherStaircase_mvPolynomial_fin` : `k[x₀, …, x_{n-1}]` has no Escher
  staircase (it is Noetherian by Hilbert's basis theorem).
* `Escher.not_escherStaircase_polynomial` : the single-variable ring `k[X]` has no
  Escher staircase.
* `Escher.escher_dichotomy_mvPolynomial` : the sharp finite/infinite dichotomy — for
  finitely many variables there is no staircase, but for countably many there is.

-- !-- Lab Notes -- !--
### Hypothesis (Hypothesizer)
  H1. `k[x₀,…,x_{n-1}]` is Noetherian (Hilbert basis) ⇒ no Escher staircase.   [kept]
  H2. `k[X]` (a PID) is Noetherian ⇒ no Escher staircase.                       [kept]
  H3. (dichotomy) The presence of an Escher staircase for polynomial rings over a
      field is governed *exactly* by whether the variable set is infinite.      [kept]

### Experiment (Experimenter)
`MvPolynomial (Fin n) k` is Noetherian for every `n` via `isNoetherianRing_fin`;
`Polynomial k` is Noetherian via `Polynomial.isNoetherianRing`.  Together with the
`ℕ`-variable staircase from the sibling file, the dichotomy is witnessed on both
sides.

### Analysis (Analyst)
Both negative results reduce, through
`escherStaircase_iff_not_isNoetherianRing`, to Noetherianity, which Mathlib supplies
for finitely many variables over a Noetherian base (a field is Noetherian).  The
content is the Hilbert basis theorem itself; the Escher-staircase language repackages
it as "no impossible staircase can be built with a bounded number of variables".

### Critique (Critic)
* Non-triviality: `not_not` + the Hilbert basis instance; the dichotomy pairs a
  genuine existence proof with a genuine non-existence proof, neither vacuous.
* Corner case: `n = 0` gives `k` itself, still Noetherian, still no staircase — the
  statement holds uniformly.

### Synthesis (PI)
Finitely many variables ⇒ Noetherian ⇒ no Escher staircase; countably many ⇒ an
explicit staircase.  This is the precise sense in which the "Escher height" of a
polynomial ring over a field tracks the number of variables: it is `0` (no staircase)
in the finite case and positive (a staircase exists) in the infinite case.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Algebra.EscherStaircase
import Algebra.EscherStaircasePolynomial

open MvPolynomial

namespace Escher

variable {k : Type*} [Field k]

/-- **Main theorem (no finite staircase).** The polynomial ring `k[x₀, …, x_{n-1}]`
in finitely many variables over a field has **no** Escher staircase: by Hilbert's
basis theorem it is Noetherian, so every ascending chain of ideals stabilises. -/
theorem not_escherStaircase_mvPolynomial_fin (n : ℕ) :
    ¬ EscherStaircase (MvPolynomial (Fin n) k) := by
  rw [escherStaircase_iff_not_isNoetherianRing, not_not]
  exact MvPolynomial.isNoetherianRing_fin

/-- The single-variable polynomial ring `k[X]` over a field — a PID, hence
Noetherian — has no Escher staircase. -/
theorem not_escherStaircase_polynomial : ¬ EscherStaircase (Polynomial k) := by
  rw [escherStaircase_iff_not_isNoetherianRing, not_not]
  exact Polynomial.isNoetherianRing

/-- **The Escher dichotomy for polynomial rings over a field.** With finitely many
variables there is no Escher staircase, but with countably many variables there is
one.  This is the sharp finite/infinite boundary underlying "Escher height = number
of variables". -/
theorem escher_dichotomy_mvPolynomial (n : ℕ) :
    (¬ EscherStaircase (MvPolynomial (Fin n) k)) ∧ EscherStaircase (MvPolynomial ℕ k) :=
  ⟨not_escherStaircase_mvPolynomial_fin n, escherStaircase_mvPolynomial_nat⟩

end Escher