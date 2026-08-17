/-
# The area under the prime Betti curve is `p_n − 2`

Fourth instalment of the persistent-homology-of-primes thread.  The catalog file
`Novelty/PrimeBarcodeInvariants.lean` computes the two headline invariants of the
zero-dimensional prime barcode separately: the total persistence
`∑_{i<n} (p_{i+1} − p_i) = p_n − 2` and the Betti staircase
`b₀(ε, n) = 1 + #{i < n : gap i > ε}`.  Here we prove the *bridge* between them:

  the area under the reduced Betti curve equals the total persistence,

an exact Fubini-type identity between a Lebesgue integral over the scale parameter
and an arithmetic quantity, namely the `n`-th prime minus two.

## Main results

* `PrimeBettiIntegral.reduced_betti_eq_sum_indicators` — pointwise, for `ε > 0` the
  reduced Betti number `b₀(ε,n) − 1` is the sum of the indicators of the intervals
  `(0, gap i)`: each bar contributes to the component count exactly while the scale
  is below its length.

* `PrimeBettiIntegral.bettiZero_integral` — **the area identity**
  `∫_{0}^{∞} (b₀(ε, n) − 1) dε = p_n − 2`.

* `PrimeBettiIntegral.mean_bar_length` — dividing by `n`: the mean `H₀` bar length of
  the first `n` bars is `(p_n − 2)/n`, the exact form of the "average prime gap"
  whose asymptotics the prime number theorem predicts to be `∼ log p_n`.

* `PrimeBettiIntegral.betti_area_unbounded` — the area diverges: for every bound `C`
  there is a truncation whose Betti area exceeds `C`.

* `PrimeBettiIntegral.gap_histogram_from_betti` — the **inversion formula**: the number
  of bars of length exactly `2k` is the drop of `b₀` across `[2k−1, 2k+1]`, so the Betti
  staircase and the prime gap histogram determine each other.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Persistence diagrams satisfy a "layer-cake" principle:
the integral of the Betti curve should recover the total persistence.  For the primes
this would equate an analytic quantity with `p_n − 2`.

Experiment (Experimenter).  Wrote `b₀(ε,n) − 1` as `∑_{i<n} 1_{(0, gap i)}(ε)`, moved
the integral inside the finite sum (indicators of bounded intervals are integrable),
and evaluated each term as `vol (0, gap i) = gap i`; the telescoping sum of gaps is
`p_n − 2` by the catalog result `prime_totalPersistence`.

Analysis (Analyst).  The identity shows that the two invariants studied separately in
the catalog are the same datum viewed in two ways; it also converts statements about
prime gaps into statements about an integral of a topological invariant, e.g. mean
bar length is literally an average of a Betti curve.

Critique (Critic).  The integral is over the genuine Lebesgue measure on `(0, ∞)` and
the integrand is the honest Betti curve of the Rips filtration, not a definitional
stand-in; integrability is proved, not assumed.

Synthesis (PI).  Area under the Betti curve = total persistence = `p_n − 2`: the
topology of the prime point cloud integrates to arithmetic.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Computation.PrimeBarcodePoissonObstruction

open MeasureTheory

open scoped Classical

namespace PrimeBettiIntegral

open PrimePH PrimeBarcode TwinPrimeGaps PrimeTopology

/-- Pointwise layer-cake decomposition of the reduced Betti number: at scale `ε > 0`
the `i`-th bar contributes `1` exactly when `ε` is below its length. -/
theorem reduced_betti_eq_sum_indicators {n : ℕ} {ε : ℝ} (hε : 0 < ε) :
    ((bettiZero P ε n : ℝ) - 1)
      = ∑ i ∈ Finset.range n,
          Set.indicator (Set.Ioo 0 ((primeGap i : ℕ) : ℝ)) (fun _ => (1 : ℝ)) ε := by
  rw [prime_bettiZero_eq]
  push_cast
  rw [Finset.card_filter]
  push_cast
  rw [Finset.sum_congr rfl (fun i _ => ?_)]
  · ring
  · by_cases h : ε < ((primeGap i : ℕ) : ℝ) <;> simp [h, hε, Set.mem_Ioo]

/-- The indicator of a bounded interval is integrable. -/
theorem indicator_integrable (g : ℝ) :
    Integrable (Set.indicator (Set.Ioo 0 g) (fun _ => (1 : ℝ))) := by
  rw [MeasureTheory.integrable_indicator_iff measurableSet_Ioo]
  exact integrableOn_const measure_Ioo_lt_top.ne

/-- **The area under the reduced Betti curve of the prime cloud is `p_n − 2`.** -/
theorem bettiZero_integral (n : ℕ) :
    ∫ ε in Set.Ioi (0 : ℝ), ((bettiZero P ε n : ℝ) - 1) = (Nat.nth Nat.Prime n : ℝ) - 2 := by
  have step1 : ∫ ε in Set.Ioi (0 : ℝ), ((bettiZero P ε n : ℝ) - 1)
      = ∫ ε in Set.Ioi (0 : ℝ), ∑ i ∈ Finset.range n,
          Set.indicator (Set.Ioo 0 ((primeGap i : ℕ) : ℝ)) (fun _ => (1 : ℝ)) ε := by
    apply setIntegral_congr_fun measurableSet_Ioi
    intro ε hε
    exact reduced_betti_eq_sum_indicators (Set.mem_Ioi.mp hε)
  have step2 : ∫ ε in Set.Ioi (0 : ℝ), ∑ i ∈ Finset.range n,
        Set.indicator (Set.Ioo 0 ((primeGap i : ℕ) : ℝ)) (fun _ => (1 : ℝ)) ε
      = ∫ ε : ℝ, ∑ i ∈ Finset.range n,
          Set.indicator (Set.Ioo 0 ((primeGap i : ℕ) : ℝ)) (fun _ => (1 : ℝ)) ε := by
    apply setIntegral_eq_integral_of_forall_compl_eq_zero
    intro x hx
    apply Finset.sum_eq_zero
    intro i _
    apply Set.indicator_of_notMem
    simp only [Set.mem_Ioi, not_lt] at hx
    simp only [Set.mem_Ioo]
    rintro ⟨h1, -⟩
    linarith
  have step3 : ∫ ε : ℝ, ∑ i ∈ Finset.range n,
        Set.indicator (Set.Ioo 0 ((primeGap i : ℕ) : ℝ)) (fun _ => (1 : ℝ)) ε
      = ∑ i ∈ Finset.range n, ((primeGap i : ℕ) : ℝ) := by
    rw [MeasureTheory.integral_finset_sum _ (fun i _ => indicator_integrable _)]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [MeasureTheory.integral_indicator_const _ measurableSet_Ioo]
    simp
  rw [step1, step2, step3]
  have h := prime_totalPersistence_sum_gaps n
  rw [prime_totalPersistence] at h
  exact h.symm

/-- **Mean bar length.**  The average length of the first `n` finite `H₀` bars — the
average prime gap — is the Betti area divided by `n`. -/
theorem mean_bar_length {n : ℕ} (hn : 0 < n) :
    (1 / (n : ℝ)) * ∫ ε in Set.Ioi (0 : ℝ), ((bettiZero P ε n : ℝ) - 1)
      = ((Nat.nth Nat.Prime n : ℝ) - 2) / n := by
  rw [bettiZero_integral n]
  have hn' : (n : ℝ) ≠ 0 := by
    simp only [ne_eq, Nat.cast_eq_zero]
    omega
  field_simp

/-- The Betti area of the prime cloud diverges with the truncation. -/
theorem betti_area_unbounded (C : ℝ) :
    ∃ n : ℕ, C < ∫ ε in Set.Ioi (0 : ℝ), ((bettiZero P ε n : ℝ) - 1) := by
  obtain ⟨i, hi⟩ := exists_large_primeGap (⌈C⌉.toNat + 3)
  refine ⟨i + 1, ?_⟩
  rw [bettiZero_integral]
  have hstep : (Nat.nth Nat.Prime i : ℝ) ≥ 0 := by positivity
  have hgap : ((primeGap i : ℕ) : ℝ) ≤ (Nat.nth Nat.Prime (i + 1) : ℝ) := by
    have h : primeGap i ≤ Nat.nth Nat.Prime (i + 1) := by
      unfold primeGap
      omega
    exact_mod_cast h
  have hbig : ((⌈C⌉.toNat + 3 : ℕ) : ℝ) ≤ ((primeGap i : ℕ) : ℝ) := by exact_mod_cast hi
  have hC : C ≤ (⌈C⌉.toNat : ℝ) := by
    calc C ≤ (⌈C⌉ : ℝ) := Int.le_ceil C
      _ ≤ ((⌈C⌉.toNat : ℤ) : ℝ) := by exact_mod_cast Int.self_le_toNat _
      _ = (⌈C⌉.toNat : ℝ) := by push_cast; ring
  push_cast at hbig
  linarith

/-! ## The Betti staircase determines the gap histogram -/

/-- Splitting the gaps exceeding `2k−1` into those exceeding `2k+1` and those equal to
`2k`; the parity of prime gaps is what makes the middle case `2k+1` impossible. -/
theorem card_gap_window_split (n : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    ((Finset.range n).filter (fun i => 2 * k - 1 < primeGap i)).card
      = ((Finset.range n).filter (fun i => 2 * k + 1 < primeGap i)).card
        + ((Finset.range n).filter (fun i => primeGap i = 2 * k)).card := by
  have key : ∀ i, (2 * k - 1 < primeGap i ↔ (2 * k + 1 < primeGap i ∨ primeGap i = 2 * k)) := by
    intro i
    rcases Nat.eq_zero_or_pos i with rfl | hi
    · rw [primeGap_zero]; omega
    · obtain ⟨a, ha⟩ := primeGap_even hi
      rw [ha]; omega
  rw [← Finset.card_union_of_disjoint, ← Finset.filter_or]
  · exact congrArg _ (Finset.filter_congr (fun i _ => key i))
  · simp only [Finset.disjoint_left, Finset.mem_filter]
    rintro a ⟨-, ha⟩ ⟨-, hb⟩
    omega

/-- **Inversion formula.**  The prime gap histogram is recovered from the Betti
staircase: the number of bars of length exactly `2k` among the first `n` is the drop
of `b₀` across the window `[2k−1, 2k+1]`.  So the `H₀` barcode and the gap histogram
carry exactly the same information. -/
theorem gap_histogram_from_betti (n : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    bettiZero P ((2 * k - 1 : ℕ) : ℝ) n - bettiZero P ((2 * k + 1 : ℕ) : ℝ) n
      = ((Finset.range n).filter (fun i => primeGap i = 2 * k)).card := by
  rw [prime_bettiZero_eq, prime_bettiZero_eq, filter_gap_cast, filter_gap_cast,
    card_gap_window_split n hk]
  omega

end PrimeBettiIntegral