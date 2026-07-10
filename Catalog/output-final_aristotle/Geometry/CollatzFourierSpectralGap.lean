import Mathlib

/-! # The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map

This file builds a *connector* between two a priori unrelated areas:

* **Arithmetic dynamics** — the Collatz (`3n+1`) map `T : ℕ → ℕ`, and
* **Fourier analysis** — exponential (character) sums `∑ e(ω n)` and their
  *spectral gap* dichotomy.

## The Fourier side

For `e ω = exp(2πi ω)` the geometric character sum
`S_N(ω) = ∑_{n<N} (e ω)^n` exhibits a sharp dichotomy:

* **Full resonance** at integer frequencies: `S_N(m) = N` (`full_resonance`).
* **Spectral gap** at every non-integer frequency: `‖S_N(ω)‖ ≤ 1 / |sin(π ω)|`,
  a bound *independent of `N`* (`spectral_gap`).

So the character sum concentrates energy (grows like `N`) *only* at the integer
frequencies; everywhere else it stays bounded.  This is the precise sense in
which a linear phase is "mixing".

## The bridge

The Collatz branch selector is governed by a single Fourier character: the
value of `e` at the Nyquist frequency `ω = 1/2`.  Indeed `(e (1/2))^n = (-1)^n`,
which equals `1` exactly when `n` is even, so

`collatz n = if (e (1/2))^n = 1 then n/2 else 3n+1`  (`fourier_selects_branch`).

Consequently the Collatz Fourier transform splits along parity
(`collatzFourier_parity_split`).  This is the announced cross-domain link:
Collatz dynamics are read off from the character sum at `ω = 1/2`.

## The dynamics side

We record that the Collatz orbit of a power of two collapses to `1`
(`collatz_pow_two_step`, `collatz_iterate_pow_two`), the cleanest instance of
"convergence to the `{1,4,2,1}` cycle".
-/

namespace CollatzFourierSpectralGap

open Complex Real

/-- The additive character `e(x) = exp(2πi x)`. -/
noncomputable def e (x : ℝ) : ℂ := Complex.exp (2 * Real.pi * Complex.I * x)

/-
The character has unit modulus: `‖e ω‖ = 1`.
-/
theorem norm_e (ω : ℝ) : ‖e ω‖ = 1 := by
  -- The norm of the exponential function is 1 for any real number.
  simp [e, Complex.norm_exp]

/-
Powers of the character are characters of the scaled frequency.
-/
theorem e_pow (ω : ℝ) (n : ℕ) : (e ω) ^ n = Complex.exp (2 * Real.pi * Complex.I * (ω * n)) := by
  unfold e; rw [ ← Complex.exp_nat_mul ] ; ring_nf;

/-
Modulus of `e ω - 1` in terms of a sine (half-angle identity):
`‖e ω - 1‖ = 2 |sin(π ω)|`.
-/
theorem norm_e_sub_one (ω : ℝ) : ‖e ω - 1‖ = 2 * |Real.sin (Real.pi * ω)| := by
  unfold e;
  norm_num [ Complex.norm_def, Complex.normSq, Complex.exp_re, Complex.exp_im ];
  rw [ Real.sqrt_eq_iff_mul_self_eq ] <;> norm_num <;> ring_nf <;> norm_num [ Real.sin_sq, Real.cos_sq ] <;> ring_nf;
  nlinarith [ Real.cos_sq' ( Real.pi * ω * 2 ) ]

/-
`e ω = 1` for integer frequencies.
-/
theorem e_intCast (m : ℤ) : e (m : ℝ) = 1 := by
  exact Complex.exp_eq_one_iff.mpr ⟨ m, by simp +decide [ mul_comm, mul_left_comm ] ⟩

/-
**Full resonance.** At an integer frequency the character sum is exactly `N`.
-/
theorem full_resonance (m : ℤ) (N : ℕ) :
    ∑ n ∈ Finset.range N, (e (m : ℝ)) ^ n = (N : ℂ) := by
  rw [ Finset.sum_congr rfl fun _ _ => by rw [ e_intCast m, one_pow ], Finset.sum_const, Finset.card_range, nsmul_one ]

/-
**Spectral gap.** At any non-integer frequency (`e ω ≠ 1`) the character sum
is bounded by `1 / |sin(π ω)|`, *uniformly in `N`*.
-/
theorem spectral_gap (ω : ℝ) (hω : e ω ≠ 1) (N : ℕ) :
    ‖∑ n ∈ Finset.range N, (e ω) ^ n‖ ≤ 1 / |Real.sin (Real.pi * ω)| := by
  rw [ geom_sum_eq ];
  · norm_num [ norm_div, norm_e, norm_e_sub_one ];
    exact le_trans ( mul_le_mul_of_nonneg_right ( show ‖e ω ^ N - 1‖ ≤ 2 by exact le_trans ( norm_sub_le _ _ ) <| by norm_num [ norm_e ] ) <| by positivity ) <| by ring_nf; norm_num;
  · assumption

/-! ## The Collatz map -/

/-- The Collatz `3n+1` map. -/
def collatz (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-
One Collatz step halves a power of two.
-/
theorem collatz_pow_two_step (k : ℕ) : collatz (2 ^ (k + 1)) = 2 ^ k := by
  unfold collatz; norm_num [ pow_succ' ] ;

/-
The Collatz orbit of `2 ^ k` reaches `1` in exactly `k` steps.
-/
theorem collatz_iterate_pow_two (k : ℕ) : collatz^[k] (2 ^ k) = 1 := by
  induction' k with k ih;
  · rfl;
  · simp_all +decide [ Function.iterate_add_apply, collatz_pow_two_step ]

/-! ## The bridge: a Fourier character selects the Collatz branch -/

/-
The Nyquist character value: `e (1/2) = -1`.
-/
theorem e_half : e (1 / 2) = -1 := by
  convert Complex.exp_pi_mul_I using 2 ; ring_nf;
  unfold e; norm_num [ mul_assoc, mul_comm, mul_left_comm ] ;

/-
**The connector.** The Collatz branch is decided by the value of the Fourier
character `e` at the Nyquist frequency `ω = 1/2`: the even branch is taken
exactly when `(e (1/2))^n = 1`.
-/
theorem fourier_selects_branch (n : ℕ) :
    collatz n = if (e (1 / 2)) ^ n = 1 then n / 2 else 3 * n + 1 := by
  -- Recall that `e(1/2) = -1`.
  have h_e_half : e (1 / 2) = -1 := e_half
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> norm_num [ h_e_half, pow_add, pow_mul, collatz ]

/-- The Collatz Fourier transform `F_N(ω) = ∑_{n<N} e(ω · T n)`. -/
noncomputable def collatzFourier (ω : ℝ) (N : ℕ) : ℂ :=
  ∑ n ∈ Finset.range N, e (ω * (collatz n))

/-
The Collatz Fourier transform splits along the parity partition induced by the
Nyquist character.
-/
theorem collatzFourier_parity_split (ω : ℝ) (N : ℕ) :
    collatzFourier ω N =
      (∑ n ∈ (Finset.range N).filter (fun n => n % 2 = 0), e (ω * (n / 2)))
      + (∑ n ∈ (Finset.range N).filter (fun n => ¬ n % 2 = 0), e (ω * (3 * n + 1))) := by
  unfold collatzFourier;
  rw [ Finset.sum_filter, Finset.sum_filter, ← Finset.sum_add_distrib ] ; congr ; ext x ; split_ifs <;> simp_all +decide [ collatz ] ; ring_nf;
  rw [ Nat.cast_div ( Nat.dvd_of_mod_eq_zero ‹_› ) ] <;> norm_num ; ring_nf;

end CollatzFourierSpectralGap