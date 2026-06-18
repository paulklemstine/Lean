# Future Directions — The Rank of Apparition as a Lattice Morphism

## Synthesis

The catalog's rank-of-apparition thread (`RankOfApparition.lean`,
`UnifiedRankOfApparition.lean`) had distilled the "Law of Apparition" down to a single
*spine* — `m ∣ u n ↔ rank u m ∣ n` for any strong divisibility sequence `u` — and used it to
recover the Fibonacci and Mersenne value-divisibility biconditionals as instances of one
engine. But on the *modulus* side it had only ever proved the **monotone** order-morphism law
`b ∣ a → rank b ∣ rank a`. The structural question "how does `rank` interact with the *join*
of two moduli?" was left open.

This cycle closes that gap. The new file `Catalog/Applications/RankLatticeMorphism.lean`
proves, purely from the spine, that the rank of apparition is a **homomorphism of
join-semilattices** `(ℕ_{>0}, lcm) → (ℕ_{>0}, lcm)`:

* `rank_lcm` (generic): `rank u (lcm a b) = lcm (rank u a) (rank u b)`;
* `hasRank_lcm`: existence of ranks is *closed* under `lcm` (the join's rank is manufactured,
  never assumed);
* `rank_mul_coprime`: the multiplicative entry-point law for coprime moduli;
* `fibRank_lcm`: the classical "Fibonacci entry point of an lcm is the lcm of entry points";
* `mersenne_rank_lcm`: the *same* law for `aᵏ−1`, giving `rank(lcm(aᵐ−1, aⁿ−1)) = lcm m n`.

The conceptual payoff is that one lattice-theoretic identity unifies two number-theoretic
worlds (Fibonacci, `aⁿ−1`) that share no surface structure — they are simply two points in the
category of strong divisibility sequences, and the rank functor preserves joins.

## Results Summary

12 theorems, `sorry`-free, self-contained against Mathlib. The four headline results
(`rank_lcm`, `rank_mul_coprime`, `fibRank_lcm`, `mersenne_rank_lcm`) are new to the catalog;
the engine core (`rank_dvd_iff`, `rank_self`, `fib_hasRank`) is restated/copied from the
existing rank thread so the file stands alone.

## Research Directions

### 1. The gcd side is genuinely broken — quantify the defect.

The join law `rank(lcm a b) = lcm(rank a, rank b)` holds, but the dual meet law
`rank(gcd a b) =? gcd(rank a, rank b)` does **not**. The conjecture to test is the precise
one-sided statement: for every strong divisibility sequence with totality,
`gcd(rank a, rank b) ∣ rank(gcd a b)` always, and equality can fail. The key insight is that
`rank` preserving joins but not meets means it is a *lower-adjoint-like* map, not a lattice
isomorphism, and the obstruction is exactly the failure of `gcd` of moduli to be a divisibility
"pullback". Why now? We already have `rank_lcm` and `rank_dvd_of_dvd`; the one-sided divisibility
`gcd(rank a, rank b) ∣ rank(gcd a b)` follows from monotonicity alone, and a concrete Fibonacci
counterexample to equality (e.g. comparing `rank F 2` and `rank F 4` against `rank F (gcd 2 4)`)
is a finite `decide`-checkable disproof — making this immediately falsifiable.

### 2. Lift the join morphism to a full `LatticeHom` / `MonoidHom` in Mathlib's bundled API.

Right now `rank_lcm` is an unbundled equation. The conjecture is that `rank u` factors as an
honest `MonoidHom (Associates ℕ) (Associates ℕ)` (with `lcm` as the monoid operation on the
divisibility monoid), once restricted to moduli that have a rank. The key insight is that the
spine makes `n ↦ {k : rank u n ∣ k}` an injective map into principal ideals, so `rank u`
*is* a poset/monoid embedding of its domain, and Mathlib's `Associates` machinery is the right
home for it. Why now? The standalone identities are proven; bundling them is a pure
re-packaging task that immediately exposes the result to Mathlib's order/algebra automation
(`OrderHom`, `sSup`-preservation), turning four ad-hoc theorems into one reusable structure.

### 3. The prime-power decomposition: `rank u m = lcm_{p^e ∥ m} rank u (p^e)`.

Iterating `rank_mul_coprime` over the prime factorisation gives a closed form:
`rank u m` is the `lcm` over the prime-power components of `m` of their individual ranks. The
key insight is that the join morphism reduces the entire rank function to its values on prime
powers — exactly the reduction that classical entry-point tables exploit — so all of apparition
is determined by the "local" data `rank u (pᵉ)`. Why now? `rank_mul_coprime` is in hand and
`Nat.factorization` / `Finsupp.prod` provide the induction skeleton; the statement is a clean
`Finset.lcm` identity provable by strong induction on the number of prime factors, and it is
falsifiable by a single composite Fibonacci example computed two ways.

### 4. Local rank-rigidity for `aⁿ−1` and the lifting-the-exponent bridge.

For Mersenne, `rank(pᵉ)` within `k ↦ aᵏ−1` is governed by the multiplicative order of `a` mod
`p` together with a `p`-adic valuation jump (lifting-the-exponent). The conjecture: there is a
sequence-agnostic statement `rank u (pᵉ⁺¹) = p · rank u (pᵉ)` for all `e` past a sequence-
dependent threshold, holding for *both* Fibonacci and `aⁿ−1`. The key insight is that the
"multiply-the-rank-by-`p`" phenomenon is not number-specific but a property of how `p`-adic
valuation grows along any strong divisibility sequence, so LTE and the Fibonacci wall-sun-sun
question are two faces of one valuation law. Why now? The catalog already hosts a tropical /
`p`-adic valuation file for Fibonacci primitive divisors; combining its valuation estimates with
the new `rank_self`/`rank_lcm` engine is the missing link, and the base case is decidable.

### 5. Primitive divisors as the "new" primes in the rank lattice.

Define `q` to be a primitive divisor of `u n` when `rank u q = n`. The conjecture: the
primitive divisors across all `n` form a partition-like generating set for the rank lattice,
i.e. every modulus's rank is the join of the indices of its primitive prime-power divisors, and
`fibRank_lcm` makes "having all of `F a` and `F b`'s primitive divisors" equivalent to "dividing
`F (lcm a b)`". The key insight is that primitivity (`rank u q = n`, exactly the catalog's
`IsPrimitive`) is precisely the condition that a prime sits at a *single* lattice index, so
primitive divisors are the atoms of the apparition lattice. Why now? `RankOfApparition.lean`
already proves `fib_prime_index_has_primitive`, and the join morphism `rank_lcm` is exactly the
tool needed to show these atoms generate — connecting Carmichael's primitive-divisor theorem to
the lattice structure for the first time, with Zsygmondy-style counterexamples (`F 6 = 8`,
`F 12 = 144`) available as finite tests.
