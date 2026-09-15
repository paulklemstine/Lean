# Computational Evidence — the Euler Brick Tree

This note records the exploratory computations that guided the formalization in
`Catalog/Tropical/EulerBrickTree/`.  **Everything in this file is exploratory
numerics only**; the statements that are actually *proved* are the Lean theorems
in that directory (see the summary at the end for which numerical facts were
subsequently turned into machine-checked proofs).

## 1. The generator and the closed formulas

For a Pythagorean triple `(u,v,w)` (`u²+v²=w²`) set

```
brick(u,v,w) = ( u(4v²−w²) , v(4u²−w²) , 4uvw ).
```

Symbolic algebra (over `ℚ[u,v,w]/(u²+v²−w²)`) gives

| quantity | closed form |
|---|---|
| `x²+y²` | `(w³)²` |
| `x²+z²` | `(u(w²+4v²))²` |
| `y²+z²` | `(v(w²+4u²))²` |
| `x²+y²+z²` | `w²·(w⁴+16u²v²)` |

Small check: `(u,v,w) = (3,4,5)` gives `(117, 44, 240)`, the classical smallest
Euler brick, with face diagonals `125 = 5³`, `267`, `244`, and squared space
diagonal `25 · 2929 = 73225`, which is not a square (`270² = 72900`,
`271² = 73441`).

All four formulas are now Lean theorems (`brick_face_xy`, `brick_face_xz`,
`brick_face_yz`, `brick_space_diagonal`), so the reduction

> `brick(u,v,w)` is a perfect cuboid  ⟺  `w⁴ + 16u²v²` is a perfect square

is proved (`brick_perfect_iff`), not merely observed.

## 2. Counterexample hunt: is the quartic ever a square?

### 2a. Over all coprime pairs (no Pythagorean constraint)

`u⁴ + 18u²v² + v⁴ = s²` (the same quartic written without `w`) was tested for
all coprime `1 ≤ v ≤ u < 1500`: **no solutions**.

### 2b. Along the tree

Nodes of the Berggren tree of depth `≤ 10` (`(3^11−1)/2 = 88 573` primitive
triples) were tested for `c⁴ + 16a²b² = square`: **no solutions**.

### 2c. Over all primitive triples of bounded hypotenuse

All `31 819` primitive triples with `c ≤ 200 000`: **no solutions**.

So no perfect cuboid occurs in the Saunderson family in any range we searched;
this is consistent with the classical expectation that this parametric family
contains none.

## 3. Local obstruction spectrum

For a prime `p`, a node is *killed at `p`* when `c⁴+16a²b²` is a quadratic
nonresidue mod `p`.  Over the `88 573` nodes of depth `≤ 10`:

| p | fraction of nodes killed |
|---|---|
| 7 | 0.499 |
| 11 | 0.000 |
| 13 | 0.000 |
| 17 | 0.667 |
| 19 | 0.800 |
| 23 | 0.167 |
| 29 | 0.267 |
| 31 | 0.749 |
| 37 | 0.632 |
| 41 | 0.189 |
| 43 | 0.545 |
| **any of the above** | **0.99929** (63 nodes survive) |

Two structural points come out of this table.

* `p = 3, 5, 11, 13` never obstruct: modulo those primes the quartic is always a
  square on the Pythagorean cone.  This is why the Lean obstruction theorem uses
  `p = 7`, the smallest obstructing prime.
* Local obstructions are extremely efficient but *not* complete: a positive
  proportion of nodes survives every fixed finite set of primes, so a purely
  congruence-theoretic proof of "no perfect cuboid in the tree" cannot exist.
  The residual difficulty is genuinely global (the quartic
  `s² = t⁴+18t²+1` is a curve of genus one; its Jacobian is
  `y² = x(x+16)(x+20)`).

A clean sufficient condition extracted from the `p = 7` column, and proved in
Lean, is: if `u ≡ ±v (mod 7)` and `7 ∤ u`, then `c⁴+16a²b² ≡ 6u⁴ (mod 7)` is a
nonresidue, so the brick is not perfect.

A finite-state computation on residues modulo `7` shows more: the `12`-element
set of states `u ≡ v ≢ 0 (mod 7)` is *closed under the second generator* and
consists entirely of obstructed states (whereas no nonempty obstructed set is
closed under the first or third generator).  This is the combinatorial reason
behind the Lean theorem `obstructed_branch`: iterating the second generator from
such a node produces an infinite branch of the tree on which the space-diagonal
condition fails at *every* node.

## 4. The `720` law

Every Euler brick `(x,y,z)` found in the literature satisfies `720 ∣ xyz`
(e.g. `117·44·240 = 1 235 520 = 720 · 1716`).  The residue computations behind
the proof are: modulo `8` an odd edge forces the other two edges to be `0 mod 4`;
modulo `3` at least two edges vanish; modulo `5` at least one edge vanishes.
These are Lean theorems (`sixteen_dvd_of_odd_edge`, `nine_dvd_prod`,
`five_dvd_prod`, `seven_hundred_twenty_dvd`, `primitiveBrick_720_dvd`).

## 5. Can a congruence certify a subtree?

The mod-7 branch of `Branch.lean` raises the question of how thick the
obstructed region certified by a single modulus can be.  For a modulus `m` let
`Bad(m)` be the set of residue states `(a,b,c) mod m` with `a²+b² ≡ c²` for
which `c⁴+16a²b²` is a nonresidue mod `m`, and let `Bad(m, T)` be the greatest
subset of `Bad(m)` closed under the generators in `T ⊆ {A, B, C}` (computed as a
greatest fixed point).

| `m` | `|Bad(m)|` | `T = {B}` | any `T` with `|T| = 2` | `T = {A,B,C}` |
|---|---|---|---|---|
| 3, 4, 5, 8, 9, 11, 13, 16, 25 | 0 | 0 | 0 | 0 |
| 7 | 24 | 12 | **0** | 0 |
| 21 | 216 | 108 | **0** | 0 |
| 35 | 600 | 300 | **0** | 0 |
| 49 | 1176 | 588 | **0** | 0 |
| 56 | 2304 | 1152 | **0** | 0 |
| 63 | 2376 | 1188 | **0** | 0 |
| 77 | 2904 | 1452 | **0** | 0 |
| 91 | 4056 | 2028 | **0** | 0 |

So in every modulus we tested, a congruence certificate can be propagated along
one generator (hence along a branch) but never along two (hence never over a
subtree of positive growth rate).  For `m = 7` the escape is fast and uniform:
over all `343` residue states, one of the four words `ε, A, AA, AB` always
reaches a state where the quartic is a square mod `7`.  That statement is now a
Lean theorem (`mod7_escape_two_steps`), and with it
`mod7_no_binary_subtree`; the rest of the table is unverified numerics.

A related search: `u⁴ + 18u²v² + v⁴` (the value of the quartic after
substituting `w² = u²+v²`) is a perfect square for **no** pair `1 ≤ v < u ≤ 3000`
with `v ≠ 0`, which is the numerical support for Direction 1 of
`FUTURE_DIRECTIONS.md`.

## 6. What became machine-checked

| numerical observation | Lean theorem |
|---|---|
| the four closed formulas | `brick_face_*`, `brick_space_diagonal` |
| perfect ⟺ quartic square | `brick_perfect_iff`, `treeBrick_perfect_iff` |
| no perfect cuboid at depth `≤ 3` (40 nodes) | `no_perfect_cuboid_depth_le_three` |
| mod-7 column of the spectrum | `brick_not_perfect_of_mod7`, `infinite_obstructed_family` |
| the mod-7 state set closed under the second generator | `mod7_branch_step`, `obstructed_branch` |
| the mod-7 state set is *not* closed under two generators | `mod7_escape_two_steps`, `mod7_no_binary_subtree` |
| general local criterion | `brick_not_perfect_of_local_nonsquare` |
| `720 ∣ xyz` | `seven_hundred_twenty_dvd`, `primitiveBrick_720_dvd` |
| tree has exactly `3ⁿ` nodes / bricks at depth `n` | `depthNodes_card`, `brickLevel_card` |

The searches of §2b (depth `≤ 10`) and §2c (`c ≤ 200 000`), the full table of
§3, and the rows of §5 other than `m = 7` remain **unverified numerics**: only
the depth `≤ 3` portion and the mod-7 rows have been turned into Lean proofs.
