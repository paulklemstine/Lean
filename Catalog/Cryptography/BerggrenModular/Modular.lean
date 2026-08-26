import Cryptography.BerggrenModular.Core

/-!
# Berggren moves on `(ℤ/m)³`

We push the Berggren moves through the reduction map `ℤ³ → (ℤ/m)³` and study
what survives.

## Main results

* `redTri_applyMove`, `redTri_applyWord` — reduction is equivariant: the modular
  dynamics is a genuine quotient of the integer dynamics.
* `applyMoveM_bijective` — every modular move is a bijection of `(ℤ/m)³`
  (the state map itself loses nothing; all loss comes from wrap-around).
* `lorentzM_applyMoveM` — the Lorentz form `a²+b²−c²` is still invariant mod `m`.
* `whichMoveMod_redTri` — **the classifier remains sound modulo `m`**: as long as
  the observed state has not wrapped around (`hypotenuse < m`), the canonical
  lift of the residue is the true state and `whichMove` returns the true last move.
* `whichMoveMod_not_sound_mod_seven` — and this hypothesis is sharp: an explicit
  failure at `m = 7`.
* `vecOfM_iterate_applyMoveM` — iterating the move `B₂` mod `m` is exactly
  multiplication by the matrix power `B₂^t` over `ℤ/m`, which is what makes the
  seed-recovery problem for `B₂`-only words a discrete-logarithm problem.
-/

namespace Cryptography
namespace BerggrenModular

/-- A state of the Berggren system reduced modulo `m`. -/
abbrev TriM (m : ℕ) := ZMod m × ZMod m × ZMod m

/-- The Berggren moves acting on `(ℤ/m)³`. -/
def applyMoveM (m : ℕ) (i : Move) (w : TriM m) : TriM m :=
  match i with
  | .m1 => (w.1 - 2 * w.2.1 + 2 * w.2.2, 2 * w.1 - w.2.1 + 2 * w.2.2,
            2 * w.1 - 2 * w.2.1 + 3 * w.2.2)
  | .m2 => (w.1 + 2 * w.2.1 + 2 * w.2.2, 2 * w.1 + w.2.1 + 2 * w.2.2,
            2 * w.1 + 2 * w.2.1 + 3 * w.2.2)
  | .m3 => (-w.1 + 2 * w.2.1 + 2 * w.2.2, -2 * w.1 + w.2.1 + 2 * w.2.2,
            -2 * w.1 + 2 * w.2.1 + 3 * w.2.2)

/-- The inverse Berggren moves acting on `(ℤ/m)³`. -/
def invMoveM (m : ℕ) (i : Move) (w : TriM m) : TriM m :=
  match i with
  | .m1 => (w.1 + 2 * w.2.1 - 2 * w.2.2, -2 * w.1 - w.2.1 + 2 * w.2.2,
            -2 * w.1 - 2 * w.2.1 + 3 * w.2.2)
  | .m2 => (w.1 + 2 * w.2.1 - 2 * w.2.2, 2 * w.1 + w.2.1 - 2 * w.2.2,
            -2 * w.1 - 2 * w.2.1 + 3 * w.2.2)
  | .m3 => (-w.1 - 2 * w.2.1 + 2 * w.2.2, 2 * w.1 + w.2.1 - 2 * w.2.2,
            -2 * w.1 - 2 * w.2.1 + 3 * w.2.2)

theorem invMoveM_applyMoveM (m : ℕ) (i : Move) (w : TriM m) :
    invMoveM m i (applyMoveM m i w) = w := by
  cases i <;> simp only [invMoveM, applyMoveM] <;> ext <;> ring

theorem applyMoveM_invMoveM (m : ℕ) (i : Move) (w : TriM m) :
    applyMoveM m i (invMoveM m i w) = w := by
  cases i <;> simp only [invMoveM, applyMoveM] <;> ext <;> ring

/-- **The modular dynamics is reversible.** -/
theorem applyMoveM_bijective (m : ℕ) (i : Move) : Function.Bijective (applyMoveM m i) :=
  Function.bijective_iff_has_inverse.2
    ⟨invMoveM m i, invMoveM_applyMoveM m i, applyMoveM_invMoveM m i⟩

/-- The Lorentz form modulo `m`. -/
def lorentzM (m : ℕ) (w : TriM m) : ZMod m := w.1 ^ 2 + w.2.1 ^ 2 - w.2.2 ^ 2

/-- The Lorentz form is still an invariant of the modular dynamics. -/
theorem lorentzM_applyMoveM (m : ℕ) (i : Move) (w : TriM m) :
    lorentzM m (applyMoveM m i w) = lorentzM m w := by
  cases i <;> simp only [lorentzM, applyMoveM] <;> ring

/-! ## Reduction is equivariant -/

/-- Reduce an integer state modulo `m`. -/
def redTri (m : ℕ) (v : Tri) : TriM m := ((v.1 : ZMod m), (v.2.1 : ZMod m), (v.2.2 : ZMod m))

theorem redTri_applyMove (m : ℕ) (i : Move) (v : Tri) :
    redTri m (applyMove i v) = applyMoveM m i (redTri m v) := by
  cases i <;> simp only [redTri, applyMove, applyMoveM, Prod.mk.injEq] <;>
    refine ⟨by push_cast; ring, by push_cast; ring, by push_cast; ring⟩

/-- Apply a control word modulo `m`. -/
def applyWordM (m : ℕ) : List Move → TriM m → TriM m
  | [], w => w
  | i :: u, w => applyMoveM m i (applyWordM m u w)

@[simp] theorem applyWordM_nil (m : ℕ) (w : TriM m) : applyWordM m [] w = w := rfl

@[simp] theorem applyWordM_cons (m : ℕ) (i : Move) (u : List Move) (w : TriM m) :
    applyWordM m (i :: u) w = applyMoveM m i (applyWordM m u w) := rfl

/-- **Equivariance.**  Observing the reduction of the integer state is the same as
running the whole dynamical system inside `(ℤ/m)³`. -/
theorem redTri_applyWord (m : ℕ) (u : List Move) (v : Tri) :
    redTri m (applyWord u v) = applyWordM m u (redTri m v) := by
  induction u with
  | nil => rfl
  | cons i rest ih => rw [applyWord_cons, redTri_applyMove, ih, applyWordM_cons]

theorem applyWordM_injective (m : ℕ) (u : List Move) :
    Function.Injective (applyWordM m u) := by
  induction u with
  | nil => exact fun a b h => h
  | cons i rest ih =>
      intro a b h
      exact ih ((applyMoveM_bijective m i).1 h)

/-! ## The classifier modulo `m` -/

/-- The canonical lift of a modular state, using representatives in `[0, m)`. -/
def liftTri (m : ℕ) [NeZero m] (w : TriM m) : Tri :=
  ((w.1.val : ℤ), (w.2.1.val : ℤ), (w.2.2.val : ℤ))

/-- The classifier as an observer of a modular state can only see it: it lifts the
residue canonically and runs the integer test. -/
def whichMoveMod (m : ℕ) [NeZero m] (w : TriM m) : Move := whichMove (liftTri m w)

theorem liftZ_red {m : ℕ} [NeZero m] {a : ℤ} (h0 : 0 ≤ a) (h1 : a < m) :
    (((a : ZMod m).val : ℤ)) = a := by
  rw [ZMod.val_intCast]; exact Int.emod_eq_of_lt h0 h1

/-- Below the modulus the canonical lift undoes the reduction. -/
theorem liftTri_redTri {m : ℕ} [NeZero m] {v : Tri} (h1 : 0 ≤ v.1) (h2 : 0 ≤ v.2.1)
    (h3 : 0 ≤ v.2.2) (b1 : v.1 < m) (b2 : v.2.1 < m) (b3 : v.2.2 < m) :
    liftTri m (redTri m v) = v := by
  simp only [liftTri, redTri]
  refine Prod.ext (liftZ_red h1 b1) (Prod.ext (liftZ_red h2 b2) (liftZ_red h3 b3))

/-- **Soundness of `whichMove` modulo `m`.**  If the observed state has not wrapped
around — i.e. its hypotenuse is smaller than the modulus — then the classifier,
reading only the residue, still returns the true last move.  This is the exact
statement in which "the classifier remains sound mod `m`". -/
theorem whichMoveMod_redTri {m : ℕ} [NeZero m] (i : Move) {v : Tri} (hv : Valid v)
    (hb : (applyMove i v).2.2 < m) :
    whichMoveMod m (redTri m (applyMove i v)) = i := by
  have hc : Valid (applyMove i v) := applyMove_valid hv
  have h1 : (applyMove i v).1 < (applyMove i v).2.2 := valid_leg_lt_hyp₁ hc
  have h2 : (applyMove i v).2.1 < (applyMove i v).2.2 := valid_leg_lt_hyp₂ hc
  have := liftTri_redTri (m := m) (v := applyMove i v) (le_of_lt hc.1) (le_of_lt hc.2.1)
    (le_of_lt hc.2.2.1) (by linarith) (by linarith) hb
  rw [whichMoveMod, this, whichMove_applyMove i hv]

/-- Iterating soundness: as long as the whole trajectory stays below the modulus,
modular seed recovery agrees with integer seed recovery. -/
def recoverMod (m : ℕ) [NeZero m] : ℕ → TriM m → List Move
  | 0, _ => []
  | n + 1, w => whichMoveMod m w :: recoverMod m n (invMoveM m (whichMoveMod m w) w)

/-- **Modular seed recovery is correct below the modulus.**  If every intermediate
state along the word stays below `m`, the modular observer recovers the control
word exactly. -/
theorem recoverMod_applyWordM {m : ℕ} [NeZero m] (u : List Move) {v : Tri} (hv : Valid v)
    (hb : ∀ s : List Move, s <:+ u → (applyWord s v).2.2 < m) :
    recoverMod m u.length (redTri m (applyWord u v)) = u := by
  induction u with
  | nil => rfl
  | cons i rest ih =>
      have hu : Valid (applyWord rest v) := applyWord_valid rest hv
      have hbi : (applyMove i (applyWord rest v)).2.2 < m := hb (i :: rest) (List.suffix_refl _)
      have hstep : whichMoveMod m (redTri m (applyWord (i :: rest) v)) = i := by
        rw [applyWord_cons]; exact whichMoveMod_redTri i hu hbi
      simp only [List.length_cons, recoverMod]
      rw [hstep]
      have hinv : invMoveM m i (redTri m (applyWord (i :: rest) v))
          = redTri m (applyWord rest v) := by
        rw [applyWord_cons, redTri_applyMove, invMoveM_applyMoveM]
      rw [hinv, ih (fun s hs => hb s (hs.trans (List.suffix_cons i rest)))]

/-! ## Sharpness: the classifier fails once the state wraps around -/

/-- With `m = 7` the child `(5,12,13) = B₁ (3,4,5)` reduces to `(5,5,6)`, whose
canonical lift is classified as `B₃`.  So the smallness hypothesis in
`whichMoveMod_redTri` cannot be dropped. -/
theorem whichMoveMod_not_sound_mod_seven :
    whichMoveMod 7 (redTri 7 (applyMove .m1 root)) = Move.m3 := by
  decide

theorem whichMoveMod_fails_mod_seven :
    whichMoveMod 7 (redTri 7 (applyMove .m1 root)) ≠ Move.m1 := by
  rw [whichMoveMod_not_sound_mod_seven]; exact fun h => Move.noConfusion h

/-! ## Matrix form and the `B₂` discrete logarithm -/

/-- The vector attached to a modular state. -/
def vecOfM (m : ℕ) (w : TriM m) : Fin 3 → ZMod m := ![w.1, w.2.1, w.2.2]

/-- The Berggren matrices reduced modulo `m`. -/
def bergMatrixM (m : ℕ) (i : Move) : Matrix (Fin 3) (Fin 3) (ZMod m) :=
  (bergMatrix i).map (Int.cast)

theorem vecOfM_applyMoveM (m : ℕ) (i : Move) (w : TriM m) :
    vecOfM m (applyMoveM m i w) = (bergMatrixM m i).mulVec (vecOfM m w) := by
  cases i <;>
    · funext k
      fin_cases k <;>
        simp [vecOfM, applyMoveM, bergMatrixM, bergMatrix, Matrix.mulVec, dotProduct,
          Fin.sum_univ_three] <;>
        ring

/-- **Iterating a single move is a matrix power.**  Consequently, recovering the
number of `B₂`-steps from an observed modular state is literally a discrete
logarithm problem for the matrix `B₂` in `GL₃(ℤ/m)`. -/
theorem vecOfM_iterate_applyMoveM (m : ℕ) (i : Move) (t : ℕ) (w : TriM m) :
    vecOfM m ((applyMoveM m i)^[t] w) = ((bergMatrixM m i) ^ t).mulVec (vecOfM m w) := by
  induction t generalizing w with
  | zero => simp [Matrix.one_mulVec]
  | succ n ih =>
      rw [Function.iterate_succ_apply, ih, vecOfM_applyMoveM, pow_succ']
      rw [Matrix.mulVec_mulVec]
      have hcomm : bergMatrixM m i ^ n * bergMatrixM m i
          = bergMatrixM m i * bergMatrixM m i ^ n := by
        rw [← pow_succ, ← pow_succ']
      rw [hcomm]

/-- A word consisting of `t` copies of the move `i` is the `t`-fold iterate. -/
theorem applyWordM_replicate (m : ℕ) (i : Move) (t : ℕ) (w : TriM m) :
    applyWordM m (List.replicate t i) w = (applyMoveM m i)^[t] w := by
  induction t generalizing w with
  | zero => rfl
  | succ n ih =>
      rw [List.replicate_succ, applyWordM_cons, ih]
      exact (Function.iterate_succ_apply' _ _ _).symm

end BerggrenModular
end Cryptography