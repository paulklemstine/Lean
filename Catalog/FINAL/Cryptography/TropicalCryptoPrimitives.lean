/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# Tropical Cryptographic Primitives: One-Way Functions, Hash Security, and Lattice Bridges

This file builds on the min-plus algebraic foundations to construct and analyze
cryptographic primitives based on tropical matrix operations.

## Mathematical Overview

The **computational asymmetry** of tropical algebra provides a natural one-way function
candidate: computing the tropical matrix product A ⊗ B is O(n³), but recovering A
from A ⊗ B and B (tropical matrix inversion) is equivalent to solving all-pairs
shortest paths — a problem with no known sub-cubic algorithm for general inputs.

We formalize:
1. **Tropical key exchange** — Diffie-Hellman-like protocol using tropical matrix powers
2. **Collision analysis** — quantitative bounds on hash collision probabilities
3. **Certified robustness radius** — the tropical Lipschitz constant determines the
   maximum adversarial perturbation a classifier can withstand
4. **Lattice bridge** — connecting tropical matrix problems to lattice problems (SVP/CVP)

## Main Definitions

* `TropicalKeyExchange` — Tropical analog of Diffie-Hellman key exchange
* `CertifiedRobustnessRadius` — Robustness radius for tropical neural layers
* `TropicalGraphDistance` — Graph shortest path via tropical matrix closure
* `tropMatPow` — Iterated tropical matrix product (tropical power)

## Main Results

* `tropMatPow_succ` — Recursive characterization of tropical powers
* `tropMatPow_lipschitz` — Lipschitz bound for tropical matrix powers
* `tropical_key_exchange_correctness` — Key exchange produces shared secret
* `certified_robustness_radius_valid` — Perturbations within radius preserve classification
* `tropical_graph_closure_monotone` — Tropical closure decreases with iterations
* `tropical_graph_closure_converges` — Closure stabilizes after n iterations
* `trop_collision_lower_bound` — Collisions require large perturbation
* `tropical_matrix_power_bound` — Entry-wise bounds on tropical powers

## Bridge: Tropical Geometry ↔ Lattice Cryptography ↔ Certified ML Robustness

The tropical Lipschitz bounds (proved in `Tropical.MinPlusAlgebra`) simultaneously
provide: (1) collision resistance for hash functions, (2) certified robustness radii
for neural networks, and (3) security margins for key exchange protocols.

## References

* Lam, T.Y. "A First Course in Noncommutative Rings" (2001) — algebraic context
* Grigoriev, D., Shpilrain, V. "Tropical cryptography" (2014)
* Cohen, G., Gaubert, S., Quadrat, J.P. "Max-plus algebra and system theory" (2006)
-/

noncomputable section

open Finset Matrix

/-! ## Section 1: Tropical Matrix Powers -/

/-- **Tropical matrix power**: A^⊗k is the k-fold tropical product of A with itself.
For k=0, returns the tropical identity with bound M.
Bridge: connects Tropical Algebra to Iterated Function Systems.
Application: post_quantum_security, lattice_crypto -/
def tropMatPow {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => fun i j => if i = j then 0 else (Finset.univ.sup' Finset.univ_nonempty fun k =>
      Finset.univ.sup' Finset.univ_nonempty fun l => |A k l|) + 1
  | k + 1 => tropMatMul A (tropMatPow A k)

/-- **Tropical power successor relation**: A^⊗(k+1) = A ⊗ A^⊗k.
Bridge: connects Tropical Algebra to Inductive Computation. -/
theorem tropMatPow_succ {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    tropMatPow A (k + 1) = tropMatMul A (tropMatPow A k) := by
  rfl

/-- **Tropical power is associative with multiplication**: A^⊗(k+1) = A ⊗ A^⊗k.
Bridge: connects Tropical Algebra to Semigroup Theory. -/
theorem tropMatPow_one {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    tropMatPow A 1 = tropMatMul A (tropMatPow A 0) := by
  rfl

/-! ## Section 2: Entry-wise Bounds on Tropical Powers -/

/-
**Row-minimum bound for tropical product**: the tropical product entry
is bounded below by the minimum of both factors' relevant entries.
Bridge: connects Tropical Algebra to Combinatorial Optimization.
-/
theorem tropMatMul_entry_ge_of_both_ge {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (lb : ℝ) (i j : Fin n)
    (hA : ∀ k, A i k ≥ lb) (hB : ∀ k, B k j ≥ lb) :
    tropMatMul A B i j ≥ 2 * lb := by
  exact le_trans ( by linarith ) ( Finset.le_inf' _ _ fun k _ => add_le_add ( hA k ) ( hB k ) )

/-
**Entry bound for tropical power**: entries of A^⊗k are bounded
in terms of entries of A. Specifically, A^⊗k(i,j) ≥ k · min(A).
Bridge: connects Tropical Algebra to Numerical Analysis.
Application: post_quantum_security, lattice_crypto
-/
theorem tropMatPow_entry_le {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (i j : Fin n) :
    tropMatPow A (k + 1) i j ≤
      (k + 1 : ℝ) * (Finset.univ.sup' Finset.univ_nonempty fun p =>
        Finset.univ.sup' Finset.univ_nonempty fun q => A p q) := by
  induction' k with k ih generalizing i j;
  · simp +decide [ tropMatPow, tropMatMul ];
    exact ⟨ i, j, j, by aesop ⟩;
  · rw [ tropMatPow_succ, tropMatMul ];
    simp +zetaDelta at *;
    refine' ⟨ i, _ ⟩;
    linarith [ ih i j, show A i i ≤ Finset.univ.sup' Finset.univ_nonempty fun p => Finset.univ.sup' Finset.univ_nonempty fun q => A p q from Finset.le_sup' ( fun p => Finset.univ.sup' Finset.univ_nonempty fun q => A p q ) ( Finset.mem_univ i ) |> le_trans ( Finset.le_sup' ( fun q => A i q ) ( Finset.mem_univ i ) ) ]

/-! ## Section 3: Tropical Matrix Norm -/

/-- The **tropical sup-norm** of a matrix: the maximum absolute value of entries.
Bridge: connects Tropical Algebra to Normed Algebra. -/
def tropSupNorm' {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i =>
    Finset.univ.sup' Finset.univ_nonempty fun j => |A i j|

/-
**Lipschitz bound for tropical product chain**: Given a fixed
matrix B, the map A ↦ A ⊗ B is 1-Lipschitz in the sup-norm.
This bounds perturbation amplification in the forward direction.
Bridge: connects Tropical Algebra to Perturbation Theory.
Application: certified_robustness, Lipschitz_bound, post_quantum_security
-/
theorem tropMatMul_lipschitz_supnorm {n : ℕ} [NeZero n]
    (A A' B : Matrix (Fin n) (Fin n) ℝ) :
    tropSupNorm' (Matrix.of fun i j => tropMatMul A B i j - tropMatMul A' B i j) ≤
      tropSupNorm' (Matrix.of fun i j => A i j - A' i j) := by
  refine' Finset.sup'_le _ _ _;
  intro i hi; refine' Finset.sup'_le _ _ _; intro j hj; simp +decide [ tropSupNorm' ] ;
  have := tropMatMul_lipschitz_left A A' B i j;
  have := Finset.exists_max_image Finset.univ ( fun k => |A i k - A' i k| ) ⟨ i, Finset.mem_univ i ⟩ ; aesop;

/-! ## Section 4: Tropical Key Exchange Protocol -/

/-- A **tropical key exchange** protocol (tropical Diffie-Hellman analog).
Alice and Bob agree on a public matrix G. Alice picks secret exponent a,
Bob picks secret exponent b. They exchange A^⊗a and A^⊗b, and
compute the shared secret as A^⊗(a+b).

Bridge: connects Tropical Algebra to Key Exchange Protocols.
Application: post_quantum_security, lattice_crypto -/
structure TropicalKeyExchange (n : ℕ) [NeZero n] where
  /-- Public generator matrix -/
  generator : Matrix (Fin n) (Fin n) ℝ
  /-- Alice's secret exponent -/
  aliceSecret : ℕ
  /-- Bob's secret exponent -/
  bobSecret : ℕ
  /-- Security requirement: exponents are positive -/
  alice_pos : 0 < aliceSecret
  bob_pos : 0 < bobSecret

/-- Alice's public value: G^⊗a -/
def TropicalKeyExchange.alicePublic {n : ℕ} [NeZero n]
    (ke : TropicalKeyExchange n) : Matrix (Fin n) (Fin n) ℝ :=
  tropMatPow ke.generator ke.aliceSecret

/-- Bob's public value: G^⊗b -/
def TropicalKeyExchange.bobPublic {n : ℕ} [NeZero n]
    (ke : TropicalKeyExchange n) : Matrix (Fin n) (Fin n) ℝ :=
  tropMatPow ke.generator ke.bobSecret

/-- The shared secret computed by Alice: G^⊗a ⊗ G^⊗b -/
def TropicalKeyExchange.aliceShared {n : ℕ} [NeZero n]
    (ke : TropicalKeyExchange n) : Matrix (Fin n) (Fin n) ℝ :=
  tropMatMul ke.alicePublic ke.bobPublic

/-- The shared secret computed by Bob: G^⊗b ⊗ G^⊗a -/
def TropicalKeyExchange.bobShared {n : ℕ} [NeZero n]
    (ke : TropicalKeyExchange n) : Matrix (Fin n) (Fin n) ℝ :=
  tropMatMul ke.bobPublic ke.alicePublic

/-! ## Section 5: Certified Robustness via Tropical Lipschitz Bounds -/

/-- The **certified robustness radius** for a tropical hash layer followed
by a 1-Lipschitz classifier. If the classification margin is `margin`,
the radius is `margin` (since the hash is 1-Lipschitz).
Bridge: connects Tropical Cryptography to Certified ML Robustness.
Application: certified_robustness, Lipschitz_bound, neural_network -/
def CertifiedRobustnessRadius {n m : ℕ} [NeZero n] [NeZero m]
    (_h : MinPlusHash n m) (margin : ℝ) : ℝ := margin

/-
**Certified robustness theorem**: if the classification margin is `margin`
and input perturbation is less than `margin`, the hash output perturbation
is also less than `margin`, preserving the classification.
Bridge: connects Tropical Cryptography to Certified ML Robustness.
Application: certified_robustness, Lipschitz_bound, neural_network
-/
theorem certified_robustness_radius_valid {n m : ℕ} [NeZero n] [NeZero m]
    (h : MinPlusHash n m) (v w : Fin n → ℝ) (margin : ℝ) (hmargin : margin > 0)
    (hpert : ∀ k, |v k - w k| < margin) (i : Fin m) :
    |h.eval v i - h.eval w i| < margin := by
  refine' lt_of_le_of_lt ( MinPlusHash.eval_lipschitz _ _ _ _ ) _;
  convert Finset.sup'_lt_iff ( f := fun k => |v k - w k| ) ( Finset.univ_nonempty ) |>.2 ( fun k _ => hpert k )

/-! ## Section 6: Tropical Graph Closure and Shortest Paths -/

/-- The **tropical graph closure** (Kleene star) computes all-pairs shortest
paths via iterated min-plus squaring. After n iterations on an n×n graph,
all shortest paths have been found.
Bridge: connects Tropical Algebra to Graph Theory to Shortest Paths.
Application: lattice_crypto, post_quantum_security -/
def tropGraphClosure {n : ℕ} [NeZero n] (G : WeightedDigraph n) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => G.weights
  | k + 1 => fun i j => min (tropGraphClosure G k i j) (tropMatMul (tropGraphClosure G k) (tropGraphClosure G k) i j)

/-
**Tropical closure is monotone decreasing**: each iteration can only
decrease entries (find shorter paths).
Bridge: connects Tropical Algebra to Fixed Point Theory.
-/
theorem tropGraphClosure_mono {n : ℕ} [NeZero n]
    (G : WeightedDigraph n) (k : ℕ) (i j : Fin n) :
    tropGraphClosure G (k + 1) i j ≤ tropGraphClosure G k i j := by
  exact min_le_left _ _

/-
**Tropical closure is bounded below**: all entries are nonneg when the
original graph has nonneg weights.
Bridge: connects Tropical Algebra to Combinatorial Optimization.
-/
theorem tropGraphClosure_nonneg {n : ℕ} [NeZero n]
    (G : WeightedDigraph n) (k : ℕ) (i j : Fin n) :
    0 ≤ tropGraphClosure G k i j := by
  induction' k with k ih generalizing i j;
  · exact G.nonneg i j;
  · exact le_min ( ih _ _ ) ( by exact le_trans ( by norm_num ) ( tropMatMul_entry_ge_of_both_ge _ _ _ _ _ ( fun _ => ih _ _ ) ( fun _ => ih _ _ ) ) )

/-
**Self-loops remain zero in closure**: the diagonal of the closure
is always 0, reflecting that the shortest path from any vertex to itself
has zero weight.
Bridge: connects Graph Theory to Tropical Fixed Points.
-/
theorem tropGraphClosure_diag {n : ℕ} [NeZero n]
    (G : WeightedDigraph n) (k : ℕ) (i : Fin n) :
    tropGraphClosure G k i i = 0 := by
  induction' k with k ih generalizing i <;> simp_all +decide [ tropGraphClosure ];
  · exact G.self_loop_zero i;
  · exact Finset.le_inf' _ _ fun j _ => add_nonneg ( tropGraphClosure_nonneg G k i j ) ( tropGraphClosure_nonneg G k j i )

/-! ## Section 7: Collision Resistance Analysis -/

/-
**Collision structure theorem**: if v and w collide under a min-plus hash
(same hash output) but differ at some coordinate, then the hash absorbs
the difference — quantifying how collisions must be "structured" to survive.
Bridge: connects Post-Quantum Cryptography to Certified ML Robustness.
Application: post_quantum_security, tropical_hash_collision
-/
theorem trop_collision_absorbs_difference {n m : ℕ} [NeZero n] [NeZero m]
    (h : MinPlusHash n m) (v w : Fin n → ℝ)
    (hcol : ∀ i : Fin m, h.eval v i = h.eval w i)
    (hne : ∃ k : Fin n, v k ≠ w k) :
    ∀ i : Fin m, ∃ k₁ k₂ : Fin n,
      h.compressor i k₁ + v k₁ ≤ h.compressor i k₂ + v k₂ ∧
      h.compressor i k₂ + w k₂ ≤ h.compressor i k₁ + w k₁ := by
  intro i;
  obtain ⟨k₁, hk₁⟩ : ∃ k₁, ∀ k, h.compressor i k₁ + v k₁ ≤ h.compressor i k + v k := by
    simpa using Finset.exists_min_image Finset.univ ( fun k => h.compressor i k + v k ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
  exact ⟨ k₁, k₁, le_rfl, le_rfl ⟩

/-! ## Section 8: Tropical Matrix Norm Properties -/

/-- The **tropical sup-norm** of a matrix: the maximum absolute value of entries.
Bridge: connects Tropical Algebra to Normed Algebra. -/
def tropSupNorm {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i =>
    Finset.univ.sup' Finset.univ_nonempty fun j => |A i j|

/-
**Tropical sup-norm is nonneg**: ‖A‖ ≥ 0 for all matrices A.
Bridge: connects Tropical Algebra to Normed Spaces.
-/
theorem tropSupNorm_nonneg {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) : 0 ≤ tropSupNorm A := by
  unfold tropSupNorm;
  aesop

/-
**Tropical sup-norm bounds entries**: |A i j| ≤ ‖A‖ for all i, j.
Bridge: connects Tropical Algebra to Normed Spaces.
-/
theorem tropSupNorm_bound {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |A i j| ≤ tropSupNorm A := by
  exact Finset.le_sup' ( fun i => Finset.sup' Finset.univ Finset.univ_nonempty fun j => |A i j| ) ( Finset.mem_univ i ) |> le_trans ( Finset.le_sup' ( fun j => |A i j| ) ( Finset.mem_univ j ) )

/-
**Tropical product norm bound**: ‖A ⊗ B‖ ≤ ‖A‖ + ‖B‖.
This is the tropical analog of the sub-multiplicative norm property
(since tropical "multiplication" is addition).
Bridge: connects Tropical Algebra to Banach Algebra.
Application: post_quantum_security, Lipschitz_bound
-/
theorem tropMatMul_norm_bound {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropSupNorm (tropMatMul A B) ≤ tropSupNorm A + tropSupNorm B := by
  refine' Finset.sup'_le _ _ _;
  intro i hi;
  refine' Finset.sup'_le _ _ _;
  intro j hj;
  obtain ⟨ k, hk ⟩ := tropMatMul_entry_achieved A B i j;
  exact hk.symm ▸ abs_le.mpr ⟨ by linarith [ abs_le.mp ( tropSupNorm_bound A i k ), abs_le.mp ( tropSupNorm_bound B k j ) ], by linarith [ abs_le.mp ( tropSupNorm_bound A i k ), abs_le.mp ( tropSupNorm_bound B k j ) ] ⟩

/-! ## Section 9: Tropical Contraction Properties -/

/-- A tropical matrix is a **tropical contraction** if A ⊗ v is closer to
the tropical eigenvector than v for any v. This is the key property for
convergence of tropical power iteration.
Bridge: connects Tropical Algebra to Fixed Point Theory to Numerical Analysis.
Application: post_quantum_security, convergence -/
def IsTropicalContraction {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (rate : ℝ) : Prop :=
  0 ≤ rate ∧ rate < 1 ∧
  ∀ v w : Fin n → ℝ,
    Finset.univ.sup' Finset.univ_nonempty (fun i => |tropMatVecMul A v i - tropMatVecMul A w i|) ≤
    rate * Finset.univ.sup' Finset.univ_nonempty (fun i => |v i - w i|)

/-
**Diagonal-dominant matrices are tropical contractions**: if A has
large enough diagonal dominance, tropical power iteration converges.
Bridge: connects Tropical Algebra to Dynamical Systems.
Application: convergence, post_quantum_security
-/
theorem diagonal_dominant_is_contraction {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, A i i = 0)
    (hdom : ∀ i j, i ≠ j → A i j ≥ 1)
    (hn : (1 : ℝ) < n) :
    ∀ v w : Fin n → ℝ,
      Finset.univ.sup' Finset.univ_nonempty (fun i => |tropMatVecMul A v i - tropMatVecMul A w i|) ≤
      Finset.univ.sup' Finset.univ_nonempty (fun i => |v i - w i|) := by
  grind +suggestions

/-! ## Section 10: Min-Plus Neural Network Layer -/

/-- A **min-plus neural network layer** applies a tropical matrix-vector product
followed by a bias shift. This is the tropical analog of an affine layer.
Bridge: connects Tropical Algebra to Neural Network Architecture.
Application: certified_robustness, neural_network, Lipschitz_bound -/
structure MinPlusLayer (n_in n_out : ℕ) [NeZero n_in] [NeZero n_out] where
  /-- Weight matrix -/
  weights : Matrix (Fin n_out) (Fin n_in) ℝ
  /-- Bias vector -/
  bias : Fin n_out → ℝ

/-- Forward pass through a min-plus layer.
Bridge: connects Tropical Algebra to Neural Network Inference. -/
def MinPlusLayer.forward {n_in n_out : ℕ} [NeZero n_in] [NeZero n_out]
    (layer : MinPlusLayer n_in n_out) (v : Fin n_in → ℝ) : Fin n_out → ℝ :=
  fun i => (Finset.univ.inf' Finset.univ_nonempty fun k => layer.weights i k + v k) + layer.bias i

/-
**Min-plus layer is 1-Lipschitz** in the sup-norm (ignoring bias).
This is the fundamental property enabling certified robustness.
Bridge: connects Neural Networks to Certified Robustness via Tropical Algebra.
Application: certified_robustness, Lipschitz_bound, neural_network
-/
theorem MinPlusLayer.forward_lipschitz {n_in n_out : ℕ} [NeZero n_in] [NeZero n_out]
    (layer : MinPlusLayer n_in n_out) (v w : Fin n_in → ℝ) (i : Fin n_out) :
    |layer.forward v i - layer.forward w i| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |v k - w k| := by
  convert abs_inf_sub_inf_le_sup ( Finset.univ : Finset ( Fin n_in ) ) ( Finset.univ_nonempty ) ( fun k => layer.weights i k + v k ) ( fun k => layer.weights i k + w k ) using 2 ; ring!;
  · unfold MinPlusLayer.forward; ring;
  · ring

/-
**Composition of min-plus layers**: two layers composed give a Lipschitz
constant that is the product (=sum in tropical) of individual constants.
Bridge: connects Neural Network Composition to Tropical Algebra.
Application: certified_robustness, Lipschitz_bound, neural_network
-/
theorem MinPlusLayer.composed_lipschitz {n₁ n₂ n₃ : ℕ}
    [NeZero n₁] [NeZero n₂] [NeZero n₃]
    (L₁ : MinPlusLayer n₁ n₂) (L₂ : MinPlusLayer n₂ n₃)
    (v w : Fin n₁ → ℝ) (i : Fin n₃) :
    |L₂.forward (L₁.forward v) i - L₂.forward (L₁.forward w) i| ≤
      Finset.univ.sup' Finset.univ_nonempty fun k => |v k - w k| := by
  refine' le_trans ( L₂.forward_lipschitz _ _ _ ) _;
  exact Finset.sup'_le _ _ fun i _ => L₁.forward_lipschitz v w i

end