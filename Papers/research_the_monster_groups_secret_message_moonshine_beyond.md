# Arithmetic Characterisation of the Primes Dividing the Order of the Monster Group

## Problem statement

The Fischer–Griess Monster group `M` is the largest of the twenty-six sporadic
finite simple groups. A. P. Ogg's celebrated observation ("the jack of diamonds
problem") is that the set of prime numbers dividing the order `|M|` coincides
*exactly* with the set of **supersingular primes** — the primes `p` for which the
modular curve `X₀(p)` (equivalently its Fricke quotient) has genus `0`.

This work provides a fully machine-checked, elementary, and non-circular treatment
of the **arithmetic side** of Ogg's observation: taking `|M|` in its established
factored form and taking the supersingular primes as their explicit enumeration, we
prove the universally quantified divisibility characterisation for *all* primes, and
package it in the standard `Nat.primeFactors` interface. Every result is verified in
Lean 4 with Mathlib and is free of `sorry`.

## Mathematical context and definitions

The order of the Monster group is the 54-digit integer

```
|M| = 2^46 · 3^20 · 5^9 · 7^6 · 11^2 · 13^3 · 17 · 19 · 23 · 29 · 31 · 41 · 47 · 59 · 71
    = 808017424794512875886459904961710757005754368000000000.
```

The fifteen supersingular primes are

```
{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71}.
```

In the Lean development (`Catalog/FINAL/Tropical/MonsterMoonshine.lean`):

* `monsterOrder : ℕ` is defined by the prime-power product above.
* `supersingularPrimes : Finset ℕ` is the explicit fifteen-element set.

We emphasise that `prime_dvd_monsterOrder_iff` is quantified over **all** primes `p`,
so the "only if" direction is a genuine theorem about every prime and not a finite
membership test.

## Main results

All are proved in `MonsterMoonshine`:

1. **`monsterOrder_eq`** — the prime-power product equals the standard value
   `808017424794512875886459904961710757005754368000000000`.
2. **`card_supersingularPrimes`** — there are exactly `15` supersingular primes.
3. **`prime_dvd_monsterOrder_iff`** — for every prime `p`,
   `p ∣ |M| ↔ p ∈ supersingularPrimes`.
4. **`primeFactors_monsterOrder`** — `(|M|).primeFactors = supersingularPrimes`.
5. **`twentyfour_dvd_monsterOrder`**, **`monsterOrderDiv24_mul`**,
   **`monsterOrderDiv24_eq`** — a computational pipeline extracting
   `|M| / 24 = 33667392699771369828602496040071281541906432000000000`.

### Proof sketch

The only non-finite step is the "only if" direction of (3). Given a prime `p` with
`p ∣ |M|`, Euclid's lemma for primes (`Nat.Prime.dvd_mul`) — applied through the
product structure and re-associated with `or_assoc` — yields `p ∣ qᵢ^{eᵢ}` for one of
the fifteen factors. Then `Nat.Prime.dvd_of_dvd_pow` gives `p ∣ qᵢ`, and since both
`p` and `qᵢ` are prime, `Nat.prime_dvd_prime_iff_eq` forces `p = qᵢ`, placing `p` in
the enumerated set. The "if" direction is fifteen decidable divisibilities; the
numeric facts are `decide`/`native_decide`. Result (4) is (3) transported across
`Nat.mem_primeFactors`.

The certified axiom base is `{propext, Classical.choice, Quot.sound}`, augmented by
`{Lean.ofReduceBool, Lean.trustCompiler}` only for evaluating the 54-digit numeral.

## Significance

The result is the foundational arithmetic pillar of any formal moonshine program:
it isolates, with full rigour and no circular dependence on deep modular-forms
theory, the precise finite set of primes on which the Monster acts, and it does so as
a clean, reusable statement about `Nat.primeFactors` that downstream files can invoke
directly. The `|M| / 24` pipeline connects the group-order arithmetic to the `q`-
expansion normalisation used on the modular side of moonshine.

## Open questions / next steps

* **Genus-0 side.** Formalise the *definition* of supersingular prime via the genus
  of `X₀(p)` and prove it agrees with the enumerated set, closing the loop with the
  analytic content of Ogg's observation.
* **Head coefficients of `j`.** Formalise the McKay–Thompson head character
  decomposition `196884 = 196883 + 1` and successive coefficients as integer
  combinations of Monster irreducible-representation dimensions.
* **Sylow structure.** Use `prime_dvd_monsterOrder_iff` to state and prove
  Sylow-`p` existence facts for `M` uniformly across the fifteen primes.
* **General `X₀(N)` genus computation.** Build a decision procedure for the genus of
  `X₀(N)` and recover the fifteen supersingular primes as the genus-0 level set.
