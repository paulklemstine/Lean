# Future Directions: Rank of Apparition and Fibonacci Primitive Divisors

This cycle introduced `Catalog/Speculative/AutoResearch/FibonacciRankOfApparition.lean`,
a self-contained development of the **rank of apparition** (entry point) of integers in the
Fibonacci sequence. Four theorems are proved with no `sorry` and only the standard kernel
axioms:

- `fib_entryPoint_dvd_iff` — the **law of apparition**: if `a` is the least positive index
  with `p ∣ F a`, then `p ∣ F n ↔ a ∣ n`, with no upper bound on `n`.
- `fib_dvd_iff_of_three_le` — the **strong divisibility law** `F m ∣ F n ↔ m ∣ n` for
  `m ≥ 3`, upgrading Mathlib's one-directional `Nat.fib_dvd` to an equivalence.
- `fib_primitive_iff_entryPoint` — a prime is a **primitive divisor** of `F n` iff its rank
  of apparition equals `n`. This is exactly the predicate that
  `Speculative.AutoResearch.CarmichaelComposite.fib_carmichael_composite` certifies, now made
  intrinsic.
- `fib_entryPoint_exists` — every modulus `p ≥ 1` *has* a rank of apparition (Pisano /
  pigeonhole).

These results sit directly underneath the catalog's Carmichael work, whose only remaining
gap is the *infinite tail* of `fib_carmichael_composite` (composite `n > 10000`). The
directions below are concrete attacks on that gap and natural generalizations.

## Direction 1 — Total entry-point function and its multiplicativity

Package the rank of apparition as a genuine function `alpha : ℕ → ℕ`, `alpha p = Nat.find`
of the existence proof `fib_entryPoint_exists`, and prove the **lcm law**
`alpha (lcm a b) = lcm (alpha a) (alpha b)` for coprime `a, b`, together with
`p ∣ F n ↔ alpha p ∣ n` as a corollary of `fib_entryPoint_dvd_iff`.

The key insight is that `fib_entryPoint_dvd_iff` already shows the entry point is the unique
generator of the divisibility ideal `{n : p ∣ F n}`, so multiplicativity of `alpha` is forced
by the multiplicativity of intersection of these ideals — no new Fibonacci identity is needed,
only the abstract fact that the index set is exactly the multiples of `alpha p`.

Why now? With the law of apparition proved generally (not just for `n ≤ 10000`), `alpha` is
well-defined and its arithmetic becomes a finite bookkeeping exercise rather than an
open-ended search, making it a tractable next step that immediately strengthens every
downstream Carmichael argument.

## Direction 2 — Closing the infinite Carmichael tail via a growth/totient bound

Attack the remaining `sorry` in `fib_carmichael_composite` (composite `n > 10000`) by the
classical Carmichael route: bound the product of *non-primitive* prime power contributions to
`F n` and compare it to the size of `F n` itself. Concretely, formalize
`F n = ∏_{d ∣ n} Φ_d` (the Fibonacci analogue of cyclotomic factorization) and show the
"imprimitive part" `∏_{d ∣ n, d < n} F d` is too small to absorb all of `F n` once
`n ≥ 13`, leaving a primitive factor.

The key insight is that `fib_primitive_iff_entryPoint` reduces "primitive divisor exists" to
"some prime has entry point exactly `n`," which is a counting statement about the multiset of
entry points of the prime factors of `F n` — a statement amenable to the explicit growth
bound `F n ≥ φ^{n-2}` versus the at-most-`F d` imprimitive contributions.

Why now? The primitivity predicate has just been re-expressed intrinsically via the entry
point, converting the geometric/transcendence flavor of the original Carmichael proof into a
divisor-counting inequality that Lean's `Nat`/`Finset` automation handles well.

## Direction 3 — Lucas sequences and a uniform apparition law

Generalize from Fibonacci to arbitrary **Lucas sequences** `U_n(P, Q)` with
`gcd(P, Q) = 1`, proving `gcd(U_m, U_n) = U_{gcd(m,n)}` and then transporting
`fib_entryPoint_dvd_iff` verbatim to obtain a law of apparition for every such sequence
(Mersenne numbers `2^n - 1`, Pell numbers, etc. are special cases).

The key insight is that every proof in this file used *only* the gcd identity
`Nat.fib_gcd` plus strict monotonicity; abstracting the hypothesis to "`U` is a strong
divisibility sequence" makes the entire apparition theory parametric, so the Fibonacci file
becomes one instantiation of a single reusable theorem.

Why now? Mathlib already contains the divisibility machinery for these sequences in
fragments, and the present file isolates the *exact* lemma interface
(`gcd`-compatibility + monotonicity) that a generalization must satisfy, so the abstraction
boundary is now explicit.

## Direction 4 — Pisano period as the order of the apparition shift

Upgrade `fib_entryPoint_exists` (pure existence) to the quantitative **Pisano period**:
define `pisano p` as the period of `(F k, F (k+1)) mod p` and prove `alpha p ∣ pisano p`
together with `pisano p ∣ ...` divisor relations, by recognizing the shift map
`T(x,y) = (y, x+y)` as an element of `GL₂(ZMod p)` and computing its multiplicative order.

The key insight is that the finite-orbit pigeonhole already used in `fib_entryPoint_exists`
is exactly the statement that `T` has finite order; promoting `T` to a unit of the matrix
ring `Matrix (Fin 2) (Fin 2) (ZMod p)` turns "a period exists" into "the order of a specific
group element," which is computable and divides `|GL₂(ZMod p)|`.

Why now? The existence proof is in hand and already manipulates the pair-sequence; the only
new ingredient is naming the shift as a matrix, after which Lagrange's theorem (present in
Mathlib) delivers the divisibility bounds for free.

## Direction 5 — A sharp threshold for "random" divisibility theories (the originating conjecture)

Return to the cycle's motivating phase-transition theme: model a "random first-order theory"
as a random set `S ⊆ {primes}` of allowed prime divisors and ask, for the schema
`φ_n := (∃ p ∈ S, p ∣ F n)`, for the critical density of `S` at which `φ_n` becomes
provable for almost all `n`. Using `fib_primitive_iff_entryPoint`, `φ_n` holds iff `S` meets
the set of primes with entry point dividing `n`; the threshold is then governed by the
distribution of entry points.

The key insight is that primitive divisors give each `n` a *fresh* prime (entry point exactly
`n`), so the relevant random structure is a one-per-level coupon-collector process, predicting
a sharp threshold at density `~ 1/log n` rather than a constant — a falsifiable prediction
that can be checked by `#eval` over the first several thousand Fibonacci numbers.

Why now? The intrinsic characterization of primitivity finally makes "which primes can prove
`φ_n`" a decidable, enumerable set, so the conjectured threshold can be tested computationally
in Lean before any asymptotic proof is attempted.
