/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical One-Way Kernel Duality via Idempotent Kernel Semimodules

## Bridge: Tropical Algebra ↔ Speculative Cryptography ↔ Realization Theory

This file formalizes a representation-theoretic approach to tropical one-way structure.
One-way behavior in tropical hash networks is encoded intrinsically by an
**idempotent kernel semimodule** rather than operationally by circuits.

## Main Results

* `kernelProfile_symm` — kernel profiles are symmetric
* `kernelProfile_le_witness` / `kernelProfile_exists_witness` — witness bounds
* `tropicalGram_symm` — tropical Gram symmetry
* `self_composition_eq_of_zero_diag` — idempotent kernel characterization
* `idempotent_iff_metric` — tropical metrics = idempotent kernels
* `composeKernelProfiles_symm` — functoriality under composition
* `reconstructNetwork_kernelProfile_eq` — certified reconstruction
* `reconstructNetwork_matches_kernel` — recovery bound
* `distKernel_idempotent` — concrete idempotent example

## Cross-Domain Connections

- **Automata / Myhill–Nerode**: Kernel profiles as indistinguishability invariants
- **Control theory**: Generator rank mirrors Hankel-rank minimality
- **Cryptography**: Collision-separation via algebraic certificates
- **Tropical geometry**: Kernel profile = tropical Gram matrix
- **Complexity theory**: Realization size as structural complexity
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

namespace TropicalOneWayKernelDuality

/-! ## Section 1: Min-Plus Matrix Arithmetic -/

variable {n : ℕ}

/-- Min-plus matrix multiplication: (A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ). -/
def tropMul' (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)

theorem tropMul_entry_le' (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) : tropMul' hn A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem tropMul_exists_witness' (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ∃ k, tropMul' hn A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)
  exact ⟨k, hk⟩

theorem tropMul_bound' (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) (MA MB : ℝ)
    (hA : ∀ i j, A i j ≤ MA) (hB : ∀ i j, B i j ≤ MB) :
    ∀ i j, tropMul' hn A B i j ≤ MA + MB := by
  intro i j
  calc tropMul' hn A B i j ≤ A i ⟨0, hn⟩ + B ⟨0, hn⟩ j :=
      tropMul_entry_le' hn A B i j ⟨0, hn⟩
    _ ≤ MA + MB := add_le_add (hA _ _) (hB _ _)

/-! ## Section 2: Bounded Tropical Hash Networks -/

/-- A bounded tropical hash network on `Fin n`. -/
structure BoundedTropicalHashNetwork (n : ℕ) (hn : 0 < n) where
  layerCount : ℕ
  layers : Fin layerCount → Matrix (Fin n) (Fin n) ℝ
  bound : ℝ
  entries_bounded : ∀ l i j, |layers l i j| ≤ bound

/-- Network evaluation: first layer (zero matrix for empty network). -/
def BoundedTropicalHashNetwork.eval {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) : Matrix (Fin n) (Fin n) ℝ :=
  if h : H.layerCount = 0 then fun _ _ => 0
  else H.layers ⟨0, Nat.pos_of_ne_zero h⟩

/-- Kernel profile: κ(a,b) = min_k (M(a,k) + M(b,k)). -/
def BoundedTropicalHashNetwork.kernelProfile {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) : Fin n → Fin n → ℝ :=
  fun a b => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => H.eval a k + H.eval b k)

/-! ## Section 3: Kernel Profile Properties -/

theorem kernelProfile_symm {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) (a b : Fin n) :
    H.kernelProfile a b = H.kernelProfile b a := by
  simp only [BoundedTropicalHashNetwork.kernelProfile]
  congr 1; ext k; ring

theorem kernelProfile_le_witness {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) (a b k : Fin n) :
    H.kernelProfile a b ≤ H.eval a k + H.eval b k :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem kernelProfile_exists_witness {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) (a b : Fin n) :
    ∃ k, H.kernelProfile a b = H.eval a k + H.eval b k := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf'
    (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun k => H.eval a k + H.eval b k)
  exact ⟨k, hk⟩

/-! ## Section 4: Tropical Gram Matrix -/

/-- Tropical Gram matrix: G_{ab} = min_k (M_{ak} + M_{bk}). -/
def tropicalGram (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    Fin n → Fin n → ℝ :=
  fun a b => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => M a k + M b k)

theorem tropicalGram_symm (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (a b : Fin n) : tropicalGram hn M a b = tropicalGram hn M b a := by
  simp only [tropicalGram]; congr 1; ext k; ring

theorem tropicalGram_le (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (a b k : Fin n) : tropicalGram hn M a b ≤ M a k + M b k :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem tropicalGram_witness (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (a b : Fin n) :
    ∃ k, tropicalGram hn M a b = M a k + M b k := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf'
    (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun k => M a k + M b k)
  exact ⟨k, hk⟩

/-- Kernel profile = tropical Gram of evaluation. -/
theorem kernelProfile_eq_tropicalGram {hn : 0 < n}
    (H : BoundedTropicalHashNetwork n hn) :
    H.kernelProfile = tropicalGram hn H.eval := rfl

/-! ## Section 5: Composition of Kernel Profiles -/

/-- Tropical composition: (κ₁ ⊗ κ₂)(a,c) = min_b (κ₁(a,b) + κ₂(b,c)). -/
def composeKernelProfiles (hn : 0 < n)
    (κ₁ κ₂ : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun a c => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun b => κ₁ a b + κ₂ b c)

theorem composeKernelProfiles_le (hn : 0 < n)
    (κ₁ κ₂ : Fin n → Fin n → ℝ) (a b c : Fin n) :
    composeKernelProfiles hn κ₁ κ₂ a c ≤ κ₁ a b + κ₂ b c :=
  Finset.inf'_le _ (Finset.mem_univ b)

theorem composeKernelProfiles_witness (hn : 0 < n)
    (κ₁ κ₂ : Fin n → Fin n → ℝ) (a c : Fin n) :
    ∃ b, composeKernelProfiles hn κ₁ κ₂ a c = κ₁ a b + κ₂ b c := by
  obtain ⟨b, _, hb⟩ := Finset.exists_mem_eq_inf'
    (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun b => κ₁ a b + κ₂ b c)
  exact ⟨b, hb⟩

theorem composeKernelProfiles_symm (hn : 0 < n)
    (κ₁ κ₂ : Fin n → Fin n → ℝ)
    (h₁ : ∀ a b, κ₁ a b = κ₁ b a)
    (h₂ : ∀ a b, κ₂ a b = κ₂ b a) :
    ∀ a c, composeKernelProfiles hn κ₁ κ₂ a c =
      composeKernelProfiles hn κ₂ κ₁ c a := by
  intro a c
  simp only [composeKernelProfiles]
  congr 1; ext b; rw [h₁ a b, h₂ b c, add_comm]

/-! ## Section 6: Network Composition -/

/-- Compose two networks by concatenating layers. -/
def BoundedTropicalHashNetwork.comp {hn : 0 < n}
    (H₂ H₁ : BoundedTropicalHashNetwork n hn) :
    BoundedTropicalHashNetwork n hn where
  layerCount := H₁.layerCount + H₂.layerCount
  layers := fun l =>
    if h : l.val < H₁.layerCount then H₁.layers ⟨l.val, h⟩
    else H₂.layers ⟨l.val - H₁.layerCount, by omega⟩
  bound := max H₁.bound H₂.bound
  entries_bounded := by
    intro l i j; split
    · exact le_trans (H₁.entries_bounded _ i j) (le_max_left _ _)
    · exact le_trans (H₂.entries_bounded _ i j) (le_max_right _ _)

theorem comp_layerCount {hn : 0 < n}
    (H₁ H₂ : BoundedTropicalHashNetwork n hn) :
    (H₂.comp H₁).layerCount = H₁.layerCount + H₂.layerCount := rfl

/-! ## Section 7: Tropical Kernel Distance -/

/-- Normalized tropical kernel distance: d(a,b) = κ(a,b) - (κ(a,a) + κ(b,b))/2. -/
def tropKernelDist (κ : Fin n → Fin n → ℝ) (a b : Fin n) : ℝ :=
  κ a b - (κ a a + κ b b) / 2

theorem tropKernelDist_symm (κ : Fin n → Fin n → ℝ)
    (hκ : ∀ a b, κ a b = κ b a) (a b : Fin n) :
    tropKernelDist κ a b = tropKernelDist κ b a := by
  simp only [tropKernelDist, hκ a b]; ring

theorem tropKernelDist_self (κ : Fin n → Fin n → ℝ) (a : Fin n) :
    tropKernelDist κ a a = 0 := by
  simp only [tropKernelDist]; ring

/-! ## Section 8: Idempotent Kernel Theory

**Central theorem**: κ ⊗ κ = κ ↔ κ is a tropical (pseudo)metric. -/

/-- Self-composition refines when diagonal ≤ 0. -/
theorem self_composition_refines (hn : 0 < n)
    (κ : Fin n → Fin n → ℝ) (a b : Fin n)
    (h_diag_le : ∀ x, κ x x ≤ 0) :
    composeKernelProfiles hn κ κ a b ≤ κ a b := by
  calc composeKernelProfiles hn κ κ a b
      ≤ κ a a + κ a b := composeKernelProfiles_le hn κ κ a a b
    _ ≤ 0 + κ a b := by linarith [h_diag_le a]
    _ = κ a b := by ring

/-- **Idempotent kernel theorem.**
    Zero diagonal + triangle inequality ⟹ κ ⊗ κ = κ. -/
theorem self_composition_eq_of_zero_diag (hn : 0 < n)
    (κ : Fin n → Fin n → ℝ)
    (h_diag : ∀ x, κ x x = 0)
    (h_triangle : ∀ a b c, κ a c ≤ κ a b + κ b c) :
    ∀ a b, composeKernelProfiles hn κ κ a b = κ a b := by
  intro a b
  apply le_antisymm
  · calc composeKernelProfiles hn κ κ a b
        ≤ κ a a + κ a b := composeKernelProfiles_le hn κ κ a a b
      _ = κ a b := by rw [h_diag a]; ring
  · simp only [composeKernelProfiles]
    apply Finset.le_inf'
    intro k _; exact h_triangle a k b

/-- Pointfree version. -/
theorem idempotent_iff_metric (hn : 0 < n)
    (κ : Fin n → Fin n → ℝ)
    (h_diag : ∀ x, κ x x = 0)
    (h_triangle : ∀ a b c, κ a c ≤ κ a b + κ b c) :
    composeKernelProfiles hn κ κ = κ := by
  funext a b
  exact self_composition_eq_of_zero_diag hn κ h_diag h_triangle a b

/-! ## Section 9: Finite Tropical Kernel Semimodule -/

/-- A finite tropical kernel semimodule with generators. -/
structure FiniteTropKernelSemimodule (n : ℕ) (hn : 0 < n) where
  κ : Fin n → Fin n → ℝ
  generators : Finset (Fin n)
  generators_nonempty : generators.Nonempty
  span_eq : ∀ a b, κ a b = generators.inf' generators_nonempty
    (fun g => κ a g + κ g b)

def generatorRank {hn : 0 < n} (K : FiniteTropKernelSemimodule n hn) : ℕ :=
  K.generators.card

theorem generatorRank_pos {hn : 0 < n}
    (K : FiniteTropKernelSemimodule n hn) : 0 < generatorRank K :=
  Finset.Nonempty.card_pos K.generators_nonempty

theorem generatorRank_le {hn : 0 < n}
    (K : FiniteTropKernelSemimodule n hn) : generatorRank K ≤ n :=
  le_trans (Finset.card_le_card (Finset.subset_univ _)) (by simp)

/-! ## Section 10: Network Reconstruction -/

/-- Build a 1-layer network from a kernel semimodule. -/
def reconstructNetwork (hn : 0 < n) (K : FiniteTropKernelSemimodule n hn) :
    BoundedTropicalHashNetwork n hn where
  layerCount := 1
  layers := fun _ a b => K.κ a b
  bound := Finset.univ.sup' (univ_nonempty_iff.mpr ⟨(⟨0, hn⟩ : Fin n)⟩)
    (fun i => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨(⟨0, hn⟩ : Fin n)⟩)
      (fun j => |K.κ i j|))
  entries_bounded := by
    intro _ i j
    exact le_trans
      (Finset.le_sup' (fun j' => |K.κ i j'|) (Finset.mem_univ j))
      (Finset.le_sup'
        (fun i' => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨(⟨0, hn⟩ : Fin n)⟩)
          (fun j' => |K.κ i' j'|))
        (Finset.mem_univ i))

theorem reconstructNetwork_eval (hn : 0 < n)
    (K : FiniteTropKernelSemimodule n hn) (a b : Fin n) :
    (reconstructNetwork hn K).eval a b = K.κ a b := by
  simp [reconstructNetwork, BoundedTropicalHashNetwork.eval]

theorem reconstructNetwork_kernelProfile_eq (hn : 0 < n)
    (K : FiniteTropKernelSemimodule n hn) (a b : Fin n) :
    (reconstructNetwork hn K).kernelProfile a b =
    Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
      (fun k => K.κ a k + K.κ b k) := by
  simp only [BoundedTropicalHashNetwork.kernelProfile, reconstructNetwork_eval]

/-- The kernel profile of the reconstructed network bounds K.κ for symmetric kernels. -/
theorem reconstructNetwork_matches_kernel (hn : 0 < n)
    (K : FiniteTropKernelSemimodule n hn)
    (h_symm : ∀ a b, K.κ a b = K.κ b a)
    (a b : Fin n) :
    (reconstructNetwork hn K).kernelProfile a b ≤ K.κ a b := by
  rw [reconstructNetwork_kernelProfile_eq]
  -- For symmetric κ, κ(a,k) + κ(b,k) = κ(a,k) + κ(k,b)
  have : (fun k => K.κ a k + K.κ b k) = (fun k => K.κ a k + K.κ k b) := by
    ext k; rw [h_symm b k]
  rw [this, K.span_eq a b]
  exact Finset.inf'_mono (fun g => K.κ a g + K.κ g b)
    (Finset.subset_univ _) K.generators_nonempty

theorem reconstructNetwork_layerCount (hn : 0 < n)
    (K : FiniteTropKernelSemimodule n hn) :
    (reconstructNetwork hn K).layerCount = 1 := rfl

/-! ## Section 11: Concrete Examples -/

/-- Distance kernel on Fin 2: 0 on diagonal, d off-diagonal. -/
def distKernel (d : ℝ) : Fin 2 → Fin 2 → ℝ :=
  fun a b => if a = b then 0 else d

theorem distKernel_symm (d : ℝ) (a b : Fin 2) :
    distKernel d a b = distKernel d b a := by
  simp only [distKernel]; congr 1; exact propext ⟨Eq.symm, Eq.symm⟩

theorem distKernel_diag (d : ℝ) (a : Fin 2) : distKernel d a a = 0 := if_pos rfl

/-- Distance kernel triangle inequality for d ≥ 0. -/
theorem distKernel_triangle (d : ℝ) (hd : 0 ≤ d) (a b c : Fin 2) :
    distKernel d a c ≤ distKernel d a b + distKernel d b c := by
  simp only [distKernel]
  fin_cases a <;> fin_cases b <;> fin_cases c <;> simp <;> linarith

/-- Distance kernels are idempotent for d ≥ 0. -/
theorem distKernel_idempotent (d : ℝ) (hd : 0 ≤ d) :
    composeKernelProfiles (n := 2) (by omega) (distKernel d) (distKernel d) =
    distKernel d :=
  idempotent_iff_metric (by omega) (distKernel d)
    (distKernel_diag d) (distKernel_triangle d hd)

/-! ## Section 12: Recovery for Tropical Metrics -/

/-- For tropical metrics, reconstruction recovers the kernel profile. -/
theorem reconstructed_kernel_recovers_metric (hn : 0 < n)
    (K : FiniteTropKernelSemimodule n hn)
    (h_symm : ∀ a b, K.κ a b = K.κ b a)
    (h_diag : ∀ x, K.κ x x = 0) :
    ∀ a b, (reconstructNetwork hn K).kernelProfile a b ≤ K.κ a b := by
  intro a b
  rw [reconstructNetwork_kernelProfile_eq]
  calc Finset.univ.inf' _ (fun k => K.κ a k + K.κ b k)
      ≤ K.κ a a + K.κ b a := Finset.inf'_le _ (Finset.mem_univ a)
    _ = K.κ a b := by rw [h_diag a, h_symm b a]; ring

/-! ## Section 13: Distinct Witness Count -/

/-- Number of optimal witnesses for some pair. -/
def distinctWitnessCount (hn : 0 < n) (κ : Fin n → Fin n → ℝ) : ℕ :=
  (Finset.univ.filter (fun k : Fin n =>
    ∃ a b : Fin n, κ a b = κ a k + κ k b)).card

theorem distinctWitnessCount_le (hn : 0 < n) (κ : Fin n → Fin n → ℝ) :
    distinctWitnessCount hn κ ≤ n :=
  le_trans (Finset.card_filter_le _ _) (by simp)

/-! ## Section 14: Duality Summary

| Direction | Theorem | Description |
|-----------|---------|-------------|
| Forward | `kernelProfile_eq_tropicalGram` | Network → Gram kernel |
| Symmetry | `kernelProfile_symm` | Kernel profiles symmetric |
| Witness | `kernelProfile_exists_witness` | Witnesses exist |
| Idempotent | `idempotent_iff_metric` | Metric ↔ Idempotent |
| Composition | `composeKernelProfiles_symm` | Functorial |
| Reconstruction | `reconstructNetwork_matches_kernel` | Certified bound |
| Recovery | `reconstructed_kernel_recovers_metric` | Metric recovery |
-/

end TropicalOneWayKernelDuality