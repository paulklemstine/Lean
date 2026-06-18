# Future Directions: Fibonacci Entry Points and Primitive Divisors

This cycle formalized the divisibility theory of the *Fibonacci entry point*
(rank of apparition) `α(p) = entryPoint p`, the least `k > 0` with `p ∣ F_k`,
and derived a clean characterization of *primitive prime divisors* of Fibonacci
numbers in `FibonacciEntryPoints.lean`:

* `fib_dvd_gcd` — the gcd–Fibonacci bridge `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd(m,n)}`.
* `dvd_fib_iff_entry_dvd` — `p ∣ F_n ↔ α(p) ∣ n`.
* `primitive_iff_entry_eq` — `p` is a primitive prime divisor of `F_n` iff `α(p) = n`.
* `fib_twelve_no_primitive` — the classical exception: `F_12 = 144` has no primitive divisor.

These results are the analytic backbone of Carmichael's primitive-divisor theorem
already pursued in the catalog (`Speculative.AutoResearch.CarmichaelComposite`,
`Shared.CarmichaelProof`), recast self-containedly against Mathlib so that the
entry-point lemmas no longer depend on the (currently absent) `Shared.CarmichaelHelper`.
Below are concrete, falsifiable next steps.

## Direction 1 — Entry point and the Pisano period

The Pisano period `π(p)` (period of `F` mod `p`) is always a multiple of the entry
point `α(p)`, and the quotient `π(p)/α(p) ∈ {1, 2, 4}`. Formalize
`α(p) ∣ π(p)` and the bound on the quotient, building directly on
`dvd_fib_iff_entry_dvd`.

The key insight is that the multiplicative *order* of the companion matrix `[[1,1],[1,0]]`
mod `p` is exactly `π(p)`, while `α(p)` is the additive index at which the off-diagonal
entry first vanishes; the quotient measures the order of the eigenvalue ratio, a unit
whose order divides 4. Why now? We already have `dvd_fib_iff_entry_dvd`, the exact
"`α(p) ∣ n ↔ p ∣ F_n`" lever needed to transfer between the entry point and the period,
and Mathlib's `ZMod` matrix-order API makes the companion-matrix formulation routine.

## Direction 2 — Law of apparition for `p ≡ ±1 (mod 5)`

For an odd prime `p ≠ 5`, the entry point satisfies `α(p) ∣ p - 1` when `p ≡ ±1 (mod 5)`
and `α(p) ∣ p + 1` when `p ≡ ±2 (mod 5)` (the law of apparition). Formalize this divisibility
as a corollary of `dvd_fib_iff_entry_dvd` together with `p ∣ F_{p-(5/p)}` (a Fibonacci
analogue of Fermat's little theorem, where `(5/p)` is the Legendre symbol).

The key insight is that the Binet identity over `ZMod p` turns `F_{p - (5/p)} ≡ 0`
into a statement about whether `5` is a quadratic residue, so the entry-point divisibility
is precisely the Frobenius action on `√5`. Why now? `dvd_fib_iff_entry_dvd` already reduces
the law of apparition to proving the single congruence `p ∣ F_{p ± 1}`, and Mathlib's
quadratic-reciprocity and `legendreSym` machinery supplies the residue dichotomy off the shelf.

## Direction 3 — Complete the list of Fibonacci exceptions

`fib_twelve_no_primitive` is one of exactly two non-trivial indices (`n = 1, 2, 6, 12`,
with `1, 2` degenerate) where `F_n` lacks a primitive prime divisor (Carmichael 1913).
Prove the converse direction in full: for every `n ∉ {1, 2, 6, 12}`, `F_n` *does* have a
primitive divisor, i.e. some prime `p` with `entryPoint p = n`.

The key insight is that the primitive part `F_n / ∏_{d ∣ n, d < n} gcd(F_n, F_d)`
(the "cyclotomic" factor) exceeds 1 once `F_n` outgrows the product of its proper-divisor
contributions, which holds for all `n ≥ 13` by the exponential growth `F_n ≍ φ^n`. Why now?
We already have `primitive_iff_entry_eq` (existence of a primitive divisor ⇔ some prime has
entry point `n`) and the catalog's `fibCoprimePart`/`primPart` constructions verify the small
cases; the remaining gap is exactly the growth bound `φ^{n-2} > n·φ^{n/2}`, a one-variable
inequality amenable to `Nat.fib` lower bounds.

## Direction 4 — Entry points and the Wall–Sun–Sun phenomenon

A prime `p` is *Wall–Sun–Sun* iff `α(p) = α(p²)`, equivalently `p² ∣ F_{α(p)}`. Formalize the
equivalence `α(p) = α(p²) ↔ p² ∣ F_{α(p)}` and the general inclusion `α(p) ∣ α(p²)`.

The key insight is that `dvd_fib_iff_entry_dvd` applies verbatim with modulus `p²`, so the
entry point of `p²` is the least multiple of `α(p)` whose Fibonacci value is divisible by `p²`;
the lift-the-exponent structure of `v_p(F_{kα(p)})` then forces `α(p²) = p·α(p)` unless `p`
is Wall–Sun–Sun. Why now? Our entry-point framework is modulus-agnostic — every lemma is stated
for an arbitrary divisor `p`, so reusing it for `p²` is immediate, and Mathlib's
`multiplicity`/`Nat.factorization` API gives the `v_p` bookkeeping.

## Direction 5 — Lucas-sequence generalization

All four main theorems hold for any nondegenerate Lucas sequence `U_n(P, Q)` in place of `F_n`,
because the only inputs are the gcd identity `gcd(U_m, U_n) = U_{gcd(m,n)}` and the divisibility
`m ∣ n → U_m ∣ U_n`. Abstract `entryPoint`, `IsPrimitive`, and the three structural theorems to a
typeclass capturing exactly these two properties, then instantiate it at `Nat.fib` and at
`U_n(P,Q)`.

The key insight is that `fib_dvd_gcd` and `dvd_fib_iff_entry_dvd` never touch the Binet formula —
they use *only* `Nat.fib_gcd` and `Nat.fib_dvd`, so a `StrongDivisibilitySequence` interface with
those two axioms is the natural home for the entire development. Why now? The proofs in this file
are already phrased in terms of those two lemmas alone, making the generalization a mechanical
abstraction that immediately yields primitive-divisor theory for Mersenne-type and Pell-type
sequences as free corollaries.
