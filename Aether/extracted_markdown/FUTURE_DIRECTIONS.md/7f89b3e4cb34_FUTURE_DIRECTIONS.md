# Future Directions — From the Lucas apparition parity law

## Synthesis

This cycle sharpened the catalog's Lucas–Fibonacci bridge. The marquee result of
`Catalog/Applications/FibonacciLucasBridge.lean` characterized Lucas divisibility implicitly:
for an odd prime `p` with Fibonacci rank `r = rank p`,

```
p ∣ L n  ↔  (r ∣ 2 n  ∧  r ∤ n).
```

In `Catalog/Novelty/LucasApparitionParity.lean` we proved that this condition is *purely
2-adic*. The new arithmetic core `dvd_two_mul_and_not_dvd_iff` shows, for any `0 < r`,

```
r ∣ 2 n  ∧  r ∤ n   ↔   ∃ s, r = 2 s ∧ s ∣ n ∧ Odd (n / s),
```

i.e. `r` must be even and `n` must be an *odd* multiple of `r/2`. Specializing gives the
explicit Lucas apparition law `prime_dvd_lucas_iff_parity`, the vanishing theorem
`prime_not_dvd_lucas_of_odd_rank` (odd rank ⇒ `p` divides no Lucas number, e.g. `p = 5`),
and the existence dichotomy `exists_dvd_lucas_iff_even_rank` (`p` divides some `L n` iff
`rank p` is even). All four are `sorry`-free and rest only on `propext`, `Classical.choice`,
and `Quot.sound`.

The picture that emerges: the Lucas apparition behavior of an odd prime is governed by a
*single bit* of its Fibonacci rank — the parity of `r` — and, when present, by the 2-adic
valuation `v₂(r)`. The Fibonacci side is "ideal-like" (`m ∣ F k ↔ rank m ∣ k`); the Lucas
side is its 2-adic shadow. The directions below probe how far this parity/valuation
dictionary extends, and connect it back to the cycle's stated motivation (primitive-divisor
and Carmichael-type phenomena).

## Results summary

- `dvd_two_mul_and_not_dvd_iff` — domain-free 2-adic core lemma.
- `prime_dvd_lucas_iff_parity` — explicit Lucas apparition law via `(s, Odd (n/s))`.
- `prime_not_dvd_lucas_of_odd_rank` — odd Fibonacci rank ⇒ no Lucas divisibility.
- `exists_dvd_lucas_iff_even_rank` — existence dichotomy keyed on `Even (rank p)`.

Numerically validated for all odd primes `p < 60` and all `n < 80`; the odd-rank case is
non-vacuous (`p = 5, 13, 17, 37, 53, …`).

## Research directions

### 1. The Lucas rank is exactly `rank(p)` when `rank(p)` is even.
Define a Lucas rank `lrank p` as the least `m > 0` with `p ∣ L m`. The parity law forces
`lrank p = (rank p)/2` whenever `rank p` is even, and `lrank p` undefined otherwise.
**Conjecture:** for every odd prime `p` with `Even (rank p)`, `lrank p = rank p / 2`, and the
Lucas apparition set `{n : p ∣ L n}` equals the odd multiples of `rank p / 2`. **The key
insight is** that the odd-multiple structure in `prime_dvd_lucas_iff_parity` is precisely an
arithmetic progression with common difference `rank p`, so the Lucas apparition set is a coset
of the Fibonacci apparition ideal, not an ideal itself — a structural asymmetry the catalog has
not recorded. **Why now?** The explicit `(s, Odd (n/s))` witness already in hand makes
`lrank` definable and its formula immediately provable by reusing `dvd_two_mul_and_not_dvd_iff`;
no new machinery is required.

### 2. Prime-power lifting (LTE) for Lucas numbers.
The catalog proves a lifting-the-exponent bound for Fibonacci numbers
(`Tropical_..._Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`,
`fib_lte`). **Conjecture:** for an odd prime `p` with even rank and `p ∣ L n`, the valuation
satisfies `v_p(L n) = v_p(L (lrank p)) + v_p(n / lrank p)`, the Lucas analogue of the
Fibonacci LTE law. **The key insight is** that `L n = F(2n)/F n` turns a Lucas valuation into a
*difference* of two Fibonacci valuations, both already controlled by the catalog's `fib_lte`;
the parity law guarantees the subtracted term `v_p(F n)` is zero exactly on the Lucas
apparition set, so the difference collapses to a single LTE expression. **Why now?** Both
inputs — `fib_lte` and the doubling identity `fib_two_mul_eq_fib_mul_lucas` — are present and
proved, so this is an assembly problem, not a from-scratch development.

### 3. Primitive prime divisors of Lucas numbers.
Carmichael-type theory in the catalog concerns primitive divisors of `F n`. Define `q` to be a
*Lucas-primitive* divisor of `L n` if `q ∣ L n` but `q ∤ L m` for all `0 < m < n`.
**Conjecture:** `q` (odd prime) is Lucas-primitive for `L n` iff `lrank q = n`, equivalently iff
`rank q = 2 n`; and `L n` has a primitive prime divisor for all `n ∉ {1, 6}`. **The key insight
is** that the bijection `n ↦ 2n` between Lucas indices and even Fibonacci ranks transports the
Fibonacci primitive-divisor existence theorem onto Lucas numbers, so the Lucas exceptional set is
the `F`-exceptional set `{1,2,6,12}` pulled back through doubling. **Why now?** The Fibonacci
primitive-divisor existence results (`fib_prime_has_primitive`, the finite exceptional cases)
are already proven in the catalog, and the parity law supplies the missing index translation.

### 4. The 2-adic stratification of odd primes by `v₂(rank p)`.
Group odd primes by `k = v₂(rank p)`: `k = 0` (odd rank, never divides a Lucas number),
`k = 1`, `k ≥ 2`, … . **Conjecture:** the Lucas apparition set of `p` is the residue class
`{n : v₂(n) = k - 1 ∧ (odd part of rank p) ∣ n}` for `k ≥ 1`, and empty for `k = 0`; moreover the
natural density of odd primes with `k = 0` is positive (so a positive proportion of odd primes
divide *no* Lucas number). **The key insight is** that the single parity bit proven here is the
bottom layer of a full 2-adic valuation stratification, and the qualitative `k = 0` stratum is
already a theorem (`prime_not_dvd_lucas_of_odd_rank`). **Why now?** The valuation refinement is a
direct strengthening of `dvd_two_mul_and_not_dvd_iff` from "even/odd" to "`v₂`", reachable by the
same `Nat`-level 2-adic argument; the density half connects to existing analytic-number-theory
threads in the catalog.

### 5. Generalization to Lucas sequences `U_n(P,Q)` and their companions `V_n`.
Replace `(F, L)` by a general non-degenerate Lucas pair `U_n(P,Q)`, `V_n(P,Q)` with the doubling
identity `U_{2n} = U_n V_n`. **Conjecture:** for an odd prime `p ∤ 2Q` with rank `ρ_p` (least `n`
with `p ∣ U_n`), `p ∣ V_n ↔ ∃ s, ρ_p = 2 s ∧ s ∣ n ∧ Odd (n/s)` — i.e. the parity law is a
universal feature of Lucas sequences, not special to Fibonacci. **The key insight is** that the
entire proof used only the doubling factorization `U_{2n} = U_n V_n` and the coprimality
`gcd(U_n, V_n) ∣ 2Q`, both of which hold for every Lucas sequence; the Fibonacci specifics
(`Nat.fib_gcd`, `Nat.fib_dvd`) entered only through the rank ideal theorem, which itself
generalizes. **Why now?** The self-contained proof here isolates exactly the two abstract inputs
needed, making the generalization a matter of re-proving those two facts for `U_n(P,Q)` — a
well-scoped next target that would lift a Fibonacci curiosity to a structural theorem about all
Lucas sequences.
