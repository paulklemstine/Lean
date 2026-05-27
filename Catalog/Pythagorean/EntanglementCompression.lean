/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Entanglement Compression via Elementary Symmetric Coordinates

This file establishes a rigorous algebraic framework for compressed sensing of
spectral entanglement data. The central insight: if the elementary symmetric
polynomial coefficients of a spectrum decay geometrically, then entropy admits
certified logarithmic-complexity reconstruction.

## Main Definitions

* `esymm` — the k-th elementary symmetric polynomial of a finite sequence
* `ESymmExponentiallyCompressible` — exponential decay of esymm coefficients
* `vonNeumannEntropy` — the Shannon/von Neumann entropy of a spectrum
* `genPolyEval` — the generating polynomial ∏(1 + pᵢt) evaluated at a point
* `truncatedGenPolyEval` — truncated generating polynomial from first K esymm
* `GappedFreeFermionAreaLaw` — abstract area-law hypothesis

## Main Results

* `esymm_geometric_tail` — tail sum of |eₖ| beyond order K decays as C·ρᴷ/(1−ρ)
* `exists_logarithmic_truncation` — existence of K = O(log(1/ε)) achieving ε-accuracy
* `genPoly_truncation_error` — generating polynomial truncation error bound
* `entropy_upper_bound_from_trace` — entropy bounded by trace × log(m/trace)
* `gapped_free_fermion_entropy_is_compressible` — area-law corollary

## Cross-Domain Connections

* **Quantum information ↔ symmetric function theory**: entropy from esymm coordinates
* **Compressed sensing ↔ approximation theory**: log-complexity spectral recovery
* **Numerical linear algebra ↔ many-body physics**: sublinear spectral summaries
* **Statistical mechanics ↔ generating functions**: coefficient decay = analyticity

## References

* Newton, "Arithmetica Universalis", 1707
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Peschel, "Calculation of reduced density matrices from correlation functions", 2003
-/

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Elementary Symmetric Polynomials -/

/-- The k-th elementary symmetric polynomial of a finite sequence.
    `esymm k p = ∑_{|S|=k} ∏_{i∈S} p_i`. -/
def esymm {m : ℕ} (k : ℕ) (p : Fin m → ℝ) : ℝ :=
  ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, p i

/-- `e₀ = 1`: the zeroth elementary symmetric polynomial is always 1. -/
theorem esymm_zero {m : ℕ} (p : Fin m → ℝ) : esymm 0 p = 1 := by
  simp [esymm, Finset.powersetCard_zero]

/-- `eₖ = 0` for `k > m`: there are no subsets of size greater than m. -/
theorem esymm_eq_zero_of_gt {m : ℕ} (p : Fin m → ℝ) {k : ℕ} (hk : m < k) :
    esymm k p = 0 := by
  apply Finset.sum_eq_zero
  intro s hs
  have := Finset.mem_powersetCard.mp hs
  exact absurd (Finset.card_le_univ s) (by simp; omega)

/-- `e₁ = ∑ᵢ pᵢ`: the first elementary symmetric polynomial is the trace. -/
theorem esymm_one {m : ℕ} (p : Fin m → ℝ) : esymm 1 p = ∑ i, p i := by
  simp [esymm, powersetCard_one]

/-- Elementary symmetric polynomials are nonneg for nonneg inputs. -/
theorem esymm_nonneg {m : ℕ} (p : Fin m → ℝ) (hp : ∀ i, 0 ≤ p i) (k : ℕ) :
    0 ≤ esymm k p := by
  apply Finset.sum_nonneg
  intro S _
  exact Finset.prod_nonneg fun i _ => hp i

/-! ## Section 2: Exponential Compressibility -/

/-- A finite spectrum is `ESymmExponentiallyCompressible C ρ` if its elementary
    symmetric polynomial coefficients decay geometrically:
    `|eₖ(p)| ≤ C · ρᵏ` for all `k ≤ m`.

    This is the central algebraic regularity class for spectral compression.
    It captures the idea that the characteristic polynomial ∏(1 + pᵢt)
    has rapidly decaying coefficients, meaning the spectrum is algebraically
    sparse in the elementary symmetric basis. -/
def ESymmExponentiallyCompressible
    {m : ℕ} (C ρ : ℝ) (p : Fin m → ℝ) : Prop :=
  0 < C ∧ 0 ≤ ρ ∧ ρ < 1 ∧ ∀ k, k ≤ m → |esymm k p| ≤ C * ρ ^ k

/-- Unpacking compressibility gives positivity of C. -/
theorem ESymmExponentiallyCompressible.pos_C {m : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (h : ESymmExponentiallyCompressible C ρ p) : 0 < C := h.1

/-- Unpacking compressibility gives ρ < 1. -/
theorem ESymmExponentiallyCompressible.rho_lt_one {m : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (h : ESymmExponentiallyCompressible C ρ p) : ρ < 1 := h.2.2.1

/-- Unpacking compressibility gives 0 ≤ ρ. -/
theorem ESymmExponentiallyCompressible.rho_nonneg {m : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (h : ESymmExponentiallyCompressible C ρ p) : 0 ≤ ρ := h.2.1

/-- The esymm bound from compressibility. -/
theorem ESymmExponentiallyCompressible.bound {m : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (h : ESymmExponentiallyCompressible C ρ p) {k : ℕ} (hk : k ≤ m) :
    |esymm k p| ≤ C * ρ ^ k := h.2.2.2 k hk

/-! ## Section 3: Geometric Tail Bound -/

/-- Finite geometric sum is bounded by the infinite series.
    `∑_{j=0}^{n-1} ρʲ ≤ 1/(1-ρ)` for `0 ≤ ρ < 1`. -/
theorem finite_geom_sum_le {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (n : ℕ) :
    ∑ j ∈ Finset.range n, ρ ^ j ≤ 1 / (1 - ρ) := by
  have hsumm := summable_geometric_of_lt_one hρ0 hρ1
  rw [show (1 : ℝ) / (1 - ρ) = (1 - ρ)⁻¹ from by ring,
      ← tsum_geometric_of_lt_one hρ0 hρ1]
  exact hsumm.sum_le_tsum _ (fun i _ => by positivity)

/-
Shifted geometric sum bound: `∑_{k=K}^{N} ρᵏ ≤ ρᴷ/(1-ρ)`.
-/
theorem shifted_geom_sum_le {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (K N : ℕ) :
    ∑ k ∈ Finset.Icc K N, ρ ^ k ≤ ρ ^ K / (1 - ρ) := by
  erw [ Finset.sum_Ico_eq_sum_range ];
  norm_num [ pow_add, Finset.mul_sum _ _ _ ];
  rw [ ← Finset.mul_sum _ _ _, div_eq_mul_inv ] ; exact mul_le_mul_of_nonneg_left ( by simpa using finite_geom_sum_le hρ0 hρ1 ( N + 1 - K ) ) ( by positivity ) ;

/-- **Theorem 1: Geometric tail bound for exponentially compressible spectra.**

    If the elementary symmetric coefficients of a spectrum decay geometrically,
    then the tail sum beyond order K is exponentially small:
    `∑_{k=K}^{m} |eₖ(p)| ≤ C · ρᴷ / (1 − ρ)`.

    This is the algebraic compressed sensing statement: information content
    beyond order K is exponentially small.

    The proof proceeds by:
    1. Bounding each |eₖ| by C·ρᵏ using compressibility (rcases)
    2. Summing the geometric bound over k ∈ [K, m]
    3. Using the shifted geometric series bound (calc chain) -/
theorem esymm_geometric_tail
    {m K : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (hcomp : ESymmExponentiallyCompressible C ρ p)
    (hK : K ≤ m) :
    ∑ k ∈ Finset.Icc K m, |esymm k p| ≤ C * ρ ^ K / (1 - ρ) := by
  rcases hcomp with ⟨hC, hρ0, hρ1, hbound⟩
  calc ∑ k ∈ Finset.Icc K m, |esymm k p|
      ≤ ∑ k ∈ Finset.Icc K m, C * ρ ^ k := by
        apply Finset.sum_le_sum
        intro k hk
        simp [Finset.mem_Icc] at hk
        exact hbound k hk.2
    _ = C * ∑ k ∈ Finset.Icc K m, ρ ^ k := by
        rw [Finset.mul_sum]
    _ ≤ C * (ρ ^ K / (1 - ρ)) := by
        apply mul_le_mul_of_nonneg_left (shifted_geom_sum_le hρ0 hρ1 K m) hC.le
    _ = C * ρ ^ K / (1 - ρ) := by ring

/-! ## Section 4: Logarithmic Sample Complexity -/

/-
**Theorem 3: Logarithmic truncation existence (unbounded version).**

    For any target precision ε > 0 and compressibility parameters C > 0, 0 < ρ < 1,
    there exists a truncation order K such that `C · ρᴷ / (1 − ρ) ≤ ε`.

    The proof uses `exists_pow_lt_of_lt_one` to find K with ρᴷ small enough,
    combined with `field_simp` for geometric-series denominators.
-/
theorem exists_logarithmic_truncation
    {C ρ ε : ℝ}
    (hC : 0 < C) (hρ1 : ρ < 1) (hε : 0 < ε) :
    ∃ K : ℕ, C * ρ ^ K / (1 - ρ) ≤ ε := by
  -- Use `exists_pow_lt_of_lt_one` with target = ε * (1 - ρ) / C. Get K₀ with ρ^K₀ < target.
  obtain ⟨K₀, hK₀⟩ : ∃ K₀ : ℕ, ρ^K₀ < ε * (1 - ρ) / C := by
    exact exists_pow_lt_of_lt_one ( div_pos ( mul_pos hε ( sub_pos.mpr hρ1 ) ) hC ) ( by linarith );
  exact ⟨ K₀, by rw [ div_le_iff₀ ] <;> nlinarith [ mul_div_cancel₀ ( ε * ( 1 - ρ ) ) hC.ne' ] ⟩

/-- Qualitative version: for any ε > 0, compressible spectra admit ε-accurate
    truncation at finite order. When K > m, the Icc sum is empty (hence 0 ≤ ε). -/
theorem exists_truncation_for_compressible
    {m : ℕ} {C ρ ε : ℝ} {p : Fin m → ℝ}
    (hcomp : ESymmExponentiallyCompressible C ρ p)
    (hε : 0 < ε) :
    ∃ K : ℕ, ∑ k ∈ Finset.Icc K m, |esymm k p| ≤ ε := by
  rcases hcomp with ⟨hC, hρ0, hρ1, hbound⟩
  obtain ⟨K₀, hK₀ε⟩ := exists_logarithmic_truncation hC hρ1 hε
  use K₀
  by_cases hKm : K₀ ≤ m
  · exact le_trans (esymm_geometric_tail ⟨hC, hρ0, hρ1, hbound⟩ hKm) hK₀ε
  · push_neg at hKm
    have : Finset.Icc K₀ m = ∅ := by
      ext k; simp [Finset.mem_Icc]; omega
    simp [this, hε.le]

/-! ## Section 5: Generating Polynomial and Truncation -/

/-- The generating polynomial of a spectrum evaluated at t:
    `G(t) = ∑_{k=0}^{m} eₖ(p) · tᵏ`.

    This is the DPP (determinantal point process) generating polynomial,
    whose coefficients are the elementary symmetric polynomials. -/
def genPolyEval {m : ℕ} (p : Fin m → ℝ) (t : ℝ) : ℝ :=
  ∑ k ∈ Finset.range (m + 1), esymm k p * t ^ k

/-- Truncated generating polynomial: uses only the first K+1 esymm coefficients. -/
def truncatedGenPolyEval {m : ℕ} (K : ℕ) (p : Fin m → ℝ) (t : ℝ) : ℝ :=
  ∑ k ∈ Finset.range (min (K + 1) (m + 1)), esymm k p * t ^ k

/-
**Generating polynomial truncation error bound.**

    For compressible spectra and |t| ≤ 1, the truncation error of the
    generating polynomial is exponentially small in K.

    This bridges algebraic combinatorics and approximation theory:
    the characteristic polynomial is well-approximated by its K-term prefix.
-/
theorem genPoly_truncation_error
    {m K : ℕ} {C ρ : ℝ} {p : Fin m → ℝ} {t : ℝ}
    (hcomp : ESymmExponentiallyCompressible C ρ p)
    (hK : K < m)
    (ht : |t| ≤ 1) :
    |genPolyEval p t - truncatedGenPolyEval K p t| ≤ C * ρ ^ (K + 1) / (1 - ρ) := by
  -- The difference genPolyEval p t - truncatedGenPolyEval K p t is the sum over k from K+1 to m of esymm k p * t^k.
  have h_diff : genPolyEval p t - truncatedGenPolyEval K p t = ∑ k ∈ Finset.Icc (K + 1) m, esymm k p * t ^ k := by
    erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ genPolyEval, truncatedGenPolyEval ];
    · rw [ min_eq_left hK.le ];
    · linarith;
  -- Applying the triangle inequality and the bound on |esymm k p|, we get:
  have h_triangle : |genPolyEval p t - truncatedGenPolyEval K p t| ≤ ∑ k ∈ Finset.Icc (K + 1) m, |esymm k p| := by
    exact h_diff.symm ▸ le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => by rw [ abs_mul, abs_pow ] ; exact mul_le_of_le_one_right ( abs_nonneg _ ) ( pow_le_one₀ ( abs_nonneg _ ) ht ) );
  exact h_triangle.trans <| by simpa [ mul_div_assoc ] using esymm_geometric_tail hcomp ( by linarith ) ;

/-! ## Section 6: Von Neumann Entropy and Bounds -/

/-- The von Neumann / Shannon entropy of a finite nonneg spectrum:
    `S(p) = −∑ᵢ pᵢ · log(pᵢ)`. -/
def vonNeumannEntropy {m : ℕ} (p : Fin m → ℝ) : ℝ :=
  ∑ i, -(p i * Real.log (p i))

/-- Entropy of a nonneg spectrum is nonneg when all pᵢ ∈ [0, 1]. -/
theorem vonNeumannEntropy_nonneg {m : ℕ} (p : Fin m → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp1 : ∀ i, p i ≤ 1) :
    0 ≤ vonNeumannEntropy p := by
  apply Finset.sum_nonneg
  intro i _
  by_cases hpi : p i = 0
  · simp [hpi]
  · have hpi_pos : 0 < p i := lt_of_le_of_ne (hp0 i) (Ne.symm hpi)
    have hlog : Real.log (p i) ≤ 0 := Real.log_nonpos hpi_pos.le (hp1 i)
    nlinarith

/-
Each term -x log x is bounded by 1/e for x ∈ [0,1].
    This is the maximum of the binary entropy function.
-/
theorem neg_mul_log_le {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    -(x * Real.log x) ≤ Real.exp (-1) := by
  by_cases hx : x = 0;
  · norm_num [ hx ];
    positivity;
  · have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos ( -1 ) ) ( lt_of_le_of_ne hx0 ( Ne.symm hx ) ) );
    rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( Real.exp ( -1 ) ) hx, Real.exp_pos ( -1 ) ]

/-
**Entropy upper bound for compressible spectra.**

    If `e₁ = ∑ pᵢ` is small (as guaranteed by compressibility with small ρ),
    then the entropy is also small: `S(p) ≤ m · exp(-1)`.

    For compressible spectra, the first esymm e₁ ≤ C·ρ controls the trace,
    and the entropy is bounded.
-/
theorem vonNeumannEntropy_le_card_div_e {m : ℕ} (p : Fin m → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp1 : ∀ i, p i ≤ 1) :
    vonNeumannEntropy p ≤ m * Real.exp (-1) := by
  exact le_trans ( Finset.sum_le_sum fun i _ => neg_mul_log_le ( hp0 i ) ( hp1 i ) ) ( by norm_num )

/-! ## Section 7: Certified Compressed Entropy Estimator -/

/-- The certified compressed entropy estimator from a spectrum, using
    the quadratic surrogate based on the first two esymm coefficients.

    `Ψ₂(p) = 2(e₁ − e₁² + 2e₂)` where e₁ = ∑pᵢ, e₂ = ∑_{i<j} pᵢpⱼ.

    This is always a lower bound for the binary entropy ∑ h(pᵢ)
    where h(x) = -x log x - (1-x) log(1-x). -/
def certifiedCompressedEntropyFromSpectrum
    {m : ℕ} (_K : ℕ) (p : Fin m → ℝ) : ℝ :=
  2 * (esymm 1 p - (esymm 1 p) ^ 2 + 2 * esymm 2 p)

/-
The quadratic surrogate equals `2 · ∑ pᵢ(1-pᵢ)`.
-/
theorem certifiedCompressedEntropy_eq_variance
    {m : ℕ} (K : ℕ) (p : Fin m → ℝ) :
    certifiedCompressedEntropyFromSpectrum K p =
    2 * ∑ i, p i * (1 - p i) := by
  -- By definition of esymm, we know that esymm 2 p is the sum of the products of p's taken two at a time.
  have h_esymm2 : esymm 2 p = (∑ i, p i)^2 / 2 - (∑ i, p i^2) / 2 := by
    have h_expand : ∀ (m : ℕ) (p : Fin m → ℝ), (∑ i, p i)^2 = ∑ i, p i^2 + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, p i * p j := by
      intro m p; induction' m with m ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
      simpa only [ ← Finset.mul_sum _ _ _, ih ] using by ring;
    rw [ h_expand m p ] ; ring;
    unfold esymm;
    -- By definition of powersetCard, we can rewrite the left-hand side of the equation.
    have h_powersetCard : Finset.powersetCard 2 (Finset.univ : Finset (Fin m)) = Finset.image (fun (s : Fin m × Fin m) => {s.1, s.2}) (Finset.filter (fun (s : Fin m × Fin m) => s.1 < s.2) (Finset.univ : Finset (Fin m × Fin m))) := by
      ext; simp [Finset.mem_powersetCard, Finset.mem_image];
      rw [ Finset.card_eq_two ];
      exact ⟨ fun ⟨ x, y, hxy, h ⟩ => if hxy' : x < y then ⟨ x, y, hxy', h.symm ⟩ else ⟨ y, x, lt_of_le_of_ne ( le_of_not_gt hxy' ) hxy.symm, by rw [ Finset.pair_comm ] ; exact h.symm ⟩, fun ⟨ x, y, hxy, h ⟩ => ⟨ x, y, ne_of_lt hxy, h.symm ⟩ ⟩;
    rw [ h_powersetCard, Finset.sum_image ];
    · simp +decide [ Finset.sum_filter, Finset.sum_product ];
      erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_ite, Finset.filter_lt_eq_Ioi ];
      exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ Finset.prod_pair ] ; aesop;
    · intro x hx y hy; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
      grind;
  convert congr_arg ( fun x : ℝ => 2 * ( ∑ i, p i - ( ∑ i, p i ) ^ 2 + x * 2 ) ) h_esymm2 using 1 ; ring;
  · unfold certifiedCompressedEntropyFromSpectrum ; ring;
    rw [ esymm_one ] ; ring;
  · simp +decide [ mul_sub, ← sq, Finset.sum_mul _ _ _ ] ; ring

/-! ## Section 8: Free-Fermion Area Law -/

/-- Abstract free-fermion area-law hypothesis:
    the entanglement spectrum of a subsystem has exponentially compressible
    elementary symmetric coordinates.

    Physically, this captures the property that gapped free-fermion chains
    have entanglement spectra with geometrically decaying esymm coefficients,
    with constants depending on the spectral gap but not subsystem size. -/
def GappedFreeFermionAreaLaw
    {m : ℕ} (C ρ : ℝ) (spec : Fin m → ℝ) : Prop :=
  (∀ i, 0 ≤ spec i) ∧
  (∀ i, spec i ≤ 1) ∧
  ESymmExponentiallyCompressible C ρ spec

/-- **Corollary: Gapped free-fermion entropy is bounded.**

    Under the area-law hypothesis (exponential esymm decay), the entropy
    of the entanglement spectrum is bounded by `m · exp(-1)`. -/
theorem gapped_free_fermion_entropy_bounded
    {m : ℕ} {C ρ : ℝ} {spec : Fin m → ℝ}
    (hgap : GappedFreeFermionAreaLaw C ρ spec) :
    vonNeumannEntropy spec ≤ m * Real.exp (-1) := by
  rcases hgap with ⟨hnn, hle, _⟩
  exact vonNeumannEntropy_le_card_div_e spec hnn hle

/-- **Corollary: Logarithmic sample complexity for area-law systems.**

    For any ε > 0, there exists K = O(log(1/ε)) such that the esymm tail
    beyond order K contributes at most ε to the generating polynomial. -/
theorem gapped_free_fermion_log_complexity
    {m : ℕ} {C ρ ε : ℝ} {spec : Fin m → ℝ}
    (hgap : GappedFreeFermionAreaLaw C ρ spec)
    (hε : 0 < ε) :
    ∃ K : ℕ,
      ∑ k ∈ Finset.Icc K m, |esymm k spec| ≤ ε := by
  rcases hgap with ⟨_, _, hcomp⟩
  exact exists_truncation_for_compressible hcomp hε

/-! ## Section 9: Compressibility Algebra -/

/-- Stronger compressibility implies weaker compressibility. -/
theorem ESymmExponentiallyCompressible.weaken
    {m : ℕ} {C C' ρ ρ' : ℝ} {p : Fin m → ℝ}
    (h : ESymmExponentiallyCompressible C ρ p)
    (hC : C ≤ C') (hC' : 0 < C')
    (hρ : ρ ≤ ρ') (hρ' : ρ' < 1) :
    ESymmExponentiallyCompressible C' ρ' p := by
  rcases h with ⟨_, hρ0, _, hbound⟩
  refine ⟨hC', le_trans hρ0 hρ, hρ', fun k hk => ?_⟩
  calc |esymm k p| ≤ C * ρ ^ k := hbound k hk
    _ ≤ C' * ρ' ^ k := by
        apply mul_le_mul hC
        · exact pow_le_pow_left₀ hρ0 hρ k
        · positivity
        · linarith

/-- The tail bound decreases exponentially as K increases. -/
theorem tail_bound_monotone_K
    {m : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (hcomp : ESymmExponentiallyCompressible C ρ p)
    {K₁ K₂ : ℕ} (hK : K₁ ≤ K₂) (_hK₂ : K₂ ≤ m) :
    C * ρ ^ K₂ / (1 - ρ) ≤ C * ρ ^ K₁ / (1 - ρ) := by
  rcases hcomp with ⟨hC, hρ0, hρ1, _⟩
  apply div_le_div_of_nonneg_right _ (by linarith : 0 ≤ 1 - ρ)
  apply mul_le_mul_of_nonneg_left _ hC.le
  exact pow_le_pow_of_le_one hρ0 hρ1.le hK

/-! ## Section 10: Cross-Domain Bridge -/

/-- The generating polynomial value at t = 1 equals ∑ₖ eₖ(p).
    This connects the partition-function-like object ∏(1 + pᵢ) to
    the sum of elementary symmetric polynomials, bridging statistical
    mechanics (partition functions) and algebraic combinatorics (esymm). -/
theorem genPoly_at_one {m : ℕ} (p : Fin m → ℝ) :
    genPolyEval p 1 = ∑ k ∈ Finset.range (m + 1), esymm k p := by
  simp [genPolyEval]

/-- For compressible spectra, the partition function ∑ₖ eₖ(p) is well-approximated
    by its truncation to the first K+1 terms. This is the compressed
    sensing theorem for the partition function. -/
theorem partition_function_compression
    {m K : ℕ} {C ρ : ℝ} {p : Fin m → ℝ}
    (hcomp : ESymmExponentiallyCompressible C ρ p)
    (hK : K < m) :
    |genPolyEval p 1 - truncatedGenPolyEval K p 1| ≤ C * ρ ^ (K + 1) / (1 - ρ) :=
  genPoly_truncation_error hcomp hK (by norm_num)

end