/-
# The CRT defect law of the hint map

Cycle 2 of SEXTIC-HINT-VALUE (paper 121).  `Physics.SexticHintValue` proved the round-31 hint
value `log₂ 3 + 1/18` at degree 6 and observed, at the four coprime composite degrees available
in the catalog (`6, 10, 12, 15`), that the hint map is *superadditive* with a defect equal to a
product of two type-distinctness probabilities.  This file proves that observation as a
general law.

## Main results

* `uEnt_unordered` — **the unordered-pair entropy law**: for any read-out `g` of a uniform
  i.i.d. pair, `H({g x, g y}) = H(g x, g y) - P(g x ≠ g y)` (bits).  Forgetting the order
  costs exactly one bit on the off-diagonal and nothing on the diagonal.
* `pairEntropy_eq` — the label entropy of the cyclic channel:
  `pairEntropy n = 2 · typeEntropy n - δ(n)`.
* `sameCount_mul`, `one_sub_distinctProb_mul` — the CRT relabelling `crtMap` preserves type
  equality (`same_type_crt`), so the equal-type count is multiplicative and
  `1 - δ(m n) = (1 - δ(m))(1 - δ(n))`.
* `hintMap_mul_of_coprime` — **THE CRT DEFECT LAW**: for coprime positive `m, n`,
  `hintMap (m n) = hintMap m + hintMap n + δ(m) δ(n)`.
  Proof: the product channel `Ipair` (`Ipair_mul_of_coprime`) and the type entropy
  (`typeEntropy_mul_of_coprime`) are exactly additive; only the unordered-pair correction
  `-δ` is not, and its non-additivity is `δ(m) + δ(n) - δ(m n) = δ(m) δ(n)`.
* `hintMap_strict_superadditive` — for coprime `m, n ≥ 2` the inequality is strict
  (`distinctProb_pos`): every coprime composite rung carries more hint than its components.
* `sameCount_eq_sum_totient_sq`, `distinctProb_eq_totient`, `hintMap_mul_totient` — the
  defect in closed arithmetic form, `δ(n) = 1 - (∑_{d ∣ n} φ(d)²)/n²`, and the arithmetic
  corollary `sum_totient_sq_mul`: `n ↦ ∑_{d ∣ n} φ(d)²` is multiplicative, obtained from the
  information-theoretic CRT structure.
* `hintMap_six_defect` — the degree-6 instance, defect `2/9`.
-/
import Physics.SexticHintValue
import Shared.CyclicTypeChannelProduct

namespace SexticHintValue

open Finset CyclicTypeChannel

/-- Unordered pairs in a linear order: `{p, q} = {u, w}` iff `(p, q)` is `(u, w)` or `(w, u)`. -/
theorem minmax_eq_iff {β : Type*} [LinearOrder β] (p q u w : β) :
    (min p q, max p q) = (min u w, max u w) ↔ (p, q) = (u, w) ∨ (p, q) = (w, u) := by
  simp only [Prod.mk.injEq]
  constructor
  · rintro ⟨h1, h2⟩
    rcases le_total p q with hpq | hpq <;> rcases le_total u w with huw | huw <;>
      simp only [min_eq_left, min_eq_right, max_eq_left, max_eq_right, hpq, huw] at h1 h2 <;>
      subst h1 h2 <;> simp
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨rfl, rfl⟩
    · exact ⟨min_comm _ _, max_comm _ _⟩

/-- **The unordered-pair entropy law.**  Forgetting the order of an i.i.d. pair of read-outs
removes exactly the probability that the two read-outs differ (in bits):
`H({g(x), g(y)}) = H(g(x), g(y)) - P(g(x) ≠ g(y))`. -/
theorem uEnt_unordered {α β : Type*} [DecidableEq α] [LinearOrder β] (s : Finset α) (g : α → β) :
    uEnt (s ×ˢ s) (fun x => (min (g x.1) (g x.2), max (g x.1) (g x.2)))
      = uEnt (s ×ˢ s) (fun x => (g x.1, g x.2))
        - (#{x ∈ s ×ˢ s | g x.1 ≠ g x.2} : ℝ) / (s ×ˢ s).card := by
  set S := s ×ˢ s with hS
  have hpt : ∀ a ∈ S,
      Real.logb 2 (#{x ∈ S | (min (g x.1) (g x.2), max (g x.1) (g x.2))
          = (min (g a.1) (g a.2), max (g a.1) (g a.2))} : ℝ)
      = Real.logb 2 (#{x ∈ S | (g x.1, g x.2) = (g a.1, g a.2)} : ℝ)
        + (if g a.1 ≠ g a.2 then 1 else 0) := by
    intro a ha
    have hfib : {x ∈ S | (min (g x.1) (g x.2), max (g x.1) (g x.2))
          = (min (g a.1) (g a.2), max (g a.1) (g a.2))}
        = {x ∈ S | (g x.1, g x.2) = (g a.1, g a.2)} ∪ {x ∈ S | (g x.1, g x.2) = (g a.2, g a.1)} := by
      ext x
      simp only [mem_filter, mem_union, minmax_eq_iff]
      tauto
    have hswap : #{x ∈ S | (g x.1, g x.2) = (g a.2, g a.1)}
        = #{x ∈ S | (g x.1, g x.2) = (g a.1, g a.2)} := by
      refine Finset.card_nbij' Prod.swap Prod.swap ?_ ?_ ?_ ?_
      · intro x hx
        simp only [hS, coe_filter, mem_product, Set.mem_setOf_eq, Prod.fst_swap, Prod.snd_swap,
          Prod.mk.injEq] at hx ⊢
        exact ⟨⟨hx.1.2, hx.1.1⟩, hx.2.2, hx.2.1⟩
      · intro x hx
        simp only [hS, coe_filter, mem_product, Set.mem_setOf_eq, Prod.fst_swap, Prod.snd_swap,
          Prod.mk.injEq] at hx ⊢
        exact ⟨⟨hx.1.2, hx.1.1⟩, hx.2.2, hx.2.1⟩
      · intro x _; rfl
      · intro x _; rfl
    have hpos : (0 : ℝ) < #{x ∈ S | (g x.1, g x.2) = (g a.1, g a.2)} := by
      exact_mod_cast card_pos.2 ⟨a, by simp [ha]⟩
    split_ifs with hne
    · have hdisj : Disjoint {x ∈ S | (g x.1, g x.2) = (g a.1, g a.2)}
          {x ∈ S | (g x.1, g x.2) = (g a.2, g a.1)} := by
        rw [Finset.disjoint_filter]
        intro x _ h1 h2
        rw [h1, Prod.mk.injEq] at h2
        exact hne h2.1
      rw [hfib, card_union_of_disjoint hdisj, hswap]
      push_cast
      rw [← two_mul, Real.logb_mul (by norm_num) hpos.ne', Real.logb_self_eq_one (by norm_num)]
      ring
    · push_neg at hne
      rw [hfib, hne, union_self]
      ring
  rw [uEnt, uEnt, sum_congr rfl hpt, sum_add_distrib, Finset.sum_boole]
  simp only [ne_eq]
  rw [add_div]
  ring

/-- `hintMap n = pairEntropy n - Ipair n`. -/
theorem hintMap_eq_sub (n : ℕ) : hintMap n = pairEntropy n - Ipair n := by
  rw [hintMap, mutInfo_box_id]

theorem card_box_real (n : ℕ) : ((CyclicTypeChannel.box n).card : ℝ) = (n : ℝ) ^ 2 := by
  simp only [CyclicTypeChannel.box, card_product, card_range]
  push_cast
  ring

/-- **The label entropy of the cyclic channel**: the unordered type pair carries twice the
single-prime type entropy, minus the type-distinctness probability. -/
theorem pairEntropy_eq {n : ℕ} (hn : 0 < n) :
    pairEntropy n = 2 * typeEntropy n - distinctProb n := by
  have hr : (range n).Nonempty := ⟨0, by simp [hn]⟩
  have h := uEnt_unordered (range n) (ordType n)
  rw [uEnt_prod hr hr] at h
  rw [pairEntropy, distinctProb, ← card_box_real]
  change uEnt (range n ×ˢ range n) _ = _
  rw [show (typePair n) = (fun x : ℕ × ℕ => (min (ordType n x.1) (ordType n x.2),
      max (ordType n x.1) (ordType n x.2))) from rfl, h, typeEntropy]
  simp only [CyclicTypeChannel.box]
  ring

/-- The number of exponent pairs with *equal* splitting types. -/
def sameCount (n : ℕ) : ℕ := #{x ∈ CyclicTypeChannel.box n | ordType n x.1 = ordType n x.2}

theorem one_sub_distinctProb {n : ℕ} (hn : 0 < n) :
    1 - distinctProb n = (sameCount n : ℝ) / (n : ℝ) ^ 2 := by
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := CyclicTypeChannel.box n) (fun x : ℕ × ℕ => ordType n x.1 = ordType n x.2)
  have hc : ((#{x ∈ CyclicTypeChannel.box n | ordType n x.1 = ordType n x.2} : ℕ) : ℝ)
      + ((#{x ∈ CyclicTypeChannel.box n | ¬ ordType n x.1 = ordType n x.2} : ℕ) : ℝ)
      = (n : ℝ) ^ 2 := by
    rw [← card_box_real]; exact_mod_cast hsplit
  have hn2 : (0 : ℝ) < (n : ℝ) ^ 2 := by positivity
  rw [distinctProb, sameCount]
  simp only [ne_eq]
  field_simp
  linarith

/-- The CRT relabelling respects type equality: two exponents mod `m n` have the same type iff
their residues mod `m` and mod `n` both do. -/
theorem same_type_crt {m n : ℕ} (hm : 0 < m) (h : Nat.Coprime m n) (a b : ℕ) :
    ordType (m * n) a = ordType (m * n) b ↔
      ordType m (a % m) = ordType m (b % m) ∧ ordType n (a % n) = ordType n (b % n) := by
  rw [ordType_mod, ordType_mod, ordType_mod, ordType_mod, ordType_mul_of_coprime h,
    ordType_mul_of_coprime h]
  constructor
  · intro he
    exact eq_of_mul_eq_mul_coprime h hm (ordType_dvd _) (ordType_dvd _) (ordType_dvd _)
      (ordType_dvd _) he
  · rintro ⟨h1, h2⟩
    rw [h1, h2]

/-- **The equal-type count is multiplicative** over coprime orders. -/
theorem sameCount_mul {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    sameCount (m * n) = sameCount m * sameCount n := by
  classical
  rw [sameCount, ← card_image_of_injOn ((crtMap_injOn h).mono (by
    intro x hx; exact (mem_filter.1 hx).1))]
  have himg : ({x ∈ CyclicTypeChannel.box (m * n) | ordType (m * n) x.1 = ordType (m * n) x.2}
      ).image (crtMap m n)
      = {x ∈ CyclicTypeChannel.box m | ordType m x.1 = ordType m x.2} ×ˢ
        {x ∈ CyclicTypeChannel.box n | ordType n x.1 = ordType n x.2} := by
    rw [← filter_product, ← image_crtMap hm hn h, Finset.filter_image]
    congr 1
    refine Finset.filter_congr fun x _ => ?_
    simp only [crtMap]
    exact same_type_crt hm h x.1 x.2
  rw [himg, card_product, sameCount, sameCount]

/-- **Distinctness complements multiply**: `1 - δ(m n) = (1 - δ(m)) (1 - δ(n))`. -/
theorem one_sub_distinctProb_mul {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    1 - distinctProb (m * n) = (1 - distinctProb m) * (1 - distinctProb n) := by
  rw [one_sub_distinctProb (Nat.mul_pos hm hn), one_sub_distinctProb hm, one_sub_distinctProb hn,
    sameCount_mul hm hn h]
  push_cast
  have : (m : ℝ) ≠ 0 := by positivity
  have : (n : ℝ) ≠ 0 := by positivity
  field_simp

/-- **THE CRT DEFECT LAW OF THE HINT MAP.**  For coprime positive orders `m, n`,
`hintMap (m n) = hintMap m + hintMap n + δ(m) δ(n)`,
where `δ(k)` is the probability that two uniformly random exponents mod `k` have different
splitting types.  The product channel `Ipair` and the type entropy are exactly CRT-additive;
the whole defect comes from forgetting the order of the pair, and it equals the probability
that the pair is "doubly distinct" (distinct in both CRT components). -/
theorem hintMap_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    hintMap (m * n) = hintMap m + hintMap n + distinctProb m * distinctProb n := by
  have hd := one_sub_distinctProb_mul hm hn h
  rw [hintMap_eq_sub, hintMap_eq_sub, hintMap_eq_sub, pairEntropy_eq (Nat.mul_pos hm hn),
    pairEntropy_eq hm, pairEntropy_eq hn, typeEntropy_mul_of_coprime hm hn h,
    Ipair_mul_of_coprime hm hn h]
  linear_combination hd

/-- **Superadditivity.**  Over coprime components the hint map is superadditive. -/
theorem hintMap_superadditive {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    hintMap m + hintMap n ≤ hintMap (m * n) := by
  have h1 : 0 ≤ distinctProb m := by unfold distinctProb; positivity
  have h2 : 0 ≤ distinctProb n := by unfold distinctProb; positivity
  rw [hintMap_mul_of_coprime hm hn h]
  nlinarith [mul_nonneg h1 h2]

/-- Two splitting types always occur once `n ≥ 2` (the exponents `0` and `1` have types `1`
and `n`), so the distinctness probability is positive. -/
theorem distinctProb_pos {n : ℕ} (hn : 2 ≤ n) : 0 < distinctProb n := by
  unfold distinctProb
  have hmem : ((0, 1) : ℕ × ℕ) ∈
      ({x ∈ CyclicTypeChannel.box n | ordType n x.1 ≠ ordType n x.2} : Finset (ℕ × ℕ)) := by
    simp only [mem_filter, CyclicTypeChannel.box, mem_product, mem_range, ordType,
      Nat.gcd_zero_left, Nat.gcd_one_left, Nat.div_one]
    refine ⟨⟨by omega, by omega⟩, ?_⟩
    rw [Nat.div_self (by omega)]
    omega
  have : (0 : ℝ) < (#{x ∈ CyclicTypeChannel.box n | ordType n x.1 ≠ ordType n x.2} : ℕ) := by
    exact_mod_cast card_pos.2 ⟨_, hmem⟩
  have hn0 : (0 : ℝ) < (n : ℝ) ^ 2 := by
    have : (0 : ℝ) < n := by exact_mod_cast (by omega : 0 < n)
    positivity
  exact div_pos this hn0

/-- **THE-HINT-EXTENDS-BEYOND-DEGREE-5, general form.**  Every composite rung `m n` with
coprime non-trivial components carries strictly more hint value than its two components
together. -/
theorem hintMap_strict_superadditive {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) (h : Nat.Coprime m n) :
    hintMap m + hintMap n < hintMap (m * n) := by
  rw [hintMap_mul_of_coprime (by omega) (by omega) h]
  have := mul_pos (distinctProb_pos hm) (distinctProb_pos hn)
  linarith

/-- The general law recovers the degree-6 defect `2/9`. -/
theorem hintMap_six_defect : hintMap 6 - hintMap 2 - hintMap 3 = 2 / 9 := by
  have := hintMap_mul_of_coprime (m := 2) (n := 3) (by norm_num) (by norm_num) (by norm_num)
  norm_num at this
  rw [this, distinctProb_two, distinctProb_three]
  ring

/-- Collision count of an i.i.d. pair: `#{(x, y) : g x = g y} = ∑_v #{g = v}²`. -/
theorem card_diag_eq_sum_sq {α β : Type*} [DecidableEq α] [DecidableEq β]
    (s : Finset α) (g : α → β) :
    #{x ∈ s ×ˢ s | g x.1 = g x.2} = ∑ v ∈ s.image g, #{a ∈ s | g a = v} ^ 2 := by
  rw [card_eq_sum_card_fiberwise (f := fun x => g x.1) (t := s.image g)]
  · refine sum_congr rfl fun v _ => ?_
    have : {x ∈ {x ∈ s ×ˢ s | g x.1 = g x.2} | g x.1 = v}
        = {a ∈ s | g a = v} ×ˢ {a ∈ s | g a = v} := by
      ext x
      simp only [mem_filter, mem_product]
      constructor
      · rintro ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩
        exact ⟨⟨h1, h4⟩, h2, h3 ▸ h4⟩
      · rintro ⟨⟨h1, h4⟩, h2, h5⟩
        exact ⟨⟨⟨h1, h2⟩, h4.trans h5.symm⟩, h4⟩
    rw [this, card_product, sq]
  · intro x hx
    simp only [coe_filter, mem_product, Set.mem_setOf_eq] at hx
    exact mem_coe.2 (mem_image_of_mem g hx.1.1)

/-- **The equal-type count is a totient square sum**: `sameCount n = ∑_{d ∣ n} φ(d)²`. -/
theorem sameCount_eq_sum_totient_sq {n : ℕ} (hn : 0 < n) :
    sameCount n = ∑ d ∈ n.divisors, Nat.totient d ^ 2 := by
  rw [sameCount, CyclicTypeChannel.box, card_diag_eq_sum_sq, image_ordType n hn]
  refine sum_congr rfl fun d hd => ?_
  rw [card_ordType_eq_totient hn (Nat.dvd_of_mem_divisors hd)]

/-- **Closed form of the distinctness probability**:
`δ(n) = 1 - (∑_{d ∣ n} φ(d)²) / n²`. -/
theorem distinctProb_eq_totient {n : ℕ} (hn : 0 < n) :
    distinctProb n = 1 - ((∑ d ∈ n.divisors, Nat.totient d ^ 2 : ℕ) : ℝ) / (n : ℝ) ^ 2 := by
  rw [← sameCount_eq_sum_totient_sq hn, ← one_sub_distinctProb hn]
  ring

/-- **Arithmetic corollary**: `n ↦ ∑_{d ∣ n} φ(d)²` is multiplicative on coprime arguments —
obtained here from the CRT structure of the splitting-type channel rather than from Dirichlet
convolution. -/
theorem sum_totient_sq_mul {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    ∑ d ∈ (m * n).divisors, Nat.totient d ^ 2
      = (∑ d ∈ m.divisors, Nat.totient d ^ 2) * ∑ d ∈ n.divisors, Nat.totient d ^ 2 := by
  rw [← sameCount_eq_sum_totient_sq (Nat.mul_pos hm hn), ← sameCount_eq_sum_totient_sq hm,
    ← sameCount_eq_sum_totient_sq hn, sameCount_mul hm hn h]

/-- **The hint map on coprime composites, in totients.**  For coprime positive `m, n`:
`hintMap (m n) = hintMap m + hintMap n + (1 - Σφ²(m)/m²)(1 - Σφ²(n)/n²)`. -/
theorem hintMap_mul_totient {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    hintMap (m * n) = hintMap m + hintMap n
      + (1 - ((∑ d ∈ m.divisors, Nat.totient d ^ 2 : ℕ) : ℝ) / (m : ℝ) ^ 2)
        * (1 - ((∑ d ∈ n.divisors, Nat.totient d ^ 2 : ℕ) : ℝ) / (n : ℝ) ^ 2) := by
  rw [hintMap_mul_of_coprime hm hn h, distinctProb_eq_totient hm, distinctProb_eq_totient hn]

end SexticHintValue