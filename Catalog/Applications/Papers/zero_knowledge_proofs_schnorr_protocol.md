# Computational Evidence — Schnorr Protocol

The formalized claims are algebraic identities and a finite-field extraction formula, so
the relevant "evidence" is small concrete instantiations checking the extractor and the
verification equation. All checks below were run in Lean over `ZMod 11`
(`G = Multiplicative (ZMod 11)` is cyclic of order 11, generator `g = ofAdd 1`).

## Witness-extraction spot checks

Extractor: `ext z₁ z₂ c₁ c₂ = (z₁ - z₂) * (c₁ - c₂)⁻¹` in `ZMod 11`, with honest responses
`zᵢ = r + cᵢ · x`.

| secret x | r | c₁ | c₂ | z₁ = r+c₁x | z₂ = r+c₂x | `ext` output | matches x? |
|----------|---|----|----|------------|------------|--------------|------------|
| 4        | 7 | 2  | 9  | 15≡4       | 43≡10      | 4            | ✓          |
| 9        | 3 | 5  | 1  | 48≡4       | 12≡1       | 9            | ✓          |

`#eval (ext (7+2*4) (7+9*4) 2 9, (4 : ZMod 11))  -- (4, 4)`
`#eval (ext (3+5*9) (3+1*9) 5 1, (9 : ZMod 11))  -- (9, 9)`

The extractor recovers the secret independent of the (unknown) commitment randomness `r`,
exactly as `schnorr_extract` proves in general for prime-order groups.

## Completeness / HVZK

Completeness (`g^z = a·pk^c`) and the simulator's back-computed commitment
`a = g^z·pk^(-c)` are unconditional group identities; they hold in every group and require
no numerical search. No counterexample exists, and none was sought beyond confirming the
`group`-tactic normal forms close.

## Counterexample hunt

The only non-trivial universal claim is extraction, whose single hypothesis is
`c₁ ≢ c₂ (mod q)`. Dropping it makes `c₁ - c₂` non-invertible and extraction must fail —
this matches the `hne : (c₁ : ZMod q) - c₂ ≠ 0` step being load-bearing in the proof. No
counterexample to the stated (hypothesis-bearing) theorems was found.
