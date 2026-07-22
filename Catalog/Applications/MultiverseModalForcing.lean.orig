/-
# The Modal Logic of Forcing — a Kripke-semantic deepening of Multiverse Set Theory

This file equips the combinatorial core of the set-theoretic *multiverse* with a
**modal structure of forcing**, following the Hamkins–Löwe programme:

* **possibility** `◇p` — `p` holds in *some* forcing (generic) extension;
* **necessity**  `□p` — `p` holds in *every* forcing extension.

Forcing extensions form a Kripke *frame*: an accessibility relation `R` on worlds
(models of set theory).  We give the standard Kripke semantics for a language of
modal set-theoretic sentences and prove that the forcing frame is **sound for the
modal system `S4.2`**, the theorem at the heart of the modal logic of forcing:

* `sound_K`      — the distribution axiom `□(p → q) → (□p → □q)` (any frame);
* `sound_Nec`    — the necessitation rule (any frame);
* `sound_T`      — `□p → p` from **reflexivity** of forcing (you force over yourself);
* `sound_Four`   — `□p → □□p` from **transitivity** (iterated forcing);
* `sound_Two`    — `◇□p → □◇p` from **directedness** (any two extensions have a
  common further extension — the amalgamation/product-forcing property).

Together `K, T, 4, .2` axiomatise `S4.2`.  We also prove the **duality**
`◇p ↔ ¬□¬p`, monotonicity and distribution laws, package the result as
`forcing_sound_S42`, instantiate the abstract frame with a concrete
*flip-reachability* forcing frame over the multiverse, and finally show the logic
is **properly weaker than `S5`**: the characteristic axiom `B : p → □◇p` **fails**
in a directed reflexive-transitive forcing frame (`B_fails`).  Thus forcing is
genuinely `S4.2` and not `S5` — you cannot, in general, force your way back.

Everything is proved from first principles over `Mathlib`, self-contained.
-/
import Mathlib

namespace MultiverseModalForcing

open Classical

/-! ## Worlds and modal sentences -/

/-- A `World` (a model of the ambient set theory) is a truth assignment to atoms. -/
abbrev World (α : Type*) := α → Bool

/-- A **multiverse** is a collection of worlds. -/
abbrev Multiverse (α : Type*) := Set (World α)

/-- Modal propositional set-theoretic sentences over atoms `α`, with a `box`
    (necessity / "holds in every forcing extension") modality. -/
inductive MSentence (α : Type*) where
  | atom : α → MSentence α
  | tru : MSentence α
  | fls : MSentence α
  | neg : MSentence α → MSentence α
  | conj : MSentence α → MSentence α → MSentence α
  | disj : MSentence α → MSentence α → MSentence α
  | imp : MSentence α → MSentence α → MSentence α
  | box : MSentence α → MSentence α
  deriving DecidableEq

namespace MSentence

/-- Diamond (possibility): `◇p := ¬□¬p` — `p` holds in *some* forcing extension. -/
def dia {α} (p : MSentence α) : MSentence α := .neg (.box (.neg p))

end MSentence

/-! ## Kripke semantics for forcing

`R w v` reads "`v` is a forcing extension of `w`".  `M` is the multiverse of
admissible worlds.  `meval R M w p` is the truth of `p` at world `w`. -/

/-- Kripke evaluation of a modal sentence at a world, relative to an accessibility
    relation `R` (the forcing-extension relation) and a multiverse `M`. -/
def meval {α} (R : World α → World α → Prop) (M : Multiverse α) (w : World α) :
    MSentence α → Prop
  | .atom a => w a = true
  | .tru => True
  | .fls => False
  | .neg p => ¬ meval R M w p
  | .conj p q => meval R M w p ∧ meval R M w q
  | .disj p q => meval R M w p ∨ meval R M w q
  | .imp p q => meval R M w p → meval R M w q
  | .box p => ∀ v, R w v → v ∈ M → meval R M v p

/-- A modal sentence is **valid** in the frame `(R, M)` if it is true at every
    admissible world. -/
def MValid {α} (R : World α → World α → Prop) (M : Multiverse α) (p : MSentence α) : Prop :=
  ∀ w ∈ M, meval R M w p

@[simp] theorem meval_atom {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (a : α) : meval R M w (.atom a) ↔ w a = true := Iff.rfl

@[simp] theorem meval_neg {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p : MSentence α) : meval R M w (.neg p) ↔ ¬ meval R M w p := Iff.rfl

@[simp] theorem meval_conj {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p q : MSentence α) :
    meval R M w (.conj p q) ↔ meval R M w p ∧ meval R M w q := Iff.rfl

@[simp] theorem meval_disj {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p q : MSentence α) :
    meval R M w (.disj p q) ↔ meval R M w p ∨ meval R M w q := Iff.rfl

@[simp] theorem meval_imp {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p q : MSentence α) :
    meval R M w (.imp p q) ↔ (meval R M w p → meval R M w q) := Iff.rfl

@[simp] theorem meval_box {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p : MSentence α) :
    meval R M w (.box p) ↔ ∀ v, R w v → v ∈ M → meval R M v p := Iff.rfl

/-! ## Duality between necessity and possibility -/

/-- **Diamond semantics.** `◇p` is true at `w` iff `p` holds in some forcing
    extension of `w`.  This is the defining duality `◇p ↔ ¬□¬p`. -/
theorem meval_dia {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p : MSentence α) :
    meval R M w (MSentence.dia p) ↔ ∃ v, R w v ∧ v ∈ M ∧ meval R M v p := by
  unfold MSentence.dia
  simp only [meval_neg, meval_box]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact h (fun v hRv hvM => by
      have := hc v hRv hvM
      simpa [meval] using this)
  · rintro ⟨v, hRv, hvM, hp⟩ h
    exact (h v hRv hvM) hp

/-- Duality as a validity: `◇p` is valid iff `¬□¬p` is (definitionally). -/
theorem dia_iff_not_box_not {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p : MSentence α) :
    meval R M w (MSentence.dia p) ↔ meval R M w (.neg (.box (.neg p))) := Iff.rfl

/-! ## Soundness of the modal system S4.2 for forcing frames

We isolate the three frame conditions that forcing satisfies and show each
validates the corresponding modal axiom. -/

/-- **Reflexivity** of forcing on `M`: every admissible world is a (trivial)
    forcing extension of itself. -/
def Reflexive {α} (R : World α → World α → Prop) (M : Multiverse α) : Prop :=
  ∀ w ∈ M, R w w

/-- **Transitivity** of forcing: a forcing extension of a forcing extension is a
    forcing extension (iterated forcing). -/
def Transitive {α} (R : World α → World α → Prop) : Prop :=
  ∀ w v u, R w v → R v u → R w u

/-- **Directedness** of forcing: any two forcing extensions of a world have a
    common further extension (amalgamation / product forcing). -/
def Directed {α} (R : World α → World α → Prop) (M : Multiverse α) : Prop :=
  ∀ w ∈ M, ∀ v₁ v₂, R w v₁ → v₁ ∈ M → R w v₂ → v₂ ∈ M →
    ∃ u ∈ M, R v₁ u ∧ R v₂ u

/-- **Axiom K** (distribution): `□(p → q) → (□p → □q)`, valid in every frame. -/
theorem sound_K {α} (R : World α → World α → Prop) (M : Multiverse α)
    (p q : MSentence α) : MValid R M (.imp (.box (.imp p q)) (.imp (.box p) (.box q))) := by
  intro w _ hpq hp v hRv hvM
  exact (hpq v hRv hvM) (hp v hRv hvM)

/-- **Necessitation rule**: a validity is necessarily valid, `⊢ p ⟹ ⊢ □p`. -/
theorem sound_Nec {α} (R : World α → World α → Prop) (M : Multiverse α)
    (p : MSentence α) (h : MValid R M p) : MValid R M (.box p) := by
  intro w _ v _ hvM
  exact h v hvM

/-- **Axiom T** (`□p → p`): valid when forcing is reflexive. -/
theorem sound_T {α} (R : World α → World α → Prop) (M : Multiverse α)
    (hrefl : Reflexive R M) (p : MSentence α) : MValid R M (.imp (.box p) p) := by
  intro w hw hbox
  exact hbox w (hrefl w hw) hw

/-- **Axiom 4** (`□p → □□p`): valid when forcing is transitive. -/
theorem sound_Four {α} (R : World α → World α → Prop) (M : Multiverse α)
    (htrans : Transitive R) (p : MSentence α) : MValid R M (.imp (.box p) (.box (.box p))) := by
  intro w _ hbox v hRv _ u hRu huM
  exact hbox u (htrans w v u hRv hRu) huM

/-- **Axiom .2** (`◇□p → □◇p`, the geometric/directedness axiom): valid when
    forcing is directed.  This is what upgrades `S4` to `S4.2`. -/
theorem sound_Two {α} (R : World α → World α → Prop) (M : Multiverse α)
    (hdir : Directed R M) (p : MSentence α) :
    MValid R M (.imp (MSentence.dia (.box p)) (.box (MSentence.dia p))) := by
  intro w hw hdia v₂ hRv₂ hv₂M
  rw [meval_dia] at hdia
  obtain ⟨v₁, hRv₁, hv₁M, hbox⟩ := hdia
  obtain ⟨u, huM, hR1u, hR2u⟩ := hdir w hw v₁ v₂ hRv₁ hv₁M hRv₂ hv₂M
  rw [meval_dia]
  exact ⟨u, hR2u, huM, hbox u hR1u huM⟩

/-! ## Derived modal principles -/

/-- **Axiom D-style / seriality-free reflexive form** `p → ◇p`: dual of `T`,
    valid when forcing is reflexive (every truth is possible: it holds in the
    trivial extension). -/
theorem sound_T_dual {α} (R : World α → World α → Prop) (M : Multiverse α)
    (hrefl : Reflexive R M) (p : MSentence α) : MValid R M (.imp p (MSentence.dia p)) := by
  intro w hw hp
  rw [meval_dia]
  exact ⟨w, hrefl w hw, hw, hp⟩

/-- **`□` distributes over conjunction**: `□(p ∧ q) ↔ (□p ∧ □q)`. -/
theorem box_conj {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p q : MSentence α) :
    meval R M w (.box (.conj p q)) ↔
      meval R M w (.conj (.box p) (.box q)) := by
  simp only [meval_box, meval_conj]
  constructor
  · intro h; exact ⟨fun v hR hM => (h v hR hM).1, fun v hR hM => (h v hR hM).2⟩
  · rintro ⟨h1, h2⟩ v hR hM; exact ⟨h1 v hR hM, h2 v hR hM⟩

/-- **`◇` distributes over disjunction**: `◇(p ∨ q) ↔ (◇p ∨ ◇q)`. -/
theorem dia_disj {α} (R : World α → World α → Prop) (M : Multiverse α)
    (w : World α) (p q : MSentence α) :
    meval R M w (MSentence.dia (.disj p q)) ↔
      meval R M w (.disj (MSentence.dia p) (MSentence.dia q)) := by
  simp only [meval_disj, meval_dia]
  constructor
  · rintro ⟨v, hR, hM, hpq⟩
    rcases hpq with hp | hq
    · exact Or.inl ⟨v, hR, hM, hp⟩
    · exact Or.inr ⟨v, hR, hM, hq⟩
  · rintro (⟨v, hR, hM, hp⟩ | ⟨v, hR, hM, hq⟩)
    · exact ⟨v, hR, hM, Or.inl hp⟩
    · exact ⟨v, hR, hM, Or.inr hq⟩

/-- **Monotonicity of `□`**: if `p → q` is valid then `□p → □q` is valid. -/
theorem box_mono {α} (R : World α → World α → Prop) (M : Multiverse α)
    (p q : MSentence α) (h : MValid R M (.imp p q)) :
    MValid R M (.imp (.box p) (.box q)) := by
  intro w _ hbox v hRv hvM
  exact h v hvM (hbox v hRv hvM)

/-- **Monotonicity of `◇`**: if `p → q` is valid then `◇p → ◇q` is valid. -/
theorem dia_mono {α} (R : World α → World α → Prop) (M : Multiverse α)
    (p q : MSentence α) (h : MValid R M (.imp p q)) :
    MValid R M (.imp (MSentence.dia p) (MSentence.dia q)) := by
  intro w _ hdia
  rw [meval_dia] at hdia ⊢
  obtain ⟨v, hRv, hvM, hp⟩ := hdia
  exact ⟨v, hRv, hvM, h v hvM hp⟩

/-! ## Packaging the S4.2 soundness theorem -/

/-- A **forcing frame** on a multiverse `M`: an accessibility relation that is
    reflexive, transitive and directed — the abstract multiverse axioms for
    forcing extensions. -/
structure ForcingFrame (α : Type*) where
  /-- The forcing-extension accessibility relation. -/
  R : World α → World α → Prop
  /-- The multiverse of admissible worlds. -/
  M : Multiverse α
  refl : Reflexive R M
  trans : Transitive R
  dir : Directed R M

/-- **Main soundness theorem: forcing validates `S4.2`.**  Every forcing frame
    validates the axioms `K`, `T`, `4`, `.2` and is closed under necessitation. -/
theorem forcing_sound_S42 {α} (F : ForcingFrame α) (p q : MSentence α) :
    MValid F.R F.M (.imp (.box (.imp p q)) (.imp (.box p) (.box q))) ∧
    MValid F.R F.M (.imp (.box p) p) ∧
    MValid F.R F.M (.imp (.box p) (.box (.box p))) ∧
    MValid F.R F.M (.imp (MSentence.dia (.box p)) (.box (MSentence.dia p))) :=
  ⟨sound_K F.R F.M p q,
   sound_T F.R F.M F.refl p,
   sound_Four F.R F.M F.trans p,
   sound_Two F.R F.M F.dir p⟩

/-! ## A concrete forcing frame: flip-reachability

We model a generic extension deciding an atom the other way by *flipping* its
truth value.  Two worlds are mutually accessible when they differ on only
finitely many atoms — the reachable class under finitely many forcing steps. -/

/-- The flip-reachability relation: `v` differs from `w` on a finite set of atoms.
    This is the equivalence class of worlds reachable by finitely many single-atom
    forcing steps. -/
def FlipReach {α} [DecidableEq α] (w v : World α) : Prop :=
  ∃ s : Finset α, ∀ x, v x = if x ∈ s then !(w x) else w x

theorem FlipReach.refl {α} [DecidableEq α] (w : World α) : FlipReach w w :=
  ⟨∅, by intro x; simp⟩

theorem FlipReach.symm {α} [DecidableEq α] {w v : World α}
    (h : FlipReach w v) : FlipReach v w := by
  obtain ⟨s, hs⟩ := h
  refine ⟨s, ?_⟩
  intro x
  by_cases hx : x ∈ s <;> simp [hs x, hx]

theorem FlipReach.trans {α} [DecidableEq α] {w v u : World α}
    (h1 : FlipReach w v) (h2 : FlipReach v u) : FlipReach w u := by
  obtain ⟨s, hs⟩ := h1
  obtain ⟨t, ht⟩ := h2
  refine ⟨symmDiff s t, ?_⟩
  intro x
  rw [ht x, hs x]
  by_cases hxs : x ∈ s <;> by_cases hxt : x ∈ t <;>
    simp [Finset.mem_symmDiff, hxs, hxt]

/-- The **flip-reachability forcing frame** over a multiverse closed under
    flip-reachability.  Concretely we take the *full* multiverse, which is closed
    under all finite flips.  This realises the abstract forcing frame, so it too
    validates `S4.2`. -/
def flipFrame (α : Type*) [DecidableEq α] : ForcingFrame α where
  R := FlipReach
  M := Set.univ
  refl := fun w _ => FlipReach.refl w
  trans := fun _ _ _ h1 h2 => FlipReach.trans h1 h2
  dir := by
    intro w _ v₁ v₂ h1 _ h2 _
    exact ⟨v₁, trivial, FlipReach.refl v₁, (h1.symm.trans h2).symm⟩

/-- The flip-reachability model of forcing validates `S4.2`. -/
theorem flip_sound_S42 {α} [DecidableEq α] (p q : MSentence α) :
    MValid (flipFrame α).R (flipFrame α).M
        (.imp (.box (.imp p q)) (.imp (.box p) (.box q))) ∧
    MValid (flipFrame α).R (flipFrame α).M (.imp (.box p) p) ∧
    MValid (flipFrame α).R (flipFrame α).M (.imp (.box p) (.box (.box p))) ∧
    MValid (flipFrame α).R (flipFrame α).M
        (.imp (MSentence.dia (.box p)) (.box (MSentence.dia p))) :=
  forcing_sound_S42 (flipFrame α) p q

/-! ## Properness: forcing is `S4.2`, not `S5`

The characteristic `S5` axiom `B : p → □◇p` fails in a directed reflexive
transitive forcing frame.  Hence the modal logic of forcing is *properly* weaker
than `S5`: from a generic extension you cannot in general force *back* to the
ground model. -/

/-- A two-world forcing frame over a single atom.  `wT` (atom true) can force to
    `wF` (atom false), but `wF` is a *sink*: no forcing extension of `wF` makes
    the atom true again.  This is reflexive, transitive and directed. -/
def wT : World Bool := fun _ => true
def wF : World Bool := fun _ => false

/-- Sink accessibility: from any world you may force to `wF`, and forcing is
    reflexive.  `wF` has no extension other than itself. -/
def sinkR (x y : World Bool) : Prop := y = wF ∨ x = y

theorem sinkR_refl : Reflexive sinkR Set.univ := fun _ _ => Or.inr rfl

theorem sinkR_trans : Transitive sinkR := by
  intro x y z hxy hyz
  rcases hyz with h | h
  · exact Or.inl h
  · subst h; exact hxy

theorem sinkR_dir : Directed sinkR Set.univ := by
  intro w _ v₁ v₂ _ _ _ _
  exact ⟨wF, trivial, Or.inl rfl, Or.inl rfl⟩

/-- The sink frame is a genuine forcing frame (reflexive, transitive, directed). -/
def sinkFrame : ForcingFrame Bool where
  R := sinkR
  M := Set.univ
  refl := sinkR_refl
  trans := sinkR_trans
  dir := sinkR_dir

theorem wT_ne_wF : wT ≠ wF := by
  intro h
  have : wT true = wF true := by rw [h]
  simp [wT, wF] at this

/-- **Properness of `S4.2`.**  The `S5` axiom `B : p → □◇p` **fails** in the
    (reflexive, transitive, directed) sink forcing frame: the atom is true at
    `wT`, yet from the accessible sink world `wF` no forcing extension recovers
    its truth.  Hence forcing does not validate `S5`. -/
theorem B_fails :
    ¬ MValid sinkFrame.R sinkFrame.M
        (.imp (.atom true) (.box (MSentence.dia (.atom true)))) := by
  intro h
  -- `p → □◇p` at `wT`
  have key : meval sinkFrame.R sinkFrame.M wT
      (.imp (.atom true) (.box (MSentence.dia (.atom true)))) := h wT trivial
  -- `p` is true at `wT`
  have hp : meval sinkFrame.R sinkFrame.M wT (.atom true) := by
    simp [meval, wT]
  -- so `□◇p` holds at `wT`; specialise to the accessible sink `wF`
  have hbox := key hp
  have hwF : sinkFrame.R wT wF := Or.inl rfl
  have hdia : meval sinkFrame.R sinkFrame.M wF (MSentence.dia (.atom true)) :=
    hbox wF hwF trivial
  rw [meval_dia] at hdia
  obtain ⟨u, hRu, _, hpu⟩ := hdia
  -- `wF` is a sink, so `u = wF`, but the atom is false there
  have : u = wF := by
    rcases hRu with h1 | h1
    · exact h1
    · exact h1 ▸ rfl
  subst this
  simp [meval, wF] at hpu

/-! ## Independence recast modally

The multiverse notion of *independence* (true in some world, false in another)
is exactly modal *contingency* `◇p ∧ ◇¬p` under the full-accessibility frame.  We
record the modal reading and a concrete instance. -/

/-- Three atomic set-theoretic assertions, as in the base multiverse file. -/
inductive Claim
  | CH | VeqL | Meas
  deriving DecidableEq, Fintype

open Claim

/-- Gödel's constructible universe: `CH`, `V=L`, no measurable. -/
def godel : World Claim
  | CH => true | VeqL => true | Meas => false

/-- A Cohen extension refuting `CH`. -/
def cohen : World Claim
  | CH => false | VeqL => false | Meas => false

/-- In the flip forcing frame over `{CH, V=L, Meas}`, `CH` is **contingent**:
    both `◇CH` and `◇¬CH` hold at Gödel's universe — CH is possible and its
    negation is possible.  This is the modal face of the independence of `CH`. -/
theorem CH_contingent :
    meval (flipFrame Claim).R (flipFrame Claim).M godel
        (.conj (MSentence.dia (.atom CH)) (MSentence.dia (.neg (.atom CH)))) := by
  refine ⟨?_, ?_⟩
  · rw [meval_dia]
    refine ⟨godel, FlipReach.refl godel, trivial, ?_⟩
    simp [meval, godel]
  · rw [meval_dia]
    refine ⟨cohen, ?_, trivial, ?_⟩
    · exact ⟨{CH, VeqL}, by intro x; cases x <;> simp [godel, cohen]⟩
    · simp [meval, cohen]

/-- Consequently `CH` is **not necessary** in the forcing frame: `¬□CH` at
    Gödel's universe (forcing does not settle the Continuum Hypothesis). -/
theorem CH_not_necessary :
    ¬ meval (flipFrame Claim).R (flipFrame Claim).M godel (.box (.atom CH)) := by
  intro h
  have hcontra := (CH_contingent).2
  rw [meval_dia] at hcontra
  obtain ⟨v, hRv, hvM, hv⟩ := hcontra
  have hvtrue := h v hRv hvM
  simp only [meval] at hvtrue hv
  exact hv hvtrue

/-! ## Bridge: modal contingency = multiverse independence

The base multiverse file calls a sentence **independent** in `M` when it is true
in some admissible world and false in another.  Here we show this is *exactly*
modal **contingency** `◇p ∧ ◇¬p` in the **full-accessibility** forcing frame,
where every admissible world is a forcing extension of every other.  This closes
the conceptual gap between the two files with a single general theorem. -/

/-- Modal independence of `p` in a frame: `p` is satisfied at some admissible
    world and refuted at some admissible world. -/
def MIndependent {α} (R : World α → World α → Prop) (M : Multiverse α)
    (p : MSentence α) : Prop :=
  (∃ v ∈ M, meval R M v p) ∧ (∃ v ∈ M, ¬ meval R M v p)

/-- The **full-accessibility forcing frame**: every world is a forcing extension
    of every other, over the full multiverse.  It is trivially reflexive,
    transitive and directed, hence a genuine forcing frame validating `S4.2`. -/
def fullFrame (α : Type*) : ForcingFrame α where
  R := fun _ _ => True
  M := Set.univ
  refl := fun _ _ => trivial
  trans := fun _ _ _ _ _ => trivial
  dir := fun _ _ v₁ _ _ _ _ _ => ⟨v₁, trivial, trivial, trivial⟩

/-- In the full-accessibility frame, `◇p` at any world means simply that `p`
    holds in *some* admissible world (accessibility imposes no constraint). -/
theorem meval_dia_fullFrame {α} (w : World α) (p : MSentence α) :
    meval (fullFrame α).R (fullFrame α).M w (MSentence.dia p)
      ↔ ∃ v, meval (fullFrame α).R (fullFrame α).M v p := by
  rw [meval_dia]
  constructor
  · rintro ⟨v, _, _, hv⟩; exact ⟨v, hv⟩
  · rintro ⟨v, hv⟩; exact ⟨v, trivial, trivial, hv⟩

/-- **Bridge theorem.**  In the full-accessibility forcing frame, modal
    *contingency* `◇p ∧ ◇¬p` at any world is equivalent to modal *independence*
    of `p`: true in some world, false in another.  Thus the multiverse notion of
    independence *is* the modal notion of contingency once forcing accessibility
    is total. -/
theorem contingent_iff_independent {α} (w : World α) (p : MSentence α) :
    meval (fullFrame α).R (fullFrame α).M w
        (.conj (MSentence.dia p) (MSentence.dia (.neg p)))
      ↔ MIndependent (fullFrame α).R (fullFrame α).M p := by
  simp only [meval_conj, MIndependent]
  rw [meval_dia_fullFrame, meval_dia_fullFrame]
  constructor
  · rintro ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
    exact ⟨⟨v, trivial, hv⟩, ⟨u, trivial, hu⟩⟩
  · rintro ⟨⟨v, _, hv⟩, ⟨u, _, hu⟩⟩
    exact ⟨⟨v, hv⟩, ⟨u, fun hc => hu hc⟩⟩

/-- Contingency is world-independent in the full frame: if `p` is contingent at
    one world it is contingent at every world (independence is a global property
    of the multiverse, not a local one). -/
theorem contingent_global {α} (w w' : World α) (p : MSentence α)
    (h : meval (fullFrame α).R (fullFrame α).M w
          (.conj (MSentence.dia p) (MSentence.dia (.neg p)))) :
    meval (fullFrame α).R (fullFrame α).M w'
        (.conj (MSentence.dia p) (MSentence.dia (.neg p))) :=
  (contingent_iff_independent w' p).2 ((contingent_iff_independent w p).1 h)

end MultiverseModalForcing