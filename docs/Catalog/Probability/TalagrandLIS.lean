import Probability.TalagrandCertifiable

/-!
# Concentration of the longest increasing subsequence

The classical application of Talagrand's inequality that bounded differences
cannot reach: the length `L` of the longest (weakly) increasing subsequence of a
random word concentrates on the scale `√L` rather than `√m`, because a witnessing
subsequence is a *certificate* of size `L` in the sense of
`Talagrand.certifiable_concentration`.

## Main results

* `Talagrand.lis` — the length of the longest increasing subsequence of a word
  `x : Fin m → α` over a linearly ordered alphabet, as a real number.
* `Talagrand.lis_lipschitz` — `lis` is `1`-Lipschitz for the plain Hamming metric.
* `Talagrand.lis_cert` — a witnessing subsequence of length `⌈l⌉` certifies
  `lis ≥ l`.
* `Talagrand.lis_concentration` — for an arbitrary product measure on words,
  `P(lis ≤ b) · P(lis ≥ l) ≤ exp (-(l - b)² / (4⌈l⌉))`.  The deviation scale is
  `√l`, not `√m`.
-/

namespace Talagrand

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α] [LinearOrder α] {m : ℕ}

/-- `S` indexes a weakly increasing subsequence of the word `x`. -/
def IsIncr (x : Fin m → α) (S : Finset (Fin m)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, i ≤ j → x i ≤ x j

instance (x : Fin m → α) : DecidablePred (IsIncr x) := fun _ => by
  unfold IsIncr; infer_instance

/-- The length of the longest weakly increasing subsequence of `x`. -/
def lis (x : Fin m → α) : ℝ :=
  (((Finset.univ.filter (IsIncr x)).sup Finset.card : ℕ) : ℝ)

omit [Fintype α] [DecidableEq α] in
lemma incr_filter_nonempty (x : Fin m → α) :
    (Finset.univ.filter (IsIncr x)).Nonempty := by
  refine ⟨∅, ?_⟩
  simp [IsIncr]

omit [Fintype α] [DecidableEq α] in
/-- Every increasing subsequence is at most as long as the longest one. -/
lemma card_le_lis {x : Fin m → α} {S : Finset (Fin m)} (hS : IsIncr x S) :
    (S.card : ℝ) ≤ lis x := by
  have hmem : S ∈ Finset.univ.filter (IsIncr x) := by
    simp [Finset.mem_filter, hS]
  have h := Finset.le_sup (f := Finset.card) hmem
  rw [lis]
  exact_mod_cast h

omit [Fintype α] [DecidableEq α] in
/-- The longest increasing subsequence is realised. -/
lemma exists_incr_card_eq_lis (x : Fin m → α) :
    ∃ S : Finset (Fin m), IsIncr x S ∧ (S.card : ℝ) = lis x := by
  obtain ⟨S, hS, hsup⟩ :=
    Finset.exists_mem_eq_sup _ (incr_filter_nonempty x) Finset.card
  refine ⟨S, (Finset.mem_filter.mp hS).2, ?_⟩
  rw [lis, ← hsup]

omit [Fintype α] [DecidableEq α] in
/-- A single position is an increasing subsequence, so `lis ≥ 1` on nonempty words. -/
lemma one_le_lis (hm : 0 < m) (x : Fin m → α) : 1 ≤ lis x := by
  have hincr : IsIncr x {(⟨0, hm⟩ : Fin m)} := by
    intro i hi j hj _
    rw [Finset.mem_singleton.mp hi, Finset.mem_singleton.mp hj]
  simpa using card_le_lis hincr

omit [Fintype α] [DecidableEq α] in
/-- **Non-degeneracy.**  On a strictly decreasing word the longest increasing
subsequence has length exactly `1`, so `lis` is far from the trivial bound `m`. -/
lemma lis_eq_one_of_decreasing (hm : 0 < m) {x : Fin m → α}
    (h : ∀ i j : Fin m, i < j → x j < x i) : lis x = 1 := by
  refine le_antisymm ?_ (one_le_lis hm x)
  have hup : (Finset.univ.filter (IsIncr x)).sup Finset.card ≤ 1 := by
    refine Finset.sup_le fun S hS => ?_
    have hincr := (Finset.mem_filter.mp hS).2
    refine Finset.card_le_one.mpr fun a ha b hb => ?_
    rcases lt_trichotomy a b with hab | hab | hab
    · exact absurd (hincr a ha b hb hab.le) (not_le.mpr (h a b hab))
    · exact hab
    · exact absurd (hincr b hb a ha hab.le) (not_le.mpr (h b a hab))
  calc lis x = ((Finset.univ.filter (IsIncr x)).sup Finset.card : ℕ) := rfl
    _ ≤ ((1 : ℕ) : ℝ) := by exact_mod_cast hup
    _ = 1 := by norm_num

omit [Fintype α] [LinearOrder α] in
/-- The Hamming distance counts the coordinates where two words differ. -/
lemma sum_hamm_eq_card_diff (x y : Fin m → α) :
    ∑ i, hamm (x i) (y i)
      = ((Finset.univ.filter (fun i => x i ≠ y i)).card : ℝ) := by
  classical
  have hstep : ∀ i : Fin m, hamm (x i) (y i) = if x i ≠ y i then (1:ℝ) else 0 := by
    intro i
    unfold hamm
    by_cases h : x i = y i <;> simp [h]
  rw [Finset.sum_congr rfl fun i _ => hstep i, Finset.sum_boole]

omit [Fintype α] in
/-- **`lis` is `1`-Lipschitz for the plain Hamming metric.** -/
lemma lis_lipschitz (x y : Fin m → α) :
    lis x ≤ lis y + ∑ i, hamm (x i) (y i) := by
  classical
  obtain ⟨S, hS, hcard⟩ := exists_incr_card_eq_lis x
  set D : Finset (Fin m) := Finset.univ.filter (fun i => x i ≠ y i) with hD
  set S' : Finset (Fin m) := S.filter (fun i => x i = y i) with hS'
  have hincr' : IsIncr y S' := by
    intro i hi j hj hij
    obtain ⟨hiS, hix⟩ := Finset.mem_filter.mp hi
    obtain ⟨hjS, hjx⟩ := Finset.mem_filter.mp hj
    rw [← hix, ← hjx]
    exact hS i hiS j hjS hij
  have hsub : S ⊆ S' ∪ D := by
    intro i hi
    by_cases hxy : x i = y i
    · exact Finset.mem_union_left _ (Finset.mem_filter.mpr ⟨hi, hxy⟩)
    · exact Finset.mem_union_right _ (Finset.mem_filter.mpr ⟨Finset.mem_univ i, hxy⟩)
  have hcards : S.card ≤ S'.card + D.card :=
    le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)
  have hcardsR : (S.card : ℝ) ≤ (S'.card : ℝ) + (D.card : ℝ) := by exact_mod_cast hcards
  have h1 : (S'.card : ℝ) ≤ lis y := card_le_lis hincr'
  have h2 : ∑ i, hamm (x i) (y i) = (D.card : ℝ) := sum_hamm_eq_card_diff x y
  linarith [hcard.ge, hcard.le]

omit [Fintype α] [DecidableEq α] in
/-- **A witnessing subsequence is a certificate.**  If `lis x ≥ l`, then `⌈l⌉` of
the coordinates of `x` already force every word agreeing with `x` there to have
`lis ≥ l`. -/
lemma lis_cert {l : ℝ} {x : Fin m → α} (hx : l ≤ lis x) :
    ∃ J : Finset (Fin m), ((J.card : ℝ)) ≤ (⌈l⌉₊ : ℝ) ∧
      ∀ y : Fin m → α, (∀ i ∈ J, y i = x i) → l ≤ lis y := by
  classical
  obtain ⟨S, hS, hcard⟩ := exists_incr_card_eq_lis x
  have hle : (⌈l⌉₊ : ℕ) ≤ S.card := by
    apply Nat.ceil_le.mpr
    rw [hcard]; exact hx
  obtain ⟨J, hJS, hJcard⟩ := Finset.exists_subset_card_eq hle
  refine ⟨J, by rw [hJcard], fun y hy => ?_⟩
  have hincr : IsIncr y J := by
    intro i hi j hj hij
    rw [hy i hi, hy j hj]
    exact hS i (hJS hi) j (hJS hj) hij
  have h1 : (J.card : ℝ) ≤ lis y := card_le_lis hincr
  have h2 : l ≤ (J.card : ℝ) := by
    rw [hJcard]; exact Nat.le_ceil l
  linarith

/-- **Talagrand concentration for the longest increasing subsequence.**  For an
arbitrary product measure on words of length `m`, the sublevel set `{lis ≤ b}`
and the superlevel set `{lis ≥ l}` satisfy
`P(lis ≤ b) · P(lis ≥ l) ≤ exp (-(l - b)² / (4⌈l⌉))`: the deviation is measured on
the scale `√l` of a witnessing subsequence, not on the scale `√m` given by the
bounded-differences inequality. -/
theorem lis_concentration {p : Fin m → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (A S : Finset (Fin m → α)) (hA : A.Nonempty)
    {b l : ℝ} (hl : 0 < l) (hbl : b ≤ l)
    (hAle : ∀ y ∈ A, lis y ≤ b) (hSge : ∀ x ∈ S, l ≤ lis x) :
    mass p A * mass p S ≤ Real.exp (-((l - b) ^ 2 / (4 * (⌈l⌉₊ : ℝ)))) := by
  have hK : (0 : ℝ) < (⌈l⌉₊ : ℝ) := by
    have : 0 < ⌈l⌉₊ := Nat.ceil_pos.mpr hl
    exact_mod_cast this
  exact certifiable_concentration hp0 hp1 lis_lipschitz A S hA hK hbl hAle
    (fun x hx => lis_cert (hSge x hx))

end Talagrand