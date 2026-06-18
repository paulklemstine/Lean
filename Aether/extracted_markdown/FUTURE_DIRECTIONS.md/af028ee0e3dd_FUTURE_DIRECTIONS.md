# Future Directions — The Entry-Point (Rank-of-Apparition) Lattice Morphism

## Synthesis

This cycle isolated, and proved in full abstraction, the two facts that the catalog's
"proof phase transition / Fibonacci primitive divisor" program had only ever stated for the
Fibonacci sequence (and through the now-missing `Speculative.AutoResearch.FibonacciApparition`
module): the **law of apparition** and the **coprime multiplicativity of the rank of
apparition**. The new file `Catalog/Speculative/AutoResearch/EntryPointMultiplicativity.lean`
shows both follow from nothing but the renormalization identity
`gcd (u m) (u n) = u (gcd m n)` together with the boundary value `u 0 = 0`. Concretely it
proves, for an arbitrary strong divisibility sequence `u`:

* `dvd_iff_entry_dvd` — `m ∣ u k ↔ entry u m ∣ k` (the bridge from terms to indices);
* `entry_eq_of_dvd_iff` — the entry point is the unique positive generator of the appearance
  set (uses only the gcd identity, **not** `u 0 = 0`);
* `entry_dvd_entry_of_dvd` — `d ∣ m → entry u d ∣ entry u m` (order side of the morphism);
* `entry_mul_coprime` — `entry u (a·b) = lcm (entry u a) (entry u b)` on coprime moduli.

These were harvested into two cross-domain instances at zero further cost:
`mersenne_entry_mul_coprime` for `u n = aⁿ − 1` (where `entry` is the multiplicative order,
so this is the classical `ord_{a·b} = lcm(ord_a, ord_b)`) and `fib_entry_mul_coprime` for
Fibonacci, recovering the catalog's `fibEntry_mul_coprime`. Together with the catalog's
`StrongDivSeq.dvd_gcd_index_iff` (`gcd ↦ gcd`) this exhibits `entry u` as a genuine
divisibility-lattice morphism, and pins down `u 0 = 0` as load-bearing only for the `k = 0`
edge case of the law of apparition.

## Results Summary

| Theorem | Statement | Hypotheses actually used |
|---|---|---|
| `dvd_iff_entry_dvd` | `m ∣ u k ↔ entry u m ∣ k` | `IsSDS`, `Appears` (`u 0 = 0` only for `k=0`) |
| `entry_eq_of_dvd_iff` | entry = unique positive generator | `IsSDS` only |
| `entry_dvd_entry_of_dvd` | `d ∣ m → entry u d ∣ entry u m` | `IsSDS` only |
| `entry_mul_coprime` | `entry u (a·b) = lcm (entry u a) (entry u b)` | `IsSDS`, `u 0 = 0`, coprimality, `Appears` |
| `mersenne_entry_mul_coprime` | order is multiplicative on coprime moduli | `Appears` of both factors |
| `fib_entry_mul_coprime` | Fibonacci rank multiplicative on coprime moduli | `Appears` of both factors |

All six are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Fibonacci totality: discharge the `Appears` hypotheses via Pisano periodicity
**Conjecture.** Every positive `m` divides some positive Fibonacci number, with the first
index `entry Nat.fib m ≤ m²` (more sharply, `≤ 6m`, the Pisano-period bound). Formalizing
this removes the `Appears` hypotheses from `fib_entry_mul_coprime`, turning it into the
unconditional `∀ a b > 0, Coprime a b → entry fib (a·b) = lcm (entry fib a) (entry fib b)`.
**The key insight is** that the pair-state map `k ↦ (fib k mod m, fib (k+1) mod m)` is an
injection-on-a-finite-set whose dynamics are *invertible* (the recurrence runs backwards),
so the orbit is purely periodic and must return to `(0, 1)`, forcing a zero of `fib` mod `m`.
**Why now?** Mathlib has no rank-of-apparition existence lemma, yet everything downstream in
this file is already conditional only on `Appears`; supplying this one lemma instantly
upgrades the whole Fibonacci layer to hypothesis-free theorems and matches the catalog's lost
`exists_pos_dvd_fib`.

### 2. Prime-power reconstruction of the entry point
**Conjecture.** For any strong divisibility sequence with `u 0 = 0` in which every modulus
appears, `entry u n = Finset.lcm (n.primeFactors) (fun p => entry u (p ^ (n.factorization p)))`,
i.e. the entry point is *completely determined by its values on prime powers*.
**The key insight is** that `entry_mul_coprime` is exactly the statement that `entry u` is an
lcm-homomorphism on coprime products, and the prime-power factorization of `n` is a coprime
product, so induction on the number of prime factors collapses `entry u n` to an lcm over
prime powers. **Why now?** The coprime multiplicativity lemma proved this cycle is the precise
inductive step that was previously missing; this direction is the natural "global" payoff and
is falsifiable by a single numerical mismatch in `#eval` over Fibonacci or Mersenne.

### 3. The dual meet law for entry points
**Conjecture.** Under totality, `entry u (Nat.gcd a b)` divides `Nat.gcd (entry u a) (entry u b)`,
and equality can fail; identify the exact obstruction. (Contrast: the *join* law
`entry u (lcm-of-coprime) = lcm` is now an equality.)
**The key insight is** that `gcd a b ∣ a` already gives `entry u (gcd a b) ∣ entry u a`
via `entry_dvd_entry_of_dvd`, so the divisibility direction is immediate; the open content is
whether the reverse holds, which probes how faithfully `entry u` reflects the *meet* (not just
the *join*) of the modulus lattice. **Why now?** With the order-side morphism
`entry_dvd_entry_of_dvd` in hand, the easy direction is free and the question sharpens to a
clean equality-vs-strict-divisibility dichotomy, testable on small `a, b`.

### 4. Identify the Mersenne entry point with the multiplicative order
**Conjecture.** For `a ≥ 2` and `Nat.Coprime a m` with `m ≥ 1`,
`entry (fun n => aⁿ − 1) m = orderOf (a : ZMod m)` (with the convention `orderOf 1 = 1` at
`m = 1`), so that `mersenne_entry_mul_coprime` *is* the classical multiplicative-order identity
`ord_{a·b}(a) = lcm(ord_a, ord_b)`. **The key insight is** that `m ∣ aᵏ − 1 ↔ aᵏ ≡ 1 (mod m)
↔ (a : ZMod m)ᵏ = 1`, so the least positive such `k` is by definition the order; Euler's
theorem (`ZMod.pow_totient`) supplies the `Appears` hypothesis automatically when
`Coprime a m`. **Why now?** Mathlib has a mature `orderOf` / `ZMod` API, so this bridge is
immediately within reach and turns the abstract instantiation into a recognizable number-theory
theorem, while also discharging `Appears` for the entire coprime-to-base Mersenne family.

### 5. Close the genuine open `sorry`: Carmichael's primitive-divisor theorem, infinite tail
**Conjecture (Carmichael 1913).** For composite `n > 10000` (the residual case left as `sorry`
at `Catalog/Shared/CarmichaelProof.lean:129`), `Nat.fib n` has a primitive prime divisor; in
fact every `Nat.fib n` with `n ∉ {1,2,6,12}` does. **The key insight is** that a prime `p` is
a primitive divisor of `fib n` iff `entry Nat.fib p = n` (now a clean statement via this
cycle's `dvd_iff_entry_dvd`/`entry_eq_of_dvd_iff`), and the failure of primitivity is
controlled by the cyclotomic/“lifting-the-exponent” valuation `v_p(fib n)`, so a
Zsygmondy-style counting of cyclotomic contributions rules out all-divisors-non-primitive for
large `n`. **Why now?** The entry-point bridge proved here reduces "primitive divisor exists"
to "some prime has entry point exactly `n`", and the catalog already contains a p-adic
valuation/LTE file for Fibonacci primitive divisors
(`Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`);
combining the two is the concrete path to eliminating the last mathematically deep `sorry` in
the Carmichael chain.
