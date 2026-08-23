import Mathlib
import Tropical.MusicalDigits.IntervalDistribution

/-!
# The tropical lag spectrum of a digit melody

For a fixed digit melody `x` and a temporal lag `ℓ` the *lag spectrum*

`maxInterval x ℓ = sup_i |x i - x (i+ℓ)|`

is the largest pitch interval realized by the position pairs `(i, i + ℓ)`.  It is the
`ℓ`-th coordinate of a max-plus (tropical) object: this file proves that

* `maxInterval` is **subadditive in the lag** (`maxInterval_add_le`), hence
  `ℓ ↦ trop (maxInterval x ℓ)` is a *tropically submultiplicative* map from the additive
  monoid `ℕ` to the tropical semiring `Tropical ℕ` (`tropLagSpectrum_submul`);
* the *kernel* of that tropical seminorm — the set of lags at which the melody is
  literally a unison — is an additive submonoid of `ℕ` (`unisonLags`), and it is closed
  not only under addition but under **greatest common divisors** (`isPeriod_gcd`);
* consequently the unison-lag monoid is *rigid*: it is either `{0}` (aperiodic melody)
  or exactly the set of multiples of the minimal period (`unisonLags_eq_multiples`).
  Every "perfect lag-12 autocorrelation" phenomenon is therefore governed by a single
  divisor of 12, and it is a **unison** phenomenon: the intervals realized are all `0`,
  never the twelve semitones of an octave (`lag_twelve_unison_not_octave`).

This is the structural separation demanded by the corrected methodology: the temporal
variable `ℓ` lives in the additive monoid `ℕ` and is organized by divisibility, whereas
the pitch variable lives in `{0, …, 9}` and is organized by the tropical order.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the lag statistic should behave like a seminorm on the lag
monoid, so its zero set should be an arithmetically rigid object rather than an arbitrary
set of lags.

Experiment (Experimenter): the triangle inequality for `Nat.dist` gives subadditivity in
one line once `i + (k + l) = (i + k) + l` is used. For gcd-closure the decisive step is
that periods of a one-sided infinite word are closed under truncated subtraction, since
`x (i + (p - q) + q) = x (i + p)` whenever `q ≤ p`; Euclidean strong induction then
produces the gcd.

Analysis (Analyst): the gcd-closure is what upgrades "submonoid" to "multiples of one
number". Without it, the unison lags could a priori be, e.g., `{0, 4, 8, 9, 12, …}`; with
it, `4, 9 ∈ S` forces `1 ∈ S`, i.e. a constant melody.

Critique (Critic): the sup defining `maxInterval` needs the alphabet bound to be finite;
all statements therefore carry an explicit `IsDigitMelody b x` hypothesis, and the
structure theorem carries the (necessary) hypothesis that some positive period exists.
The aperiodic branch is stated separately (`unisonLags_eq_bot_of_aperiodic`).
-/

namespace TropicalMusicalDigits

open Finset Tropical

/-! ### Periods of a digit melody -/

/-- A lag `p` is a *unison lag* (a period) when every position pair `(i, i + p)` realizes
the interval `0`. -/
def IsPeriod (x : ℕ → ℕ) (p : ℕ) : Prop := ∀ i, x i = x (i + p)

lemma isPeriod_zero (x : ℕ → ℕ) : IsPeriod x 0 := fun i => by simp

lemma IsPeriod.add {x : ℕ → ℕ} {p q : ℕ} (hp : IsPeriod x p) (hq : IsPeriod x q) :
    IsPeriod x (p + q) := by
  intro i
  rw [hp i, hq (i + p), ← add_assoc]

lemma IsPeriod.nsmul {x : ℕ → ℕ} {p : ℕ} (hp : IsPeriod x p) : ∀ m, IsPeriod x (m * p)
  | 0 => by simpa using isPeriod_zero x
  | (m + 1) => by
      have := (hp.nsmul m).add hp
      simpa [add_mul, add_comm, add_left_comm, add_assoc] using this

/-- Periods of a one-sided infinite melody are closed under truncated subtraction. -/
lemma IsPeriod.sub {x : ℕ → ℕ} {p q : ℕ} (hp : IsPeriod x p) (hq : IsPeriod x q)
    (hle : q ≤ p) : IsPeriod x (p - q) := by
  intro i
  have h : i + (p - q) + q = i + p := by omega
  calc x i = x (i + p) := hp i
    _ = x (i + (p - q) + q) := by rw [h]
    _ = x (i + (p - q)) := (hq (i + (p - q))).symm

lemma IsPeriod.mod {x : ℕ → ℕ} {p q : ℕ} (hp : IsPeriod x p) (hq : IsPeriod x q) :
    IsPeriod x (q % p) := by
  rcases Nat.eq_zero_or_pos p with rfl | hpos
  · simpa using hq
  · have hmul : IsPeriod x (q / p * p) := hp.nsmul _
    have hle : q / p * p ≤ q := Nat.div_mul_le_self q p
    have hsub := hq.sub hmul hle
    have hdm : q / p * p + q % p = q := Nat.div_add_mod' q p
    have heq : q - q / p * p = q % p := by omega
    rwa [heq] at hsub

/-- **Unison lags are closed under greatest common divisors.**  This is the arithmetic
rigidity that makes the unison-lag monoid a monoid of multiples. -/
theorem isPeriod_gcd {x : ℕ → ℕ} :
    ∀ p q : ℕ, IsPeriod x p → IsPeriod x q → IsPeriod x (Nat.gcd p q) := by
  intro p
  induction p using Nat.strong_induction_on with
  | _ p ih =>
    intro q hp hq
    rcases Nat.eq_zero_or_pos p with rfl | hpos
    · simpa using hq
    · rw [Nat.gcd_rec]
      exact ih (q % p) (Nat.mod_lt _ hpos) p (hp.mod hq) hp

/-- The set of unison lags of a melody, as an additive submonoid of the lag monoid `ℕ`. -/
def unisonLags (x : ℕ → ℕ) : AddSubmonoid ℕ where
  carrier := {p | IsPeriod x p}
  add_mem' hp hq := IsPeriod.add hp hq
  zero_mem' := isPeriod_zero x

@[simp] lemma mem_unisonLags {x : ℕ → ℕ} {p : ℕ} : p ∈ unisonLags x ↔ IsPeriod x p :=
  Iff.rfl

/-! ### The minimal period and the structure of the unison-lag monoid -/

/-- The minimal positive unison lag (`0` if the melody is aperiodic). -/
noncomputable def minPeriod (x : ℕ → ℕ) : ℕ := sInf {p | 0 < p ∧ IsPeriod x p}

lemma minPeriod_spec {x : ℕ → ℕ} (h : ∃ p, 0 < p ∧ IsPeriod x p) :
    0 < minPeriod x ∧ IsPeriod x (minPeriod x) :=
  Nat.sInf_mem h

lemma minPeriod_le {x : ℕ → ℕ} {p : ℕ} (hp : 0 < p) (h : IsPeriod x p) :
    minPeriod x ≤ p :=
  Nat.sInf_le ⟨hp, h⟩

/-- Every unison lag is a multiple of the minimal period. -/
theorem minPeriod_dvd {x : ℕ → ℕ} (hne : ∃ p, 0 < p ∧ IsPeriod x p) {p : ℕ}
    (hp : IsPeriod x p) : minPeriod x ∣ p := by
  obtain ⟨hd0, hd⟩ := minPeriod_spec hne
  rcases Nat.eq_zero_or_pos p with rfl | hpos
  · exact dvd_zero _
  · have hg : IsPeriod x (Nat.gcd (minPeriod x) p) := isPeriod_gcd _ _ hd hp
    have hgpos : 0 < Nat.gcd (minPeriod x) p := Nat.gcd_pos_of_pos_left _ hd0
    have hle : minPeriod x ≤ Nat.gcd (minPeriod x) p := minPeriod_le hgpos hg
    have hge : Nat.gcd (minPeriod x) p ≤ minPeriod x := Nat.gcd_le_left _ hd0
    have : Nat.gcd (minPeriod x) p = minPeriod x := le_antisymm hge hle
    exact this ▸ Nat.gcd_dvd_right _ _

/-- **Rigidity of the unison-lag monoid.**  For a melody with at least one positive
period, the lags at which the melody sounds a unison are exactly the multiples of a
single number, its minimal period. -/
theorem unisonLags_eq_multiples {x : ℕ → ℕ} (hne : ∃ p, 0 < p ∧ IsPeriod x p) :
    (unisonLags x : Set ℕ) = {p | minPeriod x ∣ p} := by
  ext p
  constructor
  · exact fun hp => minPeriod_dvd hne hp
  · rintro ⟨m, rfl⟩
    show IsPeriod x (minPeriod x * m)
    rw [mul_comm]
    exact (minPeriod_spec hne).2.nsmul m

/-- For an aperiodic melody the unison-lag monoid is trivial. -/
theorem unisonLags_eq_bot_of_aperiodic {x : ℕ → ℕ} (h : ¬ ∃ p, 0 < p ∧ IsPeriod x p) :
    unisonLags x = ⊥ := by
  ext p
  simp only [mem_unisonLags, AddSubmonoid.mem_bot]
  constructor
  · intro hp
    by_contra hne
    exact h ⟨p, Nat.pos_of_ne_zero hne, hp⟩
  · rintro rfl; exact isPeriod_zero x

/-- Two coprime unison lags force a constant melody: an extreme form of the rigidity. -/
theorem constant_of_coprime_periods {x : ℕ → ℕ} {p q : ℕ} (hp : IsPeriod x p)
    (hq : IsPeriod x q) (hcop : Nat.Coprime p q) : ∀ i, x i = x 0 := by
  have h1 : IsPeriod x 1 := by
    have := isPeriod_gcd p q hp hq
    rwa [hcop] at this
  intro i
  induction i with
  | zero => rfl
  | succ n ih => rw [← ih]; exact (h1 n).symm

/-! ### The lag spectrum as a tropical seminorm -/

/-- The lag spectrum: the largest pitch interval realized by a position pair at lag `ℓ`. -/
noncomputable def maxInterval (x : ℕ → ℕ) (ℓ : ℕ) : ℕ := sSup (Set.range (lagInterval x ℓ))

lemma bddAbove_lagInterval {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ : ℕ) :
    BddAbove (Set.range (lagInterval x ℓ)) := by
  refine ⟨b, ?_⟩
  rintro y ⟨i, rfl⟩
  exact (lagInterval_lt_base hx ℓ i).le

lemma lagInterval_le_maxInterval {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ i : ℕ) :
    lagInterval x ℓ i ≤ maxInterval x ℓ :=
  le_csSup (bddAbove_lagInterval hx ℓ) ⟨i, rfl⟩

lemma maxInterval_le {x : ℕ → ℕ} {ℓ M : ℕ} (h : ∀ i, lagInterval x ℓ i ≤ M) :
    maxInterval x ℓ ≤ M := by
  refine csSup_le ⟨lagInterval x ℓ 0, ⟨0, rfl⟩⟩ ?_
  rintro y ⟨i, rfl⟩
  exact h i

lemma maxInterval_lt_base {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ : ℕ) :
    maxInterval x ℓ < b := by
  have h0 := lagInterval_lt_base hx ℓ 0
  have : maxInterval x ℓ ≤ b - 1 :=
    maxInterval_le fun i => by have := lagInterval_lt_base hx ℓ i; omega
  omega

/-- Decimal melodies: the lag spectrum never exceeds nine semitones, so it never reaches
the twelve semitones of an octave, at any lag. -/
theorem maxInterval_le_nine {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (ℓ : ℕ) :
    maxInterval x ℓ ≤ 9 := by
  have := maxInterval_lt_base hx ℓ; omega

/-- **Subadditivity of the lag spectrum.**  Interval sizes at composite lags are
controlled by their factors: this is the max-plus triangle inequality on the lag monoid. -/
theorem maxInterval_add_le {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (k l : ℕ) :
    maxInterval x (k + l) ≤ maxInterval x k + maxInterval x l := by
  refine maxInterval_le fun i => ?_
  have htri : interval x i (i + (k + l))
      ≤ interval x i (i + k) + interval x (i + k) (i + (k + l)) :=
    interval_triangle x i (i + k) (i + (k + l))
  have hassoc : i + (k + l) = (i + k) + l := by omega
  have h1 : interval x i (i + k) ≤ maxInterval x k :=
    lagInterval_le_maxInterval hx k i
  have h2 : interval x (i + k) ((i + k) + l) ≤ maxInterval x l :=
    lagInterval_le_maxInterval hx l (i + k)
  simp only [lagInterval] at *
  rw [hassoc] at htri ⊢
  omega

/-- The lag spectrum vanishes exactly at the unison lags. -/
theorem maxInterval_eq_zero_iff {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ : ℕ) :
    maxInterval x ℓ = 0 ↔ IsPeriod x ℓ := by
  constructor
  · intro h i
    have := lagInterval_le_maxInterval hx ℓ i
    rw [h, Nat.le_zero] at this
    exact (interval_eq_zero_iff x i (i + ℓ)).1 this
  · intro h
    refine Nat.le_zero.1 (maxInterval_le fun i => ?_)
    simp [lagInterval, interval, ← h i]

/-- The tropical lag spectrum: the lag spectrum viewed inside the tropical semiring,
where addition is `min` and multiplication is `+`. -/
noncomputable def tropLagSpectrum (x : ℕ → ℕ) (ℓ : ℕ) : Tropical ℕ :=
  trop (maxInterval x ℓ)

/-- **The lag spectrum is a tropical seminorm on the lag monoid**: it is submultiplicative
for the tropical product, which is ordinary addition of lags. -/
theorem tropLagSpectrum_submul {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (k l : ℕ) :
    tropLagSpectrum x (k + l) ≤ tropLagSpectrum x k * tropLagSpectrum x l := by
  have h := maxInterval_add_le hx k l
  simpa [tropLagSpectrum, ← trop_add] using trop_monotone h

/-- The kernel of the tropical seminorm — the fibre over the tropical unit `1 = trop 0` —
is precisely the unison-lag monoid. -/
theorem tropLagSpectrum_eq_one_iff {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ : ℕ) :
    tropLagSpectrum x ℓ = 1 ↔ ℓ ∈ unisonLags x := by
  rw [tropLagSpectrum, ← trop_zero, trop_inj_iff, mem_unisonLags]
  exact maxInterval_eq_zero_iff hx ℓ

/-- Consequently the tropical unit fibre of the spectrum is an additive submonoid of the
lag monoid: a tropical restatement of `unisonLags`. -/
theorem tropLagSpectrum_unit_fibre_add_closed {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x)
    {k l : ℕ} (hk : tropLagSpectrum x k = 1) (hl : tropLagSpectrum x l = 1) :
    tropLagSpectrum x (k + l) = 1 := by
  rw [tropLagSpectrum_eq_one_iff hx] at hk hl ⊢
  exact AddSubmonoid.add_mem _ hk hl

/-! ### Lag twelve, resolved -/

/-- **Perfect lag-12 correlation is a unison phenomenon governed by a divisor of 12.**
If a decimal melody realizes the interval `0` at every position pair of lag `12`, then its
minimal period divides `12`; moreover every interval it realizes at lag `12` is a unison,
and never the twelve-semitone octave. -/
theorem lag_twelve_unison_not_octave {x : ℕ → ℕ} (hx : IsDigitMelody 10 x)
    (h : maxInterval x 12 = 0) :
    minPeriod x ∣ 12 ∧ (∀ i, lagInterval x 12 i = 0) ∧ (∀ i, lagInterval x 12 i ≠ 12) := by
  have hper : IsPeriod x 12 := (maxInterval_eq_zero_iff hx 12).1 h
  have hne : ∃ p, 0 < p ∧ IsPeriod x p := ⟨12, by norm_num, hper⟩
  refine ⟨minPeriod_dvd hne hper, fun i => ?_, fun i => ?_⟩
  · have := lagInterval_le_maxInterval hx 12 i
    omega
  · have := lagInterval_le_nine hx 12 i
    omega

/-- The converse direction of the same dichotomy: a decimal melody whose lag-12 spectrum
is *nonzero* has at least one lag-12 position pair sounding a nontrivial interval, of size
between one and nine semitones — again never an octave. -/
theorem lag_twelve_nontrivial_interval {x : ℕ → ℕ} (hx : IsDigitMelody 10 x)
    (h : maxInterval x 12 ≠ 0) :
    ∃ i, 1 ≤ lagInterval x 12 i ∧ lagInterval x 12 i ≤ 9 := by
  by_contra hcon
  push_neg at hcon
  refine h (Nat.le_zero.1 (maxInterval_le fun i => ?_))
  have h9 := lagInterval_le_nine hx 12 i
  by_cases h1 : 1 ≤ lagInterval x 12 i
  · have := hcon i h1; omega
  · omega

/-- The square wave of amplitude `7` and half-period `12` has lag-12 spectrum exactly `7`:
maximal temporal regularity at lag 12 coexisting with *no* unison at all at that lag. -/
theorem squareWave_maxInterval_twelve : maxInterval (squareWave 7 12) 12 = 7 := by
  have hconst : ∀ i, lagInterval (squareWave 7 12) 12 i = 7 :=
    fun i => squareWave_lagInterval (by norm_num) i
  refine le_antisymm (maxInterval_le fun i => (hconst i).le) ?_
  have := lagInterval_le_maxInterval
    (squareWave_isDigitMelody (v := 7) (ℓ := 12) (b := 10) (by norm_num)) 12 0
  rw [hconst 0] at this
  exact this

/-- The same square wave is `24`-periodic, so its lag-24 spectrum vanishes: the lag
spectrum is subadditive but very far from additive, and a vanishing spectrum at lag `2ℓ`
says nothing about the spectrum at lag `ℓ`. -/
theorem squareWave_maxInterval_twentyfour : maxInterval (squareWave 7 12) 24 = 0 := by
  refine Nat.le_zero.1 (maxInterval_le fun i => ?_)
  have hdiv : (i + 24) / 12 = i / 12 + 2 := by omega
  simp [lagInterval, interval, squareWave, hdiv, Nat.add_mod_right, Nat.dist]

end TropicalMusicalDigits