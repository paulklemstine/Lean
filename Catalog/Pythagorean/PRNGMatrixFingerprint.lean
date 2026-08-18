import Mathlib
import Pythagorean.PRNGBerggrenSeedCode

/-!
# Cycle 2: every 3×3 integer generator is an order-3 LFSR, and the order is sharp

The first three files established that each single Barning–Berggren move produces
order-3 linearly recurrent data.  Two questions are left open by that analysis:

1. *Is the phenomenon special to the three moves?*  No — it is Cayley–Hamilton.
   `readout_charpoly` and `satisfiesLFSR_matVec` prove that for **any** integer
   `3 × 3` matrix `M`, every linear readout of every orbit of `M` satisfies the
   order-3 recurrence whose taps are the coefficients of the characteristic
   polynomial, `y(t+3) = tr(M)·y(t+2) - c₂(M)·y(t+1) + det(M)·y(t)`.
   In particular a generator driven by a *periodic control word* (e.g. `ABAB…`)
   is still order-3 detectable: `satisfiesLFSR_wordOrbit`.

2. *Is order 3 the true linear complexity, or an artefact?*  It is sharp on the
   unipotent branches and **not** sharp on the `B`-branch:
   `hypA_not_order_two` shows the `A`-branch hypotenuse stream satisfies no order-2
   recurrence, while `bergB_hypotenuse_pell` gives an order-2 recurrence on the
   `B`-branch and `hypB_not_order_one` shows *that* is sharp.  So the **linear
   complexity of the hypotenuse stream is itself a branch classifier**: 3 for the
   unipotent branches `A`, `C` and 2 for `B`.

Main contents.

* `c2`, `readout_charpoly` — the characteristic relation for `3 × 3` matrices,
  in readout form.
* `satisfiesLFSR_matVec` — the general fingerprint theorem.
* `stepMat`, `toVec`, `applyStep_matVec`, `applyWord_matVec` — the Berggren moves
  and arbitrary control words as matrices.
* `satisfiesLFSR_wordOrbit` — composite (periodically seeded) generators are
  order-3 detectable too.
* `hypA_not_order_two`, `hypC_not_order_two`, `hypB_not_order_one` — sharpness.
* `linear_complexity_separates_branches` — the complexity-based classifier.
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid Matrix

/-! ## The characteristic relation of a 3×3 matrix -/

/-- The second elementary symmetric function of the eigenvalues: the sum of the
principal `2 × 2` minors.  Together with the trace and the determinant it makes
up the characteristic polynomial `λ³ - tr·λ² + c₂·λ - det`. -/
def c2 (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ :=
  (M 0 0 * M 1 1 - M 0 1 * M 1 0) + (M 0 0 * M 2 2 - M 0 2 * M 2 0) +
    (M 1 1 * M 2 2 - M 1 2 * M 2 1)

/-- **Cayley–Hamilton in readout form.**  For any linear observation `u` of any
state `w`, three applications of `M` are a fixed integer combination of fewer
applications.  This is the mechanism behind every order-3 fingerprint in this
development. -/
theorem readout_charpoly (M : Matrix (Fin 3) (Fin 3) ℤ) (u w : Fin 3 → ℤ) :
    u ⬝ᵥ M.mulVec (M.mulVec (M.mulVec w)) =
      M.trace * (u ⬝ᵥ M.mulVec (M.mulVec w)) - c2 M * (u ⬝ᵥ M.mulVec w) +
        M.det * (u ⬝ᵥ w) := by
  simp only [dotProduct, mulVec, Fin.sum_univ_three, Matrix.trace_fin_three,
    Matrix.det_fin_three, c2]
  ring

/-- **General fingerprint theorem.**  Every linear readout of every orbit of an
integer `3 × 3` matrix is an order-3 LFSR stream, with taps read off the
characteristic polynomial. -/
theorem satisfiesLFSR_matVec (M : Matrix (Fin 3) (Fin 3) ℤ) (u v : Fin 3 → ℤ) :
    SatisfiesLFSR ![M.det, -c2 M, M.trace] (fun t => u ⬝ᵥ (M.mulVec)^[t] v) := by
  intro t
  have e1 : (M.mulVec)^[t + 1] v = M.mulVec ((M.mulVec)^[t] v) := by
    rw [Function.iterate_succ_apply']
  have e2 : (M.mulVec)^[t + 2] v = M.mulVec (M.mulVec ((M.mulVec)^[t] v)) := by
    rw [show t + 2 = (t + 1) + 1 from rfl, Function.iterate_succ_apply', e1]
  have e3 : (M.mulVec)^[t + 3] v = M.mulVec (M.mulVec (M.mulVec ((M.mulVec)^[t] v))) := by
    rw [show t + 3 = (t + 2) + 1 from rfl, Function.iterate_succ_apply', e2]
  simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Fin.val_zero, Fin.val_one, Fin.val_two, Nat.add_zero]
  rw [e1, e2, e3, readout_charpoly M u ((M.mulVec)^[t] v)]
  ring

/-! ## The Berggren moves as matrices -/

/-- A triple as a column vector. -/
def toVec (p : ℤ × ℤ × ℤ) : Fin 3 → ℤ := ![p.1, p.2.1, p.2.2]

/-- The Barning matrix of a control symbol. -/
def stepMat : BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
  | .A => B₁_mat
  | .B => B₂_mat
  | .C => B₃_mat

theorem applyStep_matVec (s : BerggrenStep) (p : ℤ × ℤ × ℤ) :
    toVec (applyStep s p) = (stepMat s).mulVec (toVec p) := by
  obtain ⟨a, b, c⟩ := p
  cases s <;> funext i <;> fin_cases i <;>
    simp [toVec, stepMat, applyStep, bergA, bergB, bergC, B₁_mat, B₂_mat, B₃_mat,
      mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- Running a whole control word from a given state. -/
def applyWordFrom (w : List BerggrenStep) (p : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  w.foldl (fun q s => applyStep s q) p

@[simp] theorem applyWordFrom_nil (p : ℤ × ℤ × ℤ) : applyWordFrom [] p = p := rfl

theorem applyWordFrom_cons (s : BerggrenStep) (w : List BerggrenStep) (p : ℤ × ℤ × ℤ) :
    applyWordFrom (s :: w) p = applyWordFrom w (applyStep s p) := rfl

/-- The matrix of a control word. -/
def wordMat : List BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | s :: w => wordMat w * stepMat s

theorem applyWord_matVec (w : List BerggrenStep) (p : ℤ × ℤ × ℤ) :
    toVec (applyWordFrom w p) = (wordMat w).mulVec (toVec p) := by
  induction w generalizing p with
  | nil => simp [wordMat]
  | cons s w ih =>
      rw [applyWordFrom_cons, ih (applyStep s p), applyStep_matVec, wordMat,
        Matrix.mulVec_mulVec]

/-- **Composite generators stay detectable.**  Driving the tree with a fixed
control word `w` repeated over and over is again an order-3 linearly recurrent
source: repetition of a seed pattern does not defeat the fingerprint. -/
theorem satisfiesLFSR_wordOrbit (w : List BerggrenStep) (u : Fin 3 → ℤ) (p : ℤ × ℤ × ℤ) :
    SatisfiesLFSR ![(wordMat w).det, -c2 (wordMat w), (wordMat w).trace]
      (fun t => u ⬝ᵥ toVec ((applyWordFrom w)^[t] p)) := by
  have key : ∀ t : ℕ, toVec ((applyWordFrom w)^[t] p) = ((wordMat w).mulVec)^[t] (toVec p) := by
    intro t
    induction t with
    | zero => simp
    | succ t ih =>
        rw [Function.iterate_succ_apply', Function.iterate_succ_apply', applyWord_matVec, ih]
  simpa only [key] using satisfiesLFSR_matVec (wordMat w) u (toVec p)

/-- Consistency check: the single-move taps computed in
`Pythagorean.PRNGBerggrenFingerprint` are exactly the characteristic data of the
Barning matrices. -/
theorem berg_taps_from_charpoly :
    (B₁_mat.det, -c2 B₁_mat, B₁_mat.trace) = ((1 : ℤ), -3, 3) ∧
    (B₂_mat.det, -c2 B₂_mat, B₂_mat.trace) = ((-1 : ℤ), 5, 5) ∧
    (B₃_mat.det, -c2 B₃_mat, B₃_mat.trace) = ((1 : ℤ), -3, 3) := by
  refine ⟨?_, ?_, ?_⟩ <;>
    simp [B₁_mat, B₂_mat, B₃_mat, c2, Matrix.det_fin_three, Matrix.trace_fin_three]

/-! ## Sharpness: the true linear complexity of the branch streams -/

/-- The hypotenuse stream of the `A`-branch from the root is `2t² + 6t + 5`. -/
theorem hypA_values (t : ℕ) : (moveA^[t] (3, 4, 5)).2.2 = 2 * (t : ℤ) ^ 2 + 6 * t + 5 := by
  rw [orbitA_root_closed_form]

/-- The hypotenuse stream of the `C`-branch from the root is `4t² + 8t + 5`. -/
theorem hypC_values (t : ℕ) : (moveC^[t] (3, 4, 5)).2.2 = 4 * (t : ℤ) ^ 2 + 8 * t + 5 := by
  rw [orbitC_root_closed_form]

/-- **Sharpness on the `A`-branch.**  No order-2 linear recurrence generates the
`A`-branch hypotenuse stream: its linear complexity is exactly `3`. -/
theorem hypA_not_order_two (c₀ c₁ : ℤ) :
    ¬ ∀ t : ℕ, (moveA^[t + 2] (3, 4, 5)).2.2 =
        c₀ * (moveA^[t] (3, 4, 5)).2.2 + c₁ * (moveA^[t + 1] (3, 4, 5)).2.2 := by
  intro h
  have h0 := h 0
  have h1 := h 1
  have h2 := h 2
  rw [hypA_values, hypA_values, hypA_values] at h0 h1 h2
  norm_num at h0 h1 h2
  omega

/-- **Sharpness on the `C`-branch.** -/
theorem hypC_not_order_two (c₀ c₁ : ℤ) :
    ¬ ∀ t : ℕ, (moveC^[t + 2] (3, 4, 5)).2.2 =
        c₀ * (moveC^[t] (3, 4, 5)).2.2 + c₁ * (moveC^[t + 1] (3, 4, 5)).2.2 := by
  intro h
  have h0 := h 0
  have h1 := h 1
  have h2 := h 2
  rw [hypC_values, hypC_values, hypC_values] at h0 h1 h2
  norm_num at h0 h1 h2
  omega

theorem hypB_zero : (moveB^[0] (3, 4, 5)).2.2 = 5 := rfl

theorem hypB_one : (moveB^[1] (3, 4, 5)).2.2 = 29 := by
  norm_num [Function.iterate_one, moveB, bergB]

/-- **Sharpness on the `B`-branch.**  The `B`-branch hypotenuse *does* satisfy the
order-2 Pell recurrence (`bergB_hypotenuse_pell`), and no order-1 recurrence: its
linear complexity is exactly `2`. -/
theorem hypB_not_order_one (c₀ : ℤ) :
    ¬ ∀ t : ℕ, (moveB^[t + 1] (3, 4, 5)).2.2 = c₀ * (moveB^[t] (3, 4, 5)).2.2 := by
  intro h
  have h0 := h 0
  rw [hypB_zero] at h0
  rw [show (0 : ℕ) + 1 = 1 from rfl, hypB_one] at h0
  omega

/-- **A complexity-based classifier.**  The `B`-branch hypotenuse stream obeys an
order-2 recurrence; the `A`-branch one does not.  Hence measuring the linear
complexity of a single observed coordinate already separates the exponential
(Pell) branch from the unipotent branches — no seed search required. -/
theorem linear_complexity_separates_branches :
    (∃ c₀ c₁ : ℤ, ∀ t : ℕ, (moveB^[t + 2] (3, 4, 5)).2.2 =
        c₀ * (moveB^[t] (3, 4, 5)).2.2 + c₁ * (moveB^[t + 1] (3, 4, 5)).2.2) ∧
    ¬ ∃ c₀ c₁ : ℤ, ∀ t : ℕ, (moveA^[t + 2] (3, 4, 5)).2.2 =
        c₀ * (moveA^[t] (3, 4, 5)).2.2 + c₁ * (moveA^[t + 1] (3, 4, 5)).2.2 := by
  constructor
  · refine ⟨-1, 6, fun t => ?_⟩
    have := bergB_hypotenuse_pell (3, 4, 5) t
    rw [this]
    ring
  · rintro ⟨c₀, c₁, h⟩
    exact hypA_not_order_two c₀ c₁ h

end Catalog.Pythagorean.BerggrenPRNG