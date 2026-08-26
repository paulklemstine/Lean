import Mathlib
import Bridges.NeuralCoding.MaxPlusDefs
import Bridges.NeuralCoding.MaxPlusLemmas
import Bridges.TropicalAlgebra.EigenvectorIteration
import Speculative.AutoResearch.TropicalPerronCore

/-!
# Tropical Perron-Frobenius Theorem

We prove the existence of max-plus eigenvectors for finite matrices over `ℝ`.

## Main results

* `exists_eigenvector_dim1` - eigenvector for 1×1 matrices
* `exists_eigenvector_dim2` - eigenvector for 2×2 matrices (via IVT)
* `exists_maxPlusMul_eigenvector` - general eigenvector existence (uses compactness)
* `bounded_defect_growth_conditional` - spectral growth given an eigenvector

## Proof strategy for 2×2 case

For a 2×2 matrix, parameterize `v = (0, t)` and define:
- `φ(t) = max(M₀₀, M₀₁ + t) - max(M₁₀ - t, M₁₁)`

Show `φ` is continuous, goes from negative to positive, and apply IVT.
-/

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ### 1×1 eigenvector -/

/-- In the 1×1 case, `μ = M 0 0` and `v = [0]`. -/
theorem exists_eigenvector_dim1
    (M : Matrix (Fin 1) (Fin 1) ℝ) :
    ∃ (mu : ℝ) (v : Fin 1 → ℝ),
      (∀ i, maxPlusMul M v (by omega) i = mu + v i) := by
  simp +decide [ maxPlusMul ]

/-! ### 2×2 eigenvector via IVT -/

/-- The "balance function" for the 2×2 case, parameterized by `t = v₁ - v₀`.
    `φ(t) = max(M₀₀, M₀₁ + t) - max(M₁₀ - t, M₁₁)`. -/
def phi2 (M : Matrix (Fin 2) (Fin 2) ℝ) (t : ℝ) : ℝ :=
  max (M 0 0) (M 0 1 + t) - max (M 1 0 - t) (M 1 1)

/-- `phi2` is continuous (composition of continuous max, add, sub). -/
theorem phi2_continuous (M : Matrix (Fin 2) (Fin 2) ℝ) :
    Continuous (phi2 M) :=
  Continuous.sub (Continuous.max continuous_const (continuous_const.add continuous_id'))
    (Continuous.max (continuous_const.sub continuous_id') continuous_const)

/-- `phi2` is negative for sufficiently negative `t`. -/
theorem phi2_neg_at_low (M : Matrix (Fin 2) (Fin 2) ℝ) :
    ∃ t₀ : ℝ, phi2 M t₀ < 0 := by
  unfold phi2
  exact ⟨-2 - |M 0 0| - |M 1 0| - |M 1 1| - |M 0 1|, by
    cases max_cases (M 0 0) (M 0 1 + (-2 - |M 0 0| - |M 1 0| - |M 1 1| - |M 0 1|)) <;>
    cases max_cases (M 1 0 - (-2 - |M 0 0| - |M 1 0| - |M 1 1| - |M 0 1|)) (M 1 1) <;>
    cases abs_cases (M 0 0) <;> cases abs_cases (M 1 0) <;>
    cases abs_cases (M 1 1) <;> cases abs_cases (M 0 1) <;> linarith⟩

/-- `phi2` is positive for sufficiently positive `t`. -/
theorem phi2_pos_at_high (M : Matrix (Fin 2) (Fin 2) ℝ) :
    ∃ t₁ : ℝ, 0 < phi2 M t₁ := by
  set t₁ : ℝ := abs (M 0 0) + abs (M 0 1) + abs (M 1 0) + abs (M 1 1) + 1
  use t₁
  unfold phi2
  grind

/-- **2×2 Tropical Perron theorem**: For any 2×2 real matrix,
    there exists an eigenvector.

    Proof uses the intermediate value theorem: the balance function `φ`
    is continuous, negative for very negative `t`, and positive for
    very positive `t`, so it has a zero by IVT. -/
theorem exists_eigenvector_dim2
    (M : Matrix (Fin 2) (Fin 2) ℝ) :
    ∃ (mu : ℝ) (v : Fin 2 → ℝ),
      (∀ i, maxPlusMul M v (by omega) i = mu + v i) := by
  obtain ⟨t₀, ht₀⟩ : ∃ t₀ : ℝ, phi2 M t₀ = 0 := by
    obtain ⟨t₁, ht₁⟩ : ∃ t₁ : ℝ, 0 < phi2 M t₁ := phi2_pos_at_high M
    obtain ⟨t₀, ht₀⟩ : ∃ t₀ : ℝ, phi2 M t₀ < 0 := phi2_neg_at_low M
    have h_ivt : IsConnected (Set.range (phi2 M)) :=
      isConnected_range (phi2_continuous M)
    exact h_ivt.Icc_subset (Set.mem_range_self t₀) (Set.mem_range_self t₁) ⟨ht₀.le, ht₁.le⟩
  unfold phi2 at ht₀; norm_num [Fin.forall_fin_two, maxPlusMul] at *
  refine' ⟨max (M 0 0) (M 0 1 + t₀), fun i => if i = 0 then 0 else t₀, _, _⟩ <;>
    simp +decide [Fin.univ_succ]
  grind

/-! ### General eigenvector existence -/

/-- **Tropical Perron-Frobenius Theorem (general case)**:
    For any `n × n` matrix over `ℝ` with `n > 0`, there exist `μ` and `v`
    satisfying the max-plus eigenvector equation `(M ⊗ v)ᵢ = μ + vᵢ`.

    The proof is the Cuninghame-Green construction, carried out in
    `Speculative.AutoResearch.TropicalPerronCore`: `μ` is the maximal cycle mean
    `lam hn M`, and `v i` is the largest shifted weight `Wt l i i₀ - l · μ` of a walk
    of length `l ≤ n` from `i` to a critical node `i₀`.  Cycle removal (pigeonhole
    on a walk longer than `n`, together with the fact that every cycle has mean at
    most `μ`) shows this potential satisfies the eigenvector equation exactly. -/
theorem exists_maxPlusMul_eigenvector (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (mu : ℝ) (v : Fin n → ℝ),
      (∀ i, maxPlusMul M v hn i = mu + v i) := by
  obtain ⟨v, hv⟩ := TropPerron.exists_eigen_potential hn M
  exact ⟨TropPerron.lam hn M, v, fun i => hv i⟩

/-! ### Conditional bounded defect growth

We prove that if an eigenvector exists, the sup of the k-th iterate
grows linearly with slope `μ`, establishing the spectral growth property.
-/

/-- **Conditional bounded defect growth**: Given an eigenvector `v` with
    eigenvalue `μ`, the sup of the k-th iterate equals `k·μ + sup v`. -/
theorem iterate_growth_exact (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (mu : ℝ)
    (hv : ∀ i, maxPlusMul M v hn i = mu + v i) (k : ℕ) :
    Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (iterMaxPlusMul hn M k v) =
      k * mu + Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) v :=
  iterate_max_eq hn M v mu hv k

/-
The inf of the k-th iterate also shifts by `k·μ`.
-/
theorem iterate_min_exact (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (mu : ℝ)
    (hv : ∀ i, maxPlusMul M v hn i = mu + v i) (k : ℕ) :
    Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (iterMaxPlusMul hn M k v) =
      k * mu + Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) v := by
  refine' le_antisymm _ _;
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) v;
    exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ i ) ) ( by rw [ hi.2, eigenvector_iterate hn M v mu hv k i ] );
  · have := eigenvector_iterate hn M v mu hv k; aesop;

end