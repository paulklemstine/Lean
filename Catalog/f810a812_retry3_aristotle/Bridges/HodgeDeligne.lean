import Mathlib

/-!
# The Hodge–Deligne E-polynomial and its functional equations

This file formalizes the Hodge–Deligne E-polynomial of an *abstract Hodge diamond*
(a finite array of non-negative integers `h^{p,q}`) and proves the functional
equations induced by two geometric involutions:

* **Serre duality** `h^{p,q} = h^{n-p,n-q}` produces the symmetry
  `E(u,v) = (uv)^n E(1/u, 1/v)`.
* The **mirror involution** `(p,q) ↦ (n-p, q)` produces
  `E_mirror(u,v) = (-1)^n · u^n · E(1/u, v)`.

These two "substitution + scaling" operations on Laurent monomials are realized here
as honest polynomial endomorphisms `reverseVars` / `reverseFirstVar` of
`MvPolynomial (Fin 2) ℤ`, given by reflecting the exponent of each variable
`p ↦ n - p` (this is exactly the *reciprocal polynomial* construction
`P ↦ u^n v^n · P(1/u,1/v)`, which stays inside the polynomial ring).

## Note on the statements

The informal prompt wrote the Serre equation with explicit extra factors
`C ((-1)^(2n)) * monomial (n,n) 1` and the mirror equation with `monomial (n,0) 1`.
Pulling the substitution `u ↦ 1/u` literally out of a diamond produces a *Laurent*
polynomial with negative exponents, which does not live in `MvPolynomial`.  The
mathematically faithful object is the reciprocal polynomial, and once the `(uv)^n`
scaling is folded into the reflection operator `reverseVars`, the Serre equation is
exactly `epoly X = reverseVars n (epoly X)` (the spurious `(-1)^(2n) = 1` and the
`(uv)^n` factor are absorbed into `reverseVars`).  The mirror equation keeps its
genuine `(-1)^n` sign as `C ((-1)^n)`.

## Main results

* `epoly_serre_functional_equation` — Serre functional equation.
* `epoly_mirror_functional_equation` — mirror functional equation (carries `(-1)^n`).
* `eulerChar_mirror_sign` — specialization of the mirror equation at `u = v = 1`.
* `totalDim_mirror` — invariance of the total dimension under the mirror involution.
-/

namespace HodgeDeligne

open MvPolynomial

variable {n : ℕ}

/-- An abstract Hodge diamond of dimension `n`: the integers `h^{p,q}` for
`0 ≤ p, q ≤ n`. -/
structure HodgeDiamond (n : ℕ) where
  /-- `h p q` is the Hodge number `h^{p,q}`. -/
  h : Fin (n + 1) → Fin (n + 1) → ℕ

/-- The exponent vector of the monomial `u^p v^q` in `MvPolynomial (Fin 2) ℤ`. -/
noncomputable def expVec (p q : ℕ) : Fin 2 →₀ ℕ :=
  Finsupp.single 0 p + Finsupp.single 1 q

/-- The Hodge–Deligne E-polynomial
`E(X; u, v) = ∑_{p,q} (-1)^{p+q} h^{p,q} u^p v^q`, with `u = X 0`, `v = X 1`. -/
noncomputable def epoly (X : HodgeDiamond n) : MvPolynomial (Fin 2) ℤ :=
  ∑ p : Fin (n + 1), ∑ q : Fin (n + 1),
    MvPolynomial.monomial (expVec (p : ℕ) (q : ℕ))
      ((-1 : ℤ) ^ ((p : ℕ) + (q : ℕ)) * (X.h p q : ℤ))

/-- Serre duality: `h^{p,q} = h^{n-p,n-q}` for all `p, q`. -/
def SerreDuality (X : HodgeDiamond n) : Prop :=
  ∀ p q : Fin (n + 1), X.h p q = X.h p.rev q.rev

/-- The mirror involution of a Hodge diamond: `(mirrorDiamond X).h p q = X.h (n-p) q`. -/
def mirrorDiamond (X : HodgeDiamond n) : HodgeDiamond n where
  h p q := X.h p.rev q

/-- Reflection of the exponent vector in both variables: `(p, q) ↦ (n - p, n - q)`. -/
noncomputable def revExpBoth (n : ℕ) (s : Fin 2 →₀ ℕ) : Fin 2 →₀ ℕ :=
  Finsupp.single 0 (n - s 0) + Finsupp.single 1 (n - s 1)

/-- Reflection of the exponent vector in the first variable only: `(p, q) ↦ (n - p, q)`. -/
noncomputable def revExpFst (n : ℕ) (s : Fin 2 →₀ ℕ) : Fin 2 →₀ ℕ :=
  Finsupp.single 0 (n - s 0) + Finsupp.single 1 (s 1)

/-- The reciprocal-polynomial operator `P ↦ u^n v^n · P(1/u, 1/v)`, realized by
reflecting both exponents `(p,q) ↦ (n-p, n-q)`. This implements the substitution
"`u ↦ 1/u`, `v ↦ 1/v`, scaled by `(uv)^n`". -/
noncomputable def reverseVars (n : ℕ) (P : MvPolynomial (Fin 2) ℤ) :
    MvPolynomial (Fin 2) ℤ :=
  Finsupp.mapDomain (revExpBoth n) P

/-- The first-variable reciprocal operator `P ↦ u^n · P(1/u, v)`, realized by
reflecting the first exponent `(p,q) ↦ (n-p, q)`. -/
noncomputable def reverseFirstVar (n : ℕ) (P : MvPolynomial (Fin 2) ℤ) :
    MvPolynomial (Fin 2) ℤ :=
  Finsupp.mapDomain (revExpFst n) P

/-- The Euler characteristic `χ(X) = ∑_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond n) : ℤ :=
  ∑ p : Fin (n + 1), ∑ q : Fin (n + 1), (-1 : ℤ) ^ ((p : ℕ) + (q : ℕ)) * (X.h p q : ℤ)

/-- The total dimension `∑_{p,q} h^{p,q}`. -/
def totalDim (X : HodgeDiamond n) : ℕ :=
  ∑ p : Fin (n + 1), ∑ q : Fin (n + 1), X.h p q

/-! ### Helper lemmas about the reflection operators -/

@[simp]
theorem reverseVars_monomial (n : ℕ) (s : Fin 2 →₀ ℕ) (c : ℤ) :
    reverseVars n (MvPolynomial.monomial s c) = MvPolynomial.monomial (revExpBoth n s) c := by
  rw [reverseVars, show (MvPolynomial.monomial s c) = Finsupp.single s c from rfl,
    Finsupp.mapDomain_single]; rfl

@[simp]
theorem reverseFirstVar_monomial (n : ℕ) (s : Fin 2 →₀ ℕ) (c : ℤ) :
    reverseFirstVar n (MvPolynomial.monomial s c)
      = MvPolynomial.monomial (revExpFst n s) c := by
  rw [reverseFirstVar, show (MvPolynomial.monomial s c) = Finsupp.single s c from rfl,
    Finsupp.mapDomain_single]; rfl

theorem reverseVars_sum {ι : Type*} (n : ℕ) (T : Finset ι)
    (g : ι → MvPolynomial (Fin 2) ℤ) :
    reverseVars n (∑ i ∈ T, g i) = ∑ i ∈ T, reverseVars n (g i) := by
  simp only [reverseVars]; exact map_sum (Finsupp.mapDomain.addMonoidHom (revExpBoth n)) g T

theorem reverseFirstVar_sum {ι : Type*} (n : ℕ) (T : Finset ι)
    (g : ι → MvPolynomial (Fin 2) ℤ) :
    reverseFirstVar n (∑ i ∈ T, g i) = ∑ i ∈ T, reverseFirstVar n (g i) := by
  simp only [reverseFirstVar]; exact map_sum (Finsupp.mapDomain.addMonoidHom (revExpFst n)) g T

/-! ### Theorem 1: Serre functional equation -/

/-- **Serre functional equation.**  If `X` satisfies Serre duality
`h^{p,q} = h^{n-p,n-q}`, then its E-polynomial is invariant under the reciprocal
operator `reverseVars` (i.e. `E(u,v) = (uv)^n E(1/u,1/v)`). -/
theorem epoly_serre_functional_equation (X : HodgeDiamond n) (hS : SerreDuality X) :
    epoly X = reverseVars n (epoly X) := by
  unfold epoly
  simp_rw [reverseVars_sum, reverseVars_monomial]
  refine Fintype.sum_equiv (Equiv.ofBijective Fin.rev Fin.rev_bijective) _ _ (fun p => ?_)
  refine Fintype.sum_equiv (Equiv.ofBijective Fin.rev Fin.rev_bijective) _ _ (fun q => ?_)
  simp only [Equiv.ofBijective_apply]
  have hp : ((p.rev : Fin (n+1)) : ℕ) = n - (p:ℕ) := by simp [Fin.rev]
  have hq : ((q.rev : Fin (n+1)) : ℕ) = n - (q:ℕ) := by simp [Fin.rev]
  rw [hp, hq]
  have e0 : (expVec (n-(p:ℕ)) (n-(q:ℕ))) 0 = n - (p:ℕ) := by simp [expVec]
  have e1 : (expVec (n-(p:ℕ)) (n-(q:ℕ))) 1 = n - (q:ℕ) := by simp [expVec]
  have hexp : revExpBoth n (expVec (n-(p:ℕ)) (n-(q:ℕ))) = expVec (p:ℕ) (q:ℕ) := by
    unfold revExpBoth
    rw [e0, e1, show n - (n - (p:ℕ)) = (p:ℕ) by omega, show n - (n - (q:ℕ)) = (q:ℕ) by omega]
    rfl
  rw [hexp, hS p q]
  congr 2
  have hsum : ((p:ℕ)+(q:ℕ)) + ((n-(p:ℕ))+(n-(q:ℕ))) = 2*n := by omega
  have hprod : (-1:ℤ)^((p:ℕ)+(q:ℕ)) * (-1)^((n-(p:ℕ))+(n-(q:ℕ))) = 1 := by
    rw [← pow_add, hsum, pow_mul]; norm_num
  have hbb : (-1:ℤ)^((n-(p:ℕ))+(n-(q:ℕ))) * (-1)^((n-(p:ℕ))+(n-(q:ℕ))) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]; norm_num
  calc (-1:ℤ)^((p:ℕ)+(q:ℕ))
      = (-1:ℤ)^((p:ℕ)+(q:ℕ)) * ((-1)^((n-(p:ℕ))+(n-(q:ℕ))) * (-1)^((n-(p:ℕ))+(n-(q:ℕ)))) := by rw [hbb, mul_one]
    _ = ((-1:ℤ)^((p:ℕ)+(q:ℕ)) * (-1)^((n-(p:ℕ))+(n-(q:ℕ)))) * (-1)^((n-(p:ℕ))+(n-(q:ℕ))) := by ring
    _ = (-1:ℤ)^((n-(p:ℕ))+(n-(q:ℕ))) := by rw [hprod, one_mul]

/-! ### Theorem 2: Mirror functional equation -/

/-- **Mirror functional equation.**  The E-polynomial of the mirror diamond is
`(-1)^n` times the first-variable reciprocal of the E-polynomial of `X`
(i.e. `E_mirror(u,v) = (-1)^n u^n E(1/u, v)`). -/
theorem epoly_mirror_functional_equation (X : HodgeDiamond n) :
    epoly (mirrorDiamond X)
      = MvPolynomial.C ((-1 : ℤ) ^ n) * reverseFirstVar n (epoly X) := by
  unfold epoly mirrorDiamond
  simp_rw [reverseFirstVar_sum, reverseFirstVar_monomial, Finset.mul_sum,
    MvPolynomial.C_mul_monomial]
  refine Fintype.sum_equiv (Equiv.ofBijective Fin.rev Fin.rev_bijective) _ _ (fun p => ?_)
  refine Finset.sum_congr rfl (fun q _ => ?_)
  simp only [Equiv.ofBijective_apply]
  have hp : ((p.rev : Fin (n+1)) : ℕ) = n - (p:ℕ) := by simp [Fin.rev]
  rw [hp]
  have e0 : (expVec (n-(p:ℕ)) (q:ℕ)) 0 = n - (p:ℕ) := by simp [expVec]
  have e1 : (expVec (n-(p:ℕ)) (q:ℕ)) 1 = (q:ℕ) := by simp [expVec]
  have hexp : revExpFst n (expVec (n-(p:ℕ)) (q:ℕ)) = expVec (p:ℕ) (q:ℕ) := by
    unfold revExpFst
    rw [e0, e1, show n - (n - (p:ℕ)) = (p:ℕ) by omega]
    rfl
  rw [hexp]
  congr 1
  have hsum : ((p:ℕ)+(q:ℕ)) + (n + ((n-(p:ℕ))+(q:ℕ))) = 2*(n+(q:ℕ)) := by omega
  have hprod : (-1:ℤ)^((p:ℕ)+(q:ℕ)) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) = 1 := by
    rw [← pow_add, ← pow_add, hsum, pow_mul]; norm_num
  have hbb : ((-1:ℤ)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) = 1 := by
    rw [show ((-1:ℤ)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ)))
        = ((-1:ℤ)^n*(-1)^n) * ((-1)^((n-(p:ℕ))+(q:ℕ)) * (-1)^((n-(p:ℕ))+(q:ℕ))) by ring,
       ← pow_add, ← pow_add, ← two_mul, ← two_mul, pow_mul, pow_mul]; norm_num
  have hpow : (-1:ℤ)^((p:ℕ)+(q:ℕ)) = (-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ)) := by
    calc (-1:ℤ)^((p:ℕ)+(q:ℕ))
        = (-1:ℤ)^((p:ℕ)+(q:ℕ)) * (((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ)))) := by rw [hbb, mul_one]
      _ = ((-1:ℤ)^((p:ℕ)+(q:ℕ)) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ)))) * ((-1)^n * (-1)^((n-(p:ℕ))+(q:ℕ))) := by ring
      _ = (-1:ℤ)^n * (-1)^((n-(p:ℕ))+(q:ℕ)) := by rw [hprod, one_mul]
  rw [hpow]; ring

/-! ### Theorem 3: Euler characteristic mirror sign -/

/-- Evaluating the E-polynomial at `u = v = 1` recovers the Euler characteristic. -/
theorem eval_one_epoly (X : HodgeDiamond n) :
    MvPolynomial.eval (fun _ => (1 : ℤ)) (epoly X) = eulerChar X := by
  unfold epoly eulerChar
  simp [map_sum, MvPolynomial.eval_monomial]

/-- The first-variable reflection does not change the value at `u = v = 1`. -/
theorem eval_one_reverseFirstVar (n : ℕ) (P : MvPolynomial (Fin 2) ℤ) :
    MvPolynomial.eval (fun _ => (1 : ℤ)) (reverseFirstVar n P)
      = MvPolynomial.eval (fun _ => (1 : ℤ)) P := by
  rw [reverseFirstVar, MvPolynomial.eval_eq', MvPolynomial.eval_eq']
  simp only [one_pow, Finset.prod_const_one, mul_one]
  show (Finsupp.mapDomain (revExpFst n) P).sum (fun _ c => c) = P.sum (fun _ c => c)
  rw [Finsupp.sum_mapDomain_index (by intro b; rfl) (by intro b a₁ a₂; rfl)]

/-- **Euler characteristic mirror sign.**  Specialization of the mirror functional
equation at `u = v = 1`. -/
theorem eulerChar_mirror_sign (X : HodgeDiamond n) :
    eulerChar (mirrorDiamond X) = (-1) ^ n * eulerChar X := by
  have h2 := epoly_mirror_functional_equation X
  have := congrArg (MvPolynomial.eval (fun _ => (1 : ℤ))) h2
  simpa [eval_one_epoly, eval_one_reverseFirstVar, map_mul] using this

/-! ### Theorem 4: Total dimension mirror invariance -/

/-- **Total dimension mirror invariance.**  The total dimension is invariant under
the mirror involution `(p,q) ↦ (n-p,q)` (a direct reindexing). -/
theorem totalDim_mirror (X : HodgeDiamond n) :
    totalDim (mirrorDiamond X) = totalDim X := by
  unfold totalDim mirrorDiamond
  exact Fintype.sum_bijective Fin.rev Fin.rev_bijective _ _ (fun p => rfl)

end HodgeDeligne