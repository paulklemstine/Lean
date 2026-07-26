import Mathlib

/-!
# Spectral Decay Transfer Theorem for Pseudorandomness

This file establishes the abstract spectral-to-fooling transfer theorem:
if a linear operator preserves a graded family of test subspaces and contracts
degree-`k` centered observables by at most `ρ^k`, then `n` iterations of the
operator give `(ρ^k)^n` decay. This is the formal engine underlying
pseudorandomness guarantees for arithmetic random walks, including the
Berggren walk on Pythagorean triples.

## Main Results

* `iterate_norm_bound` — If `T` contracts a submodule `W` by factor `c`,
  then `T^n` contracts `W` by `c^n`. Works for any seminormed module.

* `bias_bound_of_spectral_decay` — The graded spectral decay theorem:
  degree-`k` centered observables are fooled with bias `(ρ^k)^n` after
  `n` steps.

* `berggren_sibling_spectral_decay` — Specialization to the Berggren
  sibling walk on `Fin 3`, recovering the `(1/2)^n` mixing bound.

## Mathematical Significance

This creates a formal bridge between:
- spectral gap estimates for averaging operators,
- exponential mixing of structured observables,
- pseudorandomness against low-complexity test classes.

The abstract theorem is reusable for any finitely generated semigroup walk
with a graded observable filtration, making it a launchpad for formal
complexity-theoretic derandomization from arithmetic dynamics.
-/

noncomputable section

open Finset BigOperators Function

namespace SpectralPseudorandomness

/-! ## Part 1: Abstract Operator Iteration Bound

The core engine: if a linear operator `T` contracts norms on a submodule `W`
by a factor `c` in one step, then `n` iterations contract by `c^n`.
This works for any seminormed module over `ℝ`.
-/

/-
**Abstract spectral iteration bound.** If a linear endomorphism `T` preserves
a submodule `W` and satisfies `‖T v‖ ≤ c * ‖v‖` for all `v ∈ W`, then
`‖T^n v‖ ≤ c^n * ‖v‖` for all `v ∈ W` and all `n`.
-/
theorem iterate_norm_bound
    {V : Type*} [SeminormedAddCommGroup V] [Module ℝ V]
    (T : V →ₗ[ℝ] V)
    (W : Submodule ℝ V)
    (c : ℝ) (hc : 0 ≤ c)
    (hW : ∀ v ∈ W, T v ∈ W)
    (hT : ∀ v ∈ W, ‖T v‖ ≤ c * ‖v‖)
    (n : ℕ) :
    ∀ v ∈ W, ‖(⇑T)^[n] v‖ ≤ c ^ n * ‖v‖ := by
  induction' n with n ih <;> simp_all +decide [ pow_succ', mul_assoc, mul_add, Function.iterate_succ_apply' ];
  exact fun v hv => le_trans ( hT _ ( by exact Nat.recOn n hv fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using hW _ ihn ) ) ( mul_le_mul_of_nonneg_left ( ih _ hv ) hc )

/-! ## Part 2: Mean-Zero Preservation Lemma

Helper lemma establishing that iterated application of a mean-preserving
operator preserves the mean-zero property.
-/

/-
If `T` preserves sums, then `T` preserves mean-zero.
-/
theorem mean_zero_preserved_of_sum_preserved
    {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (hmean : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (f : α → ℝ) (hf : ∑ x, f x = 0) :
    ∑ x, (T f) x = 0 := by
  rw [ hmean, hf ]

/-
Iterated application of a sum-preserving operator preserves mean-zero.
-/
theorem iterate_mean_zero_preserved
    {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (hmean : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (f : α → ℝ) (hf : ∑ x, f x = 0) (n : ℕ) :
    ∑ x, ((⇑T)^[n] f) x = 0 := by
  induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-
Iterated application of a submodule-preserving map stays in the submodule.
-/
theorem iterate_mem_of_mem
    {V : Type*}
    (T : V → V) (W : Set V)
    (hW : ∀ v ∈ W, T v ∈ W)
    (v : V) (hv : v ∈ W) (n : ℕ) :
    T^[n] v ∈ W := by
  exact Nat.recOn n hv fun n ih => by simpa only [ Function.iterate_succ_apply' ] using hW _ ih;

/-! ## Part 3: Graded Spectral Decay Transfer Theorem

The main theorem: if a Markov averaging operator preserves a graded family
of test spaces and acts on degree-`k` centered tests with operator norm
at most `ρ^k`, then every centered degree-`k` test has exponentially
decaying bias under `n` steps of the operator.
-/

/-
**Spectral-to-fooling transfer theorem.** If a Markov averaging operator
preserves a graded family of test spaces and acts on degree-`k` centered tests
with operator norm at most `ρ^k`, then the bias of any centered degree-`k` test
after `n` steps decays by `(ρ^k)^n`.

This is the abstract engine underlying pseudorandomness guarantees for
arithmetic random walks, including Berggren walks on Pythagorean triples.
-/
theorem bias_bound_of_spectral_decay
    {α : Type*} [Fintype α] [DecidableEq α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (degSpace : ℕ → Submodule ℝ (α → ℝ))
    (ρ : ℝ)
    (hpres : ∀ k, Submodule.map T (degSpace k) ≤ degSpace k)
    (hmean_zero_pres :
      ∀ f, (∑ x, (T f) x) = ∑ x, f x)
    (hnorm :
      ∀ k, ∀ f ∈ degSpace k,
        (∑ x, f x = 0) →
        ‖T f‖ ≤ (ρ ^ k) * ‖f‖)
    (hρ : 0 ≤ ρ ∧ ρ ≤ 1) :
    ∀ k n, ∀ f ∈ degSpace k,
      (∑ x, f x = 0) →
      ‖(⇑T)^[n] f‖ ≤ ((ρ ^ k) ^ n) * ‖f‖ := by
  intro k n f hf hf_mean_zero
  induction' n with n ih generalizing f;
  · simp +decide;
  · exact le_trans ( ih _ ( hpres k ( Submodule.mem_map_of_mem hf ) ) ( by simp +decide [ hmean_zero_pres, hf_mean_zero ] ) ) ( mul_le_mul_of_nonneg_left ( hnorm _ _ hf hf_mean_zero ) ( by exact pow_nonneg ( pow_nonneg hρ.left _ ) _ ) ) |> le_trans <| by ring_nf; norm_num;

/-! ## Part 4: Berggren Sibling Walk Specialization

We specialize the abstract theorem to the Berggren sibling walk on `Fin 3`,
recovering the `(1/2)^n` mixing bound from the spectral contraction of the
complete graph `K₃` transition operator.
-/

/-- The Berggren sibling transition matrix on `Fin 3`:
    from any vertex, go to each of the other two with probability `1/2`. -/
def berggrenSiblingMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  Matrix.of fun i j => if i = j then (0 : ℝ) else 1 / 2

/-- The sibling transition as a linear map on functions `Fin 3 → ℝ`. -/
def berggrenSiblingOp : (Fin 3 → ℝ) →ₗ[ℝ] (Fin 3 → ℝ) where
  toFun f := berggrenSiblingMatrix.mulVec f
  map_add' f g := by simp [Matrix.mulVec_add]
  map_smul' c f := by simp [Matrix.mulVec_smul]

/-
The sibling operator preserves the sum of function values (doubly stochastic).
-/
theorem berggrenSiblingOp_preserves_sum (f : Fin 3 → ℝ) :
    ∑ x, (berggrenSiblingOp f) x = ∑ x, f x := by
  unfold berggrenSiblingOp; norm_num [ Fin.sum_univ_succ ] ; ring!;
  norm_num [ Fin.sum_univ_succ, Fin.prod_univ_succ, berggrenSiblingMatrix ] ; ring!;
  norm_num [ Fin.sum_univ_succ, Matrix.mulVec ] ; ring!;
  simpa [ Fin.sum_univ_three, dotProduct ] using by ring!;

/-
For mean-zero `f`, the sibling operator acts as multiplication by `-1/2`.
-/
theorem berggrenSiblingOp_meanZero (f : Fin 3 → ℝ)
    (hf : ∑ x, f x = 0) (i : Fin 3) :
    berggrenSiblingOp f i = -(1 / 2) * f i := by
  unfold berggrenSiblingOp;
  simp +decide [ Fin.sum_univ_three, Matrix.mulVec, berggrenSiblingMatrix ] at *;
  fin_cases i <;> simp +decide [ dotProduct, Fin.sum_univ_three ] <;> linarith!

/-
The sibling operator contracts the sup norm of mean-zero functions by `1/2`.
-/
theorem berggrenSiblingOp_norm_contraction (f : Fin 3 → ℝ)
    (hf : ∑ x, f x = 0) :
    ‖berggrenSiblingOp f‖ ≤ (1 / 2) * ‖f‖ := by
  -- By definition of $berggrenSiblingOp$, we know that for any mean-zero $f$, $\berggrenSiblingOp f (i) = -(1/2) * f (i)$.
  have h_op : ∀ i, (berggrenSiblingOp f) i = -(1 / 2) * f i := by
    exact fun i => berggrenSiblingOp_meanZero f hf i;
  norm_num [ Norm.norm, h_op ];
  norm_num [ Fin.univ_succ ]

/-
**Berggren sibling spectral decay**: The iterated sibling walk contracts
centered observables by `(1/2)^n`. This is the concrete pseudorandomness
bound for the Berggren arithmetic random walk on `K₃`.
-/
theorem berggren_sibling_spectral_decay (f : Fin 3 → ℝ)
    (hf : ∑ x, f x = 0) (n : ℕ) :
    ‖(⇑berggrenSiblingOp)^[n] f‖ ≤ (1 / 2) ^ n * ‖f‖ := by
  induction' n with n ih generalizing f <;> norm_num [ Function.iterate_succ', pow_succ' ];
  refine' le_trans ( ih _ _ ) _;
  · convert berggrenSiblingOp_preserves_sum f using 1;
    exact hf.symm;
  · convert mul_le_mul_of_nonneg_left ( berggrenSiblingOp_norm_contraction f hf ) ( by positivity : 0 ≤ ( 1 / 2 : ℝ ) ^ n ) using 1 ; ring

end SpectralPseudorandomness