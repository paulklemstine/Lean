/-
# The q-Lucas theorem: Gaussian binomials at a root of unity

Sixth cycle.  Direction 4 of the previous cycle's `FUTURE_DIRECTIONS.md` conjectured
that at a primitive `d`-th root of unity `ζ` the Gaussian binomial coefficient
degenerates into an *ordinary* binomial coefficient times a residual Gaussian
binomial,

`⟦n, k⟧_ζ = C(n / d, k / d) · ⟦n % d, k % d⟧_ζ`,

the q-analogue of Lucas' theorem.  This file proves exactly that, in any integral
domain containing an element `z` with `z ^ d = 1` and `z ^ j ≠ 1` for `0 < j < d`.

The proof is the one predicted by the previous cycle:

* the Gauss product formula `qBinom_mul_qPoch` forces `⟦d, j⟧_ζ = 0` for `0 < j < d`,
  because `(ζ;ζ)_d` contains the vanishing factor `1 - ζ^d` while `(ζ;ζ)_j` and
  `(ζ;ζ)_{d-j}` are nonzero;
* feeding this into the q-Vandermonde convolution with the splitting `n + d` kills
  every term except `j = 0` and `j = d`, yielding the *carry recurrence*
  `⟦n + d, k⟧_ζ = ⟦n, k⟧_ζ + ⟦n, k - d⟧_ζ`   (`d ≤ k`),
  `⟦n + d, k⟧_ζ = ⟦n, k⟧_ζ`                  (`k < d`);
* strong induction on `n` against Pascal's rule for `Nat.choose` gives q-Lucas.

A corollary records the vanishing criterion: if `d ∣ n` but `d ∤ k` then
`⟦n, k⟧_ζ = 0`.
-/

import Applications.QBinomialGaussProduct

namespace Catalog.Applications.QBinomial

open Finset

variable {R : Type*} [CommRing R] [IsDomain R]

section RootOfUnity

variable {z : R} {d : ℕ}

/-- Below the order of the root of unity, the q-Pochhammer symbol is nonzero. -/
lemma qPoch_ne_zero_of_lt (hprim : ∀ j, 0 < j → j < d → z ^ j ≠ 1) {m : ℕ} (hm : m < d) :
    qPoch z m ≠ 0 := by
  rw [qPoch]
  refine Finset.prod_ne_zero_iff.mpr fun i hi h => ?_
  rw [Finset.mem_range] at hi
  exact hprim (i + 1) (by omega) (by omega) (sub_eq_zero.mp h).symm

omit [IsDomain R] in
/-- `(z;z)_d = 0` when `z ^ d = 1`: the last factor is `1 - z^d = 0`. -/
lemma qPoch_self_eq_zero (hz : z ^ d = 1) (hd : 0 < d) : qPoch z d = 0 := by
  rw [qPoch]
  refine Finset.prod_eq_zero (i := d - 1) (Finset.mem_range.mpr (by omega)) ?_
  rw [show d - 1 + 1 = d by omega, hz, sub_self]

/-- **Interior vanishing at a root of unity.**  If `z` is a primitive `d`-th root of
unity in a domain then `⟦d, j⟧_z = 0` for every `0 < j < d`. -/
theorem qBinom_root_of_unity_eq_zero (hz : z ^ d = 1)
    (hprim : ∀ j, 0 < j → j < d → z ^ j ≠ 1) {j : ℕ} (hj0 : 0 < j) (hjd : j < d) :
    qBinom z d j = 0 := by
  have hgauss := qBinom_mul_qPoch z (show j ≤ d by omega)
  rw [qPoch_self_eq_zero hz (by omega)] at hgauss
  have hne : qPoch z j * qPoch z (d - j) ≠ 0 :=
    mul_ne_zero (qPoch_ne_zero_of_lt hprim (by omega)) (qPoch_ne_zero_of_lt hprim (by omega))
  have : qBinom z d j * (qPoch z j * qPoch z (d - j)) = 0 := by
    rw [← mul_assoc]; exact hgauss
  rcases mul_eq_zero.mp this with h | h
  · exact h
  · exact absurd h hne

/-- The q-Vandermonde convolution collapses at a root of unity: only the terms
`j = 0` and `j = d` survive. -/
theorem qBinom_add_order (hz : z ^ d = 1) (hprim : ∀ j, 0 < j → j < d → z ^ j ≠ 1)
    (hd : 0 < d) (n k : ℕ) :
    qBinom z (d + n) k = qBinom z n k + (if d ≤ k then qBinom z n (k - d) else 0) := by
  rw [qBinom_vandermonde z d n k]
  have hterm : ∀ j ∈ range (k + 1), j ≠ 0 → j ≠ d →
      z ^ ((d - j) * (k - j)) * qBinom z d j * qBinom z n (k - j) = 0 := by
    intro j _ hj0 hjd
    rcases Nat.lt_or_ge j d with h | h
    · rw [qBinom_root_of_unity_eq_zero hz hprim (by omega) h, mul_zero, zero_mul]
    · rw [qBinom_eq_zero_of_lt z (show d < j by omega), mul_zero, zero_mul]
  have hzero : z ^ (d * k) = 1 := by
    rw [pow_mul, hz, one_pow]
  by_cases hk : d ≤ k
  · rw [if_pos hk]
    have h0 : (0 : ℕ) ∈ range (k + 1) := Finset.mem_range.mpr (by omega)
    have hdm : d ∈ range (k + 1) := Finset.mem_range.mpr (by omega)
    rw [Finset.sum_eq_add_of_mem 0 d h0 hdm (by omega)
      (fun j hj hne => hterm j hj hne.1 hne.2)]
    simp only [Nat.sub_zero, qBinom_zero_right, qBinom_self, mul_one]
    rw [hzero, one_mul, Nat.sub_self, zero_mul, pow_zero, one_mul]
  · rw [if_neg hk]
    have h0 : (0 : ℕ) ∈ range (k + 1) := Finset.mem_range.mpr (by omega)
    rw [Finset.sum_eq_single_of_mem 0 h0 (fun j hj hne => hterm j hj hne
      (by have := Finset.mem_range.mp hj; omega))]
    simp only [Nat.sub_zero, qBinom_zero_right, mul_one]
    rw [hzero, one_mul, add_zero]

/-- **The q-Lucas theorem.**  For a primitive `d`-th root of unity `z` in an integral
domain, `⟦n, k⟧_z = C(n / d, k / d) · ⟦n % d, k % d⟧_z`. -/
theorem qBinom_qLucas (hz : z ^ d = 1) (hprim : ∀ j, 0 < j → j < d → z ^ j ≠ 1)
    (hd : 0 < d) (n k : ℕ) :
    qBinom z n k = ((n / d).choose (k / d) : R) * qBinom z (n % d) (k % d) := by
  induction n using Nat.strong_induction_on generalizing k with
  | _ n ih =>
    rcases Nat.lt_or_ge n d with hn | hn
    · -- base range `n < d`
      rw [Nat.div_eq_of_lt hn, Nat.mod_eq_of_lt hn]
      rcases Nat.lt_or_ge k d with hk | hk
      · rw [Nat.div_eq_of_lt hk, Nat.mod_eq_of_lt hk]
        simp
      · have hkd : 0 < k / d := Nat.div_pos hk hd
        rw [Nat.choose_eq_zero_of_lt hkd, qBinom_eq_zero_of_lt z (by omega)]
        simp
    · -- inductive step: peel off one block of size `d`
      obtain ⟨m, rfl⟩ : ∃ m, n = d + m := ⟨n - d, by omega⟩
      have hm : m < d + m := by omega
      have hdiv : (d + m) / d = m / d + 1 := by
        rw [Nat.add_comm]; exact Nat.add_div_right m hd
      have hmod : (d + m) % d = m % d := Nat.add_mod_left d m
      rw [qBinom_add_order hz hprim hd m k, ih m hm k, hdiv, hmod]
      by_cases hk : d ≤ k
      · rw [if_pos hk, ih m hm (k - d)]
        have hsplit : k - d + d = k := by omega
        have hkdiv : k / d = (k - d) / d + 1 := by
          conv_lhs => rw [← hsplit]
          exact Nat.add_div_right _ hd
        have hkmod : (k - d) % d = k % d := by
          conv_rhs => rw [← hsplit]
          exact (Nat.add_mod_right _ _).symm
        rw [hkmod, hkdiv, Nat.choose_succ_succ (m / d) ((k - d) / d)]
        push_cast
        ring
      · rw [if_neg hk, add_zero]
        have hk0 : k / d = 0 := Nat.div_eq_of_lt (by omega)
        rw [hk0]
        simp

/-- Vanishing criterion: if the block length `d` divides `n` but not `k`, then the
Gaussian binomial coefficient vanishes at a primitive `d`-th root of unity. -/
theorem qBinom_root_of_unity_eq_zero_of_not_dvd (hz : z ^ d = 1)
    (hprim : ∀ j, 0 < j → j < d → z ^ j ≠ 1) (hd : 0 < d) {n k : ℕ}
    (hn : d ∣ n) (hk : ¬ d ∣ k) : qBinom z n k = 0 := by
  rw [qBinom_qLucas hz hprim hd n k]
  have hn0 : n % d = 0 := Nat.mod_eq_zero_of_dvd hn
  have hk0 : 0 < k % d := Nat.pos_of_ne_zero fun h => hk (Nat.dvd_of_mod_eq_zero h)
  rw [hn0, qBinom_eq_zero_of_lt z hk0, mul_zero]

end RootOfUnity

/-! ## A concrete instance: the `q = -1` phenomenon

The hypotheses of `qBinom_qLucas` are satisfiable: `-1` is a primitive square root of
unity in `ℤ`.  The resulting identity is the classical "`q = -1` phenomenon" for
Gaussian binomials. -/

/-- **q-Lucas at `q = -1`**: `⟦n,k⟧_{-1} = C(n/2, k/2) · ⟦n%2, k%2⟧_{-1}`. -/
theorem qBinom_neg_one_qLucas (n k : ℕ) :
    qBinom (-1 : ℤ) n k = ((n / 2).choose (k / 2) : ℤ) * qBinom (-1 : ℤ) (n % 2) (k % 2) := by
  refine qBinom_qLucas (d := 2) (by norm_num) (fun j hj0 hj2 h => ?_) (by norm_num) n k
  obtain rfl : j = 1 := by omega
  norm_num at h

/-- The `q = -1` phenomenon in its sharpest form: `⟦2a, 2b⟧_{-1} = C(a, b)`. -/
theorem qBinom_neg_one_even (a b : ℕ) :
    qBinom (-1 : ℤ) (2 * a) (2 * b) = (a.choose b : ℤ) := by
  rw [qBinom_neg_one_qLucas]
  simp [Nat.mul_mod_right]

/-- An even Gaussian binomial coefficient at `q = -1` vanishes in odd degree:
`⟦2a, 2b+1⟧_{-1} = 0`. -/
theorem qBinom_neg_one_even_odd (a b : ℕ) : qBinom (-1 : ℤ) (2 * a) (2 * b + 1) = 0 := by
  refine qBinom_root_of_unity_eq_zero_of_not_dvd (d := 2) (by norm_num)
    (fun j hj0 hj2 h => ?_) (by norm_num) ⟨a, by ring⟩ (by omega)
  obtain rfl : j = 1 := by omega
  norm_num at h

end Catalog.Applications.QBinomial