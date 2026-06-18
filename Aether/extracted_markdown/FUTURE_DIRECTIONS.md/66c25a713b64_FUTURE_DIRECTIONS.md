# Future Directions — The Lattice Structure of the Fibonacci Rank of Apparition

This cycle established, `sorry`-free, the **lattice behaviour** of the Fibonacci entry
point (rank of apparition) `fibEntry m = least k > 0 with m ∣ F k`, building directly on
the catalog's entry-point theory (`FibonacciApparition.fibEntry`, the law of apparition
`fib_dvd_iff_fibEntry_dvd`, and the coprime multiplicativity
`FibonacciEntryPointInvariant.fibEntry_mul_coprime`). The new file
`Catalog/Speculative/AutoResearch/FibonacciApparitionLattice.lean` proves:

* `fibEntry_lcm` — the **unrestricted** join law `fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)`
  (dropping the coprimality hypothesis of the existing `fibEntry_mul_coprime`);
* `fibEntry_monotone` — `a ∣ b → fibEntry a ∣ fibEntry b`;
* `fibEntry_gcd_dvd` — the meet bound `fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)`;
* `fibEntry_gcd_not_exact` — the concrete witness `a = 4, b = 6` proving the meet bound is
  *strict*, so `fibEntry` is a join-morphism but **not** a meet-morphism of divisibility lattices.

The following directions are testable and falsifiable; each could be the seed of the next cycle.

## 1. Abstract the lattice laws to every strong divisibility sequence

The join law and monotonicity proven here use *only* the law of apparition, which itself
follows from the strong-divisibility identity `gcd(u m, u n) = u (gcd m n)` already isolated
abstractly in `StrongDivSeq` (`Catalog/Novelty/FibonacciEntryPointInvariant.lean`). Conjecture:
for any `u` with that identity, totality (`∀ m>0, ∃ k>0, m ∣ u k`) and `u 0 = 0`, one has
`StrongDivSeq.entry u (lcm a b) = lcm (entry u a) (entry u b)` and `a ∣ b → entry u a ∣ entry u b`.
**The key insight is** that nothing in the lattice argument touches the value of `F k`; only
the apparition equivalence `m ∣ u k ↔ entry u m ∣ k` is used, and that equivalence is purely
a consequence of `dvd_of_dvd` plus `entry_dvd`, both already abstract. **Why now?** The
abstract scaffolding (`StrongDivSeq.entry`, `entry_dvd`, `dvd_of_dvd`) is already in the
catalog and the Fibonacci proofs in this file are a line-for-line template, so the transfer to
the Mersenne/repunit model `u n = aⁿ − 1` (giving the lcm law for multiplicative orders) costs
almost nothing.

## 2. Prime-power tower: Wall's `fibEntry (p^(j+1)) ∈ {fibEntry (p^j), p · fibEntry (p^j)}`

Combined with `fibEntry_lcm`, a full understanding of `fibEntry` reduces (by the multiplicative
factorization of `lcm` over prime powers) to computing `fibEntry (p^j)`. Conjecture: for prime
`p` and `j ≥ 1`, `fibEntry (p^(j+1))` equals either `fibEntry (p^j)` or `p · fibEntry (p^j)`.
**The key insight is** that the `p`-adic valuation `v_p(F k)` grows by exactly one each time `k`
crosses a multiple of `fibEntry p` (lifting-the-exponent), which the catalog already formalizes in
`Catalog/Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`.
**Why now?** That LTE file supplies precisely the valuation step needed, so the tower statement
becomes a bookkeeping argument on top of `fibEntry_lcm` rather than new analytic input.

## 3. Exact meet law on a co-Wall locus

`fibEntry_gcd_not_exact` shows `fibEntry (gcd a b) = gcd (fibEntry a) (fibEntry b)` fails in
general, but it should hold under a structural hypothesis. Conjecture: equality holds whenever
`a` and `b` are coprime, and more generally whenever no prime divides both `fibEntry a` and
`fibEntry b` to different powers. **The key insight is** that the failure at `(4,6)` comes
entirely from the prime `2` appearing with mismatched exponents in `fibEntry 4 = 6` and
`fibEntry 6 = 12`; ruling that out restores the dual of the join law. **Why now?** With both the
join law (`fibEntry_lcm`) and the prime-power tower (Direction 2) in hand, the meet law becomes a
prime-by-prime comparison of exponents — a finite, decidable check per prime.

## 4. Density and growth of `fibEntry m`

Conjecture: `fibEntry m ≤ 2m` for all `m`, with the bound approached along `m = 5^j`
(where `fibEntry (5^j) = 5^j`) and the average order `(1/x) Σ_{m≤x} fibEntry m` growing like
`c · x` for an explicit constant. **The key insight is** that the law of apparition forces
`m ∣ F (fibEntry m)` and the Pisano period (the order of the Fibonacci pair map mod `m`,
already constructed via `fibPair` in `FibonacciApparition`) is a multiple of `fibEntry m`,
so period bounds transfer directly to entry-point bounds. **Why now?** The periodicity machinery
`fibPair`/`fibPair_descent` is already proven in the catalog; turning the existing pigeonhole
into a quantitative period bound is the only missing ingredient.

## 5. The entry-point spectrum as a complete invariant of divisibility sequences

Conjecture: two strong divisibility sequences `u, v` with the same entry-point function
(`entry u = entry v` on all moduli) have identical divisibility lattices, i.e. `m ∣ u k ↔ m ∣ v k`
for all `m, k`. **The key insight is** that the law of apparition makes `entry` a *complete*
encoding of the divisibility relation — `m ∣ u k ↔ entry u m ∣ k` — so equality of `entry`
functions forces equality of the relations pointwise. **Why now?** The forward implication is an
immediate corollary of the apparition equivalence already isolated in this cycle, and it reframes
the catalog's `primitive_divisor_inj` ("fractal injectivity") as one facet of a sharper
representation theorem worth stating in full generality.
