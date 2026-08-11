import Mathlib
import Logic.StronglyCompleteSets.Contrarian

/-!
# Ordered-block criteria for strong completeness

This file continues the study of *complete* and *strongly complete* sets of natural
numbers begun in `Logic/StronglyCompleteSets/Contrarian.lean`, whose definitions
(`IsSubsetSum`, `Complete`, `StronglyComplete`) we reuse verbatim.

Main contributions:

* monotonicity of completeness and strong completeness under supersets;
* the *initial-segment criterion*: a set is strongly complete iff every tail
  `A ∩ (k, ∞)` is complete, so arbitrary finite deletions reduce to canonical ones;
* an **ordered-block criterion** (`stronglyComplete_of_orderedBlocks`): if `A`
  contains a sequence of pairwise ordered finite blocks whose attainable subset sums
  cover intervals `[lo k, hi k]` satisfying an overlap condition `lo (k+1) ≤ hi k + 1`
  and a doubling condition `2 * lo k ≤ hi k + 1`, then `A` is strongly complete;
* the dyadic specialization, with `dyadicBlock A k = A ∩ Set.Ioc (2^k) (2^(k+1))`;
* a sharp warning: having at least six elements in every large dyadic block is *not*
  sufficient for completeness (the multiples of `3` are a counterexample), which is
  precisely why the analytic divergence hypothesis is needed in the source paper.
-/

namespace StronglyCompleteSets

/-! ## Monotonicity -/

/-- A subset sum for `A` is a subset sum for any superset of `A`. -/
theorem IsSubsetSum.mono {A B : Set ℕ} (h : A ⊆ B) {n : ℕ} (hn : IsSubsetSum A n) :
    IsSubsetSum B n := by
  obtain ⟨s, hs, hsum⟩ := hn
  exact ⟨s, hs.trans h, hsum⟩

/-- Every superset of a complete set is complete. -/
theorem Complete.mono {A B : Set ℕ} (h : A ⊆ B) (hA : Complete A) : Complete B := by
  obtain ⟨N, hN⟩ := hA
  exact ⟨N, fun n hn => (hN n hn).mono h⟩

/-- Every superset of a strongly complete set is strongly complete. -/
theorem StronglyComplete.mono {A B : Set ℕ} (h : A ⊆ B) (hA : StronglyComplete A) :
    StronglyComplete B := fun F hF =>
  (hA F hF).mono (Set.diff_subset_diff_left h)

/-! ## Tails: reduction of finite deletions to initial segments -/

/-- **Initial-segment criterion.** A set is strongly complete precisely when each of its
tails `A ∩ (k, ∞)` is complete.  Thus arbitrary finite deletions may always be replaced
by deletions of initial segments. -/
theorem stronglyComplete_iff_tails {A : Set ℕ} :
    StronglyComplete A ↔ ∀ k : ℕ, Complete (A ∩ Set.Ioi k) := by
  constructor
  · intro hA k
    have h := hA (Set.Iic k) (Set.finite_Iic k)
    have : A \ Set.Iic k = A ∩ Set.Ioi k := by
      ext x; simp [Set.mem_diff, Set.mem_Iic, Set.mem_Ioi]
    exact this ▸ h
  · intro h F hF
    obtain ⟨M, hM⟩ := hF.bddAbove
    refine (h M).mono ?_
    intro x hx
    refine ⟨hx.1, ?_⟩
    intro hxF
    exact absurd (hM hxF) (by simpa using Nat.not_le.mpr hx.2)

/-! ## The ordered-block criterion -/

section Blocks

variable (B : ℕ → Finset ℕ)

/-- In an ordered sequence of nonempty blocks, every element of an earlier block is
smaller than every element of a later block. -/
theorem block_lt_of_lt (hne : ∀ k, (B k).Nonempty)
    (hord : ∀ k, ∀ x ∈ B k, ∀ y ∈ B (k + 1), x < y) :
    ∀ {i k : ℕ}, i < k → ∀ x ∈ B i, ∀ y ∈ B k, x < y := by
  intro i k hik
  induction k with
  | zero => omega
  | succ k ih =>
    intro x hx y hy
    rcases Nat.lt_succ_iff_lt_or_eq.mp hik with h | h
    · obtain ⟨z, hz⟩ := hne k
      exact lt_trans (ih h x hx z hz) (hord k z hz y hy)
    · subst h; exact hord i x hx y hy

/-- In an ordered sequence of nonempty blocks the `k`-th block consists of numbers `≥ k`. -/
theorem le_of_mem_block (hne : ∀ k, (B k).Nonempty)
    (hord : ∀ k, ∀ x ∈ B k, ∀ y ∈ B (k + 1), x < y) :
    ∀ k, ∀ x ∈ B k, k ≤ x := by
  intro k
  induction k with
  | zero => intro x _; exact Nat.zero_le x
  | succ k ih =>
    intro x hx
    obtain ⟨y, hy⟩ := hne k
    have h1 : k ≤ y := ih y hy
    have h2 : y < x := hord k y hy x hx
    omega

/-- The core covering induction: starting from block index `m`, the subset sums of the
first `j + 1` blocks cover every integer between `lo m` and `∑_{i ≤ j} hi (m + i)`. -/
theorem blocks_cover (lo hi : ℕ → ℕ) (m : ℕ)
    (hne : ∀ k, (B k).Nonempty)
    (hord : ∀ k, ∀ x ∈ B k, ∀ y ∈ B (k + 1), x < y)
    (hcov : ∀ k, ∀ n, lo k ≤ n → n ≤ hi k → ∃ s ⊆ B k, ∑ a ∈ s, a = n)
    (hpos : ∀ k, 1 ≤ lo k) (hmono : Monotone lo)
    (hdouble : ∀ k, 2 * lo k ≤ hi k + 1) (hstep : ∀ k, lo (k + 1) ≤ hi k + 1) :
    ∀ j n, lo m ≤ n → n ≤ ∑ i ∈ Finset.range (j + 1), hi (m + i) →
      ∃ s : Finset ℕ, s ⊆ (Finset.range (j + 1)).biUnion (fun i => B (m + i)) ∧
        ∑ a ∈ s, a = n := by
  intro j
  induction j with
  | zero =>
    intro n hn1 hn2
    simp only [Nat.zero_add, Finset.sum_range_one, Nat.add_zero] at hn2
    obtain ⟨s, hs, hsum⟩ := hcov m n hn1 hn2
    refine ⟨s, ?_, hsum⟩
    intro x hx
    simp only [Finset.mem_biUnion, Finset.mem_range]
    exact ⟨0, by omega, by simpa using hs hx⟩
  | succ j ih =>
    intro n hn1 hn2
    set H : ℕ := ∑ i ∈ Finset.range (j + 1), hi (m + i) with hH
    have hsum_succ : ∑ i ∈ Finset.range (j + 2), hi (m + i) = H + hi (m + (j + 1)) := by
      rw [hH, Finset.sum_range_succ]
    rw [hsum_succ] at hn2
    set k : ℕ := m + (j + 1) with hk
    -- a monotonicity fact used repeatedly
    have hHhi : hi (m + j) ≤ H := by
      rw [hH, Finset.sum_range_succ]
      omega
    have hsub_step : ∀ s : Finset ℕ,
        s ⊆ (Finset.range (j + 1)).biUnion (fun i => B (m + i)) →
        s ⊆ (Finset.range (j + 2)).biUnion (fun i => B (m + i)) := by
      intro s hs x hx
      have := hs hx
      simp only [Finset.mem_biUnion, Finset.mem_range] at this ⊢
      obtain ⟨i, hi', hmem⟩ := this
      exact ⟨i, by omega, hmem⟩
    by_cases hle : n ≤ H
    · obtain ⟨s, hs, hsum⟩ := ih n hn1 hle
      exact ⟨s, hsub_step s hs, hsum⟩
    · push_neg at hle
      have hlok : lo k ≤ H + 1 := by
        have hs' : lo k ≤ hi (m + j) + 1 := hstep (m + j)
        omega
      by_cases hsmall : n ≤ hi k
      · -- the last block alone represents `n`
        have h1 : lo k ≤ n := by omega
        obtain ⟨s, hs, hsum⟩ := hcov k n h1 hsmall
        refine ⟨s, ?_, hsum⟩
        intro x hx
        simp only [Finset.mem_biUnion, Finset.mem_range]
        exact ⟨j + 1, by omega, by simpa [hk] using hs hx⟩
      · push_neg at hsmall
        -- split `n = u + v` with `v` inside the last block
        have hmk : m ≤ k := by omega
        have hlomk : lo m ≤ lo k := hmono hmk
        have hL1 : 1 ≤ lo m := hpos m
        have hdk : 2 * lo k ≤ hi k + 1 := hdouble k
        obtain ⟨u, v, hu1, hu2, hv1, hv2, huv⟩ :
            ∃ u v : ℕ, lo m ≤ u ∧ u ≤ H ∧ lo k ≤ v ∧ v ≤ hi k ∧ u + v = n := by
          by_cases hbig : lo m + hi k ≤ n
          · refine ⟨n - hi k, hi k, by omega, by omega, ?_, le_rfl, by omega⟩
            omega
          · refine ⟨lo m, n - lo m, le_rfl, ?_, by omega, by omega, by omega⟩
            have hm2 : 2 * lo m ≤ hi m + 1 := hdouble m
            have : hi m ≤ H := by
              rw [hH]
              have h0 : (0 : ℕ) ∈ Finset.range (j + 1) := by simp
              have := Finset.single_le_sum (f := fun i => hi (m + i))
                (fun i _ => Nat.zero_le (hi (m + i))) h0
              simpa using this
            omega
        obtain ⟨su, hsu, hsumu⟩ := ih u hu1 hu2
        obtain ⟨sv, hsv, hsumv⟩ := hcov k v hv1 hv2
        have hdisj : Disjoint su sv := by
          rw [Finset.disjoint_left]
          intro x hxu hxv
          have hxu' := hsu hxu
          simp only [Finset.mem_biUnion, Finset.mem_range] at hxu'
          obtain ⟨i, hi', hmem⟩ := hxu'
          have hlt : m + i < k := by omega
          have := block_lt_of_lt B hne hord hlt x hmem x (hsv hxv)
          exact lt_irrefl x this
        refine ⟨su ∪ sv, ?_, ?_⟩
        · intro x hx
          rcases Finset.mem_union.mp hx with h | h
          · exact hsub_step su hsu h
          · simp only [Finset.mem_biUnion, Finset.mem_range]
            exact ⟨j + 1, by omega, by simpa [hk] using hsv h⟩
        · rw [Finset.sum_union hdisj, hsumu, hsumv, huv]

/-- **Ordered-block criterion for strong completeness.**

If `A` contains a sequence of nonempty, pairwise ordered finite blocks `B k` such that

* every integer of `[lo k, hi k]` is a subset sum of `B k`,
* `lo` is positive and monotone,
* each covered interval is at least twice as long as its left endpoint
  (`2 * lo k ≤ hi k + 1`),
* consecutive intervals overlap or abut (`lo (k+1) ≤ hi k + 1`),

then `A` is strongly complete: no finite deletion destroys completeness. -/
theorem stronglyComplete_of_orderedBlocks {A : Set ℕ} (lo hi : ℕ → ℕ)
    (hsub : ∀ k, ↑(B k) ⊆ A)
    (hne : ∀ k, (B k).Nonempty)
    (hord : ∀ k, ∀ x ∈ B k, ∀ y ∈ B (k + 1), x < y)
    (hcov : ∀ k, ∀ n, lo k ≤ n → n ≤ hi k → ∃ s ⊆ B k, ∑ a ∈ s, a = n)
    (hpos : ∀ k, 1 ≤ lo k) (hmono : Monotone lo)
    (hdouble : ∀ k, 2 * lo k ≤ hi k + 1) (hstep : ∀ k, lo (k + 1) ≤ hi k + 1) :
    StronglyComplete A := by
  intro F hF
  obtain ⟨M, hM⟩ := hF.bddAbove
  set m : ℕ := M + 1 with hm
  -- every element of a block of index `≥ m` avoids `F`
  have havoid : ∀ k, m ≤ k → ∀ x ∈ B k, x ∉ F := by
    intro k hk x hx hxF
    have h1 : k ≤ x := le_of_mem_block B hne hord k x hx
    have h2 : x ≤ M := hM hxF
    omega
  have hhi : ∀ k, 1 ≤ hi k := by
    intro k
    have := hdouble k
    have := hpos k
    omega
  refine ⟨lo m, fun n hn => ?_⟩
  have hbig : n ≤ ∑ i ∈ Finset.range (n + 1), hi (m + i) := by
    calc n ≤ ∑ _i ∈ Finset.range (n + 1), 1 := by simp
    _ ≤ ∑ i ∈ Finset.range (n + 1), hi (m + i) :=
        Finset.sum_le_sum (fun i _ => hhi (m + i))
  obtain ⟨s, hs, hsum⟩ := blocks_cover B lo hi m hne hord hcov hpos hmono hdouble hstep n n hn hbig
  refine ⟨s, ?_, hsum⟩
  intro x hx
  have hx' := hs hx
  simp only [Finset.mem_biUnion, Finset.mem_range] at hx'
  obtain ⟨i, _, hmem⟩ := hx'
  exact ⟨hsub (m + i) (by simpa using hmem), havoid (m + i) (by omega) x hmem⟩

/-- The ordered-block criterion, in its plain completeness form. -/
theorem complete_of_orderedBlocks {A : Set ℕ} (lo hi : ℕ → ℕ)
    (hsub : ∀ k, ↑(B k) ⊆ A)
    (hne : ∀ k, (B k).Nonempty)
    (hord : ∀ k, ∀ x ∈ B k, ∀ y ∈ B (k + 1), x < y)
    (hcov : ∀ k, ∀ n, lo k ≤ n → n ≤ hi k → ∃ s ⊆ B k, ∑ a ∈ s, a = n)
    (hpos : ∀ k, 1 ≤ lo k) (hmono : Monotone lo)
    (hdouble : ∀ k, 2 * lo k ≤ hi k + 1) (hstep : ∀ k, lo (k + 1) ≤ hi k + 1) :
    Complete A :=
  stronglyComplete_complete
    (stronglyComplete_of_orderedBlocks B lo hi hsub hne hord hcov hpos hmono hdouble hstep)

end Blocks

/-! ## Dyadic blocks -/

/-- The `k`-th dyadic block of `A`. -/
def dyadicBlock (A : Set ℕ) (k : ℕ) : Set ℕ := A ∩ Set.Ioc (2 ^ k) (2 ^ (k + 1))

theorem mem_dyadicBlock {A : Set ℕ} {k n : ℕ} :
    n ∈ dyadicBlock A k ↔ n ∈ A ∧ 2 ^ k < n ∧ n ≤ 2 ^ (k + 1) := by
  simp [dyadicBlock, Set.mem_Ioc]

/-- Every natural number `≥ 2` lies in some dyadic range, so the dyadic blocks of `A`
cover `A ∩ [2, ∞)`. -/
theorem exists_dyadic_index {n : ℕ} (hn : 2 ≤ n) : ∃ k, 2 ^ k < n ∧ n ≤ 2 ^ (k + 1) := by
  induction n with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hn with h | h
    · exact ⟨0, by norm_num; omega⟩
    · have hn1 : 2 ≤ n := by omega
      obtain ⟨k, hk1, hk2⟩ := ih hn1
      rcases Nat.eq_or_lt_of_le hk2 with h2 | h2
      · refine ⟨k + 1, by omega, ?_⟩
        have e1 : (2 : ℕ) ^ (k + 1 + 1) = 2 ^ (k + 1) + 2 ^ (k + 1) := by ring
        have e2 : (1 : ℕ) ≤ 2 ^ (k + 1) := Nat.one_le_two_pow
        omega
      · exact ⟨k, by omega, by omega⟩

/-- **Dyadic specialization.** If, from some point on, `A` contains every element of each
dyadic range, then `A` is strongly complete.  The blocks used are unions of two
consecutive dyadic ranges, which is what makes the doubling hypothesis of
`stronglyComplete_of_orderedBlocks` available. -/
theorem stronglyComplete_of_full_dyadicBlocks {A : Set ℕ} (K : ℕ)
    (h : ∀ k, K ≤ k → Set.Ioc (2 ^ k) (2 ^ (k + 1)) ⊆ A) :
    StronglyComplete A := by
  classical
  refine stronglyComplete_of_orderedBlocks
    (fun j => Finset.Ioc (2 ^ (K + 2 * j)) (2 ^ (K + 2 * j + 2)))
    (fun j => 2 ^ (K + 2 * j) + 1) (fun j => 2 ^ (K + 2 * j + 2)) ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_
  · -- blocks are contained in `A`
    intro j x hx
    simp only [Finset.coe_Ioc, Set.mem_Ioc] at hx
    have hpow : (2 : ℕ) ^ (K + 2 * j + 1) < 2 ^ (K + 2 * j + 2) :=
      Nat.pow_lt_pow_right (by norm_num) (by omega)
    by_cases hcase : x ≤ 2 ^ (K + 2 * j + 1)
    · exact h (K + 2 * j) (by omega) ⟨hx.1, hcase⟩
    · exact h (K + 2 * j + 1) (by omega) ⟨by omega, hx.2⟩
  · -- nonempty
    intro j
    refine ⟨2 ^ (K + 2 * j + 2), ?_⟩
    simp only [Finset.mem_Ioc]
    exact ⟨Nat.pow_lt_pow_right (by norm_num) (by omega), le_rfl⟩
  · -- ordered
    intro j x hx y hy
    simp only [Finset.mem_Ioc] at hx hy
    have e : K + 2 * (j + 1) = K + 2 * j + 2 := by ring
    rw [e] at hy
    omega
  · -- coverage by singletons
    intro j n h1 h2
    dsimp only at h1 h2
    refine ⟨{n}, ?_, by simp⟩
    intro x hx
    simp only [Finset.mem_singleton] at hx
    subst hx
    simp only [Finset.mem_Ioc]
    omega
  · intro j
    dsimp only
    have h3 : (1 : ℕ) ≤ 2 ^ (K + 2 * j) := Nat.one_le_two_pow
    omega
  · intro i j hij
    dsimp only
    have : (2 : ℕ) ^ (K + 2 * i) ≤ 2 ^ (K + 2 * j) :=
      Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  · intro j
    dsimp only
    have h1 : (2 : ℕ) ^ (K + 2 * j + 2) = 2 * (2 ^ (K + 2 * j + 1)) := by ring
    have h2 : (2 : ℕ) ^ (K + 2 * j + 1) = 2 * (2 ^ (K + 2 * j)) := by ring
    have h3 : (1 : ℕ) ≤ 2 ^ (K + 2 * j) := Nat.one_le_two_pow
    omega
  · intro j
    dsimp only
    have e : K + 2 * (j + 1) = K + 2 * j + 2 := by ring
    rw [e]

/-! ## Six elements per dyadic block do not suffice -/

/-- The set of multiples of `3`. -/
def multiplesOfThree : Set ℕ := {n | 3 ∣ n}

/-- Every dyadic block of `multiplesOfThree` with `k ≥ 5` contains at least six elements. -/
theorem six_elements_in_dyadicBlock (k : ℕ) (hk : 5 ≤ k) :
    ∃ s : Finset ℕ, s.card = 6 ∧ ↑s ⊆ dyadicBlock multiplesOfThree k := by
  classical
  have h32 : (32 : ℕ) ≤ 2 ^ k := by
    calc (32 : ℕ) = 2 ^ 5 := by norm_num
    _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk
  obtain ⟨c, hc3, hc1, hc2⟩ : ∃ c : ℕ, 3 ∣ c ∧ 2 ^ k < c ∧ c + 15 ≤ 2 ^ (k + 1) := by
    have hdm := Nat.div_add_mod (2 ^ k) 3
    have hlt : 2 ^ k % 3 < 3 := Nat.mod_lt _ (by norm_num)
    have hpow : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    exact ⟨3 * (2 ^ k / 3 + 1), ⟨2 ^ k / 3 + 1, rfl⟩, by omega, by omega⟩
  refine ⟨(Finset.range 6).image (fun i => c + 3 * i), ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ (fun a b hab => by omega), Finset.card_range]
  · intro x hx
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_range] at hx
    obtain ⟨i, hi, rfl⟩ := hx
    obtain ⟨t, ht⟩ := hc3
    rw [mem_dyadicBlock]
    exact ⟨⟨t + i, by omega⟩, by omega, by omega⟩

/-- `multiplesOfThree` is not complete: subset sums of multiples of three are multiples
of three. -/
theorem multiplesOfThree_not_complete : ¬ Complete multiplesOfThree := by
  rintro ⟨N, hN⟩
  obtain ⟨s, hs, hsum⟩ := hN (3 * N + 1) (by omega)
  have hdvd : (3 : ℕ) ∣ ∑ a ∈ s, a := by
    refine Finset.dvd_sum ?_
    intro a ha
    exact hs ha
  rw [hsum] at hdvd
  omega

/-- **Six elements per dyadic block are not sufficient.**  There is a set with at least six
elements in every dyadic block of index `≥ 5` which is not even complete, let alone
strongly complete.  Hence any dyadic criterion must include a hypothesis (such as the
paper's analytic divergence condition) ruling out congruence obstructions. -/
theorem six_per_block_insufficient :
    ∃ A : Set ℕ, (∀ k, 5 ≤ k → ∃ s : Finset ℕ, s.card = 6 ∧ ↑s ⊆ dyadicBlock A k) ∧
      ¬ Complete A :=
  ⟨multiplesOfThree, fun k hk => six_elements_in_dyadicBlock k hk,
    multiplesOfThree_not_complete⟩

end StronglyCompleteSets