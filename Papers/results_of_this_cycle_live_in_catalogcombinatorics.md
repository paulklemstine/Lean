# Computational Evidence — Cycle 2 (GHZ / W normal forms)

All numbers below were produced by evaluating the definitions inside Lean (`#eval`) on
rational-valued amplitude tensors, i.e. by the same kernel that checks the proofs.  Rational
coefficients were used because `ℂ` is not computably representable; every identity tested is
polynomial with integer coefficients, so a rational test is a faithful specialisation.

Indexing convention: a tensor is written as the list
`[a₀₀₀, a₀₀₁, a₀₁₀, a₀₁₁, a₁₀₀, a₁₀₁, a₁₁₀, a₁₁₁]`.

## 1. The hyperdeterminant is the discriminant of the Alice pencil

Conjecture tested: `Det ψ = pencilB ψ² − 4·d₀ ψ·d₁ ψ`, where

```
d₀ = a₀₀₀a₀₁₁ − a₀₀₁a₀₁₀,  d₁ = a₁₀₀a₁₁₁ − a₁₀₁a₁₁₀,
pencilB = a₀₀₀a₁₁₁ − a₀₀₁a₁₁₀ − a₀₁₀a₁₀₁ + a₀₁₁a₁₀₀.
```

| tensor | `Det ψ` | `pencilB² − 4 d₀ d₁` |
|---|---|---|
| `[1,0,0,0,0,0,0,1]` (GHZ) | 1 | 1 |
| `[0,1,1,0,1,0,0,0]` (W)   | 0 | 0 |
| `[1,2,3,4,5,6,7,8]`       | 0 | 0 |
| `[1,0,0,1,0,1,1,0]`       | 4 | 4 |
| `[2,-1,3,5,-4,1,0,7]`     | 1537 | 1537 |
| `[1,1,1,1,1,1,1,1]`       | 0 | 0 |
| `[0,0,0,1,1,0,0,0]`       | 1 | 1 |
| `[3,1,4,1,5,9,2,6]`       | 273 | 273 |

Agreement in all 8 cases.  This is the identity later proved as
`ThreeQubitGHZ.hyperdet_eq_discriminant`.

Remark: `[1,2,3,4,5,6,7,8]` and the all-ones tensor have vanishing hyperdeterminant, which is a
useful reminder that the degenerate stratum is not a measure-zero curiosity for "nice looking"
integer tensors.

## 2. Relative invariance check (sanity check on the group action)

With `A = [[2,3],[1,4]]`, `det A = 5`, so `Det (A ⊗ 1 ⊗ 1)ψ` should equal `25 · Det ψ`:

| tensor | `Det (Aψ)` | `25 · Det ψ` |
|---|---|---|
| `[1,0,0,0,0,0,0,1]` | 25 | 25 |
| `[1,0,0,1,0,1,1,0]` | 100 | 100 |
| `[2,-1,3,5,-4,1,0,7]` | 38425 | 38425 |
| `[0,0,0,1,1,0,0,0]` | 25 | 25 |
| `[3,1,4,1,5,9,2,6]` | 6825 | 6825 |

## 3. Diagonalizing the pencil (Step 1 of the GHZ normal form)

Take `ψ = [1,0,0,1,0,1,1,0]`.  Computed: `Det ψ = 4`, `d₀ = 1`, `d₁ = −1`, `pencilB = 0`.
The quadratic form is `x² − y²`, whose roots are `(1, 1)` and `(−1, 1)`; the recipe in
`exists_diagonalizing_A` therefore returns `A = [[1,1],[−1,1]]` (`det A = 2 ≠ 0`).
Evaluating the transformed tensor gives

```
d₀(A·ψ) = 0 ,   d₁(A·ψ) = 0
```

exactly as predicted: both Alice slices become singular.  Since `Det(A·ψ) = 4·4 = 16 ≠ 0`, the
polarization `pencilB(A·ψ)` must then be `±4 ≠ 0`, which is what forces the two rank-one factor
pairs to be bases.

## 4. The degenerate stratum (Step 1 of the W normal form)

* `ψ = W = [0,1,1,0,1,0,0,0]`: `Det = 0`, `d₀ = −1`, `d₁ = 0`, `pencilB = 0`.
  The form is `−x²`, a perfect square with double root `(0,1)`; the recipe returns
  `A = [[0,1],[1,0]]` (swap the two slices, `det = −1`), after which `d₀ = d₁ = pencilB = 0`.
* `ψ = [1,0,0,0,2,3,5,0]`: `Det = 0`, `d₀ = 0`, `d₁ = −15`, `pencilB = 0`.
  This is already in the pre-normal shape `|000⟩ + 2|100⟩ + 3|101⟩ + 5|110⟩` used in the proof;
  the elementary move `A = [[1,0],[−2,1]]` clears the `|100⟩` amplitude and leaves
  `|000⟩ + 3|101⟩ + 5|110⟩`, i.e. a W-type tensor with `q = 3 ≠ 0`, `r = 5 ≠ 0`.

## 5. Counterexample hunt

The universal claims tested were
(i) `Det = pencilB² − 4 d₀ d₁` and
(ii) `Det(Aψ) = (det A)² Det ψ`.
No counterexample was found in the samples above; both are now theorems in
`Catalog/Logic/ThreeQubitGHZNormalForm.lean`, so no counterexample exists.

A genuine failure mode that the search *did* surface, and which shaped the formal proof, is that
the two-root construction breaks when `d₀ = 0` (division by zero in `r = (−b ± √Δ)/(2d₀)`).
The tensor `[0,0,0,1,1,0,0,0]` has `d₀ = 1`, but `[0,1,1,0,1,0,0,0]` after the swap has `d₀ = 0`
with `Det = 0`, and `[1,0,0,0,2,3,5,0]` has `d₀ = 0` with `Det = 0`.  Both normal-form proofs
therefore branch explicitly on `d₀ = 0`, with the roots `(1,0)` and `(d₁, −pencilB)` in the
degenerate branch.

## 6. No OEIS sequence

The objects here are polynomial invariants of a fixed-size tensor rather than a sequence, so no
OEIS lookup applies.

---

# Cycle 3 evidence (genericity, stabilizer, W-orbit closure)

All numbers below are literal `#eval` output from a rational-arithmetic replica of the
definitions (`hyperdetQ`, `localActQ`, the four families and the three families of `2 × 2`
minors), evaluated inside Lean before the corresponding statements were proved.

## 7. The GHZ-direction quartic

For `pert a t = a + t·(∣000⟩ + ∣111⟩)` the claim is that `t ↦ Det (pert a t)` is the **monic**
quartic

`t⁴ + 2(a₀₀₀ + a₁₁₁) t³ + ((a₀₀₀+a₁₁₁)² + 2·pencilB − 4 a₀₁₁a₁₀₀) t² + (2·pencilB·(a₀₀₀+a₁₁₁) − 4(d₀a₁₀₀ + a₀₁₁d₁)) t + Det a.`

With `a = [1,2,3,4,5,6,7,8]` (entries in the order `a₀₀₀ … a₁₁₁`), `(t, Det(pert a t), quartic a t)`:

```
(0, 0, 0), (1/4, -39/256, -39/256), (1/2, 9/16, 9/16), (3/4, 1017/256, 1017/256),
(1, 12, 12), (5/4, 6825/256, 6825/256)
```

With `a = W = [0,1,1,0,1,0,0,0]`:

```
(0, 0, 0), (1/4, 257/256, 257/256), (1/2, 33/16, 33/16), (3/4, 849/256, 849/256),
(1, 5, 5), (5/4, 1905/256, 1905/256)
```

The two columns agree in every sample — this is `pertPoly_eval`.  Note also that `a = [1,…,8]`
has `Det a = 0` yet `Det(pert a t) ≠ 0` already at `t = 1/4`: the quartic is not identically
zero, which is exactly the density mechanism.

Shrinking `t` along the W state, `(t, Det(pert W t))`:

```
(1/10, 4001/10000), (1/100, 4000001/10⁸), (1/1000, 4000000001/10¹²),
(1/10000, 4000000000001/10¹⁶), (1/100000, 4000000000000001/10²⁰)
```

i.e. `Det(pert W t) = 4t + t⁴`, nonzero for every `t ≠ 0` of modulus below any prescribed `ε`.

## 8. The four degenerating families

`Det` of `wFam0 s, wFamA s, wFamB s, wFamC s` for `s = 1,2,3,4,5`:

```
(0,0,0,0), (0,0,0,0), (0,0,0,0), (0,0,0,0), (0,0,0,0)
```

so all four families lie on the hypersurface identically in `s`.  Genuineness at `s = 1/10`,
reported as the triple of witnessing minors `(minor_A, minor_B, minor_C)` used in the formal
proofs:

```
wFam0 : (1/10, 1/10, 1/10)
wFamA : (-1/10, 1, 1)
wFamB : (1, 1/10, 1)
wFamC : (1/10, 1, 1/10)
```

Every entry is nonzero, so each family is genuinely entangled for `s ≠ 0` — and each of the
`s`-dependent entries shows *which* cut degenerates at `s = 0`: `wFam0` becomes fully product,
`wFamA/B/C` become biseparable across `A∣BC`, `B∣AC`, `C∣AB` respectively.

## 9. The stabilizer of GHZ

Diagonal triple `A = diag(2,5)`, `B = diag(3,7)`, `C = diag(1/6, 1/35)`
(so `A₀₀B₀₀C₀₀ = A₁₁B₁₁C₁₁ = 1`):

```
localAct A B C ghzBare = ghzBare   →  true
det A · det B · det C              →  1
```

Antidiagonal triple `A = antidiag(2,5)`, `B = antidiag(3,7)`, `C = antidiag(1/6, 1/35)`:

```
localAct A B C ghzBare = ghzBare   →  true
det A · det B · det C              →  -1
```

Two negative controls:

```
A = [[1,1],[0,1]], B = C = 1                              →  false   (not diagonal)
A = diag(2,5), B = diag(3,7), C = diag(1/7, 1/35)         →  false   (wrong product)
```

The sign `±1` of `det A · det B · det C` separating the two components is
`stab_det_eq_one_or_neg_one` / `stab_diagonal_iff_det_eq_one`, and the failure of the
non-diagonal and wrong-product triples is what the forward direction of `stab_ghzBare_iff`
proves in general.

## 10. Effective genericity (this cycle)

All data below is literal `#eval` output of a rational-arithmetic model of the
hyperdeterminant `Det` (the same degree-4 polynomial in the eight amplitudes, over `ℚ`) and of
the GHZ-direction perturbation `pert v t` (add `t` to the `000` and `111` amplitudes).  The six
test tensors are

```
v1 = [1,2,3,4,5,6,7,8]                      v2 = W = [0,1,1,0,1,0,0,0]
v3 = 0                                      v4 = GHZ = [1,0,0,0,0,0,0,1]
v5 = [3,-1,2,5,-4,0,1,1]                    v6 = [1/2,1/3,1/5,1/7,1/11,1/13,1/17,1/19]
```

(entries in the order `a₀₀₀ … a₁₁₁`), and the step sizes are `ε ∈ {1, 1/2, 1/10, 2}`.

### 10.1 The fourth-difference identity

For each tensor and each `ε`, the pair
`(Det(pert v (−ε)) − 4Det(pert v (−ε/2)) + 6Det v − 4Det(pert v (ε/2)) + Det(pert v ε),  (3/2)ε⁴)`:

```
v1 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
v2 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
v3 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
v4 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
v5 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
v6 : (3/2, 3/2)  (3/32, 3/32)  (3/20000, 3/20000)  (24, 24)
```

The two columns agree in all 24 experiments and the value is *independent of the tensor* —
this is `hyperdet_pert_fourth_difference`, and it is the reason the density rate is uniform.

### 10.2 The five-node maximum against the certified bound `(3/32)ε⁴`

Triples `(max over the five nodes of |Det|, (3/32)ε⁴, bound satisfied)`:

```
v1 : (24, 3/32, true)      (63/16, 3/512, true)     (879/10000, 3/320000, true)   (156, 3/2, true)
v2 : (5, 3/32, true)       (33/16, 3/512, true)     (4001/10000, 3/320000, true)  (24, 3/2, true)
v3 : (1, 3/32, true)       (1/16, 3/512, true)      (1/10000, 3/320000, true)     (16, 3/2, true)
v4 : (16, 3/32, true)      (81/16, 3/512, true)     (14641/10000, 3/320000, true) (81, 3/2, true)
v5 : (825, 3/32, true)     (10513/16, 3/512, true)  (5510481/10000, 3/320000, true) (1312, 3/2, true)
v6 : (55750291327039/23520996524025, 3/32, true)  (25179894946441/94083986096100, 3/512, true)
     (9709554434449/2352099652402500, 3/320000, true)  (2436416224248241/94083986096100, 3/2, true)
```

The bound holds in every case.  The row `v3 = 0` is the extremal one: there the five-node
maximum is exactly `ε⁴` (`1, 1/16, 1/10000, 16` for `ε = 1, 1/2, 1/10, 2`), which is
`hyperdet_pert_zeroAmp`.  So the constant `3/32` is off from optimal by exactly the factor
`32/3` on the worst tensor tested, and no constant larger than `1` is possible.

### 10.3 The quartic upper bound `32 M⁴`

Triples `(|Det v|, 32·(max entry modulus)⁴, bound satisfied)`:

```
v1 : (0, 131072, true)   v2 : (0, 32, true)      v3 : (0, 0, true)
v4 : (1, 32, true)       v5 : (528, 20000, true) v6 : (1282407361/94083986096100, 2, true)
```

This is the sample check of `hyperdet_norm_le_of_entries`; together with §10.2 it pins the
growth rate on a ball at exactly `ε⁴`.

### 10.4 The Lipschitz estimate `128 M³ r`

Triples `(|Det b − Det a|, 128 M³ r, bound satisfied)` for three perturbed pairs
(`a → b` changing one or two amplitudes by `1/10` resp. `1/5`):

```
([1..8] → [1..7, 8+1/10])                  : (321/100, 4251528/625, true)
(W → W + (1/10)(|000⟩+|111⟩))              : (4001/10000, 64/5, true)
(GHZ → GHZ + (1/5)(|001⟩+|110⟩))           : (49/625, 128/5, true)
```

The bound holds with room to spare, as expected of a crude triangle-inequality constant; what
matters for `exists_ghz_ball` is only that it is explicit and of the correct order `M³`.
