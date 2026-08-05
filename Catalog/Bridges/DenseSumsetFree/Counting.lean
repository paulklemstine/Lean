/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The counting (deterministic first-moment) argument

We count `m`-element subsets `S` of `[n]`.  A subset is *bad* if it contains the
sumset `A' + B'` of some distinct-sums pair of `l`-element sets, i.e. some
`l²`-element set of a very special shape.  There are at most `binom(n, l)² ≤ n^{2l}`
such sumsets, and each fixed `l²`-set is contained in exactly
`binom(n - l², m - l²)` of the `m`-subsets.  Comparing with the total
`binom(n, m)` gives a good (i.e. sumset-free) set as soon as

  `n^{2l} · p^{l²} < q^{l²}`,  where  `q·m ≤ p·n`  (density at most `p/q`).

This is the first-moment / union-bound argument, carried out purely by counting
finite sets — no measure theory is required.

## Main results

* `choose_sdiff_mul_pow_le` — the ratio bound `binom(n-s, m-s) · n^s ≤ binom(n,m) · m^s`;
* `card_supersets_eq` — exactly `binom(n-s, m-s)` of the `m`-subsets of `[n]`
  contain a fixed `s`-subset;
* `exists_set_avoiding_family` — the first moment for an arbitrary family of
  forbidden `s`-element patterns;
* `mul_choose_sdiff_lt_choose` — the arithmetic behind the union bound;
* `exists_distinctSums_free_set` — existence of a dense `S ⊆ [n]` containing no
  sumset of a distinct-sums pair of `l`-sets;
* `exists_avoidsSumsets_set` — combined with the extraction theorem: existence of
  a dense `S ⊆ [n]` with `AvoidsSumsets S (l³ + l)`.
-/
import Bridges.DenseSumsetFree.Extraction

open Finset Pointwise

namespace DenseSumsetFree

/-- Elementary comparison used in the induction below: `(m - s)·n ≤ (n - s)·m`
whenever `m ≤ n`. -/
lemma sub_mul_le_sub_mul {s n m : ℕ} (hm : m ≤ n) : (m - s) * n ≤ (n - s) * m := by
  calc (m - s) * n = m * n - s * n := by rw [Nat.sub_mul]
    _ ≤ n * m - s * m := tsub_le_tsub (le_of_eq (mul_comm m n)) (Nat.mul_le_mul_left _ hm)
    _ = (n - s) * m := by rw [Nat.sub_mul]

/-- **Binomial ratio bound.** For `s ≤ m ≤ n`,
`binom(n - s, m - s) · n^s ≤ binom(n, m) · m^s`; equivalently, the proportion of
`m`-subsets containing a fixed `s`-set is at most `(m/n)^s`. -/
theorem choose_sdiff_mul_pow_le :
    ∀ (s n m : ℕ), s ≤ m → m ≤ n → (n - s).choose (m - s) * n ^ s ≤ n.choose m * m ^ s := by
  intro s
  induction s with
  | zero => intro n m _ _; simp
  | succ s ih =>
    intro n m hs hm
    have hsm : s ≤ m := Nat.le_of_succ_le hs
    have ihnm := ih n m hsm hm
    have hb1 : 1 ≤ m - s := by omega
    have ha1 : 1 ≤ n - s := by omega
    have hid : (n - s) * (n - s - 1).choose (m - s - 1) = (n - s).choose (m - s) * (m - s) := by
      obtain ⟨a', ha'⟩ : ∃ a', n - s = a' + 1 := ⟨n - s - 1, by omega⟩
      obtain ⟨b', hb'⟩ : ∃ b', m - s = b' + 1 := ⟨m - s - 1, by omega⟩
      rw [ha', hb']
      simpa using Nat.add_one_mul_choose_eq a' b'
    have hab : n - (s + 1) = n - s - 1 := by omega
    have hab' : m - (s + 1) = m - s - 1 := by omega
    rw [hab, hab']
    refine Nat.le_of_mul_le_mul_left ?_ (show 0 < n - s by omega)
    calc (n - s) * ((n - s - 1).choose (m - s - 1) * n ^ (s + 1))
        = ((n - s) * (n - s - 1).choose (m - s - 1)) * (n ^ s * n) := by ring
      _ = ((n - s).choose (m - s) * n ^ s) * ((m - s) * n) := by rw [hid]; ring
      _ ≤ ((n - s).choose (m - s) * n ^ s) * ((n - s) * m) :=
          Nat.mul_le_mul_left _ (sub_mul_le_sub_mul hm)
      _ ≤ (n.choose m * m ^ s) * ((n - s) * m) := Nat.mul_le_mul_right _ ihnm
      _ = (n - s) * (n.choose m * m ^ (s + 1)) := by ring

/-- **Counting supersets.** For a fixed `s`-element subset `T ⊆ [n]` with
`s ≤ m ≤ n`, exactly `binom(n - s, m - s)` of the `m`-element subsets of `[n]`
contain `T`. -/
theorem card_supersets_eq {n m s : ℕ} (T : Finset ℕ) (hT : T ⊆ Finset.range n)
    (hTcard : T.card = s) (hs : s ≤ m) :
    (((Finset.range n).powersetCard m).filter (fun S => T ⊆ S)).card
      = (n - s).choose (m - s) := by
  classical
  have hcompl : (Finset.range n \ T).card = n - s := by
    rw [Finset.card_sdiff_of_subset hT, Finset.card_range, hTcard]
  rw [← hcompl, ← Finset.card_powersetCard]
  refine Finset.card_bij' (fun S _ => S \ T) (fun R _ => R ∪ T) ?_ ?_ ?_ ?_
  · -- forward map lands in the target
    intro S hS
    rw [Finset.mem_filter, Finset.mem_powersetCard] at hS
    obtain ⟨⟨hsub, hcard⟩, hTS⟩ := hS
    rw [Finset.mem_powersetCard]
    refine ⟨?_, ?_⟩
    · intro x hx
      rw [Finset.mem_sdiff] at hx ⊢
      exact ⟨hsub hx.1, hx.2⟩
    · rw [Finset.card_sdiff_of_subset hTS, hcard, hTcard]
  · -- backward map lands in the source
    intro R hR
    rw [Finset.mem_powersetCard] at hR
    obtain ⟨hsub, hcard⟩ := hR
    have hdisj : Disjoint R T := by
      refine Finset.disjoint_left.2 fun x hx hxT => ?_
      exact (Finset.mem_sdiff.1 (hsub hx)).2 hxT
    rw [Finset.mem_filter, Finset.mem_powersetCard]
    refine ⟨⟨?_, ?_⟩, Finset.subset_union_right⟩
    · exact Finset.union_subset (fun x hx => (Finset.mem_sdiff.1 (hsub hx)).1) hT
    · rw [Finset.card_union_of_disjoint hdisj, hcard, hTcard]
      omega
  · intro S hS
    rw [Finset.mem_filter] at hS
    exact Finset.sdiff_union_of_subset hS.2
  · intro R hR
    rw [Finset.mem_powersetCard] at hR
    have hdisj : Disjoint R T := by
      refine Finset.disjoint_left.2 fun x hx hxT => ?_
      exact (Finset.mem_sdiff.1 (hR.1 hx)).2 hxT
    show (R ∪ T) \ T = R
    rw [Finset.union_sdiff_cancel_right hdisj]

/-- The bound version of `card_supersets_eq`, valid for an arbitrary `s`-element
set `T` (if `T` is not contained in `[n]` there are no supersets at all). -/
theorem card_supersets_le {n m s : ℕ} (T : Finset ℕ) (hTcard : T.card = s) (hs : s ≤ m) :
    (((Finset.range n).powersetCard m).filter (fun S => T ⊆ S)).card
      ≤ (n - s).choose (m - s) := by
  classical
  by_cases hT : T ⊆ Finset.range n
  · exact le_of_eq (card_supersets_eq T hT hTcard hs)
  · have : (((Finset.range n).powersetCard m).filter (fun S => T ⊆ S)) = ∅ := by
      refine Finset.eq_empty_of_forall_notMem fun S hS => ?_
      rw [Finset.mem_filter, Finset.mem_powersetCard] at hS
      exact hT (Finset.Subset.trans hS.2 hS.1.1)
    rw [this]
    simp

/-- **First moment, general form.**  Let `F` be any finite family of `s`-element
sets.  If `|F| · binom(n - s, m - s) < binom(n, m)` then some `m`-element subset
`S ⊆ [n]` contains no member of `F`. -/
theorem exists_set_avoiding_family {n m s : ℕ} (F : Finset (Finset ℕ))
    (hFcard : ∀ T ∈ F, T.card = s) (hs : s ≤ m)
    (hbound : F.card * (n - s).choose (m - s) < n.choose m) :
    ∃ S ⊆ Finset.range n, S.card = m ∧ ∀ T ∈ F, ¬ T ⊆ S := by
  classical
  have hbad :
      (((Finset.range n).powersetCard m).filter (fun S => ¬ ∀ T ∈ F, ¬ T ⊆ S)).card
        ≤ F.card * (n - s).choose (m - s) := by
    have hsubset :
        ((Finset.range n).powersetCard m).filter (fun S => ¬ ∀ T ∈ F, ¬ T ⊆ S)
          ⊆ F.biUnion
              (fun T => ((Finset.range n).powersetCard m).filter (fun S => T ⊆ S)) := by
      intro S hS
      rw [Finset.mem_filter] at hS
      obtain ⟨hSmem, hSbad⟩ := hS
      push_neg at hSbad
      obtain ⟨T, hTmem, hTS⟩ := hSbad
      exact Finset.mem_biUnion.2 ⟨T, hTmem, Finset.mem_filter.2 ⟨hSmem, hTS⟩⟩
    refine le_trans (Finset.card_le_card hsubset) (le_trans (Finset.card_biUnion_le) ?_)
    have hterm : ∀ T ∈ F,
        (((Finset.range n).powersetCard m).filter (fun S => T ⊆ S)).card
          ≤ (n - s).choose (m - s) :=
      fun T hT => card_supersets_le T (hFcard T hT) hs
    simpa [smul_eq_mul, mul_comm] using Finset.sum_le_card_nsmul _ _ _ hterm
  have hgoodne : (((Finset.range n).powersetCard m).filter
      (fun S => ∀ T ∈ F, ¬ T ⊆ S)).Nonempty := by
    rw [← Finset.card_pos]
    have htot : ((Finset.range n).powersetCard m).card = n.choose m := by
      rw [Finset.card_powersetCard, Finset.card_range]
    have hsplit :
        (((Finset.range n).powersetCard m).filter (fun S => ∀ T ∈ F, ¬ T ⊆ S)).card
        + (((Finset.range n).powersetCard m).filter (fun S => ¬ ∀ T ∈ F, ¬ T ⊆ S)).card
        = ((Finset.range n).powersetCard m).card :=
      Finset.card_filter_add_card_filter_not _
    rw [htot] at hsplit
    omega
  obtain ⟨S, hS⟩ := hgoodne
  rw [Finset.mem_filter, Finset.mem_powersetCard] at hS
  exact ⟨S, hS.1.1, hS.1.2, hS.2⟩

/-- **The union-bound arithmetic.**  If the density is bounded by `p/q`
(`q·m ≤ p·n`) and `W · p^s < q^s`, then `W · binom(n - s, m - s) < binom(n, m)`:
a family of `W` forbidden `s`-sets is not enough to cover all `m`-subsets. -/
theorem mul_choose_sdiff_lt_choose {n m s W p q : ℕ} (hn : 0 < n)
    (hs : s ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n) (hkey : W * p ^ s < q ^ s) :
    W * (n - s).choose (m - s) < n.choose m := by
  have hratio := choose_sdiff_mul_pow_le s n m hs hm
  have hchoose_pos : 0 < n.choose m := Nat.choose_pos hm
  have hnpos : 0 < n ^ s := Nat.pow_pos hn
  refine Nat.lt_of_mul_lt_mul_right (a := n ^ s * q ^ s) ?_
  calc W * (n - s).choose (m - s) * (n ^ s * q ^ s)
      = (W * q ^ s) * ((n - s).choose (m - s) * n ^ s) := by ring
    _ ≤ (W * q ^ s) * (n.choose m * m ^ s) := Nat.mul_le_mul_left _ hratio
    _ = (W * n.choose m) * (q * m) ^ s := by rw [mul_pow]; ring
    _ ≤ (W * n.choose m) * (p * n) ^ s := Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hdens s)
    _ = (W * p ^ s) * (n.choose m * n ^ s) := by rw [mul_pow]; ring
    _ < q ^ s * (n.choose m * n ^ s) :=
        (Nat.mul_lt_mul_right (Nat.mul_pos hchoose_pos hnpos)).2 hkey
    _ = n.choose m * (n ^ s * q ^ s) := by ring

/-- **Existence of a dense set containing no distinct-sums sumset.**  Suppose
`l ≥ 1`, `l² ≤ m ≤ n`, the density is bounded by `p/q` in the sense `q·m ≤ p·n`,
and the union-bound inequality `n^{2l} · p^{l²} < q^{l²}` holds.  Then some
`m`-element subset `S ⊆ [n]` contains no sumset `A' + B'` of a distinct-sums pair
of `l`-element sets. -/
theorem exists_distinctSums_free_set {n m l p q : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l * l ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (2 * l) * p ^ (l * l) < q ^ (l * l)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧
      ∀ A' B' : Finset ℕ, A'.card = l → B'.card = l → DistinctSums A' B' →
        ¬ A' + B' ⊆ S := by
  classical
  set s := l * l with hs
  -- the family of candidate sumsets
  set F : Finset (Finset ℕ) :=
    ((((Finset.range n).powersetCard l) ×ˢ ((Finset.range n).powersetCard l)).image
      (fun r : Finset ℕ × Finset ℕ => r.1 + r.2)).filter (fun T => T.card = s) with hF
  have hFle : F.card ≤ n ^ (2 * l) := by
    refine le_trans (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    refine le_trans (Finset.card_image_le) ?_
    rw [Finset.card_product, Finset.card_powersetCard, Finset.card_range]
    calc n.choose l * n.choose l ≤ n ^ l * n ^ l :=
          Nat.mul_le_mul (Nat.choose_le_pow n l) (Nat.choose_le_pow n l)
      _ = n ^ (2 * l) := by rw [← pow_add]; ring_nf
  have hbound : F.card * (n - s).choose (m - s) < n.choose m :=
    lt_of_le_of_lt (Nat.mul_le_mul_right _ hFle)
      (mul_choose_sdiff_lt_choose hn hsm hm hdens hkey)
  obtain ⟨S, hSsub, hScard, hSgood⟩ :=
    exists_set_avoiding_family F (fun T hT => (Finset.mem_filter.1 hT).2) hsm hbound
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A' B' hA' hB' hdist hsub
  have hsubrange : A' + B' ⊆ Finset.range n := Finset.Subset.trans hsub hSsub
  have hA'sub : A' ⊆ Finset.range n := by
    have hB'ne : B'.Nonempty := Finset.card_pos.1 (by omega)
    exact subset_range_of_add_subset_range hB'ne hsubrange
  have hB'sub : B' ⊆ Finset.range n := by
    have hA'ne : A'.Nonempty := Finset.card_pos.1 (by omega)
    exact snd_subset_range_of_add_subset_range hA'ne hsubrange
  refine hSgood (A' + B') ?_ hsub
  rw [hF, Finset.mem_filter]
  refine ⟨Finset.mem_image.2 ⟨(A', B'), ?_, rfl⟩, ?_⟩
  · rw [Finset.mem_product, Finset.mem_powersetCard, Finset.mem_powersetCard]
    exact ⟨⟨hA'sub, hA'⟩, ⟨hB'sub, hB'⟩⟩
  · rw [card_add_of_distinctSums hdist, hA', hB', hs]

/-- **Dense sumset-avoiding sets: the quantitative core.** Under the same
hypotheses, there is an `m`-element `S ⊆ [n]` which avoids *all* `k`-sumsets with
`k = l³ + l`.  This combines the counting argument with the greedy extraction of
distinct-sums pairs. -/
theorem exists_avoidsSumsets_set {n m l p q : ℕ} (hl : 1 ≤ l) (hn : 0 < n)
    (hsm : l * l ≤ m) (hm : m ≤ n) (hdens : q * m ≤ p * n)
    (hkey : n ^ (2 * l) * p ^ (l * l) < q ^ (l * l)) :
    ∃ S ⊆ Finset.range n, S.card = m ∧ AvoidsSumsets S (l ^ 3 + l) := by
  obtain ⟨S, hSsub, hScard, hSfree⟩ :=
    exists_distinctSums_free_set hl hn hsm hm hdens hkey
  exact ⟨S, hSsub, hScard, avoidsSumsets_of_no_distinctSums hSfree⟩

end DenseSumsetFree