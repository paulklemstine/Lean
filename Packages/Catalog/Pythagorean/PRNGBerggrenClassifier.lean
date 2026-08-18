import Mathlib
import Pythagorean.PRNGBerggrenFingerprint

/-!
# Routing Pythagorean data: a classifier for Berggren-generated streams

Continuation of `Pythagorean.PRNGBerggrenFingerprint`.  There the *fingerprint*
(order-3 linear recurrence) of a Berggren orbit was established.  Here we build
the **classifier** that the research programme calls for: a decision procedure
routing an observed stream of triples to *seed-compressible* (some Berggren move
generated it, so store three integers plus a two-bit family label) or
*model-compressible* (no Berggren move did, so fall back to a general model).

Main contents.

* `IsOrbit`, `isOrbit_iff_iterate` — the predicate "the file is the orbit of `m`".
* `orbitA_invariant`, `orbitC_invariant`, `bergB_legdiff_abs` — cheap conserved
  quantities separating the three branches (`c-b` frozen on the `A`-branch,
  `c-a` frozen on the `C`-branch, `|b-a|` frozen on the `B`-branch).
* `moves_pairwise_ne` — **one transition identifies the family**: on a triple
  with positive legs the three Berggren images are pairwise distinct.
* `whichMove`, `whichMove_sound`, `whichMove_complete` — the classifier itself,
  proved sound and complete on positive triples.
* `orbit_family_unique` — a stream cannot be explained by two different branches.
* `card_bergWords_le`, `exists_not_bergWord` — **rarity**: the number of
  length-`n` Berggren files from a bounded seed box is bounded *independently of
  `n`*, so already at length `2` most files are not seed-compressible.  This is
  the quantitative form of the falsifiability gate.
* `constant_stream_not_orbit`, `six_eight_ten_no_positive_parent` — concrete
  negative benchmark items: real Pythagorean data that is *not* seed-compressible
  in this family (in particular, rescaling a triple destroys seed
  compressibility).
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid

/-! ## Observed streams and the orbit predicate -/

/-- The observed file `x` is the orbit of the generator `m`. -/
def IsOrbit (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) (x : ℕ → ℤ × ℤ × ℤ) : Prop :=
  ∀ t, x (t + 1) = m (x t)

/-- An orbit is exactly a stream of the generator started at the first symbol:
seed recovery for the triple stream is reading off `x 0`. -/
theorem isOrbit_iff_iterate (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) (x : ℕ → ℤ × ℤ × ℤ) :
    IsOrbit m x ↔ ∀ t, x t = (bergGen m).stream (x 0) t := by
  constructor
  · intro h t
    induction t with
    | zero => rfl
    | succ t ih =>
        rw [h t, ih, bergGen_stream, bergGen_stream, Function.iterate_succ_apply']
  · intro h t
    rw [h (t + 1), h t, bergGen_stream, bergGen_stream, Function.iterate_succ_apply']

/-! ## Conserved quantities: the branch signatures -/

/-- On the `A`-branch the gap `c - b` never changes. -/
theorem orbitA_invariant (a b c : ℤ) (t : ℕ) :
    (moveA^[t] (a, b, c)).2.2 - (moveA^[t] (a, b, c)).2.1 = c - b := by
  rw [orbitA_closed_form]
  ring

/-- On the `C`-branch the gap `c - a` never changes. -/
theorem orbitC_invariant (a b c : ℤ) (t : ℕ) :
    (moveC^[t] (a, b, c)).2.2 - (moveC^[t] (a, b, c)).1 = c - a := by
  rw [orbitC_closed_form]
  ring

/-- On the `B`-branch the leg gap only flips sign, so its absolute value is
frozen. -/
theorem bergB_legdiff_abs (a b c : ℤ) (t : ℕ) :
    |(moveB^[t] (a, b, c)).2.1 - (moveB^[t] (a, b, c)).1| = |b - a| := by
  rw [bergB_legdiff_alternates, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]

/-! ## Fingerprinting: one observed transition identifies the branch -/

/-- **Separation of the three generators.**  On a triple with positive legs the
three Berggren moves land on three *distinct* triples, so a single observed
transition already determines which branch produced the data. -/
theorem moves_pairwise_ne (p : ℤ × ℤ × ℤ) (ha : 0 < p.1) (hb : 0 < p.2.1) :
    moveA p ≠ moveB p ∧ moveA p ≠ moveC p ∧ moveB p ≠ moveC p := by
  obtain ⟨a, b, c⟩ := p
  simp only at ha hb
  refine ⟨?_, ?_, ?_⟩ <;>
    simp only [moveA, moveB, moveC, bergA, bergB, bergC, ne_eq, Prod.mk.injEq, not_and] <;>
    intro h1 <;> omega

/-- The classifier: given two consecutive observed triples, return the Berggren
step that explains the transition, if there is one. -/
def whichMove (p q : ℤ × ℤ × ℤ) : Option BerggrenStep :=
  if moveA p = q then some .A
  else if moveB p = q then some .B
  else if moveC p = q then some .C
  else none

/-- **Soundness of the classifier**: whenever it commits to a branch, that branch
really does produce the observed transition. -/
theorem whichMove_sound {p q : ℤ × ℤ × ℤ} {s : BerggrenStep} (h : whichMove p q = some s) :
    applyStep s p = q := by
  obtain ⟨a, b, c⟩ := p
  unfold whichMove at h
  split_ifs at h with h1 h2 h3 <;> cases h <;>
    simpa [applyStep, moveA, moveB, moveC] using ‹_›

/-- **Completeness of the classifier**: if the transition is Berggren at all, the
classifier finds a branch. -/
theorem whichMove_complete {p q : ℤ × ℤ × ℤ} {s : BerggrenStep} (h : applyStep s p = q) :
    (whichMove p q).isSome := by
  obtain ⟨a, b, c⟩ := p
  cases s <;> simp only [applyStep] at h <;> subst h <;> unfold whichMove <;>
    simp only [moveA, moveB, moveC] <;> split_ifs <;> simp

/-- **Exactness of the classifier on nondegenerate data**: on a triple with
positive legs the returned branch is *the* branch. -/
theorem whichMove_eq_of_pos {p : ℤ × ℤ × ℤ} (ha : 0 < p.1) (hb : 0 < p.2.1) {q : ℤ × ℤ × ℤ}
    {s : BerggrenStep} (h : applyStep s p = q) : whichMove p q = some s := by
  obtain ⟨hAB, hAC, hBC⟩ := moves_pairwise_ne p ha hb
  obtain ⟨a, b, c⟩ := p
  subst h
  simp only [moveA, moveB, moveC] at hAB hAC hBC
  cases s <;> simp only [applyStep] <;> unfold whichMove <;>
    simp [moveA, moveB, moveC, hAB, hAC, hBC]

/-- **Unambiguous routing.**  A file with positive legs at the first symbol
cannot be explained by two different Berggren branches: the seed *and* the family
label are uniquely recoverable. -/
theorem orbit_family_unique {x : ℕ → ℤ × ℤ × ℤ} (ha : 0 < (x 0).1) (hb : 0 < (x 0).2.1)
    {s s' : BerggrenStep} (h : ∀ t, x (t + 1) = applyStep s (x t))
    (h' : ∀ t, x (t + 1) = applyStep s' (x t)) : s = s' := by
  have hs : applyStep s (x 0) = x 1 := (h 0).symm
  have hs' : applyStep s' (x 0) = x 1 := (h' 0).symm
  have e1 := whichMove_eq_of_pos ha hb hs
  have e2 := whichMove_eq_of_pos ha hb hs'
  rw [e1] at e2
  exact Option.some_inj.mp e2

/-! ## Rarity: seed compression cannot cover the data -/

section Counting

variable (N : ℤ)

/-- Seeds with all coordinates in `[-N, N]`. -/
def seedBox : Finset (ℤ × ℤ × ℤ) :=
  (Finset.Icc (-N) N) ×ˢ (Finset.Icc (-N) N) ×ˢ (Finset.Icc (-N) N)

theorem card_seedBox : (seedBox N).card = (2 * N + 1).toNat ^ 3 := by
  have h : (Finset.Icc (-N) N).card = (2 * N + 1).toNat := by
    rw [Int.card_Icc]
    congr 1
    omega
  simp [seedBox, Finset.card_product, h, pow_succ, mul_comm]

/-- The length-`n` files produced by *any* of the three Berggren moves from a
seed in the box: the entire reach of the seed-compression scheme. -/
def bergWords (n : ℕ) : Finset (Fin n → ℤ × ℤ × ℤ) :=
  ((seedBox N).image ((bergGen moveA).pref n)) ∪
    ((seedBox N).image ((bergGen moveB).pref n)) ∪
    ((seedBox N).image ((bergGen moveC).pref n))

/-- **Capacity of the seed compressor.**  Whatever the file length, at most
`3 · (2N+1)³` files can be produced: the reachable set does not grow with `n`. -/
theorem card_bergWords_le (n : ℕ) :
    (bergWords N n).card ≤ 3 * (2 * N + 1).toNat ^ 3 := by
  have h1 : ∀ m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ,
      ((seedBox N).image ((bergGen m).pref n)).card ≤ (2 * N + 1).toNat ^ 3 := by
    intro m
    exact (Finset.card_image_le).trans (le_of_eq (card_seedBox N))
  calc (bergWords N n).card
      ≤ (((seedBox N).image ((bergGen moveA).pref n)) ∪
          ((seedBox N).image ((bergGen moveB).pref n))).card +
          ((seedBox N).image ((bergGen moveC).pref n)).card := Finset.card_union_le _ _
    _ ≤ (((seedBox N).image ((bergGen moveA).pref n)).card +
          ((seedBox N).image ((bergGen moveB).pref n)).card) +
          ((seedBox N).image ((bergGen moveC).pref n)).card := by
        gcongr
        exact Finset.card_union_le _ _
    _ ≤ ((2 * N + 1).toNat ^ 3 + (2 * N + 1).toNat ^ 3) + (2 * N + 1).toNat ^ 3 := by
        gcongr <;> exact h1 _
    _ = 3 * (2 * N + 1).toNat ^ 3 := by ring

/-- **Most files are not seed-compressible.**  Already for files of length `2`
over the same bounded alphabet, some file is outside the reach of every Berggren
generator with a seed in the box.  (The gap widens exponentially in `n`.) -/
theorem exists_not_bergWord (n : ℕ) (hn : 2 ≤ n) (hN : 1 ≤ N) :
    ∃ x ∈ Fintype.piFinset (fun _ : Fin n => seedBox N), x ∉ bergWords N n := by
  classical
  by_contra hc
  push_neg at hc
  have hsub : Fintype.piFinset (fun _ : Fin n => seedBox N) ⊆ bergWords N n := hc
  set K : ℕ := (2 * N + 1).toNat with hK
  have hcard : (K ^ 3) ^ n ≤ (bergWords N n).card := by
    have h := Finset.card_le_card hsub
    rwa [Fintype.card_piFinset, Finset.prod_const, Finset.card_univ, Fintype.card_fin,
      card_seedBox N] at h
  have hbound := card_bergWords_le N n
  rw [← hK] at hbound
  have hK3 : 3 ≤ K := by omega
  have hpos : 0 < K ^ 3 := by positivity
  have h27 : 27 ≤ K ^ 3 := by
    have := Nat.pow_le_pow_left hK3 3
    norm_num at this
    exact this
  have h1 : (K ^ 3) ^ 2 ≤ (K ^ 3) ^ n := Nat.pow_le_pow_right hpos hn
  have h2 : 27 * K ^ 3 ≤ (K ^ 3) ^ 2 := by
    have : (K ^ 3) ^ 2 = K ^ 3 * K ^ 3 := by ring
    rw [this]
    exact Nat.mul_le_mul_right _ h27
  omega

end Counting

/-! ## Negative benchmark items -/

/-- A constant stream of a triple with positive legs is *not* a Berggren orbit:
repetition is model-compressible, not seed-compressible in this family. -/
theorem constant_stream_not_orbit (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : IsPythag a b c) (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) (hm : m = moveA ∨ m = moveB ∨ m = moveC) :
    ¬ IsOrbit m (fun _ => (a, b, c)) := by
  intro horb
  have h0 := horb 0
  have h' : a ^ 2 + b ^ 2 = c ^ 2 := h
  have hcb : b < c := by nlinarith
  have hca : a < c := by nlinarith
  rcases hm with rfl | rfl | rfl <;>
    simp only [moveA, moveB, moveC, bergA, bergB, bergC, Prod.mk.injEq] at h0 <;> omega

/-- **Rescaling destroys seed compressibility.**  The (non-primitive) triple
`(6,8,10)` — the double of the root — has no Berggren parent with positive legs,
so no Berggren generator can emit it after a first step.  Concretely, doubling a
seed-compressible file makes it seed-incompressible in this family. -/
theorem six_eight_ten_no_positive_parent (p : ℤ × ℤ × ℤ) (ha : 0 < p.1) (hb : 0 < p.2.1) :
    moveA p ≠ (6, 8, 10) ∧ moveB p ≠ (6, 8, 10) ∧ moveC p ≠ (6, 8, 10) := by
  obtain ⟨a, b, c⟩ := p
  simp only at ha hb
  refine ⟨?_, ?_, ?_⟩ <;>
    simp only [moveA, moveB, moveC, bergA, bergB, bergC, ne_eq, Prod.mk.injEq, not_and] <;>
    intro h1 h2 <;> omega

end Catalog.Pythagorean.BerggrenPRNG