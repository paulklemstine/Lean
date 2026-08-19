# Computational evidence — Conjecture D (q-series rigidity / Molien-type dichotomy)

All numbers below were produced by a brute-force model inside Lean (`#eval` on an explicit list
of permutations), *before* the formal proofs were written.  For a finite group `G` of
permutations of a `k`-element set `X` we compute

* the fixed-point vector `(|X^g|)_{g ∈ G}` (the fixed-point q-series is
  `Φ(q) = ∑_g q^{|X^g|}`),
* the orbit counts `N_n = #((Fin n → X)/G) = (1/|G|) ∑_g |X^g|ⁿ` for `n = 0,…,5`
  (the coefficients of the orbit-counting generating function).

## 1. Small cases

| action | `|G|` | `|X|` | fixed-point vector | `N_0 … N_5` |
|---|---|---|---|---|
| `S₃` on 3 points | 6 | 3 | `[3,1,1,1,0,0]` | `1, 1, 2, 5, 14, 41` |
| `Z/6` regular on itself | 6 | 6 | `[6,0,0,0,0,0]` | `1, 1, 6, 36, 216, 1296` |
| `Z/3` rotating 3 points | 3 | 3 | `[3,0,0]` | `1, 1, 3, 9, 27, 81` |
| Klein `V₄` regular | 4 | 4 | `[4,0,0,0]` | `1, 1, 4, 16, 64, 256` |
| `Z/4` regular | 4 | 4 | `[4,0,0,0]` | `1, 1, 4, 16, 64, 256` |
| trivial group on `Bool` | 1 | 2 | `[2]` | `1, 2, 4, 8, 16, 32` |
| `Z/2` acting trivially on `Bool` | 2 | 2 | `[2,2]` | `1, 2, 4, 8, 16, 32` |
| `Perm Bool` on `Bool` | 2 | 2 | `[2,0]` | `1, 1, 2, 4, 8, 16` |

Closed forms visible in the data (all are instances of the Molien form
`N_n = ∑_v ρ(v) vⁿ` proved as `sum_fixDensity_pow`):

* `S₃` on 3 points: `N_n = (3ⁿ + 3)/6` for `n ≥ 1`; the first three values `1, 2, 5` are the
  Bell numbers, reflecting the 3-transitivity of `S₃` (`Bridges/MoonshineBellTransitivityBridge`).
* regular action of a group of order `m`: `N_n = m^{n-1}`, matching
  `card_orbits_pi_regular` in the catalog.
* `Perm Bool`: `N_{n+1} = 2ⁿ`, proved formally as `orbitCount_permBool`.

No OEIS lookup was performed (the environment is offline); the closed forms above are stated
instead, and each is checked against the table.

## 2. Counterexample hunt

**Hunt 1 — can the orbit-counting sequence recover the raw multiset `{|X^g|}`?**  No.
Rows 6 and 7 of the table have *identical* orbit-counting sequences (`2ⁿ`) but different
fixed-point multisets (`{2}` versus `{2,2}`) — the group orders differ.  Their *normalised*
distributions agree (point mass at `v = 2`).  This is exactly the boundary formalised as
`normalisation_necessary`, and it is why the converse direction of Conjecture D is stated for
the normalised distribution (or under `|G| = |H|`).

**Hunt 2 — can the data distinguish groups?**  No, and it is not meant to: rows 4 and 5
(`V₄` and `Z/4`, non-isomorphic groups) have identical q-series and identical orbit counts.
The dichotomy is about the pair (q-series, orbit series), not about the group.

**Hunt 3 — do a few coefficients suffice?**  Not a bounded number independent of `|X|`.
`S₃` on 3 points and `Z/6` regular have `N_0 = N_1 = 1` but `N_2 = 2 ≠ 6`.  So agreement up to
`n = 1` does not imply equal q-series, and some bound must grow with the number of distinct
fixed-point values.  The proved bound is `n ≤ max(|X|,|Y|)` (`orbitCount_determines_fixDensity`),
i.e. one coefficient per possible fixed-point value.

**Hunt 4 — kernel bound.**  In every row, `N_n · |G| ≥ |K| · |X|ⁿ` with `K` the set of elements
acting trivially, with equality exactly for the trivial actions (rows 6, 7).  Formalised as
`kernel_le_burnside`, `burnside_le_kernel_add` and `molien_detects_trivial`.

## 3. Why the algebraic core is believable

The engine is: a weighted power-sum functional `n ↦ ∑_v w(v) vⁿ` supported on `k` distinct
nodes vanishes identically iff it vanishes for `n = 0,…,k-1` (Lagrange interpolation /
Vandermonde).  Numerically: with nodes `{0,1,2,3}` the `4 × 4` Vandermonde matrix
`(vⁿ)_{v,n}` has determinant `12 ≠ 0`, so the first four moments already pin down the four
weights; three moments do not (e.g. `w = (1,-3,3,-1)` on `{0,1,2,3}` kills the moments
`n = 0,1,2` but gives `-6` at `n = 3`).  This is the sharpness underlying the
`max(|X|,|Y|) + 1` coefficient count.

## Cycle 4 evidence: regular actions and the blind spot

All of the numbers below are *proved*, not merely computed: they are the content of
`Catalog/Bridges/MolienRegularRigidity.lean`.

| action | fixed-point multiset `{|X^g|}` | q-series `Φ(q)` | orbit counts `N_0, N_1, N_2, N_3, …` |
|---|---|---|---|
| `G` on itself (general) | `{|G|, 0^(|G|−1)}` (`fixMultiset_regular`) | `q^{\|G\|} + (\|G\|−1)` | `1, 1, |G|, |G|², …` (`orbitCount_regular`) |
| `Z/4` on itself | `{4,0,0,0}` | `q⁴ + 3` | `1, 1, 4, 16, 64, …` (`orbitCount_witness`) |
| `Z/2 × Z/2` on itself | `{4,0,0,0}` | `q⁴ + 3` | `1, 1, 4, 16, 64, …` (`orbitCount_witness`) |

The last two rows agree in every entry although the groups are non-isomorphic
(`molien_blind_to_group_structure`), and the same coincidence holds for `Z/p²` versus
`Z/p × Z/p` for every `p ≥ 2` (`molien_blind_family`).  This is the counterexample hunt for the
question "does the orbit-counting series determine the group?"; the answer is no, in an infinite
family, so no strengthening of Conjecture D in that direction is possible.
