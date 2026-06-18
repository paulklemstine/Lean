# Future Directions — Rank of Apparition of Fibonacci Numbers

This cycle built, from scratch and `sorry`-free, the arithmetic theory of the
**rank of apparition** (Fibonacci entry point) `fibRank m`, the least positive
`k` with `m ∣ F(k)`, in `Catalog/Shared/FibRankApparition.lean`. The central
result is the divisibility characterisation `m ∣ F(k) ↔ fibRank m ∣ k`
(for `m > 0`), which upgrades the catalog gcd identity
`gcd(F m, F n) = F (gcd m n)` (`fib_gcd_identity`) into a complete answer to
*when* `m` divides a Fibonacci number, together with the primitive-divisor
characterisation `IsPrimitivePrimeDivisor p n ↔ fibRank p = n` linking directly
to the catalog's Carmichael theorem (`fib_primitive_divisor_existence`).

The following conjectures extend this foundation. Each is testable and
falsifiable: each can be checked numerically against `Nat.fib` for thousands of
inputs before any proof attempt, and each is stated so that a single
counterexample would refute it.

## 1. Multiplicativity of the entry point on coprime factors

**Conjecture.** For positive coprime `a, b`, `fibRank (a * b) = Nat.lcm (fibRank a) (fibRank b)`.

The key insight is that `fib_dvd_iff_fibRank_dvd` turns the divisibility
`a*b ∣ F(k)` into the *conjunction* `fibRank a ∣ k ∧ fibRank b ∣ k` (because
`a` and `b` are coprime, so `a*b ∣ F k ↔ a ∣ F k ∧ b ∣ F k`), and the least `k`
satisfying both divisibilities is exactly their `lcm`. This reduces the entire
computation of `fibRank m` to the prime-power case.

Why now? The hard direction — converting joint divisibility into a single
`lcm` condition — is now a two-line consequence of the divisibility theorem
proved this cycle; before it, one had no handle on the minimal `k` at all.
Numerically verifiable instantly over all coprime `a,b ≤ 200`.

## 2. The Lucas–Legendre bound on prime entry points

**Conjecture.** For a prime `p ∉ {2, 5}`, `fibRank p ∣ (p - legendreSym p 5)`,
hence `fibRank p ≤ p + 1`; and `fibRank 5 = 5`, `fibRank 2 = 3`.

The key insight is that the catalog identity `fib_sq_mod_prime`
(`F(p)² ≡ 1 (mod p)` for `p ∉ {2,5}`) is the residue-class shadow of the
stronger statement `F(p - (5|p)) ≡ 0 (mod p)`; feeding that congruence into
`fib_dvd_iff_fibRank_dvd` immediately yields `fibRank p ∣ p - (5|p)`.

Why now? The quadratic-residue machinery for `5 mod p` already exists in the
catalog (it was needed for `fib_sq_mod_prime`), and the new entry-point theorem
is precisely the device that converts a divisibility `p ∣ F(N)` into a bound on
`fibRank p`. This is the missing multiplicative half of that earlier additive
result. Falsifiable by a single prime where `fibRank p > p + 1`.

## 3. Wall's prime-power law for entry points

**Conjecture.** For an odd prime `p` and `e ≥ 1`,
`fibRank (p ^ e) = p ^ (e - min e w) * fibRank p`, where `w` is the largest
exponent with `p ^ w ∣ F(fibRank p)` (the *Wall exponent* of `p`).

The key insight is a lifting-the-exponent principle for the Fibonacci sequence:
the `p`-adic valuation `v_p(F(k))` jumps by exactly `v_p(k / fibRank p)` once
`fibRank p ∣ k`, so the entry point of `p^e` is the entry point of `p` scaled by
the deficit between the target valuation `e` and the base valuation `w`.

Why now? With `fib_dvd_iff_fibRank_dvd` in hand, `fibRank (p^e)` is no longer a
mysterious minimum but `fibRank p` times "the least multiplier supplying `e`
factors of `p`", reducing a hard analytic question to a clean valuation
computation. (Whether `w = 1` for all `p`, i.e. the non-existence of
Wall–Sun–Sun primes, is the famous open input; the *conditional* law above is
provable outright.) Falsifiable per `(p,e)` by direct valuation check.

## 4. Closing the Carmichael composite tail via the primitive part

**Conjecture.** For every composite `n > 10000`, the primitive part of `F(n)`
exceeds `1`; equivalently there is a prime `p` with `fibRank p = n`, completing
the `sorry` in `Catalog/Shared/CarmichaelProof.lean`.

The key insight is that `isPrimitive_iff_fibRank_eq` recasts "F(n) has a
primitive prime divisor" as "some prime has entry point exactly `n`", and the
only obstruction is an *intrinsic* prime (one dividing `n` itself); a size
estimate `|Φ_n| ≈ φ^{φ(n)} > n` then forces a genuinely new prime once `φ(n)`
is large, which holds for all `n > 10000`.

Why now? The finite range `13 ≤ n ≤ 10000` is already discharged by
`native_decide`; the entry-point reformulation proved this cycle isolates
*exactly one* possible non-primitive prime, so the remaining work is a single
quantitative inequality `φ^{φ(n)} > n` rather than the full classical theory of
cyclotomic factors. Falsifiable instantly: a composite `n` with `primPart n = 1`
would refute it.

## 5. The Lucas-number entry point and a Fibonacci–Lucas bridge

**Conjecture.** Defining `lucasRank m` as the least positive `k` with
`m ∣ Lucas k`, the analogue `m ∣ Lucas k ↔ lucasRank m ∣ k` holds for `m > 0`,
and for odd `m` one has `fibRank m = lucasRank m` exactly when `fibRank m / 2`
is odd (equivalently when the entry point is `≡ 2 (mod 4)`).

The key insight is that `Lucas k = F(2k)/F(k)` ties the Lucas divisibility
lattice to the Fibonacci one already understood by `fib_dvd_iff_fibRank_dvd`,
so the Lucas entry point is governed by the *2-adic structure* of `fibRank m`
rather than by new arithmetic.

Why now? The Fibonacci entry-point theory is now complete and `sorry`-free, and
Lucas numbers are definable directly in terms of `Nat.fib`; the bridge therefore
transports a finished theory rather than rebuilding one, and the parity
criterion is a sharp, falsifiable prediction checkable over all odd `m ≤ 1000`.
