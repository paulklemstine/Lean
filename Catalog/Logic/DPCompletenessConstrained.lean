/-
# Completeness without cancellativity, and constrained dynamic programming

In `Logic.DPCompleteness` the notion `IsDPRun` was *semantic* (all prefix scores are optimal)
and the existence of runs was proved using cancellativity of the weight monoid.  This file
removes that hypothesis by working with the *structural* (backtrace) notion of a run:

> `IsBacktrace D n f` : at each stage the DP recursion is realised on the nose,
> `val i (f i) + step i (f i) (f (i+1)) = val (i+1) (f (i+1))`.

The two notions turn out to be equivalent for **every** ordered weight monoid
(`isBacktrace_iff_isDPRun`), and completeness holds with no cancellativity assumption
(`dp_complete_general`).  This is exactly what is needed to cover **constrained** dynamic
programming, where infeasible transitions carry the absorbing weight `⊥` of `WithBot W` — a
monoid that is emphatically *not* cancellative.

As an application we characterise infeasibility (`val_eq_bot_iff`) and instantiate the theory on
the classical maximum-weight independent set problem on a path.
-/

import Logic.DPCompleteness

namespace Logic.DPCompleteness

namespace DPSpec

/-! ## Structural runs -/

section General

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- A *backtrace* run: at every stage the DP recursion is realised exactly. -/
def IsBacktrace (D : DPSpec S W) (n : ℕ) (f : ℕ → S) : Prop :=
  ∀ i < n, D.val i (f i) + D.step i (f i) (f (i + 1)) = D.val (i + 1) (f (i + 1))

omit [AddLeftMono W] in
/-- A backtrace is score-optimal at every prefix.  No cancellativity is needed. -/
theorem IsBacktrace.score_eq_val {D : DPSpec S W} {n : ℕ} {f : ℕ → S} (h : D.IsBacktrace n f) :
    ∀ i ≤ n, D.score f i = D.val i (f i) := by
  intro i
  induction i with
  | zero => intro _; rfl
  | succ i ih =>
      intro hi
      have hle : i ≤ n := Nat.le_of_succ_le hi
      rw [score_succ, ih hle]
      exact h i (Nat.lt_of_lt_of_le (Nat.lt_succ_self i) hi)

omit [AddLeftMono W] in
/-- **The structural and the semantic notion of a DP run agree**, over an arbitrary ordered
weight monoid. -/
theorem isBacktrace_iff_isDPRun (D : DPSpec S W) (n : ℕ) (f : ℕ → S) :
    D.IsBacktrace n f ↔ D.IsDPRun n f := by
  constructor
  · intro h; exact h.score_eq_val
  · intro h i hi
    have h1 : D.score f i = D.val i (f i) := h i (Nat.le_of_lt hi)
    have h2 : D.score f (i + 1) = D.val (i + 1) (f (i + 1)) := h (i + 1) hi
    rw [score_succ, h1] at h2
    exact h2

omit [AddLeftMono W] in
/-- **Realisability without cancellativity.** Every DP value is attained by a backtrace. -/
theorem exists_backtrace_ending (D : DPSpec S W) :
    ∀ (n : ℕ) (s : S), ∃ f : ℕ → S, f n = s ∧ D.IsBacktrace n f := by
  intro n
  induction n with
  | zero => intro s; exact ⟨fun _ => s, rfl, by intro i hi; omega⟩
  | succ n ih =>
      intro t
      obtain ⟨s, -, hs⟩ :=
        Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := S))
          (fun s => D.val n s + D.step n s t)
      obtain ⟨f, hfn, hf⟩ := ih s
      set g : ℕ → S := fun i => if i ≤ n then f i else t with hgdef
      have hgn : g n = f n := by simp [hgdef]
      have hgn1 : g (n + 1) = t := by simp [hgdef]
      refine ⟨g, hgn1, ?_⟩
      intro i hi
      rcases Nat.lt_or_ge i n with hlt | hge
      · have e1 : g i = f i := by simp [hgdef, Nat.le_of_lt hlt]
        have e2 : g (i + 1) = f (i + 1) := by simp [hgdef, hlt]
        rw [e1, e2]
        exact hf i hlt
      · have hin : i = n := le_antisymm (Nat.lt_succ_iff.mp hi) hge
        subst hin
        rw [hgn, hgn1, hfn, val_succ, hs]

/-- **Completeness without cancellativity.** Every labelling is dominated by some backtrace
run of the dynamic program. -/
theorem dp_complete_general (D : DPSpec S W) (n : ℕ) (f : ℕ → S) :
    ∃ g : ℕ → S, D.IsBacktrace n g ∧ D.score f n ≤ D.score g n := by
  obtain ⟨g, hgn, hg⟩ := D.exists_backtrace_ending n (f n)
  refine ⟨g, hg, ?_⟩
  rw [hg.score_eq_val n le_rfl, hgn]
  exact D.score_le_val f n

/-- **Uniform completeness without cancellativity.** -/
theorem dp_complete_general_uniform (D : DPSpec S W) (n : ℕ) :
    ∃ g : ℕ → S, D.IsBacktrace n g ∧ ∀ f : ℕ → S, D.score f n ≤ D.score g n := by
  obtain ⟨s, -, hs⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := S)) (fun s => D.val n s)
  obtain ⟨g, hgn, hg⟩ := D.exists_backtrace_ending n s
  refine ⟨g, hg, fun f => ?_⟩
  rw [hg.score_eq_val n le_rfl, hgn]
  refine le_trans (D.score_le_val f n) ?_
  rw [← hs]
  exact Finset.le_sup' (fun s => D.val n s) (Finset.mem_univ (f n))

/-- **Exactness without cancellativity.** -/
theorem isGreatest_val_general (D : DPSpec S W) (n : ℕ) (s : S) :
    IsGreatest {w | ∃ f : ℕ → S, f n = s ∧ D.score f n = w} (D.val n s) := by
  constructor
  · obtain ⟨f, hfn, hf⟩ := D.exists_backtrace_ending n s
    exact ⟨f, hfn, by rw [hf.score_eq_val n le_rfl, hfn]⟩
  · rintro w ⟨f, hfn, rfl⟩
    have := D.score_le_val f n
    rwa [hfn] at this

end General

/-! ## Constrained dynamic programming over `WithBot` -/

section Constrained

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

omit [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W] in
/-- A labelling is infeasible exactly when it uses an infeasible ingredient. -/
theorem score_eq_bot_iff (D : DPSpec S (WithBot W)) (f : ℕ → S) :
    ∀ n : ℕ, D.score f n = ⊥ ↔
      (D.init (f 0) = ⊥ ∨ ∃ i < n, D.step i (f i) (f (i + 1)) = ⊥) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [score_succ, WithBot.add_eq_bot, ih]
      constructor
      · rintro (h | h)
        · rcases h with h | ⟨i, hi, h⟩
          · exact Or.inl h
          · exact Or.inr ⟨i, by omega, h⟩
        · exact Or.inr ⟨n, by omega, h⟩
      · rintro (h | ⟨i, hi, h⟩)
        · exact Or.inl (Or.inl h)
        · rcases Nat.lt_or_ge i n with hlt | hge
          · exact Or.inl (Or.inr ⟨i, hlt, h⟩)
          · have : i = n := by omega
            subst this
            exact Or.inr h

/-- **Characterisation of infeasibility.** The DP reports `⊥` at `(n, s)` precisely when *no*
labelling ending at `s` is feasible.  This is the completeness theorem in contrapositive
form. -/
theorem val_eq_bot_iff (D : DPSpec S (WithBot W)) (n : ℕ) (s : S) :
    D.val n s = ⊥ ↔ ∀ f : ℕ → S, f n = s → D.score f n = ⊥ := by
  obtain ⟨hmem, hub⟩ := D.isGreatest_val_general n s
  constructor
  · intro h f hf
    have := hub ⟨f, hf, rfl⟩
    rw [h] at this
    exact le_bot_iff.mp this
  · intro h
    obtain ⟨f, hf, hfv⟩ := hmem
    rw [← hfv, h f hf]

end Constrained

/-! ## Application: maximum-weight independent set on a path -/

section MWIS

/-- Vertex weights of the running example: a path on stages `0,1,2,3,4`. -/
def misW : ℕ → ℤ
  | 0 => 3
  | 1 => 7
  | 2 => 2
  | 3 => 8
  | 4 => 1
  | _ => 0

/-- The maximum-weight-independent-set specification on a path.  The state at stage `i` records
whether vertex `i` is selected; selecting two adjacent vertices is forbidden, which is encoded
by the absorbing weight `⊥`. -/
def misD : DPSpec Bool (WithBot ℤ) where
  init b := if b then (misW 0 : WithBot ℤ) else (0 : WithBot ℤ)
  step i b c := if b && c then ⊥ else if c then (misW (i + 1) : WithBot ℤ) else (0 : WithBot ℤ)

/-- The DP optimum of the maximum-weight independent set on the path with weights
`3, 7, 2, 8, 1`: the best independent set is `{1, 3}` of weight `15`. -/
theorem misD_optimum :
    max (misD.val 4 true) (misD.val 4 false) = ((15 : ℤ) : WithBot ℤ) := by
  decide

/-- Adjacent selection really is infeasible: any labelling selecting two consecutive vertices
scores `⊥`. -/
theorem misD_adjacent_infeasible (f : ℕ → Bool) (n i : ℕ) (hi : i < n)
    (h : f i = true) (h' : f (i + 1) = true) : misD.score f n = ⊥ := by
  rw [score_eq_bot_iff]
  exact Or.inr ⟨i, hi, by simp [misD, h, h']⟩

end MWIS

end DPSpec

end Logic.DPCompleteness