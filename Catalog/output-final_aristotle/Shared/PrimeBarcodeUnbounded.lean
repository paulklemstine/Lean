/-
# The prime barcode has unboundedly many bars: growth of the Betti curve

This file deepens `Shared/PrimeBarcodeInvariants.lean`, where the zero-dimensional
Vietoris–Rips barcode of the prime point cloud `P n = p_n = nth Nat.Prime n` was
shown to be governed by the prime gap sequence, with

  `bettiZero P ε n = 1 + #{ i < n : ε < p_{i+1} − p_i }`   (the Betti staircase).

Those results describe the barcode for a *fixed* number of points.  Here we study
the asymptotics in `n`, for a *fixed* resolution `ε`, and connect the topology to
the classical elementary fact that prime gaps are unbounded.

## Main results

* `factorial_add_not_prime` — the composite-run lemma: for `2 ≤ j ≤ N` the number
  `N! + j` is composite, giving runs of arbitrarily many consecutive composites.

* `exists_large_primeGap` — **prime gaps are unbounded, infinitely often**: for every
  bound `B` and every `M` there is an index `n ≥ M` with `B < primeGap n`.

* `setOf_primeGap_gt_infinite` — for every `c` the index set `{n : c < primeGap n}`
  is infinite.

* `prime_bettiZero_unbounded` / `prime_bettiZero_tendsto_atTop` — at every fixed
  resolution `ε ≥ 0` the prime Betti curve `n ↦ bettiZero P ε n` is unbounded and in
  fact tends to `+∞`.  Topologically: no matter how coarse the scale, the number of
  connected components of the prime cloud grows without bound as primes are added.

* `prime_eventually_disconnected` — the negative global-merge statement: for every
  resolution `ε` there is an `n` with `bettiZero P ε n > 1`; there is no single scale
  that keeps the infinite prime cloud connected.

* `prime_totalPersistence_tendsto_atTop` — the total persistence `p_n − 2` diverges.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The `PrimeBarcodeInvariants` cycle fixed the number of
points and read off the Betti staircase.  The natural deepening is the limit `n → ∞`:
each downward step of the Betti curve is a gap crossing `ε`, so the curve is unbounded
iff infinitely many gaps exceed `ε`, i.e. iff prime gaps are unbounded.

Experiment (Experimenter).  Prime gaps are unbounded by Euclid's composite run:
`N! + 2, …, N! + N` are all composite, so the consecutive prime gap straddling that
run is `≥ N`.  Placing the run past `nth Prime M` forces the offending index `≥ M`,
giving the "infinitely often" strengthening `exists_large_primeGap`.

Analysis (Analyst).  From `exists_large_primeGap` the set `{n : c < primeGap n}` is
infinite; counting its members below `n` and comparing with the real-valued filter of
`prime_bettiZero_eq` shows the component count is unbounded, and monotonicity in `n`
upgrades this to `Tendsto … atTop atTop`.

Critique (Critic).  The composite-run lemma is proved from divisibility, not asserted;
the gaps result is the genuine "infinitely often" version, not a single large gap; and
the barcode consequence is derived through the already-proved Betti staircase, so no
step is circular.

Synthesis (PI).  "The prime cloud shatters at every scale": for arbitrarily coarse
`ε`, the zero-dimensional barcode has arbitrarily many bars, and there is no global
merge scale for the full infinite cloud.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Shared.PrimeBarcodeInvariants

open scoped Classical
open Filter

namespace PrimeBarcode

open PrimePH TwinPrimeGaps

/-! ### Unboundedness of prime gaps -/

/-- Composite-run lemma: for `2 ≤ j ≤ N`, the number `N! + j` is not prime, since
`j ∣ N!` and hence `j ∣ (N! + j)` with `1 < j < N! + j`. -/
theorem factorial_add_not_prime {N j : ℕ} (hj2 : 2 ≤ j) (hjN : j ≤ N) :
    ¬ (Nat.factorial N + j).Prime := by
  intro hp
  have hjdvd : j ∣ Nat.factorial N := Nat.dvd_factorial (by omega) hjN
  have hdvd : j ∣ (Nat.factorial N + j) := Nat.dvd_add hjdvd (dvd_refl j)
  rcases (hp.eq_one_or_self_of_dvd j hdvd) with h | h
  · omega
  · have : 0 < Nat.factorial N := Nat.factorial_pos N; omega

/-- **Prime gaps are unbounded, infinitely often.**  For every bound `B` and every
`M` there is an index `n ≥ M` whose prime gap exceeds `B`.

The construction places a run of consecutive composites `N! + 2, …, N! + N` (with
`N` chosen larger than both `B` and `nth Prime M`) past the `M`-th prime; the
consecutive prime gap straddling that run has length `≥ N > B` at an index `≥ M`. -/
theorem exists_large_primeGap (B M : ℕ) : ∃ n, M ≤ n ∧ B < primeGap n := by
  have hinf := Nat.infinite_setOf_prime
  set N := B + Nat.nth Nat.Prime M + 2 with hN
  have hNfact : N ≤ Nat.factorial N := Nat.self_le_factorial N
  have hnthM_lt : Nat.nth Nat.Prime M < Nat.factorial N + 2 := by omega
  have hkM : M < Nat.count Nat.Prime (Nat.factorial N + 2) :=
    (Nat.lt_nth_iff_count_lt hinf).2 hnthM_lt
  obtain ⟨n, hn_eq⟩ : ∃ n, Nat.count Nat.Prime (Nat.factorial N + 2) = n + 1 :=
    ⟨Nat.count Nat.Prime (Nat.factorial N + 2) - 1, by omega⟩
  have hnM : M ≤ n := by omega
  have hn_lt : Nat.nth Nat.Prime n < Nat.factorial N + 2 :=
    (Nat.lt_nth_iff_count_lt hinf).1 (by rw [hn_eq]; omega)
  have hn1_ge : Nat.factorial N + 2 ≤ Nat.nth Nat.Prime (n + 1) := by
    by_contra h
    push_neg at h
    have := (Nat.lt_nth_iff_count_lt hinf).2 h
    rw [hn_eq] at this
    omega
  have hprime : (Nat.nth Nat.Prime (n + 1)).Prime := Nat.prime_nth_prime _
  have hn1_big : Nat.factorial N + N + 1 ≤ Nat.nth Nat.Prime (n + 1) := by
    by_contra h
    push_neg at h
    set q := Nat.nth Nat.Prime (n + 1) with hq
    have heq : Nat.factorial N + (q - Nat.factorial N) = q := by omega
    have hnp := factorial_add_not_prime (N := N) (j := q - Nat.factorial N)
      (by omega) (by omega)
    exact hnp (heq.symm ▸ hprime)
  refine ⟨n, hnM, ?_⟩
  have hpg : primeGap n = Nat.nth Nat.Prime (n + 1) - Nat.nth Nat.Prime n := rfl
  rw [hpg]; omega

/-- The set of indices whose prime gap exceeds `c` is infinite. -/
theorem setOf_primeGap_gt_infinite (c : ℕ) : {n : ℕ | c < primeGap n}.Infinite := by
  rw [Set.infinite_iff_exists_gt]
  intro a
  obtain ⟨n, hn, hgap⟩ := exists_large_primeGap c (a + 1)
  exact ⟨n, hgap, by omega⟩

/-! ### Growth of the Betti curve -/

/-- The Betti number is monotone in the number of points `n`. -/
theorem bettiZero_mono_n (p : ℕ → ℝ) (ε : ℝ) : Monotone (bettiZero p ε) := by
  intro m n hmn
  rw [bettiZero_eq, bettiZero_eq]
  gcongr

/-- The number of prime gaps exceeding `c` among the first `n` indices is unbounded. -/
theorem gapCount_unbounded (c M : ℕ) :
    ∃ n, M ≤ ((Finset.range n).filter (fun i => c < primeGap i)).card := by
  induction M with
  | zero => exact ⟨0, by simp⟩
  | succ M ih =>
    obtain ⟨n, hn⟩ := ih
    obtain ⟨m, hmn, hgap⟩ := exists_large_primeGap c n
    refine ⟨m + 1, ?_⟩
    have hsub : insert m ((Finset.range n).filter (fun i => c < primeGap i)) ⊆
        (Finset.range (m + 1)).filter (fun i => c < primeGap i) := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_filter, Finset.mem_range] at hx ⊢
      rcases hx with rfl | ⟨hxr, hxg⟩
      · exact ⟨by omega, hgap⟩
      · exact ⟨by omega, hxg⟩
    have hnotin : m ∉ (Finset.range n).filter (fun i => c < primeGap i) := by
      simp only [Finset.mem_filter, Finset.mem_range]; omega
    calc M + 1 ≤ ((Finset.range n).filter (fun i => c < primeGap i)).card + 1 := by omega
      _ = (insert m ((Finset.range n).filter (fun i => c < primeGap i))).card :=
            (Finset.card_insert_of_notMem hnotin).symm
      _ ≤ _ := Finset.card_le_card hsub

/-- **The prime Betti curve is unbounded.**  For every resolution `ε` and every `M`
there is an `n` with `M ≤ bettiZero P ε n`. -/
theorem prime_bettiZero_unbounded (ε : ℝ) (M : ℕ) : ∃ n, M ≤ bettiZero P ε n := by
  obtain ⟨n, hn⟩ := gapCount_unbounded ⌈ε⌉₊ M
  refine ⟨n, ?_⟩
  rw [prime_bettiZero_eq]
  have hsub : (Finset.range n).filter (fun i => ⌈ε⌉₊ < primeGap i) ⊆
      (Finset.range n).filter (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ)) := by
    intro x hx
    simp only [Finset.mem_filter] at hx ⊢
    refine ⟨hx.1, ?_⟩
    have hcast : (⌈ε⌉₊ : ℝ) < (TwinPrimeGaps.primeGap x : ℝ) := by exact_mod_cast hx.2
    exact lt_of_le_of_lt (Nat.le_ceil ε) hcast
  have := Finset.card_le_card hsub
  omega

/-- **The prime Betti curve tends to infinity.**  At every fixed resolution `ε`, the
number of `ε`-connected components of the prime cloud tends to `+∞` as points are
added. -/
theorem prime_bettiZero_tendsto_atTop (ε : ℝ) :
    Filter.Tendsto (fun n => bettiZero P ε n) Filter.atTop Filter.atTop := by
  refine tendsto_atTop_atTop_of_monotone (bettiZero_mono_n P ε) ?_
  intro b
  exact prime_bettiZero_unbounded ε b

/-- **No global merge scale.**  For every resolution `ε` there is an `n` at which the
prime cloud has more than one `ε`-component: the infinite prime cloud cannot be held
connected at any fixed scale. -/
theorem prime_eventually_disconnected (ε : ℝ) : ∃ n, 1 < bettiZero P ε n := by
  obtain ⟨n, hn⟩ := prime_bettiZero_unbounded ε 2
  exact ⟨n, by omega⟩

/-! ### Divergence of total persistence -/

/-- **Total persistence diverges.**  The aggregate persistence `p_n − 2` of the prime
barcode tends to `+∞`. -/
theorem prime_totalPersistence_tendsto_atTop :
    Filter.Tendsto (fun n => totalPersistence P n) Filter.atTop Filter.atTop := by
  have hfun : (fun n => totalPersistence P n)
      = fun n => ((Nat.nth Nat.Prime n : ℝ) - 2) := by
    funext n; rw [prime_totalPersistence]
  rw [hfun]
  have h1 : Filter.Tendsto (fun n => Nat.nth Nat.Prime n) Filter.atTop Filter.atTop :=
    (Nat.nth_strictMono Nat.infinite_setOf_prime).tendsto_atTop
  have h2 : Filter.Tendsto (fun n => (Nat.nth Nat.Prime n : ℝ)) Filter.atTop Filter.atTop :=
    tendsto_natCast_atTop_atTop.comp h1
  simpa only [sub_eq_add_neg] using Filter.tendsto_atTop_add_const_right _ (-2 : ℝ) h2

end PrimeBarcode