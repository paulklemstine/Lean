import Applications.AdjacentSumPolytopes.Basic

/-!
# Cayley–Hamilton recurrences and the shared characteristic denominator

Building on `Applications.AdjacentSumPolytopes.Basic`, where the open and cyclic
adjacent-sum lattice counts were identified with matrix entries and traces of powers
of the `(s+1)`-state transfer matrix `adjMat s`, we deduce:

* a **linear recurrence of order `s + 2`** satisfied by *both* the open counts and the
  cyclic counts, with coefficients the coefficients of the characteristic polynomial
  of the transfer matrix (`openCount_recurrence`, `cycCount_recurrence`);
* the resulting **shared characteristic denominator** for the two generating functions
  (`openSeries_mul_charDenom_isPoly`, `cycSeries_mul_charDenom_isPoly`): multiplying
  either formal power series by the *same* reciprocal characteristic polynomial
  `charDenom s` produces a polynomial of degree `≤ s`;
* the **Jacobi derivative identity** in the two-state case (`jacobi_two_state`):
  `(∑ₙ tr(Mⁿ) Xⁿ) · det(I − XM) = 2 − tr(M)·X = 2·p(X) − X·p'(X)` for `p = det(I − XM)`,
  which is the `k = 2` instance of `∑ₙ tr(Mⁿ)Xⁿ = (k·p − X p')/p`.

The general algebraic engine (`charpoly_pow_recurrence`, `charpoly_trace_recurrence`,
`charpoly_entry_recurrence`, `coeff_mul_revDenom`) is stated for arbitrary square
matrices over a commutative ring and for arbitrary linearly recurrent sequences, so it
applies verbatim to the `(s+2)`-state matrices of the lattice-polytope model.

-- !-- Lab Notes -- !--
* **Hypothesis.** Since the open counts are bilinear-form values `1ᵀ Mᵈ 1` and the
  cyclic counts are traces `tr Mᵈ`, Cayley–Hamilton should force *both* to obey the
  characteristic recurrence, i.e. the two Ehrhart-type series share a denominator.
* **Experiment.** For `s = 2` the characteristic polynomial of `adjMat 2` is
  `X³ − 2X² − X + 1`, and indeed both `3, 6, 14, 31, 70, 157, 353, 793` (open) and
  `2, 6, 11, 26, 57, 129, 289, 650` (cyclic) satisfy `a₍ₙ₊₃₎ = 2a₍ₙ₊₂₎ + a₍ₙ₊₁₎ − aₙ`:
  `31 = 2·14 + 6 − 3`, `70 = 2·31 + 14 − 6`, `26 = 2·11 + 6 − 2`, `57 = 2·26 + 11 − 6`.
  Computed characteristic polynomials (coefficients from the top): `s = 1 : (1,−1,−1)`,
  `s = 2 : (1,−2,−1,1)`, `s = 3 : (1,−2,−3,1,1)`, `s = 4 : (1,−3,−3,4,1,−1)`,
  `s = 5 : (1,−3,−6,4,5,−1,−1)` — the signs run in a period-four pattern `+,−,−,+`.
* **Analysis.** The recurrence survives with no positivity or irreducibility
  hypotheses whatsoever: it is pure Cayley–Hamilton.  What is *not* automatic is the
  numerator, which differs between the two parity classes; the two-state Jacobi
  identity pins it down for `k = 2`.
* **Critique.** `charpoly_pow_recurrence` needs `Nontrivial R` (for
  `charpoly_natDegree_eq_dim`); over the trivial ring everything is `0` anyway.  The
  power-series lemma is stated for `k ≤ m` — for `m < k` the coefficients are exactly
  the numerator and are generally nonzero, so the bound is sharp.
-/

namespace AdjSum

open Finset Matrix Polynomial PowerSeries

/-! ## Generic Cayley–Hamilton recurrences -/

/-- Cayley–Hamilton in "shifted" form: the matrix powers `M ^ (m + i)` satisfy the
linear recurrence given by the coefficients of the characteristic polynomial. -/
theorem charpoly_pow_recurrence {R : Type*} [CommRing R] [Nontrivial R] {n : ℕ}
    (M : Matrix (Fin n) (Fin n) R) (m : ℕ) :
    ∑ i ∈ Finset.range (n + 1), M.charpoly.coeff i • M ^ (m + i) = 0 := by
  have h0 : (Polynomial.aeval M) M.charpoly = 0 := Matrix.aeval_self_charpoly M
  have hdeg : M.charpoly.natDegree = n := by
    rw [M.charpoly_natDegree_eq_dim, Fintype.card_fin]
  rw [Polynomial.aeval_eq_sum_range, hdeg] at h0
  calc ∑ i ∈ Finset.range (n + 1), M.charpoly.coeff i • M ^ (m + i)
      = (∑ i ∈ Finset.range (n + 1), M.charpoly.coeff i • M ^ i) * M ^ m := by
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl (fun i _ => ?_)
        rw [smul_mul_assoc, ← pow_add, add_comm i m]
    _ = 0 := by rw [h0, zero_mul]

/-- The traces of the powers of a matrix satisfy the characteristic recurrence. -/
theorem charpoly_trace_recurrence {R : Type*} [CommRing R] [Nontrivial R] {n : ℕ}
    (M : Matrix (Fin n) (Fin n) R) (m : ℕ) :
    ∑ i ∈ Finset.range (n + 1), M.charpoly.coeff i * Matrix.trace (M ^ (m + i)) = 0 := by
  have h := congrArg Matrix.trace (charpoly_pow_recurrence M m)
  rw [Matrix.trace_sum, Matrix.trace_zero] at h
  simpa [Matrix.trace_smul, smul_eq_mul] using h

/-- Every fixed matrix entry of the powers of a matrix satisfies the characteristic
recurrence. -/
theorem charpoly_entry_recurrence {R : Type*} [CommRing R] [Nontrivial R] {n : ℕ}
    (M : Matrix (Fin n) (Fin n) R) (m : ℕ) (a b : Fin n) :
    ∑ i ∈ Finset.range (n + 1), M.charpoly.coeff i * ((M ^ (m + i)) a b) = 0 := by
  have h := congrFun (congrFun (charpoly_pow_recurrence M m) a) b
  simpa [Matrix.sum_apply, smul_eq_mul] using h

/-! ## Generating functions of linearly recurrent sequences -/

/-- The reciprocal ("reversed") polynomial `∑ᵢ cᵢ X^{k-i}` of a recurrence, viewed as a
formal power series.  For `c = ` coefficients of a characteristic polynomial this is
`det (I - X M)`. -/
noncomputable def revDenom {R : Type*} [CommRing R] (k : ℕ) (c : ℕ → R) : PowerSeries R :=
  ∑ i ∈ Finset.range (k + 1), PowerSeries.C (c i) * PowerSeries.X ^ (k - i)

/-- **Denominator lemma.**  If `a` satisfies the order-`k` linear recurrence with
coefficients `c`, then all coefficients of `(∑ aₙ Xⁿ) · revDenom k c` in degrees `≥ k`
vanish; i.e. the generating function of `a` is a rational function with denominator
`revDenom k c`. -/
theorem coeff_mul_revDenom {R : Type*} [CommRing R] (k : ℕ) (c a : ℕ → R)
    (hrec : ∀ m, ∑ i ∈ Finset.range (k + 1), c i * a (m + i) = 0) (m : ℕ) (hm : k ≤ m) :
    PowerSeries.coeff m ((PowerSeries.mk a) * revDenom k c) = 0 := by
  rw [revDenom, Finset.mul_sum, map_sum, ← hrec (m - k)]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  rw [Finset.mem_range] at hi
  have hik : k - i ≤ m := by omega
  rw [show (PowerSeries.mk a) * (PowerSeries.C (c i) * PowerSeries.X ^ (k - i))
      = PowerSeries.C (c i) * ((PowerSeries.mk a) * PowerSeries.X ^ (k - i)) by ring]
  rw [PowerSeries.coeff_C_mul, PowerSeries.coeff_mul_X_pow', if_pos hik, PowerSeries.coeff_mk]
  congr 2
  omega

/-- A power series whose coefficients vanish from degree `k` on is (the image of) its
own truncation, hence a polynomial. -/
theorem eq_coe_trunc_of_coeff_eq_zero {R : Type*} [CommRing R] (k : ℕ) (f : PowerSeries R)
    (h : ∀ m, k ≤ m → PowerSeries.coeff m f = 0) :
    f = ((PowerSeries.trunc k f : Polynomial R) : PowerSeries R) := by
  ext m
  rw [Polynomial.coeff_coe, PowerSeries.coeff_trunc]
  by_cases hm : m < k
  · rw [if_pos hm]
  · rw [if_neg hm, h m (by omega)]

/-! ## The integral transfer matrix -/

/-- The adjacent-sum transfer matrix with integer entries. -/
def adjMatZ (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ :=
  fun a b => if (a : ℕ) + (b : ℕ) ≤ s then 1 else 0

lemma adjMatZ_eq_map (s : ℕ) :
    adjMatZ s = (Nat.castRingHom ℤ).mapMatrix (adjMat s) := by
  ext a b
  simp only [adjMatZ, RingHom.mapMatrix_apply, Matrix.map_apply, adjMat_apply,
    Nat.castRingHom]
  split <;> simp

lemma adjMatZ_pow_apply (s d : ℕ) (a b : Fin (s + 1)) :
    ((adjMatZ s) ^ d) a b = (((adjMat s ^ d) a b : ℕ) : ℤ) := by
  rw [adjMatZ_eq_map, ← map_pow]
  simp [RingHom.mapMatrix_apply, Matrix.map_apply]

lemma trace_adjMatZ_pow (s d : ℕ) :
    Matrix.trace ((adjMatZ s) ^ d) = ((Matrix.trace (adjMat s ^ d) : ℕ) : ℤ) := by
  simp [Matrix.trace, Matrix.diag, adjMatZ_pow_apply]

/-! ## Counting functions and their common recurrence -/

/-- Number of open adjacent-sum lattice points of length `d + 1`. -/
def openCount (s d : ℕ) : ℕ := (openSet s d).card

/-- Number of cyclic adjacent-sum lattice points of length `d + 1`. -/
def cycCount (s d : ℕ) : ℕ := (cycSet s d).card

lemma openCount_eq (s d : ℕ) :
    (openCount s d : ℤ) = ∑ a, ∑ b, ((adjMatZ s) ^ d) a b := by
  simp [openCount, card_openSet, adjMatZ_pow_apply]

lemma cycCount_eq (s d : ℕ) :
    (cycCount s d : ℤ) = Matrix.trace ((adjMatZ s) ^ (d + 1)) := by
  rw [cycCount, card_cycSet, trace_adjMatZ_pow]

/-- **Shared characteristic recurrence, cyclic class.**  The cyclic adjacent-sum counts
satisfy the order-`s+2` linear recurrence given by the characteristic polynomial of the
transfer matrix. -/
theorem cycCount_recurrence (s m : ℕ) :
    ∑ i ∈ Finset.range (s + 2), (adjMatZ s).charpoly.coeff i * (cycCount s (m + i) : ℤ) = 0 := by
  have h := charpoly_trace_recurrence (adjMatZ s) (m + 1)
  rw [show s + 1 + 1 = s + 2 from rfl] at h
  rw [← h]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [cycCount_eq, show m + i + 1 = m + 1 + i from by omega]

/-- **Shared characteristic recurrence, open class.**  The open adjacent-sum counts
satisfy the *same* order-`s+2` linear recurrence. -/
theorem openCount_recurrence (s m : ℕ) :
    ∑ i ∈ Finset.range (s + 2), (adjMatZ s).charpoly.coeff i * (openCount s (m + i) : ℤ) = 0 := by
  have key : ∀ i ∈ Finset.range (s + 2),
      (adjMatZ s).charpoly.coeff i * (openCount s (m + i) : ℤ)
        = ∑ a, ∑ b, (adjMatZ s).charpoly.coeff i * ((adjMatZ s) ^ (m + i)) a b := by
    intro i _
    rw [openCount_eq, Finset.mul_sum]
    exact Finset.sum_congr rfl (fun a _ => by rw [Finset.mul_sum])
  rw [Finset.sum_congr rfl key, Finset.sum_comm]
  refine Finset.sum_eq_zero (fun a _ => ?_)
  rw [Finset.sum_comm]
  refine Finset.sum_eq_zero (fun b _ => ?_)
  exact charpoly_entry_recurrence (adjMatZ s) m a b

/-! ## The shared denominator of the two Ehrhart-type series -/

/-- The reciprocal characteristic polynomial `det (I − X · adjMat s)` of the transfer
matrix, as a formal power series: the common denominator of both parity classes. -/
noncomputable def charDenom (s : ℕ) : PowerSeries ℤ :=
  revDenom (s + 1) (fun i => (adjMatZ s).charpoly.coeff i)

/-- Generating function of the open adjacent-sum counts. -/
noncomputable def openSeries (s : ℕ) : PowerSeries ℤ :=
  PowerSeries.mk fun d => (openCount s d : ℤ)

/-- Generating function of the cyclic adjacent-sum counts. -/
noncomputable def cycSeries (s : ℕ) : PowerSeries ℤ :=
  PowerSeries.mk fun d => (cycCount s d : ℤ)

theorem openSeries_mul_charDenom_coeff (s m : ℕ) (hm : s + 1 ≤ m) :
    PowerSeries.coeff m (openSeries s * charDenom s) = 0 :=
  coeff_mul_revDenom (s + 1) _ _ (openCount_recurrence s) m hm

theorem cycSeries_mul_charDenom_coeff (s m : ℕ) (hm : s + 1 ≤ m) :
    PowerSeries.coeff m (cycSeries s * charDenom s) = 0 :=
  coeff_mul_revDenom (s + 1) _ _ (cycCount_recurrence s) m hm

/-- **Shared denominator, open class.**  `openSeries s · charDenom s` is a polynomial of
degree at most `s`. -/
theorem openSeries_mul_charDenom_isPoly (s : ℕ) :
    ∃ p : Polynomial ℤ, p.natDegree ≤ s ∧
      openSeries s * charDenom s = (p : PowerSeries ℤ) := by
  refine ⟨PowerSeries.trunc (s + 1) (openSeries s * charDenom s), ?_, ?_⟩
  · exact Nat.lt_succ_iff.mp (PowerSeries.natDegree_trunc_lt _ s)
  · exact eq_coe_trunc_of_coeff_eq_zero (s + 1) _ (openSeries_mul_charDenom_coeff s)

/-- **Shared denominator, cyclic class.**  `cycSeries s · charDenom s` is a polynomial of
degree at most `s`; in particular the two Ehrhart-type series of the two parity classes
have the *same* denominator `charDenom s`. -/
theorem cycSeries_mul_charDenom_isPoly (s : ℕ) :
    ∃ p : Polynomial ℤ, p.natDegree ≤ s ∧
      cycSeries s * charDenom s = (p : PowerSeries ℤ) := by
  refine ⟨PowerSeries.trunc (s + 1) (cycSeries s * charDenom s), ?_, ?_⟩
  · exact Nat.lt_succ_iff.mp (PowerSeries.natDegree_trunc_lt _ s)
  · exact eq_coe_trunc_of_coeff_eq_zero (s + 1) _ (cycSeries_mul_charDenom_coeff s)

/-! ## The two-state Jacobi derivative identity -/

/-- Cayley–Hamilton for `2 × 2` matrices, proved entrywise (no `Nontrivial` needed). -/
theorem sq_eq_trace_smul_sub_det_smul {R : Type*} [CommRing R] (M : Matrix (Fin 2) (Fin 2) R) :
    M ^ 2 = M.trace • M - M.det • (1 : Matrix (Fin 2) (Fin 2) R) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pow_two, Matrix.mul_apply, Matrix.trace, Matrix.diag, Matrix.det_fin_two,
      Fin.sum_univ_two] <;> ring

/-- The trace sequence of a `2 × 2` matrix obeys the second-order recurrence
`tₙ₊₂ = (tr M) tₙ₊₁ − (det M) tₙ`. -/
theorem trace_pow_rec {R : Type*} [CommRing R] (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    Matrix.trace (M ^ (n + 2)) =
      M.trace * Matrix.trace (M ^ (n + 1)) - M.det * Matrix.trace (M ^ n) := by
  have h : M ^ (n + 2) = M.trace • M ^ (n + 1) - M.det • M ^ n := by
    have h2 : M ^ (n + 2) = M ^ n * M ^ 2 := by rw [← pow_add]
    rw [h2, sq_eq_trace_smul_sub_det_smul, Matrix.mul_sub, Matrix.mul_smul, Matrix.mul_smul,
      mul_one, ← pow_succ]
  rw [h, Matrix.trace_sub, Matrix.trace_smul, Matrix.trace_smul, smul_eq_mul, smul_eq_mul]

/-- **Jacobi derivative identity, two-state case.**  With `p(X) = det(I − XM) =
1 − (tr M)X + (det M)X²`, the trace generating function satisfies
`(∑ₙ tr(Mⁿ)Xⁿ) · p(X) = 2 − (tr M)X = 2·p(X) − X·p′(X)`. -/
theorem jacobi_two_state {R : Type*} [CommRing R] (M : Matrix (Fin 2) (Fin 2) R) :
    (PowerSeries.mk fun n => Matrix.trace (M ^ n)) *
        (1 - PowerSeries.C M.trace * PowerSeries.X
              + PowerSeries.C M.det * PowerSeries.X ^ 2)
      = PowerSeries.C 2 - PowerSeries.C M.trace * PowerSeries.X := by
  set A : PowerSeries R := PowerSeries.mk fun n => Matrix.trace (M ^ n) with hA
  have expand : A * (1 - PowerSeries.C M.trace * PowerSeries.X
        + PowerSeries.C M.det * PowerSeries.X ^ 2)
      = A - PowerSeries.C M.trace * (A * PowerSeries.X ^ 1)
          + PowerSeries.C M.det * (A * PowerSeries.X ^ 2) := by
    rw [pow_one]; ring
  rw [expand]
  ext n
  rw [map_add, map_sub, PowerSeries.coeff_C_mul, PowerSeries.coeff_C_mul,
    PowerSeries.coeff_mul_X_pow', PowerSeries.coeff_mul_X_pow', hA]
  match n with
  | 0 => simp [Matrix.trace_one]
  | 1 => simp [Matrix.trace_one, pow_one]; ring
  | (n + 2) =>
      rw [if_pos (by omega), if_pos (by omega)]
      simp only [PowerSeries.coeff_mk, map_sub, PowerSeries.coeff_C_mul]
      have h1 : n + 2 - 1 = n + 1 := by omega
      have h2 : n + 2 - 2 = n := by omega
      rw [h1, h2, trace_pow_rec M n]
      simp [PowerSeries.coeff_X]

/-- The two-state instance of the model: `adjMat 1 = !![1,1;1,0]` has trace `1` and
determinant `-1`, so the cyclic generating function is `(2 − X)/(1 − X − X²)`: the
Lucas numbers. -/
theorem jacobi_adjMat_one :
    (PowerSeries.mk fun n => Matrix.trace ((adjMatZ 1) ^ n)) *
        (1 - PowerSeries.X - PowerSeries.X ^ 2)
      = PowerSeries.C 2 - PowerSeries.X := by
  have htr : (adjMatZ 1).trace = 1 := by
    rw [Matrix.trace_fin_two]
    norm_num [adjMatZ]
  have hdet : (adjMatZ 1).det = -1 := by
    simp [adjMatZ, Matrix.det_fin_two]
  have h := jacobi_two_state (adjMatZ 1)
  rw [htr, hdet] at h
  simpa [map_one, sub_eq_add_neg, map_neg] using h

end AdjSum