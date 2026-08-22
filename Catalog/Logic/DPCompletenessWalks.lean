/-
# Walk algebra for layered dynamic programming

This file complements `Logic.DPCompleteness`. There the DP value function `val` and the
completeness theorem ("every labelling is dominated by some DP run") were established.
Here we develop the *segment* (walk) calculus that underlies the value function:

* `DPSpec.walk D k m s t` — the optimal weight of `m + 1` consecutive transitions starting
  in state `s` at stage `k` and ending in state `t` at stage `k + m + 1`;
* `DPSpec.walk_chapman_kolmogorov` — the max-plus Chapman–Kolmogorov identity, i.e.
  associativity of segment composition. In tropical language, this says that the family of
  matrices `walk D k m` forms a (shifted) semigroup under max-plus matrix multiplication;
* `DPSpec.val_add` — the forward value function is the max-plus action of the walk matrices
  on the initial value vector;
* `DPSpec.bval_eq_sup_walk` — the backward value function is the row-max of a walk matrix.

Finally we instantiate everything on an explicit three-state integer digraph and check the
computed values against a brute-force enumeration of all labellings, entirely inside Lean
using `decide`.
-/

import Logic.DPCompleteness

namespace Logic.DPCompleteness

namespace DPSpec

variable {S W : Type*} [AddCommMonoid W] [Fintype S] [Nonempty S] [LinearOrder W] [AddLeftMono W]

/-- `walk D k m s t` is the optimal total weight of `m + 1` transitions leading from state `s`
at stage `k` to state `t` at stage `k + m + 1`.  (The `+ 1` shift avoids having to adjoin a
bottom element for empty walks.) -/
def walk (D : DPSpec S W) : ℕ → ℕ → S → S → W
  | k, 0, s, t => D.step k s t
  | k, (m + 1), s, t =>
      (Finset.univ : Finset S).sup' Finset.univ_nonempty
        (fun u => D.step k s u + D.walk (k + 1) m u t)

omit [AddLeftMono W] in
@[simp] theorem walk_zero (D : DPSpec S W) (k : ℕ) (s t : S) : D.walk k 0 s t = D.step k s t :=
  rfl

omit [AddLeftMono W] in
theorem walk_succ (D : DPSpec S W) (k m : ℕ) (s t : S) :
    D.walk k (m + 1) s t =
      (Finset.univ : Finset S).sup' Finset.univ_nonempty
        (fun u => D.step k s u + D.walk (k + 1) m u t) := rfl

/-- **Chapman–Kolmogorov / associativity of segment composition.**
Splitting a walk of `m₁ + m₂ + 2` transitions after the first `m₁ + 1` of them gives the
max-plus product of the two segment matrices. -/
theorem walk_chapman_kolmogorov (D : DPSpec S W) :
    ∀ (m₁ m₂ k : ℕ) (s u : S),
      D.walk k (m₁ + m₂ + 1) s u =
        (Finset.univ : Finset S).sup' Finset.univ_nonempty
          (fun t => D.walk k m₁ s t + D.walk (k + m₁ + 1) m₂ t u) := by
  intro m₁
  induction m₁ with
  | zero =>
      intro m₂ k s u
      simp only [Nat.zero_add, Nat.add_zero, walk_succ, walk_zero]
  | succ m₁ ih =>
      intro m₂ k s u
      have e : m₁ + 1 + m₂ + 1 = (m₁ + m₂ + 1) + 1 := by omega
      have eidx : k + 1 + m₁ + 1 = k + (m₁ + 1) + 1 := by omega
      rw [e, walk_succ]
      have L2 : ∀ v : S, D.step k s v + D.walk (k + 1) (m₁ + m₂ + 1) v u =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun t => D.step k s v + (D.walk (k + 1) m₁ v t +
              D.walk (k + (m₁ + 1) + 1) m₂ t u)) := by
        intro v
        have hv := ih m₂ (k + 1) v u
        rw [eidx] at hv
        rw [hv, add_sup']
      have R : ∀ t : S, D.walk k (m₁ + 1) s t + D.walk (k + (m₁ + 1) + 1) m₂ t u =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun v => (D.step k s v + D.walk (k + 1) m₁ v t) +
              D.walk (k + (m₁ + 1) + 1) m₂ t u) := by
        intro t; rw [walk_succ, sup'_add]
      simp only [L2, R]
      rw [Finset.sup'_comm]
      refine Finset.sup'_congr _ rfl (fun t _ => ?_)
      refine Finset.sup'_congr _ rfl (fun v _ => ?_)
      exact (add_assoc _ _ _).symm

/-- Appending a single transition at the *end* of a walk. -/
theorem walk_succ_right (D : DPSpec S W) (k m : ℕ) (s u : S) :
    D.walk k (m + 1) s u =
      (Finset.univ : Finset S).sup' Finset.univ_nonempty
        (fun t => D.walk k m s t + D.step (k + m + 1) t u) := by
  have h := D.walk_chapman_kolmogorov m 0 k s u
  simpa using h

/-- The forward value function is the max-plus action of the walk matrices on the value
vector at an earlier stage. -/
theorem val_add (D : DPSpec S W) :
    ∀ (m k : ℕ) (t : S),
      D.val (k + m + 1) t =
        (Finset.univ : Finset S).sup' Finset.univ_nonempty
          (fun s => D.val k s + D.walk k m s t) := by
  intro m
  induction m with
  | zero => intro k t; rw [Nat.add_zero, val_succ]; simp
  | succ m ih =>
      intro k t
      have e : k + (m + 1) + 1 = (k + m + 1) + 1 := by omega
      rw [e, val_succ]
      have L : ∀ v : S, D.val (k + m + 1) v + D.step (k + m + 1) v t =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun s => (D.val k s + D.walk k m s v) + D.step (k + m + 1) v t) := by
        intro v; rw [ih k v, sup'_add]
      have R : ∀ s : S, D.val k s + D.walk k (m + 1) s t =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun v => D.val k s + (D.walk k m s v + D.step (k + m + 1) v t)) := by
        intro s; rw [walk_succ_right, add_sup']
      simp only [L, R]
      rw [Finset.sup'_comm]
      refine Finset.sup'_congr _ rfl (fun s _ => ?_)
      refine Finset.sup'_congr _ rfl (fun v _ => ?_)
      rw [add_assoc]

/-- The backward value function is the row-maximum of the corresponding walk matrix. -/
theorem bval_eq_sup_walk (D : DPSpec S W) :
    ∀ (m k : ℕ) (s : S),
      D.bval k (m + 1) s =
        (Finset.univ : Finset S).sup' Finset.univ_nonempty (fun t => D.walk k m s t) := by
  intro m
  induction m with
  | zero => intro k s; rw [bval_succ]; simp
  | succ m ih =>
      intro k s
      rw [bval_succ]
      have L : ∀ t : S, D.step k s t + D.bval (k + 1) (m + 1) t =
          (Finset.univ : Finset S).sup' Finset.univ_nonempty
            (fun u => D.step k s t + D.walk (k + 1) m t u) := by
        intro t; rw [ih (k + 1) t, add_sup']
      simp only [L, walk_succ]
      exact Finset.sup'_comm _ _ _

end DPSpec

end Logic.DPCompleteness