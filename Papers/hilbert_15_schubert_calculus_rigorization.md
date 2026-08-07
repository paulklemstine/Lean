# Computational Evidence — Schubert Calculus Rigorization

All computations below were run inside Lean (via `#eval` on the definitions that appear in
`Catalog/Geometry/SchubertCalculus/`), so they test *the very definitions used in the
theorems*, not a separate scratch model. The claims that survived are stated and proved as
theorems; the ones marked "verified in Lean" additionally appear as kernel-checked
statements (`by decide`) in the files.

## 1. Poincaré polynomial / Gaussian binomial `poincare R k n q`

`poincare R k n q = ∑_{S ⊆ {0,…,n-1}, #S = k} q ^ dimCell n S`.

| `k` | `n` | `q` | computed | closed form `[n choose k]_q` | status |
|----|----|----|----------|------------------------------|--------|
| 2 | 4 | 2 | 35 | (2⁴-1)(2³-1)/((2²-1)(2-1)) = 35 | verified in Lean (`poincare_two_four_two`) |
| 2 | 4 | 1 | 6 | `choose 4 2 = 6` | matches `poincare_one` |
| 2 | 5 | 3 | 1210 | (3⁵-1)(3⁴-1)/((3²-1)(3-1)) = 1210 | verified in Lean (`poincare_two_five_three`) |
| 3 | 6 | 2 | 1395 | Gaussian binomial `[6,3]_2 = 1395` | verified in Lean (`poincare_three_six_two`) |
| 2 | 4 | 5 | 806 | (5⁴-1)(5³-1)/((5²-1)(5-1)) = 806 | numerical check |

These are the point counts `#Gr(k,n)(𝔽_q)` predicted by the cell decomposition, and they
agree with the classical Gaussian binomial coefficients — evidence that the combinatorial
`dimCell` really is the Schubert cell dimension. The `q`-Pascal recursion
(`poincare_succ`) and the specialisation `q = 1` (`poincare_one`) are proved in general.

## 2. Palindromicity (Poincaré duality)

For `Gr(2,4)` the coefficient list of `∑_S q^{dimCell 4 S}` is `1, 1, 2, 1, 1`
(dimensions `0,1,2,2,3,4` of the six cells), which is palindromic of degree
`k(n-k) = 4`. This is the finite shadow of `poincare_palindromic`, proved in general via
the order-reversing involution on jump sets.

## 3. Degree of `Gr(2, n)` by Pieri chain counting

`degreeGr 2 n` counts saturated Pieri chains from the bottom Schubert cell to the top one.
Computed values:

| `n` | 3 | 4 | 5 | 6 | 7 | 8 |
|-----|---|---|---|---|---|---|
| `degreeGr 2 n` | 1 | 2 | 5 | 14 | 42 | 132 |

This is OEIS **A000108** (Catalan numbers) shifted by two, i.e. `deg Gr(2, m+2) = Cₘ`;
the values `1,2,5,14,42` are verified in Lean by `decide`, and the general statement is
proved as `degreeGr_two_eq_catalan`. The entry `n = 4` is the classical Schubert count:
two lines of `ℙ³` meet four general lines.

## 4. Counterexample hunt

* *Is the basic inequality `dim(W ∩ Eᵢ) + dim(W ∩ E'_{n-i}) ≤ dim W` ever violated?*
  No: it is proved in general (`finrank_inf_std_add_finrank_inf_opp_le`); the proof
  shows the failure mode would require `Eᵢ ∩ E'_{n-i} ≠ 0`, which cannot happen for
  opposite coordinate flags.
* *Is the transverse intersection ever empty or larger than a point?*
  Testing the `k = 2, n = 4` case: for each of the six index sets `S`, the set
  `{W : W transverse and jump set S}` is a single coordinate plane. The general
  statement (both non-emptiness and uniqueness) is `transverse_setOf_eq_singleton`.
* *Does `dimCell` change by more than one along a Pieri move?* Exhaustive checks for
  `n ≤ 6`, `k ≤ 3` show increments of exactly `1`; proved in general as
  `dimCell_of_mem_coverSet`.

## 5. What the evidence did **not** settle

The identity `#Gr(k,n)(𝔽_q) = poincare ℕ k n q` is verified numerically above for four
parameter sets, but is *not* proved here: a proof needs the reduced-echelon
parametrisation of each Schubert cell. It is recorded as Conjecture 1 in
`FUTURE_DIRECTIONS.md`.

## 6. Addendum — counts for flags in general position

After the coordinate-free theory was completed (`GeneralFlags.lean`, `FlagVariety.lean`), the
two enumerative counts were compared with the combinatorics:

| `n` | `k` | transverse `k`-subspaces (`ncard_transverse_eq_choose`) | `poincare ℕ k n 1` | transverse complete flags (`ncard_transverse_flags_eq_factorial`) |
|-----|-----|--------------------------------------------------------|--------------------|-------------------------------------------------------------------|
| 2 | 1 | 2 | 2 | 2 |
| 3 | 1 | 3 | 3 | 6 |
| 4 | 2 | 6 | 6 | 24 |
| 5 | 2 | 10 | 10 | 120 |
| 6 | 3 | 20 | 20 | 720 |

The middle two columns agree by the theorem `ncard_transverse_eq_poincare_one`
(`Catalog/Geometry/SchubertCalculus/Synthesis.lean`); the last column is the factorial
sequence OEIS **A000142**, proved in general as `ncard_transverse_flags_eq_factorial`.  Both
identities are theorems, not numerical observations: the table records the specialisations.

## 7. Addendum — finite-field point counts (supersedes §5)

Section 5 above recorded `#Gr(k,n)(𝔽_q) = poincare ℕ k n q` as unproved.  It is now a
theorem: `SchubertCalculus.card_grassmannian_eq_poincare`
(`Catalog/Geometry/SchubertCalculus/FiniteField.lean`), together with its cell-by-cell
refinement `SchubertCalculus.card_cell` (`CellCount.lean`) and the flag-variety analogue
`SchubertCalculus.card_completeFlag_eq_qFactorial` (`FlagCount.lean`).  The proof does not use
reduced echelon forms; it uses an affine fibration lemma (`card_extSet`) and induction along
the flag, plus a fibration over the space of ordered bases for the flag variety.

The following instances are kernel-checked in the Lean files (`by decide` / `norm_num` on the
proved general theorems), not merely computed in a scratch model:

| statement | value | Lean name |
|-----------|-------|-----------|
| `#Gr(2, 𝔽₂⁴)` | 35 | `card_grassmannian_two_four_two` |
| big Schubert cell of `Gr(2, 𝔽₂⁴)` | 16 = 2⁴ | `card_big_cell_two_four` |
| `#Fl(𝔽₂³)` | 21 | `card_completeFlag_two_three` |
| `∑_{w ∈ S₃} 2^{inv w}` | 21 | `mahonian_three_two` |

Independent numerical cross-check of the Mahonian identity (`#eval` over all of `S₄`):
`∑_{w ∈ S₄} 3^{inv w} = 2080` and `qFactorial 3 4 = 1 · 4 · 13 · 40 = 2080`.  The inversion
statistic of `S₄` has distribution `1, 3, 5, 6, 5, 3, 1` over inversion numbers `0,…,6`
(OEIS **A008302**, the Mahonian triangle), whose generating polynomial factors as
`(1)(1+q)(1+q+q²)(1+q+q²+q³)` — the content of `SchubertCalculus.sum_pow_invCount`.

## 8. Addendum — the ratio formula

The identity `[n choose k]_q · [k]_q ! · [n-k]_q ! = [n]_q !`
(`SchubertCalculus.poincare_mul_qFact`) was first checked numerically and then proved over an
arbitrary commutative semiring:

| `n` | `k` | `q` | `[n choose k]_q` | `[k]_q !` | `[n-k]_q !` | product | `[n]_q !` |
|-----|-----|-----|------------------|-----------|-------------|---------|-----------|
| 4 | 2 | 2 | 35 | 3 | 3 | 315 | 315 |
| 4 | 1 | 2 | 15 | 1 | 21 | 315 | 315 |
| 4 | 2 | 3 | 130 | 4 | 4 | 2080 | 2080 |
| 5 | 2 | 2 | 155 | 3 | 21 | 9765 | 9765 |

The `n = 4, k = 2, q = 2` row is kernel-checked in Lean as
`SchubertCalculus.poincare_mul_qFactorial_two_four`; the general statement is the theorem.
The geometric reading is that `Fl(𝔽₂⁴)` fibres over `Gr(2, 𝔽₂⁴)` with fibre
`Fl(𝔽₂²) × Fl(𝔽₂²)`: `315 = 35 · 3 · 3`.

---

## Addendum (cycle: q-Vandermonde and Coxeter length)

### 1. q-Vandermonde convolution

Exhaustive check of

`poincare ℕ k (m+n) q = ∑_{(a,b) ∈ antidiagonal k} q^{(m-a)b} · poincare ℕ a m q · poincare ℕ b n q`

for all `m, n ∈ {0,…,4}`, `k ∈ {0,…,5}`, `q ∈ {2,3}` (300 instances): **no counterexample**.
Two of these instances are recorded as theorems obtained *from* the convolution rather than by
direct evaluation:

| splitting | `k` | `q` | convolution value |
|---|---|---|---|
| `4 = 2 + 2` | 2 | 2 | `1·1·6 + 2·3·3 + 1·6·1 = 35` (`poincare_two_four_two_split`) |
| `6 = 4 + 2` | 3 | 2 | `1395` (`poincare_three_six_two_split`) |

The `q = 1` specialisation reproduces the classical Vandermonde convolution
(`choose_add_convolution`), and the `n = 1` specialisation reproduces `q`-Pascal
(`poincare_succ_of_add`) — two independent consistency checks of the exponent `(m-a)b`.

### 2. Inversions versus Coxeter length

Breadth-first search in `S₄` from the identity along the three adjacent transpositions
`s₀, s₁, s₂` reaches all `24` permutations; comparing the BFS distance (= minimal word length)
with `invCount` gives **0 mismatches**, and the eccentricity is `6 = 4·3/2 = ℓ(w₀)`.  This is
the computational shadow of `coxLength_eq_invCount` and `coxLength_revPerm_mul_two`.

Inversion distribution of `S₄` (the Mahonian numbers, OEIS A008302 read by rows):

| `ℓ` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| `#{w ∈ S₄ : ℓ(w) = ℓ}` | 1 | 3 | 5 | 6 | 5 | 3 | 1 |

Total `24 = 4!`; the generating function is `[4]_q! = (1)(1+q)(1+q+q²)(1+q+q²+q³)`, and the
palindromicity of the row is the complementary-cell identity `ℓ(w₀w) + ℓ(w) = 6`
(`invCount_revPerm_mul_add`).
