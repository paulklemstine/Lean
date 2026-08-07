import Mathlib
import Novelty.SYZMonodromyDuality

/-!
# Arithmetic Mirror Symmetry VII — T-duality is inner only in rank one

This file closes **Conjecture C** of the previous cycle's `FUTURE_DIRECTIONS.md`, and
sharpens it.  Cycle 1 proved that fiberwise SYZ T-duality `M ↦ (M⁻¹)ᵀ` is an involutive
automorphism of the integral monodromy group `GL_n(ℤ)`, that it is realized by conjugation
with the symplectic matrix on `SL₂(ℤ)` (`Novelty.MirrorBridge.sl2_dual_conj`), and that it
is **not** inner in rank three (`dualMon_not_inner_rank_three`).  Conjecture C asked for the
uniform statement in every rank `n ≥ 3`.

The uniform statement is proved here, and the answer turns out to be sharper than
conjectured: on the *full* monodromy group `GL_n(ℤ)` dualization is not inner for **every**
`n ≥ 2`.  The rank-two positive result is therefore genuinely a statement about `SL₂(ℤ)`:
the determinant hypothesis in `sl2_dual_conj` cannot be dropped, because for `det M = −1`
one gets `(M⁻¹)ᵀ = −J M J⁻¹`.  Only in rank one is dualization inner, and there it is the
identity.

## Main results

* `dualMon_not_inner_of_trace_ne` — the general obstruction: a single monodromy matrix with
  `tr M⁻¹ ≠ tr M` shows dualization is not inner, because conjugation and transposition both
  preserve the trace.
* `embedBlock`, `embedBlock_mul`, `embedBlock_trace`, `embedBlock_det` — stabilization of a
  monodromy matrix by an identity block, transported to `Fin (r + k)` by `reindex`.
* `dualMon_not_inner_rank_ge_three` — **Conjecture C**: for every `n ≥ 3` dualization is not
  an inner automorphism of `GL_n(ℤ)`, witnessed by a matrix of determinant `1` (so it is not
  inner on `SL_n(ℤ)` either).
* `dualMon_not_inner_rank_ge_two` — the sharpening: for every `n ≥ 2` dualization is not
  inner on `GL_n(ℤ)`, witnessed by the hyperbolic matrix `[[2,1],[1,0]]` of determinant `−1`.
* `sl2_dual_conj_fails_for_det_neg_one` — the determinant hypothesis of `sl2_dual_conj` is
  necessary: for `det M = −1` one has `(M⁻¹)ᵀ = −(J M J⁻¹)`, and the two differ.
* `dualMon_rank_one` / `dualMon_inner_rank_one` — in rank one dualization is the identity.
* `dualMon_inner_iff_rank_le_one` — the resulting **dichotomy**: dualization is an inner
  automorphism of `GL_n(ℤ)` if and only if `n ≤ 1`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cycle 1 suggested "inner exactly for `n ≤ 2`".  The
  trace obstruction `tr M ≠ tr M⁻¹`, which killed rank three, should stabilize: padding a
  witness by an identity block adds the same constant `k` to both traces, so the difference
  is preserved in every larger rank.
* **Experiment (Experimenter).**  Implemented padding as
  `reindex finSumFinEquiv finSumFinEquiv (fromBlocks A 0 0 1)`; multiplicativity comes from
  `Matrix.reindexAlgEquiv` and `Matrix.fromBlocks_multiply`, the trace from
  `Fintype.sum_sum_type`, and the determinant from `Matrix.det_fromBlocks_zero₁₂`.  Running
  the padding on the rank-three companion matrix of `x³ − 2x² + x − 1` gives traces
  `2 + k` and `1 + k`, closing every rank `n ≥ 3` at once.
* **Analysis (Analyst).**  Testing the same obstruction in rank two produced a surprise:
  `[[2,1],[1,0]]` has `tr = 2` and `tr⁻¹ = −2`, so dualization is not inner on `GL₂(ℤ)`
  either.  The rank-two positive result is thus *not* a rank phenomenon but a
  **determinant** phenomenon — the symplectic conjugation computes `(M⁻¹)ᵀ` only up to the
  factor `det M`.  Conjecture C was therefore true but stated one rank too weakly.
* **Critique (Critic).**  Every statement below is a genuine inequality of integers or an
  explicit matrix identity; no `decide`, no `native_decide`.  The rank-one positive result
  is not vacuous: it produces the explicit conjugator `1` and uses the fact that the only
  units of `ℤ` are `±1`.  The dichotomy `dualMon_inner_iff_rank_le_one` covers `n = 0`
  as well (the trivial group).
* **Synthesis (PI).**  On the full integral monodromy group, T-duality is an outer
  automorphism in every rank `≥ 2`; a rank-`n` integral SYZ local system with full monodromy
  is therefore isomorphic to its T-dual only in rank `≤ 1`, and the rank-two "self-duality"
  of elliptic fibrations is exactly the orientation-preserving (`SL₂`) part of the story.
-/

namespace Novelty.MirrorBridge

open Matrix

section Obstruction

variable {n : ℕ}

/-- **The trace obstruction to innerness.**  If some monodromy matrix `M` with two-sided
inverse `N` has `tr N ≠ tr M`, then no single change of basis can realize fiberwise
T-duality: conjugation preserves the trace, and so does transposition, while
`tr (M⁻¹)ᵀ = tr N`. -/
theorem dual_not_inner_of_trace_ne (M N : Matrix (Fin n) (Fin n) ℤ)
    (htr : N.trace ≠ M.trace) (S T : Matrix (Fin n) (Fin n) ℤ) (hST : S * T = 1) :
    Nᵀ ≠ S * M * T := by
  intro h
  have htr' : Nᵀ.trace = (S * M * T).trace := by rw [h]
  rw [Matrix.trace_transpose] at htr'
  have hcyc : (S * M * T).trace = (T * (S * M)).trace := Matrix.trace_mul_comm _ _
  rw [hcyc, ← Matrix.mul_assoc, mul_eq_one_comm.mp hST, Matrix.one_mul] at htr'
  exact htr htr'

/-- Group-level form of the trace obstruction: dualization is not an inner automorphism of
`GL_n(ℤ)` as soon as some unit has `tr M⁻¹ ≠ tr M`. -/
theorem dualMon_not_inner_of_trace_ne (M N : Matrix (Fin n) (Fin n) ℤ) (hMN : M * N = 1)
    (hNM : N * M = 1) (htr : N.trace ≠ M.trace) :
    ¬ ∃ S : IntGL n, ∀ U : IntGL n, dualMon U = S * U * S⁻¹ := by
  rintro ⟨S, hS⟩
  let W : IntGL n := ⟨M, N, hMN, hNM⟩
  have h := congrArg (fun U : IntGL n => (U : Matrix (Fin n) (Fin n) ℤ)) (hS W)
  simp only [dualMon_coe, Units.val_mul] at h
  exact dual_not_inner_of_trace_ne M N htr (↑S) (↑S⁻¹) (by simp) h

end Obstruction

section Stabilization

/-! ### Padding a monodromy matrix by an identity block

A rank-`r` witness is turned into a rank-`(r + k)` witness by acting trivially on `k`
further lattice directions.  Both the trace and the determinant behave transparently. -/

variable {r k : ℕ}

/-- Stabilize an `r × r` monodromy matrix to size `r + k` by an identity block. -/
def embedBlock (r k : ℕ) (A : Matrix (Fin r) (Fin r) ℤ) : Matrix (Fin (r + k)) (Fin (r + k)) ℤ :=
  Matrix.reindex finSumFinEquiv finSumFinEquiv (Matrix.fromBlocks A 0 0 1)

theorem reindex_sum_trace (A : Matrix (Fin r ⊕ Fin k) (Fin r ⊕ Fin k) ℤ) :
    (Matrix.reindex finSumFinEquiv finSumFinEquiv A).trace = A.trace :=
  (Fintype.sum_equiv (finSumFinEquiv (m := r) (n := k)) (fun j => A.diag j)
    (fun i => (Matrix.reindex finSumFinEquiv finSumFinEquiv A).diag i) (fun _ => by simp)).symm

theorem reindex_sum_mul (A B : Matrix (Fin r ⊕ Fin k) (Fin r ⊕ Fin k) ℤ) :
    Matrix.reindex finSumFinEquiv finSumFinEquiv (A * B)
      = Matrix.reindex finSumFinEquiv finSumFinEquiv A
        * Matrix.reindex finSumFinEquiv finSumFinEquiv B :=
  (Matrix.reindexAlgEquiv ℤ ℤ (finSumFinEquiv (m := r) (n := k))).map_mul A B

/-- Padding is multiplicative, so it sends monodromy relations to monodromy relations. -/
theorem embedBlock_mul (A B : Matrix (Fin r) (Fin r) ℤ) (hAB : A * B = 1) :
    embedBlock r k A * embedBlock r k B = 1 := by
  rw [embedBlock, embedBlock, ← reindex_sum_mul, Matrix.fromBlocks_multiply]
  simp [hAB, Matrix.fromBlocks_one]

/-- Padding adds `k` to the trace. -/
theorem embedBlock_trace (A : Matrix (Fin r) (Fin r) ℤ) :
    (embedBlock r k A).trace = A.trace + k := by
  rw [embedBlock, reindex_sum_trace]
  simp [Matrix.trace, Matrix.diag, Fintype.sum_sum_type]

/-- Padding preserves the determinant, so it maps `SL_r(ℤ)` into `SL_{r+k}(ℤ)`. -/
theorem embedBlock_det (A : Matrix (Fin r) (Fin r) ℤ) :
    (embedBlock r k A).det = A.det := by
  rw [embedBlock, Matrix.det_reindex_self, Matrix.det_fromBlocks_zero₁₂]
  simp

end Stabilization

section RankGeThree

/-- The rank-`n` stabilization (`n = 3 + k`) of the companion matrix of `x³ − 2x² + x − 1`. -/
def gl3Stab (k : ℕ) : Matrix (Fin (3 + k)) (Fin (3 + k)) ℤ := embedBlock 3 k gl3Example

/-- Its inverse. -/
def gl3StabInv (k : ℕ) : Matrix (Fin (3 + k)) (Fin (3 + k)) ℤ := embedBlock 3 k gl3ExampleInv

theorem gl3Stab_mul_inv (k : ℕ) : gl3Stab k * gl3StabInv k = 1 :=
  embedBlock_mul _ _ gl3Example_mul_inv

theorem gl3StabInv_mul (k : ℕ) : gl3StabInv k * gl3Stab k = 1 :=
  embedBlock_mul _ _ gl3ExampleInv_mul

theorem gl3Stab_trace (k : ℕ) : (gl3Stab k).trace = 2 + k := by
  rw [gl3Stab, embedBlock_trace, gl3Example_trace]

theorem gl3StabInv_trace (k : ℕ) : (gl3StabInv k).trace = 1 + k := by
  rw [gl3StabInv, embedBlock_trace, gl3ExampleInv_trace]

/-- The stabilized witness has determinant `1`, i.e. it lies in `SL_{3+k}(ℤ)`. -/
theorem gl3Stab_det (k : ℕ) : (gl3Stab k).det = 1 := by
  rw [gl3Stab, embedBlock_det, gl3Example, Matrix.det_fin_three]
  simp

/-- **Conjecture C, closed.**  For every rank `n ≥ 3` fiberwise SYZ T-duality
`M ↦ (M⁻¹)ᵀ` is *not* an inner automorphism of the integral monodromy group `GL_n(ℤ)`.
The witness `gl3Stab` has determinant `1`, so dualization is not inner on `SL_n(ℤ)` either:
a rank-`n` integral SYZ local system with full monodromy is not isomorphic to its T-dual. -/
theorem dualMon_not_inner_rank_ge_three (n : ℕ) (hn : 3 ≤ n) :
    ¬ ∃ S : IntGL n, ∀ M : IntGL n, dualMon M = S * M * S⁻¹ := by
  obtain ⟨k, rfl⟩ : ∃ k, n = 3 + k := ⟨n - 3, by omega⟩
  refine dualMon_not_inner_of_trace_ne (gl3Stab k) (gl3StabInv k) (gl3Stab_mul_inv k)
    (gl3StabInv_mul k) ?_
  rw [gl3Stab_trace, gl3StabInv_trace]
  omega

end RankGeThree

section RankGeTwo

/-! ### Rank two: dualization is inner on `SL₂(ℤ)` but not on `GL₂(ℤ)`

The symplectic conjugation of `sl2_dual_conj` computes the adjugate transpose, which equals
`(M⁻¹)ᵀ` only after dividing by `det M`.  For `det M = −1` the two differ by a sign, and the
trace obstruction detects this. -/

/-- The hyperbolic monodromy `[[2,1],[1,0]]`, of determinant `−1`. -/
def gl2Hyper : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Its inverse `[[0,1],[1,−2]]`. -/
def gl2HyperInv : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, -2]

theorem gl2Hyper_det : gl2Hyper.det = -1 := by
  rw [gl2Hyper, Matrix.det_fin_two_of]; ring

theorem gl2Hyper_mul_inv : gl2Hyper * gl2HyperInv = 1 := by
  rw [gl2Hyper, gl2HyperInv, Matrix.mul_fin_two]
  ext i j
  fin_cases i <;> fin_cases j <;> simp

theorem gl2HyperInv_mul : gl2HyperInv * gl2Hyper = 1 := by
  rw [gl2Hyper, gl2HyperInv, Matrix.mul_fin_two]
  ext i j
  fin_cases i <;> fin_cases j <;> simp

theorem gl2Hyper_trace : gl2Hyper.trace = 2 := by
  rw [gl2Hyper, Matrix.trace_fin_two_of]; norm_num

theorem gl2HyperInv_trace : gl2HyperInv.trace = -2 := by
  rw [gl2HyperInv, Matrix.trace_fin_two_of]; norm_num

/-- The stabilized rank-`(2+k)` hyperbolic witness. -/
def gl2Stab (k : ℕ) : Matrix (Fin (2 + k)) (Fin (2 + k)) ℤ := embedBlock 2 k gl2Hyper

/-- Its inverse. -/
def gl2StabInv (k : ℕ) : Matrix (Fin (2 + k)) (Fin (2 + k)) ℤ := embedBlock 2 k gl2HyperInv

theorem gl2Stab_mul_inv (k : ℕ) : gl2Stab k * gl2StabInv k = 1 :=
  embedBlock_mul _ _ gl2Hyper_mul_inv

theorem gl2StabInv_mul (k : ℕ) : gl2StabInv k * gl2Stab k = 1 :=
  embedBlock_mul _ _ gl2HyperInv_mul

/-- **Sharpening of Conjecture C.**  On the *full* integral monodromy group dualization is
already non-inner in rank two, hence in every rank `n ≥ 2`.  The witness has determinant
`−1`, which is exactly the case excluded by the hypothesis of `sl2_dual_conj`. -/
theorem dualMon_not_inner_rank_ge_two (n : ℕ) (hn : 2 ≤ n) :
    ¬ ∃ S : IntGL n, ∀ M : IntGL n, dualMon M = S * M * S⁻¹ := by
  obtain ⟨k, rfl⟩ : ∃ k, n = 2 + k := ⟨n - 2, by omega⟩
  refine dualMon_not_inner_of_trace_ne (gl2Stab k) (gl2StabInv k) (gl2Stab_mul_inv k)
    (gl2StabInv_mul k) ?_
  rw [gl2Stab, gl2StabInv, embedBlock_trace, embedBlock_trace, gl2Hyper_trace,
    gl2HyperInv_trace]
  omega

/-- **The determinant hypothesis of `sl2_dual_conj` is necessary.**  For the determinant
`−1` matrix `gl2Hyper`, the symplectic conjugate computes `(M⁻¹)ᵀ` only up to sign:
`(M⁻¹)ᵀ = −(J M J⁻¹)`, and the two sides genuinely differ. -/
theorem sl2_dual_conj_fails_for_det_neg_one :
    gl2HyperInvᵀ = -(symplJ * gl2Hyper * symplJinv) ∧
      gl2HyperInvᵀ ≠ symplJ * gl2Hyper * symplJinv := by
  constructor
  · rw [gl2Hyper, gl2HyperInv, symplJ, symplJinv, Matrix.mul_fin_two, Matrix.mul_fin_two]
    ext i j
    fin_cases i <;> fin_cases j <;> simp
  · intro h
    have h01 : gl2HyperInvᵀ 0 1 = (symplJ * gl2Hyper * symplJinv) 0 1 := by rw [h]
    rw [gl2HyperInv, gl2Hyper, symplJ, symplJinv, Matrix.mul_fin_two, Matrix.mul_fin_two] at h01
    norm_num at h01

end RankGeTwo

section RankOne

/-- **Rank one: dualization is the identity.**  A `1 × 1` integral monodromy matrix has
entry `±1`, so it is its own inverse and its own transpose. -/
theorem dualMon_rank_one (M : IntGL 1) : dualMon M = M := by
  have hmul : (↑M : Matrix (Fin 1) (Fin 1) ℤ) 0 0 * (↑M⁻¹ : Matrix (Fin 1) (Fin 1) ℤ) 0 0 = 1 := by
    have h : (↑M : Matrix (Fin 1) (Fin 1) ℤ) * (↑M⁻¹ : Matrix (Fin 1) (Fin 1) ℤ) = 1 :=
      Units.mul_inv M
    have := congrArg (fun A : Matrix (Fin 1) (Fin 1) ℤ => A 0 0) h
    simpa [Matrix.mul_apply] using this
  have hinv : (↑M⁻¹ : Matrix (Fin 1) (Fin 1) ℤ) 0 0 = (↑M : Matrix (Fin 1) (Fin 1) ℤ) 0 0 := by
    rcases Int.eq_one_or_neg_one_of_mul_eq_one' hmul with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2]
  ext i j
  fin_cases i
  fin_cases j
  simpa using hinv

/-- In rank one dualization is (trivially) inner: the identity conjugator works. -/
theorem dualMon_inner_rank_one : ∃ S : IntGL 1, ∀ M : IntGL 1, dualMon M = S * M * S⁻¹ :=
  ⟨1, fun M => by simp [dualMon_rank_one M]⟩

/-- In rank zero there is nothing to do. -/
theorem dualMon_inner_rank_zero : ∃ S : IntGL 0, ∀ M : IntGL 0, dualMon M = S * M * S⁻¹ :=
  ⟨1, fun M => by
    ext i
    exact absurd i.isLt (by omega)⟩

end RankOne

/-- **Dichotomy for integral SYZ T-duality.**  Fiberwise dualization `M ↦ (M⁻¹)ᵀ` is an
inner automorphism of the integral monodromy group `GL_n(ℤ)` **iff** `n ≤ 1`.  Conjecture C
asked for non-innerness in ranks `≥ 3`; the true boundary is one rank lower, because the
rank-two self-duality `sl2_dual_conj` is an `SL₂`, not a `GL₂`, phenomenon. -/
theorem dualMon_inner_iff_rank_le_one (n : ℕ) :
    (∃ S : IntGL n, ∀ M : IntGL n, dualMon M = S * M * S⁻¹) ↔ n ≤ 1 := by
  constructor
  · intro h
    by_contra hn
    exact dualMon_not_inner_rank_ge_two n (by omega) h
  · intro hn
    interval_cases n
    · exact dualMon_inner_rank_zero
    · exact dualMon_inner_rank_one

end Novelty.MirrorBridge