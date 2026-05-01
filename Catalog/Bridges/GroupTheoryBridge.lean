import Mathlib

/-! # Group Theory Bridge

Proves fundamental results about finite groups:
1. ZMod n has n elements: |Z/pℤ| = p
2. Order of element divides group order (Lagrange's theorem for cyclic subgroups)
3. g^|g| = 1 (order divides exponent)
4. orderOf (g^n) involves GCD of order and n

These are the FOUNDATIONAL results of finite group theory.
Lagrange's theorem (order of element | order of group) is one of the
most important theorems in algebra.
-/

namespace GroupTheoryBridge

/-! ## Section 1: Finite Cyclic Groups -/

/-- ZMod n has exactly n elements: |ℤ/nℤ| = n. -/
theorem zmod_card (n : ℕ) [Fintype (ZMod n)] :
    Fintype.card (ZMod n) = n :=
  ZMod.card n

/-! ## Section 2: Lagrange's Theorem for Element Orders -/

/-- **Order of element divides group order** (Lagrange's theorem for cyclic subgroups):
    If G is a finite group and g ∈ G, then |g| | |G|.
    This is the PRIMARY consequence of Lagrange's theorem. -/
theorem order_dvd_card {G : Type*} [Group G] [Fintype G]
    {x : G} :
    orderOf x ∣ Fintype.card G :=
  orderOf_dvd_card

/-! ## Section 3: Element Order Properties -/

/-- **g^|g| = 1**: The identity element property for element orders.
    Every element raised to its own order gives the identity. -/
theorem pow_order_eq_one {G : Type*} [Monoid G] (x : G) :
    x ^ orderOf x = 1 :=
  pow_orderOf_eq_one x

/-- **Order of g^n involves GCD**:
    orderOf(g^n) = orderOf(g) / gcd(orderOf(g), n).
    This shows that taking powers divides the order by the GCD. -/
theorem order_of_pow_eq_div_gcd {G : Type*} [LeftCancelMonoid G] [Finite G]
    {n : ℕ} (x : G) :
    orderOf (x ^ n) = orderOf x / (orderOf x).gcd n :=
  orderOf_pow x

end GroupTheoryBridge