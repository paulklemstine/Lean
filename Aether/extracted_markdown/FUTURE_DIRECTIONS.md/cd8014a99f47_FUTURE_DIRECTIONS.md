# Future Directions — Fibonacci Rank of Apparition

The file `Catalog/Speculative/FibApparitionExistence.lean` establishes, for every
modulus `m ≥ 1`, the **existence** of the Fibonacci rank of apparition `z(m)` (the least
positive `k` with `m ∣ F k`) and the full **biconditional** divisibility law
`m ∣ F n ↔ z(m) ∣ n`. The existence proof is purely structural: it iterates the
Fibonacci shift permutation `(a,b) ↦ (b, a+b)` on the finite set `ZMod m × ZMod m` and
uses pigeonhole + injectivity to force a return to `(0,1)`. This is the abstract engine
behind the Pisano period, none of which currently lives in Mathlib. The catalog's existing
`fibEntryPt_dvd_of_fib_dvd` (in `Speculative.AutoResearch.CarmichaelComposite`) is now a
strict corollary, freed from its primality assumption. The directions below build outward
from this foundation.

## 1. The Pisano period as the order of the shift permutation

Define the Pisano period `π(m)` as the least positive `t` with `(fibStep m)^[t] = id`,
i.e. the order of `fibStep m` in the permutation group of `ZMod m × ZMod m`. Conjecture:
`π(m)` exists for every `m ≥ 1`, equals `orderOf (fibStep m)`, and satisfies
`z(m) ∣ π(m)` together with the multiplicative bound `π(m) ∣ lcm` of the prime-power
Pisano periods of `m`.

The key insight is that `fibStep m` is a genuine group element (an `Equiv`), so its order
is a single algebraic invariant from which both the Pisano period and the rank of
apparition descend — `z(m)` is the first index where the *first coordinate* vanishes,
while `π(m)` is the first index where the *whole state* returns. Why now? The present file
already packages `fibStep` as an `Equiv.Perm`-style object and proves `fibStep_iterate`, so
`orderOf` and `Function.IsPeriodicPt` apply directly without any new infrastructure.

## 2. Multiplicativity of the rank of apparition

Conjecture: if `gcd(a, b) = 1` then `z(a * b) = lcm(z(a), z(b))`, and consequently `z` is
determined by its values on prime powers. Combined with Direction 1 this would give a
complete recursive formula for `z(m)`.

The key insight is that `m ∣ F n ↔ z(m) ∣ n` (already proved as
`fib_dvd_iff_apparitionRank_dvd`) turns a divisibility statement about `F n` into a lattice
statement about the divisors of `n`: for coprime `a, b`, `a*b ∣ F n ↔ (z(a) ∣ n ∧ z(b) ∣ n)
↔ lcm(z(a), z(b)) ∣ n`, and the least such `n` is exactly the lcm. Why now? The
biconditional that makes this CRT-style argument purely formal is exactly the capstone
theorem just proved, so the conjecture is reducible to elementary lattice manipulation plus
`Nat.Coprime` API.

## 3. The law of apparition for primes (z(p) ∣ p − (5/p))

Conjecture: for a prime `p ≠ 5`, the rank of apparition divides `p - (5 | p)`, where
`(5 | p)` is the Legendre symbol; concretely `z(p) ∣ p − 1` when `p ≡ ±1 (mod 5)` and
`z(p) ∣ p + 1` when `p ≡ ±2 (mod 5)`. This refines pure existence into a sharp size bound
`z(p) ≤ p + 1`.

The key insight is that working in `ZMod p` adjoined with a square root of `5` lets the
Binet formula `F n = (φⁿ − ψⁿ)/√5` become an honest identity, turning the apparition index
into the multiplicative order of `φ/ψ`, which divides the order of the unit group via
Fermat/Frobenius. Why now? The shift-map framework already embeds Fibonacci dynamics into a
finite ring; replacing `ZMod m × ZMod m` by the rank-2 algebra `ZMod p[X]/(X²−X−1)` reuses
the identical pigeonhole/order machinery while sharpening the bound from "finite" to
"linear in p".

## 4. Carmichael-style primitive divisors via the rank lattice

Conjecture: for every `n ≥ 13`, `F n` has a prime divisor `p` with `z(p) = n` (a primitive
prime divisor). Equivalently, the "new part" of `F n` — the cofactor after dividing out all
`F d` for proper divisors `d ∣ n` — exceeds `1`.

The key insight is that `z(p) = n` is *equivalent* to "`p ∣ F n` but `p ∤ F d` for every
proper divisor `d ∣ n`", which by `fib_dvd_iff_apparitionRank_dvd` is a statement entirely
about the divisor lattice of `n` plus a size comparison `F n > ∏ F d`. Why now? The catalog
already contains the size/coprime-part bookkeeping in `CarmichaelComposite.lean`; pairing it
with the unconditional, primality-free `fib_dvd_iff_apparitionRank_dvd` removes the
ad hoc primality hypotheses and makes the lattice argument uniform across prime and
composite `n`.

## 5. Generalization to arbitrary Lucas sequences and linear recurrences

Conjecture: every nondegenerate Lucas sequence `U(P,Q)` (with `gcd(stuff)` conditions) is a
*strong divisibility sequence* and admits a rank of apparition for every modulus coprime to
`Q`, with the same biconditional `m ∣ U n ↔ z(m) ∣ n`. More generally, any integer linear
recurrence whose companion matrix is invertible mod `m` has a well-defined apparition index.

The key insight is that nothing in the present existence proof uses the specific Fibonacci
recurrence beyond (i) the step map being an invertible affine/linear map on a finite module
and (ii) the chosen start vector. Replacing `fibStep` by the companion matrix of a general
recurrence over `ZMod m` keeps pigeonhole + injectivity verbatim. Why now? The proof here is
already phrased through an abstract `Equiv` rather than explicit Fibonacci arithmetic, so
generalizing amounts to swapping the `2×2` companion matrix and re-running the orbit
argument — a high-leverage abstraction that subsumes Pell, Mersenne, and Jacobsthal
sequences in one stroke.
