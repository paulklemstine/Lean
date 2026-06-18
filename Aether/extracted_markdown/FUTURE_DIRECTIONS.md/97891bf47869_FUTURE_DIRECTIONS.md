# Future Directions: The Rank of Apparition after `FibonacciApparition.lean`

## Synthesis

`Catalog/Speculative/AutoResearch/FibonacciApparition.lean` now establishes, fully
`sorry`-free and self-contained against Mathlib, the foundational theory of the Fibonacci
rank of apparition `fibEntry m` (the least `k > 0` with `m ∣ F k`):

* **Unconditional existence** `fibEntry_exists : 1 ≤ m → ∃ k, 0 < k ∧ m ∣ F k`, proved
  through the finite order of the Fibonacci shift permutation `fibStep` on
  `ZMod m × ZMod m` — an abstract, Pisano-free route to the period.
* **The law of apparition** `fib_dvd_iff_fibEntry_dvd : m ∣ F n ↔ fibEntry m ∣ n`
  (and its unconditional form `fib_dvd_iff_fibEntry_dvd_of_pos`).
* **The primitive-divisor characterisation** `prime_primitive_iff`.
* Two new cross-frontier theorems: **Carmichael's exceptional ranks**
  `fibEntry_not_exceptional` (no prime has rank in `{1,2,6,12}`) and the decidable
  **no Wall–Sun–Sun prime below 100** `no_wallSunSun_prime_below_hundred`.

This recasts the catalog's Carmichael targets as statements about a single arithmetic
function and gives the first uniform existence proof. The directions below extend the
frontier.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntry_exists` | rank of apparition exists for all `m ≥ 1` | proved |
| `fib_dvd_iff_fibEntry_dvd` | `m ∣ F n ↔ fibEntry m ∣ n` | proved |
| `prime_primitive_iff` | primitive divisor ⇔ `fibEntry p = n` | proved |
| `fibEntry_not_exceptional` | no prime rank in `{1,2,6,12}` | proved |
| `no_wallSunSun_prime_below_hundred` | no Wall–Sun–Sun prime `< 100` | proved |

## Direction 1 — Quantifying the entry point: `fibEntry p ∣ p − (5/p)`

For an odd prime `p ≠ 5`, the rank of apparition divides `p − (5/p)`, the Legendre symbol;
so `fibEntry p ≤ p + 1`, which is exactly the (currently externally justified) search bound
in `no_wallSunSun_prime_below_hundred`. **The key insight is** that this is the Fibonacci
shadow of Fermat's little theorem in the quadratic ring `ZMod p[√5]`: `α^p ≡ α^{(5/p)}`,
which translates into the divisibility `p ∣ F_{p − (5/p)}` and then, by the *already proved*
`fib_dvd_iff_fibEntry_dvd`, into `fibEntry p ∣ p − (5/p)`. **Why now?** The hard half —
turning a congruence into a divisibility of indices — is finished; what remains is purely
the Frobenius congruence `α^p ≡ α^{(5/p)}` in `ZMod p[√5]`, for which Mathlib's `ZMod`,
`Polynomial`, and `legendreSym` API are now mature. Proving it would *internalise* the
`p + 1` bound and upgrade `no_wallSunSun_prime_below_hundred` from a bounded check to a
statement whose hypothesis bound is theorem-justified.

## Direction 2 — Lifting the exponent: `fibEntry (p²) ∈ {fibEntry p, p · fibEntry p}`

The Wall–Sun–Sun conjecture is the assertion `fibEntry (p²) = p · fibEntry p` for every
prime `p`. **The key insight is** that the entry point lifts through prime powers by a
controlled factor: monotonicity (`p ∣ p²` gives `fibEntry p ∣ fibEntry (p²)`) plus a
Fibonacci lifting-the-exponent estimate `v_p(F_{p·α}) = v_p(F_α) + 1` pins the ratio
`fibEntry (p²) / fibEntry p` to the prime `p`, so it is either `1` or `p`, with the value
`p` occurring **iff** `p² ∤ F_{fibEntry p}`. **Why now?** With `fibEntry`, `fibEntry_exists`,
and `prime_primitive_iff` in place, the only missing lemma is the single `p`-adic valuation
identity for Fibonacci numbers; everything else is the proved law of apparition. This would
turn `no_wallSunSun_prime_below_hundred` into a corollary of an *abstract* dichotomy rather
than a finite computation.

## Direction 3 — Cofiniteness of realised ranks (the arithmetic phase transition)

Call `n` a *realised rank* if `n = fibEntry p` for some prime `p`. `prime_primitive_iff`
makes "`n` is realised" equivalent to "`F n` has a primitive prime divisor", and
`fibEntry_not_exceptional` shows `{1,2,6,12}` are *not* realised. **The key insight is** that
Carmichael's theorem upgrades this to a sharp threshold: the non-realised ranks are exactly
`{1,2,6,12}`, so the realised-rank set is cofinite — a `density → 1` phase transition, the
number-theoretic analogue of a satisfiability threshold. **Why now?** The equivalence
between the analytic statement (density of realised ranks) and the algebraic one (existence
of primitive divisors) is already a proved `iff` here; formalising cofiniteness reduces to
`{1,2,6,12}ᶜ ⊆ realised`, i.e. to Carmichael's primitive-divisor theorem, whose composite
tail the catalog is independently attacking. The two efforts now share one interface,
`prime_primitive_iff`.

## Direction 4 — Strong-divisibility abstraction: `seqEntry` for general Lucas sequences

Every theorem in the file used only two facts about `F`: `gcd(F m, F n) = F (gcd m n)` and
`m ∣ n → F m ∣ F n`. **The key insight is** that the existence proof, the law of apparition,
and the primitive characterisation are theorems about *any* strong-divisibility sequence
`u : ℕ → ℕ` with `u 0 = 0` and `gcd(u m, u n) = u (gcd m n)` — Lucas sequences `U_n(P,Q)`,
Mersenne-type `aⁿ − 1`, and resultant sequences alike. Abstracting `fibEntry` to
`seqEntry u` behind a `StrongDivisibilitySeq` typeclass would subsume the Fibonacci,
Mersenne, and cyclotomic primitive-divisor theories under one roof. **Why now?** The
Fibonacci development is the minimal working prototype, and the `fibStep`/`orderOf`
existence argument already only uses the recurrence abstractly; the refactor is structural,
carries no new mathematical risk, and bridges the catalog's number-theory and
tropical/valuation domains (apparition is a discrete valuation on the index lattice).

## Direction 5 — Beyond 100: a uniform Wall–Sun–Sun reduction

`no_wallSunSun_prime_below_hundred` is a finite check; the conjecture asks for *all* primes.
**The key insight is** that combining Direction 1's bound `fibEntry p ≤ p + 1` with
Direction 2's valuation dichotomy reduces "no Wall–Sun–Sun prime `< N`" for *any* `N` to a
single decidable predicate `¬ p² ∣ F_{fibEntry p}` evaluated on a computable entry function
proved equal to `fibEntry`. **Why now?** The decidable reformulation pattern is already
demonstrated in this file; the only missing ingredient is a *computable* `fibEntryC` with a
proof `fibEntryC p = fibEntry p` (provable once `fibEntry p ≤ p + 1` is a theorem, giving a
finite search window). That single bridge lemma would let the bound `100` be replaced by an
arbitrary parameter and the whole search be regenerated mechanically.
