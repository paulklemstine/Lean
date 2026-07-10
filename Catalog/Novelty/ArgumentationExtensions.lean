import Mathlib

/-!
# The topology of argumentation, II: preferred and grounded extensions

This file is **self-contained** (it re-declares the basic Dung semantics from
`ArgumentationCore`) and develops the two central *extension-based* semantics of
an argumentation framework `(A, R)`:

* `Preferred S` — `S` is a **preferred extension**: a *maximal* admissible set.
* `Complete S`  — `S` is a **complete extension**: admissible and closed under
  the defense operator (`charF S ⊆ S`).
* `groundedExt` — the **grounded extension**: the *least* fixed point of the
  defense operator (skeptical semantics).

Main results:

* `admissible_sUnion_chain`   — admissible sets are closed under unions of chains.
* `exists_preferred_superset` — (Zorn) every admissible set extends to a
  preferred extension; in particular `exists_preferred`.
* `preferred_complete`        — **every preferred extension is complete**
  (Dung); the proof is a direct application of the Fundamental Lemma.
* `groundedExt_subset_complete` / `groundedExt_subset_preferred` — the grounded
  extension is contained in every complete, hence every preferred, extension:
  the skeptically-accepted arguments are accepted under every credulous position.
-/

namespace ArgTop

variable {A : Type*} (R : A → A → Prop)

/-- `S` is conflict-free: no argument in `S` attacks another in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` defends `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is admissible: conflict-free and defends all its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The characteristic (defense) operator. -/
def charF (S : Set A) : Set A := {a | Defends R S a}

/-- `S` is a **complete extension**: admissible and closed under defense. -/
def Complete (S : Set A) : Prop := Admissible R S ∧ charF R S ⊆ S

/-- `S` is a **preferred extension**: a maximal admissible set. -/
def Preferred (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

theorem complete_admissible {S : Set A} (h : Complete R S) : Admissible R S := h.1
theorem preferred_admissible {S : Set A} (h : Preferred R S) : Admissible R S := h.1

/-- **Dung's Fundamental Lemma** (re-proved here to keep the file self-contained):
if `S` is admissible and defends `a`, then `insert a S` is admissible. -/
theorem fundamental_lemma {S : Set A} (hS : Admissible R S) {a : A}
    (ha : Defends R S a) : Admissible R (insert a S) := by
  obtain ⟨hcf, hdef⟩ := hS
  have H1 : ∀ c ∈ S, ¬ R c a := fun c hc hca => by
    obtain ⟨d, hd, hdc⟩ := ha c hca; exact hcf d hd c hc hdc
  have H2 : ∀ c ∈ S, ¬ R a c := fun c hc hac => by
    obtain ⟨d, hd, hda⟩ := hdef c hc a hac; exact H1 d hd hda
  have H3 : ¬ R a a := fun haa => by
    obtain ⟨c, hc, hca⟩ := ha a haa; exact H1 c hc hca
  refine ⟨?_, ?_⟩
  · intro x hx y hy hxy
    rcases hx with rfl | hx <;> rcases hy with rfl | hy
    · exact H3 hxy
    · exact H2 y hy hxy
    · exact H1 x hx hxy
    · exact hcf x hx y hy hxy
  · intro x hx
    rcases hx with rfl | hx
    · exact defends_mono R (Set.subset_insert _ _) ha
    · exact defends_mono R (Set.subset_insert _ _) (hdef x hx)

/-- The union of a chain of admissible sets is admissible. -/
theorem admissible_sUnion_chain {c : Set (Set A)} (hc : IsChain (· ⊆ ·) c)
    (hadm : ∀ S ∈ c, Admissible R S) : Admissible R (⋃₀ c) := by
  refine ⟨?_, ?_⟩
  · rintro a ⟨S1, hS1, ha⟩ b ⟨S2, hS2, hb⟩ hab
    rcases hc.total hS1 hS2 with h | h
    · exact (hadm S2 hS2).1 a (h ha) b hb hab
    · exact (hadm S1 hS1).1 a ha b (h hb) hab
  · rintro a ⟨S, hS, ha⟩
    exact defends_mono R (Set.subset_sUnion_of_mem hS) ((hadm S hS).2 a ha)

/-- **Existence of preferred extensions (Zorn's Lemma).**  Every admissible set is
contained in a preferred (maximal admissible) extension. -/
theorem exists_preferred_superset {S₀ : Set A} (h : Admissible R S₀) :
    ∃ S, S₀ ⊆ S ∧ Preferred R S := by
  obtain ⟨m, hm, hmax⟩ := zorn_subset_nonempty {T | Admissible R T}
    (fun c hcsub hchain _ => ⟨⋃₀ c,
      admissible_sUnion_chain R hchain (fun S hS => hcsub hS),
      fun s hs => Set.subset_sUnion_of_mem hs⟩) S₀ h
  refine ⟨m, hm, hmax.prop, ?_⟩
  intro T hT hmT
  exact le_antisymm (hmax.le_of_ge hT hmT) hmT

/-- Every argumentation framework has at least one preferred extension. -/
theorem exists_preferred : ∃ S, Preferred R S := by
  obtain ⟨S, _, hS⟩ := exists_preferred_superset R (S₀ := ∅)
    ⟨fun a ha => absurd ha (Set.notMem_empty a),
     fun a ha => absurd ha (Set.notMem_empty a)⟩
  exact ⟨S, hS⟩

/-- **Every preferred extension is complete** (Dung).  A maximal admissible set
already contains every argument it defends, because otherwise the Fundamental
Lemma would produce a strictly larger admissible set. -/
theorem preferred_complete {S : Set A} (hS : Preferred R S) : Complete R S := by
  obtain ⟨hadm, hmax⟩ := hS
  refine ⟨hadm, ?_⟩
  intro a ha
  have hins : Admissible R (insert a S) := fundamental_lemma R hadm ha
  have heq : insert a S = S := hmax (insert a S) hins (Set.subset_insert a S)
  rw [← heq]
  exact Set.mem_insert a S

/-- The defense operator as a monotone self-map of the complete lattice `Set A`. -/
def charFHom : Set A →o Set A := ⟨charF R, fun _ _ h => charF_mono R h⟩

/-- The **grounded extension**: the least fixed point of the defense operator. -/
noncomputable def groundedExt : Set A := OrderHom.lfp (charFHom R)

/-- The grounded extension is a fixed point of the defense operator. -/
theorem charF_groundedExt : charF R (groundedExt R) = groundedExt R :=
  OrderHom.map_lfp (charFHom R)

/-- The grounded extension is the least fixed point: it is contained in any set
closed under defense. -/
theorem groundedExt_subset_of_charF_subset {S : Set A} (h : charF R S ⊆ S) :
    groundedExt R ⊆ S :=
  OrderHom.lfp_le (charFHom R) h

/-- The grounded extension is contained in every complete extension. -/
theorem groundedExt_subset_complete {S : Set A} (hS : Complete R S) :
    groundedExt R ⊆ S :=
  groundedExt_subset_of_charF_subset R hS.2

/-- The grounded extension is contained in every preferred extension: every
skeptically-accepted argument is accepted under every preferred (credulous)
position. -/
theorem groundedExt_subset_preferred {S : Set A} (hS : Preferred R S) :
    groundedExt R ⊆ S :=
  groundedExt_subset_complete R (preferred_complete R hS)

end ArgTop