import Mathlib
import Catalog.NumberTheory.EMLQuantumScalarLogRootIsolation

/-!
# An effective denominator obstruction for quantum EML Hamiltonians

`Catalog/NumberTheory/EMLQuantumScalarLogRootIsolation.lean` isolates the scalar-log root
`t*` — the unique positive solution of `‖log (1 + t i)‖ = 1` — inside the certified
interval `[1.2290370, 1.2290381]`, and shows (spectral rigidity) that the logarithmic
activation `log (I + i H)` of a Hermitian matrix is unitary exactly when
`H² = t*² · I`.

The previous instalment deduced an *integrality* obstruction: an integer Hermitian
matrix never has a unitary activation, because `1 < t*² < 2`.  Here we push the same idea
as far as the certified interval allows, obtaining an **effective denominator
obstruction**:

> no Hermitian matrix whose entries are Gaussian rationals with a common denominator
> `q ≤ 64` satisfies `H² = t*² I`.

The mechanism is the *row quantization* identity `∑_j |H_{ij}|² = t*²`
(`row_normSq_eq`): clearing denominators turns it into `m = q² t*²` for a nonnegative
integer `m`, and the certified enclosure

`1.510531947369 ≤ t*² ≤ 1.510534651252`

(`scalarLogRoot_sq_mem_Icc`) leaves no room for such an integer once `q ≤ 64`.  The
finite arithmetic check is discharged by `decide` on exact integer arithmetic
(`no_integer_multiple`); the bound `64` is exactly where the current width of the
certified interval runs out (for `q = 65` the interval `[q²·L, q²·U]` does contain an
integer, so the obstruction cannot be pushed further without a sharper enclosure).

All results are unconditional and use only the standard Lean axioms.
-/

open Complex Matrix Set

namespace QuantumEML

namespace Denominator

/-! ### A sharper enclosure for `t*²` -/

/-- **Certified enclosure of the squared root**: `t*² ∈ [1.510531947369, 1.510534651252]`,
obtained by squaring the certified interval for `t*`. -/
theorem scalarLogRoot_sq_mem_Icc :
    scalarLogRoot ^ 2 ∈ Icc ((12290370 : ℝ) ^ 2 / 10 ^ 14) ((12290381 : ℝ) ^ 2 / 10 ^ 14) := by
  obtain ⟨hlo, hhi⟩ := scalarLogRoot_mem_Icc
  have hpos : (0 : ℝ) < scalarLogRoot := scalarLogRoot_pos
  constructor
  · nlinarith [hlo, hpos]
  · nlinarith [hhi, hpos, hlo]

/-! ### Row quantization -/

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- **Row quantization.**  If a Hermitian `H` satisfies the rigidity relation
`H² = t*² I`, then every row of `H` has squared Euclidean norm exactly `t*²`. -/
theorem row_normSq_eq {H : Matrix n n ℂ} (hH : H.IsHermitian)
    (hsq : H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ)) (i : n) :
    ∑ j, ‖H i j‖ ^ 2 = scalarLogRoot ^ 2 := by
  have hentry := congrFun (congrFun hsq i) i
  rw [Matrix.mul_apply] at hentry
  simp only [Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul, mul_one] at hentry
  have hterm : ∀ j, H i j * H j i = ((‖H i j‖ ^ 2 : ℝ) : ℂ) := by
    intro j
    have hji : H j i = star (H i j) := (hH.apply j i).symm
    rw [hji, show (star (H i j)) = (starRingEnd ℂ) (H i j) from rfl, Complex.mul_conj]
    norm_cast
    exact Complex.normSq_eq_norm_sq (H i j)
  rw [Finset.sum_congr rfl (fun j _ => hterm j)] at hentry
  have hc : ((∑ j, ‖H i j‖ ^ 2 : ℝ) : ℂ) = ((scalarLogRoot ^ 2 : ℝ) : ℂ) := by
    push_cast at hentry ⊢
    exact hentry
  exact_mod_cast hc

/-! ### The finite arithmetic certificate -/

set_option maxRecDepth 10000 in
/-- **The arithmetic certificate.**  For every `1 ≤ q ≤ 64` the real interval
`[q² · 1.2290370², q² · 1.2290381²]` contains no integer.  Stated in cleared-denominator
form: the largest multiple of `10¹⁴` below the right endpoint already lies below the left
endpoint.  Verified by exact integer arithmetic. -/
theorem no_integer_multiple : ∀ q ∈ Finset.Icc (1 : ℤ) 64,
    (q ^ 2 * 12290381 ^ 2) / 10 ^ 14 * 10 ^ 14 < q ^ 2 * 12290370 ^ 2 := by decide

/-! ### The denominator obstruction -/

/-- **Effective denominator obstruction.**  Let `H` be a Hermitian matrix all of whose
entries become Gaussian integers after multiplication by a fixed `q` with `1 ≤ q ≤ 64`
(i.e. all entries are Gaussian rationals with common denominator `q`).  Then `H` does not
satisfy the rigidity relation `H² = t*² I`.

For `q = 1` this recovers the Gaussian-integer (hence integer) obstruction; the content
here is the uniform treatment of all denominators up to the resolution of the certified
enclosure. -/
theorem not_sq_eq_of_den_le [Nonempty n] {q : ℕ} (hq1 : 1 ≤ q) (hq64 : q ≤ 64)
    {H : Matrix n n ℂ} (hH : H.IsHermitian)
    (hsq : H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ))
    (hent : ∀ i j, ∃ a b : ℤ, (q : ℂ) * H i j = (a : ℂ) + (b : ℂ) * I) : False := by
  obtain ⟨i⟩ := ‹Nonempty n›
  choose a b hab using hent i
  have hrow := row_normSq_eq hH hsq i
  -- each entry contributes an integer after clearing the denominator
  have hnorm : ∀ j, (q : ℝ) ^ 2 * ‖H i j‖ ^ 2 = ((a j ^ 2 + b j ^ 2 : ℤ) : ℝ) := by
    intro j
    have hqn : ‖(q : ℂ) * H i j‖ ^ 2 = ((a j ^ 2 + b j ^ 2 : ℤ) : ℝ) := by
      rw [hab j, ← Complex.normSq_eq_norm_sq]
      simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
        Complex.mul_re, Complex.mul_im, Complex.I_re, Complex.I_im,
        Complex.intCast_re, Complex.intCast_im]
      push_cast
      ring
    rw [← hqn, norm_mul, mul_pow]
    simp
  -- summing the row identity
  have hsum : ((∑ j, (a j ^ 2 + b j ^ 2) : ℤ) : ℝ) = (q : ℝ) ^ 2 * scalarLogRoot ^ 2 := by
    rw [← hrow, Finset.mul_sum]
    push_cast
    exact (Finset.sum_congr rfl (fun j _ => by
      have := hnorm j
      push_cast at this
      linarith)).symm
  set m : ℤ := ∑ j, (a j ^ 2 + b j ^ 2) with hm
  obtain ⟨hlo, hhi⟩ := scalarLogRoot_sq_mem_Icc
  have hqR : (0 : ℝ) ≤ (q : ℝ) ^ 2 := by positivity
  -- integer inequalities after clearing `10¹⁴`
  have h1R : ((q : ℝ) ^ 2 * 12290370 ^ 2 : ℝ) ≤ (m : ℝ) * 10 ^ 14 := by
    rw [hsum]
    nlinarith [hlo, hqR]
  have h2R : (m : ℝ) * 10 ^ 14 ≤ ((q : ℝ) ^ 2 * 12290381 ^ 2 : ℝ) := by
    rw [hsum]
    nlinarith [hhi, hqR]
  have h1 : ((q : ℤ) ^ 2 * 12290370 ^ 2 : ℤ) ≤ m * 10 ^ 14 := by exact_mod_cast h1R
  have h2 : m * 10 ^ 14 ≤ ((q : ℤ) ^ 2 * 12290381 ^ 2 : ℤ) := by exact_mod_cast h2R
  -- the certificate rules this out
  have hqmem : (q : ℤ) ∈ Finset.Icc (1 : ℤ) 64 := by
    simp only [Finset.mem_Icc]
    constructor
    · exact_mod_cast hq1
    · exact_mod_cast hq64
  have hcert := no_integer_multiple (q : ℤ) hqmem
  have hle : m ≤ ((q : ℤ) ^ 2 * 12290381 ^ 2) / 10 ^ 14 :=
    (Int.le_ediv_iff_mul_le (by norm_num)).2 h2
  have := mul_le_mul_of_nonneg_right hle (by norm_num : (0 : ℤ) ≤ 10 ^ 14)
  linarith

/-- **Denominator obstruction, activation form.**  In the spectral presentation used by
`spectral_log_activation_mem_unitary_iff_sq`, a Hamiltonian whose entries are Gaussian
rationals of common denominator `q ≤ 64` never has a unitary logarithmic activation. -/
theorem spectral_log_activation_not_mem_unitary_of_den_le [Nonempty n] {q : ℕ}
    (hq1 : 1 ≤ q) (hq64 : q ≤ 64) {V : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ))
    (d : n → ℝ)
    (hent : ∀ i j, ∃ a b : ℤ,
      (q : ℂ) * (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V) i j
        = (a : ℂ) + (b : ℂ) * I) :
    V * Matrix.diagonal (fun i => Complex.log (1 + (d i : ℂ) * I)) * star V ∉
      unitary (Matrix n n ℂ) := by
  intro hu
  set H : Matrix n n ℂ := V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V with hH_def
  have hsq2 : H ^ 2 = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) :=
    (spectral_log_activation_mem_unitary_iff_sq hV d).1 hu
  have hsq : H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
    rw [← pow_two]; exact hsq2
  have hHerm : H.IsHermitian := by
    have hd : (Matrix.diagonal (fun i => ((d i : ℝ) : ℂ))).IsHermitian :=
      Matrix.isHermitian_diagonal_of_self_adjoint _ (by
        funext i
        simp [Complex.conj_ofReal])
    unfold Matrix.IsHermitian
    rw [hH_def]
    simp only [Matrix.conjTranspose_mul, Matrix.star_eq_conjTranspose,
      Matrix.conjTranspose_conjTranspose, hd.eq, Matrix.mul_assoc]
  exact not_sq_eq_of_den_le hq1 hq64 hHerm hsq hent

end Denominator

end QuantumEML