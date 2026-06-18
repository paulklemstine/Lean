# FUTURE_DIRECTIONS.md — Fibonacci Apparition as a Local-to-Global Sheaf

## Synthesis

This cycle formalized the Fibonacci **rank of apparition** as a *local-to-global sheaf* over
the divisibility site of moduli, and proved four theorems with **zero `sorry`** in
`Catalog/Shared/FibonacciApparitionSheaf.lean` (axioms: `propext`, `Classical.choice`,
`Quot.sound` only). The file is self-contained against Mathlib, following the established
catalog convention (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Novelty/FibApparitionExistence.lean`), restating the short existence/biconditional
*spine* and building the new sheaf layer on top of it.

The guiding theme is **duality and representation**: the rank `rank m = fibRank m` is the
exact dictionary between the divisibility lattice of *moduli* and the divisibility lattice of
*indices*. Its central structural features are:

1. **`fib_dvd_iff_fibRank_dvd`** — the *law of apparition* `m ∣ F n ↔ rank m ∣ n` (for
   `m > 0`). Existence of the rank is obtained not analytically but *structurally*: the
   Fibonacci shift `(a,b) ↦ (b, a+b)` is an honest **permutation** of the finite type
   `(ZMod m)²` (inverse `(a,b) ↦ (b−a, a)`, encoding the reversibility
   `F(k−1) = F(k+1) − F(k)`), so its orbit through `(0,1)` must return — forcing some positive
   `F k ≡ 0 (mod m)`.
2. **`isPrimitive_iff_fibRank_eq`** — the *Carmichael bridge*: `m` is a **primitive divisor**
   of `F n` iff `rank m = n`. This recasts the global primitive-divisor condition (an
   avoidance statement over *all* earlier indices, cf.
   `Shared.CarmichaelProof.bridge_lemma`) as a single local, stalk-level equation:
   primitivity *is* rank-maximality.
3. **`fibRank_mul_coprime`** — CRT *gluing of stalks*: `rank(ab) = lcm(rank a, rank b)` for
   coprime `a, b`.
4. **`fibRank_eq_factorization_lcm`** — the *full local-to-global reconstruction*:
   `rank n = lcm_{p ∈ supp(n)} rank(p^{v_p(n)})`. The global rank is the section glued from the
   prime-power **stalk** ranks; this strictly generalizes the binary gluing law (3) to the
   entire prime decomposition (via the intermediate `fibRank_finset_prod_coprime`, the
   arbitrary coprime-family gluing law).

The catalog already records parallel rank developments (`RankOfApparition`,
`FibonacciApparitionLattice`, `FibonacciEntryPoints`, ...). The new layer here is the explicit
**sheaf framing** — primitivity-as-rank-maximality (the bridge to Carmichael) and the
prime-power reconstruction of the global rank from local stalks — which those threads did not
isolate.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibRank_dvd` | `m ∣ F n ↔ rank m ∣ n` (`m > 0`) | proved |
| `isPrimitive_iff_fibRank_eq` | `IsPrimitive m n ↔ rank m = n` (`m,n > 0`) | proved |
| `fibRank_mul_coprime` | `rank(ab) = lcm(rank a, rank b)`, `Coprime a b` | proved |
| `fibRank_finset_prod_coprime` | `rank(∏ f) = Finset.lcm (rank ∘ f)`, pairwise coprime | proved |
| `fibRank_eq_factorization_lcm` | `rank n = lcm_p rank(p^{v_p(n)})` (`n > 0`) | proved |

## Research Directions (falsifiable)

### Direction 1 — Close the infinite tail of Fibonacci Carmichael via the stalk bridge.
`Shared.CarmichaelProof` proves a primitive divisor exists for composite `13 ≤ n ≤ 10000` by
computation and leaves the tail `n > 10000` open. **Conjecture:** for every composite
`n ≥ 13` there is a prime `p` with `rank p = n`, producible *uniformly* from a
Lifting-the-Exponent bound on the primitive part `primPart n` of `F n`. **The key insight is**
that `isPrimitive_iff_fibRank_eq` converts "primitive divisor exists" into "some prime has
rank exactly `n`", and a prime fails to have rank `n` only if it divides an earlier `F d`
(`d ∣ n`, `d < n`); LTE bounds the multiplicity those primes can carry, so once `F n` is large
enough the primitive part exceeds `1`. **Why now?** The stalk bridge proved this cycle is
exactly the reformulation needed to replace the computational tail with an analytic `v_p`
estimate, and the catalog already has an LTE-for-Fibonacci file
(`Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`) to draw on.

### Direction 2 — The meet (gcd) obstruction is a measurable defect.
The join law `rank(lcm a b) = lcm(rank a, rank b)` is exact, but the meet law fails:
`rank(gcd a b) ∣ gcd(rank a, rank b)` is strict in general (catalog boundary case `a=4, b=6`,
`FibonacciApparitionLattice.fibEntry_gcd_not_exact`). **Conjecture:** the defect
`δ(a,b) := gcd(rank a, rank b) / rank(gcd a b)` is *multiplicative in the prime stalks* and
equals `1` exactly when no prime simultaneously sub-divides the two ranks beyond their gcd —
i.e. `δ` is the order of an obstruction to `rank` being a lattice homomorphism. **The key
insight is** that `rank` is a join-morphism but not a meet-morphism, and the *quotient* `δ`
(not the additive gap) is the natural local invariant, computable stalk-by-stalk from
`fibRank_eq_factorization_lcm`. **Why now?** With the prime-power reconstruction in hand,
`δ(a,b)` reduces to a finite product over `supp(a) ∩ supp(b)`, making the multiplicativity
claim a concrete, decidable target.

### Direction 3 — Rank, Pisano period, and the global "period sheaf".
Let `π(m)` be the Pisano period (period of `F mod m`). Classically `rank m ∣ π m` and
`π m / rank m ∈ {1,2,4}`. **Conjecture:** `m ↦ π m` is the *global section* of the same sheaf,
with `π(lcm a b) = lcm(π a, π b)` and `π(p^{k+1}) = p · π(p^k)` for `p` not a Wall–Sun–Sun
prime; the ratio `π m / rank m` is locally constant on the prime stalks. **The key insight is**
that the shift permutation `fibStep m` already used to prove existence has order *exactly*
`π m`, so `π m = orderOf (fibStep m)` — the same finite-group datum that produced `rank`, read
globally (over the whole orbit structure) instead of at the single point `(0,1)`. **Why now?**
`fibStep` is defined and its permutation/order theory is in scope this cycle, so
`π m = orderOf (fibStep m)` and the gluing laws for `π` become corollaries of permutation-group
order arithmetic.

### Direction 4 — A presheaf of apparition over an arbitrary Lucas sequence.
Replace `F` by a non-degenerate Lucas sequence `U_n(P,Q)` (a strong divisibility sequence when
`gcd(P,Q)=1`). **Conjecture:** every theorem of this cycle lifts verbatim — existence via the
shift `(a,b) ↦ (b, P·b − Q·a)` (a permutation of `(ZMod m)²` when `gcd(Q,m)=1`), the law of
apparition, the primitivity bridge, and the prime-power reconstruction — giving a `rank_{P,Q}`
presheaf on moduli coprime to `Q`. **The key insight is** that the *only* property of `F`
actually used above is that the recurrence matrix `[[0,1],[1,1]]` is invertible mod `m`; for
general `U`, the companion matrix `[[0,1],[−Q,P]]` is invertible mod `m` exactly when
`gcd(Q,m)=1`, which pins down the natural site of definition. **Why now?** The proofs are
already factored through `fibStep`'s invertibility and `Nat.fib_gcd`; abstracting the `2×2`
companion matrix is a mechanical generalization that multiplies the catalog's reach across all
Lucas sequences.

### Direction 5 — Inverse problem: the fibers of `rank` and the image lattice.
`rank` maps the divisibility lattice of moduli to that of indices. **Conjecture:** for each
index `n` the fiber `{m | rank m = n}` has a maximum element `M(n) =` the primitive part
`primPart n` of `F n` (every modulus of rank `n` divides `M(n)`), so the fiber is precisely the
divisor set of `M(n)` minus moduli of strictly smaller rank; moreover `n ↦ M(n)` is
multiplicative-up-to-gcd. **The key insight is** that `isPrimitive_iff_fibRank_eq` identifies
the fiber of `rank` at `n` with the divisors of `F n` that avoid all earlier `F d` — exactly
the primitive part — so the inverse image of the sheaf is governed by `primPart`, the object
`Shared.CarmichaelProof` already computes. **Why now?** Both endpoints exist in the project this
cycle (`fibRank` here, `primPart` in `CarmichaelProof`), so the fiber description is a
falsifiable bridge between two already-formalized constructions.
