/-
# Strict entropy deficit and a detection criterion for conditional artifacts

Fifth cycle on `Novelty.ConditionalLabelDPI`.  `Applications.LabelEntropyDeficit`
proves Gibbs' inequality (`kl_nonneg`) and superadditivity of the deficit
(`D_superadditive`) in *weak* form; `ConditionalArtifactAccounting` reduces
strictness of the conditional data-processing inequality to a single
fiber-local deficit gap.  This file supplies the missing analytic step:

* `gibbs_term_strict`, `kl_pos_of_ne` — the strict form of Gibbs' inequality;
  the relative entropy is *positive* as soon as the two weights differ at one
  point (with equal total mass and absolute continuity);
* `D_superadditive_strict` — the deficit is *strictly* superadditive unless
  every slice is proportional to the total, i.e. unless the block is a product;
* `CMI_lt_of_nonproduct_fiber` — **detection criterion**: if in some context a
  fiber of the merge fails to be a product (some cell deviates from the
  rank-one prediction), the merged conditional reading is *strictly* below the
  true one.  A collision is therefore invisible only when it collides dial
  settings that are conditionally exchangeable.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation
import Novelty.ConditionalLabelDPI
import Novelty.ConditionalArtifactAccounting

namespace StrictLabelDeficit

open Finset LabelEntropy JointLabelReconciliation ConditionalLabelDPI
open ConditionalArtifactAccounting

variable {ι κ : Type*}

/-! ## Strict Gibbs -/

/-- Strict form of the per-term Gibbs bound: the inequality of `gibbs_term` is
strict as soon as the two values differ. -/
lemma gibbs_term_strict {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hac : b = 0 → a = 0)
    (hne : a ≠ b) : (a - b) / Real.log 2 < a * (Real.logb 2 a - Real.logb 2 b) := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le ha with h0 | hapos
  · -- `a = 0`, hence `b > 0`
    have hbpos : 0 < b := by
      rcases eq_or_lt_of_le hb with hb0 | hbp
      · exact absurd ((hac hb0.symm).trans hb0) hne
      · exact hbp
    have : (0 - b) / Real.log 2 < 0 := div_neg_of_neg_of_pos (by linarith) hlog2
    simpa [← h0] using this
  · have hbpos : 0 < b := by
      rcases eq_or_lt_of_le hb with hb0 | hbp
      · exact absurd (hac hb0.symm) (by linarith)
      · exact hbp
    have hdivne : b / a ≠ 1 := by
      intro h
      exact hne (by field_simp at h; linarith)
    have hlog : Real.log (b / a) < b / a - 1 :=
      Real.log_lt_sub_one_of_pos (div_pos hbpos hapos) hdivne
    have hsplit : Real.log (b / a) = Real.log b - Real.log a :=
      Real.log_div (ne_of_gt hbpos) (ne_of_gt hapos)
    have key : 1 - b / a < Real.log a - Real.log b := by
      rw [hsplit] at hlog; linarith
    have hmul : a * (1 - b / a) < a * (Real.log a - Real.log b) :=
      mul_lt_mul_of_pos_left key hapos
    have hcancel : a * (1 - b / a) = a - b := by field_simp
    have hrw : a * (Real.logb 2 a - Real.logb 2 b)
        = (a * (Real.log a - Real.log b)) / Real.log 2 := by
      simp only [Real.logb]
      ring
    rw [hrw]
    refine (div_lt_div_iff_of_pos_right hlog2).mpr ?_
    linarith [hcancel ▸ hmul]

/-- **Strict Gibbs' inequality.**  With equal total mass and absolute
continuity, the relative entropy is strictly positive as soon as the weights
differ at a single point. -/
theorem kl_pos_of_ne {s : Finset ι} {a b : ι → ℝ}
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 ≤ b i)
    (hac : ∀ i ∈ s, b i = 0 → a i = 0)
    (hsum : ∑ i ∈ s, b i = ∑ i ∈ s, a i)
    {i₀ : ι} (hi₀ : i₀ ∈ s) (hne : a i₀ ≠ b i₀) :
    0 < ∑ i ∈ s, a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hterm : ∀ i ∈ s, (a i - b i) / Real.log 2
      ≤ a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) :=
    fun i hi => gibbs_term (ha i hi) (hb i hi) (hac i hi)
  have hstrict : (a i₀ - b i₀) / Real.log 2
      < a i₀ * (Real.logb 2 (a i₀) - Real.logb 2 (b i₀)) :=
    gibbs_term_strict (ha i₀ hi₀) (hb i₀ hi₀) (hac i₀ hi₀) hne
  have h1 : ∑ i ∈ s, (a i - b i) / Real.log 2
      < ∑ i ∈ s, a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) :=
    Finset.sum_lt_sum hterm ⟨i₀, hi₀, hstrict⟩
  have h2 : ∑ i ∈ s, (a i - b i) / Real.log 2 = 0 := by
    rw [← Finset.sum_div, Finset.sum_sub_distrib, hsum]
    simp
  linarith

/-! ## Strict superadditivity of the deficit -/

/-- Strict form of `kl_fiber_nonneg`: if the sub-block `v` is not the rank-one
prediction `w · V / W` at some point, the fiber estimate is strict. -/
lemma kl_fiber_pos {s : Finset ι} {v w : ι → ℝ}
    (hv : ∀ x ∈ s, 0 ≤ v x) (hvw : ∀ x ∈ s, v x ≤ w x)
    (hWpos : 0 < ∑ x ∈ s, w x)
    {x₀ : ι} (hx₀ : x₀ ∈ s)
    (hne : v x₀ ≠ w x₀ * (∑ y ∈ s, v y) / (∑ y ∈ s, w y)) :
    0 < ∑ x ∈ s, v x *
      ((Real.logb 2 (∑ y ∈ s, w y) - Real.logb 2 (w x))
        - (Real.logb 2 (∑ y ∈ s, v y) - Real.logb 2 (v x))) := by
  set W := ∑ y ∈ s, w y with hW
  set V := ∑ y ∈ s, v y with hV
  have hw : ∀ x ∈ s, 0 ≤ w x := fun x hx => le_trans (hv x hx) (hvw x hx)
  have hVnonneg : 0 ≤ V := Finset.sum_nonneg hv
  set b : ι → ℝ := fun x => w x * V / W with hbdef
  have hbnonneg : ∀ x ∈ s, 0 ≤ b x := fun x hx =>
    div_nonneg (mul_nonneg (hw x hx) hVnonneg) hWpos.le
  have hbsum : ∑ x ∈ s, b x = V := by
    simp only [hbdef]
    rw [← Finset.sum_div, ← Finset.sum_mul, ← hW]
    field_simp
  have hac : ∀ x ∈ s, b x = 0 → v x = 0 := by
    intro x hx hbx
    simp only [hbdef, div_eq_zero_iff] at hbx
    rcases hbx with h | h
    · rcases mul_eq_zero.mp h with hwx | hVzero
      · exact le_antisymm (by rw [← hwx]; exact hvw x hx) (hv x hx)
      · have : ∀ y ∈ s, v y = 0 :=
          (Finset.sum_eq_zero_iff_of_nonneg hv).mp (hV ▸ hVzero)
        exact this x hx
    · exact absurd h (ne_of_gt hWpos)
  have hkl := kl_pos_of_ne (a := v) (b := b) hv hbnonneg hac (by rw [hbsum]) hx₀ hne
  refine lt_of_lt_of_le hkl (le_of_eq (Finset.sum_congr rfl fun x hx => ?_))
  rcases eq_or_lt_of_le (hv x hx) with h0 | hpos
  · simp [← h0]
  · have hwx : 0 < w x := lt_of_lt_of_le hpos (hvw x hx)
    have hVpos : 0 < V := lt_of_lt_of_le hpos (hV ▸ Finset.single_le_sum hv hx)
    have hbx : b x = w x * V / W := rfl
    have : Real.logb 2 (b x) = Real.logb 2 (w x) + Real.logb 2 V - Real.logb 2 W := by
      rw [hbx, Real.logb_div (by positivity) (ne_of_gt hWpos),
        Real.logb_mul (ne_of_gt hwx) (ne_of_gt hVpos)]
    rw [this]
    ring

/-- **Strict superadditivity of the deficit.**  Splitting a nonnegative weight
vector into slices strictly lowers the total deficit unless every slice is the
rank-one prediction; one deviating cell suffices. -/
theorem D_superadditive_strict {s : Finset ι} {t : Finset κ} {v : κ → ι → ℝ}
    (hv : ∀ y ∈ t, ∀ x ∈ s, 0 ≤ v y x)
    (hWpos : 0 < ∑ x ∈ s, ∑ y ∈ t, v y x)
    {y₀ : κ} (hy₀ : y₀ ∈ t) {x₀ : ι} (hx₀ : x₀ ∈ s)
    (hne : v y₀ x₀ ≠ (∑ y ∈ t, v y x₀) * (∑ x ∈ s, v y₀ x) / (∑ x ∈ s, ∑ y ∈ t, v y x)) :
    ∑ y ∈ t, D s (v y) < D s (fun x => ∑ y ∈ t, v y x) := by
  set w : ι → ℝ := fun x => ∑ y ∈ t, v y x with hwdef
  have hw : ∀ x ∈ s, 0 ≤ w x := fun x hx => Finset.sum_nonneg fun y hy => hv y hy x hx
  have hvw : ∀ y ∈ t, ∀ x ∈ s, v y x ≤ w x := fun y hy x hx =>
    Finset.single_le_sum (f := fun y => v y x) (fun z hz => hv z hz x hx) hy
  have hLHS : ∑ y ∈ t, D s (v y)
      = ∑ y ∈ t, ∑ x ∈ s, v y x *
          (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)) :=
    Finset.sum_congr rfl fun y _ => D_eq s (v y)
  have hRHS : D s w = ∑ y ∈ t, ∑ x ∈ s, v y x *
      (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)) := by
    rw [D_eq]
    conv_rhs => rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [hwdef, Finset.sum_mul]
  rw [hLHS, hRHS]
  refine Finset.sum_lt_sum (fun y hy => ?_) ⟨y₀, hy₀, ?_⟩
  · have hnn := kl_fiber_nonneg (s := s) (v := v y) (w := w)
      (fun x hx => hv y hy x hx) (fun x hx => hvw y hy x hx) hWpos
    have hsplit : ∑ x ∈ s, v y x *
        ((Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x))
          - (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)))
        = (∑ x ∈ s, v y x * (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)))
            - ∑ x ∈ s, v y x * (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun x _ => by ring
    rw [hsplit] at hnn
    linarith
  · have hpos := kl_fiber_pos (s := s) (v := v y₀) (w := w)
      (fun x hx => hv y₀ hy₀ x hx) (fun x hx => hvw y₀ hy₀ x hx) hWpos hx₀ hne
    have hsplit : ∑ x ∈ s, v y₀ x *
        ((Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x))
          - (Real.logb 2 (∑ z ∈ s, v y₀ z) - Real.logb 2 (v y₀ x)))
        = (∑ x ∈ s, v y₀ x * (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)))
            - ∑ x ∈ s, v y₀ x * (Real.logb 2 (∑ z ∈ s, v y₀ z) - Real.logb 2 (v y₀ x)) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun x _ => by ring
    rw [hsplit] at hpos
    linarith

/-- A block of zero weight has zero deficit. -/
lemma D_eq_zero_of_all_zero {s : Finset ι} {w : ι → ℝ} (h : ∀ x ∈ s, w x = 0) :
    D s w = 0 := by
  have h1 : H s w = 0 := Finset.sum_eq_zero fun x hx => by rw [h x hx, nlp_zero]
  have h2 : ∑ x ∈ s, w x = 0 := Finset.sum_eq_zero h
  simp [D, h1, h2]

/-- **Equality case of superadditivity.**  If every slice is exactly the
rank-one prediction, slicing loses no deficit at all. -/
theorem D_superadditive_eq_of_product {s : Finset ι} {t : Finset κ} {v : κ → ι → ℝ}
    (hv : ∀ y ∈ t, ∀ x ∈ s, 0 ≤ v y x)
    (hWpos : 0 < ∑ x ∈ s, ∑ y ∈ t, v y x)
    (hprod : ∀ y ∈ t, ∀ x ∈ s,
      v y x = (∑ y' ∈ t, v y' x) * (∑ x' ∈ s, v y x') / (∑ x' ∈ s, ∑ y' ∈ t, v y' x')) :
    ∑ y ∈ t, D s (v y) = D s (fun x => ∑ y ∈ t, v y x) := by
  set w : ι → ℝ := fun x => ∑ y ∈ t, v y x with hwdef
  have hw : ∀ x ∈ s, 0 ≤ w x := fun x hx => Finset.sum_nonneg fun y hy => hv y hy x hx
  have hLHS : ∑ y ∈ t, D s (v y)
      = ∑ y ∈ t, ∑ x ∈ s, v y x *
          (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)) :=
    Finset.sum_congr rfl fun y _ => D_eq s (v y)
  have hRHS : D s w = ∑ y ∈ t, ∑ x ∈ s, v y x *
      (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)) := by
    rw [D_eq]
    conv_rhs => rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [hwdef, Finset.sum_mul]
  rw [hLHS, hRHS]
  refine Finset.sum_congr rfl fun y hy => Finset.sum_congr rfl fun x hx => ?_
  rcases eq_or_lt_of_le (hv y hy x hx) with h0 | hpos
  · simp [← h0]
  · have hprodx := hprod y hy x hx
    have hWne : (∑ x' ∈ s, w x') ≠ 0 := ne_of_gt hWpos
    have hwx : 0 < w x :=
      lt_of_lt_of_le hpos
        (Finset.single_le_sum (f := fun y => v y x) (fun z hz => hv z hz x hx) hy)
    have hVpos : 0 < ∑ x' ∈ s, v y x' :=
      lt_of_lt_of_le hpos
        (Finset.single_le_sum (f := fun x' => v y x') (fun x' hx' => hv y hy x' hx') hx)
    have hlog : Real.logb 2 (v y x)
        = Real.logb 2 (w x) + Real.logb 2 (∑ x' ∈ s, v y x') - Real.logb 2 (∑ x' ∈ s, w x') := by
      rw [hprodx, Real.logb_div (by positivity) hWne,
        Real.logb_mul (ne_of_gt hwx) (ne_of_gt hVpos)]
    rw [hlog]
    ring

/-! ## The detection criterion -/

variable {α β γ α' : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype α']
  [DecidableEq α']

/-- **Detection criterion for conditional artifacts.**  If in some context `z`
some fiber of the merge is not a product table — one cell `(x₀, y₀)` deviates
from the rank-one prediction built from its row and column sums — then the
merged conditional reading is *strictly* below the true one.  Equivalently: a
collision is invisible to `I(·;Y|Z)` only when it merges dial settings that are
conditionally exchangeable. -/
theorem CMI_lt_of_nonproduct_fiber (f : α → α') {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i)
    (z : γ) (u : α')
    (hWpos : 0 < ∑ x ∈ fib f u, marg1 (slice p z) x)
    {y₀ : β} {x₀ : α} (hx₀ : x₀ ∈ fib f u)
    (hne : slice p z (x₀, y₀) ≠ marg1 (slice p z) x₀ * (∑ x ∈ fib f u, slice p z (x, y₀))
      / (∑ x ∈ fib f u, marg1 (slice p z) x)) :
    CMI (pushFst3 f p) < CMI p := by
  refine CMI_lt_of_fiber_gap f hp (z := z) (u := u) ?_
  have hstrict := D_superadditive_strict (s := fib f u) (t := (univ : Finset β))
    (v := fun y x => slice p z (x, y)) (fun y _ x _ => hp _)
    (by simpa [marg1] using hWpos) (mem_univ y₀) hx₀ (by simpa [marg1] using hne)
  simpa [marg1] using hstrict

/-- **Classification of invisible collisions.**  A merged conditional reading
is exact *if and only if* every fiber of the merge is a product table in every
context that gives it positive mass.  Combined with `CMI_pushFst3_le` this is a
complete description of the artifact: the reading drops, and it drops strictly,
exactly when some fiber fails conditional exchangeability. -/
theorem CMI_eq_iff_fibers_product (f : α → α') {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 f p) = CMI p ↔
      ∀ (z : γ) (u : α'), 0 < ∑ x ∈ fib f u, marg1 (slice p z) x →
        ∀ (y : β), ∀ x ∈ fib f u,
          slice p z (x, y) = marg1 (slice p z) x * (∑ x' ∈ fib f u, slice p z (x', y))
            / (∑ x' ∈ fib f u, marg1 (slice p z) x') := by
  constructor
  · intro heq z u hWpos y x hx
    by_contra hne
    exact absurd heq (ne_of_lt (CMI_lt_of_nonproduct_fiber f hp z u hWpos hx hne))
  · intro hprod
    refine (CMI_eq_iff_fiberwise_tight f hp).mpr fun z u => ?_
    have hnn : ∀ x ∈ fib f u, 0 ≤ marg1 (slice p z) x :=
      fun x _ => Finset.sum_nonneg fun y _ => hp _
    rcases eq_or_lt_of_le (Finset.sum_nonneg hnn) with hW0 | hWpos
    · -- the fiber is empty of mass: both sides vanish
      have hzero : ∀ x ∈ fib f u, marg1 (slice p z) x = 0 :=
        (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hW0.symm
      have hcell : ∀ (y : β), ∀ x ∈ fib f u, slice p z (x, y) = 0 := by
        intro y x hx
        have hle : slice p z (x, y) ≤ marg1 (slice p z) x :=
          Finset.single_le_sum (f := fun y => slice p z (x, y)) (fun y _ => hp _) (mem_univ y)
        have hz0 := hzero x hx
        have hnn0 : 0 ≤ slice p z (x, y) := hp _
        linarith [hz0 ▸ hle]
      rw [D_eq_zero_of_all_zero hzero]
      exact Finset.sum_eq_zero fun y _ => D_eq_zero_of_all_zero (hcell y)
    · have hWpos' : 0 < ∑ x ∈ fib f u, ∑ y : β, slice p z (x, y) := by
        simpa [marg1] using hWpos
      have := D_superadditive_eq_of_product (s := fib f u) (t := (univ : Finset β))
        (v := fun y x => slice p z (x, y)) (fun y _ x _ => hp _) hWpos'
        (fun y _ x hx => by simpa [marg1] using hprod z u hWpos y x hx)
      simpa [marg1] using this

end StrictLabelDeficit