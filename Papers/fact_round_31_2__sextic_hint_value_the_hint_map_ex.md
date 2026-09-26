# Computational Evidence — SEXTIC-HINT-VALUE (FACT round-31 #2, paper 121)

All values below that appear in a theorem are proved exactly in Lean
(`Catalog/Physics/SexticHintValue.lean`, `Catalog/Physics/HintMapCRTDefect.lean`).
The fibre counts were first found with a Lean `#eval` over the 144 unit pairs of `ZMod 13`, and
then checked by the kernel with `decide` inside the proofs. Rows marked *(exploratory)* come
from a Python scratch computation only and are **not** Lean-verified.

## 1. The round-31 battery over `Q(ζ₁₃)⁺` (144 unit pairs `(p mod 13, q mod 13)`)

Labels: the unordered pair of residue degrees `{T(p), T(q)}`, with `T ∈ {1,2,3,6}` at rates
`{1/6,1/6,1/3,1/3}`.

| statistic | fibre-size multiset | entropy (bits) |
|---|---|---|
| label `{T(p),T(q)}` | `4,8,16,16,4,16,16,16,16,32` | `2 log₂3 − 1/18 = 3.114369` |
| `N = pq` | `12 × 12` | `2 + log₂3 = 3.584963` |
| `(label, N)` | `12×2, 26×4, 2×8` | `4 + 2log₂3 − 35/18` |
| `s = p+q` | `1×12, 12×11` | — |
| `(label, s)` | `8×1, 50×2, 4×3, 6×4` | — |

| view | reported | exact (Lean) | float check |
|---|---|---|---|
| `I(label ; N)` product view | 1.4704 | `log₂3 − 1/9` | 1.473851 |
| `I(label ; s,d)` joint | 3.1110 | `2log₂3 − 1/18` | 3.114369 |
| hint value | +1.6407 | `log₂3 + 1/18` | 1.640518 |
| `I(label ; N,s)` | — | `2log₂3 − 1/18` (the sum dial pins the label) | 3.114369 |
| `I(label ; N,d)` | — | `2log₂3 − 1/18` (the gap dial pins the label) | 3.114369 |
| `I(label ; s)` alone | — | `2log₂3 + 29/36 − (11/12)log₂11` | 0.804335 |
| `I(label ; d)` alone | — | (same float value; no Lean theorem) | 0.804335 |

So the sum hint, the gap hint and the joint hint are all equal to `log₂3 + 1/18`, and the
hint synergy is `−(log₂3 + 1/18)`: the two dials are completely redundant.

## 2. The hint map `n ↦ H(pair | N)` of the cyclic type channel

| n | hintMap n | closed form | log₂ n |
|---|---|---|---|
| 2 | 0.50000 | 1/2 | 1.0000 |
| 3 | 0.91830 | log₂3 − 2/3 | 1.5850 |
| 4 | 1.12500 | 9/8 | 2.0000 |
| 5 | 0.92115 | log₂5 − (12/25)log₂3 − 16/25 | 2.3219 |
| **6** | **1.64052** | **log₂3 + 1/18** | 2.5850 |
| 7 *(exploratory)* | 0.82434 | — | 2.8074 |
| 8 *(exploratory)* | 1.53125 | — | 3.0000 |
| 9 *(exploratory)* | 1.42846 | — | 3.1699 |
| 10 | 1.58115 | via `condPairEntropy_val_10` | 3.3219 |
| 12 | 2.32107 | via `condPairEntropy_val_12` | 3.5850 |
| 15 | 1.98166 | via `condPairEntropy_val_15` | 3.9069 |
| 30 *(exploratory)* | 2.79278 | — | 4.9069 |

Order on degrees 2–6 (proved): `h(2) < h(3) < h(5) < h(4) < h(6)`.

## 3. CRT defect law, instance by instance

`δ(n) = 1 − Σ_{d|n} φ(d)²/n²`: δ(2)=1/2, δ(3)=4/9, δ(4)=5/8, δ(5)=8/25, δ(15)=28/45.

| n = m·k | h(n) − h(m) − h(k) | δ(m)δ(k) |
|---|---|---|
| 6 = 2·3 | 2/9 | 2/9 |
| 10 = 2·5 | 4/25 | 4/25 |
| 12 = 4·3 | 5/18 | 5/18 |
| 15 = 3·5 | 32/225 | 32/225 |
| 30 = 2·15 *(exploratory)* | 0.31111 | 14/45 = 0.31111 |

The general law is proved in Lean (`hintMap_mul_of_coprime`). No counterexample exists.

## 4. Prime rungs *(exploratory, not Lean-verified)*

For prime `q`, the float values match
`h(q) = ((q−1)/q)·H_b(2/q) + (1/q)·H_b(1/q)` to 15 digits for q = 3, 5, 7, 11, 13, which gives
`h(q) → 0`. This is conjecture 1 of `FUTURE_DIRECTIONS.md`.
