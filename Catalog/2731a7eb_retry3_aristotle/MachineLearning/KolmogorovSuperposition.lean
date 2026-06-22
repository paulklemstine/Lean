import Mathlib

open scoped NNReal

/-!
# Lipschitz constant for a finite Kolmogorov-type superposition

This file establishes that a finite Kolmogorov-type superposition
`x ↦ ∑ q, Φ q (∑ p, φ q p (x p))` on `Fin n → ℝ` is Lipschitz, with an
explicit Lipschitz constant assembled from the Lipschitz constants of the
inner functions `φ q p` and the outer functions `Φ q`.
-/

variable {n m : ℕ}

/-- A finite sum of Lipschitz functions is Lipschitz, with constant the sum of
the individual Lipschitz constants. -/
theorem lipschitzWith_finset_sum {ι α β : Type*} [PseudoEMetricSpace α]
    [SeminormedAddCommGroup β] (s : Finset ι) (f : ι → α → β) (K : ι → ℝ≥0)
    (hf : ∀ i ∈ s, LipschitzWith (K i) (f i)) :
    LipschitzWith (∑ i ∈ s, K i) (fun x => ∑ i ∈ s, f i x) := by
  classical
  induction s using Finset.induction with
  | empty =>
      simpa using (LipschitzWith.const' (0 : β))
  | insert a s ha ih =>
      simp only [Finset.sum_insert ha]
      exact (hf a (Finset.mem_insert_self a s)).add
        (ih (fun i hi => hf i (Finset.mem_insert_of_mem hi)))

/-- The inner sum `x ↦ ∑ p, φ q p (x p)` of the `q`-th superposition term. -/
def innerSum (φ : Fin m → Fin n → ℝ → ℝ) (q : Fin m) : (Fin n → ℝ) → ℝ :=
  fun x => ∑ p, φ q p (x p)

/-- The inner sum is Lipschitz, with constant the sum of the inner Lipschitz
constants over the coordinates `p`. -/
theorem innerSum_lipschitz (φ : Fin m → Fin n → ℝ → ℝ)
    (Kφ : Fin m → Fin n → ℝ≥0)
    (hφ : ∀ q p, LipschitzWith (Kφ q p) (φ q p)) (q : Fin m) :
    LipschitzWith (∑ p, Kφ q p) (innerSum φ q) := by
  classical
  have := lipschitzWith_finset_sum (Finset.univ : Finset (Fin n))
    (fun p (x : Fin n → ℝ) => φ q p (x p)) (fun p => Kφ q p)
    (fun p _ => by
      have he : LipschitzWith 1 (fun x : Fin n → ℝ => x p) := by
        simpa using LipschitzWith.eval p
      simpa [Function.comp_def, mul_one] using (hφ q p).comp he)
  simpa [innerSum] using this

/-- The full finite Kolmogorov-type superposition
`x ↦ ∑ q, Φ q (∑ p, φ q p (x p))`. -/
def kolmogorovSuperposition (φ : Fin m → Fin n → ℝ → ℝ) (Φ : Fin m → ℝ → ℝ) :
    (Fin n → ℝ) → ℝ :=
  fun x => ∑ q, Φ q (∑ p, φ q p (x p))

/-- The Kolmogorov-type superposition is Lipschitz with the explicit constant
`∑ q, KΦ q * (∑ p, Kφ q p)`. -/
theorem kolmogorovSuperposition_lipschitz
    (φ : Fin m → Fin n → ℝ → ℝ) (Φ : Fin m → ℝ → ℝ)
    (Kφ : Fin m → Fin n → ℝ≥0) (KΦ : Fin m → ℝ≥0)
    (hφ : ∀ q p, LipschitzWith (Kφ q p) (φ q p))
    (hΦ : ∀ q, LipschitzWith (KΦ q) (Φ q)) :
    LipschitzWith (∑ q, KΦ q * (∑ p, Kφ q p))
      (kolmogorovSuperposition φ Φ) := by
  classical
  have := lipschitzWith_finset_sum (Finset.univ : Finset (Fin m))
    (fun q (x : Fin n → ℝ) => Φ q (∑ p, φ q p (x p)))
    (fun q => KΦ q * (∑ p, Kφ q p))
    (fun q _ => by
      simpa [innerSum, Function.comp_def] using
        (hΦ q).comp (innerSum_lipschitz φ Kφ hφ q))
  simpa [kolmogorovSuperposition] using this