# Computational Evidence — ET-HINTS-FULL (paper 148, round 40 #4)

All numbers below come from exact rational arithmetic in Python (`fractions.Fraction`) as
exploration. The Lean files only certify the claims listed as "Lean" in the last column.

Model: min-law prior \(P(J=i+1) = (2(M-1-i)+1)/M^2\) (where \(J=\min(p,q)\)). The hint names a window, and trust \(\alpha\) puts mass
\(\alpha\) on the window and \(1-\alpha\) off it, each spread in proportion to the prior.
`E_opt` = cost of the sorted (greedy) posterior; "committed" = scan the window first, then the rest in ascending order.

## 1. Hedging hump (T7): max of `E_opt(α)` on the grid α = k/200

| M | x | placement | blind | peak E_opt | at α |
|---|---|---|---|---|---|
| 512 | 1/4 | right | 171.17 | 196.50 | 0.22 |
| 512 | 1/2 | right | 171.17 | 197.84 | 0.435 |
| 512 | 1/4 | left | 171.17 | 186.37 | 0.31 |
| 512 | 1/4 | center | 171.17 | 176.97 | 0.335 |
| 512 | 1/16 | right | 171.17 | 180.58 | 0.06 |
| 512 | 1/64 | right | 171.17 | 173.76 | 0.015 |
| 256 | 1/4 | right | 85.83 | 98.50 | 0.22 |

The reported pair (196.09 vs 171.17) is consistent with the right window at \(x = 1/4\), \(M = 512\), on a coarser α grid.
**Every** placement shows a hump, so we went looking for a universal theorem. Lean: `hedging_hump` (universal),
`minLaw_right_hump`, and the ceiling `trustCost_le_uniform_level`, which gives 256.5 at \(M=512\).

## 2. Placement ceilings (T8), α = 1, M = 256

| x | left | center | right | ceiling 1/x |
|---|---|---|---|---|
| 1/64 | 34.40 | 34.47 | 45.78 | 64 |
| 1/16 | — | — | **14.6877** | 16 |
| 1/8 | 5.32 | 5.42 | 7.68 | 8 |

The best cell is \(2109384/143616 = 14.6877\) (Lean: `best_cell_right_sixteenth`). The asymptotic law is
\(k(2m-1)/(3m-2)\) (Lean: `placementSpeedup_tendsto`). In the limit, right/left \(= (3-2x)/(2-x) \to 3/2\). That is **not** 2.

## 3. Crossing for 5.19× (committed procedure)

| x | placement | M=256 | M=512 | M=1024 |
|---|---|---|---|---|
| 1/64 | left | 0.8367 | 0.8344 | 0.8332 |
| 1/64 | right | 0.8332 | 0.8306 | 0.8294 |
| 1/8 | left | **0.9957** | 0.9935 | 0.9923 |
| 1/8 | right | 0.9485 | 0.9466 | 0.9456 |

Lean: `left_crossing_eighth` proves the \(M=256\) crossing lies in \((0.995, 0.996)\) and is unique. `left_crossing_sixtyfourth` proves it lies in \((0.836, 0.837)\).
The reported value 0.832 at \(x=1/64\) does not match the left window at \(M=256\). It does match the right window there, or the large-\(M\) limit.

## 4. Counterexample hunt
- The claim "the hump requires right placement" is false. Left and centered windows also hump (table 1).
- The claim "placement doubles" is false asymptotically. The ratio is 3/2.
- The claim "the uniform-given-hit gate holds for every placement" is false. For a left window at \(x=1/16\), \(M=512\), the cap is \(r\alpha \le 0.117\), which is not tiny.
  The gate (`right_uniform_gate`) is specific to right placement.

No OEIS search was relevant: the objects here are rational functions, not integer sequences.
