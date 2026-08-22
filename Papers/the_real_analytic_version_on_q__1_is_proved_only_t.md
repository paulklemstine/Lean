# Computational Evidence

Small-scale numerical exploration performed **before** formalisation, to test the two
conjectures that drive this cycle:

* **(C1)** the residue at `q = 1` of `∑ₙ P(n) qⁿ` equals `−P(−1)`;
* **(C2)** the pole order at `q = 1` equals `deg P + 1`.

All computations below were run with `#eval` over `ℚ` inside Lean; they are *exploratory*
evidence only.  The verified content of this cycle is the set of `sorry`-free theorems in
`Catalog/Physics/GradedTransitivityComplex.lean`,
`Catalog/Physics/GradedTransitivityResidue.lean` and
`Catalog/Physics/GradedTransitivityTrivial.lean`.

## 1. Hand computations of the Laurent expansion

| `P(n)` | closed form `∑ₙ P(n) qⁿ` | Laurent part at `q = 1` | residue | `−P(−1)` |
|---|---|---|---|---|
| `1` | `1/(1−q)` | `−1/(q−1)` | `−1` | `−1` |
| `n` | `q/(1−q)²` | `1/(q−1) + 1/(q−1)²` | `+1` | `+1` |
| `n²` | `q(1+q)/(1−q)³` | `−1/(q−1) − 3/(q−1)² − 2/(q−1)³` | `−1` | `−1` |

The pole orders `1, 2, 3` match `deg P + 1`, supporting **(C2)**.

## 2. Residue predicted by the Newton expansion

Writing `P = ∑ₖ Δᵏ P(0)·(x choose k)` and using `∑ₙ C(n,k) qⁿ = qᵏ/(1−q)^{k+1}`, whose
residue at `q = 1` is `(−1)^{k+1}`, gives the prediction

```
Res_{q=1} ∑ₙ P(n) qⁿ = ∑ₖ (−1)^{k+1} Δᵏ P(0).
```

`#eval` comparison of this quantity with `−P(−1)`:

| family | computed `∑ₖ (−1)^{k+1} Δᵏ P(0)` | `−P(−1)` | agree |
|---|---|---|---|
| `P(n) = nᵈ`, `d = 0..6` | `-1, 1, -1, 1, -1, 1, -1` | `-1, 1, -1, 1, -1, 1, -1` | ✓ |
| `P(n) = n^{\underline r}`, `r = 0..5` | `-1, 1, -2, 6, -24, 120` | `-1, 1, -2, 6, -24, 120` | ✓ |
| `P(n) = n² + 3n + 5` | `-3` | `-3` | ✓ |

No counterexample was found in this sample; both conjectures were subsequently proved
(`circleIntegral_polyZeta`, `order_polyZeta`).

## 3. Newton coefficients of the descending factorial

`Δᵏ (n ↦ n^{\underline r}) (0)` for `r = 0..4`:

```
r = 0 : [1]
r = 1 : [0, 1]
r = 2 : [0, 0, 2]
r = 3 : [0, 0, 0, 6]
r = 4 : [0, 0, 0, 0, 24]
```

i.e. `n^{\underline r} = r!·C(n,r)`, so the top Newton coefficient is `r!` — nonzero, which is
exactly the input needed for the pole order to be *exactly* `r + 1`
(`order_trivialAction`), and the alternating sum is `(−1)^r r!`, giving the residue
`(−1)^{r+1} r!` of the trivial-action partition function.

## 4. Sequences

The residues of the trivial-action family, `(−1)^{r+1} r!` for `r = 0,1,2,…`, are
`−1, 1, −2, 6, −24, 120, …`: the signed factorials (up to sign, OEIS A000142, the factorials
`1, 1, 2, 6, 24, 120`).  No new integer sequence appears in this cycle.

## 5. Later cycle: two-periodic grade counts and the second singularity

Hand computation of the partial-fraction decomposition of the two-periodic partition
function `Z(q) = ∑ₙ cₙ qⁿ` with `cₙ = c₀` for even `n` and `c₁` for odd `n`:

```
Z(q) = c₀/(1−q²) + c₁ q/(1−q²) = (c₀ + c₁ q)/((1−q)(1+q))
     = ((c₀+c₁)/2)/(1−q) + ((c₀−c₁)/2)/(1+q).
```

| `(c₀, c₁)` | `Res_{q=1} Z` | `Res_{q=−1} Z` | second pole present |
|---|---|---|---|
| `(1, 1)` | `−1` | `0` | no |
| `(2, 2)` | `−2` | `0` | no |
| `(1, 0)` | `−1/2` | `1/2` | yes |
| `(0, 1)` | `−1/2` | `−1/2` | yes |
| `(3, 1)` | `−2` | `1` | yes |

Two observations survived formalisation:

* the residue at `q = 1` is `−(c₀+c₁)/2`, the *average* of the periodic values — consistent
  with the eventually constant case `c₀ = c₁ = c` where it is `−c`;
* the residue at `q = −1` is `(c₀−c₁)/2`, which vanishes exactly when the sequence is in
  fact constant.  This is the conjectured root-of-unity value
  `−(ζ/m)·∑_{j<m} ζ^{−j} P_j(−1)` at `m = 2`, `ζ = −1`.

Both are now theorems (`circleIntegral_periodicGF_one`,
`circleIntegral_periodicGF_neg_one` in `Catalog/Physics/GradedTransitivityPeriodic.lean`),
as is the resulting detector `circleIntegral_neg_one_eq_zero_iff`.
