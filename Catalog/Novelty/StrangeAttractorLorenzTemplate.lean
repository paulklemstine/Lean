import Novelty.StrangeAttractorZeta
import Novelty.StrangeAttractorTopology
import Novelty.StrangeAttractorsAlgebraic

/-!
# Strange attractors as algebraic objects, V: the Lorenz template and its algebra

The geometric Lorenz attractor collapses along its stable direction onto a branched surface
(the *Lorenz template*), whose first-return dynamics is the full shift on two symbols `L`,
`R`: the two branches of the template, with all four transitions admissible.  Its transverse
structure is therefore the inverse limit of the two-vertex complete directed graph.

This file instantiates the general theory at that graph (`lorenzTemplate`) and at a *pruned*
template (`prunedTemplate`) in which the transition `R → R` is forbidden — the model of a
Lorenz-like attractor whose kneading data removes one branch return.  We prove:

* `lorenzPathSpaceHomeomorph` : the Lorenz template attractor is homeomorphic to Cantor space;
* `card_finPath_lorenz`, `trace_adjMatrix_lorenz` : the finite approximants have `2 ^ (n+1)`
  elements and the transfer matrix has power traces `2 ^ n` (so the topological entropy is
  `log 2` and the zeta function is `1 / (1 - 2t)`);
* `trace_adjMatrix_pruned` : for the pruned template the power traces are Lucas numbers
  `fib (n+2) + fib n`, and the approximants are counted by Fibonacci numbers;
* `lorenz_not_conjugate_pruned` : the two attractors are **not** topologically conjugate —
  a purely algebraic separation of two chaotic attractors, obtained from the trace of the
  square of the transfer matrix (`4 ≠ 3`);
* `prefixLimit_equiv_lorenz` : the de Bruijn inverse limit of the previous cycle
  (`Novelty.StrangeAttractorsAlgebraic`) is exactly the Lorenz template attractor, and
  `streamToLimit_bijective` upgrades that cycle's injectivity result to a bijection.
-/

namespace LorenzLimit

/-! ## The two templates -/

/-- The first-return graph of the Lorenz template: two branches, all transitions allowed. -/
def lorenzTemplate : Bool → Bool → Bool := fun _ _ => true

/-- A pruned Lorenz-type template: the transition `true → true` is forbidden. -/
def prunedTemplate : Bool → Bool → Bool := fun u v => !(u && v)

theorem branching_lorenzTemplate : Branching lorenzTemplate :=
  fun _ => ⟨false, true, by simp, rfl, rfl⟩

theorem branching_prunedTemplate_false :
    ∃ u u' : Bool, u ≠ u' ∧ prunedTemplate false u = true ∧ prunedTemplate false u' = true :=
  ⟨false, true, by simp, rfl, rfl⟩

theorem noDeadEnds_prunedTemplate : NoDeadEnds prunedTemplate := by
  intro v
  exact ⟨false, by cases v <;> rfl⟩

/-! ## The Lorenz template attractor is Cantor space -/

/-- Every binary stream is an orbit of the Lorenz template, and conversely. -/
def lorenzPathEquiv : PathSpace lorenzTemplate ≃ (ℕ → Bool) where
  toFun x := x.1
  invFun b := ⟨b, fun _ => rfl⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **The Lorenz template attractor is homeomorphic to the Cantor set.** -/
def lorenzPathSpaceHomeomorph : PathSpace lorenzTemplate ≃ₜ (ℕ → Bool) where
  toEquiv := lorenzPathEquiv
  continuous_toFun := continuous_subtype_val
  continuous_invFun := Continuous.subtype_mk continuous_id _

/-- The inverse limit of the finite Lorenz-template path diagram is Cantor space. -/
def lorenzInvLimitEquiv : InvLimit lorenzTemplate ≃ (ℕ → Bool) :=
  invLimitEquiv.symm.trans lorenzPathEquiv

/-! ## Counting: transfer matrices, entropy and the zeta function -/

/-- Finite Lorenz-template paths with `n` edges are exactly the binary words of length
`n + 1`. -/
def finPathLorenzEquiv (n : ℕ) : FinPath lorenzTemplate n ≃ (Fin (n + 1) → Bool) where
  toFun w := w.1
  invFun w := ⟨w, fun _ => rfl⟩
  left_inv _ := rfl
  right_inv _ := rfl

theorem card_finPath_lorenz (n : ℕ) :
    Fintype.card (FinPath lorenzTemplate n) = 2 ^ (n + 1) := by
  rw [Fintype.card_congr (finPathLorenzEquiv n)]
  simp

/-- All entries of the powers of the Lorenz transfer matrix are powers of two. -/
theorem adjMatrix_lorenz_pow (n : ℕ) (i j : Bool) :
    (adjMatrix lorenzTemplate ^ (n + 1)) i j = 2 ^ n := by
  induction n generalizing j with
  | zero => simp [adjMatrix, lorenzTemplate]
  | succ n ih =>
      rw [pow_succ, Matrix.mul_apply, Fintype.sum_bool, ih true, ih false]
      simp [adjMatrix, lorenzTemplate, pow_succ]
      ring

/-- **Entropy of the Lorenz template.**  The transfer matrix has power traces `2 ^ n`; the
number of periodic points of period `n` grows like `2 ^ n`, i.e. the topological entropy of
the template shift is `log 2`. -/
theorem trace_adjMatrix_lorenz (n : ℕ) :
    Matrix.trace (adjMatrix lorenzTemplate ^ (n + 1)) = 2 ^ (n + 1) := by
  rw [Matrix.trace, Fintype.sum_bool]
  simp only [Matrix.diag_apply, adjMatrix_lorenz_pow]
  ring

theorem card_closedWalk_lorenz (n : ℕ) :
    Fintype.card (ClosedWalk lorenzTemplate (n + 1)) = 2 ^ (n + 1) := by
  rw [card_closedWalk_eq_trace, trace_adjMatrix_lorenz]

/-! ### The pruned template: Fibonacci and Lucas numbers -/

theorem adj_pruned_ff : adjMatrix prunedTemplate false false = 1 := by
  simp [adjMatrix, prunedTemplate]

theorem adj_pruned_ft : adjMatrix prunedTemplate false true = 1 := by
  simp [adjMatrix, prunedTemplate]

theorem adj_pruned_tf : adjMatrix prunedTemplate true false = 1 := by
  simp [adjMatrix, prunedTemplate]

theorem adj_pruned_tt : adjMatrix prunedTemplate true true = 0 := by
  simp [adjMatrix, prunedTemplate]

/-- The powers of the pruned transfer matrix are the Fibonacci matrices. -/
theorem adjMatrix_pruned_pow (n : ℕ) :
    (adjMatrix prunedTemplate ^ (n + 1)) false false = Nat.fib (n + 2) ∧
    (adjMatrix prunedTemplate ^ (n + 1)) false true = Nat.fib (n + 1) ∧
    (adjMatrix prunedTemplate ^ (n + 1)) true false = Nat.fib (n + 1) ∧
    (adjMatrix prunedTemplate ^ (n + 1)) true true = Nat.fib n := by
  induction n with
  | zero => refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [adjMatrix, prunedTemplate]
  | succ n ih =>
      obtain ⟨h1, h2, h3, h4⟩ := ih
      have e2 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := Nat.fib_add_two
      simp only [show n + 1 + 1 = n + 2 from rfl, show n + 1 + 2 = n + 3 from rfl]
      refine ⟨?_, ?_, ?_, ?_⟩
      · rw [pow_succ, Matrix.mul_apply, Fintype.sum_bool, h1, h2, adj_pruned_ff, adj_pruned_tf]
        omega
      · rw [pow_succ, Matrix.mul_apply, Fintype.sum_bool, h1, h2, adj_pruned_ft, adj_pruned_tt]
        omega
      · rw [pow_succ, Matrix.mul_apply, Fintype.sum_bool, h3, h4, adj_pruned_ff, adj_pruned_tf]
        have : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
        omega
      · rw [pow_succ, Matrix.mul_apply, Fintype.sum_bool, h3, h4, adj_pruned_ft, adj_pruned_tt]
        omega

/-- **The pruned template has Lucas-number periodic-orbit counts.**  The trace of the `n`-th
power of its transfer matrix is `fib (n+1) + fib (n-1)`, the `n`-th Lucas number. -/
theorem trace_adjMatrix_pruned (n : ℕ) :
    Matrix.trace (adjMatrix prunedTemplate ^ (n + 1)) = Nat.fib (n + 2) + Nat.fib n := by
  obtain ⟨h1, _, _, h4⟩ := adjMatrix_pruned_pow n
  rw [Matrix.trace, Fintype.sum_bool]
  simp only [Matrix.diag_apply, h1, h4]
  ring

/-- The finite approximants of the pruned template are counted by Fibonacci numbers: there
are `fib (n + 3)` admissible words of length `n + 1`. -/
theorem card_finPath_pruned (n : ℕ) :
    Fintype.card (FinPath prunedTemplate (n + 1)) = Nat.fib (n + 4) := by
  obtain ⟨h1, h2, h3, h4⟩ := adjMatrix_pruned_pow n
  rw [card_finPath_eq_sum, Fintype.sum_bool, Fintype.sum_bool, Fintype.sum_bool]
  simp only [h1, h2, h3, h4]
  have e1 : Nat.fib (n + 4) = Nat.fib (n + 2) + Nat.fib (n + 3) := Nat.fib_add_two
  have e2 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := Nat.fib_add_two
  have e3 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
  omega

/-! ## Algebraic separation of the two attractors -/

/-- **The Lorenz template attractor is not conjugate to the pruned one.**  Their transfer
matrices have different power traces (`4` versus `3` at `n = 2`), so no shift-commuting
bijection of the two inverse limits can exist.  Chaotic attractors are thereby separated by
a purely algebraic invariant. -/
theorem lorenz_not_conjugate_pruned : ¬ IsConjugate lorenzTemplate prunedTemplate := by
  intro hconj
  have h := trace_pow_eq_of_conjugate hconj (n := 2) (by norm_num)
  rw [show (2 : ℕ) = 1 + 1 from rfl, trace_adjMatrix_lorenz 1, trace_adjMatrix_pruned 1] at h
  norm_num at h

theorem fib_lt_two_pow (n : ℕ) : Nat.fib (n + 4) < 2 ^ (n + 2) := by
  induction n with
  | zero => norm_num [Nat.fib]
  | succ n ih =>
      have e1 : Nat.fib (n + 1 + 4) = Nat.fib (n + 3) + Nat.fib (n + 4) := by
        have h : n + 1 + 4 = (n + 3) + 2 := by ring
        rw [h, Nat.fib_add_two]
      have hmono : Nat.fib (n + 3) ≤ Nat.fib (n + 4) := Nat.fib_le_fib_succ
      have e2 : (2 : ℕ) ^ (n + 1 + 2) = 2 ^ (n + 2) + 2 ^ (n + 2) := by ring
      omega

/-- The Lorenz template strictly dominates the pruned template in complexity: it has more
paths of every positive length, hence strictly larger topological entropy. -/
theorem card_finPath_lorenz_gt_pruned (n : ℕ) :
    Fintype.card (FinPath prunedTemplate (n + 1))
      < Fintype.card (FinPath lorenzTemplate (n + 1)) := by
  rw [card_finPath_pruned, card_finPath_lorenz]
  exact fib_lt_two_pow n

/-! ## Bridge to the previous cycle: de Bruijn prefix limits -/

open StrangeAttractorsAlgebraic in
/-- Coherence for the de Bruijn prefix limit of the previous cycle. -/
theorem prefix_coherent (x : ∀ n, Word n) (hx : ∀ n, truncate n (x (n + 1)) = x n) :
    ∀ n (i : Fin n), x n i = x (i.val + 1) ⟨i.val, Nat.lt_succ_self i.val⟩ := by
  intro n
  induction n with
  | zero => intro i; exact absurd i.isLt (by omega)
  | succ n ih =>
      intro i
      rcases lt_or_ge i.val n with hlt | hge
      · have h := congrFun (hx n) ⟨i.val, hlt⟩
        simp only [truncate] at h
        have hcast : (⟨(⟨i.val, hlt⟩ : Fin n).val, Nat.lt_succ_of_lt (⟨i.val, hlt⟩ : Fin n).isLt⟩
            : Fin (n + 1)) = i := Fin.ext rfl
        rw [hcast] at h
        rw [h]
        exact ih ⟨i.val, hlt⟩
      · have hi : i = Fin.last n :=
          Fin.ext (le_antisymm (Nat.lt_succ_iff.1 i.isLt) hge)
        rw [hi]
        rfl

open StrangeAttractorsAlgebraic in
/-- **The previous cycle's injection is a bijection.**  Every compatible thread of finite
binary prefixes comes from a unique infinite binary stream. -/
theorem streamToLimit_bijective : Function.Bijective StrangeAttractorsAlgebraic.streamToLimit := by
  refine ⟨streamToLimit_injective, ?_⟩
  rintro ⟨x, hx⟩
  refine ⟨fun i => x (i + 1) ⟨i, Nat.lt_succ_self i⟩, ?_⟩
  apply Subtype.ext
  funext n
  funext i
  exact (prefix_coherent x hx n i).symm

open StrangeAttractorsAlgebraic in
/-- The de Bruijn prefix inverse limit of the previous cycle **is** the Lorenz template
attractor. -/
noncomputable def prefixLimit_equiv_lorenz :
    StrangeAttractorsAlgebraic.PrefixLimit ≃ PathSpace lorenzTemplate :=
  (Equiv.ofBijective _ streamToLimit_bijective).symm.trans lorenzPathEquiv.symm

end LorenzLimit