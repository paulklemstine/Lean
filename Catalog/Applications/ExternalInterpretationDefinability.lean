/-
# The Definability Boundary for External Interpretations

An **external interpretation** of a structure `M` is a map `I : M → V` assigning
to each element of the structure a "meaning" drawn from an outside value type `V`.
The structure itself only sees its elements up to its symmetries: two elements
lying in the same orbit of the automorphism group `G` are *structurally
indistinguishable*.  The guiding question of this file is:

> When is an external interpretation *recoverable from structural truth*, i.e.
> when does it factor through the structural quotient, and when is it moreover
> *definable* in a language of invariant predicates?

The conjecture under test is:

> recoverable ⟺ constant on automorphism orbits **and** definable in the
> invariant language; for finite models orbit constancy alone suffices once the
> language is enriched by (bounded) orbit-counting modalities.

What we prove:

* **Part 1 — Orbit descent.**  `recoverable_iff_orbitConstant` : an
  interpretation factors through the orbit quotient exactly when it is constant
  on orbits, and `recovery_unique` shows the factorisation is unique.  This is
  the "necessary condition" half of the conjecture, proved in full generality.
* **Part 2 — Meaning collision.**  `not_recoverable_of_collision` and
  `perm_recoverable_iff_constant` : under the full symmetric group every
  non-constant interpretation collides, so structural truth cannot recover it;
  `meaning_collision_bool` is a concrete two-element instance.  This is the
  negative half of the classification.
* **Part 3 — Invariant languages.**  Definability in *any* invariant language
  implies orbit constancy (`definable_orbitConstant`), hence recoverability
  (`definable_recoverable`): definability is genuinely the stronger notion.
* **Part 4 — Finite sufficiency.**  For a finite model, every invariant set is
  a Boolean combination of orbit predicates (`countGen_of_invariantSet`), and
  conversely (`invariantSet_of_countGen`).  Consequently
  `finite_recoverable_iff_definable` : on finite models the three notions
  (recoverable, orbit-constant, definable in the counting language) coincide —
  the conjectured collapse in the finite case, and `orbitLang` is shown to be
  the largest invariant language (`orbitLang_maximal`).  In general (no
  finiteness) `definable_orbitLang_iff_recoverable` shows recoverability is
  exactly definability in that largest invariant language, and
  `classification_finite` packages the finite collapse as a `TFAE`.
* **Part 5 — The infinite boundary is real.**  `parity_not_definable` exhibits
  an interpretation on `ℕ` which is orbit-constant (indeed the group is trivial)
  yet undefinable in the finite/cofinite invariant language: orbit constancy
  alone is *strictly weaker* than definability, so the definability clause in
  the conjecture cannot be dropped for infinite models.
* **Part 6 — A Burnside bridge.**  `card_orbitConstant_eq_pow` counts the
  recoverable interpretations as `|V| ^ (number of orbits)`, and
  `burnside_recoverable_count` combines this with the orbit-counting lemma:
  `2 ^ (∑_g |Fix g|) = (number of recoverable Boolean interpretations) ^ |G|`,
  linking semantic recoverability to group-theoretic character sums.
-/

import Mathlib

namespace ExternalInterpretationDefinability

open MulAction

universe u v w

variable {G : Type u} {M : Type v} {V : Type w} [Group G] [MulAction G M]

/-! ## Part 0 — Structural indistinguishability -/

/-- Two elements are **structurally indistinguishable** when some automorphism
(element of the acting group `G`) carries one to the other. -/
def Indist (G : Type u) [Group G] [MulAction G M] (x y : M) : Prop := ∃ g : G, g • x = y

lemma indist_refl (x : M) : Indist G x x := ⟨1, one_smul _ _⟩

lemma indist_symm {x y : M} (h : Indist G x y) : Indist G y x := by
  obtain ⟨g, rfl⟩ := h
  exact ⟨g⁻¹, by simp⟩

lemma indist_trans {x y z : M} (h₁ : Indist G x y) (h₂ : Indist G y z) : Indist G x z := by
  obtain ⟨g, rfl⟩ := h₁
  obtain ⟨h, rfl⟩ := h₂
  exact ⟨h * g, by rw [mul_smul]⟩

/-- Indistinguishability is exactly the Mathlib orbit relation (with arguments
swapped, matching `MulAction.orbitRel_apply`). -/
lemma indist_iff_orbitRel {x y : M} : Indist G x y ↔ (orbitRel G M) y x := by
  rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff]
  exact Iff.rfl

/-- An interpretation is **orbit-constant** if indistinguishable elements get the
same meaning. -/
def OrbitConstant (G : Type u) [Group G] [MulAction G M] (I : M → V) : Prop :=
  ∀ ⦃x y : M⦄, Indist G x y → I x = I y

/-- An interpretation is **recoverable from structural truth** if it factors
through the quotient of the model by structural indistinguishability. -/
def Recoverable (G : Type u) [Group G] [MulAction G M] (I : M → V) : Prop :=
  ∃ F : orbitRel.Quotient G M → V, ∀ x : M, F (Quotient.mk _ x) = I x

/-! ## Part 1 — Orbit descent -/

/-- **Orbit descent.**  An external interpretation is recoverable from structural
truth precisely when it is constant on automorphism orbits. -/
theorem recoverable_iff_orbitConstant (I : M → V) :
    Recoverable G I ↔ OrbitConstant G I := by
  constructor
  · rintro ⟨F, hF⟩ x y hxy
    have : (Quotient.mk (orbitRel G M) x) = Quotient.mk _ y :=
      Quotient.sound (indist_iff_orbitRel.mp (indist_symm hxy))
    rw [← hF x, ← hF y, this]
  · intro h
    refine ⟨Quotient.lift I ?_, fun x => rfl⟩
    intro a b hab
    have hr : (orbitRel G M) a b := hab
    rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
    exact (h hr).symm

/-- The structural recovery of an interpretation, when it exists, is unique. -/
theorem recovery_unique {I : M → V} {F₁ F₂ : orbitRel.Quotient G M → V}
    (h₁ : ∀ x : M, F₁ (Quotient.mk _ x) = I x) (h₂ : ∀ x : M, F₂ (Quotient.mk _ x) = I x) :
    F₁ = F₂ := by
  funext q
  induction q using Quotient.inductionOn with
  | h x => rw [h₁ x, h₂ x]

/-! ## Part 2 — Meaning collisions: the negative half -/

/-- **Meaning collision.**  If two structurally indistinguishable elements are
assigned different meanings, the interpretation cannot be recovered from
structural truth. -/
theorem not_recoverable_of_collision {I : M → V} {x y : M}
    (hxy : Indist G x y) (hne : I x ≠ I y) : ¬ Recoverable G I := by
  intro h
  exact hne ((recoverable_iff_orbitConstant I).mp h hxy)

/-- Under the *full* symmetric group all elements are indistinguishable, so an
interpretation is recoverable exactly when it is globally constant: maximal
symmetry destroys all external meaning beyond a single value. -/
theorem perm_recoverable_iff_constant (I : M → V) :
    Recoverable (Equiv.Perm M) I ↔ ∀ x y : M, I x = I y := by
  rw [recoverable_iff_orbitConstant]
  constructor
  · intro h x y
    classical
    by_cases hxy : x = y
    · rw [hxy]
    · exact h ⟨Equiv.swap x y, by simp [Equiv.Perm.smul_def, Equiv.swap_apply_left]⟩
  · intro h x y _
    exact h x y

/-- A concrete meaning collision: the identity interpretation on `Bool`, viewed
inside the full symmetry group of `Bool`, is not recoverable. -/
theorem meaning_collision_bool : ¬ Recoverable (Equiv.Perm Bool) (id : Bool → Bool) := by
  intro h
  have := (perm_recoverable_iff_constant (id : Bool → Bool)).mp h true false
  simp at this

/-! ## Part 3 — Invariant languages and definability -/

/-- A set is **invariant** if it is closed under the action of the group. -/
def InvariantSet (G : Type u) [Group G] [MulAction G M] (s : Set M) : Prop :=
  ∀ (g : G) ⦃x : M⦄, x ∈ s → g • x ∈ s

/-- An **invariant language** on `M`: a Boolean algebra of subsets of `M`, all of
whose members are invariant under the automorphism group. -/
structure InvLang (G : Type u) (M : Type v) [Group G] [MulAction G M] where
  /-- The sets definable by a formula of the language. -/
  Defble : Set M → Prop
  /-- The empty set is definable (by a contradictory formula). -/
  empty_mem : Defble ∅
  /-- Definable sets are closed under negation. -/
  compl_mem : ∀ {s : Set M}, Defble s → Defble sᶜ
  /-- Definable sets are closed under disjunction. -/
  union_mem : ∀ {s t : Set M}, Defble s → Defble t → Defble (s ∪ t)
  /-- Every definable set is invariant: the language sees only structure. -/
  invariant : ∀ {s : Set M}, Defble s → InvariantSet G s

/-- An interpretation is **definable** in an invariant language when each of its
meaning fibres is definable. -/
def Definable (L : InvLang G M) (I : M → V) : Prop := ∀ v : V, L.Defble {x | I x = v}

/-- Definability in an invariant language forces orbit constancy: the necessary
condition of the conjecture holds for every invariant language. -/
theorem definable_orbitConstant {L : InvLang G M} {I : M → V} (h : Definable L I) :
    OrbitConstant G I := by
  intro x y hxy
  obtain ⟨g, rfl⟩ := hxy
  have hx : x ∈ {z | I z = I x} := rfl
  have := L.invariant (h (I x)) g hx
  exact this.symm

/-- **The conjunction in the conjecture is redundant.**  "Constant on orbits *and*
definable in the invariant language" says no more than "definable": for an
invariant language the first conjunct is automatic. -/
theorem definable_iff_orbitConstant_and_definable {L : InvLang G M} {I : M → V} :
    Definable L I ↔ (OrbitConstant G I ∧ Definable L I) :=
  ⟨fun h => ⟨definable_orbitConstant h, h⟩, And.right⟩

/-- Definable interpretations are recoverable from structural truth. -/
theorem definable_recoverable {L : InvLang G M} {I : M → V} (h : Definable L I) :
    Recoverable G I :=
  (recoverable_iff_orbitConstant I).mpr (definable_orbitConstant h)

/-! ## Part 4 — Orbit predicates, counting modalities, and finite sufficiency -/

lemma invariantSet_orbit (x : M) : InvariantSet G (orbit G x) := by
  intro g y hy
  exact MulAction.mem_orbit_of_mem_orbit g hy

lemma invariantSet_empty : InvariantSet G (∅ : Set M) := by
  intro g x hx; exact absurd hx (Set.notMem_empty x)

lemma invariantSet_compl {s : Set M} (hs : InvariantSet G s) : InvariantSet G sᶜ := by
  intro g x hx hmem
  exact hx (by simpa using hs g⁻¹ hmem)

lemma invariantSet_union {s t : Set M} (hs : InvariantSet G s) (ht : InvariantSet G t) :
    InvariantSet G (s ∪ t) := by
  rintro g x (hx | hx)
  · exact Or.inl (hs g hx)
  · exact Or.inr (ht g hx)

lemma invariantSet_diff {s t : Set M} (hs : InvariantSet G s) (ht : InvariantSet G t) :
    InvariantSet G (s \ t) := by
  intro g x hx
  refine ⟨hs g hx.1, ?_⟩
  intro hmem
  exact hx.2 (by simpa using ht g⁻¹ hmem)

/-- The **orbit language**: all invariant subsets of `M`.  It is an invariant
language, and by `orbitLang_maximal` the largest one. -/
def orbitLang (G : Type u) (M : Type v) [Group G] [MulAction G M] : InvLang G M where
  Defble := InvariantSet G
  empty_mem := invariantSet_empty
  compl_mem := invariantSet_compl
  union_mem := invariantSet_union
  invariant := id

/-- Any invariant language is contained in the orbit language. -/
theorem orbitLang_maximal (L : InvLang G M) {s : Set M} (hs : L.Defble s) :
    (orbitLang G M).Defble s := L.invariant hs

/-- Sets definable by a Boolean combination of **orbit (counting) modalities**:
the smallest Boolean algebra of subsets containing every orbit. -/
inductive CountGen (G : Type u) (M : Type v) [Group G] [MulAction G M] : Set M → Prop
  | orbit (x : M) : CountGen G M (MulAction.orbit G x)
  | empty : CountGen G M ∅
  | compl {s : Set M} : CountGen G M s → CountGen G M sᶜ
  | union {s t : Set M} : CountGen G M s → CountGen G M t → CountGen G M (s ∪ t)

lemma CountGen.inter {s t : Set M} (hs : CountGen G M s) (ht : CountGen G M t) :
    CountGen G M (s ∩ t) := by
  have : s ∩ t = (sᶜ ∪ tᶜ)ᶜ := by
    simp [Set.compl_union]
  rw [this]
  exact ((hs.compl.union ht.compl).compl)

lemma CountGen.diff {s t : Set M} (hs : CountGen G M s) (ht : CountGen G M t) :
    CountGen G M (s \ t) := by
  rw [Set.diff_eq]
  exact hs.inter ht.compl

/-- **Soundness of the counting language**: every Boolean combination of orbit
predicates is an invariant set. -/
theorem invariantSet_of_countGen {s : Set M} (h : CountGen G M s) : InvariantSet G s := by
  induction h with
  | orbit x => exact invariantSet_orbit x
  | empty => exact invariantSet_empty
  | compl _ ih => exact invariantSet_compl ih
  | union _ _ ih₁ ih₂ => exact invariantSet_union ih₁ ih₂

/-- Auxiliary strong induction on the size of an invariant set. -/
private theorem countGen_of_invariantSet_aux [Finite M] :
    ∀ (n : ℕ) (s : Set M), s.ncard = n → InvariantSet G s → CountGen G M s := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro s hcard hinv
    rcases Set.eq_empty_or_nonempty s with rfl | ⟨x, hx⟩
    · exact CountGen.empty
    · have hsub : orbit G x ⊆ s := by
        rintro y ⟨g, rfl⟩
        exact hinv g hx
      have hxorb : x ∈ orbit G x := MulAction.mem_orbit_self x
      have hss : s \ orbit G x ⊂ s := by
        refine ⟨Set.diff_subset, ?_⟩
        intro hcon
        exact (hcon hx).2 hxorb
      have hfin : s.Finite := Set.toFinite s
      have hlt : (s \ orbit G x).ncard < n := by
        rw [← hcard]; exact Set.ncard_lt_ncard hss hfin
      have hrest : CountGen G M (s \ orbit G x) :=
        ih _ hlt _ rfl (invariantSet_diff hinv (invariantSet_orbit x))
      have hsplit : s = orbit G x ∪ (s \ orbit G x) := by
        rw [Set.union_diff_cancel hsub]
      rw [hsplit]
      exact (CountGen.orbit x).union hrest

/-- **Finite completeness of the counting language.**  On a finite model every
invariant set is a Boolean combination of orbit predicates.  Together with
`invariantSet_of_countGen` this identifies the counting language with the orbit
language. -/
theorem countGen_of_invariantSet [Finite M] {s : Set M} (hs : InvariantSet G s) :
    CountGen G M s := countGen_of_invariantSet_aux s.ncard s rfl hs

/-- On a finite model, the counting language defines exactly the invariant sets. -/
theorem countGen_iff_invariantSet [Finite M] {s : Set M} :
    CountGen G M s ↔ InvariantSet G s :=
  ⟨invariantSet_of_countGen, countGen_of_invariantSet⟩

/-- **The finite collapse.**  On a finite model the three notions coincide:
an external interpretation is recoverable from structural truth iff it is
constant on automorphism orbits iff each of its meaning fibres is a Boolean
combination of orbit-counting predicates. -/
theorem finite_recoverable_iff_definable [Finite M] (I : M → V) :
    Recoverable G I ↔ ∀ v : V, CountGen G M {x | I x = v} := by
  rw [recoverable_iff_orbitConstant]
  constructor
  · intro h v
    refine countGen_of_invariantSet ?_
    intro g x hx
    have : I (g • x) = I x := (h ⟨g, rfl⟩).symm
    simp only [Set.mem_setOf_eq] at hx ⊢
    rw [this, hx]
  · intro h x y hxy
    obtain ⟨g, rfl⟩ := hxy
    have hx : x ∈ {z | I z = I x} := rfl
    exact (invariantSet_of_countGen (h (I x)) g hx).symm

/-- **The general form of the conjecture.**  Without any finiteness assumption,
recoverability from structural truth is exactly definability in the *maximal*
invariant language, the orbit language.  So the correct general statement is
"recoverable ⟺ definable in the largest invariant language"; the role of the
finite hypothesis is only to replace that language by the concrete Boolean
algebra of orbit-counting predicates. -/
theorem definable_orbitLang_iff_recoverable (I : M → V) :
    Definable (orbitLang G M) I ↔ Recoverable G I := by
  rw [recoverable_iff_orbitConstant]
  refine ⟨definable_orbitConstant, ?_⟩
  intro h v g x hx
  simp only [Set.mem_setOf_eq] at hx ⊢
  rw [← h ⟨g, rfl⟩, hx]

/-- **Capstone classification.**  On a finite model the four candidate readings
of "the interpretation is fixed by structural truth" agree: recoverability,
orbit constancy, definability in the maximal invariant language, and
definability by Boolean combinations of orbit-counting predicates. -/
theorem classification_finite [Finite M] (I : M → V) :
    [Recoverable G I, OrbitConstant G I, Definable (orbitLang G M) I,
      ∀ v : V, CountGen G M {x | I x = v}].TFAE := by
  tfae_have 1 ↔ 2 := recoverable_iff_orbitConstant I
  tfae_have 1 ↔ 3 := (definable_orbitLang_iff_recoverable I).symm
  tfae_have 1 ↔ 4 := finite_recoverable_iff_definable I
  tfae_finish

/-! ## Part 5 — The infinite boundary: orbit constancy is strictly weaker -/

section InfiniteBoundary

/-- The trivial automorphism group of `ℕ`: the bottom subgroup of `Equiv.Perm ℕ`. -/
abbrev TrivG : Type := (⊥ : Subgroup (Equiv.Perm ℕ))

lemma trivG_smul (g : TrivG) (n : ℕ) : g • n = n := by
  obtain ⟨g, hg⟩ := g
  rw [Subgroup.mem_bot] at hg
  subst hg
  rfl

/-- With a trivial automorphism group, structural indistinguishability is
equality, so *every* interpretation is orbit-constant. -/
theorem trivG_orbitConstant (I : ℕ → V) : OrbitConstant TrivG I := by
  rintro x y ⟨g, rfl⟩
  rw [trivG_smul]

/-- The invariant language of finite-or-cofinite subsets of `ℕ` (the "bounded"
language: a formula may only pin down finitely much information, or its
negation may). -/
def cofiniteLang : InvLang TrivG ℕ where
  Defble s := s.Finite ∨ sᶜ.Finite
  empty_mem := Or.inl Set.finite_empty
  compl_mem := by
    rintro s (h | h)
    · exact Or.inr (by simpa using h)
    · exact Or.inl h
  union_mem := by
    rintro s t (hs | hs) (ht | ht)
    · exact Or.inl (hs.union ht)
    · refine Or.inr (Set.Finite.subset ht ?_)
      intro x hx
      simp only [Set.mem_compl_iff, Set.mem_union, not_or] at hx ⊢
      exact hx.2
    · refine Or.inr (Set.Finite.subset hs ?_)
      intro x hx
      simp only [Set.mem_compl_iff, Set.mem_union, not_or] at hx ⊢
      exact hx.1
    · refine Or.inr (Set.Finite.subset hs ?_)
      intro x hx
      simp only [Set.mem_compl_iff, Set.mem_union, not_or] at hx ⊢
      exact hx.1
  invariant := by
    intro s _ g x hx
    rw [trivG_smul]
    exact hx

/-- The parity interpretation of `ℕ`. -/
def parity : ℕ → Bool := fun n => decide (Even n)

lemma setOf_parity_true : {n : ℕ | parity n = true} = {n | Even n} := by
  ext n; simp [parity]

theorem infinite_evens : {n : ℕ | Even n}.Infinite := by
  refine Set.infinite_of_injective_forall_mem (f := fun k : ℕ => 2 * k) ?_ ?_
  · intro a b hab
    have h : 2 * a = 2 * b := hab
    omega
  · intro k; exact ⟨k, by ring⟩

theorem infinite_odds : {n : ℕ | Even n}ᶜ.Infinite := by
  refine Set.infinite_of_injective_forall_mem (f := fun k : ℕ => 2 * k + 1) ?_ ?_
  · intro a b hab
    have h : 2 * a + 1 = 2 * b + 1 := hab
    omega
  · intro k
    simp only [Set.mem_compl_iff, Set.mem_setOf_eq, Nat.not_even_iff_odd]
    exact ⟨k, rfl⟩

/-- **The boundary is real.**  Parity is orbit-constant (trivially so, the
automorphism group being trivial) yet it is *not* definable in the bounded
invariant language: on infinite models orbit constancy is strictly weaker than
definability, so the definability clause of the conjecture cannot be dropped. -/
theorem parity_not_definable : OrbitConstant TrivG parity ∧ ¬ Definable cofiniteLang parity := by
  refine ⟨trivG_orbitConstant parity, ?_⟩
  intro h
  have hdef := h true
  rw [setOf_parity_true] at hdef
  rcases hdef with hfin | hfin
  · exact infinite_evens hfin
  · exact infinite_odds hfin

/-- Consequently, on infinite models recoverability does *not* imply definability:
there is a recoverable but undefinable interpretation. -/
theorem recoverable_not_definable :
    ∃ I : ℕ → Bool, Recoverable TrivG I ∧ ¬ Definable cofiniteLang I :=
  ⟨parity, (recoverable_iff_orbitConstant parity).mpr (trivG_orbitConstant parity),
    parity_not_definable.2⟩

end InfiniteBoundary

/-! ## Part 6 — Counting the recoverable interpretations (Burnside bridge) -/

/-- Recoverable interpretations correspond bijectively to functions on the orbit
space. -/
def recoverableEquiv (G : Type u) (M : Type v) (V : Type w) [Group G] [MulAction G M] :
    {I : M → V // OrbitConstant G I} ≃ (orbitRel.Quotient G M → V) where
  toFun I := Quotient.lift I.1 (by
    intro a b hab
    have hr : (orbitRel G M) a b := hab
    rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
    exact (I.2 hr).symm)
  invFun F := ⟨fun x => F (Quotient.mk _ x), by
    intro x y hxy
    have : (Quotient.mk (orbitRel G M) x) = Quotient.mk _ y :=
      Quotient.sound (indist_iff_orbitRel.mp (indist_symm hxy))
    simp only
    rw [this]⟩
  left_inv := by rintro ⟨I, hI⟩; rfl
  right_inv := by
    intro F
    funext q
    induction q using Quotient.inductionOn with
    | h x => rfl

/-- **Counting recoverable interpretations.**  There are exactly
`|V| ^ (number of orbits)` interpretations recoverable from structural truth. -/
theorem card_orbitConstant_eq_pow [Fintype M] [Fintype V]
    [DecidableEq (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G M)]
    [Fintype {I : M → V // OrbitConstant G I}] :
    Fintype.card {I : M → V // OrbitConstant G I}
      = Fintype.card V ^ Fintype.card (orbitRel.Quotient G M) := by
  rw [Fintype.card_congr (recoverableEquiv G M V), Fintype.card_fun]

/-- **Burnside bridge.**  Combining the count of recoverable Boolean
interpretations with the orbit-counting lemma gives a purely group-theoretic
formula: the number of recoverable interpretations, raised to the order of the
automorphism group, equals `2` to the total number of fixed points. -/
theorem burnside_recoverable_count [Fintype G] [Fintype M]
    [DecidableEq (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G M)]
    [∀ g : G, Fintype (fixedBy M g)]
    [Fintype {I : M → Bool // OrbitConstant G I}] :
    2 ^ (∑ g : G, Fintype.card (fixedBy M g))
      = (Fintype.card {I : M → Bool // OrbitConstant G I}) ^ Fintype.card G := by
  rw [MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G M, pow_mul,
    card_orbitConstant_eq_pow (G := G) (M := M) (V := Bool)]
  norm_num

end ExternalInterpretationDefinability