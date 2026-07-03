# Computational Evidence: Escher Staircases

## 1. Small-case calculation — the Boolean product ring `ℕ → 𝔽₂`

Ideals `Iₙ = suppLt n = { f : ℕ → 𝔽₂ | f i = 0 for all i ≥ n }`.

| n | membership condition        | example element in `Iₙ \ I_{n-1}` |
|---|-----------------------------|-----------------------------------|
| 0 | `f = 0` (all coords zero)   | — (`I₀ = {0}`)                    |
| 1 | `f i = 0` for `i ≥ 1`       | `e₀ = (1,0,0,…)`                  |
| 2 | `f i = 0` for `i ≥ 2`       | `e₁ = (0,1,0,…)`                  |
| 3 | `f i = 0` for `i ≥ 3`       | `e₂ = (0,0,1,0,…)`               |

* `eₙ = Pi.single n 1` lies in `I_{n+1}` (vanishes past index `n`) but **not** in
  `Iₙ` (its value at `n` is `1`).  Hence `Iₙ ⊊ I_{n+1}` strictly for every `n`.
* `I₀ = {0} = ⊥`.
* `⋂ₙ Iₙ = {f | ∀n, ∀ i ≥ n, f i = 0} = {0}`; consistent with the loop-back
  identity `⋂ₙ Iₙ = I₀`.

So `ℕ → 𝔽₂` carries a genuine strictly ascending Escher staircase and is
non-Noetherian.  (Formalized: `not_isNoetherianRing_boolProduct`.)

## 2. The advertised `Int(ℤ)` example is a DESCENDING chain

Claimed chain `Iₙ = {f ∈ Int(ℤ) : f(ℤ) ⊆ 2ⁿℤ}`.  Because `2ⁿ⁺¹ℤ ⊆ 2ⁿℤ`, the
condition for `I_{n+1}` is *stronger*, so `I_{n+1} ⊆ Iₙ`.  Concrete test values:

| n | `Iₙ` contains constant `2ⁿ`? | `Iₙ` contains constant `2ⁿ⁻¹`? |
|---|------------------------------|-------------------------------|
| 1 | yes (`2 ∈ 2ℤ`)              | `1 ∉ 2ℤ` → no                |
| 2 | yes (`4 ∈ 4ℤ`)             | `2 ∉ 4ℤ` → no                |

The constant `2 ∈ I₁` but `2 ∉ I₂`, so `I₂ ⊊ I₁`: **descending**, not ascending.
The headline example is therefore a *descending* "Anti-Escher" chain (whose
intersection is `{0}`), not an ascending staircase.  This is the phenomenon
already studied for `ℤ` in `Logic/ChainInvariants.lean`.

## 3. Dyadic descending chain in `ℤ` (bridge)

`(2⁰) ⊇ (2¹) ⊇ (2²) ⊇ ⋯`, generators `1, 2, 4, 8, …` (OEIS A000079).
Since `|2ⁿ| = 2ⁿ → ∞`, any nonzero integer eventually fails to be divisible, so
`⋂ₙ (2ⁿ) = {0}`.  (Formalized: `dyadic_int_intersection_bot`, via the catalog's
`ChainInvariants.int_anti_escher_ideal`.)

## 4. Counterexample hunt on the loop-back identity

Claim `⨅ₙ Iₙ = I₀` for every ascending chain.  This is *forced*: `I₀ ≤ Iₙ` for all
`n` (monotone), so `I₀` is a lower bound and equals the term `n = 0`, giving
`I₀ ≤ ⨅ₙ Iₙ ≤ I₀`.  No ascending counterexample can exist — the "paradox" that an
ascending chain has intersection different from its base is impossible.
(Formalized: `Escher.Staircase.iInf_eq_first`.)

## Summary of findings
* Ascending Escher staircase exists ⇔ ring non-Noetherian (proved).
* Loop-back `⨅ = I₀` is automatic (proved).
* `ℕ → 𝔽₂` is an explicit non-Noetherian model (proved).
* The `Int(ℤ)` headline example is descending; its true content is the ℤ
  Anti-Escher collapse (proved for the dyadic chain, bridging the catalog).
