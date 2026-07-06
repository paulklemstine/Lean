/-
# Gamma-function telescoping identity for Beta-moment products

This file develops a telescoping identity for products of ratios of Gamma
functions arising from Beta-distribution moment computations.
-/
import Mathlib

open scoped BigOperators

namespace Catalog.BetaMomentTelescope

/-
`Γ(x + n) / Γ(x)` equals the product `∏_{i<n} (x + i)`.
-/
lemma gamma_ratio_eq_prod (x : ℝ) (hx : Real.Gamma x ≠ 0) (n : ℕ) :
    Real.Gamma (x + n) / Real.Gamma x = ∏ i ∈ Finset.range n, (x + i) := by
  by_cases h : ∃ i : ℕ, i < n ∧ x + i = 0;
  · rcases h with ⟨ i, hi, hi' ⟩ ; simp_all +decide [ Real.Gamma_eq_zero_iff ] ;
    exact False.elim <| hx i <| by linarith;
  · induction' n with n ih;
    · norm_num [ hx ];
    · rw [ Finset.prod_range_succ_comm, ← ih fun ⟨ i, hi, hi' ⟩ => h ⟨ i, Nat.lt_succ_of_lt hi, hi' ⟩ ];
      rw [ Nat.cast_succ, ← add_assoc, Real.Gamma_add_one ( by push_neg at h; exact h _ ( Nat.lt_succ_self _ ) ), mul_div_assoc ]

/-
One factor of the Beta-moment product rewritten as a ratio of `Γ(·+p)/Γ(·)`.
-/
lemma moment_factor_decomposition (α β : ℕ → ℝ) (p : ℝ) (j : ℕ)
    (h : α (j + 1) = α j + β j) :
    (Real.Gamma (α j + p) * Real.Gamma (α j + β j)) /
        (Real.Gamma (α j) * Real.Gamma (α j + β j + p)) =
      (Real.Gamma (α j + p) / Real.Gamma (α j)) /
        (Real.Gamma (α (j + 1) + p) / Real.Gamma (α (j + 1))) := by
  rw [ h, div_div_eq_mul_div ] ; ring;

/-
Telescoping a product of consecutive ratios of a function `f ∘ α`.
-/
lemma chaining_telescope (f : ℝ → ℝ) (α : ℕ → ℝ) (n : ℕ)
    (hf : ∀ j ∈ Finset.range (n + 1), f (α j) ≠ 0) :
    ∏ j ∈ Finset.range n, (f (α j) / f (α (j + 1))) = f (α 0) / f (α n) := by
  induction n <;> simp_all +decide [ Finset.prod_range_succ ];
  grind +splitImp

/--
The main telescoping identity for Beta-moment products.

An extra hypothesis `hαp` (that `Γ(α j + p) ≠ 0` for every `j ∈ range n`) is required
beyond those in the original problem statement: without it the identity is false, since a
vanishing interior `Γ(α k + p)` collapses the left-hand product to `0` while the
right-hand side stays nonzero.

The hypotheses `_hαβ` (that `Γ(α j + β j) ≠ 0`) and `_hα0` (that `Γ(α 0) ≠ 0`) were part
of the requested statement but turn out to be unnecessary: the per-factor decomposition is
an unconditional field identity, and the `j = 0` non-vanishing needed for telescoping is
already covered by `hα`/`hαn`. They are kept (underscore-prefixed) to match the requested
signature.
-/
theorem beta_moment_product_telescope (α β : ℕ → ℝ) (p : ℝ) (n : ℕ)
    (hchain : ∀ j ∈ Finset.range n, α (j + 1) = α j + β j)
    (hα : ∀ j ∈ Finset.range n, Real.Gamma (α j) ≠ 0)
    (_hαβ : ∀ j ∈ Finset.range n, Real.Gamma (α j + β j) ≠ 0)
    (hαp : ∀ j ∈ Finset.range n, Real.Gamma (α j + p) ≠ 0)
    (_hα0 : Real.Gamma (α 0) ≠ 0)
    (hαn : Real.Gamma (α n) ≠ 0)
    (hαnp : Real.Gamma (α n + p) ≠ 0) :
    ∏ j ∈ Finset.range n,
        (Real.Gamma (α j + p) * Real.Gamma (α j + β j)) /
          (Real.Gamma (α j) * Real.Gamma (α j + β j + p)) =
      (Real.Gamma (α 0 + p) * Real.Gamma (α n)) /
        (Real.Gamma (α 0) * Real.Gamma (α n + p)) := by
  convert ( chaining_telescope ( fun x => Real.Gamma ( x + p ) / Real.Gamma ( x ) ) α n ?_ ) using 1;
  · apply Finset.prod_congr rfl;
    intro j hj; rw [ hchain j hj ] ; rw [ div_div_eq_mul_div ] ; ring;
  · rw [ div_div_eq_mul_div ] ; ring;
  · grind

end Catalog.BetaMomentTelescope