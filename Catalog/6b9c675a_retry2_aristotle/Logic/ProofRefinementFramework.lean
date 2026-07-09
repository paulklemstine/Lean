import Mathlib

/-!
# A Proof-Refinement Framework

This file formalizes the proof-refinement framework described in the research
brief: proofs can be *simplified* over time, and we study when such a
simplification process is well behaved.

## The model

A `RefinementSystem` bundles together:

* a type `Candidate` of concrete proof candidates for a fixed target,
* a soundness predicate `valid : Candidate → Prop` (`valid c` records that `c`
  really certifies the target proposition), and
* a decidable complexity measure `complexity : Candidate → ℕ` (e.g. the size of
  the underlying Lean term, or a custom weight).

A candidate `p'` **refines** `p` when both are valid and `p'` is strictly
simpler:

```
refines p' p  :=  valid p' ∧ valid p ∧ complexity p' < complexity p
```

## Main results

* `RefinementSystem.refines_wellFounded` — refinement is well founded (it is a
  subrelation of the pullback of `<` on `ℕ` along `complexity`), so no infinite
  simplification is possible.
* `RefinementSystem.process_halts` — any deterministic, complexity-non-increasing
  refinement process eventually stabilizes in complexity.
* `RefinementSystem.exists_minimal` — as soon as a valid candidate exists, there
  is a globally complexity-minimal valid candidate.

## Counterexamples

The final two sections show that these good properties do *not* guarantee a
unique simplest proof, nor that a local process reaches the global optimum:

* `two_distinct_global_minima` — two distinct candidates that are both valid and
  both globally complexity-minimal.
* `clocal_is_local_min` together with `clocal_not_global_min` — a deterministic
  process that gets stuck at a *local* minimum even though a strictly simpler
  valid candidate exists (unreachable by the process's allowed steps).
-/

namespace ProofRefinement

/-- A *proof-refinement system* for a fixed target proposition: a type of proof
candidates, a validity (soundness) predicate, and a natural-number complexity
measure. -/
structure RefinementSystem where
  /-- The type of concrete proof candidates for the target. -/
  Candidate : Type
  /-- Soundness predicate: `valid c` means `c` genuinely certifies the target. -/
  valid : Candidate → Prop
  /-- The complexity measure (e.g. term size or a custom weight). -/
  complexity : Candidate → ℕ

namespace RefinementSystem

variable (S : RefinementSystem)

/-- `refines p' p`: the candidate `p'` is a refinement of `p`, i.e. both are
valid and `p'` is strictly simpler. -/
def refines (p' p : S.Candidate) : Prop :=
  S.valid p' ∧ S.valid p ∧ S.complexity p' < S.complexity p

/-- **Refinement is well founded.**  It is a subrelation of the pullback of the
well-founded order `<` on `ℕ` along `complexity`, hence there is no infinite
descending chain of refinements. -/
theorem refines_wellFounded : WellFounded S.refines :=
  Subrelation.wf (fun h => h.2.2) (InvImage.wf S.complexity Nat.lt_wfRel.wf)

/-- **A deterministic refinement process halts.**  If `step` never increases
complexity, then iterating it from any candidate `c0` eventually stabilizes in
complexity: there is an index `N` beyond which the complexity is constant. -/
theorem process_halts (step : S.Candidate → S.Candidate)
    (hstep : ∀ c, S.complexity (step c) ≤ S.complexity c) (c0 : S.Candidate) :
    ∃ N, ∀ n, N ≤ n →
      S.complexity (step^[n] c0) = S.complexity (step^[N] c0) := by
        -- Since the complexitities are bounded below by zero, they must eventually stabilize.
        have h_bounded : Antitone (fun n => S.complexity (step^[n] c0)) := by
          exact antitone_nat_of_succ_le fun n => by simpa only [ Function.iterate_succ_apply' ] using hstep _;
        -- Since the complexitities are bounded below by zero, they must eventually stabilize to a minimum value.
        obtain ⟨m, hm⟩ : ∃ m, m ∈ Set.range (fun n => S.complexity (step^[n] c0)) ∧ ∀ y ∈ Set.range (fun n => S.complexity (step^[n] c0)), m ≤ y := by
          apply_rules [ Set.exists_min_image ];
          · exact Set.finite_iff_bddAbove.mpr ⟨ S.complexity c0, by rintro x ⟨ n, rfl ⟩ ; exact h_bounded n.zero_le ⟩;
          · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
        obtain ⟨ ⟨ N, rfl ⟩, hm ⟩ := hm; exact ⟨ N, fun n hn => le_antisymm ( h_bounded hn ) ( hm _ <| Set.mem_range_self _ ) ⟩ ;

/-- **A globally minimal valid candidate exists.**  As soon as some candidate is
valid, there is a valid candidate whose complexity is `≤` that of every valid
candidate. -/
theorem exists_minimal (hT : ∃ c, S.valid c) :
    ∃ c_min, S.valid c_min ∧ ∀ c', S.valid c' → S.complexity c_min ≤ S.complexity c' := by
  by_contra! h
  obtain ⟨c, hc_valid, hc_min⟩ :=
    S.refines_wellFounded.has_min {c | S.valid c} ⟨_, hT.choose_spec⟩
  obtain ⟨c', hc', hlt⟩ := h c hc_valid
  exact hc_min c' hc' ⟨hc', hc_valid, hlt⟩

end RefinementSystem

/-! ## Counterexample 1: two distinct global minima

For the (true) target `2 + 2 = 4` we build a system with two distinct valid
candidates of equal, globally minimal complexity. -/

/-- Candidates for `2 + 2 = 4`: two distinct "single-step" proofs of complexity
`1` and a verbose proof of complexity `3`. -/
inductive GMCand where
  | rflProof
  | normNumProof
  | verboseProof
  deriving DecidableEq

/-- Complexity assignment: the two single-step proofs both weigh `1`. -/
def gmComplexity : GMCand → ℕ
  | .rflProof => 1
  | .normNumProof => 1
  | .verboseProof => 3

/-- The refinement system whose target is `2 + 2 = 4`.  Since the target holds,
every candidate is valid. -/
def globalMinimaSystem : RefinementSystem where
  Candidate := GMCand
  valid := fun _ => (2 + 2 = 4)
  complexity := gmComplexity

/-- **Two distinct global minima.**  There are two distinct candidates, both
valid and both globally complexity-minimal. -/
theorem two_distinct_global_minima :
    ∃ c1 c2 : globalMinimaSystem.Candidate,
      c1 ≠ c2 ∧
      globalMinimaSystem.valid c1 ∧ globalMinimaSystem.valid c2 ∧
      globalMinimaSystem.complexity c1 = globalMinimaSystem.complexity c2 ∧
      (∀ c', globalMinimaSystem.valid c' →
        globalMinimaSystem.complexity c1 ≤ globalMinimaSystem.complexity c') ∧
      (∀ c', globalMinimaSystem.valid c' →
        globalMinimaSystem.complexity c2 ≤ globalMinimaSystem.complexity c') := by
  refine ⟨GMCand.rflProof, GMCand.normNumProof, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact fun h => GMCand.noConfusion h
  · show (2 + 2 : ℕ) = 4; norm_num
  · show (2 + 2 : ℕ) = 4; norm_num
  · rfl
  · intro c' _; cases c' <;> decide
  · intro c' _; cases c' <;> decide

/-! ## Counterexample 2: a local minimum that is not global

We model a deterministic process on four candidates.  The process descends
`start (5) ⇝ mid (4) ⇝ local (3)` and then gets stuck, even though a strictly
simpler valid candidate `global (2)` exists — it is simply unreachable by the
process's allowed steps.  Thus well-foundedness, halting and existence of a
global minimum do *not* imply the process reaches the global optimum. -/

/-- Candidates for the local-minimum example, with complexities `5, 4, 3, 2`. -/
inductive LMCand where
  | cstart
  | cmid
  | clocal
  | cglobal
  deriving DecidableEq

/-- Complexity weights: `start = 5`, `mid = 4`, `local = 3`, `global = 2`. -/
def lmComplexity : LMCand → ℕ
  | .cstart => 5
  | .cmid => 4
  | .clocal => 3
  | .cglobal => 2

/-- The refinement system for the local-minimum example; every candidate is
valid. -/
def localMinSystem : RefinementSystem where
  Candidate := LMCand
  valid := fun _ => True
  complexity := lmComplexity

/-- The deterministic process step.  It descends `start ⇝ mid ⇝ local` and then
loops at `local`; `global` is a separate fixed point never produced by the
process. -/
def lmNext : LMCand → LMCand
  | .cstart => .cmid
  | .cmid => .clocal
  | .clocal => .clocal
  | .cglobal => .cglobal

/-- An *allowed process step*: the deterministic successor `lmNext`, provided it
strictly decreases complexity. -/
def lmStep (p' p : LMCand) : Prop :=
  lmNext p = p' ∧ lmComplexity p' < lmComplexity p

/-- The process genuinely descends `start ⇝ mid ⇝ local`. -/
theorem local_min_process_decreases :
    lmStep LMCand.cmid LMCand.cstart ∧ lmStep LMCand.clocal LMCand.cmid := by
  refine ⟨⟨rfl, ?_⟩, ⟨rfl, ?_⟩⟩ <;> decide

/-- **`clocal` is a local minimum.**  The process cannot take any further
allowed step from `clocal`. -/
theorem clocal_is_local_min : ¬ ∃ p', lmStep p' LMCand.clocal := by
  rintro ⟨p', hp, hlt⟩
  simp only [lmNext] at hp
  subst hp
  exact absurd hlt (by decide)

/-- **`clocal` is not a global minimum.**  The strictly simpler candidate
`cglobal` is valid and refines `clocal` in the full refinement relation, even
though the process can never reach it. -/
theorem clocal_not_global_min :
    localMinSystem.refines LMCand.cglobal LMCand.clocal := by
  refine ⟨trivial, trivial, ?_⟩
  decide

/-- **The local minimum is not global.**  Packaged form: a valid candidate
strictly simpler than `clocal` exists, yet the process admits no step out of
`clocal`. -/
theorem local_min_not_global :
    (∃ c', localMinSystem.valid c' ∧
      localMinSystem.complexity c' < localMinSystem.complexity LMCand.clocal) ∧
    ¬ ∃ p', lmStep p' LMCand.clocal := by
  refine ⟨⟨LMCand.cglobal, trivial, ?_⟩, clocal_is_local_min⟩
  decide

end ProofRefinement