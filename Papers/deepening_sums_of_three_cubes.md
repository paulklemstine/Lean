# Computational Evidence — Sums of Three Cubes

All computations below were run inside Lean 4 (`#eval`, kernel/compiler arithmetic on `Int`)
before any theorem was stated. Every witness quoted here is *also* re-verified by the kernel
in `Catalog/Probability/ThreeCubes/Witnesses.lean`, so the numerical claims that survive into
the final artefact are machine-checked, not merely computed in a scratch script.

## 1. Small-case search

Exhaustive search over `|x|, |y|, |z| ≤ 150` for `0 ≤ n ≤ 113` with `n ≢ ±4 (mod 9)`.

Residues excluded a priori (cubes are `0, ±1 mod 9`, so `x³+y³+z³ ∈ {0,±1,±2,±3} mod 9`):

```
4, 5, 13, 14, 22, 23, 31, 32, 40, 41, 49, 50, 58, 59, 67, 68, 76, 77, 85, 86, 94, 95, 103, 104, 112, 113
```

All remaining `n ≤ 113` were found in the box **except**

```
30, 33, 39, 42, 51, 52, 74, 75, 84, 87, 102, 108, 110, 111
```

Extending the box (shell-by-shell, up to `|x|,|y|,|z| ≤ 1500`) additionally produced

```
51  = (-796)³ + 602³ + 659³
102 = 118³ + 229³ + (-239)³
108 = (-1165)³ + (-948)³ + 1345³
111 = (-1040)³ + 148³ + 1039³
```

Together with the large witnesses of §3 this settles **every** `n ≤ 113` with `n ≢ ±4 (mod 9)`,
which is what makes the theorem `ThreeCubes.hasse_of_abs_le_113` possible. The first value
left open is `114`.

## 2. Representative table (`0 ≤ n ≤ 50`, small witnesses)

| n | (x, y, z) | n | (x, y, z) |
|---|---|---|---|
| 0 | (0,0,0) | 26 | (-1,0,3) |
| 1 | (1,0,0) | 27 | (3,0,0) |
| 2 | (1,1,0) | 28 | (3,1,0) |
| 3 | (1,1,1) | 29 | (3,1,1) |
| 6 | (-1,-1,2) | 34 | (-1,2,3) |
| 7 | (-1,0,2) | 35 | (3,2,0) |
| 8 | (2,0,0) | 36 | (1,2,3) |
| 9 | (0,1,2) | 37 | (-3,0,4) |
| 10 | (1,1,2) | 38 | (-3,1,4) |
| 11 | (-2,-2,3) | 43 | (2,2,3) |
| 12 | (7,10,-11) | 44 | (-5,-7,8) |
| 15 | (-1,2,2) | 45 | (-3,2,4) |
| 16 | (2,2,0) | 46 | (-2,3,3) |
| 17 | (1,2,2) | 47 | (-30,-14,31) |
| 18 | (-2,-1,3) | 48 | (-26,-23,31) |
| 19 | (-2,0,3) | 24 | (2,2,2) |
| 20 | (-2,1,3) | 25 | (-1,-1,3) |
| 21 | (-14,-11,16) | | |

## 3. Large witnesses (all re-verified by the Lean kernel)

```
30  = 2220422932³ + (-2218888517)³ + (-283059965)³
33  = 8866128975287528³ + (-8778405442862239)³ + (-2736111468807040)³
39  = 134476³ + 117367³ + (-159380)³
42  = (-80538738812075974)³ + 80435758145817515³ + 12602123297335631³
52  = 60702901317³ + 23961292454³ + (-61922712865)³
74  = (-284650292555885)³ + 66229832190556³ + 283450105697727³
75  = 4381159³ + 435203083³ + (-435203231)³
87  = (-1972)³ + (-4126)³ + 4271³
102 = (-239)³ + 118³ + 229³
110 = 109938919³ + 16540290030³ + (-16540291649)³
84  = 41639611³ + (-41531726)³ + (-8241191)³
3   = 569936821221962380720³ + (-569936821113563493509)³ + (-472715493453327032)³
```

Several candidate values found in the literature-style recollection stage were **rejected**
by the `#eval` check (they did not evaluate to the claimed `n`) and were therefore not used;
only witnesses that evaluate correctly were kept, and every one of them appears in the Lean
file with a `norm_num` proof.

## 4. Counterexample hunt for the universal claims

* `∀ x y z : ZMod 9, x³+y³+z³ ∉ {4,5}` — checked exhaustively over all `9³ = 729` triples
  (`decide`); no counterexample. This is the mod `9` obstruction.
* `∀ a : ZMod p, ∃ x y z, x³+y³+z³ = a` — checked for `p = 2,3,5,7,11,13`; no counterexample.
  For `p = 7` (the smallest prime `≡ 1 mod 3` where two cubes are *not* enough) the sets are
  `C = {0,1,6}`, `C+C = {0,1,2,5,6}` (missing `3,4`), `C+C+C = 𝔽₇`. This is precisely the
  behaviour predicted by the Cauchy–Davenport bound `|C+C+C| ≥ min(p, 3|C|-2) = p`, and it is
  what the formal proof exploits.
* `u ≡ ±1 (mod 9) ⇒ u is a cube mod 3^k` — checked for `k ≤ 6` and `u` in the admissible
  residues; no counterexample. Conversely `u ≡ 4 (mod 9)` is never a cube mod `27`, matching
  the theory (the cube map on `ℤ₃ˣ` has image `{u : u ≡ ±1 mod 9}`).

## 5. Density data

The admissible residues mod `9` are `{0,1,2,3,6,7,8}`, i.e. `7` out of `9`, so the density of
locally solvable integers is exactly `7/9 ≈ 0.7778`. The excluded values are the numbers
`≡ ±4 (mod 9)`, beginning `4, 5, 13, 14, 22, 23, 31, 32, 40, 41, …`. We did not attempt to
attach OEIS identifiers, since the relevant sequences (sums of three cubes, and the list of
`n < 1000` still unresolved) come in several variants and we could not verify a specific ID
from inside this environment. The exact counting statement `#{n < 9N : n locally solvable} = 7N`
is formalised as `ThreeCubes.card_locallySolvable_block`.

## 6. Growth of the representation count for `n = 1`

Mahler's family `t ↦ (9t⁴, 3t-9t⁴, 1-9t³)` gives `2T+1` distinct representations with all
coordinates `≤ 12T⁴+9T³+3T+1`, i.e. `≫ B^{1/4}` representations of height `≤ B`. Sampled
values: `T = 1 → 3` representations of height `≤ 25`; `T = 3 → 7` of height `≤ 1225`;
`T = 10 → 21` of height `≤ 129031`. This is formalised as `ThreeCubes.card_repsBox_one` and
contrasts sharply with the conjectured `c·log B` for generic admissible `n`.

## 7. Rational cubes: the mod `9` obstruction over `ℚ`

For an obstructed `n` (i.e. `n ≡ ±4 (mod 9)`) a rational representation `n = x³+y³+z³` with
common denominator `d` is the same as an integral solution of `X³+Y³+Z³ = n d³`; and `3 ∣ d` is
forced, since otherwise `d³ ≡ ±1 (mod 9)` and `n d³ ≡ ±4 (mod 9)` would again be obstructed.
This is `ThreeCubes.denominator_three_dvd_of_obstructed`.

A search over `d ∈ {3, 6, 9, …}` and numerators `|X| ≤ 300` (the remainder `n d³ - X³` being
tested for being a sum of two integer cubes by factoring it as `(Y+Z)(Y²-YZ+Z²)` and checking
the resulting discriminant `(4q - s²)/3` for squareness) found a representation for **every**
one of the `26` obstructed `n` with `0 ≤ n ≤ 113`, always with `d = 3` or `d = 6`:

| `n` | `x` | `y` | `z` | | `n` | `x` | `y` | `z` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | −23 | 121/6 | 95/6 | | 59 | −3 | 13/3 | 5/3 |
| 5 | −2 | 7/3 | 2/3 | | 67 | −8 | 25/3 | 2/3 |
| 13 | 0 | 7/3 | 2/3 | | 68 | 11/6 | 7/2 | 8/3 |
| 14 | 2/3 | 7/3 | 1 | | 76 | −2/3 | 11/3 | 3 |
| 22 | −3 | 11/3 | −2/3 | | 77 | 2/3 | 4 | 7/3 |
| 23 | 1/2 | 7/3 | 13/6 | | 85 | −1 | 13/3 | 5/3 |
| 31 | −6 | 20/3 | −11/3 | | 86 | 0 | 13/3 | 5/3 |
| 32 | −46 | 121/3 | 95/3 | | 94 | 5/3 | 13/3 | 2 |
| 40 | 2/3 | 3 | 7/3 | | 95 | −8 | 29/3 | −20/3 |
| 41 | −2 | 11/3 | −2/3 | | 103 | −1 | 14/3 | 4/3 |
| 49 | −2/3 | 11/3 | 0 | | 104 | 0 | 14/3 | 4/3 |
| 50 | −2/3 | 11/3 | 1 | | 112 | 4/3 | 14/3 | 2 |
| 58 | −5 | 14/3 | 13/3 | | 113 | −2/3 | 4 | 11/3 |

Every entry of this table is kernel-checked inside
`ThreeCubes.rationalCubes_of_obstructed_le_113`; combined with the integral window
`ThreeCubes.hasse_of_abs_le_113` it yields `ThreeCubes.rationalCubes_window`: *every* integer
with `|n| ≤ 113` is a sum of three rational cubes. No counterexample to the rational statement
was found anywhere in the search.

Observation feeding Conjecture 1: no obstructed value required a denominator larger than `6`,
and `4` and `32 = 4·2³` (same cube class) are the only ones needing `6`. The smallest witness
`5 = (−2)³ + (7/3)³ + (2/3)³` is what powers the infinite family `5t³` (`3 ∤ t`) of integers
that are rationally but not integrally representable.

## 8. The full rational window `|n| ≤ 1000`

The same divisor-based search (now over denominators `d ≤ 24` and numerators `|X| ≤ 600`)
found a rational representation for **every** integer `0 ≤ n ≤ 1000`, with no exceptions.
Summary statistics of the certified table:

| statistic | value |
| --- | --- |
| values covered | `1001` (all of `0 … 1000`) |
| largest denominator needed | `12` (only `212` and `319`) |
| denominator distribution | `d=1`: 639, `d=2`: 57, `d=3`: 282, `d=4`: 4, `d=5`: 2, `d=6`: 12, `d=9`: 3, `d=12`: 2 |
| largest numerator | `3731` (for `n = 887`) |
| failures | none |

`987` of the `1001` values were already found with `d ≤ 6` and `|X| ≤ 150`; the remaining
`14` (`212, 319, 338, 401, 490, 509, 527, 626, 635, 663, 887, 940, 978, 985`) needed a wider
sweep. Examples of the harder ones:

* `212 = (-28/12)³ + (73/12)³ + (-9/12)³`,
* `887 = (-437/3)³ + (3731/3)³ + (-3729/3)³`,
* `114 = (-12)³ + (35/3)³ + (19/3)³` — the smallest integer whose *integral* status is open.

Every entry is kernel-checked in `ThreeCubes.rationalCubes_chunk_a` … `_chunk_d`, and the
window theorem is `ThreeCubes.rationalCubes_window_1000`. The nine integers below `1000` with
unknown integral status (`114, 165, 390, 579, 627, 633, 732, 921, 975`) are all covered:
`ThreeCubes.rationalCubes_open_cases_below_1000`.

## 5. Second cycle: the injective two-cube family and the four-cube identity search

### 5.1 Counting representable integers from below

The family used for `ThreeCubes.repCount_ge` is `(k, m) ↦ k³ + m³` with `K³ ≤ k < 2K³` and
`0 ≤ m ≤ K²`. Injectivity is forced by `m³ ≤ K⁶ ≤ 3k² < (k+1)³ - k³`. The cardinality was
checked inside Lean before the theorem was proved (`cubeValues` is a computable `Finset`):

| `K` | predicted `K³(K²+1)` | `#eval (cubeValues K).card` |
| --- | --- | --- |
| `2` | `8 · 5 = 40` | `40` |
| `3` | `27 · 10 = 270` | `270` |

so no collision occurs, exactly as the injectivity lemma `ThreeCubes.cube_pair_inj` predicts.
With `9K⁹` as the upper bound for the largest element this gives `repCount N ≫ N^{5/9}`.

### 5.2 Search for one-parameter four-cube identities

A quadruple of linear polynomials `xᵢ = aᵢt + bᵢ` satisfies

```
∑ xᵢ³ = (∑aᵢ³) t³ + 3(∑aᵢ²bᵢ) t² + 3(∑aᵢbᵢ²) t + ∑bᵢ³,
```

so `∑xᵢ³` is the linear polynomial `αt + β` with `α = 3∑aᵢbᵢ²`, `β = ∑bᵢ³` exactly when
`∑aᵢ³ = 0` and `∑aᵢ²bᵢ = 0`. Exhaustive search:

| search range | `∑aᵢ³ = 0` quadruples | families `(α, β mod α)` found |
| --- | --- | --- |
| `|aᵢ| ≤ 6, |bᵢ| ≤ 4` | `516` | `α = 6`: `β ≡ 0, 3`; `α = 18`: 6 classes |
| `|aᵢ| ≤ 9, |bᵢ| ≤ 7` | `1560` | `1703` distinct families |
| `|aᵢ| ≤ 12, |bᵢ| ≤ 14` | `1920` | none with `α ∣ 54` and `β ≡ ±2, ±16 (mod 54)` |

Coverage experiment: with the `1703` families of the second row, the integers in `[-100, 100]`
*not* representable by any family are

```
±4, ±5, ±13, ±14, ±22, ±23, ±31, ±32, ±38, ±40, ±41, ±49, ±50, ±52, ±58, ±59, ±67, ±68,
±70, ±76, ±77, ±85, ±86, ±92, ±94, ±95
```

i.e. exactly the classes `±4 (mod 9)` together with the sporadic values `38, 52, 70, 92`, which
are precisely the `±2 (mod 18)` values outside `±20 (mod 54)`. Note that the classes
`±4 (mod 9)` are *not* obstructed for four cubes (`4 = 1³+1³+1³+1³`); the search simply found no
linear family meeting them, which is itself a testable phenomenon (see Conjecture 5 in
`FUTURE_DIRECTIONS.md`). This is what produced the final statement
`ThreeCubes.isSumOfFourCubes_of_not_exceptional`: `38` of the `54` residue classes modulo `54`
are covered by `14` explicit identities, and the four classes `±2, ±16 (mod 54)` resisted every
linear family in the ranges searched.

All `14` identities are polynomial identities verified by `ring` in
`Catalog/Probability/ThreeCubes/FourCubes.lean`; each was first checked numerically at `81`
consecutive integer values of the parameter (more than the degree, hence conclusive).

---

## 6. Second continuation cycle

### 6.1 Extending the four-cube covering beyond modulus `54`

The search of §5.2 was re-run without the restriction `α ∣ 54`, recording for every family the
pair `(α, β mod α)`, and then the residues mod `M` covered by all families of modulus dividing
`M` were computed:

| `M` | classes uncovered | uncovered **and** `≢ ±4 (mod 9)` |
| --- | --- | --- |
| `18` | `6` | `2` — namely `2, 16` |
| `54` | `16` | `4` — namely `2, 16, 38, 52` |
| `108` | `30` | `6` |
| `216` | `54` | `6` — namely `38, 52, 70, 146, 164, 178` |
| `432` | `106` | `10` |

So passing from modulus `54` to modulus `216` shrinks the gap from `4/54` of all classes
(`16/216`) to `6/216`; the six survivors are symmetric, `±38, ±52, ±70 (mod 216)`. A greedy
set-cover over the families found produced a minimal system of **six new identities** — moduli
`72` (residues `16, 56`), `108` (residues `2, 106`) and `216` (residues `92, 124`) — which is
exactly what is formalised in `Catalog/Probability/ThreeCubes/FourCubesExtended.lean`. Each was
verified symbolically (expanding `∑(aᵢk+bᵢ)³` and checking that the `k³` and `k²` coefficients
vanish) before being handed to `ring`.

Targeted searches for the six survivors returned nothing:

| search | range | families found for `±38, ±52, ±70 (mod 216)` |
| --- | --- | --- |
| linear `aᵢk + bᵢ` | `|aᵢ| ≤ 20`, `|bᵢ| ≤ 50`, `α ∣ 216` | `0` |
| quadratic `aᵢk²+bᵢk+cᵢ` | `|aᵢ| ≤ 6`, `|bᵢ| ≤ 8`, `|cᵢ| ≤ 10`, `α ∣ 216` | `0` |

(The quadratic search imposes the five conditions `∑aᵢ³ = ∑aᵢ²bᵢ = ∑(aᵢ²cᵢ+aᵢbᵢ²) =
∑(bᵢ³+6aᵢbᵢcᵢ) = ∑(aᵢcᵢ²+bᵢ²cᵢ) = 0`, which is exactly what makes `∑xᵢ³` linear in `k`; it does
find plenty of families, e.g. `α = 108, β = -452` from `a = (-2,-2,2,2)`, `b = (-6,-4,2,8)`,
`c = (-5,2,-7,2)`, just none in the six target classes.)

### 6.2 The nested cube-gap boxes

For the `N^{19/27}` lower bound the three boxes must satisfy `y³+z³ < (x+1)³-x³` and
`z³ < (y+1)³-y³`. With `x ∈ [8K⁹, 16K⁹)`, `y ∈ [2K⁶, 4K⁶)`, `z ∈ [K⁴, 2K⁴)`:

| quantity | bound |
| --- | --- |
| `y³ + z³` | `< 64K¹⁸ + 8K¹²` |
| `3x²` | `≥ 192K¹⁸` |
| `z³` | `< 8K¹²` |
| `3y²` | `≥ 12K¹²` |
| `x³+y³+z³` | `< 4096K²⁷ + 64K¹⁸ + 8K¹² ≤ 4168K²⁷` |
| number of triples | `8K⁹ · 2K⁶ · K⁴ = 16K¹⁹` |

so `16K¹⁹` distinct values sit in `[0, 4168K²⁷]`; `19/27 = 0.7037…` against the upper density
`7/9 = 0.7777…`. For `K = 1` the boxes are `x ∈ [8,16)`, `y ∈ [2,4)`, `z ∈ [1,2)`, and the
`16` values `x³+y³+z³` were checked to be pairwise distinct by direct enumeration, matching
`ThreeCubes.card_cubeTripleValues`.

### 6.3 A quadratic mechanism for the six survivors

`(x+w)³ + (x−w)³ = 2x³ + 6xw²`, so with `w = 6s`

```
(x+6s)³ + (x−6s)³ + u³ + u³ = 2(x³+u³) + 216·x·s²,
```

which stays in one class modulo `216` while `s` varies. Searching `1 ≤ x ≤ 20`,
`|u| ≤ 30` for `2(x³+u³) ≡ r (mod 216)` gave a pair for every one of the six survivors:

| `r` | `(x, u)` | family |
| --- | --- | --- |
| `38` | `(3, -2)` | `648s² + 38` |
| `52` | `(3, -1)` | `648s² + 52` |
| `70` | `(2, 3)` | `432s² + 70` |
| `146` | `(12, -11)` | `2592s² + 794` |
| `164` | `(1, -3)` | `216s² - 52` |
| `178` | `(2, -3)` | `432s² - 38` |

Each identity was expanded symbolically and checked to be exact before being handed to `ring`;
they are formalised as `ThreeCubes.isSumOfFourCubes_class38` … `_class178`, and combined in
`ThreeCubes.exceptional_class_has_arbitrarily_large_four_cube`. Because `s²` is sparse these
families cannot *fill* a class — which is precisely why the linear search matters.
