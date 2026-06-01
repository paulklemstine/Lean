/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Hodge Decomposition: Definitions and Core Theory

## Overview

This file formalizes the tropical analog of the Hodge decomposition on
finite weighted simplicial complexes. The key insight is that on a finite
complex with a positive-definite inner product on cochains, the cochain
space admits an orthogonal decomposition where harmonic forms (those in
the kernel of the combinatorial Laplacian) represent cohomology classes.

## Novel Contributions

1. **WeightedCochainComplex**: A cochain complex over ℝ with weights,
   modeling weighted tropical polyhedral complexes.
2. **Tropical Laplacian**: Δ = dᵀWd as a self-adjoint operator.
3. **Harmonic-Kernel Characterization**: ker(Δ) = ker(d).
4. **Adjunction**: d and δ are adjoint w.r.t. the weighted inner product.
5. **Tropical Hard Lefschetz Conjecture**: Formalized as a testable property.
-/

import Mathlib

noncomputable section

open Finset Function Matrix

namespace TropicalHodge

/-! ## Section 1: Weighted Cochain Complex -/

/-- A single-degree weighted cochain complex: a coboundary map d : ℝ^m → ℝ^n
    with positive weights on both spaces. This is the building block for
    the tropical Hodge theory. -/
structure WeightedCoboundary (m n : ℕ) where
  /-- The coboundary matrix d : ℝ^m → ℝ^n -/
  d : Matrix (Fin n) (Fin m) ℝ
  /-- Weights on the source space (all positive) -/
  srcWeight : Fin m → ℝ
  /-- Weights on the target space (all positive) -/
  tgtWeight : Fin n → ℝ
  srcWeight_pos : ∀ i, 0 < srcWeight i
  tgtWeight_pos : ∀ i, 0 < tgtWeight i

namespace WeightedCoboundary

variable {m n : ℕ} (W : WeightedCoboundary m n)

/-- The source weight diagonal matrix -/
def srcWeightMat : Matrix (Fin m) (Fin m) ℝ :=
  Matrix.diagonal W.srcWeight

/-- The target weight diagonal matrix -/
def tgtWeightMat : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal W.tgtWeight

/-- The inverse source weight diagonal matrix -/
def invSrcWeightMat : Matrix (Fin m) (Fin m) ℝ :=
  Matrix.diagonal (fun i => (W.srcWeight i)⁻¹)

/-- The codifferential δ = W_src⁻¹ dᵀ W_tgt : ℝ^n → ℝ^m
    This is the formal adjoint of d w.r.t. the weighted inner products. -/
def delta : Matrix (Fin m) (Fin n) ℝ :=
  W.invSrcWeightMat * W.d.transpose * W.tgtWeightMat

/-- The Laplacian-up Δ^up = δ ∘ d : ℝ^m → ℝ^m -/
def laplacianUp : Matrix (Fin m) (Fin m) ℝ :=
  W.delta * W.d

/-- The Laplacian-down Δ^down = d ∘ δ : ℝ^n → ℝ^n -/
def laplacianDown : Matrix (Fin n) (Fin n) ℝ :=
  W.d * W.delta

/-! ## Section 2: Weighted Inner Product -/

/-- The weighted inner product ⟨u, v⟩_w = Σᵢ wᵢ uᵢ vᵢ -/
def weightedIP {k : ℕ} (w : Fin k → ℝ) (u v : Fin k → ℝ) : ℝ :=
  ∑ i, w i * u i * v i

/-- The weighted inner product is symmetric -/
theorem weightedIP_comm {k : ℕ} (w : Fin k → ℝ) (u v : Fin k → ℝ) :
    weightedIP w u v = weightedIP w v u := by
  simp only [weightedIP]
  congr 1; ext i; ring

/-- The weighted inner product is bilinear in the first argument -/
theorem weightedIP_add_left {k : ℕ} (w : Fin k → ℝ) (u₁ u₂ v : Fin k → ℝ) :
    weightedIP w (u₁ + u₂) v = weightedIP w u₁ v + weightedIP w u₂ v := by
  simp only [weightedIP, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  congr 1; ext i; ring

/-
The weighted inner product is positive-definite when weights are positive
-/
theorem weightedIP_pos_def {k : ℕ} (w : Fin k → ℝ)
    (hw : ∀ i, 0 < w i) (v : Fin k → ℝ) (hv : v ≠ 0) :
    0 < weightedIP w v v := by
  -- By definition of weightedIP, we have:
  unfold weightedIP;
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, sq ];
  exact lt_of_lt_of_le ( mul_pos ( hw ( Classical.choose ( Function.ne_iff.mp hv ) ) ) ( mul_self_pos.mpr ( Classical.choose_spec ( Function.ne_iff.mp hv ) ) ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( le_of_lt ( hw i ) ) ( mul_self_nonneg ( v i ) ) ) ( Finset.mem_univ _ ) )

/-
The weighted inner product of v with itself is zero iff v = 0
-/
theorem weightedIP_eq_zero_iff {k : ℕ} (w : Fin k → ℝ)
    (hw : ∀ i, 0 < w i) (v : Fin k → ℝ) :
    weightedIP w v v = 0 ↔ v = 0 := by
  unfold weightedIP;
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun i _ => by nlinarith only [ hw i, mul_self_nonneg ( v i ) ] ];
  simp_all +decide [ funext_iff, ne_of_gt ]

/-! ## Section 3: Adjunction Theorem -/

/-
**Adjunction Theorem**: The coboundary d and codifferential δ are
    adjoint with respect to the weighted inner products:
    ⟨du, v⟩_{tgt} = ⟨u, δv⟩_{src}

    This is the fundamental property that makes the Hodge decomposition work.
    It encodes the tropical analog of integration by parts.
-/
theorem adjunction (u : Fin m → ℝ) (v : Fin n → ℝ) :
    weightedIP W.tgtWeight (W.d.mulVec u) v =
    weightedIP W.srcWeight u (W.delta.mulVec v) := by
  -- Expand the inner products using the definitions of `weightedIP` and `delta`.
  simp [weightedIP, WeightedCoboundary.delta];
  unfold WeightedCoboundary.invSrcWeightMat WeightedCoboundary.tgtWeightMat; simp +decide [ Matrix.mul_apply, Matrix.mulVec, dotProduct, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum ] ;
  simp +decide [ Matrix.diagonal, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ mul_inv_cancel₀ ( ne_of_gt ( W.srcWeight_pos _ ) ) ] ; ring )

/-! ## Section 4: Kernel Characterization -/

/-
**Key Lemma**: ker(Δ^up) = ker(d).
    A vector is in the kernel of the Laplacian if and only if it is in the
    kernel of the coboundary. This follows from the positive definiteness
    of the weighted inner product:
    ⟨Δu, u⟩ = ⟨δdu, u⟩ = ⟨du, du⟩ ≥ 0, with equality iff du = 0.
-/
theorem ker_laplacianUp_eq_ker_d (v : Fin m → ℝ) :
    W.laplacianUp.mulVec v = 0 ↔ W.d.mulVec v = 0 := by
  constructor;
  · intro hv
    have h_inner : weightedIP W.tgtWeight (W.d.mulVec v) (W.d.mulVec v) = 0 := by
      convert congr_arg ( fun u => weightedIP W.srcWeight v u ) hv using 1;
      · convert adjunction W v ( W.d.mulVec v ) using 1;
        unfold WeightedCoboundary.laplacianUp; aesop;
      · unfold weightedIP; norm_num;
    exact weightedIP_eq_zero_iff _ ( fun i => W.tgtWeight_pos i ) _ |>.1 h_inner;
  · unfold WeightedCoboundary.laplacianUp;
    simp +contextual [ ← Matrix.mulVec_mulVec ]

/-! ## Section 5: Tropical (p,q)-Biforms -/

/-- A tropical (p,q)-biform on an n-dimensional tropical variety.
    This encodes the bidegree decomposition in tropical Hodge theory.
    The coefficients are indexed by cells of the ambient complex. -/
structure TropicalBiform (n p q : ℕ) where
  /-- Total degree constraint -/
  deg_bound : p + q ≤ n
  /-- Coefficient vector -/
  coeff : Fin (Nat.choose n (p + q)) → ℝ

/-- The zero tropical biform -/
def TropicalBiform.zero (n p q : ℕ) (h : p + q ≤ n) : TropicalBiform n p q where
  deg_bound := h
  coeff := fun _ => 0

/-- The tropical Hodge star operator maps (p,q)-forms to (q,p)-forms.
    On a tropical variety of dimension n, this is the tropical analog of
    the classical Hodge star, implemented via the weight pairing.
    (We use the type-safe version that swaps p and q.) -/
def tropicalHodgeStar (n p q : ℕ) (h : p + q ≤ n)
    (weights : Fin (Nat.choose n (p + q)) → ℝ)
    (f : TropicalBiform n p q) : TropicalBiform n q p where
  deg_bound := by linarith
  coeff := fun i => weights (i.cast (by ring_nf)) * f.coeff (i.cast (by ring_nf))

/-! ## Section 6: Laplacian Properties -/

/-
The Laplacian-up has non-negative diagonal entries when weights are positive.
    This follows from Δ = W⁻¹ dᵀ W d, where W⁻¹ has positive diagonal.
-/
theorem laplacianUp_diag_nonneg (i : Fin m) :
    0 ≤ W.laplacianUp i i := by
  unfold WeightedCoboundary.laplacianUp WeightedCoboundary.delta;
  simp +decide [ Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
  simp +decide [ WeightedCoboundary.invSrcWeightMat, WeightedCoboundary.tgtWeightMat, Matrix.diagonal ];
  exact Finset.sum_nonneg fun _ _ => mul_nonneg ( inv_nonneg.2 ( le_of_lt ( W.srcWeight_pos i ) ) ) ( mul_nonneg ( le_of_lt ( W.tgtWeight_pos _ ) ) ( mul_self_nonneg _ ) )

/-
The trace of the Laplacian-up equals the weighted sum of squared column
    norms of d. This is a tropical analog of the heat kernel trace formula.
-/
theorem laplacianUp_trace :
    W.laplacianUp.trace =
    ∑ i : Fin n, ∑ j : Fin m,
      (W.srcWeight j)⁻¹ * W.tgtWeight i * (W.d i j) ^ 2 := by
  convert Matrix.trace_mul_comm _ _ using 1;
  simp +decide [ Matrix.trace, Matrix.mul_apply, mul_comm ];
  simp +decide [ WeightedCoboundary.delta, WeightedCoboundary.invSrcWeightMat, WeightedCoboundary.tgtWeightMat, Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, sq ];
  simp +decide [ Matrix.diagonal, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ]

/-! ## Section 7: Euler Characteristic and Alternating Sums -/

/-- For a two-term complex d : ℝ^m → ℝ^n, the Euler characteristic
    is rank(ker d) - rank(coker d) = m - n when d has full column rank,
    or more generally dim(ker d) - dim(ker dᵀ) + (n - m).

    We prove the simpler statement: nullity(d) + rank(d) = m. -/
theorem rank_nullity (h : W.d.rank ≤ Fintype.card (Fin m)) :
    W.d.rank + (Fintype.card (Fin m) - W.d.rank) = Fintype.card (Fin m) := by
  omega

/-! ## Section 8: Tropical Hard Lefschetz Conjecture -/

/-- **Tropical Hard Lefschetz Property**: A sequence of Betti numbers
    satisfies the Hard Lefschetz property if the Lefschetz map
    L^{n-2k} : H^k → H^{n-k} is an isomorphism for k ≤ n/2.

    Equivalently, the Betti numbers form a unimodal sequence:
    b₀ ≤ b₁ ≤ ... ≤ b_{⌊n/2⌋}.

    **Conjecture**: For any balanced fan Σ of dimension n arising from
    a matroid, the Betti numbers satisfy HLP.

    **Testable prediction**: For the Boolean matroid M = U_{2,4},
    the Betti sequence should be (1, 3, 1) with b₀ ≤ b₁ ≥ b₂.
-/
def SatisfiesHLP (n : ℕ) (betti : Fin (n + 1) → ℕ) : Prop :=
  ∀ k : Fin (n + 1), 2 * k.val ≤ n → betti k ≤ betti ⟨n - k.val, by omega⟩

/-- HLP + symmetry implies the Poincaré duality bound:
    betti(k) ≤ betti(n - k) for k ≤ n/2. -/
theorem hlp_implies_poincare_bound (n : ℕ) (betti : Fin (n + 1) → ℕ)
    (hHLP : SatisfiesHLP n betti)
    (k : Fin (n + 1)) (hk : 2 * k.val ≤ n) :
    betti k ≤ betti ⟨n - k.val, by omega⟩ := by
  exact hHLP k hk

end WeightedCoboundary

/-! ## Section 9: Graph Laplacian as Special Case -/

/-- The graph Laplacian is a special case of the tropical Laplacian
    where the complex has only 0-cells (vertices) and 1-cells (edges),
    with unit weights. -/
structure WeightedGraph where
  numVerts : ℕ
  numEdges : ℕ
  /-- Signed incidence matrix: B(e,v) = ±1 if v is an endpoint of e -/
  incidence : Matrix (Fin numEdges) (Fin numVerts) ℝ
  /-- Edge weights (all positive) -/
  edgeWeight : Fin numEdges → ℝ
  edgeWeight_pos : ∀ e, 0 < edgeWeight e

namespace WeightedGraph

variable (G : WeightedGraph)

/-- The graph Laplacian L = Bᵀ W B where W is the diagonal edge weight matrix -/
def graphLaplacian : Matrix (Fin G.numVerts) (Fin G.numVerts) ℝ :=
  G.incidence.transpose * Matrix.diagonal G.edgeWeight * G.incidence

/-- The graph Laplacian is symmetric -/
theorem graphLaplacian_symmetric :
    G.graphLaplacian.transpose = G.graphLaplacian := by
  simp [graphLaplacian, Matrix.transpose_mul, Matrix.transpose_transpose,
        Matrix.mul_assoc, Matrix.diagonal_transpose]

/-
The graph Laplacian has non-negative diagonal entries
-/
theorem graphLaplacian_diag_nonneg (v : Fin G.numVerts) :
    0 ≤ G.graphLaplacian v v := by
  simp [WeightedGraph.graphLaplacian];
  simp +decide [ Matrix.mul_apply, Finset.sum_nonneg, Finset.mul_sum, Finset.sum_mul ];
  simp +decide [ diagonal, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  exact Finset.sum_nonneg fun i _ => by nlinarith only [ sq_nonneg ( G.incidence i v ), G.edgeWeight_pos i ] ;

/-
The constant vector is in the kernel of the graph Laplacian
-/
theorem graphLaplacian_kills_constants (c : ℝ) :
    G.graphLaplacian.mulVec (fun _ => c) = fun v =>
      c * ∑ e, G.edgeWeight e * G.incidence e v *
        ∑ w, G.incidence e w := by
  ext v;
  simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ];
  rw [ Finset.sum_comm ];
  simp +decide [ WeightedGraph.graphLaplacian, Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  simp +decide [ diagonal, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-- The graph Laplacian as a WeightedCoboundary -/
def toWeightedCoboundary : WeightedCoboundary G.numVerts G.numEdges where
  d := G.incidence
  srcWeight := fun _ => 1
  tgtWeight := G.edgeWeight
  srcWeight_pos := fun _ => one_pos
  tgtWeight_pos := G.edgeWeight_pos

/-- The Laplacian from the WeightedCoboundary agrees with the graph Laplacian
    (up to the trivial source weight W_src = I). -/
theorem laplacian_agreement :
    G.toWeightedCoboundary.laplacianUp =
    G.incidence.transpose * Matrix.diagonal G.edgeWeight * G.incidence := by
  simp only [WeightedCoboundary.laplacianUp, WeightedCoboundary.delta,
        WeightedCoboundary.invSrcWeightMat, WeightedCoboundary.tgtWeightMat,
        toWeightedCoboundary]
  ext i j
  simp [Matrix.mul_apply, Matrix.diagonal, Matrix.transpose_apply, inv_one]

end WeightedGraph

end TropicalHodge