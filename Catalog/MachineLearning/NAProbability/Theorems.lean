/-
# Non-Archimedean Finitely Additive Probability: Main Theorems

This module proves the core theorems of non-Archimedean probability theory:
1. Existence of uniform grid probabilities with equal positive atomic masses
2. Exact expectation of affine observables matching the continuum limit
3. Refinement invariance (coherence under grid subdivision)
4. Convergence of grid expectations to the continuum integral (shadow principle)
5. Impossibility of countably additive equal-mass probabilities on ℕ
-/
import Speculative.NAProbability.Defs

open Finset BigOperators

/-! ## Theorem 1: Uniform atomic probability on finite grids -/

/-- Every point on the grid `Fin (n+1)` carries equal mass `1/(n+1)` under
the uniform grid probability. This is the seed theorem: every point has a
nonzero "small" probability, and as `n → ∞` these masses asymptotically
behave as infinitesimals. -/
theorem grid_uniform_exists (n : ℕ) :
    ∃ P : NAProbability (Fin (n + 1)) ℚ,
      ∀ i : Fin (n + 1),
        P.mass ({i}) = 1 / (n + 1 : ℚ) := by
  exact ⟨gridUniformProb n, gridUniformProb_singleton n⟩

/-! ## Theorem 2: Exact affine expectation on grids -/

/-
Helper: the Gauss sum formula `∑ i : Fin (n+1), (i : ℚ) = n*(n+1)/2`.
-/
theorem fin_sum_id (n : ℕ) :
    ∑ i : Fin (n + 1), (i : ℚ) = (n : ℚ) * (n + 1) / 2 := by
  exact Nat.recOn n ( by norm_num ) fun k ih => by norm_num [ Fin.sum_univ_castSucc ] at * ; linarith;

/-
For affine observables `X(i) = a * i/n + b` on the uniform grid probability
over `Fin (n+1)`, the expectation equals exactly `a/2 + b`. This exhibits a
proto-continuum law: the discrete model already recovers the exact classical
expectation for affine functions.
-/
theorem grid_expectation_affine (n : ℕ) (hn : 0 < n) (a b : ℚ) :
    let X : Fin (n + 1) → ℚ := fun i => a * (i : ℚ) / n + b
    let P := gridUniformProb n
    NAExpectation P X = a / 2 + b := by
  unfold NAExpectation;
  unfold gridUniformProb;
  simp +decide [ Finset.sum_add_distrib, add_mul, div_eq_mul_inv ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  rw [ show ( ∑ i : Fin ( n + 1 ), ( i : ℚ ) ) = n * ( n + 1 ) / 2 from mod_cast fin_sum_id n ] ; ring;
  -- Combine like terms and simplify the expression.
  field_simp
  ring

/-! ## Theorem 3: Refinement invariance -/

/-- Uniform probability on `Fin m` for any `m ≥ 1`, parameterized by `m` directly. -/
noncomputable def uniformFinProb (m : ℕ) (hm : 0 < m) :
    NAProbability (Fin m) ℚ where
  mass s := (s.card : ℚ) / (m : ℚ)
  empty_mass := by simp
  add_mass := by
    intro s t hst
    rw [Finset.card_union_of_disjoint hst]
    push_cast; ring
  total_mass := by
    rw [Finset.card_fin]; push_cast
    exact div_self (by positivity)
  nonneg_mass := fun s => by positivity

/-- The uniform prob on `Fin m` assigns each singleton mass `1/m`. -/
theorem uniformFinProb_singleton (m : ℕ) (hm : 0 < m) (i : Fin m) :
    (uniformFinProb m hm).mass {i} = 1 / (m : ℚ) := by
  simp [uniformFinProb, Finset.card_singleton]

/-
Helper: the number of elements in `Fin (k*(n+1))` mapping to a given
coarse point under the block embedding `j ↦ j/k` is exactly `k`.
-/
theorem refine_fiber_card {n : ℕ} (k : ℕ) (hk : 0 < k) (i : Fin (n + 1)) :
    (Finset.univ.filter (fun j : Fin (k * (n + 1)) => j.val / k = i.val)).card = k := by
  rw [ Finset.card_eq_of_bijective ];
  use fun j hj => ⟨ i * k + j, by nlinarith [ Fin.is_lt i ] ⟩;
  · simp +zetaDelta at *;
    exact fun a ha => ⟨ a % k, Nat.mod_lt _ hk, Fin.ext <| by nlinarith [ Nat.mod_add_div a k, Fin.is_lt a ] ⟩;
  · simp +decide [ Nat.add_div, hk ];
    exact fun j hj => by rw [ Nat.div_eq_of_lt hj, if_neg ( Nat.not_le_of_gt ( Nat.mod_lt _ hk ) ) ] ; ring;
  · aesop

/-
Expectation of observables pulled back from a coarse grid is preserved
by the refined uniform probability. This is the key coherence property:
probability is consistent under refinement.

For any `k ≥ 1`, refining the grid `Fin(n+1)` to `Fin(k*(n+1))` by replacing
each point with a block of `k` points preserves the expectation of any
observable lifted via `refineObservable`.
-/
theorem refinement_expectation_invariant (n k : ℕ) (hk : 0 < k) :
    ∀ X : Fin (n + 1) → ℚ,
      NAExpectation (gridUniformProb n) X =
      NAExpectation (uniformFinProb (k * (n + 1)) (by positivity))
        (refineObservable k hk X) := by
  unfold refineObservable
  generalize_proofs at *;
  intro X
  unfold NAExpectation uniformFinProb gridUniformProb
  simp [Finset.sum_mul, div_eq_mul_inv];
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ j : Fin (k * (n + 1)), X ⟨j.val / k, by
    exact?⟩ * (n + 1 : ℚ)⁻¹ * (k : ℚ)⁻¹ = ∑ i : Fin (n + 1), ∑ j ∈ Finset.univ.filter (fun j : Fin (k * (n + 1)) => j.val / k = i.val), X i * (n + 1 : ℚ)⁻¹ * (k : ℚ)⁻¹ := by
    rw [ Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun j _ => ⟨ ⟨ j / k, by solve_by_elim ⟩, j ⟩ ) _ _ _ _ <;> aesop
  generalize_proofs at *;
  simp_all +decide [ ← mul_assoc, Finset.sum_mul _ _ _ ];
  exact Finset.sum_congr rfl fun i hi => by rw [ refine_fiber_card k hk i ] ; simp +decide [ hk.ne', mul_assoc, mul_comm, mul_left_comm ] ;

/-! ## Theorem 4: Convergence to continuum (shadow principle) -/

/-
The grid expectation of `x ↦ a*x + b` on `Fin (n+2)` with uniform
probability converges to `a/2 + b` as `n → ∞`. This is the shadow principle:
infinitesimal atomic probabilities approximate classical continuum probability.
-/
theorem grid_average_converges_affine (a b : ℚ) :
    Filter.Tendsto
      (fun n : ℕ => NAExpectation (gridUniformProb (n + 1))
        (fun i : Fin (n + 2) => a * ((i : ℚ) / (↑n + 2)) + b))
      Filter.atTop
      (nhds (a / 2 + b)) := by
  unfold NAExpectation gridUniformProb;
  simp +decide [ Finset.sum_add_distrib, add_mul, mul_add, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, Finset.sum_const, Finset.card_fin ];
  norm_num [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ( by ring : ( ( Nat.cast:ℕ → ℚ ) _ + 1 + 1 ) = ( Nat.cast:ℕ → ℚ ) _ + 2 ) ];
  -- We'll use the fact that $\sum_{i=0}^{n} i = \frac{n(n+1)}{2}$ to simplify the expression.
  have h_sum : ∀ n : ℕ, ∑ i : Fin (n + 2), (i : ℚ) = (n + 1) * (n + 2) / 2 := by
    exact fun n => by induction n <;> norm_num [ Fin.sum_univ_castSucc ] at * ; linarith;
  -- Substitute the sum formula into the expression.
  simp_rw [h_sum];
  -- Simplify the expression inside the limit.
  suffices h_simp : Filter.Tendsto (fun n : ℕ => a / 2 * (1 - 1 / (n + 2 : ℚ)) + b) Filter.atTop (nhds (a / 2 + b)) by
    grind +suggestions;
  exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.mul ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop ( Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) ) ) ) tendsto_const_nhds ) ( by norm_num )

/-! ## Theorem 5: Impossibility of equal positive atoms on ℕ -/

/-
There is no finitely additive real-valued probability on `ℕ` that assigns
every singleton the same positive mass and has all finite subsets with mass ≤ 1.
This marks the exact frontier where non-Archimedean probability departs from
the classical Kolmogorov framework.

The proof uses the Archimedean property: if `ε > 0`, then for `N > 1/ε`,
a set of `N` disjoint singletons has mass `N*ε > 1`, contradicting bounded
total mass.
-/
theorem no_equal_positive_atoms_nat :
    ¬ ∃ (ε : ℝ) (_ : 0 < ε) (μ : Finset ℕ → ℝ),
      (∀ n : ℕ, μ {n} = ε) ∧
      (∀ s t : Finset ℕ, Disjoint s t → μ (s ∪ t) = μ s + μ t) ∧
      (∀ s : Finset ℕ, μ s ≤ 1) := by
  by_contra h
  obtain ⟨ε, hε_pos, μ, hμ_singleton, hμ_additive, hμ_le_one⟩ := h;
  -- By finite additivity and induction, we have $\mu(\text{Finset.range } N) = N \cdot \epsilon$.
  have h_mu_range : ∀ N : ℕ, μ (Finset.range N) = N * ε := by
    intro N; induction' N with N ih <;> simp_all +decide [ Finset.range_add_one ] ;
    · simpa using hμ_additive ∅ ∅;
    · rw [ Finset.insert_eq, hμ_additive ] <;> norm_num [ ih, hμ_singleton ] ; ring;
  exact absurd ( hμ_le_one ( Finset.range ( ⌊ε⁻¹⌋₊ + 1 ) ) ) ( by push_cast [ h_mu_range ] ; nlinarith [ Nat.lt_floor_add_one ε⁻¹, mul_inv_cancel₀ ( ne_of_gt hε_pos ) ] )