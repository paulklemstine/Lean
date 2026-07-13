# Computational Evidence

All computations are in the finite (step-graphon) model on `Fin N` with the
uniform measure, which is the standard discretization of graphons. Every integral
is a finite average, so the numbers below are exact.

Notation:
- `edgeLp N W p = ( (1/N²) Σ_{i,j} W(i,j)^p )^{1/p}` — the discrete `Lᵖ` norm of
  the single-edge kernel `K₂`.
- `homLpM2 N W p = ( (1/N⁴) Σ_{a,b,c,d} W(a,b)^p W(c,d)^p )^{1/p}` — the discrete
  `Lᵖ` norm of the 2-edge-matching kernel `M₂`.

## 1. The two-block kernel `blockW ρ` (on `Fin 2`)

`blockW ρ (i,j) = 2ρ` if `i = j`, else `0`.

Local-density check for every subset `S ⊆ {0,1}`:
`Σ_{i,j∈S} blockW = 2ρ·|S|`, and `ρ·|S|² ≤ 2ρ·|S|` ⇔ `|S| ≤ 2`, always true.
So `blockW ρ` is ρ-locally dense. It has values in `[0,1]` iff `2ρ ≤ 1`.

Closed form: `edgeLpPow 2 (blockW ρ) p = (1/2)(2ρ)^p = 2^{p-1} ρ^p`, hence
`edgeLp 2 (blockW ρ) p = 2^{(p-1)/p} · ρ`.

| ρ    | p    | edgeLp = 2^{(p-1)/p}·ρ | ρ    | edgeLp < ρ ? |
|------|------|------------------------|------|--------------|
| 0.25 | 0.50 | 0.125                  | 0.25 | yes          |
| 0.25 | 0.90 | 0.2065…                | 0.25 | yes          |
| 0.25 | 0.99 | 0.2465…                | 0.25 | yes          |
| 0.25 | 1.00 | 0.25                   | 0.25 | **no (=)**   |
| 0.25 | 1.50 | 0.315…                 | 0.25 | no (>)       |
| 0.10 | 0.50 | 0.05                   | 0.10 | yes          |

The factor `2^{(p-1)/p}` is `< 1` exactly when `p < 1`, matching the theorem
`blockW_edgeLp_lt` (counterexample for `p < 1`) and `edgeLp_ge_rho`
(no counterexample for `p ≥ 1`). The single-edge threshold is therefore exactly
`p = 1 = C(2,2)/1`.

## 2. Matching `M₂`: the literal `C(n,2)/m = 3` threshold fails

`M₂` has `n = 4` non-isolated vertices, `m = 2` edges, `e(F) = 2`.
The claim says: for every `p < C(4,2)/2 = 3` there is a ρ-locally-dense
counterexample with `homLpM2 < ρ²`.

Because the two edges use disjoint vertices, the functional factorizes:
`homLpM2 N W p = (edgeLp N W p)²` (theorem `homLpM2_eq`). Hence:

| ρ    | p    | edgeLp (constant kernel W≡ρ) | homLpM2 = edgeLp² | ρ²    | < ρ² ? |
|------|------|------------------------------|-------------------|-------|--------|
| 0.25 | 2.00 | 0.25                         | 0.0625            | 0.0625| no (=) |
| 0.25 | 1.50 | 0.25                         | 0.0625            | 0.0625| no (=) |
| 0.25 | 1.00 | 0.25                         | 0.0625            | 0.0625| no (=) |

More strongly, `edgeLp ≥ ρ` for **every** ρ-locally-dense kernel when `p ≥ 1`
(power-mean inequality, `edgeLp_ge_rho`), so `homLpM2 = edgeLp² ≥ ρ²` for the
entire range `1 ≤ p < 3`. No counterexample exists there — the claimed threshold
`3` is false. (Theorem `matching_no_counterexample`, instantiated at `p = 2`.)

## 3. Matching `M₂`: the correct threshold is `p = 1`

Using the two-block kernel again, for `0 < p < 1`:
`homLpM2 2 (blockW ρ) p = (2^{(p-1)/p} ρ)² < ρ²`.

| ρ    | p    | homLpM2 = (edgeLp)² | ρ²    | < ρ² ? |
|------|------|---------------------|-------|--------|
| 0.25 | 0.50 | 0.015625            | 0.0625| yes    |
| 0.25 | 0.90 | 0.04265…            | 0.0625| yes    |

So `M₂` has a genuine counterexample for every `p < 1` and none for `p ≥ 1`:
its exact threshold is `1`, far below the conjectured `3`. (Theorem
`matching_counterexample_below_one`.)

## 4. The general pattern (`(n-c)/m`, not `C(n,2)/m`)

For a graph `F` on `n` non-isolated vertices with `m` edges and `c` connected
components, the `k`-block kernel (value `kρ` inside each block, `0` across) is
ρ-locally dense, and one computes
`(1/N^n) Σ_φ ∏_{edges} W(φ)^p = k^{c - n + mp} ρ^{mp}`,
which is `< ρ^{mp}` exactly when `p < (n - c)/m`.

- Single edge `K₂`: `n=2, m=1, c=1` → `(n-c)/m = 1` (matches `C(2,2)/1 = 1`).
- Matching `M₂`: `n=4, m=2, c=2` → `(n-c)/m = 1`, while `C(4,2)/2 = 3`.

The values coincide only for connected graphs with `n = m + 1` (trees) up to the
edge; in general `(n-c)/m ≤ C(n,2)/m`, and the matching family shows the gap can
be made arbitrarily large. This is the source of the disproof of the literal
`C(n,2)/m` threshold.
