import Geometry.ToricCode.Dual
/-!
# Abstract self-duality: when are the `X`- and `Z`-spectra equal?

`ToricCode.dualLogicalWeights_eq` proved that the primal and dual logical weight
spectra of the square-grid torus coincide, by exhibiting one explicit
quarter-turn permutation of the qubit set.  This file isolates *exactly* what
that argument used, answering sub-conjecture 3 of the previous cycle's
`FUTURE_DIRECTIONS.md`.

We introduce

* `BinaryCSS V E F` — a three-term binary chain complex `𝔽₂^F → 𝔽₂^E → 𝔽₂^V`
  given by two matrices with `A * B = 0`, i.e. a CSS code with qubit set `E`,
  `Z`-checks `V` and `X`-checks `F`;
* `BinaryCSS.SelfDual` — the *data* of a weight-preserving self-duality: a
  permutation `τ` of the qubits together with bijections `σ : F ≃ V` and
  `ρ : V ≃ F` of the two check sets, satisfying the two intertwining identities
  `Bᵀ(z ∘ τ) = (A z) ∘ σ` and `(B g) ∘ τ = Aᵀ (g ∘ ρ)`.

The main theorem `BinaryCSS.SelfDual.logicalWeights_eq` says that such data
forces the *full* primal and dual logical weight spectra to be equal as subsets
of `ℕ` — hence in particular `d_X = d_Z` (`SelfDual.dualDistance_eq`).  No
finiteness of the field, no surface, no locality is used: the statement is pure
linear algebra over `𝔽₂` plus a bijection.

Finally `toricSelfDual` exhibits the `M × N` torus as an instance, so the
concrete result of `ToricCode.Dual` is recovered from the general principle.
-/

open Matrix

namespace ToricCode

/-- A binary CSS code: a three-term chain complex `𝔽₂^F --B--> 𝔽₂^E --A--> 𝔽₂^V`
over `𝔽₂`.  `E` is the qubit set, `V` indexes the `Z`-checks and `F` the
`X`-checks. -/
structure BinaryCSS (V E F : Type*) [Fintype V] [Fintype E] [Fintype F] [DecidableEq E] where
  /-- The boundary map `∂₁` (the `Z`-check matrix). -/
  A : Matrix V E F2
  /-- The boundary map `∂₂` (the `X`-check matrix). -/
  B : Matrix E F F2
  /-- The chain condition `∂₁ ∘ ∂₂ = 0`. -/
  chain : A * B = 0

namespace BinaryCSS

variable {V E F : Type*} [Fintype V] [Fintype E] [Fintype F] [DecidableEq E]
variable (C : BinaryCSS V E F)

/-- `Z`-cycles: chains with trivial syndrome. -/
noncomputable def cycles : Submodule F2 (E → F2) := LinearMap.ker C.A.mulVecLin

/-- `Z`-boundaries: the stabiliser group. -/
noncomputable def boundaries : Submodule F2 (E → F2) := LinearMap.range C.B.mulVecLin

/-- `X`-cycles of the dual (cochain) complex. -/
noncomputable def dualCycles : Submodule F2 (E → F2) := LinearMap.ker (C.Bᵀ).mulVecLin

/-- `X`-boundaries of the dual (cochain) complex. -/
noncomputable def dualBoundaries : Submodule F2 (E → F2) := LinearMap.range (C.Aᵀ).mulVecLin

/-- Boundaries are cycles — the chain condition. -/
theorem boundaries_le_cycles : C.boundaries ≤ C.cycles := by
  rintro z ⟨g, rfl⟩
  rw [cycles, LinearMap.mem_ker, Matrix.mulVecLin_apply, Matrix.mulVecLin_apply,
    Matrix.mulVec_mulVec, C.chain, Matrix.zero_mulVec]

/-- Weights of the undetectable non-stabiliser (`Z`-type) errors. -/
def logicalWeights : Set ℕ :=
  {w | ∃ z : E → F2, z ∈ C.cycles ∧ z ∉ C.boundaries ∧ hammingNorm z = w}

/-- Weights of the undetectable non-stabiliser (`X`-type) errors. -/
def dualLogicalWeights : Set ℕ :=
  {w | ∃ z : E → F2, z ∈ C.dualCycles ∧ z ∉ C.dualBoundaries ∧ hammingNorm z = w}

/-- The `Z`-distance. -/
noncomputable def distance : ℕ := sInf C.logicalWeights

/-- The `X`-distance. -/
noncomputable def dualDistance : ℕ := sInf C.dualLogicalWeights

/-- **Self-duality data** for a binary CSS code: a permutation `τ` of the qubits
together with bijections `σ, ρ` between the two check sets, intertwining the
boundary map with the dual boundary map and boundaries with coboundaries. -/
structure SelfDual (C : BinaryCSS V E F) where
  /-- The weight-preserving relabelling of the qubits. -/
  tau : E ≃ E
  /-- The matching of `X`-checks with `Z`-checks used by the cycle identity. -/
  sigma : F ≃ V
  /-- The matching of `Z`-checks with `X`-checks used by the boundary identity. -/
  rho : V ≃ F
  /-- `τ` turns the boundary map into the dual boundary map. -/
  intertwine_cycle : ∀ z : E → F2, (C.Bᵀ) *ᵥ (z ∘ tau) = (C.A *ᵥ z) ∘ sigma
  /-- `τ` turns boundaries into coboundaries. -/
  intertwine_boundary : ∀ g : F → F2, (C.B *ᵥ g) ∘ tau = (C.Aᵀ) *ᵥ (g ∘ rho)

namespace SelfDual

variable {C}

/-- Every coboundary is the `τ`-relabelling of a boundary. -/
lemma coboundary_eq (S : SelfDual C) (h : V → F2) :
    (C.Aᵀ) *ᵥ h = (C.B *ᵥ (h ∘ S.rho.symm)) ∘ S.tau := by
  rw [S.intertwine_boundary]
  congr 1
  funext v
  simp

/-- **A self-dual CSS code has equal primal and dual logical weight spectra.**
Not merely equal minima: the two sets of achievable logical weights coincide. -/
theorem logicalWeights_eq (S : SelfDual C) :
    C.dualLogicalWeights = C.logicalWeights := by
  ext w
  constructor
  · rintro ⟨z, hz, hnb, rfl⟩
    refine ⟨z ∘ S.tau.symm, ?_, ?_, ?_⟩
    · rw [cycles, LinearMap.mem_ker, Matrix.mulVecLin_apply]
      have hzz : (z ∘ S.tau.symm) ∘ S.tau = z := by funext e; simp
      have hkey := S.intertwine_cycle (z ∘ S.tau.symm)
      have hz0 : (C.Bᵀ) *ᵥ z = 0 := hz
      rw [hzz, hz0] at hkey
      funext v
      have := congrFun hkey.symm (S.sigma.symm v)
      simpa using this
    · rintro ⟨g, hg⟩
      refine hnb ⟨g ∘ S.rho, ?_⟩
      rw [Matrix.mulVecLin_apply, ← S.intertwine_boundary]
      rw [Matrix.mulVecLin_apply] at hg
      rw [hg]
      funext e
      simp
    · exact ToricCode.hammingNorm_comp_equiv S.tau.symm z
  · rintro ⟨z, hz, hnb, rfl⟩
    refine ⟨z ∘ S.tau, ?_, ?_, ?_⟩
    · have hz0 : C.A *ᵥ z = 0 := hz
      rw [dualCycles, LinearMap.mem_ker, Matrix.mulVecLin_apply, S.intertwine_cycle, hz0]
      rfl
    · rintro ⟨h, hh⟩
      refine hnb ⟨h ∘ S.rho.symm, ?_⟩
      rw [Matrix.mulVecLin_apply] at hh ⊢
      have hkey := S.coboundary_eq h
      rw [hh] at hkey
      funext e
      have := congrFun hkey (S.tau.symm e)
      simpa using this.symm
    · exact ToricCode.hammingNorm_comp_equiv S.tau z

/-- **A self-dual CSS code has `d_X = d_Z`.** -/
theorem dualDistance_eq (S : SelfDual C) : C.dualDistance = C.distance := by
  rw [dualDistance, distance, S.logicalWeights_eq]

end SelfDual

end BinaryCSS

/-! ### The torus is an instance -/

variable (M N : ℕ) [NeZero M] [NeZero N]

/-- The `M × N` torus as an abstract binary CSS code. -/
def toricCSS : BinaryCSS (Vert M N) (Edge M N) (Face M N) where
  A := d1 M N
  B := d2 M N
  chain := by
    ext v f
    have h2 : ((d1 M N * d2 M N) *ᵥ (Pi.single f (1 : F2))) v = 0 := by
      rw [← Matrix.mulVec_mulVec, d1_d2_mulVec]; rfl
    simpa [Matrix.mulVec, dotProduct, Pi.single_apply] using h2

/-- **The quarter turn makes the torus code self-dual**, in the abstract sense
of `BinaryCSS.SelfDual`. -/
def toricSelfDual : (toricCSS M N).SelfDual where
  tau := tauEquiv M N
  sigma := Equiv.refl _
  rho := Equiv.subRight (1, 1)
  intertwine_cycle z := by simpa using d2T_mulVec_comp_tau M N z
  intertwine_boundary g := d2_comp_tau M N g

/-- Recovering `ToricCode.dualLogicalWeights_eq` from the general principle. -/
theorem toricCSS_logicalWeights_eq :
    (toricCSS M N).dualLogicalWeights = (toricCSS M N).logicalWeights :=
  BinaryCSS.SelfDual.logicalWeights_eq (toricSelfDual M N)

/-- The abstract distance of `toricCSS` is the geometric one: `min M N`. -/
theorem toricCSS_distance : (toricCSS M N).distance = min M N :=
  toric_distance M N

/-- The abstract dual distance of `toricCSS` is `min M N` as well. -/
theorem toricCSS_dualDistance : (toricCSS M N).dualDistance = min M N := by
  rw [BinaryCSS.SelfDual.dualDistance_eq (toricSelfDual M N)]
  exact toricCSS_distance M N

end ToricCode