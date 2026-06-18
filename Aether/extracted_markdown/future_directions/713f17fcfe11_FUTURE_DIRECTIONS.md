# Future Directions — The Unified Primitive-Divisor Engine

## Synthesis

This cycle took the catalog's two parallel threads — the Fibonacci-specific composite-case
machinery of `Shared.CarmichaelProof` (the `stripAllAux`/`primPart` "primitive part"
construction, certified on `13 ≤ n ≤ 10000` by `native_decide`) and the abstract
strong-divisibility-sequence engine of `Applications.UnifiedRankOfApparition`
(`IsStrongDivSeq`, `rank`, `rank_dvd_iff`) together with its prime-index corollary
`Speculative.AutoResearch.PrimitiveDivisorEntryLaw.sds_primitive_divisor_prime` — and fused
them. The new file `Speculative.AutoResearch.UnifiedPrimitivePart` shows that the *entire*
composite-case primitive-part engine is sequence-agnostic: the only fact it needs is the
gcd-meet law `u (gcd k n) = gcd (u k) (u n)`. The pay-off is that **one** generic theorem,
`genPrimPart_implies_primitive`, produces *both* Carmichael's composite case for Fibonacci
*and* Bang's theorem (composite case) for the Mersenne numbers `2ⁿ − 1`, each certified on a
finite range by the same `native_decide` idiom.

The deep structural takeaway: the existence of a primitive divisor is governed entirely by a
single positivity statement, `1 < genPrimPart u n`. Everything number-theoretic about the
sequence collapses into the meet law (`IsStrongDivSeq`) plus this one inequality. This both
explains why Carmichael (Fibonacci) and Bang (`2ⁿ−1`) are "the same theorem" and isolates the
one genuinely hard ingredient — bounding the primitive part from below for *all* `n`, not just
a finite range.

## Results Summary

All results below are `sorry`-free; their axiom footprint is exactly
`propext, Classical.choice, Quot.sound` (plus `Lean.ofReduceBool, Lean.trustCompiler` from
`native_decide` on the finite-range instances).

* `genPrimPart` — the generic primitive part of `u n` (strip every prime appearing in `u d`
  for proper `d ∣ n`), generalizing `Shared.CarmichaelProof.primPart`.
* `genPrimPart_dvd` — `genPrimPart u n ∣ u n`.
* `genPrimPart_coprime_proper_divs` — for positive `u`, the least prime factor of a nontrivial
  `genPrimPart u n` divides no `u d` with `d` a proper divisor of `n`.
* `genPrimPart_implies_primitive` — **the engine**: for any strong divisibility sequence `u`
  with positive terms, `1 < genPrimPart u n` yields a primitive prime divisor of `u n`.
* `fib_carmichael_composite_range` — Carmichael's composite case, `13 ≤ n ≤ 10000`, recovered
  from the engine.
* `mersenne_bang_composite_range` — Bang's theorem, composite case, `7 ≤ n ≤ 64`, **new**,
  from the same engine.
* `fib_primitive_divisor_range` — the full Carmichael statement (prime + composite) on
  `13 ≤ n ≤ 10000`, prime case via `sds_primitive_divisor_prime`, composite via the engine.

The pre-existing open `sorry` in `Shared.CarmichaelProof.fib_carmichael_composite` (the
infinite composite tail `n > 10000`) remains — it is precisely the grand challenge below, and
the engine here reframes it as a single inequality.

## Research Directions

### Direction 1 — The primitive-part lower bound is the whole game

**Conjecture.** For Fibonacci, `1 < genPrimPart Nat.fib n` holds for *every* `n ≥ 13`
(not merely `n ≤ 10000`); equivalently `genPrimPart Nat.fib n ≥ 2` for all `n ∉ {1,2,6,12}`.
Proving this single inequality immediately discharges the open `sorry` in
`fib_carmichael_composite` via `genPrimPart_implies_primitive`, completing Carmichael's
theorem with **no** further sequence-specific work.

The key insight is that the catalog's split at `n = 10000` is an artifact of `native_decide`,
not of the mathematics: `genPrimPart_implies_primitive` already proves "the engine works" for
all `n`; only the *evaluation* of `genPrimPart` is finite. So the infinite tail is not a new
theorem about primitivity at all — it is exactly the statement that the stripped residual is
never fully cancelled, i.e. a lower bound on the cyclotomic-like factor `D(n)`.

Why now? Because the engine has just made the reduction exact and Lean-checked: there is now a
*named, typed* target (`1 < genPrimPart Nat.fib n`) standing between the catalog and a complete
formal Carmichael theorem, replacing a vague "do the composite case" with one inequality.

### Direction 2 — Bang's theorem for every base, unconditionally

**Conjecture.** For every base `a ≥ 2`, `1 < genPrimPart (fun k => a ^ k - 1) n` for all
`n ≥ 7` (and more precisely for all `n` outside the classical Zsygmondy exceptions, e.g.
`a = 2, n = 6`). Consequently `mersenne_bang_composite_range` generalizes to arbitrary `a` and
arbitrary `n`, recovering the composite case of the **Bang–Zsygmondy theorem** from the same
engine that does Fibonacci.

The key insight is that `mersenne_isStrongDivSeq a` already holds for *every* `a`, so the engine
applies verbatim to `a ^ k - 1`; the only base-dependent content is again the lower bound on the
primitive part, which for `a ^ k - 1` is the cyclotomic value `Φ_n(a)` minus its single possible
intrinsic prime factor.

Why now? Because the catalog proved `mersenne_isStrongDivSeq` and `mersenne_dvd_iff` for general
`a` but never extracted *existence* of primitive divisors for general `a`; the engine closes that
gap up to one inequality, turning a folklore "and similarly for `aⁿ−1`" into a precise program.

### Direction 3 — A computable witness collapses the analytic bound

**Conjecture.** There is an *elementary, closed-form* lower bound
`genPrimPart u n ≥ B(u, n)` with `B(u,n) > 1` for all large `n`, expressible without cyclotomic
polynomials — e.g. `genPrimPart u n ≥ u n / (∏_{d ∣ n, d < n} gcd(u n, u d))` and a divisor-sum
bound on the denominator. Formalizing `B` and the inequality `B(u,n) > 1` would prove Directions
1 and 2 simultaneously and uniformly.

The key insight is that stripping by `gcd` (what `stripAllAux` does) never removes more than the
product of the pairwise gcds, so the residual is bounded below by an explicit ratio; the analytic
"size of `D(n)`" argument can be replaced by a purely arithmetic divisor-sum estimate that Lean's
`gcd`/`Nat.factorization` API can support.

Why now? Because the engine exposes `genPrimPart` as a concrete `Nat`-valued function with a
proven `∣`-relationship to `u n`; we can now reason about its *magnitude* with Mathlib's
multiplicative-number-theory toolkit rather than re-deriving everything from `α`, `β` and the
golden ratio.

### Direction 4 — Rank meets primitive part: a sharp apparition identity

**Conjecture.** For a strong divisibility sequence `u` with `u 1 = 1`, a prime `q` is a
primitive divisor of `u n` **iff** `rank u q = n`, and moreover the primitive part factors as
`genPrimPart u n = ∏_{q : rank u q = n} q ^ (v_q (u n))`. This unifies the rank engine
(`rank_dvd_iff`) with the primitive-part engine of this cycle into a single exact statement.

The key insight is that "survives the stripping" (the defining property of `genPrimPart`'s prime
factors) is *exactly* "rank equals `n`": both say `q ∣ u n` but `q ∤ u d` for every proper
`d ∣ n`. The two engines were built independently but describe the same set of primes.

Why now? Because both halves now live in the same import graph (`UnifiedPrimitivePart` already
imports the rank engine via `PrimitiveDivisorEntryLaw`), so the identity can be stated and proved
without any new infrastructure — only the bridge between `rank u q = n` and primality of `q` in
`genPrimPart u n`.

### Direction 5 — Counting primitive divisors and a density law

**Conjecture.** The number of *indices* `n ≤ N` for which `u n` has a primitive divisor is
`N − O(1)` (all but finitely many), and the count of distinct primitive primes appearing among
`u 1, …, u N` grows like `∑_{n ≤ N} ω(genPrimPart u n)`. For Fibonacci this should give an
explicit asymptotic for the number of "new" primes introduced by the Fibonacci sequence up to
index `N`.

The key insight is that primitive divisors partition the prime factors of the whole sequence by
their rank (Direction 4), so counting primitive divisors is counting primes weighted by the index
at which they first appear — a question now phrased entirely in terms of `genPrimPart` and `rank`.

Why now? Because the catalog already has `apparition_count` (density `1/n` of indices hit by a
fixed prime) in `StrongDivisibilitySequences`; combining it with the primitive-part factorization
of Direction 4 turns a counting heuristic into a falsifiable asymptotic with a Lean-checkable
finite-range instance via `native_decide`.
