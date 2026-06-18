# Future Directions — Strong Divisibility Sequences as the Hidden Skeleton of Primitive-Divisor Theory

## Synthesis

This cycle isolated the *single structural axiom* that powers the catalog's entire Fibonacci
primitive-divisor theory and reused it to unify two historically separate worlds — the
**Fibonacci** numbers `F_n` and the **Mersenne / repunit** numbers `b^n − 1`. The new file
`Catalog/Bridges/StrongDivisibilitySequences.lean` defines a `StrongDivSeq` (a sequence with
`a 0 = 0` and `gcd (a m) (a n) = a (gcd m n)`) and proves the *whole* rank-of-apparition /
primitive-divisor calculus generically:

* divisibility monotonicity (`dvd_of_dvd`), the meet law (`dvd_gcd_iff`),
* rigidity of primitivity (`isPrimitive_unique`), divisibility pinning (`dvd_iff_index_dvd`),
* the join law and its finite-family generalization (`simultaneous_apparition[_finset]`),
* the entry-point characterization (`entryPoint_isPrimitive`, `dvd_iff_entryPoint_dvd`,
  `primitive_iff_entryPoint_eq`).

Fibonacci theory (the catalog's `FibonacciEntryPoints` and `FibonacciPrimitiveDivisors`) drops
out as the `fibSDS` instance, and the *same theorems* immediately produce a Zsygmondy-flavoured
join law for `b^n − 1` (`mersenne_simultaneous_apparition`) at no extra cost. The conceptual
payoff: the "rank of apparition" is not a fact about the golden ratio — it is a fact about one
gcd identity.

## Results Summary

* **12 new theorems, zero `sorry`** in `Catalog/Bridges/StrongDivisibilitySequences.lean`
  (10 generic results + 2 cross-domain corollaries), plus three instances `fibSDS`,
  `mersenneSDS`, `idSDS`.
* Removed a dangling broken import in `Catalog/Shared/CarmichaelProof.lean` so that file again
  elaborates, and corrected the package source root (`srcDir = "Catalog"`) in the root lakefile.
* The one genuinely open `sorry` in the catalog — `fib_carmichael_composite` for composite
  `n > 10000` — was attacked but **not** closed: it is the full analytic Carmichael/Zsygmondy
  statement and needs cyclotomic-value lower bounds absent from Mathlib. It is left honest and
  unaxiomatized, and is now the headline target below.

---

## Direction 1 — Close `fib_carmichael_composite` via a generic "cyclotomic lower bound"

State and prove, for `StrongDivSeq` of *Lucas type* (those arising from `(α^n − β^n)/(α − β)`
with `|α| > 1 ≥ |β|`, `αβ = ±1`), the inequality `Φ_n(a) > n` for all but finitely many `n`,
where `Φ_n = ∏_{d|n} a(d)^{μ(n/d)}` is the Möbius-defined primitive part. Combined with
`primitive_iff_entryPoint_eq`, this discharges the open tail `n > 10000` for Fibonacci.

The key insight is that the obstruction to a primitive divisor is *exactly one* intrinsic
prime, dividing `Φ_n` to the first power and bounded by `n`; so a single quantitative bound
`Φ_n > n` — not the full strength of Carmichael's proof — suffices, and that bound is a
property of the `StrongDivSeq`, not of Fibonacci specifically.

Why now? The generic `entryPoint`/`primitivePart` scaffolding built this cycle reduces
Carmichael's theorem to one clean falsifiable inequality `Φ_n > n`, decoupling the
combinatorial bookkeeping (already done, generically) from the single missing analytic fact.

## Direction 2 — A generic `primitivePart` and the existence criterion

Define `StrongDivSeq.primitivePart s n := ∏_{d|n} (s.a d) ^ (μ (n/d))` (as an integer via the
Möbius inversion of `log`), and prove the equivalence
`(∃ p, IsPrimitive s p n) ↔ 1 < primitivePart s n` for `n > 0`.

The key insight is that primitivity is detected by a *single multiplicative invariant*: every
prime of `s.a n` is either intrinsic (entry point a proper divisor of `n`) or primitive (entry
point `n`), and the primitive ones are precisely those surviving Möbius inversion.

Why now? The catalog already contains two ad-hoc "primitive residual" algorithms
(`primPart`, `primitiveResidual`, `fibCoprimePart`) with hand-rolled soundness proofs; lifting
them to one generic invariant over `StrongDivSeq` would replace three duplicated developments
with a single reusable theorem and make Direction 1's target precise.

## Direction 3 — The entry-point ↔ multiplicative-order bridge for `b^n − 1`

Prove `(mersenneSDS b).entryPoint p = orderOf (b : ZMod p)` for primes `p ∤ b`, turning the
abstract rank of apparition into the concrete multiplicative order. Then `dvd_iff_entryPoint_dvd`
becomes the classical `p ∣ b^n − 1 ↔ ord_p(b) ∣ n`, and `simultaneous_apparition` becomes a
statement about simultaneous orders.

The key insight is that the entry point of the Mersenne sequence is literally a group-theoretic
order, so the number-theoretic apparition laws proved generically this cycle are secretly
theorems about cyclic groups `(ZMod p)ˣ`.

Why now? `mersenneSDS` is already an instance, and Mathlib's `orderOf`/`ZMod` API is mature;
this bridge would connect the catalog's number theory directly to its algebra files and give a
second, independent route to Zsygmondy for `b^n − 1`.

## Direction 4 — Entry point as a graded rank function (lattice / Galois structure)

Conjecture that for a fixed `StrongDivSeq s`, the map `p ↦ {n : p ∣ s.a n}` is an order
isomorphism from "values up to entry point" onto the lattice of `≤`-down-sets generated by
multiples of a single index, and that `entryPoint` is the associated closure operator. Formalize
this as a Galois connection between value-divisibility and index-divisibility.

The key insight is that `dvd_iff_entryPoint_dvd` already says the apparition set of `p` is the
*principal* up-set `{n : entryPoint p ∣ n}`; promoting this to a Galois connection would make
"rank of apparition" a categorical/lattice-theoretic invariant rather than a numerical one.

Why now? All the pointwise lemmas (`dvd_iff_entryPoint_dvd`, `simultaneous_apparition_finset`)
are in place; only the packaging into Mathlib's `GaloisConnection`/`Order` API remains, and that
packaging is exactly the Grothendieck-style abstraction this engine targets.

## Direction 5 — Lucas sequences `U_n(P,Q)` as a unifying instance family

Add the general Lucas sequences `U_n(P, Q)` (which include Fibonacci `P=1,Q=−1`, Pell `P=2,Q=−1`,
and Mersenne-like `P=b+1,Q=b`) as `StrongDivSeq` instances by proving their strong-divisibility
identity `gcd(U_m, U_n) = U_{gcd(m,n)}` (for `gcd(P,Q)=1`). Every generic theorem of this cycle
then applies verbatim to all of them.

The key insight is that the strong-divisibility identity for Lucas sequences follows from the
same `α,β` eigenvalue arithmetic for *any* admissible `(P,Q)`, so a single proof instantiates an
entire two-parameter family — the ultimate "generalization over specialization".

Why now? The framework and its three instances already demonstrate the pattern; the only new
ingredient is the Lucas strong-divisibility lemma, after which Pell, balancing, and Jacobsthal
primitive-divisor theory all become corollaries with no further work.
