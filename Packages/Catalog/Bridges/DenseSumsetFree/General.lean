/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# An arbitrary number of summands, done natively

`MultiFold.lean` obtains `t`-fold avoidance from the two-fold theorem by
grouping; the threshold stays `C (log n)³` for every `t`.  `Triple.lean` redoes
the argument natively for `t = 3` and improves the threshold to `C (log n)^{5/2}`.
This file carries out the argument for **every** `t ≥ 2` at once.

The trade-off is the same as for three summands:

* the union bound over `t`-tuples of `l`-subsets of `[n]` costs `n^{t l}`;
* a `t`-tuple all of whose `l^t` sums are distinct contributes a pattern of size
  exactly `l^t`,

so the first moment closes as soon as `t · l · log n < l^t · log(q/p)`, i.e. for
`l ≈ (t log n / log(q/p))^{1/(t-1)}`.  Greedy extraction of a distinct-sums
`t`-tuple needs parts of size `≳ l^{2t-1}`, so the threshold becomes

  `(t log n / log(q/p))^{(2t-1)/(t-1)}`,

whose exponent `(2t-1)/(t-1)` decreases from `3` (at `t = 2`) through `5/2`
(`t = 3`) and `7/3` (`t = 4`) towards `2`.

## Main results

* `DistinctSumsList` — all `∏ |Aᵢ|` sums of a list of sets are distinct;
* `card_sumsetNat_of_distinctSumsList` — such a list has `|A₁ + ⋯ + A_t| = l^t`;
* `exists_distinctSumsList` — **greedy extraction**: a list of sets each of size
  `≥ l^{2t-1} + l` contains a sublist-wise family of `l`-element subsets with all
  `l^t` sums distinct;
* `AvoidsSumsetsN` — avoidance of `t`-fold sumsets with all parts of size `≥ k`;
* `exists_distinctSumsN_free_set`, `exists_avoidsSumsetsN_set` — the counting
  theorem for `t` summands;
* `exists_dense_set_avoiding_N_sumsets` — the asymptotic theorem with threshold
  `c (log n)^{(2t-1)/(t-1)}`, stated with a real exponent;
* `general_counting_hypotheses_satisfiable` — a machine-checked numerical
  instance for `t = 4`;
* `avoidsSumsetsN_two_iff`, `avoidsSumsetsN_three` — compatibility with the
  two- and three-summand notions of the earlier files.
-/
import Bridges.DenseSumsetFree.Triple
import Bridges.DenseSumsetFree.MultiFold

open Finset Pointwise

namespace DenseSumsetFree

/-- Having distinct sums is a symmetric relation. -/
lemma DistinctSums.symm {A B : Finset ℕ} (h : DistinctSums A B) : DistinctSums B A := by
  intro b₁ hb₁ a₁ ha₁ b₂ hb₂ a₂ ha₂ he
  obtain ⟨h1, h2⟩ := h a₁ ha₁ b₁ hb₁ a₂ ha₂ b₂ hb₂ (by omega)
  exact ⟨h2, h1⟩

/-- A list of finite sets has *distinct sums* if, reading it from the left, each
set has distinct sums against the iterated sumset of the remaining sets.  This is
exactly the condition making the `∏ |Aᵢ|` sums `a₁ + ⋯ + a_t` pairwise different. -/
def DistinctSumsList : List (Finset ℕ) → Prop
  | [] => True
  | A :: L => DistinctSums A (sumsetNat L) ∧ DistinctSumsList L

@[simp] lemma distinctSumsList_nil : DistinctSumsList [] := trivial

@[simp] lemma distinctSumsList_cons {A : Finset ℕ} {L : List (Finset ℕ)} :
    DistinctSumsList (A :: L) ↔ DistinctSums A (sumsetNat L) ∧ DistinctSumsList L :=
  Iff.rfl

/-- A distinct-sums list of `l`-element sets has an iterated sumset of size
exactly `l^t`, where `t` is the length of the list. -/
lemma card_sumsetNat_of_distinctSumsList {l : ℕ} :
    ∀ {L : List (Finset ℕ)}, DistinctSumsList L → (∀ A ∈ L, A.card = l) →
      (sumsetNat L).card = l ^ L.length
  | [], _, _ => by simp
  | A :: L, h, hc => by
    obtain ⟨h1, h2⟩ := h
    rw [sumsetNat_cons, card_add_of_distinctSums h1,
      card_sumsetNat_of_distinctSumsList h2 (fun X hX => hc X (List.mem_cons_of_mem _ hX)),
      hc A List.mem_cons_self, List.length_cons, pow_succ]
    ring

/-- Iterated sumsets are monotone in each argument. -/
lemma sumsetNat_subset_of_forall₂ :
    ∀ {L' L : List (Finset ℕ)}, List.Forall₂ (· ⊆ ·) L' L →
      sumsetNat L' ⊆ sumsetNat L := by
  intro L' L h
  induction h with
  | nil => exact Finset.Subset.refl _
  | cons hAB _ ih => exact Finset.add_subset_add hAB ih

/-- If an iterated sumset of nonempty sets lies in `[n]`, so does every part. -/
lemma subset_range_of_sumsetNat_subset_range {n : ℕ} :
    ∀ {L : List (Finset ℕ)}, (∀ A ∈ L, A.Nonempty) → sumsetNat L ⊆ Finset.range n →
      ∀ A ∈ L, A ⊆ Finset.range n := by
  intro L
  induction L with
  | nil => intro _ _ A hA; exact absurd hA (by simp)
  | cons A L ih =>
    intro hne hsub X hX
    have hAne : A.Nonempty := hne A List.mem_cons_self
    have hLne : (sumsetNat L).Nonempty :=
      sumsetNat_nonempty L fun B hB => hne B (List.mem_cons_of_mem _ hB)
    rw [sumsetNat_cons] at hsub
    have hA : A ⊆ Finset.range n := subset_range_of_add_subset_range hLne hsub
    have hL : sumsetNat L ⊆ Finset.range n :=
      snd_subset_range_of_add_subset_range hAne hsub
    rcases List.mem_cons.1 hX with rfl | hX'
    · exact hA
    · exact ih (fun B hB => hne B (List.mem_cons_of_mem _ hB)) hL X hX'

/-- **Greedy extraction of a distinct-sums `t`-tuple.**  If every set in a list
`L` of length `t` has at least `l^{2t-1} + l` elements, then one can choose
`l`-element subsets, one inside each member of `L`, all of whose `l^t` sums are
distinct.  (For `t = 2` this is `exists_distinctSums_pair`, for `t = 3` it is
`exists_distinctSums_triple`.) -/
theorem exists_distinctSumsList {l : ℕ} (hl : 1 ≤ l) :
    ∀ L : List (Finset ℕ), (∀ A ∈ L, l ^ (2 * L.length - 1) + l ≤ A.card) →
      ∃ L' : List (Finset ℕ), List.Forall₂ (· ⊆ ·) L' L ∧
        (∀ A ∈ L', A.card = l) ∧ DistinctSumsList L' := by
  intro L
  induction L with
  | nil => intro _; exact ⟨[], List.Forall₂.nil, by simp, trivial⟩
  | cons A L ih =>
    intro h
    have hlen : (A :: L).length = L.length + 1 := List.length_cons
    have hexp : 2 * (A :: L).length - 1 = 2 * L.length + 1 := by rw [hlen]; omega
    have htail : ∀ X ∈ L, l ^ (2 * L.length - 1) + l ≤ X.card := by
      intro X hX
      have hX' := h X (List.mem_cons_of_mem _ hX)
      have hpow : l ^ (2 * L.length - 1) ≤ l ^ (2 * (A :: L).length - 1) :=
        Nat.pow_le_pow_right hl (by omega)
      omega
    obtain ⟨L', hf, hcards, hdist⟩ := ih htail
    have hlen' : L'.length = L.length := hf.length_eq
    have hcardsum : (sumsetNat L').card = l ^ L.length := by
      rw [← hlen']
      exact card_sumsetNat_of_distinctSumsList hdist hcards
    have hAcard : l ^ L.length * l ^ L.length * l + l ≤ A.card := by
      have hA := h A List.mem_cons_self
      have hpow : l ^ L.length * l ^ L.length * l = l ^ (2 * (A :: L).length - 1) := by
        rw [hexp, ← pow_add, ← pow_succ]
        ring_nf
      omega
    obtain ⟨A', hA'sub, hA'card, hA'dist⟩ :=
      exists_distinctSums_snd_of_card (sumsetNat L') A (l ^ L.length) l hcardsum hAcard
    refine ⟨A' :: L', List.Forall₂.cons hA'sub hf, ?_, ?_, hdist⟩
    · intro X hX
      rcases List.mem_cons.1 hX with rfl | hX'
      · exact hA'card
      · exact hcards X hX'
    · exact hA'dist.symm

/-- `S` avoids `t`-fold `k`-sumsets: no iterated sumset `A₁ + ⋯ + A_t` with all
parts of size at least `k` is contained in `S`. -/
def AvoidsSumsetsN (S : Finset ℕ) (t k : ℕ) : Prop :=
  ∀ L : List (Finset ℕ), L.length = t → (∀ A ∈ L, k ≤ A.card) → ¬ sumsetNat L ⊆ S

/-- Avoidance of `t`-fold sumsets is monotone in the threshold. -/
lemma AvoidsSumsetsN.mono {S : Finset ℕ} {t k k' : ℕ} (h : AvoidsSumsetsN S t k)
    (hk : k ≤ k') : AvoidsSumsetsN S t k' :=
  fun L hlen hcard => h L hlen fun A hA => le_trans hk (hcard A hA)

/-- **Reduction to distinct-sums tuples.**  If `S` contains no iterated sumset of
a distinct-sums list of `t` sets of size `l`, then `S` avoids all `t`-fold
`k`-sumsets with `k = l^{2t-1} + l`. -/
theorem avoidsSumsetsN_of_no_distinctSumsList {S : Finset ℕ} {l t : ℕ} (hl : 1 ≤ l)
    (h : ∀ L : List (Finset ℕ), L.length = t → (∀ A ∈ L, A.card = l) →
      DistinctSumsList L → ¬ sumsetNat L ⊆ S) :
    AvoidsSumsetsN S t (l ^ (2 * t - 1) + l) := by
  intro L hlen hcard hsub
  obtain ⟨L', hf, hcards, hdist⟩ :=
    exists_distinctSumsList hl L (by rw [hlen]; exact hcard)
  exact h L' (by rw [hf.length_eq, hlen]) hcards hdist
    (Finset.Subset.trans (sumsetNat_subset_of_forall₂ hf) hsub)

/-- **Existence of a dense set containing no distinct-sums `t`-fold sumset.**
If `l ≥ 1`, `l^t ≤ m ≤ n`, the density is bounded by `p/q` (`q·m ≤ p·n`) and the
union-bound inequality `n^{t l} · p^{l^t} < q^{l^t}` holds, then some `m`-element
`S ⊆ [n]` contains no iterated sumset of a distinct-sums list of `t` sets of
size `l`. -/
theorem exists_distinctSumsN_free_set {n m l p q t : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l ^ t ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (t * l) * p ^ (l ^ t) < q ^ (l ^ t)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧
      ∀ L : List (Finset ℕ), L.length = t → (∀ A ∈ L, A.card = l) →
        DistinctSumsList L → ¬ sumsetNat L ⊆ S := by
  classical
  set F : Finset (Finset ℕ) :=
    ((Fintype.piFinset (fun _ : Fin t => (Finset.range n).powersetCard l)).image
      (fun f => sumsetNat (List.ofFn f))).filter (fun T => T.card = l ^ t) with hF
  have hFle : F.card ≤ n ^ (t * l) := by
    refine le_trans (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    refine le_trans Finset.card_image_le ?_
    rw [Fintype.card_piFinset]
    simp only [Finset.card_powersetCard, Finset.card_range, Finset.prod_const,
      Finset.card_univ, Fintype.card_fin]
    calc n.choose l ^ t ≤ (n ^ l) ^ t := Nat.pow_le_pow_left (Nat.choose_le_pow n l) t
      _ = n ^ (t * l) := by rw [← pow_mul]; ring_nf
  have hbound : F.card * (n - l ^ t).choose (m - l ^ t) < n.choose m :=
    lt_of_le_of_lt (Nat.mul_le_mul_right _ hFle)
      (mul_choose_sdiff_lt_choose hn hsm hm hdens hkey)
  obtain ⟨S, hSsub, hScard, hSgood⟩ :=
    exists_set_avoiding_family F (fun T hT => (Finset.mem_filter.1 hT).2) hsm hbound
  refine ⟨S, hSsub, hScard, ?_⟩
  intro L hlen hcard hdist hsub
  subst hlen
  have hne : ∀ A ∈ L, A.Nonempty := by
    intro A hA
    exact Finset.card_pos.1 (by rw [hcard A hA]; omega)
  have hrange : ∀ A ∈ L, A ⊆ Finset.range n :=
    subset_range_of_sumsetNat_subset_range hne (Finset.Subset.trans hsub hSsub)
  refine hSgood (sumsetNat L) ?_ hsub
  rw [hF, Finset.mem_filter]
  refine ⟨Finset.mem_image.2 ⟨fun i : Fin L.length => L[(i : ℕ)], ?_, ?_⟩, ?_⟩
  · rw [Fintype.mem_piFinset]
    intro i
    rw [Finset.mem_powersetCard]
    exact ⟨hrange _ (List.getElem_mem _), hcard _ (List.getElem_mem _)⟩
  · rw [List.ofFn_getElem]
  · exact card_sumsetNat_of_distinctSumsList hdist hcard

/-- **Dense `t`-fold-sumset-avoiding sets: the quantitative core.**  Under the
same hypotheses there is an `m`-element `S ⊆ [n]` avoiding *all* `t`-fold
`k`-sumsets with `k = l^{2t-1} + l`. -/
theorem exists_avoidsSumsetsN_set {n m l p q t : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l ^ t ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (t * l) * p ^ (l ^ t) < q ^ (l ^ t)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧ AvoidsSumsetsN S t (l ^ (2 * t - 1) + l) := by
  obtain ⟨S, hSsub, hScard, hSfree⟩ :=
    exists_distinctSumsN_free_set hl hn hsm hm hdens hkey
  exact ⟨S, hSsub, hScard, avoidsSumsetsN_of_no_distinctSumsList hl hSfree⟩

/-- A machine-checked instance with four summands: with `n = 1024`, `m = 512`
(density `1/2`) and `l = 4` one has `l⁴ = 256 ≤ 512` and
`n^{4l} = 2^{160} < 2^{256} = 2^{l⁴}`, so some `512`-element subset of `[1024]`
contains no four-fold sumset `A₁ + A₂ + A₃ + A₄` with all parts of size at least
`4⁷ + 4 = 16388`. -/
theorem general_counting_hypotheses_satisfiable :
    ∃ S ⊆ Finset.range 1024, S.card = 512 ∧ AvoidsSumsetsN S 4 (4 ^ 7 + 4) := by
  have h := exists_avoidsSumsetsN_set (n := 1024) (m := 512) (l := 4) (p := 1) (q := 2)
    (t := 4) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by
      have h1 : (1024 : ℕ) ^ (4 * 4) * 1 ^ (4 ^ 4) = 2 ^ 160 := by
        rw [one_pow, mul_one, show (1024 : ℕ) = 2 ^ 10 from by norm_num, ← pow_mul]
      rw [h1, show (4 : ℕ) ^ 4 = 256 from by norm_num]
      exact Nat.pow_lt_pow_right (by norm_num) (by norm_num))
  simpa using h

/-- For two summands the list formulation agrees with `AvoidsSumsets`. -/
theorem avoidsSumsetsN_two_of_avoidsSumsets {S : Finset ℕ} {k : ℕ}
    (h : AvoidsSumsets S k) : AvoidsSumsetsN S 2 k := by
  intro L hlen hcard hsub
  match L, hlen with
  | [A, B], _ =>
    have hA : k ≤ A.card := hcard A (by simp)
    have hB : k ≤ B.card := hcard B (by simp)
    refine h A B hA hB ?_
    have hBsum : sumsetNat [A, B] = A + B := by
      simp only [sumsetNat, List.foldr]
      rw [show ({0} : Finset ℕ) = 0 from rfl, add_zero]
    rwa [hBsum] at hsub

/-- For three summands the list formulation implies `AvoidsSumsets3`. -/
theorem avoidsSumsets3_of_avoidsSumsetsN {S : Finset ℕ} {k : ℕ}
    (h : AvoidsSumsetsN S 3 k) : AvoidsSumsets3 S k := by
  intro A B C hA hB hC hsub
  refine h [A, B, C] rfl ?_ ?_
  · intro X hX
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl | rfl <;> assumption
  · have : sumsetNat [A, B, C] = A + B + C := by
      simp only [sumsetNat, List.foldr]
      rw [show ({0} : Finset ℕ) = 0 from rfl, add_zero, add_assoc]
    rwa [this]

/-! ### The asymptotic theorem for a fixed number of summands -/

/-- A `k`-th power of the `(t-1)`-st root, as a real power. -/
lemma rpow_inv_pow {y : ℝ} (hy : 0 ≤ y) {t : ℕ} (ht : 2 ≤ t) (k : ℕ) :
    (y ^ (1 / ((t : ℝ) - 1))) ^ k = y ^ ((k : ℝ) / ((t : ℝ) - 1)) := by
  have ht1 : (0:ℝ) < (t:ℝ) - 1 := by
    have : (2:ℝ) ≤ (t:ℝ) := by exact_mod_cast ht
    linarith
  rw [← Real.rpow_natCast (y ^ (1 / ((t : ℝ) - 1))) k, ← Real.rpow_mul hy]
  congr 1
  field_simp

lemma cast_two_mul_sub_one {t : ℕ} (ht : 1 ≤ t) : ((2 * t - 1 : ℕ) : ℝ) = 2 * (t:ℝ) - 1 := by
  have h : 1 ≤ 2 * t := by omega
  push_cast [Nat.cast_sub h]
  ring

lemma cast_sub_one {t : ℕ} (ht : 1 ≤ t) : ((t - 1 : ℕ) : ℝ) = (t:ℝ) - 1 := by
  push_cast [Nat.cast_sub ht]
  ring

/-- The union-bound inequality for `t` summands, in the form produced by the
choice `l ≈ (t log n / log(q/p))^{1/(t-1)}`. -/
lemma key_pow_ltN {n l p q t : ℕ} (hn : 1 ≤ n) (hp : 1 ≤ p) (hpq : p < q) (hl : 1 ≤ l)
    (ht : 1 ≤ t)
    (hlog : (t:ℝ) * Real.log n < (l:ℝ) ^ (t - 1) * (Real.log q - Real.log p)) :
    n ^ (t * l) * p ^ (l ^ t) < q ^ (l ^ t) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hp0 : (0:ℝ) < p := by exact_mod_cast hp
  have hq0 : (0:ℝ) < q := by exact_mod_cast lt_of_lt_of_le hp hpq.le
  have hl0 : (0:ℝ) < l := by exact_mod_cast hl
  have hpow : (l:ℝ) ^ (t - 1) * (l:ℝ) = (l:ℝ) ^ t := by
    rw [← pow_succ]
    congr 1
    omega
  have hmain : ((n : ℝ) ^ (t * l) * (p : ℝ) ^ (l ^ t)) < (q : ℝ) ^ (l ^ t) := by
    have hpos : (0:ℝ) < (n : ℝ) ^ (t * l) * (p : ℝ) ^ (l ^ t) :=
      mul_pos (pow_pos hn0 _) (pow_pos hp0 _)
    have hposq : (0:ℝ) < (q : ℝ) ^ (l ^ t) := pow_pos hq0 _
    rw [← Real.log_lt_log_iff hpos hposq, Real.log_mul (by positivity) (by positivity),
      Real.log_pow, Real.log_pow, Real.log_pow]
    have hstep := mul_lt_mul_of_pos_right hlog hl0
    have h2 : (l:ℝ) ^ (t - 1) * (Real.log q - Real.log p) * l
        = (l:ℝ) ^ t * (Real.log q - Real.log p) := by rw [← hpow]; ring
    push_cast
    linarith [hstep, h2]
  exact_mod_cast hmain

set_option maxHeartbeats 400000 in
/-- **Main theorem for `t` summands.**  Fix `t ≥ 2` and a density `0 < δ < 1`.
There is a constant `c > 0` such that for all sufficiently large `n` there is a
set `S ⊆ {0, …, n-1}` with `|S| ≥ δ n` such that for every list `A₁, …, A_t` of
finite subsets of `ℕ` with all `|Aᵢ| ≥ c (log n)^{(2t-1)/(t-1)}`, the iterated
sumset `A₁ + ⋯ + A_t` is **not** contained in `S`.

For `t = 2` the exponent is `3` (the theorem of `Main.lean`), for `t = 3` it is
`5/2` (the theorem of `Triple.lean`), and it decreases to `2` as `t → ∞`. -/
theorem exists_dense_set_avoiding_N_sumsets (t : ℕ) (ht : 2 ≤ t)
    (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    ∃ c : ℝ, 0 < c ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ L : List (Finset ℕ), L.length = t →
          (∀ A ∈ L, c * (Real.log n) ^ ((2 * (t:ℝ) - 1) / ((t:ℝ) - 1)) ≤ A.card) →
          ¬ sumsetNat L ⊆ S := by
  classical
  have ht1 : 1 ≤ t := by omega
  have htR : (2:ℝ) ≤ (t:ℝ) := by exact_mod_cast ht
  have htR1 : (0:ℝ) < (t:ℝ) - 1 := by linarith
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
  obtain ⟨G, hG0, hGeq⟩ : ∃ G : ℝ, 0 < G ∧ G = Real.log q - Real.log p := by
    refine ⟨Real.log q - Real.log p, ?_, rfl⟩
    have : Real.log p < Real.log q :=
      Real.log_lt_log (by exact_mod_cast hp1) (by exact_mod_cast hpq)
    linarith
  -- the scaling constant
  set K : ℝ := ((t:ℝ) / G) ^ (1 / ((t:ℝ) - 1)) + 2 with hKeq
  have hK1 : 1 ≤ K := by
    have : (0:ℝ) ≤ ((t:ℝ) / G) ^ (1 / ((t:ℝ) - 1)) := Real.rpow_nonneg (by positivity) _
    rw [hKeq]; linarith
  have hK0 : (0:ℝ) < K := by linarith
  refine ⟨2 * K ^ (2 * t - 1), by positivity, 3 + ⌈(q : ℝ) / e⌉₊ + ⌈1 / (1 - δ)⌉₊ +
    ⌈(16 * K ^ t / δ) ^ 2⌉₊, ?_⟩
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
  have hlog0 : (0:ℝ) ≤ Real.log n := by linarith
  -- `w = (log n)^{1/(t-1)}`
  set w : ℝ := (Real.log n) ^ (1 / ((t:ℝ) - 1)) with hw
  have hw1 : 1 ≤ w := Real.one_le_rpow hlog1 (by positivity)
  have hw0 : (0:ℝ) < w := by linarith
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
  -- the scale `l ≈ (t log n / G)^{1/(t-1)}`
  set x : ℝ := ((t:ℝ) * Real.log n / G) ^ (1 / ((t:ℝ) - 1)) with hx
  have hx0 : (0:ℝ) ≤ x := Real.rpow_nonneg (by positivity) _
  have hxw : x = ((t:ℝ) / G) ^ (1 / ((t:ℝ) - 1)) * w := by
    rw [hx, hw, show (t:ℝ) * Real.log n / G = ((t:ℝ) / G) * Real.log n by ring,
      Real.mul_rpow (by positivity) hlog0]
  have hxpow : x ^ (t - 1) = (t:ℝ) * Real.log n / G := by
    rw [hx, rpow_inv_pow (by positivity) ht, cast_sub_one ht1,
      div_self (ne_of_gt htR1), Real.rpow_one]
  obtain ⟨l, hl1, hlR, hlogl⟩ :
      ∃ l : ℕ, 1 ≤ l ∧ (l : ℝ) ≤ K * w ∧
        (t:ℝ) * Real.log n < (l:ℝ) ^ (t - 1) * G := by
    refine ⟨⌈x⌉₊ + 1, by omega, ?_, ?_⟩
    · have h1 : ((⌈x⌉₊ : ℕ) : ℝ) < x + 1 := Nat.ceil_lt_add_one hx0
      have h2 : ((⌈x⌉₊ + 1 : ℕ) : ℝ) < x + 2 := by push_cast; linarith
      have h3 : x + 2 ≤ K * w := by
        rw [hxw, hKeq]
        have hc : (0:ℝ) ≤ ((t:ℝ) / G) ^ (1 / ((t:ℝ) - 1)) := Real.rpow_nonneg (by positivity) _
        nlinarith
      linarith
    · have h1 : x ≤ ((⌈x⌉₊ : ℕ) : ℝ) := Nat.le_ceil _
      have h2 : x < ((⌈x⌉₊ + 1 : ℕ) : ℝ) := by push_cast; linarith
      have h3 : x ^ (t - 1) < (((⌈x⌉₊ + 1 : ℕ) : ℝ)) ^ (t - 1) :=
        pow_lt_pow_left₀ h2 hx0 (by omega)
      rw [hxpow] at h3
      have := mul_lt_mul_of_pos_right h3 hG0
      rwa [div_mul_cancel₀ _ (ne_of_gt hG0)] at this
  -- `l^t ≤ m`
  have hlt : l ^ t ≤ m := by
    have hlnn : (0:ℝ) ≤ (l : ℝ) := Nat.cast_nonneg l
    have hpowl : ((l : ℝ)) ^ t ≤ K ^ t * w ^ t := by
      calc ((l : ℝ)) ^ t ≤ (K * w) ^ t := pow_le_pow_left₀ hlnn hlR t
        _ = K ^ t * w ^ t := mul_pow K w t
    have hwt : w ^ t ≤ (Real.log n) ^ 2 := by
      rw [hw, rpow_inv_pow hlog0 ht]
      have hexp : (t:ℝ) / ((t:ℝ) - 1) ≤ 2 := by
        rw [div_le_iff₀ htR1]; linarith
      calc (Real.log n) ^ ((t:ℝ) / ((t:ℝ) - 1))
          ≤ (Real.log n) ^ (2:ℝ) := Real.rpow_le_rpow_of_exponent_le hlog1 hexp
        _ = (Real.log n) ^ (2:ℕ) := by
            rw [← Real.rpow_natCast (Real.log n) 2]; norm_num
    have hsqrt : (Real.log n) ^ 2 ≤ 16 * Real.sqrt n := log_sq_le_sqrt (by linarith)
    have hbig : (16 * K ^ t / δ) ^ 2 ≤ (n : ℝ) := by
      have h2 : (⌈(16 * K ^ t / δ) ^ 2⌉₊ : ℕ) ≤ n := by omega
      have h3 : ((⌈(16 * K ^ t / δ) ^ 2⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast h2
      exact le_trans (Nat.le_ceil _) h3
    have hsn : 16 * K ^ t / δ ≤ Real.sqrt n := by
      rw [show (16 * K ^ t / δ) = Real.sqrt ((16 * K ^ t / δ) ^ 2) from
        (Real.sqrt_sq (by positivity)).symm]
      exact Real.sqrt_le_sqrt hbig
    have hsqrtn : 0 ≤ Real.sqrt n := Real.sqrt_nonneg _
    have hsqrt_sq : Real.sqrt n * Real.sqrt n = (n : ℝ) := Real.mul_self_sqrt (by positivity)
    have h16 : 16 * K ^ t ≤ δ * Real.sqrt n := by
      rw [div_le_iff₀ hδ0] at hsn; linarith
    have hfin : ((l : ℝ)) ^ t ≤ δ * n :=
      calc ((l : ℝ)) ^ t ≤ K ^ t * w ^ t := hpowl
        _ ≤ K ^ t * (16 * Real.sqrt n) :=
            mul_le_mul_of_nonneg_left (le_trans hwt hsqrt) (by positivity)
        _ = (16 * K ^ t) * Real.sqrt n := by ring
        _ ≤ (δ * Real.sqrt n) * Real.sqrt n := mul_le_mul_of_nonneg_right h16 hsqrtn
        _ = δ * n := by rw [mul_assoc, hsqrt_sq]
    have hcast : ((l ^ t : ℕ) : ℝ) ≤ (m : ℝ) := by
      have hll : ((l ^ t : ℕ) : ℝ) = ((l : ℝ)) ^ t := by push_cast; ring
      rw [hll]; linarith
    exact_mod_cast hcast
  -- the union-bound inequality
  have hkey : n ^ (t * l) * p ^ (l ^ t) < q ^ (l ^ t) :=
    key_pow_ltN (by omega) hp1 hpq hl1 ht1 (by rw [← hGeq]; exact hlogl)
  obtain ⟨S, hSsub, hScard, hSavoid⟩ :=
    exists_avoidsSumsetsN_set (n := n) (m := m) (l := l) (p := p) (q := q) (t := t)
      hl1 (by omega) hlt hmn hdens hkey
  refine ⟨S, hSsub, by rw [hScard]; exact hmge, ?_⟩
  intro L hlen hcard
  -- the threshold `l^{2t-1} + l` is dominated by `c (log n)^{(2t-1)/(t-1)}`
  have hthr : ((l ^ (2 * t - 1) + l : ℕ) : ℝ)
      ≤ 2 * K ^ (2 * t - 1) * (Real.log n) ^ ((2 * (t:ℝ) - 1) / ((t:ℝ) - 1)) := by
    have hlnn : (0:ℝ) ≤ (l : ℝ) := Nat.cast_nonneg l
    have hl0 : (1:ℝ) ≤ (l : ℝ) := by exact_mod_cast hl1
    have hpowl : ((l : ℝ)) ^ (2 * t - 1) ≤ K ^ (2 * t - 1) * w ^ (2 * t - 1) := by
      calc ((l : ℝ)) ^ (2 * t - 1) ≤ (K * w) ^ (2 * t - 1) :=
            pow_le_pow_left₀ hlnn hlR _
        _ = K ^ (2 * t - 1) * w ^ (2 * t - 1) := mul_pow K w _
    have hwpow : w ^ (2 * t - 1)
        = (Real.log n) ^ ((2 * (t:ℝ) - 1) / ((t:ℝ) - 1)) := by
      rw [hw, rpow_inv_pow hlog0 ht, cast_two_mul_sub_one ht1]
    have hsmall : (l : ℝ) ≤ ((l : ℝ)) ^ (2 * t - 1) := by
      simpa using pow_le_pow_right₀ hl0 (by omega : 1 ≤ 2 * t - 1)
    have hpos : (0:ℝ) ≤ K ^ (2 * t - 1) * (Real.log n) ^ ((2 * (t:ℝ) - 1) / ((t:ℝ) - 1)) := by
      have : (0:ℝ) ≤ (Real.log n) ^ ((2 * (t:ℝ) - 1) / ((t:ℝ) - 1)) :=
        Real.rpow_nonneg hlog0 _
      positivity
    have hcast : ((l ^ (2 * t - 1) + l : ℕ) : ℝ) = ((l : ℝ)) ^ (2 * t - 1) + (l : ℝ) := by
      push_cast; ring
    rw [hcast, ← hwpow]
    linarith
  refine hSavoid L hlen ?_
  intro A hA
  have h1 : ((l ^ (2 * t - 1) + l : ℕ) : ℝ) ≤ (A.card : ℝ) := le_trans hthr (hcard A hA)
  exact_mod_cast h1

/-! ### How the exponent behaves -/

/-- The exponent `(2t-1)/(t-1)` is always strictly greater than `2`: the method
never reaches the (conjecturally optimal) linear-in-`log n` threshold. -/
lemma two_lt_general_exponent {t : ℕ} (ht : 2 ≤ t) :
    2 < (2 * (t:ℝ) - 1) / ((t:ℝ) - 1) := by
  have htR : (2:ℝ) ≤ (t:ℝ) := by exact_mod_cast ht
  have h1 : (0:ℝ) < (t:ℝ) - 1 := by linarith
  rw [lt_div_iff₀ h1]
  linarith

/-- For `t ≥ 3` summands the exponent `(2t-1)/(t-1)` is strictly below the
exponent `3` of the two-summand theorem: passing to more summands is a genuine
gain, not just the grouping bound of `MultiFold.lean`. -/
lemma general_exponent_lt_three {t : ℕ} (ht : 3 ≤ t) :
    (2 * (t:ℝ) - 1) / ((t:ℝ) - 1) < 3 := by
  have htR : (3:ℝ) ≤ (t:ℝ) := by exact_mod_cast ht
  have h1 : (0:ℝ) < (t:ℝ) - 1 := by linarith
  rw [div_lt_iff₀ h1]
  linarith

/-- The exponent decreases as the number of summands grows. -/
lemma general_exponent_antitone {t u : ℕ} (ht : 2 ≤ t) (htu : t ≤ u) :
    (2 * (u:ℝ) - 1) / ((u:ℝ) - 1) ≤ (2 * (t:ℝ) - 1) / ((t:ℝ) - 1) := by
  have htR : (2:ℝ) ≤ (t:ℝ) := by exact_mod_cast ht
  have huR : (t:ℝ) ≤ (u:ℝ) := by exact_mod_cast htu
  have h1 : (0:ℝ) < (t:ℝ) - 1 := by linarith
  have h2 : (0:ℝ) < (u:ℝ) - 1 := by linarith
  rw [div_le_div_iff₀ h2 h1]
  nlinarith

/-- The exponent tends to `2`: for every `ε > 0` there are `t` summands for which
the threshold exponent is below `2 + ε`. -/
lemma exists_general_exponent_lt {ε : ℝ} (hε : 0 < ε) :
    ∃ t : ℕ, 2 ≤ t ∧ (2 * (t:ℝ) - 1) / ((t:ℝ) - 1) < 2 + ε := by
  obtain ⟨t, ht⟩ := exists_nat_gt (2 + 1 / ε)
  refine ⟨max t 2, le_max_right _ _, ?_⟩
  have h2 : (2:ℝ) ≤ ((max t 2 : ℕ) : ℝ) := by
    have : (2 : ℕ) ≤ max t 2 := le_max_right _ _
    exact_mod_cast this
  have htmax : ((t : ℕ) : ℝ) ≤ ((max t 2 : ℕ) : ℝ) := by
    have : t ≤ max t 2 := le_max_left _ _
    exact_mod_cast this
  set u : ℝ := ((max t 2 : ℕ) : ℝ) with hu
  have h1 : (0:ℝ) < u - 1 := by linarith
  have hgt : 2 + 1 / ε < u := lt_of_lt_of_le ht htmax
  have hkey : 1 / ε < u - 1 - 1 + 1 := by linarith
  rw [div_lt_iff₀ h1]
  have hεu : 1 < ε * (u - 1) := by
    have h3 : 1 / ε < u - 1 := by linarith
    rw [div_lt_iff₀ hε] at h3
    nlinarith
  nlinarith

end DenseSumsetFree