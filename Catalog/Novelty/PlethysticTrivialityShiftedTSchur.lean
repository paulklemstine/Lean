/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Plethystic Triviality of the Shifted `t`-Schur Basis

This file develops the *plethystic triviality* phenomenon for the shifted `t`-Schur
functions `S^t_λ` relative to the Schur `Q`-functions `Q_λ`.

The base construction (vertex operators, the one-row functions `q`/`qt`, the operators
`B`/`Bt`, and the headline identity `S^t_λ = φ_t(Q_λ)`) reproduces the proven cycle
`ShiftedTSchur` (catalog reference "Schur Q-functions / neutral fermion vertex
operators / odd power-sum symmetric functions").  Because cross-file imports inside the
catalog tree do not resolve in this build, the construction is reproduced here so the
file is self-contained.

The **new** mathematical content (the research extension of this cycle) is:

* `phiTEquiv` — the plethystic endomorphism `φ_t` is in fact an *algebra automorphism*
  of the odd power-sum ring, with explicit inverse `ψ_t : p_n ↦ p_n / (1 - t^n)`
  (`psiT`, `psiT_phiT`, `phiT_psiT`).
* `Qfun_eq_psiT_Sfun` — the change of basis is invertible: `Q_λ = ψ_t(S^t_λ)`.  This is
  the precise sense in which the `t`-deformation is *trivial*: it is undone by an algebra
  automorphism.
* `linearIndependent_Sfun_iff` — consequently `{S^t_λ}` is `K`-linearly independent **iff**
  `{Q_λ}` is.  The deformation carries no new linear-algebraic information; it is a mere
  invertible relabelling of the Schur-`Q` basis.
* `Qfun_singleton`, `Sfun_singleton` — explicit small-case verification (`λ = (1)`),
  realizing the "coefficient comparison in the finite odd power-sum ring" falsifiability
  test.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):  The map `Q_λ ↦ S^t_λ` is not merely a coincidental identity
  but is induced by an *invertible* operator; hence the `t`-Schur family is a trivial
  (automorphic) relabelling of the Schur-`Q` basis, sharing all of its linear-algebraic
  structure.
Experiment (Experimenter):  Define `ψ_t(p_n) = p_n/(1-t^n)` and verify `ψ_t ∘ φ_t = id`
  and `φ_t ∘ ψ_t = id` on generators (`MvPolynomial.algHom_ext`).  Package into an
  `AlgEquiv` and transfer linear independence along the induced linear equivalence.
Analysis (Analyst):  Invertibility hinges on `1 - t^n ≠ 0` for the transcendental `t`
  (`cc_ne`); over a ring where some `1 - t^n` vanishes, `φ_t` degenerates and triviality
  fails — this is the genuine boundary of the phenomenon.
Critique (Critic):  Triviality must NOT mean `φ_t = id`; we record `phiT (X 0) ≠ X 0`
  (in the companion file `OddPowerSumPlethysm`) to confirm the deformation is real.
Synthesis (PI):  "Plethystic triviality" = `φ_t ∈ Aut`, so `S^t` and `Q` are equivalent
  bases; the deformation lives entirely in the diagonal scalars `∏(1 - t^{n})`.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open MvPolynomial Polynomial

noncomputable section

namespace PlethysticTrivialityShiftedTSchur

/-- The base field `K = ℚ(t)`. -/
abbrev K := RatFunc ℚ

/-- The ring of symmetric functions in the odd power sums, modeled as the polynomial ring
`MvPolynomial ℕ K` where the variable `X k` stands for the odd power sum `p_{2k+1}`. -/
abbrev Lam := MvPolynomial ℕ K

/-- The transcendental parameter `t ∈ K`. -/
def tt : K := RatFunc.X

/-- The odd power sum `p_{2k+1}`, realized as the variable `X k`. -/
def p (k : ℕ) : Lam := X k

/-- The scalar `c_k = 1 - t^{2k+1}` by which `φ_t` scales the `k`-th odd power sum. -/
def cc (k : ℕ) : K := 1 - tt ^ (2 * k + 1)

lemma cc_ne (k : ℕ) : cc k ≠ 0 := by
  by_contra h_contra
  have h_eq : (1 - (RatFunc.X : RatFunc ℚ) ^ (2 * k + 1)) = 0 := by
    exact h_contra;
  convert absurd h_eq ?_;
  rw [ show ( 1 - RatFunc.X ^ ( 2 * k + 1 ) : RatFunc ℚ ) = algebraMap ( Polynomial ℚ ) ( RatFunc ℚ ) ( 1 - Polynomial.X ^ ( 2 * k + 1 ) ) by simp +decide, IsFractionRing.to_map_eq_zero_iff ];
  exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num )

/-! ### The plethystic endomorphism `φ_t` -/

/-- The plethystic endomorphism `φ_t`, the `K`-algebra map sending the odd power sum
`p_{2k+1}` to `(1 - t^{2k+1}) p_{2k+1}`. -/
def phiT : Lam →ₐ[K] Lam :=
  MvPolynomial.aeval (fun k => MvPolynomial.C (cc k) * X k)

@[simp] lemma phiT_X (k : ℕ) : phiT (X k) = MvPolynomial.C (cc k) * X k := by
  simp [phiT]

/-- `φ_t(p_{2k+1}) = (1 - t^{2k+1}) p_{2k+1}`. -/
lemma phiT_p (k : ℕ) : phiT (p k) = MvPolynomial.C (cc k) * p k := by
  simp [p, phiT_X]

/-! ### The creation (one-row) functions -/

/-- Generic creation functions: the coefficients of `exp(∑_k (2/(2k+1)) (cf k) z^{2k+1})`,
defined by the Newton recursion coming from the logarithmic derivative of the kernel. -/
def qGen (cf : ℕ → Lam) : ℕ → Lam
  | 0 => 1
  | (m + 1) => MvPolynomial.C ((1 : K) / ((m : K) + 1)) *
      ∑ k ∈ Finset.range (m / 2 + 1), MvPolynomial.C (2 : K) * cf k * qGen cf (m - 2 * k)
  decreasing_by omega

/-- The one-row Schur `Q`-functions `q_n = Q_{(n)}`. -/
def q : ℕ → Lam := qGen (fun k => X k)

/-- The `t`-deformed one-row functions, built from the `t`-deformed odd power sums. -/
def qt : ℕ → Lam := qGen (fun k => MvPolynomial.C (cc k) * X k)

lemma qt_eq_phiT_q (n : ℕ) : qt n = phiT (q n) := by
  unfold qt q;
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide;
  · simp [qGen];
  · unfold qGen; aesop;
  · unfold qGen; simp +decide [ ih ] ;

/-! ### The annihilation (Taylor shift) operators -/

/-- The annihilation part of the vertex operator, as a `K`-algebra map `Lam → Lam[u]`. -/
def annGen (d : ℕ → K) : Lam →ₐ[K] Polynomial Lam :=
  MvPolynomial.aeval
    (fun k => Polynomial.C (X k)
      - Polynomial.C (algebraMap K Lam (d k)) * Polynomial.X ^ (2 * k + 1))

/-- Annihilation for the Schur `Q` vertex operator (adjoint normalization constant `4`). -/
def annShift : Lam →ₐ[K] Polynomial Lam := annGen (fun _ => (4 : K))

/-- Annihilation for the `t`-deformed vertex operator with constant `4 / (1 - t^{2k+1})`. -/
def annShiftT : Lam →ₐ[K] Polynomial Lam := annGen (fun k => (4 : K) / cc k)

lemma annShiftT_phiT (f : Lam) :
    annShiftT (phiT f) = (annShift f).map (phiT : Lam →+* Lam) := by
  have h_annShiftT : ∀ p : Lam, annShiftT (phiT p) = Polynomial.map (phiT : Lam →+* Lam) (annShift p) := by
    intro p
    unfold annShiftT annShift;
    unfold annGen; simp +decide [ phiT ] ;
    induction p using MvPolynomial.induction_on <;> simp_all +decide [ Polynomial.map_mul, Polynomial.map_pow, Polynomial.map_X ];
    left; ring_nf; norm_num [ cc_ne ] ;
    rw [ ← mul_assoc, ← Polynomial.C_mul, ← MvPolynomial.C_mul ] ; norm_num [ cc_ne ] ;
  exact h_annShiftT f

/-! ### The vertex operator components and the symmetric functions -/

/-- The linear functional extracting `∑_m (coeff_m p) · (qf (n+m))` from a polynomial. -/
def Tsum (qf : ℕ → Lam) (n : ℕ) (pp : Polynomial Lam) : Lam :=
  pp.sum (fun m c => qf (n + m) * c)

/-- The `n`-th component `B_n` of the Schur `Q` vertex operator. -/
def B (n : ℕ) (f : Lam) : Lam := Tsum q n (annShift f)

/-- The `n`-th component `Bt_n` of the `t`-deformed vertex operator. -/
def Bt (n : ℕ) (f : Lam) : Lam := Tsum qt n (annShiftT f)

lemma Tsum_map_phiT (n : ℕ) (pp : Polynomial Lam) :
    Tsum qt n (pp.map (phiT : Lam →+* Lam)) = phiT (Tsum q n pp) := by
  unfold Tsum;
  simp +decide [ Polynomial.sum_def, qt_eq_phiT_q ];
  refine' Finset.sum_subset _ _ <;> intro x hx <;> aesop

/-- The intertwining (Pieri-compatible) relation: `φ_t` conjugates `B` into `Bt`. -/
lemma Bt_phiT (n : ℕ) (f : Lam) : Bt n (phiT f) = phiT (B n f) := by
  unfold Bt B
  rw [annShiftT_phiT]
  exact Tsum_map_phiT n (annShift f)

/-- The Schur `Q`-function `Q_λ`, where `λ` is given by its list of parts (largest first). -/
def Qfun (l : List ℕ) : Lam := l.foldr B 1

/-- The shifted `t`-Schur function `S^t_λ`. -/
def Sfun (l : List ℕ) : Lam := l.foldr Bt 1

/-- **Main identity (general form).** For every list of parts `l`, `S^t_λ = φ_t(Q_λ)`. -/
theorem Sfun_eq_phiT_Qfun (l : List ℕ) : Sfun l = phiT (Qfun l) := by
  induction l with
  | nil => simp [Sfun, Qfun]
  | cons a t ih =>
      show Bt a (Sfun t) = phiT (B a (Qfun t))
      rw [ih, Bt_phiT]

/-- A strict partition, given as a list of its parts: strictly decreasing and positive. -/
def IsStrictPartition (l : List ℕ) : Prop :=
  l.Pairwise (· > ·) ∧ ∀ x ∈ l, 0 < x

/-- **The identity `S^t_λ = φ_t(Q_λ)` for strict partitions `λ`.** -/
theorem shifted_tSchur_eq_phiT_Q (l : List ℕ) (_hl : IsStrictPartition l) :
    Sfun l = phiT (Qfun l) :=
  Sfun_eq_phiT_Qfun l

/-! ## New content: the plethystic substitution is an automorphism -/

/-- The inverse scalar `1 / (1 - t^{2k+1})`. -/
def dd (k : ℕ) : K := 1 / cc k

/-- The inverse plethystic endomorphism `ψ_t`, sending `p_{2k+1} ↦ p_{2k+1} / (1 - t^{2k+1})`. -/
def psiT : Lam →ₐ[K] Lam :=
  MvPolynomial.aeval (fun k => MvPolynomial.C (dd k) * X k)

@[simp] lemma psiT_X (k : ℕ) : psiT (X k) = MvPolynomial.C (dd k) * X k := by
  simp [psiT]

/-
`ψ_t` is a left inverse of `φ_t`.
-/
lemma psiT_phiT : psiT.comp phiT = AlgHom.id K Lam := by
  ext x;
  simp +decide [ phiT, psiT ];
  simp +decide [ dd, cc_ne ]

/-
`ψ_t` is a right inverse of `φ_t`.
-/
lemma phiT_psiT : phiT.comp psiT = AlgHom.id K Lam := by
  ext x;
  simp +decide [ dd, cc_ne ]

/-- **The plethystic substitution `φ_t` is an algebra automorphism** of the odd power-sum
ring, with explicit inverse `ψ_t`. -/
def phiTEquiv : Lam ≃ₐ[K] Lam :=
  AlgEquiv.ofAlgHom phiT psiT phiT_psiT psiT_phiT

@[simp] lemma phiTEquiv_apply (f : Lam) : phiTEquiv f = phiT f := rfl

/-
`φ_t` is injective.
-/
lemma phiT_injective : Function.Injective phiT := by
  convert phiTEquiv.injective

/-
**Invertibility of the change of basis** (the triviality statement): the Schur-`Q`
function is recovered from the shifted `t`-Schur function by the inverse plethysm `ψ_t`.
-/
theorem Qfun_eq_psiT_Sfun (l : List ℕ) : Qfun l = psiT (Sfun l) := by
  rw [ Sfun_eq_phiT_Qfun ];
  have := psiT_phiT;
  exact congr_arg ( fun f => f ( Qfun l ) ) this.symm

/-
**Basis triviality.** A family of shifted `t`-Schur functions is `K`-linearly
independent if and only if the corresponding family of Schur-`Q` functions is.  The
`t`-deformation is a mere invertible relabelling of the Schur-`Q` basis.
-/
theorem linearIndependent_Sfun_iff {ι : Type*} (g : ι → List ℕ) :
    LinearIndependent K (fun i => Sfun (g i)) ↔
      LinearIndependent K (fun i => Qfun (g i)) := by
        constructor;
        · intro h;
          convert h.map' _ _;
          rotate_left;
          exact ( phiTEquiv.symm.toLinearMap );
          · exact LinearMap.ker_eq_bot_of_injective phiTEquiv.symm.injective;
          · convert Qfun_eq_psiT_Sfun ( g _ ) using 1;
        · intro h;
          convert h.map' ( phiTEquiv.toLinearMap ) _;
          · exact Sfun_eq_phiT_Qfun _;
          · exact LinearMap.ker_eq_bot_of_injective phiTEquiv.injective

/-! ### Explicit small-case verification (`λ = (1)`) -/

/-
`Q_{(1)} = 2 p_1`.
-/
lemma Qfun_singleton : Qfun [1] = MvPolynomial.C 2 * X 0 := by
  unfold Qfun; simp +decide [ B, annShift, annGen ] ;
  unfold Tsum q; norm_num [ Polynomial.sum ] ;
  erw [ Polynomial.support_monomial ] <;> norm_num [ qGen ]

/-
`S^t_{(1)} = 2 (1 - t) p_1 = (1 - t) Q_{(1)}`, exactly the odd plethysm `p_1 ↦ (1-t)p_1`.
-/
lemma Sfun_singleton : Sfun [1] = MvPolynomial.C (2 * cc 0) * X 0 := by
  rw [ Sfun_eq_phiT_Qfun, Qfun_singleton ];
  simp +decide [ mul_assoc, phiT_X ]

end PlethysticTrivialityShiftedTSchur