# FUTURE_DIRECTIONS — The entry-point invariant of strong divisibility sequences

## What this cycle settled

The file `Catalog/Speculative/AutoResearch/FibonacciEntryPointInvariant.lean` lifts the
Fibonacci-specific entry-point scaffolding of the catalog
(`FibonacciApparition.fibEntry`, `fib_dvd_iff_fibEntry_dvd`,
`prime_primitive_divisor_iff`, and `CarmichaelComposite.primitive_of_entryPt_eq`) into a
fully abstract theory parameterised by the single *renormalization* hypothesis
`gcd (u m) (u n) = u (gcd m n)`. Three things became theorems that depend on **nothing**
but that identity and minimality of `Nat.find`:

* `StrongDivSeq.entry_dvd` — the rank of apparition divides every index of appearance;
* `StrongDivSeq.primitive_divisor_inj` — *fractal injectivity*: a fixed modulus is a
  primitive divisor of at most one term;
* `StrongDivSeq.primitive_divisor_distinct` — distinct indices have disjoint
  primitive-divisor sets.

These instantiate with zero further work at `u = Nat.fib` (`fib_primitive_divisor_inj`,
via `Nat.fib_gcd`) and at the base-`a` Mersenne/repunit sequence `u n = a^n - 1`
(`mersenne_primitive_divisor_inj`, via `Nat.pow_sub_one_gcd_pow_sub_one`). We also closed
the previously-conjectured **multiplicativity on coprime moduli**,
`fibEntry (a*b) = lcm (fibEntry a) (fibEntry b)` (`fibEntry_mul_coprime`), the lattice dual
of the `gcd ↦ gcd` half recorded by `Nat.fib_gcd`. The recurring lesson — *prove the
property of the invariant, never of the raw sequence* — made every proof a few lines.

The frontier now sits where the raw values re-enter: prime-power refinement (needs the
actual `p`-adic valuation of `u e`), pure periodicity (needs reversibility of the dynamical
pair-map), and density (needs growth bounds). Those are the directions below.

## Direction 1 — Abstract multiplicativity, then prime-power reduction

Multiplicativity on coprime moduli is currently proved only for `u = Nat.fib`
(`fibEntry_mul_coprime`), because it uses the *law of apparition* `m ∣ u k ↔ entry u m ∣ k`,
which in turn needs the entry point to be total. The conjecture is that the abstract
statement holds for any strong divisibility sequence whose entry map is total:
`entry u (a*b) = lcm (entry u a) (entry u b)` for coprime `a, b > 0`. Combined with a
prime-power formula it would give `entry u n` for all `n` from its values at prime powers.
The prime-power formula itself (a lifting-the-exponent statement) reads, for an odd prime
`p` with `e = entry u p` and `v` the `p`-adic valuation of `u e`,
`entry u (p^(k+1)) = p · entry u (p^k)` once `k ≥ v`, and `= entry u (p^k)` below `v`.
**The key insight is** that multiplicativity and lifting-the-exponent are the *additive* and
*ramified* halves of the same statement: the entry map is a lattice morphism off the prime,
and a single controlled `p`-factor jump on the prime. **Why now?** `entry_dvd` plus the
law of apparition already supply both inequalities an `lcm`/recursion characterisation needs,
and `Catalog/Shared/FibonacciLTE.lean` carries an LTE skeleton for the Fibonacci case to
seed the valuation step. *Testable/falsifiable:* an `#eval` sweep of `entry` over coprime
pairs and prime powers up to a few hundred will expose any off-by-one before a proof is
attempted; the Wall–Sun–Sun primes (`fib e ≡ 0 mod p²`) are the precise predicted
obstruction if the prime-power form fails.

## Direction 2 — Totality of the entry map as a hypothesis-free corollary

For Fibonacci, totality (`exists_pos_dvd_fib`) comes from pigeonhole on the finite
pair-map mod `m`. The conjecture is a clean sufficient condition on an abstract sequence:
if `u` satisfies the strong-divisibility identity *and* a linear recurrence with unit
leading and trailing coefficients over each `ZMod m`, then its entry map is total. **The key
insight is** that reversibility of the recurrence (the trailing unit) turns the cheap
forward pigeonhole into a purely periodic orbit through `(0,1)`, which is exactly what forces
a zero of `u` mod `m` to reappear at a positive index. **Why now?** The Fibonacci proof in
`FibonacciApparition` already isolates the two ingredients (`fibPair_back` reversibility and
descent-to-zero); abstracting them over a two-term reversible recurrence is a near-verbatim
re-derivation. *Testable/falsifiable:* instantiate at Lucas sequences `U_n(P,Q)` with
`gcd(P,Q)=1` and check totality computationally; a sequence with `gcd(P,Q) > 1` should be
the first to break it, sharpening the exact hypothesis.

## Direction 3 — A Mathlib-native Pisano period from the pair-map orbit

Define `pisano p` as `Nat.find` of the orbit-return predicate
`fibPair p 0 = fibPair p d, d > 0`. The conjecture is `entry Nat.fib p ∣ pisano p`,
`pisano p ≤ p^2 - 1`, and pure (pre-period-free) periodicity of the orbit through `(0,1)`.
**The key insight is** that reversibility (`FibonacciApparition.fibPair_back`) upgrades a
one-shot existence pigeonhole into an exact quantitative invariant: an injective eventually
periodic map is purely periodic, so the first return *is* the period. **Why now?** The
backward step and descent-to-zero lemmas are already proved, which are precisely the
"injective + eventually periodic ⟹ purely periodic" inputs; only the `Nat.find` packaging
and the `p^2 - 1` finiteness count remain. *Testable/falsifiable:* `entry p ∣ pisano p` is
forced by group theory, so any computed counterexample would instead flag a `ZMod`-cast bug
— a built-in self-check. Mathlib currently has only a `PisanoPeriodBoundConjecture`
placeholder (`Catalog/Bridges/ModularCFDynamics.lean`), so a proved version is genuinely new.

## Direction 4 — Density of indices carrying a primitive divisor

With `primitive_divisor_inj` now abstract, the index ↦ primitive-modulus assignment is a
partial injection. The conjecture is that `{n | ∃ p prime, IsPrimitive Nat.fib p n}` has
natural density `1` (the strong form of Carmichael: all but finitely many `n ≥ 13` carry a
primitive prime divisor), and that the number of distinct primes appearing as primitive
divisors below `x` grows like `x / log φ` (`φ` the golden ratio). **The key insight is** that
injectivity of the invariant is exactly the bridge from a *pointwise* existence statement
(the catalog's `fib_carmichael`) to a *global* counting statement: distinct large indices
contribute distinct primes. **Why now?** The existence half is already in the catalog and the
injectivity half is now a one-liner instantiation; the remaining work is the analytic growth
estimate, for which `fib_exp_bound`-style bounds give the `log φ` denominator. *Testable/
falsifiable:* compute the count of distinct primitive primes below `x` for `x` up to a few
thousand and compare to `x / log φ`; a persistent gap measures how often two indices are
forced to share their entire prime support, quantifying the failure of primitivity.

## Direction 5 — Elliptic and other higher divisibility sequences

The abstraction in this file used only the gcd identity, so it should export to *elliptic
divisibility sequences* (EDS) and to `q`-integer analogues, where strong divisibility is
known to hold. The conjecture is that an `EllipticDivisibilitySequence` structure satisfying
`gcd (u m) (u n) = u (gcd m n)` (up to sign/normalisation) inherits `entry_dvd` and
`primitive_divisor_inj` with no new proof, and that its entry map is again multiplicative on
coprime moduli. **The key insight is** that "fractal injectivity" is a theorem about the
divisibility lattice, not about any closed form, so the same `StrongDivSeq` interface covers
EDS once the gcd identity is supplied. **Why now?** The interface is already minimal — a
single `Hgcd` hypothesis — so wrapping it as a `class StrongDivisibilitySequence` and
discharging the EDS instance is the entire task. *Testable/falsifiable:* instantiate at a
concrete EDS (e.g. the sequence from a rational point on `y² = x³ + x`) and verify the gcd
identity numerically; sequences where the sign normalisation fails pinpoint exactly where the
unsigned `Nat` interface must be replaced by an `Int`/ideal-theoretic one.
