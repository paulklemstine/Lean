# Future Directions — Fibonacci Entry-Point Theory and Carmichael's Primitive-Divisor Theorem

## Synthesis

The catalog's Carmichael work (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibonacciEntryPointDuality.lean`)
is organized around the *entry point* (rank of apparition) `entryPt m = min { k > 0 : m ∣ F_k }`.
Those files establish the divisibility plumbing (`fibEntryPt_dvd_of_fib_dvd`,
`primitive_of_entryPt_eq`) but treat totality of the entry point and the finite range
`n ≤ 10000` as `native_decide` certificates, and leave the genuine tail — every composite
`n > 10000` admits a primitive prime divisor of `F_n` — as a `sorry`.

This cycle isolates and proves, fully `sorry`-free, the *structural core* on which all of
that rests (`Catalog/Novelty/FibonacciEntryPointTheory.lean`):

* `entry_exists` — **totality**: every `m ≥ 1` divides some positive Fibonacci number,
  so `entryPt` is a genuine total function rather than a partial one patched with `0`.
  The proof is a pure-periodicity / pigeonhole argument on the state `(F_k, F_{k+1}) mod m`.
* `fib_dvd_iff_entryPt_dvd` — the **divisibility characterization** `m ∣ F_n ↔ entryPt m ∣ n`,
  generalising `Nat.fib_dvd` and `Nat.fib_gcd` into a single biconditional.
* `primitive_iff_entryPt_eq` — `p` is a primitive prime divisor of `F_n` **iff** `entryPt p = n`,
  abstracting the catalog's one-directional `primitive_of_entryPt_eq` into an exact criterion.

## Results Summary

Six theorems, no `sorry`, axioms `{propext, Classical.choice, Quot.sound}` only.
The headline characterizations turn "primitive divisor" questions into elementary
divisibility questions about a single total arithmetic function `entryPt`.

## Research Directions

### 1. Entry points respect the CRT: a coprime-multiplicativity law
**Conjecture.** For coprime `m, n ≥ 1`, `entryPt (m * n) = Nat.lcm (entryPt m) (entryPt n)`.
The key insight is that, via `fib_dvd_iff_entryPt_dvd`, the predicate `m * n ∣ F_k` factors
as `(m ∣ F_k) ∧ (n ∣ F_k)`, i.e. `entryPt m ∣ k ∧ entryPt n ∣ k`, whose least positive
solution is exactly `lcm`. **Why now?** The biconditional `fib_dvd_iff_entryPt_dvd` proved
this cycle reduces the statement to `Nat.lcm` being the join of the divisibility lattice —
no new analysis is needed, only `Nat.Coprime.dvd_of_dvd_mul_right` style plumbing. This is
the cleanest possible falsifiable next step and immediately reduces `entryPt` of any integer
to its prime-power components.

### 2. The size estimate that closes the `n > 10000` Carmichael tail
**Conjecture.** For all `n ≥ 13`, the primitive part `primPart n` (defined in
`Catalog/Shared/CarmichaelProof.lean`) satisfies `1 < primPart n` *unboundedly*, because
`log F_n ≈ n log φ` strictly dominates `∑_{d ∣ n, d < n} log F_d`. Concretely, for composite
`n`, `∏_{d ∣ n, d < n} F_d < F_n`, so stripping all `F_d` from `F_n` cannot reach `1`.
The key insight is that primitivity is *forced by growth*: the entry-point characterization
already guarantees that any surviving prime factor is primitive, so the only missing ingredient
is the inequality `∑_{d ∣ n, d < n} d ≤ n - 1` combined with `F_d ≤ φ^{d-1}` and
`F_n ≥ φ^{n-2}`. **Why now?** `primitive_iff_entryPt_eq` removes the number-theoretic content
and leaves a purely *quantitative* comparison of Fibonacci magnitudes — a `Nat`/`Real`
inequality of the kind that is routine to formalise, directly retiring the catalog `sorry`.

### 3. Exact exception set for primitive divisors (sharp Carmichael)
**Conjecture.** `F_n` has a primitive prime divisor for every `n` *except* `n ∈ {1, 2, 6, 12}`,
and these four are the *only* exceptions. The key insight is that `primitive_iff_entryPt_eq`
recasts "no primitive divisor" as "every prime factor `p ∣ F_n` has `entryPt p < n`", a finite,
checkable condition once the growth bound of Direction 2 caps the candidate range. **Why now?**
With totality (`entry_exists`) and the primitivity criterion in hand, the exceptional set is a
*finite* search glued to the asymptotic bound, making the sharp statement provable rather than
merely verified on a range.

### 4. Pisano period versus entry point
**Conjecture.** The Pisano period `π(m)` (least `t > 0` with `F_{k+t} ≡ F_k (mod m)` for all `k`)
is always a multiple of `entryPt m`, and for an odd prime `p` the ratio `π(p) / entryPt(p) ∈ {1, 2, 4}`.
The key insight is that the pigeonhole/pure-periodicity argument inside `entry_exists` actually
constructs `π(m)` as the order of the state-transition map `T(a,b) = (b, a+b)` on `(ZMod m)²`,
and `entryPt m` is the first return of the *first coordinate* to `0`; the quotient measures the
multiplicative order of `F_{entryPt+1}` modulo `m`. **Why now?** The state-map machinery is
already built and verified in this cycle, so promoting it from "a period exists" to "the period
is `orderOf T`" is an incremental, falsifiable refinement.

### 5. Zsygmondy beyond Fibonacci: nondegenerate Lucas sequences
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P, Q)` (with `U_0 = 0`, `U_1 = 1`,
`U_{n+2} = P·U_{n+1} - Q·U_n`, `gcd(P,Q)=1`, `P² - 4Q ≠ 0`), the entry-point characterization
`m ∣ U_n ↔ entryPt_U m ∣ n` holds verbatim, and `U_n` has a primitive prime divisor for all
`n` outside an explicit finite set depending only on `(P, Q)`. The key insight is that *nothing*
in this cycle's proofs used `P = Q = 1` beyond the recurrence and the reversibility
`U_a = (U_{a+2} - P·U_{a+1}) / (-Q)` modulo `m` (a unit since `gcd(Q,m)=1` on the relevant part);
the state map `(a,b) ↦ (b, P·b - Q·a)` is still a bijection on `(ZMod m)²` when `Q` is a unit.
**Why now?** The Fibonacci proofs are written against the abstract two-term recurrence pattern,
so generalising them is a parameterisation exercise rather than a new theory — the most direct
route toward a Lean formalisation of the Bilu–Hanrot–Voutier primitive-divisor theorem.
