# Computational Evidence — Schnorr Σ-protocol compositions & generalizations

This note records the small-case numerical checks performed *before* writing the
formal Lean proofs in this research cycle. The two new artifacts are:

* `SchnorrOrProof.lean` — the Cramer–Damgård–Schoenmakers OR-composition of two
  Schnorr instances (proof of knowledge of *one of two* discrete logs).
* `MaurerPreimageProtocol.lean` — the Maurer unified "preimage of a group
  homomorphism" Σ-protocol generalizing Schnorr to arbitrary additive abelian
  groups, including the hidden-order / integer-challenge regime.

All claims here are algebraic identities; they were verified with `#eval` over a
concrete small prime field before formalization, and are *separately* proved in
Lean (so this file is supporting evidence, not the source of truth).

## 1. OR-proof over `ZMod 23`, generator `g = 5`

Setup: secret `x₁ = 7`, `Y₁ = x₁·g`, `Y₂ = 11` (witness for branch 2 unknown).
Honest prover knows branch 1, uses real randomness `r₁ = 3`, simulates branch 2
with `(c₂, s₂) = (9, 4)`, verifier challenge `c = 17`.

Derived: `t₁ = r₁·g`, `t₂ = s₂·g − c₂·Y₂`, `c₁ = c − c₂`, `s₁ = r₁ + c₁·x₁`.

| check | result |
|-------|--------|
| `c₁ + c₂ = c` (challenge split) | ✓ |
| `s₁·g = t₁ + c₁·Y₁` (branch 1) | ✓ |
| `s₂·g = t₂ + c₂·Y₂` (branch 2, simulated) | ✓ |

**Special soundness.** A second accepting transcript with the *same* `(t₁,t₂)` but
challenge `c' = 2` (re-using `c₂' = c₂`, so `c₁' = c' − c₂ ≠ c₁`) extracts the
branch-1 witness:

| check | result |
|-------|--------|
| `(c₁ − c₁')⁻¹·(s₁ − s₁') = x₁` | ✓ |

i.e. distinct overall challenges force distinct sub-challenges in some branch, and
that branch yields a genuine discrete-log witness.

## 2. Maurer preimage protocol

Two regimes, both reducing to one Bézout / inversion identity:

* **Field/module regime** (challenges in a field `F`, `c₁ ≠ c₂`):
  from `φ(s₁) = t + c₁·Y` and `φ(s₂) = t + c₂·Y` we get
  `φ((c₁−c₂)⁻¹·(s₁−s₂)) = Y`, so `x = (c₁−c₂)⁻¹·(s₁−s₂)` is a preimage. This
  specializes to Schnorr (`φ = (·*g)` on `ZMod p`) and to the affine-matrix
  extractor already in the catalog.
* **Hidden-order / integer-challenge regime**: given a "special preimage"
  `φ(u) = ℓ·Y` with `IsCoprime ℓ (c₁−c₂)`, Bézout coefficients
  `a·ℓ + b·(c₁−c₂) = 1` give the preimage `x = a·u + b·(s₁−s₂)` with
  `φ(x) = Y`. This needs no inverse and works in groups of unknown order.

Both identities are pure `AddMonoidHom`/`zsmul` algebra and were confirmed by hand
on `ZMod 24` (`φ = (·*5)`, `Y = 5`, `ℓ = 1`, `u = 1`, challenge difference `7`,
`IsCoprime 1 7`) before formalization.

## Why no exhaustive counterexample hunt

The statements are universally-quantified algebraic identities over commutative
(semi)rings / modules, not number-theoretic conjectures with potential sporadic
counterexamples. The decisive risk is a *mis-stated* equation, which the small
concrete instances above already catch; the Lean proofs then certify the universal
claim.
