# Computational evidence

All numbers below were produced by `#eval` inside the project's Lean toolchain
(exact integer arithmetic) before the corresponding theorems were formalised.
Every claim that survives is now backed by a `sorry`-free Lean proof in
`Catalog/Pythagorean/PRNGBerggren*.lean`; the tables are kept only as the
exploratory record.

## 1. The three Berggren orbits of the root `(3,4,5)`

`mA`, `mB`, `mC` are the Barning–Berggren moves applied repeatedly to `(3,4,5)`.

| t | `mA^[t] (3,4,5)` | `mB^[t] (3,4,5)` | `mC^[t] (3,4,5)` |
|---|---|---|---|
| 0 | (3, 4, 5)   | (3, 4, 5)        | (3, 4, 5) |
| 1 | (5, 12, 13) | (21, 20, 29)     | (15, 8, 17) |
| 2 | (7, 24, 25) | (119, 120, 169)  | (35, 12, 37) |
| 3 | (9, 40, 41) | (697, 696, 985)  | (63, 16, 65) |
| 4 | (11, 60, 61)| (4059, 4060, 5741)| (99, 20, 101) |

Observations that turned into theorems:

* the `A`-orbit first leg is arithmetic (`3,5,7,9,11`) and the other two entries
  are quadratic in `t` → `orbitA_closed_form`, `orbitA_root_closed_form`;
* the `C`-orbit second leg is arithmetic (`4,8,12,16,20`) → `orbitC_closed_form`;
* the `B`-orbit leg difference is `1,-1,1,-1,1` → `bergB_legdiff_alternates`;
* the `B`-orbit hypotenuse `5, 29, 169, 985, 5741` satisfies `x(t+2)=6x(t+1)-x(t)`
  (`6·985 - 169 = 5741`) → `bergB_hypotenuse_pell`.  This is OEIS A001653
  (NSW-type Pell hypotenuses, `1, 5, 29, 169, 985, 5741, …`).

## 2. Third-difference test (the order-3 fingerprint)

For `t = 0,1,2,3`:

* `y(t+3) - (3y(t+2) - 3y(t+1) + y(t)) = 0` for every coordinate of the `A`-orbit
  and of the `C`-orbit (taps `![1,-3,3]`);
* `y(t+3) - (5y(t+2) + 5y(t+1) - y(t)) = 0` for every coordinate of the
  `B`-orbit, checked from the seed `(7,24,25)` as well as `(3,4,5)`
  (taps `![-1,5,5]`).

Predicted from the characteristic polynomials `det(λI - B₁) = (λ-1)³`,
`det(λI - B₂) = λ³-5λ²-5λ+1`, `det(λI - B₃) = (λ-1)³`, and afterwards proved:
`berggrenA_satisfiesLFSR`, `berggrenB_satisfiesLFSR`, `berggrenC_satisfiesLFSR`,
`berg_taps_from_charpoly`.

## 3. Sharpness hunt (is order 3 an artefact?)

Trying to fit an order-2 recurrence `y(t+2) = c₀y(t) + c₁y(t+1)` to the
`A`-branch hypotenuse `5, 13, 25, 41, 61` gives the inconsistent system
`25 = 5c₀+13c₁`, `41 = 13c₀+25c₁`, `61 = 25c₀+41c₁` (no integer, indeed no
rational, solution).  Formalised as `hypA_not_order_two` / `hypC_not_order_two`;
the `B`-branch counterpart `hypB_not_order_one` shows the Pell order 2 is sharp
there.  Hence the linear complexity itself classifies the branch
(`linear_complexity_separates_branches`).

## 4. Counterexample hunt (rarity and coverage)

* Constant streams: `moveX (a,b,c) = (a,b,c)` is impossible for a positive
  triple → `constant_stream_not_orbit`.
* Rescaling: the parents of `(6,8,10)` computed by the three inverse maps are
  `(2,0,2)`, `(2,0,2)`, `(-2,0,2)` — all with a zero leg, so `(6,8,10)` has no
  positive parent → `six_eight_ten_no_positive_parent`.  Doubling a
  seed-compressible file destroys seed compressibility in this family.
* Decoder round trip: `decodeSeed 4 (applyPath [A,C,B,A]) = [A,C,B,A]` with
  `applyPath [A,C,B,A] = (369, 800, 881)` (and `369² + 800² = 881²`), matching
  `decodeSeed_applyPath`.
* No counterexample was found to the coverage conjecture (every normalised
  primitive triple lies on the tree); it is now proved
  (`exists_path_of_treeTriple`).
