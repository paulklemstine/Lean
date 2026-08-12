# Computational evidence (exploration stage)

All numbers below come from floating-point exploration (Python, `cmath`, zero tolerance
`1e-9`). **They are not verified**; they were used only to select and sanity-check the
statements that are then proved in Lean. The verified statements are in
`Catalog/Bridges/FourierFunctorUncertainty.lean`, `Catalog/Bridges/MatrixUncertainty.lean`
and `Catalog/Bridges/SubgroupExtremals.lean`.

## 1. Donoho–Stark: is `|supp Φ| · |supp 𝓕Φ| ≥ N` tight?

Minimum of the support product over all nonzero `0/1` vectors on `ZMod N`:

| N | min product | number of 0/1 vectors attaining it |
|---|---|---|
| 2 | 2 | 3 |
| 3 | 3 | 4 |
| 4 | 4 | 7 |
| 5 | 5 | 6 |
| 6 | 6 | 12 |
| 7 | 7 | 8 |
| 8 | 8 | 15 |
| 9 | 9 | 13 |
| 10 | 10 | 18 |
| 11 | 11 | 12 |
| 12 | 12 | 28 |

The minimum always equals `N` exactly, so the bound is sharp for every tested `N`. The count of
extremal `0/1` vectors equals `∑_{d | N} d` (e.g. `28 = 1+2+3+4+6+12` for `N = 12`), and the
extremal vectors observed are exactly the indicators of **cosets of subgroups** (for `N = 4`:
`{0}, {1}, {2}, {3}, {0,2}, {1,3}, {0,1,2,3}`). The subgroup case is the observation formalised
as `SubgroupExtremals.donoho_stark_extremal` (`|supp Φ| · |supp 𝓕Φ| = d · m` for the indicator of
the multiples of `d` in `ZMod (d·m)`); the coset case is now also proved, as
`FourierSymmetries.donoho_stark_extremal_coset`, via translation invariance of the support pair.

2000 random complex vectors with about 40% nonzero entries on `ZMod 12` also gave minimum
product exactly `12`, consistent with the bound and with its sharpness.

## 2. Additive bound: minimum of `|supp Φ| + |supp 𝓕Φ|`

Over nonzero `0/1` vectors:

| N | min sum | N+1 | prime bound holds? | minimiser |
|---|---|---|---|---|
| 2 | 3 | 3 | yes | delta |
| 3 | 4 | 4 | yes | delta |
| 4 | 4 | 5 | **no** | `1{0,2}` |
| 5 | 6 | 6 | yes | delta |
| 6 | 5 | 7 | **no** | `1{0,3}` |
| 7 | 8 | 8 | yes | delta |
| 8 | 6 | 9 | **no** | `1{0,4}` |
| 9 | 6 | 10 | **no** | `1{0,3,6}` |
| 10 | 7 | 11 | **no** | `1{0,5}` |
| 11 | 12 | 12 | yes | delta |
| 12 | 7 | 13 | **no** | `1{0,4,8}` |
| 13 | 14 | 14 | yes | delta |
| 14 | 9 | 15 | **no** | `1{0,7}` |
| 15 | 8 | 16 | **no** | `1{0,5,10}` |
| 16 | 8 | 17 | **no** | `1{0,4,8,12}` |

Two patterns, both now settled in Lean:

* the additive bound `N + 1` holds exactly at the prime moduli in the sample — the
  two-element-support case is proved in `FourierUncertainty.tao_uncertainty_pair`;
* at composite `N` the minimum equals `min_{d | N} (d + N/d)`, attained by subgroup
  indicators. The upper bound half of this is proved in
  `SubgroupExtremals.additive_bound_le_divisor_sum` and
  `SubgroupExtremals.tao_bound_fails_of_composite`. The matching lower bound
  (`min_{d|N}(d + N/d)` is optimal) remains a conjecture; see `FUTURE_DIRECTIONS.md`.

## 3. Two-element supports at prime modulus

With `Φ` supported on `{0, 1}` and the second coefficient chosen to force a zero of the
transform (`c₂ = -ω`), the sampled data are:

| p | \|supp Φ\| | \|supp 𝓕Φ\| | sum | p+1 |
|---|---|---|---|---|
| 3 | 2 | 2 | 4 | 4 |
| 5 | 2 | 4 | 6 | 6 |
| 7 | 2 | 6 | 8 | 8 |
| 11 | 2 | 10 | 12 | 12 |
| 13 | 2 | 12 | 14 | 14 |

So `|supp 𝓕Φ| = p - 1` is attained: exactly one zero occurs, and never two. That is the
statement proved as `FourierUncertainty.card_dft_zeros_le_one` and
`FourierUncertainty.tao_dft_support_ge`. Generic coefficients give `|supp 𝓕Φ| = p`, i.e. the
degenerate case is a measure-zero event, which is why the bound `p - 1` (not `p`) is the correct
sharp one.

## 4. Naturality check

For `N = 8` and each unit `u ∈ (ZMod 8)ˣ`, the numerically computed matrices satisfy
`𝓕(Φ ∘ (u·)) = (𝓕Φ) ∘ (u⁻¹·)` to machine precision, while for the non-unit map `j ↦ 2j` the
identity fails. This matches the split between
`FourierUncertainty.dftNatIso` (naturality over the unit automorphisms) and the previous
cycle's disproof of unrestricted naturality.

---

## Cycle 2 exploration: rigidity of the equality case

*(Exploratory floating-point computation, not a verified artifact — the corresponding statements
are proved in Lean in `Catalog/Bridges/UncertaintyRigidity.lean`,
`Catalog/Bridges/ExtremalCosets.lean` and `Catalog/Bridges/CosetClassification.lean`.)*

Before formalising the classification of Donoho–Stark extremals we enumerated all vectors with
entries in `{0, 1, i, 2, -1}` for `N = 4` and `N = 6`, computed the discrete Fourier transform
numerically, and inspected those with support product exactly `N`:

| `N` | nonzero vectors tested | extremals found | modulus constant on the support | support a coset |
|-----|------------------------|-----------------|---------------------------------|-----------------|
| 4   | 624                    | 34              | yes (all)                       | yes (all)       |
| 6   | 15624                  | 56              | yes (all)                       | yes (all)       |

No extremal in the sample had two distinct moduli on its support, and in every case the
difference set of the support was closed under addition, i.e. the support was a coset. This is
what suggested proving flatness first and then extracting the subgroup from the phase relation;
both statements are now theorems for every modulus `N`.

---

## Cycle 3 exploration: a non-cyclic group

*(Exploratory `#eval` computation in Lean, exact integer arithmetic; it motivated but does not
verify the theorems. The verification is `Catalog/Bridges/AbelianCosetClassification.lean`.)*

Before formalising the classification over an arbitrary finite abelian group we tested it on the
smallest non-cyclic example, the Klein four-group `G = (ZMod 2)²`, whose characters take values
`±1`, so the Fourier transform is the Walsh–Hadamard matrix and all computations are exact
integer arithmetic. Enumerating all vectors with entries in `{-1, 0, 1}`:

| quantity | value |
|----------|-------|
| nonzero vectors tested | 80 |
| extremals (`\|supp f\| · \|supp 𝓖f\| = 4`) | 40 |
| extremals whose support is a coset of a subgroup | 40 (all) |
| extremals whose spectrum is a coset of a subgroup | 40 (all) |

The extremal supports occurring are the four singletons, the six two-element subsets — in
`(ZMod 2)²` *every* pair is a coset of one of the three order-two subgroups — and the whole
group. The first genuine failure of "a subset of the right size is automatically extremal"
therefore has to be looked for elsewhere: over `ZMod 4` the non-coset pair `{0, 1}` has spectrum
`(2, 1 - i, 0, 1 + i)`, so its support product is `2 · 3 = 6 > 4`, strictly above the bound.
This is exactly the dichotomy that
`AbelianCosetClassification.extremal_iff_modCosetIndicator` proves in general: the extremals are
precisely the modulated coset indicators, and everything else satisfies the strict inequality
(`AbelianCosetClassification.uncertainty_strict_of_not_modCosetIndicator`).
