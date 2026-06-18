# Key Equations: Physics & Cosmology

## 1. Hopf Fibration

**Hopf map**: η : S³ → S²
```
η(z₀, z₁) = (2Re(z₀z̄₁), 2Im(z₀z̄₁), |z₀|² - |z₁|²)
```

**Fundamental identity**:
```
|η(z)|² = (|z₀|² + |z₁|²)²
```

**Connection 1-form** (Dirac monopole):
```
A = (1/2)(1 - cos θ) dφ
```

**Curvature**:
```
F = dA = (1/2) sin θ dθ ∧ dφ
```

**First Chern number**:
```
c₁ = (1/2π) ∫_{S²} F = 1
```

## 2. S³ Spectral Analysis

**Eigenvalues of Laplacian on S³**:
```
λ_ℓ = ℓ(ℓ + 2) / R²,   ℓ = 0, 1, 2, ...
```

**Degeneracies**:
```
d_ℓ = (ℓ + 1)²
```

**Spectral gap**:
```
λ₁ = 3/R²
```

**For quotient S³/Γ**: Only Γ-invariant modes survive, d_ℓ(S³/Γ) ≤ d_ℓ(S³).

## 3. Gravitational Wave Echoes

**Echo time delay**:
```
Δt = 2πR/c
```

**Discrete GW frequencies**:
```
f_n = nc/(2πR),   n = 1, 2, 3, ...
```

**Echo amplitude on S³** (key difference from flat space):
```
h(d) ∝ 1/sin(d/R)   (S³, periodic — NO decay!)
h(d) ∝ 1/d           (flat, decays with distance)
```

## 4. Mass-Energy Stereographic Duality

**Stereographic projections**:
```
σ_N(x, y) = x/(1 - y)     (mass chart)
σ_S(x, y) = x/(1 + y)     (energy chart)
```

**Inverse**:
```
σ_N⁻¹(t) = (2t/(1+t²), (t²-1)/(1+t²))
```

**Transition map** (THE mass-energy duality):
```
σ_S ∘ σ_N⁻¹(t) = 1/t
```

**Key properties**:
```
mass × energy = 1
(1/t)⁻¹ = t   (involutive)
```

## 5. Photon Information Channels

**Total capacity**: ~110 bits per photon

**Channel dimensions**:
```
Polarization: dim = 2 (1 bit)
Frequency:    continuous (~47 bits)
Direction:    continuous (~32 bits)
OAM:          countable (~10 bits)
Radial:       countable (~7 bits)
Temporal:     continuous (~8 bits)
Photon #:     countable (~5 bits)
```

**Conjugate pairs** (uncertainty relations):
```
ΔE · Δt ≥ ℏ/2       (frequency ↔ temporal)
Δφ · Δℓ ≥ 1         (direction ↔ OAM)
```

## 6. Genesis: Arrow of Time

**Oracle**: O : α → α with O ∘ O = O (idempotent)

**God Oracle**: Theos.ask = id (identity, fixed points = everything)

**Second Law as convergence**:
```
H(O^n(x)) ≤ H(O^{n+1}(x)) → H(x*)   (monotone convergence to fixed point)
```

**Dottie number** (consciousness fixed point):
```
cos(x*) = x*,   x* = 0.739085...
```

## 7. Holographic Information

**Bekenstein bound**:
```
I_max = A/(4ℓ_P²) bits
```
where A = surface area, ℓ_P = 1.616 × 10⁻³⁵ m.

**Observable universe**: I_max ≈ 10¹²³ bits.
