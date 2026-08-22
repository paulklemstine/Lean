/-
# Recursive Bresenham trees: logarithmic-discrepancy fair schedules

`Novelty.FairSchedulePrefixBatches` shows that the prefix-sum block schedule realises the
exact rates once per period but can be `Θ(R)` services away from the ideal share in between,
while for two clients the Bresenham (Beatty) schedule stays within one unit.  This file
combines the two ideas.

A `STree` is a binary *splitting tree*: leaves carry a client label together with its rate,
and each internal node splits the slot stream between its two subtrees using the two-client
Bresenham schedule of the subtree weights.  `STree.sched` is the resulting recursive
schedule, and the main theorem

  `STree.tree_disc : |wt T * schedCnt (sched T) i t - rate T i * t| ≤ wt T * depth T`

says that *each splitting level costs at most one unit of discrepancy* — the bound depends
only on the shape of the tree and never on the rates.  Applied to the perfectly balanced
tree over `2 ^ d` clients (`STree.perfect_isFair`) it yields, for **arbitrary positive rate
profiles**, a schedule whose normalised discrepancy never exceeds `d = log₂ k`.
-/
import Novelty.FairSchedulePrefixBatches

namespace FairSchedule

open Finset

/-- A binary splitting tree over labelled clients: each leaf carries a client label and its
rate, each node splits the stream between its two subtrees. -/
inductive STree where
  | leaf : ℕ → ℕ → STree
  | node : STree → STree → STree
  deriving Inhabited

namespace STree

/-- Total rate of a subtree. -/
def wt : STree → ℕ
  | leaf _ w => w
  | node l r => wt l + wt r

/-- Depth of the splitting tree (a leaf has depth `0`). -/
def depth : STree → ℕ
  | leaf _ _ => 0
  | node l r => max (depth l) (depth r) + 1

/-- The set of client labels appearing in the tree. -/
def labels : STree → Finset ℕ
  | leaf i _ => {i}
  | node l r => labels l ∪ labels r

/-- Rate of a given client label inside the tree. -/
def rate : STree → ℕ → ℕ
  | leaf i w => fun j => if j = i then w else 0
  | node l r => fun j => rate l j + rate r j

/-- Well-formedness: positive leaf rates and pairwise distinct labels. -/
def WF : STree → Prop
  | leaf _ w => 0 < w
  | node l r => WF l ∧ WF r ∧ Disjoint (labels l) (labels r)

/-- The recursive Bresenham schedule of a splitting tree: at each node the stream is split
between the two subtrees by the two-client Bresenham schedule, and each subtree is served
according to its own recursive schedule. -/
def sched : STree → ℕ → ℕ
  | leaf i _ => fun _ => i
  | node l r => fun t =>
      if bres (wt l) (wt l + wt r) t = 0
      then sched l (t * wt l / (wt l + wt r))
      else sched r (t - t * wt l / (wt l + wt r))

lemma wt_pos {T : STree} (h : WF T) : 0 < wt T := by
  induction T with
  | leaf i w => exact h
  | node l r ihl ihr =>
      obtain ⟨hl, hr, -⟩ := h
      have := ihl hl
      have := ihr hr
      simp only [wt]
      omega

lemma sched_mem_labels (T : STree) (t : ℕ) : sched T t ∈ labels T := by
  induction T generalizing t with
  | leaf i w => simp [sched, labels]
  | node l r ihl ihr =>
      simp only [sched, labels, Finset.mem_union]
      split
      · exact Or.inl (ihl _)
      · exact Or.inr (ihr _)

lemma rate_eq_zero_of_notMem {T : STree} {i : ℕ} (h : i ∉ labels T) : rate T i = 0 := by
  induction T with
  | leaf j w =>
      simp only [labels, Finset.mem_singleton] at h
      simp [rate, h]
  | node l r ihl ihr =>
      simp only [labels, Finset.mem_union, not_or] at h
      simp [rate, ihl h.1, ihr h.2]

lemma rate_le_wt (T : STree) (i : ℕ) : rate T i ≤ wt T := by
  induction T with
  | leaf j w => by_cases h : i = j <;> simp [rate, wt, h]
  | node l r ihl ihr =>
      simp only [rate, wt]
      exact Nat.add_le_add ihl ihr

lemma schedCnt_eq_zero_of_notMem {T : STree} {i : ℕ} (h : i ∉ labels T) (t : ℕ) :
    schedCnt (sched T) i t = 0 := by
  unfold schedCnt
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro x _ hx
  exact h (hx ▸ sched_mem_labels T x)

/-! ## Restriction of the node schedule to a subtree -/

lemma schedCnt_node_left {l r : STree} {i : ℕ} (hw : 0 < wt l + wt r)
    (hi : i ∈ labels l) (hdisj : Disjoint (labels l) (labels r)) (t : ℕ) :
    schedCnt (sched (node l r)) i t = schedCnt (sched l) i (t * wt l / (wt l + wt r)) := by
  have hle : wt l ≤ wt l + wt r := Nat.le_add_right _ _
  have hnotr : i ∉ labels r := Finset.disjoint_left.mp hdisj hi
  induction t with
  | zero => simp [schedCnt]
  | succ t ih =>
      have hm : schedCnt (bres (wt l) (wt l + wt r)) 0 t = t * wt l / (wt l + wt r) :=
        bres_cnt0 hle hw t
      have hm1 : schedCnt (bres (wt l) (wt l + wt r)) 0 (t + 1)
          = (t + 1) * wt l / (wt l + wt r) := bres_cnt0 hle hw (t + 1)
      have hstep := schedCnt_succ (bres (wt l) (wt l + wt r)) 0 t
      rw [hm, hm1] at hstep
      rw [schedCnt_succ, ih]
      by_cases hb : bres (wt l) (wt l + wt r) t = 0
      · have hidx : (t + 1) * wt l / (wt l + wt r) = t * wt l / (wt l + wt r) + 1 := by
          rw [hb] at hstep; simpa using hstep
        rw [hidx, schedCnt_succ]
        congr 1
        simp [sched, hb]
      · have hb1 : bres (wt l) (wt l + wt r) t = 1 := by
          rcases bres_eq_zero_or_one (wt l) (wt l + wt r) t with h | h
          · exact absurd h hb
          · exact h
        have hidx : (t + 1) * wt l / (wt l + wt r) = t * wt l / (wt l + wt r) := by
          rw [hb1] at hstep; simpa using hstep
        rw [hidx]
        have hne : sched (node l r) t ≠ i := by
          simp only [sched, hb1]
          simp only [one_ne_zero, if_false]
          intro hcon
          exact hnotr (hcon ▸ sched_mem_labels r _)
        rw [if_neg hne, Nat.add_zero]

lemma schedCnt_node_right {l r : STree} {i : ℕ} (hw : 0 < wt l + wt r)
    (hi : i ∈ labels r) (hdisj : Disjoint (labels l) (labels r)) (t : ℕ) :
    schedCnt (sched (node l r)) i t = schedCnt (sched r) i (t - t * wt l / (wt l + wt r)) := by
  have hle : wt l ≤ wt l + wt r := Nat.le_add_right _ _
  have hnotl : i ∉ labels l := Finset.disjoint_right.mp hdisj hi
  induction t with
  | zero => simp [schedCnt]
  | succ t ih =>
      have hm : schedCnt (bres (wt l) (wt l + wt r)) 1 t = t - t * wt l / (wt l + wt r) :=
        bres_cnt1 hle hw t
      have hm1 : schedCnt (bres (wt l) (wt l + wt r)) 1 (t + 1)
          = (t + 1) - (t + 1) * wt l / (wt l + wt r) := bres_cnt1 hle hw (t + 1)
      have hstep := schedCnt_succ (bres (wt l) (wt l + wt r)) 1 t
      rw [hm, hm1] at hstep
      rw [schedCnt_succ, ih]
      by_cases hb : bres (wt l) (wt l + wt r) t = 0
      · have hidx : (t + 1) - (t + 1) * wt l / (wt l + wt r) = t - t * wt l / (wt l + wt r) := by
          rw [hb] at hstep; simpa using hstep
        rw [hidx]
        have hne : sched (node l r) t ≠ i := by
          simp only [sched, hb, if_true]
          intro hcon
          exact hnotl (hcon ▸ sched_mem_labels l _)
        rw [if_neg hne, Nat.add_zero]
      · have hb1 : bres (wt l) (wt l + wt r) t = 1 := by
          rcases bres_eq_zero_or_one (wt l) (wt l + wt r) t with h | h
          · exact absurd h hb
          · exact h
        have hidx : (t + 1) - (t + 1) * wt l / (wt l + wt r)
            = (t - t * wt l / (wt l + wt r)) + 1 := by
          rw [hb1] at hstep; simpa using hstep
        rw [hidx, schedCnt_succ]
        congr 1
        simp only [sched, hb1]
        simp

/-! ## Logarithmic discrepancy of the recursive Bresenham schedule -/

lemma schedCnt_const (j i t : ℕ) : schedCnt (fun _ => j) i t = if i = j then t else 0 := by
  induction t with
  | zero => simp [schedCnt]
  | succ t ih =>
      rw [schedCnt_succ, ih]
      by_cases h : i = j
      · subst h; simp
      · rw [if_neg h, if_neg h, if_neg (Ne.symm h)]

/-- Arithmetic core of the recursion: one splitting level costs at most one extra unit of
discrepancy, whatever the weights. -/
lemma refine_core {A W w c m t dsub d : ℤ} (hA : 0 < A) (hW : 0 < W) (hw0 : 0 ≤ w)
    (hwA : w ≤ A) (hd : dsub + 1 ≤ d)
    (hgap1 : -W < A * t - W * m) (hgap2 : A * t - W * m < W)
    (hIH1 : -(A * dsub) ≤ A * c - w * m) (hIH2 : A * c - w * m ≤ A * dsub) :
    |W * c - w * t| ≤ W * d := by
  have key : A * (W * c - w * t) = W * (A * c - w * m) - w * (A * t - W * m) := by ring
  have h1 : W * (A * c - w * m) ≤ W * (A * dsub) := by nlinarith
  have h2 : -(W * (A * dsub)) ≤ W * (A * c - w * m) := by nlinarith
  have h3 : w * (A * t - W * m) ≤ w * W := by nlinarith
  have h4 : -(w * W) ≤ w * (A * t - W * m) := by nlinarith
  have h5 : w * W ≤ A * W := by nlinarith
  have h6 : A * W * (dsub + 1) ≤ A * W * d := by nlinarith
  have hupper : A * (W * c - w * t) ≤ A * (W * d) := by nlinarith
  have hlower : A * (-(W * d)) ≤ A * (W * c - w * t) := by nlinarith
  exact abs_le.mpr ⟨le_of_mul_le_mul_left hlower hA, le_of_mul_le_mul_left hupper hA⟩

/-- **Main theorem.**  The recursive Bresenham schedule of a well-formed splitting tree keeps
every client within `depth T` services of its ideal share — a bound that depends only on the
shape of the tree, never on the rates. -/
theorem tree_disc {T : STree} (hT : WF T) (i t : ℕ) :
    |(wt T : ℤ) * schedCnt (sched T) i t - (rate T i : ℤ) * t| ≤ (wt T : ℤ) * (depth T : ℤ) := by
  induction T generalizing i t with
  | leaf j w =>
      rw [show sched (leaf j w) = (fun _ => j) from rfl, schedCnt_const]
      by_cases h : i = j
      · simp [h, rate, wt, depth]
      · simp [h, rate, wt, depth]
  | node l r ihl ihr =>
      obtain ⟨hl, hr, hdisj⟩ := hT
      have hAp : 0 < wt l := wt_pos hl
      have hBp : 0 < wt r := wt_pos hr
      have hw : 0 < wt l + wt r := by omega
      have hle : wt l ≤ wt l + wt r := Nat.le_add_right _ _
      have hdm : (wt l + wt r) * (t * wt l / (wt l + wt r)) + (t * wt l) % (wt l + wt r)
          = t * wt l := Nat.div_add_mod _ _
      have hmodlt : (t * wt l) % (wt l + wt r) < wt l + wt r := Nat.mod_lt _ hw
      have hmt : t * wt l / (wt l + wt r) ≤ t := by
        calc t * wt l / (wt l + wt r) ≤ t * (wt l + wt r) / (wt l + wt r) :=
              Nat.div_le_div_right (Nat.mul_le_mul_left t hle)
          _ = t := by rw [Nat.mul_div_cancel _ hw]
      have hA : (0:ℤ) < (wt l : ℤ) := by exact_mod_cast hAp
      have hB : (0:ℤ) < (wt r : ℤ) := by exact_mod_cast hBp
      have hW : (0:ℤ) < ((wt l : ℤ) + wt r) := by linarith
      have hb1n : (wt l + wt r) * (t * wt l / (wt l + wt r)) ≤ t * wt l := by omega
      have hb2n : t * wt l < (wt l + wt r) * (t * wt l / (wt l + wt r)) + (wt l + wt r) := by
        omega
      have hb1 : ((wt l : ℤ) + wt r) * ((t * wt l / (wt l + wt r) : ℕ) : ℤ)
          ≤ (t : ℤ) * (wt l : ℤ) := by exact_mod_cast hb1n
      have hb2 : (t : ℤ) * (wt l : ℤ)
          < ((wt l : ℤ) + wt r) * ((t * wt l / (wt l + wt r) : ℕ) : ℤ) + ((wt l : ℤ) + wt r) := by
        exact_mod_cast hb2n
      have hwt : ((wt (node l r) : ℕ) : ℤ) = (wt l : ℤ) + (wt r : ℤ) := by simp [wt]
      have hdl : (depth l : ℤ) + 1 ≤ (depth (node l r) : ℤ) := by
        have : depth l ≤ max (depth l) (depth r) := le_max_left _ _
        simp only [depth]
        push_cast
        omega
      have hdr : (depth r : ℤ) + 1 ≤ (depth (node l r) : ℤ) := by
        have : depth r ≤ max (depth l) (depth r) := le_max_right _ _
        simp only [depth]
        push_cast
        omega
      by_cases hi : i ∈ labels l
      · have hnr : rate r i = 0 := rate_eq_zero_of_notMem (Finset.disjoint_left.mp hdisj hi)
        have hrate : rate (node l r) i = rate l i := by simp [rate, hnr]
        have hIH := ihl hl i (t * wt l / (wt l + wt r))
        rw [abs_le] at hIH
        have hwA : ((rate l i : ℕ) : ℤ) ≤ (wt l : ℤ) := by exact_mod_cast rate_le_wt l i
        have hw0 : (0:ℤ) ≤ ((rate l i : ℕ) : ℤ) := Int.natCast_nonneg _
        rw [schedCnt_node_left hw hi hdisj, hrate, hwt]
        exact refine_core hA hW hw0 hwA hdl (by linarith) (by linarith) hIH.1 hIH.2
      · by_cases hir : i ∈ labels r
        · have hnl : rate l i = 0 := rate_eq_zero_of_notMem hi
          have hrate : rate (node l r) i = rate r i := by simp [rate, hnl]
          have hIH := ihr hr i (t - t * wt l / (wt l + wt r))
          rw [abs_le] at hIH
          have hwB : ((rate r i : ℕ) : ℤ) ≤ (wt r : ℤ) := by exact_mod_cast rate_le_wt r i
          have hw0 : (0:ℤ) ≤ ((rate r i : ℕ) : ℤ) := Int.natCast_nonneg _
          have hcast : ((t - t * wt l / (wt l + wt r) : ℕ) : ℤ)
              = (t : ℤ) - ((t * wt l / (wt l + wt r) : ℕ) : ℤ) := by
            push_cast [Nat.cast_sub hmt]
            ring
          rw [hcast] at hIH
          rw [schedCnt_node_right hw hir hdisj, hrate, hwt]
          exact refine_core hB hW hw0 hwB hdr (by linarith) (by linarith) hIH.1 hIH.2
        · have hnot : i ∉ labels (node l r) := by
            simp only [labels, Finset.mem_union]
            tauto
          rw [schedCnt_eq_zero_of_notMem hnot, rate_eq_zero_of_notMem hnot]
          simp
          positivity

/-! ## Perfectly balanced trees: logarithmic discrepancy for any rate profile -/

/-- The perfectly balanced splitting tree over the `2 ^ d` clients `base, …, base + 2^d - 1`. -/
def perfect (w : ℕ → ℕ) : ℕ → ℕ → STree
  | 0, base => leaf base (w base)
  | d + 1, base => node (perfect w d base) (perfect w d (base + 2 ^ d))

lemma depth_perfect (w : ℕ → ℕ) (d base : ℕ) : depth (perfect w d base) = d := by
  induction d generalizing base with
  | zero => simp [perfect, depth]
  | succ d ih => simp [perfect, depth, ih]

lemma labels_perfect (w : ℕ → ℕ) (d base : ℕ) :
    labels (perfect w d base) = Finset.Ico base (base + 2 ^ d) := by
  induction d generalizing base with
  | zero =>
      ext x
      simp [perfect, labels]
  | succ d ih =>
      have hp : 0 < (2:ℕ) ^ d := Nat.two_pow_pos d
      have hpow : (2:ℕ) ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; ring
      simp only [perfect, labels, ih]
      rw [show base + 2 ^ (d + 1) = base + 2 ^ d + 2 ^ d by omega]
      exact Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)

lemma wt_perfect (w : ℕ → ℕ) (d base : ℕ) :
    wt (perfect w d base) = ∑ j ∈ Finset.Ico base (base + 2 ^ d), w j := by
  induction d generalizing base with
  | zero => simp [perfect, wt]
  | succ d ih =>
      have hp : 0 < (2:ℕ) ^ d := Nat.two_pow_pos d
      have hpow : (2:ℕ) ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; ring
      simp only [perfect, wt, ih]
      rw [show base + 2 ^ (d + 1) = base + 2 ^ d + 2 ^ d by omega,
        ← Finset.sum_union (Finset.Ico_disjoint_Ico_consecutive _ _ _),
        Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)]

lemma rate_perfect (w : ℕ → ℕ) (d base i : ℕ) :
    rate (perfect w d base) i = if i ∈ Finset.Ico base (base + 2 ^ d) then w i else 0 := by
  induction d generalizing base with
  | zero =>
      by_cases h : i = base
      · simp [perfect, rate, h]
      · simp [perfect, rate, h]
  | succ d ih =>
      have hp : 0 < (2:ℕ) ^ d := Nat.two_pow_pos d
      have hpow : (2:ℕ) ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; ring
      simp only [perfect, rate, ih, Finset.mem_Ico]
      by_cases h1 : base ≤ i ∧ i < base + 2 ^ d
      · rw [if_pos h1, if_neg (by omega), if_pos (by omega)]
        omega
      · by_cases h2 : base + 2 ^ d ≤ i ∧ i < base + 2 ^ d + 2 ^ d
        · rw [if_neg h1, if_pos h2, if_pos (by omega)]
          omega
        · rw [if_neg h1, if_neg h2, if_neg (by omega)]

lemma WF_perfect {w : ℕ → ℕ} {d base : ℕ}
    (hpos : ∀ j ∈ Finset.Ico base (base + 2 ^ d), 0 < w j) : WF (perfect w d base) := by
  induction d generalizing base with
  | zero =>
      have : base ∈ Finset.Ico base (base + 2 ^ 0) := by simp
      exact hpos base this
  | succ d ih =>
      have hp : 0 < (2:ℕ) ^ d := Nat.two_pow_pos d
      have hpow : (2:ℕ) ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; ring
      refine ⟨ih ?_, ih ?_, ?_⟩
      · intro j hj
        simp only [Finset.mem_Ico] at hj ⊢
        exact hpos j (by simp only [Finset.mem_Ico]; omega)
      · intro j hj
        simp only [Finset.mem_Ico] at hj ⊢
        exact hpos j (by simp only [Finset.mem_Ico]; omega)
      · rw [labels_perfect, labels_perfect]
        rw [Finset.disjoint_left]
        intro x hx hx'
        simp only [Finset.mem_Ico] at hx hx'
        omega

/-- **Logarithmic fairness for arbitrary positive rate profiles.**  For `2 ^ d` clients with
*any* positive rates, the recursive Bresenham schedule of the balanced tree keeps every client
within `d = log₂ k` services of its ideal share — a bound independent of the rates
themselves, in stark contrast with the `Θ(R)` discrepancy of the exact-rate block schedule
(`bres_fair_block_unfair`). -/
theorem perfect_isFair {d : ℕ} {w : ℕ → ℕ} (hpos : ∀ j < 2 ^ d, 0 < w j) :
    IsFair (sched (perfect w d 0)) w (2 ^ d) (total w (2 ^ d) * d) := by
  have hWF : WF (perfect w d 0) := WF_perfect (by
    intro j hj
    simp only [Finset.mem_Ico] at hj
    exact hpos j (by omega))
  have hwt : wt (perfect w d 0) = total w (2 ^ d) := by
    rw [wt_perfect, Nat.zero_add, total, pre, Finset.range_eq_Ico]
  intro i hi t
  have h := tree_disc hWF i t
  rw [hwt, depth_perfect, rate_perfect, if_pos (by simp only [Finset.mem_Ico]; omega)] at h
  push_cast
  exact_mod_cast h

/-- Four clients with arbitrary positive rates admit a schedule of normalised discrepancy
at most `2`, however extreme the rates are. -/
theorem four_client_log_fair {w : ℕ → ℕ} (hpos : ∀ j < 4, 0 < w j) :
    IsFair (sched (perfect w 2 0)) w 4 (total w 4 * 2) := by
  have h := perfect_isFair (d := 2) (w := w) (by
    intro j hj
    norm_num at hj
    exact hpos j hj)
  norm_num at h
  exact h

end STree

end FairSchedule