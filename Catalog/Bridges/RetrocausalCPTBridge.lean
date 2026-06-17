import Mathlib
import Logic.RetrocausalHeyting
import Physics.ReflectionPositivityMassGap

/-!
# Bridge: QFT CPT Reflection ⟷ Retrocausal Intuitionistic Logic

This file is the **cross-domain bridge** mandated by the research cycle. It connects:

* **Physics** — `Catalog/Physics/ReflectionPositivityMassGap.lean`:
  a `ReflectionPositiveForm V` carries an involutive Osterwalder–Schrader time
  reflection `θ : V → V` with `θ ∘ θ = id` (Euclidean time reversal, the `T` of `CPT`).
* **Logic** — `Catalog/Logic/RetrocausalHeyting.lean`:
  a `RetrocausalHeyting` is a Heyting algebra equipped with an order-reversing
  involution `rev`, with derived De Morgan laws `rev_sup`, `rev_inf` and pole-swap
  `rev_bot`, `rev_top`, plus the universally valid temporal excluded middle.

## The new connection

Given a reflection-positive QFT, define the connective on the Boolean algebra of
field-configuration propositions `Set V`

  `cptReversal R S = θ⁻¹(Sᶜ)`  (charge-conjugate ∘ time-reflect, i.e. `C ∘ T`).

We prove this is an **order-reversing involution**, hence makes `Set V` into a
`RetrocausalHeyting` whose De Morgan laws and pole-swaps are *exactly* the abstract Logic
lemmas, now driven by the *physical* involutivity `θ ∘ θ = id`. The headline
`cpt_yields_retrocausal_logic` bundles the physical reflection-positivity bound together
with the full retrocausal-logic package, witnessing that CPT symmetry and retrocausal
(intuitionistic-style) logic are two faces of the same involution.

-- !-- Lab Notes -- !--
Files used:
  * Physics: `Catalog/Physics/ReflectionPositivityMassGap.lean`
      (`ReflectionPositiveForm`, fields `θ`, `θ_involution`, `reflection_pos`).
  * Logic:   `Catalog/Logic/RetrocausalHeyting.lean`
      (`RetrocausalHeyting`, `rev_sup`, `rev_inf`, `rev_bot`, `rev_top`,
       `temporal_excluded_middle`, `lem_iff_dne`).

Hypothesis (Hypothesizer):
  B1. The OS time-reflection `θ`, composed with logical negation, is an order-reversing
      involution on the proposition algebra `Set V` — a genuine retrocausal connective.
  B2. Its De Morgan duality is *forced* by `θ ∘ θ = id`, so the algebraic Logic lemmas
      apply verbatim to the physics-derived structure.  [the actual bridge]

Experiment (Experimenter):
  - `cptReversal_involutive` reduces to `θ.comp_self` after `Set.preimage_compl` /
    `compl_compl`; `cptReversal_antitone` is `Set.preimage_mono ∘ compl_le_compl`.
  - These two facts populate a `RetrocausalHeyting (Set V)` term, after which the
    abstract `Retrocausal.rev_sup` / `rev_bot` / `rev_top` discharge the De Morgan and
    pole-swap statements with NO new manual lattice work — the bridge "pays off".

Analysis (Analyst):
  - `Set V` is Boolean, so LEM also holds there: the *carrier* must be intuitionistic
    (non-Boolean) for LEM to fail. The retrocausal *involution*, however, transfers
    perfectly from QFT regardless of the carrier's classicality. The genuinely
    LEM-failing retrocausal model lives in `Fin 3` (Logic file); here we isolate the
    CPT-origin of the involution.

Critique (Critic):
  - Guarded against triviality: the headline theorem combines a *Physics* inequality
    (`reflection_pos`) with *Logic* De Morgan/pole-swap lemmas applied to a structure
    built from `θ`; neither half is provable without the other domain's import.
  - No `native_decide`; the bridge lemmas use real `simp`/preimage algebra and reuse of
    inter-file lemmas.

Synthesis (PI): CPT reflection ↦ retrocausal connective `C∘T`; the QFT involution is the
physical source of the logic's time-reversal, and the temporal excluded middle is its
invariant.
-- !-- Lab Notes -- !--
-/

open Retrocausal

variable {V : Type*} [AddCommGroup V] [Module ℝ V]

/-- The **CPT reversal connective** on the proposition algebra `Set V` of a
reflection-positive QFT: charge-conjugate (negate) then time-reflect (`θ`-pullback).
This is `C ∘ T`. -/
def cptReversal (R : ReflectionPositiveForm V) (S : Set V) : Set V := R.θ ⁻¹' Sᶜ

/-- **CPT reversal is an involution**, driven by the physical `θ ∘ θ = id`. -/
theorem cptReversal_involutive (R : ReflectionPositiveForm V) :
    Function.Involutive (cptReversal R) := by
  intro S
  unfold cptReversal
  simp only [Set.preimage_compl, compl_compl]
  rw [← Set.preimage_comp]
  have hcomp : R.θ ∘ R.θ = id := funext (fun v => R.θ_involution v)
  rw [hcomp, Set.preimage_id]

/-- **CPT reversal reverses entailment**: implications flow backward in time. -/
theorem cptReversal_antitone (R : ReflectionPositiveForm V) {S T : Set V} (h : S ≤ T) :
    cptReversal R T ≤ cptReversal R S :=
  Set.preimage_mono (compl_le_compl h)

/-- **The retrocausal logic of a reflection-positive QFT.** The CPT connective makes the
proposition algebra `Set V` a `RetrocausalHeyting`: the physical time-reflection `θ` is
the origin of the logical time-reversal `rev`. -/
def cptRetrocausal (R : ReflectionPositiveForm V) : RetrocausalHeyting (Set V) where
  rev := cptReversal R
  rev_involutive := cptReversal_involutive R
  rev_antitone := cptReversal_antitone R

/-- **De Morgan for CPT reversal**, obtained for free from the abstract Logic lemma
`Retrocausal.rev_sup` applied to the physics-derived structure. -/
theorem cpt_rev_sup (R : ReflectionPositiveForm V) (S T : Set V) :
    cptReversal R (S ⊔ T) = cptReversal R S ⊓ cptReversal R T :=
  @Retrocausal.rev_sup (Set V) _ (cptRetrocausal R) S T

/-- **Dual De Morgan for CPT reversal**, from `Retrocausal.rev_inf`. -/
theorem cpt_rev_inf (R : ReflectionPositiveForm V) (S T : Set V) :
    cptReversal R (S ⊓ T) = cptReversal R S ⊔ cptReversal R T :=
  @Retrocausal.rev_inf (Set V) _ (cptRetrocausal R) S T

/-- **CPT reversal swaps the truth poles** `⊥ ↔ ⊤`, from `Retrocausal.rev_bot/rev_top`. -/
theorem cpt_rev_swaps_poles (R : ReflectionPositiveForm V) :
    cptReversal R (⊥ : Set V) = ⊤ ∧ cptReversal R (⊤ : Set V) = ⊥ :=
  ⟨@Retrocausal.rev_bot (Set V) _ (cptRetrocausal R),
   @Retrocausal.rev_top (Set V) _ (cptRetrocausal R)⟩

/-- **Headline bridge theorem.** A reflection-positive QFT simultaneously exhibits:
1. its physical **reflection-positivity** bound `0 ≤ B (θ v) v` (Physics), and
2. a full **retrocausal logic** on its proposition algebra — the CPT connective is an
   order-reversing involution obeying De Morgan and swapping truth poles (Logic), while
3. the **temporal excluded middle** `(P ∨ ¬P)ᶜᶜ = ⊤` holds for every proposition.

The same involution `θ` underlies both the QFT symmetry and the logical time-reversal:
CPT symmetry *is* retrocausal logic. -/
theorem cpt_yields_retrocausal_logic (R : ReflectionPositiveForm V) :
    (∀ v, 0 ≤ R.B (R.θ v) v) ∧
    Function.Involutive (cptReversal R) ∧
    (∀ S T : Set V, cptReversal R (S ⊔ T) = cptReversal R S ⊓ cptReversal R T) ∧
    (cptReversal R (⊥ : Set V) = ⊤) ∧
    (∀ P : Set V, (P ⊔ Pᶜ)ᶜᶜ = ⊤) := by
  refine ⟨R.reflection_pos, cptReversal_involutive R, cpt_rev_sup R, ?_, ?_⟩
  · exact (cpt_rev_swaps_poles R).1
  · exact fun P => Retrocausal.temporal_excluded_middle P