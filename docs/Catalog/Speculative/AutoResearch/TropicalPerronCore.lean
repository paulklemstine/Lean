import Mathlib

/-!
# Cuninghame-Green construction: the core of the tropical Perron-Frobenius theorem

This file supplies the combinatorial core needed to prove that every finite real
matrix has a max-plus eigenvector (`Speculative.AutoResearch.PerronTheorem`).

The classical construction is carried out here in an elementary, walk-based form:

* `wt M f k` is the weight of the length-`k` walk `f 0 → f 1 → ⋯ → f k`;
* `Wt hn M k i j` is the maximal weight of a length-`k` walk from `i` to `j`
  (defined by the tropical recursion `Wt (k+2) i j = max_l (M i l + Wt (k+1) l j)`);
* `wt_le_Wt` and `exists_wt_eq_Wt` identify `Wt` with the maximum over walks;
* `lam hn M` is the **maximal cycle mean** over closed walks of length at most `n`;
* `wt_splice` removes a closed sub-walk from a walk, and
  `Wt_sub_le_maxTo` (proved by strong induction, using the pigeonhole principle to
  locate a repeated vertex) shows that in the shifted matrix `M - lam` no walk beats
  the best walk of length at most `n`;
* `exists_eigen_potential` then produces the eigenvector: the potential
  `v i = max_{1 ≤ l ≤ n} (Wt l i i₀ - l * lam)`, taken relative to a critical node
  `i₀`, satisfies `max_j (M i j + v j) = lam + v i`.

Nothing here uses `sorry`, `native_decide`, or any new axiom.
-/

open Finset

namespace TropPerron

variable {n : ℕ}

/-! ### Walks and their weights -/

/-- Weight of the length-`k` walk `f 0 → f 1 → ⋯ → f k`. -/
def wt (M : Matrix (Fin n) (Fin n) ℝ) (f : ℕ → Fin n) (k : ℕ) : ℝ :=
  ∑ t ∈ Finset.range k, M (f t) (f (t + 1))

/-- Maximal weight of a length-`k` walk from `i` to `j`.  Only the values for `k ≥ 1`
are meaningful; `Wt _ _ 0` is set to `0`. -/
def Wt (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) : ℕ → Fin n → Fin n → ℝ
  | 0, _, _ => 0
  | 1, i, j => M i j
  | (k + 2), i, j =>
      Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun l => M i l + Wt hn M (k + 1) l j)

lemma Wt_one (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    Wt hn M 1 i j = M i j := rfl

lemma Wt_succ_succ (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (i j : Fin n) :
    Wt hn M (k + 2) i j =
      Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun l => M i l + Wt hn M (k + 1) l j) := rfl

lemma wt_succ (M : Matrix (Fin n) (Fin n) ℝ) (f : ℕ → Fin n) (k : ℕ) :
    wt M f (k + 1) = M (f 0) (f 1) + wt M (fun t => f (t + 1)) k := by
  unfold wt
  rw [Finset.sum_range_succ']
  simp [add_comm]

/-- Every walk weight is bounded by `Wt`. -/
lemma wt_le_Wt (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ∀ (k : ℕ), 1 ≤ k → ∀ f : ℕ → Fin n, wt M f k ≤ Wt hn M k (f 0) (f k) := by
  intro k
  induction k with
  | zero => omega
  | succ k ih =>
    intro _ f
    match k, ih with
    | 0, _ => simp [wt, Wt]
    | (m + 1), ih =>
      rw [wt_succ, Wt_succ_succ]
      have h1 := ih (by omega) (fun t => f (t + 1))
      simp only at h1
      have h2 : M (f 0) (f 1) + wt M (fun t => f (t + 1)) (m + 1)
          ≤ M (f 0) (f 1) + Wt hn M (m + 1) (f 1) (f (m + 1 + 1)) := by linarith
      refine le_trans h2 ?_
      exact Finset.le_sup' (f := fun l => M (f 0) l + Wt hn M (m + 1) l (f (m + 1 + 1)))
        (Finset.mem_univ (f 1))

/-- `Wt` is attained by an actual walk. -/
lemma exists_wt_eq_Wt (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ∀ (k : ℕ), 1 ≤ k → ∀ i j : Fin n,
      ∃ f : ℕ → Fin n, f 0 = i ∧ f k = j ∧ wt M f k = Wt hn M k i j := by
  intro k
  induction k with
  | zero => omega
  | succ k ih =>
    intro _ i j
    match k, ih with
    | 0, _ =>
      refine ⟨fun t => if t = 0 then i else j, by simp, by simp, ?_⟩
      simp [wt, Wt]
    | (m + 1), ih =>
      obtain ⟨l, -, hl⟩ := Finset.exists_mem_eq_sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun l => M i l + Wt hn M (m + 1) l j)
      obtain ⟨g, hg0, hgk, hgw⟩ := ih (by omega) l j
      have eshift : (fun t => if t + 1 = 0 then i else g (t + 1 - 1)) = g := by
        funext t; simp
      refine ⟨fun t => if t = 0 then i else g (t - 1), by simp, by simp [hgk], ?_⟩
      rw [wt_succ, Wt_succ_succ, hl, eshift, hgw]
      simp [hg0]

/-! ### Removing a closed sub-walk -/

/-- If a walk revisits a vertex (`f a = f b` with `a < b ≤ k`), its weight splits as the
weight of the shortened walk plus the weight of the excised closed sub-walk. -/
lemma wt_splice (M : Matrix (Fin n) (Fin n) ℝ) (f : ℕ → Fin n) {a b k : ℕ}
    (hab : a < b) (hbk : b ≤ k) (heq : f a = f b) :
    wt M f k = wt M (fun t => if t < a then f t else f (t + (b - a))) (k - (b - a))
      + wt M (fun t => f (a + t)) (b - a) := by
  set d := b - a with hd
  have hbad : a + d = b := by omega
  set g : ℕ → Fin n := fun t => if t < a then f t else f (t + d) with hg
  have p2 : wt M (fun t => f (a + t)) d = ∑ t ∈ Finset.Ico a b, M (f t) (f (t + 1)) := by
    rw [wt, Finset.sum_Ico_eq_sum_range, ← hd]
    exact Finset.sum_congr rfl fun t _ => by rw [add_assoc]
  have p1a : ∑ t ∈ Finset.range a, M (g t) (g (t + 1))
      = ∑ t ∈ Finset.Ico 0 a, M (f t) (f (t + 1)) := by
    rw [Finset.range_eq_Ico]
    refine Finset.sum_congr rfl fun t ht => ?_
    have hta : t < a := (Finset.mem_Ico.mp ht).2
    have h1 : g t = f t := by simp [hg, hta]
    have h2 : g (t + 1) = f (t + 1) := by
      by_cases h : t + 1 < a
      · simp [hg, h]
      · have hte : t + 1 = a := by omega
        simp [hg, hte, hbad, heq]
    rw [h1, h2]
  have p1b : ∑ t ∈ Finset.Ico a (k - d), M (g t) (g (t + 1))
      = ∑ t ∈ Finset.Ico b k, M (f t) (f (t + 1)) := by
    rw [Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sum_range]
    have hlen : k - d - a = k - b := by omega
    rw [hlen]
    refine Finset.sum_congr rfl fun t _ => ?_
    have h1 : g (a + t) = f (a + t + d) := by
      simp only [hg]
      rw [if_neg (by omega)]
    have h2 : g (a + t + 1) = f (a + t + 1 + d) := by
      simp only [hg]
      rw [if_neg (by omega)]
    rw [h1, h2]
    congr 2 <;> omega
  have hsplit1 : ∑ t ∈ Finset.Ico 0 a, M (f t) (f (t + 1))
      + ∑ t ∈ Finset.Ico a b, M (f t) (f (t + 1))
      + ∑ t ∈ Finset.Ico b k, M (f t) (f (t + 1)) = wt M f k := by
    rw [wt, Finset.range_eq_Ico]
    rw [Finset.sum_Ico_consecutive _ (by omega : 0 ≤ a) (by omega : a ≤ b)]
    rw [Finset.sum_Ico_consecutive _ (by omega : 0 ≤ b) hbk]
  have hgsplit : wt M g (k - d) = ∑ t ∈ Finset.range a, M (g t) (g (t + 1))
      + ∑ t ∈ Finset.Ico a (k - d), M (g t) (g (t + 1)) := by
    rw [wt, Finset.range_eq_Ico]
    rw [Finset.sum_Ico_consecutive _ (by omega : 0 ≤ a) (by omega : a ≤ k - d)]
  rw [hgsplit, p1a, p1b, p2, ← hsplit1]
  ring

/-! ### The maximal cycle mean -/

/-- The index set `{1, …, n}` of admissible cycle lengths is nonempty. -/
lemma icc_nonempty (hn : 0 < n) : (Finset.Icc 1 n).Nonempty :=
  ⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, hn⟩⟩

/-- The maximal cycle mean: the largest mean weight of a closed walk of length at most
`n`. -/
noncomputable def lam (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  (Finset.Icc 1 n).sup' (icc_nonempty hn)
    (fun k => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => Wt hn M k i i / k))

/-- Closed walks of length at most `n` have nonpositive weight after the shift by
`lam`. -/
lemma Wt_diag_sub_le (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) {d : ℕ}
    (hd : d ∈ Finset.Icc 1 n) (i : Fin n) : Wt hn M d i i - d * lam hn M ≤ 0 := by
  have hd1 : 1 ≤ d := (Finset.mem_Icc.mp hd).1
  have hdpos : (0:ℝ) < (d:ℝ) := by exact_mod_cast hd1
  have h1 : Wt hn M d i i / d ≤ lam hn M := by
    refine le_trans ?_ (Finset.le_sup'
      (fun k => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun i => Wt hn M k i i / k)) hd)
    exact Finset.le_sup' (fun i => Wt hn M d i i / d) (Finset.mem_univ i)
  rw [div_le_iff₀ hdpos] at h1
  nlinarith [h1]

/-- **Cycle removal.**  After the shift by the maximal cycle mean, no walk beats the
best walk of length at most `n`. -/
lemma Wt_sub_le_maxTo (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    ∀ k : ℕ, 1 ≤ k →
      Wt hn M k i j - k * lam hn M ≤
        (Finset.Icc 1 n).sup' (icc_nonempty hn) (fun l => Wt hn M l i j - l * lam hn M) := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    intro hk1
    by_cases hkn : k ≤ n
    · exact Finset.le_sup' (fun l => Wt hn M l i j - l * lam hn M)
        (Finset.mem_Icc.mpr ⟨hk1, hkn⟩)
    · push_neg at hkn
      obtain ⟨f, hf0, hfk, hfw⟩ := exists_wt_eq_Wt hn M k hk1 i j
      have hcard : Fintype.card (Fin n) < Fintype.card (Fin (n + 1)) := by simp
      obtain ⟨x, y, hxy, hfxy⟩ :=
        Fintype.exists_ne_map_eq_of_card_lt (fun t : Fin (n + 1) => f t) hcard
      have hne' : (x : ℕ) ≠ (y : ℕ) := fun hxyval => hxy (Fin.ext hxyval)
      have hxle : (x : ℕ) ≤ n := Nat.lt_succ_iff.mp x.isLt
      have hyle : (y : ℕ) ≤ n := Nat.lt_succ_iff.mp y.isLt
      have hfx : f (x : ℕ) = f (y : ℕ) := hfxy
      obtain ⟨a, b, hab, hbn, heq⟩ : ∃ a b : ℕ, a < b ∧ b ≤ n ∧ f a = f b := by
        rcases lt_or_gt_of_ne hne' with hlt | hgt
        · exact ⟨(x : ℕ), (y : ℕ), hlt, hyle, hfx⟩
        · exact ⟨(y : ℕ), (x : ℕ), hgt, hxle, hfx.symm⟩
      set d := b - a with hd
      have hd1 : 1 ≤ d := by omega
      have hdn : d ≤ n := by omega
      have hbk : b ≤ k := by omega
      have hsp := wt_splice M f hab hbk heq
      rw [← hd] at hsp
      -- the excised closed sub-walk has nonpositive shifted weight
      have hAA : f (a + d) = f a := by
        rw [show a + d = b by omega]; exact heq.symm
      have hclosed : wt M (fun t => f (a + t)) d ≤ d * lam hn M := by
        have hle := wt_le_Wt hn M d hd1 (fun t => f (a + t))
        simp only [Nat.add_zero, hAA] at hle
        have h2 := Wt_diag_sub_le hn M (Finset.mem_Icc.mpr ⟨hd1, hdn⟩) (f a)
        linarith
      -- the shortened walk still runs from `i` to `j`
      have hstart : (if (0:ℕ) < a then f 0 else f (0 + d)) = i := by
        by_cases h0 : 0 < a
        · rw [if_pos h0]; exact hf0
        · rw [if_neg (by omega), show (0:ℕ) + d = b by omega, ← heq, show a = 0 by omega]
          exact hf0
      have hend : (if k - d < a then f (k - d) else f (k - d + d)) = j := by
        rw [if_neg (by omega), show k - d + d = k by omega]; exact hfk
      have hgle := wt_le_Wt hn M (k - d) (by omega) (fun t => if t < a then f t else f (t + d))
      simp only [hstart, hend] at hgle
      have hIH := ih (k - d) (by omega) (by omega)
      have hcast : ((k - d : ℕ) : ℝ) = (k : ℝ) - (d : ℝ) := by
        have : d ≤ k := by omega
        push_cast [this]
        ring
      rw [hcast] at hIH
      rw [← hfw]
      rw [hsp]
      linarith

/-! ### The eigenvector -/

/-- **Cuninghame-Green.**  For every real square matrix there is a potential `v` with
`max_j (M i j + v j) = lam + v i` for all `i`. -/
theorem exists_eigen_potential (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ v : Fin n → ℝ, ∀ i : Fin n,
      Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => M i j + v j)
        = lam hn M + v i := by
  classical
  obtain ⟨k0, hk0mem, hk0⟩ := Finset.exists_mem_eq_sup' (icc_nonempty hn)
    (fun k => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => Wt hn M k i i / k))
  obtain ⟨i0, -, hi0⟩ := Finset.exists_mem_eq_sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun i => Wt hn M k0 i i / k0)
  have hk01 : 1 ≤ k0 := (Finset.mem_Icc.mp hk0mem).1
  have hk0pos : (0:ℝ) < (k0 : ℝ) := by exact_mod_cast hk01
  have hlam : lam hn M = Wt hn M k0 i0 i0 / k0 := by
    rw [lam, hk0, hi0]
  have hcrit : Wt hn M k0 i0 i0 - k0 * lam hn M = 0 := by
    rw [hlam]
    field_simp
    ring
  set v : Fin n → ℝ :=
    fun i => (Finset.Icc 1 n).sup' (icc_nonempty hn)
      (fun l => Wt hn M l i i0 - l * lam hn M) with hv
  have hv0 : v i0 = 0 := by
    refine le_antisymm ?_ ?_
    · exact Finset.sup'_le _ _ fun l hl => Wt_diag_sub_le hn M hl i0
    · rw [hv]
      exact le_trans (le_of_eq hcrit.symm)
        (Finset.le_sup' (fun l => Wt hn M l i0 i0 - l * lam hn M) hk0mem)
  have hupper : ∀ i j : Fin n, M i j + v j ≤ lam hn M + v i := by
    intro i j
    obtain ⟨l, hlmem, hl⟩ := Finset.exists_mem_eq_sup' (icc_nonempty hn)
      (fun l => Wt hn M l j i0 - l * lam hn M)
    have hl1 : 1 ≤ l := (Finset.mem_Icc.mp hlmem).1
    obtain ⟨m, rfl⟩ : ∃ m, l = m + 1 := ⟨l - 1, by omega⟩
    have hvj : v j = Wt hn M (m + 1) j i0 - (m + 1 : ℕ) * lam hn M := by
      rw [hv]; exact hl
    have hstep : M i j + Wt hn M (m + 1) j i0 ≤ Wt hn M (m + 2) i i0 := by
      rw [Wt_succ_succ]
      exact Finset.le_sup' (fun l => M i l + Wt hn M (m + 1) l i0) (Finset.mem_univ j)
    have hred := Wt_sub_le_maxTo hn M i i0 (m + 2) (by omega)
    have hvi : (Finset.Icc 1 n).sup' (icc_nonempty hn)
        (fun l => Wt hn M l i i0 - l * lam hn M) = v i := by rw [hv]
    rw [hvi] at hred
    rw [hvj]
    push_cast at hred ⊢
    linarith
  have hlower : ∀ i : Fin n, ∃ j : Fin n, lam hn M + v i ≤ M i j + v j := by
    intro i
    obtain ⟨l, hlmem, hl⟩ := Finset.exists_mem_eq_sup' (icc_nonempty hn)
      (fun l => Wt hn M l i i0 - l * lam hn M)
    have hl1 : 1 ≤ l := (Finset.mem_Icc.mp hlmem).1
    have hln : l ≤ n := (Finset.mem_Icc.mp hlmem).2
    have hvi : v i = Wt hn M l i i0 - l * lam hn M := by rw [hv]; exact hl
    match l, hl1, hln, hvi with
    | 0, hl1, _, _ => exact absurd hl1 (by omega)
    | 1, _, _, hvi =>
      refine ⟨i0, ?_⟩
      rw [hvi, hv0, Wt_one]
      push_cast
      linarith
    | (m + 2), _, hln, hvi =>
      obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun j => M i j + Wt hn M (m + 1) j i0)
      refine ⟨j, ?_⟩
      have hwt : Wt hn M (m + 2) i i0 = M i j + Wt hn M (m + 1) j i0 := by
        rw [Wt_succ_succ]; exact hj
      have hvj : Wt hn M (m + 1) j i0 - (m + 1 : ℕ) * lam hn M ≤ v j := by
        rw [hv]
        exact Finset.le_sup' (fun l => Wt hn M l j i0 - l * lam hn M)
          (Finset.mem_Icc.mpr ⟨by omega, by omega⟩)
      rw [hvi, hwt]
      push_cast at hvj ⊢
      linarith
  refine ⟨v, fun i => le_antisymm ?_ ?_⟩
  · exact Finset.sup'_le _ _ fun j _ => hupper i j
  · obtain ⟨j, hj⟩ := hlower i
    exact le_trans hj (Finset.le_sup' (fun j => M i j + v j) (Finset.mem_univ j))

end TropPerron