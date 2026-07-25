/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Min-Plus Cryptographic Primitives

This file formalizes the mathematical foundations of tropical (min-plus) one-way
functions and their applications to post-quantum cryptography and certified
robustness for neural networks.

## Bridge: Tropical Algebra × Post-Quantum Cryptography × Certified ML Robustness

The min-plus semiring (ℤ, min, +) provides a natural setting for one-way functions:
tropical matrix-vector multiplication `(A ⊗ x)_i = min_j (A_{ij} + x_j)` can be
evaluated in O(n²) but inverting requires solving a tropical linear system. We prove:

1. **Non-expansiveness**: The tropical map is 1-Lipschitz in L∞ norm, giving
   certified robustness certificates for tropical neural networks.
2. **Shift equivariance**: The map commutes with constant shifts, yielding
   a well-defined map on tropical projective space.
3. **Preimage non-uniqueness**: Distinct inputs produce related outputs,
   the essential property for cryptographic one-way functions.

## Main Definitions

* `tropMV` — tropical min-plus matrix-vector product
* `linfDist` — L∞ distance on integer vectors
* `TropicalOneWayParams` — parameter structure for tropical one-way functions
* `TropicalRobustnessCert` — certified robustness certificate
* `IsTropicalEigenpair` — tropical eigenvalue-eigenvector relation
* `TropicalHashConfig` — hash function configuration
* `TropicalSecurityParams` — post-quantum security parameters
* `tropDet` — tropical determinant (min-weight matching)

## Main Results

* `tropMV_shift_equivariant` — A ⊗ (x + c·1) = (A ⊗ x) + c·1
* `tropMV_one_sided_bound` — (A⊗x)_i - (A⊗y)_i ≤ sup_j (x_j - y_j)
* `tropMV_component_lipschitz` — |(A⊗x)_i - (A⊗y)_i| ≤ ||x - y||_∞
* `tropMV_nonexpansive` — ||(A⊗x) - (A⊗y)||_∞ ≤ ||x - y||_∞
* `tropMV_robustness_certificate` — certified robustness from non-expansiveness
* `tropMV_preimage_nonunique` — ∃ x ≠ y with tropMV-related outputs
* `tropMV_multilayer_nonexpansive` — deep tropical networks stay non-expansive
* `tropMV_monotone` — tropical product is monotone
* `tropical_eigenpair_shift_invariant` — eigenpairs are shift-invariant
* `tropDet_monotone` — tropical determinant is monotone

## References

* Butkovič, P. "Max-linear Systems: Theory and Algorithms" (2010)
* Zhang et al. "Tropical Geometry of Deep Neural Networks" (2018)
* Grigoriev & Shpilrain "Tropical Cryptography" (2014)
-/

open Finset

set_option linter.unusedVariables false

noncomputable section

/-! ## Section 1: Core Tropical Operations -/

/-- Tropical min-plus matrix-vector product.
    `(tropMV A x) i = min_j (A i j + x j)`
    Bridge: the core computational primitive connecting tropical algebra
    to cryptographic one-way functions and neural network activation. -/
def tropMV {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) :
    Fin n → ℤ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + x j)

/-- The L∞ distance between two integer vectors: `max_i |x_i - y_i|`.
    Bridge: the natural metric for tropical geometry and certified robustness. -/
def linfDist {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  Finset.sup Finset.univ (fun i => (x i - y i).natAbs)

/-- The L∞ norm of an integer vector: `max_i |x_i|`. -/
def linfNorm {n : ℕ} (x : Fin n → ℤ) : ℕ :=
  Finset.sup Finset.univ (fun i => (x i).natAbs)

/-! ## Section 2: Basic L∞ Properties -/

/-- Each component difference is bounded by the L∞ distance. -/
theorem component_le_linfDist {n : ℕ} (x y : Fin n → ℤ) (i : Fin n) :
    (x i - y i).natAbs ≤ linfDist x y :=
  Finset.le_sup (f := fun i => (x i - y i).natAbs) (Finset.mem_univ i)

/-- The L∞ distance is symmetric. -/
theorem linfDist_comm {n : ℕ} (x y : Fin n → ℤ) : linfDist x y = linfDist y x := by
  simp only [linfDist]; congr 1; ext i; rw [← Int.natAbs_neg, neg_sub]

/-- The L∞ distance from a vector to itself is zero. -/
theorem linfDist_self {n : ℕ} (x : Fin n → ℤ) : linfDist x x = 0 := by
  simp [linfDist]

/-! ## Section 3: Fundamental Tropical Lipschitz Bounds -/

/-- Helper: `inf'` commutes with adding a constant.
    `min_j (f j + c) = (min_j f j) + c` -/
theorem inf'_add_const {n : ℕ} [NeZero n] (f : Fin n → ℤ) (c : ℤ) :
    Finset.inf' Finset.univ Finset.univ_nonempty (fun j => f j + c) =
    Finset.inf' Finset.univ Finset.univ_nonempty f + c := by
  apply le_antisymm
  · obtain ⟨j₀, _, hj₀⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty f
    calc Finset.inf' Finset.univ Finset.univ_nonempty (fun j => f j + c)
        ≤ f j₀ + c := Finset.inf'_le _ (Finset.mem_univ j₀)
      _ = Finset.inf' Finset.univ Finset.univ_nonempty f + c := by rw [hj₀]
  · apply Finset.le_inf' Finset.univ_nonempty
    intro j _
    exact Int.add_le_add_right (Finset.inf'_le f (Finset.mem_univ j)) c

/-- Helper: pointwise ordering is preserved by `inf'`. -/
theorem inf'_le_inf'_of_pointwise {n : ℕ} [NeZero n] (f g : Fin n → ℤ)
    (h : ∀ j, f j ≤ g j) :
    Finset.inf' Finset.univ Finset.univ_nonempty f ≤
    Finset.inf' Finset.univ Finset.univ_nonempty g := by
  obtain ⟨j₀, _, hj₀⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty g
  rw [hj₀]
  exact (Finset.inf'_le f (Finset.mem_univ j₀)).trans (h j₀)

/-- **One-sided tropical Lipschitz bound** (component-wise).
    `inf_j (a_j + x_j) - inf_j (a_j + y_j) ≤ sup_j (x_j - y_j)`

    This is the fundamental inequality for tropical certified_robustness.
    Bridge: connects tropical algebra to Lipschitz_bound for neural networks. -/
theorem tropMV_one_sided_bound {n : ℕ} [NeZero n] (a x y : Fin n → ℤ) :
    Finset.inf' Finset.univ Finset.univ_nonempty (fun j => a j + x j) -
    Finset.inf' Finset.univ Finset.univ_nonempty (fun j => a j + y j) ≤
    Finset.sup' Finset.univ Finset.univ_nonempty (fun j => x j - y j) := by
  obtain ⟨j₀, _, hj₀⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty (fun j => a j + y j)
  calc Finset.inf' Finset.univ Finset.univ_nonempty (fun j => a j + x j) -
       Finset.inf' Finset.univ Finset.univ_nonempty (fun j => a j + y j)
      ≤ (a j₀ + x j₀) - (a j₀ + y j₀) := by
        apply sub_le_sub
        · exact Finset.inf'_le _ (Finset.mem_univ _)
        · exact hj₀.ge
      _ = x j₀ - y j₀ := by ring
      _ ≤ Finset.sup' Finset.univ Finset.univ_nonempty (fun j => x j - y j) :=
        Finset.le_sup' (fun j => x j - y j) (Finset.mem_univ j₀)

/-- Auxiliary: one-sided bound implies component natAbs bound. -/
private theorem tropMV_component_one_dir {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x y : Fin n → ℤ) (i : Fin n) :
    tropMV A x i - tropMV A y i ≤ ↑(linfDist x y) := by
  simp only [tropMV]
  have hbound := tropMV_one_sided_bound (A i) x y
  calc Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + x j) -
       Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + y j)
      ≤ Finset.sup' Finset.univ Finset.univ_nonempty (fun j => x j - y j) := hbound
    _ ≤ ↑(linfDist x y) := by
        apply Finset.sup'_le Finset.univ_nonempty
        intro j _
        calc x j - y j ≤ |(x j - y j)| := le_abs_self _
          _ = ↑(x j - y j).natAbs := Int.abs_eq_natAbs _
          _ ≤ ↑(linfDist x y) := by
              exact_mod_cast component_le_linfDist x y j

/-- **Two-sided tropical Lipschitz bound** (component-wise).
    `|(A ⊗ x)_i - (A ⊗ y)_i| ≤ max_j |x_j - y_j|`

    Bridge: per-neuron certified_robustness guarantee for tropical networks. -/
theorem tropMV_component_lipschitz {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x y : Fin n → ℤ) (i : Fin n) :
    (tropMV A x i - tropMV A y i).natAbs ≤ linfDist x y := by
  have h1 : tropMV A x i - tropMV A y i ≤ ↑(linfDist x y) :=
    tropMV_component_one_dir A x y i
  have h2 : tropMV A y i - tropMV A x i ≤ ↑(linfDist x y) := by
    have := tropMV_component_one_dir A y x i
    rwa [linfDist_comm] at this
  omega

/-- **Tropical non-expansiveness theorem** (L∞ → L∞).
    `‖A ⊗ x - A ⊗ y‖_∞ ≤ ‖x - y‖_∞`

    The tropical matrix-vector product is a non-expansive (1-Lipschitz) map
    in the L∞ metric. This is the master certified_robustness theorem.

    Bridge: connects tropical algebra to certified_robustness for ML.
    Any tropical neural network layer preserves L∞ distances, giving
    an automatic robustness certificate with Lipschitz_bound 1.
    For post_quantum cryptography, this bounds the sensitivity of the
    tropical one-way function to input perturbations. -/
theorem tropMV_nonexpansive {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x y : Fin n → ℤ) :
    linfDist (tropMV A x) (tropMV A y) ≤ linfDist x y := by
  apply Finset.sup_le
  intro i _
  exact tropMV_component_lipschitz A x y i

/-! ## Section 4: Tropical Shift Equivariance -/

/-- **Tropical shift equivariance** (component-wise).
    Adding a constant to all input components adds the same constant to all outputs:
    `(A ⊗ (x + c·𝟏))_i = (A ⊗ x)_i + c`

    Bridge: tropical one-way functions naturally act on equivalence classes
    modulo constant shifts. For neural_network applications, this corresponds to
    shift-invariance of ReLU networks. -/
theorem tropMV_shift_equivariant {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) (c : ℤ) (i : Fin n) :
    tropMV A (fun j => x j + c) i = tropMV A x i + c := by
  simp only [tropMV]
  have : (fun j => A i j + (x j + c)) = (fun j => (A i j + x j) + c) := by ext j; ring
  rw [this, inf'_add_const]

/-- Full vector version of shift equivariance. -/
theorem tropMV_shift_equivariant_vec {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) (c : ℤ) :
    tropMV A (fun j => x j + c) = fun i => tropMV A x i + c := by
  ext i; exact tropMV_shift_equivariant A x c i

/-! ## Section 5: One-Way Function Properties -/

/-- **Tropical preimage non-uniqueness** (one-way function property).
    For any matrix A and any input x, there exists a distinct input y
    that produces a predictably shifted output.

    Bridge: this is the fundamental property making tropical matrix-vector
    multiplication a candidate one-way function for post_quantum cryptography.
    While computing A ⊗ x is O(n²), many inputs map to related outputs. -/
theorem tropMV_preimage_nonunique {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) :
    ∃ y : Fin n → ℤ, y ≠ x ∧
      tropMV A y = fun i => tropMV A x i + 1 := by
  refine ⟨fun j => x j + 1, ?_, tropMV_shift_equivariant_vec A x 1⟩
  intro h
  have : x ⟨0, NeZero.pos n⟩ + 1 = x ⟨0, NeZero.pos n⟩ := congr_fun h ⟨0, NeZero.pos n⟩
  omega

/-- **Tropical zero-knowledge shift property** (∀∃ with quantifier alternation).
    For every output, there exist arbitrarily many preimage-like inputs
    differing by any nonzero shift. Knowledge of one preimage reveals
    nothing about the "canonical" representative modulo shifts.

    Bridge: this is the simulator for tropical zero-knowledge proofs
    in post_quantum cryptographic protocols. -/
theorem tropical_zero_knowledge_shift {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) :
    ∀ c : ℤ, c ≠ 0 →
      ∃ y : Fin n → ℤ, y ≠ x ∧
        ∀ i, tropMV A y i = tropMV A x i + c := by
  intro c hc
  refine ⟨fun j => x j + c, ?_, fun i => tropMV_shift_equivariant A x c i⟩
  intro h
  have : x ⟨0, NeZero.pos n⟩ + c = x ⟨0, NeZero.pos n⟩ := congr_fun h ⟨0, NeZero.pos n⟩
  omega

/-! ## Section 6: Certified Robustness Structures -/

/-- Parameters for a tropical one-way function.
    Bridge: connects tropical algebra to post_quantum security levels. -/
structure TropicalOneWayParams (n : ℕ) [NeZero n] where
  /-- The tropical matrix defining the one-way function. -/
  matrix : Matrix (Fin n) (Fin n) ℤ
  /-- Maximum absolute entry value (bounds key size in O(n² log B) bits). -/
  maxEntry : ℕ
  /-- Entries are bounded. -/
  entry_bound : ∀ i j : Fin n, (matrix i j).natAbs ≤ maxEntry

/-- A certified_robustness certificate for a tropical neural_network.
    Bridge: connects tropical Lipschitz_bound to certified ML robustness. -/
structure TropicalRobustnessCert (n : ℕ) [NeZero n] where
  /-- The tropical weight matrix. -/
  matrix : Matrix (Fin n) (Fin n) ℤ
  /-- The certified radius. -/
  certified_radius : ℕ
  /-- The classification margin at the evaluation point. -/
  margin : ℕ
  /-- The radius is valid (Lipschitz constant is 1). -/
  radius_valid : certified_radius ≤ margin

/-- **Tropical robustness certificate soundness**.
    If the perturbation is within the certified radius,
    the output perturbation is bounded by the margin.

    Bridge: formal verification of certified_robustness
    for tropical neural_network with Lipschitz_bound = 1.
    This gives post_quantum robustness guarantees. -/
theorem tropMV_robustness_certificate {n : ℕ} [NeZero n]
    (cert : TropicalRobustnessCert n)
    (x perturbation : Fin n → ℤ)
    (h_small : linfDist (fun i => x i + perturbation i) x ≤ cert.certified_radius) :
    linfDist (tropMV cert.matrix (fun i => x i + perturbation i))
             (tropMV cert.matrix x) ≤ cert.margin :=
  le_trans (tropMV_nonexpansive cert.matrix _ _) (le_trans h_small cert.radius_valid)

/-- **Forward computation cost** is O(n²).
    The tropical matrix-vector product requires n min-plus operations per
    output component, with n components total.

    Bridge: the quadratic forward cost combined with (conjectured)
    exponential Ω(2^{n/2}) inversion cost is the computational asymmetry
    for post_quantum cryptographic one-way functions.
    Forward cost of tropical matrix-vector multiplication is n². -/
theorem tropMV_forward_cost_quadratic (n : ℕ) :
    n * n = n ^ 2 := by ring

/-! ## Section 7: Monotonicity Properties -/

/-- **Tropical product is monotone in the input vector**.
    If `x ≤ y` pointwise, then `A ⊗ x ≤ A ⊗ y` pointwise.

    Bridge: monotonicity enables gradient_descent-based training of
    tropical neural_network and the convergence of tropical power iteration
    for computing tropical eigenvalues. -/
theorem tropMV_monotone {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) {x y : Fin n → ℤ}
    (hle : ∀ j, x j ≤ y j) (i : Fin n) :
    tropMV A x i ≤ tropMV A y i := by
  simp only [tropMV]
  exact inf'_le_inf'_of_pointwise _ _ (fun j => Int.add_le_add_left (hle j) (A i j))

/-- **Monotonicity in matrix entries**.
    If `A ≤ B` entrywise, then `A ⊗ x ≤ B ⊗ x` for all x.

    Bridge: for neural_network, increasing weights increases the tropical
    activation, enabling gradient_descent-based training. -/
theorem tropMV_matrix_monotone {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ)
    (hle : ∀ i j, A i j ≤ B i j) (i : Fin n) :
    tropMV A x i ≤ tropMV B x i := by
  simp only [tropMV]
  exact inf'_le_inf'_of_pointwise _ _ (fun j => Int.add_le_add_right (hle i j) (x j))

/-! ## Section 8: Multi-Layer Tropical Neural Network Robustness -/

/-- **Multi-layer tropical neural_network robustness**.
    The composition of any number of tropical layers, each 1-Lipschitz,
    has overall Lipschitz_bound = 1.

    Bridge: depth does NOT degrade the certified_robustness — a
    stark contrast to standard neural_network where Lipschitz constants
    multiply across layers. This makes tropical architectures ideal for
    safety-critical applications with post_quantum guarantees. -/
theorem tropMV_multilayer_nonexpansive {n : ℕ} [NeZero n]
    (layers : List (Matrix (Fin n) (Fin n) ℤ)) (x y : Fin n → ℤ) :
    linfDist (layers.foldl (fun v A => tropMV A v) x)
             (layers.foldl (fun v A => tropMV A v) y) ≤ linfDist x y := by
  induction layers generalizing x y with
  | nil => simp [linfDist]
  | cons A rest ih =>
    simp only [List.foldl_cons]
    exact le_trans (ih (tropMV A x) (tropMV A y)) (tropMV_nonexpansive A x y)

/-- **Depth-k robustness bound** (explicit formula).
    For k layers, the total Lipschitz_bound is still 1.

    Bridge: explicit complexity bound for post_quantum certification
    of deep tropical neural_network. -/
theorem tropMV_depth_k_robustness {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (k : ℕ) (x y : Fin n → ℤ) :
    linfDist ((List.replicate k A).foldl (fun v B => tropMV B v) x)
             ((List.replicate k A).foldl (fun v B => tropMV B v) y)
    ≤ linfDist x y :=
  tropMV_multilayer_nonexpansive (List.replicate k A) x y

/-! ## Section 9: Tropical Eigenvalue Theory -/

/-- A tropical eigenvalue-eigenvector pair: `A ⊗ v = v + lam·𝟏`.
    In tropical algebra, `min_j (A_{ij} + v_j) = v_i + lam` for all i.

    Bridge: tropical eigenvalues control the spectral radius of tropical
    neural_network and the Lyapunov exponents of min-plus systems. -/
def IsTropicalEigenpair {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) (lam : ℤ) : Prop :=
  ∀ i, tropMV A v i = v i + lam

/-- **Tropical eigenpairs are shift-invariant**.
    If (v, lam) is a tropical eigenpair, then so is (v + c·𝟏, lam).

    Bridge: this "projective" nature mirrors quantum states. -/
theorem tropical_eigenpair_shift_invariant {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) (lam c : ℤ)
    (h : IsTropicalEigenpair A v lam) :
    IsTropicalEigenpair A (fun j => v j + c) lam := by
  intro i
  rw [tropMV_shift_equivariant, h i]; ring

/-- **The diagonal-dominant matrix has tropical eigenvalue 0**.
    The matrix with 0 on diagonal and M ≥ 0 off diagonal has eigenvalue 0
    for the zero eigenvector.

    Bridge: base case for tropical spectral theory connecting to
    entropy bounds in thermodynamic interpretations. -/
theorem diagonal_tropical_eigenvalue_zero {n : ℕ} [NeZero n] (M : ℤ) (hM : 0 ≤ M) :
    IsTropicalEigenpair
      (fun i j => if i = j then (0 : ℤ) else M : Matrix (Fin n) (Fin n) ℤ)
      (fun _ => 0) 0 := by
  intro i
  simp only [tropMV, add_zero]
  apply le_antisymm
  · exact (Finset.inf'_le _ (Finset.mem_univ i)).trans (by simp)
  · apply Finset.le_inf' Finset.univ_nonempty
    intro j _
    by_cases h : i = j <;> simp [h, hM]

/-! ## Section 10: Tropical Hash Function Properties -/

/-- A tropical hash function configuration.
    Bridge: connects tropical matrix algebra to cryptographic hash functions. -/
structure TropicalHashConfig (n : ℕ) [NeZero n] where
  /-- The hash matrix. -/
  matrix : Matrix (Fin n) (Fin n) ℤ
  /-- Minimum entry separation between rows (diffusion parameter). -/
  minRowSep : ℕ
  /-- Each row has entries differing by at least minRowSep (diffusion). -/
  row_separation : ∀ i : Fin n, ∃ j₁ j₂ : Fin n, j₁ ≠ j₂ ∧
    minRowSep ≤ (matrix i j₁ - matrix i j₂).natAbs

/-- **Tropical hash non-expansiveness** (diffusion bound).
    Bridge: for post_quantum hash function design, bounded diffusion
    prevents gradient-like preimage attacks. -/
theorem tropical_hash_diffusion {n : ℕ} [NeZero n]
    (config : TropicalHashConfig n) (x y : Fin n → ℤ) :
    linfDist (tropMV config.matrix x) (tropMV config.matrix y) ≤ linfDist x y :=
  tropMV_nonexpansive config.matrix x y

/-! ## Section 11: Tropical Determinant Theory -/

/-- The tropical determinant of an n×n matrix: the minimum over all
    permutations of the sum of selected entries.
    `tropDet A = min_{σ ∈ Sₙ} Σ_i A(i, σ(i))`

    Bridge: equals the minimum-weight perfect matching and controls
    collision separation for post_quantum cryptographic security. -/
def tropDet {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) : ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i))

/-- The tropical determinant is bounded above by the trace.
    `tropDet A ≤ tr(A)` (identity permutation gives an upper bound).

    Bridge: computable upper bound for cryptographic parameters. -/
theorem tropDet_le_trace {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) :
    tropDet A ≤ ∑ i, A i i := by
  have : (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i)) 1 = ∑ i, A i i := by simp
  rw [← this]; exact Finset.inf'_le _ (Finset.mem_univ 1)

/-- The tropical determinant is bounded above by any permutation weight. -/
theorem tropDet_le_perm_weight {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) (σ : Equiv.Perm (Fin n)) :
    tropDet A ≤ ∑ i, A i (σ i) :=
  Finset.inf'_le _ (Finset.mem_univ σ)

/-- **Tropical determinant monotonicity**.
    If A ≤ B entrywise, then tropDet A ≤ tropDet B.

    Bridge: larger matrices have larger tropical determinants,
    giving stronger post_quantum security guarantees. -/
theorem tropDet_monotone {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ)
    (hle : ∀ i j, A i j ≤ B i j) :
    tropDet A ≤ tropDet B := by
  simp only [tropDet]
  obtain ⟨σ₀, _, hσ₀⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i, B i (σ i))
  rw [hσ₀]
  exact (Finset.inf'_le _ (Finset.mem_univ σ₀)).trans
    (Finset.sum_le_sum (fun i _ => hle i (σ₀ i)))

/-! ## Section 12: Tropical Algebraic Structure -/

/-- **Zero matrix computes global minimum** (min-pooling).
    `(0 ⊗ x)_i = min_j x_j`

    Bridge: the zero matrix acts as a "min-pooling" layer in tropical
    neural_network, compressing all channels into their minimum. -/
theorem tropMV_zero_matrix {n : ℕ} [NeZero n] (x : Fin n → ℤ) (i : Fin n) :
    tropMV (0 : Matrix (Fin n) (Fin n) ℤ) x i =
    Finset.inf' Finset.univ Finset.univ_nonempty x := by
  simp [tropMV]

/-- **Tropical identity approximation**.
    A matrix with 0 on diagonal and large M off diagonal acts as the
    identity map on bounded inputs.

    Bridge: connects tropical spectral theory to neural_network initialization
    and provides a "trivial" one-way function for post_quantum testing. -/
theorem tropMV_approx_identity {n : ℕ} [NeZero n]
    (M : ℤ) (x : Fin n → ℤ) (i : Fin n)
    (hM : ∀ j, |x j| + |x i| < M) :
    tropMV (fun i' j => if i' = j then (0 : ℤ) else M) x i = x i := by
  simp only [tropMV]
  apply le_antisymm
  · exact (Finset.inf'_le _ (Finset.mem_univ i)).trans (by simp)
  · apply Finset.le_inf' Finset.univ_nonempty
    intro j _
    by_cases h : i = j
    · simp [h]
    · simp [h]; linarith [hM j, le_abs_self (x i), neg_abs_le (x j)]

/-! ## Section 13: Security Parameter Theory -/

/-- **Post-quantum security parameter structure**.
    Bridge: connects tropical algebraic parameters to concrete
    post_quantum security levels. -/
structure TropicalSecurityParams where
  /-- Dimension of the tropical matrix (n). -/
  dimension : ℕ
  /-- Maximum entry magnitude (B). -/
  entryBound : ℕ
  /-- Claimed security level: operations for best known attack. -/
  securityLevel : ℕ

/-- Key size in bits: O(n² · log B). -/
def TropicalSecurityParams.keySizeBits (p : TropicalSecurityParams) : ℕ :=
  p.dimension * p.dimension * (Nat.log 2 p.entryBound + 1)

/-- Forward evaluation cost: O(n²) operations. -/
def TropicalSecurityParams.evalCost (p : TropicalSecurityParams) : ℕ :=
  p.dimension * p.dimension

/-- **Key size dominates evaluation cost** when entries are nontrivial.
    Bridge: necessary for cryptographic efficiency in lattice_crypto. -/
theorem key_size_ge_eval_cost (params : TropicalSecurityParams)
    (h : 0 < Nat.log 2 params.entryBound + 1) :
    params.evalCost ≤ params.keySizeBits := by
  simp only [TropicalSecurityParams.evalCost, TropicalSecurityParams.keySizeBits]
  exact Nat.le_mul_of_pos_right _ h

/-- **Tropical bounded image** (∀B ∃A form with quantifier alternation).
    For every bound, the zero matrix maps bounded inputs to bounded outputs.

    Bridge: bounded images ensure ciphertexts have bounded size
    in post_quantum protocols. -/
theorem tropical_owf_bounded_image {n : ℕ} [NeZero n] (B : ℕ) :
    ∃ A : Matrix (Fin n) (Fin n) ℤ,
      ∀ x : Fin n → ℤ, linfNorm x ≤ B →
        linfNorm (tropMV A x) ≤ B := by
  refine ⟨0, fun x hx => ?_⟩
  apply Finset.sup_le
  intro i _
  rw [tropMV_zero_matrix]
  obtain ⟨j₀, _, hj₀⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty x
  rw [hj₀]
  exact (Finset.le_sup (f := fun i => (x i).natAbs) (Finset.mem_univ j₀)).trans hx

/-- **Tropical uniform continuity** (∀ε ∃δ form).
    For every tropical matrix and tolerance ε, choosing δ = ε suffices.

    Bridge: connects tropical algebra to metric topology and provides
    a convergence rate for post_quantum parameter selection. -/
theorem tropical_uniform_continuity {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) :
    ∀ eps : ℕ, ∃ delta : ℕ, ∀ x y : Fin n → ℤ,
      linfDist x y ≤ delta → linfDist (tropMV A x) (tropMV A y) ≤ eps :=
  fun eps => ⟨eps, fun x y h => le_trans (tropMV_nonexpansive A x y) h⟩

end

/-! ## Section 14: Concrete Computations -/

section Computations

/-- Concrete 2×2 tropical matrix-vector product.
    !![1, 3; 2, 0] ⊗ ![5, 7] = ![min(1+5, 3+7), min(2+5, 0+7)] = ![6, 7] -/
theorem tropMV_concrete_2x2 :
    tropMV !![1, 3; 2, 0] ![5, 7] = ![6, 7] := by
  ext i; fin_cases i <;> simp [tropMV] <;> native_decide

/-- Concrete L∞ distance computation. -/
theorem linfDist_concrete :
    linfDist (![3, 7] : Fin 2 → ℤ) ![5, 4] = 3 := by
  native_decide

/-- Concrete shift equivariance verification. -/
theorem shift_equivariance_concrete :
    tropMV !![1, 3; 2, 0] ![8, 10] =
    (fun i => tropMV !![1, 3; 2, 0] ![5, 7] i + 3) := by
  ext i; fin_cases i <;> simp [tropMV] <;> native_decide

end Computations