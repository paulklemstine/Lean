import Mathlib
import Algebra.ObservationGap

/-!
# The Adaptive Observation Gap: Decision-Tree Indistinguishability

This file extends the *static* observation framework of
`Catalog/Algebra/ObservationGap.lean` (`ObservationGap.ObsSys`,
`observation_pigeonhole`, `observation_quotient_card_le`, `observation_can_suffice`)
to **adaptive** observation systems, where the predicate asked at step `k+1` may
depend on the answers to the first `k` predicates.

The static pigeonhole theorem is a counting argument on the product type
`Fin n → Bool`. The adaptive theorem cannot be proved that way directly — the
predicates are no longer a fixed family — so we model an adaptive observation
system as a **binary decision tree** of depth `n` and argue by structural
recursion on the tree. The crucial conceptual point (Shannon's "1 bit per query"
heuristic, made precise) is that, even though the queries are adaptive, the
*transcript* of answers for a given element still lives in `Fin n → Bool`, a set
of size `2 ^ n`. Hence adaptivity buys no extra discriminative power.

## Main results

* `AdaptiveObs` / `AdaptiveObs.transcript` — the decision-tree model and the
  answer transcript of each element.
* `adaptive_card_le_of_distinguishes` — an adaptive system of depth `n` that
  distinguishes all elements forces `|α| ≤ 2 ^ n`.
* `adaptive_observation_pigeonhole` — the adaptive analogue of
  `ObservationGap.observation_pigeonhole`: if `2 ^ n < |α|` then some adaptive
  system of depth `n` admits a twin pair (in fact *every* such system does).
* `AdaptiveObs.ofStatic` and `transcript_ofStatic` — the **bridge**: every static
  `ObservationGap.ObsSys α n` embeds into an adaptive system with *identical*
  transcripts, so the static theory is the history-independent special case.
* `adaptive_can_suffice` — boundary: on `Fin (2 ^ n)` an adaptive system *can*
  distinguish all elements, matching `ObservationGap.observation_can_suffice`.
* `adaptive_quotient_card_le` — the adaptive observational quotient has at most
  `2 ^ n` classes, the adaptive analogue of
  `ObservationGap.observation_quotient_card_le`.
-/

namespace AdaptiveObservationGap

universe u

-- ============================================================================
-- The decision-tree model of an adaptive observation system
-- ============================================================================

/-- An **adaptive observation system** of depth `n` on `α`: a binary decision
tree. A `node p f` asks the Boolean predicate `p` and then continues with the
subtree `f b` determined by the answer `b`. -/
inductive AdaptiveObs (α : Type u) : ℕ → Type u
  | nil : AdaptiveObs α 0
  | node {n : ℕ} : (α → Bool) → (Bool → AdaptiveObs α n) → AdaptiveObs α (n + 1)

namespace AdaptiveObs

/-- The **transcript** of an element `a`: the length-`n` sequence of answers
obtained by running the adaptive system on `a`. Even though the queries are
adaptive, the transcript lives in `Fin n → Bool`. -/
def transcript {α : Type u} : {n : ℕ} → AdaptiveObs α n → α → (Fin n → Bool)
  | 0, _, _ => Fin.elim0
  | _ + 1, .node p f, a => Fin.cons (p a) (transcript (f (p a)) a)

/-- Two elements are adaptive twins if they produce the same transcript. -/
def twins {α : Type u} {n : ℕ} (O : AdaptiveObs α n) (a b : α) : Prop :=
  O.transcript a = O.transcript b

/-- Adaptive twinhood is an equivalence relation. -/
theorem twins_equivalence {α : Type u} {n : ℕ} (O : AdaptiveObs α n) :
    Equivalence O.twins :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- The setoid induced by adaptive observational equivalence. -/
def setoid {α : Type u} {n : ℕ} (O : AdaptiveObs α n) : Setoid α where
  r := O.twins
  iseqv := twins_equivalence O

end AdaptiveObs

/-
============================================================================
Theorem 1: the adaptive cardinality bound and pigeonhole
============================================================================

!-- The transcript map lands in `Fin n → Bool` (card `2^n`); if it is injective
then `Fintype.card_le_of_injective` gives `|α| ≤ 2^n`. -- !--

**Adaptive cardinality bound.** If an adaptive system of depth `n`
distinguishes all elements (its transcript map is injective) then `|α| ≤ 2 ^ n`.
-/
theorem adaptive_card_le_of_distinguishes {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) (hinj : Function.Injective O.transcript) :
    Fintype.card α ≤ 2 ^ n := by
  have := Fintype.card_le_of_injective O.transcript hinj; simp_all +decide [ Fintype.card_pi ] ;

/-
!-- Apply `Fintype.exists_ne_map_eq_of_card_lt` to the transcript map; the
codomain `Fin n → Bool` has card `2^n < |α|`. -- !--

**Adaptive Observation Pigeonhole.** If `2 ^ n < |α|`, then *any* adaptive
observation system of depth `n` admits a twin pair: adaptivity does not beat the
static bound `ObservationGap.observation_pigeonhole`.
-/
theorem adaptive_observation_pigeonhole {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) (hcard : 2 ^ n < Fintype.card α) :
    ∃ a b : α, a ≠ b ∧ O.twins a b := by
  contrapose! hcard;
  convert adaptive_card_le_of_distinguishes O _;
  exact fun a b hab => Classical.not_not.1 fun h => hcard a b h hab

-- ============================================================================
-- Theorem 2: quotient cardinality bound
-- ============================================================================

/-- Fintype instance for the adaptive observation quotient. -/
noncomputable instance {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) : Fintype (Quotient O.setoid) := by
  letI : DecidableRel O.setoid.r := fun a b =>
    inferInstanceAs (Decidable (O.transcript a = O.transcript b))
  exact Quotient.fintype O.setoid

/-
!-- The transcript descends to an injection on the quotient by definition of
`twins`; `Fintype.card_le_of_injective` then bounds the number of classes. -- !--

**Adaptive Quotient Bound.** The adaptive observation quotient has at most
`2 ^ n` classes — the adaptive analogue of
`ObservationGap.observation_quotient_card_le`.
-/
theorem adaptive_quotient_card_le {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) :
    Fintype.card (Quotient O.setoid) ≤ 2 ^ n := by
  -- Define the function $f : Quotient O.setoid → (Fin n → Bool)$ by $f ⟦a⟧ = O.transcript a$.
  obtain ⟨f, hf⟩ : ∃ f : Quotient O.setoid → (Fin n → Bool), ∀ a, f (Quotient.mk O.setoid a) = O.transcript a := by
    exact ⟨ fun x => Quotient.liftOn' x ( fun a => O.transcript a ) fun a b h => h, fun a => rfl ⟩;
  have := Fintype.card_le_of_injective f ( show Function.Injective f from fun a b h => by
                                            obtain ⟨ a, rfl ⟩ := Quotient.exists_rep a; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep b; simp_all +decide [ Quotient.eq ] ; ) ; simp_all +decide [ Fintype.card_pi ] ;

-- ============================================================================
-- Theorem 3: the bridge from static to adaptive systems
-- ============================================================================

/-- Build a (history-independent) adaptive system from a family of `n` predicates:
ask `p 0`, then `p 1`, … regardless of the answers. -/
def AdaptiveObs.ofPreds {α : Type u} : {n : ℕ} → (Fin n → α → Bool) → AdaptiveObs α n
  | 0, _ => .nil
  | _ + 1, p => .node (p 0) (fun _ => AdaptiveObs.ofPreds (fun i => p i.succ))

/-
!-- Induction on `n`: `Fin.cons (p 0 a) (fun i => p i.succ a) = fun i => p i a`
via `Fin.cons_self_tail`/`Fin.cases`. -- !--

The transcript of `ofPreds p` is exactly the static profile `fun i => p i a`.
-/
theorem transcript_ofPreds {α : Type u} {n : ℕ} (p : Fin n → α → Bool) (a : α) :
    (AdaptiveObs.ofPreds p).transcript a = fun i => p i a := by
  ext i;
  induction' n with n ih;
  · fin_cases i;
  · refine' Fin.cases _ _ i <;> simp_all +decide [ AdaptiveObs.ofPreds ];
    · rfl;
    · exact fun i => ih _ _

/-- Convert a static observation system to an adaptive one. -/
def AdaptiveObs.ofStatic {α : Type u} {n : ℕ} (O : ObservationGap.ObsSys α n) :
    AdaptiveObs α n :=
  AdaptiveObs.ofPreds O.pred

/-
!-- Unfold `ofStatic`/`twins`; both sides reduce to equality of static profiles
by `transcript_ofPreds`. -- !--

**Static–Adaptive Bridge.** A static observation system and the adaptive
system built from it have *identical* twin relations. Hence
`adaptive_observation_pigeonhole` specializes to
`ObservationGap.observation_pigeonhole`.
-/
theorem twins_ofStatic {α : Type u} {n : ℕ} (O : ObservationGap.ObsSys α n)
    (a b : α) : (AdaptiveObs.ofStatic O).twins a b ↔ O.twins a b := by
  unfold AdaptiveObs.ofStatic AdaptiveObs.twins ObservationGap.ObsSys.twins ObservationGap.ObsSys.profile;
  rw [ transcript_ofPreds, transcript_ofPreds ]

/-
============================================================================
Theorem 4: the sufficiency boundary for adaptive systems
============================================================================

!-- Take the history-independent system from the bit-extraction predicates
`fun i a => a.val.testBit i`; injectivity follows from
`ObservationGap.observation_can_suffice` through the bridge `twins_ofStatic`. -- !--

**Adaptive Sufficiency Boundary.** When `|α| = 2 ^ n` an adaptive system of
depth `n` *can* distinguish all elements, matching
`ObservationGap.observation_can_suffice`.
-/
theorem adaptive_can_suffice (n : ℕ) :
    ∃ O : AdaptiveObs (Fin (2 ^ n)) n,
      ∀ a b : Fin (2 ^ n), O.twins a b → a = b := by
  obtain ⟨ O, hO ⟩ := ObservationGap.observation_can_suffice n;
  use AdaptiveObs.ofStatic O;
  exact fun a b h => hO a b <| twins_ofStatic O a b |>.1 h

-- ============================================================================
-- Demonstrations
-- ============================================================================

/-- Any adaptive system of depth `2` on `Fin 5` has a twin pair, since
`2 ^ 2 = 4 < 5`. -/
example (O : AdaptiveObs (Fin 5) 2) : ∃ a b : Fin 5, a ≠ b ∧ O.twins a b :=
  adaptive_observation_pigeonhole O (by norm_num)

/-- The static and adaptive theories agree on twins, via the bridge. -/
example {α : Type u} {n : ℕ} (O : ObservationGap.ObsSys α n) (a b : α) :
    (AdaptiveObs.ofStatic O).twins a b ↔ O.twins a b :=
  twins_ofStatic O a b

end AdaptiveObservationGap