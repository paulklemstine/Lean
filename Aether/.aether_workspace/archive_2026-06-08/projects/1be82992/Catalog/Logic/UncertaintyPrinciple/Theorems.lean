/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Uncertainty Principle: Main Theorems

This file proves the core theorems connecting polynomial algebra to
uncertainty principles. The main results are:

1. **Polynomial Uncertainty Theorem**: A nonzero polynomial of degree d
   evaluated at n distinct points has at most d zeros, hence at least
   n - d nonzero evaluations. This is the algebraic engine behind
   ALL uncertainty principles.

2. **Degree-Evaluation Uncertainty**: For the Vandermonde transform,
   `degree + 1 + supportCard(evaluation) ≥ n + 1` for any nonzero
   coefficient vector. The "degree" plays the role of frequency bandwidth.

3. **Polynomial Identity Theorem**: A polynomial of degree < n that vanishes
   at n distinct points must be zero — the algebraic core of analytic
   continuation.

4. **Vandermonde Injectivity**: The polynomial evaluation map at distinct
   points is injective on bounded-degree polynomials.

5. **Transform Basis Spread**: Any transform with no zero kernel entries
   maps basis vectors to fully-supported vectors.

## The Deep Insight

The uncertainty principle is not about physics. It is about the algebraic
impossibility of a polynomial simultaneously vanishing at many points while
having low degree. The Fourier, Laplace, and Mellin transforms are, at their
core, polynomial evaluations (or limits thereof). The uncertainty principle
is a theorem about polynomials, not about quantum mechanics.
-/

import Logic.UncertaintyPrinciple.Defs

open Finset Polynomial BigOperators

noncomputable section

/-! ## Theorem 1: Polynomial Root Bound

The fundamental algebraic fact: a nonzero polynomial has at most `degree`
roots. This single fact implies every uncertainty principle. -/

/-
**Polynomial Root Bound.** If `p` is a nonzero polynomial over an
integral domain, then the number of roots of `p` in any finite set `S`
is at most `natDegree p`.
-/
theorem polynomial_zeros_le_degree {R : Type*} [CommRing R] [IsDomain R]
    (p : Polynomial R) (hp : p ≠ 0) (S : Finset R) (hS : ∀ x ∈ S, p.IsRoot x) :
    S.card ≤ p.natDegree := by
  convert Polynomial.card_roots' p |> le_trans ( Multiset.toFinset_card_le p.roots ) |> le_trans ( Finset.card_le_card <| show S ⊆ p.roots.toFinset from fun x hx => Multiset.mem_toFinset.2 <| Polynomial.mem_roots hp |>.2 <| hS x hx ) using 1;
  exact Classical.decEq R

/-
**Polynomial Nonzero Evaluations Bound.** Evaluating a nonzero polynomial
of degree `d` at `n` distinct points yields ≥ `n - d` nonzero values.
This is the "positive" uncertainty principle.
-/
theorem polynomial_nonzero_evals {F : Type*} [Field F] [DecidableEq F]
    (p : Polynomial F) (hp : p ≠ 0) (pts : Fin n → F)
    (h_inj : Function.Injective pts) :
    n - p.natDegree ≤ (Finset.univ.filter fun i => p.eval (pts i) ≠ 0).card := by
  have h_card_roots : (Finset.image pts (Finset.filter (fun i => p.eval (pts i) = 0) Finset.univ)).card ≤ p.natDegree := by
    have h_card_roots : (Finset.image pts (Finset.filter (fun i => p.eval (pts i) = 0) Finset.univ)).card ≤ p.roots.toFinset.card := by
      exact Finset.card_le_card fun x hx => by aesop;
    exact h_card_roots.trans ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) );
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff, Finset.card_image_of_injective _ h_inj ];
  omega

/-! ## Theorem 2: Polynomial-Evaluation Duality

The coefficient representation and evaluation representation of a
polynomial are dual: localizing one delocalizes the other. -/

/-- Convert a coefficient vector `c : Fin n → F` to a polynomial. -/
def coeffsToPoly {F : Type*} [Field F] (n : ℕ) (c : Fin n → F) : Polynomial F :=
  ∑ k : Fin n, Polynomial.C (c k) * Polynomial.X ^ (k : ℕ)

/-
The polynomial from a coefficient vector has degree < n.
-/
theorem coeffsToPoly_degree_lt {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (hn : 0 < n) (c : Fin n → F) :
    (coeffsToPoly n c).natDegree < n := by
  refine' lt_of_le_of_lt ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_lt_iff _ |>.2 _ );
  · exact hn;
  · exact fun i _ => lt_of_le_of_lt ( Polynomial.natDegree_C_mul_X_pow_le _ _ ) ( by simp )

/-
Evaluating `coeffsToPoly` gives `polyEval`.
-/
theorem coeffsToPoly_eval {F : Type*} [Field F] {n : ℕ}
    (c : Fin n → F) (x : F) :
    (coeffsToPoly n c).eval x = polyEval n c x := by
  simp +decide [ coeffsToPoly, polyEval, Polynomial.eval_finset_sum ]

/-
If the coefficient vector is nonzero, the polynomial is nonzero.
-/
theorem coeffsToPoly_ne_zero {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (c : Fin n → F) (hc : isNonzero c) :
    coeffsToPoly n c ≠ 0 := by
  obtain ⟨ k, hk ⟩ := hc;
  contrapose! hk;
  replace hk := congr_arg ( fun p => p.coeff ( k : ℕ ) ) hk ; simp_all +decide [ coeffsToPoly ] ;
  simp_all +decide [ Fin.val_inj ]

/-
**Degree-Evaluation Uncertainty Principle.** For a nonzero coefficient
vector evaluated via the Vandermonde transform at n distinct points:

  `(natDegree of polynomial) + (# nonzero evaluations) ≥ n`

Equivalently: `degree + supportCard(evaluations) ≥ n`.

The "degree" here plays the role of bandwidth/frequency support.
This is the honest algebraic content of the Heisenberg uncertainty
principle: bandwidth × time-support cannot both be small.
-/
theorem degree_evaluation_uncertainty {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (pts : Fin n → F) (h_inj : Function.Injective pts)
    (c : Fin n → F) (hc : isNonzero c) :
    n ≤ (coeffsToPoly n c).natDegree + supportCard (vandermonde pts c) := by
  have h_poly_nonzero_evals : n - (coeffsToPoly n c).natDegree ≤ (Finset.univ.filter fun i => (coeffsToPoly n c).eval (pts i) ≠ 0).card := by
    convert polynomial_nonzero_evals ( coeffsToPoly n c ) ( coeffsToPoly_ne_zero c hc ) pts h_inj using 1;
  convert add_le_add_right h_poly_nonzero_evals ( Polynomial.natDegree ( coeffsToPoly n c ) ) using 1;
  · rw [ Nat.add_sub_of_le ( coeffsToPoly_degree_lt ( Nat.pos_of_ne_zero ( by rintro rfl; exact absurd hc ( by rintro ⟨ i, hi ⟩ ; exact hi ( Fin.elim0 i ) ) ) ) c |> Nat.le_of_lt ) ];
  · simp +decide [ supportCard, coeffsToPoly_eval ];
    congr! 1

/-! ## Theorem 3: Polynomial Identity Theorem

The algebraic core of analytic continuation. -/

/-
**Polynomial Identity Theorem.** A polynomial of degree < n vanishing
at n distinct points is zero. This is the algebraic engine behind the
identity theorem for analytic functions, which in turn drives the
Laplace transform uncertainty principle.
-/
theorem poly_identity_theorem {R : Type*} [CommRing R] [IsDomain R]
    (p : Polynomial R) (n : ℕ) (hp_deg : p.natDegree < n)
    (pts : Fin n → R) (h_inj : Function.Injective pts)
    (h_vanish : ∀ i, p.eval (pts i) = 0) :
    p = 0 := by
  -- By contradiction, assume $p \neq 0$.
  by_contra h_nonzero;
  convert polynomial_zeros_le_degree p h_nonzero ( Finset.image pts Finset.univ ) ?_;
  any_goals haveI := Classical.decEq R; simp +decide [ h_vanish ];
  convert hp_deg using 1;
  convert Finset.card_image_of_injective _ h_inj;
  · simp +decide;
  · exact Classical.decEq R

/-
**Vandermonde Injectivity.** Two polynomials of degree < n that agree
at n distinct points must be equal. This is the invertibility of the
Vandermonde matrix — the foundation of interpolation theory.
-/
theorem vandermonde_injective {F : Type*} [Field F]
    {n : ℕ} (pts : Fin n → F) (h_inj : Function.Injective pts)
    (p q : Polynomial F) (hp : p.natDegree < n) (hq : q.natDegree < n)
    (h_eq : ∀ i, p.eval (pts i) = q.eval (pts i)) :
    p = q := by
  -- By the Polynomial Identity Theorem, since $p - q$ is a polynomial of degree less than $n$ and has $n$ distinct roots, it must be the zero polynomial.
  have h_poly_zero : p - q = 0 := by
    apply poly_identity_theorem;
    any_goals exact h_inj;
    · exact lt_of_le_of_lt ( Polynomial.natDegree_sub_le _ _ ) ( max_lt hp hq );
    · aesop;
  exact eq_of_sub_eq_zero h_poly_zero

/-! ## Theorem 4: Transform Basis Spread

The "no blind spots" property of transforms with nonzero kernels. -/

/-- A transform has the **basis spread property** if every standard basis
vector maps to a vector with full support. -/
def hasBasisSpread {F : Type*} [Field F] [DecidableEq F] {n : ℕ}
    (T : TransformDuality F n) : Prop :=
  ∀ (j : Fin n) (i : Fin n), T.kernel i j ≠ 0

/-- Every `TransformDuality` has the basis spread property. -/
theorem transformDuality_has_basis_spread {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (T : TransformDuality F n) : hasBasisSpread T :=
  fun j i => T.no_zero_entry i j

/-
**Single-entry full spread.** A transform with no zero kernel entries maps
each basis vector to a vector with full support n.
-/
theorem single_entry_full_spread {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (T : TransformDuality F n) (j : Fin n) :
    supportCard (T.transform (fun k => if k = j then (1 : F) else 0)) = n := by
  unfold supportCard;
  unfold supportFinset;
  simp +decide [ T.no_zero_entry, TransformDuality.transform ]

/-! ## Theorem 5: Evaluation Support Bound (Key Bridge Theorem)

This theorem bridges the polynomial root bound to the Vandermonde
transform setting, providing the explicit support bound. -/

/-
**Vandermonde Evaluation Support Bound.** For a nonzero coefficient
vector `c`, the Vandermonde evaluation at n distinct points has:
  `supportCard(vandermonde pts c) ≥ 1`

Combined with `degree_evaluation_uncertainty`, this gives the full
uncertainty principle: knowing the degree is d forces at least n - d
nonzero evaluations.
-/
theorem vandermonde_eval_nonzero {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (hn : 0 < n) (pts : Fin n → F) (h_inj : Function.Injective pts)
    (c : Fin n → F) (hc : isNonzero c) :
    0 < supportCard (vandermonde pts c) := by
  -- Since `coeffsToPoly n c ≠ 0` by `coeffsToPoly_ne_zero` and `hc`, then at least one evaluation is nonzero by `polynomial_nonzero_evals`.
  have h_eval_nonzero : ∃ i, (coeffsToPoly n c).eval (pts i) ≠ 0 := by
    contrapose! hc;
    exact fun h => absurd ( poly_identity_theorem ( coeffsToPoly n c ) n ( coeffsToPoly_degree_lt hn c ) pts h_inj hc ) ( coeffsToPoly_ne_zero c h );
  exact Finset.card_pos.mpr ⟨ h_eval_nonzero.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa only [ coeffsToPoly_eval ] using h_eval_nonzero.choose_spec ⟩ ⟩

/-! ## Conjecture -/

/-- **Conjecture: MDS Uncertainty Principle.**
For a transform whose kernel matrix satisfies the MDS property (every
square submatrix is invertible), any nonzero function f satisfies:
  `supportCard f + supportCard (T.transform f) ≥ n + 1`

This is known to be true for:
- Fourier transforms on cyclic groups of prime order (Tao, 2005)
- Vandermonde matrices (= Reed-Solomon codes)
- Cauchy matrices

**Testable prediction**: For the 4×4 DFT matrix over GF(5), every nonzero
vector f should satisfy |supp(f)| + |supp(f̂)| ≥ 5. This can be verified
by exhaustive enumeration over all 5⁴ - 1 = 624 nonzero vectors. -/
def mds_uncertainty_conjecture : Prop :=
  ∀ (F : Type*) [inst1 : Field F] [inst2 : DecidableEq F] (n : ℕ) (hn : 0 < n)
    (M : Fin n → Fin n → F)
    (h_mds : ∀ (S T : Finset (Fin n)), S.card = T.card →
      (∀ (f : Fin n → F), (∀ j, j ∉ T → f j = 0) →
        (∀ i ∈ S, ∑ j : Fin n, M i j * f j = 0) → (∀ j, f j = 0)))
    (f : Fin n → F) (_ : ∃ j, f j ≠ 0),
    supportCard f + supportCard (fun i => ∑ j : Fin n, M i j * f j) ≥ n + 1

end