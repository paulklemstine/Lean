# Computational Evidence — HINT-VALUE-SCALING (paper 124)

All numbers are exact rational arithmetic on the four reported values
`V(0)=0, V(1)=0.52, V(2)=2.43, V(3)=3.19`. Every claim in this table is also
proved in `Catalog/Bridges/HintValueScalingLaw.lean` (proofs use `norm_num`/`linarith`;
no `native_decide`).

## 1. Marginal gains

| k | V(k) | Δ(k-1) = V(k) − V(k−1) | Lean |
|---|------|------------------------|------|
| 1 | 0.52 | 0.52 | `paper124_marginals` |
| 2 | 2.43 | **1.91** | `paper124_marginals` |
| 3 | 3.19 | 0.76 | `paper124_marginals` |

The marginal gains go **up** and then down (0.52 < 1.91 > 0.76). So "positive but decreasing"
holds only from k = 1 on. The curve is S-shaped, not concave (`paper124_not_concave`).

## 2. Superadditivity on the window

| pair (m,n) | V(m)+V(n) | V(m+n) | margin |
|------------|-----------|--------|--------|
| (1,1) | 1.04 | 2.43 | +1.39 |
| (1,2) | 2.95 | 3.19 | +0.24 |

The compounding margin shrinks from +1.39 to +0.24 (`paper124_window_compounds`).

## 3. Counterexample hunt: extending to k = 4

* Compounding at (2,2) requires `V(4) ≥ 2·2.43 = 4.86`.
* Diminishing returns at k = 3 require `V(4) ≤ 3.19 + 0.76 = 3.95`.
* Gap: 0.91 bits. **No V(4) satisfies both** (`paper124_sharp_k4`).

More generally, the compounding-horizon bound `V(b) ≤ b·Δ(k)` gives, for b = 2,
a required asymptotic slope of `≥ 2.43/2 = 1.215` bits per hint, while the observed Δ(2) is 0.76
(`paper124_asymptotic_slope`, `paper124_verdict_refuted`).

## 4. Consistency witnesses (each half of the verdict alone)

| extension | V(4) | V(5) | V(6) | property |
|-----------|------|------|------|----------|
| tangent line `2.43 + 0.76(k−2)` | 3.95 | 4.71 | 5.47 | diminishing from k=1 (`paper124_diminishing_extension`) |
| `k²` for k ≥ 4 | 16 | 25 | 36 | compounding (`paper124_compounding_extension`) |

The `k²` extension is unbounded; any extension with a uniform ceiling (e.g. the label
entropy) cannot compound (`paper124_bounded_not_compounding`).

## 5. Ceilings from the catalog

* Single odd prime field: second marginal ≤ 1 bit, observed 1.91 → impossible
  (`paper124_single_field_impossible`).
* `k` prime fields: second marginal ≤ k bits; 1.91 ≤ 2 fits two fields
  (`second_marginal_le_num_fields`).
* Any third hint that is a function of the factor residues `(p,q)` adds exactly 0 bits
  (`third_hint_saturation`), so the observed +0.76 at k = 3 must come from outside the
  residue ring.

## OEIS

No integer sequence is involved (the data are four decimal measurements); no OEIS search applies.
