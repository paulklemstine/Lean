import Mathlib
import Novelty.SplitCountLaw
import Speculative.AutoResearch.SplitCountChannel

/-!
# The OR-collapse law of a character-pinned fork

Setting (paper 72, experiment 407).  Let `K/ℚ` be abelian with the
split-completely event of a prime `p` pinned by a Dirichlet character `χ` of
order `n` (`p` splits completely iff `χ(p) = 1`, so `P(split) = 1/n`).  For a
semiprime `N = p q` with `gcd(N, f) = 1` the only observable of the fork that is
visible from `N` alone is the residue class `χ(N) = χ(p) χ(q)`, and the coarsest
non-trivial statistic of the fork is the Boolean

`OR = [ p splits ] ∨ [ q splits ]`.

This file proves the *exact universal law* of the resulting collapse.

## Main results

* `card_prodFiber`, `card_orFiber`, `card_orEvent` — the group-theoretic heart:
  in any finite group `G` of order `n` (the value group of `χ`) the fibre
  `{(x,y) : x y = c}` has `n` elements, its OR-part `{x = 1 ∨ y = 1}` has
  **exactly `1` element if `c = 1` and exactly `2` if `c ≠ 1`**, and the total OR
  event has `2n - 1` elements.  This is the source of the numbers `1/n`, `2/n`,
  `(2n-1)/n²`.
* `orRate_eq_channel` — the counting rates are exactly the two rows of the
  binary OR channel `orCond`.
* `or_collapse_law` (**main theorem**) : for every real order `n ≥ 2`,
  `Ior n = gOR n` where
  `gOR n = Hb ((2n-1)/n²) - (1/n) Hb (1/n) - ((n-1)/n) Hb (2/n)`,
  `Hb` the binary entropy in bits.  The information a semiprime's residue class
  carries about the OR of its two split events depends on **nothing but the
  order `n` of the character**.
* `gOR_two`, `gOR_three`, `gOR_four`, `gOR_five` — exact closed forms
  `3/2 - (3/4)log₂3`, `log₂3 - (5/9)log₂5 - 2/9`,
  `11/4 - (15/16)log₂3 - (7/16)log₂7`, `log₂5 - (6/25)log₂3 - 48/25`, and
  rational brackets `gOR_two_bracket`, …, `gOR_five_bracket` matching the
  measured values `0.3113, 0.0728, 0.0359, 0.0215`.
* `gOR_decay` — the measured decay chain `gOR 5 < gOR 4 < gOR 3 < gOR 2`.
* `gOR_pos` — the OR face never collapses completely: `0 < gOR n` for `n ≥ 2`.
* `gOR_le_chiSq` (**quantitative collapse**) : `gOR n ≤ 1/(log 2 ⬝ (n-1)(2n-1))`,
  a χ²-divergence bound, hence the `1/n²` decay rate.
* `gOR_le_gOR_two` — the universal cap: no order-`n` Dirichlet fork yields more
  than `gOR 2 = 0.3113…` bits of symmetric OR information.
* `gOR_tendsto_zero` — the collapse is total in the limit of large order.
* `gOR_ge_classZero`, `gOR_ge_explicit` — a matching lower bound: the exact
  Kullback–Leibler term of the class `χ(N) = 1` gives
  `n² g(n) ≥ (1 - 1/(2n))/log 2 - 1 → 1/log 2 - 1 = 0.4427…`.
* `gOR_order_inv_sq` — combining the two bounds, `0.08/n² ≤ g(n) ≤ 2/n²`: the
  semiprime OR collapse has order **exactly** `n⁻²`.

The sharp asymptotic constant `n² g(n) → 1/log 2 - 1` is proved in the companion
file `Applications.OrCollapseAsymptotics`.

Everything is built on the catalogued finite-table information theory of
`Novelty.SplitCountLaw` and the fork channel of
`Speculative.AutoResearch.SplitCountChannel`.
-/

namespace OrCollapseLaw

open Finset Real SplitCountLaw SplitCountChannel

/-! ## 1. The group-theoretic source of the numbers `1/n`, `2/n`, `(2n-1)/n²` -/

section CharacterGroup

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The pairs of character values `(χ(p), χ(q))` with prescribed product
`χ(N) = c`. -/
def prodFiber (c : G) : Finset (G × G) := Finset.univ.filter (fun z => z.1 * z.2 = c)

/-- The part of the fibre on which the OR of the two split events holds
(`χ(p) = 1` or `χ(q) = 1`). -/
def orFiber (c : G) : Finset (G × G) := (prodFiber c).filter (fun z => z.1 = 1 ∨ z.2 = 1)

/-- The whole OR event, over all classes of `N`. -/
def orEvent (G : Type*) [Group G] [Fintype G] [DecidableEq G] : Finset (G × G) :=
  Finset.univ.filter (fun z : G × G => z.1 = 1 ∨ z.2 = 1)

/-- Every class of `N` is hit by exactly `n = |G|` value pairs: the CRT split. -/
theorem card_prodFiber (c : G) : (prodFiber c).card = Fintype.card G := by
  have h : prodFiber c = Finset.univ.image (fun x : G => (x, x⁻¹ * c)) := by
    ext z
    obtain ⟨x, y⟩ := z
    simp only [prodFiber, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image,
      Prod.mk.injEq]
    constructor
    · intro h
      exact ⟨x, by rw [← h]; simp⟩
    · rintro ⟨a, ha, rfl⟩
      rw [← ha]
      simp
  have hinj : Function.Injective (fun x : G => (x, x⁻¹ * c)) := by
    intro x y hxy
    exact congrArg Prod.fst hxy
  rw [h, Finset.card_image_of_injective _ hinj, Finset.card_univ]

/-- The OR-part of a fibre is exactly `{(1, c), (c, 1)}`. -/
theorem orFiber_eq (c : G) : orFiber c = {(1, c), (c, 1)} := by
  ext z
  obtain ⟨x, y⟩ := z
  simp only [orFiber, prodFiber, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_insert, Finset.mem_singleton, Prod.mk.injEq]
  constructor
  · rintro ⟨hxy, rfl | rfl⟩
    · exact Or.inl ⟨rfl, by simpa using hxy⟩
    · exact Or.inr ⟨by simpa using hxy, rfl⟩
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;> simp

/-- **The `1` versus `2` dichotomy.**  Among the `n` value pairs producing a
given class `c` of `N`, exactly one has a split factor when `c = 1`, and exactly
two when `c ≠ 1`. -/
theorem card_orFiber (c : G) : (orFiber c).card = if c = 1 then 1 else 2 := by
  rw [orFiber_eq]
  by_cases hc : c = 1
  · subst hc; simp
  · rw [if_neg hc, Finset.card_insert_of_notMem (by simp [Prod.ext_iff, hc]),
      Finset.card_singleton]

/-- **The OR marginal count**: `2n - 1` of the `n²` value pairs make the OR true. -/
theorem card_orEvent : (orEvent G).card = 2 * Fintype.card G - 1 := by
  classical
  have hsplit : orEvent G = (({1} : Finset G) ×ˢ (Finset.univ : Finset G)) ∪
      ((Finset.univ : Finset G) ×ˢ ({1} : Finset G)) := by
    ext z
    obtain ⟨x, y⟩ := z
    simp [orEvent, Prod.ext_iff, eq_comm]
  have hinter : (({1} : Finset G) ×ˢ (Finset.univ : Finset G)) ∩
      ((Finset.univ : Finset G) ×ˢ ({1} : Finset G)) = {((1 : G), (1 : G))} := by
    ext z
    obtain ⟨x, y⟩ := z
    simp [Prod.ext_iff, eq_comm]
  have hcard := Finset.card_union_add_card_inter
    (({1} : Finset G) ×ˢ (Finset.univ : Finset G))
    ((Finset.univ : Finset G) ×ˢ ({1} : Finset G))
  rw [hinter, Finset.card_singleton] at hcard
  have h1 : ((({1} : Finset G) ×ˢ (Finset.univ : Finset G))).card = Fintype.card G := by
    simp [Finset.card_univ]
  have h2 : (((Finset.univ : Finset G) ×ˢ ({1} : Finset G))).card = Fintype.card G := by
    simp [Finset.card_univ]
  rw [h1, h2] at hcard
  rw [hsplit]
  omega

end CharacterGroup

/-! ## 2. The binary OR channel -/

/-- The two conditional OR laws: on the class `χ(N) = 1` the OR holds with
probability `1/n`, on the classes `χ(N) ≠ 1` with probability `2/n`. -/
noncomputable def orCond (n : ℝ) : Fin 2 → Fin 2 → ℝ :=
  ![![(n - 1) / n, 1 / n], ![(n - 2) / n, 2 / n]]

/-- The joint law of (class of `N`, OR of the two split events). -/
noncomputable def orJoint (n : ℝ) : Fin 2 → Fin 2 → ℝ := fun a t => prior n a * orCond n a t

/-- The OR marginal: `P(OR) = (2n-1)/n²`. -/
noncomputable def orMarg (n : ℝ) : Fin 2 → ℝ := ![((n - 1) / n) ^ 2, (2 * n - 1) / n ^ 2]

section Rates

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- **The counting rates are the channel.**  The conditional probability of the
OR event given the class `c` of `N`, computed by counting character-value pairs,
is exactly the corresponding entry of `orCond`. -/
theorem orRate_eq_channel (c : G) :
    ((orFiber c).card : ℝ) / (prodFiber c).card
      = orCond (Fintype.card G) (if c = 1 then 0 else 1) 1 := by
  rw [card_prodFiber, card_orFiber]
  by_cases hc : c = 1 <;> simp [hc, orCond]

/-- **The OR marginal law** `P(OR) = (2n-1)/n²`, from pure counting. -/
theorem orEvent_rate :
    ((orEvent G).card : ℝ) / (Fintype.card G : ℝ) ^ 2
      = (2 * (Fintype.card G : ℝ) - 1) / (Fintype.card G : ℝ) ^ 2 := by
  have hG : 0 < Fintype.card G := Fintype.card_pos
  have hcast : ((orEvent G).card : ℝ) = 2 * (Fintype.card G : ℝ) - 1 := by
    rw [card_orEvent]
    have : 1 ≤ 2 * Fintype.card G := by omega
    push_cast [Nat.cast_sub this]
    ring
  rw [hcast]

end Rates

/-! ## 3. The exact law -/

variable {n : ℝ}

/-- The OR face of the split-count fork is the binary channel `orJoint`. -/
theorem push_or_eq_orJoint (hn : 2 ≤ n) : push (forkJoint n) orMap = orJoint n := by
  have hn0 : (0:ℝ) ≠ n := by intro h; rw [← h] at hn; linarith
  funext a t
  fin_cases a <;> fin_cases t <;>
    simp [push_fin3, forkJoint, prior, SplitCountChannel.cond, orMap, orCond, orJoint,
      Fin.sum_univ_three]

lemma orCond_nonneg (hn : 2 ≤ n) : ∀ a t, 0 ≤ orCond n a t := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a t
  fin_cases a <;> fin_cases t <;>
    · simp only [orCond]
      exact div_nonneg (by linarith) hn0.le

lemma orCond_sum (hn : 2 ≤ n) : ∀ a, ∑ t, orCond n a t = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a
  fin_cases a
  · rw [Fin.sum_univ_two]
    show (n - 1) / n + 1 / n = 1
    field_simp
    ring
  · rw [Fin.sum_univ_two]
    show (n - 2) / n + 2 / n = 1
    field_simp
    ring

lemma colMarg_orJoint (hn : 2 ≤ n) : colMarg (orJoint n) = orMarg n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext t
  fin_cases t <;>
    · simp [colMarg, orJoint, prior, orCond, orMarg, Fin.sum_univ_two]
      field_simp
      ring

lemma orMarg_pos (hn : 2 ≤ n) : ∀ t, 0 < orMarg n t := by
  have hn0 : (0:ℝ) < n := by linarith
  have h0 : (0:ℝ) < ((n - 1) / n) ^ 2 := by
    have : (0:ℝ) < (n - 1) / n := div_pos (by linarith) hn0
    positivity
  have h1 : (0:ℝ) < (2 * n - 1) / n ^ 2 := div_pos (by linarith) (by positivity)
  intro t
  fin_cases t
  · simpa [orMarg] using h0
  · simpa [orMarg] using h1

lemma colMarg_orJoint_pos (hn : 2 ≤ n) : ∀ t, 0 < colMarg (orJoint n) t := by
  rw [colMarg_orJoint hn]; exact orMarg_pos hn

lemma rowMarg_orJoint (hn : 2 ≤ n) (a : Fin 2) : rowMarg (orJoint n) a = prior n a := by
  simp only [rowMarg, orJoint, ← Finset.mul_sum, orCond_sum hn a, mul_one]

lemma orJoint_nonneg (hn : 2 ≤ n) : ∀ a t, 0 ≤ orJoint n a t :=
  fun a t => mul_nonneg (prior_nonneg hn a) (orCond_nonneg hn a t)

/-- Binary entropy in bits. -/
noncomputable def Hb (x : ℝ) : ℝ := -(x * logb 2 x) - ((1 - x) * logb 2 (1 - x))

/-- `Hb` is symmetric under `x ↦ 1 - x`. -/
lemma Hb_symm (x : ℝ) : Hb (1 - x) = Hb x := by
  simp only [Hb, sub_sub_cancel]
  ring

lemma entropyBits_pair {x y : ℝ} (h : x + y = 1) : entropyBits ![x, y] = Hb y := by
  have hx : x = 1 - y := by linarith
  subst hx
  simp only [entropyBits, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one, Hb]
  ring

/-- **The OR-collapse function** `g(n)`. -/
noncomputable def gOR (n : ℝ) : ℝ :=
  Hb ((2 * n - 1) / n ^ 2) - (1 / n) * Hb (1 / n) - ((n - 1) / n) * Hb (2 / n)

/-- **THE OR-COLLAPSE LAW.**  For every order `n ≥ 2` the information that the
residue class of a semiprime `N` carries about the OR of the two split events is
exactly `g(n)`, independent of the field, its degree and its conductor. -/
theorem or_collapse_law (hn : 2 ≤ n) : Ior n = gOR n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn0' : n ≠ 0 := ne_of_gt hn0
  have hchan : Ior n = mutualInfo (fun a t => prior n a * orCond n a t) := by
    rw [Ior, push_or_eq_orJoint hn]; rfl
  have hcol : ∀ t, 0 < colMarg (fun a t => prior n a * orCond n a t) t := by
    intro t
    have := colMarg_orJoint_pos hn t
    simpa [orJoint] using this
  have h := mutualInfo_of_channel (prior n) (orCond n) (prior_nonneg hn) (orCond_nonneg hn)
    (orCond_sum hn) hcol
  have hcolm : colMarg (fun a t => prior n a * orCond n a t) = orMarg n := by
    have := colMarg_orJoint hn
    simpa [orJoint] using this
  rw [hchan, h, hcolm, Fin.sum_univ_two]
  have e0 : entropyBits (orMarg n) = Hb ((2 * n - 1) / n ^ 2) := by
    have hsum : ((n - 1) / n) ^ 2 + (2 * n - 1) / n ^ 2 = 1 := by field_simp; ring
    have : orMarg n = ![((n - 1) / n) ^ 2, (2 * n - 1) / n ^ 2] := rfl
    rw [this, entropyBits_pair hsum]
  have e1 : entropyBits (orCond n 0) = Hb (1 / n) := by
    have hsum : (n - 1) / n + 1 / n = 1 := by field_simp; ring
    have : orCond n 0 = ![(n - 1) / n, 1 / n] := rfl
    rw [this, entropyBits_pair hsum]
  have e2 : entropyBits (orCond n 1) = Hb (2 / n) := by
    have hsum : (n - 2) / n + 2 / n = 1 := by field_simp; ring
    have : orCond n 1 = ![(n - 2) / n, 2 / n] := rfl
    rw [this, entropyBits_pair hsum]
  rw [e0, e1, e2]
  simp only [gOR, prior, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring


/-! ## 4. Exact closed forms of `g(n)` -/

private lemma logb_two_one : logb 2 (2:ℝ) = 1 := by simp

private lemma logb_four_val : logb 2 (4:ℝ) = 2 := by
  rw [show (4:ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb_pow]; simp

private lemma logb_sixteen : logb 2 (16:ℝ) = 4 := by
  rw [show (16:ℝ) = 2 ^ (4:ℕ) by norm_num, Real.logb_pow]; simp

private lemma logb_nine_val : logb 2 (9:ℝ) = 2 * logb 2 3 := by
  rw [show (9:ℝ) = 3 ^ (2:ℕ) by norm_num, Real.logb_pow]; ring

private lemma logb_twentyfive : logb 2 (25:ℝ) = 2 * logb 2 5 := by
  rw [show (25:ℝ) = 5 ^ (2:ℕ) by norm_num, Real.logb_pow]; ring

/-- `g(2) = 3/2 - (3/4) log₂ 3 = 0.3113…`: the quadratic case, which the lab
measured both as the `p-1`, `ℓ = 3` symmetric OR and as `Q(√5)`. -/
theorem gOR_two : gOR 2 = 3 / 2 - 3 / 4 * logb 2 3 := by
  rw [← or_collapse_law le_rfl, Ior_two]

/-- `g(3) = log₂ 3 - (5/9) log₂ 5 - 2/9 = 0.0728…`: the cyclic cubic case. -/
theorem gOR_three : gOR 3 = logb 2 3 - 5 / 9 * logb 2 5 - 2 / 9 := by
  rw [← or_collapse_law (by norm_num), Ior_three]

/-- `g(8) = 31/8 + (27/64) log₂ 3 - (15/64) log₂ 5 - (91/64) log₂ 7`. -/
theorem gOR_eight :
    gOR 8 = 31/8 + 27/64 * logb 2 3 - 15/64 * logb 2 5 - 91/64 * logb 2 7 := by
  rw [← or_collapse_law (by norm_num), Ior_eight]

/-- `g(4) = 11/4 - (15/16) log₂ 3 - (7/16) log₂ 7 = 0.0359…`: the quartic case
(`Q(ζ₁₆)⁺`, conductor `16`, non-cyclic unit group). -/
theorem gOR_four : gOR 4 = 11/4 - 15/16 * logb 2 3 - 7/16 * logb 2 7 := by
  have h1 : logb 2 ((7:ℝ)/16) = logb 2 7 - 4 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_sixteen]
  have h2 : logb 2 ((9:ℝ)/16) = 2 * logb 2 3 - 4 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_nine_val, logb_sixteen]
  have h3 : logb 2 ((1:ℝ)/4) = -2 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_four_val]; simp
  have h4 : logb 2 ((3:ℝ)/4) = logb 2 3 - 2 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_four_val]
  have h5 : logb 2 ((1:ℝ)/2) = -1 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_two_one]; simp
  simp only [gOR, Hb]
  norm_num [h1, h2, h3, h4, h5]
  ring

/-- `g(5) = log₂ 5 - (6/25) log₂ 3 - 48/25 = 0.0215…`: the quintic case
(`Q(ζ₁₁)⁺`, conductor `11`). -/
theorem gOR_five : gOR 5 = logb 2 5 - 6/25 * logb 2 3 - 48/25 := by
  have h1 : logb 2 ((9:ℝ)/25) = 2 * logb 2 3 - 2 * logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_nine_val, logb_twentyfive]
  have h2 : logb 2 ((16:ℝ)/25) = 4 - 2 * logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_sixteen, logb_twentyfive]
  have h3 : logb 2 ((1:ℝ)/5) = -logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]; simp
  have h4 : logb 2 ((4:ℝ)/5) = 2 - logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_four_val]
  have h5 : logb 2 ((2:ℝ)/5) = 1 - logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num), logb_two_one]
  have h6 : logb 2 ((3:ℝ)/5) = logb 2 3 - logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]
  simp only [gOR, Hb]
  norm_num [h1, h2, h3, h4, h5, h6]
  ring

/-! ## 5. Rational certificates and the measured decay chain -/

private lemma logb_lower' {x : ℝ} {a b : ℕ} (h : (2:ℝ) ^ a < x ^ b) :
    (a : ℝ) < b * logb 2 x := by
  have := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
  rwa [Real.logb_pow, Real.logb_pow, logb_two_one, mul_one] at this

private lemma logb_upper' {x : ℝ} (hx : 0 < x) {a b : ℕ} (h : x ^ b < (2:ℝ) ^ a) :
    (b : ℝ) * logb 2 x < a := by
  have := Real.logb_lt_logb (b := 2) (by norm_num) (pow_pos hx b) h
  rwa [Real.logb_pow, Real.logb_pow, logb_two_one, mul_one] at this

lemma logb_three_gt' : (84:ℝ)/53 < logb 2 3 := by
  have h := logb_lower' (x := (3:ℝ)) (a := 84) (b := 53)
    (by exact_mod_cast (by decide +kernel : (2:ℕ) ^ 84 < 3 ^ 53))
  push_cast at h; linarith

lemma logb_three_lt' : logb 2 3 < 65/41 := by
  have h := logb_upper' (x := (3:ℝ)) (by norm_num) (a := 65) (b := 41)
    (by exact_mod_cast (by decide +kernel : (3:ℕ) ^ 41 < 2 ^ 65))
  push_cast at h; linarith

lemma logb_five_gt' : (339:ℝ)/146 < logb 2 5 := by
  have h := logb_lower' (x := (5:ℝ)) (a := 339) (b := 146)
    (by exact_mod_cast (by decide +kernel : (2:ℕ) ^ 339 < 5 ^ 146))
  push_cast at h; linarith

lemma logb_five_lt' : logb 2 5 < 137/59 := by
  have h := logb_upper' (x := (5:ℝ)) (by norm_num) (a := 137) (b := 59)
    (by exact_mod_cast (by decide +kernel : (5:ℕ) ^ 59 < 2 ^ 137))
  push_cast at h; linarith

lemma logb_seven_gt' : (306:ℝ)/109 < logb 2 7 := by
  have h := logb_lower' (x := (7:ℝ)) (a := 306) (b := 109)
    (by exact_mod_cast (by decide +kernel : (2:ℕ) ^ 306 < 7 ^ 109))
  push_cast at h; linarith

lemma logb_seven_lt' : logb 2 7 < 73/26 := by
  have h := logb_upper' (x := (7:ℝ)) (by norm_num) (a := 73) (b := 26)
    (by exact_mod_cast (by decide +kernel : (7:ℕ) ^ 26 < 2 ^ 73))
  push_cast at h; linarith

/-- The measured `n = 2` value `0.3113` is certified. -/
theorem gOR_two_bracket : 0.3109 < gOR 2 ∧ gOR 2 < 0.3114 := by
  rw [gOR_two]
  constructor <;> [have := logb_three_lt'; have := logb_three_gt'] <;> linarith

/-- The measured `n = 3` value `0.0728` is certified. -/
theorem gOR_three_bracket : 0.0726 < gOR 3 ∧ gOR 3 < 0.0732 := by
  rw [gOR_three]
  have a1 := logb_three_gt'
  have a2 := logb_three_lt'
  have b1 := logb_five_gt'
  have b2 := logb_five_lt'
  constructor <;> linarith

/-- The measured `n = 4` value `0.0359` is certified. -/
theorem gOR_four_bracket : 0.0353 < gOR 4 ∧ gOR 4 < 0.0360 := by
  rw [gOR_four]
  have a1 := logb_three_gt'
  have a2 := logb_three_lt'
  have c1 := logb_seven_gt'
  have c2 := logb_seven_lt'
  constructor <;> linarith

/-- The measured `n = 5` value `0.0215` is certified. -/
theorem gOR_five_bracket : 0.0214 < gOR 5 ∧ gOR 5 < 0.0217 := by
  rw [gOR_five]
  have a1 := logb_three_gt'
  have a2 := logb_three_lt'
  have b1 := logb_five_gt'
  have b2 := logb_five_lt'
  constructor <;> linarith

/-- **The decay chain** measured in the lab: `g(5) < g(4) < g(3) < g(2)`. -/
theorem gOR_decay : gOR 5 < gOR 4 ∧ gOR 4 < gOR 3 ∧ gOR 3 < gOR 2 := by
  obtain ⟨h2l, -⟩ := gOR_two_bracket
  obtain ⟨h3l, h3u⟩ := gOR_three_bracket
  obtain ⟨h4l, h4u⟩ := gOR_four_bracket
  obtain ⟨-, h5u⟩ := gOR_five_bracket
  exact ⟨by linarith, by linarith, by linarith⟩


/-! ## 6. The fork never fully collapses -/

lemma prior_pos (hn : 2 ≤ n) : ∀ a, 0 < prior n a := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a
  fin_cases a
  · simpa [prior] using (by positivity : (0:ℝ) < 1 / n)
  · simpa [prior] using div_pos (by linarith) hn0

lemma rowMarg_orJoint_pos (hn : 2 ≤ n) : ∀ a, 0 < rowMarg (orJoint n) a := by
  intro a; rw [rowMarg_orJoint hn]; exact prior_pos hn a

/-- **The OR face is never vacuous.**  For every order `n ≥ 2` the residue class
of `N` retains strictly positive information about the OR of the split events. -/
theorem gOR_pos (hn : 2 ≤ n) : 0 < gOR n := by
  have hn0 : (0:ℝ) < n := by linarith
  rw [← or_collapse_law hn, Ior, push_or_eq_orJoint hn]
  have htot : ∑ a, rowMarg (orJoint n) a = 1 := by
    rw [Finset.sum_congr rfl (fun a _ => rowMarg_orJoint hn a)]
    exact prior_sum hn
  refine mutualInfo_pos (orJoint n) (orJoint_nonneg hn) (rowMarg_orJoint_pos hn)
    (colMarg_orJoint_pos hn) htot (a₀ := 0) (b₀ := 1) ?_
  rw [rowMarg_orJoint hn, colMarg_orJoint hn]
  have hleft : orJoint n 0 1 = 1 / n * (1 / n) := rfl
  have hright : prior n 0 * orMarg n 1 = 1 / n * ((2 * n - 1) / n ^ 2) := rfl
  rw [hleft, hright]
  intro hcon
  have hn2 : n = 2 * n - 1 := by
    field_simp at hcon
    nlinarith [hcon]
  linarith

/-! ## 7. The χ²-collapse bound and the universal cap -/

/-- Pointwise `KL ≤ χ²` step: `p log₂(p/(rc)) ≤ (p²/(rc) - p)/log 2`. -/
lemma logb_cell_bound {p r c : ℝ} (hp : 0 ≤ p) (hr : 0 < r) (hc : 0 < c) :
    p * logb 2 (p / (r * c)) ≤ (p * p / (r * c) - p) / Real.log 2 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le hp with h | hp'
  · simp [← h]
  · have hx : 0 < p / (r * c) := by positivity
    have hlog : Real.log (p / (r * c)) ≤ p / (r * c) - 1 := Real.log_le_sub_one_of_pos hx
    have h1 : p * Real.log (p / (r * c)) ≤ p * (p / (r * c) - 1) :=
      mul_le_mul_of_nonneg_left hlog hp
    have h2 : p * (p / (r * c) - 1) = p * p / (r * c) - p := by field_simp
    rw [Real.logb, mul_div_assoc']
    exact div_le_div_of_nonneg_right (by linarith) hl2.le

/-- **The χ²-collapse bound.**  For every order `n ≥ 2`,
`g(n) ≤ 1 / (log 2 · (n-1)(2n-1))`; in particular the collapse is of order
`1/n²`.  The bound comes from the χ²-divergence of the two-point OR channel,
whose exact value is `1/((n-1)(2n-1))`. -/
theorem gOR_le_chiSq (hn : 2 ≤ n) : gOR n ≤ 1 / (Real.log 2 * ((n - 1) * (2 * n - 1))) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have hn2 : (0:ℝ) < 2 * n - 1 := by linarith
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [← or_collapse_law hn, Ior, push_or_eq_orJoint hn]
  have hcell : ∀ a t, orJoint n a t *
      logb 2 (orJoint n a t / (rowMarg (orJoint n) a * colMarg (orJoint n) t)) ≤
      (orJoint n a t * orJoint n a t / (rowMarg (orJoint n) a * colMarg (orJoint n) t)
        - orJoint n a t) / Real.log 2 := fun a t =>
    logb_cell_bound (orJoint_nonneg hn a t) (rowMarg_orJoint_pos hn a) (colMarg_orJoint_pos hn t)
  have hle : mutualInfo (orJoint n) ≤ ∑ a, ∑ t,
      (orJoint n a t * orJoint n a t / (rowMarg (orJoint n) a * colMarg (orJoint n) t)
        - orJoint n a t) / Real.log 2 :=
    Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun t _ => hcell a t))
  have hval : ∑ a, ∑ t,
      (orJoint n a t * orJoint n a t / (rowMarg (orJoint n) a * colMarg (orJoint n) t)
        - orJoint n a t) / Real.log 2 = 1 / (Real.log 2 * ((n - 1) * (2 * n - 1))) := by
    have e0 : n ≠ 0 := ne_of_gt hn0
    have e1 : n - 1 ≠ 0 := ne_of_gt hn1
    have e2 : 2 * n - 1 ≠ 0 := ne_of_gt hn2
    have e2' : -1 + n * 2 ≠ 0 := by intro h; exact e2 (by linarith)
    have e2'' : n * 2 - 1 ≠ 0 := by intro h; exact e2 (by linarith)
    have e3 : Real.log 2 ≠ 0 := ne_of_gt hl2
    simp only [rowMarg_orJoint hn, colMarg_orJoint hn, Fin.sum_univ_two, orJoint, prior, orCond,
      orMarg, Matrix.cons_val_zero, Matrix.cons_val_one]
    field_simp
    ring
  linarith [hle, hval.le, hval.ge]

/-- **The universal OR cap.**  No order-`n` Dirichlet fork yields more symmetric
OR information than the quadratic one: `g(n) ≤ g(2) = 0.3113…` bits. -/
theorem gOR_le_gOR_two (m : ℕ) (hm : 2 ≤ m) : gOR m ≤ gOR 2 := by
  have hl2 : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
  rcases eq_or_lt_of_le hm with h | h
  · rw [← h]; norm_num
  · have h3 : (3:ℝ) ≤ (m : ℝ) := by exact_mod_cast h
    have hb := gOR_le_chiSq (n := (m : ℝ)) (by linarith)
    have hprod : (10:ℝ) ≤ ((m : ℝ) - 1) * (2 * (m : ℝ) - 1) := by nlinarith
    have hpos : (0:ℝ) < Real.log 2 * (((m : ℝ) - 1) * (2 * (m : ℝ) - 1)) := by
      have : (0:ℝ) < Real.log 2 := by linarith
      nlinarith
    have hsmall : 1 / (Real.log 2 * (((m : ℝ) - 1) * (2 * (m : ℝ) - 1))) ≤ 1 / 6.9 := by
      apply one_div_le_one_div_of_le (by norm_num)
      nlinarith
    have h2 := gOR_two_bracket.1
    linarith

/-- **Total collapse in the large-order limit**: `g(n) → 0`. -/
theorem gOR_tendsto_zero : Filter.Tendsto gOR Filter.atTop (nhds 0) := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h1 : Filter.Tendsto (fun n : ℝ => n - 1) Filter.atTop Filter.atTop :=
    Filter.tendsto_atTop_add_const_right _ (-1) Filter.tendsto_id
  have h2 : Filter.Tendsto (fun n : ℝ => 2 * n - 1) Filter.atTop Filter.atTop := by
    apply Filter.tendsto_atTop_add_const_right _ (-1)
    exact Filter.Tendsto.const_mul_atTop (by norm_num) Filter.tendsto_id
  have h3 : Filter.Tendsto (fun n : ℝ => Real.log 2 * ((n - 1) * (2 * n - 1)))
      Filter.atTop Filter.atTop :=
    Filter.Tendsto.const_mul_atTop hl2 (h1.atTop_mul_atTop₀ h2)
  have h4 : Filter.Tendsto (fun n : ℝ => (Real.log 2 * ((n - 1) * (2 * n - 1)))⁻¹)
      Filter.atTop (nhds 0) := by
    simpa only [Pi.inv_apply] using h3.inv_tendsto_atTop
  refine squeeze_zero' ?_ ?_ h4
  · filter_upwards [Filter.eventually_ge_atTop (2:ℝ)] with n hn using (gOR_pos hn).le
  · filter_upwards [Filter.eventually_ge_atTop (2:ℝ)] with n hn
    rw [← one_div]
    exact gOR_le_chiSq hn


/-! ## 8. A matching lower bound: the collapse has order exactly `n⁻²` -/

lemma colMarg_orJoint_sum (hn : 2 ≤ n) : ∑ t, colMarg (orJoint n) t = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  rw [colMarg_orJoint hn, Fin.sum_univ_two]
  show ((n - 1) / n) ^ 2 + (2 * n - 1) / n ^ 2 = 1
  field_simp
  ring

/-- Each row of the OR table contributes a nonnegative (Kullback–Leibler) amount. -/
lemma orRow_nonneg (hn : 2 ≤ n) (a : Fin 2) :
    0 ≤ ∑ t, orJoint n a t *
      logb 2 (orJoint n a t / (rowMarg (orJoint n) a * colMarg (orJoint n) t)) := by
  have h := logsum_inequality_logb (Finset.univ : Finset (Fin 2)) (fun t => orJoint n a t)
    (fun t => rowMarg (orJoint n) a * colMarg (orJoint n) t)
    (fun t _ => orJoint_nonneg hn a t)
    (fun t _ => mul_pos (rowMarg_orJoint_pos hn a) (colMarg_orJoint_pos hn t))
  have hA : ∑ t, orJoint n a t = rowMarg (orJoint n) a := rfl
  have hB : ∑ t, rowMarg (orJoint n) a * colMarg (orJoint n) t = rowMarg (orJoint n) a := by
    rw [← Finset.mul_sum, colMarg_orJoint_sum hn, mul_one]
  rw [hA, hB, div_self (ne_of_gt (rowMarg_orJoint_pos hn a)), Real.logb_one, mul_zero] at h
  exact h

/-- **Exact class-`χ(N) = 1` lower bound.**  Dropping the (nonnegative)
contribution of the non-trivial classes leaves the exact Kullback–Leibler term of
the class `χ(N) = 1`. -/
theorem gOR_ge_classZero (hn : 2 ≤ n) :
    (1 / n ^ 2) * ((n - 1) * logb 2 (n / (n - 1)) + logb 2 (n / (2 * n - 1))) ≤ gOR n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have hn2 : (0:ℝ) < 2 * n - 1 := by linarith
  rw [← or_collapse_law hn, Ior, push_or_eq_orJoint hn]
  have hmi : mutualInfo (orJoint n) =
      (∑ t, orJoint n 0 t *
        logb 2 (orJoint n 0 t / (rowMarg (orJoint n) 0 * colMarg (orJoint n) t))) +
      (∑ t, orJoint n 1 t *
        logb 2 (orJoint n 1 t / (rowMarg (orJoint n) 1 * colMarg (orJoint n) t))) := by
    rw [mutualInfo, Fin.sum_univ_two]
  have hq0 : orJoint n 0 0 / (rowMarg (orJoint n) 0 * colMarg (orJoint n) 0) = n / (n - 1) := by
    rw [rowMarg_orJoint hn, colMarg_orJoint hn]
    show 1 / n * ((n - 1) / n) / (1 / n * ((n - 1) / n) ^ 2) = n / (n - 1)
    field_simp
  have hq1 : orJoint n 0 1 / (rowMarg (orJoint n) 0 * colMarg (orJoint n) 1) = n / (2 * n - 1) := by
    rw [rowMarg_orJoint hn, colMarg_orJoint hn]
    show 1 / n * (1 / n) / (1 / n * ((2 * n - 1) / n ^ 2)) = n / (2 * n - 1)
    field_simp
  have hp0 : orJoint n 0 0 = (n - 1) / n ^ 2 := by
    show 1 / n * ((n - 1) / n) = (n - 1) / n ^ 2
    field_simp
  have hp1 : orJoint n 0 1 = 1 / n ^ 2 := by
    show 1 / n * (1 / n) = 1 / n ^ 2
    field_simp
  have hrow0 : (∑ t, orJoint n 0 t *
      logb 2 (orJoint n 0 t / (rowMarg (orJoint n) 0 * colMarg (orJoint n) t))) =
      (1 / n ^ 2) * ((n - 1) * logb 2 (n / (n - 1)) + logb 2 (n / (2 * n - 1))) := by
    rw [Fin.sum_univ_two, hq0, hq1, hp0, hp1]
    field_simp
  linarith [orRow_nonneg hn 1]

/-! ### Elementary logarithm estimates -/

private lemma log_ratio_lower {x : ℝ} (hx : 0 < x) :
    1 - x ≤ Real.log (1 / x) := by
  have h := Real.log_le_sub_one_of_pos hx
  have hlog : Real.log (1 / x) = -Real.log x := by
    rw [one_div, Real.log_inv]
  rw [hlog]
  linarith

/-- **The `n⁻²` lower bound.**  `n² g(n) ≥ (1 - 1/(2n))/log 2 - 1`, which tends to
`1/log 2 - 1 = 0.4427…` -/
theorem gOR_ge_explicit (hn : 2 ≤ n) :
    ((1 - 1 / (2 * n)) / Real.log 2 - 1) / n ^ 2 ≤ gOR n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have hn2 : (0:ℝ) < 2 * n - 1 := by linarith
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- `log (n/(n-1)) ≥ 1/n`
  have e1 : 1 / n ≤ Real.log (n / (n - 1)) := by
    have hx : (0:ℝ) < (n - 1) / n := div_pos hn1 hn0
    have h := log_ratio_lower hx
    have hinv : 1 / ((n - 1) / n) = n / (n - 1) := by field_simp
    rw [hinv] at h
    have : 1 - (n - 1) / n = 1 / n := by field_simp; ring
    linarith [this ▸ h]
  -- `log (n/(2n-1)) ≥ 1/(2n) - log 2`
  have e2 : 1 / (2 * n) - Real.log 2 ≤ Real.log (n / (2 * n - 1)) := by
    have hx : (0:ℝ) < (2 * n - 1) / (2 * n) := div_pos hn2 (by linarith)
    have h := log_ratio_lower hx
    have hinv : 1 / ((2 * n - 1) / (2 * n)) = 2 * n / (2 * n - 1) := by field_simp
    have hval : 1 - (2 * n - 1) / (2 * n) = 1 / (2 * n) := by field_simp; ring
    rw [hinv, hval] at h
    have hsplit : Real.log (2 * n / (2 * n - 1)) =
        Real.log 2 + Real.log (n / (2 * n - 1)) := by
      rw [show 2 * n / (2 * n - 1) = 2 * (n / (2 * n - 1)) by ring,
        Real.log_mul (by norm_num) (by positivity)]
    linarith [hsplit ▸ h]
  -- combine, in bits
  have key : (1 - 1 / (2 * n)) / Real.log 2 - 1 ≤
      (n - 1) * logb 2 (n / (n - 1)) + logb 2 (n / (2 * n - 1)) := by
    have b1 : (n - 1) * logb 2 (n / (n - 1)) = (n - 1) * Real.log (n / (n - 1)) / Real.log 2 := by
      rw [Real.logb]; ring
    have b2 : logb 2 (n / (2 * n - 1)) = Real.log (n / (2 * n - 1)) / Real.log 2 := rfl
    rw [b1, b2, ← add_div, le_div_iff₀ hl2, sub_mul, div_mul_cancel₀ _ (ne_of_gt hl2)]
    have hmul : (n - 1) * (1 / n) + (1 / (2 * n) - Real.log 2) ≤
        (n - 1) * Real.log (n / (n - 1)) + Real.log (n / (2 * n - 1)) := by
      have := mul_le_mul_of_nonneg_left e1 (le_of_lt hn1)
      linarith
    have harith : (n - 1) * (1 / n) + 1 / (2 * n) = 1 - 1 / (2 * n) := by field_simp; ring
    linarith
  have hpos : (0:ℝ) < n ^ 2 := by positivity
  have hmain := gOR_ge_classZero hn
  have hstep : ((1 - 1 / (2 * n)) / Real.log 2 - 1) / n ^ 2 ≤
      (1 / n ^ 2) * ((n - 1) * logb 2 (n / (n - 1)) + logb 2 (n / (2 * n - 1))) := by
    rw [div_eq_mul_inv, ← one_div, mul_comm]
    exact mul_le_mul_of_nonneg_left key (by positivity : (0:ℝ) ≤ 1 / n ^ 2)
  linarith

/-- **The collapse is of order exactly `n⁻²`.**  For every order `n ≥ 2`,
`0.08/n² ≤ g(n) ≤ 2/n²`. -/
theorem gOR_order_inv_sq (hn : 2 ≤ n) : 0.08 / n ^ 2 ≤ gOR n ∧ gOR n ≤ 2 / n ^ 2 := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have hn2 : (0:ℝ) < 2 * n - 1 := by linarith
  have hpos : (0:ℝ) < n ^ 2 := by positivity
  have hlow : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hup : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  constructor
  · refine le_trans ?_ (gOR_ge_explicit hn)
    apply div_le_div_of_nonneg_right _ (le_of_lt hpos)
    have h34 : (3:ℝ)/4 ≤ 1 - 1 / (2 * n) := by
      rw [le_sub_iff_add_le]
      have : 1 / (2 * n) ≤ 1 / 4 := by
        apply one_div_le_one_div_of_le (by norm_num)
        linarith
      linarith
    have hdiv : (3:ℝ)/4 / Real.log 2 ≤ (1 - 1 / (2 * n)) / Real.log 2 := by
      apply div_le_div_of_nonneg_right h34 (by linarith)
    have : (1.08:ℝ) ≤ 3/4 / Real.log 2 := by
      rw [le_div_iff₀ (by linarith)]
      nlinarith
    linarith
  · refine le_trans (gOR_le_chiSq hn) ?_
    have hden : (0:ℝ) < Real.log 2 * ((n - 1) * (2 * n - 1)) := by positivity
    rw [div_le_div_iff₀ hden hpos]
    nlinarith [sq_nonneg (n - 2), sq_nonneg n]


end OrCollapseLaw