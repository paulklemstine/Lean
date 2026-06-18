# Future Directions: The Rank of Apparition and Fibonacci Primitive Divisors

The file `Catalog/Speculative/AutoResearch/FibonacciApparition.lean` establishes, fully
`sorry`-free, the foundational theory of the **Fibonacci entry point** (rank of apparition)
`fibEntry m` — the least `k > 0` with `m ∣ F k` — culminating in the *law of apparition*
`m ∣ F k ↔ fibEntry m ∣ k` and the characterisation of primitive prime divisors of `F n`
as exactly those primes `p` with `fibEntry p = n`. This recasts the catalog's Carmichael
targets (`fib_primitive_divisor`, `fib_carmichael`, `fib_carmichael_composite`) as
statements about a single arithmetic function. The directions below extend that frontier.

## Direction 1 — Closing the infinite tail of Carmichael's theorem via apparition

The catalog's `fib_carmichael_composite` discharges `13 ≤ n ≤ 10000` by `native_decide`
but leaves composite `n > 10000` as a `sorry`. The entry-point framework reduces this to a
single growth inequality: `F n` has a primitive prime divisor iff the *primitive part*
`Φ_n = F n / ∏_{d ∣ n, d < n} F d` exceeds the contribution of "intrinsic" (non-primitive)
factors, and the only possible non-primitive prime divisor of `Φ_n` is the largest prime
factor `q` of `n`, dividing `Φ_n` exactly once. **The key insight is** that
`fibEntry p = n` partitions the prime divisors of `F n` cleanly, so a Zsygmondy-style
bound `Φ_n > q` for `n > 12` (provable from `φ(α^n) ≍ α^{φ(n)}` with `α = (1+√5)/2`)
closes the tail *uniformly*, eliminating the `10000` cutoff entirely.
**Why now?** The law of apparition is now a proved lemma in this project, so the reduction
from "primitive divisor exists" to "one explicit real-analytic inequality" is purely
mechanical — the remaining work is a single growth estimate rather than a full number-theoretic edifice.

## Direction 2 — The apparition bound `fibEntry p ∣ p − (5 ∣ p)`

For an odd prime `p ≠ 5`, the rank of apparition divides `p − (5/p)` where `(5/p)` is the
Legendre symbol; equivalently `fibEntry p ∣ p − 1` when `p ≡ ±1 (mod 5)` and
`fibEntry p ∣ p + 1` when `p ≡ ±2 (mod 5)`. **The key insight is** that this is the
Fibonacci shadow of Fermat's little theorem in `ZMod p[√5]`: `α^p ≡ α^{(5/p)}`, which our
`fibPair`/`ZMod` machinery already models, so the bound becomes
`p ∣ F_{p − (5/p)}` and then `fibEntry p ∣ p − (5/p)` by the *proved* law of apparition.
**Why now?** The hard direction — turning a congruence into a divisibility of indices —
is exactly `fib_dvd_iff_fibEntry_dvd`, which is finished; only the Frobenius congruence in
the quadratic ring `ZMod p[√5]` remains, and Mathlib's `ZMod` and `Polynomial` API now
make that congruence routine.

## Direction 3 — The Wall–Sun–Sun phenomenon: `fibEntry (p²) = p · fibEntry p`

It is conjectured (and verified for all `p < 2^64`) that for every prime `p`,
`fibEntry (p²) = p · fibEntry p`; a prime violating this is a *Wall–Sun–Sun prime*, none of
which are known. **The key insight is** that `fibEntry` lifts through prime powers by a
single factor of `p` precisely when `F_{fibEntry p}` is divisible by `p` but not `p²`, so
the conjecture is equivalent to the falsifiable statement "`p² ∤ F_{fibEntry p}` for all
primes `p`" — a condition our entry-point definition states directly and which is
machine-checkable for any finite range. **Why now?** With `fibEntry` formalised, this
folklore conjecture acquires a *precise Lean statement* for the first time, turning an
informal computational search into a verifiable predicate `¬ p^2 ∣ Nat.fib (fibEntry p)`
that can be both checked numerically and reasoned about abstractly.

## Direction 4 — Strong-divisibility abstraction: apparition for general Lucas sequences

Every result in the file used only two facts: `gcd(F m, F n) = F (gcd m n)`
(strong divisibility) and `m ∣ n → F m ∣ F n`. **The key insight is** that the *entire*
law of apparition and primitive-divisor characterisation are theorems about any
**strong divisibility sequence** `u : ℕ → ℕ` with `u 0 = 0` and `gcd(u m, u n) = u (gcd m n)`
— including Lucas sequences `U_n(P,Q)`, Mersenne-type sequences `a^n − 1`, and resultant
sequences. Abstracting `fibEntry` to `seqEntry u m` would subsume the Fibonacci, Mersenne,
and cyclotomic primitive-divisor theories under one roof. **Why now?** The Fibonacci proof
is the minimal working prototype; refactoring it against a `StrongDivisibilitySeq`
typeclass is a structural generalisation with no new mathematical risk, and it directly
bridges the catalog's number-theory and tropical/valuation domains (apparition is a
discrete valuation on the index lattice).

## Direction 5 — A "proof phase transition": threshold density of primitive indices

Frame the original cycle's *phase-transition* theme number-theoretically: for the random
model where `p` ranges over primes up to `N`, what is the limiting density of indices
`n ≤ M` that arise as `fibEntry p` for some `p` (the "realised ranks")? **The key insight
is** that `prime_primitive_divisor_iff` makes "`n` is a realised rank" equivalent to "`F n`
has a primitive prime divisor", so by Carmichael's theorem the realised ranks are
*cofinite* (all `n ∉ {1,2,6,12}`) — a sharp `density → 1` threshold, the arithmetic analogue
of a satisfiability phase transition. **Why now?** The equivalence between the analytic
question (density of realised ranks) and the algebraic one (existence of primitive divisors)
is now a *proved* iff in this project, so the phase-transition statement can be formalised
as `{n | ∃ p, Nat.Prime p ∧ fibEntry p = n}ᶜ` being finite — a concrete, falsifiable target
that unifies the cycle's stated theme with the concrete Fibonacci mathematics delivered here.
