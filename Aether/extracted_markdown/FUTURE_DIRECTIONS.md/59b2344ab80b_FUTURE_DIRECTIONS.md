# Future Directions: Primitive Prime Divisors of Fibonacci Numbers

## Synthesis

This cycle targeted the single open `sorry` in `Catalog/Shared/CarmichaelProof.lean`:
the *composite, large-index* tail of **Carmichael's primitive-divisor theorem** for the
Fibonacci sequence — the statement that for every composite `n > 10000` the Fibonacci
number `F n` has a *primitive* prime divisor (a prime dividing `F n` but none of
`F 1, …, F (n-1)`).  The finite range `13 ≤ n ≤ 10000` is already discharged in the file by
`native_decide` via the coprime-stripping `primPart`; the infinite tail is the genuine
mathematical heart.

Rather than reproving the existing entry-point material (`Applications.FibonacciEntryPoints`,
`Novelty.FibonacciEntryPointInvariant`, `Speculative.AutoResearch.CarmichaelComposite`), we
**factored out the structural skeleton** of the tail into a new, fully proved
(`sorry = 0`) file, `Catalog/Shared/CarmichaelReduction.lean`:

* `Nat.exists_prime_dvd_quot_of_dvd_lt` — the lattice covering lemma: every proper divisor
  `d ∣ n` sits under a *maximal* proper divisor `n / q` (`q` prime, `q ∣ n`).
* `Nat.fib_dvd_fib_iff` — the **strong divisibility law** `F m ∣ F n ↔ m ∣ n` for `3 ≤ m`.
* `fib_nonprimitive_dvd_fib_maximal` — every non-primitive prime divisor of `F n` already
  divides some `F (n / q)`.
* `fib_primitive_iff_not_dvd_maximal` — **the main reduction**: `F n` has a primitive prime
  divisor *iff* some prime `p ∣ F n` divides **none** of the finitely many `F (n / q)`.

The reduction collapses an infinite conjunction (over all `0 < k < n`) into a finite check
against the maximal proper divisors. What remains to close the tail is purely *analytic*:
a lower bound on the size of the primitive part. We could not complete that lower bound in
this cycle — it requires machinery genuinely absent from Mathlib — so the `sorry` stands,
now documented and reduced to a precise analytic statement.

## Results Summary

| Result | File | Status |
|---|---|---|
| Lattice covering of proper divisors | `CarmichaelReduction.lean` | proved, `sorry = 0` |
| Strong divisibility law `F m ∣ F n ↔ m ∣ n` (`3 ≤ m`) | `CarmichaelReduction.lean` | proved, `sorry = 0` |
| Non-primitive ⇒ divides a maximal `F (n/q)` | `CarmichaelReduction.lean` | proved, `sorry = 0` |
| Primitive-divisor reduction to maximal divisors | `CarmichaelReduction.lean` | proved, `sorry = 0` |
| Golden-ratio quadratic `φ² = φ + 1` | `CarmichaelSizeBound.lean` | proved, `sorry = 0` |
| Two-sided Binet bounds `φ^(n-1) ≤ F(n+1) ≤ φ^n` | `CarmichaelSizeBound.lean` | proved, `sorry = 0` |
| Möbius–totient identity `∑_{d∣n} μ(n/d)·d = φ(n)` | `CarmichaelSizeBound.lean` | proved, `sorry = 0` |
| Composite large-tail of Carmichael | `CarmichaelProof.lean` | open `sorry`, reduced + documented |

A repair to the project build was also required: the `lakefile.toml` source root was set to
`Catalog` (`srcDir`), and a thin re-export `Catalog/Shared/CarmichaelHelper.lean` was added
so the existing `import Shared.CarmichaelHelper` paths resolve.

## Research Directions

### Direction 1 — The Binet–Möbius size bound for the Fibonacci primitive part

Define the primitive part `Φ n = ∏_{d ∣ n} (F d) ^ μ(n/d) = F n / lcm_{q ∣ n prime} F (n/q)`.
A primitive prime divisor of `F n` exists once `Φ n` exceeds the largest prime factor of `n`.
The conjecture to formalize is the clean lower bound

> For all `n ≥ 1`, `Φ n ≥ goldenRatio ^ (totient n) / 4`, hence `Φ n > n` for composite `n > 10000`.

**The key insight is** that taking logarithms and using Binet's formula
`F d = (φ^d − ψ^d)/√5` makes the error terms a *geometrically convergent* series: the `√5`
factors cancel because `∑_{d ∣ n} μ(n/d) = 0` for `n > 1`, the main term is
`(∑_{d ∣ n} μ(n/d)·d)·log φ = totient(n)·log φ` (the identity `id ⋆ μ = φ` of arithmetic
functions), and `∑_{d ∣ n} |log(1 − (ψ/φ)^d)|` is bounded by an absolute constant since
`|ψ/φ| = φ^{-2} < 1`. This is falsifiable: a single composite `n` with `Φ n ≤ n` would
refute it (none exists, but the bound is sharp enough to check numerically up to any range).
**Why now?** Mathlib 4 now ships `Mathlib/NumberTheory/Real/GoldenRatio.lean`
(`goldenRatio_mul_fib_succ_add_fib`, `fib_succ_sub_goldenRatio_mul_fib`) and the
`ArithmeticFunction` Möbius-inversion API, so both the Binet identities and the divisor-sum
algebra are finally available off the shelf; only their *combination* is missing.

### Direction 2 — Fibonacci lifting-the-exponent (the intrinsic-prime bound)

To turn "`Φ n` is large" into "`Φ n` has a *primitive* prime factor" one must bound the
*intrinsic* (non-primitive) primes that can divide `Φ n`. The conjecture is the Fibonacci
analogue of LTE:

> For an odd prime `p ≠ 5` with rank of apparition `e = entryPoint p` and `e ∣ n`,
> `v_p(F n) = v_p(F e) + v_p(n / e)`; for `p = 2, 5` an explicit closed form holds.

**The key insight is** that `F n` is the Lucas value `(φ^n − ψ^n)/√5` with `φ, ψ` the roots
of `x² = x + 1`, so Mathlib's integer LTE `Int.emultiplicity_pow_sub_pow` applies in the
ring `ℤ[φ]` after clearing `√5`, reducing the Fibonacci statement to the already-formalized
`x^n − y^n` case. This is falsifiable on any `(p, n)` pair by direct computation. **Why now?**
The general LTE lemmas were added to Mathlib's `NumberTheory/Multiplicity.lean`; the only new
work is the descent from `ℤ[φ]` valuations to `v_p(F n)`, plus the small `p ∈ {2,5}` cases.

### Direction 3 — A uniform Zsygmondy reduction for strong divisibility sequences

`Novelty.FibonacciEntryPointInvariant` already abstracts entry points to arbitrary strong
divisibility sequences `u` (`gcd (u m) (u n) = u (gcd m n)`), covering Fibonacci and
`a^n − 1` simultaneously. The reduction theorems of this cycle (`fib_primitive_iff_not_dvd_maximal`)
are *also* purely strong-divisibility facts. The conjecture:

> The covering lemma and primitive-divisor reduction hold verbatim for **every** strong
> divisibility sequence; Carmichael (Fibonacci) and Zsygmondy (`a^n − 1`) differ only in
> the analytic size input of Direction 1.

**The key insight is** that the entire combinatorial skeleton of primitive-divisor theorems
is `gcd`-functoriality, which is exactly the strong divisibility axiom — nothing Fibonacci-
specific enters before the size estimate. **Why now?** With the abstract `StrongDivSeq`
namespace and the concrete `mersenne_strong_div` instance already in the catalog, promoting
`fib_primitive_iff_not_dvd_maximal` to `StrongDivSeq` would immediately yield the Mersenne /
repunit reduction for free, unifying two classical theorems under one lemma.

### Direction 4 — Sharpening the computational frontier

The current proof checks `13 ≤ n ≤ 10000` by `native_decide` on `primPart`. The conjecture:

> The crossover where the Binet–Möbius bound `Φ n > n` becomes unconditionally provable
> (no case analysis) is far below `10000`; with the bound of Direction 1 the `native_decide`
> range can be shrunk to `n ≤ 12` (the genuine exceptional set `{1, 2, 6, 12}`).

**The key insight is** that `Φ n > n` already holds for all `n ≥ 13` once the constant in the
Binet bound is made explicit, so the only true exceptions are the classical
`{1, 2, 6, 12}` — the computational range is an artifact of not yet having the analytic bound.
**Why now?** Eliminating the `native_decide` dependency would make the whole development
kernel-checkable without `ofReduceBool`, a strictly stronger soundness guarantee that is
within reach once Direction 1 lands.

### Direction 5 — Counting primitive divisors and a Fibonacci density statement

The injectivity result `fib_primitive_divisor_inj` (distinct indices have disjoint primitive
divisor sets) plus existence (Carmichael) yields a counting corollary. The conjecture:

> The number of distinct primes dividing some `F k` with `k ≤ N` is at least `N − C` for an
> absolute constant `C`; equivalently, the map `n ↦ (least primitive prime divisor of F n)`
> is injective off a finite set.

**The key insight is** that existence contributes one *new* prime per index `n ∉ {1,2,6,12}`
and injectivity guarantees these primes are never reused, so the count grows linearly. **Why
now?** Both ingredients (existence after Directions 1–2, injectivity already proved) would be
in place, making this a short corollary that converts the qualitative theorem into a
quantitative density bound — a natural springboard toward Fibonacci analogues of
Bang–Zsygmondy prime counting.
