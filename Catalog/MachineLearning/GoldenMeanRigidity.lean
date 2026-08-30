import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.GoldenMeanHomeomorph

/-!
# Rigidity: homeomorphic spaces, non-conjugate dynamics

Eighth cycle of the research thread.  Cycle 4 produced an explicit homeomorphism
`goldenMeanHomeomorph : Cantor ≃ₜ GoldenMean`, built from the golden substitution
`0 ↦ 0, 1 ↦ 10`: as *topological spaces* the full Cantor truth space and the golden-mean
subshift are indistinguishable — both are nonempty compact perfect totally disconnected
metrizable spaces.

This file shows that the *dynamical systems* are nevertheless rigidly different.  The obstruction
is the simplest possible conjugacy invariant, the number of fixed points of the shift:

* the full shift has exactly two fixed points, the constant streams
  (`fixedPoints_shift_cantor`);
* the golden-mean shift has exactly one, the all-`false` stream, because the constant `true`
  stream contains `11` (`fixedPoints_shift_goldenMean`).

Hence no bijection intertwining the two shifts can exist (`not_exists_shift_conjugacy`), even
though a homeomorphism does (`homeomorphic_but_not_conjugate`).  Along the way we record that
the golden-mean shift is surjective but not injective, so it is a genuinely non-invertible
chaotic endomorphism.

## Main results

* `shift_fixed_iff` — a stream is shift-invariant exactly when it is constant.
* `fixedPoints_shift_cantor`, `fixedPoints_shift_goldenMean` — two fixed points versus one.
* `not_exists_shift_conjugacy` — no shift-equivariant bijection `Cantor ≃ GoldenMean`.
* `homeomorphic_but_not_conjugate` — the two statements side by side.
* `surjOn_shift_goldenMean`, `not_injOn_shift_goldenMean` — the golden-mean shift is a
  surjective, non-injective self-map of the subshift.
-/

namespace FractalTruthCompactness

open FractalTruthMetric

/-! ## Constant streams -/

/-- The constantly-`false` stream. -/
def allFalse : Cantor := fun _ => false

/-- The constantly-`true` stream. -/
def allTrue : Cantor := fun _ => true

@[simp] theorem allFalse_apply (k : ℕ) : allFalse k = false := rfl
@[simp] theorem allTrue_apply (k : ℕ) : allTrue k = true := rfl

theorem allFalse_ne_allTrue : allFalse ≠ allTrue := by
  intro h
  have := congrFun h 0
  simp at this

theorem allFalse_mem_goldenMean : allFalse ∈ GoldenMean := by
  intro k hk
  simp at hk

theorem allTrue_not_mem_goldenMean : allTrue ∉ GoldenMean := by
  intro h
  exact h 0 ⟨rfl, rfl⟩

/-! ## Fixed points of the shift -/

/-- A stream is fixed by the shift exactly when it is constant. -/
theorem shift_fixed_iff {x : Cantor} : shift x = x ↔ ∀ k, x k = x 0 := by
  constructor
  · intro h k
    induction k with
    | zero => rfl
    | succ m ih =>
        have := congrFun h m
        rw [shift_apply] at this
        rw [this, ih]
  · intro h
    funext k
    rw [shift_apply, h (k + 1), h k]

/-- **The full shift has exactly two fixed points.** -/
theorem fixedPoints_shift_cantor : {x : Cantor | shift x = x} = {allFalse, allTrue} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro h
    rw [shift_fixed_iff] at h
    cases hx : x 0 with
    | false => left; funext k; rw [h k, hx]; rfl
    | true => right; funext k; rw [h k, hx]; rfl
  · rintro (rfl | rfl) <;> rw [shift_fixed_iff] <;> intro k <;> rfl

/-- **The golden-mean shift has exactly one fixed point.**  The other constant stream is
forbidden, since it contains `11`. -/
theorem fixedPoints_shift_goldenMean :
    {x : Cantor | x ∈ GoldenMean ∧ shift x = x} = {allFalse} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hmem, hfix⟩
    have hx : x ∈ ({allFalse, allTrue} : Set Cantor) := by
      rw [← fixedPoints_shift_cantor]; exact hfix
    rcases hx with h | h
    · exact h
    · exact absurd (h ▸ hmem) allTrue_not_mem_goldenMean
  · rintro rfl
    exact ⟨allFalse_mem_goldenMean, by rw [shift_fixed_iff]; intro k; rfl⟩

/-- Any fixed point of the shift inside the subshift is the all-`false` stream. -/
theorem eq_allFalse_of_mem_of_fixed {x : Cantor} (hmem : x ∈ GoldenMean) (hfix : shift x = x) :
    x = allFalse := by
  have : x ∈ ({allFalse} : Set Cantor) := by
    rw [← fixedPoints_shift_goldenMean]; exact ⟨hmem, hfix⟩
  simpa using this

/-! ## No conjugacy -/

/-- **Rigidity.**  There is no shift-equivariant bijection between the full Cantor truth space
and the golden-mean subshift: the fixed-point counts `2` and `1` are a conjugacy invariant that
already separates them. -/
theorem not_exists_shift_conjugacy :
    ¬ ∃ e : Cantor ≃ GoldenMean, ∀ x : Cantor, ((e (shift x) : Cantor)) = shift ((e x : Cantor)) := by
  rintro ⟨e, he⟩
  have key : ∀ x : Cantor, shift x = x → ((e x : Cantor)) = allFalse := by
    intro x hx
    refine eq_allFalse_of_mem_of_fixed (e x).2 ?_
    have h := he x
    rw [hx] at h
    exact h.symm
  have h1 : ((e allFalse : Cantor)) = allFalse :=
    key allFalse (by rw [shift_fixed_iff]; intro k; rfl)
  have h2 : ((e allTrue : Cantor)) = allFalse :=
    key allTrue (by rw [shift_fixed_iff]; intro k; rfl)
  have : e allFalse = e allTrue := Subtype.ext (by rw [h1, h2])
  exact allFalse_ne_allTrue (e.injective this)

/-- **Homeomorphic but not conjugate.**  The two systems have the same topology and different
dynamics: a homeomorphism `Cantor ≃ₜ GoldenMean` exists, yet no bijection at all intertwines
the two shifts. -/
theorem homeomorphic_but_not_conjugate :
    (Nonempty (Cantor ≃ₜ GoldenMean)) ∧
    ¬ ∃ e : Cantor ≃ GoldenMean,
        ∀ x : Cantor, ((e (shift x) : Cantor)) = shift ((e x : Cantor)) :=
  ⟨nonempty_homeomorph_goldenMean, not_exists_shift_conjugacy⟩

/-! ## The golden-mean shift is surjective but not injective -/

/-- Prepend a letter to a stream. -/
def consStream (b : Bool) (x : Cantor) : Cantor := fun k => if k = 0 then b else x (k - 1)

@[simp] theorem consStream_zero (b : Bool) (x : Cantor) : consStream b x 0 = b := rfl

@[simp] theorem consStream_succ (b : Bool) (x : Cantor) (k : ℕ) :
    consStream b x (k + 1) = x k := by
  simp [consStream]

theorem shift_consStream (b : Bool) (x : Cantor) : shift (consStream b x) = x := by
  funext k
  rw [shift_apply, consStream_succ]

/-- Prepending `false` keeps a stream in the subshift. -/
theorem consStream_false_mem_goldenMean {x : Cantor} (hx : x ∈ GoldenMean) :
    consStream false x ∈ GoldenMean := by
  intro k hk
  cases k with
  | zero => simp at hk
  | succ m =>
      rw [consStream_succ, consStream_succ] at hk
      exact hx m hk

/-- Prepending `true` keeps a stream in the subshift provided it starts with `false`. -/
theorem consStream_true_mem_goldenMean {x : Cantor} (hx : x ∈ GoldenMean) (h0 : x 0 = false) :
    consStream true x ∈ GoldenMean := by
  intro k hk
  cases k with
  | zero =>
      rw [consStream_zero, consStream_succ] at hk
      rw [h0] at hk
      exact Bool.false_ne_true hk.2
  | succ m =>
      rw [consStream_succ, consStream_succ] at hk
      exact hx m hk

/-- **The golden-mean shift is surjective** on the subshift: every admissible future has an
admissible past, obtained by prepending `false`. -/
theorem surjOn_shift_goldenMean : Set.SurjOn shift GoldenMean GoldenMean := by
  intro y hy
  exact ⟨consStream false y, consStream_false_mem_goldenMean hy, shift_consStream false y⟩

/-- **The golden-mean shift is not injective** on the subshift: the all-`false` stream has two
admissible preimages.  Together with `surjOn_shift_goldenMean` this makes the subshift a
non-invertible surjective chaotic endomorphism, not a homeomorphism. -/
theorem not_injOn_shift_goldenMean : ¬ Set.InjOn shift GoldenMean := by
  intro hinj
  have h1 : consStream false allFalse ∈ GoldenMean :=
    consStream_false_mem_goldenMean allFalse_mem_goldenMean
  have h2 : consStream true allFalse ∈ GoldenMean :=
    consStream_true_mem_goldenMean allFalse_mem_goldenMean rfl
  have heq : shift (consStream false allFalse) = shift (consStream true allFalse) := by
    rw [shift_consStream, shift_consStream]
  have := hinj h1 h2 heq
  have := congrFun this 0
  simp at this

end FractalTruthCompactness