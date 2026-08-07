# Computational evidence — the Berggren tree in the hyperbolic plane

All numbers below were produced with exact rational arithmetic (`fractions.Fraction`) or double
precision, *before* the corresponding Lean theorems were attempted.  Everything that is asserted
as a theorem in `Catalog/Computation/Berggren*.lean` is proved there without `sorry`; the tables
here only record the experiments that suggested those statements.

Notation: a Euclid seed is `(m, n)` with `0 < n < m`, `gcd(m,n) = 1`, `m + n` odd; its node is
`z(m,n) = (n + i)/m` in the upper half-plane; the base point is `i = z(1,0)`; `c = m² + n²` is the
hypotenuse of the associated Pythagorean triple `(m² - n², 2mn, m² + n²)`.

## 1. The master identity

Conjecture: `cosh d(z(m,n), z(m',n')) = 1 + ((n m' - n' m)² + (m - m')²) / (2 m m')`.

Checked against `acosh(1 + |z-w|²/(2 Im z Im w))` for all `1 ≤ m, m' ≤ 20`, `0 ≤ n < m`,
`0 ≤ n' < m'`: **maximum absolute error 2.9 · 10⁻¹⁵** (floating point noise).
Specialising to `(m',n') = (1,0)` reproduces the identity quoted in the plotting script,
`cosh d(i, z(m,n)) = (m² + n² + 1)/(2m)`.

→ `cosh_dist_node`, `cosh_dist_base_node`.

## 2. The residual (the dashed rings of the picture)

`ρ(m,n) = d(i, z(m,n)) - ½ log c`.  Over **all seeds with m ≤ 400** (24 293 seeds):

| quantity | value |
|---|---|
| min ρ | 3.157 · 10⁻⁶ (attained at `m = 397, n = 2`-type seeds, ρ → 0 as `n/m → 0`) |
| max ρ | 0.345 322 029… (attained at `n = m - 1`) |
| `½ log 2` | 0.346 573 590… |

So `0 < ρ < ½ log 2` with `½ log 2` approached but never attained — matching the annotation
"every node lies within ½ log 2 of its ring".  The upper bound *fails* in the limit `n = m`
(where `ρ → ½ log 2` exactly), which is why the Lean statement carries the hypotheses
`1 ≤ n`, `n + 1 ≤ m`.

→ `log_lt_dist_base_node`, `dist_base_node_lt_log`, `residual_mem_Ioo`.

## 3. Hunting the straight lines

Two visually different families were separated experimentally.

**(a) Level sets of `n`.**  For fixed `n`, the points `(n/m, 1/m)` all lie on the Euclidean ray
`x = n y`; the ratio `Re/Im = n` is constant, and the distance to the geodesic `Re = 0` came out
constant `= arsinh n` numerically.  More generally, `A n + B m + C = 0` gives the Euclidean line
`x = -B/A - (C/A) y`, an exact hypercycle. Example: the left spine `(k+2, k+1)` satisfies
`x + y = 1` exactly.

→ `isLeast_dist_vline`, `isLeast_dist_vline_of_linear`, `left_spine_hypercycle`.

**(b) Exact geodesics through the centre.**  Fitting a circle `x² + y² + Dx + Ey + F = 0` through
node triples, the triples with `E = 0` (circles centred on the real axis = geodesics) were exactly
those whose *radial invariant* `ϱ(m,n) = (m² - n² - 1)/(mn)` agrees.  Integer level sets of `ϱ`:

| `k` | first points of `m² - k m n - n² = 1` | seeds? | step `cosh` | `exp(step)` |
|---|---|---|---|---|
| 1 | (2,1), (5,3), (13,8), (34,21) | T F T T F T | 1.5 | 2.618033988… = φ² |
| 2 | (5,2), (29,12), (169,70), (985,408) | T T T T T T | 3 | 5.828427124… = (1+√2)² |
| 3 | (10,3), (109,33), (1189,360) | T F T T F T | 5.5 | 10.908326913… |
| 4 | (17,4), (305,72), (5473,1292) | T T T T T T | 9 | 17.944271909… |
| 5 | (26,5), (701,135), (18901,3640) | T F T T F T | 13.5 | 26.962912017… |

Collinearity `d(i,P) + d(P, S P) = d(i, S P)` held to `≤ 4.4 · 10⁻¹⁶` in every case; the step
`cosh` is `1 + k²/2` and `exp(step) = λ_k²` with `λ_k = (k + √(k²+4))/2` the metallic ratio.
The seed pattern is constant for even `k` and has period three for odd `k`.

→ `pell_collinear`, `dist_base_pellOrbit`, `exp_step_eq_metallic_sq`, `pellSeeds_infinite`,
`pellOrbit_parity_odd`, `seeds_on_geodesic_infinite`.

The `k = 2` family is exactly every second node of the Berggren middle ("Pell") spine
`(2,1) → (5,2) → (12,5) → (29,12) → …`, because `M ∘ M = S₂`.

## 4. Counterexample hunt: is the *whole* middle spine straight?

It looks straight in the plot, but the odd-indexed points satisfy `m² - 2mn - n² = -1`, not `+1`.
For the triangle `(i, (m,n), M(m,n))` on that branch the Gram invariant
`Φ = 2c₁c₂c₃ - c₁² - c₂² - c₃² + 1` was computed in exact rational arithmetic:

| `(m,n)` | (2,1) | (12,5) | (70,29) | (408,169) |
|---|---|---|---|---|
| `Φ` | 1 | 1 | 1 | 1 |

So the full spine is **never** collinear, and it misses by the *same* amount every time.
This falsified the naive conjecture "the Pell spine is a geodesic" and produced the sharper
theorem instead.

→ `gram_middle_spine_eq_one`, `middle_spine_not_collinear`.

## 5. The determinant behind the Gram invariant

Sampling triples of seeds and comparing `Φ` with the integer determinant
`Δ = det (nᵢ² + 1, nᵢmᵢ, mᵢ²)`:

| triple | `Φ` | `Δ` | `(Δ/(2m₁m₂m₃))²` |
|---|---|---|---|
| (1,0),(2,1),(5,2) | 1 | 20 | 1 |
| (3,1),(7,2),(5,4) | 81/25 | -378 | 81/25 |
| (1,0),(2,1),(13,8) | 0 | 0 | 0 |
| (4,3),(9,2),(11,5) | 15389929/156816 | 7846 | 15389929/156816 |

Perfect agreement in every sample, which is the identity `Φ = (Δ / 2m₁m₂m₃)²`
(`gram_eq_seedDet_sq`) and, since `Δ` is an integer, the quantization bound
`Φ ≥ 1/(2m₁m₂m₃)²` for non-collinear integer seeds (`gram_quantization`).

## 6. OEIS

The first coordinates of the `k = 1` conic are `1, 2, 5, 13, 34, 89, …` — odd-indexed Fibonacci
numbers, [A001519](https://oeis.org/A001519); the second coordinates are `0, 1, 3, 8, 21, 55, …`
= [A001906](https://oeis.org/A001906).  For `k = 2` one gets `1, 5, 29, 169, 985, …`
= [A001653](https://oeis.org/A001653) (NSW / half-companion Pell numbers) with second coordinates
`0, 2, 12, 70, 408, …` = [A001542](https://oeis.org/A001542).  In general the `k`-th family is the
even-index subsequence of the `k`-metallic (`x_{j+1} = k x_j + x_{j-1}`) recurrence.

## 7. Cycle 4: pencil geometry, ideal endpoints, density and growth

Numerical check of the three cycle-4 theorems (`Catalog/Computation/BerggrenLinePencil.lean`).

Hypotenuse growth `λ_k^{4j}/2 < c_j < λ_k^{4j}` on the first orbits:

| k | j | (m,n) | c = m²+n² | λ_k^{4j} | λ_k^{4j}/2 | inside? |
|---|---|---|---|---|---|---|
| 1 | 1 | (2,1) | 5 | 6.854 | 3.427 | yes |
| 1 | 2 | (5,3) | 34 | 46.979 | 23.490 | yes |
| 1 | 3 | (13,8) | 233 | 321.997 | 160.999 | yes |
| 1 | 4 | (34,21) | 1597 | 2207.000 | 1103.500 | yes |
| 2 | 1 | (5,2) | 29 | 33.971 | 16.985 | yes |
| 2 | 2 | (29,12) | 985 | 1153.999 | 577.000 | yes |
| 2 | 3 | (169,70) | 33461 | 39202.000 | 19601.000 | yes |
| 3 | 1 | (10,3) | 109 | 118.992 | 59.496 | yes |
| 3 | 2 | (109,33) | 12970 | 14159.000 | 7079.500 | yes |
| 3 | 3 | (1189,360) | 1543321 | 1684802.0 | 842401.0 | yes |

Ideal endpoints: the slopes `n_j/m_j` converge to `1/λ_k`.

| k | slopes n_j/m_j | limit 1/λ_k |
|---|---|---|
| 1 | 0.5, 0.6, 0.615385, 0.617647 | 0.618034 |
| 2 | 0.4, 0.413793, 0.414201, 0.414213 | 0.414214 (= √2 − 1) |
| 3 | 0.3, 0.302752, 0.302775, 0.302776 | 0.302776 |

The observed error is `O(m_j^{-2})`, matching the proved bound
`|n_j/m_j − 1/λ_k| ≤ m_j^{-2} ≤ (j+1)^{-2}` (`pellOrbit_ratio_error`).

Node density: with `2 log λ₁ = 0.9624…`, a ball of radius `R = 5` around the centre contains
`⌊5/0.9624⌋ + 1 = 6` nodes of the golden line, and `⌊5/1.7627⌋ + 1 = 3` nodes of the silver
line — matching `card_pellOrbit_within_radius`.

Separation: subtracting the two conic equations for `k ≠ k'` gives `(k − k') m n = 0`, so a
common point must have `n = 0`; the only shared point of the pencil is therefore the centre
`(1,0)`.  This is exactly the proved statement `lines_meet_only_at_base`.

---

# Cycle 5 evidence — horocycles, the metallic gap and the counting law

**Horocycles carry few seeds.**  A horocycle based at `∞` is the locus `im = t`, i.e. `m = 1/t`
constant, so the seeds on it are the `n < m` coprime to `m` of opposite parity:

| m | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|----|----|----|
| # seeds | 1 | 1 | 2 | 2 | 2 | 3 | 4 | 3 | 4 | 5 | 4 |

Always finite (`≤ m - 1`), in sharp contrast with the geodesics of the pencil, each of which
carries infinitely many (`seeds_on_geodesic_infinite`).  This is the numerical content of
`seeds_on_horocycle_finite` / `horocycle_vs_geodesic`.

**Metallic data.**  `λ_k = (k+√(k²+4))/2`, spacing `2 log λ_k`, growth exponent `λ_k⁴`:

| k | λ_k | 2 log λ_k | λ_k⁴ |
|---|-----|-----------|------|
| 1 | 1.618034 | 0.962424 | 6.8541 |
| 2 | 2.414214 | 1.762747 | 33.9706 |
| 3 | 3.302776 | 2.389526 | 118.9916 |
| 4 | 4.236068 | 2.887271 | 321.9969 |
| 5 | 5.192582 | 3.294462 | 726.9986 |

The spacing is strictly increasing with infimum `0.9624…` at `k = 1`
(`pellStepLength_strictMono`, `two_log_goldenRatio_le_pellStepLength`), and `λ_k⁴ > 6` for all
`k ≥ 1` (`metallicRatio_pow_four_gt_six`).

**Counting.**  Nodes in the ball `R = 10`, `N_k = ⌊10/(2 log λ_k)⌋ + 1`:
`N_1 = 11, N_2 = 6, N_3 = 5, N_4 = 4, N_5 = 4, N_6 = … = N_10 = 3`, total `45` over `k ≤ 10`;
the sum bound `R Σ (2 log λ_k)⁻¹ ≤ Σ N_k ≤ R Σ (2 log λ_k)⁻¹ + K` of `sum_lineCount_bounds`
gives `38.85 ≤ 45 ≤ 48.85` here.

# Cycle 6 evidence — rational lines

Grouping all Euclid seeds with `m ≤ 4000` by radial value `ϱ = (m²-n²-1)/(mn)` gives the
most populated lines:

| ϱ | seeds | discriminant a²+4b² |
|---|-------|---------------------|
| 1   | (2,1), (13,8), (34,21), (233,144), (610,377) | 5 |
| 2/3 | (3,2), (25,18), (111,80), (949,684) | 40 |
| 1/2 | (4,3), (41,32), (260,203), (2705,2112) | 17 |
| 2   | (5,2), (29,12), (169,70), (985,408) | 8 |
| 7/2 | (4,1), (241,64), (1028,273) | 53 |
| 1/3 | (6,5), (85,72), (870,737) | 37 |
| 3/2 | none | 25 = 5² |

so the lines with non-integral `ϱ` are just as visible as the integral ones.  For `ϱ = 2/3` the
unit is `(s,u) = (25,6)` (`25² − 2·25·6 − 9·36 = 1`) and the step matrix `[[25,18],[18,13]]`
reproduces the observed points; distances from the centre are
`1.4910, 3.6369, 5.1279, 7.2738, …`, two interleaved progressions of common difference
`arcosh 19 = 3.6369…`, and the orbit of the centre `(1,0) → (25,18) → (949,684) → (36037,25974)`
sits at `0, 3.6369, 7.2738, 10.9107 = j · arcosh 19`, matching `dist_base_ratOrbit` exactly.
The single empty line in the table, `ϱ = 3/2`, is precisely the one with square discriminant —
the degenerate case isolated by `ratConic_three_two_empty`.

# Cycle 7 evidence — the square-discriminant case

**Question.**  Cycle 6 left open what happens on a line `ϱ = a/b` whose discriminant `a² + 4b²`
*is* a perfect square; `ϱ = 3/2` (discriminant `25`) was empty, and the conjecture in
`FUTURE_DIRECTIONS.md` only claimed finiteness.

**Sweep 1 (over nodes).**  For every pair `0 < n < m ≤ 4000` — `7 998 000` pairs — the reduced
radial value `a/b = (m²-n²-1)/(mn)` was formed and `a² + 4b²` tested for squareness.
**0 hits.**  So no node of the picture sits on a square-discriminant line, up to `m = 4000`.

**Sweep 2 (over lines, exhaustive per line).**  For every `b ≤ 199` and every `0 ≤ a ≤ 1999` with
`a² + 4b²` square, all factorizations `P · Q = 4b²` (both signs) were enumerated and solved back
for `(m, n)` via `n = (Q-P)/(2d)`, `m = (P+Q+2an)/(4b)`.  Since every point of the conic produces
such a factorization, this is an exhaustive search on those lines.  **0 solutions** with
`m, n > 0`.

**Explanation found and proved.**  Write `a² + 4b² = d²`.  In the primitive case the classical
parametrization gives `a = f² - e²`, `b = e f`, `d = e² + f²` with `gcd(e,f) = 1`, and the conic
factors:

  `b m² - a m n - b n² = b  ⟺  (e m - f n)(f m + e n) = e f`.

Hence `f m + e n` divides `e f`; writing that divisor as `A · B` with `A ∣ e`, `B ∣ f`, one has
`B ∣ f m + e n` and `B ∣ f m`, so `B ∣ e n`, and `gcd(B,e) = 1` forces `B ∣ n`.  Therefore
`f m + e n = A B ≤ e n`, which is impossible for `f, m > 0`.  So the square case is not merely
finite — it is **empty** (`ratConic_pos_empty_of_isSquare_disc`).

Sample square-discriminant lines, all empty:

| ϱ = a/b | disc a²+4b² | (e,f) | factorized conic          |
|---------|-------------|-------|---------------------------|
| 0/1     | 4 = 2²      | (1,1) | `(m - n)(m + n) = 1`      |
| 3/2     | 25 = 5²     | (1,2) | `(m - 2n)(2m + n) = 2`    |
| 8/3     | 100 = 10²   | (1,3) | `(m - 3n)(3m + n) = 3`    |
| 5/6     | 169 = 13²   | (2,3) | `(2m - 3n)(3m + 2n) = 6`  |
| 16/15   | 1156 = 34²  | (3,5) | `(3m - 5n)(5m + 3n) = 15` |

**Corollary tested numerically.**  `(m² - n² - 1)² + (2mn)²` was checked to be a non-square for all
`0 < n < m ≤ 4000` (the same `7 998 000` pairs), matching the theorem
`radialDiscriminant_not_isSquare`.

# Cycle 8 evidence — alignment classes

Grouping the nodes by exact alignment with the centre (vanishing Cayley–Menger determinant
`seedDet 1 0 …`) reproduces exactly the grouping by radial value, as `alignment_iff_ratConic`
predicts.  First classes, with the members found for `m ≤ 4000`:

| node   | ϱ    | further Euclid seeds in the class      | disc |
|--------|------|----------------------------------------|------|
| (2,1)  | 1    | (13,8), (34,21), (233,144), (610,377)  | 5    |
| (3,2)  | 2/3  | (25,18), (111,80), (949,684)           | 40   |
| (4,3)  | 1/2  | (41,32), (260,203), (2705,2112)        | 17   |
| (5,2)  | 2    | (29,12), (169,70), (985,408)           | 8    |
| (6,5)  | 1/3  | (85,72), (870,737)                     | 37   |

The lists show the genuine Euclid seeds (coprime, opposite parity); an alignment class also
contains integral nodes that are not seeds — on the `ϱ = 1` line, for instance, `(5,3)`, `(89,55)`
and `(1597,987)` sit between the seeds listed above.

Every discriminant in the census is a non-square, as cycle 7 now proves it must be, and each class
is infinite (`alignmentClass_infinite`) even though only its first few members fall inside the
search window.  The classes are pairwise disjoint (`alignmentClass_eq_of_mem`), so the picture
really does decompose into disjoint infinite straight lines through the centre.
