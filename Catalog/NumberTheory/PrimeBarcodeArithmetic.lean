/-
# Arithmetic of the prime `H₀` barcode: parity, the Poisson refutation, and the twin
# prime Betti defect

`PrimePersistentHomology.lean` identified the `H₀` barcode of the prime point cloud
`P n = p_n` with the sequence of prime gaps, and `PrimeBarcodeInvariants.lean` computed the
total persistence and the Betti staircase `b₀(ε, n) = 1 + #{i < n : gap_i > ε}`.  The
research mission then conjectured that this barcode is statistically indistinguishable from
that of a Poisson point process of intensity `1/log x`: the bar lengths should be
*exponentially distributed* with mean `≈ log x`.

This file tests that conjecture and **refutes it**, and then converts the surviving
arithmetic content into topology.

## Main results

* `PrimeBarcodeArith.barLength_lattice` — the bar-length spectrum is *atomic*: every `H₀`
  bar of the prime cloud has length `1` (the single bar `2 ↦ 3`) or an even length `≥ 2`.
  A continuous exponential law is therefore impossible.

* `PrimeBarcodeArith.card_short_bars_eq_one` — quantitatively, the number of bars of length
  `< 2` among the first `n` bars is **exactly one**, for every `n ≥ 1`.

* `PrimeBarcodeArith.poisson_short_bar_prediction_fails` — the refutation: for *every*
  candidate mean `μ > 0`, an exponential law predicts `n(1 - e^{-2/μ}) → ∞` bars of length
  `< 2`, while the true count stays equal to `1`.  Hence no exponential law, with any mean
  whatsoever (in particular with mean `log x`), fits the prime `H₀` barcode.

* `PrimeBarcodeArith.bettiZero_two_add_twinIndexCount` — **the twin prime counting function
  is a Betti defect**: for `n ≥ 1`, `b₀(2, n) + #{i < n : gap_i = 2} = n`.

* `PrimeBarcodeArith.twinPrime_iff_bettiDefect_unbounded` — the **twin prime conjecture** is
  equivalent to the unboundedness of the topological defect `n - b₀(2, n)` of the prime
  cloud at scale `2`.

* `PrimeBarcodeArith.exists_large_primeGap` — arbitrarily long bars occur arbitrarily late,
  and hence `PrimeBarcodeArith.bettiZero_unbounded`: at *every fixed scale* the prime cloud
  breaks into arbitrarily many connected components.

* `PrimeBarcodeArith.bettiZero_interleaving` — a hard stability (interleaving) bound: a
  `δ`-perturbation of a line cloud shifts its Betti curve by at most `2δ` in scale.  In
  particular the prime barcode is robust: it is not an artefact of the exact positions of
  the primes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  H1: prime `H₀` bar lengths are exponential with mean `log x`.
H2: the twin prime conjecture is a statement about a Betti number, not about a bar.
H3: at fixed scale the cloud is eventually connected (this we expected to be false).

Experiment (Experimenter).  Sieve to `10^6` (`ComputationalEvidence.md`): 78 497 bars, mean
bar length 12.74 versus `log 10^6 = 13.82`, maximal bar 114 at `p = 492113`, and *exactly
one* odd bar (the bar of length `1` from `2` to `3`).  An exponential law with mean 12.74
predicts `78497·(1 - e^{-2/12.74}) ≈ 11405` bars shorter than `2`; the truth is `1`.  The
Betti identity `b₀(2, n) = n - #twins` was verified exactly: `70328 = 78497 - 8169`.

Analysis (Analyst).  H1 is **false**, and false for a structural reason: after the first
bar all bars are even, because all primes after `2` are odd.  The barcode measure is
supported on `{1} ∪ 2ℕ`, a lattice of measure zero for any absolutely continuous law.  The
correct statement, still open, is that the *rescaled even* barcode `gap/log x` is
exponential (Cramér).  H2 is **true and provable**.  H3 is **false**: factorial gaps give
arbitrarily many components at any fixed scale.

Critique (Critic).  The refutation of H1 is made quantitative rather than rhetorical: we
prove a strict inequality between the true count and the Poisson prediction for all large
`n` and *all* means `μ > 0`, so the failure cannot be repaired by re-tuning the mean.  The
twin prime equivalence is stated with the honest `Set.Infinite` on primes, and inherits no
hidden assumption; the ℕ-subtraction in the defect is safe because `b₀(2, n) ≤ n`.

Synthesis (PI).  The prime barcode is topologically rigid but statistically *non*-Poisson:
its atoms are the even numbers, its Betti defect at scale `2` counts twin primes, and at
every scale it has infinitely many components.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.PrimeBarcodeInvariants

namespace PrimeBarcodeArith

open Finset

/-! ### The bar-length spectrum is atomic -/

/-- The first `H₀` bar of the prime cloud, from `2` to `3`, has length `1`. -/
theorem primeGap_zero : TwinPrimeGaps.primeGap 0 = 1 := by
  unfold TwinPrimeGaps.primeGap
  simp

/-- Every prime after the first is odd. -/
theorem nth_prime_odd {n : ℕ} (hn : 1 ≤ n) : Odd (Nat.nth Nat.Prime n) := by
  have h3 : (3 : ℕ) ≤ Nat.nth Nat.Prime n := by
    have : Nat.nth Nat.Prime 1 ≤ Nat.nth Nat.Prime n :=
      Nat.nth_monotone Nat.infinite_setOf_prime hn
    simpa using this
  have hp : (Nat.nth Nat.Prime n).Prime := Nat.prime_nth_prime n
  rcases hp.eq_two_or_odd' with h | h
  · omega
  · exact h

/-- Bars are strictly positive: consecutive primes are distinct. -/
theorem primeGap_pos (n : ℕ) : 0 < TwinPrimeGaps.primeGap n := by
  have h : Nat.nth Nat.Prime n < Nat.nth Nat.Prime (n + 1) :=
    Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self n)
  unfold TwinPrimeGaps.primeGap
  omega

/-- All bars after the first have even length. -/
theorem primeGap_even {n : ℕ} (hn : 1 ≤ n) : Even (TwinPrimeGaps.primeGap n) := by
  have ha : Nat.nth Nat.Prime n % 2 = 1 := Nat.odd_iff.mp (nth_prime_odd hn)
  have hb : Nat.nth Nat.Prime (n + 1) % 2 = 1 :=
    Nat.odd_iff.mp (nth_prime_odd (le_trans hn (Nat.le_succ n)))
  have h : Nat.nth Nat.Prime n < Nat.nth Nat.Prime (n + 1) :=
    Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self n)
  rw [Nat.even_iff]
  unfold TwinPrimeGaps.primeGap
  omega

/-- **The bar-length spectrum of the prime barcode is atomic.**  Every bar has length `1`
(and this happens only for the very first bar) or an even length `≥ 2`. -/
theorem barLength_lattice (n : ℕ) :
    (n = 0 ∧ TwinPrimeGaps.primeGap n = 1) ∨
      (1 ≤ n ∧ Even (TwinPrimeGaps.primeGap n) ∧ 2 ≤ TwinPrimeGaps.primeGap n) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · exact Or.inl ⟨rfl, primeGap_zero⟩
  · refine Or.inr ⟨hn, primeGap_even hn, ?_⟩
    obtain ⟨k, hk⟩ := primeGap_even hn
    have := primeGap_pos n
    omega

/-- Only the very first bar is shorter than `2`. -/
theorem short_bar_iff (i : ℕ) : ((TwinPrimeGaps.primeGap i : ℝ) < 2) ↔ i = 0 := by
  constructor
  · intro h
    by_contra hi
    have hi' : 1 ≤ i := Nat.one_le_iff_ne_zero.mpr hi
    obtain ⟨k, hk⟩ := primeGap_even hi'
    have hpos := primeGap_pos i
    have h2 : (2 : ℕ) ≤ TwinPrimeGaps.primeGap i := by omega
    have : ((2 : ℕ) : ℝ) ≤ (TwinPrimeGaps.primeGap i : ℝ) := Nat.cast_le.mpr h2
    push_cast at this
    linarith
  · rintro rfl
    rw [primeGap_zero]
    norm_num

/-- **Exactly one short bar.**  Among the first `n ≥ 1` bars of the prime barcode there is
exactly one of length `< 2`. -/
theorem card_short_bars_eq_one {n : ℕ} (hn : 1 ≤ n) :
    ((Finset.range n).filter (fun i => (TwinPrimeGaps.primeGap i : ℝ) < 2)).card = 1 := by
  classical
  have : (Finset.range n).filter (fun i => (TwinPrimeGaps.primeGap i : ℝ) < 2) = {0} := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨-, h⟩
      exact (short_bar_iff i).mp h
    · rintro rfl
      exact ⟨hn, (short_bar_iff 0).mpr rfl⟩
  rw [this]
  simp

/-- **Refutation of the Poisson / exponential conjecture.**  For every candidate mean
`μ > 0` the exponential law predicts `n·(1 - e^{-2/μ})` bars of length `< 2` among the
first `n`, a quantity tending to infinity, whereas the prime barcode has exactly one such
bar.  Consequently no exponential law — with mean `log x` or with any other mean — can
describe the `H₀` bar lengths of the primes. -/
theorem poisson_short_bar_prediction_fails (μ : ℝ) (hμ : 0 < μ) :
    ∃ N : ℕ, 1 ≤ N ∧ ∀ n ≥ N,
      (((Finset.range n).filter (fun i => (TwinPrimeGaps.primeGap i : ℝ) < 2)).card : ℝ)
        < (n : ℝ) * (1 - Real.exp (-2 / μ)) := by
  have hc : 0 < 1 - Real.exp (-2 / μ) := by
    have hpos : (0 : ℝ) < 2 / μ := by positivity
    have hneg : -2 / μ < 0 := by rw [neg_div]; linarith
    have : Real.exp (-2 / μ) < 1 := Real.exp_lt_one_iff.mpr hneg
    linarith
  obtain ⟨N, hN⟩ := exists_nat_gt (1 / (1 - Real.exp (-2 / μ)))
  refine ⟨max N 1, le_max_right _ _, ?_⟩
  intro n hn
  have hn1 : 1 ≤ n := le_trans (le_max_right N 1) hn
  rw [card_short_bars_eq_one hn1]
  have hNn : (N : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast le_trans (le_max_left N 1) hn
  have h1 : 1 / (1 - Real.exp (-2 / μ)) < (n : ℝ) := lt_of_lt_of_le hN hNn
  rw [div_lt_iff₀ hc] at h1
  push_cast
  linarith

/-! ### The twin prime conjecture as a Betti defect -/

/-- The number of twin-prime bars (bars of length exactly `2`) among the first `n` bars. -/
noncomputable def twinIndexCount (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun i => TwinPrimeGaps.primeGap i = 2)).card

/-- Splitting the first `n` bars according to their length: short (only the first), twin
(length `2`), and long (length `> 2`). -/
theorem card_long_bars {n : ℕ} (hn : 1 ≤ n) :
    ((Finset.range n).filter (fun i => 2 < TwinPrimeGaps.primeGap i)).card
      + twinIndexCount n + 1 = n := by
  classical
  have hsplit :
      ((Finset.range n).filter (fun i => 2 < TwinPrimeGaps.primeGap i)).card
        + ((Finset.range n).filter (fun i => ¬ (2 < TwinPrimeGaps.primeGap i))).card = n := by
    simpa using Finset.card_filter_add_card_filter_not (s := Finset.range n)
      (fun i => 2 < TwinPrimeGaps.primeGap i)
  have hsmall :
      (Finset.range n).filter (fun i => ¬ (2 < TwinPrimeGaps.primeGap i))
        = insert 0 ((Finset.range n).filter (fun i => TwinPrimeGaps.primeGap i = 2)) := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_insert, not_lt]
    constructor
    · rintro ⟨hi, h⟩
      rcases Nat.eq_zero_or_pos i with rfl | hpos
      · exact Or.inl rfl
      · refine Or.inr ⟨hi, ?_⟩
        obtain ⟨k, hk⟩ := primeGap_even hpos
        have := primeGap_pos i
        omega
    · rintro (rfl | ⟨hi, h⟩)
      · exact ⟨hn, by rw [primeGap_zero]; norm_num⟩
      · exact ⟨hi, by omega⟩
  have h0 : (0 : ℕ) ∉ (Finset.range n).filter (fun i => TwinPrimeGaps.primeGap i = 2) := by
    simp [primeGap_zero]
  rw [hsmall, Finset.card_insert_of_notMem h0] at hsplit
  unfold twinIndexCount
  omega

/-- **The twin prime counting function is a Betti defect.**  At scale `ε = 2` the number of
connected components of the first `n + 1` primes plus the number of twin-prime bars among
the first `n` bars equals `n`. -/
theorem bettiZero_two_add_twinIndexCount {n : ℕ} (hn : 1 ≤ n) :
    PrimeBarcode.bettiZero PrimePH.P 2 n + twinIndexCount n = n := by
  classical
  have hb := PrimeBarcode.prime_bettiZero_eq (2 : ℝ) n
  have hcast : (Finset.range n).filter (fun i => (2 : ℝ) < (TwinPrimeGaps.primeGap i : ℝ))
      = (Finset.range n).filter (fun i => 2 < TwinPrimeGaps.primeGap i) := by
    apply Finset.filter_congr
    intro i _
    constructor
    · intro h; exact_mod_cast h
    · intro h; exact_mod_cast h
  rw [hcast] at hb
  have := card_long_bars hn
  omega

/-- From an infinite set of indices, the counting function is unbounded. -/
theorem exists_card_filter_ge {p : ℕ → Prop} [DecidablePred p] (hp : {n | p n}.Infinite)
    (K : ℕ) : ∃ n, K ≤ ((Finset.range n).filter p).card := by
  classical
  obtain ⟨t, hts, htc⟩ := hp.exists_subset_card_eq K
  refine ⟨(t.sup id) + 1, ?_⟩
  have hsub : t ⊆ (Finset.range ((t.sup id) + 1)).filter p := by
    intro x hx
    refine Finset.mem_filter.mpr ⟨Finset.mem_range.mpr ?_, hts hx⟩
    have : id x ≤ t.sup id := Finset.le_sup hx
    simpa using Nat.lt_succ_of_le this
  calc K = t.card := htc.symm
    _ ≤ _ := Finset.card_le_card hsub

/-- Conversely, a finite set of indices gives a bounded counting function. -/
theorem card_filter_le_of_finite {p : ℕ → Prop} [DecidablePred p] (hp : {n | p n}.Finite)
    (n : ℕ) : ((Finset.range n).filter p).card ≤ hp.toFinset.card := by
  classical
  apply Finset.card_le_card
  intro x hx
  exact hp.mem_toFinset.mpr (Finset.mem_filter.mp hx).2

/-- **The twin prime conjecture is a topological unboundedness statement.**  There are
infinitely many twin primes if and only if the Betti defect `n - b₀(2, n)` of the prime
point cloud at scale `2` is unbounded. -/
theorem twinPrime_iff_bettiDefect_unbounded :
    {p : ℕ | p.Prime ∧ (p + 2).Prime}.Infinite ↔
      ∀ K : ℕ, ∃ n, K ≤ n - PrimeBarcode.bettiZero PrimePH.P 2 n := by
  classical
  rw [PrimePH.twinPrime_iff_infinitely_many_gap_two]
  constructor
  · intro h K
    obtain ⟨n, hn⟩ := exists_card_filter_ge (p := fun i => TwinPrimeGaps.primeGap i = 2) h K
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · have hK : K = 0 := by simp at hn; omega
      exact ⟨0, by omega⟩
    · refine ⟨n, ?_⟩
      have hbb := bettiZero_two_add_twinIndexCount hpos
      have hn' : K ≤ twinIndexCount n := by simpa [twinIndexCount] using hn
      omega
  · intro h
    by_contra hfin
    rw [Set.not_infinite] at hfin
    obtain ⟨n, hn⟩ := h (hfin.toFinset.card + 1)
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · simp at hn
    · have hb := bettiZero_two_add_twinIndexCount hpos
      have hle : twinIndexCount n ≤ hfin.toFinset.card := by
        simpa [twinIndexCount] using card_filter_le_of_finite
          (p := fun i => TwinPrimeGaps.primeGap i = 2) hfin n
      omega

/-! ### Arbitrarily long bars, and infinitely many components at every scale -/

/-- The classical composite window: `m! + k` is composite for `2 ≤ k ≤ m`. -/
theorem not_prime_factorial_add {m k : ℕ} (hk : 2 ≤ k) (hkm : k ≤ m) :
    ¬ (Nat.factorial m + k).Prime := by
  intro hp
  have hd : k ∣ Nat.factorial m + k :=
    Nat.dvd_add (Nat.dvd_factorial (by omega) hkm) dvd_rfl
  rcases hp.eq_one_or_self_of_dvd k hd with h | h
  · omega
  · have := Nat.factorial_pos m
    omega

/-- **Arbitrarily long bars occur arbitrarily late.**  For every length `L` and every index
`N` there is a bar of index `≥ N` and length `> L`. -/
theorem exists_large_primeGap (L N : ℕ) :
    ∃ n, N ≤ n ∧ L < TwinPrimeGaps.primeGap n := by
  classical
  set m : ℕ := max (L + 2) (Nat.nth Nat.Prime N + 2) with hm
  have hm2 : 2 ≤ m := le_trans (by omega) (le_max_left _ _)
  have hmL : L + 2 ≤ m := le_max_left _ _
  have hmN : Nat.nth Nat.Prime N + 2 ≤ m := le_max_right _ _
  set c : ℕ := Nat.count Nat.Prime (Nat.factorial m + 2) with hc
  -- `c ≥ N + 1`, so `c - 1 ≥ N`
  have hfac : m ≤ Nat.factorial m := Nat.self_le_factorial m
  have hcN : N + 1 ≤ c := by
    have h1 : Nat.count Nat.Prime (Nat.nth Nat.Prime N + 1) = N + 1 :=
      Nat.count_nth_succ_of_infinite Nat.infinite_setOf_prime N
    have h2 : Nat.nth Nat.Prime N + 1 ≤ Nat.factorial m + 2 := by omega
    have := Nat.count_monotone Nat.Prime h2
    omega
  refine ⟨c - 1, by omega, ?_⟩
  have hc1 : c - 1 + 1 = c := by omega
  -- the `(c-1)`-st prime is at most `m! + 1`
  have hlow : Nat.nth Nat.Prime (c - 1) ≤ Nat.factorial m + 1 := by
    have : Nat.nth Nat.Prime (c - 1) < Nat.factorial m + 2 :=
      Nat.nth_lt_of_lt_count (by omega)
    omega
  -- the `c`-th prime is at least `m! + 2`
  have hhigh : Nat.factorial m + 2 ≤ Nat.nth Nat.Prime c :=
    (Nat.count_le_iff_le_nth Nat.infinite_setOf_prime).mp le_rfl
  -- but it avoids the composite window, so it is at least `m! + m + 1`
  have hprime : (Nat.nth Nat.Prime c).Prime := Nat.prime_nth_prime c
  have hwindow : Nat.factorial m + m + 1 ≤ Nat.nth Nat.Prime c := by
    by_contra hlt
    push_neg at hlt
    obtain ⟨k, hk⟩ : ∃ k, Nat.nth Nat.Prime c = Nat.factorial m + k ∧ 2 ≤ k ∧ k ≤ m := by
      refine ⟨Nat.nth Nat.Prime c - Nat.factorial m, by omega, by omega, by omega⟩
    exact not_prime_factorial_add hk.2.1 hk.2.2 (hk.1 ▸ hprime)
  unfold TwinPrimeGaps.primeGap
  rw [hc1]
  omega

/-- The set of bars longer than any fixed scale is infinite. -/
theorem infinite_long_bars (ε : ℝ) :
    {i : ℕ | ε < (TwinPrimeGaps.primeGap i : ℝ)}.Infinite := by
  classical
  rw [Set.infinite_iff_exists_gt]
  intro a
  obtain ⟨L, hL⟩ := exists_nat_gt ε
  obtain ⟨n, hn1, hn2⟩ := exists_large_primeGap L (a + 1)
  refine ⟨n, ?_, by omega⟩
  have : (L : ℝ) < (TwinPrimeGaps.primeGap n : ℝ) := by exact_mod_cast hn2
  exact lt_trans hL this

/-- **At every fixed scale the prime cloud has arbitrarily many components.**  Contrary to
the naive expectation that a large scale eventually connects the primes, the Betti number
`b₀(ε, n)` is unbounded in `n` for every fixed `ε`. -/
theorem bettiZero_unbounded (ε : ℝ) (K : ℕ) :
    ∃ n, K ≤ PrimeBarcode.bettiZero PrimePH.P ε n := by
  classical
  obtain ⟨n, hn⟩ := exists_card_filter_ge
    (p := fun i => ε < (TwinPrimeGaps.primeGap i : ℝ)) (infinite_long_bars ε) K
  refine ⟨n, ?_⟩
  rw [PrimeBarcode.prime_bettiZero_eq ε n]
  omega

/-! ### Monotonicity and stability of the Betti curve -/

/-- The Betti curve is antitone in the scale: enlarging `ε` can only merge components. -/
theorem bettiZero_antitone (p : ℕ → ℝ) (n : ℕ) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    PrimeBarcode.bettiZero p ε₂ n ≤ PrimeBarcode.bettiZero p ε₁ n := by
  classical
  rw [PrimeBarcode.bettiZero_eq, PrimeBarcode.bettiZero_eq]
  have : (Finset.range n).filter (fun i => ε₂ < p (i + 1) - p i)
      ⊆ (Finset.range n).filter (fun i => ε₁ < p (i + 1) - p i) := by
    intro i hi
    rcases Finset.mem_filter.mp hi with ⟨hi1, hi2⟩
    exact Finset.mem_filter.mpr ⟨hi1, lt_of_le_of_lt h hi2⟩
  have := Finset.card_le_card this
  omega

/-- **Stability / interleaving of the `H₀` barcode.**  If two clouds on the line are
uniformly `δ`-close then their Betti curves are `2δ`-interleaved: perturbing the primes by
`δ` shifts the barcode by at most `2δ` in scale. -/
theorem bettiZero_interleaving (p q : ℕ → ℝ) (δ ε : ℝ) (h : ∀ i, |p i - q i| ≤ δ) (n : ℕ) :
    PrimeBarcode.bettiZero q (ε + 2 * δ) n ≤ PrimeBarcode.bettiZero p ε n := by
  classical
  rw [PrimeBarcode.bettiZero_eq, PrimeBarcode.bettiZero_eq]
  have hsub : (Finset.range n).filter (fun i => ε + 2 * δ < q (i + 1) - q i)
      ⊆ (Finset.range n).filter (fun i => ε < p (i + 1) - p i) := by
    intro i hi
    rcases Finset.mem_filter.mp hi with ⟨hi1, hi2⟩
    refine Finset.mem_filter.mpr ⟨hi1, ?_⟩
    have h1 := abs_le.mp (h (i + 1))
    have h2 := abs_le.mp (h i)
    linarith
  have := Finset.card_le_card hsub
  omega

end PrimeBarcodeArith