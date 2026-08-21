import Catalog.Bridges.BerggrenChernoffSeparation

/-!
# A converse to Chernoff separation: the Bhattacharyya speed limit

`BerggrenChernoffSeparation.lean` proved that two distinct Berggren walks are separated
*exponentially fast* by events of the first `n` letters.  The remaining open half of that
cycle's Conjecture 4 was the **sharp constant**: how fast can a depth-`n` test possibly be?

This file proves the matching converse bound.  For *every* event `A` determined by the first
`n` letters — that is, every union of depth-`n` cylinders — the two error probabilities
cannot both be smaller than an explicit exponential:

`bernoulli P A + bernoulli Q Aᶜ ≥ ½ β(P,Q)^{2n}`,  `β(P,Q) = ∑ₐ √(pₐ qₐ)`,

where `β` is the Bhattacharyya coefficient of the one-step laws.  Since `β < 1` exactly when
the walks differ (`bhatt_lt_one`), the exponential rate of separation of two Berggren walks is
at most `−2 log β`: no depth-`n` test beats the Bhattacharyya exponent.  Together with
`chernoff_separation` this brackets the true cutoff rate.

## Main results

* `wordCyl`, `wordEvent` : depth-`n` cylinders indexed by finite words, and the events of the
  first `n` letters; `wordCyl_partition`, `compl_wordEvent` show the word cylinders partition
  the boundary.
* `bernoulli_wordEvent` : the harmonic mass of such an event is the sum of the word masses.
* `sum_wordMass_univ` : the word masses form a probability vector on the `3ⁿ` words.
* `sum_sqrt_wordMass` : the Bhattacharyya coefficient of the depth-`n` laws factorises as
  `β^n` — the analogue at the level of affinities of `mgf_sumLetters`.
* `bhatt_pos`, `bhatt_lt_one` : `0 < β ≤ 1`, with `β < 1` iff the walks differ (strict AM–GM).
* `bhattacharyya_error_bound` : the finite-word inequality
  `∑_{w ∈ W} m_P(w) + ∑_{w ∉ W} m_Q(w) ≥ ½ β^{2n}`.
* `no_faster_separation` : the measure-theoretic form — every event of the first `n` letters
  has `bernoulli P A + bernoulli Q Aᶜ ≥ ½ β^{2n}`, so the separation rate proved in
  `chernoff_separation` can never exceed `−2 log β`.
-/

namespace BerggrenHarmonic

open MeasureTheory Set Finset
open scoped ENNReal

variable {n : ℕ}

/-! ## Words and the cylinders they name -/

/-- The boundary ray extending a finite word by zeros. -/
def wordExt (w : Fin n → Letter) : Bdry := fun k => if h : k < n then w ⟨k, h⟩ else 0

/-- The depth-`n` cylinder named by the finite word `w`. -/
def wordCyl (w : Fin n → Letter) : Set Bdry := cyl n (wordExt w)

lemma mem_wordCyl {w : Fin n → Letter} {x : Bdry} :
    x ∈ wordCyl w ↔ ∀ i : Fin n, x i = w i := by
  constructor
  · intro hx i
    have := hx i i.isLt
    simpa [wordExt, i.isLt] using this
  · intro hx i hi
    have := hx ⟨i, hi⟩
    simpa [wordExt, hi] using this

lemma measurableSet_wordCyl (w : Fin n → Letter) : MeasurableSet (wordCyl w) :=
  measurableSet_cyl n (wordExt w)

/-- The word of the first `n` letters of a ray. -/
def wordOf (n : ℕ) (x : Bdry) : Fin n → Letter := fun i => x i

lemma mem_wordCyl_wordOf (x : Bdry) : x ∈ wordCyl (wordOf n x) :=
  mem_wordCyl.2 (fun _ => rfl)

/-- The word cylinders partition the boundary: a ray lies in the cylinder of `w` iff `w` is
its own initial word. -/
lemma wordCyl_partition {w : Fin n → Letter} {x : Bdry} :
    x ∈ wordCyl w ↔ wordOf n x = w := by
  rw [mem_wordCyl]
  constructor
  · intro h; funext i; exact h i
  · intro h i; exact congrFun h i

lemma wordCyl_disjoint {w w' : Fin n → Letter} (h : w ≠ w') :
    Disjoint (wordCyl w) (wordCyl w') := by
  rw [Set.disjoint_left]
  intro x hx hx'
  exact h ((wordCyl_partition.1 hx).symm.trans (wordCyl_partition.1 hx'))

/-- The real-valued harmonic mass of a word. -/
noncomputable def wordMass (P : ProbVec) (w : Fin n → Letter) : ℝ := ∏ i, P.p (w i)

lemma wordMass_pos (P : ProbVec) (w : Fin n → Letter) : 0 < wordMass P w :=
  Finset.prod_pos (fun i _ => P.pos (w i))

lemma bernoulli_wordCyl (P : ProbVec) (w : Fin n → Letter) :
    bernoulli P (wordCyl w) = ENNReal.ofReal (wordMass P w) := by
  rw [wordCyl, bernoulli_cyl, wmass]
  have h1 : ∏ k ∈ Finset.range n, ENNReal.ofReal (P.p (wordExt w k))
      = ∏ i : Fin n, ENNReal.ofReal (P.p (w i)) := by
    rw [← Fin.prod_univ_eq_prod_range (fun k => ENNReal.ofReal (P.p (wordExt w k))) n]
    exact Finset.prod_congr rfl (fun i _ => by simp [wordExt, i.isLt])
  rw [h1, wordMass, ENNReal.ofReal_prod_of_nonneg (fun i _ => (P.pos (w i)).le)]

/-- The word masses of depth `n` form a probability vector on the `3ⁿ` words. -/
theorem sum_wordMass_univ (P : ProbVec) : ∑ w : Fin n → Letter, wordMass P w = 1 := by
  have h : ∏ _i : Fin n, (∑ a : Letter, P.p a) = 1 := by
    simp [P.sum_eq]
  rw [Finset.prod_univ_sum (fun _ : Fin n => (Finset.univ : Finset Letter))
      (fun _ a => P.p a), Fintype.piFinset_univ] at h
  simpa [wordMass] using h

/-- An event of the first `n` letters: the union of the cylinders of a finite set of words. -/
def wordEvent (W : Finset (Fin n → Letter)) : Set Bdry := ⋃ w ∈ W, wordCyl w

lemma measurableSet_wordEvent (W : Finset (Fin n → Letter)) : MeasurableSet (wordEvent W) := by
  refine Finset.measurableSet_biUnion W (fun w _ => measurableSet_wordCyl w)

lemma mem_wordEvent {W : Finset (Fin n → Letter)} {x : Bdry} :
    x ∈ wordEvent W ↔ wordOf n x ∈ W := by
  constructor
  · intro hx
    obtain ⟨w, hw, hxw⟩ := Set.mem_iUnion₂.1 hx
    rw [wordCyl_partition.1 hxw]
    exact hw
  · intro hx
    exact Set.mem_iUnion₂.2 ⟨wordOf n x, hx, mem_wordCyl_wordOf x⟩

/-- The complement of an event of the first `n` letters is the event of the complementary set
of words. -/
lemma compl_wordEvent (W : Finset (Fin n → Letter)) :
    (wordEvent W)ᶜ = wordEvent Wᶜ := by
  ext x
  simp [mem_wordEvent]

/-- The probability of an event of the first `n` letters. -/
noncomputable def probOf (P : ProbVec) (W : Finset (Fin n → Letter)) : ℝ :=
  ∑ w ∈ W, wordMass P w

lemma probOf_nonneg (P : ProbVec) (W : Finset (Fin n → Letter)) : 0 ≤ probOf P W :=
  Finset.sum_nonneg (fun w _ => (wordMass_pos P w).le)

/-- **The harmonic measure of an event of the first `n` letters is the sum of the word
masses.** -/
theorem bernoulli_wordEvent (P : ProbVec) (W : Finset (Fin n → Letter)) :
    bernoulli P (wordEvent W) = ENNReal.ofReal (probOf P W) := by
  rw [wordEvent, measure_biUnion_finset (fun w _ w' _ h => wordCyl_disjoint h)
      (fun w _ => measurableSet_wordCyl w)]
  rw [probOf, ENNReal.ofReal_sum_of_nonneg (fun w _ => (wordMass_pos P w).le)]
  exact Finset.sum_congr rfl (fun w _ => bernoulli_wordCyl P w)

/-! ## The Bhattacharyya coefficient -/

/-- The Bhattacharyya coefficient (affinity) of the one-step laws of two Berggren walks. -/
noncomputable def bhatt (P Q : ProbVec) : ℝ := ∑ a : Letter, Real.sqrt (P.p a * Q.p a)

theorem bhatt_pos (P Q : ProbVec) : 0 < bhatt P Q := by
  refine Finset.sum_pos (fun a _ => Real.sqrt_pos.2 (mul_pos (P.pos a) (Q.pos a))) ?_
  exact ⟨0, Finset.mem_univ 0⟩

lemma sqrt_mul_le_avg (u v : ℝ) (hu : 0 < u) (hv : 0 < v) :
    Real.sqrt (u * v) ≤ (u + v) / 2 := by
  have h1 : Real.sqrt (u * v) = Real.sqrt u * Real.sqrt v := Real.sqrt_mul hu.le v
  have hu' : Real.sqrt u ^ 2 = u := Real.sq_sqrt hu.le
  have hv' : Real.sqrt v ^ 2 = v := Real.sq_sqrt hv.le
  nlinarith [sq_nonneg (Real.sqrt u - Real.sqrt v)]

lemma sqrt_mul_lt_avg (u v : ℝ) (hu : 0 < u) (hv : 0 < v) (huv : u ≠ v) :
    Real.sqrt (u * v) < (u + v) / 2 := by
  have h1 : Real.sqrt (u * v) = Real.sqrt u * Real.sqrt v := Real.sqrt_mul hu.le v
  have hu' : Real.sqrt u ^ 2 = u := Real.sq_sqrt hu.le
  have hv' : Real.sqrt v ^ 2 = v := Real.sq_sqrt hv.le
  have hne : Real.sqrt u ≠ Real.sqrt v := by
    intro h
    exact huv (by rw [← hu', ← hv', h])
  have hsub : Real.sqrt u - Real.sqrt v ≠ 0 := sub_ne_zero.mpr hne
  have hpos : 0 < (Real.sqrt u - Real.sqrt v) ^ 2 :=
    lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hsub))
  nlinarith [hpos]

theorem bhatt_le_one (P Q : ProbVec) : bhatt P Q ≤ 1 := by
  have h : ∀ a : Letter, Real.sqrt (P.p a * Q.p a) ≤ (P.p a + Q.p a) / 2 :=
    fun a => sqrt_mul_le_avg _ _ (P.pos a) (Q.pos a)
  calc bhatt P Q ≤ ∑ a : Letter, (P.p a + Q.p a) / 2 :=
        Finset.sum_le_sum (fun a _ => h a)
    _ = 1 := by
        rw [← Finset.sum_div, Finset.sum_add_distrib, P.sum_eq, Q.sum_eq]
        norm_num

/-- **The Bhattacharyya coefficient detects distinct walks**: it is `< 1` as soon as the two
weight vectors differ. -/
theorem bhatt_lt_one (P Q : ProbVec) (h : ∃ a, P.p a ≠ Q.p a) : bhatt P Q < 1 := by
  obtain ⟨a₀, ha₀⟩ := h
  have hle : ∀ a : Letter, Real.sqrt (P.p a * Q.p a) ≤ (P.p a + Q.p a) / 2 :=
    fun a => sqrt_mul_le_avg _ _ (P.pos a) (Q.pos a)
  have hlt : Real.sqrt (P.p a₀ * Q.p a₀) < (P.p a₀ + Q.p a₀) / 2 :=
    sqrt_mul_lt_avg _ _ (P.pos a₀) (Q.pos a₀) ha₀
  have hsum : bhatt P Q < ∑ a : Letter, (P.p a + Q.p a) / 2 :=
    Finset.sum_lt_sum (fun a _ => hle a) ⟨a₀, Finset.mem_univ a₀, hlt⟩
  have : ∑ a : Letter, (P.p a + Q.p a) / 2 = 1 := by
    rw [← Finset.sum_div, Finset.sum_add_distrib, P.sum_eq, Q.sum_eq]
    norm_num
  linarith [this ▸ hsum]

/-- **Tensorisation of the affinity**: the Bhattacharyya coefficient of the depth-`n` laws is
the `n`-th power of the one-step coefficient. -/
theorem sum_sqrt_wordMass (P Q : ProbVec) :
    ∑ w : Fin n → Letter, Real.sqrt (wordMass P w * wordMass Q w) = (bhatt P Q) ^ n := by
  have hterm : ∀ w : Fin n → Letter,
      Real.sqrt (wordMass P w * wordMass Q w) = ∏ i, Real.sqrt (P.p (w i) * Q.p (w i)) := by
    intro w
    rw [wordMass, wordMass, ← Finset.prod_mul_distrib,
      Real.sqrt_prod _ (fun i _ => mul_nonneg (P.pos (w i)).le (Q.pos (w i)).le)]
  rw [Finset.sum_congr rfl (fun w _ => hterm w)]
  have := Finset.prod_univ_sum (fun _ : Fin n => (Finset.univ : Finset Letter))
      (fun (_ : Fin n) (a : Letter) => Real.sqrt (P.p a * Q.p a))
  rw [Fintype.piFinset_univ] at this
  rw [← this, bhatt, Finset.prod_const, Finset.card_univ, Fintype.card_fin]

/-! ## The speed limit -/

/-- **The Bhattacharyya error bound.**  For every set `W` of depth-`n` words, the sum of the
two error probabilities of the test "is the initial word in `W`?" is at least `½ β^{2n}`. -/
theorem bhattacharyya_error_bound (P Q : ProbVec) (W : Finset (Fin n → Letter)) :
    (1 / 2) * (bhatt P Q) ^ (2 * n) ≤ probOf P W + probOf Q Wᶜ := by
  classical
  set m : (Fin n → Letter) → ℝ := fun w => min (wordMass P w) (wordMass Q w) with hm
  set M : (Fin n → Letter) → ℝ := fun w => max (wordMass P w) (wordMass Q w) with hM
  have hm0 : ∀ w, 0 ≤ m w := fun w => le_min (wordMass_pos P w).le (wordMass_pos Q w).le
  have hM0 : ∀ w, 0 ≤ M w := fun w => le_max_of_le_left (wordMass_pos P w).le
  -- the two error probabilities dominate the total overlap mass
  have h1 : ∑ w ∈ W, m w ≤ probOf P W :=
    Finset.sum_le_sum (fun w _ => min_le_left _ _)
  have h2 : ∑ w ∈ Wᶜ, m w ≤ probOf Q Wᶜ :=
    Finset.sum_le_sum (fun w _ => min_le_right _ _)
  have hsplit : ∑ w ∈ W, m w + ∑ w ∈ Wᶜ, m w = ∑ w : Fin n → Letter, m w := by
    rw [← Finset.sum_add_sum_compl W m]
  -- Cauchy–Schwarz : (∑ √(m M))² ≤ (∑ m)(∑ M)
  have hprod : ∀ w : Fin n → Letter,
      Real.sqrt (wordMass P w * wordMass Q w) = Real.sqrt (m w) * Real.sqrt (M w) := by
    intro w
    rw [← Real.sqrt_mul (hm0 w)]
    congr 1
    rcases le_total (wordMass P w) (wordMass Q w) with h | h
    · simp [hm, hM, min_eq_left h, max_eq_right h]
    · simp [hm, hM, min_eq_right h, max_eq_left h, mul_comm]
  have hcs : (∑ w : Fin n → Letter, Real.sqrt (m w) * Real.sqrt (M w)) ^ 2 ≤
      (∑ w : Fin n → Letter, m w) * (∑ w : Fin n → Letter, M w) := by
    have := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset (Fin n → Letter))
      (fun w => Real.sqrt (m w)) (fun w => Real.sqrt (M w))
    calc (∑ w : Fin n → Letter, Real.sqrt (m w) * Real.sqrt (M w)) ^ 2
        ≤ (∑ w : Fin n → Letter, Real.sqrt (m w) ^ 2) *
            ∑ w : Fin n → Letter, Real.sqrt (M w) ^ 2 := this
      _ = (∑ w : Fin n → Letter, m w) * (∑ w : Fin n → Letter, M w) := by
          rw [Finset.sum_congr rfl (fun w _ => Real.sq_sqrt (hm0 w)),
            Finset.sum_congr rfl (fun w _ => Real.sq_sqrt (hM0 w))]
  -- the maxima sum to at most 2
  have hMsum : ∑ w : Fin n → Letter, M w ≤ 2 := by
    have hle : ∀ w : Fin n → Letter, M w ≤ wordMass P w + wordMass Q w := by
      intro w
      rcases le_total (wordMass P w) (wordMass Q w) with h | h
      · simp only [hM, max_eq_right h]
        linarith [(wordMass_pos P w).le]
      · simp only [hM, max_eq_left h]
        linarith [(wordMass_pos Q w).le]
    calc ∑ w : Fin n → Letter, M w
        ≤ ∑ w : Fin n → Letter, (wordMass P w + wordMass Q w) :=
          Finset.sum_le_sum (fun w _ => hle w)
      _ = 2 := by
          rw [Finset.sum_add_distrib, sum_wordMass_univ P, sum_wordMass_univ Q]
          norm_num
  -- put the pieces together
  have hbeta : ∑ w : Fin n → Letter, Real.sqrt (m w) * Real.sqrt (M w) = (bhatt P Q) ^ n := by
    rw [← sum_sqrt_wordMass P Q]
    exact (Finset.sum_congr rfl (fun w _ => (hprod w).symm))
  have hmsum_nonneg : 0 ≤ ∑ w : Fin n → Letter, m w :=
    Finset.sum_nonneg (fun w _ => hm0 w)
  have hkey : (bhatt P Q) ^ (2 * n) ≤ 2 * ∑ w : Fin n → Letter, m w := by
    have h3 : (bhatt P Q) ^ (2 * n) = ((bhatt P Q) ^ n) ^ 2 := by
      rw [← pow_mul, mul_comm]
    rw [h3, ← hbeta]
    calc (∑ w : Fin n → Letter, Real.sqrt (m w) * Real.sqrt (M w)) ^ 2
        ≤ (∑ w : Fin n → Letter, m w) * (∑ w : Fin n → Letter, M w) := hcs
      _ ≤ (∑ w : Fin n → Letter, m w) * 2 :=
          mul_le_mul_of_nonneg_left hMsum hmsum_nonneg
      _ = 2 * ∑ w : Fin n → Letter, m w := by ring
  linarith [h1, h2, hsplit, hkey]

/-- **No depth-`n` test separates two Berggren walks faster than the Bhattacharyya rate.**
For every event `A` of the first `n` letters, the two error probabilities satisfy
`bernoulli P A + bernoulli Q Aᶜ ≥ ½ β(P,Q)^{2n}`.  Since `β < 1` precisely when the walks
differ, the exponential separation rate of `chernoff_separation` is capped at `−2 log β`. -/
theorem no_faster_separation (P Q : ProbVec) (W : Finset (Fin n → Letter)) :
    (1 / 2) * (bhatt P Q) ^ (2 * n) ≤
      (bernoulli P (wordEvent W)).toReal + (bernoulli Q (wordEvent W)ᶜ).toReal := by
  rw [compl_wordEvent, bernoulli_wordEvent, bernoulli_wordEvent,
    ENNReal.toReal_ofReal (probOf_nonneg P W), ENNReal.toReal_ofReal (probOf_nonneg Q Wᶜ)]
  exact bhattacharyya_error_bound P Q W

/-- The separation is genuinely exponential and no faster: for distinct walks the lower bound
`½ β^{2n}` is positive for every `n`, with `0 < β < 1`. -/
theorem no_faster_separation_pos (P Q : ProbVec) (h : ∃ a, P.p a ≠ Q.p a) :
    0 < bhatt P Q ∧ bhatt P Q < 1 ∧
      ∀ (n : ℕ) (W : Finset (Fin n → Letter)),
        0 < (bernoulli P (wordEvent W)).toReal + (bernoulli Q (wordEvent W)ᶜ).toReal := by
  refine ⟨bhatt_pos P Q, bhatt_lt_one P Q h, fun n W => ?_⟩
  have hb := bhatt_pos P Q
  have := no_faster_separation P Q W
  have hpow : 0 < (bhatt P Q) ^ (2 * n) := pow_pos hb _
  linarith

end BerggrenHarmonic