/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Hodge Theory: The Hodge Decomposition Machinery

This file develops the analytic heart of Hodge theory for the weighted
two-term cochain complex `WeightedCoboundary` (a coboundary map `d : ℝᵐ → ℝⁿ`
together with positive weights making both spaces weighted inner-product
spaces).  It is a self-contained companion to `Tropical.HodgeDecomposition.Defs`:
the structure, the codifferential `δ`, the up/down Laplacians and the basic
inner-product lemmas are reproduced here (so the file depends only on Mathlib),
and on top of them we prove the *new* results that complete the picture begun
in the catalog (`ker(Δ^up) = ker(d)`):

* `weightedIP_zero_right`     :  the weighted inner product kills the zero cochain
* `adjunction`               :  ⟨d u, v⟩_tgt = ⟨u, δ v⟩_src   (integration by parts)
* `laplacianUp_energy`        :  ⟨Δ^up v, v⟩_src = ⟨d v, d v⟩_tgt   (Dirichlet energy)
* `laplacianUp_self_adjoint`  :  Δ^up is self-adjoint for the weighted inner product
* `image_d_perp_ker_delta`    :  im(d) ⊥ ker(δ)   (Hodge orthogonality)
* `ker_laplacianDown_eq_ker_delta` :  ker(Δ^down) = ker(δ)   (dual kernel theorem)

Everything is deduced from the single structural input `adjunction` together
with positive definiteness of the weighted inner product — the exact chain of
reasoning that, over ℝ, yields the orthogonal Hodge decomposition
`ℝⁿ = im(d) ⊕ ker(δ)`.
-/

import Mathlib

noncomputable section

open Finset Function Matrix

namespace TropicalHodgeAnalysis

/-! ## Section 0: The weighted two-term cochain complex (self-contained core)

These declarations mirror `TropicalHodge.WeightedCoboundary` from
`Tropical.HodgeDecomposition.Defs`; they are reproduced here under a fresh
namespace so that this file depends only on Mathlib. -/

/-- A single-degree weighted cochain complex: a coboundary map `d : ℝᵐ → ℝⁿ`
with positive weights on source and target. -/
structure WeightedCoboundary (m n : ℕ) where
  /-- The coboundary matrix `d : ℝᵐ → ℝⁿ`. -/
  d : Matrix (Fin n) (Fin m) ℝ
  /-- Positive weights on the source space. -/
  srcWeight : Fin m → ℝ
  /-- Positive weights on the target space. -/
  tgtWeight : Fin n → ℝ
  srcWeight_pos : ∀ i, 0 < srcWeight i
  tgtWeight_pos : ∀ i, 0 < tgtWeight i

namespace WeightedCoboundary

variable {m n : ℕ} (W : WeightedCoboundary m n)

/-- The inverse source-weight diagonal matrix. -/
def invSrcWeightMat : Matrix (Fin m) (Fin m) ℝ :=
  Matrix.diagonal (fun i => (W.srcWeight i)⁻¹)

/-- The target-weight diagonal matrix. -/
def tgtWeightMat : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal W.tgtWeight

/-- The codifferential `δ = W_src⁻¹ dᵀ W_tgt`, the weighted adjoint of `d`. -/
def delta : Matrix (Fin m) (Fin n) ℝ :=
  W.invSrcWeightMat * W.d.transpose * W.tgtWeightMat

/-- The up-Laplacian `Δ^up = δ ∘ d`. -/
def laplacianUp : Matrix (Fin m) (Fin m) ℝ :=
  W.delta * W.d

/-- The down-Laplacian `Δ^down = d ∘ δ`. -/
def laplacianDown : Matrix (Fin n) (Fin n) ℝ :=
  W.d * W.delta

/-- The weighted inner product `⟨u, v⟩_w = Σᵢ wᵢ uᵢ vᵢ`. -/
def weightedIP {k : ℕ} (w : Fin k → ℝ) (u v : Fin k → ℝ) : ℝ :=
  ∑ i, w i * u i * v i

/-- The weighted inner product is symmetric. -/
theorem weightedIP_comm {k : ℕ} (w : Fin k → ℝ) (u v : Fin k → ℝ) :
    weightedIP w u v = weightedIP w v u := by
  simp only [weightedIP]
  congr 1; ext i; ring

/-- The weighted inner product of `v` with itself is zero iff `v = 0`
(positive weights). -/
theorem weightedIP_eq_zero_iff {k : ℕ} (w : Fin k → ℝ)
    (hw : ∀ i, 0 < w i) (v : Fin k → ℝ) :
    weightedIP w v v = 0 ↔ v = 0 := by
  unfold weightedIP
  rw [Finset.sum_eq_zero_iff_of_nonneg
        fun i _ => by nlinarith only [hw i, mul_self_nonneg (v i)]]
  simp_all +decide [funext_iff, ne_of_gt]

/-- **Adjunction (integration by parts)**: `d` and `δ` are adjoint for the
weighted inner products, `⟨d u, v⟩_tgt = ⟨u, δ v⟩_src`. -/
theorem adjunction (u : Fin m → ℝ) (v : Fin n → ℝ) :
    weightedIP W.tgtWeight (W.d.mulVec u) v =
    weightedIP W.srcWeight u (W.delta.mulVec v) := by
  simp [weightedIP, WeightedCoboundary.delta]
  unfold WeightedCoboundary.invSrcWeightMat WeightedCoboundary.tgtWeightMat
  simp +decide [Matrix.mul_apply, Matrix.mulVec, dotProduct, mul_assoc, mul_comm,
    mul_left_comm, Finset.mul_sum]
  simp +decide [Matrix.diagonal, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne]
  exact Finset.sum_comm.trans (Finset.sum_congr rfl fun _ _ =>
    Finset.sum_congr rfl fun _ _ => by
      rw [mul_inv_cancel₀ (ne_of_gt (W.srcWeight_pos _))]; ring)

/-! ## Auxiliary: the weighted inner product vanishes against the zero cochain -/

/-
The weighted inner product is zero whenever one argument is the zero cochain.
-/
theorem weightedIP_zero_right {k : ℕ} (w : Fin k → ℝ) (u : Fin k → ℝ) :
    weightedIP w u 0 = 0 := by
  -- By definition of weightedIP, we have:
  simp [weightedIP]

/-! ## Section 1: The Dirichlet energy identity -/

/-
!-- The up-Laplacian factors as `δ ∘ d`; applying `adjunction` with the test
!-- cochain `v` rewrites `⟨δ(d v), v⟩_src` as `⟨d v, d v⟩_tgt`. -- !--

**Dirichlet energy identity**: the weighted energy of a cochain under the
up-Laplacian equals the squared weighted norm of its coboundary,
`⟨Δ^up v, v⟩_src = ⟨d v, d v⟩_tgt`. In particular it is non-negative, and the
catalog's `ker_laplacianUp_eq_ker_d` is precisely its equality case.
-/
theorem laplacianUp_energy (v : Fin m → ℝ) :
    weightedIP W.srcWeight (W.laplacianUp.mulVec v) v
      = weightedIP W.tgtWeight (W.d.mulVec v) (W.d.mulVec v) := by
  unfold WeightedCoboundary.laplacianUp;
  convert adjunction W v ( W.d.mulVec v ) |> Eq.symm using 1;
  rw [ ← Matrix.mulVec_mulVec, weightedIP_comm ]

/-! ## Section 2: Self-adjointness of the Laplacian -/

/-
!-- Both sides reduce, via `adjunction` applied twice and `weightedIP_comm`,
!-- to the symmetric pairing `⟨d u, d w⟩_tgt`. -- !--

**Self-adjointness**: the up-Laplacian is symmetric with respect to the
weighted inner product, `⟨Δ^up u, w⟩_src = ⟨u, Δ^up w⟩_src`. This is the
spectral-theorem prerequisite guaranteeing a real orthogonal eigenbasis.
-/
theorem laplacianUp_self_adjoint (u w : Fin m → ℝ) :
    weightedIP W.srcWeight (W.laplacianUp.mulVec u) w
      = weightedIP W.srcWeight u (W.laplacianUp.mulVec w) := by
  -- Unfold `laplacianUp` into `delta * d`.
  have h_laplacianUp : weightedIP W.srcWeight (W.laplacianUp *ᵥ u) w = weightedIP W.srcWeight (W.delta.mulVec (W.d.mulVec u)) w := by
    simp +decide only [laplacianUp, mulVec_mulVec];
  rw [ h_laplacianUp ];
  convert adjunction W u ( W.d.mulVec w ) using 1;
  · convert adjunction W w ( W.d.mulVec u ) |> Eq.symm using 1; all_goals exact weightedIP_comm _ _ _;
  · unfold WeightedCoboundary.laplacianUp; aesop;

/-! ## Section 3: Hodge orthogonality of exact and coexact cochains -/

/-
!-- `adjunction` turns `⟨d u, v⟩_tgt` into `⟨u, δ v⟩_src`; since `δ v = 0`
!-- the right-hand pairing is against the zero cochain. -- !--

**Hodge orthogonality**: every exact cochain `d u` is orthogonal (in the
target weighted inner product) to every coclosed cochain `v` (one with
`δ v = 0`). This is the orthogonality that splits the Hodge decomposition
`ℝⁿ = im(d) ⊕ ker(δ)`.
-/
theorem image_d_perp_ker_delta (u : Fin m → ℝ) (v : Fin n → ℝ)
    (hv : W.delta.mulVec v = 0) :
    weightedIP W.tgtWeight (W.d.mulVec u) v = 0 := by
  rw [ ← weightedIP_zero_right, ← hv, W.adjunction ]

/-! ## Section 4: Kernel of the down-Laplacian -/

/-
!-- Mirror of `ker_laplacianUp_eq_ker_d`: `⟨Δ^down w, w⟩_tgt = ⟨δ w, δ w⟩_src`
!-- by `adjunction`, then positive-definiteness forces `δ w = 0`. -- !--

**Dual kernel characterization**: a cochain lies in the kernel of the
down-Laplacian `Δ^down = d ∘ δ` iff it is coclosed (`δ w = 0`). Together with
the catalog's `ker_laplacianUp_eq_ker_d` this identifies the harmonic spaces
in both degrees.
-/
theorem ker_laplacianDown_eq_ker_delta (w : Fin n → ℝ) :
    W.laplacianDown.mulVec w = 0 ↔ W.delta.mulVec w = 0 := by
  constructor <;> intro h;
  · have h_adj : Matrix.mulVec W.d (W.delta.mulVec w) = 0 := by
      simpa only [ Matrix.mulVec_mulVec ] using h;
    have h_adj : weightedIP W.srcWeight (W.delta.mulVec w) (W.delta.mulVec w) = 0 := by
      have := adjunction W ( W.delta.mulVec w ) w;
      simp_all +decide [ weightedIP ];
    exact ( weightedIP_eq_zero_iff W.srcWeight W.srcWeight_pos _ ) |>.1 h_adj;
  · simp_all +decide [ ← Matrix.mulVec_mulVec, WeightedCoboundary.laplacianDown ]

end WeightedCoboundary

end TropicalHodgeAnalysis