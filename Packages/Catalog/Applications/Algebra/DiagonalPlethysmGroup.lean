/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The diagonal plethysm group and the boundary of plethystic triviality

This file generalises the single operator `φ_t : p_{2k+1} ↦ (1 - t^{2k+1}) p_{2k+1}`
studied in `OddPowerSumPlethysm` and `PlethysticTrivialityShiftedTSchur` to the whole
*diagonal plethysm group*: the family of `K`-algebra endomorphisms of the odd power-sum
ring `Lam = MvPolynomial ℕ K` that scale each generator `X k` (standing for `p_{2k+1}`)
by a scalar `a k`,
`diagHom a : p_{2k+1} ↦ (a k) · p_{2k+1}`.

These maps are exactly the endomorphisms that are *diagonal in the monomial basis*, and
they form the structural backbone of the `t`-Schur / Schur-`Q` story: the shifted
`t`-Schur isomorphism is the special member `φ_t = diagHom (k ↦ 1 - t^{2k+1})`.

## Main results

### Structure of the parametrisation

* `diagHom_one`, `diagHom_comp` — `diagHom` turns pointwise multiplication of parameter
  sequences into composition of operators: `diagHom 1 = id` and
  `(diagHom a).comp (diagHom b) = diagHom (a * b)`.
* `diagHom_param_injective` — **injectivity of `diagHom`**: the assignment
  `a ↦ diagHom a` is injective.  Equivalently, the "diagonal cocycle" `a ↦ diagHom a`
  has trivial kernel inside the odd power-sum ring: two diagonal operators that agree on
  every generator agree as parameter sequences (the coefficient/coboundary comparison in
  the monomial basis).
* `diagGroupHom` — the diagonal plethysm group as a genuine group homomorphism
  `(ℕ → Kˣ) →* (Lam ≃ₐ[K] Lam)` from invertible parameter sequences to automorphisms,
  and `diagGroupHom_injective` — it is injective, so the diagonal plethysm group is a
  faithful copy of `(Kˣ)^ℕ`.

### Injectivity and its failure (counterexamples)

* `diagEquiv` / `diagHom_injective_of_nonzero` — if every `a k ≠ 0`, then `diagHom a` is
  an automorphism (hence injective), with explicit inverse `diagHom (a⁻¹)`.
* `diagHom_not_injective_of_zero` — if some `a k = 0`, then `diagHom a` is **not**
  injective: it collapses `X k` to `0`.
* `diagHom_injective_iff` — the sharp dichotomy: `diagHom a` is injective iff `a` never
  vanishes.
* `diagHom_single_zero_not_injective`, `diagHom_const_zero_not_injective` — explicit
  counterexamples: a sequence vanishing at a single index, and the all-zero sequence.

### Relation to the shifted `t`-Schur isomorphism

* `phiT_eq_diagHom`, `phiT_injective` — over `K = ℚ(t)` the shifted `t`-Schur operator
  `φ_t` is the diagonal member `diagHom cc` with `cc k = 1 - t^{2k+1}`, and it is
  injective precisely because the transcendental `t` makes every `cc k ≠ 0` (`cc_ne`).
* `ccAt`, `ccAt_one_eq_zero`, `phiT_specialize_one_not_injective` — specialising the
  parameter `t ↦ 1` sends every scalar `1 - t^{2k+1}` to `0`, so the corresponding
  diagonal operator degenerates and is no longer injective.  This pins the shifted
  `t`-Schur isomorphism to the *non-vanishing locus* of the diagonal plethysm group: it
  is an automorphism exactly because `t` avoids the roots of `1 - t^{2k+1}`.

All lemmas are proved bottom-up from earlier ones; the file is self-contained and free of
circular dependencies.
-/
import Mathlib

open MvPolynomial

noncomputable section

namespace DiagonalPlethysmGroup

/-! ## The diagonal plethysm operators over an arbitrary field -/

section AbstractField

variable {K : Type*} [Field K]

/-- The odd power-sum ring over `K`, with `X k` standing for the odd power sum
`p_{2k+1}`. -/
abbrev Lam (K : Type*) [Field K] := MvPolynomial ℕ K

/-- The diagonal plethysm operator attached to a parameter sequence `a : ℕ → K`:
the `K`-algebra endomorphism sending each generator `X k` (i.e. `p_{2k+1}`) to
`(a k) · X k`. -/
def diagHom (a : ℕ → K) : Lam K →ₐ[K] Lam K :=
  aeval (fun k => C (a k) * X k)

@[simp] lemma diagHom_X (a : ℕ → K) (k : ℕ) : diagHom a (X k) = C (a k) * X k := by
  simp [diagHom]

/-- The constant-one sequence induces the identity operator. -/
lemma diagHom_one : diagHom (1 : ℕ → K) = AlgHom.id K (Lam K) := by
  apply algHom_ext; intro k; simp [diagHom]

/-- `diagHom` turns pointwise multiplication of parameter sequences into composition of
operators. -/
lemma diagHom_comp (a b : ℕ → K) :
    (diagHom a).comp (diagHom b) = diagHom (a * b) := by
  apply algHom_ext; intro k
  simp [diagHom, mul_comm, mul_left_comm]

/-- **Injectivity of `diagHom`.** The assignment `a ↦ diagHom a` is injective: two
diagonal operators agreeing on the odd power-sum ring have equal parameter sequences.
This is the coefficient comparison (coboundary triviality) in the monomial basis. -/
theorem diagHom_param_injective : Function.Injective (diagHom : (ℕ → K) → _) := by
  intro a b h
  funext k
  have hk : diagHom a (X k) = diagHom b (X k) := by rw [h]
  rw [diagHom_X, diagHom_X] at hk
  have hfac : (C (a k) - C (b k)) * X k = 0 := by
    ring_nf; ring_nf at hk; linear_combination hk
  rcases mul_eq_zero.1 hfac with h1 | h2
  · exact C_injective ℕ K (sub_eq_zero.1 h1)
  · exact absurd h2 (X_ne_zero k)

/-! ## Automorphisms: the non-vanishing case -/

/-- When every scalar `a k` is nonzero, `diagHom a` is an algebra automorphism with
explicit inverse `diagHom (a⁻¹)`. -/
def diagEquiv (a : ℕ → K) (ha : ∀ k, a k ≠ 0) : Lam K ≃ₐ[K] Lam K :=
  AlgEquiv.ofAlgHom (diagHom a) (diagHom (fun k => (a k)⁻¹))
    (by
      rw [diagHom_comp]; convert diagHom_one; funext k
      simp [Pi.mul_apply, mul_inv_cancel₀ (ha k)])
    (by
      rw [diagHom_comp]; convert diagHom_one; funext k
      simp [Pi.mul_apply, inv_mul_cancel₀ (ha k)])

@[simp] lemma diagEquiv_apply (a : ℕ → K) (ha : ∀ k, a k ≠ 0) (f : Lam K) :
    diagEquiv a ha f = diagHom a f := rfl

/-- If every scalar is nonzero, `diagHom a` is injective. -/
lemma diagHom_injective_of_nonzero (a : ℕ → K) (ha : ∀ k, a k ≠ 0) :
    Function.Injective (diagHom a) :=
  (diagEquiv a ha).injective

/-- **Counterexample mechanism.** If some scalar `a k` vanishes, `diagHom a` collapses
the generator `X k` to `0` and hence is not injective. -/
lemma diagHom_not_injective_of_zero (a : ℕ → K) {k : ℕ} (hk : a k = 0) :
    ¬ Function.Injective (diagHom a) := by
  intro hinj
  have h0 : diagHom a (X k) = diagHom a 0 := by rw [diagHom_X, hk]; simp
  exact X_ne_zero k (hinj h0)

/-- **Sharp dichotomy.** `diagHom a` is injective iff the parameter sequence never
vanishes. -/
theorem diagHom_injective_iff (a : ℕ → K) :
    Function.Injective (diagHom a) ↔ ∀ k, a k ≠ 0 := by
  constructor
  · intro hinj k hk; exact diagHom_not_injective_of_zero a hk hinj
  · intro ha; exact diagHom_injective_of_nonzero a ha

/-! ## The diagonal plethysm group -/

/-- The automorphism attached to an *invertible* parameter sequence `a : ℕ → Kˣ`. -/
def diagUnit (a : ℕ → Kˣ) : Lam K ≃ₐ[K] Lam K :=
  diagEquiv (fun k => ((a k : K))) (fun k => (a k).ne_zero)

/-- **The diagonal plethysm group**, presented as a group homomorphism from the group
`(ℕ → Kˣ)` of invertible parameter sequences (under pointwise multiplication) to the
group of automorphisms of the odd power-sum ring. -/
def diagGroupHom : (ℕ → Kˣ) →* (Lam K ≃ₐ[K] Lam K) where
  toFun := diagUnit
  map_one' := by
    apply AlgEquiv.ext; intro f
    simp only [diagUnit, diagEquiv_apply]
    show diagHom (fun k => ((1 : ℕ → Kˣ) k : K)) f = _
    rw [show (fun k => ((1 : ℕ → Kˣ) k : K)) = (1 : ℕ → K) by funext k; simp, diagHom_one]
    rfl
  map_mul' a b := by
    apply AlgEquiv.ext; intro f
    show diagHom (fun k => ((a * b) k : K)) f = _
    have hsplit : (fun k => (((a * b) k : K))) = (fun k => ((a k : K))) * (fun k => ((b k : K))) := by
      funext k; simp [Pi.mul_apply]
    rw [hsplit, ← diagHom_comp]
    rfl

/-- **Faithfulness of the diagonal plethysm group.** The group homomorphism `diagGroupHom`
is injective, so the diagonal plethysm group is a faithful copy of `(Kˣ)^ℕ`. -/
theorem diagGroupHom_injective : Function.Injective (diagGroupHom : (ℕ → Kˣ) → _) := by
  intro a b h
  have hdiag : diagHom (fun k => ((a k : K))) = diagHom (fun k => ((b k : K))) := by
    apply AlgHom.ext; intro f
    have := AlgEquiv.ext_iff.1 h f
    simpa [diagGroupHom, diagUnit] using this
  have hcoe := diagHom_param_injective hdiag
  funext k; exact Units.ext (congrFun hcoe k)

/-! ## Explicit counterexamples -/

/-- **Counterexample 1 (single vanishing index).** A parameter sequence that is `0` at a
single index `k₀` (and `1` elsewhere) fails to induce an injective automorphism. -/
theorem diagHom_single_zero_not_injective (k0 : ℕ) :
    ¬ Function.Injective (diagHom (fun k => if k = k0 then (0 : K) else 1)) :=
  diagHom_not_injective_of_zero _ (k := k0) (by simp)

/-- **Counterexample 2 (total collapse).** The all-zero parameter sequence is the extreme
degenerate case: it sends every generator to `0`, so the operator is far from injective. -/
theorem diagHom_const_zero_not_injective :
    ¬ Function.Injective (diagHom (fun _ => (0 : K))) :=
  diagHom_not_injective_of_zero _ (k := 0) rfl

end AbstractField

/-! ## Relation to the shifted `t`-Schur isomorphism -/

section TSchur

/-- The base field `K = ℚ(t)`. -/
abbrev FF := RatFunc ℚ

/-- The transcendental parameter `t ∈ ℚ(t)`. -/
def tt : FF := RatFunc.X

/-- The shifted `t`-Schur scalar `c_k = 1 - t^{2k+1}`. -/
def cc (k : ℕ) : FF := 1 - tt ^ (2 * k + 1)

/-- Each shifted `t`-Schur scalar is nonzero, because `t` is transcendental over `ℚ`. -/
lemma cc_ne (k : ℕ) : cc k ≠ 0 := by
  by_contra h_contra
  have h_eq : (1 - (RatFunc.X : RatFunc ℚ) ^ (2 * k + 1)) = 0 := h_contra
  convert absurd h_eq ?_
  rw [show (1 - RatFunc.X ^ (2 * k + 1) : RatFunc ℚ)
        = algebraMap (Polynomial ℚ) (RatFunc ℚ) (1 - Polynomial.X ^ (2 * k + 1)) by
        simp +decide, IsFractionRing.to_map_eq_zero_iff]
  exact ne_of_apply_ne (Polynomial.eval 0) (by norm_num)

/-- The shifted `t`-Schur plethystic operator `φ_t`, realised as the diagonal member of
the diagonal plethysm group with parameter sequence `cc`. -/
def phiT : Lam FF →ₐ[FF] Lam FF := diagHom cc

/-- `φ_t` is literally the diagonal operator `diagHom cc`. -/
lemma phiT_eq_diagHom : phiT = diagHom cc := rfl

/-- `φ_t(p_{2k+1}) = (1 - t^{2k+1}) · p_{2k+1}`, the defining odd plethysm. -/
lemma phiT_X (k : ℕ) : phiT (X k) = C (cc k) * X k := by
  simp [phiT]

/-- **The shifted `t`-Schur isomorphism.** `φ_t` is injective (indeed an automorphism),
because every `cc k = 1 - t^{2k+1}` is nonzero.  This realises the headline triviality
result inside the diagonal plethysm group: the `t`-deformation sits at the non-vanishing
locus. -/
theorem phiT_injective : Function.Injective phiT :=
  diagHom_injective_of_nonzero cc cc_ne

/-- The family of scalars obtained by specialising the parameter to a value `s`:
`1 - s^{2k+1}`.  The shifted `t`-Schur scalars are the case `s = t` (`ccAt tt = cc`). -/
def ccAt (s : FF) (k : ℕ) : FF := 1 - s ^ (2 * k + 1)

lemma ccAt_tt : ccAt tt = cc := rfl

/-- Specialising the parameter `t ↦ 1` sends every scalar `1 - t^{2k+1}` to `0`. -/
lemma ccAt_one_eq_zero (k : ℕ) : ccAt 1 k = 0 := by simp [ccAt]

/-- **Boundary of the shifted `t`-Schur isomorphism.** Specialising the transcendental
parameter `t ↦ 1` degenerates the diagonal operator: `diagHom (ccAt 1)` is *not*
injective.  Thus `φ_t = diagHom (ccAt t)` is an isomorphism only away from the vanishing
locus of `1 - t^{2k+1}` — precisely the locus the transcendental `t` avoids
(`cc_ne`). -/
theorem phiT_specialize_one_not_injective :
    ¬ Function.Injective (diagHom (ccAt (1 : FF))) :=
  diagHom_not_injective_of_zero _ (k := 0) (ccAt_one_eq_zero 0)

end TSchur

end DiagonalPlethysmGroup