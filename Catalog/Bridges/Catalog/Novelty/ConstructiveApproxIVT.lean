import Mathlib

/-!
# A constructive, non-circular approximate intermediate value theorem

This file develops a finite-grid "approximate IVT" with an explicit modulus and a
supplied mesh size. It deliberately does **not** prove or use the classical
intermediate value theorem: no `intermediate_value_Icc`, `IsPreconnected`,
connectedness of intervals, or root-existence results are used.

The file is organized strictly bottom-up:
* `finite_sign_change` — a purely finite/order lemma about a sequence `ℕ → ℝ`;
* `discrete_approx_ivt` — a discrete approximate IVT built from `finite_sign_change`;
* `approx_ivt_of_modulus_nonpos_nonneg` — the oriented modulus-based theorem, built
  on `discrete_approx_ivt` via a uniform grid;
* `approx_ivt_of_modulus` — the symmetric version, derived from the oriented one.
-/

namespace ConstructiveApproxIVT

open Set

/-- The uniform grid on `[a, b]` with `N` subdivisions: the `i`-th node. -/
noncomputable def grid (a b : ℝ) (N i : ℕ) : ℝ := a + (i : ℝ) * (b - a) / (N : ℝ)

lemma grid_zero (a b : ℝ) (N : ℕ) : grid a b N 0 = a := by
  -- By definition of grid, we have grid a b N 0 = a + 0 * (b - a) / N = a.
  simp [grid]

lemma grid_last (a b : ℝ) {N : ℕ} (hN : 0 < N) : grid a b N N = b := by
  -- By definition of grid, we have grid a b N N = a + N * (b - a) / N.
  simp [grid];
  rw [ mul_div_cancel_left₀ _ ( by positivity ), add_sub_cancel ]

lemma grid_mem_Icc (a b : ℝ) {N i : ℕ} (hab : a ≤ b) (hN : 0 < N) (hi : i ≤ N) :
    grid a b N i ∈ Set.Icc a b := by
      constructor <;> unfold grid <;> nlinarith [ show ( i : ℝ ) ≤ N by norm_cast, show ( N : ℝ ) ≥ 1 by norm_cast, mul_div_cancel₀ ( ( i : ℝ ) * ( b - a ) ) ( by positivity : ( N : ℝ ) ≠ 0 ) ]

lemma grid_succ_dist_le (a b δ : ℝ) {N i : ℕ} (hab : a ≤ b) (hN : 0 < N)
    (hmesh : (b - a) / (N : ℝ) ≤ δ) : |grid a b N (i+1) - grid a b N i| ≤ δ := by
      unfold grid;
      convert hmesh using 1 ; push_cast ; ring;
      exact abs_of_nonneg ( by nlinarith [ inv_pos.2 ( by positivity : 0 < ( N : ℝ ) ) ] )

/-- A purely finite sign-change lemma. If `u 0 ≤ 0 ≤ u N`, then either some node is
exactly zero, or there is an adjacent pair where the sign changes from `≤ 0` to `≥ 0`. -/
theorem finite_sign_change (u : ℕ → ℝ) {N : ℕ} (h0 : u 0 ≤ 0) (hN : 0 ≤ u N) :
    (∃ i, i ≤ N ∧ u i = 0) ∨ ∃ i, i < N ∧ u i ≤ 0 ∧ 0 ≤ u (i+1) := by
      by_contra h_no_sign_change;
      -- By induction, we can show that $u_i < 0$ for all $i \leq N$.
      have h_ind : ∀ i ≤ N, u i < 0 := by
        intro i hi; induction' i with i ih <;> simp_all +decide ;
        · exact lt_of_le_of_ne h0 ( h_no_sign_change.1 0 bot_le );
        · exact h_no_sign_change.2 i hi ( le_of_lt ( ih ( Nat.le_of_lt hi ) ) );
      linarith [ h_ind N le_rfl ]

/-- The discrete approximate IVT. If `u 0 ≤ 0 ≤ u N` and consecutive steps move by at
most `ε`, then some node has `|u i| ≤ ε`. -/
theorem discrete_approx_ivt (u : ℕ → ℝ) {N : ℕ} {ε : ℝ} (hε : 0 ≤ ε) (h0 : u 0 ≤ 0)
    (hN : 0 ≤ u N) (hstep : ∀ i, i < N → |u (i+1) - u i| ≤ ε) :
    ∃ i, i ≤ N ∧ |u i| ≤ ε := by
      obtain ⟨ i, hi, h ⟩ := finite_sign_change u h0 hN;
      · exact ⟨ i, hi, by simpa [ h ] using hε ⟩;
      · grind

/-- The oriented modulus-based approximate IVT, for `f a ≤ 0 ≤ f b`.

The hypothesis `hδ : 0 < δ` is part of the requested signature; the oriented proof does
not actually need it (the mesh bound `hmesh` suffices), so it is retained only for the
stated interface. -/
theorem approx_ivt_of_modulus_nonpos_nonneg {f : ℝ → ℝ} {a b ε δ : ℝ} {N : ℕ}
    (hab : a ≤ b) (hε : 0 ≤ ε) (hδ : 0 < δ) (hN : 0 < N)
    (hmesh : (b - a) / (N : ℝ) ≤ δ) (hleft : f a ≤ 0) (hright : 0 ≤ f b)
    (hmod : ∀ x ∈ Set.Icc a b, ∀ y ∈ Set.Icc a b, |y - x| ≤ δ → |f y - f x| ≤ ε) :
    ∃ x ∈ Set.Icc a b, |f x| ≤ ε := by
      -- Set u : ℕ → ℝ := fun i => f (grid a b N i).
      set u : ℕ → ℝ := fun i => f (grid a b N i);
      -- By the discrete_approx_ivt theorem, there exists an i such that |u i| ≤ ε.
      obtain ⟨i, hi⟩ : ∃ i, i ≤ N ∧ |u i| ≤ ε := by
        apply discrete_approx_ivt u hε;
        · grind +suggestions;
        · convert hright using 1;
          exact congr_arg f ( grid_last a b hN );
        · intros i hi; exact hmod ( grid a b N i ) ( grid_mem_Icc a b hab hN ( by linarith ) ) ( grid a b N ( i + 1 ) ) ( grid_mem_Icc a b hab hN ( by linarith ) ) ( grid_succ_dist_le a b δ hab hN hmesh ) ;
      exact ⟨ grid a b N i, grid_mem_Icc a b hab hN hi.1, hi.2 ⟩

/-- The symmetric modulus-based approximate IVT, for either sign orientation. -/
theorem approx_ivt_of_modulus {f : ℝ → ℝ} {a b ε δ : ℝ} {N : ℕ}
    (hab : a ≤ b) (hε : 0 ≤ ε) (hδ : 0 < δ) (hN : 0 < N)
    (hmesh : (b - a) / (N : ℝ) ≤ δ)
    (hsign : (f a ≤ 0 ∧ 0 ≤ f b) ∨ (0 ≤ f a ∧ f b ≤ 0))
    (hmod : ∀ x ∈ Set.Icc a b, ∀ y ∈ Set.Icc a b, |y - x| ≤ δ → |f y - f x| ≤ ε) :
    ∃ x ∈ Set.Icc a b, |f x| ≤ ε := by
      rcases hsign with hsign | hsign;
      · convert approx_ivt_of_modulus_nonpos_nonneg hab hε hδ hN hmesh hsign.1 hsign.2 hmod;
      · have := @approx_ivt_of_modulus_nonpos_nonneg ( fun x => -f x ) a b ε δ N hab hε hδ hN hmesh ?_ ?_ ?_ <;> norm_num at *;
        · exact this;
        · linarith;
        · linarith;
        · exact fun x hx₁ hx₂ y hy₁ hy₂ hxy => by rw [ neg_add_eq_sub, abs_sub_comm ] ; exact hmod x hx₁ hx₂ y hy₁ hy₂ hxy;

end ConstructiveApproxIVT