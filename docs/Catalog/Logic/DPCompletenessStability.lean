/-
# Stability of the DP value function under perturbation of the specification

The completeness theorem of `Logic.DPCompleteness` says the DP value is the exact optimum over
all labellings.  This file quantifies how that optimum reacts to perturbing the data.

* `DPSpec.shift` uniformly shifts the initial weights by `a` and every transition weight by `b`;
  `DPSpec.val_shift` shows the value function shifts by exactly `a + n • b` — the DP optimum is
  *equivariant* for the additive action of constants.
* `DPSpec.abs_val_sub_le` is the resulting Lipschitz stability bound: if two specifications
  differ by at most `a` on initial weights and at most `b` on transition weights, their value
  functions differ by at most `a + n • b` at horizon `n`.
* `DPSpec.near_optimal_transfer` turns this into a robustness statement about *runs*: a DP run
  computed for a perturbed model is within `2 • (a + n • b)` of the true optimum.  Combined with
  completeness this says the DP is not merely exact, but *stably* exact.

The weight monoid here is a linearly ordered additive commutative group (e.g. `ℤ`, `ℚ`, `ℝ`).
-/

import Logic.DPCompleteness

namespace Logic.DPCompleteness

namespace DPSpec

section Shift

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- Shift all initial weights by `a` and all transition weights by `b`. -/
def shift (D : DPSpec S W) (a b : W) : DPSpec S W :=
  ⟨fun s => D.init s + a, fun i s t => D.step i s t + b⟩

omit [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W] in
@[simp] theorem shift_init (D : DPSpec S W) (a b : W) (s : S) :
    (D.shift a b).init s = D.init s + a := rfl

omit [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W] in
@[simp] theorem shift_step (D : DPSpec S W) (a b : W) (i : ℕ) (s t : S) :
    (D.shift a b).step i s t = D.step i s t + b := rfl

/-- **Equivariance of the DP optimum.** A uniform shift of the data shifts the value function
by exactly `a + n • b`. -/
theorem val_shift (D : DPSpec S W) (a b : W) :
    ∀ (n : ℕ) (s : S), (D.shift a b).val n s = D.val n s + (a + n • b) := by
  intro n
  induction n with
  | zero => intro s; simp
  | succ n ih =>
      intro t
      rw [val_succ, val_succ]
      have hstep : ∀ s : S,
          (D.shift a b).val n s + (D.shift a b).step n s t =
            (D.val n s + D.step n s t) + (a + (n + 1) • b) := by
        intro s
        rw [ih s, shift_step, succ_nsmul b n]
        abel
      simp only [hstep]
      rw [sup'_add]

end Shift

section Stability

variable {S W : Type*} [AddCommGroup W] [Fintype S] [Nonempty S] [LinearOrder W]
  [IsOrderedAddMonoid W]

omit [Fintype S] [Nonempty S] in
/-- From a two-sided bound `|x - y| ≤ c` we extract `x ≤ y + c`. -/
theorem le_add_of_abs_sub_le {x y c : W} (h : |x - y| ≤ c) : x ≤ y + c :=
  sub_le_iff_le_add'.mp (abs_le.mp h).2

/-- Comparison of value functions from a one-sided comparison of specifications. -/
theorem val_le_val_shift {D D' : DPSpec S W} {a b : W}
    (hinit : ∀ s, D'.init s ≤ D.init s + a) (hstep : ∀ i s t, D'.step i s t ≤ D.step i s t + b) :
    ∀ (n : ℕ) (s : S), D'.val n s ≤ D.val n s + (a + n • b) := by
  intro n s
  have h := val_mono (D := D') (D' := D.shift a b) hinit hstep n s
  rwa [val_shift] at h

/-- **Lipschitz stability of the DP optimum.** If two specifications differ by at most `a` on
the initial weights and at most `b` on every transition weight, then their value functions
differ by at most `a + n • b` at horizon `n`. -/
theorem abs_val_sub_le {D D' : DPSpec S W} {a b : W}
    (hinit : ∀ s, |D'.init s - D.init s| ≤ a) (hstep : ∀ i s t, |D'.step i s t - D.step i s t| ≤ b)
    (n : ℕ) (s : S) : |D'.val n s - D.val n s| ≤ a + n • b := by
  have hi1 : ∀ s, D'.init s ≤ D.init s + a := fun s => le_add_of_abs_sub_le (hinit s)
  have hi2 : ∀ s, D.init s ≤ D'.init s + a := fun s =>
    le_add_of_abs_sub_le (by rw [abs_sub_comm]; exact hinit s)
  have hs1 : ∀ i s t, D'.step i s t ≤ D.step i s t + b :=
    fun i s t => le_add_of_abs_sub_le (hstep i s t)
  have hs2 : ∀ i s t, D.step i s t ≤ D'.step i s t + b := fun i s t =>
    le_add_of_abs_sub_le (by rw [abs_sub_comm]; exact hstep i s t)
  have h1 := val_le_val_shift hi1 hs1 n s
  have h2 := val_le_val_shift hi2 hs2 n s
  rw [abs_sub_le_iff]
  exact ⟨sub_le_iff_le_add'.mpr h1, sub_le_iff_le_add'.mpr h2⟩

omit [Fintype S] [Nonempty S] in
/-- Perturbation bound at the level of individual labelling scores. -/
theorem abs_score_sub_le {D D' : DPSpec S W} {a b : W}
    (hinit : ∀ s, |D'.init s - D.init s| ≤ a) (hstep : ∀ i s t, |D'.step i s t - D.step i s t| ≤ b)
    (f : ℕ → S) : ∀ n : ℕ, |D'.score f n - D.score f n| ≤ a + n • b := by
  intro n
  induction n with
  | zero => simpa using hinit (f 0)
  | succ n ih =>
      have hsplit : D'.score f (n + 1) - D.score f (n + 1) =
          (D'.score f n - D.score f n) +
            (D'.step n (f n) (f (n + 1)) - D.step n (f n) (f (n + 1))) := by
        simp only [score_succ]; abel
      have hbound : |D'.score f (n + 1) - D.score f (n + 1)| ≤ (a + n • b) + b := by
        rw [hsplit]
        exact le_trans (abs_add_le _ _) (add_le_add ih (hstep n (f n) (f (n + 1))))
      calc |D'.score f (n + 1) - D.score f (n + 1)| ≤ (a + n • b) + b := hbound
        _ = a + (n + 1) • b := by rw [succ_nsmul b n]; abel

omit [Fintype S] [Nonempty S] in
/-- **Near-optimality transfer.** If `g` is optimal for the perturbed specification `D'`, then
for the true specification `D` it is within `2 • (a + n • b)` of optimal. -/
theorem near_optimal_transfer {D D' : DPSpec S W} {a b : W}
    (hinit : ∀ s, |D'.init s - D.init s| ≤ a) (hstep : ∀ i s t, |D'.step i s t - D.step i s t| ≤ b)
    (n : ℕ) {g : ℕ → S} (hg : ∀ f : ℕ → S, D'.score f n ≤ D'.score g n) (f : ℕ → S) :
    D.score f n ≤ D.score g n + ((a + n • b) + (a + n • b)) := by
  have h1 : D.score f n ≤ D'.score f n + (a + n • b) :=
    le_add_of_abs_sub_le (by
      rw [abs_sub_comm]; exact abs_score_sub_le hinit hstep f n)
  have h2 : D'.score g n ≤ D.score g n + (a + n • b) :=
    le_add_of_abs_sub_le (abs_score_sub_le hinit hstep g n)
  calc D.score f n ≤ D'.score f n + (a + n • b) := h1
    _ ≤ D'.score g n + (a + n • b) := add_le_add (hg f) le_rfl
    _ ≤ (D.score g n + (a + n • b)) + (a + n • b) := add_le_add h2 le_rfl
    _ = D.score g n + ((a + n • b) + (a + n • b)) := add_assoc _ _ _

/-- **Existence form of near-optimality.** Some genuine DP run of the perturbed specification
is within `2 • (a + n • b)` of the true optimum.  Non-vacuous: the run is produced by
`dp_complete_uniform`. -/
theorem exists_near_optimal_run [IsOrderedCancelAddMonoid W] {D D' : DPSpec S W} {a b : W}
    (hinit : ∀ s, |D'.init s - D.init s| ≤ a) (hstep : ∀ i s t, |D'.step i s t - D.step i s t| ≤ b)
    (n : ℕ) :
    ∃ g : ℕ → S, D'.IsDPRun n g ∧
      ∀ f : ℕ → S, D.score f n ≤ D.score g n + ((a + n • b) + (a + n • b)) := by
  obtain ⟨g, hgrun, hg⟩ := D'.dp_complete_uniform n
  exact ⟨g, hgrun, fun f => near_optimal_transfer hinit hstep n hg f⟩

end Stability

end DPSpec

end Logic.DPCompleteness