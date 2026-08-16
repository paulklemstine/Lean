/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The semicircle law as the unique fixed point of the moment convolution

The even moments `m_{2k} = ∫ x^{2k} dσ(x)` of the semicircle law satisfy the
*Catalan convolution recursion*

  `m_{2(k+1)} = ∑_{i=0}^{k} m_{2i} · m_{2(k-i)}`,

which is the combinatorial shadow of the Stieltjes fixed-point equation
`m(z) = 1 / (-z - m(z))` for the semicircle transform.  This recursion is exactly
the moment-method identity produced by decomposing a closed `2(k+1)`-walk at the
first return to its starting point.

We prove the recursion, and — more importantly — its converse: the recursion
together with the normalisation `m_0 = 1` **determines** the whole even moment
sequence.  Hence any limiting spectral distribution whose moments obey the
first-return decomposition must be the semicircle law: this is the abstract
uniqueness half of the moment method for Wigner matrices.
-/
import Probability.WignerSemicircleMoments

open BigOperators Finset

namespace WignerSemicircle

/-- **Catalan convolution recursion for the semicircle moments.**  Decomposing a
closed walk at its first return to the origin gives
`m_{2(k+1)} = ∑_{i ≤ k} m_{2i} m_{2(k-i)}`. -/
theorem semicircleMoment_convolution (k : ℕ) :
    semicircleMoment (2 * (k + 1))
      = ∑ i ∈ Finset.range (k + 1), semicircleMoment (2 * i) * semicircleMoment (2 * (k - i)) := by
  have hlhs : semicircleMoment (2 * (k + 1)) = (catalan (k + 1) : ℝ) :=
    semicircleMoment_two_mul (k + 1)
  have hrhs : ∀ i ∈ Finset.range (k + 1),
      semicircleMoment (2 * i) * semicircleMoment (2 * (k - i))
        = ((catalan i * catalan (k - i) : ℕ) : ℝ) := by
    intro i _
    rw [semicircleMoment_two_mul i, semicircleMoment_two_mul (k - i)]
    push_cast
    ring
  rw [hlhs, Finset.sum_congr rfl hrhs, ← Nat.cast_sum]
  congr 1
  rw [catalan_succ k, Fin.sum_univ_eq_sum_range (fun i => catalan i * catalan (k - i)) (k + 1)]

/-- **Uniqueness.**  A real sequence normalised by `a 0 = 1` and satisfying the
convolution recursion coincides with the even moments of the semicircle law.  The
proof is a strong induction: the recursion expresses `a (k+1)` in terms of the
strictly earlier values. -/
theorem eq_semicircleMoment_of_convolution (a : ℕ → ℝ) (h0 : a 0 = 1)
    (hrec : ∀ k, a (k + 1) = ∑ i ∈ Finset.range (k + 1), a i * a (k - i)) :
    ∀ k, a k = semicircleMoment (2 * k) := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    match k with
    | 0 => simpa [h0] using semicircleMoment_zero.symm
    | (n + 1) =>
        rw [hrec n, semicircleMoment_convolution n]
        refine Finset.sum_congr rfl fun i hi => ?_
        have hin : i < n + 1 := Finset.mem_range.1 hi
        have h1 : a i = semicircleMoment (2 * i) := ih i hin
        have h2 : a (n - i) = semicircleMoment (2 * (n - i)) :=
          ih (n - i) (lt_of_le_of_lt (Nat.sub_le n i) (Nat.lt_succ_self n))
        rw [h1, h2]

/-- The semicircle moment sequence is, up to the odd moments (which vanish), a
Catalan sequence: `m_{2k} = C_k` and `m_{2k+1} = 0`. Combined with
`semicircleMoment_convolution` this pins the semicircle law down completely at the
level of moments. -/
theorem semicircleMoment_eq_catalan_or_zero (m : ℕ) :
    (Even m → semicircleMoment m = (catalan (m / 2) : ℝ)) ∧
      (¬ Even m → semicircleMoment m = 0) := by
  constructor
  · rintro ⟨k, rfl⟩
    have h : k + k = 2 * k := by ring
    rw [h, semicircleMoment_two_mul k]
    congr 2
    omega
  · intro hm
    obtain ⟨k, hk⟩ := Nat.not_even_iff_odd.1 hm
    rw [hk]
    exact semicircleMoment_odd k

end WignerSemicircle