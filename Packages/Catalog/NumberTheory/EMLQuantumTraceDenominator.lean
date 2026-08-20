import Mathlib
import Catalog.NumberTheory.EMLQuantumDenominatorObstruction

/-!
# A trace-denominator obstruction in odd dimension

`Catalog/NumberTheory/EMLQuantumDenominatorObstruction.lean` used *row quantization*
`∑_j |H_{ij}|² = t*²` together with the certified enclosure of `t*²` to rule out
Hermitian matrices whose entries are Gaussian rationals of common denominator `q ≤ 64`.
The bound `64` is the exact resolution limit of that enclosure.

This file opens a **second, independent arithmetic channel** and pushes the obstruction
much further in odd dimension.  The input is no longer the enclosure of `t*²` but the
*effective irrationality bound* `scalarLogRoot_ne_rat_of_den_le` (`t*` is no rational of
denominator `≤ 1287`), combined with trace quantization:

* `sum_eigenvalues_eq_of_spectrum` — if every eigenvalue is `± t*` then
  `∑_i d_i = t* (2k − n)` where `k` is the number of `+t*` levels;
* `trace_conj_diagonal` — the trace of `V D V⋆` is `∑_i d_i`;
* `not_unitary_of_odd_card_of_den` — **the obstruction**: if `n` is odd and the diagonal
  entries of `H = V D V⋆` are rationals with common denominator `q` satisfying
  `q · n ≤ 1287`, then the logarithmic activation of `H` is *not* unitary.  Indeed
  `tr H = t*(2k − n)` is then rational with denominator at most `q|2k − n| ≤ q n`, and
  `2k − n ≠ 0` because `n` is odd — so `t*` itself would be a rational of denominator
  `≤ 1287`.
* `not_unitary_of_odd_card_gaussianRat_den` — the Gaussian-rational form: for `n` odd
  the obstruction covers all denominators `q ≤ 1287 / n`, e.g. `q ≤ 1287` in dimension
  one, `q ≤ 429` in dimension three, `q ≤ 257` in dimension five — in every case far
  beyond the `q ≤ 64` reachable from the enclosure of `t*²`, and using only the diagonal
  entries of the Hamiltonian.

All results are unconditional and use only the standard Lean axioms.
-/

open Complex Matrix Set

namespace QuantumEML

namespace TraceDen

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The number of `+t*` levels of a spectrum. -/
noncomputable def levelCount (d : n → ℝ) : ℕ :=
  (Finset.univ.filter fun i => d i = scalarLogRoot).card

omit [DecidableEq n] in
theorem levelCount_le (d : n → ℝ) : levelCount d ≤ Fintype.card n := by
  classical
  simpa [levelCount, Finset.card_univ] using
    Finset.card_le_card (Finset.filter_subset (fun i => d i = scalarLogRoot) Finset.univ)

omit [DecidableEq n] in
/-- **Trace quantization of a two-level spectrum.**  If every `d i` is `± t*` then the
sum of the levels is `t* (2k − n)`, with `k` the number of `+t*` levels. -/
theorem sum_eigenvalues_eq_of_spectrum {d : n → ℝ}
    (hspec : ∀ i, d i = scalarLogRoot ∨ d i = -scalarLogRoot) :
    ∑ i, d i = scalarLogRoot * (2 * (levelCount d : ℝ) - Fintype.card n) := by
  classical
  set s : Finset n := Finset.univ.filter (fun i => d i = scalarLogRoot) with hs
  set u : Finset n := Finset.univ.filter (fun i => ¬ d i = scalarLogRoot) with hu
  have hsplit := Finset.sum_filter_add_sum_filter_not Finset.univ
      (fun i => d i = scalarLogRoot) d
  have key1 : ∀ i ∈ s, d i = scalarLogRoot := by
    intro i hi
    rw [hs] at hi
    exact (Finset.mem_filter.1 hi).2
  have key2 : ∀ i ∈ u, d i = -scalarLogRoot := by
    intro i hi
    rw [hu] at hi
    have hi' := (Finset.mem_filter.1 hi).2
    rcases hspec i with hv | hv
    · exact absurd hv hi'
    · exact hv
  have h1 : ∑ i ∈ s, d i = (s.card : ℝ) * scalarLogRoot := by
    rw [Finset.sum_congr rfl key1]; simp [mul_comm]
  have h2 : ∑ i ∈ u, d i = (u.card : ℝ) * (-scalarLogRoot) := by
    rw [Finset.sum_congr rfl key2]; simp [mul_comm]
  have hcards : s.card + u.card = Fintype.card n := by
    rw [hs, hu]
    simpa [Finset.card_univ] using
      Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset n))
        (p := fun i => d i = scalarLogRoot)
  have hcast : (s.card : ℝ) + (u.card : ℝ) = (Fintype.card n : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hcards
  rw [h1, h2] at hsplit
  rw [← hsplit, levelCount, ← hs, ← hcast]
  ring

/-- The trace of a spectrally presented Hermitian matrix is the sum of its eigenvalues. -/
theorem trace_conj_diagonal {V : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) (d : n → ℝ) :
    (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V).trace = ((∑ i, d i : ℝ) : ℂ) := by
  have h1 : star V * V = 1 := hV.1
  rw [Matrix.trace_mul_comm (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ))) (star V),
    ← Matrix.mul_assoc, h1, Matrix.one_mul, Matrix.trace_diagonal]
  push_cast
  rfl

/-- The Hermitian matrix `V D V⋆` has real diagonal entries. -/
theorem isHermitian_conj_diagonal (V : Matrix n n ℂ) (d : n → ℝ) : (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V).IsHermitian := by
  have hd : (Matrix.diagonal (fun i => ((d i : ℝ) : ℂ))).IsHermitian :=
    Matrix.isHermitian_diagonal_of_self_adjoint _ (by
      funext i
      simp [Complex.conj_ofReal])
  unfold Matrix.IsHermitian
  simp only [Matrix.conjTranspose_mul, Matrix.star_eq_conjTranspose,
    Matrix.conjTranspose_conjTranspose, hd.eq, Matrix.mul_assoc]

/-- **Trace-denominator obstruction in odd dimension.**  Let `H = V D V⋆` be a Hermitian
matrix in odd dimension `n` whose diagonal entries are rationals with common denominator
`q`, where `q n ≤ 1287`.  Then the logarithmic activation of `H` is not unitary.

The proof is a collision of two quantizations: unitarity forces `tr H = t*(2k − n)` with
`2k − n` a nonzero *odd* integer, while the denominator hypothesis forces `tr H ∈ (1/q)ℤ`.
Together they exhibit `t*` as a rational of denominator at most `q n ≤ 1287`, which the
certified isolation of the root forbids. -/
theorem not_unitary_of_odd_card_of_den {q : ℕ} (hq : 1 ≤ q) (hodd : Odd (Fintype.card n))
    (hqn : q * Fintype.card n ≤ 1287) {V : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ))
    (d : n → ℝ)
    (hdiag : ∀ i, ∃ m : ℤ,
      (q : ℂ) * (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V) i i = (m : ℂ)) :
    V * Matrix.diagonal (fun i => Complex.log (1 + (d i : ℂ) * I)) * star V ∉
      unitary (Matrix n n ℂ) := by
  classical
  intro hu
  set H : Matrix n n ℂ := V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V with hH
  have hspec := (spectral_log_activation_mem_unitary_iff hV d).1 hu
  -- trace quantization
  have htr : H.trace = ((scalarLogRoot * (2 * (levelCount d : ℝ) - Fintype.card n) : ℝ) : ℂ) := by
    rw [hH, trace_conj_diagonal hV d, sum_eigenvalues_eq_of_spectrum hspec]
  -- denominator of the trace
  choose m hm using hdiag
  have htr2 : (q : ℂ) * H.trace = ((∑ i, m i : ℤ) : ℂ) := by
    simp only [Matrix.trace, Matrix.diag_apply, Finset.mul_sum]
    push_cast
    exact Finset.sum_congr rfl fun i _ => hm i
  set M : ℤ := ∑ i, m i with hM
  set k : ℕ := levelCount d with hk
  set e : ℤ := 2 * (k : ℤ) - (Fintype.card n : ℤ) with he
  -- the real equation `q t* e = M`
  have hreal : (q : ℝ) * (scalarLogRoot * (e : ℝ)) = (M : ℝ) := by
    have hc : ((q : ℂ)) * ((scalarLogRoot * (2 * (k : ℝ) - Fintype.card n) : ℝ) : ℂ)
        = ((M : ℤ) : ℂ) := by rw [← htr, ← htr2]
    have hc' : (((q : ℝ) * (scalarLogRoot * (e : ℝ)) : ℝ) : ℂ) = (((M : ℝ)) : ℂ) := by
      rw [he]
      push_cast
      push_cast at hc
      linear_combination hc
    exact_mod_cast hc'
  -- `e ≠ 0` because the dimension is odd
  have hene : e ≠ 0 := by
    rcases hodd with ⟨j, hj⟩
    rw [he, hj]
    push_cast
    omega
  have hqpos : (0 : ℤ) < (q : ℤ) := by exact_mod_cast hq
  have hqe : ((q : ℤ) * e) ≠ 0 := mul_ne_zero (by omega) hene
  -- hence `t*` is the rational `M / (q e)`
  set r : ℚ := Rat.divInt M ((q : ℤ) * e) with hr
  have hrreal : (r : ℝ) = scalarLogRoot := by
    have hqeR : (((q : ℤ) * e : ℤ) : ℝ) ≠ 0 := Int.cast_ne_zero.2 hqe
    rw [hr, Rat.divInt_eq_div]
    push_cast
    field_simp
    push_cast at hreal
    linarith [hreal]
  -- but its denominator is small
  have hden : (r.den : ℤ) ∣ (q : ℤ) * e := hr ▸ Rat.den_dvd M ((q : ℤ) * e)
  have hdenle : (r.den : ℤ) ≤ |(q : ℤ) * e| :=
    Int.le_of_dvd (abs_pos.2 hqe) ((dvd_abs _ _).2 hden)
  have hele : |e| ≤ (Fintype.card n : ℤ) := by
    have hkle : (k : ℤ) ≤ (Fintype.card n : ℤ) := by
      exact_mod_cast levelCount_le d
    have hk0 : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg k
    rw [he, abs_le]
    omega
  have hfin : (r.den : ℤ) ≤ 1287 := by
    have habs : |(q : ℤ) * e| = (q : ℤ) * |e| := by
      rw [abs_mul, abs_of_pos hqpos]
    have hmul : (q : ℤ) * |e| ≤ (q : ℤ) * (Fintype.card n : ℤ) :=
      mul_le_mul_of_nonneg_left hele (by omega)
    have hqn' : (q : ℤ) * (Fintype.card n : ℤ) ≤ 1287 := by exact_mod_cast hqn
    omega
  exact scalarLogRoot_ne_rat_of_den_le r (by exact_mod_cast hfin) hrreal

/-- **Gaussian-rational form.**  In odd dimension `n`, no Hermitian matrix whose entries
are Gaussian rationals with common denominator `q ≤ 1287 / n` has a unitary logarithmic
activation.  For `n = 1, 3, 5` this covers `q ≤ 1287, 429, 257`, far beyond the bound
`q ≤ 64` obtainable from the enclosure of `t*²` alone. -/
theorem not_unitary_of_odd_card_gaussianRat_den {q : ℕ} (hq : 1 ≤ q)
    (hodd : Odd (Fintype.card n)) (hqn : q * Fintype.card n ≤ 1287) {V : Matrix n n ℂ}
    (hV : V ∈ unitary (Matrix n n ℂ)) (d : n → ℝ)
    (hent : ∀ i j, ∃ a b : ℤ,
      (q : ℂ) * (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V) i j
        = (a : ℂ) + (b : ℂ) * I) :
    V * Matrix.diagonal (fun i => Complex.log (1 + (d i : ℂ) * I)) * star V ∉
      unitary (Matrix n n ℂ) := by
  refine not_unitary_of_odd_card_of_den hq hodd hqn hV d ?_
  intro i
  obtain ⟨a, b, hab⟩ := hent i i
  set H : Matrix n n ℂ := V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V with hH
  have hHerm := isHermitian_conj_diagonal V d
  -- the diagonal entry is real, so its imaginary part `b / q` vanishes
  have hreal : (H i i).im = 0 := by
    have := hHerm.apply i i
    have hconj : (starRingEnd ℂ) (H i i) = H i i := by
      simpa [Matrix.conjTranspose_apply] using this
    have := congrArg Complex.im hconj
    simp only [Complex.conj_im] at this
    linarith
  have him : (b : ℝ) = 0 := by
    have h1 := congrArg Complex.im hab
    simp only [Complex.mul_im, Complex.add_im, Complex.I_re, Complex.I_im,
      Complex.natCast_re, Complex.natCast_im,
      Complex.intCast_re, Complex.intCast_im, hreal] at h1
    simpa using h1.symm
  have hb0 : (b : ℂ) = 0 := by exact_mod_cast him
  refine ⟨a, ?_⟩
  rw [hab, hb0]
  ring

end TraceDen

end QuantumEML