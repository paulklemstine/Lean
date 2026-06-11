import Speculative.AutoResearch.FibonacciApparition

/-! # The lattice structure of the Fibonacci rank of apparition

Domain: Number Theory / Applications (extends the catalog's Fibonacci entry-point theory).

This file **extends** the entry-point theory of
`Catalog/Speculative/AutoResearch/FibonacciApparition.lean`
(`FibonacciApparition.fibEntry`, the law of apparition
`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`, and the totality result
`FibonacciApparition.exists_pos_dvd_fib`).

The catalog already records the **coprime** multiplicativity
`fibEntry (a * b) = lcm (fibEntry a) (fibEntry b)` for `Coprime a b`
(`Catalog/Novelty/FibonacciEntryPointInvariant.lean`, `fibEntry_mul_coprime`).
Here we remove the coprimality hypothesis entirely and pin down the *full* lattice
behaviour of `fibEntry` as a map from the divisibility lattice of moduli to that of
indices:

* `fibEntry_lcm` — **the unrestricted join (lcm) law**
  `fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)` for all `a, b > 0`.
  This strictly generalizes `fibEntry_mul_coprime` (take `a, b` coprime, so
  `lcm a b = a * b`).
* `fibEntry_monotone` — `a ∣ b → fibEntry a ∣ fibEntry b`: the entry point is an
  order-morphism of divisibility posets.
* `fibEntry_gcd_dvd` — the meet (gcd) bound `fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)`.
* `fibEntry_gcd_not_exact` — a **concrete boundary case** (`a = 4, b = 6`) showing the
  meet bound is in general *strict*: `fibEntry` is a join-morphism but **not** a
  meet-morphism. This explains why the lcm law is the sharp one.

The arithmetic backbone is, in every case, the law of apparition
`m ∣ fib k ↔ fibEntry m ∣ k`, which converts statements about Fibonacci divisibility into
statements about divisibility of indices, where lattice identities are elementary.
-/

namespace FibonacciApparitionLattice

open FibonacciApparition

/-- Two naturals that are divisibility-equivalent (`d ∣ k ↔ e ∣ k` for all `k`) coincide. -/
-- !-- Apply the equivalence at `k = e` and `k = d` and use antisymmetry of `∣`. -- !--
lemma nat_eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-! ## §1. The join (lcm) law -/

/-
!-- For each `k`, `lcm a b ∣ fib k ↔ (a ∣ fib k ∧ b ∣ fib k)` by `Nat.lcm_dvd_iff`;
the law of apparition turns each conjunct into `fibEntry _ ∣ k`, and `Nat.lcm_dvd_iff`
repackages the pair as `lcm (fibEntry a) (fibEntry b) ∣ k`. Divisibility-equivalence
(`nat_eq_of_dvd_iff`) gives the equality. -- !--

**Unrestricted join law for the rank of apparition.** For all `a, b > 0`,
`fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)`. Removes the coprimality hypothesis
from `FibonacciEntryPointInvariant.fibEntry_mul_coprime`.

!-- Via the law of apparition, both sides have the same divisors `k`: `lcm a b ∣ fib k ↔ fibEntry a ∣ k ∧ fibEntry b ∣ k ↔ lcm(fibEntry a)(fibEntry b) ∣ k`. -- !--
-/
theorem fibEntry_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    fibEntry (Nat.lcm a b) = Nat.lcm (fibEntry a) (fibEntry b) := by
  refine' Nat.dvd_antisymm _ _;
  · refine' FibonacciApparition.fib_dvd_iff_fibEntry_dvd _ ( Nat.lcm_pos ha hb ) _ |>.1 _;
    exact Nat.lcm_dvd ( FibonacciApparition.fib_dvd_iff_fibEntry_dvd _ ha _ |>.2 ( Nat.dvd_lcm_left _ _ ) ) ( FibonacciApparition.fib_dvd_iff_fibEntry_dvd _ hb _ |>.2 ( Nat.dvd_lcm_right _ _ ) );
  · refine' Nat.lcm_dvd _ _;
    · exact FibonacciApparition.fib_dvd_iff_fibEntry_dvd a ha _ |>.1 ( Nat.dvd_trans ( Nat.dvd_lcm_left _ _ ) ( FibonacciApparition.fibEntry_dvd_fib _ ( Nat.lcm_pos ha hb ) ) );
    · exact FibonacciApparition.fib_dvd_iff_fibEntry_dvd _ hb _ |>.1 ( Nat.dvd_trans ( Nat.dvd_lcm_right _ _ ) ( FibonacciApparition.fibEntry_dvd_fib _ ( Nat.lcm_pos ha hb ) ) )

/-! ## §2. Monotonicity: an order-morphism of divisibility posets -/

/-
!-- `b ∣ fib (fibEntry b)` and `a ∣ b` give `a ∣ fib (fibEntry b)`; the law of apparition
(needing `a > 0`, which follows from `a ∣ b` and `b > 0`) yields `fibEntry a ∣ fibEntry b`. -- !--

**Monotonicity of the rank of apparition.** If `a ∣ b` (with `b > 0`) then
`fibEntry a ∣ fibEntry b`.

!-- `a ∣ b ∣ fib (fibEntry b)`, so by the law of apparition `fibEntry a ∣ fibEntry b`. -- !--
-/
theorem fibEntry_monotone {a b : ℕ} (hb : 0 < b) (hab : a ∣ b) :
    fibEntry a ∣ fibEntry b := by
  by_cases ha : 0 < a;
  · exact FibonacciApparition.fib_dvd_iff_fibEntry_dvd a ha ( fibEntry b ) |>.1 ( dvd_trans hab ( FibonacciApparition.fibEntry_dvd_fib b hb ) );
  · aesop

/-! ## §3. The meet (gcd) bound -/

/-
!-- `gcd a b ∣ a` and `gcd a b ∣ b`, so by `fibEntry_monotone`,
`fibEntry (gcd a b)` divides both `fibEntry a` and `fibEntry b`, hence their gcd. -- !--

**Meet bound for the rank of apparition.** For `a, b > 0`,
`fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)`.

!-- `gcd a b` divides `a` and `b`; monotonicity sends this to `fibEntry (gcd a b)` dividing both `fibEntry a`, `fibEntry b`, hence their gcd. -- !--
-/
theorem fibEntry_gcd_dvd {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    fibEntry (Nat.gcd a b) ∣ Nat.gcd (fibEntry a) (fibEntry b) := by
  refine' Nat.dvd_gcd _ _;
  · exact fibEntry_monotone ha ( Nat.gcd_dvd_left _ _ );
  · exact fibEntry_monotone hb ( Nat.gcd_dvd_right _ _ )

/-! ## §4. The meet bound is strict — a boundary case -/

/-
Characterisation used to compute concrete entry points: if `m > 0` divides `fib n`
at a positive index `n` and at no smaller positive index, then `fibEntry m = n`.

!-- `fibEntry_le` gives `fibEntry m ≤ n`; if it were `< n` then `m ∣ fib (fibEntry m)`
(by `fibEntry_dvd_fib`) at a smaller positive index contradicts the hypothesis. -- !--
-/
lemma fibEntry_eq {m n : ℕ} (hn : 0 < n) (hmn : m ∣ Nat.fib n)
    (hmin : ∀ k, 0 < k → k < n → ¬ m ∣ Nat.fib k) : fibEntry m = n := by
  unfold fibEntry;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]

/-
!-- Compute `fibEntry 4 = 6`, `fibEntry 6 = 12`, `fibEntry 2 = 3` via `fibEntry_eq`
(checking small Fibonacci values by `decide`), then observe `gcd 4 6 = 2` so the meet bound
reads `3 ∣ gcd 6 12 = 6`, which is proper. -- !--

**The meet bound is strict.** Taking `a = 4`, `b = 6`: `fibEntry (gcd 4 6) = fibEntry 2 = 3`
whereas `gcd (fibEntry 4) (fibEntry 6) = gcd 6 12 = 6`. Hence `fibEntry` is a join-morphism
(`fibEntry_lcm`) but **not** a meet-morphism — the divisibility in `fibEntry_gcd_dvd` cannot
be upgraded to equality.

!-- `fibEntry 4 = 6`, `fibEntry 6 = 12`, `fibEntry 2 = 3`, `gcd 4 6 = 2`, `gcd 6 12 = 6`, and `3 ≠ 6`. -- !--
-/
theorem fibEntry_gcd_not_exact :
    fibEntry (Nat.gcd 4 6) ≠ Nat.gcd (fibEntry 4) (fibEntry 6) := by
  -- Compute the three entry points with fibEntry_eq.
  have h4 : fibEntry 4 = 6 := by
    -- By definition of `fibEntry`, we know that `fibEntry 4` is the smallest positive integer `k` such that `4 ∣ F k`.
    apply fibEntry_eq (by decide) (by decide) (by intro k hk1 hk2; interval_cases k <;> decide)
  have h6 : fibEntry 6 = 12 := by
    apply fibEntry_eq <;> norm_num;
    intro k hk hk'; interval_cases k <;> trivial;
  have h2 : fibEntry 2 = 3 := by
    -- Apply the fibEntry_eq lemma with m = 2 and n = 3.
    apply fibEntry_eq (by decide) (by decide) (by intro k hk1 hk2; interval_cases k <;> decide);
  norm_num [ h4, h6, h2 ]

end FibonacciApparitionLattice