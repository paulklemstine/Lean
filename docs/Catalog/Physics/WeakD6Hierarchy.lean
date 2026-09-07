import Physics.WeakD6Core

/-!
# The height hierarchy: weak `D_{2^m-2}`-freeness in an `(m+1)`-layer window

The three-layer / four-layer analysis of `Physics.WeakD6Core` is the case
`m = 3` of a uniform phenomenon.  Inside a window of `m + 1` consecutive layers
of `2^[n]`:

* a weak copy of `D_j` needs `j` sets strictly between two members, and an
  interval of height `d` has exactly `2^d - 2` interior sets
  (`WeakD6.card_openInterval`);
* hence a window of height `m` is automatically weakly `D_{2^m-1}`-free
  (`WeakD6.window_weaklyDiamondFree`), which for `m = 2` is the statement that
  three layers are `D₃`-free;
* and at the critical threshold `j = 2^m - 2` freeness is *equivalent* to
  interval exclusion at height exactly `m`
  (`WeakD6.window_exclusion_iff`), which for `m = 3` is the `D₆` criterion and
  for `m = 2` is the classical diamond (`D₂`) criterion;
* the `m`-layer family is saturated: any set of the next layer up completes an
  interval and creates a weak `D_{2^m-2}` (`WeakD6.windowFamily_saturated`).

This is the structural backbone that makes the `D₆` results of the other files
special cases rather than coincidences.
-/

namespace WeakD6

open Finset

/-- A family containing a full interval of height `m` weakly contains
`D_{2^m-2}`. -/
theorem not_weaklyDiamondFree_of_interval_subset {F : Finset (Finset ℕ)} {A C : Finset ℕ}
    {m : ℕ} (hm : 1 ≤ m) (hA : A ∈ F) (hC : C ∈ F) (hAC : A ⊆ C)
    (hcard : C.card = A.card + m) (hint : openInterval A C ⊆ F) :
    ¬ WeaklyDiamondFree (2 ^ m - 2) F := by
  intro hfree
  have hne : A ≠ C := by
    intro h
    rw [h] at hcard
    omega
  exact hfree ⟨A, hA, C, hC, openInterval A C, hint,
    by rw [card_openInterval hAC hne, show C.card - A.card = m by omega],
    fun B hB => mem_openInterval.1 hB⟩

/-- **Automatic freeness in a window of height `m`.**  A family whose members all
have sizes in `[k, k+m]` is weakly `D_{2^m-1}`-free: an interval of height at
most `m` has at most `2^m - 2` interior sets. -/
theorem window_weaklyDiamondFree (m k : ℕ) (hm : 1 ≤ m) (F : Finset (Finset ℕ))
    (hF : ∀ S ∈ F, k ≤ S.card ∧ S.card ≤ k + m) :
    WeaklyDiamondFree (2 ^ m - 1) F := by
  have h2m : 2 ≤ 2 ^ m := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hm
  rintro ⟨A, hA, C, hC, S, hSF, hScard, hS⟩
  have hSne : S.Nonempty := Finset.card_pos.1 (by omega)
  obtain ⟨B₀, hB₀⟩ := hSne
  obtain ⟨hAC, hlow⟩ := card_lt_of_between (hS B₀ hB₀).1 (hS B₀ hB₀).2
  have hA' := hF A hA
  have hC' := hF C hC
  have hne : A ≠ C := by intro h; rw [h] at hlow; omega
  have hsub : S ⊆ openInterval A C := fun B hB => mem_openInterval.2 (hS B hB)
  have hcards := Finset.card_le_card hsub
  rw [card_openInterval hAC hne, hScard] at hcards
  have hd : C.card - A.card ≤ m := by omega
  have hmono : (2 : ℕ) ^ (C.card - A.card) ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hd
  omega

/-- **The critical criterion.**  In a window of height `m ≥ 2`, weak
`D_{2^m-2}`-freeness is *equivalent* to interval exclusion at height exactly
`m`: every interval of height `m` with endpoints in the family misses one of its
`2^m - 2` interior sets.  For `m = 3` this is the `D₆` criterion, for `m = 2` the
classical diamond criterion. -/
theorem window_exclusion_iff (m k : ℕ) (hm : 2 ≤ m) (F : Finset (Finset ℕ))
    (hF : ∀ S ∈ F, k ≤ S.card ∧ S.card ≤ k + m) :
    WeaklyDiamondFree (2 ^ m - 2) F ↔
      ∀ A ∈ F, ∀ C ∈ F, A ⊆ C → C.card = A.card + m → ∃ B, A ⊂ B ∧ B ⊂ C ∧ B ∉ F := by
  have h2m : 2 ≤ 2 ^ m := by
    calc 2 = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) (by omega)
  constructor
  · intro hfree A hA C hC hAC hcard
    by_contra hcon
    push_neg at hcon
    refine not_weaklyDiamondFree_of_interval_subset (by omega) hA hC hAC hcard ?_ hfree
    intro B hB
    rw [mem_openInterval] at hB
    exact hcon B hB.1 hB.2
  · intro hex
    rintro ⟨A, hA, C, hC, S, hSF, hScard, hS⟩
    have hSne : S.Nonempty := by
      refine Finset.card_pos.1 ?_
      rw [hScard]
      have : 4 ≤ 2 ^ m := by
        calc (4 : ℕ) = 2 ^ 2 := by norm_num
          _ ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hm
      omega
    obtain ⟨B₀, hB₀⟩ := hSne
    obtain ⟨hAC, hlow⟩ := card_lt_of_between (hS B₀ hB₀).1 (hS B₀ hB₀).2
    have hA' := hF A hA
    have hC' := hF C hC
    have hne : A ≠ C := by intro h; rw [h] at hlow; omega
    have hsub : S ⊆ openInterval A C := fun B hB => mem_openInterval.2 (hS B hB)
    have hcards := Finset.card_le_card hsub
    rw [card_openInterval hAC hne, hScard] at hcards
    -- the height must be exactly `m`
    have h4 : (4 : ℕ) ≤ 2 ^ (C.card - A.card) := by
      calc (4 : ℕ) = 2 ^ 2 := by norm_num
        _ ≤ 2 ^ (C.card - A.card) := Nat.pow_le_pow_right (by norm_num) (by omega)
    have hd : C.card - A.card = m := by
      by_contra hcon
      have hlt : C.card - A.card < m := by omega
      have hpow : (2 : ℕ) ^ (C.card - A.card) < 2 ^ m :=
        Nat.pow_lt_pow_right (by norm_num) hlt
      omega
    obtain ⟨B, hAB, hBC, hBF⟩ := hex A hA C hC hAC (by omega)
    have hIcard : (openInterval A C).card = 2 ^ m - 2 := by
      rw [card_openInterval hAC hne, hd]
    have : S = openInterval A C := Finset.eq_of_subset_of_card_le hsub (by omega)
    exact hBF (hSF (this ▸ mem_openInterval.2 ⟨hAB, hBC⟩))

/-- The window of `m` consecutive layers `k, …, k+m-1`. -/
def windowFamily (n k m : ℕ) : Finset (Finset ℕ) :=
  (Finset.range m).biUnion (fun j => layer n (k + j))

lemma mem_windowFamily {n k m : ℕ} {S : Finset ℕ} :
    S ∈ windowFamily n k m ↔ S ⊆ Finset.range n ∧ ∃ j < m, S.card = k + j := by
  simp only [windowFamily, Finset.mem_biUnion, Finset.mem_range, mem_layer]
  constructor
  · rintro ⟨j, hj, hsub, hcard⟩; exact ⟨hsub, j, hj, hcard⟩
  · rintro ⟨hsub, j, hj, hcard⟩; exact ⟨j, hj, hsub, hcard⟩

/-- The window of `m` layers has `∑_{j<m} C(n, k+j)` members. -/
theorem card_windowFamily (n k m : ℕ) :
    (windowFamily n k m).card = ∑ j ∈ Finset.range m, n.choose (k + j) := by
  classical
  rw [windowFamily, Finset.card_biUnion]
  · exact Finset.sum_congr rfl fun j _ => card_layer n (k + j)
  · intro i _ j _ hij
    exact layer_disjoint (by omega)

/-- **Saturation of the window.**  Adding to the `m`-layer window any set of the
next layer up creates a weak copy of `D_{2^m-2}`; in particular `m+1` full
consecutive layers are never weakly `D_{2^m-2}`-free. -/
theorem windowFamily_saturated (n k m : ℕ) (hm : 2 ≤ m) {X : Finset ℕ}
    (hXsub : X ⊆ Finset.range n) (hXcard : X.card = k + m) :
    ¬ WeaklyDiamondFree (2 ^ m - 2) (insert X (windowFamily n k m)) := by
  classical
  obtain ⟨A, hAX, hAcard⟩ := Finset.exists_subset_card_eq (show k ≤ X.card by omega)
  refine not_weaklyDiamondFree_of_interval_subset (by omega)
    (Finset.mem_insert_of_mem (mem_windowFamily.2 ⟨hAX.trans hXsub, 0, by omega, by omega⟩))
    (Finset.mem_insert_self _ _) hAX (by omega) ?_
  intro B hB
  rw [mem_openInterval] at hB
  obtain ⟨hAB, hBX⟩ := hB
  have h1 := Finset.card_lt_card hAB
  have h2 := Finset.card_lt_card hBX
  refine Finset.mem_insert_of_mem (mem_windowFamily.2 ⟨hBX.1.trans hXsub, B.card - k, by omega, ?_⟩)
  omega

end WeakD6