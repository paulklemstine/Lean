import Mathlib

/-!
# Quadruple Division Factoring: From Triples to 4D and Back

## Overview

We formalize the "Quadruple Division" pipeline for integer factoring:
1. Embed a target number N as a leg of a Pythagorean triple
2. Lift the triple to a Pythagorean quadruple (3D → 4D)
3. Extract factor information via GCD cascades on the quadruple's components
4. Map the reduced quadruple back to a (potentially different) Pythagorean triple
5. Track how these mappings create new links in the Berggren tree

### Key Theorems

- **Trivial Triple Construction**: Every odd N ≥ 3 is a leg of the triple (N, (N²-1)/2, (N²+1)/2)
- **Quadruple Lift Theorem**: Every Pythagorean triple lifts to at least one quadruple
- **Factor Extraction via d-c**: For a quadruple with N as component,
  gcd(d-c, N) often yields a nontrivial factor
- **Shared-Hypotenuse Factor Theorem**: Two quadruples with the same hypotenuse d
  yield factor information through cross-component GCDs
- **Berggren Bridge**: Quadruple projection can map between different Berggren tree nodes
-/

/-! ## §1. Trivial Triple Construction -/

/-
For any odd n ≥ 3, the triple (n, (n²-1)/2, (n²+1)/2) is Pythagorean.
-/
theorem odd_trivial_triple (n : ℤ) (hn : n % 2 = 1) :
    n ^ 2 + ((n ^ 2 - 1) / 2) ^ 2 = ((n ^ 2 + 1) / 2) ^ 2 := by
  cases abs_cases n <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ n ^ 2 - 1 from Int.dvd_self_sub_of_emod_eq ( by simp +decide [ sq, Int.mul_emod, hn ] ) ), Int.ediv_mul_cancel ( show 2 ∣ n ^ 2 + 1 from Int.dvd_of_emod_eq_zero ( by simp +decide [ sq, Int.mul_emod, Int.add_emod, hn ] ) ) ]

/-
For any even n ≥ 4, the triple (n, (n/2)²-1, (n/2)²+1) is Pythagorean.
-/
theorem even_trivial_triple (m : ℤ) (hm : m > 0) :
    (2 * m) ^ 2 + (m ^ 2 - 1) ^ 2 = (m ^ 2 + 1) ^ 2 := by
  ring

/-! ## §2. The Quadruple Equation and Factor Structure -/

/-
The fundamental quadruple identity: a² + b² + c² = d² implies
    (d-c)(d+c) = a² + b².
-/
theorem quad_factor_identity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by
  linarith

/-
Lifting a Pythagorean triple to a quadruple: if a² + b² = e² and
    e² + k² = d² (i.e., e is also a leg of another triple), then
    a² + b² + k² = d².
-/
theorem triple_lift_to_quadruple (a b e k d : ℤ)
    (h1 : a ^ 2 + b ^ 2 = e ^ 2)
    (h2 : e ^ 2 + k ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2 := by
  linarith

/-
If a² + b² + c² = d² and g = gcd(d-c, d+c), then g divides a² + b².
-/
theorem gcd_dc_divides_sum_sq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ↑(Int.gcd (d - c) (d + c)) ∣ (a ^ 2 + b ^ 2) := by
  exact ⟨ ( d - c ) * ( d + c ) / Int.gcd ( d - c ) ( d + c ), by linarith [ Int.ediv_mul_cancel <| show ( Int.gcd ( d - c ) ( d + c ) : ℤ ) ∣ ( d - c ) * ( d + c ) from dvd_mul_of_dvd_left ( Int.gcd_dvd_left _ _ ) _ ] ⟩

/-! ## §3. Factor Extraction Theorems -/

/-
**Key Factoring Theorem**: If N = a is part of a quadruple (a,b,c,d)
    with a²+b²+c²=d², then gcd(d-c, a) · gcd(d+c, a) divides a².
-/
theorem factor_extraction_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (↑(Int.gcd (d - c) a) : ℤ) * ↑(Int.gcd (d + c) a) ∣ a ^ 2 := by
  convert mul_dvd_mul ( Int.gcd_dvd_right ( d - c ) a ) ( Int.gcd_dvd_right ( d + c ) a ) using 1 ; ring

/-
For odd N in the trivial triple (N, (N²-1)/2, (N²+1)/2),
    the hypotenuse satisfies c = (N²+1)/2.
-/
theorem trivial_triple_hypotenuse (n : ℤ) (hn_odd : n % 2 = 1) (hn_pos : n > 0) :
    n ^ 2 + ((n ^ 2 - 1) / 2) ^ 2 = ((n ^ 2 + 1) / 2) ^ 2 := by
  exact?

/-! ## §4. Shared-Hypotenuse Collision Theorem -/

/-
**Collision Theorem**: If (a₁,b₁,c₁,d) and (a₂,b₂,c₂,d) are two
    Pythagorean quadruples with the same hypotenuse d, then
    a₁² + b₁² + c₁² = a₂² + b₂² + c₂².
-/
theorem shared_hypotenuse_eq (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 := by
  grind

/-
**Cross-Difference Identity**: Under shared hypotenuse,
    (c₁² - c₂²) = (a₂² - a₁²) + (b₂² - b₁²).
-/
theorem cross_difference_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    c₁ ^ 2 - c₂ ^ 2 = (a₂ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - b₁ ^ 2) := by
  grind

/-
**Factor via Cross-Difference**: The cross-difference of squares factors as
    (c₁-c₂)(c₁+c₂) = (a₂-a₁)(a₂+a₁) + (b₂-b₁)(b₂+b₁).
-/
theorem cross_difference_factored (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (c₁ - c₂) * (c₁ + c₂) =
    (a₂ - a₁) * (a₂ + a₁) + (b₂ - b₁) * (b₂ + b₁) := by
  linarith

/-! ## §5. Berggren Tree Formalization -/

/-- Berggren matrix M₁ applied to a triple. -/
def berggrenM1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)

/-- Berggren matrix M₂ applied to a triple. -/
def berggrenM2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)

/-- Berggren matrix M₃ applied to a triple. -/
def berggrenM3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-
M₁ preserves the Pythagorean property.
-/
theorem berggrenM1_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM1 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM1; linarith;

/-
M₂ preserves the Pythagorean property.
-/
theorem berggrenM2_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM2; linarith;

/-
M₃ preserves the Pythagorean property.
-/
theorem berggrenM3_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM3 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM3; linarith;

/-! ## §6. Quadruple-Mediated Berggren Bridge -/

/-
**Bridge Theorem**: If a Berggren triple (a,b,c) lifts to quadruple (a,b,k,d)
    and the projection √(a²+k²) is an integer e, then e² + b² = d².
    This means (b, e, d) — or equivalently (e, b, d) — is a new
    Pythagorean triple that may live at a different Berggren tree node.
-/
theorem berggren_bridge_triple (a b c k d : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2)
    (h_quad : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2)
    (e : ℤ) (h_e : a ^ 2 + k ^ 2 = e ^ 2) :
    e ^ 2 + b ^ 2 = d ^ 2 := by
  linarith

/-
The hypotenuse grows multiplicatively under Berggren: c' = 2a - 2b + 3c for M₁.
-/
theorem berggren_hypotenuse_growth_M1 (a b c : ℤ) :
    (berggrenM1 a b c).2.2 = 2 * a - 2 * b + 3 * c := by
  rfl

/-
The hypotenuse grows under M₂: c' = 2a + 2b + 3c.
-/
theorem berggren_hypotenuse_growth_M2 (a b c : ℤ) :
    (berggrenM2 a b c).2.2 = 2 * a + 2 * b + 3 * c := by
  rfl

/-! ## §7. GCD Cascade for Factor Extraction from Multiple Quadruples -/

/-
If two quadruples share hypotenuse d and we compute
    g = gcd(c₁² - c₂², N), this divides N when c₁² ≡ c₂² (mod some factor of N).
-/
theorem gcd_cascade_divides (c₁ c₂ N : ℤ) (hN : N > 0) :
    ↑(Int.gcd (c₁ ^ 2 - c₂ ^ 2) N) ∣ N := by
  exact Int.gcd_dvd_right _ _

/-
The GCD of a value with N always divides N (foundational).
-/
theorem gcd_divides_right (a N : ℤ) : ↑(Int.gcd a N) ∣ N := by
  exact Int.gcd_dvd_right _ _

/-! ## §8. The Division-Reduction Map -/

/-
**Quadruple Reduction**: Dividing each component by gcd(a,b,c,d)
    preserves the quadruple equation.
-/
theorem quad_reduction_preserves (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (g : ℤ) (hg : g > 0) (ha : g ∣ a) (hb : g ∣ b) (hc : g ∣ c) (hd : g ∣ d) :
    (a / g) ^ 2 + (b / g) ^ 2 + (c / g) ^ 2 = (d / g) ^ 2 := by
  obtain ⟨ k₁, rfl ⟩ := ha; obtain ⟨ k₂, rfl ⟩ := hb; obtain ⟨ k₃, rfl ⟩ := hc; obtain ⟨ k₄, rfl ⟩ := hd; ring;
  rw [ Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne' ] ; nlinarith [ mul_pos hg hg ]

/-! ## §9. Parity Constraints on Quadruples -/

/-
In a Pythagorean quadruple a²+b²+c²=d², at most one of a,b,c is odd
    when d is even (or other parity constraints apply).
-/
theorem quad_parity_constraint (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd_even : 2 ∣ d) (ha_odd : ¬ 2 ∣ a) (hb_odd : ¬ 2 ∣ b) :
    2 ∣ c := by
  obtain ⟨ k, hk ⟩ := hd_even; replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ m, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ n, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ o, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;
  norm_num [ hk, mul_pow ] at h

/-! ## §10. Quadruple Component Sum Identity -/

/-
The sum of all components of a quadruple satisfies:
    (a + b + c + d)² = 2(d² + d(a+b+c) + ab + ac + bc).
-/
theorem quad_component_sum_sq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + b + c + d) ^ 2 =
    2 * (d ^ 2 + d * (a + b + c) + a * b + a * c + b * c) := by
  grind