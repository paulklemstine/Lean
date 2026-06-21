# Computational Evidence — LWE Hardness Cycle

All numeric checks below were executed in Lean (`#eval`) before the formal
proofs were written; the formal theorems then establish them for *all*
inputs, not just these samples.

## 1. Dual-Regev decryption identity (`dualRegev_decrypt_identity`)

Modulus `q = 17`, with
`A = !![1,2,3;4,5,6]`, `e' = ![1,0,1]`, `s = ![2,3]`,
`x0 = ![1,16,0]`, `x1 = 5`, `μ = 1`, `k = 8`.

| expression | value (ZMod 17) |
|---|---|
| `(⟨A·e', s⟩ + x1 + μ·k) - ⟨e', Aᵀ·s + x0⟩` | `12` |
| `μ·k + (x1 - ⟨e', x0⟩)` | `12` |

Both sides agree → the secret mask cancels exactly. ✓

## 2. Ring-LWE / LPR decryption identity (`ringLWE_decrypt_identity`)

Modulus `q = 17`, scalars `a=3, s=2, e=1, r=4, e0=6, e1=5, μ=1, k=8`.

| expression | value (ZMod 17) |
|---|---|
| `(b·r + e1 + μ·k) - s·c0`, with `b=a·s+e, c0=a·r+e0` | `5` |
| `μ·k + (e·r + e1 - s·e0)` | `5` |

Both sides agree. ✓

## 3. Counterexample hunt — necessity of the unit hypothesis

Tests Conjecture 2 (`FUTURE_DIRECTIONS.md`). Over `ZMod 6`, take the
non-unit `a = 2` (a zero divisor) and `f = ⟦· = 0⟧`:

| quantity | value |
|---|---|
| `#{ x : ZMod 6 | 2·x = 0 }`  (i.e. `∑ x f(2·x)`) | `2` |
| `#{ x : ZMod 6 | x = 0 }`    (i.e. `∑ x f(x)`)   | `1` |

`2 ≠ 1`, so `∑ x f(a·x) = ∑ x f(x)` **fails** for the non-unit `a = 2`.
This confirms that the `unit` hypothesis in `ringLWE_sum_affine_eq` is
necessary and cannot be weakened to `a ≠ 0` over composite moduli.

## 4. OEIS

No integer sequence is central to this cycle; the objects are algebraic
identities and inequalities rather than an enumerated sequence, so an OEIS
lookup is not applicable.

## Scope note

The decryption identities are *exact polynomial identities* (closed by
`ring`), so a finite sample is genuine evidence of the universal statement's
plausibility; the Lean proofs upgrade this to a full guarantee. The noise
bounds and reduction lemmas are inequalities proved by `linarith` / `gcongr`
/ induction and are not amenable to a single decisive numeric check, so no
further evaluation is reported for them.
