# Future Directions — Primitive Fibonacci Primes and the Carmichael Bridge

## Synthesis of this cycle

This cycle attacked the catalog's standing gap in **Carmichael's primitive–divisor
theorem for the Fibonacci sequence**. The catalog already contains a clean, *sorry-free*
proof of the **prime-index half** (`fib_primitive_divisor_prime` in
`Speculative.AutoResearch.CarmichaelHelper`), built on the entry-point identity
`Nat.fib_gcd`. The **composite tail** (`fib_carmichael_composite` in
`Shared.CarmichaelProof`, used by `Speculative.AutoResearch.CarmichaelComposite`) remains
open: the `n ≤ 10000` range is dispatched by `native_decide` on the coprime-part
construction, but the infinite tail `n > 10000` still carries a `sorry`, because closing it
requires a genuine lower bound `Φ_n > P(n)` on the homogeneous-cyclotomic ("primitive")
part — machinery absent from Mathlib (no Zsigmondy/Carmichael primitive-divisor theorem).

Rather than gamble the whole cycle on that single deep estimate, we extracted the maximum
*unconditional* structural mileage from the already-proven prime case, and packaged it as
new theory in `Catalog/Speculative/AutoResearch/FibPrimitivePrimes.lean`.

## Results summary (`FibPrimitivePrimes.lean`, `sorry = 0`)

- `fib_primitive_index_unique` — a number is a primitive divisor of **at most one**
  Fibonacci number; the index is an invariant of the prime (its entry point).
- `infinite_fib_primitive_primes` — the set of primes occurring as primitive divisors of
  `F_p` for prime `p ≥ 13` is **infinite** (a Fibonacci-flavoured Euclid theorem, proved
  using only the sorry-free prime case).
- `infinite_primes_with_prime_fib_entry` — there are **infinitely many primes whose
  Fibonacci entry point (rank of apparition) is itself prime**.
- Supporting, reusable: `exists_prime_isPrimitive`, `primeIndices_infinite`,
  `entryPoint_eq_of_primitive`.

All three main theorems depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Close the infinite tail via a homogeneous-cyclotomic lower bound

Build the integer "primitive part" `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}` and prove the Carmichael
estimate `Φ_n > rad(n)` (in fact `Φ_n ≥ φ^{euler_totient(n)} / n` is far more than enough)
for all `n > 10000`, then identify the unique possible non-primitive prime divisor of `Φ_n`
as the largest prime factor `P(n)` with valuation exactly 1. This discharges
`fib_carmichael_composite` and, with the existing prime case, finishes Carmichael's theorem
for Fibonacci with `sorry = 0`.

The key insight is that the *proper-divisor contributions do not merely bound but exactly
cancel* through Möbius inversion: a crude `lcm`/product bound fails on abundant `n` (where
`σ(n) − n` exceeds `n`), but `∑_{d∣n} μ(n/d)·d = euler_totient(n)` makes `log Φ_n ≈
euler_totient(n)·log φ`, which dominates `log n` once `n` is large because
`euler_totient(n) ≫ log n`. Why now? The catalog already supplies the entry-point/LTE
scaffolding (`FibonacciEntryPoints`, the Tropical/p-adic LTE-for-Fibonacci file) and the
`native_decide`-verified finite base case, so only the asymptotic estimate is missing — a
self-contained analytic lemma rather than new structural theory.

## Direction 2 — A Zsigmondy theorem for general Lucas sequences in the catalog

Generalize `fib_primitive_divisor_prime` and `fib_primitive_index_unique` from `Nat.fib`
to an arbitrary strong divisibility sequence `u` with `gcd(u m, u n) = u (gcd m n)` (the
hypothesis already abstracted in `Novelty.FibonacciEntryPointInvariant`), recovering
Mersenne numbers `2^n − 1` and Lucas sequences `U_n(P,Q)` as instances.

The key insight is that **every theorem in `FibPrimitivePrimes.lean` used only the
gcd-compatibility `Nat.fib_gcd` and never any Fibonacci-specific arithmetic**, so the entire
uniqueness-and-infinitude package is really a theorem about strong divisibility sequences.
Why now? `Novelty.FibonacciEntryPointInvariant` already states the gcd hypothesis as an
explicit parameter `Hgcd` and proves `primitive_divisor_inj` at that generality — bridging
it to the infinitude statements is a short, high-leverage synthesis that unifies the
Fibonacci, Mersenne, and Lucas entries of the catalog under one roof.

## Direction 3 — Density and congruence structure of Fibonacci entry points

Quantify `infinite_primes_with_prime_fib_entry`: prove that for a prime `q ∤ 10`, the entry
point `entryPoint q` divides `q − (5 ∣ q)` (the Legendre symbol shift), hence
`entryPoint q ≤ q + 1`, and use this to give an *explicit* lower bound on the counting
function `#{q ≤ x : entryPoint q prime}`.

The key insight is that the entry point is governed by the splitting of `q` in `ℤ[φ]`: the
rank of apparition divides `q − 1` when `5` is a QR mod `q` and `q + 1` otherwise, turning a
purely existential infinitude statement into a sieve-theoretic counting problem. Why now?
The catalog's `FibApparitionExistence` already realizes the entry point as the order of the
Fibonacci `ZMod` automorphism `fibStep`, which is exactly the algebraic object whose order
the quadratic-reciprocity bound controls — the dynamical and number-theoretic descriptions
of `entryPoint` are both already formalized and ready to be fused.

## Direction 4 — The exceptional set is exactly `{1, 2, 6, 12}`

Combine the finished prime case, the (to-be-closed, Direction 1) composite case, and the
catalog's `fib_twelve_no_primitive` to prove the sharp statement: `F_n` has a primitive
prime divisor **iff** `n ∉ {1, 2, 6, 12}`. This requires the matching *non-existence*
direction for `n ∈ {1,2,6,12}` (only `n = 6, 12` are nontrivial).

The key insight is that primitivity fails exactly when `Φ_n ∈ {1, P(n)}`, and the four
exceptions are precisely the small `n` where the cyclotomic value is too small to clear its
intrinsic factor — a finite, `decide`-checkable obstruction once the general bound of
Direction 1 rules out all larger `n`. Why now? Three of the four exceptional cases are
already mechanically checkable and one (`n = 12`) is *already proved* in
`FibonacciEntryPoints.fib_twelve_no_primitive`; the sharp characterization is then one
finite case-split away from the general theorem.

## Direction 5 — Primitive divisors as a source of effective prime production

Turn `infinite_fib_primitive_primes` into an *effective* statement: exhibit a strictly
increasing computable function `g` such that for every `k`, the interval `(k, g k]` contains
a prime arising as a primitive Fibonacci divisor, giving a constructive (if slow) prime
generator with provable coverage.

The key insight is that the injection `n ↦ (primitive divisor of F_n)` is **monotone in a
controllable way**: a primitive divisor of `F_n` is `≥` the smallest prime not dividing any
earlier `F_k`, and `F_n` grows like `φ^n`, so explicit gaps between successive primitive
primes can be bounded. Why now? The proof of `infinite_fib_primitive_primes` is already
constructive up to the `Classical.choose`; replacing the choice by `Nat.minFac` of the
catalog's `primPart`/`fibCoprimePart` (both computable, already in the catalog) makes the
generator literally executable and its coverage provable.
