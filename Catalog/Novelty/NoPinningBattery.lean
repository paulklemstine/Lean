/-
# The poly(log N) battery: residues, Jacobi symbols and gcds

Companion to `Novelty/NoPinningLemma.lean`.  Here we exhibit the concrete
`poly(log N)`-computable battery of the COMPENSATING-PARTNER experiment as a
family of modulus-`L` observables, with `L = modLevel B = 4 · lcm(1,…,B)`:

* `residueObs m : N ↦ N mod m` for `1 ≤ m ≤ B`,
* `jacobiObs a : N ↦ (a | N)` (Jacobi symbol) for `1 ≤ a ≤ B`,
* `gcdObs c : N ↦ gcd(N, c)` for `1 ≤ c ≤ B`.

and we prove:

* `isModObs_residueObs`, `isModObs_jacobiObs`, `isModObs_gcdObs` — each channel
  is a modulus-`L` observable;
* `fullBattery_no_pinning` — the entire battery is blind: for every target `N₀`
  and every candidate prime `p` coprime to `L` there are infinitely many primes
  `q` with identical battery readouts on `p·q` and `N₀`;
* `prime_dvd_modLevel_iff` — the pinned primes at level `B` are exactly the
  primes `≤ B` (plus `2`), so `card ≤ B`: `poly(log N)` many;
* `large_prime_never_pinned` — every prime candidate `p > B` survives;
* `Int.gcd_eval_eq_gcd_coeff_zero` — **barrier 1**: `gcd(f(N), N) = gcd(f(0), N)`
  for every integer polynomial `f`; polynomial gcds are functions of `N` alone
  and add no pinning power.  In particular `gcd(N + k, N) = gcd(k, N)`.
-/

import Mathlib
import Novelty.NoPinningLemma

namespace Novelty.NoPinning

/-! ## The modulus of a level-`B` battery -/

/-- `lcm(1, …, B)`. -/
def lcmUpTo (B : ℕ) : ℕ := (Finset.Icc 1 B).lcm id

/-- The modulus of the level-`B` battery: `4 · lcm(1,…,B)`.  The factor `4`
accommodates the conductor of the Jacobi symbols. -/
def modLevel (B : ℕ) : ℕ := 4 * lcmUpTo B

theorem lcmUpTo_ne_zero (B : ℕ) : lcmUpTo B ≠ 0 := by
  unfold lcmUpTo
  intro h
  rw [Finset.lcm_eq_zero_iff] at h
  simp only [Finset.mem_Icc, id_eq] at h
  obtain ⟨m, hm, hm0⟩ := h
  omega

theorem dvd_lcmUpTo {B m : ℕ} (h1 : 1 ≤ m) (h2 : m ≤ B) : m ∣ lcmUpTo B := by
  have : m ∈ Finset.Icc 1 B := Finset.mem_Icc.2 ⟨h1, h2⟩
  simpa [lcmUpTo] using Finset.dvd_lcm (f := (id : ℕ → ℕ)) this

theorem modLevel_ne_zero (B : ℕ) : modLevel B ≠ 0 :=
  mul_ne_zero (by norm_num) (lcmUpTo_ne_zero B)

instance (B : ℕ) : NeZero (modLevel B) := ⟨modLevel_ne_zero B⟩

theorem four_dvd_modLevel (B : ℕ) : 4 ∣ modLevel B := ⟨lcmUpTo B, rfl⟩

theorem two_dvd_modLevel (B : ℕ) : 2 ∣ modLevel B :=
  dvd_trans ⟨2, rfl⟩ (four_dvd_modLevel B)

/-! ## The three observable channels -/

/-- Residue channel: `N ↦ N mod m`. -/
def residueObs (m : ℕ) : ℕ → ℤ := fun N => (N % m : ℕ)

/-- Jacobi channel: `N ↦ (a | N)`. -/
def jacobiObs (a : ℕ) : ℕ → ℤ := fun N => jacobiSym (a : ℤ) N

/-- gcd channel: `N ↦ gcd(N, c)`. -/
def gcdObs (c : ℕ) : ℕ → ℤ := fun N => (Nat.gcd N c : ℕ)

theorem isModObs_residueObs {L m : ℕ} (h : m ∣ L) : IsModObs L (residueObs m) := by
  intro a b _ _ hab
  simp only [residueObs, Nat.cast_inj]
  exact hab.of_dvd h

theorem isModObs_gcdObs {L c : ℕ} (h : c ∣ L) : IsModObs L (gcdObs c) := by
  intro a b _ _ hab
  simp only [gcdObs, Nat.cast_inj]
  exact (hab.of_dvd h).gcd_eq

theorem isModObs_jacobiObs {L a : ℕ} (h : 4 * a ∣ L) : IsModObs L (jacobiObs a) := by
  intro m n hm hn hmn
  simp only [jacobiObs]
  rw [jacobiSym.mod_right' a hm, jacobiSym.mod_right' a hn, hmn.of_dvd h]

/-- The level-`B` battery: all residues, Jacobi symbols and gcds with parameter
in `{1, …, B}`.  Every entry is computable in `poly(log N)` time. -/
def fullBattery (B : ℕ) : List (ℕ → ℤ) :=
  (List.range B).map (fun i => residueObs (i + 1)) ++
  (List.range B).map (fun i => jacobiObs (i + 1)) ++
  (List.range B).map (fun i => gcdObs (i + 1))

theorem fullBattery_isModObs (B : ℕ) :
    ∀ f ∈ fullBattery B, IsModObs (modLevel B) f := by
  intro f hf
  have hdvd : ∀ i : ℕ, i < B → (i + 1) ∣ lcmUpTo B := fun i hi =>
    dvd_lcmUpTo (Nat.le_add_left 1 i) (by omega)
  simp only [fullBattery, List.mem_append, List.mem_map, List.mem_range] at hf
  rcases hf with (⟨i, hi, rfl⟩ | ⟨i, hi, rfl⟩) | ⟨i, hi, rfl⟩
  · exact isModObs_residueObs (dvd_trans (hdvd i hi) ⟨4, by rw [modLevel]; ring⟩)
  · exact isModObs_jacobiObs (mul_dvd_mul_left 4 (hdvd i hi))
  · exact isModObs_gcdObs (dvd_trans (hdvd i hi) ⟨4, by rw [modLevel]; ring⟩)

/-- **The battery is blind.**  For any target `N₀` and any candidate prime `p`,
both coprime to `4·lcm(1,…,B)`, infinitely many primes `q` produce a semiprime
`p·q` whose *entire* level-`B` readout — every residue `N mod m`, every Jacobi
symbol `(a | N)`, every gcd `gcd(N, c)` with parameter `≤ B` — coincides with
that of `N₀`. -/
theorem fullBattery_no_pinning (B : ℕ) {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ (modLevel B)) (hp : Nat.Coprime p (modLevel B)) :
    {q : ℕ | q.Prime ∧
      batteryValue (fullBattery B) (p * q) = batteryValue (fullBattery B) N₀}.Infinite :=
  battery_no_pinning (modLevel B) (two_dvd_modLevel B) (fullBattery B)
    (fullBattery_isModObs B) hN hp

/-! ## The pinned set at level `B` -/

theorem lcmUpTo_dvd_prod (B : ℕ) : lcmUpTo B ∣ ∏ i ∈ Finset.Icc 1 B, i :=
  Finset.lcm_dvd fun _ hi => Finset.dvd_prod_of_mem _ hi

/-- **The pinned primes at level `B` are exactly the primes `≤ B` (and `2`).**
Everything else remains a consistent candidate factor. -/
theorem prime_dvd_modLevel_iff {B p : ℕ} (hp : p.Prime) :
    p ∣ modLevel B ↔ (p = 2 ∨ p ≤ B) := by
  constructor
  · intro h
    rcases (Nat.Prime.dvd_mul hp).1 h with h4 | hlcm
    · left
      have : p ∣ 2 ^ 2 := by simpa using h4
      have := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 (hp.dvd_of_dvd_pow this)
      exact this
    · right
      have hprod : p ∣ ∏ i ∈ Finset.Icc 1 B, i := hlcm.trans (lcmUpTo_dvd_prod B)
      obtain ⟨i, hi, hpi⟩ := (Prime.dvd_finset_prod_iff hp.prime id).1 hprod
      have hiB := (Finset.mem_Icc.1 hi).2
      have hi1 := (Finset.mem_Icc.1 hi).1
      have hpi' : p ∣ i := by simpa using hpi
      exact le_trans (Nat.le_of_dvd (by omega) hpi') hiB
  · rintro (rfl | hpB)
    · exact dvd_trans ⟨2, rfl⟩ (four_dvd_modLevel B)
    · exact dvd_trans (dvd_lcmUpTo hp.one_lt.le hpB) ⟨4, by rw [modLevel]; ring⟩

/-- Every prime candidate larger than the battery parameter `B` (and larger than
`2`) survives the whole level-`B` battery, with infinitely many compensating
partners. -/
theorem large_prime_never_pinned {B p : ℕ} (hp : p.Prime) (hpB : B < p) {N₀ : ℕ}
    (hN : Nat.Coprime N₀ (modLevel B)) (hB : 2 ≤ B) :
    {q : ℕ | q.Prime ∧
      batteryValue (fullBattery B) (p * q) = batteryValue (fullBattery B) N₀}.Infinite := by
  refine fullBattery_no_pinning B hN ((Nat.Prime.coprime_iff_not_dvd hp).2 ?_)
  intro hdvd
  rcases (prime_dvd_modLevel_iff hp).1 hdvd with rfl | h
  · omega
  · omega

/-- The pinned set at level `B` has at most `B` elements: `poly(log N)` many,
against `~ √N / log N` prime candidates. -/
theorem pinnedPrimes_modLevel_card_le {B : ℕ} (hB : 2 ≤ B) :
    (pinnedPrimes (modLevel B)).card ≤ B := by
  have hsub : pinnedPrimes (modLevel B) ⊆ Finset.Icc 2 B := by
    intro p hp
    obtain ⟨hp1, hp2⟩ := (mem_pinnedPrimes (modLevel_ne_zero B)).1 hp
    rcases (prime_dvd_modLevel_iff hp1).1 hp2 with rfl | h
    · exact Finset.mem_Icc.2 ⟨le_rfl, hB⟩
    · exact Finset.mem_Icc.2 ⟨hp1.two_le, h⟩
  calc (pinnedPrimes (modLevel B)).card ≤ (Finset.Icc 2 B).card :=
        Finset.card_le_card hsub
    _ ≤ B := by rw [Nat.card_Icc]; omega

/-! ## Barrier 1: polynomial gcds are functions of `N` -/

/-- **Barrier 1.**  For every integer polynomial `f`, `gcd(f(N), N) = gcd(f(0), N)`.
A gcd probe against a polynomial value therefore carries no information beyond
the constant term of the polynomial and `N` itself: it cannot separate the two
factors of a semiprime. -/
theorem Int.gcd_eval_eq_gcd_coeff_zero (f : Polynomial ℤ) (N : ℤ) :
    Int.gcd (f.eval N) N = Int.gcd (f.coeff 0) N := by
  have hdvd : N ∣ f.eval N - f.eval 0 := by
    simpa using Polynomial.sub_dvd_eval_sub N 0 f
  have h0 : f.eval 0 = f.coeff 0 := (Polynomial.coeff_zero_eq_eval_zero f).symm
  obtain ⟨t, ht⟩ := hdvd
  have hval : f.eval N = f.coeff 0 + N * t := by
    rw [← h0]; linarith [ht]
  rw [hval, Int.gcd_add_mul_left_left N (f.coeff 0) t]

/-- The shift case, verified in the experiment: `gcd(N + k, N) = gcd(k, N)`. -/
theorem Nat.gcd_add_left_eq (N k : ℕ) : Nat.gcd (N + k) N = Nat.gcd k N :=
  Nat.gcd_self_add_left N k

/-! ## A concrete instance -/

/-- A concrete compensating pair at level `B = 3` (modulus `4·lcm(1,2,3) = 24`):
the target `N₀ = 35 = 5·7` and the semiprime `11 · 73 = 803` have identical
level-3 readouts, although they share no prime factor.  (`35 ≡ 803 ≡ 11 mod 24`.) -/
theorem compensation_example :
    batteryValue (fullBattery 3) (11 * 73) = batteryValue (fullBattery 3) 35 := by
  refine List.map_congr_left fun f hf => ?_
  exact fullBattery_isModObs 3 f hf (Nat.odd_iff.mpr rfl) (Nat.odd_iff.mpr rfl) rfl

end Novelty.NoPinning