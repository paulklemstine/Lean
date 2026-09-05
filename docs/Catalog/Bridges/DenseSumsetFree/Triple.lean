import Mathlib
import Bridges.DenseSumsetFree.Basic
import Bridges.DenseSumsetFree.Extraction
import Bridges.DenseSumsetFree.Counting
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Three summands: beating the two-fold threshold

`MultiFold.lean` derives `t`-fold avoidance from two-fold avoidance by grouping
summands; that costs nothing but also gains nothing — the threshold stays
`C (log n)³`.  This file redoes the whole argument *natively* for three summands
and gets a genuinely smaller threshold, `C (log n)^{5/2}`.

The mechanism is the trade-off between the two ingredients:

* the union bound over triples of `l`-subsets of `[n]` costs `n^{3l}`;
* a triple with all `l³` sums distinct has `|A + B + C| = l³`,

so the first moment closes as soon as `3 l log n < l³ log(q/p)`, i.e. for
`l ≈ √(3 log n / log(q/p))` — a *square root* of a logarithm, rather than the
logarithm itself needed in the two-summand case.  The greedy extraction of a
distinct-sums triple needs the parts to have `≳ l⁵` elements, so the threshold is
`l⁵ ≈ (3 log n / log(q/p))^{5/2}`.

## Main results

* `AvoidsSumsets3` — avoidance of three-fold sumsets;
* `exists_distinctSums_triple` — greedy extraction of a distinct-sums triple of
  `l`-sets from sets of size `≥ l⁵ + l`;
* `avoidsSumsets3_of_no_distinctSums` — the reduction to distinct-sums triples;
* `exists_avoidsSumsets3_set` — the quantitative counting theorem for triples;
* `exists_dense_set_avoiding_triple_sumsets` — the asymptotic theorem with the
  threshold `c (log n)² √(log n) = c (log n)^{5/2}`;
* `triple_threshold_le_log_cubed` — the comparison showing this is an improvement
  on the `(log n)³` threshold of `MultiFold.lean`;
* `avoidsSumsets3_of_avoidsSumsets` — the (weaker) grouping route, for comparison;
* `triple_counting_hypotheses_satisfiable` — a machine-checked numerical instance;
* `exists_dense_set_avoiding_triple_sumsets_min` — the same theorem phrased with
  `min(|A|, |B|, |C|)`.
-/
-- MISSING MODULE (not present in this repository): import Bridges.DenseSumsetFree.Main
open Finset Pointwise

namespace DenseSumsetFree

/-- `S` avoids `k`-fold triple sumsets: no `A + B + C` with `|A|, |B|, |C| ≥ k`
is contained in `S`. -/
def AvoidsSumsets3 (S : Finset ℕ) (k : ℕ) : Prop :=
  ∀ A B C : Finset ℕ, k ≤ A.card → k ≤ B.card → k ≤ C.card → ¬ A + B + C ⊆ S

/-- If the pairs `(A, B)` and `(A + B, C)` both have distinct sums, then all
`|A| · |B| · |C|` triple sums are distinct. -/
lemma card_add3_of_distinctSums {A B C : Finset ℕ} (h1 : DistinctSums A B)
    (h2 : DistinctSums (A + B) C) :
    (A + B + C).card = A.card * B.card * C.card := by
  rw [card_add_of_distinctSums h2, card_add_of_distinctSums h1]

/-- **Greedy extraction of a distinct-sums triple.**  If `|A| ≥ l`,
`|B| ≥ l³ + l` and `|C| ≥ l⁵ + l`, then there are `l`-element subsets
`A' ⊆ A`, `B' ⊆ B`, `C' ⊆ C` all of whose `l³` triple sums are distinct. -/
theorem exists_distinctSums_triple (A B C : Finset ℕ) (l : ℕ)
    (hA : l ≤ A.card) (hB : l ^ 3 + l ≤ B.card) (hC : l ^ 5 + l ≤ C.card) :
    ∃ A' ⊆ A, ∃ B' ⊆ B, ∃ C' ⊆ C, A'.card = l ∧ B'.card = l ∧ C'.card = l ∧
      DistinctSums A' B' ∧ DistinctSums (A' + B') C' := by
  obtain ⟨A', hA'sub, hA'card⟩ := Finset.exists_subset_card_eq hA
  obtain ⟨B', hB'sub, hB'card, hdistAB⟩ := exists_distinctSums_snd A' B l hA'card hB
  have hDcard : (A' + B').card = l * l := by
    rw [card_add_of_distinctSums hdistAB, hA'card, hB'card]
  obtain ⟨C', hC'sub, hC'card, hdistDC⟩ :=
    exists_distinctSums_snd_of_card (A' + B') C (l * l) l hDcard
      (by
        have : l * l * (l * l) * l + l = l ^ 5 + l := by ring
        omega)
  exact ⟨A', hA'sub, B', hB'sub, C', hC'sub, hA'card, hB'card, hC'card, hdistAB, hdistDC⟩

/-- **Reduction to distinct-sums triples.**  If `S` contains no triple sumset
`A' + B' + C'` coming from a distinct-sums triple of `l`-element sets, then `S`
avoids all three-fold `k`-sumsets with `k = l⁵ + l`. -/
theorem avoidsSumsets3_of_no_distinctSums {S : Finset ℕ} {l : ℕ}
    (h : ∀ A' B' C' : Finset ℕ, A'.card = l → B'.card = l → C'.card = l →
      DistinctSums A' B' → DistinctSums (A' + B') C' → ¬ A' + B' + C' ⊆ S) :
    AvoidsSumsets3 S (l ^ 5 + l) := by
  intro A B C hA hB hC hsub
  have hmono3 : l ^ 3 + l ≤ l ^ 5 + l := by
    rcases Nat.eq_zero_or_pos l with rfl | hl
    · simp
    · exact Nat.add_le_add_right (Nat.pow_le_pow_right hl (by norm_num)) l
  have hmono1 : l ≤ l ^ 5 + l := Nat.le_add_left _ _
  obtain ⟨A', hA'sub, B', hB'sub, C', hC'sub, hA'card, hB'card, hC'card, h1, h2⟩ :=
    exists_distinctSums_triple A B C l (le_trans hmono1 hA) (le_trans hmono3 hB) hC
  refine h A' B' C' hA'card hB'card hC'card h1 h2 ?_
  exact Finset.Subset.trans (add_subset_add (add_subset_add hA'sub hB'sub) hC'sub) hsub

/-- **Existence of a dense set containing no distinct-sums triple sumset.**
If `l ≥ 1`, `l³ ≤ m ≤ n`, the density is bounded by `p/q` (`q·m ≤ p·n`) and the
union-bound inequality `n^{3l} · p^{l³} < q^{l³}` holds, then some `m`-element
`S ⊆ [n]` contains no sumset `A' + B' + C'` of a distinct-sums triple of
`l`-element sets. -/
theorem exists_distinctSums3_free_set {n m l p q : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l ^ 3 ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (3 * l) * p ^ (l ^ 3) < q ^ (l ^ 3)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧
      ∀ A' B' C' : Finset ℕ, A'.card = l → B'.card = l → C'.card = l →
        DistinctSums A' B' → DistinctSums (A' + B') C' → ¬ A' + B' + C' ⊆ S := by
  classical
  set s := l ^ 3 with hs
  set P : Finset (Finset ℕ) := (Finset.range n).powersetCard l with hP
  set F : Finset (Finset ℕ) :=
    ((P ×ˢ (P ×ˢ P)).image
      (fun r : Finset ℕ × Finset ℕ × Finset ℕ => r.1 + r.2.1 + r.2.2)).filter
        (fun T => T.card = s) with hF
  have hFle : F.card ≤ n ^ (3 * l) := by
    refine le_trans (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    refine le_trans (Finset.card_image_le) ?_
    rw [Finset.card_product, Finset.card_product, hP, Finset.card_powersetCard,
      Finset.card_range]
    calc n.choose l * (n.choose l * n.choose l)
        ≤ n ^ l * (n ^ l * n ^ l) :=
          Nat.mul_le_mul (Nat.choose_le_pow n l)
            (Nat.mul_le_mul (Nat.choose_le_pow n l) (Nat.choose_le_pow n l))
      _ = n ^ (3 * l) := by rw [← pow_add, ← pow_add]; ring_nf
  have hbound : F.card * (n - s).choose (m - s) < n.choose m :=
    lt_of_le_of_lt (Nat.mul_le_mul_right _ hFle)
      (mul_choose_sdiff_lt_choose hn hsm hm hdens hkey)
  obtain ⟨S, hSsub, hScard, hSgood⟩ :=
    exists_set_avoiding_family F (fun T hT => (Finset.mem_filter.1 hT).2) hsm hbound
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A' B' C' hA' hB' hC' h1 h2 hsub
  have hA'ne : A'.Nonempty := Finset.card_pos.1 (by omega)
  have hB'ne : B'.Nonempty := Finset.card_pos.1 (by omega)
  have hC'ne : C'.Nonempty := Finset.card_pos.1 (by omega)
  have hABne : (A' + B').Nonempty := hA'ne.add hB'ne
  have hsubrange : A' + B' + C' ⊆ Finset.range n := Finset.Subset.trans hsub hSsub
  have hABsub : A' + B' ⊆ Finset.range n :=
    subset_range_of_add_subset_range hC'ne hsubrange
  have hC'sub : C' ⊆ Finset.range n :=
    snd_subset_range_of_add_subset_range hABne hsubrange
  have hA'sub : A' ⊆ Finset.range n :=
    subset_range_of_add_subset_range hB'ne hABsub
  have hB'sub : B' ⊆ Finset.range n :=
    snd_subset_range_of_add_subset_range hA'ne hABsub
  refine hSgood (A' + B' + C') ?_ hsub
  rw [hF, Finset.mem_filter]
  refine ⟨Finset.mem_image.2 ⟨(A', B', C'), ?_, rfl⟩, ?_⟩
  · rw [Finset.mem_product, Finset.mem_product, hP, Finset.mem_powersetCard,
      Finset.mem_powersetCard, Finset.mem_powersetCard]
    exact ⟨⟨hA'sub, hA'⟩, ⟨hB'sub, hB'⟩, ⟨hC'sub, hC'⟩⟩
  · rw [card_add3_of_distinctSums h1 h2, hA', hB', hC', hs]
    ring

/-- **Dense triple-sumset-avoiding sets: the quantitative core.**  Under the same
hypotheses there is an `m`-element `S ⊆ [n]` avoiding *all* three-fold
`k`-sumsets with `k = l⁵ + l`. -/
theorem exists_avoidsSumsets3_set {n m l p q : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l ^ 3 ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (3 * l) * p ^ (l ^ 3) < q ^ (l ^ 3)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧ AvoidsSumsets3 S (l ^ 5 + l) := by
  obtain ⟨S, hSsub, hScard, hSfree⟩ :=
    exists_distinctSums3_free_set hl hn hsm hm hdens hkey
  exact ⟨S, hSsub, hScard, avoidsSumsets3_of_no_distinctSums hSfree⟩

/-- The union-bound inequality for triples, in the form produced by the choice
`l ≈ √(3 log n / log(q/p))`. -/
lemma key_pow_lt3 {n l p q : ℕ} (hn : 1 ≤ n) (hp : 1 ≤ p) (hpq : p < q) (hl : 1 ≤ l)
    (hlog : 3 * Real.log n < (l : ℝ) * l * (Real.log q - Real.log p)) :
    n ^ (3 * l) * p ^ (l ^ 3) < q ^ (l ^ 3) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hp0 : (0:ℝ) < p := by exact_mod_cast hp
  have hq0 : (0:ℝ) < q := by exact_mod_cast lt_of_lt_of_le hp hpq.le
  have hl0 : (0:ℝ) < l := by exact_mod_cast hl
  have hmain : ((n : ℝ) ^ (3 * l) * (p : ℝ) ^ (l ^ 3)) < (q : ℝ) ^ (l ^ 3) := by
    have hpos : (0:ℝ) < (n : ℝ) ^ (3 * l) * (p : ℝ) ^ (l ^ 3) :=
      mul_pos (pow_pos hn0 _) (pow_pos hp0 _)
    have hposq : (0:ℝ) < (q : ℝ) ^ (l ^ 3) := pow_pos hq0 _
    rw [← Real.log_lt_log_iff hpos hposq, Real.log_mul (by positivity) (by positivity),
      Real.log_pow, Real.log_pow, Real.log_pow]
    have hstep := mul_lt_mul_of_pos_left hlog hl0
    push_cast
    nlinarith
  exact_mod_cast hmain

/-- The `(log n)^{5/2}` threshold is eventually below any `(log n)³` threshold:
the three-summand theorem below is a genuine improvement on the two-summand
theorem applied by grouping. -/
lemma triple_threshold_le_log_cubed {c C x : ℝ} (hc : 0 < c) (hC : 0 < C)
    (hx : 1 ≤ x) (hxc : (c / C) ^ 2 ≤ x) :
    c * x ^ 2 * Real.sqrt x ≤ C * x ^ 3 := by
  have hx0 : (0:ℝ) ≤ x := by linarith
  have hcC : 0 ≤ c / C := le_of_lt (div_pos hc hC)
  have h1 : c / C ≤ Real.sqrt x := by
    calc c / C = Real.sqrt ((c / C) ^ 2) := (Real.sqrt_sq hcC).symm
      _ ≤ Real.sqrt x := Real.sqrt_le_sqrt hxc
  have hsq : Real.sqrt x * Real.sqrt x = x := Real.mul_self_sqrt hx0
  have hsnn : 0 ≤ Real.sqrt x := Real.sqrt_nonneg x
  have h2 : c * Real.sqrt x ≤ C * x := by
    have := mul_le_mul_of_nonneg_right ((div_le_iff₀ hC).1 h1) hsnn
    nlinarith
  nlinarith [sq_nonneg x, mul_le_mul_of_nonneg_left h2 (sq_nonneg x)]

set_option maxHeartbeats 400000 in
/-- **Main theorem for three summands.**  For every density `0 < δ < 1` there is
a constant `c > 0` such that for all sufficiently large `n` there is a set
`S ⊆ {0, …, n-1}` with `|S| ≥ δ n` such that for all finite `A, B, C ⊆ ℕ` with
`|A|, |B|, |C| ≥ c (log n)^{5/2}` the sumset `A + B + C` is **not** contained in
`S`.  (The threshold is written `c (log n)² √(log n)`.) -/
theorem exists_dense_set_avoiding_triple_sumsets (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    ∃ c : ℝ, 0 < c ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ A B C : Finset ℕ,
          c * (Real.log n) ^ 2 * Real.sqrt (Real.log n) ≤ A.card →
          c * (Real.log n) ^ 2 * Real.sqrt (Real.log n) ≤ B.card →
          c * (Real.log n) ^ 2 * Real.sqrt (Real.log n) ≤ C.card →
          ¬ A + B + C ⊆ S := by
  classical
  have hδ1' : (0:ℝ) < 1 - δ := by linarith
  -- a rational density bound `δ < p/q < 1`
  obtain ⟨q, hq2, hqR⟩ : ∃ q : ℕ, 2 ≤ q ∧ 1 / (1 - δ) < (q : ℝ) := by
    refine ⟨⌈1 / (1 - δ)⌉₊ + 1, ?_, ?_⟩
    · have h1 : (1:ℝ) ≤ 1 / (1 - δ) := by rw [le_div_iff₀ hδ1']; linarith
      have : 1 ≤ ⌈1 / (1 - δ)⌉₊ := Nat.one_le_ceil_iff.2 (by linarith)
      omega
    · have := Nat.le_ceil (1 / (1 - δ))
      push_cast
      linarith
  obtain ⟨p, hp1, hpq, hpR⟩ : ∃ p : ℕ, 1 ≤ p ∧ p < q ∧ (p : ℝ) = (q : ℝ) - 1 := by
    refine ⟨q - 1, by omega, by omega, ?_⟩
    push_cast [Nat.cast_sub (by omega : 1 ≤ q)]
    ring
  obtain ⟨e, he0, heq⟩ : ∃ e : ℝ, 0 < e ∧ e = (p : ℝ) - q * δ := by
    refine ⟨(p : ℝ) - q * δ, ?_, rfl⟩
    have h1 : 1 < (q : ℝ) * (1 - δ) := by rw [div_lt_iff₀ hδ1'] at hqR; linarith
    rw [hpR]; nlinarith
  obtain ⟨L, hL0, hLeq⟩ : ∃ L : ℝ, 0 < L ∧ L = Real.log q - Real.log p := by
    refine ⟨Real.log q - Real.log p, ?_, rfl⟩
    have : Real.log p < Real.log q :=
      Real.log_lt_log (by exact_mod_cast hp1) (by exact_mod_cast hpq)
    linarith
  obtain ⟨K, hK1, hKeq⟩ : ∃ K : ℝ, 1 ≤ K ∧ K = Real.sqrt (3 / L) + 2 := by
    refine ⟨Real.sqrt (3 / L) + 2, ?_, rfl⟩
    have := Real.sqrt_nonneg (3 / L)
    linarith
  have hK0 : (0:ℝ) < K := by linarith
  refine ⟨2 * K ^ 5, by positivity, 3 + ⌈(q : ℝ) / e⌉₊ + ⌈1 / (1 - δ)⌉₊ +
    ⌈(16 * K ^ 3 / δ) ^ 2⌉₊, ?_⟩
  intro n hn
  have hn3 : 3 ≤ n := by omega
  have hnR : (3:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn3
  have hn0 : (0:ℝ) < n := by linarith
  have hlog1 : 1 ≤ Real.log n := by
    have h3 : (1:ℝ) < Real.log 3 := by
      rw [Real.lt_log_iff_exp_lt (by norm_num)]
      linarith [Real.exp_one_lt_d9]
    have : Real.log 3 ≤ Real.log n := Real.log_le_log (by norm_num) hnR
    linarith
  -- `w = √(log n)`
  set w : ℝ := Real.sqrt (Real.log n) with hw
  have hw1 : 1 ≤ w := by
    rw [hw, show (1:ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
    exact Real.sqrt_le_sqrt hlog1
  have hw0 : (0:ℝ) < w := by linarith
  have hwsq : w * w = Real.log n := Real.mul_self_sqrt (by linarith)
  -- the size of `S`
  obtain ⟨m, hmge, hmlt⟩ : ∃ m : ℕ, δ * n ≤ (m : ℝ) ∧ (m : ℝ) < δ * n + 1 :=
    ⟨⌈δ * n⌉₊, Nat.le_ceil _, Nat.ceil_lt_add_one (by positivity)⟩
  have hn1 : (1:ℝ) / (1 - δ) ≤ (n : ℝ) := by
    have h2 : (⌈1 / (1 - δ)⌉₊ : ℕ) ≤ n := by omega
    have h3 : ((⌈1 / (1 - δ)⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast h2
    exact le_trans (Nat.le_ceil _) h3
  have hmn : m ≤ n := by
    have h1 : (1:ℝ) ≤ (1 - δ) * n := by rw [div_le_iff₀ hδ1'] at hn1; linarith
    have : (m : ℝ) ≤ (n : ℝ) := by linarith
    exact_mod_cast this
  have hdens : q * m ≤ p * n := by
    have hnq : ((q : ℝ)) / e ≤ (n : ℝ) := by
      have h2 : (⌈(q : ℝ) / e⌉₊ : ℕ) ≤ n := by omega
      have h3 : ((⌈(q : ℝ) / e⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast h2
      exact le_trans (Nat.le_ceil _) h3
    have hqe : (q : ℝ) ≤ n * e := by rwa [div_le_iff₀ he0] at hnq
    have hcast : (q : ℝ) * m ≤ (p : ℝ) * n := by
      have h2 : (q : ℝ) * m ≤ (q : ℝ) * (δ * n + 1) :=
        mul_le_mul_of_nonneg_left hmlt.le (by positivity)
      nlinarith
    exact_mod_cast hcast
  -- the scale `l ≈ √(3 log n / L)`
  set t : ℝ := Real.sqrt (3 * Real.log n / L) with ht
  have ht0 : 0 ≤ t := Real.sqrt_nonneg _
  have htsq : t * t = 3 * Real.log n / L := Real.mul_self_sqrt (by positivity)
  have htw : t = Real.sqrt (3 / L) * w := by
    rw [ht, hw, show 3 * Real.log n / L = (3 / L) * Real.log n by ring,
      Real.sqrt_mul (by positivity)]
  obtain ⟨l, hl1, hlR, hlogl⟩ :
      ∃ l : ℕ, 1 ≤ l ∧ (l : ℝ) ≤ K * w ∧ 3 * Real.log n < (l : ℝ) * l * L := by
    refine ⟨⌈t⌉₊ + 1, by omega, ?_, ?_⟩
    · have h1 : ((⌈t⌉₊ : ℕ) : ℝ) < t + 1 := Nat.ceil_lt_add_one ht0
      have h2 : ((⌈t⌉₊ + 1 : ℕ) : ℝ) < t + 2 := by push_cast; linarith
      have h3 : t + 2 ≤ K * w := by
        rw [htw, hKeq]
        nlinarith [Real.sqrt_nonneg (3 / L)]
      linarith
    · have h1 : t ≤ ((⌈t⌉₊ : ℕ) : ℝ) := Nat.le_ceil _
      have h2 : t < ((⌈t⌉₊ + 1 : ℕ) : ℝ) := by push_cast; linarith
      set lr : ℝ := ((⌈t⌉₊ + 1 : ℕ) : ℝ) with hlr
      have hlr0 : 0 ≤ lr := by positivity
      have hsq : t * t < lr * lr := by nlinarith
      rw [htsq] at hsq
      have : 3 * Real.log n / L * L < lr * lr * L := by
        exact mul_lt_mul_of_pos_right hsq hL0
      rw [div_mul_cancel₀ _ (ne_of_gt hL0)] at this
      exact this
  -- `l³ ≤ m`
  have hlcube : l ^ 3 ≤ m := by
    have hlnn : (0:ℝ) ≤ (l : ℝ) := Nat.cast_nonneg l
    have hcube : ((l : ℝ)) ^ 3 ≤ K ^ 3 * w ^ 3 := by
      have h1 : ((l : ℝ)) ^ 3 ≤ (K * w) ^ 3 := pow_le_pow_left₀ hlnn hlR 3
      calc ((l : ℝ)) ^ 3 ≤ (K * w) ^ 3 := h1
        _ = K ^ 3 * w ^ 3 := by ring
    have hw3 : w ^ 3 ≤ (Real.log n) ^ 2 :=
      calc w ^ 3 ≤ w ^ 4 := pow_le_pow_right₀ hw1 (by norm_num)
        _ = (w * w) ^ 2 := by ring
        _ = (Real.log n) ^ 2 := by rw [hwsq]
    have hsqrt : (Real.log n) ^ 2 ≤ 16 * Real.sqrt n := log_sq_le_sqrt (by linarith)
    have hbig : (16 * K ^ 3 / δ) ^ 2 ≤ (n : ℝ) := by
      have h2 : (⌈(16 * K ^ 3 / δ) ^ 2⌉₊ : ℕ) ≤ n := by omega
      have h3 : ((⌈(16 * K ^ 3 / δ) ^ 2⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast h2
      exact le_trans (Nat.le_ceil _) h3
    have hsn : 16 * K ^ 3 / δ ≤ Real.sqrt n := by
      rw [show (16 * K ^ 3 / δ) = Real.sqrt ((16 * K ^ 3 / δ) ^ 2) from
        (Real.sqrt_sq (by positivity)).symm]
      exact Real.sqrt_le_sqrt hbig
    have hsqrtn : 0 ≤ Real.sqrt n := Real.sqrt_nonneg _
    have hsqrt_sq : Real.sqrt n * Real.sqrt n = (n : ℝ) := Real.mul_self_sqrt (by positivity)
    have h16 : 16 * K ^ 3 ≤ δ * Real.sqrt n := by
      rw [div_le_iff₀ hδ0] at hsn; linarith
    have hfin : ((l : ℝ)) ^ 3 ≤ δ * n :=
      calc ((l : ℝ)) ^ 3 ≤ K ^ 3 * w ^ 3 := hcube
        _ ≤ K ^ 3 * (16 * Real.sqrt n) :=
            mul_le_mul_of_nonneg_left (le_trans hw3 hsqrt) (by positivity)
        _ = (16 * K ^ 3) * Real.sqrt n := by ring
        _ ≤ (δ * Real.sqrt n) * Real.sqrt n := mul_le_mul_of_nonneg_right h16 hsqrtn
        _ = δ * n := by rw [mul_assoc, hsqrt_sq]
    have hcast : ((l ^ 3 : ℕ) : ℝ) ≤ (m : ℝ) := by
      have hll : ((l ^ 3 : ℕ) : ℝ) = ((l : ℝ)) ^ 3 := by push_cast; ring
      rw [hll]; linarith
    exact_mod_cast hcast
  -- the union-bound inequality
  have hkey : n ^ (3 * l) * p ^ (l ^ 3) < q ^ (l ^ 3) :=
    key_pow_lt3 (by omega) hp1 hpq hl1 (by rw [← hLeq]; exact hlogl)
  obtain ⟨S, hSsub, hScard, hSavoid⟩ :=
    exists_avoidsSumsets3_set (n := n) (m := m) (l := l) (p := p) (q := q)
      hl1 (by omega) hlcube hmn hdens hkey
  refine ⟨S, hSsub, by rw [hScard]; exact hmge, ?_⟩
  intro A B C hA hB hC
  have hthr : ((l ^ 5 + l : ℕ) : ℝ) ≤ 2 * K ^ 5 * (Real.log n) ^ 2 * w := by
    have hl0 : (1:ℝ) ≤ (l : ℝ) := by exact_mod_cast hl1
    have hlnn : (0:ℝ) ≤ (l : ℝ) := by linarith
    have h1 : ((l : ℝ)) ^ 5 ≤ (K * w) ^ 5 := pow_le_pow_left₀ hlnn hlR 5
    have h2 : (l : ℝ) ≤ ((l : ℝ)) ^ 5 := by
      simpa using pow_le_pow_right₀ hl0 (by norm_num : 1 ≤ 5)
    have h3 : (K * w) ^ 5 = K ^ 5 * ((w * w) ^ 2 * w) := by ring
    have h4 : (K * w) ^ 5 = K ^ 5 * (Real.log n) ^ 2 * w := by
      rw [h3, hwsq]; ring
    have hcast : ((l ^ 5 + l : ℕ) : ℝ) = ((l : ℝ)) ^ 5 + (l : ℝ) := by push_cast; ring
    rw [hcast]
    have hpos : 0 ≤ K ^ 5 * (Real.log n) ^ 2 * w := by positivity
    linarith [h1, h2, h4]
  have hAcard : l ^ 5 + l ≤ A.card := by
    have : ((l ^ 5 + l : ℕ) : ℝ) ≤ (A.card : ℝ) := le_trans hthr hA
    exact_mod_cast this
  have hBcard : l ^ 5 + l ≤ B.card := by
    have : ((l ^ 5 + l : ℕ) : ℝ) ≤ (B.card : ℝ) := le_trans hthr hB
    exact_mod_cast this
  have hCcard : l ^ 5 + l ≤ C.card := by
    have : ((l ^ 5 + l : ℕ) : ℝ) ≤ (C.card : ℝ) := le_trans hthr hC
    exact_mod_cast this
  exact hSavoid A B C hAcard hBcard hCcard

/-- Two-fold avoidance trivially implies three-fold avoidance at the *same*
threshold (this is the grouping argument of `MultiFold.lean`, specialised to
three summands).  The point of `exists_dense_set_avoiding_triple_sumsets` is that
for three summands one can do better than the threshold this route provides. -/
theorem avoidsSumsets3_of_avoidsSumsets {S : Finset ℕ} {k : ℕ} (hk : 1 ≤ k)
    (h : AvoidsSumsets S k) : AvoidsSumsets3 S k := by
  intro A B C hA hB hC hsub
  have hCne : C.Nonempty := Finset.card_pos.1 (by omega)
  have hBC : k ≤ (B + C).card := le_trans hB (Finset.card_le_card_add_right hCne)
  exact h A (B + C) hA hBC (by rwa [add_assoc] at hsub)

/-- A machine-checked instance of the three-summand counting hypotheses:
with `n = 1024`, `m = 512` (density `1/2`) and `l = 6` one has `l³ = 216 ≤ 512`
and `n^{3l} = 2^{180} < 2^{216} = 2^{l³}`, so some `512`-element subset of
`[1024]` contains no three-fold sumset `A + B + C` with all parts of size at
least `6⁵ + 6 = 7782`.  (The two-summand instance of `Sharpness.lean` gives the
weaker threshold `9282` on the same set size.) -/
theorem triple_counting_hypotheses_satisfiable :
    ∃ S ⊆ Finset.range 1024, S.card = 512 ∧ AvoidsSumsets3 S (6 ^ 5 + 6) := by
  refine exists_avoidsSumsets3_set (n := 1024) (m := 512) (l := 6) (p := 1) (q := 2)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) ?_
  have h1 : (1024 : ℕ) ^ (3 * 6) * 1 ^ (6 ^ 3) = 2 ^ 180 := by
    rw [one_pow, mul_one, show (1024 : ℕ) = 2 ^ 10 from by norm_num, ← pow_mul]
  rw [h1, show (6 : ℕ) ^ 3 = 216 from by norm_num]
  exact Nat.pow_lt_pow_right (by norm_num) (by norm_num)

/-- **The mission statement for three summands, in `min` form.**  For every fixed
`0 < δ < 1` there is `c > 0` such that for all sufficiently large `n` there is
`S ⊆ [n]` with `|S| ≥ δ n` and: for all finite `A, B, C ⊆ ℕ` with
`min(|A|, |B|, |C|) ≥ c (log n)^{5/2}`, the sumset `A + B + C` is not contained
in `S`. -/
theorem exists_dense_set_avoiding_triple_sumsets_min (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    ∃ c : ℝ, 0 < c ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ A B C : Finset ℕ,
          c * (Real.log n) ^ 2 * Real.sqrt (Real.log n)
              ≤ (min (min A.card B.card) C.card : ℕ) →
          ¬ A + B + C ⊆ S := by
  obtain ⟨c, hc0, N, hN⟩ := exists_dense_set_avoiding_triple_sumsets δ hδ0 hδ1
  refine ⟨c, hc0, N, fun n hn => ?_⟩
  obtain ⟨S, hSsub, hScard, hSavoid⟩ := hN n hn
  refine ⟨S, hSsub, hScard, fun A B C hmin => hSavoid A B C ?_ ?_ ?_⟩
  · have h : min (min A.card B.card) C.card ≤ A.card :=
      le_trans (min_le_left _ _) (min_le_left _ _)
    exact le_trans hmin (by exact_mod_cast h)
  · have h : min (min A.card B.card) C.card ≤ B.card :=
      le_trans (min_le_left _ _) (min_le_right _ _)
    exact le_trans hmin (by exact_mod_cast h)
  · have h : min (min A.card B.card) C.card ≤ C.card := min_le_right _ _
    exact le_trans hmin (by exact_mod_cast h)

end DenseSumsetFree