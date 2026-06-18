# Future Directions: The Rank-of-Apparition Lattice Morphism

## Synthesis

The catalog's rank-of-apparition program (`RankOfApparition` in
`EntryPointMultiplicativity.lean`) established that, for a **strong divisibility
sequence** `u` — one satisfying the renormalization identity `gcd(uₘ, uₙ) = u₍gcd m n₎`
— with boundary value `u₀ = 0`, the rank-of-apparition map `entry u : ℕ → ℕ` behaves
like a morphism between two divisibility lattices: it sends `gcd ↦ gcd` (the meet side,
catalog) and, on **coprime** moduli, `product ↦ lcm` (the *binary* join law
`entry_mul_coprime`). The Fibonacci and Mersenne/repunit families are the headline
instances.

`RankApparitionFinite.lean` closes that picture into a genuine lattice statement and
pushes it to its structural endpoint:

* **Closure** (`appears_mul`): the set of moduli that appear is closed under coprime
  products.
* **Meet lower bound** (`entry_dvd_gcd`): `entry u (gcd a b) ∣ gcd(entry u a, entry u b)`,
  the order-theoretic companion of the catalog's order-side morphism.
* **Finite join law** (`entry_prod_coprime`): for a pairwise-coprime appearing family,
  `entry u (∏ᵢ fᵢ) = lcmᵢ (entry u (fᵢ))` — the binary law lifted to arbitrarily many
  factors.
* **Reduction to prime powers** (`entry_eq_lcm_primePow`): for `m > 0` whose prime-power
  parts appear, `entry u m = lcm over p∣m of entry u (p^{vₚ(m)})`. The entire
  rank-of-apparition function is determined by its values on prime powers.

All results are abstract: they use nothing beyond `IsSDS` and `u₀ = 0`, and instantiate
uniformly to Fibonacci (`fib_entry_prod_coprime`) and to the Mersenne/repunit family,
where `entry` *is* the multiplicative order (`mersenne_entry_prod_coprime`).

## Results Summary

| Theorem | Statement | Inputs |
|---|---|---|
| `appears_mul` | coprime `a,b` appear ⇒ `a*b` appears | `IsSDS` |
| `entry_dvd_gcd` | `entry(gcd a b) ∣ gcd(entry a, entry b)` | `IsSDS` |
| `entry_prod_coprime` | `entry(∏ fᵢ) = lcm(entry fᵢ)` (pairwise coprime) | `IsSDS`, `u₀=0` |
| `entry_eq_lcm_primePow` | `entry m = lcm_{p∣m} entry(p^{vₚ(m)})` | `IsSDS`, `u₀=0` |

Axiom profile: `propext`, `Classical.choice`, `Quot.sound` only; `sorry = 0` on all
main results.

## Research Directions

### 1. The prime-power values are the only free parameters — pin them down for Fibonacci.

The reduction `entry_eq_lcm_primePow` says the rank of apparition is a *free function on
prime powers* extended multiplicatively by `lcm`. For Fibonacci the prime-power values
obey a sharp conjecture: for an odd prime `p` and `e ≥ 1`,
`entry Nat.fib (p^e) = p^{max(e - vₚ(fib(entry fib p)), 0)} · entry fib p` — i.e. the rank
grows by one factor of `p` per extra power once a *Wall–Sun–Sun* threshold is crossed, and
no Wall–Sun–Sun prime (`p² ∣ fib(entry fib p)`) is known. **The key insight is** that
`entry_eq_lcm_primePow` quarantines the only genuine arithmetic content of the rank
function into the prime-power case, so the whole multiplicative theory rests on a single
*lifting-the-exponent* statement. **Why now?** The catalog already contains a
lifting-the-exponent file
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`);
combining its `vₚ` bounds with our prime-power reduction is exactly the missing bridge and
would yield a fully closed-form `entry Nat.fib`.

### 2. Totality: discharge the `Appears` hypotheses for Fibonacci and Mersenne.

Every concrete theorem here carries an explicit `Appears u m` hypothesis because Mathlib
lacks a rank-of-apparition *existence* lemma. For Fibonacci, `Appears Nat.fib m` holds for
*every* `m ≥ 1` (a Pisano-period fact: `fib` is purely periodic mod `m`, and `0` occurs in
each period). For `u n = aⁿ − 1`, `Appears m` ⇔ `gcd(a, m) = 1`. **The key insight is**
that periodicity mod `m` forces a zero of `fib` in `{1, …, m²}`, so existence is a finite
search made uniform by the pigeonhole on `(fib k, fib (k+1)) mod m`. **Why now?** Proving
`fib_appears : ∀ m ≥ 1, Appears Nat.fib m` once would strip the hypotheses from
`fib_entry_prod_coprime` and `entry_eq_lcm_primePow`, turning them into unconditional
theorems about a *total* multiplicative arithmetic function `entry Nat.fib : ℕ → ℕ`.

### 3. `entry u` is a lattice homomorphism, not merely a monotone pair of bounds.

We have meet *lower* bound (`entry_dvd_gcd`) and the coprime join *equality*. Conjecture:
on the full sublattice of appearing moduli, `entry u (gcd a b) = gcd(entry u a, entry u b)`
fails in general but holds whenever `a, b` are prime powers of distinct primes, and more
sharply `lcm(entry a, entry b) = entry(lcm a b)` for *all* appearing `a, b` (not just
coprime). **The key insight is** that dropping coprimality replaces `product` by `lcm` on
the modulus side, so the natural statement is `entry(lcm a b) = lcm(entry a, entry b)` — a
clean lattice-homomorphism law that subsumes `entry_prod_coprime`. **Why now?** Our
`entry_dvd_gcd` already provides one inclusion via the order-side morphism; the reverse
inclusion needs only the law of apparition `dvd_iff_entry_dvd` (already in the file),
making this a short, falsifiable next step that would upgrade "morphism of bounds" to
"lattice homomorphism."

### 4. Carmichael primitive divisors from the prime-power reduction.

A prime `p` is a *primitive divisor* of `uₙ` iff `entry u p = n`. The reduction to prime
powers reframes Carmichael's primitive-divisor theorem as: the set
`{ p prime : entry u p = n }` is nonempty for all `n` outside a finite exceptional set.
**The key insight is** that `entry u p = n` ⇔ `p ∣ uₙ` and `p ∤ u_d` for every proper
divisor `d ∣ n`, which by `dvd_iff_entry_dvd` is purely a statement about the index
lattice — exactly the data our morphism controls. **Why now?** The catalog has both a
primitive-divisor injectivity result (`primitive_divisor_inj`) and a Carmichael target
(`CarmichaelComposite`); expressing primitivity through `entry` connects these orphan
results to the multiplicative machinery proved here, a concrete cross-domain bridge.

### 5. Generalize beyond `ℕ` to Lucas sequences and elliptic divisibility sequences.

`IsSDS` is stated for `u : ℕ → ℕ`. Lucas sequences `U(P, Q)` and elliptic divisibility
sequences are strong divisibility sequences over `ℤ` (up to sign) and over global fields.
**The key insight is** that every proof in this file uses only `Nat.gcd`/`Nat.lcm` lattice
identities and `Nat.find` minimality, all of which have `GCDMonoid` analogues, so the
abstraction barrier is the *order structure on indices*, not the coefficient ring. **Why
now?** Mathlib's `GCDMonoid` and `UniqueFactorizationMonoid` are mature; restating `entry`
over an arbitrary `[CancelCommMonoidWithZero] [NormalizedGCDMonoid]` codomain would make
the rank-of-apparition lattice morphism a reusable piece of general arithmetic, applicable
wherever a strong divisibility sequence appears.
