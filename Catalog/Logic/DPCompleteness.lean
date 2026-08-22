/-
# Completeness of Dynamic Programming: every labelling is dominated by some DP run

This file develops, from scratch, a general theory of *layered dynamic programming*
(the Viterbi / Bellman shortest-path schema) over an arbitrary finite state space `S`
and an arbitrary linearly ordered cancellative additive monoid `W` of weights, and
proves the **completeness theorem**:

> every labelling `f : ℕ → S` is dominated by some DP run `g`, i.e. there is a `g`
> all of whose prefixes are DP-optimal and whose total score is at least that of `f`.

Together with the dual **soundness** statement (every DP run is an honest labelling whose
score is exactly the DP value) this gives an exactness theorem: the DP value function is
the greatest element of the set of achievable labelling scores.

We additionally prove
* the **Bellman optimality principle** (`IsDPRun` is inherited by every prefix of an
  end-optimal labelling),
* the **forward-backward decomposition** relating the forward value function to a
  backward value function at any intermediate stage,
* **monotonicity** of the value function in the specification.

Everything is stated for a general weight monoid, so it specialises simultaneously to
max-plus (longest path), min-plus (shortest path, by using the order dual), and
Viterbi-style probabilistic decoding.
-/

import Mathlib

namespace Logic.DPCompleteness

/-! ## Generic `sup'` lemmas -/

section SupLemmas

variable {ι W : Type*} [LinearOrder W] [AddCommMonoid W] [AddLeftMono W]

/-- Adding a constant on the right commutes with a finite `sup'`. -/
theorem sup'_add (s : Finset ι) (h : s.Nonempty) (f : ι → W) (c : W) :
    s.sup' h f + c = s.sup' h (fun i => f i + c) := by
  refine le_antisymm ?_ (Finset.sup'_le _ _ ?_)
  · obtain ⟨i, hi, he⟩ := Finset.exists_mem_eq_sup' h f
    rw [he]
    exact Finset.le_sup' (fun i => f i + c) hi
  · intro i hi
    exact add_le_add (Finset.le_sup' f hi) le_rfl

/-- Adding a constant on the left commutes with a finite `sup'`. -/
theorem add_sup' (s : Finset ι) (h : s.Nonempty) (f : ι → W) (c : W) :
    c + s.sup' h f = s.sup' h (fun i => c + f i) := by
  simp only [add_comm c]
  exact sup'_add s h f c

end SupLemmas

/-! ## The DP specification -/

/-- A layered dynamic-programming specification: an initial weight for each state and a
stage-dependent transition weight. -/
structure DPSpec (S W : Type*) where
  /-- weight of starting in a given state -/
  init : S → W
  /-- `step i s t` is the weight of moving from state `s` at stage `i` to state `t` at
  stage `i + 1`. -/
  step : ℕ → S → S → W

namespace DPSpec

variable {S W : Type*} [AddCommMonoid W]

/-- The total score of the labelling `f` truncated at stage `n`. -/
def score (D : DPSpec S W) (f : ℕ → S) : ℕ → W
  | 0 => D.init (f 0)
  | (n + 1) => D.score f n + D.step n (f n) (f (n + 1))

@[simp] theorem score_zero (D : DPSpec S W) (f : ℕ → S) : D.score f 0 = D.init (f 0) := rfl

@[simp] theorem score_succ (D : DPSpec S W) (f : ℕ → S) (n : ℕ) :
    D.score f (n + 1) = D.score f n + D.step n (f n) (f (n + 1)) := rfl

/-- The score at stage `n` only depends on the labelling up to stage `n`. -/
theorem score_congr (D : DPSpec S W) {f g : ℕ → S} :
    ∀ {n : ℕ}, (∀ i ≤ n, f i = g i) → D.score f n = D.score g n := by
  intro n
  induction n with
  | zero => intro h; simp [h 0 le_rfl]
  | succ n ih =>
      intro h
      rw [score_succ, score_succ, ih (fun i hi => h i (hi.trans (Nat.le_succ n))),
        h n (Nat.le_succ n), h (n + 1) le_rfl]

section Value

variable [Fintype S] [Nonempty S] [LinearOrder W]

/-- The forward DP value function: `val D n s` is the best score of a labelling of stages
`0 … n` that ends in state `s`. -/
def val (D : DPSpec S W) : ℕ → S → W
  | 0, s => D.init s
  | (n + 1), t =>
      (Finset.univ : Finset S).sup' Finset.univ_nonempty (fun s => D.val n s + D.step n s t)

@[simp] theorem val_zero (D : DPSpec S W) (s : S) : D.val 0 s = D.init s := rfl

theorem val_succ (D : DPSpec S W) (n : ℕ) (t : S) :
    D.val (n + 1) t =
      (Finset.univ : Finset S).sup' Finset.univ_nonempty (fun s => D.val n s + D.step n s t) :=
  rfl

variable [AddLeftMono W]

omit [AddLeftMono W] in
/-- One half of the Bellman equation: the DP value dominates every transition. -/
theorem le_val_succ (D : DPSpec S W) (n : ℕ) (s t : S) :
    D.val n s + D.step n s t ≤ D.val (n + 1) t := by
  rw [val_succ]
  exact Finset.le_sup' (fun s => D.val n s + D.step n s t) (Finset.mem_univ s)

/-- **Domination.** Every labelling scores at most the DP value at its endpoint. -/
theorem score_le_val (D : DPSpec S W) (f : ℕ → S) : ∀ n : ℕ, D.score f n ≤ D.val n (f n) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [score_succ]
      exact le_trans (add_le_add ih le_rfl) (le_val_succ D n (f n) (f (n + 1)))

/-! ## DP runs -/

/-- `IsDPRun D n f` says that the labelling `f` is a genuine run of the dynamic program up to
stage `n`: *every* prefix score is DP-optimal, i.e. `f` is produced by the DP recursion. -/
def IsDPRun (D : DPSpec S W) (n : ℕ) (f : ℕ → S) : Prop :=
  ∀ i ≤ n, D.score f i = D.val i (f i)

omit [AddLeftMono W] in
theorem IsDPRun.mono {D : DPSpec S W} {n m : ℕ} {f : ℕ → S} (h : D.IsDPRun n f) (hm : m ≤ n) :
    D.IsDPRun m f := fun i hi => h i (hi.trans hm)

omit [AddLeftMono W] in
/-- **Soundness.** A DP run is an honest labelling realising the DP value at its endpoint. -/
theorem IsDPRun.score_eq_val {D : DPSpec S W} {n : ℕ} {f : ℕ → S} (h : D.IsDPRun n f) :
    D.score f n = D.val n (f n) := h n le_rfl

end Value

section Cancel

variable [Fintype S] [Nonempty S] [LinearOrder W] [IsOrderedCancelAddMonoid W]

/-- **Bellman's optimality principle.** If a labelling is optimal at its endpoint, then all of
its prefixes are optimal as well — hence it *is* a DP run. -/
theorem isDPRun_of_score_eq_val (D : DPSpec S W) (f : ℕ → S) :
    ∀ {n : ℕ}, D.score f n = D.val n (f n) → D.IsDPRun n f := by
  intro n
  induction n with
  | zero => intro _ i hi; interval_cases i; rfl
  | succ n ih =>
      intro h
      have hstep : D.score f n = D.val n (f n) := by
        refine le_antisymm (D.score_le_val f n) ?_
        by_contra hlt
        push_neg at hlt
        have : D.score f n + D.step n (f n) (f (n + 1)) <
            D.val n (f n) + D.step n (f n) (f (n + 1)) :=
          add_lt_add_of_lt_of_le hlt le_rfl
        have h2 := lt_of_lt_of_le this (D.le_val_succ n (f n) (f (n + 1)))
        rw [← score_succ] at h2
        exact absurd h h2.ne
      intro i hi
      rcases Nat.lt_or_ge i (n + 1) with hlt | hge
      · exact ih hstep i (Nat.lt_succ_iff.mp hlt)
      · have : i = n + 1 := le_antisymm hi hge
        subst this; exact h

end Cancel

/-! ## Existence of DP runs -/

section Existence

variable [Fintype S] [Nonempty S] [LinearOrder W] [IsOrderedCancelAddMonoid W]

/-- **Realisability.** Every DP value is attained by an actual labelling, which is moreover a
DP run. -/
theorem exists_dpRun_ending (D : DPSpec S W) :
    ∀ (n : ℕ) (s : S), ∃ f : ℕ → S, f n = s ∧ D.IsDPRun n f := by
  intro n
  induction n with
  | zero =>
      intro s
      exact ⟨fun _ => s, rfl, by intro i hi; interval_cases i; rfl⟩
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
      apply D.isDPRun_of_score_eq_val
      have hpref : D.score g n = D.score f n := D.score_congr (fun i hi => by simp [hgdef, hi])
      rw [score_succ, hpref, hf.score_eq_val, hgn, hgn1, hfn, val_succ, hs]

/-- The DP value is the *greatest* achievable score among labellings ending at `s`. -/
theorem isGreatest_val (D : DPSpec S W) (n : ℕ) (s : S) :
    IsGreatest {w | ∃ f : ℕ → S, f n = s ∧ D.score f n = w} (D.val n s) := by
  constructor
  · obtain ⟨f, hfn, hf⟩ := D.exists_dpRun_ending n s
    exact ⟨f, hfn, by rw [hf.score_eq_val, hfn]⟩
  · rintro w ⟨f, hfn, rfl⟩
    have := D.score_le_val f n
    rwa [hfn] at this

/-- **Completeness (pointwise form).** Every labelling `f` is dominated by some DP run `g`. -/
theorem dp_complete (D : DPSpec S W) (n : ℕ) (f : ℕ → S) :
    ∃ g : ℕ → S, D.IsDPRun n g ∧ D.score f n ≤ D.score g n := by
  obtain ⟨g, hgn, hg⟩ := D.exists_dpRun_ending n (f n)
  refine ⟨g, hg, ?_⟩
  rw [hg.score_eq_val, hgn]
  exact D.score_le_val f n

/-- **Completeness (uniform form).** There is a *single* DP run dominating every labelling. -/
theorem dp_complete_uniform (D : DPSpec S W) (n : ℕ) :
    ∃ g : ℕ → S, D.IsDPRun n g ∧ ∀ f : ℕ → S, D.score f n ≤ D.score g n := by
  obtain ⟨s, -, hs⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := S)) (fun s => D.val n s)
  obtain ⟨g, hgn, hg⟩ := D.exists_dpRun_ending n s
  refine ⟨g, hg, fun f => ?_⟩
  rw [hg.score_eq_val, hgn]
  refine le_trans (D.score_le_val f n) ?_
  rw [← hs]
  exact Finset.le_sup' (fun s => D.val n s) (Finset.mem_univ (f n))

/-- **Characterisation of DP runs.** A labelling is a DP run exactly when it is optimal among
all labellings with the same endpoint. This is the sharp form of soundness + completeness:
the syntactic notion (produced by the DP recursion) and the semantic notion (optimal) coincide. -/
theorem isDPRun_iff (D : DPSpec S W) (n : ℕ) (f : ℕ → S) :
    D.IsDPRun n f ↔ ∀ g : ℕ → S, g n = f n → D.score g n ≤ D.score f n := by
  constructor
  · intro h g hg
    rw [h.score_eq_val, ← hg]
    exact D.score_le_val g n
  · intro h
    apply D.isDPRun_of_score_eq_val
    refine le_antisymm (D.score_le_val f n) ?_
    obtain ⟨g, hgn, hg⟩ := D.exists_dpRun_ending n (f n)
    calc D.val n (f n) = D.score g n := by rw [hg.score_eq_val, hgn]
      _ ≤ D.score f n := h g hgn

/-- **Exactness.** Combining soundness and completeness: the maximal DP value at stage `n` is
the greatest score of any labelling. -/
theorem isGreatest_max_val (D : DPSpec S W) (n : ℕ) :
    IsGreatest {w | ∃ f : ℕ → S, D.score f n = w}
      ((Finset.univ : Finset S).sup' Finset.univ_nonempty (fun s => D.val n s)) := by
  obtain ⟨s, -, hs⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := S)) (fun s => D.val n s)
  constructor
  · obtain ⟨f, hfn, hf⟩ := D.exists_dpRun_ending n s
    exact ⟨f, by rw [hf.score_eq_val, hfn, hs]⟩
  · rintro w ⟨f, rfl⟩
    exact le_trans (D.score_le_val f n) (Finset.le_sup' (fun s => D.val n s) (Finset.mem_univ _))

end Existence

/-! ## Backward values and the forward–backward decomposition -/

section Backward

variable [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- The backward DP value: `bval D k m s` is the best weight of `m` further transitions
starting from state `s` at stage `k`. -/
def bval (D : DPSpec S W) : ℕ → ℕ → S → W
  | _, 0, _ => 0
  | k, (m + 1), s =>
      (Finset.univ : Finset S).sup' Finset.univ_nonempty
        (fun t => D.step k s t + D.bval (k + 1) m t)

omit [AddLeftMono W] in
@[simp] theorem bval_zero (D : DPSpec S W) (k : ℕ) (s : S) : D.bval k 0 s = 0 := rfl

omit [AddLeftMono W] in
theorem bval_succ (D : DPSpec S W) (k m : ℕ) (s : S) :
    D.bval k (m + 1) s =
      (Finset.univ : Finset S).sup' Finset.univ_nonempty
        (fun t => D.step k s t + D.bval (k + 1) m t) := rfl

/-- **Forward–backward decomposition.** Splitting an optimal run at any intermediate stage `k`
gives the optimum of forward value plus backward value. -/
theorem forward_backward (D : DPSpec S W) :
    ∀ (m k : ℕ),
      (Finset.univ : Finset S).sup' Finset.univ_nonempty (fun s => D.val (k + m) s) =
        (Finset.univ : Finset S).sup' Finset.univ_nonempty
          (fun s => D.val k s + D.bval k m s) := by
  intro m
  induction m with
  | zero => intro k; simp
  | succ m ih =>
      intro k
      have key : k + (m + 1) = (k + 1) + m := by omega
      rw [key, ih (k + 1)]
      -- expand `val (k+1)` on the left and `bval k (m+1)` on the right
      have L : ∀ t : S, D.val (k + 1) t + D.bval (k + 1) m t =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun s => D.val k s + D.step k s t + D.bval (k + 1) m t) := by
        intro t
        rw [val_succ, sup'_add]
      have R : ∀ s : S, D.val k s + D.bval k (m + 1) s =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun t => D.val k s + (D.step k s t + D.bval (k + 1) m t)) := by
        intro s
        rw [bval_succ, add_sup']
      simp only [L, R]
      rw [Finset.sup'_comm]
      congr 1
      funext s
      congr 1
      funext t
      rw [add_assoc]

end Backward

/-! ## Monotonicity in the specification -/

section Monotone

variable [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- The DP value function is monotone in the specification. -/
theorem val_mono {D D' : DPSpec S W} (hinit : ∀ s, D.init s ≤ D'.init s)
    (hstep : ∀ i s t, D.step i s t ≤ D'.step i s t) :
    ∀ (n : ℕ) (s : S), D.val n s ≤ D'.val n s := by
  intro n
  induction n with
  | zero => intro s; simpa using hinit s
  | succ n ih =>
      intro t
      rw [val_succ, val_succ]
      refine Finset.sup'_le _ _ (fun s _ => ?_)
      exact le_trans (add_le_add (ih s) (hstep n s t))
        (Finset.le_sup' (fun s => D'.val n s + D'.step n s t) (Finset.mem_univ s))

omit [Fintype S] [Nonempty S] in
/-- Scores are monotone in the specification. -/
theorem score_mono {D D' : DPSpec S W} (hinit : ∀ s, D.init s ≤ D'.init s)
    (hstep : ∀ i s t, D.step i s t ≤ D'.step i s t) (f : ℕ → S) :
    ∀ n : ℕ, D.score f n ≤ D'.score f n := by
  intro n
  induction n with
  | zero => simpa using hinit (f 0)
  | succ n ih => exact add_le_add ih (hstep n (f n) (f (n + 1)))

end Monotone

end DPSpec

end Logic.DPCompleteness