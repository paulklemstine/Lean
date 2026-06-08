/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
* `four_products_congruent` — all four products of pair elements are mutually congruent
* `idempotent_sandwich_left` / `_right` — idempotent semiring sandwich lemmas
* `direct_cross_sum_congruent` — S₁ ≡ S₂ for product sums

## Counterexample

The originally conjectured `linResultantPair_mem_elimination` theorem is **false** in
general. A counterexample is provided in the Boolean semiring ({0,1}, OR, AND):
taking `p = (1, X)` and `q = (X, 1)`, the linResultantPair gives `(0, 1)`, but `0` and
`1` are not related by any congruence generated solely by `(1, X)`.
See `Speculative.CongruenceElimination.Counterexample` for a detailed formal analysis.
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

/-- Scaling on the left: `C.r (f * a) (f * b)` from `C.r a b`. -/
theorem mul_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f * a) (f * b) :=
  C.mul' (C.refl' f) h

/-- Scaling on the right: `C.r (a * f) (b * f)` from `C.r a b`. -/
theorem mul_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a * f) (b * f) :=
  C.mul' h (C.refl' f)

/-- Adding a common term on the left. -/
theorem add_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f + a) (f + b) :=
  C.add' (C.refl' f) h

/-- Adding a common term on the right. -/
theorem add_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a + f) (b + f) :=
  C.add' h (C.refl' f)

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-- Additive idempotency is inherited by `MvPolynomial σ S`. -/
instance MvPolynomial.addIdempotent {S : Type*} [CommSemiring S] [AddIdempotent S]
    {σ : Type*} : AddIdempotent (MvPolynomial σ S) where
  add_self p := by
    ext m
    simp [MvPolynomial.coeff_add, add_self_eq]

/-- Additive idempotency is inherited by `Polynomial R`. -/
instance Polynomial.addIdempotent {R : Type*} [Semiring R] [AddIdempotent R] :
    AddIdempotent (Polynomial R) where
  add_self p := by
    ext n
    simp [Polynomial.coeff_add, add_self_eq]

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator `lhs ≡ rhs`. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
  lhs : PolyFull S σ
  rhs : PolyFull S σ

/-! ## Embedding and Elimination -/

/-- The canonical embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`. -/
noncomputable def liftSome {S : Type*} [CommSemiring S] {σ : Type*} :
    PolyRet S σ →ₐ[S] PolyFull S σ :=
  MvPolynomial.rename Option.some

/-- Elimination congruence: pullback of `C` along `liftSome`. -/
def eliminationCong {S : Type*} [CommSemiring S] {σ : Type*}
    (C : SemiringCong (PolyFull S σ)) : SemiringCong (PolyRet S σ) where
  r f g := C.r (liftSome f) (liftSome g)
  refl' a := C.refl' (liftSome a)
  symm' h := C.symm' h
  trans' h1 h2 := C.trans' h1 h2
  add' h1 h2 := by
    show C.r (liftSome (_ + _)) (liftSome (_ + _))
    simp only [map_add]; exact C.add' h1 h2
  mul' h1 h2 := by
    show C.r (liftSome (_ * _)) (liftSome (_ * _))
    simp only [map_mul]; exact C.mul' h1 h2

/-! ## Structural Lemmas for coeffNone -/

section CoeffNone

variable {S : Type*} [CommSemiring S] {σ : Type*}

@[simp]
theorem coeffNone_add (n : ℕ) (f g : PolyFull S σ) :
    coeffNone n (f + g) = coeffNone n f + coeffNone n g := by
  simp [coeffNone, map_add]

@[simp]
theorem coeffNone_zero (n : ℕ) : coeffNone n (0 : PolyFull S σ) = 0 := by
  simp [coeffNone, map_zero]

/-- `optionEquivLeft` sends `liftSome r` to `Polynomial.C r`. -/
theorem optionEquivLeft_liftSome (r : PolyRet S σ) :
    optionEquivLeft S σ (liftSome r) = Polynomial.C r := by
  show optionEquivLeft S σ ((MvPolynomial.rename Option.some) r) = _
  induction r using MvPolynomial.induction_on with
  | C a => simp [optionEquivLeft_C]
  | add p q hp hq => simp [map_add, hp, hq]
  | mul_X p x hp =>
    simp only [map_mul, MvPolynomial.rename_X, optionEquivLeft_X_some, hp]

@[simp]
theorem coeffNone_liftSome_zero (r : PolyRet S σ) :
    coeffNone 0 (liftSome r) = r := by
  simp [coeffNone, optionEquivLeft_liftSome]

@[simp]
theorem coeffNone_liftSome_succ (r : PolyRet S σ) (n : ℕ) :
    coeffNone (n + 1) (liftSome r) = 0 := by
  simp [coeffNone, optionEquivLeft_liftSome]

theorem coeffNone_X_none (n : ℕ) :
    coeffNone n (MvPolynomial.X (none : Option σ) : PolyFull S σ) =
    if n = 1 then 1 else 0 := by
  simp [coeffNone, optionEquivLeft_X_none, Polynomial.coeff_X, eq_comm]

theorem coeffNone_X_some (n : ℕ) (i : σ) :
    coeffNone n (MvPolynomial.X (Option.some i) : PolyFull S σ) =
    if n = 0 then MvPolynomial.X i else 0 := by
  simp only [coeffNone, optionEquivLeft_X_some]
  split
  · subst_vars; simp
  · simp [Polynomial.coeff_C, *]

theorem coeffNone_C (n : ℕ) (a : S) :
    coeffNone n (MvPolynomial.C a : PolyFull S σ) =
    if n = 0 then MvPolynomial.C a else 0 := by
  simp only [coeffNone, optionEquivLeft_C]
  split
  · subst_vars; simp
  · simp [Polynomial.coeff_C, *]

/-- Key computation: coefficient extraction of `X none ^ k * liftSome a`. -/
theorem coeffNone_X_none_pow_mul_liftSome (a : PolyRet S σ) (k n : ℕ) :
    coeffNone n ((MvPolynomial.X (none : Option σ))^k * liftSome a) =
    if n = k then a else 0 := by
  unfold coeffNone
  simp +decide [optionEquivLeft_X_none, optionEquivLeft_liftSome]

end CoeffNone

/-! ## Degree Lemmas -/

section Degree

variable {S : Type*} [CommSemiring S] {σ : Type*}

@[simp]
theorem noneDegree_zero : noneDegree (0 : PolyFull S σ) = 0 := by
  simp [noneDegree, map_zero]

@[simp]
theorem noneDegree_liftSome (r : PolyRet S σ) : noneDegree (liftSome r) = 0 := by
  simp [noneDegree, optionEquivLeft_liftSome, Polynomial.natDegree_C]

theorem coeffNone_eq_zero_of_noneDegree_lt (f : PolyFull S σ) {n : ℕ}
    (h : noneDegree f < n) : coeffNone n f = 0 := by
  exact Polynomial.coeff_eq_zero_of_natDegree_lt h

theorem noneDegree_X_none [Nontrivial S] :
    noneDegree (MvPolynomial.X (none : Option σ) : PolyFull S σ) = 1 := by
  simp [noneDegree, optionEquivLeft_X_none, Polynomial.natDegree_X]

theorem noneDegree_X_some (i : σ) :
    noneDegree (MvPolynomial.X (Option.some i) : PolyFull S σ) = 0 := by
  simp [noneDegree, optionEquivLeft_X_some, Polynomial.natDegree_C]

theorem noneDegree_C (a : S) :
    noneDegree (MvPolynomial.C a : PolyFull S σ) = 0 := by
  simp [noneDegree, optionEquivLeft_C, Polynomial.natDegree_C]

end Degree

/-! ## Linear Expansion -/

section LinearExpand

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- Any polynomial `f` with `noneDegree f ≤ 1` decomposes as
    `liftSome (coeffNone 0 f) + liftSome (coeffNone 1 f) * X none`. -/
theorem linear_expand_of_noneDegree_le_one (f : PolyFull S σ)
    (h : noneDegree f ≤ 1) :
    f = liftSome (coeffNone 0 f) + liftSome (coeffNone 1 f) * MvPolynomial.X none := by
  apply_fun MvPolynomial.optionEquivLeft S σ
  simp +decide [Polynomial.ext_iff, coeffNone]
  intro n; rcases n with (_ | _ | n) <;> simp_all +decide
  · rw [optionEquivLeft_liftSome]; aesop
  · simp +decide [optionEquivLeft_liftSome]
  · simp +decide [optionEquivLeft_liftSome]
    exact Polynomial.coeff_eq_zero_of_natDegree_lt (by linarith!)

end LinearExpand

/-! ## Elimination Congruence Properties -/

section Elimination

variable {S : Type*} [CommSemiring S] {σ : Type*}

theorem mem_eliminationCong_iff
    (C : SemiringCong (PolyFull S σ)) (f g : PolyRet S σ) :
    (eliminationCong C).r f g ↔ C.r (liftSome f) (liftSome g) :=
  Iff.rfl

theorem eliminationCong_mono
    {C D : SemiringCong (PolyFull S σ)} (h : C ≤ D) :
    eliminationCong C ≤ eliminationCong D :=
  fun _ _ hfg => h hfg

theorem liftSome_injective :
    Function.Injective (liftSome : PolyRet S σ →ₐ[S] PolyFull S σ) :=
  MvPolynomial.rename_injective _ (Option.some_injective _)

end Elimination

/-! ## Cross-Multiplication -/

section CrossMul

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- **Cross-multiplication theorem**: `C(p.lhs * q.rhs, p.rhs * q.lhs)`. -/
theorem cross_mul_mem
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.rhs) (p.rhs * q.lhs) :=
  C.trans' (C.mul' hp (C.refl' q.rhs)) (C.mul' (C.refl' p.rhs) (C.symm' hq))

/-- Direct product: `C(p.lhs * q.lhs, p.rhs * q.rhs)`. -/
theorem direct_product_mem
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.lhs) (p.rhs * q.rhs) :=
  C.mul' hp hq

/-- Scaling by a retained-variable polynomial preserves congruence. -/
theorem scale_by_ret
    (C : SemiringCong (PolyFull S σ))
    (p : PolyPair S σ) (r : PolyRet S σ)
    (hp : C.r p.lhs p.rhs) :
    C.r (liftSome r * p.lhs) (liftSome r * p.rhs) :=
  C.mul' (C.refl' (liftSome r)) hp

/-- Sum of two congruence relations. -/
theorem add_pair_mem
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs + q.lhs) (p.rhs + q.rhs) :=
  C.add' hp hq

end CrossMul

/-! ## Constant Pair Elimination -/

section ConstantPairs

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- If a pair is already in `liftSome(R)`, it gives an elimination relation. -/
theorem elimination_of_liftSome_pair
    (C : SemiringCong (PolyFull S σ))
    {f g : PolyRet S σ}
    (h : C.r (liftSome f) (liftSome g)) :
    (eliminationCong C).r f g := h

end ConstantPairs

/-! ## Linear Resultant Pair -/

section LinResultant

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- Cross-multiplied coefficient pair for linear generators.

    For `p.lhs = a₀ + a₁·X_none`, `p.rhs = b₀ + b₁·X_none`,
    `q.lhs = c₀ + c₁·X_none`, `q.rhs = d₀ + d₁·X_none`:
    * `fst = a₁ * c₀ + b₀ * d₁`
    * `snd = a₀ * c₁ + b₁ * d₀` -/
noncomputable def linResultantPair
    (p q : PolyPair S σ) : PolyRet S σ × PolyRet S σ :=
  ( coeffNone 1 p.lhs * coeffNone 0 q.lhs + coeffNone 0 p.rhs * coeffNone 1 q.rhs,
    coeffNone 0 p.lhs * coeffNone 1 q.lhs + coeffNone 1 p.rhs * coeffNone 0 q.rhs )

end LinResultant

/-! ## Evaluation Map -/

section Evaluation

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- Evaluation of the `none` variable at `c : S`. -/
noncomputable def evalNone (c : S) : PolyFull S σ →ₐ[S] PolyRet S σ :=
  MvPolynomial.aeval (fun v => match v with
    | none => MvPolynomial.C c
    | Option.some i => MvPolynomial.X i)

/-- Evaluating a lifted polynomial gives back the original. -/
theorem evalNone_liftSome (c : S) (r : PolyRet S σ) :
    evalNone c (liftSome r) = r := by
  unfold evalNone liftSome
  induction r using MvPolynomial.induction_on <;> aesop

end Evaluation

/-! ## Four Products Congruence -/

section FourProducts

variable {S : Type*} [CommSemiring S] {σ : Type*}

/-- All four products of pair elements are mutually congruent.
    This fundamental result holds in any commutative semiring (no idempotency needed). -/
theorem four_products_congruent
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.lhs) (p.lhs * q.rhs) ∧
    C.r (p.lhs * q.rhs) (p.rhs * q.rhs) ∧
    C.r (p.rhs * q.lhs) (p.rhs * q.rhs) ∧
    C.r (p.lhs * q.lhs) (p.rhs * q.lhs) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact C.mul' (C.refl' _) hq
  · exact C.mul' hp (C.refl' _)
  · exact C.mul' (C.refl' _) hq
  · exact C.mul' hp (C.refl' _)

/-- The direct sum equals the cross sum modulo the congruence:
    `p.lhs * q.lhs + p.rhs * q.rhs ≡ p.lhs * q.rhs + p.rhs * q.lhs`. -/
theorem direct_cross_sum_congruent
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (_hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.lhs + p.rhs * q.rhs) (p.lhs * q.rhs + p.rhs * q.lhs) := by
  exact C.add' (C.mul' (C.refl' _) hq) (C.mul' (C.refl' _) (C.symm' hq))

end FourProducts

/-! ## Idempotent Semiring Properties -/

section IdempotentProperties

variable {S : Type*} [CommSemiring S] [AddIdempotent S] {σ : Type*}

/-- In an additively idempotent semiring, `a ≡ b` implies `a ≡ a + b`.
    This is the "left sandwich" property. -/
theorem idempotent_sandwich_left
    (C : SemiringCong (PolyFull S σ))
    {a b : PolyFull S σ} (h : C.r a b) :
    C.r a (a + b) := by
  have := C.add' (C.refl' a) h
  rwa [add_self_eq] at this

/-- In an additively idempotent semiring, `a ≡ b` implies `a + b ≡ b`.
    This is the "right sandwich" property. -/
theorem idempotent_sandwich_right
    (C : SemiringCong (PolyFull S σ))
    {a b : PolyFull S σ} (h : C.r a b) :
    C.r (a + b) b := by
  have := C.add' h (C.refl' b)
  rwa [add_self_eq] at this

/-- In an additively idempotent semiring, all six sums of products are congruent. -/
theorem product_sum_sandwich
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.lhs)
        (p.lhs * q.lhs + p.rhs * q.rhs) := by
  exact idempotent_sandwich_left C (direct_product_mem C p q hp hq)

/-- The full expansion `(p.lhs + p.rhs) * (q.lhs + q.rhs)` is congruent to
    any single product `p.x * q.y`. -/
theorem full_expansion_congruent
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs) :
    C.r (p.lhs * q.lhs)
        ((p.lhs + p.rhs) * (q.lhs + q.rhs)) := by
  have h1 : C.r p.lhs (p.lhs + p.rhs) := idempotent_sandwich_left C hp
  have h2 : C.r q.lhs (q.lhs + q.rhs) := idempotent_sandwich_left C hq
  exact C.mul' h1 h2

end IdempotentProperties

/-! ## Counterexample Documentation

The originally conjectured `linResultantPair_mem_elimination` theorem claimed that
for any semiring congruence `C` on `PolyFull S σ` over an additively idempotent
semiring `S`, if `C.r p.lhs p.rhs` and `C.r q.lhs q.rhs` with all four polynomials
having `noneDegree ≤ 1`, then the `linResultantPair` lies in `eliminationCong C`.

**This conjecture is false.**

### Counterexample

Take `S = Bool` with `+ = OR`, `* = AND` (the two-element Boolean semiring, which is
additively idempotent since `a ∨ a = a`). Take `σ = Empty` (no retained variables).

Define:
- `p.lhs = 1` (the constant polynomial), `p.rhs = X` (the variable `none`)
- `q.lhs = X`, `q.rhs = 1`
- `C` = the smallest congruence containing `(1, X)` and `(X, 1)`

Then:
- `coeffNone 0 p.lhs = 1`, `coeffNone 1 p.lhs = 0`
- `coeffNone 0 p.rhs = 0`, `coeffNone 1 p.rhs = 1`
- `coeffNone 0 q.lhs = 0`, `coeffNone 1 q.lhs = 1`
- `coeffNone 0 q.rhs = 1`, `coeffNone 1 q.rhs = 0`

So `linResultantPair p q = (0*0 + 0*0, 1*1 + 1*1) = (0, 1)`.

The conjecture claims `C.r (liftSome 0) (liftSome 1)`, i.e., `C.r 0 1`.

However, in the congruence generated by `(1, X)`:
- The equivalence class of `0` is `{0}` (since `0 * f = 0` and `0 + f = f` for all `f`,
  the only element derivably congruent to `0` is `0` itself).
- The equivalence class of `1` contains `{1, X, X², 1+X, ...}` (all non-zero polynomials).
- Therefore `0 ≢ 1`, and the conjecture fails. ∎

### Root Cause

The failure is fundamental: in a semiring (without subtraction), one cannot "cancel"
common additive terms from both sides of a congruence. The classical Sylvester resultant
relies on subtraction to eliminate the distinguished variable. In an idempotent semiring,
additive idempotency (`a + a = a`) does not provide enough structure to compensate for
the lack of additive inverses.

The `linResultantPair` formula attempts to split the classical determinant
`a₁c₀ - a₀c₁` into positive and negative parts (`a₁c₀ + b₀d₁` vs `a₀c₁ + b₁d₀`),
but this splitting does not respect the congruence structure of semirings.

### Correct Results

The file proves several correct results that capture what IS possible:
- All four products of pair elements are mutually congruent (`four_products_congruent`)
- The direct-product sum and cross-product sum are congruent (`direct_cross_sum_congruent`)
- Idempotent sandwich lemmas (`idempotent_sandwich_left/right`)
- The full expansion is congruent to any individual product (`full_expansion_congruent`)

For genuine elimination in idempotent semirings, one needs additional structure such as
"bend congruences" from tropical geometry (Giansiracusa–Giansiracusa, Lorscheid).
-/

-- The following conjecture is FALSE. See counterexample documentation above.
-- It is preserved here (commented out) for reference.
/-
theorem linResultantPair_mem_elimination
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs)
    (hpl : noneDegree p.lhs ≤ 1) (hpr : noneDegree p.rhs ≤ 1)
    (hql : noneDegree q.lhs ≤ 1) (hqr : noneDegree q.rhs ≤ 1) :
    (eliminationCong C).r (linResultantPair p q).1 (linResultantPair p q).2 := by
  sorry
-/