import Mathlib

/-!
# Universal Mathematics: which theorems does *any* intelligence discover?

Would an alien, an AI, or an independently evolved intelligence discover the same
mathematics we did?  We make one precise reading of this question.

Fix a class of *structures* `M` (the "worlds" a theory can talk about).  A
**sentence** is a property `M → Prop`; a **theory** is a set of sentences (its
axioms); a **model** of a theory is a structure satisfying all its axioms.  A
theory is **consistent** when it has at least one model, and it **entails** a
sentence when the sentence holds in every one of its models (semantic
consequence, `⊨`).

We call a sentence `φ` **universal over `T`** when it is entailed by *every*
consistent extension of `T`.  Intuitively: no matter how a reasoner strengthens
the base theory `T` (as long as they stay consistent), they are forced to accept
`φ`.  This is our formal stand-in for "a truth any sufficiently expressive,
consistent reasoner must reach".

The main results:

* `entails_mono` — theorems survive under extension: every theorem of `T` is a
  theorem of every larger theory.  This is the exact content of *"Peano
  arithmetic is universal: its theorems are a subset of every consistent
  extension."*
* `universal_iff_entails` — over a consistent base theory, *universal = provable*.
  Universality adds nothing beyond ordinary consequence, precisely because a
  theory is a consistent extension of itself.
* `independent_not_universal` — a sentence with a model *and* a countermodel is
  **not** universal (and neither is its negation).  Instantiated below with the
  commutativity axiom, which plays the role of the parallel postulate: the
  existence of non‑abelian groups is the algebraic analogue of the existence of
  non‑Euclidean geometries.
* `universal_or_iff_decided` — over a consistent theory, "`φ` or `¬φ` is
  universal" is *equivalent* to "`T` decides `φ`".  This is the exact structural
  reduction behind the conjecture *"the Riemann Hypothesis is universal iff
  arithmetic decides it."*

The development is fully semantic and self-contained.
-/

namespace UniversalMathematics

variable {M : Type*}

/-- A **sentence** over a class of structures `M` is a property of structures. -/
abbrev Sentence (M : Type*) := M → Prop

/-- A **theory** is a set of sentences (its axioms). -/
abbrev Theory (M : Type*) := Set (M → Prop)

/-- The negation of a sentence. -/
def Sentence.neg (φ : Sentence M) : Sentence M := fun m => ¬ φ m

/-- `m` is a **model** of `T` when it satisfies every axiom of `T`. -/
def IsModel (T : Theory M) (m : M) : Prop := ∀ φ ∈ T, φ m

/-- `T` is **consistent** when it has a model. -/
def Consistent (T : Theory M) : Prop := ∃ m, IsModel T m

/-- `T` **entails** `φ` (`T ⊨ φ`) when `φ` holds in every model of `T`. -/
def Entails (T : Theory M) (φ : Sentence M) : Prop := ∀ m, IsModel T m → φ m

/-- `φ` is **universal over `T`** when every consistent extension of `T` entails it. -/
def Universal (T : Theory M) (φ : Sentence M) : Prop :=
  ∀ T' : Theory M, T ⊆ T' → Consistent T' → Entails T' φ

/-- `T` **decides** `φ` when it entails `φ` or entails `¬φ`. -/
def Decides (T : Theory M) (φ : Sentence M) : Prop :=
  Entails T φ ∨ Entails T φ.neg

/-! ## Basic consequence facts -/

/-- Every axiom of a theory is entailed by it. -/
theorem entails_of_mem {T : Theory M} {φ : Sentence M} (h : φ ∈ T) : Entails T φ :=
  fun _ hm => hm φ h

/-- **Monotonicity of consequence.**  Every theorem of `T` is a theorem of any
extension `T' ⊇ T`.  Formalizes *"Peano's theorems are a subset of the theorems
of every extension."* -/
theorem entails_mono {T T' : Theory M} {φ : Sentence M}
    (h : T ⊆ T') (hφ : Entails T φ) : Entails T' φ :=
  fun m hm => hφ m (fun ψ hψ => hm ψ (h hψ))

/-- A consistent theory cannot entail a sentence and its negation. -/
theorem not_entails_both {T : Theory M} {φ : Sentence M}
    (hc : Consistent T) : ¬ (Entails T φ ∧ Entails T φ.neg) := by
  rintro ⟨h1, h2⟩
  obtain ⟨m, hm⟩ := hc
  exact h2 m hm (h1 m hm)

/-! ## The universality characterization -/

/-- **Universality = provability.**  Over a *consistent* base theory, a sentence
is universal (entailed by every consistent extension) exactly when it is already
a theorem of the base theory.  Universality genuinely characterizes the theorems
of `T`; the forward direction uses that `T` is a consistent extension of itself. -/
theorem universal_iff_entails {T : Theory M} {φ : Sentence M} (hc : Consistent T) :
    Universal T φ ↔ Entails T φ := by
  constructor
  · intro h; exact h T (le_refl T) hc
  · intro h T' hext _; exact entails_mono hext h

/-- Universal sentences are entailed by the base theory (one direction, no
consistency needed to *use* it once you have `hc`). -/
theorem entails_of_universal {T : Theory M} {φ : Sentence M}
    (hc : Consistent T) (h : Universal T φ) : Entails T φ :=
  (universal_iff_entails hc).1 h

/-- Axioms are universal. -/
theorem universal_of_mem {T : Theory M} {φ : Sentence M} (h : φ ∈ T) : Universal T φ :=
  fun _ hext _ => entails_mono hext (entails_of_mem h)

/-! ## Closure properties of the universal sentences -/

/-- Universality is closed under conjunction. -/
theorem universal_and {T : Theory M} {φ ψ : Sentence M}
    (hφ : Universal T φ) (hψ : Universal T ψ) :
    Universal T (fun m => φ m ∧ ψ m) := by
  intro T' hext hcons m hm
  exact ⟨hφ T' hext hcons m hm, hψ T' hext hcons m hm⟩

/-- Universality is closed under modus ponens. -/
theorem universal_mp {T : Theory M} {φ ψ : Sentence M}
    (himp : Universal T (fun m => φ m → ψ m)) (hφ : Universal T φ) :
    Universal T ψ := by
  intro T' hext hcons m hm
  exact himp T' hext hcons m hm (hφ T' hext hcons m hm)

/-! ## Independence: not every truth is universal (the parallel postulate) -/

/-- `φ` is **independent** over `T` when `T` has a model of `φ` and a model of
`¬φ`. -/
def Independent (T : Theory M) (φ : Sentence M) : Prop :=
  (∃ m, IsModel T m ∧ φ m) ∧ (∃ m, IsModel T m ∧ ¬ φ m)

/-- If a sentence has a model of `T` where it fails, `T` does not entail it. -/
theorem not_entails_of_countermodel {T : Theory M} {φ : Sentence M}
    (h : ∃ m, IsModel T m ∧ ¬ φ m) : ¬ Entails T φ := by
  obtain ⟨m, hm, hφ⟩ := h
  intro he; exact hφ (he m hm)

/-- **Independence defeats universality.**  If `φ` has both a model and a
countermodel over `T`, then neither `φ` nor `¬φ` is universal over `T`.  This is
the abstract "parallel postulate is not universal": an independent axiom can be
consistently affirmed *or* denied. -/
theorem independent_not_universal {T : Theory M} {φ : Sentence M}
    (h : Independent T φ) :
    ¬ Universal T φ ∧ ¬ Universal T φ.neg := by
  obtain ⟨⟨m₁, hm₁, hφ₁⟩, m₂, hm₂, hφ₂⟩ := h
  -- `m₂` models `T ∪ {¬φ}`
  have hmodel₂ : IsModel (insert φ.neg T) m₂ := by
    intro ψ hψ
    rcases Set.mem_insert_iff.1 hψ with rfl | h
    · exact hφ₂
    · exact hm₂ ψ h
  -- `m₁` models `T ∪ {φ}`
  have hmodel₁ : IsModel (insert φ T) m₁ := by
    intro ψ hψ
    rcases Set.mem_insert_iff.1 hψ with rfl | h
    · exact hφ₁
    · exact hm₁ ψ h
  constructor
  · -- extend `T` by `¬φ`; consistent via `m₂`, does not entail `φ`
    intro hu
    exact hφ₂ (hu _ (Set.subset_insert _ _) ⟨m₂, hmodel₂⟩ m₂ hmodel₂)
  · -- extend `T` by `φ`; consistent via `m₁`, does not entail `¬φ`
    intro hu
    exact (hu _ (Set.subset_insert _ _) ⟨m₁, hmodel₁⟩ m₁ hmodel₁) hφ₁

/-! ## Decidability and the Riemann-Hypothesis-style conjecture -/

/-- At most one of `φ`, `¬φ` can be universal over a consistent theory. -/
theorem not_universal_both {T : Theory M} {φ : Sentence M} (hc : Consistent T) :
    ¬ (Universal T φ ∧ Universal T φ.neg) := by
  rintro ⟨h1, h2⟩
  exact not_entails_both hc ⟨entails_of_universal hc h1, entails_of_universal hc h2⟩

/-- **The RH-universality reduction.**  Over a consistent theory, "either `φ` or
its negation is universal" is *equivalent* to "the theory decides `φ`".

Reading `T` as an arithmetic theory and `φ` as the Riemann Hypothesis: RH (or its
negation) is universal **iff** arithmetic decides RH.  So the conjecture *"RH is
universal"* is, on this semantics, exactly the open problem of whether arithmetic
settles RH — it is neither trivially true nor trivially false, which is why we
leave it as a conjecture rather than a theorem. -/
theorem universal_or_iff_decided {T : Theory M} {φ : Sentence M} (hc : Consistent T) :
    (Universal T φ ∨ Universal T φ.neg) ↔ Decides T φ := by
  unfold Decides
  rw [universal_iff_entails hc, universal_iff_entails hc]

/-! ## A concrete world: groups, commutativity, and the "parallel postulate"

We instantiate the framework with a small class of group structures.  Group
theory has both abelian and non‑abelian models, so *commutativity* is the
algebraic parallel postulate: it can be consistently added or denied.  The
non‑abelian witness is the symmetric group `S₃`, whose non‑commutativity is a
finite check — the analogue of a non‑Euclidean model. -/

namespace Groups

/-- Two concrete group worlds: the abelian group `ℤ/2ℤ` and the non‑abelian
symmetric group `S₃`. -/
inductive World | z2 | perm3
  deriving DecidableEq

/-- The carrier group of each world. -/
def World.carrier : World → Type
  | .z2 => Multiplicative (ZMod 2)
  | .perm3 => Equiv.Perm (Fin 3)

instance (w : World) : Group w.carrier := by
  cases w <;> unfold World.carrier <;> infer_instance
instance (w : World) : Fintype w.carrier := by
  cases w <;> unfold World.carrier <;> infer_instance
instance (w : World) : DecidableEq w.carrier := by
  cases w <;> unfold World.carrier <;> infer_instance

/-- The commutativity sentence: "this group is abelian". -/
def isCommutative : Sentence World := fun w => ∀ x y : w.carrier, x * y = y * x

/-- The empty theory: every `World` is already a group, so *the theory of
groups* imposes no further axioms on this class. -/
def theoryOfGroups : Theory World := ∅

/-- Every world is a model of the (axiom‑free) theory of groups. -/
theorem isModel_groups (w : World) : IsModel theoryOfGroups w := by
  intro φ hφ; exact absurd hφ (Set.notMem_empty φ)

/-- `ℤ/2ℤ` is a commutative model. -/
theorem z2_commutative : isCommutative World.z2 := by
  unfold isCommutative; decide

/-- `S₃` is a non‑commutative model — the "non‑Euclidean" witness. -/
theorem perm3_not_commutative : ¬ isCommutative World.perm3 := by
  unfold isCommutative; decide

/-- **The parallel postulate is not universal.**  Commutativity is independent of
the group axioms: neither it nor its negation is universal over the theory of
groups, exactly because both abelian and non‑abelian groups exist. -/
theorem commutativity_not_universal :
    ¬ Universal theoryOfGroups isCommutative ∧
      ¬ Universal theoryOfGroups isCommutative.neg := by
  apply independent_not_universal
  exact ⟨⟨World.z2, isModel_groups _, z2_commutative⟩,
         ⟨World.perm3, isModel_groups _, perm3_not_commutative⟩⟩

/-- The theory of *abelian* groups: the theory of groups together with the
commutativity axiom. -/
def theoryOfAbelian : Theory World := insert isCommutative theoryOfGroups

/-- `theoryOfAbelian` is consistent (`ℤ/2ℤ` is a model). -/
theorem theoryOfAbelian_consistent : Consistent theoryOfAbelian := by
  refine ⟨World.z2, ?_⟩
  intro φ hφ
  rcases hφ with h | h
  · exact h ▸ z2_commutative
  · exact absurd h (Set.notMem_empty φ)

/-- **Commutativity *is* universal over the theory of abelian groups.**  Once an
intelligence adopts it as an axiom, every consistent extension of their theory is
forced to keep it — the contrast that makes `commutativity_not_universal`
meaningful.  This is `universal_iff_entails` in action. -/
theorem commutativity_universal_over_abelian :
    Universal theoryOfAbelian isCommutative :=
  universal_of_mem (Set.mem_insert _ _)

end Groups

end UniversalMathematics