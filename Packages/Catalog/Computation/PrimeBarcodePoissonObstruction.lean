/-
# The prime barcode is *not* Poisson: quantisation, staircases, and the absence of `H₁`

This file continues the persistent-homology-of-primes thread of the catalog
(`Novelty/PrimePersistentHomology.lean`, `Novelty/PrimeBarcodeInvariants.lean`),
where the zero-dimensional Vietoris–Rips barcode of the prime point cloud
`P n = p_n ⊆ ℝ` was identified with the sequence of prime gaps and the Betti
curve was computed as `b₀(ε,n) = 1 + #{i < n : gap i > ε}`.

The research conjecture under test is the *Poisson heuristic*: that the `H₀`
barcode of the primes looks like the barcode of a Poisson process of intensity
`1/log x`, i.e. that bar lengths are exponentially distributed with mean
`≈ log x`, and that `H₁` bars appear at scale `(log x)²`, the longest one
encoding the twin prime conjecture.

We prove that **both halves of the conjecture are false**, and we replace the
false `H₁` statement by a true one: the twin prime conjecture is a statement
about a single *step of the `H₀` Betti staircase*.

## Main results

* `PrimeTopology.primeGap_even`, `PrimeTopology.bar_length_quantized` —
  **quantisation of the barcode**: every finite `H₀` bar except the very first
  has even integer length `2k`, `k ≥ 1`; the first bar has length `1`.

* `PrimeTopology.bar_window_count_eq_zero` — no bar length ever falls in an open
  window `(2k, 2k+2)`, and none falls in `(0,1)`.

* `PrimeTopology.poisson_exponential_model_refuted` — the **refutation**: for any
  proposed exponential law with mean `m > 0`, the predicted mass on the window
  `(2k, 2k+2)` is strictly positive while the empirical mass carried by the prime
  barcode is exactly `0`, for every truncation `n`.  The prime barcode measure is
  atomic on `{1} ∪ 2ℕ`; no absolutely continuous law can be its bar-length
  distribution.

* `PrimeTopology.prime_bettiZero_const_on_even_window` — the **Betti staircase is
  even-quantised**: `ε ↦ b₀(ε,n)` is constant on `[2k, 2k+2)`.  A Poisson cloud
  would have a Betti curve that decreases on every subinterval.

* `PrimeTopology.twinPrime_iff_twinStep_unbounded` — the corrected twin-prime
  bridge: the twin prime conjecture holds **iff** the single Betti step
  `b₀(1,n) − b₀(2,n)` is unbounded in `n`.  So the twin prime conjecture lives in
  `H₀`, not in `H₁`.

* `PrimeTopology.exists_large_primeGap`, `PrimeTopology.barcode_unbounded` — the
  barcode contains bars of arbitrarily large length (an explicit factorial
  construction), so the barcode has no exponential tail with a fixed mean.

* `PrimeTopology.cycle_has_two_step_chord`, `PrimeTopology.prime_no_chordless_cycle`
  — **the `H₁` prediction fails at the source**: in the Vietoris–Rips graph of any
  strictly increasing point cloud on a line, every closed cycle of length `≥ 4`
  has a two-step chord.  Hence the prime Rips graph has no chordless (induced)
  cycle at any scale `ε`, and there is no minimal `1`-cycle that could create a
  hole.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  H1: prime bar lengths are exponentially distributed
(Poisson heuristic).  H2: the barcode carries `H₁` bars at scale `(log x)²`, the
longest encoding twin primes.  H3 (ours, contrarian): the barcode is *arithmetically
quantised*, hence provably non-Poisson, and all topology of a line cloud is `H₀`.

Experiment (Experimenter).  Sieve to `10^6` (78 497 finite bars, see
`ComputationalEvidence.md`): exactly one odd bar (length `1`), all others even;
empirical mass on `(2,4)` and `(4,6)` is `0` against exponential predictions
`0.124` and `0.106`; the Betti curve is constant on `[2,4)` and `[4,6)`;
max bar length `114` at `p = 492113`.  Every one of these observations is turned
into a theorem below (with the max-bar observation strengthened to unboundedness
via the factorial gap construction).

Analysis (Analyst).  The failure of the Poisson model is *not statistical* but
structural: all primes past `2` are odd, so the barcode measure is supported on
`{1} ∪ 2ℕ`, an atomic set, while an exponential law is absolutely continuous.  The
failure of the `H₁` prediction is geometric: a point cloud in ℝ has an indifference
Rips graph, in which the leftmost vertex of any cycle sees both of its cycle
neighbours inside a window of length `ε`, so they are joined — every cycle has a
chord, no hole can ever be born.  What *is* true is the twin-prime statement, but
one dimension lower: it is the unboundedness of the `ε = 2` step of the `H₀` Betti
staircase.

Critique (Critic).  `bar_window_count_eq_zero` is vacuous only if the window is
empty — it is not: the theorems are stated with an explicit witness of positive
predicted mass, so the refutation compares two nonvacuous numbers.  The chord
theorem is stated for genuine cycles (periodic, injective on one period, length
`≥ 4`) and produces a chord between vertices at cyclic distance exactly `2`, i.e.
a real chord, not a cycle edge.  The twin prime equivalence is proved in both
directions from the catalog's `twinPrime_iff_infinitely_many_gap_two`.

Synthesis (PI).  Primes do have topology, but it is entirely zero-dimensional and
entirely arithmetic: an atomic, even-quantised barcode whose Betti staircase steps
are the gap histogram, with the twin prime conjecture as the unbounded step at
`ε = 2`.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Novelty.PrimeBarcodeInvariants

open scoped Classical

namespace PrimeTopology

open PrimePH PrimeBarcode TwinPrimeGaps

/-! ## 1. Arithmetic quantisation of the `H₀` barcode -/

/-- Consecutive primes are strictly increasing (specialisation of `Nat.nth_strictMono`). -/
theorem nth_prime_lt_succ (i : ℕ) : Nat.nth Nat.Prime i < Nat.nth Nat.Prime (i + 1) :=
  Nat.nth_strictMono (p := Nat.Prime) Nat.infinite_setOf_prime (Nat.lt_succ_self i)

/-- Monotonicity of the prime enumeration. -/
theorem nth_prime_mono {i j : ℕ} (h : i ≤ j) : Nat.nth Nat.Prime i ≤ Nat.nth Nat.Prime j :=
  Nat.nth_monotone (p := Nat.Prime) Nat.infinite_setOf_prime h

/-- The first prime after `2` is `3`. -/
theorem nth_prime_one : Nat.nth Nat.Prime 1 = 3 := by simp

/-- Every prime past the first is at least `3`. -/
theorem three_le_nth_prime {i : ℕ} (hi : 1 ≤ i) : 3 ≤ Nat.nth Nat.Prime i := by
  have h := nth_prime_mono hi
  rwa [nth_prime_one] at h

/-- Every prime past the first is odd. -/
theorem nth_prime_odd {i : ℕ} (hi : 1 ≤ i) : Odd (Nat.nth Nat.Prime i) := by
  have hp := Nat.prime_nth_prime i
  have h3 := three_le_nth_prime hi
  rcases hp.eq_two_or_odd' with h | h
  · omega
  · exact h

/-- Prime gaps, i.e. finite `H₀` bar lengths, are positive. -/
theorem primeGap_pos (i : ℕ) : 0 < primeGap i := by
  have := nth_prime_lt_succ i
  unfold primeGap
  omega

/-- The first bar of the prime barcode has length `1` (the bar `2 → 3`). -/
theorem primeGap_zero : primeGap 0 = 1 := by
  unfold primeGap
  simp

/-- **Quantisation.**  Every bar of the prime barcode past the first has even length. -/
theorem primeGap_even {i : ℕ} (hi : 1 ≤ i) : Even (primeGap i) := by
  obtain ⟨a, ha⟩ := nth_prime_odd hi
  obtain ⟨b, hb⟩ := nth_prime_odd (i := i + 1) (by omega)
  have hlt := nth_prime_lt_succ i
  refine ⟨b - a, ?_⟩
  unfold primeGap
  omega

/-- Every bar past the first has length at least `2`. -/
theorem two_le_primeGap {i : ℕ} (hi : 1 ≤ i) : 2 ≤ primeGap i := by
  obtain ⟨a, ha⟩ := primeGap_even hi
  have hpos := primeGap_pos i
  omega

/-- Bar length `1` occurs exactly once in the whole prime barcode. -/
theorem primeGap_eq_one_iff (i : ℕ) : primeGap i = 1 ↔ i = 0 := by
  constructor
  · intro h
    by_contra hi
    have := two_le_primeGap (i := i) (by omega)
    omega
  · rintro rfl
    exact primeGap_zero

/-- **Bar-length quantisation, real form.**  The `i`-th finite `H₀` bar of the prime
cloud (`i ≥ 1`) has length exactly `2k` for some `k ≥ 1`. -/
theorem bar_length_quantized {i : ℕ} (hi : 1 ≤ i) :
    ∃ k : ℕ, 1 ≤ k ∧ P (i + 1) - P i = 2 * (k : ℝ) := by
  obtain ⟨a, ha⟩ := primeGap_even hi
  refine ⟨a, ?_, ?_⟩
  · have := two_le_primeGap hi
    omega
  · rw [death_scale_eq_primeGap, ha]
    push_cast
    ring

/-! ## 2. The barcode measure is atomic: empty windows -/

/-- The number of finite `H₀` bars among the first `n` whose length lies in the open
interval `(a, b)`. -/
noncomputable def barCount (n : ℕ) (a b : ℝ) : ℕ :=
  ((Finset.range n).filter (fun i => a < P (i + 1) - P i ∧ P (i + 1) - P i < b)).card

/-- **Empty even windows.**  No prime bar has length strictly between `2k` and `2k+2`
for `k ≥ 1`: the bar-length measure is atomic, supported on the even integers
together with the single atom `1`. -/
theorem bar_window_count_eq_zero (n : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    barCount n (2 * k) (2 * k + 2) = 0 := by
  unfold barCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro i _
  rw [death_scale_eq_primeGap]
  rintro ⟨h1, h2⟩
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · rw [primeGap_zero] at h1
    have hk' : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    push_cast at h1
    linarith
  · obtain ⟨a, ha⟩ := primeGap_even hi
    rw [ha] at h1 h2
    have h1' : 2 * k < a + a := by
      have : ((2 * k : ℕ) : ℝ) < ((a + a : ℕ) : ℝ) := by push_cast at h1 ⊢; linarith
      exact_mod_cast this
    have h2' : (a + a : ℕ) < 2 * k + 2 := by
      have : ((a + a : ℕ) : ℝ) < ((2 * k + 2 : ℕ) : ℝ) := by push_cast at h2 ⊢; linarith
      exact_mod_cast this
    omega

/-- No prime bar has length strictly between `0` and `1`: the barcode has a hard
lower cutoff, whereas an exponential law puts positive mass arbitrarily close to `0`. -/
theorem bar_window_count_short_eq_zero (n : ℕ) : barCount n 0 1 = 0 := by
  unfold barCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro i _
  rw [death_scale_eq_primeGap]
  rintro ⟨-, h2⟩
  have : (1 : ℕ) ≤ primeGap i := primeGap_pos i
  have : ((1 : ℕ) : ℝ) ≤ ((primeGap i : ℕ) : ℝ) := by exact_mod_cast this
  push_cast at this
  linarith

/-- The mass an exponential law of mean `m > 0` assigns to a nondegenerate window
`(a,b)` is strictly positive. -/
theorem exp_window_mass_pos {m a b : ℝ} (hm : 0 < m) (hab : a < b) :
    0 < Real.exp (-a / m) - Real.exp (-b / m) := by
  have h : -b / m < -a / m := by gcongr
  simpa using Real.exp_lt_exp.mpr h

/-- **Refutation of the Poisson / exponential conjecture.**  For every proposed mean
`m > 0` and every even window `(2k, 2k+2)` with `k ≥ 1`, an exponential law of mean
`m` predicts a strictly positive fraction of bars inside the window, while the prime
barcode contains *no* bar there, at every truncation `n`.  Hence the `H₀` bar lengths
of the primes are not exponentially distributed for any mean — in particular not for
`m = log x`. -/
theorem poisson_exponential_model_refuted {m : ℝ} (hm : 0 < m) (n : ℕ) {k : ℕ}
    (hk : 1 ≤ k) :
    (barCount n (2 * k) (2 * k + 2) : ℝ) = 0 ∧
      0 < Real.exp (-(2 * (k : ℝ)) / m) - Real.exp (-(2 * (k : ℝ) + 2) / m) := by
  refine ⟨by rw [bar_window_count_eq_zero n hk]; norm_num, ?_⟩
  exact exp_window_mass_pos hm (by linarith)

/-- The same refutation at the bottom of the range: the model predicts a positive
fraction of bars shorter than `1`, the primes have none. -/
theorem poisson_model_refuted_short {m : ℝ} (hm : 0 < m) (n : ℕ) :
    (barCount n 0 1 : ℝ) = 0 ∧ 0 < Real.exp (-(0 : ℝ) / m) - Real.exp (-(1 : ℝ) / m) := by
  refine ⟨by rw [bar_window_count_short_eq_zero n]; norm_num, ?_⟩
  exact exp_window_mass_pos hm (by norm_num)

/-! ## 3. The Betti staircase is even-quantised -/

/-- **Even quantisation of the Betti curve.**  For `k ≥ 1` the Betti number
`b₀(ε, n)` of the prime cloud is constant for `ε ∈ [2k, 2k+2)`: every jump of the
`H₀` staircase sits at an even integer.  A Poisson cloud of any intensity has, with
probability one, a Betti curve that is nonconstant on every subinterval. -/
theorem prime_bettiZero_const_on_even_window (n : ℕ) {k : ℕ} (hk : 1 ≤ k) {e₁ e₂ : ℝ}
    (h1 : 2 * (k : ℝ) ≤ e₁) (h2 : e₁ ≤ e₂) (h3 : e₂ < 2 * (k : ℝ) + 2) :
    bettiZero P e₁ n = bettiZero P e₂ n := by
  rw [prime_bettiZero_eq, prime_bettiZero_eq]
  congr 2
  apply Finset.filter_congr
  intro i _
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos i with rfl | hi
    · rw [primeGap_zero] at h
      have hk' : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
      push_cast at h
      linarith
    · obtain ⟨a, ha⟩ := primeGap_even hi
      rw [ha] at h ⊢
      have hka : k < a := by
        by_contra hc
        push_neg at hc
        have : ((a : ℕ) : ℝ) ≤ (k : ℝ) := by exact_mod_cast hc
        push_cast at h
        linarith
      have : (k : ℝ) + 1 ≤ (a : ℝ) := by exact_mod_cast hka
      push_cast
      linarith
  · intro h
    linarith

/-! ## 4. The twin prime conjecture as an unbounded Betti step -/

/-- The `ε = 2` step of the Betti staircase: the number of components that merge as
the scale crosses `2`. -/
noncomputable def twinStep (n : ℕ) : ℕ := bettiZero P 1 n - bettiZero P 2 n

/-- Recasting a real threshold on gaps as a natural-number threshold. -/
theorem filter_gap_cast (n c : ℕ) :
    (Finset.range n).filter (fun i => (c : ℝ) < (primeGap i : ℝ))
      = (Finset.range n).filter (fun i => c < primeGap i) := by
  apply Finset.filter_congr
  intro i _
  exact_mod_cast Iff.rfl

/-- Splitting the gaps exceeding `1` into those exceeding `2` and the twin gaps. -/
theorem card_gap_split (n : ℕ) :
    ((Finset.range n).filter (fun i => 1 < primeGap i)).card
      = ((Finset.range n).filter (fun i => 2 < primeGap i)).card
        + ((Finset.range n).filter (fun i => primeGap i = 2)).card := by
  rw [← Finset.card_union_of_disjoint, ← Finset.filter_or]
  · congr 1
    apply Finset.filter_congr
    intro i _
    constructor
    · intro h; omega
    · intro h; omega
  · simp only [Finset.disjoint_left, Finset.mem_filter]
    rintro a ⟨-, ha⟩ ⟨-, hb⟩
    omega

/-- The `ε = 2` Betti step counts exactly the twin pairs among the first `n` bars. -/
theorem twinStep_eq_card (n : ℕ) :
    twinStep n = ((Finset.range n).filter (fun i => primeGap i = 2)).card := by
  unfold twinStep
  rw [prime_bettiZero_eq, prime_bettiZero_eq]
  have e1 : ((1 : ℝ)) = ((1 : ℕ) : ℝ) := by norm_num
  have e2 : ((2 : ℝ)) = ((2 : ℕ) : ℝ) := by norm_num
  rw [e1, e2, filter_gap_cast, filter_gap_cast, card_gap_split]
  omega

/-- A predicate holds infinitely often iff its counting function is unbounded. -/
theorem infinite_iff_count_unbounded (S : ℕ → Prop) [DecidablePred S] :
    {i | S i}.Infinite ↔ ∀ N : ℕ, ∃ n, N ≤ ((Finset.range n).filter S).card := by
  classical
  constructor
  · intro hinf N
    obtain ⟨T, hTsub, hTcard⟩ := hinf.exists_subset_card_eq N
    refine ⟨(T.sup id) + 1, ?_⟩
    have hsub : T ⊆ (Finset.range ((T.sup id) + 1)).filter S := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_range]
      exact ⟨Nat.lt_succ_of_le (Finset.le_sup (f := id) hx), hTsub hx⟩
    calc N = T.card := hTcard.symm
      _ ≤ _ := Finset.card_le_card hsub
  · intro h
    by_contra hfin
    rw [Set.not_infinite] at hfin
    obtain ⟨n, hn⟩ := h (hfin.toFinset.card + 1)
    have hsub : ((Finset.range n).filter S) ⊆ hfin.toFinset := by
      intro x hx
      simp only [Finset.mem_filter] at hx
      simpa using hx.2
    have := Finset.card_le_card hsub
    omega

/-- **Twin primes live in `H₀`, not in `H₁`.**  The twin prime conjecture holds if and
only if the single Betti step of the prime barcode at scale `ε = 2`,
`b₀(1,n) − b₀(2,n)`, is unbounded as the truncation `n` grows. -/
theorem twinPrime_iff_twinStep_unbounded :
    {p : ℕ | p.Prime ∧ (p + 2).Prime}.Infinite ↔ ∀ N : ℕ, ∃ n, N ≤ twinStep n := by
  rw [twinPrime_iff_infinitely_many_gap_two]
  rw [infinite_iff_count_unbounded (fun i => primeGap i = 2)]
  constructor <;> intro h N <;> obtain ⟨n, hn⟩ := h N <;> exact ⟨n, by rwa [twinStep_eq_card] at *⟩

/-! ## 5. Bars of arbitrarily large length -/

/-- Numbers of the form `m! + j` with `2 ≤ j ≤ m` are composite. -/
theorem not_prime_factorial_add {m j : ℕ} (h2 : 2 ≤ j) (hj : j ≤ m) :
    ¬ Nat.Prime (Nat.factorial m + j) := by
  intro hp
  have hdvd : j ∣ Nat.factorial m + j := Nat.dvd_add (Nat.dvd_factorial (by omega) hj) dvd_rfl
  have hfac : 0 < Nat.factorial m := Nat.factorial_pos m
  rcases hp.eq_one_or_self_of_dvd j hdvd with h | h <;> omega

/-- **Arbitrarily long bars.**  For every `N` some finite `H₀` bar of the prime cloud
has length at least `N`.  Hence the barcode has no exponential tail with a fixed mean
and, in particular, no single `log x` scale governs it. -/
theorem exists_large_primeGap (N : ℕ) : ∃ i, N ≤ primeGap i := by
  classical
  set m := N + 2 with hm
  set n := Nat.count Nat.Prime (Nat.factorial m + 2) with hn
  have hfac : 2 ≤ Nat.factorial m := by
    have h := Nat.factorial_le (m := 2) (n := m) (by omega)
    simpa [Nat.factorial] using h
  have hn1 : 1 ≤ n := by
    have h : Nat.count Nat.Prime 3 ≤ n := Nat.count_monotone _ (by omega)
    have h3 : Nat.count Nat.Prime 3 = 1 := by decide
    omega
  have hlt : Nat.nth Nat.Prime (n - 1) < Nat.factorial m + 2 :=
    Nat.nth_lt_of_lt_count (by omega)
  have hge : Nat.factorial m + 2 ≤ Nat.nth Nat.Prime n := by
    by_contra hc
    push_neg at hc
    have hp : Nat.Prime (Nat.nth Nat.Prime n) := Nat.prime_nth_prime n
    have h1 : Nat.count Nat.Prime (Nat.nth Nat.Prime n + 1) = n + 1 := by
      rw [Nat.count_succ]
      simp [hp, Nat.count_nth_of_infinite Nat.infinite_setOf_prime]
    have h2 : Nat.count Nat.Prime (Nat.nth Nat.Prime n + 1) ≤ n :=
      Nat.count_monotone _ (by omega)
    omega
  have hbig : Nat.factorial m + m + 1 ≤ Nat.nth Nat.Prime n := by
    by_contra hc
    push_neg at hc
    obtain ⟨j, hj⟩ : ∃ j, Nat.nth Nat.Prime n = Nat.factorial m + j :=
      ⟨Nat.nth Nat.Prime n - Nat.factorial m, by omega⟩
    exact not_prime_factorial_add (m := m) (j := j) (by omega) (by omega)
      (hj ▸ Nat.prime_nth_prime n)
  refine ⟨n - 1, ?_⟩
  have hsucc : n - 1 + 1 = n := by omega
  unfold primeGap
  rw [hsucc]
  omega

/-- The prime barcode is unbounded: bar lengths exceed every real bound. -/
theorem barcode_unbounded (C : ℝ) : ∃ i, C < P (i + 1) - P i := by
  obtain ⟨i, hi⟩ := exists_large_primeGap (⌈C⌉.toNat + 1)
  refine ⟨i, ?_⟩
  rw [death_scale_eq_primeGap]
  have h1 : C ≤ (⌈C⌉.toNat : ℝ) := by
    calc C ≤ (⌈C⌉ : ℝ) := Int.le_ceil C
      _ ≤ ((⌈C⌉.toNat : ℤ) : ℝ) := by exact_mod_cast Int.self_le_toNat _
      _ = (⌈C⌉.toNat : ℝ) := by push_cast; ring
  have h2 : ((⌈C⌉.toNat + 1 : ℕ) : ℝ) ≤ (primeGap i : ℝ) := by exact_mod_cast hi
  push_cast at h2
  linarith

/-! ## 6. No `H₁`: every cycle of a line Rips graph has a chord -/

/-- A `k`-periodic sequence is determined by residues mod `k`. -/
theorem periodic_mod {k : ℕ} (hk : 0 < k) {c : ℕ → ℕ} (hper : ∀ i, c (i + k) = c i)
    (i : ℕ) : c i = c (i % k) := by
  induction i using Nat.strong_induction_on with
  | _ i ih =>
    rcases lt_or_ge i k with h | h
    · rw [Nat.mod_eq_of_lt h]
    · have h1 : c i = c (i - k) := by
        have hp := hper (i - k)
        rwa [Nat.sub_add_cancel h] at hp
      have h2 : i % k = (i - k) % k := Nat.mod_eq_sub_mod h
      rw [h1, ih (i - k) (by omega), h2]

/-- **Every cycle in a line Rips graph has a two-step chord.**  If `c` is a closed
cycle of length `k ≥ 4` in the Vietoris–Rips graph of a strictly increasing point
cloud `p` at scale `ε` (periodic of period `k`, injective on one period, consecutive
vertices `ε`-close), then some pair of vertices at cyclic distance exactly `2` is
`ε`-close as well: the cycle has a genuine chord.

Geometrically: the leftmost vertex of the cycle sees both of its cycle neighbours
inside the window `[·, · + ε]`, so those two neighbours are within `ε` of each other.
Consequently the Rips graph of *any* point cloud on a line is chordal — there are no
induced cycles of length `≥ 4`, hence no minimal one-cycle that could bound a hole. -/
theorem cycle_has_two_step_chord {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} {k : ℕ}
    (hk : 4 ≤ k) {c : ℕ → ℕ} (hper : ∀ i, c (i + k) = c i)
    (hinj : ∀ i < k, ∀ j < k, c i = c j → i = j)
    (hadj : ∀ i, |p (c i) - p (c (i + 1))| ≤ ε) :
    ∃ t, c t ≠ c (t + 2) ∧ |p (c t) - p (c (t + 2))| ≤ ε := by
  have hk0 : 0 < k := by omega
  obtain ⟨i₀, hi₀mem, hi₀min⟩ :=
    Finset.exists_min_image (Finset.range k) c ⟨0, by simp [hk0]⟩
  simp only [Finset.mem_range] at hi₀mem
  have hmin : ∀ i, c i₀ ≤ c i := by
    intro i
    rw [periodic_mod hk0 hper i]
    exact hi₀min _ (Finset.mem_range.mpr (Nat.mod_lt _ hk0))
  set t := if i₀ = 0 then k - 1 else i₀ - 1 with ht
  have hstep : c (t + 1) = c i₀ := by
    by_cases h : i₀ = 0
    · have htk : t + 1 = k := by simp [ht, h]; omega
      rw [htk, h]
      simpa using hper 0
    · have htk : t + 1 = i₀ := by simp [ht, h]; omega
      rw [htk]
  refine ⟨t, ?_, ?_⟩
  · intro hcontra
    have h1 : c (t % k) = c ((t + 2) % k) := by
      rw [← periodic_mod hk0 hper, ← periodic_mod hk0 hper]
      exact hcontra
    have h2 : t % k = (t + 2) % k := hinj _ (Nat.mod_lt _ hk0) _ (Nat.mod_lt _ hk0) h1
    have hmod : Nat.ModEq k t (t + 2) := h2
    have hdvd : k ∣ 2 := by
      have h := (Nat.modEq_iff_dvd' (by omega : t ≤ t + 2)).mp hmod
      simpa using h
    have := Nat.le_of_dvd (by norm_num) hdvd
    omega
  · have e1 : p (c (t + 1)) ≤ p (c t) := hp.monotone (by rw [hstep]; exact hmin _)
    have e2 : p (c (t + 1)) ≤ p (c (t + 2)) := hp.monotone (by rw [hstep]; exact hmin _)
    have a1 := hadj t
    have a2 := hadj (t + 1)
    have ht2 : t + 1 + 1 = t + 2 := by omega
    rw [ht2] at a2
    rw [abs_le] at a1 a2 ⊢
    constructor <;> linarith [a1.1, a1.2, a2.1, a2.2]

/-- **No chordless cycles in the prime Rips graph.**  At every scale `ε`, a cycle of
length `≥ 4` in the Vietoris–Rips graph of the prime point cloud must have a chord.
So the prime cloud creates no minimal one-cycle at any scale: the conjectured `H₁`
bars at scale `(log x)²` — and in particular a "twin prime `H₁` bar" — do not exist. -/
theorem prime_no_chordless_cycle {ε : ℝ} {k : ℕ} (hk : 4 ≤ k) {c : ℕ → ℕ}
    (hper : ∀ i, c (i + k) = c i) (hinj : ∀ i < k, ∀ j < k, c i = c j → i = j)
    (hadj : ∀ i, RipsAdj P ε (c i) (c (i + 1)))
    (hchordless : ∀ t, ¬ RipsAdj P ε (c t) (c (t + 2))) : False := by
  obtain ⟨t, -, hchord⟩ :=
    cycle_has_two_step_chord P_strictMono hk hper hinj (fun i => hadj i)
  exact hchordless t hchord

/-- The prime Rips graph does have chords to find: at scale `ε ≥ 4` the three
consecutive primes `3, 5, 7` form a triangle, so the chord statement above is not
vacuous. -/
theorem prime_triangle_at_scale_four : RipsAdj P 4 1 3 := by
  have h1 : P 1 = 3 := by simp [P]
  have h3 : P 3 = 7 := by
    have h7 : Nat.nth Nat.Prime 3 = 7 := by simp
    simp [P, h7]
  unfold RipsAdj
  rw [h1, h3]
  rw [abs_le]
  constructor <;> norm_num

end PrimeTopology