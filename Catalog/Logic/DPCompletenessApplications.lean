/-
# Applications and specialisations of the DP completeness theorem

Building on `Logic.DPCompleteness` and `Logic.DPCompletenessWalks` this file records three
consequences of the general theory.

1. **Order duality (min-plus / shortest paths).**  Replacing the weight order by its dual turns
   the "greatest score" completeness theorem into a *minimality* theorem: every labelling
   *dominates* some dual DP run.  This is the Bellman–Ford shortest-path statement, obtained
   for free from the max-plus one.
2. **Closed form for stage-independent weights.**  When all transitions carry the same weight
   `c`, the value function collapses to `sup init + n • c`.
3. **A fully explicit three-state integer instance**, where the abstract value function is
   checked, inside Lean's kernel, against a brute-force enumeration of *all* labellings.
   This is a machine-checked instance of the completeness/exactness theorem.
-/

import Logic.DPCompletenessWalks

namespace Logic.DPCompleteness

namespace DPSpec

/-! ## Order duality: minimising runs -/

section Dual

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W]
  [IsOrderedCancelAddMonoid W]

/-- The same DP data, read in the order-dual weight monoid.  Maximisation becomes
minimisation. -/
def dual (D : DPSpec S W) : DPSpec S Wᵒᵈ := ⟨D.init, D.step⟩

omit [Fintype S] [Nonempty S] [LinearOrder W] [IsOrderedCancelAddMonoid W] in
@[simp] theorem dual_score (D : DPSpec S W) (f : ℕ → S) (n : ℕ) :
    D.dual.score f n = D.score f n := rfl

/-- **Dual completeness (shortest paths).** Every labelling dominates — i.e. scores at least
as much as — some run of the dual dynamic program, and that run is a genuine DP run for the
dual specification. -/
theorem dp_complete_min (D : DPSpec S W) (n : ℕ) (f : ℕ → S) :
    ∃ g : ℕ → S, D.dual.IsDPRun n g ∧ D.score g n ≤ D.score f n := by
  obtain ⟨g, hg, hle⟩ := D.dual.dp_complete n f
  exact ⟨g, hg, hle⟩

/-- **Uniform dual completeness.** A single run minimises the score over all labellings. -/
theorem dp_complete_min_uniform (D : DPSpec S W) (n : ℕ) :
    ∃ g : ℕ → S, D.dual.IsDPRun n g ∧ ∀ f : ℕ → S, D.score g n ≤ D.score f n := by
  obtain ⟨g, hg, hle⟩ := D.dual.dp_complete_uniform n
  exact ⟨g, hg, fun f => hle f⟩

/-- The dual value function is the *least* achievable score among labellings ending at `s`. -/
theorem isLeast_dual_val (D : DPSpec S W) (n : ℕ) (s : S) :
    IsLeast {w | ∃ f : ℕ → S, f n = s ∧ D.score f n = w} (D.dual.val n s) :=
  D.dual.isGreatest_val n s

end Dual

/-! ## Stage-independent weights -/

section Const

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- If every transition carries the same weight `c`, the value function is
`sup init + (n+1) • c` from stage `1` on. -/
theorem val_const_step (D : DPSpec S W) (c : W) (h : ∀ i s t, D.step i s t = c) :
    ∀ (n : ℕ) (t : S),
      D.val (n + 1) t =
        (Finset.univ : Finset S).sup' Finset.univ_nonempty D.init + (n + 1) • c := by
  intro n
  induction n with
  | zero =>
      intro t
      have hc : (0 + 1) • c = c := by simp
      rw [val_succ]
      simp only [val_zero, h]
      rw [sup'_add, hc]
  | succ n ih =>
      intro t
      have hc : (n + 1 + 1) • c = (n + 1) • c + c := succ_nsmul c (n + 1)
      rw [val_succ]
      simp only [ih, h]
      rw [Finset.sup'_const, hc, add_assoc]

end Const

/-! ## An explicit three-state integer instance -/

section Example

/-- The transition weight matrix of the running example. -/
def exA : Fin 3 → Fin 3 → ℤ
  | 0, 0 =>  2 | 0, 1 => -1 | 0, 2 =>  3
  | 1, 0 =>  1 | 1, 1 =>  0 | 1, 2 => -2
  | 2, 0 => -3 | 2, 1 =>  4 | 2, 2 =>  1

/-- A concrete stage-independent DP specification on three states with integer weights. -/
def exD : DPSpec (Fin 3) ℤ := ⟨fun s => (s : ℤ), fun _ s t => exA s t⟩

/-- All labellings of stages `0 … n`, as lists of length `n + 1`. -/
def exLabellings : ℕ → List (List (Fin 3))
  | 0 => (List.finRange 3).map (fun s => [s])
  | (n + 1) => (exLabellings n).flatMap (fun p => (List.finRange 3).map (fun s => p ++ [s]))

/-- Accumulate the score of a labelling presented as a list. -/
def exListScoreAux (k : ℕ) (prev : Fin 3) (acc : ℤ) : List (Fin 3) → ℤ
  | [] => acc
  | s :: r => exListScoreAux (k + 1) s (acc + exD.step k prev s) r

/-- The score of a labelling presented as a list. -/
def exListScore : List (Fin 3) → ℤ
  | [] => 0
  | s :: r => exListScoreAux 0 s (exD.init s) r

/-- Brute-force optimum over *all* labellings of stages `0 … n` ending in state `t`. -/
def exBrute (n : ℕ) (t : Fin 3) : ℤ :=
  ((exLabellings n).filter (fun p => p.getLast? = some t)).foldl
    (fun a p => max a (exListScore p)) (-1000)

set_option maxRecDepth 40000 in
/-- Kernel-checked instance of exactness: for every horizon up to `3` and every endpoint, the
value computed by the dynamic program agrees with the brute-force maximum over all `3^(n+1)`
labellings. -/
theorem exBrute_eq_val : ∀ n ∈ [0, 1, 2, 3], ∀ t : Fin 3, exBrute n t = exD.val n t := by
  decide

/-- The concrete optimal values at the first few horizons. -/
theorem exD_values :
    (exD.val 0 0, exD.val 0 1, exD.val 0 2) = (0, 1, 2) ∧
    (exD.val 1 0, exD.val 1 1, exD.val 1 2) = (2, 6, 3) ∧
    (exD.val 2 0, exD.val 2 1, exD.val 2 2) = (7, 7, 5) ∧
    (exD.val 3 0, exD.val 3 1, exD.val 3 2) = (9, 9, 10) := by
  refine ⟨by decide, by decide, by decide, by decide⟩

/-- Kernel-checked instance of the `val_add` transfer identity of `Logic.DPCompletenessWalks`
at `k = 1`, `m = 2`: `val 4 = val 1 ⊗ walk 1 2` in the max-plus sense. -/
theorem exD_val_add :
    ∀ t : Fin 3,
      exD.val 4 t =
        (Finset.univ : Finset (Fin 3)).sup' Finset.univ_nonempty
          (fun s => exD.val 1 s + exD.walk 1 2 s t) := by
  decide

end Example

end DPSpec

end Logic.DPCompleteness