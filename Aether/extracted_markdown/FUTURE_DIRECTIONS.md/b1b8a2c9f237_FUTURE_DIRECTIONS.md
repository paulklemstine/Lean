# Future Directions — Entry-Point Duality and Primitive Divisors

## Synthesis

This cycle produced `Speculative/AutoResearch/FibonacciEntryPointDuality.lean`, a
self-contained, `sorry`-free development of the *rank of apparition* (entry point)
`z(p)` of the Fibonacci sequence and four results built on it:

* `fib_dvd_iff_fibEntry_dvd` — the master biconditional `p ∣ F_n ↔ z(p) ∣ n`;
* `isFibPrimitiveDivisor_iff_entry` — primitivity of `p` for `F_n` reduces to the
  single equation `z(p) = n`;
* `fib_dvd_iff` — the strong-divisibility law `F_m ∣ F_n ↔ m ∣ n` (`m ≥ 3`),
  recovered as the special case `p = F_m`;
* `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's
  theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`.

The unifying discovery is that the previously *scattered, one-directional*
entry-point lemmas in the catalog (`CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`,
the `Algebra` LTE file's `fibEntryPoint`, and the computational primitive-part
extractors `CarmichaelProof.primPart` / `CarmichaelComposite.fibCoprimePart`) are
all corollaries of one biconditional, and that biconditional needs nothing beyond
`Nat.fib_gcd` and `Nat.fib_dvd`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibEntry_dvd` | `p ∣ F_n ↔ z(p) ∣ n` | proved (sorry-free) |
| `isFibPrimitiveDivisor_iff_entry` | primitivity `⇔ z(p) = n` | proved (sorry-free) |
| `fib_dvd_iff` | `F_m ∣ F_n ↔ m ∣ n`, `m ≥ 3` | proved (sorry-free) |
| `fib_primitive_divisor_verified` | Carmichael for `n ≤ 40` | proved (`native_decide`) |

The genuinely open object in the catalog remains the *infinite tail* of
Carmichael's composite case (`Shared/CarmichaelProof.lean`, `fib_carmichael_composite`
for composite `n > 10000`), whose surrounding files additionally depend on a
missing `Shared.CarmichaelHelper` module. The directions below are chosen to chip
away at exactly that frontier with reusable, falsifiable lemmas.

---

## Direction 1 — A closed-form lower bound on the primitive part

**Conjecture.** Let `Φ*(n)` be the primitive part of `F_n` (the largest divisor of
`F_n` coprime to every `F_d` with `d ∣ n`, `d < n`, as already computed by
`CarmichaelProof.primPart`). Then for every composite `n ≥ 14`,
`Φ*(n) > n`, and in particular `Φ*(n) > 1`.

The key insight is that `Φ*(n)` tracks the cyclotomic factor `Φ_n(φ, ψ)` evaluated
at the Fibonacci recurrence roots, so `log Φ*(n) = φ(n)·log((1+√5)/2) + o(φ(n))`;
once Euler's totient `φ(n)` is shown to dominate `log n`, the inequality is purely
analytic and *uniform* in `n`, eliminating the `native_decide` ceiling at 10000.

Why now? The entry-point duality of this cycle already certifies that every prime
factor of `Φ*(n)` is primitive, so a single size bound `Φ*(n) > 1` upgrades to a
full existence proof — turning the open infinite tail into one growth lemma rather
than a case analysis.

## Direction 2 — Lifting-the-Exponent collapses the intrinsic prime

**Conjecture.** For a prime `p` with entry point `z = z(p)` and any `n` with `z ∣ n`,
`v_p(F_n) = v_p(F_z) + v_p(n/z)`, and consequently the only prime that can divide
`Φ*(n)` *without* being primitive is the largest prime factor of `n`.

The key insight is that LTE makes the `p`-adic valuation of `F_n` an *affine*
function of `v_p(n)`, so non-primitive contributions to `F_n` are bounded by `n`
itself — exactly the slack needed to make Direction 1's inequality `Φ*(n) > n`
sufficient rather than merely necessary.

Why now? The catalog's `Algebra/…Lifting_the_Exponent…` file already states the LTE
scaffold; combining it with `fib_dvd_iff_fibEntry_dvd` (this cycle) gives the
valuation identity on the nose, with no new transcendence input.

## Direction 3 — Entry points are eventually surjective onto divisor lattices

**Conjecture.** The map `p ↦ z(p)` from primes to positive integers hits every
sufficiently large integer: there is `N₀` such that for all `n ≥ N₀`, some prime `p`
has `z(p) = n`. (This is Carmichael's theorem restated through `isFibPrimitiveDivisor_iff_entry`.)

The key insight is that `isFibPrimitiveDivisor_iff_entry` already proves
"primitive divisor of `F_n`" and "`z(p) = n`" are *literally the same statement*,
so surjectivity of `z` past `N₀` is logically equivalent to the eventual existence
of primitive divisors — letting one attack the analytic Direction 1 and the
combinatorial surjectivity statement interchangeably.

Why now? With the equation `z(p)=n` in hand, the problem detaches from Fibonacci
specifics and becomes a clean statement about a single arithmetic function, inviting
sieve- or density-style arguments that do not need the recurrence at all.

## Direction 4 — A bounded-degree CSS chain complex from the entry-point lattice

**Conjecture.** Order the indices `{1,…,N}` by divisibility and form the boundary map
`∂` sending `n` to the formal sum of its maximal proper divisors. Assigning to each
index `n` the `𝔽₂`-vector `(p ∣ F_n)_p` over primitive primes yields a 2-term chain
complex whose homology has dimension equal to the number of `n ≤ N` possessing a
primitive divisor; for `N` large this dimension is `N − 4` (the four exceptions
`1,2,6,12`).

The key insight is that primitivity = "`z(p)=n`" makes the primitive-prime
indicator a *diagonal* cochain in the divisor lattice, so the CSS distance and the
homology dimension are governed by the same entry-point equation that this cycle
isolated — a concrete bridge from the requested expander/quantum-code framing to the
number theory actually present in the catalog.

Why now? The catalog has both Fibonacci primitive-divisor machinery and cellular
sheaf/cohomology files (`Cryptography/CellularSheafCohomology.lean`); the entry-point
duality is the missing dictionary that lets a homological statement be *decided*
index-by-index, exactly as `fib_primitive_divisor_verified` does for `N = 40`.

## Direction 5 — Replace `native_decide` with a verified primitive-divisor algorithm

**Conjecture.** The `Nat.find`-based `fibEntry` extends to a *fuel-free, structurally
terminating* function `firstPrimitiveDivisor : ℕ → ℕ` that returns the least
primitive prime divisor of `F_n` (or `0` for `n ∈ {1,2,6,12}`), and one can prove
`∀ n, firstPrimitiveDivisor n ≠ 0 → IsFibPrimitiveDivisor (firstPrimitiveDivisor n) n`
*without* `native_decide`, by reflection on the entry-point equation.

The key insight is that `isFibPrimitiveDivisor_iff_entry` reduces correctness of the
algorithm to the decidable check `z(p) = n`, so the verification becomes a
`decide`-on-`Bool` reflection rather than an opaque kernel-trusted `native_decide`,
removing `Lean.ofReduceBool` / `Lean.trustCompiler` from the axiom footprint.

Why now? The constructive `fibEntry` of this cycle is already `Nat.find`; promoting
it to a Bool-reflective certificate is the last step to a fully kernel-checked,
algorithmic Carmichael witness generator — the constructive deliverable this engine
is configured to prize.
