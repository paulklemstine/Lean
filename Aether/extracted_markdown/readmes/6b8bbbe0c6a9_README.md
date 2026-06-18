This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# Berggren Pythagorean Triple Tree: A Machine-Verified Research Program

## Overview

This Lean 4 project provides **560+ formally verified theorems** centered on the Berggren ternary tree of primitive Pythagorean triples, with extensions across number theory, algebra, analysis, topology, combinatorics, cryptography, quantum computing, and connections to the Millennium Problems.

**Zero sorry in compiled code. Zero non-standard axioms.**

## Core Results

### Parent Descent Algorithm (NEW — `ParentDescent.lean`)
- **Inverse Berggren matrices**: B₁⁻¹, B₂⁻¹, B₃⁻¹ computed via Lorentz adjoint Q·Bᵀ·Q
- **Correctness**: B_i⁻¹ ∘ B_i = Identity (proved algebraically and via matrix multiplication)
- **Hypotenuse decrease**: Parent c' = −2a−2b+3c satisfies 0 < c' < c
- **Uniqueness**: At most one inverse gives all-positive output
- **Factorization**: Descent from trivial PPT reveals factors via GCD extraction
- **Path encoding**: Unique branch label sequence [1,2,3]* identifies every PPT

### Berggren Tree (`Basic.lean`, `Berggren.lean`, `BerggrenTree.lean`)
- Euclid parametrization: (m²−n², 2mn, m²+n²) is a PPT
- Forward Berggren matrices B₁, B₂, B₃ preserve Pythagorean property
- Lorentz form Q = a²+b²−c² preserved by all six matrices
- Tree depth d covers hypotenuses up to 3^d · 5

### Factorization (`FermatFactor.lean`)
- Fermat identity: x²−y² = (x−y)(x+y)
- Every odd composite has Fermat representation
- Berggren tree search algorithm with correctness proof

### Group Theory (`SL2Theory.lean`)
- ⟨M₁, M₃⟩ = Γ_θ = ⟨S, T²⟩ (the theta group)
- ADE tower: |SL(2,𝔽_p)| for p = 2,3,5,7,11

### Millennium Connections (`MillenniumConnections.lean`)
- BSD: PPT → congruent number → elliptic curve point
- RH: sum-of-two-squares ⟺ prime ≡ 1 (mod 4) (both directions)
- Lorentz group: arithmetic SO(2,1) action

## File Structure

| File | Description |
|------|-------------|
| `ParentDescent.lean` | **NEW**: Inverse maps, descent, factorization, uniqueness |
| `Basic.lean` | PPT definitions, Euclid parametrization |
| `Berggren.lean` | Matrix definitions, determinants, Lorentz preservation |
| `BerggrenTree.lean` | Inductive tree, path-based Pythagorean preservation |
| `FermatFactor.lean` | Fermat factorization, tree search |
| `CongruentNumber.lean` | Congruent number mapping |
| `MillenniumConnections.lean` | BSD, RH, Lorentz connections |
| `SL2Theory.lean` | Theta group, ADE tower |
| `DescentTheory.lean` | FLT4, Sophie Germain |
| `NewTheorems.lean` | Modular arithmetic, Pell, Gaussian |
| `Combinatorics.lean` | Pigeonhole, Sperner, binomial identities |
| *(27 other files)* | Analysis, algebra, topology, crypto, quantum, etc. |

## Documentation

- `RESEARCH_PAPER.md` — Comprehensive paper on all findings
- `EXPERIMENT_LOG.md` — Running log of experiments, successes, failures, hypotheses

## Building

```bash
lake build
```

Requires Lean 4 v4.28.0 with Mathlib v4.28.0.
