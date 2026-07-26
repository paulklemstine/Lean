/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The odd power-sum plethysm `φ_t : p_n ↦ (1 - t^n) p_n` as an automorphism

This companion file isolates the *abstract* plethystic operator
`φ_t : p_{2k+1} ↦ (1 - t^{2k+1}) p_{2k+1}` on the ring of odd power-sum symmetric
functions, modeled as `Lam = MvPolynomial ℕ K` over `K = ℚ(t)` (variable `X k = p_{2k+1}`),
independently of the Schur-`Q` / vertex-operator machinery used in
`PlethysticTrivialityShiftedTSchur`.

The "plethystic triviality" of the shifted `t`-Schur basis is, at bottom, a statement
about `φ_t` alone: it is an algebra automorphism that is *diagonal in the monomial basis*
and *degree-preserving*, yet genuinely non-trivial (not the identity).  These three facts
are the structural reason the `t`-deformation is a mere invertible relabelling.

Main results:
* `phiTEquiv` / `phiT_bijective` — `φ_t` is an algebra automorphism with inverse
  `ψ_t : p_n ↦ p_n / (1 - t^n)`.
* `phiT_monomial_pow` — `φ_t` is *diagonal* on each variable-power: `φ_t(p_n^m) =
  (1 - t^n)^m p_n^m`.
* `phiT_isHomogeneous` — `φ_t` preserves the grading by total degree.
* `phiT_X_zero_ne` / `phiT_ne_id` — `φ_t` is genuinely non-trivial (`φ_t ≠ id`), so
  "triviality" means *automorphic*, not *identity* (the Critic's boundary check).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):  The whole `S^t` vs `Q` story is governed by a single linear
  operator `φ_t` that is diagonal in the monomial basis; thus the deformation must
  preserve every grading-respecting structural invariant.
Experiment (Experimenter):  Prove `φ_t(X k ^ m) = C(cc k ^ m) * X k ^ m` by `map_pow`
  and `phiT_X`; lift to homogeneity via `MvPolynomial.IsHomogeneous.aeval` with each
  generator `C (cc k) * X k` homogeneous of degree `1` (`isHomogeneous_C_mul_X`).
Analysis (Analyst):  Degree preservation is the abstract shadow of `|S^t_λ| = |λ| = |Q_λ|`:
  the plethysm never mixes degrees, only rescales monomials by `∏ (1 - t^{n_i})`.
Critique (Critic):  A "trivial" basis change could be vacuously the identity; we refute
  this with `phiT_ne_id`, using `cc 0 = 1 - t ≠ 1` because `t = RatFunc.X ≠ 0`.
Synthesis (PI):  `φ_t` is a degree-preserving, monomial-diagonal automorphism — exactly
  the operator-theoretic content of plethystic triviality.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open MvPolynomial

noncomputable section

namespace OddPowerSumPlethysm

/-- The base field `K = ℚ(t)`. -/
abbrev K := RatFunc ℚ

/-- The odd power-sum ring `MvPolynomial ℕ K`, with `X k` standing for `p_{2k+1}`. -/
abbrev Lam := MvPolynomial ℕ K

/-- The transcendental parameter `t ∈ K`. -/
def tt : K := RatFunc.X

/-- The scalar `c_k = 1 - t^{2k+1}`. -/
def cc (k : ℕ) : K := 1 - tt ^ (2 * k + 1)

lemma cc_ne (k : ℕ) : cc k ≠ 0 := by
  by_contra h_contra
  have h_eq : (1 - (RatFunc.X : RatFunc ℚ) ^ (2 * k + 1)) = 0 := by
    exact h_contra
  convert absurd h_eq ?_
  rw [ show ( 1 - RatFunc.X ^ ( 2 * k + 1 ) : RatFunc ℚ ) = algebraMap ( Polynomial ℚ ) ( RatFunc ℚ ) ( 1 - Polynomial.X ^ ( 2 * k + 1 ) ) by simp +decide, IsFractionRing.to_map_eq_zero_iff ]
  exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num )

/-- The inverse scalar `1 / (1 - t^{2k+1})`. -/
def dd (k : ℕ) : K := 1 / cc k

/-- The plethystic endomorphism `φ_t : p_{2k+1} ↦ (1 - t^{2k+1}) p_{2k+1}`. -/
def phiT : Lam →ₐ[K] Lam :=
  MvPolynomial.aeval (fun k => MvPolynomial.C (cc k) * X k)

/-- The inverse plethystic endomorphism `ψ_t : p_{2k+1} ↦ p_{2k+1} / (1 - t^{2k+1})`. -/
def psiT : Lam →ₐ[K] Lam :=
  MvPolynomial.aeval (fun k => MvPolynomial.C (dd k) * X k)

@[simp] lemma phiT_X (k : ℕ) : phiT (X k) = MvPolynomial.C (cc k) * X k := by
  simp [phiT]

@[simp] lemma psiT_X (k : ℕ) : psiT (X k) = MvPolynomial.C (dd k) * X k := by
  simp [psiT]

/-- `ψ_t` is a left inverse of `φ_t`. -/
lemma psiT_phiT : psiT.comp phiT = AlgHom.id K Lam := by
  ext x
  simp +decide [ phiT, psiT ]
  simp +decide [ dd, cc_ne ]

/-- `ψ_t` is a right inverse of `φ_t`. -/
lemma phiT_psiT : phiT.comp psiT = AlgHom.id K Lam := by
  ext x
  simp +decide [ dd, cc_ne ]

/-- **`φ_t` is an algebra automorphism** of the odd power-sum ring. -/
def phiTEquiv : Lam ≃ₐ[K] Lam :=
  AlgEquiv.ofAlgHom phiT psiT phiT_psiT psiT_phiT

@[simp] lemma phiTEquiv_apply (f : Lam) : phiTEquiv f = phiT f := rfl

/-
`φ_t` is bijective.
-/
lemma phiT_bijective : Function.Bijective phiT := by
  convert ( phiTEquiv.bijective : Function.Bijective ( phiTEquiv : Lam → Lam ) )

/-! ### `φ_t` is diagonal in the monomial basis -/

/-
`φ_t` scales each variable-power diagonally: `φ_t(p_n^m) = (1 - t^n)^m p_n^m`.
-/
lemma phiT_monomial_pow (k m : ℕ) :
    phiT (X k ^ m) = MvPolynomial.C (cc k ^ m) * X k ^ m := by
      induction m <;> simp_all +decide [ pow_succ, mul_assoc ];
      exact Or.inl ( by rw [ mul_left_comm ] )

/-! ### `φ_t` preserves the grading -/

/-
**`φ_t` is degree-preserving**: it maps homogeneous polynomials of degree `m` to
homogeneous polynomials of degree `m`.
-/
lemma phiT_isHomogeneous {f : Lam} {m : ℕ} (hf : f.IsHomogeneous m) :
    (phiT f).IsHomogeneous m := by
      convert hf.aeval (fun k => MvPolynomial.C (cc k) * MvPolynomial.X k) (fun k => MvPolynomial.isHomogeneous_C_mul_X (cc k) k) using 1;
      ring

/-! ### Non-triviality boundary (the deformation is real) -/

/-
`φ_t` genuinely moves `p_1`: `φ_t(p_1) = (1 - t) p_1 ≠ p_1`.
-/
lemma phiT_X_zero_ne : phiT (X 0) ≠ X 0 := by
  intro h; have := congr_arg ( MvPolynomial.eval ( fun _ => 1 ) ) h; norm_num at this;
  unfold cc at this;
  norm_num [ tt ] at this;
  exact absurd this ( RatFunc.X_ne_zero )

/-
**`φ_t` is not the identity.**  "Plethystic triviality" therefore means *automorphic*,
not *identity*: the `t`-deformation is a genuine, invertible relabelling.
-/
theorem phiT_ne_id : phiT ≠ AlgHom.id K Lam := by
  intro h
  exact phiT_X_zero_ne (by rw [h]; rfl)

end OddPowerSumPlethysm