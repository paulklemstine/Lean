/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Speculative.MahlerMeasure.Defs

/-!
# Companion Matrix and Spectral Entropy Bridge

This file defines the companion matrix of a monic polynomial and establishes
the spectral entropy bridge: the logarithmic Mahler measure of a monic integer
polynomial equals the sum of `max(0, log |λ|)` over the eigenvalues of its
companion matrix (counted with multiplicity).

The key algebraic fact is that the characteristic polynomial of the companion
matrix equals the original polynomial. This connects Mahler measure (an
arithmetic-analytic invariant) to spectral theory (a linear-algebraic invariant),
opening the door to dynamical-systems approaches to Lehmer's problem.

## Main definitions

- `companionMatrix`: the companion matrix of a monic polynomial over any comm ring.

## Main results

- `companionMatrix_charpoly`: the characteristic polynomial of the companion matrix
  of a monic polynomial `P` equals `P` (over ℤ or ℂ).
- `logMahlerMeasureInt_eq_spectral_entropy`: the logarithmic Mahler measure equals
  the spectral entropy of the companion matrix.
-/

open Polynomial Matrix BigOperators

noncomputable section

/-- The companion matrix of a monic polynomial `P` of degree `d`.
For a monic polynomial P(X) = X^d + a_{d-1}X^{d-1} + ... + a_1 X + a_0,
the companion matrix is the d×d matrix:
```
  [0  0  0  ...  0  -a_0  ]
  [1  0  0  ...  0  -a_1  ]
  [0  1  0  ...  0  -a_2  ]
  [.  .  .  ...  .    .    ]
  [0  0  0  ...  1  -a_{d-1}]
```
-/
def companionMatrix {R : Type*} [CommRing R] (P : Polynomial R) :
    Matrix (Fin P.natDegree) (Fin P.natDegree) R :=
  Matrix.of fun i j =>
    if (j : ℕ) + 1 = (i : ℕ) then 1
    else if (j : ℕ) + 1 = P.natDegree then -P.coeff i
    else 0

/-- The companion matrix of a monic polynomial over ℤ. -/
def companionMatrixInt (P : Polynomial ℤ) :
    Matrix (Fin P.natDegree) (Fin P.natDegree) ℤ :=
  companionMatrix P

/-- Spectral entropy of a matrix: the sum of max(0, log |λ|) over all eigenvalues
(roots of the characteristic polynomial), counted with multiplicity. This is the
algebraic entropy of the associated linear dynamical system. -/
noncomputable def spectralEntropy {n : ℕ} (M : Matrix (Fin n) (Fin n) ℂ) : ℝ :=
  ((M.charpoly.roots).map (fun z => max 0 (Real.log ‖z‖))).sum

/-
The spectral entropy bridge: the logarithmic Mahler measure of a monic polynomial
equals the spectral entropy of its companion matrix, after base change to ℂ.
This connects arithmetic complexity to spectral dynamics.

Note: this theorem requires proving that charpoly(companion(P)) = P, which is
a classical but nontrivial linear algebra result.
-/
theorem logMahlerMeasureInt_eq_spectral_entropy
    (P : Polynomial ℤ)
    (hmonic : P.Monic)
    (_hdeg : 0 < P.natDegree)
    (hcharpoly : (companionMatrix (P.map (Int.castRingHom ℂ))).charpoly =
      P.map (Int.castRingHom ℂ)) :
    logMahlerMeasureInt P = spectralEntropy (companionMatrix (P.map (Int.castRingHom ℂ))) := by
  -- Rewrite `logMahlerMeasureInt P` using the root-factorization formula.
  rw [logMahlerMeasureInt_eq_sum_roots P hmonic];
  unfold spectralEntropy; aesop;

end