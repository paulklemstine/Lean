import Mathlib

/-!
# A spectral bridge for quantum walks on cyclic Cayley graphs

This file proves a concrete **cross-domain bridge** between three areas that at first sight
have little to do with one another:

* **Harmonic analysis / representation theory** of the finite abelian group `ZMod n`
  (its characters, the additive Fourier basis `x ↦ ζ ^ x.val` for an `n`-th root of unity `ζ`);
* **Spectral graph theory** — the eigenvalues and eigenvectors of the *Cayley graph*
  `Cay(ZMod n, S)`, encoded by its adjacency operator on `ℓ²(ZMod n) = (ZMod n → ℂ)`; and
* **Trigonometry of roots of unity** — the appearance of `2·cos(2πk/n)` as the spectrum of the
  cycle graph.

The motivating context is the theory of (quantum) random walks on Cayley graphs, where the
mixing behaviour of the walk is governed by the *spectral gap* `1 - |λ₂|` of the walk operator,
and `λ₂` is the second-largest eigenvalue of the adjacency/transition operator.  The results
below give the exact spectral data of the walk operator on any cyclic Cayley graph.

## Main statements

* `char_is_eigenvector`: every additive character `charVec ζ` is an eigenvector of the Cayley
  adjacency operator `adjacency S`, with eigenvalue `eigenvalue S ζ = ∑_{s∈S} ζ^s`.  This is
  the *diagonalisation* half of the bridge: the Fourier basis simultaneously diagonalises **all**
  circulant/convolution operators.
* `eigenvalue_perron`: at the trivial character (`ζ = 1`) the eigenvalue equals the degree `|S|`
  of the graph (the Perron–Frobenius eigenvalue).
* `norm_eigenvalue_le`: every eigenvalue has modulus at most the degree `|S|`.
* `eigenvalue_real`: if the connection set `S` is **symmetric** (`s ∈ S ↔ -s ∈ S`), then every
  eigenvalue is a *real* number.  This is the spectral-theoretic statement that a symmetric
  Cayley graph has a self-adjoint (Hermitian) adjacency operator, hence a real spectrum — the
  hypothesis under which the spectral gap `1 - |λ₂|` is meaningful.
* `cycle_eigenvalue` and `cycle_spectrum`: for the cycle graph `Cay(ZMod n, {±1})` the eigenvalue
  at the `k`-th character is exactly `ζ + ζ⁻¹`, and for the standard root of unity
  `ζ = exp(2πik/n)` this equals `2·cos(2πk/n)`.  This is the classical circulant/DFT computation,
  connecting a linear-algebra spectrum to elementary trigonometry.

Everything is proved from first principles over `ℂ`; the only substantial external inputs are the
`ZMod` arithmetic API and Euler's formula from `Mathlib`.
-/

namespace QuantumWalkSpectralBridge

open scoped BigOperators
open Complex

variable {n : ℕ} [NeZero n] {ζ : ℂ}

/-! ### Root-of-unity arithmetic -/

omit [NeZero n] in
/-- For an `n`-th root of unity `ζ`, the power `ζ ^ a` only depends on `a` modulo `n`. -/
lemma zeta_pow_mod (hζ : ζ ^ n = 1) (a : ℕ) : ζ ^ (a % n) = ζ ^ a := by
  conv_rhs => rw [← Nat.div_add_mod a n]
  rw [pow_add, pow_mul, hζ, one_pow, one_mul]

/-- The map `x ↦ ζ ^ x.val` is multiplicative in the group law of `ZMod n`
(the defining property of an additive character), whenever `ζ ^ n = 1`. -/
lemma zeta_pow_val_add (hζ : ζ ^ n = 1) (x s : ZMod n) :
    ζ ^ ((x + s).val) = ζ ^ x.val * ζ ^ s.val := by
  rw [ZMod.val_add, zeta_pow_mod hζ, pow_add]

/-- The character value at `-s` is the multiplicative inverse of the value at `s`. -/
lemma zeta_neg_val (hζ : ζ ^ n = 1) (s : ZMod n) :
    ζ ^ s.val * ζ ^ ((-s).val) = 1 := by
  rw [← zeta_pow_val_add hζ, add_neg_cancel]; simp

/-! ### The Cayley adjacency operator and its eigenvectors -/

/-- The adjacency (walk) operator of the Cayley graph `Cay(ZMod n, S)` acting on
`ℓ²(ZMod n) = (ZMod n → ℂ)`: `(A f)(x) = ∑_{s ∈ S} f(x + s)`. -/
noncomputable def adjacency (S : Finset (ZMod n)) (f : ZMod n → ℂ) : ZMod n → ℂ :=
  fun x => ∑ s ∈ S, f (x + s)

/-- The additive character `x ↦ ζ ^ x.val` associated with an `n`-th root of unity `ζ`; the
Fourier basis vector of `ℓ²(ZMod n)`. -/
def charVec (ζ : ℂ) : ZMod n → ℂ := fun x => ζ ^ x.val

/-- The eigenvalue attached to the character `charVec ζ`: the Fourier transform
`∑_{s ∈ S} ζ^s` of the connection set `S` (a Laurent polynomial / character sum). -/
noncomputable def eigenvalue (S : Finset (ZMod n)) (ζ : ℂ) : ℂ := ∑ s ∈ S, ζ ^ s.val

/-- **The bridge (diagonalisation).** Every additive character `charVec ζ` (for `ζ` an `n`-th
root of unity) is an eigenvector of the Cayley adjacency operator, with eigenvalue the character
sum `eigenvalue S ζ`.  Thus the representation-theoretic Fourier basis simultaneously
diagonalises *every* Cayley (circulant/convolution) operator over `ZMod n`. -/
theorem char_is_eigenvector (hζ : ζ ^ n = 1) (S : Finset (ZMod n)) :
    adjacency S (charVec ζ) = eigenvalue S ζ • charVec ζ := by
  funext x
  simp only [adjacency, charVec, eigenvalue, Pi.smul_apply, smul_eq_mul, Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro s _
  rw [zeta_pow_val_add hζ]
  ring

omit [NeZero n] in
/-- The Fourier eigenvector is nonzero, so `char_is_eigenvector` exhibits a genuine eigenvalue. -/
lemma charVec_ne_zero : charVec ζ ≠ (0 : ZMod n → ℂ) := by
  intro h
  have := congrFun h 0
  simp [charVec] at this

/-! ### Perron eigenvalue and the degree bound -/

omit [NeZero n] in
/-- **Perron–Frobenius eigenvalue.** At the trivial character `ζ = 1` the eigenvalue equals the
degree `|S|` of the Cayley graph. -/
theorem eigenvalue_perron (S : Finset (ZMod n)) :
    eigenvalue S (1 : ℂ) = (S.card : ℂ) := by
  simp [eigenvalue]

/-- **Degree bound on the spectrum.** For `ζ` an `n`-th root of unity, every eigenvalue has
modulus at most the degree `|S|`.  This is the spectral bound underlying the mixing/spectral-gap
analysis of the walk. -/
theorem norm_eigenvalue_le (hζ : ζ ^ n = 1) (S : Finset (ZMod n)) :
    ‖eigenvalue S ζ‖ ≤ (S.card : ℝ) := by
  have hz : ‖ζ‖ = 1 := norm_eq_one_of_pow_eq_one hζ (NeZero.ne n)
  calc ‖eigenvalue S ζ‖ = ‖∑ s ∈ S, ζ ^ s.val‖ := rfl
    _ ≤ ∑ s ∈ S, ‖ζ ^ s.val‖ := norm_sum_le _ _
    _ = ∑ s ∈ S, (1 : ℝ) := by
          apply Finset.sum_congr rfl; intro s _; rw [norm_pow, hz, one_pow]
    _ = (S.card : ℝ) := by simp

/-! ### Real spectrum for symmetric Cayley graphs -/

/-- **Self-adjointness / real spectrum.** If the connection set `S` is symmetric
(`s ∈ S → -s ∈ S`), then every eigenvalue of the Cayley adjacency operator is a real number
(equivalently, it is fixed by complex conjugation).  This is the linear-algebraic reflection of
the fact that a symmetric generating set yields a Hermitian walk operator, which is exactly the
setting in which the spectral gap `1 - |λ₂|` controls mixing. -/
theorem eigenvalue_real (hζ : ζ ^ n = 1) {S : Finset (ZMod n)}
    (hSym : ∀ s ∈ S, -s ∈ S) :
    (starRingEnd ℂ) (eigenvalue S ζ) = eigenvalue S ζ := by
  have hconj : (starRingEnd ℂ) ζ = ζ⁻¹ :=
    (inv_eq_conj (norm_eq_one_of_pow_eq_one hζ (NeZero.ne n))).symm
  rw [eigenvalue, map_sum]
  have step : ∀ s ∈ S, (starRingEnd ℂ) (ζ ^ s.val) = ζ ^ ((-s).val) := by
    intro s _
    rw [map_pow, hconj, inv_pow]
    exact inv_eq_of_mul_eq_one_left (by rw [mul_comm]; exact zeta_neg_val hζ s)
  rw [Finset.sum_congr rfl step]
  apply Finset.sum_nbij' (fun s => -s) (fun s => -s)
  · intro s hs; exact hSym s hs
  · intro s hs; exact hSym s hs
  · intro s _; simp
  · intro s _; simp
  · intro s _; rfl

/-! ### The cycle graph: spectrum is `2·cos(2πk/n)` -/

/-- For the cycle Cayley graph `Cay(ZMod n, {±1})` (with `n ≥ 3` so that `1 ≠ -1`), the eigenvalue
attached to `ζ` is `ζ + ζ⁻¹`. -/
theorem cycle_eigenvalue (hζ : ζ ^ n = 1) (hn : 3 ≤ n) :
    eigenvalue ({1, -1} : Finset (ZMod n)) ζ = ζ + ζ⁻¹ := by
  have hfact : Fact (1 < n) := ⟨by omega⟩
  have hne : (1 : ZMod n) ≠ -1 := by
    intro h
    have h2' : ((2 : ℕ) : ZMod n) = 0 := by push_cast; linear_combination h
    rw [CharP.cast_eq_zero_iff (ZMod n) n] at h2'
    have := Nat.le_of_dvd (by norm_num) h2'
    omega
  rw [eigenvalue, Finset.sum_pair hne, ZMod.val_one n, pow_one]
  congr 1
  have hh : ζ ^ ((-1 : ZMod n).val) * ζ = 1 := by
    have := zeta_neg_val hζ 1
    rw [ZMod.val_one n, pow_one] at this
    linear_combination this
  exact eq_inv_of_mul_eq_one_left hh

/-- Euler's formula in the form used for the cycle spectrum:
`exp(θi) + exp(θi)⁻¹ = 2·cos θ`. -/
theorem exp_add_inv_eq_two_cos (θ : ℝ) :
    Complex.exp (θ * I) + (Complex.exp (θ * I))⁻¹ = 2 * (Real.cos θ : ℂ) := by
  rw [← Complex.exp_neg, Complex.ofReal_cos, Complex.cos, neg_mul]
  ring

/-- The standard `n`-th root of unity `exp(2πik/n)` really is an `n`-th root of unity. -/
theorem exp_two_pi_root_of_unity (k : ℤ) :
    (Complex.exp (((2 * Real.pi * k / n : ℝ)) * I)) ^ n = 1 := by
  rw [← Complex.exp_nat_mul]
  have hn : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne n)
  have : (n : ℂ) * (((2 * Real.pi * k / n : ℝ)) * I) = (k : ℂ) * (2 * Real.pi * I) := by
    push_cast; field_simp
  rw [this]
  exact Complex.exp_int_mul_two_pi_mul_I k

/-- **The full cross-domain bridge for the cycle.** For the cycle Cayley graph
`Cay(ZMod n, {±1})` with `n ≥ 3`, the eigenvalue of the walk operator at the `k`-th Fourier mode
`ζ = exp(2πik/n)` equals `2·cos(2πk/n)`.  This links the *spectrum of a circulant matrix*
(linear algebra / spectral graph theory) to *characters of `ZMod n`* (representation theory) and
to *elementary trigonometry of roots of unity*. -/
theorem cycle_spectrum (k : ℤ) (hn : 3 ≤ n) :
    eigenvalue ({1, -1} : Finset (ZMod n))
        (Complex.exp (((2 * Real.pi * k / n : ℝ)) * I))
      = 2 * (Real.cos (2 * Real.pi * k / n) : ℂ) := by
  rw [cycle_eigenvalue (exp_two_pi_root_of_unity k) hn, exp_add_inv_eq_two_cos]

end QuantumWalkSpectralBridge