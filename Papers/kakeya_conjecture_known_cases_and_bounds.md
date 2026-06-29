# Computational Evidence — Kakeya finite-field model

All numbers below were produced by `#eval` in Lean (Mathlib v4.28.0) and then
locked in as proved theorems.

## 1. Bush count `|⋃_m {(x, m·x)}| = q² − q + 1`

Predicted formula `q² − q + 1`, evaluated over `ZMod q` for primes `q`:

| q | predicted q²−q+1 | `#eval bushC (ZMod q)` |
|---|------------------|------------------------|
| 2 | 3                | 3                      |
| 3 | 7                | 7                      |
| 5 | 21               | 21                     |
| 7 | 43               | 43                     |

The bush misses exactly the `q − 1` off-origin points of the vertical axis
`{(0,b) : b ≠ 0}`, i.e. it occupies a `1 − 1/q + 1/q²` fraction of the plane —
the discrete analogue of "full dimension". This is formalized as
`KakeyaBush.bush_card`.

## 2. Iterated sumset growth (Cauchy–Davenport, Katz–Tao bridge)

Growth law predicted: `|kA| = min(q, k·(|A|−1) + 1)` for arithmetic-progression
seeds (sharp case).

`A = {0,1} ⊆ ZMod 7` (|A|=2), `[ (k·1+1) capped at 7 ]`:

`#eval (List.range 7).map (fun k => (sIter A k).card)` → `[2, 3, 4, 5, 6, 7, 7]`
matches `min 7 (k+1)` exactly; saturates at `k = 6 = p − 1`.

`A = {0,1,2} ⊆ ZMod 11` (|A|=3):

`#eval ...` → `[3, 5, 7, 9, 11, 11, 11]` matches `min 11 (2k+1)`; saturates at
`k = 5 = ⌈(p−1)/(|A|−1)⌉ = ⌈10/2⌉`.

Both tables confirm the lower bound `card_sumIter_ge` is tight on APs and the
saturation corollary `sumset_generates` (`kA = ZMod p` once `k ≥ p − 1`).

## 3. Counterexample hunt

- Singleton seed `A = {0}` gives `|kA| = 1` for all `k`; the bound predicts
  `min(p, k·0 + 1) = 1` — consistent, and explains why `sumset_generates`
  requires `|A| ≥ 2`. No counterexample to the stated theorems was found.

## Conclusion

The computational landscape matches every claim before formalization; all four
headline theorems were then proved with 0 `sorry` (axioms: `propext`,
`Classical.choice`, `Quot.sound`).
