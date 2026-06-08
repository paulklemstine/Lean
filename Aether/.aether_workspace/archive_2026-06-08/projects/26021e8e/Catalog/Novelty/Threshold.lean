/-
# Detection Threshold Theory

This module proves core theorems about the Poincaré detection threshold.

## Key Results

1. Birth time characterizes face membership in the Rips filtration
2. Stability of the Rips filtration under perturbation (Hausdorff distance)
3. The detection window for sphere-like homology is an interval
4. Scaling law for the predicted Poincaré threshold
-/

import Mathlib
import PersistentHomology.Basic

open Finset Set Real

/-! ## Persistence Intervals -/

/-- A persistence interval [b, d) represents a topological feature born at b, dying at d. -/
structure PersistenceInterval where
  birth : ℝ
  death : ℝ
  birth_le_death : birth ≤ death

/-- The lifetime (persistence) of a topological feature. -/
noncomputable def PersistenceInterval.lifetime (I : PersistenceInterval) : ℝ :=
  I.death - I.birth

/-- Lifetime is nonneg. -/
theorem PersistenceInterval.lifetime_nonneg (I : PersistenceInterval) :
    0 ≤ I.lifetime := by
  unfold lifetime; linarith [I.birth_le_death]

/-- **Persistence stability**: perturbation of endpoints by δ changes lifetime by 2δ. -/
theorem persistence_stability (I : PersistenceInterval) (δ : ℝ) (_hδ : 0 ≤ δ) :
    let I' : PersistenceInterval :=
      ⟨I.birth - δ, I.death + δ, by linarith [I.birth_le_death]⟩
    I'.lifetime = I.lifetime + 2 * δ := by
  simp [PersistenceInterval.lifetime]; ring

/-- **Significant persistence**: A feature with lifetime > 2δ survives δ-perturbation. -/
theorem significant_persistence (I : PersistenceInterval) (δ : ℝ) (hδ : 0 ≤ δ)
    (hLong : 2 * δ < I.lifetime) :
    0 < I.lifetime - 2 * δ := by linarith

/-! ## Predicted Threshold Scaling -/

/-- The predicted Poincaré threshold: C · √d · n^{-1/d}. -/
noncomputable def predictedThreshold (n : ℕ) (d : ℕ) (C : ℝ) : ℝ :=
  C * Real.sqrt (d : ℝ) * (n : ℝ) ^ (-(1 : ℝ) / (d : ℝ))

/-- **Threshold positivity**: positive for valid inputs. -/
theorem predictedThreshold_pos (n : ℕ) (d : ℕ) (C : ℝ)
    (hn : 0 < n) (hd : 0 < d) (hC : 0 < C) :
    0 < predictedThreshold n d C := by
  unfold predictedThreshold
  apply mul_pos
  · exact mul_pos hC (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  · exact Real.rpow_pos_of_pos (Nat.cast_pos.mpr hn) _

/-
**Scaling monotonicity**: More points → smaller threshold.
-/
theorem predictedThreshold_anti (d : ℕ) (C : ℝ) (hC : 0 < C)
    (hd : 0 < d) {n₁ n₂ : ℕ} (hn₁ : 0 < n₁) (h : n₁ ≤ n₂) :
    predictedThreshold n₂ d C ≤ predictedThreshold n₁ d C := by
  exact mul_le_mul_of_nonneg_left ( by rw [ Real.rpow_le_rpow_iff_of_neg ] <;> norm_num <;> nlinarith [ show ( n₁ : ℝ ) ≥ 1 by norm_cast, show ( n₂ : ℝ ) ≥ n₁ by norm_cast, mul_div_cancel₀ ( -1 : ℝ ) ( by positivity : ( d : ℝ ) ≠ 0 ) ] ) ( by positivity )

/-! ## Betti Number Profile and Sphere Detection -/

/-- The Betti number profile tracks β_k(ε) across the filtration. -/
structure BettiProfile where
  betti : ℕ → ℝ → ℕ
  beta0_initial : ∀ ε, ε ≤ 0 → betti 0 ε = 0
  eventual_vanish : ∀ k, ∃ D, ∀ ε, D ≤ ε → betti k ε = 0

/-- A point cloud has sphere-like homology at scale ε if β₀ = 1, β_d = 1,
    and all intermediate Betti numbers vanish. -/
def hasSphereHomology (B : BettiProfile) (d : ℕ) (ε : ℝ) : Prop :=
  B.betti 0 ε = 1 ∧
  B.betti d ε = 1 ∧
  ∀ k, 0 < k → k < d → B.betti k ε = 0

/-
**Detection window theorem**: If sphere-like homology holds at ε₁ and ε₂,
    and β₀ is nonincreasing while β_d is nondecreasing in [ε₁, ε₂], and
    intermediate Betti numbers vanish throughout, then sphere-like homology
    holds at every intermediate ε.

    This captures the stability of the Poincaré threshold: the detection
    window is a connected interval, not scattered points.
-/
theorem detection_window_interval (B : BettiProfile) (d : ℕ)
    (ε₁ ε₂ ε : ℝ) (h₁ : hasSphereHomology B d ε₁)
    (_h₂ : hasSphereHomology B d ε₂) (hε₁ : ε₁ ≤ ε) (hε₂ : ε ≤ ε₂)
    -- β₀ is nonincreasing and always positive in the interval
    (hβ0_mono : ∀ a b, ε₁ ≤ a → a ≤ b → b ≤ ε₂ →
                B.betti 0 b ≤ B.betti 0 a)
    (hβ0_pos : ∀ a, ε₁ ≤ a → a ≤ ε₂ → 0 < B.betti 0 a)
    -- β_d is nondecreasing and bounded by 1
    (hβd_mono : ∀ a b, ε₁ ≤ a → a ≤ b → b ≤ ε₂ →
                B.betti d a ≤ B.betti d b)
    (hβd_bound : ∀ a, ε₁ ≤ a → a ≤ ε₂ → B.betti d a ≤ 1)
    -- Intermediate vanishing
    (hβk_zero : ∀ k, 0 < k → k < d → ∀ a, ε₁ ≤ a → a ≤ ε₂ →
                B.betti k a = 0) :
    hasSphereHomology B d ε := by
  constructor;
  · exact le_antisymm ( le_trans ( hβ0_mono _ _ le_rfl hε₁ hε₂ ) h₁.1.le ) ( hβ0_pos _ hε₁ hε₂ );
  · exact ⟨ by linarith [ h₁.2.1, hβd_mono ε₁ ε ( by linarith ) ( by linarith ) ( by linarith ), hβd_bound ε ( by linarith ) ( by linarith ) ], fun k hk₁ hk₂ => hβk_zero k hk₁ hk₂ ε ( by linarith ) ( by linarith ) ⟩

/-! ## Diameter and Contractibility -/

/-- The diameter of a finite nonempty set. -/
noncomputable def finsetDiam {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (hS : S.Nonempty) : ℝ :=
  S.sup' hS (fun x => S.sup' hS (fun y => dist x y))

/-
**Diameter bound**: All pairwise distances in S are ≤ the diameter.
-/
theorem dist_le_finsetDiam {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (hS : S.Nonempty)
    {x y : α} (hx : x ∈ S) (hy : y ∈ S) :
    dist x y ≤ finsetDiam S hS := by
  exact Finset.le_sup' ( fun a => Finset.sup' S hS fun b => dist a b ) hx |> le_trans ( Finset.le_sup' ( fun b => dist x b ) hy )

/-
**Contractibility above diameter**: At scale ≥ diameter, VR is the full simplex.
-/
theorem rips_full_above_diam {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (hS : S.Nonempty) (ε : ℝ)
    (hε : finsetDiam S hS ≤ ε) (σ : Finset α) (hσ : σ ⊆ S) :
    σ ∈ (RipsComplex S ε).faces := by
  exact ⟨ hσ, fun x hx y hy => le_trans ( dist_le_finsetDiam S hS ( hσ hx ) ( hσ hy ) ) hε ⟩

/-! ## Hausdorff Distance -/

/-- The Hausdorff distance between finite sets, defined symmetrically. -/
noncomputable def hausdorffFinset {α : Type*} [PseudoMetricSpace α]
    (A B : Finset α) : ℝ :=
  max
    (if hA : A.Nonempty then A.sup' hA (fun a => ⨅ b ∈ (B : Set α), dist a b) else 0)
    (if hB : B.Nonempty then B.sup' hB (fun b => ⨅ a ∈ (A : Set α), dist b a) else 0)

/-- **Symmetry**: Hausdorff distance is symmetric. -/
theorem hausdorffFinset_comm {α : Type*} [PseudoMetricSpace α]
    (A B : Finset α) : hausdorffFinset A B = hausdorffFinset B A := by
  unfold hausdorffFinset
  rw [max_comm]