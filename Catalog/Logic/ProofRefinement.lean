/-
# Proof Refinement Systems: Self-Improving Proofs

This module formalizes proof refinement systems where proofs can be simplified
over time. The key insight is that proof complexity (a natural number) strictly
decreases with each refinement, making the process well-founded.

## Main Results

- `refinement_wellFounded`: The refinement relation is well-founded
- `exists_minimal_proof`: Every proof admits a refinement to a minimal proof
- `refinement_chain_length_bound`: Any refinement chain has length ≤ initial complexity
- `exists_arbitrarily_long_chain`: For any N, there exist systems with chains of length N
- `complexity_gap_determines_chain_length`: The gap theorem for interpolation systems
-/

import Mathlib

/-! ## Core Definitions -/

/-- A proof refinement system consists of:
  - A type of theorems `Thm`
  - A type of proofs `Prf`
  - A function `proves` associating each proof to the theorem it proves
  - A complexity measure `complexity` taking values in ℕ
  - A refinement relation: P' refines P iff they prove the same theorem
    and C(P') < C(P)
-/
structure ProofRefinementSystem where
  /-- The type of theorems -/
  Thm : Type
  /-- The type of proofs -/
  Prf : Type
  /-- What theorem a proof establishes -/
  proves : Prf → Thm
  /-- Complexity measure: length + depth + number of lemmas -/
  complexity : Prf → ℕ

namespace ProofRefinementSystem

variable (S : ProofRefinementSystem)

/-- P' is a refinement of P if it proves the same theorem with strictly lower complexity -/
def IsRefinement (p' p : S.Prf) : Prop :=
  S.proves p' = S.proves p ∧ S.complexity p' < S.complexity p

/-- A proof is minimal if no refinement exists -/
def IsMinimal (p : S.Prf) : Prop :=
  ∀ p' : S.Prf, ¬S.IsRefinement p' p

/-- A refinement chain is a sequence of proofs where each refines the previous -/
structure RefinementChain (n : ℕ) where
  /-- The sequence of proofs in the chain -/
  proofs : Fin (n + 1) → S.Prf
  /-- Each proof refines the previous one -/
  refines : ∀ i : Fin n, S.IsRefinement
    (proofs ⟨i.val + 1, Nat.add_lt_add_right i.isLt 1⟩)
    (proofs ⟨i.val, Nat.lt_of_lt_of_le i.isLt (Nat.le_succ n)⟩)

end ProofRefinementSystem

/-! ## Well-Foundedness of Refinement -/

/-
The complexity-based order on proofs is well-founded because ℕ is well-ordered.
This is the fundamental theorem: no infinite chain of strict refinements exists.
-/
theorem refinement_wellFounded (S : ProofRefinementSystem) :
    WellFounded (fun p' p => S.IsRefinement p' p) := by
  -- The complexity function is a measure of the proof's length, depth, and number of lemmas. Therefore, the relation is well-founded.
  have h_wf : WellFounded (fun p p' : S.Prf => S.complexity p < S.complexity p') := by
    have h_wf : WellFounded (fun n m : ℕ => n < m) := by
      exact wellFounded_lt;
    exact WellFounded.onFun h_wf;
  exact h_wf.mono fun x y h => h.2

/-
In any refinement chain, complexities strictly decrease along the chain
-/
theorem chain_complexity_strictDecreasing (S : ProofRefinementSystem) (n : ℕ)
    (chain : S.RefinementChain n) (i : Fin n) :
    S.complexity (chain.proofs ⟨i.val + 1, Nat.add_lt_add_right i.isLt 1⟩) <
    S.complexity (chain.proofs ⟨i.val, Nat.lt_of_lt_of_le i.isLt (Nat.le_succ n)⟩) := by
  exact chain.refines i |>.2

/-
The length of any refinement chain is bounded by the complexity of its first element
-/
theorem refinement_chain_length_bound (S : ProofRefinementSystem) (n : ℕ)
    (chain : S.RefinementChain n) :
    n ≤ S.complexity (chain.proofs ⟨0, Nat.zero_lt_succ n⟩) := by
  induction' n with n ih;
  · exact Nat.zero_le _;
  · -- By definition of a refinement chain, the complexity of the first proof is at least n.
    have h_complexity_first : n ≤ S.complexity (chain.proofs ⟨1, by linarith⟩) := by
      contrapose! ih;
      use ⟨fun i => chain.proofs ⟨i.val + 1, by linarith [Fin.is_lt i]⟩, fun i => chain.refines ⟨i.val + 1, by linarith [Fin.is_lt i]⟩⟩;
    exact Nat.succ_le_of_lt ( lt_of_le_of_lt h_complexity_first ( chain_complexity_strictDecreasing S ( n + 1 ) chain ⟨ 0, by linarith ⟩ ) )

/-! ## Existence of Minimal Proofs -/

/-
Every proof can be refined to a minimal proof. This follows from well-foundedness:
the process of repeatedly applying refinements must terminate.
-/
theorem exists_minimal_proof (S : ProofRefinementSystem) (p : S.Prf) :
    ∃ p_min : S.Prf,
      S.proves p_min = S.proves p ∧
      S.IsMinimal p_min ∧
      (p_min = p ∨ S.complexity p_min < S.complexity p) := by
  -- We apply � well�-founded induction on the complexity measure `complexity`.
  have induction_step : ∀ (p : S.Prf),
    (∀ p' : S.Prf, S.IsRefinement p' p → ∃ p_min : S.Prf,
      S.proves p_min = S.proves p' ∧ S.IsMinimal p_min ∧ (p_min = p' ∨ S.complexity p_min < S.complexity p')) →
    ∃ p_min : S.Prf,
      S.proves p_min = S.proves p ∧ S.IsMinimal p_min ∧ (p_min = p ∨ S.complexity p_min < S.complexity p) := by
        grind +locals;
  -- By induction on the complexity measure `complexity`, we can show that for any proof `p`, there exists a minimal proof `p_min` such that `S.proves p_min = S.proves p`.
  have induction : ∀ (n : ℕ), ∀ (p : S.Prf), S.complexity p = n → ∃ p_min : S.Prf,
    S.proves p_min = S.proves p ∧ S.IsMinimal p_min ∧ (p_min = p ∨ S.complexity p_min < S.complexity p) := by
      intro n
      induction' n using Nat.strong_induction_on with n ih;
      exact fun p hp => induction_step p fun p' hp' => ih _ ( hp'.2.trans_le ( by linarith ) ) _ rfl;
  exact induction _ _ rfl

/-! ## Complexity Gap Theorem -/

/-- A proof system has the interpolation property if for every non-minimal proof,
there exists a refinement of complexity exactly c - 1. -/
def ProofRefinementSystem.HasInterpolation (S : ProofRefinementSystem) : Prop :=
  ∀ p : S.Prf, ¬S.IsMinimal p →
    ∃ p' : S.Prf, S.IsRefinement p' p ∧ S.complexity p' + 1 = S.complexity p

/-
In a system with interpolation, a refinement chain of maximum length exists
from any proof to a proof of minimal complexity.
-/
theorem complexity_gap_determines_chain_length
    (S : ProofRefinementSystem) (hI : S.HasInterpolation)
    (p : S.Prf) (p_min : S.Prf)
    (_hmin : S.IsMinimal p_min) (hsame : S.proves p_min = S.proves p)
    (hle : S.complexity p_min ≤ S.complexity p) :
    ∃ chain : S.RefinementChain (S.complexity p - S.complexity p_min),
      chain.proofs ⟨0, Nat.zero_lt_succ _⟩ = p := by
  revert hle hsame p_min _hmin;
  intro p_min _hmin hsame hle
  induction' k : S.complexity p - S.complexity p_min with k ih generalizing p;
  · refine' ⟨ ⟨ fun _ => p, _ ⟩, rfl ⟩;
    simp +decide;
  · -- By interpolation, there exists a proof � $�p'$ such that $S.IsRefinement p' p$ and $S.complexity p' + 1 = S.complexity p$.
    obtain ⟨p', hp'⟩ : ∃ p' : S.Prf, S.IsRefinement p' p ∧ S.complexity p' + 1 = S.complexity p := by
      apply hI p;
      exact fun h => by have := h p_min; unfold ProofRefinementSystem.IsRefinement at this; aesop;
    obtain ⟨chain', hchain'⟩ := ih p' (by
    cases hp'.1 ; aesop) (by
    omega) (by
    omega);
    refine' ⟨ ⟨ Fin.cons p chain'.proofs, _ ⟩, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
    exact fun i => chain'.refines i

/-! ## Arbitrarily Long Chains -/

/-- Construction: for any N, a linear proof system with N+1 proofs of a
single theorem, with complexities N, N-1, ..., 0. -/
def linearSystem (N : ℕ) : ProofRefinementSystem where
  Thm := Unit
  Prf := Fin (N + 1)
  proves := fun _ => ()
  complexity := fun i => N - i.val

/-
The linear system admits a refinement chain of length exactly N
-/
theorem linearSystem_chain_exists (N : ℕ) :
    ∃ chain : (linearSystem N).RefinementChain N,
      chain.proofs ⟨0, Nat.zero_lt_succ N⟩ = ⟨0, Nat.zero_lt_succ N⟩ := by
  refine' ⟨ _, _ ⟩;
  use fun i => ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩;
  simp +decide [ linearSystem, ProofRefinementSystem.IsRefinement ];
  exacts [ fun i => by rw [ tsub_lt_tsub_iff_left_of_le ] <;> linarith [ Fin.is_lt i ], rfl ]

/-
For any N, there exists a proof refinement system containing a refinement chain
of length at least N. Refinement chains can be arbitrarily long.
-/
theorem exists_arbitrarily_long_chain (N : ℕ) :
    ∃ (S : ProofRefinementSystem) (chain : S.RefinementChain N),
      S.complexity (chain.proofs ⟨0, Nat.zero_lt_succ N⟩) = N := by
  -- Let's choose the linear system S = linearSystem N.
  use linearSystem N;
  exact Exists.elim ( linearSystem_chain_exists N ) fun chain hchain => ⟨ chain, by aesop ⟩

/-! ## The Refinement Equivalence -/

/-- Two proofs are refinement-equivalent if they prove the same theorem
with the same complexity -/
def ProofRefinementSystem.RefEquiv (S : ProofRefinementSystem) (p q : S.Prf) : Prop :=
  S.proves p = S.proves q ∧ S.complexity p = S.complexity q

/-
Refinement equivalence is an equivalence relation
-/
theorem refEquiv_equivalence (S : ProofRefinementSystem) :
    Equivalence S.RefEquiv := by
  constructor <;> intros <;> simp_all +decide [ ProofRefinementSystem.RefEquiv ]

/-! ## Proof System Morphisms -/

/-- A strict morphism between proof systems preserves theorems and strictly preserves
complexity ordering -/
structure ProofSystemMorphism (S T : ProofRefinementSystem) where
  /-- Map on proofs -/
  mapPrf : S.Prf → T.Prf
  /-- Map on theorems -/
  mapThm : S.Thm → T.Thm
  /-- Preserves which theorem is proved -/
  preserves_proves : ∀ p, T.proves (mapPrf p) = mapThm (S.proves p)
  /-- Strictly preserves complexity ordering -/
  complexity_strictMono : ∀ p q, S.complexity p < S.complexity q →
    T.complexity (mapPrf p) < T.complexity (mapPrf q)

/-
A strict morphism preserves refinement: if P' refines P in S,
then f(P') refines f(P) in T
-/
theorem morphism_preserves_refinement (S T : ProofRefinementSystem)
    (f : ProofSystemMorphism S T) (p' p : S.Prf)
    (h : S.IsRefinement p' p) :
    T.IsRefinement (f.mapPrf p') (f.mapPrf p) := by
  exact ⟨ by rw [ f.preserves_proves, f.preserves_proves, h.1 ], f.complexity_strictMono _ _ h.2 ⟩

/-! ## Fixed Point Theorem for Proof Optimizers -/

/-- A proof optimizer is an endomorphism that preserves theorems and never increases complexity -/
structure ProofOptimizer (S : ProofRefinementSystem) where
  /-- The optimization function -/
  optimize : S.Prf → S.Prf
  /-- Preserves which theorem is proved -/
  preserves_theorem : ∀ p, S.proves (optimize p) = S.proves p
  /-- Never increases complexity -/
  nonincreasing : ∀ p, S.complexity (optimize p) ≤ S.complexity p

/-- Iterating a proof optimizer n times -/
def ProofOptimizer.iterate {S : ProofRefinementSystem} (opt : ProofOptimizer S)
    (n : ℕ) (p : S.Prf) : S.Prf :=
  match n with
  | 0 => p
  | n + 1 => opt.optimize (opt.iterate n p)

/-
Iterating an optimizer preserves the theorem being proved
-/
theorem optimizer_iterate_preserves {S : ProofRefinementSystem}
    (opt : ProofOptimizer S) (n : ℕ) (p : S.Prf) :
    S.proves (opt.iterate n p) = S.proves p := by
  induction' n with n ih generalizing p <;> simp_all +decide [ ProofOptimizer.iterate ];
  rw [ opt.preserves_theorem, ih ]

/-
The complexity sequence under iteration is non-increasing
-/
theorem optimizer_complexity_nonincreasing {S : ProofRefinementSystem}
    (opt : ProofOptimizer S) (n : ℕ) (p : S.Prf) :
    S.complexity (opt.iterate (n + 1) p) ≤ S.complexity (opt.iterate n p) := by
  exact opt.nonincreasing _

/-
A non-increasing sequence of natural numbers eventually stabilizes.
This is because ℕ has no infinite strictly decreasing chains.
-/
theorem Nat.nonincreasing_eventually_constant (f : ℕ → ℕ)
    (hf : ∀ n, f (n + 1) ≤ f n) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → f n = f N := by
  -- Since $f$ is non-increasing, the sequence $f(n)$ is bounded below and thus must eventually stabilize by the Monotone � Con�vergence Theorem.
  have h_monotone_conv : Filter.Tendsto f Filter.atTop (nhds (sInf {f n | n : ℕ})) := by
    apply_rules [ tendsto_atTop_ciInf ];
    · exact antitone_nat_of_succ_le hf;
    · exact OrderBot.bddBelow (Set.range f);
  simp +zetaDelta at *;
  exact ⟨ h_monotone_conv.choose, fun n hn => by rw [ h_monotone_conv.choose_spec n hn, h_monotone_conv.choose_spec _ le_rfl ] ⟩

/-
The total number of strict decreases in a non-increasing ℕ sequence
is bounded by the initial value.
-/
theorem Nat.nonincreasing_strict_decrease_bound (f : ℕ → ℕ)
    (_hf : ∀ n, f (n + 1) ≤ f n)
    (n : ℕ) (hn : ∀ i, i < n → f (i + 1) < f i) :
    n ≤ f 0 := by
  -- By induction, we have $f(i) \leq f(0) - i$ for all $i \leq n$.
  have h_ind : ∀ i ≤ n, f i ≤ f 0 - i := by
    intro i hi; induction' i with i ih <;> norm_num at *;
    grind;
  grind +ring

/-
**Fixed Point Theorem**: Iterating any proof optimizer reaches a fixed point
in complexity. The sequence C(opt^n(P)) is non-increasing in ℕ, hence eventually
constant. Moreover, the final complexity value is at most C(P).
-/
theorem optimizer_reaches_fixed_complexity {S : ProofRefinementSystem}
    (opt : ProofOptimizer S) (p : S.Prf) :
    ∃ N : ℕ,
      (∀ n : ℕ, N ≤ n →
        S.complexity (opt.iterate n p) = S.complexity (opt.iterate N p)) ∧
      S.complexity (opt.iterate N p) ≤ S.complexity p := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → S.complexity (opt.iterate n p) = S.complexity (opt.iterate N p) := by
    convert Nat.nonincreasing_eventually_constant ( fun n => S.complexity ( opt.iterate n p ) ) _ using 1;
    -- Apply the hypothesis `optimizer_complexity_nonincreasing` directly.
    intros n; exact optimizer_complexity_nonincreasing opt n p;
  exact ⟨ N, hN, Nat.recOn N ( by rfl ) fun n ihn => by simpa [ ProofOptimizer.iterate ] using le_trans ( opt.nonincreasing _ ) ihn ⟩

/-! ## Pigeonhole for Proof Complexity -/

/-
**Pigeonhole Theorem for Proofs**: If a proof system has finitely many
theorems but minimal proofs of arbitrarily high complexity, then some
single theorem admits minimal proofs of arbitrarily high complexity.

This is a key structural result: the "hardness" of proof optimization
cannot be distributed uniformly across finitely many theorems.
-/
theorem pigeonhole_minimal_complexity
    (S : ProofRefinementSystem) [Fintype S.Thm]
    (hRich : ∀ n : ℕ, ∃ p : S.Prf, S.IsMinimal p ∧ S.complexity p ≥ n) :
    ∃ t : S.Thm, ∀ n : ℕ,
      ∃ p : S.Prf, S.proves p = t ∧ S.IsMinimal p ∧ S.complexity p ≥ n := by
  contrapose! hRich;
  choose! n hn using hRich; use Finset.sup ( Finset.univ : Finset S.Thm ) n; aesop;

/-! ## Uncomputability Conjecture -/

/-
**Falsifiable Conjecture**: In any proof system where theorems are
natural numbers and minimal proofs exist for all theorems, the function
mapping each theorem to its minimal proof complexity cannot be bounded
by any fixed polynomial.

Stated more precisely: for any function `bound : ℕ → ℕ`, if the system
has a proof of every "theorem" n with complexity ≥ bound(n), then there
is no uniform computable predictor of minimal proof complexity.

Computational test: for the linear system of size N, verify that
minimal proof complexity = 0 for the unique theorem, showing the
conjecture applies only to multi-theorem systems.
-/
theorem linear_system_minimal_complexity (N : ℕ) :
    ∃ p : (linearSystem N).Prf,
      (linearSystem N).IsMinimal p ∧ (linearSystem N).complexity p = 0 := by
  -- By definition of `linearSystem`, the complexity of the proof `⟨N, Nat.lt_succ_self N⟩` is `0`.
  use ⟨N, Nat.lt_succ_self N⟩
  simp [linearSystem];
  intro p hp;
  cases hp ; aesop