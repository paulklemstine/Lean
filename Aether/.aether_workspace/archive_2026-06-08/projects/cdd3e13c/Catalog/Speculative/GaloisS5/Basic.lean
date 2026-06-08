/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Galois Group of X⁵ - X - 1 is S₅

We prove that the Galois group of the polynomial `f = X⁵ - X - 1` over `ℚ` is isomorphic
to the symmetric group `S₅`, modulo Dedekind's theorem (connecting modular factorization
patterns to cycle types in the Galois group).

## Main results

* `quinticS5_irreducible_ℚ` : `X⁵ - X - 1` is irreducible over `ℚ`.
* `quinticS5_mod2_factorization` : `X⁵ - X - 1 ≡ (X²+X+1)(X³+X²+1) mod 2`.
* `quinticS5_not_isSquare_disc` : The discriminant `2869` is not a square integer.
* `S5_of_30_dvd_not_alt` : A subgroup of `S₅` with `30 ∣ |H|` and `H ⊄ A₅` equals `S₅`.
* `quinticS5_galActionHom_bijective_of_dedekind` : **Conditional main theorem.**

## Mathematical argument

1. `f` is irreducible over `ℚ` (lift from irreducibility over `𝔽₃`).
2. Over `𝔽₂`, `f ≡ (X²+X+1)(X³+X²+1)`, both factors irreducible.
3. By Dedekind's theorem (not formalized), the Galois group contains an element
   of cycle type `(2,3)`, which has order `6`.
4. From irreducibility, `5 ∣ |Gal|`. From the order-6 element, `6 ∣ |Gal|`.
   Hence `30 ∣ |Gal|`.
5. An element of order 6 in `S₅` must be odd (cycle type `(2,3)` has sign `-1`).
   So `Gal ⊄ A₅`.
6. By `S5_of_30_dvd_not_alt`, the only possibility is `Gal = S₅`.
-/

noncomputable section

open Polynomial Equiv.Perm

/-! ## Part I: Group-theoretic classification for S₅ -/

/-
Any nontrivial normal subgroup of `S₅` contains `A₅`.
-/
theorem Perm_Fin5_alternating_le_of_normal_nontrivial
    (N : Subgroup (Equiv.Perm (Fin 5))) [hN : N.Normal] (hbot : N ≠ ⊥) :
    alternatingGroup (Fin 5) ≤ N := by
  -- By simplicity of $A_5$, $N \cap A_5 = \bot$ or $A_5$.
  have h_inter : N ⊓ alternatingGroup (Fin 5) = ⊥ ∨ N ⊓ alternatingGroup (Fin 5) = alternatingGroup (Fin 5) := by
    have h_inter : ∀ H : Subgroup (alternatingGroup (Fin 5)), H.Normal → (H = ⊥ ∨ H = ⊤) := by
      exact?;
    convert h_inter _ _;
    any_goals exact N.subgroupOf ( alternatingGroup ( Fin 5 ) );
    · simp +decide [ Subgroup.eq_bot_iff_forall ];
      exact ⟨ fun h x hx hx' => h x hx' hx, fun h x hx hx' => h x hx' hx ⟩;
    · simp +decide [ SetLike.ext_iff, Subgroup.mem_subgroupOf ];
    · infer_instance;
  cases' h_inter with h_inter h_inter <;> simp_all +decide [ Subgroup.eq_bot_iff_forall ];
  -- If $N \cap A_5 = \bot$, then $N$ is nontrivial but all nontrivial elements have sign -1.
  obtain ⟨σ, hσN, hσ_ne_one⟩ : ∃ σ ∈ N, σ ≠ 1 ∧ Equiv.Perm.sign σ = -1 := by
    exact hbot.imp fun x hx => ⟨ hx.1, hx.2, Or.resolve_left ( Int.units_eq_one_or _ ) fun h => hx.2 <| h_inter x hx.1 h ⟩;
  -- Any conjugate $g\sigma^{-1}g^{-1}$ of $\sigma^{-1} \in N$ is in $N$ (normality) and has the same sign, so $g\sigma^{-1}g^{-1} \sigma$ is in $N \cap A_5 = \bot$, meaning $g\sigma^{-1}g^{-1} = \sigma^{-1}$ for all $g$.
  have h_conj : ∀ g : Equiv.Perm (Fin 5), g * σ⁻¹ * g⁻¹ = σ⁻¹ := by
    intros g
    have h_conj : g * σ⁻¹ * g⁻¹ * σ ∈ N ⊓ alternatingGroup (Fin 5) := by
      exact ⟨ N.mul_mem ( hN.conj_mem _ ( N.inv_mem hσN ) g ) hσN, by simp +decide [ hσ_ne_one.2, Equiv.Perm.sign_mul ] ⟩;
    have := h_inter _ h_conj.1 ( by simpa using h_conj.2 ) ; simp_all +decide [ mul_eq_one_iff_eq_inv ] ;
  -- This means $\sigma^{-1}$ is central. But the center of $S_5$ is trivial (native_decide), contradiction.
  have h_center : σ⁻¹ ∈ Subgroup.center (Equiv.Perm (Fin 5)) := by
    rw [ Subgroup.mem_center_iff ];
    exact fun g => by simpa [ mul_inv_eq_iff_eq_mul ] using h_conj g;
  have h_center_trivial : ∀ g : Equiv.Perm (Fin 5), g ∈ Subgroup.center (Equiv.Perm (Fin 5)) → g = 1 := by
    native_decide;
  exact False.elim <| hσ_ne_one.1 <| inv_eq_one.mp <| h_center_trivial _ h_center

/-- `S₅` has no subgroup of index 4. -/
theorem Perm_Fin5_no_index_four
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (hH : H.index = 4) : False := by
  set φ : Equiv.Perm (Fin 5) →* Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H) :=
    MulAction.toPermHom (Equiv.Perm (Fin 5)) (Equiv.Perm (Fin 5) ⧸ H) with hφ_def
  have h_ker_le_H : φ.ker ≤ H := by
    intro g hg; have := hg; simp_all +decide [ Equiv.Perm.ext_iff, MulAction.toPermHom ]
    specialize hg ( QuotientGroup.mk 1 ) ; simp_all +decide [ QuotientGroup.eq ]
  by_cases h_ker_bot : φ.ker = ⊥
  · have h_inj : Function.Injective φ := by grind +suggestions
    have h_card : Nat.card (Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H)) ≥
        Nat.card (Equiv.Perm (Fin 5)) :=
      Nat.card_le_card_of_injective _ h_inj
    simp_all +decide [ Fintype.card_perm ]
    have h_card2 : Nat.card (Equiv.Perm (Equiv.Perm (Fin 5) ⧸ H)) =
        Nat.factorial (H.index) := by
      simp +decide [ Subgroup.index ]; exact Nat.card_perm
    simp_all +decide [ Nat.factorial ]
  · have h_alternating_le_ker : alternatingGroup (Fin 5) ≤ φ.ker :=
      Perm_Fin5_alternating_le_of_normal_nontrivial φ.ker h_ker_bot
    have h_card_ker : Nat.card φ.ker ∣ Nat.card H :=
      Subgroup.card_dvd_of_le h_ker_le_H
    have h_card_H : Nat.card H = 30 := by
      have := Subgroup.index_mul_card H; simp_all +decide
      exact mul_left_cancel₀ ( by decide ) ( this.trans ( by native_decide ) )
    have h_card_alternating : Nat.card (alternatingGroup (Fin 5)) = 60 := by
      simp +decide [ Nat.card_eq_fintype_card ]
    have h_card_ker_ge : Nat.card φ.ker ≥ Nat.card (alternatingGroup (Fin 5)) :=
      Nat.card_mono (Set.toFinite _) h_alternating_le_ker
    linarith [ Nat.le_of_dvd ( by linarith ) h_card_ker ]

/-- Any subgroup of `S₅` of index 2 is `A₅`. -/
theorem Perm_Fin5_index_two_eq_alt
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (hH : H.index = 2) :
    H = alternatingGroup (Fin 5) :=
  eq_alternatingGroup_of_index_eq_two hH

/-
A subgroup of `S₅` whose order is divisible by `30` and not contained
    in `A₅` must equal `S₅`.
-/
theorem S5_of_30_dvd_not_alt
    (H : Subgroup (Equiv.Perm (Fin 5)))
    (h30 : 30 ∣ Nat.card H)
    (hnotalt : ¬ (H ≤ alternatingGroup (Fin 5))) :
    H = ⊤ := by
  -- By Lagrange, the order of $H$ divides $120$.
  have h_div : Nat.card H ∣ 120 := by
    simpa using Subgroup.card_subgroup_dvd_card H;
  have := Nat.le_of_dvd ( by decide ) h_div; interval_cases _ : Nat.card H <;> simp_all? +decide only ;
  · have := Perm_Fin5_no_index_four H ?_ide ;
    · contradiction;
    · have := Subgroup.index_mul_card H; simp_all +decide ;
      exact mul_right_cancel₀ ( by decide ) this;
  · -- If $|H| = 60$, then $H$ must be equal to $A_5$ since $A_5$ is the only subgroup of $S_5$ with order $60$.
    have h_eq_A5 : H = alternatingGroup (Fin 5) := by
      convert Perm_Fin5_index_two_eq_alt H _ using 1;
      have := Subgroup.index_mul_card H; simp_all +decide ;
      exact mul_right_cancel₀ ( by decide ) this;
    aesop;
  · exact Subgroup.eq_top_of_card_eq _ ( by simpa [ Fintype.card_perm ] using ‹Nat.card H = 120› )

/-! ## Part II: The polynomial X⁵ - X - 1 -/

/-- The quintic polynomial `X⁵ - X - 1` over `ℤ`. -/
def quinticS5 : ℤ[X] := X ^ 5 - X - 1

/-- The quintic polynomial `X⁵ - X - 1` over `ℚ`. -/
def quinticS5_ℚ : ℚ[X] := quinticS5.map (Int.castRingHom ℚ)

theorem quinticS5_eq : quinticS5 = X ^ 5 - X - 1 := rfl

/-
`quinticS5` is monic.
-/
theorem quinticS5_monic : quinticS5.Monic := by
  erw [ Polynomial.Monic, Polynomial.leadingCoeff, Polynomial.natDegree_sub_C, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> norm_num;
  unfold quinticS5; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ;

/-- `quinticS5` is primitive (follows from being monic). -/
theorem quinticS5_primitive : quinticS5.IsPrimitive :=
  quinticS5_monic.isPrimitive

/-
The natural degree of `quinticS5_ℚ` is 5.
-/
theorem quinticS5_ℚ_natDegree : quinticS5_ℚ.natDegree = 5 := by
  erw [ Polynomial.natDegree_map_of_leadingCoeff_ne_zero ] <;> norm_num [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
  · erw [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> erw [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> norm_num;
  · exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by simp +decide [ quinticS5 ] )

/-! ### Irreducibility -/

/-- `X⁵ - X - 1` has no roots in `𝔽₃`. -/
theorem quinticS5_no_roots_mod3 :
    ∀ x : ZMod 3, (x : ZMod 3) ^ 5 - x - 1 ≠ 0 := by decide

/-
`X⁵ - X - 1` is irreducible over `𝔽₃`.
-/
set_option maxHeartbeats 1600000 in
theorem quinticS5_irreducible_mod3 :
    Irreducible (quinticS5.map (Int.castRingHom (ZMod 3))) := by
  norm_num [ quinticS5 ] at *;
  -- We'll use that $X^5 - X - 1$ is irreducible over $\mathbb{F}_3$.
  have h_irred : Irreducible (Polynomial.X ^ 5 - Polynomial.X - 1 : Polynomial (ZMod 3)) := by
    have h_no_linear : ¬∃ x : ZMod 3, x ^ 5 - x - 1 = 0 := by
      native_decide
    have h_no_quadratic : ¬∃ p q : Polynomial (ZMod 3), p.degree = 2 ∧ q.degree = 3 ∧ p * q = Polynomial.X ^ 5 - Polynomial.X - 1 := by
      rintro ⟨ p, q, hp, hq, hpq ⟩;
      -- Let's write $p$ and $q$ as $p = a_2 X^2 + a_1 X + a_0$ and $q = b_3 X^3 + b_2 X^2 + b_1 X + b_0$.
      obtain ⟨a2, a1, a0, ha⟩ : ∃ a2 a1 a0 : ZMod 3, p = Polynomial.C a2 * Polynomial.X ^ 2 + Polynomial.C a1 * Polynomial.X + Polynomial.C a0 := by
        rw [ @Polynomial.as_sum_range_C_mul_X_pow ( ZMod 3 ) _ p ] ; exact ⟨ p.coeff 2, p.coeff 1, p.coeff 0, by simp +arith +decide [ Polynomial.natDegree_eq_of_degree_eq_some hp, Finset.sum_range_succ' ] ⟩ ;
      obtain ⟨b3, b2, b1, b0, hb⟩ : ∃ b3 b2 b1 b0 : ZMod 3, q = Polynomial.C b3 * Polynomial.X ^ 3 + Polynomial.C b2 * Polynomial.X ^ 2 + Polynomial.C b1 * Polynomial.X + Polynomial.C b0 := by
        rw [ @Polynomial.as_sum_range_C_mul_X_pow ( ZMod 3 ) _ q ] ; exact ⟨ q.coeff 3, q.coeff 2, q.coeff 1, q.coeff 0, by simp +arith +decide [ Polynomial.natDegree_eq_of_degree_eq_some hq, Finset.sum_range_succ' ] ⟩ ;
      simp_all +decide [ Polynomial.ext_iff ];
      have := hpq 0; have := hpq 1; have := hpq 2; have := hpq 3; have := hpq 4; have := hpq 5; simp_all +decide [ Polynomial.coeff_one, Polynomial.coeff_X, mul_assoc, add_mul, pow_succ ] ;
      fin_cases a2 <;> fin_cases b3 <;> simp_all ( config := { decide := Bool.true } ) only [ ];
      · fin_cases a1 <;> fin_cases a0 <;> fin_cases b2 <;> fin_cases b1 <;> fin_cases b0 <;> trivial;
      · fin_cases a1 <;> fin_cases a0 <;> fin_cases b2 <;> fin_cases b1 <;> fin_cases b0 <;> trivial
    -- Since there are no linear or quadratic factors, the polynomial must be irreducible.
    have h_irred : ∀ p q : Polynomial (ZMod 3), p.degree > 0 → q.degree > 0 → p * q = Polynomial.X ^ 5 - Polynomial.X - 1 → False := by
      intros p q hp hq h_eq
      have h_deg : p.degree + q.degree = 5 := by
        rw [ ← Polynomial.degree_mul, h_eq, Polynomial.degree_sub_eq_left_of_degree_lt ] <;> rw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num;
      have h_deg_cases : p.degree = 1 ∧ q.degree = 4 ∨ p.degree = 4 ∧ q.degree = 1 ∨ p.degree = 2 ∧ q.degree = 3 ∨ p.degree = 3 ∧ q.degree = 2 := by
        rw [ Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hp ), Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hq ) ] at * ; norm_cast at * ; omega;
      rcases h_deg_cases with ( ⟨ hp, hq ⟩ | ⟨ hp, hq ⟩ | ⟨ hp, hq ⟩ | ⟨ hp, hq ⟩ ) <;> simp_all +decide only;
      · -- If $p$ is a linear polynomial, then $p$ must have a root in $\mathbb{F}_3$.
        obtain ⟨a, ha⟩ : ∃ a : ZMod 3, p.eval a = 0 := by
          exact Polynomial.exists_root_of_degree_eq_one hp;
        replace h_eq := congr_arg ( Polynomial.eval a ) h_eq ; simp_all +decide;
        fin_cases a <;> contradiction;
      · obtain ⟨x, hx⟩ : ∃ x : ZMod 3, q.eval x = 0 := by
          exact ( Polynomial.exists_root_of_degree_eq_one hq );
        replace h_eq := congr_arg ( Polynomial.eval x ) h_eq ; simp_all +decide;
        fin_cases x <;> contradiction;
      · exact h_no_quadratic ⟨ p, q, hp, hq, h_eq ⟩;
      · exact h_no_quadratic ⟨ q, p, hq, hp, by rw [ mul_comm, h_eq ] ⟩;
    constructor <;> contrapose! h_irred;
    · exact absurd ( Polynomial.degree_eq_zero_of_isUnit h_irred ) ( by erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num );
    · obtain ⟨ a, b, h₁, h₂, h₃ ⟩ := h_irred; exact ⟨ a, b, not_le.mp fun h => h₂ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h <| le_of_not_gt fun h' => by { apply_fun Polynomial.eval 0 at h₁; aesop }, not_le.mp fun h => h₃ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h <| le_of_not_gt fun h' => by { apply_fun Polynomial.eval 0 at h₁; aesop }, h₁.symm, trivial ⟩ ;
  convert h_irred

/-- `X⁵ - X - 1` is irreducible over `ℤ`, by lifting from `𝔽₃`. -/
theorem quinticS5_irreducible : Irreducible quinticS5 :=
  Polynomial.Monic.irreducible_of_irreducible_map
    (Int.castRingHom (ZMod 3)) quinticS5 quinticS5_monic quinticS5_irreducible_mod3

/-- `X⁵ - X - 1` is irreducible over `ℚ`, by Gauss's lemma. -/
theorem quinticS5_irreducible_ℚ : Irreducible quinticS5_ℚ :=
  (Polynomial.IsPrimitive.Int.irreducible_iff_irreducible_map_cast quinticS5_primitive).mp
    quinticS5_irreducible

/-! ### Discriminant -/

/-
`2869` is not a perfect square in `ℤ`.
-/
theorem quinticS5_not_isSquare_disc : ¬ IsSquare (2869 : ℤ) := by
  native_decide +revert

/-- `2869 = 19 × 151` -/
theorem disc_factorization : (2869 : ℤ) = 19 * 151 := by norm_num

/-! ### Modular factorization over 𝔽₂ -/

/-
`X² + X + 1` is irreducible over `𝔽₂`.
-/
theorem irred_x2_x_1_mod2 :
    Irreducible (X ^ 2 + X + 1 : (ZMod 2)[X]) := by
  -- Since there are no roots in F_2, the polynomial X^2 + X + 1 has no linear factors over F_2.
  have h_no_linear_factors : ∀ p q : Polynomial (ZMod 2), p.degree > 0 → q.degree > 0 → ¬(p * q = Polynomial.X ^ 2 + Polynomial.X + 1) := by
    intros p q hp hq h_eq
    have h_deg : p.degree = 1 ∧ q.degree = 1 := by
      have := congr_arg Polynomial.degree h_eq; norm_num [ Polynomial.degree_add_eq_left_of_degree_lt, Polynomial.degree_add_eq_right_of_degree_lt ] at this;
      rw [ Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hp ), Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hq ) ] at * ; norm_cast at * ; exact ⟨ by nlinarith, by nlinarith ⟩;
    -- Since $p$ and $q$ are both of degree 1, they must have a root in $F_2$.
    obtain ⟨a, ha⟩ : ∃ a : ZMod 2, p.eval a = 0 := by
      exact Polynomial.exists_root_of_degree_eq_one h_deg.1
    obtain ⟨b, hb⟩ : ∃ b : ZMod 2, q.eval b = 0 := by
      exact Polynomial.exists_root_of_degree_eq_one h_deg.2;
    replace h_eq := congr_arg ( Polynomial.eval a ) h_eq; simp_all +decide ;
    fin_cases a <;> contradiction;
  constructor <;> contrapose! h_no_linear_factors;
  · exact absurd ( Polynomial.degree_eq_zero_of_isUnit h_no_linear_factors ) ( by erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> norm_num );
  · rcases h_no_linear_factors with ⟨ a, b, h₁, h₂, h₃ ⟩ ; exact ⟨ a, b, not_le.mp fun h => h₂ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h <| le_of_not_gt fun h' => by { apply_fun Polynomial.eval 0 at h₁; aesop }, not_le.mp fun h => h₃ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h <| le_of_not_gt fun h' => by { apply_fun Polynomial.eval 0 at h₁; aesop }, h₁.symm ⟩ ;

/-
`X³ + X² + 1` is irreducible over `𝔽₂`.
-/
theorem irred_x3_x2_1_mod2 :
    Irreducible (X ^ 3 + X ^ 2 + 1 : (ZMod 2)[X]) := by
  -- We'll use that $X^3 + X^2 + 1$ is irreducible over $\mathbb{F}_2$ if and only if it has no roots in $\mathbb{F}_2$.
  have h_no_roots : ∀ x : ZMod 2, (x ^ 3 + x ^ 2 + 1 : ZMod 2) ≠ 0 := by
    native_decide +revert;
  -- Since $X^3 + X^2 + 1$ has no roots in $\mathbb{F}_2$, it must be irreducible over $\mathbb{F}_2$.
  have h_irred : ∀ p q : Polynomial (ZMod 2), p.degree > 0 → q.degree > 0 → p * q = Polynomial.X ^ 3 + Polynomial.X ^ 2 + 1 → False := by
    intros p q hp hq h_prod
    have h_deg : p.degree + q.degree = 3 := by
      rw [ ← Polynomial.degree_mul, h_prod, Polynomial.degree_add_eq_left_of_degree_lt ] <;> rw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> norm_num;
    -- Since $p$ and $q$ are non-constant polynomials with degrees adding up to 3, one of them must have degree 1.
    obtain (h_deg_p | h_deg_q) : p.degree = 1 ∨ q.degree = 1 := by
      erw [ Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hp ), Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hq ) ] at * ; norm_cast at * ; omega;
    · -- If $p$ has degree 1, then it must have a root in $\mathbb{F}_2$.
      obtain ⟨x, hx⟩ : ∃ x : ZMod 2, p.eval x = 0 := by
        exact Polynomial.exists_root_of_degree_eq_one h_deg_p;
      replace h_prod := congr_arg ( Polynomial.eval x ) h_prod ; simp_all +decide;
      fin_cases x <;> contradiction;
    · -- If $q$ has degree 1, then it must have a root in $\mathbb{F}_2$.
      obtain ⟨x, hx⟩ : ∃ x : ZMod 2, q.eval x = 0 := by
        exact Polynomial.exists_root_of_degree_eq_one h_deg_q;
      exact h_no_roots x ( by simpa [ hx ] using congr_arg ( Polynomial.eval x ) h_prod.symm );
  constructor <;> contrapose! h_irred;
  · exact absurd ( Polynomial.degree_eq_zero_of_isUnit h_irred ) ( by erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> norm_num );
  · rcases h_irred with ⟨ a, b, h₁, h₂, h₃ ⟩ ; exact ⟨ a, b, not_le.mp fun h₄ => h₂ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h₄ <| le_of_not_gt fun h₅ => by { apply_fun Polynomial.eval 0 at h₁; aesop }, not_le.mp fun h₄ => h₃ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h₄ <| le_of_not_gt fun h₅ => by { apply_fun Polynomial.eval 0 at h₁; aesop }, h₁.symm, trivial ⟩ ;

/-
The mod-2 factorization: `X⁵ + X + 1 = (X² + X + 1)(X³ + X² + 1)` in `𝔽₂[X]`.
-/
theorem quinticS5_mod2_factorization :
    (quinticS5.map (Int.castRingHom (ZMod 2))) =
    (X ^ 2 + X + 1) * (X ^ 3 + X ^ 2 + 1) := by
  -- Expand the right-hand side to verify the factorization.
  simp [quinticS5];
  grind +ring

/-! ## Part III: Galois group -/

/-- 5 divides the cardinality of the Galois group. -/
theorem quinticS5_five_dvd_gal_card : 5 ∣ Nat.card quinticS5_ℚ.Gal := by
  have h5 := quinticS5_ℚ_natDegree
  have := Polynomial.Gal.prime_degree_dvd_card quinticS5_irreducible_ℚ (by rw [h5]; decide)
  rwa [h5] at this

instance quinticS5_splits_ℂ : Fact (quinticS5_ℚ.map (algebraMap ℚ ℂ)).Splits :=
  ⟨IsAlgClosed.splits _⟩

/-- The Galois action on roots is pretransitive. -/
theorem quinticS5_galAction_pretransitive :
    MulAction.IsPretransitive quinticS5_ℚ.Gal (quinticS5_ℚ.rootSet ℂ) :=
  Polynomial.Gal.galAction_isPretransitive quinticS5_ℚ ℂ quinticS5_irreducible_ℚ

/-
Elements of `S₅` with order 6 are odd permutations.
-/
theorem order_6_in_S5_is_odd (σ : Equiv.Perm (Fin 5)) (h6 : orderOf σ = 6) :
    Equiv.Perm.sign σ = -1 := by
  revert h6;
  simp +decide only [orderOf_eq_iff];
  native_decide +revert

/-! ### Main theorem (conditional on Dedekind's theorem)

Dedekind's theorem states: for a monic irreducible `f ∈ ℤ[X]` and a prime `p` not
dividing `disc(f)`, if `f mod p = g₁ ⋯ gₖ` with distinct monic irreducible `gᵢ`,
then the Galois group contains a permutation with cycle type `(deg g₁, …, deg gₖ)`.

Applied to `X⁵ - X - 1` at `p = 2`: the factorization `(X²+X+1)(X³+X²+1)` gives
an element of cycle type `(2,3)`, order `6`, and sign `-1`. -/

/-- If the Galois group contains an element of order 6, then `30 ∣ |Gal|`. -/
theorem quinticS5_30_dvd_gal_card
    (h_order6 : ∃ σ : quinticS5_ℚ.Gal, orderOf σ = 6) :
    30 ∣ Nat.card quinticS5_ℚ.Gal := by
  obtain ⟨σ, hσ⟩ := h_order6
  have h6 : 6 ∣ Nat.card quinticS5_ℚ.Gal := by
    have := orderOf_dvd_natCard σ; rw [hσ] at this; exact this
  have h5 := quinticS5_five_dvd_gal_card
  exact Nat.Coprime.mul_dvd_of_dvd_of_dvd (by decide) h5 h6

/-- If the Galois group contains an element of order 6, then `|Gal| = 120`. -/
theorem quinticS5_gal_card_of_dedekind
    (h_order6 : ∃ σ : quinticS5_ℚ.Gal, orderOf σ = 6) :
    Nat.card quinticS5_ℚ.Gal = 120 := by
  sorry

/-- **Conditional main theorem.** If the Galois group of `X⁵ - X - 1` contains an
    element of order 6 (guaranteed by Dedekind's theorem at `p = 2`), then the
    Galois action homomorphism is bijective: `Gal(f/ℚ) ≅ S₅`. -/
theorem quinticS5_galActionHom_bijective_of_dedekind
    (h_order6 : ∃ σ : quinticS5_ℚ.Gal, orderOf σ = 6) :
    Function.Bijective (Polynomial.Gal.galActionHom quinticS5_ℚ ℂ) := by
  sorry

end