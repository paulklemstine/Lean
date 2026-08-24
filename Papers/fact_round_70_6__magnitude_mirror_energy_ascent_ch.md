# Computational Evidence — Round-70 #6 (magnitude-mirror seal)

Scope note. The tables below come from *exploratory* scripts (Python, exact
integer arithmetic and IEEE doubles for the entropies). They are **not** part of
the formal record; everything that is claimed formally is proved in
`Catalog/Combinatorics/MagnitudeMirrorSeal.lean`,
`Catalog/Combinatorics/MagnitudeMirrorTransfer.lean` and
`Catalog/Combinatorics/MagnitudeMirrorTreeBridge.lean` and checked by `lake build`
(no `sorry`, axioms `propext, Classical.choice, Quot.sound` only). Three numeric
instances are additionally re-checked *inside* Lean:
`MagnitudeMirror.fermat_frontier_example`,
`MagnitudeMirror.pythagorean_bridge_example`,
`MagnitudeMirror.positional_oracle_informative`.

## 1. Energy sign pattern on the isqrt-anchored window (exp549 replication)

`E(a) = a² − N`, window `a_j = ⌊√N⌋ + j`, `j = 0 … 15`, 20 000 uniform
`N < 10¹²`:

| observed set `{j : E(a_j) < 0}` | count |
|---|---|
| `{0}` | 20000 |
| anything else | 0 |

Perfect squares behave as predicted by `hit_at_anchor_iff_isSquare`
(`E(a_0) = 0`, so *no* negative index):

| `N` | `E(a_0), E(a_1), E(a_2)` |
|---|---|
| `49` | `0, 15, 32` |
| `10⁶` | `0, 2001, 4004` |
| `15129 = 123²` | `0, 247, 496` |

So the sign vector is constant across `N` — the sensor is structural, hence the
exact zero of `bracket_sensor_zeroInfo`.

## 2. The Fermat hit is where the arithmetic happens

First `j` with `(⌈√N⌉ + j)² − N` a perfect square:

| `N` | first hit `j` | `a` | `b` | factorisation |
|---|---|---|---|---|
| `5959` | 2 | 80 | 21 | `59 · 101` |
| `8051` | 0 | 90 | 7 | `83 · 97` |
| `1234577 · 1299709` | 418 | 1267143 | 32566 | recovered |

The hit index is small exactly when the imbalance `k` is small, as the frontier
law predicts.

## 3. Two-sided frontier law (formalised as `fermat_hit_index_bound` / `_ge`)

For `N = u(u+2k)`, `m = ⌊√N⌋`, `j = (u+k) − m`, 20 000 random pairs
`u < 10⁶`, `k < 10⁵`:

* `2·m·j ≤ k² + 2·m` — 20000/20000 hold;
* `k² ≤ 2(u+k)·j` — 20000/20000 hold.

No counterexample found; both inequalities are proved in Lean.

## 4. Positional-oracle capacity profile (surviving channel)

4000 semiprimes `N = p·q`, `p < 10⁴`, `q < 10⁶`, `d = min(p,q)`,
capacity `= H₂(P(d ≤ B))` in bits:

| `B` | `P(d ≤ B)` | capacity |
|---|---|---|
| 10 | 0.0022 | 0.0230 |
| 50 | 0.0107 | 0.0857 |
| 100 | 0.0180 | 0.1301 |
| 200 | 0.0333 | 0.2104 |
| 500 | 0.0727 | 0.3761 |
| 1000 | 0.1325 | 0.5643 |
| 2000 | 0.2442 | 0.8020 |
| 3000 | 0.3448 | 0.9293 |
| 5000 | 0.5407 | **0.9952** |
| 8000 | 0.8173 | 0.6861 |
| 10000 | 1.0000 | 0.0000 |

Single-peaked, peak at the threshold nearest `P = 1/2`, capped by 1 bit — the
qualitative shape proved by `belowFrac_monotone`, `oracle_capacity_ascending`,
`oracle_capacity_descending`, `oracle_capacity_le_log_two`,
`oracle_capacity_peak_iff_balanced` and
`oracle_capacity_superlevel_interval`. (The mission's reported profile — peak
`0.4798` at `B ≈ 22758` — has the same shape at its own scale; the absolute
value depends on the instance ensemble, which is why only the shape is
formalised.)

## 5. The square-hit / Pythagorean-tree bridge

Every factorisation `s² = u·v` with `u ≤ v` and `u ≡ v (mod 2)` gives
`k = (v−u)/2` and a triple `k² + s² = (u+k)²`. Checked exhaustively for all
`3 ≤ s ≤ 119`: **538/538** factorisations produce a Pythagorean triple, no
exceptions. Example: `s = 12`, `144 = 8 · 18`, `k = 5`, triple `(5, 12, 13)` —
re-verified in Lean as `pythagorean_bridge_example`.

## 6. Sequence note

The frontier offsets `c − s` over square moduli are, by
`window_offset_of_square`, exactly the numbers with `(c−s)(c+s) = k²`; no OEIS
lookup was needed since the identity is exact and proved. No new integer
sequence is claimed here.
