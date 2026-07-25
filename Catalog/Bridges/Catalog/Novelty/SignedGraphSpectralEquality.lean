/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Equality cases for the spectral radius bound of signed graphs

A **signed graph** is a graph whose edges are labelled `+1` or `-1`.  Its
*signed adjacency matrix* `A` is the real symmetric matrix with `A i j ∈ {-1,0,1}`,
`A i j = 0` on the diagonal, and `A i j = A j i`.  The (unsigned) **degree** of a
vertex is `∑ j, |A i j|`, the number of incident edges, and the **maximum degree**
`Δ` dominates every row's absolute sum.

The classical "Δ-bound" states that every eigenvalue `μ` of `A` satisfies
`|μ| ≤ Δ` (so the spectral radius is at most the maximum degree).  This file
develops the bound *together with its equality cases*, in the spirit of
Sun–Das (2020) and Lan et al. (2023):

* `eigenvalue_abs_le_maxDeg` — the Δ-bound itself, via the maximum-magnitude
  entry of the eigenvector (Gershgorin / Rayleigh-type argument).
* `eq_case_degree_saturated` — at equality `|μ| = Δ`, every vertex attaining the
  maximal eigenvector magnitude has degree *exactly* `Δ` (degree saturation).
* `eq_case_neighbors_attain_max` — at equality, every neighbour of such a vertex
  also attains the maximal magnitude (magnitude propagates along edges).
* `completePositive_realizes_equality` — the all-positive complete signed graph
  `K_n^+` realises equality: the all-ones vector is an eigenvector with eigenvalue
  `n-1`, which equals its (constant) degree.  Hence the bound is sharp.

This is a **cross-domain bridge**: Graph theory (signed graphs, degrees) ⨯ Linear
algebra / spectral theory (eigenvalues, Rayleigh-type inequalities), extending the
catalog file `Novelty/SpectralBound.lean`.
-/
import Mathlib

open Matrix

namespace SignedGraphSpectral

variable {n : ℕ}

/-! ## Signed adjacency matrices -/

/-- A **signed adjacency matrix** on `Fin n`: a real symmetric matrix whose entries
lie in `{-1,0,1}` and whose diagonal vanishes. -/
structure SignedAdj (n : ℕ) where
  /-- The underlying real matrix. -/
  A : Matrix (Fin n) (Fin n) ℝ
  /-- Symmetry: `A i j = A j i`. -/
  isSymm : A.IsSymm
  /-- Entries are signs. -/
  entries : ∀ i j, A i j = -1 ∨ A i j = 0 ∨ A i j = 1
  /-- No loops. -/
  diag : ∀ i, A i i = 0

/-- The (unsigned) **degree** of vertex `i`: the absolute row sum `∑ j, |A i j|`,
i.e. the number of incident edges. -/
def degree (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : ℝ := ∑ j, |A i j|

/-! ## The Δ-bound (spectral radius ≤ maximum degree) -/

/-
**Δ-bound.** If `A *ᵥ v = μ • v` for a nonzero `v`, and every absolute row sum
is at most `Δ`, then `|μ| ≤ Δ`.

Proof idea: pick `i₀` maximising `|v i₀| =: M > 0`.  Then
`|μ|·M = |∑ j, A i₀ j · v j| ≤ ∑ j |A i₀ j|·|v j| ≤ (∑ j |A i₀ j|)·M ≤ Δ·M`,
and dividing by `M > 0` gives `|μ| ≤ Δ`.
-/
theorem eigenvalue_abs_le_maxDeg (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (μ Δ : ℝ) (hv : v ≠ 0) (heig : A *ᵥ v = μ • v)
    (hΔ : ∀ i, ∑ j, |A i j| ≤ Δ) : |μ| ≤ Δ := by
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, |v i| ≤ |v i₀| := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => |v i| ) ⟨ Classical.choose ( Function.ne_iff.mp hv ), Finset.mem_univ _ ⟩;
  have h_abs : |μ| * |v i₀| ≤ ∑ j, |A i₀ j| * |v j| := by
    replace heig := congr_fun heig i₀; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
    simpa only [ ← abs_mul, ← heig ] using Finset.abs_sum_le_sum_abs _ _;
  refine' le_of_mul_le_mul_of_pos_right ( le_trans h_abs _ ) ( abs_pos.mpr ( show v i₀ ≠ 0 from fun h => hv <| funext fun i => by simpa [ h ] using hi₀ i ) );
  exact le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_left ( hi₀ _ ) ( abs_nonneg _ ) ) ( by simpa only [ Finset.sum_mul _ _ _ ] using mul_le_mul_of_nonneg_right ( hΔ i₀ ) ( abs_nonneg _ ) )

/-! ## Equality cases -/

/-
**Degree saturation at equality.**  Suppose `A *ᵥ v = μ • v` with `v ≠ 0`,
every absolute row sum is at most `Δ`, and equality `|μ| = Δ` holds.  Then any
vertex `i₀` attaining the maximal eigenvector magnitude has degree *exactly* `Δ`.
-/
theorem eq_case_degree_saturated (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (μ Δ : ℝ) (heig : A *ᵥ v = μ • v) (hΔ : ∀ i, ∑ j, |A i j| ≤ Δ)
    (heq : |μ| = Δ) (i₀ : Fin n) (hi₀ : ∀ j, |v j| ≤ |v i₀|) (hpos : 0 < |v i₀|) :
    ∑ j, |A i₀ j| = Δ := by
  -- By the properties of the eigenvalue equation and the saturation condition, we have |μ| * |v i₀| ≤ ∑ j, |A i₀ j| * |v j|.
  have h_abs_eigenvalue : abs μ * abs (v i₀) ≤ ∑ j, abs (A i₀ j) * abs (v j) := by
    convert norm_sum_le ( Finset.univ : Finset ( Fin n ) ) ( fun j => ( A i₀ j ) * v j ) using 1;
    · replace heig := congr_fun heig i₀; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
    · norm_num;
  nlinarith [ hi₀ i₀, hΔ i₀, show ∑ j, |A i₀ j| * |v j| ≤ ∑ j, |A i₀ j| * |v i₀| from Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hi₀ i ) ( abs_nonneg _ ), show ∑ j, |A i₀ j| * |v i₀| = ( ∑ j, |A i₀ j| ) * |v i₀| by rw [ Finset.sum_mul _ _ _ ] ]

/-
**Neighbour saturation at equality.**  Under the equality hypotheses, every
neighbour `j` of a maximum-magnitude vertex `i₀` (i.e. `A i₀ j ≠ 0`) also attains
the maximal magnitude `|v j| = |v i₀|`.
-/
theorem eq_case_neighbors_attain_max (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (μ Δ : ℝ) (heig : A *ᵥ v = μ • v) (hΔ : ∀ i, ∑ j, |A i j| ≤ Δ)
    (heq : |μ| = Δ) (i₀ : Fin n) (hi₀ : ∀ j, |v j| ≤ |v i₀|) (hpos : 0 < |v i₀|) :
    ∀ j, A i₀ j ≠ 0 → |v j| = |v i₀| := by
  -- Consider the nonnegative terms $g j := |A i₀ j| * (M - |v j|) ≥ 0$ (since $|A i₀ j| ≥ 0$ and $M - |v j| ≥ 0$ by $hi₀$).
  have h_nonneg : ∀ j, |A i₀ j| * (|v i₀| - |v j|) ≥ 0 := by
    exact fun j => mul_nonneg ( abs_nonneg _ ) ( sub_nonneg.mpr ( hi₀ j ) );
  -- From heig the i₀ component gives μ * v i₀ = ∑ j, A i₀ j * v j, so |μ| * M = |∑ j, A i₀ j * v j| ≤ ∑ j, |A i₀ j| * |v j|  (call this S1)
  have h_s1 : |μ| * |v i₀| ≤ ∑ j, |A i₀ j| * |v j| := by
    convert norm_sum_le ( Finset.univ : Finset ( Fin n ) ) ( fun j => A i₀ j * v j ) using 1 ; simp +decide [ ← abs_mul ];
    · replace heig := congr_fun heig i₀; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
    · norm_num [ abs_mul ];
  contrapose! h_s1;
  obtain ⟨ j, hj₁, hj₂ ⟩ := h_s1;
  have h_sum_lt : ∑ j, |A i₀ j| * |v j| < ∑ j, |A i₀ j| * |v i₀| := by
    exact Finset.sum_lt_sum ( fun i _ => by nlinarith [ hi₀ i, h_nonneg i ] ) ⟨ j, Finset.mem_univ j, by nlinarith [ hi₀ j, h_nonneg j, abs_pos.mpr hj₁, mul_self_pos.mpr ( sub_ne_zero.mpr hj₂ ) ] ⟩;
  exact h_sum_lt.trans_le ( by rw [ ← Finset.sum_mul _ _ _ ] ; exact mul_le_mul_of_nonneg_right ( heq.symm ▸ hΔ i₀ ) hpos.le )

/-! ## Tightness: the all-positive complete signed graph realises equality -/

/-- The **all-positive complete signed graph** `K_n^+`: every off-diagonal entry is
`+1`. -/
def completePositive (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => if i = j then 0 else 1)

/-- `K_n^+` is a signed adjacency matrix. -/
def completePositiveSignedAdj (n : ℕ) : SignedAdj n where
  A := completePositive n
  isSymm := by
    ext i j; simp only [completePositive, Matrix.of_apply, Matrix.transpose_apply]
    by_cases h : i = j <;> simp [h, eq_comm]
  entries := by
    intro i j; simp only [completePositive, Matrix.of_apply]
    by_cases h : i = j <;> simp [h]
  diag := by intro i; simp [completePositive]

/-
**Tightness / equality realiser.**  For `K_n^+` the all-ones vector is an
eigenvector with eigenvalue `n - 1`, and every degree equals `n - 1`.  Hence the
Δ-bound `|μ| ≤ Δ` holds with equality `|n-1| = Δ = n-1`.
-/
theorem completePositive_realizes_equality (n : ℕ) :
    (completePositive n) *ᵥ (fun _ => (1 : ℝ)) = ((n : ℝ) - 1) • (fun _ => (1 : ℝ))
      ∧ ∀ i, ∑ j, |completePositive n i j| = (n : ℝ) - 1 := by
  constructor;
  · ext i; simp +decide [ *, Matrix.mulVec, dotProduct ] ;
    unfold completePositive; simp +decide [ Finset.sum_ite, Finset.filter_ne ] ;
    rw [ Nat.cast_pred ( Fin.pos i ) ];
  · intro i
    simp [completePositive];
    rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ];
    rw [ Finset.sum_congr rfl fun x hx => by rw [ if_neg ( by aesop ) ] ] ; norm_num [ Finset.card_sdiff ];
    rw [ Nat.cast_pred ( Fin.pos i ) ]

/-! ## Switching invariance (cycle 2)

A *switching* by a `±1` sign vector `d` conjugates `A` by the diagonal matrix
`diag d`.  Switching is the fundamental equivalence on signed graphs (it changes
signs of edges at a vertex set without changing the underlying graph).  The two
lemmas below are the building blocks for the balance conjecture C2 in
`FUTURE_DIRECTIONS.md`: switching transports eigenpairs (so it preserves the
spectrum) and preserves every absolute row sum (so it preserves the maximum
degree `Δ`, and hence the entire Δ-bound). -/

/-
**Switching transports eigenpairs.**  If `d` is a `±1` vector and
`A *ᵥ v = μ • v`, then the switched matrix `diag d · A · diag d` has the switched
vector `i ↦ d i * v i` as an eigenvector with the *same* eigenvalue `μ`.  Hence
switching preserves the spectrum.
-/
theorem switching_eigenpair (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (μ : ℝ) (d : Fin n → ℝ) (hd : ∀ i, d i = 1 ∨ d i = -1)
    (heig : A *ᵥ v = μ • v) :
    (Matrix.diagonal d * A * Matrix.diagonal d) *ᵥ (fun i => d i * v i)
      = μ • (fun i => d i * v i) := by
  have hw : Matrix.diagonal d *ᵥ (fun i => d i * v i) = v := by
    funext i
    rw [Matrix.mulVec_diagonal]
    have hsq : d i * d i = 1 := by rcases hd i with h | h <;> rw [h] <;> norm_num
    calc d i * (d i * v i) = (d i * d i) * v i := by ring
      _ = v i := by rw [hsq, one_mul]
  calc (Matrix.diagonal d * A * Matrix.diagonal d) *ᵥ (fun i => d i * v i)
      = Matrix.diagonal d *ᵥ (A *ᵥ (Matrix.diagonal d *ᵥ (fun i => d i * v i))) := by
        rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec]
    _ = Matrix.diagonal d *ᵥ (A *ᵥ v) := by rw [hw]
    _ = Matrix.diagonal d *ᵥ (μ • v) := by rw [heig]
    _ = μ • (fun i => d i * v i) := by
        funext i
        rw [Matrix.mulVec_diagonal]
        simp only [Pi.smul_apply, smul_eq_mul]
        ring

/-- **Switching preserves absolute row sums.**  For a `±1` vector `d`, the switched
matrix has the same absolute row sums as `A`; in particular the maximum degree `Δ`
is unchanged, so the Δ-bound is switching-invariant. -/
theorem switching_preserves_absRowSum (A : Matrix (Fin n) (Fin n) ℝ)
    (d : Fin n → ℝ) (hd : ∀ i, d i = 1 ∨ d i = -1) (i : Fin n) :
    ∑ j, |(Matrix.diagonal d * A * Matrix.diagonal d) i j| = ∑ j, |A i j| := by
  refine Finset.sum_congr rfl fun j _ => ?_;
  cases hd i <;> cases hd j <;> simp +decide [ *, Matrix.mul_apply, Matrix.diagonal ]

/-! ## The all-negative complete graph realises the lower extreme `-Δ` -/

/-- The **all-negative complete signed graph** `K_n^-`: every off-diagonal entry is
`-1`. -/
def completeNegative (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => if i = j then 0 else -1)

/-- **Lower-extreme realiser.**  For `K_n^-` the all-ones vector is an eigenvector
with eigenvalue `-(n-1)`, and every degree equals `n-1`.  Hence the lower extreme
`μ = -Δ` of the bound `|μ| ≤ Δ` is also attained, complementing `K_n^+`. -/
theorem completeNegative_realizes_lower (n : ℕ) :
    (completeNegative n) *ᵥ (fun _ => (1 : ℝ)) = (-((n : ℝ) - 1)) • (fun _ => (1 : ℝ))
      ∧ ∀ i, ∑ j, |completeNegative n i j| = (n : ℝ) - 1 := by
  constructor;
  · ext i; simp +decide [ *, Matrix.mulVec, dotProduct ] ;
    unfold completeNegative; simp +decide [ Finset.sum_ite, Finset.filter_ne ] ;
    rw [ Nat.cast_pred ] <;> linarith [ Fin.is_lt i ];
  · intro i; exact (by
    convert completePositive_realizes_equality n |>.2 i using 1;
    exact Finset.sum_congr rfl fun j _ => by unfold completeNegative completePositive; aesop;)

end SignedGraphSpectral
/-
-- !-- Lab Notes -- !--

Category (Menu Balance): CROSS-DOMAIN BRIDGE
  Graph theory (signed graphs, degrees, switching) ⨯ Linear algebra / spectral
  theory (eigenvalues, Rayleigh/Gershgorin-type inequalities).  Extends
  `Novelty/SpectralBound.lean` (Gram-matrix spectral size bounds) to the
  *signed adjacency* setting and, crucially, to the EQUALITY CASES.

=== CYCLE 1: the Δ-bound and its local equality cases ===

Hypotheses (Hypothesizer):
  H1. Every eigenvalue of a signed adjacency matrix is bounded in absolute value
      by the maximum degree Δ (the "Δ-bound" / spectral radius ≤ Δ).
  H2. (bold) Equality |μ| = Δ is structurally rigid: it forces degree saturation
      at the eigenvector's peak vertices, and the peak magnitude propagates along
      every incident edge.  This is the local mechanism behind the global
      equality characterisations of Sun–Das (2020) / Lan et al. (2023).
  H3. The bound is sharp for every n: the all-positive complete signed graph
      K_n^+ achieves |μ| = Δ = n-1 via the all-ones eigenvector.

Experiments (Experimenter):
  * `eigenvalue_abs_le_maxDeg` : peak-vertex Rayleigh argument.  Picking the
    argmax i₀ of |v| and chaining triangle inequality + monotonicity of the
    absolute row sum, then cancelling the positive peak magnitude.  Confirmed H1.
  * `eq_case_degree_saturated` : sandwiching |μ| ≤ deg(i₀) ≤ Δ = |μ| forces
    deg(i₀) = Δ.  Confirmed the degree half of H2.
  * `eq_case_neighbors_attain_max` : the slack is a sum of nonnegative terms
    |A i₀ j|·(M - |v j|) that must all vanish, so every neighbour attains the
    peak.  Confirmed the propagation half of H2.
  * `completePositive_realizes_equality` : direct computation, all-ones vector.
    Confirmed H3, so the Δ-bound is tight for all n.

Analysis (Analyst):
  - The single decisive object is the PEAK VERTEX i₀ (argmax |v|).  The bound is
    its row inequality; the equality cases are exactly the statements that that
    one row inequality is tight, term by term.
  - Signedness (entries in {-1,0,1}) is irrelevant to the bound and to saturation:
    only the absolute row sums matter.  The argument transfers verbatim from
    ordinary to signed graphs.

=== CYCLE 2: switching invariance and the lower extreme ===

Hypotheses:
  H4. The Δ-bound is invariant under *switching* (conjugation by a ±1 diagonal),
      the fundamental equivalence on signed graphs: switching transports
      eigenpairs (same spectrum) and preserves every absolute row sum (same Δ).
  H5. The *lower* extreme μ = -Δ of |μ| ≤ Δ is also attained — by the all-NEGATIVE
      complete graph K_n^- — so both ends of the bound are sharp.

Experiments:
  * `switching_eigenpair` : (diag d · A · diag d) carries the switched vector
    (d i · v i) at the SAME eigenvalue μ.  Proved cleanly via `mulVec_mulVec`
    associativity and `mulVec_diagonal`, using d i · d i = 1.  Confirmed the
    spectrum half of H4.
  * `switching_preserves_absRowSum` : |d i · A i j · d j| = |A i j| since
    |d i| = |d j| = 1; summing over j keeps Δ fixed.  Confirmed the degree
    half of H4.
  * `completeNegative_realizes_lower` : all-ones vector gives eigenvalue -(n-1),
    degrees n-1, so μ = -Δ.  Confirmed H5.

Critique (Critic):
  - No result is vacuous: the bound consumes a genuine eigenpair; the equality
    lemmas are non-trivial term-by-term tightness facts; both realisers exhibit
    concrete extremal graphs at opposite ends; switching invariance is a real
    conjugation argument (d² = 1), not definitional.
  - Edge case n = 0: hv forces n > 0, so the bound lemmas are never vacuously
    invoked; the realisers at n = 0/1 give Δ = -1/0 consistently with the
    empty/edgeless graph.

Synthesis (PI):
  The peak vertex governs the bound and both local equality cases; switching is
  the symmetry that makes "Δ" and "spectrum" well-defined on switching classes;
  K_n^+ and K_n^- pin the two extremes μ = ±Δ.  The natural next step is to turn
  the LOCAL propagation (`eq_case_neighbors_attain_max`) into a GLOBAL regularity
  statement on connected graphs, and to characterise which extreme is hit via
  balance — see C1, C2 in FUTURE_DIRECTIONS.md.
-/