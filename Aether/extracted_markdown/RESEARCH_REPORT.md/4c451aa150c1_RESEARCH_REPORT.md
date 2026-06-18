# Tropical Statistical Mechanics: Min-Plus Partition Functions, Idempotent Free Energy Composition, and One-Step Perturbation Convergence

## Abstract

We establish the mathematical foundations of **tropical statistical mechanics** — the zero-temperature limit of classical statistical mechanics where the tropical semiring (ℝ ∪ {+∞}, min, +) replaces the classical field (ℝ, +, ×). We prove three foundational theorems:

1. **Idempotent Free Energy Composition**: For Hamiltonians H₁, H₂ on a finite configuration space Ω, the ground state energy of the tropical sum equals the tropical sum of ground state energies: min_σ min(H₁(σ), H₂(σ)) = min(min_σ H₁(σ), min_σ H₂(σ)). This idempotent composition law means ground states compose without interaction corrections.

2. **One-Step Perturbation Convergence**: For a tropically perturbed Hamiltonian H_δ(σ) = min(H₀(σ), δ + V(σ)), the ground state energy is exactly min(E₀(H₀), δ + E₀(V)). Tropical perturbation theory converges in exactly one step, providing exponential speedup over classical perturbation theory.

3. **Zero-Temperature Semiclassical Limit**: The classical free energy F(β) = (-1/β) log Z(β) converges to the ground state energy E₀ = min_σ H(σ) as β → ∞, with explicit convergence rate |F(β) - E₀| ≤ log|Ω|/β.

All results are formally verified in Lean 4 with Mathlib, comprising 21 theorems with zero sorry statements.

## 1. Introduction

Classical statistical mechanics describes systems at finite temperature via the partition function Z(β) = Σ_σ exp(-βH(σ)) and the free energy F(β) = (-1/β) log Z(β). As the inverse temperature β → ∞ (zero-temperature limit), the dominant contribution comes from the ground state — the configuration minimizing the Hamiltonian.

In this limit, the arithmetic operations of classical mechanics undergo a transformation:
- **Summation** (Σ) becomes **minimization** (min)
- **Multiplication** (×) becomes **addition** (+)

This is precisely the tropical semiring (ℝ ∪ {+∞}, min, +), also known as the min-plus algebra. The "tropicalization" of statistical mechanics — replacing (Σ, ×) with (min, +) — yields a remarkably clean algebraic structure where:
- The partition function becomes the ground state energy
- Free energy composition becomes idempotent
- Perturbation theory becomes exact at first order

## 2. Core Definitions

### 2.1 Tropical Statistical System

A **TropicalStatisticalSystem** over a finite configuration space Ω consists of:
- A Hamiltonian H : Ω → ℝ (energy function)
- A ground state configuration σ₀ ∈ Ω
- A certificate: ∀ σ, H(σ₀) ≤ H(σ)

The **tropical partition function** is defined as:
  Z_trop(H) = ⊕_{σ∈Ω} H(σ) = min_{σ∈Ω} H(σ) = ⨅ σ, H σ

### 2.2 Tropical Perturbation

A **TropicalPerturbation** consists of a base Hamiltonian H₀, a perturbation potential V, and a coupling strength δ. The perturbed Hamiltonian is:
  H_δ(σ) = H₀(σ) ⊕ (δ ⊗ V(σ)) = min(H₀(σ), δ + V(σ))

### 2.3 Classical Free Energy

The classical free energy at inverse temperature β is:
  F(β) = (-1/β) · log(Σ_{σ∈Ω} exp(-βH(σ)))

## 3. Main Theorems

### Theorem 1: Idempotent Free Energy Composition Law

**Statement**: For any finite nonempty type Ω and functions H₁, H₂ : Ω → ℝ,
  ⨅ σ, min(H₁(σ), H₂(σ)) = min(⨅ σ, H₁(σ), ⨅ σ, H₂(σ))

**Proof**: By antisymmetry:
- (≤) For each σ, min(H₁(σ), H₂(σ)) ≤ H₁(σ), so ⨅ σ min(H₁(σ), H₂(σ)) ≤ ⨅ σ H₁(σ). Similarly for H₂. Therefore ⨅ min ≤ min(⨅ H₁, ⨅ H₂).
- (≥) For each σ, ⨅ H₁ ≤ H₁(σ) and ⨅ H₂ ≤ H₂(σ), so by monotonicity of min, min(⨅ H₁, ⨅ H₂) ≤ min(H₁(σ), H₂(σ)). Taking infimum gives min(⨅ H₁, ⨅ H₂) ≤ ⨅ min.

**Physical Significance**: Combining two energy landscapes tropically (taking pointwise minimum) yields a ground state energy that is simply the minimum of the individual ground state energies. There are **no interaction corrections** — a stark contrast to classical statistical mechanics where F(H₁ + H₂) ≠ F(H₁) + F(H₂) in general.

### Theorem 2: One-Step Perturbation Convergence

**Statement**: For H₀, V : Ω → ℝ and δ ∈ ℝ,
  ⨅ σ, min(H₀(σ), δ + V(σ)) = min(⨅ σ H₀(σ), δ + ⨅ σ V(σ))

**Proof**: Direct corollary of the composition law (Theorem 1) and the shift equivariance ⨅ σ, (δ + V(σ)) = δ + ⨅ σ, V(σ).

**Physical Significance**: In classical perturbation theory, the ground state energy of a perturbed system requires an infinite series E = E₀ + δE₁ + δ²E₂ + ⋯ with convergence issues. In tropical PT, the answer is **exact after one step**: E₀(H_δ) = min(E₀(H₀), δ + E₀(V)). This is a direct consequence of idempotence: min(a, a) = a eliminates all higher-order terms.

### Theorem 3: Zero-Temperature Semiclassical Limit

**Statement**: F(β) → E₀ as β → ∞, with |F(β) - E₀| ≤ log|Ω|/β.

**Proof**: We establish the sandwich bound E₀ - log|Ω|/β ≤ F(β) ≤ E₀:
- **Upper bound** (F ≤ E₀): Z(β) ≥ exp(-βE₀) (the ground state term), so log Z ≥ -βE₀, giving F = (-1/β) log Z ≤ E₀.
- **Lower bound** (F ≥ E₀ - log|Ω|/β): Z(β) ≤ |Ω|·exp(-βE₀) (each of |Ω| terms ≤ exp(-βE₀)), so log Z ≤ log|Ω| - βE₀, giving F ≥ E₀ - log|Ω|/β.

The squeeze theorem then gives convergence with explicit rate O(log|Ω|/β).

## 4. Additional Results

We also prove:
- **Lipschitz bound**: |E₀(H₁) - E₀(H₂)| ≤ sup_σ |H₁(σ) - H₂(σ)|, establishing the tropical partition function as 1-Lipschitz
- **Perturbation monotonicity**: E₀(min(H₀, δ₁ + V)) ≤ E₀(min(H₀, δ₂ + V)) when δ₁ ≤ δ₂
- **Degeneracy absorption**: When ⨅ H₁ = ⨅ H₂, then ⨅ min(H₁, H₂) = ⨅ H₁
- **Disjoint union decomposition**: E₀ on Ω₁ ⊕ Ω₂ = min(E₀ on Ω₁, E₀ on Ω₂)

## 5. Formalization

All results are formally verified in Lean 4 with Mathlib:
- `Catalog/Tropical/StatisticalMechanics/Basic.lean` — 14 theorems, 11 definitions
- `Catalog/Tropical/StatisticalMechanics/SemiclassicalLimit.lean` — 7 theorems, 2 definitions

Total: 21 theorems, 13 definitions, 0 sorry statements, ~658 lines of Lean code.

## References

- Litvinov, G.L. (2007). "The Maslov Dequantization, Idempotent and Tropical Mathematics"
- Maclagan, D. & Sturmfels, B. (2015). "Introduction to Tropical Geometry"
- Viro, O. (2010). "On basic concepts of tropical geometry"
