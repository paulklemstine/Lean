# Computational evidence for the radical Montgomery 2-isogeny formulas

All computations below were run in Lean 4 (`#eval` over `ℚ` and `decide` over
`ZMod p`) before the corresponding theorems were formalised. Everything that
survived is now a machine-checked theorem in `Catalog/Cryptography/IsogenySIDH/`.

## 1. The radical parameter formula

Claim under test: for a Montgomery curve `E_A : y² = x³ + A x² + x` and any
`α` with `α² = A + 2`, the quotient by `⟨(0,0)⟩` has the generalized Montgomery
model

```
B v² = u³ + A' u² + u,   A' = (A+6)/(2α),   B = 1/(8α³),
u = (x-1)²/(2αx),        v = y(x²-1)/x².
```

Test function (over `ℚ`, with `y²` substituted by `x³ + A x² + x`):

```
chk2 A α x = B·v² − (u³ + A'u² + u)
```

| `A`   | `α`  | `x`   | `chk2` |
|-------|------|-------|--------|
| 7     | 3    | 2     | 0      |
| 7     | 3    | −5    | 0      |
| 7     | −3   | 3/7   | 0      |
| 14    | 4    | 11    | 0      |
| 1/4   | 3/2  | 2/3   | 0      |

Also `radTwoIso α (1, y) = (0,0)` was checked numerically, confirming that the
four-torsion point above the kernel maps to the new kernel generator.

→ formalised as `radTwoIso_mem`, `radTwoIso_four_torsion`.

## 2. Vanishing of the level-2 modular polynomial

With `j(A) = 256(A²−3)³/(A²−4)` and `Φ₂` the classical modular polynomial of
level two, we tested `Φ₂(j(A), j(A'))` where `A' = (A+6)/(2α)`:

| `A`   | `α`  | `Φ₂(j(A), j(A'))` |
|-------|------|-------------------|
| 7     | 3    | 0                 |
| 14    | 4    | 0                 |
| 23    | 5    | 0                 |
| −1    | 1    | 0                 |
| 1/4   | 3/2  | 0                 |
| 7     | −3   | 0                 |
| 7/4   | 5/2  | **≠ 0** (control: `α² ≠ A+2`) |

The control row is important: the identity is *not* vacuous — it genuinely uses
the radical condition `α² = A + 2`.

A second computation showed that `j(A')` simplifies to the *rational* function
`16(A²+12)³/(A²−4)²` (the radical cancels), which is why the identity is
provable as a polynomial identity in the single variable `t = A²`.

→ formalised as `jMont_radTwoParam`, `modPoly2_jMont_jQuot`,
`modPoly2_radical_step`.

## 3. Diagonal of `Φ₂`

`Φ₂(j,j) = −(j−8000)(j+3375)²(j−1728)` — verified as a `ring` identity, i.e. an
exact symbolic check rather than a sample. The roots are the CM `j`-invariants
of discriminants `−8`, `−7`, `−4`.

→ formalised as `modPoly2_diagonal_factor`, `radical_fixed_point_classification`.

## 4. Finite-field instances (exhaustive, `decide`)

Supersingular curves over `𝔽_p` with `p ≡ 3 mod 4`, counted exhaustively over
all `p²` pairs `(x,y)`:

| curve                        | field   | affine points | total (`+∞`) | `p+1` |
|------------------------------|---------|---------------|--------------|-------|
| `y² = x³ + x`                | `𝔽₇`   | 7             | 8            | 8     |
| `6y² = x³ + x² + x`          | `𝔽₇`   | 7             | 8            | 8     |
| `y² = x³ + x`                | `𝔽₂₃`  | 23            | 24           | 24    |
| `21y² = x³ + 19x² + x`       | `𝔽₂₃`  | 23            | 24           | 24    |

The second and fourth rows are the images of the first and third under one
radical step (`α = 3` in `𝔽₇`, `α = 5` in `𝔽₂₃`), so supersingularity is
preserved in these instances, as it must be.

→ formalised as `supersingular_seven_source/target`,
`supersingular_twentythree_source/target`, `radStep_seven`,
`radStep_twentythree`, `modPoly2_seven`, `modPoly2_twentythree`.

## 5. Counterexample hunt

* **Is the radical needed?** Yes — see the control row in §2.
* **Is `A² ≠ 4` needed?** Yes: at `A = ±2` the Montgomery curve is singular and
  `jMont`, `jQuot` both divide by zero. All statements involving `j` carry the
  hypothesis `A² − 4 ≠ 0`.
* **Is characteristic `≠ 2` needed?** Yes for every statement dividing by `2`,
  `4`, `16` or `256`; those hypotheses are carried explicitly as `(2 : K) ≠ 0`.
* **Does the walk backtrack?** No: the image of the non-kernel two-torsion is
  `(−α/2, 0) ≠ (0,0)`, checked symbolically and formalised as
  `radicalWalk_nonbacktracking`.
* **Can a step fix `j`?** Only at `j ∈ {1728, 8000, −3375}` (§3).

## 6. OEIS

No integer sequence is naturally attached to these results (the objects are
rational functions and modular polynomials), so no OEIS entry is claimed.

---

# Cycle 3 evidence: two-step backtracking, the missing neighbours, and level 3

All of the computations below were run in Lean (`#eval` over `ℚ`) *before* the
corresponding theorems were formalised; each surviving claim is now a
machine-checked theorem in `Catalog/Cryptography/IsogenySIDH/`.

## 6. Two-step return of a radical walk

With `jQuot A = 16(A²+12)³/(A²−4)²` and `A' = (A+6)/(2α)`, `α² = A+2`, we first
checked the closed form of the *second* step's target,
`jQuot A' = 4(A²+60A+132)³/((A+2)(A−2)⁴)`:

| `A` | `α` | `jQuot A'` | `4(A²+60A+132)³/((A+2)(A−2)⁴)` |
|-----|-----|------------|-------------------------------|
| 7   | 3   | 868327204/5625 | 868327204/5625 |

The radical cancels a second time, so the two-step map is rational in `A`.
Equating with `jMont A` gives the cube equation `u³ = v³` for
`u = A²+60A+132`, `v = 4(A²−3)(A−2)`, whose principal branch `u = v` factors as
`−(A−6)(4A²+15A+18) = 0`.  Numerically:

* `A = 6`: `jMont 6 = 287496` and `jQuot((6+6)/(2α)) = 287496` — a genuine
  backtracking example, so the exceptional set is not empty.
* roots of `4A²+15A+18`: exact polynomial division gives
  `256(A²−3)³ + 3375(A²−4) = (4A²+15A+18)(64A⁴−240A³+36A²+945A−1134)`,
  i.e. `jMont A = −3375` there (checked as an exact division with zero
  remainder).
* `btDen A = 0 ⟺ A² = 3 ⟺ jMont A = 0`.

→ formalised as `two_step_return_iff`, `backtrackPoly_factor`, `jMont_six`,
`jMont_eq_neg3375_of_quadratic`, `radical_two_step_nonbacktracking`.

**Counterexample hunt.**  The previous cycle guessed the exceptional set
`{1728, 8000, −3375, 287496}`.  The computation refutes it: `1728` and `8000`
are the *one*-step fixed points, while the two-step list contains `0` and does
not contain `1728` or `8000`.

## 7. The two missing 2-isogeny neighbours

First attempt (wrong): moving a non-rational two-torsion point `(r,0)` to the
origin gives another Montgomery model, and we mistakenly read off its
`j`-invariant as a *new* neighbour.  The numerical test flagged it immediately —
the value came out equal to `jMont A` itself, because the shifted model is a
model of the same curve.  Applying the radical step to the shifted model gives
the correct neighbour.  With `u = A·r` (so `u² + A²u + A² = 0`):

`jOther A u = 16(A² − 15u − 33)³ / ((−(u+2))(A² + u − 1)²)`

| `A`  | `u`    | `jMont A` | `jQuot A` | `jOther A u` |
|------|--------|-----------|-----------|--------------|
| 5/2  | −5/4   | 35152/9   | 1556068/81 | 2048/3 |
| 5/2  | −5     | 35152/9   | 1556068/81 | 28756228/3 |

and `Φ₂(jMont A, jOther A u) = 0` in both rows (and for `A = 13/6` as well).
The three neighbours are distinct, so the neighbourhood really has size three.

→ formalised as `modPoly2_jMont_jOther`, `two_isogeny_neighbourhood_eq`,
`two_isogeny_neighbours_card_eq_three`.

## 8. Level three: the Costello–Hisil formula and `Φ₃`

Test of the 3-isogeny parameter `A' = (A x₃ − 6x₃² + 6)x₃`, where `x₃` is a root
of the three-division polynomial `3x⁴ + 4Ax³ + 6x² − 1`:

| `x₃` | `A = (1−6x₃²−3x₃⁴)/(4x₃³)` | `A'` | `Φ₃(jMont A, jMont A')` |
|------|---------------------------|------|-------------------------|
| 2    | −71/32                    | −359/8 | 0 |
| 3    | −74/27                    | −506/3 | 0 |

The twist coefficient of the image model was identified numerically: with
`g(x) = (x r − 1)(x²r − 3xr² + x + r)/(x−r)³` the ratio
`(X³ + A'X² + X)/(x³ + Ax² + x)` equals `r²·g(x)²` at `x = 3, 5, 7`, so the
image satisfies `r² Y² = X³ + A'X² + X`.

Uniformising by `r = x₃` gives `A = (1−6r²−3r⁴)/(4r³)`,
`A' = (1+18r²−27r⁴)/(4r)`, and the discriminant factors come out as
`A²−4 = (r²−1)³(9r²−1)/(16r⁶)` and `A'²−4 = (9r²−1)³(r²−1)/(16r²)` — the
exponents `3` and `1` swap.  The `j`-invariants then reduce to
`P(r)³/(r¹²(r²−1)³(9r²−1))` and `Q(r)³/(r⁴(9r²−1)³(r²−1))`, verified at
`r = 2, 5`.

→ formalised as `threeIso_mem`, `mont3Source_disc`, `mont3Target_disc`,
`modPoly3_three_isogeny`.

## 9. Is there a radical 3-isogeny in Montgomery coordinates?

Exact division of the target's three-division polynomial by the dual kernel
`(3rX + 1)` leaves the cubic `X³ + 3r(2−3r²)X² + 3r²X − r`.  Depressing it, the
linear coefficient is `9r²(3r²−1)(1−r²)`, computed to be `−1188`, `−399600`,
`−71280/117649` at `r = 2, 5, 3/7`: nonzero, so **no single cube root produces
the next kernel** in this coordinate — except exactly on `3r² = 1`, where the
cubic collapses to `(X+r)³ − 4r/3`.

→ formalised as `threeDivPoly_target_factor`, `three_radical_obstruction`,
`three_radical_locus`.

## 10. Do `btNum` and `btDen` ever vanish together? (this cycle)

The degenerate branch of the two-step backtracking obstruction is
`btNum A = A² + 60A + 132 = 0` together with `btDen A = 4(A²−3)(A−2) = 0`.
Eliminating by hand: `A = 2` gives `btNum 2 = 256 = 2⁸`; `A² = 3` gives
`btNum A = 60A + 135 = 15(4A + 9)`, so `4A = −9`, hence
`48 = 16A² = 81`, i.e. `33 = 0`.

Numerical check of the resultant over small primes (the value of `btNum` at the
roots of `btDen`, i.e. the pair `(btNum(2), (4A+9) at A² = 3)`):

| char `p` | common root? | witnessing `A` | `jMont A` |
|---|---|---|---|
| 3 | yes | `A = 0` (since `A² = 3 = 0`) | `0` |
| 5 | yes | any `A` with `A² = 3` (e.g. `A ∈ 𝔽₂₅ ∖ 𝔽₅`) | `0` |
| 7 | no | — | — |
| 11 | yes | `A = 6` (`6² = 36 = 3`) | `0 = 287496 mod 11` |
| 13, 17, 19, 23 | no | — | — |

So the bad characteristics are exactly `3, 5, 11` (and `2`, excluded
throughout), i.e. the primes dividing `2·33·15`.  In `𝔽₂₅` the element `A` with
`A² = 3` also has `A + 2` a square: `N(A+2) = (2+A)(2−A) = 4 − 3 = 1`, and an
element of `𝔽₂₅` is a square iff its norm to `𝔽₅` is `±1`.  So the
characteristic-`5` counterexample is already realised over `𝔽₂₅`; the Lean
version is stated over `AlgebraicClosure (ZMod 5)`, which needs no
square-root bookkeeping.

→ formalised as `btNum_btDen_no_common_root`,
`radical_two_step_nonbacktracking_sharp`, `backtracking_at_zero_char_three`,
`backtracking_at_sqrt_three_char_five`, `backtracking_at_six_char_eleven`,
`char_five_backtracking_exists`.

## 11. The diagonal of `Φ₃` (this cycle)

Substituting `Y = X` in the level-3 modular polynomial gives the degree-six
integer polynomial

`Φ₃(X,X) = −X⁶ + 4464X⁵ + 2585778176X⁴ + 17800519680000X³
          − 769939996672000000X² + 3710851743744000000000X.`

Root search over the standard list of small CM `j`-invariants
(`0, 1728, 8000, −3375, 287496, 54000, −32768, −884736, 16581375, −12288000,
−147197952000, −262537412640768000`) returns exactly `0, 8000, 54000, −32768`;
successive synthetic division by `X`, `X − 8000`, `X − 54000`, `X + 32768`
leaves the quadratic `−X² − 24768X + 262144000`, whose roots are `8000` and
`−32768` again.  Hence

`Φ₃(j,j) = −j (j − 8000)² (j − 54000) (j + 32768)²,`

with the four roots being the CM `j`-invariants of discriminants
`−3, −8, −12, −11` — exactly the imaginary quadratic orders containing an
element of norm three.  The identity itself is not left to the numerics: it is
checked by `ring` in Lean.

→ formalised as `modPoly3_diagonal_factor`,
`three_isogeny_fixed_point_classification`, `three_isogeny_step_moves`,
`three_isogeny_diagonal_card_le_four`, `two_and_three_fixed_point_meet`.
