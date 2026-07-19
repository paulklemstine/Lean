import Mathlib

/-!
# Tangled soundness on Kripke frames

This file gives a semantic construction of self-referential soundness predicates.
For a Kripke frame, a predicate is declared sound when it is locally valid and every
accessible world is again sound.  The predicate is constructed as a greatest fixed
point, rather than assumed.  A second construction couples two proof systems: each
system's soundness requires the other's soundness at every accessible world.
-/

open Set

namespace TangledSoundness

universe u

/-- A Kripke frame, with no finiteness or well-foundedness assumptions. -/
structure Frame where
  World : Type u
  Rel : World → World → Prop

namespace Frame

variable (F : Frame)

/-- The modal box operation on predicates over worlds. -/
def box (X : Set F.World) : Set F.World := {w | ∀ v, F.Rel w v → v ∈ X}

/-- Box is monotone. -/
theorem box_mono : Monotone F.box := by
  intro X Y hXY w hw v hwv
  exact hXY (hw v hwv)

/-- The soundness transformer: local validity together with inherited soundness. -/
def soundStep (valid : Set F.World) (X : Set F.World) : Set F.World :=
  valid ∩ F.box X

/-- Soundness is the union of all predicates preserved by the soundness transformer. -/
def sound (valid : Set F.World) : Set F.World :=
  ⋃₀ {X : Set F.World | X ⊆ F.soundStep valid X}

/-- Every post-fixed soundness candidate is contained in the constructed soundness predicate.
-/
theorem subset_sound_of_postfixed (valid X : Set F.World)
    (hX : X ⊆ F.soundStep valid X) : X ⊆ F.sound valid := by
  exact Set.subset_sUnion_of_mem hX

/-- The constructed predicate is itself post-fixed.
-/
theorem sound_subset_step (valid : Set F.World) :
    F.sound valid ⊆ F.soundStep valid (F.sound valid) := by
  intro w hw; simp_all +decide [ Frame.soundStep ] ;
  obtain ⟨ X, hX ⟩ := hw;
  exact ⟨ hX.1 hX.2 |>.1, fun v hv => subset_sound_of_postfixed F valid X hX.1 ( hX.1 hX.2 |>.2 v hv ) ⟩

/-- Applying the transformer to soundness gives another post-fixed candidate.
-/
theorem step_subset_sound (valid : Set F.World) :
    F.soundStep valid (F.sound valid) ⊆ F.sound valid := by
  apply subset_sound_of_postfixed;
  exact Set.inter_subset_inter_right _ ( F.box_mono ( sound_subset_step F valid ) )

/-- **Self-soundness fixed point.** A world is sound exactly when it is locally valid
and every world it can access is itself sound.  Thus the predicate occurs inside the
semantic clause that it validates.
-/
theorem sound_fixedPoint (valid : Set F.World) :
    F.sound valid = valid ∩ F.box (F.sound valid) := by
  convert Set.Subset.antisymm ( sound_subset_step _ _ ) ( step_subset_sound _ _ ) using 1

/-- Coinduction principle for self-soundness: any invariant whose worlds are locally
valid and lead only back into the invariant consists entirely of sound worlds.
-/
theorem sound_coinduction (valid X : Set F.World)
    (hvalid : X ⊆ valid) (hclosed : X ⊆ F.box X) : X ⊆ F.sound valid := by
  apply TangledSoundness.Frame.subset_sound_of_postfixed;
  exact fun x hx => ⟨ hvalid hx, hclosed hx ⟩

/-- Empty local validity yields no sound worlds.
-/
theorem sound_empty : F.sound (∅ : Set F.World) = ∅ := by
  convert TangledSoundness.Frame.sound_fixedPoint F ∅;
  aesop

/-! ## Two mutually referential proof systems -/

/-- A pair of candidate soundness predicates is post-fixed when system zero is locally
valid and trusts system one at successors, while system one symmetrically trusts zero. -/
def PairPost (valid₀ valid₁ X₀ X₁ : Set F.World) : Prop :=
  X₀ ⊆ valid₀ ∩ F.box X₁ ∧ X₁ ⊆ valid₁ ∩ F.box X₀

/-- Greatest mutually post-fixed predicate for system zero. -/
def tangled₀ (valid₀ valid₁ : Set F.World) : Set F.World :=
  ⋃₀ {X₀ : Set F.World | ∃ X₁, F.PairPost valid₀ valid₁ X₀ X₁}

/-- Greatest mutually post-fixed predicate for system one. -/
def tangled₁ (valid₀ valid₁ : Set F.World) : Set F.World :=
  ⋃₀ {X₁ : Set F.World | ∃ X₀, F.PairPost valid₀ valid₁ X₀ X₁}

/-- Every mutually post-fixed pair embeds into the greatest tangled pair.
-/
theorem subset_tangled_of_pairPost (valid₀ valid₁ X₀ X₁ : Set F.World)
    (h : F.PairPost valid₀ valid₁ X₀ X₁) :
    X₀ ⊆ F.tangled₀ valid₀ valid₁ ∧ X₁ ⊆ F.tangled₁ valid₀ valid₁ := by
  exact ⟨ Set.subset_sUnion_of_mem <| by tauto, Set.subset_sUnion_of_mem <| by tauto ⟩

/-- The greatest tangled predicates form a mutually post-fixed pair.
-/
theorem tangled_pairPost (valid₀ valid₁ : Set F.World) :
    F.PairPost valid₀ valid₁ (F.tangled₀ valid₀ valid₁) (F.tangled₁ valid₀ valid₁) := by
  constructor;
  · intro w hw; simp_all +decide [ Frame.tangled₀, Frame.tangled₁ ] ;
    rcases hw with ⟨ t, ⟨ X₁, ht ⟩, hw ⟩ ; exact ⟨ ht.1 hw |>.1, fun v hv => ⟨ X₁, ⟨ t, ht ⟩, ht.1 hw |>.2 v hv ⟩ ⟩ ;
  · intro w hw;
    obtain ⟨ X₁, hX₁, hwX₁ ⟩ := hw;
    obtain ⟨ X₀, hX₀ ⟩ := hX₁;
    exact ⟨ hX₀.2 hwX₁ |>.1, fun v hv => subset_tangled_of_pairPost F valid₀ valid₁ X₀ X₁ hX₀ |>.1 ( hX₀.2 hwX₁ |>.2 v hv ) ⟩

/-- **First tangled fixed-point equation.** System zero's soundness necessarily
contains system one's soundness in its own validation clause.
-/
theorem tangled₀_fixedPoint (valid₀ valid₁ : Set F.World) :
    F.tangled₀ valid₀ valid₁ = valid₀ ∩ F.box (F.tangled₁ valid₀ valid₁) := by
  refine' le_antisymm _ _;
  · exact F.tangled_pairPost valid₀ valid₁ |>.1;
  · refine' subset_tangled_of_pairPost F valid₀ valid₁ _ _ _ |>.1;
    exact valid₁ ∩ F.box ( valid₀ ∩ F.box ( F.tangled₁ valid₀ valid₁ ) );
    constructor;
    · intro x hx;
      refine' ⟨ hx.1, fun y hy => _ ⟩;
      grind +locals;
    · exact Set.Subset.rfl

/-- **Second tangled fixed-point equation.** System one's soundness necessarily
contains system zero's soundness in its own validation clause.
-/
theorem tangled₁_fixedPoint (valid₀ valid₁ : Set F.World) :
    F.tangled₁ valid₀ valid₁ = valid₁ ∩ F.box (F.tangled₀ valid₀ valid₁) := by
  refine' le_antisymm ( Set.subset_def.mpr _ ) ( Set.subset_def.mpr _ ) <;> intro w hw <;> simp_all +decide [ Frame.tangled₁ ];
  · obtain ⟨ t, ⟨ X₀, hX₀ ⟩, hw ⟩ := hw; have := hX₀.2; simp_all +decide [ Frame.PairPost ] ;
    refine' ⟨ this.1 hw, fun v hv => _ ⟩ ; have := this.2 hw v hv ; simp_all +decide [ Frame.box ] ;
    exact Set.mem_sUnion.mpr ⟨ X₀, ⟨ t, ⟨ by tauto, by tauto ⟩ ⟩, this ⟩;
  · refine' ⟨ _, ⟨ _, _, _ ⟩, _ ⟩;
    exact valid₁ ∩ F.box ( F.tangled₀ valid₀ valid₁ );
    exact F.tangled₀ valid₀ valid₁;
    · have := F.tangled_pairPost valid₀ valid₁;
      exact Set.Subset.trans this.1 ( Set.inter_subset_inter_right _ ( F.box_mono ( this.2 ) ) );
    · exact Set.Subset.rfl;
    · exact hw

/-- **Diagonal collapse.** On the diagonal, the two-system tangle collapses exactly
to ordinary self-soundness: both mutually referential predicates are the greatest
fixed point of the same unary soundness transformer.
-/
theorem tangled_diagonal_eq_sound (valid : Set F.World) :
    F.tangled₀ valid valid = F.sound valid ∧
      F.tangled₁ valid valid = F.sound valid := by
  have h_t0_eq_t1 : F.tangled₀ valid valid = F.tangled₁ valid valid := by
    refine' Set.Subset.antisymm _ _;
    · obtain ⟨ X₁, hX₁ ⟩ := F.tangled_pairPost valid valid;
      exact F.subset_tangled_of_pairPost valid valid _ _ ⟨ hX₁, X₁ ⟩ |>.2;
    · intro w hw; simp_all +decide [ Frame.tangled₁, Frame.tangled₀ ] ;
      obtain ⟨ t, ⟨ X₀, hX₀ ⟩, hw ⟩ := hw; use t; simp_all +decide [ Frame.PairPost ] ;
      exact ⟨ X₀, hX₀.2.2, hX₀.1.1, hX₀.1.2 ⟩;
  have h_t_postfixed : F.tangled₀ valid valid ⊆ F.soundStep valid (F.tangled₀ valid valid) := by
    convert F.tangled_pairPost valid valid |>.1 using 1;
    exact h_t0_eq_t1 ▸ rfl;
  have h_t_greatest : F.tangled₀ valid valid ⊆ F.sound valid := by
    exact F.subset_sound_of_postfixed valid _ h_t_postfixed;
  have h_sound_pairPost : F.PairPost valid valid (F.sound valid) (F.sound valid) := by
    exact ⟨ F.sound_subset_step valid, F.sound_subset_step valid ⟩;
  exact ⟨ h_t_greatest.antisymm ( by simpa [ h_t0_eq_t1 ] using subset_tangled_of_pairPost F valid valid ( F.sound valid ) ( F.sound valid ) h_sound_pairPost |>.1 ), h_t0_eq_t1.symm ▸ h_t_greatest.antisymm ( by simpa [ h_t0_eq_t1 ] using subset_tangled_of_pairPost F valid valid ( F.sound valid ) ( F.sound valid ) h_sound_pairPost |>.2 ) ⟩

/-- **Unavoidability of the tangle.** Any pair satisfying the same local-validity and
cross-soundness equations lies below the canonical tangled hierarchy.
-/
theorem tangled_unavoidable (valid₀ valid₁ S₀ S₁ : Set F.World)
    (h₀ : S₀ = valid₀ ∩ F.box S₁) (h₁ : S₁ = valid₁ ∩ F.box S₀) :
    S₀ ⊆ F.tangled₀ valid₀ valid₁ ∧ S₁ ⊆ F.tangled₁ valid₀ valid₁ := by
  convert TangledSoundness.Frame.subset_tangled_of_pairPost _ _ _ _ _ _;
  exact ⟨ h₀.le, h₁.le ⟩

end Frame
end TangledSoundness