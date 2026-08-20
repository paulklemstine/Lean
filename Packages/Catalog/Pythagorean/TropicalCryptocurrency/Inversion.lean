import Pythagorean.TropicalCryptocurrency.RecessionCone

/-!
# Tropical Cryptocurrency V: canonical inversion and constrained mining

The catalogue file `Algebra/TropicalCryptocurrency/Hash.lean` inverted the *single*
min-plus key by the explicit preimage `m i = y - h i`.  For `r` simultaneous keys
the naive formula breaks down: the system

`min over j of (m j + A i j) = y i`   (for all `i`)

couples all coordinates, and it need not be solvable at all.

This file settles the structure of the general fiber.

* `canonicalPre A y j = max over i of (y i - A i j)` is the coordinatewise least
  message satisfying all the *inequality* constraints.
* `preimage_exists_iff` : the fiber over `y` is nonempty **iff** this single
  candidate lies in it.  Inversion therefore costs one `r × k` evaluation — no
  search over active sets is required, which is the tractable side of the
  "nonce-restricted mining" question.
* `canonicalPre_le_of_mem_fiber` : the candidate is the minimum of the fiber, so the
  fiber is an upward-directed-at-the-bottom set with a unique least element.
* `box_preimage_exists_iff` : mining under *box* (bounded-alphabet or difference-free
  nonce) constraints is decided by the single candidate `max (canonicalPre A y) L`.
  Restricting the message space to a box therefore does not make inversion harder.

-- !-- Lab Notes -- !--
Hypothesis: constrained tropical preimage search requires enumerating which
coordinate certifies each component's minimum (exponentially many active patterns).
Experiment: the inequality part of the fiber is a *single* upward-closed orthant
with vertex `canonicalPre A y`, and the digest is monotone; testing the vertex
therefore decides the whole system.  Adding a lower bound `L` moves the vertex to
`max (canonicalPre A y) L`, and an upper bound `U` is checked pointwise.
Analysis: no disjunction over active sets survives, because the minimum of a
monotone family is attained at the least feasible point.  Hardness for nonce
families must therefore come from constraints that are *not* upward closed (e.g.
arbitrary binary linear constraints), never from the min-plus structure itself.
Critique: the theorem is about box/lower-bound constraints; general difference
constraints `m j - m j' ≤ c` are also upward-closed-compatible via shortest paths,
but that requires a separate argument and is left as a stated future direction.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalRecession

variable {k r : ℕ} [Nonempty (Fin k)]

/-- The digest is monotone in the message. -/
theorem digest_mono (A : Fin r → Fin k → ℝ) {m m' : Fin k → ℝ} (h : ∀ j, m j ≤ m' j)
    (i : Fin r) : digest A m i ≤ digest A m' i :=
  le_digest fun j => le_trans (digest_le A m i j) (by linarith [h j])

variable [Nonempty (Fin r)]

/-- The coordinatewise least message obeying every inequality constraint
`m j + A i j ≥ y i`. -/
def canonicalPre (A : Fin r → Fin k → ℝ) (y : Fin r → ℝ) (j : Fin k) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i => y i - A i j

omit [Nonempty (Fin k)] in
lemma canonicalPre_spec (A : Fin r → Fin k → ℝ) (y : Fin r → ℝ) (i : Fin r) (j : Fin k) :
    y i ≤ canonicalPre A y j + A i j := by
  have h : y i - A i j ≤ canonicalPre A y j :=
    Finset.le_sup' (f := fun i => y i - A i j) (Finset.mem_univ i)
  linarith

omit [Nonempty (Fin k)] in
lemma canonicalPre_le_iff {A : Fin r → Fin k → ℝ} {y : Fin r → ℝ} {m : Fin k → ℝ} {j : Fin k} :
    canonicalPre A y j ≤ m j ↔ ∀ i, y i ≤ m j + A i j := by
  rw [canonicalPre, Finset.sup'_le_iff]
  constructor
  · intro h i
    have := h i (Finset.mem_univ i)
    linarith
  · intro h i _
    have := h i
    linarith

/-- Every element of the fiber dominates the canonical candidate: `canonicalPre A y`
is the least element of the fiber whenever the fiber is nonempty. -/
theorem canonicalPre_le_of_mem_fiber {A : Fin r → Fin k → ℝ} {y : Fin r → ℝ}
    {m : Fin k → ℝ} (hm : digest A m = y) (j : Fin k) : canonicalPre A y j ≤ m j := by
  refine canonicalPre_le_iff.mpr fun i => ?_
  have h := digest_le A m i j
  rw [hm] at h
  exact h

/-- **Tropical inversion is a one-shot test.**  The fiber over `y` is nonempty
precisely when the canonical candidate `canonicalPre A y` lies in it. -/
theorem preimage_exists_iff (A : Fin r → Fin k → ℝ) (y : Fin r → ℝ) :
    (∃ m : Fin k → ℝ, digest A m = y) ↔ digest A (canonicalPre A y) = y := by
  constructor
  · rintro ⟨m, hm⟩
    funext i
    refine le_antisymm ?_ (le_digest fun j => canonicalPre_spec A y i j)
    have h1 : digest A (canonicalPre A y) i ≤ digest A m i :=
      digest_mono A (canonicalPre_le_of_mem_fiber hm) i
    rw [hm] at h1
    exact h1
  · intro h
    exact ⟨canonicalPre A y, h⟩

/-- **Mining under box constraints is also a one-shot test.**  With a lower bound
`L` and an upper bound `U` on the message (a bounded alphabet, or a nonce family
given by independent coordinate ranges), the constrained fiber is nonempty exactly
when the single candidate `max (canonicalPre A y) L` witnesses it. -/
theorem box_preimage_exists_iff (A : Fin r → Fin k → ℝ) (y : Fin r → ℝ) (L U : Fin k → ℝ) :
    (∃ m : Fin k → ℝ, (∀ j, L j ≤ m j) ∧ (∀ j, m j ≤ U j) ∧ digest A m = y) ↔
      ((∀ j, max (canonicalPre A y j) (L j) ≤ U j) ∧
        digest A (fun j => max (canonicalPre A y j) (L j)) = y) := by
  set w : Fin k → ℝ := fun j => max (canonicalPre A y j) (L j) with hw
  constructor
  · rintro ⟨m, hL, hU, hm⟩
    have hwm : ∀ j, w j ≤ m j := fun j =>
      max_le (canonicalPre_le_of_mem_fiber hm j) (hL j)
    refine ⟨fun j => le_trans (hwm j) (hU j), ?_⟩
    funext i
    refine le_antisymm ?_ (le_digest fun j => ?_)
    · have h1 : digest A w i ≤ digest A m i := digest_mono A hwm i
      rw [hm] at h1
      exact h1
    · have h2 : canonicalPre A y j ≤ w j := le_max_left _ _
      have h3 := canonicalPre_spec A y i j
      linarith
  · rintro ⟨hU, hfib⟩
    exact ⟨w, fun j => le_max_right _ _, hU, hfib⟩

end TropicalRecession