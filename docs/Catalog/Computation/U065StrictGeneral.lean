/-
# U065 — Cycle 4: strict mixture excess at **every** modulus, and two-sided tomography
of the carrier set

Cycle 3 proved the general-modulus inequality only in non-strict form, because Jensen's
inequality for a finite family is non-strict without a supporting-line argument.  This
file supplies the supporting line explicitly for the multiplicative proxy (the tangent
line inequality `e^t ≥ 1 + t`, strict for `t ≠ 0`) and thereby removes primality from the
cycle-1 result altogether:

* `mixture_excess_general_modulus` — for every modulus `m ≥ 3`, every weight `c > 0`
  with `c ≠ 1`, `m·c < ∑_N c^{#{j : m ∣ j² − N}}`.  Composite moduli and prime powers
  boost the smoothness rate exactly as primes do; the naive baseline is biased downwards
  at every element of the factor base.

It also closes the two-sided version of the carrier-count question:

* `carrier_count_upper_bound` — `k ≤ (3/2)·A / log(1 + X)`, which together with
  `carrier_count_lower_bound` (`A/X ≤ k`) brackets the number of carrier primes by the
  measured amplitude alone;
* `carrier_count_bracket` — the bracket in one statement.
-/
import Computation.U065GeneralModulus
import Computation.U065MixtureGeneral

namespace U065

open Finset

section StrictGeneral

variable {m : ℕ} [NeZero m]

/-- Tangent-line bound for the multiplicative proxy: `c^x ≥ c·(1 + (x−1)·log c)`, with
strict inequality unless `x = 1` or `c = 1`. -/
lemma pow_ge_tangent {c : ℝ} (hc : 0 < c) (x : ℕ) :
    c * (1 + ((x : ℝ) - 1) * Real.log c) ≤ c ^ x := by
  have hexp : c ^ x = Real.exp ((x : ℝ) * Real.log c) := by
    rw [mul_comm, Real.exp_mul, Real.exp_log hc, Real.rpow_natCast]
  have hsplit : Real.exp ((x : ℝ) * Real.log c)
      = c * Real.exp (((x : ℝ) - 1) * Real.log c) := by
    have haux : Real.exp (Real.log c) * Real.exp (((x : ℝ) - 1) * Real.log c)
        = Real.exp ((x : ℝ) * Real.log c) := by
      rw [← Real.exp_add]
      congr 1
      ring
    rw [Real.exp_log hc] at haux
    exact haux.symm
  have htan : 1 + ((x : ℝ) - 1) * Real.log c
      ≤ Real.exp (((x : ℝ) - 1) * Real.log c) := by
    have := Real.add_one_le_exp (((x : ℝ) - 1) * Real.log c)
    linarith
  rw [hexp, hsplit]
  exact mul_le_mul_of_nonneg_left htan hc.le

lemma pow_gt_tangent {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) {x : ℕ} (hx : x ≠ 1) :
    c * (1 + ((x : ℝ) - 1) * Real.log c) < c ^ x := by
  have hlog : Real.log c ≠ 0 := Real.log_ne_zero_of_pos_of_ne_one hc hc1
  have hxne : ((x : ℝ) - 1) ≠ 0 := by
    intro h
    apply hx
    have : (x : ℝ) = 1 := by linarith
    exact_mod_cast this
  have hexp : c ^ x = Real.exp ((x : ℝ) * Real.log c) := by
    rw [mul_comm, Real.exp_mul, Real.exp_log hc, Real.rpow_natCast]
  have hsplit : Real.exp ((x : ℝ) * Real.log c)
      = c * Real.exp (((x : ℝ) - 1) * Real.log c) := by
    have haux : Real.exp (Real.log c) * Real.exp (((x : ℝ) - 1) * Real.log c)
        = Real.exp ((x : ℝ) * Real.log c) := by
      rw [← Real.exp_add]
      congr 1
      ring
    rw [Real.exp_log hc] at haux
    exact haux.symm
  have htan : 1 + ((x : ℝ) - 1) * Real.log c
      < Real.exp (((x : ℝ) - 1) * Real.log c) := by
    have := Real.add_one_lt_exp (x := ((x : ℝ) - 1) * Real.log c) (mul_ne_zero hxne hlog)
    linarith
  rw [hexp, hsplit]
  exact (mul_lt_mul_of_pos_left htan hc)

/-- **Strict mixture excess at an arbitrary modulus.**  For every `m ≥ 3` the
quadratic-residue divisibility mixture strictly beats the naive baseline `m·c`.  No
primality is used: only mean preservation and the existence of a non-residue. -/
theorem mixture_excess_general_modulus (hm : 3 ≤ m) {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) :
    (m : ℝ) * c < ∑ a : ZMod m, c ^ (rootCountM a) := by
  classical
  obtain ⟨a₀, ha₀⟩ := exists_rootCountM_eq_zero hm
  have hcard : (Finset.univ : Finset (ZMod m)).card = m := ZMod.card m
  have hsumX : ∑ a : ZMod m, ((rootCountM a : ℝ)) = (m : ℝ) := by
    have h := sum_rootCountM (m := m)
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) h
  -- the tangent-line sum reproduces the naive baseline exactly
  have hbase : ∑ a : ZMod m, c * (1 + ((rootCountM a : ℝ) - 1) * Real.log c)
      = (m : ℝ) * c := by
    have hexpand : ∀ a : ZMod m, c * (1 + ((rootCountM a : ℝ) - 1) * Real.log c)
        = c + (c * Real.log c) * ((rootCountM a : ℝ) - 1) := by
      intro a; ring
    simp only [hexpand]
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hsumX,
      Finset.sum_const, hcard, nsmul_eq_mul, Finset.sum_const, hcard, nsmul_eq_mul]
    simp [mul_comm]
  have hlt : ∑ a : ZMod m, c * (1 + ((rootCountM a : ℝ) - 1) * Real.log c)
      < ∑ a : ZMod m, c ^ (rootCountM a) := by
    refine Finset.sum_lt_sum (fun a _ => pow_ge_tangent hc _) ⟨a₀, Finset.mem_univ _, ?_⟩
    exact pow_gt_tangent hc hc1 (by rw [ha₀]; norm_num)
  rw [hbase] at hlt
  exact hlt

end StrictGeneral

section Tomography

variable {ι : Type*} [Fintype ι]

/-- **Upper bound on the number of carrier primes.**  Each prime contributes at least
`(2/3)·log(1 + X)`, so a measured amplitude cannot be produced by too many primes. -/
theorem carrier_count_upper_bound (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) :
    (Fintype.card ι : ℝ) ≤ (3 / 2) * humpLogAmplitude Q c
      / Real.log (1 + (c - 1) ^ 2 / (2 * c)) := by
  have hXpos : 0 < (c - 1) ^ 2 / (2 * c) := by
    have : 0 < (c - 1) ^ 2 := pow_two_pos_of_ne_zero (sub_ne_zero.mpr hc1)
    positivity
  have hLpos : 0 < Real.log (1 + (c - 1) ^ 2 / (2 * c)) :=
    Real.log_pos (by linarith)
  have hle := Finset.sum_le_sum
    (fun i (_ : i ∈ (Finset.univ : Finset ι)) => le_logExcess (hQ i) hc)
  have hsum : (Fintype.card ι : ℝ) * ((2 / 3 : ℝ) * Real.log (1 + (c - 1) ^ 2 / (2 * c)))
      ≤ humpLogAmplitude Q c := by
    simpa [humpLogAmplitude, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using hle
  rw [le_div_iff₀ hLpos]
  linarith

/-- **Amplitude tomography.**  The measured hump amplitude brackets the number of
carrier primes from both sides, within a factor `3/2` of `A / X`. -/
theorem carrier_count_bracket (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) :
    humpLogAmplitude Q c / ((c - 1) ^ 2 / (2 * c)) ≤ (Fintype.card ι : ℝ) ∧
      (Fintype.card ι : ℝ) ≤ (3 / 2) * humpLogAmplitude Q c
        / Real.log (1 + (c - 1) ^ 2 / (2 * c)) :=
  ⟨carrier_count_lower_bound Q hQ hc hc1, carrier_count_upper_bound Q hQ hc hc1⟩

end Tomography

section StrictConvexGeneral

variable {m : ℕ} [NeZero m]

/-- Some target has at least two square roots: mean `1` together with a zero stratum
forces an over-represented stratum. -/
theorem exists_two_le_rootCountM (hm : 3 ≤ m) : ∃ a : ZMod m, 2 ≤ rootCountM a := by
  classical
  obtain ⟨a₀, ha₀⟩ := exists_rootCountM_eq_zero hm
  by_contra hcon
  push_neg at hcon
  have hle : ∀ a : ZMod m, rootCountM a ≤ 1 := fun a => by
    have := hcon a; omega
  have hcard : (Finset.univ : Finset (ZMod m)).card = m := ZMod.card m
  have hlt : ∑ a : ZMod m, rootCountM a < ∑ _a : ZMod m, 1 := by
    refine Finset.sum_lt_sum (fun a _ => hle a) ⟨a₀, Finset.mem_univ _, ?_⟩
    rw [ha₀]; norm_num
  rw [sum_rootCountM, Finset.sum_const, hcard, smul_eq_mul, mul_one] at hlt
  exact lt_irrefl _ hlt

/-- **Strict convex excess at an arbitrary modulus.**  For every `m ≥ 3` and every
strictly convex functional `G`, the divisibility mixture strictly beats the naive
baseline.  The supporting line is the chord through `0` and `1`; it is exact on the two
lower strata and strictly below `G` on the doubled stratum, which exists by
`exists_two_le_rootCountM`. -/
theorem mixture_strictConvex_excess_general (hm : 3 ≤ m) {G : ℝ → ℝ}
    (hG : StrictConvexOn ℝ Set.univ G) :
    (m : ℝ) * G 1 < ∑ a : ZMod m, G ((rootCountM a : ℝ)) := by
  classical
  obtain ⟨a₁, ha₁⟩ := exists_two_le_rootCountM hm
  set s := G 1 - G 0 with hs
  have hcard : (Finset.univ : Finset (ZMod m)).card = m := ZMod.card m
  have hsumX : ∑ a : ZMod m, ((rootCountM a : ℝ)) = (m : ℝ) := by
    have h := sum_rootCountM (m := m)
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) h
  -- the chord through `(0, G 0)` and `(1, G 1)` supports `G` at every natural point
  have hline : ∀ x : ℕ, G 1 + s * ((x : ℝ) - 1) ≤ G ((x : ℝ)) := by
    intro x
    rcases Nat.lt_or_ge x 2 with hx | hx
    · interval_cases x
      · simp [hs]
      · simp
    · have hx1 : (1 : ℝ) < (x : ℝ) := by exact_mod_cast (by omega : 1 < x)
      have hslope := hG.convexOn.slope_mono_adjacent (Set.mem_univ (0 : ℝ))
        (Set.mem_univ ((x : ℝ))) (by norm_num) hx1
      have hxpos : (0 : ℝ) < (x : ℝ) - 1 := by linarith
      rw [div_le_div_iff₀ (by norm_num) hxpos] at hslope
      simp only [sub_zero] at hslope
      nlinarith
  have hlinestrict : G 1 + s * (((rootCountM a₁ : ℕ) : ℝ) - 1) < G ((rootCountM a₁ : ℝ)) := by
    have hx1 : (1 : ℝ) < ((rootCountM a₁ : ℕ) : ℝ) := by
      exact_mod_cast (by omega : 1 < rootCountM a₁)
    have hslope := hG.slope_strict_mono_adjacent (Set.mem_univ (0 : ℝ))
      (Set.mem_univ (((rootCountM a₁ : ℕ) : ℝ))) (by norm_num) hx1
    have hxpos : (0 : ℝ) < ((rootCountM a₁ : ℕ) : ℝ) - 1 := by linarith
    rw [div_lt_div_iff₀ (by norm_num) hxpos] at hslope
    simp only [sub_zero] at hslope
    nlinarith
  have hbase : ∑ a : ZMod m, (G 1 + s * (((rootCountM a : ℕ) : ℝ) - 1)) = (m : ℝ) * G 1 := by
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hsumX,
      Finset.sum_const, hcard, nsmul_eq_mul, Finset.sum_const, hcard, nsmul_eq_mul]
    ring
  have hlt : ∑ a : ZMod m, (G 1 + s * (((rootCountM a : ℕ) : ℝ) - 1))
      < ∑ a : ZMod m, G ((rootCountM a : ℝ)) :=
    Finset.sum_lt_sum (fun a _ => hline _) ⟨a₁, Finset.mem_univ _, hlinestrict⟩
  rw [hbase] at hlt
  exact hlt

end StrictConvexGeneral

end U065