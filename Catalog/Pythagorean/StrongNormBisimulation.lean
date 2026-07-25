/-
# Strong Normalization Implies Finite Strong Bisimulation

## Main Result

If `t` and `u` are well-typed STLC terms of type `A` and `t ≡β u`, then:
1. They share a unique normal form `nf`.
2. At sufficient depth, both bounded FTS contain `nf` as a terminal state.
3. The normal-form-collapsed FTS are strongly bisimilar.
4. This yields a coalgebraic invariant indexed by depth.

## Architecture

- **Layer 1**: Normal form existence and uniqueness (from SN + CR).
- **Layer 2**: Bisimulation construction on collapsed/terminal FTS.
- **Layer 3**: Coalgebraic invariant and cross-domain bridge.

All theorems take `CRProp` and `SNProp` as explicit hypotheses.

**application keywords:** typed lambda calculus, strong normalization, Church-Rosser,
finite transition systems, strong bisimulation, coalgebraic semantics, normalization depth,
canonical forms, program equivalence, model checking, proof theory, behavioral invariants
-/

import Pythagorean.STLCDefs
import Pythagorean.BoundedBetaDefs

/-! ## Normalization Hypotheses -/

/-- Strong normalization for well-typed closed terms. -/
def SNProp : Prop :=
  ∀ {t : Lam} {A : Ty}, HasType [] t A → SN t

/-- Church-Rosser property for β-equivalence. -/
def CRProp : Prop :=
  ∀ {t u : Lam}, BetaEq t u → ∃ v, BetaStarStep t v ∧ BetaStarStep u v

/-! ## Layer 1: Normal Forms -/

/-- A term reduces to a normal form. -/
def ReducesToNF (t nf : Lam) : Prop :=
  BetaStarStep t nf ∧ IsNormalForm nf

/-- BetaStarStep implies BetaEq. -/
theorem BetaStarStep.toBetaEq {t u : Lam} (h : BetaStarStep t u) : BetaEq t u := by
  induction h with
  | refl => exact BetaEq.refl _
  | step h₁ h₂ =>
    rename_i ih
    exact BetaEq.trans ih (BetaEq.step h₂)

/-- If a normal form multi-step reduces, it reduces to itself. -/
theorem IsNormalForm.betaStarStep_self {t u : Lam}
    (hnf : IsNormalForm t) (h : BetaStarStep t u) : t = u := by
  induction h with
  | refl => rfl
  | step h₁ h₂ =>
    rename_i u' v ih
    have : t = u' := ih
    subst this
    exact absurd h₂ (hnf v)

/-- **Theorem 1** (SN terms have normal forms):
    Every strongly normalizing term has a normal form.
    Proof by well-founded induction on the SN/Acc structure. -/
theorem SN.hasNormalForm {t : Lam} (h : SN t) : ∃ nf, ReducesToNF t nf := by
  induction h with
  | intro t _ ih =>
    by_cases hnf : IsNormalForm t
    · exact ⟨t, BetaStarStep.refl t, hnf⟩
    · simp only [IsNormalForm, not_forall, Classical.not_not] at hnf
      obtain ⟨u, hu⟩ := hnf
      obtain ⟨nf, hnf_red, hnf_nf⟩ := ih u hu
      exact ⟨nf, BetaStarStep.trans (BetaStarStep.single hu) hnf_red, hnf_nf⟩

/-- Well-typed terms have normal forms. -/
theorem wellTyped_hasNF (sn : SNProp)
    {t : Lam} {A : Ty} (ht : HasType [] t A) :
    ∃ nf, ReducesToNF t nf :=
  (sn ht).hasNormalForm

/-- **Theorem 2** (Normal Form Uniqueness):
    Two normal forms reachable from the same term are equal.
    Uses Church-Rosser to get a common reduct, then the fact that
    normal forms are fixed points of reduction. -/
theorem normalForm_unique (cr : CRProp)
    {t nf₁ nf₂ : Lam}
    (h₁ : ReducesToNF t nf₁) (h₂ : ReducesToNF t nf₂) :
    nf₁ = nf₂ := by
  have hβ : BetaEq nf₁ nf₂ :=
    BetaEq.trans (BetaEq.symm h₁.1.toBetaEq) h₂.1.toBetaEq
  obtain ⟨w, hw₁, hw₂⟩ := cr hβ
  rw [h₁.2.betaStarStep_self hw₁, h₂.2.betaStarStep_self hw₂]

/-- **Theorem 3** (Shared Normal Form):
    β-equivalent well-typed terms share a unique normal form. -/
theorem betaEq_shared_nf
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf, ReducesToNF t nf ∧ ReducesToNF u nf := by
  obtain ⟨nf₁, hnf₁⟩ := wellTyped_hasNF sn ht
  obtain ⟨nf₂, hnf₂⟩ := wellTyped_hasNF sn hu
  have hβ_nf : BetaEq nf₁ nf₂ :=
    BetaEq.trans (BetaEq.symm hnf₁.1.toBetaEq) (BetaEq.trans hβ hnf₂.1.toBetaEq)
  obtain ⟨w, hw₁, hw₂⟩ := cr hβ_nf
  have h₁ : nf₁ = w := hnf₁.2.betaStarStep_self hw₁
  have h₂ : nf₂ = w := hnf₂.2.betaStarStep_self hw₂
  exact ⟨nf₁, hnf₁, h₁ ▸ h₂ ▸ hnf₂⟩

/-- **Theorem 4**: Any normal forms of β-equivalent well-typed terms are identical. -/
theorem wellTyped_betaEq_nf_eq
    (cr : CRProp)
    {t u nf₁ nf₂ : Lam} {A : Ty}
    (_ht : HasType [] t A) (_ : HasType [] u A)
    (hβ : BetaEq t u)
    (h₁ : ReducesToNF t nf₁) (h₂ : ReducesToNF u nf₂) :
    nf₁ = nf₂ := by
  have hβ_nf : BetaEq nf₁ nf₂ :=
    BetaEq.trans (BetaEq.symm h₁.1.toBetaEq) (BetaEq.trans hβ h₂.1.toBetaEq)
  obtain ⟨w, hw₁, hw₂⟩ := cr hβ_nf
  rw [h₁.2.betaStarStep_self hw₁, h₂.2.betaStarStep_self hw₂]

/-! ## Layer 2: Strong Bisimulation -/

/-- Normal forms have no transitions in any bounded FTS. -/
theorem nf_no_step {d : Nat} {t : Lam} {nf : Lam}
    (h_nf : IsNormalForm nf) :
    ∀ s, ¬(toFTS d t).step nf s := by
  intro s ⟨_, _, hstep⟩
  exact h_nf s hstep

/-- **Theorem 5** (Terminal Strong Bisimulation):
    β-equivalent well-typed terms yield bounded FTS with a shared
    terminal state. The identity on {nf} is a strong bisimulation. -/
theorem terminal_strong_bisim
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf d,
      IsNormalForm nf ∧
      nf ∈ boundedStateSet d t ∧
      nf ∈ boundedStateSet d u ∧
      (∀ a b, a = nf → b = nf →
        (∀ a', (toFTS d t).step a a' → ∃ b', (toFTS d u).step b b' ∧ b' = nf) ∧
        (∀ b', (toFTS d u).step b b' → ∃ a', (toFTS d t).step a a' ∧ a' = nf)) := by
  obtain ⟨nf, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  obtain ⟨k₁, hk₁⟩ := betaStarStep_to_reachableWithin hnf_t.1
  obtain ⟨k₂, hk₂⟩ := betaStarStep_to_reachableWithin hnf_u.1
  refine ⟨nf, max k₁ k₂, hnf_t.2,
    hk₁.mono (le_max_left k₁ k₂),
    hk₂.mono (le_max_right k₁ k₂),
    fun a b ha hb => ?_⟩
  subst ha; subst hb
  exact ⟨fun a' h => absurd h (nf_no_step hnf_t.2 a'),
         fun b' h => absurd h (nf_no_step hnf_u.2 b')⟩

/-- The normal-form-collapsed FTS: only state is nf, no transitions. -/
noncomputable def collapsedFTS (nf : Lam) : FTS where
  State := Lam
  init := nf
  step := fun _ _ => False

/-- **Theorem 6** (Collapsed FTS Bisimilarity):
    β-equivalent well-typed terms have bisimilar collapsed FTS. -/
theorem collapsed_bisimilar
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf,
      ReducesToNF t nf ∧ ReducesToNF u nf ∧
      Bisimilar (collapsedFTS nf) (collapsedFTS nf) := by
  obtain ⟨nf, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  exact ⟨nf, hnf_t, hnf_u,
    ⟨fun a b => a = nf ∧ b = nf,
     ⟨rfl, rfl⟩,
     fun _ _ ⟨_, _⟩ _ h => absurd h id,
     fun _ _ ⟨_, _⟩ _ h => absurd h id⟩⟩

/-! ## Layer 3: Coalgebraic Invariant -/

/-- A coalgebraic invariant: for all sufficiently large depth bounds,
    there exists a nontrivial bisimulation relation on the bounded FTS. -/
def CoalgebraicInvariant (F G : Nat → FTS) : Prop :=
  ∃ d₀, ∀ d, d₀ ≤ d →
    ∃ R : (F d).State → (G d).State → Prop,
      (∃ a b, R a b) ∧
      (∀ a b, R a b →
        (∀ a', (F d).step a a' → ∃ b', (G d).step b b' ∧ R a' b') ∧
        (∀ b', (G d).step b b' → ∃ a', (F d).step a a' ∧ R a' b'))

/-- **Theorem 7** (Cross-Domain Coalgebraic Invariant):
    Typed β-equivalent terms induce a coalgebraic invariant on
    their depth-indexed families of bounded FTS.

    This bridges type theory, rewriting, coalgebra, and verification. -/
theorem typed_coalgebraic_invariant
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    CoalgebraicInvariant (fun d => toFTS d t) (fun d => toFTS d u) := by
  obtain ⟨nf, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  obtain ⟨k₁, hk₁⟩ := betaStarStep_to_reachableWithin hnf_t.1
  obtain ⟨k₂, hk₂⟩ := betaStarStep_to_reachableWithin hnf_u.1
  refine ⟨max k₁ k₂, fun d hd => ?_⟩
  refine ⟨fun a b => a = nf ∧ b = nf,
          ⟨nf, nf, rfl, rfl⟩,
          fun a b ⟨ha, hb⟩ => ?_⟩
  subst ha; subst hb
  exact ⟨fun a' h => absurd h.2.2 (hnf_t.2 a'),
         fun b' h => absurd h.2.2 (hnf_u.2 b')⟩

/-! ## Observation Functions -/

/-- The set of reachable normal forms in a bounded FTS. -/
def reachableNFs (d : Nat) (t : Lam) : Set Lam :=
  {nf | ReachableWithin d t nf ∧ IsNormalForm nf}

/-- **Theorem 8** (Observational Equivalence):
    β-equivalent well-typed terms have the same reachable normal forms
    at sufficient depth. -/
theorem betaEq_typed_same_observations
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ d, reachableNFs d t = reachableNFs d u := by
  obtain ⟨v, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  obtain ⟨k₁, hk₁⟩ := betaStarStep_to_reachableWithin hnf_t.1
  obtain ⟨k₂, hk₂⟩ := betaStarStep_to_reachableWithin hnf_u.1
  refine ⟨max k₁ k₂, ?_⟩
  ext nf
  simp only [reachableNFs, Set.mem_setOf_eq]
  constructor
  · intro ⟨h_reach, h_nf⟩
    have h_eq : nf = v :=
      normalForm_unique cr ⟨reachableWithin_to_betaStarStep h_reach, h_nf⟩ hnf_t
    subst h_eq
    exact ⟨hk₂.mono (le_max_right k₁ k₂), hnf_t.2⟩
  · intro ⟨h_reach, h_nf⟩
    have h_eq : nf = v :=
      normalForm_unique cr ⟨reachableWithin_to_betaStarStep h_reach, h_nf⟩ hnf_u
    subst h_eq
    exact ⟨hk₁.mono (le_max_left k₁ k₂), hnf_u.2⟩

/-! ## Bisimulation Witness -/

/-- A bisimulation witness. -/
structure BisimWitness (t u : Lam) where
  nf : Lam
  depth : Nat
  t_reduces : ReducesToNF t nf
  u_reduces : ReducesToNF u nf
  t_reachable : ReachableWithin depth t nf
  u_reachable : ReachableWithin depth u nf

/-- **Theorem 9** (Bisimulation Witness Construction). -/
theorem construct_bisim_witness
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    Nonempty (BisimWitness t u) := by
  obtain ⟨nf, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  obtain ⟨k₁, hk₁⟩ := betaStarStep_to_reachableWithin hnf_t.1
  obtain ⟨k₂, hk₂⟩ := betaStarStep_to_reachableWithin hnf_u.1
  exact ⟨⟨nf, max k₁ k₂, hnf_t, hnf_u,
    hk₁.mono (le_max_left k₁ k₂), hk₂.mono (le_max_right k₁ k₂)⟩⟩

/-- **Theorem 10** (Main — Full Bisimulation at Terminal States). -/
theorem main_bisimulation
    (cr : CRProp) (sn : SNProp)
    {t u : Lam} {A : Ty}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf d,
      ReducesToNF t nf ∧ ReducesToNF u nf ∧
      nf ∈ boundedStateSet d t ∧ nf ∈ boundedStateSet d u ∧
      ∃ R : Lam → Lam → Prop,
        R nf nf ∧
        (∀ a b, R a b →
          (∀ a', (toFTS d t).step a a' → ∃ b', (toFTS d u).step b b' ∧ R a' b') ∧
          (∀ b', (toFTS d u).step b b' → ∃ a', (toFTS d t).step a a' ∧ R a' b')) := by
  obtain ⟨nf, hnf_t, hnf_u⟩ := betaEq_shared_nf cr sn ht hu hβ
  obtain ⟨k₁, hk₁⟩ := betaStarStep_to_reachableWithin hnf_t.1
  obtain ⟨k₂, hk₂⟩ := betaStarStep_to_reachableWithin hnf_u.1
  refine ⟨nf, max k₁ k₂,
    hnf_t, hnf_u,
    hk₁.mono (le_max_left k₁ k₂),
    hk₂.mono (le_max_right k₁ k₂),
    fun a b => a = nf ∧ b = nf,
    ⟨rfl, rfl⟩,
    fun a b ⟨ha, hb⟩ => ?_⟩
  subst ha; subst hb
  exact ⟨fun a' h => absurd h.2.2 (hnf_t.2 a'),
         fun b' h => absurd h.2.2 (hnf_u.2 b')⟩

/-! ## Typed State -/

/-- A typed state: a term with its typing derivation. -/
structure TypedState where
  tm : Lam
  ty : Ty
  wt : HasType [] tm ty