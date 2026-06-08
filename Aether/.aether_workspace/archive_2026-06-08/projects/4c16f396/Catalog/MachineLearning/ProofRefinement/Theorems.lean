/-
# Proof Refinement Systems: Core Theorems

Main results:
1. Well-foundedness of refinement (no infinite descending chains)
2. Existence of minimal proofs
3. Bounded chain length from complexity
4. Fixed-point theorem for proof optimizers
5. Complexity monotonicity of optimizer orbits
6. Convergence: optimizer orbits stabilize in finite time
7. Chain length bounds from minimum gap
-/

import Mathlib
import MachineLearning.ProofRefinement.Defs

open scoped Classical

/-! ## Well-Foundedness -/

/-- The refinement relation in a ProofRefinementSystem is well-founded.
    This is the cornerstone result: since refinement strictly decreases
    natural number complexity, and ℕ is well-founded under <,
    there can be no infinite descending chain of refinements. -/
theorem refinement_wellFounded (S : ProofRefinementSystem) :
    WellFounded S.refines := by
  rw [WellFounded.wellFounded_iff_has_min]
  intro s hs_nonempty
  obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ n ∈ s, S.complexity n ≥ S.complexity m := by
    have h_well_ordering : ∀ (T : Set ℕ), T.Nonempty → ∃ m ∈ T, ∀ n ∈ T, m ≤ n := by
      exact fun T hT => ⟨Nat.find hT, Nat.find_spec hT, fun n hn => Nat.find_min' hT hn⟩
    specialize h_well_ordering (Set.image S.complexity s); aesop
  exact ⟨m, hm.1, fun n hn hnm => not_lt_of_ge (hm.2 n hn) (S.complexity_decreasing _ _ hnm)⟩

/-! ## Existence of Minimal Proofs -/

/-- Every proof in a refinement system can be simplified to a minimal proof
    whose complexity is no greater. This follows from well-foundedness:
    starting from any proof, repeatedly refining must terminate. -/
theorem exists_minimal_below (S : ProofRefinementSystem)
    (p : S.Proof) : ∃ q, S.IsMinimal q ∧ S.complexity q ≤ S.complexity p := by
  induction' n : S.complexity p using Nat.strong_induction_on with n ih generalizing p
  by_cases h : S.IsMinimal p
  · exact ⟨p, h, n.le⟩
  · obtain ⟨q, hq⟩ := not_forall.mp h
    exact Exists.elim (ih (S.complexity q)
      (by linarith [S.complexity_decreasing q p (Classical.not_not.mp hq)]) q rfl)
      fun q' hq' => ⟨q', hq'.1,
        by linarith [S.complexity_decreasing q p (Classical.not_not.mp hq)]⟩

/-! ## Chain Length Bounds -/

/-- The length of any refinement chain is bounded by the complexity
    of its first element. Since each step decreases complexity by at least 1,
    a chain starting at complexity c can have at most c steps. -/
theorem chain_length_bounded (S : ProofRefinementSystem)
    (ch : RefinementChain S) :
    ch.length ≤ S.complexity (ch.chain ⟨0, by omega⟩) := by
  have h_ind : ∀ i : Fin (ch.length + 1), i.val ≤ S.complexity (ch.chain (Fin.mk 0 (by
    exact Nat.succ_pos _))) - S.complexity (ch.chain i) := by
    intro i
    induction' i using Fin.induction with i ih
    generalize_proofs at *
    · norm_num
    · have h_complexity_lt : S.complexity (ch.chain i.succ) <
          S.complexity (ch.chain i.castSucc) := by
        exact S.complexity_decreasing _ _ (ch.chain_refines i)
      grind
  generalize_proofs at *
  exact le_trans (h_ind ⟨ch.length, Nat.lt_succ_self _⟩) (Nat.sub_le _ _)

/-! ## Optimizer Orbit Properties -/

/-- The complexity sequence along an optimizer orbit is non-increasing. -/
theorem optimizer_complexity_nonincreasing (S : ProofRefinementSystem)
    (O : ProofOptimizer S) (p : S.Proof) (n : ℕ) :
    O.complexitySeq p (n + 1) ≤ O.complexitySeq p n := by
  exact O.complexity_nonincreasing _

/-- The complexity sequence is bounded below by 0 (trivially for ℕ),
    and non-increasing, so it must eventually stabilize. This is the
    key lemma for the fixed-point theorem. -/
theorem complexity_seq_eventually_constant (S : ProofRefinementSystem)
    (O : ProofOptimizer S) (p : S.Proof) :
    ∃ N, ∀ n, N ≤ n → O.complexitySeq p n = O.complexitySeq p N := by
  have h_stabilize : ∀ (f : ℕ → ℕ), (∀ n, f (n + 1) ≤ f n) → ∃ N, ∀ n ≥ N, f n = f N := by
    intro f hf
    have h_monotone : Antitone f := antitone_nat_of_succ_le hf
    obtain ⟨L, hL⟩ : ∃ L, Filter.Tendsto f Filter.atTop (nhds L) :=
      ⟨_, tendsto_atTop_ciInf h_monotone ⟨0, Set.forall_mem_range.mpr fun n => Nat.zero_le _⟩⟩
    norm_num +zetaDelta at *
    exact ⟨hL.choose, fun n hn => by rw [hL.choose_spec n hn, hL.choose_spec _ le_rfl]⟩
  exact h_stabilize _ fun n => optimizer_complexity_nonincreasing S O p n

/-! ## Fixed-Point Theorem -/

/-- **Fixed-Point Theorem for Proof Optimizers**: Every proof optimizer
    on a refinement system has a complexity fixed point reachable from
    any starting proof. That is, iterating the optimizer from any proof p
    eventually reaches a proof q where f(q) has the same complexity as q.

    This is non-trivial because it works for ANY optimizer, not just
    "well-behaved" ones. The key insight is that a non-increasing
    ℕ-valued sequence must stabilize. -/
theorem optimizer_has_complexity_fixed_point (S : ProofRefinementSystem)
    (O : ProofOptimizer S) (p : S.Proof) :
    ∃ N, S.complexity (O.optimize (O.orbit p N)) = S.complexity (O.orbit p N) := by
  obtain ⟨N, hN⟩ := complexity_seq_eventually_constant S O p
  exact ⟨N, by simpa [ProofOptimizer.complexitySeq] using hN (N + 1) (Nat.le_succ _)⟩

/-! ## Strict Optimizer Convergence -/

/-
For a strict optimizer, the complexity strictly decreases at each step
    until a minimal proof is reached. Since complexity is ℕ-valued, this
    means the orbit reaches a minimal proof in at most `complexity p` steps.
-/
theorem strict_optimizer_reaches_minimal (S : ProofRefinementSystem)
    (O : StrictProofOptimizer S) (p : S.Proof) :
    ∃ N, N ≤ S.complexity p ∧ S.IsMinimal (O.orbit p N) := by
  by_contra! h_contra;
  -- By induction on $n$, we can show that for all $n \leq S.complexity p$, $S.complexity (O.orbit p n) \leq S.complexity p - n$.
  have h_ind : ∀ n ≤ S.complexity p, S.complexity (O.orbit p n) ≤ S.complexity p - n := by
    intro n hn; induction' n with n ih <;> simp_all +decide [ProofOptimizer.orbit] ;
    exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( O.strict_on_nonminimal _ ( h_contra _ hn.le ) ) ( ih hn.le ) );
  specialize h_ind ( S.complexity p ) le_rfl ; simp_all +decide [ ProofRefinementSystem.IsMinimal ];
  exact absurd ( h_contra _ le_rfl ) ( by rintro ⟨ q, hq ⟩ ; linarith [ S.complexity_decreasing _ _ hq ] )

/-! ## Chain Length with Minimum Gap -/

/-- If refinement always decreases complexity by at least g ≥ 1,
    then chains have length at most ⌊c/g⌋ where c is the starting complexity.
    This is a quantitative strengthening of chain_length_bounded. -/
theorem chain_length_gap_bound (S : ProofRefinementSystem)
    (g : ℕ) (hg : S.HasMinGap g) (ch : RefinementChain S) :
    ch.length * g ≤ S.complexity (ch.chain ⟨0, by omega⟩) := by
  have h_ind : ∀ i : Fin (ch.length + 1),
      S.complexity (ch.chain ⟨0, by omega⟩) ≥ S.complexity (ch.chain i) + i.val * g := by
    intro i
    induction' i using Fin.inductionOn with i IH
    · norm_num
    · have := hg.2 (ch.chain ⟨i.val + 1, by linarith [Fin.is_lt i]⟩)
        (ch.chain ⟨i.val, by linarith [Fin.is_lt i]⟩) (ch.chain_refines i)
      norm_num at *
      linarith! [Nat.sub_add_cancel (show S.complexity (ch.chain ⟨i, by linarith [Fin.is_lt i]⟩) ≥
        S.complexity (ch.chain ⟨i + 1, by linarith [Fin.is_lt i]⟩) from
        le_of_lt (S.complexity_decreasing _ _ (ch.chain_refines i)))]
  nlinarith [h_ind ⟨ch.length, Nat.lt_succ_self _⟩]

/-! ## Ordinal Well-Foundedness -/

/-- The refinement relation in an ordinal-valued system is also well-founded.
    This uses the well-foundedness of ordinals under <. -/
theorem ordinal_refinement_wellFounded (S : OrdinalProofRefinementSystem) :
    WellFounded S.refines := by
  exact ⟨fun p => by
    induction' h : S.complexity p using Ordinal.induction with α ih generalizing p
    refine' ⟨_, fun q hq => _⟩
    exact ih _ (h ▸ S.complexity_decreasing _ _ hq) _ rfl⟩

/-- Minimal proofs exist in ordinal-valued systems too. -/
theorem ordinal_exists_minimal (S : OrdinalProofRefinementSystem) (p : S.Proof) :
    ∃ q, S.IsMinimal q ∧ S.complexity q ≤ S.complexity p := by
  have h_well_founded : WellFounded S.refines := ordinal_refinement_wellFounded S
  obtain ⟨q, hq⟩ := h_well_founded.has_min {q | S.complexity q ≤ S.complexity p} ⟨p, by aesop⟩
  exact ⟨q, fun x hx => hq.2 x (le_trans (le_of_lt (S.complexity_decreasing x q hx)) hq.1) hx,
    hq.1⟩

/-! ## Composition of Optimizers -/

/-- The composition of two proof optimizers is again a proof optimizer. -/
def ProofOptimizer.comp (O₁ O₂ : ProofOptimizer S) : ProofOptimizer S where
  optimize := O₁.optimize ∘ O₂.optimize
  complexity_nonincreasing := fun _ => le_trans (O₁.complexity_nonincreasing _) (O₂.complexity_nonincreasing _)

/-- Composing an optimizer with itself n times. -/
def ProofOptimizer.power (O : ProofOptimizer S) : ℕ → ProofOptimizer S
  | 0 => ⟨id, fun _ => le_refl _⟩
  | n + 1 => O.comp (O.power n)

attribute [simp] ProofOptimizer.power

/-- The orbit of p under O agrees with iterated application of optimize. -/
theorem orbit_eq_iterate (O : ProofOptimizer S) (p : S.Proof) (n : ℕ) :
    O.orbit p n = O.optimize^[n] p := by
  induction' n with n ih
  · rfl
  · rw [Function.iterate_succ_apply', ← ih, ProofOptimizer.orbit]