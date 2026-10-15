# Computational Evidence — Round 35 (m-leg closed; add-a-floor)

All formal claims are in `Catalog/Bridges/HarveyMLegClosed.lean` (0 sorries, axioms:
`propext`, `Classical.choice`, `Quot.sound`). The numbers below are ad-hoc exploratory checks
(Python grid search / one Lean `#eval`) run *before* the proofs; they are not themselves the
verification.

## 1. Grid minima (exponent space, step 1/200 resp. 1/60)
| cost | grid minimiser | grid min | proved value |
|---|---|---|---|
| `max(a, b, 1/2 - a/2 - b)` | (0.2, 0.2) | 0.2 | `1/5` (`harvey_dual_certificate`) |
| add floor `c`, weight `w = 1/2`, `δ = 0` | (1/6,1/6,1/6) | 0.1667 | `1/6` (`floor_lower`, `floor_attained`) |
| faithful, `θ = 1/4`, `w = 1/2` | (1/6,1/6,1/6) | 0.1667 | `1/6` (`faithful_floor_sixth_*`) |

## 2. Shadow prices (cheapen one leg by 0.1, measure optimum drop)
| leg cheapened | drop observed | predicted `(e₁+2e₂+2e₃)/5` |
|---|---|---|
| `r` (pair floor) | 0.02 | 0.02 |
| `m` (baby steps) | 0.04 | 0.04 |
| interior | 0.04 | 0.04 |

Proved exactly by `harvey_sensitivity` + `harvey_sensitivity_attained`.

## 3. Baby-step chain and the injectivity hypothesis (Lean `#eval`)
`slpRun (3 : ZMod 11) (babyProg 6)` = `[3, 9, 5, 4, 1, 3, 9]` (6 multiplications, 7 outputs).
`orderOf 3 = 5` in `ZMod 11`: the first 5 baby steps are distinct (`babyChain_nodup`), the
6th collides with the 1st (`α¹ = α^{ord+1}`), exactly as `babyChain_collision` predicts.

## 4. Counterexample hunt
* `floor_unique_minimizer` with `α = 0` is **false** (the pair floor is unpinned); found
  while proving, hypothesis strengthened to `α > 0`.
* `floor_beneficial_iff` was not tested numerically; it is proved directly.
