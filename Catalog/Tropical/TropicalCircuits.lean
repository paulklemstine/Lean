import Mathlib
import Tropical.TropicalLinearSpaceElimination

/-!
# Circuits of a tropical linear space: the underlying matroid

The vector elimination axiom proved in
`Catalog/Tropical/TropicalLinearSpaceElimination.lean` is the tropical
(valuated) form of the matroid vector axioms.  This file extracts the purely
combinatorial consequence: the *minimal supports* of a tropical linear space
satisfy the **matroid circuit elimination axiom**.  This is the bridge from
tropical algebra to matroid combinatorics.

Main results:

* `exists_isCircuit_subset` : every nonzero member of a tropical linear space
  contains a circuit in its support (finite ground set).
* `support_elimination_ne_zero` : the strengthened support elimination, in which
  the eliminated vector is guaranteed nonzero because it retains a coordinate
  belonging to only one of the two inputs.
* `circuit_elimination` : **circuit elimination**: for circuits `C₁ ≠ C₂` and
  `e ∈ C₁ ∩ C₂` there is a circuit inside `(C₁ ∪ C₂) \ {e}`.
* `tropVanishing_isCircuit_iff` : for a tropical hyperplane with finite
  coefficients the circuits are exactly the two-element sets, i.e. the underlying
  matroid is the uniform matroid `U_{n-1,n}`.
-/

namespace TropicalElimination

open Classical in
/-- The support of a tropical vector as a `Finset` of a finite ground set. -/
noncomputable def suppFinset {E : Type*} [Fintype E] (x : E → TT) : Finset E :=
  Finset.univ.filter fun i => x i ≠ ⊤

variable {E : Type*} [Fintype E]

theorem mem_suppFinset {x : E → TT} {i : E} : i ∈ suppFinset x ↔ x i ≠ ⊤ := by
  classical
  simp [suppFinset]

theorem suppFinset_eq_empty_iff {x : E → TT} : suppFinset x = ∅ ↔ x = tropZero E := by
  classical
  constructor
  · intro h
    funext i
    by_contra hi
    exact absurd (mem_suppFinset.mpr hi) (by rw [h]; exact Finset.notMem_empty i)
  · intro h
    subst h
    ext i
    simp [suppFinset, tropZero]

theorem suppFinset_nonempty {x : E → TT} (hx : x ≠ tropZero E) : (suppFinset x).Nonempty := by
  classical
  rw [Finset.nonempty_iff_ne_empty]
  intro h
  exact hx (suppFinset_eq_empty_iff.mp h)

/-- A circuit of a tropical linear space: the support of a nonzero member which
is minimal among supports of nonzero members. -/
def IsCircuit (V : Set (E → TT)) (C : Finset E) : Prop :=
  (∃ x ∈ V, x ≠ tropZero E ∧ suppFinset x = C) ∧
    ∀ y ∈ V, y ≠ tropZero E → suppFinset y ⊆ C → suppFinset y = C

theorem IsCircuit.nonempty {V : Set (E → TT)} {C : Finset E} (hC : IsCircuit V C) :
    C.Nonempty := by
  obtain ⟨⟨x, _, hx0, hxC⟩, -⟩ := hC
  rw [← hxC]
  exact suppFinset_nonempty hx0

/-- Every nonzero member of a tropical linear space contains a circuit in its
support. -/
theorem exists_isCircuit_subset {V : Set (E → TT)} {x : E → TT} (hx : x ∈ V)
    (hx0 : x ≠ tropZero E) : ∃ C, IsCircuit V C ∧ C ⊆ suppFinset x := by
  classical
  have hex : ∃ n, ∃ y ∈ V, y ≠ tropZero E ∧ suppFinset y ⊆ suppFinset x ∧
      (suppFinset y).card = n := ⟨_, x, hx, hx0, Finset.Subset.refl _, rfl⟩
  obtain ⟨y, hyV, hy0, hysub, hycard⟩ := Nat.find_spec hex
  refine ⟨suppFinset y, ⟨⟨y, hyV, hy0, rfl⟩, ?_⟩, hysub⟩
  intro z hzV hz0 hzsub
  have hzcard : (suppFinset y).card ≤ (suppFinset z).card := by
    by_contra hlt
    push_neg at hlt
    have : ∃ m ∈ Set.Iio (Nat.find hex), ∃ w ∈ V, w ≠ tropZero E ∧
        suppFinset w ⊆ suppFinset x ∧ (suppFinset w).card = m :=
      ⟨(suppFinset z).card, by rw [Set.mem_Iio, ← hycard]; exact hlt,
        z, hzV, hz0, hzsub.trans hysub, rfl⟩
    obtain ⟨m, hm, hw⟩ := this
    exact Nat.find_min hex hm hw
  exact Finset.eq_of_subset_of_card_le hzsub hzcard

section Elimination

variable [DecidableEq E] {V : Set (E → TT)}

/-- Strengthened support elimination: if the two inputs have a common support
coordinate `e` and `x` has a support coordinate `f` outside the support of `y`,
then the eliminated vector is nonzero, keeping `f` in its support. -/
theorem support_elimination_ne_zero (hV : IsTropicalLinearSpace V) {x y : E → TT}
    (hx : x ∈ V) (hy : y ∈ V) {e f : E} (hxe : x e ≠ ⊤) (hye : y e ≠ ⊤)
    (hxf : x f ≠ ⊤) (hyf : y f = ⊤) :
    ∃ z ∈ V, z ≠ tropZero E ∧ z f ≠ ⊤ ∧ z e = ⊤ ∧
      suppFinset z ⊆ (suppFinset x ∪ suppFinset y).erase e := by
  classical
  obtain ⟨p, hp⟩ : ∃ p : ℚ, x e = (p : TT) := ⟨(x e).untop hxe, by simp⟩
  obtain ⟨r, hr⟩ : ∃ r : ℚ, y e = (r : TT) := ⟨(y e).untop hye, by simp⟩
  set y' : E → TT := tropSMul ((p - r : ℚ) : TT) y with hy'
  have hy'mem : y' ∈ V := hV.semimodule.smul_mem _ hy
  have hy'e : y' e = x e := by
    rw [hy', tropSMul, hr, ← WithTop.coe_add, hp]
    norm_num
  have hy'f : y' f = ⊤ := by rw [hy', tropSMul, hyf, add_top]
  have hy'top : ∀ i, y' i = ⊤ ↔ y i = ⊤ := by
    intro i
    rw [hy', tropSMul]
    constructor
    · intro h
      by_contra hi
      obtain ⟨s, hs⟩ : ∃ s : ℚ, y i = (s : TT) := ⟨(y i).untop hi, by simp⟩
      rw [hs, ← WithTop.coe_add] at h
      exact WithTop.coe_ne_top h
    · intro h; rw [h, add_top]
  obtain ⟨z, hzV, hze, hzge, hzeq⟩ :=
    hV.elimination x hx y' hy'mem e hy'e.symm hxe
  have hzf : z f = x f := by
    have hne : x f ≠ y' f := by rw [hy'f]; exact hxf
    rw [hzeq f hne, hy'f, min_eq_left le_top]
  refine ⟨z, hzV, ?_, ?_, hze, ?_⟩
  · intro h
    rw [h] at hzf
    exact hxf hzf.symm
  · rw [hzf]; exact hxf
  · intro i hi
    have hi' : z i ≠ ⊤ := mem_suppFinset.mp hi
    refine Finset.mem_erase.mpr ⟨?_, ?_⟩
    · rintro rfl
      exact hi' hze
    · rw [Finset.mem_union]
      by_contra hmem
      push_neg at hmem
      have hxi : x i = ⊤ := by
        by_contra hxi
        exact hmem.1 (mem_suppFinset.mpr hxi)
      have hyi : y i = ⊤ := by
        by_contra hyi
        exact hmem.2 (mem_suppFinset.mpr hyi)
      have hy'i : y' i = ⊤ := (hy'top i).mpr hyi
      have h := hzge i
      rw [hxi, hy'i, min_self] at h
      exact hi' (top_le_iff.mp h)

/-- **Circuit elimination.**  The circuits of a tropical linear space satisfy the
matroid circuit elimination axiom, so they are the circuits of a matroid on the
ground set `E`. -/
theorem circuit_elimination (hV : IsTropicalLinearSpace V) {C₁ C₂ : Finset E}
    (h₁ : IsCircuit V C₁) (h₂ : IsCircuit V C₂) (hne : C₁ ≠ C₂) {e : E}
    (he₁ : e ∈ C₁) (he₂ : e ∈ C₂) :
    ∃ C₃, IsCircuit V C₃ ∧ C₃ ⊆ (C₁ ∪ C₂).erase e := by
  classical
  obtain ⟨⟨x, hxV, hx0, hxC⟩, hmin₁⟩ := h₁
  obtain ⟨⟨y, hyV, hy0, hyC⟩, hmin₂⟩ := h₂
  -- `C₁` is not contained in `C₂`, by minimality of `C₂`
  obtain ⟨f, hfC₁, hfC₂⟩ : ∃ f ∈ C₁, f ∉ C₂ := by
    by_contra hsub
    push_neg at hsub
    exact hne (hxC ▸ hmin₂ x hxV hx0 (hxC ▸ hsub))
  obtain ⟨z, hzV, hz0, -, -, hzsub⟩ :=
    support_elimination_ne_zero hV hxV hyV
      (mem_suppFinset.mp (hxC ▸ he₁)) (mem_suppFinset.mp (hyC ▸ he₂))
      (mem_suppFinset.mp (hxC ▸ hfC₁))
      (by
        by_contra hyf
        exact hfC₂ (hyC ▸ mem_suppFinset.mpr hyf))
  obtain ⟨C₃, hC₃, hC₃sub⟩ := exists_isCircuit_subset hzV hz0
  refine ⟨C₃, hC₃, hC₃sub.trans ?_⟩
  rw [hxC, hyC] at hzsub
  exact hzsub

end Elimination

section Uniform

variable [Nonempty E] (c : E → TT) (hc : ∀ i, c i ≠ ⊤)

include hc

theorem two_le_card_of_isCircuit {C : Finset E} (hC : IsCircuit (tropVanishing c) C) :
    2 ≤ C.card := by
  classical
  obtain ⟨⟨x, hxV, hx0, hxC⟩, -⟩ := hC
  obtain ⟨i, j, hij, hxi, hxj⟩ := card_support_ge_two c hc hxV hx0
  have hsub : ({i, j} : Finset E) ⊆ C := by
    intro k hk
    rw [Finset.mem_insert, Finset.mem_singleton] at hk
    rcases hk with rfl | rfl
    · exact hxC ▸ mem_suppFinset.mpr hxi
    · exact hxC ▸ mem_suppFinset.mpr hxj
  have : ({i, j} : Finset E).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton]
  exact this ▸ Finset.card_le_card hsub

/-- **The matroid of a tropical hyperplane is uniform.**  For a tropical
hyperplane with everywhere-finite coefficients, the circuits are exactly the
two-element subsets: the underlying matroid is `U_{n-1,n}`. -/
theorem tropVanishing_isCircuit_iff [DecidableEq E] {C : Finset E} :
    IsCircuit (tropVanishing c) C ↔ C.card = 2 := by
  classical
  constructor
  · intro hC
    have h2 := two_le_card_of_isCircuit c hc hC
    obtain ⟨i, hi, j, hj, hij⟩ := Finset.one_lt_card.mp (show 1 < C.card by omega)
    obtain ⟨x, hxV, hxsupp⟩ := exists_mem_support_eq_pair c hc hij
    have hx0 : x ≠ tropZero E := by
      intro h
      have : (i : E) ∈ supp x := by rw [hxsupp]; exact Set.mem_insert _ _
      rw [h] at this
      exact this rfl
    have hsuppF : suppFinset x = {i, j} := by
      ext k
      rw [mem_suppFinset]
      constructor
      · intro hk
        have hmem : k ∈ supp x := hk
        rw [hxsupp] at hmem
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hmem
        rcases hmem with rfl | rfl
        · exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self _)
      · intro hk
        rw [Finset.mem_insert, Finset.mem_singleton] at hk
        have : k ∈ supp x := by
          rw [hxsupp]
          rcases hk with rfl | rfl
          · exact Set.mem_insert _ _
          · exact Set.mem_insert_of_mem _ rfl
        exact this
    have hsub : suppFinset x ⊆ C := by
      rw [hsuppF]
      intro k hk
      rw [Finset.mem_insert, Finset.mem_singleton] at hk
      rcases hk with rfl | rfl
      · exact hi
      · exact hj
    have := hC.2 x hxV hx0 hsub
    rw [← this, hsuppF, Finset.card_insert_of_notMem (by simpa using hij),
      Finset.card_singleton]
  · intro hcard
    obtain ⟨i, hi, j, hj, hij⟩ := Finset.one_lt_card.mp (show 1 < C.card by omega)
    obtain ⟨x, hxV, hxsupp⟩ := exists_mem_support_eq_pair c hc hij
    have hpairC : ({i, j} : Finset E) = C := by
      refine Finset.eq_of_subset_of_card_le ?_ ?_
      · intro k hk
        rw [Finset.mem_insert, Finset.mem_singleton] at hk
        rcases hk with rfl | rfl
        · exact hi
        · exact hj
      · rw [hcard, Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton]
    have hsuppF : suppFinset x = C := by
      rw [← hpairC]
      ext k
      rw [mem_suppFinset]
      constructor
      · intro hk
        have hmem : k ∈ supp x := hk
        rw [hxsupp] at hmem
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hmem
        rcases hmem with rfl | rfl
        · exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self _)
      · intro hk
        rw [Finset.mem_insert, Finset.mem_singleton] at hk
        have hmem : k ∈ supp x := by
          rw [hxsupp]
          rcases hk with rfl | rfl
          · exact Set.mem_insert _ _
          · exact Set.mem_insert_of_mem _ rfl
        exact hmem
    have hx0 : x ≠ tropZero E := by
      intro h
      have hmem : (i : E) ∈ supp x := by rw [hxsupp]; exact Set.mem_insert _ _
      rw [h] at hmem
      exact hmem rfl
    refine ⟨⟨x, hxV, hx0, hsuppF⟩, ?_⟩
    intro y hyV hy0 hysub
    obtain ⟨k, l, hkl, hyk, hyl⟩ := card_support_ge_two c hc hyV hy0
    have hklsub : ({k, l} : Finset E) ⊆ suppFinset y := by
      intro m hm
      rw [Finset.mem_insert, Finset.mem_singleton] at hm
      rcases hm with rfl | rfl
      · exact mem_suppFinset.mpr hyk
      · exact mem_suppFinset.mpr hyl
    have h2 : 2 ≤ (suppFinset y).card := by
      have : ({k, l} : Finset E).card = 2 := by
        rw [Finset.card_insert_of_notMem (by simpa using hkl), Finset.card_singleton]
      exact this ▸ Finset.card_le_card hklsub
    exact Finset.eq_of_subset_of_card_le hysub (by omega)

end Uniform

end TropicalElimination