# Computational Evidence

Exploratory data collected before formalisation.  Everything reported here was
subsequently either *proved* in Lean (see the four files in
`Catalog/NumberTheory/`) or is explicitly flagged as unverified exploration.

## 1. The Vieta value map `f(a,b) = 3ab(a+b)`

`a³ + b³ + (−a−b)³ = −3ab(a+b)`, so the represented integers of the identity are
exactly `±3ab(a+b)`.

Distinct values of `f` on `1 ≤ a ≤ b` below `N` (exploration, unverified):

| `N`      | # distinct Vieta values | spine bound `⌊√(N/6)⌋` (proved) | `N^{2/3}` |
|----------|------------------------|----------------------------------|-----------|
| `10⁴`    | 188                    | 40                               | 464       |
| `10⁵`    | 979                    | 129                              | 2154      |
| `10⁶`    | 4925                   | 408                              | 10000     |
| `10⁷`    | 24476                  | 1290                             | 46416     |

The empirical growth is `≈ 0.53 · N^{2/3}`, while the *provable* injective
subfamily gives only `√(N/6)`.  This gap is the origin of Conjecture 1 in
`FUTURE_DIRECTIONS.md`.

## 2. Multiplicity of a Vieta value

Number of pairs `1 ≤ a ≤ b` with `3ab(a+b) = v`, for `v ≤ 10⁶`
(exploration, unverified): histogram

```
multiplicity : 1     2    3   4  5  6
# values     : 4414  416  77  15  2  1
```

maximal multiplicity `6`, attained at `v = 443520`.  Multiplicity is therefore
small but unbounded-looking; the divisor mechanism behind it is *proved* in
`vieta_multiplicity_le_card_divisors` (`a ∣ v` and `a` determines `b`).

Explicit smallest collisions (both proved in Lean):

* `f(1,5) = f(2,3) = 90`, i.e. `1³+5³+(−6)³ = 2³+3³+(−5)³ = −90`;
* cube-scaled spine: `3·1³·15·16 = 3·2³·5·6 = 720`.

## 3. The dyadic subfamily `a = 2^i (i ≥ 1)`, `b` odd

All `20 997` values `3·2^i·b·(2^i+b) ≤ 10⁹` with `1 ≤ i ≤ 11`, `b` odd, are
pairwise distinct (exploration; the general statement is *proved* as
`dyadNat_inj`, using that the `2`-adic valuation of the value equals `i`).

## 4. The cube-digit box (three positive cubes)

Box `1 ≤ x ≤ t⁴`, `t⁶ ≤ y < 2t⁶`, `2t⁹ ≤ z < 3t⁹`.  For `t = 2`:

```
triples  : 524288  = t^19
distinct : 524288          (no collisions)
max value: 3 618 857 854  ≤ 36 t^27 = 4 831 838 208
```

matching the *proved* statements `boxSet_card`, `cubeSum_injOn`, `box_value_le`,
which give `t¹⁹` distinct sums of three positive cubes below `36 t²⁷`, i.e.
exponent `19/27 ≈ 0.7037`.

## 5. Residues

`n³ ≡ n (mod 6)`, hence every value of the residue-restricted box (all cube
roots `≡ 1 mod 6`) is `≡ 3 (mod 6)`, while every Vieta value is divisible by `6`
(*proved*: `escVal_mod_six`, `six_dvd_vietaValue`).  So those `136 t¹⁹` integers
are provably outside the Vieta value set.

## 6. Sequences

`3b(b+1)` (the spine, `6, 18, 36, 60, 90, …`) is six times the triangular
numbers; `ab(a+b)` values are the "Vieta cubes" pattern.  No OEIS identification
is claimed here — none was verified.
