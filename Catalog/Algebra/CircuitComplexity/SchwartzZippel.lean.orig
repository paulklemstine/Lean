/-
  # Schwartz–Zippel Lemma — Polynomial Identity Testing over Finite Fields

  This file formalizes the Schwartz–Zippel lemma: a nonzero multivariate polynomial
  of total degree d over a finite field K has at most d · |K|^{n-1} zeros.

  The proof proceeds by induction on the number of variables using
  `MvPolynomial.finSuccEquiv` to decompose a polynomial in n+1 variables as a
  univariate polynomial over the ring of polynomials in n variables.

  Key results:
  - `schwartz_zippel_succ`: the main Schwartz–Zippel bound for Fin (n+1)
  - `schwartz_zippel_zmod`: specialization to ZMod q
  - `linear_schwartz_zippel`: the degree-1 case
  - `linear_zero_probability_le`: probability form of the degree-1 case

  Dependencies:
  - Uses `univariate_root_bound` from NullstellensatzPIT.lean as the base case engine.
-/

import Mathlib

open Classical in
noncomputable section

namespace SchwartzZippel

open MvPolynomial Polynomial Finset BigOperators

variable {K : Type*} [Field K] [Fintype K]

/-! ## Fiber Polynomial Construction

We use `MvPolynomial.finSuccEquiv` to view a polynomial in Fin (n+1) variables
as a univariate polynomial over MvPolynomial (Fin n). -/

/-- The fiber polynomial: specialize a polynomial in n+1 variables by evaluating
    the first n coefficient variables at `a`, obtaining a univariate polynomial. -/
noncomputable def fiberPoly {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) K) (a : Fin n → K) : Polynomial K :=
  Polynomial.map (MvPolynomial.eval a) (MvPolynomial.finSuccEquiv K n f)

/-- Evaluating the fiber polynomial at t gives the same result as evaluating
    the original polynomial at the extended assignment (Fin.cons t a). -/
theorem eval_fiberPoly {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) K) (a : Fin n → K) (t : K) :
    Polynomial.eval t (fiberPoly f a) =
      MvPolynomial.eval (Fin.cons t a) f := by
  simp only [fiberPoly]
  rw [Polynomial.eval_map, ← Polynomial.eval_map (MvPolynomial.eval a)]
  exact (MvPolynomial.eval_eq_eval_mv_eval' a t f).symm

/-
The degree of a fiber polynomial is at most the total degree of f.
-/
theorem natDegree_fiberPoly_le {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) K) (a : Fin n → K) :
    (fiberPoly f a).natDegree ≤ f.totalDegree := by
  -- By definition of `fiberPoly`, we know that its degree is at most the total degree of `f`.
  have h_deg_fiber : (fiberPoly f a).natDegree ≤ (MvPolynomial.finSuccEquiv K n f).natDegree := by
    exact Polynomial.natDegree_map_le;
  refine' le_trans h_deg_fiber _;
  convert MvPolynomial.degreeOf_le_totalDegree f 0;
  exact MvPolynomial.natDegree_finSuccEquiv f

/-- The natDegree of the finSuccEquiv image equals degreeOf 0. -/
theorem natDegree_finSuccEquiv_eq {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) K) :
    (MvPolynomial.finSuccEquiv K n f).natDegree = MvPolynomial.degreeOf 0 f :=
  MvPolynomial.natDegree_finSuccEquiv f

/-! ## Zero Set Counting -/

/-
**Schwartz–Zippel base case**: A nonzero polynomial in 1 variable
    over a finite field K has at most totalDegree(f) zeros.
-/
theorem schwartz_zippel_one
    (f : MvPolynomial (Fin 1) K)
    (hf : f ≠ 0) :
    Fintype.card {x : Fin 1 → K // MvPolynomial.eval x f = 0} ≤
      f.totalDegree := by
  -- Apply the univariate root bound to the polynomial f.
  have h_univariate : (Fintype.card { x : Fin 1 → K // (MvPolynomial.eval x) f = 0 }) ≤ (MvPolynomial.eval₂ Polynomial.C (fun i => Polynomial.X) f).natDegree := by
    -- By definition of $f$, we know that its evaluation at any point in $Fin 1 → K$ corresponds to evaluating the univariate polynomial $g$ at the first coordinate of that point.
    have h_eval : ∀ x : Fin 1 → K, (MvPolynomial.eval x) f = Polynomial.eval (x 0) (MvPolynomial.eval₂ Polynomial.C (fun i => Polynomial.X) f) := by
      intro x
      simp [MvPolynomial.eval₂_eq'];
      simp +decide [ MvPolynomial.eval_eq', Polynomial.eval_finset_sum ];
    have h_roots : (Fintype.card { x : Fin 1 → K // (MvPolynomial.eval x) f = 0 }) ≤ (Multiset.toFinset (Polynomial.roots (MvPolynomial.eval₂ Polynomial.C (fun i => Polynomial.X) f))).card := by
      have h_roots : (Finset.image (fun x : Fin 1 → K => x 0) (Finset.filter (fun x : Fin 1 → K => (MvPolynomial.eval x) f = 0) (Finset.univ : Finset (Fin 1 → K)))) ⊆ (Multiset.toFinset (Polynomial.roots (MvPolynomial.eval₂ Polynomial.C (fun i => Polynomial.X) f))) := by
        simp_all +decide [ Finset.subset_iff ];
        intro x hx; contrapose! hf; simp_all +decide [ MvPolynomial.eval₂_eq' ] ;
        ext x; replace hf := congr_arg ( fun p => p.coeff ( x 0 ) ) hf; simp_all +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow ] ;
        rw [ Finset.sum_eq_single x ] at hf <;> simp_all +decide [ Finsupp.ext_iff, Fin.forall_fin_one ];
        exact fun b hb hb' => Ne.symm hb';
      convert Finset.card_le_card h_roots using 1;
      rw [ Finset.card_image_of_injective _ fun x y hxy => by ext i; fin_cases i; exact hxy ] ; simp +decide [ Fintype.card_subtype ] ;
    exact h_roots.trans ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) );
  refine' le_trans h_univariate _;
  refine' le_trans ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_le _ );
  simp +contextual [ Polynomial.natDegree_le_iff_degree_le, Polynomial.degree_le_iff_coeff_zero ];
  intro b hb; exact Finset.le_sup ( f := fun s => Finsupp.sum s fun x e => e ) ( MvPolynomial.mem_support_iff.mpr hb ) |> le_trans ( by simp +decide [ Finsupp.sum_fintype ] ) ;

/-
**Schwartz–Zippel Lemma (successor form)**: A nonzero polynomial in n+1 variables
    over a finite field K has at most `totalDegree(f) * |K|^n` zeros.

    This is the main theorem, proved by induction on n.
    - Base case (n=0, 1 variable): reduces to the univariate root bound.
    - Inductive step: decomposes via fiber polynomials and counts zeros
      by splitting into "good" fibers (nonzero univariate) and "bad" fibers
      (zero univariate, bounded by induction on a coefficient).
-/
theorem schwartz_zippel_succ {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) K)
    (hf : f ≠ 0) :
    Fintype.card {x : Fin (n + 1) → K // MvPolynomial.eval x f = 0} ≤
      f.totalDegree * (Fintype.card K) ^ n := by
  revert hf f;
  induction' n with n ih <;> intro f hf;
  · convert schwartz_zippel_one f hf using 1;
    grind;
  · -- Let $d = \deg(f)$ and $c_d$ be the leading coefficient of $f$.
    set d := MvPolynomial.degreeOf 0 f
    set c_d := (MvPolynomial.finSuccEquiv K (n + 1) f).coeff d;
    -- The number of bad $a$'s is bounded by the induction hypothesis applied to $c_d$.
    have h_bad : Fintype.card {a : Fin (n + 1) → K | MvPolynomial.eval a c_d = 0} ≤ c_d.totalDegree * Fintype.card K ^ n := by
      by_cases hc_d : c_d = 0;
      · have h_deg : Polynomial.natDegree (MvPolynomial.finSuccEquiv K (n + 1) f) = d := by
          convert natDegree_finSuccEquiv_eq f;
        have h_deg : Polynomial.coeff (MvPolynomial.finSuccEquiv K (n + 1) f) (Polynomial.natDegree (MvPolynomial.finSuccEquiv K (n + 1) f)) ≠ 0 := by
          simp +decide [ hf ];
        aesop;
      · exact ih c_d hc_d;
    -- The number of good $a$'s is bounded by the total degree of $f$.
    have h_good : ∀ a : Fin (n + 1) → K, MvPolynomial.eval a c_d ≠ 0 → Fintype.card {t : K | MvPolynomial.eval (Fin.cons t a) f = 0} ≤ d := by
      intro a ha
      have h_fiber : (MvPolynomial.finSuccEquiv K (n + 1) f).map (MvPolynomial.eval a) ≠ 0 := by
        intro h; replace h := congr_arg ( fun p => p.coeff d ) h; simp_all +decide [ Polynomial.coeff_map ] ;
        exact ha h;
      have h_fiber_deg : (Polynomial.map (MvPolynomial.eval a) (MvPolynomial.finSuccEquiv K (n + 1) f)).natDegree ≤ d := by
        have h_fiber_deg : (MvPolynomial.finSuccEquiv K (n + 1) f).natDegree ≤ d := by
          rw [ natDegree_finSuccEquiv_eq ];
        exact le_trans ( Polynomial.natDegree_map_le ) h_fiber_deg;
      have h_fiber_roots : Fintype.card {t : K | Polynomial.eval t (Polynomial.map (MvPolynomial.eval a) (MvPolynomial.finSuccEquiv K (n + 1) f)) = 0} ≤ d := by
        rw [ Fintype.card_subtype ];
        exact le_trans ( Finset.card_le_card ( show _ ⊆ ( Polynomial.map ( MvPolynomial.eval a ) ( MvPolynomial.finSuccEquiv K ( n + 1 ) f ) |> Polynomial.roots |> Multiset.toFinset ) from fun x hx => by aesop ) ) ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) ) |> le_trans <| h_fiber_deg;
      convert h_fiber_roots using 1;
      simp +decide [ ← eval_fiberPoly ];
      rfl;
    -- The total number of zeros is the sum of the number of bad zeros and the number of good zeros.
    have h_total : Fintype.card {x : Fin (n + 2) → K | MvPolynomial.eval x f = 0} ≤ Fintype.card {a : Fin (n + 1) → K | MvPolynomial.eval a c_d = 0} * Fintype.card K + (Fintype.card K ^ (n + 1) - Fintype.card {a : Fin (n + 1) → K | MvPolynomial.eval a c_d = 0}) * d := by
      have h_total : Fintype.card {x : Fin (n + 2) → K | MvPolynomial.eval x f = 0} ≤ ∑ a : Fin (n + 1) → K, Fintype.card {t : K | MvPolynomial.eval (Fin.cons t a) f = 0} := by
        simp +decide only [Fintype.card_subtype];
        simp +decide only [card_filter];
        rw [ ← Finset.sum_product' ];
        refine' le_of_eq _;
        refine' Finset.sum_bij ( fun x _ => ( Fin.tail x, x 0 ) ) _ _ _ _ <;> simp +decide;
        · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff, Fin.tail ] ;
        · exact fun a b => ⟨ Fin.cons b a, rfl, rfl ⟩;
      refine le_trans h_total ?_;
      refine' le_trans ( Finset.sum_le_sum fun a _ => show Fintype.card { t : K | MvPolynomial.eval ( Fin.cons t a ) f = 0 } ≤ if MvPolynomial.eval a c_d = 0 then Fintype.card K else d from _ ) _;
      · split_ifs with h <;> simp_all +decide [ Fintype.card_subtype ];
        exact Finset.card_le_univ _;
      · simp +decide [ Finset.sum_ite, Fintype.card_subtype ];
        rw [ Finset.filter_not, Finset.card_sdiff ] ; simp +decide [ Finset.card_univ ];
    -- Since $c_d$ is a coefficient of $f$, we have $c_d.totalDegree \leq f.totalDegree - d$.
    have h_coeff : c_d.totalDegree ≤ f.totalDegree - d := by
      have h_coeff : ∀ m ∈ c_d.support, m.sum (fun i e => e) ≤ f.totalDegree - d := by
        intro m hm
        have h_coeff : (Finsupp.cons d m).sum (fun i e => e) ≤ f.totalDegree := by
          have h_coeff : (Finsupp.cons d m) ∈ f.support := by
            simp +zetaDelta at *;
            convert hm using 1;
            rw [ MvPolynomial.finSuccEquiv_coeff_coeff ];
          exact Finset.le_sup ( f := fun s => s.sum fun i e => e ) h_coeff;
        rw [ Finsupp.sum_cons ] at h_coeff ; omega;
      exact Finset.sup_le h_coeff;
    refine le_trans h_total ?_;
    refine' le_trans ( add_le_add ( Nat.mul_le_mul_right _ h_bad ) ( Nat.mul_le_mul_right _ ( Nat.sub_le_sub_right ( show Fintype.card K ^ ( n + 1 ) ≤ Fintype.card K ^ ( n + 1 ) from le_rfl ) _ ) ) ) _;
    refine' le_trans ( add_le_add ( Nat.mul_le_mul_right _ ( Nat.mul_le_mul_right _ h_coeff ) ) ( Nat.mul_le_mul_right _ ( Nat.sub_le _ _ ) ) ) _;
    rw [ show Fintype.card K ^ ( n + 1 ) = Fintype.card K ^ n * Fintype.card K by ring ];
    nlinarith only [ Nat.sub_add_cancel ( show d ≤ f.totalDegree from MvPolynomial.degreeOf_le_totalDegree _ _ ), show 0 ≤ Fintype.card K ^ n * Fintype.card K by positivity ]

/-
**Schwartz–Zippel over ZMod q**: A nonzero polynomial in n+1 variables
    over ZMod q has at most `totalDegree(f) * q^n` zeros.
-/
theorem schwartz_zippel_zmod {q : ℕ} [Fact q.Prime] {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) (ZMod q))
    (hf : f ≠ 0) :
    Fintype.card {x : Fin (n + 1) → ZMod q // MvPolynomial.eval x f = 0} ≤
      f.totalDegree * q ^ n := by
  -- Let's rewrite the goal using the definition of Schwartz-Zippel Over ZMod q.
  convert schwartz_zippel_succ f hf using 1;
  · convert rfl;
  · norm_num [ ZMod.card ]

/-! ## Linear Specialization -/

/-
**Linear Schwartz–Zippel**: A nonzero polynomial of total degree ≤ 1
    has at most |K|^{n-1} zeros. This is the algebraic principle behind
    Freivalds' algorithm.
-/
theorem linear_schwartz_zippel {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ 1) :
    Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0} ≤
      (Fintype.card K) ^ (n - 1) := by
  rcases n with ( _ | n ) <;> simp_all +decide;
  · rw [ MvPolynomial.eq_C_of_isEmpty f ] at hf ⊢ ; aesop;
  · exact le_trans ( schwartz_zippel_succ f hf ) ( by simpa using Nat.mul_le_mul_right _ hdeg )

/-
**Linear zero probability bound**: A nonzero polynomial of degree ≤ 1
    vanishes on at most 1/|K| of all inputs.
-/
theorem linear_zero_probability_le {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ 1) :
    (Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0} : ℚ) /
      (Fintype.card (Fin n → K) : ℚ) ≤ 1 / Fintype.card K := by
  by_cases hn : n = 0;
  · subst hn; simp_all +decide [ MvPolynomial.totalDegree ] ;
    rw [ MvPolynomial.eq_C_of_isEmpty f ] at hf ⊢ ; aesop;
  · rw [ div_le_div_iff₀ ] <;> norm_cast <;> norm_num;
    · convert mul_le_mul_of_nonneg_right ( linear_schwartz_zippel f hf hdeg ) ( Nat.zero_le ( Fintype.card K ) ) using 1;
      rw [ ← pow_succ, Nat.sub_add_cancel ( Nat.pos_of_ne_zero hn ) ];
    · exact pow_pos ( Fintype.card_pos ) _;
    · exact Fintype.card_pos_iff.mpr ⟨ 0 ⟩

end SchwartzZippel

end