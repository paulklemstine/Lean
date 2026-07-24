/-
# Fixed-amplitude complex-weighted undirected graphs: spectral line-locking

This file develops, as a self-contained chain of results, the algebraic core of the
*fixed-amplitude model*: an undirected graph whose present edges all carry one common
complex weight `z`.  The weighted adjacency matrix is `z • B`, where `B` is the
(Hermitian, `0/1`) indicator matrix of the symmetric edge relation.

The central theorem is **spectral line-locking** (`line_locking`): for nonzero `z` and
Hermitian `B`, *every* eigenvalue of `z • B` is `z` times a real number, so the whole
spectrum of `z • B` lies on the one-dimensional line `ℝ · z ⊆ ℂ`.

The chain, each step building on the previous ones:

1. `real_of_im_zero`         – a complex number with zero imaginary part is real.
2. `rayleigh_hermitian_real` – the Hermitian Rayleigh quotient `⟨v, B v⟩` is real.
3. `rayleigh_scaled`         – scaling the matrix scales the Rayleigh quotient.
4. `rayleigh_scaled_real`    – hence `⟨v, (z•B) v⟩` is `z` times a real number.
5. `line_locking`            – every eigenvalue of `z • B` is `z` times a real number.
6. `spectrum_on_line`        – restatement: eigenvalue lies on the line `ℝ · z`.
7. `trace_weighted`          – `tr(z•B) = z · tr B`; vanishes for a loopless graph.
8. `det_weighted`            – `det(z•B) = zⁿ · det B`.
9. `weighted_singular_iff`   – for `z ≠ 0`, singularity of `z•B` is a property of `B`.
10. complete graph `Kgraph`  – Hermitian, loopless, `Kgraph *ᵥ 1 = (n-1)·1`.
11. `complete_eigenvalue`    – `(n-1)·z` is an eigenvalue of the weighted `Kₙ`.
12. `complete_outlier_escapes` – for `n ≥ 3` that eigenvalue's modulus exceeds `√n·‖z‖`.
-/
import Mathlib

open scoped Matrix ComplexOrder

namespace FixedAmplitude

/-! ## Step 1 – reality of a complex number with vanishing imaginary part -/

/-- A complex number whose `RCLike` imaginary part vanishes equals its real part. -/
theorem real_of_im_zero (q : ℂ) (h : RCLike.im q = 0) :
    q = ((RCLike.re q : ℝ) : ℂ) := by
  have him : q.im = 0 := h
  have hre : (RCLike.re q : ℝ) = q.re := rfl
  rw [hre]; apply Complex.ext <;> simp [him]

/-! ## Step 2 – the Hermitian Rayleigh quotient is real -/

/-- For a Hermitian matrix `B`, the Rayleigh quotient `⟨v, B v⟩ = star v ⬝ᵥ B *ᵥ v`
is a real number (equal to the coercion of its real part). -/
theorem rayleigh_hermitian_real {n : Type*} [Fintype n] {B : Matrix n n ℂ}
    (hB : B.IsHermitian) (v : n → ℂ) :
    star v ⬝ᵥ B *ᵥ v = ((RCLike.re (star v ⬝ᵥ B *ᵥ v) : ℝ) : ℂ) :=
  real_of_im_zero _ (hB.im_star_dotProduct_mulVec_self v)

/-! ## Step 3 – scaling the matrix scales the Rayleigh quotient -/

/-- Scaling the matrix by a complex scalar `z` scales the Rayleigh quotient by `z`. -/
theorem rayleigh_scaled {n : Type*} [Fintype n] (B : Matrix n n ℂ) (z : ℂ)
    (v : n → ℂ) :
    star v ⬝ᵥ (z • B) *ᵥ v = z * (star v ⬝ᵥ B *ᵥ v) := by
  rw [Matrix.smul_mulVec, dotProduct_smul, smul_eq_mul]

/-- Combining Steps 2 and 3: the Rayleigh quotient of the *weighted* matrix `z • B`
is `z` times a real number. -/
theorem rayleigh_scaled_real {n : Type*} [Fintype n] {B : Matrix n n ℂ}
    (hB : B.IsHermitian) (z : ℂ) (v : n → ℂ) :
    ∃ r : ℝ, star v ⬝ᵥ (z • B) *ᵥ v = z * r := by
  refine ⟨RCLike.re (star v ⬝ᵥ B *ᵥ v), ?_⟩
  rw [rayleigh_scaled]
  congr 1
  exact rayleigh_hermitian_real hB v

/-! ## Step 4 – spectral line-locking -/

/-- **Spectral line-locking.**  If `B` is Hermitian and `v ≠ 0` is an eigenvector of the
weighted matrix `z • B` with eigenvalue `μ`, then `μ = z · r` for some real `r`.
Thus the entire spectrum of `z • B` lies on the complex line `ℝ · z`. -/
theorem line_locking {n : Type*} [Fintype n] [DecidableEq n] {B : Matrix n n ℂ}
    (hB : B.IsHermitian) (z μ : ℂ) (v : n → ℂ) (hv : v ≠ 0)
    (hev : (z • B) *ᵥ v = μ • v) : ∃ r : ℝ, μ = z * r := by
  set q := star v ⬝ᵥ B *ᵥ v with hq
  set s := star v ⬝ᵥ v with hs
  -- `q` is real (Step 2); `s = ⟨v, v⟩` is real and nonzero.
  have hqc : q = ((RCLike.re q : ℝ) : ℂ) := rayleigh_hermitian_real hB v
  have hsim : RCLike.im s = 0 := by
    have h1 := (Matrix.isHermitian_one (n := n) (α := ℂ)).im_star_dotProduct_mulVec_self v
    simpa using h1
  have hsc : s = ((RCLike.re s : ℝ) : ℂ) := real_of_im_zero s hsim
  have hsne : s ≠ 0 := fun h => hv (dotProduct_star_self_eq_zero.1 h)
  -- Eigenvalue equation, tested against `v`, gives `μ · s = z · q`.
  have key : μ * s = z * q := by
    have e1 : star v ⬝ᵥ ((z • B) *ᵥ v) = z * q := rayleigh_scaled B z v
    have e2 : star v ⬝ᵥ ((z • B) *ᵥ v) = μ * s := by
      rw [hev, dotProduct_smul, smul_eq_mul, mul_comm]
    rw [e2] at e1; exact e1
  have hsr : (RCLike.re s : ℝ) ≠ 0 := by
    intro h; apply hsne; rw [hsc, h]; simp
  refine ⟨(RCLike.re q) / (RCLike.re s), ?_⟩
  rw [hqc, hsc] at key
  have hsr' : ((RCLike.re s : ℝ) : ℂ) ≠ 0 := by exact_mod_cast hsr
  rw [Complex.ofReal_div]
  field_simp
  linear_combination key

/-- Restatement of line-locking as membership in the complex line `ℝ · z` through the
origin: every eigenvalue `μ` of `z • B` is of the form `(r : ℂ) • z`. -/
theorem spectrum_on_line {n : Type*} [Fintype n] [DecidableEq n] {B : Matrix n n ℂ}
    (hB : B.IsHermitian) (z μ : ℂ) (v : n → ℂ) (hv : v ≠ 0)
    (hev : (z • B) *ᵥ v = μ • v) : μ ∈ Set.range (fun r : ℝ => (r : ℂ) • z) := by
  obtain ⟨r, hr⟩ := line_locking hB z μ v hv hev
  refine ⟨r, ?_⟩
  show (r : ℂ) • z = μ
  rw [smul_eq_mul, mul_comm]; exact hr.symm

/-! ## Steps 7–9 – global multiplicative invariants -/

/-- The trace scales linearly: `tr(z • B) = z · tr B`. -/
theorem trace_weighted {n : Type*} [Fintype n] (B : Matrix n n ℂ) (z : ℂ) :
    (z • B).trace = z * B.trace := by
  rw [Matrix.trace_smul, smul_eq_mul]

/-- A loopless graph (zero diagonal) has vanishing weighted trace, for every weight. -/
theorem trace_weighted_loopless {n : Type*} [Fintype n] (B : Matrix n n ℂ) (z : ℂ)
    (hdiag : ∀ i, B i i = 0) : (z • B).trace = 0 := by
  rw [trace_weighted, Matrix.trace]
  simp [Matrix.diag, hdiag]

/-- The determinant scales by the `n`-th power of the weight: `det(z • B) = zⁿ · det B`. -/
theorem det_weighted {n : Type*} [Fintype n] [DecidableEq n] (B : Matrix n n ℂ) (z : ℂ) :
    (z • B).det = z ^ Fintype.card n * B.det :=
  Matrix.det_smul B z

/-- For a nonzero weight, singularity of the weighted matrix is a purely combinatorial
property of the indicator matrix `B`: `z • B` is singular iff `B` is. -/
theorem weighted_singular_iff {n : Type*} [Fintype n] [DecidableEq n] (B : Matrix n n ℂ)
    {z : ℂ} (hz : z ≠ 0) : (z • B).det = 0 ↔ B.det = 0 := by
  rw [det_weighted, mul_eq_zero, or_iff_right (pow_ne_zero _ hz)]

/-! ## Steps 10–12 – the complete graph and the mean-direction outlier -/

/-- The `0/1` indicator matrix of the complete graph `Kₙ`: every off-diagonal entry is
`1`, the diagonal is `0` (loopless). -/
def Kgraph (n : ℕ) : Matrix (Fin n) (Fin n) ℂ := fun i j => if i = j then 0 else 1

/-- The complete-graph indicator matrix is Hermitian. -/
theorem Kgraph_isHermitian (n : ℕ) : (Kgraph n).IsHermitian := by
  unfold Matrix.IsHermitian Kgraph
  ext i j
  simp only [Matrix.conjTranspose_apply]
  rcases eq_or_ne i j with h | h <;> simp [h, eq_comm]

/-- The complete graph is loopless (zero diagonal). -/
theorem Kgraph_loopless (n : ℕ) (i : Fin n) : Kgraph n i i = 0 := by
  simp [Kgraph]

/-- Acting on the all-ones vector, the complete-graph matrix returns the constant
row-sum `n - 1`. -/
theorem Kgraph_mulVec_ones (n : ℕ) :
    (Kgraph n) *ᵥ (fun _ => (1 : ℂ)) = (fun _ => (n - 1 : ℂ)) := by
  ext i
  simp only [Matrix.mulVec, Kgraph, dotProduct, mul_one]
  have hsplit : ∀ j, (if i = j then (0 : ℂ) else 1) = 1 - (if i = j then 1 else 0) := by
    intro j; split <;> simp
  simp_rw [hsplit, Finset.sum_sub_distrib]
  simp [Finset.sum_ite_eq]

/-- **Mean-direction eigenvalue.**  For the fixed-amplitude complete graph the all-ones
vector is an eigenvector of `z • Kₙ` with eigenvalue `(n-1)·z`. -/
theorem complete_eigenvalue (n : ℕ) (z : ℂ) :
    (z • Kgraph n) *ᵥ (fun _ => (1 : ℂ)) = ((n - 1 : ℂ) * z) • (fun _ => (1 : ℂ)) := by
  rw [Matrix.smul_mulVec, Kgraph_mulVec_ones]
  funext i
  simp [mul_comm]

/-- The mean-direction eigenvalue `(n-1)·z` genuinely lies on the line `ℝ · z`
(consistency of `complete_eigenvalue` with `line_locking`). -/
theorem complete_eigenvalue_on_line (n : ℕ) (z : ℂ) :
    ∃ r : ℝ, (n - 1 : ℂ) * z = z * r := by
  refine ⟨(n : ℝ) - 1, ?_⟩
  push_cast
  ring

/-- A real arithmetic fact: for `n ≥ 3` one has `√n < n - 1`. -/
theorem sqrt_lt_pred (n : ℕ) (hn : 3 ≤ n) : Real.sqrt n < (n : ℝ) - 1 := by
  have hcast : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h1 : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  rw [Real.sqrt_lt' h1]
  nlinarith [hcast]

/-- **Outlier escapes the naive radius.**  For every order `n ≥ 3` and nonzero weight
`z`, the modulus of the mean-direction eigenvalue `(n-1)·z` strictly exceeds the naive
radius `√n · ‖z‖`.  Hence this eigenvalue is a genuine outlier of the spectrum. -/
theorem complete_outlier_escapes (n : ℕ) (hn : 3 ≤ n) (z : ℂ) (hz : z ≠ 0) :
    Real.sqrt n * ‖z‖ < ‖((n : ℂ) - 1) * z‖ := by
  have hzpos : 0 < ‖z‖ := by simpa using hz
  have hcast : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hnorm : ‖((n : ℂ) - 1)‖ = (n : ℝ) - 1 := by
    have hre : ((n : ℂ) - 1) = (((n : ℕ) - 1 : ℕ) : ℂ) := by
      rw [Nat.cast_sub (by omega)]; simp
    rw [hre, Complex.norm_natCast, Nat.cast_sub (by omega)]
    simp
  rw [norm_mul, hnorm]
  have hlt := sqrt_lt_pred n hn
  nlinarith [hlt, hzpos]

end FixedAmplitude