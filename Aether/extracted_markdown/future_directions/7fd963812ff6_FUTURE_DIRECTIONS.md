# Future Directions — Entry-Point Duality and Primitive Divisors

## Synthesis

This cycle produced `Speculative/AutoResearch/FibonacciEntryPointDuality.lean`, a
self-contained, `sorry`-free development of the *rank of apparition* (entry point)
`z(p) = fibEntry p` of the Fibonacci sequence and four results built on it:

* `fib_dvd_iff_fibEntry_dvd` — the master biconditional `p ∣ F n ↔ z(p) ∣ n`,
  proved for **arbitrary** `p` (no primality hypothesis);
* `isFibPrimitiveDivisor_iff_entry` — primitivity of a prime `p` for `F n` reduces to
  the single equation `z(p) = n`;
* `fib_dvd_iff` — the strong-divisibility law `F m ∣ F n ↔ m ∣ n` (`m ≥ 3`),
  recovered as the special case `p = F m`;
* `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's
  primitive-divisor theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`, witnessed by an
  explicit table `fibPrimWitness` of least primitive prime divisors.

The unifying discovery is that the previously *scattered, one-directional*
entry-point lemmas in the catalog (`CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`,
the `Algebra` LTE file's `fibEntryPoint`, and the primitive-part machinery) are all
corollaries of one biconditional, and that biconditional needs nothing beyond
`Nat.fib_gcd` and `Nat.fib_dvd`. In particular, dropping the primality hypothesis
makes `fib_dvd_iff` a *literal* instance of the duality with `p = F m`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibEntry_dvd` | `p ∣ F n ↔ z(p) ∣ n` (any `p`) | proved (sorry-free) |
| `isFibPrimitiveDivisor_iff_entry` | primitivity `⇔ z(p) = n` | proved (sorry-free) |
| `fib_dvd_iff` | `F m ∣ F n ↔ m ∣ n`, `m ≥ 3` | proved (sorry-free) |
| `fib_primitive_divisor_verified` | Carmichael for `n ≤ 40` | proved (`native_decide`) |

Axiom footprint: the three analytic theorems use only `propext, Classical.choice,
Quot.sound`; the finite certificate additionally uses `Lean.ofReduceBool,
Lean.trustCompiler` (the `native_decide` kernel reflection).

The genuinely open object in the catalog remains the *infinite tail* of Carmichael's
theorem (composite `n` beyond the decidable ceiling). The directions below chip away
at exactly that frontier with reusable, falsifiable lemmas.

---

## Direction 1 — A closed-form lower bound on the primitive part

**Conjecture.** Let `Φ*(n)` be the primitive part of `F n` (the largest divisor of
`F n` coprime to every `F d` with `d ∣ n`, `d < n`). Then for every composite
`n ≥ 14`, `Φ*(n) > n`, and in particular `Φ*(n) > 1`.

The key insight is that `Φ*(n)` tracks the cyclotomic factor `Φ_n(φ, ψ)` evaluated
at the Fibonacci recurrence roots, so `log Φ*(n) = φ(n)·log((1+√5)/2) + o(φ(n))`;
once Euler's totient `φ(n)` is shown to dominate `log n`, the inequality is purely
analytic and *uniform* in `n`, eliminating the finite `native_decide` ceiling.

Why now? The entry-point duality of this cycle already certifies (via
`isFibPrimitiveDivisor_iff_entry`) that every prime factor of `Φ*(n)` is primitive,
so a single size bound `Φ*(n) > 1` upgrades to a full existence proof — turning the
open infinite tail into one growth lemma rather than a case analysis.

## Direction 2 — Lifting-the-Exponent collapses the intrinsic prime

**Conjecture.** For a prime `p` with entry point `z = z(p)` and any `n` with `z ∣ n`,
`v_p(F n) = v_p(F z) + v_p(n / z)`, and consequently the only prime that can divide
`Φ*(n)` *without* being primitive is the largest prime factor of `n`.

The key insight is that LTE makes the `p`-adic valuation of `F n` an *affine*
function of `v_p(n)`, so non-primitive contributions to `F n` are bounded by `n`
itself — exactly the slack needed to make Direction 1's inequality `Φ*(n) > n`
sufficient rather than merely necessary.

Why now? The catalog's `Algebra/…Lifting_the_Exponent…` file already states the LTE
scaffold; combining it with `fib_dvd_iff_fibEntry_dvd` (this cycle) gives the
valuation identity on the nose, with no new transcendence input.

## Direction 3 — Entry points are eventually surjective

**Conjecture.** The map `p ↦ z(p)` from primes to positive integers hits every
sufficiently large integer: there is `N₀` such that for all `n ≥ N₀`, some prime `p`
has `z(p) = n`.

The key insight is that `isFibPrimitiveDivisor_iff_entry` proves "primitive divisor
of `F n`" and "`z(p) = n`" are *literally the same statement*, so surjectivity of `z`
past `N₀` is logically equivalent to the eventual existence of primitive divisors —
letting one attack the analytic Direction 1 and the combinatorial surjectivity
statement interchangeably.

Why now? With the equation `z(p) = n` in hand, the problem detaches from Fibonacci
specifics and becomes a clean statement about a single arithmetic function, inviting
sieve- or density-style arguments that do not need the recurrence at all.

## Direction 4 — A bounded-degree chain complex from the entry-point lattice

**Conjecture.** Order `{1,…,N}` by divisibility and form the boundary map `∂` sending
`n` to the formal sum of its maximal proper divisors. Assigning to each index `n` the
`𝔽₂`-vector `(p ∣ F n)_p` over primitive primes yields a 2-term chain complex whose
homology has dimension equal to the number of `n ≤ N` possessing a primitive divisor;
for `N` large this dimension is `N − 4` (the exceptions `1, 2, 6, 12`).

The key insight is that primitivity = "`z(p) = n`" makes the primitive-prime
indicator a *diagonal* cochain in the divisor lattice, so the homology dimension is
governed by the same entry-point equation isolated this cycle — a concrete bridge
from a homological framing to the number theory actually present in the catalog.

Why now? The catalog has both Fibonacci primitive-divisor machinery and cellular
sheaf/cohomology files; the entry-point duality is the missing dictionary that lets a
homological statement be *decided* index-by-index, exactly as
`fib_primitive_divisor_verified` does for `N = 40`.

## Direction 5 — A `native_decide`-free primitive-divisor algorithm

**Conjecture.** The `Nat.find`-based `fibEntry` extends to a structurally terminating
`firstPrimitiveDivisor : ℕ → ℕ` returning the least primitive prime divisor of `F n`
(or `0` for `n ∈ {1,2,6,12}`), and one can prove
`∀ n, firstPrimitiveDivisor n ≠ 0 → IsFibPrimitiveDivisor (firstPrimitiveDivisor n) n`
*without* `native_decide`, by reflection on the entry-point equation.

The key insight is that `isFibPrimitiveDivisor_iff_entry` reduces correctness of the
algorithm to the decidable check `z(p) = n`, so verification becomes a `decide`-on-
`Bool` reflection rather than an opaque kernel-trusted `native_decide`, removing
`Lean.ofReduceBool` / `Lean.trustCompiler` from the axiom footprint of
`fib_primitive_divisor_verified`.

Why now? The constructive `fibEntry` of this cycle is already `Nat.find`; promoting it
to a Bool-reflective certificate is the last step to a fully kernel-checked,
algorithmic Carmichael witness generator.
