/-
# Correlations in the prime barcode: adjacent twin bars are forbidden

Third instalment of the persistent-homology-of-primes thread, building on
`Computation/PrimeBarcodePoissonObstruction.lean` (quantisation of the `H₀` barcode
and the refutation of the exponential/Poisson law for bar *lengths*) and on the
catalog files `Novelty/PrimePersistentHomology.lean`,
`Novelty/PrimeBarcodeInvariants.lean`.

A Poisson point process has *independent* bar lengths.  Even after one accepts the
quantisation of the prime barcode, the Poisson heuristic makes a second, testable
prediction: consecutive bars should be independent, so two adjacent bars of length
`2` (two adjacent twin merges) should occur with positive frequency.  We prove that
this **never** happens past the very beginning of the barcode: the prime barcode has
a hard exclusion rule, coming from divisibility by `3`.

## Main results

* `PrimeBarcodeCorr.gap_pair_mod_three` — the mod-3 law: for `i ≥ 2`, one of `g_i`,
  `g_{i+1}`, `g_i + g_{i+1}` is divisible by `3`; consequently two adjacent bars of
  equal length `d` force `3 ∣ d` (`repeated_gap_dvd_three`), ruling out the patterns
  `(2,2)` and `(4,4)`.

* `PrimeBarcodeCorr.exists_block_dvd` — the general mod-`q` law: for every prime `q`
  and every start index past `q`, some contiguous block of fewer than `q` bars has
  total length divisible by `q`.  With `constant_gap_run_dvd` this forbids any run of
  `q − 1` equal bars whose common length is prime to `q` (e.g. no four consecutive
  twin bars, `no_four_consecutive_twin_bars`).

* `PrimeBarcodeCorr.no_two_consecutive_twin_bars` — for `i ≥ 2` the bars `i` and
  `i+1` are never both of length `2`; the only occurrence of two adjacent twin bars
  in the whole barcode is at the very start, `3, 5, 7`.

* `PrimeBarcodeCorr.adjacentTwinBars_eq_zero` — the number of adjacent twin-bar pairs
  past the start is exactly `0`, at every truncation.

* `PrimeBarcodeCorr.iid_model_refuted` — the refutation: any model in which bars are
  independent with `P(length = 2) = q > 0` predicts `(n−1)q² > 0` adjacent twin pairs,
  while the primes have none.  So the prime barcode is not only non-exponential, it is
  not even an independent-increment (Poisson) process.

* `PrimeBarcodeCorr.twinStep_le_half` — a hard cap on the `ε = 2` Betti step:
  `twinStep n ≤ n/2 + 3`, i.e. at most about half of the first `n` bars can be twin
  bars, a constraint absent from any i.i.d. model.

* `PrimeBarcodeCorr.bar_spectrum_separated` — the quantitative form of quantisation:
  every prime bar length is at distance at least `1` from every odd integer `≥ 3`, so
  the refutation survives perturbing the barcode by less than `1/2` in the bottleneck
  metric.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  If the prime barcode were Poisson, bar lengths would be
independent; in particular adjacent twin bars would occur at frequency `q²`.  We
conjecture instead a hard arithmetic exclusion.

Experiment (Experimenter).  Sieving the barcode to `2·10⁵` (17984 bars) and tabulating
adjacent bar-length pairs: `(2,2)` occurs exactly once, at index `1` (the triple
`3,5,7`), and never again; `(4,4)` and `(8,8)` never occur at all; by contrast
`(2,4)`, `(4,2)`, `(2,6)` occur 416, 424, 379 times, and the repeated pattern `(6,6)`
— allowed, since `3 ∣ 6` — occurs 544 times.  This is exactly the mod-3 law: a
repeated bar length must be a multiple of `3`.

Experiment (Experimenter).  For `p ≥ 5` prime, one of `p`, `p+2`, `p+4` is divisible
by `3`; since `p ≥ 5` this forces the divisible one to be composite.  Formalising
this via `Nat.nth Nat.Prime` gives `no_two_consecutive_twin_bars`, whence the
adjacent-pair count vanishes identically.  A `i ↦ i/2` injection turns the exclusion
into the cap `twinStep n ≤ n/2 + 3`.

Analysis (Analyst).  The exclusion is a *pair correlation* statement: the barcode's
two-point function vanishes on the diagonal pattern `(2,2)`, while a Poisson barcode
has a positive two-point function everywhere.  Combined with the atomicity results of
the previous file this shows the failure of the Poisson model is structural at every
order, not just in the marginal law.

Critique (Critic).  The statement excludes `i < 2` because the barcode really does
contain one adjacent twin pair, at `3, 5, 7` (bars `1` and `2`); the theorem is sharp,
and the guard `2 ≤ i` is necessary, not cosmetic.

Synthesis (PI).  The prime barcode is a *correlated*, quantised point pattern; the
`ε = 2` merges repel each other, and this repulsion is one member of an infinite family
of mod-`q` block laws obtained by pigeonhole on prime residues.  Twin primes remain an `H₀` question, but their
merges can never be adjacent.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Computation.PrimeBarcodePoissonObstruction

open scoped Classical

namespace PrimeBarcodeCorr

open PrimePH PrimeBarcode TwinPrimeGaps PrimeTopology

/-! ## The exclusion rule -/

/-- **The mod-3 law of the prime barcode.**  For every `i ≥ 2` at least one of the two
consecutive bar lengths `g_i`, `g_{i+1}`, or their sum, is divisible by `3`.  Reason:
`p`, `p + g_i`, `p + g_i + g_{i+1}` are three primes `> 3`, so their residues mod `3`
lie in `{1, 2}` and two of them must coincide. -/
theorem gap_pair_mod_three {i : ℕ} (hi : 2 ≤ i) :
    3 ∣ primeGap i ∨ 3 ∣ primeGap (i + 1) ∨ 3 ∣ (primeGap i + primeGap (i + 1)) := by
  have hlt1 := Nat.nth_strictMono (p := Nat.Prime) Nat.infinite_setOf_prime (Nat.lt_succ_self i)
  have hlt2 :=
    Nat.nth_strictMono (p := Nat.Prime) Nat.infinite_setOf_prime (Nat.lt_succ_self (i + 1))
  rw [show (i + 1).succ = i + 2 from rfl] at hlt2
  rw [show i.succ = i + 1 from rfl] at hlt1
  have h5 : 5 ≤ Nat.nth Nat.Prime i := by
    have h := Nat.nth_monotone (p := Nat.Prime) Nat.infinite_setOf_prime hi
    simpa using h
  have hp0 : Nat.Prime (Nat.nth Nat.Prime i) := Nat.prime_nth_prime i
  have hp1 : Nat.Prime (Nat.nth Nat.Prime (i + 1)) := Nat.prime_nth_prime (i + 1)
  have hp2 : Nat.Prime (Nat.nth Nat.Prime (i + 2)) := Nat.prime_nth_prime (i + 2)
  have n0 : ¬ (3 ∣ Nat.nth Nat.Prime i) := by
    intro hd; rcases hp0.eq_one_or_self_of_dvd 3 hd with h | h <;> omega
  have n1 : ¬ (3 ∣ Nat.nth Nat.Prime (i + 1)) := by
    intro hd; rcases hp1.eq_one_or_self_of_dvd 3 hd with h | h <;> omega
  have n2 : ¬ (3 ∣ Nat.nth Nat.Prime (i + 2)) := by
    intro hd; rcases hp2.eq_one_or_self_of_dvd 3 hd with h | h <;> omega
  have e1 : primeGap i = Nat.nth Nat.Prime (i + 1) - Nat.nth Nat.Prime i := rfl
  have e2 : primeGap (i + 1) = Nat.nth Nat.Prime (i + 2) - Nat.nth Nat.Prime (i + 1) := by
    show Nat.nth Nat.Prime (i + 1 + 1) - _ = _
    norm_num
  omega

/-- **Repeated bar lengths are multiples of 3.**  Past the start of the barcode, two
adjacent bars of equal length `g` force `3 ∣ g`. -/
theorem repeated_gap_dvd_three {i : ℕ} (hi : 2 ≤ i) (h : primeGap i = primeGap (i + 1)) :
    3 ∣ primeGap i := by
  rcases gap_pair_mod_three hi with hd | hd | hd
  · exact hd
  · exact h ▸ hd
  · rw [← h] at hd
    omega

/-- **No two adjacent twin bars.**  For `i ≥ 2` the `i`-th and `(i+1)`-st bars of the
prime barcode are never both of length `2`: `p, p+2, p+4` cannot all be prime once
`p ≥ 5`, since one of them is divisible by `3`.  A special case of the mod-3 law. -/
theorem no_two_consecutive_twin_bars {i : ℕ} (hi : 2 ≤ i) :
    ¬ (primeGap i = 2 ∧ primeGap (i + 1) = 2) := by
  rintro ⟨h1, h2⟩
  have := repeated_gap_dvd_three hi (by rw [h1, h2])
  rw [h1] at this
  omega

/-- **No two adjacent bars of length 4.**  The exclusion is not special to twins: the
pattern `(4, 4)`, i.e. a prime triple `p, p+4, p+8`, never occurs past the start. -/
theorem no_two_consecutive_cousin_bars {i : ℕ} (hi : 2 ≤ i) :
    ¬ (primeGap i = 4 ∧ primeGap (i + 1) = 4) := by
  rintro ⟨h1, h2⟩
  have := repeated_gap_dvd_three hi (by rw [h1, h2])
  rw [h1] at this
  omega

/-- The exclusion is sharp: the barcode *does* contain one adjacent twin pair, the
bars of `3 → 5` and `5 → 7`. -/
theorem adjacent_twin_bars_at_start : primeGap 1 = 2 ∧ primeGap 2 = 2 := by
  constructor <;> · unfold primeGap; simp

/-! ## The vanishing pair-correlation count -/

/-- The number of adjacent twin-bar pairs among the first `n` bars, past the start. -/
noncomputable def adjacentTwinBars (n : ℕ) : ℕ :=
  ((Finset.range n).filter
    (fun i => 2 ≤ i ∧ primeGap i = 2 ∧ primeGap (i + 1) = 2)).card

/-- **The pair-correlation count vanishes identically.** -/
theorem adjacentTwinBars_eq_zero (n : ℕ) : adjacentTwinBars n = 0 := by
  unfold adjacentTwinBars
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro i - ⟨hi, h1, h2⟩
  exact no_two_consecutive_twin_bars hi ⟨h1, h2⟩

/-- **Refutation of the independence (Poisson) hypothesis.**  A model in which bar
lengths are independent with `P(length = 2) = q > 0` predicts `(n−1)q² > 0` adjacent
twin-bar pairs among the first `n` bars; the prime barcode has exactly none. -/
theorem iid_model_refuted {q : ℝ} (hq : 0 < q) {n : ℕ} (hn : 2 ≤ n) :
    (adjacentTwinBars n : ℝ) = 0 ∧ 0 < ((n : ℝ) - 1) * q ^ 2 := by
  refine ⟨by rw [adjacentTwinBars_eq_zero n]; norm_num, ?_⟩
  have h1 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h2 : 0 < q ^ 2 := by positivity
  nlinarith

/-! ## A hard cap on the `ε = 2` Betti step -/

/-- A subset of `range n` with no two consecutive elements past `2` has at most
`n/2 + 3` elements. -/
theorem card_no_consec_le (n : ℕ) (S : Finset ℕ) (hS : S ⊆ Finset.range n)
    (hno : ∀ i, 2 ≤ i → i ∈ S → i + 1 ∉ S) : S.card ≤ n / 2 + 3 := by
  classical
  set S' := S.filter (fun i => 2 ≤ i) with hS'
  have hsplit : S.card ≤ S'.card + 2 := by
    have h : S ⊆ S' ∪ {0, 1} := by
      intro x hx
      rcases lt_or_ge x 2 with h | h
      · simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton]
        right; omega
      · exact Finset.mem_union_left _ (Finset.mem_filter.mpr ⟨hx, h⟩)
    have h1 := Finset.card_le_card h
    have h2 : (S' ∪ {0, 1}).card ≤ S'.card + ({0, 1} : Finset ℕ).card :=
      Finset.card_union_le _ _
    have h3 : ({0, 1} : Finset ℕ).card = 2 := by decide
    omega
  have hinj : Set.InjOn (fun i => i / 2) (S' : Set ℕ) := by
    intro a ha b hb hab
    simp only at hab
    simp only [hS', Finset.coe_filter, Set.mem_setOf_eq] at ha hb
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · have hb' : b = a + 1 := by omega
      exact hno a ha.2 ha.1 (hb' ▸ hb.1)
    · have ha' : a = b + 1 := by omega
      exact hno b hb.2 hb.1 (ha' ▸ ha.1)
  have hmaps : ∀ i ∈ S', i / 2 ∈ Finset.range (n / 2 + 1) := by
    intro i hi
    have h1 : i ∈ S := (Finset.mem_filter.mp hi).1
    have h2 : i < n := Finset.mem_range.mp (hS h1)
    simp only [Finset.mem_range]
    omega
  have hcard : S'.card ≤ (Finset.range (n / 2 + 1)).card :=
    Finset.card_le_card_of_injOn (fun i => i / 2) (fun i hi => hmaps i hi) hinj
  have h4 : (Finset.range (n / 2 + 1)).card = n / 2 + 1 := Finset.card_range _
  omega

/-- **A cap on the twin Betti step.**  At most about half of the first `n` bars of the
prime barcode can be twin bars: `b₀(1,n) − b₀(2,n) ≤ n/2 + 3`.  No i.i.d. model obeys
such a deterministic constraint. -/
theorem twinStep_le_half (n : ℕ) : twinStep n ≤ n / 2 + 3 := by
  rw [twinStep_eq_card n]
  refine card_no_consec_le n _ (Finset.filter_subset _ _) ?_
  intro i hi hmem hmem'
  simp only [Finset.mem_filter] at hmem hmem'
  exact no_two_consecutive_twin_bars hi ⟨hmem.2, hmem'.2⟩

/-! ## Quantitative separation of the bar spectrum -/

/-- **Robust quantisation.**  Every prime bar length is at distance at least `1` from
every odd integer `2k+1 ≥ 3`.  Hence the refutation of the continuous models is stable:
it survives any perturbation of the barcode of size `< 1/2` in the bottleneck metric. -/
theorem bar_spectrum_separated (i : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    1 ≤ |P (i + 1) - P i - (2 * (k : ℝ) + 1)| := by
  rw [death_scale_eq_primeGap]
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · rw [primeGap_zero]
    have hk' : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    rw [le_abs]
    right
    push_cast
    linarith
  · obtain ⟨a, ha⟩ := primeGap_even hi
    rw [ha]
    rcases le_or_gt (a + a) (2 * k) with h | h
    · have h' : ((a + a : ℕ) : ℝ) ≤ 2 * (k : ℝ) := by exact_mod_cast h
      rw [le_abs]
      right
      push_cast at h' ⊢
      linarith
    · have h' : 2 * k + 2 ≤ (a + a : ℕ) := by omega
      have h'' : 2 * (k : ℝ) + 2 ≤ ((a + a : ℕ) : ℝ) := by exact_mod_cast h'
      rw [le_abs]
      left
      push_cast at h'' ⊢
      linarith

/-! ## The general residue pigeonhole: mod-`q` laws of the barcode -/

/-- Telescoping: the primes are recovered from the barcode, `p_{i+k} = p_{i+j} + ∑ bars`. -/
lemma nth_add_sum_gaps (i j : ℕ) : ∀ k, j ≤ k →
    Nat.nth Nat.Prime (i + j) + ∑ m ∈ Finset.Ico j k, primeGap (i + m)
      = Nat.nth Nat.Prime (i + k) := by
  intro k
  induction k with
  | zero => intro h; interval_cases j; simp
  | succ n ih =>
    intro h
    rcases Nat.lt_or_ge j (n + 1) with hj | hj
    · have hjn : j ≤ n := by omega
      rw [Finset.sum_Ico_succ_top hjn, ← Nat.add_assoc, ih hjn]
      have hlt : Nat.nth Nat.Prime (i + n) < Nat.nth Nat.Prime (i + n + 1) := by
        have := Nat.nth_strictMono (p := Nat.Prime) Nat.infinite_setOf_prime
          (Nat.lt_succ_self (i + n))
        simpa [Nat.succ_eq_add_one] using this
      have hg : primeGap (i + n) = Nat.nth Nat.Prime (i + n + 1) - Nat.nth Nat.Prime (i + n) := rfl
      have hin : i + (n + 1) = i + n + 1 := by ring
      rw [hg, hin]
      omega
    · have : j = n + 1 := by omega
      subst this
      simp

/-- **The mod-`q` law of the prime barcode.**  For every prime `q` and every starting
index `i` past `q`, some contiguous block of at most `q − 1` consecutive bars has total
length divisible by `q`.  The mod-3 law above is the case `q = 3`.  The proof is a
pigeonhole on the residues of the `q` primes `p_i, …, p_{i+q-1}`, which all lie in
`{1, …, q−1}` mod `q`. -/
theorem exists_block_dvd (q : ℕ) (hq : q.Prime) {i : ℕ} (hi : q < Nat.nth Nat.Prime i) :
    ∃ j k, j < k ∧ k < q ∧ q ∣ ∑ m ∈ Finset.Ico j k, primeGap (i + m) := by
  have hq2 := hq.two_le
  have hmaps : ∀ j ∈ Finset.range q, Nat.nth Nat.Prime (i + j) % q ∈ Finset.Ico 1 q := by
    intro j _
    have hp : Nat.Prime (Nat.nth Nat.Prime (i + j)) := Nat.prime_nth_prime _
    have hmono : Nat.nth Nat.Prime i ≤ Nat.nth Nat.Prime (i + j) :=
      Nat.nth_monotone (p := Nat.Prime) Nat.infinite_setOf_prime (by omega)
    have hne : ¬ (q ∣ Nat.nth Nat.Prime (i + j)) := by
      intro hd
      rcases hp.eq_one_or_self_of_dvd q hd with h | h <;> omega
    have hne' : Nat.nth Nat.Prime (i + j) % q ≠ 0 := fun h => hne (Nat.dvd_of_mod_eq_zero h)
    have := Nat.mod_lt (Nat.nth Nat.Prime (i + j)) (show 0 < q by omega)
    simp only [Finset.mem_Ico]
    omega
  have hcard : (Finset.Ico 1 q).card < (Finset.range q).card := by
    simp [Nat.card_Ico]
    omega
  obtain ⟨a, ha, b, hb, hab, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  simp only [Finset.mem_range] at ha hb
  have heq' : Nat.nth Nat.Prime (i + a) % q = Nat.nth Nat.Prime (i + b) % q := heq
  rcases Nat.lt_or_ge a b with h | h
  · refine ⟨a, b, h, hb, ?_⟩
    have h1 := nth_add_sum_gaps i a b (le_of_lt h)
    have hle : Nat.nth Nat.Prime (i + a) ≤ Nat.nth Nat.Prime (i + b) := by omega
    have hd := (Nat.modEq_iff_dvd' hle).mp heq'
    have hs : ∑ m ∈ Finset.Ico a b, primeGap (i + m)
        = Nat.nth Nat.Prime (i + b) - Nat.nth Nat.Prime (i + a) := by omega
    rw [hs]; exact hd
  · have hba : b < a := by omega
    refine ⟨b, a, hba, ha, ?_⟩
    have h1 := nth_add_sum_gaps i b a (le_of_lt hba)
    have hle : Nat.nth Nat.Prime (i + b) ≤ Nat.nth Nat.Prime (i + a) := by omega
    have hd := (Nat.modEq_iff_dvd' hle).mp heq'.symm
    have hs : ∑ m ∈ Finset.Ico b a, primeGap (i + m)
        = Nat.nth Nat.Prime (i + a) - Nat.nth Nat.Prime (i + b) := by omega
    rw [hs]; exact hd

/-- **No long run of equal bars, unless the length is divisible by `q`.**  If `q − 1`
consecutive bars of the barcode all have the same length `d`, and the run starts past
`q`, then `q ∣ d`.  Taking `q = 3` recovers `repeated_gap_dvd_three`; taking `q = 5`
shows that four consecutive bars of length `2`, `4`, `6` or `8` are impossible. -/
theorem constant_gap_run_dvd (q : ℕ) (hq : q.Prime) {i d : ℕ} (hi : q < Nat.nth Nat.Prime i)
    (hconst : ∀ m, m < q - 1 → primeGap (i + m) = d) : q ∣ d := by
  obtain ⟨j, k, hjk, hkq, hdvd⟩ := exists_block_dvd q hq hi
  have hsum : ∑ m ∈ Finset.Ico j k, primeGap (i + m) = (k - j) * d := by
    rw [Finset.sum_congr rfl (fun m hm => hconst m (by
      simp only [Finset.mem_Ico] at hm; omega))]
    simp [Nat.card_Ico, Nat.mul_comm]
  rw [hsum] at hdvd
  rcases (Nat.Prime.dvd_mul hq).mp hdvd with h | h
  · exfalso
    have := Nat.le_of_dvd (by omega) h
    omega
  · exact h

/-- Concrete instance of the mod-5 law: past `p = 7` there is no run of four
consecutive bars all of length `2` (equivalently, no five primes in arithmetic
progression with common difference `2`). -/
theorem no_four_consecutive_twin_bars {i : ℕ} (hi : 5 < Nat.nth Nat.Prime i) :
    ¬ (∀ m, m < 4 → primeGap (i + m) = 2) := by
  intro h
  have := constant_gap_run_dvd 5 (by norm_num) hi (by simpa using h)
  omega

/-- **The `H₀` barcode is a complete invariant.**  The `n`-th prime is recovered from
the bar lengths alone: `p_n = 2 + ∑_{m < n} g_m`.  Hence the persistence diagram of the
prime point cloud determines the primes, and every arithmetic statement about primes is
a statement about the barcode. -/
theorem nth_prime_eq_two_add_sum_gaps (n : ℕ) :
    Nat.nth Nat.Prime n = 2 + ∑ m ∈ Finset.range n, primeGap m := by
  have h := nth_add_sum_gaps 0 0 n (Nat.zero_le n)
  simp only [Nat.zero_add] at h
  rw [Nat.nth_prime_zero_eq_two] at h
  rw [← h, Finset.range_eq_Ico]


end PrimeBarcodeCorr