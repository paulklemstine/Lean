# FUTURE_DIRECTIONS — Fractal Fibonacci: the entry-point map as an arithmetic invariant

## Synthesis

This cycle promoted a piece of *proof-internal scaffolding* from the catalog's Carmichael
development (`fibEntryPt`, `primitive_of_entryPt_eq` in
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`, and the gcd identity in
`Catalog/Shared/Fib_gcd_identity.lean`) into a **first-class invariant with its own theory**.
The organizing idea is "fractal/self-similarity": the renormalization identity
`Nat.fib_gcd : fib (gcd m n) = gcd (fib m) (fib n)` says the divisibility lattice of the
Fibonacci values is a scale-invariant copy of the divisibility lattice of the indices.
The invariant produced by that self-similarity is the **entry point** (rank of apparition)
`entryPoint p`, the least positive index whose Fibonacci value `p` divides.

Two structural results emerged. First, `entryPoint_dvd` (rank of apparition divides the index)
needs *no primality* — it is a pure consequence of the gcd renormalization and minimality of
`Nat.find`. Second, and the conceptual payoff, `primitive_divisor_inj`: a fixed `p` can be a
*primitive* (first-appearance) divisor of **at most one** Fibonacci number, because primitivity
is exactly the fiber `entryPoint p = n`. This is "fractal injectivity": the self-similar lattice
forbids a prime from making a first appearance twice. We also closed the existence question
independently of the catalog's heavy `native_decide` computation: `every_prime_dvd_fib` shows
every prime divides some Fibonacci number via pigeonhole on the finite pair-map mod `p`, whose
*reversibility* (`fibPair_backward`) drags any collision back to index `0`. This makes the pair
map a bijection on the finite torus `(ZMod p)²` whose orbit through `(0,1)` is purely periodic — a
discrete analogue of a self-map's recurrent set.

What failed/needed care: forward periodicity alone is insufficient for existence; the *backward*
recurrence step `fib n = fib (n+2) - fib (n+1)` (valid in the ring `ZMod p`) is what closes the
loop. Comparing `fib m` and `fib n` directly is intractable; everything became one-liners once it
was factored through the invariant `entryPoint`. The lesson seeding the next cycle: *find the
invariant the self-similarity induces, then prove injectivity/periodicity of the invariant
rather than of the raw sequence.*

## Results Summary

- `fib_dvd_gcd`: proved — self-similarity at a fixed modulus: `p ∣ fib m`, `p ∣ fib n` ⟹ `p ∣ fib (gcd m n)`.
- `entryPoint_spec`: proved — when an entry point exists it is positive, divisible-at, and minimal.
- `entryPoint_dvd`: proved — rank of apparition divides every index of appearance (no primality needed).
- `entryPoint_eq_of_primitive`: proved — a primitive divisor pins `entryPoint p = n`.
- `isPrimitive_of_entryPoint_eq`: proved — converse: `entryPoint p = n` (when it exists) ⟹ primitive divisor.
- `primitive_divisor_inj`: proved — **(main)** a fixed `p` is a primitive divisor of at most one `fib n`.
- `primitive_divisor_distinct`: proved — distinct indices have disjoint primitive-divisor sets.
- `fibPair_backward`: proved — reversibility of the recurrence mod `p`.
- `fibPair_collision_to_zero`: proved — any forward collision descends to index `0`.
- `every_prime_dvd_fib`: proved — every prime divides some `fib k`, `k > 0` (entry point always exists).
- `entryPoint_pos_of_prime`: proved — entry point of a prime is positive.
- `infinite_fib_divisor_primes`: proved — infinitely many primes divide Fibonacci numbers.

## Research Directions

### Direction 1: Entry point of a prime power and lifting-the-exponent
**Hypothesis**: For an odd prime `p` with entry point `e = entryPoint p`, the entry point of
`p^k` is `e · p^(max 0 (k - v))` where `v = padicValNat p (fib e)`; equivalently the rank of
apparition climbs by exactly one factor of `p` per exponent past the first.
**Test**: Prove `entryPoint (p^(k+1)) = p * entryPoint (p^k)` for `k ≥ v` and `= entryPoint (p^k)`
below `v`, reusing `entryPoint_dvd` and a lifting-the-exponent lemma for `fib`
(`Catalog/Shared/FibonacciLTE.lean` already has an LTE skeleton to build on); disprove by an
`#eval` search over small `p, k` if the off-by-one fails.
**Why now**: We now have `entryPoint` as a standalone invariant with `entryPoint_dvd` and the
primitive-divisor characterization, so the prime-power statement is a clean recursion on the
existing invariant rather than a fact about raw `fib` values. The key insight is that
lifting-the-exponent is precisely the statement that the self-similar lattice *refines* uniformly
under `p`-adic zoom, so the entry point transforms by a single controlled `p`-factor.
**If true**: gives a complete formula for `entryPoint (n)` for any `n` via multiplicativity over
prime powers, and a self-contained route to Carmichael's theorem avoiding `native_decide`.
**If false**: pinpoints the Wall–Sun–Sun phenomenon (primes with `fib (e) ≡ 0 mod p^2`) as the
exact obstruction, which is itself a publishable computational target.

### Direction 2: Entry point is multiplicative on coprime moduli
**Hypothesis**: For coprime `a, b > 1`, `entryPoint (a * b) = Nat.lcm (entryPoint a) (entryPoint b)`.
**Test**: Prove `⊇` via `entryPoint_dvd` and CRT-style divisibility, and `⊆` via minimality
(`entryPoint_spec`); validate first with `#eval` over coprime pairs up to a few hundred.
**Why now**: `entryPoint_dvd` plus `entryPoint_spec` give exactly the two inequalities an
lcm-characterization needs, and `fib_dvd_gcd` already encodes the gcd half of the lattice
correspondence. The key insight is that the entry point is a *lattice homomorphism* from the
divisibility lattice of moduli to the divisibility lattice of indices, with `gcd ↦ gcd` (proved)
dual to `coprime-product ↦ lcm` (conjectured).
**If true**: reduces all entry-point computation to the prime-power case (Direction 1), giving a
full multiplicative theory of the rank of apparition.
**If false**: the failure must come from a shared entry point between `a` and `b`, exposing exactly
which non-coprime interactions break multiplicativity.

### Direction 3: Quantitative Pisano period bound from the pair-map orbit
**Hypothesis**: The Pisano period `π(p)` (least `d > 0` with `fibPair p 0 = fibPair p d`) satisfies
`entryPoint p ∣ π(p)` and `π(p) ≤ p^2 - 1` for every prime `p`, with the orbit of `fibPair p`
through `(0,1)` purely periodic of period `π(p)`.
**Test**: Formalize `π(p)` as `Nat.find` of the orbit-return predicate (existence is
`every_prime_dvd_fib`'s pigeonhole), prove pure periodicity from `fibPair_backward`
(bijectivity ⟹ no pre-period), then the `p^2 - 1` bound from finiteness of nonzero pairs.
**Why now**: `fibPair_backward` and `fibPair_collision_to_zero` already establish reversibility and
descent-to-zero, which are precisely the ingredients for "eventually periodic + injective ⟹ purely
periodic." The key insight is that reversibility upgrades the cheap pigeonhole existence into exact
periodicity, turning a one-shot existence proof into a quantitative invariant.
**If true**: yields a verified, Mathlib-native Pisano period (currently absent from Mathlib — only a
`PisanoPeriodBoundConjecture` placeholder exists in `Catalog/Bridges/ModularCFDynamics.lean`).
**If false**: a counterexample to `entryPoint p ∣ π(p)` would contradict basic group theory and so
flags a formalization bug — a valuable self-check on the `ZMod` cast machinery.

### Direction 4: General Lucas sequences and the abstract self-similarity axiom
**Hypothesis**: Every integer Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1` satisfies the same
renormalization identity `gcd(U_m, U_n) = U_(gcd m n)` (up to sign), and hence admits an
`entryPoint` with `entryPoint_dvd` and `primitive_divisor_inj` proved *verbatim*.
**Test**: Abstract the proofs in this file over a hypothesis `H : ∀ m n, gcd (u m) (u n) = u (gcd m n)`
and re-derive `entryPoint_dvd`/`primitive_divisor_inj`; then instantiate at `u = fib` and at
`u n = 2^n - 1` (Mersenne) to confirm reuse.
**Why now**: All four structural theorems here used *only* `fib_dvd_gcd` and minimality — never a
fib-specific value. The key insight is that "fractal injectivity" is a theorem about any
divisibility sequence, with `fib_gcd` merely one model. **Why now** specifically: the proofs are
already this thin, so the abstraction cost is near zero.
**If true**: a single `StrongDivisibilitySequence` typeclass exports entry-point theory to
Mersenne numbers, `q`-integers, elliptic divisibility sequences, etc.
**If false**: identifies which sequences fail the gcd identity (e.g. those with `gcd(P,Q) > 1`),
sharpening the precise hypothesis under which the invariant exists.

### Direction 5: Density / growth of the primitive-divisor index set
**Hypothesis**: The set `{n | ∃ p prime, IsPrimitiveDivisor p n}` has natural density `1`
(all but finitely many `n ≥ 13` carry a primitive prime divisor — the strong form of Carmichael),
and the counting function of distinct primes appearing as primitive divisors below `x` grows like
`x / log φ` where `φ` is the golden ratio.
**Test**: Combine `primitive_divisor_inj` (which makes the index ↦ primitive-prime assignment a
partial injection) with the catalog's `fib_carmichael` existence result to get a lower bound on the
prime-counting side; estimate growth via `fib_linear_lower`/`fib_exp_bound` from
`Catalog/Shared/Fib_gcd_identity.lean`.
**Why now**: `primitive_divisor_inj` is exactly the injectivity that converts "each large `n` has a
primitive divisor" into "many distinct primes," and the catalog already proves the existence half.
The key insight is that injectivity of the invariant is the bridge from a *pointwise* existence
statement to a *global* density/growth statement.
**If true**: a verified effective lower bound on the number of "Fibonacci primes" below `x`,
connecting the entry-point invariant to analytic number theory.
**If false**: the density gap measures how often two indices must share their entire prime support,
quantifying the failure of primitivity.
