/-
Copyright (c) 2025. All rights reserved.

# Evaluation-Kernel Framework for the Finite-Field Polynomial Method

This file establishes the core linear-algebraic machinery behind the polynomial method
over finite fields:

1. An abstract kernel-existence principle: if a linear map from a finite-dimensional
   vector space V to a function space on a finite set E has dim V > |E|, then the kernel
   is nontrivial.

2. Evaluation maps on finite sets for both univariate and multivariate polynomials.

3. Instantiation to univariate polynomials: existence of a nonzero polynomial of
   degree < d vanishing on all of E.

4. Instantiation to multivariate polynomials: existence of a nonzero polynomial of
   bounded total degree vanishing on any set E with |E| < dim M(n,d).

## Main results

* `exists_nonzero_mem_ker_of_finrank_gt` — abstract kernel-existence principle
* `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt` — univariate vanishing
* `exists_nonzero_in_submodule_vanishing` — general submodule vanishing
* `exists_nonzero_mvPoly_vanishing_on_set` — multivariate vanishing (total degree)
* `exists_nonzero_mvPoly_vanishing_on_set_choose` — with explicit binomial bound
-/

import Mathlib

open Polynomial MvPolynomial BigOperators Module Finsupp

noncomputable section

/-! ## Bounded-degree polynomial infrastructure -/

/-- The submodule of multivariate polynomials whose support consists of monomials
    with exponent sum `< d`. -/
def boundedTotalDegreeSubmodule' (K : Type*) [CommSemiring K]
    (σ : Type*) [DecidableEq σ] (d : ℕ) : Submodule K (MvPolynomial σ K) :=
  Finsupp.supported K K {s : σ →₀ ℕ | Finsupp.degree s < d}

/-- Membership in the bounded-degree submodule is characterized by the support condition. -/
theorem mem_boundedTotalDegreeSubmodule_iff' {K : Type*} [CommSemiring K]
    {σ : Type*} [DecidableEq σ] {d : ℕ} (p : MvPolynomial σ K) :
    p ∈ boundedTotalDegreeSubmodule' K σ d ↔
      ∀ s ∈ p.support, Finsupp.degree s < d :=
  Iff.rfl

/-- The bounded-degree submodule is finite-dimensional when `σ = Fin n`. -/
instance finiteDimensional_boundedTotalDegreeSubmodule' (K : Type*) [Field K]
    (n d : ℕ) :
    FiniteDimensional K (boundedTotalDegreeSubmodule' K (Fin n) d) := by
  have hfin : Set.Finite {s : Fin n →₀ ℕ | Finsupp.degree s < d} := by
    apply Set.Finite.subset (Finsupp.finite_of_degree_le d)
    intro s (hs : Finsupp.degree s < d)
    exact Nat.lt_succ_iff.mp (by omega)
  haveI : Finite ↥{s : Fin n →₀ ℕ | Finsupp.degree s < d} := hfin.to_subtype
  exact Module.Finite.equiv
    (Finsupp.supportedEquivFinsupp {s : Fin n →₀ ℕ | Finsupp.degree s < d}).symm

/-! ## Part 1: Abstract Kernel-Existence Principle -/

/-
The dimension of `(↥E → K)` where `E` is a `Finset` equals `E.card`.
-/
theorem finrank_finset_arrow (K : Type*) [Field K] {α : Type*} (E : Finset α) :
    Module.finrank K (E → K) = E.card := by
  simp +decide [ Module.finrank_pi ]

/-
**Abstract kernel-existence principle.**
If `V` is a finite-dimensional vector space over a field `K` and `φ : V →ₗ[K] (↥E → K)`
is a linear map to the function space on a finite set `E`, and `|E| < dim V`, then
there exists a nonzero `v ∈ V` with `φ v = 0`.
-/
theorem exists_nonzero_mem_ker_of_finrank_gt
    (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {α : Type*} (E : Finset α)
    (φ : V →ₗ[K] (E → K))
    (h : E.card < Module.finrank K V) :
    ∃ v : V, v ≠ 0 ∧ φ v = 0 := by
  contrapose! h;
  have := LinearMap.finrank_range_of_inj ( show Function.Injective φ from fun v w h' => Classical.not_not.1 fun h'' => h ( v - w ) ( sub_ne_zero.2 h'' ) ( by simp_all +decide [ sub_eq_zero ] ) );
  exact this ▸ le_trans ( Submodule.finrank_le _ ) ( by simp +decide [ finrank_finset_arrow ] )

/-! ## Part 2: Univariate Evaluation Map and Vanishing Theorem -/

/-- The evaluation map from univariate polynomials to functions on a finset. -/
def evalOnFinsetLinear (K : Type*) [CommSemiring K] (E : Finset K) :
    K[X] →ₗ[K] (E → K) where
  toFun p x := Polynomial.eval (x : K) p
  map_add' p q := by ext x; simp [Polynomial.eval_add]
  map_smul' c p := by ext x; simp [Polynomial.eval_smul]

/-
**Univariate polynomial vanishing theorem.**
For a finite set `E ⊆ K` and degree bound `d` with `|E| < d`, there exists a nonzero
polynomial of degree `< d` vanishing on all of `E`.

Proved constructively via the product `∏_{a ∈ E} (X - C a)`.
-/
theorem exists_nonzero_poly_vanishing_on_finite_set_of_card_lt
    (K : Type*) [Field K]
    (E : Finset K) (d : ℕ)
    (hE : E.card < d) :
    ∃ p : K[X], p ≠ 0 ∧ p.natDegree < d ∧ ∀ x ∈ E, Polynomial.eval x p = 0 := by
  refine' ⟨ ∏ x ∈ E, ( Polynomial.X - Polynomial.C x ), _, _, _ ⟩;
  · exact Finset.prod_ne_zero_iff.mpr fun x hx => Polynomial.X_sub_C_ne_zero x;
  · rw [ Polynomial.natDegree_prod _ _ fun x hx => Polynomial.X_sub_C_ne_zero x ] ; simpa;
  · exact fun x hx => by rw [ Polynomial.eval_prod ] ; exact Finset.prod_eq_zero hx ( by simp +decide ) ;

/-! ## Part 3: Multivariate Evaluation Map -/

/-- The evaluation map from multivariate polynomials in `n` variables to functions
on a finset of points in `K^n`. -/
def mvEvalOnFinsetLinear (K : Type*) [CommSemiring K] (n : ℕ)
    (E : Finset (Fin n → K)) :
    MvPolynomial (Fin n) K →ₗ[K] (E → K) where
  toFun p x := MvPolynomial.eval (x : Fin n → K) p
  map_add' p q := by ext x; simp [map_add]
  map_smul' c p := by ext x; simp [MvPolynomial.smul_eval, smul_eq_mul]

/-- Restriction of the multivariate evaluation map to a bounded-degree submodule. -/
def mvEvalOnFinsetLinearRestrict (K : Type*) [CommSemiring K] (n d : ℕ)
    (E : Finset (Fin n → K)) :
    boundedTotalDegreeSubmodule' K (Fin n) d →ₗ[K] (E → K) :=
  (mvEvalOnFinsetLinear K n E).comp (boundedTotalDegreeSubmodule' K (Fin n) d).subtype

/-! ## Part 4: Multivariate Vanishing Theorems -/

/-
**Multivariate polynomial vanishing theorem (submodule version).**
If `|E| < finrank K L` for a finite-dimensional submodule `L` of `MvPolynomial (Fin n) K`,
then there exists a nonzero polynomial in `L` vanishing on all of `E`.
-/
theorem exists_nonzero_in_submodule_vanishing
    (K : Type*) [Field K]
    (n : ℕ)
    (E : Finset (Fin n → K))
    (L : Submodule K (MvPolynomial (Fin n) K))
    [FiniteDimensional K L]
    (hdim : E.card < Module.finrank K L) :
    ∃ p : L, (p : MvPolynomial (Fin n) K) ≠ 0 ∧
      ∀ x ∈ E, MvPolynomial.eval x (p : MvPolynomial (Fin n) K) = 0 := by
  -- By the abstract kernel-existence principle, there exists a nonzero element in the kernel of the evaluation map.
  obtain ⟨v, hv_ne_zero, hv_ker⟩ : ∃ v : ↥L, v ≠ 0 ∧ (mvEvalOnFinsetLinear K n E).comp (L.subtype) v = 0 := by
    convert exists_nonzero_mem_ker_of_finrank_gt K L E ( mvEvalOnFinsetLinear K n E ∘ₗ L.subtype ) hdim using 1;
  exact ⟨ v, by simpa using hv_ne_zero, fun x hx => by simpa using congr_fun hv_ker ⟨ x, hx ⟩ ⟩

/-
**Multivariate polynomial vanishing theorem (degree-controlled).**
For a finite set `E ⊆ K^n` with `|E| < dim M(n,d)`, there exists a nonzero
polynomial of total degree `< d` vanishing on all of `E`.
-/
theorem exists_nonzero_mvPoly_vanishing_on_set
    (K : Type*) [Field K]
    (n d : ℕ)
    (E : Finset (Fin n → K))
    (hE : E.card < Module.finrank K (boundedTotalDegreeSubmodule' K (Fin n) d)) :
    ∃ p : MvPolynomial (Fin n) K,
      p ≠ 0 ∧
      (∀ m ∈ p.support, Finsupp.degree m < d) ∧
      ∀ x ∈ E, MvPolynomial.eval x p = 0 := by
  have := @exists_nonzero_in_submodule_vanishing K _ n E ( boundedTotalDegreeSubmodule' K ( Fin n ) d ) _ hE;
  obtain ⟨ p, hp₁, hp₂ ⟩ := this; use p; simp_all +decide [ mem_boundedTotalDegreeSubmodule_iff' ] ;
  exact fun m hm => mem_boundedTotalDegreeSubmodule_iff' _ |>.1 p.2 m ( by aesop )

noncomputable instance fintypeBoundedDegreeFinsuppFin' (n d : ℕ) :
    Fintype {s : Fin n →₀ ℕ // Finsupp.degree s < d} := by
  have hfin : Set.Finite {s : Fin n →₀ ℕ | Finsupp.degree s < d} := by
    apply Set.Finite.subset (Finsupp.finite_of_degree_le d)
    intro s (hs : Finsupp.degree s < d)
    exact Nat.lt_succ_iff.mp (by omega)
  exact hfin.fintype

/-
The finrank of the bounded-degree submodule equals the number of
bounded-degree monomials.
-/
theorem finrank_boundedTotalDegreeSubmodule'_eq_card (K : Type*) [Field K] (n d : ℕ) :
    Module.finrank K (boundedTotalDegreeSubmodule' K (Fin n) d) =
      Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s < d} := by
  have h_basis : (boundedTotalDegreeSubmodule' K (Fin n) d).toAddSubmonoid = Submodule.toAddSubmonoid (Submodule.span K (Set.range (fun s : {s : Fin n →₀ ℕ // Finsupp.degree s < d} => Finsupp.single s.val 1))) := by
    ext; simp [boundedTotalDegreeSubmodule'];
    refine' ⟨ fun h => _, fun h => _ ⟩;
    · refine' Submodule.mem_span.mpr _;
      intro p hp
      have h_sum : ∑ s ∈ (‹MvPolynomial (Fin n) K›).support, (‹MvPolynomial (Fin n) K›).coeff s • Finsupp.single s 1 = ‹MvPolynomial (Fin n) K› := by
        ext; simp [MvPolynomial.coeff_sum];
        rw [ Finset.sum_eq_single ‹_› ] <;> aesop;
      exact h_sum ▸ p.sum_mem fun s hs => p.smul_mem _ ( hp ⟨ ⟨ s, by aesop ⟩, rfl ⟩ );
    · refine' Submodule.span_induction _ _ _ _ h;
      · simp +decide [ Finsupp.mem_supported ];
        exact fun s hs => Finsupp.single_mem_supported _ _ hs;
      · simp +decide [ Finsupp.mem_supported ];
      · exact fun x y hx hy hx' hy' => Submodule.add_mem _ hx' hy';
      · finiteness;
  have h_basis : Basis {s : Fin n →₀ ℕ // Finsupp.degree s < d} K (boundedTotalDegreeSubmodule' K (Fin n) d) := by
    exact Finsupp.basisSingleOne.map ( Finsupp.supportedEquivFinsupp _ ).symm;
  convert ( finrank_eq_card_basis h_basis )

/-
The cardinality of bounded-degree monomials on `Fin n` equals `C(d+n-1, n)`
when `0 < d + n`.
-/
theorem card_bounded_degree_monomials_eq_choose (n d : ℕ) (h : 0 < d + n) :
    Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s < d} =
      Nat.choose (d + n - 1) n := by
  have := @finrank_boundedTotalDegreeSubmodule'_eq_card;
  rw [ ← this ( ZMod 2 ) n d ];
  have h_basis : Module.finrank (ZMod 2) (boundedTotalDegreeSubmodule' (ZMod 2) (Fin n) d) = Finset.card (Finset.filter (fun s : Fin n → ℕ => ∑ i, s i < d) (Finset.Iic (fun _ => d))) := by
    have h_basis : Module.finrank (ZMod 2) (boundedTotalDegreeSubmodule' (ZMod 2) (Fin n) d) = Finset.card (Finset.image (fun s : Fin n →₀ ℕ => s.toFun) (Finset.filter (fun s : Fin n →₀ ℕ => Finsupp.degree s < d) (Finset.Iic (Finsupp.equivFunOnFinite.symm (fun _ => d))))) := by
      rw [ this ];
      rw [ Fintype.card_of_subtype ];
      rotate_left;
      exact Finset.filter ( fun s => Finsupp.degree s < d ) ( Finset.Iic ( Finsupp.equivFunOnFinite.symm fun _ => d ) );
      · simp +decide [ Finsupp.degree ];
        intro x hx; intro i; by_cases hi : i ∈ x.support <;> simp_all +decide [ Finsupp.le_def ] ;
        exact le_trans ( Finset.single_le_sum ( fun a _ => Nat.zero_le ( x a ) ) ( by aesop ) ) hx.le;
      · rw [ Finset.card_image_of_injective _ fun x y hxy => by ext i; simpa using congr_fun hxy i ];
    rw [ h_basis, Finset.card_image_of_injective ];
    · refine' Finset.card_bij ( fun s hs => s.toFun ) _ _ _ <;> simp +decide [ Finsupp.degree ];
      · intro a ha₁ ha₂; refine' ⟨ _, _ ⟩;
        · exact fun i => ha₁ i;
        · convert ha₂ using 1;
          rw [ Finset.sum_subset ( Finset.subset_univ a.support ) ] ; aesop;
          exact fun x _ hx => by simpa using hx;
      · exact fun a₁ a₂ h₁ h₂ h₃ h₄ h₅ => by ext i; simpa using congr_fun h₅ i;
      · intro b hb₁ hb₂; use Finsupp.equivFunOnFinite.symm b; simp_all +decide [ Finsupp.le_def ] ;
        exact ⟨ ⟨ hb₁, lt_of_le_of_lt ( Finset.sum_le_sum_of_subset ( Finset.subset_univ _ ) ) hb₂ ⟩, rfl ⟩;
    · exact fun s t h => by ext i; simpa using congr_fun h i;
  rw [ h_basis ];
  clear h_basis this;
  induction' n with n ih generalizing d;
  · aesop;
  · nontriviality;
    rw [ show ( Finset.filter ( fun s : Fin ( n + 1 ) → ℕ => ∑ i, s i < d ) ( Finset.Iic fun _ => d ) ) = Finset.biUnion ( Finset.range d ) fun k => Finset.image ( fun s : Fin n → ℕ => Fin.cons k s ) ( Finset.filter ( fun s : Fin n → ℕ => ∑ i, s i < d - k ) ( Finset.Iic fun _ => d - k ) ) from ?_, Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ <| fun a b h => by simpa [ Fin.ext_iff ] using h ];
      rw [ Finset.sum_congr rfl fun x hx => ih _ <| by linarith [ Finset.mem_range.mp hx, Nat.sub_add_cancel ( show x ≤ d from Finset.mem_range_le hx ) ] ];
      exact Nat.recOn d ( by norm_num ) fun d ih => by simp_all +decide [ Nat.choose, add_comm, add_left_comm, Finset.sum_range_succ' ] ;
    · intros k hk l hl hkl; simp [Finset.disjoint_left, Finset.mem_image];
      intro a x hx₁ hx₂ hx₃ y hy₁ hy₂ hy₃; contrapose! hkl; aesop;
    · ext s; simp [Finset.mem_biUnion, Finset.mem_image];
      constructor;
      · intro hs;
        use s 0;
        refine' ⟨ _, Fin.tail s, _, _ ⟩ <;> simp_all +decide [ Fin.sum_univ_succ ];
        · grind +suggestions;
        · exact ⟨ fun i => Nat.le_sub_of_add_le <| by linarith! [ hs.1 i.succ, Finset.single_le_sum ( fun a _ => Nat.zero_le ( s ( Fin.succ a ) ) ) ( Finset.mem_univ i ) ], lt_tsub_iff_left.mpr <| by linarith! ⟩;
      · rintro ⟨ a, ha, b, hb, rfl ⟩ ; simp_all +decide [ Fin.sum_univ_succ, Fin.cons ];
        exact ⟨ fun i => by cases i using Fin.inductionOn <;> [ exact Nat.le_of_lt ha; exact le_trans ( hb.1 _ ) ( Nat.sub_le _ _ ) ], by linarith [ Nat.sub_add_cancel ha.le ] ⟩

/-- **Multivariate polynomial vanishing theorem with explicit dimension bound.**
When `0 < d + n`, the dimension condition becomes `|E| < C(d+n-1, n)`. -/
theorem exists_nonzero_mvPoly_vanishing_on_set_choose
    (K : Type*) [Field K]
    (n d : ℕ)
    (E : Finset (Fin n → K))
    (hdn : 0 < d + n)
    (hE : E.card < Nat.choose (d + n - 1) n) :
    ∃ p : MvPolynomial (Fin n) K,
      p ≠ 0 ∧
      (∀ m ∈ p.support, Finsupp.degree m < d) ∧
      ∀ x ∈ E, MvPolynomial.eval x p = 0 := by
  apply exists_nonzero_mvPoly_vanishing_on_set
  rw [finrank_boundedTotalDegreeSubmodule'_eq_card, card_bounded_degree_monomials_eq_choose n d hdn]
  exact hE

end