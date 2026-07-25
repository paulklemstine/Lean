import Mathlib

/-!
# The spectral core of Huang's proof of the Sensitivity Conjecture

Huang's celebrated one-page proof of the Sensitivity Conjecture (2019) is built on a
family of **signed adjacency matrices** `Aₙ` of the `n`-dimensional hypercube `Qₙ`,
defined recursively by

  `A₀ = (0)`,     `A_{n+1} = ⎡ Aₙ   I ⎤`
                            `⎣ I   -Aₙ⎦`.

The single fact that powers the whole argument is the spectral identity

  `Aₙ² = n · I`,

which forces every eigenvalue of `Aₙ` to be `±√n`.  Because `Aₙ` is a symmetric
`{-1,0,1}`-matrix that is a signed version of the ordinary hypercube adjacency matrix
(equal in absolute value to it), Cauchy interlacing applied to `Aₙ` on any set of
`2^{n-1}+1` vertices yields the `√n` lower bound on the maximum degree of an induced
subgraph — equivalently on the sensitivity of a Boolean function.

This file formalizes that **spectral core** and its immediate structural consequences.
We index the `2ⁿ` vertices by a `Sum`-recursive type `Hb n` so that the recursive block
construction is definitionally a `Matrix.fromBlocks`, making the inductions clean.

## Main results

* `Asign_sq`     : `Aₙ * Aₙ = n • 1`      (Huang's spectral identity).
* `Asign_symm`   : `Aₙᵀ = Aₙ`             (symmetry — real spectrum).
* `Asign_trace`  : `trace Aₙ = 0`         (eigenvalues `+√n` and `-√n` balance).
* `Asign_entries`: every entry is `-1`, `0`, or `1` (a genuine signed adjacency matrix).
* `Asign_row_sq` : `∑_w (Aₙ v w)² = n`    (each row has squared-norm `n`).
* `Asign_degree` : each vertex has exactly `n` nonzero entries (`Qₙ` is `n`-regular).
* `Asign_eig`    : every eigenvalue `μ` satisfies `μ² = n`  (the spectral gap `±√n`).
* `Asign_eig_abs`: `|μ| = √n` for every eigenvalue `μ`.
* `Asign_det_sq` : `(det Aₙ)² = n^(2ⁿ)`.
* `Asign_isUnit` : for `n ≥ 1`, `Aₙ` is invertible with inverse `n⁻¹ • Aₙ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Huang's recursive signed matrices satisfy `Aₙ² = nI`; if so,
their spectrum is exactly `{±√n}`, and all the interlacing-free structural facts
(symmetry, zero trace, `{-1,0,1}` entries, `n`-regularity, `(det)² = n^(2ⁿ)`,
invertibility for `n ≥ 1`) should follow by the same block induction.

Experiment (Experimenter): index vertices by `Hb n` with `Hb 0 = Unit`,
`Hb (n+1) = Hb n ⊕ Hb n`, so the recursive matrix is literally
`Matrix.fromBlocks (Aₙ) 1 1 (-Aₙ)`.  Then `fromBlocks_multiply` reduces `Aₙ₊₁²` to four
blocks that collapse via the induction hypothesis: the diagonal blocks become
`n•1 + 1 = (n+1)•1` and the off-diagonal blocks `A - A = 0`.  All other facts are the
same one-step block induction, plus two "apply the matrix twice" arguments for the
eigenvalue bound.

Analysis (Analyst): the `Sum`-recursive index type is the key enabler — it turns each
recursive step into a single `fromBlocks` rewrite, avoiding all `Fin (2^n)` index
arithmetic.  `Asign_sq` is genuinely the load-bearing fact: `Asign_eig`, `Asign_det_sq`
and `Asign_isUnit` are all corollaries of it, while `Asign_row_sq`/`Asign_degree` need
symmetry and the entry classification in addition.  The only fact requiring nontrivial
spectral theory (the *multiplicities* `2^{n-1}` of `±√n`, hence interlacing) is left to
`FUTURE_DIRECTIONS.md`.

Critique (Critic): none of these are vacuous — each uses a real induction or a
"multiply twice" spectral argument, and the entries/degree results confirm `Aₙ` really
is a signed hypercube adjacency matrix (not an artifact of the encoding).  `Asign_eig`
is stated for arbitrary real eigenpairs `(μ, v)` with `v ≠ 0`, so it is not vacuous.

Synthesis (PI): the `Aₙ² = nI` identity plus the `{-1,0,1}` / `n`-regularity facts are
precisely the hypotheses of the Cauchy-interlacing step; formalizing that step is the
natural next cycle.
-/

open Matrix

namespace SignedAdjacency

/-- The `2ⁿ`-element vertex type of the `n`-cube, built so that the recursive
signed-adjacency construction is a literal `Matrix.fromBlocks`. -/
def Hb : ℕ → Type
  | 0 => Unit
  | (n + 1) => Hb n ⊕ Hb n

instance : ∀ n, Fintype (Hb n)
  | 0 => inferInstanceAs (Fintype Unit)
  | (n + 1) => by unfold Hb; exact @instFintypeSum _ _ (instFintypeHb n) (instFintypeHb n)

instance : ∀ n, DecidableEq (Hb n)
  | 0 => inferInstanceAs (DecidableEq Unit)
  | (n + 1) => by unfold Hb; exact @instDecidableEqSum _ _ (instDecidableEqHb n) (instDecidableEqHb n)

/-- The vertex set of `Qₙ` has `2ⁿ` elements. -/
theorem Hb_card (n : ℕ) : Fintype.card (Hb n) = 2 ^ n := by
  induction n with
  | zero => simp [Hb]
  | succ k ih =>
    show Fintype.card (Hb k ⊕ Hb k) = _
    rw [Fintype.card_sum, ih]; ring

/-- Huang's recursively-defined signed adjacency matrix `Aₙ` of the hypercube `Qₙ`. -/
noncomputable def Asign : (n : ℕ) → Matrix (Hb n) (Hb n) ℝ
  | 0 => 0
  | (n + 1) => Matrix.fromBlocks (Asign n) 1 1 (-(Asign n))

/-- **Huang's spectral identity**: `Aₙ² = n · I`.  This is the single fact that forces
every eigenvalue of `Aₙ` to be `±√n`. -/
theorem Asign_sq (n : ℕ) :
    Asign n * Asign n = (n : ℝ) • (1 : Matrix (Hb n) (Hb n) ℝ) := by
  induction n with
  | zero => simp [Asign]
  | succ k ih =>
    show Matrix.fromBlocks _ _ _ _ * Matrix.fromBlocks _ _ _ _ = _
    rw [Matrix.fromBlocks_multiply, ih]
    have hone : ((k + 1 : ℕ) : ℝ) • (1 : Matrix (Hb (k + 1)) (Hb (k + 1)) ℝ)
        = Matrix.fromBlocks ((k + 1 : ℝ) • 1) 0 0 ((k + 1 : ℝ) • 1) := by
      rw [← Matrix.fromBlocks_one (α := ℝ), Matrix.fromBlocks_smul]; simp
    rw [hone]; congr 1
    · simp only [mul_one]; module
    · simp
    · simp
    · simp only [mul_one, neg_mul_neg]; rw [ih]; module

/-- `Aₙ` is symmetric, hence has a real spectrum. -/
theorem Asign_symm (n : ℕ) : (Asign n)ᵀ = Asign n := by
  induction n with
  | zero => simp [Asign]
  | succ k ih =>
    show (Matrix.fromBlocks _ _ _ _)ᵀ = _
    rw [Matrix.fromBlocks_transpose, ih]; congr 1 <;> simp [ih]

/-- The trace of `Aₙ` is `0`: the eigenvalues `+√n` and `-√n` occur with equal multiplicity. -/
theorem Asign_trace (n : ℕ) : (Asign n).trace = 0 := by
  induction n with
  | zero => simp [Asign, Matrix.trace, Matrix.diag]
  | succ k ih =>
    show (Matrix.fromBlocks (Asign k) 1 1 (-(Asign k))).trace = 0
    have h : (Matrix.fromBlocks (Asign k) 1 1 (-(Asign k))).trace
        = (Asign k).trace + (-Asign k).trace := by
      simp [Matrix.trace, Matrix.diag, Fintype.sum_sum_type]
    rw [h, Matrix.trace_neg, ih, neg_zero, add_zero]

/-- Every entry of `Aₙ` is `-1`, `0`, or `1`: it is a genuine signed adjacency matrix. -/
theorem Asign_entries (n : ℕ) (v w : Hb n) :
    Asign n v w = -1 ∨ Asign n v w = 0 ∨ Asign n v w = 1 := by
  induction n with
  | zero => right; left; rfl
  | succ k ih =>
    match v, w with
    | Sum.inl a, Sum.inl b => simpa [Asign, fromBlocks] using ih a b
    | Sum.inl a, Sum.inr b =>
        simp only [Asign, fromBlocks]
        by_cases h : a = b <;> simp [h]
    | Sum.inr a, Sum.inl b =>
        simp only [Asign, fromBlocks]
        by_cases h : a = b <;> simp [h]
    | Sum.inr a, Sum.inr b =>
        have := ih a b
        simp only [Asign, fromBlocks]
        rcases this with h | h | h <;> simp [h]

/-- The squared Euclidean norm of every row of `Aₙ` is exactly `n`
(a diagonal read-off of `Aₙ² = nI` using symmetry). -/
theorem Asign_row_sq (n : ℕ) (v : Hb n) : ∑ w, (Asign n v w) ^ 2 = (n : ℝ) := by
  have hd : (Asign n * Asign n) v v = (n : ℝ) := by rw [Asign_sq]; simp
  rw [Matrix.mul_apply] at hd
  rw [← hd]
  apply Finset.sum_congr rfl
  intro w _
  have hsymm : Asign n w v = Asign n v w := by
    rw [← Matrix.transpose_apply (Asign n) v w, Asign_symm]
  rw [hsymm]; ring

/-- **`n`-regularity of the hypercube**: each vertex has exactly `n` nonzero entries in
its row of `Aₙ`, i.e. exactly `n` neighbours in `Qₙ`. -/
theorem Asign_degree (n : ℕ) (v : Hb n) :
    (Finset.univ.filter (fun w => Asign n v w ≠ 0)).card = n := by
  have hsq : ∑ w, (Asign n v w) ^ 2 = (n : ℝ) := Asign_row_sq n v
  have hrw : ∑ w, (Asign n v w) ^ 2
      = ∑ _w ∈ Finset.univ.filter (fun w => Asign n v w ≠ 0), (1 : ℝ) := by
    rw [Finset.sum_filter]
    apply Finset.sum_congr rfl
    intro w _
    rcases Asign_entries n v w with h | h | h <;> simp [h]
  rw [hrw] at hsq
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one] at hsq
  exact_mod_cast hsq

/-- **The spectral gap**: every eigenvalue `μ` of `Aₙ` satisfies `μ² = n`
(so the only possible eigenvalues are `±√n`).  Proved by applying `Aₙ` twice and using
`Asign_sq`. -/
theorem Asign_eig (n : ℕ) (μ : ℝ) (v : Hb n → ℝ) (hv : v ≠ 0)
    (h : (Asign n).mulVec v = μ • v) : μ ^ 2 = (n : ℝ) := by
  have h2 : (Asign n).mulVec ((Asign n).mulVec v) = (μ ^ 2) • v := by
    rw [h, Matrix.mulVec_smul, h, smul_smul]; ring_nf
  rw [Matrix.mulVec_mulVec, Asign_sq, smul_mulVec, Matrix.one_mulVec] at h2
  have hz : ((μ ^ 2) - (n : ℝ)) • v = 0 := by rw [sub_smul, h2]; abel
  rcases smul_eq_zero.mp hz with h3 | h3
  · linarith [sub_eq_zero.mp h3]
  · exact absurd h3 hv

/-- Every eigenvalue of `Aₙ` has absolute value `√n`. -/
theorem Asign_eig_abs (n : ℕ) (μ : ℝ) (v : Hb n → ℝ) (hv : v ≠ 0)
    (h : (Asign n).mulVec v = μ • v) : |μ| = Real.sqrt n := by
  have hμ : μ ^ 2 = (n : ℝ) := Asign_eig n μ v hv h
  rw [← hμ, Real.sqrt_sq_eq_abs]

/-- `(det Aₙ)² = n^(2ⁿ)`, a determinant consequence of `Aₙ² = nI`. -/
theorem Asign_det_sq (n : ℕ) : (Asign n).det ^ 2 = (n : ℝ) ^ (2 ^ n) := by
  have hdet : (Asign n).det * (Asign n).det
      = ((n : ℝ) • (1 : Matrix (Hb n) (Hb n) ℝ)).det := by
    rw [← Matrix.det_mul, Asign_sq]
  rw [Matrix.det_smul, Matrix.det_one, mul_one, Hb_card] at hdet
  rw [sq]; exact hdet

/-- For `n ≥ 1`, `Aₙ` is invertible with explicit inverse `n⁻¹ • Aₙ`. -/
theorem Asign_mul_inv (n : ℕ) (hn : 1 ≤ n) :
    Asign n * ((n : ℝ)⁻¹ • Asign n) = 1 := by
  rw [Matrix.mul_smul, Asign_sq, smul_smul,
    inv_mul_cancel₀ (by exact_mod_cast Nat.one_le_iff_ne_zero.mp hn), one_smul]

/-- For `n ≥ 1`, `Aₙ` is a unit in the matrix ring. -/
theorem Asign_isUnit (n : ℕ) (hn : 1 ≤ n) : IsUnit (Asign n) := by
  exact IsUnit.of_mul_eq_one _ (Asign_mul_inv n hn)

end SignedAdjacency