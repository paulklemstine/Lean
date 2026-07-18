# Computational Evidence

## Small-case calculations

For a coefficient vector `(α, β, γ, δ)`, the tested quantity is
`C = 2|αδ-βγ|` under the normalization
`|α|²+|β|²+|γ|²+|δ|²=1`.

| State `(α,β,γ,δ)` | Determinant `αδ-βγ` | Concurrence |
|---|---:|---:|
| `(1,0,0,0)` | `0` | `0` |
| `(1/√2,0,0,1/√2)` | `1/2` | `1` |
| `(0,1/√2,1/√2,0)` | `-1/2` | `1` |
| `(1/2,1/√2,0,1/2)` | `1/4` | `1/2` |
| `(√3/2,0,0,1/2)` | `√3/4` | `√3/2` |

The fourth row is decisive: an ordinary linking number is integer-valued, whereas the concurrence is exactly `1/2`. Thus a thousand-state random comparison is unnecessary for the proposed universal equality: one exact counterexample refutes it.

## OEIS search results

No integer sequence arises naturally in this investigation, so an OEIS search is not applicable.

## Counterexample hunt

The normalized one-parameter family

`ψ(t) = (cos t, 0, 0, sin t)`

has concurrence `|sin(2t)|`. It therefore realizes a continuum of values in `[0,1]`, while an ordinary linking number takes values in the discrete set of integers. The explicit algebraic witness `(1/2,1/√2,0,1/2)` avoids reliance on numerical approximation.

There is also a dimensional mismatch in the original geometric description: fibres of the quaternionic Hopf fibration `S⁷ → S⁴` are three-spheres, not circles.

## Table interpretation

The Bell states attain the sharp upper bound `1`; product states attain `0`; and normalized intermediate states attain nonintegral values. The evidence supports the determinant/exterior-algebra interpretation and falsifies literal equality with an ordinary linking number.
