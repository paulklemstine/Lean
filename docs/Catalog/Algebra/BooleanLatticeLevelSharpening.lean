/-
# Sharpening the chain bound for forbidden Boolean-lattice subposets

This file builds on `Algebra.BooleanLatticeChainBound` and contains:

* `hasBdCopy_of_complete_levels` : a family containing `d+1` complete levels of `2^[n]`
  contains a copy of `B d`;
* `card_le_of_bdFree_levelUnion` : consequently the conjecture
  `La(n, B_d) ≤ (d + c) C(n, ⌊n/2⌋)` holds with `c = 0` for every family that is a union of
  complete levels;
* `three_levels_lower_bound` : the three middle levels give
  `(m+1) La(2m, B_3) ≥ (3m+1) C(2m,m)`, so the constant for `d = 3` is at least `3 - o(1)`;
* `La_le_sharpened_even` : a strict sharpening of the chain bound,
  `(m+1) La(2m, B_d) ≤ ((2^d-1) m + 1) C(2m, m)`, obtained by splitting the Lubell mass into
  the middle layer and its complement.  For `d = 3` this gives
  `(m+1) La(2m, B_3) ≤ (7m+1) C(2m,m) < 7 (m+1) C(2m,m)`.
-/

import Algebra.BooleanLatticeChainBound

namespace Catalog.Algebra.BooleanLatticeChainBound

open Finset

variable {n : ℕ}

/-! ## Complete levels force Boolean-lattice copies

The construction below shows that a family containing `d+1` *complete* levels of `2^[n]`
always contains a copy of `B d`.  Consequently the "consecutive levels" construction, which
gives the lower bound `∑_{i} C(n,i)` over `d` levels, cannot be pushed to `d+1` levels: for
families that are unions of complete levels the conjectured bound holds with `c = 0`. -/

/-- The set of the `k` smallest points of `Fin n`. -/
def lowBlock (n k : ℕ) : Finset (Fin n) := Finset.univ.filter (fun x : Fin n => (x : ℕ) < k)

lemma mem_lowBlock {n k : ℕ} {x : Fin n} : x ∈ lowBlock n k ↔ (x : ℕ) < k := by
  simp [lowBlock]

lemma lowBlock_mono {n k l : ℕ} (h : k ≤ l) : lowBlock n k ⊆ lowBlock n l := by
  intro x hx
  rw [mem_lowBlock] at hx ⊢
  omega

lemma card_lowBlock {n k : ℕ} (hk : k ≤ n) : (lowBlock n k).card = k := by
  have himg : lowBlock n k = Finset.univ.image (Fin.castLE hk) := by
    ext x
    simp only [mem_lowBlock, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · intro hx
      exact ⟨⟨(x : ℕ), hx⟩, Fin.ext rfl⟩
    · rintro ⟨y, rfl⟩
      simp
  rw [himg, Finset.card_image_of_injective _ (Fin.castLE_injective hk)]
  simp

/-- The `d` largest points of `Fin n`, indexed by `Fin d`. -/
def markerEmb {n d : ℕ} (h : d ≤ n) : Fin d ↪ Fin n :=
  ⟨fun t => ⟨n - d + (t : ℕ), by have := t.isLt; omega⟩, by
    intro a b hab
    have hv : n - d + (a : ℕ) = n - d + (b : ℕ) := congrArg Fin.val hab
    exact Fin.ext (by omega)⟩

lemma markerEmb_val {n d : ℕ} (h : d ≤ n) (t : Fin d) :
    ((markerEmb h t : Fin n) : ℕ) = n - d + (t : ℕ) := rfl

/-- A strictly monotone function on `Fin (d+1)` dominates the index. -/
lemma val_le_apply {d : ℕ} {i : Fin (d + 1) → ℕ} (hmono : StrictMono i) :
    ∀ (k : ℕ) (hk : k < d + 1), k ≤ i ⟨k, hk⟩ := by
  intro k
  induction k with
  | zero => intro _; exact Nat.zero_le _
  | succ k ih =>
    intro hk
    have hk' : k < d + 1 := by omega
    have h1 : i ⟨k, hk'⟩ < i ⟨k + 1, hk⟩ := hmono (by simp [Fin.lt_def])
    have := ih hk'
    omega

/-- A strictly monotone function on `Fin (d+1)` grows at least linearly. -/
lemma apply_add_le {d : ℕ} {i : Fin (d + 1) → ℕ} (hmono : StrictMono i) :
    ∀ (t : ℕ) (r s : Fin (d + 1)), (s : ℕ) = (r : ℕ) + t → i r + t ≤ i s := by
  intro t
  induction t with
  | zero =>
    intro r s hs
    have : r = s := Fin.ext (by omega)
    subst this
    simp
  | succ t ih =>
    intro r s hs
    have hs' : (s : ℕ) - 1 < d + 1 := by omega
    have h1 : i r + t ≤ i ⟨(s : ℕ) - 1, hs'⟩ := ih r ⟨(s : ℕ) - 1, hs'⟩ (by simp; omega)
    have hlt : ((⟨(s : ℕ) - 1, hs'⟩ : Fin (d + 1)) : ℕ) < (s : ℕ) := by
      show (s : ℕ) - 1 < (s : ℕ)
      omega
    have h2 : i (⟨(s : ℕ) - 1, hs'⟩ : Fin (d + 1)) < i s := hmono (Fin.lt_def.2 hlt)
    omega

/-- The cardinality of a subset of `Fin d`, viewed as an index in `Fin (d+1)`. -/
def levelIdx {d : ℕ} (S : Finset (Fin d)) : Fin (d + 1) :=
  ⟨S.card, by
    have h := S.card_le_univ
    simp only [Fintype.card_fin] at h
    omega⟩

@[simp] lemma levelIdx_val {d : ℕ} (S : Finset (Fin d)) :
    ((levelIdx S : Fin (d + 1)) : ℕ) = S.card := rfl

/-- **Complete levels contain Boolean lattices.** If `F` contains every subset of `[n]` whose
size is one of `d+1` prescribed values `i 0 < i 1 < … < i d ≤ n`, then `F` contains a copy of
`B d`. -/
theorem hasBdCopy_of_complete_levels {d : ℕ} {F : Finset (Finset (Fin n))} (hdn : d ≤ n)
    (i : Fin (d + 1) → ℕ) (hmono : StrictMono i) (hlast : i (Fin.last d) ≤ n)
    (hF : ∀ (A : Finset (Fin n)) (r : Fin (d + 1)), A.card = i r → A ∈ F) :
    HasBdCopy d F := by
  classical
  have hcard_le : ∀ S : Finset (Fin d), S.card ≤ d := by
    intro S; simpa using S.card_le_univ
  have hcard_le_i : ∀ S : Finset (Fin d), S.card ≤ i (levelIdx S) := by
    intro S
    exact val_le_apply hmono S.card (by have := hcard_le S; omega)
  have hm_le : ∀ S : Finset (Fin d), i (levelIdx S) - S.card ≤ n - d := by
    intro S
    have hSd := hcard_le S
    have hstep : i (levelIdx S) + (d - S.card) ≤ i (Fin.last d) :=
      apply_add_le hmono (d - S.card) (levelIdx S) (Fin.last d) (by simp [Fin.last]; omega)
    omega
  have hm_mono : ∀ S T : Finset (Fin d), S ⊆ T →
      i (levelIdx S) - S.card ≤ i (levelIdx T) - T.card := by
    intro S T hST
    have hle : S.card ≤ T.card := Finset.card_le_card hST
    have hstep : i (levelIdx S) + (T.card - S.card) ≤ i (levelIdx T) :=
      apply_add_le hmono (T.card - S.card) (levelIdx S) (levelIdx T) (by simp; omega)
    have h1 := hcard_le_i S
    omega
  have hdisj : ∀ S : Finset (Fin d),
      Disjoint (lowBlock n (i (levelIdx S) - S.card)) (S.map (markerEmb hdn)) := by
    intro S
    rw [Finset.disjoint_left]
    intro x hx hx'
    rw [mem_lowBlock] at hx
    obtain ⟨t, -, rfl⟩ := Finset.mem_map.1 hx'
    have := hm_le S
    rw [markerEmb_val] at hx
    omega
  have hmarker : ∀ (S : Finset (Fin d)) (t : Fin d),
      markerEmb hdn t ∈ lowBlock n (i (levelIdx S) - S.card) ∪ S.map (markerEmb hdn) ↔ t ∈ S := by
    intro S t
    constructor
    · intro hmem
      rcases Finset.mem_union.1 hmem with hlow | hmap
      · rw [mem_lowBlock, markerEmb_val] at hlow
        have := hm_le S
        omega
      · obtain ⟨t', ht', heq⟩ := Finset.mem_map.1 hmap
        rwa [(markerEmb hdn).injective heq] at ht'
    · intro hmem
      exact Finset.mem_union_right _ (Finset.mem_map_of_mem _ hmem)
  refine ⟨fun S => lowBlock n (i (levelIdx S) - S.card) ∪ S.map (markerEmb hdn), ?_, ?_, ?_⟩
  · intro S T hST
    ext t
    rw [← hmarker S t, ← hmarker T t]
    simp only at hST
    rw [hST]
  · intro S
    refine hF _ (levelIdx S) ?_
    have hml : i (levelIdx S) - S.card ≤ n := le_trans (hm_le S) (Nat.sub_le _ _)
    rw [Finset.card_union_of_disjoint (hdisj S), card_lowBlock hml, Finset.card_map]
    have := hcard_le_i S
    omega
  · intro S T hST
    refine Finset.union_subset_union (lowBlock_mono (hm_mono S T hST)) ?_
    exact Finset.map_subset_map.2 hST

/-! ## The conjecture for unions of complete levels -/

/-- A family that is a union of complete levels of the Boolean lattice. -/
def LevelUnion (F : Finset (Finset (Fin n))) : Prop :=
  ∀ A B : Finset (Fin n), A.card = B.card → A ∈ F → B ∈ F

/-- A `B d`-free union of complete levels uses at most `d` levels. -/
theorem card_image_card_le_of_bdFree_levelUnion {d : ℕ} {F : Finset (Finset (Fin n))}
    (hdn : d ≤ n) (hfree : BdFree d F) (hlev : LevelUnion F) :
    (F.image Finset.card).card ≤ d := by
  classical
  by_contra hcon
  push_neg at hcon
  obtain ⟨L, hLsub, hLcard⟩ :=
    Finset.exists_subset_card_eq (s := F.image Finset.card) (n := d + 1) (by omega)
  set e := L.orderIsoOfFin hLcard with he
  set i : Fin (d + 1) → ℕ := fun r => (e r : ℕ) with hi
  have hmono : StrictMono i := by
    intro r s hrs
    exact (L.orderIsoOfFin hLcard).strictMono hrs
  have hmemL : ∀ r : Fin (d + 1), i r ∈ L := fun r => (e r).2
  have hmemF : ∀ r : Fin (d + 1), ∃ A ∈ F, A.card = i r := by
    intro r
    have := hLsub (hmemL r)
    simpa [eq_comm] using Finset.mem_image.1 this
  have hle : ∀ r : Fin (d + 1), i r ≤ n := by
    intro r
    obtain ⟨A, -, hA⟩ := hmemF r
    have : A.card ≤ n := by simpa using A.card_le_univ
    omega
  refine hfree (hasBdCopy_of_complete_levels hdn i hmono (hle _) ?_)
  intro A r hA
  obtain ⟨B, hB, hBcard⟩ := hmemF r
  exact hlev B A (by omega) hB

/-- **The conjecture, with `c = 0`, for unions of complete levels.**
A `B d`-free family which is a union of complete levels of `2^[n]` has at most
`d * C(n, ⌊n/2⌋)` members. -/
theorem card_le_of_bdFree_levelUnion {d : ℕ} {F : Finset (Finset (Fin n))}
    (hfree : BdFree d F) (hlev : LevelUnion F) : F.card ≤ d * central n := by
  classical
  by_cases hdn : d ≤ n
  · have hL : (F.image Finset.card).card ≤ d :=
      card_image_card_le_of_bdFree_levelUnion hdn hfree hlev
    have hsub : F ⊆ (F.image Finset.card).biUnion
        (fun r => Finset.powersetCard r Finset.univ) := by
      intro A hA
      exact Finset.mem_biUnion.2 ⟨A.card, Finset.mem_image_of_mem _ hA,
        Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, rfl⟩⟩
    have h1 : F.card ≤ ∑ r ∈ F.image Finset.card, n.choose r := by
      refine le_trans (Finset.card_le_card hsub) (le_trans (Finset.card_biUnion_le) ?_)
      exact Finset.sum_le_sum (fun r _ => by simp [Finset.card_powersetCard])
    have h2 : ∑ r ∈ F.image Finset.card, n.choose r
        ≤ (F.image Finset.card).card * central n :=
      le_trans (Finset.sum_le_sum (fun r _ => choose_le_central n r)) (by simp)
    exact le_trans h1 (le_trans h2 (Nat.mul_le_mul_right _ hL))
  · have : F.card ≤ (n + 1) * central n := card_le_height_bound F
    exact le_trans this (Nat.mul_le_mul_right _ (by omega))

/-- For unions of complete levels the conjectured `d = 3` bound holds (indeed with `3` in place
of `4`). -/
theorem card_le_of_bdFree_three_levelUnion {F : Finset (Finset (Fin n))}
    (hfree : BdFree 3 F) (hlev : LevelUnion F) : F.card ≤ 4 * central n :=
  le_trans (card_le_of_bdFree_levelUnion hfree hlev) (Nat.mul_le_mul_right _ (by norm_num))

/-! ## A quantitative lower bound for `d = 3`

The three middle levels give `La(2m, B_3) ≥ (3m+1)/(m+1) * C(2m, m)`, so the constant for
`d = 3` is at least `3 - o(1)`: the conjectured value `4` is consistent, while any bound below
`3` would be false. -/

lemma central_two_mul (m : ℕ) : central (2 * m) = (2 * m).choose m := by
  simp [central, Nat.mul_div_cancel_left m (by norm_num : 0 < 2)]

lemma choose_two_mul_pred (m : ℕ) (hm : 1 ≤ m) :
    (2 * m).choose (m - 1) * (m + 1) = (2 * m).choose m * m := by
  have h := Nat.choose_succ_right_eq (2 * m) (m - 1)
  have hm1 : m - 1 + 1 = m := by omega
  rw [hm1] at h
  have h2 : 2 * m - (m - 1) = m + 1 := by omega
  rw [h2] at h
  omega

lemma choose_two_mul_succ (m : ℕ) :
    (2 * m).choose (m + 1) * (m + 1) = (2 * m).choose m * m := by
  have h := Nat.choose_succ_right_eq (2 * m) m
  have h2 : 2 * m - m = m := by omega
  rw [h2] at h
  omega

/-- **Quantitative lower bound for `d = 3`** : `(m+1) * La(2m, B_3) ≥ (3m+1) * C(2m, m)`,
i.e. `La(2m, B_3) ≥ (3 - 2/(m+1)) * C(2m, m)`. -/
theorem three_levels_lower_bound (m : ℕ) (hm : 1 ≤ m) :
    (3 * m + 1) * central (2 * m) ≤ (m + 1) * La (2 * m) 3 := by
  have hsum := La_ge_consecutive_levels (2 * m) (m - 1) 3
  have hIco : Finset.Ico (m - 1) (m - 1 + 3) = {m - 1, m, m + 1} := by
    have h1 : m - 1 + 3 = m + 2 := by omega
    rw [h1]
    ext x
    simp only [Finset.mem_Ico, Finset.mem_insert, Finset.mem_singleton]
    omega
  rw [hIco] at hsum
  have hne1 : m - 1 ≠ m := by omega
  have hne2 : m - 1 ≠ m + 1 := by omega
  rw [Finset.sum_insert (by simp [hne1, hne2]), Finset.sum_insert (by simp),
    Finset.sum_singleton] at hsum
  have hkey : ((2 * m).choose (m - 1) + ((2 * m).choose m + (2 * m).choose (m + 1))) * (m + 1)
      = (3 * m + 1) * (2 * m).choose m := by
    have h1 := choose_two_mul_pred m hm
    have h2 := choose_two_mul_succ m
    ring_nf
    ring_nf at h1 h2
    omega
  calc (3 * m + 1) * central (2 * m)
      = ((2 * m).choose (m - 1) + ((2 * m).choose m + (2 * m).choose (m + 1))) * (m + 1) := by
        rw [hkey, central_two_mul]
    _ ≤ La (2 * m) 3 * (m + 1) := Nat.mul_le_mul_right _ hsum
    _ = (m + 1) * La (2 * m) 3 := by ring


/-! ## A strict sharpening of the chain bound

The chain bound loses information because it treats every member of the family as if it lay in
the middle layer.  Splitting the Lubell mass into the middle layer and everything else gives,
for even ground sets, the strictly better bound

  `La(2m, B_d) ≤ C(2m,m) + (2^d - 2) * C(2m, m-1) = ((2^d-1)m + 1)/(m+1) * C(2m, m)`,

which improves the chain bound `(2^d-1) C(2m,m)` by `(2^d-2)/(m+1) * C(2m,m)` and is an
equality for `d = 1`. -/

lemma choose_le_choose_add (N : ℕ) :
    ∀ (t k : ℕ), k + t < N / 2 + 1 → N.choose k ≤ N.choose (k + t) := by
  intro t
  induction t with
  | zero => intro k _; simp
  | succ t ih =>
    intro k hk
    have h1 : N.choose k ≤ N.choose (k + t) := ih k (by omega)
    have h2 : N.choose (k + t) ≤ N.choose (k + t + 1) :=
      Nat.choose_le_succ_of_lt_half_left (by omega)
    calc N.choose k ≤ N.choose (k + t) := h1
      _ ≤ N.choose (k + t + 1) := h2
      _ = N.choose (k + (t + 1)) := by ring_nf

/-- Off the middle layer of `2^[2m]`, binomial coefficients are at most `C(2m, m-1)`. -/
lemma choose_le_choose_pred_of_ne {m k : ℕ} (hm : 1 ≤ m) (hk : k ≠ m) :
    (2 * m).choose k ≤ (2 * m).choose (m - 1) := by
  have hhalf : 2 * m / 2 = m := by omega
  rcases lt_or_ge (2 * m) k with hgt | hle
  · rw [Nat.choose_eq_zero_of_lt hgt]
    exact Nat.zero_le _
  · rcases lt_or_ge k m with hlt | hge
    · have := choose_le_choose_add (2 * m) (m - 1 - k) k (by omega)
      have hEq : k + (m - 1 - k) = m - 1 := by omega
      rwa [hEq] at this
    · have hk' : m < k := by omega
      rw [← Nat.choose_symm hle]
      have := choose_le_choose_add (2 * m) (m - 1 - (2 * m - k)) (2 * m - k) (by omega)
      have hEq : 2 * m - k + (m - 1 - (2 * m - k)) = m - 1 := by omega
      rwa [hEq] at this

/-- The extremal function is attained. -/
lemma exists_extremal (n d : ℕ) :
    ∃ F : Finset (Finset (Fin n)), BdFree d F ∧ F.card = La n d :=
  Nat.sSup_mem (LaSet_nonempty n d) (LaSet_bddAbove n d)

/-- **Sharpened chain bound.** Every `B d`-free family of subsets of `[2m]` satisfies
`(m+1) |F| ≤ ((2^d - 1) m + 1) C(2m, m)`, i.e. `|F| ≤ (2^d - 1 - (2^d-2)/(m+1)) C(2m,m)`. -/
theorem card_le_sharpened_even {m d : ℕ} (hm : 1 ≤ m) {F : Finset (Finset (Fin (2 * m)))}
    (hfree : BdFree d F) :
    (m + 1) * F.card ≤ ((2 ^ d - 1) * m + 1) * central (2 * m) := by
  classical
  set K : ℕ := 2 ^ d - 1 with hK
  have hlub : lubell F ≤ (K : ℝ) := lubell_le_of_bdFree hfree
  have hcpos : (0 : ℝ) < ((2 * m).choose m : ℝ) := by
    have : 0 < (2 * m).choose m := Nat.choose_pos (by omega)
    exact_mod_cast this
  have hc'pos : (0 : ℝ) < ((2 * m).choose (m - 1) : ℝ) := by
    have : 0 < (2 * m).choose (m - 1) := Nat.choose_pos (by omega)
    exact_mod_cast this
  have hident : ((m : ℝ) + 1) * ((2 * m).choose (m - 1) : ℝ)
      = (m : ℝ) * ((2 * m).choose m : ℝ) := by
    have hnat := choose_two_mul_pred m hm
    have hr : (((2 * m).choose (m - 1) * (m + 1) : ℕ) : ℝ)
        = (((2 * m).choose m * m : ℕ) : ℝ) := by exact_mod_cast hnat
    push_cast at hr
    linarith
  set F1 := F.filter (fun A : Finset (Fin (2 * m)) => A.card = m) with hF1
  set F2 := F.filter (fun A : Finset (Fin (2 * m)) => ¬ A.card = m) with hF2
  have hcard_split : F1.card + F2.card = F.card := by
    rw [hF1, hF2]
    exact Finset.card_filter_add_card_filter_not _
  have hF1le : (F1.card : ℝ) ≤ ((2 * m).choose m : ℝ) := by
    have hsub : F1 ⊆ Finset.powersetCard m Finset.univ := by
      intro A hA
      rw [hF1, Finset.mem_filter] at hA
      exact Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, hA.2⟩
    have hle := Finset.card_le_card hsub
    have hpc' : (Finset.powersetCard m (Finset.univ : Finset (Fin (2 * m)))).card
        = (2 * m).choose m := by simp [Finset.card_powersetCard]
    rw [hpc'] at hle
    exact_mod_cast hle
  have hsum_split : lubell F = (∑ A ∈ F1, (((2 * m).choose A.card : ℝ))⁻¹)
      + ∑ A ∈ F2, (((2 * m).choose A.card : ℝ))⁻¹ := by
    rw [lubell, hF1, hF2]
    exact (Finset.sum_filter_add_sum_filter_not F
      (fun A : Finset (Fin (2 * m)) => A.card = m) _).symm
  have hs1 : (∑ A ∈ F1, (((2 * m).choose A.card : ℝ))⁻¹)
      = (F1.card : ℝ) * (((2 * m).choose m : ℝ))⁻¹ := by
    have hpt : ∀ A ∈ F1, (((2 * m).choose A.card : ℝ))⁻¹ = (((2 * m).choose m : ℝ))⁻¹ := by
      intro A hA
      rw [hF1, Finset.mem_filter] at hA
      rw [hA.2]
    rw [Finset.sum_congr rfl hpt, Finset.sum_const, nsmul_eq_mul]
  have hs2 : (F2.card : ℝ) * (((2 * m).choose (m - 1) : ℝ))⁻¹
      ≤ ∑ A ∈ F2, (((2 * m).choose A.card : ℝ))⁻¹ := by
    have hterm : ∀ A ∈ F2, (((2 * m).choose (m - 1) : ℝ))⁻¹
        ≤ (((2 * m).choose A.card : ℝ))⁻¹ := by
      intro A hA
      rw [hF2, Finset.mem_filter] at hA
      have hle : (2 * m).choose A.card ≤ (2 * m).choose (m - 1) :=
        choose_le_choose_pred_of_ne hm hA.2
      have hpos : (0 : ℝ) < ((2 * m).choose A.card : ℝ) := by
        have : 0 < (2 * m).choose A.card := Nat.choose_pos (by simpa using A.card_le_univ)
        exact_mod_cast this
      have hle' : ((2 * m).choose A.card : ℝ) ≤ ((2 * m).choose (m - 1) : ℝ) := by
        exact_mod_cast hle
      have := one_div_le_one_div_of_le hpos hle'
      simpa [one_div] using this
    have hsum := Finset.sum_le_sum hterm
    rw [Finset.sum_const, nsmul_eq_mul] at hsum
    exact hsum
  set x : ℝ := (F1.card : ℝ) with hx
  set y : ℝ := (F2.card : ℝ) with hy
  set c : ℝ := ((2 * m).choose m : ℝ) with hc
  set c' : ℝ := ((2 * m).choose (m - 1) : ℝ) with hc'
  have hxy : x * c⁻¹ + y * c'⁻¹ ≤ (K : ℝ) := by
    calc x * c⁻¹ + y * c'⁻¹ ≤ (∑ A ∈ F1, (((2 * m).choose A.card : ℝ))⁻¹)
        + ∑ A ∈ F2, (((2 * m).choose A.card : ℝ))⁻¹ := by rw [hs1]; linarith
      _ = lubell F := hsum_split.symm
      _ ≤ (K : ℝ) := hlub
  have hmul : x * c' + y * c ≤ (K : ℝ) * (c * c') := by
    have h := mul_le_mul_of_nonneg_right hxy (le_of_lt (mul_pos hcpos hc'pos))
    have e1 : (x * c⁻¹ + y * c'⁻¹) * (c * c') = x * c' + y * c := by
      field_simp
    rw [e1] at h
    exact h
  have hxnn : 0 ≤ x := by positivity
  have hynn : 0 ≤ y := by positivity
  have hxle : x ≤ c := hF1le
  have h2 : x * ((m : ℝ) * c) + ((m : ℝ) + 1) * y * c ≤ (K : ℝ) * ((m : ℝ) * c) * c := by
    have h1 : ((m : ℝ) + 1) * (x * c' + y * c) ≤ ((m : ℝ) + 1) * ((K : ℝ) * (c * c')) :=
      mul_le_mul_of_nonneg_left hmul (by positivity)
    have e : ((m : ℝ) + 1) * (x * c' + y * c)
        = x * (((m : ℝ) + 1) * c') + ((m : ℝ) + 1) * y * c := by ring
    have e2 : ((m : ℝ) + 1) * ((K : ℝ) * (c * c')) = (K : ℝ) * c * (((m : ℝ) + 1) * c') := by
      ring
    rw [e, e2, hident] at h1
    calc x * ((m : ℝ) * c) + ((m : ℝ) + 1) * y * c ≤ (K : ℝ) * c * ((m : ℝ) * c) := h1
      _ = (K : ℝ) * ((m : ℝ) * c) * c := by ring
  have h3 : x * (m : ℝ) + ((m : ℝ) + 1) * y ≤ (K : ℝ) * (m : ℝ) * c := by
    have e : (x * (m : ℝ) + ((m : ℝ) + 1) * y) * c ≤ ((K : ℝ) * (m : ℝ) * c) * c := by
      nlinarith [h2]
    exact le_of_mul_le_mul_right e hcpos
  have hstep : ((m : ℝ) + 1) * (x + y) ≤ ((K : ℝ) * m + 1) * c := by nlinarith [hxle, h3]
  have hfinal : ((m : ℝ) + 1) * (F.card : ℝ) ≤ ((K : ℝ) * m + 1) * c := by
    have hxysum : x + y = (F.card : ℝ) := by
      rw [hx, hy]
      exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) hcard_split
    rwa [hxysum] at hstep
  have hnat : ((m + 1) * F.card : ℕ) ≤ ((K * m + 1) * (2 * m).choose m : ℕ) := by
    have hcast : (((m + 1) * F.card : ℕ) : ℝ) ≤ (((K * m + 1) * (2 * m).choose m : ℕ) : ℝ) := by
      push_cast
      calc ((m : ℝ) + 1) * (F.card : ℝ) ≤ ((K : ℝ) * m + 1) * c := hfinal
        _ = ((K : ℝ) * (m : ℝ) + 1) * ((2 * m).choose m : ℝ) := by rw [hc]
    exact_mod_cast hcast
  rw [central_two_mul m]
  exact hnat

/-- **Sharpened chain bound for `La`.** For all `m ≥ 1` and all `d`,
`(m+1) * La(2m, B_d) ≤ ((2^d - 1) m + 1) * C(2m, m)`.  For `d ≥ 2` this is strictly stronger
than the chain bound `La ≤ (2^d - 1) C(2m,m)`, and for `d = 1` it is an equality. -/
theorem La_le_sharpened_even {m d : ℕ} (hm : 1 ≤ m) :
    (m + 1) * La (2 * m) d ≤ ((2 ^ d - 1) * m + 1) * central (2 * m) := by
  obtain ⟨F, hfree, hcard⟩ := exists_extremal (2 * m) d
  rw [← hcard]
  exact card_le_sharpened_even hm hfree

/-- The sharpened bound is strictly better than the chain bound as soon as `d ≥ 2`. -/
theorem sharpened_lt_chain_bound {m d : ℕ} (hd : 2 ≤ d) :
    ((2 ^ d - 1) * m + 1) * central (2 * m) < (2 ^ d - 1) * (m + 1) * central (2 * m) := by
  have h2 : 4 ≤ 2 ^ d := by
    calc (4 : ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ d := Nat.pow_le_pow_right (by norm_num) hd
  have hpos : 0 < central (2 * m) := central_pos _
  have : (2 ^ d - 1) * m + 1 < (2 ^ d - 1) * (m + 1) := by
    have : (2 ^ d - 1) * (m + 1) = (2 ^ d - 1) * m + (2 ^ d - 1) := by ring
    omega
  exact Nat.mul_lt_mul_of_lt_of_le this le_rfl hpos

/-- **Sandwich for `d = 3` on even ground sets.**  The three middle levels give the lower
bound, the sharpened chain bound gives the upper bound:
`(3m+1) C(2m,m) ≤ (m+1) La(2m, B_3) ≤ (7m+1) C(2m,m)`. -/
theorem three_sandwich {m : ℕ} (hm : 1 ≤ m) :
    (3 * m + 1) * central (2 * m) ≤ (m + 1) * La (2 * m) 3 ∧
      (m + 1) * La (2 * m) 3 ≤ (7 * m + 1) * central (2 * m) := by
  refine ⟨three_levels_lower_bound m hm, ?_⟩
  have := La_le_sharpened_even (m := m) (d := 3) hm
  simpa using this


/-! ## The sharpened bound on odd ground sets

For `n = 2m+1` two layers attain the maximum binomial coefficient, so the Lubell split has a
two-layer head.  The outcome is again strictly stronger than the chain bound. -/

lemma central_two_mul_succ (m : ℕ) : central (2 * m + 1) = (2 * m + 1).choose m := by
  simp [central, show (2 * m + 1) / 2 = m by omega]

lemma choose_two_mul_succ_symm (m : ℕ) :
    (2 * m + 1).choose (m + 1) = (2 * m + 1).choose m := by
  have h := Nat.choose_symm (n := 2 * m + 1) (k := m) (by omega)
  have he : 2 * m + 1 - m = m + 1 := by omega
  rw [he] at h
  exact h

lemma choose_odd_pred_identity (m : ℕ) (hm : 1 ≤ m) :
    (2 * m + 1).choose (m - 1) * (m + 2) = (2 * m + 1).choose m * m := by
  have h := Nat.choose_succ_right_eq (2 * m + 1) (m - 1)
  have h1 : m - 1 + 1 = m := by omega
  rw [h1] at h
  have h2 : 2 * m + 1 - (m - 1) = m + 2 := by omega
  rw [h2] at h
  omega

/-- Off the two middle layers of `2^[2m+1]`, binomial coefficients are at most
`C(2m+1, m-1)`. -/
lemma choose_le_choose_pred_of_ne_odd {m k : ℕ} (hm : 1 ≤ m) (hk : k ≠ m) (hk' : k ≠ m + 1) :
    (2 * m + 1).choose k ≤ (2 * m + 1).choose (m - 1) := by
  have hhalf : (2 * m + 1) / 2 = m := by omega
  rcases lt_or_ge (2 * m + 1) k with hgt | hle
  · rw [Nat.choose_eq_zero_of_lt hgt]
    exact Nat.zero_le _
  · rcases lt_or_ge k m with hlt | hge
    · have h := choose_le_choose_add (2 * m + 1) (m - 1 - k) k (by omega)
      have hEq : k + (m - 1 - k) = m - 1 := by omega
      rwa [hEq] at h
    · have hk2 : m + 2 ≤ k := by omega
      rw [← Nat.choose_symm hle]
      have h := choose_le_choose_add (2 * m + 1) (m - 1 - (2 * m + 1 - k)) (2 * m + 1 - k)
        (by omega)
      have hEq : 2 * m + 1 - k + (m - 1 - (2 * m + 1 - k)) = m - 1 := by omega
      rwa [hEq] at h

/-- **Sharpened chain bound, odd ground set.** Every `B d`-free family of subsets of `[2m+1]`
satisfies `(m+2) |F| ≤ ((2^d - 1) m + 4) C(2m+1, m)`. -/
theorem card_le_sharpened_odd {m d : ℕ} (hm : 1 ≤ m) {F : Finset (Finset (Fin (2 * m + 1)))}
    (hfree : BdFree d F) :
    (m + 2) * F.card ≤ ((2 ^ d - 1) * m + 4) * central (2 * m + 1) := by
  classical
  set K : ℕ := 2 ^ d - 1 with hK
  have hlub : lubell F ≤ (K : ℝ) := lubell_le_of_bdFree hfree
  have hcpos : (0 : ℝ) < ((2 * m + 1).choose m : ℝ) := by
    have : 0 < (2 * m + 1).choose m := Nat.choose_pos (by omega)
    exact_mod_cast this
  have hc'pos : (0 : ℝ) < ((2 * m + 1).choose (m - 1) : ℝ) := by
    have : 0 < (2 * m + 1).choose (m - 1) := Nat.choose_pos (by omega)
    exact_mod_cast this
  have hident : ((m : ℝ) + 2) * ((2 * m + 1).choose (m - 1) : ℝ)
      = (m : ℝ) * ((2 * m + 1).choose m : ℝ) := by
    have hnat := choose_odd_pred_identity m hm
    have hr : (((2 * m + 1).choose (m - 1) * (m + 2) : ℕ) : ℝ)
        = (((2 * m + 1).choose m * m : ℕ) : ℝ) := by exact_mod_cast hnat
    push_cast at hr
    linarith
  set P : Finset (Fin (2 * m + 1)) → Prop :=
    fun A => A.card = m ∨ A.card = m + 1 with hP
  set F1 := F.filter P with hF1
  set F2 := F.filter (fun A => ¬ P A) with hF2
  have hcard_split : F1.card + F2.card = F.card := by
    rw [hF1, hF2]
    exact Finset.card_filter_add_card_filter_not _
  have hF1le : (F1.card : ℝ) ≤ 2 * ((2 * m + 1).choose m : ℝ) := by
    have hsub : F1 ⊆ Finset.powersetCard m Finset.univ
        ∪ Finset.powersetCard (m + 1) Finset.univ := by
      intro A hA
      rw [hF1, Finset.mem_filter] at hA
      rcases hA.2 with h | h
      · exact Finset.mem_union_left _ (Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, h⟩)
      · exact Finset.mem_union_right _ (Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, h⟩)
    have hle := Finset.card_le_card hsub
    have hun := Finset.card_union_le (Finset.powersetCard m (Finset.univ : Finset (Fin (2*m+1))))
      (Finset.powersetCard (m + 1) (Finset.univ : Finset (Fin (2*m+1))))
    have hpc1 : (Finset.powersetCard m (Finset.univ : Finset (Fin (2 * m + 1)))).card
        = (2 * m + 1).choose m := by simp [Finset.card_powersetCard]
    have hpc2 : (Finset.powersetCard (m + 1) (Finset.univ : Finset (Fin (2 * m + 1)))).card
        = (2 * m + 1).choose m := by
      simp [Finset.card_powersetCard, choose_two_mul_succ_symm m]
    rw [hpc1, hpc2] at hun
    have : F1.card ≤ 2 * (2 * m + 1).choose m := by omega
    exact_mod_cast this
  have hsum_split : lubell F = (∑ A ∈ F1, (((2 * m + 1).choose A.card : ℝ))⁻¹)
      + ∑ A ∈ F2, (((2 * m + 1).choose A.card : ℝ))⁻¹ := by
    rw [lubell, hF1, hF2]
    exact (Finset.sum_filter_add_sum_filter_not F P _).symm
  have hs1 : (∑ A ∈ F1, (((2 * m + 1).choose A.card : ℝ))⁻¹)
      = (F1.card : ℝ) * (((2 * m + 1).choose m : ℝ))⁻¹ := by
    have hpt : ∀ A ∈ F1, (((2 * m + 1).choose A.card : ℝ))⁻¹
        = (((2 * m + 1).choose m : ℝ))⁻¹ := by
      intro A hA
      rw [hF1, Finset.mem_filter] at hA
      rcases hA.2 with h | h
      · rw [h]
      · rw [h, choose_two_mul_succ_symm m]
    rw [Finset.sum_congr rfl hpt, Finset.sum_const, nsmul_eq_mul]
  have hs2 : (F2.card : ℝ) * (((2 * m + 1).choose (m - 1) : ℝ))⁻¹
      ≤ ∑ A ∈ F2, (((2 * m + 1).choose A.card : ℝ))⁻¹ := by
    have hterm : ∀ A ∈ F2, (((2 * m + 1).choose (m - 1) : ℝ))⁻¹
        ≤ (((2 * m + 1).choose A.card : ℝ))⁻¹ := by
      intro A hA
      rw [hF2, Finset.mem_filter] at hA
      have hnot := hA.2
      rw [hP] at hnot
      push_neg at hnot
      have hle : (2 * m + 1).choose A.card ≤ (2 * m + 1).choose (m - 1) :=
        choose_le_choose_pred_of_ne_odd hm hnot.1 hnot.2
      have hpos : (0 : ℝ) < ((2 * m + 1).choose A.card : ℝ) := by
        have : 0 < (2 * m + 1).choose A.card := Nat.choose_pos (by simpa using A.card_le_univ)
        exact_mod_cast this
      have hle' : ((2 * m + 1).choose A.card : ℝ) ≤ ((2 * m + 1).choose (m - 1) : ℝ) := by
        exact_mod_cast hle
      have := one_div_le_one_div_of_le hpos hle'
      simpa [one_div] using this
    have hsum := Finset.sum_le_sum hterm
    rw [Finset.sum_const, nsmul_eq_mul] at hsum
    exact hsum
  set x : ℝ := (F1.card : ℝ) with hx
  set y : ℝ := (F2.card : ℝ) with hy
  set c : ℝ := ((2 * m + 1).choose m : ℝ) with hc
  set c' : ℝ := ((2 * m + 1).choose (m - 1) : ℝ) with hc'
  have hxy : x * c⁻¹ + y * c'⁻¹ ≤ (K : ℝ) := by
    calc x * c⁻¹ + y * c'⁻¹ ≤ (∑ A ∈ F1, (((2 * m + 1).choose A.card : ℝ))⁻¹)
        + ∑ A ∈ F2, (((2 * m + 1).choose A.card : ℝ))⁻¹ := by rw [hs1]; linarith
      _ = lubell F := hsum_split.symm
      _ ≤ (K : ℝ) := hlub
  have hmul : x * c' + y * c ≤ (K : ℝ) * (c * c') := by
    have h := mul_le_mul_of_nonneg_right hxy (le_of_lt (mul_pos hcpos hc'pos))
    have e1 : (x * c⁻¹ + y * c'⁻¹) * (c * c') = x * c' + y * c := by
      field_simp
    rw [e1] at h
    exact h
  have hxnn : 0 ≤ x := by positivity
  have hynn : 0 ≤ y := by positivity
  have hxle : x ≤ 2 * c := hF1le
  have h2 : x * ((m : ℝ) * c) + ((m : ℝ) + 2) * y * c ≤ (K : ℝ) * ((m : ℝ) * c) * c := by
    have h1 : ((m : ℝ) + 2) * (x * c' + y * c) ≤ ((m : ℝ) + 2) * ((K : ℝ) * (c * c')) :=
      mul_le_mul_of_nonneg_left hmul (by positivity)
    have e : ((m : ℝ) + 2) * (x * c' + y * c)
        = x * (((m : ℝ) + 2) * c') + ((m : ℝ) + 2) * y * c := by ring
    have e2 : ((m : ℝ) + 2) * ((K : ℝ) * (c * c')) = (K : ℝ) * c * (((m : ℝ) + 2) * c') := by
      ring
    rw [e, e2, hident] at h1
    calc x * ((m : ℝ) * c) + ((m : ℝ) + 2) * y * c ≤ (K : ℝ) * c * ((m : ℝ) * c) := h1
      _ = (K : ℝ) * ((m : ℝ) * c) * c := by ring
  have h3 : x * (m : ℝ) + ((m : ℝ) + 2) * y ≤ (K : ℝ) * (m : ℝ) * c := by
    have e : (x * (m : ℝ) + ((m : ℝ) + 2) * y) * c ≤ ((K : ℝ) * (m : ℝ) * c) * c := by
      nlinarith [h2]
    exact le_of_mul_le_mul_right e hcpos
  have hstep : ((m : ℝ) + 2) * (x + y) ≤ ((K : ℝ) * m + 4) * c := by nlinarith [hxle, h3]
  have hfinal : ((m : ℝ) + 2) * (F.card : ℝ) ≤ ((K : ℝ) * m + 4) * c := by
    have hxysum : x + y = (F.card : ℝ) := by
      rw [hx, hy]
      exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) hcard_split
    rwa [hxysum] at hstep
  have hnat : ((m + 2) * F.card : ℕ) ≤ ((K * m + 4) * (2 * m + 1).choose m : ℕ) := by
    have hcast : (((m + 2) * F.card : ℕ) : ℝ)
        ≤ (((K * m + 4) * (2 * m + 1).choose m : ℕ) : ℝ) := by
      push_cast
      calc ((m : ℝ) + 2) * (F.card : ℝ) ≤ ((K : ℝ) * m + 4) * c := hfinal
        _ = ((K : ℝ) * (m : ℝ) + 4) * ((2 * m + 1).choose m : ℝ) := by rw [hc]
    exact_mod_cast hcast
  rw [central_two_mul_succ m]
  exact hnat

/-- **Sharpened chain bound for `La`, odd ground set.** -/
theorem La_le_sharpened_odd {m d : ℕ} (hm : 1 ≤ m) :
    (m + 2) * La (2 * m + 1) d ≤ ((2 ^ d - 1) * m + 4) * central (2 * m + 1) := by
  obtain ⟨F, hfree, hcard⟩ := exists_extremal (2 * m + 1) d
  rw [← hcard]
  exact card_le_sharpened_odd hm hfree

/-- On odd ground sets the sharpened bound is also strictly better than the chain bound,
as soon as `d ≥ 2`. -/
theorem sharpened_odd_lt_chain_bound {m d : ℕ} (hd : 2 ≤ d) :
    ((2 ^ d - 1) * m + 4) * central (2 * m + 1)
      < (2 ^ d - 1) * (m + 2) * central (2 * m + 1) := by
  have h2 : 4 ≤ 2 ^ d := by
    calc (4 : ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ d := Nat.pow_le_pow_right (by norm_num) hd
  have hpos : 0 < central (2 * m + 1) := central_pos _
  have hlt : (2 ^ d - 1) * m + 4 < (2 ^ d - 1) * (m + 2) := by
    have he : (2 ^ d - 1) * (m + 2) = (2 ^ d - 1) * m + 2 * (2 ^ d - 1) := by ring
    omega
  exact Nat.mul_lt_mul_of_lt_of_le hlt le_rfl hpos

end Catalog.Algebra.BooleanLatticeChainBound