import Mathlib

/-!
# Barrier III: the holomorphic rigidity barrier (HRB)

A recurring proposal for factoring `N = p q` is analytic: build from `N` some
holomorphic function `F_N : ℂ → ℂ` whose zeros are (or encode) the prime factors, then
"read off" the factors from the zero set.  This file makes the obstruction precise in
three independent pieces, all proved for genuinely holomorphic (entire) functions.

* **Rigidity / circularity.**
  `FactoringBarriers.entire_factor_of_two_zeros` : if an entire `F` vanishes at two
  distinct points `a ≠ b`, then `F z = (z - a) (z - b) G z` for an entire `G`.  In
  other words a construction whose zeros are the prime factors *already contains the
  factor polynomial `(z - p)(z - q)` as a divisor*: the factorization has to be known
  before `F_N` can be written down.  `FactoringBarriers.entire_cofactor_nonzero`
  sharpens this: if the zero set is exactly `{p, q}`, the cofactor is nonvanishing off
  `{p, q}`, so `F` carries no information beyond the factorization itself.

* **Null-set obstruction.**
  `FactoringBarriers.zeroSet_countable` and `FactoringBarriers.zeroSet_volume_zero` :
  the zero set of a nonzero entire function is countable and Lebesgue-null; hence
  `FactoringBarriers.random_search_misses_zeroSet` — searching for a zero by sampling
  points of the plane succeeds with probability zero.

* **Sharpness (the barrier is rigidity, not impossibility).**
  `FactoringBarriers.exists_entire_with_prescribed_prime_zeros` : an entire function
  with zero set exactly `{p, q}` always exists.  So HRB does not say the analytic
  object fails to exist; it says every such object is the factor polynomial in
  disguise.  Recording this boundary is what stops the barrier from over-claiming.
-/

namespace FactoringBarriers

open Complex Set Filter MeasureTheory

/-! ### Entire functions and `dslope` -/

/-- The difference quotient of an entire function is entire (Riemann's removable
singularity theorem). -/
theorem entire_dslope {F : ℂ → ℂ} (hF : Differentiable ℂ F) (c : ℂ) :
    Differentiable ℂ (dslope F c) := by
  rw [← differentiableOn_univ]
  exact (Complex.differentiableOn_dslope (by simp)).mpr (differentiableOn_univ.mpr hF)

/-- **One zero factors out.**  An entire function vanishing at `a` is `(z - a)` times
an entire function. -/
theorem entire_factor_of_zero {F : ℂ → ℂ} (hF : Differentiable ℂ F) {a : ℂ}
    (ha : F a = 0) :
    ∃ G : ℂ → ℂ, Differentiable ℂ G ∧ ∀ z, F z = (z - a) * G z := by
  refine ⟨dslope F a, entire_dslope hF a, fun z => ?_⟩
  have h := sub_smul_dslope F a z
  rw [smul_eq_mul, ha, sub_zero] at h
  exact h.symm

/-- **Holomorphic rigidity.**  If an entire function vanishes at two distinct points
`a ≠ b`, the quadratic `(z - a)(z - b)` divides it inside the ring of entire functions.

Applied to a putative analytic factoring device `F_N` whose zeros are the prime
factors `p ≠ q` of `N`, this says that `F_N` *is* `(z - p)(z - q)` times an entire
function: producing `F_N` is at least as hard as producing the factorization. -/
theorem entire_factor_of_two_zeros {F : ℂ → ℂ} (hF : Differentiable ℂ F) {a b : ℂ}
    (hab : a ≠ b) (ha : F a = 0) (hb : F b = 0) :
    ∃ G : ℂ → ℂ, Differentiable ℂ G ∧ ∀ z, F z = (z - a) * (z - b) * G z := by
  obtain ⟨G₁, hG₁, hfac₁⟩ := entire_factor_of_zero hF ha
  have hG₁b : G₁ b = 0 := by
    have h := hfac₁ b
    rw [hb] at h
    rcases mul_eq_zero.mp h.symm with h1 | h1
    · exact absurd (sub_eq_zero.mp h1) (Ne.symm hab)
    · exact h1
  obtain ⟨G, hG, hfac₂⟩ := entire_factor_of_zero hG₁ hG₁b
  refine ⟨G, hG, fun z => ?_⟩
  rw [hfac₁ z, hfac₂ z, mul_assoc]

/-- **Sharpened rigidity (no extra information).**  If the zero set of an entire `F`
is exactly `{a, b}` with `a ≠ b`, then the entire cofactor in
`F = (z - a)(z - b) G` is nonvanishing away from `{a, b}`.  Thus `F` is the factor
polynomial multiplied by a unit-like function: the "analytic" content is empty. -/
theorem entire_cofactor_nonzero {F : ℂ → ℂ} (hF : Differentiable ℂ F) {a b : ℂ}
    (hab : a ≠ b) (hzero : {z : ℂ | F z = 0} = {a, b}) :
    ∃ G : ℂ → ℂ, Differentiable ℂ G ∧ (∀ z, F z = (z - a) * (z - b) * G z) ∧
      ∀ z, z ≠ a → z ≠ b → G z ≠ 0 := by
  have ha : F a = 0 := by
    have : a ∈ {z : ℂ | F z = 0} := by rw [hzero]; exact Or.inl rfl
    exact this
  have hb : F b = 0 := by
    have : b ∈ {z : ℂ | F z = 0} := by rw [hzero]; exact Or.inr rfl
    exact this
  obtain ⟨G, hG, hfac⟩ := entire_factor_of_two_zeros hF hab ha hb
  refine ⟨G, hG, hfac, fun z hza hzb hGz => ?_⟩
  have : F z = 0 := by rw [hfac z, hGz, mul_zero]
  have hmem : z ∈ ({a, b} : Set ℂ) := by rw [← hzero]; exact this
  rcases hmem with h | h
  · exact hza h
  · exact hzb h

/-! ### The zero set is a null set -/

/-- The zero set of an entire function that is somewhere nonzero is countable. -/
theorem zeroSet_countable {F : ℂ → ℂ} (hF : Differentiable ℂ F) {z₀ : ℂ}
    (h0 : F z₀ ≠ 0) : {z : ℂ | F z = 0}.Countable := by
  have hana : AnalyticOnNhd ℂ F univ := analyticOnNhd_univ_iff_differentiable.mpr hF
  have hcod : F ⁻¹' {0}ᶜ ∈ codiscreteWithin (univ : Set ℂ) :=
    hana.preimage_zero_mem_codiscreteWithin h0 (mem_univ _) isConnected_univ
  have hZ : {z : ℂ | F z = 0} = (F ⁻¹' {0}ᶜ)ᶜ := by ext z; simp
  haveI : DiscreteTopology ↑((F ⁻¹' {0}ᶜ)ᶜ ∩ univ) := isDiscrete_iff_discreteTopology.mp
    (isDiscrete_of_codiscreteWithin ((compl_compl (F ⁻¹' {0}ᶜ)).symm ▸ hcod))
  have hc : ((F ⁻¹' {0}ᶜ)ᶜ ∩ univ).Countable :=
    TopologicalSpace.separableSpace_iff_countable.1 inferInstance
  rw [hZ]
  simpa using hc

/-- The zero set of an entire function that is somewhere nonzero has planar Lebesgue
measure zero. -/
theorem zeroSet_volume_zero {F : ℂ → ℂ} (hF : Differentiable ℂ F) {z₀ : ℂ}
    (h0 : F z₀ ≠ 0) : volume {z : ℂ | F z = 0} = 0 := by
  have hana : AnalyticOnNhd ℂ F univ := analyticOnNhd_univ_iff_differentiable.mpr hF
  have hcod : F ⁻¹' {0}ᶜ ∈ codiscreteWithin (univ : Set ℂ) :=
    hana.preimage_zero_mem_codiscreteWithin h0 (mem_univ _) isConnected_univ
  have hZ : {z : ℂ | F z = 0} = (F ⁻¹' {0}ᶜ)ᶜ := by ext z; simp
  have h := ae_restrict_le_codiscreteWithin (μ := (volume : Measure ℂ)) (U := univ)
    MeasurableSet.univ hcod
  rw [Measure.restrict_univ, mem_ae_iff] at h
  rw [hZ]
  exact h

/-- **Zero-set search fails.**  Any region of positive area contains points where the
analytic device does not vanish; indeed the non-vanishing points have full measure in
that region.  So "sample points and test for a zero" hits the zero set with
probability zero. -/
theorem random_search_misses_zeroSet {F : ℂ → ℂ} (hF : Differentiable ℂ F) {z₀ : ℂ}
    (h0 : F z₀ ≠ 0) {S : Set ℂ} (hS : 0 < volume S) :
    volume (S \ {z : ℂ | F z = 0}) = volume S ∧ (S \ {z : ℂ | F z = 0}).Nonempty := by
  have hnull : volume (S ∩ {z : ℂ | F z = 0}) = 0 :=
    measure_mono_null Set.inter_subset_right (zeroSet_volume_zero hF h0)
  have hdiff : volume (S \ {z : ℂ | F z = 0}) = volume S := by
    have := measure_diff_null (μ := (volume : Measure ℂ)) (s := S)
      (t := {z : ℂ | F z = 0}) (zeroSet_volume_zero hF h0)
    exact this
  refine ⟨hdiff, ?_⟩
  rw [Set.nonempty_iff_ne_empty]
  intro hempty
  rw [hempty] at hdiff
  simp only [measure_empty] at hdiff
  exact absurd hdiff.symm (ne_of_gt hS)

/-! ### Sharpness: such analytic devices do exist -/

/-- A point off the two prime factors, used to certify non-vanishing. -/
theorem cast_sum_add_one_notMem (p q : ℕ) :
    ((p : ℂ) + (q : ℂ) + 1) ∉ ({(p : ℂ), (q : ℂ)} : Set ℂ) := by
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff, not_or]
  refine ⟨fun h => ?_, fun h => ?_⟩
  · have h1 : ((q + 1 : ℕ) : ℂ) = 0 := by push_cast; linear_combination h
    have : q + 1 = 0 := by exact_mod_cast h1
    omega
  · have h1 : ((p + 1 : ℕ) : ℂ) = 0 := by push_cast; linear_combination h
    have : p + 1 = 0 := by exact_mod_cast h1
    omega

/-- **Existence / sharpness.**  For any two distinct primes there is an entire
function whose zero set is exactly the set of prime factors.  Hence Barrier III is a
*rigidity* statement (every such device equals the factor polynomial times a
nonvanishing entire function) and not a nonexistence statement — the impossibility is
in constructing the device without knowing the factors, not in its existence. -/
theorem exists_entire_with_prescribed_prime_zeros (p q : ℕ) :
    ∃ F : ℂ → ℂ, Differentiable ℂ F ∧ F ≠ 0 ∧
      {z : ℂ | F z = 0} = {(p : ℂ), (q : ℂ)} := by
  have hzeros : {z : ℂ | (z - p) * (z - q) = 0} = {(p : ℂ), (q : ℂ)} := by
    ext z
    simp only [Set.mem_setOf_eq, mul_eq_zero, sub_eq_zero, Set.mem_insert_iff,
      Set.mem_singleton_iff]
  refine ⟨fun z => (z - p) * (z - q), by fun_prop, ?_, hzeros⟩
  intro h
  have hval : ((p : ℂ) + (q : ℂ) + 1 - p) * ((p : ℂ) + (q : ℂ) + 1 - q) = 0 :=
    congrFun h ((p : ℂ) + (q : ℂ) + 1)
  have hmem : ((p : ℂ) + (q : ℂ) + 1) ∈ ({(p : ℂ), (q : ℂ)} : Set ℂ) := by
    rw [← hzeros]; exact hval
  exact cast_sum_add_one_notMem p q hmem

/-- The two barriers of this file combine: a nonzero analytic factoring device has a
null zero set (so it cannot be found by search) *and* is divisible by the factor
polynomial (so it cannot be built without the factors). -/
theorem holomorphic_rigidity_barrier {F : ℂ → ℂ} (hF : Differentiable ℂ F) {p q : ℕ}
    (hpq : p ≠ q) (hz : {z : ℂ | F z = 0} = {(p : ℂ), (q : ℂ)}) :
    volume {z : ℂ | F z = 0} = 0 ∧
      ∃ G : ℂ → ℂ, Differentiable ℂ G ∧ ∀ z, F z = (z - p) * (z - q) * G z := by
  have hne : (p : ℂ) ≠ (q : ℂ) := by
    simpa using (Nat.cast_injective (R := ℂ)).ne hpq
  have hp : F p = 0 := by
    have : (p : ℂ) ∈ {z : ℂ | F z = 0} := by rw [hz]; exact Or.inl rfl
    exact this
  have hq : F q = 0 := by
    have : (q : ℂ) ∈ {z : ℂ | F z = 0} := by rw [hz]; exact Or.inr rfl
    exact this
  obtain ⟨G, hG, hfac⟩ := entire_factor_of_two_zeros hF hne hp hq
  refine ⟨?_, G, hG, hfac⟩
  have h0 : F ((p : ℂ) + (q : ℂ) + 1) ≠ 0 := by
    intro hcontra
    have hmem : ((p : ℂ) + (q : ℂ) + 1) ∈ ({(p : ℂ), (q : ℂ)} : Set ℂ) := by
      rw [← hz]; exact hcontra
    exact cast_sum_add_one_notMem p q hmem
  exact zeroSet_volume_zero hF h0

end FactoringBarriers