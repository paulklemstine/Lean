/-
# The prime cyclic order: a closed form for the type-pair channel

The exact-value files compute the type-pair channel `Ipair n` for a finite list of
cyclic orders.  This file closes the *prime* case in complete generality: for
every prime `p` the channel of the cyclic order `C p` is

  `Ipair p = log₂ p - (p-1)(2p-1)/p² · log₂ (p-1) + (p-1)(p-2)/p² · log₂ (p-2)`.

(`Ipair_prime`; the two exact values `Ipair 3` and `Ipair 5` recorded in
`CyclicTypeChannelCRT.lean` are the instances `p = 3, 5`.)

Two consequences:

* `Ipair_prime_lt_one`: every **odd** prime order is *strictly below* the one-bit
  binary-fork cap, so among prime cyclic orders the cap is attained exactly at
  `p = 2` (`Ipair_prime_eq_one_iff`).  This upgrades the isolated computations
  `Ipair 3 < 1`, `Ipair 5 < 1` to an infinite statement and shows that the
  above-cap phenomenon of `C₄, C₆, C₁₀, C₁₂, C₁₆` is genuinely a *composite*
  phenomenon: a prime cyclic order has only two splitting types, and its fork is
  exactly the binary fork that papers 72–74 capped.
* `above_cap_imp_not_prime`: breaking the cap forces the cyclic order to be
  composite.
-/
import Catalog.Shared.CyclicTypeChannelValues
import Catalog.Shared.CyclicTypeChannelCRT

namespace CyclicTypeChannel

open Finset

/-! ## 1. The splitting type of a prime cyclic order -/

/-- For a prime order `p` the splitting type is binary: the exponent `0` gives the
split-completely type `1`, every other exponent gives the inert type `p`. -/
lemma ordType_prime {p a : ℕ} (hp : p.Prime) (ha : a < p) :
    ordType p a = if a = 0 then 1 else p := by
  rcases eq_or_ne a 0 with rfl | h
  · simp [ordType_zero hp.pos]
  · have hnd : ¬ p ∣ a := fun hdvd => by
      have := Nat.le_of_dvd (Nat.pos_of_ne_zero h) hdvd
      omega
    have hco : Nat.gcd a p = 1 := Nat.Coprime.symm ((Nat.Prime.coprime_iff_not_dvd hp).2 hnd)
    simp [ordType, hco, h]

/-- The unordered type pair for a prime cyclic order. -/
lemma typePair_prime {p a b : ℕ} (hp : p.Prime) (ha : a < p) (hb : b < p) :
    typePair p (a, b) =
      if a = 0 ∧ b = 0 then (1, 1) else if a = 0 ∨ b = 0 then (1, p) else (p, p) := by
  have h1 : (1 : ℕ) ≤ p := hp.one_lt.le
  simp only [typePair, ordType_prime hp ha, ordType_prime hp hb]
  rcases eq_or_ne a 0 with rfl | ha0
  · rcases eq_or_ne b 0 with rfl | hb0
    · simp
    · simp [hb0, min_eq_left h1, max_eq_right h1]
  · rcases eq_or_ne b 0 with rfl | hb0
    · simp [ha0, min_eq_right h1, max_eq_left h1]
    · simp [ha0, hb0]

lemma mem_box_iff {n : ℕ} {x : ℕ × ℕ} : x ∈ box n ↔ x.1 < n ∧ x.2 < n := by
  simp [box, Finset.mem_product]

lemma card_box (n : ℕ) : (box n).card = n * n := by
  simp [box]

/-! ## 2. The three fibres in the box -/

/-- The nonzero exponents. -/
private def nz (p : ℕ) : Finset ℕ := (range p).erase 0

private lemma card_nz {p : ℕ} (hp : 0 < p) : (nz p).card = p - 1 := by
  simp [nz, Finset.card_erase_of_mem, hp]

private lemma mem_nz {p a : ℕ} : a ∈ nz p ↔ a < p ∧ a ≠ 0 := by
  simp [nz, and_comm]

lemma box_fiber_11 {p : ℕ} (hp : p.Prime) :
    {x ∈ box p | typePair p x = (1, 1)} = {(0, 0)} := by
  have hpne : p ≠ 1 := hp.ne_one
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_singleton, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨ha, hb⟩, h⟩
    rw [typePair_prime hp ha hb] at h
    by_cases h0 : a = 0 ∧ b = 0
    · exact h0
    · exfalso
      rw [if_neg h0] at h
      by_cases h1 : a = 0 ∨ b = 0
      · rw [if_pos h1, Prod.mk.injEq] at h
        exact hpne h.2
      · rw [if_neg h1, Prod.mk.injEq] at h
        exact hpne h.1
  · rintro ⟨rfl, rfl⟩
    exact ⟨⟨hp.pos, hp.pos⟩, by rw [typePair_prime hp hp.pos hp.pos]; simp⟩

lemma box_fiber_1p {p : ℕ} (hp : p.Prime) :
    {x ∈ box p | typePair p x = (1, p)} = ({0} ×ˢ nz p) ∪ (nz p ×ˢ {0}) := by
  have hpne : p ≠ 1 := hp.ne_one
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_union, Finset.mem_product,
    Finset.mem_singleton, mem_nz]
  constructor
  · rintro ⟨⟨ha, hb⟩, h⟩
    rw [typePair_prime hp ha hb] at h
    by_cases h0 : a = 0 ∧ b = 0
    · exfalso
      rw [if_pos h0, Prod.mk.injEq] at h
      exact hpne h.2.symm
    · rw [if_neg h0] at h
      by_cases h1 : a = 0 ∨ b = 0
      · rcases h1 with rfl | rfl
        · have hb0 : b ≠ 0 := fun hb0 => h0 ⟨rfl, hb0⟩
          tauto
        · have ha0 : a ≠ 0 := fun ha0 => h0 ⟨ha0, rfl⟩
          tauto
      · exfalso
        rw [if_neg h1, Prod.mk.injEq] at h
        exact hpne h.1
  · rintro (⟨rfl, hb, hb0⟩ | ⟨⟨ha, ha0⟩, rfl⟩)
    · refine ⟨⟨hp.pos, hb⟩, ?_⟩
      rw [typePair_prime hp hp.pos hb]
      simp [hb0]
    · refine ⟨⟨ha, hp.pos⟩, ?_⟩
      rw [typePair_prime hp ha hp.pos]
      simp [ha0]

lemma box_fiber_pp {p : ℕ} (hp : p.Prime) :
    {x ∈ box p | typePair p x = (p, p)} = nz p ×ˢ nz p := by
  have hpne : p ≠ 1 := hp.ne_one
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_product, mem_nz]
  constructor
  · rintro ⟨⟨ha, hb⟩, h⟩
    rw [typePair_prime hp ha hb] at h
    by_cases h0 : a = 0 ∧ b = 0
    · exfalso
      rw [if_pos h0, Prod.mk.injEq] at h
      exact hpne h.1.symm
    · rw [if_neg h0] at h
      by_cases h1 : a = 0 ∨ b = 0
      · exfalso
        rw [if_pos h1, Prod.mk.injEq] at h
        exact hpne h.1.symm
      · push_neg at h1
        exact ⟨⟨ha, h1.1⟩, hb, h1.2⟩
  · rintro ⟨⟨ha, ha0⟩, hb, hb0⟩
    refine ⟨⟨ha, hb⟩, ?_⟩
    rw [typePair_prime hp ha hb]
    simp [ha0, hb0]

lemma card_box_fiber_11 {p : ℕ} (hp : p.Prime) :
    #{x ∈ box p | typePair p x = (1, 1)} = 1 := by
  rw [box_fiber_11 hp, Finset.card_singleton]

lemma card_box_fiber_1p {p : ℕ} (hp : p.Prime) :
    #{x ∈ box p | typePair p x = (1, p)} = 2 * (p - 1) := by
  have hdisj : Disjoint (({0} : Finset ℕ) ×ˢ nz p) (nz p ×ˢ ({0} : Finset ℕ)) := by
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ h1 h2
    simp only [Finset.mem_product, Finset.mem_singleton, mem_nz] at h1 h2
    exact h2.1.2 h1.1
  rw [box_fiber_1p hp, Finset.card_union_of_disjoint hdisj, Finset.card_product,
    Finset.card_product, Finset.card_singleton, card_nz hp.pos]
  ring

lemma card_box_fiber_pp {p : ℕ} (hp : p.Prime) :
    #{x ∈ box p | typePair p x = (p, p)} = (p - 1) * (p - 1) := by
  rw [box_fiber_pp hp, Finset.card_product, card_nz hp.pos]

lemma image_typePair_prime {p : ℕ} (hp : p.Prime) :
    (box p).image (typePair p) = {(1, 1), (1, p), (p, p)} := by
  ext v
  simp only [Finset.mem_image, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨a, b⟩, hx, rfl⟩
    rw [mem_box_iff] at hx
    rw [typePair_prime hp hx.1 hx.2]
    split
    · exact Or.inl rfl
    · split
      · exact Or.inr (Or.inl rfl)
      · exact Or.inr (Or.inr rfl)
  · have h00 : ((0 : ℕ), (0 : ℕ)) ∈ box p := by
      rw [mem_box_iff]; exact ⟨hp.pos, hp.pos⟩
    have h01 : ((0 : ℕ), (1 : ℕ)) ∈ box p := by
      rw [mem_box_iff]; exact ⟨hp.pos, hp.one_lt⟩
    have h11 : ((1 : ℕ), (1 : ℕ)) ∈ box p := by
      rw [mem_box_iff]; exact ⟨hp.one_lt, hp.one_lt⟩
    rintro (rfl | rfl | rfl)
    · exact ⟨(0, 0), h00, by rw [typePair_prime hp hp.pos hp.pos]; simp⟩
    · exact ⟨(0, 1), h01, by rw [typePair_prime hp hp.pos hp.one_lt]; simp⟩
    · exact ⟨(1, 1), h11, by rw [typePair_prime hp hp.one_lt hp.one_lt]; simp⟩

/-! ## 3. The pair entropy -/

lemma uEnt_eq_image_sum {α β : Type*} [DecidableEq β] (s : Finset α) (g : α → β) :
    uEnt s g = Real.logb 2 s.card
      - (∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ))
        / s.card := by
  rw [uEnt, sum_logb_fiber]

/-- **The pair entropy of a prime cyclic order.** -/
theorem pairEntropy_prime {p : ℕ} (hp : p.Prime) :
    pairEntropy p = 2 * Real.logb 2 p - 2 * ((p : ℝ) - 1) / (p : ℝ) ^ 2
      - 2 * ((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) := by
  have hpne : p ≠ 1 := hp.ne_one
  have hp2 : 2 ≤ p := hp.two_le
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hpm1 : (0 : ℝ) < (p : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp2
    linarith
  have hcast : ((p - 1 : ℕ) : ℝ) = (p : ℝ) - 1 := by
    rw [Nat.cast_sub hp.one_lt.le]; norm_num
  have hne1 : ((1 : ℕ), (1 : ℕ)) ≠ ((1 : ℕ), p) := by
    intro h; rw [Prod.mk.injEq] at h; exact hpne h.2.symm
  have hne2 : ((1 : ℕ), (1 : ℕ)) ≠ (p, p) := by
    intro h; rw [Prod.mk.injEq] at h; exact hpne h.1.symm
  have hne3 : ((1 : ℕ), p) ≠ (p, p) := by
    intro h; rw [Prod.mk.injEq] at h; exact hpne h.1.symm
  have hmem1 : ((1 : ℕ), (1 : ℕ)) ∉ ({((1 : ℕ), p), (p, p)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_insert, Finset.mem_singleton]
    push_neg
    exact ⟨hne1, hne2⟩
  have hmem2 : ((1 : ℕ), p) ∉ ({(p, p)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_singleton]
    exact hne3
  rw [pairEntropy, uEnt_eq_image_sum, image_typePair_prime hp, card_box,
    Finset.sum_insert hmem1, Finset.sum_insert hmem2,
    Finset.sum_singleton, card_box_fiber_11 hp, card_box_fiber_1p hp, card_box_fiber_pp hp]
  push_cast [hcast]
  have e1 : Real.logb 2 (2 * ((p : ℝ) - 1)) = 1 + Real.logb 2 ((p : ℝ) - 1) := by
    rw [Real.logb_mul (by norm_num) (ne_of_gt hpm1)]
    simp
  have e2 : Real.logb 2 (((p : ℝ) - 1) * ((p : ℝ) - 1)) = 2 * Real.logb 2 ((p : ℝ) - 1) := by
    rw [Real.logb_mul (ne_of_gt hpm1) (ne_of_gt hpm1)]; ring
  have e3 : Real.logb 2 ((p : ℝ) * p) = 2 * Real.logb 2 p := by
    rw [Real.logb_mul (ne_of_gt hp0) (ne_of_gt hp0)]; ring
  rw [e1, e2, e3, Real.logb_one]
  field_simp
  ring

/-! ## 4. The conditional entropy -/

lemma prodRes_fiber {p c : ℕ} (hp : 0 < p) (hc : c < p) :
    {x ∈ box p | prodRes p x = c} = (range p).image (fun a => (a, (c + p - a) % p)) := by
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_image, mem_range, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨ha, hb⟩, h⟩
    refine ⟨a, ha, rfl, ?_⟩
    rw [prodRes] at h
    rcases lt_or_ge (a + b) p with hab | hab
    · have hc' : c = a + b := by rw [← h, Nat.mod_eq_of_lt hab]
      have e : c + p - a = b + p := by omega
      rw [e, Nat.add_mod_right, Nat.mod_eq_of_lt hb]
    · have hlt : a + b - p < p := by omega
      have hc' : c = a + b - p := by
        rw [← h, Nat.mod_eq_sub_mod hab, Nat.mod_eq_of_lt hlt]
      have e : c + p - a = b := by omega
      rw [e, Nat.mod_eq_of_lt hb]
  · rintro ⟨a', ha', rfl, rfl⟩
    refine ⟨⟨ha', Nat.mod_lt _ hp⟩, ?_⟩
    rw [prodRes]
    rcases Nat.lt_or_ge c a' with h | h
    · have e : c + p - a' < p := by omega
      rw [Nat.mod_eq_of_lt e]
      have e2 : a' + (c + p - a') = c + p := by omega
      rw [e2, Nat.add_mod_right, Nat.mod_eq_of_lt hc]
    · have e : c + p - a' = (c - a') + p := by omega
      rw [e, Nat.add_mod_right, Nat.mod_eq_of_lt (by omega : c - a' < p)]
      have e2 : a' + (c - a') = c := by omega
      rw [e2, Nat.mod_eq_of_lt hc]

lemma card_prodRes_fiber {p c : ℕ} (hp : 0 < p) (hc : c < p) :
    #{x ∈ box p | prodRes p x = c} = p := by
  rw [prodRes_fiber hp hc, Finset.card_image_of_injective _ (fun x y h => by
    simpa using congrArg Prod.fst h), Finset.card_range]

lemma image_prodRes {p : ℕ} (hp : 0 < p) : (box p).image (prodRes p) = range p := by
  ext c
  simp only [Finset.mem_image, mem_range]
  constructor
  · rintro ⟨x, _, rfl⟩
    exact Nat.mod_lt _ hp
  · intro hc
    exact ⟨(c, 0), by rw [mem_box_iff]; exact ⟨hc, hp⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩

/-- On the `N ≡ 0` fibre either both exponents vanish or neither does. -/
lemma prodRes_zero_dichotomy {p a b : ℕ} (ha : a < p) (hb : b < p)
    (h : prodRes p (a, b) = 0) : (a = 0 ∧ b = 0) ∨ (a ≠ 0 ∧ b ≠ 0) := by
  rcases eq_or_ne a 0 with rfl | h1
  · refine Or.inl ⟨rfl, ?_⟩
    simpa [prodRes, Nat.mod_eq_of_lt hb] using h
  · rcases eq_or_ne b 0 with rfl | h2
    · exact absurd (by simpa [prodRes, Nat.mod_eq_of_lt ha] using h) h1
    · exact Or.inr ⟨h1, h2⟩

/-- On a nonzero fibre either exactly one exponent vanishes, or neither does. -/
lemma prodRes_ne_zero_dichotomy {p a b c : ℕ} (ha : a < p) (hb : b < p)
    (h : prodRes p (a, b) = c) :
    ((a, b) = (0, c) ∨ (a, b) = (c, 0)) ∨ (a ≠ 0 ∧ b ≠ 0) := by
  rcases eq_or_ne a 0 with rfl | h1
  · refine Or.inl (Or.inl ?_)
    have : b = c := by simpa [prodRes, Nat.mod_eq_of_lt hb] using h
    simp [this]
  · rcases eq_or_ne b 0 with rfl | h2
    · refine Or.inl (Or.inr ?_)
      have : a = c := by simpa [prodRes, Nat.mod_eq_of_lt ha] using h
      simp [this]
    · exact Or.inr ⟨h1, h2⟩

lemma zero_fiber_11 {p : ℕ} (hp : p.Prime) :
    {x ∈ {y ∈ box p | prodRes p y = 0} | typePair p x = (1, 1)} = {(0, 0)} := by
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_singleton, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨⟨ha, hb⟩, _⟩, h⟩
    have hmem : (a, b) ∈ {x ∈ box p | typePair p x = (1, 1)} := by
      rw [mem_filter, mem_box_iff]; exact ⟨⟨ha, hb⟩, h⟩
    rw [box_fiber_11 hp, Finset.mem_singleton] at hmem
    exact ⟨congrArg Prod.fst hmem, congrArg Prod.snd hmem⟩
  · rintro ⟨rfl, rfl⟩
    refine ⟨⟨⟨hp.pos, hp.pos⟩, by simp [prodRes]⟩, ?_⟩
    rw [typePair_prime hp hp.pos hp.pos]; simp

lemma origin_mem_zero_fiber {p : ℕ} (hp : p.Prime) :
    ({((0 : ℕ), (0 : ℕ))} : Finset (ℕ × ℕ)) ⊆ {y ∈ box p | prodRes p y = 0} := by
  intro x hx
  rw [Finset.mem_singleton] at hx
  subst hx
  rw [mem_filter, mem_box_iff]
  exact ⟨⟨hp.pos, hp.pos⟩, by simp [prodRes]⟩

lemma zero_fiber_pp {p : ℕ} (hp : p.Prime) :
    #{x ∈ {y ∈ box p | prodRes p y = 0} | typePair p x = (p, p)} = p - 1 := by
  have hpne : p ≠ 1 := hp.ne_one
  have hsub : {x ∈ {y ∈ box p | prodRes p y = 0} | typePair p x = (p, p)}
      = {y ∈ box p | prodRes p y = 0} \ {(0, 0)} := by
    ext ⟨a, b⟩
    simp only [mem_filter, mem_box_iff, Finset.mem_sdiff, Finset.mem_singleton, Prod.mk.injEq]
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      rintro ⟨rfl, rfl⟩
      rw [typePair_prime hp hp.pos hp.pos] at h2
      simp only [and_self, if_true, Prod.mk.injEq] at h2
      exact hpne h2.symm
    · rintro ⟨⟨⟨ha, hb⟩, hres⟩, hne⟩
      refine ⟨⟨⟨ha, hb⟩, hres⟩, ?_⟩
      rw [typePair_prime hp ha hb]
      rcases prodRes_zero_dichotomy ha hb hres with ⟨rfl, rfl⟩ | ⟨h1, h2⟩
      · exact absurd ⟨rfl, rfl⟩ hne
      · rw [if_neg (by tauto), if_neg (by tauto)]
  rw [hsub, Finset.card_sdiff_of_subset (origin_mem_zero_fiber hp), Finset.card_singleton,
    card_prodRes_fiber hp.pos hp.pos]

lemma image_zero_fiber {p : ℕ} (hp : p.Prime) :
    ({y ∈ box p | prodRes p y = 0}).image (typePair p) = {(1, 1), (p, p)} := by
  have hp2 : 2 ≤ p := hp.two_le
  ext v
  simp only [Finset.mem_image, mem_filter, mem_box_iff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨a, b⟩, ⟨⟨⟨ha, hb⟩, hres⟩, rfl⟩⟩
    rw [typePair_prime hp ha hb]
    rcases prodRes_zero_dichotomy ha hb hres with ⟨rfl, rfl⟩ | ⟨h1, h2⟩
    · simp
    · rw [if_neg (by tauto), if_neg (by tauto)]
      exact Or.inr rfl
  · rintro (rfl | rfl)
    · exact ⟨(0, 0), ⟨⟨⟨hp.pos, hp.pos⟩, by simp [prodRes]⟩, by
        rw [typePair_prime hp hp.pos hp.pos]; simp⟩⟩
    · refine ⟨(1, p - 1), ⟨⟨⟨hp.one_lt, by omega⟩, ?_⟩, ?_⟩⟩
      · rw [prodRes]
        have e : 1 + (p - 1) = p := by omega
        rw [e, Nat.mod_self]
      · rw [typePair_prime hp hp.one_lt (by omega)]
        have h2 : p - 1 ≠ 0 := by omega
        rw [if_neg (by tauto), if_neg (by tauto)]

/-- The entropy of the type pair on the `N ≡ 0` fibre. -/
theorem uEnt_zero_fiber {p : ℕ} (hp : p.Prime) :
    uEnt {y ∈ box p | prodRes p y = 0} (typePair p)
      = Real.logb 2 p - ((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) := by
  have hpne : p ≠ 1 := hp.ne_one
  have hcast : ((p - 1 : ℕ) : ℝ) = (p : ℝ) - 1 := by
    rw [Nat.cast_sub hp.one_lt.le]; norm_num
  have hne : ((1 : ℕ), (1 : ℕ)) ≠ (p, p) := by
    intro h; rw [Prod.mk.injEq] at h; exact hpne h.1.symm
  have hmem : ((1 : ℕ), (1 : ℕ)) ∉ ({(p, p)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_singleton]; exact hne
  have h11 : #{x ∈ {y ∈ box p | prodRes p y = 0} | typePair p x = (1, 1)} = 1 := by
    rw [zero_fiber_11 hp, Finset.card_singleton]
  rw [uEnt_eq_image_sum, image_zero_fiber hp, card_prodRes_fiber hp.pos hp.pos,
    Finset.sum_insert hmem, Finset.sum_singleton, h11, zero_fiber_pp hp]
  push_cast [hcast]
  simp

/-! ### The nonzero fibres -/

lemma nonzero_fiber_1p {p c : ℕ} (hp : p.Prime) (hc : c < p) (hc0 : c ≠ 0) :
    {x ∈ {y ∈ box p | prodRes p y = c} | typePair p x = (1, p)} = {(0, c), (c, 0)} := by
  have hpne : p ≠ 1 := hp.ne_one
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, Finset.mem_insert, Finset.mem_singleton, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨⟨ha, hb⟩, hres⟩, h⟩
    rcases prodRes_ne_zero_dichotomy ha hb hres with hcase | ⟨h1, h2⟩
    · rcases hcase with hcase | hcase
      · exact Or.inl ⟨congrArg Prod.fst hcase, congrArg Prod.snd hcase⟩
      · exact Or.inr ⟨congrArg Prod.fst hcase, congrArg Prod.snd hcase⟩
    · exfalso
      rw [typePair_prime hp ha hb, if_neg (by tauto), if_neg (by tauto), Prod.mk.injEq] at h
      exact hpne h.1
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · refine ⟨⟨⟨hp.pos, hc⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩, ?_⟩
      rw [typePair_prime hp hp.pos hc, if_neg (by tauto), if_pos (by tauto)]
    · refine ⟨⟨⟨hc, hp.pos⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩, ?_⟩
      rw [typePair_prime hp hc hp.pos, if_neg (by tauto), if_pos (by tauto)]

lemma card_nonzero_fiber_1p {p c : ℕ} (hp : p.Prime) (hc : c < p) (hc0 : c ≠ 0) :
    #{x ∈ {y ∈ box p | prodRes p y = c} | typePair p x = (1, p)} = 2 := by
  have hne : ((0 : ℕ), c) ∉ ({(c, 0)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_singleton, Prod.mk.injEq]
    exact fun h => hc0 h.1.symm
  rw [nonzero_fiber_1p hp hc hc0, Finset.card_insert_of_notMem hne, Finset.card_singleton]

lemma pair_mem_nonzero_fiber {p c : ℕ} (hp : p.Prime) (hc : c < p) :
    ({((0 : ℕ), c), (c, 0)} : Finset (ℕ × ℕ)) ⊆ {y ∈ box p | prodRes p y = c} := by
  intro x hx
  simp only [Finset.mem_insert, Finset.mem_singleton] at hx
  rw [mem_filter, mem_box_iff]
  rcases hx with rfl | rfl
  · exact ⟨⟨hp.pos, hc⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩
  · exact ⟨⟨hc, hp.pos⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩

lemma card_nonzero_fiber_pp {p c : ℕ} (hp : p.Prime) (hc : c < p) (hc0 : c ≠ 0) :
    #{x ∈ {y ∈ box p | prodRes p y = c} | typePair p x = (p, p)} = p - 2 := by
  have hpne : p ≠ 1 := hp.ne_one
  have hne : ((0 : ℕ), c) ∉ ({(c, 0)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_singleton, Prod.mk.injEq]
    exact fun h => hc0 h.1.symm
  have hsub : {x ∈ {y ∈ box p | prodRes p y = c} | typePair p x = (p, p)}
      = {y ∈ box p | prodRes p y = c} \ {(0, c), (c, 0)} := by
    ext ⟨a, b⟩
    simp only [mem_filter, mem_box_iff, Finset.mem_sdiff, Finset.mem_insert,
      Finset.mem_singleton, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨⟨ha, hb⟩, hres⟩, h⟩
      refine ⟨⟨⟨ha, hb⟩, hres⟩, ?_⟩
      rw [typePair_prime hp ha hb] at h
      rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
      · rw [if_neg (by tauto), if_pos (by tauto), Prod.mk.injEq] at h
        exact hpne h.1.symm
      · rw [if_neg (by tauto), if_pos (by tauto), Prod.mk.injEq] at h
        exact hpne h.1.symm
    · rintro ⟨⟨⟨ha, hb⟩, hres⟩, hne'⟩
      refine ⟨⟨⟨ha, hb⟩, hres⟩, ?_⟩
      rw [typePair_prime hp ha hb]
      rcases prodRes_ne_zero_dichotomy ha hb hres with hcase | ⟨h1, h2⟩
      · exfalso
        rcases hcase with hcase | hcase
        · exact hne' (Or.inl ⟨congrArg Prod.fst hcase, congrArg Prod.snd hcase⟩)
        · exact hne' (Or.inr ⟨congrArg Prod.fst hcase, congrArg Prod.snd hcase⟩)
      · rw [if_neg (by tauto), if_neg (by tauto)]
  rw [hsub, Finset.card_sdiff_of_subset (pair_mem_nonzero_fiber hp hc), card_prodRes_fiber hp.pos hc,
    Finset.card_insert_of_notMem hne, Finset.card_singleton]

lemma image_nonzero_fiber {p c : ℕ} (hp : p.Prime) (hp3 : 3 ≤ p) (hc : c < p) (hc0 : c ≠ 0) :
    ({y ∈ box p | prodRes p y = c}).image (typePair p) = {(1, p), (p, p)} := by
  ext v
  simp only [Finset.mem_image, mem_filter, mem_box_iff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨a, b⟩, ⟨⟨⟨ha, hb⟩, hres⟩, rfl⟩⟩
    rw [typePair_prime hp ha hb]
    rcases prodRes_ne_zero_dichotomy ha hb hres with hcase | ⟨h1, h2⟩
    · rcases hcase with hcase | hcase <;>
        · rw [Prod.mk.injEq] at hcase
          obtain ⟨rfl, rfl⟩ := hcase
          rw [if_neg (by tauto), if_pos (by tauto)]
          exact Or.inl rfl
    · rw [if_neg (by tauto), if_neg (by tauto)]
      exact Or.inr rfl
  · rintro (rfl | rfl)
    · refine ⟨(0, c), ⟨⟨⟨hp.pos, hc⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩, ?_⟩⟩
      rw [typePair_prime hp hp.pos hc, if_neg (by tauto), if_pos (by tauto)]
    · -- with `p ≥ 3` there is a pair of nonzero exponents summing to `c`
      have hex : ∃ a b, a < p ∧ b < p ∧ a ≠ 0 ∧ b ≠ 0 ∧ (a + b) % p = c := by
        rcases eq_or_ne c 1 with rfl | hc1
        · refine ⟨2, p - 1, by omega, by omega, by omega, by omega, ?_⟩
          have e : 2 + (p - 1) = 1 + p := by omega
          rw [e, Nat.add_mod_right]
          exact Nat.mod_eq_of_lt (by omega)
        · refine ⟨1, c - 1, by omega, by omega, by omega, by omega, ?_⟩
          have e : 1 + (c - 1) = c := by omega
          rw [e, Nat.mod_eq_of_lt hc]
      obtain ⟨a, b, ha, hb, ha0, hb0, hres⟩ := hex
      refine ⟨(a, b), ⟨⟨⟨ha, hb⟩, hres⟩, ?_⟩⟩
      rw [typePair_prime hp ha hb, if_neg (by tauto), if_neg (by tauto)]

/-- The entropy of the type pair on a nonzero fibre. -/
theorem uEnt_nonzero_fiber {p c : ℕ} (hp : p.Prime) (hp3 : 3 ≤ p) (hc : c < p) (hc0 : c ≠ 0) :
    uEnt {y ∈ box p | prodRes p y = c} (typePair p)
      = Real.logb 2 p - (2 + ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2)) / (p : ℝ) := by
  have hpne : p ≠ 1 := hp.ne_one
  have hcast : ((p - 2 : ℕ) : ℝ) = (p : ℝ) - 2 := by
    rw [Nat.cast_sub (by omega : 2 ≤ p)]; norm_num
  have hne : ((1 : ℕ), p) ≠ (p, p) := by
    intro h; rw [Prod.mk.injEq] at h; exact hpne h.1.symm
  have hmem : ((1 : ℕ), p) ∉ ({(p, p)} : Finset (ℕ × ℕ)) := by
    simp only [Finset.mem_singleton]; exact hne
  have hl2 : Real.logb 2 (2 : ℝ) = 1 := by simp
  rw [uEnt_eq_image_sum, image_nonzero_fiber hp hp3 hc hc0, card_prodRes_fiber hp.pos hc,
    Finset.sum_insert hmem, Finset.sum_singleton,
    card_nonzero_fiber_1p hp hc hc0, card_nonzero_fiber_pp hp hc hc0]
  push_cast [hcast]
  rw [hl2]
  ring

/-- **The conditional pair entropy of a prime cyclic order.** -/
theorem condPairEntropy_prime {p : ℕ} (hp : p.Prime) :
    condPairEntropy p = Real.logb 2 p
      - ((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2
      - 2 * ((p : ℝ) - 1) / (p : ℝ) ^ 2
      - ((p : ℝ) - 1) * ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2) / (p : ℝ) ^ 2 := by
  rcases eq_or_lt_of_le hp.two_le with h2 | h2
  · -- `p = 2`
    have hp2 : p = 2 := h2.symm
    subst hp2
    rw [condPairEntropy_val_2]
    norm_num
  · have hp3 : 3 ≤ p := by omega
    have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
    have hcard : ((box p).card : ℝ) = (p : ℝ) * p := by rw [card_box]; push_cast; ring
    rw [condPairEntropy, condEnt, image_prodRes hp.pos]
    have hterm : ∀ c ∈ range p,
        ((#{x ∈ box p | prodRes p x = c} : ℝ) / (box p).card) *
            uEnt {x ∈ box p | prodRes p x = c} (typePair p)
          = (1 / (p : ℝ)) * uEnt {x ∈ box p | prodRes p x = c} (typePair p) := by
      intro c hc
      rw [mem_range] at hc
      rw [card_prodRes_fiber hp.pos hc, hcard]
      congr 1
      field_simp
    rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum]
    have hsplit : ∑ c ∈ range p, uEnt {x ∈ box p | prodRes p x = c} (typePair p)
        = uEnt {x ∈ box p | prodRes p x = 0} (typePair p)
          + ∑ c ∈ (range p).erase 0, uEnt {x ∈ box p | prodRes p x = c} (typePair p) := by
      rw [← Finset.add_sum_erase _ _ (mem_range.2 hp.pos)]
    have hconst : ∀ c ∈ (range p).erase 0,
        uEnt {x ∈ box p | prodRes p x = c} (typePair p)
          = Real.logb 2 p - (2 + ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2)) / (p : ℝ) := by
      intro c hc
      rw [Finset.mem_erase, mem_range] at hc
      exact uEnt_nonzero_fiber hp hp3 hc.2 hc.1
    rw [hsplit, Finset.sum_congr rfl hconst, Finset.sum_const,
      Finset.card_erase_of_mem (mem_range.2 hp.pos), Finset.card_range, uEnt_zero_fiber hp]
    have hcast1 : ((p - 1 : ℕ) : ℝ) = (p : ℝ) - 1 := by
      rw [Nat.cast_sub hp.one_lt.le]; norm_num
    rw [nsmul_eq_mul, hcast1]
    field_simp
    ring

/-- **The type-pair channel of a prime cyclic order — a closed form for every
prime.**  For `p = 2` this returns the paper-74 cap `1`; for every odd prime the
value is strictly smaller (`Ipair_prime_lt_one`). -/
theorem Ipair_prime {p : ℕ} (hp : p.Prime) :
    Ipair p = Real.logb 2 p
      - ((p : ℝ) - 1) * (2 * (p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2
      + ((p : ℝ) - 1) * ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2) / (p : ℝ) ^ 2 := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  rw [Ipair_eq, pairEntropy_prime hp, condPairEntropy_prime hp]
  field_simp
  ring

/-! ## 5. Consequences: the cap among prime orders -/

/-- The elementary bound `log₂ (x+1) - log₂ x ≤ 1 / (x log 2)`. -/
lemma logb_sub_logb_le {x : ℝ} (hx : 1 ≤ x) :
    Real.logb 2 (x + 1) - Real.logb 2 x ≤ 1 / (x * Real.log 2) := by
  have hx0 : (0 : ℝ) < x := by linarith
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log (x + 1) - Real.log x = Real.log ((x + 1) / x) := by
    rw [Real.log_div (by linarith) (ne_of_gt hx0)]
  have hle : Real.log ((x + 1) / x) ≤ 1 / x := by
    have h2 := Real.log_le_sub_one_of_pos (x := (x + 1) / x) (by positivity)
    have hsimp : (x + 1) / x - 1 = 1 / x := by field_simp; ring
    rw [hsimp] at h2
    exact h2
  have hgoal : Real.log ((x + 1) / x) / Real.log 2 ≤ (1 / x) / Real.log 2 := by
    gcongr
  rw [Real.logb, Real.logb, div_sub_div_same, h]
  calc Real.log ((x + 1) / x) / Real.log 2 ≤ (1 / x) / Real.log 2 := hgoal
    _ = 1 / (x * Real.log 2) := by field_simp

/-- `log₂ p ≤ p`. -/
lemma logb_two_le_self {p : ℕ} (hp : 0 < p) : Real.logb 2 (p : ℝ) ≤ (p : ℝ) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h1 : (p : ℝ) ≤ 2 ^ p := by exact_mod_cast (Nat.lt_two_pow_self (n := p)).le
  have h2 : Real.log (p : ℝ) ≤ Real.log ((2 : ℝ) ^ p) :=
    Real.log_le_log (by exact_mod_cast hp) h1
  rw [Real.log_pow] at h2
  rw [Real.logb, div_le_iff₀ hlog2]
  calc Real.log (p : ℝ) ≤ (p : ℕ) * Real.log 2 := h2
    _ = (p : ℝ) * Real.log 2 := by ring

/-- **Every odd prime cyclic order stays strictly below the one-bit cap.**
Together with `Ipair 2 = 1` this pins the binary-fork cap to the single prime
order `p = 2`: the above-cap behaviour of `C₄, C₆, C₁₀, C₁₂, C₁₆` is a composite
phenomenon. -/
theorem Ipair_prime_lt_one {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) : Ipair p < 1 := by
  have hp3 : 3 ≤ p := by
    have h := hp.two_le
    rcases eq_or_lt_of_le h with h' | h'
    · exact absurd h'.symm hp2
    · omega
  have hpR : (3 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp3
  have hp0 : (0 : ℝ) < p := by linarith
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlog2pos : (0 : ℝ) < Real.log 2 := by linarith
  set L := Real.logb 2 (p : ℝ) with hL
  set L1 := Real.logb 2 ((p : ℝ) - 1) with hL1
  set L2 := Real.logb 2 ((p : ℝ) - 2) with hL2
  set A := ((p : ℝ) - 1) * (2 * (p : ℝ) - 1) / (p : ℝ) ^ 2 with hA
  set B := ((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2 with hB
  -- the first-order bound on the marginal gap
  have hkey : L - L1 ≤ 1 / (((p : ℝ) - 1) * Real.log 2) := by
    have h := logb_sub_logb_le (x := (p : ℝ) - 1) (by linarith)
    have e : (p : ℝ) - 1 + 1 = (p : ℝ) := by ring
    rw [e] at h
    exact h
  have hApos : 0 ≤ A := by
    rw [hA]
    apply div_nonneg _ (by positivity)
    nlinarith
  have hBpos : 0 ≤ B := by
    rw [hB]
    apply div_nonneg _ (by positivity)
    nlinarith
  have hL2le : L2 ≤ L := by
    rw [hL2, hL]
    exact Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  -- the algebraic decomposition of the channel
  have hdecomp : Ipair p = L * (1 - A + B) + A * (L - L1) - B * (L - L2) := by
    rw [Ipair_prime hp, hA, hB, hL, hL1, hL2]
    field_simp
    ring
  have hcoeff : 1 - A + B = 1 / (p : ℝ) ^ 2 := by
    rw [hA, hB]
    field_simp
    ring
  have hne1' : ((p : ℝ) - 1) ≠ 0 := by linarith
  have hne2' : (p : ℝ) ≠ 0 := by linarith
  have hne3' : Real.log 2 ≠ 0 := by linarith
  have hstep1 : A * (L - L1) ≤ (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) := by
    calc A * (L - L1) ≤ A * (1 / (((p : ℝ) - 1) * Real.log 2)) :=
          mul_le_mul_of_nonneg_left hkey hApos
      _ = (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) := by
          rw [hA]; field_simp
  have hstep2 : 0 ≤ B * (L - L2) := mul_nonneg hBpos (by linarith)
  have hIle : Ipair p ≤ L / (p : ℝ) ^ 2 + (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) := by
    rw [hdecomp, hcoeff]
    have : L * (1 / (p : ℝ) ^ 2) = L / (p : ℝ) ^ 2 := by ring
    linarith [hstep1, hstep2, this]
  -- the numerical bound
  have hnum : L / (p : ℝ) ^ 2 + (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) < 1 := by
    have hcollect : L / (p : ℝ) ^ 2 + (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2)
        = (L + (2 * (p : ℝ) - 1) / Real.log 2) / (p : ℝ) ^ 2 := by
      field_simp
    rw [hcollect, div_lt_one (by positivity)]
    have hq : (2 * (p : ℝ) - 1) / Real.log 2 < (2 * (p : ℝ) - 1) / 0.6931471803 :=
      div_lt_div_of_pos_left (by linarith) (by norm_num) hlog2
    rcases eq_or_lt_of_le hp3 with h3 | h3
    · -- `p = 3`
      have hp3' : p = 3 := h3.symm
      subst hp3'
      have hLlt : L < 8 / 5 := by
        rw [hL]
        have : ((3 : ℕ) : ℝ) = (3 : ℝ) := by norm_num
        rw [this]
        exact lb_three_lt
      have hcast3 : ((3 : ℕ) : ℝ) = (3 : ℝ) := by norm_num
      rw [hcast3] at hq ⊢
      norm_num at hq ⊢
      linarith
    · -- `p ≥ 4`
      have hp4 : (4 : ℝ) ≤ (p : ℝ) := by
        have : 4 ≤ p := by omega
        exact_mod_cast this
      have hLle : L ≤ (p : ℝ) := by rw [hL]; exact logb_two_le_self hp.pos
      have hlin : (2 * (p : ℝ) - 1) / 0.6931471803 ≤ 2.8854 * (p : ℝ) - 1.4427 := by
        rw [div_le_iff₀ (by norm_num)]
        nlinarith
      nlinarith
  linarith

/-- **Among prime cyclic orders the cap is attained exactly at `p = 2`.** -/
theorem Ipair_prime_eq_one_iff {p : ℕ} (hp : p.Prime) : Ipair p = 1 ↔ p = 2 := by
  constructor
  · intro h
    by_contra hne
    exact absurd h (ne_of_lt (Ipair_prime_lt_one hp hne))
  · rintro rfl
    exact Ipair_val_2

/-- **Breaking the one-bit cap forces the cyclic order to be composite.** -/
theorem above_cap_imp_not_prime {n : ℕ} (h : 1 < Ipair n) : ¬ n.Prime := by
  intro hn
  rcases eq_or_ne n 2 with rfl | hne
  · rw [Ipair_val_2] at h
    exact lt_irrefl 1 h
  · exact absurd h (not_lt.2 (Ipair_prime_lt_one hn hne).le)

/-- The prime channel decays: an explicit envelope `Ipair p ≤ (log₂ p + 3p)/p²`
for every prime `p`, so the prime-order channel tends to `0`. -/
theorem Ipair_prime_le_envelope {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    Ipair p ≤ (Real.logb 2 (p : ℝ) + 3 * (p : ℝ)) / (p : ℝ) ^ 2 := by
  have hp3 : 3 ≤ p := by
    have h := hp.two_le
    rcases eq_or_lt_of_le h with h' | h'
    · exact absurd h'.symm hp2
    · omega
  have hpR : (3 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp3
  have hp0 : (0 : ℝ) < p := by linarith
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlog2pos : (0 : ℝ) < Real.log 2 := by linarith
  set L := Real.logb 2 (p : ℝ) with hL
  set L1 := Real.logb 2 ((p : ℝ) - 1) with hL1
  set L2 := Real.logb 2 ((p : ℝ) - 2) with hL2
  set A := ((p : ℝ) - 1) * (2 * (p : ℝ) - 1) / (p : ℝ) ^ 2 with hA
  set B := ((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2 with hB
  have hkey : L - L1 ≤ 1 / (((p : ℝ) - 1) * Real.log 2) := by
    have h := logb_sub_logb_le (x := (p : ℝ) - 1) (by linarith)
    have e : (p : ℝ) - 1 + 1 = (p : ℝ) := by ring
    rw [e] at h
    exact h
  have hApos : 0 ≤ A := by
    rw [hA]; apply div_nonneg _ (by positivity); nlinarith
  have hBpos : 0 ≤ B := by
    rw [hB]; apply div_nonneg _ (by positivity); nlinarith
  have hL2le : L2 ≤ L := by
    rw [hL2, hL]
    exact Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  have hdecomp : Ipair p = L * (1 - A + B) + A * (L - L1) - B * (L - L2) := by
    rw [Ipair_prime hp, hA, hB, hL, hL1, hL2]
    field_simp
    ring
  have hcoeff : 1 - A + B = 1 / (p : ℝ) ^ 2 := by
    rw [hA, hB]; field_simp; ring
  have hne1' : ((p : ℝ) - 1) ≠ 0 := by linarith
  have hne2' : (p : ℝ) ≠ 0 := by linarith
  have hne3' : Real.log 2 ≠ 0 := by linarith
  have hstep1 : A * (L - L1) ≤ (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) := by
    calc A * (L - L1) ≤ A * (1 / (((p : ℝ) - 1) * Real.log 2)) :=
          mul_le_mul_of_nonneg_left hkey hApos
      _ = (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) := by
          rw [hA]; field_simp
  have hstep2 : 0 ≤ B * (L - L2) := mul_nonneg hBpos (by linarith)
  have hbound : (2 * (p : ℝ) - 1) / ((p : ℝ) ^ 2 * Real.log 2) ≤ 3 * (p : ℝ) / (p : ℝ) ^ 2 := by
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    have hcube : (0 : ℝ) < (p : ℝ) ^ 3 := by positivity
    have hmul : (p : ℝ) ^ 3 * 0.6931471803 < (p : ℝ) ^ 3 * Real.log 2 :=
      mul_lt_mul_of_pos_left hlog2 hcube
    nlinarith [hmul, hcube]
  have hcollect : L / (p : ℝ) ^ 2 + 3 * (p : ℝ) / (p : ℝ) ^ 2
      = (L + 3 * (p : ℝ)) / (p : ℝ) ^ 2 := by
    field_simp
  have hLdiv : L * (1 / (p : ℝ) ^ 2) = L / (p : ℝ) ^ 2 := by ring
  rw [hdecomp, hcoeff]
  linarith [hstep1, hstep2, hbound, hcollect, hLdiv]

/-! ## 6. Cross-checks against the enumerated values

`Ipair 3` and `Ipair 5` were computed in `CyclicTypeChannelCRT.lean` by explicit
enumeration of the `9`- and `25`-element boxes.  Re-deriving them from the general
prime formula is an independent check of the closed form. -/

/-- The general prime formula at `p = 3` reproduces the enumerated value
`Ipair 3 = log₂ 3 - 10/9`. -/
theorem Ipair_prime_three : Ipair 3 = (-10/9 : ℝ) + Real.logb 2 3 := by
  have h := Ipair_prime (p := 3) (by norm_num)
  norm_num at h
  rw [h]
  ring

/-- The general prime formula at `p = 5` reproduces the enumerated value. -/
theorem Ipair_prime_five :
    Ipair 5 = (-72/25 : ℝ) + (12/25 : ℝ) * Real.logb 2 3 + Real.logb 2 5 := by
  have h := Ipair_prime (p := 5) (by norm_num)
  norm_num [lb_4] at h
  rw [h]
  ring

end CyclicTypeChannel