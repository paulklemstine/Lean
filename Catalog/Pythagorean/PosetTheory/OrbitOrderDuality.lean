/-
# Orbit-Order Duality for the Iterated Squaring Map

The squaring map f(x) = x² mod n on the unit group (ℤ/nℤ)* has orbit structure
that encodes algebraic information about n. The central result is:

**Orbit-Order Duality**: For a unit x with multiplicative order d = ord_n(x),
the period of x under iterated squaring equals ord_d(2), the multiplicative
order of 2 in (ℤ/dℤ)* (when d is odd).

This transforms a dynamical question (orbit period under iteration) into an
algebraic question (order of 2 in a quotient group).
-/

import Mathlib

open Function

/-! ## The squaring function and its iterates -/

/-- The squaring function on a monoid: x ↦ x * x. -/
def sqFun (M : Type*) [Monoid M] : M → M := fun x => x * x

/-- Iterating the squaring function gives exponentiation by powers of 2:
    sqFun^[k](x) = x^(2^k). -/
theorem sqFun_iterate (M : Type*) [Monoid M] (x : M) (k : ℕ) :
    (sqFun M)^[k] x = x ^ (2 ^ k) := by
      induction k <;> simp_all +decide [ pow_succ, pow_mul, Function.iterate_succ', sqFun ];
      rename_i n hn;
      convert congr_arg ( fun y => sqFun M y ) hn using 1;
      exact Function.iterate_succ_apply' ( sqFun M ) n x

/-! ## Core algebraic equivalences -/

/-- In a group, x^n = x iff x^(n-1) = 1, for any n ≥ 1.
    This is the key bridge between "returning to x" and "having order dividing n-1". -/
theorem pow_eq_self_iff_pow_pred_eq_one {G : Type*} [Group G] (x : G) (n : ℕ) (hn : 1 ≤ n) :
    x ^ n = x ↔ x ^ (n - 1) = 1 := by
      cases n <;> simp_all +decide [ pow_succ' ]

/-- In a group, x^(2^k) = x iff ord(x) divides 2^k - 1 (for k ≥ 1).
    This is the fundamental equivalence connecting squaring orbits to orders. -/
theorem sq_iter_eq_self_iff {G : Type*} [Group G] (x : G) (k : ℕ) (hk : 1 ≤ k) :
    x ^ (2 ^ k) = x ↔ orderOf x ∣ (2 ^ k - 1) := by
      convert pow_eq_self_iff_pow_pred_eq_one x ( 2 ^ k ) ( by linarith [ Nat.pow_le_pow_right ( by decide : 1 ≤ 2 ) hk ] ) using 1;
      rw [ orderOf_dvd_iff_pow_eq_one ]

/-! ## Periodicity and orbit structure -/

/-- Helper: from Odd d to the coprimality needed for ZMod.unitOfCoprime. -/
def oddOrderUnit (d : ℕ) (hodd : Odd d) : (ZMod d)ˣ :=
  ZMod.unitOfCoprime 2 (Nat.coprime_two_left.mpr hodd)

/-- A unit with odd order in a finite group is periodic under squaring. -/
theorem sqFun_isPeriodicPt_of_odd_order {G : Type*} [Group G] [Finite G]
    (x : G) (hodd : Odd (orderOf x)) :
    ∃ k > 0, IsPeriodicPt (sqFun G) k x := by
      -- By definition of $oddOrderUnit$, we know that $2^k ≡ 1 \pmod{orderOf x}$.
      obtain ⟨k, hk⟩ : ∃ k > 0, (2 ^ k : ℕ) ≡ 1 [MOD orderOf x] := by
        -- By Euler's theorem, since gcd(2, orderOf x) = 1, we have 2^(φ(orderOf x)) ≡ 1 [MOD orderOf x].
        have h_euler : 2 ^ Nat.totient (orderOf x) ≡ 1 [MOD orderOf x] := by
          exact Nat.ModEq.pow_totient ( Nat.prime_two.coprime_iff_not_dvd.mpr ( by simpa [ ← even_iff_two_dvd ] using hodd ) );
        grind +suggestions;
      -- By definition of $IsPeriodicPt$, we need to show that $x^{2^k} = x$.
      have h_period : x ^ (2 ^ k) = x := by
        rw [ ← Nat.mod_add_div ( 2 ^ k ) ( orderOf x ), hk.2 ] ; simp +decide [ pow_add, pow_mul, pow_orderOf_eq_one ] ;
      exact ⟨ k, hk.1, by rw [ IsPeriodicPt, IsFixedPt, sqFun_iterate ] ; exact h_period ⟩

/-- The squaring orbit period of a unit with odd order divides
    the order of 2 modulo ord(x). -/
theorem minimalPeriod_sqFun_dvd {G : Type*} [Group G] [Finite G]
    (x : G) (hodd : Odd (orderOf x)) :
    minimalPeriod (sqFun G) x ∣ orderOf (oddOrderUnit (orderOf x) hodd) := by
      -- By definition of minimal period, we know that the minimal period is the smallest positive integer $k$ such that $sqFun^k(x) = x$.
      have h_min_period : IsPeriodicPt (sqFun G) (orderOf (oddOrderUnit (orderOf x) hodd)) x := by
        convert sq_iter_eq_self_iff x ( orderOf ( oddOrderUnit ( orderOf x ) hodd ) ) _;
        · simp +decide [ ← sqFun_iterate, IsPeriodicPt, IsFixedPt ];
          have h_unit : (oddOrderUnit (orderOf x) hodd) ^ orderOf (oddOrderUnit (orderOf x) hodd) = 1 := by
            exact pow_orderOf_eq_one _;
          have h_unit : (2 : ZMod (orderOf x)) ^ orderOf (oddOrderUnit (orderOf x) hodd) = 1 := by
            convert congr_arg ( fun u : ( ZMod ( orderOf x ) )ˣ => u.val ) h_unit using 1;
          simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
        · exact orderOf_pos _;
      exact h_min_period.minimalPeriod_dvd

/-- The order of 2 modulo ord(x) divides the squaring orbit period. -/
theorem orderOf_two_dvd_minimalPeriod_sqFun {G : Type*} [Group G] [Finite G]
    (x : G) (hodd : Odd (orderOf x)) :
    orderOf (oddOrderUnit (orderOf x) hodd) ∣ minimalPeriod (sqFun G) x := by
      have h_eq : x ^ (2 ^ minimalPeriod (sqFun G) x) = x := by
        rw [ ← sqFun_iterate ];
        exact Function.isPeriodicPt_minimalPeriod _ _;
      -- By sq_iter_eq_self_iff with m ≥ 1, orderOf x | 2^m - 1.
      have h_div : orderOf x ∣ 2 ^ minimalPeriod (sqFun G) x - 1 := by
        rw [ orderOf_dvd_iff_pow_eq_one ];
        rcases n : 2 ^ minimalPeriod ( sqFun G ) x with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
      -- This means 2^m ≡ 1 mod (orderOf x), i.e. orderOf x | 2^m - 1.
      have h_cong : (2 : ZMod (orderOf x)) ^ minimalPeriod (sqFun G) x = 1 := by
        simp_all +decide [ ← ZMod.natCast_eq_zero_iff, sub_eq_iff_eq_add ];
      exact orderOf_dvd_iff_pow_eq_one.mpr ( by simpa [ Units.ext_iff ] using h_cong )

/-! ## Main Theorem: Orbit-Order Duality -/

/-- **Orbit-Order Duality Theorem**.
    For an element x of a finite group with odd multiplicative order d,
    the minimal period of x under the squaring map x ↦ x² equals ord_d(2),
    the multiplicative order of 2 in (ℤ/dℤ)*.

    This transforms a dynamical property (orbit period under iteration)
    into a purely algebraic property (order in a quotient group). -/
theorem orbit_order_duality {G : Type*} [Group G] [Finite G]
    (x : G) (hodd : Odd (orderOf x)) :
    minimalPeriod (sqFun G) x = orderOf (oddOrderUnit (orderOf x) hodd) :=
  Nat.dvd_antisymm
    (minimalPeriod_sqFun_dvd x hodd)
    (orderOf_two_dvd_minimalPeriod_sqFun x hodd)

/-! ## Application to (ℤ/nℤ)* -/

/-- Orbit-Order Duality for the unit group of ℤ/nℤ. -/
theorem orbit_order_duality_ZMod {n : ℕ} [NeZero n] (x : (ZMod n)ˣ)
    (hodd : Odd (orderOf x)) :
    minimalPeriod (sqFun (ZMod n)ˣ) x = orderOf (oddOrderUnit (orderOf x) hodd) :=
  orbit_order_duality x hodd

/-! ## Orbit periods detect structural information -/

/-- If x has order d (odd) and k = ord_d(2), then d divides 2^k - 1.
    This means the orbit period gives us a number 2^k - 1 that is
    divisible by the order of x. -/
theorem order_divides_two_pow_period_sub_one {G : Type*} [Group G] [Finite G]
    (x : G) (_hodd : Odd (orderOf x)) :
    orderOf x ∣ 2 ^ (minimalPeriod (sqFun G) x) - 1 := by
      have h_order : (sqFun G)^[minimalPeriod (sqFun G) x] x = x :=
        Function.isPeriodicPt_minimalPeriod _ _
      grind +suggestions

/-- The squaring map returns x to itself after exactly one orbit period. -/
theorem sqFun_iterate_period {G : Type*} [Group G] [Finite G]
    (x : G) (_hodd : Odd (orderOf x)) :
    (sqFun G)^[minimalPeriod (sqFun G) x] x = x := by
      -- By definition of minimal period, we have that $(sqFun G)^[minimalPeriod (sqFun G) x] x = x$.
      apply Function.isPeriodicPt_minimalPeriod