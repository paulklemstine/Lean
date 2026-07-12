# Computational Evidence — Euler–Poincaré for the decision-surface complex

The central claim, `euler_char_three_term`, is

    dim H₀ − dim H₁ + dim H₂ = dim C₀ − dim C₁ + dim C₂,

for a three-term chain complex `C₂ →[d₂] C₁ →[d₁] C₀` over a field, where
`H₀ = coker d₁`, `H₁ = ker d₁ / im d₂`, `H₂ = ker d₂`. Because this is an
identity of finite dimensions governed by rank–nullity, it is fully checkable on
small explicit complexes.

## Small-case checks (over a field `F`, with `rᵢ = rank dᵢ`)

Using `dim H₀ = a₀ − r₁`, `dim H₁ = a₁ − r₁ − r₂`, `dim H₂ = a₂ − r₂`
(here `a_i = dim C_i`, `r₁ = rank d₁`, `r₂ = rank d₂`):

| complex | (a₀,a₁,a₂) | (r₁,r₂) | (H₀,H₁,H₂) | χ_H = H₀−H₁+H₂ | χ_C = a₀−a₁+a₂ |
|---------|-----------|---------|------------|-----------------|-----------------|
| zero maps | (2,3,1) | (0,0) | (2,3,1) | 0 | 0 |
| exact middle | (1,2,1) | (1,1) | (0,0,0) | 0 | 0 |
| iso `d₁` | (1,1,0) | (1,0) | (0,0,0) | 0 | 0 |
| `d₂` inj, `d₁=0` | (1,2,1) | (0,1) | (1,1,0) | 0 | 0 |
| generic | (3,4,2) | (2,1) | (1,1,1) | 1 | 1 |
| generic 2 | (5,2,3) | (2,1) | (3,-1... )* | 6 | 6 |

(*Row "generic 2" only makes sense when the rank constraints `r₁ ≤ min(a₁,a₀)`,
`r₂ ≤ min(a₂,a₁)` and `r₁+r₂ ≤ a₁` hold so that `dim H₁ = a₁−r₁−r₂ ≥ 0`; with
`a₁=2` we need `r₁+r₂ ≤ 2`, so `(r₁,r₂)=(2,1)` is infeasible. A feasible variant
`(a)=(5,4,3), (r)=(2,1)` gives `(H)=(3,1,2)`, `χ_H = 4 = 5−4+3 = χ_C`.)

In every *feasible* row `χ_H = χ_C`, matching `euler_char_three_term`. The two
sides agree regardless of the individual homology groups — the content of
`euler_char_indep_of_differentials`.

## Counterexample hunt

The identity is a consequence of two rank–nullity equalities and one telescoping
of ranks; there is no free parameter that could violate it once the chain-complex
condition `d₁ ∘ d₂ = 0` holds (needed only to place `im d₂ ⊆ ker d₁`). No
counterexample exists, and none was found among the feasible small cases above.

## Why this suffices

The statement is an exact dimension identity, not an asymptotic or probabilistic
claim, so a handful of representative feasible complexes plus the algebraic
telescoping (formalised in `euler_poincare_defect`) constitute complete evidence.
The full proof is machine-checked in `EulerCharacteristic.lean` (no `sorry`).
