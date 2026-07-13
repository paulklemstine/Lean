# Computational Evidence

**Claim.** The additive elementary cellular automaton `new = old + right-neighbour`
on the cyclic lattice `ℤ/n`, realised as multiplication by `u = 1 + X` in the
finite ring `Rq n = 𝔽₂[X]/(Xⁿ − 1)`, is **nilpotent** iff `n` is a power of `2`.

## Reduction used for testing

By the main theorem (`caUnit_isNilpotent_iff` / its `dvd`/`eq` lemmas),
nilpotency of `u = 1 + X` in `𝔽₂[X]/(Xⁿ − 1)` is equivalent to the polynomial
identity

```
Xⁿ − 1 = (X + 1)ⁿ     (the "Frobenius collapse")
```

Over `𝔽₂` we have `Xⁿ − 1 = Xⁿ + 1`, so this identity holds iff every middle
binomial coefficient `C(n, i)` with `0 < i < n` is **even**.  Thus:

```
collapse(n)  :=  ∀ 0 < i < n,  C(n,i) ≡ 0 (mod 2)
```

## Small-case table (`n = 0 … 16`)

Computed in Lean (`#eval`), comparing `collapse(n)` against `isPow2(n)`:

| n  | collapse(n) | power of 2 | agree |
|----|-------------|------------|-------|
| 1  | true        | true       | ✓ |
| 2  | true        | true       | ✓ |
| 3  | false       | false      | ✓ |
| 4  | true        | true       | ✓ |
| 5  | false       | false      | ✓ |
| 6  | false       | false      | ✓ |
| 7  | false       | false      | ✓ |
| 8  | true        | true       | ✓ |
| 9  | false       | false      | ✓ |
| 10 | false       | false      | ✓ |
| 11 | false       | false      | ✓ |
| 12 | false       | false      | ✓ |
| 13 | false       | false      | ✓ |
| 14 | false       | false      | ✓ |
| 15 | false       | false      | ✓ |
| 16 | true        | true       | ✓ |

A single `#eval` confirms `collapse(n) = isPow2(n)` for all `n` in `1..16`
(returns `true`).  (For `n = 0` the middle-coefficient condition is vacuously
`true`; the theorem assumes `n > 0`, so `n = 0` is excluded.)

The nilpotent sizes `1, 2, 4, 8, 16, …` are exactly the powers of two — this is
OEIS **A000079** (powers of 2).  The middle-binomial "collapse" characterisation
of powers of two is the classical Kummer/Lucas fact that Pascal's triangle mod 2
(the Sierpiński pattern) has an all-even interior row precisely at rows `2ᵏ`.

## Counterexample hunt

No counterexample exists (and the Lean proof establishes this for all `n`): the
table above tests every `n ≤ 16` and finds perfect agreement between the
dynamical/algebraic condition and the arithmetic condition `n = 2ᵏ`.
