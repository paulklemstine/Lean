# Computational Evidence — Zero-Knowledge Proofs in Lean

This note records small-case checks done before formalizing the three Lean files
(`Graph3Coloring.lean`, `QapSnark.lean`, `PCPLocalVerifier.lean`).

## 1. Graph 3-colouring zero-knowledge: the "view is uniform over distinct pairs"

The honest prover commits to a random permutation `π ∈ S₃` of the three colours
and, when challenged on an edge `(u,v)` with distinct endpoint colours `a ≠ b`,
reveals `(π a, π b)`. The simulator (which does **not** know the colouring) just
samples a uniformly random *ordered pair of distinct colours*.

Key counting fact: `|S₃| = 6` and the number of ordered pairs `(x,y)` with
`x ≠ y` in `Fin 3` is `3·2 = 6`. So if `π ↦ (π a, π b)` is injective for fixed
`a ≠ b`, it is automatically a **bijection** onto the distinct pairs. Hence the
real view and the simulated view are *identically distributed* — perfect HVZK.

Enumerated check (`a = 0, b = 1`), listing `(π 0, π 1)` over the 6 permutations:

| π (as image of 0,1,2) | (π 0, π 1) |
|-----------------------|------------|
| 0 1 2 | (0,1) |
| 0 2 1 | (0,2) |
| 1 0 2 | (1,0) |
| 1 2 0 | (1,2) |
| 2 0 1 | (2,0) |
| 2 1 0 | (2,1) |

All six distinct ordered pairs occur exactly once ⇒ bijection ⇒ uniform. ✓

## 2. Soundness gap of the edge-challenge verifier

If the committed colouring `c'` is **not** proper, then by definition some edge
`e ∈ E` has `c' e.1 = c' e.2`. A verifier choosing an edge uniformly at random
therefore rejects with probability `≥ 1/|E|`. (Standard 3-colouring sigma
protocol; gap amplified by repetition.) Tested on `K₃` (triangle, 3 edges):
the non-proper monochromatic colouring is caught on all 3 edges, probability 1.
A colouring proper on 2 of 3 edges is caught with probability `1/3 = 1/|E|`. ✓

## 3. QAP / zk-SNARK soundness (Schwartz–Zippel)

Pinocchio/Groth16-style SNARKs reduce circuit satisfaction to a polynomial
divisibility test `t(x) ∣ p(x)`, checked at a single random point `s` by
`p(s) = h(s)·t(s)`. If the prover lies (`p ≠ h·t`), the discrepancy polynomial
`p - h·t` is nonzero and vanishes at `≤ deg(p - h·t)` points, so the cheating
probability is `≤ deg(p - h·t)/|F|`. Over `F = ZMod 5`, `p = X²`, `t = X`,
dishonest `h = 1` (so `h·t = X`): `p - h·t = X² - X` has roots `{0,1}`, i.e.
2 of 5 points pass — matching `deg = 2`. ✓

These checks confirm the three formal theorems are true and non-vacuous before
the Lean proofs were attempted.
