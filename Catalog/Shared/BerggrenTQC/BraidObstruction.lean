import Shared.BerggrenTQC.EuclidLift

/-!
# No braid relation among the Berggren generators

The moonshot hypothesis is that the three Berggren generators braid, i.e. that
`σᵢ ↦ Bᵢ` defines a representation of an Artin braid group.  This file settles that
question in the negative and locates the obstruction precisely.

Main results.

* `braid_trace_two_two`: a general criterion.  If `X Y : Matrix (Fin 2) (Fin 2) ℤ` satisfy the
  braid relation `XYX = YXY` and have equal determinant, then
  `(tr X - tr Y) * (tr (XY) + det X) = 0`.  This is the classical `SL₂` trace criterion, proved
  here from Cayley–Hamilton in entrywise form.
* `berggren_traces`: all three Berggren lifts have trace `2`, so the trace criterion is
  *inconclusive* for them — the obstruction is not visible at the level of traces.
* `braid_fails_lift_12`, `braid_fails_lift_13`, `braid_fails_lift_23` and the corresponding
  statements `braid_fails_B₁₂`, `braid_fails_B₁₃`, `braid_fails_B₂₃` for the `3 × 3` Berggren
  matrices of the catalog: **every** pair of Berggren generators fails the braid relation.
* `berggren_mod_two`: every element of the Berggren group reduces mod `2` to either `1` or the
  swap `J = !![0,1;1,0]`.  In other words the Berggren group is contained in the *theta group*
  `Γ_θ`-type congruence condition, and carries a `ℤ/2`-valued *charge* (`charge_mul`,
  `charge_surjective`), which is abelian: the braiding statistics the tree can support are
  abelian (boson/fermion-like), never non-abelian.
* `braid_generators_not_berggren`: the standard braid pair `T = !![1,1;0,1]`,
  `L = !![1,0;-1,1]` of `SL(2,ℤ)` — the image of the Artin generators under the classical
  surjection `B₃ ↠ SL(2,ℤ)` — does satisfy the braid relation (`T_L_braid`) but **neither
  element lies in the Berggren group**.  Hence the Berggren group misses the braid generators
  of `SL(2,ℤ)` altogether.
* `berggrenGroup_ne_top`: consequently the Berggren group is a proper subgroup of `GL(2,ℤ)`.
-/

namespace BerggrenTQC

open Matrix

/-! ## The `SL₂` trace criterion for braiding -/

/-- **Trace criterion for the braid relation in dimension 2.**  If two `2 × 2` integer matrices
of equal determinant satisfy the braid relation, then either their traces agree or
`tr (XY) = -det X`.  (Cayley–Hamilton in entrywise form.) -/
theorem braid_trace_two_two (X Y : Matrix (Fin 2) (Fin 2) ℤ) (h : X * Y * X = Y * X * Y)
    (hd : X.det = Y.det) :
    (X.trace - Y.trace) * (Matrix.trace (X * Y) + X.det) = 0 := by
  have h00 := congrFun (congrFun h 0) 0
  have h11 := congrFun (congrFun h 1) 1
  simp only [Matrix.mul_apply, Fin.sum_univ_two] at h00 h11
  simp only [Matrix.trace_fin_two, Matrix.det_fin_two, Matrix.mul_apply, Fin.sum_univ_two] at hd ⊢
  linear_combination h00 + h11 + (X 0 0 + X 1 1) * hd

/-- All three Berggren lifts are unipotent-looking: they have trace `2`.  The trace criterion
therefore gives no obstruction, and the failure of braiding below is a genuinely finer fact. -/
theorem berggren_traces : U₁.trace = 2 ∧ U₂.trace = 2 ∧ U₃.trace = 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [U₁, U₂, U₃, Matrix.trace_fin_two]

/-! ## The braid relations all fail -/

theorem braid_fails_lift_12 : U₁ * U₂ * U₁ ≠ U₂ * U₁ * U₂ := by decide

theorem braid_fails_lift_13 : U₁ * U₃ * U₁ ≠ U₃ * U₁ * U₃ := by decide

theorem braid_fails_lift_23 : U₂ * U₃ * U₂ ≠ U₃ * U₂ * U₃ := by decide

theorem braid_fails_B₁₂ : B₁_mat * B₂_mat * B₁_mat ≠ B₂_mat * B₁_mat * B₂_mat := by decide

theorem braid_fails_B₁₃ : B₁_mat * B₃_mat * B₁_mat ≠ B₃_mat * B₁_mat * B₃_mat := by decide

theorem braid_fails_B₂₃ : B₂_mat * B₃_mat * B₂_mat ≠ B₃_mat * B₂_mat * B₃_mat := by decide

/-- The Berggren generators do not commute either, so they are not "far apart" strands of a
braid: no Artin presentation of any kind is satisfied by the pair `(B₁, B₂)`. -/
theorem berggren_noncommuting : U₁ * U₂ ≠ U₂ * U₁ := by decide

/-- **No Artin braid representation.**  For no pair of distinct Berggren generators does the
assignment `σ₁, σ₂ ↦` that pair satisfy either the braid relation or the commutation
relation of an Artin generator pair. -/
theorem no_artin_relation :
    (U₁ * U₂ * U₁ ≠ U₂ * U₁ * U₂ ∧ U₁ * U₂ ≠ U₂ * U₁) ∧
    (U₁ * U₃ * U₁ ≠ U₃ * U₁ * U₃ ∧ U₁ * U₃ ≠ U₃ * U₁) ∧
    (U₂ * U₃ * U₂ ≠ U₃ * U₂ * U₃ ∧ U₂ * U₃ ≠ U₃ * U₂) :=
  ⟨⟨braid_fails_lift_12, berggren_noncommuting⟩,
   ⟨braid_fails_lift_13, by decide⟩,
   ⟨braid_fails_lift_23, by decide⟩⟩

/-! ## The mod 2 obstruction: the Berggren group is a theta-type congruence subgroup -/

/-- Reduction of integer matrices mod `2`. -/
def redHom : Matrix (Fin 2) (Fin 2) ℤ →+* Matrix (Fin 2) (Fin 2) (ZMod 2) :=
  (Int.castRingHom (ZMod 2)).mapMatrix

/-- The mod `2` swap matrix. -/
def Jm : Matrix (Fin 2) (Fin 2) (ZMod 2) := !![0, 1; 1, 0]

theorem Jm_mul_Jm : Jm * Jm = 1 := by decide

theorem red_U₁ : redHom U₁ = Jm := by
  simp only [redHom, U₁, Jm, RingHom.mapMatrix_apply]; decide

theorem red_U₂ : redHom U₂ = Jm := by
  simp only [redHom, U₂, Jm, RingHom.mapMatrix_apply]; decide

theorem red_U₃ : redHom U₃ = 1 := by
  simp only [redHom, U₃, RingHom.mapMatrix_apply]; decide

/-- **The theta-group congruence condition.**  Every element of the Berggren group reduces
mod `2` either to the identity or to the swap `J`.  Thus the Berggren group is contained in a
proper congruence-type subgroup of `GL(2, ℤ)`, of index at least `3`. -/
theorem berggren_mod_two (g : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) (hg : g ∈ berggrenGroup) :
    redHom (g : Matrix (Fin 2) (Fin 2) ℤ) = 1 ∨ redHom (g : Matrix (Fin 2) (Fin 2) ℤ) = Jm := by
  induction hg using Subgroup.closure_induction with
  | mem x hx =>
      rcases hx with h | h | h
      · subst h; exact Or.inr (by simpa [g₁] using red_U₁)
      · subst h; exact Or.inr (by simpa [g₂] using red_U₂)
      · subst h; exact Or.inl (by simpa [g₃] using red_U₃)
  | one => exact Or.inl (by simp)
  | mul x y _ _ hx hy =>
      have hxy : redHom ((x * y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
          = redHom (x : Matrix (Fin 2) (Fin 2) ℤ) * redHom (y : Matrix (Fin 2) (Fin 2) ℤ) := by
        rw [Units.val_mul, map_mul]
      rcases hx with hx | hx <;> rcases hy with hy | hy <;>
        rw [hxy, hx, hy]
      · exact Or.inl (by simp)
      · exact Or.inr (by simp)
      · exact Or.inr (by simp)
      · exact Or.inl Jm_mul_Jm
  | inv x _ hx =>
      have hinv : redHom ((x⁻¹ : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ) *
          redHom (x : Matrix (Fin 2) (Fin 2) ℤ) = 1 := by
        rw [← map_mul, ← Units.val_mul, inv_mul_cancel, Units.val_one, map_one]
      rcases hx with hx | hx
      · rw [hx, mul_one] at hinv; exact Or.inl hinv
      · rw [hx] at hinv
        refine Or.inr ?_
        calc redHom ((x⁻¹ : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
            = redHom ((x⁻¹ : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ) *
                (Jm * Jm) := by rw [Jm_mul_Jm, mul_one]
          _ = Jm := by rw [← mul_assoc, hinv, one_mul]

/-! ## The `ℤ/2` charge of a Berggren element: abelian statistics -/

/-- The mod `2` *charge* of an integer matrix: `0` if it reduces to the identity, `1`
otherwise.  On the Berggren group this is a homomorphism to `ℤ/2` (`charge_mul`). -/
def charge (M : Matrix (Fin 2) (Fin 2) ℤ) : ZMod 2 := if redHom M = 1 then 0 else 1

theorem charge_mul (x y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ)
    (hx : x ∈ berggrenGroup) (hy : y ∈ berggrenGroup) :
    charge ((x * y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
      = charge (x : Matrix (Fin 2) (Fin 2) ℤ) + charge (y : Matrix (Fin 2) (Fin 2) ℤ) := by
  have hJ : Jm ≠ 1 := by decide
  have hxy : redHom ((x * y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
      = redHom (x : Matrix (Fin 2) (Fin 2) ℤ) * redHom (y : Matrix (Fin 2) (Fin 2) ℤ) := by
    rw [Units.val_mul, map_mul]
  simp only [charge, hxy]
  rcases berggren_mod_two x hx with hx' | hx' <;> rcases berggren_mod_two y hy with hy' | hy' <;>
    rw [hx', hy'] <;> simp [hJ, Jm_mul_Jm, show (1 : ZMod 2) + 1 = 0 from rfl]

/-- The charge is onto `ℤ/2`: the Berggren tree really does carry a nontrivial `ℤ/2` grading
(the `A`/`B` steps are charged, the `C` step is neutral). -/
theorem charge_surjective :
    charge (g₁ : Matrix (Fin 2) (Fin 2) ℤ) = 1 ∧ charge (g₃ : Matrix (Fin 2) (Fin 2) ℤ) = 0 := by
  have hJ : Jm ≠ 1 := by decide
  constructor
  · simp [charge, show redHom (g₁ : Matrix (Fin 2) (Fin 2) ℤ) = Jm from by
      simpa [g₁] using red_U₁, hJ]
  · simp [charge, show redHom (g₃ : Matrix (Fin 2) (Fin 2) ℤ) = 1 from by
      simpa [g₃] using red_U₃]

/-! ## The braid generators of `SL(2,ℤ)` are not Berggren elements -/

/-- `T = !![1,1;0,1]`, the image of the first Artin generator under `B₃ ↠ SL(2,ℤ)`. -/
def Tmat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-- `L = !![1,0;-1,1]`, the image of the second Artin generator under `B₃ ↠ SL(2,ℤ)`. -/
def Lmat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; -1, 1]

/-- `T` and `L` really do braid: they generate the classical `B₃`-representation. -/
theorem T_L_braid : Tmat * Lmat * Tmat = Lmat * Tmat * Lmat := by decide

/-- `T` as a unit of the matrix ring. -/
def gT : (Matrix (Fin 2) (Fin 2) ℤ)ˣ := ⟨Tmat, !![1, -1; 0, 1], by decide, by decide⟩

/-- `L` as a unit of the matrix ring. -/
def gL : (Matrix (Fin 2) (Fin 2) ℤ)ˣ := ⟨Lmat, !![1, 0; 1, 1], by decide, by decide⟩

theorem red_T : redHom Tmat = !![1, 1; 0, 1] := by
  simp only [redHom, Tmat, RingHom.mapMatrix_apply]; decide

theorem red_L : redHom Lmat = !![1, 0; 1, 1] := by
  simp only [redHom, Lmat, RingHom.mapMatrix_apply]; decide

/-- **The braid generators are not Berggren elements.**  Neither of the two standard braid
generators of `SL(2, ℤ)` lies in the Berggren group; the obstruction is the mod `2`
congruence condition. -/
theorem braid_generators_not_berggren : gT ∉ berggrenGroup ∧ gL ∉ berggrenGroup := by
  constructor
  · intro h
    rcases berggren_mod_two gT h with h' | h' <;>
      · rw [show ((gT : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ) = Tmat from rfl,
          red_T] at h'
        revert h'; decide
  · intro h
    rcases berggren_mod_two gL h with h' | h' <;>
      · rw [show ((gL : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ) = Lmat from rfl,
          red_L] at h'
        revert h'; decide

/-- The Berggren group is a proper subgroup of `GL(2, ℤ)`. -/
theorem berggrenGroup_ne_top : berggrenGroup ≠ ⊤ := by
  intro h
  exact braid_generators_not_berggren.1 (h ▸ Subgroup.mem_top gT)

end BerggrenTQC