# Computational Evidence

All numerical experiments below were run in double-precision floating point on
pseudo-random samples. They are **exploratory only and not verified**; every claim that
is actually asserted in this cycle is proved in
`Catalog/Combinatorics/ThreeQubitHyperdeterminant.lean` with no `sorry` and no extra
axioms.

Notation: `ψ : Fin 2 → Fin 2 → Fin 2 → ℂ`, `Det ψ` is Cayley's `2 × 2 × 2`
hyperdeterminant, `τ_A|BC = 4 det ρ_A` is the one-tangle, `τ_ABC = 4 |Det ψ|` is the
residual (three-)tangle.

## 1. Small cases

| state | `Det ψ` | `τ_ABC` | `τ_A|BC` |
|---|---|---|---|
| `(|000⟩+|111⟩)/√2` (GHZ) | `1/4` | `1` | `1` |
| `(|001⟩+|010⟩+|100⟩)/√3` (W) | `0` | `0` | `8/9` |
| `α|000⟩ + β|111⟩` | `α²β²` | `4‖α‖²‖β‖²` | `4‖α‖²‖β‖²` |
| `a|100⟩+b|010⟩+c|001⟩` | `0` | `0` | `4‖a‖²(‖b‖²+‖c‖²)` |
| any biseparable state | `0` | `0` | `0` on the split cut |

All five rows are theorems in the Lean file (`hyperdet_ghz`, `oneTangleA_wState`,
`hyperdet_ghzFamily`, `oneTangleA_wFamily`, `hyperdet_eq_zero_of_isProductA` …).

## 2. Relative `SL(2)^{×3}` invariance

For 2000 random Gaussian amplitude tensors and random `2 × 2` matrices `A, B, C`:

```
max | Det((A⊗B⊗C)ψ) − (det A · det B · det C)² · Det ψ |  =  1.2e-11
```

consistent with the exact identity `hyperdet_localAct`.

## 3. Counterexample hunt for `τ_ABC ≤ τ_A|BC`

200 000 Haar-like random normalized tensors:

```
min ( τ_A|BC − τ_ABC )  =  +1.14e-03      (no counterexample)
max τ_ABC               =   0.9930        (approaching the GHZ value 1)
max |Im det ρ_A|        =   0
```

The search found no violation, and the maximum observed three-tangle approaches `1`,
matching the GHZ state. Both facts are now theorems:
`residualTangle_le_oneTangleA` and `residualTangle_le_one`.

## 4. Two polynomial identities behind the proof

Writing `ψ` as a `2 × 4` matrix whose rows are the slices `a 0 j k`, `a 1 j k`, and
letting `m₁₂, …, m₃₄` be its six `2 × 2` minors, numerics on 500 random tensors gave

```
max | Det ψ − ( m₁₄² + m₂₃² − 2 m₁₂m₃₄ − 2 m₁₃m₂₄ ) |     =  3.2e-14
max | det ρ_A − Σ_{p<q} |m_pq|²  |                        =  5.7e-14
```

These are proved exactly as `hyperdet_eq_minors` and `rhoA_det_eq_minors`
(Cauchy–Binet); combining them with the triangle inequality and AM–GM yields
`τ_ABC ≤ τ_A|BC`.

## 5. OEIS

No integer sequence arises in this cycle; the objects are polynomial invariants of a
continuous family, so no OEIS lookup applies.
