/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.HeckePacket.Defs

/-!
# Local Euler Factor Identity

This file proves that the local generating series of an unramified Hecke eigenpacket
satisfies a rational functional equation: the quadratic Euler polynomial annihilates
the local power series.

## Main Result

For each prime `p`, define the local generating function
$$G_p(T) = \sum_{r \geq 0} a(p^r) T^r.$$

We prove coefficientwise that
$$(1 - a(p)T + pT^2) \cdot G_p(T) = 1,$$
i.e., the product is the constant power series 1.

## Cross-Domain Significance

This converts automorphic/number-theoretic data into a **transfer function identity**:
the local Euler factor `(1 - a(p)T + pT²)⁻¹` is the transfer function of the
second-order linear recurrence defined by the prime-power recursion. This bridges:
- **Number theory ↔ formal power series**: Euler products become rational functions
- **Number theory ↔ dynamical systems**: Satake parameters are poles/eigenmodes
- **Representation theory ↔ signal processing**: Hecke eigenvalues define linear
  recurrence filters
-/

open PowerSeries Finset BigOperators

namespace UnramifiedHeckePacket

variable {R : Type*} [CommRing R] (pkt : UnramifiedHeckePacket R)

/-- The local generating series at a prime `p`:
`G_p(T) = ∑_{r≥0} a(p^r) · T^r` as a formal power series. -/
noncomputable def localSeries (p : ℕ) : PowerSeries R :=
  PowerSeries.mk (fun r => pkt.a (p ^ r))

/-- Coefficient of the local series. -/
@[simp]
theorem coeff_localSeries (p n : ℕ) :
    PowerSeries.coeff n (pkt.localSeries p) = pkt.a (p ^ n) := by
  simp [localSeries]

/-- The Euler polynomial at prime `p` as a formal power series:
`E_p(T) = 1 - a(p)·T + p·T²` -/
noncomputable def eulerPolySeries (p : ℕ) : PowerSeries R :=
  1 - PowerSeries.C (pkt.a p) * PowerSeries.X +
    PowerSeries.C (p : R) * PowerSeries.X ^ 2

/-
**Local Euler Factor Identity (coefficientwise)**.

For a normalized unramified Hecke eigenpacket and any prime `p`, the `n`-th
coefficient of the product `(1 - a(p)T + pT²) · G_p(T)` equals `1` when
`n = 0` and `0` otherwise.

This is the fundamental bridge between automorphic data and rational
generating functions. It converts the three-term recurrence into a
transfer function identity, connecting number theory to spectral methods
and signal processing.
-/
theorem local_euler_factor_coeffwise
    {p : ℕ} (hp : Nat.Prime p) (n : ℕ) :
    PowerSeries.coeff n (pkt.eulerPolySeries p * pkt.localSeries p) =
      if n = 0 then 1 else 0 := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ mul_assoc, PowerSeries.coeff_mul ];
  · unfold eulerPolySeries; simp +decide [ pkt.a_one ] ;
  · simp +decide [ antidiagonal, eulerPolySeries ];
    simp +decide [ PowerSeries.coeff_mul, PowerSeries.coeff_X_pow, hp.ne_zero ];
    simp +decide [ antidiagonal, pkt.a_one ];
  · simp +decide [ Finset.Nat.sum_antidiagonal_succ, hp, UnramifiedHeckePacket.coeff_prime_power_rec ];
    unfold UnramifiedHeckePacket.eulerPolySeries; simp +decide [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ] ; ring;
    simp +decide [ add_comm 1, add_comm 2, Finset.sum_range_succ', PowerSeries.coeff_one, PowerSeries.coeff_X_pow, mul_assoc, mul_left_comm, mul_comm ];
    erw [ Finset.sum_eq_zero ] <;> simp +decide [ PowerSeries.coeff_C, PowerSeries.coeff_X_pow ];
    · erw [ PowerSeries.coeff_C_mul, PowerSeries.coeff_X_pow ] ; aesop;
    · intro x hx; erw [ PowerSeries.coeff_C ] ; aesop;

/-- **Local Euler Factor Identity (global form)**.

The product of the Euler polynomial `1 - a(p)·T + p·T²` and the local
generating series `G_p(T)` is the multiplicative identity in the power
series ring. This is the key transfer-function identity connecting
automorphic forms to rational spectral theory. -/
theorem local_euler_factor_identity
    {p : ℕ} (hp : Nat.Prime p) :
    pkt.eulerPolySeries p * pkt.localSeries p = 1 := by
  ext n
  simp only [PowerSeries.coeff_one]
  exact pkt.local_euler_factor_coeffwise hp n

end UnramifiedHeckePacket