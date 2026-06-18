# Future Directions: Fibonacci as a Strong Divisibility Sequence

## Synthesis

This cycle distilled the divisibility theory of the Fibonacci sequence down to a single
structural axiom and proved that essentially every elementary divisibility fact is a
formal consequence of it. The axiom is the **Fibonacci gcd identity** (the catalog's
`Fib_gcd_identity`, here `Nat.fib_gcd`):

> `Nat.fib (Nat.gcd m n) = Nat.gcd (Nat.fib m) (Nat.fib n)`,

i.e. `Nat.fib` is a *strong divisibility sequence*. Combined with the single analytic
input that `Nat.fib` is strictly monotone (hence injective) on `Set.Ici 2`, this yields,
in `Catalog/Algebra/FibonacciStrongDivisibility.lean`:

- `fib_dvd_gcd_indices` — the set of indices `{k | d ∣ fib k}` is closed under `gcd`;
- `fib_dvd_fib_iff` — for `3 ≤ m`, `fib m ∣ fib n ↔ m ∣ n` (sharp: false for `m ∈ {1,2}`);
- `fib_coprime_iff` — `Coprime (fib m) (fib n) ↔ gcd m n = 1 ∨ gcd m n = 2`;
- `fib_dvd_iff_fibRank_dvd` — the **law of apparition** for an *arbitrary* modulus `d`.

The headline conceptual result is the last one. The catalog's
`fib_dvd_iff_entry_dvd` proved the law of apparition only for **prime** moduli `p`. Our
proof reveals that primality is an *unnecessary* hypothesis: the law of apparition holds
for every modulus `d` admitting an apparition witness, because the only machinery actually
used is gcd-closure of the index set plus minimality of the rank `fibRank d`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_gcd_indices` | index set closed under `gcd` | proved (sorry = 0) |
| `fib_dvd_fib_iff` | `fib m ∣ fib n ↔ m ∣ n` for `m ≥ 3` | proved (sorry = 0) |
| `fib_coprime_iff` | coprimality ↔ `gcd m n ∈ {1,2}` | proved (sorry = 0) |
| `fibRank_pos`, `fibRank_dvd` | basic properties of the rank of apparition | proved (sorry = 0) |
| `fib_dvd_iff_fibRank_dvd` | law of apparition for arbitrary `d` | proved (sorry = 0) |

All proofs depend only on `Mathlib` and the gcd identity; no `sorry`, no extra axioms.

## Research Directions

### 1. Abstract the whole development to arbitrary strong divisibility sequences

Replace `Nat.fib` by an arbitrary sequence `a : ℕ → ℕ` satisfying
`a (gcd m n) = gcd (a m) (a n)` together with the eventual-strict-monotonicity input, and
re-derive `fib_dvd_gcd_indices`, `fib_dvd_fib_iff`, and `fib_dvd_iff_fibRank_dvd` verbatim.
**The key insight is** that the four Fibonacci theorems never touch the recurrence
`F_{n+2} = F_{n+1} + F_n` — they use *only* gcd-multiplicativity and injectivity past a
threshold, so they should generalize unchanged to Lucas sequences `U_n(P,Q)`, Mersenne
numbers `2^n - 1`, and `q`-integers `[n]_q`. **Why now?** The proofs in this cycle are
already phrased structurally around `Nat.fib_gcd`; factoring the hypothesis out into a
typeclass `StrongDivSeq` is a mechanical refactor that immediately multiplies the theorem
count across the catalog's divisibility files.

### 2. Total existence of the rank of apparition

Our law of apparition is stated with an apparition-witness hypothesis
`∃ k, 0 < k ∧ d ∣ fib k`. Conjecture: for every `d ≥ 1` this witness exists, so `fibRank d`
is total and positive on `d ≥ 1` (and `fibRank d ≤ d^2`). **The key insight is** that the
pairs `(fib k mod d, fib (k+1) mod d)` are eventually periodic with period at most `d^2`
(the Pisano period bounds it), and `0 ≡ fib 0` lies in the cycle, forcing some `fib k ≡ 0`.
**Why now?** With `fib_dvd_iff_fibRank_dvd` already proven, discharging totality turns the
conditional law of apparition into an unconditional one, removing the hypothesis from every
downstream lemma and matching the catalog's prime-case `fibEntryPoint` exactly while
strictly generalizing it.

### 3. Multiplicativity of the rank: `fibRank (lcm a b)` and coprime moduli

Conjecture: for coprime `a, b`, `fibRank (a * b) = lcm (fibRank a) (fibRank b)`, extending
the catalog's `FibonacciEntryPointInvariant` results from primes to all coprime pairs.
**The key insight is** that `a*b ∣ fib k ↔ a ∣ fib k ∧ b ∣ fib k` (CRT) and each side is
governed by `fib_dvd_iff_fibRank_dvd`, so the divisibility lattice `{k | a*b ∣ fib k}` is
exactly the intersection of two arithmetic progressions, whose generator is the `lcm`.
**Why now?** `fib_dvd_iff_fibRank_dvd` gives the exact "multiples of `fibRank`" description
needed; the lattice intersection is then pure `Nat.lcm_dvd_iff` bookkeeping.

### 4. Primitive prime divisors via the rank, finishing the Carmichael tail

The catalog's `fib_carmichael_composite` (`Catalog/Shared/CarmichaelProof.lean`) closes
`13 ≤ n ≤ 10000` by `native_decide` but leaves the tail `n > 10000` open. Conjecture: a
prime `p` is a *primitive* divisor of `fib n` iff `fibRank p = n`, and for `n ∉ {1,2,6,12}`
such a `p` exists. **The key insight is** that `fib_dvd_iff_fibRank_dvd` recasts
"primitive" as the purely arithmetic condition `fibRank p = n`, so Carmichael's theorem
becomes: the cyclotomic-type factor `Φ_n(fib)` is not fully "absorbed" by proper divisors —
provable from the LTE/growth bounds already formalized in
`Tropical_..._Fibonacci_Primitive_Divisors.lean`. **Why now?** Both halves of the bridge
(rank theory here, LTE + exponential growth bounds in the catalog) are now formalized; the
remaining step is the counting inequality `F_n > ∏ (absorbed parts)`, isolating a single
finite analytic lemma instead of an open-ended search.

### 5. Quantitative apparition bounds and a verified Pisano-period interface

Conjecture: `fibRank p ∣ p - 1` when `p ≡ ±1 (mod 5)` and `fibRank p ∣ p + 1` when
`p ≡ ±2 (mod 5)` (the classical entry-point law), giving `fibRank p ≤ p + 1` for all primes
`p ≠ 5`. **The key insight is** that the Binet identity over `ZMod p` makes `fib (p - (5/p))
≡ 0`, which combined with `fib_dvd_iff_fibRank_dvd` forces `fibRank p ∣ p - (5/p)`.
**Why now?** The law of apparition proven this cycle is precisely the tool that converts a
*single* divisibility witness (from quadratic reciprocity for `5`) into a *divisibility of
the index*, turning a hard analytic statement into a one-line corollary once the Legendre
symbol computation is in place.
