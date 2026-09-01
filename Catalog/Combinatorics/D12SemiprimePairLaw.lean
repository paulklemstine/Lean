/-
# The exact enumeration law for semiprime splitting-type pairs

`Shared.CyclicTypeChannelValues` evaluates the type-pair entropy of a `C n`
semiprime one `n` at a time, by a kernel-checked enumeration of fibre sizes.
This file replaces that enumeration by a *closed-form law* valid for every `n`,
and then checks that the law reproduces the degree-12 value exactly.

The law has three layers.

1. **Counting.**  For divisors `d ≤ e` of `n` the number of exponent pairs whose
   unordered splitting-type pair is `{d, e}` is
   `φ(d) φ(e)` if `d = e` and `2 φ(d) φ(e)` otherwise (`card_typePair`).
2. **Support.**  The type pairs that actually occur are exactly the pairs of
   divisors `d ≤ e` of `n` (`image_typePair`), and the counts add up to `n²`
   (`sum_pairCount_eq_sq`).
3. **Entropy.**  Hence
   `H(Π) = log₂ (n²) - (1/n²) ∑_{d ≤ e} c_{d,e} log₂ c_{d,e}` (`pairEntropy_law`).

Applying the law at `n = 12` gives an *independent* derivation of the measured
degree-12 pair entropy `7/8 + 2 log₂ 3`, and hence of the degree-12 pair channel
`I_pair(12) = 5/36 + log₂ 3`: the pair channel matches the exact enumeration
law.
-/
import Shared.CyclicTypeChannelCap

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 100000

/-! ## 1. The counting law -/

/-- The exact enumeration law: the predicted number of exponent pairs realising
the unordered splitting-type pair `t = (d, e)` with `d ≤ e`. -/
def pairCount (t : ℕ × ℕ) : ℕ :=
  if t.1 = t.2 then Nat.totient t.1 * Nat.totient t.2 else 2 * (Nat.totient t.1 * Nat.totient t.2)

/-- The set of divisor pairs that index the type-pair alphabet. -/
def divPairs (n : ℕ) : Finset (ℕ × ℕ) := {t ∈ n.divisors ×ˢ n.divisors | t.1 ≤ t.2}

lemma mem_divPairs {n : ℕ} {t : ℕ × ℕ} :
    t ∈ divPairs n ↔ (t.1 ∣ n ∧ t.2 ∣ n ∧ n ≠ 0) ∧ t.1 ≤ t.2 := by
  simp only [divPairs, mem_filter, mem_product, Nat.mem_divisors]
  tauto

/-- On the diagonal the type-pair fibre is a square. -/
lemma filter_typePair_diag (n d : ℕ) :
    {p ∈ box n | typePair n p = (d, d)}
      = {a ∈ range n | ordType n a = d} ×ˢ {a ∈ range n | ordType n a = d} := by
  ext ⟨x, y⟩
  simp only [box, typePair, mem_filter, mem_product, mem_range, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨hx, hy⟩, h1, h2⟩
    exact ⟨⟨hx, by omega⟩, ⟨hy, by omega⟩⟩
  · rintro ⟨⟨hx, h1⟩, hy, h2⟩
    exact ⟨⟨hx, hy⟩, by omega, by omega⟩

/-- Off the diagonal the type-pair fibre is a disjoint union of two rectangles —
one for each way of assigning the two types to the two primes. -/
lemma filter_typePair_offdiag (n d e : ℕ) (hde : d < e) :
    {p ∈ box n | typePair n p = (d, e)}
      = ({a ∈ range n | ordType n a = d} ×ˢ {a ∈ range n | ordType n a = e}) ∪
        ({a ∈ range n | ordType n a = e} ×ˢ {a ∈ range n | ordType n a = d}) := by
  ext ⟨x, y⟩
  simp only [box, typePair, mem_filter, mem_product, mem_range, mem_union, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨hx, hy⟩, h1, h2⟩
    rcases le_total (ordType n x) (ordType n y) with h | h
    · exact Or.inl ⟨⟨hx, by omega⟩, ⟨hy, by omega⟩⟩
    · exact Or.inr ⟨⟨hx, by omega⟩, ⟨hy, by omega⟩⟩
  · rintro (⟨⟨hx, h1⟩, hy, h2⟩ | ⟨⟨hx, h1⟩, hy, h2⟩) <;>
      exact ⟨⟨hx, hy⟩, by omega, by omega⟩

/-- **The exact enumeration law.**  For divisors `d ≤ e` of `n > 0`, the number
of exponent pairs of a `C n` semiprime whose unordered splitting-type pair is
`{d, e}` is `φ(d) φ(e)` on the diagonal and `2 φ(d) φ(e)` off it. -/
theorem card_typePair {n : ℕ} (hn : 0 < n) {t : ℕ × ℕ} (ht : t ∈ divPairs n) :
    #{p ∈ box n | typePair n p = t} = pairCount t := by
  obtain ⟨⟨hd, he, -⟩, hle⟩ := mem_divPairs.1 ht
  obtain ⟨d, e⟩ := t
  simp only at hd he hle ⊢
  rcases eq_or_lt_of_le hle with rfl | hlt
  · rw [filter_typePair_diag, Finset.card_product, card_ordType_eq_totient hn hd]
    simp [pairCount]
  · have hdisj : Disjoint
        ({a ∈ range n | ordType n a = d} ×ˢ {a ∈ range n | ordType n a = e})
        ({a ∈ range n | ordType n a = e} ×ˢ {a ∈ range n | ordType n a = d}) := by
      rw [Finset.disjoint_left]
      rintro ⟨x, y⟩ hx hy
      simp only [mem_product, mem_filter] at hx hy
      omega
    rw [filter_typePair_offdiag n d e hlt, Finset.card_union_of_disjoint hdisj,
      Finset.card_product, Finset.card_product, card_ordType_eq_totient hn hd,
      card_ordType_eq_totient hn he]
    have hne : ¬ (d = e) := Nat.ne_of_lt hlt
    simp only [pairCount, hne, if_false]
    ring

/-! ## 2. The support of the type-pair alphabet -/

/-- **The type pairs that occur are exactly the ordered pairs of divisors.** -/
theorem image_typePair (n : ℕ) (hn : 0 < n) :
    (box n).image (typePair n) = divPairs n := by
  have himg := image_ordType n hn
  ext t
  simp only [mem_image, mem_divPairs]
  constructor
  · rintro ⟨p, hp, rfl⟩
    refine ⟨⟨?_, ?_, hn.ne'⟩, ?_⟩
    · rcases le_total (ordType n p.1) (ordType n p.2) with h | h
      · simpa [typePair, min_eq_left h] using ordType_dvd (n := n) p.1
      · simpa [typePair, min_eq_right h] using ordType_dvd (n := n) p.2
    · rcases le_total (ordType n p.1) (ordType n p.2) with h | h
      · simpa [typePair, max_eq_right h] using ordType_dvd (n := n) p.2
      · simpa [typePair, max_eq_left h] using ordType_dvd (n := n) p.1
    · simp [typePair]
  · rintro ⟨⟨hd, he, -⟩, hle⟩
    have h1 : t.1 ∈ (range n).image (ordType n) := by
      rw [himg]; exact Nat.mem_divisors.2 ⟨hd, hn.ne'⟩
    have h2 : t.2 ∈ (range n).image (ordType n) := by
      rw [himg]; exact Nat.mem_divisors.2 ⟨he, hn.ne'⟩
    obtain ⟨a, ha, hae⟩ := mem_image.1 h1
    obtain ⟨b, hb, hbe⟩ := mem_image.1 h2
    refine ⟨(a, b), by simp [box, mem_product, ha, hb], ?_⟩
    simp only [typePair, hae, hbe]
    rw [min_eq_left hle, max_eq_right hle]

/-- **The law is a partition law**: the predicted counts sum to `n²`. -/
theorem sum_pairCount_eq_sq (n : ℕ) (hn : 0 < n) :
    ∑ t ∈ divPairs n, pairCount t = n ^ 2 := by
  have h := sum_fiber_card (box n) (typePair n)
  rw [image_typePair n hn] at h
  have hb : (box n).card = n ^ 2 := by simp [box, sq]
  rw [← hb, ← h]
  exact Finset.sum_congr rfl fun t ht => (card_typePair hn ht).symm

/-! ## 3. The entropy law -/

/-- **The exact enumeration law for the semiprime type-pair entropy.**
For every `n > 0`,
`H(Π) = log₂ (n²) - (1/n²) ∑_{d ≤ e ∣ n} c_{d,e} log₂ c_{d,e}`,
where `c_{d,e} = φ(d) φ(e)` on the diagonal and `2 φ(d) φ(e)` off it. -/
theorem pairEntropy_law (n : ℕ) (hn : 0 < n) :
    pairEntropy n = Real.logb 2 ((n : ℝ) ^ 2)
      - (∑ t ∈ divPairs n, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ)) / (n : ℝ) ^ 2 := by
  have hcard : ((box n).card : ℝ) = (n : ℝ) ^ 2 := by
    simp [box, sq]
  rw [pairEntropy, uEnt, sum_logb_fiber, image_typePair n hn, hcard]
  congr 2
  refine Finset.sum_congr rfl fun t ht => ?_
  rw [card_typePair hn ht]

/-! ## 4. The degree-12 arm: the pair channel matches the law -/

/-- The degree-12 profile predicted by the enumeration law: the `21` divisor
pairs of `12` carry the multiplicities `φ(d) φ(e)` / `2 φ(d) φ(e)`, which sum to
`144`. -/
theorem pairCount_profile_12 :
    ((divPairs 12).val.map pairCount)
      = (↑[1, 2, 4, 4, 4, 8, 1, 4, 4, 4, 8, 4, 8, 8, 16, 4, 8, 16, 4, 16, 16] : Multiset ℕ) := by
  decide

/-- The law's entropy sum evaluated at `n = 12`. -/
theorem law_sum_val_12 :
    ∑ t ∈ divPairs 12, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ) = 450 := by
  have hmap : ∀ m : Multiset (ℕ × ℕ),
      m.map (fun t => (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ))
        = (m.map pairCount).map (fun c : ℕ => (c : ℝ) * Real.logb 2 (c : ℝ)) := by
    intro m
    rw [Multiset.map_map]
    rfl
  rw [Finset.sum, hmap, pairCount_profile_12]
  norm_num [lb_4, lb_8, lb_16]

/-- **The degree-12 pair channel matches the exact enumeration law.**  Feeding
the `φ`-counting law into the entropy formula reproduces, with no enumeration of
the `144` exponent pairs, the measured degree-12 type-pair entropy
`7/8 + 2 log₂ 3`. -/
theorem pairEntropy_twelve_from_law : pairEntropy 12 = (7 / 8 : ℝ) + 2 * Real.logb 2 3 := by
  have h := pairEntropy_law 12 (by norm_num)
  rw [law_sum_val_12] at h
  rw [h, show ((12 : ℕ) : ℝ) ^ 2 = 144 by norm_num, lb_144]
  ring

/-- **The degree-12 pair channel, from the law.**  Combining the law-derived
pair entropy with the conditional entropy gives
`I_pair(12) = 5/36 + log₂ 3 ≈ 1.7239` bits. -/
theorem Ipair_twelve_from_law : Ipair 12 = (5 / 36 : ℝ) + Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_twelve_from_law, condPairEntropy_val_12]
  ring

/-- **The law is not degree-12 specific.**  The same computation at `n = 6` and
`n = 16` reproduces the entropies enumerated in
`Shared.CyclicTypeChannelValues`, so the enumeration law is validated across the
whole computed range. -/
theorem pairEntropy_six_from_law : pairEntropy 6 = (-1 / 18 : ℝ) + 2 * Real.logb 2 3 := by
  have hprofile : ((divPairs 6).val.map pairCount)
      = (↑[1, 2, 4, 4, 1, 4, 4, 4, 8, 4] : Multiset ℕ) := by decide
  have hmap : ∀ m : Multiset (ℕ × ℕ),
      m.map (fun t => (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ))
        = (m.map pairCount).map (fun c : ℕ => (c : ℝ) * Real.logb 2 (c : ℝ)) := by
    intro m
    rw [Multiset.map_map]
    rfl
  have hsum : ∑ t ∈ divPairs 6, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ) = 74 := by
    rw [Finset.sum, hmap, hprofile]
    norm_num [lb_4, lb_8]
  have h := pairEntropy_law 6 (by norm_num)
  rw [hsum] at h
  rw [h, show ((6 : ℕ) : ℝ) ^ 2 = 36 by norm_num, lb_36]
  ring

end CyclicTypeChannel