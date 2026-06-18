# Future Directions — Functoriality of the Fibonacci Rank of Apparition

## Synthesis

This cycle delivered `Catalog/Novelty/FibEntryFunctoriality.lean`, a self-contained,
`sorry`-free extension of the entry-point program in `Catalog/Novelty/FibonacciEntryPointDuality.lean`
(the master duality `p ∣ F n ↔ z(p) ∣ n`, where `z = fibEntry` is the rank of apparition) and
`Catalog/Novelty/FibCarmichaelStructure.lean` (totality of `z`, the coprime lcm law, the squarefree
law, and the `fibStep`/`fibPair` phase-space machinery).

Previously `z` was known to behave well only on *coprime* inputs (`z(mn) = lcm(z m)(z n)`) and on the
gcd. This cycle promotes `z` to a structure-preserving map of the **entire** divisibility poset and
ties it to the dynamics of the Fibonacci shift:

* **Functoriality** (`fibEntry_dvd_of_dvd`): `m ∣ n → z(m) ∣ z(n)`. The rank of apparition is a
  monotone morphism of `(ℕ, ∣)`, not merely of the coprime monoid. This is the capstone flagged as
  FUTURE_DIRECTIONS #5 of the previous cycle, and it follows in one relay through the duality.
* **Lax lattice morphism on all pairs** (`fibEntry_gcd_dvd`, `fibEntry_dvd_lcm`):
  `z(gcd m n) ∣ gcd(z m)(z n)` and `lcm(z m)(z n) ∣ z(lcm m n)` with **no coprimality hypothesis**,
  upgrading the coprime equalities to universal divisibilities.
* **Fibonacci–Korselt reduction** (`fib_dvd_squarefree_iff`): for squarefree `n`,
  `n ∣ F m ↔ ∀ p ∈ n.primeFactors, z(p) ∣ m`. The multi-prime apparition condition is *exactly* a
  conjunction of per-prime divisibilities — the Fibonacci analogue of the Korselt "for every prime
  factor" recombination (FUTURE_DIRECTIONS #3).
* **Pisano period as orbit length** (`pisano`, `pisano_pos`, `fibEntry_dvd_pisano`): defining the
  Pisano period as the order of the invertible Fibonacci shift `fibStep p` on the finite phase space
  `ZMod p × ZMod p`, the rank of apparition divides it: `z(p) ∣ π(p)` (FUTURE_DIRECTIONS #2's core
  divisibility, now purely group-theoretic).

The unifying realization is that the duality makes `{ n | p ∣ F n } = (z p)` a *principal ideal*, so
all order/lattice properties of these ideals descend to `z`, while the *same* function `z(p)` is the
first-return time of `(0,1)` under the permutation `fibStep p`, linking arithmetic to dynamics.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntry_dvd_of_dvd` | `m ∣ n → z(m) ∣ z(n)` (monotonicity) | proved, axioms = `propext, Classical.choice, Quot.sound` |
| `fibEntry_gcd_dvd` | `z(gcd m n) ∣ gcd(z m)(z n)` | proved |
| `fibEntry_dvd_lcm` | `lcm(z m)(z n) ∣ z(lcm m n)` | proved |
| `fib_dvd_squarefree_iff` | squarefree `n ∣ F m ↔ ∀ p ∣ n, z(p) ∣ m` | proved |
| `pisano_pos` | `π(p) > 0` for `[NeZero p]` | proved |
| `fibEntry_dvd_pisano` | `z(p) ∣ π(p)` | proved |

All main results are `sorry`-free and depend only on the standard Mathlib axioms.

## Research Directions

### 1. The Pisano period as a genuine first-return time, and the sandwich `z(p) ∣ π(p) ∣ z(p)·(p-1)`

We proved `z(p) ∣ π(p)` by showing the full permutation `fibStep p` returning to the identity drags
the orbit of `(0,1)` back to start. The sharper conjecture is that `π(p) = orderOf (fibStep p)` is in
fact the *minimal* `k` with `fibPair p k = fibPair p 0`, and that `π(p) ∣ z(p)·(p-1)` for prime `p`,
giving the classical sandwich `z(p) ∣ π(p) ∣ z(p)·(p-1)`. This is falsifiable: a single prime with
`π(p) ∤ z(p)·(p-1)` refutes it.
**The key insight is** that `fibStep p` is the companion matrix `[[0,1],[1,1]]`, so after `z(p)`
steps the orbit of `(0,1)` returns to the coordinate axis `{(0, *)}` with second coordinate
`F(z(p)+1)`, a unit acting by scalar multiplication; the residual period is the multiplicative order
of that unit, which divides `p-1` by Lagrange. **Why now?** `fibEntry_dvd_pisano` already realizes
`z(p)` as a divisor of `orderOf (fibStep p)`; the only missing step is identifying the quotient
`π(p)/z(p)` with `orderOf (F(z(p)+1) : (ZMod p)ˣ)`, which is concrete `ZMod`/`orderOf` algebra already
in Mathlib.

### 2. Strictness of the lattice inequalities, and when `z` is a true lattice homomorphism

We proved the *lax* laws `z(gcd m n) ∣ gcd(z m)(z n)` and `lcm(z m)(z n) ∣ z(lcm m n)`. Conjecture:
both are *equalities* whenever `m, n` are coprime (already implied by `fibEntry_coprime_mul`), but
both can be *strict* in general — the smallest witness of strict `z(gcd) ⊊ gcd(z)` is conjectured to
occur at the first pair `m, n` sharing a Wall–Sun–Sun-type prime power. The conjecture is sharply
falsifiable: equality for all `m, n ≤ N` for increasing `N` would refute strictness, while one strict
pair confirms it.
**The key insight is** that equality in the meet law is equivalent to `z` commuting with gcd, which
by the duality is equivalent to the apparition ideals being closed under sum — a property that fails
exactly when prime-power apparition `z(p^e)` grows faster than `lcm` predicts. **Why now?** With both
lax laws (`fibEntry_gcd_dvd`, `fibEntry_dvd_lcm`) and the coprime equalities now formalized in the
same namespace, isolating the strictness gap is a finite search bounded by the prime-power refinement,
not open-ended theory.

### 3. A complete Fibonacci–Carmichael criterion from the squarefree reduction

`fib_dvd_squarefree_iff` reduces `n ∣ F m` (squarefree `n`) to `∀ p ∣ n, z(p) ∣ m`. Combined with the
classical law of apparition `z(p) ∣ p - (5|p)`, conjecture: a squarefree composite `n` is a
*Fibonacci–Carmichael number* (`n ∣ F(n - (5|n))`) **iff** `z(p) ∣ n - (5|p)` for every prime `p ∣ n`.
This is the exact Fibonacci analogue of Korselt's criterion `(p-1) ∣ (n-1)` from
`Catalog/Novelty/KorseltCarmichael.lean`, and it is falsifiable by exhibiting one squarefree composite
violating either direction.
**The key insight is** that `fib_dvd_squarefree_iff` already turns the global condition `n ∣ F m` into a
per-prime conjunction, so the criterion is literally `∀ p ∣ n, z(p) ∣ m` specialized to
`m = n - (5|n)` — the entire content is the per-prime law `z(p) ∣ p - (5|p)` plus tracking the Jacobi
symbol `(5|n) = ∏ (5|p)`. **Why now?** The squarefree reduction (this cycle) supplies the "for every
prime factor" half, and `KorseltCarmichael.dvd_pow_sub_self` supplies the recombination template; the
bridge is a cross-domain synthesis of two finished catalog results.

### 4. Prime-power apparition `z(p^e)` and a fully multiplicative formula for `z(n)`

The lax lattice laws and the squarefree reduction reduce general `z(n)` to prime-power values
`z(p^e)`. Conjecture: `z(p^e) = p^{max(0, e - v_p(F(z p)))} · z(p)`, equivalently `z(p^e) = p^{e-1}·z(p)`
for all `e ≥ 1` **iff** `p` is not a Wall–Sun–Sun prime. Plugged into the (conjectured) equality form
of `fibEntry_dvd_lcm`, this yields a complete closed formula `z(n) = lcm_{p^e ‖ n} z(p^e)`. Falsifiable
by one prime with `v_p(F(z(p^2))) ≠ v_p(F(z p)) + 1`.
**The key insight is** that the `p`-adic valuation obeys an LTE law `v_p(F n) = v_p(F(z p)) + v_p(n/z p)`
once `z(p) ∣ n`, so the whole prime-power behaviour is governed by the single integer `v_p(F(z p))`.
**Why now?** Monotonicity `fibEntry_dvd_of_dvd` already gives `z(p) ∣ z(p^e)` and `z(p^{e}) ∣ z(p^{e+1})`,
pinning the tower into a chain; the remaining task is the valuation step, for which Mathlib's
`multiplicity`/`Nat.factorization` API is directly applicable.

### 5. Functoriality as a bona fide order-embedding into the Pisano lattice

We have `z : (ℕ, ∣) → (ℕ, ∣)` monotone and `z(p) ∣ π(p)`. Conjecture: the assignment
`p ↦ (z(p), π(p))` is an order-preserving map into the product poset, and the Pisano period itself is
monotone (`m ∣ n → π(m) ∣ π(n)`) so that the pair `(z, π)` forms a *coherent* pair of divisibility
functors with `z ∣ π` pointwise — i.e. `z` is a sub-functor of `π`. Falsifiable: one pair `m ∣ n` with
`π(m) ∤ π(n)` refutes Pisano monotonicity.
**The key insight is** that `π(p) = orderOf (fibStep p)` and reduction `ZMod n → ZMod m` (for `m ∣ n`)
is a ring hom intertwining the two shifts, so it carries `fibStep n` to `fibStep m` and hence
`orderOf (fibStep m) ∣ orderOf (fibStep n)` by the standard `orderOf` functoriality under monoid homs.
**Why now?** With `pisano` defined as an `orderOf` and `fibStep` already an `Equiv`, Pisano monotonicity
becomes `orderOf_dvd_of_...` along the `ZMod` reduction map — a Mathlib-native group-theory argument
that reuses exactly the machinery introduced this cycle.
