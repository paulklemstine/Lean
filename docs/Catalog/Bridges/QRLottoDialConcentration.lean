import Mathlib
import Bridges.QRLottoDialOptimality

/-!
# Concentration of the zero-fit QR lottery dial

`Bridges.QRLottoDialIndependence` computes the exact first two moments of the zero-fit
dial `T(N) = ∑ 2/p` over the CRT sample space of residue vectors coprime to a factor base
of distinct odd primes: the mean is the Mertens weight `∑ 1/p` and the variance is
`∑ 1/p²`.  This file turns those two exact moments into a **deviation bound that is
uniform in the size of the factor base**.

The point is a genuine dichotomy: the mean of the dial diverges (like `log log B`), while
its variance stays bounded — for *any* set of distinct odd primes the variance is at most
`1/2`, because `∑ 1/p² ≤ ∑_{m ≥ 3} 1/m² < 1/2`.  Hence the dial never spreads out: apart
from a fraction `1/(2t²)` of residue classes, every `N` reads within `t` of the Mertens
weight, no matter how large the factor base is.

## Main results

* `QRLotto.chebyshev_card_le` — a finite Chebyshev inequality for an arbitrary real
  function on a `Finset` (the reusable probabilistic ingredient).
* `QRLotto.sum_inv_sq_le_half` — for any finite family of *distinct* integers `≥ 3` the sum
  of inverse squares is `< 1/2`, proved by a telescoping induction (no analytic input).
* `QRLotto.dial_deviation_card_le` — Chebyshev for the dial: the number of residue vectors
  deviating by `≥ t` from the Mertens weight is at most `#Ω · (∑ 1/p²)/t²`.
* `QRLotto.dial_deviation_uniform` — **uniform concentration**: that count is at most
  `#Ω / (2t²)`, a bound depending on neither the factor base nor its size.
* `QRLotto.exists_dial_close_to_mean` — consequently the mean is always *attained up to
  `1`*: some residue vector reads within `1` of `∑ 1/p`.
* `QRLotto.dial_spread_lt_of_deviation` — the contrapositive shape used in practice: if a
  positive fraction `c` of targets deviates by `t`, then `t ≤ √(1/(2c))`.
-/

open Finset

namespace QRLotto

/-! ## A finite Chebyshev inequality -/

/-- **Chebyshev's inequality for a Finset.**  If `f` deviates from `m` by at least `t` on a
subset of `s`, then that subset is small compared with the total squared deviation. -/
theorem chebyshev_card_le {α : Type*} (s : Finset α) (f : α → ℝ) (m : ℝ) {t : ℝ}
    (ht : 0 ≤ t) :
    (#(s.filter (fun x => t ≤ |f x - m|)) : ℝ) * t ^ 2 ≤ ∑ x ∈ s, (f x - m) ^ 2 := by
  classical
  have h1 : (#(s.filter (fun x => t ≤ |f x - m|)) : ℝ) * t ^ 2
      = ∑ _x ∈ s.filter (fun x => t ≤ |f x - m|), t ^ 2 := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have h2 : ∑ _x ∈ s.filter (fun x => t ≤ |f x - m|), t ^ 2
      ≤ ∑ x ∈ s.filter (fun x => t ≤ |f x - m|), (f x - m) ^ 2 := by
    refine Finset.sum_le_sum (fun x hx => ?_)
    have hx' : t ≤ |f x - m| := (Finset.mem_filter.1 hx).2
    have habs : |f x - m| ^ 2 = (f x - m) ^ 2 := sq_abs _
    nlinarith [abs_nonneg (f x - m)]
  have h3 : ∑ x ∈ s.filter (fun x => t ≤ |f x - m|), (f x - m) ^ 2
      ≤ ∑ x ∈ s, (f x - m) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun x _ _ => sq_nonneg _)
  linarith

/-! ## The variance of the dial is bounded, uniformly in the factor base -/

/-- Telescoping bound: `∑_{m = 3}^{M} 1/m² ≤ 1/2 - 1/M`. -/
lemma sum_Icc_inv_sq_le (M : ℕ) (hM : 2 ≤ M) :
    ∑ m ∈ Finset.Icc 3 M, (1 : ℝ) / (m : ℝ) ^ 2 ≤ 1 / 2 - 1 / (M : ℝ) := by
  induction M, hM using Nat.le_induction with
  | base => norm_num
  | succ M hM ih =>
      have hMpos : (0 : ℝ) < (M : ℝ) := by
        have : (0 : ℕ) < M := lt_of_lt_of_le (by norm_num) hM
        exact_mod_cast this
      have hM1pos : (0 : ℝ) < (M : ℝ) + 1 := by linarith
      have hins : Finset.Icc 3 (M + 1) = insert (M + 1) (Finset.Icc 3 M) := by
        ext m
        simp only [Finset.mem_Icc, Finset.mem_insert]
        omega
      rw [hins, Finset.sum_insert (by simp)]
      have hstep : (1 : ℝ) / ((M : ℝ) + 1) ^ 2 ≤ 1 / (M : ℝ) - 1 / ((M : ℝ) + 1) := by
        have hsplit : (1 : ℝ) / (M : ℝ) - 1 / ((M : ℝ) + 1)
            = 1 / ((M : ℝ) * ((M : ℝ) + 1)) := by
          field_simp
          ring
        rw [hsplit]
        exact one_div_le_one_div_of_le (by positivity) (by nlinarith)
      have hcast : ((M + 1 : ℕ) : ℝ) = (M : ℝ) + 1 := by push_cast; ring
      rw [hcast]
      linarith [ih]

/-- **The variance is bounded by `1/2`, with no dependence on the factor base.**  For any
finite family of pairwise distinct integers `≥ 3` — in particular for any set of distinct
odd primes — the sum of inverse squares is at most `1/2`. -/
theorem sum_inv_sq_le_half {k : ℕ} (q : Fin k → ℕ) (hinj : Function.Injective q)
    (h3 : ∀ i, 3 ≤ q i) : ∑ i, (1 : ℝ) / (q i : ℝ) ^ 2 ≤ 1 / 2 := by
  classical
  set S : Finset ℕ := Finset.image q Finset.univ with hS
  have himg : ∑ i, (1 : ℝ) / (q i : ℝ) ^ 2 = ∑ m ∈ S, (1 : ℝ) / (m : ℝ) ^ 2 := by
    rw [hS, Finset.sum_image (fun a _ b _ h => hinj h)]
  set M : ℕ := S.sup id with hM
  have hsub : S ⊆ Finset.Icc 3 M := by
    intro m hm
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hm
    exact Finset.mem_Icc.2 ⟨h3 i, Finset.le_sup (f := id) hm⟩
  have hMcases : M = 0 ∨ 3 ≤ M := by
    rcases Finset.eq_empty_or_nonempty S with h | ⟨m, hm⟩
    · left; simp [hM, h]
    · right
      have hm3 : 3 ≤ m := (Finset.mem_Icc.1 (hsub hm)).1
      exact le_trans hm3 (Finset.le_sup (f := id) hm)
  have hle : ∑ m ∈ S, (1 : ℝ) / (m : ℝ) ^ 2 ≤ ∑ m ∈ Finset.Icc 3 M, (1 : ℝ) / (m : ℝ) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun m _ _ => by positivity)
  rcases hMcases with h0 | h3M
  · have : S ⊆ Finset.Icc 3 0 := by rw [← h0]; exact hsub
    have hSempty : S = ∅ := Finset.subset_empty.1 (by simpa using this)
    rw [himg, hSempty]
    norm_num
  · have h2M : 2 ≤ M := le_trans (by norm_num) h3M
    have hbound := sum_Icc_inv_sq_le M h2M
    have hMpos : (0 : ℝ) < (M : ℝ) := by
      have : (0 : ℕ) < M := lt_of_lt_of_le (by norm_num) h2M
      exact_mod_cast this
    have : (0 : ℝ) < 1 / (M : ℝ) := by positivity
    rw [himg]
    linarith

/-! ## Concentration of the dial -/

variable {k : ℕ}

/-- **Chebyshev for the dial.**  The number of residue vectors whose zero-fit dial deviates
from the Mertens weight by at least `t` is controlled by the exact variance `∑ 1/p²`. -/
theorem dial_deviation_card_le (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    {t : ℝ} (ht : 0 ≤ t) :
    (#((sampleSpace q).filter
        (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ) * t ^ 2
      ≤ (#(sampleSpace q) : ℝ) * ∑ i, 1 / (q i : ℝ) ^ 2 := by
  have h := chebyshev_card_le (sampleSpace q) (dialOf q) (∑ i, 1 / (q i : ℝ)) ht
  rwa [sum_sq_dialOf q hq h2] at h

/-- Odd primes are at least `3`. -/
lemma three_le_of_prime_ne_two {p : ℕ} (hp : p.Prime) (h2 : p ≠ 2) : 3 ≤ p := by
  have := hp.two_le
  omega

/-- **Uniform concentration of the zero-fit dial.**  For a factor base of *distinct* odd
primes, at most a fraction `1/(2t²)` of the residue classes read more than `t` away from
the Mertens weight — a bound independent of the primes and of how many there are, even
though the mean `∑ 1/p` itself diverges. -/
theorem dial_deviation_uniform (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) {t : ℝ} (ht : 0 < t) :
    (#((sampleSpace q).filter
        (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ)
      ≤ (#(sampleSpace q) : ℝ) / (2 * t ^ 2) := by
  have hvar : ∑ i, (1 : ℝ) / (q i : ℝ) ^ 2 ≤ 1 / 2 :=
    sum_inv_sq_le_half q hinj (fun i => three_le_of_prime_ne_two (hq i) (h2 i))
  have hcheb := dial_deviation_card_le q hq h2 ht.le
  have hcard : (0 : ℝ) ≤ (#(sampleSpace q) : ℝ) := Nat.cast_nonneg _
  have hmul : (#(sampleSpace q) : ℝ) * ∑ i, 1 / (q i : ℝ) ^ 2
      ≤ (#(sampleSpace q) : ℝ) * (1 / 2) := by
    exact mul_le_mul_of_nonneg_left hvar hcard
  have ht2 : (0 : ℝ) < t ^ 2 := by positivity
  rw [le_div_iff₀ (by positivity)]
  nlinarith

/-- **The Mertens weight is always attained up to `1`.**  Some residue vector coprime to the
factor base reads within `1` of the mean; the dial can never be uniformly far from it. -/
theorem exists_dial_close_to_mean (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) :
    ∃ x ∈ sampleSpace q, |dialOf q x - ∑ i, 1 / (q i : ℝ)| < 1 := by
  classical
  by_contra hcon
  push_neg at hcon
  have hfilter : (sampleSpace q).filter
      (fun x => (1 : ℝ) ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|) = sampleSpace q := by
    refine Finset.filter_true_of_mem (fun x hx => hcon x hx)
  have h := dial_deviation_uniform q hq h2 hinj (t := 1) (by norm_num)
  rw [hfilter] at h
  have hpos : 0 < #(sampleSpace q) := card_sampleSpace_pos q hq h2
  have hposR : (0 : ℝ) < (#(sampleSpace q) : ℝ) := by exact_mod_cast hpos
  norm_num at h
  linarith

/-- **The spread is bounded by the deviating fraction.**  If a fraction at least `c > 0` of
the residue classes deviates from the Mertens weight by `t`, then `2 c t² ≤ 1`; so a
constant fraction of targets can only be `O(1)` away from the mean. -/
theorem dial_spread_lt_of_deviation (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime)
    (h2 : ∀ i, q i ≠ 2) (hinj : Function.Injective q) {t c : ℝ} (ht : 0 < t)
    (hfrac : c * (#(sampleSpace q) : ℝ)
      ≤ (#((sampleSpace q).filter
          (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ)) :
    2 * c * t ^ 2 ≤ 1 := by
  have h := dial_deviation_uniform q hq h2 hinj ht
  have hpos : 0 < #(sampleSpace q) := card_sampleSpace_pos q hq h2
  have hposR : (0 : ℝ) < (#(sampleSpace q) : ℝ) := by exact_mod_cast hpos
  have ht2 : (0 : ℝ) < t ^ 2 := by positivity
  have hchain : c * (#(sampleSpace q) : ℝ) ≤ (#(sampleSpace q) : ℝ) / (2 * t ^ 2) :=
    le_trans hfrac h
  rw [le_div_iff₀ (by positivity)] at hchain
  nlinarith

end QRLotto