import Shared.SidonSetsErdosTuran

/-!
# `B_h` sets through their differences, and where Sidon sets sit in the hierarchy

Companion to `Novelty/GreedyDifferenceSidon.lean`, which grows a set by refusing to repeat
a **difference** `a i - a j`.  That file showed the resulting objects are exactly Sidon
(= `B₂`) sets.  Here we identify the general phenomenon: for every `h` there is a
*difference rigidity* property `IsDiffBh h`, and it is sandwiched between the two
neighbouring layers of the `B_h` hierarchy,

  `B_{2h}  ⟹  h-difference rigidity  ⟹  B_h`,

with the bottom layer `h = 1` being **exactly** the Sidon property.  So "greedy avoidance
of differences" is the `h = 1` instance of a whole tower, and each floor of the tower is
governed by two-sided rigidity statements rather than by a single counting inequality.

## Main results

* `IsBh` — `A` is a `B_h` set: multisets of `h` elements of `A` are determined by their
  sum.  `IsDiffBh` — the `h`-fold *difference* rigidity: `Σs - Σt = Σs' - Σt'` forces
  `s + t' = s' + t` (written additively, so it makes sense over `ℕ`).
* `isBh_two_iff_isSidon` — `B₂ ⟺ Sidon`, tying the definition to the catalog's `IsSidon`.
* `isDiffBh_one_iff_isSidon` — **the difference layer at `h = 1` is exactly Sidon**: this
  is the abstract form of "all differences `a i - a j` are distinct".
* `IsBh.isDiffBh` — `B_{2h} ⟹ h`-difference rigidity: doubling the `B_h` level buys you
  rigidity of `h`-fold differences.
* `IsDiffBh.isBh` — the converse half: `h`-difference rigidity ⟹ `B_h`.  Hence the
  sandwich `B_{2h} ⟹ Diff_h ⟹ B_h` (`isBh_of_isDiffBh_of_isBh_two_mul`).
* `isDiffBh_iff_isBh_two_mul` — **the sandwich collapses**: `h`-fold difference rigidity is
  *equivalent* to `B_{2h}`.  Splitting a `2h`-element multiset into two halves turns a
  `B_{2h}` coincidence into a repeated `h`-fold difference, so "greedy avoidance of
  `h`-fold differences" and "being a `B_{2h}` set" are the same condition.
* `IsBh.antitone` — `B_h` sets are `B_k` for `k ≤ h` (`1 ≤ k`), proved by padding with a
  repeated element.
* `IsBh.choose_card_le` — **counting bound**: a `B_h` subset of `{0, …, N-1}` satisfies
  `C(|A|, h) ≤ h(N-1) + 1`.
* `IsBh.pow_card_sub_le` — the same bound in the usable form
  `(|A| - h + 1)^h ≤ h! · (h(N-1) + 1)`, i.e. `|A| ≲ (h! · h · N)^{1/h}`; for `h = 2`
  this reproduces the Erdős–Turán order of magnitude `√N`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (B1) The difference formulation of Sidon-ness is not an
  accident of `h = 2` but the bottom of a tower: there should be a rigidity property of
  `h`-fold differences that implies `B_h` and is implied by `B_{2h}`.  (B2) The sandwich
  might be strict, i.e. `Diff_h` might sit genuinely between two `B` layers.  (B3) The
  `B_h` counting bound should follow from the same injectivity that governs greedy
  extensions, with no extra combinatorics.
Experiment (Experimenter): (B1) was proved in both directions.  The forward direction is
  a one-line application of `B_{2h}` to the two multisets `s + t'` and `s' + t`, each of
  size `2h`; the backward direction feeds the degenerate difference `Σs - Σt = Σt - Σs`
  into rigidity and cancels `s + s = t + t`.  (B2) was **refuted**, and in the most
  informative way: a second look showed that *every* `2h`-multiset splits into two halves,
  so `Diff_h` also implies `B_{2h}` and the sandwich collapses to the equivalence
  `Diff_h ⟺ B_{2h}`.  (B3) was proved by injecting
  `powersetCard h A` into `{0, …, h(N-1)}` and applying `Finset.card_le_card_of_injOn`.
  Computationally, the greedy Sidon set `{0,1,3,7,12,20,30,44}` is `B₂` but not `B₃`
  (`0+7+12 = 1+3+... ` type coincidences appear at level 3), and the greedy `B₃` and
  `B₄` sequences `1,2,5,14,33,72,125,219,376,573` and `1,2,6,22,56,154,369,857,1425`
  (OEIS A046185, A046186) grow visibly faster, consistent with the counting bound.
Analysis (Analyst): the collapse `Diff_h = B_{2h}` explains why the greedy difference
  process of the companion file produces exactly `B₂` sets: the process enforces `Diff_1`,
  and `Diff_1 = B_2` on the nose.  It also predicts the right generalisation: to build
  `B_{2h}` sets greedily one should avoid repeated `h`-fold differences, not `2h`-fold
  sums — a strictly smaller obstruction set to check.
Critique (Critic): `IsDiffBh` is stated additively (`Σs + Σt' = Σs' + Σt`) so that it is
  meaningful in `ℕ`, where subtraction is truncated; over a group it is literally the
  statement about differences.  `IsBh.antitone` needs `1 ≤ k` (for `k = 0` it is trivial
  anyway) and its proof needs `A` nonempty, which is supplied by the multisets involved
  unless `k = 0`.  The counting bound needs `1 ≤ h`; for `h = 0` the left side is `1` and
  the right side `1`, so it happens to survive, but the proof of the `pow` form assumes
  `h ≤ |A|` and that hypothesis is load-bearing.
Synthesis (PI): differences give a genuine intermediate layer `B_{2h} ⟹ Diff_h ⟹ B_h`,
  whose bottom floor is the Sidon property studied greedily in the companion file.
-/

namespace BhDifference

open Finset

section General

variable {M : Type*} [AddCancelCommMonoid M]

/-- `A` is a **`B_h` set**: a multiset of `h` elements of `A` is determined by its sum. -/
def IsBh (h : ℕ) (A : Finset M) : Prop :=
  ∀ s t : Multiset M, (∀ x ∈ s, x ∈ A) → (∀ x ∈ t, x ∈ A) →
    Multiset.card s = h → Multiset.card t = h → s.sum = t.sum → s = t

/-- **`h`-fold difference rigidity.**  Written additively so that it makes sense over `ℕ`:
`Σs - Σt = Σs' - Σt'` forces the multiset identity `s + t' = s' + t`. -/
def IsDiffBh (h : ℕ) (A : Finset M) : Prop :=
  ∀ s t s' t' : Multiset M,
    (∀ x ∈ s, x ∈ A) → (∀ x ∈ t, x ∈ A) → (∀ x ∈ s', x ∈ A) → (∀ x ∈ t', x ∈ A) →
    Multiset.card s = h → Multiset.card t = h → Multiset.card s' = h →
    Multiset.card t' = h →
    s.sum + t'.sum = s'.sum + t.sum → s + t' = s' + t

theorem IsBh.subset {h : ℕ} {A B : Finset M} (hB : IsBh h B) (hAB : A ⊆ B) : IsBh h A :=
  fun s t hs ht hcs hct hsum =>
    hB s t (fun x hx => hAB (hs x hx)) (fun x hx => hAB (ht x hx)) hcs hct hsum

/-- Every set is a `B₁` set. -/
theorem isBh_one (A : Finset M) : IsBh 1 A := by
  intro s t _ _ hcs hct hsum
  obtain ⟨a, rfl⟩ := Multiset.card_eq_one.mp hcs
  obtain ⟨b, rfl⟩ := Multiset.card_eq_one.mp hct
  simpa using hsum

/-- **`B₂ ⟺ Sidon`.** -/
theorem isBh_two_iff_isSidon (A : Finset M) : IsBh 2 A ↔ IsSidon A := by
  constructor
  · intro hB a ha b hb c hc d hd habcd
    have hs : ∀ x ∈ ({a, b} : Multiset M), x ∈ A := by
      intro x hx
      simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> assumption
    have ht : ∀ x ∈ ({c, d} : Multiset M), x ∈ A := by
      intro x hx
      simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> assumption
    have heq : ({a, b} : Multiset M) = {c, d} := by
      refine hB _ _ hs ht (by simp) (by simp) ?_
      simpa using habcd
    -- unravel the multiset equality of two pairs
    have hmem : a ∈ ({c, d} : Multiset M) := heq ▸ (by simp)
    simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hmem
    rcases hmem with rfl | rfl
    · left
      refine ⟨rfl, ?_⟩
      rw [Multiset.insert_eq_cons, Multiset.insert_eq_cons, Multiset.cons_inj_right] at heq
      simpa using heq
    · right
      refine ⟨rfl, ?_⟩
      rw [Multiset.pair_comm] at heq
      simpa using heq
  · intro hA s t hs ht hcs hct hsum
    obtain ⟨a, b, rfl⟩ := Multiset.card_eq_two.mp hcs
    obtain ⟨c, d, rfl⟩ := Multiset.card_eq_two.mp hct
    have ha : a ∈ A := hs a (by simp)
    have hb : b ∈ A := hs b (by simp)
    have hc : c ∈ A := ht c (by simp)
    have hd : d ∈ A := ht d (by simp)
    have hsum' : a + b = c + d := by simpa using hsum
    rcases hA a ha b hb c hc d hd hsum' with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rfl
    · exact Multiset.pair_comm _ _

/-- **`B_h` sets are `B_k` sets for `k ≤ h`**: pad both multisets with `h - k` copies of a
fixed element and cancel. -/
theorem IsBh.antitone {h k : ℕ} {A : Finset M} (hA : IsBh h A) (hk : 1 ≤ k) (hkh : k ≤ h) :
    IsBh k A := by
  intro s t hs ht hcs hct hsum
  -- `s` is nonempty, so `A` is nonempty
  obtain ⟨a, ha⟩ : ∃ a, a ∈ s := by
    rcases Multiset.empty_or_exists_mem s with rfl | h'
    · simp at hcs; omega
    · exact h'
  have haA : a ∈ A := hs a ha
  have hcpad : Multiset.card (Multiset.replicate (h - k) a) = h - k := by simp
  have hmem : ∀ x ∈ Multiset.replicate (h - k) a, x ∈ A := by
    intro x hx
    have hxa : x = a := Multiset.eq_of_mem_replicate hx
    rw [hxa]; exact haA
  have key : s + Multiset.replicate (h - k) a = t + Multiset.replicate (h - k) a := by
    refine hA _ _ ?_ ?_ ?_ ?_ ?_
    · intro x hx
      rcases Multiset.mem_add.mp hx with hx | hx
      · exact hs x hx
      · exact hmem x hx
    · intro x hx
      rcases Multiset.mem_add.mp hx with hx | hx
      · exact ht x hx
      · exact hmem x hx
    · rw [Multiset.card_add, hcs, hcpad]; omega
    · rw [Multiset.card_add, hct, hcpad]; omega
    · rw [Multiset.sum_add, Multiset.sum_add, hsum]
  exact add_right_cancel key

/-- **`B_{2h}` implies `h`-fold difference rigidity.** -/
theorem IsBh.isDiffBh {h : ℕ} {A : Finset M} (hA : IsBh (2 * h) A) : IsDiffBh h A := by
  intro s t s' t' hs ht hs' ht' hcs hct hcs' hct' hsum
  refine hA (s + t') (s' + t) ?_ ?_ ?_ ?_ ?_
  · intro x hx
    rcases Multiset.mem_add.mp hx with hx | hx
    · exact hs x hx
    · exact ht' x hx
  · intro x hx
    rcases Multiset.mem_add.mp hx with hx | hx
    · exact hs' x hx
    · exact ht x hx
  · rw [Multiset.card_add, hcs, hct']; omega
  · rw [Multiset.card_add, hcs', hct]; omega
  · rw [Multiset.sum_add, Multiset.sum_add]; exact hsum

/-- **`h`-fold difference rigidity implies `B_h`.** -/
theorem IsDiffBh.isBh {h : ℕ} {A : Finset M} (hA : IsDiffBh h A) : IsBh h A := by
  intro s t hs ht hcs hct hsum
  classical
  have key : s + s = t + t := hA s t t s hs ht ht hs hcs hct hct hcs (by rw [hsum])
  -- cancel: `2s = 2t` forces `s = t`
  refine Multiset.ext.mpr fun x => ?_
  have hcount := congrArg (Multiset.count x) key
  simp only [Multiset.count_add] at hcount
  omega

/-- **The difference sandwich**: `B_{2h} ⟹ Diff_h ⟹ B_h`. -/
theorem isBh_of_isDiffBh_of_isBh_two_mul {h : ℕ} {A : Finset M} (hA : IsBh (2 * h) A) :
    IsDiffBh h A ∧ IsBh h A :=
  ⟨hA.isDiffBh, hA.isDiffBh.isBh⟩

/-- Any multiset can be split into a part of prescribed size and a remainder. -/
theorem exists_split {α : Type*} (k : ℕ) : ∀ u : Multiset α, k ≤ Multiset.card u →
    ∃ s t : Multiset α, u = s + t ∧ Multiset.card s = k := by
  induction k with
  | zero => intro u _; exact ⟨0, u, by simp, by simp⟩
  | succ k ih =>
      intro u hk
      have hpos : 0 < Multiset.card u := by omega
      obtain ⟨a, ha⟩ := Multiset.card_pos_iff_exists_mem.mp hpos
      obtain ⟨u', rfl⟩ := Multiset.exists_cons_of_mem ha
      have hk' : k ≤ Multiset.card u' := by
        rw [Multiset.card_cons] at hk; omega
      obtain ⟨s, t, hu, hcs⟩ := ih u' hk'
      exact ⟨a ::ₘ s, t, by rw [Multiset.cons_add, ← hu], by rw [Multiset.card_cons, hcs]⟩

/-- **`h`-fold difference rigidity implies `B_{2h}`.**  Split each of the two `2h`-element
multisets into two halves and apply rigidity to the resulting formal difference. -/
theorem IsDiffBh.isBh_two_mul {h : ℕ} {A : Finset M} (hA : IsDiffBh h A) : IsBh (2 * h) A := by
  intro u v hu hv hcu hcv hsum
  obtain ⟨s, t', hus, hcs⟩ := exists_split h u (by omega)
  obtain ⟨s', t, hvs, hcs'⟩ := exists_split h v (by omega)
  have hct' : Multiset.card t' = h := by
    have := congrArg Multiset.card hus
    rw [Multiset.card_add, hcs] at this; omega
  have hct : Multiset.card t = h := by
    have := congrArg Multiset.card hvs
    rw [Multiset.card_add, hcs'] at this; omega
  have hsA : ∀ x ∈ s, x ∈ A := fun x hx => hu x (by rw [hus]; exact Multiset.mem_add.mpr (Or.inl hx))
  have ht'A : ∀ x ∈ t', x ∈ A :=
    fun x hx => hu x (by rw [hus]; exact Multiset.mem_add.mpr (Or.inr hx))
  have hs'A : ∀ x ∈ s', x ∈ A :=
    fun x hx => hv x (by rw [hvs]; exact Multiset.mem_add.mpr (Or.inl hx))
  have htA : ∀ x ∈ t, x ∈ A :=
    fun x hx => hv x (by rw [hvs]; exact Multiset.mem_add.mpr (Or.inr hx))
  have hsum' : s.sum + t'.sum = s'.sum + t.sum := by
    rw [← Multiset.sum_add, ← Multiset.sum_add, ← hus, ← hvs]; exact hsum
  have := hA s t s' t' hsA htA hs'A ht'A hcs hct hcs' hct' hsum'
  rw [hus, hvs]; exact this

/-- **The difference characterisation of `B_{2h}`.**  `h`-fold difference rigidity is not
merely sandwiched between two layers of the tower: it *is* the layer `B_{2h}`.  For
`h = 1` this says that distinctness of the differences `a i - a j` is exactly the Sidon
(= `B₂`) property. -/
theorem isDiffBh_iff_isBh_two_mul {h : ℕ} {A : Finset M} : IsDiffBh h A ↔ IsBh (2 * h) A :=
  ⟨fun hA => hA.isBh_two_mul, fun hA => hA.isDiffBh⟩

/-- **The bottom floor of the tower is exactly the Sidon property**: rigidity of single
differences `a - b` is `B₂`. -/
theorem isDiffBh_one_iff_isSidon (A : Finset M) : IsDiffBh 1 A ↔ IsSidon A := by
  constructor
  · intro hD a ha b hb c hc d hd habcd
    have h1 : ({a} : Multiset M) + {b} = {c} + {d} := by
      refine hD {a} {d} {c} {b} ?_ ?_ ?_ ?_ (by simp) (by simp) (by simp) (by simp) ?_
      · intro x hx; rw [Multiset.mem_singleton.mp hx]; exact ha
      · intro x hx; rw [Multiset.mem_singleton.mp hx]; exact hd
      · intro x hx; rw [Multiset.mem_singleton.mp hx]; exact hc
      · intro x hx; rw [Multiset.mem_singleton.mp hx]; exact hb
      · simpa using habcd
    have h2 : ({a, b} : Multiset M) = {c, d} := by
      simpa [Multiset.insert_eq_cons, Multiset.singleton_add] using h1
    have hmem : a ∈ ({c, d} : Multiset M) := h2 ▸ (by simp)
    simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hmem
    rcases hmem with rfl | rfl
    · left
      refine ⟨rfl, ?_⟩
      rw [Multiset.insert_eq_cons, Multiset.insert_eq_cons, Multiset.cons_inj_right] at h2
      simpa using h2
    · right
      refine ⟨rfl, ?_⟩
      rw [Multiset.pair_comm] at h2
      simpa using h2
  · intro hA s t s' t' hs ht hs' ht' hcs hct hcs' hct' hsum
    obtain ⟨a, rfl⟩ := Multiset.card_eq_one.mp hcs
    obtain ⟨b, rfl⟩ := Multiset.card_eq_one.mp hct
    obtain ⟨c, rfl⟩ := Multiset.card_eq_one.mp hcs'
    obtain ⟨d, rfl⟩ := Multiset.card_eq_one.mp hct'
    have ha : a ∈ A := hs a (by simp)
    have hb : b ∈ A := ht b (by simp)
    have hc : c ∈ A := hs' c (by simp)
    have hd : d ∈ A := ht' d (by simp)
    have hsum' : a + d = c + b := by simpa using hsum
    rcases hA a ha d hd c hc b hb hsum' with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · rw [h1, h2]
    · rw [h1, h2]; exact add_comm _ _

end General

/-! ## The counting bound for `B_h` subsets of an interval -/

section Counting

/-- **Counting bound for `B_h` sets.**  A `B_h` subset of `{0, …, N-1}` satisfies
`C(|A|, h) ≤ h(N-1) + 1`: the `C(|A|, h)` subsets of size `h` have pairwise distinct sums,
all lying in `{0, …, h(N-1)}`. -/
theorem IsBh.choose_card_le {h N : ℕ} {A : Finset ℕ} (hA : IsBh h A)
    (hsub : A ⊆ Finset.range N) : (#A).choose h ≤ h * (N - 1) + 1 := by
  classical
  have hinj : Set.InjOn (fun S : Finset ℕ => ∑ x ∈ S, x)
      ((A.powersetCard h : Finset (Finset ℕ)) : Set (Finset ℕ)) := by
    intro S hS T hT hST
    simp only [Finset.mem_coe, Finset.mem_powersetCard] at hS hT
    have hSv : ∀ x ∈ S.val, x ∈ A := fun x hx => hS.1 hx
    have hTv : ∀ x ∈ T.val, x ∈ A := fun x hx => hT.1 hx
    have e1 : (∑ x ∈ S, x) = S.val.sum := by
      rw [Finset.sum_eq_multiset_sum, Multiset.map_id']
    have e2 : (∑ x ∈ T, x) = T.val.sum := by
      rw [Finset.sum_eq_multiset_sum, Multiset.map_id']
    have hsum : S.val.sum = T.val.sum := by rw [← e1, ← e2]; exact hST
    have := hA S.val T.val hSv hTv (by simpa using hS.2) (by simpa using hT.2) hsum
    exact Finset.val_injective this
  have hmaps : Set.MapsTo (fun S : Finset ℕ => ∑ x ∈ S, x)
      ((A.powersetCard h : Finset (Finset ℕ)) : Set (Finset ℕ))
      ((Finset.range (h * (N - 1) + 1) : Finset ℕ) : Set ℕ) := by
    intro S hS
    simp only [Finset.mem_coe, Finset.mem_powersetCard] at hS
    simp only [Finset.mem_coe]
    rw [Finset.mem_range, Nat.lt_succ_iff]
    calc ∑ x ∈ S, x ≤ #S * (N - 1) := by
          refine Finset.sum_le_card_nsmul S id (N - 1) ?_
          intro x hx
          have : x < N := Finset.mem_range.mp (hsub (hS.1 hx))
          simp only [id]; omega
      _ = h * (N - 1) := by rw [hS.2]
  have := Finset.card_le_card_of_injOn _ hmaps hinj
  rwa [Finset.card_powersetCard, Finset.card_range] at this

/-- `(n - k + 1)^k ≤ n.descFactorial k`: every factor of the descending factorial is at
least `n - k + 1`. -/
theorem pow_le_descFactorial (n : ℕ) : ∀ k ≤ n, (n - k + 1) ^ k ≤ n.descFactorial k
  | 0, _ => by simp
  | k + 1, hk => by
      have hk' : k ≤ n := by omega
      have ih := pow_le_descFactorial n k hk'
      have hstep : (n - (k + 1) + 1) ^ k ≤ (n - k + 1) ^ k :=
        Nat.pow_le_pow_left (by omega) k
      rw [Nat.descFactorial_succ]
      calc (n - (k + 1) + 1) ^ (k + 1)
          = (n - k) * (n - (k + 1) + 1) ^ k := by
            rw [pow_succ]
            have : n - (k + 1) + 1 = n - k := by omega
            rw [this]; ring
        _ ≤ (n - k) * n.descFactorial k := Nat.mul_le_mul_left _ (le_trans hstep ih)

/-- **`B_h` upper bound in usable form.**  A `B_h` subset `A ⊆ {0, …, N-1}` with `h ≤ |A|`
satisfies `(|A| - h + 1)^h ≤ h! · (h(N-1) + 1)`; equivalently `|A| ≲ (h!·h·N)^{1/h} + h`.
For `h = 2` this is the Erdős–Turán order of magnitude `√N`. -/
theorem IsBh.pow_card_sub_le {h N : ℕ} {A : Finset ℕ} (hA : IsBh h A)
    (hsub : A ⊆ Finset.range N) (hh : h ≤ #A) :
    (#A - h + 1) ^ h ≤ Nat.factorial h * (h * (N - 1) + 1) := by
  have h1 : (#A - h + 1) ^ h ≤ (#A).descFactorial h := pow_le_descFactorial _ h hh
  have h2 : (#A).descFactorial h = Nat.factorial h * (#A).choose h :=
    Nat.descFactorial_eq_factorial_mul_choose _ _
  have h3 := hA.choose_card_le hsub
  calc (#A - h + 1) ^ h ≤ (#A).descFactorial h := h1
    _ = Nat.factorial h * (#A).choose h := h2
    _ ≤ Nat.factorial h * (h * (N - 1) + 1) := Nat.mul_le_mul_left _ h3

end Counting

end BhDifference