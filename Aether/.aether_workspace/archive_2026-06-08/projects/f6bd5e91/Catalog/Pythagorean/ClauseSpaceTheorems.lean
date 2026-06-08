/-
# Clause-Space Certificates — Main Theorems

This module proves the central theorems of clause-space certificate theory:

1. **Soundness** — a valid space certificate implies unsatisfiability
2. **Completeness** — bounded-space refutability yields a valid certificate
3. **Monotonicity** — more space never hurts: space-s refutability implies space-t for s ≤ t
4. **Ternary injection** — proper clauses inject into ternary vectors (Var → Fin 3)
5. **Counting bound** — explicit upper bound on the number of bounded configurations

Together these establish that bounded-space reasoning admits a finite, checkable
geometry: unsatisfiability within a memory budget is equivalent to the existence
of a finite certificate, and the search space is explicitly bounded.
-/

import Mathlib
import Pythagorean.ClauseSpaceDefs

namespace ClauseSpace

open ClauseSpace

/-! ## Resolution Soundness -/

/-
**Resolution is semantically sound**: if an assignment satisfies both parent
    clauses, it satisfies their resolvent. This is the key semantic invariant
    that underpins the soundness of the entire certificate framework.
-/
theorem resolution_sound {Var : Type} [DecidableEq Var]
    (c1 c2 : Clause Var) (v : Var) (a : Assignment Var)
    (hv1 : (v, true) ∈ c1) (hv2 : (v, false) ∈ c2)
    (hs1 : clauseSat a c1) (hs2 : clauseSat a c2) :
    clauseSat a (resolve c1 c2 v) := by
  rcases hs1 with ⟨ l1, hl1c, hl1 ⟩ ; rcases hs2 with ⟨ l2, hl2c, hl2 ⟩ ; simp_all +decide [ ClauseSpace.resolve ] ;
  by_cases h : l1 = ( v, true ) <;> by_cases h' : l2 = ( v, false ) <;> simp_all +decide [ litSat ];
  · exact ⟨ l2, Finset.mem_union_right _ ( Finset.mem_erase_of_ne_of_mem ( by aesop ) hl2c ), hl2 ⟩;
  · exact ⟨ l1, Finset.mem_union_left _ ( Finset.mem_erase_of_ne_of_mem ( by aesop ) hl1c ), hl1 ⟩;
  · exact ⟨ l1, Finset.mem_union_left _ ( Finset.mem_erase_of_ne_of_mem h hl1c ), hl1 ⟩

/-! ## Empty Clause is Unsatisfiable -/

/-
The empty clause has no literals, so no assignment can satisfy it.
-/
theorem emptyClause_unsat {Var : Type} [DecidableEq Var]
    (a : Assignment Var) : ¬ clauseSat a (emptyClause Var) := by
  -- By definition of clauseSat, the empty clause is satisfied if there exists a literal in it that is satisfied by the assignment.
  simp [clauseSat, emptyClause]

/-! ## Semantic Invariant: Steps Preserve Entailment -/

/-
Every clause in the empty configuration is vacuously entailed.
-/
theorem configEntailed_empty {Var : Type} [DecidableEq Var] (F : CNF Var) :
    ∀ c ∈ (emptySpaceConfig Var), entails F c := by
  exact fun c hc => False.elim <| Finset.notMem_empty c hc

/-
Axiom clauses from the formula are entailed by it.
-/
theorem axiom_entailed {Var : Type} [DecidableEq Var]
    (F : CNF Var) (c : Clause Var) (hc : c ∈ F.clauses) :
    entails F c := by
  exact fun a ha => ha c hc

/-
Resolution preserves entailment: if F entails c1 and c2, it entails their resolvent.
-/
theorem resolve_entailed {Var : Type} [DecidableEq Var]
    (F : CNF Var) (c1 c2 : Clause Var) (v : Var)
    (hv1 : (v, true) ∈ c1) (hv2 : (v, false) ∈ c2)
    (he1 : entails F c1) (he2 : entails F c2) :
    entails F (resolve c1 c2 v) := by
  exact fun a ha => resolution_sound c1 c2 v a hv1 hv2 ( he1 a ha ) ( he2 a ha )

/-
**A space step preserves the entailment invariant**: if every clause in `mem`
    is entailed by F, then every clause in `mem'` (obtained by a valid step) is
    also entailed by F.
-/
theorem spaceStep_preserves_entailment {Var : Type} [DecidableEq Var]
    (F : CNF Var) (mem mem' : SpaceConfig Var)
    (hstep : SpaceStep F mem mem')
    (hinv : ∀ c ∈ mem, entails F c) :
    ∀ c ∈ mem', entails F c := by
  rcases hstep with ( hstep | hstep | hstep );
  · simp +zetaDelta at *;
    exact ⟨ axiom_entailed F hstep ‹_›, hinv ⟩;
  · simp +zetaDelta at *;
    exact ⟨ resolve_entailed F _ _ _ ‹_› ‹_› ( hinv _ ‹_› ) ( hinv _ ‹_› ), hinv ⟩;
  · exact fun c hc => hinv c <| Finset.mem_of_mem_erase hc

/-
**Reachable configurations satisfy the entailment invariant**:
    every clause in every reachable configuration is entailed by F.
-/
theorem reachable_entailed {Var : Type} [DecidableEq Var]
    (F : CNF Var) (s : ℕ) (mem : SpaceConfig Var)
    (hr : SpaceReachable F s mem) :
    ∀ c ∈ mem, entails F c := by
  induction' hr;
  · exact?;
  · exact?

/-! ## Theorem 1: Soundness of Space Certificates -/

/-
**Soundness**: a valid space certificate from the empty configuration to one
    containing the empty clause proves that F is unsatisfiable.

    The proof works by showing that every clause appearing anywhere in the
    certificate trace is semantically entailed by F (by induction on the trace),
    then observing that the empty clause at the end is entailed but can never
    be satisfied, yielding a contradiction with any purported satisfying assignment.
-/
theorem spaceCertificate_sound
    {Var : Type} [DecidableEq Var]
    (F : CNF Var) (s : ℕ)
    (C : SpaceCertificate F s) :
    ¬ satisfiable F := by
  -- By induction on the trace, we show that every clause in every configuration in the trace is entailed by F.
  have h_entailed : ∀ c ∈ (C.head :: C.tail).getLast (by simp), entails F c := by
    -- We proceed by induction on the length of the trace.
    have h_ind : ∀ n ≤ C.tail.length, ∀ c ∈ (C.head :: C.tail)[n]!, entails F c := by
      intro n hn;
      induction' n with n ih;
      · convert configEntailed_empty F;
        exact C.starts_empty;
      · convert spaceStep_preserves_entailment F _ _ _ _ using 1;
        exact ( C.head :: C.tail)[n]!;
        · have := C.valid_steps;
          rw [ List.isChain_iff_get ] at this;
          convert this ⟨ n, by simpa using by omega ⟩;
          · simp +decide [ Fin.cast ];
            grind;
          · grind;
        · exact ih ( Nat.le_of_succ_le hn );
    convert h_ind C.tail.length le_rfl using 1;
    simp +decide [ List.getLast_eq_getElem ];
  exact fun ⟨ a, ha ⟩ => emptyClause_unsat a <| h_entailed _ C.ends_goal a ha

/-! ## Theorem 2: Completeness of Space Certificates -/

/-
**Completeness**: if F is clause-space refutable in space s, then there exists
    a valid space certificate. This converts the abstract Prop-level notion of
    bounded-space refutation into a concrete certified trace.
-/
theorem spaceCertificate_complete
    {Var : Type} [DecidableEq Var]
    (F : CNF Var) (s : ℕ)
    (href : clauseSpaceRefutable F s) :
    ∃ C : SpaceCertificate F s, True := by
  obtain ⟨mem, hreach, hempty⟩ := href;
  -- By induction on the SpaceReachable proof, we can construct the trace.
  have h_trace : ∃ (trace : List (SpaceConfig Var)), trace ≠ [] ∧ trace.head? = some (emptySpaceConfig Var) ∧ trace.getLast? = some mem ∧ (trace.IsChain (SpaceStep F)) ∧ (∀ cfg ∈ trace, cfg.card ≤ s) := by
    induction' hreach with mem' mem'' hreach' hstep' hcard';
    · exact False.elim <| Finset.notMem_empty _ hempty;
    · have h_trace : ∃ (trace : List (SpaceConfig Var)), trace ≠ [] ∧ trace.head? = some (emptySpaceConfig Var) ∧ trace.getLast? = some mem' ∧ (trace.IsChain (SpaceStep F)) ∧ (∀ cfg ∈ trace, cfg.card ≤ s) := by
        have h_trace : ∀ (mem : SpaceConfig Var), SpaceReachable F s mem → ∃ (trace : List (SpaceConfig Var)), trace ≠ [] ∧ trace.head? = some (emptySpaceConfig Var) ∧ trace.getLast? = some mem ∧ (trace.IsChain (SpaceStep F)) ∧ (∀ cfg ∈ trace, cfg.card ≤ s) := by
          intro mem hreach
          induction' hreach with mem' mem'' hreach' hstep' hcard';
          · use [emptySpaceConfig Var]; simp;
            exact Nat.zero_le _;
          · obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄, htrace₅ ⟩ := ‹_›; use trace ++ [ mem'' ] ; simp_all +decide [ List.isChain_append ] ;
            rintro cfg ( hcfg | rfl ) <;> [ exact htrace₅ _ hcfg; exact hcard' ];
        exact h_trace mem' hreach';
      obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄, htrace₅ ⟩ := h_trace; use trace ++ [ mem'' ] ; simp_all +decide [ List.isChain_append ] ;
      rintro cfg ( hcfg | rfl ) <;> [ exact htrace₅ _ hcfg; exact hcard' ];
  obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄, htrace₅ ⟩ := h_trace; use ⟨ emptySpaceConfig Var, trace.tail, by
    rfl, by
    grind +splitIndPred, by
    cases trace <;> aesop, by
    cases trace <;> aesop ⟩ ;

/-! ## Theorem 3: Monotonicity in Space -/

/-
A space step is independent of the space bound parameter.
-/
theorem spaceReachable_mono {Var : Type} [DecidableEq Var]
    (F : CNF Var) {s t : ℕ} (hst : s ≤ t) (mem : SpaceConfig Var)
    (hr : SpaceReachable F s mem) : SpaceReachable F t mem := by
  induction hr;
  · constructor;
  · exact SpaceReachable.step _ _ ‹_› ‹_› ( by linarith )

/-
**Resource monotonicity**: if F is clause-space refutable in space s, it is
    also refutable in any larger space t ≥ s. This is the proof-complexity
    analogue of "more memory never hurts."
-/
theorem certificate_monotone_in_space
    {Var : Type} [DecidableEq Var]
    (F : CNF Var) {s t : ℕ} (h : s ≤ t) :
    clauseSpaceRefutable F s → clauseSpaceRefutable F t := by
  rintro ⟨ mem, hr, hmem ⟩;
  exact ⟨ mem, spaceReachable_mono F h mem hr, hmem ⟩

/-! ## Theorem 4: Ternary Injection -/

/-
**Ternary injection**: the map `clauseToTernary` is injective on proper clauses
    (those where no variable appears both positively and negatively). This identifies
    proper clauses with elements of the ternary state space `Var → Fin 3`, bridging
    clause-space theory to coding theory and statistical mechanics.
-/
theorem clauseToTernary_injective {Var : Type} [DecidableEq Var]
    (c1 c2 : Clause Var)
    (hp1 : isProperClause c1) (hp2 : isProperClause c2)
    (heq : clauseToTernary c1 = clauseToTernary c2) :
    c1 = c2 := by
  refine' Finset.Subset.antisymm _ _ <;> intro x hx <;> ( ( have := congr_fun heq x.1 ; simp_all +decide [ clauseToTernary ] ) );
  · cases x ; simp_all +decide [ clauseToTernary ];
    cases ‹Bool› <;> split_ifs at this <;> simp_all +decide [ isProperClause ];
  · cases x ; simp_all +decide [ isProperClause ];
    cases ‹Bool› <;> split_ifs at this <;> simp_all +decide [ clauseToTernary ]

/-- Variant: there exists an injective function from proper clauses to ternary vectors. -/
theorem clause_injection_into_ternary_vectors
    {Var : Type} [Fintype Var] [DecidableEq Var] :
    ∃ f : {c : Clause Var // isProperClause c} → (Var → Fin 3),
      Function.Injective f := by
  exact ⟨fun ⟨c, _⟩ => clauseToTernary c,
    fun ⟨c1, hp1⟩ ⟨c2, hp2⟩ h => by
      simp only [Subtype.mk.injEq]
      exact clauseToTernary_injective c1 c2 hp1 hp2 h⟩

/-! ## Theorem 5: Counting Bounds -/

/-
**Number of proper clauses bounded by 3^n**: since proper clauses inject into
    `Var → Fin 3`, their count is at most `3^(Fintype.card Var)`.
-/
theorem numProperClauses_le_three_pow
    {Var : Type} [Fintype Var] [DecidableEq Var] :
    (properClauses Var).card ≤ 3 ^ (Fintype.card Var) := by
  convert Set.ncard_le_ncard ( show ( Set.range fun x : { c : Clause Var // isProperClause c } => clauseToTernary x.val ) ⊆ Set.univ from Set.subset_univ _ ) using 1;
  · rw [ Set.ncard_eq_toFinset_card' ];
    refine' Finset.card_bij ( fun x hx => clauseToTernary x ) _ _ _ <;> simp +decide;
    · exact fun c hc => ⟨ c, Finset.mem_filter.mp hc |>.2, rfl ⟩;
    · exact fun a₁ ha₁ a₂ ha₂ h => clauseToTernary_injective a₁ a₂ ( Finset.mem_filter.mp ha₁ |>.2 ) ( Finset.mem_filter.mp ha₂ |>.2 ) h;
    · exact fun c hc => ⟨ c, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hc ⟩, rfl ⟩;
  · rw [ Set.ncard_univ ] ; aesop

/-
**Bounded configuration counting**: the number of space configurations of size
    at most s is bounded by the sum of binomial coefficients.
-/
theorem count_bounded_configs_le
    {Var : Type} [Fintype Var] [DecidableEq Var]
    (s : ℕ) :
    cardSpaceConfigs Var s ≤
      ∑ k ∈ Finset.range (s + 1), Nat.choose (numClauses Var) k := by
  -- By definition of boundedConfigs, we have that boundedConfigs Var s is the union of the powersetCard k for k from 0 to s.
  have h_union : boundedConfigs Var s = Finset.biUnion (Finset.range (s + 1)) (fun k => Finset.powersetCard k (Finset.univ : Finset (Clause Var))) := by
    ext; simp [boundedConfigs];
  convert Finset.card_biUnion_le using 2;
  convert congr_arg Finset.card h_union using 1;
  unfold numClauses; aesop;

end ClauseSpace