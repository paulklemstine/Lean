import Probability.PRNGComplexityHierarchy
import Probability.PRNGRouterCapacity

/-!
# Exact enumeration of the linear-complexity filtration at order one (conjecture C1)

`FUTURE_DIRECTIONS.md` conjectures that over a finite field `K` with `q = |K|`
elements and for `n ≥ 2L`,
```
|lfsrWords K L n| = (q^{2L+1} + 1) / (q + 1),
```
a value bracketed by the proved bounds `q^L ≤ |lfsrWords K L n| ≤ q^{2L}`.  This
file **settles the case `L = 1`**, where the conjectured value is
`(q³ + 1) / (q + 1) = q² - q + 1`.

The order-one register over a field is the map `x ↦ c · x`, so its output is the
geometric word `x_t = cᵗ · s`.  Two facts drive the count:

* if the seed `s` is nonzero the pair `(s, c)` is *recoverable* from the first
  two symbols (`c = x₁ / x₀`), giving `q(q - 1)` distinct words;
* if the seed is zero the word is the all-zero word, whatever the taps.

So the order-one family has exactly `q(q-1) + 1 = q² - q + 1` members — strictly
between the general bounds `q` and `q²`, confirming that both are loose.

Main contents.

* `order_one_stream` — the order-one LFSR emits the geometric sequence `cᵗ s`.
* `lfsrWords_one_eq_image` — the order-one family is the image of the explicit
  parameter set `{(s, c) : s ≠ 0} ∪ {(0,0)}`.
* `card_lfsrWords_one` — **the exact count** `q² - q + 1`, for every `n ≥ 2`.
* `card_lfsrWords_one_eq_conjectured` — the same number written in the
  conjectured closed form `(q³ + 1) / (q + 1)`.
* `card_lfsrWords_one_lt_pow` — the count is *strictly* below the general upper
  bound `q^{2L}`, so the pigeonhole ceiling of `card_lfsrWords_le` is not tight.
-/

namespace Catalog.Probability.SeedRec

open Finset

section OrderOne

variable {K : Type*} [Field K]

/-- The order-one register over a field is multiplication by the single tap:
its output is the geometric sequence `t ↦ cᵗ · s`. -/
theorem order_one_stream (c σ : Fin 1 → K) (t : ℕ) :
    (lfsrPRNG c).stream σ t = c 0 ^ t * σ 0 := by
  induction t generalizing σ with
  | zero => simp [PRNG.stream, lfsrPRNG, lfsrOut]
  | succ t ih =>
      rw [PRNG.stream_succ]
      have hstep : (lfsrPRNG c).step σ = fun _ : Fin 1 => c 0 * σ 0 := by
        funext i
        have hi : (i : ℕ) = 0 := Nat.lt_one_iff.1 i.isLt
        simp only [lfsrPRNG, lfsrStep, hi]
        rw [dif_neg (by omega)]
        simp
      rw [hstep, ih]
      ring

/-- The length-`n` word emitted by the order-one register with tap `c` and seed
`s`: the geometric word. -/
def geomWord (n : ℕ) (p : K × K) : Fin n → K := fun i => p.2 ^ (i : ℕ) * p.1

theorem lfsr_pref_one (c σ : Fin 1 → K) (n : ℕ) :
    (lfsrPRNG c).pref n σ = geomWord n (σ 0, c 0) := by
  funext i
  simpa [geomWord] using order_one_stream c σ (i : ℕ)

variable (K) [Fintype K] [DecidableEq K]

/-- The parameter set that enumerates the order-one family without repetition:
all pairs with nonzero seed, plus the single degenerate pair `(0,0)`. -/
def geomParams : Finset (K × K) :=
  (({0}ᶜ : Finset K) ×ˢ (univ : Finset K)) ∪ {(0, 0)}

theorem mem_geomParams {p : K × K} : p ∈ geomParams K ↔ p.1 ≠ 0 ∨ p = (0, 0) := by
  simp only [geomParams, Finset.mem_union, Finset.mem_product, Finset.mem_compl,
    Finset.mem_singleton, Finset.mem_univ, and_true]

theorem card_geomParams :
    (geomParams K).card = Fintype.card K * (Fintype.card K - 1) + 1 := by
  have hdisj : Disjoint ((({0}ᶜ : Finset K) ×ˢ (univ : Finset K))) ({((0 : K), (0 : K))}) := by
    simp [Finset.disjoint_right]
  rw [geomParams, Finset.card_union_of_disjoint hdisj]
  simp [Finset.card_compl, Nat.mul_comm]

/-- The order-one family is exactly the image of the parameter set. -/
theorem lfsrWords_one_eq_image (n : ℕ) :
    lfsrWords K 1 n = (geomParams K).image (geomWord n) := by
  ext x
  constructor
  · intro hx
    rw [mem_lfsrWords] at hx
    obtain ⟨c, σ, hcσ⟩ := hx
    rw [lfsr_pref_one] at hcσ
    by_cases hs : σ 0 = 0
    · refine Finset.mem_image.2 ⟨(0, 0), ?_, ?_⟩
      · simp [geomParams]
      · rw [← hcσ]
        funext i
        rcases Nat.eq_zero_or_pos (i : ℕ) with hi | hi
        · simp [geomWord, hi, hs]
        · simp [geomWord, hs, zero_pow (by omega : (i : ℕ) ≠ 0)]
    · exact Finset.mem_image.2 ⟨(σ 0, c 0), by simp [geomParams, hs], hcσ⟩
  · intro hx
    obtain ⟨p, _, hp⟩ := Finset.mem_image.1 hx
    rw [mem_lfsrWords]
    exact ⟨fun _ => p.2, fun _ => p.1, by rw [lfsr_pref_one]; exact hp⟩

/-- Distinct parameters give distinct words, as soon as two symbols are
observed: the first symbol recovers the seed and the second the tap. -/
theorem geomWord_injOn (n : ℕ) (hn : 2 ≤ n) :
    Set.InjOn (geomWord (K := K) n) (geomParams K) := by
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  intro p hp p' hp' h
  have e0 : p.1 = p'.1 := by
    have := congrFun h ⟨0, h0⟩
    simpa [geomWord] using this
  have e1 : p.2 * p.1 = p'.2 * p'.1 := by
    have := congrFun h ⟨1, h1⟩
    simpa [geomWord] using this
  by_cases hs : p.1 = 0
  · have hp0 : p = (0, 0) := by
      rcases (mem_geomParams K).1 (Finset.mem_coe.1 hp) with h' | h'
      · exact absurd hs h'
      · exact h'
    have hs' : p'.1 = 0 := by rw [← e0, hs]
    have hp0' : p' = (0, 0) := by
      rcases (mem_geomParams K).1 (Finset.mem_coe.1 hp') with h' | h'
      · exact absurd hs' h'
      · exact h'
    rw [hp0, hp0']
  · have hc : p.2 = p'.2 := by
      rw [← e0] at e1
      exact mul_right_cancel₀ hs e1
    exact Prod.ext e0 hc

/-- **Exact enumeration at order one.** Over a finite field with `q` elements,
exactly `q(q-1) + 1 = q² - q + 1` words of any length `n ≥ 2` have linear
complexity at most one. -/
theorem card_lfsrWords_one (n : ℕ) (hn : 2 ≤ n) :
    (lfsrWords K 1 n).card = Fintype.card K * (Fintype.card K - 1) + 1 := by
  rw [lfsrWords_one_eq_image K n, Finset.card_image_of_injOn (geomWord_injOn K n hn),
    card_geomParams K]

/-- The count, in the closed form conjectured for general `L`:
`(q^{2L+1} + 1)/(q + 1)` at `L = 1`. -/
theorem card_lfsrWords_one_eq_conjectured (n : ℕ) (hn : 2 ≤ n) :
    (lfsrWords K 1 n).card * (Fintype.card K + 1) = Fintype.card K ^ 3 + 1 := by
  have hq : 1 ≤ Fintype.card K := Fintype.card_pos
  rw [card_lfsrWords_one K n hn]
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card K = m + 1 := ⟨Fintype.card K - 1, by omega⟩
  rw [hm, Nat.add_sub_cancel]
  ring

/-- The general upper bound `q^{2L}` of `card_lfsrWords_le` is **not** tight:
at order one the family is strictly smaller. -/
theorem card_lfsrWords_one_lt_pow (n : ℕ) (hn : 2 ≤ n) (hK : 2 ≤ Fintype.card K) :
    (lfsrWords K 1 n).card < Fintype.card K ^ (2 * 1) := by
  rw [card_lfsrWords_one K n hn]
  have : Fintype.card K ^ (2 * 1) = Fintype.card K * Fintype.card K := by ring
  rw [this]
  cases' Nat.exists_eq_add_of_le hK with m hm
  rw [hm]
  have : (2 + m) * (2 + m - 1) = (2 + m) * (1 + m) := by congr 1; omega
  rw [this]
  nlinarith [Nat.zero_le m]

/-- The general lower bound `q^L` of `card_lfsrWords_ge` is not tight either:
at order one the family is strictly larger. -/
theorem card_lfsrWords_one_gt_pow (n : ℕ) (hn : 2 ≤ n) (hK : 2 ≤ Fintype.card K) :
    Fintype.card K ^ 1 < (lfsrWords K 1 n).card := by
  rw [card_lfsrWords_one K n hn, pow_one]
  cases' Nat.exists_eq_add_of_le hK with m hm
  rw [hm]
  have : (2 + m) * (2 + m - 1) = (2 + m) * (1 + m) := by congr 1; omega
  rw [this]
  nlinarith [Nat.zero_le m]

/-- **The router capacity ceiling is not attained.** The router that tries every
LFSR of order `≤ 1` carries `1 + q²` seeds, but by the collapse theorem
`familyWords_lfsrFamily` it accepts exactly the `q² - q + 1` files of linear
complexity `≤ 1`: a deficit of exactly `q`.  This is the first exact instance of
the gap between a router's seed budget and its true coverage. -/
theorem card_familyWords_lfsrFamily_one (n : ℕ) (hn : 2 ≤ n) :
    (familyWords (lfsrFamily K 1) n).card = Fintype.card K * (Fintype.card K - 1) + 1 := by
  rw [familyWords_lfsrFamily K 1 n (by norm_num), card_lfsrWords_one K n hn]

theorem card_familyWords_lfsrFamily_one_lt_ceiling (n : ℕ) (hn : 2 ≤ n) :
    (familyWords (lfsrFamily K 1) n).card
      < ∑ i : Fin 2, Fintype.card ((Fin i.val → K) × (Fin i.val → K)) := by
  have hceil : (∑ i : Fin 2, Fintype.card ((Fin i.val → K) × (Fin i.val → K)))
      = 1 + Fintype.card K * Fintype.card K := by
    simp [Fin.sum_univ_two, Fintype.card_prod]
  have hq : 1 ≤ Fintype.card K := Fintype.card_pos
  rw [card_familyWords_lfsrFamily_one K n hn, hceil]
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card K = m + 1 := ⟨Fintype.card K - 1, by omega⟩
  rw [hm, Nat.add_sub_cancel]
  nlinarith [Nat.zero_le m]

end OrderOne

section SmallCases

/-- Cross-check against the tables of `ComputationalEvidence.md`: over `GF(3)`
the order-one family has `3 * 2 + 1 = 7` members, matching the enumerated value
(and `card_lfsrWords_two_one_four` of `PRNGEvidence.lean` gives the `q = 2`
value `3`). -/
theorem card_lfsrWords_one_zmod_three : (lfsrWords (ZMod 3) 1 4).card = 7 := by
  rw [card_lfsrWords_one (ZMod 3) 4 (by norm_num), ZMod.card]

end SmallCases

end Catalog.Probability.SeedRec