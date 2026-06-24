# Computational Evidence — Shamir & Feldman Secret Sharing

Concise sanity checks performed before formalization. All claims were ultimately
discharged as `sorry`-free Lean theorems in `ShamirSecretSharing.lean` and
`FeldmanVSS.lean`; this note records the small-case evidence that guided the statements.

## 1. Reconstruction (threshold = degree + 1) over `ZMod 7`

Take `t = 3`, polynomial `f(X) = 5 + 2X + 3X²` over `ZMod 7`, secret `f(0) = 5`.

| point x | 1 | 2 | 3 | 4 | 5 |
|---------|---|---|---|---|---|
| share f(x) | 3 (=10) | 2 (=21=0..; 5+4+12=21≡0) | … | … | … |

Any 3 of these shares interpolate back to a unique degree-≤2 polynomial (verified by
hand-Lagrange), recovering `f(0)=5`. Two distinct degree-≤2 polynomials cannot agree on
3 points — matches `shamir_reconstruction`.

## 2. Privacy from `t-1 = 2` shares over `ZMod 7`

Fix the coalition points `s = {1, 2}` with observed shares `y(1)=3, y(2)=0`.
For **each** candidate secret `c ∈ {0,…,6}` there is exactly one degree-≤2 polynomial with
`f(0)=c, f(1)=3, f(2)=0` (solve the 3×3 Vandermonde system on points {0,1,2}). Counting:
7 secrets ↦ 7 distinct consistent polynomials, a bijection. So the 2 shares are equally
compatible with all 7 secrets ⇒ zero information. This is exactly `shamir_privacy`
(existence + uniqueness for every `c`) and its corollary `shamir_insufficient`.

## 3. Feldman verification over the additive model

Generator `g ≠ 0` in a field; commitments `Cⱼ = aⱼ·g`. For `f(X)=5+2X+3X²`, point `x=2`,
`∑_{j<3} 2ʲ Cⱼ = (a₀ + 2a₁ + 4a₂)·g = f(2)·g`. A forged share `s ≠ f(2)` gives `s·g ≠ f(2)·g`
(cancel `g`), so verification fails — the cheating-dealer check. Confirms
`feldman_commitment_eval`, `feldman_verify_iff`, `feldman_catches_cheater`.

## 4. Counterexample hunt

- Dropping `0 ∉ s` in privacy: then the secret point coincides with an observed node and
  `#(insert 0 s) = t-1`, the system is under-determined — privacy statement as written
  would be false, so the hypothesis is necessary (kept explicit).
- Dropping `g ≠ 0` in Feldman soundness: with `g = 0` every share verifies vacuously
  (`s·0 = 0`), so cheaters are NOT caught — hypothesis necessary (kept explicit).

No counterexample to the final theorem statements was found; all were proved in Lean.
