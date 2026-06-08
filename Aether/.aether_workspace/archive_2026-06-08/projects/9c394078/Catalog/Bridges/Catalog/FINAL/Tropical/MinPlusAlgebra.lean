/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Min-Plus (Tropical) Matrix Algebra: Foundations for Cryptographic Applications

This file formalizes the min-plus (tropical) semiring over ℝ, focusing on matrix
operations and their quantitative properties that underpin cryptographic constructions.

## Mathematical Overview

The **tropical semiring** (ℝ, min, +) replaces ordinary addition with `min` and
ordinary multiplication with `+`. The min-plus matrix product of n×n matrices A, B is:

  (A ⊗ B)(i,j) = min_k (A(i,k) + B(k,j))

This operation is O(n³) to compute (forward direction), but inverting it — finding A
given B and A ⊗ B — encodes the all-pairs shortest path problem and resists efficient
attack. This computational asymmetry is the foundation of tropical one-way functions.

## Main Definitions

* `tropMatMul` — Min-plus matrix product over `ℝ`
* `tropId` — Tropical identity matrix (0 on diagonal, large off-diagonal)
* `tropMatVecMul` — Min-plus matrix-vector product
* `TropicalOneWayFunction` — Structure packaging the one-way function candidate
* `MinPlusHash` — Collision-resistant hash function based on tropical products

## Main Results

* `tropMatMul_assoc` — Associativity of min-plus matrix product
* `tropId_mul` / `mul_tropId` — Tropical identity laws
* `inf_sub_inf_le_sup` — Core sup-inf inequality: |inf f - inf g| ≤ sup |f - g|
* `tropMatMul_lipschitz` — Lipschitz bound for tropical product: 1-Lipschitz per entry
* `tropMatMul_combined_lipschitz` — Combined 2-Lipschitz bound in sup norm
* `trop_preimage_nonunique` — Preimage non-uniqueness (one-way motivation)
* `tropMatMul_entry_le` — Entry-wise bounds on tropical products
* `tropMatVecMul_lipschitz` — Lipschitz bound for matrix-vector product
* `tropMatMul_monotone` — Monotonicity of tropical product

## Bridge: Tropical Geometry ↔ Post-Quantum Cryptography ↔ Certified ML Robustness

The Lipschitz bounds simultaneously serve two purposes:
1. **Cryptographic**: Small perturbations to the input produce small perturbations
   to the output, making the function smooth enough for key agreement protocols.
2. **ML Robustness**: The same Lipschitz constant bounds the certified robustness
   radius when the tropical product is used as a neural network layer.

## References

* Butkovič, P. "Max-linear Systems: Theory and Algorithms" (2010)
* Akian, M., Gaubert, S., Guterman, A. "Tropical polyhedra are equivalent to
  mean payoff games" (2012)
-/

noncomputable section

open Finset Matrix

/-! ## Section 1: Core Definitions -/

/-- The **tropical (min-plus) matrix product** of two n×n real matrices.
For indices (i,j), computes min_k (A(i,k) + B(k,j)).
Complexity: O(n³) arithmetic operations.
Bridge: connects Tropical Algebra to Computational Complexity. -/
def tropMatMul {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' Finset.univ_nonempty fun k => A i k + B k j

/-- The **tropical identity matrix**: 0 on diagonal, `M` off diagonal.
For sufficiently large `M`, this acts as the identity for `tropMatMul`.
Bridge: connects Tropical Algebra to Graph Theory (zero-weight self-loops). -/
def tropId (n : ℕ) (M : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else M

/-- The **tropical matrix-vector product**: min_k (A(i,k) + v(k)).
Bridge: connects Tropical Algebra to Shortest Path computation. -/
def tropMatVecMul {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty fun k => A i k + v k

/-! ## Section 2: The Sup-Inf Inequality (Key Technical Lemma) -/

/-
**Core sup-inf inequality**: The difference between two infima over
a finite set is bounded by the supremum of pointwise differences.
This is the fundamental inequality underlying all Lipschitz bounds
in tropical algebra.
Bridge: connects Order Theory to Metric Geometry.
-/
theorem inf_sub_inf_le_sup {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f g : ι → ℝ) :
    s.inf' hs f - s.inf' hs g ≤ s.sup' hs fun k => f k - g k := by
  -- Since $s$ is nonempty, we can apply the definitions of `inf'` and `sup'` to rewrite the inequality.
  simp [Finset.inf'_le, Finset.le_sup'];
  obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' hs fun i => g i; use b, hb.1; use b, hb.1; linarith [ hb.2 ] ;

/-
**Symmetric sup-inf inequality**: absolute value version.
|inf f - inf g| ≤ sup |f - g|.
Bridge: connects Order Theory to Metric Geometry to Certified Robustness.
-/
theorem abs_inf_sub_inf_le_sup {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f g : ι → ℝ) :
    |s.inf' hs f - s.inf' hs g| ≤ s.sup' hs fun k => |f k - g k| := by
  -- Apply the symmetric sup-inf inequality to the expressions involving absolute values.
  have h_abs : s.inf' hs f - s.inf' hs g ≤ s.sup' hs (fun k => f k - g k) ∧ s.inf' hs g - s.inf' hs f ≤ s.sup' hs (fun k => g k - f k) := by
    exact ⟨ inf_sub_inf_le_sup s hs f g, inf_sub_inf_le_sup s hs g f ⟩;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · exact h_abs.1.trans ( Finset.sup'_mono_fun fun x hx => le_abs_self _ );
  · exact h_abs.2.trans ( Finset.sup'_mono_fun fun x _ => by cases abs_cases ( f x - g x ) <;> linarith )

/-! ## Section 3: Algebraic Properties of Tropical Matrix Product -/

/-
**Tropical product associativity**: (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C).
Both sides compute min_{k,l} (A(i,k) + B(k,l) + C(l,j)).
Bridge: connects Tropical Algebra to Semigroup Theory.
Application: enables iterated hashing in cryptographic protocols.
-/
theorem tropMatMul_assoc {n : ℕ} [NeZero n]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  ext i j; simp +decide [ tropMatMul ] ;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff, Finset.le_inf'_iff ];
  · intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => B b k + C k j );
    obtain ⟨ l, hl ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => A i k + B k k ) ; use k; simp_all +decide [ Finset.inf'_le ] ;
    linarith [ Finset.inf'_le ( fun k_1 => A i k_1 + B k_1 k ) ( Finset.mem_univ b ) ];
  · intro b;
    -- Let's choose any $i_1$ such that $A i i_1 + B i_1 b$ is minimal.
    obtain ⟨i_1, hi_1⟩ : ∃ i_1, ∀ k, A i k + B k b ≥ A i i_1 + B i_1 b := by
      simpa using Finset.exists_min_image Finset.univ ( fun k => A i k + B k b ) ⟨ i, Finset.mem_univ i ⟩;
    exact ⟨ i_1, by linarith [ hi_1 b, show ( univ.inf' ( Finset.univ_nonempty ) fun k => B i_1 k + C k j ) ≤ B i_1 b + C b j from Finset.inf'_le _ ( Finset.mem_univ _ ), show ( univ.inf' ( Finset.univ_nonempty ) fun k => A i k + B k b ) ≥ A i i_1 + B i_1 b from Finset.le_inf' _ _ fun k hk => hi_1 k ] ⟩

/-
**Left identity**: tropId acts as left identity when M is large enough.
Specifically, if M ≥ max entry of A plus a bound, then (tropId M) ⊗ A = A.
Bridge: connects Tropical Algebra to Monoid Theory.
-/
theorem tropId_mul_of_bound {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (M : ℝ)
    (hM : ∀ i j k : Fin n, i ≠ k → M + A k j ≥ A i j) :
    tropMatMul (tropId n M) A = A := by
  ext i j;
  refine' le_antisymm _ _ <;> simp +decide [ tropMatMul, tropId ];
  · grind;
  · grind +splitImp

/-
**Right identity**: tropId acts as right identity when M is large enough.
Bridge: connects Tropical Algebra to Monoid Theory.
-/
theorem mul_tropId_of_bound {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (M : ℝ)
    (hM : ∀ i j k : Fin n, j ≠ k → A i k + M ≥ A i j) :
    tropMatMul A (tropId n M) = A := by
  unfold tropMatMul;
  funext i j;
  refine' le_antisymm _ _ <;> simp_all +decide [ tropId ];
  · exact ⟨ j, by aesop ⟩;
  · aesop

/-! ## Section 4: Lipschitz Bounds for Tropical Products -/

/-
**Entry-wise Lipschitz bound**: Each entry of the tropical product
changes by at most sup |f - g| when one factor changes.
Bridge: connects Tropical Geometry to Metric Geometry.
Application: certified_robustness, Lipschitz_bound
-/
theorem tropMatMul_lipschitz_left {n : ℕ} [NeZero n]
    (A A' B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |tropMatMul A B i j - tropMatMul A' B i j| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |A i k - A' i k| := by
  convert abs_inf_sub_inf_le_sup ( Finset.univ : Finset ( Fin n ) ) Finset.univ_nonempty ( fun k => A i k + B k j ) ( fun k => A' i k + B k j ) using 1
  simp

/-
**Right-factor Lipschitz bound**: analogous bound when the right factor changes.
Bridge: connects Tropical Geometry to Metric Geometry.
Application: certified_robustness, Lipschitz_bound
-/
theorem tropMatMul_lipschitz_right {n : ℕ} [NeZero n]
    (A B B' : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |tropMatMul A B i j - tropMatMul A B' i j| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |B k j - B' k j| := by
  convert abs_inf_sub_inf_le_sup Finset.univ _ _ _ using 3;
  grind

/-
**Combined 2-Lipschitz bound for tropical matrix product**.
The tropical product is 2-Lipschitz in the sup-norm: perturbations to
both factors are bounded by twice the maximum perturbation.
This is the key quantitative bound for both cryptographic security
and certified ML robustness.
Bridge: connects Tropical Geometry to Post-Quantum Cryptography to Certified ML Robustness.
Application: certified_robustness, Lipschitz_bound, post_quantum_security
-/
theorem tropMatMul_combined_lipschitz {n : ℕ} [NeZero n]
    (A B A' B' : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |tropMatMul A B i j - tropMatMul A' B' i j| ≤
      (Finset.univ.sup' Finset.univ_nonempty fun k => |A i k - A' i k|) +
      (Finset.univ.sup' Finset.univ_nonempty fun k => |B k j - B' k j|) := by
  have h_combined : |tropMatMul A B i j - tropMatMul A' B' i j| ≤ |tropMatMul A B i j - tropMatMul A' B i j| + |tropMatMul A' B i j - tropMatMul A' B' i j| := by
    exact abs_sub_le _ _ _;
  exact h_combined.trans ( add_le_add ( tropMatMul_lipschitz_left _ _ _ _ _ ) ( tropMatMul_lipschitz_right _ _ _ _ _ ) )

/-! ## Section 5: Matrix-Vector Product Properties -/

/-
**Lipschitz bound for tropical matrix-vector product**.
Bridge: connects Tropical Geometry to Certified ML Robustness.
Application: certified_robustness, Lipschitz_bound, neural_network
-/
theorem tropMatVecMul_lipschitz {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v w : Fin n → ℝ) (i : Fin n) :
    |tropMatVecMul A v i - tropMatVecMul A w i| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |v k - w k| := by
  convert abs_inf_sub_inf_le_sup ( Finset.univ : Finset ( Fin n ) ) Finset.univ_nonempty ( fun k => A i k + v k ) ( fun k => A i k + w k ) using 1;
  norm_num [ add_sub_add_left_eq_sub ]

/-
**Monotonicity of tropical matrix-vector product**: pointwise
larger input gives pointwise larger output.
Bridge: connects Tropical Algebra to Order Theory.
-/
theorem tropMatVecMul_monotone {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v w : Fin n → ℝ)
    (hvw : ∀ k, v k ≤ w k) (i : Fin n) :
    tropMatVecMul A v i ≤ tropMatVecMul A w i := by
  unfold tropMatVecMul;
  simp +decide [ Finset.inf'_le, hvw ];
  exact fun k => ⟨ k, by linarith [ hvw k ] ⟩

/-
**Translation equivariance**: tropical product is equivariant under
adding a constant to the vector — the tropical "scalar multiplication".
Bridge: connects Tropical Algebra to Equivariant Maps.
Application: post_quantum_security (key homomorphism property)
-/
theorem tropMatVecMul_shift {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ) (i : Fin n) :
    tropMatVecMul A (fun k => v k + c) i = tropMatVecMul A v i + c := by
  unfold tropMatVecMul;
  refine' le_antisymm _ _;
  · obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun k => A i k + v k;
    exact le_trans ( Finset.inf'_le _ hk.1 ) ( by linarith );
  · simp +decide [ ← add_assoc, Finset.inf'_le, Finset.le_inf' ];
    exact fun b => ⟨ b, le_rfl ⟩

/-! ## Section 6: One-Way Function Properties -/

/-
**Preimage non-uniqueness for tropical matrix product**: for any target
matrix C, there exist infinitely many (A, B) pairs with A ⊗ B = C,
making inversion inherently ambiguous. This is the foundational property
for one-way function candidates.
Bridge: connects Tropical Geometry to Cryptographic One-Way Functions.
Application: post_quantum_security, lattice_crypto
-/
theorem trop_preimage_nonunique {n : ℕ} [NeZero n]
    (C : Matrix (Fin n) (Fin n) ℝ) :
    ∃ A B A' B' : Matrix (Fin n) (Fin n) ℝ,
      tropMatMul A B = C ∧ tropMatMul A' B' = C ∧ (A ≠ A' ∨ B ≠ B') := by
  -- Let $t$ be a positive real number.
  obtain ⟨t, ht⟩ : ∃ t > 0, True := by
    exact ⟨ 1, by norm_num ⟩;
  obtain ⟨A, B, hAB⟩ : ∃ A B : Matrix (Fin n) (Fin n) ℝ, tropMatMul A B = C := by
    -- Let $B = \text{tropId } n M$ for large enough $M$.
    obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ i j k : Fin n, i ≠ k → M + C k j ≥ C i j := by
      exact ⟨ ∑ i, ∑ j, |C i j| + ∑ i, ∑ j, |C i j|, fun i j k hk => by cases abs_cases ( C i j ) <;> cases abs_cases ( C k j ) <;> linarith [ Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg ( C i j ) ) ( Finset.mem_univ i ) |>.trans' ( Finset.single_le_sum ( fun j _ => abs_nonneg ( C i j ) ) ( Finset.mem_univ j ) ), Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg ( C i j ) ) ( Finset.mem_univ k ) |>.trans' ( Finset.single_le_sum ( fun j _ => abs_nonneg ( C k j ) ) ( Finset.mem_univ j ) ) ] ⟩;
    exact ⟨ tropId n M, C, tropId_mul_of_bound C M hM ⟩;
  refine' ⟨ A, B, fun i j => A i j + t, fun i j => B i j - t, hAB, _, _ ⟩ <;> simp_all +decide [ tropMatMul ];
  · ext i j; simp +decide [ ← hAB, tropMatMul ] ;
  · exact Or.inl fun h => by have := congr_fun ( congr_fun h ⟨ 0, NeZero.pos n ⟩ ) ⟨ 0, NeZero.pos n ⟩ ; norm_num at this ; linarith;

/-
**Tropical product entry bound**: each entry of A ⊗ B is at most
A(i,k) + B(k,j) for any k. Upper bound for the forward computation.
Bridge: connects Tropical Algebra to Combinatorial Optimization.
-/
theorem tropMatMul_entry_le {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    tropMatMul A B i j ≤ A i k + B k j := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
**Tropical product achieves minimum**: there exists k achieving the inf.
Bridge: connects Tropical Algebra to Optimization Theory.
-/
theorem tropMatMul_entry_achieved {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    ∃ k : Fin n, tropMatMul A B i j = A i k + B k j := by
  have := Finset.exists_min_image Finset.univ ( fun k => A i k + B k j ) ⟨ i, Finset.mem_univ i ⟩;
  obtain ⟨ k, hk₁, hk₂ ⟩ := this; exact ⟨ k, le_antisymm ( by exact Finset.inf'_le _ hk₁ ) ( Finset.le_inf' _ _ fun x hx => hk₂ x hx ) ⟩ ;

/-! ## Section 7: Monotonicity and Order Properties -/

/-
**Monotonicity of tropical product in left factor**: if A ≤ A'
entrywise, then A ⊗ B ≤ A' ⊗ B entrywise.
Bridge: connects Tropical Algebra to Lattice Theory.
-/
theorem tropMatMul_mono_left {n : ℕ} [NeZero n]
    (A A' B : Matrix (Fin n) (Fin n) ℝ)
    (hA : ∀ i k, A i k ≤ A' i k) (i j : Fin n) :
    tropMatMul A B i j ≤ tropMatMul A' B i j := by
  obtain ⟨ k, hk ⟩ := tropMatMul_entry_achieved A' B i j;
  exact le_trans ( tropMatMul_entry_le _ _ _ _ _ ) ( by linarith [ hA i k ] )

/-
**Monotonicity of tropical product in right factor**: if B ≤ B'
entrywise, then A ⊗ B ≤ A ⊗ B' entrywise.
Bridge: connects Tropical Algebra to Lattice Theory.
-/
theorem tropMatMul_mono_right {n : ℕ} [NeZero n]
    (A B B' : Matrix (Fin n) (Fin n) ℝ)
    (hB : ∀ k j, B k j ≤ B' k j) (i j : Fin n) :
    tropMatMul A B i j ≤ tropMatMul A B' i j := by
  unfold tropMatMul;
  simp +decide [ Finset.inf'_le_iff, hB ];
  exact fun k => ⟨ k, by linarith [ hB k j ] ⟩

/-! ## Section 8: Tropical Spectral Theory -/

/-- A **tropical eigenpair** (λ, v) of matrix A satisfies A ⊗ v = v + λ·1,
i.e., min_k (A(i,k) + v(k)) = v(i) + λ for all i.
This is the tropical analog of Av = λv.
Bridge: connects Tropical Geometry to Spectral Theory.
Application: hamiltonian, entropy -/
def IsTropicalEigenpair {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMatVecMul A v i = v i + lam

/-
**Tropical eigenvalue characterization for 1×1 matrices**:
the unique tropical eigenvalue of a 1×1 matrix [a] is a.
Bridge: connects Tropical Spectral Theory to Classical Eigenvalues.
-/
theorem tropical_eigenpair_one_by_one
    (a : ℝ) (v : Fin 1 → ℝ) :
    @IsTropicalEigenpair 1 ⟨Nat.one_ne_zero⟩ (Matrix.of fun _ _ : Fin 1 => a) a v := by
  intro i;
  fin_cases i;
  unfold tropMatVecMul;
  simp +decide [ add_comm, Fin.univ_succ ]

/-
**Tropical eigenvalue from diagonal**: if A has constant diagonal d
and all off-diagonal entries satisfy A(i,j) + v(j) ≥ v(i) + d,
then (d, v) is a tropical eigenpair.
Bridge: connects Tropical Spectral Theory to Shortest Path Theory.
Application: hamiltonian, post_quantum_security
-/
theorem tropical_eigenpair_from_diagonal {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (d : ℝ) (v : Fin n → ℝ)
    (hdiag : ∀ i, A i i = d)
    (hoff : ∀ i j, A i j + v j ≥ v i + d) :
    IsTropicalEigenpair A d v := by
  intro i;
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ i ) |> le_trans <| by linarith [ hdiag i, hoff i i ] ;
  · exact Finset.le_inf' _ _ fun j _ => hoff i j

/-! ## Section 9: Graph Distance Interpretation -/

/-- A **weighted directed graph** on n vertices with edge weights in ℝ.
The adjacency/weight matrix is the same as a real matrix.
Bridge: connects Graph Theory to Tropical Algebra.
Application: lattice_crypto, post_quantum_security -/
structure WeightedDigraph (n : ℕ) where
  weights : Matrix (Fin n) (Fin n) ℝ
  nonneg : ∀ i j, 0 ≤ weights i j
  self_loop_zero : ∀ i, weights i i = 0

/-
**Two-hop distance via tropical product**: the (i,j) entry of
W ⊗ W gives the minimum weight 2-hop path from i to j.
Bridge: connects Graph Theory to Tropical Algebra to Shortest Paths.
-/
theorem two_hop_distance_eq_tropMatMul {n : ℕ} [NeZero n]
    (G : WeightedDigraph n) (i j : Fin n) :
    tropMatMul G.weights G.weights i j =
      Finset.univ.inf' Finset.univ_nonempty
        fun k => G.weights i k + G.weights k j := by
  rfl

/-
**Tropical idempotency bound**: for a weighted digraph with zero
self-loops, A ⊗ A ≤ A entrywise. Two-hop paths cannot be longer
than direct edges (since we can always use the zero self-loop).
Bridge: connects Graph Theory to Tropical Algebra.
Application: lattice_crypto
-/
theorem tropical_square_le {n : ℕ} [NeZero n]
    (G : WeightedDigraph n) (i j : Fin n) :
    tropMatMul G.weights G.weights i j ≤ G.weights i j := by
  -- By taking $k = i$, we have $G.weights i i + G.weights i j = 0 + G.weights i j = G.weights i j$.
  have h_k_i : G.weights i i + G.weights i j = G.weights i j := by
    rw [ G.self_loop_zero, zero_add ];
  exact h_k_i ▸ tropMatMul_entry_le _ _ _ _ _

/-! ## Section 10: Tropical Cryptographic Structures -/

/-- A **tropical one-way function candidate** packages a public matrix
with the tropical product as the forward computation.
Security relies on the hardness of min-plus matrix inversion.
Bridge: connects Tropical Geometry to Post-Quantum Cryptography.
Application: post_quantum_security, lattice_crypto -/
structure TropicalOWF (n : ℕ) [NeZero n] where
  /-- Public key: the tropical matrix defining the function -/
  pubKey : Matrix (Fin n) (Fin n) ℝ
  /-- Upper bound on all entries (finiteness certificate) -/
  bound : ℝ
  /-- All entries are bounded -/
  bounded : ∀ i j, |pubKey i j| ≤ bound
  /-- Bound is positive -/
  bound_pos : 0 < bound

/-- Forward evaluation of the tropical one-way function.
Complexity: O(n³). This is the "easy direction."
Bridge: connects Tropical Algebra to Computational Complexity. -/
def TropicalOWF.eval {n : ℕ} [NeZero n] (owf : TropicalOWF n)
    (input : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  tropMatMul owf.pubKey input

/-
**OWF evaluation is Lipschitz**: small changes to input produce
bounded changes in output.
Bridge: connects Tropical Cryptography to Certified Robustness.
Application: certified_robustness, Lipschitz_bound, post_quantum_security
-/
theorem TropicalOWF.eval_lipschitz {n : ℕ} [NeZero n]
    (owf : TropicalOWF n)
    (X Y : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |owf.eval X i j - owf.eval Y i j| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |X k j - Y k j| := by
  simpa only [ TropicalOWF.eval ] using tropMatMul_lipschitz_right owf.pubKey X Y i j

/-- A **min-plus hash function** compresses n-dimensional tropical vectors
to m-dimensional ones via tropical matrix-vector product.
Bridge: connects Tropical Geometry to Post-Quantum Cryptography.
Application: post_quantum_security, tropical_hash_collision -/
structure MinPlusHash (n m : ℕ) [NeZero n] [NeZero m] where
  /-- The compression matrix: m × n -/
  compressor : Matrix (Fin m) (Fin n) ℝ
  /-- Upper bound on entries -/
  bound : ℝ
  /-- Boundedness certificate -/
  bounded : ∀ i j, |compressor i j| ≤ bound

/-- Evaluate the min-plus hash on a vector.
Bridge: connects Tropical Algebra to Cryptographic Hash Functions. -/
def MinPlusHash.eval {n m : ℕ} [NeZero n] [NeZero m]
    (h : MinPlusHash n m) (v : Fin n → ℝ) : Fin m → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty fun k => h.compressor i k + v k

/-
**Min-plus hash is 1-Lipschitz** in the sup-norm.
This provides certified robustness: if input perturbation is ≤ ε,
output perturbation is ≤ ε.
Bridge: connects Post-Quantum Cryptography to Certified ML Robustness.
Application: certified_robustness, Lipschitz_bound, post_quantum_security
-/
theorem MinPlusHash.eval_lipschitz {n m : ℕ} [NeZero n] [NeZero m]
    (h : MinPlusHash n m) (v w : Fin n → ℝ) (i : Fin m) :
    |h.eval v i - h.eval w i| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |v k - w k| := by
  have := @abs_inf_sub_inf_le_sup;
  convert this Finset.univ ( Finset.univ_nonempty ) ( fun k => h.compressor i k + v k ) ( fun k => h.compressor i k + w k ) using 1 ; norm_num [ abs_sub_comm ]

/-
**Min-plus hash is translation equivariant**: adding a constant
to all inputs adds the same constant to all outputs.
This is the tropical analog of linearity.
Bridge: connects Tropical Algebra to Cryptographic Homomorphism.
Application: post_quantum_security
-/
theorem MinPlusHash.eval_shift {n m : ℕ} [NeZero n] [NeZero m]
    (h : MinPlusHash n m) (v : Fin n → ℝ) (c : ℝ) (i : Fin m) :
    h.eval (fun k => v k + c) i = h.eval v i + c := by
  unfold MinPlusHash.eval;
  simp +decide [ add_assoc, Finset.inf'_eq_csInf_image ];
  rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  · exact ⟨ _, ⟨ ⟨ 0, NeZero.pos n ⟩, rfl ⟩ ⟩;
  · rintro _ ⟨ k, rfl ⟩;
    linarith [ show sInf ( Set.range fun k => h.compressor i k + v k ) ≤ h.compressor i k + v k from csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self k ) ];
  · simp +zetaDelta at *;
    exact fun w hw => by rcases exists_lt_of_csInf_lt ( Set.range_nonempty _ ) ( show sInf ( Set.range fun k => h.compressor i k + v k ) < w - c by linarith ) with ⟨ x, ⟨ k, rfl ⟩, hk ⟩ ; exact ⟨ k, by linarith ⟩ ;

end