# Computational Evidence — Topology of Knotted Light

We study the OAM phase field `φ_ℓ(θ) = exp(i ℓ θ)` and its topological charge
(winding number) `w(φ) = (1/2πi) ∮ φ'/φ dθ`.

## 1. Small-case calculations of the winding number

For `φ_ℓ`, the logarithmic derivative is constant: `φ'/φ = iℓ`, so

    w(φ_ℓ) = (1/2πi) · (iℓ) · (2π) = ℓ.

| ℓ  | φ'/φ | ∮ over [0,2π] | winding w |
|----|------|---------------|-----------|
| 0  | 0    | 0             | 0         |
| 1  | i    | 2πi           | 1         |
| 2  | 2i   | 4πi           | 2         |
| -1 | -i   | -2πi          | -1        |
| -3 | -3i  | -6πi          | -3        |

The winding number reproduces the charge exactly, including negative (opposite
handedness) vortices. This matches `winding_oamPhase`.

## 2. Charge additivity / conservation

Multiplying beams multiplies phases and adds exponents:
`φ_ℓ · φ_m = exp(i(ℓ+m)θ) = φ_{ℓ+m}`, hence `w = ℓ + m`. Iterating over a family
gives `w(∏_i φ_{f i}) = Σ_i f i`. Spot check `{1, 2, -1}` → total charge `2`.
This matches `oamPhase_mul`, `oamPhase_prod`, `winding_additive`.

## 3. Amplitude / phase singularity

The amplitude `A_ℓ(r,θ) = r^{|ℓ|} exp(iℓθ)` satisfies:
- `A_ℓ(0,θ) = 0` whenever `ℓ ≠ 0` (on-axis phase singularity of knotted light);
- `A_ℓ(r,θ) ≠ 0` for every `r > 0`.

Matches `beamAmp_vanishes`, `beamAmp_nonzero`.

## 4. Counterexample hunt (contrarian conjectures)

- **"Charge is always ≥ 0."** FALSE: `ℓ = -1` gives `w = -1`. See
  `winding_can_be_negative`.
- **"A product of two vortex beams is again a vortex beam."** FALSE: opposite
  charges annihilate, `φ_ℓ · φ_{-ℓ} = 1`, a nonvanishing constant with `w = 0`
  and no singularity. See `oam_annihilation`, `oam_annihilation_nonvanishing`.

## 5. Sequence note

The winding numbers of `φ_ℓ` for `ℓ = 0,1,2,3,...` are simply the integers `0,1,2,3,…`
(OEIS A001477); nothing more exotic appears, which is precisely the quantization
statement `winding_quantized`.
