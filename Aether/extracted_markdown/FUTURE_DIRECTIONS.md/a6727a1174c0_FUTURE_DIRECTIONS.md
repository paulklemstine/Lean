# Future Directions — The Entry-Point (Rank-of-Apparition) Program

## Synthesis of this cycle

This cycle closed two open `sorry` targets and built a structural bridge across
the catalog's two parallel entry-point developments.

* In `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`
  we completed the **lcm law** `fibEntryPt_mul_coprime`: for coprime `a, b` each
  admitting a Fibonacci apparition index, `α(a·b) = lcm(α a, α b)`. This is the
  engine that reduces every entry-point computation to the prime-power case.

* In the new file `Catalog/Speculative/AutoResearch/FibEntryBridge.lean` we proved
  that the Fibonacci-specific `FibEntryChar.fibEntryPt` and the abstract
  `RankOfApparition.entry Nat.fib` (from `EntryPointMultiplicativity.lean`) are
  *literally the same function* (`fibEntryPt_eq_entry`, by `rfl`), and then
  generalized the Fibonacci-only **primitive-divisor characterization** to every
  strong divisibility sequence: `entry_eq_iff_primitive` says that, in any
  `IsSDS` sequence, `entry u p = n` iff `p` is primitive at `n` (divides `u n`
  but no earlier positive-index term). Specializations recover the Fibonacci case
  and give, for free, the Mersenne/repunit case
  (`mersenne_entry_eq_iff_primitive`), where the entry point is the multiplicative
  order — so "primitive prime divisor of `aⁿ − 1`" and "order `= n`" are one and
  the same statement.

## Results summary

| Theorem | File | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` (lcm law) | `FibonacciEntryPointCharacterization.lean` | proved, sorry = 0 |
| `fibEntryPt_eq_entry` (definitions coincide) | `FibEntryBridge.lean` | proved |
| `entry_eq_iff_primitive` (abstract primitivity) | `FibEntryBridge.lean` | proved |
| `fibEntryPt_dvd_entry_of_dvd` (order-side morphism) | `FibEntryBridge.lean` | proved |
| `fib_entryPt_eq_iff_primitive` (Fibonacci) | `FibEntryBridge.lean` | proved |
| `mersenne_entry_eq_iff_primitive` (Mersenne) | `FibEntryBridge.lean` | proved |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.
(As an enabling fix, the package `srcDir` was set to `Catalog` in `lakefile.toml`
so that the catalog's cross-file imports resolve at all.)

## Research directions for the next cycle

### 1. Totality of the entry point (the Pisano apparition theorem)

Every theorem above carries an `Appears`/existence hypothesis ("`p` divides some
positive-index term"). Conjecture: for **every** prime `p` this hypothesis is
automatic — `∃ k, 0 < k ∧ p ∣ Nat.fib k` — so `fibEntryPt p > 0` for all primes,
and the whole theory becomes unconditional. The key insight is that the Fibonacci
sequence taken modulo `p` is eventually periodic on a finite state space and its
two-step recurrence is invertible mod `p`, so the pair `(0, 0)` (hence a genuine
zero `F k ≡ 0`) must recur inside one period. This is falsifiable: a single prime
with no apparition index up to its Pisano period would refute it. Why now? With
`fibEntryPt_mul_coprime` and `entry_eq_iff_primitive` already in place, totality
is the one missing input that upgrades every conditional corollary in
`FibEntryBridge.lean` to a clean unconditional statement, and Mathlib already has
`ZMod` periodicity machinery to drive the pigeonhole argument.

### 2. Full prime-power reconstruction of the entry point

Conjecture: for `n > 0` whose prime-power factors all appear,
`fibEntryPt n = ∏'`-style lcm over the factorization, i.e.
`fibEntryPt n = (n.factorization.support).lcm (fun p => fibEntryPt (p ^ n.factorization p))`.
The key insight is that `fibEntryPt` is a *lattice morphism*: it sends the
multiplicative (coprime-product) structure of `n` to the join (lcm) of the
entry points of its prime-power parts, exactly as the proven two-factor law
`fibEntryPt_mul_coprime` predicts. This is falsifiable against any `n` by direct
computation of both sides. Why now? The coprime two-factor case is done; the
general case is a `Nat.factorization`/`Finset.induction` lift using pairwise
coprimality of distinct prime powers, with no new number theory required.

### 3. Carmichael's primitive-divisor theorem as surjectivity of `α`

The remaining open `sorry` in `Catalog/Shared/CarmichaelProof.lean`
(`fib_carmichael_composite` for composite `n > 10000`) is exactly the assertion
that `F(n)` has a primitive prime divisor. Via `fib_entryPt_eq_iff_primitive`,
this is equivalent to: **there exists a prime `p` with `fibEntryPt p = n`** — i.e.
the entry-point map is surjective onto `ℕ \ {1, 2, 6, 12}` when restricted to
primes. The key insight is that the bridge converts an existence-of-divisor
question into a surjectivity question about a concrete arithmetic function, so the
analytic content collapses to a size estimate: the "primitive part" `primPart n`
(already defined in `CarmichaelProof.lean`) exceeds `1` because the `n`-th
cyclotomic value `Φ_n(φ, ψ)` of the Fibonacci Binet pair is too large to be
cancelled by the bounded product of earlier apparition factors. This is
falsifiable by exhibiting any composite `n ∉ {1,2,6,12}` with `primPart n = 1`.
Why now? With primitivity ⇔ `entry = n` proven abstractly, the only missing piece
is the cyclotomic lower bound, which can be developed independently and then
plugged into the already-complete `primPart_implies_primitive` pipeline.

### 4. An abstract Zsygmondy theorem for strong divisibility sequences

`entry_eq_iff_primitive` holds for *every* `IsSDS` sequence, and we have already
instantiated both Fibonacci and Mersenne. Conjecture: a single abstract
primitive-divisor (Zsygmondy/Bang–Carmichael) theorem covers both — for an
`IsSDS` sequence with strictly increasing terms and a multiplicative growth
hypothesis, `u n` has a primitive prime divisor for all but finitely many `n`.
The key insight is that the Fibonacci and Mersenne proofs share the *same*
skeleton — primitivity = `entry = n` plus a cyclotomic-factor size estimate — so
the only genuinely sequence-specific datum is one growth/`gcd` inequality, which
can be isolated as a hypothesis. This is falsifiable: an `IsSDS` sequence meeting
the growth hypothesis but with a large-index term lacking a primitive divisor
would refute it. Why now? The abstract characterization is proved and both
flagship instances are in hand, so abstracting the proof is a matter of naming
the one analytic input rather than inventing new mathematics.

### 5. Quantitative entry-point bounds from quadratic reciprocity

Conjecture: for an odd prime `p ≠ 5`, `fibEntryPt p ∣ (p - χ(p))` where
`χ(p) = ±1` is the Legendre symbol `(5 | p)` (so `α(p) ≤ p + 1`), refining the
order-side morphism `fibEntryPt_dvd_entry_of_dvd` into a sharp numeric bound. The
key insight is that the law of apparition reduces the bound to the *single*
divisibility `p ∣ F(p − χ(p))`, which follows from the Binet formula read in
`𝔽_p` (or its quadratic extension): `p` splits or is inert in `ℤ[φ]` exactly as
`χ(p)` dictates, forcing a root of `x² = x + 1` and hence a zero of `F` at index
`p − χ(p)`. This is falsifiable by any odd prime `p ≠ 5` with `α(p) ∤ (p − χ(p))`.
Why now? `fib_dvd_iff_entryPt_dvd` already turns the bound into one divisibility
statement, and Mathlib's `ZMod`, `legendreSym`, and quadratic-residue API make
the `𝔽_p` Binet computation directly accessible.
