# Computational Evidence — Asymmetric CRT split of `Q(a) = a^(N-1) mod N`

All numbers below were produced by evaluation inside Lean (`#eval`) and the key
rows were subsequently re-checked by the Lean kernel (`decide`, **no**
`native_decide`) in `Catalog/Cryptography/AsymmetricExponent/LabNotes.lean`.

## 1. Asymmetric CRT decomposition

For every pair of distinct primes `p, q ∈ {3,5,7,11,13,17,19}` and every
`a ∈ {2,3,5}` coprime to `N = p·q` (51 triples) we tested

```
Q(a) mod p == a^(q-1) mod p    and    Q(a) mod q == a^(p-1) mod q
```

Result: **51/51 true, no exceptions.** Sample:

| N = p·q | a | Q(a) mod p | a^(q-1) mod p | Q(a) mod q | a^(p-1) mod q |
|---------|---|------------|---------------|------------|---------------|
| 15=3·5  | 2 | 1          | 1             | 4          | 4             |
| 21=3·7  | 2 | 1          | 1             | 4          | 4             |
| 33=3·11 | 2 | 1          | 1             | 4          | 4             |
| 35=5·7  | 3 | 4          | 4             | 4          | 4             |
| 91=7·13 | 5 | 1          | 1             | 12         | 12            |

This is now a theorem for *all* `p, q, a`
(`AsymmetricExponent.pow_modEq_left` / `pow_modEq_right`), together with the
uniqueness statement `fetq_unique`.

## 2. Counterexample hunt for the liar count `g²`

Conjecture tested: the number of units `a` mod `N = p·q` with `a^{N-1} ≡ 1`
equals `g² `, where `g = gcd(p-1, q-1)`.

| N   | p, q   | g | measured #liars | g² | φ(N) | ratio |
|-----|--------|---|-----------------|----|------|-------|
| 15  | 3, 5   | 2 | 4               | 4  | 8    | 0.50  |
| 33  | 3, 11  | 2 | 4               | 4  | 20   | 0.20  |
| 35  | 5, 7   | 2 | 4               | 4  | 24   | 0.17  |
| 65  | 5, 13  | 4 | 16              | 16 | 48   | 0.33  |
| 91  | 7, 13  | 6 | 36              | 36 | 72   | 0.50  |
| 143 | 11, 13 | 2 | 4               | 4  | 120  | 0.03  |

No counterexample was found. Two structural facts stand out and were then
proved in general:

* the ratio never exceeds `1/2` (`fermatLiar_density_le_half`), with equality
  approached exactly when `g` is as large as it can be
  (`N = 15`, `N = 91` above);
* the same `g` gives the same count even for very different factorisations
  (`N = 33` versus `N = 35`), which is the numerical face of the isomorphism
  `liarGroupEquiv : liars ≃* (ℤ/g) × (ℤ/g)`.

## 3. Exponent gcd collapse

For all pairs above, `gcd(N-1, p-1) = gcd(N-1, q-1) = gcd(p-1, q-1)`, e.g.
`N = 91`: `gcd(90, 6) = 6`, `gcd(90, 12) = 6`, `gcd(6, 12) = 6`. Proved in
general as `gcd_exp_left`, `gcd_exp_right`, `gcd_exp_symmetric`.

## 3b. Reveal density of the gcd variant

Count of units `a` with `gcd(a^{N-1} - 1, N) ∉ {1, N}` (i.e. the gcd actually
returns a factor), against the predicted `g(q-1) + g(p-1) - 2g²`:

| N   | p, q   | g | measured reveals | predicted |
|-----|--------|---|------------------|-----------|
| 15  | 3, 5   | 2 | 4                | 4         |
| 35  | 5, 7   | 2 | 12               | 12        |
| 91  | 7, 13  | 6 | 36               | 36        |
| 143 | 11, 13 | 2 | 36               | 36        |
| 65  | 5, 13  | 4 | 32               | 32        |
| 33  | 3, 11  | 2 | 16               | 16        |

Agreement in all cases; proved in general as `card_revealing`, with the two
rows for `N = 15, 35` re-checked by the kernel in `LabNotes.lean`.

## 4. Sequences

The liar counts `g²` are squares of `gcd(p-1, q-1)`; no separate OEIS entry was
needed, the sequence being determined by `g`. The general Fermat-liar count
`gcd(N-1, p-1)·gcd(N-1, q-1)` is classical; the semiprime specialisation to
`g²` is what the data suggested and what is proved here.

## 5. What the evidence does *not* show

No experiment here says anything about the *hardness* of factoring. The
evidence supports the structural statements only: the split is exact, the
observable content of the Fermat/`Q` surface is the single number `g`, and
extracting a CRT component is equivalent to factoring
(`componentReader_factors`).
