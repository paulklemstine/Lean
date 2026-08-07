import Novelty.DiophantineLatticeSpectralGap

/-!
# The shifted theta spectrum of `ℤⁿ` at its deep hole

Continuing `Novelty/DiophantineLatticeSpectralGap.lean`, we analyse the non-homogeneous form
`F(x) = Q(x - t)` for the standard form `Q(x) = Σ xᵢ²` on `ℤⁿ` and the **deep hole**
`t = (1/2, …, 1/2)`.  Two independent phenomena are isolated.

* *Metric*: the spectral gap at the deep hole is exactly `n/4` (`deepHole_isInhomMin`), and
  `n/4` is also an upper bound for the inhomogeneous minimum at **every** shift
  (`standard_covering_le`).  Hence the covering radius² of `ℤⁿ` is exactly `n/4`
  (`standard_covering_radius_least`).  Compared with `covering_ge_quarter_min` (which only
  gives `≥ 1/4`), this shows the packing–covering inequality is very far from an equality in
  large dimension (`covering_exceeds_quarter_min`).
* *Arithmetic*: the whole value set (the support of the shifted theta series) is contained in
  `n/4 + 2ℤ≥0` (`deepHole_spectrum`), because a sum of `n` odd squares is `≡ n (mod 8)`.  So
  consecutive attained values differ by at least `2` (`deepHole_gap_two`), and this is
  attained (`deepHole_gap_two_attained`).  In particular the non-homogeneous equation
  `Σ (2xᵢ - 1)² = N` is unsolvable unless `N ≡ n (mod 8)`, `N ≥ n`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the deep-hole shifted theta series of `ℤⁿ` should have a *doubled*
gap, i.e. its support sits in an arithmetic progression of step `2` rather than `1`.
Experiment (Experimenter): exhaustive rational enumeration of `4·Q(t-m)` over `m ∈ {-2..2}ⁿ`
for `n ≤ 4` produced exactly the residues `{n, n+8, n+16, …}` (see `ComputationalEvidence.md`);
no value `≡ n+4 (mod 8)` ever appeared, ruling out step `1`.
Analysis (Analyst): the mechanism is `(1-2m)² = 8·m(m-1)/2 + 1` with `m(m-1)/2 ≥ 0` an
integer — a `2`-adic statement, entirely independent of the metric statement `μ = n/4`, which
is a rounding/convexity statement.  The two combine into: the smallest attained value is `n/4`
and the next possible one is `n/4 + 2`.
Critique (Critic): `deepHole_gap_two` is not vacuous — both `n/4` and `n/4 + 2` are attained
(`deepHole_mem_spectrum`, `deepHole_gap_two_attained`) for `n ≥ 1`; and it is genuinely
stronger than integrality, which would only give step `1/4` here.
Synthesis (PI): the deep hole of `ℤⁿ` carries a spectral gap of size `2` in the value spectrum
*and* an inhomogeneous minimum of `n/4` — two different senses of "gap" for the same
non-homogeneous form, one archimedean, one `2`-adic.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-- The deep hole of `ℤⁿ`, the centre `(1/2, …, 1/2)` of a unit cube. -/
def deepHole (n : ℕ) : Fin n → ℚ := fun _ => 1 / 2

/-! ## Metric part: the inhomogeneous minimum at the deep hole is `n/4` -/

lemma deepHole_term_ge (m : ℤ) : (1 : ℚ) / 4 ≤ (1 / 2 - (m : ℚ)) ^ 2 := by
  rcases (by omega : m ≤ 0 ∨ 1 ≤ m) with h | h
  · have : ((m : ℚ)) ≤ 0 := by exact_mod_cast h
    nlinarith
  · have : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast h
    nlinarith

/-- Every lattice point is at squared distance at least `n/4` from the deep hole. -/
theorem deepHole_dist_ge (m : Fin n → ℤ) :
    (n : ℚ) / 4 ≤ form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i) := by
  rw [form_one]
  have h := card_nsmul_le_sum (univ : Finset (Fin n))
    (fun i => (deepHole n i - emb m i) ^ 2) ((1 : ℚ) / 4)
    (fun i _ => deepHole_term_ge (m i))
  simpa [nsmul_eq_mul, div_eq_mul_inv] using h.trans_eq rfl

/-- The value `n/4` is attained, at the lattice point `0`. -/
theorem deepHole_dist_zero :
    form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb (0 : Fin n → ℤ) i)
      = (n : ℚ) / 4 := by
  rw [form_one]
  have : ∀ i : Fin n, (deepHole n i - emb (0 : Fin n → ℤ) i) ^ 2 = (1 : ℚ) / 4 := by
    intro i; simp [deepHole, emb]; norm_num
  rw [sum_congr rfl fun i _ => this i]
  simp [sum_const, card_univ]
  ring

/-- **The spectral gap of `ℤⁿ` at its deep hole is exactly `n/4`.** -/
theorem deepHole_isInhomMin :
    IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) (deepHole n) ((n : ℚ) / 4) :=
  ⟨⟨0, deepHole_dist_zero⟩, deepHole_dist_ge⟩

/-- **Covering bound.**  Rounding each coordinate shows every rational shift is within squared
distance `n/4` of the lattice. -/
theorem standard_covering_le (t : Fin n → ℚ) :
    ∃ m : Fin n → ℤ, form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => t i - emb m i)
      ≤ (n : ℚ) / 4 := by
  refine ⟨fun i => round (t i), ?_⟩
  rw [form_one]
  have hterm : ∀ i : Fin n, (t i - emb (fun i => round (t i)) i) ^ 2 ≤ (1 : ℚ) / 4 := by
    intro i
    have h := abs_sub_round (t i)
    have h2 : |t i - (round (t i) : ℚ)| ^ 2 ≤ ((1 : ℚ) / 2) ^ 2 := by
      apply pow_le_pow_left₀ (abs_nonneg _) h
    simpa [sq_abs, emb] using h2.trans_eq (by norm_num)
  have h := sum_le_card_nsmul (univ : Finset (Fin n))
    (fun i => (t i - emb (fun i => round (t i)) i) ^ 2) ((1 : ℚ) / 4) (fun i _ => hterm i)
  simpa [nsmul_eq_mul, div_eq_mul_inv] using h

/-- `n/4` is the **least** covering bound: the covering radius² of `ℤⁿ` equals `n/4`. -/
theorem standard_covering_radius_least (mu : ℚ)
    (hcov : ∀ t : Fin n → ℚ, ∃ m : Fin n → ℤ,
      form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => t i - emb m i) ≤ mu) :
    (n : ℚ) / 4 ≤ mu := by
  obtain ⟨m, hm⟩ := hcov (deepHole n)
  exact (deepHole_dist_ge m).trans hm

/-- The packing–covering inequality `covering ≥ λ₁/4` of `covering_ge_quarter_min` is strict
for `ℤⁿ` as soon as `n ≥ 2`: the true covering radius² is `n/4`, larger than `λ₁/4 = 1/4`
by the factor `n`. -/
theorem covering_exceeds_quarter_min (hn : 2 ≤ n) : (1 : ℚ) / 4 < (n : ℚ) / 4 := by
  have : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  linarith

/-! ## Arithmetic part: the `2`-adic gap in the shifted spectrum -/

/-- Every odd square is `1` modulo `8`, with a *nonnegative* quotient. -/
lemma odd_sq_eq_one_add_eight (m : ℤ) : ∃ k : ℤ, 0 ≤ k ∧ (1 - 2 * m) ^ 2 = 1 + 8 * k := by
  obtain ⟨j, hj⟩ : ∃ j : ℤ, m * (m - 1) = 2 * j := by
    rcases Int.even_or_odd m with ⟨t, ht⟩ | ⟨t, ht⟩
    · exact ⟨t * (m - 1), by rw [ht]; ring⟩
    · exact ⟨m * t, by rw [ht]; ring⟩
  refine ⟨j, ?_, by linarith [hj, sq_nonneg (1 - 2 * m)] ⟩
  · have hnn : 0 ≤ m * (m - 1) := by
      rcases (by omega : m ≤ 0 ∨ 1 ≤ m) with h | h <;> nlinarith
    omega

/-- The integral avatar of the shifted form: `4·Q(t - m) = Σ (1 - 2mᵢ)²`. -/
lemma four_mul_deepHole_form (m : Fin n → ℤ) :
    4 * form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
      = ((∑ i, (1 - 2 * m i) ^ 2 : ℤ) : ℚ) := by
  rw [form_one, mul_sum]
  push_cast
  refine sum_congr rfl fun i _ => ?_
  simp only [deepHole, emb]
  ring

/-- **The shifted theta spectrum of `ℤⁿ` at its deep hole is contained in `n/4 + 2ℤ≥0`.** -/
theorem deepHole_spectrum (m : Fin n → ℤ) :
    ∃ k : ℤ, 0 ≤ k ∧
      form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
        = (n : ℚ) / 4 + 2 * k := by
  choose k hk0 hk using fun i : Fin n => odd_sq_eq_one_add_eight (m i)
  refine ⟨∑ i, k i, sum_nonneg fun i _ => hk0 i, ?_⟩
  have hsum : (∑ i, (1 - 2 * m i) ^ 2 : ℤ) = n + 8 * ∑ i, k i := by
    rw [sum_congr rfl fun i _ => hk i, sum_add_distrib, ← mul_sum]
    simp [sum_const, card_univ]
  have h4 := four_mul_deepHole_form m
  rw [hsum] at h4
  push_cast at h4 ⊢
  linarith

/-- The minimum `n/4` really is in the spectrum. -/
theorem deepHole_mem_spectrum :
    ∃ m : Fin n → ℤ,
      form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i) = (n : ℚ) / 4 :=
  ⟨0, deepHole_dist_zero⟩

/-- **Spectral gap 2.**  Two lattice points give either the same value of the non-homogeneous
form at the deep hole, or values differing by at least `2`. -/
theorem deepHole_gap_two (m m' : Fin n → ℤ)
    (hne : form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
      ≠ form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m' i)) :
    2 ≤ |form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
      - form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m' i)| := by
  obtain ⟨k, _, hk⟩ := deepHole_spectrum m
  obtain ⟨k', _, hk'⟩ := deepHole_spectrum m'
  have hkk : k ≠ k' := by
    rintro rfl
    exact hne (by rw [hk, hk'])
  have hdiff : form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
      - form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m' i)
      = 2 * ((k : ℚ) - k') := by rw [hk, hk']; ring
  rw [hdiff, abs_mul]
  have h0 : (1 : ℤ) ≤ |k - k'| := Int.one_le_abs (sub_ne_zero.mpr hkk)
  have h1 : (1 : ℚ) ≤ |(k : ℚ) - k'| := by exact_mod_cast h0
  have habs : |(2 : ℚ)| = 2 := by norm_num
  rw [habs]
  linarith

/-- The gap `2` is attained: the value `n/4 + 2` occurs (take `m = -e₀`). -/
theorem deepHole_gap_two_attained (hn : 0 < n) :
    ∃ m : Fin n → ℤ,
      form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
        = (n : ℚ) / 4 + 2 := by
  classical
  refine ⟨fun i => if i = ⟨0, hn⟩ then -1 else 0, ?_⟩
  rw [form_one]
  have hterm : ∀ i : Fin n,
      (deepHole n i - emb (fun i => if i = ⟨0, hn⟩ then (-1 : ℤ) else 0) i) ^ 2
        = 1 / 4 + (if i = ⟨0, hn⟩ then (2 : ℚ) else 0) := by
    intro i
    by_cases h : i = ⟨0, hn⟩ <;> simp [deepHole, emb, h] <;> norm_num
  rw [sum_congr rfl fun i _ => hterm i, sum_add_distrib, sum_ite_eq' univ (⟨0, hn⟩ : Fin n)]
  simp [sum_const, card_univ]
  ring

end DiophantineLattice