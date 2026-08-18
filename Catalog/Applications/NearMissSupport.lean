/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Shared.PowerSumSharpness

/-!
# The support of a power-sum near miss

This file continues the analysis of `Shared/PowerSumSharpness.lean`.

Recall the setting there: for a multiset `s` of naturals bounded by `N`,
`powerSum s k = ∑_{x ∈ s} x ^ k`.  A **near miss at level `N`** is a pair `s ≠ t` of
multisets bounded by `N` with `powerSum s k = powerSum t k` for every `k < N`; the
canonical example is the *binomial pair* `evenPart N` / `oddPart N`.

Earlier cycles established that the binomial pair minimises

* the top-index separation (`factorial_le_powerSum_gap`, `factorial_gap_attained`), and
* the cardinality (`two_pow_le_two_mul_card_of_near_miss`, `card_evenPart`).

The open successor question was: does it also minimise the **support size**, i.e. the number
of *distinct values* used, and is that minimum `⌈(N+1)/2⌉`?  This file answers **yes** to
both, by proving a structure theorem that is strictly stronger than the multiplicity-level
`near_miss_classification` of the previous cycle.

## Main results

* `near_miss_structure` — **every** near miss at level `N` is, as a *multiset* identity,
  a positive integer multiple of the binomial pair plus a common padding:
  `s = lam • evenPart N + u` and `t = lam • oddPart N + u` (or with the roles swapped),
  with `lam ≥ 1`.  This upgrades `near_miss_classification` from an identity between
  multiplicity vectors to an identity between multisets, and it makes the whole near-miss
  family completely explicit.
* `near_miss_iff` — the converse holds too, so this is a *complete description*: a pair
  bounded by `N` is a near miss iff it is a scaled binomial pair plus common padding.
* `support_union_eq_range` — the two supports *together* always exhaust `{0,…,N}`; hence
  `card_support_add_card_support` : `N + 1 ≤ |supp s| + |supp t|`.
* `card_support_max_lower_bound` — `⌈(N+1)/2⌉ = N/2 + 1 ≤ max |supp s| |supp t|`, and
  `card_support_min_lower_bound` — `⌊(N+1)/2⌋ = (N+1)/2 ≤ min |supp s| |supp t|`.
* `card_support_evenPart`, `card_support_oddPart` — the binomial pair has support sizes
  exactly `N/2 + 1` and `(N+1)/2`, so **both** bounds above are attained
  (`binomial_pair_minimises_support`).
* `disjoint_support_near_miss` — a near miss whose two supports are *disjoint* is exactly a
  scalar multiple of the binomial pair (zero padding), `minimal_support_near_miss` — the
  same conclusion from support-minimality alone, and `minimal_card_near_miss_eq_binomial` —
  a near miss of minimal cardinality `2 ^ (N-1)` *is* the binomial pair.
* `support_partition_iff_disjoint` — equality `|supp s| + |supp t| = N + 1` holds iff the
  supports are disjoint, i.e. iff the near miss is a scaled binomial pair.

## Lab notes (computed, see `ComputationalEvidence.md`)

| `N`                | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|--------------------|---|---|---|---|---|---|---|---|---|
| `|supp evenPart N|`| 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 | 5 |
| `|supp oddPart N|` | 0 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 |
| `|evenPart N|`     | 1 | 1 | 2 | 4 | 8 | 16| 32| 64|128|

The support sizes are `⌈(N+1)/2⌉` and `⌊(N+1)/2⌋`, the cardinalities `2^(N-1)`.
-/

open Finset

namespace PowerSumSharpness

/-! ### The support of a multiset -/

/-- The **support** of a multiset of naturals: the finset of distinct values it uses. -/
def support (s : Multiset ℕ) : Finset ℕ := s.toFinset

lemma mem_support {s : Multiset ℕ} {j : ℕ} : j ∈ support s ↔ 0 < s.count j := by
  simp [support, Multiset.count_pos]

lemma support_subset_range {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) :
    support s ⊆ Finset.range (N + 1) := by
  intro j hj
  rw [support, Multiset.mem_toFinset] at hj
  exact Finset.mem_range.mpr (Nat.lt_succ_of_le (hs j hj))

/-! ### Counting evens and odds in an initial segment -/

/-- The number of even naturals below `n` is `⌈n/2⌉ = (n+1)/2`. -/
lemma card_filter_even_range (n : ℕ) :
    ((Finset.range n).filter (fun j => Even j)).card = (n + 1) / 2 := by
  classical
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.range_add_one, Finset.filter_insert]
      by_cases hn : Even n
      · rw [if_pos hn, Finset.card_insert_of_notMem (by simp), ih]
        rw [Nat.even_iff] at hn; omega
      · rw [if_neg hn, ih]
        rw [Nat.not_even_iff] at hn; omega

/-- The number of odd naturals below `n` is `⌊n/2⌋`. -/
lemma card_filter_odd_range (n : ℕ) :
    ((Finset.range n).filter (fun j => ¬ Even j)).card = n / 2 := by
  classical
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.range_add_one, Finset.filter_insert]
      by_cases hn : Even n
      · rw [if_neg (by simpa using hn), ih]
        rw [Nat.even_iff] at hn; omega
      · rw [if_pos hn, Finset.card_insert_of_notMem (by simp), ih]
        rw [Nat.not_even_iff] at hn; omega

/-! ### Supports of the binomial pair -/

lemma count_evenPart (N j : ℕ) :
    (evenPart N).count j = if j ≤ N then (if Even j then N.choose j else 0) else 0 := by
  rw [evenPart, count_ofCounts]

lemma count_oddPart (N j : ℕ) :
    (oddPart N).count j = if j ≤ N then (if Even j then 0 else N.choose j) else 0 := by
  rw [oddPart, count_ofCounts]

lemma support_evenPart (N : ℕ) :
    support (evenPart N) = (Finset.range (N + 1)).filter (fun j => Even j) := by
  classical
  ext j
  rw [mem_support, count_evenPart, Finset.mem_filter, Finset.mem_range]
  constructor
  · intro hj
    by_cases hjN : j ≤ N
    · rw [if_pos hjN] at hj
      by_cases hev : Even j
      · exact ⟨by omega, hev⟩
      · rw [if_neg hev] at hj; omega
    · rw [if_neg hjN] at hj; omega
  · rintro ⟨hjN, hev⟩
    rw [if_pos (by omega : j ≤ N), if_pos hev]
    exact Nat.choose_pos (by omega)

lemma support_oddPart (N : ℕ) :
    support (oddPart N) = (Finset.range (N + 1)).filter (fun j => ¬ Even j) := by
  classical
  ext j
  rw [mem_support, count_oddPart, Finset.mem_filter, Finset.mem_range]
  constructor
  · intro hj
    by_cases hjN : j ≤ N
    · rw [if_pos hjN] at hj
      by_cases hev : Even j
      · rw [if_pos hev] at hj; omega
      · exact ⟨by omega, hev⟩
    · rw [if_neg hjN] at hj; omega
  · rintro ⟨hjN, hev⟩
    rw [if_pos (by omega : j ≤ N), if_neg hev]
    exact Nat.choose_pos (by omega)

/-- The even part uses exactly `⌈(N+1)/2⌉ = N/2 + 1` distinct values. -/
theorem card_support_evenPart (N : ℕ) : (support (evenPart N)).card = N / 2 + 1 := by
  rw [support_evenPart, card_filter_even_range]
  omega

/-- The odd part uses exactly `⌊(N+1)/2⌋ = (N+1)/2` distinct values. -/
theorem card_support_oddPart (N : ℕ) : (support (oddPart N)).card = (N + 1) / 2 := by
  rw [support_oddPart, card_filter_odd_range]

/-- The supports of the two halves of the binomial pair are disjoint. -/
theorem disjoint_support_binomial (N : ℕ) :
    Disjoint (support (evenPart N)) (support (oddPart N)) := by
  classical
  rw [support_evenPart, support_oddPart, Finset.disjoint_left]
  intro j hj hj'
  rw [Finset.mem_filter] at hj hj'
  exact hj'.2 hj.2

/-- Together the two halves use every value in `{0,…,N}`. -/
theorem support_union_binomial (N : ℕ) :
    support (evenPart N) ∪ support (oddPart N) = Finset.range (N + 1) := by
  classical
  rw [support_evenPart, support_oddPart, ← Finset.filter_or]
  exact Finset.filter_true_of_mem fun j _ => em (Even j)

/-! ### The structure theorem for near misses -/

/-- Auxiliary step: from the multiplicity identity with a *nonnegative* multiplier `lam` we
read off an honest multiset decomposition, the padding being the common part. -/
lemma near_miss_decomposition_of_counts {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N) (lam : ℕ)
    (hlam : ∀ j ≤ N, (s.count j : ℤ) - (t.count j : ℤ)
      = (lam : ℤ) * ((-1 : ℤ) ^ j * (N.choose j))) :
    ∃ u : Multiset ℕ, (∀ x ∈ u, x ≤ N) ∧
      s = lam • evenPart N + u ∧ t = lam • oddPart N + u := by
  classical
  set c : ℕ → ℕ := fun j => if Even j then t.count j else s.count j with hc
  refine ⟨ofCounts N c, fun x hx => mem_ofCounts_le _ _ hx, ?_, ?_⟩
  · refine Multiset.ext.mpr fun m => ?_
    rw [Multiset.count_add, count_ofCounts, Multiset.count_nsmul, count_evenPart]
    by_cases hm : m ≤ N
    · by_cases hev : Even m
      · simp only [hc, if_pos hm, if_pos hev]
        have h1 := hlam m hm
        rw [hev.neg_one_pow, one_mul] at h1
        have h2 : (s.count m : ℤ) = (lam : ℤ) * (N.choose m : ℤ) + (t.count m : ℤ) := by
          linarith
        exact_mod_cast h2
      · simp only [hc, if_pos hm, if_neg hev, mul_zero, zero_add]
    · simp only [hc, if_neg hm, mul_zero, add_zero]
      exact Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem)
  · refine Multiset.ext.mpr fun m => ?_
    rw [Multiset.count_add, count_ofCounts, Multiset.count_nsmul, count_oddPart]
    by_cases hm : m ≤ N
    · by_cases hev : Even m
      · simp only [hc, if_pos hm, if_pos hev, mul_zero, zero_add]
      · simp only [hc, if_pos hm, if_neg hev]
        have h1 := hlam m hm
        rw [(Nat.not_even_iff_odd.mp hev).neg_one_pow] at h1
        have h2 : (t.count m : ℤ) = (lam : ℤ) * (N.choose m : ℤ) + (s.count m : ℤ) := by
          linarith
        exact_mod_cast h2
    · simp only [hc, if_neg hm, mul_zero, add_zero]
      exact Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)

/-- **Structure theorem for near misses.**  Every pair of *distinct* multisets bounded by `N`
whose power sums agree below the top index is a positive integral multiple of the binomial
pair `evenPart N` / `oddPart N`, plus a common padding multiset.  This is an identity of
multisets, strictly stronger than the multiplicity-vector statement
`near_miss_classification`. -/
theorem near_miss_structure {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    ∃ (lam : ℕ) (u : Multiset ℕ), 1 ≤ lam ∧ (∀ x ∈ u, x ≤ N) ∧
      ((s = lam • evenPart N + u ∧ t = lam • oddPart N + u) ∨
       (s = lam • oddPart N + u ∧ t = lam • evenPart N + u)) := by
  classical
  have hcounts := count_diff_eq_smul_alternating hs ht h
  set L : ℤ := (s.count 0 : ℤ) - (t.count 0 : ℤ) with hL
  have hL0 : L ≠ 0 := by
    intro h0
    refine hne (Multiset.ext.mpr fun m => ?_)
    by_cases hm : m ≤ N
    · have hcm := hcounts m hm
      rw [h0, zero_mul, sub_eq_zero] at hcm
      exact_mod_cast hcm
    · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem),
        Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)]
  rcases lt_or_gt_of_ne hL0 with hneg | hpos
  · have hlam : ∀ j ≤ N, (t.count j : ℤ) - (s.count j : ℤ)
        = (((-L).toNat : ℕ) : ℤ) * ((-1 : ℤ) ^ j * (N.choose j)) := by
      intro j hj
      have hcj := hcounts j hj
      rw [Int.toNat_of_nonneg (by omega : (0 : ℤ) ≤ -L)]
      linarith [hcj]
    obtain ⟨u, hu, h1, h2⟩ := near_miss_decomposition_of_counts ht hs (-L).toNat hlam
    exact ⟨(-L).toNat, u, by omega, hu, Or.inr ⟨h2, h1⟩⟩
  · have hlam : ∀ j ≤ N, (s.count j : ℤ) - (t.count j : ℤ)
        = ((L.toNat : ℕ) : ℤ) * ((-1 : ℤ) ^ j * (N.choose j)) := by
      intro j hj
      have hcj := hcounts j hj
      rw [Int.toNat_of_nonneg (by omega : (0 : ℤ) ≤ L)]
      exact hcj
    obtain ⟨u, hu, h1, h2⟩ := near_miss_decomposition_of_counts hs ht L.toNat hlam
    exact ⟨L.toNat, u, by omega, hu, Or.inl ⟨h1, h2⟩⟩

/-! ### The converse: a complete description of the near-miss family -/

lemma powerSum_nsmul (n : ℕ) (s : Multiset ℕ) (k : ℕ) :
    powerSum (n • s) k = (n : ℤ) * powerSum s k := by
  induction n with
  | zero => simp
  | succ n ih => rw [succ_nsmul, powerSum_add, ih]; push_cast; ring

lemma count_zero_evenPart (N : ℕ) : (evenPart N).count 0 = 1 := by
  rw [count_evenPart, if_pos (Nat.zero_le N), if_pos (Nat.even_iff.mpr rfl),
    Nat.choose_zero_right]

lemma count_zero_oddPart (N : ℕ) : (oddPart N).count 0 = 0 := by
  rw [count_oddPart, if_pos (Nat.zero_le N), if_pos (Nat.even_iff.mpr rfl)]

/-- **Sufficiency.**  Every scaled binomial pair with common padding really is a near miss. -/
theorem scaled_binomial_is_near_miss (N : ℕ) {lam : ℕ} (hlam : 1 ≤ lam) (u : Multiset ℕ) :
    (∀ k < N, powerSum (lam • evenPart N + u) k = powerSum (lam • oddPart N + u) k) ∧
      lam • evenPart N + u ≠ lam • oddPart N + u := by
  constructor
  · intro k hk
    rw [powerSum_add, powerSum_add, powerSum_nsmul, powerSum_nsmul,
      powerSum_evenPart_eq_oddPart N hk]
  · intro heq
    have := congrArg (fun m : Multiset ℕ => m.count 0) heq
    simp only [Multiset.count_add, Multiset.count_nsmul, count_zero_evenPart,
      count_zero_oddPart] at this
    omega

/-- **Complete description of the near misses at level `N`.**  A pair of multisets bounded
by `N` is a near miss (equal power sums below the top index, but distinct) *if and only if*
it is a positive multiple of the binomial pair plus a common padding.  The moduli of near
misses at level `N` is therefore `{(lam, u) : lam ≥ 1, u bounded by N}`, doubled by the
swap. -/
theorem near_miss_iff {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N) :
    ((∀ k < N, powerSum s k = powerSum t k) ∧ s ≠ t) ↔
      ∃ (lam : ℕ) (u : Multiset ℕ), 1 ≤ lam ∧ (∀ x ∈ u, x ≤ N) ∧
        ((s = lam • evenPart N + u ∧ t = lam • oddPart N + u) ∨
         (s = lam • oddPart N + u ∧ t = lam • evenPart N + u)) := by
  constructor
  · rintro ⟨h, hne⟩
    exact near_miss_structure hs ht h hne
  · rintro ⟨lam, u, hlam, -, hcase⟩
    obtain ⟨hpow, hnepair⟩ := scaled_binomial_is_near_miss N hlam u
    rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact ⟨fun k hk => by rw [h1, h2]; exact hpow k hk, by rw [h1, h2]; exact hnepair⟩
    · refine ⟨fun k hk => by rw [h1, h2]; exact (hpow k hk).symm, ?_⟩
      rw [h1, h2]
      exact fun hc => hnepair hc.symm

/-! ### Consequences for the support -/

lemma support_mono_of_le {a b : Multiset ℕ} (hab : a ≤ b) : support a ⊆ support b := by
  intro j hj
  rw [mem_support] at hj ⊢
  exact lt_of_lt_of_le hj (Multiset.count_le_of_le j hab)

lemma support_nsmul_of_pos {lam : ℕ} (hlam : 1 ≤ lam) (a : Multiset ℕ) :
    support (lam • a) = support a := by
  ext j
  rw [mem_support, mem_support, Multiset.count_nsmul]
  constructor
  · intro hj; nlinarith
  · intro hj; exact Nat.mul_pos (by omega) hj

/-- **Every near miss contains a full binomial half in each side.**  Up to swapping,
the support of one side contains all even values `≤ N` and the support of the other contains
all odd values `≤ N`. -/
theorem near_miss_support_contains_halves {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    (support (evenPart N) ⊆ support s ∧ support (oddPart N) ⊆ support t) ∨
    (support (oddPart N) ⊆ support s ∧ support (evenPart N) ⊆ support t) := by
  obtain ⟨lam, u, hlam, -, hcase⟩ := near_miss_structure hs ht h hne
  have key : ∀ (a b : Multiset ℕ), b = lam • a + u → support a ⊆ support b := by
    intro a b hb
    rw [hb, ← support_nsmul_of_pos hlam a]
    exact support_mono_of_le (Multiset.le_add_right _ _)
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨key _ _ h1, key _ _ h2⟩
  · exact Or.inr ⟨key _ _ h1, key _ _ h2⟩

/-- **The two supports of a near miss exhaust `{0,…,N}`.** -/
theorem support_union_eq_range {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    support s ∪ support t = Finset.range (N + 1) := by
  refine Finset.Subset.antisymm (Finset.union_subset (support_subset_range hs)
    (support_subset_range ht)) ?_
  rcases near_miss_support_contains_halves hs ht h hne with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · calc Finset.range (N + 1) = support (evenPart N) ∪ support (oddPart N) :=
          (support_union_binomial N).symm
      _ ⊆ support s ∪ support t := Finset.union_subset_union h1 h2
  · calc Finset.range (N + 1) = support (oddPart N) ∪ support (evenPart N) := by
          rw [Finset.union_comm]; exact (support_union_binomial N).symm
      _ ⊆ support s ∪ support t := Finset.union_subset_union h1 h2

/-- **Total support bound.**  A near miss at level `N` must use at least `N + 1` distinct
values in total. -/
theorem card_support_add_card_support {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    N + 1 ≤ (support s).card + (support t).card := by
  classical
  have hu := support_union_eq_range hs ht h hne
  calc N + 1 = (Finset.range (N + 1)).card := (Finset.card_range _).symm
    _ = (support s ∪ support t).card := by rw [hu]
    _ ≤ (support s).card + (support t).card := Finset.card_union_le _ _

/-- **Support lower bound, larger side.**  One side of a near miss uses at least
`⌈(N+1)/2⌉ = N/2 + 1` distinct values. -/
theorem card_support_max_lower_bound {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    N / 2 + 1 ≤ max (support s).card (support t).card := by
  rcases near_miss_support_contains_halves hs ht h hne with ⟨h1, -⟩ | ⟨-, h2⟩
  · have := Finset.card_le_card h1
    rw [card_support_evenPart] at this
    exact le_trans this (le_max_left _ _)
  · have := Finset.card_le_card h2
    rw [card_support_evenPart] at this
    exact le_trans this (le_max_right _ _)

/-- **Support lower bound, smaller side.**  *Both* sides of a near miss use at least
`⌊(N+1)/2⌋ = (N+1)/2` distinct values. -/
theorem card_support_min_lower_bound {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    (N + 1) / 2 ≤ min (support s).card (support t).card := by
  have key : ∀ a b : Multiset ℕ,
      (support (evenPart N) ⊆ support a ∧ support (oddPart N) ⊆ support b) →
      (N + 1) / 2 ≤ min (support a).card (support b).card := by
    intro a b ⟨h1, h2⟩
    have ha := Finset.card_le_card h1
    have hb := Finset.card_le_card h2
    rw [card_support_evenPart] at ha
    rw [card_support_oddPart] at hb
    have : (N + 1) / 2 ≤ N / 2 + 1 := by omega
    exact le_min (le_trans this ha) hb
  rcases near_miss_support_contains_halves hs ht h hne with hc | hc
  · exact key s t hc
  · have := key t s ⟨hc.2, hc.1⟩
    rwa [min_comm] at this

/-- **The binomial pair attains both support bounds.**  Hence the answer to the open
successor question of cycle 3 is affirmative: the minimal support size of a near miss at
level `N` is `⌈(N+1)/2⌉` on the larger side and `⌊(N+1)/2⌋` on the smaller side, both
realised by `evenPart N` / `oddPart N`. -/
theorem binomial_pair_minimises_support (N : ℕ) :
    max (support (evenPart N)).card (support (oddPart N)).card = N / 2 + 1 ∧
    min (support (evenPart N)).card (support (oddPart N)).card = (N + 1) / 2 ∧
    (support (evenPart N)).card + (support (oddPart N)).card = N + 1 := by
  rw [card_support_evenPart, card_support_oddPart]
  refine ⟨?_, ?_, ?_⟩ <;> omega

/-! ### Rigidity at the extremes -/

/-- **Disjoint supports force the binomial pair (up to scaling).**  A near miss whose two
sides use disjoint sets of values has zero padding, hence is `lam • (evenPart N, oddPart N)`
for some `lam ≥ 1`. -/
theorem disjoint_support_near_miss {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t)
    (hdisj : Disjoint (support s) (support t)) :
    ∃ lam : ℕ, 1 ≤ lam ∧
      ((s = lam • evenPart N ∧ t = lam • oddPart N) ∨
       (s = lam • oddPart N ∧ t = lam • evenPart N)) := by
  classical
  obtain ⟨lam, u, hlam, hu, hcase⟩ := near_miss_structure hs ht h hne
  -- the padding is contained in both supports, hence empty
  have key : ∀ a b : Multiset ℕ, s = lam • a + u → t = lam • b + u → u = 0 := by
    intro a b h1 h2
    by_contra hune
    obtain ⟨m, hm⟩ := Multiset.exists_mem_of_ne_zero hune
    have hms : m ∈ support s := by
      rw [mem_support, h1, Multiset.count_add]
      have : 0 < u.count m := Multiset.count_pos.mpr hm
      omega
    have hmt : m ∈ support t := by
      rw [mem_support, h2, Multiset.count_add]
      have : 0 < u.count m := Multiset.count_pos.mpr hm
      omega
    exact (Finset.disjoint_left.mp hdisj hms) hmt
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · have hu0 := key _ _ h1 h2
    exact ⟨lam, hlam, Or.inl ⟨by rw [h1, hu0, add_zero], by rw [h2, hu0, add_zero]⟩⟩
  · have hu0 := key _ _ h1 h2
    exact ⟨lam, hlam, Or.inr ⟨by rw [h1, hu0, add_zero], by rw [h2, hu0, add_zero]⟩⟩

/-- Equality in the total-support bound characterises the scaled binomial pairs. -/
theorem support_partition_iff_disjoint {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    (support s).card + (support t).card = N + 1 ↔ Disjoint (support s) (support t) := by
  classical
  have hu := support_union_eq_range hs ht h hne
  have hcard : (support s ∪ support t).card = N + 1 := by rw [hu, Finset.card_range]
  constructor
  · intro heq
    have hi := Finset.card_union_add_card_inter (support s) (support t)
    rw [hcard, heq] at hi
    have hz : (support s ∩ support t).card = 0 := by omega
    exact Finset.disjoint_iff_inter_eq_empty.mpr (Finset.card_eq_zero.mp hz)
  · intro hdisj
    rw [← Finset.card_union_of_disjoint hdisj, hcard]

/-- **Full rigidity from minimal cardinality alone.**  A near miss at level `N ≥ 1` of
minimal cardinality `2^(N-1)` *is* the binomial pair (up to swapping the two sides).  No
disjointness hypothesis is needed: minimal size already forces both the multiplier and the
padding of `near_miss_structure` to be trivial. -/
theorem minimal_card_near_miss_eq_binomial {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) (hN : 1 ≤ N)
    (hcard : 2 * Multiset.card s = 2 ^ N) :
    (s = evenPart N ∧ t = oddPart N) ∨ (s = oddPart N ∧ t = evenPart N) := by
  obtain ⟨lam, u, hlam, -, hcase⟩ := near_miss_structure hs ht h hne
  have hcards : Multiset.card (evenPart N) = Multiset.card (oddPart N) := by
    have h0 : powerSum (evenPart N) 0 = powerSum (oddPart N) 0 :=
      powerSum_evenPart_eq_oddPart N (by omega)
    rw [powerSum_index_zero, powerSum_index_zero] at h0
    exact_mod_cast h0
  have hev : 2 * Multiset.card (evenPart N) = 2 ^ N := card_evenPart N hN
  have hpos : 0 < Multiset.card (evenPart N) := by
    have : (0 : ℕ) < 2 ^ N := pow_pos (by norm_num) N
    omega
  -- in either case the cardinality equation reads `lam * |evenPart N| + |u| = |evenPart N|`
  have key : lam = 1 ∧ u = 0 := by
    have hc : lam * Multiset.card (evenPart N) + Multiset.card u
        = Multiset.card (evenPart N) := by
      rcases hcase with ⟨h1, -⟩ | ⟨h1, -⟩
      · rw [h1, Multiset.card_add, Multiset.card_nsmul] at hcard; omega
      · rw [h1, Multiset.card_add, Multiset.card_nsmul, ← hcards] at hcard; omega
    have hge : Multiset.card (evenPart N) ≤ lam * Multiset.card (evenPart N) :=
      Nat.le_mul_of_pos_left _ hlam
    have hu0 : Multiset.card u = 0 := by
      set A := lam * Multiset.card (evenPart N) with hA
      omega
    refine ⟨?_, Multiset.card_eq_zero.mp hu0⟩
    have : lam * Multiset.card (evenPart N) = 1 * Multiset.card (evenPart N) := by omega
    exact Nat.eq_of_mul_eq_mul_right hpos this
  obtain ⟨hlam1, hu0⟩ := key
  subst hlam1; subst hu0
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨by rw [h1, one_nsmul, add_zero], by rw [h2, one_nsmul, add_zero]⟩
  · exact Or.inr ⟨by rw [h1, one_nsmul, add_zero], by rw [h2, one_nsmul, add_zero]⟩

/-- **Minimal support forces a scaled binomial pair.**  If a near miss achieves the total
support bound `|supp s| + |supp t| = N + 1` — equivalently, if both sides achieve the
individual bounds `⌈(N+1)/2⌉` and `⌊(N+1)/2⌋` — then it is `lam • (evenPart N, oddPart N)`
for some `lam ≥ 1`. -/
theorem minimal_support_near_miss {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t)
    (hsum : (support s).card + (support t).card = N + 1) :
    ∃ lam : ℕ, 1 ≤ lam ∧
      ((s = lam • evenPart N ∧ t = lam • oddPart N) ∨
       (s = lam • oddPart N ∧ t = lam • evenPart N)) :=
  disjoint_support_near_miss hs ht h hne
    ((support_partition_iff_disjoint hs ht h hne).mp hsum)

end PowerSumSharpness