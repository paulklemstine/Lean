/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.GeneralFlags

/-!
# Schubert calculus VII: the flag variety and the Bruhat count `n!`

`Geometry.SchubertCalculus.GeneralFlags` shows that, for a pair of complete flags `F, G` in
general position, the subspaces transverse to the pair are in bijection with the subsets of
`{0, …, n-1}`.  Here the same analysis is carried out one level up, on the variety of
*complete flags*: a complete flag `H` is called transverse to `(F, G)` when each of its
members is.  The result is the flag-variety analogue of the Grassmannian count:

* `SchubertCalculus.flagOfPerm` : every permutation `w ∈ S_n` produces a transverse flag,
  namely the flag spanned by the jump lines `L_{w(0)}, L_{w(1)}, …`;
* `SchubertCalculus.eq_flagOfPerm_of_transverse` : conversely every transverse flag arises
  this way, and from a unique permutation (`flagOfPerm_injective`);
* `SchubertCalculus.flagOfPerm_one` / `SchubertCalculus.flagOfPerm_revPerm` : the two reference
  flags are themselves transverse, and correspond to the identity and to the longest
  permutation `j ↦ n-1-j`;
* `SchubertCalculus.ncard_transverse_flags_eq_factorial` : **there are exactly `n !` complete
  flags transverse to a pair of flags in general position.**  This is the point count of the
  big Bruhat cell — the Euler characteristic of the full flag variety — and the
  flag-variety counterpart of `ncard_transverse_eq_choose`.

The key geometric input is `subset_of_sup_lines_le`: because the jump lines are in staircase
position, containment of two spans of jump lines is *equivalent* to containment of the index
sets, so the lattice of transverse subspaces is a Boolean lattice on `n` generators.
-/

namespace SchubertCalculus

open Module Submodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]
variable {n : ℕ} {F G : CompleteFlag K V n}

omit [FiniteDimensional K V] in
/-- Two complete flags with the same members are equal. -/
lemma CompleteFlag.ext_part {H₁ H₂ : CompleteFlag K V n} (h : ∀ i, H₁.part i = H₂.part i) :
    H₁ = H₂ := by
  obtain ⟨p₁, m₁, f₁, t₁⟩ := H₁
  obtain ⟨p₂, m₂, f₂, t₂⟩ := H₂
  have hp : p₁ = p₂ := funext h
  subst hp
  rfl

omit [FiniteDimensional K V] in
lemma CompleteFlag.part_eq_top_of_ge (H : CompleteFlag K V n) {i : ℕ} (hi : n ≤ i) :
    H.part i = ⊤ := by
  have := H.mono hi
  rw [H.part_top] at this
  exact top_le_iff.mp this

/-- **Staircase rigidity.** For flags in general position, one span of jump lines is contained
in another exactly when the index sets are. -/
theorem subset_of_sup_lines_le (hFG : Opposite F G) {S T : Finset ℕ}
    (hS : S ⊆ Finset.range n) (hT : T ⊆ Finset.range n)
    (h : (S.sup (line F G) : Submodule K V) ≤ (T.sup (line F G) : Submodule K V)) : S ⊆ T := by
  classical
  intro s hsS
  by_contra hsT
  have hline : (line F G s : Submodule K V) ≤ (T.sup (line F G) : Submodule K V) :=
    le_trans (Finset.le_sup hsS) h
  have hins : ((insert s T).sup (line F G) : Submodule K V)
      = (T.sup (line F G) : Submodule K V) := by
    rw [Finset.sup_insert]
    exact sup_eq_right.mpr hline
  have hsub : insert s T ⊆ Finset.range n := by
    intro x hx
    rcases Finset.mem_insert.mp hx with rfl | hx
    · exact hS hsS
    · exact hT hx
  have h1 : finrank K (((insert s T).sup (line F G) : Submodule K V)) = (insert s T).card :=
    finrank_sup_lines hFG _ hsub
  rw [hins, finrank_sup_lines hFG T hT, Finset.card_insert_of_notMem hsT] at h1
  omega

/-- All the jump lines together span the whole space. -/
theorem sup_lines_range_eq_top (hFG : Opposite F G) :
    ((Finset.range n).sup (line F G) : Submodule K V) = ⊤ := by
  have h := finrank_sup_lines hFG (Finset.range n) (subset_refl _)
  rw [Finset.card_range] at h
  have hV : finrank K V = n := finrank_top_eq F
  exact Submodule.eq_top_of_finrank_eq (by rw [h, hV])

/-- A complete flag is *transverse* to the pair `(F, G)` when each of its members is. -/
def IsTransverseFlag (F G H : CompleteFlag K V n) : Prop :=
  ∀ i ≤ n, IsTransverseFlags F G (H.part i)

/-! ### The jump chain of a permutation -/

/-- The `i`-th member of the jump chain of a permutation `w`: the indices `w 0, …, w (i-1)`. -/
def permSet {n : ℕ} (w : Equiv.Perm (Fin n)) (i : ℕ) : Finset ℕ :=
  (Finset.univ.filter fun j : Fin n => (j : ℕ) < i).image fun j => ((w j : Fin n) : ℕ)

lemma permSet_subset {n : ℕ} (w : Equiv.Perm (Fin n)) (i : ℕ) :
    permSet w i ⊆ Finset.range n := by
  intro x hx
  obtain ⟨j, _, rfl⟩ := Finset.mem_image.mp hx
  exact Finset.mem_range.mpr (w j).isLt

lemma mem_permSet {n : ℕ} (w : Equiv.Perm (Fin n)) (i x : ℕ) :
    x ∈ permSet w i ↔ ∃ j : Fin n, (j : ℕ) < i ∧ ((w j : Fin n) : ℕ) = x := by
  simp [permSet]

private lemma card_filter_val_lt {n : ℕ} {i : ℕ} (hi : i ≤ n) :
    (Finset.univ.filter fun j : Fin n => (j : ℕ) < i).card = i := by
  classical
  have himg : (Finset.univ.filter fun j : Fin n => (j : ℕ) < i).image Fin.val
      = Finset.range i := by
    ext x
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_range]
    constructor
    · rintro ⟨j, hj, rfl⟩; exact hj
    · intro hx; exact ⟨⟨x, by omega⟩, hx, rfl⟩
  have hc := congrArg Finset.card himg
  rwa [Finset.card_image_of_injective _ Fin.val_injective, Finset.card_range] at hc

lemma card_permSet {n : ℕ} (w : Equiv.Perm (Fin n)) {i : ℕ} (hi : i ≤ n) :
    (permSet w i).card = i := by
  have hinj : Function.Injective fun j : Fin n => ((w j : Fin n) : ℕ) :=
    fun a b h => w.injective (Fin.val_injective h)
  rw [permSet, Finset.card_image_of_injective _ hinj]
  exact card_filter_val_lt hi

lemma permSet_mono {n : ℕ} (w : Equiv.Perm (Fin n)) {i j : ℕ} (h : i ≤ j) :
    permSet w i ⊆ permSet w j := by
  intro x hx
  obtain ⟨a, ha, rfl⟩ := (mem_permSet w i x).mp hx
  exact (mem_permSet w j _).mpr ⟨a, by omega, rfl⟩

lemma permSet_top {n : ℕ} (w : Equiv.Perm (Fin n)) : permSet w n = Finset.range n := by
  ext x
  rw [mem_permSet, Finset.mem_range]
  constructor
  · rintro ⟨j, _, rfl⟩; exact (w j).isLt
  · intro hx
    exact ⟨w.symm ⟨x, hx⟩, (w.symm ⟨x, hx⟩).isLt, by simp⟩

/-- Consecutive members of the jump chain of `w` differ by the single index `w j`. -/
lemma permSet_succ_sdiff {n : ℕ} (w : Equiv.Perm (Fin n)) {j : ℕ} (hj : j < n) :
    permSet w (j + 1) \ permSet w j = {((w ⟨j, hj⟩ : Fin n) : ℕ)} := by
  classical
  ext x
  simp only [Finset.mem_sdiff, Finset.mem_singleton, mem_permSet]
  constructor
  · rintro ⟨⟨a, ha, rfl⟩, hnot⟩
    have haj : (a : ℕ) = j := by
      by_contra hne
      exact hnot ⟨a, by omega, rfl⟩
    congr 2
    exact Fin.ext haj
  · rintro rfl
    refine ⟨⟨⟨j, hj⟩, by simp, rfl⟩, ?_⟩
    rintro ⟨a, ha, heq⟩
    have : a = (⟨j, hj⟩ : Fin n) := w.injective (Fin.val_injective heq)
    rw [this] at ha
    simp at ha

/-! ### From permutations to transverse flags and back -/

/-- The complete flag attached to a permutation: its `i`-th member is spanned by the jump
lines `L_{w 0}, …, L_{w (i-1)}`. -/
noncomputable def flagOfPerm (hFG : Opposite F G) (w : Equiv.Perm (Fin n)) :
    CompleteFlag K V n where
  part i := ((permSet w (min i n)).sup (line F G) : Submodule K V)
  mono := fun _ _ hab => Finset.sup_mono (permSet_mono w (by omega))
  finrank_part := fun i hi => by
    rw [min_eq_left hi, finrank_sup_lines hFG _ (permSet_subset w i), card_permSet w hi]
  part_top := by
    simp only [min_self, permSet_top]
    exact sup_lines_range_eq_top hFG

lemma flagOfPerm_part (hFG : Opposite F G) (w : Equiv.Perm (Fin n)) {i : ℕ} (hi : i ≤ n) :
    (flagOfPerm hFG w).part i = ((permSet w i).sup (line F G) : Submodule K V) := by
  simp only [flagOfPerm, min_eq_left hi]

theorem isTransverseFlag_flagOfPerm (hFG : Opposite F G) (w : Equiv.Perm (Fin n)) :
    IsTransverseFlag F G (flagOfPerm hFG w) := by
  intro i hi
  rw [flagOfPerm_part hFG w hi]
  exact isTransverseFlags_sup_lines hFG _ (permSet_subset w i)

theorem jumpSet_flagOfPerm (hFG : Opposite F G) (w : Equiv.Perm (Fin n)) {i : ℕ} (hi : i ≤ n) :
    F.jumpSet ((flagOfPerm hFG w).part i) = permSet w i := by
  rw [flagOfPerm_part hFG w hi]
  exact jumpSet_sup_lines hFG _ (permSet_subset w i)

/-- Distinct permutations give distinct transverse flags. -/
theorem flagOfPerm_injective (hFG : Opposite F G) :
    Function.Injective (flagOfPerm (K := K) (V := V) (n := n) (F := F) (G := G) hFG) := by
  intro w w' hww'
  have hsets : ∀ i ≤ n, permSet w i = permSet w' i := by
    intro i hi
    rw [← jumpSet_flagOfPerm hFG w hi, ← jumpSet_flagOfPerm hFG w' hi, hww']
  ext a
  have hj : (a : ℕ) < n := a.isLt
  have h1 := permSet_succ_sdiff w hj
  have h2 := permSet_succ_sdiff w' hj
  rw [hsets ((a : ℕ) + 1) hj, hsets (a : ℕ) hj.le, h2] at h1
  have : ((w' ⟨(a : ℕ), hj⟩ : Fin n) : ℕ) = ((w ⟨(a : ℕ), hj⟩ : Fin n) : ℕ) :=
    Finset.singleton_injective h1
  simpa [Fin.eta] using this.symm

/-- **Every transverse complete flag comes from a permutation.** -/
theorem eq_flagOfPerm_of_transverse (hFG : Opposite F G) {H : CompleteFlag K V n}
    (hH : IsTransverseFlag F G H) : ∃ w : Equiv.Perm (Fin n), flagOfPerm hFG w = H := by
  classical
  set J : ℕ → Finset ℕ := fun i => F.jumpSet (H.part i) with hJdef
  have hJsub : ∀ i, J i ⊆ Finset.range n := fun i => F.jumpSet_subset _
  have hJcard : ∀ i ≤ n, (J i).card = i := by
    intro i hi
    rw [hJdef]
    simp only
    rw [F.card_jumpSet (H.part i), H.finrank_part i hi]
  have hJsup : ∀ i ≤ n, H.part i = ((J i).sup (line F G) : Submodule K V) := by
    intro i hi
    exact transverse_eq_sup_lines hFG (hH i hi)
  have hJmono : ∀ i j, i ≤ j → j ≤ n → J i ⊆ J j := by
    intro i j hij hj
    refine subset_of_sup_lines_le hFG (hJsub i) (hJsub j) ?_
    rw [← hJsup i (le_trans hij hj), ← hJsup j hj]
    exact H.mono hij
  have hex : ∀ a : Fin n, ∃ x : Fin n, J ((a : ℕ) + 1) \ J (a : ℕ) = {(x : ℕ)} := by
    intro a
    have ha : (a : ℕ) < n := a.isLt
    have hsub := hJmono (a : ℕ) ((a : ℕ) + 1) (by omega) ha
    have hcard : (J ((a : ℕ) + 1) \ J (a : ℕ)).card = 1 := by
      rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hsub, hJcard ((a : ℕ) + 1) ha,
        hJcard (a : ℕ) ha.le]
      omega
    obtain ⟨x, hx⟩ := Finset.card_eq_one.mp hcard
    have hxmem : x ∈ J ((a : ℕ) + 1) := by
      have : x ∈ J ((a : ℕ) + 1) \ J (a : ℕ) := by rw [hx]; exact Finset.mem_singleton_self x
      exact (Finset.mem_sdiff.mp this).1
    exact ⟨⟨x, Finset.mem_range.mp (hJsub _ hxmem)⟩, hx⟩
  choose f hf using hex
  have hfmem : ∀ a : Fin n, ((f a : Fin n) : ℕ) ∈ J ((a : ℕ) + 1) := by
    intro a
    have : ((f a : Fin n) : ℕ) ∈ J ((a : ℕ) + 1) \ J (a : ℕ) := by
      rw [hf a]; exact Finset.mem_singleton_self _
    exact (Finset.mem_sdiff.mp this).1
  have hfnot : ∀ a : Fin n, ((f a : Fin n) : ℕ) ∉ J (a : ℕ) := by
    intro a
    have : ((f a : Fin n) : ℕ) ∈ J ((a : ℕ) + 1) \ J (a : ℕ) := by
      rw [hf a]; exact Finset.mem_singleton_self _
    exact (Finset.mem_sdiff.mp this).2
  have hfinj : Function.Injective f := by
    intro a b hab
    by_contra hne
    have hne' : (a : ℕ) ≠ (b : ℕ) := fun h => hne (Fin.ext h)
    rcases lt_or_gt_of_ne hne' with h | h
    · exact hfnot b (hJmono ((a : ℕ) + 1) (b : ℕ) (by omega) b.isLt.le (hab ▸ hfmem a))
    · exact hfnot a (hJmono ((b : ℕ) + 1) (a : ℕ) (by omega) a.isLt.le (hab ▸ hfmem b))
  have hbij := Finite.injective_iff_bijective.mp hfinj
  refine ⟨Equiv.ofBijective f hbij, ?_⟩
  set w : Equiv.Perm (Fin n) := Equiv.ofBijective f hbij with hwdef
  have hwf : ∀ a : Fin n, w a = f a := fun a => rfl
  have hpermJ : ∀ i ≤ n, permSet w i = J i := by
    intro i hi
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro x hx
      obtain ⟨a, ha, rfl⟩ := (mem_permSet w i x).mp hx
      rw [hwf a]
      exact hJmono ((a : ℕ) + 1) i (by omega) hi (hfmem a)
    · rw [hJcard i hi, card_permSet w hi]
  refine CompleteFlag.ext_part fun i => ?_
  rcases le_or_gt i n with hi | hi
  · rw [flagOfPerm_part hFG w hi, hpermJ i hi, ← hJsup i hi]
  · rw [H.part_eq_top_of_ge hi.le]
    show ((permSet w (min i n)).sup (line F G) : Submodule K V) = ⊤
    rw [min_eq_right hi.le, permSet_top]
    exact sup_lines_range_eq_top hFG

/-! ### The two reference flags are the extreme points of the big cell -/

lemma permSet_one {n : ℕ} {i : ℕ} (hi : i ≤ n) :
    permSet (1 : Equiv.Perm (Fin n)) i = Finset.range i := by
  ext x
  rw [mem_permSet, Finset.mem_range]
  constructor
  · rintro ⟨j, hj, rfl⟩; simpa using hj
  · intro hx
    exact ⟨⟨x, by omega⟩, hx, by simp⟩

lemma permSet_revPerm {n : ℕ} {i : ℕ} (hi : i ≤ n) :
    permSet (Fin.revPerm : Equiv.Perm (Fin n)) i = Finset.Ico (n - i) n := by
  ext x
  rw [mem_permSet, Finset.mem_Ico]
  constructor
  · rintro ⟨j, hj, rfl⟩
    have hjn : (j : ℕ) < n := j.isLt
    have hval : ((Fin.revPerm j : Fin n) : ℕ) = n - 1 - (j : ℕ) := by
      simp [Fin.revPerm, Fin.rev]; omega
    rw [hval]
    omega
  · rintro ⟨h1, h2⟩
    refine ⟨⟨n - 1 - x, by omega⟩, by simp; omega, ?_⟩
    have hval : ((Fin.revPerm (⟨n - 1 - x, by omega⟩ : Fin n) : Fin n) : ℕ)
        = n - 1 - (n - 1 - x) := by
      simp [Fin.revPerm, Fin.rev]; omega
    rw [hval]
    omega

/-- The first reference flag is itself transverse: it is the flag of the identity
permutation. -/
theorem flagOfPerm_one (hFG : Opposite F G) : flagOfPerm hFG 1 = F := by
  refine CompleteFlag.ext_part fun i => ?_
  rcases le_or_gt i n with hi | hi
  · rw [flagOfPerm_part hFG 1 hi, permSet_one hi]
    refine Submodule.eq_of_le_of_finrank_eq ?_ ?_
    · exact sup_lines_le_part_F _ fun s hs => Finset.mem_range.mp hs
    · rw [finrank_sup_lines hFG _ (fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hi)), Finset.card_range,
        F.finrank_part i hi]
  · rw [F.part_eq_top_of_ge hi.le]
    show ((permSet 1 (min i n)).sup (line F G) : Submodule K V) = ⊤
    rw [min_eq_right hi.le, permSet_top]
    exact sup_lines_range_eq_top hFG

/-- The second reference flag is the flag of the longest permutation: `F` and `G` are the two
extreme points of the big cell. -/
theorem flagOfPerm_revPerm (hFG : Opposite F G) : flagOfPerm hFG Fin.revPerm = G := by
  refine CompleteFlag.ext_part fun i => ?_
  rcases le_or_gt i n with hi | hi
  · rw [flagOfPerm_part hFG Fin.revPerm hi, permSet_revPerm hi]
    refine Submodule.eq_of_le_of_finrank_eq ?_ ?_
    · have hle : ((Finset.Ico (n - i) n).sup (line F G) : Submodule K V)
          ≤ G.part (n - (n - i)) :=
        sup_lines_le_part_G _ fun s hs => (Finset.mem_Ico.mp hs).1
      rwa [show n - (n - i) = i by omega] at hle
    · rw [finrank_sup_lines hFG _ (fun x hx => Finset.mem_range.mpr (Finset.mem_Ico.mp hx).2),
        Nat.card_Ico, G.finrank_part i hi]
      omega
  · rw [G.part_eq_top_of_ge hi.le]
    show ((permSet Fin.revPerm (min i n)).sup (line F G) : Submodule K V) = ⊤
    rw [min_eq_right hi.le, permSet_top]
    exact sup_lines_range_eq_top hFG

/-- **The Bruhat count for the flag variety.**  For a pair of complete flags in general
position in an `n`-dimensional space there are exactly `n !` complete flags transverse to the
pair — one for each permutation of `{0, …, n-1}`.  This is the flag-variety analogue of the
`n.choose k` count on the Grassmannian, and the point count of the big Bruhat cell. -/
theorem ncard_transverse_flags_eq_factorial (hFG : Opposite F G) :
    {H : CompleteFlag K V n | IsTransverseFlag F G H}.ncard = Nat.factorial n := by
  classical
  have himg : {H : CompleteFlag K V n | IsTransverseFlag F G H}
      = Set.range (flagOfPerm hFG) := by
    ext H
    simp only [Set.mem_setOf_eq, Set.mem_range]
    constructor
    · intro hH; exact eq_flagOfPerm_of_transverse hFG hH
    · rintro ⟨w, rfl⟩; exact isTransverseFlag_flagOfPerm hFG w
  rw [himg, ← Set.image_univ, (flagOfPerm_injective hFG).injOn.ncard_image, Set.ncard_univ,
    Nat.card_eq_fintype_card, Fintype.card_perm, Fintype.card_fin]

end SchubertCalculus