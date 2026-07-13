/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Edge-spectral supersaturation for triangles

For a finite graph `G` with `m` edges, write `λ(G)` for the spectral radius of its
adjacency matrix.  Nosal's classical theorem states that a triangle-free graph
satisfies `λ² ≤ m`; equivalently, `λ² > m` forces at least one triangle.  A natural
*supersaturation* strengthening asks how the triangle count grows once `λ²` exceeds
`m` by an amount `q`.  The sharp conjecture (constant `B = 1`) predicts roughly
`q√m` triangles.  This file establishes the **unconditional spectral lower bound
with constant `1/3`**, which is the bound that follows directly from the power-trace
method, together with the triangle-free endpoint (Nosal's inequality).

## The power-trace method

The three ingredients are the standard identities relating the eigenvalues
`μ₁, …, μₙ` of the adjacency matrix to graph invariants:

* `∑ μᵢ² = tr(A²) = 2m`   (twice the number of edges),
* `∑ μᵢ³ = tr(A³) = 6t`   (six times the number of triangles),
* `|μᵢ| ≤ λ` for every `i`, where `λ` is the top eigenvalue.

The last item is the Perron–Frobenius statement that the spectral radius of a
nonnegative symmetric matrix is attained by its largest eigenvalue; we take it as
the hypothesis `hbound`, which is exactly the arithmetic input the method needs.

From these we prove the *eigenvalue supersaturation inequality*

  `∑ μᵢ³ ≥ 2λ³ − λ · ∑ μᵢ²`,

which specialises, via `∑ μᵢ² = 2m` and `λ² = m + q`, to `6t ≥ 2λq`, i.e.

  `t ≥ (λ q)/3 ≥ (q √m)/3`.

The whole development is carried out at the level of the eigenvalue multiset,
so the results apply verbatim to any real symmetric matrix whose spectral radius
dominates its spectrum.

## Main results

* `eigen_supersat`    — the eigenvalue supersaturation inequality.
* `triangle_count_lower`      — `λ q ≤ 3 t` (spectral supersaturation, constant 1/3).
* `triangle_count_lower_sqrt` — `√m · q ≤ 3 t`.
* `nosal`             — triangle-free (`∑ μᵢ³ = 0`) forces `λ² ≤ m`.
* `K3_supersaturation_example` — the complete graph `K₃` as a concrete instance.
* `trace_pow_eq_sum_pow_eigenvalues` — the linear-algebra bridge `tr(Aᵏ) = ∑ μᵢᵏ`
  for a real symmetric matrix, discharging the trace hypotheses from the spectral
  theorem.
* `matrix_eigen_supersat` — the eigenvalue supersaturation inequality proved
  directly for the traces of powers of a real symmetric matrix.

## Relation to the catalog

This file sits alongside the extremal-graph material of `Novelty/Turan.lean`
(Turán/Mantel, the *edge-count* endpoint of the same theory) and the Gram-matrix
spectral bounds of `Novelty/SpectralBound.lean`, extending the catalog's treatment
of triangle counting from the purely combinatorial regime to the spectral one.
-/
import Mathlib

namespace Catalog.Novelty.EdgeSpectralSupersaturationTriangles

open Finset

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the sharp edge-spectral supersaturation bound for
--   triangles has constant `B = 1` (`t ≳ q√m`).  The `χ(F) ≥ 4` case is known;
--   the `χ = 3` (triangle) case is open.  Conjecture: even if the sharp constant
--   is out of reach, the power-trace method yields an unconditional constant.
-- Experiment (Experimenter): encode `tr(A²)=2m`, `tr(A³)=6t`, and Perron–Frobenius
--   `|μᵢ| ≤ λ` as hypotheses on the eigenvalue vector `μ` and push the inequality
--   `μ³ ≥ -λμ²` through the sum, isolating the top eigenvalue.
-- Analysis (Analyst): the method is *exactly* lossy by a factor of 3 versus the
--   conjecture — the slack lives in bounding `∑_{i≥2} μᵢ³ ≥ -λ∑_{i≥2}μᵢ²`, which is
--   tight only when the negative spectrum concentrates at `-λ` (bipartite-like),
--   a configuration incompatible with many triangles.  Hence "true but not sharp".
-- Critique (Critic): the results are conditional on the three eigenvalue identities.
--   These are genuine theorems (trace of matrix powers, Perron–Frobenius) rather
--   than definitions, so stating them as hypotheses is the faithful abstraction and
--   not a triviality; the `K₃` instance certifies the hypotheses are satisfiable and
--   the bound non-vacuous.
-- Synthesis (PI): constant-`1/3` supersaturation + Nosal endpoint, all sorry-free.

/-- **Cubic domination.**  If `|μ| ≤ λ` then `μ³ ≥ -λ·μ²`.  This is the pointwise
inequality that drives the power-trace estimate: a real number's cube cannot fall
below `-λ` times its square once its absolute value is bounded by `λ`. -/
theorem cube_lower (μ lam : ℝ) (h : |μ| ≤ lam) : -lam * μ ^ 2 ≤ μ ^ 3 := by
  nlinarith [sq_nonneg μ, abs_le.mp h]

/-- **Eigenvalue supersaturation inequality.**  Let `μ : Fin n → ℝ` be a spectrum
with a distinguished top eigenvalue `λ = μ j` dominating the whole spectrum in
absolute value (`|μᵢ| ≤ λ`).  Then the cubic power sum obeys

  `2λ³ − λ·∑ μᵢ² ≤ ∑ μᵢ³`.

Summing the pointwise bound `μᵢ³ + λμᵢ² ≥ 0` and keeping only the `j`-th term
(which equals `2λ³`) yields the estimate. -/
theorem eigen_supersat {n : ℕ} (μ : Fin n → ℝ) (j : Fin n) (lam : ℝ)
    (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam) :
    2 * lam ^ 3 - lam * (∑ i, (μ i) ^ 2) ≤ ∑ i, (μ i) ^ 3 := by
  have key : ∀ i, (0 : ℝ) ≤ (μ i) ^ 3 + lam * (μ i) ^ 2 := fun i => by
    have := cube_lower (μ i) lam (hbound i); linarith
  have hsum : (μ j) ^ 3 + lam * (μ j) ^ 2 ≤ ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2) :=
    Finset.single_le_sum (f := fun i => (μ i) ^ 3 + lam * (μ i) ^ 2)
      (fun i _ => key i) (Finset.mem_univ j)
  have hsplit : ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2)
      = (∑ i, (μ i) ^ 3) + lam * (∑ i, (μ i) ^ 2) := by
    rw [Finset.sum_add_distrib, Finset.mul_sum]
  rw [hsplit, ← hlam] at hsum
  nlinarith [hsum]

/-- **Spectral supersaturation for triangles (constant `1/3`).**  Suppose a graph's
adjacency spectrum `μ` satisfies the trace identities `∑ μᵢ² = 2m` and `∑ μᵢ³ = 6t`,
the Perron–Frobenius domination `|μᵢ| ≤ λ = μ j`, and the spectral excess
`λ² = m + q`.  Then the number of triangles obeys

  `λ · q ≤ 3 t`,

i.e. `t ≥ (λ q)/3`. -/
theorem triangle_count_lower {n : ℕ} (μ : Fin n → ℝ) (j : Fin n) (lam m t q : ℝ)
    (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam)
    (hS2 : ∑ i, (μ i) ^ 2 = 2 * m) (hS3 : ∑ i, (μ i) ^ 3 = 6 * t)
    (hq : lam ^ 2 = m + q) : lam * q ≤ 3 * t := by
  have H := eigen_supersat μ j lam hlam hbound
  rw [hS2, hS3] at H
  have hcube : lam ^ 3 = lam * (m + q) := by rw [← hq]; ring
  nlinarith [H, hcube]

/-- **Spectral supersaturation with the `√m` scaling.**  Under the hypotheses of
`triangle_count_lower` with nonnegative excess `q`, the triangle count satisfies

  `√m · q ≤ 3 t`,

the shape appearing in the conjecture `t ≥ (1-ε) q √m`, here with constant `1/3`. -/
theorem triangle_count_lower_sqrt {n : ℕ} (μ : Fin n → ℝ) (j : Fin n)
    (lam m t q : ℝ) (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam)
    (hS2 : ∑ i, (μ i) ^ 2 = 2 * m) (hS3 : ∑ i, (μ i) ^ 3 = 6 * t)
    (hq : lam ^ 2 = m + q) (hqnn : 0 ≤ q) : Real.sqrt m * q ≤ 3 * t := by
  have hln : 0 ≤ lam := le_trans (abs_nonneg (μ j)) (hlam ▸ hbound j)
  have hbase := triangle_count_lower μ j lam m t q hlam hbound hS2 hS3 hq
  have hsqrt : Real.sqrt m ≤ lam := by
    rw [show m = lam ^ 2 - q by linarith]
    calc Real.sqrt (lam ^ 2 - q) ≤ Real.sqrt (lam ^ 2) := Real.sqrt_le_sqrt (by linarith)
      _ = lam := by rw [Real.sqrt_sq hln]
  nlinarith [mul_le_mul_of_nonneg_right hsqrt hqnn, hbase]

/-- **Nosal's inequality (spectral triangle-freeness endpoint).**  If the cubic
power sum vanishes (`∑ μᵢ³ = 0`, the spectral signature of a triangle-free graph),
then the top eigenvalue satisfies `λ² ≤ m`.  This is the `q = 0` boundary case of
supersaturation and recovers the classical bound `λ(G) ≤ √m` for triangle-free `G`. -/
theorem nosal {n : ℕ} (μ : Fin n → ℝ) (j : Fin n) (lam m : ℝ)
    (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam)
    (hS2 : ∑ i, (μ i) ^ 2 = 2 * m) (hS3free : ∑ i, (μ i) ^ 3 = 0) :
    lam ^ 2 ≤ m := by
  have hln : 0 ≤ lam := le_trans (abs_nonneg (μ j)) (hbound j)
  have H := eigen_supersat μ j lam hlam hbound
  rw [hS2, hS3free] at H
  have hmnn : 0 ≤ m := by
    have h2 : (0 : ℝ) ≤ ∑ i, (μ i) ^ 2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
    rw [hS2] at h2; linarith
  nlinarith [H, hln, hmnn]

/-! ### A concrete instance: the triangle `K₃`

The adjacency matrix of `K₃` has spectrum `{2, -1, -1}`.  Here `m = 3`, `t = 1`,
`λ = 2`, so `λ² = 4 = m + q` with excess `q = 1`.  The general theorem then
certifies `λ·q = 2 ≤ 3 = 3t`, a genuine (non-vacuous) triangle count. -/

/-- The eigenvalue vector of the complete graph `K₃`. -/
noncomputable def muK3 : Fin 3 → ℝ := ![2, -1, -1]

/-- `K₃` realises the supersaturation hypotheses and hence the conclusion
`λ·q ≤ 3t` with `λ = 2`, `m = 3`, `t = 1`, `q = 1`. -/
theorem K3_supersaturation_example :
    (2 : ℝ) * 1 ≤ 3 * 1 := by
  have hS2 : (∑ i, (muK3 i) ^ 2) = 2 * 3 := by
    simp [muK3, Fin.sum_univ_three]; norm_num
  have hS3 : (∑ i, (muK3 i) ^ 3) = 6 * 1 := by
    simp [muK3, Fin.sum_univ_three]; norm_num
  have hbound : ∀ i, |muK3 i| ≤ (2 : ℝ) := by
    intro i; fin_cases i <;> norm_num [muK3]
  exact triangle_count_lower muK3 0 2 3 1 1 (by norm_num [muK3]) hbound hS2 hS3
    (by norm_num)

/-! ### The linear-algebra bridge: from the spectral theorem to matrix traces

The results above are stated at the level of an abstract eigenvalue vector, with the
trace identities `∑ μᵢ² = tr(A²)` and `∑ μᵢ³ = tr(A³)` supplied as hypotheses.  We now
*discharge* those hypotheses for a genuine real symmetric (Hermitian) matrix, turning
the combinatorial estimate into a theorem of linear algebra.  The engine is Mathlib's
spectral theorem `Matrix.IsHermitian.spectral_theorem`, which diagonalises `A` by a
unitary conjugation; since the trace is invariant under conjugation and a power of a
conjugation is the conjugation of the power, `tr(Aᵏ)` collapses to `∑ μᵢᵏ`. -/

/-- **Eigenvalue supersaturation over an arbitrary finite index.**  The eigenvalue
supersaturation inequality holds for a spectrum indexed by any finite type, not just
`Fin n`; this is the form consumed by the matrix bridge below. -/
theorem eigen_supersat_general {ι : Type*} [Fintype ι] (μ : ι → ℝ) (j : ι) (lam : ℝ)
    (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam) :
    2 * lam ^ 3 - lam * (∑ i, (μ i) ^ 2) ≤ ∑ i, (μ i) ^ 3 := by
  have key : ∀ i, (0 : ℝ) ≤ (μ i) ^ 3 + lam * (μ i) ^ 2 := fun i => by
    have := cube_lower (μ i) lam (hbound i); linarith
  have hsum : (μ j) ^ 3 + lam * (μ j) ^ 2 ≤ ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2) :=
    Finset.single_le_sum (f := fun i => (μ i) ^ 3 + lam * (μ i) ^ 2)
      (fun i _ => key i) (Finset.mem_univ j)
  have hsplit : ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2)
      = (∑ i, (μ i) ^ 3) + lam * (∑ i, (μ i) ^ 2) := by
    rw [Finset.sum_add_distrib, Finset.mul_sum]
  rw [hsplit, ← hlam] at hsum
  nlinarith [hsum]

open Matrix in
/-- **Trace of a matrix power equals the power sum of its eigenvalues.**  For a real
symmetric (Hermitian) matrix `A`, the trace of `Aᵏ` is `∑ᵢ μᵢᵏ`, where the `μᵢ` are the
(real) eigenvalues.  This is the exact arithmetic content of the trace identities
`tr(A²) = ∑ μᵢ²` and `tr(A³) = ∑ μᵢ³` that power the supersaturation method. -/
theorem trace_pow_eq_sum_pow_eigenvalues {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (k : ℕ) :
    (A ^ k).trace = ∑ i, (hA.eigenvalues i) ^ k := by
  have := hA.spectral_theorem;
  conv_lhs => rw [ this, ← map_pow ];
  simp +decide [ Matrix.trace_mul_comm, Matrix.mul_assoc ];
  simp +decide [ Matrix.trace, Matrix.diagonal_pow ]

open Matrix in
/-- **Spectral supersaturation for a real symmetric matrix.**  Combining the spectral
theorem bridge with the eigenvalue inequality: if every eigenvalue of a real symmetric
matrix `A` is dominated in absolute value by a distinguished top eigenvalue
`lam = μ j` (the Perron–Frobenius situation for an adjacency matrix), then the traces
of the second and third powers obey

  `2·lam³ − lam·tr(A²) ≤ tr(A³)`.

Specialised to a graph adjacency matrix this reads `6t ≥ 2λ³ − 2λm`, i.e. the
triangle supersaturation bound, now proved *from* the matrix rather than assumed. -/
theorem matrix_eigen_supersat {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (j : n) (lam : ℝ)
    (hlam : lam = hA.eigenvalues j) (hbound : ∀ i, |hA.eigenvalues i| ≤ lam) :
    2 * lam ^ 3 - lam * (A ^ 2).trace ≤ (A ^ 3).trace := by
  have h2 := trace_pow_eq_sum_pow_eigenvalues A hA 2
  have h3 := trace_pow_eq_sum_pow_eigenvalues A hA 3
  have H := eigen_supersat_general (hA.eigenvalues) j lam hlam hbound
  rw [h2, h3]
  exact H

end Catalog.Novelty.EdgeSpectralSupersaturationTriangles