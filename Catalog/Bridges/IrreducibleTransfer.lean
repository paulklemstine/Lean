/-
# Irreducibility Transfer: Finite Fields to Integers

This file establishes a reusable pattern for proving irreducibility of integer
polynomials by reduction to finite fields.

## Main results

* `irreducible_X4_add_X_add_one_zmod2` — X⁴ + X + 1 is irreducible over 𝔽₂
* `irreducible_X4_add_X_add_one_int` — X⁴ + X + 1 is irreducible over ℤ
* `irreducible_X4_add_X_add_one_rat` — X⁴ + X + 1 is irreducible over ℚ
* `irreducible_of_irreducible_mod_prime_monic` — reusable transfer theorem:
    monic + irreducible mod p ⟹ irreducible over ℤ

## Strategy

We use **Route 2** (modular transfer):
1. Prove X⁴ + X + 1 is irreducible over ZMod 2.
2. Apply the Gauss-style transfer: monic ℤ-polynomial irreducible mod p ⟹ irreducible over ℤ.
3. Transfer from ℤ to ℚ via the standard Gauss lemma.
-/

import Mathlib

open Polynomial

/-! ## The polynomial definition -/

/-- The polynomial X⁴ + X + 1 over any commutative ring. -/
noncomputable abbrev poly_X4_X_1 (R : Type*) [CommRing R] : Polynomial R :=
  X ^ 4 + X + 1

/-! ## Irreducibility over 𝔽₂ -/

/-
X⁴ + X + 1 has no roots in 𝔽₂.
-/
theorem no_root_X4_X_1_zmod2 (a : ZMod 2) :
    (poly_X4_X_1 (ZMod 2)).eval a ≠ 0 := by
  fin_cases a <;> simp +decide [ poly_X4_X_1 ]

/-
X² + X + 1 does not divide X⁴ + X + 1 over 𝔽₂.
-/
theorem not_dvd_quad_zmod2 :
    ¬ (X ^ 2 + X + 1 : Polynomial (ZMod 2)) ∣ poly_X4_X_1 (ZMod 2) := by
  rintro ⟨ q, hq ⟩;
  -- By comparing coefficients, we can see that there are no solutions for $a$, $b$, and $c$ in $\mathbb{F}_2$ that satisfy the equations derived from the polynomial division.
  have h_no_solution : ¬∃ (a b c : ZMod 2), q = Polynomial.X^2 + Polynomial.C a * Polynomial.X + Polynomial.C b := by
    rintro ⟨ a, b, c, rfl ⟩;
    simp_all +decide [ Polynomial.ext_iff, poly_X4_X_1 ];
    have := hq 0; have := hq 1; have := hq 2; have := hq 3; have := hq 4; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, add_mul, mul_assoc, pow_succ' ] at *;
    grind;
  have h_deg : q.natDegree = 2 := by
    have := congr_arg Polynomial.natDegree hq; erw [ Polynomial.natDegree_mul' ] at this <;> norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt ] at * ;
    · linarith;
    · exact ⟨ by exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by simp +decide ), by rintro rfl; simp +decide at this ⟩;
  rw [ Polynomial.as_sum_range_C_mul_X_pow q ] at hq h_no_solution; norm_num [ Finset.sum_range_succ', h_deg ] at hq h_no_solution;
  have := congr_arg ( fun p => Polynomial.coeff p 4 ) hq; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, pow_succ, mul_assoc, add_mul ] at this;
  exact h_no_solution ( q.coeff 1 ) ( q.coeff 0 ) ( by rw [ ← this ] ; simp +decide )

/-
X⁴ + X + 1 is irreducible over 𝔽₂.

The proof proceeds by:
1. Showing no element of 𝔽₂ is a root (ruling out linear factors).
2. Showing X² + X + 1 (the unique irreducible quadratic over 𝔽₂) does not divide it
   (ruling out quadratic factors).
3. A degree-4 polynomial with no linear or irreducible quadratic factors is irreducible.
-/
theorem irreducible_X4_add_X_add_one_zmod2 :
    Irreducible (poly_X4_X_1 (ZMod 2)) := by
  -- Assume there's a factorization f = a * b where a and b are non-constant polynomials.
  by_contra h
  obtain ⟨a, b, ha, hb, h_factor⟩ : ∃ a b : Polynomial (ZMod 2), a.degree > 0 ∧ b.degree > 0 ∧ (poly_X4_X_1 (ZMod 2)) = a * b := by
    contrapose! h;
    constructor <;> contrapose! h <;> simp_all +decide;
    · exact absurd ( Polynomial.degree_eq_zero_of_isUnit h ) ( by erw [ show poly_X4_X_1 ( ZMod 2 ) = Polynomial.X ^ 4 + Polynomial.X + 1 from rfl ] ; erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> simp +decide );
    · obtain ⟨ a, b, h₁, h₂, h₃ ⟩ := h; exact ⟨ a, not_le.mp fun h₄ => h₂ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h₄ <| le_of_not_gt fun h₅ => by { apply_fun Polynomial.eval 0 at h₁; aesop }, b, not_le.mp fun h₄ => h₃ <| Polynomial.isUnit_iff_degree_eq_zero.mpr <| le_antisymm h₄ <| le_of_not_gt fun h₅ => by { apply_fun Polynomial.eval 0 at h₁; aesop }, h₁ ⟩ ;
  -- Since $a$ and $b$ are non-constant polynomials in $\mathbb{F}_2[x]$, their degrees must be $1$ or $2$.
  have h_deg : a.degree = 1 ∧ b.degree = 3 ∨ a.degree = 3 ∧ b.degree = 1 ∨ a.degree = 2 ∧ b.degree = 2 := by
    have h_deg : a.degree + b.degree = 4 := by
      erw [ ← Polynomial.degree_mul, ← h_factor, Polynomial.degree_add_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_add_eq_left_of_degree_lt ] <;> norm_num;
    rw [ Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt ha ), Polynomial.degree_eq_natDegree ( Polynomial.ne_zero_of_degree_gt hb ) ] at * ; norm_cast at * ; omega;
  obtain h | h | h := h_deg <;> simp_all +decide [ poly_X4_X_1 ];
  · -- If $a$ is a polynomial of degree $1$, then $a$ must have a root in $\mathbb{F}_2$.
    obtain ⟨x, hx⟩ : ∃ x : ZMod 2, a.eval x = 0 := by
      exact Polynomial.exists_root_of_degree_eq_one h.1;
    replace h_factor := congr_arg ( Polynomial.eval x ) h_factor ; simp_all +decide;
    fin_cases x <;> contradiction;
  · -- Since $b$ is a polynomial of degree 1, it must have a root in $\mathbb{F}_2$.
    obtain ⟨r, hr⟩ : ∃ r : ZMod 2, b.eval r = 0 := by
      exact Polynomial.exists_root_of_degree_eq_one h.2;
    replace h_factor := congr_arg ( Polynomial.eval r ) h_factor ; simp_all +decide;
    fin_cases r <;> contradiction;
  · -- Let $a(x) = ax^2 + bx + c$ and $b(x) = dx^2 + ex + f$.
    obtain ⟨a0, a1, a2, ha⟩ : ∃ a0 a1 a2 : ZMod 2, a = Polynomial.C a0 * Polynomial.X ^ 2 + Polynomial.C a1 * Polynomial.X + Polynomial.C a2 := by
      rw [ @Polynomial.as_sum_range_C_mul_X_pow ( ZMod 2 ) _ a ] ; exact ⟨ a.coeff 2, a.coeff 1, a.coeff 0, by simp +arith +decide [ Polynomial.natDegree_eq_of_degree_eq_some h.left, Finset.sum_range_succ' ] ⟩ ;
    obtain ⟨b0, b1, b2, hb⟩ : ∃ b0 b1 b2 : ZMod 2, b = Polynomial.C b0 * Polynomial.X ^ 2 + Polynomial.C b1 * Polynomial.X + Polynomial.C b2 := by
      rw [ @Polynomial.as_sum_range_C_mul_X_pow ( ZMod 2 ) _ b ] ; exact ⟨ b.coeff 2, b.coeff 1, b.coeff 0, by simp +arith +decide [ Polynomial.natDegree_eq_of_degree_eq_some h.2, Finset.sum_range_succ' ] ⟩ ;
    simp_all +decide [ Polynomial.ext_iff ];
    have := h_factor 0; have := h_factor 1; have := h_factor 2; have := h_factor 3; have := h_factor 4; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, mul_assoc, add_mul, pow_succ ] at *;
    fin_cases a0 <;> fin_cases a1 <;> fin_cases a2 <;> fin_cases b0 <;> fin_cases b1 <;> fin_cases b2 <;> contradiction

/-! ## The reusable transfer theorem -/

/-- **Monic mod-p irreducibility transfer.**

If `f : ℤ[X]` is monic and its image in `(ℤ/pℤ)[X]` is irreducible for some prime `p`,
then `f` is irreducible over ℤ.

This is a direct consequence of `Polynomial.Monic.irreducible_of_irreducible_map`
from Mathlib, packaged for convenient use with `ZMod p`. -/
theorem irreducible_of_irreducible_mod_prime_monic
    (f : Polynomial ℤ)
    (p : ℕ)
    [hp : Fact p.Prime]
    (hmonic : f.Monic)
    (hmod : Irreducible (f.map (Int.castRingHom (ZMod p)))) :
    Irreducible f :=
  hmonic.irreducible_of_irreducible_map (Int.castRingHom (ZMod p)) f hmod

/-! ## Main results -/

/-
The polynomial X⁴ + X + 1 is monic over ℤ.
-/
theorem monic_X4_X_1_int : (poly_X4_X_1 ℤ).Monic := by
  rw [ Polynomial.Monic, Polynomial.leadingCoeff ];
  norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.natDegree_add_eq_left_of_natDegree_lt ]

/-
The map of X⁴ + X + 1 from ℤ to ZMod 2 equals X⁴ + X + 1 over ZMod 2.
-/
theorem map_X4_X_1_zmod2 :
    (poly_X4_X_1 ℤ).map (Int.castRingHom (ZMod 2)) = poly_X4_X_1 (ZMod 2) := by
  unfold poly_X4_X_1; norm_num [ Polynomial.ext_iff ] ;

/-- **X⁴ + X + 1 is irreducible over ℤ.**

Proved by modular transfer: the polynomial is monic and irreducible over 𝔽₂,
hence irreducible over ℤ. -/
theorem irreducible_X4_add_X_add_one_int :
    Irreducible (poly_X4_X_1 ℤ) := by
  apply irreducible_of_irreducible_mod_prime_monic _ 2 monic_X4_X_1_int
  rw [map_X4_X_1_zmod2]
  exact irreducible_X4_add_X_add_one_zmod2

/-
**X⁴ + X + 1 is irreducible over ℚ.**

Since X⁴ + X + 1 is monic and irreducible over ℤ, it is irreducible over ℚ
by the Gauss lemma.
-/
theorem irreducible_X4_add_X_add_one_rat :
    Irreducible (poly_X4_X_1 ℚ) := by
  -- Since poly_X4_X_1 ℚ is a primitive polynomial over ℤ and is irreducible over ℤ, it is also irreducible over ℚ.
  have h_irred_rat : Irreducible (poly_X4_X_1 ℤ) := by
    convert irreducible_X4_add_X_add_one_int;
  have h_primitive : Polynomial.IsPrimitive (poly_X4_X_1 ℤ) := by
    exact monic_X4_X_1_int.isPrimitive;
  -- Apply the Gauss lemma to conclude that the polynomial is irreducible over the rationals.
  have h_gauss : Irreducible (Polynomial.map (Int.castRingHom ℚ) (poly_X4_X_1 ℤ)) := by
    exact (IsPrimitive.Int.irreducible_iff_irreducible_map_cast h_primitive).mp h_irred_rat;
  convert h_gauss using 1;
  unfold poly_X4_X_1; norm_num;

#print axioms irreducible_X4_add_X_add_one_int
#print axioms irreducible_X4_add_X_add_one_rat