import Mathlib

/-!
# Matrix Reduction Modulo a Prime

We define entrywise reduction of integer matrices modulo `p` and prove
that it preserves multiplication, powers, determinant, and trace.

This is the foundational layer for the SPB Diffie–Hellman reduction:
it transports integral Berggren matrices into `SL₂(𝔽_p)` where
discrete-log hardness can be stated.
-/

open Matrix

/-! ## Definition of `matRed` -/

/-- Entrywise reduction of an integer matrix modulo `p`, defined as the
canonical ring homomorphism `ℤ →+* ZMod p` lifted to matrices.
Since it is a ring homomorphism on matrices, it automatically preserves
multiplication and the identity. -/
noncomputable def matRed (p : ℕ) : Matrix (Fin 2) (Fin 2) ℤ →+* Matrix (Fin 2) (Fin 2) (ZMod p) :=
  (Int.castRingHom (ZMod p)).mapMatrix

/-! ## Multiplicativity -/

/-- `matRed` preserves matrix multiplication. -/
theorem matRed_mul {p : ℕ} (M N : Matrix (Fin 2) (Fin 2) ℤ) :
    matRed p (M * N) = matRed p M * matRed p N :=
  map_mul (matRed p) M N

/-- `matRed` preserves matrix powers. -/
theorem matRed_pow {p : ℕ} (M : Matrix (Fin 2) (Fin 2) ℤ) (n : ℕ) :
    matRed p (M ^ n) = (matRed p M) ^ n :=
  map_pow (matRed p) M n

/-- `matRed` preserves the identity matrix. -/
theorem matRed_one {p : ℕ} : matRed p 1 = 1 :=
  map_one (matRed p)

/-! ## Determinant preservation -/

/-- Determinant commutes with `matRed`: `det (matRed p M) = (det M : ZMod p)`. -/
theorem det_matRed_eq {p : ℕ} (M : Matrix (Fin 2) (Fin 2) ℤ) :
    (matRed p M).det = ((M.det : ℤ) : ZMod p) := by
  rw [matRed, ← RingHom.map_det]; rfl

/-- If `det M = 1` over `ℤ`, then `det (matRed p M) = 1` over `ZMod p`.
This means the reduced matrix lies in `SL₂(ZMod p)`. -/
theorem det_matRed {p : ℕ} [Fact p.Prime]
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1) :
    (matRed p g).det = 1 := by
  rw [det_matRed_eq, hdet, Int.cast_one]

/-! ## Trace preservation -/

/-- Trace commutes with `matRed`. -/
theorem trace_matRed {p : ℕ}
    (M : Matrix (Fin 2) (Fin 2) ℤ) :
    Matrix.trace (matRed p M) = ((Matrix.trace M : ℤ) : ZMod p) := by
  simp only [Matrix.trace, matRed, RingHom.mapMatrix_apply, Matrix.diag,
    Matrix.map_apply]
  simp