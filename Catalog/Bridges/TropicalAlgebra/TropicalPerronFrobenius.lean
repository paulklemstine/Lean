import Mathlib
import Bridges.NeuralCoding.MaxPlusDefs

/-!
# Tropical Perron–Frobenius: existence of a max-plus eigenvector

This file proves the general max-plus (tropical) Perron–Frobenius theorem for a *finite*
real matrix: for every `n × n` matrix `A` over `ℝ` with `n > 0` there are a scalar `μ`
and a vector `v : Fin n → ℝ` with

`maxPlusMul A v hn i = μ + v i`  for every `i`,

i.e. `A ⊗ v = μ ⊗ v` in the max-plus semiring.  Since all entries of `A` are finite the
underlying digraph is complete, hence irreducible, and the classical
Cuninghame-Green construction applies:

* `μ` is the **maximal cycle mean** `max { (Aᵏ)ᵢᵢ / k : 1 ≤ k ≤ n }`
  (`TropicalPerron.cycleMeanMax`);
* after subtracting `μ` from every entry the resulting matrix `B` has all cycles of
  length `≤ n` of nonpositive weight (`TropicalPerron.shift_diag_nonpos`);
* a critical node `i₀` is a node lying on a cycle of weight exactly `0`
  (`TropicalPerron.exists_critical`);
* the eigenvector is the truncated Kleene star column
  `v j = max { (Bˡ)_{j i₀} : 1 ≤ l ≤ n }` (`TropicalPerron.kleeneCol`).

The combinatorial heart of the argument is `TropicalPerron.walk_cut`: a walk of length
`> n` contains a repeated vertex, so it splits into a shorter walk with the same endpoints
plus a closed walk of length at most `n`.  This is what allows the truncation at length
`n` in the definition of `v`, and it is proved here from scratch (pigeonhole on the first
`n+1` positions plus an explicit re-indexing of the weight sums).

## Main results

* `TropicalPerron.walk_cut` — cycle excision from a long walk;
* `TropicalPerron.kleeneCol_eigen` — `B ⊗ v = v` for the truncated Kleene column;
* `TropicalPerron.exists_maxPlus_eigenvector` — the tropical Perron–Frobenius theorem,
  stated with the catalogue's `maxPlusMul`.
-/

noncomputable section

open Finset

namespace TropicalPerron

variable {n : ℕ}

/-! ### Powers, walks and their weights -/

/-- `Finset.univ : Finset (Fin n)` is nonempty when `0 < n`. -/
theorem univ_ne (hn : 0 < n) : (Finset.univ : Finset (Fin n)).Nonempty :=
  Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩

/-- `tpow hn A k` is the `(k+1)`-st max-plus power of `A`:
`tpow hn A k i j = max over walks of length k+1 from i to j`. -/
def tpow (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | k + 1 => fun i j => (Finset.univ).sup' (univ_ne hn) (fun m => A i m + tpow hn A k m j)

theorem tpow_succ (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (i j : Fin n) :
    tpow hn A (k + 1) i j
      = (Finset.univ).sup' (univ_ne hn) (fun m => A i m + tpow hn A k m j) := rfl

/-- The weight of the length-`k` walk `w`. -/
def wt (A : Matrix (Fin n) (Fin n) ℝ) (w : ℕ → Fin n) (k : ℕ) : ℝ :=
  ∑ t ∈ Finset.range k, A (w t) (w (t + 1))

theorem wt_succ_left (A : Matrix (Fin n) (Fin n) ℝ) (w : ℕ → Fin n) (k : ℕ) :
    wt A w (k + 1) = A (w 0) (w 1) + wt A (fun t => w (t + 1)) k := by
  unfold wt
  rw [Finset.sum_range_succ']
  simp [add_comm]

/-- Every walk is dominated by the corresponding max-plus power. -/
theorem wt_le_tpow (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∀ (k : ℕ) (w : ℕ → Fin n), wt A w (k + 1) ≤ tpow hn A k (w 0) (w (k + 1)) := by
  intro k
  induction k with
  | zero => intro w; simp [wt, tpow]
  | succ k ih =>
      intro w
      rw [wt_succ_left]
      have h := ih (fun t => w (t + 1))
      norm_num at h
      have h2 : A (w 0) (w 1) + wt A (fun t => w (t + 1)) (k + 1)
          ≤ A (w 0) (w 1) + tpow hn A k (w 1) (w (k + 1 + 1)) := by linarith
      refine le_trans h2 ?_
      rw [tpow_succ]
      exact Finset.le_sup' (fun m => A (w 0) m + tpow hn A k m (w (k + 1 + 1)))
        (Finset.mem_univ (w 1))

/-- The max-plus power is attained by some walk. -/
theorem exists_wt_eq_tpow (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∀ (k : ℕ) (i j : Fin n), ∃ w : ℕ → Fin n,
      w 0 = i ∧ w (k + 1) = j ∧ wt A w (k + 1) = tpow hn A k i j := by
  intro k
  induction k with
  | zero =>
      intro i j
      refine ⟨fun t => if t = 0 then i else j, by simp, by simp, ?_⟩
      simp [wt, tpow]
  | succ k ih =>
      intro i j
      obtain ⟨m, -, hm⟩ := Finset.exists_mem_eq_sup' (univ_ne hn)
        (fun m => A i m + tpow hn A k m j)
      obtain ⟨w, hw0, hwk, hwt⟩ := ih m j
      refine ⟨fun t => if t = 0 then i else w (t - 1), by simp, ?_, ?_⟩
      · simp only
        rw [if_neg (by omega)]
        simpa using hwk
      · rw [wt_succ_left]
        have e1 : (if (0 : ℕ) = 0 then i else w (0 - 1)) = i := by norm_num
        have e2 : (if (1 : ℕ) = 0 then i else w (1 - 1)) = m := by norm_num [hw0]
        have e3 : (fun t : ℕ => if t + 1 = 0 then i else w (t + 1 - 1)) = w := by
          funext t; norm_num
        rw [e1, e2, e3, hwt, tpow_succ, hm]

/-! ### Cycle excision -/

/-- **Cycle excision.**  A walk of length `k + 1 > n` repeats a vertex among its first
`n + 1` positions, hence splits into a walk `u` with the same endpoints and strictly
smaller length together with a closed walk `c` of length `m ∈ [1, n]`, the two weights
adding up to the weight of the original walk. -/
theorem walk_cut (A : Matrix (Fin n) (Fin n) ℝ) (w : ℕ → Fin n) (k : ℕ) (hk : n ≤ k) :
    ∃ (m : ℕ) (u c : ℕ → Fin n), 0 < m ∧ m ≤ n ∧
      u 0 = w 0 ∧ u (k + 1 - m) = w (k + 1) ∧ c 0 = c m ∧
      wt A w (k + 1) = wt A u (k + 1 - m) + wt A c m := by
  classical
  obtain ⟨a, b, hab, hfab⟩ : ∃ a b : Fin (n + 1), a ≠ b ∧ w a.val = w b.val := by
    have hcard : Fintype.card (Fin n) < Fintype.card (Fin (n + 1)) := by simp
    obtain ⟨a, b, hab, h⟩ :=
      Fintype.exists_ne_map_eq_of_card_lt (fun x : Fin (n + 1) => w x.val) hcard
    exact ⟨a, b, hab, h⟩
  obtain ⟨s, t, hst, htn, hrep⟩ : ∃ s t : ℕ, s < t ∧ t ≤ n ∧ w s = w t := by
    rcases lt_or_gt_of_ne (fun h : a.val = b.val => hab (Fin.ext h)) with h | h
    · exact ⟨a.val, b.val, h, Nat.lt_succ_iff.mp b.isLt, hfab⟩
    · exact ⟨b.val, a.val, h, Nat.lt_succ_iff.mp a.isLt, hfab.symm⟩
  set m := t - s with hm
  set u : ℕ → Fin n := fun x => if x ≤ s then w x else w (x + m) with hu
  set c : ℕ → Fin n := fun x => w (s + x) with hc
  set K := k + 1 - m with hK
  have hmpos : 0 < m := by omega
  have hmn : m ≤ n := by omega
  have hsK : s < K := by omega
  have hKm : K + m = k + 1 := by omega
  have hsm : s + m = t := by omega
  refine ⟨m, u, c, hmpos, hmn, by simp [hu], ?_, ?_, ?_⟩
  · show (if K ≤ s then w K else w (K + m)) = w (k + 1)
    rw [if_neg (by omega : ¬ K ≤ s), hKm]
  · show w (s + 0) = w (s + m)
    rw [Nat.add_zero, hsm]
    exact hrep
  · have hcw : wt A c m = ∑ x ∈ Finset.Ico s t, A (w x) (w (x + 1)) := by
      rw [Finset.sum_Ico_eq_sum_range]
      simp only [wt, hc, ← hm]
      exact Finset.sum_congr rfl fun x _ => by congr 2
    have hsplit1 : ∑ x ∈ Finset.range K, A (u x) (u (x + 1))
        = ∑ x ∈ Finset.range s, A (u x) (u (x + 1))
          + ∑ x ∈ Finset.Ico s K, A (u x) (u (x + 1)) := by
      rw [Finset.range_eq_Ico, Finset.sum_Ico_consecutive _ (Nat.zero_le s) (le_of_lt hsK)]
    have hfirst : ∑ x ∈ Finset.range s, A (u x) (u (x + 1))
        = ∑ x ∈ Finset.range s, A (w x) (w (x + 1)) := by
      refine Finset.sum_congr rfl fun x hx => ?_
      have hx' : x < s := Finset.mem_range.mp hx
      show A (if x ≤ s then w x else w (x + m))
          (if x + 1 ≤ s then w (x + 1) else w (x + 1 + m)) = _
      rw [if_pos (le_of_lt hx'), if_pos (show x + 1 ≤ s by omega)]
    have husnd : ∀ x, s ≤ x → u x = w (x + m) := by
      intro x hx
      rcases eq_or_lt_of_le hx with h | h
      · show (if x ≤ s then w x else w (x + m)) = w (x + m)
        rw [if_pos (by omega : x ≤ s), show x + m = t by omega, ← h]
        exact hrep
      · show (if x ≤ s then w x else w (x + m)) = w (x + m)
        rw [if_neg (by omega : ¬ x ≤ s)]
    have hsecond : ∑ x ∈ Finset.Ico s K, A (u x) (u (x + 1))
        = ∑ x ∈ Finset.Ico t (k + 1), A (w x) (w (x + 1)) := by
      rw [Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sum_range]
      rw [show K - s = k + 1 - t by omega]
      refine Finset.sum_congr rfl fun x _ => ?_
      rw [husnd (s + x) (by omega), husnd (s + x + 1) (by omega)]
      congr 2 <;> omega
    have hsplit2 : ∑ x ∈ Finset.range (k + 1), A (w x) (w (x + 1))
        = ∑ x ∈ Finset.range s, A (w x) (w (x + 1))
          + (∑ x ∈ Finset.Ico s t, A (w x) (w (x + 1))
            + ∑ x ∈ Finset.Ico t (k + 1), A (w x) (w (x + 1))) := by
      rw [Finset.sum_Ico_consecutive _ (le_of_lt hst) (by omega : t ≤ k + 1),
        Finset.range_eq_Ico,
        Finset.sum_Ico_consecutive _ (Nat.zero_le s) (by omega : s ≤ k + 1)]
    show ∑ x ∈ Finset.range (k + 1), A (w x) (w (x + 1)) = _ + _
    rw [hsplit2, hcw]
    show _ = ∑ x ∈ Finset.range K, A (u x) (u (x + 1)) + _
    rw [hsplit1, hfirst, hsecond]
    ring

/-! ### The maximal cycle mean and the shifted matrix -/

/-- Shifting a supremum by a constant. -/
theorem sup'_sub_const {β : Type*} (s : Finset β) (H : s.Nonempty) (f : β → ℝ) (c : ℝ) :
    s.sup' H (fun b => f b - c) = s.sup' H f - c := by
  refine le_antisymm (Finset.sup'_le _ _ fun b hb => ?_) ?_
  · exact sub_le_sub_right (Finset.le_sup' f hb) c
  · rw [sub_le_iff_le_add]
    refine Finset.sup'_le _ _ fun b hb => ?_
    have : f b - c ≤ s.sup' H (fun b => f b - c) := Finset.le_sup' (fun b => f b - c) hb
    linarith

/-- Index set of the cycles of length at most `n`. -/
theorem cycIdx_ne (hn : 0 < n) :
    ((Finset.range n) ×ˢ (Finset.univ : Finset (Fin n))).Nonempty :=
  Finset.Nonempty.product ⟨0, Finset.mem_range.mpr hn⟩ (univ_ne hn)

/-- The **maximal cycle mean** of `A`, i.e. `max { (Aˡ)ᵢᵢ / l : 1 ≤ l ≤ n }`. -/
def cycleMeanMax (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ((Finset.range n) ×ˢ (Finset.univ : Finset (Fin n))).sup' (cycIdx_ne hn)
    (fun p => tpow hn A p.1 p.2 p.2 / (p.1 + 1))

/-- Subtracting a constant from every entry subtracts `(k+1)·c` from the `(k+1)`-st power. -/
theorem tpow_shift (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) :
    ∀ (k : ℕ) (i j : Fin n),
      tpow hn (fun i j => A i j - c) k i j = tpow hn A k i j - (k + 1) * c := by
  intro k
  induction k with
  | zero => intro i j; simp [tpow]
  | succ k ih =>
      intro i j
      rw [tpow_succ, tpow_succ]
      have : ∀ m : Fin n, (A i m - c) + tpow hn (fun i j => A i j - c) k m j
          = (A i m + tpow hn A k m j) - (k + 1 + 1) * c := by
        intro m
        rw [ih m j]
        ring
      rw [Finset.sup'_congr _ rfl (fun m _ => this m)]
      rw [sup'_sub_const]
      push_cast
      ring

/-- After subtracting the maximal cycle mean every cycle of length at most `n` has
nonpositive weight. -/
theorem shift_diag_nonpos (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (l : ℕ) (hl : l < n)
    (i : Fin n) :
    tpow hn (fun i j => A i j - cycleMeanMax hn A) l i i ≤ 0 := by
  have hmem : (l, i) ∈ (Finset.range n) ×ˢ (Finset.univ : Finset (Fin n)) :=
    Finset.mem_product.mpr ⟨Finset.mem_range.mpr hl, Finset.mem_univ i⟩
  have hle : tpow hn A l i i / (l + 1) ≤ cycleMeanMax hn A :=
    Finset.le_sup' (fun p => tpow hn A p.1 p.2 p.2 / (p.1 + 1)) hmem
  have hpos : (0 : ℝ) < (l : ℝ) + 1 := by positivity
  rw [tpow_shift]
  rw [div_le_iff₀ hpos] at hle
  linarith

/-- A **critical node**: some cycle of length at most `n` has weight exactly `0` after
the shift. -/
theorem exists_critical (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (l₀ : ℕ) (i₀ : Fin n), l₀ < n ∧
      tpow hn (fun i j => A i j - cycleMeanMax hn A) l₀ i₀ i₀ = 0 := by
  obtain ⟨p, hp, hsup⟩ := Finset.exists_mem_eq_sup' (cycIdx_ne hn)
    (fun p => tpow hn A p.1 p.2 p.2 / (p.1 + 1))
  refine ⟨p.1, p.2, Finset.mem_range.mp (Finset.mem_product.mp hp).1, ?_⟩
  have hpos : (0 : ℝ) < (p.1 : ℝ) + 1 := by positivity
  have : cycleMeanMax hn A = tpow hn A p.1 p.2 p.2 / (p.1 + 1) := hsup
  rw [tpow_shift, this]
  field_simp
  ring

/-! ### The eigenvector -/

/-- The truncated Kleene-star column at the node `i₀`:
`v j = max { (Bˡ)_{j i₀} : 1 ≤ l ≤ n }`. -/
def kleeneCol (hn : 0 < n) (B : Matrix (Fin n) (Fin n) ℝ) (i₀ : Fin n) : Fin n → ℝ :=
  fun j => (Finset.range n).sup' ⟨0, Finset.mem_range.mpr hn⟩ (fun l => tpow hn B l j i₀)

theorem tpow_le_kleeneCol (hn : 0 < n) (B : Matrix (Fin n) (Fin n) ℝ) (i₀ : Fin n)
    {l : ℕ} (hl : l < n) (j : Fin n) : tpow hn B l j i₀ ≤ kleeneCol hn B i₀ j :=
  Finset.le_sup' (fun l => tpow hn B l j i₀) (Finset.mem_range.mpr hl)

/-- One step beyond the truncation length is still bounded by the truncated column:
this is where cycle excision is used. -/
theorem tpow_n_le_kleeneCol (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (i₀ : Fin n)
    (hdiag : ∀ l < n, ∀ i : Fin n, tpow hn A l i i ≤ 0) (i : Fin n) :
    tpow hn A n i i₀ ≤ kleeneCol hn A i₀ i := by
  obtain ⟨w, hw0, hwn, hwt⟩ := exists_wt_eq_tpow hn A n i i₀
  obtain ⟨m, u, c, hmpos, hmn, hu0, huend, hcclosed, hsplit⟩ := walk_cut A w n le_rfl
  -- the excised cycle has nonpositive weight
  have hcycle : wt A c m ≤ 0 := by
    have h := wt_le_tpow hn A (m - 1) c
    rw [show m - 1 + 1 = m by omega] at h
    rw [← hcclosed] at h
    exact le_trans h (hdiag (m - 1) (by omega) (c 0))
  -- the remaining walk is short enough to be seen by the truncated column
  have hrest : wt A u (n + 1 - m) ≤ kleeneCol hn A i₀ i := by
    have h := wt_le_tpow hn A (n - m) u
    rw [show n - m + 1 = n + 1 - m by omega] at h
    rw [hu0, hw0, huend, hwn] at h
    exact le_trans h (tpow_le_kleeneCol hn A i₀ (by omega) i)
  rw [← hwt, hsplit]
  linarith

/-- **The truncated Kleene column is a max-plus eigenvector of the shifted matrix**:
`max_j (B i j + v j) = v i`. -/
theorem kleeneCol_eigen (hn : 0 < n) (B : Matrix (Fin n) (Fin n) ℝ) (i₀ : Fin n)
    (hdiag : ∀ l < n, ∀ i : Fin n, tpow hn B l i i ≤ 0)
    {l₀ : ℕ} (hl₀ : l₀ < n) (hcrit : tpow hn B l₀ i₀ i₀ = 0) (i : Fin n) :
    (Finset.univ).sup' (univ_ne hn) (fun j => B i j + kleeneCol hn B i₀ j)
      = kleeneCol hn B i₀ i := by
  have hv₀ : 0 ≤ kleeneCol hn B i₀ i₀ := by
    rw [← hcrit]
    exact tpow_le_kleeneCol hn B i₀ hl₀ i₀
  refine le_antisymm (Finset.sup'_le _ _ fun j _ => ?_) ?_
  · -- upper bound: prolonging a short walk by one step stays below the column
    obtain ⟨l, hl, hlval⟩ := Finset.exists_mem_eq_sup' (⟨0, Finset.mem_range.mpr hn⟩ :
      (Finset.range n).Nonempty) (fun l => tpow hn B l j i₀)
    have hln : l < n := Finset.mem_range.mp hl
    have hstep : B i j + tpow hn B l j i₀ ≤ tpow hn B (l + 1) i i₀ := by
      rw [tpow_succ]
      exact Finset.le_sup' (fun m => B i m + tpow hn B l m i₀) (Finset.mem_univ j)
    have hvj : kleeneCol hn B i₀ j = tpow hn B l j i₀ := hlval
    rw [hvj]
    refine le_trans hstep ?_
    rcases Nat.lt_or_ge (l + 1) n with h | h
    · exact tpow_le_kleeneCol hn B i₀ h i
    · rw [show l + 1 = n by omega]
      exact tpow_n_le_kleeneCol hn B i₀ hdiag i
  · -- lower bound: peel off the first step of the optimal short walk
    obtain ⟨l, hl, hlval⟩ := Finset.exists_mem_eq_sup' (⟨0, Finset.mem_range.mpr hn⟩ :
      (Finset.range n).Nonempty) (fun l => tpow hn B l i i₀)
    have hln : l < n := Finset.mem_range.mp hl
    have hvi : kleeneCol hn B i₀ i = tpow hn B l i i₀ := hlval
    rw [hvi]
    match l, hln with
    | 0, _ =>
        have h1 : tpow hn B 0 i i₀ ≤ B i i₀ + kleeneCol hn B i₀ i₀ := by
          show B i i₀ ≤ _
          linarith
        exact le_trans h1
          (Finset.le_sup' (fun j => B i j + kleeneCol hn B i₀ j) (Finset.mem_univ i₀))
    | (l + 1), hln' =>
        rw [tpow_succ]
        refine Finset.sup'_le _ _ fun m _ => ?_
        have : tpow hn B l m i₀ ≤ kleeneCol hn B i₀ m :=
          tpow_le_kleeneCol hn B i₀ (by omega) m
        have hle : B i m + tpow hn B l m i₀ ≤ B i m + kleeneCol hn B i₀ m := by linarith
        exact le_trans hle
          (Finset.le_sup' (fun j => B i j + kleeneCol hn B i₀ j) (Finset.mem_univ m))

/-- **Tropical Perron–Frobenius theorem.**  Every finite real matrix of positive size has a
max-plus eigenvector, with eigenvalue the maximal cycle mean. -/
theorem exists_maxPlus_eigenvector (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (mu : ℝ) (v : Fin n → ℝ), ∀ i, maxPlusMul A v hn i = mu + v i := by
  obtain ⟨l₀, i₀, hl₀, hcrit⟩ := exists_critical hn A
  set lam := cycleMeanMax hn A with hlam
  set B : Matrix (Fin n) (Fin n) ℝ := fun i j => A i j - lam with hB
  refine ⟨lam, kleeneCol hn B i₀, fun i => ?_⟩
  have heigen := kleeneCol_eigen hn B i₀ (fun l hl i => shift_diag_nonpos hn A l hl i) hl₀
    hcrit i
  have hrew : ∀ j : Fin n, A i j + kleeneCol hn B i₀ j
      = (B i j + kleeneCol hn B i₀ j) + lam := by
    intro j
    show A i j + _ = (A i j - lam + _) + lam
    ring
  show (Finset.univ).sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
      (fun j => A i j + kleeneCol hn B i₀ j) = lam + kleeneCol hn B i₀ i
  rw [Finset.sup'_congr _ rfl (fun j _ => hrew j)]
  have hshift : (Finset.univ).sup' (univ_ne hn) (fun j => (B i j + kleeneCol hn B i₀ j) + lam)
      = (Finset.univ).sup' (univ_ne hn) (fun j => B i j + kleeneCol hn B i₀ j) + lam := by
    have h := sup'_sub_const (Finset.univ : Finset (Fin n)) (univ_ne hn)
      (fun j => B i j + kleeneCol hn B i₀ j + lam) lam
    simp only [add_sub_cancel_right] at h
    linarith
  rw [hshift, heigen]
  ring

end TropicalPerron