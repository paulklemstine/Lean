import Mathlib
import Computation.EastinKnillLie

/-!
# Approximate Eastin–Knill and the covariance–error tradeoff

The exact Eastin–Knill theorem (`Computation.EastinKnillLie`) is a *rigid* statement: a
transversal generator that is exactly detectable produces exactly a phase.  Physically one
wants the *stable* version: if detectability holds only up to an error `δ`, how far from a
phase can the generated logical gate be?  The answer proved here is that the deviation is
**Lipschitz in `δ`**, with the explicit constant `e^M` where `M` bounds the generator:

  `‖exp (t a) p − e^{t c} p‖ ≤ |t| δ · e^{max (‖t a‖, |t c|)}`.

Two consequences make this more than a technical refinement.

* **No-go is stable.**  Approximate transversality cannot buy universality: a gate that is
  `Δ`-far from every phase forces `δ ≥ Δ e^{-M} / |t|` (`eastin_knill_error_lower_bound`).
* **The `1/n` covariance–error tradeoff.**  For a transversal generator on `n` sites with
  per-site detection error `δ`, the total error is `n δ` (detection errors add, exactly as
  the detection scalars do).  Hence implementing a gate `Δ`-far from a phase requires

  `δ ≥ Δ e^{-M} / (n |t|)`   (`eastin_knill_covariance_tradeoff`),

  i.e. the per-site error can only be reduced by *spreading the code over more sites* —
  the quantitative version of "you can approximate universality, but the accuracy is
  limited by the code size".

## Main results

* `norm_pow_sub_smul_le` — the `k`-th power of an approximate eigenvector equation costs
  at most `k M^{k-1} δ`; the linear-in-`δ`, polynomial-in-`k` growth is what makes the
  exponential series converge.
* `norm_exp_sub_smul_le` — the Banach-algebra approximate exponentiation bound.
* `approx_eastin_knill` — the QEC statement.
* `approx_eastin_knill_exact` — consistency: at `δ = 0` it reproduces the exact theorem.
* `eastin_knill_error_lower_bound`, `eastin_knill_covariance_tradeoff` — the tradeoff.

-- !-- Lab Notebook -- !--
-- Hypothesis:  Eastin–Knill should be *stable*: the map (detection error) ↦ (distance of
--   the logical gate from a phase) should be Lipschitz, not merely continuous, and the
--   Lipschitz constant should be computable from the generator norm alone.
-- Experiment 1:  Propagate the approximate eigenvalue equation through powers.  The
--   telescoping identity `aᵏ⁺¹p − cᵏ⁺¹p = a(aᵏp − cᵏp) + cᵏ(ap − cp)` gives the recursion
--   `εₖ₊₁ ≤ ‖a‖ εₖ + |c|ᵏ δ`, hence `εₖ ≤ k Mᵏ⁻¹ δ`.  CONFIRMED; note the bound is *tight*
--   in the commutative case `a = c + δ`, where `εₖ = |(c+δ)ᵏ − cᵏ| ≈ k cᵏ⁻¹ δ`.
-- Experiment 2:  Sum the series.  `∑ₖ k Mᵏ⁻¹ δ / k! = δ e^M` exactly (after reindexing
--   `k/k! = 1/(k−1)!`), so no slack is lost in the summation.  The final constant `e^M`
--   is therefore the honest one, not an artefact.
-- Experiment 3 (failed first attempt, kept as data):  bounding `εₖ ≤ k Mᵏ δ` instead
--   (avoiding the truncated subtraction `k−1`) breaks the induction whenever `M < 1`,
--   which is precisely the physically interesting regime of small generators.  The
--   truncated exponent is not cosmetic.
-- Insight:  Detection errors are additive over sites for exactly the same reason that
--   detection *scalars* are additive (`Detectable.sum` in the base catalog file): the
--   triangle inequality applied to a sum of single-site terms.  The `1/n` tradeoff is the
--   shadow of that additivity.
-/

open NormedSpace

namespace EastinKnill

/-! ## Banach-algebra estimates -/

section BanachAlgebra

variable {A : Type*} [NormedRing A] [NormedAlgebra ℂ A]

/-- **Powers of an approximate eigenvector equation.**  If `a p` differs from `c p` by at
most `δ`, then `aᵏ p` differs from `cᵏ p` by at most `k Mᵏ⁻¹ δ`, where `M` bounds both
`‖a‖` and `|c|`.  The growth is linear in the error and only polynomial in `k`. -/
theorem norm_pow_sub_smul_le {a p : A} {c : ℂ} {δ : ℝ} (hδ : ‖a * p - c • p‖ ≤ δ) (k : ℕ) :
    ‖a ^ k * p - c ^ k • p‖ ≤ k * (max ‖a‖ ‖c‖) ^ (k - 1) * δ := by
  set M := max ‖a‖ ‖c‖ with hM
  have hM0 : 0 ≤ M := le_trans (norm_nonneg a) (le_max_left _ _)
  have hδ0 : 0 ≤ δ := le_trans (norm_nonneg _) hδ
  induction k with
  | zero => simp
  | succ k ih =>
      have key : a ^ (k + 1) * p - c ^ (k + 1) • p
          = a * (a ^ k * p - c ^ k • p) + c ^ k • (a * p - c • p) := by
        have h1 : a * (c ^ k • p) = c ^ k • (a * p) := mul_smul_comm _ _ _
        have h2 : a ^ k * a = a * a ^ k := (Commute.pow_self a k).eq
        rw [mul_sub, smul_sub, h1, pow_succ, pow_succ, smul_smul, ← mul_assoc, h2]
        abel
      rw [key]
      have h1 : ‖a * (a ^ k * p - c ^ k • p)‖ ≤ ‖a‖ * ((k : ℝ) * M ^ (k - 1) * δ) :=
        le_trans (norm_mul_le _ _) (mul_le_mul_of_nonneg_left ih (norm_nonneg a))
      have h2 : ‖c ^ k • (a * p - c • p)‖ ≤ ‖c‖ ^ k * δ := by
        rw [norm_smul, norm_pow]
        exact mul_le_mul_of_nonneg_left hδ (by positivity)
      refine (le_trans (norm_add_le _ _) (add_le_add h1 h2)).trans ?_
      cases k with
      | zero => simp
      | succ j =>
          have hak : ‖a‖ ≤ M := le_max_left _ _
          have hck : ‖c‖ ≤ M := le_max_right _ _
          have e1 : ‖a‖ * ((j + 1 : ℕ) * M ^ (j + 1 - 1) * δ)
              ≤ M * ((j + 1 : ℝ) * M ^ j * δ) := by
            push_cast
            exact mul_le_mul_of_nonneg_right hak (by positivity)
          have e2 : ‖c‖ ^ (j + 1) * δ ≤ M ^ (j + 1) * δ :=
            mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (norm_nonneg c) hck _) hδ0
          calc ‖a‖ * ((j + 1 : ℕ) * M ^ (j + 1 - 1) * δ) + ‖c‖ ^ (j + 1) * δ
              ≤ M * ((j + 1 : ℝ) * M ^ j * δ) + M ^ (j + 1) * δ := add_le_add e1 e2
          _ = ((j + 1 + 1 : ℕ) : ℝ) * M ^ (j + 1 + 1 - 1) * δ := by push_cast; ring

/-- The majorant series `∑ k Mᵏ⁻¹ δ / k!` sums to exactly `δ e^M`: reindexing
`k / k! = 1 / (k-1)!` turns it into the exponential series, so the estimate below loses
nothing in the summation. -/
theorem expMajorant_hasSum (M δ : ℝ) :
    HasSum (fun k : ℕ => (k.factorial : ℝ)⁻¹ * k * M ^ (k - 1) * δ) (δ * Real.exp M) := by
  have hv : HasSum (fun n : ℕ => δ * (M ^ n / n.factorial)) (δ * Real.exp M) := by
    have h := expSeries_div_hasSum_exp (𝔸 := ℝ) M
    rw [← Real.exp_eq_exp_ℝ] at h
    exact h.mul_left δ
  have h2 : HasSum
      (fun n : ℕ => (((n + 1).factorial : ℝ))⁻¹ * ((n + 1 : ℕ) : ℝ) * M ^ (n + 1 - 1) * δ)
      (δ * Real.exp M) := by
    refine hv.congr_fun ?_
    intro n
    simp only [Nat.add_sub_cancel, Nat.factorial_succ]
    push_cast
    field_simp
  have := (hasSum_nat_add_iff
    (f := fun k : ℕ => (k.factorial : ℝ)⁻¹ * k * M ^ (k - 1) * δ) 1).mp h2
  simpa using this

variable [CompleteSpace A]

/-- **Approximate exponentiation.**  An approximate right-eigenvector equation
`‖a p − c p‖ ≤ δ` is inherited by the one-parameter group it generates, with the explicit
Lipschitz constant `e^M`:  `‖exp a · p − e^c · p‖ ≤ δ e^M`. -/
theorem norm_exp_sub_smul_le {a p : A} {c : ℂ} {δ : ℝ} (hδ : ‖a * p - c • p‖ ≤ δ) :
    ‖exp a * p - Complex.exp c • p‖ ≤ δ * Real.exp (max ‖a‖ ‖c‖) := by
  set M := max ‖a‖ ‖c‖ with hM
  set w : ℕ → A := fun k => (k.factorial : ℂ)⁻¹ • (a ^ k * p - c ^ k • p) with hw
  set u : ℕ → ℝ := fun k => (k.factorial : ℝ)⁻¹ * k * M ^ (k - 1) * δ with hu
  have hf : HasSum (fun k : ℕ => ((k.factorial : ℂ)⁻¹ • a ^ k) * p) (exp a * p) := by
    simpa [expSeries_apply_eq] using (expSeries_hasSum_exp (𝕂 := ℂ) a).mul_right p
  have hc : HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • c ^ k) (Complex.exp c) := by
    rw [Complex.exp_eq_exp_ℂ]
    simpa [div_eq_inv_mul, smul_eq_mul] using (expSeries_div_hasSum_exp (𝔸 := ℂ) c)
  have hsum : HasSum w (exp a * p - Complex.exp c • p) := by
    refine (hf.sub (hc.smul_const p)).congr_fun ?_
    intro k
    rw [hw]
    simp only [smul_sub, smul_mul_assoc, smul_assoc]
  have hnorm : ∀ k, ‖w k‖ ≤ u k := by
    intro k
    rw [hw, hu]
    simp only [norm_smul, norm_inv, Complex.norm_natCast]
    calc (k.factorial : ℝ)⁻¹ * ‖a ^ k * p - c ^ k • p‖
        ≤ (k.factorial : ℝ)⁻¹ * ((k : ℝ) * M ^ (k - 1) * δ) :=
          mul_le_mul_of_nonneg_left (norm_pow_sub_smul_le hδ k) (by positivity)
    _ = (k.factorial : ℝ)⁻¹ * k * M ^ (k - 1) * δ := by ring
  have hmaj : HasSum u (δ * Real.exp M) := expMajorant_hasSum M δ
  have hsn : Summable fun k => ‖w k‖ :=
    Summable.of_nonneg_of_le (fun k => norm_nonneg _) hnorm hmaj.summable
  calc ‖exp a * p - Complex.exp c • p‖ = ‖∑' k, w k‖ := by rw [hsum.tsum_eq]
  _ ≤ ∑' k, ‖w k‖ := norm_tsum_le_tsum_norm hsn
  _ ≤ ∑' k, u k := Summable.tsum_mono hsn hmaj.summable hnorm
  _ = δ * Real.exp M := hmaj.tsum_eq

end BanachAlgebra

/-! ## The quantum error-correction statement -/

attribute [local instance] Matrix.linftyOpNormedRing Matrix.linftyOpNormedAlgebra

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- `A` is **`δ`-approximately detectable** with scalar `c` on the code `Q`: it acts on the
code space as the scalar `c` up to an error `δ` (this bundles approximate detectability
and approximate code-preservation into the single physically relevant quantity). -/
def ApproxDetectable (Q : QECCode n) (A : Matrix n n ℂ) (c : ℂ) (δ : ℝ) : Prop :=
  ‖A * Q.P - c • Q.P‖ ≤ δ

/-- Exact detectability plus exact code preservation is `0`-approximate detectability. -/
theorem approxDetectable_of_exact {Q : QECCode n} {A : Matrix n n ℂ} {c : ℂ}
    (hinv : CodePreserving Q A) (hdet : Detectable Q A c) :
    ApproxDetectable Q A c 0 := by
  rw [ApproxDetectable, codePreserving_detectable_mul_eq_smul hinv hdet, sub_self, norm_zero]

/-- **Detection errors add over sites.**  A transversal generator built from single-site
terms with detection errors `δ i` is approximately detectable with error `∑ δ i` and
scalar `∑ c i`.  This is the quantitative form of `Detectable.sum`. -/
theorem ApproxDetectable.sum {Q : QECCode n} {m : Type*} (s : Finset m)
    (A : m → Matrix n n ℂ) (c : m → ℂ) (δ : m → ℝ)
    (h : ∀ i ∈ s, ApproxDetectable Q (A i) (c i) (δ i)) :
    ApproxDetectable Q (∑ i ∈ s, A i) (∑ i ∈ s, c i) (∑ i ∈ s, δ i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [ApproxDetectable]
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, Finset.sum_insert ha]
      have hhead := h a (Finset.mem_insert_self a s)
      have htail := ih fun i hi => h i (Finset.mem_insert_of_mem hi)
      rw [ApproxDetectable] at hhead htail ⊢
      have hsplit : (A a + ∑ i ∈ s, A i) * Q.P - (c a + ∑ i ∈ s, c i) • Q.P
          = (A a * Q.P - c a • Q.P) + ((∑ i ∈ s, A i) * Q.P - (∑ i ∈ s, c i) • Q.P) := by
        rw [Matrix.add_mul, add_smul]
        abel
      rw [hsplit]
      exact le_trans (norm_add_le _ _) (add_le_add hhead htail)

/-- **Approximate Eastin–Knill.**  A `δ`-approximately detectable generator produces a
logical gate that is within `|t| δ e^M` of the global phase `e^{t c}`; the no-go theorem
degrades gracefully, and linearly, in the detection error. -/
theorem approx_eastin_knill {Q : QECCode n} {A : Matrix n n ℂ} {c : ℂ} {δ : ℝ}
    (h : ApproxDetectable Q A c δ) (t : ℂ) :
    ‖exp (t • A) * Q.P - Complex.exp (t * c) • Q.P‖
      ≤ (‖t‖ * δ) * Real.exp (max ‖t • A‖ ‖t * c‖) := by
  refine norm_exp_sub_smul_le ?_
  have hrw : (t • A) * Q.P - (t * c) • Q.P = t • (A * Q.P - c • Q.P) := by
    rw [smul_sub, Matrix.smul_mul, smul_smul]
  rw [hrw, norm_smul]
  exact mul_le_mul_of_nonneg_left h (norm_nonneg t)

/-- Consistency check: at zero detection error the approximate theorem reproduces the
exact one — the logical gate is *exactly* a phase. -/
theorem approx_eastin_knill_exact {Q : QECCode n} {A : Matrix n n ℂ} {c : ℂ}
    (hinv : CodePreserving Q A) (hdet : Detectable Q A c) (t : ℂ) :
    exp (t • A) * Q.P = Complex.exp (t * c) • Q.P := by
  have h := approx_eastin_knill (approxDetectable_of_exact hinv hdet) t
  rw [mul_zero, zero_mul] at h
  have := le_antisymm h (norm_nonneg _)
  exact sub_eq_zero.1 (norm_eq_zero.1 this)

/-- **Lower bound on the detection error of a nontrivial logical gate.**  If the gate
generated by `A` stays a distance `Δ` away from *every* global phase, then the detection
error obeys `Δ ≤ |t| δ e^M`; no approximately detectable generator can implement a
genuinely logical gate cheaply. -/
theorem eastin_knill_error_lower_bound {Q : QECCode n} {A : Matrix n n ℂ} {c : ℂ}
    {δ Δ : ℝ} (h : ApproxDetectable Q A c δ) (t : ℂ)
    (hfar : ∀ z : ℂ, Δ ≤ ‖exp (t • A) * Q.P - z • Q.P‖) :
    Δ ≤ (‖t‖ * δ) * Real.exp (max ‖t • A‖ ‖t * c‖) :=
  le_trans (hfar (Complex.exp (t * c))) (approx_eastin_knill h t)

/-- **The covariance–error tradeoff.**  For a transversal generator on a finite set of
sites, each with detection error at most `δ`, implementing a logical gate that is `Δ`-far
from every phase forces

  `Δ ≤ |t| · (#sites · δ) · e^M`,

i.e. `δ ≥ Δ e^{-M} / (|t| · #sites)`.  The per-site accuracy requirement relaxes only in
inverse proportion to the number of sites: continuous logical symmetry can be approximated,
but only by paying with code size. -/
theorem eastin_knill_covariance_tradeoff {Q : QECCode n} {m : Type*} [Fintype m]
    (A : m → Matrix n n ℂ) (c : m → ℂ) (δ Δ : ℝ) (t : ℂ)
    (hδ : ∀ i, ApproxDetectable Q (A i) (c i) δ)
    (hfar : ∀ z : ℂ, Δ ≤ ‖exp (t • ∑ i, A i) * Q.P - z • Q.P‖) :
    Δ ≤ (‖t‖ * (Fintype.card m * δ)) *
      Real.exp (max ‖t • ∑ i, A i‖ ‖t * ∑ i, c i‖) := by
  have hsum : ApproxDetectable Q (∑ i, A i) (∑ i, c i) (∑ _i : m, δ) :=
    ApproxDetectable.sum Finset.univ A c (fun _ => δ) fun i _ => hδ i
  have hcard : (∑ _i : m, δ) = Fintype.card m * δ := by
    simp [Finset.sum_const, nsmul_eq_mul]
  rw [hcard] at hsum
  exact eastin_knill_error_lower_bound hsum t hfar

end EastinKnill