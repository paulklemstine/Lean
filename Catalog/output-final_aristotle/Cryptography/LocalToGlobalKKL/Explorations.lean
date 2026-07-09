import Mathlib
import Cryptography.LocalToGlobalKKL.Basic

/-!
# Explorations following the Local-to-Global KKL theorem

This file builds on `Cryptography.LocalToGlobalKKL.Basic` and explores consequences
of the abstract local-to-global engine.

The main additions are:

* `abstract_localToGlobal_KKL_variance` — a *faithful* restatement of the
  local-to-global principle in which the local KKL hypothesis has the true
  conditional shape of the KKL theorem: *if a link is non-degenerate (its variance
  proxy exceeds a threshold `V₀`) then it has a coordinate of influence `≥ τ`.*
  Together with the assumption that every link is non-degenerate, this yields the
  global total-influence bound.

* `abstract_global_influential_coord_variance` — the corresponding global
  influential-coordinate statement.

* `regular_complex_exact` — in a *regular* system where every link has the same
  total influence `A` and every weight is `1`, the global total influence is
  exactly `|κ| · A`; combined with the local bound this gives the clean
  `|κ| · τ ≤` total influence.

* `cube_localKKL_influential_coord_real` — the real-valued global
  influential-coordinate consequence for the Boolean cube: if each of the two
  links of a coordinate `j` has an influential coordinate of influence `≥ T`,
  some global coordinate has (real) influence `≥ 2T / n`.
-/

namespace LocalToGlobalKKL

open Finset

/-! ## Variance-thresholded local-to-global KKL -/

/-- **Local-to-global KKL with the genuine KKL conditional.**

Here the local KKL hypothesis is stated in its true form: for each link `ℓ`,
*if* the link is non-degenerate (`V₀ ≤ V ℓ`, a variance proxy exceeding a
threshold) *then* it has a coordinate of influence at least `τ`.  Assuming every
link is non-degenerate, the global total influence is at least `τ · (∑ ℓ w ℓ)`. -/
theorem abstract_localToGlobal_KKL_variance
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (V : κ → ℝ) (V₀ τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (hnondeg : ∀ l, V₀ ≤ V l)
    (localKKL : ∀ l, V₀ ≤ V l → ∃ i, τ ≤ Iℓ l i) :
    τ * (∑ l, w l) ≤ ∑ i, I i :=
  abstract_localToGlobal_KKL I w Iℓ τ hw hIℓ bridge
    (fun l => localKKL l (hnondeg l))

/-- Global influential-coordinate consequence of the variance-thresholded
local-to-global KKL principle. -/
theorem abstract_global_influential_coord_variance
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (V : κ → ℝ) (V₀ τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (hnondeg : ∀ l, V₀ ≤ V l)
    (localKKL : ∀ l, V₀ ≤ V l → ∃ i, τ ≤ Iℓ l i) :
    ∃ i, τ * (∑ l, w l) ≤ (Fintype.card ι : ℝ) * I i :=
  abstract_global_influential_coord I w Iℓ τ hw hIℓ bridge
    (fun l => localKKL l (hnondeg l))

/-! ## The regular case: exact total influence -/

/-- **Regular systems.**  If every link carries exactly total influence `A` and
every weight is `1`, then the global total influence is exactly `|κ| · A`. -/
theorem regular_complex_exact
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (I : ι → ℝ) (Iℓ : κ → ι → ℝ) (A : ℝ)
    (bridge : ∀ i, I i = ∑ l, (1 : ℝ) * Iℓ l i)
    (hreg : ∀ l, ∑ i, Iℓ l i = A) :
    ∑ i, I i = (Fintype.card κ : ℝ) * A := by
  have step : ∑ i, I i = ∑ l, (∑ i, Iℓ l i) := by
    simp_rw [bridge, one_mul]; rw [Finset.sum_comm]
  rw [step]
  simp_rw [hreg]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## Real-valued global influential coordinate for the Boolean cube -/

/-- **Boolean-cube local-to-global KKL, real form.**
If each of the two links of the coordinate `j` has an influential coordinate of
influence at least `T`, then some global coordinate has real influence at least
the average `2T / n`, stated multiplicatively as `2T ≤ n · Inf f i`. -/
theorem cube_localKKL_influential_coord_real {n : ℕ} [NeZero n]
    (f : (Fin n → Bool) → Bool) (j : Fin n) (T : ℕ)
    (hfalse : ∃ i, T ≤ InfSub f j false i) (htrue : ∃ i, T ≤ InfSub f j true i) :
    ∃ i, (2 * T : ℝ) ≤ (n : ℝ) * Inf f i := by
  have htot : 2 * T ≤ TotInf f := cube_total_via_abstract f j T hfalse htrue
  obtain ⟨i, hi⟩ := exists_ge_avg_real (ι := Fin n) (fun i => (Inf f i : ℝ))
  refine ⟨i, ?_⟩
  have hcard : (Fintype.card (Fin n) : ℝ) = (n : ℝ) := by
    rw [Fintype.card_fin]
  have hsum : (∑ i, (Inf f i : ℝ)) = (TotInf f : ℝ) := by
    unfold TotInf; push_cast; ring
  rw [hcard, hsum] at hi
  have h2 : (2 * T : ℝ) ≤ (TotInf f : ℝ) := by exact_mod_cast htot
  calc (2 * T : ℝ) ≤ (TotInf f : ℝ) := h2
    _ ≤ (n : ℝ) * Inf f i := hi

end LocalToGlobalKKL