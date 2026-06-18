# Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
gadget but as **one half of a Galois adjunction** `fibRank ⊣ fib` between the
divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n`
— is exactly the adjunction inequality, and once it is read this way the
structural theorems become formal consequences of the adjunction rather than
separate computations.

Two concrete payoffs were formalized (sorry-free) this cycle:

* The adjunction itself, with the `HasFibRank` hypothesis **removed**: the spine
  `fibRank m ∣ n ↔ m ∣ F n` holds for *every* `m` (`fibRank_dvd_iff'`).
* The representation consequence that a left adjoint preserves joins: `fibRank`
  is an exact **lcm-homomorphism** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
  (`fibRank_lcm`), lifting to arbitrary finite joins (`fibRank_finset_lcm`), while
  meets are preserved only up to divisibility (`fibRank_gcd_dvd`).

In parallel the long-standing structural gap that prevented the whole
Carmichael development from compiling — the missing prime-index case
`fib_primitive_divisor_prime` — was closed by the rank argument: for a prime
index every prime divisor of `F n` is automatically primitive.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fib_primitive_divisor_prime` (prime-index Carmichael) | `Catalog/Shared/CarmichaelHelper.lean` | proved, `sorry = 0` |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single remaining `sorry` in the program is the **composite asymptotic tail**
`fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`).

---

## Direction 1 — Close the composite tail through the cyclotomic value `Φ_n`

State and prove, for composite `n > 12`, that the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (F d) ^ μ(n/d)` is a positive integer satisfying
`∏_{d ∣ n} Φ_d = F n`, that every prime dividing `Φ_n` with rank a *proper*
divisor of `n` equals the largest prime factor `P` of `n` and divides `Φ_n` to
first power (an LTE corollary of the already-proven `fib_lte`), and finally that
`Φ_n > n`. Then a primitive prime divisor exists.

The key insight is that the existence question collapses to a single scalar
inequality `Φ_n > n`: the reduction `primitive part = F_n / N` with
`N = (F_n/Φ_n)·N₂` and `N₂ ∣ n` shows the primitive part is `> 1` precisely when
`Φ_n` outgrows `n`, so all the number theory is concentrated in one golden-ratio
size bound `Φ_n ≍ α^{φ(n)}`.

Why now? Every analytic ingredient already lives in the catalog sorry-free —
`fib_lte` (lifting the exponent), `fib_exponential_lower_bound`, and the full
entry-point/rank spine — so the remaining work is the Möbius bookkeeping plus one
`φ(n) ≥ c√n` estimate rather than a from-scratch theory.

## Direction 2 — The adjunction is sharp: classify when `fibRank` preserves meets

Conjecture: `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)` holds **iff**
`fibRank a` and `fibRank b` are "rank-coprime in apparition", and fails for the
first time at an explicit small pair; only the divisibility `fibRank_gcd_dvd`
survives in general.

The key insight is that a left adjoint preserves joins but generally not meets,
so the gcd law must degrade exactly where the apparition lattice is not
distributive over the prime-power decomposition — a defect that should be
measurable and pinned to concrete witnesses.

Why now? `fibRank_lcm` and `fibRank_gcd_dvd` are in hand, so the equality
question is a finite search away from a counterexample and a clean
characterization; the falsifiable form (find the least failing `(a,b)`) makes it
immediately testable by `decide`.

## Direction 3 — Lift the adjunction to every strong divisibility sequence

Generalize `fibRank_dvd_iff'` and `fibRank_lcm` from `Nat.fib` to an arbitrary
strong divisibility sequence `u` (the `IsStrongDivSeq` setting already in
`Catalog/Applications/UnifiedRankOfApparition.lean`): prove `rank u ⊣ u` and that
`rank u` is an lcm-homomorphism.

The key insight is that nothing in the join law used Fibonacci-specific identities
— only the meet law `u (gcd m n) = gcd (u m) (u n)` — so the entire adjunction is
a theorem about strong divisibility sequences, with Fibonacci, Lucas, Mersenne
`2^n - 1`, and `q^n - 1` as instances of one engine.

Why now? The `rank u` machinery (`rank_dvd_iff`, `rank_dvd_of_dvd`) is already
proved sorry-free, so the generalization is a re-derivation of this cycle's two
headline theorems one abstraction level up.

## Direction 4 — A Stone-style duality between indices and apparition supports

Define the apparition support functor `n ↦ Supp(n) = { p prime | p ∣ F n }` and
its adjoint `S ↦ ⋂_{p ∈ S} (multiples of fibRank p)`, and prove they form a
Galois connection whose closed indices are exactly the multiples and whose closed
supports are exactly the "rank-saturated" prime sets; primitive divisors are the
points where the support strictly grows.

The key insight is that Carmichael's theorem is precisely the statement that this
Galois connection is *non-degenerate* for `n ∉ {1,2,6,12}` — primitivity is the
order-theoretic assertion that `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`, turning an
analytic divisor question into a duality/closure statement.

Why now? With `fibRank_dvd_iff'` giving `p ∣ F n ↔ fibRank p ∣ n`, the support
functor is already definable and computable, so the connection's unit/counit
laws reduce to the lcm/gcd homomorphism results proved this cycle.
