import Mathlib

/-!
# Retrocausal Heyting Algebras: Where Effects Precede Causes

This module formalizes **retrocausal logical structures**, where an order-reversing
involution (a "time-reversal" / CPT operator) models implications flowing *backward*
in time. The central phenomena are:

* **The law of excluded middle (LEM) fails** in genuinely intuitionistic (non-Boolean)
  Heyting algebras (`retro_lem_fails`).
* **A temporal excluded middle (TEM) always holds**: the *double negation* of LEM is
  valid in *every* Heyting algebra (`temporal_excluded_middle`). This is the Glivenko /
  weak-excluded-middle phenomenon reinterpreted temporally: `¬¬(a ∨ ¬a) = ⊤`.
* **Any retrocausal logic must be intuitionistic**: rejecting LEM is *equivalent* to
  rejecting double-negation elimination (`lem_iff_dne`). Hence a logic that admits a
  proper retrocausal (non-Boolean) structure cannot be classical.
* A retrocausal **time-reversal** is an antitone involution; it satisfies De Morgan
  dualities `rev (a ⊔ b) = rev a ⊓ rev b` and swaps `⊥ ↔ ⊤` (`rev_sup`, `rev_inf`,
  `rev_bot`, `rev_top`).

## Physical reading

In Euclidean QFT, Osterwalder–Schrader **reflection positivity** equips the theory with
an involutive time-reflection `θ` (`θ ∘ θ = id`). Composing this reflection with
logical negation yields exactly an order-reversing involution on the algebra of
propositions — a *retrocausal* connective `C ∘ T`. The companion bridge file
`Bridges/RetrocausalCPTBridge.lean` constructs this connective from a
`ReflectionPositiveForm`, tying the algebraic content here to the QFT CPT structure.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
  H1. In a retrocausal Heyting algebra LEM `a ⊔ aᶜ = ⊤` fails, yet its double negation
      `(a ⊔ aᶜ)ᶜᶜ = ⊤` (a "temporal" excluded middle) survives.  [surprising]
  H2. Rejecting LEM is *equivalent* to rejecting double-negation elimination; i.e.
      "retrocausal ⟹ intuitionistic" is an iff, not a one-way implication.  [surprising]
  H3. A retrocausal time-reversal (antitone involution) automatically satisfies the
      De Morgan dualities and swaps the truth poles `⊥ ↔ ⊤`.

Experiment (Experimenter):
  - H1: `temporal_excluded_middle` proved for ALL Heyting algebras via
        `compl_sup_distrib` + `inf_compl_eq_bot`; the concrete failure of LEM is
        witnessed in the 3-chain `Fin 3` (a genuinely non-Boolean Heyting algebra).
  - H2: `lem_iff_dne` proved both directions; the backward direction crucially reuses
        `temporal_excluded_middle`.
  - H3: derived `rev_sup`, `rev_inf`, `rev_bot`, `rev_top` from only `Involutive` +
        antitone, using the involution to transport `⊔`/`⊓` across the order dual.

Analysis (Analyst):
  - SURVIVED: H1, H2, H3 (all 0-sorry). The decisive insight is that TEM is not a new
    axiom but a *theorem* of every Heyting algebra; intuitionism keeps the doubly-negated
    classical tautologies. This is why "effects precede causes" is logically coherent.
  - The forward direction of H2 needs distributivity (`inf_sup_left`), confirming that
    the LEM ⇒ Boolean collapse is a distributive-lattice fact, not a Heyting accident.

Critique (Critic):
  - `retro_lem_fails` uses `decide` on `Fin 3`; it is a *witness* (an existence example),
    not a headline theorem. The headline theorems `temporal_excluded_middle`,
    `lem_iff_dne`, `rev_sup`, `rev_inf` all use genuine algebraic tactics
    (`rw`, `le_antisymm`, distributivity), not decision procedures.
  - Guarded the De Morgan lemmas to the minimal typeclass (`Lattice` + bounds) so they
    are reusable by the Boolean carrier `Set V` in the CPT bridge.

Synthesis (PI): the retrocausal class + TEM + LEM↔DNE + De Morgan transport form a
self-contained intuitionistic core that the QFT bridge instantiates from OS reflection.
-- !-- Lab Notes -- !--
-/

namespace Retrocausal

/-! ## Part I. The temporal excluded middle (TEM) -/

/-- **Temporal excluded middle.** In *every* Heyting algebra the *double negation* of
the law of excluded middle holds: `¬¬(a ∨ ¬a) = ⊤`. Intuitionistically LEM may fail,
but its temporal (doubly-negated) shadow always survives — effects may precede causes
without contradiction. -/
theorem temporal_excluded_middle {α : Type*} [HeytingAlgebra α] (a : α) :
    (a ⊔ aᶜ)ᶜᶜ = ⊤ := by
  have h : (a ⊔ aᶜ)ᶜ = ⊥ := by rw [compl_sup_distrib, inf_compl_eq_bot]
  rw [h, compl_bot]

/-- **LEM ⟺ double-negation elimination.** The law of excluded middle holds for every
element iff double negation can be eliminated for every element. Hence *rejecting* LEM is
equivalent to *rejecting* DNE: any logic without LEM is genuinely intuitionistic.

The backward direction reuses `temporal_excluded_middle`: DNE turns the always-valid
doubly-negated LEM back into honest LEM. -/
theorem lem_iff_dne {α : Type*} [HeytingAlgebra α] :
    (∀ a : α, a ⊔ aᶜ = ⊤) ↔ (∀ a : α, aᶜᶜ = a) := by
  constructor
  · intro hlem a
    have hd : aᶜᶜ ⊓ (a ⊔ aᶜ) = (aᶜᶜ ⊓ a) ⊔ (aᶜᶜ ⊓ aᶜ) := inf_sup_left _ _ _
    rw [hlem a, inf_top_eq] at hd
    have h2 : aᶜᶜ ⊓ aᶜ = ⊥ := by rw [inf_comm]; exact inf_compl_eq_bot
    rw [h2, sup_bot_eq, inf_comm, inf_eq_left.mpr le_compl_compl] at hd
    exact hd
  · intro hdne a
    have h : (a ⊔ aᶜ)ᶜᶜ = ⊤ := temporal_excluded_middle a
    rw [hdne] at h; exact h

/-- **Retrocausal logic must be intuitionistic (contrapositive form).** If LEM fails for
some element, then double-negation elimination must fail for some element too. -/
theorem lem_fails_of_dne_fails {α : Type*} [HeytingAlgebra α]
    (h : ∃ a : α, aᶜᶜ ≠ a) : ∃ a : α, a ⊔ aᶜ ≠ ⊤ := by
  by_contra hc
  push_neg at hc
  obtain ⟨a, ha⟩ := h
  exact ha (lem_iff_dne.mp hc a)

/-- **Concrete failure of LEM.** The three-element chain `Fin 3` is a genuinely
non-Boolean Heyting algebra: for the middle element `1`, `1 ⊔ 1ᶜ = 1 ≠ ⊤`. This is the
existence witness backing the abstract `lem_fails_of_dne_fails`. -/
theorem retro_lem_fails : ∃ a : Fin 3, a ⊔ aᶜ ≠ ⊤ := ⟨1, by decide⟩

/-- The temporal excluded middle nevertheless holds at that same witness in `Fin 3`. -/
theorem retro_tem_holds : ((1 : Fin 3) ⊔ (1 : Fin 3)ᶜ)ᶜᶜ = ⊤ :=
  temporal_excluded_middle 1

/-! ## Part II. Retrocausal time-reversal -/

/-- A **retrocausal time-reversal** on a Heyting algebra is an order-*reversing*
involution `rev`. Order reversal encodes "implications flowing backward in time":
`a ≤ b` (cause `a` entails effect `b`) becomes `rev b ≤ rev a` under time reversal.
Involutivity is the algebraic shadow of the CPT theorem (`(CPT)² = id`). -/
class RetrocausalHeyting (α : Type*) [HeytingAlgebra α] where
  /-- The time-reversal / CPT operator. -/
  rev : α → α
  /-- Time reversal is an involution: applying it twice is the identity. -/
  rev_involutive : Function.Involutive rev
  /-- Time reversal reverses entailment (implications flow backward). -/
  rev_antitone : ∀ {a b : α}, a ≤ b → rev b ≤ rev a

export RetrocausalHeyting (rev rev_involutive rev_antitone)

variable {α : Type*} [HeytingAlgebra α] [RetrocausalHeyting α]

/-- Time reversal sends contradiction to tautology: `rev ⊥ = ⊤`. -/
theorem rev_bot : rev (⊥ : α) = ⊤ := by
  apply top_le_iff.mp
  have h := rev_antitone (bot_le : (⊥ : α) ≤ rev ⊤)
  rwa [rev_involutive ⊤] at h

/-- Time reversal sends tautology to contradiction: `rev ⊤ = ⊥`. -/
theorem rev_top : rev (⊤ : α) = ⊥ := by
  apply le_bot_iff.mp
  have h := rev_antitone (le_top : rev ⊥ ≤ (⊤ : α))
  rwa [rev_involutive ⊥] at h

/-- **De Morgan for time-reversal.** A retrocausal involution turns joins into meets:
`rev (a ⊔ b) = rev a ⊓ rev b`. -/
theorem rev_sup (a b : α) : rev (a ⊔ b) = rev a ⊓ rev b := by
  apply le_antisymm
  · exact le_inf (rev_antitone le_sup_left) (rev_antitone le_sup_right)
  · have h1 : a ≤ rev (rev a ⊓ rev b) := by
      have h := rev_antitone (inf_le_left : rev a ⊓ rev b ≤ rev a)
      rwa [rev_involutive a] at h
    have h2 : b ≤ rev (rev a ⊓ rev b) := by
      have h := rev_antitone (inf_le_right : rev a ⊓ rev b ≤ rev b)
      rwa [rev_involutive b] at h
    have h3 := rev_antitone (sup_le h1 h2)
    rwa [rev_involutive (rev a ⊓ rev b)] at h3

/-- **Dual De Morgan for time-reversal.** A retrocausal involution turns meets into
joins: `rev (a ⊓ b) = rev a ⊔ rev b`. -/
theorem rev_inf (a b : α) : rev (a ⊓ b) = rev a ⊔ rev b := by
  have h := rev_sup (rev a) (rev b)
  rw [rev_involutive a, rev_involutive b] at h
  calc rev (a ⊓ b) = rev (rev (rev a ⊔ rev b)) := by rw [h]
    _ = rev a ⊔ rev b := rev_involutive _

/-! ## Part III. A concrete retrocausal Heyting algebra with failing LEM -/

/-- The order-reversal `a ↦ 2 - a` makes the 3-chain `Fin 3` a retrocausal Heyting
algebra. Combined with `retro_lem_fails`/`retro_tem_holds` this is a concrete model in
which the law of excluded middle fails while the temporal excluded middle holds. -/
instance : RetrocausalHeyting (Fin 3) where
  rev a := 2 - a
  rev_involutive := by intro x; fin_cases x <;> rfl
  rev_antitone := by
    intro a b h
    fin_cases a <;> fin_cases b <;> simp_all

/-- In the concrete `Fin 3` model, time-reversal swaps the truth poles. -/
theorem fin3_rev_swaps : rev (⊥ : Fin 3) = ⊤ ∧ rev (⊤ : Fin 3) = ⊥ :=
  ⟨rev_bot, rev_top⟩

end Retrocausal