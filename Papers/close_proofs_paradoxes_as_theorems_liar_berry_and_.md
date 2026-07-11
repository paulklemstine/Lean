# Computational Evidence

The central objects here are *finite*, so all claims are checked exhaustively
(by `decide`/`Fintype` enumeration) rather than sampled.

## 1. The four-valued Belnap algebra `BV = {T, F, B, N}`

Negation table (`neg`):

| v | neg v |
|---|-------|
| T | F |
| F | T |
| B | B |
| N | N |

Designation (`des`, "asserted/provable" = at-least-true):

| v | des v |
|---|-------|
| T | true |
| F | false |
| B | true |
| N | false |

**Negation fixed points**: `neg v = v` holds for `v ∈ {B, N}`.
Of these, only `B` is designated (`des B = true`). So `B` is the unique
*designated negation fixed point* — the algebraic seed of a "provable Liar".

**Glut check** (`des v = true ∧ des (neg v) = true`): enumerating all four values,
this holds only for `v = B`. Confirmed as `BV.glut_iff`.

## 2. De Morgan / involution laws

`neg (neg v) = v`, `neg (a ∧ b) = neg a ∨ neg b`, and dually — verified over all
`4` and `4×4 = 16` cases by `decide`.

## 3. The six-sentence witness model

`paradoxVal = [B, B, B, T, F, N]`, `paradoxNeg = [0,1,2,4,3,5]`.

Coherence `val (sneg s) = neg (val s)` checked over all `6` sentences:

| s | val s | sneg s | val (sneg s) | neg (val s) |
|---|-------|--------|--------------|-------------|
| 0 | B | 0 | B | B ✓ |
| 1 | B | 1 | B | B ✓ |
| 2 | B | 2 | B | B ✓ |
| 3 | T | 4 | F | F ✓ |
| 4 | F | 3 | T | T ✓ |
| 5 | N | 5 | N | N ✓ |

Sentences `0,1,2` are provable gluts; sentence `4` is unprovable, witnessing
**nontriviality** and **non-explosion**.

## 4. Boolean (classical) side — counterexample hunt

Claim: in a nontrivial Boolean algebra there is *no* `x` with `xᶜ = x`.
Test on `Bool` (the 2-element Boolean algebra): the two candidates are
`x = false` (`xᶜ = true ≠ false`) and `x = true` (`xᶜ = false ≠ true`).
No fixed point — consistent with the general theorem
`boolean_neg_fixpoint_trivial`, which shows any such fixed point forces `⊥ = ⊤`.

Since every relevant domain is finite, no unbounded search or OEIS lookup is
applicable; the Lean file discharges every case by kernel-checked enumeration.
