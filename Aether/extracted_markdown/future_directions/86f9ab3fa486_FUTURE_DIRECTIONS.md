# Future Directions — Rank of Apparition & Fibonacci Primitive Divisors

## Synthesis

This cycle isolated the *single algebraic engine* behind the divisibility theory of
the Fibonacci sequence: the strong-divisibility identity
`Nat.fib_gcd : fib (gcd m n) = gcd (fib m) (fib n)`. From it alone — with **no
primality, no cyclotomic theory, and no analysis** — we derived a complete,
first-principles account of the *rank of apparition* (entry point) map and a clean
structural characterization of primitive divisors:

- `fib_entry_point` — the indices at which a modulus `p` appears are *exactly* the
  multiples of its least index of appearance `z`. This is the fundamental theorem of
  the entry point, stated in maximal generality (`p` an arbitrary natural).
- `fib_strong_divisibility` — for `3 ≤ m`, `fib m ∣ fib n ↔ m ∣ n`.
- `fib_coprime_iff` — `fib m`, `fib n` are coprime iff `gcd m n ≤ 2`.
- `fib_primitive_divisor_entry` — a primitive divisor of `fib n` has entry point
  exactly `n`, so its appearance set is precisely the multiples of `n`.

These results are the structural skeleton sitting *underneath* Carmichael's
primitive-divisor theorem (`Catalog/Shared/CarmichaelProof.lean`,
`Catalog/Novelty/KorseltCarmichael.lean`): the `bridge_lemma` used there is exactly
`fib_primitive_divisor_entry` restricted to indices `< n`. The catalog's Carmichael
file currently discharges the composite range `[13, 10000]` by `native_decide` and
leaves the infinite composite tail `n > 10000` as the lone open `sorry`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_gcd` | `p ∣ fib m → p ∣ fib n → p ∣ fib (gcd m n)` | proved (sorry = 0) |
| `fib_entry_point` | least-index `z` ⇒ (`p ∣ fib n ↔ z ∣ n`) | proved (sorry = 0) |
| `fib_strong_divisibility` | `3 ≤ m ⇒ (fib m ∣ fib n ↔ m ∣ n)` | proved (sorry = 0) |
| `fib_coprime_iff` | `Coprime (fib m) (fib n) ↔ gcd m n ≤ 2` | proved (sorry = 0) |
| `fib_primitive_divisor_entry` | primitive divisor of `fib n` ⇒ appearance set = multiples of `n` | proved (sorry = 0) |

All five depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Entry-point multiplicativity across coprime moduli

**Conjecture.** For coprime `a b > 0`, the entry point satisfies
`z(a*b) = lcm (z a) (z b)`, where `z m` is the least positive index with `m ∣ fib`.
The key insight is that `fib_entry_point` turns "`m ∣ fib n`" into a *purely
arithmetic* membership "`z m ∣ n`", so for coprime `a, b` we have
`a*b ∣ fib n ↔ z a ∣ n ∧ z b ∣ n ↔ lcm (z a) (z b) ∣ n`, and the least such `n` is
the lcm. This is falsifiable: a single coprime pair with
`z(ab) ≠ lcm(z a)(z b)` refutes it.
**Why now?** `fib_entry_point` is already proved in this cycle and reduces the claim
to elementary lcm/gcd manipulation in `ℕ`; no new analytic input is needed, so the
subagent can attack it directly from the lemmas already in `FibonacciRankOfApparition.lean`.

### 2. Periodicity of `fib mod p` is governed by the entry point

**Conjecture.** For prime `p`, the Pisano period `π(p)` is a multiple of the entry
point `z(p)`, and `z(p) ∣ π(p) ∣` a small explicit multiple of `z(p)` (1, 2, or 4
times). The key insight is that `p ∣ fib n ↔ z(p) ∣ n` (this cycle) already pins the
*zero set* of `fib mod p` to an arithmetic progression of step `z(p)`; the full
period must respect that progression. This is falsifiable on any prime by direct
computation of `π(p)` and `z(p)`.
**Why now?** Mathlib has the Pisano-period scaffolding (`ZMod` Fibonacci), and the
zero-set description from `fib_entry_point` is the missing combinatorial bridge that
connects "where `fib` vanishes mod `p`" to "how long until `fib` repeats mod `p`".

### 3. Strong divisibility extends to all Lucas sequences `U_n(P,Q)`

**Conjecture.** The pair `(fib_dvd_gcd, fib_entry_point)` generalizes verbatim to any
nondegenerate Lucas sequence `U` with `gcd(U m, U n) = ± U (gcd m n)`; in particular
`fib_strong_divisibility` and the entry-point theorem hold for `U` with the same
proofs. The key insight is that *none* of this cycle's proofs used the recurrence
`fib (n+2) = fib (n+1) + fib n` directly — they used only `fib_gcd`, `fib_dvd`, and
monotonicity — so the argument is a theorem about *strong divisibility sequences*,
not about Fibonacci specifically. Falsifiable: exhibit a Lucas sequence satisfying
the gcd identity but failing `U m ∣ U n ↔ m ∣ n` for `m ≥ 3`.
**Why now?** Abstracting the hypotheses to a `StrongDivisibilitySequence` structure is
a clean refactor of an *already-closed* proof, yielding a reusable Mathlib-style
typeclass that the rest of the catalog (Carmichael, Korselt) can import.

### 4. Closing the Carmichael composite tail via the entry-point sieve

**Conjecture.** For every composite `n > 10000`, `primPart n > 1`
(`Catalog/Shared/CarmichaelProof.lean`), equivalently `fib n` has a prime divisor of
entry point exactly `n`. The key insight is that `fib_primitive_divisor_entry` shows a
primitive divisor is *precisely* a prime whose entry point equals `n`, so the tail
reduces to a lower bound: `fib n` exceeds the product of `fib d` over proper divisors
`d ∣ n` (a cyclotomic/Zsygmondy size estimate), forcing an un-stripped prime to
survive. This is falsifiable by a single composite counterexample (none expected past
the classical exceptions `1, 2, 6, 12`).
**Why now?** The finite range is already machine-verified and the *structural* meaning
of "primitive" is now a proved equivalence (this cycle); what remains is a self-
contained growth estimate `fib n / ∏_{d∣n, d<n} fib d > 1`, which is amenable to
induction on the number of prime factors of `n` rather than full cyclotomic theory.

### 5. A density theorem for primes with prescribed entry point

**Conjecture.** For each `n` not in `{1,2,6,12}` the set of primes `p` with entry
point exactly `n` is nonempty (Carmichael) and, moreover, its smallest element is
`≤ fib n`. The key insight is that `fib_primitive_divisor_entry` makes "smallest prime
of entry point `n`" identical to "smallest primitive prime divisor of `fib n`", and
`primPart n` from the catalog is an *explicit witness* whose minimal factor realizes
the bound. Falsifiable: a value `n` whose smallest entry-point-`n` prime exceeds
`fib n`.
**Why now?** `primPart` and `primPart_implies_primitive` already exist and produce a
concrete prime; combining them with the entry-point equivalence converts an
existence statement into an *effective* one with a checkable numeric bound.
