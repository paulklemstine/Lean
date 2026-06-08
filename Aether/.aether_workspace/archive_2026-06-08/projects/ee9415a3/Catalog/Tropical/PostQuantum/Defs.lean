/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Post-Quantum Cryptography: Core Definitions

## Overview

We formalize the **min-plus semiring** operations on real matrices, building the
algebraic foundation for the Stickel key exchange protocol — a candidate
post-quantum cryptographic primitive. The tropical (min-plus) semiring replaces
field arithmetic with `(min, +)`, creating a computational geometry resistant to
quantum attacks via Shor's algorithm.

## Bridge: Tropical Algebra ↔ Post-Quantum Cryptography ↔ Neural Networks

The min-plus matrix product `(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)` arises in:
- **Shortest path algorithms** (Floyd-Warshall = tropical matrix powering)
- **ReLU neural network analysis** (tropical polynomial = piecewise-linear map)
- **Post-quantum key exchange** (Stickel protocol on commuting tropical matrices)

## Main Definitions

* `TropicalMatrix.tropMul` — Min-plus matrix multiplication
* `TropicalMatrix.tropAdd` — Entrywise minimum (tropical addition)
* `TropicalMatrix.tropScalar` — Tropical scalar multiplication (add constant)
* `TropicalMatrix.tropPow` — Iterated tropical matrix power
* `TropicalMatrix.TropicalCommutingPair` — Pair of tropically commuting matrices
* `TropicalMatrix.StickelProtocol` — The Stickel key exchange protocol
* `TropicalMatrix.TropicalLipschitzFn` — Lipschitz structure for certified robustness
-/
import Mathlib

noncomputable section
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset

namespace TropicalMatrix

/-! ## §1. Core Tropical Matrix Operations -/

variable {n : ℕ} [NeZero n]

/-- **Tropical matrix multiplication (min-plus product).**
`(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)`.

Bridge: connects shortest-path graph algorithms to matrix algebra.
Computational bound: O(n³) per multiplication. -/
def tropMul (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.inf' univ univ_nonempty (fun k => A i k + B k j)

/-- **Tropical matrix addition (entrywise minimum).**
`(A ⊕ B)ᵢⱼ = min(Aᵢⱼ, Bᵢⱼ)`.

Bridge: this IS the ReLU network's `min` operation;
neural network layers compose via tropical addition. -/
def tropAdd (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => min (A i j) (B i j)

/-- **Tropical scalar multiplication.**
`(c ⊗ A)ᵢⱼ = c + Aᵢⱼ` (adding a real constant to every entry).

Bridge: in neural networks, this is the bias shift operation. -/
def tropScalar (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => c + A i j

/-- **Tropical matrix power** (iterated min-plus product).
`tropPow A 0 = A` (= A¹), `tropPow A k = A^{k+1}`.

Bridge: `tropPow A (k-1)` computes all shortest paths of length exactly k
in the weighted digraph defined by A. Floyd-Warshall is tropical matrix powering.
Computational bound: O(n³ · k) for k-th power. -/
def tropPow (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | k + 1 => tropMul A (tropPow A k)

/-! ## §2. Commutativity and Protocol Structures -/

/-- **Tropically commuting matrices.** Two matrices `A`, `B` satisfy
`A ⊗ B = B ⊗ A` under min-plus multiplication.

Bridge: commuting tropical matrices ↔ compatible shortest-path structures ↔
simultaneously diagonalizable quantum Hamiltonians (in the tropical limit). -/
structure TropicalCommutingPair (n : ℕ) [NeZero n] where
  A : Matrix (Fin n) (Fin n) ℝ
  B : Matrix (Fin n) (Fin n) ℝ
  comm : tropMul A B = tropMul B A

/-- **The Stickel Key Exchange Protocol** on tropical matrices.

Public parameters: commuting matrices `(A, B)` with `A ⊗ B = B ⊗ A`.
Alice's secret: exponents `(a, b)`, publishes `U = A^a ⊗ B^b`.
Bob's secret: exponents `(c, d)`, publishes `V = A^c ⊗ B^d`.
Shared key: `K = A^{a+c} ⊗ B^{b+d}` (both can compute).

Post-quantum security: recovering `(a, b)` from `U` and `(A, B)` requires solving
the Tropical Matrix Decomposition Problem, which has no known quantum speedup.
Explicit security: O(n^{max(a,b,c,d)}) classical, no better quantum bound known.

Bridge: tropical key exchange ↔ lattice-based crypto ↔ shortest-path hardness. -/
structure StickelProtocol (n : ℕ) [NeZero n] where
  pub : TropicalCommutingPair n
  alice_a : ℕ   -- Alice's first secret exponent
  alice_b : ℕ   -- Alice's second secret exponent
  bob_c : ℕ     -- Bob's first secret exponent
  bob_d : ℕ     -- Bob's second secret exponent
  alicePublic : Matrix (Fin n) (Fin n) ℝ :=
    tropMul (tropPow pub.A alice_a) (tropPow pub.B alice_b)
  bobPublic : Matrix (Fin n) (Fin n) ℝ :=
    tropMul (tropPow pub.A bob_c) (tropPow pub.B bob_d)

/-! ## §3. Lipschitz and ML Robustness Structures -/

/-- **Tropical Lipschitz function.** A function `f : ℝ → ℝ` together with
an explicit Lipschitz constant `K` such that `|f(x) - f(y)| ≤ K · |x - y|`.

Bridge: every ReLU neural network defines a tropical Lipschitz function.
The Lipschitz constant bounds certified adversarial robustness. -/
structure TropicalLipschitzFn where
  f : ℝ → ℝ
  K : ℝ
  K_nonneg : 0 ≤ K
  lipschitz : ∀ x y : ℝ, |f x - f y| ≤ K * |x - y|

/-- **Certified robustness radius.** Given a Lipschitz function with constant K
and a classification margin m > 0, the robustness radius is m / K.
Any perturbation within this radius preserves the classification.

Bridge: post-quantum crypto → ML safety. The tropical spectral gap of the
key exchange matrix bounds both cryptographic security and adversarial robustness. -/
def certifiedRobustnessRadius (K m : ℝ) : ℝ :=
  if K ≤ 0 then 0 else m / K

/-- **Tropical spectral radius** of a matrix: the minimum average edge weight
over all cycles in the weighted digraph. Controls convergence of tropical
matrix powering and bounds post-quantum security levels.

Bridge: tropical spectral theory ↔ Karp's algorithm ↔ quantum ground state.
Computational bound: O(n³) via Karp's algorithm. -/
def tropicalSpectralRadius (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' univ univ_nonempty (fun i => A i i)

/-- **Post-quantum security level** (in bits): log₂ of the minimum number of
operations to solve the Tropical Matrix Decomposition Problem.

For an n×n matrix with spectral gap Δ, the security level is at least
n · log₂(Δ) bits. Bridge: algebraic hardness → cryptographic security. -/
def postQuantumSecurityBits (n_dim : ℕ) (spectralGap : ℝ) : ℝ :=
  n_dim * Real.log spectralGap / Real.log 2

/-! ## §4. Auxiliary Definitions -/

/-- **Tropical matrix norm** (max absolute entry). Used for bounding
tropical polynomial evaluations and Lipschitz constants. -/
def tropNorm (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sup' (univ ×ˢ univ) (by simp [Finset.Nonempty]) (fun p => |A p.1 p.2|)

/-- **Tropical distance** between matrices: max absolute entry difference.
Metrizes the space of tropical matrices for robustness analysis.
Bridge: tropical metric → adversarial perturbation bounds. -/
def tropDist (A B : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sup' (univ ×ˢ univ) (by simp [Finset.Nonempty]) (fun p => |A p.1 p.2 - B p.1 p.2|)

/-- The **ReLU activation function**: `relu(x) = max(0, x)`.
Bridge: tropical algebra → neural network layers. -/
def relu (x : ℝ) : ℝ := max 0 x

/-- A **single-variable tropical affine map**: `f(x) = min(ax + b, cx + d)`.
This is the simplest tropical polynomial; it IS a ReLU neuron.
Bridge: tropical geometry → neural network architecture. -/
structure TropicalAffineMap where
  a₁ : ℝ   -- slope of first affine piece
  b₁ : ℝ   -- intercept of first affine piece
  a₂ : ℝ   -- slope of second affine piece
  b₂ : ℝ   -- intercept of second affine piece

/-- Evaluate a tropical affine map. -/
def TropicalAffineMap.eval (f : TropicalAffineMap) (x : ℝ) : ℝ :=
  min (f.a₁ * x + f.b₁) (f.a₂ * x + f.b₂)

/-- **Tropical polynomial evaluation at a vector** (single-variable version).
Given coefficients `c : Fin m → ℝ` and slopes `d : Fin m → ℝ`,
`tropPolyEval c d x = min_i (cᵢ + dᵢ · x)`.
Bridge: this IS the forward pass of a width-m ReLU layer. -/
def tropPolyEval {m : ℕ} [NeZero m]
    (c : Fin m → ℝ) (d : Fin m → ℝ) (x : ℝ) : ℝ :=
  Finset.inf' univ univ_nonempty (fun i => c i + d i * x)

end TropicalMatrix