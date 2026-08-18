import Logic.FibreSpectrumOrderBound

/-!
# The Stirling recurrence, proved from the pattern model

`stirling k r` was defined in `Catalog/Logic/FibreSpectrumRank.lean` as the number of kernel
patterns of `Fin k` with exactly `r` blocks, and used there to expand the tuple-orbit count
`#(X^k/G) = Σ_r S(k,r)·t_r`.  This file proves that this pattern count satisfies the classical
recurrence of the Stirling numbers of the second kind,

  `S(k+1, r+1) = S(k, r) + (r+1)·S(k, r+1)`   (`stirling_succ_succ`),

by an explicit bijection: a pattern of `Fin (k+1)` is a pattern `Q` of `Fin k` together with a
choice of value at the last coordinate, which must be either the new index `k` (opening a new
block, raising the rank by one) or one of the `rank Q` block leaders of `Q` (joining an existing
block, keeping the rank).

Together with `stirling_zero_succ`, `stirling_succ_zero` and `stirling_self` this pins the
`stirling` table down to the classical triangle (OEIS A008277) by induction, so the orbit-count
expansion of the previous files is genuinely a Stirling transform.

No `sorry`s, no `native_decide`, no new axioms.
-/

open Finset MulAction Function

namespace FibreSpectrum

open MoonshineBell

section Recurrence

variable {k : ℕ}

/-! ### Restriction of a pattern to the first `k` coordinates -/

theorem pattern_apply_ne_last (P : Pattern (k + 1)) (i : Fin k) :
    P.1 i.castSucc ≠ Fin.last k :=
  Fin.ne_last_of_lt (lt_of_le_of_lt (P.2.1 i.castSucc) (Fin.castSucc_lt_last i))

/-- Restrict a pattern of `Fin (k+1)` to a pattern of `Fin k`; the values stay below the last
index because a pattern is bounded by the identity. -/
def restr (P : Pattern (k + 1)) : Pattern k :=
  ⟨fun i => (P.1 i.castSucc).castPred (pattern_apply_ne_last P i), by
    constructor
    · intro i
      have h := P.2.1 i.castSucc
      simp only [Fin.le_def, Fin.coe_castPred]
      simpa [Fin.le_def] using h
    · intro i
      apply Fin.val_injective
      have hcast : ((P.1 i.castSucc).castPred (pattern_apply_ne_last P i)).castSucc
          = P.1 i.castSucc := Fin.castSucc_castPred _ _
      simp only [Fin.coe_castPred]
      rw [hcast, P.2.2 i.castSucc]⟩

theorem restr_castSucc (P : Pattern (k + 1)) (i : Fin k) :
    ((restr P).1 i).castSucc = P.1 i.castSucc :=
  Fin.castSucc_castPred _ (pattern_apply_ne_last P i)

/-! ### Extension of a pattern by a value at the last coordinate -/

/-- Extend a pattern `Q` of `Fin k` by prescribing the value `j` at the last coordinate. -/
def extend (Q : Pattern k) (j : Fin (k + 1)) : Fin (k + 1) → Fin (k + 1) :=
  Fin.snoc (fun i : Fin k => (Q.1 i).castSucc) j

theorem extend_castSucc (Q : Pattern k) (j : Fin (k + 1)) (i : Fin k) :
    extend Q j i.castSucc = (Q.1 i).castSucc := by
  simp [extend]

theorem extend_last (Q : Pattern k) (j : Fin (k + 1)) : extend Q j (Fin.last k) = j := by
  simp [extend]

/-- The admissible values at the last coordinate: the new index `k`, or a block leader of `Q`. -/
def admissible (Q : Pattern k) : Finset (Fin (k + 1)) :=
  insert (Fin.last k) ((leaders Q).image Fin.castSucc)

theorem isPattern_extend_iff (Q : Pattern k) (j : Fin (k + 1)) :
    IsPattern (extend Q j) ↔ j ∈ admissible Q := by
  classical
  constructor
  · intro hj
    rcases eq_or_ne j (Fin.last k) with h | h
    · simp [admissible, h]
    · obtain ⟨j', rfl⟩ : ∃ j' : Fin k, j = j'.castSucc :=
        ⟨j.castPred h, (Fin.castSucc_castPred _ _).symm⟩
      have hidem := hj.2 (Fin.last k)
      rw [extend_last, extend_castSucc] at hidem
      have hQ : Q.1 j' = j' := by
        have := congrArg Fin.val hidem
        simpa using Fin.val_injective (by simpa using this)
      refine Finset.mem_insert_of_mem (Finset.mem_image.2 ⟨j', ?_, rfl⟩)
      rw [← hQ]
      exact leader_mem Q j'
  · intro hj
    constructor
    · intro i
      induction i using Fin.lastCases with
      | last =>
        rw [extend_last]
        exact Fin.le_last j
      | cast i =>
        rw [extend_castSucc]
        exact Fin.castSucc_le_castSucc_iff.2 (Q.2.1 i)
    · intro i
      induction i using Fin.lastCases with
      | last =>
        rw [extend_last]
        rcases Finset.mem_insert.1 hj with h | h
        · rw [h, extend_last]
        · obtain ⟨j', hj', rfl⟩ := Finset.mem_image.1 h
          rw [extend_castSucc, leader_fixed hj']
      | cast i =>
        rw [extend_castSucc, extend_castSucc, Q.2.2 i]

/-- The pattern `Q` extended by an admissible value `j`, packaged as a pattern of `Fin (k+1)`. -/
def extendPattern (Q : Pattern k) (j : Fin (k + 1)) (hj : j ∈ admissible Q) : Pattern (k + 1) :=
  ⟨extend Q j, (isPattern_extend_iff Q j).2 hj⟩

theorem restr_extendPattern (Q : Pattern k) (j : Fin (k + 1)) (hj : j ∈ admissible Q) :
    restr (extendPattern Q j hj) = Q := by
  refine Subtype.ext (funext fun i => Fin.val_injective ?_)
  have h : ((restr (extendPattern Q j hj)).1 i).castSucc = extend Q j i.castSucc :=
    restr_castSucc _ i
  rw [extend_castSucc] at h
  simpa using congrArg Fin.val h

theorem extendPattern_restr (P : Pattern (k + 1)) :
    extend (restr P) (P.1 (Fin.last k)) = P.1 := by
  funext i
  induction i using Fin.lastCases with
  | last => rw [extend_last]
  | cast i => rw [extend_castSucc, restr_castSucc]

theorem last_mem_admissible_restr (P : Pattern (k + 1)) :
    P.1 (Fin.last k) ∈ admissible (restr P) :=
  (isPattern_extend_iff (restr P) (P.1 (Fin.last k))).1 (by rw [extendPattern_restr]; exact P.2)

/-! ### Ranks -/

theorem card_admissible (Q : Pattern k) : (admissible Q).card = rank Q + 1 := by
  classical
  have hnot : Fin.last k ∉ (leaders Q).image Fin.castSucc := by
    intro h
    obtain ⟨i, -, hi⟩ := Finset.mem_image.1 h
    exact absurd hi (Fin.castSucc_lt_last i).ne
  rw [admissible, Finset.card_insert_of_notMem hnot,
    Finset.card_image_of_injective _ (Fin.castSucc_injective k), card_leaders]

theorem leaders_extendPattern (Q : Pattern k) (j : Fin (k + 1)) (hj : j ∈ admissible Q) :
    leaders (extendPattern Q j hj) = insert j ((leaders Q).image Fin.castSucc) := by
  classical
  ext x
  simp only [leaders, Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_insert]
  constructor
  · rintro ⟨i, rfl⟩
    induction i using Fin.lastCases with
    | last => exact Or.inl (extend_last Q j)
    | cast i => exact Or.inr ⟨Q.1 i, ⟨i, rfl⟩, (extend_castSucc Q j i).symm⟩
  · rintro (rfl | ⟨y, ⟨i, rfl⟩, rfl⟩)
    · exact ⟨Fin.last k, extend_last Q _⟩
    · exact ⟨i.castSucc, extend_castSucc Q j i⟩

theorem rank_extendPattern_last (Q : Pattern k)
    (hj : Fin.last k ∈ admissible Q) :
    rank (extendPattern Q (Fin.last k) hj) = rank Q + 1 := by
  classical
  have hnot : Fin.last k ∉ (leaders Q).image Fin.castSucc := by
    intro h
    obtain ⟨i, -, hi⟩ := Finset.mem_image.1 h
    exact absurd hi (Fin.castSucc_lt_last i).ne
  rw [rank, leaders_extendPattern, Finset.card_insert_of_notMem hnot,
    Finset.card_image_of_injective _ (Fin.castSucc_injective k), card_leaders]

theorem rank_extendPattern_castSucc (Q : Pattern k) (j : Fin k)
    (hj : j.castSucc ∈ admissible Q) :
    rank (extendPattern Q j.castSucc hj) = rank Q := by
  classical
  have hmem : j ∈ leaders Q := by
    rcases Finset.mem_insert.1 hj with h | h
    · exact absurd h (Fin.castSucc_lt_last j).ne
    · obtain ⟨y, hy, hxy⟩ := Finset.mem_image.1 h
      rwa [Fin.castSucc_injective k hxy] at hy
  rw [rank, leaders_extendPattern,
    Finset.insert_eq_self.2 (Finset.mem_image.2 ⟨j, hmem, rfl⟩),
    Finset.card_image_of_injective _ (Fin.castSucc_injective k), card_leaders]

/-- A pattern of `Fin (k+1)` whose last value is the new index `k` has one more block than its
restriction. -/
theorem rank_of_last_eq (P : Pattern (k + 1)) (h : P.1 (Fin.last k) = Fin.last k) :
    rank P = rank (restr P) + 1 := by
  have hmem : Fin.last k ∈ admissible (restr P) := Finset.mem_insert_self _ _
  have hext : extend (restr P) (Fin.last k) = P.1 := by
    rw [← h]; exact extendPattern_restr P
  have hP : P = extendPattern (restr P) (Fin.last k) hmem := Subtype.ext hext.symm
  calc rank P = rank (extendPattern (restr P) (Fin.last k) hmem) := by rw [← hP]
    _ = rank (restr P) + 1 := rank_extendPattern_last _ _

/-- A pattern of `Fin (k+1)` whose last value joins an existing block has the same number of
blocks as its restriction. -/
theorem rank_of_last_ne (P : Pattern (k + 1)) (h : P.1 (Fin.last k) ≠ Fin.last k) :
    rank P = rank (restr P) := by
  set j : Fin k := (P.1 (Fin.last k)).castPred h with hj
  have hjc : j.castSucc = P.1 (Fin.last k) := Fin.castSucc_castPred _ _
  have hmem : j.castSucc ∈ admissible (restr P) := by
    rw [hjc]; exact last_mem_admissible_restr P
  have hext : extend (restr P) j.castSucc = P.1 := by
    rw [hjc]; exact extendPattern_restr P
  have hP : P = extendPattern (restr P) j.castSucc hmem := Subtype.ext hext.symm
  calc rank P = rank (extendPattern (restr P) j.castSucc hmem) := by rw [← hP]
    _ = rank (restr P) := rank_extendPattern_castSucc _ _ _

/-! ### The recurrence -/

/-- Patterns whose last coordinate opens a new block are exactly the patterns of `Fin k` of one
rank lower. -/
theorem card_newBlock (r : ℕ) :
    (Finset.univ.filter fun P : Pattern (k + 1) =>
      rank P = r + 1 ∧ P.1 (Fin.last k) = Fin.last k).card = stirling k r := by
  classical
  rw [stirling]
  refine Finset.card_bij' (fun P _ => restr P)
    (fun Q _ => extendPattern Q (Fin.last k) (Finset.mem_insert_self _ _)) ?_ ?_ ?_ ?_
  · intro P hP
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hP ⊢
    have := rank_of_last_eq P hP.2
    omega
  · intro Q hQ
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hQ ⊢
    refine ⟨?_, extend_last Q (Fin.last k)⟩
    rw [rank_extendPattern_last, hQ]
  · intro P hP
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hP
    refine Subtype.ext ?_
    show extend (restr P) (Fin.last k) = P.1
    rw [← hP.2]
    exact extendPattern_restr P
  · intro Q hQ
    exact restr_extendPattern Q _ _

/-- Patterns whose last coordinate joins an existing block: there are `rank Q = r + 1` of them
above each pattern `Q` of rank `r + 1`. -/
theorem card_oldBlock (r : ℕ) :
    (Finset.univ.filter fun P : Pattern (k + 1) =>
      rank P = r + 1 ∧ P.1 (Fin.last k) ≠ Fin.last k).card = (r + 1) * stirling k (r + 1) := by
  classical
  set s := Finset.univ.filter fun P : Pattern (k + 1) =>
    rank P = r + 1 ∧ P.1 (Fin.last k) ≠ Fin.last k with hs
  set t := Finset.univ.filter fun Q : Pattern k => rank Q = r + 1 with ht
  have hmaps : ∀ P ∈ s, restr P ∈ t := by
    intro P hP
    simp only [hs, ht, Finset.mem_filter, Finset.mem_univ, true_and] at hP ⊢
    rw [← rank_of_last_ne P hP.2]
    exact hP.1
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfib : ∀ Q ∈ t, (s.filter fun P => restr P = Q).card = r + 1 := by
    intro Q hQ
    simp only [ht, Finset.mem_filter, Finset.mem_univ, true_and] at hQ
    have hcard : (leaders Q).card = r + 1 := by rw [card_leaders, hQ]
    rw [← hcard]
    refine Finset.card_bij'
      (fun P hP => (P.1 (Fin.last k)).castPred (by
        simp only [hs, Finset.mem_filter, Finset.mem_univ, true_and] at hP
        exact hP.1.2))
      (fun x hx => extendPattern Q x.castSucc
        (Finset.mem_insert_of_mem (Finset.mem_image_of_mem _ hx))) ?_ ?_ ?_ ?_
    · intro P hP
      simp only [hs, Finset.mem_filter, Finset.mem_univ, true_and] at hP
      have hne := hP.1.2
      show (P.1 (Fin.last k)).castPred hne ∈ leaders Q
      have hmem := last_mem_admissible_restr P
      rcases Finset.mem_insert.1 hmem with hlast | himg
      · exact absurd hlast hne
      · obtain ⟨y, hy, hxy⟩ := Finset.mem_image.1 himg
        have : (P.1 (Fin.last k)).castPred hne = y := by
          apply Fin.castSucc_injective
          rw [Fin.castSucc_castPred, hxy]
        rw [this, ← hP.2]
        exact hy
    · intro x hx
      simp only [hs, Finset.mem_filter, Finset.mem_univ, true_and]
      refine ⟨⟨?_, ?_⟩, restr_extendPattern Q _ _⟩
      · rw [rank_extendPattern_castSucc, hQ]
      · show extend Q x.castSucc (Fin.last k) ≠ Fin.last k
        rw [extend_last]
        exact (Fin.castSucc_lt_last x).ne
    · intro P hP
      simp only [hs, Finset.mem_filter, Finset.mem_univ, true_and] at hP
      refine Subtype.ext ?_
      show extend Q ((P.1 (Fin.last k)).castPred hP.1.2).castSucc = P.1
      rw [Fin.castSucc_castPred, ← hP.2]
      exact extendPattern_restr P
    · intro x hx
      apply Fin.castSucc_injective
      rw [Fin.castSucc_castPred]
      exact extend_last Q x.castSucc
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul, ht, ← stirling, mul_comm]

/-- **The Stirling recurrence.**  Counting patterns of `Fin (k+1)` by their value at the last
coordinate gives `S(k+1, r+1) = S(k, r) + (r+1)·S(k, r+1)`. -/
theorem stirling_succ_succ (k r : ℕ) :
    stirling (k + 1) (r + 1) = stirling k r + (r + 1) * stirling k (r + 1) := by
  classical
  have hsplit : (Finset.univ.filter fun P : Pattern (k + 1) => rank P = r + 1)
      = (Finset.univ.filter fun P : Pattern (k + 1) =>
          rank P = r + 1 ∧ P.1 (Fin.last k) = Fin.last k)
        ∪ (Finset.univ.filter fun P : Pattern (k + 1) =>
          rank P = r + 1 ∧ P.1 (Fin.last k) ≠ Fin.last k) := by
    ext P
    by_cases h : P.1 (Fin.last k) = Fin.last k <;> simp [h]
  have hdisj : Disjoint
      (Finset.univ.filter fun P : Pattern (k + 1) =>
        rank P = r + 1 ∧ P.1 (Fin.last k) = Fin.last k)
      (Finset.univ.filter fun P : Pattern (k + 1) =>
        rank P = r + 1 ∧ P.1 (Fin.last k) ≠ Fin.last k) := by
    rw [Finset.disjoint_left]
    intro P hP hP'
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hP hP'
    exact hP'.2 hP.2
  rw [stirling, hsplit, Finset.card_union_of_disjoint hdisj, card_newBlock, card_oldBlock]

/-- No pattern of a nonempty index set has rank `0`. -/
theorem stirling_succ_zero (k : ℕ) : stirling (k + 1) 0 = 0 := by
  classical
  rw [stirling, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro P _
  have hne : (leaders P).Nonempty := ⟨P.1 0, leader_mem P 0⟩
  have := Finset.card_pos.2 hne
  rw [card_leaders] at this
  omega

theorem stirling_zero_zero : stirling 0 0 = 1 := by decide

/-- The empty index set has only the empty pattern, of rank `0`. -/
theorem stirling_zero_succ (r : ℕ) : stirling 0 (r + 1) = 0 := by
  classical
  rw [stirling, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro P _
  have h0 : rank P = 0 := by
    simp [rank, leaders]
  omega

/-- A partition of `Fin k` has at most `k` blocks. -/
theorem stirling_eq_zero_of_lt {k r : ℕ} (h : k < r) : stirling k r = 0 := by
  classical
  rw [stirling, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro P _
  have := rank_le P
  omega

/-- **The pattern count is the Stirling triangle.**  Any table satisfying the classical boundary
conditions and recurrence coincides with `stirling`; so the coefficients appearing in the
orbit-count expansion of `Catalog/Logic/FibreSpectrumRank.lean` are the Stirling numbers of the
second kind, with no appeal to a numerical check. -/
theorem stirling_unique (f : ℕ → ℕ → ℕ) (h00 : f 0 0 = 1) (h0succ : ∀ r, f 0 (r + 1) = 0)
    (hsucc0 : ∀ k, f (k + 1) 0 = 0)
    (hrec : ∀ k r, f (k + 1) (r + 1) = f k r + (r + 1) * f k (r + 1)) :
    ∀ k r, f k r = stirling k r := by
  intro k
  induction k with
  | zero =>
    intro r
    cases r with
    | zero => rw [h00, stirling_zero_zero]
    | succ r => rw [h0succ r, stirling_zero_succ r]
  | succ n ih =>
    intro r
    cases r with
    | zero => rw [hsucc0 n, stirling_succ_zero n]
    | succ r => rw [hrec n r, stirling_succ_succ n r, ih r, ih (r + 1)]

end Recurrence

end FibreSpectrum