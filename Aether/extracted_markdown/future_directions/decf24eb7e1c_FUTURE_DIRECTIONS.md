# Future Directions — Self-Indexing and the Lattice Morphism of the Fibonacci Rank of Apparition

## Synthesis

This cycle put the Fibonacci rank of apparition `z(m) = min { k > 0 : m ∣ F k }` on a
genuinely *buildable* foundation and pinned down its behaviour as a map between two
divisibility lattices: the lattice of moduli and the lattice of indices. The existing catalog
file `Catalog/Applications/FibonacciApparitionLattice.lean` stated the join/meet laws, but it
imports a `Speculative.AutoResearch.FibonacciApparition` module whose source is absent from the
repository, so those statements do not compile. We re-derived the entire package against the
self-contained foundation `Catalog/Novelty/FibApparitionExistence.lean` (the namespace
`FibApparition`, whose only external dependency is Mathlib), and we added the genuinely new
*self-indexing* theorem that the catalog never recorded.

The decisive tool is, as before, the **law of apparition** `m ∣ F n ↔ z(m) ∣ n`
(`FibApparition.fib_dvd_iff_apparitionRank_dvd`), proved unconditionally for every `m ≥ 1` from
a pigeonhole argument on the Fibonacci shift map over `ZMod m`. Once it is in hand, every
lattice statement about `z` collapses to an elementary divisibility statement about indices.

The honest one-line summary: **`z` is a join-morphism and a meet-sub-morphism of divisibility
lattices, and it fixes every Fibonacci number `F n` at its own index `n` — for every `n` except
the degenerate `n = 2` where `F 2 = 1` collides with `F 1`.**

A second outcome of this cycle was *negative and important*: the previously-floated conjecture
that the equation `z(m) = m` has solution set exactly `{1, 5}` is **false**. A direct
computation (verified by `#eval`) shows the fixed-point set begins `1, 5, 12, 25, …`: `z(12)=12`
because the first Fibonacci number divisible by `12` is `F_12 = 144`, and `z(25)=25` because
`25 ∣ F_25 = 75025` with no earlier appearance. Self-indexing constrains only moduli that *are*
Fibonacci numbers; it says nothing about general fixed points. This correction reshapes the
direction below.

## Results summary

All theorems live in `Catalog/Applications/FibApparitionSelfIndex.lean`, are `sorry`-free, and
depend only on `propext, Classical.choice, Quot.sound`. Writing `z := FibApparition.apparitionRank`:

| Theorem | Statement | Status |
|---|---|---|
| `apparitionRank_lcm` | `z(lcm a b) = lcm(z a, z b)` (all `a,b > 0`) | proved |
| `apparitionRank_monotone` | `a ∣ b → z a ∣ z b` | proved |
| `apparitionRank_gcd_dvd` | `z(gcd a b) ∣ gcd(z a, z b)` | proved |
| `apparitionRank_gcd_not_exact` | meet bound strict at `(4,6)` | proved |
| `apparitionRank_fib_self` | `z(F n) = n` for `n ≥ 3` | proved |
| `apparitionRank_fib_eq_self_iff` | `z(F n) = n ↔ n ≠ 2` (sharp) | proved |

## Research directions

### 1. Classify the true fixed-point set of `z` — the "self-apparition numbers"

Our computation overturns the `{1,5}` conjecture: the solution set of `z(m) = m` begins
`1, 5, 12, 25, 60, 125, …` and is exactly the set of `m` such that `m ∣ F_m` *and* `m` divides
no earlier Fibonacci number. Conjecture: `z(m) = m` holds **iff** `m` is a product of prime
powers `p^e` each of which is itself a self-apparition number, with the multiplicative structure
governed by `z(p^e)`; concretely, the set is closed under the operations `m ↦ p·m` precisely
when `z(p·m) = p·m`, giving an effectively enumerable, lcm-stable subsemigroup of `(ℕ, ·)`.
**The key insight is** that `z(m) = m` is equivalent to the conjunction "`m ∣ F_m`" and "`z(m)`
is not a *proper* divisor of `m`", and our proved `apparitionRank_lcm` already forces `z(m)` to
factor through the prime-power parts of `m`, so the whole question reduces to understanding
single-prime-power fixed points `z(p^e) = p^e`. **Why now?** We have an exact, sorry-free join
law (`apparitionRank_lcm`) and the computational engine to enumerate witnesses; the remaining
content is a finite per-prime tower analysis. Falsifiable by exhibiting a fixed point `m` that
is *not* an lcm of prime-power fixed points, or by proving the closure law fails for some `p`.

### 2. The exact gcd-defect is a 2-adic phenomenon

The meet bound `z(gcd a b) ∣ gcd(z a, z b)` (`apparitionRank_gcd_dvd`) is strict, with `(4,6)`
the minimal witness (`apparitionRank_gcd_not_exact`). Conjecture: the defect ratio
`gcd(z a, z b) / z(gcd a b)` is always a power of `2`, controlled entirely by the entry points
at the prime `2`, where `z(2)=3`, `z(4)=6`, `z(8)=6` — the doubling collision `z(8)=z(6)=6` being
the unique small obstruction to injectivity of `z`. **The key insight is** that the only place a
lattice morphism can leak is where `z` fails to be injective along a `p`-adic tower, and for
Fibonacci the first such anomaly sits at `p = 2`. **Why now?** With the join exact and the meet
sub-exact already proved here, the entire defect is isolated into a single computable ratio; a
finite verification over residues mod small powers of `2`, combined with `apparitionRank_lcm`,
would settle it. Falsifiable by any pair `(a,b)` whose defect ratio has an odd prime factor.

### 3. The join law upgrades to a full prime-power product formula

Combining `apparitionRank_lcm` with multiplicativity over coprime parts yields the closed form
`z(m) = lcm_{p^e ∥ m} z(p^e)`. Conjecture the single-prime tower law
`z(p^{e+1}) = p · z(p^e)` for all `e ≥ 1`, equivalent to the non-Wall–Sun–Sun condition
`p^2 ∤ F_{z(p)}`. **The key insight is** that `apparitionRank_lcm` already reduces all
entry-point computation to prime powers, so the only unknown is the tower step, which links this
elementary lattice theory to the famous open Wall–Sun–Sun problem. **Why now?** The prime-power
reduction is no longer conjectural — it is a corollary of the proved join law — so formalizing
the tower step gives a decision procedure for `z(m)` for every `m` free of Wall–Sun–Sun primes.
Falsifiable: a prime `p` with `z(p^2) = z(p)` refutes the tower law (and would be a Wall–Sun–Sun
prime).

### 4. Self-indexing transfers to every strong divisibility sequence

The proofs of `apparitionRank_lcm`, `apparitionRank_monotone`, `apparitionRank_gcd_dvd`, and the
self-indexing law used only the strong-divisibility identity `gcd(F m, F n) = F(gcd m n)` and
minimality of the entry point — never the *value* `F n`. Conjecture: for *any* strong
divisibility sequence `u` with `u(0)=0`, `u(1)=1`, and bounded residues, the entry map `z_u` is a
join-morphism, a meet-sub-morphism, and satisfies `z_u(u n) = n` beyond a sequence-dependent
threshold. **The key insight is** that the catalog already isolates this abstraction
(`StrongDivSeq` in `Catalog/Novelty/FibonacciEntryPointInvariant.lean`), so the entire package is
a theorem about the renormalization identity, not about Fibonacci. **Why now?** Porting
`apparitionRank_lcm` and `apparitionRank_fib_self` into the `StrongDivSeq` setting would
instantiate immediately to the Mersenne/repunit sequences `a^n - 1` (via
`Nat.pow_sub_one_gcd_pow_sub_one`, already used in the catalog). Falsifiable by any strong
divisibility sequence whose entry map fails the join law or the self-indexing threshold.

### 5. Apparition controls a sharp Pisano-period divisibility tower

The pigeonhole behind `FibApparition.fib_apparition_exists` produces, but does not name, the
Pisano period `π(m)`. Conjecture the tower `z(m) ∣ π(m) ∣ z(m) · ord_m(±1)`, with `z(m) = π(m)`
exactly when the unit `F_{z(m)+1} ≡ 1 (mod m)`. **The key insight is** that the same shift-map
orbit (`FibApparition.fibStep`, `FibApparition.fibStep_iterate`) that yields `z` as the *first
return to the F-axis* yields `π` as the *first return to the identity*, so `π/z` is exactly the
multiplicative order of the diagonal twist `F_{z+1}` in `(ZMod m)ˣ`, expressible with Mathlib's
`orderOf`. **Why now?** The orbit dynamics are already formalized as an `Equiv` with a clean
iterate lemma, so building `π(m)` as an `orderOf` and proving the divisibility tower would give
Mathlib its first Pisano-period theory, with `z` as the cornerstone. Falsifiable by any `m` with
`z(m) ∤ π(m)`, or `π(m)/z(m)` exceeding the order of the orientation unit.
