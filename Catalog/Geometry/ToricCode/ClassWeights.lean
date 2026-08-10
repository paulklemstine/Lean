import ToricCode.Distance

/-!
# Weights of individual logical classes: the diagonal class costs `M + N`

`ToricCode.toric_distance` says the *minimum* over all logical operators of the
`M × N` torus is `min M N`.  This file refines the analysis to individual
homology classes.

The winding pair `(hWind z 0, vWind z 0) ∈ 𝔽₂²` is a complete invariant of the
homology class (`ToricCode.boundaries_eq_trivialWinding`).  There are therefore
three nonzero classes: "horizontal", "vertical" and "diagonal".  The two cut
families — the `M` column cuts (horizontal edges) and the `N` row cuts (vertical
edges) — are *disjoint* as sets of qubits, so a cycle in the diagonal class must
meet all `M + N` of them:

* `sum_le_weight_of_both_windings` : weight `≥ M + N` for the diagonal class;
* `hammingNorm_loopHV` : the sum of the row loop and the column loop has weight
  exactly `M + N`;
* `diagonal_class_distance` : the minimal weight in the diagonal class is
  exactly `M + N`.

So the logical weight structure of the toric code is *not* uniform across
classes: the distance `min M N` is attained only on an "axis" class, and the
diagonal class is strictly more expensive.
-/

open Matrix

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

/-- **The diagonal logical class has weight at least `M + N`.**  A cycle whose two
winding parities are both nonzero must meet each of the `M` column cuts and each
of the `N` row cuts, and these `M + N` cuts are pairwise disjoint sets of qubits. -/
theorem sum_le_weight_of_both_windings {z : Edge M N → F2}
    (hz : z ∈ cycles M N) (hh : hWind M N z 0 ≠ 0) (hv : vWind M N z 0 ≠ 0) :
    M + N ≤ hammingNorm z := by
  classical
  have hcyc : (d1 M N) *ᵥ z = 0 := by simpa [cycles, LinearMap.mem_ker] using hz
  have hcard : (Finset.univ : Finset (ZMod M ⊕ ZMod N)).card = M + N := by
    simp [ZMod.card]
  refine le_trans (le_of_eq hcard.symm) ?_
  rw [support_card_eq]
  refine Finset.card_le_card_of_surjOn
    (fun e : Edge M N => if e.1 then Sum.inr e.2.2 else Sum.inl e.2.1) ?_
  rintro (i | j) -
  · have hi : hWind M N z i ≠ 0 := by rw [hWind_const M N hcyc i]; exact hh
    have hex : ∃ y : ZMod N, z (false, (i, y)) ≠ 0 := by
      by_contra hc
      push_neg at hc
      exact hi (Finset.sum_eq_zero (fun y _ => hc y))
    obtain ⟨y, hy⟩ := hex
    exact ⟨(false, (i, y)), by simpa using hy, rfl⟩
  · have hj : vWind M N z j ≠ 0 := by rw [vWind_const M N hcyc j]; exact hv
    have hex : ∃ x : ZMod M, z (true, (x, j)) ≠ 0 := by
      by_contra hc
      push_neg at hc
      exact hj (Finset.sum_eq_zero (fun x _ => hc x))
    obtain ⟨x, hx⟩ := hex
    exact ⟨(true, (x, j)), by simpa using hx, rfl⟩

/-- The diagonal logical operator: the row loop plus the column loop. -/
def loopHV : Edge M N → F2 := loopH M N + loopV M N

lemma loopHV_cycle : (d1 M N) *ᵥ (loopHV M N) = 0 := by
  rw [loopHV, Matrix.mulVec_add, loopH_cycle, loopV_cycle, add_zero]

lemma loopHV_mem : loopHV M N ∈ cycles M N := by
  simpa [cycles, LinearMap.mem_ker] using loopHV_cycle M N

omit [NeZero M] in
lemma hWind_loopHV : hWind M N (loopHV M N) 0 = 1 := by
  simp only [loopHV, hWind, Pi.add_apply, Finset.sum_add_distrib]
  rw [show (∑ y : ZMod N, loopH M N (false, (0, y))) = hWind M N (loopH M N) 0 from rfl,
    show (∑ y : ZMod N, loopV M N (false, (0, y))) = hWind M N (loopV M N) 0 from rfl,
    hWind_loopH, hWind_loopV, add_zero]

omit [NeZero N] in
lemma vWind_loopHV : vWind M N (loopHV M N) 0 = 1 := by
  simp only [loopHV, vWind, Pi.add_apply, Finset.sum_add_distrib]
  rw [show (∑ x : ZMod M, loopH M N (true, (x, 0))) = vWind M N (loopH M N) 0 from rfl,
    show (∑ x : ZMod M, loopV M N (true, (x, 0))) = vWind M N (loopV M N) 0 from rfl,
    vWind_loopH, vWind_loopV, zero_add]

/-- The diagonal logical operator has weight exactly `M + N`. -/
lemma hammingNorm_loopHV : hammingNorm (loopHV M N) = M + N := by
  classical
  rw [support_card_eq]
  set F : ZMod M ⊕ ZMod N → Edge M N :=
    Sum.elim (fun x => ((false, (x, 0)) : Edge M N)) (fun y => ((true, (0, y)) : Edge M N))
      with hF
  have hinj : Function.Injective F := by
    rintro (a | a) (b | b) h <;> simp [hF] at h ⊢ <;> simp_all
  have hmem : ∀ b : Bool, ∀ (x : ZMod M) (y : ZMod N),
      loopHV M N (b, (x, y)) ≠ 0 ↔ (b = false ∧ y = 0) ∨ (b = true ∧ x = 0) := by
    intro b x y
    cases b
    · simp only [loopHV, Pi.add_apply, loopH, loopV]
      by_cases hy : y = 0 <;> simp [hy]
    · simp only [loopHV, Pi.add_apply, loopH, loopV]
      by_cases hx : x = 0 <;> simp [hx]
  have himg : (Finset.univ.filter (fun e : Edge M N => loopHV M N e ≠ 0))
      = Finset.univ.image F := by
    ext e
    obtain ⟨b, x, y⟩ := e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    rw [hmem]
    constructor
    · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
      · exact ⟨Sum.inl x, by simp [hF]⟩
      · exact ⟨Sum.inr y, by simp [hF]⟩
    · rintro ⟨s, hs⟩
      cases s with
      | inl a =>
        left
        simp only [hF, Sum.elim_inl, Prod.mk.injEq] at hs
        exact ⟨hs.1.symm, hs.2.2.symm⟩
      | inr a =>
        right
        simp only [hF, Sum.elim_inr, Prod.mk.injEq] at hs
        exact ⟨hs.1.symm, hs.2.1.symm⟩
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ]
  simp [ZMod.card]

/-- Weights of the logical operators lying in the diagonal class. -/
def diagonalWeights : Set ℕ :=
  {w | ∃ z : Edge M N → F2, z ∈ cycles M N ∧ hWind M N z 0 ≠ 0 ∧ vWind M N z 0 ≠ 0 ∧
    hammingNorm z = w}

/-- **The diagonal logical class has minimal weight exactly `M + N`.**  Since
`M + N > min M N`, the logical weight structure is class-dependent: the code
distance `min M N` is attained only on an axis class. -/
theorem diagonal_class_distance : sInf (diagonalWeights M N) = M + N := by
  have hmem : hammingNorm (loopHV M N) ∈ diagonalWeights M N :=
    ⟨loopHV M N, loopHV_mem M N, by rw [hWind_loopHV]; exact one_ne_zero,
      by rw [vWind_loopHV]; exact one_ne_zero, rfl⟩
  apply le_antisymm
  · have := Nat.sInf_le hmem
    rwa [hammingNorm_loopHV] at this
  · apply le_csInf ⟨_, hmem⟩
    rintro w ⟨z, hz, hh, hv, rfl⟩
    exact sum_le_weight_of_both_windings M N hz hh hv

/-- The diagonal class is *strictly* more expensive than the code distance. -/
theorem distance_lt_diagonal_class :
    distance M N < sInf (diagonalWeights M N) := by
  rw [toric_distance, diagonal_class_distance]
  have hM : 0 < M := Nat.pos_of_ne_zero (NeZero.ne M)
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  rcases min_cases M N with ⟨h, _⟩ | ⟨h, _⟩ <;> omega

end ToricCode