# Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

## Synthesis

This cycle isolated the *rank of apparition* (the Fibonacci entry point) as the genuine
load-bearing object of the catalog's Carmichael / primitive-divisor program, and gave it a
clean, fully-proved, self-contained foundation in `Catalog/Applications/RankOfApparition.lean`.

The catalog had accumulated several parallel threads — `FibonacciPrimitiveDivisors`
(`dvd_fib_iff_index_dvd_of_primitive`), the abstract `StrongDivisibilitySequences`
(`IsStrongDivSeq`, `fib_isStrongDivSeq`), `FibonacciApparitionLattice`, and the Carmichael
program in `Shared.CarmichaelProof` / `Speculative.CarmichaelPrimitiveDivisor` — each of which
secretly turns on the *same* fact: the set `{ n | m ∣ F n }` is exactly the set of multiples
of one number. We named that number `fibRank m` and proved the biconditional that makes it the
spine of everything else.

The key conceptual move was to drop the hypothesis of *primitivity*. The catalog's pinning
lemma `dvd_fib_iff_index_dvd_of_primitive` assumes `p` is already a primitive divisor; our
`fibRank_dvd_iff` holds for **every** modulus `m` with a rank, and primitivity reappears as the
boundary special case `fibRank m = n`. With that single biconditional in hand, Carmichael's
prime case, the order-morphism structure of `fibRank`, and the exact evaluation
`fibRank (F k) = k` all fall out cheaply.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, 0 sorry, axioms = propext/Classical.choice/Quot.sound)

- **`hasFibRank_of_pos`** — every positive modulus has a rank of apparition. Apparition always
  occurs: the pair sequence `n ↦ (F n, F (n+1)) mod m` lives in the finite set `(ZMod m)²`, and
  the Fibonacci shift is reversible, so a repeated pair is back-stepped to a zero of `F mod m`.
- **`fibRank_dvd_iff`** *(the spine)* — `m ∣ F n ↔ fibRank m ∣ n`. The `←` direction is pure
  `Nat.fib_dvd`; the `→` direction pushes `m` into `F (gcd (fibRank m) n)` via `Nat.fib_gcd` and
  closes by minimality of the rank. This generalizes `dvd_fib_iff_index_dvd_of_primitive` by
  removing the primitivity hypothesis entirely.
- **`fibRank_dvd_of_dvd`** — `fibRank` is an order morphism `(ℕ, ∣) → (ℕ, ∣)`: `b ∣ a` implies
  `b` has a rank and `fibRank b ∣ fibRank a`.
- **`fibRank_fib`** — `fibRank (F k) = k` for `k ≥ 3`; the rank pins the Fibonacci values
  exactly, with strict monotonicity ruling out earlier apparition.
- **`fib_prime_index_has_primitive`** — Carmichael's prime case, derived in a few lines from the
  spine: for prime `p ≥ 3`, `F p` has a primitive prime divisor (its rank equals `p`, forced
  because the rank divides the prime `p` and cannot be `1`).

Together with the existing computational composite case, these close the *prime* half of the
Carmichael program on a primitivity-free footing and supply reusable infrastructure for the
composite half.

## Research Directions

### 1. A primitivity-free Carmichael composite case via a primitive-part lower bound

The catalog's composite case is currently a `native_decide` check up to `n ≤ 10000` plus an
unfilled tail for `n > 10000`. The spine reframes the problem: `F n` has a primitive divisor iff
the "primitive part" `Π(n) := F n / ∏_{d | n, d < n, fibRank-compatible} (...)` exceeds `1`,
which is governed by the cyclotomic value `Φ_n(φ, ψ)`. **The key insight is** that the
non-primitive part of `F n` is supported on at most the single prime dividing `n / fibRank`,
so a lower bound `|Φ_n(φ, ψ)| > n` (provable from `φ^{totient n}` growth) forces a primitive
divisor for all large `n` *uniformly*, eliminating the `10000` cutoff. **Why now?** The
spine `fibRank_dvd_iff` plus `fibRank_dvd_of_dvd` already give the exact divisor-lattice
bookkeeping the cyclotomic argument needs; the only missing analytic ingredient is the totient
growth bound, which Mathlib supports (`Nat.totient`, `Nat.totient_lt`, real-power estimates).

### 2. The rank is multiplicative-by-lcm: `fibRank (a*b) = lcm` under coprimality

`fibRank_dvd_of_dvd` shows `fibRank` respects divisibility; conjecture the sharper
`fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` and, for coprime `a, b`,
`fibRank (a*b) = lcm (fibRank a) (fibRank b)`. **The key insight is** that
`m ∣ F n ↔ fibRank m ∣ n` turns `lcm a b ∣ F n` into the simultaneous system
`fibRank a ∣ n ∧ fibRank b ∣ n`, whose least solution is `lcm (fibRank a) (fibRank b)` — exactly
the `FibonacciApparitionLattice` join law, now provable without case analysis. **Why now?** This
is the missing bridge that upgrades the catalog's `FibonacciApparitionLattice` join bound (proved
only as a divisibility, with strictness examples) into an equality on the coprime sublattice, and
reduces all rank computation to prime-power moduli.

### 3. Prime-power ranks and a Lifting-the-Exponent law for `fibRank`

Building on Direction 2, reduce to prime powers: conjecture `fibRank (p^(e+1)) = p · fibRank(p^e)`
for `e ≥ E_0(p)` (a Wall–Sun–Sun threshold), with the exceptional "Wall–Sun–Sun" behavior at the
base. **The key insight is** that `v_p(F (fibRank p · t))` grows by exactly one each time `t`
gains a factor of `p`, the Fibonacci instance of Lifting-the-Exponent — and the catalog already
hosts an LTE-for-Fibonacci file
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`)
to plug in. **Why now?** With `fibRank_fib` and the spine giving exact apparition indices, the
`v_p` recursion becomes a statement purely about `fibRank`, decoupled from the analytic estimates,
making it a tractable next target.

### 4. Transport the spine to all strong divisibility sequences (Lucas, Mersenne, ...)

`StrongDivisibilitySequences.IsStrongDivSeq` already abstracts the gcd law; conjecture that for
**any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every modulus dividing some `u k` has a rank
`rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`. **The key insight is** that the entire proof of
`fibRank_dvd_iff` used only `Nat.fib_gcd` and `Nat.fib_dvd`, both of which are *exactly* the
`IsStrongDivSeq` hypotheses — so the spine is not about Fibonacci at all. **Why now?** The catalog
proves `mersenne_isStrongDivSeq` and `fib_isStrongDivSeq`; abstracting the spine instantly yields
Carmichael/Bang–Zsygmondy entry-point theory for `a^n - 1` and Lucas sequences for free, a genuine
cross-domain unification of the number-theory files.

### 5. Density and equidistribution of apparition indices

For fixed `m`, the apparition set `{ n ≤ N | m ∣ F n }` has size `⌊N / fibRank m⌋`, so its natural
density is `1 / fibRank m` (the catalog's `apparition_count` is the finite version). Conjecture the
two-modulus refinement: the joint apparition density of coprime `m₁, m₂` is
`1 / lcm (fibRank m₁) (fibRank m₂)`, and that averaging `1/fibRank p` over primes `p` connects to
the Fibonacci analogue of Artin's constant. **The key insight is** that `fibRank_dvd_iff` makes the
apparition set a literal arithmetic progression, so density is exact (not asymptotic) and stacks
multiplicatively across coprime moduli. **Why now?** The exact-progression structure is already
proved here; only the (independent) prime-averaging heuristic remains, making the conditional
density statements fully falsifiable by computation against `fibRank` tables.
