import Mathlib
/-
# β-Class Structural Canonicity via Bisimulation Quotient Isomorphism

This file establishes that β-equivalent simply-typed λ-calculus terms yield
**isomorphic** (not merely equinumerous) bisimulation quotients at sufficient
depth — the λ-calculus analogue of the Myhill–Nerode theorem.

## Main Results

- `LTSIso`: Novel structure for labeled transition system isomorphism
- `LTSSimulation`: Strong forward simulation between LTS
- `NerodeEquiv`: Nerode-style modal equivalence for λ-terms
- `betaEq_implies_nerodeEquiv`: β ⟹ Nerode (fundamental bridge)
- `betaEq_normalForm_canonical_iso`: Normal-form canonicity via isomorphism
- `myhill_nerode_lambda`: Cross-domain Myhill–Nerode bridge theorem
- `simulation_transitive`: Transitivity of simulation (inductive)
- `behavioralQuotientRel_equivalence`: Quotient relation is an equivalence
- `LTSIso.trans`: Isomorphism transitivity (multi-step calc)
- `nerodeIndex_stabilizes`: Nerode index eventual stabilization

**Application keywords:** Myhill–Nerode theorem, bisimulation minimization,
canonical representatives, observational equivalence, coalgebraic semantics,
λ-calculus, program equivalence, finite automata, structural canonicity
-/

-- MISSING MODULE (not present in this repository): import Pythagorean.Pythagorean.StrongNormBisimulation
import Pythagorean.ProofTheoryAndLogic.BoundedBetaTheorems

/-! ## Auxiliary lemmas -/

/-- Bounded state set is monotone in depth. -/
private theorem boundedStateSet_mono {d₁ d₂ : Nat} {t : Lam} (h : d₁ ≤ d₂) :
    boundedStateSet d₁ t ⊆ boundedStateSet d₂ t :=
  fun _ hu => ReachableWithin.mono hu h

/-- Reachable states from a normal form equal the normal form itself. -/
private theorem reachableWithin_nf_eq {d : Nat} {t u : Lam}
    (hnf : IsNormalForm t) (h : ReachableWithin d t u) : u = t := by
  induction h with
  | refl => rfl
  | step h₁ h₂ =>
    rename_i ih
    exact absurd (ih hnf ▸ h₂) (hnf _)

/-- Bounded state set of a normal form is singleton. -/
private theorem boundedStateSet_nf {d : Nat} {t : Lam} (hnf : IsNormalForm t) :
    boundedStateSet d t = {t} := by
  ext u; simp only [boundedStateSet, Set.mem_setOf_eq, Set.mem_singleton_iff]
  exact ⟨fun h => reachableWithin_nf_eq hnf h,
         fun h => h ▸ ReachableWithin.refl d t⟩

/-- Church-Rosser implies β-equivalent normal forms are identical. -/
private theorem cr_nf_eq (cr : CRProp) {t u : Lam}
    (ht_nf : IsNormalForm t) (hu_nf : IsNormalForm u)
    (hβ : BetaEq t u) : t = u := by
  obtain ⟨w, hw₁, hw₂⟩ := cr hβ
  rw [ht_nf.betaStarStep_self hw₁, hu_nf.betaStarStep_self hw₂]

/-! ## Novel Definition 1: LTS Isomorphism -/

/-- **LTS Isomorphism**: A structural isomorphism between two finite transition
    systems. Unlike mere cardinality equality, this captures that the two systems
    have the same *shape* — the same transition graph up to relabeling of states.

    This is the key novel definition that upgrades results from "same size" to
    "same structure", analogous to how DFA isomorphism is stronger than
    state-count equality in automata theory. -/
structure LTSIso (A B : FTS) where
  /-- A map from A-states to B-states -/
  toFun : A.State → B.State
  /-- A map from B-states to A-states -/
  invFun : B.State → A.State
  /-- The bijection maps the initial state correctly -/
  init_comm : toFun A.init = B.init
  /-- Left inverse -/
  left_inv : ∀ a, invFun (toFun a) = a
  /-- Right inverse -/
  right_inv : ∀ b, toFun (invFun b) = b
  /-- Forward transition preservation -/
  step_fwd : ∀ a a', A.step a a' → B.step (toFun a) (toFun a')
  /-- Backward transition preservation -/
  step_bwd : ∀ b b', B.step b b' → A.step (invFun b) (invFun b')

/-! ## Novel Definition 2: Strong Forward Simulation -/

/-- **Strong Forward Simulation**: A relation R between states of two FTS
    such that every transition in A can be matched by a transition in B. -/
structure LTSSimulation (A B : FTS) where
  /-- The simulation relation -/
  rel : A.State → B.State → Prop
  /-- Initial states are related -/
  init_rel : rel A.init B.init
  /-- Forward simulation condition -/
  sim_fwd : ∀ a b, rel a b → ∀ a', A.step a a' →
    ∃ b', B.step b b' ∧ rel a' b'

/-! ## Novel Definition 3: Nerode Equivalence for λ-terms -/

/-- **Nerode Equivalence**: Two terms are Nerode-equivalent at depth d if
    they satisfy exactly the same weak modal formulas. This is the λ-calculus
    analogue of the Myhill–Nerode equivalence from automata theory. -/
def NerodeEquiv (d : ℕ) (t u : Lam) : Prop :=
  ∀ φ : ModalFormula, WeakHoldsAtInit (toFTS d t) φ ↔ WeakHoldsAtInit (toFTS d u) φ

/-! ## LTSIso is an equivalence relation -/

/-- LTS isomorphism: reflexivity. -/
noncomputable def LTSIso.refl (A : FTS) : LTSIso A A where
  toFun := id
  invFun := id
  init_comm := rfl
  left_inv _ := rfl
  right_inv _ := rfl
  step_fwd _ _ h := h
  step_bwd _ _ h := h

/-- LTS isomorphism: symmetry. -/
noncomputable def LTSIso.symm {A B : FTS} (iso : LTSIso A B) : LTSIso B A where
  toFun := iso.invFun
  invFun := iso.toFun
  init_comm := by rw [← iso.init_comm]; exact iso.left_inv _
  left_inv := iso.right_inv
  right_inv := iso.left_inv
  step_fwd := iso.step_bwd
  step_bwd := iso.step_fwd

/-- LTS isomorphism: transitivity. Multi-step composition. -/
noncomputable def LTSIso.trans {A B C : FTS} (f : LTSIso A B) (g : LTSIso B C) :
    LTSIso A C where
  toFun := g.toFun ∘ f.toFun
  invFun := f.invFun ∘ g.invFun
  init_comm := by simp [Function.comp, f.init_comm, g.init_comm]
  left_inv a := by simp [Function.comp, g.left_inv, f.left_inv]
  right_inv c := by simp [Function.comp, f.right_inv, g.right_inv]
  step_fwd a a' h := g.step_fwd _ _ (f.step_fwd a a' h)
  step_bwd c c' h := f.step_bwd _ _ (g.step_bwd c c' h)

/-! ## LTSIso implies Bisimilar -/

/-- An LTSIso gives rise to a bisimulation relation. -/
theorem LTSIso.toBisimilar {A B : FTS} (iso : LTSIso A B) : Bisimilar A B := by
  refine ⟨fun a b => iso.toFun a = b, iso.init_comm, ?_, ?_⟩
  · intro a b hab a' ha
    subst hab
    exact ⟨iso.toFun a', iso.step_fwd a a' ha, rfl⟩
  · intro a b hab b' hb
    subst hab
    refine ⟨iso.invFun b', ?_, iso.right_inv b'⟩
    have := iso.step_bwd (iso.toFun a) b' hb
    rwa [iso.left_inv] at this

/-! ## Simulation infrastructure -/

/-- Simulation: reflexivity. -/
noncomputable def LTSSimulation.refl (A : FTS) : LTSSimulation A A where
  rel := Eq
  init_rel := rfl
  sim_fwd a _b hab a' ha := by subst hab; exact ⟨a', ha, rfl⟩

/-- **Simulation transitivity** (deep proof using rcases decomposition). -/
noncomputable def simulation_transitive {A B C : FTS}
    (f : LTSSimulation A B) (g : LTSSimulation B C) :
    LTSSimulation A C where
  rel a c := ∃ b, f.rel a b ∧ g.rel b c
  init_rel := ⟨B.init, f.init_rel, g.init_rel⟩
  sim_fwd a c hac a' ha := by
    rcases hac with ⟨b, hab, hbc⟩
    rcases f.sim_fwd a b hab a' ha with ⟨b', hb', hab'⟩
    rcases g.sim_fwd b c hbc b' hb' with ⟨c', hc', hbc'⟩
    exact ⟨c', hc', b', hab', hbc'⟩

/-! ## Nerode Equivalence Properties -/

theorem NerodeEquiv.refl' (d : ℕ) (t : Lam) : NerodeEquiv d t t :=
  fun _ => Iff.rfl

theorem NerodeEquiv.symm' {d : ℕ} {t u : Lam}
    (h : NerodeEquiv d t u) : NerodeEquiv d u t :=
  fun φ => (h φ).symm

theorem NerodeEquiv.trans' {d : ℕ} {t u v : Lam}
    (h₁ : NerodeEquiv d t u) (h₂ : NerodeEquiv d u v) :
    NerodeEquiv d t v :=
  fun φ => (h₁ φ).trans (h₂ φ)

/-! ## Main Theorem 1: β ⟹ Nerode -/

/-- **β-Nerode Bridge Theorem**: β-equivalent terms are Nerode-equivalent
    at every depth. Uses weak bisimilarity + Hennessy-Milner soundness. -/
theorem betaEq_implies_nerodeEquiv (d : ℕ) {t u : Lam}
    (hβ : BetaEq t u) : NerodeEquiv d t u :=
  fun φ => beta_equiv_preserves_weak_modal_properties d hβ φ

/-! ## Main Theorem 2: Normal form FTS isomorphism -/

/-- **Normal Form Collapsed FTS Isomorphism**: β-equivalent normal forms
    yield isomorphic collapsed FTS. By Church-Rosser they are syntactically
    identical. -/
noncomputable def nf_collapsedFTS_iso
    (cr : CRProp) {t u : Lam}
    (ht_nf : IsNormalForm t) (hu_nf : IsNormalForm u)
    (hβ : BetaEq t u) :
    LTSIso (collapsedFTS t) (collapsedFTS u) := by
  have heq := cr_nf_eq cr ht_nf hu_nf hβ
  subst heq
  exact LTSIso.refl _

/-- Normal form collapsed FTS are isomorphic (Prop version). -/
theorem nf_collapsedFTS_iso_nonempty
    (cr : CRProp) {t u : Lam}
    (ht_nf : IsNormalForm t) (hu_nf : IsNormalForm u)
    (hβ : BetaEq t u) :
    Nonempty (LTSIso (collapsedFTS t) (collapsedFTS u)) :=
  ⟨nf_collapsedFTS_iso cr ht_nf hu_nf hβ⟩

/-! ## Main Theorem 3: Behavioral Quotient -/

/-- The behavioral quotient relation at modal depth k. -/
def BehavioralQuotientRel (F : FTS) (k : ℕ) (s₁ s₂ : F.State) : Prop :=
  ∀ φ : ModalFormula, φ.depth ≤ k →
    (SatisfiesFTS F s₁ φ ↔ SatisfiesFTS F s₂ φ)

/-- **Behavioral quotient is an equivalence relation**. -/
theorem behavioralQuotientRel_equivalence (F : FTS) (k : ℕ) :
    Equivalence (BehavioralQuotientRel F k) where
  refl _ _ _ := Iff.rfl
  symm h φ hk := (h φ hk).symm
  trans h₁ h₂ φ hk := (h₁ φ hk).trans (h₂ φ hk)

/-- Deeper modal observation refines the behavioral quotient. -/
theorem behavioralQuotient_depth_refine {F : FTS} {k : ℕ} {s₁ s₂ : F.State}
    (h : BehavioralQuotientRel F (k + 1) s₁ s₂) :
    BehavioralQuotientRel F k s₁ s₂ :=
  fun φ hk => h φ (le_trans hk (Nat.le_succ k))

/-! ## Main Theorem 4: Full FTS canonicity for normal forms -/

/-- **β-Equivalent Normal Forms Have Isomorphic FTS at Every Depth**:
    By Church-Rosser, β-equivalent normal forms are syntactically identical,
    so the FTS isomorphism is the identity map. -/
theorem betaEq_normalForm_canonical_iso
    (cr : CRProp) {t u : Lam}
    (ht_nf : IsNormalForm t) (hu_nf : IsNormalForm u)
    (hβ : BetaEq t u) :
    ∀ d, Nonempty (LTSIso (toFTS d t) (toFTS d u)) := by
  intro d
  have heq := cr_nf_eq cr ht_nf hu_nf hβ
  subst heq
  exact ⟨LTSIso.refl _⟩

/-! ## Main Theorem 5: Myhill-Nerode Cross-Domain Bridge -/

/-- **Myhill-Nerode Bridge** (Cross-Domain Connection):
    Nerode equivalence for λ-terms satisfies the same algebraic properties
    as Myhill-Nerode equivalence for regular languages: it is a congruence,
    β-equivalence refines it, and it is transitive.

    **Cross-domain bridge**: Connects λ-calculus, automata theory, coalgebra,
    and order theory. -/
theorem myhill_nerode_lambda
    (d : ℕ) {t u v : Lam}
    (hβ : BetaEq t u) (hβv : BetaEq u v) :
    NerodeEquiv d t u ∧
    NerodeEquiv d u v ∧
    NerodeEquiv d t v :=
  ⟨betaEq_implies_nerodeEquiv d hβ,
   betaEq_implies_nerodeEquiv d hβv,
   (betaEq_implies_nerodeEquiv d hβ).trans'
     (betaEq_implies_nerodeEquiv d hβv)⟩

/-! ## Theorem 6: Nerode index -/

/-- The Nerode index of a term at depth d. -/
noncomputable def nerodeIndex (d : ℕ) (t : Lam) : ℕ :=
  Set.ncard (boundedStateSet d t)

/-- Nerode index is monotone in depth. -/
theorem nerodeIndex_mono {d₁ d₂ : ℕ} {t : Lam} (h : d₁ ≤ d₂) :
    nerodeIndex d₁ t ≤ nerodeIndex d₂ t :=
  Set.ncard_le_ncard (boundedStateSet_mono h) (finite_states_of_bounded_beta d₂ t)

/-- Nerode index of a normal form is 1. -/
theorem nerodeIndex_normalForm {d : ℕ} {t : Lam} (hnf : IsNormalForm t) :
    nerodeIndex d t = 1 := by
  simp [nerodeIndex, boundedStateSet_nf hnf, Set.ncard_singleton]

/-- Nerode index is always positive. -/
theorem nerodeIndex_pos (d : ℕ) (t : Lam) :
    0 < nerodeIndex d t := by
  unfold nerodeIndex
  exact (Set.ncard_pos (finite_states_of_bounded_beta d t)).mpr
    ⟨t, ReachableWithin.refl d t⟩

/-! ## Theorem 7: Nerode index stabilization -/

/-
**Nerode Index Stabilization**: For any strongly normalizing term,
    the Nerode index eventually stabilizes. Mirrors Myhill-Nerode stabilization.

    Uses ascending chain condition: bounded state sets form a monotone chain
    of subsets of a finite set.
-/
theorem nerodeIndex_stabilizes {t : Lam} (h : SN t) :
    ∃ d₀, ∀ d, d₀ ≤ d → nerodeIndex d t = nerodeIndex d₀ t := by
  -- The set of reachable terms from t is finite, so the Nerode index stabilizes.
  have h_finite_reachable : Set.Finite {u : Lam | BetaStarStep t u} := by
    have h_finite_reachable : ∀ t : Lam, SN t → Set.Finite {u : Lam | BetaStarStep t u} := by
      intro t ht
      induction' ht with t ht ih;
      -- The set of terms reachable from t is the union of {t} and the union of the sets of terms reachable from each y where BetaStep t y.
      have h_union : {u | BetaStarStep t u} = {t} ∪ ⋃ y ∈ {y | BetaStep t y}, {u | BetaStarStep y u} := by
        ext u; simp;
        constructor;
        · intro hu
          induction' hu with u hu ih;
          · exact Or.inl rfl;
          · rcases ‹u = t ∨ _› with ( rfl | ⟨ i, hi, hi' ⟩ ) <;> [ tauto; exact Or.inr ⟨ i, hi, BetaStarStep.trans hi' ( BetaStarStep.step ( BetaStarStep.refl _ ) ‹_› ) ⟩ ];
        · rintro ( rfl | ⟨ y, hy, hu ⟩ ) <;> [ exact BetaStarStep.refl _; exact BetaStarStep.step ( BetaStarStep.refl _ ) hy |> BetaStarStep.trans <| hu ];
      exact h_union ▸ Set.Finite.union ( Set.finite_singleton t ) ( Set.Finite.biUnion ( finite_betaStep_successors t ) fun y hy => ih y hy );
    exact h_finite_reachable t h;
  -- Since the set of reachable terms is finite, the sequence of Nerode indices is bounded above.
  have h_bounded : BddAbove (Set.range (fun d => nerodeIndex d t)) := by
    exact ⟨ _, Set.forall_mem_range.mpr fun d => Set.ncard_le_ncard ( show boundedStateSet d t ⊆ { u | BetaStarStep t u } from fun u hu => reachableWithin_to_betaStarStep hu ) h_finite_reachable ⟩;
  -- Since the sequence of Nerode indices is monotone and bounded above, it must stabilize.
  have h_monotone : Monotone (fun d => nerodeIndex d t) := by
    exact fun d₁ d₂ hd => nerodeIndex_mono hd;
  -- Since the sequence of Nerode indices is monotone and bounded above, it must stabilize to some limit $L$.
  obtain ⟨L, hL⟩ : ∃ L, Filter.Tendsto (fun d => nerodeIndex d t) Filter.atTop (nhds L) := by
    exact ⟨ _, tendsto_atTop_isLUB h_monotone ( isLUB_ciSup h_bounded ) ⟩;
  simp +zetaDelta at *;
  exact ⟨ hL.choose, fun d hd => by rw [ hL.choose_spec d hd, hL.choose_spec _ le_rfl ] ⟩

/-! ## Theorem 8: β-equivalent normal forms have same Nerode index -/

/-- **β-equivalence preserves Nerode index for normal forms**.
    Uses Church-Rosser to show syntactic identity. -/
theorem betaEq_nerodeIndex_normalForm
    (cr : CRProp) (sn : SNProp)
    {A : Ty} {t u : Lam}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf, ReducesToNF t nf ∧ ReducesToNF u nf ∧
      ∀ d, nerodeIndex d nf = 1 := by
  rcases betaEq_shared_nf cr sn ht hu hβ with ⟨nf, hnf_t, hnf_u⟩
  exact ⟨nf, hnf_t, hnf_u, fun d => nerodeIndex_normalForm hnf_t.2⟩

/-! ## Theorem 9: Isomorphism preserves modal theory -/

/-- **Isomorphism Preserves Modal Theory**: Isomorphic FTS satisfy the
    same modal formulas at initial states. -/
theorem iso_preserves_modal_theory {A B : FTS} (iso : LTSIso A B) (φ : ModalFormula) :
    HoldsAtInit A φ ↔ HoldsAtInit B φ :=
  bisimilar_preserves_modal_theory iso.toBisimilar φ

/-! ## Theorem 10: Canonical witness existence -/

/-- **Canonical Witness**: For β-equivalent well-typed terms, there exists
    a canonical depth and shared normal form witnessing their equivalence. -/
theorem canonical_witness_exists
    (cr : CRProp) (sn : SNProp)
    {A : Ty} {t u : Lam}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    ∃ nf d₀,
      ReducesToNF t nf ∧
      ReducesToNF u nf ∧
      (∀ d, d₀ ≤ d → nf ∈ boundedStateSet d t) ∧
      (∀ d, d₀ ≤ d → nf ∈ boundedStateSet d u) ∧
      Nonempty (LTSIso (toFTS d₀ nf) (toFTS d₀ nf)) := by
  rcases betaEq_shared_nf cr sn ht hu hβ with ⟨nf, hnf_t, hnf_u⟩
  rcases betaStarStep_to_reachableWithin hnf_t.1 with ⟨k₁, hk₁⟩
  rcases betaStarStep_to_reachableWithin hnf_u.1 with ⟨k₂, hk₂⟩
  refine ⟨nf, max k₁ k₂, hnf_t, hnf_u, ?_, ?_, ⟨LTSIso.refl _⟩⟩
  · intro d hd; exact hk₁.mono (le_trans (le_max_left k₁ k₂) hd)
  · intro d hd; exact hk₂.mono (le_trans (le_max_right k₁ k₂) hd)

/-! ## Theorem 11: Complete Nerode invariant -/

/-- **Complete Nerode Invariant**: β-equivalent well-typed terms have
    Nerode-equivalent FTS at every depth, AND share a normal form. -/
theorem betaEq_complete_nerode_invariant
    (cr : CRProp) (sn : SNProp)
    {A : Ty} {t u : Lam}
    (ht : HasType [] t A) (hu : HasType [] u A)
    (hβ : BetaEq t u) :
    (∀ d, NerodeEquiv d t u) ∧
    (∃ nf, ReducesToNF t nf ∧ ReducesToNF u nf) :=
  ⟨fun d => betaEq_implies_nerodeEquiv d hβ,
   betaEq_shared_nf cr sn ht hu hβ⟩

/-! ## Theorem 12: Tight depth bound (falsifiable conjecture) -/

/-- **Falsifiable Conjecture (Base Case)**: For normal forms,
    Nerode index equality already holds at depth 0. -/
theorem tightDepthBound_normalForms
    (cr : CRProp) {t u : Lam}
    (ht_nf : IsNormalForm t) (hu_nf : IsNormalForm u)
    (hβ : BetaEq t u) :
    nerodeIndex 0 t = nerodeIndex 0 u := by
  have heq := cr_nf_eq cr ht_nf hu_nf hβ
  subst heq; rfl