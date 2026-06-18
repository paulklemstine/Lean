# Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

## Synthesis

This cycle consolidated the *rank of apparition* (the Fibonacci entry point) into a single,
self-contained, fully-proved foundation in `Catalog/Applications/RankOfApparition.lean`, and used
it to prove results that the catalog's many parallel apparition threads were all missing.

The catalog had accumulated several overlapping developments of the same object — the existence
proof and biconditional in `Catalog/Novelty/FibApparitionExistence.lean`
(`apparitionRank`, `fib_apparition_exists`, `fib_dvd_iff_apparitionRank_dvd`); the entry-point
calculus of `Catalog/Applications/FibonacciEntryPoints.lean` (`entryPoint`,
`primitive_iff_entry_eq`); the lattice laws of `Catalog/Applications/FibonacciApparitionLattice.lean`
(`fibEntry_lcm`, `fibEntry_monotone`, `fibEntry_gcd_dvd`); the primitivity calculus of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` (`dvd_fib_iff_index_dvd_of_primitive`,
`simultaneous_apparition`); the abstract `Catalog/Applications/StrongDivisibilitySequences.lean`
(`IsStrongDivSeq`, `dvd_iff_index_dvd_of_primitive`, `apparition_count`); and the analytic
Carmichael program in `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`
(`fib_prime_has_primitive`, restricted to primes `p ≥ 5`). Every one of these secretly turns on
the same fact: `{ n | m ∣ F n }` is exactly the set of multiples of one number, `fibRank m`.

The conceptual move was to make that biconditional, `fibRank_dvd_iff`, primitivity-free and then
read everything off it. With the spine in hand, the genuinely new facts of this cycle — that the
rank pins Fibonacci values *exactly* (`fibRank_fib`), that this upgrades Mathlib's one-way
`Nat.fib_dvd` to a full biconditional (`fib_dvd_fib_iff`), and that Carmichael's prime case holds
for *all* primes `p ≥ 3` (`fib_prime_index_has_primitive`) — each fall out in a few lines.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, 0 sorry; axioms = propext / Classical.choice / Quot.sound)

- **`hasFibRank_of_pos`** — every positive modulus has a rank of apparition. The pair sequence
  `n ↦ (F n, F (n+1)) mod m` lives in the finite set `(ZMod m)²`, and the Fibonacci shift is a
  permutation (unit-determinant), so a repeated pair back-steps to a zero of `F mod m`.
- **`fibRank_dvd_iff`** *(the spine)* — `m ∣ F n ↔ fibRank m ∣ n`, with **no primitivity
  hypothesis**, generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`.
- **`fibRank_dvd_of_dvd`** — the order-morphism law packaged with existence:
  `b ∣ a → 0 < a → fibRank b ∣ fibRank a`.
- **`fibRank_fib`** *(new)* — `fibRank (F k) = k` for `k ≥ 3`. The rank pins the Fibonacci
  values exactly; this appears nowhere in the catalog or in Mathlib.
- **`fib_dvd_fib_iff`** *(new corollary)* — `F a ∣ F b ↔ a ∣ b` for `a ≥ 3`. Mathlib provides
  only the forward direction (`Nat.fib_dvd`); the biconditional was absent (`exact?` fails).
- **`fib_prime_index_has_primitive`** — Carmichael's prime case for **every** prime `p ≥ 3`
  (the catalog's `fib_prime_has_primitive` needs `p ≥ 5`): the chosen prime divisor of `F p` has
  rank exactly `p`, so it cannot divide any earlier `F k`.

## Research Directions

### 1. A primitivity-free Carmichael composite case via a primitive-part lower bound

The catalog's composite case is a `native_decide` check up to `n ≤ 50000`
(`FibPrimitive.fib_primitive_le_50000`) plus an analytic tail. The spine reframes the problem:
`F n` has a primitive divisor iff its "primitive part" `Π(n) := F n / ∏_{d ∣ n, d < n} F d^{…}`
exceeds `1`, which is governed by the cyclotomic value `Φ_n(φ, ψ)`. **The key insight is** that
the non-primitive part of `F n` is supported on at most the single prime dividing `n / fibRank`,
so a uniform lower bound `|Φ_n(φ, ψ)| > n` — provable from `φ^{totient n}` growth — forces a
primitive divisor for *all* large `n` at once, eliminating the numeric cutoff. **Why now?** The
spine `fibRank_dvd_iff` together with `fibRank_dvd_of_dvd` already supplies the exact
divisor-lattice bookkeeping the cyclotomic argument needs; the only missing ingredient is the
totient growth bound, which Mathlib supports (`Nat.totient`, `Nat.totient_lt`, real-power estimates).

### 2. `fibRank` as an exact join-morphism, transported to the new spine

`Catalog/Applications/FibonacciApparitionLattice.lean` already proves the unrestricted join law
`fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)` and the strictness of the meet bound for
the *old* `fibEntry`. Conjecture the same laws hold verbatim for the primitivity-free `fibRank`,
and combine with `fibRank_fib` to compute `fibRank` on any `lcm` of Fibonacci numbers in closed
form. **The key insight is** that `fibRank_dvd_iff` makes `lcm a b ∣ F n` equivalent to the
system `fibRank a ∣ n ∧ fibRank b ∣ n`, whose least solution is `lcm (fibRank a) (fibRank b)` —
so the join law is a one-line consequence of the spine plus `Nat.lcm_dvd_iff`, with no case
analysis. **Why now?** Re-deriving the lattice laws on the `fibRank` spine merges the catalog's
two parallel rank objects (`fibEntry`, `apparitionRank`/`fibRank`) into one, and `fibRank_fib`
turns the abstract laws into concrete evaluations.

### 3. Prime-power ranks and a Lifting-the-Exponent law for `fibRank`

Reduce rank computation to prime powers: conjecture `fibRank (p^(e+1)) = p · fibRank (p^e)` for
`e ≥ E₀(p)` (a Wall–Sun–Sun threshold), with exceptional behaviour at the base. **The key insight
is** that `v_p(F (fibRank p · t))` increases by exactly one each time `t` gains a factor of `p` —
the Fibonacci instance of Lifting-the-Exponent — and the catalog already hosts an LTE-for-Fibonacci
file (`Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`) to plug in. **Why
now?** With `fibRank_fib` giving exact apparition indices and the spine decoupling the combinatorics
from the analytic estimates, the `v_p` recursion becomes a statement purely about `fibRank`, making
it a tractable next target.

### 4. Transport the entire spine to all strong divisibility sequences

`Catalog/Applications/StrongDivisibilitySequences.lean` abstracts the gcd law as `IsStrongDivSeq`.
Conjecture that for **any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every modulus dividing some
`u k` has a rank `rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`, and that `rank_u (u k) = k` whenever
`u` is eventually strictly monotone. **The key insight is** that the proof of `fibRank_dvd_iff` and
`fibRank_fib` used only the strong-divisibility law and strict monotonicity — never anything
Fibonacci-specific — so the whole spine is sequence-agnostic. **Why now?** The catalog already
proves `mersenne_isStrongDivSeq` and `fib_isStrongDivSeq`; abstracting the spine immediately yields
Bang–Zsygmondy entry-point theory for `aⁿ − 1` and Lucas sequences for free, a genuine cross-domain
unification of the number-theory files.

### 5. Exact arithmetic-progression density of apparition indices

For fixed `m`, `fibRank_dvd_iff` makes `{ n ≤ N | m ∣ F n }` a literal arithmetic progression of
step `fibRank m`, so its count is exactly `⌊N / fibRank m⌋` and its natural density is `1 / fibRank m`
(the finite version is `StrongDivSeq.apparition_count`). Conjecture the coprime refinement: the joint
apparition density of coprime `m₁, m₂` is `1 / lcm (fibRank m₁) (fibRank m₂)`, and that averaging
`1 / fibRank p` over primes `p` connects to the Fibonacci analogue of Artin's constant. **The key
insight is** that the spine makes the apparition set an *exact* progression (not merely asymptotic),
so densities multiply across coprime moduli with no error term. **Why now?** The exact-progression
structure is already proved; only the (independent) prime-averaging heuristic remains, making the
conditional density statements fully falsifiable against computed `fibRank` tables.
