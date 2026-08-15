import Catalog.Physics.CyclicTypeRootCountLossy

/-!
# The divisor-lattice bound on the splitting-type channel

The catalog model (`Catalog.Computation.CyclicTypeChannel`) attaches to a cyclic Galois group
`C_n` the splitting type `T(x) = n / gcd (n, x)`, whose law is the Euler-φ law
`P(T = d) = φ(d)/n` supported on the divisor lattice of `n`
(`Catalog.Computation.CyclicTypeDeterminism.HT_divisor_formula`).

This file bounds the resulting entropy `HT n` by the *combinatorics of that lattice*: the type
channel of `C_n` can never carry more than `log₂ (number of divisors of n)` bits, and — apart
from the two degenerate orders `n = 1, 2` — never as much as `log₂ n`.  Together with
`CyclicType.Hnr_le_HT` this pins the channel between the binary root-count readout and the
divisor count.

## Main results

* `CyclicType.card_divisors_lt_self` : `d(n) < n` for `n ≥ 3`.
* `CyclicType.HT_nonneg`, `CyclicType.HT_pos` : the type entropy is nonnegative, and positive
  exactly from `n = 2` on.
* `CyclicType.HT_le_logb_self`, `CyclicType.HT_lt_logb_self` : `HT n ≤ log₂ n`, strictly for
  `n ≥ 3` — the type channel is *never* the full residue channel beyond the quadratic case.
* `CyclicType.HT_le_logb_card_divisors`, `CyclicType.HT_lt_logb_card_divisors` : the
  divisor-lattice bound `HT n ≤ log₂ d(n)`, strict for `n ≥ 3`.  This is the exact sense in
  which "the divisor structure of the cyclic order governs the channel".
* `CyclicType.Hnr_le_HT_le_logb_card_divisors` : the full sandwich
  `H(nr) ≤ H(T) ≤ log₂ d(n)`.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

variable {n : ℕ}

/-! ## Combinatorics of the divisor lattice -/

/-- For every cyclic order `n ≥ 3` the divisor lattice is strictly smaller than the residue
group: `d(n) < n`.  (For `n = 1, 2` one has `d(n) = n`.) -/
theorem card_divisors_lt_self (hn : 3 ≤ n) : n.divisors.card < n := by
  have hnpos : 0 < n := by omega
  have hsub : n.divisors ⊆ Finset.Icc 1 n := by
    intro d hd
    obtain ⟨hdvd, hne⟩ := Nat.mem_divisors.1 hd
    exact Finset.mem_Icc.2 ⟨Nat.pos_of_dvd_of_pos hdvd hnpos, Nat.le_of_dvd hnpos hdvd⟩
  have hmem : n - 1 ∈ Finset.Icc 1 n := Finset.mem_Icc.2 ⟨by omega, by omega⟩
  have hnot : n - 1 ∉ n.divisors := by
    intro h
    obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 h
    have hd1 : (n - 1) ∣ (n - (n - 1)) := Nat.dvd_sub hdvd dvd_rfl
    have hrw : n - (n - 1) = 1 := by omega
    rw [hrw] at hd1
    have := Nat.le_of_dvd one_pos hd1
    omega
  have hssub : n.divisors ⊂ Finset.Icc 1 n := ⟨hsub, fun h => hnot (h hmem)⟩
  have hcard := Finset.card_lt_card hssub
  simpa [Nat.card_Icc] using hcard

/-! ## Elementary bounds -/

private lemma sum_totient_real (n : ℕ) :
    ∑ d ∈ n.divisors, ((Nat.totient d : ℝ)) = (n : ℝ) := by
  rw [← Nat.cast_sum, Nat.sum_totient]

private lemma totient_ge_two (hn : 3 ≤ n) : 2 ≤ Nat.totient n := by
  have hpos : 0 < Nat.totient n := Nat.totient_pos.2 (by omega)
  have hne : Nat.totient n ≠ 1 := by
    intro h
    rcases (Nat.totient_eq_one_iff).1 h with h1 | h2 <;> omega
  omega

/-- The type entropy is nonnegative. -/
theorem HT_nonneg (hn : 0 < n) : 0 ≤ HT n := by
  rw [HT_divisor_formula hn]
  have hterm : ∀ d ∈ n.divisors,
      (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
        ≤ (Nat.totient d : ℝ) * Real.logb 2 (n : ℝ) := by
    intro d hd
    obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hd
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hn
    have htpos : (0 : ℝ) < (Nat.totient d : ℝ) := by
      exact_mod_cast Nat.totient_pos.2 hdpos
    have hle : (Nat.totient d : ℝ) ≤ (n : ℝ) := by
      have h1 : Nat.totient d ≤ d := Nat.totient_le d
      have h2 : d ≤ n := Nat.le_of_dvd hn hdvd
      exact_mod_cast le_trans h1 h2
    exact mul_le_mul_of_nonneg_left
      (Real.logb_le_logb_of_le (by norm_num) htpos hle) htpos.le
  have hsum : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      ≤ (n : ℝ) * Real.logb 2 (n : ℝ) := by
    refine le_trans (Finset.sum_le_sum hterm) ?_
    rw [← Finset.sum_mul, sum_totient_real n]
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by
    have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    positivity
  have h := mul_le_mul_of_nonneg_left hsum hinv.le
  have hrw : 1 / (n : ℝ) * ((n : ℝ) * Real.logb 2 (n : ℝ)) = Real.logb 2 (n : ℝ) := by
    have : (n : ℝ) ≠ 0 := by positivity
    field_simp
  rw [hrw] at h
  linarith

/-- Beyond the trivial order the type channel carries strictly positive information. -/
theorem HT_pos (hn : 2 ≤ n) : 0 < HT n := by
  have hnpos : 0 < n := by omega
  refine lt_of_lt_of_le ?_ (Hnr_le_HT hnpos)
  rw [Hnr_eq_binary_entropy hnpos]
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : 1 ≤ n := by omega
    push_cast [this]; ring
  rw [hcast]
  rcases eq_or_lt_of_le hn with h2 | h3
  · -- `n = 2`: the binary entropy of `1/2` is `1`
    have hn2 : (n : ℝ) = 2 := by rw [← h2]; norm_num
    rw [hn2, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
    norm_num
  · -- `n ≥ 3`: `log₂ (n-1) > 0` and the weight `(n-1)/n` is `< 1`
    have hn3 : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast h3
    have hpos : (0 : ℝ) < (n : ℝ) := by linarith
    have hL1 : (0 : ℝ) < Real.logb 2 ((n : ℝ) - 1) :=
      Real.logb_pos (by norm_num) (by linarith)
    have hmono : Real.logb 2 ((n : ℝ) - 1) < Real.logb 2 (n : ℝ) :=
      Real.logb_lt_logb (by norm_num) (by linarith) (by linarith)
    have hlt : ((n : ℝ) - 1) / (n : ℝ) < 1 := by
      rw [div_lt_one hpos]; linarith
    nlinarith

/-! ## The `log₂ n` bound -/

/-- The type entropy never exceeds the entropy of the residue itself. -/
theorem HT_le_logb_self (hn : 0 < n) : HT n ≤ Real.logb 2 n := by
  rw [HT_divisor_formula hn]
  have hnonneg : 0 ≤ ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d) := by
    refine Finset.sum_nonneg ?_
    intro d hd
    obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hd
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hn
    have htpos : (1 : ℝ) ≤ (Nat.totient d : ℝ) := by
      exact_mod_cast Nat.totient_pos.2 hdpos
    have hlog : 0 ≤ Real.logb 2 (Nat.totient d) := Real.logb_nonneg (by norm_num) htpos
    have : (0 : ℝ) ≤ (Nat.totient d : ℝ) := by positivity
    positivity
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by
    have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    positivity
  nlinarith

/-- From `n = 3` on the type readout is a **strict** coarsening of the residue: the top divisor
level is degenerate (`φ(n) ≥ 2`), so `HT n < log₂ n`. -/
theorem HT_lt_logb_self (hn : 3 ≤ n) : HT n < Real.logb 2 n := by
  have hnpos : 0 < n := by omega
  rw [HT_divisor_formula hnpos]
  have hmem : n ∈ n.divisors := Nat.mem_divisors_self n (by omega)
  have hpos : 0 < ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d) := by
    refine Finset.sum_pos' ?_ ⟨n, hmem, ?_⟩
    · intro d hd
      obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hd
      have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hnpos
      have htpos : (1 : ℝ) ≤ (Nat.totient d : ℝ) := by
        exact_mod_cast Nat.totient_pos.2 hdpos
      have hlog : 0 ≤ Real.logb 2 (Nat.totient d) := Real.logb_nonneg (by norm_num) htpos
      have : (0 : ℝ) ≤ (Nat.totient d : ℝ) := by positivity
      positivity
    · have h2 : (2 : ℝ) ≤ (Nat.totient n : ℝ) := by exact_mod_cast totient_ge_two hn
      have hlog : 0 < Real.logb 2 (Nat.totient n) :=
        Real.logb_pos (by norm_num) (by linarith)
      have hnt : (0 : ℝ) < (Nat.totient n : ℝ) := by linarith
      positivity
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by
    have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hnpos
    positivity
  nlinarith

/-! ## The divisor-lattice bound -/

/-- The pointwise Gibbs estimate behind the divisor bound: for every divisor `d` of `n`,
`φ(d) · log (n / (φ(d) · D)) ≤ n/D − φ(d)`, where `D` is the divisor count. -/
private lemma gibbs_term (hn : 0 < n) {D : ℝ} (hD : 0 < D) {d : ℕ} (hd : d ∈ n.divisors) :
    (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d) - Real.log D)
      ≤ (n : ℝ) / D - (Nat.totient d : ℝ) := by
  obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hd
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hn
  have htpos : (0 : ℝ) < (Nat.totient d : ℝ) := by
    exact_mod_cast Nat.totient_pos.2 hdpos
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have ht : (0 : ℝ) < (n : ℝ) / ((Nat.totient d : ℝ) * D) := by positivity
  have hlog := Real.log_le_sub_one_of_pos ht
  have hexp : Real.log ((n : ℝ) / ((Nat.totient d : ℝ) * D))
      = Real.log n - Real.log (Nat.totient d) - Real.log D := by
    rw [Real.log_div (by positivity) (by positivity), Real.log_mul (by positivity)
      (by positivity)]
    ring
  rw [hexp] at hlog
  have h := mul_le_mul_of_nonneg_left hlog htpos.le
  have hrw : (Nat.totient d : ℝ) * ((n : ℝ) / ((Nat.totient d : ℝ) * D) - 1)
      = (n : ℝ) / D - (Nat.totient d : ℝ) := by
    field_simp
  linarith [h, hrw ▸ h]

/-- **The divisor-lattice bound.**  The splitting-type channel of `C_n` carries at most
`log₂ d(n)` bits, where `d(n)` is the number of divisors of `n` — i.e. the entropy is capped by
the size of the divisor lattice, exactly the set of possible splitting types. -/
theorem HT_le_logb_card_divisors (hn : 0 < n) :
    HT n ≤ Real.logb 2 (n.divisors.card) := by
  set D : ℝ := (n.divisors.card : ℝ) with hDdef
  have hne : n.divisors.Nonempty := ⟨1, Nat.one_mem_divisors.2 hn.ne'⟩
  have hDpos : 0 < D := by
    rw [hDdef]
    exact_mod_cast Finset.card_pos.2 hne
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  -- summing the Gibbs estimate
  have hsum : ∑ d ∈ n.divisors,
      (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d) - Real.log D) ≤ 0 := by
    refine le_trans (Finset.sum_le_sum (fun d hd => gibbs_term hn hDpos hd)) ?_
    have hc : (n.divisors.card : ℝ) ≠ 0 := by
      rw [hDdef] at hDpos; exact hDpos.ne'
    rw [Finset.sum_sub_distrib, Finset.sum_const, sum_totient_real n, nsmul_eq_mul, hDdef]
    field_simp
    simp
  -- expand the sum
  have hexpand : ∑ d ∈ n.divisors,
      (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d) - Real.log D)
      = (n : ℝ) * Real.log n
        - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        - (n : ℝ) * Real.log D := by
    have h1 : ∀ d : ℕ, (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d)
        - Real.log D)
        = (Nat.totient d : ℝ) * Real.log n - (Nat.totient d : ℝ) * Real.log (Nat.totient d)
          - (Nat.totient d : ℝ) * Real.log D := by
      intro d; ring
    simp only [h1]
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul,
      sum_totient_real n]
  rw [hexpand] at hsum
  -- convert to base-2 logarithms
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hS : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d)) / Real.log 2 := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl (fun d _ => ?_)
    rw [Real.logb]
    ring
  rw [HT_divisor_formula hn, hS, Real.logb, Real.logb]
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have hkey : Real.log n
      - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
      ≤ Real.log D := by
    have h1 := mul_le_mul_of_nonneg_left hsum hinv.le
    rw [mul_zero] at h1
    have hrw2 : 1 / (n : ℝ) * ((n : ℝ) * Real.log n
        - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        - (n : ℝ) * Real.log D)
        = Real.log n
          - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
          - Real.log D := by
      field_simp
    rw [hrw2] at h1
    linarith
  have hrw : Real.log ↑n / Real.log 2
      - 1 / (n : ℝ) * ((∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        / Real.log 2)
      = (Real.log n
        - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d)))
        / Real.log 2 := by
    field_simp
  rw [hrw]
  gcongr

/-- **Strict divisor-lattice bound.**  For `n ≥ 3` the type law is never uniform on the divisor
lattice, so the bound is strict: `HT n < log₂ d(n)`. -/
theorem HT_lt_logb_card_divisors (hn : 3 ≤ n) :
    HT n < Real.logb 2 (n.divisors.card) := by
  have hnpos : 0 < n := by omega
  set D : ℝ := (n.divisors.card : ℝ) with hDdef
  have hne : n.divisors.Nonempty := ⟨1, Nat.one_mem_divisors.2 hnpos.ne'⟩
  have hDpos : 0 < D := by
    rw [hDdef]; exact_mod_cast Finset.card_pos.2 hne
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hnpos
  have hDlt : D < (n : ℝ) := by
    rw [hDdef]; exact_mod_cast card_divisors_lt_self hn
  -- the `d = 1` term is strict, because `n / D ≠ 1`
  have hmem1 : (1 : ℕ) ∈ n.divisors := Nat.one_mem_divisors.2 hnpos.ne'
  have hstrict : (Nat.totient 1 : ℝ) * (Real.log n - Real.log (Nat.totient 1) - Real.log D)
      < (n : ℝ) / D - (Nat.totient 1 : ℝ) := by
    have ht : (0 : ℝ) < (n : ℝ) / ((1 : ℝ) * D) := by positivity
    have htne : (n : ℝ) / ((1 : ℝ) * D) ≠ 1 := by
      rw [one_mul]
      intro h
      rw [div_eq_one_iff_eq hDpos.ne'] at h
      linarith
    have hlog := Real.log_lt_sub_one_of_pos ht htne
    have hexp : Real.log ((n : ℝ) / ((1 : ℝ) * D)) = Real.log n - Real.log 1 - Real.log D := by
      rw [one_mul, Real.log_div (by positivity) hDpos.ne', Real.log_one]
      ring
    rw [hexp] at hlog
    have hrw : (n : ℝ) / ((1 : ℝ) * D) - 1 = (n : ℝ) / D - 1 := by rw [one_mul]
    rw [hrw] at hlog
    simpa using hlog
  have hsum : ∑ d ∈ n.divisors,
      (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d) - Real.log D) < 0 := by
    refine lt_of_lt_of_le
      (Finset.sum_lt_sum (fun d hd => gibbs_term hnpos hDpos hd) ⟨1, hmem1, hstrict⟩) ?_
    have hc : (n.divisors.card : ℝ) ≠ 0 := by
      rw [hDdef] at hDpos; exact hDpos.ne'
    rw [Finset.sum_sub_distrib, Finset.sum_const, sum_totient_real n, nsmul_eq_mul, hDdef]
    field_simp
    simp
  have hexpand : ∑ d ∈ n.divisors,
      (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d) - Real.log D)
      = (n : ℝ) * Real.log n
        - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        - (n : ℝ) * Real.log D := by
    have h1 : ∀ d : ℕ, (Nat.totient d : ℝ) * (Real.log n - Real.log (Nat.totient d)
        - Real.log D)
        = (Nat.totient d : ℝ) * Real.log n - (Nat.totient d : ℝ) * Real.log (Nat.totient d)
          - (Nat.totient d : ℝ) * Real.log D := by
      intro d; ring
    simp only [h1]
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul,
      sum_totient_real n]
  rw [hexpand] at hsum
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hS : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d)) / Real.log 2 := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl (fun d _ => ?_)
    rw [Real.logb]; ring
  rw [HT_divisor_formula hnpos, hS, Real.logb, Real.logb]
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have hkey : Real.log n
      - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
      < Real.log D := by
    have h1 := mul_lt_mul_of_pos_left hsum hinv
    rw [mul_zero] at h1
    have hrw2 : 1 / (n : ℝ) * ((n : ℝ) * Real.log n
        - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        - (n : ℝ) * Real.log D)
        = Real.log n
          - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
          - Real.log D := by
      field_simp
    rw [hrw2] at h1
    linarith
  have hrw : Real.log ↑n / Real.log 2
      - 1 / (n : ℝ) * ((∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d))
        / Real.log 2)
      = (Real.log n
        - 1 / (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.log (Nat.totient d)))
        / Real.log 2 := by
    field_simp
  rw [hrw]
  gcongr

/-- **The sandwich.**  The binary root-count readout, the full type channel and the divisor
lattice are nested: `H(nr) ≤ H(T) ≤ log₂ d(n)`. -/
theorem Hnr_le_HT_le_logb_card_divisors (hn : 0 < n) :
    Hnr n ≤ HT n ∧ HT n ≤ Real.logb 2 (n.divisors.card) :=
  ⟨Hnr_le_HT hn, HT_le_logb_card_divisors hn⟩

end CyclicType