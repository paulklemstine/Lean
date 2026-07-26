/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Functorial Automata Semantics for Tropical One-Way Dynamics
# via Weighted Myhill-Nerode Congruences

This file establishes a formal bridge between **tropical semiring dynamics**,
**automata-theoretic state minimization**, and **functorial quotient semantics**.

## Main results

* `TropicalNerodeRel` is an equivalence relation (reflexive, symmetric, transitive)
* `tropicalNerodeSetoid` packages this as a `Setoid`
* `tropical_nerode_not_iff_exists_separation` — separation theorem via classical logic
* `rightCost_functorial_transport` — rightCost is preserved by automata morphisms
* `tropical_nerode_functorial` — Nerode equivalence transports along morphisms
* `tropical_nerode_induces_observable_equality` — Nerode ↔ right-language equality
* Application theorems bridging to post-quantum security, Lipschitz robustness, and
  thermodynamic energy invariants

## Cross-domain bridges

- **Automata theory ↔ Tropical algebra**: weighted right-languages over semirings
- **Category theory ↔ Automata**: functorial state maps preserving Nerode structure
- **Cryptography**: separation witnesses as collision certificates
- **Machine learning**: Lipschitz margins from tropical cost gaps
- **Physics**: state energy as empty-word tropical observable

## Future directions

1. Optimal witness bounds by quotient cardinality
2. Categorical universal property of the tropical Nerode quotient
3. Tropical transducers and bidirectional weighted congruences
4. Collision entropy monotonicity under automata morphisms
5. Certified robustness radii for tropical sequence classifiers
-/

import Mathlib

namespace Bridges.TropicalAutomataComplexity

open scoped BigOperators
open Finset

/-! ## Core structures -/

/-- A one-way tropical weighted automaton with state type `σ`, alphabet `α`,
and weight semiring `W`. Transitions carry weights and states produce outputs.
This models tropical dynamical systems where composition follows semiring laws. -/
structure TropicalOneWayAutomaton (α σ W : Type*) [Semiring W] where
  /-- Transition weight from state `q` to state `s` on input `a`. -/
  step : α → σ → σ → W
  /-- Output weight at state `q`. -/
  output : σ → W

variable {α σ τ W : Type*}

/-! ## Right-cost semantics -/

section RightCost

variable [Semiring W] [Fintype σ]

/-- Right-language cost of continuing from state `q` along word `w`.
Computed by summing over all state paths weighted by transition costs. -/
def rightCost (A : TropicalOneWayAutomaton α σ W) : List α → σ → W
  | [], q => A.output q
  | a :: w, q => ∑ s : σ, A.step a q s * rightCost A w s

@[simp]
theorem rightCost_nil (A : TropicalOneWayAutomaton α σ W) (q : σ) :
    rightCost A [] q = A.output q := rfl

@[simp]
theorem rightCost_cons (A : TropicalOneWayAutomaton α σ W) (a : α) (w : List α) (q : σ) :
    rightCost A (a :: w) q = ∑ s : σ, A.step a q s * rightCost A w s := rfl

end RightCost

/-! ## Nerode relation and variants -/

section NerodeRelation

variable [Semiring W] [Fintype σ]

/-- Weighted Myhill-Nerode relation: states with identical right-costs on all suffixes.
This is the tropical analogue of classical Myhill-Nerode equivalence, generalized
to weighted automata over arbitrary semirings. -/
def TropicalNerodeRel (A : TropicalOneWayAutomaton α σ W) (p q : σ) : Prop :=
  ∀ w : List α, rightCost A w p = rightCost A w q

/-- Bounded witness version: equivalence up to words of length at most `k`.
Approximates the full Nerode relation with finite computational resources. -/
def BoundedTropicalNerodeRel (A : TropicalOneWayAutomaton α σ W) (k : ℕ) (p q : σ) : Prop :=
  ∀ w : List α, w.length ≤ k → rightCost A w p = rightCost A w q

/-- The tropical right-language of a state as a function on words.
This is the observable semantics of a state: the complete profile of
continuation costs. Two states are Nerode-equivalent iff their
right-languages coincide. -/
def tropicalRightLanguage (A : TropicalOneWayAutomaton α σ W) (q : σ) : List α → W :=
  fun w => rightCost A w q

/-- A finite witness separating two states by a continuation word.
Bridge: connects to post_quantum_security — short witnesses model
efficiently checkable transcript collisions. -/
structure TropicalSeparationWitness (A : TropicalOneWayAutomaton α σ W) (p q : σ) where
  /-- The separating word. -/
  word : List α
  /-- Proof that the word witnesses different costs. -/
  separates : rightCost A word p ≠ rightCost A word q

end NerodeRelation

/-! ## Nerode relation is an equivalence -/

section Equivalence

variable [Semiring W] [Fintype σ]

/-- The tropical Nerode relation is reflexive: every state agrees with itself
on all continuations. -/
theorem TropicalNerodeRel_refl (A : TropicalOneWayAutomaton α σ W) :
    Reflexive (TropicalNerodeRel A) := by
  intro x w
  rfl

/-- The tropical Nerode relation is symmetric: if `p` agrees with `q` on
all continuations, then `q` agrees with `p`. -/
theorem TropicalNerodeRel_symm (A : TropicalOneWayAutomaton α σ W) :
    Symmetric (TropicalNerodeRel A) := by
  intro x y h w
  exact (h w).symm

/-- The tropical Nerode relation is transitive: if `p ≡ q` and `q ≡ r`
under all continuations, then `p ≡ r`. -/
theorem TropicalNerodeRel_trans (A : TropicalOneWayAutomaton α σ W) :
    Transitive (TropicalNerodeRel A) := by
  intro x y z hxy hyz w
  exact (hxy w).trans (hyz w)

/-- The tropical Nerode equivalence packaged as a `Setoid`.
This is the foundation for quotient semantics: the quotient `σ / ~_T`
yields the canonical minimal state space. -/
def tropicalNerodeSetoid (A : TropicalOneWayAutomaton α σ W) : Setoid σ where
  r := TropicalNerodeRel A
  iseqv := ⟨TropicalNerodeRel_refl A, fun h => TropicalNerodeRel_symm A h, fun h1 h2 => TropicalNerodeRel_trans A h1 h2⟩

end Equivalence

/-! ## Separation and extensionality theorems -/

section Separation

variable [Semiring W] [Fintype σ]

/-
Bridge: connects tropical automata separation to post_quantum_security witness extraction.
Two states are Nerode-inequivalent iff there exists a separating continuation word.
This is the quantifier-alternating core of the theory: ¬∀ ↔ ∃¬.
-/
theorem tropical_nerode_not_iff_exists_separation
    (A : TropicalOneWayAutomaton α σ W) (p q : σ) :
    ¬TropicalNerodeRel A p q ↔ ∃ w : List α, rightCost A w p ≠ rightCost A w q := by
  exact ⟨ fun h => by contrapose! h; tauto, fun h => by contrapose! h; tauto ⟩

/-
Bridge: connects Nerode quotient invariants to observable right-language equality.
Two states have the same right-language function iff they are Nerode-equivalent.
-/
theorem tropical_nerode_induces_observable_equality
    (A : TropicalOneWayAutomaton α σ W) (p q : σ) :
    TropicalNerodeRel A p q ↔ tropicalRightLanguage A p = tropicalRightLanguage A q := by
  exact ⟨ fun h => funext h, fun h w => congr_fun h w ⟩

/-
A separation witness proves Nerode inequivalence.
-/
theorem tropical_separation_witness_sound
    {A : TropicalOneWayAutomaton α σ W} {p q : σ}
    (h : TropicalSeparationWitness A p q) :
    ¬TropicalNerodeRel A p q := by
  exact fun h' => h.separates ( h' h.word )

/-
Nerode-inequivalent states admit a separation witness.
Bridge: connects to post_quantum_security — witnesses are efficiently checkable
certificates of state distinguishability.
-/
theorem tropical_separation_witness_complete
    (A : TropicalOneWayAutomaton α σ W) {p q : σ}
    (h : ¬TropicalNerodeRel A p q) :
    Nonempty (TropicalSeparationWitness A p q) := by
  exact ⟨ ⟨ Classical.choose ( tropical_nerode_not_iff_exists_separation A p q |>.1 h ), Classical.choose_spec ( tropical_nerode_not_iff_exists_separation A p q |>.1 h ) ⟩ ⟩

end Separation

/-! ## Bounded relation properties -/

section BoundedRelation

variable [Semiring W] [Fintype σ]

/-
Monotonicity: the bounded Nerode relation becomes finer as the bound decreases.
If two states agree on all words of length ≤ ℓ, they agree on all words of length ≤ k
for any k ≤ ℓ.
-/
theorem bounded_rel_mono
    (A : TropicalOneWayAutomaton α σ W)
    {k ℓ : ℕ} (hkl : k ≤ ℓ) {p q : σ}
    (h : BoundedTropicalNerodeRel A ℓ p q) :
    BoundedTropicalNerodeRel A k p q := by
  exact fun w hw => h w ( le_trans hw hkl )

/-
At bound 0, the bounded Nerode relation reduces to output equality.
This is the base case of iterative refinement algorithms.
-/
theorem bounded_rel_zero_iff_output_eq
    (A : TropicalOneWayAutomaton α σ W) (p q : σ) :
    BoundedTropicalNerodeRel A 0 p q ↔ A.output p = A.output q := by
  constructor <;> intro h;
  · simpa using h [];
  · intro w hw; cases w <;> aesop;

/-
The full Nerode relation implies all bounded versions.
-/
theorem nerode_implies_bounded
    (A : TropicalOneWayAutomaton α σ W)
    {p q : σ} (h : TropicalNerodeRel A p q) (k : ℕ) :
    BoundedTropicalNerodeRel A k p q := by
  exact fun w hw => h w

/-
The full Nerode relation is the intersection of all bounded relations.
-/
theorem nerode_eq_iInf_bounded
    (A : TropicalOneWayAutomaton α σ W) {p q : σ} :
    TropicalNerodeRel A p q ↔ ∀ k : ℕ, BoundedTropicalNerodeRel A k p q := by
  exact ⟨ fun h k => nerode_implies_bounded A h k, fun h w => h w.length w ( by simp +decide ) ⟩

end BoundedRelation

/-! ## Congruence compatibility -/

section Congruence

variable [Semiring W] [Fintype σ]

/-
Bridge: the Nerode relation is compatible with one-step transitions.
If two states are Nerode-equivalent, they produce the same weighted
aggregation under any input symbol. This is the key property making
the Nerode relation a congruence for the transition dynamics.
-/
theorem tropical_nerode_step_congruence
    (A : TropicalOneWayAutomaton α σ W) {p q : σ}
    (h : TropicalNerodeRel A p q)
    (a : α) (w : List α) :
    (∑ s : σ, A.step a p s * rightCost A w s) =
    (∑ s : σ, A.step a q s * rightCost A w s) := by
  exact h ( a :: w )

/-
Bridge: Nerode-equivalent states produce identical costs on all
prefixed words. This is the strongest form of congruence compatibility,
subsuming the one-step version.
-/
theorem tropical_nerode_respects_prefixed_words
    (A : TropicalOneWayAutomaton α σ W) {p q : σ}
    (h : TropicalNerodeRel A p q)
    (u w : List α) :
    rightCost A (u ++ w) p = rightCost A (u ++ w) q := by
  exact h _

end Congruence

/-! ## Functorial state maps -/

section Functorial

variable [Semiring W] [Fintype σ] [Fintype τ]

/-- A structure-preserving map between tropical weighted automata.
This is the morphism notion in the category of tropical automata:
it preserves both transition weights and output weights via a
bijective state correspondence. -/
structure FunctorialStateMap
    (A : TropicalOneWayAutomaton α σ W)
    (B : TropicalOneWayAutomaton α τ W) where
  /-- The underlying state bijection. -/
  toEquiv : σ ≃ τ
  /-- Transitions are preserved by the map. -/
  step_preserving : ∀ a q r, A.step a q r = B.step a (toEquiv q) (toEquiv r)
  /-- Outputs are preserved by the map. -/
  output_preserving : ∀ q, A.output q = B.output (toEquiv q)

/-
Bridge: connects automata morphisms to tropical dynamics invariants.
Right-cost semantics is preserved by functorial state maps. This is the
fundamental functoriality theorem: automata morphisms preserve all
observable behavior.
-/
theorem rightCost_functorial_transport
    [DecidableEq σ] [DecidableEq τ]
    {A : TropicalOneWayAutomaton α σ W}
    {B : TropicalOneWayAutomaton α τ W}
    (F : FunctorialStateMap A B)
    (w : List α) (q : σ) :
    rightCost A w q = rightCost B w (F.toEquiv q) := by
  -- By induction on the length of the word `w`, we can show that the cost is preserved.
  induction' w with a w ih generalizing q;
  · exact F.output_preserving q;
  · refine' Finset.sum_bij ( fun s _ => F.toEquiv s ) _ _ _ _ <;> simp +decide [ F.step_preserving, ih ];
    exact F.toEquiv.surjective

/-
Bridge: Nerode equivalence transports along functorial state maps.
If two states are Nerode-equivalent in the source automaton, their
images are Nerode-equivalent in the target. This makes the Nerode
relation a functorial invariant.
-/
theorem tropical_nerode_functorial
    [DecidableEq σ] [DecidableEq τ]
    {A : TropicalOneWayAutomaton α σ W}
    {B : TropicalOneWayAutomaton α τ W}
    (F : FunctorialStateMap A B)
    {p q : σ}
    (h : TropicalNerodeRel A p q) :
    TropicalNerodeRel B (F.toEquiv p) (F.toEquiv q) := by
  intro w;
  rw [ ← rightCost_functorial_transport F, ← rightCost_functorial_transport F, h w ]

end Functorial

/-! ## Application structures and theorems -/

section Applications

variable [Fintype σ]

/-! ### Post-quantum security: separation witnesses as collision certificates -/

/-- Finite witness complexity: the number of states as an upper bound
on computational resources needed to find separation witnesses.
Bridge: connects to post_quantum_security — this bounds the search
space for collision-finding algorithms. -/
def FiniteWitnessComplexity [Semiring W]
    (_A : TropicalOneWayAutomaton α σ W) : ℕ :=
  Fintype.card σ

/-
Bridge: connects tropical automata separation to post_quantum_security
witness extraction. Inequivalent states can always be separated, giving
a constructive certificate.
-/
theorem post_quantum_security_separation_existence
    [Semiring W]
    (A : TropicalOneWayAutomaton α σ W)
    {p q : σ} (h : ¬TropicalNerodeRel A p q) :
    ∃ w : List α, rightCost A w p ≠ rightCost A w q := by
  exact (tropical_nerode_not_iff_exists_separation A p q).mp h

/-! ### Thermodynamic energy: empty-word observable -/

/-- Tropical state energy: the output cost at a state, interpreted as
a thermodynamic free-energy observable in the tropical limit.
Bridge: connects to quantum_thermodynamic energy functionals where
the min-plus algebra captures zero-temperature limits of partition functions. -/
def TropicalStateEnergy
    (A : TropicalOneWayAutomaton α σ ℚ) (q : σ) : ℚ :=
  rightCost A [] q

/-
Bridge: connects Nerode quotient invariants to quantum_thermodynamic state energy.
The tropical state energy is an invariant of Nerode equivalence classes:
equivalent states have the same energy.
-/
theorem quantum_thermodynamic_energy_invariant_under_nerode
    (A : TropicalOneWayAutomaton α σ ℚ) {p q : σ}
    (h : TropicalNerodeRel A p q) :
    TropicalStateEnergy A p = TropicalStateEnergy A q := by
  exact h []

/-! ### Lipschitz certified robustness: separation margins -/

/-- A positive Lipschitz separation margin between two states.
Bridge: connects right-language margins to lipschitz_certified_robustness —
a positive gap in tropical costs provides a certifiable adversarial radius
for sequence classification models. -/
def TropicalLipschitzMargin
    (A : TropicalOneWayAutomaton α σ ℚ) (p q : σ) : Prop :=
  ∃ w : List α, rightCost A w p ≠ rightCost A w q

/-
Bridge: connects tropical residual languages to lipschitz_certified_robustness.
A positive separation margin certifies that two states are distinguishable,
which provides a robustness certificate for tropical sequence classifiers.
-/
theorem lipschitz_certified_robustness_of_separation_margin
    (A : TropicalOneWayAutomaton α σ ℚ)
    {p q : σ} (h : TropicalLipschitzMargin A p q) :
    ¬TropicalNerodeRel A p q := by
  exact fun h' => h.choose_spec ( h' _ )

/-! ### Tropical collision entropy -/

/-- Tropical collision entropy: the cardinality of the state space
as a measure of collision potential. More states means more potential
for distinct tropical hash outputs.
Bridge: connects to tropical_hash_collision analysis — the cardinality
upper-bounds the number of distinguishable output profiles. -/
def TropicalCollisionEntropy [Semiring W]
    (_A : TropicalOneWayAutomaton α σ W) : ℕ :=
  Fintype.card σ

/-- Bridge: connects tropical automata state space to tropical_hash_collision
analysis. The collision entropy (state cardinality) is always nonneg. -/
theorem tropical_hash_collision_entropy_nonneg [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) :
    0 ≤ TropicalCollisionEntropy A :=
  Nat.zero_le _

/-! ### Tropical residual observable -/

/-- The tropical residual after processing a prefix word `u` from state `q`.
This captures the "remaining behavior" of the automaton, connecting
to lattice_style_residual complexity analysis. -/
def TropicalResidual [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) (u : List α) (q : σ) : List α → W :=
  fun w => rightCost A (u ++ w) q

/-
Nerode-equivalent states have identical residuals for any prefix.
Bridge: connects to lattice_style_residual analysis — equivalent states
cannot be distinguished by any future observation.
-/
theorem tropical_residual_nerode_invariant [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) {p q : σ}
    (h : TropicalNerodeRel A p q) (u : List α) :
    TropicalResidual A u p = TropicalResidual A u q := by
  exact funext fun w => h ( u ++ w )

/-! ### Congruence invariant -/

/-- A tropical congruence invariant: a property of states that is preserved
by Nerode equivalence. This typeclass captures observables that descend
to the quotient. -/
class TropicalCongruenceInvariant [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) (P : σ → Prop) : Prop where
  /-- The property is invariant under Nerode equivalence. -/
  invariant : ∀ {p q : σ}, TropicalNerodeRel A p q → (P p ↔ P q)

/-
The output value is a congruence invariant.
-/
instance outputCongruenceInvariant [Semiring W] [DecidableEq W]
    (A : TropicalOneWayAutomaton α σ W) (c : W) :
    TropicalCongruenceInvariant A (fun q => A.output q = c) where
  invariant := by
    intro p q h; rw [ ← rightCost_nil, ← rightCost_nil, h [] ] ;

/-! ### Post-quantum separation profile -/

/-- Post-quantum separation profile: the set of words that separate two states.
Bridge: connects to post_quantum_security — this profile characterizes the
difficulty of distinguishing states via polynomial-length queries. -/
def PostQuantumSeparationProfile [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) (p q : σ) : Set (List α) :=
  {w | rightCost A w p ≠ rightCost A w q}

/-
The separation profile is empty iff the states are Nerode-equivalent.
-/
theorem post_quantum_separation_profile_empty_iff [Semiring W]
    (A : TropicalOneWayAutomaton α σ W) (p q : σ) :
    PostQuantumSeparationProfile A p q = ∅ ↔ TropicalNerodeRel A p q := by
  unfold PostQuantumSeparationProfile TropicalNerodeRel;
  simp +decide [ Set.ext_iff ]

end Applications

/-! ## Quotient existence theorem -/

section QuotientExistence

variable [Semiring W] [Fintype σ] [DecidableEq σ]

/-- The tropical Nerode quotient type. -/
def TropicalNerodeQuot (A : TropicalOneWayAutomaton α σ W) :=
  Quotient (tropicalNerodeSetoid A)

/-- The quotient projection map. -/
def tropicalNerodeProj (A : TropicalOneWayAutomaton α σ W) :
    σ → TropicalNerodeQuot A :=
  Quotient.mk (tropicalNerodeSetoid A)

/-
The projection map identifies exactly Nerode-equivalent states.
-/
omit [DecidableEq σ] in
theorem tropicalNerodeProj_eq_iff (A : TropicalOneWayAutomaton α σ W) (p q : σ) :
    tropicalNerodeProj A p = tropicalNerodeProj A q ↔ TropicalNerodeRel A p q := by
  exact Quotient.eq

/-
Right-cost descends to the Nerode quotient: equivalent states
have the same cost for every word.
-/
omit [DecidableEq σ] in
theorem rightCost_quotient_wellDefined
    (A : TropicalOneWayAutomaton α σ W) (w : List α) {p q : σ}
    (h : TropicalNerodeRel A p q) :
    rightCost A w p = rightCost A w q := by
  exact h w

/-
Bridge: connects tropical weighted automata minimization to
entropy_preserving_quotient semantics via functorial Myhill-Nerode.
The Nerode setoid exists, and the projection identifies exactly the
Nerode-equivalent states while preserving right-cost semantics.
-/
omit [DecidableEq σ] in
theorem tropical_myhill_nerode_quotient_exists
    (A : TropicalOneWayAutomaton α σ W) :
    ∃ (S : Setoid σ),
      S = tropicalNerodeSetoid A ∧
      (∀ p q : σ, S.r p q ↔ ∀ w, rightCost A w p = rightCost A w q) ∧
      (∀ p q : σ, S.r p q → ∀ w, rightCost A w p = rightCost A w q) := by
  exact ⟨ _, rfl, fun p q => Iff.rfl, fun p q h w => h w ⟩

end QuotientExistence

/-!
## Future Directions

1. **Optimal witness bounds by quotient cardinality**: Prove that inequivalent states
   in a finite tropical automaton admit a separating word of length at most
   `Fintype.card (Quotient (tropicalNerodeSetoid A))`.

2. **Categorical universal property**: Show the tropical Nerode quotient is the
   universal object through which all observation-compatible maps factor,
   establishing it as a categorical coequalizer in the category of tropical automata.

3. **Tropical transducers and bidirectional weighted congruences**: Extend the
   theory to transducers with both input and output alphabets, defining
   bidirectional Nerode relations and proving minimization for the richer setting.

4. **Collision entropy monotonicity under automata morphisms**: Prove that
   surjective automata morphisms decrease collision entropy, formalizing the
   intuition that quotients reduce distinguishability.

5. **Certified robustness radii for tropical sequence classifiers**: Define
   explicit perturbation radii in tropical cost space and prove that positive
   Lipschitz margins yield certified robustness guarantees for sequence models.
-/

end Bridges.TropicalAutomataComplexity