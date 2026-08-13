import Mathlib
import Algebra.QubitTrade.Resolution

/-!
# QUBIT-TRADE III: qubit ↔ sample fungibility above the threshold

Above the resolution threshold of `Resolution.lean` a truncated register still
does not hand you the order: continued fractions return the *reduced* fraction
`k/r`, whose denominator is `r / gcd (k, r)`, and a sample with `gcd (k, r) > 1`
under-reports the order.  This is the only remaining obstruction, and it is the
one that **more samples do repair** — the observed "qubit ↔ sample fungibility".

We prove this exactly:

* `QubitTrade.recovered_eq` — one sample returns `r / gcd (k, r)`, a proper
  divisor of `r` whenever `gcd (k, r) > 1` (`QubitTrade.recovered_lt`);
* `QubitTrade.two_samples_recover` — **two** samples whose numerators are jointly
  coprime to `r` already give `r` as the lcm of the two reduced denominators;
* `QubitTrade.samples_recover` — the same for a record of arbitrary length: the
  lcm of the reduced denominators equals `r` exactly when the numerators are
  jointly coprime to `r` (`QubitTrade.samples_recover_iff` gives the converse,
  so the criterion is sharp).

Combined with `Resolution.cf_target_unique` this is the positive half of the
trade: above `2 log₂ r` qubits, extra samples buy the missing gcd information —
but below it (see `SupportCollapse.lean`) no number of samples buys anything.
-/

namespace QubitTrade

/-- The order actually recovered from a single sample `k` at true order `r`:
the denominator of the reduced fraction `k / r`. -/
def recovered (k r : ℕ) : ℕ := (orderFrac k r).den

theorem recovered_eq {k r : ℕ} (hr : 0 < r) : recovered k r = r / Nat.gcd k r :=
  orderFrac_den k r hr

theorem recovered_dvd {k r : ℕ} (hr : 0 < r) : recovered k r ∣ r := by
  rw [recovered_eq hr]
  exact Nat.div_dvd_of_dvd (Nat.gcd_dvd_right _ _)

/-- A single sample recovers the *full* order iff its numerator is coprime to it. -/
theorem recovered_eq_self_iff {k r : ℕ} (hr : 0 < r) :
    recovered k r = r ↔ Nat.gcd k r = 1 := by
  rw [recovered_eq hr]
  constructor
  · intro h
    have hg : Nat.gcd k r ∣ r := Nat.gcd_dvd_right _ _
    have hgpos : 0 < Nat.gcd k r := Nat.pos_of_dvd_of_pos hg hr
    have : r / Nat.gcd k r * Nat.gcd k r = r := Nat.div_mul_cancel hg
    rw [h] at this
    nlinarith [this, hgpos, hr]
  · intro h; rw [h, Nat.div_one]
/-- A sample with `gcd (k, r) > 1` **under-reports**: it returns a proper divisor. -/
theorem recovered_lt {k r : ℕ} (hr : 0 < r) (hk : 1 < Nat.gcd k r) :
    recovered k r < r := by
  have hdvd := recovered_dvd (k := k) hr
  have hne : recovered k r ≠ r := by
    rw [Ne, recovered_eq_self_iff hr]
    omega
  exact lt_of_le_of_ne (Nat.le_of_dvd hr hdvd) hne

/-! ## Records of arbitrary length -/

/-- The joint gcd of a record of numerators. -/
def recordGcd (ks : List ℕ) : ℕ := ks.foldr Nat.gcd 0

/-- The order estimate produced from a record: the lcm of the reduced
denominators of all the samples. -/
def recordEstimate (ks : List ℕ) (r : ℕ) : ℕ :=
  (ks.map (fun k => recovered k r)).foldr Nat.lcm 1

theorem recordGcd_dvd {p : ℕ} {ks : List ℕ} (h : ∀ k ∈ ks, p ∣ k) : p ∣ recordGcd ks := by
  induction ks with
  | nil => simp [recordGcd]
  | cons a l ih =>
      have hla : p ∣ a := h a (List.mem_cons_self ..)
      have hl : ∀ k ∈ l, p ∣ k := fun k hk => h k (List.mem_cons_of_mem _ hk)
      exact Nat.dvd_gcd hla (ih hl)

theorem recordEstimate_dvd {ks : List ℕ} {r : ℕ} (hr : 0 < r) : recordEstimate ks r ∣ r := by
  induction ks with
  | nil => simp [recordEstimate]
  | cons a l ih =>
      exact Nat.lcm_dvd (recovered_dvd hr) ih

theorem recovered_dvd_recordEstimate {k : ℕ} {ks : List ℕ} {r : ℕ} (hk : k ∈ ks) :
    recovered k r ∣ recordEstimate ks r := by
  induction ks with
  | nil => cases hk
  | cons a l ih =>
      rcases List.mem_cons.mp hk with rfl | hmem
      · exact Nat.dvd_lcm_left _ _
      · exact (ih hmem).trans (Nat.dvd_lcm_right _ _)

/-- If every sample's reduced denominator divides `d`, so does the record estimate. -/
theorem recordEstimate_dvd_of_forall {r d : ℕ} :
    ∀ {ks : List ℕ}, (∀ k ∈ ks, recovered k r ∣ d) → recordEstimate ks r ∣ d := by
  intro ks
  induction ks with
  | nil => intro _; simp [recordEstimate]
  | cons a l ih =>
      intro h
      exact Nat.lcm_dvd (h a (List.mem_cons_self ..))
        (ih fun k hk => h k (List.mem_cons_of_mem _ hk))

/-- The joint gcd of a record divides each of its entries. -/
theorem recordGcd_dvd_mem {k : ℕ} {ks : List ℕ} (hk : k ∈ ks) : recordGcd ks ∣ k := by
  induction ks with
  | nil => cases hk
  | cons a l ih =>
      rcases List.mem_cons.mp hk with rfl | hmem
      · exact Nat.gcd_dvd_left _ _
      · exact (Nat.gcd_dvd_right a (recordGcd l)).trans (ih hmem)

/-- **Sample fungibility, general form.**  A record of samples recovers the order
as soon as the sampled numerators are *jointly* coprime to it. -/
theorem samples_recover {r : ℕ} {ks : List ℕ} (hr : 0 < r)
    (h : Nat.gcd (recordGcd ks) r = 1) : recordEstimate ks r = r := by
  obtain ⟨c, hc⟩ := recordEstimate_dvd (ks := ks) hr
  rcases eq_or_ne c 1 with hc1 | hc1
  · rw [hc1, mul_one] at hc; exact hc.symm
  · exfalso
    obtain ⟨p, hp, hpc⟩ := Nat.exists_prime_and_dvd hc1
    obtain ⟨c', hc'⟩ := hpc
    have key : ∀ k ∈ ks, p ∣ Nat.gcd k r := by
      intro k hk
      obtain ⟨e, he⟩ := recovered_dvd_recordEstimate (k := k) (r := r) hk
      have hgr : Nat.gcd k r ∣ r := Nat.gcd_dvd_right _ _
      have hgpos : 0 < Nat.gcd k r := Nat.pos_of_dvd_of_pos hgr hr
      have hrec : recovered k r = r / Nat.gcd k r := recovered_eq hr
      have hdpos : 0 < r / Nat.gcd k r := Nat.div_pos (Nat.le_of_dvd hr hgr) hgpos
      have hrg : (r / Nat.gcd k r) * Nat.gcd k r = r := Nat.div_mul_cancel hgr
      have hmain : (r / Nat.gcd k r) * Nat.gcd k r
          = (r / Nat.gcd k r) * (e * (p * c')) := by
        calc (r / Nat.gcd k r) * Nat.gcd k r = r := hrg
          _ = recordEstimate ks r * c := hc
          _ = (r / Nat.gcd k r) * e * (p * c') := by rw [he, hrec, hc']
          _ = (r / Nat.gcd k r) * (e * (p * c')) := by ring
      have hgeq : Nat.gcd k r = e * (p * c') := Nat.eq_of_mul_eq_mul_left hdpos hmain
      exact ⟨e * c', by rw [hgeq]; ring⟩
    have hks : ∀ k ∈ ks, p ∣ k := fun k hk => (key k hk).trans (Nat.gcd_dvd_left _ _)
    have hpr : p ∣ r := by
      rw [hc, hc']
      exact ⟨recordEstimate ks r * c', by ring⟩
    have hfin : p ∣ Nat.gcd (recordGcd ks) r := Nat.dvd_gcd (recordGcd_dvd hks) hpr
    rw [h] at hfin
    exact hp.one_lt.ne' (Nat.eq_one_of_dvd_one hfin)

/-- Conversely, a record whose numerators share a prime factor with the order can
never recover it: the criterion of `samples_recover` is sharp. -/
theorem samples_recover_iff {r : ℕ} {ks : List ℕ} (hr : 0 < r) :
    recordEstimate ks r = r ↔ Nat.gcd (recordGcd ks) r = 1 := by
  refine ⟨fun h => ?_, samples_recover hr⟩
  by_contra hne
  obtain ⟨p, hp, hpg⟩ := Nat.exists_prime_and_dvd hne
  have hpr : p ∣ r := hpg.trans (Nat.gcd_dvd_right _ _)
  have hppos : 0 < p := hp.pos
  have hrp : 0 < r / p := Nat.div_pos (Nat.le_of_dvd hr hpr) hppos
  -- every sample's reduced denominator divides `r / p`
  have hstep : ∀ k ∈ ks, recovered k r ∣ r / p := by
    intro k hk
    have hpk : p ∣ k := hpg.trans ((Nat.gcd_dvd_left _ _).trans (recordGcd_dvd_mem hk))
    have hpgcd : p ∣ Nat.gcd k r := Nat.dvd_gcd hpk hpr
    obtain ⟨g', hg'⟩ := hpgcd
    have hgr : Nat.gcd k r ∣ r := Nat.gcd_dvd_right _ _
    have hrg : (r / Nat.gcd k r) * Nat.gcd k r = r := Nat.div_mul_cancel hgr
    refine ⟨g', ?_⟩
    rw [recovered_eq hr]
    refine Nat.div_eq_of_eq_mul_left hppos ?_
    calc r = (r / Nat.gcd k r) * Nat.gcd k r := hrg.symm
      _ = (r / Nat.gcd k r) * (p * g') := by rw [← hg']
      _ = (r / Nat.gcd k r) * g' * p := by ring
  have hL : recordEstimate ks r ∣ r / p := recordEstimate_dvd_of_forall hstep
  rw [h] at hL
  have : r ≤ r / p := Nat.le_of_dvd hrp hL
  have hlt : r / p < r := Nat.div_lt_self hr hp.one_lt
  omega

/-! ## Two samples suffice -/

/-- **Sample fungibility, two-sample form.**  If the two numerators are jointly
coprime to the order (`gcd (gcd k₁ k₂) r = 1`), then the least common multiple of
the two reduced denominators is exactly the order — even though each sample alone
may under-report it.  This is the "samples compensate `gcd (k, r) > 1`" effect. -/
theorem two_samples_recover {r k₁ k₂ : ℕ} (hr : 0 < r)
    (h : Nat.gcd (Nat.gcd k₁ k₂) r = 1) :
    Nat.lcm (recovered k₁ r) (recovered k₂ r) = r := by
  have hg : recordGcd [k₁, k₂] = Nat.gcd k₁ k₂ := by
    simp [recordGcd]
  have he : recordEstimate [k₁, k₂] r = Nat.lcm (recovered k₁ r) (recovered k₂ r) := by
    simp [recordEstimate]
  rw [← he]
  exact samples_recover hr (by rw [hg]; exact h)

/-- A single sample already suffices when its numerator happens to be coprime to
the order; the two-sample bound is only needed when it is not. -/
theorem one_sample_recover {r k : ℕ} (hr : 0 < r) (h : Nat.gcd k r = 1) :
    recovered k r = r := (recovered_eq_self_iff hr).mpr h

end QubitTrade