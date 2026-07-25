/-
# Dvir's Finite-Field Kakeya Theorem

The conceptual core of Dvir's polynomial-method proof of the finite-field Kakeya
conjecture: no nonzero polynomial of degree less than |K| can vanish on a Kakeya set.

This turns the Kakeya problem from a geometric covering statement into an
algebraic rigidity principle.
-/
import Mathlib
import EML.PolynomialMethod.UnivariateVanishing
import EML.PolynomialMethod.MultivariateVanishing
import EML.PolynomialMethod.LineRestriction

open MvPolynomial Polynomial Finset

noncomputable section

/-- A **Kakeya set** in `K^n` is a set that contains an affine line in every direction:
for every nonzero direction vector `v`, there exists a point `x` such that the
entire affine line `{x + t • v | t ∈ K}` lies in the set. -/
def IsKakeyaSet
    {K : Type*} [Field K]
    {n : ℕ}
    (E : Set (Fin n → K)) : Prop :=
  ∀ v : Fin n → K, v ≠ 0 →
    ∃ x : Fin n → K, ∀ t : K, x + t • v ∈ E

/-
The top homogeneous component of a nonzero polynomial is nonzero.
-/
theorem homogeneousComponent_totalDegree_ne_zero
    {K : Type*} [CommSemiring K]
    {σ : Type*}
    (f : MvPolynomial σ K)
    (hf : f ≠ 0) :
    homogeneousComponent f.totalDegree f ≠ 0 := by
  simp_all +decide [ MvPolynomial.ext_iff ];
  obtain ⟨d, hd⟩ : ∃ d ∈ f.support, d.sum (fun _ e => e) = f.totalDegree := by
    have h_deg : ∃ d ∈ f.support, ∀ e ∈ f.support, e.sum (fun _ e => e) ≤ d.sum (fun _ e => e) := by
      exact Finset.exists_max_image _ _ ⟨ hf.choose, Finsupp.mem_support_iff.mpr hf.choose_spec ⟩;
    exact ⟨ h_deg.choose, h_deg.choose_spec.1, le_antisymm ( Finset.le_sup ( f := fun d => d.sum fun x e => e ) h_deg.choose_spec.1 ) ( Finset.sup_le fun e he => h_deg.choose_spec.2 e he ) ⟩;
  simp_all +decide [ MvPolynomial.coeff_homogeneousComponent ];
  exact ⟨ d, hd.2, hd.1 ⟩

/-
Evaluating a homogeneous polynomial of positive degree at zero gives zero.
-/
theorem eval_zero_of_isHomogeneous_pos
    {K : Type*} [CommSemiring K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (d : ℕ) (hd : 0 < d)
    (hf : f.IsHomogeneous d) :
    MvPolynomial.eval 0 f = 0 := by
  simp +decide [ MvPolynomial.eval_eq' ];
  rw [ MvPolynomial.constantCoeff_eq, hf.coeff_eq_zero ] ; aesop

/-
The coefficient of `T^d` in the affine-line restriction of `f` at `(x, v)`
equals the evaluation of the degree-`d` homogeneous component of `f` at `v`,
multiplied by the appropriate scalar from `x`. More precisely, if `d ≤ totalDegree f`,
the leading-degree coefficient captures only the top homogeneous part.
-/
theorem coeff_top_restrictAffineLine
    {K : Type*} [CommRing K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (x v : Fin n → K) :
    (restrictAffineLine f x v).coeff f.totalDegree
      = MvPolynomial.eval v (homogeneousComponent f.totalDegree f) := by
  -- Write $f$ as a sum over monomials.
  have h_sum_monomials : f = ∑ d ∈ f.support, MvPolynomial.monomial d (MvPolynomial.coeff d f) := by
    conv_lhs => rw [ f.as_sum ] ;
  -- By linearity of polynomial evaluation and restriction, we can break down the problem into evaluating each monomial separately.
  have h_monomial : ∀ d ∈ f.support, (MvPolynomial.aeval (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) (MvPolynomial.monomial d (MvPolynomial.coeff d f))).coeff f.totalDegree = if d.sum (fun i di => di) = f.totalDegree then MvPolynomial.eval v (MvPolynomial.monomial d (MvPolynomial.coeff d f)) else 0 := by
    intro d hd
    have h_monomial_eval : (MvPolynomial.aeval (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) (MvPolynomial.monomial d (MvPolynomial.coeff d f))) = Polynomial.C (MvPolynomial.coeff d f) * ∏ i, (Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) ^ d i := by
      simp +decide [ MvPolynomial.aeval_monomial ];
    -- The coefficient of $T^d$ in $\prod_{i} (C(x_i) + C(v_i)T)^{d_i}$ is $\prod_{i} v_i^{d_i}$ if $d = \sum_{i} d_i$, and zero otherwise.
    have h_coeff_prod : ∀ (ds : Fin n → ℕ), (Polynomial.coeff (∏ i, (Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) ^ ds i) (∑ i, ds i)) = ∏ i, v i ^ ds i := by
      intro ds
      have h_coeff_prod : ∀ (i : Fin n), (Polynomial.coeff ((Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) ^ ds i) (ds i)) = v i ^ ds i := by
        intro i;
        rw [ add_comm, add_pow ];
        simp +decide [ mul_pow, Polynomial.coeff_C, Polynomial.coeff_X_pow ];
        rw [ Finset.sum_eq_single ( ds i ) ] <;> simp +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow, mul_assoc, pow_add ];
        · rw [ Polynomial.coeff_mul, Finset.sum_eq_single ( 0, ds i ) ] <;> simp +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow ];
          · simp +decide [ Polynomial.coeff_zero_eq_eval_zero ];
          · grind;
        · intro b hb hb'; rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ] <;> norm_num;
          refine' lt_of_le_of_lt ( Polynomial.natDegree_mul_le .. ) _;
          refine' lt_of_le_of_lt ( add_le_add ( Polynomial.natDegree_pow_le ) ( Polynomial.natDegree_mul_le .. ) ) _ ; norm_num;
          refine' lt_of_le_of_lt ( add_le_add ( Polynomial.natDegree_X_pow_le _ ) ( Polynomial.natDegree_pow_le ) ) _ ; norm_num;
          exact lt_of_le_of_ne hb hb';
      rw [ Finset.prod_congr rfl fun i _ => show ( Polynomial.C ( x i ) + Polynomial.C ( v i ) * Polynomial.X ) ^ ds i = ∑ j ∈ Finset.range ( ds i + 1 ), Polynomial.monomial j ( Polynomial.coeff ( ( Polynomial.C ( x i ) + Polynomial.C ( v i ) * Polynomial.X ) ^ ds i ) j ) from ?_, Finset.prod_sum ];
      · rw [ Polynomial.finset_sum_coeff, Finset.sum_eq_single ( fun i _ => ds i ) ] <;> simp +decide [ Polynomial.coeff_monomial, h_coeff_prod ];
        · rw [ Finset.prod_congr rfl fun _ _ => by rw [ ← Polynomial.C_mul_X_pow_eq_monomial ] ];
          rw [ Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum ];
          rw [ Polynomial.coeff_mul, Finset.sum_eq_single ( 0, ∑ i, ds i ) ] <;> simp +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow ];
          · simp +decide [ Polynomial.coeff_zero_eq_eval_zero, Polynomial.eval_prod ];
          · exact fun a b hab ha hb => False.elim <| ha ( by linarith ) ( by linarith );
        · intro b hb hb';
          rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
          refine' lt_of_le_of_lt ( Polynomial.natDegree_prod_le _ _ ) _;
          refine' Finset.sum_lt_sum _ _;
          · exact fun i _ => le_trans ( Polynomial.natDegree_monomial_le _ ) ( hb i );
          · contrapose! hb';
            ext i; specialize hb' i; specialize hb i; simp +decide [ Polynomial.natDegree_monomial ] at hb' hb ⊢;
            exact le_antisymm hb ( hb'.trans ( Polynomial.natDegree_monomial_le _ ) );
      · conv_lhs => rw [ ← Polynomial.sum_monomial_eq ( ( Polynomial.C ( x i ) + Polynomial.C ( v i ) * Polynomial.X ) ^ ds i ) ] ;
        rw [ Polynomial.sum_over_range' ] <;> norm_num;
        refine' le_trans ( Polynomial.natDegree_pow_le ) _;
        by_cases hi : v i = 0 <;> simp +decide [ hi, Polynomial.natDegree_add_eq_right_of_natDegree_lt ];
    split_ifs with h;
    · simp +decide [ ← h, h_monomial_eval, h_coeff_prod, MvPolynomial.eval_monomial ];
      simp +decide [ Finsupp.sum_fintype, h_coeff_prod ];
    · rw [ h_monomial_eval, Polynomial.coeff_C_mul, Polynomial.coeff_eq_zero_of_natDegree_lt ];
      · ring;
      · refine' lt_of_le_of_lt _ ( lt_of_le_of_ne _ h );
        · refine' le_trans ( Polynomial.natDegree_prod_le _ _ ) _;
          refine' le_trans ( Finset.sum_le_sum fun i _ => Polynomial.natDegree_pow_le ) _;
          simp +decide [ Finsupp.sum_fintype ];
          exact Finset.sum_le_sum fun i _ => mul_le_of_le_one_right ( Nat.zero_le _ ) ( by by_cases hi : v i = 0 <;> simp +decide [ hi ] );
        · exact Finset.le_sup ( f := fun s => Finsupp.sum s fun i di => di ) hd;
  convert Finset.sum_congr rfl h_monomial using 1;
  · convert congr_arg ( fun p : Polynomial K => p.coeff f.totalDegree ) ( congr_arg ( MvPolynomial.aeval ( fun i => Polynomial.C ( x i ) + Polynomial.C ( v i ) * Polynomial.X ) ) h_sum_monomials ) using 1;
    conv_rhs => rw [ h_sum_monomials, map_sum ] ;
    rw [ ← h_sum_monomials, Polynomial.finset_sum_coeff ];
  · simp +decide [ homogeneousComponent_apply, MvPolynomial.eval_monomial ];
    rw [ Finset.sum_filter ];
    rfl

/-
**Dvir's theorem (core algebraic statement).**
No nonzero polynomial of total degree less than `|K|` can vanish on a Kakeya set
in `K^n` (for `n ≥ 1`).

This is the revolutionary insight that transforms Kakeya from a geometric covering
problem into a polynomial rigidity principle.
-/
theorem no_low_degree_polynomial_vanishing_on_kakeya
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n : ℕ} (hn : 0 < n)
    (E : Set (Fin n → K))
    (hE : IsKakeyaSet E)
    (f : MvPolynomial (Fin n) K)
    (hdeg : f.totalDegree < Fintype.card K)
    (hvanish : ∀ x ∈ E, MvPolynomial.eval x f = 0) :
    f = 0 := by
  -- Since `f` is assumed nonzero, its homogeneous component of degree `f.totalDegree`, denoted `g`, is also nonzero.
  by_cases hf : f = 0;
  · exact hf;
  · -- For each $v \neq 0$, by IsKakeyaSet, there exists $x₀$ such that $∀ t : K, x₀ + t • v ∈ E$.
    -- So $f$ vanishes at all points of this line: $∀ t, \text{eval}(x₀ + t • v) f = 0$.
    have h_eval_zero : ∀ v : Fin n → K, v ≠ 0 → MvPolynomial.eval v (homogeneousComponent f.totalDegree f) = 0 := by
      intro v hv_ne;
      obtain ⟨ x₀, hx₀ ⟩ := hE v hv_ne;
      -- By the properties of the restriction, we know that the restriction of `f` to the line `x₀ + t • v` is the zero polynomial.
      have h_restrict_zero : restrictAffineLine f x₀ v = 0 := by
        refine' polynomial_eq_zero_of_eval_eq_zero_all _ _ _;
        · exact lt_of_le_of_lt ( natDegree_restrictAffineLine_le_totalDegree f x₀ v ) hdeg;
        · exact fun t => eval_restrictAffineLine' f x₀ v t ▸ hvanish _ ( hx₀ t );
      rw [ ← coeff_top_restrictAffineLine ];
      rw [ h_restrict_zero, Polynomial.coeff_zero ];
    -- If $d > 0$: by eval_zero_of_isHomogeneous_pos (using homogeneousComponent_isHomogeneous), eval $0 (homogeneousComponent d f) = 0$.
    have h_eval_zero_zero : MvPolynomial.eval 0 (homogeneousComponent f.totalDegree f) = 0 := by
      by_cases hd : f.totalDegree = 0;
      · -- Since $f$ is a constant polynomial, we can write it as $f = c$ for some $c \in K$.
        obtain ⟨c, hc⟩ : ∃ c : K, f = MvPolynomial.C c := by
          grind +suggestions;
        obtain ⟨ x, hx ⟩ := hE ( fun _ => 1 ) ( ne_of_apply_ne ( fun x => x ⟨ 0, hn ⟩ ) one_ne_zero );
        specialize hvanish _ ( hx 0 ) ; aesop;
      · exact eval_zero_of_isHomogeneous_pos _ _ ( Nat.pos_of_ne_zero hd ) ( MvPolynomial.homogeneousComponent_isHomogeneous _ _ );
    -- By mvpolynomial_eq_zero_of_eval_eq_zero (totalDegree of homogeneousComponent d f ≤ d < |K|, using IsHomogeneous.totalDegree or the fact that it's homogeneous of degree d), homogeneousComponent d f = 0.
    have h_homogeneous_zero : homogeneousComponent f.totalDegree f = 0 := by
      apply mvpolynomial_eq_zero_of_eval_eq_zero;
      · refine' lt_of_le_of_lt _ hdeg;
        simp +decide [ MvPolynomial.totalDegree ];
        simp +decide [ homogeneousComponent_apply ];
        simp +contextual [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ];
        exact fun b hb hb' => Finset.le_sup ( f := fun s => s.sum fun x e => e ) ( Finsupp.mem_support_iff.mpr hb );
      · exact fun x => if hx : x = 0 then hx.symm ▸ h_eval_zero_zero else h_eval_zero x hx;
    exact False.elim ( homogeneousComponent_totalDegree_ne_zero f hf h_homogeneous_zero )

end