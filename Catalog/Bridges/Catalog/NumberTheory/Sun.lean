import Mathlib
import NumberTheory.SunLegendreDeterminant.Basic
import NumberTheory.SunLegendreDeterminant.Affine

/-!
# Sun's truncated Legendre-symbol determinant — main results

Putting the two structural pillars together:

* `det C = 0` for the antisymmetric, odd-order Legendre-difference matrix
  (`Basic.det_Cleg_eq_zero`);
* `det (C.map Polynomial.C + X • J)` is affine in `X` (`Affine.det_Apoly`);

we obtain the **general reduction**

`det A = (det (C + J)) · X`   (`det_legendre_matrix`)

valid for *every* prime `p ≥ 7` with `p ≡ 3 (mod 4)`.  The determinant is thus a
pure monomial `c · X` with **zero constant term**, and the entire content of Sun's
theorem is concentrated in the single integer `c = det (C + J)`.

Sun's closed form is `c = ((p - 2)/3)^2`.  We verify this exactly for the first
admissible primes `p = 7, 11, 19` (`sun_det_7`, `sun_det_11`, `sun_det_19`), each
giving the full polynomial identity `det A = ((p-2)/3)^2 · X` over `ℤ[X]`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `det A = ((p-2)/3)^2 · X`.  Two sub-claims: (i) the
determinant is a monomial `c·X` (no constant, no higher terms); (ii) the
coefficient is the perfect square `((p-2)/3)^2`.

Experiment (Experimenter): Sub-claim (i) is proved in full generality by combining
the antisymmetric-determinant vanishing with the rank-one affine structure.
Sub-claim (ii) is the deep number-theoretic core (Sun); we verify it by exact
integer determinant computation for `p = 7, 11, 19` (`native_decide`).  The
`m × m` permutation expansion becomes infeasible around `m = 9` (`p = 23`), which
is a tooling limit, not a mathematical one — the Python evidence
(`ComputationalEvidence.md`) confirms the formula through `p = 151`.

Analysis (Analyst): The coefficient sequence `1, 9, 25, 49, 81, …` is
`((p-2)/3)^2 = (1,3,5,7,9,…)^2`.  The factorisation of Sun's identity into
"vanishing constant term" + "rank-one linear coefficient" + "evaluate the
coefficient" is the key conceptual gain: the first two parts are general and
clean; only the third needs heavy machinery (Gauss/Jacobi sums).

Critique (Critic): The general theorem `det_legendre_matrix` has 0 sorries and is
not vacuous (it pins down the determinant as `C(det(C+J)) * X`, an honest
polynomial identity).  The instances are genuine `ℤ[X]` identities, each obtained
from the general theorem plus one verified scalar — *not* a bare `native_decide`
of the whole claim.  Boundary: the closed form `((p-2)/3)^2` is asserted only
where verified.

Synthesis (PI): A clean reduction of Sun's theorem to a single character-sum
computation, with the polynomial/linear-algebra scaffolding fully formalised.
-/

open Polynomial Matrix

namespace SunLegendreDet

/-- **General reduction (main theorem).**  For every prime `p ≥ 7` with
`p ≡ 3 (mod 4)`, the determinant of the truncated Legendre-symbol polynomial
matrix `A j k = X + (j - k | p)` is the monomial `det (C + J) · X`: it has zero
constant term and is linear in `X`.  This holds over `ℤ[X]` for all such `p`. -/
theorem det_legendre_matrix
    (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) (hp7 : 7 ≤ p) :
    (Apoly (Cleg p (mDim p))).det
      = Polynomial.C ((Cleg p (mDim p) + onesM ℤ (mDim p)).det) * Polynomial.X := by
  rw [det_Apoly, det_Cleg_eq_zero p hp hp7]
  simp

/-- **Reduction to the scalar coefficient.**  If `det (C + J) = c`, then
`det A = c · X`.  Each verified prime simply supplies the value of `c`. -/
theorem sun_det_of_coeff
    (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) (hp7 : 7 ≤ p)
    {c : ℤ} (hc : (Cleg p (mDim p) + onesM ℤ (mDim p)).det = c) :
    (Apoly (Cleg p (mDim p))).det = Polynomial.C c * Polynomial.X := by
  rw [det_legendre_matrix p hp hp7, hc]

instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 19) := ⟨by norm_num⟩

/-- **Sun's identity, `p = 7`.**  `det A = ((7-2)/3)^2 · X = 1 · X`. -/
theorem sun_det_7 :
    (Apoly (Cleg 7 (mDim 7))).det = Polynomial.C ((((7 - 2) / 3 : ℕ) : ℤ) ^ 2) * Polynomial.X :=
  sun_det_of_coeff 7 (by norm_num) (by norm_num) (by native_decide)

/-- **Sun's identity, `p = 11`.**  `det A = ((11-2)/3)^2 · X = 9 · X`. -/
theorem sun_det_11 :
    (Apoly (Cleg 11 (mDim 11))).det = Polynomial.C ((((11 - 2) / 3 : ℕ) : ℤ) ^ 2) * Polynomial.X :=
  sun_det_of_coeff 11 (by norm_num) (by norm_num) (by native_decide)

/-- **Sun's identity, `p = 19`.**  `det A = ((19-2)/3)^2 · X = 25 · X`. -/
theorem sun_det_19 :
    (Apoly (Cleg 19 (mDim 19))).det = Polynomial.C ((((19 - 2) / 3 : ℕ) : ℤ) ^ 2) * Polynomial.X :=
  sun_det_of_coeff 19 (by norm_num) (by norm_num) (by native_decide)

end SunLegendreDet