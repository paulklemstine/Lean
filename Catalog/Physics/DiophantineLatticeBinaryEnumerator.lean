import Physics.DiophantineLatticeRankTwoStrict

/-!
# Cycle 10b: the covering weight enumerator of a binary lattice is a complete invariant

Conjecture D′ of the previous cycle asks for the structure of the **covering weight enumerator**
`W(Q) = {4·μ(v/2) : v ∈ L/2L}`, the multiset of coset minima of `Q` on the four cosets of `2L`
in `L` when `L = ℤ²`.  Cycle 8 computed `W` for `ℤⁿ` and cycle 9 for all diagonal forms; here the
computation is carried out for an **arbitrary** binary form, in the reduction domain
`0 < a`, `|b| ≤ a ≤ c`:

  `W(a x² + b x y + c y²) = {0, a, c, a + c − |b|}`,

with the four entries realised by the classes `(0,0)`, `(1,0)`, `(0,1)`, `(1,1)` respectively
(`reduced_gap_zero`, `reduced_gap_e0`, `reduced_gap_e1`, `reduced_gap_e01`), and every `2`-torsion
gap is one of them (`two_torsion_gap_mem`).  Consequently:

* `coverEnum_min_eq_minEnergy` : the smallest nonzero entry of `W` is the packing invariant `λ₁`
  (this is the rank-two case of the second half of Conjecture D′);
* `coverEnum_determines` : `W` determines the triple `(a, |b|, c)`, hence
* `coverEnum_complete_invariant` : in rank two the covering weight enumerator is a **complete**
  isometry invariant — two reduced binary lattices with the same `W` are isometric, by a
  coordinate sign flip.

The last statement is strictly stronger than "finer than the theta series": in rank two nothing
at all is lost.

## Lab notes

*Hypothesizer.*  Cycle 9 proved `min W = λ₁` for diagonal forms; if the same holds for binary
forms with a cross term, then `W` should see `|b|` through its top entry, and the three numbers
`a`, `c`, `a+c−|b|` would be recoverable from an unordered multiset because they are automatically
ordered: `a ≤ c ≤ a + c − |b|` in the reduction domain.

*Experimenter.*  Exact enumeration of the four coset minima for
`(a,b,c) ∈ {(1,0,1),(1,1,1),(2,1,3),(1,0,5),(3,2,7),(5,4,9),(2,2,3),(1,1,2),(3,3,3)}` produced
`{0, a, c, a+c−|b|}` in every case, e.g. `W(2x²+xy+3y²) = {0,2,3,4}`; see
`ComputationalEvidence.md`.  The hexagonal form is the unique case where the top entry collapses
to `λ₁`: `W(x²+xy+y²) = {0,1,1,1}`.

*Analyst.*  The coset minima are computed by three different integer inequalities, one per
nonzero class, all of them consequences of the single estimate
`a X² + b X Y + c Y² ≥ a (X² + Y² − |XY|)` valid in the reduction domain.  The recovery of
`(a,|b|,c)` from `W` uses only two order-theoretic facts (the least and the greatest entry) plus
the total sum, i.e. no case analysis on `b`.

*Critic.*  Two caveats.  (i) The enumerator is a multiset, so the hexagonal degeneracy
`{0,1,1,1}` must not break the recovery argument — it does not, because the argument uses
`min`, `max` and the sum rather than distinctness.  (ii) "Complete invariant" is asserted only
inside the reduction domain; combined with `exists_reduced_basis` of the previous file this is
no loss of generality, since every positive-definite binary form has a reduced representative.

*PI.*  In rank two Conjecture D′ is not merely true, it is optimal: `W` is a complete invariant,
so any isospectral pair separated by `W` must live in rank `≥ 3`.
-/

namespace DiophantineLattice
namespace RankTwo

open Finset

/-! ## The matrix of a binary form -/

/-- The Gram matrix of `a x² + b x y + c y²`. -/
def binMat (a b c : ℚ) : Matrix (Fin 2) (Fin 2) ℚ := !![a, b / 2; b / 2, c]

lemma form_binMat (a b c : ℚ) (x : Fin 2 → ℚ) : form (binMat a b c) x = bq a b c (x 0) (x 1) := by
  rw [form_eq_bq]
  norm_num [binMat, bq]

lemma binMat_value (a b c : ℚ) (t : Fin 2 → ℚ) (m : Fin 2 → ℤ) :
    form (binMat a b c) (fun i => t i - emb m i)
      = bq a b c (t 0 - ((m 0 : ℤ) : ℚ)) (t 1 - ((m 1 : ℤ) : ℚ)) := by
  rw [form_binMat]
  simp [emb]

lemma bq_half (a b c X Y : ℚ) : bq a b c (X / 2) (Y / 2) = bq a b c X Y / 4 := by
  unfold bq; ring

lemma binMat_halfPt_value (a b c : ℚ) (v m : Fin 2 → ℤ) :
    form (binMat a b c) (fun i => halfPt v i - emb m i)
      = bq a b c ((v 0 - 2 * m 0 : ℤ) : ℚ) ((v 1 - 2 * m 1 : ℤ) : ℚ) / 4 := by
  rw [binMat_value, ← bq_half]
  have h0 : halfPt v 0 - ((m 0 : ℤ) : ℚ) = ((v 0 - 2 * m 0 : ℤ) : ℚ) / 2 := by
    simp only [halfPt]; push_cast; ring
  have h1 : halfPt v 1 - ((m 1 : ℤ) : ℚ) = ((v 1 - 2 * m 1 : ℤ) : ℚ) / 2 := by
    simp only [halfPt]; push_cast; ring
  rw [h0, h1]

/-! ## Casting helpers -/

lemma one_le_abs_cast {X : ℤ} (hX : X ≠ 0) : (1 : ℚ) ≤ |(X : ℚ)| := by
  have h : (1 : ℤ) ≤ |X| := Int.one_le_abs hX
  have h' : ((1 : ℤ) : ℚ) ≤ ((|X| : ℤ) : ℚ) := Int.cast_le.2 h
  rwa [Int.cast_abs, Int.cast_one] at h'

lemma two_le_abs_cast_of_even {X : ℤ} (hX : X ≠ 0) (h2 : 2 ∣ X) : (2 : ℚ) ≤ |(X : ℚ)| := by
  obtain ⟨j, hj⟩ := h2
  have h : (2 : ℤ) ≤ |X| := by
    rcases abs_cases X with ⟨h1, _⟩ | ⟨h1, _⟩ <;> omega
  have h' : ((2 : ℤ) : ℚ) ≤ ((|X| : ℤ) : ℚ) := Int.cast_le.2 h
  rwa [Int.cast_abs] at h'
  
lemma abs_mul_cast (X Y : ℤ) : |(X : ℚ) * (Y : ℚ)| = |(X : ℚ)| * |(Y : ℚ)| := abs_mul _ _

/-- The basic estimate in the reduction domain: the cross term can always be absorbed into the
diagonal terms, keeping the coefficient `c`. -/
lemma bq_ge_split {a b c : ℚ} (hb : |b| ≤ a) (X Y : ℚ) :
    a * X ^ 2 - a * (|X| * |Y|) + c * Y ^ 2 ≤ bq a b c X Y := by
  have hcross : b * X * Y ≥ -(|b| * (|X| * |Y|)) := by
    have h1 : |b * X * Y| ≤ |b| * (|X| * |Y|) := by
      rw [abs_mul, abs_mul]
      exact le_of_eq (by ring)
    linarith [neg_abs_le (b * X * Y)]
  have habs : (|b| - a) * (|X| * |Y|) ≤ 0 :=
    mul_nonpos_of_nonpos_of_nonneg (by linarith) (mul_nonneg (abs_nonneg X) (abs_nonneg Y))
  unfold bq
  nlinarith

/-! ## The three nonzero coset minima -/

/-- Class `(1,0)`: the coset minimum is `a = λ₁`. -/
lemma reduced_odd_even_lower {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) {X Y : ℤ}
    (hX : ¬ (2 ∣ X)) (hY : 2 ∣ Y) : a ≤ bq a b c (X : ℚ) (Y : ℚ) := by
  have hXne : X ≠ 0 := by rintro rfl; exact hX ⟨0, by ring⟩
  have hu : (1 : ℚ) ≤ |(X : ℚ)| := one_le_abs_cast hXne
  have hsq : ((X : ℚ)) ^ 2 = |(X : ℚ)| ^ 2 := (sq_abs _).symm
  have hsq' : ((Y : ℚ)) ^ 2 = |(Y : ℚ)| ^ 2 := (sq_abs _).symm
  have hbase := bq_ge_split (a := a) (b := b) (c := c) hb (X : ℚ) (Y : ℚ)
  rcases eq_or_ne Y 0 with rfl | hY0
  · have hz : |((0 : ℤ) : ℚ)| = 0 := by norm_num
    rw [hz] at hbase
    have h0 : (((0 : ℤ) : ℚ)) ^ 2 = 0 := by norm_num
    rw [h0] at hbase
    have h1 : (1 : ℚ) ≤ (X : ℚ) ^ 2 := by nlinarith [hsq, hu]
    nlinarith [h1, ha]
  · have hv : (2 : ℚ) ≤ |(Y : ℚ)| := two_le_abs_cast_of_even hY0 hY
    have hcy : a * (Y : ℚ) ^ 2 ≤ c * (Y : ℚ) ^ 2 := by nlinarith [sq_nonneg ((Y : ℚ))]
    nlinarith [hsq, hsq', sq_nonneg (|(X : ℚ)| - |(Y : ℚ)|),
      mul_nonneg (sub_nonneg.2 hu) (sub_nonneg.2 hv)]

/-- Class `(0,1)`: the coset minimum is `c`. -/
lemma reduced_even_odd_lower {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) {X Y : ℤ}
    (hX : 2 ∣ X) (hY : ¬ (2 ∣ Y)) : c ≤ bq a b c (X : ℚ) (Y : ℚ) := by
  have hYne : Y ≠ 0 := by rintro rfl; exact hY ⟨0, by ring⟩
  have hv : (1 : ℚ) ≤ |(Y : ℚ)| := one_le_abs_cast hYne
  have hsq : ((X : ℚ)) ^ 2 = |(X : ℚ)| ^ 2 := (sq_abs _).symm
  have hsq' : ((Y : ℚ)) ^ 2 = |(Y : ℚ)| ^ 2 := (sq_abs _).symm
  have hbase := bq_ge_split (a := a) (b := b) (c := c) hb (X : ℚ) (Y : ℚ)
  rcases eq_or_ne X 0 with rfl | hX0
  · have hz : |((0 : ℤ) : ℚ)| = 0 := by norm_num
    rw [hz] at hbase
    have h0 : (((0 : ℤ) : ℚ)) ^ 2 = 0 := by norm_num
    rw [h0] at hbase
    nlinarith [hsq', hv, sq_nonneg (|(Y : ℚ)| - 1), le_trans hb hc]
  · have hu : (2 : ℚ) ≤ |(X : ℚ)| := two_le_abs_cast_of_even hX0 hX
    nlinarith [hsq, hsq', sq_nonneg (|(X : ℚ)| - |(Y : ℚ)|), sq_nonneg (|(Y : ℚ)| - 1),
      mul_nonneg (sub_nonneg.2 hc) (sub_nonneg.2 (by nlinarith [hsq'] : (1 : ℚ) ≤ (Y : ℚ) ^ 2)),
      mul_nonneg (sub_nonneg.2 hu) (sub_nonneg.2 hv), ha.le]

/-- Class `(1,1)`: the coset minimum is `a + c − |b|`. -/
lemma reduced_odd_odd_lower {a b c : ℚ} (hb : |b| ≤ a) (hc : a ≤ c) {X Y : ℤ}
    (hX : ¬ (2 ∣ X)) (hY : ¬ (2 ∣ Y)) : a + c - |b| ≤ bq a b c (X : ℚ) (Y : ℚ) := by
  have hXne : X ≠ 0 := by rintro rfl; exact hX ⟨0, by ring⟩
  have hYne : Y ≠ 0 := by rintro rfl; exact hY ⟨0, by ring⟩
  have hu : (1 : ℚ) ≤ |(X : ℚ)| := one_le_abs_cast hXne
  have hv : (1 : ℚ) ≤ |(Y : ℚ)| := one_le_abs_cast hYne
  have hbc : |b| ≤ c := le_trans hb hc
  have hb0 : (0 : ℚ) ≤ |b| := abs_nonneg b
  have hsq : ((X : ℚ)) ^ 2 = |(X : ℚ)| ^ 2 := (sq_abs _).symm
  have hsq' : ((Y : ℚ)) ^ 2 = |(Y : ℚ)| ^ 2 := (sq_abs _).symm
  have hcross : b * (X : ℚ) * (Y : ℚ) ≥ -(|b| * (|(X : ℚ)| * |(Y : ℚ)|)) := by
    have h1 : |b * (X : ℚ) * (Y : ℚ)| ≤ |b| * (|(X : ℚ)| * |(Y : ℚ)|) := by
      rw [abs_mul, abs_mul]
      exact le_of_eq (by ring)
    linarith [neg_abs_le (b * (X : ℚ) * (Y : ℚ))]
  unfold bq
  rw [hsq, hsq']
  nlinarith [mul_nonneg (sub_nonneg.2 hb) (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |(X : ℚ)| ^ 2)),
    mul_nonneg (sub_nonneg.2 hbc) (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |(Y : ℚ)| ^ 2)),
    mul_nonneg hb0 (sq_nonneg (|(X : ℚ)| - |(Y : ℚ)|)),
    mul_nonneg hb0 (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |(X : ℚ)| * |(Y : ℚ)|))]

/-! ## The four coset minima as spectral gaps -/

/-- The homogeneous minimum of a reduced binary form is `a`. -/
theorem reduced_isMinEnergy {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    IsMinEnergy (binMat a b c) a := by
  constructor
  · refine ⟨![1, 0], ?_, ?_⟩
    · intro hcon
      simpa using congrFun hcon 0
    · rw [form_binMat]
      norm_num [bq, emb]
  · intro m hm
    have hpair : ¬(m 0 = 0 ∧ m 1 = 0) := by
      rintro ⟨h0, h1⟩
      exact hm (funext fun i => by fin_cases i <;> simpa using ‹_›)
    rw [form_binMat]
    have hm0 : ((emb m) 0) = ((m 0 : ℤ) : ℚ) := rfl
    have hm1 : ((emb m) 1) = ((m 1 : ℤ) : ℚ) := rfl
    rw [hm0, hm1]
    exact bq_int_ge ha hb hc hpair

/-- The trivial class has gap `0`. -/
theorem reduced_gap_zero {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (halfPt ![0, 0]) 0 := by
  have hnn : ∀ X Y : ℚ, 0 ≤ bq a b c X Y := by
    intro X Y
    have hbase := bq_ge_split (a := a) (b := b) (c := c) hb X Y
    have hsq : X ^ 2 = |X| ^ 2 := (sq_abs _).symm
    have hsq' : Y ^ 2 = |Y| ^ 2 := (sq_abs _).symm
    nlinarith [sq_nonneg (|X| - |Y|), mul_nonneg (abs_nonneg X) (abs_nonneg Y),
      mul_nonneg (sub_nonneg.2 hc) (sq_nonneg Y), ha.le]
  constructor
  · refine ⟨0, ?_⟩
    rw [binMat_halfPt_value]
    rw [show (![0, 0] : Fin 2 → ℤ) 0 - 2 * (0 : Fin 2 → ℤ) 0 = 0 from rfl,
      show (![0, 0] : Fin 2 → ℤ) 1 - 2 * (0 : Fin 2 → ℤ) 1 = 0 from rfl]
    norm_num [bq]
  · intro m
    rw [binMat_halfPt_value]
    have := hnn (((![0, 0] : Fin 2 → ℤ) 0 - 2 * m 0 : ℤ) : ℚ)
      (((![0, 0] : Fin 2 → ℤ) 1 - 2 * m 1 : ℤ) : ℚ)
    linarith

/-- Class `(1,0)`: gap `a/4 = λ₁/4`, the packing end of the enumerator. -/
theorem reduced_gap_e0 {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (halfPt ![1, 0]) (a / 4) := by
  constructor
  · refine ⟨0, ?_⟩
    rw [binMat_halfPt_value]
    rw [show (![1, 0] : Fin 2 → ℤ) 0 - 2 * (0 : Fin 2 → ℤ) 0 = 1 from rfl,
      show (![1, 0] : Fin 2 → ℤ) 1 - 2 * (0 : Fin 2 → ℤ) 1 = 0 from rfl]
    norm_num [bq]
  · intro m
    rw [binMat_halfPt_value]
    have hX : ¬ (2 ∣ ((![1, 0] : Fin 2 → ℤ) 0 - 2 * m 0)) := by
      rw [show (![1, 0] : Fin 2 → ℤ) 0 = 1 from rfl]
      omega
    have hY : 2 ∣ ((![1, 0] : Fin 2 → ℤ) 1 - 2 * m 1) := by
      rw [show (![1, 0] : Fin 2 → ℤ) 1 = 0 from rfl]
      exact ⟨-(m 1), by ring⟩
    have := reduced_odd_even_lower ha hb hc hX hY
    linarith

/-- Class `(0,1)`: gap `c/4`. -/
theorem reduced_gap_e1 {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (halfPt ![0, 1]) (c / 4) := by
  constructor
  · refine ⟨0, ?_⟩
    rw [binMat_halfPt_value]
    rw [show (![0, 1] : Fin 2 → ℤ) 0 - 2 * (0 : Fin 2 → ℤ) 0 = 0 from rfl,
      show (![0, 1] : Fin 2 → ℤ) 1 - 2 * (0 : Fin 2 → ℤ) 1 = 1 from rfl]
    norm_num [bq]
  · intro m
    rw [binMat_halfPt_value]
    have hX : 2 ∣ ((![0, 1] : Fin 2 → ℤ) 0 - 2 * m 0) := by
      rw [show (![0, 1] : Fin 2 → ℤ) 0 = 0 from rfl]
      exact ⟨-(m 0), by ring⟩
    have hY : ¬ (2 ∣ ((![0, 1] : Fin 2 → ℤ) 1 - 2 * m 1)) := by
      rw [show (![0, 1] : Fin 2 → ℤ) 1 = 1 from rfl]
      omega
    have := reduced_even_odd_lower ha hb hc hX hY
    linarith

/-- Class `(1,1)`: gap `(a + c − |b|)/4`, the covering end of the enumerator. -/
theorem reduced_gap_e01 {a b c : ℚ} (hb : |b| ≤ a) (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (halfPt ![1, 1]) ((a + c - |b|) / 4) := by
  constructor
  · rcases abs_cases b with ⟨hbe, _⟩ | ⟨hbe, _⟩
    · refine ⟨![0, 1], ?_⟩
      rw [binMat_halfPt_value]
      rw [show (![1, 1] : Fin 2 → ℤ) 0 - 2 * (![0, 1] : Fin 2 → ℤ) 0 = 1 from rfl,
        show (![1, 1] : Fin 2 → ℤ) 1 - 2 * (![0, 1] : Fin 2 → ℤ) 1 = -1 from rfl, hbe]
      unfold bq
      push_cast
      ring
    · refine ⟨0, ?_⟩
      rw [binMat_halfPt_value]
      rw [show (![1, 1] : Fin 2 → ℤ) 0 - 2 * (0 : Fin 2 → ℤ) 0 = 1 from rfl,
        show (![1, 1] : Fin 2 → ℤ) 1 - 2 * (0 : Fin 2 → ℤ) 1 = 1 from rfl, hbe]
      unfold bq
      push_cast
      ring
  · intro m
    rw [binMat_halfPt_value]
    have hX : ¬ (2 ∣ ((![1, 1] : Fin 2 → ℤ) 0 - 2 * m 0)) := by
      rw [show (![1, 1] : Fin 2 → ℤ) 0 = 1 from rfl]
      omega
    have hY : ¬ (2 ∣ ((![1, 1] : Fin 2 → ℤ) 1 - 2 * m 1)) := by
      rw [show (![1, 1] : Fin 2 → ℤ) 1 = 1 from rfl]
      omega
    have := reduced_odd_odd_lower hb hc hX hY
    linarith

/-! ## The covering weight enumerator -/

/-- The **covering weight enumerator** of the reduced binary form `a x² + b x y + c y²`: the
multiset of `4·(coset minimum)` over the four classes of `L/2L`. -/
def coverEnum (a b c : ℚ) : Multiset ℚ := {0, a, c, a + c - |b|}

/-- Every entry of the enumerator is four times the spectral gap of a `2`-torsion shift. -/
theorem coverEnum_entries {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) {x : ℚ}
    (hx : x ∈ coverEnum a b c) :
    ∃ v : Fin 2 → ℤ, IsInhomMin (binMat a b c) (halfPt v) (x / 4) := by
  have h0 : (0 : ℚ) / 4 = 0 := by norm_num
  simp only [coverEnum, Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl | rfl
  · exact ⟨![0, 0], by rw [h0]; exact reduced_gap_zero ha hb hc⟩
  · exact ⟨![1, 0], reduced_gap_e0 ha hb hc⟩
  · exact ⟨![0, 1], reduced_gap_e1 ha hb hc⟩
  · exact ⟨![1, 1], reduced_gap_e01 hb hc⟩

/-- Conversely every `2`-torsion gap occurs in the enumerator: the four classes exhaust
`L/2L`. -/
theorem two_torsion_gap_mem {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c)
    (v : Fin 2 → ℤ) {mu : ℚ} (hmu : IsInhomMin (binMat a b c) (halfPt v) mu) :
    4 * mu ∈ coverEnum a b c := by
  -- reduce `v` modulo `2L`
  obtain ⟨r0, k0, hr0, hv0⟩ : ∃ r0 k0 : ℤ, (r0 = 0 ∨ r0 = 1) ∧ v 0 = r0 + 2 * k0 :=
    ⟨v 0 % 2, v 0 / 2, by omega, by omega⟩
  obtain ⟨r1, k1, hr1, hv1⟩ : ∃ r1 k1 : ℤ, (r1 = 0 ∨ r1 = 1) ∧ v 1 = r1 + 2 * k1 :=
    ⟨v 1 % 2, v 1 / 2, by omega, by omega⟩
  have hshift : halfPt v = fun i => halfPt ![r0, r1] i + emb ![k0, k1] i := by
    refine funext ?_
    rw [Fin.forall_fin_two]
    constructor
    · simp only [halfPt, emb, Matrix.cons_val_zero]
      rw [hv0]; push_cast; ring
    · simp only [halfPt, emb, Matrix.cons_val_one]
      rw [hv1]; push_cast; ring
  rw [hshift] at hmu
  have hmu' : IsInhomMin (binMat a b c) (halfPt ![r0, r1]) mu :=
    isInhomMin_translate' _ _ _ hmu
  simp only [coverEnum, Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton]
  rcases hr0 with rfl | rfl <;> rcases hr1 with rfl | rfl
  · have := isInhomMin_unique hmu' (reduced_gap_zero ha hb hc)
    left; rw [this]; ring
  · have := isInhomMin_unique hmu' (reduced_gap_e1 ha hb hc)
    right; right; left; rw [this]; ring
  · have := isInhomMin_unique hmu' (reduced_gap_e0 ha hb hc)
    right; left; rw [this]; ring
  · have := isInhomMin_unique hmu' (reduced_gap_e01 hb hc)
    right; right; right; rw [this]; ring

/-! ## The enumerator is a complete invariant -/

lemma coverEnum_le_max {a b c : ℚ} (hb : |b| ≤ a) (hc : a ≤ c) {x : ℚ}
    (hx : x ∈ coverEnum a b c) : x ≤ a + c - |b| := by
  have hbc : |b| ≤ c := le_trans hb hc
  have hb0 : (0 : ℚ) ≤ |b| := abs_nonneg b
  simp only [coverEnum, Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl | rfl <;> linarith

lemma coverEnum_pos_ge_min {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) {x : ℚ}
    (hx : x ∈ coverEnum a b c) (hpos : x ≠ 0) : a ≤ x := by
  have hbc : |b| ≤ c := le_trans hb hc
  simp only [coverEnum, Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl | rfl
  · exact absurd rfl hpos
  · exact le_rfl
  · exact hc
  · linarith

lemma coverEnum_sum (a b c : ℚ) : (coverEnum a b c).sum = 2 * a + 2 * c - |b| := by
  simp only [coverEnum, Multiset.insert_eq_cons, Multiset.sum_cons, Multiset.sum_singleton]
  ring

lemma coverEnum_mem_min {a b c : ℚ} : a ∈ coverEnum a b c := by
  simp [coverEnum]

lemma coverEnum_mem_max {a b c : ℚ} : a + c - |b| ∈ coverEnum a b c := by
  simp [coverEnum]

/-- **Conjecture D′ in rank two.**  The covering weight enumerator determines the reduced
coefficients `(a, |b|, c)`. -/
theorem coverEnum_determines {a b c a' b' c' : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c)
    (ha' : 0 < a') (hb' : |b'| ≤ a') (hc' : a' ≤ c')
    (heq : coverEnum a b c = coverEnum a' b' c') :
    a = a' ∧ c = c' ∧ |b| = |b'| := by
  have hmin : a = a' := by
    have h1 : a ∈ coverEnum a' b' c' := heq ▸ coverEnum_mem_min (b := b)
    have h2 : a' ∈ coverEnum a b c := heq ▸ coverEnum_mem_min (b := b')
    have h1' : a' ≤ a := coverEnum_pos_ge_min ha' hb' hc' h1 (ne_of_gt ha)
    have h2' : a ≤ a' := coverEnum_pos_ge_min ha hb hc h2 (ne_of_gt ha')
    linarith
  have hmax : a + c - |b| = a' + c' - |b'| := by
    have h1 : a + c - |b| ∈ coverEnum a' b' c' := heq ▸ coverEnum_mem_max
    have h2 : a' + c' - |b'| ∈ coverEnum a b c := heq ▸ coverEnum_mem_max
    have h1' := coverEnum_le_max hb' hc' h1
    have h2' := coverEnum_le_max hb hc h2
    linarith
  have hsum : 2 * a + 2 * c - |b| = 2 * a' + 2 * c' - |b'| := by
    rw [← coverEnum_sum a b c, ← coverEnum_sum a' b' c', heq]
  refine ⟨hmin, ?_, ?_⟩ <;> [linarith; linarith]

/-- **The enumerator is a complete isometry invariant in rank two.**  Two reduced binary forms
with the same covering weight enumerator agree after the coordinate flip `y ↦ ±y`, which is an
isometry of the lattice `ℤ²`. -/
theorem coverEnum_complete_invariant {a b c a' b' c' : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c)
    (ha' : 0 < a') (hb' : |b'| ≤ a') (hc' : a' ≤ c')
    (heq : coverEnum a b c = coverEnum a' b' c') :
    ∃ e : ℚ, (e = 1 ∨ e = -1) ∧ ∀ x y : ℚ, bq a b c x y = bq a' b' c' x (e * y) := by
  obtain ⟨haa, hcc, hbb⟩ := coverEnum_determines ha hb hc ha' hb' hc' heq
  subst haa; subst hcc
  rcases abs_eq_abs.1 hbb with h | h
  · exact ⟨1, Or.inl rfl, fun x y => by unfold bq; rw [h]; ring⟩
  · exact ⟨-1, Or.inr rfl, fun x y => by unfold bq; rw [h]; ring⟩

/-- The smallest nonzero entry of the enumerator is the packing invariant `λ₁`: the rank-two case
of the second half of Conjecture D′. -/
theorem coverEnum_min_eq_minEnergy {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    IsMinEnergy (binMat a b c) a ∧
      (a ∈ coverEnum a b c ∧ ∀ x ∈ coverEnum a b c, x ≠ 0 → a ≤ x) :=
  ⟨reduced_isMinEnergy ha hb hc, coverEnum_mem_min, fun _ hx hne =>
    coverEnum_pos_ge_min ha hb hc hx hne⟩


/-! ## A two-sided bound for the covering radius of a binary lattice -/

/-- A reduced triple defines a positive-definite form. -/
theorem reduced_posDef {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    PosDef (binMat a b c) := by
  intro x hx
  rw [form_binMat]
  have hne : x 0 ≠ 0 ∨ x 1 ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hx (funext fun i => by fin_cases i <;> simp [hcon.1, hcon.2])
  have hbase := bq_ge_split (a := a) (b := b) (c := c) hb (x 0) (x 1)
  have hsq : (x 0) ^ 2 = |x 0| ^ 2 := (sq_abs _).symm
  have hsq' : (x 1) ^ 2 = |x 1| ^ 2 := (sq_abs _).symm
  have hcy : a * (x 1) ^ 2 ≤ c * (x 1) ^ 2 := by nlinarith [sq_nonneg (x 1)]
  have hq : 0 < |x 0| ^ 2 - |x 0| * |x 1| + |x 1| ^ 2 := by
    rcases hne with h | h
    · have hpos : 0 < |x 0| := abs_pos.2 h
      nlinarith [sq_nonneg (2 * |x 0| - |x 1|), sq_nonneg (|x 1|), mul_pos hpos hpos]
    · have hpos : 0 < |x 1| := abs_pos.2 h
      nlinarith [sq_nonneg (2 * |x 1| - |x 0|), sq_nonneg (|x 0|), mul_pos hpos hpos]
  have hstep : 0 < a * (|x 0| ^ 2 - |x 0| * |x 1| + |x 1| ^ 2) := mul_pos ha hq
  nlinarith [hsq, hsq', hcy]

/-- **Covering upper bound.**  Rounding each coordinate to the nearest integer shows that the
covering radius² of a reduced binary lattice is at most `(a + |b| + c)/4`. -/
theorem reduced_covering_upper {a b c : ℚ} (ha : 0 < a) (hc : a ≤ c) (t : Fin 2 → ℚ) :
    ∃ m : Fin 2 → ℤ, form (binMat a b c) (fun i => t i - emb m i) ≤ (a + |b| + c) / 4 := by
  refine ⟨![round (t 0), round (t 1)], ?_⟩
  rw [binMat_value]
  rw [show ((![round (t 0), round (t 1)] : Fin 2 → ℤ) 0 : ℤ) = round (t 0) from rfl,
    show ((![round (t 0), round (t 1)] : Fin 2 → ℤ) 1 : ℤ) = round (t 1) from rfl]
  have h0 : |t 0 - ((round (t 0) : ℤ) : ℚ)| ≤ 1 / 2 := abs_sub_round (t 0)
  have h1 : |t 1 - ((round (t 1) : ℤ) : ℚ)| ≤ 1 / 2 := abs_sub_round (t 1)
  have hsq0 : (t 0 - ((round (t 0) : ℤ) : ℚ)) ^ 2 = |t 0 - ((round (t 0) : ℤ) : ℚ)| ^ 2 :=
    (sq_abs _).symm
  have hsq1 : (t 1 - ((round (t 1) : ℤ) : ℚ)) ^ 2 = |t 1 - ((round (t 1) : ℤ) : ℚ)| ^ 2 :=
    (sq_abs _).symm
  have hcross : b * (t 0 - ((round (t 0) : ℤ) : ℚ)) * (t 1 - ((round (t 1) : ℤ) : ℚ))
      ≤ |b| * (1 / 2) * (1 / 2) := by
    have hle : b * (t 0 - ((round (t 0) : ℤ) : ℚ)) * (t 1 - ((round (t 1) : ℤ) : ℚ))
        ≤ |b| * (|t 0 - ((round (t 0) : ℤ) : ℚ)| * |t 1 - ((round (t 1) : ℤ) : ℚ)|) := by
      have := le_abs_self (b * (t 0 - ((round (t 0) : ℤ) : ℚ)) * (t 1 - ((round (t 1) : ℤ) : ℚ)))
      rw [abs_mul, abs_mul] at this
      linarith [this]
    have hbound : |t 0 - ((round (t 0) : ℤ) : ℚ)| * |t 1 - ((round (t 1) : ℤ) : ℚ)|
        ≤ (1 / 2) * (1 / 2) :=
      mul_le_mul h0 h1 (abs_nonneg _) (by norm_num)
    nlinarith [abs_nonneg b]
  have hu2 : (t 0 - ((round (t 0) : ℤ) : ℚ)) ^ 2 ≤ 1 / 4 := by
    rw [hsq0]; nlinarith [abs_nonneg (t 0 - ((round (t 0) : ℤ) : ℚ))]
  have hv2 : (t 1 - ((round (t 1) : ℤ) : ℚ)) ^ 2 ≤ 1 / 4 := by
    rw [hsq1]; nlinarith [abs_nonneg (t 1 - ((round (t 1) : ℤ) : ℚ))]
  have hau : a * (t 0 - ((round (t 0) : ℤ) : ℚ)) ^ 2 ≤ a / 4 := by nlinarith [ha.le]
  have hcv : c * (t 1 - ((round (t 1) : ℤ) : ℚ)) ^ 2 ≤ c / 4 := by
    nlinarith [le_trans ha.le hc]
  unfold bq
  linarith

/-- **Two-sided bound for the covering radius in rank two.**  If `mu` is the *least* covering
value of a reduced binary lattice then `λ₁/4 < mu ≤ (a + |b| + c)/4`.  The left inequality is the
strictness theorem of the previous file, the right one is nearest-integer rounding. -/
theorem reduced_covering_two_sided {a b c mu : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c)
    (hcov : ∀ t : Fin 2 → ℚ, ∃ m : Fin 2 → ℤ,
      form (binMat a b c) (fun i => t i - emb m i) ≤ mu)
    (hleast : ∀ mu' : ℚ, (∀ t : Fin 2 → ℚ, ∃ m : Fin 2 → ℤ,
      form (binMat a b c) (fun i => t i - emb m i) ≤ mu') → mu ≤ mu') :
    a / 4 < mu ∧ mu ≤ (a + |b| + c) / 4 :=
  ⟨rank_two_covering_strict (reduced_posDef ha hb hc) (reduced_isMinEnergy ha hb hc) hcov,
    hleast _ (reduced_covering_upper ha hc)⟩

/-- The hexagonal lattice has the degenerate enumerator `{0,1,1,1}`: all three nonzero classes
have the same coset minimum `λ₁`.  This is the rank-two obstruction of Conjecture C. -/
theorem hex_coverEnum : coverEnum 1 1 1 = ({0, 1, 1, 1} : Multiset ℚ) := by
  simp [coverEnum]

end RankTwo
end DiophantineLattice