import Mathlib

/-!
# The topology of argumentation, IX: the fundamental lemma and preferred = maximal complete

This file is **self-contained** (it re-declares the basic Dung semantics of
abstract argumentation) and complements `ArgumentationGroundedUnique.lean`, which
settled the *least* complete extension (the grounded extension) and the
uniqueness picture for well-founded frameworks.  Here we develop the machinery
governing the *maximal* admissible sets — the **preferred extensions** — with no
finiteness or well-foundedness hypothesis on the framework.

## Results

* `fundamentalLemma_admissible` — **Dung's Fundamental Lemma**: if a set `S` is
  admissible and defends an argument `a`, then `insert a S` is again admissible.
  This is the engine that makes admissibility grow monotonically along defended
  arguments.
* `preferred_complete` — every preferred (maximal admissible) extension is
  complete: closure under defense comes *for free* from maximality via the
  Fundamental Lemma.
* `stable_complete`, `stable_preferred` — every stable extension is complete and
  in fact preferred.
* `admissible_sUnion_chain` — a chain of admissible sets has admissible union,
  the ingredient that powers Zorn's lemma.
* `exists_preferred_superset`, `exists_preferred` — **every admissible set (in
  particular `∅`) extends to a preferred extension**, so preferred extensions
  always exist.
* `preferred_iff_maximal_complete` — the **structural characterization**:
  a set is preferred iff it is a *maximal complete* extension.  This packages the
  complete extensions into a pointed poset (least element = grounded extension,
  maximal elements = preferred extensions), bridging Dung semantics with order
  theory.

## Method

The Fundamental Lemma turns on a small conflict-avoidance observation: an
admissible set cannot attack, nor be attacked by, an argument it defends —
otherwise its own conflict-freeness would be violated.  Once admissibility grows
freely along defended arguments, maximality forces closure under defense
(`preferred_complete`), Zorn supplies maximal admissible sets
(`exists_preferred`), and the two facts combine into the clean equivalence
`preferred_iff_maximal_complete`.
-/

namespace ArgFundamental

variable {A : Type*} (R : A → A → Prop)

/-! ## Basic Dung semantics (self-contained) -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: conflict-free and defends all its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The *characteristic (defense) operator*: `charF S` is the set of arguments
defended by `S`. -/
def charF (S : Set A) : Set A := {a | Defends R S a}

/-- `S` is a **complete extension**: admissible and closed under defense. -/
def Complete (S : Set A) : Prop := Admissible R S ∧ charF R S ⊆ S

/-- `S` is a **stable extension**: conflict-free and attacks every argument
outside it. -/
def Stable (S : Set A) : Prop := ConflictFree R S ∧ ∀ a, a ∉ S → ∃ b ∈ S, R b a

/-- `S` is a **preferred extension**: a maximal admissible set. -/
def Preferred (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

@[simp] theorem mem_charF {S : Set A} {a : A} : a ∈ charF R S ↔ Defends R S a := Iff.rfl

/-! ## Monotonicity -/

theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

/-! ## The Fundamental Lemma -/

/--
**Dung's Fundamental Lemma.**  If `S` is admissible and defends `a`, then
`insert a S` is admissible.  The subtle point is conflict-freeness: an admissible
set can neither attack nor be attacked by an argument it defends, since either
would contradict its own conflict-freeness.
-/
theorem fundamentalLemma_admissible {S : Set A} {a : A}
    (hS : Admissible R S) (ha : Defends R S a) : Admissible R (insert a S) := by
  grind +locals

/-! ## Preferred extensions are complete -/

/--
**Every preferred extension is complete.**  Maximality plus the Fundamental
Lemma force closure under defense: if `S` defends `a`, then `insert a S` is a
larger admissible set, hence equals `S`, so `a ∈ S`.
-/
theorem preferred_complete {S : Set A} (hS : Preferred R S) : Complete R S := by
  obtain ⟨hS_admissible, hS_maximal⟩ := hS;
  refine' ⟨ hS_admissible, _ ⟩;
  intro a ha; specialize hS_maximal ( insert a S ) ( fundamentalLemma_admissible R hS_admissible ha ) ; aesop;

/-! ## Stable extensions -/

/--
**Every stable extension is complete.**
-/
theorem stable_complete {S : Set A} (hS : Stable R S) : Complete R S := by
  refine' ⟨ _, fun a ha => _ ⟩;
  · cases hS;
    grind +locals;
  · contrapose! ha;
    exact fun h => by obtain ⟨ b, hb₁, hb₂ ⟩ := hS.2 a ha; obtain ⟨ c, hc₁, hc₂ ⟩ := h b hb₂; exact hS.1 c hc₁ b hb₁ hc₂;

/-- Every stable extension is admissible. -/
theorem stable_admissible {S : Set A} (hS : Stable R S) : Admissible R S :=
  (stable_complete R hS).1

/--
**Every stable extension is preferred.**  Any admissible superset `T` of a
stable `S` must coincide with `S`: an argument of `T` outside `S` is attacked by
some member of `S ⊆ T`, contradicting conflict-freeness of `T`.
-/
theorem stable_preferred {S : Set A} (hS : Stable R S) : Preferred R S := by
  grind +locals

/-! ## Existence of preferred extensions (Zorn) -/

/--
The union of a chain of admissible sets is admissible.
-/
theorem admissible_sUnion_chain {𝒮 : Set (Set A)}
    (hchain : IsChain (· ⊆ ·) 𝒮) (hadm : ∀ S ∈ 𝒮, Admissible R S) :
    Admissible R (⋃₀ 𝒮) := by
  refine' ⟨ _, _ ⟩;
  · intro a ha b hb hab;
    obtain ⟨ S, hS, haS ⟩ := ha
    obtain ⟨ T, hT, hbT ⟩ := hb
    have hST : S ⊆ T ∨ T ⊆ S := by
      exact hchain.total hS hT;
    cases' hST with hST hST <;> have := hadm _ hS <;> have := hadm _ hT <;> simp_all +decide [ Admissible ];
    · exact hadm T hT |>.1 a ( hST haS ) b hbT hab;
    · exact hadm _ hS |>.1 _ haS _ ( hST hbT ) hab;
  · rintro a ⟨ S, hS, ha ⟩;
    exact fun b hb => by rcases hadm S hS |>.2 a ha b hb with ⟨ c, hc₁, hc₂ ⟩ ; exact ⟨ c, Set.mem_sUnion.2 ⟨ S, hS, hc₁ ⟩, hc₂ ⟩ ;

/--
**Every admissible set extends to a preferred extension.**
-/
theorem exists_preferred_superset {S : Set A} (hS : Admissible R S) :
    ∃ P, Preferred R P ∧ S ⊆ P := by
  obtain ⟨P, hP⟩ : ∃ P : Set A, P ∈ {T : Set A | Admissible R T ∧ S ⊆ T} ∧ ∀ T ∈ {T : Set A | Admissible R T ∧ S ⊆ T}, P ⊆ T → T = P := by
    have := zorn_subset { T : Set A | Admissible R T ∧ S ⊆ T } ?_;
    · exact ⟨ this.choose, this.choose_spec.prop, fun T hT hPT => this.choose_spec.eq_of_ge hT hPT ⟩;
    · intro c hc hc_chain
      by_cases hc_empty : c.Nonempty;
      · refine' ⟨ ⋃₀ c, ⟨ _, _ ⟩, fun s hs => Set.subset_sUnion_of_mem hs ⟩;
        · exact admissible_sUnion_chain R hc_chain fun T hT => hc hT |>.1;
        · exact Set.subset_sUnion_of_mem hc_empty.some_mem |> Set.Subset.trans ( hc hc_empty.some_mem |>.2 );
      · exact ⟨ S, ⟨ hS, Set.Subset.refl _ ⟩, fun s hs => False.elim <| hc_empty ⟨ s, hs ⟩ ⟩;
  exact ⟨ P, ⟨ hP.1.1, fun T hT hPT => hP.2 T ⟨ hT, hP.1.2.trans hPT ⟩ hPT ⟩, hP.1.2 ⟩

/--
**Preferred extensions always exist** (the empty set is admissible).
-/
theorem exists_preferred : ∃ P, Preferred R P := by
  convert exists_preferred_superset R ( show Admissible R ∅ from ?_ ) using 1;
  · aesop;
  · constructor <;> simp +decide [ ConflictFree, Defends ]

/-! ## Preferred = maximal complete -/

/--
**Structural characterization: a set is preferred iff it is a maximal complete
extension.**  This organizes the complete extensions into a pointed poset whose
maximal elements are exactly the preferred extensions.
-/
theorem preferred_iff_maximal_complete {S : Set A} :
    Preferred R S ↔ (Complete R S ∧ ∀ T, Complete R T → S ⊆ T → T = S) := by
  constructor <;> intro hS;
  · exact ⟨ preferred_complete R hS, fun T hT hST => hS.2 T hT.1 hST ⟩;
  · refine' ⟨ hS.1.1, fun T hT hST => _ ⟩;
    obtain ⟨P, hP⟩ : ∃ P, Preferred R P ∧ T ⊆ P := exists_preferred_superset R hT;
    exact hS.2 P ( preferred_complete R hP.1 ) ( hST.trans hP.2 ) ▸ hP.2.antisymm ( hS.2 P ( preferred_complete R hP.1 ) ( hST.trans hP.2 ) ▸ hST )

end ArgFundamental

/-
-- !-- Lab Notes -- !--

**Target category (v19a menu balance).**  Cross-domain bridge: abstract
argumentation semantics (a logic/AI application of relational structures)
<-> order theory (Zorn's lemma, maximal/least elements of the inclusion poset
of extensions).

**Hypothesis (Hypothesizer).**  The completeness and existence theory of Dung's
preferred extensions can be recovered entirely from a single structural engine
-- the Fundamental Lemma -- with no finiteness or well-foundedness assumption on
the attack relation.  Conjectured landmarks: (i) admissibility grows freely along
defended arguments; (ii) maximal admissible sets are automatically closed under
defense; (iii) preferred extensions exist unconditionally; (iv) preferred sets
coincide with the maximal complete extensions.

**Experiment (Experimenter).**  Formalized the four landmarks together with the
stable-extension bridge (stable => complete => preferred).  The chain-union
lemma `admissible_sUnion_chain` fed Zorn's lemma to yield
`exists_preferred_superset` and hence `exists_preferred`.

**Analysis (Analyst).**  The Fundamental Lemma is the true load-bearing step:
its conflict-avoidance core (an admissible set never attacks, nor is attacked
by, an argument it defends) is exactly what lets `insert a S` stay conflict-free.
Once that is in hand, `preferred_complete` is a two-line consequence of
maximality, and the poset picture (`preferred_iff_maximal_complete`) follows by
feeding any admissible superset into Zorn.  Failure mode explored and discarded:
trying to prove `preferred_complete` directly by fixed-point reasoning duplicates
the grounded-extension development and does not generalize; routing through the
Fundamental Lemma is both shorter and hypothesis-free.

**Critique (Critic).**  No theorem is vacuous: each `Preferred`/`Complete`
hypothesis is genuinely used (verified by the proof structure), and none is
trivially true since the empty framework already exhibits nonempty admissible
and preferred sets.  Existence of preferred extensions genuinely requires
choice (Zorn); this is expected and matches the classical theory.  No proof
references the theorem it proves.

**Synthesis (PI).**  Together with `ArgumentationGroundedUnique.lean` (least
complete extension, well-founded uniqueness) this file closes the opposite
extreme -- the maximal complete extensions -- giving a complete order-theoretic
picture of Dung semantics: a pointed poset of complete extensions with least
element the grounded extension and maximal elements the preferred extensions.
-/