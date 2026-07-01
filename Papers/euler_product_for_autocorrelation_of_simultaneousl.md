# Computational Evidence — Euler Product for Autocorrelation of Simultaneously Visible Lattice Points

We record small-case computations supporting the local/Euler-product structure that
is formalized in `Core.lean` and `EulerProduct.lean`.

## 1. Local factor as a complement count

Fix a prime `p` and dimension `k`. A residue class `v ∈ (ℤ/pℤ)ᵏ` is *simultaneously
visible at `p`* from a finite set `S` (with shift `z`) iff `v` avoids the image
`S_p` and `v` avoids `(S − z)_p`. The number of good classes is therefore

```
pᵏ − |S_p ∪ (S − z)_p|.
```

Small check, `k = 2`, `S = {0}`, `z = 0`, `p = 2`: `S_2 = {(0,0)}`, so the good
classes are the `2² − 1 = 3` nonzero classes `{(1,0),(0,1),(1,1)}`. Density
`3/4 = 1 − 1/2²`. Matches `localDensity_singleton` (`= 1 − p^{-k}`).

| p | pᵏ (k=2) | pᵏ − 1 | factor 1 − p⁻² |
|---|----------|--------|----------------|
| 2 | 4        | 3      | 0.7500         |
| 3 | 9        | 8      | 0.8889         |
| 5 | 25       | 24     | 0.9600         |
| 7 | 49       | 48     | 0.9796         |

Product over all primes → `1/ζ(2) = 6/π² ≈ 0.607927`, the classical density of
primitive (visible-from-origin) lattice vectors. This is the `S = {0}, z = 0` case of
the general autocorrelation `γ_S(0)`.

## 2. Autocorrelation of the classical visible set (`S = {0}`), general shift `z`

Here `γ_{0}(z) = ∏_p (1 − |{0, −z}_p| / p²)`.
For a prime `p`, `|{0, −z}_p| = 1` if `p ∣ z` (i.e. `z ≡ 0 mod p`), else `2`.
So the local factor is `1 − 1/p²` at primes dividing `gcd(z)`, and `1 − 2/p²`
otherwise. First terms for `z = (1,0)` (no prime divides both coordinates):

| p | 1 − 2/p² |
|---|----------|
| 2 | 0.5000   |
| 3 | 0.7778   |
| 5 | 0.9200   |
| 7 | 0.9592   |

Partial products: `0.5, 0.3889, 0.3578, 0.3432, …` converging (the tail
`∏ (1 − 2/p²)` converges since `Σ 2/p² < ∞`), giving a positive autocorrelation
value — evidence that `γ` is well defined and, being a convergent Euler product,
gives a pure-point diffraction measure.

## 3. Multiplicativity across coprime moduli (CRT)

`card_crt_filter` predicts: for coprime `m, n`, the number of residues mod `m·n`
meeting an independent constraint mod `m` (allowed set `A`) and mod `n` (allowed set
`B`) is `|A|·|B|`.

Check `k = 1`, `m = 2`, `n = 3`, `A = {1} ⊆ ℤ/2`, `B = {1,2} ⊆ ℤ/3`. Residues mod 6
with `r ≡ 1 (2)` and `r ∈ {1,2} (3)`: `r ≡ 1 (2)` gives `{1,3,5}`; intersect with
`r mod 3 ∈ {1,2}`: `1 (→1 ✓), 3 (→0 ✗), 5 (→2 ✓)` = `{1,5}`, count `2 = 1·2 = |A|·|B|`. ✓

This is the finite prototype of the Euler product: local densities multiply because
the per-prime constraints are independent by CRT.

## 4. Counterexample hunt

- Multiplicativity fails without coprimality: `m = n = 2` (not coprime) — the CRT
  equivalence does not exist and counts need not multiply. The `Nat.Coprime`
  hypothesis in `card_crt_filter` is load-bearing (removing it breaks the CRT ring
  isomorphism), confirmed by the statement requiring `h : Nat.Coprime m n`.
- The visibility-to-residue bridge (`vecGcd_eq_one_iff`) needs *all* primes, not a
  finite set: e.g. any single prime constraint leaves infinitely many non-coprime
  vectors. No finite-prime weakening survives.

No counterexample to the local/Euler-product claim was found in the tested range.
