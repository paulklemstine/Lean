import Mathlib

/-!
# Coherence Theory — Formal Foundations

We formalize the basic definitions and properties of the coherence measure
for Boolean functions, defined via Fourier analysis on the Boolean hypercube.

## Main Definitions

- `SpectralEntropy`: The Shannon entropy of the squared Fourier coefficients
- `coherence`: The coherence measure C(f) = 1 - H(spectral distribution) / n

## Main Results

- `coherence_nonneg`: Coherence is nonneg (C ≥ 0)
- `coherence_le_one`: Coherence is at most 1
- `coherence_add_landscape_eq_one`: The duality identity C + L = 1
-/

open Finset BigOperators

noncomputable section

/-- Shannon entropy of a finite probability distribution. -/
def shannonEntropy (p : Fin k → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) : ℝ :=
  -∑ i, p i * Real.log (p i)

/-- The spectral landscape entropy L(f) = H(spectral distribution) / n,
    normalized to [0, 1]. For our formalization, we define it abstractly. -/
def landscapeEntropy (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  H_spectral / n

/-- The coherence C(f) = 1 - H(spectral distribution) / n. -/
def coherenceMeasure (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  1 - H_spectral / n

/-
PROBLEM
The definitional duality: C(f) + L(f) = 1.

PROVIDED SOLUTION
Unfold the definitions of coherenceMeasure and landscapeEntropy, then show (1 - H/n) + H/n = 1 by ring.
-/
theorem coherence_add_landscape_eq_one (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) :
    coherenceMeasure H_spectral n hn + landscapeEntropy H_spectral n hn = 1 := by
  -- By definition of coherenceMeasure and landscapeEntropy, we have:
  simp [coherenceMeasure, landscapeEntropy]

/-
PROBLEM
Shannon entropy is nonneg for probability distributions.

PROVIDED SOLUTION
Shannon entropy is nonneg because each term -p_i * log(p_i) is nonneg when 0 ≤ p_i ≤ 1 (since log(p_i) ≤ 0). The whole sum is the negation of a sum of nonpositive terms. Use Finset.sum_nonneg and show each -p_i * log(p_i) ≥ 0.
-/
theorem shannonEntropy_nonneg (p : Fin k → ℝ) (hp : ∀ i, 0 ≤ p i) (hp1 : ∀ i, p i ≤ 1)
    (hsum : ∑ i, p i = 1) : 0 ≤ shannonEntropy p hp hsum := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i _ => mul_nonpos_of_nonneg_of_nonpos ( hp i ) ( Real.log_nonpos ( hp i ) ( hp1 i ) ) )

/-
PROBLEM
Shannon entropy is at most log(k) for distributions over k elements.

PROVIDED SOLUTION
This is the well-known fact that Shannon entropy is maximized by the uniform distribution. For k outcomes, H ≤ log k. This is a consequence of Jensen's inequality applied to the concave function -x log x. Try using simp and unfold shannonEntropy, then use standard Mathlib inequalities about log and sums.
-/
theorem shannonEntropy_le_log (p : Fin k → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (hk : 0 < k) :
    shannonEntropy p hp hsum ≤ Real.log k := by
  unfold shannonEntropy;
  -- Apply Jensen's inequality for the concave function $f(x) = x \log x$.
  have h_jensen : (∑ i, (1 / k : ℝ) * (p i * Real.log (p i))) ≥ ((∑ i, (1 / k : ℝ) * p i) * Real.log (∑ i, (1 / k : ℝ) * p i)) := by
    -- The function $f(x) = x \log x$ is convex on $[0, \infty)$.
    have h_convex : ConvexOn ℝ (Set.Ici 0) (fun x : ℝ => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    apply ConvexOn.map_sum_le h_convex;
    · aesop;
    · simp +decide [ hk.ne' ];
    · aesop;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  nlinarith [ inv_mul_cancel_left₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ( Real.log k ), inv_mul_cancel₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ]

/-
PROBLEM
Coherence is nonneg when spectral entropy is at most n.

PROVIDED SOLUTION
Unfold coherenceMeasure to get 0 ≤ 1 - H/n, which follows from H ≤ n and n > 0, so H/n ≤ 1.
-/
theorem coherence_nonneg (H_spectral : ℝ) (n : ℕ) (hn : 0 < n)
    (hH : H_spectral ≤ n) : 0 ≤ coherenceMeasure H_spectral n hn := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ hH <| Nat.cast_nonneg _ )

/-
PROBLEM
Coherence is at most 1 when spectral entropy is nonneg.

PROVIDED SOLUTION
Unfold coherenceMeasure to get 1 - H/n ≤ 1, which follows from 0 ≤ H and n > 0, so 0 ≤ H/n, hence 1 - H/n ≤ 1.
-/
theorem coherence_le_one (H_spectral : ℝ) (n : ℕ) (hn : 0 < n)
    (hH : 0 ≤ H_spectral) : coherenceMeasure H_spectral n hn ≤ 1 := by
  exact sub_le_self _ ( by positivity )

end