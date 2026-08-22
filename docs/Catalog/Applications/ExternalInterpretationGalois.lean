/-
# A Galois Correspondence Between Symmetry Groups and Interpretation Theories

The companion files show that an external interpretation `I : M → V` descends to
structural truth exactly when it is constant on the orbits of the symmetry group
`G` (`ExternalInterpretationDefinability.recoverable_iff_orbitConstant`).  That
result takes the group as given.  This file asks the *inverse* question:

> How much of the symmetry group is visible in the collection of interpretations
> it makes recoverable?

The answer is: **all of it**, provided the interpretations are allowed to speak
about *configurations* (tuples of elements) rather than single points.  Writing
`Config α = α → α` for the space of `α`-indexed configurations, with a
permutation acting pointwise on values, we prove

* `mem_iff_preserves_recoverable` — a permutation `σ` lies in `G` **iff** it
  preserves every `G`-recoverable interpretation of configurations.  This is a
  Krasner-style closure theorem for permutation groups: no proper overgroup and
  no proper subgroup can have the same recoverable theory.
* `invTheory_injective` — hence `G ↦ (its recoverable theory)` is injective, so
  the lattice of symmetry groups embeds into the lattice of interpretation
  theories, antitonically (`invTheory_antitone`, `symGroup_antitone`).
* `symGroup_invTheory` / `invTheory_symGroup_invTheory` — the pair
  (`symGroup`, `invTheory`) is a Galois connection whose group-side closure
  operator is the identity: symmetry groups are exactly the Galois-closed
  objects.
* `invTheory_lt_of_lt` — strict inclusions of groups give strict inclusions of
  theories, and `bool_theories_ne` is a concrete two-element witness.

The moral for the definability programme: "structural truth" determines its own
symmetry group, so the recoverability boundary studied in the other files is an
intrinsic invariant of the theory, not an artefact of the chosen group
presentation.
-/

import Mathlib
import Catalog.Applications.ExternalInterpretationDefinability

namespace ExternalInterpretationGalois

open ExternalInterpretationDefinability

universe u

variable {α : Type u}

/-! ## Configurations and the pointwise action -/

/-- The space of **configurations**: `α`-indexed tuples of elements of `α`.
Interpretations of configurations are the natural test objects for how much a
symmetry group is seen by structural truth. -/
def Config (α : Type u) : Type u := α → α

instance : MulAction (Equiv.Perm α) (Config α) where
  smul σ f := fun a => σ (f a)
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

lemma smul_config_apply (σ : Equiv.Perm α) (f : Config α) (a : α) :
    (σ • f) a = σ (f a) := rfl

/-- The identity configuration, i.e. the tuple listing every element of `α` once. -/
def idConfig (α : Type u) : Config α := fun a => a

lemma smul_idConfig (σ : Equiv.Perm α) : σ • idConfig α = (fun a => σ a) := rfl

/-! ## The two sides of the correspondence -/

/-- An **interpretation theory**: a set of propositional interpretations of
configurations. -/
abbrev Theory (α : Type u) : Type u := Set (Config α → Prop)

/-- The theory of a symmetry group: all interpretations recoverable from the
structural truth `G` provides. -/
def invTheory (G : Subgroup (Equiv.Perm α)) : Theory α :=
  {I | Recoverable G I}

/-- A permutation **preserves** an interpretation when it cannot change any
meaning. -/
def Preserves (σ : Equiv.Perm α) (I : Config α → Prop) : Prop :=
  ∀ f : Config α, I (σ • f) = I f

/-- The symmetry group of a theory: all permutations preserving every
interpretation in it.  This is a subgroup. -/
def symGroup (S : Theory α) : Subgroup (Equiv.Perm α) where
  carrier := {σ | ∀ I ∈ S, Preserves σ I}
  one_mem' := by
    intro I _ f
    simp [one_smul]
  mul_mem' := by
    intro σ τ hσ hτ I hI f
    rw [mul_smul, hσ I hI, hτ I hI]
  inv_mem' := by
    intro σ hσ I hI f
    have := hσ I hI (σ⁻¹ • f)
    rw [smul_inv_smul] at this
    exact this.symm

lemma mem_symGroup {S : Theory α} {σ : Equiv.Perm α} :
    σ ∈ symGroup S ↔ ∀ I ∈ S, Preserves σ I := Iff.rfl

/-! ## Recoverable interpretations of configurations -/

/-- Membership in a group's theory, unfolded to orbit constancy. -/
lemma mem_invTheory_iff {G : Subgroup (Equiv.Perm α)} {I : Config α → Prop} :
    I ∈ invTheory G ↔ ∀ (g : G) (f : Config α), I (g • f) = I f := by
  constructor
  · intro hI g f
    have h := (recoverable_iff_orbitConstant (G := G) I).mp hI (⟨g, rfl⟩ : Indist G f (g • f))
    exact propext ⟨fun hx => h ▸ hx, fun hx => h ▸ hx⟩
  · intro h
    refine (recoverable_iff_orbitConstant (G := G) I).mpr ?_
    rintro x y ⟨g, rfl⟩
    exact (h g x).symm

/-- Every element of `G` preserves every interpretation in `G`'s theory: one half
of the closure theorem, and the easy one. -/
lemma le_symGroup_invTheory (G : Subgroup (Equiv.Perm α)) :
    G ≤ symGroup (invTheory G) := by
  intro σ hσ I hI f
  exact mem_invTheory_iff.mp hI ⟨σ, hσ⟩ f

/-- The **membership interpretation** of a subgroup: a configuration is
meaningful exactly when it is (the underlying tuple of) a symmetry in `G`.  This
is the interpretation that detects `G` itself. -/
def memInterp (G : Subgroup (Equiv.Perm α)) : Config α → Prop :=
  fun f => ∃ g : Equiv.Perm α, g ∈ G ∧ (fun a => g a) = f

lemma memInterp_recoverable (G : Subgroup (Equiv.Perm α)) :
    memInterp G ∈ invTheory G := by
  refine mem_invTheory_iff.mpr ?_
  rintro ⟨σ, hσ⟩ f
  refine propext ⟨?_, ?_⟩
  · rintro ⟨g, hg, hgf⟩
    refine ⟨σ⁻¹ * g, G.mul_mem (G.inv_mem hσ) hg, ?_⟩
    funext a
    have h1 : g a = σ (f a) := congrArg (fun h => h a) hgf
    simp [Equiv.Perm.coe_mul, h1]
  · rintro ⟨g, hg, hgf⟩
    refine ⟨σ * g, G.mul_mem hσ hg, ?_⟩
    funext a
    have h1 : g a = f a := congrArg (fun h => h a) hgf
    show σ (g a) = σ (f a)
    rw [h1]

/-- **Krasner-style closure theorem.**  A permutation belongs to the symmetry
group exactly when it preserves every interpretation that this group makes
recoverable.  Thus the group is reconstructible from its recoverable theory. -/
theorem mem_iff_preserves_recoverable {G : Subgroup (Equiv.Perm α)}
    {σ : Equiv.Perm α} :
    σ ∈ G ↔ ∀ I ∈ invTheory G, Preserves σ I := by
  constructor
  · intro hσ I hI
    exact le_symGroup_invTheory G hσ I hI
  · intro h
    have hpres := h (memInterp G) (memInterp_recoverable G) (idConfig α)
    have hid : memInterp G (idConfig α) := ⟨1, G.one_mem, rfl⟩
    have : memInterp G (σ • idConfig α) := by rw [hpres]; exact hid
    obtain ⟨g, hg, hgf⟩ := this
    have : g = σ := by
      ext a
      have := congrArg (fun h => h a) hgf
      simpa [smul_idConfig] using this
    exact this ▸ hg

/-- **Group-side Galois closure is the identity.** -/
theorem symGroup_invTheory (G : Subgroup (Equiv.Perm α)) :
    symGroup (invTheory G) = G := by
  ext σ
  exact (mem_iff_preserves_recoverable).symm

/-! ## The Galois connection -/

lemma invTheory_antitone {G H : Subgroup (Equiv.Perm α)} (h : G ≤ H) :
    invTheory H ⊆ invTheory G := by
  intro I hI
  refine mem_invTheory_iff.mpr ?_
  rintro ⟨g, hg⟩ f
  exact mem_invTheory_iff.mp hI ⟨g, h hg⟩ f

lemma symGroup_antitone {S T : Theory α} (h : S ⊆ T) : symGroup T ≤ symGroup S :=
  fun _ hσ I hI => hσ I (h hI)

lemma le_symGroup_iff {G : Subgroup (Equiv.Perm α)} {S : Theory α} :
    G ≤ symGroup S ↔ S ⊆ invTheory G := by
  constructor
  · intro h I hI
    refine mem_invTheory_iff.mpr ?_
    rintro ⟨g, hg⟩ f
    exact h hg I hI f
  · intro h σ hσ I hI f
    exact mem_invTheory_iff.mp (h hI) ⟨σ, hσ⟩ f

/-- The theory-side closure operator is idempotent on theories of groups. -/
theorem invTheory_symGroup_invTheory (G : Subgroup (Equiv.Perm α)) :
    invTheory (symGroup (invTheory G)) = invTheory G := by
  rw [symGroup_invTheory]

/-- **Reconstruction.**  Distinct symmetry groups have distinct recoverable
theories: the map `G ↦ invTheory G` is injective. -/
theorem invTheory_injective :
    Function.Injective (invTheory : Subgroup (Equiv.Perm α) → Theory α) := by
  intro G H h
  have := congrArg symGroup h
  rwa [symGroup_invTheory, symGroup_invTheory] at this

/-- A strictly larger symmetry group has a strictly smaller theory: more
symmetry means strictly fewer recoverable meanings. -/
theorem invTheory_lt_of_lt {G H : Subgroup (Equiv.Perm α)} (h : G < H) :
    invTheory H ⊂ invTheory G := by
  refine ⟨invTheory_antitone h.le, ?_⟩
  intro hsub
  have hEq : H = G := invTheory_injective (Set.Subset.antisymm (invTheory_antitone h.le) hsub)
  exact absurd hEq h.ne'

/-! ## A concrete two-element witness -/

/-- On a two-element model the trivial group and the full symmetric group are
distinct, hence – by reconstruction – have genuinely different stocks of
recoverable interpretations. -/
theorem bool_theories_ne :
    invTheory (⊥ : Subgroup (Equiv.Perm Bool)) ≠ invTheory (⊤ : Subgroup (Equiv.Perm Bool)) := by
  intro h
  have : (⊥ : Subgroup (Equiv.Perm Bool)) = ⊤ := invTheory_injective h
  have hswap : Equiv.swap true false ∈ (⊤ : Subgroup (Equiv.Perm Bool)) := Subgroup.mem_top _
  rw [← this] at hswap
  have : Equiv.swap true false = (1 : Equiv.Perm Bool) := Subgroup.mem_bot.mp hswap
  have := congrArg (fun e => e true) this
  simp at this

end ExternalInterpretationGalois