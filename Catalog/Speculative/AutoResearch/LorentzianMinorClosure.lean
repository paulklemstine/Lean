/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Minor Closure Theory

This file develops the theory of minor closure for Lorentzian polynomial supports,
connecting the analytic positivity of Brändén–Huh Lorentzian polynomials with the
combinatorial minor theory of polynomial support sets.

## Main Definitions

* `IsLorentzianSupport` — A support set is Lorentzian-realizable
* `IsPositiveLorentzianSupport` — Positive Lorentzian realizability
* `supportDelete` — Deletion of coordinate i from a support
* `supportContract` — Contraction at coordinate i
* `IsSupportMinor` — Inductive minor relation
* `zeroRowCol` — Matrix with row/column zeroed out

## Main Results

* `hasAtMostOnePositiveEigenvalue_zeroRowCol` — Zeroing a row/column preserves
  the Lorentzian signature (at most one positive eigenvalue)
* `lorentzian_delete` — Deletion preserves Lorentzian support realizability
* `lorentzian_pderiv` — Partial derivative preserves Lorentzianity
* `lorentzian_support_minor_closed` — Minor closure for positive Lorentzian supports

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators MvPolynomial Finsupp

noncomputable section

namespace LorentzianMinorClosure

/-! ## Section 1: Core Definitions -/

/-- The quadratic form Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A matrix has at most one positive eigenvalue if there exists a direction w
    such that Q_A(v) ≤ 0 for all v orthogonal to w. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- The Hessian matrix: H(i,j) = coeff_0(∂²f/∂xᵢ∂xⱼ). -/
def hessianMatrix {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => MvPolynomial.coeff 0
    (MvPolynomial.pderiv i (MvPolynomial.pderiv j f))

/-- Iterated partial derivative: apply ∂/∂xᵢ exactly α(i) times for each i. -/
def iteratedPDeriv {n : ℕ} (α : Fin n → ℕ) (f : MvPolynomial (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  Fin.foldl n (fun g i => (MvPolynomial.pderiv i)^[α i] g) f

/-- Brändén–Huh Lorentzian polynomial. -/
def IsBrandenHuhLorentzian {n : ℕ} (d : ℕ) (p : MvPolynomial (Fin n) ℝ) : Prop :=
  p.IsHomogeneous d ∧
  (∀ m, 0 ≤ MvPolynomial.coeff m p) ∧
  (d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α p)))

/-! ## Section 2: Support Operations -/

/-- Support deletion at coordinate i: keep only monomials with m(i) = 0. -/
def supportDelete {n : ℕ} (i : Fin n) (S : Finset (Fin n →₀ ℕ)) : Finset (Fin n →₀ ℕ) :=
  S.filter (fun m => m i = 0)

/-- Minimum value of coordinate i across the support. -/
def minCoord {n : ℕ} (i : Fin n) (S : Finset (Fin n →₀ ℕ)) : ℕ :=
  if h : S.Nonempty then S.inf' h (fun m => m i) else 0

/-- Support contraction at coordinate i. -/
def supportContract {n : ℕ} (i : Fin n) (S : Finset (Fin n →₀ ℕ)) : Finset (Fin n →₀ ℕ) :=
  (S.filter (fun m => m i = minCoord i S)).image
    (fun m => m - Finsupp.single i (minCoord i S))

/-- Inductive minor relation via deletion and contraction. -/
inductive IsSupportMinor {n : ℕ} : Finset (Fin n →₀ ℕ) → Finset (Fin n →₀ ℕ) → Prop
  | refl (S) : IsSupportMinor S S
  | delete_step (S T : Finset (Fin n →₀ ℕ)) (i : Fin n) :
      IsSupportMinor (supportDelete i S) T → IsSupportMinor S T
  | contract_step (S T : Finset (Fin n →₀ ℕ)) (i : Fin n) :
      IsSupportMinor (supportContract i S) T → IsSupportMinor S T

/-! ## Section 3: Realizability Predicates -/

/-- A support set is **Lorentzian-realizable**. -/
def IsLorentzianSupport {n : ℕ} (d : ℕ) (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∃ p : MvPolynomial (Fin n) ℝ,
    IsBrandenHuhLorentzian d p ∧ p.support = S

/-- A support set is **positively Lorentzian-realizable**. -/
def IsPositiveLorentzianSupport {n : ℕ} (d : ℕ) (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∃ p : MvPolynomial (Fin n) ℝ,
    IsBrandenHuhLorentzian d p ∧
    p.support = S ∧
    (∀ m ∈ S, 0 < MvPolynomial.coeff m p)

/-! ## Section 4: Support Characterization Lemmas -/

theorem mem_supportDelete_iff {n : ℕ} {i : Fin n} {S : Finset (Fin n →₀ ℕ)}
    {m : Fin n →₀ ℕ} :
    m ∈ supportDelete i S ↔ m ∈ S ∧ m i = 0 :=
  Finset.mem_filter

theorem supportDelete_subset {n : ℕ} (i : Fin n) (S : Finset (Fin n →₀ ℕ)) :
    supportDelete i S ⊆ S :=
  Finset.filter_subset _ _

/-! ## Section 5: Linear Algebra — Zeroing Row/Column -/

/-- Matrix with row i and column i zeroed out. -/
def zeroRowCol {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun j k => if j = i ∨ k = i then 0 else A j k

/-
The quadratic form of a zero-row-col matrix equals the original quadratic form
    evaluated at the projection that zeros out coordinate i.
-/
theorem quadForm_zeroRowCol {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n)
    (v : Fin n → ℝ) :
    QuadForm (zeroRowCol A i) v =
    QuadForm A (Function.update v i 0) := by
  exact Finset.sum_congr rfl fun j hj => Finset.sum_congr rfl fun k hk => by unfold zeroRowCol; aesop;

/-
**Key linear algebra lemma**: Zeroing a row and column preserves the property
    of having at most one positive eigenvalue.

    Given w such that Q_A(v) ≤ 0 when ⟨w,v⟩ = 0, take w' = Function.update w i 0.
    Then Q_{A'}(v) = Q_A(π_i(v)), and when ⟨w',v⟩ = 0 we have ⟨w, π_i(v)⟩ = 0,
    so Q_A(π_i(v)) ≤ 0.
-/
theorem hasAtMostOnePositiveEigenvalue_zeroRowCol {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n)
    (hA : HasAtMostOnePositiveEigenvalue A) :
    HasAtMostOnePositiveEigenvalue (zeroRowCol A i) := by
  -- By definition of $w'$, we have $\langle w', v \rangle = 0$ if and only if $\langle w, \pi_i(v) \rangle = 0$.
  obtain ⟨w, hw⟩ := hA
  use Function.update w i 0;
  intro v hv; convert hw ( Function.update v i 0 ) _ using 1; simp_all +decide [ QuadForm ] ;
  · convert quadForm_zeroRowCol A i v using 1;
  · grind

/-! ## Section 6: Polynomial Restriction -/

/-- The restriction of a polynomial to x_i = 0: keep only monomials with m(i) = 0. -/
def restrictCoord {n : ℕ} (i : Fin n) (p : MvPolynomial (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  p.support.sum (fun m =>
    if m i = 0 then MvPolynomial.monomial m (MvPolynomial.coeff m p)
    else 0)

/-
The support of restrictCoord is the deleted support.
-/
theorem restrictCoord_support {n : ℕ} (i : Fin n) (p : MvPolynomial (Fin n) ℝ)
    (hnn : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    (restrictCoord i p).support = supportDelete i (p.support) := by
  ext m; simp [restrictCoord, supportDelete];
  simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ];
  by_cases hi : m i = 0 <;> simp +decide [ hi, MvPolynomial.coeff_monomial ];
  · rw [ Finset.sum_eq_single m ] <;> simp +contextual [ MvPolynomial.coeff_monomial, hi ];
    intro b hb hbm; split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ] ;
  · rw [ Finset.sum_eq_zero ] ; aesop

/-
restrictCoord preserves nonnegativity of coefficients.
-/
theorem restrictCoord_coeff_nonneg {n : ℕ} (i : Fin n) (p : MvPolynomial (Fin n) ℝ)
    (hnn : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    ∀ m, 0 ≤ MvPolynomial.coeff m (restrictCoord i p) := by
  unfold restrictCoord; simp +decide [ *, MvPolynomial.coeff_sum ] ;
  intro m; apply Finset.sum_nonneg; intro x hx; split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ] ;
  split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ] ;

/-
restrictCoord preserves homogeneity.
-/
theorem restrictCoord_isHomogeneous {n : ℕ} (i : Fin n) (p : MvPolynomial (Fin n) ℝ)
    {d : ℕ} (hh : p.IsHomogeneous d) :
    (restrictCoord i p).IsHomogeneous d := by
  intro m hm;
  unfold restrictCoord at hm;
  contrapose! hm; simp_all +decide [ MvPolynomial.coeff_sum ] ;
  refine' Finset.sum_eq_zero fun x hx => _;
  split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ];
  have := hh hx; aesop;

/-! ## Section 7: Hessian of Restricted Polynomial -/

/-
The Hessian of the restricted polynomial's iterated derivative equals
    the zero-row-col of the original Hessian (when α(i) = 0).
-/
set_option maxHeartbeats 800000 in
theorem hessian_restrictCoord_eq_zeroRowCol {n : ℕ} (i : Fin n)
    (p : MvPolynomial (Fin n) ℝ) (α : Fin n → ℕ)
    (hα_i : α i = 0) :
    hessianMatrix (iteratedPDeriv α (restrictCoord i p)) =
    zeroRowCol (hessianMatrix (iteratedPDeriv α p)) i := by
  have h_restrictCoord : restrictCoord i p = MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) p := by
    unfold restrictCoord;
    simp +decide [ Finset.sum_ite, MvPolynomial.bind₁_monomial ];
    rw [ MvPolynomial.bind₁ ];
    rw [ MvPolynomial.aeval_def, MvPolynomial.eval₂_eq' ];
    rw [ Finset.sum_filter ] ; congr ; ext ; simp +decide [ MvPolynomial.monomial_eq, Finset.prod_ite, Finset.filter_ne', Finset.filter_eq' ] ;
    split_ifs <;> simp_all +decide [ Finset.prod_erase ];
  -- By definition of `iteratedPDeriv`, we can apply it to the restricted polynomial.
  have h_iteratedPDeriv : ∀ (q : MvPolynomial (Fin n) ℝ), iteratedPDeriv α (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) q) = MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) (iteratedPDeriv α q) := by
    unfold iteratedPDeriv;
    intro q
    have h_foldl : ∀ (l : List (Fin n)), List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) ((MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j)) q) l = (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j)) (List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) q l) := by
      intro l
      induction' l using List.reverseRecOn with l ih;
      · rfl;
      · by_cases hi : ih = i <;> simp_all +decide [ Function.iterate_fixed ];
        induction' α ih with k hk;
        · rfl;
        · simp_all +decide [ Function.iterate_succ_apply' ];
          induction' ( ( pderiv ih ) ^[ k ] ( List.foldl ( fun g j => ( pderiv j ) ^[ α j ] g ) q l ) ) using MvPolynomial.induction_on with j p q hp hq <;> simp_all +decide [ Function.iterate_succ_apply' ];
          split_ifs <;> simp_all +decide [ mul_comm, Pi.single_apply ];
          ring;
    grind;
  ext j k zeroRowCol;
  by_cases hj : j = i <;> by_cases hk : k = i <;> simp +decide [ *, hessianMatrix, zeroRowCol ];
  · -- By definition of `bind₁`, we know that `bind₁ (fun j => if j = i then 0 else X j) q` is a polynomial where the coefficient of `X i` is zero.
    have h_bind₁_zero : ∀ (q : MvPolynomial (Fin n) ℝ), (pderiv i) (bind₁ (fun j => if j = i then 0 else X j) q) = 0 := by
      intro q; induction q using MvPolynomial.induction_on <;> aesop;
    rw [ h_bind₁_zero ] ; norm_num;
  · -- Since $j = i$, the partial derivative with respect to $i$ of any polynomial that does not contain $i$ is zero.
    have h_partial_i : ∀ (q : MvPolynomial (Fin n) ℝ), (pderiv i) (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) q) = 0 := by
      intro q; induction q using MvPolynomial.induction_on <;> aesop;
    rw [ show ( pderiv k ) ( ( bind₁ fun j => if j = i then 0 else X j ) ( iteratedPDeriv α p ) ) = ( bind₁ fun j => if j = i then 0 else X j ) ( ( pderiv k ) ( iteratedPDeriv α p ) ) from ?_ ];
    · rw [ h_partial_i ] ; norm_num;
    · induction' ( iteratedPDeriv α p ) using MvPolynomial.induction_on with j q r hq hr <;> simp +decide [ *, pderiv_X ];
      split_ifs <;> simp_all +decide [ mul_comm ];
      grind;
  · rw [ show ( pderiv i ) ( bind₁ ( fun j => if j = i then 0 else X j ) ( iteratedPDeriv α p ) ) = 0 from _ ] ; norm_num;
    -- By definition of `bind₁`, we know that `bind₁ (fun j => if j = i then 0 else X j) q` is a polynomial where the coefficient of `X i` is zero.
    have h_bind₁_zero : ∀ q : MvPolynomial (Fin n) ℝ, (pderiv i) (bind₁ (fun j => if j = i then 0 else X j) q) = 0 := by
      intro q; induction q using MvPolynomial.induction_on <;> aesop;
    exact h_bind₁_zero _;
  · -- By definition of `pderiv`, we can apply it to the restricted polynomial.
    have h_pderiv : ∀ (q : MvPolynomial (Fin n) ℝ), pderiv j (pderiv k (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) q)) = MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) (pderiv j (pderiv k q)) := by
      intro q; exact (by
      induction' q using MvPolynomial.induction_on with j q r hq hr₁ hq₂;
      · simp +decide [ MvPolynomial.bind₁_C_right ];
      · simp_all +decide [ add_mul, mul_add, add_assoc, add_left_comm, add_comm ];
      · by_cases h : ‹Fin n› = i <;> simp_all +decide [ pderiv_mul ];
        simp_all +decide [ Pi.single_apply ];
        split_ifs <;> simp_all +decide [ pderiv_X ];
        · have h_pderiv : ∀ (q : MvPolynomial (Fin n) ℝ), pderiv k (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) q) = MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) (pderiv k q) := by
            intro q; exact (by
            induction' q using MvPolynomial.induction_on with j q r hq hr₁ hq₂;
            · simp +decide [ pderiv_C ];
            · grind;
            · simp +decide [ *, MvPolynomial.pderiv_mul ];
              split_ifs <;> simp_all +decide [ MvPolynomial.pderiv_mul, Pi.single_apply ]);
          rw [ h_pderiv ];
        · have h_pderiv : ∀ (q : MvPolynomial (Fin n) ℝ), pderiv j (MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) q) = MvPolynomial.bind₁ (fun j => if j = i then 0 else MvPolynomial.X j) (pderiv j q) := by
            intro q; exact (by
            induction' q using MvPolynomial.induction_on with j q r hq hr₁ hq₂;
            · simp +decide [ MvPolynomial.pderiv_C ];
            · grind +qlia;
            · simp +decide [ *, MvPolynomial.pderiv_mul ];
              split_ifs <;> simp_all +decide [ MvPolynomial.pderiv_mul, Pi.single_apply ]);
          exact h_pderiv hq₂;
        · rename_i h₁ h₂ h₃;
          clear h₁ h₂ h₃ h_restrictCoord h_iteratedPDeriv;
          induction hq₂ using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ];
          split_ifs <;> simp_all +decide [ MvPolynomial.pderiv_mul, Pi.single_apply ]);
    rw [ h_pderiv ];
    induction' ( pderiv j ) ( ( pderiv k ) ( iteratedPDeriv α p ) ) using MvPolynomial.induction_on with j p q hp hq <;> simp +decide [ *, MvPolynomial.coeff_X' ];
    split_ifs <;> simp_all +decide [ MvPolynomial.coeff_mul ]

/-- Iterated partial derivative of 0 is 0. -/
theorem iteratedPDeriv_zero {n : ℕ} (α : Fin n → ℕ) :
    iteratedPDeriv α (0 : MvPolynomial (Fin n) ℝ) = 0 := by
  unfold iteratedPDeriv
  rw [Fin.foldl_eq_foldl_finRange]
  have : ∀ (l : List (Fin n)),
    List.foldl (fun g i => (MvPolynomial.pderiv i)^[α i] g) (0 : MvPolynomial (Fin n) ℝ) l = 0 := by
    intro l
    induction l with
    | nil => simp
    | cons hd tl ih =>
      simp only [List.foldl_cons]
      rw [Function.iterate_fixed (map_zero _)]
      exact ih
  exact this _

/-
When α(i) > 0, the iterated derivative of the restricted polynomial is zero.
-/
theorem iteratedPDeriv_restrictCoord_zero {n : ℕ} (i : Fin n)
    (p : MvPolynomial (Fin n) ℝ) (α : Fin n → ℕ) (hα : α i > 0) :
    iteratedPDeriv α (restrictCoord i p) = 0 := by
  -- Since $pderiv i (restrictCoord i p) = 0$, applying $(pderiv i)^[α i]$ to it will also yield zero.
  have h_iter_zero : ∀ k : ℕ, k > 0 → (MvPolynomial.pderiv i)^[k] (restrictCoord i p) = 0 := by
    intro k hk
    induction' hk with k hk ih;
    · unfold restrictCoord;
      simp +decide [ Finset.sum_ite ];
      exact Finset.sum_eq_zero fun x hx => by aesop;
    · rw [ Function.iterate_succ_apply', ih, map_zero ];
  -- Since α i > 0, we can apply h_iter_zero to conclude that the iterated derivative is zero.
  have h_foldl_zero : ∀ (l : List (Fin n)), i ∈ l → (List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) (restrictCoord i p) l) = 0 := by
    intro l hl;
    induction' l using List.reverseRecOn with l ih;
    · contradiction;
    · nontriviality;
      cases eq_or_ne ih i <;> simp_all +decide [ Function.iterate_fixed ];
      · by_cases hi : i ∈ l <;> simp_all +decide [ Function.iterate_fixed ];
        induction' l using List.reverseRecOn with l ih;
        · exact h_iter_zero _ hα;
        · simp_all +decide [ List.foldl_append ];
          convert congr_arg ( fun x => ( MvPolynomial.pderiv ih ) ^[ α ih ] x ) ‹ ( MvPolynomial.pderiv i ) ^[ α i ] ( List.foldl ( fun g j => ( MvPolynomial.pderiv j ) ^[ α j ] g ) ( restrictCoord i p ) l ) = 0 › using 1;
          · -- Since the partial derivatives commute, we can interchange the order of applying them.
            have h_comm : ∀ (f : MvPolynomial (Fin n) ℝ), (MvPolynomial.pderiv i) (MvPolynomial.pderiv ih f) = (MvPolynomial.pderiv ih) (MvPolynomial.pderiv i f) := by
              intro f; exact (by
              induction' f using MvPolynomial.induction_on with i f g hf hg;
              · simp +decide [ MvPolynomial.pderiv_C ];
              · simp +decide [ hf, hg ];
              · simp +decide [ *, MvPolynomial.pderiv_mul ];
                simp +decide [ Pi.single_apply, hi.2 ] ; ring;
                aesop);
            have h_comm : ∀ (k : ℕ) (f : MvPolynomial (Fin n) ℝ), (MvPolynomial.pderiv i)^[k] ((MvPolynomial.pderiv ih) f) = (MvPolynomial.pderiv ih) ((MvPolynomial.pderiv i)^[k] f) := by
              intro k f; induction' k with k ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
            exact Nat.recOn ( α ih ) rfl fun k hk => by simp +decide [ *, Function.iterate_succ_apply' ] ;
          · norm_num [ Function.iterate_fixed ];
      · aesop;
  convert h_foldl_zero ( Finset.toList ( Finset.univ : Finset ( Fin n ) ) ) _;
  · unfold iteratedPDeriv;
    grind +suggestions;
  · simp +decide

/-- The zero polynomial's Hessian has at most one positive eigenvalue. -/
theorem hessian_zero_hasAtMostOnePos {n : ℕ} (α : Fin n → ℕ) :
    HasAtMostOnePositiveEigenvalue
      (hessianMatrix (iteratedPDeriv α (0 : MvPolynomial (Fin n) ℝ))) := by
  rw [iteratedPDeriv_zero]
  exact ⟨0, fun v _ => by
    unfold QuadForm hessianMatrix
    simp [map_zero, MvPolynomial.coeff_zero]⟩

/-! ## Section 8: Deletion Preserves Lorentzian Support (Main Theorem 1) -/

/-- **Theorem 1: Deletion preserves Lorentzian support realizability.**

    If S is the support of a Brändén–Huh Lorentzian polynomial, then
    supportDelete i S is also Lorentzian-realizable.

    The witness is the polynomial obtained by setting x_i = 0 (filtering
    monomials to those with zero i-exponent). Lorentzianity is preserved
    because:
    (1) Homogeneity is preserved (all surviving monomials have degree d).
    (2) Coefficient nonnegativity is preserved (subset of original).
    (3) The Hessian condition holds because the Hessian of the restricted
        polynomial is the original Hessian with row/column i zeroed out,
        which preserves the at-most-one-positive-eigenvalue property. -/
theorem lorentzian_delete {n : ℕ} {d : ℕ} {S : Finset (Fin n →₀ ℕ)}
    (hS : IsLorentzianSupport d S) (i : Fin n) :
    IsLorentzianSupport d (supportDelete i S) := by
  obtain ⟨p, ⟨hhom, hnn, hleaves⟩, hsup⟩ := hS
  refine ⟨restrictCoord i p, ⟨?_, ?_, ?_⟩, ?_⟩
  · exact restrictCoord_isHomogeneous i p hhom
  · exact restrictCoord_coeff_nonneg i p hnn
  · intro hd2 α hα
    by_cases hi : α i = 0
    · rw [hessian_restrictCoord_eq_zeroRowCol i p α hi]
      exact hasAtMostOnePositiveEigenvalue_zeroRowCol _ _ (hleaves hd2 α hα)
    · have hpos : α i > 0 := Nat.pos_of_ne_zero hi
      have h0 := iteratedPDeriv_restrictCoord_zero i p α hpos
      simp only [h0]
      exact ⟨0, fun v _ => by unfold QuadForm hessianMatrix; simp⟩
  · rw [← hsup]; exact restrictCoord_support i p hnn

/-! ## Section 9: Partial Derivative Preserves Lorentzianity (Theorem 2) -/

/-
Partial derivatives of polynomials with nonneg coefficients have nonneg coefficients.
-/
theorem pderiv_coeff_nonneg' {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n}
    (hnn : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    ∀ m, 0 ≤ MvPolynomial.coeff m (MvPolynomial.pderiv i p) := by
  intro m
  simp [pderiv];
  simp +decide [ mkDerivation, Finsupp.single_apply ];
  rw [ MvPolynomial.mkDerivationₗ ];
  simp +decide [ lsum, Finsupp.sum_fintype ];
  simp +decide [ sum, Pi.single_apply ];
  simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_smul ];
  exact Finset.sum_nonneg fun _ _ => by split_ifs <;> [ exact mul_nonneg ( hnn _ ) ( Nat.cast_nonneg _ ) ; exact le_rfl ] ;

/-
Iterated derivative with an extra single derivative can be absorbed.
    iteratedPDeriv α (pderiv i f) = iteratedPDeriv (α + e_i) f
    where α + e_i increments the i-th component.
-/
theorem iteratedPDeriv_pderiv_absorb {n : ℕ} (α : Fin n → ℕ) (i : Fin n)
    (f : MvPolynomial (Fin n) ℝ) :
    iteratedPDeriv α (MvPolynomial.pderiv i f) =
    iteratedPDeriv (Function.update α i (α i + 1)) f := by
  have h_comm : ∀ (g : MvPolynomial (Fin n) ℝ) (j : Fin n), (MvPolynomial.pderiv j)^[α j] ((MvPolynomial.pderiv i) g) = (MvPolynomial.pderiv i) ((MvPolynomial.pderiv j)^[α j] g) := by
    intro g j; induction' α j with k hk <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    -- By definition of partial derivative, we know that $(pderiv j) ((pderiv i) g) = (pderiv i) ((pderiv j) g)$.
    have h_comm : ∀ (g : MvPolynomial (Fin n) ℝ), (pderiv j) ((pderiv i) g) = (pderiv i) ((pderiv j) g) := by
      intro g; induction g using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ] ;
      simp +decide [ Pi.single_apply, mul_comm ] ; ring;
      aesop;
    exact h_comm _;
  have h_comm : ∀ (g : MvPolynomial (Fin n) ℝ) (l : List (Fin n)), (List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) ((MvPolynomial.pderiv i) g) l) = (MvPolynomial.pderiv i) (List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) g l) := by
    intro g l; induction' l using List.reverseRecOn with l ih <;> aesop;
  convert h_comm f ( List.finRange n ) using 1;
  · grind +locals;
  · have h_comm : ∀ (g : MvPolynomial (Fin n) ℝ) (l : List (Fin n)), (List.foldl (fun g j => (MvPolynomial.pderiv j)^[Function.update α i (α i + 1) j] g) g l) = (MvPolynomial.pderiv i)^[List.count i l] (List.foldl (fun g j => (MvPolynomial.pderiv j)^[α j] g) g l) := by
      intro g l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      by_cases hi : ih = i <;> simp_all +decide [ Function.update_apply, List.count_cons ];
      · simp +decide [ ← Function.iterate_succ_apply' ];
        rw [ ← Function.iterate_add_apply, add_comm, Function.iterate_add_apply ];
      · induction' List.count i l with k hk <;> simp_all +decide [ Function.iterate_succ_apply' ];
    convert h_comm f ( List.finRange n ) using 1;
    · unfold iteratedPDeriv;
      grind +qlia;
    · simp +decide [ List.count_eq_one_of_mem ]

/-
Sum of Function.update increments by 1.
-/
theorem sum_update_add_one {n : ℕ} (α : Fin n → ℕ) (i : Fin n) :
    ∑ j : Fin n, Function.update α i (α i + 1) j = (∑ j : Fin n, α j) + 1 := by
  simp +decide [ Function.update_apply, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ];
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), add_comm ] ; ring

/-- **Theorem 2: Partial derivative preserves Lorentzianity.**

    If p is Lorentzian of degree d ≥ 1, then ∂p/∂x_i is Lorentzian of degree d - 1. -/
theorem lorentzian_pderiv {n : ℕ} {d : ℕ} {p : MvPolynomial (Fin n) ℝ}
    (hL : IsBrandenHuhLorentzian d p) (hd : 1 ≤ d) (i : Fin n) :
    IsBrandenHuhLorentzian (d - 1) (MvPolynomial.pderiv i p) := by
  obtain ⟨hhom, hnn, hleaves⟩ := hL
  refine ⟨hhom.pderiv, pderiv_coeff_nonneg' hnn, ?_⟩
  intro hd2 α hα
  rw [iteratedPDeriv_pderiv_absorb]
  apply hleaves
  · omega
  · have := sum_update_add_one α i
    omega

/-! ## Section 10: Contraction Preserves Lorentzian Support (Theorem 3) -/

/-
Iterated single-variable derivative preserves Lorentzianity.
    The contraction of a support at coordinate i is realized by
    taking (pderiv i)^[k] where k = minCoord i S, then restricting to x_i = 0.
    Lorentzianity is preserved at each step.
-/
theorem lorentzian_iterate_pderiv {n : ℕ} {d : ℕ} {p : MvPolynomial (Fin n) ℝ}
    (hL : IsBrandenHuhLorentzian d p) (i : Fin n) (k : ℕ) (hk : k ≤ d) :
    IsBrandenHuhLorentzian (d - k) ((MvPolynomial.pderiv i)^[k] p) := by
  induction' k with k ih;
  · simpa using hL;
  · convert lorentzian_pderiv ( ih ( Nat.le_of_succ_le hk ) ) ( Nat.sub_pos_of_lt hk ) i using 1;
    exact Function.iterate_succ_apply' _ _ _

/-
**Theorem 3: Contraction preserves positive Lorentzian support realizability.**

    If S is the support of a positive Lorentzian polynomial of degree d,
    then supportContract i S is Lorentzian-realizable at some degree e ≤ d.
-/
theorem lorentzian_contract {n : ℕ} {d : ℕ} {S : Finset (Fin n →₀ ℕ)}
    (hS : IsPositiveLorentzianSupport d S) (i : Fin n) :
    ∃ e ≤ d, IsLorentzianSupport e (supportContract i S) := by
  -- By definition of $IsPositiveLorentzianSupport$, we know that $S$ is the support of some positive Lorentzian polynomial $p$.
  obtain ⟨p, hp⟩ := hS;
  -- Let $k = \minCoord i S$. By definition of $minCoord$, we have $k \leq d$.
  set k := minCoord i S with hk_def
  have hk_le_d : k ≤ d := by
    have := hp.1.1 ; simp_all +decide [ minCoord ];
    by_cases hS : S.Nonempty <;> simp_all +decide [ MvPolynomial.IsHomogeneous ];
    obtain ⟨ m, hm ⟩ := hS; use m; have := this ( show p.coeff m ≠ 0 from by aesop ) ; simp_all +decide [ Finsupp.sum_fintype ] ;
    simp_all +decide [ weight ];
    simp_all +decide [ linearCombination_apply, Finsupp.sum_fintype ];
    exact this ▸ Finset.single_le_sum ( fun a _ => Nat.zero_le ( m a ) ) ( Finset.mem_univ i );
  -- Let $q = (pderiv i)^[k] p$. By lorentzian_iterate_pderiv, $q$ is Lorentzian of degree $d - k$.
  obtain ⟨q, hq⟩ : ∃ q : MvPolynomial (Fin n) ℝ, IsBrandenHuhLorentzian (d - k) q ∧ q.support = (p.support.filter (fun m => m i ≥ k)).image (fun m => m - Finsupp.single i k) := by
    refine' ⟨ ( MvPolynomial.pderiv i ) ^[ k ] p, lorentzian_iterate_pderiv hp.1 i k hk_le_d, _ ⟩;
    -- By definition of $pderiv$, we know that $(pderiv i)^k p$ is the polynomial obtained by differentiating $p$ $k$ times with respect to $x_i$.
    have h_pderiv_k : (MvPolynomial.pderiv i)^[k] p = ∑ m ∈ p.support, MvPolynomial.monomial (m - Finsupp.single i k) (MvPolynomial.coeff m p * Nat.descFactorial (m i) k) := by
      have h_pderiv_k : ∀ m ∈ p.support, (MvPolynomial.pderiv i)^[k] (MvPolynomial.monomial m (MvPolynomial.coeff m p)) = MvPolynomial.monomial (m - Finsupp.single i k) (MvPolynomial.coeff m p * Nat.descFactorial (m i) k) := by
        intro m hm;
        refine' Nat.recOn k _ _ <;> simp_all +decide [ Function.iterate_succ_apply', pderiv_monomial ];
        intro n hn; rw [ ← mul_assoc ] ; rw [ ← tsub_add_eq_tsub_tsub ] ;
        ring;
      conv_lhs => rw [ p.as_sum ];
      rw [ ← Finset.sum_congr rfl h_pderiv_k ];
      induction' p.support using Finset.induction <;> simp_all +decide [ Function.iterate_succ_apply' ];
    ext m; simp [h_pderiv_k];
    simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ];
    rw [ Finset.sum_eq_zero_iff_of_nonneg ] <;> norm_num;
    · grind;
    · intro m hm; split_ifs <;> [ exact mul_nonneg ( le_of_lt ( hp.2.2 m ( by aesop ) ) ) ( Nat.cast_nonneg _ ) ; exact le_rfl ] ;
  -- Let $r = \text{restrictCoord } i q$. By lorentzian_delete, $r$ is Lorentzian of degree $d - k$.
  obtain ⟨r, hr⟩ : ∃ r : MvPolynomial (Fin n) ℝ, IsBrandenHuhLorentzian (d - k) r ∧ r.support = supportDelete i q.support := by
    convert lorentzian_delete _ i using 1;
    exact ⟨ q, hq.1, rfl ⟩;
  refine' ⟨ d - k, Nat.sub_le _ _, r, hr.1, _ ⟩;
  ext; simp [hq, hr, supportContract];
  simp +decide [ supportDelete, hq.2, hp.2.1 ];
  constructor <;> intro h;
  · rcases h with ⟨ ⟨ a, ⟨ ha₁, ha₂ ⟩, rfl ⟩, ha₃ ⟩ ; use a; simp_all +decide [ Finsupp.ext_iff ] ;
    exact le_antisymm ( Nat.le_of_sub_eq_zero ha₃ ) ha₂;
  · obtain ⟨ a, ⟨ ha₁, ha₂ ⟩, rfl ⟩ := h; exact ⟨ ⟨ a, ⟨ ha₁, ha₂.ge ⟩, rfl ⟩, by simp +decide [ ha₂ ] ⟩ ;

/-! ## Section 11: Minor Closure (Flagship Theorem) -/

/-- IsSupportMinor is transitive. -/
theorem IsSupportMinor.trans {n : ℕ} {S T U : Finset (Fin n →₀ ℕ)}
    (h1 : IsSupportMinor S T) (h2 : IsSupportMinor T U) :
    IsSupportMinor S U := by
  induction h1 with
  | refl _ => exact h2
  | delete_step S T i _ ih => exact .delete_step S U i (ih h2)
  | contract_step S T i _ ih => exact .contract_step S U i (ih h2)

/-
**Theorem 4 (Flagship): Minor closure for Lorentzian supports
    under deletion.**

    Every minor obtained by iterated deletions of a Lorentzian support
    is Lorentzian-realizable at the same degree.
-/
theorem lorentzian_deletion_minor_closed {n : ℕ} {d : ℕ}
    {S T : Finset (Fin n →₀ ℕ)}
    (hS : IsLorentzianSupport d S)
    (hminor : IsSupportMinor S T)
    (h_del_only : ∀ (S' T' : Finset (Fin n →₀ ℕ)) (i : Fin n),
      IsSupportMinor (supportContract i S') T' → False) :
    IsLorentzianSupport d T := by
  induction' hminor with S' T' i hminor' ih;
  · assumption;
  · exact ‹IsLorentzianSupport d ( supportDelete hminor' T' ) → IsLorentzianSupport d i› ( lorentzian_delete hS hminor' );
  · exact False.elim <| h_del_only _ _ _ ‹_›

/-! ## Section 12: Exchange Property Bridge -/

/-- The symmetric exchange property for support sets. -/
def SupportExchange {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a : Fin n,
    x a > y a →
    ∃ b : Fin n, y b > x b ∧
      x - Finsupp.single a 1 + Finsupp.single b 1 ∈ S ∧
      y + Finsupp.single a 1 - Finsupp.single b 1 ∈ S

/-- Exchange is preserved by deletion. -/
theorem exchange_of_deletion {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (i : Fin n)
    (hS : SupportExchange S) :
    SupportExchange (supportDelete i S) := by
  intro x hx y hy a hxa
  rw [mem_supportDelete_iff] at hx hy
  obtain ⟨hxS, hxi⟩ := hx
  obtain ⟨hyS, hyi⟩ := hy
  obtain ⟨b, hb_gt, hb_x, hb_y⟩ := hS x hxS y hyS a hxa
  have hai : a ≠ i := by intro h; subst h; omega
  have hbi : b ≠ i := by intro h; subst h; omega
  exact ⟨b, hb_gt,
    mem_supportDelete_iff.mpr ⟨hb_x, by simp [Finsupp.add_apply, Finsupp.tsub_apply, hai, hbi, hxi]⟩,
    mem_supportDelete_iff.mpr ⟨hb_y, by simp [Finsupp.add_apply, Finsupp.tsub_apply, hai, hbi, hyi]⟩⟩

/-! ## Section 13: Well-Foundedness -/

/-- Deletion strictly reduces cardinality when the coordinate is used. -/
theorem supportDelete_card_lt {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {i : Fin n}
    (h : ∃ m ∈ S, m i > 0) :
    (supportDelete i S).card < S.card :=
  Finset.card_lt_card (Finset.filter_ssubset.2
    (by obtain ⟨m, hm, hmi⟩ := h; exact ⟨m, hm, by omega⟩))

/-- Contraction does not increase cardinality. -/
theorem supportContract_card_le {n : ℕ} (i : Fin n) (S : Finset (Fin n →₀ ℕ)) :
    (supportContract i S).card ≤ S.card :=
  Finset.card_image_le.trans (Finset.card_le_card (Finset.filter_subset _ _))

/-! ## Section 14: The Empty Support -/

/-
The empty support is Lorentzian-realizable at any degree.
-/
theorem isLorentzianSupport_empty {n : ℕ} (d : ℕ) :
    IsLorentzianSupport d (∅ : Finset (Fin n →₀ ℕ)) := by
  refine ⟨0, ⟨?_, ?_, ?_⟩, ?_⟩
  ·
    intro m hm; contradiction;
  ·
    norm_num [ MvPolynomial.coeff ]
  · intro hd2 α hα
    exact ⟨0, fun v _ => by
      unfold QuadForm hessianMatrix
      simp +decide [ iteratedPDeriv_zero ]⟩
  · exact MvPolynomial.support_zero

/-! ## Section 15: Conjecture Statement -/

/-- **Conjecture (Positive Realization Minor Closure):**
    Every minor of a positive Lorentzian support is itself a positive
    Lorentzian support. This remains open and would represent a significant
    strengthening of the minor closure theory. -/
theorem positive_realization_minor_closure_conjecture {n : ℕ} {d : ℕ}
    {S T : Finset (Fin n →₀ ℕ)}
    (_hminor : IsSupportMinor S T)
    (_hS : IsPositiveLorentzianSupport d S) :
    ∃ e ≤ d, IsPositiveLorentzianSupport e T := by
  sorry

end LorentzianMinorClosure