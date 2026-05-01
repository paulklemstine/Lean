/-! # CatalogBuild.Bridges.GroupTheoryBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 3
-/

import Mathlib

/-- **Order of element divides group order** (Lagrange's theorem for cyclic subgroups):
If G is a finite group and g ∈ G, then |g| | |G|.
This is the PRIMARY consequence of Lagrange's theorem. -/
theorem order_dvd_card {G : Type*} [Group G] [Fintype G]
    {x : G} :
    orderOf x ∣ Fintype.card G :=
  orderOf_dvd_card


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

