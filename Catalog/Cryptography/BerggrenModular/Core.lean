import Mathlib

/-!
# Berggren moves over `ℤ`: the exact move classifier and free-monoid seed recovery

This file is the integer-side foundation for the modular study carried out in
`Cryptography.BerggrenModular.Modular` and
`Cryptography.BerggrenModular.Hardness`.

The three Berggren (Barning–Hall) moves `B₁, B₂, B₃` act on integer triples and
preserve the Lorentz form `a² + b² − c²`; on the cone of positive Pythagorean
triples they generate a ternary tree rooted at `(3,4,5)`.

The central object here is an **exact, purely linear classifier**

```
whichMove (a,b,c) = if 5a < 3c then B₁ else if 5a < 4c then B₂ else B₃
```

which reads off, from a single child state, *which* move produced it.  The
thresholds `3/5` and `4/5` are the images of the ratio tests `m < 2n`,
`2n < m < 3n`, `m > 3n` in the Euclid parametrisation `a = m²−n²`, `b = 2mn`,
`c = m²+n²`, transported through `m/n = √((c+a)/(c−a))`.

## Main results

* `whichMove_applyMove` — soundness *and* completeness of the classifier over `ℤ`.
* `applyMove_valid` — the positive Pythagorean cone is invariant.
* `invMove_applyMove` — each move is inverted by an explicit integer matrix.
* `recover_applyWord` — a **linear-time seed-recovery algorithm** over `ℤ`:
  the control word is recovered exactly from a single observed state.
* `applyWord_injective` — the Berggren monoid acts freely on the cone
  (so the length-`k` search space really has `3^k` distinct states).
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Moves -/

/-- The three Berggren moves. -/
inductive Move : Type
  | m1 | m2 | m3
  deriving DecidableEq, Repr, Fintype

/-- There are exactly three moves: the branching degree of the Berggren tree. -/
theorem card_move : Fintype.card Move = 3 := rfl

/-- An integer triple. -/
abbrev Tri := ℤ × ℤ × ℤ

/-- The Berggren move `B₁`, `B₂`, `B₃` acting on integer triples. -/
def applyMove (i : Move) (v : Tri) : Tri :=
  match i with
  | .m1 => (v.1 - 2 * v.2.1 + 2 * v.2.2, 2 * v.1 - v.2.1 + 2 * v.2.2,
            2 * v.1 - 2 * v.2.1 + 3 * v.2.2)
  | .m2 => (v.1 + 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 + 2 * v.2.2,
            2 * v.1 + 2 * v.2.1 + 3 * v.2.2)
  | .m3 => (-v.1 + 2 * v.2.1 + 2 * v.2.2, -2 * v.1 + v.2.1 + 2 * v.2.2,
            -2 * v.1 + 2 * v.2.1 + 3 * v.2.2)

/-- The inverse Berggren moves `Bᵢ⁻¹ = Q Bᵢᵀ Q` with `Q = diag(1,1,-1)`. -/
def invMove (i : Move) (v : Tri) : Tri :=
  match i with
  | .m1 => (v.1 + 2 * v.2.1 - 2 * v.2.2, -2 * v.1 - v.2.1 + 2 * v.2.2,
            -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)
  | .m2 => (v.1 + 2 * v.2.1 - 2 * v.2.2, 2 * v.1 + v.2.1 - 2 * v.2.2,
            -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)
  | .m3 => (-v.1 - 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 - 2 * v.2.2,
            -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- The Lorentz form of signature `(2,1)`. -/
def lorentz (v : Tri) : ℤ := v.1 ^ 2 + v.2.1 ^ 2 - v.2.2 ^ 2

/-- Every Berggren move is an isometry of the Lorentz form. -/
theorem lorentz_applyMove (i : Move) (v : Tri) : lorentz (applyMove i v) = lorentz v := by
  cases i <;> simp only [lorentz, applyMove] <;> ring

/-- Every inverse Berggren move is an isometry of the Lorentz form. -/
theorem lorentz_invMove (i : Move) (v : Tri) : lorentz (invMove i v) = lorentz v := by
  cases i <;> simp only [lorentz, invMove] <;> ring

/-- `invMove i` is a left inverse of `applyMove i`. -/
theorem invMove_applyMove (i : Move) (v : Tri) : invMove i (applyMove i v) = v := by
  cases i <;> simp only [invMove, applyMove] <;> ext <;> ring

/-- `invMove i` is a right inverse of `applyMove i`. -/
theorem applyMove_invMove (i : Move) (v : Tri) : applyMove i (invMove i v) = v := by
  cases i <;> simp only [invMove, applyMove] <;> ext <;> ring

theorem applyMove_injective (i : Move) : Function.Injective (applyMove i) := by
  intro u v h
  have := congrArg (invMove i) h
  rwa [invMove_applyMove, invMove_applyMove] at this

/-! ## The positive Pythagorean cone -/

/-- A *valid* state: a strictly positive Pythagorean triple. -/
def Valid (v : Tri) : Prop :=
  0 < v.1 ∧ 0 < v.2.1 ∧ 0 < v.2.2 ∧ v.1 ^ 2 + v.2.1 ^ 2 = v.2.2 ^ 2

theorem valid_leg_lt_hyp₁ {v : Tri} (h : Valid v) : v.1 < v.2.2 := by
  obtain ⟨ha, hb, hc, hp⟩ := h; nlinarith

theorem valid_leg_lt_hyp₂ {v : Tri} (h : Valid v) : v.2.1 < v.2.2 := by
  obtain ⟨ha, hb, hc, hp⟩ := h; nlinarith

/-- Strict triangle inequality: a positive Pythagorean triple is non-degenerate. -/
theorem valid_hyp_lt_sum {v : Tri} (h : Valid v) : v.2.2 < v.1 + v.2.1 := by
  obtain ⟨ha, hb, hc, hp⟩ := h; nlinarith

/-- The cone of positive Pythagorean triples is invariant under every move. -/
theorem applyMove_valid {i : Move} {v : Tri} (h : Valid v) : Valid (applyMove i v) := by
  have h1 := valid_leg_lt_hyp₁ h
  have h2 := valid_leg_lt_hyp₂ h
  obtain ⟨ha, hb, hc, hp⟩ := h
  cases i <;>
    refine ⟨by simp only [applyMove]; linarith, by simp only [applyMove]; linarith,
      by simp only [applyMove]; linarith, ?_⟩ <;>
    simp only [applyMove] <;> linear_combination hp

/-- Each move strictly increases the hypotenuse: the tree is graded. -/
theorem hyp_lt_applyMove {i : Move} {v : Tri} (h : Valid v) :
    v.2.2 < (applyMove i v).2.2 := by
  have h1 := valid_leg_lt_hyp₁ h
  have h2 := valid_leg_lt_hyp₂ h
  obtain ⟨ha, hb, hc, hp⟩ := h
  cases i <;> simp only [applyMove] <;> linarith

/-! ## The exact linear classifier -/

/-- **The Berggren move classifier.**  Given a child state `(a,b,c)` it returns the
unique move that produced it.  The test is purely linear in the state. -/
def whichMove (v : Tri) : Move :=
  if 5 * v.1 < 3 * v.2.2 then .m1 else if 5 * v.1 < 4 * v.2.2 then .m2 else .m3

/-- **Soundness and completeness of `whichMove` over `ℤ`.**  For every valid state `v`
and every move `i`, the classifier applied to the child `applyMove i v` returns
exactly `i`. -/
theorem whichMove_applyMove (i : Move) {v : Tri} (h : Valid v) :
    whichMove (applyMove i v) = i := by
  have h1 := valid_leg_lt_hyp₁ h
  have h2 := valid_leg_lt_hyp₂ h
  have h3 := valid_hyp_lt_sum h
  obtain ⟨ha, hb, hc, hp⟩ := h
  cases i <;> simp only [whichMove, applyMove]
  · rw [if_pos (by linarith)]
  · rw [if_neg (by linarith), if_pos (by linarith)]
  · rw [if_neg (by linarith), if_neg (by linarith)]

/-- Distinct moves send a valid state to distinct children: the classifier is
injective on the fibre over any valid parent. -/
theorem applyMove_ne_of_ne {i j : Move} {v : Tri} (h : Valid v) (hij : i ≠ j) :
    applyMove i v ≠ applyMove j v := by
  intro hEq
  exact hij (by rw [← whichMove_applyMove i h, ← whichMove_applyMove j h, hEq])

/-! ## Words, orbits and seed recovery -/

/-- Apply a control word.  The head of the list is the **last** move applied. -/
def applyWord : List Move → Tri → Tri
  | [], v => v
  | i :: w, v => applyMove i (applyWord w v)

@[simp] theorem applyWord_nil (v : Tri) : applyWord [] v = v := rfl

@[simp] theorem applyWord_cons (i : Move) (w : List Move) (v : Tri) :
    applyWord (i :: w) v = applyMove i (applyWord w v) := rfl

theorem applyWord_valid (w : List Move) {v : Tri} (h : Valid v) : Valid (applyWord w v) := by
  induction w with
  | nil => exact h
  | cons i rest ih => exact applyMove_valid ih

theorem applyWord_append (u w : List Move) (v : Tri) :
    applyWord (u ++ w) v = applyWord u (applyWord w v) := by
  induction u with
  | nil => rfl
  | cons i rest ih => simp [ih]

/-- The hypotenuse never decreases along a word. -/
theorem hyp_le_applyWord (w : List Move) {v : Tri} (h : Valid v) :
    v.2.2 ≤ (applyWord w v).2.2 := by
  induction w with
  | nil => exact le_rfl
  | cons i rest ih =>
      exact ih.trans (le_of_lt (hyp_lt_applyMove (applyWord_valid rest h)))

/-- **Seed recovery over `ℤ`.**  Peel off `n` moves, each step costing one
comparison and one linear map. -/
def recover : ℕ → Tri → List Move
  | 0, _ => []
  | n + 1, v => whichMove v :: recover n (invMove (whichMove v) v)

/-- **Correctness of integer seed recovery.**  From the single observed state
`applyWord w v` (and the length of `w`) the whole control word is reconstructed. -/
theorem recover_applyWord (w : List Move) {v : Tri} (h : Valid v) :
    recover w.length (applyWord w v) = w := by
  induction w with
  | nil => rfl
  | cons i rest ih =>
      have hu : Valid (applyWord rest v) := applyWord_valid rest h
      simp only [List.length_cons, recover, applyWord_cons]
      rw [whichMove_applyMove i hu, invMove_applyMove, ih]

/-- **Freeness of the Berggren action on the cone.**  Distinct control words give
distinct states, so the length-`k` state space really has `3^k` points. -/
theorem applyWord_injective {v : Tri} (h : Valid v) :
    Function.Injective (fun w : List Move => applyWord w v) := by
  intro u
  induction u with
  | nil =>
      intro w hw
      match w with
      | [] => rfl
      | j :: t =>
          exfalso
          have h1 : v.2.2 ≤ (applyWord t v).2.2 := hyp_le_applyWord t h
          have h2 : (applyWord t v).2.2 < (applyMove j (applyWord t v)).2.2 :=
            hyp_lt_applyMove (applyWord_valid t h)
          simp only [applyWord_nil, applyWord_cons] at hw
          rw [← hw] at h2
          linarith
  | cons i s ih =>
      intro w hw
      match w with
      | [] =>
          exfalso
          have h1 : v.2.2 ≤ (applyWord s v).2.2 := hyp_le_applyWord s h
          have h2 : (applyWord s v).2.2 < (applyMove i (applyWord s v)).2.2 :=
            hyp_lt_applyMove (applyWord_valid s h)
          simp only [applyWord_nil, applyWord_cons] at hw
          rw [hw] at h2
          linarith
      | j :: t =>
          simp only [applyWord_cons] at hw
          have hij : i = j := by
            rw [← whichMove_applyMove i (applyWord_valid s h),
              ← whichMove_applyMove j (applyWord_valid t h), hw]
          subst hij
          have : applyWord s v = applyWord t v := applyMove_injective i hw
          exact congrArg (i :: ·) (ih this)

/-- The classical root of the Berggren tree. -/
def root : Tri := (3, 4, 5)

theorem root_valid : Valid root := by
  refine ⟨by norm_num [root], by norm_num [root], by norm_num [root], by norm_num [root]⟩

/-- The three children of the root, as a sanity check on the classifier. -/
example : applyMove .m1 root = (5, 12, 13) := by norm_num [applyMove, root]

example : applyMove .m2 root = (21, 20, 29) := by norm_num [applyMove, root]

example : applyMove .m3 root = (15, 8, 17) := by norm_num [applyMove, root]

/-! ## Matrix formulation -/

/-- The Berggren moves as `3×3` integer matrices. -/
def bergMatrix : Move → Matrix (Fin 3) (Fin 3) ℤ
  | .m1 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .m2 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .m3 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The vector attached to a triple. -/
def vecOf (v : Tri) : Fin 3 → ℤ := ![v.1, v.2.1, v.2.2]

/-- The coordinate description of the moves agrees with matrix multiplication. -/
theorem vecOf_applyMove (i : Move) (v : Tri) :
    vecOf (applyMove i v) = (bergMatrix i).mulVec (vecOf v) := by
  cases i <;>
    · funext k
      fin_cases k <;>
        simp [vecOf, applyMove, bergMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;>
        ring

theorem det_bergMatrix (i : Move) : (bergMatrix i).det = if i = .m2 then -1 else 1 := by
  cases i <;> simp [bergMatrix, Matrix.det_fin_three]

end BerggrenModular
end Cryptography