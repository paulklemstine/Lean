/-
# Tropical Transfer Operators: Core Definitions and Basic Properties

This file establishes the foundations of tropical (max-plus) transfer operator theory
on finite state spaces `Fin (n+1)`. The tropical transfer operator
  `(T_M v)(i) = max_j (M i j + v j)`
is the max-plus analogue of a Markov/transfer matrix. It is the Bellman operator for
deterministic finite-state optimal control and the idempotent shadow of a quantum
transfer matrix.

## Main definitions

* `tropTransfer` — The tropical (max-plus) transfer operator
* `IsTropEigenpair` — Tropical eigenpair predicate: `T_M v = lam + v`
* `oscNorm` — Oscillation seminorm on potentials
* `normalizedTropTransfer` — Gauge-fixed transfer (subtract value at coordinate 0)
* `sameArgmaxPattern` — Two matrices have the same argmax pattern
* `universalityInvariant` — The set of dominant edges (argmax pairs)
* `tropicalGap` — Spectral gap between top eigenvalue and a secondary value
* `criticalExponent` — Inverse of the spectral gap

## Main results

* `tropTransfer_add_const` — Additive homogeneity: T_M(v + c·1) = T_M(v) + c·1
* `tropTransfer_monotone` — Monotonicity: v ≤ w → T_M v ≤ T_M w
* `oscNorm_nonneg` — Oscillation seminorm is nonneg
* `universality_invariant_constant_on_cells` — Universality invariant is constant on cells
* `critical_exponent_pos` — Positive gap implies positive critical exponent
-/

import Mathlib

open Matrix Finset BigOperators

noncomputable section

namespace TropicalTransfer

variable {n : ℕ}

/-! ## §1. The Tropical Transfer Operator -/

/-- The tropical (max-plus) transfer operator on `Fin (n+1) → ℝ`.
Given a matrix `M` and a potential `v`, produces a new potential where each
coordinate is the maximum over columns of `M i j + v j`. This is the Bellman
operator for deterministic finite-state control / dynamic programming. -/
def tropTransfer (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (v : Fin (n+1) → ℝ) :
    Fin (n+1) → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => M i j + v j)

/-- A tropical eigenpair `(lam, v)` of `M` satisfies `T_M(v) = lam + v` pointwise. -/
def IsTropEigenpair (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (lam : ℝ) (v : Fin (n+1) → ℝ) :
    Prop :=
  ∀ i, tropTransfer M v i = lam + v i

/-! ## §2. Additive Homogeneity and Monotonicity -/

/-
The tropical transfer operator is additively homogeneous:
adding a constant to the potential shifts the output by the same constant.
This is the max-plus analogue of linearity.
-/
theorem tropTransfer_add_const (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (v : Fin (n+1) → ℝ)
    (c : ℝ) :
    tropTransfer M (fun j => v j + c) = fun i => tropTransfer M v i + c := by
  unfold tropTransfer;
  simp +decide only [← add_assoc];
  ext i;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup' ];
  · exact fun j => ⟨ j, le_rfl ⟩;
  · simpa using Finset.exists_max_image Finset.univ ( fun j => M i j + v j ) ⟨ i, Finset.mem_univ i ⟩

/-
The tropical transfer operator is monotone (order-preserving):
if `v ≤ w` pointwise, then `T_M v ≤ T_M w` pointwise.
This is a fundamental structural property of max-plus linear maps.
-/
theorem tropTransfer_monotone (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Monotone (tropTransfer M) := by
  intro v w hvw;
  intros i
  simp [tropTransfer, hvw];
  cases' Finset.exists_max_image Finset.univ ( fun j => M i j + w j ) ( Finset.univ_nonempty ) with j hj ; use j ; intro k ; linarith [ hj.2 k ( Finset.mem_univ k ), hvw k ]

/-! ## §3. Oscillation Seminorm -/

/-- The oscillation seminorm of a potential `v : Fin (n+1) → ℝ`,
defined as `max v - min v`. This measures the "spread" of the potential
and is the natural seminorm for tropical spectral theory. -/
def oscNorm (v : Fin (n+1) → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty v - Finset.univ.inf' Finset.univ_nonempty v

/-
The oscillation seminorm is always nonneg.
-/
theorem oscNorm_nonneg (v : Fin (n+1) → ℝ) : 0 ≤ oscNorm v := by
  exact sub_nonneg_of_le ( Finset.le_sup' ( fun x ↦ v x ) ( Finset.mem_univ ( Classical.choose ( Finset.exists_max_image Finset.univ v ( Finset.univ_nonempty ) ) ) ) |> le_trans ( Finset.inf'_le _ ( Classical.choose_spec ( Finset.exists_max_image Finset.univ v ( Finset.univ_nonempty ) ) |>.1 ) ) )

/-! ## §4. Normalized Tropical Transfer -/

/-- The normalized tropical transfer subtracts the value at coordinate `0`
after applying the transfer. This "gauge-fixes" the operator so that
fixed points are genuine fixed points rather than eigenvectors.
Physically, this corresponds to working modulo the additive gauge symmetry
of the max-plus semiring. -/
def normalizedTropTransfer (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (v : Fin (n+1) → ℝ) :
    Fin (n+1) → ℝ :=
  let w := tropTransfer M v
  fun i => w i - w 0

/-
The normalized transfer always sends coordinate 0 to 0.
-/
theorem normalizedTropTransfer_zero (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (v : Fin (n+1) → ℝ) : normalizedTropTransfer M v 0 = 0 := by
  exact sub_self _

/-
The oscillation of the normalized transfer is bounded by
the oscillation of the original transfer.
-/
theorem oscNorm_normalizedTropTransfer_bounded (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (v : Fin (n+1) → ℝ) :
    oscNorm (normalizedTropTransfer M v) ≤ oscNorm (tropTransfer M v) := by
  unfold oscNorm normalizedTropTransfer;
  simp +decide [ sub_eq_add_neg ];
  obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun x => tropTransfer M v x );
  obtain ⟨ c, hc ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => tropTransfer M v x );
  obtain ⟨ d, hd ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun x => tropTransfer M v x + -tropTransfer M v 0 ) ; obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => tropTransfer M v x + -tropTransfer M v 0 ) ; use b; simp_all +decide [ Finset.sup'_eq_sup, Finset.inf'_eq_inf ] ;
  linarith [ show tropTransfer M v d ≤ tropTransfer M v b from hb ▸ Finset.le_sup' ( fun x => tropTransfer M v x ) ( Finset.mem_univ _ ), show tropTransfer M v e ≥ tropTransfer M v c from hc ▸ Finset.inf'_le _ ( Finset.mem_univ _ ) ]

/-! ## §5. Eigenpair from Normalized Fixed Point -/

/-
If `v` is a fixed point of `normalizedTropTransfer M`, then
`(tropTransfer M v 0, v)` is a tropical eigenpair of `M`.
This shows that normalized fixed points immediately yield tropical eigenvectors.
-/
theorem eigenpair_of_normalized_fixed_point (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (v : Fin (n+1) → ℝ) (hv : normalizedTropTransfer M v = v) :
    IsTropEigenpair M (tropTransfer M v 0) v := by
  unfold normalizedTropTransfer at hv;
  exact fun i => by have := congr_fun hv i; norm_num at *; linarith;

/-! ## §6. Iteration and Invariance -/

/-
If `v` is a normalized fixed point, then iterating the normalized
transfer preserves it. This is the formal content of "RG invariance":
the fixed point is stable under coarse-graining.
-/
theorem normalized_fixed_point_iter_invariant (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (v : Fin (n+1) → ℝ) (hv : normalizedTropTransfer M v = v) (k : ℕ) :
    (normalizedTropTransfer M)^[k] v = v := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-
If `(lam, v)` is a tropical eigenpair, then after k iterations of the
transfer, we get `k * lam + v`. This is the tropical spectral mapping theorem.
-/
theorem eigenpair_of_iterate (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (lam : ℝ) (v : Fin (n+1) → ℝ) (hv : IsTropEigenpair M lam v) (k : ℕ) :
    ∀ i, (tropTransfer M)^[k] v i = k * lam + v i := by
  induction' k with k ih;
  · norm_num;
  · intro i; specialize hv i; simp_all +decide [ Function.iterate_succ_apply', add_mul ] ;
    convert tropTransfer_add_const M ( fun j => v j ) ( k * lam ) |> congr_fun <| i using 1;
    · exact congr_arg ( fun f => tropTransfer M f i ) ( funext fun j => by rw [ ih j, add_comm ] );
    · linarith

/-! ## §7. Universality Cells and Argmax Patterns -/

/-- Two matrices have the same argmax pattern if the ordering of
`M i j` agrees for all row indices `i` and column pairs `(j, k)`.
This defines an equivalence relation whose classes are the
"tropical universality cells." -/
def sameArgmaxPattern (M N : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  ∀ i j k, M i j ≥ M i k ↔ N i j ≥ N i k

/-- The universality invariant: for each row, the set of column indices
achieving the maximum value. This is the combinatorial skeleton of the
tropical transfer operator. -/
def universalityInvariant (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Fin (n+1) → Finset (Fin (n+1)) :=
  fun i => Finset.univ.filter (fun j =>
    ∀ k, M i j ≥ M i k)

/-
The universality invariant is constant on argmax cells:
if two matrices have the same ordering pattern, they have the
same universality invariant. This is the formal content of
"universality": within each cell of parameter space, the
combinatorial structure of the transfer operator is frozen.
-/
theorem universality_invariant_constant_on_cells
    (M N : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hcell : sameArgmaxPattern M N) :
    universalityInvariant M = universalityInvariant N := by
  -- Unfold `universalityInvariant` to compare the sets.
  funext i
  simp [universalityInvariant];
  ext j; specialize hcell i j; aesop;

/-
The argmax pattern relation is reflexive.
-/
theorem sameArgmaxPattern_refl (M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    sameArgmaxPattern M M := by
  exact fun i j k => Iff.rfl

/-
The argmax pattern relation is symmetric.
-/
theorem sameArgmaxPattern_symm {M N : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (h : sameArgmaxPattern M N) : sameArgmaxPattern N M := by
  exact fun i j k => ( h i j k ).symm

/-
The argmax pattern relation is transitive.
-/
theorem sameArgmaxPattern_trans {M N P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (h1 : sameArgmaxPattern M N) (h2 : sameArgmaxPattern N P) :
    sameArgmaxPattern M P := by
  exact fun i j k => ( h1 i j k ).trans ( h2 i j k )

/-
The number of distinct universality invariant functions is finite
(bounded by the finite number of functions `Fin (n+1) → Finset (Fin (n+1))`).
-/
theorem argmax_patterns_finite :
    Set.Finite {f : Fin (n+1) → Finset (Fin (n+1)) | ∃ M : Matrix (Fin (n+1)) (Fin (n+1)) ℝ,
      universalityInvariant M = f} := by
  exact Set.toFinite _

/-! ## §8. Tropical Spectral Gap and Critical Exponent -/

/-- The tropical spectral gap between a top eigenvalue and a secondary value. -/
def tropicalGap (lam1 lam2 : ℝ) : ℝ := lam1 - lam2

/-- The critical exponent / correlation length, defined as the inverse
of the spectral gap. This is the tropical analogue of the relaxation time
in statistical mechanics. -/
def criticalExponent (lam1 lam2 : ℝ) : ℝ := 1 / (lam1 - lam2)

/-
A positive spectral gap yields a positive critical exponent.
-/
theorem critical_exponent_pos (lam1 lam2 : ℝ) (hgap : lam2 < lam1) :
    0 < criticalExponent lam1 lam2 := by
  exact one_div_pos.mpr ( sub_pos.mpr hgap )

/-
The critical exponent is monotone decreasing in the gap:
a larger gap (smaller `lam2`) means a smaller (faster-decaying) critical exponent.
If `lam2' ≤ lam2`, the gap `lam1 - lam2'` is at least as large as `lam1 - lam2`,
so the critical exponent `1/(lam1 - lam2')` is at most `1/(lam1 - lam2)`.
-/
theorem critical_exponent_antitone (lam1 lam2 lam2' : ℝ)
    (hgap : lam2 < lam1) (hgap' : lam2' < lam1) (h : lam2' ≤ lam2) :
    criticalExponent lam1 lam2' ≤ criticalExponent lam1 lam2 := by
  unfold criticalExponent;
  rw [ div_le_div_iff₀ ] <;> linarith

/-
Gap-time duality: the critical exponent times the gap equals 1.
This is the tropical analogue of the uncertainty relation.
-/
theorem gap_time_duality (lam1 lam2 : ℝ) (hgap : lam2 < lam1) :
    tropicalGap lam1 lam2 * criticalExponent lam1 lam2 = 1 := by
  exact mul_div_cancel₀ _ ( sub_ne_zero_of_ne hgap.ne' )

/-! ## §9. Concrete 2×2 Eigenpair -/

/-
For a 2×2 matrix, explicitly construct the tropical eigenpair.
The eigenvalue is the maximum cycle mean: max(M 0 0, M 1 1, (M 0 1 + M 1 0)/2).
This demonstrates that the theory is not vacuous and provides
a template for computational verification.
-/
theorem exists_eigenpair_2x2 (M : Matrix (Fin 2) (Fin 2) ℝ) :
    ∃ (lam : ℝ) (v : Fin 2 → ℝ), IsTropEigenpair M lam v := by
  unfold IsTropEigenpair;
  simp +decide [ Fin.forall_fin_two, tropTransfer ];
  simp +decide [ Fin.univ_succ ];
  by_contra! h_contra;
  -- Let's choose any $v_0$ and $v_1$ such that $v_0 = 0$ and $v_1 = \max(M_{10}, M_{11} + v_1) - \max(M_{00}, M_{01} + v_1)$.
  obtain ⟨v1, hv1⟩ : ∃ v1 : ℝ, max (M 1 0) (M 1 1 + v1) - max (M 0 0) (M 0 1 + v1) = v1 := by
    -- By the intermediate value theorem, since $f(v1)$ is continuous and $f(-∞) < 0$ and $f(∞) > 0$, there exists some $v1$ such that $f(v1) = 0$.
    have h_ivt : ∃ v1 ∈ Set.Icc (-10 - |M 1 0| - |M 1 1| - |M 0 0| - |M 0 1|) (10 + |M 1 0| + |M 1 1| + |M 0 0| + |M 0 1|), max (M 1 0) (M 1 1 + v1) - max (M 0 0) (M 0 1 + v1) - v1 = 0 := by
      apply_rules [ intermediate_value_Icc' ] <;> norm_num;
      · linarith [ abs_nonneg ( M 1 0 ), abs_nonneg ( M 1 1 ), abs_nonneg ( M 0 0 ), abs_nonneg ( M 0 1 ) ];
      · fun_prop;
      · constructor;
        · constructor <;> cases max_cases ( M 0 0 ) ( M 0 1 + ( 10 + |M 1 0| + |M 1 1| + |M 0 0| + |M 0 1| ) ) <;> cases abs_cases ( M 1 0 ) <;> cases abs_cases ( M 1 1 ) <;> cases abs_cases ( M 0 0 ) <;> cases abs_cases ( M 0 1 ) <;> linarith;
        · cases max_cases ( M 1 0 ) ( M 1 1 + ( -10 - |M 1 0| - |M 1 1| - |M 0 0| - |M 0 1| ) ) <;> cases max_cases ( M 0 0 ) ( M 0 1 + ( -10 - |M 1 0| - |M 1 1| - |M 0 0| - |M 0 1| ) ) <;> cases abs_cases ( M 1 0 ) <;> cases abs_cases ( M 1 1 ) <;> cases abs_cases ( M 0 0 ) <;> cases abs_cases ( M 0 1 ) <;> linarith;
    exact h_ivt.imp fun x hx => eq_of_sub_eq_zero hx.2;
  exact h_contra ( max ( M 0 0 ) ( M 0 1 + v1 ) ) ( fun i => if i = 0 then 0 else v1 ) ( by simp +decide ) ( by simpa [ Fin.ext_iff ] using by linarith )

end TropicalTransfer