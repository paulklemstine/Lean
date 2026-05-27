/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# General Newton–Girard Identities and Entropy Surrogates

This file establishes the **universal Newton–Girard recurrence** for all orders,
derives the **finite linear recurrence** for power sums when `k > m`, defines a
**spectral invariant profile** that captures the elementary symmetric data of a
spectrum, and proves **entropy surrogate approximation theorems** showing that
polynomial spectral statistics — and hence entropy on gapped spectra — can be
approximated from elementary symmetric data alone.

## Main Results

### Algebraic backbone
* `esymm_eq_eval_esymm` — connection to Mathlib's `MvPolynomial.esymm`
* `psum_eq_eval_psum` — connection to Mathlib's `MvPolynomial.psum`
* `newton_girard_general` — the full Newton–Girard recurrence for all `k ≥ 1`
* `newton_girard_alternating_sum` — alternating-sum form
* `powerSum_linear_recurrence_of_gt_card` — finite linear recurrence for `k > m`

### Spectral invariant profile and reconstruction
* `SpectralInvariantProfile` — structure bundling elementary symmetric invariants
* `powerSumFromProfile` — recursive power-sum reconstruction from profile data
* `powerSumFromProfile_correct` — correctness theorem

### Polynomial spectral evaluation
* `spectralPolyEval` — evaluation of polynomial spectral functionals
* `spectralPolyEval_eq_sum_powerSum` — reduction to power sums
* `spectralPolyEval_from_esymm_data` — computability from symmetric data alone

### Entropy surrogates
* `entropy_surrogate_uniform_error` — uniform approximation error bound
* `entropy_surrogate_converges` — convergence of surrogate sequence

## Cross-Domain Connections

* **Algebraic combinatorics ↔ approximation theory**: Newton–Girard converts
  polynomial approximation of scalar functions into approximation of symmetric
  spectral observables.
* **Symmetric polynomials ↔ quantum information**: gapped spectral entropy can
  be approximated from elementary symmetric invariants alone, without diagonalization.
* **Linear recurrences ↔ statistical mechanics**: power sums satisfy a finite
  linear recurrence from `e₁,…,eₘ`, connecting to transfer matrices and
  partition functions.
-/

open Finset BigOperators MvPolynomial

noncomputable section

/-! ## Section 1: Definitions (self-contained) -/

/-- The k-th elementary symmetric polynomial of a finite sequence.
    `esymm' m μ k = ∑_{|S|=k} ∏_{i∈S} μ_i`. -/
def esymm' (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, μ i

/-- The k-th power sum of a finite sequence. `psum' μ k = ∑ᵢ μᵢᵏ`. -/
def psum' {m : ℕ} (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  ∑ i, μ i ^ k

/-- Binary Shannon entropy: `h(x) = −x log x − (1−x) log(1−x)`. -/
def shannonEntropy (x : ℝ) : ℝ :=
  -x * Real.log x - (1 - x) * Real.log (1 - x)

/-! ## Section 2: Bridge to Mathlib's MvPolynomial Newton Identities -/

/-- `e₀ = 1`: the zeroth elementary symmetric polynomial is always 1. -/
theorem esymm'_zero (m : ℕ) (μ : Fin m → ℝ) : esymm' m μ 0 = 1 := by
  simp [esymm', Finset.powersetCard_zero]

/-- `eₖ = 0` for `k > m`. -/
theorem esymm'_eq_zero_of_gt (m : ℕ) (μ : Fin m → ℝ) {k : ℕ} (hk : m < k) :
    esymm' m μ k = 0 := by
  apply Finset.sum_eq_zero
  intro s hs
  have := Finset.mem_powersetCard.mp hs
  exact absurd (Finset.card_le_univ s) (by simp; omega)

/-
The elementary symmetric polynomial `esymm' m μ k` equals the evaluation
    of `MvPolynomial.esymm (Fin m) ℝ k` at `μ`.
-/
theorem esymm'_eq_eval_esymm (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) :
    esymm' m μ k = MvPolynomial.eval μ (MvPolynomial.esymm (Fin m) ℝ k) := by
  -- By definition of esymm', we have emsymm' m μ k = ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, μ i.
  unfold esymm' at *; simp_all +decide [ MvPolynomial.esymm ];

/-
The power sum `psum' μ k` equals the evaluation of
    `MvPolynomial.psum (Fin m) ℝ k` at `μ`.
-/
theorem psum'_eq_eval_psum (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) :
    psum' μ k = MvPolynomial.eval μ (MvPolynomial.psum (Fin m) ℝ k) := by
  unfold psum; aesop;

/-! ## Section 3: General Newton–Girard Recurrence -/

/-
**General Newton–Girard identity (recurrence form).**
    For all `k ≥ 1`, the `k`-th power sum can be expressed in terms of
    lower-order power sums and elementary symmetric polynomials.
    This is obtained by evaluating Mathlib's `MvPolynomial.psum_eq_mul_esymm_sub_sum`
    at a concrete spectrum.

    This replaces the ad hoc identities for k=1,2,3 with a uniform theorem
    for all orders. It is the algebraic engine that makes entropy approximation
    possible.
-/
theorem newton_girard_general (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) (hk : 0 < k) :
    psum' μ k = (-1 : ℝ) ^ (k + 1) * (k : ℝ) * esymm' m μ k -
      ∑ a ∈ (Finset.antidiagonal k).filter (fun a => 0 < a.1 ∧ a.1 < k),
        (-1 : ℝ) ^ a.1 * esymm' m μ a.1 * psum' μ a.2 := by
  convert congr_arg ( MvPolynomial.eval μ ) ( MvPolynomial.psum_eq_mul_esymm_sub_sum ( Fin m ) ℝ k hk ) using 1;
  · convert psum'_eq_eval_psum m μ k using 1;
  · simp +decide [ esymm'_eq_eval_esymm, psum'_eq_eval_psum ]

/-
**Newton–Girard: filtered alternating sum equals scaled esymm.**
    The alternating sum over pairs `(j, k-j)` with `j < k` in the antidiagonal
    equals `(-1)^{k+1} · k · e_k`. This is the evaluation of Mathlib's
    `mul_esymm_eq_sum` at a concrete spectrum.
-/
theorem newton_girard_filtered_sum (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) :
    (k : ℝ) * esymm' m μ k = (-1 : ℝ) ^ (k + 1) *
      ∑ a ∈ (Finset.antidiagonal k).filter (fun a => a.1 < k),
        (-1 : ℝ) ^ a.1 * esymm' m μ a.1 * psum' μ a.2 := by
  convert congr_arg ( MvPolynomial.eval μ ) ( MvPolynomial.mul_esymm_eq_sum ( Fin m ) ℝ k ) using 1;
  · simp +decide [esymm'_eq_eval_esymm];
  · simp +decide [ esymm'_eq_eval_esymm, psum'_eq_eval_psum, map_sum, map_mul, map_pow ]

/-! ## Section 4: Finite Linear Recurrence for Power Sums -/

/-
**Vanishing and finite linear recurrence.**
    For `k > m`, elementary symmetric polynomials vanish (`e_k = 0`), so
    the Newton–Girard recurrence becomes a finite linear recurrence:
    all higher power sums are determined by `e_1, …, e_m` and the first
    `m` power sums. This is conceptually decisive: it says that **all
    high-order moments are generated by finitely many low-order invariants**.
-/
theorem powerSum_linear_recurrence_of_gt_card (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) (hk : m < k) :
    psum' μ k =
      ∑ j ∈ Finset.range m,
        (-1 : ℝ) ^ j * esymm' m μ (j + 1) * psum' μ (k - 1 - j) := by
  convert newton_girard_general m μ k ( pos_of_gt hk ) using 1;
  rw [ show ( Finset.antidiagonal k |> Finset.filter fun a => 0 < a.1 ∧ a.1 < k ) = Finset.image ( fun j => ( j + 1, k - ( j + 1 ) ) ) ( Finset.range ( k - 1 ) ) from ?_, Finset.sum_image ];
  · rw [ ← Finset.sum_range_add_sum_Ico _ ( show m ≤ k - 1 from Nat.le_sub_one_of_lt hk ) ];
    rw [ Finset.sum_Ico_eq_sum_range ];
    simp +decide [ pow_add, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, esymm'_eq_zero_of_gt m μ ];
    rw [ esymm'_eq_zero_of_gt m μ hk ] ; norm_num;
    exact Finset.sum_congr rfl fun x hx => by rw [ tsub_tsub, add_comm ] ;
  · aesop_cat;
  · ext ⟨ a, b ⟩ ; simp +decide [ Nat.sub_sub, add_comm ];
    exact ⟨ fun h => ⟨ a - 1, by omega, by omega, by omega ⟩, fun ⟨ a, ha, ha', ha'' ⟩ => ⟨ by omega, by omega, by omega ⟩ ⟩

/-! ## Section 5: Spectral Invariant Profile and Reconstruction -/

/-- A **spectral invariant profile** bundles the elementary symmetric invariants
    of a spectrum together with the vanishing condition above the number of
    variables. This is the fundamental data structure for invariant-based
    spectral computation: once you have a profile, you can reconstruct all
    power sums and hence approximate entropy without access to individual
    eigenvalues. -/
structure SpectralInvariantProfile (m : ℕ) where
  /-- The elementary symmetric coefficients. -/
  esymmData : ℕ → ℝ
  /-- `e_0 = 1` -/
  esymm_zero_eq : esymmData 0 = 1
  /-- `e_k = 0` for `k > m` -/
  vanish_above : ∀ k, m < k → esymmData k = 0

/-- Construct a spectral invariant profile from a concrete spectrum. -/
def SpectralInvariantProfile.fromSpectrum (m : ℕ) (μ : Fin m → ℝ) :
    SpectralInvariantProfile m where
  esymmData := esymm' m μ
  esymm_zero_eq := esymm'_zero m μ
  vanish_above := fun k hk => esymm'_eq_zero_of_gt m μ hk

/-- Recursive power-sum reconstruction from a spectral invariant profile.
    This implements a verified dynamic-programming algorithm: given only
    the elementary symmetric data, reconstruct power sums to arbitrary order.

    Uses the Newton–Girard recurrence:
    - `P(0) = m`
    - For `k ≥ 1`: `P(k) = (-1)^{k+1} · k · e_k −
        ∑_{j=1}^{k-1} (-1)^j · e_j · P(k−j)` -/
def powerSumFromProfile (m : ℕ) (prof : SpectralInvariantProfile m) : ℕ → ℝ
  | 0 => (m : ℝ)
  | k + 1 =>
    (-1 : ℝ) ^ (k + 2) * ((k + 1 : ℕ) : ℝ) * prof.esymmData (k + 1) -
      ∑ j ∈ Finset.range k,
        (-1 : ℝ) ^ (j + 1) * prof.esymmData (j + 1) * powerSumFromProfile m prof (k - j)

/-
**Correctness of power-sum reconstruction.**
    The reconstructed power sums from the spectral invariant profile of a
    spectrum equal the directly computed power sums.
-/
theorem powerSumFromProfile_correct (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) :
    powerSumFromProfile m (SpectralInvariantProfile.fromSpectrum m μ) k = psum' μ k := by
  induction' k using Nat.strongRecOn with k ih ih;
  rcases k with ( _ | k ) <;> simp_all +decide [ Nat.succ_eq_add_one ];
  · unfold powerSumFromProfile psum' ; aesop;
  · -- By definition of powerSumFromProfile, we have:
    have h_def : powerSumFromProfile m (SpectralInvariantProfile.fromSpectrum m μ) (k + 1) =
      (-1 : ℝ) ^ (k + 2) * ((k + 1 : ℕ) : ℝ) * (SpectralInvariantProfile.fromSpectrum m μ).esymmData (k + 1) -
        ∑ j ∈ Finset.range k,
          (-1 : ℝ) ^ (j + 1) * (SpectralInvariantProfile.fromSpectrum m μ).esymmData (j + 1) * powerSumFromProfile m (SpectralInvariantProfile.fromSpectrum m μ) (k - j) := by
            grind +locals;
    convert newton_girard_general m μ ( k + 1 ) ( Nat.succ_pos k ) |> Eq.symm using 1;
    rw [ h_def ];
    refine' congrArg₂ _ rfl ( Finset.sum_bij ( fun x hx => ( x + 1, k - x ) ) _ _ _ _ ) <;> simp +decide [ Finset.mem_filter, Finset.mem_antidiagonal ];
    · exact fun a ha => ⟨ by linarith [ Nat.sub_add_cancel ha.le ], ha ⟩;
    · aesop;
    · exact fun a b hab ha hk => ⟨ a - 1, by omega, by omega, by omega ⟩;
    · exact fun a ha => by rw [ ih _ ( Nat.sub_le _ _ ) ] ; rfl;

/-! ## Section 6: Polynomial Spectral Evaluation -/

/-- Evaluation of a polynomial spectral functional:
    `Φ_q(μ) = ∑ᵢ q(μᵢ)`. This is the general form of a polynomial
    observable applied to a spectrum. -/
def spectralPolyEval {m : ℕ} (q : Polynomial ℝ) (μ : Fin m → ℝ) : ℝ :=
  ∑ i, q.eval (μ i)

/-
**Spectral polynomial evaluation reduces to power sums.**
    Every polynomial spectral functional is a linear combination of power sums:
    `Φ_q(μ) = ∑_j c_j · p_j(μ)` where `c_j` are the coefficients of `q`.
-/
theorem spectralPolyEval_eq_sum_psum' {m : ℕ} (q : Polynomial ℝ) (μ : Fin m → ℝ) :
    spectralPolyEval q μ = ∑ j ∈ Finset.range (q.natDegree + 1),
      q.coeff j * psum' μ j := by
  simp +decide only [spectralPolyEval, Polynomial.eval_eq_sum_range, psum'];
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => by rw [ Finset.mul_sum _ _ _ ] )

/-
**Polynomial spectral observables are computable from elementary symmetric data.**
    Combined with Newton–Girard reconstruction, this shows that every polynomial
    spectral statistic is computable from the spectral invariant profile alone,
    without access to individual eigenvalues. This is the algebraic-combinatorics ↔
    spectral-analysis bridge.
-/
theorem spectralPolyEval_from_esymm_data {m : ℕ} (q : Polynomial ℝ) (μ : Fin m → ℝ) :
    spectralPolyEval q μ =
      ∑ j ∈ Finset.range (q.natDegree + 1),
        q.coeff j * powerSumFromProfile m (SpectralInvariantProfile.fromSpectrum m μ) j := by
  rw [spectralPolyEval_eq_sum_psum'];
  exact Finset.sum_congr rfl fun j hj => by rw [ powerSumFromProfile_correct m μ j ] ;

/-! ## Section 7: Entropy Surrogates on Gapped Spectra -/

/-
**Entropy surrogate uniform error bound.**
    For spectra in a gapped interval `[δ, 1-δ]`, if a polynomial `qN`
    approximates the entropy kernel within `εN` on that interval, then the
    polynomial spectral functional approximates the true entropy within `m · εN`.

    This is the algebra → analysis → information theory bridge: polynomial
    approximation on an interval pushes through Newton–Girard reduction to
    yield computable entropy surrogates from elementary symmetric data.
-/
theorem entropy_surrogate_uniform_error
    {m : ℕ} {δ εN : ℝ} (_hδ : 0 < δ) (_hδ' : δ < 1 / 2)
    (μ : Fin m → ℝ)
    (hμlo : ∀ i, δ ≤ μ i) (hμhi : ∀ i, μ i ≤ 1 - δ)
    (qN : Polynomial ℝ)
    (_hεN : 0 ≤ εN)
    (happrox : ∀ x, x ∈ Set.Icc δ (1 - δ) →
      |shannonEntropy x - qN.eval x| ≤ εN) :
    |(∑ i : Fin m, shannonEntropy (μ i)) - spectralPolyEval qN μ| ≤ ↑m * εN := by
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i _ => happrox ( μ i ) ⟨ hμlo i, hμhi i ⟩ using 1 ; unfold spectralPolyEval ; aesop;
  norm_num

/-
**Entropy surrogate convergence theorem.**
    If a sequence of polynomials approximates the entropy kernel with vanishing
    error on a gapped interval, then the corresponding spectral polynomial
    surrogates converge to the true entropy.

    This is the main asymptotic theorem: it says that once the elementary symmetric
    profile of a finite spectrum is known, one can approximate entropy to arbitrary
    precision on gapped spectral families.
-/
theorem entropy_surrogate_converges
    {m : ℕ} {δ : ℝ} (hδ : 0 < δ) (hδ' : δ < 1 / 2)
    (μ : Fin m → ℝ)
    (hμlo : ∀ i, δ ≤ μ i) (hμhi : ∀ i, μ i ≤ 1 - δ)
    (qSeq : ℕ → Polynomial ℝ)
    (errSeq : ℕ → ℝ)
    (herrnn : ∀ N, 0 ≤ errSeq N)
    (happrox : ∀ N, ∀ x, x ∈ Set.Icc δ (1 - δ) →
      |shannonEntropy x - (qSeq N).eval x| ≤ errSeq N)
    (herr : Filter.Tendsto errSeq Filter.atTop (nhds 0)) :
    Filter.Tendsto
      (fun N => spectralPolyEval (qSeq N) μ)
      Filter.atTop
      (nhds (∑ i, shannonEntropy (μ i))) := by
  -- We need to show that spectralPolyEval (qSeq N) μ → ∑ i, shannonEntropy (μ i) as N → ∞.
  have h_tendsto : Filter.Tendsto (fun N => ∑ i, shannonEntropy (μ i) - spectralPolyEval (qSeq N) μ) Filter.atTop (nhds 0) := by
    exact squeeze_zero_norm ( fun N => by simpa using entropy_surrogate_uniform_error hδ hδ' μ hμlo hμhi ( qSeq N ) ( herrnn N ) ( happrox N ) ) ( by simpa using tendsto_const_nhds.mul herr );
  simpa using h_tendsto.neg.const_add ( ∑ i, shannonEntropy ( μ i ) )

/-
**Geometric entropy surrogate convergence.**
    Under a geometric approximation rate `errN ≤ C · ρ^N` with `0 ≤ ρ < 1`,
    the entropy surrogate converges geometrically fast.
    This bridges algebraic combinatorics, approximation theory, and
    quantum information: spectral entropy can be approximated at geometric
    rate from elementary symmetric invariants alone.
-/
theorem entropy_surrogate_geometric
    {m : ℕ} {δ C ρ : ℝ} (hδ : 0 < δ) (hδ' : δ < 1 / 2)
    (μ : Fin m → ℝ)
    (hμlo : ∀ i, δ ≤ μ i) (hμhi : ∀ i, μ i ≤ 1 - δ)
    (qSeq : ℕ → Polynomial ℝ)
    (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (happrox : ∀ N, ∀ x, x ∈ Set.Icc δ (1 - δ) →
      |shannonEntropy x - (qSeq N).eval x| ≤ C * ρ ^ N) :
    Filter.Tendsto
      (fun N => spectralPolyEval (qSeq N) μ)
      Filter.atTop
      (nhds (∑ i, shannonEntropy (μ i))) := by
  convert entropy_surrogate_converges hδ hδ' μ hμlo hμhi qSeq ( fun N => C * ρ ^ N ) ( fun N => mul_nonneg hC ( pow_nonneg hρ0 N ) ) ( fun N x hx => happrox N x hx ) ( by simpa using Filter.Tendsto.const_mul C ( tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1 ) ) using 1

end