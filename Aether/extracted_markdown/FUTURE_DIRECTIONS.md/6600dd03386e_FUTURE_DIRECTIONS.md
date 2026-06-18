# Future Directions — Universal Transport for the Fibonacci Rank of Apparition

## Synthesis

This cycle continued the *representation/duality* program built around the Fibonacci
rank of apparition `z(p) = fibEntry p`. The foundation laid in
`Catalog/Novelty/FibonacciEntryPointDuality.lean` is the master duality

> `p ∣ F n  ↔  z(p) ∣ n`,

which *represents* every Fibonacci-divisibility question by the single arithmetic
function `z`. `Catalog/Novelty/FibCarmichaelStructure.lean` then extracted the
**algebraic** content of this duality: `z` is a morphism of divisibility *lattices*
(it sends `gcd` to meet and coprime products to `lcm`, and it is total on `p ≥ 1`).

The new file `Catalog/Novelty/FibEntryTransport.lean` extracts the complementary
**order-theoretic / homotopical** content, turning the duality into a genuine
*universal transport*. Concretely it proves, all `sorry`-free and using only the
standard axioms:

* `fibEntry_dvd_of_dvd` — **functoriality**: `d ∣ m → z(d) ∣ z(m)`. The entry point is
  a monotone endofunctor of the divisibility preorder `(ℕ, ∣)`.
* `fib_dvd_period` — **periodicity**: `p ∣ F(n + z(p)) ↔ p ∣ F n`. The divisibility
  indicator of `p` factors through the cyclic quotient `ℕ / z(p)`.
* `fib_dvd_mod_fibEntry` — **reduction mod the period**: `p ∣ F n ↔ p ∣ F(n % z(p))`.
* `fibEntry_dvd_iff_fib_dvd_imp` — **faithfulness**: `z(p) ∣ z(q) ↔ ∀ n, q ∣ F n → p ∣ F n`.
  Divisibility of entry points is *exactly* implication between divisibility predicates,
  so `z` is a faithful order-embedding — the precise sense in which the representation
  loses no information.

The unifying picture: the duality says `{n : p ∣ F n}` is the principal ideal `(z p)`,
so the family of "Fibonacci-divisibility ideals" embeds, order-preservingly and
faithfully, into the principal ideals of `(ℕ, ∣)`. The catalog now records this embedding
on three independent fronts — lattice (meet/join), order (monotone + faithful), and
dynamics (periodicity as a first-return time on the finite phase space
`ZMod p × ZMod p`, via `FibCarmichaelStructure.exists_pos_fib_dvd`).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntry_dvd_of_dvd` | `d ∣ m → z(d) ∣ z(m)` | proved, axioms standard |
| `fib_dvd_period` | `p ∣ F(n + z p) ↔ p ∣ F n` | proved, axioms standard |
| `fib_dvd_mod_fibEntry` | `p ∣ F n ↔ p ∣ F(n % z p)` | proved, axioms standard |
| `fibEntry_dvd_iff_fib_dvd_imp` | `z p ∣ z q ↔ ∀ n, q ∣ F n → p ∣ F n` | proved, axioms standard |

All four are corollaries of the single master duality, instantiated at the index `z(q)`
(where `q ∣ F(z q)` holds unconditionally), which is why **none** of them requires a
positivity or primality hypothesis.

## Research Directions

### 1. The entry point at prime powers: a Fibonacci "Wall–Sun–Sun" transport law

Conjecture: for a prime `p` and exponent `e ≥ 1`,
`z(p^e) = p^(max(0, e - w(p))) · z(p)` for some "wall exponent" `w(p) ≥ 1`, and generically
`z(p^e) = p^(e-1) · z(p)`. Equivalently, the monotone map `e ↦ z(p^e)` is eventually
multiplication-by-`p`. The exceptional primes (where `z(p^2) = z(p)`) are exactly the
Fibonacci–Wieferich / "Wall–Sun–Sun" primes, none known below astronomical bounds.

The key insight is that `fibEntry_dvd_of_dvd` already forces `z(p^e) ∣ z(p^{e+1})` and the
lcm law pins down the coprime part, so the *only* freedom left is the `p`-adic valuation of
`z(p^e)` — a single integer sequence per prime — converting a question about Fibonacci
numbers into a lifting-the-exponent estimate `v_p(F_{z(p)·k})`.

Why now? Functoriality (`fibEntry_dvd_of_dvd`) and the lcm law are in place, so the prime-power
case is the last missing generator of `z` on all of `ℕ`; closing it makes `z` *completely*
computable from its values on primes plus one `p`-adic valuation, and gives a fully formal
home for the Wall–Sun–Sun primes inside the catalog.

### 2. Faithfulness upgraded to an order isomorphism onto principal ideals

Conjecture: the assignment `p ↦ z(p)` descends to an order **isomorphism**
`({Fibonacci-divisibility predicates}, ⇒) ≅ (range z, ∣)`, and `range z` is exactly the set
of `m` with `m ∣ F m` — i.e. the entry point is idempotent-stable, `z(z(p)) ∣ z(p)` with
equality iff `p ∈ range z`.

The key insight is that `fibEntry_dvd_iff_fib_dvd_imp` already gives injectivity-up-to-predicate
(faithfulness); promoting it to a surjection onto `range z` only needs the fixed-point
characterization `z(F m) = m` (already proved as `FibEntryDuality.fibEntry_fib` for `m ≥ 3`),
recast as `m ∈ range z ↔ z(m) = m`.

Why now? With faithfulness (this cycle) and the `m ≥ 3` fixed-point lemma (prior cycle) both
formalized, the isomorphism is one quotient construction away; it would give the duality program
its definitive categorical statement — `z` *is* the universal transport, not merely a transport.

### 3. Transport of primitivity: closing the Carmichael infinite tail by descent

Conjecture: the primitive-divisor theorem `n ∉ {1,2,6,12} → ∃ primitive prime divisor of F n`
(whose composite, large-`n` tail is the lone remaining `sorry` in
`Catalog/Shared/CarmichaelProof.lean`) follows from a *transport* statement: `F n` has a
primitive prime divisor iff the "primitive part" `Φ_n := F n / lcm_{d ∣ n, d < n} F d` exceeds 1,
and `Φ_n > 1` for all `n > 12` by the growth estimate `F n ≍ φ^n` against the subexponential
bound `lcm_{d<n} F d ≤ ∏_{d ∣ n, d<n} F d`.

The key insight is that the lcm law `fibEntry_prod_coprime` and `fib_dvd_iff` already turn the
"earlier apparitions" obstruction into a clean lcm of proper-divisor terms, so the entire
arithmetic of the obstruction is now a statement about `z` and `lcm`, reducing Carmichael's tail
to a single real-analytic inequality `φ^{n} > C · φ^{n/2 · τ(n)}` provable by `Nat.fib` growth bounds.

Why now? The current proof discharges `n ≤ 10000` by `native_decide`; the structural lemmas
needed to replace the infinite tail by a growth argument (lcm law, strong divisibility,
duality) all became available this and last cycle, so the descent has a complete formal scaffold
for the first time.

### 4. A Lucas / generalized-Lucas-sequence transport principle

Conjecture: every theorem in `FibEntryTransport` holds verbatim for an arbitrary nondegenerate
Lucas sequence `U(P,Q)` (with `gcd`-compatibility `U_{gcd(m,n)} = gcd(U_m, U_n)` replaced by its
Lucas analogue): the rank of apparition `z_{P,Q}` is a faithful, monotone, periodicity-inducing
transport, and the four laws of this cycle are special cases `P=1, Q=-1`.

The key insight is that *the proofs in this file never use any Fibonacci-specific fact beyond the
single divisibility law `p ∣ U n ↔ z(p) ∣ n`*; abstracting the hypothesis "`U` admits a strong
divisibility / gcd law" makes all four theorems polymorphic over `U`.

Why now? The Fibonacci proofs are now short enough (each two lines from the duality) that the
abstraction cost is essentially zero; doing it produces a reusable `IsStrongDivisibilitySequence`
typeclass that immediately serves the Lucas, Pell, and Mersenne (`a^n - 1`) threads already
present elsewhere in the catalog.

### 5. Density and equidistribution of the entry-point map

Conjecture: the counting function `#{p ≤ X : z(p) ≤ Y}` obeys a two-variable asymptotic, and in
particular the "defect" set `{p : z(p) < p - 1}` (primes failing the maximal apparition `z(p) = p-1`)
has a positive natural density governed by the splitting of `x^2 - x - 1` mod `p` (i.e. by whether
`5` is a quadratic residue), making `z(p) ∣ p - (5/p)` the transport of the Legendre symbol.

The key insight is that `fibEntry_dvd_iff_fib_dvd_imp` reduces the law `z(p) ∣ p - (5/p)` to the
single implication `p ∣ F_{p-(5/p)}`, a clean Euler-criterion-style congruence, so the entire
density question becomes a Chebotarev/quadratic-reciprocity statement about the field
`ℚ(√5)` transported through `z`.

Why now? With the faithfulness theorem the arithmetic of `z(p)` is now *equivalent* to membership
statements `p ∣ F_k`, exactly the form Mathlib's quadratic-reciprocity and `ZMod` machinery can
attack; this is the natural analytic continuation of the structural (algebraic + order) program of
the previous cycles into the *analytic* regime.
