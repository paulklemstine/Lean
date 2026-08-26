import Geometry.KernelPatterns.Bell

/-!
# Kernel patterns with a prescribed number of blocks are the Stirling numbers

Mathlib defines the Stirling numbers of the second kind `Nat.stirlingSecond`
purely by their recursion.  Here we prove that they really do count kernel
patterns: the number of equality patterns of `n`-tuples having exactly `k`
distinct values is `Nat.stirlingSecond n k`
(`card_patternsWith_eq_stirlingSecond`).

The proof is a structural induction implemented by an explicit
restriction/extension dictionary between patterns on `Fin (n+1)` and patterns on
`Fin n`:

* `restr p` — delete the last index;
* `extend q a` — re-attach a last index whose representative is `a`;
* `extend_restr`, `restr_extend` — these are mutually inverse.

Deleting the last index either destroys a singleton block (`p` fixes the last
index) or leaves the block structure unchanged (`p` sends it into one of the
`k` existing blocks), which is exactly the Stirling recursion
`S(n+1, k+1) = (k+1) * S(n, k+1) + S(n, k)`.
-/

namespace Geometry.KernelPatterns

open Finset

variable {n : ℕ}

/-! ### A pointwise characterisation of patterns -/

/-- A tuple `p : Fin n → Fin n` is its own pattern exactly when it is a
"choice of least representatives": weakly decreasing on indices and
idempotent. -/
theorem pat_eq_self_iff (p : Fin n → Fin n) :
    pat p = p ↔ (∀ i, p i ≤ i) ∧ ∀ i, p (p i) = p i := by
  constructor
  · intro h
    refine ⟨fun i => ?_, fun i => ?_⟩
    · have hi := pat_le p i
      rwa [h] at hi
    · have hi := pat_apply_pat p i
      rwa [h] at hi
  · rintro ⟨hle, hidem⟩
    funext i
    apply le_antisymm
    · exact Finset.min'_le _ _ (by simp [hidem i])
    · refine Finset.le_min' _ _ _ ?_
      intro j hj
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj
      calc p i = p j := hj.symm
        _ ≤ j := hle j

lemma mem_patternsWith {n k : ℕ} (p : Fin n → Fin n) :
    p ∈ patternsWith n k ↔ pat p = p ∧ (univ.image p).card = k := by
  simp [patternsWith, mem_patterns_self]

/-! ### Deleting and re-attaching the last index -/

/-- Delete the last index from a pattern on `Fin (n+1)`. -/
def restr (p : Fin (n + 1) → Fin (n + 1)) (i : Fin n) : Fin n :=
  if h : (p i.castSucc : ℕ) < n then ⟨p i.castSucc, h⟩ else i

/-- Re-attach a last index to a pattern on `Fin n`, with representative `a`. -/
def extend (q : Fin n → Fin n) (a : Fin (n + 1)) : Fin (n + 1) → Fin (n + 1) :=
  fun j => if h : (j : ℕ) < n then (q ⟨j, h⟩).castSucc else a

@[simp] lemma extend_castSucc (q : Fin n → Fin n) (a : Fin (n + 1)) (i : Fin n) :
    extend q a i.castSucc = (q i).castSucc := by
  simp only [extend, Fin.val_castSucc, i.isLt, dif_pos]

@[simp] lemma extend_last (q : Fin n → Fin n) (a : Fin (n + 1)) :
    extend q a (Fin.last n) = a := by
  simp [extend]

@[simp] lemma restr_extend (q : Fin n → Fin n) (a : Fin (n + 1)) :
    restr (extend q a) = q := by
  funext i
  simp only [restr, extend_castSucc, Fin.val_castSucc]
  rw [dif_pos (q i).isLt]

lemma extend_restr {p : Fin (n + 1) → Fin (n + 1)} (hp : pat p = p) :
    extend (restr p) (p (Fin.last n)) = p := by
  have hle := ((pat_eq_self_iff p).1 hp).1
  funext j
  rcases Fin.eq_castSucc_or_eq_last j with ⟨i, rfl⟩ | rfl
  · have hlt : (p i.castSucc : ℕ) < n := lt_of_le_of_lt (hle i.castSucc) i.isLt
    rw [extend_castSucc]
    apply Fin.ext
    simp only [restr, dif_pos hlt, Fin.val_castSucc]
  · rw [extend_last]

lemma restr_apply_val {p : Fin (n + 1) → Fin (n + 1)} (hp : pat p = p) (i : Fin n) :
    (restr p i : ℕ) = (p i.castSucc : ℕ) := by
  have hle := ((pat_eq_self_iff p).1 hp).1
  have hlt : (p i.castSucc : ℕ) < n := lt_of_le_of_lt (hle i.castSucc) i.isLt
  simp only [restr, dif_pos hlt]

/-- Restriction of a pattern is a pattern. -/
lemma pat_restr {p : Fin (n + 1) → Fin (n + 1)} (hp : pat p = p) :
    pat (restr p) = restr p := by
  obtain ⟨hle, hidem⟩ := (pat_eq_self_iff p).1 hp
  refine (pat_eq_self_iff _).2 ⟨fun i => ?_, fun i => ?_⟩
  · have h1 : (restr p i : ℕ) = (p i.castSucc : ℕ) := restr_apply_val hp i
    have h2 : (p i.castSucc : ℕ) ≤ (i : ℕ) := hle i.castSucc
    exact Fin.le_def.2 (by omega)
  · apply Fin.ext
    have h1 : (restr p i : ℕ) = (p i.castSucc : ℕ) := restr_apply_val hp i
    have h2 : (restr p (restr p i) : ℕ) = (p (restr p i).castSucc : ℕ) :=
      restr_apply_val hp _
    have h3 : ((restr p i).castSucc : Fin (n + 1)) = p i.castSucc := Fin.ext (by simpa using h1)
    rw [h2, h3, hidem]
    exact h1.symm

/-- Extension of a pattern by a fixed representative is a pattern. -/
lemma pat_extend {q : Fin n → Fin n} (hq : pat q = q) {a : Fin (n + 1)}
    (ha : a = Fin.last n ∨ ∃ w : Fin n, q w = w ∧ a = w.castSucc) :
    pat (extend q a) = extend q a := by
  obtain ⟨hle, hidem⟩ := (pat_eq_self_iff q).1 hq
  refine (pat_eq_self_iff _).2 ⟨fun j => ?_, fun j => ?_⟩
  · rcases Fin.eq_castSucc_or_eq_last j with ⟨i, rfl⟩ | rfl
    · rw [extend_castSucc]
      exact Fin.castSucc_le_castSucc_iff.2 (hle i)
    · rw [extend_last]
      exact Fin.le_last a
  · rcases Fin.eq_castSucc_or_eq_last j with ⟨i, rfl⟩ | rfl
    · rw [extend_castSucc, extend_castSucc, hidem]
    · rw [extend_last]
      rcases ha with rfl | ⟨w, hw, rfl⟩
      · rw [extend_last]
      · rw [extend_castSucc, hw]

/-! ### How the block count changes -/

lemma image_extend_last (q : Fin n → Fin n) :
    univ.image (extend q (Fin.last n)) =
      (univ.image q).image Fin.castSucc ∪ {Fin.last n} := by
  ext b
  simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_union,
    Finset.mem_singleton]
  constructor
  · rintro ⟨j, rfl⟩
    rcases Fin.eq_castSucc_or_eq_last j with ⟨i, rfl⟩ | rfl
    · exact Or.inl ⟨q i, ⟨i, rfl⟩, by rw [extend_castSucc]⟩
    · exact Or.inr (by rw [extend_last])
  · rintro (⟨c, ⟨i, rfl⟩, rfl⟩ | rfl)
    · exact ⟨i.castSucc, by rw [extend_castSucc]⟩
    · exact ⟨Fin.last n, by rw [extend_last]⟩

lemma image_extend_castSucc {q : Fin n → Fin n} {w : Fin n} (hw : w ∈ univ.image q) :
    univ.image (extend q w.castSucc) = (univ.image q).image Fin.castSucc := by
  obtain ⟨v, -, hv⟩ := Finset.mem_image.1 hw
  ext b
  simp only [Finset.mem_image, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨j, rfl⟩
    rcases Fin.eq_castSucc_or_eq_last j with ⟨i, rfl⟩ | rfl
    · exact ⟨q i, ⟨i, rfl⟩, by rw [extend_castSucc]⟩
    · exact ⟨w, ⟨v, hv⟩, by rw [extend_last]⟩
  · rintro ⟨c, ⟨i, rfl⟩, rfl⟩
    exact ⟨i.castSucc, by rw [extend_castSucc]⟩

lemma card_image_extend_last (q : Fin n → Fin n) :
    (univ.image (extend q (Fin.last n))).card = (univ.image q).card + 1 := by
  rw [image_extend_last]
  have hnot : Fin.last n ∉ (univ.image q).image Fin.castSucc := by simp
  have hcast : ((univ.image q).image Fin.castSucc).card = (univ.image q).card :=
    Finset.card_image_of_injective _ (Fin.castSucc_injective n)
  have hdisj : Disjoint ((univ.image q).image Fin.castSucc)
      ({Fin.last n} : Finset (Fin (n + 1))) := by
    simp [Finset.disjoint_singleton_right]
  rw [Finset.card_union_of_disjoint hdisj, hcast, Finset.card_singleton]

lemma card_image_extend_castSucc {q : Fin n → Fin n} {w : Fin n} (hw : w ∈ univ.image q) :
    (univ.image (extend q w.castSucc)).card = (univ.image q).card := by
  rw [image_extend_castSucc hw, Finset.card_image_of_injective _ (Fin.castSucc_injective n)]

/-! ### The Stirling recursion -/

/-- Membership in the finset of patterns of `Fin (n+1)` with `k+1` blocks. -/
lemma mem_patternsWith_succ (n k : ℕ) (p : Fin (n + 1) → Fin (n + 1)) :
    p ∈ patternsWith (n + 1) (k + 1) ↔ pat p = p ∧ (univ.image p).card = k + 1 :=
  mem_patternsWith p

/-- Patterns on `Fin (n+1)` fixing the last index correspond to patterns on
`Fin n` with one block fewer. -/
theorem card_patternsWith_fixing_last (n k : ℕ) :
    ((patternsWith (n + 1) (k + 1)).filter fun p => p (Fin.last n) = Fin.last n).card
      = (patternsWith n k).card := by
  refine Finset.card_bij' (fun p _ => restr p) (fun q _ => extend q (Fin.last n)) ?_ ?_ ?_ ?_
  · intro p hp
    simp only [Finset.mem_filter, mem_patternsWith] at hp
    obtain ⟨⟨hpat, hcard⟩, hlast⟩ := hp
    refine (mem_patternsWith _).2 ⟨pat_restr hpat, ?_⟩
    show (univ.image (restr p)).card = k
    have hp' : extend (restr p) (Fin.last n) = p := by
      rw [← hlast]; exact extend_restr hpat
    have hcnt := card_image_extend_last (restr p)
    rw [hp', hcard] at hcnt
    omega
  · intro q hq
    rw [mem_patternsWith] at hq
    refine Finset.mem_filter.2 ⟨(mem_patternsWith _).2 ⟨pat_extend hq.1 (Or.inl rfl), ?_⟩, ?_⟩
    · show (univ.image (extend q (Fin.last n))).card = k + 1
      rw [card_image_extend_last, hq.2]
    · show extend q (Fin.last n) (Fin.last n) = Fin.last n
      rw [extend_last]
  · intro p hp
    simp only [Finset.mem_filter, mem_patternsWith] at hp
    show extend (restr p) (Fin.last n) = p
    rw [← hp.2]
    exact extend_restr hp.1.1
  · intro q _
    exact restr_extend q (Fin.last n)

/-- Patterns on `Fin (n+1)` not fixing the last index: the last index joins one
of the `k+1` blocks of the restricted pattern, giving `k+1` choices. -/
theorem card_patternsWith_moving_last (n k : ℕ) :
    ((patternsWith (n + 1) (k + 1)).filter fun p => ¬ p (Fin.last n) = Fin.last n).card
      = (k + 1) * (patternsWith n (k + 1)).card := by
  classical
  have hmem_iff : ∀ p : Fin (n + 1) → Fin (n + 1),
      p ∈ (patternsWith (n + 1) (k + 1)).filter (fun p => ¬ p (Fin.last n) = Fin.last n) ↔
        (pat p = p ∧ (univ.image p).card = k + 1) ∧ p (Fin.last n) ≠ Fin.last n := by
    intro p
    simp only [Finset.mem_filter, mem_patternsWith]
  -- the representative of the last index is not the last index, hence lies in `Fin n`
  have hlt : ∀ p : Fin (n + 1) → Fin (n + 1), p (Fin.last n) ≠ Fin.last n →
      ((p (Fin.last n) : ℕ)) < n := by
    intro p h2
    have h1 : (p (Fin.last n) : ℕ) ≤ n := Nat.lt_succ_iff.1 (p (Fin.last n)).isLt
    have h3 : (p (Fin.last n) : ℕ) ≠ n := fun h => h2 (Fin.ext (by simpa using h))
    omega
  have hlast_mem : ∀ p : Fin (n + 1) → Fin (n + 1), pat p = p →
      p (Fin.last n) ≠ Fin.last n →
      p (Fin.last n) ∈ (univ.image (restr p)).image Fin.castSucc := by
    intro p hpat h2
    have hidem := ((pat_eq_self_iff p).1 hpat).2
    refine Finset.mem_image.2 ⟨⟨(p (Fin.last n) : ℕ), hlt p h2⟩, ?_, ?_⟩
    · refine Finset.mem_image.2 ⟨⟨(p (Fin.last n) : ℕ), hlt p h2⟩, Finset.mem_univ _, ?_⟩
      apply Fin.ext
      have hcast : (⟨(p (Fin.last n) : ℕ), hlt p h2⟩ : Fin n).castSucc = p (Fin.last n) :=
        Fin.ext (by simp)
      rw [restr_apply_val hpat, hcast, hidem]
    · exact Fin.ext (by simp)
  have hmaps : ∀ p ∈ (patternsWith (n + 1) (k + 1)).filter
      (fun p => ¬ p (Fin.last n) = Fin.last n), restr p ∈ patternsWith n (k + 1) := by
    intro p hp
    obtain ⟨⟨hpat, hcard⟩, hlast⟩ := (hmem_iff p).1 hp
    refine (mem_patternsWith _).2 ⟨pat_restr hpat, ?_⟩
    obtain ⟨w, hw, hwcast⟩ := Finset.mem_image.1 (hlast_mem p hpat hlast)
    have hpe : extend (restr p) w.castSucc = p := by
      rw [hwcast]; exact extend_restr hpat
    have hcnt := card_image_extend_castSucc hw
    rw [hpe, hcard] at hcnt
    exact hcnt.symm
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfib : ∀ q ∈ patternsWith n (k + 1),
      (((patternsWith (n + 1) (k + 1)).filter fun p => ¬ p (Fin.last n) = Fin.last n).filter
        fun p => restr p = q).card = k + 1 := by
    intro q hq
    rw [mem_patternsWith] at hq
    obtain ⟨hqpat, hqcard⟩ := hq
    have hqidem := ((pat_eq_self_iff q).1 hqpat).2
    have hcard_img : ((univ.image q).image Fin.castSucc).card = k + 1 := by
      rw [Finset.card_image_of_injective _ (Fin.castSucc_injective n), hqcard]
    refine Eq.trans ?_ hcard_img
    refine Finset.card_bij' (fun p _ => p (Fin.last n)) (fun a _ => extend q a) ?_ ?_ ?_ ?_
    · intro p hp
      obtain ⟨hpB, hpq⟩ := Finset.mem_filter.1 hp
      obtain ⟨⟨hpat, -⟩, hlast⟩ := (hmem_iff p).1 hpB
      have := hlast_mem p hpat hlast
      rwa [hpq] at this
    · intro a ha
      obtain ⟨w, hw, rfl⟩ := Finset.mem_image.1 ha
      have hqw : q w = w := by
        obtain ⟨v, -, rfl⟩ := Finset.mem_image.1 hw
        exact hqidem v
      refine Finset.mem_filter.2 ⟨(hmem_iff _).2 ⟨⟨pat_extend hqpat (Or.inr ⟨w, hqw, rfl⟩), ?_⟩, ?_⟩,
        restr_extend q w.castSucc⟩
      · rw [card_image_extend_castSucc hw, hqcard]
      · show extend q w.castSucc (Fin.last n) ≠ Fin.last n
        rw [extend_last]
        exact Fin.castSucc_ne_last w
    · intro p hp
      obtain ⟨hpB, hpq⟩ := Finset.mem_filter.1 hp
      obtain ⟨⟨hpat, -⟩, -⟩ := (hmem_iff p).1 hpB
      show extend q (p (Fin.last n)) = p
      rw [← hpq]
      exact extend_restr hpat
    · intro a _
      exact extend_last q a
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul, mul_comm]

/-- **The Stirling recursion for kernel patterns.** -/
theorem card_patternsWith_succ_succ (n k : ℕ) :
    (patternsWith (n + 1) (k + 1)).card
      = (k + 1) * (patternsWith n (k + 1)).card + (patternsWith n k).card := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := patternsWith (n + 1) (k + 1)) (p := fun p => p (Fin.last n) = Fin.last n)
  rw [card_patternsWith_fixing_last, card_patternsWith_moving_last] at hsplit
  omega

/-! ### Base cases and the identification with `Nat.stirlingSecond` -/

theorem card_patternsWith_zero_zero : (patternsWith 0 0).card = 1 := by decide

theorem card_patternsWith_zero_succ (k : ℕ) : (patternsWith 0 (k + 1)).card = 0 := by
  rw [Finset.card_eq_zero]
  ext p
  simp [mem_patternsWith]

theorem card_patternsWith_succ_zero (n : ℕ) : (patternsWith (n + 1) 0).card = 0 := by
  rw [Finset.card_eq_zero]
  ext p
  simp only [mem_patternsWith, Finset.notMem_empty, iff_false, not_and]
  intro _
  have hne : (univ.image p).Nonempty := ⟨p 0, Finset.mem_image_of_mem _ (Finset.mem_univ 0)⟩
  exact (Finset.card_pos.2 hne).ne'

/-- **Kernel patterns with `k` blocks are counted by the Stirling numbers of the
second kind.**  This links Mathlib's recursively defined `Nat.stirlingSecond` to
an actual count of set partitions. -/
theorem card_patternsWith_eq_stirlingSecond :
    ∀ n k : ℕ, (patternsWith n k).card = Nat.stirlingSecond n k
  | 0, 0 => by rw [card_patternsWith_zero_zero, Nat.stirlingSecond_zero]
  | 0, _ + 1 => by rw [card_patternsWith_zero_succ, Nat.stirlingSecond_zero_succ]
  | _ + 1, 0 => by rw [card_patternsWith_succ_zero, Nat.stirlingSecond_succ_zero]
  | n + 1, k + 1 => by
      rw [card_patternsWith_succ_succ, Nat.stirlingSecond_succ_succ,
        card_patternsWith_eq_stirlingSecond n (k + 1), card_patternsWith_eq_stirlingSecond n k]

/-- The total number of kernel patterns is the sum over the number of blocks of
Stirling numbers of the second kind. -/
theorem card_patterns_eq_sum_stirlingSecond (n : ℕ) :
    (patterns n n).card = ∑ k ∈ range (n + 1), Nat.stirlingSecond n k := by
  rw [card_patterns_eq_sum_blocks]
  exact Finset.sum_congr rfl fun k _ => card_patternsWith_eq_stirlingSecond n k

end Geometry.KernelPatterns