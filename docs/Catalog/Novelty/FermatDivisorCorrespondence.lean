import Novelty.OracleRealizationGap

/-!
# Cycle 2: the navigation sensor for arbitrary odd `N` is a divisor-midpoint minimum

Cycle 1 (`Novelty.OracleRealizationGap`) priced the oracle navigation sensor on *semiprimes*:
a Fermat scan of budget `k` succeeds exactly when the Fermat gap `d = (p+q)/2 - ⌊√N⌋` is at
most `k`.  That statement presupposes the factorisation.  This file removes the hypothesis and
identifies the scan's cost for an arbitrary odd `N` intrinsically:

> a scan of budget `k` succeeds **iff** `N` has a nontrivial divisor `d` whose divisor-pair
> midpoint `(d + N/d)/2` lies within `⌊√N⌋ + k`.

So the navigation sensor of the campaign is, in general, the indicator of

`fermatCost N = min { (d + N/d)/2 - ⌊√N⌋ : d ∣ N, 1 < d < N } ≤ B`,

a minimum over the whole divisor lattice of `N`; on semiprimes the lattice has a single
nontrivial pair and the minimum collapses to the gap of cycle 1.  This is the structural reason
the sensor is factor-conditioned: its value is a *divisor-lattice* functional.

## Main results

* `scanHit_of_split` : an odd factorisation `N = u·v` with `1 < u ≤ v` and midpoint within
  `⌊√N⌋ + k` produces a scan hit;
* `scanHit_iff_exists_divisor` : the intrinsic characterisation, for every odd `N` and budget;
* `not_scanHit_of_all_divisors_far` : the safety criterion — if every divisor-pair midpoint
  overshoots the budget, no scan of that budget succeeds;
* `scanHit_mono`, `exists_scanHit_of_dvd` : monotonicity in the budget and unconditional
  reachability for composite `N`, so the least successful budget (the general navigation gap)
  exists;
* `scanHit_semiprime_iff` : cycle 1's semiprime budget law recovered from the general one.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the sensor threshold statistic is not tied to the *prime*
factorisation at all; it is the distance from `⌊√N⌋` to the nearest divisor-pair midpoint.  If
so, the semiprime law of cycle 1 is one instance of a lattice-wide minimum, and highly composite
`N` should be *easier* to navigate, not harder.

Experiment (Experimenter): `ComputationalEvidence.md`, Table 5: for every odd `N < 20000` the
least budget with a scan hit equals `min over d ∣ N, 1 < d < N of (d + N/d)/2 - ⌊√N⌋` — zero
violations; and for `N` with many divisors the minimum is attained at an interior divisor, not
at the extreme pair.

Analysis (Analyst): the correspondence `d ↔ (a, b) = ((d + N/d)/2, (N/d - d)/2)` is a bijection
between nontrivial divisor pairs and nontrivial Fermat representations.  Everything else — the
budget law, the safety criterion, the semiprime specialisation — is a reading of that bijection.

Critique (Critic): the `1 < d < N` guard is exactly the exclusion of the trivial representation
`N = ((N+1)/2)² - ((N-1)/2)²`; dropping it would make every odd `N` a hit at astronomical
budget and the theorem vacuous.  Oddness of `N` is needed there: for even `N` the divisor pair
may have opposite parities and no integral midpoint exists (`N = 12`, `k = 0`, `d = 3` is a
counterexample to the odd law without the hypothesis).  Cycle 4 repairs this by doubling, where
the guard must be strengthened to `2 < a - b` because `4N = (N+1)² - (N-1)²` has `a - b = 2`.
-/

namespace OracleRealizationGap

/-- A divisor of an odd number is odd. -/
lemma odd_of_dvd_odd {N d : ℕ} (hN : Odd N) (hd : d ∣ N) : Odd d := by
  by_contra hcon
  rw [Nat.not_odd_iff_even] at hcon
  have h2 : (2 : ℕ) ∣ N := dvd_trans hcon.two_dvd hd
  rw [Nat.odd_iff] at hN
  omega

/-- **From a split to a scan hit.**  An odd factorisation `N = u·v` with `1 < u ≤ v` whose
midpoint lies within budget produces a Fermat scan hit. -/
theorem scanHit_of_split {N k u v : ℕ} (hu : Odd u) (hv : Odd v) (huv : u ≤ v)
    (hN : N = u * v) (h1 : 1 < u) (hmid : (u + v) / 2 ≤ Nat.sqrt N + k) : ScanHit N k := by
  obtain ⟨h, rfl⟩ := exists_half hu hv huv
  have hNe : N = u * (u + 2 * h) := hN
  have hsq : (u + h) ^ 2 = N + h ^ 2 := by rw [hNe]; exact sq_param u h
  have hmid' : u + h ≤ Nat.sqrt N + k := by
    have : (u + (u + 2 * h)) / 2 = u + h := by omega
    omega
  have hge : Nat.sqrt N ≤ u + h := by
    have hle : N ≤ (u + h) ^ 2 := by omega
    calc Nat.sqrt N ≤ Nat.sqrt ((u + h) ^ 2) := Nat.sqrt_le_sqrt hle
      _ = u + h := Nat.sqrt_eq' _
  refine ⟨u + h - Nat.sqrt N, by omega, h, ?_, ?_⟩
  · have : Nat.sqrt N + (u + h - Nat.sqrt N) = u + h := by omega
    rw [this, hsq]
  · have : Nat.sqrt N + (u + h - Nat.sqrt N) = u + h := by omega
    omega

/-- **The intrinsic budget law.**  For odd `N`, a Fermat scan of budget `k` succeeds iff some
nontrivial divisor pair of `N` has its midpoint within `⌊√N⌋ + k`. -/
theorem scanHit_iff_exists_divisor (N k : ℕ) (hN : Odd N) :
    ScanHit N k ↔ ∃ d, d ∣ N ∧ 1 < d ∧ d < N ∧ (d + N / d) / 2 ≤ Nat.sqrt N + k := by
  constructor
  · rintro ⟨i, hik, b, hsq, hnt⟩
    set a := Nat.sqrt N + i with ha
    have hba : b < a := by omega
    have hfac : (a - b) * (a + b) = N := by
      rw [sq_sub_sq a b (le_of_lt hba)]
      exact Nat.sub_eq_of_eq_add hsq
    have hdvd : (a - b) ∣ N := ⟨a + b, hfac.symm⟩
    have hpos : 0 < a - b := by omega
    have hdiv : N / (a - b) = a + b := by
      rw [← hfac, Nat.mul_div_cancel_left _ hpos]
    refine ⟨a - b, hdvd, by omega, ?_, ?_⟩
    · -- `a - b ≤ a + b` and both exceed `1`, so `a - b` is a proper divisor
      have h2 : 2 ≤ a - b := by omega
      have hab : 2 ≤ a + b := by omega
      have hkey : (a - b) * 2 ≤ (a - b) * (a + b) := Nat.mul_le_mul_left _ hab
      rw [hfac] at hkey
      omega
    · rw [hdiv]
      have : (a - b + (a + b)) / 2 = a := by omega
      omega
  · rintro ⟨d, hdvd, hd1, hdN, hmid⟩
    obtain ⟨e, he⟩ := hdvd
    have hNpos : 0 < N := by
      rcases Nat.eq_zero_or_pos N with h | h
      · exact absurd (h ▸ hN) (by simp)
      · exact h
    have hdpos : 0 < d := by omega
    have hdiv : N / d = e := by rw [he, Nat.mul_div_cancel_left _ hdpos]
    rw [hdiv] at hmid
    have hdo : Odd d := odd_of_dvd_odd hN ⟨e, he⟩
    have heo : Odd e := odd_of_dvd_odd hN ⟨d, by rw [he]; ring⟩
    have he1 : 1 < e := by
      rcases Nat.lt_or_ge e 2 with h | h
      · interval_cases e <;> omega
      · omega
    rcases le_total d e with hde | hed
    · exact scanHit_of_split hdo heo hde he hd1 hmid
    · refine scanHit_of_split heo hdo hed (by rw [he]; ring) he1 ?_
      have : e + d = d + e := by ring
      omega

/-- **Safety criterion.**  If every nontrivial divisor pair of an odd `N` has its midpoint
beyond `⌊√N⌋ + k`, then no Fermat scan of budget `k` succeeds. -/
theorem not_scanHit_of_all_divisors_far (N k : ℕ) (hN : Odd N)
    (hfar : ∀ d, d ∣ N → 1 < d → d < N → Nat.sqrt N + k < (d + N / d) / 2) :
    ¬ ScanHit N k := by
  rw [scanHit_iff_exists_divisor N k hN]
  rintro ⟨d, hdvd, hd1, hdN, hmid⟩
  exact absurd hmid (by simpa using hfar d hdvd hd1 hdN)

/-- Scan hits are monotone in the budget. -/
theorem scanHit_mono (N : ℕ) {k l : ℕ} (hkl : k ≤ l) (h : ScanHit N k) : ScanHit N l := by
  obtain ⟨i, hik, b, hsq, hnt⟩ := h
  exact ⟨i, hik.trans hkl, b, hsq, hnt⟩

/-- Every odd number with a nontrivial divisor is eventually navigable: the least successful
budget — the general navigation gap — exists. -/
theorem exists_scanHit_of_dvd (N d : ℕ) (hN : Odd N) (hdvd : d ∣ N) (hd1 : 1 < d)
    (hdN : d < N) : ∃ k, ScanHit N k :=
  ⟨(d + N / d) / 2, (scanHit_iff_exists_divisor N _ hN).2 ⟨d, hdvd, hd1, hdN, by omega⟩⟩

/-! ## Cycle 4: removing the parity hypothesis by doubling -/

/-- The doubled scan: probe `⌊√(4N)⌋, …, ⌊√(4N)⌋ + k` for a square remainder, with the
nontriviality guard `2 < a - b` (the doubled split `4N = (N+1)² - (N-1)²` has `a - b = 2`). -/
def ScanHit2 (N k : ℕ) : Prop :=
  ∃ i ≤ k, ∃ b : ℕ, (Nat.sqrt (4 * N) + i) ^ 2 = 4 * N + b ^ 2 ∧ 2 < Nat.sqrt (4 * N) + i - b

/-- A factorisation of *any* parity produces a doubled scan hit within its midpoint budget. -/
theorem scanHit2_of_split {N k d e : ℕ} (hde : N = d * e) (hd : 1 < d) (hle : d ≤ e)
    (hmid : d + e ≤ Nat.sqrt (4 * N) + k) : ScanHit2 N k := by
  have hsq : (d + e) ^ 2 = 4 * N + (e - d) ^ 2 := by
    obtain ⟨c, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hexp : (d + (d + c)) ^ 2 = 4 * (d * (d + c)) + c ^ 2 := by ring
    have hsub : d + c - d = c := by omega
    rw [hde, hsub]
    omega
  have hge : Nat.sqrt (4 * N) ≤ d + e := by
    have hle' : 4 * N ≤ (d + e) ^ 2 := by omega
    calc Nat.sqrt (4 * N) ≤ Nat.sqrt ((d + e) ^ 2) := Nat.sqrt_le_sqrt hle'
      _ = d + e := Nat.sqrt_eq' _
  refine ⟨d + e - Nat.sqrt (4 * N), by omega, e - d, ?_, ?_⟩
  · have hrw : Nat.sqrt (4 * N) + (d + e - Nat.sqrt (4 * N)) = d + e := by omega
    rw [hrw, hsq]
  · have hrw : Nat.sqrt (4 * N) + (d + e - Nat.sqrt (4 * N)) = d + e := by omega
    omega

/-- **Parity-free navigation law.**  For every positive `N` — odd or even — a doubled Fermat scan
of budget `k` succeeds iff some nontrivial divisor pair of `N` has `d + N/d` within
`⌊√(4N)⌋ + k`.  Doubling makes the divisor-pair midpoint integral, removing the `Odd N`
hypothesis of `scanHit_iff_exists_divisor`. -/
theorem scanHit2_iff_exists_divisor (N k : ℕ) (hN : 0 < N) :
    ScanHit2 N k ↔ ∃ d, d ∣ N ∧ 1 < d ∧ d < N ∧ d + N / d ≤ Nat.sqrt (4 * N) + k := by
  constructor
  · rintro ⟨i, hik, b, hsq, hnt⟩
    set a := Nat.sqrt (4 * N) + i with ha
    have hba : b < a := by omega
    have hfac : (a - b) * (a + b) = 4 * N := by
      rw [sq_sub_sq a b (le_of_lt hba)]
      exact Nat.sub_eq_of_eq_add hsq
    -- both factors are even, since their sum `2a` is even and their product is even
    have hpar : (a - b) % 2 = (a + b) % 2 := by omega
    have heven : (a - b) % 2 = 0 := by
      by_contra hodd
      have h1 : Odd (a - b) := by rw [Nat.odd_iff]; omega
      have h2 : Odd (a + b) := by rw [Nat.odd_iff]; omega
      have : Odd ((a - b) * (a + b)) := h1.mul h2
      rw [hfac, Nat.odd_iff] at this
      omega
    obtain ⟨d, hd⟩ : ∃ d, a - b = 2 * d := ⟨(a - b) / 2, by omega⟩
    obtain ⟨e, he⟩ : ∃ e, a + b = 2 * e := ⟨(a + b) / 2, by omega⟩
    have hde : d * e = N := by
      have h4 : 4 * (d * e) = 4 * N := by rw [← hfac, hd, he]; ring
      omega
    have hd1 : 1 < d := by omega
    have hdle : d ≤ e := by omega
    have he1 : 1 < e := by omega
    have hdpos : 0 < d := by omega
    have hdiv : N / d = e := by rw [← hde, Nat.mul_div_cancel_left _ hdpos]
    refine ⟨d, ⟨e, hde.symm⟩, hd1, ?_, ?_⟩
    · have : d * 2 ≤ d * e := Nat.mul_le_mul_left _ he1
      omega
    · rw [hdiv]
      omega
  · rintro ⟨d, hdvd, hd1, hdN, hmid⟩
    obtain ⟨e, he⟩ := hdvd
    have hdpos : 0 < d := by omega
    have hdiv : N / d = e := by rw [he, Nat.mul_div_cancel_left _ hdpos]
    rw [hdiv] at hmid
    have he1 : 1 < e := by
      rcases Nat.lt_or_ge e 2 with h | h
      · interval_cases e <;> omega
      · omega
    rcases le_total d e with hde | hed
    · exact scanHit2_of_split he hd1 hde hmid
    · exact scanHit2_of_split (by rw [he]; ring) he1 hed (by omega)

/-- Cycle 1's semiprime budget law, recovered from the general divisor law. -/
theorem scanHit_semiprime_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpo : Odd p)
    (hqo : Odd q) (hpq : p ≤ q) (k : ℕ) : ScanHit (p * q) k ↔ gap p q ≤ k :=
  scanHit_iff_gap_le hp hq hpo hqo hpq k

end OracleRealizationGap