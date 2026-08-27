# Computational evidence — NET-94 role split (Algebra cell, axis iteration 69)

All numbers below were produced with Lean `#eval` on `Float` arithmetic from the two
reported NET-94 arms (relative degradations vs the f16 control, expressed as fractions):

* `ρ = 0.00142`  (K `q8_0` / V `q4_0`, `+0.142 %`, PPL 7.1194)
* `P = 8.67694`  (K `q5_1` / V `q5_1`, `+867.694 %`, PPL 68.7963)

They are *exploratory*: every claim that survives is restated and proved in Lean in
`Catalog/Algebra/KVCache*.lean`, and it is those proofs, not the floats, that certify the
results.

## 1. Small-case calculations

| quantity | value | meaning |
|---|---|---|
| `P / ρ` | `6110.521` | distortion ratio across the 3-bit key drop |
| `(P/ρ)^(1/3)` | `18.2821` | required *per-bit* distortion shrink base |
| `log(1+P)/log(1+ρ)` | `1599.547` | ratio of log-distortions (multiplicative model) |
| `log₂` of that | `10.6434` | bit-window width demanded by the squaring law |
| `log₂((P/ρ)^(1/3))` | `4.1924` | implied power-law response exponent |
| `8 ρ` | `0.011360` | value-side distortion 3 bits below the free point |
| `(1+ρ)^8 − 1` | `0.011417` | key-side distortion 3 bits below the free point, squaring law |

## 2. What the table refutes

*Linear (uniform-quantiser) response.*  A step law `D(b) = c · 2⁻ᵇ` multiplies distortion
by exactly `2³ = 8` over three bits, i.e. `+0.142 % → +1.136 %`.  Observed: `+867.694 %`,
a factor `6110` instead of `8` — off by **2.9 orders of magnitude**.  Formalised as
`value_path_cannot_cliff` and `net94_refutes_uniform_step_law`.

*Exponential (Lipschitz-softmax) response.*  With `D(b) = exp(c·2⁻ᵇ) − 1` the *logarithm*
of the distortion factor doubles per lost bit, so three bits multiply it by `8`, giving
`+1.142 %` at 5 bits.  Reproducing the measured pair would need a window of
`log₂(1599.5) = 10.64` bit widths, not `3`.  Formalised as `cliff_width_lower_bound` and
`net94_refutes_uniform_lipschitz_model`.

*Consequence.*  The per-bit shrink base must exceed `11.69` in the exponential model and
`18.28` in any multiplicative model — never the physical `2`.  Formalised as
`key_bit_shrink_base_lower_bound` (`K > 11`) and `net94_forces_superbinary_shrink`
(`K > 18`), and converted into the integer statement `γ ≥ 5` for a power-law response
(`net94_forces_quintic_key_response`; the fitted real exponent is `4.19`, and `γ = 5` is
attained — `quintic_response_is_attained`).

## 3. Counterexample hunt

The universal claims proved here are inequalities over all admissible model constants, so
the counterexample hunt is a *satisfiability* hunt in the opposite direction: is any
constant consistent with the data?

* Squaring model, `exp(c/2ᵇ) − 1`: swept `c` so that the 8-bit arm is met with equality
  (`c = 2⁸·log(1.00142) = 0.3634`); the 5-bit prediction is then `+1.14 %`, three orders
  of magnitude below the measurement.  No `c` works — this is exactly
  `net94_refutes_uniform_lipschitz_model`.
* Power-law model, `c·(R/2ᵇ)^γ`: `γ = 5`, `R = 1`, `c = 8.67694·2²⁵` meets the 5-bit arm
  with equality and gives `8.67694/2¹⁵ = 2.65·10⁻⁴ ≤ 0.00142` at 8 bits — consistent.
  `γ = 4` tuned the same way gives `8.67694/2¹² = 2.12·10⁻³ > 0.00142` at 8 bits and
  fails; `γ ≤ 4` is excluded in general by the exact inequality `2⁴ = 16 < 18.28`.  Hence
  `γ ≥ 5` is both necessary and attainable.

## 3b. Depth is not the missing amplifier

The natural rescue for the refuted smooth models is depth: `L` stacked layers, each of
Lipschitz gain `λ`.  Solving the error recursion `δ_{L+1} = λ δ_L + e` gives
`δ_L = e·Σ_{i<L} λ^i`, a constant multiple of the per-layer error, so the *slope* of the
distortion in the quantiser step is unchanged.  Numerically, with `λ = 1.1` and `L = 32`
the depth factor is `Σ_{i<32} 1.1^i ≈ 201`, which shifts the curve but not the exponent:
the required shrink base stays above `18` at every depth.  Formalised as
`depth_preserves_response_exponent` and `depth_cannot_rescue_low_exponent`.

## 4. Role-side sanity check

The value side is *provably* incapable of the observed collapse, at any range `R`: its
distortion is exactly the quantiser step, so a 3-bit drop can inflate it by exactly `8`,
never by `6110`.  This is the one claim that needs no fitting at all and is the content of
`value_path_cannot_cliff`.  Combined with the response-exponent gap
(`role_response_exponent_gap`: key exponent `≥ 5`, value exponent `= 1`), it identifies
`-ctk q8_0 -ctv q4_0` as the correct allocation of a 6-average-bit budget
(`equal_memory_split_strictly_better`).

## 5. OEIS

No integer sequence arises in this cell; the only integers produced are the response
exponent bound `γ ≥ 5` and the bit widths `4, 5, 6, 8`.  No OEIS lookup was performed.
