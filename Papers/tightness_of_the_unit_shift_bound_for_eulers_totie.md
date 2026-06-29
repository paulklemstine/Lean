# Computational Evidence — Fermat-prime prefix collisions for `φ(n) = φ(n+1)`

Topic: tightness of the unit-shift bound for Euler's totient function, via the
Graham–Holt–Pomerance constructive lower-bound strategy for
`S₁^φ(x) = #{ n ≤ x : φ(n) = φ(n+1) }`.

## 1. Small-case unit-shift collisions

Enumerating `n ≤ 1000` with `φ(n) = φ(n+1)` (catalog data) gives exactly:

| n   | n  factorization | n+1 factorization | common φ |
|-----|------------------|-------------------|----------|
| 1   | 1                | 2                 | 1        |
| 3   | 3                | 2²                | 2        |
| 15  | 3·5              | 2⁴                | 8        |
| 104 | 2³·13            | 3·5·7             | 48       |
| 164 | 2²·41            | 3·5·11            | 80       |
| 194 | 2·97             | 3·5·13            | 96       |
| 255 | 3·5·17           | 2⁸                | 128      |
| 495 | 3²·5·11          | 2⁴·31             | 240      |
| 584 | 2³·73            | 3²·5·13           | 288      |
| 975 | 3·5²·13          | 2⁴·61             | 480      |

→ `S1phi 975 = 10` (catalog `S1phi_ge_ten`).

## 2. The Fermat-prime prefix pattern

Three of the rows above (`3|4`, `15|16`, `255|256`) share one structure: `n` is a
**product of distinct Fermat primes** `Fₖ = 2^(2^k)+1` and `n+1` is a **power of
two**. The classical telescoping identity (Mathlib `Nat.prod_fermatNumber`,
re-proved here as `fermat_telescope`)

```
∏_{k<m} (2^(2^k)+1) = 2^(2^m) - 1
```

makes this exact:

| m | prefix product = 2^(2^m)−1 | n+1 = 2^(2^m) | φ value = 2^(2^m−1) |
|---|----------------------------|----------------|----------------------|
| 1 | 3                          | 4              | 2                    |
| 2 | 15                         | 16             | 8                    |
| 3 | 255                        | 256            | 128                  |
| 4 | 65535 = 3·5·17·257         | 65536          | 32768                |
| 5 | 4294967295 = 3·5·17·257·65537 | 4294967296  | 2147483648           |

The `m = 4, 5` rows are **new collisions far outside the catalog's `≤ 1000`
search range**, verified multiplicatively in `TotientFermatCollisions.lean`
(`ghp_65535`, `ghp_4294967295`). Each requires only primality of the Fermat
factors (`norm_num` discharges `Nat.Prime 65537`).

## 3. Why the family is finite (counterexample to naive infinitude)

`F₅ = 2^(2^5)+1 = 4294967297 = 641 · 6700417` is **composite**, so the prefix
hypothesis `∀ i < m, Prime (2^(2^i)+1)` is unsatisfiable for `m ≥ 6`. Indeed every
known Fermat number `F₅,…,F₃₂` is composite, and no Fermat prime beyond `F₄` is
known. Hence this elementary family produces exactly the five collisions above and
**cannot by itself establish infinitude of `S₁^φ`** — matching the open status
recorded in the catalog Lab Notes. The genuine GHP lower bound is analytic.

## 4. Counting consequence

Adding the two new witnesses to the catalog's ten gives twelve certified
collisions below `4294967295`:

```
12 ≤ S1phi 4294967295          (theorem `S1phi_ge_twelve`)
```

a verified improvement over the catalog's `10 ≤ S1phi 975`, extending the range
`x` by roughly seven orders of magnitude.

## 5. OEIS

The unit-shift solution set `{1, 3, 15, 104, 164, 194, 255, 495, 584, 975, …}`
(values `n` with `φ(n)=φ(n+1)`) is **OEIS A001274**. The power-of-two-vs-product
subfamily `{3, 15, 255, 65535, 4294967295}` is `2^(2^m) − 1` for the known Fermat
primes, related to **A051179** (`2^(2^n) − 1`) and the Fermat primes **A019434**.

All numeric claims in this note are reproduced as fully verified Lean theorems
(0 sorries, standard axioms only) in `TotientFermatCollisions.lean`.
