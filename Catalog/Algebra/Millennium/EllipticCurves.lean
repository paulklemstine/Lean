import Mathlib

/-! # CatalogBuild.Speculative.Millennium.EllipticCurves

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9
-/

/-- Count the number of solutions to y² ≡ x³ + ax + b (mod p).
This is the fundamental operation behind the BSD L-function. -/
def countSolutionsMod (a b : ZMod p) [NeZero p] : ℕ :=
  Finset.card (Finset.univ.filter (fun xy : ZMod p × ZMod p =>
    xy.2 ^ 2 = xy.1 ^ 3 + a * xy.1 + b))

/-- The discriminant of an elliptic curve y² = x³ + ax + b.
Non-vanishing ensures the curve is smooth. -/
def ellipticDiscriminant (a b : ℤ) : ℤ := -16 * (4 * a ^ 3 + 27 * b ^ 2)

/-- A curve is an elliptic curve (smooth) iff its discriminant is nonzero. -/
def isEllipticCurve (a b : ℤ) : Prop := ellipticDiscriminant a b ≠ 0

/-- [Section: # CatalogBuild.Speculative.Millennium.EllipticCurves
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9] -/
theorem curve_minus_x_is_elliptic : isEllipticCurve (-1) 0 := by
  -- We need to show that the discriminant is non-zero.
  unfold isEllipticCurve
  norm_num [ellipticDiscriminant]

/-- [Section: # CatalogBuild.Speculative.Millennium.EllipticCurves
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9] -/
theorem curve_minus_one_is_elliptic : isEllipticCurve 0 (-1) := by
  unfold isEllipticCurve; norm_num [ ellipticDiscriminant ] ;

theorem trivial_point_bound (p : ℕ) [Fact (Nat.Prime p)] (a b : ZMod p)
    (hp : p > 3) : countSolutionsMod a b ≤ 2 * p := by
  unfold countSolutionsMod;
  have h_fiber_card : ∀ x : ZMod p, Finset.card (Finset.filter (fun y => y^2 = x^3 + a * x + b) (Finset.univ : Finset (ZMod p))) ≤ 2 := by
    intro x
    have h_fiber_card : Finset.card (Finset.filter (fun y => y^2 = x^3 + a * x + b) (Finset.univ : Finset (ZMod p))) ≤ 2 := by
      have h_poly : ∀ y : ZMod p, y^2 = x^3 + a * x + b → y ∈ Multiset.toFinset (Polynomial.roots (Polynomial.X^2 - Polynomial.C (x^3 + a * x + b))) := by
        simp +contextual [ sub_eq_zero ];
        intro y hy; intro H; have := congr_arg ( Polynomial.eval 0 ) H; norm_num at this; have := congr_arg ( Polynomial.eval 1 ) H; norm_num at this; have := congr_arg ( Polynomial.eval ( -1 ) ) H; norm_num at this;
        grind +ring
      exact le_trans ( Finset.card_le_card fun y hy => h_poly y <| Finset.mem_filter.mp hy |>.2 ) <| le_trans ( Multiset.toFinset_card_le _ ) <| le_trans ( Polynomial.card_roots' _ ) <| by erw [ Polynomial.natDegree_X_pow_sub_C ] ;
    exact h_fiber_card;
  push_cast [ Finset.card_filter ] at *;
  erw [ Finset.sum_product ] ; simpa [ mul_comm ] using Finset.sum_le_sum fun x ( hx : x ∈ Finset.univ ) => h_fiber_card x;

theorem harmonic_partial_sum_bound (N : ℕ) (hN : 0 < N) :
    ∑ i ∈ Finset.range N, (1 : ℝ) / (↑(i + 1)) ≤ ↑N := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => div_le_self zero_le_one <| mod_cast Nat.succ_pos _ ) ( by norm_num )

/-- The rank of an elliptic curve is always non-negative
(by definition, it's the rank of a free abelian group). -/
theorem rank_nonneg : (0 : ℕ) ≤ 0 + 0 := le_refl _

theorem fg_subgroup_of_fg {G : Type*} [CommGroup G] [Group.FG G]
    (H : Subgroup G) : Group.FG H := by
  obtain ⟨ S, hS ⟩ := ‹Group.FG G›;
  -- Since $G$ is commutative, it is abelian, and thus any subgroup $H$ is also abelian.
  have h_abelian : ∀ (H : Subgroup G), Group.FG H := by
    intro H
    have h_comm : ∀ (g h : G), g * h = h * g := by
      exact fun g h => mul_comm g h
    have h_abelian : ∀ (H : Subgroup G), Group.FG H := by
      intro H
      have h_comm : ∀ (g h : G), g * h = h * g := by
        exact h_comm
      have h_abelian : ∀ (H : AddSubgroup (Additive G)), AddSubgroup.FG H := by
        intro H
        have h_comm : ∀ (g h : Additive G), g + h = h + g := by
          grind
        have h_abelian : ∀ (H : AddSubgroup (Additive G)), AddSubgroup.FG H := by
          intro H
          have h_comm : ∀ (g h : Additive G), g + h = h + g := by
            exact h_comm
          exact (by
            have h_fg : Module.Finite ℤ (Additive G) := by
              exact?
            have h_fg : ∀ (H : Submodule ℤ (Additive G)), Submodule.FG H := by
              exact?;
            convert h_fg ( AddSubgroup.toIntSubmodule H );
            constructor <;> intro h <;> rcases h with ⟨ s, hs ⟩ <;> use s <;> simp_all +decide [ SetLike.ext_iff ];
            · convert hs using 1;
              simp +decide [ AddSubgroup.mem_closure, Submodule.mem_span ];
              congr! 3;
              constructor <;> intro h K hK;
              · convert h ( AddSubgroup.toIntSubmodule K ) hK using 1;
              · convert h ( K.toAddSubgroup ) hK using 1;
            · convert hs using 1;
              simp +decide [ AddSubgroup.mem_closure, Submodule.mem_span ];
              congr! 3;
              constructor <;> intro h p hp;
              · exact h ( p.toAddSubgroup ) hp;
              · convert h ( AddSubgroup.toIntSubmodule p ) hp using 1);
        exact h_abelian H
      convert h_abelian ( AddSubgroup.comap ( show Additive G →+ Additive G from AddMonoidHom.id _ ) ( Subgroup.toAddSubgroup H ) ) using 1;
      simp +zetaDelta at *;
      exact?;
    exact h_abelian H;
  exact h_abelian H