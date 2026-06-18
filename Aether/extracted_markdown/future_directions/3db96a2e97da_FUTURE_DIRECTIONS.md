# Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle stopped treating the rank of apparition `fibRank` as an ad-hoc arithmetic
gadget and started treating it as **one half of a Galois adjunction** `fibRank ⊣ fib`
between the divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n` — is
exactly the adjunction inequality, and once it is read this way the structural theorems
become formal consequences of the adjunction rather than separate computations.

Everything is formalized sorry-free in
`Catalog/Applications/FibonacciRankDuality.lean` (self-contained against Mathlib, building
on the spine restated from `Catalog/Applications/RankOfApparition.lean`):

* **The adjunction itself, hypothesis-free.** `fibRank_dvd_iff'` proves
  `fibRank m ∣ n ↔ m ∣ F n` for *every* `m`, dropping the `HasFibRank m` side condition
  that the catalog spine `RankOfApparition.fibRank_dvd_iff` still carried. The `m = 0`
  corner is made to work by the alignment `fibRank 0 = 0`, `F 0 = 0`, `0 ∣ x ↔ x = 0`.
* **A left adjoint preserves joins.** `fibRank_lcm` proves the exact lcm-homomorphism
  `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`, and `fibRank_finset_lcm` lifts it to
  arbitrary finite joins. Both fall out of the adjunction through `lcm_dvd_iff` plus the
  divisibility-extensionality lemma `dvd_ext`.
* **Meets only sub-preserved.** `fibRank_mono` (monotonicity for divisibility) and
  `fibRank_gcd_dvd` (`fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)`) show the meet law
  degrades to a divisibility — the categorical signature of a functor that preserves
  colimits but not limits.
* **Representation payoff.** `fibRank_prime_index_has_primitive` recovers Carmichael's
  prime-index case for every prime `p ≥ 3` purely from the adjunction: a prime divisor of
  `F p` has rank dividing the prime `p`, the rank is not `1`, hence it equals `p`.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (monotone + meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_prime_index_has_primitive` (prime-index Carmichael) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single open analytic gap in the broader program remains the **composite asymptotic
tail** `fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`).

---

## Direction 1 — Close the composite tail through the cyclotomic value `Φ_n`

State and prove, for composite `n > 12`, that the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (F d) ^ μ(n/d)` is a positive integer satisfying `∏_{d ∣ n} Φ_d = F n`,
that every prime dividing `Φ_n` whose rank is a *proper* divisor of `n` equals the largest
prime factor `P` of `n` and divides `Φ_n` to first power (a lifting-the-exponent corollary),
and finally that `Φ_n > n`. A primitive prime divisor then exists.

The key insight is that the existence question collapses to a single scalar inequality
`Φ_n > n`: writing the primitive part as `F_n / N` with `N = (F_n/Φ_n)·N₂` and `N₂ ∣ n`
shows the primitive part exceeds `1` precisely when `Φ_n` outgrows `n`, so all the number
theory concentrates in one golden-ratio size bound `Φ_n ≍ α^{φ(n)}`.

Why now? The adjunction `fibRank_dvd_iff'` is exactly the tool that pins down *which* primes
can divide `Φ_n` (their rank must divide `n`), so the Möbius bookkeeping now has a clean
order-theoretic backbone; the remaining work is one `φ(n) ≥ c√n` estimate rather than a
from-scratch theory.

## Direction 2 — The adjunction is sharp: classify when `fibRank` preserves meets

Conjecture: `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)` holds **iff** the ranks
`fibRank a` and `fibRank b` are "rank-coprime in apparition", and it fails for the first
time at an explicit small pair; only the divisibility `fibRank_gcd_dvd` survives in general.

The key insight is that a left adjoint preserves joins but generally not meets, so the gcd
law must degrade exactly where the apparition lattice fails to be distributive over the
prime-power decomposition — a defect that should be measurable and pinned to concrete
witnesses.

Why now? `fibRank_lcm` and `fibRank_gcd_dvd` are both in hand, so the equality question is a
finite `decide` search away from a least counterexample and a clean characterization; the
falsifiable form ("find the least failing `(a,b)`") makes it immediately testable.

## Direction 3 — Lift the adjunction to every strong divisibility sequence

Generalize `fibRank_dvd_iff'` and `fibRank_lcm` from `Nat.fib` to an arbitrary strong
divisibility sequence `u` (the `IsStrongDivSeq` setting already in
`Catalog/Applications/UnifiedRankOfApparition.lean` and
`Catalog/Applications/StrongDivisibilitySequences.lean`): prove `rank u ⊣ u` and that
`rank u` is an lcm-homomorphism.

The key insight is that nothing in the join law used Fibonacci-specific identities — only
the meet law `u (gcd m n) = gcd (u m) (u n)` and the minimality of the rank — so the entire
adjunction is a theorem about strong divisibility sequences, with Fibonacci, Lucas, Mersenne
`2^n − 1`, and `q^n − 1` all instances of one engine.

Why now? The `rank u` machinery is already proved sorry-free in the unified file, so the
generalization is a re-derivation of this cycle's two headline theorems one abstraction
level up, with `dvd_ext` and `lcm_dvd_iff` reused verbatim.

## Direction 4 — A Stone-style duality between indices and apparition supports

Define the apparition support `Supp(n) = { p prime | p ∣ F n }` and its adjoint
`S ↦ ⋂_{p ∈ S} (multiples of fibRank p)`, and prove they form a Galois connection whose
closed indices are exactly the divisor-closed sets of multiples and whose closed supports
are exactly the "rank-saturated" prime sets; primitive divisors are the points where the
support strictly grows.

The key insight is that Carmichael's theorem is precisely the statement that this Galois
connection is *non-degenerate* for `n ∉ {1,2,6,12}` — primitivity becomes the order-theoretic
assertion `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`, turning an analytic divisor question into a
closure/duality statement.

Why now? With `fibRank_dvd_iff'` giving `p ∣ F n ↔ fibRank p ∣ n`, the support functor is
already definable and computable, so the connection's unit/counit laws reduce directly to the
lcm/gcd homomorphism results proved this cycle (`fibRank_lcm`, `fibRank_gcd_dvd`).
