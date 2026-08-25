# Computational Evidence — Matrix-level modular action

All numbers below were produced with floating-point evaluation inside Lean (`#eval`,
double precision) *before* the formal proofs were attempted.  They are exploratory only;
the authoritative statements are the machine-checked theorems in
`Catalog/Shared/ModularCayley/MatrixModularAction.lean`.

Conventions used in the experiments (matching the Lean file):

* `cayley z = (1 + z i)/(1 - z i)` (extends the catalog `cayley` from `ℝ` to `ℂ`),
* `discHoro w = (1 - |w|²)/|w + 1|²`,
* `parMob t w` = Möbius action of `discPar t = !![1 + it/2, it/2; -it/2, 1 - it/2]`.

## 1. Horocycle dictionary `discHoro (cayley z) = Im z`

| `z`            | `discHoro (cayley z)` | `Im z` |
|----------------|-----------------------|--------|
| `0.3 + 1.7i`   | 1.700000              | 1.7    |
| `2.0 + 0.5i`   | 0.500000              | 0.5    |
| `-1.2 + 3.0i`  | 3.000000              | 3.0    |

Agreement to full displayed precision. Formalised as `discHoro_cayleyC`.

## 2. Cayley compatibility with translations

`cayley (z + t)` vs. `parMob t (cayley z)` at `t = 1.4`:

| `z`          | `cayley (z + t)`            | `parMob t (cayley z)`       |
|--------------|-----------------------------|-----------------------------|
| `0.3 + 1.7i` | `-0.469548 + 0.333988i`     | `-0.469548 + 0.333988i`     |
| `2.0 + 0.5i` | `-0.782766 + 0.492397i`     | `-0.782766 + 0.492397i`     |

Formalised at matrix level as `cayleyMat_transMat` and at Möbius level as
`cayleyC_add_ofReal`.

## 3. Horocycle invariance on the disc (`t = 0.9`)

| `w`           | `discHoro w` | `discHoro (parMob 0.9 w)` |
|---------------|--------------|---------------------------|
| `0.2 + 0.3i`  | 0.568627     | 0.568627                  |
| `-0.5 + 0.1i` | 2.846154     | 2.846154                  |

Formalised as `discPar_preserves_discHoro`, which in the proof is reduced to the single
quadratic identity `discPar_normSq_key`: `|den|² - |num|² = 1 - |w|²`.

## 4. Counterexample hunt: does `tr² = 4 det` alone give horocycle preservation?

Test matrix `N = !![1, 0; 1, 1]` (det 1, trace 2, hence parabolic).  At `z = i`:

```
Im (N · i) = Im (i/(i+1)) = 0.500000  ≠  1 = Im i
```

So the universal claim "parabolic ⟹ horocycle preserving" is **false**; the cusp-fixing
guard `c = 0` is required.  This counterexample is formalised exactly, with rational
arithmetic, as `parabolic_not_horocycle_preserving`, and the guarded statement is
`parabolic_fixing_infty_preserves_horocycles`.

## 5. Elliptic side: does Cayley linearise the catalog `spb`?

`x = 0.4`, `y = 1.3` (so `1 - xy = 0.48 ≠ 0`):

```
cayley (spb x y)      = -0.852327 + 0.523010i
cayley x * cayley y   = -0.852327 + 0.523010i
```

Formalised as `cayleyC_spb`, with the matrix counterpart `cayleyMat_spbMat`
(`spbMat a` is Cayley-conjugate to the rotation `rotMat a`).

## 6. No OEIS sequence

The objects here are continuous one-parameter families (translations, horocycles,
`SU(1,1)` parabolics), not integer sequences, so no OEIS lookup applies.
