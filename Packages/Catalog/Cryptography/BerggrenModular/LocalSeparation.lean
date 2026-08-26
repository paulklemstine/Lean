import Cryptography.BerggrenModular.SilverOrbit

/-!
# Local separation of the three moves modulo `m`

`Cryptography.BerggrenModular.Modular` shows that the *absolute* classifier — the
one that sees only the child state — stays sound modulo `m` exactly while the
state has not wrapped around.  Here we analyse the **relative** classifier, which
sees the parent as well.  It is sound modulo `m` precisely when the three children
of the parent are pairwise distinct, and we compute exactly when that happens:

```
B₁w − B₂w = (−4b, −2b, −4b),
B₂w − B₃w = ( 2a,  4a,  4a),
B₁w − B₃w = (2a − 4b, 4a − 2b, 4a − 4b).
```

So the branching is visible modulo `m` iff `2a`, `2b` and `2a − 4b` are nonzero in
`ℤ/m`.  Two consequences are worth isolating:

* `whichMoveRel_sound` — the relative classifier is sound (and complete) under
  exactly those three nondegeneracy conditions;
* `applyMoveM_two_eq_id` — modulo `2` all three Berggren moves are the identity,
  so the dynamics collapses completely and no classifier of any kind can work.
  This is the extreme case of the information loss quantified in
  `Cryptography.BerggrenModular.Hardness`.
-/

namespace Cryptography
namespace BerggrenModular

variable {m : ℕ}

/-! ## The three difference vectors -/

theorem child_diff_12 (w : TriM m) :
    applyMoveM m Move.m1 w - applyMoveM m Move.m2 w
      = (-4 * w.2.1, -2 * w.2.1, -4 * w.2.1) := by
  simp only [applyMoveM, Prod.mk_sub_mk, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem child_diff_23 (w : TriM m) :
    applyMoveM m Move.m2 w - applyMoveM m Move.m3 w = (2 * w.1, 4 * w.1, 4 * w.1) := by
  simp only [applyMoveM, Prod.mk_sub_mk, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem child_diff_13 (w : TriM m) :
    applyMoveM m Move.m1 w - applyMoveM m Move.m3 w
      = (2 * w.1 - 4 * w.2.1, 4 * w.1 - 2 * w.2.1, 4 * w.1 - 4 * w.2.1) := by
  simp only [applyMoveM, Prod.mk_sub_mk, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-! ## Pairwise distinctness of the children -/

theorem child_m1_ne_m2 {w : TriM m} (h : (2 : ZMod m) * w.2.1 ≠ 0) :
    applyMoveM m Move.m1 w ≠ applyMoveM m Move.m2 w := by
  intro hEq
  apply h
  have := congrArg (fun x : TriM m => x.2.1) hEq
  simp only [applyMoveM] at this
  linear_combination -this

theorem child_m2_ne_m3 {w : TriM m} (h : (2 : ZMod m) * w.1 ≠ 0) :
    applyMoveM m Move.m2 w ≠ applyMoveM m Move.m3 w := by
  intro hEq
  apply h
  have := congrArg (fun x : TriM m => x.1) hEq
  simp only [applyMoveM] at this
  linear_combination this

theorem child_m1_ne_m3 {w : TriM m} (h : (2 : ZMod m) * w.1 - 4 * w.2.1 ≠ 0) :
    applyMoveM m Move.m1 w ≠ applyMoveM m Move.m3 w := by
  intro hEq
  apply h
  have := congrArg (fun x : TriM m => x.1) hEq
  simp only [applyMoveM] at this
  linear_combination this

/-- A modular state whose three children are pairwise distinguishable. -/
def Separated (w : TriM m) : Prop :=
  (2 : ZMod m) * w.1 ≠ 0 ∧ (2 : ZMod m) * w.2.1 ≠ 0 ∧ (2 : ZMod m) * w.1 - 4 * w.2.1 ≠ 0

theorem applyMoveM_injective_of_separated {w : TriM m} (hw : Separated w) {i j : Move}
    (h : applyMoveM m i w = applyMoveM m j w) : i = j := by
  obtain ⟨h1, h2, h3⟩ := hw
  cases i <;> cases j <;> first
    | rfl
    | exact absurd h (child_m1_ne_m2 h2)
    | exact absurd h.symm (child_m1_ne_m2 h2)
    | exact absurd h (child_m2_ne_m3 h1)
    | exact absurd h.symm (child_m2_ne_m3 h1)
    | exact absurd h (child_m1_ne_m3 h3)
    | exact absurd h.symm (child_m1_ne_m3 h3)

/-! ## The relative classifier -/

/-- The relative classifier: given the parent `w` and the observed child `x`, name
the move.  Purely algebraic — no order, no lifting. -/
def whichMoveRel (m : ℕ) (w x : TriM m) : Option Move :=
  if x = applyMoveM m Move.m1 w then some Move.m1
  else if x = applyMoveM m Move.m2 w then some Move.m2
  else if x = applyMoveM m Move.m3 w then some Move.m3
  else none

/-- **The relative classifier is sound and complete modulo `m`** on separated states. -/
theorem whichMoveRel_sound {w : TriM m} (hw : Separated w) (i : Move) :
    whichMoveRel m w (applyMoveM m i w) = some i := by
  cases i
  · simp [whichMoveRel]
  · rw [whichMoveRel, if_neg (fun h => child_m1_ne_m2 hw.2.1 h.symm), if_pos rfl]
  · rw [whichMoveRel, if_neg (fun h => child_m1_ne_m3 hw.2.2 h.symm),
      if_neg (fun h => child_m2_ne_m3 hw.1 h.symm), if_pos rfl]

/-- Conversely, if the classifier names a move then that move was played. -/
theorem whichMoveRel_eq_some {w x : TriM m} {i : Move} (h : whichMoveRel m w x = some i) :
    x = applyMoveM m i w := by
  unfold whichMoveRel at h
  split at h
  · rename_i hx; cases h; exact hx
  · split at h
    · rename_i hx; cases h; exact hx
    · split at h
      · rename_i hx; cases h; exact hx
      · exact absurd h (by simp)

/-! ## The degenerate modulus -/

/-- **Modulo `2` the Berggren dynamics collapses**: every move acts as the identity
on `(ℤ/2)³`, so the observed state carries no information whatsoever about the
control word. -/
theorem applyMoveM_two_eq_id (i : Move) (w : TriM 2) : applyMoveM 2 i w = w := by
  cases i <;> revert w <;> decide

/-- Modulo `2` no state is separated. -/
theorem not_separated_two (w : TriM 2) : ¬ Separated w := by
  rintro ⟨h1, -, -⟩
  exact h1 (by rw [show (2 : ZMod 2) = 0 from rfl, zero_mul])

/-- Consequently every control word yields the same observation modulo `2`. -/
theorem stateMod_two_constant (u : List Move) : stateMod 2 u = redTri 2 root := by
  induction u with
  | nil => rfl
  | cons i rest ih =>
      show redTri 2 (applyWord (i :: rest) root) = redTri 2 root
      rw [applyWord_cons, redTri_applyMove]
      show applyMoveM 2 i (redTri 2 (applyWord rest root)) = redTri 2 root
      rw [applyMoveM_two_eq_id]
      exact ih

/-- Hence modulo `2` seed recovery is impossible for every `k ≥ 1`. -/
theorem not_modSeedRecoverable_two {k : ℕ} (hk : 1 ≤ k) : ¬ ModSeedRecoverable 2 k := by
  refine not_modSeedRecoverable_of_collision (u := []) (w := [Move.m1]) (by simp)
    (by simpa using hk) (by simp) ?_
  rw [stateMod_two_constant, stateMod_two_constant]

end BerggrenModular
end Cryptography