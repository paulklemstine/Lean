# EML Cryptographic Primitives: Closure One-Way Functions, Idempotent Sigma Protocols, and Fixed-Point Key Exchange

## Abstract

We present a formal verification in Lean 4 of the algebraic foundations connecting closure operators from order theory to cryptographic protocol design. We define an `EMLClosureOperator` typeclass capturing extensiveness, monotonicity, and idempotence, and construct the **closure min** function `closureMin(x) = min(cl({x}))` as a candidate one-way function. We prove 30+ theorems with zero `sorry` statements, including:

1. **Idempotence of closureMin** — `closureMin(closureMin(x)) = closureMin(x)` for all `x`, establishing that closureMin is a retraction onto its fixed-point set.
2. **Sigma protocol completeness, special soundness, and HVZK** — a Σ-protocol for proving knowledge of preimages under closureMin, where the zero-knowledge simulator exploits idempotence.
3. **Key exchange fixed-point properties** — in a two-party key exchange using independent closure operators, each party's shared secret is a fixed point of their own operator.
4. **Commuting closure collapse** — when two closure operators commute, iterated application stabilizes in one step.

## 1. Introduction

The study of one-way functions traditionally relies on computational hardness assumptions (factoring, discrete logarithm, lattice problems). We explore an alternative algebraic approach: using the structure of closure operators to define functions that are easy to compute forward but structurally difficult to invert.

A **closure operator** on a set `C` is a function `cl : P(C) → P(C)` satisfying:
- **Extensiveness**: `A ⊆ cl(A)` for all `A`
- **Monotonicity**: `A ⊆ B → cl(A) ⊆ cl(B)`
- **Idempotence**: `cl(cl(A)) = cl(A)` for all `A`

These operators arise naturally in algebra (algebraic closure), topology (topological closure), logic (consequence operators), and lattice theory.

## 2. The Closure Min Function

Given a finite linearly ordered type `C` with a closure operator, we define:

```
closureMin(x) = min(cl({x}))
```

This function has remarkable algebraic properties:

**Theorem (Idempotence).** `closureMin(closureMin(x)) = closureMin(x)` for all `x`.

*Proof.* Two inequalities:
- `closureMin(closureMin(x)) ≤ closureMin(x)`: by `closureMin_le_self` applied to `closureMin(x)`.
- `closureMin(x) ≤ closureMin(closureMin(x))`: since `closureMin(closureMin(x)) ∈ cl({closureMin(x)})` by extensiveness, and `cl({closureMin(x)}) ⊆ cl({x})` by monotonicity + idempotence, we get `closureMin(closureMin(x)) ∈ cl({x})`, so `closureMin(x) ≤ closureMin(closureMin(x))` by minimality. □

**Corollary.** The image of `closureMin` equals its fixed-point set: `range(closureMin) = {x | closureMin(x) = x}`.

## 3. Idempotent Sigma Protocol

We define a Σ-protocol for proving knowledge of a preimage under closureMin:

- **Commit**: Prover sends `a = closureMin(r)` for witness `r`
- **Challenge**: Verifier sends `e ∈ {0, 1}`
- **Response**: If `e = 0`, send `r`; if `e = 1`, send `closureMin(r)`
- **Verify**: If `e = 0`, check `closureMin(z) = a`; if `e = 1`, check `z = a`

**Theorem (Completeness).** The honest prover is always accepted.

**Theorem (Special Soundness).** From two accepting transcripts `(a, 0, z₀)` and `(a, 1, z₁)`, we extract `closureMin(z₀) = z₁ = a`.

**Theorem (HVZK).** The simulator, given only the target (not the witness), produces accepting transcripts:
- For `e = 1`: output `(target, 1, target)` — trivially accepting.
- For `e = 0`: output `(closureMin(x), 0, x)` for any `x` — accepting by definition.

The key insight: for `e = 0`, the real transcript has commitment `closureMin(witness)`, and the simulated transcript has commitment `closureMin(x)`. When the target is a fixed point (which it always is, by idempotence), these are indistinguishable.

## 4. Fixed-Point Key Exchange

Two parties, Alice and Bob, each have their own closure operator (`cl_A`, `cl_B`) on the same type:

1. Alice publishes `pubA = closureMin_A(secretA)`
2. Bob publishes `pubB = closureMin_B(secretB)`
3. Alice computes `ssA = closureMin_A(pubB)`
4. Bob computes `ssB = closureMin_B(pubA)`

**Theorem.** Each party's shared secret is a fixed point of their own operator:
- `closureMin_A(ssA) = ssA`
- `closureMin_B(ssB) = ssB`

**Theorem.** The shared secrets are bounded: `ssA ≤ pubB` and `ssB ≤ pubA`.

When the operators commute (`cl_A(cl_B(A)) = cl_B(cl_A(A))`), the shared secrets may agree, analogous to the Diffie-Hellman property `g^{ab} = g^{ba}`.

## 5. Formal Verification

All results are formalized in Lean 4 using Mathlib, with:
- **0 sorry statements** — every theorem has a complete machine-checked proof
- **Only standard axioms**: `propext`, `Classical.choice`, `Quot.sound`
- **Diverse proof techniques**: term-mode proofs, tactic proofs (`simp`, `rw`, `calc`, `refine`, `subst`, `unfold`), and structural arguments

### Key definitions:
- `EMLClosureOperator` — typeclass
- `closureMin` — one-way function candidate
- `sigmaVerify` — protocol verification
- `FixedPointKeyExchange` — key exchange structure
- `ClosureOWF` — one-way function package
- `IdempotentSigmaProtocol` — protocol instance
- `CommutingClosures` — commutativity predicate

## 6. Limitations and Honest Assessment

We should be transparent about the scope of this formalization:

1. **No computational hardness**: On finite types with decidable equality, the closure operator and its inverse are both computable. The "one-way" property is purely algebraic (the function is order-decreasing and idempotent), not cryptographically hard in the complexity-theoretic sense.

2. **Idealized protocols**: The sigma protocol and key exchange are algebraic abstractions. Real cryptographic security requires computational hardness assumptions that are not formalized here.

3. **The bridge is structural, not security-theoretic**: We prove that closure operators give rise to functions with the right algebraic shape for cryptographic use (idempotent projections, fiber structure). Proving actual security would require complexity-theoretic or information-theoretic arguments beyond the scope of this formalization.

## 7. Connections to Existing Work

- **Closure operators in Mathlib**: Mathlib has `ClosureOperator` for lattices; our `EMLClosureOperator` operates on the power set, providing a different interface suitable for cryptographic applications.
- **Tropical cryptography**: The `closureMin` function performs a min-operation reminiscent of tropical semiring arithmetic, connecting to tropical hash function constructions.
- **Tarski's fixed-point theorem**: The fixed-point structure of closure operators connects to Tarski's theorem on complete lattice fixed points.

## References

1. Birkhoff, G. (1967). *Lattice Theory*, 3rd ed. AMS.
2. Goldreich, O. (2001). *Foundations of Cryptography*, Vol. 1. Cambridge University Press.
3. Davey, B.A. & Priestley, H.A. (2002). *Introduction to Lattices and Order*, 2nd ed. Cambridge University Press.
