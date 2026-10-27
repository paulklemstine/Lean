import Mathlib

/-!
# Multiple transitivity: the one-step comparison and the counting half

Mathlib's `MulAction.isMultiplyPretransitive_of_le'` lowers the degree of
multiple pretransitivity provided `n ≤ ENat.card α`.  Here we

* prove `nat_le_enatCard_of_embedding`: an embedding `Fin n ↪ α` forces `n ≤ ENat.card α`,
  and combine it with Mathlib to get the one-step comparison
  (`(n+1)`-pretransitive and an `(n+1)`-tuple of distinct points ⇒ `n`-pretransitive);
* show the hypothesis cannot be dropped (`one_step_fails_without_embedding`);
* supply the *counting half*: for a finite set `α` with `Nat.card α = N`, the action is
  `k`-pretransitive iff the stabilizer of one (equivalently any) `k`-tuple of distinct points
  has index `N.descFactorial k = N (N-1) ⋯ (N-k+1)`;
  hence `N.descFactorial k ∣ Nat.card G`, and equality forces trivial stabilizers
  (sharp `k`-transitivity).
-/

open MulAction

namespace Catalog.Geometry.MultipleTransitivityCounting

variable {G α : Type*} [Group G] [MulAction G α]

/-- An embedding `Fin n ↪ α` witnesses `n ≤ ENat.card α`. -/
theorem nat_le_enatCard_of_embedding {n : ℕ} (e : Fin n ↪ α) :
    (n : ℕ∞) ≤ ENat.card α := by
  have h := ENat.card_le_card_of_injective e.injective
  simpa using h

/-- **One-step comparison.** If the action is `(n+1)`-pretransitive and `α` contains
`n+1` distinct points, then it is `n`-pretransitive. -/
theorem isMultiplyPretransitive_of_succ {n : ℕ} [IsMultiplyPretransitive G α (n + 1)]
    (e : Fin (n + 1) ↪ α) : IsMultiplyPretransitive G α n :=
  isMultiplyPretransitive_of_le' (Nat.le_succ n) (nat_le_enatCard_of_embedding e)

/-- Iterated version, proved by descending induction using only the one-step comparison. -/
theorem isMultiplyPretransitive_of_le_of_embedding {m n : ℕ}
    [h : IsMultiplyPretransitive G α n] (hmn : m ≤ n) (e : Fin n ↪ α) :
    IsMultiplyPretransitive G α m := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hmn
  clear hmn
  revert h e
  induction d with
  | zero => intro h _; simpa using h
  | succ d ih =>
    intro h e
    have : IsMultiplyPretransitive G α (m + d) := isMultiplyPretransitive_of_succ (n := m + d) e
    exact ih ((Fin.castLEEmb (by omega)).trans e) (h := this)

/-- The size hypothesis in the one-step comparison is necessary: the trivial group acting
on two points is vacuously `3`-pretransitive but not `2`-pretransitive. -/
theorem one_step_fails_without_embedding :
    IsMultiplyPretransitive (⊥ : Subgroup (Equiv.Perm (Fin 2))) (Fin 2) 3 ∧
      ¬ IsMultiplyPretransitive (⊥ : Subgroup (Equiv.Perm (Fin 2))) (Fin 2) 2 := by
  constructor
  · refine ⟨fun x _ => ?_⟩
    have := Fintype.card_le_of_injective x x.injective
    simp at this
  · intro h
    rw [is_two_pretransitive_iff] at h
    obtain ⟨g, h0, h1⟩ := h (a := (0 : Fin 2)) (b := 1) (c := 1) (d := 0) (by decide) (by decide)
    have hg : (g : Equiv.Perm (Fin 2)) = 1 := Subgroup.mem_bot.mp g.2
    rw [Subgroup.smul_def, hg] at h0
    simp at h0

/-- Number of `k`-tuples of distinct points of a finite type. -/
theorem natCard_embedding_eq [Finite α] (k : ℕ) :
    Nat.card (Fin k ↪ α) = (Nat.card α).descFactorial k := by
  have := Fintype.ofFinite α
  classical
  rw [Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Fintype.card_fin,
    Nat.card_eq_fintype_card]

/-- **Counting characterization.** On a finite set, the action is `k`-pretransitive iff the
stabilizer of a given `k`-tuple of distinct points has index `N (N-1) ⋯ (N-k+1)`. -/
theorem isMultiplyPretransitive_iff_index_eq [Finite α] {k : ℕ} (x : Fin k ↪ α) :
    IsMultiplyPretransitive G α k ↔
      (stabilizer G x).index = (Nat.card α).descFactorial k := by
  rw [index_stabilizer, ← natCard_embedding_eq, IsMultiplyPretransitive,
    isPretransitive_iff_orbit_eq_univ x, ← Set.ncard_univ]
  constructor
  · intro h; rw [h]
  · intro h
    exact Set.eq_of_subset_of_ncard_le (Set.subset_univ _) h.ge (Set.toFinite _)

/-- **Counting half.** If a group acts `k`-pretransitively on a finite set of size
`N ≥ k`, then `N (N-1) ⋯ (N-k+1)` divides `|G|`. -/
theorem descFactorial_dvd_card [Finite α] {k : ℕ} [h : IsMultiplyPretransitive G α k]
    (hk : k ≤ Nat.card α) : (Nat.card α).descFactorial k ∣ Nat.card G := by
  have := Fintype.ofFinite α
  have hne : Nonempty (Fin k ↪ α) :=
    Function.Embedding.nonempty_of_card_le (by simpa [Nat.card_eq_fintype_card] using hk)
  obtain ⟨x⟩ := hne
  rw [← (isMultiplyPretransitive_iff_index_eq (G := G) x).mp h]
  exact (stabilizer G x).index_dvd_card

/-- Lower bound on the order of a finite `k`-pretransitive group. -/
theorem descFactorial_le_card [Finite α] [Finite G] {k : ℕ} [IsMultiplyPretransitive G α k]
    (hk : k ≤ Nat.card α) : (Nat.card α).descFactorial k ≤ Nat.card G :=
  Nat.le_of_dvd Nat.card_pos (descFactorial_dvd_card hk)

/-- **Sharpness.** A `k`-pretransitive group of order exactly `N (N-1) ⋯ (N-k+1)` has trivial
stabilizers of `k`-tuples of distinct points (it is sharply `k`-transitive). -/
theorem stabilizer_eq_bot_of_card_eq [Finite α] {k : ℕ} [h : IsMultiplyPretransitive G α k]
    (hG : Nat.card G = (Nat.card α).descFactorial k) (x : Fin k ↪ α) :
    stabilizer G x = ⊥ := by
  have hidx := (isMultiplyPretransitive_iff_index_eq (G := G) x).mp h
  have hpos : 0 < (Nat.card α).descFactorial k := by
    rw [← natCard_embedding_eq]
    have := Fintype.ofFinite α
    classical
    exact Nat.card_pos_iff.mpr ⟨⟨x⟩, inferInstance⟩
  have hmul := (stabilizer G x).card_mul_index
  rw [hidx, hG] at hmul
  have h1 : Nat.card (stabilizer G x) = 1 := by
    have := Nat.eq_of_mul_eq_mul_right hpos (hmul.trans (one_mul _).symm)
    exact this
  exact Subgroup.eq_bot_of_card_eq _ h1

/-- Application: `Equiv.Perm α` is sharply `(N-1)`-transitive on a finite `α` of size `N`;
a permutation fixing `N - 1` distinct points is the identity. -/
theorem perm_stabilizer_eq_bot [Finite α] (x : Fin (Nat.card α - 1) ↪ α) :
    stabilizer (Equiv.Perm α) x = ⊥ := by
  have := Equiv.Perm.isMultiplyPretransitive α (Nat.card α - 1)
  apply stabilizer_eq_bot_of_card_eq
  rw [Nat.card_perm]
  rcases Nat.eq_zero_or_pos (Nat.card α) with h | h
  · simp [h]
  · obtain ⟨m, hm⟩ := Nat.exists_eq_succ_of_ne_zero h.ne'
    rw [hm, Nat.succ_sub_one]
    have := Nat.factorial_mul_descFactorial (Nat.le_succ m)
    simpa using this.symm

/-- `α` admits `k` distinct points as soon as `k ≤ Nat.card α`. -/
theorem nonempty_embedding_of_le [Finite α] {k : ℕ} (hk : k ≤ Nat.card α) :
    Nonempty (Fin k ↪ α) := by
  have := Fintype.ofFinite α
  exact Function.Embedding.nonempty_of_card_le (by simpa [Nat.card_eq_fintype_card] using hk)

/-- **Counting form of the one-step comparison.** For a `(k+1)`-pretransitive action on a
finite set of size `N`, the stabilizer of a `(k+1)`-tuple has index `N - k` times the index of
the stabilizer of its first `k` entries. -/
theorem index_stabilizer_succ [Finite α] {k : ℕ} [h : IsMultiplyPretransitive G α (k + 1)]
    (x : Fin (k + 1) ↪ α) :
    (stabilizer G x).index =
      (Nat.card α - k) * (stabilizer G ((Fin.castSuccEmb).trans x)).index := by
  have hk : IsMultiplyPretransitive G α k := isMultiplyPretransitive_of_succ x
  rw [(isMultiplyPretransitive_iff_index_eq x).mp h,
    (isMultiplyPretransitive_iff_index_eq _).mp hk, Nat.descFactorial_succ]

/-- In a sharply `(k+1)`-transitive group on `N ≥ k+1` points, the stabilizer of any `k`
distinct points has order exactly `N - k` (e.g. point stabilizers of sharply `2`-transitive
groups have order `N - 1`). -/
theorem card_stabilizer_of_sharp [Finite α] {k : ℕ} [h : IsMultiplyPretransitive G α (k + 1)]
    (hk : k + 1 ≤ Nat.card α) (hG : Nat.card G = (Nat.card α).descFactorial (k + 1))
    (y : Fin k ↪ α) : Nat.card (stabilizer G y) = Nat.card α - k := by
  obtain ⟨x⟩ := nonempty_embedding_of_le (α := α) hk
  have hk' : IsMultiplyPretransitive G α k := isMultiplyPretransitive_of_succ x
  have hidx := (isMultiplyPretransitive_iff_index_eq y).mp hk'
  have hpos : 0 < (Nat.card α).descFactorial k :=
    Nat.descFactorial_pos.mpr (by omega)
  have hmul := (stabilizer G y).card_mul_index
  rw [hidx, hG, Nat.descFactorial_succ] at hmul
  exact Nat.eq_of_mul_eq_mul_right hpos hmul

end Catalog.Geometry.MultipleTransitivityCounting