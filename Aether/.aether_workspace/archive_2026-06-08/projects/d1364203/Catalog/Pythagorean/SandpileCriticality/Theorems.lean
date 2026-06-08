/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Abelian Sandpile Criticality — Main Theorems

This file proves the main theorems establishing that critical sandpile
configurations are characterized by energy minimization via the Laplacian.

## Main Results

### Laplacian Properties
* `graphLaplacian_symmetric` — the Laplacian is symmetric
* `graphLaplacian_row_sum_zero` — rows sum to zero
* `graphLaplacian_diagonal_eq_degree` — diagonal entries equal vertex degree

### Energy Theory
* `laplacianRealQuadratic_nonneg` — the quadratic form is nonneg (sum of squares)
* `laplacianQuadraticInt_nonneg` — integer version is nonneg
* `laplacianRealQuadratic_pos_of_connected` — strictly positive for connected
  graphs when x vanishes at sink and x ≠ 0

### Chip-Firing
* `chipFireEquivSink_refl` — reflexivity
* `chipFireEquivSink_symm` — symmetry
* `chipFireEquivSink_trans` — transitivity
* `laplacianDiv_sum_zero` — principal divisors have degree zero

### Cross-Domain Bridge (Theorem 4)
* `fiedler_lower_bound_laplacianQuadratic` — λ₂ ‖x‖² ≤ x^T L x

## References

* Baker–Norine (2007), Biggs (1999), Corry–Perkinson (2018)
-/

import Pythagorean.SandpileCriticality.Defs

open Finset BigOperators Matrix SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Laplacian Properties -/

/-
The graph Laplacian is symmetric.
-/
theorem graphLaplacian_symmetric (G : SimpleGraph V) [DecidableRel G.Adj]
    (i j : V) : graphLaplacian G i j = graphLaplacian G j i := by
  unfold graphLaplacian;
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-
Each row of the graph Laplacian sums to zero.
-/
theorem graphLaplacian_row_sum_zero (G : SimpleGraph V) [DecidableRel G.Adj]
    (i : V) : ∑ j : V, graphLaplacian G i j = 0 := by
  unfold graphLaplacian; simp +decide [ Finset.sum_ite, Finset.filter_ne' ] ;
  simp +decide [ Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ; ring;
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
Diagonal entries of the Laplacian equal the vertex degree.
-/
theorem graphLaplacian_diagonal_eq_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V) : graphLaplacian G v v = (G.degree v : ℤ) := by
  unfold graphLaplacian;
  simp +decide

/-
Off-diagonal entries are nonpositive.
-/
theorem graphLaplacian_off_diagonal (G : SimpleGraph V) [DecidableRel G.Adj]
    (i j : V) (hij : i ≠ j) : graphLaplacian G i j ≤ 0 := by
  unfold graphLaplacian; aesop

/-! ## Principal Divisor Properties -/

/-
Principal divisors have degree zero (conservation of charge).
    This follows from the row-sum-zero property of the Laplacian.

    **Connection to catalog:** This is the `V → ℤ` analogue of
    `principalDivisor_degree_zero` from ChipFiringCorrespondence.lean.
-/
theorem laplacianDiv_sum_zero (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : ∑ v : V, laplacianDiv G f v = 0 := by
  convert Finset.sum_comm using 1;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, graphLaplacian_symmetric, graphLaplacian_row_sum_zero ]

/-! ## Chip-Firing Equivalence -/

/-
Chip-firing equivalence is reflexive.
-/
theorem chipFireEquivSink_refl (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D : V → ℤ) : ChipFireEquivSink G q D D := by
  exact ⟨ 0, by simp +decide, by simp +decide [ laplacianDiv ] ⟩

/-
Chip-firing equivalence is symmetric.
-/
theorem chipFireEquivSink_symm (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D₁ D₂ : V → ℤ) (h : ChipFireEquivSink G q D₁ D₂) :
    ChipFireEquivSink G q D₂ D₁ := by
  -- By definition of ChipFireEquivSink, there exists a firing vector f such that D₂ = D₁ + L·f and f(q) = 0.
  obtain ⟨f, hf⟩ := h;
  refine' ⟨ -f, _, _ ⟩ <;> simp_all +decide [ laplacianDiv ]

/-
Chip-firing equivalence is transitive.
-/
theorem chipFireEquivSink_trans (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D₁ D₂ D₃ : V → ℤ)
    (h₁₂ : ChipFireEquivSink G q D₁ D₂)
    (h₂₃ : ChipFireEquivSink G q D₂ D₃) :
    ChipFireEquivSink G q D₁ D₃ := by
  -- By definition of ChipFireEquivSink, there exist firing vectors f₁ and f₂ such that D₂ = D₁ + L·f₁ and D₃ = D₂ + L·f₂.
  obtain ⟨f₁, hf₁⟩ := h₁₂
  obtain ⟨f₂, hf₂⟩ := h₂₃;
  -- By linearity of the Laplacian, we have L·(f₁ + f₂) = L·f₁ + L·f₂.
  have h_laplacian_add : ∀ (f g : V → ℤ), laplacianDiv G (f + g) = laplacianDiv G f + laplacianDiv G g := by
    intro f g; ext v; simp +decide [ laplacianDiv ] ;
    simp +decide only [mul_add, sum_add_distrib];
  exact ⟨ f₁ + f₂, by simp +decide [ hf₁.1, hf₂.1 ], fun v => by simpa [ h_laplacian_add ] using by linarith [ hf₁.2 v, hf₂.2 v ] ⟩

/-
Chip-firing preserves the total degree of a divisor.
    **Connection to catalog:** This is the `V → ℤ` analogue of
    `chipFire_degree_preserved` from ChipFiringCorrespondence.lean.
-/
theorem chipFireEquivSink_preserves_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D₁ D₂ : V → ℤ) (h : ChipFireEquivSink G q D₁ D₂) :
    ∑ v, D₁ v = ∑ v, D₂ v := by
  obtain ⟨ f, hf₁, hf₂ ⟩ := h;
  simp_all +decide [ Finset.sum_add_distrib ];
  convert laplacianDiv_sum_zero G f using 1

/-! ## Quadratic Form Properties -/

/-
**The Laplacian quadratic form is nonneg** (sum of squares).
    This is the discrete analogue of ∫|∇f|² ≥ 0.
-/
theorem laplacianRealQuadratic_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ) : 0 ≤ laplacianRealQuadratic G x := by
  exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by split_ifs <;> positivity;

/-
**The integer Laplacian quadratic form is nonneg.**
-/
theorem laplacianQuadraticInt_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : 0 ≤ laplacianQuadraticInt G f := by
  exact Finset.sum_nonneg fun v _ => Finset.sum_nonneg fun w _ => by split_ifs <;> positivity;

/-
**Strict positivity for connected graphs.**
    If G is connected and x vanishes at q and is not identically zero,
    then x^T L x > 0. This is the key positive-definiteness result for
    the reduced Laplacian.

    **Proof idea:** If x^T L x = 0, then x is constant on each connected
    component. Since G is connected and x(q) = 0, x must be identically zero.
-/
omit [DecidableEq V] in
theorem laplacianRealQuadratic_pos_of_connected
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (q : V) (x : V → ℝ)
    (hq : x q = 0) (hne : x ≠ 0) :
    0 < laplacianRealQuadratic G x := by
  -- By squaring both sides, we can remove the absolute value.
  suffices h_sq : (∑ v, ∑ w, if G.Adj v w then (x v - x w) ^ 2 else 0) ≠ 0 by
    exact lt_of_le_of_ne ( by exact Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => by split_ifs <;> positivity ) h_sq.symm;
  -- Since $x \neq 0$, there exists some $v$ such that $x v \neq 0$.
  obtain ⟨v, hv⟩ : ∃ v, x v ≠ 0 := by
    exact Function.ne_iff.mp hne;
  -- Since $G$ is connected, there exists a path from $q$ to $v$.
  obtain ⟨p, hp⟩ : ∃ p : G.Walk q v, True := by
    exact ⟨ hconn q v |> fun h => h.some, trivial ⟩;
  induction' p with u w p ih;
  · contradiction;
  · by_cases h : x p = 0 <;> simp_all +decide;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun v _ => Finset.sum_nonneg fun w _ => by positivity ) ( Finset.mem_univ w ) |> le_trans ( Finset.single_le_sum ( fun u _ => by positivity ) ( Finset.mem_univ p ) ) ) ) ; simp +decide [ *, sq_pos_iff ]

/-! ## Theorem 2: Energy Expansion Under Firing

This is the "engine theorem" that drives energy descent.
When we fire a vector f (with f(q) = 0), the energy changes by a
quadratic expression.
-/

/-
**Energy expansion under chip-firing.**
    The quadratic form of a fired divisor decomposes as:
    `Q(D + Lf) = Q(D) + 2 * cross_term + Q(Lf)`
-/
theorem laplacianQuadraticInt_sub_firing
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D f : V → ℤ) :
    laplacianQuadraticInt G (fun v => D v + laplacianDiv G f v)
      = laplacianQuadraticInt G D
        + 2 * (∑ v : V, ∑ w : V,
            if G.Adj v w then (D v - D w) * (laplacianDiv G f v - laplacianDiv G f w) else 0)
        + laplacianQuadraticInt G (laplacianDiv G f) := by
  simp +decide only [laplacianQuadraticInt];
  simp +decide only [mul_sum _ _ _, ← sum_add_distrib];
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by split_ifs <;> ring;

/-! ## Theorem 4: Fiedler Bound — Spectral Gap Controls Energy

The algebraic connectivity (Fiedler value) provides a lower bound on the
Laplacian quadratic form for vectors orthogonal to constants. -/

/-
**Fiedler lower bound on the Laplacian quadratic form.**
    For any vector orthogonal to constants with unit norm:
    `fiedlerValue G ≤ Q_L(x)`
-/
theorem fiedler_lower_bound_laplacianQuadratic
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ)
    (horth : orthogonalToConstants x)
    (hnorm : euclideanNormSq x = 1) :
    fiedlerValue G ≤ laplacianRealQuadratic G x := by
  refine' ciInf_le_of_le _ _ _;
  exact ⟨ 0, Set.forall_mem_range.2 fun x => by exact Real.iInf_nonneg fun _ => Real.iInf_nonneg fun _ => laplacianRealQuadratic_nonneg G x ⟩;
  exact x;
  aesop

/-! ## Additional Quadratic Form Properties -/

/-
The Laplacian quadratic form is zero iff x is constant on each
    connected component. For a connected graph, this means x is constant.
-/
omit [DecidableEq V] in
theorem laplacianRealQuadratic_eq_zero_iff_constant
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (x : V → ℝ) :
    laplacianRealQuadratic G x = 0 ↔ ∃ c : ℝ, ∀ v, x v = c := by
  constructor;
  · intro h;
    have h_const : ∀ v w, G.Adj v w → x v = x w := by
      rw [ laplacianRealQuadratic ] at h;
      rw [ Finset.sum_eq_zero_iff_of_nonneg fun v _ => Finset.sum_nonneg fun w _ => by positivity ] at h;
      simp_all +decide [ Finset.sum_ite ];
      intro v w hvw; specialize h v; rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _ ] at h; simp_all +decide [ sub_eq_iff_eq_add ] ;
      exact h _ hvw;
    rcases isEmpty_or_nonempty V with ( h | ⟨ v ⟩ );
    · exact ⟨ 0, fun v => h.elim v ⟩;
    · obtain ⟨ v ⟩ := v;
      use x v;
      intro w;
      have := hconn v w;
      obtain ⟨ p ⟩ := this;
      induction p <;> [ rfl; linarith [ h_const _ _ ‹_› ] ];
  · rintro ⟨ c, hc ⟩ ; simp +decide [ hc, laplacianRealQuadratic ] ;

/-
Scaling property of the quadratic form.
-/
omit [DecidableEq V] in
theorem laplacianRealQuadratic_smul (G : SimpleGraph V) [DecidableRel G.Adj]
    (c : ℝ) (x : V → ℝ) :
    laplacianRealQuadratic G (fun v => c * x v) =
      c ^ 2 * laplacianRealQuadratic G x := by
  simp +decide only [laplacianRealQuadratic, pow_two];
  simp +decide only [mul_sub, mul_left_comm, Finset.mul_sum _ _ _, mul_assoc];
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by split_ifs <;> ring;