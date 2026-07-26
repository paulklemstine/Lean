import Mathlib

/-!
# Finite Stone Representation for Closure-Stable Proof States

This file proves that the fixed points of a complement-stable closure operator
on `Set α` (where `α` is finite) are order-isomorphic to `Set β` for some
finite type `β` canonically built as a quotient of `α`.

This is a finite version of Stone's representation theorem: it shows that
complement-stable finite closure systems are exactly finite Boolean semantic
universes (powerset algebras), connecting closure-based proof states to
finite Stone spaces.

## Main results

* `fixedpoints_inter` — Fixed points are closed under intersection.
* `fixedpoints_univ` — `Set.univ` is always a fixed point.
* `fixedpoints_empty` — Under complement stability, `∅` is a fixed point.
* `fixedpoints_union` — Under complement stability, fixed points are closed under union.
* `classOf_fixed` — Each equivalence class is a fixed point.
* `preimage_quot_fixed` — Preimage of any set under the quotient map is a fixed point.
* `finite_fixedpoints_stone_representation` — **Main theorem**: Fixed points ≃o Set β.

## References

Builds on `kernel_fixedpoint_representation_pred` and `fixedpoints_closed_under_meet`
from `Catalog.Logic.ParallelClosureCanonicalization`, and on
`fixed_points_card_le` from `Catalog.Cryptography.EMLCrypto.ClosureOneWay`.
-/

noncomputable section
open Set Classical

namespace FiniteStoneClosure

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Basic Closure Properties -/

omit [Fintype α] [DecidableEq α] in
/-- Fixed points of a monotone, extensive closure operator are closed under intersection. -/
theorem fixedpoints_inter
    {O : Set α → Set α} (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    {s t : Set α} (hs : O s = s) (ht : O t = t) :
    O (s ∩ t) = s ∩ t := by
  have h_subset : O (s ∩ t) ⊆ s ∩ t := by
    exact Set.subset_inter
      (h_mono Set.inter_subset_left |> Set.Subset.trans <| hs.symm ▸ Set.Subset.refl _)
      (h_mono Set.inter_subset_right |> Set.Subset.trans <| ht.symm ▸ Set.Subset.refl _)
  grind

omit [Fintype α] [DecidableEq α] in
/-- `Set.univ` is a fixed point of any extensive operator on `Set α`. -/
theorem fixedpoints_univ
    {O : Set α → Set α} (h_ext : ∀ s, s ⊆ O s) :
    O Set.univ = Set.univ := by
  exact Set.eq_univ_of_forall fun x => h_ext univ (Set.mem_univ x)

omit [Fintype α] [DecidableEq α] in
/-- Under complement stability, `∅` is a fixed point. -/
theorem fixedpoints_empty
    {O : Set α → Set α} (h_ext : ∀ s, s ⊆ O s)
    (h_compl : ∀ s, O s = s → O sᶜ = sᶜ) :
    O ∅ = ∅ := by
  simpa using h_compl _ (fixedpoints_univ h_ext)

omit [Fintype α] [DecidableEq α] in
/-- Under complement stability, fixed points are closed under union. -/
theorem fixedpoints_union
    {O : Set α → Set α} (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    (h_compl : ∀ s, O s = s → O sᶜ = sᶜ)
    {s t : Set α} (hs : O s = s) (ht : O t = t) :
    O (s ∪ t) = s ∪ t := by
  have h_de_morgan : s ∪ t = (sᶜ ∩ tᶜ)ᶜ := by
    simp +decide [Set.compl_inter]
  convert h_compl (sᶜ ∩ tᶜ) _ using 1
  · rw [h_de_morgan]
  · exact fixedpoints_inter h_mono h_ext (h_compl s hs) (h_compl t ht)

/-! ## Equivalence Classes and Saturation -/

/-- The equivalence class of `x`: all elements sharing the same fixed-point membership
    pattern as `x`. This is the "semantic atom" containing `x`. -/
def classOf (O : Set α → Set α) (x : α) : Set α :=
  {y | ∀ s : Set α, O s = s → (x ∈ s ↔ y ∈ s)}

omit [Fintype α] [DecidableEq α] in
@[simp]
theorem mem_classOf_self (O : Set α → Set α) (x : α) : x ∈ classOf O x :=
  fun _ _ => Iff.rfl

omit [Fintype α] [DecidableEq α] in
/-- If `s` is a fixed point and `x ∈ s`, then the entire equivalence class of `x`
    is contained in `s`. This is the saturation property. -/
theorem classOf_subset_of_mem_fixed
    (O : Set α → Set α) {s : Set α} {x : α} (hs : O s = s) (hx : x ∈ s) :
    classOf O x ⊆ s :=
  fun _y hy => (hy s hs).mp hx

omit [Fintype α] [DecidableEq α] in
/-- Each equivalence class is itself a fixed point of the closure operator. -/
theorem classOf_fixed
    {O : Set α → Set α} (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    (_h_idem : ∀ s, O (O s) = O s) (h_compl : ∀ s, O s = s → O sᶜ = sᶜ)
    (x : α) :
    O (classOf O x) = classOf O x := by
  refine' le_antisymm _ _;
  · intro y hy s hs;
    constructor <;> intro hxs;
    · exact h_mono ( show classOf O x ⊆ s from fun z hz => hz s hs |>.1 hxs ) hy |> fun h => hs ▸ h;
    · contrapose! hy;
      have h_classOf_subset_s_compl : classOf O x ⊆ sᶜ := by
        exact fun z hz => fun hzs => hy <| by simpa [ hz s hs ] using hzs;
      have h_O_classOf_subset_s_compl : O (classOf O x) ⊆ sᶜ := by
        exact Set.Subset.trans ( h_mono h_classOf_subset_s_compl ) ( by aesop );
      exact fun h => h_O_classOf_subset_s_compl h hxs;
  · exact h_ext _

/-! ## Setoid and Quotient Construction -/

/-- The setoid on `α` induced by a closure operator: elements are equivalent iff
    they belong to exactly the same fixed points. -/
def closureSetoid (O : Set α → Set α) : Setoid α where
  r x y := ∀ s : Set α, O s = s → (x ∈ s ↔ y ∈ s)
  iseqv := ⟨
    fun _ _ _ => Iff.rfl,
    fun h s hs => (h s hs).symm,
    fun h1 h2 s hs => (h1 s hs).trans (h2 s hs)⟩

/-- The quotient type: the finite type of "semantic worlds" or "Stone points". -/
abbrev ClosureQuotient (O : Set α → Set α) : Type _ := Quotient (closureSetoid (α := α) O)

instance closureQuotientFintype (O : Set α → Set α) : Fintype (ClosureQuotient O) :=
  Quotient.fintype (closureSetoid O)

omit [Fintype α] [DecidableEq α] in
/-- A fixed point is saturated: it is a union of equivalence classes. -/
theorem fixed_saturated
    {O : Set α → Set α}
    {s : Set α} (hs : O s = s) {x y : α}
    (hx : x ∈ s) (hxy : (closureSetoid O).r x y) : y ∈ s :=
  (hxy s hs).mp hx

omit [Fintype α] [DecidableEq α] in
/-- Preimage of any set under the quotient map is a fixed point. -/
theorem preimage_quot_fixed
    {O : Set α → Set α} (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    (h_idem : ∀ s, O (O s) = O s) (h_compl : ∀ s, O s = s → O sᶜ = sᶜ)
    (T : Set (ClosureQuotient O)) :
    O (Quotient.mk (closureSetoid O) ⁻¹' T) =
      Quotient.mk (closureSetoid O) ⁻¹' T := by
  -- Let π = Quotient.mk (closureSetoid O), S = π ⁻¹' T.
  set π : α → ClosureQuotient O := Quotient.mk (closureSetoid O)
  set S := π ⁻¹' T;
  -- By contradiction, assume there exists $y \in O S$ such that $y \notin S$.
  by_contra h_contra;
  -- Then there exists $y \in O S$ such that $y \notin S$.
  obtain ⟨y, hyO, hyS⟩ : ∃ y, y ∈ O S ∧ y ∉ S := by
    exact Set.exists_of_ssubset ( lt_of_le_of_ne ( h_ext S ) ( Ne.symm h_contra ) );
  -- Then for all $z \in S$, $\pi z \in T$, so $\pi z \neq \pi y$, so $z$ and $y$ are not equivalent under closureSetoid.
  have h_not_equiv : ∀ z ∈ S, ¬(closureSetoid O).r z y := by
    intro z hz hzy
    have h_eq : π z = π y := by
      exact Quotient.eq.mpr hzy;
    grind;
  -- So S ⊆ (classOf O y)ᶜ.
  have hS_subset_compl : S ⊆ (classOf O y)ᶜ := by
    exact fun z hz => fun h => h_not_equiv z hz fun s hs => by have := h s hs; tauto;
  -- By monotonicity: O S ⊆ O ((classOf O y)ᶜ) = (classOf O y)ᶜ.
  have hOS_subset_compl : O S ⊆ (classOf O y)ᶜ := by
    exact Set.Subset.trans ( h_mono hS_subset_compl ) ( by rw [ h_compl _ ( classOf_fixed h_mono h_ext h_idem h_compl y ) ] );
  grind +suggestions

/-! ## Main Representation Theorem -/

/-
**Finite Stone Representation Theorem**: The fixed points of a complement-stable
    closure operator on `Set α` (with `α` finite) are order-isomorphic to `Set β`
    for a finite type `β`.
-/
omit [DecidableEq α] in
theorem finite_fixedpoints_stone_representation
    (O : Set α → Set α)
    (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    (h_idem : ∀ s, O (O s) = O s) (h_compl : ∀ s, O s = s → O sᶜ = sᶜ) :
    ∃ (β : Type) (_ : Fintype β),
      Nonempty ({s : Set α // O s = s} ≃o Set β) := by
  refine' ⟨ _, _, ⟨ _ ⟩ ⟩;
  exact Fin ( Fintype.card ( Quotient ( closureSetoid ( α := α ) O ) ) );
  · infer_instance;
  · have h_iso : Nonempty ({s : Set α // O s = s} ≃o Set (Quotient (closureSetoid (α := α) O))) := by
      refine' ⟨ _ ⟩;
      refine' { Equiv.ofBijective ( fun s => Quotient.mk ( closureSetoid O ) '' s.val ) ⟨ _, _ ⟩ with .. };
      all_goals simp +decide [ Set.subset_def, Function.Injective, Function.Surjective ];
      · intro s hs t ht h_eq;
        ext x;
        constructor <;> intro hx;
        · obtain ⟨ y, hy, hy' ⟩ := h_eq.subset ⟨ x, hx, rfl ⟩;
          rw [ Quotient.eq ] at hy';
          exact fixed_saturated ht hy hy';
        · obtain ⟨ y, hy, hy' ⟩ := h_eq.symm.subset ( Set.mem_image_of_mem _ hx );
          exact fixed_saturated hs hy ( by simpa [ Quotient.eq ] using hy' );
      · intro b;
        refine' ⟨ Quotient.mk ( closureSetoid O ) ⁻¹' b, _, _ ⟩;
        · exact preimage_quot_fixed h_mono h_ext h_idem h_compl b;
        · exact Set.image_preimage_eq_inter_range.trans ( by rw [ Set.range_eq_univ.mpr ( Quotient.mk_surjective ) ] ; simp +decide );
      · intro s hs t ht; constructor <;> intro h x hx <;> specialize h x hx <;> simp_all +decide [ Quotient.eq ] ;
        · obtain ⟨ y, hy, hxy ⟩ := h; exact fixed_saturated ht hy hxy;
        · exact ⟨ x, h, fun s hs => Iff.rfl ⟩;
    refine' h_iso.some.trans _;
    refine' OrderIso.symm _;
    refine' { Equiv.trans ( Equiv.Set.congr ( Fintype.equivFin _ |> Equiv.symm ) ) ( Equiv.refl _ ) with .. };
    simp +decide [ Set.subset_def ]

/-! ## Atom Characterization -/

/-- An atom of the fixed-point lattice: a minimal nonempty fixed point. -/
def IsAtomFixed (O : Set α → Set α) (a : Set α) : Prop :=
  O a = a ∧ a.Nonempty ∧ ∀ b, O b = b → b ⊆ a → b = ∅ ∨ b = a

omit [Fintype α] [DecidableEq α] in
/-- Each equivalence class is an atom of the fixed-point lattice. -/
theorem classOf_isAtom
    {O : Set α → Set α} (h_mono : Monotone O) (h_ext : ∀ s, s ⊆ O s)
    (h_idem : ∀ s, O (O s) = O s) (h_compl : ∀ s, O s = s → O sᶜ = sᶜ)
    (x : α) :
    IsAtomFixed O (classOf O x) := by
  refine' ⟨ classOf_fixed h_mono h_ext h_idem h_compl x, _, _ ⟩;
  · exact ⟨ x, fun s hs => Iff.rfl ⟩;
  · grind +locals

omit [Fintype α] [DecidableEq α] in
/-- Every fixed point is the union of equivalence classes of its elements. -/
theorem fixedpoint_eq_biUnion_classOf
    (O : Set α → Set α)
    {s : Set α} (hs : O s = s) :
    s = ⋃ x ∈ s, classOf O x := by
  apply Set.eq_of_subset_of_subset;
  · exact fun x hx => Set.mem_iUnion₂.2 ⟨ x, hx, mem_classOf_self _ _ ⟩;
  · exact Set.iUnion₂_subset fun x hx => classOf_subset_of_mem_fixed O hs hx

end FiniteStoneClosure
end