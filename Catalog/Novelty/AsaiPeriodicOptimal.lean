/-
# The periodic large sieve constant is exactly `D · ⌈N/q⌉`

This file continues the formalisation of the analytic skeleton of the paper
**"On the Second Moment of `L(1/2, As(f) × φ)`"** (`Novelty.AsaiLargeSieve`,
`Novelty.AsaiLargeSieveGram`, `Novelty.AsaiSecondMoment`, `Novelty.AsaiMomentApplications`,
`Novelty.AsaiLargeSieveSharp`, `Novelty.AsaiSecondMomentLower`,
`Novelty.AsaiOverlapMultiplicity`).  It settles conjecture **C7** of `FUTURE_DIRECTIONS.md`.

`AsaiLargeSieve.largeSieve_of_periodic_gram_ceil` shows that a `q`-periodic Gram matrix with
entries bounded by `D` admits the large sieve constant `D · ⌈N/q⌉`.  C7 asserted that this
constant is *optimal*: no smaller one is admissible for the extremal periodic family.  That
is proved here.

## Contents

* `AsaiLargeSieve.resFamily` — the extremal `q`-periodic family
  `lam f n = √D · 1_{n ≡ f (mod q)}`, indexed by the residues `f < q`.  Its Gram matrix is
  computed exactly in `gram_resFamily`: it is `D` on `m ≡ n (mod q)` and `0` elsewhere, i.e.
  precisely the extremal matrix allowed by the hypotheses of the periodic criterion.
* `AsaiLargeSieve.largeSieve_resFamily` — the upper bound, an instance of the periodic
  criterion.
* `AsaiLargeSieve.le_of_largeSieve_resFamily` — the matching **lower** bound: every
  admissible constant `C` for this family satisfies `D · ⌈N/q⌉ ≤ C`.  The extremal test
  vector is the indicator of the residue class of `0`, which meets `[0,N)` in at least
  `⌈N/q⌉ = (N + q - 1)/q` points (`ceilDiv_le_card_residue_zero`), and on which the quadratic
  form takes the value `D · k²` against a coefficient mass `k`
  (`sum_normSq_linForm_resFamily`, `sum_normSq_resIndicator`).
* `AsaiLargeSieve.isLeast_periodic_constant` — the two halves combined: `D · ⌈N/q⌉` is the
  *least* admissible large sieve constant for `resFamily`.  In particular the criterion
  `largeSieve_of_periodic_gram_ceil` cannot be improved, and — by
  `ceilDiv_lt_real_of_not_dvd` — the older constant `D · (N/q + 1)` is genuinely
  suboptimal whenever `q ∤ N`.
* `AsaiLargeSieve.periodic_saving` — the quantitative gain over the trivial constant: for the
  extremal family the trivial (Cauchy–Schwarz) constant is `D · N`, so the periodic criterion
  saves a factor of essentially `q`.
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiLargeSieveGram
import Novelty.AsaiLargeSieveSharp

open Finset Complex

namespace AsaiLargeSieve

/-- The extremal `q`-periodic family: the `f`-th member is `√D` on the residue class of `f`
modulo `q` and `0` elsewhere.  The index set is `Finset.range q`. -/
noncomputable def resFamily (q : ℕ) (D : ℝ) : ℕ → ℕ → ℂ :=
  fun f n => if n % q = f then ((Real.sqrt D : ℝ) : ℂ) else 0

/-- The indicator of the residue class of `0` modulo `q`: the extremal test vector. -/
noncomputable def resIndicator (q : ℕ) : ℕ → ℂ :=
  fun n => if n % q = 0 then 1 else 0

/-- **The Gram matrix of the extremal family.**  It is `D` on `m ≡ n (mod q)` and `0`
elsewhere: the extremal matrix allowed by the hypotheses of the periodic criterion. -/
theorem gram_resFamily {q : ℕ} (hq : 0 < q) {D : ℝ} (hD : 0 ≤ D) (m n : ℕ) :
    gram (Finset.range q) (resFamily q D) m n = if m % q = n % q then (D : ℂ) else 0 := by
  classical
  have hs : ((Real.sqrt D : ℝ) : ℂ) * (starRingEnd ℂ) ((Real.sqrt D : ℝ) : ℂ) = (D : ℂ) := by
    rw [Complex.conj_ofReal, ← Complex.ofReal_mul, Real.mul_self_sqrt hD]
  have hmem : m % q ∈ Finset.range q := Finset.mem_range.mpr (Nat.mod_lt _ hq)
  by_cases hmn : m % q = n % q
  · rw [if_pos hmn, gram]
    refine (Finset.sum_eq_single (m % q) ?_ ?_).trans ?_
    · intro f _ hf
      have hne : m % q ≠ f := Ne.symm hf
      simp [resFamily, hne]
    · intro hcon; exact absurd hmem hcon
    · simp only [resFamily, hmn]
      simpa [hmn] using hs
  · rw [if_neg hmn, gram]
    refine Finset.sum_eq_zero fun f _ => ?_
    by_cases h1 : m % q = f
    · have h2 : n % q ≠ f := by
        intro hcon; exact hmn (h1.trans hcon.symm)
      simp [resFamily, h2]
    · simp [resFamily, h1]

/-- **Upper bound.**  The periodic criterion applies to the extremal family with the
constant `D · ⌈N/q⌉`. -/
theorem largeSieve_resFamily {q : ℕ} (hq : 0 < q) {D : ℝ} (hD : 0 ≤ D) (N : ℕ) :
    LargeSieve (Finset.range q) (resFamily q D) N (D * (((N + q - 1) / q : ℕ) : ℝ)) := by
  classical
  refine largeSieve_of_periodic_gram_ceil _ _ N q D hq hD ?_ ?_
  · intro m _ n _ hmn
    rw [gram_resFamily hq hD]
    exact if_neg hmn
  · intro m _ n _
    rw [gram_resFamily hq hD]
    by_cases h : m % q = n % q
    · rw [if_pos h, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hD]
    · rw [if_neg h, norm_zero]; exact hD

/-- The residue class of `0` meets `[0,N)` in at least `⌈N/q⌉` points: the multiples
`0, q, 2q, …` of `q` below `N` are `⌈N/q⌉` in number. -/
theorem ceilDiv_le_card_residue_zero {q : ℕ} (hq : 0 < q) (N : ℕ) :
    (N + q - 1) / q ≤ ((Finset.range N).filter (fun n => n % q = 0)).card := by
  classical
  set k := (N + q - 1) / q with hk
  have hkq : k * q ≤ N + q - 1 := Nat.div_mul_le_self _ _
  have hmap : ∀ i ∈ Finset.range k, i * q ∈ (Finset.range N).filter (fun n => n % q = 0) := by
    intro i hi
    have hik : i + 1 ≤ k := Nat.succ_le_of_lt (Finset.mem_range.mp hi)
    have h1 : (i + 1) * q ≤ k * q := Nat.mul_le_mul_right q hik
    have h2 : i * q < N := by
      have : (i + 1) * q = i * q + q := by ring
      omega
    refine Finset.mem_filter.mpr ⟨Finset.mem_range.mpr h2, ?_⟩
    simp [Nat.mul_mod_left]
  have hinj : ∀ i ∈ Finset.range k, ∀ j ∈ Finset.range k, i * q = j * q → i = j := by
    intro i _ j _ h
    exact Nat.eq_of_mul_eq_mul_right hq h
  have hcard : (Finset.range k).card
      ≤ ((Finset.range N).filter (fun n => n % q = 0)).card := by
    refine Finset.card_le_card_of_injOn (fun i => i * q) (fun i hi => hmap i hi) ?_
    intro i hi j hj h
    exact hinj i (by simpa using hi) j (by simpa using hj) h
  simpa using hcard

/-- The coefficient mass of the extremal test vector is the size of the residue class. -/
theorem sum_normSq_resIndicator (q N : ℕ) :
    ∑ n ∈ Finset.range N, ‖resIndicator q n‖ ^ 2
      = (((Finset.range N).filter (fun n => n % q = 0)).card : ℝ) := by
  classical
  simp [resIndicator, apply_ite (fun z : ℂ => ‖z‖ ^ 2)]

/-- **The quadratic form of the extremal family at the extremal test vector.**  Only the
member `f = 0` contributes, and it contributes `D · k²` where `k` is the size of the residue
class of `0` in `[0,N)`.  This is the source of the lower bound. -/
theorem sum_normSq_linForm_resFamily {q : ℕ} (hq : 0 < q) {D : ℝ} (hD : 0 ≤ D) (N : ℕ) :
    ∑ f ∈ Finset.range q, ‖linForm (resFamily q D) N (resIndicator q) f‖ ^ 2
      = D * (((Finset.range N).filter (fun n => n % q = 0)).card : ℝ) ^ 2 := by
  classical
  set K := ((Finset.range N).filter (fun n => n % q = 0)).card with hK
  have hzero : (0 : ℕ) ∈ Finset.range q := Finset.mem_range.mpr hq
  have hf0 : linForm (resFamily q D) N (resIndicator q) 0
      = ((Real.sqrt D : ℝ) : ℂ) * (K : ℂ) := by
    rw [linForm]
    have hpt : ∀ n ∈ Finset.range N,
        resIndicator q n * resFamily q D 0 n
          = if n % q = 0 then ((Real.sqrt D : ℝ) : ℂ) else 0 := by
      intro n _
      by_cases h : n % q = 0 <;> simp [resIndicator, resFamily, h]
    rw [Finset.sum_congr rfl hpt]
    simp [Finset.sum_ite, Finset.sum_const, nsmul_eq_mul, hK, mul_comm]
  have hfne : ∀ f ∈ Finset.range q, f ≠ 0 →
      linForm (resFamily q D) N (resIndicator q) f = 0 := by
    intro f _ hf
    rw [linForm]
    refine Finset.sum_eq_zero fun n _ => ?_
    by_cases h : n % q = 0
    · have : n % q ≠ f := by rw [h]; exact fun hc => hf hc.symm
      simp [resFamily, this]
    · simp [resIndicator, h]
  have hsum : ∑ f ∈ Finset.range q, ‖linForm (resFamily q D) N (resIndicator q) f‖ ^ 2
      = ‖linForm (resFamily q D) N (resIndicator q) 0‖ ^ 2 := by
    refine Finset.sum_eq_single 0 (fun f hf hne => ?_) (fun hcon => absurd hzero hcon)
    rw [hfne f hf hne, norm_zero]
    norm_num
  rw [hsum, hf0, norm_mul, mul_pow, Complex.norm_real, Real.norm_eq_abs,
    abs_of_nonneg (Real.sqrt_nonneg D), Real.sq_sqrt hD]
  simp

/-- **Conjecture C7, lower bound.**  Every admissible large sieve constant for the extremal
`q`-periodic family is at least `D · ⌈N/q⌉`. -/
theorem le_of_largeSieve_resFamily {q N : ℕ} (hq : 0 < q) (hN : 0 < N) {D : ℝ} (hD : 0 ≤ D)
    {C : ℝ} (h : LargeSieve (Finset.range q) (resFamily q D) N C) :
    D * (((N + q - 1) / q : ℕ) : ℝ) ≤ C := by
  classical
  set K := ((Finset.range N).filter (fun n => n % q = 0)).card with hK
  have hk1 : 1 ≤ (N + q - 1) / q := by
    have : q ≤ N + q - 1 := by omega
    exact (Nat.one_le_div_iff hq).mpr this
  have hKk : (N + q - 1) / q ≤ K := ceilDiv_le_card_residue_zero hq N
  have hKpos : 0 < K := lt_of_lt_of_le hk1 hKk
  have hKR : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hKpos
  have htest := h (resIndicator q)
  rw [sum_normSq_linForm_resFamily hq hD N, sum_normSq_resIndicator q N] at htest
  have hstep : D * (K : ℝ) ≤ C := by
    have : D * (K : ℝ) * (K : ℝ) ≤ C * (K : ℝ) := by nlinarith [htest]
    exact le_of_mul_le_mul_right this hKR
  have hcast : (((N + q - 1) / q : ℕ) : ℝ) ≤ (K : ℝ) := by exact_mod_cast hKk
  calc D * (((N + q - 1) / q : ℕ) : ℝ) ≤ D * (K : ℝ) := mul_le_mul_of_nonneg_left hcast hD
    _ ≤ C := hstep

/-- **Conjecture C7, proved.**  For the extremal `q`-periodic family the least admissible
large sieve constant on `[0,N)` is exactly `D · ⌈N/q⌉`; the criterion
`largeSieve_of_periodic_gram_ceil` is therefore optimal, and no criterion can do better. -/
theorem isLeast_periodic_constant {q N : ℕ} (hq : 0 < q) (hN : 0 < N) {D : ℝ} (hD : 0 ≤ D) :
    IsLeast {C : ℝ | LargeSieve (Finset.range q) (resFamily q D) N C}
      (D * (((N + q - 1) / q : ℕ) : ℝ)) :=
  ⟨largeSieve_resFamily hq hD N, fun _ hC => le_of_largeSieve_resFamily hq hN hD hC⟩

/-- **The saving over the trivial constant.**  For the extremal family the trivial
Cauchy–Schwarz constant is `D · N`, whereas the optimal one is `D · ⌈N/q⌉`; the periodic
criterion therefore saves the full factor `N / ⌈N/q⌉ ≈ q`.  (Stated as the strict inequality
`D · ⌈N/q⌉ < D · N`, valid as soon as `D > 0`, `q ≥ 2` and `N ≥ 2`.) -/
theorem periodic_saving {q N : ℕ} (hq : 2 ≤ q) (hN : 2 ≤ N) {D : ℝ} (hD : 0 < D) :
    D * (((N + q - 1) / q : ℕ) : ℝ) < D * (N : ℝ) := by
  have hNq : N + q ≤ N * q := by
    obtain ⟨a, rfl⟩ : ∃ a, N = a + 2 := ⟨N - 2, by omega⟩
    obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
    nlinarith
  have hlt : (N + q - 1) / q < N := by
    by_contra hcon
    push_neg at hcon
    have hmul : N * q ≤ ((N + q - 1) / q) * q := Nat.mul_le_mul_right q hcon
    have hle : ((N + q - 1) / q) * q ≤ N + q - 1 := Nat.div_mul_le_self _ _
    set M := N * q with hM
    set X := ((N + q - 1) / q) * q with hX
    clear_value M X
    omega
  have hcast : (((N + q - 1) / q : ℕ) : ℝ) < (N : ℝ) := by exact_mod_cast hlt
  exact mul_lt_mul_of_pos_left hcast hD

end AsaiLargeSieve