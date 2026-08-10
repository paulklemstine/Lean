import MachineLearning.SemitotalDomination.PathUpperBound

/-!
# The matching lower bound `γ_t2(Pₙ) ≥ ⌈2n/5⌉`

`PathUpperBound.lean` produces an explicit semitotal dominating set of the path of size
`2⌈n/5⌉`.  Here we prove the complementary *lower* bound

`2n ≤ 5 · γ_t2(Pₙ)`, i.e. `γ_t2(Pₙ) ≥ ⌈2n/5⌉`,

which is the hard half of Conjecture 1 of `FUTURE_DIRECTIONS.md`.  The two bounds coincide
whenever `5 ∣ n`, giving the exact value `γ_t2(P₅q) = 2q` for an infinite family.

## The argument

Write a semitotal dominating set of the path as an increasing sequence `s₀ < s₁ < ⋯ < s_{k-1}`
and let `gᵢ = s_{i+1} − sᵢ` be its gaps.  Then

* domination of the vertex `sᵢ + 2` forces `gᵢ ≤ 3`;
* the semitotal condition forces, for every `i`, `min(g_{i−1}, gᵢ) ≤ 2` — in particular
  `g₀ ≤ 2` and `g_{k−2} ≤ 2`, and no two consecutive gaps can both equal `3`;
* domination of the two endpoints gives `s₀ ≤ 1` and `n ≤ s_{k−1} + 2`.

A "gap `3` must be paid for by a neighbouring gap `≤ 2`" induction (the invariant
`2 sᵢ + [gᵢ₋₁ ≤ 2] ≤ 5i + 2 s₀`) then yields `2 s_{k−1} + 1 ≤ 5(k−1) + 2 s₀`, and hence
`2n ≤ 5k`.

Everything is carried out on `Finset ℕ` (the vertex labels) and transferred to `Fin n` at the end.
-/

namespace SemitotalDomination

open Finset SimpleGraph

/-- Increasing enumeration of a finite set of naturals. -/
theorem exists_strictMono_enum (T : Finset ℕ) :
    ∃ s : ℕ → ℕ, (∀ i, i < T.card → s i ∈ T) ∧
      (∀ i j, i < j → j < T.card → s i < s j) ∧
      (∀ t ∈ T, ∃ i, i < T.card ∧ s i = t) := by
  classical
  refine ⟨fun i => if h : i < T.card then (T.orderIsoOfFin rfl ⟨i, h⟩ : ℕ) else 0, ?_, ?_, ?_⟩
  · intro i h
    dsimp only
    rw [dif_pos h]
    exact (T.orderIsoOfFin rfl ⟨i, h⟩).2
  · intro i j hij hj
    have hi : i < T.card := lt_trans hij hj
    dsimp only
    rw [dif_pos hi, dif_pos hj]
    exact_mod_cast (T.orderIsoOfFin rfl).lt_iff_lt.mpr
      (show (⟨i, hi⟩ : Fin T.card) < ⟨j, hj⟩ from hij)
  · intro t ht
    obtain ⟨i, hi⟩ := (T.orderIsoOfFin (rfl : T.card = T.card)).surjective ⟨t, ht⟩
    refine ⟨i, i.isLt, ?_⟩
    dsimp only
    rw [dif_pos i.isLt]
    have hii : (⟨(i : ℕ), i.isLt⟩ : Fin T.card) = i := rfl
    rw [hii]
    exact congrArg Subtype.val hi

/-- **The counting core.**  A set of labels in `{0, …, n−1}` that dominates every label
(within distance `1`) and in which every element has another element within distance `2` has at
least `2n/5` elements. -/
theorem two_mul_le_five_mul_card_of_semitotal_range (n : ℕ) (T : Finset ℕ)
    (hsub : ∀ t ∈ T, t < n)
    (hdom : ∀ v, v < n → ∃ t ∈ T, t ≤ v + 1 ∧ v ≤ t + 1)
    (hpart : ∀ t ∈ T, ∃ u ∈ T, u ≠ t ∧ u ≤ t + 2 ∧ t ≤ u + 2) :
    2 * n ≤ 5 * T.card := by
  classical
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  obtain ⟨s, hmem, hmono, hsurj⟩ := exists_strictMono_enum T
  set k := T.card with hk
  have hle : ∀ i j, i ≤ j → j < k → s i ≤ s j := by
    intro i j hij hj
    rcases eq_or_lt_of_le hij with rfl | h
    · exact le_rfl
    · exact (hmono i j h hj).le
  have hk2 : 2 ≤ k := by
    obtain ⟨t, ht, -, -⟩ := hdom 0 hn
    obtain ⟨u, hu, hne, -, -⟩ := hpart t ht
    have hsubs : ({u, t} : Finset ℕ) ⊆ T := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> assumption
    have hcard : ({u, t} : Finset ℕ).card = 2 := by
      rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
    calc 2 = ({u, t} : Finset ℕ).card := hcard.symm
      _ ≤ T.card := Finset.card_le_card hsubs
  have hmin : ∀ t ∈ T, s 0 ≤ t := by
    intro t ht
    obtain ⟨i, hi, rfl⟩ := hsurj t ht
    exact hle 0 i (Nat.zero_le i) hi
  have hmax : ∀ t ∈ T, t ≤ s (k - 1) := by
    intro t ht
    obtain ⟨i, hi, rfl⟩ := hsurj t ht
    exact hle i (k - 1) (by omega) (by omega)
  have hbetween : ∀ i, i + 1 < k → ∀ t ∈ T, ¬ (s i < t ∧ t < s (i + 1)) := by
    rintro i hi t ht ⟨h1, h2⟩
    obtain ⟨j, hj, rfl⟩ := hsurj t ht
    rcases Nat.lt_or_ge j (i + 1) with h | h
    · exact absurd (hle j i (by omega) (by omega)) (by omega)
    · exact absurd (hle (i + 1) j h hj) (by omega)
  have h0 : s 0 ≤ 1 := by
    obtain ⟨t, ht, h1, -⟩ := hdom 0 hn
    exact le_trans (hmin t ht) (by omega)
  have hlastge : n ≤ s (k - 1) + 2 := by
    obtain ⟨t, ht, -, h2⟩ := hdom (n - 1) (by omega)
    have := hmax t ht
    omega
  -- domination forces every gap to be at most `3`
  have hgap : ∀ i, i + 1 < k → s (i + 1) ≤ s i + 3 := by
    intro i hi
    by_contra hc
    push_neg at hc
    have hlt : s (i + 1) < n := hsub _ (hmem _ hi)
    obtain ⟨t, ht, h1, h2⟩ := hdom (s i + 2) (by omega)
    exact hbetween i hi t ht ⟨by omega, by omega⟩
  -- the semitotal condition: each element has a neighbouring element within distance `2`
  have hpartner : ∀ i, i < k →
      (0 < i ∧ s i ≤ s (i - 1) + 2) ∨ (i + 1 < k ∧ s (i + 1) ≤ s i + 2) := by
    intro i hi
    obtain ⟨u, hu, hne, h1, h2⟩ := hpart (s i) (hmem i hi)
    obtain ⟨j, hj, rfl⟩ := hsurj u hu
    have hij : j ≠ i := by rintro rfl; exact hne rfl
    rcases Nat.lt_or_ge j i with h | h
    · refine Or.inl ⟨by omega, ?_⟩
      have := hle j (i - 1) (by omega) (by omega)
      omega
    · refine Or.inr ⟨by omega, ?_⟩
      have := hle (i + 1) j (by omega) hj
      omega
  -- the discharging invariant: a gap of `3` has to be paid for by a neighbouring gap `≤ 2`
  have Q : ∀ i, 1 ≤ i → i < k →
      2 * s i + (if s i ≤ s (i - 1) + 2 then 1 else 0) ≤ 5 * i + 2 * s 0 := by
    intro i
    induction i with
    | zero => intro h; omega
    | succ i ih =>
      intro _ hik
      rcases Nat.eq_zero_or_pos i with rfl | hipos
      · have := hpartner 0 (by omega)
        rcases this with ⟨h, -⟩ | ⟨-, h2⟩
        · omega
        · simp only [Nat.add_sub_cancel, if_pos h2]
          omega
      · have hQi := ih hipos (by omega)
        have hQi' : 2 * s i ≤ 5 * i + 2 * s 0 := by split_ifs at hQi <;> omega
        by_cases hc : s (i + 1) ≤ s i + 2
        · simp only [Nat.add_sub_cancel, if_pos hc]
          omega
        · simp only [Nat.add_sub_cancel, if_neg hc]
          have h3 := hgap i (by omega)
          rcases hpartner i (by omega) with ⟨-, hback⟩ | ⟨-, hfwd⟩
          · rw [if_pos hback] at hQi
            omega
          · exact absurd hfwd hc
  have hfin := Q (k - 1) (by omega) (by omega)
  rcases hpartner (k - 1) (by omega) with ⟨-, hback⟩ | ⟨hbad, -⟩
  · rw [if_pos hback] at hfin
    omega
  · omega

/-- `Within2` in a path means the labels differ by at most `2`. -/
lemma within2_pathGraph_le {n : ℕ} {u v : Fin n} (h : Within2 (pathGraph n) u v) :
    (u : ℕ) ≤ (v : ℕ) + 2 ∧ (v : ℕ) ≤ (u : ℕ) + 2 := by
  rcases h with rfl | hadj | ⟨w, h1, h2⟩
  · omega
  · rw [pathGraph_adj] at hadj; omega
  · rw [pathGraph_adj] at h1 h2; omega

/-- **Lower bound for paths.**  Every semitotal dominating set `S` of `Pₙ` satisfies
`2n ≤ 5|S|`. -/
theorem two_mul_le_five_mul_card_of_semitotalDominatingSet_pathGraph {n : ℕ} {S : Finset (Fin n)}
    (hS : IsSemitotalDominatingSet (pathGraph n) S) : 2 * n ≤ 5 * S.card := by
  classical
  obtain ⟨hdom, hst⟩ := hS
  have hcard : (S.image (Fin.val)).card = S.card :=
    Finset.card_image_of_injective S Fin.val_injective
  rw [← hcard]
  refine two_mul_le_five_mul_card_of_semitotal_range n _ ?_ ?_ ?_
  · intro t ht
    obtain ⟨x, -, rfl⟩ := Finset.mem_image.1 ht
    exact x.isLt
  · intro v hv
    rcases hdom ⟨v, hv⟩ with hmem | ⟨d, hd, hadj⟩
    · exact ⟨v, Finset.mem_image.2 ⟨⟨v, hv⟩, hmem, rfl⟩, by omega, by omega⟩
    · rw [pathGraph_adj] at hadj
      exact ⟨(d : ℕ), Finset.mem_image.2 ⟨d, hd, rfl⟩, by simp at hadj ⊢; omega,
        by simp at hadj ⊢; omega⟩
  · intro t ht
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 ht
    obtain ⟨u, hu, hne, hw⟩ := hst x hx
    obtain ⟨h1, h2⟩ := within2_pathGraph_le hw
    exact ⟨(u : ℕ), Finset.mem_image.2 ⟨u, hu, rfl⟩,
      fun hc => hne (Fin.ext hc), by omega, by omega⟩

/-- **`γ_t2(Pₙ) ≥ ⌈2n/5⌉`.** -/
theorem ceil_two_mul_div_five_le_semitotalDominationNumber_pathGraph {n : ℕ} (hn : 2 ≤ n) :
    (2 * n + 4) / 5 ≤ semitotalDominationNumber (pathGraph n) := by
  obtain ⟨S, hS, hcard⟩ := exists_semitotal_card_eq (exists_semitotalDominatingSet_pathGraph hn)
  have := two_mul_le_five_mul_card_of_semitotalDominatingSet_pathGraph hS
  omega

/-- **Exact value on an infinite family.**  For `q ≥ 1`, `γ_t2(P₅q) = 2q`: the periodic
construction of `PathUpperBound.lean` is optimal whenever `5 ∣ n`. -/
theorem semitotalDominationNumber_pathGraph_five_mul {q : ℕ} (hq : 1 ≤ q) :
    semitotalDominationNumber (pathGraph (5 * q)) = 2 * q := by
  have hn : 2 ≤ 5 * q := by omega
  have hub := semitotalDominationNumber_pathGraph_le_two_mul_ceil_div_five hn
  have hlb := ceil_two_mul_div_five_le_semitotalDominationNumber_pathGraph hn
  have h1 : (5 * q + 4) / 5 = q := by omega
  have h2 : (2 * (5 * q) + 4) / 5 = 2 * q := by omega
  omega

end SemitotalDomination