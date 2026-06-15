import Mathlib

/-! # Strong divisibility sequences: abstract primitive divisors and apparition

Domain: Algebra / Number Theory (Applications).

This file **generalizes** the Fibonacci-specific results of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` to *arbitrary strong divisibility
sequences*.  A sequence `u : ℕ → ℕ` is a **strong divisibility sequence** (`IsStrongDivSeq`)
when `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.  The Fibonacci file used **only** the
two facts `Nat.fib_gcd` and `Nat.fib_dvd`; both are instances of this single hypothesis, so
the entire primitivity/apparition theory lifts verbatim.  This realizes **Direction 3** of the
previous cycle's `FUTURE_DIRECTIONS.md` ("Abstract strong divisibility sequences") and, via the
counting corollaries, **Direction 5** ("Counting simultaneous apparitions / density").

Two concrete instances are recorded:

* `fib_isStrongDivSeq`     — the Fibonacci sequence `Nat.fib` (from `Nat.fib_gcd`); this
  recovers every result of `FibonacciPrimitiveDivisors`.
* `mersenne_isStrongDivSeq`— the sequence `n ↦ a ^ n - 1` (from
  `Nat.pow_sub_one_gcd_pow_sub_one`), i.e. the Mersenne / `aⁿ−1` family.

Main results (all stated for an arbitrary `u`):

* `IsStrongDivSeq.dvd_of_dvd`         — `m ∣ n → u m ∣ u n` (the weak divisibility law).
* `IsStrongDivSeq.dvd_gcd_index_iff`  — the sharp meet law `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n`.
* `isPrimitive_unique`                — a value is primitive for at most one positive index.
* `dvd_iff_index_dvd_of_primitive`    — a primitive divisor pins divisibility to multiples of its index.
* `simultaneous_apparition`           — the join law `(p ∣ u n ∧ q ∣ u n) ↔ lcm a b ∣ n`.
* `simultaneous_apparition_finset`    — the finite-family generalization.
* `apparition_count`                  — `#{e < N : p ∣ u (e+1)} = N / n` (density `1/n`).
* `simultaneous_apparition_count`     — `#{e < N : p ∣ u(e+1) ∧ q ∣ u(e+1)} = N / lcm a b`.
-/

namespace StrongDivSeq

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy this. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop :=
  ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-- `p` is a *primitive divisor* of `u n`: it divides `u n` but none of `u 1, …, u (n-1)`. -/
def IsPrimitive (u : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ u n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ u k

/-! ## §1. Elementary consequences of the strong-divisibility law -/

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_of_dvd -- !--
!-- Hypothesis: A strong divisibility sequence is in particular a divisibility sequence:
`m ∣ n → u m ∣ u n` (generalizing `Nat.fib_dvd`). -- !--
!-- Result: Proved. `m ∣ n` gives `gcd m n = m`, so `u m = u (gcd m n) = gcd (u m) (u n)`
divides `u n` by `Nat.gcd_dvd_right`. -- !--
!-- Insight: The *weak* law (Mathlib's `Nat.fib_dvd`) is a free corollary of the *strong* law;
no extra hypothesis is needed. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
      -- Since m divides n, we know that gcd m n = m (by Nat.gcd_eq_left h).
      have h_gcd : Nat.gcd m n = m := by
        exact Nat.gcd_eq_left h;
      convert hu m n ▸ Nat.gcd_dvd_right _ _ using 1 ; aesop

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_gcd_index_iff -- !--
!-- Hypothesis: For ANY divisor `d`, `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n`
(generalizing `FibonacciPrimitiveDivisors.fib_dvd_gcd_iff`). -- !--
!-- Result: Proved by rewriting with the strong-divisibility law and `Nat.dvd_gcd_iff`. -- !--
!-- Insight: This is the lattice "meet" law at the level of raw divisors, valid in every
strong divisibility sequence. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
theorem IsStrongDivSeq.dvd_gcd_index_iff {u : ℕ → ℕ} (hu : IsStrongDivSeq u) (d m n : ℕ) :
    d ∣ u (Nat.gcd m n) ↔ d ∣ u m ∧ d ∣ u n := by
      rw [ hu m n, Nat.dvd_gcd_iff ]

/-! ## §2. Rigidity: a value is primitive for at most one index -/

/-
!-- Lab Notebook: isPrimitive_zero_everything -- !--
!-- Hypothesis: Every modulus is vacuously primitive at index `0`. -- !--
!-- Result: Proved: `p ∣ u 0 ... ` need not hold for general `u`! Instead the minimality
clause is vacuous; but `p ∣ u 0` requires `u 0 = 0`. We therefore require `u 0 = 0`. -- !--
!-- Insight: For Fibonacci `u 0 = 0` automatically; in the abstract setting the boundary
fact needs `u 0 = 0` as a hypothesis, pinning down why positivity is required elsewhere. -- !--
!-- Failure analysis: dropping `u 0 = 0` makes index-0 primitivity fail. -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_zero_everything {u : ℕ → ℕ} (h0 : u 0 = 0) (p : ℕ) :
    IsPrimitive u p 0 := by
      exact ⟨ h0.symm ▸ dvd_zero _, by intros; linarith ⟩

/-
!-- Lab Notebook: isPrimitive_unique -- !--
!-- Hypothesis: A value cannot be a primitive divisor of two different positive indices. -- !--
!-- Result: Proved by a direct minimality clash; NO strong-divisibility hypothesis needed.
If `m < n`, primitivity at `n` forbids `p ∣ u m`, contradicting primitivity at `m`. -- !--
!-- Insight: Primitivity is so rigid that uniqueness is immediate from the definition. -- !--
!-- Failure analysis: index 0 must be excluded (see isPrimitive_zero_everything). -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_unique {u : ℕ → ℕ} {p m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitive u p m) (hpn : IsPrimitive u p n) : m = n := by
      grind +locals

/-! ## §3. A primitive divisor pins down the divisibility set -/

/-
!-- Lab Notebook: dvd_iff_index_dvd_of_primitive -- !--
!-- Hypothesis: If `p` is primitive for `u n` then `p ∣ u m ↔ n ∣ m`
(generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`). -- !--
!-- Result: Proved. Backward: `n ∣ m → u n ∣ u m` (`dvd_of_dvd`), and `p ∣ u n`.
Forward: from `p ∣ u m, u n` get `p ∣ u (gcd n m)` (meet law); minimality forces
`gcd n m = n`, i.e. `n ∣ m`. -- !--
!-- Insight: Primitivity upgrades the abstract apparition law to a concrete divisibility
test, derived straight from the meet law. -- !--
!-- Failure analysis: needs the strong-divisibility hypothesis (for the meet law) and `0<n`. -- !--
!-- End Lab Notebook -- !--
-/
theorem dvd_iff_index_dvd_of_primitive {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p n : ℕ}
    (hn : 0 < n) (hp : IsPrimitive u p n) (m : ℕ) :
    p ∣ u m ↔ n ∣ m := by
      constructor;
      · intro hpm
        have h_gcd : p ∣ u (Nat.gcd n m) := by
          exact hu.dvd_gcd_index_iff p n m |>.2 ⟨ hp.1, hpm ⟩
        have h_gcd_eq : Nat.gcd n m = n := by
          exact Classical.not_not.1 fun h => hp.2 _ ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_ne ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) h ) h_gcd
        exact h_gcd_eq ▸ Nat.gcd_dvd_right _ _;
      · exact fun h => dvd_trans hp.1 ( hu.dvd_of_dvd h )

/-! ## §4. Simultaneous apparition: the join law -/

/-
!-- Lab Notebook: simultaneous_apparition -- !--
!-- Hypothesis: For primitive divisors `p` (of `u a`) and `q` (of `u b`), both divide `u n`
exactly at the multiples of `lcm a b`. -- !--
!-- Result: Proved: rewrite each conjunct via `dvd_iff_index_dvd_of_primitive`, then
`Nat.lcm_dvd_iff`. -- !--
!-- Insight: The common-apparition set of two primitive divisors is itself an apparition
class governed by the lcm of the two indices. -- !--
!-- Failure analysis: both indices must be positive. -- !--
!-- End Lab Notebook -- !--
-/
theorem simultaneous_apparition {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p q a b n : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hp : IsPrimitive u p a) (hq : IsPrimitive u q b) :
    (p ∣ u n ∧ q ∣ u n) ↔ Nat.lcm a b ∣ n := by
      grind +suggestions

/-
!-- Lab Notebook: simultaneous_apparition_finset -- !--
!-- Hypothesis: For a finite family with each `f i` primitive for `u (g i)`, all `f i`
divide `u n` iff the lcm of the indices `g i` divides `n`. -- !--
!-- Result: Proved by `Finset.induction` combining `dvd_iff_index_dvd_of_primitive`
with `Nat.lcm_dvd_iff` and `Finset.lcm_insert`. -- !--
!-- Insight: Expresses the full common-apparition set of a family as a single apparition class. -- !--
!-- Failure analysis: `Finset.lcm ∅ = 1 ∣ n` handles the base case. -- !--
!-- End Lab Notebook -- !--
-/
theorem simultaneous_apparition_finset {u : ℕ → ℕ} (hu : IsStrongDivSeq u)
    {ι : Type*} (s : Finset ι) (f g : ι → ℕ)
    (hpos : ∀ i ∈ s, 0 < g i) (hprim : ∀ i ∈ s, IsPrimitive u (f i) (g i)) (n : ℕ) :
    (∀ i ∈ s, f i ∣ u n) ↔ (s.lcm g) ∣ n := by
      constructor <;> intro h;
      · exact Finset.lcm_dvd fun i hi => dvd_iff_index_dvd_of_primitive hu ( hpos i hi ) ( hprim i hi ) n |>.1 ( h i hi );
      · exact fun i hi => dvd_iff_index_dvd_of_primitive hu ( hpos i hi ) ( hprim i hi ) n |>.2 ( dvd_trans ( Finset.dvd_lcm hi ) h )

/-! ## §5. Counting / density of apparition indices (Direction 5) -/

/-
!-- Lab Notebook: apparition_count -- !--
!-- Hypothesis: Among the first `N` positive indices, exactly `N / n` of them are apparition
indices of a primitive divisor `p` of `u n`. -- !--
!-- Result: Proved: `dvd_iff_index_dvd_of_primitive` turns the filter predicate
`p ∣ u (e+1)` into `n ∣ (e+1)`, and `Nat.card_multiples` counts those as `N / n`. -- !--
!-- Insight: The natural-density of apparition indices of a primitive divisor of index `n`
is exactly `1/n`; this is the quantitative face of the pinning law. -- !--
!-- Failure analysis: uses the `+1` shift so that index `0` (where everything divides) is
excluded, matching `Nat.card_multiples`. -- !--
!-- End Lab Notebook -- !--
-/
theorem apparition_count {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p n : ℕ}
    (hn : 0 < n) (hp : IsPrimitive u p n) (N : ℕ) :
    {e ∈ Finset.range N | p ∣ u (e + 1)}.card = N / n := by
      convert Nat.card_multiples N n using 1;
      congr 1 with e ; simp +decide [ dvd_iff_index_dvd_of_primitive hu hn hp ]

/-
!-- Lab Notebook: simultaneous_apparition_count -- !--
!-- Hypothesis: Among the first `N` positive indices, exactly `N / lcm a b` are joint
apparition indices of primitive divisors `p` (of `u a`) and `q` (of `u b`). -- !--
!-- Result: Proved: `simultaneous_apparition` turns the joint predicate into
`lcm a b ∣ (e+1)`, then `Nat.card_multiples`. -- !--
!-- Insight: Joint apparition has density `1 / lcm a b`, connecting the apparition lattice
to analytic density. -- !--
!-- Failure analysis: same `+1` shift convention as `apparition_count`. -- !--
!-- End Lab Notebook -- !--
-/
theorem simultaneous_apparition_count {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p q a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hp : IsPrimitive u p a) (hq : IsPrimitive u q b) (N : ℕ) :
    {e ∈ Finset.range N | p ∣ u (e + 1) ∧ q ∣ u (e + 1)}.card = N / Nat.lcm a b := by
      have h_filter : {e ∈ Finset.range N | p ∣ u (e + 1) ∧ q ∣ u (e + 1)} = {e ∈ Finset.range N | Nat.lcm a b ∣ (e + 1)} := by
        ext e; simp [simultaneous_apparition hu ha hb hp hq];
      rw [ h_filter, Nat.card_multiples ]

/-! ## §6. Concrete instances: Fibonacci and Mersenne (`aⁿ − 1`) -/

/-
!-- Lab Notebook: fib_isStrongDivSeq -- !--
!-- Hypothesis: `Nat.fib` is a strong divisibility sequence. -- !--
!-- Result: Immediate from `Nat.fib_gcd`. -- !--
!-- Insight: Every theorem above instantiates to the Fibonacci results of the previous cycle. -- !--
!-- End Lab Notebook -- !--
-/
theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := by
  -- By definition of IsStrongDivSeq, we need to show that for all m and n, Nat.fib (Nat.gcd m n) = Nat.gcd (Nat.fib m) (Nat.fib n).
  intro m n
  apply Nat.fib_gcd

/-
!-- Lab Notebook: mersenne_isStrongDivSeq -- !--
!-- Hypothesis: For any base `a`, the sequence `n ↦ aⁿ − 1` is a strong divisibility sequence. -- !--
!-- Result: Immediate from `Nat.pow_sub_one_gcd_pow_sub_one`. -- !--
!-- Insight: The same primitivity/apparition theory governs Mersenne-type sequences,
a genuine cross-domain consolidation. -- !--
!-- End Lab Notebook -- !--
-/
theorem mersenne_isStrongDivSeq (a : ℕ) : IsStrongDivSeq (fun n => a ^ n - 1) := by
  intro m n; by_cases ha : a = 0 <;> simp_all +decide [ Nat.pow_sub_one_gcd_pow_sub_one ] ;

end StrongDivSeq