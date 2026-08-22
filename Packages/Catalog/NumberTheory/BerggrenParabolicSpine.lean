import Mathlib
import Catalog.NumberTheory.BerggrenTreeCompleteness

/-!
# Parabolic and hyperbolic branches of the Berggren tree

The three Berggren matrices are *not* dynamically alike.  In `SO(2,1)`:

* `B₃` (here `bC`) is **unipotent** (`(B₃ - I)³ = 0`, trace `3`): iterating it moves a
  triple along a *parabolic* orbit whose hypotenuse grows only **quadratically**.  The
  closed form is proved in `bC_iterate_closed`.
* `B₂` (here `bB`) is **hyperbolic** (trace `5`, eigenvalue `3 + 2√2 = (1+√2)²`, the
  square of the silver ratio): its hypotenuse grows at least by a factor `5` per step,
  hence **exponentially** (`hyp_bB_iterate_ge`).

This dichotomy explains the counting theorem `BerggrenBoxCounting.berggren_box_theta`:
a purely hyperbolic tree of branching `3` would put only `O(log H)` nodes in a box on
each branch, while the parabolic branches deposit `≍ √H` nodes each; the aggregate is
`Θ(H)`.

The consequence proved here is a *seed-independent* lower bound: the orbit of **any**
valid triple under the parabolic generator alone already meets the box `[1,H]³` in at
least `≍ √H` points (`orbit_in_box_card_ge`).
-/

namespace BerggrenTree

/-- The hypotenuse minus the odd leg is invariant under the parabolic generator. -/
lemma bC_sub_invariant (t : Tri) : (bC t).2.2 - (bC t).1 = t.2.2 - t.1 := by
  simp only [bC]; ring

/-- Closed form for the iterates of the unipotent generator `B₃`. -/
theorem bC_iterate_closed (k : ℕ) (t : Tri) :
    bC^[k] t =
      (t.1 + (k : ℤ) * (-2 * t.1 + 2 * t.2.1 + 2 * t.2.2)
          + 2 * (k : ℤ) * ((k : ℤ) - 1) * (t.2.2 - t.1),
       t.2.1 + (k : ℤ) * (-2 * t.1 + 2 * t.2.2),
       t.2.2 + (k : ℤ) * (-2 * t.1 + 2 * t.2.1 + 2 * t.2.2)
          + 2 * (k : ℤ) * ((k : ℤ) - 1) * (t.2.2 - t.1)) := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [bC]
    push_cast
    refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> ring

/-- Along a parabolic orbit the hypotenuse grows **quadratically**, not exponentially. -/
theorem hyp_bC_iterate (k : ℕ) (t : Tri) :
    (bC^[k] t).2.2 = t.2.2 + (k : ℤ) * (-2 * t.1 + 2 * t.2.1 + 2 * t.2.2)
      + 2 * (k : ℤ) * ((k : ℤ) - 1) * (t.2.2 - t.1) := by
  rw [bC_iterate_closed]

lemma valid_bC_iterate (k : ℕ) {t : Tri} (h : Valid t) : Valid (bC^[k] t) := by
  induction k with
  | zero => simpa using h
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    exact valid_bC ih

/-- The hypotenuse strictly increases along a parabolic orbit. -/
theorem hyp_bC_iterate_strictMono {t : Tri} (h : Valid t) :
    StrictMono (fun k : ℕ => (bC^[k] t).2.2) := by
  refine strictMono_nat_of_lt_succ (fun k => ?_)
  have hv := valid_bC_iterate k h
  obtain ⟨ha, hb, hc, hpy, _, _⟩ := hv
  have hac : (bC^[k] t).1 < (bC^[k] t).2.2 := by nlinarith
  rw [Function.iterate_succ_apply']
  simp only [bC]
  linarith

/-- A quadratic upper bound for the hypotenuse along the parabolic orbit. -/
theorem hyp_bC_iterate_le {t : Tri} (h : Valid t) (k : ℕ) :
    (bC^[k] t).2.2 ≤ 7 * ((k : ℤ) + 1) ^ 2 * t.2.2 := by
  obtain ⟨ha, hb, hc, hpy, _, _⟩ := h
  have hbc : t.2.1 < t.2.2 := by nlinarith
  have hac : t.1 < t.2.2 := by nlinarith
  have hk : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg k
  rw [hyp_bC_iterate]
  nlinarith [hk, hb, ha, hc, hbc, hac, sq_nonneg ((k : ℤ))]

/-- The parabolic orbit of a valid triple, truncated at length `K`. -/
def cSpine (t : Tri) (K : ℕ) : Finset Tri := (Finset.range K).image (fun k => bC^[k] t)

lemma card_cSpine {t : Tri} (h : Valid t) (K : ℕ) : (cSpine t K).card = K := by
  rw [cSpine, Finset.card_image_of_injOn, Finset.card_range]
  intro i _ j _ hij
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · exact absurd (congrArg (fun u : Tri => u.2.2) hij)
      (ne_of_lt (hyp_bC_iterate_strictMono h hlt))
  · exact absurd (congrArg (fun u : Tri => u.2.2) hij).symm
      (ne_of_lt (hyp_bC_iterate_strictMono h hlt))

/-- **Seed-independent `Ω(√H)` lower bound.**  For every valid triple `t` and every `K`
with `7 K² c ≤ H`, the parabolic orbit of `t` contributes `K` distinct valid triples to
the box `[1,H]³`. -/
theorem orbit_in_box_card_ge {t : Tri} (h : Valid t) (H K : ℕ)
    (hK : 7 * ((K : ℤ)) ^ 2 * t.2.2 ≤ (H : ℤ)) :
    ∃ S : Finset Tri, S.card = K ∧
      ∀ u ∈ S, Valid u ∧ u.2.2 ≤ (H : ℤ) ∧ ∃ k : ℕ, bC^[k] t = u := by
  refine ⟨cSpine t K, card_cSpine h K, ?_⟩
  intro u hu
  obtain ⟨k, hk, rfl⟩ := Finset.mem_image.mp hu
  have hkK : k < K := Finset.mem_range.mp hk
  have hkZ : ((k : ℤ) + 1) ≤ (K : ℤ) := by exact_mod_cast hkK
  have hc0 : (0 : ℤ) < t.2.2 := h.2.2.1
  refine ⟨valid_bC_iterate k h, ?_, ⟨k, rfl⟩⟩
  have h1 := hyp_bC_iterate_le h k
  have h2 : 7 * ((k : ℤ) + 1) ^ 2 * t.2.2 ≤ 7 * ((K : ℤ)) ^ 2 * t.2.2 := by
    have hk0 : (0 : ℤ) ≤ (k : ℤ) + 1 := by positivity
    have hsq : ((k : ℤ) + 1) ^ 2 ≤ ((K : ℤ)) ^ 2 := by nlinarith
    nlinarith [hsq, hc0]
  linarith

lemma valid_bB_iterate (k : ℕ) {t : Tri} (h : Valid t) : Valid (bB^[k] t) := by
  induction k with
  | zero => simpa using h
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    exact valid_bB ih

/-! ### The hyperbolic branch -/

/-- One step of the hyperbolic generator `B₂` multiplies the hypotenuse by more than `5`
(the true expansion factor is the silver-ratio square `3 + 2√2 ≈ 5.828`). -/
theorem hyp_bB_gt {t : Tri} (h : Valid t) : 5 * t.2.2 < (bB t).2.2 := by
  obtain ⟨ha, hb, hc, hpy, _, _⟩ := h
  have hab : t.2.2 < t.1 + t.2.1 := by nlinarith
  simp only [bB]
  linarith

/-- Hence the hyperbolic branch grows exponentially: `c_k ≥ 5^k c`. -/
theorem hyp_bB_iterate_ge {t : Tri} (h : Valid t) (k : ℕ) :
    5 ^ k * t.2.2 ≤ (bB^[k] t).2.2 := by
  induction k with
  | zero => simp
  | succ n ih =>
    have hvn : Valid (bB^[n] t) := valid_bB_iterate n h
    have hstep : 5 * (bB^[n] t).2.2 < (bB^[n + 1] t).2.2 := by
      rw [Function.iterate_succ_apply']
      exact hyp_bB_gt hvn
    have h5 : (0 : ℤ) < 5 ^ n := by positivity
    calc (5 : ℤ) ^ (n + 1) * t.2.2 = 5 * (5 ^ n * t.2.2) := by ring
      _ ≤ 5 * (bB^[n] t).2.2 := by linarith
      _ ≤ (bB^[n + 1] t).2.2 := le_of_lt hstep

end BerggrenTree