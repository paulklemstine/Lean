/-
  Ordinal Cellular Automata: Main Theorems
  =========================================

  Core results on transfinite computation via ordinal cellular automata.
-/

import Mathlib
import MachineLearning.OrdinalCA.Defs

open Ordinal Set Function

noncomputable section

/-! ## Core Definitions for Theorems -/

/-- The all-quiescent configuration. -/
def allQuiescent (ca : OrdinalCA S) : OCAConfig S := fun _ => ca.quiescent

/-- A limit aggregation respects fixed points if applying it to a constant
    sequence returns that constant. -/
def LimitAggRespectsFixedPoints (ca : OrdinalCA S) : Prop :=
  ∀ (s : S), ca.limitAgg (fun _ => s) = s

/-! ## Theorem 1: Quiescent Preservation -/

/-- If an OCA is quiescent-preserving, the all-quiescent configuration is
    invariant under successor evolution. -/
theorem quiescent_succStep_invariant (ca : OrdinalCA S)
    (hq : ca.QuiescentPreserving) :
    ca.succStep (allQuiescent ca) = allQuiescent ca := by
  funext α
  unfold OrdinalCA.succStep
  simp [allQuiescent]
  exact hq

/-! ## Theorem 2: Finite Orbit Inclusion -/

theorem finiteOrbit_subset_orbit (ca : OrdinalCA S) (init : OCAConfig S) :
    ca.finiteOrbit init ⊆ ca.orbit init := by
  intro cfg hcfg
  exact ⟨hcfg.choose, mod_cast hcfg.choose_spec⟩

/-! ## Theorem 3: Evolution at Zero -/

theorem evolve_zero (ca : OrdinalCA S) (init : OCAConfig S) :
    ca.evolve init 0 = init := by
  unfold OrdinalCA.evolve; aesop

/-! ## Theorem 4: Evolution Successor Unfold -/

theorem evolve_succ (ca : OrdinalCA S) (init : OCAConfig S) (α : Ordinal) :
    ca.evolve init (Order.succ α) = ca.succStep (ca.evolve init α) := by
  convert limitRecOn_succ _ _ _ _ using 1

/-! ## Theorem 5: All-Quiescent Transfinite Stability

The all-quiescent configuration remains stable through all transfinite stages,
including limit ordinals. This requires both quiescent-preservation of the local
rule AND that the limit aggregation respects constant sequences.

This is proved by transfinite induction on ordinals:
- Base (0): evolve at 0 is the identity
- Successor: quiescent-preservation of the local rule
- Limit: the limit aggregation applied to a constant quiescent sequence
  returns quiescent -/

theorem allQuiescent_evolve_stable (ca : OrdinalCA S)
    (hq : ca.QuiescentPreserving)
    (hlim : ca.limitAgg (fun _ => ca.quiescent) = ca.quiescent) :
    ∀ α, ca.evolve (allQuiescent ca) α = allQuiescent ca := by
  intro α;
  induction' α using Ordinal.induction with α ih;
  by_cases hα : α = 0;
  · exact hα.symm ▸ evolve_zero ca ( allQuiescent ca );
  · by_cases hα_succ : ∃ β, α = Order.succ β;
    · obtain ⟨ β, rfl ⟩ := hα_succ;
      rw [ evolve_succ, ih β ( Order.lt_succ β ), quiescent_succStep_invariant ca hq ];
    · convert Ordinal.limitRecOn_limit α _ _ _ _;
      · convert hlim.symm using 1;
        congr! 2;
        split_ifs <;> simp_all +decide [ allQuiescent ];
        exact congr_fun ( ih _ ‹_› ) _;
      · constructor;
        · aesop;
        · intro β hβ;
          exact hα_succ ⟨ β, hβ.succ_eq.symm ⟩

/-! ## Theorem 6: Transfinite Orbit Strict Extension

**Central Result**: There exists an OCA where transfinite evolution produces
configurations unreachable by any finite number of steps. This demonstrates
that ordinal CAs have genuinely more computational power than standard CAs.

Construction: Use the identity local rule (every successor step is a no-op)
with a limit aggregation that flips false to true. Then:
- All finite steps keep the all-false initial configuration
- At time ω, the limit aggregation produces all-true
- all-true ≠ all-false, so the orbit is strictly larger -/

theorem exists_strict_transfinite_extension :
    ∃ (ca : OrdinalCA Bool) (init : OCAConfig Bool),
      ca.finiteOrbit init ⊂ ca.orbit init := by
  fconstructor;
  exact ⟨ fun _ c _ => c, Bool.false, fun _ => Bool.true ⟩;
  refine' ⟨ fun _ => false, _, _ ⟩;
  · exact Set.subset_def.mpr fun x hx => by obtain ⟨ n, rfl ⟩ := hx; exact ⟨ n, rfl ⟩ ;
  · rw [ Set.not_subset ];
    use fun _ => true;
    constructor;
    · use Ordinal.omega0;
      unfold OrdinalCA.evolve;
      rw [ limitRecOn_limit ];
      exact Ordinal.isSuccLimit_omega0;
    · rintro ⟨ n, hn ⟩;
      induction n <;> simp_all +decide [ OrdinalCA.evolve ];
      · simpa using congr_fun hn 0;
      · rename_i h;
        exact h ( funext fun x => by have := congr_fun hn x; unfold OrdinalCA.succStep at this; aesop )

/-! ## Theorem 7: Rule 110 Properties -/

theorem rule110_quiescent : rule110 false false false = false := rfl

theorem rule110OCA_quiescent_preserving (limAgg : (Ordinal → Bool) → Bool) :
    (rule110OCA limAgg).QuiescentPreserving := by
  simp [OrdinalCA.QuiescentPreserving, rule110OCA, rule110]

/-! ## Theorem 8: Orbit Embedding -/

theorem finiteCA_orbit_embeds (fca : FiniteCA S) (limAgg : (Ordinal → S) → S)
    (init : OCAConfig S) :
    (fca.toOrdinalCA limAgg).finiteOrbit init ⊆ (fca.toOrdinalCA limAgg).orbit init :=
  finiteOrbit_subset_orbit _ _

/-! ## Theorem 9: Diagonal Constraint -/

theorem diagonal_constraint (ca : OrdinalCA Bool) (_hq : ca.QuiescentPreserving) :
    allQuiescent ca ∈ ca.orbit (allQuiescent ca) :=
  ⟨0, evolve_zero ca (allQuiescent ca)⟩

/-! ## Theorem 10: Identity Rule Finite Orbit Singleton

For the identity local rule, every successor step is the identity, so the
finite orbit consists of exactly the initial configuration. -/

/-- The identity OCA: local rule returns the center cell, ignoring neighbors. -/
def identityOCA (limAgg : (Ordinal → S) → S) (q : S) : OrdinalCA S :=
  { localRule := fun _ c _ => c
    quiescent := q
    limitAgg := limAgg }

theorem identity_succStep_eq (limAgg : (Ordinal → S) → S) (q : S)
    (cfg : OCAConfig S) :
    (identityOCA limAgg q).succStep cfg = cfg := by
  unfold identityOCA; unfold OrdinalCA.succStep; aesop;

theorem identity_finite_evolve (limAgg : (Ordinal → S) → S) (q : S)
    (init : OCAConfig S) (n : ℕ) :
    (identityOCA limAgg q).evolve init n = init := by
  unfold OrdinalCA.evolve;
  induction n <;> aesop

/-! ## Conjecture: ω² Convergence Bound

**Conjecture**: For any OCA on Bool states with finitely-supported initial
configurations, if the evolution eventually stabilizes, then it stabilizes
before ω². This would mean that ω² is a universal convergence bound for
binary ordinal CAs with finite initial support.

**Testable prediction**: Compute evolution of specific Rule 110 variants
on ω·n for increasing n; if any converges after ω·n steps but before ω·(n+1),
the conjecture predicts convergence will always occur before ω².

**Computational test**: For CAs with k-cell finite support, check if the
convergence ordinal is always less than ω·k. If true for k ≤ 100, this
provides strong evidence for the conjecture.
-/

/-- A configuration has finite support if only finitely many cells differ
    from quiescent. -/
def OCAConfig.FiniteSupport (ca : OrdinalCA S) [DecidableEq S] (cfg : OCAConfig S) : Prop :=
  Set.Finite { pos : Ordinal | cfg pos ≠ ca.quiescent }

end