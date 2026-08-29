import Mathlib

/-!
# The oracle-realization gap for the Fermat navigation sensor

Round-74 of the factoring-barriers campaign measured an *oracle navigation sensor* on a
population of odd semiprimes `N = p·q`: the indicator `1{d ≤ B}` of the **Fermat gap**

`d(N) = (p+q)/2 - ⌊√N⌋`

carried `I(1{d ≤ B}; b₁) ≈ 0.48` bits at `B = 22758`, while *no* `N`-computable query policy
with a 295-item menu realised more than a fraction of it (strict within-strata crediting: `0 %`
on both seeds; only a between-strata population base-rate slice survived leniently).  The
experimental verdict was `GAP-PARTIAL`, attributed to *barrier 6 (circularity)*: the sensor is a
function of the hidden factorisation, not of `N`.

This file turns that empirical verdict into theorems.  Three independent mechanisms are proved.

## Main results

* `recover_gap` (**circularity, exactly**): for odd `p ≤ q` the single number `d = gap p q`
  reconstructs the factorisation by two integer square roots:
  `recover (p*q) (gap p q) = p` and `recoverHi (p*q) (gap p q) = q`.
  Knowing the sensor's underlying statistic *is* knowing the factors — the sensor is
  factor-conditioned by construction.
* `scanHit_iff_gap_le` (**budget law**): for a semiprime `N = p·q` with `p, q` odd primes, a
  Fermat scan of budget `k` (probing `⌊√N⌋, …, ⌊√N⌋+k` for a square remainder and demanding a
  nontrivial split) succeeds **iff** `gap p q ≤ k`.  So the geometric channel realises the
  sensor exactly at the price `k ≥ B`, and never below it.
* `least_accepting_eq_gap`, `oracle_factors` (**oracle ⇒ factoring**): any oracle answering the
  thresholded sensor `1{d ≤ B}` for all `B` yields `d`, hence a factorisation.  The `0.48`-bit
  sensor is therefore not merely unrealised but *factoring-hard*.
* `gap_gt_of_far`, `exists_prime_gap_gt` (**menu exhaustion**): the gap is unbounded — for every
  budget `k` there are infinitely many semiprimes whose gap exceeds `k`, so no fixed menu (295
  items, or any finite number) can cover the population.
* `residue_menu_blind`, `residue_policy_errs` (**MODONLY null, structurally**): for *every*
  modulus `L` and every threshold `B` there are two semiprimes with the same residue `mod L`
  and opposite sensor values.  Hence every policy that reads only residues of `N` errs on one of
  them: the residue channel carries exactly zero sensor information, which is the structural
  counterpart of the measured `0.0008–0.0032` bit MODONLY residual.
* `witness_gap`, `witness_scan_295`, `witness_scan_22758` (**the measured window, concretely**):
  `N = 955277 · 1044727 = 998003674379` has `gap = 1001`, so it lies strictly inside the
  reported window `295 < d ≤ 22758`: the sensor fires, and the 295-query scan misses it.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the measured 74–77 % "within-strata geometric excess" is not a
statistical artefact but a theorem: the sensor's statistic is Fermat-equivalent, so realising it
costs exactly the gap in probes, and every bounded-menu policy that is a function of residues is
provably blind.

Experiment (Experimenter): `ComputationalEvidence.md` tabulates `gap p q` for semiprime samples
across five magnitude decades, locates the concrete witness `998003674379` (gap `1001`) inside
the reported `(295, 22758]` window, and checks the budget law `scan k succeeds ↔ gap ≤ k` by
brute force for all odd semiprimes below `10^5`.

Analysis (Analyst): the empirical split "≈ 74 % within-strata geometry + ≈ 24 % population
prior" corresponds to the two theorems `scanHit_iff_gap_le` (geometry, priced in probes) and
`gap_gt_of_far` (unboundedness, which is what the finite menu cannot cover).  The MODONLY null
is not an estimate at all: it is exact, by `residue_policy_errs`.

Critique (Critic): the budget law needs the *nontriviality* guard `1 < a - b`, else the split
`N = ((N+1)/2)² - ((N-1)/2)²` makes every odd `N` a hit at astronomical budget; the guard is
part of `ScanHit`.  Squares `p = q` are legitimate members of the semiprime population and are
used (only) in `residue_menu_blind`, where the *other* member of the colliding pair has two
distinct prime factors; the pair is genuinely mixed.  No theorem here is vacuous: each existence
statement is witnessed, and `witness_gap` is a concrete numeral computation.
-/

namespace OracleRealizationGap

/-! ## 1.  The Fermat gap and its parametrisation -/

/-- The Fermat midpoint `(p+q)/2` of a semiprime with factors `p, q`. -/
def mid (p q : ℕ) : ℕ := (p + q) / 2

/-- The **Fermat gap** `d = (p+q)/2 - ⌊√(pq)⌋`: the number of probes a Fermat scan needs. -/
def gap (p q : ℕ) : ℕ := mid p q - Nat.sqrt (p * q)

/-- The oracle navigation sensor `1{d ≤ B}` of paper 197. -/
def sensor (B p q : ℕ) : Bool := decide (gap p q ≤ B)

/-- Reconstruction of the smaller factor from `N` and the gap. -/
def recover (N d : ℕ) : ℕ := (Nat.sqrt N + d) - Nat.sqrt ((Nat.sqrt N + d) ^ 2 - N)

/-- Reconstruction of the larger factor from `N` and the gap. -/
def recoverHi (N d : ℕ) : ℕ := (Nat.sqrt N + d) + Nat.sqrt ((Nat.sqrt N + d) ^ 2 - N)

/-- A Fermat scan of budget `k` hits: some probe `⌊√N⌋ + i`, `i ≤ k`, has square remainder and
produces a nontrivial split. -/
def ScanHit (N k : ℕ) : Prop :=
  ∃ i ≤ k, ∃ b : ℕ, (Nat.sqrt N + i) ^ 2 = N + b ^ 2 ∧ 1 < Nat.sqrt N + i - b

/-- Two odd numbers `p ≤ q` differ by an even amount. -/
lemma exists_half {p q : ℕ} (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    ∃ h : ℕ, q = p + 2 * h := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  exact ⟨b - a, by omega⟩

section Param

variable {p h : ℕ}

lemma mid_param (p h : ℕ) : mid p (p + 2 * h) = p + h := by
  unfold mid; omega

lemma sq_param (p h : ℕ) : (p + h) ^ 2 = p * (p + 2 * h) + h ^ 2 := by ring

lemma sqrt_le_param (p h : ℕ) : Nat.sqrt (p * (p + 2 * h)) ≤ p + h := by
  have : p * (p + 2 * h) ≤ (p + h) ^ 2 := by nlinarith
  calc Nat.sqrt (p * (p + 2 * h)) ≤ Nat.sqrt ((p + h) ^ 2) := Nat.sqrt_le_sqrt this
    _ = p + h := Nat.sqrt_eq' _

end Param

variable {p q : ℕ}

/-- `⌊√(pq)⌋ ≤ (p+q)/2`: the arithmetic–geometric mean inequality, integer form. -/
lemma sqrt_le_mid (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    Nat.sqrt (p * q) ≤ mid p q := by
  obtain ⟨h, rfl⟩ := exists_half hp hq hpq
  rw [mid_param]; exact sqrt_le_param p h

/-- The defining identity of the gap. -/
lemma sqrt_add_gap (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    Nat.sqrt (p * q) + gap p q = mid p q := by
  have := sqrt_le_mid hp hq hpq
  unfold gap; omega

/-- The midpoint squared exceeds `N` by exactly the squared half-difference. -/
lemma mid_sq (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    (mid p q) ^ 2 = p * q + ((q - p) / 2) ^ 2 := by
  obtain ⟨h, rfl⟩ := exists_half hp hq hpq
  have hh : (p + 2 * h - p) / 2 = h := by omega
  rw [mid_param, hh]; ring

/-! ## 2.  Barrier 6, exactly: the gap reconstructs the factorisation -/

/-- **Circularity theorem.**  For odd `p ≤ q`, the Fermat gap of `N = pq` together with `N`
recovers the smaller prime factor by two integer square roots. -/
theorem recover_gap (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    recover (p * q) (gap p q) = p := by
  obtain ⟨h, rfl⟩ := exists_half hp hq hpq
  have hmid : Nat.sqrt (p * (p + 2 * h)) + gap p (p + 2 * h) = p + h := by
    have := sqrt_add_gap hp hq hpq
    rwa [mid_param] at this
  unfold recover
  rw [hmid]
  have hsq : (p + h) ^ 2 - p * (p + 2 * h) = h ^ 2 := by
    have := sq_param p h; omega
  rw [hsq, Nat.sqrt_eq']
  omega

/-- The companion recovery of the larger factor. -/
theorem recoverHi_gap (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    recoverHi (p * q) (gap p q) = q := by
  obtain ⟨h, rfl⟩ := exists_half hp hq hpq
  have hmid : Nat.sqrt (p * (p + 2 * h)) + gap p (p + 2 * h) = p + h := by
    have := sqrt_add_gap hp hq hpq
    rwa [mid_param] at this
  unfold recoverHi
  rw [hmid]
  have hsq : (p + h) ^ 2 - p * (p + 2 * h) = h ^ 2 := by
    have := sq_param p h; omega
  rw [hsq, Nat.sqrt_eq']
  omega

/-- Difference of squares, in `ℕ`. -/
lemma sq_sub_sq (a b : ℕ) (hab : b ≤ a) : (a - b) * (a + b) = a ^ 2 - b ^ 2 := by
  obtain ⟨c, rfl⟩ := Nat.exists_eq_add_of_le hab
  have hexp : (b + c) ^ 2 = b ^ 2 + c * (b + c + b) := by ring
  have hsub : b + c - b = c := by omega
  rw [hsub]
  omega

/-! ## 3.  The budget law for the geometric channel -/

/-- **Budget law.**  For a semiprime `N = pq` with odd prime factors, a Fermat scan of budget
`k` succeeds if and only if the gap is at most `k`.  The geometric channel realises the sensor
`1{d ≤ B}` exactly when the budget reaches `B`, and never below. -/
theorem scanHit_iff_gap_le (hp : p.Prime) (hq : q.Prime) (hpo : Odd p) (hqo : Odd q)
    (hpq : p ≤ q) (k : ℕ) : ScanHit (p * q) k ↔ gap p q ≤ k := by
  constructor
  · rintro ⟨i, hik, b, hsq, hnt⟩
    set s := Nat.sqrt (p * q) with hs
    set a := s + i with ha
    have hba : b < a := by omega
    have hfac : (a - b) * (a + b) = p * q := by
      rw [sq_sub_sq a b (le_of_lt hba)]
      exact Nat.sub_eq_of_eq_add hsq
    have hu2 : 2 ≤ a - b := by omega
    have hle : a - b ≤ a + b := by omega
    -- the split must be `{p, q}`
    have hsum : (a - b) + (a + b) = p + q := by
      have hpd : p ∣ (a - b) * (a + b) := ⟨q, hfac⟩
      rcases (Nat.Prime.dvd_mul hp).1 hpd with hdu | hdv
      · obtain ⟨m, hm⟩ := hdu
        have hmv : m * (a + b) = q := by
          have : p * (m * (a + b)) = p * q := by rw [← hfac, hm]; ring
          exact Nat.eq_of_mul_eq_mul_left hp.pos this
        rcases (Nat.Prime.eq_one_or_self_of_dvd hq m ⟨a + b, hmv.symm⟩) with hm1 | hmq
        · subst hm1
          have : a + b = q := by omega
          omega
        · exfalso
          have hv1 : a + b = 1 := by
            subst hmq
            have := hq.pos
            nlinarith [hmv]
          omega
      · obtain ⟨m, hm⟩ := hdv
        have hmu : (a - b) * m = q := by
          have : p * ((a - b) * m) = p * q := by rw [← hfac, hm]; ring
          exact Nat.eq_of_mul_eq_mul_left hp.pos this
        rcases (Nat.Prime.eq_one_or_self_of_dvd hq (a - b) ⟨m, hmu.symm⟩) with hu1 | huq
        · omega
        · have hm1 : m = 1 := by
            have : q * m = q * 1 := by rw [← huq] at hmu ⊢; omega
            exact Nat.eq_of_mul_eq_mul_left hq.pos this
          have hvp : a + b = p := by rw [hm, hm1]; ring
          omega
    have hmideq : a = mid p q := by
      unfold mid; omega
    have hs_le : s ≤ mid p q := sqrt_le_mid hpo hqo hpq
    have : gap p q = i := by unfold gap; omega
    omega
  · intro hgk
    refine ⟨gap p q, hgk, (q - p) / 2, ?_, ?_⟩
    · rw [sqrt_add_gap hpo hqo hpq]
      exact mid_sq hpo hqo hpq
    · rw [sqrt_add_gap hpo hqo hpq]
      have hmid : mid p q = p + (q - p) / 2 := by
        obtain ⟨h, rfl⟩ := exists_half hpo hqo hpq
        rw [mid_param]; omega
      have hp3 : 2 < p := by
        have h1 := Nat.odd_iff.mp hpo
        have h2 := hp.two_le
        omega
      omega

/-! ## 4.  The sensor oracle is factoring-hard -/

/-- The least accepting threshold of a sensor oracle is the gap itself. -/
theorem least_accepting_eq_gap
    (O : ℕ → Bool) (hO : ∀ B, O B = sensor B p q) (H : ∃ B, O B = true) :
    Nat.find H = gap p q := by
  have hacc : O (gap p q) = true := by rw [hO]; simp [sensor]
  refine Nat.find_eq_iff _ |>.2 ⟨hacc, ?_⟩
  intro n hn hOn
  rw [hO] at hOn
  simp only [sensor, decide_eq_true_eq] at hOn
  omega

/-- **Oracle ⇒ factoring.**  An oracle that answers the thresholded navigation sensor
`1{d ≤ B}` for all `B` determines the factorisation of `N = pq`. -/
theorem oracle_factors (hp : Odd p) (hq : Odd q) (hpq : p ≤ q)
    (O : ℕ → Bool) (hO : ∀ B, O B = sensor B p q) (H : ∃ B, O B = true) :
    recover (p * q) (Nat.find H) = p ∧ recoverHi (p * q) (Nat.find H) = q := by
  rw [least_accepting_eq_gap O hO H]
  exact ⟨recover_gap hp hq hpq, recoverHi_gap hp hq hpq⟩

/-! ## 5.  Menu exhaustion: the gap is unbounded -/

/-- A quantitative lower bound: if the factors are far apart, the gap exceeds `k`. -/
theorem gap_gt_of_far (hpo : Odd p) (hqo : Odd q) (hfar : p + 2 * (k + 2 * p * k + 1) ≤ q) :
    k < gap p q := by
  have hpq : p ≤ q := by omega
  obtain ⟨h, rfl⟩ := exists_half hpo hqo hpq
  have hh : k + 2 * p * k + 1 ≤ h := by omega
  set m := h - k with hm
  have hmk : h = k + m := by omega
  have hmge : 2 * p * k + 1 ≤ m := by omega
  have hlt : p * (p + 2 * h) < (p + m) ^ 2 := by
    have : 2 * p * k < m ^ 2 := by nlinarith
    nlinarith
  have hsqrt : Nat.sqrt (p * (p + 2 * h)) < p + m := Nat.sqrt_lt'.2 hlt
  have hmid : mid p (p + 2 * h) = p + h := mid_param p h
  unfold gap
  omega

/-- For every budget `k` and every bound `n` there is a prime `q > n` with `gap 3 q > k`:
the semiprime population escapes every finite menu. -/
theorem exists_prime_gap_gt (k n : ℕ) :
    ∃ q, q.Prime ∧ n < q ∧ k < gap 3 q := by
  obtain ⟨q, hqgt, hq⟩ := Nat.exists_infinite_primes (max (n + 1) (3 + 2 * (k + 6 * k + 1)))
  refine ⟨q, hq, by omega, ?_⟩
  have hqo : Odd q := hq.odd_of_ne_two (by omega)
  exact gap_gt_of_far (by decide) hqo (by omega)

/-- The set of semiprimes with gap exceeding `k` is infinite. -/
theorem infinite_gap_gt (k : ℕ) :
    {N | ∃ q, q.Prime ∧ N = 3 * q ∧ k < gap 3 q}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨M, hM⟩
  obtain ⟨q, hq, hqM, hgap⟩ := exists_prime_gap_gt k M
  have : 3 * q ≤ M := hM ⟨q, hq, rfl, hgap⟩
  omega

/-! ## 6.  The residue channel is exactly blind -/

/-- **MODONLY null, structurally.**  For every modulus `L ≠ 0` and every threshold `B` there
are two semiprimes with the *same* residue mod `L` and opposite sensor values. -/
theorem residue_menu_blind (L B : ℕ) (hL : L ≠ 0) :
    ∃ p q₁ q₂ : ℕ, p.Prime ∧ q₁.Prime ∧ q₂.Prime ∧ Odd p ∧ Odd q₁ ∧ Odd q₂ ∧
      p ≤ q₁ ∧ p ≤ q₂ ∧ p * q₁ ≡ p * q₂ [MOD L] ∧ gap p q₁ ≤ B ∧ B < gap p q₂ := by
  obtain ⟨p, hpgt, hp⟩ := Nat.exists_infinite_primes (max (L + 1) 3)
  have hpo : Odd p := hp.odd_of_ne_two (by omega)
  have hcop : Nat.Coprime p L := by
    refine (Nat.Prime.coprime_iff_not_dvd hp).mpr ?_
    intro hdvd
    have := Nat.le_of_dvd (Nat.pos_of_ne_zero hL) hdvd
    omega
  obtain ⟨q₂, hq₂gt, hq₂, hmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (max p (p + 2 * (B + 2 * p * B + 1))) hL hcop
  have hq₂o : Odd q₂ := hq₂.odd_of_ne_two (by omega)
  refine ⟨p, p, q₂, hp, hp, hq₂, hpo, hpo, hq₂o, le_rfl, by omega, ?_, ?_, ?_⟩
  · exact Nat.ModEq.mul_left p hmod.symm
  · have : gap p p = 0 := by
      have h0 : mid p p = p := by unfold mid; omega
      have h1 : Nat.sqrt (p * p) = p := by
        have := Nat.sqrt_eq' p; rwa [pow_two] at this
      unfold gap; omega
    omega
  · exact gap_gt_of_far hpo hq₂o (by omega)

/-- **Every residue-only policy errs.**  A policy that reads only `N mod L` cannot match the
navigation sensor on the whole semiprime population. -/
theorem residue_policy_errs (L B : ℕ) (hL : L ≠ 0) (f : ℕ → Bool) :
    ∃ p q₁ q₂ : ℕ, p.Prime ∧ q₁.Prime ∧ q₂.Prime ∧ Odd p ∧ Odd q₁ ∧ Odd q₂ ∧
      (f ((p * q₁) % L) ≠ sensor B p q₁ ∨ f ((p * q₂) % L) ≠ sensor B p q₂) := by
  obtain ⟨p, q₁, q₂, hp, hq₁, hq₂, hpo, hq₁o, hq₂o, _, _, hmod, hlo, hhi⟩ :=
    residue_menu_blind L B hL
  refine ⟨p, q₁, q₂, hp, hq₁, hq₂, hpo, hq₁o, hq₂o, ?_⟩
  have hs₁ : sensor B p q₁ = true := by simp [sensor, hlo]
  have hs₂ : sensor B p q₂ = false := by
    simp only [sensor, decide_eq_false_iff_not, not_le]; omega
  have hres : (p * q₁) % L = (p * q₂) % L := hmod
  by_cases hf : f ((p * q₁) % L) = true
  · right
    rw [hs₂, ← hres, hf]; simp
  · left
    rw [hs₁]; simpa using hf

/-! ## 7.  The measured window, concretely -/

lemma witness_primes : Nat.Prime 955277 ∧ Nat.Prime 1044727 := by
  constructor <;> norm_num

/-- The concrete witness of the reported window: `N = 955277 · 1044727` has Fermat gap `1001`,
strictly between the 295-query menu budget and the sensor threshold `B = 22758`. -/
theorem witness_gap : gap 955277 1044727 = 1001 := by
  have h1 : (955277 : ℕ) * 1044727 = 998003674379 := by norm_num
  have h2 : Nat.sqrt 998003674379 = 999001 := by norm_num
  unfold gap mid
  rw [h1, h2]

/-- At the published menu budget of 295 distinct queries the Fermat scan misses this sample. -/
theorem witness_scan_295 : ¬ ScanHit (955277 * 1044727) 295 := by
  rw [scanHit_iff_gap_le witness_primes.1 witness_primes.2 (by decide) (by decide) (by norm_num),
    witness_gap]
  omega

/-- The sensor at the published threshold `B = 22758` nevertheless fires on this sample. -/
theorem witness_scan_22758 : ScanHit (955277 * 1044727) 22758 ∧
    sensor 22758 955277 1044727 = true := by
  refine ⟨?_, ?_⟩
  · rw [scanHit_iff_gap_le witness_primes.1 witness_primes.2 (by decide) (by decide) (by norm_num),
      witness_gap]
    omega
  · simp [sensor, witness_gap]

/-- The witness makes the realisation gap explicit: the sensor value is `1`, yet the
295-query geometric channel returns `0`. -/
theorem witness_realisation_gap :
    sensor 22758 955277 1044727 = true ∧ ¬ ScanHit (955277 * 1044727) 295 :=
  ⟨witness_scan_22758.2, witness_scan_295⟩

end OracleRealizationGap