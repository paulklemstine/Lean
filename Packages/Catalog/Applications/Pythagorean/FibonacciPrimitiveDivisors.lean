import Mathlib

/-! # Primitive prime divisors and simultaneous apparition of Fibonacci numbers

Domain: Number Theory / Applications.

This file is a **self-contained** companion to the catalog's Fibonacci entry-point theory
(`Catalog/Applications/FibonacciEntryPoints.lean`, which defines `entryPoint` and the law of
apparition, and `Catalog/Applications/FibonacciApparitionLattice.lean`, which studies how the
rank of apparition interacts with `gcd`/`lcm` of *moduli*).  Those files study the rank of
apparition of a single modulus; here we focus on **primitivity** and on **several** moduli at
once, and — crucially — we prove everything *directly from the strong-divisibility property of
the Fibonacci sequence* (`Nat.fib_gcd`, `Nat.fib_dvd`), without ever computing an entry point.
That makes the central rigidity result (`isPrimitive_unique`) follow from a one-line
minimality argument rather than from the machinery of `Nat.find`.

Main results:

* `fib_dvd_gcd_iff`           — the sharp **strong-divisibility meet law** valid for an
  *arbitrary* divisor `d`:  `d ∣ F_{gcd m n} ↔ d ∣ F_m ∧ d ∣ F_n`.
* `isPrimitive_unique`        — a value is a primitive divisor of **at most one** positive
  index (`IsPrimitive p m → IsPrimitive p n → m = n`, for `m, n > 0`); the rigidity that makes
  the rank of apparition a well-defined labelling.
* `dvd_fib_iff_index_dvd_of_primitive` — if `p` is primitive for `F_n` then `p ∣ F_m ↔ n ∣ m`:
  a primitive divisor pins the entire divisibility set to the multiples of its index.
* `simultaneous_apparition`   — the **join law**: if `p` is primitive for `F_a` and `q` for
  `F_b`, then `(p ∣ F_n ∧ q ∣ F_n) ↔ lcm a b ∣ n`.
* `simultaneous_apparition_finset` — the finite-family generalization of
  `simultaneous_apparition`, by induction over the family with `Nat.lcm_dvd_iff`.
-/

namespace FibonacciPrimitiveDivisors

/-- `p` is a *primitive divisor* of `F_n`: it divides `F_n` but none of the earlier
Fibonacci numbers `F_1, …, F_{n-1}`.  (Same notion as `FibonacciEntryPoints.IsPrimitive`.) -/
def IsPrimitive (p n : ℕ) : Prop :=
  p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

/-! ## §1. The strong-divisibility meet law (arbitrary divisor) -/

/-
!-- Lab Notebook: fib_dvd_gcd_iff -- !--
!-- Hypothesis: Fibonacci divisibility at a gcd index is equivalent to joint divisibility,
for ANY divisor `d` (no primality), because `F` is a strong divisibility sequence. -- !--
!-- Result: Proved. Forward: `gcd m n ∣ m, n` gives `F_{gcd} ∣ F_m, F_n` (`Nat.fib_dvd`),
so `d ∣ F_{gcd}` divides both. Backward: `Nat.fib_gcd` rewrites `F_{gcd m n}` to
`gcd (F_m) (F_n)`, then `Nat.dvd_gcd`. -- !--
!-- Insight: This is the lattice "meet" law at the level of raw divisors — the sharpest
form of the gcd bridge, with no entry-point apparatus. -- !--
!-- Failure analysis: none; only requires recalling `Nat.fib_gcd` and `Nat.fib_dvd`. -- !--
!-- End Lab Notebook -- !--

!-- (→) `gcd m n ∣ m, n`, so `F_{gcd m n} ∣ F_m, F_n` (`Nat.fib_dvd`); transitivity from
`d ∣ F_{gcd m n}`. (←) `Nat.fib_gcd : F_{gcd m n} = gcd (F_m) (F_n)` then `Nat.dvd_gcd`. -- !--
-/
theorem fib_dvd_gcd_iff (d m n : ℕ) :
    d ∣ Nat.fib (Nat.gcd m n) ↔ d ∣ Nat.fib m ∧ d ∣ Nat.fib n := by
  rw [ Nat.fib_gcd ];
  exact Nat.dvd_gcd_iff

/-! ## §2. Rigidity: a value is primitive for at most one index -/

/-
Boundary case showing positivity is necessary in `isPrimitive_unique`: at index `0`
every modulus is vacuously primitive, since `F_0 = 0` and the minimality condition is empty.

!-- `p ∣ F_0 = 0` always, and `∀ k, 0 < k → k < 0 → …` is vacuous. -- !--
-/
theorem isPrimitive_zero_everything (p : ℕ) : IsPrimitive p 0 := by
  exact ⟨ dvd_zero _, fun k hk hk' => by linarith ⟩

/-
!-- Lab Notebook: isPrimitive_unique -- !--
!-- Hypothesis: A value cannot be a primitive divisor of two different positive indices. -- !--
!-- Result: Proved by a direct minimality clash, NO entry point needed: if `m < n` then
`p ∣ F_m` (from primitivity at `m`) contradicts the minimality clause of primitivity
at `n` (which forbids divisibility at every positive index `< n`); symmetrically `n < m`
is impossible, so `m = n`. -- !--
!-- Insight: Primitivity is so rigid that uniqueness is immediate from the definition —
the strong-divisibility structure is not even required here. The boundary lemma
`isPrimitive_zero_everything` shows why `0 < m, 0 < n` cannot be dropped. -- !--
!-- Failure analysis: an earlier statement omitting `0 < m, 0 < n` is FALSE (index `0`). -- !--
!-- End Lab Notebook -- !--

!-- If `m < n`, primitivity at `n` gives `¬ p ∣ F_m` while primitivity at `m` gives `p ∣ F_m`,
a contradiction; symmetrically `n < m` is impossible. Hence `m = n`. -- !--
-/
theorem isPrimitive_unique {p m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitive p m) (hpn : IsPrimitive p n) : m = n := by
  grind +locals

/-! ## §3. A primitive divisor pins down the divisibility set -/

/-
!-- Lab Notebook: dvd_fib_iff_index_dvd_of_primitive -- !--
!-- Hypothesis: If `p` is primitive for `F_n` then `p ∣ F_m` exactly at the multiples of `n`. -- !--
!-- Result: Proved directly. Backward: `n ∣ m → F_n ∣ F_m` (`Nat.fib_dvd`), and `p ∣ F_n`.
Forward: from `p ∣ F_m` and `p ∣ F_n` get `p ∣ F_{gcd n m}` (`fib_dvd_gcd_iff`); since
`gcd n m ≤ n` and primitivity forbids divisibility below `n`, the gcd must equal `n`,
i.e. `n ∣ m`. -- !--
!-- Insight: Primitivity upgrades the abstract apparition law to a concrete divisibility
test, derived here straight from the meet law `fib_dvd_gcd_iff`. -- !--
!-- Failure analysis: the `m = 0` case needs separate (trivial) handling since `gcd n 0 = n`. -- !--
!-- End Lab Notebook -- !--

!-- (←) `n ∣ m → F_n ∣ F_m` (`Nat.fib_dvd`) and `p ∣ F_n` give `p ∣ F_m`. (→) `p ∣ F_m, F_n`
give `p ∣ F_{gcd n m}` (`fib_dvd_gcd_iff`); `gcd n m ∣ n` so `gcd n m ≤ n`, and minimality of
primitivity forces `gcd n m = n`, i.e. `n ∣ m`. -- !--
-/
theorem dvd_fib_iff_index_dvd_of_primitive {p n : ℕ} (hn : 0 < n)
    (hp : IsPrimitive p n) (m : ℕ) :
    p ∣ Nat.fib m ↔ n ∣ m := by
  constructor;
  · intro hpm
    have h_gcd : p ∣ Nat.fib (Nat.gcd n m) := by
      exact fib_dvd_gcd_iff p n m |>.2 ⟨ hp.1, hpm ⟩;
    exact Classical.not_not.1 fun h => hp.2 ( Nat.gcd n m ) ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_ne ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) fun con => h <| con ▸ Nat.gcd_dvd_right _ _ ) h_gcd;
  · exact fun h => dvd_trans hp.1 ( Nat.fib_dvd _ _ h )

/-! ## §4. Simultaneous apparition: the join law -/

/-
!-- Lab Notebook: simultaneous_apparition -- !--
!-- Hypothesis: For primitive divisors `p` (of `F_a`) and `q` (of `F_b`), both divide `F_n`
exactly at the multiples of `lcm a b`. -- !--
!-- Result: Proved: rewrite each conjunct via `dvd_fib_iff_index_dvd_of_primitive`
(`p ∣ F_n ↔ a ∣ n`, `q ∣ F_n ↔ b ∣ n`), then `Nat.lcm_dvd_iff`. -- !--
!-- Insight: The common-apparition set of two primitive divisors is itself an apparition
class, governed by the lcm of the two indices — a clean "join" of two divisibility laws. -- !--
!-- Failure analysis: requires both indices positive so the pinning lemma applies. -- !--
!-- End Lab Notebook -- !--

!-- `dvd_fib_iff_index_dvd_of_primitive` turns the two conjuncts into `a ∣ n` and `b ∣ n`;
`Nat.lcm_dvd_iff` repackages the pair as `lcm a b ∣ n`. -- !--
-/
theorem simultaneous_apparition {p q a b n : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hp : IsPrimitive p a) (hq : IsPrimitive q b) :
    (p ∣ Nat.fib n ∧ q ∣ Nat.fib n) ↔ Nat.lcm a b ∣ n := by
  rw [ dvd_fib_iff_index_dvd_of_primitive ha hp, dvd_fib_iff_index_dvd_of_primitive hb hq, Nat.lcm_dvd_iff ]

/-! ## §5. Generalization to a finite family -/

/-
!-- Lab Notebook: simultaneous_apparition_finset -- !--
!-- Hypothesis: For a finite family where each `f i` is primitive for `F_(g i)`, all `f i`
divide `F_n` iff the lcm of the indices `g i` divides `n`. -- !--
!-- Result: Proved by `Finset.induction`: the empty case gives `Finset.lcm ∅ = 1 ∣ n`; the
insert step combines `dvd_fib_iff_index_dvd_of_primitive` with `Nat.lcm_dvd_iff`. -- !--
!-- Insight: This expresses the full common-apparition set of a family as a single
apparition class — the natural endpoint of the two-modulus join law. -- !--
!-- Failure analysis: the only subtlety is `Finset.lcm` over ℕ unfolding via `Finset.lcm_insert`
with `Finset.lcm_empty = 1`. -- !--
!-- End Lab Notebook -- !--

Finite-family generalization of `simultaneous_apparition`: for a finite family in which each
`f i` is a primitive divisor of `F_{g i}`, every `f i` divides `F_n` iff the lcm of the
indices `g i` divides `n`.
-/
theorem simultaneous_apparition_finset {ι : Type*} (s : Finset ι) (f g : ι → ℕ)
    (hpos : ∀ i ∈ s, 0 < g i) (hprim : ∀ i ∈ s, IsPrimitive (f i) (g i)) (n : ℕ) :
    (∀ i ∈ s, f i ∣ Nat.fib n) ↔ (s.lcm g) ∣ n := by
  induction' s using Finset.induction with i s hi ih generalizing n;
  all_goals try exact Classical.decEq _;
  · simp +decide [ Finset.lcm ];
  · simp_all +decide [ Finset.lcm_insert ];
    grind +suggestions

end FibonacciPrimitiveDivisors