/-
# Transfinite Proof Refinement Systems

This module extends proof refinement systems to ordinal-valued complexity measures.
The key result is that even with transfinite complexity, iterating any optimizer
reaches a fixed point in finitely many steps — because a non-increasing ℕ-indexed
sequence of ordinals must stabilize (well-foundedness of ordinals).

## Main Results

- `ordinal_refinement_wellFounded`: Ordinal refinement is well-founded
- `Ordinal.nonincreasing_eventually_constant`: Non-increasing ℕ → Ordinal stabilizes
- `ordinal_optimizer_reaches_fixed_complexity`: Fixed-point theorem for ordinal optimizers
- `ordinal_chain_length_bound`: Chain length bounded by complexity
- `embed_preserves_refinement`: ℕ systems embed into ordinal systems
- `composition_optimizer_fixed_point`: Composed optimizers reach fixed points
- `lyapunov_convergence_ordinal`: Lyapunov certificate implies convergence
- `strict_optimizer_reaches_fixed_point`: Strict optimizers reach genuine fixed points

## Novel Concepts

- `OrdinalRefinementSystem`: Refinement with ordinal-valued complexity
- `OrdinalOptimizer` / `StrictOrdinalOptimizer`: Optimizers for ordinal systems
- `OrdinalLyapunovCertificate`: Lyapunov certificate with ordinal potential
-/

import Mathlib

/-! ## Core Definitions -/

/-- An ordinal refinement system generalizes proof refinement systems by allowing
complexity to take values in the well-ordered class of ordinals. This enables
modeling processes that require transfinite induction for termination arguments,
such as ordinal analysis, higher-type computation, and transfinite optimization. -/
structure OrdinalRefinementSystem where
  /-- The type of theorems -/
  Thm : Type
  /-- The type of proofs -/
  Prf : Type
  /-- What theorem a proof establishes -/
  proves : Prf → Thm
  /-- Complexity measure taking values in ordinals -/
  complexity : Prf → Ordinal

namespace OrdinalRefinementSystem

variable (S : OrdinalRefinementSystem)

/-- P' is a refinement of P if it proves the same theorem with strictly lower
ordinal complexity -/
def IsRefinement (p' p : S.Prf) : Prop :=
  S.proves p' = S.proves p ∧ S.complexity p' < S.complexity p

/-- A proof is minimal if no refinement exists -/
def IsMinimal (p : S.Prf) : Prop :=
  ∀ p' : S.Prf, ¬S.IsRefinement p' p

/-- A refinement chain of length n -/
structure RefinementChain (n : ℕ) where
  proofs : Fin (n + 1) → S.Prf
  refines : ∀ i : Fin n, S.IsRefinement
    (proofs ⟨i.val + 1, Nat.add_lt_add_right i.isLt 1⟩)
    (proofs ⟨i.val, Nat.lt_of_lt_of_le i.isLt (Nat.le_succ n)⟩)

end OrdinalRefinementSystem

/-! ## Well-Foundedness of Ordinal Refinement -/

/-- The ordinal refinement relation is well-founded because ordinals are
well-ordered. No infinite chain of strict ordinal refinements exists. -/
theorem ordinal_refinement_wellFounded (S : OrdinalRefinementSystem) :
    WellFounded (fun p' p => S.IsRefinement p' p) :=
  WellFounded.mono (InvImage.wf S.complexity Ordinal.lt_wf) fun _ _ h => h.2

/-! ## No Infinite Descent in Well-Founded Orders -/

/-- There is no strictly decreasing ℕ-indexed sequence in a well-founded order.
This is the sequential characterization of well-foundedness. -/
theorem no_infinite_descent_ordinal (f : ℕ → Ordinal)
    (hf : ∀ n, f (n + 1) < f n) : False := by
  have h := Ordinal.lt_wf.has_min (Set.range f) ⟨f 0, 0, rfl⟩
  obtain ⟨_, ⟨k, rfl⟩, hmin⟩ := h
  exact hmin (f (k + 1)) ⟨k + 1, rfl⟩ (hf k)

/-! ## Non-increasing Ordinal Sequences Stabilize -/

/-
**Key Lemma**: A non-increasing sequence ℕ → Ordinal eventually stabilizes.
Even though ordinals can be uncountable, a non-increasing ℕ-indexed sequence
can only decrease finitely many times because ordinals are well-ordered.

The proof works by contradiction: if the sequence never stabilizes, we can
extract infinitely many strict decreases, contradicting well-foundedness.
-/
theorem Ordinal.nonincreasing_eventually_constant (f : ℕ → Ordinal)
    (hf : ∀ n, f (n + 1) ≤ f n) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → f n = f N := by
  by_contra! h_contra;
  -- We can recursively build a strictly decreasing subsequence: let g(0) = 0, and given g(k), find g(k+1) > g(k) with f(g(k+1)) < f(g(k)).
  have h_subseq : ∃ g : ℕ → ℕ, StrictMono g ∧ ∀ n, f (g (n + 1)) < f (g n) := by
    -- We can construct such a sequence by induction on $n$.
    have h_seq : ∀ n, ∃ m > n, f m < f n := by
      intro n
      obtain ⟨m, hm₁, hm₂⟩ := h_contra n
      by_cases hm₃ : m = n;
      · aesop;
      · exact ⟨ m, lt_of_le_of_ne hm₁ ( Ne.symm hm₃ ), lt_of_le_of_ne ( by exact Nat.le_induction ( by tauto ) ( fun k hk ih => by exact le_trans ( hf k ) ih ) m hm₁ ) hm₂ ⟩;
    exact ⟨ fun n => Nat.recOn n 0 fun n ih => Nat.find ( h_seq ih ), strictMono_nat_of_lt_succ fun n => Nat.find_spec ( h_seq _ ) |>.1, fun n => Nat.find_spec ( h_seq _ ) |>.2 ⟩;
  exact no_infinite_descent_ordinal ( fun n => f ( h_subseq.choose n ) ) ( fun n => h_subseq.choose_spec.2 n )

/-
Helper: the antitone property extends to arbitrary gaps
-/
theorem ordinal_antitone_of_succ_le (f : ℕ → Ordinal)
    (hf : ∀ n, f (n + 1) ≤ f n) : Antitone f := by
  exact antitone_nat_of_succ_le hf

/-! ## Chain Length Bound -/

/-- In an ordinal refinement chain, complexities strictly decrease. -/
theorem ordinal_chain_complexity_strictDecreasing (S : OrdinalRefinementSystem) (n : ℕ)
    (chain : S.RefinementChain n) (i : Fin n) :
    S.complexity (chain.proofs ⟨i.val + 1, Nat.add_lt_add_right i.isLt 1⟩) <
    S.complexity (chain.proofs ⟨i.val, Nat.lt_of_lt_of_le i.isLt (Nat.le_succ n)⟩) :=
  (chain.refines i).2

/-
**Chain Length Bound**: Any refinement chain of length n satisfies
↑n ≤ complexity of the initial element (as ordinals).
-/
theorem ordinal_chain_length_bound (S : OrdinalRefinementSystem) (n : ℕ)
    (chain : S.RefinementChain n) :
    (n : Ordinal) ≤ S.complexity (chain.proofs ⟨0, Nat.zero_lt_succ n⟩) := by
  induction' n with n ih;
  · norm_num;
  · convert Order.add_one_le_of_lt ( lt_of_le_of_lt ( ih ⟨ fun i => chain.proofs ( Fin.succ i ), fun i => chain.refines ( Fin.succ i ) ⟩ ) ( chain.refines 0 |>.2 ) ) using 1

/-! ## Ordinal Optimizers and Fixed Points -/

/-- An ordinal proof optimizer preserves theorems and never increases
ordinal complexity. -/
structure OrdinalOptimizer (S : OrdinalRefinementSystem) where
  /-- The optimization function -/
  optimize : S.Prf → S.Prf
  /-- Preserves which theorem is proved -/
  preserves_theorem : ∀ p, S.proves (optimize p) = S.proves p
  /-- Never increases ordinal complexity -/
  nonincreasing : ∀ p, S.complexity (optimize p) ≤ S.complexity p

namespace OrdinalOptimizer

variable {S : OrdinalRefinementSystem}

/-- Iterating an ordinal optimizer n times -/
def iterate (opt : OrdinalOptimizer S) : ℕ → S.Prf → S.Prf
  | 0, p => p
  | n + 1, p => opt.optimize (opt.iterate n p)

/-- Iteration preserves the theorem being proved -/
theorem iterate_preserves (opt : OrdinalOptimizer S) (n : ℕ) (p : S.Prf) :
    S.proves (opt.iterate n p) = S.proves p := by
  induction n with
  | zero => rfl
  | succ n ih => simp [iterate, opt.preserves_theorem, ih]

/-- Complexity is non-increasing under iteration -/
theorem iterate_complexity_nonincreasing (opt : OrdinalOptimizer S) (n : ℕ) (p : S.Prf) :
    S.complexity (opt.iterate (n + 1) p) ≤ S.complexity (opt.iterate n p) :=
  opt.nonincreasing _

end OrdinalOptimizer

/-
**Transfinite Fixed-Point Theorem**: Iterating any ordinal optimizer reaches
a fixed point in complexity in finitely many steps. Even though the complexity
values are ordinals (potentially uncountable), the ℕ-indexed orbit must
stabilize because a non-increasing sequence in a well-ordered set cannot
decrease infinitely often.

This is the central theorem of transfinite refinement theory: ω steps of
iteration always suffice, regardless of the ordinal complexity.
-/
theorem ordinal_optimizer_reaches_fixed_complexity {S : OrdinalRefinementSystem}
    (opt : OrdinalOptimizer S) (p : S.Prf) :
    ∃ N : ℕ,
      (∀ n : ℕ, N ≤ n →
        S.complexity (opt.iterate n p) = S.complexity (opt.iterate N p)) ∧
      S.complexity (opt.iterate N p) ≤ S.complexity p := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → S.complexity (opt.iterate n p) = S.complexity (opt.iterate N p) := by
    apply Ordinal.nonincreasing_eventually_constant;
    grind +suggestions;
  refine' ⟨ N, hN, _ ⟩;
  exact Nat.recOn N ( by tauto ) fun n ihn => by simpa [ OrdinalOptimizer.iterate ] using le_trans ( opt.iterate_complexity_nonincreasing n p ) ihn;

/-! ## Embedding ℕ Systems into Ordinal Systems -/

/-- A proof refinement system with ℕ-valued complexity -/
structure NatRefinementSystem where
  Thm : Type
  Prf : Type
  proves : Prf → Thm
  complexity : Prf → ℕ

/-- Every ℕ-valued refinement system embeds canonically into an ordinal-valued one
via the inclusion ℕ ↪ Ordinal. -/
def embed_nat_to_ordinal_system (S : NatRefinementSystem) : OrdinalRefinementSystem where
  Thm := S.Thm
  Prf := S.Prf
  proves := S.proves
  complexity := fun p => (S.complexity p : Ordinal)

/-- The embedding preserves the refinement relation -/
theorem embed_preserves_refinement (S : NatRefinementSystem) (p' p : S.Prf)
    (hproves : S.proves p' = S.proves p) (hlt : S.complexity p' < S.complexity p) :
    (embed_nat_to_ordinal_system S).IsRefinement p' p :=
  ⟨hproves, Nat.cast_lt.mpr hlt⟩

/-- The embedding reflects the refinement relation -/
theorem embed_reflects_refinement (S : NatRefinementSystem) (p' p : S.Prf)
    (h : (embed_nat_to_ordinal_system S).IsRefinement p' p) :
    S.proves p' = S.proves p ∧ S.complexity p' < S.complexity p :=
  ⟨h.1, Nat.cast_lt.mp h.2⟩

/-! ## Composition of Optimizers -/

/-- The composition of two ordinal optimizers is again an optimizer -/
def OrdinalOptimizer.comp {S : OrdinalRefinementSystem}
    (opt₁ opt₂ : OrdinalOptimizer S) : OrdinalOptimizer S where
  optimize := opt₁.optimize ∘ opt₂.optimize
  preserves_theorem := fun p => by
    simp [Function.comp, opt₁.preserves_theorem, opt₂.preserves_theorem]
  nonincreasing := fun p => le_trans (opt₁.nonincreasing _) (opt₂.nonincreasing _)

/-- **Composition Fixed-Point Theorem**: The composition of two optimizers
reaches a fixed point in complexity. -/
theorem composition_optimizer_fixed_point {S : OrdinalRefinementSystem}
    (opt₁ opt₂ : OrdinalOptimizer S) (p : S.Prf) :
    ∃ N : ℕ,
      (∀ n : ℕ, N ≤ n →
        S.complexity ((opt₁.comp opt₂).iterate n p) =
        S.complexity ((opt₁.comp opt₂).iterate N p)) ∧
      S.complexity ((opt₁.comp opt₂).iterate N p) ≤ S.complexity p :=
  ordinal_optimizer_reaches_fixed_complexity (opt₁.comp opt₂) p

/-! ## Lyapunov Certificates for Ordinal Refinement -/

/-- A Lyapunov certificate for an ordinal refinement system consists of a
potential function V : Prf → Ordinal that is non-increasing and strictly
decreases whenever the optimizer changes complexity. This is the ordinal
analogue of Lyapunov stability from control theory. -/
structure OrdinalLyapunovCertificate (S : OrdinalRefinementSystem)
    (opt : OrdinalOptimizer S) where
  /-- The Lyapunov potential function -/
  potential : S.Prf → Ordinal
  /-- Potential is non-increasing under optimization -/
  nonincreasing : ∀ p, potential (opt.optimize p) ≤ potential p
  /-- Potential strictly decreases when complexity changes -/
  strict_decrease : ∀ p, S.complexity (opt.optimize p) ≠ S.complexity p →
    potential (opt.optimize p) < potential p

/-
**Lyapunov Convergence Theorem**: If a Lyapunov certificate exists for an
ordinal optimizer, then the optimizer reaches a complexity fixed point, and
the potential also stabilizes.
-/
theorem lyapunov_convergence_ordinal {S : OrdinalRefinementSystem}
    {opt : OrdinalOptimizer S} (cert : OrdinalLyapunovCertificate S opt) (p : S.Prf) :
    ∃ N : ℕ,
      (∀ n, N ≤ n →
        S.complexity (opt.iterate n p) = S.complexity (opt.iterate N p)) ∧
      (∀ n, N ≤ n →
        cert.potential (opt.iterate n p) = cert.potential (opt.iterate N p)) := by
  obtain ⟨ N, hN ⟩ := Ordinal.nonincreasing_eventually_constant ( fun n => cert.potential ( opt.iterate n p ) ) ( fun n => cert.nonincreasing _ );
  refine' ⟨ N, _, hN ⟩;
  intro n hn; induction hn <;> simp_all +decide [ OrdinalOptimizer.iterate ] ;
  rename_i k hk ih; have := hN ( k + 1 ) ( by linarith ) ; simp_all +decide [ OrdinalOptimizer.iterate ] ;
  contrapose! this;
  exact ne_of_lt ( lt_of_lt_of_le ( cert.strict_decrease _ ( by aesop ) ) ( by aesop ) )

/-! ## Strict Optimizer Theorem -/

/-- A strict optimizer always strictly decreases complexity on non-fixed-points -/
structure StrictOrdinalOptimizer (S : OrdinalRefinementSystem) extends
    OrdinalOptimizer S where
  /-- Strictly decreases complexity unless already at a fixed point -/
  strict_on_nonfixed : ∀ p, optimize p ≠ p →
    S.complexity (optimize p) < S.complexity p

/-
**Strict Optimizer Fixed-Point Theorem**: A strict optimizer reaches a genuine
fixed point (where optimize p = p) within finitely many steps.

The proof uses the fact that complexity strictly decreases at each non-fixed step,
and ordinals cannot have an infinite strictly decreasing sequence.
-/
theorem strict_optimizer_reaches_fixed_point {S : OrdinalRefinementSystem}
    [DecidableEq S.Prf]
    (opt : StrictOrdinalOptimizer S) (p : S.Prf) :
    ∃ N : ℕ, opt.iterate N p = opt.iterate (N + 1) p := by
  by_contra h;
  convert no_infinite_descent_ordinal ( fun n => S.complexity ( opt.iterate n p ) ) _ using 1;
  simp_all +decide [ OrdinalOptimizer.iterate ];
  exact fun n => opt.strict_on_nonfixed _ ( Ne.symm ( h n ) )

/-! ## Ordinal Gap Conjecture (Finite Case) -/

/-
For any natural number n, there exists an ordinal refinement system with a
refinement chain of length exactly n and initial complexity n. This is the
finite case of the ordinal gap conjecture.

**Falsifiable Conjecture**: For transfinite ordinals α ≥ ω, no ℕ-indexed
refinement chain can have length α. This reveals a fundamental asymmetry
between finite and transfinite refinement: ℕ-indexed chains are insufficient
to witness transfinite complexity gaps.
-/
theorem ordinal_gap_finite_case (n : ℕ) :
    ∃ (S : OrdinalRefinementSystem) (chain : S.RefinementChain n),
      S.complexity (chain.proofs ⟨0, Nat.zero_lt_succ n⟩) = (n : Ordinal) := by
  by_contra h_contra;
  -- Define the linear ordinal system with Thm = Unit, Prf = Fin (n+1), proves _ = (), and complexity i = n - i.
  set Thm := Unit
  set Prf := Fin (n + 1)
  set proves : Prf → Thm := fun _ => ()
  set complexity : Prf → Ordinal := fun i => (n - i.val : ℕ);
  refine' h_contra ⟨ ⟨ Thm, Prf, proves, complexity ⟩, ⟨ fun i => i, _ ⟩, _ ⟩ <;> norm_num;
  · intro i; exact ⟨ rfl, by
      exact Nat.cast_lt.mpr ( by rw [ tsub_lt_tsub_iff_left_of_le ] <;> linarith [ Fin.is_lt i ] ) ⟩ ;
  · aesop