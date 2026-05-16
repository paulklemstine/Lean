/-
# Schwartz–Zippel Lemma and Point-Hypersurface Incidence Bound

The multivariate Schwartz–Zippel lemma: a nonzero polynomial of total degree d
over a finite field K has at most d * |K|^(n-1) zeros in K^n.

As a corollary, we derive a point-hypersurface incidence bound.
-/
import Mathlib
import EML.PolynomialMethod.MultivariateVanishing

open MvPolynomial Polynomial Finset

noncomputable section

set_option maxHeartbeats 800000 in
/-
**Schwartz–Zippel lemma over finite fields.**
A nonzero multivariate polynomial of total degree `d` over a finite field `K`
vanishes on at most `d * |K|^(n-1)` points of `K^n`.

Proved by induction on `n` using `finSuccEquiv` to decompose the polynomial.
-/
theorem mvpolynomial_zero_set_card_le_totalDegree_mul_pow
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K) (hf : f ≠ 0) :
    (Finset.univ.filter (fun x : Fin n → K => MvPolynomial.eval x f = 0)).card
      ≤ f.totalDegree * (Fintype.card K) ^ (n - 1) := by
  rcases n with ( _ | n );
  · rw [ MvPolynomial.eq_C_of_isEmpty f ] at hf ⊢;
    aesop;
  · revert f;
    induction' n with n ih;
    · intro f hf
      have h_roots : (Finset.filter (fun x : Fin 1 → K => (MvPolynomial.eval x) f = 0) Finset.univ).card ≤ (Polynomial.roots (MvPolynomial.eval₂ Polynomial.C (fun _ => Polynomial.X) f)).toFinset.card := by
        refine' le_of_eq _;
        refine' Finset.card_bij ( fun x hx => x 0 ) _ _ _ <;> simp_all +decide [ MvPolynomial.eval₂_eq' ];
        · intro a ha
          have h_eval : (MvPolynomial.eval a) f = Polynomial.eval (a 0) (∑ x ∈ f.support, Polynomial.C (MvPolynomial.coeff x f) * Polynomial.X ^ x 0) := by
            simp +decide [ MvPolynomial.eval_eq', Polynomial.eval_finset_sum ]
          simp_all +decide [ MvPolynomial.eval_eq' ];
          contrapose! hf;
          ext x; replace hf := congr_arg ( fun p => p.coeff ( x 0 ) ) hf; simp_all +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow ] ;
          rw [ Finset.sum_eq_single x ] at hf <;> simp_all +decide [ Fin.eq_zero ];
          intro b hb hb'; intro h; simp_all +decide [ Finsupp.ext_iff, Fin.forall_fin_succ ] ;
        · exact fun a₁ ha₁ a₂ ha₂ h => by ext i; fin_cases i; exact h;
        · intro b hb hb'; use fun _ => b; simp_all +decide [ Polynomial.eval_finset_sum, MvPolynomial.eval_eq' ] ;
      refine' le_trans h_roots ( le_trans ( Multiset.toFinset_card_le _ ) ( le_trans ( Polynomial.card_roots' _ ) _ ) );
      simp +decide [ MvPolynomial.eval₂_eq' ];
      refine' le_trans ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_le _ );
      intro b hb; by_cases h : f.coeff b = 0 <;> simp_all +decide [ Polynomial.natDegree_C_mul_X_pow ] ;
      exact Finset.le_sup ( f := fun s => Finsupp.sum s fun x e => e ) ( Finsupp.mem_support_iff.mpr h ) |> le_trans ( by simp +decide [ Finsupp.sum_fintype ] );
    · intro f hf_ne_zero
      set p := (MvPolynomial.finSuccEquiv K (n + 1)) f with hp
      have hp_ne_zero : p ≠ 0 := by
        exact fun h => hf_ne_zero <| by simpa [ hp ] using congr_arg ( MvPolynomial.finSuccEquiv K ( n + 1 ) ).symm h;
      have h_deg : p.natDegree ≤ f.totalDegree := by
        have h_deg : p.natDegree ≤ f.degreeOf 0 := by
          have h_deg : p.natDegree = f.degreeOf 0 := by
            convert MvPolynomial.degree_finSuccEquiv hf_ne_zero using 1;
            rw [ Polynomial.degree_eq_natDegree ] <;> aesop
          rw [h_deg];
        exact le_trans h_deg ( MvPolynomial.degreeOf_le_totalDegree _ _ )
      have h_leading_coeff : (p.leadingCoeff).totalDegree ≤ f.totalDegree - p.natDegree := by
        have h_leading_coeff : ∀ m ∈ p.support, m ≤ f.totalDegree → (p.coeff m).totalDegree ≤ f.totalDegree - m := by
          intro m hm hm_le
          have h_coeff : ∀ c ∈ (p.coeff m).support, c.sum (fun i j => j) ≤ f.totalDegree - m := by
            intro c hc
            have h_coeff : (Finsupp.cons m c).sum (fun i j => j) ≤ f.totalDegree := by
              have h_coeff : (Finsupp.cons m c) ∈ f.support := by
                exact?;
              exact Finset.le_sup ( f := fun s => s.sum fun i j => j ) h_coeff;
            simp_all +decide [ Finsupp.sum_fintype ];
            simp_all +decide [ Fin.sum_univ_succ, Finsupp.cons ];
            exact le_tsub_of_add_le_left h_coeff;
          exact Finset.sup_le fun c hc => h_coeff c hc;
        exact h_leading_coeff _ ( Polynomial.natDegree_mem_support_of_nonzero hp_ne_zero ) h_deg
      have h_eval : ∀ x : Fin (n + 2) → K, (MvPolynomial.eval x f) = (Polynomial.eval (x 0) (Polynomial.map (MvPolynomial.eval (fun i => x (Fin.succ i))) p)) := by
        intro x
        simp [hp, MvPolynomial.eval_eq'];
        simp +decide [ Polynomial.map_sum, Polynomial.map_mul, Polynomial.map_pow, Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X, Polynomial.eval_one, MvPolynomial.finSuccEquiv_apply, MvPolynomial.eval_eq' ];
        simp +decide [ Polynomial.map_sum, Polynomial.map_mul, Polynomial.map_pow, Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X, Polynomial.eval_one, MvPolynomial.eval₂_eq' ];
        simp +decide [ Polynomial.map_prod, Polynomial.eval_prod, Fin.prod_univ_succ ]
      have h_card : (Finset.filter (fun x : Fin (n + 2) → K => (MvPolynomial.eval x f) = 0) Finset.univ).card ≤ (Finset.filter (fun a : Fin (n + 1) → K => (MvPolynomial.eval a (p.leadingCoeff)) = 0) Finset.univ).card * Fintype.card K + (Fintype.card K) ^ (n + 1) * p.natDegree := by
        have h_card : ∀ a : Fin (n + 1) → K, (Finset.filter (fun x : K => (Polynomial.eval x (Polynomial.map (MvPolynomial.eval a) p)) = 0) Finset.univ).card ≤ if (MvPolynomial.eval a (p.leadingCoeff)) = 0 then Fintype.card K else p.natDegree := by
          intro a
          by_cases h_leading_coeff_zero : (MvPolynomial.eval a (p.leadingCoeff)) = 0;
          · grind;
          · have h_card : (Finset.filter (fun x : K => (Polynomial.eval x (Polynomial.map (MvPolynomial.eval a) p)) = 0) Finset.univ).card ≤ (Polynomial.map (MvPolynomial.eval a) p).natDegree := by
              have h_card : (Finset.filter (fun x : K => (Polynomial.eval x (Polynomial.map (MvPolynomial.eval a) p)) = 0) Finset.univ).card ≤ (Polynomial.map (MvPolynomial.eval a) p).roots.toFinset.card := by
                refine' Finset.card_le_card _;
                simp +decide [ Finset.subset_iff ];
                exact fun x hx => ⟨ fun h => h_leading_coeff_zero <| by simpa [ Polynomial.leadingCoeff_map_of_leadingCoeff_ne_zero, h_leading_coeff_zero ] using congr_arg ( fun q => Polynomial.coeff q ( Polynomial.natDegree p ) ) h, hx ⟩;
              exact h_card.trans ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) );
            rw [ Polynomial.natDegree_map_of_leadingCoeff_ne_zero ] at h_card <;> aesop ( simp_config := { singlePass := true } ) ;
        have h_card : (Finset.filter (fun x : Fin (n + 2) → K => (MvPolynomial.eval x f) = 0) Finset.univ).card = Finset.sum Finset.univ (fun a : Fin (n + 1) → K => (Finset.filter (fun x : K => (Polynomial.eval x (Polynomial.map (MvPolynomial.eval a) p)) = 0) Finset.univ).card) := by
          simp +decide only [card_filter];
          rw [ ← Finset.sum_product' ];
          refine' Finset.sum_bij ( fun x _ => ( fun i => x i.succ, x 0 ) ) _ _ _ _ <;> simp +decide [ h_eval ];
          · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
          · exact fun a b => ⟨ Fin.cons b a, rfl, rfl ⟩;
        refine' le_trans ( h_card.le.trans ( Finset.sum_le_sum fun a _ => ‹∀ a : Fin ( n + 1 ) → K, Finset.card { x : K | Polynomial.eval x ( Polynomial.map ( MvPolynomial.eval a ) p ) = 0 } ≤ if MvPolynomial.eval a p.leadingCoeff = 0 then Fintype.card K else p.natDegree› a ) ) _;
        simp +decide [ Finset.sum_ite ];
        exact Nat.mul_le_mul_right _ ( le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ Finset.card_univ ] ) )
      have h_ind : (Finset.filter (fun a : Fin (n + 1) → K => (MvPolynomial.eval a (p.leadingCoeff)) = 0) Finset.univ).card ≤ (p.leadingCoeff).totalDegree * Fintype.card K ^ n := by
        by_cases h : p.leadingCoeff = 0 <;> aesop
      have h_final : (Finset.filter (fun x : Fin (n + 2) → K => (MvPolynomial.eval x f) = 0) Finset.univ).card ≤ f.totalDegree * Fintype.card K ^ (n + 1) := by
        refine le_trans h_card ?_;
        rw [ show Fintype.card K ^ ( n + 1 ) = Fintype.card K ^ n * Fintype.card K by ring ];
        nlinarith [ Nat.sub_add_cancel h_deg, show 0 < Fintype.card K ^ n * Fintype.card K by exact mul_pos ( pow_pos ( Fintype.card_pos ) _ ) ( Fintype.card_pos ) ]
      exact h_final

/-
**Point-hypersurface incidence bound.**
For any subset `S ⊆ K^n` and nonzero polynomial `f`, the number of points in `S`
on the zero set of `f` is bounded by the minimum of `|S|` and `d * |K|^(n-1)`.
-/
theorem point_hypersurface_incidence_bound
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K) (hf : f ≠ 0)
    (S : Finset (Fin n → K)) :
    (S.filter (fun x => MvPolynomial.eval x f = 0)).card
      ≤ min S.card (f.totalDegree * (Fintype.card K) ^ (n - 1)) := by
  exact le_min ( Finset.card_filter_le _ _ ) ( le_trans ( Finset.card_le_card ( Finset.filter_subset_filter _ ( Finset.subset_univ _ ) ) ) ( mvpolynomial_zero_set_card_le_totalDegree_mul_pow f hf ) )

end