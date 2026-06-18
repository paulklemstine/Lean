# Future Directions — The Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle took the catalog's *arithmetic-height / apparition duality*
(`Speculative.AutoResearch.FibonacciApparitionDuality`, `Applications.FibonacciEntryPoints`,
`Applications.RankOfApparition`) and asked a structural question the catalog had left
implicit: the pointwise equivalence

> `fib_dvd_iff_rank_dvd : m ∣ fib n ↔ fibRank m ∣ n`

says the *index set* `{ n | m ∣ fib n }` is the **principal ideal** `(fibRank m)` of the
divisibility monoid `(ℕ, ∣)`. Once the duality is read as "values ↦ principal ideals of
indices", every algebraic identity true of the *predicate* must transport to an identity of
its *generator* `fibRank`. The new file
`Speculative/AutoResearch/FibRankLatticeMorphism.lean` makes this precise and proves it
`sorry`-free:

* **`fibRank_unique`** — the rank is *the* canonical generator of its index ideal
  (representation theorem);
* **`fibRank_monotone`** — `m ∣ m' → fibRank m ∣ fibRank m'` (functoriality of the duality
  as a poset morphism);
* **`fibRank_lcm`** — `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`: the apparition map
  is an **lcm-semilattice homomorphism**, the tropical/arithmetic-height "join" duality made
  structural;
* **`fibRank_pow_chain`** — along `m, m², m³, …` the ranks form a `∣`-increasing chain, a
  literal *path* in the index poset.

The decisive negative observation (recorded in the Lab Notebook) is that the **meet** is
*not* preserved: `gcd a b ∣ fib n` is not equivalent to `a ∣ fib n ∧ b ∣ fib n`, so
`fibRank` is a join-morphism but only a sub-morphism for `gcd`. That asymmetry is exactly
what a *localization* (left adjoint) should exhibit, and it sets up the directions below.

## Results Summary

Four theorems, all `sorry`-free and depending only on `propext`, `Classical.choice`,
`Quot.sound`, building on `Nat.fib_gcd` / `Nat.fib_dvd` (the catalog's priority
`Fib_gcd_identity`). The apparition base is reproduced self-containedly because the
catalog's original sits behind a currently-unbuildable bridge import
(`Bridges.TropicalUltrametricBridge`); the new file imports only `Mathlib` and therefore
stands on its own.

## Research Directions

### 1. Close Carmichael's tail through the join-morphism, not by computation
The one genuine `sorry` left in the catalog (`Shared/CarmichaelProof.lean`, the composite
case `n > 10000`) is exactly a statement about the *generator* of an index ideal: a
primitive prime divisor of `fib n` is a prime `p` with `fibRank p = n`. **The key insight
is** that `fibRank_lcm` rewrites the primitive part of `fib n` as the part of `fib n`
coprime to `fib d` over the *join* of proper-divisor ranks, so existence of a primitive
divisor becomes the strictly-positive gap between Binet's lower bound on `log fib n` and the
upper bound on `Σ_{d | n, d < n} log fib d` — a single inequality, no per-`n` `native_decide`.
*Why now?* The lattice-morphism layer just proved here is the missing algebraic reduction
that turns Carmichael's analytic content into one growth inequality, which is in range of
Mathlib's `Nat.fib` asymptotics; the computational scaffold up to `10000` already pins the
finitely many exceptional indices.

### 2. The meet defect is bounded and divisible
Computation suggests `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` always, with the
quotient supported only on primes dividing `gcd a b`. **The key insight is** that the meet
failure is a *coboundary*: the only obstruction to `fibRank` being a full lattice morphism is
the carry coming from shared prime power structure, so the defect `gcd(fibRank a, fibRank b) /
fibRank(gcd a b)` should be a product of primitive-divisor primes. *Why now?* With
`fibRank_lcm` proven, the lcm/gcd duality `lcm·gcd = a·b` lets one test the conjectured meet
divisibility directly against the join identity, and either prove it or produce an explicit
counterexample by `decide` on small `a, b`.

### 3. Apparition as a localization (left adjoint) of `(ℕ, ∣)`
`fibRank` preserves joins but not meets — the signature of a left adjoint. **The key insight
is** that the class of indices `S = { n | n ∣ fib n is "invisible", i.e. contributes no new
rank }` should be a *saturated multiplicative system*, and `fibRank` should factor as the
universal localization `(ℕ, ∣) → (ℕ, ∣)[S⁻¹]` inverting exactly the rank-trivial morphisms.
*Why now?* `fibRank_monotone` gives functoriality and `fibRank_pow_chain` gives the path/tower
structure; together they are the data of a monotone-map-into-a-poset, which is precisely a
0-truncated localization that Mathlib's order/`GaloisConnection` API can now express and test.

### 4. The morphism survives to all nondegenerate Lucas sequences
Conjecture: for every nondegenerate Lucas sequence `U_n(P, Q)` the rank of apparition is again
an lcm-semilattice homomorphism, `rank(lcm a b) = lcm(rank a, rank b)`. **The key insight is**
that the only property of `fib` used in this cycle is the strong-divisibility identity
`fib(gcd m n) = gcd(fib m, fib n)`, which holds verbatim for all nondegenerate Lucas
sequences; the entire proof skeleton is therefore parametric in that single hypothesis.
*Why now?* The proof here is already factored through `Nat.fib_gcd` and `Nat.fib_dvd` alone, so
abstracting it over a `StrongDivisibilitySequence` typeclass (cf. the catalog's
`Bridges/StrongDivisibilitySequences.lean`) is a mechanical generalization that immediately
multiplies the theorem's reach.

### 5. p-adic rank tower and lifting-the-exponent
Conjecture: there is an exponent `e(p) ≥ 1` with `fibRank (p^(k+1)) = p · fibRank (p^k)` for all
`k ≥ e(p)`, so the tower of §4 is eventually geometric with ratio `p`. **The key insight is**
that lifting-the-exponent controls `v_p(fib n)` linearly in `v_p(n)` once `n` is a multiple of
`fibRank p`, which converts the `∣`-chain `fibRank_pow_chain` into an *exact* recursion rather
than a mere divisibility. *Why now?* The catalog already contains an LTE-for-Fibonacci file
(`Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`);
feeding its valuation bound into `fibRank_pow_chain` is the natural next composition and is
falsifiable by computing `fibRank (p^k)` for the first few primes and exponents.
