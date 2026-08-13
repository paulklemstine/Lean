import Pythagorean.FactoringBarriers.Dequant.CombSpectrum
import Pythagorean.FactoringBarriers.Dequant.OrderToFactor
import Pythagorean.FactoringBarriers.Dequant.SchmidtRank
import Pythagorean.FactoringBarriers.Dequant.ProbeComplexity
import Pythagorean.FactoringBarriers.Dequant.CombDistance

/-!
# Barrier IV, synthesis: the de-quantization frontier, closed

This file assembles the four parts into the single statement the assessment paper
argues informally, and pins down concrete machine-checked instances.

* `Dequant.sampled_frequency_yields_factor` — **the forward half of the
  equivalence**: a sampled frequency accurate to `1/(2R²)` determines the order
  uniquely and hence, through one gcd, a nontrivial factor of `N`.  A poly-time
  exact sampler of Shor's output distribution *is* a poly-time factoring algorithm.
* `Dequant.dequantization_frontier_closed` — **the reverse half**: for one and the
  same instance, (i) every probe below `r` is uninformative, (ii) the state's
  Schmidt rank is exactly `r`, (iii) every `k`-sparse surrogate distribution is at
  total variation `≥ 1 - k/r` from the true output distribution, (iv) the output
  distribution is flat with entropy `log r`, and (v) knowing `r` factors `N`.
  Every listed de-quantization route must therefore pay `Ω(r)`.

## Lab notes (machine-checked instances)

| instance                  | quantity                     | value            |
|---------------------------|------------------------------|------------------|
| `N = 15, b = 2`           | `ord`                        | `4`              |
| `N = 15, b = 2`           | `gcd(2^{r/2} - 1, 15)`       | `3` (nontrivial) |
| `N = 21, b = 2`           | `ord`                        | `6`              |
| `N = 21, b = 2`           | `gcd(2^{r/2} - 1, 21)`       | `7` (nontrivial) |
| `N = 31 = 2^5 - 1, b = 2` | `ord`                        | `5`              |
| `Q = 16, r = 4`           | peak set                     | `{0, 4, 8, 12}`  |
| `Q = 16, r = 4`           | `#peaks`                     | `4 = r`          |
| `Q = 12, r = 3`           | peak set                     | `{0, 4, 8}`      |
| `Q = 48, r = 3` vs `16`   | `TV` between the two combs   | `15/16`          |
-/

namespace Dequant

open Finset

/-! ### The forward half: a sample yields the order, and the order yields a factor -/

/-- **Sampling the output distribution factors the modulus.**  Suppose a classical
device returns a frequency `y` together with a reduced fraction `s'/r'` with
`r' ≤ R` approximating `y/Q` to within `1/(2R²)` — the standard continued-fraction
post-processing — and suppose the true order also has such an approximation (which
is exactly what the peak structure of `Dequant.combSum_eq_ite` guarantees).  Then
`r'` *is* the order, and one gcd produces a nontrivial factor of `N`. -/
theorem sampled_frequency_yields_factor {N b Q R y s s' r' : ℕ}
    (hN : 1 < N) (hrpos : 0 < ord N b) (heven : 2 ∣ ord N b)
    (hminus : ¬ (N : ℤ) ∣ (b : ℤ) ^ (ord N b / 2) + 1)
    (hrR : ord N b ≤ R) (hr'pos : 0 < r') (hr'R : r' ≤ R)
    (hc : Nat.Coprime s (ord N b)) (hc' : Nat.Coprime s' r')
    (h1 : |(y : ℝ) / Q - (s : ℝ) / (ord N b)| < 1 / (2 * (R : ℝ) ^ 2))
    (h2 : |(y : ℝ) / Q - (s' : ℝ) / r'| < 1 / (2 * (R : ℝ) ^ 2)) :
    r' = ord N b ∧
      (1 < Int.gcd ((b : ℤ) ^ (r' / 2) - 1) (N : ℤ) ∧
        Int.gcd ((b : ℤ) ^ (r' / 2) - 1) (N : ℤ) < N) := by
  obtain ⟨heq, -⟩ := order_determined_by_approx hrpos hrR hr'pos hr'R h1 h2 hc hc'
  refine ⟨heq.symm, ?_⟩
  rw [heq.symm]
  exact order_finding_splits hN hrpos heven hminus

/-! ### The reverse half: every classical route pays `Ω(r)` -/

/-- **The de-quantization frontier, closed.**  For a single order-finding instance
`(N, b)` with grid size `Q` the five obstructions hold simultaneously:

1. no probe below the order returns any information;
2. the Schmidt rank across the register cut is exactly `r`, so a bond dimension
   below `r` cannot represent the state;
3. every distribution supported on `k` outcomes is at total variation `≥ 1 - k/r`
   from the exact output distribution;
4. the exact output distribution is flat with Shannon entropy `log r`;
5. and the order, once known, factors `N` with a single gcd.

Together: observation is free, but every extraction route is `Ω(r)`-sealed, while
the *only* thing an extraction would buy — the order — is already equivalent to a
factorisation. -/
theorem dequantization_frontier_closed {N b Q k : ℕ} [NeZero N] (hN : 1 < N)
    (hQ : 0 < Q) (hrpos : 0 < ord N b) (hdvd : ord N b ∣ Q) (heven : 2 ∣ ord N b)
    (hminus : ¬ (N : ℤ) ∣ (b : ℤ) ^ (ord N b / 2) + 1)
    (D : DistOn (Finset.range Q)) (S : Finset ℕ) (hcard : S.card ≤ k)
    (hsupp : ∀ y ∈ Finset.range Q, y ∉ S → D.p y = 0) :
    (∀ t : ℕ, 0 < t → t < ord N b → ¬ probe N b t) ∧
    (shorMatrix N b Q).rank = ord N b ∧
    (1 - (k : ℝ) / (ord N b) ≤ tv (combDist hrpos hQ hdvd) D) ∧
    (∑ y ∈ peaks Q (ord N b), (-(combPMF Q (ord N b) y) * Real.log (combPMF Q (ord N b) y))
      = Real.log (ord N b)) ∧
    (1 < Int.gcd ((b : ℤ) ^ (ord N b / 2) - 1) (N : ℤ) ∧
      Int.gcd ((b : ℤ) ^ (ord N b / 2) - 1) (N : ℤ) < N) := by
  refine ⟨fun t ht htr => probe_false_below_order ht htr,
    shorMatrix_rank_eq_order hrpos hdvd hQ,
    sparse_approx_lower_bound hrpos hQ hdvd D S hcard hsupp,
    combDist_entropy hrpos hQ hdvd,
    order_finding_splits hN hrpos heven hminus⟩

/-! ### Lab notes: machine-checked instances -/

/-- Data point: `ord_15(2) = 4`.  The probe fires at `4` and not at `2`. -/
theorem ord_15_2 : ord 15 2 = 4 := by
  have h4 : ord 15 2 ∣ 4 := (probe_iff_ord_dvd 15 2 4).mp (by decide)
  have hn2 : ¬ (ord 15 2 ∣ 2) := by
    intro h
    have hp : probe 15 2 2 := (probe_iff_ord_dvd 15 2 2).mpr h
    revert hp
    decide
  generalize hgen : ord 15 2 = d at h4 hn2
  have hd0 : 0 < d := Nat.pos_of_dvd_of_pos h4 (by norm_num)
  have hd4 : d ≤ 4 := Nat.le_of_dvd (by norm_num) h4
  interval_cases d <;> revert h4 hn2 <;> decide

/-- Data point: `ord_21(2) = 6`. -/
theorem ord_21_2 : ord 21 2 = 6 := by
  have h6 : ord 21 2 ∣ 6 := (probe_iff_ord_dvd 21 2 6).mp (by decide)
  have hn3 : ¬ (ord 21 2 ∣ 3) := by
    intro h
    have hp : probe 21 2 3 := (probe_iff_ord_dvd 21 2 3).mpr h
    revert hp
    decide
  have hn2 : ¬ (ord 21 2 ∣ 2) := by
    intro h
    have hp : probe 21 2 2 := (probe_iff_ord_dvd 21 2 2).mpr h
    revert hp
    decide
  generalize hgen : ord 21 2 = d at h6 hn3 hn2
  have hd0 : 0 < d := Nat.pos_of_dvd_of_pos h6 (by norm_num)
  have hd6 : d ≤ 6 := Nat.le_of_dvd (by norm_num) h6
  interval_cases d <;> revert h6 hn3 hn2 <;> decide

/-- Data point: `ord_31(2) = 5`, an instance of the Mersenne realisation
`Dequant.ord_two_mersenne`; the seal applies at every scale. -/
theorem ord_31_2 : ord 31 2 = 5 := by
  have h : (31 : ℕ) = 2 ^ 5 - 1 := by norm_num
  rw [h]
  exact ord_two_mersenne (by norm_num)

/-- Data point: the order-finding split for `N = 15`, `b = 2` really produces the
factor `3`. -/
theorem split_15 : 1 < Int.gcd ((2 : ℤ) ^ (ord 15 2 / 2) - 1) (15 : ℤ) ∧
    Int.gcd ((2 : ℤ) ^ (ord 15 2 / 2) - 1) (15 : ℤ) < 15 := by
  refine order_finding_splits (by norm_num) ?_ ?_ ?_
  · rw [ord_15_2]; norm_num
  · rw [ord_15_2]; norm_num
  · rw [ord_15_2]
    decide

/-- …and the split is the honest factor `3` of `15`. -/
theorem split_15_value : Int.gcd ((2 : ℤ) ^ (ord 15 2 / 2) - 1) (15 : ℤ) = 3 := by
  rw [ord_15_2]
  decide

/-- Data point: the order-finding split for `N = 21`, `b = 2` produces the factor
`7`. -/
theorem split_21_value : Int.gcd ((2 : ℤ) ^ (ord 21 2 / 2) - 1) (21 : ℤ) = 7 := by
  rw [ord_21_2]
  decide

/-- Data point: for `Q = 16` and order `r = 4` the informative frequencies are the
multiples of `Q/r = 4`. -/
theorem peaks_16_4 : peaks 16 4 = {0, 4, 8, 12} := by decide

/-- …and there are exactly `r = 4` of them, as `Dequant.card_peaks` predicts. -/
theorem card_peaks_16_4 : (peaks 16 4).card = 4 := by decide

/-- Data point: `Q = 12`, `r = 3`, spacing `4`. -/
theorem peaks_12_3 : peaks 12 3 = {0, 4, 8} := by decide

/-- **Non-vacuity check.**  All the hypotheses of the synthesis theorem are met by a
concrete instance: `N = 15`, `b = 2`, `Q = 4`.  Its Schmidt rank is `4`, its comb
has `4` peaks, and the order-finding split returns the factor `3`. -/
theorem frontier_instance_15 :
    (shorMatrix 15 2 4).rank = 4 ∧ (peaks 4 4).card = 4 ∧
      Int.gcd ((2 : ℤ) ^ (ord 15 2 / 2) - 1) (15 : ℤ) = 3 := by
  haveI : NeZero (15 : ℕ) := ⟨by norm_num⟩
  refine ⟨?_, ?_, split_15_value⟩
  · rw [shorMatrix_rank_eq_order (by rw [ord_15_2]; norm_num)
      (by rw [ord_15_2]) (by norm_num), ord_15_2]
  · exact card_peaks (by norm_num) (by norm_num) dvd_rfl

/-- Data point: on the grid `Q = 48` the output distributions of the coprime orders
`3` and `16` are at total variation exactly `15/16`, as `Dequant.tv_comb_comb`
predicts (`1 - gcd(3,16)/16`). -/
theorem tv_48_3_16 :
    tv (combDist (Q := 48) (r := 3) (by norm_num) (by norm_num) (by norm_num))
      (combDist (Q := 48) (r := 16) (by norm_num) (by norm_num) (by norm_num))
      = 1 - 1 / 16 := by
  rw [tv_comb_comb (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)]
  norm_num

end Dequant