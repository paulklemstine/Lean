import ToricCode.Dual
import Probability.HomologicalDistance

/-!
# Bridge: the rectangular torus realises a catalog `CellularCode`

The previous research cycle introduced the abstract structure
`TopologicalQEC.CellularCode` — a three-term binary chain complex indexed by
`Fin n` — and proved that its operational distance equals its combinatorial
one-systole.  That development was purely algebraic: no cellulation was ever
exhibited.

Here we close the loop demanded by future target 1: we produce an explicit
`CellularCode` **induced by a genuine cellulation** (the `M × N` square-grid
torus) and transport all the geometric results of this directory to it.  In
particular `toricCellularCode_systole` gives a nonabstract, geometrically
meaningful value for the catalog notion of one-systole.
-/

open Matrix TopologicalQEC

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

/-- Precomposition with a bijection, as a linear equivalence of function spaces. -/
def preComp {α β : Type*} (e : α ≃ β) : (β → F2) ≃ₗ[F2] (α → F2) where
  toFun z := z ∘ e
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
  invFun z := z ∘ e.symm
  left_inv z := by funext b; simp
  right_inv z := by funext a; simp

@[simp] lemma preComp_apply {α β : Type*} (e : α ≃ β) (z : β → F2) (a : α) :
    preComp e z a = z (e a) := rfl

/-- An enumeration of the `2MN` qubits. -/
noncomputable def eEdge : Fin (2 * (M * N)) ≃ Edge M N :=
  (Fintype.equivFinOfCardEq (card_edge M N)).symm

/-- An enumeration of the `MN` vertices (`Z`-checks). -/
noncomputable def eVert : Fin (M * N) ≃ Vert M N :=
  (Fintype.equivFinOfCardEq (card_vert M N)).symm

/-- An enumeration of the `MN` faces (`X`-checks). -/
noncomputable def eFace : Fin (M * N) ≃ Face M N :=
  (Fintype.equivFinOfCardEq (card_face M N)).symm

/-- Relabelling of one-chains by the chosen enumeration of qubits. -/
noncomputable def QE : (Fin (2 * (M * N)) → F2) ≃ₗ[F2] (Edge M N → F2) :=
  preComp (eEdge M N).symm

/-- Relabelling of zero-chains. -/
noncomputable def QV : (Vert M N → F2) ≃ₗ[F2] (Fin (M * N) → F2) := preComp (eVert M N)

/-- Relabelling of two-chains. -/
noncomputable def QF : (Fin (M * N) → F2) ≃ₗ[F2] (Face M N → F2) := preComp (eFace M N).symm

/-- **The rectangular torus, presented as a catalog `CellularCode`.** -/
noncomputable def toricCellularCode : CellularCode where
  n₀ := M * N
  n₁ := 2 * (M * N)
  n₂ := M * N
  d₁ := (QV M N).toLinearMap ∘ₗ (d1 M N).mulVecLin ∘ₗ (QE M N).toLinearMap
  d₂ := (QE M N).symm.toLinearMap ∘ₗ (d2 M N).mulVecLin ∘ₗ (QF M N).toLinearMap
  chain_condition := by
    refine LinearMap.ext fun g => ?_
    simp only [LinearMap.comp_apply, LinearMap.zero_apply, LinearEquiv.coe_coe,
      LinearEquiv.apply_symm_apply, Matrix.mulVecLin_apply]
    rw [d1_d2_mulVec]
    exact map_zero _

@[simp] lemma toricCellularCode_n₁ : (toricCellularCode M N).n₁ = 2 * (M * N) := rfl

/-! ### Transport of cycles and boundaries -/

lemma mem_cycles_iff (z : Fin (2 * (M * N)) → F2) :
    z ∈ (toricCellularCode M N).cycles ↔ (QE M N) z ∈ cycles M N := by
  constructor
  · intro hz
    rw [CellularCode.cycles, LinearMap.mem_ker] at hz
    have h2 : (QV M N) ((d1 M N).mulVecLin ((QE M N) z)) = 0 := hz
    have h3 := congrArg (QV M N).symm h2
    simpa using h3
  · intro hz
    rw [CellularCode.cycles, LinearMap.mem_ker]
    show (QV M N) ((d1 M N).mulVecLin ((QE M N) z)) = 0
    rw [(by exact hz : (d1 M N).mulVecLin ((QE M N) z) = 0)]
    exact map_zero _

lemma mem_boundaries_iff (z : Fin (2 * (M * N)) → F2) :
    z ∈ (toricCellularCode M N).boundaries ↔ (QE M N) z ∈ boundaries M N := by
  constructor
  · rintro ⟨g, rfl⟩
    refine ⟨(QF M N) g, ?_⟩
    show (d2 M N).mulVecLin ((QF M N) g)
      = (QE M N) ((QE M N).symm ((d2 M N).mulVecLin ((QF M N) g)))
    rw [LinearEquiv.apply_symm_apply]
  · rintro ⟨g, hg⟩
    refine ⟨(QF M N).symm g, ?_⟩
    show (QE M N).symm ((d2 M N).mulVecLin ((QF M N) ((QF M N).symm g))) = z
    rw [LinearEquiv.apply_symm_apply, hg, LinearEquiv.symm_apply_apply]

/-! ### The catalog invariants of the toric code -/

lemma cycles_eq_map :
    (toricCellularCode M N).cycles
      = Submodule.map (QE M N).symm.toLinearMap (cycles M N) := by
  ext z
  rw [mem_cycles_iff]
  constructor
  · intro hz
    exact ⟨(QE M N) z, hz, by simp⟩
  · rintro ⟨w, hw, rfl⟩
    simpa using hw

lemma boundaries_eq_map :
    (toricCellularCode M N).boundaries
      = Submodule.map (QE M N).symm.toLinearMap (boundaries M N) := by
  ext z
  rw [mem_boundaries_iff]
  constructor
  · intro hz
    exact ⟨(QE M N) z, hz, by simp⟩
  · rintro ⟨w, hw, rfl⟩
    simpa using hw

/-- **The catalog code obtained from the torus encodes two logical qubits.** -/
theorem toricCellularCode_logicalQubits : (toricCellularCode M N).homologyRank = 2 := by
  rw [CellularCode.homologyRank, cycles_eq_map, boundaries_eq_map,
    LinearEquiv.finrank_map_eq, LinearEquiv.finrank_map_eq]
  exact toric_homologyRank M N

/-! ### The catalog distance and systole -/

lemma logicalWeights_bridge :
    (toricCellularCode M N).logicalWeights = logicalWeights M N := by
  ext w
  constructor
  · rintro ⟨z, hz, hnb, rfl⟩
    refine ⟨(QE M N) z, (mem_cycles_iff M N z).1 hz,
      fun hc => hnb ((mem_boundaries_iff M N z).2 hc), ?_⟩
    exact hammingNorm_comp_equiv (eEdge M N).symm z
  · rintro ⟨z, hz, hnb, rfl⟩
    refine ⟨(QE M N).symm z, ?_, ?_, ?_⟩
    · rw [mem_cycles_iff, LinearEquiv.apply_symm_apply]; exact hz
    · rw [mem_boundaries_iff, LinearEquiv.apply_symm_apply]; exact hnb
    · have h : (QE M N).symm z = z ∘ (eEdge M N) := rfl
      rw [h]
      exact hammingNorm_comp_equiv (eEdge M N) z

/-- **The catalog distance of the toric cellular code is `min M N`.** -/
theorem toricCellularCode_distance : (toricCellularCode M N).distance = min M N := by
  rw [CellularCode.distance, logicalWeights_bridge]
  exact toric_distance M N

/-- **The catalog one-systole of the `M × N` torus is `min M N`.**  Combining the
abstract catalog theorem `distance = systole` with the geometric computation of
this directory: the shortest noncontractible cellular loop on the `M × N`
square-grid torus has exactly `min M N` edges. -/
theorem toricCellularCode_systole : (toricCellularCode M N).systole = min M N := by
  rw [← CellularCode.distance_eq_systole]
  exact toricCellularCode_distance M N

/-- **Summary.**  The square-grid cellulation of the torus induces a catalog
`CellularCode` with `2MN` physical qubits, first homology of rank `2`, and
distance (equivalently, one-systole) exactly `min M N`. -/
theorem toricCellularCode_parameters :
    (toricCellularCode M N).n₁ = 2 * (M * N) ∧
    (toricCellularCode M N).homologyRank = 2 ∧
    (toricCellularCode M N).distance = min M N ∧
    (toricCellularCode M N).systole = min M N :=
  ⟨rfl, toricCellularCode_logicalQubits M N, toricCellularCode_distance M N,
    toricCellularCode_systole M N⟩

end ToricCode