# Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which proves two new
`sorry`-free theorems on top of the catalog's entry-point theory
(`FibonacciApparition.fibEntry`, the law of apparition `fib_dvd_iff_fibEntry_dvd`, and the
binary multiplicativity `fibEntry_mul_coprime`):

* **`fibEntry_prod_coprime`** — finite multiplicativity: for a pairwise-coprime family of
  positive moduli, `fibEntry (∏ i, f i) = lcm_i (fibEntry (f i))`.
* **`fibEntry_eq_lcm_factorization`** — the prime-power reduction: for `n > 0`,
  `fibEntry n = lcm over p^vₚ(n) of fibEntry (p ^ vₚ(n))`.

Together these show that the entire (otherwise `Nat.find`-opaque) rank-of-apparition function
is *determined by its values on prime powers*. The directions below all exploit this
localization. Each is testable: it either reduces to a finite computation, or is a precise
divisibility/equality statement that a future cycle can attack as a fresh Lean target.

## Direction 1 — The prime-power tower and Wall's question

Conjecture: for every prime `p` and every `k ≥ 1`, `fibEntry (p^(k+1)) ∈ {fibEntry (p^k),
p · fibEntry (p^k)}`, and the "stay" case `fibEntry (p^(k+1)) = fibEntry (p^k)` happens for at
most one threshold `k = e_p` (the Wall exponent), after which the tower grows by exactly a
factor of `p` at each step. The falsifiable Lean target is the divisibility
`fibEntry (p^(k+1)) ∣ p · fibEntry (p^k)` together with `fibEntry (p^k) ∣ fibEntry (p^(k+1))`
(the second is already an instance of the proved `fibEntry_dvd_of_dvd`).

The key insight is that the reduction theorem `fibEntry_eq_lcm_factorization` makes prime
powers the *only* unknown in the whole theory, so the long-standing Wall–Sun–Sun question
("is `fibEntry (p^2) = fibEntry p` ever?") is exactly the `k = 1` boundary case of this tower
and nothing else needs to be understood globally.

Why now? We have a clean, machine-checked statement that fibEntry factors through prime
powers; the missing ingredient is a single lifting-the-exponent lemma
(`p^j ∣ F n → p^(j+1) ∣ F (p·n)`), which is a self-contained, provable Lean lemma rather than
a global conjecture.

## Direction 2 — Pisano period versus rank of apparition

Conjecture: for `m > 0`, the Pisano period `π(m)` (the period of `F mod m`) is an integer
multiple of `fibEntry m`, with quotient `π(m) / fibEntry m ∈ {1, 2, 4}`; moreover the quotient
is multiplicative-compatible with `fibEntry_prod_coprime` on coprime moduli (so the period also
localizes to prime powers).

The key insight is that `F(fibEntry m) ≡ 0` forces the pair `(F(fibEntry m), F(fibEntry m + 1))`
to be `(0, u)` for a unit `u` of multiplicative order `1`, `2`, or `4` in `(ℤ/m)ˣ`, and that
order is precisely the period-to-rank quotient.

Why now? The period side already exists implicitly in
`Catalog/Speculative/AutoResearch/FibonacciApparition.lean` (the `fibPair` dynamical system and
its pigeonhole periodicity), so the quotient bound can be phrased and proved with the same
`ZMod m × ZMod m` machinery already in the catalog.

## Direction 3 — Abstract reduction for strong divisibility sequences

Conjecture: the reduction theorem is not special to Fibonacci. For *any* strong divisibility
sequence `u` (one with `gcd (u m) (u n) = u (gcd m n)`) in which every modulus appears, the
abstract entry point `StrongDivSeq.entry u` satisfies both finite multiplicativity on coprime
moduli and `entry u n = lcm over p^vₚ(n) of entry u (p^vₚ(n))`. Instantiating at
`u n = a^n - 1` recovers the classical fact that the multiplicative order `ord_m(a)` is the lcm
of the orders modulo prime powers.

The key insight is that the only Fibonacci-specific fact used in this cycle's proofs is the
law of apparition, which `Catalog/Novelty/FibonacciEntryPointInvariant.lean` already proves
abstractly from `gcd (u m) (u n) = u (gcd m n)` alone — so the reduction lifts verbatim once a
"totality" hypothesis (every modulus appears) is added.

Why now? `StrongDivSeq.entry`, `entry_dvd`, and `primitive_divisor_inj` are already in the
catalog; abstracting the two new theorems is a mechanical generalization that immediately pays
off in two concrete models (Fibonacci and base-`a` Mersenne/repunit).

## Direction 4 — Carmichael / Zsygmondy via the reduction

Conjecture: an index `n` carries a *primitive* prime divisor of `F n` exactly when some prime
power `p^vₚ(n)` in its factorization has `fibEntry (p^vₚ(n)) = n`; equivalently, the set of
"defective" indices (no primitive divisor) is finite and computable. The reduction theorem
turns the global Carmichael statement (`Catalog/Shared/CarmichaelProof.lean`) into a per-prime-
power appearance test.

The key insight is that `fibEntry` pins the first appearance of a modulus, and the lcm formula
shows `n` is a first appearance of *some* modulus iff `n` is the lcm of the prime-power ranks
beneath it — collapsing primitivity to a finite divisor-comparison at each `n`.

Why now? The composite Carmichael case in `CarmichaelProof.lean` still carries one `sorry`
(the infinite tail beyond the `native_decide` range); re-expressing that tail through
`fibEntry_eq_lcm_factorization` may replace the brute-force bound with a structural argument.

## Direction 5 — Average order of the rank of apparition

Conjecture: the summatory function `∑_{m ≤ x} fibEntry m` grows like `C · x^2` for an explicit
constant `C`, and the reduction theorem gives `C` as an Euler product over primes of the
prime-power contributions `fibEntry (p^k)`.

The key insight is that multiplicativity (`fibEntry_prod_coprime`) plus the lcm-over-prime-powers
formula expresses any Dirichlet-series / averaging statement about `fibEntry` as a product over
primes, exactly as for classical multiplicative functions.

Why now? With the prime-power reduction proved, the analytic-number-theory toolkit
(`ArithmeticFunction`, Euler products) in Mathlib becomes directly applicable to `fibEntry`,
which previously had no multiplicative handle.
