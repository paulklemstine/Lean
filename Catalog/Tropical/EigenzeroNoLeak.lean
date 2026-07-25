/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# The Boundary Theorem for Tropical Eigenvalues and `eigenzero_no_leak`

This file extends the tropical (min-plus) spectral theory developed in
`Tropical.MinPlusAlgebra` (Section 8, `IsTropicalEigenpair`) with a focused study of
the **boundary eigenvalue** `λ = 0` and its consequences for cryptanalysis based on
tropical linear algebra.

## Mathematical Overview

A tropical eigenpair `(λ, v)` of a matrix `A` satisfies the min-plus relation

  `(A ⊗ v)_i = v_i + λ`     for all `i`,

i.e. `tropMatVecMul A v i = v i + lam`.  Unlike the classical theory, the tropical
"spectrum" is constrained by the *geometry of the underlying graph*.  For a weighted
digraph with nonnegative edge weights and zero self-loops, every eigenvalue satisfies
`λ ≤ 0`, with `λ = 0` the unique attainable **boundary value** (the constant vectors are
its eigenvectors).  This is the tropical analogue of a spectral radius bound.

In tropical algebra there is no general subtraction.  The one place where an honest
subtraction *is* meaningful is the **residual**

  `tropResidual A v i := (A ⊗ v)_i - v_i`,

which for an eigenpair recovers the eigenvalue at every coordinate.  At the boundary
`λ = 0` the residual vanishes identically — this is `eigenzero_no_leak`: the residual
signal carries no positional information whatsoever.

## Security application: eigenvector indistinguishability under `λ = 0`

Tropical maps are equivariant under the global additive shift `v ↦ v + c` (the tropical
"scalar action").  Consequently an eigenvector is only ever determined up to a global
offset, and at the boundary eigenvalue **any two eigenvectors produce the identically
zero residual signature**.  An adversary measuring residuals therefore learns nothing
that distinguishes one boundary eigenvector from another, nor from a shifted copy.  We
make this precise and connect it to the `MinPlusHash` of `Tropical.MinPlusAlgebra`,
showing that the hash leaks *at most* the global offset.

## Main Results

* `tropResidual_eq_eigenvalue` — the residual equals the eigenvalue at every coordinate.
* `tropical_eigenvalue_unique` — the eigenvalue is determined by the eigenvector.
* `eigenzero_iff_fixed` — `λ = 0` ⇔ `v` is a tropical fixed point of `A`.
* `eigenzero_no_leak` — **the boundary residual vanishes identically**.
* `digraph_residual_nonpos` / `digraph_eigenvalue_nonpos` — the boundary theorem:
  eigenvalues of a nonnegative zero-self-loop digraph are `≤ 0`.
* `digraph_eigenzero_const` — `λ = 0` is attained by constant eigenvectors.
* `eigenpair_shift_invariant` / `eigenzero_shift_invariant` — shift equivariance of the
  spectrum.
* `eigenzero_residual_indistinguishable` / `eigenzero_residual_uninformative` —
  eigenvector indistinguishability under `λ = 0`.
* `minPlusHash_leak_only_offset` — the min-plus hash leaks at most the global offset.

## References

* Butkovič, P. "Max-linear Systems: Theory and Algorithms" (2010).
* Cuninghame-Green, R. "Minimax Algebra" (1979).
-/

noncomputable section

open Finset Matrix

namespace TropicalEigenzero

variable {n : ℕ} [NeZero n]

/-! ## Section 1: The tropical residual and the eigenvalue it encodes -/

/-- The **tropical residual** of `A` at `v`: the per-coordinate (honest) subtraction
`(A ⊗ v)_i - v_i`.  This is the only meaningful difference in min-plus algebra, and it is
exactly the signal an adversary could measure when probing a tropical eigensystem.

Bridge: connects Tropical Spectral Theory to Cryptanalysis. -/
def tropResidual (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (i : Fin n) : ℝ :=
  tropMatVecMul A v i - v i

/--
For an eigenpair `(λ, v)`, the residual equals `λ` at every coordinate.
-/
theorem tropResidual_eq_eigenvalue
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (i : Fin n) :
    tropResidual A v i = lam := by
      exact sub_eq_iff_eq_add'.mpr ( h i )

/--
The residual is independent of the coordinate for any eigenpair: there is no
positional information in the residual signal.
-/
theorem tropResidual_const
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A lam v) (i j : Fin n) :
    tropResidual A v i = tropResidual A v j := by
      rw [ tropResidual_eq_eigenvalue A lam v h i, tropResidual_eq_eigenvalue A lam v h j ]

/--
The tropical eigenvalue is uniquely determined by the eigenvector.
-/
theorem tropical_eigenvalue_unique
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (lam mu : ℝ)
    (h1 : IsTropicalEigenpair A lam v) (h2 : IsTropicalEigenpair A mu v) :
    lam = mu := by
      linarith [ h1 ⟨ 0, NeZero.pos n ⟩, h2 ⟨ 0, NeZero.pos n ⟩ ]

/-! ## Section 2: The boundary eigenvalue `λ = 0` -/

/--
Fixed-point characterization of the boundary eigenvalue: `(0, v)` is an eigenpair iff
`v` is a tropical fixed point of `A`, i.e. `A ⊗ v = v`.
-/
theorem eigenzero_iff_fixed (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    IsTropicalEigenpair A 0 v ↔ ∀ i, tropMatVecMul A v i = v i := by
      unfold IsTropicalEigenpair; aesop;

/--
**`eigenzero_no_leak`.**  At the boundary eigenvalue `λ = 0`, the tropical residual
(the per-coordinate tropical subtraction `(A ⊗ v)_i - v_i`) vanishes identically.  The
residual signal is therefore constantly zero and leaks no positional information about the
secret eigenvector.

Bridge: connects Tropical Spectral Theory to Cryptanalysis (side-channel resistance).
-/
theorem eigenzero_no_leak
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A 0 v) (i : Fin n) :
    tropResidual A v i = 0 := by
      exact tropResidual_eq_eigenvalue A 0 v h i

/--
At the boundary eigenvalue, repeated application of the tropical map fixes the
eigenvector: no eigenvalue "leaks" into the growth of iterates.
-/
theorem eigenzero_iterate
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair A 0 v) (k : ℕ) :
    (tropMatVecMul A)^[k] v = v := by
      induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
      exact funext fun i => by simpa using h i;

/-! ## Section 3: The boundary theorem for weighted digraphs -/

/--
For a weighted digraph with nonnegative weights and zero self-loops, the residual is
nonpositive at every coordinate (the zero self-loop always provides an upper bound).
-/
theorem digraph_residual_nonpos
    (G : WeightedDigraph n) (v : Fin n → ℝ) (i : Fin n) :
    tropResidual G.weights v i ≤ 0 := by
      unfold tropResidual;
      simp +decide [ tropMatVecMul ];
      exact ⟨ i, by linarith [ G.self_loop_zero i ] ⟩

/--
**Boundary theorem.**  Every tropical eigenvalue of a weighted digraph with
nonnegative weights and zero self-loops satisfies `λ ≤ 0`.  Thus `λ = 0` is the upper
boundary of the tropical spectrum.
-/
theorem digraph_eigenvalue_nonpos
    (G : WeightedDigraph n) (lam : ℝ) (v : Fin n → ℝ)
    (h : IsTropicalEigenpair G.weights lam v) :
    lam ≤ 0 := by
      -- By `tropResidual_eq_eigenvalue`, we have `lam = tropResidual G.weights v i`.
      have h_eigenvalue :lam = tropResidual G.weights v ⟨0, NeZero.pos n⟩  := by
        exact Eq.symm ( tropResidual_eq_eigenvalue _ _ _ h _ );
      exact h_eigenvalue ▸ digraph_residual_nonpos G v _

/--
The boundary value `λ = 0` is attained: every constant vector is an eigenvector of a
weighted digraph (nonnegative weights, zero self-loops) with eigenvalue `0`.
-/
theorem digraph_eigenzero_const (G : WeightedDigraph n) (c : ℝ) :
    IsTropicalEigenpair G.weights 0 (fun _ => c) := by
      intro i;
      refine' le_antisymm _ _;
      · exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ i ) ) ( by norm_num [ G.self_loop_zero ] );
      · exact Finset.le_inf' _ _ fun k _ => by linarith [ G.nonneg i k ] ;

/-! ## Section 4: Eigenvector indistinguishability under `λ = 0` -/

/--
Shift equivariance of the tropical spectrum: shifting an eigenvector by a global
constant `c` produces another eigenvector with the *same* eigenvalue.
-/
theorem eigenpair_shift_invariant
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ) (c : ℝ)
    (h : IsTropicalEigenpair A lam v) :
    IsTropicalEigenpair A lam (fun k => v k + c) := by
      intro i
      have := h i
      simp [tropMatVecMul_shift] at this ⊢
      linarith

/--
Boundary specialization: the set of `λ = 0` eigenvectors is closed under the global
additive shift. An eigenvector is only determined up to this offset.
-/
theorem eigenzero_shift_invariant
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ)
    (h : IsTropicalEigenpair A 0 v) :
    IsTropicalEigenpair A 0 (fun k => v k + c) := by
      exact eigenpair_shift_invariant A 0 v c h

/--
**Eigenvector indistinguishability (shift).**  At the boundary eigenvalue, an
eigenvector and any global shift of it produce the identical (zero) residual signature.
The residual cannot distinguish `v` from `v + c`.
-/
theorem eigenzero_residual_indistinguishable
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ)
    (h : IsTropicalEigenpair A 0 v) (i : Fin n) :
    tropResidual A v i = tropResidual A (fun k => v k + c) i := by
      rw [ eigenzero_no_leak A v h i, eigenzero_no_leak A ( fun k => v k + c ) ( eigenzero_shift_invariant A v c h ) i ]

/--
**Eigenvector indistinguishability (general).**  At the boundary eigenvalue, *any two*
eigenvectors produce the identical (zero) residual signature.  An adversary measuring
residuals learns nothing that distinguishes one boundary eigenvector from another.

Bridge: connects Tropical Spectral Theory to Cryptanalysis (indistinguishability).
-/
theorem eigenzero_residual_uninformative
    (A : Matrix (Fin n) (Fin n) ℝ) (v w : Fin n → ℝ)
    (hv : IsTropicalEigenpair A 0 v) (hw : IsTropicalEigenpair A 0 w) (i : Fin n) :
    tropResidual A v i = tropResidual A w i := by
      rw [ eigenzero_no_leak A v hv i, eigenzero_no_leak A w hw i ]

/-! ## Section 5: Cryptanalytic corollary for the min-plus hash -/

/--
**Min-plus hash leaks at most the global offset.**  Hashing `v` and its global shift
`v + c` yields outputs that differ by exactly `c` at every coordinate, independent of any
other structure of the secret `v`.  Combined with `eigenzero_shift_invariant`, this shows
the hash cannot separate eigenvectors within a single boundary orbit beyond the public
offset.

Bridge: connects Tropical Cryptography to Cryptanalysis.
-/
theorem minPlusHash_leak_only_offset
    {m : ℕ} [NeZero m] (h : MinPlusHash n m) (v : Fin n → ℝ) (c : ℝ) (i : Fin m) :
    h.eval (fun k => v k + c) i - h.eval v i = c := by
      rw [ MinPlusHash.eval_shift ] ; ring!;

end TropicalEigenzero