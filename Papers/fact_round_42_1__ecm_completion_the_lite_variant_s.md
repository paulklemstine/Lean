# Computational evidence — ECM-lite (exp 487 replication, round-42 #1)

Script: `ResearchOutput/scripts/ecm_lite_evidence.py` (pure Python, seed `20260921`).
All numbers below were produced by that script in this project.

## E1 — the detection window (supports `xCollision_iff_addOrderOf_le`)

Model: cyclic curve group `Z/n`, base point `x`, run `P, 2P, …, B·P`, detection =
repeated `x`-coordinate, i.e. `i·x ≡ ±j·x (mod n)` for some `1 ≤ i < j ≤ B`
(the elliptic involution `Q ↦ -Q`).

Exhaustive sweep `n = 1 … 59`, `B = 3 … 8`, all `x ∈ Z/n` (≈ 10 600 cases):

```
E1 detection-window counterexamples: 0
```

Every case satisfies `collision ⟺ ord(x) ≤ 2B - 1`, including the sharp
negative endpoint `ord = 2B` (e.g. `n = 16, B = 8, x = 1`: no collision).
This is the statement proved in Lean as
`ECMLite.xCollision_iff_addOrderOf_le` / `no_xCollision_of_addOrderOf_eq_two_mul`.

## E2 — curve-budget scaling with a FIXED bound `B₁ = 50`

Genuine random elliptic curves `y² = x³ + ax + b` over `F_p` (random `a`, random
base point, `b` fitted; singular curves rejected), sequential multiples with an
explicit doubling at `j = 2` (the v1 ledger fix), success = some `j·P = O` with
`2 ≤ j ≤ 50`.  Budget = number of curves until the first success.

| k  | p       | median budget | mean budget |
|----|---------|---------------|-------------|
| 10 | 1031    | 22            | 24.9        |
| 12 | 4099    | 61            | 95.7        |
| 14 | 16411   | 273           | 333.3       |
| 16 | 65537   | 1935          | 1602.2      |
| 18 | 262147  | 4969          | 5217.2      |

Least-squares slope of `log₂(median budget)` per `log₂ p`: **1.031**
(15 trials per `k`, uncensored).

A focused replication on exactly the reported bit sizes (7 trials each):

| k  | p        | median budget |
|----|----------|---------------|
| 16 | 65537    | 812           |
| 20 | 1048583  | 12669         |

slope `k = 16 → 20`: **0.991**.

**Finding.**  With a fixed `B₁ = 50` the ECM-lite curve budget grows like `p^1`,
not `p^0.48`.  This is exactly the proved statement
`ECMLite.fixed_bound_refutes_sqrt_scaling` (a fixed window has curve-count
exponent 1) together with the visible-set bound `card_lowOrder_le_sq`
(`≤ B²` detectable points per curve).  The reported `0.48` per `log₂ p` is
therefore **not reproducible as an uncensored curve-budget exponent in the hidden
prime**; it is consistent with (i) a slope measured per `log₂ N` of a balanced
semiprime `N = p·q` (which halves the exponent to ≈ 0.5), or (ii) censoring of
the upper tail, or (iii) an effective window that grows with `p`.  Reading (iii)
is quantified in Lean by `ECMLite.window_exponent_from_slope`: slope `1 - α =
0.48` forces `B_eff = p^{0.26}`, i.e. `2^{4.2} … 2^{5.2}` at `k = 16 … 20` —
numerically indistinguishable from the fixed `50 = 2^{5.6}` over that four-bit
range, which is precisely why a fixed window can masquerade as a growing one
there.

## E3 — zero-detection versus x-collision detection (constant factor only)

Same experiment with detection by repeated `x`-coordinate (window `2B-1 = 99`)
instead of by `R = O` (window `B = 50`), 15 trials each:

| k  | p     | budget (R = O) | budget (x-collision) |
|----|-------|----------------|----------------------|
| 12 | 4099  | 42             | 33                   |
| 14 | 16411 | 273            | 192                  |
| 16 | 65537 | 636            | 495                  |

Widening the window from `B` to `2B - 1` buys a constant factor ≈ 1.3 and no
change of exponent — as the window theorem predicts, since both windows are
linear in `B`.

## Not verified computationally

The rpow bookkeeping (`budget_exponent_identity`, `window_exponent_from_slope`)
and the addition-chain barrier (`addChain_le_two_pow`) are proved in Lean; they
are exact statements and were not sampled numerically.
