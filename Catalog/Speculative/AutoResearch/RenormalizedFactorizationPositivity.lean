/-
# Positivity kills the twist group (Cycle 6, the key insight of Conjecture C3)

The Conjecture-C thread
(`Catalog/Probability/RenormalizedFactorizationValuation.lean`,
`Catalog/Probability/RenormalizedFactorizationExact.lean`) shows that the fibre of the
renormalized-product map over a realizable target is a **torsor** under the group of
valuation-zero twists, hence never a singleton once `m ≥ 2`.

Conjecture C3 predicted that this abundance is a purely *algebraic* phenomenon and that it
collapses as soon as one insists on probabilistic (nonnegative) coefficients.  This file proves
the exact mechanism behind that prediction:

**The group of positivity-preserving twists is trivial.**  If a formal power series `u` over `ℝ`
has nonnegative coefficients and admits an inverse `v` with nonnegative coefficients, then `u` is
a *constant* (`eq_C_of_mul_eq_one_of_nonneg`); after the usual normalization
`constantCoeff u = 1` this forces `u = 1` (`eq_one_of_mul_eq_one_of_nonneg`).  Equivalently,
the two-slot twist `(u, u⁻¹)` — the very deformation that produces the second factorization in
`factorization_not_unique` — is never positivity-preserving unless it is trivial
(`twoSlotTwist_positivity_trivial`, `posTwist_subsingleton`).

Probabilistically: the only sub-probability generating function whose reciprocal is again a
nonnegative series is the one of a point mass at `0` (`dirac_of_prob_inv_nonneg`).

The proof is a one-line convolution argument that is *not* available on the algebraic side: for
`n ≥ 1` the `n`-th coefficient of `u * v = 1` is a sum of **nonnegative** terms equal to `0`, so
every single term vanishes; the term `u_n · v_0` together with `u_0 v_0 = 1` gives `u_n = 0`.

No `sorry`, no `native_decide`, no new axioms.
-/
import Probability.RenormalizedFactorizationExact

namespace Catalog.Probability.RenormalizedFactorizationPositivity

open PowerSeries

/-- A formal power series over `ℝ` has *nonnegative coefficients*. -/
def Nonneg (u : PowerSeries ℝ) : Prop := ∀ n, 0 ≤ coeff n u

lemma constantCoeff_mul_constantCoeff {u v : PowerSeries ℝ} (huv : u * v = 1) :
    constantCoeff u * constantCoeff v = 1 := by
  rw [← map_mul, huv, map_one]

lemma constantCoeff_ne_zero_right {u v : PowerSeries ℝ} (huv : u * v = 1) :
    constantCoeff v ≠ 0 := by
  intro h
  have := constantCoeff_mul_constantCoeff huv
  rw [h, mul_zero] at this
  exact zero_ne_one this

/-- **The convolution obstruction.**  If `u * v = 1` and both series have nonnegative
coefficients, then all higher coefficients of `u` vanish: the `n`-th coefficient of the product
is a sum of nonnegative terms that has to be `0`, so each term — in particular `u_n · v_0` —
vanishes, and `v_0 ≠ 0`. -/
theorem coeff_eq_zero_of_mul_eq_one_of_nonneg {u v : PowerSeries ℝ}
    (hu : Nonneg u) (hv : Nonneg v) (huv : u * v = 1) {n : ℕ} (hn : n ≠ 0) :
    coeff n u = 0 := by
  have h0 : (coeff n) (u * v) = 0 := by
    rw [huv, coeff_one, if_neg hn]
  rw [coeff_mul] at h0
  have hterms : ∀ p ∈ Finset.antidiagonal n, coeff p.1 u * coeff p.2 v = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg fun p _ => mul_nonneg (hu _) (hv _)).mp h0
  have hmem : ((n, 0) : ℕ × ℕ) ∈ Finset.antidiagonal n := by simp
  have hprod : coeff n u * coeff 0 v = 0 := hterms (n, 0) hmem
  have hv0 : coeff 0 v ≠ 0 := by
    rw [coeff_zero_eq_constantCoeff]
    exact constantCoeff_ne_zero_right huv
  rcases mul_eq_zero.mp hprod with h | h
  · exact h
  · exact absurd h hv0

/-- **Positivity forces constancy.**  A nonnegative power series whose inverse is again
nonnegative is a constant. -/
theorem eq_C_of_mul_eq_one_of_nonneg {u v : PowerSeries ℝ}
    (hu : Nonneg u) (hv : Nonneg v) (huv : u * v = 1) :
    u = C (constantCoeff u) := by
  ext n
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · rw [coeff_zero_eq_constantCoeff, constantCoeff_C]
  · rw [coeff_eq_zero_of_mul_eq_one_of_nonneg hu hv huv (by omega : n ≠ 0), coeff_C,
      if_neg (by omega : ¬ n = 0)]

/-- The constant is strictly positive. -/
theorem constantCoeff_pos_of_nonneg {u v : PowerSeries ℝ}
    (hu : Nonneg u) (huv : u * v = 1) : 0 < constantCoeff u := by
  rcases lt_or_eq_of_le (by simpa [coeff_zero_eq_constantCoeff] using hu 0 :
      (0 : ℝ) ≤ constantCoeff u) with h | h
  · exact h
  · exact absurd (constantCoeff_mul_constantCoeff huv) (by rw [← h, zero_mul]; exact zero_ne_one)

/-- **The positivity-preserving twist group is trivial.**  A normalized nonnegative series with
nonnegative inverse is `1`. -/
theorem eq_one_of_mul_eq_one_of_nonneg {u v : PowerSeries ℝ}
    (hu : Nonneg u) (hv : Nonneg v) (huv : u * v = 1) (h1 : constantCoeff u = 1) :
    u = 1 := by
  rw [eq_C_of_mul_eq_one_of_nonneg hu hv huv, h1, map_one]

/-- **Conjecture C3, key insight.**  The two-slot twist `(u, u⁻¹)` that produces the second
factorization in `factorization_not_unique` is never positivity-preserving unless it is the
trivial twist. -/
theorem twoSlotTwist_positivity_trivial {u v : PowerSeries ℝ}
    (hu : Nonneg u) (hv : Nonneg v) (huv : u * v = 1) (h1 : constantCoeff u = 1) :
    u = 1 ∧ v = 1 := by
  have hu1 : u = 1 := eq_one_of_mul_eq_one_of_nonneg hu hv huv h1
  refine ⟨hu1, ?_⟩
  rw [hu1, one_mul] at huv
  exact huv

/-- Set-level form: the positivity-preserving, normalized twists form a subsingleton.  Contrast
this with the abstract picture, where the twist group is as large as the whole valuation-zero
group. -/
theorem posTwist_subsingleton :
    {u : PowerSeries ℝ | Nonneg u ∧ constantCoeff u = 1 ∧ ∃ v, u * v = 1 ∧ Nonneg v}.Subsingleton
    := by
  rintro u ⟨hu, hu1, v, huv, hv⟩ u' ⟨hu', hu1', v', hu'v', hv'⟩
  rw [eq_one_of_mul_eq_one_of_nonneg hu hv huv hu1,
    eq_one_of_mul_eq_one_of_nonneg hu' hv' hu'v' hu1']

/-! ## Probabilistic reading -/

/-- The generating function of the law `p` on `ℕ`. -/
noncomputable def gf (p : ℕ → ℝ) : PowerSeries ℝ := PowerSeries.mk p

@[simp] lemma coeff_gf (p : ℕ → ℝ) (n : ℕ) : coeff n (gf p) = p n := by
  simp [gf]

/-- **Only the point mass at `0` has a nonnegative reciprocal.**  If `p` is a nonnegative law
with `p 0 = 1` (equivalently, a sub-probability law whose generating function is normalized) and
the reciprocal of its generating function is again nonnegative, then `p` is the Dirac mass at
`0`. -/
theorem dirac_of_prob_inv_nonneg {p : ℕ → ℝ} (hp : ∀ n, 0 ≤ p n) (hp0 : p 0 = 1)
    {v : PowerSeries ℝ} (hv : Nonneg v) (huv : gf p * v = 1) :
    ∀ n, p n = if n = 0 then 1 else 0 := by
  have hu : Nonneg (gf p) := by intro n; simpa using hp n
  have h1 : constantCoeff (gf p) = 1 := by
    rw [← coeff_zero_eq_constantCoeff, coeff_gf, hp0]
  have hgf : gf p = 1 := eq_one_of_mul_eq_one_of_nonneg hu hv huv h1
  intro n
  have := congrArg (fun w => coeff n w) hgf
  simpa [coeff_one] using this

end Catalog.Probability.RenormalizedFactorizationPositivity