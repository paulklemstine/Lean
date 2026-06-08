/-
  # Evaluation-Kernel Calculus for the Finite-Field Polynomial Method

  This file formalizes the core linear-algebraic engine behind the polynomial method
  over finite fields. The central insight: when a finite set E is too small to support
  all evaluations from a finite-dimensional vector space V, rank-nullity forces
  a nonzero element of V to vanish on all of E.

  ## Main results

  - `exists_nonzero_mem_ker_of_finrank_gt`: Abstract kernel-existence principle.
    If dim(V) > |E|, any linear map V →ₗ (E → K) has nontrivial kernel.

  - `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt`: Univariate polynomial
    witness theorem. If |E| < d, there exists a nonzero polynomial of degree < d
    vanishing on all of E.

  - `exists_nonzero_in_lowTotalDegree_vanishing`: Multivariate polynomial
    witness theorem via submodule kernel extraction.

  - `exists_nonzero_mvPolynomial_vanishing_on_finite_set_of_card_lt_pow`:
    Box-degree multivariate vanishing theorem.

  ## Architecture

  The evaluation map is defined as a linear map from the polynomial space to the
  function space on E. The abstract kernel theorem isolates the linear algebra,
  making it reusable for Reed-Muller codes, algebraic complexity, and finite geometry.
-/

import Mathlib

open Polynomial MvPolynomial Finset

noncomputable section

/-! ## Abstract Kernel-Existence Principle

The core rank-nullity argument: if a linear map sends a finite-dimensional space V
into a space of dimension at most |E|, and dim(V) > |E|, then the kernel is nontrivial.
-/

/-
**Abstract kernel-existence principle.**
If `V` is a finite-dimensional vector space over a field `K`, and `φ : V →ₗ[K] (E → K)`
is a linear map into the function space on a finite set `E`, then whenever
`|E| < dim(V)`, there exists a nonzero `v ∈ V` with `φ(v) = 0`.

This is the universal polynomial witness extractor: it produces vanishing certificates
from dimension counts alone.
-/
theorem exists_nonzero_mem_ker_of_finrank_gt
    (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {α : Type*} (E : Finset α)
    (φ : V →ₗ[K] (E → K))
    (h : E.card < Module.finrank K V) :
    ∃ v : V, v ≠ 0 ∧ φ v = 0 := by
  -- Use rank-nullity (LinearMap.finrank_range_add_finrank_ker). The range of phi is
  -- an image subspace of (E → K), which has dimension E.card (by Module.finrank_pi).
  have h_rank : LinearMap.rank φ ≤ E.card := by
    exact le_trans ( LinearMap.rank_le_range _ ) ( by simp +decide );
  contrapose! h_rank;
  rw [ LinearMap.rank ];
  rw [ ← Module.finrank_eq_rank, LinearMap.finrank_range_of_inj ];
  · exact_mod_cast h;
  · exact LinearMap.ker_eq_bot.mp ( LinearMap.ker_eq_bot'.mpr fun v hv => Classical.not_not.1 fun hv' => h_rank v hv' hv )

/-! ## Evaluation Linear Maps -/

/-- The evaluation map for univariate polynomials on a finite set,
as a K-linear map from K[X] to (E → K). -/
def Polynomial.evalOnFinsetLinear
    (K : Type*) [CommSemiring K]
    (E : Finset K) :
    K[X] →ₗ[K] (E → K) where
  toFun p := fun ⟨x, _⟩ => Polynomial.eval x p
  map_add' p q := by ext ⟨x, _⟩; simp [Polynomial.eval_add]
  map_smul' r p := by ext ⟨x, _⟩; simp [Polynomial.eval_smul]

/-- The evaluation map for multivariate polynomials on a finite set,
as a K-linear map from MvPolynomial (Fin n) K to (E → K). -/
def MvPolynomial.evalOnFinsetLinear
    (K : Type*) [CommSemiring K]
    (n : ℕ) (E : Finset (Fin n → K)) :
    MvPolynomial (Fin n) K →ₗ[K] (E → K) where
  toFun p := fun ⟨x, _⟩ => MvPolynomial.eval x p
  map_add' p q := by ext ⟨x, _⟩; simp [map_add]
  map_smul' r p := by ext ⟨x, _⟩; simp

/-! ## Univariate Polynomial Vanishing Theorem -/

/-
**Univariate polynomial vanishing theorem.**
For any finite set E ⊆ K and degree bound d with |E| < d,
there exists a nonzero polynomial p of degree < d vanishing on all of E.

This is proved constructively: p = ∏_{a ∈ E} (X - C a) has degree |E| < d.
-/
theorem exists_nonzero_poly_vanishing_on_finite_set_of_card_lt
    (K : Type*) [Field K]
    (E : Finset K) (d : ℕ)
    (hE : E.card < d) :
    ∃ p : K[X], p ≠ 0 ∧ p.natDegree < d ∧ ∀ x ∈ E, Polynomial.eval x p = 0 := by
  refine' ⟨ ∏ x ∈ E, ( Polynomial.X - Polynomial.C x ), _, _, _ ⟩;
  · exact Finset.prod_ne_zero_iff.mpr fun x hx => Polynomial.X_sub_C_ne_zero x;
  · rw [ Polynomial.natDegree_prod _ _ fun x hx => Polynomial.X_sub_C_ne_zero x ] ; aesop;
  · exact fun x hx => by rw [ Polynomial.eval_prod ] ; exact Finset.prod_eq_zero hx ( by simp +decide ) ;

/-! ## Multivariate Evaluation-Kernel Theorem -/

/-
**Multivariate polynomial vanishing theorem via submodule kernel extraction.**
Given a finite-dimensional submodule L of MvPolynomial (Fin n) K whose elements
have total degree < d, if |E| < dim(L), then there exists a nonzero polynomial
in L vanishing on all of E.
-/
theorem exists_nonzero_in_lowTotalDegree_vanishing
    (K : Type*) [Field K]
    (n : ℕ) (d : ℕ)
    (E : Finset (Fin n → K))
    (L : Submodule K (MvPolynomial (Fin n) K))
    [FiniteDimensional K L]
    (_hLdeg : ∀ p ∈ L, ∀ m ∈ (p : MvPolynomial (Fin n) K).support,
      m.sum (fun _ e => e) < d)
    (hdim : E.card < Module.finrank K L) :
    ∃ p : L, (p : MvPolynomial (Fin n) K) ≠ 0 ∧
      ∀ x ∈ E, MvPolynomial.eval x (p : MvPolynomial (Fin n) K) = 0 := by
  -- Define the linear map $\phi : L \to (E \to K)$ by $\phi(p)(x) = \text{eval}(x, p)$.
  set phi : L →ₗ[K] (E → K) := { toFun := fun p => fun ⟨x, hx⟩ => MvPolynomial.eval x p.val, map_add' := by
                                  exact fun x y => funext fun z => by simp +decide [ map_add ] ;, map_smul' := by
                                  simp +decide;
                                  exact fun m p hp => rfl }
  generalize_proofs at *;
  -- By the rank-nullity theorem, since the dimension of L is greater than the cardinality of E, the kernel of phi is nontrivial.
  have h_ker_nontrivial : ∃ p : L, p ≠ 0 ∧ phi p = 0 := by
    apply exists_nonzero_mem_ker_of_finrank_gt K L E phi hdim;
  obtain ⟨ p, hp₁, hp₂ ⟩ := h_ker_nontrivial; use p; simp_all +decide [ funext_iff ] ;
  exact fun x hx => hp₂ x hx

/-! ## Box-Degree Multivariate Vanishing Theorem -/

/-
**Box-degree multivariate vanishing theorem.**
For polynomials with each variable's degree bounded by d,
the space has dimension d^n. If |E| < d^n, there exists
a nonzero polynomial with all variable degrees < d vanishing on E.
-/
theorem exists_nonzero_mvPolynomial_vanishing_on_finite_set_of_card_lt_pow
    (K : Type*) [Field K]
    (n d : ℕ)
    (E : Finset (Fin n → K))
    (hE : E.card < d ^ n) :
    ∃ p : MvPolynomial (Fin n) K,
      p ≠ 0 ∧
      (∀ m ∈ p.support, ∀ i, m i < d) ∧
      ∀ x ∈ E, MvPolynomial.eval x p = 0 := by
  -- Consider the subspace L of MvPolynomial (Fin n) K spanned by monomials X^α for α : Fin n → ℕ with ∀ i, α i < d.
  set S : Finset ((Fin n) →₀ ℕ) := Finset.image (fun α : Fin n → Fin d => Finsupp.equivFunOnFinite.symm (fun i => (α i : ℕ))) (Finset.univ : Finset (Fin n → Fin d)) with hS_def;
  -- Let L = Submodule.span K (MvPolynomial.monomial · 1 '' S) or equivalently the span of these monomials
  set L : Submodule K (MvPolynomial (Fin n) K) := Submodule.span K (Set.image (fun m : (Fin n) →₀ ℕ => MvPolynomial.monomial m 1) S) with hL_def;
  -- Show L has dimension = |S| = d^n (using linear independence of monomials)
  have hL_dim : Module.finrank K L = d^n := by
    have hL_dim : Module.finrank K L = Finset.card S := by
      have h_basis : LinearIndependent K (fun m : S => MvPolynomial.monomial m.val 1 : S → MvPolynomial (Fin n) K) := by
        refine' Fintype.linearIndependent_iff.2 _;
        intro g hg i; replace hg := congr_arg ( fun p => MvPolynomial.coeff ( i : ( Fin n ) →₀ ℕ ) p ) hg; simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ] ;
      convert ( finrank_span_eq_card <| h_basis );
      · ext; simp [Set.mem_image, Set.mem_range];
      · ext; simp [Set.mem_image];
      · ext; simp [Set.mem_image];
      · rw [ Fintype.card_of_subtype ] ; aesop;
    rw [ hL_dim, Finset.card_image_of_injective ];
    · simp +decide [ Finset.card_univ ];
    · exact fun α β h => by ext i; simpa using congr_arg ( fun f => f i ) h;
  -- Apply exists_nonzero_mem_ker_of_finrank_gt with V = L
  obtain ⟨p, hp_ne_zero, hp_eval⟩ : ∃ p : L, p ≠ 0 ∧ ∀ x ∈ E, MvPolynomial.eval x (p : MvPolynomial (Fin n) K) = 0 := by
    convert exists_nonzero_mem_ker_of_finrank_gt K L E ( show L →ₗ[K] ( E → K ) from ?_ ) ?_;
    rotate_left;
    exact FiniteDimensional.of_finrank_pos ( by linarith );
    refine' { toFun := fun p => fun x => MvPolynomial.eval x p.val, map_add' := _, map_smul' := _ };
    all_goals norm_num [ funext_iff, hL_dim ];
    exact hE;
  refine' ⟨ p, _, _, hp_eval ⟩;
  · exact fun h => hp_ne_zero <| Subtype.ext h;
  · intro m hm i;
    have h_support : ∀ p ∈ L, ∀ m ∈ p.support, m ∈ S := by
      intro p hp m hm;
      rw [ Finsupp.mem_span_image_iff_linearCombination ] at hp;
      obtain ⟨ l, hl, rfl ⟩ := hp;
      simp_all +decide [ Finsupp.linearCombination_apply, Finsupp.sum ];
      simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_smul ];
      exact hl ( by aesop );
    specialize h_support p p.2 m hm;
    rw [ Finset.mem_image ] at h_support; obtain ⟨ α, _, rfl ⟩ := h_support; simp +decide ;

end