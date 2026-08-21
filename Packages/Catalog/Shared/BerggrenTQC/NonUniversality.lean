import Shared.BerggrenTQC.BraidObstruction

/-!
# Integrality kills universality

The Freedman–Kitaev–Wang universality criterion for a topological quantum computer asks the
image of the braid representation to be **dense** in the relevant unitary group.  The Berggren
generators are *integer* matrices, and this file shows that integrality alone is an absolute
obstruction to that criterion.

Main results.

* `intOrthogonal_iff`: a `2 × 2` integer matrix is orthogonal iff it is one of the eight signed
  permutation matrices; `signedPerms_card` records that there are exactly `8` of them.  So the
  *unitary* part of any integral matrix group is a finite group of order at most `8` — the
  Pauli/Clifford corner, never a dense subgroup.
* `isClosed_integralMat`: the set of complex matrices with integer entries is closed.
* `closure_subset_integralMat`: consequently the closure of any set of integral matrices
  consists of integral matrices.
* `sgate_unitary`, `sgate_not_integral`: the single-qubit phase gate `S = diag(i, 1)` is unitary
  and is not integral.
* `berggrenRep_not_dense`: **the Berggren representation is not dense in `U(2)`**; indeed the
  phase gate `S` is not even in its closure, so it cannot be approximated to any accuracy.
  The moonshot universality claim is therefore false, and false for a structural reason.
* `no_integral_group_is_universal`: the same statement for an arbitrary group of integer
  matrices, isolating integrality (equivalently: discreteness) as the obstruction.
-/

namespace BerggrenTQC

open Matrix

/-! ## The unitary part of an integral matrix group is finite -/

theorem int_sq_add_sq_one {x y : ℤ} (h : x * x + y * y = 1) : x = 0 ∨ x = 1 ∨ x = -1 := by
  have h1 : x * x ≤ 1 := by nlinarith [mul_self_nonneg y]
  have hb : -1 ≤ x ∧ x ≤ 1 := by constructor <;> nlinarith
  omega

/-- The eight signed permutation matrices of size `2`. -/
def signedPerms : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
  {!![1, 0; 0, 1], !![1, 0; 0, -1], !![-1, 0; 0, 1], !![-1, 0; 0, -1],
   !![0, 1; 1, 0], !![0, 1; -1, 0], !![0, -1; 1, 0], !![0, -1; -1, 0]}

theorem signedPerms_card : signedPerms.card = 8 := by decide

/-- **The integral orthogonal group in dimension 2.**  An integer matrix is orthogonal exactly
when it is a signed permutation matrix.  Hence any group of integer matrices meets the unitary
group in a group of order at most `8`. -/
theorem intOrthogonal_iff (M : Matrix (Fin 2) (Fin 2) ℤ) : Mᵀ * M = 1 ↔ M ∈ signedPerms := by
  constructor
  · intro h
    have h0 := congrFun (congrFun h 0) 0
    have h1 := congrFun (congrFun h 1) 1
    simp only [Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_two,
      Matrix.one_apply_eq] at h0 h1
    have ha := int_sq_add_sq_one h0
    have hc := int_sq_add_sq_one (by linarith : M 1 0 * M 1 0 + M 0 0 * M 0 0 = 1)
    have hb := int_sq_add_sq_one h1
    have hd := int_sq_add_sq_one (by linarith : M 1 1 * M 1 1 + M 0 1 * M 0 1 = 1)
    rw [Matrix.eta_fin_two M] at h ⊢
    rcases ha with h' | h' | h' <;> rw [h'] at h ⊢ <;>
    rcases hb with h'' | h'' | h'' <;> rw [h''] at h ⊢ <;>
    rcases hc with h3 | h3 | h3 <;> rw [h3] at h ⊢ <;>
    rcases hd with h4 | h4 | h4 <;> rw [h4] at h ⊢ <;>
    revert h <;> decide
  · intro h
    fin_cases h <;> decide

/-- None of the Berggren generators is orthogonal: the Berggren group is not a group of
"gates" to begin with. -/
theorem berggren_gens_not_orthogonal :
    U₁ᵀ * U₁ ≠ 1 ∧ U₂ᵀ * U₂ ≠ 1 ∧ U₃ᵀ * U₃ ≠ 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp only [U₁, U₂, U₃] <;> decide

/-! ## Integral complex matrices form a closed set -/

/-- Complex matrices all of whose entries are (rational) integers. -/
def IntegralMat : Set (Matrix (Fin 2) (Fin 2) ℂ) :=
  {M | ∀ i j, M i j ∈ Set.range ((↑) : ℤ → ℂ)}

theorem isClosed_integralMat : IsClosed IntegralMat := by
  have h : IntegralMat = ⋂ i : Fin 2, ⋂ j : Fin 2,
      (fun M : Matrix (Fin 2) (Fin 2) ℂ => M i j) ⁻¹' (Set.range ((↑) : ℤ → ℂ)) := by
    ext M; simp [IntegralMat]
  rw [h]
  refine isClosed_iInter fun i => isClosed_iInter fun j => ?_
  exact Complex.isClosed_range_intCast.preimage ((continuous_apply j).comp (continuous_apply i))

theorem closure_subset_integralMat {G : Set (Matrix (Fin 2) (Fin 2) ℂ)} (hG : G ⊆ IntegralMat) :
    closure G ⊆ IntegralMat :=
  isClosed_integralMat.closure_subset_iff.mpr hG

/-! ## A unitary that no integral group can approximate -/

/-- The single-qubit phase gate `S = diag(i, 1)`. -/
noncomputable def Sgate : Matrix (Fin 2) (Fin 2) ℂ := !![Complex.I, 0; 0, 1]

theorem sgate_unitary : Sgate ∈ Matrix.unitaryGroup (Fin 2) ℂ := by
  rw [Matrix.mem_unitaryGroup_iff]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Sgate, Matrix.mul_apply, Fin.sum_univ_two, Matrix.star_apply, Complex.I_mul_I]

theorem sgate_not_integral : Sgate ∉ IntegralMat := by
  intro h
  obtain ⟨k, hk⟩ := h 0 0
  have : ((k : ℂ)).im = Complex.I.im := by rw [hk]; simp [Sgate]
  simp at this

/-- **Integrality forbids universality.**  No group (indeed, no set) of complex matrices with
integer entries has the phase gate in its closure; a fortiori its closure is not all of `U(2)`.
This is the exact point at which the "Berggren braiding is universal" moonshot fails. -/
theorem no_integral_group_is_universal {G : Set (Matrix (Fin 2) (Fin 2) ℂ)}
    (hG : G ⊆ IntegralMat) :
    Sgate ∉ closure G ∧ ¬ ((Matrix.unitaryGroup (Fin 2) ℂ : Set (Matrix (Fin 2) (Fin 2) ℂ))
      ⊆ closure G) := by
  have h1 : Sgate ∉ closure G := fun h => sgate_not_integral (closure_subset_integralMat hG h)
  exact ⟨h1, fun h => h1 (h sgate_unitary)⟩

/-! ## Specialisation to the Berggren group -/

/-- The complexification of an integer matrix. -/
def toC (M : Matrix (Fin 2) (Fin 2) ℤ) : Matrix (Fin 2) (Fin 2) ℂ := M.map (Int.cast)

/-- The Berggren representation: the Berggren group viewed inside `GL(2, ℂ)`, i.e. the set of
"gates" the Berggren braiding could ever produce. -/
def berggrenRep : Set (Matrix (Fin 2) (Fin 2) ℂ) :=
  {N | ∃ g : (Matrix (Fin 2) (Fin 2) ℤ)ˣ, g ∈ berggrenGroup ∧ N = toC (g : Matrix (Fin 2) (Fin 2) ℤ)}

theorem berggrenRep_subset_integral : berggrenRep ⊆ IntegralMat := by
  rintro N ⟨g, -, rfl⟩ i j
  exact ⟨(g : Matrix (Fin 2) (Fin 2) ℤ) i j, by simp [toC]⟩

/-- **The Berggren braiding is not universal.**  The closure of the Berggren representation
misses the phase gate entirely, so it is not dense in `U(2)`: the topological-quantum-computation
universality criterion fails for the Berggren groupoid. -/
theorem berggrenRep_not_dense :
    Sgate ∉ closure berggrenRep ∧
    ¬ ((Matrix.unitaryGroup (Fin 2) ℂ : Set (Matrix (Fin 2) (Fin 2) ℂ)) ⊆ closure berggrenRep) :=
  no_integral_group_is_universal berggrenRep_subset_integral

/-- Stated as a failure of density in the sense of `Dense`: the Berggren representation is not
dense in the space of all `2 × 2` complex matrices either. -/
theorem berggrenRep_not_dense_univ : ¬ Dense berggrenRep := by
  intro h
  exact berggrenRep_not_dense.1 (by simpa using h Sgate)

end BerggrenTQC