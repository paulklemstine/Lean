# Future Directions — Fibonacci primitive divisors and apparition

## Synthesis

This cycle isolated the *primitivity* layer of Fibonacci divisibility theory and showed
that almost all of its structural content flows from a single elementary fact: the
Fibonacci sequence is a **strong divisibility sequence** (`Nat.fib_gcd`,
`Nat.fib_dvd`).  The catalog already develops the *rank of apparition* (`entryPoint`)
via `Nat.find` and studies its lattice behaviour over moduli
(`Catalog/Applications/FibonacciEntryPoints.lean`,
`Catalog/Applications/FibonacciApparitionLattice.lean`).  We deliberately took the
*opposite* route: a fully self-contained file
(`Catalog/Applications/FibonacciPrimitiveDivisors.lean`) that never computes an entry
point and instead reasons directly with `gcd`/`lcm` of indices.  The pay-off is that the
key rigidity theorem — a value is a primitive divisor of at most one positive index —
collapses to a one-line minimality clash (`isPrimitive_unique`), and the law that a
primitive divisor pins the whole divisibility set to the multiples of its index
(`dvd_fib_iff_index_dvd_of_primitive`) follows straight from the sharp meet law
`fib_dvd_gcd_iff` (`d ∣ F_{gcd m n} ↔ d ∣ F_m ∧ d ∣ F_n`, valid for *any* divisor `d`).

From these we obtained the "join" law: the common-apparition set of two primitive
divisors is itself an apparition class governed by the lcm of their indices
(`simultaneous_apparition`), and — beyond the originally-planned conjecture — its full
finite-family generalization `simultaneous_apparition_finset`, proved by `Finset`
induction.  The structural insight is that the map *modulus ↦ {indices where it divides
`F`}* is an isomorphism from the divisibility lattice of "active" moduli onto a sublattice
of `(ℕ, gcd, lcm)`; primitivity is exactly the property of sitting at a *generator* of
such a multiples-ideal.

What did *not* get done: the genuinely deep gap in the catalog remains the infinite tail
of Carmichael's primitive-divisor theorem (`Catalog/Shared/CarmichaelProof.lean` discharges
`13 ≤ n ≤ 10000` by `native_decide` but leaves composite `n > 10000` as `sorry`).  Our
results are precisely the *combinatorial backbone* such a proof needs (they reduce
"`p` is primitive for `F_n`" to a clean statement about indices), but the analytic
existence step — that a primitive divisor *exists* for every `n ≥ 13` except `n ∈ {1,2,6,12}`
— is not addressed here and is the natural next target.

## Results Summary

- `fib_dvd_gcd_iff`: proved — the sharp strong-divisibility meet law `d ∣ F_{gcd m n} ↔ d ∣ F_m ∧ d ∣ F_n` for an arbitrary divisor `d`.
- `isPrimitive_zero_everything`: proved — boundary fact that every modulus is vacuously primitive at index `0`, pinning down why positivity is required elsewhere.
- `isPrimitive_unique`: proved — a value is a primitive divisor of at most one positive index, so the rank of apparition is a well-defined labelling.
- `dvd_fib_iff_index_dvd_of_primitive`: proved — a primitive divisor `p` of `F_n` divides exactly the Fibonacci numbers at multiples of `n` (`p ∣ F_m ↔ n ∣ m`).
- `simultaneous_apparition`: proved — the join law `(p ∣ F_n ∧ q ∣ F_n) ↔ lcm a b ∣ n` for primitive divisors of `F_a`, `F_b`.
- `simultaneous_apparition_finset`: proved — finite-family generalization of the join law via `Finset` induction.

## Research Directions

### Direction 1: Existence of primitive divisors (the Carmichael tail)
**Hypothesis**: For every `n ≥ 13`, `F_n` has a primitive prime divisor (equivalently, the
`sorry` for composite `n > 10000` in `Catalog/Shared/CarmichaelProof.lean` is true).
**Test**: Prove it by bounding the primitive part `Φ_n` (the product of primitive prime
powers) from below using the Lucas/cyclotomic factorization `F_n = ∏_{d ∣ n} Φ_d` and the
fact that intrinsic (non-primitive) prime factors are bounded; then `Φ_n > 1` forces a
primitive divisor.  A disproof would be a single counterexample `n` with `Φ_n = 1`.
**Why now**: Our `dvd_fib_iff_index_dvd_of_primitive` and `isPrimitive_unique` already
reduce "primitive divisor of `F_n`" to "prime with entry point exactly `n`", so the missing
ingredient is purely the size estimate, not the divisibility bookkeeping.
**If true**: closes the headline open `sorry` in the catalog and yields the classical
Carmichael theorem in full.
**If false**: would contradict known mathematics, so any "counterexample" instead pinpoints
a modelling error in the formal statement — valuable as a correctness check.

### Direction 2: Entry point divides `p − (5/p)` (the quadratic-residue law)
**Hypothesis**: For a prime `p ≠ 5`, the entry point `e(p)` divides `p − (5/p)`, where
`(5/p)` is the Legendre symbol; in particular `e(p) ≤ p + 1`.
**Test**: Formalize `F_p ≡ (5/p) (mod p)` and `F_{p−(5/p)} ≡ 0 (mod p)` via the
matrix/`Nat.fib` doubling identities, then apply `dvd_fib_iff_index_dvd_of_primitive` to
convert the congruence into `e(p) ∣ p − (5/p)`.
**Why now**: `dvd_fib_iff_index_dvd_of_primitive` is exactly the converter from "`p ∣ F_k`"
to "`e(p) ∣ k`"; once the single congruence `p ∣ F_{p−(5/p)}` is in hand, the divisibility
of the entry point is immediate.
**If true**: gives an effective upper bound on entry points and a fast primality-style test.
**If false**: would expose a missing hypothesis (e.g. excluding `p = 5`), refining the law.

### Direction 3: Abstract strong divisibility sequences
**Hypothesis**: Every theorem in `FibonacciPrimitiveDivisors` holds verbatim for *any*
sequence `u : ℕ → ℕ` satisfying `u (gcd m n) = gcd (u m) (u n)` (a strong divisibility
sequence), e.g. `u n = a^n − 1` or general Lucas sequences `U_n`.
**Test**: Abstract `Nat.fib` to a hypothesis `StrongDiv u` and re-derive `fib_dvd_gcd_iff`,
`isPrimitive_unique`, `dvd_fib_iff_index_dvd_of_primitive`, and the join laws; check the
`a^n − 1` instance against Mathlib's `Nat.sub_one_dvd_sub_of_dvd_sub`-style lemmas.
**Why now**: our proofs already use *only* `Nat.fib_gcd`/`Nat.fib_dvd`, so the generalization
is a mechanical replacement of one lemma by a typeclass/hypothesis — the math is done.
**If true**: a single reusable module subsumes Fibonacci, Mersenne, and Lucas apparition
theory, a genuine cross-domain consolidation of the catalog.
**If false** (some instance breaks): identifies exactly which extra axiom (e.g. `u 1 = 1`,
or strict monotonicity) the Fibonacci proofs silently relied on.

### Direction 4: The apparition lattice is an order isomorphism
**Hypothesis**: The map `Φ : a ↦ entryPoint a`, restricted to moduli that divide some `F_k`,
is an injective lattice homomorphism for the *join* (`lcm`) but only a lax morphism for the
*meet* (`gcd`), and its image is exactly the set of `n` such that `F_n` has a primitive
divisor with that entry point.
**Test**: Combine the catalog's `fibEntry_lcm` and `fibEntry_gcd_not_exact`
(`FibonacciApparitionLattice.lean`) with our `isPrimitive_unique` to prove injectivity on
the relevant domain and characterize the image; the boundary case `a = 4, b = 6` already
witnesses meet-failure.
**Why now**: the join law is proved here and the meet counterexample is proved in the
catalog; `isPrimitive_unique` supplies the injectivity that ties them into a single
structural statement.
**If true**: a clean categorical description of the rank of apparition as a lattice map.
**If false**: the failure locates a second exceptional index beyond `12` where injectivity
or surjectivity breaks.

### Direction 5: Counting simultaneous apparitions (density)
**Hypothesis**: For fixed primitive divisors `p` of `F_a` and `q` of `F_b`, the number of
indices `n ≤ N` with `p ∣ F_n ∧ q ∣ F_n` is exactly `⌊N / lcm(a,b)⌋`, and more generally the
density of common-apparition indices of a finite family equals `1 / lcm(g i)`.
**Test**: Turn `simultaneous_apparition` / `simultaneous_apparition_finset` into a counting
statement via `Nat.Ioc`/`Finset.filter` cardinalities of multiples of a fixed modulus
(`Nat.card_multiples`-style lemmas), then take the limit.
**Why now**: the iff with `lcm a b ∣ n` reduces the count to "multiples of a fixed number in
`[1, N]`", which Mathlib counts exactly — so this is a packaging of an already-proved
equivalence into quantitative form.
**If true**: gives explicit densities for joint Fibonacci divisibility, connecting the
apparition lattice to analytic number theory.
**If false**: a discrepancy would reveal an off-by-one in how the empty family or `n = 0` is
counted, sharpening the statement.
