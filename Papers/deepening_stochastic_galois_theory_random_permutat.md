# Computational Evidence

Direct small-case checks supporting the exact identities proved this cycle. All counts are
finite and were confirmed by explicit enumeration; the corresponding closed forms are the
statements formalized in `Catalog/Novelty/StochasticGaloisPermutation.lean`.

## 1. Number of `n`-cycles in `S_n` equals `(n-1)!`

| `n` | `#{n-cycles}` | `(n-1)!` | proportion `= 1/n` |
|-----|---------------|----------|--------------------|
| 2   | 1             | 1        | 1/2                |
| 3   | 2             | 2        | 1/3                |
| 4   | 6             | 6        | 1/4                |
| 5   | 24            | 24       | 1/5                |

The proportion column matches `1/n` exactly, since `#{n\text{-cycles}} \cdot n = n!`
(formalized as `nCycles_mul_eq_factorial`). This is the sequence of factorials shifted by
one, OEIS A000142 read as `(n-1)!`.

## 2. First moment of fixed points: total over `S_n` equals `n!`

For each `n`, summing the number of fixed points over all `n!` permutations:

| `n` | `∑_{σ∈S_n} #fix(σ)` | `n!` | expected `#fix = 1` |
|-----|---------------------|------|----------------------|
| 1   | 1                   | 1    | 1                    |
| 2   | 2                   | 2    | 1                    |
| 3   | 6                   | 6    | 1                    |
| 4   | 24                  | 24   | 1                    |

The total equals `n!` in every case, so the expected number of fixed points is exactly `1`
(formalized as `total_fixedPoints`). The per-point fiber counts `#{σ : σ i = i} = (n-1)!`
were also checked and drive the identity by double counting.

## 3. First moment of roots over `F_q` (small fields), matching the permutation side

Summing the number of roots over all `q^n` monic degree-`n` polynomials over `F_q`:

| `q` | `n` | `∑ #roots` | `q^n` |
|-----|-----|------------|-------|
| 2   | 2   | 4          | 4     |
| 2   | 3   | 8          | 8     |
| 3   | 2   | 9          | 9     |
| 3   | 3   | 27         | 27    |

The total equals `q^n` in every case, so the expected number of roots is exactly `1`,
matching the permutation-side expected number of fixed points. This is the content of the
imported `total_root_incidences` and of the cross-domain `bridge_fixedPoints_roots`.

## 4. Boundary check at `n = 0`

`S_0` has a single element (the empty permutation) with zero fixed points, so the total is
`0`, whereas `0! = 1`. The first-moment identity therefore genuinely requires `n ≥ 1`; the
same boundary appears on the polynomial side, where a degree-`0` monic polynomial is the
constant `1` with no roots. This confirms the `0 < n` hypothesis is necessary, not
cosmetic.

## 5. Counterexample hunt for the naive conjecture

The prompt's original expectation — that a random polynomial over a finite field has Galois
group `S_n` with high probability — fails at the very first nontrivial degree. For `n ≥ 3`
the Galois group of any polynomial over a finite field is cyclic, hence abelian, hence
never isomorphic to the non-abelian `S_n`. This structural obstruction (recorded in the
companion file `StochasticGaloisCyclic.lean`) is why the corrected object of study is the
Frobenius cycle type rather than the group.
