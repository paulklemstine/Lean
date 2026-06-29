# Computational Evidence — Renormalization of Proofs

Small-case checks supporting the formal results in `ProofSearchRG.lean` and `RGFlow.lean`.
All quantities are exact (integer or closed-form), so evidence is confirmatory rather than
statistical.

## 1. RG (block-spin) invariance — exact data collapse

`searchSize b d = b^d`; coarse-grain `(b,d) ↦ (b^L, d/L)` with `L ∣ d`.

| b | d  | L | b^L | d/L | (b^L)^(d/L) | b^d   | equal? |
|---|----|---|-----|-----|-------------|-------|--------|
| 2 | 12 | 2 | 4   | 6   | 4096        | 4096  | ✓      |
| 2 | 12 | 3 | 8   | 4   | 4096        | 4096  | ✓      |
| 3 | 6  | 2 | 9   | 3   | 729         | 729   | ✓      |
| 3 | 6  | 3 | 27  | 2   | 729         | 729   | ✓      |
| 5 | 4  | 2 | 25  | 2   | 625         | 625   | ✓      |

Perfect collapse onto the invariant curve `b^d` for every divisor block size — matches
`searchSize_coarse_grain`.  (When `L ∤ d`, e.g. `b=2,d=5,L=2`: `(2^2)^2 = 16 < 32 = 2^5`,
so only an inequality holds — the documented `Nat`-truncation boundary.)

## 2. Branching phase transition (critical branching b_c = 1)

`searchSize b d`:

| b\d | 0 | 1 | 2 | 3 | 4  | 5  |
|-----|---|---|---|---|----|----|
| 0   | 1 | 0 | 0 | 0 | 0  | 0  |
| 1   | 1 | 1 | 1 | 1 | 1  | 1  |
| 2   | 1 | 2 | 4 | 8 | 16 | 32 |
| 3   | 1 | 3 | 9 |27 | 81 |243 |

`b ≤ 1` stays `≤ 1` (bounded class); `b ≥ 2` is `≥ 2^d` (exponential class).  Sharp jump at
`b = 1 → 2` — matches `branching_phase_transition` / `branching_transition_witness`.

## 3. Continuous RG flow `rgStep g = g²`, iterate `g^(2^n)`

| g    | n=0 | n=1 | n=2  | n=3      | n→∞ |
|------|-----|-----|------|----------|-----|
| 0.5  | 0.5 |0.25 |0.0625| 0.00390… | → 0 |
| 0.9  | 0.9 |0.81 |0.6561| 0.43046… | → 0 |
| 1.0  | 1.0 |1.0  |1.0   | 1.0      | = 1 (fixed) |
| 1.1  | 1.1 |1.21 |1.4641| 2.1435…  | → ∞ |
| 2.0  | 2.0 |4.0  |16.0  | 256.0    | → ∞ |

Subcritical `[0,1) → 0`, critical `1` fixed, supercritical `(1,∞) → ∞` — matches
`rg_flow_subcritical`, `rgStep_fixed_one`, `rg_flow_supercritical`.

## 4. Fixed points and exponent

`g² = g` ⇔ `g ∈ {0, 1}` (no other real roots) — matches `rgStep_fixed_points`.
`d/dg (g²)|_{g=1} = 2 > 1`, so `g=1` is repelling; block size `b=2` and `2 = 2^{1/ν}` give
`ν = 1` — matches `rgStep_deriv_at_one`, `rg_critical_relevant`,
`rg_correlation_length_exponent`.

## 5. Tower hierarchy bridge (uses catalog `towerExp`)

`towerExp 0 = 1`, `towerExp (n+1) = 2^(towerExp n)`: `1, 2, 4, 16, 65536, …`.

| d | searchSize 2 d = 2^d | towerExp (d+1) |
|---|----------------------|----------------|
| 0 | 1                    | 2              |
| 1 | 2                    | 4              |
| 2 | 4                    | 16             |
| 3 | 8                    | 65536          |
| 4 | 16                   | 2^65536        |

`2^d ≤ towerExp (d+1)` with a rapidly widening gap — matches `searchSize_below_tower`.

## OEIS notes

- `searchSize 2 d = 2^d`: powers of two, OEIS A000079.
- `towerExp`: `1, 2, 4, 16, 65536, …` is OEIS A014221 (2↑↑n).

No counterexamples were found in any sampled range.
