# Future Directions — The Fibonacci Apparition Sheaf as a Lattice Morphism

## Synthesis

This cycle worked inside the **local-to-global / sheaf** theme on the *rank of apparition*
`fibRank m` (the least positive `k` with `m ∣ F_k`), the section of the apparition sheaf over
the divisibility site of moduli developed in `Catalog/Shared/FibonacciApparitionSheaf.lean`.

That file established the *law of apparition* (`fib_dvd_iff_fibRank_dvd`: `m ∣ F_n ↔ rank m ∣ n`),
the *Carmichael stalk bridge* (`isPrimitive_iff_fibRank_eq`: primitivity ⇔ `rank m = n`), and a
**coprime** product/gluing law (`fibRank_mul_coprime`, `fibRank_finset_prod_coprime`).

The new file `Catalog/Novelty/FibApparitionLatticeMorphism.lean` removes the coprimality
hypotheses and identifies the true algebraic nature of the apparition section: `fibRank` is a
**homomorphism of join-semilattices** from `(ℕ_{>0}, lcm, ∣)` of *moduli* to `(ℕ_{>0}, lcm, ∣)`
of *indices*. Concretely:

* `fibRank_one_eq_one` — preserves the unit.
* `fibRank_dvd_of_dvd` — monotone for divisibility (the restriction map of the sheaf).
* `fibRank_lcm` — the **exact join law** `rank(lcm a b) = lcm(rank a, rank b)` for *all* positive
  `a,b`, strictly generalising the catalog's coprime-only `fibRank_mul_coprime`.
* `fibRank_gcd_dvd` — the **lax meet law** `rank(gcd a b) ∣ gcd(rank a, rank b)`: only a one-sided
  divisibility, the structural asymmetry of the morphism.
* `fibRank_finset_lcm` — the finite join law with **no coprimality**, generalising
  `fibRank_finset_prod_coprime`.

## Results Summary

Five new theorems, all `sorry`-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.
The headline `fibRank_lcm` collapses two prior catalog results (the binary and finite *coprime*
product laws) into a single unconditional join-homomorphism, and `fibRank_gcd_dvd` isolates the
exact place where the morphism fails to be a full lattice isomorphism — the obstruction class.

## Bold, Falsifiable Directions

### 1. The meet defect is the genuine cohomological obstruction
Define the **apparition defect** `δ(a,b) := gcd(rank a, rank b) / rank(gcd a b)`, a positive
integer by `fibRank_gcd_dvd`. *Conjecture:* `δ(a,b) = 1` whenever `gcd(rank a, rank b)` is itself
the rank of some modulus dividing `gcd a b`, and the prime factors of every `δ(a,b)` divide
`5·gcd(a,b)`. **The key insight is** that the join law is exact precisely because `m ∣ F_k` is a
*disjunction-closed* (lcm) condition, while the meet (gcd) of indices can be realised by a
strictly larger modulus — so `δ` measures exactly the "primes that enter late," a first-cohomology
class of the apparition sheaf. **Why now?** With `fibRank_lcm` and `fibRank_gcd_dvd` both formal,
`δ` is now a well-defined computable object; a `native_decide` sweep over `a,b ≤ 10^4` can confirm
or refute the prime-support bound before any structural proof is attempted.

### 2. The lcm-morphism characterises strong divisibility sequences
*Conjecture:* For an integer linear recurrence `s` with `s_0 = 0`, the associated rank function
satisfies `rank_s(lcm a b) = lcm(rank_s a, rank_s b)` for all coprime-free positive `a,b`
**iff** `s` is a strong divisibility sequence (`gcd(s_m, s_n) = s_{gcd(m,n)}`). **The key insight
is** that the only property of Fibonacci used in `fibRank_lcm` is `Nat.fib_gcd`; the entire proof
factors through the strong-divisibility identity, so the join-morphism should be *equivalent* to
it, not merely a consequence. **Why now?** The proof of `fibRank_lcm` is short and uses exactly
one Fibonacci-specific lemma, making the abstraction to a typeclass `StrongDivSeq` a direct,
testable refactor that would immediately cover Lucas, Mersenne, and `aⁿ − bⁿ` sequences.

### 3. Closing the Carmichael asymptotic tail via the cyclotomic primitive part
The lone deep `sorry` in the catalog (`Catalog/Shared/CarmichaelProof.lean`,
`fib_carmichael_composite` for `n > 10000`) is the asymptotic half of Carmichael's primitive
divisor theorem. *Conjecture (provable):* the integer `Φ_n := ∏_{d ∣ n} F_d^{μ(n/d)}` satisfies
`Φ_n > n` for `n > 12`, and every prime factor of `Φ_n` except at most one (which divides `n` to
the first power) has `rank p = n`; hence `Φ_n` exhibits a primitive prime divisor. **The key
insight is** that the Möbius-defined primitive part has size `≈ φ^{φ(n)}` because
`∑_{d∣n} d·μ(n/d) = φ(n)` (Euler totient), an exponential lower bound that dwarfs the single
exceptional prime `≤ n`. **Why now?** The stalk-level dictionary (`isPrimitive_iff_fibRank_eq`)
and the join laws proved this cycle reduce the global statement to (i) the totient identity
[in Mathlib: `Nat.totient`, `Nat.sum_totient`] and (ii) a one-prime exceptional bound — both
self-contained lemmas, turning a monolithic open `sorry` into two provable pieces.

### 4. Rank versus Pisano period: two sections of one sheaf
The Pisano period `π(m)` (period of `F mod m`) and `rank(m)` are two sections over the same
divisibility site. *Conjecture:* `rank` is the *finest* join-exact section dividing `π`, i.e.
`rank m ∣ π m`, `π(lcm a b) = lcm(π a, π b)`, and `π m / rank m ∈ {1,2,4}` for all `m`. **The key
insight is** that both functions are governed by the order of the companion matrix
`[[0,1],[1,1]]` over `ZMod m`, with `rank` the order of its "off-diagonal vanishing" and `π` the
full multiplicative order — so their quotient is the order of a determinant `(−1)`-type unit,
forcing a 2-power. **Why now?** `fibStep` (the reversible shift permutation) is already formalised
in the sheaf file; its order *is* `π`, so the period section can be built with the existing
machinery and compared to `rank` directly.

### 5. Functoriality: the apparition map as a Galois connection
*Conjecture:* The pair (`fibRank`, `m ↦ gcd of moduli with rank dividing m`) forms a monotone
Galois connection between the modulus and index divisibility lattices, with `fibRank` the lower
adjoint; consequently `fibRank` preserves all existing joins (already shown for binary/finite lcm)
and the upper adjoint preserves meets. **The key insight is** that `fibRank_dvd_of_dvd` plus
`fib_dvd_iff_fibRank_dvd` are exactly the unit/counit inequalities of an adjunction in the
divisibility-poset-as-category. **Why now?** Monotonicity (`fibRank_dvd_of_dvd`) and the
divisibility dictionary are now both formal; assembling them into Mathlib's `GaloisConnection`
API is a packaging step that would make every preservation theorem (including this cycle's
`fibRank_lcm`) a one-line corollary, unifying the whole apparition-sheaf thread.
