# Future Directions — The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Synthesis

This cycle closed a concrete gap between two halves of the catalog that had only been
linked *abstractly*: the tropical/ultrametric arithmetic-height machinery — now made
concrete in `Bridges/TropicalUltrametricBridge.lean` (the `NonArchNorm` structure and
the `padicHeightNorm` / `padicTropicalValuation` realisation of `p`-adic height as the
exponential of a tropical valuation) — and the strong-divisibility identity
`Nat.fib_gcd` that powers the catalog's Carmichael/Fibonacci work
(`Novelty/FibonacciEntryPointDuality.lean`).

The bridge is the **rank of apparition**. In
`Speculative/AutoResearch/FibonacciApparitionDuality.lean` we prove, for every modulus
`m ≥ 1`, that there is a least positive index `fibRank m` with `m ∣ fib (fibRank m)`
(`fib_apparition_exists`), and the headline *representation/duality theorem*

```
fib_dvd_iff_rank_dvd :  m ∣ fib n  ↔  fibRank m ∣ n .
```

Divisibility of Fibonacci **values** is translated, with no loss, into divisibility of
**indices** — the index-side dual of `fib (gcd m n) = gcd (fib m) (fib n)`. Two
consequences make the duality quantitative: the divisibility predicate is a **min-plus
(lattice) homomorphism** (`fib_dvd_gcd_iff`, sending the index `gcd` — a tropical `min`
— to logical conjunction), and the `p`-adic arithmetic height of `fib n` drops below `1`
*exactly* on the rank sublattice (`fibHeight_lt_one_iff` / `padicNorm_fib_lt_one_iff`).
In one sentence: the non-archimedean size of a Fibonacci number is governed precisely by
the combinatorial object `fibRank p`.

The bridge file also isolates the *tropical dictionary* itself,
`padicHeightNorm_eq_zpow : N q = p^(−v q)` for `q ≠ 0`, exhibiting the multiplicative
ultrametric norm as the exponential of the additive min-plus valuation
`padicTropicalValuation = padicValRat`.

The pleasant surprise is how little is needed. Existence of the rank reduces to the
single fact that the affine shift `T(a,b) = (b, a+b)` is a *bijection* of the finite set
`ZMod m × ZMod m`; a finite bijection has purely periodic orbits, so the orbit of
`(0,1)` returns to `(0,1)`. No Binet formula, no analysis — only injectivity, packaged
as `add_right_cancel`.

## Results summary

All statements below are proven `sorry`-free, depending only on `propext`,
`Classical.choice`, `Quot.sound`.

* `TropUltra.padicHeightNorm` — the `p`-adic ultrametric arithmetic-height norm on `ℚ`
  (a `NonArchNorm`), with all axioms discharged.
* `TropUltra.padicHeightNorm_eq_zpow` — the tropical dictionary `N q = p^(−v q)`.
* `TropUltra.padicHeightNorm_lt_one_iff_dvd` — height `< 1` reads off `p ∣ z`.
* `FibApparition.fib_apparition_exists` — every `m ≥ 1` divides some positive `fib k`
  (pure periodicity of the Fibonacci state pair mod `m`).
* `FibApparition.fib_dvd_iff_rank_dvd` — **the law of apparition** (value/index duality).
* `FibApparition.fib_dvd_gcd_iff` — divisibility is a `gcd → ∧` (min-plus) homomorphism.
* `FibApparition.padicNorm_fib_lt_one_iff` — Mathlib-native height capstone.
* `FibApparition.fibHeight_lt_one_iff` — catalog capstone: `TropUltra.padicHeightNorm`
  of `fib n` is `< 1` iff `fibRank p ∣ n`.

## Research directions

### 1. Primitivity is rank equality — and it re-frames the open Carmichael tail.

The catalog's Carmichael work still leaves the *infinite tail* (composite `n > 10000`)
of the Fibonacci primitive-divisor theorem open. The apparition theorem turns the very
definition of "primitive divisor" into a clean statement about the rank: a prime `p` is
a primitive prime divisor of `fib n` (it divides `fib n` but no earlier `fib k`) **iff**
`fibRank p = n` (already visible in `FibonacciEntryPointDuality.isFibPrimitiveDivisor_iff_entry`).
Conjecture: with `fib_dvd_iff_rank_dvd`, Carmichael's theorem becomes the single
arithmetic claim "for every composite `n > 12` there exists a prime with `fibRank p = n`."
The key insight is that primitivity is not an analytic property of magnitudes but the
*equality case* of the apparition duality, so the whole problem collapses onto the
surjectivity of `fibRank` onto `{n : n > 12}`. Why now? We have just isolated `fibRank`
and proven the iff that the catalog's bridge-lemma was implicitly using; small `n` are
checkable by `decide`/`native_decide`, so any wrong reformulation is caught immediately.

### 2. The rank is an arithmetic function with a CRT/lcm law.

Conjecture: for coprime moduli `a` and `b`, `fibRank (a * b) = Nat.lcm (fibRank a)
(fibRank b)`, and more generally `m ∣ fib n ↔ ∀ prime powers q ‖ m, fibRank q ∣ n`. The
key insight is that the value-side Chinese Remainder Theorem is *dual* to an index-side
`lcm`: conjunction over prime-power components on the value side becomes a single `lcm`
divisibility on the index side, exactly because `fib_dvd_iff_rank_dvd` linearises each
component. Why now? `fib_dvd_gcd_iff` already exhibits `fibRank` as a lattice
homomorphism for `gcd`/`∧`; the multiplicative (lcm) law is the dual lattice operation
and is fully falsifiable by enumerating `fibRank` on small composite `m`.

### 3. The Pisano/companion-matrix bound `fibRank p ∣ p − (5 | p)`.

Our `fibState` is literally the forward orbit of the Fibonacci **companion matrix**
`[[0,1],[1,1]]` acting on `(F_p)²`. Conjecture: for an odd prime `p ≠ 5`, `fibRank p`
divides `p − legendreSym 5 p`, hence `fibRank p ≤ p + 1`; equivalently the order of the
companion matrix in `GL₂(F_p)` controls the rank. The key insight is that the rank of
apparition equals the multiplicative order of the companion matrix's eigenvalue (the
golden ratio) in the field `F_p` (or `F_{p²}`), so the classical order-divides-group-size
bound applies. Why now? The bijection `T` we already use *is* that matrix; promoting
`fibState` from a raw function to a `Matrix`/`ZMod` power gives the order interpretation
directly, and the resulting bound is sharply falsifiable (it fails instantly for any
miscomputed Legendre symbol).

### 4. Exact tropical valuation of Fibonacci numbers (lifting-the-exponent).

`fibHeight_lt_one_iff` is a *threshold* result; its quantitative refinement should be an
exact valuation formula. Conjecture: for an odd prime `p` and `fibRank p ∣ n`,
`padicValNat p (fib n) = padicValNat p (fib (fibRank p)) + padicValNat p (n / fibRank p)`,
so the `p`-adic arithmetic height of `fib n` is an *exact tropical (min-plus) valuation*
that is affine in `padicValNat p n` along the rank filtration. The key insight is that
the height is not merely `< 1` on multiples of the rank but descends by a controlled,
additive amount each time another factor of `p` enters the index — a Fibonacci
lifting-the-exponent law. Combined with `padicHeightNorm_eq_zpow`, this would upgrade the
dictionary from "support" to "exact slope". Why now? Having pinned the *support* of the
height to the rank sublattice, the only remaining unknown is the *slope*, and the formula
is directly testable: compute `padicValNat p (fib n)` for a grid of `(p, n)` and check
affinity.

### 5. Abstract the whole theory to strong divisibility sequences.

The proof of `fib_dvd_iff_rank_dvd` used *only* `Nat.fib_gcd`, `Nat.fib_dvd`, and
positivity of `fib` on positive indices. Conjecture: the identical theorem holds for any
**strong divisibility sequence** `a : ℕ → ℕ` (one with `gcd (a m) (a n) = a (gcd m n)`
and `a n ≠ 0 ↔ n ≠ 0`), e.g. `a n = q^n − 1`, Lucas sequences, and elliptic divisibility
sequences. The key insight is that apparition is a *purely order-theoretic* phenomenon of
strong divisibility, with the Fibonacci specifics entering only through existence of the
rank (which itself follows from any eventual periodicity mod `m`). Why now? A
`class StrongDivSeq` carrying these two axioms would let the catalog reuse `fibRank`,
`*_dvd_iff_rank_dvd`, and the height capstone across all of its `q`-analogue and
Lucas-sequence files at once — a single abstraction collapsing several would-be duplicate
bridges. It is falsifiable by exhibiting any strong divisibility sequence where the rank
fails to control divisibility.
