import Mathlib
import Novelty.MirrorCongruenceSharpness
import Novelty.MirrorWeilSlopes

/-!
# Arithmetic Mirror Symmetry XI — the point-count difference is an exact slope detector

This file is the fourth part of cycle 4 of the research thread.  It closes **Conjecture H**
of `FUTURE_DIRECTIONS.md`.

Cycle 2 proved that the mirror point-count congruence has a strict filtration: if the Tate
multiplicities of `X` and `Y` agree in all slots below `r` and differ at `r`, then
`q^r ∣ #X(𝔽_q) − #Y(𝔽_q)` and, for the specific one-slot-bump family, not `q^{r+1}`.
Conjecture H asked whether this is an *exact* detector for arbitrary multiplicity vectors,
i.e. whether the `p`-adic valuation of the difference is exactly `a·r` and not merely `≥ a·r`.

The answer is yes, with the precise unit predicted in the conjecture's "key insight":

`#X(𝔽_q) − #Y(𝔽_q) = q^r · u`  with  `u ≡ c_r − c_{n−r}  (mod q)`,

so the difference detects the first discrepancy exactly whenever that first discrepancy is
a `p`-adic unit — and the residual ambiguity is *only* the divisibility of `c_r − c_{n−r}`
itself, which is the sharp boundary.

## Main results

* `mirror_pointCount_diff_sum` — the difference of mirror point counts is
  `∑_{k ≤ n} (c_k − c_{n−k}) q^k`.
* `mirror_pointCount_diff_factor` — under coincidence below `r`, the difference factors as
  `q^r · u` with `u = ∑_{i ≤ n−r} (c_{r+i} − c_{n−r−i}) q^i`.
* `mirror_slope_unit_congruence` — `u ≡ c_r − c_{n−r} (mod q)`: the cofactor is a lift of
  the first discrepancy.
* `mirror_slope_detector` — the packaged statement `∃ u, diff = q^r u ∧ q ∣ u − (c_r − c_{n−r})`.
* `mirror_slope_exact` — **Conjecture H, integral form**: if `q ∤ (c_r − c_{n−r})` then
  `q^r ∣ diff` and `q^{r+1} ∤ diff`.
* `mirror_slope_padic_exact` — **Conjecture H, `p`-adic form**: for `q = p^a` with `a ≥ 1`
  and `p ∤ (c_r − c_{n−r})`, `v_p(#X(𝔽_q) − #Y(𝔽_q)) = a·r` exactly.
* `sharp_family_padic_valuation` — consistency with cycle 2's one-slot-bump family: the
  valuation of `q^r(1 − q)` is exactly `a·r`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cycle 2's witness had difference exactly `q^r(1 − q)`,
  and `1 − q` is a `p`-adic unit.  The `1 − q` looked like an accident of the one-slot
  bump; the guess was that in general the cofactor is a lift of `c_r − c_{n−r}`, of which
  `1 − 2 = −1` (mod `q`, after the reflection moves the bump) is the special case.
* **Experiment (Experimenter).**  Splitting `range (n+1) = range r ⊎ (r + range (n+1−r))`
  via `Finset.sum_range_add` kills the first block by hypothesis and pulls `q^r` out of the
  second.  Peeling the `i = 0` term of the cofactor with `Finset.sum_range_succ'` shows
  every remaining term carries a factor `q`, which is the congruence.  Both steps are
  index arithmetic only — no positivity, no bounds.
* **Analysis (Analyst).**  The boundary is exactly `q ∣ c_r − c_{n−r}`: when the first
  discrepancy is itself divisible by `p`, the detector *under*-reports, and it must, since
  the difference is then divisible by `q^{r+1}`.  So the correct form of Conjecture H is
  conditional on the first discrepancy being a unit, and in that form it is an equality,
  not an inequality.
* **Critique (Critic).**  `mirror_slope_exact` needs `q ≠ 0` (else `q^{r+1} = 0` divides
  the vanishing difference and the statement is false for `r ≥ 1`), and the `p`-adic form
  needs `a ≥ 1` (for `a = 0` the modulus is trivial).  Both hypotheses are carried
  explicitly.  No `decide`, no `native_decide`; the proofs use `Finset.sum_range_add`,
  `Finset.sum_range_succ'`, `Finset.dvd_sum` and `padicValInt.mul`.
* **Synthesis (PI).**  Together with cycle 4's Newton-polygon reflection
  (`middlePoly_newton_reflection`), the loop E–H predicted in cycle 3 is closed: the slope
  symmetry comes from the coefficient functional equation, and the `p`-adic valuation of the
  point-count difference is an exact detector of the first slope discrepancy.
-/

namespace Novelty.MirrorBridge

open Finset

section Integral

variable (n r : ℕ) (c : ℕ → ℤ) (q : ℤ)

/-- The difference of the two mirror point counts is the weighted sum of the discrepancies
`c_k − c_{n−k}`. -/
theorem mirror_pointCount_diff_sum :
    hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q
      = ∑ k ∈ range (n + 1), (c k - c (n - k)) * q ^ k := by
  unfold hodgeTateCount mirrorCoeffs
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl (fun k _ => by ring)

variable {n r c q}

/-- **Factoring out the first `r` coincidences.**  If the multiplicity vector agrees with
its mirror reflection in every slot below `r`, the point-count difference is `q^r` times an
explicit cofactor. -/
theorem mirror_pointCount_diff_factor (hr : r ≤ n) (hbelow : ∀ k < r, c k = c (n - k)) :
    hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q
      = q ^ r * ∑ i ∈ range (n + 1 - r), (c (r + i) - c (n - (r + i))) * q ^ i := by
  rw [mirror_pointCount_diff_sum]
  have hsplit : n + 1 = r + (n + 1 - r) := by omega
  have key := Finset.sum_range_add (fun k => (c k - c (n - k)) * q ^ k) r (n + 1 - r)
  rw [← hsplit] at key
  have hzero : ∑ k ∈ range r, (c k - c (n - k)) * q ^ k = 0 := by
    refine Finset.sum_eq_zero (fun k hk => ?_)
    rw [hbelow k (Finset.mem_range.mp hk)]
    ring
  rw [key, hzero, zero_add, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [pow_add]
  ring

/-- **The cofactor is a lift of the first discrepancy.**  Every term of the cofactor beyond
the leading one carries a factor `q`, so `u ≡ c_r − c_{n−r} (mod q)`. -/
theorem mirror_slope_unit_congruence (hr : r ≤ n) :
    q ∣ (∑ i ∈ range (n + 1 - r), (c (r + i) - c (n - (r + i))) * q ^ i)
        - (c r - c (n - r)) := by
  have hsucc : n + 1 - r = (n - r) + 1 := by omega
  rw [hsucc, Finset.sum_range_succ']
  simp only [Nat.add_zero, pow_zero, mul_one, add_sub_cancel_right]
  refine Finset.dvd_sum (fun i _ => ?_)
  exact ⟨(c (r + (i + 1)) - c (n - (r + (i + 1)))) * q ^ i, by ring⟩

/-- **Conjecture H, packaged.**  Under coincidence below `r`, the mirror point-count
difference is `q^r · u` where the cofactor `u` reduces to the first discrepancy mod `q`. -/
theorem mirror_slope_detector (hr : r ≤ n) (hbelow : ∀ k < r, c k = c (n - k)) :
    ∃ u : ℤ, hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q = q ^ r * u
      ∧ q ∣ u - (c r - c (n - r)) :=
  ⟨_, mirror_pointCount_diff_factor hr hbelow, mirror_slope_unit_congruence hr⟩

/-- **Conjecture H, integral exactness.**  If the first discrepancy `c_r − c_{n−r}` is not
divisible by `q`, then the point-count difference is divisible by `q^r` and *not* by
`q^{r+1}`: the congruence filtration detects the first discrepancy exactly. -/
theorem mirror_slope_exact (hr : r ≤ n) (hq : q ≠ 0) (hbelow : ∀ k < r, c k = c (n - k))
    (hunit : ¬ q ∣ (c r - c (n - r))) :
    q ^ r ∣ hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q
      ∧ ¬ q ^ (r + 1) ∣ hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q := by
  obtain ⟨u, hu, hcong⟩ := mirror_slope_detector hr hbelow
  have hqr : q ^ r ≠ 0 := pow_ne_zero _ hq
  refine ⟨⟨u, hu⟩, ?_⟩
  intro hdvd
  rw [hu, pow_succ] at hdvd
  have hqu : q ∣ u := (mul_dvd_mul_iff_left hqr).mp hdvd
  exact hunit (by simpa using dvd_sub hqu hcong)

end Integral

section Padic

/-- **Conjecture H, `p`-adic form.**  Let `q = p^a` with `a ≥ 1`, let the Tate
multiplicities of the mirror pair agree in all slots below `r`, and let the first
discrepancy `c_r − c_{n−r}` be a `p`-adic unit.  Then

`v_p(#X(𝔽_q) − #Y(𝔽_q)) = a · r`

exactly.  The `p`-adic valuation of the point-count difference is therefore an exact
detector of the first slope discrepancy, as conjectured. -/
theorem mirror_slope_padic_exact {n r : ℕ} {c : ℕ → ℤ} {p a : ℕ} (hp : p.Prime) (ha : 1 ≤ a)
    (hr : r ≤ n) (hbelow : ∀ k < r, c k = c (n - k))
    (hunit : ¬ (p : ℤ) ∣ (c r - c (n - r))) :
    padicValInt p (hodgeTateCount c n ((p : ℤ) ^ a)
        - hodgeTateCount (mirrorCoeffs n c) n ((p : ℤ) ^ a)) = a * r := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp0 : (p : ℤ) ≠ 0 := Int.natCast_ne_zero.mpr hp.ne_zero
  obtain ⟨u, hu, hcong⟩ := mirror_slope_detector (q := (p : ℤ) ^ a) hr hbelow
  -- `p ∤ u`, because `p^a ∣ u − (c_r − c_{n−r})` and `a ≥ 1`
  have hpu : ¬ (p : ℤ) ∣ u := by
    intro hdvd
    have hpa : (p : ℤ) ∣ u - (c r - c (n - r)) :=
      dvd_trans (dvd_pow_self (p : ℤ) (by omega)) hcong
    exact hunit (by simpa using dvd_sub hdvd hpa)
  have hune : u ≠ 0 := by
    intro h
    exact hpu (h ▸ dvd_zero _)
  have hpow : ((p : ℤ) ^ a) ^ r = (p : ℤ) ^ (a * r) := by rw [← pow_mul]
  have hpowne : ((p : ℤ) ^ (a * r)) ≠ 0 := pow_ne_zero _ hp0
  have huval : padicValInt p u = 0 := by
    have hnat : ¬ p ∣ u.natAbs := by
      intro h
      exact hpu (Int.natCast_dvd_natCast.mpr h |>.trans (Int.natAbs_dvd.mpr dvd_rfl))
    simpa [padicValInt] using padicValNat.eq_zero_of_not_dvd hnat
  rw [hu, hpow, padicValInt.mul hpowne hune, padicValInt_prime_pow, huval, Nat.add_zero]

/-- **Consistency with cycle 2's sharp family.**  For the one-slot bump in dimension
`2r + 1` the difference is `q^r(1 − q)`; at `q = p^a` its valuation is exactly `a·r`,
since `1 − p^a` is a `p`-adic unit.  This is the special case of
`mirror_slope_padic_exact` in which the first discrepancy equals `1`. -/
theorem sharp_family_padic_valuation {p a r : ℕ} (hp : p.Prime) (ha : 1 ≤ a) :
    padicValInt p (((p : ℤ) ^ a) ^ r * (1 - (p : ℤ) ^ a)) = a * r := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp0 : (p : ℤ) ≠ 0 := Int.natCast_ne_zero.mpr hp.ne_zero
  have hp2 : 2 ≤ p := hp.two_le
  have hpa : (2 : ℤ) ≤ (p : ℤ) ^ a := by
    calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
      _ ≤ (p : ℤ) ^ 1 := by
          have : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp2
          simpa using this
      _ ≤ (p : ℤ) ^ a := by
          refine pow_le_pow_right₀ ?_ ha
          have : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp2
          omega
  have hune : (1 : ℤ) - (p : ℤ) ^ a ≠ 0 := by omega
  have hpu : ¬ (p : ℤ) ∣ (1 - (p : ℤ) ^ a) := by
    intro hdvd
    have hpp : (p : ℤ) ∣ (p : ℤ) ^ a := dvd_pow_self _ (by omega)
    have : (p : ℤ) ∣ 1 := by simpa using dvd_add hdvd hpp
    have hle := Int.le_of_dvd one_pos this
    have : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp2
    omega
  have huval : padicValInt p (1 - (p : ℤ) ^ a) = 0 := by
    have hnat : ¬ p ∣ (1 - (p : ℤ) ^ a).natAbs := by
      intro h
      exact hpu (Int.natCast_dvd_natCast.mpr h |>.trans (Int.natAbs_dvd.mpr dvd_rfl))
    simpa [padicValInt] using padicValNat.eq_zero_of_not_dvd hnat
  have hpow : ((p : ℤ) ^ a) ^ r = (p : ℤ) ^ (a * r) := by rw [← pow_mul]
  rw [hpow, padicValInt.mul (pow_ne_zero _ hp0) hune, padicValInt_prime_pow, huval,
    Nat.add_zero]

end Padic

end Novelty.MirrorBridge