import Catalog.Bridges.BerggrenBoundaryEntropy
import Catalog.Bridges.BerggrenBoundaryCantor

/-!
# Rigidity of the family of Berggren harmonic measures

The harmonic measures `bernoulli P`, `P` ranging over strictly positive weight vectors on the
three Berggren moves, all live on the *same* compact Cantor set (the boundary of the Berggren
tree) and all have full support (`bernoulli_cyl_pos`, `support_eq_univ`).  Nevertheless they
are pairwise as different as measures can be.

## Main results

* `shift_invariant` : the harmonic measure is invariant under the shift `x ↦ (x₁, x₂, …)` —
  "forget the first Berggren move".  The Berggren boundary walk is a stationary process.
* `bernoulli_cyl_pos`, `support_eq_univ` : every node of the Berggren tree carries positive
  harmonic mass; the harmonic measure has full support.
* `bernoulli_mutuallySingular` : **distinct weight vectors give mutually singular harmonic
  measures.**  The map `P ↦ bernoulli P` is therefore injective, and the two-parameter family
  of harmonic measures is a family of pairwise singular probability measures on one and the
  same Cantor set — each one detected by the asymptotic frequency of a Berggren move along
  its typical boundary rays.
* `bernoulli_injective` : in particular `bernoulli P = bernoulli Q → P.p = Q.p`, so the
  harmonic measure remembers the transition probabilities exactly.
-/

namespace BerggrenHarmonic

open MeasureTheory ProbabilityTheory Filter Finset Set
open scoped Topology ENNReal

/-! ## Full support -/

theorem bernoulli_cyl_pos (P : ProbVec) (n : ℕ) (v : Bdry) : 0 < bernoulli P (cyl n v) := by
  rw [bernoulli_cyl, wmass, pos_iff_ne_zero, Finset.prod_ne_zero_iff]
  exact fun i _ => (ENNReal.ofReal_pos.2 (P.pos (v i))).ne'

/-- The harmonic measure charges every nonempty open subset of the boundary: its support is
the whole Cantor set. -/
theorem measure_pos_of_isOpen (P : ProbVec) {U : Set Bdry} (hU : IsOpen U) (hne : U.Nonempty) :
    0 < bernoulli P U := by
  obtain ⟨x, hx⟩ := hne
  obtain ⟨n, hn⟩ := cyl_nhds_basis x U (hU.mem_nhds hx)
  exact lt_of_lt_of_le (bernoulli_cyl_pos P n x) (measure_mono hn)

/-! ## Shift invariance -/

/-- The shift on the boundary: forget the first Berggren move. -/
def shift (x : Bdry) : Bdry := fun n => x (n + 1)

lemma measurable_shift : Measurable shift :=
  measurable_pi_lambda _ fun n => measurable_pi_apply (n + 1)

lemma preimage_shift_cyl (n : ℕ) (v : Bdry) :
    shift ⁻¹' cyl n v = ⋃ a : Letter, cyl (n + 1) (cons a v) := by
  ext x
  constructor
  · intro hx
    refine mem_iUnion.2 ⟨x 0, ?_⟩
    intro i hi
    cases i with
    | zero => rfl
    | succ k => exact hx k (by omega)
  · intro hx
    obtain ⟨a, ha⟩ := mem_iUnion.1 hx
    intro i hi
    have := ha (i + 1) (by omega)
    simpa [shift] using this

lemma cyl_cons_disjoint {a b : Letter} (hab : a ≠ b) (n : ℕ) (v : Bdry) :
    Disjoint (cyl (n + 1) (cons a v)) (cyl (n + 1) (cons b v)) := by
  rw [Set.disjoint_left]
  intro x hxa hxb
  have h1 : x 0 = a := hxa 0 (by omega)
  have h2 : x 0 = b := hxb 0 (by omega)
  exact hab (h1 ▸ h2 ▸ rfl)

/-- **The harmonic measure is shift invariant.**  Forgetting the first Berggren move does not
change the law of the random boundary point: the sequence of moves is a stationary process. -/
theorem shift_invariant (P : ProbVec) : (bernoulli P).map shift = bernoulli P := by
  have : IsProbabilityMeasure ((bernoulli P).map shift) :=
    ⟨by rw [Measure.map_apply measurable_shift MeasurableSet.univ, Set.preimage_univ,
        measure_univ]⟩
  refine ext_of_cyl_eq (fun n v => ?_)
  rw [Measure.map_apply measurable_shift (measurableSet_cyl n v), preimage_shift_cyl,
    measure_iUnion (fun a b hab => cyl_cons_disjoint hab n v)
      (fun a => measurableSet_cyl (n + 1) (cons a v))]
  have hterm : ∀ a : Letter,
      bernoulli P (cyl (n + 1) (cons a v)) = ENNReal.ofReal (P.p a) * wmass P n v := by
    intro a
    have h2 : tail (cons a v) = v := by funext k; rfl
    rw [bernoulli_cyl, wmass_succ, h2]
    rfl
  rw [tsum_fintype, Finset.sum_congr rfl (fun a _ => hterm a), ← Finset.sum_mul,
    ← ENNReal.ofReal_sum_of_nonneg (fun a _ => (P.pos a).le), P.sum_eq, ENNReal.ofReal_one,
    one_mul, bernoulli_cyl]

/-! ## Mutual singularity -/

/-- The indicator observable of a Berggren move. -/
noncomputable def ind (a : Letter) : Letter → ℝ := fun b => if b = a then 1 else 0

lemma sum_p_mul_ind (P : ProbVec) (a : Letter) : ∑ b, P.p b * ind a b = P.p a := by
  have hterm : ∀ b : Letter, P.p b * ind a b = if b = a then P.p b else 0 := by
    intro b; by_cases hb : b = a <;> simp [ind, hb]
  rw [Finset.sum_congr rfl (fun b _ => hterm b), Finset.sum_ite_eq' Finset.univ a,
    if_pos (Finset.mem_univ a)]

/-- The set of boundary rays along which the Berggren move `a` has asymptotic frequency `t`. -/
def freqSet (a : Letter) (t : ℝ) : Set Bdry :=
  {x | Tendsto (fun n : ℕ => (∑ i ∈ Finset.range n, ind a (x i)) / n) atTop (𝓝 t)}

lemma measurableSet_freqSet (a : Letter) (t : ℝ) : MeasurableSet (freqSet a t) := by
  refine measurableSet_tendsto (𝓝 t) (fun n => ?_)
  exact (Finset.measurable_sum _ (fun i _ => measurable_letter_coord (ind a) i)).div_const _

/-- Almost every ray of the harmonic measure `bernoulli P` realises the frequency `P.p a` for
the move `a`. -/
theorem freqSet_measure_one (P : ProbVec) (a : Letter) :
    bernoulli P (freqSet a (P.p a)) = 1 := by
  have h := strongLaw_letters P (ind a)
  rw [sum_p_mul_ind] at h
  have hae : ∀ᵐ x ∂(bernoulli P), x ∈ freqSet a (P.p a) := h
  have h0 : bernoulli P (freqSet a (P.p a))ᶜ = 0 := ae_iff.1 hae
  have hsum := measure_add_measure_compl (μ := bernoulli P) (measurableSet_freqSet a (P.p a))
  rw [h0, add_zero, measure_univ] at hsum
  exact hsum

lemma freqSet_measure_zero (P : ProbVec) (a : Letter) {t : ℝ} (ht : t ≠ P.p a) :
    bernoulli P (freqSet a t) = 0 := by
  have h := strongLaw_letters P (ind a)
  rw [sum_p_mul_ind] at h
  have hae : ∀ᵐ x ∂(bernoulli P), x ∉ freqSet a t := by
    filter_upwards [h] with x hx hmem
    exact ht (tendsto_nhds_unique hmem hx)
  have h2 : bernoulli P {x : Bdry | ¬ (x ∉ freqSet a t)} = 0 := ae_iff.1 hae
  simpa using h2

/-- **Distinct Berggren walks have mutually singular harmonic measures.**  If two weight
vectors differ in a single coordinate, the corresponding harmonic measures are supported on
disjoint sets of boundary rays, distinguished by the asymptotic frequency of that move. -/
theorem bernoulli_mutuallySingular (P Q : ProbVec) (h : ∃ a, P.p a ≠ Q.p a) :
    (bernoulli P) ⟂ₘ (bernoulli Q) := by
  obtain ⟨a, ha⟩ := h
  refine ⟨freqSet a (Q.p a), measurableSet_freqSet a (Q.p a), freqSet_measure_zero P a ha.symm,
    ?_⟩
  have h1 : bernoulli Q (freqSet a (Q.p a)) = 1 := freqSet_measure_one Q a
  have := measure_compl (μ := bernoulli Q) (measurableSet_freqSet a (Q.p a))
    (by rw [h1]; exact ENNReal.one_ne_top)
  rw [this, measure_univ, h1, tsub_self]

/-- The harmonic measure determines the transition probabilities. -/
theorem bernoulli_injective (P Q : ProbVec) (h : bernoulli P = bernoulli Q) : P.p = Q.p := by
  funext a
  by_contra hne
  have hsing := bernoulli_mutuallySingular P Q ⟨a, hne⟩
  rw [h] at hsing
  obtain ⟨s, hs, h0, hc⟩ := hsing
  have : bernoulli Q Set.univ = 0 := by
    have : (Set.univ : Set Bdry) = s ∪ sᶜ := by simp
    rw [this]
    exact le_antisymm (le_trans (measure_union_le _ _) (by rw [h0, hc]; simp)) (zero_le _)
  rw [measure_univ] at this
  exact one_ne_zero this

end BerggrenHarmonic