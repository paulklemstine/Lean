# Computational evidence (cycle 1, thread `th_576aa37a`)

All numbers below were produced by a small brute-force `𝔽₂` linear-algebra
script over the *explicit* hypercube incidence matrix and the Hamming
parity-check matrix, before the Lean development was written.  They are
**evidence, not proof**; every claim that survived was subsequently proved in
Lean (references given).  The script enumerates the full `2^E` edge space, so it
is limited to `n ≤ 3`.

## 1. The hypercube incidence complex `∂₁ : 𝔽₂^E → 𝔽₂^V`

| `n` | `#V = 2ⁿ` | `#E = n·2ⁿ⁻¹` | `rank ∂₁` | `2ⁿ − 1` | `k = #E − rank` | `dX` (min non-cut) | `dZ` (girth) | `d = min` |
|----|----|----|----|----|----|----|----|----|
| 2 | 4 | 4  | 3 | 3 | 1 | 1 | 4 | 1 |
| 3 | 8 | 12 | 7 | 7 | 5 | 1 | 4 | 1 |

Observations, and where each became a theorem:

* `rank ∂₁ = 2ⁿ − 1` exactly (corank one ⟺ connectivity) →
  `HypercubeIncidence.rank_incid_add_one`.
* `k = 1, 5` for `n = 2, 3`, matching the closed form `2ⁿ⁻¹(n−2)+1`
  (`1, 5, 17, 49, 129, 321, 769` for `n = 2,…,8`, cf. the `#eval` in
  `HypercubeIncidence.lean`) → `hyperComplex_numLogical_add`.
* **`dX = 1` in every computed case**, independent of `n`: a single edge is
  never a cut, because it always lies on a square.  This is the observation
  that motivated `HypercubeDistanceOne.hypercube_cssDistance_eq_one`.
* `dZ = 4` reproduces the previous cycle's girth computation — and the table
  shows directly that the girth is *not* the code distance, since
  `d = min(1, 4) = 1`.

No counterexample to `dX = 1` was found for `n = 2, 3`; the Lean proof
(`single_edge_not_coboundary`) shows it holds for all `n ≥ 2`.

## 2. The Hamming/Steane matrix `H = [[1010101],[0110011],[0001111]]`

* `H Hᵀ = 0` (self-orthogonality) — checked, then proved by `decide`.
* `dim ker H = 4` (16 codewords), `rank H = 3`.
* Row space (the simplex code) has weight distribution `0⁽¹⁾, 4⁽⁷⁾`; the full
  Hamming code has enumerator `{0:1, 3:7, 4:7, 7:1}`.
* Minimum weight of a codeword *outside* the row space: **3**.  Hence
  `dX = dZ = 3` and, by the `min(systole, cosystole)` theorem, `d = 3`.
  Formalised as `SteaneCode.steane_cssDistance_eq_three`; the `k = 1` count is
  `steane_numLogical_eq_one`.
* Because `rank H = 3 = #rows`, the Steane `X`-checks are *independent*, whereas
  the vertex checks of any graph always satisfy one linear relation.  This gap
  is what the representability obstruction
  `GraphRepresentability.IsGraphIncidence.rank_lt` formalises.

## 3. Sequences

`k(Qₙ) = 2ⁿ⁻¹(n−2)+1` gives `1, 5, 17, 49, 129, 321, 769, …` for `n ≥ 2`.  No
OEIS lookup was performed; the closed form is proved directly
(`hyperComplex_numLogical_closed`), so an identification would add nothing.

## 4. Counterexample hunt

The universal claim tested was: *"the girth of the underlying graph is the
distance of the homological code"*.  It fails at the very first instance
(`n = 2`: girth `4`, distance `1`) and in every case computed.  The failure is
structural — graph codes have no `Z`-checks, so their `X`-distance is the
minimum weight of a non-cut — and is proved in general in
`HypercubeDistanceOne.lean`.
