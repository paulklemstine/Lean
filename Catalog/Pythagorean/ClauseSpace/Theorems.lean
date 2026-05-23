/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Main theorems on clause-space certificates

This file contains the core theorems establishing that clause-space certificates
form a sound and complete certification framework for memory-bounded SAT refutations.

## Main results

* `spaceCertificate_sound` — a valid certificate implies unsatisfiability
* `spaceCertificate_complete` — bounded-space refutation yields a valid certificate
* `certificate_monotone_in_space` — larger memory budgets subsume smaller ones
* `clause_toTernary_injective_of_disjoint` — disjoint clauses inject into ternary vectors
* `numDisjointClauses_le_three_pow` — at most `3^n` disjoint clauses on `n` variables
* `certificate_iff_reachable` — certificates correspond to graph reachability
* `count_bounded_configs_le` — configuration counting bound
-/
import Mathlib
import Pythagorean.ClauseSpace.Defs

namespace ClauseSpace

variable {Var : Type} [DecidableEq Var]

/-! ## Resolution soundness -/

/-
Resolution preserves semantic entailment: if `σ` satisfies both `c1` and `c2`,
    and `v` appears only positively in `c1` and only negatively in `c2`,
    then `σ` satisfies the resolvent.
-/
theorem resolve_preserves_satisfaction
    (c1 c2 : Clause Var) (v : Var) (σ : Var → Bool)
    (hv_pos : v ∈ c1.pos) (hv_not_neg : v ∉ c1.neg)
    (hv_neg : v ∈ c2.neg) (hv_not_pos : v ∉ c2.pos)
    (h1 : c1.satisfiedBy σ) (h2 : c2.satisfiedBy σ) :
    (Clause.resolve c1 c2 v).satisfiedBy σ := by
  cases h1 <;> cases h2 <;> simp_all +decide [ Clause.satisfiedBy ];
  · simp_all +decide [ Clause.resolve ];
    grind;
  · unfold Clause.resolve;
    grind;
  · unfold Clause.resolve; aesop;
  · unfold Clause.resolve; aesop;

/-! ## Entailment invariant -/

/-
Every clause in a configuration reachable via one `SpaceStep` from a configuration
    whose clauses are all entailed by `F`, is itself entailed by `F`.
-/
theorem entailed_preserved_by_step
    (F : CNF Var) (mem1 mem2 : Finset (Clause Var))
    (hstep : SpaceStep F mem1 mem2)
    (h_entailed : ∀ c ∈ mem1, F.entails c) :
    ∀ c ∈ mem2, F.entails c := by
  cases hstep;
  · simp +zetaDelta at *;
    exact ⟨ fun σ hσ => hσ _ ‹_›, h_entailed ⟩;
  · simp +zetaDelta at *;
    exact ⟨ fun σ hσ => resolve_preserves_satisfaction _ _ _ _ ‹_› ‹_› ‹_› ‹_› ( h_entailed _ ‹_› σ hσ ) ( h_entailed _ ‹_› σ hσ ), h_entailed ⟩;
  · exact fun c hc => h_entailed c <| Finset.mem_of_mem_erase hc

/-
Entailment is preserved along any chain of space steps.
-/
theorem entailed_preserved_along_chain
    (F : CNF Var)
    (trace : List (Finset (Clause Var)))
    (hchain : List.IsChain (SpaceStep F) trace)
    (hstart : trace.head? = some ∅ ∨ trace = []) :
    ∀ mem ∈ trace, ∀ c ∈ mem, F.entails c := by
  induction' trace with mem trace ih;
  · tauto;
  · rcases hstart with ( hstart | hstart ) <;> simp_all +decide [ List.isChain_cons_cons ];
    have h_tail_entailed : ∀ mem1 mem2 : Finset (Clause Var), SpaceStep F mem1 mem2 → (∀ c ∈ mem1, F.entails c) → (∀ c ∈ mem2, F.entails c) := by
      grind +suggestions;
    have h_tail_entailed : ∀ (mem : Finset (Clause Var)) (trace : List (Finset (Clause Var))), List.IsChain (SpaceStep F) (mem :: trace) → (∀ c ∈ mem, F.entails c) → ∀ a ∈ trace, ∀ c ∈ a, F.entails c := by
      intros mem trace hchain hstart; induction' trace with mem' trace ih generalizing mem; aesop;
      grind +locals;
    grind

/-! ## Theorem 1: Soundness of space certificates -/

/-
**Soundness theorem**: If a valid space certificate exists for `F` with bound `s`,
    then `F` is unsatisfiable. This is the central correctness guarantee:
    a checked certificate really proves unsatisfiability.
-/
theorem spaceCertificate_sound
    [Fintype Var]
    (F : CNF Var) (s : ℕ)
    (cert : SpaceCertificate F s) :
    ¬ F.satisfiable := by
  rintro ⟨ σ, hσ ⟩;
  -- By the soundness theorem, all clauses in mem are entailed by F.
  have h_entailed : ∀ c ∈ cert.trace.getLast cert.nonempty, F.entails c := by
    convert entailed_preserved_along_chain F cert.trace cert.valid_steps _ _ _;
    · have := cert.starts_empty; cases h : cert.trace <;> aesop;
    · grind;
  exact Clause.empty_not_satisfiedBy σ ( h_entailed _ ( cert.ends_with_empty_clause ) σ hσ )

/-! ## Theorem 2: Completeness of bounded-space certificates -/

/-
**Completeness theorem**: Any bounded-space refutation can be normalized into
    a certificate accepted by the checker. If `F` is clause-space refutable in space `s`,
    then there exists a certificate whose checker accepts it.
-/
theorem spaceCertificate_complete
    [Fintype Var]
    (F : CNF Var) (s : ℕ) :
    clauseSpaceRefutable F s →
    ∃ C : SpaceCertificate F s, certificateChecks F s C = true := by
  intro h
  obtain ⟨C⟩ := h;
  simp +decide [ certificateChecks ];
  exact ⟨ C, ⟨ C.starts_empty, C.bounded ⟩, C.ends_with_empty_clause ⟩

/-! ## Resource monotonicity -/

/-
**Resource monotonicity**: If `F` is refutable in space `s` and `s ≤ t`,
    then `F` is refutable in space `t`. Larger memory budgets subsume smaller ones.
-/
theorem certificate_monotone_in_space
    (F : CNF Var) {s t : ℕ} (h : s ≤ t)
    (href : clauseSpaceRefutable F s) :
    clauseSpaceRefutable F t := by
  cases' href with C hC;
  refine' ⟨ ⟨ C.trace, C.nonempty, C.starts_empty, C.ends_with_empty_clause, fun mem hmem => le_trans ( C.bounded mem hmem ) h, C.valid_steps ⟩ ⟩

/-! ## Ternary encoding -/

/-
**Ternary injection**: The encoding of disjoint clauses into functions `Var → Fin 3`
    is injective. This identifies non-tautological clauses with ternary vectors,
    bridging proof complexity and coding theory.
-/
theorem clause_toTernary_injective_of_disjoint [Fintype Var]
    (c1 c2 : Clause Var)
    (hd1 : Disjoint c1.pos c1.neg) (hd2 : Disjoint c2.pos c2.neg)
    (heq : c1.toTernary = c2.toTernary) :
    c1 = c2 := by
  simp_all +decide [ funext_iff, Clause.toTernary ];
  refine' Clause.ext _ _ <;> ext x <;> specialize heq x <;> split_ifs at heq <;> simp_all +decide [ Finset.disjoint_left ]

/-
**Injection into ternary vectors**: There exists an injection from
    disjoint clauses to functions `Var → Fin 3`, connecting clause structure
    to coding theory and ternary state spaces.
-/
theorem clause_injection_into_ternary_vectors [Fintype Var] :
    ∃ f : {c : Clause Var // c.isDisjoint} → (Var → Fin 3),
    Function.Injective f := by
  refine' ⟨ fun x => x.val.toTernary, fun x y hxy => _ ⟩;
  exact Subtype.ext ( clause_toTernary_injective_of_disjoint _ _ x.2 y.2 hxy )

/-
The number of disjoint clauses over `n` variables is at most `3^n`.
    Each variable independently contributes one of three states:
    absent, positive, or negative.
-/
theorem numDisjointClauses_le_three_pow [Fintype Var] :
    numDisjointClauses Var ≤ 3 ^ (Fintype.card Var) := by
  -- The number of disjoint clauses is at most the number of functions from `Var` to `Fin 3`, which is `3 ^ Fintype.card Var`.
  have h_card : (disjointClauses (Var := Var)).card ≤ Finset.card (Finset.image (fun c : Clause Var => c.toTernary) (disjointClauses (Var := Var))) := by
    rw [ Finset.card_image_of_injOn ];
    intro c1 hc1 c2 hc2 h; exact clause_toTernary_injective_of_disjoint _ _ ( Finset.mem_filter.mp hc1 |>.2 ) ( Finset.mem_filter.mp hc2 |>.2 ) h;
  exact h_card.trans ( Finset.card_le_univ _ ) |> le_trans <| by simp +decide [ Fintype.card_fun ] ;

/-! ## Theorem 5: Reachability equivalence -/

/-
**Certificate-reachability equivalence**: A certificate exists if and only if there
    is a path in the space graph from the empty configuration to a goal configuration.
    This is the conceptual heart of the theory: clause-space certificates become
    finite-state reachability certificates.
-/
theorem certificate_iff_reachable
    [Fintype Var]
    (F : CNF Var) (s : ℕ) :
    clauseSpaceRefutable F s ↔
    ∃ goal, isGoalConfig goal ∧ SpaceReachable F s emptyConfig goal := by
  refine' ⟨ fun ⟨ C ⟩ => _, _ ⟩;
  · refine' ⟨ _, _, _ ⟩;
    exact C.trace.getLast C.nonempty;
    · exact C.ends_with_empty_clause;
    · have h_ind : ∀ {l : List (Finset (Clause Var))}, List.IsChain (SpaceStep F) l → ∀ {mem1 mem2 : Finset (Clause Var)}, l.head? = some mem1 → l.getLast? = some mem2 → ∀ {hb1 hb2 : ℕ}, l ≠ [] → (∀ mem ∈ l, Finset.card mem ≤ hb1) → hb1 ≤ hb2 → SpaceReachable F hb2 mem1 mem2 := by
        intros l hl mem1 mem2 h1 h2 hb1 hb2 hl_nonempty hl_card hl_le; induction' l with mem l ih generalizing mem1 mem2 <;> simp_all +decide [ List.isChain_cons_cons ] ;
        rcases l with ( _ | ⟨ mem', l ⟩ ) <;> simp_all +decide [ List.isChain_cons_cons ];
        · exact SpaceReachable.refl _ ( by linarith );
        · exact SpaceReachable.step _ _ _ hl.1 ( by linarith ) ( by linarith ) ( ih rfl h2 );
      convert h_ind C.valid_steps _ _ C.nonempty C.bounded le_rfl using 1;
      · cases h : C.trace <;> simp_all +decide [ emptyConfig ];
        · exact C.nonempty h;
        · have := C.starts_empty; aesop;
      · grind +splitImp;
  · rintro ⟨ goal, hgoal, hreach ⟩;
    -- By definition of `SpaceReachable`, there exists a path from `emptyConfig` to `goal` in the space graph.
    have h_path : ∃ trace : List (Finset (Clause Var)), List.IsChain (SpaceStep F) trace ∧ trace.head? = some emptyConfig ∧ trace.getLast? = some goal ∧ ∀ mem ∈ trace, Finset.card mem ≤ s := by
      have h_path : ∀ {mem1 mem2 : Finset (Clause Var)}, SpaceReachable F s mem1 mem2 → ∃ trace : List (Finset (Clause Var)), List.IsChain (SpaceStep F) trace ∧ trace.head? = some mem1 ∧ trace.getLast? = some mem2 ∧ ∀ mem ∈ trace, Finset.card mem ≤ s := by
        intro mem1 mem2 hreach
        induction' hreach with mem1 mem2 hstep h_ind;
        · exact ⟨ [ mem1 ], by simp +decide [ mem2 ] ⟩;
        · rename_i h12 hb1 hb2 h23 ih3_ih;
          obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄ ⟩ := ih3_ih; use hstep :: trace; simp_all +decide [ List.isChain_cons_cons ] ;
          cases trace <;> simp_all +decide [ List.isChain_cons_cons ];
      exact h_path hreach;
    obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄ ⟩ := h_path;
    refine' ⟨ ⟨ trace, _, _, _, _, _ ⟩ ⟩;
    all_goals norm_num [ isGoalConfig ] at *;
    any_goals tauto;
    grind;
    · cases trace <;> aesop;
    · grind

/-! ## Theorem 4: Configuration counting bound -/

/-
The number of bounded-memory configurations is at most the sum of
    binomial coefficients `∑ k ≤ s, C(numAllClauses, k)`.
-/
theorem count_bounded_configs_le [Fintype Var] (s : ℕ) :
    cardSpaceConfigs Var s ≤
    ∑ k ∈ Finset.range (s + 1), Nat.choose (numAllClauses Var) k := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.biUnion ( Finset.range ( s + 1 ) ) fun k => Finset.powersetCard k ( Finset.univ : Finset ( Clause Var ) );
  · intro S hS; aesop;
  · exact Finset.card_biUnion_le.trans ( Finset.sum_le_sum fun _ _ => by simp +decide [ numAllClauses ] )

/-! ## Finiteness of the search space -/

/-
The set of all configurations of size at most `s` over `Var` is finite,
    so exhaustive search terminates.
-/
theorem spaceConfigs_finite [Fintype Var] (s : ℕ) :
    Set.Finite {S : Finset (Clause Var) | S.card ≤ s} := by
  exact Set.toFinite _

end ClauseSpace