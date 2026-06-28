import Mathlib

/-!
# Formal Verification of the (Number-Theoretic) Discrete Fourier Transform

This file verifies the algebraic heart of the Fast Fourier Transform / Number
Theoretic Transform: the **discrete Fourier transform is invertible**, with the
inverse given by the conjugate transform scaled by `1/n`.

Everything is stated over an arbitrary field `F` carrying a primitive `n`-th root
of unity `ω` with `n` invertible.  Taking `F = ZMod p` recovers the *Number
Theoretic Transform*; taking `F = ℂ` recovers the classical DFT.  The FFT is an
`O(n log n)` *evaluation strategy* for the very same linear map `DFT`, so the
correctness of FFT reduces to the inversion theorem proved here.

Main results:

* `geom_root_sum` — a geometric-series vanishing lemma in a domain.
* `root_orthogonality` — orthogonality of the DFT characters:
  `∑_{j<n} ω^{a j} (ω⁻¹)^{b j} = n·[a = b]` for `a, b < n`.
* `idft_dft` — **inversion**: `IDFT (DFT v) = v`.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): `IDFT ∘ DFT = id` holds over *any* field with a
  primitive `n`-th root of unity and `n` invertible — not just `ℂ`.  The same
  proof should specialise to `ZMod p` (the NTT), so the "number theoretic" and
  "analytic" Fourier transforms share one verification.
* Experiment (Experimenter): The crux is the character orthogonality
  `∑_{j<n} (ω^a (ω⁻¹)^b)^j = n·[a=b]`.  We reduced this to a single geometric
  series `∑_{j<n} x^j` with `x = ω^a (ω⁻¹)^b`: when `a=b`, `x = 1` and the sum is
  `n`; when `a≠b` (with `a,b<n`), `x ≠ 1` but `x^n = 1`, so `geom_sum_mul` gives
  `(x-1)·(∑ x^j) = x^n - 1 = 0`, and the domain (field) forces the sum to be `0`.
* Analysis (Analyst): The decisive facts are (i) `ω ≠ 0` (so `ω ω⁻¹ = 1`),
  (ii) injectivity of `k ↦ ω^k` on `range n` (`IsPrimitiveRoot.pow_inj`), which
  turns `a ≠ b` into `ω^a ≠ ω^b` hence `x ≠ 1`.  "True, and the field/domain
  hypothesis is essential": over a non-domain the cancellation `x ≠ 1 ⇒ sum = 0`
  fails, which is exactly why FFT needs a field (or a ring with `n` and the
  relevant differences invertible).
* Critique (Critic): we require `0 < n` and `(n : F) ≠ 0`; both are genuine —
  without invertibility of `n` the `1/n` normalisation is meaningless and the
  map is not invertible (e.g. char `p ∣ n`).  The inner double sum is reorganised
  with `Finset.sum_comm`; the `a=b` collapse uses `Finset.sum_ite_eq`.
* Synthesis (PI): `root_orthogonality` + `Finset.sum_comm` give `idft_dft`,
  uniformly over `ℂ` and `ZMod p`.
-/

namespace FourierTransformInversion

open Finset

variable {F : Type*} [Field F] {n : ℕ} {ω : F}

/-
Geometric-series vanishing: in a field, if `x^n = 1` but `x ≠ 1`, then the
truncated geometric sum `∑_{j<n} x^j` vanishes.
-/
lemma geom_root_sum (x : F) (hxn : x ^ n = 1) (hx : x ≠ 1) :
    ∑ j ∈ range n, x ^ j = 0 := by
  rw [ geom_sum_eq ] <;> aesop

/-
**Orthogonality of DFT characters.** For a primitive `n`-th root of unity `ω`
and `a, b < n`, the character inner product is `n` on the diagonal and `0` off it.
-/
lemma root_orthogonality (hω : IsPrimitiveRoot ω n) (hn : 0 < n)
    {a b : ℕ} (ha : a < n) (hb : b < n) :
    ∑ j ∈ range n, ω ^ (a * j) * (ω⁻¹) ^ (b * j) = if a = b then (n : F) else 0 := by
  by_cases hab : a = b <;> simp_all +decide [ pow_mul', ← mul_pow ];
  · rw [ Finset.sum_congr rfl fun _ _ => mul_inv_cancel₀ <| pow_ne_zero _ <| pow_ne_zero _ <| hω.ne_zero hn.ne' ] ; simp +decide;
  · convert geom_root_sum ( ω ^ a * ( ω ^ b ) ⁻¹ ) _ _ using 2 <;> simp_all +decide [ ← pow_mul, mul_pow ];
    · ring;
    · simp +decide [ pow_mul', hω.pow_eq_one ];
    · exact fun h => hab ( hω.pow_inj ha hb <| by rw [ mul_inv_eq_iff_eq_mul₀ ( pow_ne_zero _ <| hω.ne_zero hn.ne' ) ] at h; aesop )

/-- The discrete Fourier transform of `v : Fin n → F` with kernel `ω`. -/
noncomputable def DFT (ω : F) (v : Fin n → F) : Fin n → F :=
  fun j => ∑ i : Fin n, v i * ω ^ (i.val * j.val)

/-- The (un-normalised by `1/n`) inverse transform using the conjugate kernel `ω⁻¹`,
scaled by `(n : F)⁻¹`. -/
noncomputable def IDFT (ω : F) (w : Fin n → F) : Fin n → F :=
  fun i => (n : F)⁻¹ * ∑ j : Fin n, w j * (ω⁻¹) ^ (i.val * j.val)

/-
**Inversion of the discrete Fourier transform.** Over any field with a
primitive `n`-th root of unity `ω` and `n` invertible, `IDFT (DFT v) = v`.
Specialises to the classical DFT (`F = ℂ`) and the Number Theoretic Transform
(`F = ZMod p`).
-/
theorem idft_dft (hω : IsPrimitiveRoot ω n) (hn : 0 < n) (hchar : (n : F) ≠ 0)
    (v : Fin n → F) : IDFT ω (DFT ω v) = v := by
  -- Apply the orthogonality lemma to simplify the inner sum.
  have h_inner : ∀ i : Fin n, ∑ j : Fin n, (∑ i' : Fin n, v i' * ω ^ (i'.val * j.val)) * (ω⁻¹) ^ (i.val * j.val) = n * v i := by
    intro i
    have h_inner : ∑ j : Fin n, (∑ i' : Fin n, v i' * ω ^ (i'.val * j.val)) * (ω⁻¹) ^ (i.val * j.val) = ∑ i' : Fin n, v i' * ∑ j : Fin n, ω ^ (i'.val * j.val) * (ω⁻¹) ^ (i.val * j.val) := by
      simp +decide only [sum_mul, Finset.mul_sum _ _ _];
      exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
    have h_inner : ∀ i' : Fin n, ∑ j : Fin n, ω ^ (i'.val * j.val) * (ω⁻¹) ^ (i.val * j.val) = if i'.val = i.val then (n : F) else 0 := by
      intro i'
      have := root_orthogonality hω hn (Fin.is_lt i') (Fin.is_lt i)
      simp_all +decide [ Finset.sum_range ];
    simp_all +decide [ Fin.val_inj, mul_comm ];
  ext i; simp_all +decide [ IDFT, DFT ] ;

end FourierTransformInversion