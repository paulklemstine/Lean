/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra
import Tropical.TropicalMatrixPower
import Tropical.EigenzeroNoLeak

/-!
# The Tropical Discrete Logarithm Problem: an eigenvalue break

This file formalizes the **eigenvalue attack** on the *tropical discrete logarithm
problem* (TDLP), the structural weakness underlying the proposed tropical
Diffie–Hellman key exchange.

The TDLP asks: given a public min-plus matrix `A` and `B = A^{⊗(k+1)}`
(`TropicalPower.tropMatPow A k`, with the field-friendly indexing of
`Tropical.TropicalMatrixPower`), recover the secret exponent `k`.

The attack rests on **tropical eigenvalue additivity**: if `(λ, v)` is a tropical
eigenpair of `A` (`IsTropicalEigenpair A λ v`, from `Tropical.MinPlusAlgebra`),
then `(λ·(k+1), v)` is a tropical eigenpair of `A^{⊗(k+1)}`.  Hence the **residual**
`(A^{⊗(k+1)} ⊗ v)_i - v_i` (`TropicalEigenzero.tropResidual`, from
`Tropical.EigenzeroNoLeak`) equals `(k+1)·λ` at *every* coordinate, and as soon as
`λ ≠ 0` the secret `k` is read off by a **single subtraction and division**.

This is the formal counterpart of the informal claim
`λ(A^{⊗k}) = k·λ(A)  ⟹  k = λ(A^{⊗k})/λ(A)`, and it shows the TDLP is *broken*
exactly in the regime `λ(A) ≠ 0` (complementing the `λ = 0` "no-leak" boundary of
`Tropical.EigenzeroNoLeak`).

## Main results

* `tropMatPow_eigenpair` — eigenvalue additivity under powers:
  `IsTropicalEigenpair A λ v → IsTropicalEigenpair (tropMatPow A k) ((k+1)*λ) v`.
* `tropResidual_tropMatPow` — the public residual equals `(k+1)·λ` at every coordinate.
* `tdlp_eigenvalue_injective` — for `λ ≠ 0` distinct exponents give distinct eigenvalues.
* `tdlp_recover` — **the break**: `λ ≠ 0 ⟹ (residual(A^{⊗(k+1)}) - λ)/λ = k`.
* `tdlp_recover_ratio` — ratio form: `residual(A^{⊗(k+1)}) / residual(A) = k+1`.

Bridge: connects Tropical Spectral Theory to Post-Quantum Cryptanalysis.
-/

noncomputable section

open TropicalPower TropicalEigenzero

namespace TropicalDLog

variable {n : ℕ} [NeZero n]

/-! ## Section 1: Tropical eigenvalue additivity under powers -/

/-
**Tropical eigenvalue additivity.**  If `(λ, v)` is a tropical eigenpair of `A`,
then `(λ·(k+1), v)` is a tropical eigenpair of the tropical power `A^{⊗(k+1)}`
(`tropMatPow A k`).  This is the engine of the TDLP eigenvalue attack:
`λ(A^{⊗(k+1)}) = (k+1)·λ(A)`.
-/
theorem tropMatPow_eigenpair (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (k : ℕ) :
    IsTropicalEigenpair (tropMatPow A k) (((k : ℝ) + 1) * lam) v := by
  induction k <;> simp_all +decide [ Nat.succ_eq_add_one, add_mul ];
  intro i; exact (by
  rw [ show tropMatPow A ( _ + 1 ) = tropMatMul A ( tropMatPow A _ ) from rfl, tropMatVecMul_tropMatMul ];
  rename_i k hk; rw [ show tropMatVecMul ( tropMatPow A k ) v = fun j => v j + ( k * lam + lam ) from funext fun j => hk j ] ; simp +decide [ h i, tropMatVecMul_shift ] ; ring;)

/-! ## Section 2: The residual leaks the eigenvalue -/

/-
The residual of the public power matrix equals `(k+1)·λ` at every coordinate.
The adversary measures this residual directly from `(A^{⊗(k+1)}, v)`.
-/
theorem tropResidual_tropMatPow (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (k : ℕ) (i : Fin n) :
    tropResidual (tropMatPow A k) v i = ((k : ℝ) + 1) * lam := by
  exact tropResidual_eq_eigenvalue _ _ _ ( tropMatPow_eigenpair A lam v h k ) i

/-
The base residual recovers the eigenvalue of `A` itself.
-/
theorem tropResidual_base (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (i : Fin n) :
    tropResidual A v i = lam :=
  tropResidual_eq_eigenvalue A lam v h i

/-! ## Section 3: The TDLP is broken when `λ ≠ 0` -/

/-
For a nonzero eigenvalue, distinct exponents produce distinct tropical eigenvalues,
so the exponent is uniquely determined by the public power's eigenvalue.
-/
theorem tdlp_eigenvalue_injective (lam : ℝ) (hlam : lam ≠ 0) (k k' : ℕ)
    (heq : ((k : ℝ) + 1) * lam = ((k' : ℝ) + 1) * lam) : k = k' := by
  aesop

/-
**The TDLP break.**  When the public matrix has a nonzero tropical eigenvalue,
the secret exponent `k` is recovered from the public pair `(A, A^{⊗(k+1)})` and a
shared eigenvector `v` by one subtraction and one division of measured residuals.
-/
theorem tdlp_recover (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (hlam : lam ≠ 0) (k : ℕ) (i : Fin n) :
    (tropResidual (tropMatPow A k) v i - lam) / lam = k := by
  rw [ tropResidual_tropMatPow A lam v h k i, div_eq_iff hlam ] ; ring

/-
**Ratio form of the break.**  The ratio of the public residual to the base
residual is exactly `k + 1`, i.e. `λ(A^{⊗(k+1)}) / λ(A) = k+1`.
-/
theorem tdlp_recover_ratio (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (hlam : lam ≠ 0) (k : ℕ) (i : Fin n) :
    tropResidual (tropMatPow A k) v i / tropResidual A v i = (k : ℝ) + 1 := by
  rw [tropResidual_tropMatPow A lam v h k i, tropResidual_base A lam v h i]
  field_simp

end TropicalDLog

end

/-!
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
The proposed tropical Diffie–Hellman scheme hides a secret exponent `k` inside the
min-plus power `A^{⊗(k+1)}`.  Conjecture: the scheme is broken whenever `A` has a
nonzero tropical eigenvalue, because tropical eigenvalues are *additive* under powers
(`λ(A^{⊗(k+1)}) = (k+1)λ(A)`), so `k` is a single division away.

## Experiment (Experimenter)
Proved `tropMatPow_eigenpair` by induction on `k` using matrix–vector associativity
(`tropMatVecMul_tropMatMul`) and shift-equivariance (`tropMatVecMul_shift`) from
`Tropical.MinPlusAlgebra`/`Tropical.TropicalMatrixPower`.  Fed the eigenvalue into the
`tropResidual` of `Tropical.EigenzeroNoLeak`, giving `tropResidual_tropMatPow`.  The
recovery theorems `tdlp_recover` / `tdlp_recover_ratio` then reduce to `field_simp`
arithmetic guarded by `lam ≠ 0`.

## Analysis (Analyst)
The break SURVIVES exactly on `λ ≠ 0`.  This is the precise complement of the
`λ = 0` boundary studied in `Tropical.EigenzeroNoLeak` (`eigenzero_no_leak`): there the
residual is identically `0` and leaks nothing; here the residual is `(k+1)λ` and leaks
*everything*.  The eigenvalue thus partitions the parameter space into a "secure"
boundary `λ = 0` and a "broken" interior `λ ≠ 0`.

## Critique (Critic)
No theorem is trivial: `tropMatPow_eigenpair` is a genuine induction, and the recovery
results require the `lam ≠ 0` guard (without it the division collapses and `tdlp_recover`
is false, since `0/0 = 0 ≠ k`).  The result is honest about its scope: it does not claim
to break TDLP for `λ = 0`, where the boundary theorem forbids the attack.

## Synthesis (PI)
Tropical eigenvalue additivity is a homomorphism `(ℕ, +) → (ℝ, +)`, `k ↦ (k+1)λ`,
injective iff `λ ≠ 0`.  The companion file `Bridges/TropicalStrongDivisibilityDLog.lean`
upgrades this from injectivity to a full *strong divisibility* structure on the
eigenvalue sequence, connecting the Tropical and Bridges catalog domains.
-/