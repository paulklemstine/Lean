/-
Copyright (c) 2025. All rights reserved.

# Cube Subgroup Structure and Obstruction Criterion

## Main Results

- `every_unit_is_cube_of_prime_mod3_eq2` : For primes p ≡ 2 (mod 3),
  every unit in `ZMod p` is a cube
- `primitiveResidueSolution_of_prime_mod3_eq2` : For primes p ≡ 2 (mod 3)
  with p ≥ 5, primitive residue solutions to (3,3,3) always exist
- `cubic_obstructing_primes` : Certified obstructions at p = 2, 7, 13
- `cubic_non_obstructing_primes` : Certified solutions at p = 3, 5, 11

## Mathematical Background

For a prime `p`, the cube map `x ↦ x³` on `(ℤ/pℤ)×` has image equal
to the unique subgroup of index `gcd(3, p-1)`. When `3 ∤ (p-1)`, every
unit is a cube and the obstruction cannot occur. When `3 ∣ (p-1)`, cubes
form a proper subgroup, and the question reduces to sumset avoidance.
-/
import Mathlib
import Speculative.Beal.Defs

/-! ## Cube Map Properties -/

/-
For primes `p` with `p % 3 = 2` (i.e., `3 ∤ (p-1)`), every element
of `ZMod p` is a perfect cube. This uses the fact that `gcd(3, p-1) = 1`
implies the cube map is a bijection on `(ℤ/pℤ)×`.
-/
theorem every_unit_is_cube_of_prime_mod3_eq2
    {p : ℕ} (hp : Nat.Prime p) (hmod : p % 3 = 2) (a : ZMod p) (ha : IsUnit a) :
    ∃ b : ZMod p, IsUnit b ∧ b ^ 3 = a := by
  -- Since $p \equiv 2 \pmod{3}$, we know that $x \mapsto x^3$ is a bijection on $(\mathbb{Z}/p\mathbb{Z})^*$.
  have h_bijection : Function.Bijective (fun x : (ZMod p)ˣ => x ^ 3) := by
    have h_bijection : ∀ x : (ZMod p)ˣ, x ^ 3 = 1 → x = 1 := by
      haveI := Fact.mk hp; intro x hx; have := orderOf_dvd_iff_pow_eq_one.mpr hx; simp_all +decide [ Nat.dvd_prime ] ;
      exact this.resolve_right fun h => by have := orderOf_dvd_iff_pow_eq_one.mpr ( show x ^ ( p - 1 ) = 1 from by rw [ ← ZMod.card_units p, pow_card_eq_one ] ) ; rw [ h ] at this; rw [ Nat.dvd_iff_mod_eq_zero ] at this; rw [ ← Nat.mod_add_div p 3, hmod ] at this; norm_num at this;
    have h_injective : Function.Injective (fun x : (ZMod p)ˣ => x ^ 3) := by
      intro x y hxy; specialize h_bijection ( x * y⁻¹ ) ; simp_all +decide [ mul_pow ] ;
      simpa using eq_inv_of_mul_eq_one_left h_bijection;
    exact ⟨ h_injective, Finite.injective_iff_surjective.mp h_injective ⟩;
  cases' ha with u hu; cases' h_bijection.2 u with b hb; use b; aesop;

/-
For primes p ≡ 2 (mod 3) with p ≥ 5, a primitive residue solution
always exists for signature (3,3,3). When every unit is a cube, the
equation `a³ + b³ = c³` reduces to `u + v = w` for units, which is
clearly solvable.
-/
theorem primitiveResidueSolution_of_prime_mod3_eq2
    {p : ℕ} (hp : Nat.Prime p) (hmod : p % 3 = 2) (hp5 : 5 ≤ p) :
    PrimitiveResidueSolution p 3 3 3 := by
  -- Since $p \geq 5$, $2$ is a unit in $ZMod p$.
  have h_unit2 : IsUnit (2 : ZMod p) := by
    haveI := Fact.mk hp; exact isUnit_iff_ne_zero.mpr ( by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith ) ) ;
  -- By every_unit_is_cube_of_prime_mod3_eq2, there exist units a, b, c such that a^3 = 1, b^3 = 1, and c^3 = 2.
  obtain ⟨a, ha⟩ : ∃ a : ZMod p, IsUnit a ∧ a ^ 3 = 1 := by
    exact ⟨ 1, isUnit_one, by norm_num ⟩
  obtain ⟨b, hb⟩ : ∃ b : ZMod p, IsUnit b ∧ b ^ 3 = 1 := by
    use a
  obtain ⟨c, hc⟩ : ∃ c : ZMod p, IsUnit c ∧ c ^ 3 = 2 := by
    exact every_unit_is_cube_of_prime_mod3_eq2 hp hmod 2 h_unit2;
  exact ⟨ a, b, c, ha.1, hb.1, hc.1, by linear_combination' ha.2 + hb.2 - hc.2 ⟩

/-! ## Multiple Obstructing Primes -/

/-- All three known obstructing primes for (3,3,3) below 200. -/
theorem cubic_obstructing_primes :
    ¬ PrimitiveResidueSolution 2 3 3 3 ∧
    ¬ PrimitiveResidueSolution 7 3 3 3 ∧
    ¬ PrimitiveResidueSolution 13 3 3 3 := by
  refine ⟨?_, ?_, ?_⟩ <;> {
    show ¬ (∃ a b c : ZMod _, IsUnit a ∧ IsUnit b ∧ IsUnit c ∧ a ^ 3 + b ^ 3 = c ^ 3)
    native_decide }

/-- Primes 3, 5, 11 all admit primitive residue solutions for (3,3,3).
This confirms that obstruction is a non-trivial property. -/
theorem cubic_non_obstructing_primes :
    PrimitiveResidueSolution 3 3 3 3 ∧
    PrimitiveResidueSolution 5 3 3 3 ∧
    PrimitiveResidueSolution 11 3 3 3 := by
  refine ⟨?_, ?_, ?_⟩ <;> {
    show ∃ a b c : ZMod _, IsUnit a ∧ IsUnit b ∧ IsUnit c ∧ a ^ 3 + b ^ 3 = c ^ 3
    native_decide }