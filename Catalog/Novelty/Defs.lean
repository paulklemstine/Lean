import Mathlib

/-!
# Neural Hodge Theory: Core Definitions

Combinatorial-algebraic framework for analyzing the topological complexity
of ReLU neural network decision surfaces.
-/

open Finset BigOperators

/-! ## Abstract f-vector -/

/-- An abstract f-vector of dimension at most `d`. The value `f k` represents
    the number of k-dimensional faces of a polyhedral complex. -/
structure FVectorData (d : ℕ) where
  /-- Number of faces of each dimension -/
  f : Fin (d + 1) → ℕ

namespace FVectorData

variable {d : ℕ}

/-- Total number of faces across all dimensions. -/
def totalFaces (v : FVectorData d) : ℕ :=
  ∑ i : Fin (d + 1), v.f i

/-- Euler characteristic: χ = Σ_k (-1)^k f_k. -/
noncomputable def eulerChar (v : FVectorData d) : ℤ :=
  ∑ i : Fin (d + 1), (-1 : ℤ) ^ (i : ℕ) * (v.f i : ℤ)

end FVectorData

/-! ## Network Architecture -/

/-- Architecture of a feedforward ReLU network.
    The network maps ℝ^inputDim → ℝ through `numLayers` hidden layers. -/
structure ReluNetArch where
  /-- Input space dimension -/
  inputDim : ℕ
  /-- Number of hidden layers -/
  numLayers : ℕ
  /-- Width of each hidden layer -/
  layerWidths : Fin numLayers → ℕ
  /-- All layers have positive width -/
  widths_pos : ∀ i, 0 < layerWidths i
  /-- Input dimension is positive -/
  input_pos : 0 < inputDim

namespace ReluNetArch

/-- Total number of hidden neurons. -/
def totalNeurons (arch : ReluNetArch) : ℕ :=
  ∑ i : Fin arch.numLayers, arch.layerWidths i

end ReluNetArch

/-! ## Zaslavsky Bound -/

/-- The Zaslavsky bound: maximum number of regions created by `m` hyperplanes
    in ℝⁿ in general position. Equal to Σ_{k=0}^{n} C(m, k). -/
def zaslavskyBound (m n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), m.choose k

/-- Region bound for a single layer: the Zaslavsky bound applied to a layer
    of width w in input dimension n. -/
def layerRegionBound (n w : ℕ) : ℕ := zaslavskyBound w n

/-- The multiplicative region bound for a full network: product of per-layer bounds.
    This is the Montúfar-Pascanu-Cho-Bengio bound. -/
def networkRegionBound (arch : ReluNetArch) : ℕ :=
  ∏ i : Fin arch.numLayers, layerRegionBound arch.inputDim (arch.layerWidths i)

/-- The "Hodge-type" bound for a network with ≥ 2 layers.
    For indices (p, q), bounds the (p,q)-component by
    C(w_first, p) · C(w_last, q) · Π_{middle layers} w_i. -/
noncomputable def hodgeBound (arch : ReluNetArch) (p q : ℕ) : ℕ :=
  if h : arch.numLayers ≥ 2 then
    let w₁ := arch.layerWidths ⟨0, by omega⟩
    let wL := arch.layerWidths ⟨arch.numLayers - 1, by omega⟩
    w₁.choose p * wL.choose q *
      ∏ i : Fin (arch.numLayers - 2),
        arch.layerWidths ⟨(i : ℕ) + 1, by omega⟩
  else 1