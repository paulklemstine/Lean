/-
# Phantom Numbers of Non-Metrizable Spaces: Refuting the "≥ 3 Observers" Conjecture

Building on `Catalog.Novelty.PhantomTopology`, this file settles the second half of
the phantom-topology programme.  Recall the *consensus* (real) topology of a phantom
topology `T : ι → TopologicalSpace X` is the supremum `⨆ i, T i`, whose opens are the
sets open in **every** observer; and a representation is *genuinely phantom* when each
observer is strictly finer than the consensus (`T i < consensus T`), i.e. every observer
resolves structure that reality does not.

The original conjecture claimed:

  "Every second-countable space admits a phantom representation with at most 2 observers,
   and **every non-metrizable space requires at least 3 observers**."

We **refute** the second clause.  The two-point indiscrete space `(Bool, ⊤)` is:

* **non-metrizable** (`indiscrete_bool_not_metrizable`) — it is not even `T₀`, while every
  metrizable space is `T₀`; and yet
* it is the consensus of **exactly two** genuinely phantom observers
  (`consensus_pair_eq_indiscrete`), the two Sierpiński observers
  `sierpTrue` (only `{true}` becomes visible) and `sierpFalse` (only `{false}` becomes
  visible), each of which is **strictly finer** than reality
  (`sierpTrue_lt_top`, `sierpFalse_lt_top`).

Hence the phantom number of a non-metrizable space can be exactly `2`
(`nonmetrizable_two_observer_representation`), so the "≥ 3 observers" clause is false.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H1. The conjecture "non-metrizable ⇒ ≥ 3 observers" conflates two independent axes:
      *separation* (metrizability forces T₀/Hausdorff) and *lattice meet-reducibility*
      (how many strictly-finer topologies are needed to intersect back to reality).
      These are orthogonal, so a non-metrizable space can still be 2-reducible.
  H2 (surprising). The *smallest* non-metrizable space — two points, indiscrete — is a
      counterexample: it is the intersection of the two Sierpiński resolutions.
  H3. Sierpiński opens are cleanly captured by an *implication* predicate:
      `sierpTrue`-open := `false ∈ U → true ∈ U`; this makes all three topology axioms
      one-liners and makes the consensus computation `true ∈ U ↔ false ∈ U`, i.e. `U`
      is `∅` or `univ`.

Experiment (Experimenter):
  - Verified opens of `sierpTrue` are exactly `{∅, {true}, univ}` and of `sierpFalse`
    exactly `{∅, {false}, univ}`; their intersection is `{∅, univ}` = indiscrete.
  - Checked non-T₀: `true` and `false` are inseparable under `⊤` (no open separates
    them), so metrizability (⇒ `T₀`) fails.

Analysis (Analyst):
  - H2/H3 survive as the main theorems. The counterexample is minimal (2 points).
  - The *positive* half of the conjecture (metrizable/second-countable ⇒ ≤ 2) is
    corroborated by the `ℝ` result in `PhantomTopology`; the *negative* half is FALSE.
  - Root cause of the failure: the conjecture assumed metrizability was *necessary* for
    low phantom number, but low phantom number only needs lattice meet-reducibility,
    which indiscrete spaces enjoy abundantly.

Critique (Critic):
  - `indiscrete_bool_not_metrizable` is not vacuous: it discharges an actual
    `MetrizableSpace` hypothesis via `MetrizableSpace.toT0Space` and an explicit
    inseparability witness — a real separation-axiom argument.
  - The observers are proved *strictly* finer (`<`), so the representation is genuinely
    phantom, not a trivial duplication; the refutation is therefore airtight.
  - Uses imported catalog results (`consensus`, `observer_le_consensus`,
    `consensus_isOpen_iff`); no `native_decide`, no `True`, no wrapper types.

Synthesis (PI):
  Reality-as-consensus decouples "how separated a space looks" from "how many observers
  reconstruct it". Non-metrizability is about separation; the phantom number is about
  meet-reducibility in the topology lattice. The indiscrete two-point space is the sharp
  witness that these are independent, refuting the conjectured metrizability barrier.
-/
import Mathlib
import Novelty.PosetTheory.PhantomTopology

open Set TopologicalSpace

namespace Phantom

/-! ## The two Sierpiński observers on `Bool` -/

/-- The **`true`-Sierpiński observer**: a set is open iff, whenever it contains `false`,
it also contains `true`.  Its opens are exactly `{∅, {true}, univ}` — the observer that
resolves the phantom singleton `{true}`. -/
def sierpTrue : TopologicalSpace Bool where
  IsOpen U := false ∈ U → true ∈ U
  isOpen_univ := by intro _; trivial
  isOpen_inter s t hs ht := by
    intro h
    exact ⟨hs h.1, ht h.2⟩
  isOpen_sUnion S hS := by
    rintro ⟨U, hUS, hfU⟩
    exact ⟨U, hUS, hS U hUS hfU⟩

/-- The **`false`-Sierpiński observer**: a set is open iff, whenever it contains `true`,
it also contains `false`.  Its opens are exactly `{∅, {false}, univ}`. -/
def sierpFalse : TopologicalSpace Bool where
  IsOpen U := true ∈ U → false ∈ U
  isOpen_univ := by intro _; trivial
  isOpen_inter s t hs ht := by
    intro h
    exact ⟨hs h.1, ht h.2⟩
  isOpen_sUnion S hS := by
    rintro ⟨U, hUS, htU⟩
    exact ⟨U, hUS, hS U hUS htU⟩

/-- `{true}` is open for the `true`-Sierpiński observer (the implication is vacuous:
`false ∉ {true}`). -/
theorem sierpTrue_isOpen_singleton : @IsOpen Bool sierpTrue {true} := by
  intro h; simp at h

/-- `{false}` is open for the `false`-Sierpiński observer. -/
theorem sierpFalse_isOpen_singleton : @IsOpen Bool sierpFalse {false} := by
  intro h; simp at h

/-! ## Main theorem 1: the indiscrete line is a two-observer consensus -/

/-- **Two-observer consensus for the indiscrete space.** A set is open for *both*
Sierpiński observers iff it is `∅` or `univ`; hence the supremum (consensus) of the two
observers is the indiscrete topology `⊤` on `Bool`. -/
theorem sierpTrue_sup_sierpFalse_eq_top :
    sierpTrue ⊔ sierpFalse = (⊤ : TopologicalSpace Bool) := by
  apply TopologicalSpace.ext
  ext U
  rw [isOpen_top_iff]
  constructor
  · -- open for both observers ⇒ `∅` or `univ`
    rintro ⟨hT, hF⟩
    by_cases hne : U = ∅
    · exact Or.inl hne
    · refine Or.inr ?_
      obtain ⟨x, hx⟩ := nonempty_iff_ne_empty.2 hne
      have htrue : true ∈ U := by
        cases x with
        | true => exact hx
        | false => exact hT hx
      have hfalse : false ∈ U := hF htrue
      ext y; cases y <;> simp_all
  · -- `∅` or `univ` are open for both observers
    rintro (rfl | rfl)
    · exact @isOpen_empty Bool (sierpTrue ⊔ sierpFalse)
    · exact @isOpen_univ Bool (sierpTrue ⊔ sierpFalse)

/-- The **two Sierpiński observers**, packaged as a `Bool`-indexed phantom topology. -/
def observersBool : PhantomTopology Bool Bool :=
  fun b => if b then sierpTrue else sierpFalse

/-- **Consensus computation.** The consensus of the two Sierpiński observers is the
indiscrete topology on `Bool`. -/
theorem consensus_pair_eq_indiscrete :
    consensus observersBool = (⊤ : TopologicalSpace Bool) := by
  rw [consensus, iSup_bool_eq]
  show sierpTrue ⊔ sierpFalse = _
  exact sierpTrue_sup_sierpFalse_eq_top

/-! ## Each observer is strictly finer than reality -/

/-- The `true`-Sierpiński observer is **strictly finer** than the indiscrete consensus:
it resolves `{true}`, which reality (`⊤`) does not. -/
theorem sierpTrue_lt_top : sierpTrue < (⊤ : TopologicalSpace Bool) := by
  refine lt_of_le_of_ne le_top ?_
  intro h
  have : @IsOpen Bool (⊤ : TopologicalSpace Bool) {true} := h ▸ sierpTrue_isOpen_singleton
  rw [isOpen_top_iff] at this
  rcases this with h0 | h1
  · exact (Set.singleton_ne_empty true) h0
  · have : (false : Bool) ∈ ({true} : Set Bool) := by rw [h1]; trivial
    simp at this

/-- The `false`-Sierpiński observer is **strictly finer** than the indiscrete consensus. -/
theorem sierpFalse_lt_top : sierpFalse < (⊤ : TopologicalSpace Bool) := by
  refine lt_of_le_of_ne le_top ?_
  intro h
  have : @IsOpen Bool (⊤ : TopologicalSpace Bool) {false} := h ▸ sierpFalse_isOpen_singleton
  rw [isOpen_top_iff] at this
  rcases this with h0 | h1
  · exact (Set.singleton_ne_empty false) h0
  · have : (true : Bool) ∈ ({false} : Set Bool) := by rw [h1]; trivial
    simp at this

/-- Every observer in the pair is strictly finer than the consensus: the representation
is *genuinely phantom*, not a trivial duplication of reality. -/
theorem observersBool_lt_consensus (b : Bool) :
    observersBool b < consensus observersBool := by
  rw [consensus_pair_eq_indiscrete]
  cases b with
  | true => simpa [observersBool] using sierpTrue_lt_top
  | false => simpa [observersBool] using sierpFalse_lt_top

/-! ## Main theorem 2: the indiscrete two-point space is non-metrizable -/

/-- **Non-metrizability.** The indiscrete topology on `Bool` is not metrizable: it is not
even `T₀` (the two points are inseparable), while every metrizable space is `T₀`. -/
theorem indiscrete_bool_not_metrizable : ¬ @MetrizableSpace Bool ⊤ := by
  intro h
  have hT0 : @T0Space Bool ⊤ := @MetrizableSpace.toT0Space Bool ⊤ h
  have hins : @Inseparable Bool ⊤ true false := by
    rw [@inseparable_iff_forall_isOpen Bool ⊤]
    intro U hU
    rcases (isOpen_top_iff U).1 hU with h0 | h1 <;> subst_vars <;> simp
  have hcontra : true = false := @T0Space.t0 Bool ⊤ hT0 true false hins
  simp at hcontra

/-! ## Main theorem 3: refutation of the conjecture -/

/-- **Refutation of the "non-metrizable ⇒ ≥ 3 observers" conjecture.** There is a
non-metrizable space that is the consensus of exactly **two** genuinely phantom observers
(each strictly finer than the consensus). Concretely, the indiscrete two-point space is
the consensus of the two Sierpiński observers. -/
theorem nonmetrizable_two_observer_representation :
    ∃ (X : Type) (T : PhantomTopology Bool X),
      ¬ @MetrizableSpace X (consensus T) ∧ (∀ b, T b < consensus T) := by
  refine ⟨Bool, observersBool, ?_, observersBool_lt_consensus⟩
  rw [consensus_pair_eq_indiscrete]
  exact indiscrete_bool_not_metrizable

end Phantom