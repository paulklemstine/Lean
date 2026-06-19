# Computational Evidence: Tropical Discrete Logarithm & Eigenvalue Additivity

All computations performed in Lean over `ℚ` (exact arithmetic) to avoid
floating-point error. Min-plus product `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})`,
`tropMatPow A k := A^{⊗(k+1)}` (powers indexed from `A` itself at `k=0`,
since no tropical identity exists over a field without `+∞`).

## Test matrix

`A : 3×3` with diagonal `2`, off-diagonal `10`; constant vector `v ≡ 5`.
By the diagonal-eigenpair construction this gives a tropical eigenpair with
eigenvalue `λ = 2` and eigenvector `v`.

## 1. Eigenvalue additivity under tropical power  `λ(A^{⊗m}) = m·λ(A)`

| power `tropMatPow A k` | true exponent `m=k+1` | predicted eigenvalue `m·2` | `mvm (A^{⊗m}) v` |
|---|---|---|---|
| `k=0` (`A^1`)  | 1 | 2 | `![7,7,7]` = `v+2`  ✓ |
| `k=1` (`A^2`)  | 2 | 4 | `![9,9,9]` = `v+4`  ✓ |
| `k=2` (`A^3`)  | 3 | 6 | `![11,11,11]` = `v+6` ✓ |

The residual `(A^{⊗m} ⊗ v)_i − v_i` equals `m·λ` exactly, at **every** coordinate.

## 2. TDLP attack — exponent recovery

`(mvm (tropMatPow A 2) v 0 − v 0) / λ = (11 − 5)/2 = 3 = k+1`.

The secret exponent is recovered in closed form from a single eigenvalue
measurement whenever `λ ≠ 0`. This **refutes** the security conjecture
(TDLP hard) in every instance possessing a nonzero-eigenvalue eigenvector.

## 3. Diffie–Hellman correctness (power commutativity)

`decide (tropMatPow (tropMatPow A 1) 2 = tropMatPow (tropMatPow A 2) 1) = true`.
Alice's `(A^{⊗a})^{⊗b}` equals Bob's `(A^{⊗b})^{⊗a}` — the shared key is well defined.

## 4. Power multiplicativity

`decide (tropMatMul (tropMatPow A 1) (tropMatPow A 2) = tropMatPow A 4) = true`,
i.e. `A^{⊗2} ⊗ A^{⊗3} = A^{⊗5}`  (indices `1,2 ↦ 4` under the `k ↦ k+1` shift).

## Counterexample hunt

- Conjecture "TDLP is hard": **FALSE** for `λ ≠ 0` (Section 2 above; formalized as
  `tdlp_recover_exponent` and the concrete `tdlp_break_concrete`).
- Boundary `λ = 0`: attack divides by zero and recovers nothing — consistent with
  `Tropical.EigenzeroNoLeak.eigenzero_no_leak`. The hardness, where it exists at all,
  lives **only** at the degenerate boundary eigenvalue.
- Eigenvalue additivity `λ(A^{⊗m}) = m·λ`: no counterexample; it is an unconditional
  theorem given any eigenpair (proved by induction via translation equivariance).
