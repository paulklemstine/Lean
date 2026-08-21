import Novelty.BerggrenCausalSetPhysics

/-!
# The Berggren causal set III: proper time, spatial slices, edge lengths, freeness

Third cycle of the investigation.  Cycle I proved the causal-set axioms, cycle II proved
that the ambient Minkowski separation of *every* pair of distinct events is spacelike and
that the interval growth is linear.  This file sharpens all three fronts.

## Main results

* `mink_edge_A`, `mink_edge_B`, `mink_edge_C` — **the exact edge-length spectrum**.  For an
  event `(a,b,c)` the Minkowski interval of the three tree edges is
  `4 (c − b)²`, `4 (a − b)²`, `4 (c − a)²` respectively: the "links" of the causal set have
  exactly computable spacelike lengths, all strictly positive (`mink_edges_pos`).
* `legs_ne` — no primitive event has `a = b`, so the middle edge never degenerates.
* `properTime` and `properTime_add` — the **discrete proper time** (the unique word length
  between two causally related events) is well defined and additive along causal chains,
  and `causalInterval_ncard_properTime` computes every interval volume from it.
* `link_iff_properTime_one` — the links (covering relations) of the causal set are exactly
  the Berggren moves.
* `level_antichain` — each depth level is an **antichain**: the `3 ^ k` events at depth `k`
  are pairwise causally unrelated, a discrete "spatial slice" of `3 ^ k` events.
* `wordMat_injective` — the three Berggren generators generate a **free monoid of rank 3**
  inside `O(2,1;ℤ)`; this is the group-theoretic source of the `3 ^ k` level growth.
-/

namespace BerggrenCausalSet

/-! ## Part A. Exact spacelike lengths of the causal links -/

/-- The `A`-edge has spacelike length `4 (c − b)²`; remarkably this needs no Pythagorean
input, the `b`- and `c`-increments of the move cancel identically. -/
theorem mink_edge_A (a b c : ℤ) : mink (a, b, c) (bergA a b c) = 4 * (c - b) ^ 2 := by
  simp only [mink, bergA]
  ring

/-- The middle (Pell) edge has spacelike length `4 (a − b)²`; this one *does* use the null
condition `a² + b² = c²`. -/
theorem mink_edge_B {a b c : ℤ} (h : IsEvent (a, b, c)) :
    mink (a, b, c) (bergB a b c) = 4 * (a - b) ^ 2 := by
  have hp := h.1
  unfold IsPythag at hp
  simp only at hp
  simp only [mink, bergB]
  linear_combination (-4 : ℤ) * hp

/-- The `C`-edge has spacelike length `4 (c − a)²`. -/
theorem mink_edge_C (a b c : ℤ) : mink (a, b, c) (bergC a b c) = 4 * (c - a) ^ 2 := by
  simp only [mink, bergC]
  ring

/-- The legs of a primitive event are never equal (`a = b` would force `c² = 2`). -/
theorem legs_ne {t : Event} (h : IsPrimEvent t) : t.1 ≠ t.2.1 := by
  intro hab
  obtain ⟨⟨hp, ha, hb, hc⟩, hg⟩ := h
  unfold IsPythag at hp
  rw [← hab] at hg hp
  have h1 : t.1.natAbs = 1 := by simpa using hg
  have h2 : t.1 = 1 := by omega
  rw [h2] at hp
  have hc2 : t.2.2 ^ 2 = 2 := by linarith
  rcases (by omega : t.2.2 = 1 ∨ 2 ≤ t.2.2) with h3 | h3
  · rw [h3] at hc2; norm_num at hc2
  · nlinarith

/-- The three link lengths at a primitive event are all strictly positive: no causal link
of the Berggren causal set is null or timelike. -/
theorem mink_edges_pos {a b c : ℤ} (h : IsPrimEvent (a, b, c)) :
    0 < mink (a, b, c) (bergA a b c) ∧ 0 < mink (a, b, c) (bergB a b c) ∧
      0 < mink (a, b, c) (bergC a b c) := by
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h.1
  have hab : a ≠ b := legs_ne h
  simp only at hac hbc
  refine ⟨?_, ?_, ?_⟩
  · rw [mink_edge_A]
    have : c - b ≠ 0 := sub_ne_zero_of_ne (by omega)
    positivity
  · rw [mink_edge_B h.1]
    have : a - b ≠ 0 := sub_ne_zero_of_ne hab
    positivity
  · rw [mink_edge_C]
    have : c - a ≠ 0 := sub_ne_zero_of_ne (by omega)
    positivity

/-! ## Part B. Discrete proper time -/

open Classical in
/-- The **discrete proper time** between two causally related events: the length of the
(unique, by `run_word_unique`) word of Berggren moves joining them. -/
noncomputable def properTime (t u : Event) : ℕ :=
  if h : Causal t u then (Classical.choose h).length else 0

theorem properTime_eq {t u : Event} (ht : IsEvent t) {w : List BerggrenStep}
    (hw : run w t = u) : properTime t u = w.length := by
  have hc : Causal t u := ⟨w, hw⟩
  have hspec : run (Classical.choose hc) t = u := Classical.choose_spec hc
  have : Classical.choose hc = w := run_word_unique ht (by rw [hspec, hw])
  simp only [properTime, dif_pos hc, this]

@[simp] theorem properTime_self {t : Event} (ht : IsEvent t) : properTime t t = 0 :=
  properTime_eq ht (w := []) rfl

/-- Proper time is additive along causal chains. -/
theorem properTime_add {t u v : Event} (ht : IsEvent t) (h₁ : Causal t u) (h₂ : Causal u v) :
    properTime t v = properTime t u + properTime u v := by
  obtain ⟨w₁, rfl⟩ := h₁
  obtain ⟨w₂, rfl⟩ := h₂
  rw [properTime_eq ht (w := w₁ ++ w₂) (by rw [run_append]), properTime_eq ht (w := w₁) rfl,
    properTime_eq (run_isEvent w₁ ht) (w := w₂) rfl, List.length_append]

/-- The hypotenuse ("cosmic time") advances by at least the proper time. -/
theorem properTime_le_hyp_diff {t u : Event} (ht : IsEvent t) (h : Causal t u) :
    t.2.2 + (properTime t u : ℤ) ≤ u.2.2 := by
  obtain ⟨w, rfl⟩ := h
  rw [properTime_eq ht (w := w) rfl]
  exact run_hyp_ge w ht

/-- **Interval volume from proper time.** -/
theorem causalInterval_ncard_properTime {t u : Event} (ht : IsEvent t) (h : Causal t u) :
    (causalInterval t u).ncard = properTime t u + 1 := by
  obtain ⟨w, rfl⟩ := h
  rw [causalInterval_ncard ht, properTime_eq ht (w := w) rfl]

/-- **The links of the causal set are exactly the Berggren moves.** -/
theorem link_iff_properTime_one {t u : Event} (ht : IsEvent t) (h : Causal t u) :
    properTime t u = 1 ↔ ∃ s : BerggrenStep, applyStep s t = u := by
  obtain ⟨w, rfl⟩ := h
  rw [properTime_eq ht (w := w) rfl]
  constructor
  · intro hlen
    obtain ⟨s, hs⟩ : ∃ s, w = [s] := by
      match w, hlen with
      | [s], _ => exact ⟨s, rfl⟩
    exact ⟨s, by rw [hs]; rfl⟩
  · rintro ⟨s, hs⟩
    have hrun : run w t = run [s] t := hs.symm
    rw [run_word_unique ht hrun]
    simp

/-! ## Part C. Spatial slices are antichains -/

/-- **Each level of the Berggren causal set is an antichain.**  Two events at the same
depth are never causally related unless they are equal: the `3 ^ k` events of level `k`
form a discrete "spatial slice". -/
theorem level_antichain {t : Event} (ht : IsEvent t) {w w' : List BerggrenStep}
    (hlen : w.length = w'.length) (h : Causal (run w t) (run w' t)) : run w t = run w' t := by
  obtain ⟨p, hp⟩ := h
  have hcat : run (w ++ p) t = run w' t := by rw [run_append]; exact hp
  have hww : w ++ p = w' := run_word_unique ht hcat
  have hp0 : p = [] := by
    have : w.length + p.length = w'.length := by rw [← hww]; simp
    exact List.length_eq_zero_iff.mp (by omega)
  rw [← hp, hp0, run_nil]

/-- Distinct events of the same level are causally unrelated in *both* directions, and
(by cycle II) spacelike separated: the levels behave like spatial hypersurfaces. -/
theorem level_unrelated {t : Event} (ht : IsEvent t) {w w' : List BerggrenStep}
    (hlen : w.length = w'.length) (hne : run w t ≠ run w' t) :
    ¬ Causal (run w t) (run w' t) ∧ ¬ Causal (run w' t) (run w t) :=
  ⟨fun h => hne (level_antichain ht hlen h),
   fun h => hne (level_antichain ht hlen.symm h).symm⟩

/-! ## Part D. Freeness of the Berggren monoid -/

theorem vec_injective : Function.Injective vec := by
  intro t u h
  have h0 := congrFun h 0
  have h1 := congrFun h 1
  have h2 := congrFun h 2
  simp only [vec, Matrix.cons_val_zero, Matrix.cons_val_one] at h0 h1 h2
  obtain ⟨a, b, c⟩ := t
  obtain ⟨a', b', c'⟩ := u
  simp only at h0 h1 h2
  simp only [Prod.mk.injEq]
  refine ⟨h0, h1, ?_⟩
  simpa using h2

/-- **The Berggren monoid is free of rank 3.**  Distinct words give distinct Lorentz
matrices, so the submonoid of `O(2,1;ℤ)` generated by `B₁, B₂, B₃` is a free monoid on
three generators; this is exactly why the level sets have `3 ^ k` elements. -/
theorem wordMat_injective : Function.Injective wordMat := by
  intro w w' h
  have hact : vec (run w root) = vec (run w' root) := by
    rw [← wordMat_action, ← wordMat_action, h]
  exact run_word_unique root_isEvent (vec_injective hact)

/-- The three generators are distinct elements of `O(2,1;ℤ)`, and the word map is a monoid
antihomomorphism: the matrix of a concatenation is the reversed product. -/
theorem wordMat_append (w w' : List BerggrenStep) :
    wordMat (w ++ w') = wordMat w' * wordMat w := by
  induction w with
  | nil => simp [wordMat]
  | cons s w ih => rw [List.cons_append, wordMat, wordMat, ih, Matrix.mul_assoc]

end BerggrenCausalSet