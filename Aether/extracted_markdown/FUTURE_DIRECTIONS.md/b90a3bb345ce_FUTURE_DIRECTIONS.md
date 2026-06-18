# Future Directions — A Unified Primitive-Divisor Engine, Sixth Cycle

## Synthesis

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion.lean`, a **self-contained,
`sorry`-free** file that fuses two previously separate strands of the catalog's Fibonacci
primitive-divisor program:

1. the **structural** abstraction `StrongDivSeq.IsStrongDivSeq`
   (`Catalog/Applications/StrongDivisibilitySequences.lean`), which lifted uniqueness, the meet/join
   laws, and apparition counting to arbitrary strong divisibility sequences `u (gcd m n) =
   gcd (u m) (u n)`; and
2. the **computational** engine — the "coprime part" `fibCoprimePart` with
   `primitive_of_fibCoprimePart_pos` (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`),
   which until now was hard-wired to `Nat.fib`.

The new file lifts the *engine itself* to the abstract setting. The single criterion
`primitive_of_coprimePart_pos` then specializes, with no extra mathematical input, to **both**
Carmichael's theorem for Fibonacci (`fib_carmichael_band`, verified uniformly over primes and
composites on `13 ≤ n ≤ 1000`) **and** Bang's theorem for `2ⁿ − 1` (`mersenne_bang_band`, verified
on `2 ≤ n ≤ 120`, with the unique Zsygmondy exception `n = 6` isolated automatically by the
computation). The engine never touches a Fibonacci identity — its only number-theoretic step,
`dvd_index_gcd`, uses strong divisibility alone — which is exactly why one `native_decide`-backed
inequality discharges two classically distinct primitive-divisor theorems.

## Results Summary

* `dvd_index_gcd` — `p ∣ u m → p ∣ u n → p ∣ u (gcd m n)`, the sole structural fact used.
* `primitive_of_coprimePart_pos` — **the engine**: `coprimePart u n > 1` ⟹ `u n` has a primitive
  prime divisor, for every strong divisibility sequence `u`.
* `fib_isStrongDivSeq`, `mersenne_isStrongDivSeq` — the two concrete instances (from `Nat.fib_gcd`
  and `Nat.pow_sub_one_gcd_pow_sub_one`).
* `fib_carmichael_band` — Carmichael, `sorry`-free, on `13 ≤ n ≤ 1000`.
* `mersenne_bang_band` — Bang, `sorry`-free, on `2 ≤ n ≤ 120`, `n ≠ 6`.

All depend only on `propext / Classical.choice / Quot.sound / Lean.ofReduceBool / Lean.trustCompiler`.

## Research Directions

### 1. Make the exceptional set a *theorem*, not an observed artifact.

For Fibonacci the engine's failures are exactly `{1, 2, 6, 12}`; for `2ⁿ − 1` exactly `{1, 6}`.
Prove `coprimePart Nat.fib n = 1 ↔ n ∈ {1,2,6,12}` for `n ≥ 1`, and the analogous statement for base
`2`, turning the empirically isolated exceptions into closed-form characterizations.
**The key insight is** that `coprimePart u n = 1` is equivalent to "every prime of `u n` already
divides some `u d` with `d ∣ n`, `d < n`", a *finite* divisor condition that the strong-divisibility
meet law (`dvd_index_gcd`) reduces to a statement about the maximal-divisor lattice of `n` — so the
exceptions are forced by small-index arithmetic, not by analysis. **Why now?** The criterion already
makes `coprimePart` the canonical witness; pinning its zero-set is the natural next invariant and
needs only the lattice lemmas already proved in `StrongDivisibilitySequences.lean`.

### 2. Close the infinite tail with one inequality, uniformly across families.

State `coprimePart u n > 1` for all `n` beyond a family-dependent threshold by proving the *single*
size estimate `u n > ∏_{d ∣ n, d < n} gcd(u n, u d)`. For Fibonacci this is `φ^{φ(n)}`-vs-`n`; for
`2ⁿ − 1` it is `2^{φ(n)}`-vs-`n`. **The key insight is** that `coprimePart u n` divides
`u n / ∏ (shared parts)`, so a *lower bound* on `u n` that beats the product of pairwise gcds with
proper divisors already forces the coprime part above `1` — converting both deep existence theorems
into the *same* exponential-beats-product inequality. **Why now?** The engine has reduced existence
to "`coprimePart > 1`"; only a growth bound on that computable quantity is missing, and it is one
inequality shared by every strong divisibility sequence rather than one per family.

### 3. A primitive-divisor criterion for *all* Lucas sequences `U_n(P,Q)`.

Generalize `mersenne_isStrongDivSeq` from `aⁿ − 1` to the Lucas sequence `U_n(P,Q)` (with
`gcd(P,Q)=1`), which is also a strong divisibility sequence, and instantiate the engine to obtain
Carmichael–Zsygmondy primitive divisors for the whole family in one stroke. **The key insight is**
that `Nat.fib` and `2ⁿ − 1` are merely the cases `(P,Q) = (1,−1)` and `(3,2)`; the file's `dvd_index_gcd`
is the *only* hook, so any proof of the strong-divisibility law for `U_n` plugs straight in. **Why
now?** Both existing instances are already two-line consequences of a gcd identity, so the bottleneck
is purely a Mathlib-level Lucas-sequence `gcd` lemma — a focused, self-contained target.

### 4. Multiplicity via lifting-the-exponent, read off the engine's recursion.

The recursion in `removePrimesOf` divides out `gcd a b` repeatedly; conjecture and prove that the
number of divisions of `u n` by primes of `u d` equals `v_p(u n) − v_p(u (gcd n d))`, i.e. an LTE law
`v_p(u n) = v_p(u z) + v_p(n)` for the entry point `z = z(p) ∣ n` (Fibonacci: `p ≠ 2,5`). **The key
insight is** that `removePrimesOf`'s `native_decide`-observed behaviour — each non-primitive prime
surviving to multiplicity `v_p(n)` — is exactly the LTE statement made symbolic, so the engine's
control flow *is* the multiplicative skeleton of the proof. **Why now?** With `dvd_index_gcd` and the
coprime-part divisibility already formalized, LTE is the one missing multiplicative ingredient, and a
catalog file (`...Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`) already targets the needed
valuation bounds.

### 5. Push and calibrate the verified bands to de-risk Direction 2.

Extend `fib_carmichael_band` to `n ≤ 5000` and `mersenne_bang_band` to `n ≤ 500` with sharded
`native_decide`, and record the *minimum observed ratio* `coprimePart u n / (∏ shared gcds)` across
each band. **The key insight is** that the empirical minimum of this ratio is already `> 1` with
visibly growing slack, so the band is not merely a checked instance but *quantitative evidence
calibrating the constant* in Direction 2's inequality — and identical instrumentation works for both
families because `coprimePart` is family-agnostic. **Why now?** `coprimePart` is fully computable and
the `native_decide` infrastructure is in place; extending the bands is cheap and directly measures
the margin the analytic proof must clear.
