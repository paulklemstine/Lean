import Novelty.IITTensorNetworkPhi

/-! # Equality analysis for the entropy bounds of integrated information

The companion files prove the inequalities

* `sum_negMulLog_le_log_card_support` : `H(p) ≤ log |supp p|`;
* `vnEntropy_le_log_rank`             : `S(ρ) ≤ log (rank ρ)`;
* `mutualInformation_le_two_log_schmidtRank` : `I(A:B) ≤ 2 log (Schmidt rank)`;
* `phi_le_two_log_of_bondDim`         : `Φ ≤ 2 log χ`.

Here we settle the *equality cases*: each of these bounds is saturated exactly
when the relevant spectrum is **flat**, i.e. uniform on its support.  This is
the missing "only if" half of the saturation analysis, and it is what makes the
value `Φ(GHZ) = 2 log d` an extremal, not merely an example, computation.

Main results:

* `sum_negMulLog_eq_log_card_support_iff` : `H(p) = log |supp p|` iff `p` is
  uniform on its support;
* `vnEntropy_eq_log_rank_iff` : a density matrix saturates the maximal entropy
  bound iff its nonzero eigenvalues all equal `1 / rank`;
* `entanglementEntropy_eq_log_schmidtRank_iff` and
  `mutualInformation_eq_two_log_schmidtRank_iff` : the Schmidt-rank bound on the
  mutual information across a cut is saturated exactly at a flat Schmidt
  spectrum;
* `phi_lt_two_log_of_nonflat_cut` : if some cut of a chain state has a
  non-flat marginal spectrum, then `Φ` is *strictly* below the bound
  `2 log (Schmidt rank)` at that cut.

We also formalize the "product cut" mechanism behind reducibility:
`schmidtRank_eq_one_of_product` and `phi_eq_zero_of_product_cut` show that a
chain state which factorizes across one bipartition has `Φ = 0`, so integrated
information is destroyed by a single product cut no matter how entangled the
two blocks are internally.
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

/-! ## Equality in the maximal entropy bound -/

section Shannon

variable {ι : Type*} [Fintype ι]

/-- The elementary bound behind the maximal entropy inequality:
`-x log x ≤ x log r + 1/r - x` for positive `x` and `r`. -/
lemma negMulLog_le_flat_bound {r x : ℝ} (hr : 0 < r) (hx : 0 < x) :
    Real.negMulLog x ≤ x * Real.log r + 1 / r - x := by
  have hxr : 0 < 1 / (r * x) := by positivity
  have hlog := Real.log_le_sub_one_of_pos hxr
  have hmul : x * Real.log (1 / (r * x)) ≤ x * (1 / (r * x) - 1) :=
    mul_le_mul_of_nonneg_left hlog hx.le
  have hrewrite : Real.log (1 / (r * x)) = -(Real.log r + Real.log x) := by
    rw [Real.log_div one_ne_zero (by positivity), Real.log_one,
      Real.log_mul (ne_of_gt hr) (ne_of_gt hx)]
    ring
  have hval : x * (1 / (r * x) - 1) = 1 / r - x := by field_simp
  rw [hrewrite, hval] at hmul
  simp only [Real.negMulLog]
  nlinarith [hmul]

/-- The bound `negMulLog_le_flat_bound` is *strict* away from the flat value
`x = 1 / r`. -/
lemma negMulLog_lt_flat_bound {r x : ℝ} (hr : 0 < r) (hx : 0 < x) (hne : x ≠ 1 / r) :
    Real.negMulLog x < x * Real.log r + 1 / r - x := by
  have hxr : 0 < 1 / (r * x) := by positivity
  have hne' : 1 / (r * x) ≠ 1 := by
    intro h
    apply hne
    have hrx : r * x = 1 := by
      field_simp at h
      linarith [h]
    field_simp
    linarith [hrx]
  have hlog := Real.log_lt_sub_one_of_pos hxr hne'
  have hmul : x * Real.log (1 / (r * x)) < x * (1 / (r * x) - 1) :=
    mul_lt_mul_of_pos_left hlog hx
  have hrewrite : Real.log (1 / (r * x)) = -(Real.log r + Real.log x) := by
    rw [Real.log_div one_ne_zero (by positivity), Real.log_one,
      Real.log_mul (ne_of_gt hr) (ne_of_gt hx)]
    ring
  have hval : x * (1 / (r * x) - 1) = 1 / r - x := by field_simp
  rw [hrewrite, hval] at hmul
  simp only [Real.negMulLog]
  nlinarith [hmul]

/-- The Shannon entropy of a vector that is uniform on its support is exactly
the logarithm of the size of the support. -/
theorem sum_negMulLog_of_flat {p : ι → ℝ} (hsum : ∑ i, p i = 1)
    (hflat : ∀ i ∈ support p, p i = ((support p).card : ℝ)⁻¹) :
    ∑ i, Real.negMulLog (p i) = Real.log (support p).card := by
  have hSne : (support p).Nonempty := support_nonempty hsum
  have hrpos : (0 : ℝ) < (support p).card := by
    exact_mod_cast Finset.card_pos.mpr hSne
  rw [← sum_negMulLog_support p]
  rw [Finset.sum_congr rfl (fun i hi => by rw [hflat i hi])]
  rw [Finset.sum_const, nsmul_eq_mul, Real.negMulLog, Real.log_inv]
  field_simp

/-- **Equality in the maximal entropy bound.**  The Shannon entropy of a
probability vector equals the logarithm of the size of its support exactly when
the vector is uniform on that support. -/
theorem sum_negMulLog_eq_log_card_support_iff {p : ι → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) :
    (∑ i, Real.negMulLog (p i)) = Real.log (support p).card ↔
      ∀ i ∈ support p, p i = ((support p).card : ℝ)⁻¹ := by
  classical
  set S := support p with hS
  have hSne : S.Nonempty := support_nonempty hsum
  have hrpos : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hSne
  have hsumS : ∑ i ∈ S, p i = 1 := by rw [hS, sum_support p, hsum]
  refine ⟨fun heq => ?_, fun hflat => sum_negMulLog_of_flat hsum hflat⟩
  by_contra hcon
  push_neg at hcon
  obtain ⟨i0, hi0S, hi0⟩ := hcon
  have hpi0 : 0 < p i0 := lt_of_le_of_ne (hp i0) (Ne.symm (mem_support.mp hi0S))
  have hi0' : p i0 ≠ 1 / (S.card : ℝ) := by
    rw [one_div]; exact hi0
  have hle : ∀ i ∈ S, Real.negMulLog (p i)
      ≤ p i * Real.log (S.card : ℝ) + 1 / (S.card : ℝ) - p i := by
    intro i hi
    have hpi : 0 < p i := lt_of_le_of_ne (hp i) (Ne.symm (mem_support.mp hi))
    exact negMulLog_le_flat_bound hrpos hpi
  have hlt : ∑ i ∈ S, Real.negMulLog (p i)
      < ∑ i ∈ S, (p i * Real.log (S.card : ℝ) + 1 / (S.card : ℝ) - p i) :=
    Finset.sum_lt_sum hle ⟨i0, hi0S, negMulLog_lt_flat_bound hrpos hpi0 hi0'⟩
  have hrhs : ∑ i ∈ S, (p i * Real.log (S.card : ℝ) + 1 / (S.card : ℝ) - p i)
      = Real.log (S.card : ℝ) := by
    rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul,
      Finset.sum_const, nsmul_eq_mul, hsumS]
    field_simp
    ring
  rw [hrhs] at hlt
  rw [← sum_negMulLog_support p, ← hS] at heq
  exact absurd heq (ne_of_lt hlt)

/-- **Strict maximal entropy bound.**  A probability vector on a finite type
which is not the uniform distribution has entropy strictly below
`log (card ι)`. -/
theorem sum_negMulLog_lt_log_card {p : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (hne : ∃ i, p i ≠ ((Fintype.card ι : ℝ))⁻¹) :
    ∑ i, Real.negMulLog (p i) < Real.log (Fintype.card ι) := by
  classical
  set S := support p with hS
  have hSne : S.Nonempty := support_nonempty hsum
  have hcardpos : 0 < S.card := Finset.card_pos.mpr hSne
  have hsub : S ⊆ Finset.univ := Finset.subset_univ _
  have hcardle : S.card ≤ Fintype.card ι := by
    simpa [Finset.card_univ] using Finset.card_le_card hsub
  have hbound := sum_negMulLog_le_log_card_support hp hsum
  rw [← hS] at hbound
  rcases lt_or_eq_of_le hcardle with hlt | heqcard
  · have h1 : Real.log (S.card : ℝ) < Real.log (Fintype.card ι : ℝ) := by
      apply Real.log_lt_log
      · exact_mod_cast hcardpos
      · exact_mod_cast hlt
    linarith
  · -- the support is everything, so non-uniformity gives strictness
    have huniv : S = Finset.univ := by
      apply Finset.eq_univ_of_card
      rw [heqcard]
    obtain ⟨i0, hi0⟩ := hne
    have hi0S : i0 ∈ S := by rw [huniv]; exact Finset.mem_univ i0
    have hnotflat : ¬ ∀ i ∈ support p, p i = ((support p).card : ℝ)⁻¹ := by
      intro hflat
      exact hi0 (by rw [hflat i0 (by rw [← hS]; exact hi0S), ← hS, heqcard])
    have hne' : (∑ i, Real.negMulLog (p i)) ≠ Real.log (S.card : ℝ) := by
      intro h
      exact hnotflat ((sum_negMulLog_eq_log_card_support_iff hp hsum).mp (by rw [hS] at *; exact h))
    have := lt_of_le_of_ne hbound hne'
    rw [heqcard] at this
    exact this

end Shannon

/-! ## Equality in the von Neumann bound -/

section VonNeumann

variable {m : Type*} [Fintype m] [DecidableEq m]

/-- **Equality in the maximal entropy bound for density matrices.**  A density
matrix saturates `S(ρ) ≤ log (rank ρ)` exactly when its nonzero eigenvalues are
all equal to `1 / rank ρ`, i.e. exactly when its spectrum is flat. -/
theorem vnEntropy_eq_log_rank_iff {A : Matrix m m ℂ} (hA : A.PosSemidef) (htr : A.trace = 1) :
    vnEntropy A = Real.log A.rank ↔
      ∀ i ∈ support hA.isHermitian.eigenvalues,
        hA.isHermitian.eigenvalues i = ((A.rank : ℝ))⁻¹ := by
  have hrk : A.rank = (support hA.isHermitian.eigenvalues).card :=
    rank_eq_card_support hA.isHermitian
  rw [vnEntropy_of_isHermitian hA.isHermitian, hrk]
  exact sum_negMulLog_eq_log_card_support_iff hA.eigenvalues_nonneg
    (sum_eigenvalues_eq_one hA htr)

/-- A flat spectrum saturates the bound. -/
theorem vnEntropy_eq_log_rank_of_flat {A : Matrix m m ℂ} (hA : A.PosSemidef) (htr : A.trace = 1)
    (hflat : ∀ i ∈ support hA.isHermitian.eigenvalues,
      hA.isHermitian.eigenvalues i = ((A.rank : ℝ))⁻¹) :
    vnEntropy A = Real.log A.rank :=
  (vnEntropy_eq_log_rank_iff hA htr).mpr hflat

/-- A density matrix whose spectrum is *not* flat has entropy strictly below the
logarithm of its rank. -/
theorem vnEntropy_lt_log_rank_of_not_flat {A : Matrix m m ℂ} (hA : A.PosSemidef)
    (htr : A.trace = 1)
    (hnf : ¬ ∀ i ∈ support hA.isHermitian.eigenvalues,
      hA.isHermitian.eigenvalues i = ((A.rank : ℝ))⁻¹) :
    vnEntropy A < Real.log A.rank :=
  lt_of_le_of_ne (vnEntropy_le_log_rank hA htr)
    (fun h => hnf ((vnEntropy_eq_log_rank_iff hA htr).mp h))

end VonNeumann

/-! ## Equality in the Schmidt-rank bound for mutual information -/

section Bipartite

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- Two Hermitian matrices whose characteristic polynomials differ by a power of
`X` (i.e. by extra zero eigenvalues) have the same von Neumann entropy. -/
lemma vnEntropy_eq_of_charpoly_eq_X_pow_mul {A : Matrix α α ℂ} {B : Matrix β β ℂ}
    (hA : A.IsHermitian) (hB : B.IsHermitian) {k : ℕ}
    (h : A.charpoly = Polynomial.X ^ k * B.charpoly) :
    vnEntropy A = vnEntropy B := by
  have hne : (Polynomial.X : Polynomial ℂ) ^ k * B.charpoly ≠ 0 :=
    mul_ne_zero (pow_ne_zero _ Polynomial.X_ne_zero) (Matrix.charpoly_monic B).ne_zero
  rw [vnEntropy_eq_multiset_sum hA, vnEntropy_eq_multiset_sum hB, h,
    Polynomial.roots_mul hne, Polynomial.roots_pow, Polynomial.roots_X,
    Multiset.nsmul_singleton, Multiset.map_add, Multiset.sum_add, Multiset.map_replicate]
  simp [Multiset.sum_replicate]

/-- **The two marginals of a bipartite pure state have the same entropy**, for
arbitrary (not necessarily equal) part dimensions: the two reduced density
matrices have the same nonzero spectrum. -/
theorem vnEntropy_rhoLeft_eq_rhoRight_general (M : Matrix α β ℂ) :
    vnEntropy (rhoLeft M) = vnEntropy (rhoRight M) := by
  rcases le_total (Fintype.card β) (Fintype.card α) with h | h
  · exact vnEntropy_eq_of_charpoly_eq_X_pow_mul (rhoLeft_posSemidef M).isHermitian
      (rhoRight_posSemidef M).isHermitian (Matrix.charpoly_mul_comm_of_le M Mᴴ h)
  · exact (vnEntropy_eq_of_charpoly_eq_X_pow_mul (rhoRight_posSemidef M).isHermitian
      (rhoLeft_posSemidef M).isHermitian (Matrix.charpoly_mul_comm_of_le Mᴴ M h)).symm

/-- For an arbitrary bipartite pure state the mutual information across the cut
is twice the entanglement entropy. -/
theorem mutualInformation_eq_two_mul_entanglementEntropy_general (M : Matrix α β ℂ) :
    mutualInformation M = 2 * entanglementEntropy M := by
  rw [mutualInformation, entanglementEntropy, ← vnEntropy_rhoLeft_eq_rhoRight_general M]
  ring

/-- The spectrum of the left marginal of a bipartite pure state is *flat* if all
its nonzero eigenvalues equal the reciprocal of the Schmidt rank. -/
def FlatSchmidtSpectrum (M : Matrix α β ℂ) : Prop :=
  ∀ i ∈ support (rhoLeft_posSemidef M).isHermitian.eigenvalues,
    (rhoLeft_posSemidef M).isHermitian.eigenvalues i = ((schmidtRank M : ℝ))⁻¹

omit [DecidableEq β] in
/-- **Equality in the entropy–Schmidt-rank bound.**  The entanglement entropy
across a cut equals `log (Schmidt rank)` exactly at a flat Schmidt spectrum. -/
theorem entanglementEntropy_eq_log_schmidtRank_iff {M : Matrix α β ℂ} (hM : Normalized M) :
    entanglementEntropy M = Real.log (schmidtRank M) ↔ FlatSchmidtSpectrum M := by
  have h := vnEntropy_eq_log_rank_iff (rhoLeft_posSemidef M) (rhoLeft_trace hM)
  rw [rank_rhoLeft] at h
  exact h

omit [DecidableEq β] in
/-- Strict inequality away from a flat Schmidt spectrum. -/
theorem entanglementEntropy_lt_log_schmidtRank_of_not_flat {M : Matrix α β ℂ}
    (hM : Normalized M) (hnf : ¬ FlatSchmidtSpectrum M) :
    entanglementEntropy M < Real.log (schmidtRank M) :=
  lt_of_le_of_ne (entanglementEntropy_le_log_schmidtRank hM)
    (fun h => hnf ((entanglementEntropy_eq_log_schmidtRank_iff hM).mp h))

/-- **Strict Schmidt-rank bound off flat spectra.**  If the Schmidt spectrum of
a bipartite pure state is not flat, the mutual information across the cut is
*strictly* smaller than `2 log (Schmidt rank)`: the rank alone never determines
the mutual information away from the flat case. -/
theorem mutualInformation_lt_two_log_schmidtRank_of_not_flat {M : Matrix α β ℂ}
    (hM : Normalized M) (hnf : ¬ FlatSchmidtSpectrum M) :
    mutualInformation M < 2 * Real.log (schmidtRank M) := by
  have hleft : vnEntropy (rhoLeft M) < Real.log (schmidtRank M) :=
    entanglementEntropy_lt_log_schmidtRank_of_not_flat hM hnf
  have hright : vnEntropy (rhoRight M) ≤ Real.log (schmidtRank M) := by
    have := vnEntropy_le_log_rank (rhoRight_posSemidef M) (rhoRight_trace hM)
    rwa [rank_rhoRight] at this
  simp only [mutualInformation]
  linarith

/-- **Equality in the mutual-information–Schmidt-rank bound.**  The mutual
information across a cut equals `2 log (Schmidt rank)` exactly at a flat Schmidt
spectrum. -/
theorem mutualInformation_eq_two_log_schmidtRank_iff {M : Matrix α β ℂ} (hM : Normalized M) :
    mutualInformation M = 2 * Real.log (schmidtRank M) ↔ FlatSchmidtSpectrum M := by
  rw [mutualInformation_eq_two_mul_entanglementEntropy_general M]
  constructor
  · intro h
    exact (entanglementEntropy_eq_log_schmidtRank_iff hM).mp (by linarith)
  · intro h
    rw [(entanglementEntropy_eq_log_schmidtRank_iff hM).mpr h]

end Bipartite


/-! ## Product cuts destroy integrated information -/

section ProductCut

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- A bipartite coefficient matrix is a *product across the cut* when it is the
outer product of a vector on the left part and a vector on the right part. -/
def ProductAcross (M : Matrix α β ℂ) : Prop :=
  ∃ (a : α → ℂ) (b : β → ℂ), M = Matrix.of fun i j => a i * b j

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- A product state has bond dimension one. -/
theorem hasBondDim_one_of_product {M : Matrix α β ℂ} (h : ProductAcross M) :
    HasBondDim M 1 := by
  obtain ⟨a, b, rfl⟩ := h
  refine ⟨Matrix.of fun i _ => a i, Matrix.of fun _ j => b j, ?_⟩
  ext i j
  simp [Matrix.mul_apply]

omit [DecidableEq β] in
/-- **A product cut has Schmidt rank one.** -/
theorem schmidtRank_eq_one_of_product {M : Matrix α β ℂ} (hM : Normalized M)
    (h : ProductAcross M) : schmidtRank M = 1 :=
  le_antisymm (schmidtRank_le_of_hasBondDim (hasBondDim_one_of_product h)) (schmidtRank_pos hM)

/-- **A product cut carries no mutual information.** -/
theorem mutualInformation_eq_zero_of_product {M : Matrix α β ℂ} (hM : Normalized M)
    (h : ProductAcross M) : mutualInformation M = 0 :=
  (mutualInformation_eq_zero_iff_schmidtRank_eq_one hM).mpr (schmidtRank_eq_one_of_product hM h)

end ProductCut

/-! ## Consequences for the integrated information of a chain -/

section Chain

variable {n d : ℕ} {psi : (Fin n → Fin d) → ℂ}

/-- If the amplitudes of a chain state factorize at the cut `l`, its cut matrix
is a product matrix. -/
theorem productAcross_chainCutMatrix {l : ℕ} (hl : l ≤ n) {a : (Fin l → Fin d) → ℂ}
    {b : (Fin (n - l) → Fin d) → ℂ} (h : ∀ f g, psi (glue l hl f g) = a f * b g) :
    ProductAcross (chainCutMatrix psi l hl) :=
  ⟨a, b, by ext f g; exact h f g⟩

/-- **A single product cut annihilates `Φ`.**  If a chain state factorizes
across one bipartition, then its integrated information vanishes — no matter how
entangled the two blocks are internally.  This is the formal content of the IIT
slogan that a system is *reducible* as soon as one cut is informationless. -/
theorem phi_eq_zero_of_product_cut (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n)
    (p : Fin (n - 1))
    (hprod : ProductAcross (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega))) :
    Phi hpsi hn = 0 :=
  (phi_eq_zero_iff_exists_product_cut hpsi hn).mpr
    ⟨p, schmidtRank_eq_one_of_product (normalized_chainCutMatrix hpsi _ _) hprod⟩

/-- **A non-flat cut is strictly below the Schmidt-rank cap.**  If the marginal
spectrum at some bipartition is not flat, then `Φ` is strictly smaller than
`2 log (Schmidt rank)` at that cut; equality in the Schmidt-rank bound therefore
forces a maximally entangled (flat) cut. -/
theorem phi_lt_two_log_schmidtRank_of_not_flat_cut (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n)
    (p : Fin (n - 1))
    (hnf : ¬ FlatSchmidtSpectrum (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega))) :
    Phi hpsi hn
      < 2 * Real.log (schmidtRank (chainCutMatrix psi ((p : ℕ) + 1)
          (by have := p.isLt; omega))) :=
  lt_of_le_of_lt (phi_le_mutualInformation hpsi hn p)
    (mutualInformation_lt_two_log_schmidtRank_of_not_flat
      (normalized_chainCutMatrix hpsi _ _) hnf)

/-- **Factorization at one cut kills `Φ`.**  Cut-index-free form of
`phi_eq_zero_of_product_cut`. -/
theorem phi_eq_zero_of_factorizes_at (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) {l : ℕ}
    (hl1 : 1 ≤ l) (hlr : l < n) {a : (Fin l → Fin d) → ℂ} {b : (Fin (n - l) → Fin d) → ℂ}
    (h : ∀ f g, psi (glue l (le_of_lt hlr) f g) = a f * b g) :
    Phi hpsi hn = 0 := by
  obtain ⟨k, rfl⟩ : ∃ k, l = k + 1 := ⟨l - 1, by omega⟩
  exact phi_eq_zero_of_product_cut hpsi hn ⟨k, by omega⟩
    (productAcross_chainCutMatrix (le_of_lt hlr) h)

/-- **Saturation criterion for `Φ`.**  The integrated information of a chain
state equals `2 log (Schmidt rank)` at a given bipartition exactly when that cut
is maximally entangled (flat Schmidt spectrum) *and* no other cut carries less
information.  This is the equality analysis accompanying the bound
`phi_le_two_log_of_bondDim`. -/
theorem phi_eq_two_log_schmidtRank_iff (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n)
    (p : Fin (n - 1)) :
    Phi hpsi hn
        = 2 * Real.log (schmidtRank (chainCutMatrix psi ((p : ℕ) + 1)
            (by have := p.isLt; omega))) ↔
      (FlatSchmidtSpectrum (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) ∧
        ∀ q : Fin (n - 1),
          2 * Real.log (schmidtRank (chainCutMatrix psi ((p : ℕ) + 1)
              (by have := p.isLt; omega)))
            ≤ mutualInformation (chainCutMatrix psi ((q : ℕ) + 1)
              (by have := q.isLt; omega))) := by
  constructor
  · intro heq
    refine ⟨?_, fun q => ?_⟩
    · by_contra hnf
      exact absurd heq (ne_of_lt (phi_lt_two_log_schmidtRank_of_not_flat_cut hpsi hn p hnf))
    · rw [← heq]
      exact phi_le_mutualInformation hpsi hn q
  · rintro ⟨hflat, hmin⟩
    refine le_antisymm ?_ ?_
    · refine le_trans (phi_le_mutualInformation hpsi hn p) ?_
      exact le_of_eq ((mutualInformation_eq_two_log_schmidtRank_iff
        (normalized_chainCutMatrix hpsi _ _)).mpr hflat)
    · exact le_phi hpsi hn hmin

end Chain

/-! ## Concatenation of two chains -/

section Concatenation

variable {n d : ℕ}

/-- The **concatenation** of a state of the first `l` sites with a state of the
remaining `n - l` sites: the two blocks are prepared independently. -/
noncomputable def concatState {l : ℕ} (hl : l ≤ n) (psiA : (Fin l → Fin d) → ℂ)
    (psiB : (Fin (n - l) → Fin d) → ℂ) : (Fin n → Fin d) → ℂ :=
  fun s => psiA (splitL l hl s) * psiB (splitR l hl s)

lemma concatState_glue {l : ℕ} (hl : l ≤ n) (psiA : (Fin l → Fin d) → ℂ)
    (psiB : (Fin (n - l) → Fin d) → ℂ) (f : Fin l → Fin d) (g : Fin (n - l) → Fin d) :
    concatState hl psiA psiB (glue l hl f g) = psiA f * psiB g := by
  rw [concatState, splitL_glue, splitR_glue]

/-- A concatenation of two normalized block states is a normalized chain
state. -/
theorem concatState_normalized {l : ℕ} (hl : l ≤ n) {psiA : (Fin l → Fin d) → ℂ}
    {psiB : (Fin (n - l) → Fin d) → ℂ} (hA : ∑ f, ‖psiA f‖ ^ 2 = 1)
    (hB : ∑ g, ‖psiB g‖ ^ 2 = 1) :
    ∑ s, ‖concatState hl psiA psiB s‖ ^ 2 = 1 := by
  rw [← Equiv.sum_comp (chainEquiv l hl).symm (fun s => ‖concatState hl psiA psiB s‖ ^ 2)]
  have hterm : ∀ p : (Fin l → Fin d) × (Fin (n - l) → Fin d),
      ‖concatState hl psiA psiB ((chainEquiv l hl).symm p)‖ ^ 2
        = ‖psiA p.1‖ ^ 2 * ‖psiB p.2‖ ^ 2 := by
    rintro ⟨f, g⟩
    show ‖concatState hl psiA psiB (glue l hl f g)‖ ^ 2 = _
    rw [concatState_glue, norm_mul, mul_pow]
  rw [Finset.sum_congr rfl (fun p _ => hterm p), Fintype.sum_prod_type]
  calc ∑ x : Fin l → Fin d, ∑ y : Fin (n - l) → Fin d, ‖psiA x‖ ^ 2 * ‖psiB y‖ ^ 2
      = (∑ x, ‖psiA x‖ ^ 2) * ∑ y, ‖psiB y‖ ^ 2 := (Fintype.sum_mul_sum _ _).symm
    _ = 1 := by rw [hA, hB, one_mul]

/-- **Concatenation destroys integrated information.**  However entangled the
two blocks are internally, the concatenated chain factorizes across the junction
and therefore has `Φ = 0`: integrated information is *not* additive under
parallel composition of chains, it collapses. -/
theorem phi_concatState_eq_zero {l : ℕ} (hl1 : 1 ≤ l) (hlr : l < n) (hn : 2 ≤ n)
    {psiA : (Fin l → Fin d) → ℂ} {psiB : (Fin (n - l) → Fin d) → ℂ}
    (hA : ∑ f, ‖psiA f‖ ^ 2 = 1) (hB : ∑ g, ‖psiB g‖ ^ 2 = 1) :
    Phi (concatState_normalized (le_of_lt hlr) hA hB) hn = 0 :=
  phi_eq_zero_of_factorizes_at _ hn hl1 hlr
    (concatState_glue (le_of_lt hlr) psiA psiB)

end Concatenation

end IITTensorNetwork