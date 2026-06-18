# FUTURE DIRECTIONS — Carmichael Primitive Divisors via Cyclotomic–Fibonacci Duality

## Synthesis

This cycle closed the standing gap around Carmichael's primitive divisor theorem
for Fibonacci numbers. Three things happened.

First, the build was repaired: the file `Shared.CarmichaelProof` and
`Speculative.AutoResearch.CarmichaelComposite` both imported a `Shared.CarmichaelHelper`
module that did not exist, so nothing in the Carmichael component elaborated. The
helper was rebuilt from scratch and its single export — the **prime case** of the
theorem — was proved cleanly: when the index `n` is prime, *every* prime factor of
`F(n)` is automatically primitive, because the rank of apparition `e(p)` divides `n`
and cannot be `1`. The load-bearing identity is `Nat.fib_gcd`.

Second, we proved the **dual / sharpness direction below the threshold**. The
existence direction in the catalog handles `n ≥ 13`; we now have a complete,
`sorry`-free characterization on `1 ≤ n ≤ 12`: `F(n)` lacks a primitive prime divisor
*iff* `n ∈ {1, 2, 6, 12}`. These four indices are exactly the Carmichael exceptions,
and the proof is finite and decidable once a witness prime is fixed. In the language
of the apparition representation `p ↦ e(p)`, the exceptional indices are precisely the
empty fibers of the dual map `n ↦ {p : e(p) = n}`.

Third, we isolated and documented the one genuinely deep obstruction that remains:
the **infinite tail** `n > 10000` of the composite case. The finite range
`13 ≤ n ≤ 10000` is discharged by a verified computation of the *primitive part*
`primPart n`; the tail is the analytic core of the theorem and is not yet supported
by Mathlib.

## Results Summary

- `fib_primitive_divisor_prime` (prime case, `n ≥ 13`) — proved, `sorry`-free.
- `fib_no_primitive_one`, `fib_no_primitive_two`, `fib_no_primitive_six`,
  `fib_no_primitive_twelve` — the four exceptions, proved, `sorry`-free.
- `carmichael_small_characterization` — the unifying biconditional on `1 ≤ n ≤ 12`,
  proved, `sorry`-free.
- `fib_carmichael_composite` (in `Shared.CarmichaelProof`) — proved on
  `13 ≤ n ≤ 10000`; the tail `n > 10000` is the single remaining `sorry`, fully
  documented in the file's lab notebook.

All proven results were checked to depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. The homogeneous cyclotomic factorization `F(n) = ∏_{d ∣ n} Φ_d`

Define the cyclotomic–Fibonacci value `Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` and prove it is
a positive integer with `F(n) = ∏_{d ∣ n} Φ_d` and `Φ_n ∣ F(n)`. This is the algebraic
backbone of every modern proof of Carmichael's theorem and is the cleanest first
target because it is a pure divisibility/Möbius statement with no analysis. *The key
insight is* that `Φ_n` is the image, under the Binet substitution `x = α, y = β`, of the
homogeneous cyclotomic polynomial `Φ_n(x, y)`, so its integrality is inherited from the
integrality of cyclotomic polynomials already in Mathlib (`Polynomial.cyclotomic`).
*Why now?* The prime case and the small-index characterization proved this cycle already
exercise `Nat.fib_gcd` and the entry-point machinery; the missing piece is purely the
Möbius bookkeeping, which is self-contained and falsifiable by a single integer
computation of `Φ_n` for, say, `n ≤ 50`.

### 2. Carmichael's law of repetition (a Fibonacci lifting-the-exponent theorem)

Prove that for a prime `p` with rank of apparition `e = e(p)`, the `p`-adic valuation
satisfies `v_p(F(e·m)) = v_p(F(e)) + v_p(m)` (with the usual `p = 2, 5` caveats).
Consequently the only non-primitive prime that can divide `Φ_n` is the largest prime
factor of `n`, and it divides `Φ_n` to multiplicity at most one. *The key insight is*
that the Fibonacci sequence is a strong divisibility sequence, so `F(e·m)/F(e)` is a
known polynomial-in-`F` expression whose valuation telescopes exactly as in classical
LTE. *Why now?* This is the precise bridge between the apparition results already in the
catalog (`dvd_fib_iff_entry_dvd`, `fibEntryPt_mul_coprime`) and the multiplicity control
needed for the tail; it is falsifiable by checking `v_p(F(n))` against the formula on a
table of small `(p, n)`.

### 3. A Binet size bound `Φ_n > n` for `n > 12`

Establish `Φ_n ≥ α^{φ(n)-2}` with `α = (1+√5)/2`, hence `Φ_n > n` for all `n > 12`.
Combined with Directions 1–2 this *closes the tail*: `Φ_n` is neither `1` nor a single
copy of the largest prime factor of `n`, so it carries a primitive prime. *The key
insight is* that `|Φ_n|` differs from `α^{φ(n)}` only by a rapidly convergent product of
factors `(1 - α^{-2k})`, so a crude bound on `φ(n)` (e.g. `φ(n) ≥ √(n/2)`) already
dwarfs `n`. *Why now?* It removes the `n ≤ 10000` ceiling entirely, replacing the
`native_decide` window with an unconditional theorem, and is falsifiable by comparing
`Φ_n` with `n` numerically across the current ceiling.

### 4. Generalize the duality to all Lucas sequences (Bilu–Hanrot–Voutier)

Recast the entire pipeline for a general non-degenerate Lucas sequence `U_n(P,Q)` and
characterize its exceptional indices. *The key insight is* that the apparition map
`p ↦ e(p)`, the strong-divisibility identity `U_{gcd} = gcd(U·)`, and the cyclotomic
factorization are *not* special to Fibonacci — they are features of the rank-2 linear
recurrence, so the catalog's Fibonacci lemmas should lift verbatim with `(P,Q)` as
parameters. *Why now?* The small-index characterization proved this cycle is the
`(P,Q)=(1,-1)` instance of the Bilu–Hanrot–Voutier exceptional table; making `(P,Q)`
a parameter turns one theorem into an infinite family, and the conjecture is falsifiable
by instantiating `(P,Q)=(2,-1)` (Pell numbers) and recomputing the exceptions.

### 5. A Stone-type duality between indices and primitive-prime fibers

Conjecture that the assignment `n ↦ Prim(n) := {p : e(p) = n}` and `p ↦ e(p)` form an
adjoint pair whose induced closure operator recovers exactly the divisibility lattice of
indices, so that "primitive prime divisor exists for all but finitely many `n`" becomes
the statement "the dual map has finite empty-fiber locus". *The key insight is* that
`dvd_fib_iff_entry_dvd` already exhibits `{n : p ∣ F(n)}` as a principal up-set `e(p)·ℕ`,
which is precisely the data of a Galois connection between primes and indices; Carmichael's
theorem is then the assertion that this connection is "almost surjective". *Why now?*
The empty-fiber locus is now pinned down below `13` (this cycle) and conjecturally empty
above `12` (Directions 1–3), so the duality statement is fully falsifiable: any index
`n > 12` with `Prim(n) = ∅` would refute it simultaneously with classical Carmichael.
