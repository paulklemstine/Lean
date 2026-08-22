import Mathlib

/-!
# Walks, cycle means and the max-plus (tropical) Perron–Frobenius eigenvector

This file develops, from scratch, the combinatorial machinery needed to prove the
existence of a max-plus eigenvector for an arbitrary finite real matrix:

  for every `A : V → V → ℝ` on a nonempty finite type `V` there are `μ : ℝ`
  and `v : V → ℝ` with `max_j (A i j + v j) = μ + v i` for all `i`.

Everything is finite: since all entries of `A` are real numbers (no `-∞`), the
underlying digraph is complete, so every pair of nodes is joined by walks of every
length.  The proof follows the Cuninghame-Green construction:

* `walkW A p m` is the weight of the first `m` edges of the walk `p : ℕ → V`;
* `bestW A m i j` is the maximal weight of a walk from `i` to `j` using `m + 1` edges;
* `cycleMax A` is the maximal cycle mean, taken over cycles of length at most `card V`;
* every closed walk has mean at most `cycleMax A` (`walkW_le_cycleMax`, proved by
  strong induction on the length using a pigeonhole splitting argument);
* after normalising `A` by `cycleMax A` one has a critical cycle of weight `0`, and
  the Kleene-star column `v i = max_{m ≤ 2·card V} bestW A m i c` is an eigenvector.

## Main results

* `walkW_le_cycleMax` : every closed walk has weight at most `length · cycleMax A`.
* `exists_normalized_eigenvector` : eigenvector existence for a normalised matrix.
* `exists_tropical_eigenvector` : the general tropical Perron–Frobenius statement.
-/

noncomputable section

open Finset

namespace TropicalWalk

variable {V : Type*}

/-! ### Walks and their weights -/

/-- Weight of the first `m` edges of the walk `p`. -/
def walkW (A : V → V → ℝ) (p : ℕ → V) (m : ℕ) : ℝ :=
  ∑ t ∈ Finset.range m, A (p t) (p (t + 1))

@[simp] lemma walkW_zero (A : V → V → ℝ) (p : ℕ → V) : walkW A p 0 = 0 := by
  simp [walkW]

lemma walkW_succ (A : V → V → ℝ) (p : ℕ → V) (m : ℕ) :
    walkW A p (m + 1) = walkW A p m + A (p m) (p (m + 1)) := by
  simp [walkW, Finset.sum_range_succ]

variable [Fintype V] [Nonempty V]

/-- Maximal weight of a walk from `i` to `j` using exactly `m + 1` edges. -/
def bestW (A : V → V → ℝ) : ℕ → V → V → ℝ
  | 0, i, j => A i j
  | (m + 1), i, j =>
      Finset.univ.sup' Finset.univ_nonempty (fun l => bestW A m i l + A l j)

@[simp] lemma bestW_zero (A : V → V → ℝ) (i j : V) : bestW A 0 i j = A i j := rfl

lemma bestW_succ (A : V → V → ℝ) (m : ℕ) (i j : V) :
    bestW A (m + 1) i j =
      Finset.univ.sup' Finset.univ_nonempty (fun l => bestW A m i l + A l j) := rfl

lemma bestW_succ_ge (A : V → V → ℝ) (m : ℕ) (i l j : V) :
    bestW A m i l + A l j ≤ bestW A (m + 1) i j := by
  rw [bestW_succ]
  exact Finset.le_sup' (fun l => bestW A m i l + A l j) (Finset.mem_univ l)

/-- Any walk of `m + 1` edges weighs at most the optimum `bestW`. -/
lemma walkW_le_bestW (A : V → V → ℝ) (p : ℕ → V) (m : ℕ) :
    walkW A p (m + 1) ≤ bestW A m (p 0) (p (m + 1)) := by
  induction m with
  | zero => simp [walkW, bestW]
  | succ m ih =>
      rw [walkW_succ]
      refine le_trans ?_ (bestW_succ_ge A m (p 0) (p (m + 1)) (p (m + 2)))
      gcongr

/-- The optimum `bestW` is attained by an actual walk. -/
lemma exists_walk_eq_bestW (A : V → V → ℝ) (m : ℕ) (i j : V) :
    ∃ p : ℕ → V, p 0 = i ∧ p (m + 1) = j ∧ walkW A p (m + 1) = bestW A m i j := by
  induction m generalizing j with
  | zero =>
      refine ⟨fun t => if t = 0 then i else j, by simp, by simp, ?_⟩
      simp [walkW, bestW]
  | succ m ih =>
      obtain ⟨l, -, hl⟩ :=
        Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := V))
          (fun l => bestW A m i l + A l j)
      obtain ⟨p, hp0, hpm, hpw⟩ := ih l
      refine ⟨fun t => if t ≤ m + 1 then p t else j, by simpa using hp0, by simp, ?_⟩
      have hsum : walkW A (fun t => if t ≤ m + 1 then p t else j) (m + 1) =
          walkW A p (m + 1) := by
        refine Finset.sum_congr rfl ?_
        intro t ht
        simp only [Finset.mem_range] at ht
        have h1 : t ≤ m + 1 := by omega
        have h2 : t + 1 ≤ m + 1 := by omega
        simp [h1, h2]
      rw [walkW_succ, hsum, hpw]
      simp only [le_refl, if_true, hpm]
      have : ¬ (m + 1 + 1 ≤ m + 1) := by omega
      rw [if_neg this, bestW_succ, hl]

/-! ### Prepending and concatenating -/

/-- The optimum can also be computed by peeling off the *first* edge. -/
lemma bestW_prepend (A : V → V → ℝ) (m : ℕ) : ∀ i j : V,
    bestW A (m + 1) i j =
      Finset.univ.sup' Finset.univ_nonempty (fun l => A i l + bestW A m l j) := by
  induction m with
  | zero => intro i j; rfl
  | succ m ih =>
      intro i j
      rw [bestW_succ]
      have step : ∀ l : V, bestW A (m + 1) i l + A l j =
          Finset.univ.sup' Finset.univ_nonempty
            (fun k => A i k + bestW A m k l + A l j) := by
        intro l; rw [ih i l, Finset.sup'_add]
      have h1 : (Finset.univ.sup' Finset.univ_nonempty
            (fun l => bestW A (m + 1) i l + A l j)) =
          Finset.univ.sup' Finset.univ_nonempty (fun l : V =>
            Finset.univ.sup' Finset.univ_nonempty (fun k : V => A i k + bestW A m k l + A l j)) := by
        refine Finset.sup'_congr _ rfl ?_
        intro l _; exact step l
      rw [h1, Finset.sup'_comm]
      refine Finset.sup'_congr _ rfl ?_
      intro k _
      rw [bestW_succ, Finset.add_sup']
      refine Finset.sup'_congr _ rfl ?_
      intro l _; ring

/-- Concatenating an optimal `i → l` walk with an optimal `l → j` walk. -/
lemma bestW_concat_ge (A : V → V → ℝ) (m k : ℕ) (i l j : V) :
    bestW A m i l + bestW A k l j ≤ bestW A (m + k + 1) i j := by
  induction k generalizing j with
  | zero => simpa using bestW_succ_ge A m i l j
  | succ k ih =>
      obtain ⟨l', -, hl'⟩ :=
        Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := V))
          (fun l' => bestW A k l l' + A l' j)
      have hsplit : bestW A (k + 1) l j = bestW A k l l' + A l' j := by
        rw [bestW_succ, hl']
      have h1 : bestW A m i l + bestW A k l l' ≤ bestW A (m + k + 1) i l' := ih l'
      have h2 : bestW A (m + k + 1) i l' + A l' j ≤ bestW A (m + (k + 1) + 1) i j := by
        have h := bestW_succ_ge A (m + k + 1) i l' j
        have hidx : m + k + 1 + 1 = m + (k + 1) + 1 := by omega
        rwa [hidx] at h
      calc bestW A m i l + bestW A (k + 1) l j
          = (bestW A m i l + bestW A k l l') + A l' j := by rw [hsplit]; ring
        _ ≤ bestW A (m + k + 1) i l' + A l' j := by gcongr
        _ ≤ bestW A (m + (k + 1) + 1) i j := h2

/-! ### Splitting a walk at a repeated vertex -/

/-- The walk obtained from `p` by deleting the loop between times `s` and `s + d`. -/
def cutWalk (p : ℕ → V) (s d : ℕ) : ℕ → V := fun u => if u ≤ s then p u else p (u + d)

lemma cutWalk_zero (p : ℕ → V) (s d : ℕ) : cutWalk p s d 0 = p 0 := by
  simp [cutWalk]

lemma cutWalk_of_le (p : ℕ → V) (s d u : ℕ) (h : u ≤ s) : cutWalk p s d u = p u := by
  simp [cutWalk, h]

lemma cutWalk_of_ge (p : ℕ → V) (s d u : ℕ) (hp : p s = p (s + d)) (h : s ≤ u) :
    cutWalk p s d u = p (u + d) := by
  rcases eq_or_lt_of_le h with h' | h'
  · subst h'; simp [cutWalk, hp]
  · have : ¬ (u ≤ s) := by omega
    simp [cutWalk, this]

/-- Pigeonhole: any infinite walk repeats a vertex within `card V` steps. -/
lemma exists_repeat (p : ℕ → V) :
    ∃ s t : ℕ, s < t ∧ t ≤ Fintype.card V ∧ p s = p t := by
  obtain ⟨x, y, hxy, hpe⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun x : Fin (Fintype.card V + 1) => p (x : ℕ)) (by simp)
  have hne : (x : ℕ) ≠ (y : ℕ) := fun h => hxy (Fin.ext h)
  rcases lt_or_gt_of_ne hne with h | h
  · exact ⟨x, y, h, by omega, hpe⟩
  · exact ⟨y, x, h, by omega, hpe.symm⟩

/-- Splitting the weight of a walk at a repeated vertex:
the loop from time `s` to time `s + d` contributes `walkW A (p ∘ (s + ·)) d`, and the
remaining walk is `cutWalk p s d`. -/
lemma walkW_split (A : V → V → ℝ) (p : ℕ → V) (s d e : ℕ) (hse : s ≤ e)
    (hp : p s = p (s + d)) :
    walkW A p (e + d) = walkW A (fun u => p (s + u)) d + walkW A (cutWalk p s d) e := by
  classical
  let f : ℕ → ℝ := fun w => A (p w) (p (w + 1))
  have hleft : walkW A p (e + d) = ∑ w ∈ Finset.Ico 0 (e + d), f w := by
    rw [walkW, Finset.range_eq_Ico]
  have hshift : walkW A (fun u => p (s + u)) d = ∑ w ∈ Finset.Ico s (s + d), f w := by
    rw [Finset.sum_Ico_eq_sum_range, walkW, Nat.add_sub_cancel_left]
    refine Finset.sum_congr rfl ?_
    intro u _
    show A (p (s + u)) (p (s + u + 1)) = A (p (s + u)) (p (s + u + 1))
    rfl
  have hcut : walkW A (cutWalk p s d) e =
      ∑ w ∈ Finset.Ico 0 s, f w + ∑ w ∈ Finset.Ico (s + d) (e + d), f w := by
    have h0 : walkW A (cutWalk p s d) e =
        ∑ u ∈ Finset.Ico 0 s, A (cutWalk p s d u) (cutWalk p s d (u + 1)) +
        ∑ u ∈ Finset.Ico s e, A (cutWalk p s d u) (cutWalk p s d (u + 1)) := by
      rw [walkW, Finset.range_eq_Ico,
        ← Finset.sum_Ico_consecutive _ (Nat.zero_le s) hse]
    have h1 : ∑ u ∈ Finset.Ico 0 s, A (cutWalk p s d u) (cutWalk p s d (u + 1)) =
        ∑ w ∈ Finset.Ico 0 s, f w := by
      refine Finset.sum_congr rfl ?_
      intro u hu
      simp only [Finset.mem_Ico] at hu
      rw [cutWalk_of_le p s d u (by omega), cutWalk_of_le p s d (u + 1) (by omega)]
    have h2 : ∑ u ∈ Finset.Ico s e, A (cutWalk p s d u) (cutWalk p s d (u + 1)) =
        ∑ w ∈ Finset.Ico (s + d) (e + d), f w := by
      have : ∑ u ∈ Finset.Ico s e, A (cutWalk p s d u) (cutWalk p s d (u + 1)) =
          ∑ u ∈ Finset.Ico s e, f (u + d) := by
        refine Finset.sum_congr rfl ?_
        intro u hu
        simp only [Finset.mem_Ico] at hu
        rw [cutWalk_of_ge p s d u hp (by omega), cutWalk_of_ge p s d (u + 1) hp (by omega)]
        show A (p (u + d)) (p (u + 1 + d)) = A (p (u + d)) (p (u + d + 1))
        rw [Nat.add_right_comm]
      rw [this, Finset.sum_Ico_add' f s e d]
    rw [h0, h1, h2]
  have hcons : ∑ w ∈ Finset.Ico 0 s, f w + ∑ w ∈ Finset.Ico s (s + d), f w
      = ∑ w ∈ Finset.Ico 0 (s + d), f w :=
    Finset.sum_Ico_consecutive f (Nat.zero_le s) (Nat.le_add_right s d)
  have hcons2 : ∑ w ∈ Finset.Ico 0 (s + d), f w + ∑ w ∈ Finset.Ico (s + d) (e + d), f w
      = ∑ w ∈ Finset.Ico 0 (e + d), f w :=
    Finset.sum_Ico_consecutive f (Nat.zero_le _) (by omega)
  rw [hleft, hshift, hcut, ← hcons2, ← hcons]
  ring

/-! ### The maximal cycle mean -/

/-- Index set for cycles of length at most `card V`. -/
def cycleIndex (V : Type*) [Fintype V] : Finset (ℕ × V) :=
  (Finset.range (Fintype.card V)) ×ˢ (Finset.univ : Finset V)

lemma cycleIndex_nonempty : (cycleIndex V).Nonempty := by
  refine Finset.Nonempty.product ⟨0, Finset.mem_range.mpr Fintype.card_pos⟩ Finset.univ_nonempty

/-- The maximal cycle mean of `A`, taken over closed walks of at most `card V` edges. -/
def cycleMax (A : V → V → ℝ) : ℝ :=
  (cycleIndex V).sup' cycleIndex_nonempty
    (fun ki => bestW A ki.1 ki.2 ki.2 / (ki.1 + 1))

lemma bestW_diag_le_cycleMax (A : V → V → ℝ) {k : ℕ} (hk : k < Fintype.card V) (i : V) :
    bestW A k i i ≤ (k + 1) * cycleMax A := by
  have hmem : (k, i) ∈ cycleIndex V := by
    simp [cycleIndex, Finset.mem_range.mpr hk]
  have h := Finset.le_sup' (fun ki : ℕ × V => bestW A ki.1 ki.2 ki.2 / (ki.1 + 1)) hmem
  have hpos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  rw [div_le_iff₀ hpos] at h
  calc bestW A k i i = bestW A k i i / ((k : ℝ) + 1) * ((k : ℝ) + 1) := by
        field_simp
    _ ≤ cycleMax A * ((k : ℝ) + 1) := by
        exact mul_le_mul_of_nonneg_right (by
          rw [div_le_iff₀ hpos]; exact h) (le_of_lt hpos)
    _ = ((k : ℝ) + 1) * cycleMax A := by ring

/-- **Cycle-mean bound**: every closed walk has weight at most its length times the
maximal cycle mean.  Proved by strong induction on the length: a walk longer than
`card V` revisits a vertex, and splits into two strictly shorter closed walks. -/
lemma walkW_le_cycleMax (A : V → V → ℝ) :
    ∀ m : ℕ, 1 ≤ m → ∀ p : ℕ → V, p 0 = p m → walkW A p m ≤ m * cycleMax A := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro hm p hp
    by_cases hsmall : m ≤ Fintype.card V
    · obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
      have h1 : walkW A p (m' + 1) ≤ bestW A m' (p 0) (p (m' + 1)) := walkW_le_bestW A p m'
      rw [← hp] at h1
      have h2 : bestW A m' (p 0) (p 0) ≤ (m' + 1) * cycleMax A :=
        bestW_diag_le_cycleMax A (by omega) (p 0)
      have : ((m' : ℝ) + 1) = ((m' + 1 : ℕ) : ℝ) := by push_cast; ring
      rw [this] at h2
      exact le_trans h1 h2
    · push_neg at hsmall
      obtain ⟨s, t, hst, htN, hpst⟩ := exists_repeat p
      set d := t - s with hd
      have hd1 : 1 ≤ d := by omega
      have hdN : d ≤ Fintype.card V := by omega
      set e := m - d with he
      have hed : e + d = m := by omega
      have hse : s ≤ e := by omega
      have he1 : 1 ≤ e := by omega
      have hsd : p s = p (s + d) := by
        have : s + d = t := by omega
        rw [this]; exact hpst
      have hsplit := walkW_split A p s d e hse hsd
      rw [hed] at hsplit
      have hinner : walkW A (fun u => p (s + u)) d ≤ d * cycleMax A := by
        refine ih d (by omega) hd1 _ ?_
        simpa using hsd
      have houter : walkW A (cutWalk p s d) e ≤ e * cycleMax A := by
        refine ih e (by omega) he1 _ ?_
        rw [cutWalk_zero, cutWalk_of_ge p s d e hsd hse, hed, ← hp]
      have hsum : ((d : ℝ) + e) = (m : ℝ) := by
        have : (d + e : ℕ) = m := by omega
        exact_mod_cast congrArg (fun x : ℕ => (x : ℝ)) this
      rw [hsplit]
      calc walkW A (fun u => p (s + u)) d + walkW A (cutWalk p s d) e
          ≤ d * cycleMax A + e * cycleMax A := add_le_add hinner houter
        _ = ((d : ℝ) + e) * cycleMax A := by ring
        _ = m * cycleMax A := by rw [hsum]

/-! ### Normalising by the maximal cycle mean -/

omit [Fintype V] [Nonempty V] in
lemma walkW_sub_const (A : V → V → ℝ) (r : ℝ) (p : ℕ → V) (m : ℕ) :
    walkW (fun i j => A i j - r) p m = walkW A p m - m * r := by
  simp [walkW, Finset.sum_sub_distrib]

lemma bestW_sub_const (A : V → V → ℝ) (r : ℝ) (m : ℕ) (i j : V) :
    bestW (fun i j => A i j - r) m i j = bestW A m i j - (m + 1) * r := by
  induction m generalizing j with
  | zero => simp [bestW]
  | succ m ih =>
      rw [bestW_succ, bestW_succ]
      have : ∀ l : V, bestW (fun i j => A i j - r) m i l + (A l j - r)
          = (bestW A m i l + A l j) + (-((m : ℝ) + 2) * r) := by
        intro l; rw [ih l]; ring
      have hcongr : (Finset.univ.sup' Finset.univ_nonempty
            (fun l => bestW (fun i j => A i j - r) m i l + (A l j - r)))
          = Finset.univ.sup' Finset.univ_nonempty
            (fun l : V => (bestW A m i l + A l j) + (-((m : ℝ) + 2) * r)) := by
        refine Finset.sup'_congr _ rfl ?_
        intro l _; exact this l
      rw [hcongr, ← Finset.sup'_add]
      push_cast
      ring

/-! ### The Kleene-star column and the eigenvector -/

lemma starRange_nonempty : (Finset.range (2 * Fintype.card V + 1)).Nonempty :=
  Finset.nonempty_range_iff.mpr (by omega)

/-- Kleene-star column at `c`: the best weight of a walk from `i` to `c` using at most
`2 · card V + 1` edges. -/
def starCol (A : V → V → ℝ) (c i : V) : ℝ :=
  (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty (fun m => bestW A m i c)

/-- If no closed walk has positive weight, walks longer than `2·card V + 1` edges never
beat the ones counted in `starCol`. -/
lemma bestW_le_starCol {A : V → V → ℝ}
    (H1 : ∀ m : ℕ, 1 ≤ m → ∀ p : ℕ → V, p 0 = p m → walkW A p m ≤ 0) (c : V) :
    ∀ m : ℕ, ∀ i : V, bestW A m i c ≤ starCol A c i := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro i
    by_cases hm : m ≤ 2 * Fintype.card V
    · exact Finset.le_sup' (fun m => bestW A m i c) (Finset.mem_range.mpr (by omega))
    · push_neg at hm
      obtain ⟨p, hp0, hpm, hpw⟩ := exists_walk_eq_bestW A m i c
      obtain ⟨s, t, hst, htN, hpst⟩ := exists_repeat p
      have hcard : 1 ≤ Fintype.card V := Fintype.card_pos
      have hd1 : 1 ≤ t - s := by omega
      have hdm : t - s ≤ m := by omega
      have hse : s ≤ (m - (t - s)) + 1 := by omega
      have hed : (m - (t - s)) + 1 + (t - s) = m + 1 := by omega
      have hsd : p s = p (s + (t - s)) := by
        have hts : s + (t - s) = t := by omega
        rw [hts]; exact hpst
      have hsplit := walkW_split A p s (t - s) ((m - (t - s)) + 1) hse hsd
      rw [hed] at hsplit
      have hinner : walkW A (fun u => p (s + u)) (t - s) ≤ 0 := by
        refine H1 (t - s) hd1 _ ?_
        simpa using hsd
      have houter : walkW A (cutWalk p s (t - s)) ((m - (t - s)) + 1)
          ≤ bestW A (m - (t - s)) i c := by
        have h := walkW_le_bestW A (cutWalk p s (t - s)) (m - (t - s))
        rw [cutWalk_zero, hp0,
          cutWalk_of_ge p s (t - s) ((m - (t - s)) + 1) hsd hse, hed, hpm] at h
        exact h
      calc bestW A m i c = walkW A p (m + 1) := hpw.symm
        _ = walkW A (fun u => p (s + u)) (t - s)
              + walkW A (cutWalk p s (t - s)) ((m - (t - s)) + 1) := hsplit
        _ ≤ 0 + bestW A (m - (t - s)) i c := add_le_add hinner houter
        _ = bestW A (m - (t - s)) i c := zero_add _
        _ ≤ starCol A c i := ih (m - (t - s)) (by omega) i

/-- **Eigenvector for a normalised matrix.**  If no closed walk of `A` has positive
weight and some cycle through `c` has weight exactly `0`, then the Kleene-star column
at `c` is a max-plus eigenvector with eigenvalue `0`. -/
theorem exists_normalized_eigenvector {A : V → V → ℝ}
    (H1 : ∀ m : ℕ, 1 ≤ m → ∀ p : ℕ → V, p 0 = p m → walkW A p m ≤ 0)
    {c : V} {L : ℕ} (hL : L < Fintype.card V) (hc : bestW A L c c = 0) :
    ∃ v : V → ℝ, ∀ i : V,
      Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + v j) = v i := by
  refine ⟨starCol A c, fun i => ?_⟩
  have hLmem : L ∈ Finset.range (2 * Fintype.card V + 1) :=
    Finset.mem_range.mpr (by omega)
  -- rewrite the left-hand side as a supremum over walk lengths
  have step1 : Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + starCol A c j)
      = Finset.univ.sup' Finset.univ_nonempty (fun j : V =>
          (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty
            (fun m => A i j + bestW A m j c)) := by
    refine Finset.sup'_congr _ rfl ?_
    intro j _
    rw [starCol, Finset.add_sup']
  have step2 : Finset.univ.sup' Finset.univ_nonempty (fun j : V =>
          (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty
            (fun m => A i j + bestW A m j c))
      = (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty (fun m =>
          Finset.univ.sup' Finset.univ_nonempty (fun j : V => A i j + bestW A m j c)) :=
    Finset.sup'_comm _ _ _
  have step3 : (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty (fun m =>
          Finset.univ.sup' Finset.univ_nonempty (fun j : V => A i j + bestW A m j c))
      = (Finset.range (2 * Fintype.card V + 1)).sup' starRange_nonempty
          (fun m => bestW A (m + 1) i c) := by
    refine Finset.sup'_congr _ rfl ?_
    intro m _
    exact (bestW_prepend A m i c).symm
  rw [step1, step2, step3]
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ ?_
    intro m _
    exact bestW_le_starCol H1 c (m + 1) i
  · refine Finset.sup'_le _ _ ?_
    intro m _
    match m with
    | 0 =>
        have hcat := bestW_concat_ge A 0 L i c c
        rw [hc, add_zero, Nat.zero_add] at hcat
        exact le_trans hcat
          (Finset.le_sup' (fun m => bestW A (m + 1) i c) hLmem)
    | (m + 1) =>
        exact Finset.le_sup' (fun m => bestW A (m + 1) i c)
          (Finset.mem_range.mpr (by
            have := Finset.mem_range.mp (by assumption : m + 1 ∈ Finset.range (2 * Fintype.card V + 1))
            omega))

/-! ### General tropical Perron–Frobenius theorem -/

/-- **Tropical (max-plus) Perron–Frobenius theorem.**  Every real matrix indexed by a
nonempty finite type has a max-plus eigenvector; the eigenvalue is the maximal cycle
mean of the matrix. -/
theorem exists_tropical_eigenvector (A : V → V → ℝ) :
    ∃ (mu : ℝ) (v : V → ℝ), ∀ i : V,
      Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + v j) = mu + v i := by
  classical
  have H1 : ∀ m : ℕ, 1 ≤ m → ∀ p : ℕ → V,
      p 0 = p m → walkW (fun i j => A i j - cycleMax A) p m ≤ 0 := by
    intro m hm p hp
    rw [walkW_sub_const]
    have h := walkW_le_cycleMax A m hm p hp
    linarith
  obtain ⟨ki, hki, hval⟩ :=
    Finset.exists_mem_eq_sup' (cycleIndex_nonempty (V := V))
      (fun ki : ℕ × V => bestW A ki.1 ki.2 ki.2 / (ki.1 + 1))
  have hk : ki.1 < Fintype.card V := by simpa [cycleIndex] using hki
  have hcyc : cycleMax A = bestW A ki.1 ki.2 ki.2 / ((ki.1 : ℝ) + 1) := by
    rw [cycleMax]; exact hval
  have hc : bestW (fun i j => A i j - cycleMax A) ki.1 ki.2 ki.2 = 0 := by
    rw [bestW_sub_const, hcyc]
    have hpos : ((ki.1 : ℝ) + 1) ≠ 0 := by positivity
    field_simp
    ring
  obtain ⟨v, hv⟩ := exists_normalized_eigenvector H1 hk hc
  refine ⟨cycleMax A, v, fun i => ?_⟩
  have hpoint : ∀ j : V, A i j + v j = ((A i j - cycleMax A) + v j) + cycleMax A := by
    intro j; ring
  have hrw : Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + v j)
      = Finset.univ.sup' Finset.univ_nonempty
          (fun j : V => ((A i j - cycleMax A) + v j) + cycleMax A) := by
    refine Finset.sup'_congr _ rfl ?_
    intro j _; exact hpoint j
  rw [hrw, ← Finset.sup'_add, hv i]
  ring