# Computational evidence — NET-75 knee analysis

All numbers below were produced by `#eval` inside Lean 4 (exact rational or
natural-number arithmetic, no floating point), so they are reproducible in the
same toolchain used for the proofs.  Where a finding is *proved*, the
corresponding theorem name is given; where it is only *computed*, it is
labelled as such.

## 1. Does a geometric profile reproduce the measured French/English pair?

Definition used (exact `ℚ` arithmetic):

```lean
def kgB (r t : ℚ) (bound : ℕ) : ℕ :=
  ((List.range (bound+1)).find? (fun k => r ^ k ≤ t)).getD 9999
```

Gate `τ = 0.98`, i.e. tail budget `t = 1 - τ = 0.02`.

| profile | decay ratio `r` | computed knee |
|---|---|---|
| EN prose (fitted) | `0.8223` | **20** |
| FR prose = √EN | `0.9068` | **40** |
| code-like `r_EN³` | `0.556…` | 7 |

So a *single* square-root of the decay ratio reproduces the reported
`k*(en) = 20 → k*(fr) = 40` doubling exactly.  The `code = 12` entry is *not*
`r_EN³` (that gives 7), which is why the master-knee reconstruction below uses
exponent 10 rather than a power of the English ratio.

## 2. Is the doubling gate-invariant?

Tightening the gate to `t = 0.0002`:

| profile | computed knee |
|---|---|
| `r = 0.8223` (EN) | 44 |
| `r = 0.9068` (FR) | 88 |

The ratio is again exactly 2.  This is the computational shadow of the proved
theorem `idealKnee_ratio_gate_invariant`: for the *ideal* (un-rounded) knee the
ratio `log r₂ / log r₁` is independent of the gate, and the integer knee differs
from the ideal one by less than 1 (`kgeom_sub_idealKnee_lt_one`).

**Prediction (falsifiable).** Re-running the NET-75 harness at any other gate or
context must give a French/English knee ratio of `2 ± (rounding)`, i.e.
`|k*_fr − 2·k*_en| ≤ 2`.  A larger discrepancy falsifies the single-ratio model.

## 3. Master-knee reconstruction of the five-domain table

Target table (NET-75, context 1024): `code 12, EN 20, math 20, DE 24, FR 40`.

```lean
#eval (120 ⌈/⌉ 10, 120 ⌈/⌉ 6, 120 ⌈/⌉ 5, 120 ⌈/⌉ 3)   -- (12, 20, 24, 40)
```

So one master profile with knee `120` and tax exponents `(10, 6, 6, 5, 3)`
reproduces every entry (proved: `five_domain_table`).

### Counterexample hunt: is `120` the smallest master?

```lean
def realizes (B v : ℕ) : Bool := (List.range (B+1)).any (fun m => 0 < m && B ⌈/⌉ m == v)
def coversTable (B : ℕ) : Bool := realizes B 12 && realizes B 20 && realizes B 24 && realizes B 40
#eval (List.range 400).find? coversTable      -- some 118
#eval (List.range 400).find? coversExact      -- some 120
```

* Under **exact division** the minimum is `120 = lcm(12, 20, 24, 40)`
  (proved: `five_domain_base_minimal`).
* Under the **ceiling law** — which is what `kgeom_root` actually gives — the
  minimum is `118`: `⌈118/10⌉ = 12`, `⌈118/6⌉ = 20`, `⌈118/5⌉ = 24`,
  `⌈118/3⌉ = 40`, with the *same* exponent vector.

Both facts are now theorems: `five_domain_table_118`, `no_master_below_118`
(a finite search over all `B < 118`, with the unbounded exponent range reduced
to `m ≤ B` by `exponent_le_of_ceilDiv_eq`), and `master_knee_ambiguous`.

Moreover the solution set is now known exactly: with the exponent vector
`(10, 6, 5, 3)` the table is reproduced **iff** the master knee is `118`, `119`
or `120` (proved: `master_solution_set`).

**Consequence for the NET-75 claim.** The five-domain fingerprint does *not*
identify the master profile: `118`, `119` and `120` are observationally
identical at this resolution.  Any statement that the tax exponents are canonical needs an
extra measurement (e.g. a sixth domain, or the same domains at a second gate).

## 4. Grid resolution

The reported French row is `k = 36 ✗ (0.9795)`, `k = 40 ✓ (0.9830)` at gate
`0.98`.  With monotone retention this only brackets the knee:
`36 < k* ≤ 40` (proved: `knee_bracket`, instantiated in `french_bracket`).
The value `40` is the least *grid point* above the knee, not the knee
(proved in general: `gridKnee_eq_least_grid_point`).  The true knee could be
37, 38, 39 or 40; a `k = 38` probe would halve the remaining interval.

## 5. OEIS

No integer sequence beyond the finite table `12, 20, 20, 24, 40` and the
divisor/ceiling data above arose, so no OEIS lookup was applicable.
