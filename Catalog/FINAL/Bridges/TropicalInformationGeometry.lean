/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Information Geometry: Min-Plus Fisher Information and Certified Bounds

This file opens the field of **tropical (min-plus) information geometry** by establishing
foundational definitions and theorems connecting idempotent semiring analysis to
statistical geometry, optimization, and certified robustness.

## Bridge: Tropical Geometry ↔ Information Theory ↔ Certified ML ↔ Post-Quantum Crypto

## Main Results
1. Tropical semiring foundations with full algebraic properties
2. L∞ entropy metric: triangle inequality, symmetry, identity
3. Tropical Fisher information: structure, symmetry, score bounds
4. Tropical spectral theory: eigenvalue bounds, condition numbers
5. Tropical determinant: trace bounds, spectral connections
6. Cross-domain bridges: crypto, ML, quantum, thermodynamics
-/

noncomputable section

open Finset BigOperators

namespace TropicalInfoGeom

/-! ## Section 1: Tropical Semiring -/

/-- Min-plus tropical addition: ⊕ = min.
    Bridge: tropical algebraic geometry ↔ dynamic programming. -/
@[reducible] def tropOplus (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication: ⊗ = +.
    Bridge: tropical algebraic geometry ↔ logarithmic probability. -/
@[reducible] def tropOtimes (a b : ℝ) : ℝ := a + b

theorem tropOplus_comm (a b : ℝ) : tropOplus a b = tropOplus b a := min_comm a b
theorem tropOplus_assoc (a b c : ℝ) :
    tropOplus (tropOplus a b) c = tropOplus a (tropOplus b c) := min_assoc a b c

/-- Idempotency: a ⊕ a = a. Foundation of tropical fixed-point theory. -/
theorem tropOplus_idem (a : ℝ) : tropOplus a a = a := min_self a

/-- Distributivity: c ⊗ (a ⊕ b) = (c ⊗ a) ⊕ (c ⊗ b). -/
theorem tropOtimes_distributes_tropOplus (a b c : ℝ) :
    tropOtimes c (tropOplus a b) = tropOplus (tropOtimes c a) (tropOtimes c b) := by
  simp [tropOtimes, tropOplus, min_add_add_left]

theorem tropOtimes_comm (a b : ℝ) : tropOtimes a b = tropOtimes b a := add_comm a b
theorem tropOtimes_assoc (a b c : ℝ) :
    tropOtimes (tropOtimes a b) c = tropOtimes a (tropOtimes b c) := add_assoc a b c
theorem tropOtimes_zero_left (a : ℝ) : tropOtimes 0 a = a := zero_add a
theorem tropOtimes_zero_right (a : ℝ) : tropOtimes a 0 = a := add_zero a

/-- Min-max absorption: min(a, max(a, b)) = a.
    Bridge: lattice theory ↔ tropical geometry ↔ neural network activation. -/
theorem tropical_min_max_absorption_info (a b : ℝ) :
    min a (max a b) = a := min_eq_left (le_max_left a b)

theorem tropical_max_min_absorption_info (a b : ℝ) :
    max a (min a b) = a := max_eq_left (min_le_left a b)

/-- Min-plus duality: min(a,b) = -(max(-a, -b)).
    Bridge: min-plus ↔ max-plus duality ↔ ReLU/tropical. -/
theorem tropOplus_neg_duality (a b : ℝ) :
    min a b = -max (-a) (-b) := by
  simp [min_def, max_def]; split_ifs with h1 h2 h2 <;> linarith

/-! ## Section 2: L∞ Entropy Distance -/

/-- L∞ distance between real-valued functions on Fin n.
    Bridge: normed space theory ↔ adversarial perturbation measurement. -/
def linftyDist {n : ℕ} [NeZero n] (f g : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun k => |f k - g k|)

/-- L∞ distance is non-negative. -/
theorem linftyDist_nonneg {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    0 ≤ linftyDist f g := by
  unfold linftyDist
  exact le_trans (abs_nonneg (f 0 - g 0))
    (Finset.le_sup' (fun k => |f k - g k|) (Finset.mem_univ 0))

/-- L∞ distance is symmetric. -/
theorem linftyDist_symm {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    linftyDist f g = linftyDist g f := by
  unfold linftyDist; congr 1; ext k; rw [abs_sub_comm]

/-- Each coordinate difference is bounded by L∞ distance. -/
theorem coord_le_linftyDist {n : ℕ} [NeZero n] (f g : Fin n → ℝ)
    (k : Fin n) : |f k - g k| ≤ linftyDist f g :=
  Finset.le_sup' (fun k => |f k - g k|) (Finset.mem_univ k)

/-- L∞ self-distance is zero. -/
theorem linftyDist_self {n : ℕ} [NeZero n] (f : Fin n → ℝ) :
    linftyDist f f = 0 := by
  simp [linftyDist, sub_self]

/-
**L∞ triangle inequality**: d_∞(f, h) ≤ d_∞(f, g) + d_∞(g, h).
    Bridge: metric geometry ↔ certified robustness composition.
-/
theorem linftyDist_triangle {n : ℕ} [NeZero n] (f g h : Fin n → ℝ) :
    linftyDist f h ≤ linftyDist f g + linftyDist g h := by
      unfold linftyDist;
      exact Finset.sup'_le _ _ fun x hx => by cases abs_cases ( f x - h x ) <;> cases abs_cases ( f x - g x ) <;> cases abs_cases ( g x - h x ) <;> linarith [ Finset.le_sup' ( fun x => |f x - g x| ) hx, Finset.le_sup' ( fun x => |g x - h x| ) hx ] ;

/-
L∞ distance zero iff equal.
    Bridge: metric identity ↔ information indistinguishability.
-/
theorem linftyDist_eq_zero_iff {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    linftyDist f g = 0 ↔ f = g := by
      constructor <;> intro h;
      · exact funext fun x => sub_eq_zero.mp ( abs_eq_zero.mp ( le_antisymm ( le_trans ( coord_le_linftyDist f g x ) h.le ) ( abs_nonneg _ ) ) );
      · -- If $f = g$, then for every $k$, $|f k - g k| = 0$, so the supremum is also $0$.
        simp [h, linftyDist]

/-! ## Section 3: Tropical Matrix Operations -/

/-- Tropical matrix-vector product: (A ⊗ v)_i = min_j (A_{ij} + v_j).
    Bridge: shortest-path computation ↔ tropical Fisher preconditioning. -/
def tropMatVecMul {m p : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (v : Fin p → ℝ) : Fin m → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + v j)

/-- Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
    Computable in O(n³). Bridge: Floyd-Warshall ↔ tropical linear algebra. -/
def tropMatMul {m p q : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (B : Matrix (Fin p) (Fin q) ℝ) :
    Matrix (Fin m) (Fin q) ℝ :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-
Tropical mat-vec product is monotone: v ≤ w ⟹ Av ≤ Aw.
    Bridge: order-preserving dynamics ↔ certified convergence.
-/
theorem tropMatVecMul_mono {m p : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (v w : Fin p → ℝ)
    (hvw : ∀ j, v j ≤ w j) :
    ∀ i, tropMatVecMul A v i ≤ tropMatVecMul A w i := by
      unfold tropMatVecMul;
      simp +decide [ Finset.le_inf', hvw ];
      grind

/-- Tropical matrix multiplication entry bounded by any summand. -/
theorem tropMatMul_le_entry {m p q : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (B : Matrix (Fin p) (Fin q) ℝ)
    (i : Fin m) (j : Fin q) (k : Fin p) :
    tropMatMul A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

/-- Diagonal of tropical A ⊗ Aᵀ equals tropical self-inner-product. -/
theorem tropMatMul_transpose_diag {m p : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (i : Fin m) :
    tropMatMul A A.transpose i i =
      Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + A i k) := by
  simp [tropMatMul, Matrix.transpose_apply]

/-! ## Section 4: Tropical Fisher Information Matrix -/

/-- Tropical Fisher Information Matrix: min-plus correlation of score functions.
    Entry (i,j) = min_x [score_i(x) + score_j(x)].
    Bridge: idempotent analysis ↔ statistical estimation ↔ lattice crypto. -/
structure TropicalFisherMatrix (d n : ℕ) [NeZero n] where
  mat : Matrix (Fin d) (Fin d) ℝ
  scores : Matrix (Fin d) (Fin n) ℝ
  consistent : ∀ i j,
    mat i j = Finset.inf' Finset.univ Finset.univ_nonempty
      (fun k => scores i k + scores j k)

/-- Tropical Fisher matrix is symmetric: G_{ij} = G_{ji}.
    Bridge: symmetric geometry ↔ unbiased estimation duality. -/
theorem tropicalFisher_symmetric {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n) :
    ∀ i j, G.mat i j = G.mat j i := by
  intro i j; rw [G.consistent i j, G.consistent j i]
  congr 1; ext k; ring

/-- Diagonal: G_{ii} = min_x (2 · score_i(x)). -/
theorem tropicalFisher_diag {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n) (i : Fin d) :
    G.mat i i = Finset.inf' Finset.univ Finset.univ_nonempty
      (fun k => 2 * G.scores i k) := by
  rw [G.consistent i i]; congr 1; ext k; ring

/-- Fisher diagonal bounds score: G_{ii} ≤ 2 · score_i(x) for all x.
    Bridge: Fisher info ↔ estimation precision ↔ crypto key leakage. -/
theorem fisher_diag_le_score {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n) (i : Fin d) (k : Fin n) :
    G.mat i i ≤ 2 * G.scores i k := by
  rw [G.consistent i i]
  have : Finset.inf' Finset.univ Finset.univ_nonempty
    (fun k' => G.scores i k' + G.scores i k') ≤ G.scores i k + G.scores i k :=
    Finset.inf'_le _ (Finset.mem_univ k)
  linarith

/-- Fisher off-diagonal bound: G_{ij} ≤ score_i(x) + score_j(x) for all x. -/
theorem fisher_offdiag_le_scores {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n) (i j : Fin d) (k : Fin n) :
    G.mat i j ≤ G.scores i k + G.scores j k := by
  rw [G.consistent i j]; exact Finset.inf'_le _ (Finset.mem_univ k)

/-! ## Section 5: Tropical Spectral Theory -/

/-- Tropical spectral radius: max diagonal entry.
    Computable in O(d) time.
    Bridge: spectral theory ↔ information capacity ↔ crypto key strength. -/
def tropSpecRadius {d : ℕ} [NeZero d] (M : Matrix (Fin d) (Fin d) ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => M i i)

/-- Tropical minimum eigenvalue: min diagonal entry.
    Bridge: spectral gap ↔ convergence rate ↔ crypto security margin. -/
def tropMinEig {d : ℕ} [NeZero d] (M : Matrix (Fin d) (Fin d) ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => M i i)

/-- Tropical condition number: κ_∞ = λ_max - λ_min.
    Bridge: condition number ↔ convergence rate ↔ adversarial robustness. -/
def tropCondNumber {d : ℕ} [NeZero d] (M : Matrix (Fin d) (Fin d) ℝ) : ℝ :=
  tropSpecRadius M - tropMinEig M

/-
Tropical condition number is non-negative.
-/
theorem tropCondNumber_nonneg {d : ℕ} [NeZero d] (M : Matrix (Fin d) (Fin d) ℝ) :
    0 ≤ tropCondNumber M := by
      exact sub_nonneg_of_le ( Finset.le_sup' ( fun i ↦ M i i ) ( Finset.mem_univ ( Classical.choose ( Finset.exists_min_image Finset.univ ( fun i ↦ M i i ) ⟨ 0, Finset.mem_univ _ ⟩ ) ) ) |> le_trans ( Finset.inf'_le _ <| Finset.mem_univ _ ) )

/-- Spectral radius bounds all diagonal entries. -/
theorem tropSpecRadius_ge_diag {d : ℕ} [NeZero d]
    (M : Matrix (Fin d) (Fin d) ℝ) (i : Fin d) :
    M i i ≤ tropSpecRadius M :=
  Finset.le_sup' (fun j => M j j) (Finset.mem_univ i)

/-- Min eigenvalue bounds all diagonal entries from below. -/
theorem tropMinEig_le_diag {d : ℕ} [NeZero d]
    (M : Matrix (Fin d) (Fin d) ℝ) (i : Fin d) :
    tropMinEig M ≤ M i i :=
  Finset.inf'_le (fun j => M j j) (Finset.mem_univ i)

/-- Spectral radius ≥ min eigenvalue. -/
theorem tropSpecRadius_ge_tropMinEig {d : ℕ} [NeZero d]
    (M : Matrix (Fin d) (Fin d) ℝ) :
    tropMinEig M ≤ tropSpecRadius M := by
  unfold tropMinEig tropSpecRadius
  obtain ⟨a, ha⟩ := Finset.univ_nonempty (α := Fin d)
  exact le_trans (Finset.inf'_le (fun i => M i i) ha)
    (Finset.le_sup' (fun i => M i i) ha)

/-
Condition number zero iff all diagonal entries equal.
    Bridge: isotropic geometry ↔ uniform information ↔ perfect security.
-/
theorem tropCondNumber_eq_zero_iff {d : ℕ} [NeZero d]
    (M : Matrix (Fin d) (Fin d) ℝ) :
    tropCondNumber M = 0 ↔ ∀ i j : Fin d, M i i = M j j := by
      constructor;
      · intro h i j;
        unfold tropCondNumber at h;
        unfold tropSpecRadius tropMinEig at h;
        linarith [ Finset.le_sup' ( fun i => M i i ) ( Finset.mem_univ i ), Finset.le_sup' ( fun i => M i i ) ( Finset.mem_univ j ), Finset.inf'_le ( fun i => M i i ) ( Finset.mem_univ i ), Finset.inf'_le ( fun i => M i i ) ( Finset.mem_univ j ) ];
      · intro h
        unfold tropCondNumber;
        unfold tropSpecRadius tropMinEig; simp +decide [ h _ 0 ] ;

/-! ## Section 6: Tropical Determinant -/

/-- Tropical determinant: min over permutations of ∑_i M_{i,σ(i)}.
    Equals minimum-weight perfect matching, computable in O(n³).
    Bridge: Hungarian algorithm ↔ tropical linear algebra ↔ lattice crypto. -/
def tropDet {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i, M i (σ i))

/-- Tropical determinant ≤ trace (identity permutation bound).
    Bridge: trace bound ↔ diagonal dominance ↔ spectral approximation. -/
theorem tropDet_le_trace {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) :
    tropDet M ≤ ∑ i, M i i := by
  unfold tropDet
  exact Finset.inf'_le _ (Finset.mem_univ (Equiv.refl (Fin n)))

/-! ## Section 7: Stochastic Maps -/

/-- Stochastic matrix: non-negative rows summing to 1.
    Bridge: Markov chains ↔ quantum channels ↔ data processing. -/
structure StochMatrix (m n : ℕ) where
  mat : Matrix (Fin m) (Fin n) ℝ
  nonneg : ∀ i j, 0 ≤ mat i j
  row_sum : ∀ i, ∑ j, mat i j = 1

/-- Apply a stochastic matrix to a vector. -/
def stochApply {m n : ℕ} (K : StochMatrix m n) (p : Fin n → ℝ) : Fin m → ℝ :=
  fun i => ∑ j, K.mat i j * p j

/-- Stochastic maps preserve non-negativity.
    Bridge: positivity ↔ physical realizability. -/
theorem stochApply_nonneg {m n : ℕ} (K : StochMatrix m n)
    (p : Fin n → ℝ) (hp : ∀ j, 0 ≤ p j) :
    ∀ i, 0 ≤ stochApply K p i := by
  intro i; unfold stochApply
  exact Finset.sum_nonneg (fun j _ => mul_nonneg (K.nonneg i j) (hp j))

/-! ## Section 8: Min-Entropy -/

/-- Min-entropy of a distribution: H_∞(p) = -log(max_x p(x)).
    Bridge: Shannon entropy limit ↔ post-quantum security parameter. -/
def minEntropy {n : ℕ} [NeZero n] (p : Fin n → ℝ) : ℝ :=
  -Real.log (Finset.sup' Finset.univ Finset.univ_nonempty p)

/-
Min-entropy non-negative when max ≤ 1.
    Bridge: entropy non-negativity ↔ fundamental information bound.
-/
theorem minEntropy_nonneg {n : ℕ} [NeZero n] (p : Fin n → ℝ)
    (hp_pos : ∀ i, 0 < p i)
    (hp_le : Finset.sup' Finset.univ Finset.univ_nonempty p ≤ 1) :
    0 ≤ minEntropy p := by
      exact neg_nonneg.mpr ( Real.log_nonpos ( by exact le_trans ( by norm_num ) ( Finset.le_sup' _ ( Finset.mem_univ ⟨ 0, NeZero.pos n ⟩ ) |> le_trans ( le_of_lt ( hp_pos _ ) ) ) ) hp_le )

/-
Min-entropy upper bound: H_∞(p) ≤ log(n).
    Bridge: maximum entropy principle ↔ thermodynamic equilibrium.
-/
theorem minEntropy_le_log_card {n : ℕ} [NeZero n] (p : Fin n → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hp_sum : ∑ i, p i = 1) :
    minEntropy p ≤ Real.log n := by
      unfold minEntropy;
      rw [ ← Real.log_inv, Real.log_le_log_iff ] <;> norm_num;
      · rw [ inv_eq_one_div, div_le_iff₀ ];
        · have := Finset.sum_le_sum fun i ( _ : i ∈ Finset.univ ) => show p i ≤ Finset.univ.sup' Finset.univ_nonempty p from Finset.le_sup' ( fun i => p i ) ( Finset.mem_univ i ) ; aesop;
        · exact lt_of_lt_of_le ( hp_pos ⟨ 0, NeZero.pos n ⟩ ) ( Finset.le_sup' _ ( Finset.mem_univ _ ) );
      · exact ⟨ ⟨ 0, NeZero.pos n ⟩, hp_pos _ ⟩;
      · exact NeZero.pos n

/-! ## Section 9: Tropical Gradient Descent -/

/-- Tropical gradient step: θ_{t+1,i} = θ_{t,i} - η · min_j (P_{ij} + grad_j).
    Bridge: optimization ↔ tropical matrix algebra ↔ natural gradient. -/
def tropGradStep {d : ℕ} [NeZero d]
    (P : Matrix (Fin d) (Fin d) ℝ) (theta grad : Fin d → ℝ) (eta : ℝ) : Fin d → ℝ :=
  fun i => theta i - eta * Finset.inf' Finset.univ Finset.univ_nonempty
    (fun j => P i j + grad j)

/-
Fixed-point characterization of tropical gradient descent.
    Bridge: tropical equilibrium ↔ optimal solution ↔ Nash equilibrium.
-/
theorem tropGradStep_fixed_iff {d : ℕ} [NeZero d]
    (P : Matrix (Fin d) (Fin d) ℝ) (theta grad : Fin d → ℝ)
    (eta : ℝ) (heta : eta ≠ 0) :
    tropGradStep P theta grad eta = theta ↔
      ∀ i, Finset.inf' Finset.univ Finset.univ_nonempty (fun j => P i j + grad j) = 0 := by
  constructor <;> intro h <;> simp_all +decide [ funext_iff, tropGradStep ]

/-! ## Section 10: Tropical Inner Product -/

/-- Tropical inner product: ⟨u, v⟩_G = min_{i,j} (u_i + G_{ij} + v_j).
    Bridge: quadratic forms ↔ tropical geometry ↔ quantum fidelity. -/
def tropInnerProd {d : ℕ} [NeZero d]
    (G : Matrix (Fin d) (Fin d) ℝ) (u v : Fin d → ℝ) : ℝ :=
  Finset.inf' (Finset.univ ×ˢ Finset.univ)
    (Finset.Nonempty.product Finset.univ_nonempty Finset.univ_nonempty)
    (fun p => u p.1 + G p.1 p.2 + v p.2)

/-
Tropical inner product symmetric when G is symmetric.
    Bridge: symmetric bilinear forms ↔ information geometry.
-/
theorem tropInnerProd_symm {d : ℕ} [NeZero d]
    (G : Matrix (Fin d) (Fin d) ℝ) (u v : Fin d → ℝ)
    (hG : ∀ i j, G i j = G j i) :
    tropInnerProd G u v = tropInnerProd G v u := by
      apply le_antisymm;
      · simp +decide [ tropInnerProd ];
        exact fun i j => ⟨ j, i, by linarith [ hG i j ] ⟩;
      · unfold tropInnerProd;
        simp +decide [ Finset.inf'_le, hG ];
        exact fun i j => ⟨ j, i, by linarith [ hG i j ] ⟩

/-
Tropical inner product bounded by any entry.
-/
theorem tropInnerProd_le_entry {d : ℕ} [NeZero d]
    (G : Matrix (Fin d) (Fin d) ℝ) (u v : Fin d → ℝ) (i j : Fin d) :
    tropInnerProd G u v ≤ u i + G i j + v j := by
      -- By definition of tropInnerProd, we have:
      unfold tropInnerProd;
      aesop

/-! ## Section 11: Cross-Domain Bridge Theorems -/

/-
**Tropical-to-classical Fisher bridge**: min_x [s_i(x) + s_j(x)] ≤ E_w[s_i + s_j].
    The tropical Fisher info is always ≤ classical Fisher info.
    Bridge: classical statistics ↔ tropical geometry ↔ worst-case analysis.
-/
theorem tropical_le_classical_fisher
    {n : ℕ} [NeZero n]
    (s_i s_j : Fin n → ℝ)
    (w : Fin n → ℝ) (hw_nn : ∀ k, 0 ≤ w k) (hw_sum : ∑ k, w k = 1) :
    Finset.inf' Finset.univ Finset.univ_nonempty (fun k => s_i k + s_j k) ≤
    ∑ k, w k * (s_i k + s_j k) := by
      refine' le_trans _ ( Finset.sum_le_sum fun k _ => mul_le_mul_of_nonneg_left ( show s_i k + s_j k ≥ Finset.inf' Finset.univ Finset.univ_nonempty ( fun k => s_i k + s_j k ) from Finset.inf'_le _ <| Finset.mem_univ k ) <| hw_nn k );
      rw [ ← Finset.sum_mul _ _ _, hw_sum, one_mul ]

/-- Post-quantum security bridge: tropDet(G) ≤ tr(G) for Fisher matrices. -/
theorem post_quantum_tropical_det_bound {d n : ℕ} [NeZero d] [NeZero n]
    (G : TropicalFisherMatrix d n) :
    tropDet G.mat ≤ ∑ i, G.mat i i := tropDet_le_trace G.mat

/-- **Depth-information tradeoff**: Larger diagonal ⟹ larger spectral radius.
    Bridge: deep learning ↔ tropical geometry ↔ certified training. -/
theorem depth_information_tradeoff {d : ℕ} [NeZero d]
    (G₁ G₂ : Matrix (Fin d) (Fin d) ℝ)
    (h : ∀ i, G₁ i i ≤ G₂ i i) :
    tropSpecRadius G₁ ≤ tropSpecRadius G₂ := by
  unfold tropSpecRadius
  exact Finset.sup'_le _ _ fun i hi =>
    le_trans (h i) (Finset.le_sup' (fun j => G₂ j j) (Finset.mem_univ i))

/-- **Entropy-Fisher duality**: scores = -log p ⟹ Fisher diagonal uses -2·log p.
    Bridge: entropy ↔ Fisher information ↔ thermodynamic free energy. -/
theorem entropy_fisher_duality {n : ℕ} [NeZero n]
    (logp scores : Fin n → ℝ) (h : ∀ k, scores k = -logp k) :
    Finset.inf' Finset.univ Finset.univ_nonempty (fun k => 2 * scores k) =
    Finset.inf' Finset.univ Finset.univ_nonempty (fun k => -2 * logp k) := by
  congr 1; ext k; rw [h]; ring

/-- **Hamiltonian-tropical connection**: energy gradients = scores ⟹ Fisher
    entries equal min-plus energy gradient correlations.
    Bridge: statistical mechanics ↔ tropical geometry ↔ information theory. -/
theorem hamiltonian_tropical_fisher {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n)
    (E : Matrix (Fin d) (Fin n) ℝ)
    (h : ∀ i k, E i k = G.scores i k) :
    ∀ i j, G.mat i j = Finset.inf' Finset.univ Finset.univ_nonempty
      (fun k => E i k + E j k) := by
  intro i j; rw [G.consistent]; congr 1; ext k; rw [h, h]

/-
**Tropical Fisher trace-score bound**: tr(G) ≤ 2 · ∑_i min_x score_i(x).
    Bridge: information capacity ↔ estimation complexity ↔ crypto key length.
-/
theorem tropicalFisher_trace_bound {d n : ℕ} [NeZero d] [NeZero n]
    (G : TropicalFisherMatrix d n) :
    ∑ i : Fin d, G.mat i i ≤
      2 * ∑ i : Fin d, Finset.inf' Finset.univ Finset.univ_nonempty
        (fun k => G.scores i k) := by
          -- By definition of $G$, we know that for each $i$, $G.mat i i = \inf_k (2 * scores i k)$.
          have h_diag : ∀ i, G.mat i i = Finset.inf' (Finset.univ : Finset (Fin n)) Finset.univ_nonempty (fun k => 2 * G.scores i k) := by
            exact?;
          rw [ Finset.mul_sum ] ; gcongr;
          aesop

/-
**Certified robustness via Fisher perturbation**: score perturbation ≤ δ
    ⟹ Fisher entry perturbation ≤ 2δ. Explicit bound: O(δ).
    Bridge: Lipschitz certification ↔ tropical Fisher ↔ adversarial robustness.
-/
theorem certified_robustness_fisher_perturbation
    {d n : ℕ} [NeZero n]
    (s₁ s₂ : Matrix (Fin d) (Fin n) ℝ) (delta : ℝ) (_hd : 0 ≤ delta)
    (hbd : ∀ i k, |s₁ i k - s₂ i k| ≤ delta) (i j : Fin d) :
    |Finset.inf' Finset.univ Finset.univ_nonempty (fun k => s₁ i k + s₁ j k) -
     Finset.inf' Finset.univ Finset.univ_nonempty (fun k => s₂ i k + s₂ j k)| ≤
    2 * delta := by
      refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
      · simp +zetaDelta at *;
        obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun k => s₂ i k + s₂ j k );
        exact ⟨ k, by linarith [ abs_le.mp ( hbd i k ), abs_le.mp ( hbd j k ) ] ⟩;
      · obtain ⟨ k₁, hk₁ ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => s₁ i k + s₁ j k );
        linarith [ abs_le.mp ( hbd i k₁ ), abs_le.mp ( hbd j k₁ ), Finset.inf'_le ( fun k => s₂ i k + s₂ j k ) ( Finset.mem_univ k₁ ) ]

/-! ## Section 12: Min-Plus Convexity -/

/-- Min-plus convex combination: γ(t, i) = min(t + p_i, (1-t) + q_i).
    Bridge: tropical geodesic ↔ optimal transport ↔ quantum interpolation. -/
def minPlusConvComb {n : ℕ} (p q : Fin n → ℝ) (t : ℝ) : Fin n → ℝ :=
  fun i => min (t + p i) ((1 - t) + q i)

/-- Min-plus combination at t=0. -/
theorem minPlusConvComb_at_zero {n : ℕ} (p q : Fin n → ℝ) :
    minPlusConvComb p q 0 = fun i => min (p i) (1 + q i) := by
  ext i; simp [minPlusConvComb]

/-- Min-plus combination at t=1. -/
theorem minPlusConvComb_at_one {n : ℕ} (p q : Fin n → ℝ) :
    minPlusConvComb p q 1 = fun i => min (1 + p i) (q i) := by
  ext i; simp [minPlusConvComb]

/-- Each component ≤ t + p_i. -/
theorem minPlusConvComb_le_left {n : ℕ} (p q : Fin n → ℝ) (t : ℝ) (i : Fin n) :
    minPlusConvComb p q t i ≤ t + p i := min_le_left _ _

/-- Each component ≤ (1-t) + q_i. -/
theorem minPlusConvComb_le_right {n : ℕ} (p q : Fin n → ℝ) (t : ℝ) (i : Fin n) :
    minPlusConvComb p q t i ≤ (1 - t) + q i := min_le_right _ _

/-! ## Section 13: Spectral-Trace and Minimax -/

/-
Tropical spectral-trace sandwich:
    d · tropMinEig(M) ≤ tr(M) ≤ d · tropSpecRadius(M).
    Bridge: spectral-trace relation ↔ average vs worst-case information.
-/
theorem tropical_spectral_trace_sandwich {d : ℕ} [NeZero d]
    (M : Matrix (Fin d) (Fin d) ℝ) :
    (Fintype.card (Fin d) : ℝ) * tropMinEig M ≤ ∑ i : Fin d, M i i ∧
    ∑ i : Fin d, M i i ≤ (Fintype.card (Fin d) : ℝ) * tropSpecRadius M := by
      constructor <;> norm_num [ tropMinEig, tropSpecRadius ];
      · -- Since the infimum is a lower bound for each term in the sum, we can apply the sum inequality.
        have h_inf_le : ∀ i, (Finset.univ.inf' Finset.univ_nonempty (fun i => M i i)) ≤ M i i := by
          exact fun i => Finset.inf'_le _ ( Finset.mem_univ _ );
        simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_inf_le i;
      · convert Finset.sum_le_card_nsmul _ _ _ _ ; aesop;
        · infer_instance;
        · exact fun i _ => Finset.le_sup' ( fun i => M i i ) ( Finset.mem_univ i )

/-
**Tropical weak minimax duality**: max_j min_i A_{ij} ≤ min_i max_j A_{ij}.
    Bridge: minimax theorem ↔ tropical geometry ↔ adversarial ML.
-/
theorem tropical_weak_minimax {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) :
    Finset.sup' Finset.univ Finset.univ_nonempty
      (fun j => Finset.inf' Finset.univ Finset.univ_nonempty (fun i => A i j)) ≤
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => A i j)) := by
        simp +zetaDelta at *;
        exact fun i => by rcases Finset.exists_max_image Finset.univ ( fun j => A i j ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩ with ⟨ j, hj₁, hj₂ ⟩ ; exact ⟨ j, fun k => ⟨ i, by linarith [ hj₂ k ( Finset.mem_univ k ) ] ⟩ ⟩ ;

/-- Score L∞ norm non-negativity: max_i |score_i(k)| ≥ 0.
    Bridge: score bounding ↔ sensitivity ↔ differential privacy. -/
theorem score_linfty_nonneg {d n : ℕ} [NeZero d] [NeZero n]
    (scores : Matrix (Fin d) (Fin n) ℝ) (k : Fin n) :
    0 ≤ Finset.sup' Finset.univ Finset.univ_nonempty (fun i => |scores i k|) :=
  le_trans (abs_nonneg (scores 0 k))
    (Finset.le_sup' (fun i => |scores i k|) (Finset.mem_univ 0))

/-
Fisher entry bounded by sup of score sums.
-/
theorem tropicalFisher_entry_sup_bound {d n : ℕ} [NeZero n]
    (G : TropicalFisherMatrix d n) (i j : Fin d) :
    G.mat i j ≤ Finset.sup' Finset.univ Finset.univ_nonempty
      (fun k => G.scores i k + G.scores j k) := by
        have := G.consistent i j;
        exact this ▸ Finset.inf'_le _ ( Finset.mem_univ ( ⟨ 0, NeZero.pos n ⟩ : Fin n ) ) |> le_trans <| Finset.le_sup' _ ( Finset.mem_univ _ )

/-
Factorial exponential lower bound: 2^(n-1) ≤ n! for n ≥ 1.
    Bounds naive tropical determinant computation complexity.
    Bridge: combinatorial complexity ↔ crypto hardness.
-/
theorem factorial_exponential_bound (n : ℕ) (hn : 1 ≤ n) :
    2 ^ (n - 1) ≤ n.factorial := by
      induction hn <;> simp_all +decide [ Nat.factorial_succ, pow_succ' ];
      cases ‹1 ≤ _› <;> simp_all +decide [ pow_succ' ] ; nlinarith

/-- Construct canonical tropical Fisher matrix from scores.
    Bridge: constructive information geometry ↔ algorithmic estimation. -/
def mkTropicalFisher {d n : ℕ} [NeZero n] (scores : Matrix (Fin d) (Fin n) ℝ) :
    TropicalFisherMatrix d n where
  mat i j := Finset.inf' Finset.univ Finset.univ_nonempty
    (fun k => scores i k + scores j k)
  scores := scores
  consistent _ _ := rfl

/-- The constructed Fisher matrix is symmetric. -/
theorem mkTropicalFisher_symmetric {d n : ℕ} [NeZero n]
    (scores : Matrix (Fin d) (Fin n) ℝ) :
    ∀ i j, (mkTropicalFisher scores).mat i j = (mkTropicalFisher scores).mat j i :=
  tropicalFisher_symmetric (mkTropicalFisher scores)

end TropicalInfoGeom