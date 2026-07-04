# Computational Evidence — Escher Staircases and Escher Height

## 1. The variable-ideal chain in `k[x₀, x₁, x₂, …]`

Rungs `V n = ⟨x₀, …, x_{n-1}⟩`:

| n | generators of `V n`        | new element in `V (n+1) \ V n` |
|---|----------------------------|--------------------------------|
| 0 | `∅`  (so `V 0 = ⟨0⟩ = ⊥`)   | `x₀`                           |
| 1 | `x₀`                        | `x₁`                           |
| 2 | `x₀, x₁`                    | `x₂`                           |
| 3 | `x₀, x₁, x₂`                | `x₃`                           |

Strictness check (separating homomorphism): let `φ_n : x_i ↦ 0` for `i < n`,
`x_i ↦ x_i` for `i ≥ n`. Then `φ_n` kills every generator of `V n`, so `φ_n(V n) = 0`,
yet `φ_n(x_n) = x_n ≠ 0`. Hence `x_n ∉ V n` while `x_n ∈ V (n+1)`. The chain is
strictly ascending → an Escher staircase.

Loop-back: `⨅ n V n ⊆ V 0 = ⊥`, so the infimum of the whole ascending chain is exactly
the bottom rung `{0}`.

## 2. Finite-variable side (Hilbert basis)

For each fixed `n`, `k[x₀,…,x_{n-1}]` is Noetherian. Sample: any ascending chain of
ideals in `k[x]` (a PID) stabilises because ideals are `⟨d⟩` with `d | d'` forcing the
degrees to be non-increasing along the chain — a finite descent. No infinite strictly
ascending chain exists ⇒ no Escher staircase.

## 3. The mission's `Int(ℤ)` chain is descending, not ascending

The description proposes `I_n = {f ∈ Int(ℤ) : f(ℤ) ⊆ 2ⁿℤ}`. Since `2^{n+1}ℤ ⊆ 2ⁿℤ`,
we get `I_{n+1} ⊆ I_n`: the chain is *descending*. Concretely `f = 2` lies in `I_1`
(all values divisible by 2) but not in `I_2`. So this particular family is **not** an
Escher staircase in the ascending sense. The honest infinite-height witness is instead
the variable chain of §1 (equivalently, any infinite-variable polynomial ring), and
the negative predictions of the mission (`ℤ_p`, finitely many variables) are Noetherian.

## 4. Dichotomy summary

| ring                       | Noetherian? | Escher staircase? |
|----------------------------|-------------|-------------------|
| field `k`                  | yes         | no                |
| `k[X]`                     | yes         | no                |
| `k[x₀,…,x_{n-1}]`          | yes         | no                |
| `k[x₀, x₁, x₂, …]`         | **no**      | **yes**           |
| `ℤ_p` (p-adic integers)    | yes         | no                |
| `ℕ → ℤ` (infinite product) | **no**      | **yes**           |

All rows are formalised: the finite/Noetherian rows via the ACC characterisation plus
Hilbert basis / DVR instances, the two "yes" rows via explicit strictly ascending
chains whose infimum returns to the bottom rung `⊥`.
