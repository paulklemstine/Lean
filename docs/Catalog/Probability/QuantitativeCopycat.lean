/-
# Quantitative Copycat stability for probabilistic transition systems

This file develops a *quantitative* transport theorem for probabilistic modal logic
along ε-approximate structural analogies ("Copycat maps") between finite
probabilistic transition systems.

The research conjecture under test was:

> For finite probabilistic transition systems, an ε-approximate structural analogy
> transports every modal formula of depth `d` with truth-probability error at most
> `d * ε`, and this linear bound is sharp.

What we prove here:

* `PModalStructure.transport_le` : the exact contraction bound
  `|⟦φ⟧_M s - ⟦φ⟧_N (f s)| ≤ 1 - (1 - ε) ^ depth φ`.
* `PModalStructure.transport_le_depth_mul` : the conjectured linear bound
  `≤ depth φ * ε` follows (Bernoulli).
* `Sharp.transport_eq` : the contraction bound `1 - (1-ε)^d` is *attained* by an
  explicit two-state family, for every depth `d` and every `ε ∈ [0,1]`.
* `linear_bound_not_attained` : for `d ≥ 2` and `0 < ε < 1` one has strictly
  `1 - (1-ε)^d < d * ε`, so the *linear* bound of the conjecture, while true, is
  never attained; the exact modulus of continuity is `ε ↦ 1 - (1-ε)^d`.
* `depth_mul_sub_le_quadratic` : `d*ε - (d*(d-1)/2)*ε^2 ≤ 1 - (1-ε)^d`, so the
  linear bound *is* sharp to first order in `ε`.

Thus the conjecture is confirmed as an upper bound and refuted as an equality:
the true modulus is the geometric (not linear) accumulation of local defects.
-/
import Mathlib

namespace Catalog.Probability.QuantitativeCopycat

open Finset

/-! ## Real-analytic lemmas about the modulus `1 - (1-ε)^d` -/

/-- Bernoulli: the geometric accumulation of defects is below the linear one. -/
theorem one_sub_pow_le_depth_mul (ε : ℝ) (hε : ε ≤ 2) (d : ℕ) :
    1 - (1 - ε) ^ d ≤ d * ε := by
  have h : (1 : ℝ) + d * (-ε) ≤ (1 + -ε) ^ d :=
    one_add_mul_le_pow (by linarith) d
  have e1 : (1 : ℝ) + -ε = 1 - ε := by ring
  have e2 : (1 : ℝ) + d * (-ε) = 1 - d * ε := by ring
  rw [e1, e2] at h
  linarith

/-- The modulus is monotone in the depth. -/
theorem one_sub_pow_mono (ε : ℝ) (h0 : 0 ≤ ε) (h1 : ε ≤ 1) {d e : ℕ} (h : d ≤ e) :
    1 - (1 - ε) ^ d ≤ 1 - (1 - ε) ^ e := by
  have := pow_le_pow_of_le_one (a := 1 - ε) (by linarith) (by linarith) h
  linarith

/-- The modulus lies in `[0,1]`. -/
theorem one_sub_pow_mem (ε : ℝ) (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (d : ℕ) :
    0 ≤ 1 - (1 - ε) ^ d ∧ 1 - (1 - ε) ^ d ≤ 1 := by
  constructor
  · have := pow_le_one₀ (a := 1 - ε) (by linarith) (by linarith) (n := d)
    linarith
  · have := pow_nonneg (a := 1 - ε) (by linarith) d
    linarith

/-- Second-order (in `ε`) lower bound: the geometric modulus agrees with the linear
bound to first order, with quadratic defect at most `d(d-1)/2 · ε²`. -/
theorem depth_mul_sub_le_quadratic (ε : ℝ) (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (d : ℕ) :
    (d : ℝ) * ε - (d * (d - 1) / 2) * ε ^ 2 ≤ 1 - (1 - ε) ^ d := by
  induction d with
  | zero => simp
  | succ n ih =>
      set a : ℝ := 1 - (1 - ε) ^ n with ha
      have hstep : 1 - (1 - ε) ^ (n + 1) = a + ε * (1 - a) := by
        simp only [ha, pow_succ]; ring
      have hup : a ≤ n * ε := one_sub_pow_le_depth_mul ε (by linarith) n
      have hnn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      rw [hstep]
      push_cast
      nlinarith [ih, hup, hnn, sq_nonneg ε, mul_nonneg h0 hnn]

/-- For depth at least `2` and a genuinely approximate analogy (`0 < ε < 1`) the
linear bound is *strict*: the conjectured linear modulus is never attained. -/
theorem one_sub_pow_lt_depth_mul (ε : ℝ) (h0 : 0 < ε) (h1 : ε < 1) {d : ℕ} (hd : 2 ≤ d) :
    1 - (1 - ε) ^ d < d * ε := by
  induction d with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge n 2 with hn | hn
      · -- then `n = 1`, i.e. `d = 2`
        have hn1 : n = 1 := by omega
        subst hn1
        push_cast
        nlinarith [mul_pos h0 h0]
      · have hstep : 1 - (1 - ε) ^ (n + 1) = (1 - (1 - ε) ^ n) + ε * ((1 - ε) ^ n) := by
          ring
        have hpos : 0 < (1 - ε) ^ n := pow_pos (by linarith) n
        have hple : (1 - ε) ^ n ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
        have := ih hn
        rw [hstep]
        push_cast
        nlinarith [mul_pos h0 hpos]

/-! ## Probabilistic modal structures -/

/-- A finite probabilistic transition system together with a `[0,1]`-valued
valuation of atomic propositions (a *probabilistic modal structure*). -/
structure PModalStructure (ι : Type*) (S : Type*) [Fintype S] where
  /-- Transition kernel. -/
  step : S → S → ℝ
  step_nonneg : ∀ s t, 0 ≤ step s t
  step_sum : ∀ s, ∑ t, step s t = 1
  /-- Truth-probability of atoms. -/
  val : ι → S → ℝ
  val_nonneg : ∀ p s, 0 ≤ val p s
  val_le_one : ∀ p s, val p s ≤ 1

/-- Probabilistic modal formulas: atoms, negation, (min-)conjunction and the
one-step expectation modality. -/
inductive PForm (ι : Type*) : Type _
  | atom : ι → PForm ι
  | neg : PForm ι → PForm ι
  | conj : PForm ι → PForm ι → PForm ι
  | next : PForm ι → PForm ι

namespace PForm

/-- Modal depth: the number of nested `next` observations. -/
def depth {ι : Type*} : PForm ι → ℕ
  | atom _ => 0
  | neg φ => depth φ
  | conj φ ψ => max (depth φ) (depth ψ)
  | next φ => depth φ + 1

/-- `next` iterated `n` times. -/
def nextIter {ι : Type*} : ℕ → PForm ι → PForm ι
  | 0, φ => φ
  | n + 1, φ => next (nextIter n φ)

@[simp] theorem depth_nextIter {ι : Type*} (n : ℕ) (φ : PForm ι) :
    (nextIter n φ).depth = n + φ.depth := by
  induction n with
  | zero => simp [nextIter]
  | succ k ih => simp [nextIter, depth, ih]; omega

end PForm

namespace PModalStructure

variable {ι S : Type*} [Fintype S]

/-- Truth-probability semantics. -/
def eval (M : PModalStructure ι S) : PForm ι → S → ℝ
  | .atom p => M.val p
  | .neg φ => fun s => 1 - M.eval φ s
  | .conj φ ψ => fun s => min (M.eval φ s) (M.eval ψ s)
  | .next φ => fun s => ∑ t, M.step s t * M.eval φ t

@[simp] theorem eval_atom (M : PModalStructure ι S) (p : ι) : M.eval (.atom p) = M.val p := rfl
@[simp] theorem eval_neg (M : PModalStructure ι S) (φ : PForm ι) (s : S) :
    M.eval (.neg φ) s = 1 - M.eval φ s := rfl
@[simp] theorem eval_conj (M : PModalStructure ι S) (φ ψ : PForm ι) (s : S) :
    M.eval (.conj φ ψ) s = min (M.eval φ s) (M.eval ψ s) := rfl
@[simp] theorem eval_next (M : PModalStructure ι S) (φ : PForm ι) (s : S) :
    M.eval (.next φ) s = ∑ t, M.step s t * M.eval φ t := rfl

/-- Truth probabilities are genuine probabilities. -/
theorem eval_mem (M : PModalStructure ι S) (φ : PForm ι) (s : S) :
    0 ≤ M.eval φ s ∧ M.eval φ s ≤ 1 := by
  induction φ generalizing s with
  | atom p => exact ⟨M.val_nonneg p s, M.val_le_one p s⟩
  | neg φ ih =>
      simp only [PModalStructure.eval_neg]
      constructor <;> linarith [(ih s).1, (ih s).2]
  | conj φ ψ ihφ ihψ =>
      refine ⟨le_min (ihφ s).1 (ihψ s).1, le_trans (min_le_left _ _) (ihφ s).2⟩
  | next φ ih =>
      constructor
      · exact sum_nonneg fun t _ => mul_nonneg (M.step_nonneg s t) (ih t).1
      · calc ∑ t, M.step s t * M.eval φ t ≤ ∑ t, M.step s t * 1 :=
              sum_le_sum fun t _ =>
                mul_le_mul_of_nonneg_left (ih t).2 (M.step_nonneg s t)
          _ = 1 := by simpa using M.step_sum s

theorem eval_nonneg (M : PModalStructure ι S) (φ : PForm ι) (s : S) : 0 ≤ M.eval φ s :=
  (M.eval_mem φ s).1

theorem eval_le_one (M : PModalStructure ι S) (φ : PForm ι) (s : S) : M.eval φ s ≤ 1 :=
  (M.eval_mem φ s).2

end PModalStructure

/-! ## ε-approximate structural analogies -/

/-- An **ε-approximate structural analogy** (Copycat map) between two probabilistic
modal structures: a bijection of state spaces preserving atomic truth probabilities
exactly, whose transported transition kernels overlap up to a defect `ε`
(the overlap defect `1 - ∑ min` is exactly the total variation distance). -/
structure ApproxAnalogy {ι S S' : Type*} [Fintype S] [Fintype S']
    (M : PModalStructure ι S) (N : PModalStructure ι S') (ε : ℝ) where
  /-- The underlying renaming of worlds. -/
  toEquiv : S ≃ S'
  atoms : ∀ p s, N.val p (toEquiv s) = M.val p s
  defect : ∀ s, 1 - ∑ t, min (M.step s t) (N.step (toEquiv s) (toEquiv t)) ≤ ε

/-- One-sided one-step estimate: if two probability vectors have overlap defect at
most `ε` and the two `[0,1]`-valued observables differ by at most `δ`, their
expectations differ by at most `δ + ε(1-δ)`. -/
theorem one_step_bound {S : Type*} [Fintype S] (P Q g g' : S → ℝ) (δ ε : ℝ)
    (hPn : ∀ t, 0 ≤ P t) (hPs : ∑ t, P t = 1)
    (hQn : ∀ t, 0 ≤ Q t)
    (hg1 : ∀ t, g t ≤ 1) (hg'0 : ∀ t, 0 ≤ g' t)
    (hd : ∀ t, g t - g' t ≤ δ) (hδ1 : δ ≤ 1)
    (hov : 1 - ∑ t, min (P t) (Q t) ≤ ε) :
    ∑ t, P t * g t - ∑ t, Q t * g' t ≤ δ + ε * (1 - δ) := by
  set m : S → ℝ := fun t => min (P t) (Q t) with hm
  have hmn : ∀ t, 0 ≤ m t := fun t => le_min (hPn t) (hQn t)
  have hmP : ∀ t, m t ≤ P t := fun t => min_le_left _ _
  have hmQ : ∀ t, m t ≤ Q t := fun t => min_le_right _ _
  set M0 : ℝ := ∑ t, m t with hM0
  -- decomposition
  have hdecomp : ∑ t, P t * g t - ∑ t, Q t * g' t
      = (∑ t, m t * (g t - g' t)) + (∑ t, (P t - m t) * g t)
        - (∑ t, (Q t - m t) * g' t) := by
    rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun t _ => by ring
  have h1 : ∑ t, m t * (g t - g' t) ≤ M0 * δ := by
    rw [hM0, Finset.sum_mul]
    exact sum_le_sum fun t _ => mul_le_mul_of_nonneg_left (hd t) (hmn t)
  have h2 : ∑ t, (P t - m t) * g t ≤ 1 - M0 := by
    have : ∑ t, (P t - m t) * g t ≤ ∑ t, (P t - m t) := by
      refine sum_le_sum fun t _ => ?_
      have h := sub_nonneg.2 (hmP t)
      nlinarith [hg1 t]
    calc ∑ t, (P t - m t) * g t ≤ ∑ t, (P t - m t) := this
      _ = 1 - M0 := by rw [Finset.sum_sub_distrib, hPs, hM0]
  have h3 : 0 ≤ ∑ t, (Q t - m t) * g' t :=
    sum_nonneg fun t _ => mul_nonneg (sub_nonneg.2 (hmQ t)) (hg'0 t)
  have hM0le : 1 - M0 ≤ ε := hov
  rw [hdecomp]
  nlinarith [h1, h2, h3, hM0le, hδ1]

variable {ι S S' : Type*} [Fintype S] [Fintype S']

/-- **Quantitative transport theorem.** Along an ε-approximate structural analogy,
a modal formula of depth `d` has truth probabilities differing by at most
`1 - (1-ε)^d`. -/
theorem PModalStructure.transport_le (M : PModalStructure ι S) (N : PModalStructure ι S')
    {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (A : ApproxAnalogy M N ε) (φ : PForm ι) (s : S) :
    |M.eval φ s - N.eval φ (A.toEquiv s)| ≤ 1 - (1 - ε) ^ φ.depth := by
  induction φ generalizing s with
  | atom p => simp [A.atoms p s, PForm.depth]
  | neg φ ih =>
      have := ih s
      have hrw : M.eval (.neg φ) s - N.eval (.neg φ) (A.toEquiv s)
          = -(M.eval φ s - N.eval φ (A.toEquiv s)) := by
        simp only [PModalStructure.eval_neg]; ring
      rw [hrw, abs_neg]
      simpa [PForm.depth] using this
  | conj φ ψ ihφ ihψ =>
      have hb := abs_min_sub_min_le_max (M.eval φ s) (M.eval ψ s)
        (N.eval φ (A.toEquiv s)) (N.eval ψ (A.toEquiv s))
      have hφ : |M.eval φ s - N.eval φ (A.toEquiv s)|
          ≤ 1 - (1 - ε) ^ (PForm.conj φ ψ).depth :=
        le_trans (ihφ s) (one_sub_pow_mono ε h0 h1 (le_max_left _ _))
      have hψ : |M.eval ψ s - N.eval ψ (A.toEquiv s)|
          ≤ 1 - (1 - ε) ^ (PForm.conj φ ψ).depth :=
        le_trans (ihψ s) (one_sub_pow_mono ε h0 h1 (le_max_right _ _))
      simp only [PModalStructure.eval_conj]
      exact le_trans hb (max_le hφ hψ)
  | next φ ih =>
      set δ : ℝ := 1 - (1 - ε) ^ φ.depth with hδ
      obtain ⟨hδ0, hδ1⟩ := one_sub_pow_mem ε h0 h1 φ.depth
      set f := A.toEquiv with hf
      set P : S → ℝ := fun t => M.step s t with hP
      set Q : S → ℝ := fun t => N.step (f s) (f t) with hQ
      set g : S → ℝ := fun t => M.eval φ t with hg
      set g' : S → ℝ := fun t => N.eval φ (f t) with hg'
      have hPs : ∑ t, P t = 1 := M.step_sum s
      have hQs : ∑ t, Q t = 1 := by
        rw [hQ]
        rw [show (∑ t, N.step (f s) (f t)) = ∑ u, N.step (f s) u from
          Equiv.sum_comp f (fun u => N.step (f s) u)]
        exact N.step_sum (f s)
      have hgoal : M.eval (.next φ) s - N.eval (.next φ) (f s)
          = (∑ t, P t * g t) - (∑ t, Q t * g' t) := by
        simp only [PModalStructure.eval_next]
        congr 1
        rw [show (∑ u, N.step (f s) u * N.eval φ u)
            = ∑ t, N.step (f s) (f t) * N.eval φ (f t) from
          (Equiv.sum_comp f (fun u => N.step (f s) u * N.eval φ u)).symm]
      have hdiff : ∀ t, |g t - g' t| ≤ δ := fun t => ih t
      have hupper : (∑ t, P t * g t) - (∑ t, Q t * g' t) ≤ δ + ε * (1 - δ) :=
        one_step_bound P Q g g' δ ε (fun t => M.step_nonneg s t) hPs
          (fun t => N.step_nonneg (f s) (f t))
          (fun t => M.eval_le_one φ t) (fun t => N.eval_nonneg φ (f t))
          (fun t => (abs_le.1 (hdiff t)).2) hδ1 (A.defect s)
      have hlower : (∑ t, Q t * g' t) - (∑ t, P t * g t) ≤ δ + ε * (1 - δ) := by
        refine one_step_bound Q P g' g δ ε (fun t => N.step_nonneg (f s) (f t)) hQs
          (fun t => M.step_nonneg s t)
          (fun t => N.eval_le_one φ (f t)) (fun t => M.eval_nonneg φ t)
          (fun t => by have := (abs_le.1 (hdiff t)).1; linarith) hδ1 ?_
        simpa [min_comm] using A.defect s
      have hd1 : (PForm.next φ).depth = φ.depth + 1 := rfl
      have hexp : 1 - (1 - ε) ^ (PForm.next φ).depth = δ + ε * (1 - δ) := by
        rw [hd1, hδ, pow_succ]; ring
      rw [hgoal, hexp, abs_le]
      exact ⟨by linarith, hupper⟩

/-- **The conjectured linear bound.** Truth-probability error at most `d * ε`. -/
theorem PModalStructure.transport_le_depth_mul (M : PModalStructure ι S)
    (N : PModalStructure ι S') {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1)
    (A : ApproxAnalogy M N ε) (φ : PForm ι) (s : S) :
    |M.eval φ s - N.eval φ (A.toEquiv s)| ≤ (φ.depth : ℝ) * ε :=
  le_trans (M.transport_le N h0 h1 A φ s) (one_sub_pow_le_depth_mul ε (by linarith) φ.depth)

/-- Exact transport (`ε = 0`): a strict structural analogy preserves all
truth probabilities. -/
theorem PModalStructure.transport_exact (M : PModalStructure ι S) (N : PModalStructure ι S')
    (A : ApproxAnalogy M N 0) (φ : PForm ι) (s : S) :
    M.eval φ s = N.eval φ (A.toEquiv s) := by
  have h := M.transport_le N le_rfl zero_le_one A φ s
  have hz : (1 : ℝ) - (1 - 0) ^ φ.depth = 0 := by norm_num
  rw [hz] at h
  have hnn := abs_nonneg (M.eval φ s - N.eval φ (A.toEquiv s))
  exact sub_eq_zero.1 (abs_eq_zero.1 (le_antisymm h hnn))

/-! ## Sharpness: an explicit extremal two-state family -/

namespace Sharp

/-- The exact system: `true` and `false` are both absorbing; the atom is true at
`true` and false at `false`. -/
def exactSys (ι : Type*) : PModalStructure ι Bool where
  step s t := if s = t then 1 else 0
  step_nonneg s t := by split <;> norm_num
  step_sum s := by simp
  val _ s := if s then 1 else 0
  val_nonneg _ s := by split <;> norm_num
  val_le_one _ s := by split <;> norm_num

/-- The perturbed system: from `true` a mass `ε` leaks into the absorbing `false`. -/
def leakySys (ι : Type*) (ε : ℝ) (h0 : 0 ≤ ε) (h1 : ε ≤ 1) : PModalStructure ι Bool where
  step s t := if s then (if t then 1 - ε else ε) else (if t then 0 else 1)
  step_nonneg s t := by
    rcases s with _ | _ <;> rcases t with _ | _ <;> simp <;> linarith
  step_sum s := by cases s <;> simp
  val _ s := if s then 1 else 0
  val_nonneg _ s := by split <;> norm_num
  val_le_one _ s := by split <;> norm_num

variable {ι : Type*} {ε : ℝ}

@[simp] theorem exactSys_step (s t : Bool) :
    (exactSys ι).step s t = if s = t then 1 else 0 := rfl

@[simp] theorem exactSys_val (p : ι) (s : Bool) :
    (exactSys ι).val p s = if s then 1 else 0 := rfl

@[simp] theorem leakySys_step (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (s t : Bool) :
    (leakySys ι ε h0 h1).step s t =
      if s then (if t then 1 - ε else ε) else (if t then 0 else 1) := rfl

@[simp] theorem leakySys_val (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (p : ι) (s : Bool) :
    (leakySys ι ε h0 h1).val p s = if s then 1 else 0 := rfl

/-- The identity renaming is an ε-approximate structural analogy from the exact to
the leaky system: the only defect is the leak of size `ε` at the state `true`. -/
def analogy (ι : Type*) (h0 : 0 ≤ ε) (h1 : ε ≤ 1) :
    ApproxAnalogy (exactSys ι) (leakySys ι ε h0 h1) ε where
  toEquiv := Equiv.refl Bool
  atoms p s := rfl
  defect s := by
    cases s <;> simp [min_def] <;> first | linarith | (split_ifs <;> linarith)

/-- In the leaky system the iterated modality is `0` at the absorbing state `false`. -/
theorem leaky_eval_false (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (p : ι) (d : ℕ) :
    (leakySys ι ε h0 h1).eval (PForm.nextIter d (.atom p)) false = 0 := by
  induction d with
  | zero => simp [PForm.nextIter]
  | succ n ih => simp [PForm.nextIter, ih]

/-- In the leaky system the depth-`d` truth probability at `true` is `(1-ε)^d`:
the local defect `ε` accumulates *geometrically*, not linearly. -/
theorem leaky_eval_true (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (p : ι) (d : ℕ) :
    (leakySys ι ε h0 h1).eval (PForm.nextIter d (.atom p)) true = (1 - ε) ^ d := by
  induction d with
  | zero => simp [PForm.nextIter]
  | succ n ih =>
      rw [PForm.nextIter, PModalStructure.eval_next]
      rw [Fintype.sum_bool]
      rw [ih, leaky_eval_false h0 h1 p n]
      simp [pow_succ, mul_comm]

/-- In the exact system the depth-`d` truth probability at `true` is `1`. -/
theorem exact_eval_true (p : ι) (d : ℕ) :
    (exactSys ι).eval (PForm.nextIter d (.atom p)) true = 1 := by
  induction d with
  | zero => simp [PForm.nextIter]
  | succ n ih => simp [PForm.nextIter, ih]

/-- **Sharpness of the contraction bound.** For every depth `d` and every
`ε ∈ [0,1]` the bound `1 - (1-ε)^d` of `transport_le` is attained by the
two-state leaking family. -/
theorem transport_eq (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (p : ι) (d : ℕ) :
    |(exactSys ι).eval (PForm.nextIter d (.atom p)) true
      - (leakySys ι ε h0 h1).eval (PForm.nextIter d (.atom p))
          ((analogy ι h0 h1).toEquiv true)|
      = 1 - (1 - ε) ^ (PForm.nextIter d (PForm.atom p)).depth := by
  have hd : (PForm.nextIter d (PForm.atom p)).depth = d := by simp [PForm.depth]
  have hEq : ((analogy ι h0 h1).toEquiv true) = true := rfl
  rw [hd, hEq, exact_eval_true p d, leaky_eval_true h0 h1 p d]
  have hp : (1 - ε) ^ d ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
  rw [abs_of_nonneg (by linarith)]

end Sharp

/-- **The linear bound of the conjecture is never attained** for depth `≥ 2` and a
nondegenerate defect: the exact modulus `1 - (1-ε)^d` is strictly below `d·ε`. -/
theorem linear_bound_not_attained {ε : ℝ} (h0 : 0 < ε) (h1 : ε < 1) {d : ℕ} (hd : 2 ≤ d) :
    1 - (1 - ε) ^ d < d * ε :=
  one_sub_pow_lt_depth_mul ε h0 h1 hd

/-- ... but it *is* sharp to first order in `ε`: the gap is `O(d² ε²)`. -/
theorem linear_bound_first_order_sharp {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1) (d : ℕ) :
    (d : ℝ) * ε - (1 - (1 - ε) ^ d) ≤ (d * (d - 1) / 2) * ε ^ 2 := by
  have := depth_mul_sub_le_quadratic ε h0 h1 d
  linarith

end Catalog.Probability.QuantitativeCopycat