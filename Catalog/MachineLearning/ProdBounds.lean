import Mathlib

/-!
# Product Perturbation Bounds

This file proves quantitative bounds on how finite products of bounded real sequences
respond to perturbation. These are the analytical core of the multiplicative
subadditivity theorem for description complexity.

## Main results

* `abs_finprod_le_pow` — `|∏ u_i| ≤ B^k` when each `|u_i| ≤ B`
* `abs_prod_sub_prod_le_of_uniform` — `|∏ u_i - ∏ v_i| ≤ k · B^(k-1) · δ`
  when each factor is B-bounded and δ-close
* `intervalProd_bounded` — pointwise products of bounded functions are bounded
-/

open Finset BigOperators

/-! ## Finite product bounds -/

/-
The absolute value of a finite product is bounded by the product of the bounds.
-/
theorem abs_finprod_le_pow (k : ℕ) (u : Fin k → ℝ) (B : ℝ)
    (_hB : 0 ≤ B) (hu : ∀ i, |u i| ≤ B) :
    |∏ i : Fin k, u i| ≤ B ^ k := by
  rw [ Finset.abs_prod ] ; exact le_trans ( Finset.prod_le_prod ( fun a _ ↦ by positivity ) fun _ _ ↦ hu _ ) ( by norm_num )

/-
Telescoping product perturbation bound (uniform version).

If `|u i| ≤ B`, `|v i| ≤ B`, and `|u i - v i| ≤ δ` for all `i : Fin k`,
then `|∏ u - ∏ v| ≤ k * B^(k-1) * δ`.

The proof uses induction on `k` with the Leibniz product decomposition
at each step: `|a*b - c*d| ≤ |a|*|b-d| + |d|*|a-c|`.
-/
theorem abs_prod_sub_prod_le_of_uniform (k : ℕ) (u v : Fin k → ℝ) (B δ : ℝ)
    (hB : 0 ≤ B) (hδ : 0 ≤ δ)
    (hBu : ∀ i, |u i| ≤ B) (hBv : ∀ i, |v i| ≤ B)
    (hd : ∀ i, |u i - v i| ≤ δ) :
    |(∏ i : Fin k, u i) - (∏ i : Fin k, v i)| ≤ ↑k * B ^ (k - 1) * δ := by
  induction' k with k ih;
  · norm_num;
  · -- Let's expand the product using the Leibniz rule.
    have h_expand : |∏ i, u i - ∏ i, v i| ≤ |u (Fin.last k)| * |∏ i : Fin k, u (Fin.castSucc i) - ∏ i : Fin k, v (Fin.castSucc i)| + |∏ i : Fin k, v (Fin.castSucc i)| * |u (Fin.last k) - v (Fin.last k)| := by
      rw [ ← abs_mul, ← abs_mul ];
      rw [ Fin.prod_univ_castSucc, Fin.prod_univ_castSucc ];
      grind +splitImp;
    rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ' ];
    refine le_trans h_expand ?_;
    refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( ih _ _ ( fun i => hBu _ ) ( fun i => hBv _ ) ( fun i => hd _ ) ) ( abs_nonneg _ ) ) ( mul_le_mul_of_nonneg_right ( show |∏ i : Fin ( k + 1 ), v ( Fin.castSucc i )| ≤ B ^ ( k + 1 ) from _ ) ( abs_nonneg _ ) ) ) _;
    · exact le_trans ( by rw [ Finset.abs_prod ] ) ( le_trans ( Finset.prod_le_prod ( fun _ _ => abs_nonneg _ ) fun _ _ => hBv _ ) ( by norm_num ) );
    · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_right ( hBu _ ) ( by positivity ) ) ( mul_le_mul_of_nonneg_left ( hd _ ) ( by positivity ) ) ) _ ; ring_nf ; norm_num

/-! ## Pointwise product of function families -/

/-- Pointwise product of a finite family of functions. -/
def intervalProd {k : ℕ} (f : Fin k → ℝ → ℝ) : ℝ → ℝ :=
  fun x => ∏ i : Fin k, f i x

/-
Products of bounded functions are bounded by `B^k`.
-/
theorem intervalProd_bounded (a b B : ℝ) (k : ℕ) (f : Fin k → ℝ → ℝ)
    (_hB : 0 ≤ B)
    (hBf : ∀ i x, x ∈ Set.Icc a b → |f i x| ≤ B) :
    ∀ x, x ∈ Set.Icc a b → |intervalProd f x| ≤ B ^ k := by
  exact fun x hx => by rw [ intervalProd ] ; exact le_trans ( by rw [ Finset.abs_prod ] ) ( by exact le_trans ( Finset.prod_le_prod ( fun _ _ => abs_nonneg _ ) fun _ _ => hBf _ _ hx ) <| by norm_num ) ;

/-
Product perturbation bound for function families on an interval.

If each `f i` and `g i` are `B`-bounded on `[a,b]` and pointwise `δ`-close,
then the products are `k * B^(k-1) * δ`-close on `[a,b]`.
-/
theorem intervalProd_approx (a b B δ : ℝ) (k : ℕ) (f g : Fin k → ℝ → ℝ)
    (hB : 0 ≤ B) (hδ : 0 ≤ δ)
    (hBf : ∀ i x, x ∈ Set.Icc a b → |f i x| ≤ B)
    (hBg : ∀ i x, x ∈ Set.Icc a b → |g i x| ≤ B)
    (hclose : ∀ i x, x ∈ Set.Icc a b → |f i x - g i x| ≤ δ) :
    ∀ x, x ∈ Set.Icc a b →
      |intervalProd f x - intervalProd g x| ≤ ↑k * B ^ (k - 1) * δ := by
  exact fun x hx => abs_prod_sub_prod_le_of_uniform k ( fun i => f i x ) ( fun i => g i x ) B δ hB hδ ( fun i => hBf i x hx ) ( fun i => hBg i x hx ) ( fun i => hclose i x hx )