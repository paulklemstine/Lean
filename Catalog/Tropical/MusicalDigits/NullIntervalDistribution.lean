import Mathlib
import Tropical.MusicalDigits.AutocorrelationMomentBridge

/-!
# The null interval distribution of a digit alphabet

Any empirical claim about the intervals of a digit melody has to be measured against the
distribution that pure combinatorics already forces.  For a base-`b` alphabet the number
of ordered digit pairs realizing a given pitch interval is

`pairCount b 0 = b`,  `pairCount b v = 2 (b - v)` for `1 ≤ v < b`,  `pairCount b v = 0`
for `v ≥ b`

(`pairCount_zero`, `pairCount_of_pos`, `pairCount_eq_zero_of_base_le`): the *triangular*
null distribution.  Its total mass is `b²` (`sum_pairCount`) and — the main arithmetic
result of this file — its second moment obeys the closed form

`6 · Σ_v v² · pairCount b v + b² = b⁴`   (`six_mul_sum_sq_pairCount`),

i.e. the mean squared interval of two independent uniform digits is `(b² - 1)/6`; for the
decimal scale this is the value `16.5` and `Σ_v v² · pairCount 10 v = 1650`
(`sum_sq_pairCount_ten`).

Combining with the moment bridge, a melody whose lag-`k` interval distribution is exactly
the null distribution has a *predetermined* autocorrelation deficit
(`null_autocorrelation_deficit`).  This is the quantitative baseline against which a
"lag-12 peak" must be compared: the peak is a statement about the unison mass `N(0)`,
whose null value is `b` out of `b²`, i.e. one tenth of the pairs in base ten.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the interval distribution of an unstructured digit melody
should be triangular, and its second moment should have a closed form polynomial in the
base — giving an exact null value for the autocorrelation deficit.

Experiment (Experimenter): `#eval` over base 10 gives the counts
`[10, 18, 16, 14, 12, 10, 8, 6, 4, 2]` and second moment `1650`; base 13 gives
`[13, 24, 22, …, 2]`.  The proofs split the interval fibre into the two images
`a ↦ (a, a+v)` and `a ↦ (a+v, a)`, which are disjoint exactly because `v ≥ 1`.

Analysis (Analyst): the closed form `b⁴ - b²` for `6 ·` the second moment was obtained by
an integer induction with the auxiliary square-sum identity; the ℕ statement is phrased
additively (`… + b² = b⁴`) to avoid truncated subtraction.

Critique (Critic): the null distribution is a statement about the *alphabet*, not about π;
no claim is made that any particular constant realizes it.  What is proved is the
conditional statement `null distribution ⇒ exact autocorrelation deficit`.
-/

namespace TropicalMusicalDigits

open Finset MusicalDigits

/-! ### The triangular null distribution -/

/-- The number of ordered pairs of base-`b` digits whose pitch interval is `v` semitones. -/
def pairCount (b v : ℕ) : ℕ :=
  (((range b) ×ˢ (range b)).filter fun p => Nat.dist p.1 p.2 = v).card

/-- Unisons: there are `b` ordered pairs of equal digits. -/
theorem pairCount_zero (b : ℕ) : pairCount b 0 = b := by
  classical
  have hset : ((range b) ×ˢ (range b)).filter (fun p => Nat.dist p.1 p.2 = 0)
      = (range b).image fun a => (a, a) := by
    ext ⟨a, c⟩
    simp only [mem_filter, mem_product, mem_range, mem_image, Prod.mk.injEq, Nat.dist]
    constructor
    · rintro ⟨⟨ha, _⟩, hd⟩; exact ⟨a, ha, rfl, by omega⟩
    · rintro ⟨t, ht, rfl, rfl⟩; exact ⟨⟨ht, ht⟩, by omega⟩
  have hinj : Function.Injective (fun a : ℕ => (a, a)) := by
    intro a b h; simpa using congrArg Prod.fst h
  rw [pairCount, hset, card_image_of_injective _ hinj, card_range]

/-- **Triangular law.**  For a nonzero interval value there are exactly `2 (b - v)`
ordered digit pairs realizing it. -/
theorem pairCount_of_pos {b v : ℕ} (hv : 0 < v) : pairCount b v = 2 * (b - v) := by
  classical
  have hset : ((range b) ×ˢ (range b)).filter (fun p => Nat.dist p.1 p.2 = v)
      = ((range (b - v)).image fun a => (a, a + v)) ∪
        ((range (b - v)).image fun a => (a + v, a)) := by
    ext ⟨a, c⟩
    simp only [mem_filter, mem_product, mem_range, mem_union, mem_image, Prod.mk.injEq,
      Nat.dist]
    constructor
    · rintro ⟨⟨ha, hc⟩, hd⟩
      rcases le_total a c with h | h
      · exact Or.inl ⟨a, by omega, rfl, by omega⟩
      · exact Or.inr ⟨c, by omega, by omega, rfl⟩
    · rintro (⟨t, ht, rfl, rfl⟩ | ⟨t, ht, rfl, rfl⟩) <;> refine ⟨⟨by omega, by omega⟩, by omega⟩
  have hdisj : Disjoint ((range (b - v)).image fun a => (a, a + v))
      ((range (b - v)).image fun a => (a + v, a)) := by
    rw [disjoint_left]
    rintro ⟨a, c⟩ h1 h2
    simp only [mem_image, mem_range, Prod.mk.injEq] at h1 h2
    obtain ⟨t, _, rfl, rfl⟩ := h1
    obtain ⟨s, _, hs1, hs2⟩ := h2
    omega
  have hinj1 : Function.Injective (fun a : ℕ => (a, a + v)) := by
    intro a b h; simpa using congrArg Prod.fst h
  have hinj2 : Function.Injective (fun a : ℕ => (a + v, a)) := by
    intro a b h; simpa using congrArg Prod.snd h
  rw [pairCount, hset, card_union_of_disjoint hdisj, card_image_of_injective _ hinj1,
    card_image_of_injective _ hinj2, card_range]
  omega

/-- No pair of base-`b` digits realizes an interval of `b` or more semitones; for `b = 10`
this is the vanishing of the octave value. -/
theorem pairCount_eq_zero_of_base_le {b v : ℕ} (hv : b ≤ v) : pairCount b v = 0 := by
  classical
  simp only [pairCount, card_eq_zero, filter_eq_empty_iff]
  rintro ⟨a, c⟩ hmem
  simp only [mem_product, mem_range] at hmem
  simp only [Nat.dist]
  omega

/-- The decimal alphabet has no octave: `pairCount 10 12 = 0`. -/
theorem pairCount_ten_octave : pairCount 10 12 = 0 :=
  pairCount_eq_zero_of_base_le (by norm_num)

/-- Total mass of the null distribution: all `b²` ordered digit pairs. -/
theorem sum_pairCount (b : ℕ) : ∑ v ∈ range b, pairCount b v = b ^ 2 := by
  classical
  have hmaps : ∀ p ∈ (range b) ×ˢ (range b), Nat.dist p.1 p.2 ∈ range b := by
    rintro ⟨a, c⟩ hmem
    simp only [mem_product, mem_range] at hmem
    simp only [mem_range, Nat.dist]
    omega
  have := card_eq_sum_card_fiberwise (f := fun p : ℕ × ℕ => Nat.dist p.1 p.2)
    (s := (range b) ×ˢ (range b)) (t := range b) hmaps
  simpa [pairCount, card_product, sq] using this.symm

/-! ### The closed form for the second moment -/

private lemma sum_sq_int (b : ℕ) :
    6 * ∑ v ∈ range b, ((v : ℤ)) ^ 2 = 2 * (b : ℤ) ^ 3 - 3 * (b : ℤ) ^ 2 + (b : ℤ) := by
  induction b with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, mul_add]; push_cast; push_cast at ih; linarith

private lemma sum_null_moment_int (b : ℕ) :
    6 * ∑ v ∈ range b, 2 * ((v : ℤ)) ^ 2 * ((b : ℤ) - v) = (b : ℤ) ^ 4 - (b : ℤ) ^ 2 := by
  induction b with
  | zero => simp
  | succ n ih =>
    have hsplit : ∑ v ∈ range (n + 1), 2 * ((v : ℤ)) ^ 2 * (((n : ℤ) + 1) - v)
        = (∑ v ∈ range n, 2 * ((v : ℤ)) ^ 2 * ((n : ℤ) - v))
          + (∑ v ∈ range n, 2 * ((v : ℤ)) ^ 2) + 2 * (n : ℤ) ^ 2 := by
      rw [Finset.sum_range_succ, ← Finset.sum_add_distrib]
      congr 1
      · exact Finset.sum_congr rfl fun v _ => by ring
      · ring
    have hq := sum_sq_int n
    push_cast
    push_cast at hsplit ih
    rw [hsplit]
    have h2 : (2 : ℤ) * ∑ v ∈ range n, ((v : ℤ)) ^ 2 = ∑ v ∈ range n, 2 * ((v : ℤ)) ^ 2 :=
      Finset.mul_sum _ _ _
    nlinarith [hq, ih, h2]

/-- The second moment of the null distribution, written without truncated subtraction. -/
theorem six_mul_sum_sq_pairCount (b : ℕ) :
    6 * ∑ v ∈ range b, v ^ 2 * pairCount b v + b ^ 2 = b ^ 4 := by
  have hterm : ∀ v ∈ range b, (v ^ 2 * pairCount b v : ℤ) = 2 * (v : ℤ) ^ 2 * ((b : ℤ) - v) := by
    intro v hv
    rcases Nat.eq_zero_or_pos v with rfl | hpos
    · simp
    · have hvb : v < b := mem_range.1 hv
      rw [pairCount_of_pos hpos]
      push_cast [Nat.cast_sub hvb.le]
      ring
  have hcast : ((∑ v ∈ range b, v ^ 2 * pairCount b v : ℕ) : ℤ)
      = ∑ v ∈ range b, 2 * (v : ℤ) ^ 2 * ((b : ℤ) - v) := by
    push_cast
    exact Finset.sum_congr rfl hterm
  have h := sum_null_moment_int b
  rw [← hcast] at h
  have : ((6 * ∑ v ∈ range b, v ^ 2 * pairCount b v + b ^ 2 : ℕ) : ℤ) = ((b ^ 4 : ℕ) : ℤ) := by
    push_cast
    push_cast at h
    linarith
  exact_mod_cast this

/-- The decimal case: the null second moment is `1650`, i.e. a mean squared interval of
`16.5` semitones² — the exact baseline for any empirical interval statistic. -/
theorem sum_sq_pairCount_ten : ∑ v ∈ range 10, v ^ 2 * pairCount 10 v = 1650 := by
  have h := six_mul_sum_sq_pairCount 10
  omega

/-! ### The null baseline for autocorrelation -/

/-- **Null autocorrelation deficit.**  If the lag-`k` interval distribution of a cyclic
digit melody is exactly `m` copies of the triangular null distribution, then its
autocorrelation deficit is completely determined by the base and the multiplicity:
`12 (energy - autocorrelation) = m (b⁴ - b²)`.  No structural assumption on the melody
enters; conversely a measured deficit differing from this value is the only legitimate
form of a "lag-`k` anomaly" claim. -/
theorem null_autocorrelation_deficit {b n : ℕ} (d : Fin n → ℕ) (hd : ∀ i, d i < b)
    (k : Fin n) (m : ℕ)
    (hnull : ∀ v, cycIntervalCount d k v = m * pairCount b v) :
    12 * (signalEnergy (toSignal d) - autocorrelation (toSignal d) k)
      = (m : ℝ) * ((b : ℝ) ^ 4 - (b : ℝ) ^ 2) := by
  have hmoment := autocorrelation_moment_identity d hd k
  have hsum : ∑ v ∈ range b, (v : ℝ) ^ 2 * (cycIntervalCount d k v : ℝ)
      = (m : ℝ) * ∑ v ∈ range b, (v : ℝ) ^ 2 * (pairCount b v : ℝ) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun v _ => ?_
    rw [hnull v]
    push_cast
    ring
  have hclosed : 6 * ∑ v ∈ range b, (v : ℝ) ^ 2 * (pairCount b v : ℝ)
      = (b : ℝ) ^ 4 - (b : ℝ) ^ 2 := by
    have h := six_mul_sum_sq_pairCount b
    have hcast : ((6 * ∑ v ∈ range b, v ^ 2 * pairCount b v + b ^ 2 : ℕ) : ℝ)
        = ((b ^ 4 : ℕ) : ℝ) := by exact_mod_cast congrArg (fun t : ℕ => (t : ℝ)) h
    push_cast at hcast
    linarith
  rw [hsum] at hmoment
  have h6 : (m : ℝ) * (6 * ∑ v ∈ range b, (v : ℝ) ^ 2 * (pairCount b v : ℝ))
      = (m : ℝ) * ((b : ℝ) ^ 4 - (b : ℝ) ^ 2) := by rw [hclosed]
  linarith [hmoment, h6]

/-- The decimal specialization: a melody with the null lag-`k` interval distribution has
autocorrelation deficit exactly `825 m`, where `n = 100 m` is the window length. -/
theorem null_autocorrelation_deficit_ten {n : ℕ} (d : Fin n → ℕ) (hd : ∀ i, d i < 10)
    (k : Fin n) (m : ℕ) (hnull : ∀ v, cycIntervalCount d k v = m * pairCount 10 v) :
    signalEnergy (toSignal d) - autocorrelation (toSignal d) k = 825 * (m : ℝ) := by
  have h := null_autocorrelation_deficit d hd k m hnull
  push_cast at h
  linarith

end TropicalMusicalDigits