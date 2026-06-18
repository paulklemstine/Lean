# Future Directions — The Fibonacci Divisibility Lattice

## Synthesis

This cycle isolated a single catalog identity — `Nat.fib_gcd`, i.e.
`fib (gcd m n) = gcd (fib m) (fib n)` (the catalog's *Fib_gcd_identity*) — and showed
it is the *only* structural input needed to recover the entire divisibility lattice of
the Fibonacci sequence. From it, together with strict monotonicity of `fib` above index
`1`, three first-principles theorems fall out cleanly in
`Catalog/Cryptography/FibonacciDivisibilityLattice.lean`:

* `fib_dvd_fib_iff` — the **converse divisibility law** `fib m ∣ fib n ↔ m ∣ n`
  (`3 ≤ m`), the half *not* in Mathlib (Mathlib only ships the forward `Nat.fib_dvd`);
* `fib_coprime_iff` — coprimality of `fib m, fib n` is governed entirely by
  `gcd m n ∈ {1,2}`, with no positivity hypotheses;
* `entry_exists` + `fib_dvd_iff_entry_dvd` — every modulus has a **rank of apparition**
  `entry m`, and it *generates* all apparition indices: `m ∣ fib n ↔ entry m ∣ n`.

The unifying mechanism is that `fib_gcd` exhibits `fib` as a **lattice homomorphism**
from `(ℕ, gcd)` to `(ℕ, gcd)`; once `fib` is injective above the unit indices, this
homomorphism is *faithful*, and every downstairs divisibility/coprimality question is
answered upstairs. The rank-of-apparition layer turns this into the algebraic skeleton
underlying Lucas-sequence primality testing — the reason the file lives in the
Cryptography domain.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_inj_iff` | `fib` injective on `{n ≥ 2}` | proved |
| `fib_eq_one_iff` | `fib k = 1 ↔ k ∈ {1,2}` | proved |
| `fib_dvd_fib_iff` | `fib m ∣ fib n ↔ m ∣ n` for `3 ≤ m` | proved |
| `fib_coprime_iff` | `Coprime (fib m) (fib n) ↔ gcd m n ∈ {1,2}` | proved |
| `entry_exists` | rank of apparition exists for `m > 0` | proved |
| `fib_dvd_iff_entry_dvd` | `m ∣ fib n ↔ entry m ∣ n` | proved |

All six results compile with `sorry = 0` and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

## Conjectures for the Next Cycle

**Direction 1 — Multiplicativity of the rank of apparition on coprime moduli.**
Conjecture: for coprime `a, b > 0`, `entry (a * b) = Nat.lcm (entry a) (entry b)`.
The key insight is that `m ∣ fib n ↔ entry m ∣ n` (already proved) turns the apparition
predicate into a *divisibility* predicate, and for coprime `a, b` we have
`a*b ∣ fib n ↔ a ∣ fib n ∧ b ∣ fib n ↔ entry a ∣ n ∧ entry b ∣ n ↔ lcm (entry a)(entry b) ∣ n`;
matching generators of equal divisor-sets pins the value. Why now? The two ingredients —
the apparition law and CRT for `∣` — are both in hand this cycle, so the proof is a short
composition rather than new theory.

**Direction 2 — Wall's conjecture is falsifiable at the lattice level.**
Conjecture (Wall–Sun–Sun): for every prime `p`, `entry (p^2) = p * entry p`
(equivalently `p^2 ∤ fib (entry p)`). The key insight is that our `entry` is now a
*computable-in-principle, fully specified* function via `Nat.find`, so the statement is a
clean arithmetic predicate on primes rather than folklore; a single counterexample prime
would refute it, and none is known below `2^64`. Why now? With `fib_dvd_iff_entry_dvd`
established, "Wall-Sun-Sun prime" becomes definable inside the catalog, enabling a
`native_decide`-backed search lemma `∀ p ∈ range N, ¬ WallSunSun p` as a first milestone.

**Direction 3 — The lattice transports to every nondegenerate Lucas U-sequence.**
Conjecture: any integer sequence `U` satisfying the strong divisibility identity
`gcd (U m) (U n) = U (gcd m n)` and strict growth above some index obeys verbatim
analogues of `fib_dvd_fib_iff`, `fib_coprime_iff`, and `fib_dvd_iff_entry_dvd`. The key
insight is that our proofs used *only* `fib_gcd` + monotonicity, never a closed form for
`fib`, so the arguments are secretly statements about abstract strong divisibility
sequences. Why now? Abstracting the three theorems over a typeclass `StrongDivSeq` is pure
refactoring of already-verified Lean, and immediately subsumes Mersenne numbers
`2^n - 1` (whose `gcd (2^m-1)(2^n-1) = 2^(gcd m n)-1` is already in the catalog).

**Direction 4 — Carmichael primitive divisors via the entry-point spectrum.**
Conjecture: for `n ≥ 13`, `fib n` has a prime `p` with `entry p = n` (a *primitive* prime
divisor). The key insight is that `entry p = n` is exactly the primitivity condition
`p ∣ fib n ∧ ∀ k < n, p ∤ fib k`, rephrased through `fib_dvd_iff_entry_dvd`; the catalog's
stalled `fib_carmichael_composite` reduces to showing the entry-point spectrum
`{entry p : p ∣ fib n}` attains the value `n`. Why now? This cycle gives the missing clean
definition of `entry` that the broken `Shared/CarmichaelProof.lean` lacked (its imports
`Shared.CarmichaelHelper`/`Shared.CarmichaelComposite` are absent), offering a fresh,
self-contained route to the composite tail rather than the abandoned computational one.

**Direction 5 — Pisano-period bound on apparition rank for cryptographic sizing.**
Conjecture: `entry m ≤ π(m)`, the Pisano period of `m`, with equality iff the Fibonacci
orbit mod `m` hits `0` exactly once per period. The key insight is that `entry_exists` was
proved by pigeonhole on the period of `(fib k, fib (k+1)) mod m`, so the *same* finite
orbit simultaneously bounds the apparition rank — the existence proof already contains the
bound. Why now? The orbit-return argument is the literal content of the `entry_exists`
proof, so extracting the quantitative `entry m ≤ π(m)` is a strengthening of a proof we
already have, and it gives the first catalog handle on the cost of Lucas-style primality
witnesses.
