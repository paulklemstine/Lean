# Computational Evidence — Knotted Light Topology

## 1. Charge of torus-knot beams `w = p·q`

| (p, q)   | p·q | gcd | lcm | knot/link              |
|----------|-----|-----|-----|------------------------|
| (2, 3)   | 6   | 1   | 6   | trefoil (knot)         |
| (2, 5)   | 10  | 1   | 10  | Solomon / (2,5) knot   |
| (3, 4)   | 12  | 1   | 12  | (3,4) torus knot       |
| (2, 4)   | 8   | 2   | 4   | split link (2 comps)   |
| (3, 6)   | 18  | 3   | 6   | split link (3 comps)   |

Observation: `lcm p q = p·q` exactly when `gcd(p,q)=1`, i.e. exactly for the
genuine torus **knots**; the composite pairs give `lcm < p·q` and split into
`gcd(p,q)` components. This matches `winding_torusBeam_coprime`.

## 2. Additivity of charge (product rule) — spot checks

For pure phases `exp(i ℓ θ)`:

| ℓ  | m  | ℓ+m | w(φ)+w(ψ) |
|----|----|-----|-----------|
| +1 | +1 |  2  |    2      |
| +2 | -3 | -1  |   -1      |
| +5 |  0 |  5  |    5      |
| -1 | +1 |  0  |    0      | (annihilation)

Every row satisfies `w(φ·ψ) = w(φ) + w(ψ)`, consistent with `winding_mul` and its
corollary `winding_oamPhase_mul`.

## 3. Envelope invariance

Multiplying `exp(iℓθ)` by any nonzero constant `c` (or the radial factor
`r^{|ℓ|}` with `r>0`) leaves the computed winding number at `ℓ`, confirming
`winding_smul_left` and `winding_beamAmp`.

## 4. Notes

The claims are finite/closed-form and are fully settled by the proved theorems in
`KnottedLightTopology.lean`; no counterexample was found in the sampled range, as
expected from the general proofs.


# Computational Evidence — Knotted Light Topology

## 1. Charge of torus-knot beams `w = p·q`

| (p, q)   | p·q | gcd | lcm | knot/link              |
|----------|-----|-----|-----|------------------------|
| (2, 3)   | 6   | 1   | 6   | trefoil (knot)         |
| (2, 5)   | 10  | 1   | 10  | Solomon / (2,5) knot   |
| (3, 4)   | 12  | 1   | 12  | (3,4) torus knot       |
| (2, 4)   | 8   | 2   | 4   | split link (2 comps)   |
| (3, 6)   | 18  | 3   | 6   | split link (3 comps)   |

Observation: `lcm p q = p·q` exactly when `gcd(p,q)=1`, i.e. exactly for the
genuine torus **knots**; the composite pairs give `lcm < p·q` and split into
`gcd(p,q)` components. This matches `winding_torusBeam_coprime`.

## 2. Additivity of charge (product rule) — spot checks

For pure phases `exp(i ℓ θ)`:

| ℓ  | m  | ℓ+m | w(φ)+w(ψ) |
|----|----|-----|-----------|
| +1 | +1 |  2  |    2      |
| +2 | -3 | -1  |   -1      |
| +5 |  0 |  5  |    5      |
| -1 | +1 |  0  |    0      | (annihilation)

Every row satisfies `w(φ·ψ) = w(φ) + w(ψ)`, consistent with `winding_mul` and its
corollary `winding_oamPhase_mul`.

## 3. Envelope invariance

Multiplying `exp(iℓθ)` by any nonzero constant `c` (or the radial factor
`r^{|ℓ|}` with `r>0`) leaves the computed winding number at `ℓ`, confirming
`winding_smul_left` and `winding_beamAmp`.

## 4. Notes

The claims are finite/closed-form and are fully settled by the proved theorems in
`KnottedLightTopology.lean`; no counterexample was found in the sampled range, as
expected from the general proofs.
