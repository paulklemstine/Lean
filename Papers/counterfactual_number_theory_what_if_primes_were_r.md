# Computational Evidence — Counterfactual Primes in the Hilbert Monoid

We model a "counterfactual number theory" by the **Hilbert monoid**
`H = { n ∈ ℕ : n ≡ 1 (mod 4) }`, multiplicatively closed under the usual product.
Its *primes* are the `H`-irreducibles: elements of `H` with no nontrivial
factorization inside `H`.

## 1. Small-case calculations

Elements of `H` up to 50:

```
1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49
```

Classifying each `> 1` as reducible / irreducible inside `H`:

| n  | rational factorization | factors' classes mod 4 | H-irreducible? |
|----|------------------------|------------------------|----------------|
| 5  | prime                  | —                      | yes            |
| 9  | 3·3                    | 3·3 (both leave H)     | **yes**        |
| 13 | prime                  | —                      | yes            |
| 17 | prime                  | —                      | yes            |
| 21 | 3·7                    | 3·3 (both leave H)     | **yes**        |
| 25 | 5·5                    | 1·1 (stay in H)        | no (= 5·5)     |
| 29 | prime                  | —                      | yes            |
| 33 | 3·11                   | 3·3 (both leave H)     | yes            |
| 37 | prime                  | —                      | yes            |
| 41 | prime                  | —                      | yes            |
| 45 | 9·5                    | 1·1 (stay in H)        | no (= 9·5)     |
| 49 | 7·7                    | 3·3 (both leave H)     | **yes**        |

The three boldface entries `9, 21, 49` are the key: each is a product of two
rational primes `≡ 3 (mod 4)`, so neither factor is available inside `H`.

## 2. The unique-factorization counterexample

```
441 = 9 · 49        (both H-irreducible)
441 = 21 · 21       (H-irreducible squared)
```

The multiset of irreducible factors `{9, 49}` differs from `{21, 21}`, so `441`
has two genuinely different factorizations into counterfactual primes. This is
the smallest such collision in `H`. It is the classical Hilbert example showing
that unique factorization is not a formal consequence of having a multiplicative
monoid with irreducibles.

## 3. Counterexample hunt for the "survivors"

- **Multiplicative closure**: tested `a·b mod 4` for all `a, b ≡ 1 (mod 4)` with
  `a, b ≤ 200` — always `≡ 1 (mod 4)`. No counterexample (and provably none).
- **Infinitude of counterfactual primes**: the rational primes `≡ 1 (mod 4)`
  begin `5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97, …`; each is automatically
  `H`-irreducible. Dirichlet guarantees this list never terminates.

## 4. OEIS pointers

- Naturals `≡ 1 (mod 4)` (the Hilbert monoid): **A016813** (`1, 5, 9, 13, …`).
- Primes `≡ 1 (mod 4)` (a source of counterfactual primes): **A002144**
  (`5, 13, 17, 29, 37, …`).

## Conclusion

The computations confirm the split proven formally: closure and Dirichlet-type
infinitude survive the deformation of the prime set, while unique factorization
collapses already at `441`.
