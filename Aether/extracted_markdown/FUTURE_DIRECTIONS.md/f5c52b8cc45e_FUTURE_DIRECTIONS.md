# Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

## Synthesis

This cycle attacked the two `sorry`/missing-dependency holes left in the catalog's
Carmichael program (`Shared/CarmichaelProof.lean`'s composite tail for `n > 10000`, and
the absent `Shared/CarmichaelHelper.lean` providing the prime case
`fib_primitive_divisor_prime`).  Both holes turned out to be the *same* mathematical object
seen twice: the genuinely infinite, research-level content of Carmichael's primitive-divisor
theorem for Fibonacci numbers, which is **not** in Mathlib and cannot be discharged by the
existing `native_decide` verification (which only certifies `13 ≤ n ≤ 10000`).

Rather than fake a proof of a theorem we could not honestly close, we did three things.
First, we repaired the build configuration (the package was missing `srcDir = "Catalog"` and
several library globs, so *nothing* compiled).  Second, we discovered that the catalog already
contained two **disconnected** developments of the same idea — `FibApparition.apparitionRank`
(an *unconditional*, `Nat.find`-based rank of apparition with the divisibility law
`m ∣ F n ↔ apparitionRank m ∣ n`) and `FibonacciPrimitiveDivisors.IsPrimitive` (a
*minimality*-based primitive-divisor predicate) — and we **fused** them in the new file
`Catalog/Speculative/AutoResearch/CarmichaelApparitionBridge.lean`.  Third, using that bridge
we extracted the *arithmetic* of the rank of apparition that the minimality definition cannot
express, and recast Carmichael's theorem as a clean surjectivity statement.

## Results summary (all `sorry`-free, axioms `propext`/`Classical.choice`/`Quot.sound`)

* `isPrimitive_iff_apparitionRank_eq` — the two catalog notions of "primitive divisor"
  coincide: `IsPrimitive m n ↔ apparitionRank m = n` (for `0 < m`, `0 < n`).
* `apparitionRank_dvd_of_dvd` — monotonicity: `m ∣ m' ⟹ apparitionRank m ∣ apparitionRank m'`.
* `apparitionRank_coprime_mul` — the **lcm law**: for coprime `m, n`,
  `apparitionRank (m·n) = lcm (apparitionRank m) (apparitionRank n)`.
* `exists_primitive_prime_iff_exists_apparitionRank_eq` and
  `carmichael_statement_iff_apparitionRank_surjective` — Carmichael's theorem is *equivalent*
  to "`prime ↦ apparitionRank` is surjective onto `{n : 13 ≤ n}`".

---

## Direction 1 — Prove the prime-power formula `apparitionRank (p^(k+1)) = p · apparitionRank (p^k)`

Wall's classical result states that, away from "Wall–Sun–Sun" primes, the rank of apparition
satisfies `z(p^k) = p^{k-1} · z(p)`.  Combined with this cycle's `apparitionRank_coprime_mul`
(the coprime lcm law), a proven prime-power formula would give a **complete multiplicative
description** of `apparitionRank` on all of ℕ.

The key insight is that the lcm law already reduces the entire arithmetic of the rank of
apparition to prime powers, so this single missing recurrence is *exactly* the remaining
degree of freedom — once it is in place, `apparitionRank n` is computable from the
factorization of `n` with no Fibonacci arithmetic at all.

Why now? Because `apparitionRank_coprime_mul` was proved this cycle and `FibApparition`
already gives the unconditional divisibility law `m ∣ F n ↔ apparitionRank m ∣ n`; the
prime-power step needs only `p`-adic valuation bookkeeping (`Nat.fib` lifting-the-exponent),
for which the catalog already has a dedicated p-adic Fibonacci file to build on.
Falsifiable: it predicts `apparitionRank 4 = 6`, `apparitionRank 8 = 6`, `apparitionRank 9 = 12`,
`apparitionRank 16 = 12` — each is a finite `#eval`/`decide` check that would refute the formula
immediately if wrong (and indeed the `p=2` line `z(2)=3, z(4)=6, z(8)=6` already flags that the
naive `p^{k-1}` shape needs the Wall correction at small powers).

## Direction 2 — Close the composite tail via the cyclotomic primitive part `Φ_n`

The `sorry` in `Shared/CarmichaelProof.lean` (composite `n > 10000`) and the missing prime
case are both the assertion `1 < primPart n`.  The standard route is the homogeneous
cyclotomic factorization `F_n = ∏_{d ∣ n} Φ_d` with `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}`, together
with the Birkhoff–Vandiver dichotomy: a non-primitive prime divisor of `Φ_n` must be the
largest prime factor `P` of `n`, dividing `Φ_n` exactly once.  Hence a primitive divisor
exists as soon as `Φ_n > P`.

The key insight is that the infinite tail is not really "infinitely many cases": it is a
single inequality `Φ_n > P(n)`, and `log Φ_n ≍ φ(n) · log α` grows linearly in `φ(n)` while
`P(n) ≤ n`, so the inequality holds for all `n` past a small explicit bound that the existing
`native_decide` already covers.

Why now? Because this cycle's `isPrimitive_iff_apparitionRank_eq` turns "primitive divisor of
`F_n`" into "`apparitionRank p = n`", which is precisely the entry-point language in which the
Birkhoff–Vandiver intrinsic/extrinsic split is cleanest; the entry-point law
`fibEntryPt_dvd_of_fib_dvd` is already proved in `CarmichaelComposite.lean`.
Falsifiable: the claim `Φ_n > P(n)` for all composite `n ≥ 14` is a concrete inequality whose
failure at any single `n` would be exhibited by direct computation.

## Direction 3 — A lifting-the-exponent theorem `v_p(F_n) = v_p(F_{z(p)}) + v_p(n / z(p))`

The engine behind both Direction 1 and Direction 2 is LTE for Fibonacci: when `z(p) ∣ n`,
the `p`-adic valuation of `F_n` is `v_p(F_{z(p)}) + v_p(n / z(p))`.  Proving this as a
standalone, reusable theorem would unlock the prime-power recurrence and the `Φ_n` growth
bound simultaneously.

The key insight is that `apparitionRank` (this cycle's bridge target) is *exactly* the index
`z(p)` appearing in LTE, so the statement can be phrased entirely against the already-proven
`apparitionRank` API instead of re-deriving entry points.

Why now? The unconditional `apparitionRank` and its divisibility law exist and are sorry-free;
LTE is the natural next layer and the only genuinely new analytic input needed for the whole
Carmichael program.
Falsifiable: predicts e.g. `v_2(F_n)` jumps by exactly one each time `n` gains a factor of
`2` once `3 ∣ n` (`z(2)=3`); any deviation in a finite table refutes it.

## Direction 4 — Surjectivity of `prime ↦ apparitionRank` and the density of "apparition-defective" indices

This cycle proved Carmichael ⇔ "`apparitionRank` restricted to primes is surjective onto
`{n ≥ 13}`".  A bolder conjecture: the map is surjective onto `{n ≥ 13}` but **far from
injective on initial segments**, and the number of primes `p ≤ X` with `apparitionRank p = p`
(the "Fibonacci–Wieferich-free" primes for which `p` is its own rank) has positive density.

The key insight is that `apparitionRank_coprime_mul` makes the image of `apparitionRank`
a multiplicatively structured set, so surjectivity onto all large `n` is governed entirely by
which `n` are hit by *prime* arguments — a question the bridge isolates exactly.

Why now? With the surjectivity reformulation now a theorem rather than folklore, the next
cycle can target the quantitative refinement (counting functions) using only finite
`#eval` evidence to calibrate the density constant before attempting a proof.
Falsifiable: the density claim makes a numerical prediction for `#{p ≤ 10^4 : z(p) = p}`
that can be computed and checked against the conjectured asymptotic.

## Direction 5 — Transport the bridge to general Lucas sequences `U_n(P,Q)`

`apparitionRank`, `IsPrimitive`, and the lcm law used nothing Fibonacci-specific beyond the
strong-divisibility property `gcd(U_m, U_n) = U_{gcd(m,n)}`.  The conjecture is that the entire
bridge file generalizes verbatim to any non-degenerate Lucas sequence with that property,
yielding a uniform "rank of apparition ⇔ primitivity" dictionary.

The key insight is that every proof in `CarmichaelApparitionBridge.lean` factors through the
single law `m ∣ U_n ↔ z(m) ∣ n`, so abstracting the sequence to a typeclass of
strong-divisibility sequences would make the results sequence-agnostic.

Why now? The Fibonacci proofs are short and structural (each is one to three lines over the
divisibility law), so the generalization cost is low, and a `StrongDivisibilitySequence`
abstraction would let the catalog's many separate Fibonacci/Lucas files share one API.
Falsifiable: the generalization predicts the lcm law for, e.g., the Pell sequence
(`P=2, Q=-1`); a finite check of `apparitionRank` for Pell numbers at coprime moduli would
refute it if the strong-divisibility hypothesis were insufficient.
