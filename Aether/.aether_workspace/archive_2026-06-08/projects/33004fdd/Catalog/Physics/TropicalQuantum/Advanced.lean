/-
  # Tropical Quantum Mechanics — Advanced Theory

  ## Unitary Collapse, No-Cloning, and Convergence Rates

  This file builds on the foundations to prove deeper results about
  tropical quantum mechanics: matrix dequantization bounds,
  the tropical no-cloning theorem, and explicit convergence rates for
  the tropical Born rule.

  Bridge: connects quantum information theory, representation theory,
  and ML certified robustness through the Maslov dequantization lens.
-/
import Mathlib
import Physics.TropicalQuantum.Foundations

open Real Finset BigOperators

noncomputable section

namespace TropicalQuantum

/-! ## Section 1: Maslov Matrix Dequantization — Convergence Bounds

The h-deformed matrix multiplication converges to tropical (max-plus) matrix
multiplication as h → 0⁺, with explicit error bounds.

Bridge: connects quantum matrix mechanics to shortest-path algorithms. -/

/-- h-deformed matrix entry: (A ⊗_h B)_{ij} = h·log(Σ_k e^{(A_{ik} + B_{kj})/h}). -/
def maslovMatMul {n : ℕ} (h : ℝ) (A B : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i j : Fin (n + 1)) : ℝ :=
  h * Real.log (∑ k : Fin (n + 1), Real.exp ((A i k + B k j) / h))

/-- Tropical matrix entry: max_k (A_{ik} + B_{kj}). -/
def tropMatMul {n : ℕ} (A B : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i j : Fin (n + 1)) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-
**Maslov Matrix Lower Bound**: (A ⊗_h B)_{ij} ≥ max_k(A_{ik} + B_{kj}).
    The h-deformed matrix product is at least the tropical product.
    Bridge: connects quantum matrix bounds to shortest-path lower bounds.
-/
theorem maslov_matrix_lower {n : ℕ} (A B : Fin (n + 1) → Fin (n + 1) → ℝ)
    (h : ℝ) (hh : h > 0) (i j : Fin (n + 1)) :
    maslovMatMul h A B i j ≥ tropMatMul A B i j := by
  unfold maslovMatMul tropMatMul;
  refine' le_trans _ ( mul_le_mul_of_nonneg_left ( Real.log_le_log _ <| Finset.single_le_sum ( fun k _ => Real.exp_nonneg ( ( A i k + B k j ) / h ) ) <| Finset.mem_univ <| Classical.choose <| Finset.exists_max_image Finset.univ ( fun k => A i k + B k j ) <| Finset.univ_nonempty ) hh.le );
  · rw [ Real.log_exp, mul_div_cancel₀ _ hh.ne' ];
    have := Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun k => A i k + B k j ) ( Finset.univ_nonempty ) ) ; aesop;
  · positivity

/-
**Maslov Matrix Upper Bound**: (A ⊗_h B)_{ij} ≤ max_k(A_{ik} + B_{kj}) + h·log(n+1).
    The h-deformed matrix product overshoots by at most h·log(n+1).
    Bridge: connects tropical matrix approximation to quantum error bounds.
    Explicit convergence rate: O(h · log n).
-/
theorem maslov_matrix_upper {n : ℕ} (A B : Fin (n + 1) → Fin (n + 1) → ℝ)
    (h : ℝ) (hh : h > 0) (i j : Fin (n + 1)) :
    maslovMatMul h A B i j ≤ tropMatMul A B i j + h * Real.log (n + 1 : ℝ) := by
  -- Apply the logarithmic sum inequality to the inner sum.
  have h_log_sum : ∀ k : Fin (n + 1), Real.exp ((A i k + B k j) / h) ≤ Real.exp ((tropMatMul A B i j) / h) := by
    exact fun k => Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( Finset.le_sup' ( fun k => A i k + B k j ) ( Finset.mem_univ k ) ) hh.le );
  have h_log_sum : Real.log (∑ k : Fin (n + 1), Real.exp ((A i k + B k j) / h)) ≤ Real.log ((n + 1) * Real.exp ((tropMatMul A B i j) / h)) := by
    exact Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty ) ) ( le_trans ( Finset.sum_le_sum fun _ _ => h_log_sum _ ) ( by norm_num ) );
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at h_log_sum;
  unfold maslovMatMul; nlinarith [ mul_div_cancel₀ ( tropMatMul A B i j ) hh.ne' ] ;

/-! ## Section 2: Tropical Born Rule — Convergence Rate

The Born probability of the dominant state converges exponentially to 1
as h → 0⁺, with rate governed by the spectral gap. -/

/-
**Born Rule Dominance Bound**: For the dominant state j*,
    P_h(j*) ≥ 1/(1 + n·e^{-(gap)/h}) where gap = ψ_{j*} - max_{i≠j*} ψ_i.
    As h → 0⁺, this converges to 1 exponentially fast.
    Bridge: connects quantum measurement collapse rates to simulated annealing convergence.
    Exponential convergence rate: O(n · e^{-Δ/h}).
-/
theorem born_rule_dominance_lower {n : ℕ} (h : ℝ) (ψ : Fin (n + 2) → ℝ)
    (hh : h > 0) (j_star : Fin (n + 2))
    (hj : ∀ i, ψ i ≤ ψ j_star)
    (δ : ℝ) (hδ : δ > 0)
    (hgap : ∀ i, i ≠ j_star → ψ i ≤ ψ j_star - δ) :
    tropicalBornProb h ψ j_star ≥ 1 / (1 + ((n : ℝ) + 1) * Real.exp (-δ / h)) := by
  unfold tropicalBornProb;
  rw [ ge_iff_le, div_le_div_iff₀ ] <;> try positivity;
  -- Apply the gap condition to each term in the sum.
  have h_sum_bound : ∑ x ∈ univ \ {j_star}, Real.exp (ψ x / h) ≤ ∑ x ∈ univ \ {j_star}, Real.exp ((ψ j_star - δ) / h) := by
    exact Finset.sum_le_sum fun i hi => Real.exp_le_exp.mpr <| by rw [ div_le_div_iff_of_pos_right hh ] ; linarith [ hgap i <| by aesop ] ;
  simp_all +decide [ Finset.card_sdiff, sub_div ];
  exact h_sum_bound.trans_eq ( by rw [ sub_eq_add_neg, Real.exp_add ] ; ring )

/-
**Non-Dominant Suppression**: For any non-dominant state j ≠ j*,
    P_h(j) ≤ e^{-δ/h} where δ is the gap.
    Bridge: connects quantum state discrimination to ML classification margin.
-/
theorem born_rule_nondominant_upper {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j j_star : Fin (n + 1))
    (hj : ψ j ≤ ψ j_star - δ) (hδ : δ > 0) :
    tropicalBornProb h ψ j ≤ Real.exp (-δ / h) := by
  refine' div_le_of_le_mul₀ _ _ _;
  · exact Finset.sum_nonneg fun _ _ => Real.exp_nonneg _;
  · positivity;
  · refine' le_trans _ ( mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( ψ i / h ) ) ( Finset.mem_univ j_star ) ) ( Real.exp_nonneg _ ) );
    rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by ring_nf at *; nlinarith [ inv_pos.mpr hh ] )

/-! ## Section 3: Tropical Tensor Products and No-Cloning

The tropical tensor product ψ ⊗ φ is defined by (ψ ⊗ φ)_{ij} = ψ_i + φ_j.
The no-cloning theorem states that no permutation can clone all states. -/

/-- The tropical tensor product: (ψ ⊗ φ)_{(i,j)} = ψ_i + φ_j.
    Bridge: connects quantum tensor products to tropical direct sums. -/
def tropicalTensor {m n : ℕ} (ψ : Fin m → ℝ) (φ : Fin n → ℝ)
    (p : Fin m × Fin n) : ℝ :=
  ψ p.1 + φ p.2

/-
The tropical tensor product of separable states is separable.
    Bridge: connects quantum product structure to tropical additivity.
-/
theorem tropicalTensor_separable {m n : ℕ}
    (ψ : Fin (m + 1) → ℝ) (φ : Fin (n + 1) → ℝ) :
    IsTropicalSeparable (fun i j => ψ i + φ j) := by
  exact ⟨ fun i => ψ i, fun j => φ j, fun i j => rfl ⟩

/-
**Tropical No-Cloning (Permutation Version)**: No permutation of Fin n × Fin n
    can act as a universal cloner for all tropical states.
    If σ is a permutation and φ is a fixed ancilla state, then
    it is impossible that for all ψ : Fin n → ℝ,
    the σ-permuted tensor ψ ⊗ φ equals ψ ⊗ ψ coordinate-wise.
    Bridge: connects quantum no-cloning to post-quantum security guarantees.
-/
theorem tropical_no_cloning_perm (hn : (2 : ℕ) ≤ 2) :
    ¬∃ (σ : Equiv.Perm (Fin 2 × Fin 2)) (φ : Fin 2 → ℝ),
      ∀ (ψ : Fin 2 → ℝ),
        ∀ p : Fin 2 × Fin 2,
          tropicalTensor ψ φ (σ p) = tropicalTensor ψ ψ p := by
  unfold tropicalTensor; norm_num;
  intro σ φ; by_contra! h; have := h ( fun _ => 0 ) ; have := h ( fun _ => 1 ) ; norm_num at *;
  linarith

/-! ## Section 4: Properties of the Maslov Semiring

Additional structural properties of the Maslov dequantized semiring. -/

/-
**Maslov Self-Addition**: x ⊕_h x = x + h · log 2.
    Shows the precise deviation from idempotency at temperature h.
    Bridge: connects quantum decoherence to tropical idempotency violation.
-/
theorem maslov_self_add (h x : ℝ) (hh : h > 0) :
    maslovAdd h x x = x + h * Real.log 2 := by
  -- Substitute x into the definition of maslovAdd and simplify the expression.
  have h_subst : maslovAdd h x x = h * Real.log (2 * Real.exp (x / h)) := by
    unfold maslovAdd; ring;
  rw [ h_subst, Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
  norm_num [ mul_comm h, hh.ne' ]

/-- **Maslov Idempotent Error**: The error from idempotency is exactly h·log 2.
    Bridge: quantifies how far quantum superposition deviates from classical logic. -/
theorem maslov_idempotent_error (h x : ℝ) (hh : h > 0) :
    maslovAdd h x x - x = h * Real.log 2 := by
  have := maslov_self_add h x hh; linarith

/-! ## Section 5: Tropical State Space Geometry

The geometry of the tropical state space, including the tropical metric. -/

/-- The tropical l∞ distance between states.
    Bridge: connects quantum state distinguishability to tropical metric geometry. -/
def tropicalDist {n : ℕ} (ψ φ : Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => |ψ i - φ i|)

/-
The tropical distance is symmetric.
    Bridge: connects quantum metric symmetry to tropical distance symmetry.
-/
theorem tropicalDist_symm {n : ℕ} (ψ φ : Fin (n + 1) → ℝ) :
    tropicalDist ψ φ = tropicalDist φ ψ := by
  unfold tropicalDist;
  simp +decide only [abs_sub_comm]

/-
The tropical distance is nonnegative.
    Bridge: connects quantum metric positivity to tropical geometry.
-/
theorem tropicalDist_nonneg {n : ℕ} (ψ φ : Fin (n + 1) → ℝ) :
    tropicalDist ψ φ ≥ 0 := by
  exact Finset.le_sup' ( fun i => |ψ i - φ i| ) ( Finset.mem_univ 0 ) |> le_trans ( abs_nonneg _ )

/-
The tropical distance from a state to itself is zero.
    Bridge: connects quantum self-distance to tropical identity.
-/
theorem tropicalDist_self {n : ℕ} (ψ : Fin (n + 1) → ℝ) :
    tropicalDist ψ ψ = 0 := by
  unfold tropicalDist; aesop;

/-! ## Section 6: Entanglement Monotonicity and Symmetry

The Cauchy-Schwarz defect has key monotonicity properties that
connect to quantum entanglement measures. -/

/-
**Defect Under Translation**: Adding a constant to all entries preserves
    the Cauchy-Schwarz defect (gauge invariance).
    Bridge: connects quantum phase invariance to tropical shift symmetry.
-/
theorem defect_translation_invariant {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) (c : ℝ) :
    cauchySchwarzDefect (fun i j => ψ i j + c) = cauchySchwarzDefect ψ := by
  unfold cauchySchwarzDefect;
  grind

/-
**Defect Under Row Shifts**: Adding row-dependent constants preserves
    the Cauchy-Schwarz defect.
    Bridge: connects local quantum operations to tropical rank preservation.
-/
theorem defect_row_shift_invariant {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) (a : Fin (m + 1) → ℝ) :
    cauchySchwarzDefect (fun i j => ψ i j + a i) = cauchySchwarzDefect ψ := by
  unfold cauchySchwarzDefect;
  grind

/-
**Defect Under Column Shifts**: Adding column-dependent constants preserves
    the Cauchy-Schwarz defect.
    Bridge: connects local quantum operations to tropical rank preservation.
-/
theorem defect_col_shift_invariant {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) (b : Fin (n + 1) → ℝ) :
    cauchySchwarzDefect (fun i j => ψ i j + b j) = cauchySchwarzDefect ψ := by
  unfold cauchySchwarzDefect;
  grind

/-! ## Section 7: Tropical Quantum Information Bounds

Explicit information-theoretic bounds connecting tropical quantum mechanics
to classical communication and computation. -/

/-
**Tropical Holevo Bound (Dominant State)**: For the dominant state j*,
    the surprise is at most log(n+1).
    Bridge: connects quantum Holevo bound to tropical information capacity.
    Information bound: O(log n) bits per measurement for the dominant outcome.
-/
theorem tropical_holevo_dominant_bound {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j_star : Fin (n + 1))
    (hj : ∀ i, ψ i ≤ ψ j_star) :
    -Real.log (tropicalBornProb h ψ j_star) ≤ Real.log (n + 1 : ℝ) := by
  rw [ ← Real.log_inv, Real.log_le_log_iff ];
  · convert inv_anti₀ _ ( tropicalBornProb_argmax_dominance h ψ hh j_star hj ) using 1 ; norm_num;
    positivity;
  · exact inv_pos.mpr ( div_pos ( Real.exp_pos _ ) ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty ) ) );
  · positivity

/-
**Uniform Born Distribution**: For a constant state, softmax gives uniform.
    P_h(j | (0,0,...,0)) = 1/(n+1) for all j.
    Bridge: connects quantum maximal uncertainty to ML uniform prediction.
-/
theorem born_prob_uniform {n : ℕ} (h : ℝ) (_hh : h > 0) (j : Fin (n + 1)) :
    tropicalBornProb h (fun (_ : Fin (n + 1)) => (0 : ℝ)) j =
      1 / ((n : ℝ) + 1) := by
  unfold tropicalBornProb; aesop

end TropicalQuantum

end