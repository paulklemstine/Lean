/-
# The joint-label reconciliation: encoding-invariance and one-sided artifacts

## Context (FACT round-29 #2, verdict "THE-ORIGINAL-STANDS")

Two runs on an *identical* population disagreed about the joint channel:
a width-valid chained encoding reported `36` labels and a large mutual
information, a rebuild using a too-narrow decimal frame reported `18` labels
and a much smaller mutual information.  Which reading is the artifact?

This file answers the question *structurally*, i.e. without access to either
run's data:

* `MI_pushFst_eq_of_injective` — **encoding invariance**: any two width-valid
  (injective) label encodings of the same population give the *same* mutual
  information.  Two clean re-implementations therefore *must* agree; agreement
  is evidence of correctness, and paper 91's value is reproduced by the clean
  cross-check for this reason.
* `MI_pushFst_le` — **one-sidedness (data-processing inequality)**: a
  non-injective label encoding can only *lower* the measured mutual
  information.  Collision artifacts are therefore *signed*: the discrepant
  reading is always the smaller one, so the larger of two readings on the same
  population is the admissible one.
* `narrow_frame_strictly_loses` — on the audited `4 × 9` population the narrow
  `·3` frame strictly loses label entropy, quantitatively:
  `H(narrow labels) ≤ log₂ 36 - 1/18`.

Together: a disagreement between a width-valid and a width-invalid chaining can
only be resolved *in favour of the width-valid one*.  This is the formal content
of the verdict.

The entropy toolkit lives in `Applications.LabelEntropyDeficit`, the arithmetic
of chained frames in `Applications.ChainedLabelWidth`.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.ChainedLabelWidth

namespace JointLabelReconciliation

open Finset LabelEntropy

variable {α β α' : Type*} [Fintype α] [Fintype β] [Fintype α'] [DecidableEq α']

/-- The fiber of a labelling map `f` over the label `u`. -/
def fib (f : α → α') (u : α') : Finset α := {x ∈ (univ : Finset α) | f x = u}

omit [Fintype α'] in
@[simp] lemma mem_fib {f : α → α'} {u : α'} {x : α} : x ∈ fib f u ↔ f x = u := by
  simp [fib]

/-- Pushforward of a weight function along a labelling. -/
noncomputable def push (f : α → α') (p : α → ℝ) : α' → ℝ := fun u => ∑ x ∈ fib f u, p x

/-- Pushforward of a *joint* weight function along a labelling of the first
coordinate (the second coordinate is the reference variable). -/
noncomputable def pushFst (f : α → α') (p : α × β → ℝ) : α' × β → ℝ :=
  fun q => ∑ x ∈ fib f q.1, p (x, q.2)

/-- First marginal. -/
noncomputable def marg1 (p : α × β → ℝ) : α → ℝ := fun x => ∑ y : β, p (x, y)

/-- Second marginal. -/
noncomputable def marg2 (p : α × β → ℝ) : β → ℝ := fun y => ∑ x : α, p (x, y)

/-- Mutual information (bits) of a joint weight function. -/
noncomputable def MI (p : α × β → ℝ) : ℝ :=
  H univ (marg1 p) + H univ (marg2 p) - H univ p

/-! ## Entropy loss of a labelling equals the total fiber deficit -/

/-- The entropy destroyed by a labelling is exactly the sum of the fiber
deficits. -/
theorem H_sub_H_push (f : α → α') (p : α → ℝ) :
    H univ p - H univ (push f p) = ∑ u : α', D (fib f u) p := by
  have h1 : ∑ u : α', H (fib f u) p = H univ p := by
    simpa [H, fib] using Finset.sum_fiberwise (univ : Finset α) f (fun x => nlp (p x))
  have h2 : H univ (push f p) = ∑ u : α', nlp (∑ x ∈ fib f u, p x) := rfl
  rw [h2, ← h1, ← Finset.sum_sub_distrib]
  rfl

/-- **Labelling cannot create entropy.** -/
theorem H_push_le {f : α → α'} {p : α → ℝ} (hp : ∀ x, 0 ≤ p x) :
    H univ (push f p) ≤ H univ p := by
  have := H_sub_H_push f p
  have hD : 0 ≤ ∑ u : α', D (fib f u) p :=
    Finset.sum_nonneg fun u _ => D_nonneg (fun x _ => hp x)
  linarith

omit [Fintype α'] in
/-- Fibers of an injective labelling carry no deficit. -/
lemma D_fib_eq_zero_of_injective {f : α → α'} (hf : Function.Injective f) (u : α')
    (p : α → ℝ) : D (fib f u) p = 0 := by
  classical
  rcases Finset.eq_empty_or_nonempty (fib f u) with hE | ⟨x, hx⟩
  · simp [D, H, hE]
  · have hsingle : fib f u = {x} := by
      refine Finset.eq_singleton_iff_unique_mem.mpr ⟨hx, fun z hz => ?_⟩
      have h1 : f z = u := mem_fib.mp hz
      have h2 : f x = u := mem_fib.mp hx
      exact hf (h1.trans h2.symm)
    simp [D, H, hsingle]

/-- **Encoding invariance for entropy**: an injective relabelling preserves
label entropy exactly. -/
theorem H_push_eq_of_injective {f : α → α'} (hf : Function.Injective f) (p : α → ℝ) :
    H univ (push f p) = H univ p := by
  have h := H_sub_H_push f p
  rw [Finset.sum_congr rfl (fun u _ => D_fib_eq_zero_of_injective hf u p)] at h
  simp only [Finset.sum_const_zero] at h
  linarith

/-! ## Marginals of a coarsened joint weight -/

omit [Fintype α'] in
lemma marg1_pushFst (f : α → α') (p : α × β → ℝ) :
    marg1 (pushFst f p) = push f (marg1 p) := by
  funext u
  simp only [marg1, pushFst, push]
  rw [Finset.sum_comm]

omit [Fintype β] in
lemma marg2_pushFst (f : α → α') (p : α × β → ℝ) :
    marg2 (pushFst f p) = marg2 p := by
  funext y
  simp only [marg2, pushFst]
  exact Finset.sum_fiberwise (univ : Finset α) f (fun x => p (x, y))

/-- Joint version of `H_sub_H_push`: the entropy destroyed in the joint
distribution is the total deficit of the fibers, computed slice by slice. -/
theorem H_joint_sub (f : α → α') (p : α × β → ℝ) :
    H univ p - H univ (pushFst f p)
      = ∑ u : α', ∑ y : β, D (fib f u) (fun x => p (x, y)) := by
  have hp : H univ p = ∑ u : α', ∑ y : β, H (fib f u) (fun x => p (x, y)) := by
    have h1 : H (univ : Finset (α × β)) p = ∑ y : β, ∑ x : α, nlp (p (x, y)) := by
      simp only [H]
      rw [Fintype.sum_prod_type]
      exact Finset.sum_comm
    have h2 : ∀ y : β, ∑ x : α, nlp (p (x, y))
        = ∑ u : α', H (fib f u) (fun x => p (x, y)) := by
      intro y
      simpa [H, fib] using
        (Finset.sum_fiberwise (univ : Finset α) f (fun x => nlp (p (x, y)))).symm
    rw [h1, Finset.sum_congr rfl (fun y _ => h2 y), Finset.sum_comm]
  have hq : H univ (pushFst f p)
      = ∑ u : α', ∑ y : β, nlp (∑ x ∈ fib f u, p (x, y)) := by
    simp only [H, pushFst]
    rw [Fintype.sum_prod_type]
  rw [hp, hq, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun u _ => ?_
  rw [← Finset.sum_sub_distrib]
  rfl

/-! ## The two structural theorems -/

/-- **Encoding invariance.**  Any injective (i.e. width-valid) label encoding of
the first coordinate leaves the mutual information unchanged.  Consequently two
independent width-valid implementations must report the *same* joint value. -/
theorem MI_pushFst_eq_of_injective {f : α → α'} (hf : Function.Injective f)
    (p : α × β → ℝ) : MI (pushFst f p) = MI p := by
  have h1 : H univ (marg1 (pushFst f p)) = H univ (marg1 p) := by
    rw [marg1_pushFst, H_push_eq_of_injective hf]
  have h2 : H univ (marg2 (pushFst f p)) = H univ (marg2 p) := by
    rw [marg2_pushFst]
  have h3 : H univ (pushFst f p) = H univ p := by
    have h := H_joint_sub f p
    have hz : ∑ u : α', ∑ y : β, D (fib f u) (fun x => p (x, y)) = 0 :=
      Finset.sum_eq_zero fun u _ =>
        Finset.sum_eq_zero fun y _ => D_fib_eq_zero_of_injective hf u _
    rw [hz] at h
    linarith
  simp only [MI, h1, h2, h3]

/-- **Data-processing inequality for label coarsenings.**  An arbitrary (in
particular a collision-producing) label encoding can only *decrease* the
measured mutual information.  Collision artifacts are therefore one-sided. -/
theorem MI_pushFst_le {f : α → α'} {p : α × β → ℝ} (hp : ∀ q, 0 ≤ p q) :
    MI (pushFst f p) ≤ MI p := by
  have hmarg1 : H univ (marg1 (pushFst f p)) = H univ (push f (marg1 p)) := by
    rw [marg1_pushFst]
  have hmarg2 : H univ (marg2 (pushFst f p)) = H univ (marg2 p) := by
    rw [marg2_pushFst]
  have hjoint := H_joint_sub f p
  have hfirst := H_sub_H_push f (marg1 p)
  -- per-fiber concavity: the sliced deficits never exceed the marginal deficit
  have hkey : ∀ u : α', ∑ y : β, D (fib f u) (fun x => p (x, y))
      ≤ D (fib f u) (marg1 p) := by
    intro u
    have := D_superadditive (s := fib f u) (t := (univ : Finset β))
      (v := fun y x => p (x, y)) (fun y _ x _ => hp (x, y))
    simpa [marg1] using this
  have hsum : ∑ u : α', ∑ y : β, D (fib f u) (fun x => p (x, y))
      ≤ ∑ u : α', D (fib f u) (marg1 p) :=
    Finset.sum_le_sum fun u _ => hkey u
  simp only [MI, hmarg1, hmarg2]
  linarith

/-- **The reconciliation.**  On one and the same population, a width-valid
encoding reports the true joint value, and *any* other encoding reports at most
that value.  Hence when two runs disagree, the larger reading is the admissible
one and the smaller is the artifact. -/
theorem reconciliation {f g : α → α'} (hf : Function.Injective f)
    {p : α × β → ℝ} (hp : ∀ q, 0 ≤ p q) :
    MI (pushFst g p) ≤ MI (pushFst f p) := by
  rw [MI_pushFst_eq_of_injective hf]
  exact MI_pushFst_le hp

/-! ## Strictness on the audited `4 × 9` population -/

/-- The quantitative loss of a labelling: the deficit of a single fiber already
bounds the entropy drop. -/
theorem H_push_le_of_fiber (f : α → α') (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) (u : α') :
    H univ (push f p) ≤ H univ p - D (fib f u) p := by
  have h := H_sub_H_push f p
  have hrest : D (fib f u) p ≤ ∑ v : α', D (fib f v) p := by
    refine Finset.single_le_sum (f := fun v => D (fib f v) p) ?_ (Finset.mem_univ u)
    exact fun v _ => D_nonneg fun x _ => hp x
  linarith

section Audited

/-- The audited population: `4 × 9 = 36` code pairs. -/
abbrev Pop : Type := Fin 4 × Fin 9

/-- A width-valid chaining of the audited population (frame `9 ≥ 9`). -/
def encWide (q : Pop) : Fin 40 := ⟨9 * (q.1 : ℕ) + (q.2 : ℕ), by have := q.1.isLt; have := q.2.isLt; omega⟩

/-- The rebuild's narrow chaining of the same population (frame `3 < 9`). -/
def encNarrow (q : Pop) : Fin 40 := ⟨3 * (q.1 : ℕ) + (q.2 : ℕ), by have := q.1.isLt; have := q.2.isLt; omega⟩

/-- The uniform population weight. -/
noncomputable def unif : Pop → ℝ := fun _ => 1 / 36

lemma encWide_injective : Function.Injective encWide := by decide

lemma encNarrow_not_injective : ¬ Function.Injective encNarrow := by
  intro h
  have : ((0 : Fin 4), (3 : Fin 9)) = ((1 : Fin 4), (0 : Fin 9)) := h (by decide)
  exact absurd this (by decide)

/-- Uniform label entropy of the audited population is `log₂ 36` bits. -/
theorem entropy_unif : H (univ : Finset Pop) unif = Real.logb 2 36 := by
  have hcard : (Finset.univ : Finset Pop).card = 36 := by decide
  have hterm : ∀ q : Pop, nlp (unif q) = (1 / 36) * Real.logb 2 36 := by
    intro q
    have hlog : Real.logb 2 ((1:ℝ)/36) = - Real.logb 2 36 := by
      rw [one_div, Real.logb_inv]
    simp only [nlp, unif, hlog]
    ring
  rw [H, Finset.sum_congr rfl (fun q _ => hterm q), Finset.sum_const, hcard, nsmul_eq_mul]
  push_cast
  ring

/-- The `·3` frame merges the pairs `(0,3)` and `(1,0)`: both live in the fiber
over the label `3`. -/
lemma fiber_three_has_two :
    ((0 : Fin 4), (3 : Fin 9)) ∈ fib encNarrow ⟨3, by omega⟩ ∧
      ((1 : Fin 4), (0 : Fin 9)) ∈ fib encNarrow ⟨3, by omega⟩ := by
  constructor <;> decide

/-- **Strict loss on the audited population.**  Under the narrow `·3` frame the
label entropy of the uniform `4 × 9` population is strictly below `log₂ 36`,
with an explicit gap of at least `1/18` bit. -/
theorem narrow_frame_strictly_loses :
    H (univ : Finset (Fin 40)) (push encNarrow unif) ≤ Real.logb 2 36 - 1 / 18 := by
  have hnn : ∀ q : Pop, (0:ℝ) ≤ unif q := fun _ => by norm_num [unif]
  obtain ⟨hi, hj⟩ := fiber_three_has_two
  have hpos : (0:ℝ) < D (fib encNarrow ⟨3, by omega⟩) unif := by
    refine D_pos_of_two_positive (fun x _ => hnn x) hi hj (by decide) ?_ ?_ <;>
      norm_num [unif]
  -- quantitative form: the two merged atoms alone cost `2 · (1/36) · log₂ 2`
  have hbound : (1:ℝ)/18 ≤ D (fib encNarrow ⟨3, by omega⟩) unif := by
    classical
    rw [D_eq]
    set S := ∑ k ∈ fib encNarrow (⟨3, by omega⟩ : Fin 40), unif k with hS
    have hSge : (2:ℝ)/36 ≤ S := by
      have hpair : ((0 : Fin 4), (3 : Fin 9)) ≠ ((1 : Fin 4), (0 : Fin 9)) := by decide
      have : ∑ k ∈ ({((0 : Fin 4), (3 : Fin 9)), ((1 : Fin 4), (0 : Fin 9))} : Finset Pop),
          unif k ≤ S := by
        rw [hS]
        refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun k _ _ => hnn k)
        intro k hk
        simp only [Finset.mem_insert, Finset.mem_singleton] at hk
        rcases hk with rfl | rfl <;> assumption
      rw [Finset.sum_pair hpair] at this
      have hval : unif ((0 : Fin 4), (3 : Fin 9)) + unif ((1 : Fin 4), (0 : Fin 9))
          = (2:ℝ)/36 := by norm_num [unif]
      linarith [hval ▸ this]
    have hterms : ∀ k ∈ fib encNarrow (⟨3, by omega⟩ : Fin 40),
        (1/36 : ℝ) * (Real.logb 2 2) ≤ unif k * (Real.logb 2 S - Real.logb 2 (unif k)) := by
      intro k _
      have h1 : Real.logb 2 ((1:ℝ)/18) ≤ Real.logb 2 S :=
        Real.logb_le_logb_of_le (by norm_num) (by norm_num) (by linarith [hSge])
      have h2 : Real.logb 2 ((1:ℝ)/18) - Real.logb 2 ((1:ℝ)/36) = Real.logb 2 2 := by
        rw [show (1:ℝ)/18 = 2 * (1/36) by norm_num, Real.logb_mul (by norm_num) (by norm_num)]
        ring
      have : Real.logb 2 2 ≤ Real.logb 2 S - Real.logb 2 (unif k) := by
        simp only [unif]
        linarith
      calc (1/36 : ℝ) * Real.logb 2 2 ≤ (1/36 : ℝ) * (Real.logb 2 S - Real.logb 2 (unif k)) := by
            exact mul_le_mul_of_nonneg_left this (by norm_num)
        _ = unif k * (Real.logb 2 S - Real.logb 2 (unif k)) := by simp [unif]
    have hcard2 : 2 ≤ (fib encNarrow (⟨3, by omega⟩ : Fin 40)).card := by decide
    have hsum := Finset.sum_le_sum hterms
    rw [Finset.sum_const, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)] at hsum
    have : (2:ℝ) * (1/36) ≤ (fib encNarrow (⟨3, by omega⟩ : Fin 40)).card * ((1/36 : ℝ) * 1) := by
      have : (2:ℝ) ≤ ((fib encNarrow (⟨3, by omega⟩ : Fin 40)).card : ℝ) := by
        exact_mod_cast hcard2
      nlinarith
    simp only [nsmul_eq_mul] at hsum
    linarith
  have hle := H_push_le_of_fiber encNarrow unif hnn (⟨3, by omega⟩ : Fin 40)
  rw [entropy_unif] at hle
  linarith

/-- The width-valid frame, by contrast, preserves the full `log₂ 36` bits. -/
theorem wide_frame_preserves :
    H (univ : Finset (Fin 40)) (push encWide unif) = Real.logb 2 36 := by
  rw [H_push_eq_of_injective encWide_injective, entropy_unif]

/-- **THE-ORIGINAL-STANDS, quantitative form.**  On the audited population the
width-valid reading strictly exceeds the narrow-frame reading. -/
theorem original_stands :
    H (univ : Finset (Fin 40)) (push encNarrow unif)
      < H (univ : Finset (Fin 40)) (push encWide unif) := by
  have h1 := narrow_frame_strictly_loses
  rw [wide_frame_preserves]
  linarith

end Audited

end JointLabelReconciliation