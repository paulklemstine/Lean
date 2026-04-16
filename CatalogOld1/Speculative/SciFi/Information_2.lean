/-
  Mathematics of Science Fiction — Chapter 4: The Limits of Alien Communication
  Shannon entropy bounds, information-theoretic inequalities.
  Author: Paul Klemstine | Soli Deo Gloria
-/
import Mathlib

open Real BigOperators

noncomputable section

/-! ## Shannon Entropy

  H(X) = -∑ p(x) log₂ p(x) is the minimum average bits to encode one sample. -/

/-- Shannon entropy of a finite probability distribution. -/
def shannonEntropy {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  -∑ i, p i * Real.log (p i) / Real.log 2

/-
Entropy is non-negative for valid probability distributions.
-/
theorem shannonEntropy_nonneg {n : ℕ} (p : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ p i) (h_le_one : ∀ i, p i ≤ 1)
    (h_sum : ∑ i, p i = 1) :
    0 ≤ shannonEntropy p := by
  refine' neg_nonneg.mpr _;
  exact Finset.sum_nonpos fun i _ => div_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonneg_of_nonpos ( h_nonneg i ) ( Real.log_nonpos ( h_nonneg i ) ( h_le_one i ) ) ) ( Real.log_nonneg ( by norm_num ) )

/-
Maximum entropy is achieved by the uniform distribution: H ≤ log₂ n.
-/
theorem shannonEntropy_le_log {n : ℕ} (hn : 0 < n) (p : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ p i)
    (h_sum : ∑ i, p i = 1) :
    shannonEntropy p ≤ Real.log n / Real.log 2 := by
  by_cases hn2 : 2 < n <;> simp_all +decide [ div_eq_inv_mul ];
  · -- Applying Jensen's inequality for the concave function $f(x) = x \log x$
    have h_jensen : ∑ i, p i * Real.log (p i) ≥ (∑ i, p i) * Real.log (∑ i, p i / n) := by
      have h_jensen : ∀ (q : Fin n → ℝ), (∀ i, 0 ≤ q i) → (∑ i, q i = 1) → (∑ i, q i * Real.log (q i)) ≥ (∑ i, q i) * Real.log (∑ i, q i / n) := by
        intros q hq_nonneg hq_sum
        have h_jensen : (∑ i, (1 / n : ℝ) * (q i * Real.log (q i))) ≥ (∑ i, (1 / n : ℝ) * q i) * Real.log (∑ i, (1 / n : ℝ) * q i) := by
          have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
            exact ( Real.convexOn_mul_log );
          apply ConvexOn.map_sum_le h_jensen;
          · exact fun _ _ => by positivity;
          · simp +decide [ hn.ne' ];
          · grind +splitImp;
        simp_all +decide [ div_eq_inv_mul, ← Finset.mul_sum _ _ _ ];
        nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ];
      exact h_jensen p h_nonneg h_sum;
    simp_all +decide [ ← Finset.sum_div _ _ _ ];
    unfold shannonEntropy;
    rw [ ← Finset.sum_div _ _ _ ] ; ring_nf at *; nlinarith [ inv_pos.mpr ( Real.log_pos one_lt_two ), mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos one_lt_two ) ) ] ;
  · interval_cases n <;> norm_num [ Fin.sum_univ_succ ] at *;
    · unfold shannonEntropy; aesop;
    · unfold shannonEntropy;
      rcases eq_or_lt_of_le h_nonneg.1 with ha | ha <;> rcases eq_or_lt_of_le h_nonneg.2 with hb | hb <;> norm_num at *;
      · linarith;
      · norm_num [ show p 1 = 1 by linarith, ha.symm ];
      · norm_num [ ← hb ] at *;
        norm_num [ h_sum ];
      · field_simp;
        have := @Real.geom_mean_le_arith_mean;
        specialize this { 0, 1 } ( fun i => if i = 0 then p 0 else p 1 ) ( fun i => if i = 0 then ( p 0 ) ⁻¹ else ( p 1 ) ⁻¹ ) ; norm_num at *;
        norm_num [ ha.ne', hb.ne', h_sum ] at this;
        have := Real.log_le_log ( by positivity ) ( this h_nonneg.1 h_nonneg.2 h_nonneg.1 h_nonneg.2 ) ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_rpow ( by positivity ), Real.log_rpow ( by positivity ) ] at this ; norm_num at * ; nlinarith [ inv_mul_cancel₀ ( ne_of_gt ha ), inv_mul_cancel₀ ( ne_of_gt hb ), Real.log_inv ( p 0 ), Real.log_inv ( p 1 ) ] ;

/-! ## Channel Capacity and Interstellar Communication

  The capacity of a Gaussian channel: C = W log₂(1 + SNR). -/

/-- Gaussian channel capacity function. -/
def gaussianCapacity (W SNR : ℝ) : ℝ :=
  W * Real.log (1 + SNR) / Real.log 2

/-
Channel capacity is non-negative when bandwidth and SNR are non-negative.
-/
theorem gaussianCapacity_nonneg (W SNR : ℝ) (hW : 0 ≤ W) (hSNR : 0 ≤ SNR) :
    0 ≤ gaussianCapacity W SNR := by
  exact div_nonneg ( mul_nonneg hW ( Real.log_nonneg ( by linarith ) ) ) ( Real.log_nonneg ( by norm_num ) )

/-
Channel capacity is monotone increasing in SNR for non-negative SNR and positive W.
-/
theorem gaussianCapacity_mono_SNR (W : ℝ) (hW : 0 < W) {a b : ℝ}
    (ha : 0 ≤ a) (hab : a ≤ b) :
    gaussianCapacity W a ≤ gaussianCapacity W b := by
  unfold gaussianCapacity; gcongr

/-! ## Kolmogorov Complexity Invariance

  |K_U₁(x) - K_U₂(x)| ≤ c for some constant c. -/

/-- Abstract invariance theorem: two complexity measures agree up to a constant. -/
theorem kolmogorov_invariance {X : Type*} (K₁ K₂ : X → ℕ)
    (c : ℕ) (h : ∀ x, K₁ x ≤ K₂ x + c) (h' : ∀ x, K₂ x ≤ K₁ x + c)
    (x : X) : (K₁ x : ℤ) - (K₂ x : ℤ) ≤ c ∧ (K₂ x : ℤ) - (K₁ x : ℤ) ≤ c := by
  constructor <;> { have := h x; have := h' x; omega }

end