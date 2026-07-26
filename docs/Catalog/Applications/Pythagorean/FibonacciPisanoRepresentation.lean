import Mathlib

/-!
# The Pisano period as the order of the Fibonacci shift: a representation/duality view

For a modulus `m ≥ 1` the **Pisano period** `π(m)` is the period of the Fibonacci
sequence taken modulo `m`.  This file isolates `π(m)` as a *representation-theoretic*
object: it is exactly the **order of a single group element**, the Fibonacci shift

`Q : (a, b) ↦ (b, a + b)`

viewed as a permutation of the finite set `ZMod m × ZMod m`.  Under this dictionary the
*dynamics* of the Fibonacci recurrence becomes the *algebra* of a cyclic subgroup of
`Equiv.Perm (ZMod m × ZMod m)`, and several facts that look analytic (periodicity) or
combinatorial become one-line consequences of `orderOf` theory.

This is the duality/representation companion to the catalog's *entry-point* (rank of
apparition) theory:

* `FibApparition` (`Catalog/Novelty/FibApparitionExistence.lean`) builds the entry point
  `z(m)` — least `k > 0` with `m ∣ F k` — and the ideal law `m ∣ F n ↔ z(m) ∣ n`.
* `FibEntryChar` (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
  `Catalog/Novelty/FibonacciEntryPointMultiplicative.lean`) develops the multiplicative
  lcm-algebra of the entry point.

The new organizing object here is `pisanoPeriod m := orderOf (fibStep m)`.  Its relation
to the entry point is `dvd_fib_pisanoPeriod` (`m ∣ F(π m)`, hence `z(m) ∣ π(m)` via the
catalog law `FibApparition.fib_dvd_iff_apparitionRank_dvd`), and the
crowning result `pisano_mul_coprime` is the **Chinese-Remainder/spectral
decomposition** `π(mn) = lcm(π m, π n)` for coprime moduli — the product dynamical
system factors as a product of its prime-power "spectral" components, exactly mirroring
the entry point's lcm law `FibEntryChar.fibEntryPt_prod_coprime`.

-- !-- Lab Notebook -- !--
-- !-- Hypothesis: the Pisano period is not merely "the period of a sequence" but the
--     order of the shift automorphism Q in Perm(ZMod m × ZMod m); hence periodicity,
--     the entry-point bound, and CRT-multiplicativity should all follow from generic
--     `orderOf` machinery plus the closed iterate formula for Q^k. -- !--
-- !-- Result: proved the closed form Q^[k](a,b) = (a F(k-1)+b F k, a F k + b F(k+1)),
--     the divisibility duality π(m) ∣ k ↔ (F k ≡ 0 ∧ F(k+1) ≡ 1) (mod m), periodicity,
--     z(m) ∣ π(m), and π(mn) = lcm(π m, π n) for coprime m, n. -- !--
-- !-- Insight: ALL Fibonacci content is concentrated in one induction (the iterate
--     formula `fibStep_iterate_apply`); after that the period is pure group theory, and
--     CRT-multiplicativity is just `Nat.Coprime.mul_dvd` distributed across a `dvd`-iff. -- !--
-- !-- Failure analysis: the only friction is bookkeeping the `ZMod` ↔ `ℕ` casts for the
--     condition `F(k+1) ≡ 1`; phrasing the CRT step through `Nat` divisibility of
--     `F k` and `F(k+1) - 1` (using `1 ≤ F(k+1)`) removes it entirely. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibPisano

open scoped Classical

/-- The Fibonacci **shift** automorphism on `ZMod m × ZMod m`, `(a, b) ↦ (b, a + b)`,
with inverse `(a, b) ↦ (b - a, a)`.  Iterating it from `(0, 1)` reads off consecutive
Fibonacci numbers, so the entire Fibonacci sequence mod `m` is the orbit of this single
group element. -/
def fibStep (m : ℕ) : Equiv.Perm (ZMod m × ZMod m) where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

/-- The **Pisano period** of `m`: the order of the Fibonacci shift in the (finite for
`m ≥ 1`) permutation group of `ZMod m × ZMod m`. -/
noncomputable def pisanoPeriod (m : ℕ) : ℕ := orderOf (fibStep m)

/-
!-- Closed form for the k-th iterate of the shift, by induction on k using
`Function.iterate_succ_apply'` and `Nat.fib_add_two`; this is the only step that
touches the Fibonacci recurrence. -- !--

Closed form: the `k`-th power of the shift is the Fibonacci `Q^k` matrix acting on
`(a, b)`.
-/
theorem fibStep_iterate_apply (m k : ℕ) (a b : ZMod m) :
    (⇑(fibStep m))^[k] (a, b) =
      (a * ((Nat.fib (k + 1) : ZMod m) - (Nat.fib k : ZMod m)) + b * (Nat.fib k : ZMod m),
       a * (Nat.fib k : ZMod m) + b * (Nat.fib (k + 1) : ZMod m)) := by
  induction' k with k ih generalizing a b
  · simp
  · rw [Function.iterate_succ_apply', ih]
    simp only [fibStep, Equiv.coe_fn_mk, Nat.fib_add_two]
    push_cast
    rw [Prod.mk.injEq]
    exact ⟨by ring, by ring⟩

/-
!-- Representation theorem: specialize the closed form at (a,b) = (0,1). -- !--

**Representation of the Fibonacci sequence as a group orbit.** Iterating the shift
from `(0, 1)` yields consecutive Fibonacci numbers mod `m`.
-/
theorem fibStep_iterate (m k : ℕ) :
    (⇑(fibStep m))^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply', Nat.fib_add_two ];
  rfl

/-
For `m ≥ 1` the shift has positive (finite) order: the Pisano period exists.
-/
theorem pisanoPeriod_pos (m : ℕ) [NeZero m] : 0 < pisanoPeriod m := by
  convert Nat.pos_of_ne_zero _;
  -- Since `fibStep m` is a permutation of a finite set, it must have finite order.
  have h_finite_order : ∃ k > 0, (fibStep m) ^ k = 1 := by
    exact ⟨ orderOf ( fibStep m ), orderOf_pos _, pow_orderOf_eq_one _ ⟩;
  exact Nat.ne_of_gt ( Nat.pos_of_dvd_of_pos ( orderOf_dvd_iff_pow_eq_one.mpr h_finite_order.choose_spec.2 ) h_finite_order.choose_spec.1 )

/-
!-- The power Q^k is the identity permutation iff it fixes (0,1) (forward: apply at
(0,1) via `fibStep_iterate`; backward: the closed form with F k = 0, F(k+1) = 1
collapses to the identity, then `Equiv.Perm.ext`). -- !--

The shift power `Q^k` is trivial iff the sequence has returned to its seed:
`F k ≡ 0` and `F(k+1) ≡ 1` (mod `m`).
-/
theorem fibStep_pow_eq_one_iff (m k : ℕ) :
    (fibStep m) ^ k = 1 ↔
      ((Nat.fib k : ZMod m) = 0 ∧ (Nat.fib (k + 1) : ZMod m) = 1) := by
  constructor;
  · intro h
    have h_fib : (fibStep m)^[k] (0, 1) = (0, 1) := by
      convert congr_arg ( fun f : Equiv.Perm ( ZMod m × ZMod m ) => f ( 0, 1 ) ) h using 1;
    rw [ fibStep_iterate ] at h_fib ; aesop;
  · intro h;
    ext ⟨ a, b ⟩;
    · convert fibStep_iterate_apply m k a b |> congr_arg Prod.fst using 1;
      aesop;
    · convert congr_arg Prod.snd ( fibStep_iterate_apply m k a b ) using 1 ; aesop

/-
!-- Combine `orderOf_dvd_iff_pow_eq_one` with `fibStep_pow_eq_one_iff`. -- !--

**Period–return duality.** The Pisano period divides `k` exactly when the Fibonacci
sequence mod `m` has returned to its initial value at index `k`.
-/
theorem pisano_dvd_iff (m k : ℕ) :
    pisanoPeriod m ∣ k ↔
      ((Nat.fib k : ZMod m) = 0 ∧ (Nat.fib (k + 1) : ZMod m) = 1) := by
  rw [ ← fibStep_pow_eq_one_iff ];
  convert orderOf_dvd_iff_pow_eq_one using 1

/-
!-- Use the orbit description: Q^[n+π](0,1) = Q^[π](Q^[n](0,1)) = Q^[n](0,1) since
Q^π = 1; read off the first coordinate. -- !--

**Periodicity.** The Fibonacci sequence mod `m` is periodic with period `π(m)`.
-/
theorem fib_pisano_periodic (m n : ℕ) :
    (Nat.fib (n + pisanoPeriod m) : ZMod m) = (Nat.fib n : ZMod m) := by
  convert congr_arg Prod.fst ( fibStep_iterate m n ) using 1;
  convert congr_arg Prod.fst ( fibStep_iterate m ( n + orderOf ( fibStep m ) ) ) using 1;
  · rw [ fibStep_iterate ];
    rfl;
  · convert congr_arg Prod.fst ( fibStep_iterate m ( n + orderOf ( fibStep m ) ) ) using 1;
    simp +decide [ pow_add, pow_orderOf_eq_one ]

/-
!-- π(m) divides itself, so `pisano_dvd_iff` gives F(π m) ≡ 0 (mod m), i.e. m ∣ F(π m);
thus π(m) is an apparition index and the entry point z(m) divides it. -- !--

The Pisano period is an apparition index: `m ∣ F(π m)`.  Hence (via the catalog law
`FibApparition.fib_dvd_iff_apparitionRank_dvd`) the entry point `z(m)` divides `π(m)`.
-/
theorem dvd_fib_pisanoPeriod (m : ℕ) : m ∣ Nat.fib (pisanoPeriod m) := by
  by_contra h_contra;
  apply_mod_cast h_contra <| by have := pisano_dvd_iff m ( pisanoPeriod m ) |>.1 ( dvd_refl _ ) ; exact by simpa [ ← ZMod.natCast_eq_zero_iff ] using this.1;

/-- Helper: a natural number is determined by the principal ideal it generates. -/
theorem nat_eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-
!-- For coprime m, n: π(mn) ∣ k ↔ (mn ∣ F k ∧ mn ∣ F(k+1)-1) ↔ (m and n each divide
both) ↔ π(m) ∣ k ∧ π(n) ∣ k ↔ lcm(π m, π n) ∣ k, using `Nat.Coprime.mul_dvd_of_dvd_of_dvd`,
`ZMod.natCast_eq_zero_iff`, `Nat.modEq_iff_dvd'` (1 ≤ F(k+1)) and `Nat.lcm_dvd_iff`. -- !--

**Chinese-Remainder / spectral decomposition of the Pisano period.** For coprime
moduli the period of the product is the lcm of the periods — the product dynamical
system factors as the product of its components.
-/
theorem pisano_mul_coprime (m n : ℕ) (hmn : Nat.Coprime m n) :
    pisanoPeriod (m * n) = Nat.lcm (pisanoPeriod m) (pisanoPeriod n) := by
  apply nat_eq_of_dvd_iff;
  intro k; rw [ Nat.lcm_dvd_iff ] ;
  -- By definition of Pisano period, we know that `pisanoPeriod d ∣ k` if and only if `d ∣ Nat.fib k` and `d ∣ Nat.fib (k + 1) - 1`.
  have h_def : ∀ d : ℕ, pisanoPeriod d ∣ k ↔ d ∣ Nat.fib k ∧ d ∣ Nat.fib (k + 1) - 1 := by
    intro d
    rw [pisano_dvd_iff];
    rcases x : Nat.fib ( k + 1 ) with ( _ | _ | k ) <;> simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
  simp +decide only [h_def];
  constructor <;> intro h;
  · exact ⟨ ⟨ dvd_of_mul_right_dvd h.1, dvd_of_mul_right_dvd h.2 ⟩, dvd_of_mul_left_dvd h.1, dvd_of_mul_left_dvd h.2 ⟩;
  · exact ⟨ Nat.Coprime.mul_dvd_of_dvd_of_dvd hmn h.1.1 h.2.1, Nat.Coprime.mul_dvd_of_dvd_of_dvd hmn h.1.2 h.2.2 ⟩

end FibPisano