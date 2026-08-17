# Computational Evidence — Berggren Spectral Eigenvalues and Modular Resonance

All numbers below were produced by `#eval` inside the Lean project (kernel-evaluated
arithmetic), before the corresponding theorems were formalised.  Everything that is *claimed*
is proved in `Catalog/Cryptography/BerggrenSpectral/`; this file records the exploration that
guided the proofs.

## 1. Spectra of the generators

With `M₁ = !![1,-2,2; 2,-1,2; 2,-2,3]`, `M₂ = !![1,2,2; 2,1,2; 2,2,3]`,
`M₃ = !![-1,2,2; -2,1,2; -2,2,3]` (the catalog `B₃`):

| generator | trace | det | characteristic polynomial | spectrum |
|---|---|---|---|---|
| `M₁` | 3 | 1 | `(X-1)³` | `{1,1,1}` (unipotent) |
| `M₂` | 5 | −1 | `(X+1)(X²−6X+1)` | `{−1, 3+2√2, 3−2√2}` |
| `M₃` | 3 | 1 | `(X-1)³` | `{1,1,1}` (unipotent) |

`3 + 2√2 = (1+√2)²` is the square of the silver ratio (fundamental unit of `ℤ[√2]`), of
norm 1.  Formalised in `Generators.lean`.

## 2. Unipotent powers grow polynomially

`M₁^k = !![1, −2k, 2k; 2k, 1−2k², 2k²; 2k, −2k², 1+2k²]` — verified for `k ≤ 20`, then
proved by induction (`berg_one_pow`).  Every entry of `M₁^k − 1` is `0, ±2k, ±2k²`, which is
the source of the **factoring barrier** (`berg_one_no_advantage`).

Order of `M₁` mod `p` (search over `k ≤ 5000`):

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ord | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 |

i.e. `ord = p` exactly — proved as `berg_one_orderOf`.

## 3. Hyperbolic resonance: `ord_p(M₂)` versus `p ∓ 1`

Column *predicted* is `p−1` if `p ≡ ±1 (mod 8)` (2 is a QR) and `p+1` otherwise.

| p | p mod 8 | ord_p(M₂) | predicted bound |
|---|---|---|---|
| 3 | 3 | 4 | 4 |
| 5 | 5 | 6 | 6 |
| 7 | 7 | 6 | 6 |
| 11 | 3 | 12 | 12 |
| 13 | 5 | 14 | 14 |
| 17 | 1 | 8 | 16 |
| 19 | 3 | 20 | 20 |
| 23 | 7 | 22 | 22 |
| 29 | 5 | 10 | 30 |
| 31 | 7 | 30 | 30 |
| 37 | 5 | 38 | 38 |
| 41 | 1 | 10 | 40 |
| 43 | 3 | 44 | 44 |
| 47 | 7 | 46 | 46 |
| 53 | 5 | 54 | 54 |
| 59 | 3 | 20 | 60 |
| 61 | 5 | 62 | 62 |

No counterexample: the order always divides the predicted value, and equals it in 13 of the
17 cases.  This is `berg_two_resonance_mod_eight` / `berg_two_resonance`.  (An earlier draft
conjectured the weaker bound `2(p∓1)`; the data showed the factor 2 was spurious and the
final theorems drop it.)

## 4. Counterexample hunt for the factoring criterion

For `N = p·q` we tested `k = p ∓ 1` (the resonance of `p`) on all semiprimes with
`3 ≤ p < q ≤ 61`.  Whenever `M₂^k ≢ 1 (mod q)` the gcd of the entries of `M₂^k − 1` with `N`
returned `p` exactly — never `1` and never `N`.  Two instances are now Lean theorems:

* `N = 15 = 3·5`, `k = 4`: `gcd((M₂⁴−1)ᵢⱼ, 15) = 3` (`berg_factor_fifteen`).
* `N = 3233 = 53·61`, `k = 54`: `gcd((M₂⁵⁴−1)₀₀, 3233) = 53` (`berg_factor_3233`).
  Direct evaluation: `Int.gcd ((M₂^54−1) 0 0) 3233 = 53` and
  `Int.gcd ((M₂^54−1) 0 1) 3233 = 53`.

Failure mode found and formalised: when `k` happens to be a resonance of *both* primes, every
gcd is `N` (`berg_aligned_resonance_no_factor`).  This is the honest boundary of the method —
without knowing `p` one does not know which `k` to use, so no polynomial-time factoring
follows.  The method is a Berggren-tree analogue of Pollard `p ± 1`.

## 5. The Berggren–Lucas trace sequence

`t k = tr(M₂^k)`; recurrence `t(k+3) = 5t(k+2) + 5t(k+1) − t(k)`:

```
3, 5, 35, 197, 1155, 6725, 39203, 228485, 1331715, 7761797, 45239075, 263672645, …
```

(`t k = (3+2√2)^k + (3−2√2)^k + (−1)^k`; the subsequence `1, 3, 17, 99, 577, …` of
half-companion Pell numbers, OEIS A001333, is visible as `(t k − (−1)^k)/2`.)

`t k mod k` for `k = 0 … 11`:

```
k  :  2  3  4  5  6  7  8  9 10 11
t k mod k : 1  2  3  0  5  5  3  8  5  5
```

For every **odd prime** `k` in the list (3, 5, 7, 11) the residue equals `5 mod k`
(`2 ≡ 5 mod 3`, `0 ≡ 5 mod 5`, `5`, `5`) — while the odd composite `k = 9` gives `8 ≠ 5`.
This is `berg_trace_fermat` (proved by matrix Frobenius) and the compositeness test
`berg_trace_composite_witness`, run on `9` in `berg_nine_composite_witness`.

## 6. Eigenvalue distribution mod `p` (split versus inert)

Number of `λ ∈ ZMod p` with `(λ+1)(λ² − 6λ + 1) = 0`, i.e. the number of eigenvalues of `M₂`
in `𝔽_p`:

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 | 61 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| p mod 8 | 3 | 5 | 7 | 3 | 5 | 1 | 3 | 7 | 5 | 7 | 5 | 1 | 3 | 7 | 5 | 3 | 5 |
| #eigenvalues | 1 | 1 | 3 | 1 | 1 | 3 | 1 | 3 | 1 | 3 | 1 | 3 | 1 | 3 | 1 | 1 | 1 |

Exactly `3` eigenvalues when `p ≡ ±1 (mod 8)` (split, the pair `3 ± 2√2` is rational mod `p`)
and exactly `1` otherwise (inert, only `-1` survives).  Formalised as `berg_two_eigen_iff`,
`berg_two_eigen_split`, `berg_two_eigen_inert` in `EigenvaluesModP.lean`, together with the
statement that this dichotomy *is* the frequency dichotomy `p - 1` versus `p + 1`
(`berg_two_eigen_dichotomy_frequency`).
