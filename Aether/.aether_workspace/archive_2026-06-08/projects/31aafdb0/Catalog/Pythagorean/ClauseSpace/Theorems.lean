/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Main theorems on clause-space certificates

This file contains the core theorems establishing that clause-space certificates
form a sound and complete certification framework for memory-bounded SAT refutations.

## Main results

* `spaceCertificate_sound` — a valid certificate implies unsatisfiability
* `certificate_monotone_in_space` — larger memory budgets subsume smaller ones
* `clause_toTernary_injective_of_disjoint` — disjoint clauses inject into ternary vectors
* `numDisjointClauses_le_three_pow` — at most `3^n` disjoint clauses on `n` variables
* `certificate_iff_reachable` — certificates correspond to graph reachability
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
  cases h1 <;> cases h2 <;> simp_all +decide [ Clause.resolve, Clause.satisfiedBy ];
  · grind;
  · grind;
  · grind;
  · grind

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
  rcases hstep with ( _ | _ | _ );
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
  rcases trace <;> simp_all +decide [ List.IsChain ];
  have h_ind : ∀ (mem : Finset (Clause Var)) (mem' : Finset (Clause Var)), SpaceStep F mem mem' → (∀ c ∈ mem, F.entails c) → (∀ c ∈ mem', F.entails c) := by
    grind +suggestions;
  have h_ind : ∀ (mem : Finset (Clause Var)) (trace : List (Finset (Clause Var))), List.IsChain (SpaceStep F) (mem :: trace) → (∀ c ∈ mem, F.entails c) → ∀ (mem' : Finset (Clause Var)), mem' ∈ mem :: trace → ∀ c ∈ mem', F.entails c := by
    intros mem trace hchain hstart mem' hmem'
    induction' trace with mem'' trace ih generalizing mem mem';
    · grind;
    · grind;
  exact fun a ha c hc => h_ind _ _ hchain ( by simp +decide ) _ ( List.mem_cons_of_mem _ ha ) _ hc

/-! ## Soundness of space certificates -/

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
  -- From the certificate, extract the trace. Use entailed_preserved_along_chain to show all clauses in every configuration are entailed by F.
  have h_entailed : ∀ c ∈ cert.trace.getLast cert.nonempty, F.entails c := by
    convert entailed_preserved_along_chain F cert.trace _ _ _;
    any_goals exact cert.trace.getLast cert.nonempty;
    · grind;
    · exact cert.valid_steps;
    · cases h : cert.trace <;> simp_all +decide;
      have := cert.starts_empty; aesop;
  exact fun ⟨ σ, hσ ⟩ => Clause.empty_not_satisfiedBy σ <| h_entailed _ ( cert.ends_with_empty_clause ) σ fun c' hc' => hσ c' hc'

/-! ## Monotonicity of clause space -/

/-
**Resource monotonicity**: If `F` is refutable in space `s` and `s ≤ t`,
    then `F` is refutable in space `t`. Larger memory budgets subsume smaller ones.
-/
theorem certificate_monotone_in_space
    (F : CNF Var) {s t : ℕ} (h : s ≤ t)
    (href : clauseSpaceRefutable F s) :
    clauseSpaceRefutable F t := by
  obtain ⟨ cert ⟩ := href;
  exact ⟨ ⟨ cert.trace, cert.nonempty, cert.starts_empty, cert.ends_with_empty_clause, fun mem hmem => le_trans ( cert.bounded mem hmem ) h, cert.valid_steps ⟩ ⟩

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
  -- By definition of `toTernary`, if `c1.toTernary = c2.toTernary`, then for every variable `v`, `c1.pos` and `c2.pos` have the same elements, and similarly for `c1.neg` and `c2.neg`.
  have h_pos_eq : c1.pos = c2.pos := by
    ext v; replace heq := congr_fun heq v; unfold Clause.toTernary at heq; aesop;
  have h_neg_eq : c1.neg = c2.neg := by
    ext v; replace heq := congr_fun heq v; simp_all +decide [ Clause.toTernary ] ;
    constructor <;> intro hv <;> contrapose! heq <;> simp_all +decide [ Finset.ext_iff ];
    · split_ifs <;> simp_all +decide [ Finset.disjoint_left ];
    · split_ifs <;> simp_all +decide [ Finset.disjoint_left ];
  cases c1 ; cases c2 ; aesop

/-
The number of disjoint clauses over `n` variables is at most `3^n`.
    Each variable independently contributes one of three states:
    absent, positive, or negative.
-/
theorem numDisjointClauses_le_three_pow [Fintype Var] :
    numDisjointClauses Var ≤ 3 ^ (Fintype.card Var) := by
  -- By definition of `numDisjointClauses`, we have `numDisjointClauses Var = (disjointClauses (Var := Var)).card`.
  unfold numDisjointClauses;
  convert Finset.card_le_card ( show Finset.image ( fun c : Clause Var => c.toTernary ) ( Finset.filter Clause.isDisjoint Finset.univ ) ⊆ Finset.univ from Finset.subset_univ _ ) using 1;
  · rw [ Finset.card_image_of_injOn ];
    · rfl;
    · intro c hc c' hc' h; exact clause_toTernary_injective_of_disjoint c c' ( Finset.mem_filter.mp hc |>.2 ) ( Finset.mem_filter.mp hc' |>.2 ) h;
  · simp +decide [ Fintype.card_pi ]

/-! ## Reachability equivalence -/

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
  constructor;
  · rintro ⟨ trace, nonempty, starts_empty, ends_with_empty_clause, bounded, valid_steps ⟩;
    have h_trace : ∀ (mem1 mem2 : Finset (Clause Var)), SpaceStep F mem1 mem2 → mem1.card ≤ s → mem2.card ≤ s → SpaceReachable F s mem1 mem2 := by
      exact fun mem1 mem2 h1 h2 h3 => SpaceReachable.step mem1 mem2 mem2 h1 h2 h3 ( SpaceReachable.refl mem2 h3 );
    have h_trace : ∀ (mem1 mem2 : Finset (Clause Var)), List.IsChain (SpaceStep F) (mem1 :: mem2 :: []) → mem1.card ≤ s → mem2.card ≤ s → SpaceReachable F s mem1 mem2 := by
      aesop;
    have h_trace : ∀ (mem : Finset (Clause Var)), ∀ (trace : List (Finset (Clause Var))), List.IsChain (SpaceStep F) (mem :: trace) → mem.card ≤ s → (∀ mem' ∈ trace, mem'.card ≤ s) → SpaceReachable F s mem (trace.getLastD mem) := by
      intros mem trace hchain hmem htrace
      induction' trace with mem' trace ih generalizing mem;
      · exact SpaceReachable.refl mem hmem;
      · simp +zetaDelta at *;
        convert SpaceReachable.step mem mem' ( trace.getLast?.getD mem' ) hchain.1 hmem htrace.1 ( ih mem' hchain.2 htrace.1 htrace.2 ) using 1;
        cases trace <;> simp +decide [ List.getLast? ];
    specialize h_trace ∅ ( trace.tail ) ; simp_all +decide [ List.isChain_cons_cons ];
    cases trace <;> simp_all +decide [ List.isChain_cons_cons ];
    · contradiction;
    · cases ‹List ( Finset ( Clause Var ) ) › <;> simp_all +decide [ List.getLast ];
      exact ⟨ _, ends_with_empty_clause, h_trace ⟩;
  · intro h
    obtain ⟨goal, hgoal, hreach⟩ := h
    have htrace : ∃ trace : List (Finset (Clause Var)), List.IsChain (SpaceStep F) trace ∧ trace.head? = some emptyConfig ∧ trace.getLast? = some goal ∧ ∀ mem ∈ trace, Finset.card mem ≤ s := by
      have htrace : ∀ {mem1 mem2 : Finset (Clause Var)}, SpaceReachable F s mem1 mem2 → ∃ trace : List (Finset (Clause Var)), List.IsChain (SpaceStep F) trace ∧ trace.head? = some mem1 ∧ trace.getLast? = some mem2 ∧ ∀ mem ∈ trace, Finset.card mem ≤ s := by
        intros mem1 mem2 hreach
        induction' hreach with mem1 mem2 hreach ih;
        · exact ⟨ [ mem1 ], by simp +decide, by simp +decide, by simp +decide, by simp +decide [ mem2 ] ⟩;
        · obtain ⟨ trace, htrace₁, htrace₂, htrace₃, htrace₄ ⟩ := ‹_›; use hreach :: trace; simp_all +decide [ List.isChain_cons_cons ] ;
          cases trace <;> aesop;
      exact htrace hreach;
    obtain ⟨trace, htrace_chain, htrace_head, htrace_last, htrace_bounded⟩ := htrace
    use trace;
    all_goals cases trace <;> simp_all +decide [ emptyConfig ];
    · contradiction;
    · cases htrace_head ; aesop;
    · cases htrace_head;
    · cases htrace_last ; aesop

/-! ## Configuration counting -/

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
  · exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_sum fun _ _ => by simp +decide [ numAllClauses ] )

/-! ## Finiteness of the search space -/

/-
The set of all configurations of size at most `s` over `Var` is finite,
    so exhaustive search terminates.
-/
theorem spaceConfigs_finite [Fintype Var] (s : ℕ) :
    Set.Finite {S : Finset (Clause Var) | S.card ≤ s} := by
  exact Set.toFinite _

end ClauseSpace