/-
  TropicalFeynman.lean

  Future Direction 6.1: Tropical Feynman Integrals

  The reduction of Feynman path integrals to classical multipaths suggests a
  tropical Feynman calculus where the path integral becomes a tropical sum
  (minimum) over classical actions. We formalize the key structures.

  Key insight: In the Maslov dequantization limit ℏ → 0, the Feynman path
  integral ∫ e^{iS/ℏ} Dpath → min_paths S (tropical minimum).
-/
import Mathlib

open Real

namespace TropicalFeynman

/-! ## Section 1: Tropical Path Integral Foundations

The Feynman path integral ∫ e^{iS[x]/ℏ} Dx in the tropical limit becomes
the min-plus selection: ⊕_paths S[x] = min_paths S[x]. -/

/-- Tropical sum (min-plus addition) over a finite set of actions -/
noncomputable def tropicalPathIntegral {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty actions

/-- Soft tropical path integral (quantum version with temperature ε) -/
noncomputable def softTropicalPathIntegral {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) : ℝ :=
  -ε * Real.log (Finset.sum Finset.univ (fun j => Real.exp (-actions j / ε)))

/-- Classical Feynman weight for a single path -/
noncomputable def feynmanWeight (action : ℝ) (hbar : ℝ) : ℂ :=
  Complex.exp (Complex.I * (action / hbar))

/-- Tropical weight (real-valued, in the ℏ→0 limit) -/
noncomputable def tropicalWeight (action : ℝ) (ε : ℝ) : ℝ :=
  Real.exp (-action / ε)

/-! ### Tropical path integral bounds -/

/-- The tropical path integral is bounded above by any individual action -/
theorem tropicalPathIntegral_le {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (j : Fin n) :
    tropicalPathIntegral actions ≤ actions j := by
  exact Finset.inf'_le _ (Finset.mem_univ _)

/-
The tropical path integral equals some action (achieved minimum)
-/
theorem tropicalPathIntegral_achieved {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) :
    ∃ j, tropicalPathIntegral actions = actions j := by
  -- By definition of infimum, there exists some $j$ such that $actions j$ is equal to the infimum.
  have h_inf : ∃ j : Fin n, ∀ i : Fin n, actions j ≤ actions i := by
    simpa using Finset.exists_min_image Finset.univ ( fun i => actions i ) ( Finset.univ_nonempty );
  exact ⟨ h_inf.choose, le_antisymm ( Finset.inf'_le _ <| Finset.mem_univ _ ) <| Finset.le_inf' _ _ fun i _ => h_inf.choose_spec i ⟩

/-
Tropical weights sum to at least 1 when minimum action is 0
-/
theorem tropical_weight_sum_lower {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) (j : Fin n)
    (hj : actions j = 0) (hn : ∀ i, 0 ≤ actions i) :
    1 ≤ Finset.sum Finset.univ (fun i => tropicalWeight (actions i) ε) := by
  exact le_trans ( by norm_num [ hj, tropicalWeight, hε.ne' ] ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( -actions i / ε ) ) ( Finset.mem_univ j ) )

/-! ## Section 2: Stationary Phase and Tropical Vertex

The stationary phase approximation δS/δx = 0 selects classical paths.
In tropical geometry, these correspond to tropical vertices. -/

/-- A path is stationary if it achieves the tropical minimum -/
def isStationaryPath {n : ℕ} [NeZero n] (actions : Fin n → ℝ) (j : Fin n) : Prop :=
  ∀ i, actions j ≤ actions i

/-
Every finite collection of paths has a stationary path
-/
theorem exists_stationary_path {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    ∃ j, isStationaryPath actions j := by
  cases' Finset.exists_min_image Finset.univ ( fun x => actions x ) ( Finset.univ_nonempty ) with j hj ; use j ; aesop

/-
Stationary path achieves the tropical integral
-/
theorem stationary_achieves_tropical {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (j : Fin n) (hj : isStationaryPath actions j) :
    tropicalPathIntegral actions = actions j := by
  exact le_antisymm ( Finset.inf'_le _ <| Finset.mem_univ _ ) ( Finset.le_inf' _ _ fun i _ => hj i )

/-! ## Section 3: Tropical Propagator

The quantum propagator K(x,t;x₀,t₀) = ∫ e^{iS/ℏ} Dx has a tropical
analogue K_trop(x,t;x₀,t₀) = min_paths S[x]. -/

/-- Tropical propagator: minimum action between two points -/
noncomputable def tropicalPropagator {n : ℕ} [NeZero n]
    (pathActions : Fin n → ℝ) : ℝ :=
  tropicalPathIntegral pathActions

/-- Tropical propagator composition (min-plus convolution)
    K_trop(x₂,x₀) = min_x₁ [K_trop(x₂,x₁) + K_trop(x₁,x₀)] -/
noncomputable def tropicalComposition {n m : ℕ} [NeZero n] [NeZero m]
    (K₁ : Fin n → ℝ) (K₂ : Fin m → ℝ) : ℝ :=
  Finset.inf' (Finset.univ ×ˢ Finset.univ)
    (by simp [Finset.Nonempty])
    (fun p => K₁ p.1 + K₂ p.2)

/-
Tropical propagator is subadditive
-/
theorem tropicalPropagator_triangle {n m : ℕ} [NeZero n] [NeZero m]
    (K₁ : Fin n → ℝ) (K₂ : Fin m → ℝ) :
    tropicalComposition K₁ K₂ ≤ tropicalPathIntegral K₁ + tropicalPathIntegral K₂ := by
  refine' le_trans _ ( add_le_add _ _ );
  convert Finset.inf'_le _ _;
  exact ⟨ Classical.choose ( tropicalPathIntegral_achieved K₁ ), Classical.choose ( tropicalPathIntegral_achieved K₂ ) ⟩;
  · exact Finset.mem_product.mpr ⟨ Finset.mem_univ _, Finset.mem_univ _ ⟩;
  · exact Classical.choose_spec ( tropicalPathIntegral_achieved K₁ ) ▸ le_rfl;
  · exact Classical.choose_spec ( tropicalPathIntegral_achieved K₂ ) ▸ le_rfl

/-! ## Section 4: Tropical Amplitude and Interference

In tropical geometry, interference becomes piecewise-linear:
max(a,b) = (a+b)/2 + |a-b|/2 (tropical analogue of |ψ₁+ψ₂|²) -/

/-- Tropical interference: the "probability" in tropical limit -/
noncomputable def tropicalInterference (S₁ S₂ : ℝ) : ℝ :=
  min S₁ S₂

/-- Tropical interference selects the dominant (minimum action) path -/
theorem tropical_interference_min (S₁ S₂ : ℝ) :
    tropicalInterference S₁ S₂ = min S₁ S₂ := by
  rfl

/-- When actions are equal, both paths contribute equally (caustic) -/
theorem tropical_caustic (S : ℝ) :
    tropicalInterference S S = S := by
  simp [tropicalInterference]

/-- Tropical interference is commutative -/
theorem tropical_interference_comm (S₁ S₂ : ℝ) :
    tropicalInterference S₁ S₂ = tropicalInterference S₂ S₁ := by
  simp [tropicalInterference, min_comm]

/-- Tropical interference is associative -/
theorem tropical_interference_assoc (S₁ S₂ S₃ : ℝ) :
    tropicalInterference (tropicalInterference S₁ S₂) S₃ =
    tropicalInterference S₁ (tropicalInterference S₂ S₃) := by
  simp [tropicalInterference, min_assoc]

/-- Tropical interference is idempotent -/
theorem tropical_interference_idem (S : ℝ) :
    tropicalInterference S S = S := by
  simp [tropicalInterference]

/-! ## Section 5: Action Additivity and Tropical Linearity

The classical action is additive along paths: S[x₁→x₃] = S[x₁→x₂] + S[x₂→x₃].
This becomes tropical linearity: a ⊗ b = a + b in min-plus algebra. -/

/-- Tropical multiplication (= ordinary addition) -/
def tropicalMul (a b : ℝ) : ℝ := a + b

/-- Tropical multiplication is commutative -/
theorem tropicalMul_comm (a b : ℝ) : tropicalMul a b = tropicalMul b a := by
  unfold tropicalMul; ring

/-- Tropical multiplication is associative -/
theorem tropicalMul_assoc (a b c : ℝ) :
    tropicalMul (tropicalMul a b) c = tropicalMul a (tropicalMul b c) := by
  unfold tropicalMul; ring

/-- Tropical multiplication distributes over tropical addition (min) -/
theorem tropicalMul_distrib (a b c : ℝ) :
    tropicalMul a (min b c) = min (tropicalMul a b) (tropicalMul a c) := by
  simp [tropicalMul, min_add_add_left]

/-- Zero element of tropical multiplication is 0 (identity action) -/
theorem tropicalMul_zero (a : ℝ) : tropicalMul a 0 = a := by
  unfold tropicalMul; ring

end TropicalFeynman