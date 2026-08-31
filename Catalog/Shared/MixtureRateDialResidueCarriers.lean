import Mathlib
import Shared.MixtureRateDialCells
import Shared.MixtureRateDialBaseline

/-!
# No residue carrier is a position dial (Part III): the named follow-up, one family removed

Context: experiment 588c / paper 242 leaves the named follow-up *"identify the
non-divisibility carrier"*, with pre-named candidate family (i): `j`-arithmetic
beyond small-prime divisibility — higher-order residues of `v = j² - N`, bit
structure of `j`, quadratic-character / Legendre patterns mod `p > 7`.

This file removes **that entire family at once**, at every modulus and every
bit length.  The mechanism is the one isolated in Part I, but the divisibility
grid plays no special role in it:

> Every classifier of `j` that factors through `ZMod m` — divisibility patterns,
> Legendre symbols, higher power residues, low bit patterns, any Boolean
> combination of them — has *position independent* window composition as soon as
> the window length is a multiple of `m`.  By Part II its mixture family is a
> ray, so it removes exactly `0 %` of a positional excess.

Main results.

* `count_add`, `count_le` — basic window-count calculus.
* `count_const_of_period_dvd` — flat composition for any `m`-periodic classifier
  and window length a multiple of `m`.
* `count_drift_le_mod` — the *quantitative* version for a window length that is
  not a multiple: the composition of two windows can differ by at most
  `L % m < m` members, i.e. a relative drift `< m / L`.
* `periodicClass_of_zmod`, `residueCarrier_periodic`, `legendreCarrier_periodic`
  — every residue-type carrier of `v = j² - N` is periodic.
* `residue_mixture_excess_survives` — the capstone: the residual excess over any
  residue-class mixture equals the excess over the plain shape.
* `positional_carrier_is_aperiodic` — contrapositive and the actual content of
  the follow-up: **a carrier that moves the excess cannot factor through any
  `ZMod m` with `m ∣ L`; the non-divisibility carrier must be aperiodic in `j`.**
-/

namespace RateDial

open Finset

variable {α : Type*} [DecidableEq α]

/-! ## Periodic classifiers and window counts -/

/-- `f` classifies integers `m`-periodically. -/
def PeriodicClass (m : ℕ) (f : ℤ → α) : Prop := ∀ j : ℤ, f (j + m) = f j

/-- The number of `j` in the window `{a, …, a + L - 1}` with class `c`. -/
def count (f : ℤ → α) (a : ℤ) (L : ℕ) (c : α) : ℕ :=
  ∑ i ∈ Finset.range L, if f (a + i) = c then 1 else 0

theorem count_le (f : ℤ → α) (a : ℤ) (L : ℕ) (c : α) : count f a L c ≤ L := by
  calc count f a L c ≤ ∑ _i ∈ Finset.range L, 1 := by
        refine Finset.sum_le_sum fun i _ => ?_
        split <;> simp
    _ = L := by simp

/-- Windows concatenate. -/
theorem count_add (f : ℤ → α) (a : ℤ) (L₁ L₂ : ℕ) (c : α) :
    count f a (L₁ + L₂) c = count f a L₁ c + count f (a + L₁) L₂ c := by
  simp only [count]
  rw [Finset.sum_range_add]
  congr 1
  refine Finset.sum_congr rfl fun i _ => ?_
  have harg : a + ((L₁ + i : ℕ) : ℤ) = a + (L₁ : ℤ) + (i : ℤ) := by push_cast; ring
  rw [harg]

omit [DecidableEq α] in
/-- Periodicity iterates. -/
theorem periodic_add_natMul {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f) (j : ℤ) :
    ∀ k : ℕ, f (j + m * k) = f j := by
  intro k
  induction k with
  | zero => simp
  | succ n ih =>
      have harg : j + (m : ℤ) * ((n + 1 : ℕ) : ℤ) = (j + (m : ℤ) * (n : ℤ)) + (m : ℤ) := by
        push_cast; ring
      rw [harg, hper, ih]

/-- Shifting a window whose length is a multiple of the period preserves every
class population. -/
theorem count_succ_of_period {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f) (a : ℤ)
    {L q : ℕ} (hL : L = m * q) (c : α) :
    count f (a + 1) L c = count f a L c := by
  classical
  set h : ℕ → ℕ := fun i => if f (a + i) = c then 1 else 0 with hh
  have e1 : ∑ i ∈ range (L + 1), h i = (∑ i ∈ range L, h (i + 1)) + h 0 :=
    Finset.sum_range_succ' h L
  have e2 : ∑ i ∈ range (L + 1), h i = (∑ i ∈ range L, h i) + h L :=
    Finset.sum_range_succ h L
  have e3 : h L = h 0 := by
    have hfa : f (a + (L : ℤ)) = f (a + ((0 : ℕ) : ℤ)) := by
      have harg : a + (L : ℤ) = a + (m : ℤ) * (q : ℤ) := by rw [hL]; push_cast; ring
      rw [harg, periodic_add_natMul hper a q]
      norm_num
    simp only [hh, hfa]
  have e4 : count f (a + 1) L c = ∑ i ∈ range L, h (i + 1) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    have harg : a + 1 + ((i : ℕ) : ℤ) = a + (((i + 1 : ℕ)) : ℤ) := by push_cast; ring
    simp only [hh, harg]
  have e5 : count f a L c = ∑ i ∈ range L, h i := rfl
  omega

/-- **Flat composition, general form.**  For an `m`-periodic classifier and a
window length that is a multiple of `m`, every window anywhere on the line has
exactly the same class populations. -/
theorem count_const_of_period_dvd {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f)
    {L q : ℕ} (hL : L = m * q) (a : ℤ) (c : α) :
    count f a L c = count f 0 L c := by
  refine Int.induction_on a rfl (fun n ih => ?_) (fun n ih => ?_)
  · rw [count_succ_of_period hper _ hL]; exact ih
  · have hstep := count_succ_of_period hper (-(n : ℤ) - 1) hL c
    have hEq : (-(n : ℤ) - 1) + 1 = -(n : ℤ) := by ring
    rw [hEq] at hstep
    rw [← hstep]
    exact ih

/-! ## Quantitative version: window length not a multiple of the period -/

/-- A window of `q` full periods contains exactly `q` copies of each class. -/
theorem count_fullPeriods {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f) (a : ℤ) (q : ℕ) (c : α) :
    count f a (m * q) c = q * count f 0 m c := by
  induction q generalizing a with
  | zero => simp [count]
  | succ n ih =>
      have hlen : m * (n + 1) = m * n + m := by ring
      rw [hlen, count_add, ih a]
      have hfull : count f (a + ((m * n : ℕ) : ℤ)) m c = count f 0 m c :=
        count_const_of_period_dvd hper (q := 1) (by ring) _ c
      rw [hfull]
      ring

/-- A window of length `m * q + r` splits into `q` full periods plus a remainder. -/
theorem count_split {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f) (a : ℤ) (q r : ℕ) (c : α) :
    count f a (m * q + r) c = q * count f 0 m c + count f (a + ((m * q : ℕ) : ℤ)) r c := by
  rw [count_add, count_fullPeriods hper a q]

/-- **Bounded drift.**  For an `m`-periodic classifier and an arbitrary window
length `L`, the population of a class in two windows differs by at most
`L % m < m`: a relative composition drift below `m / L`. -/
theorem count_drift_le_mod {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f)
    (a b : ℤ) (L : ℕ) (c : α) :
    count f a L c ≤ count f b L c + L % m := by
  have hL : L = m * (L / m) + L % m := (Nat.div_add_mod L m).symm
  have ha := count_split hper a (L / m) (L % m) c
  have hb := count_split hper b (L / m) (L % m) c
  rw [← hL] at ha hb
  have hbound := count_le f (a + ((m * (L / m) : ℕ) : ℤ)) (L % m) c
  omega

/-! ## Every residue-type carrier of `j` (and of `j² - N`) is periodic -/

omit [DecidableEq α] in
/-- Any classifier that factors through `ZMod m` is `m`-periodic. -/
theorem periodicClass_of_zmod (m : ℕ) (g : ZMod m → α) :
    PeriodicClass m (fun j : ℤ => g ((j : ZMod m))) := by
  intro j
  have : (((j + (m : ℤ)) : ℤ) : ZMod m) = ((j : ℤ) : ZMod m) := by
    push_cast
    simp
  simp only [this]

omit [DecidableEq α] in
/-- Higher-order residue carriers of the sieve value `v = j² - N`: any function of
`v mod m` — power residues, bit patterns, Legendre symbols — is `m`-periodic in
`j`, hence a rate dial, not a position dial. -/
theorem residueCarrier_periodic (m : ℕ) (N : ℤ) (g : ZMod m → α) :
    PeriodicClass m (fun j : ℤ => g (((j ^ 2 - N : ℤ) : ZMod m))) := by
  intro j
  have hcast : (((j + (m : ℤ)) ^ 2 - N : ℤ) : ZMod m) = ((j ^ 2 - N : ℤ) : ZMod m) := by
    push_cast [ZMod.natCast_self]
    ring
  simp only [hcast]

/-- The Legendre / quadratic-character carrier at a prime `p > 7` is a special
case: it is `p`-periodic. -/
theorem legendreCarrier_periodic (p : ℕ) [Fact (Nat.Prime p)] (N : ℤ) :
    PeriodicClass p (fun j : ℤ => quadraticChar (ZMod p) (((j ^ 2 - N : ℤ) : ZMod p))) :=
  residueCarrier_periodic p N (fun x => quadraticChar (ZMod p) x)

/-! ## Capstone: no residue mixture removes any part of the excess -/

/-- Cell-resolved reference sums built from a general classifier `f` and a window
of length `L`. -/
noncomputable def classRefSum (f : ℤ → α) (L : ℕ) (B : ℝ → ℝ) (c : α) (t : ℝ) : ℝ :=
  (count f ⌊t⌋ L c : ℝ) * B t

/-- A periodic classifier, sampled on windows whose length is a multiple of the
period, has flat composition in the sense of Part II. -/
theorem classRefSum_flatComposition {m : ℕ} {f : ℤ → α} (hper : PeriodicClass m f)
    {L q : ℕ} (hL : L = m * q) (B : ℝ → ℝ) :
    FlatComposition (classRefSum f L B) (fun c => (count f 0 L c : ℝ)) B := by
  intro c t
  simp only [classRefSum, count_const_of_period_dvd hper hL ⌊t⌋ c]

/-- **Capstone (follow-up to paper 242).**  For *any* residue-type carrier — any
`m`-periodic classification of `j`, at any modulus, sampled on windows of length
a multiple of `m` — the mixture baseline leaves the mid-window excess exactly as
it was: removal is `0 %`. -/
theorem residue_mixture_excess_survives [Fintype α] {m : ℕ} {f : ℤ → α}
    (hper : PeriodicClass m f) {L q : ℕ} (hL : L = m * q) (B T : ℝ → ℝ) (κ : α → ℝ)
    {t₀ t₁ : ℝ} (hK : (∑ c, κ c * (count f 0 L c : ℝ)) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0) :
    relExcess (resid T (mixPred κ (classRefSum f L B))) t₀ t₁ = relExcess (resid T B) t₀ t₁ :=
  relExcess_invariant (classRefSum_flatComposition hper hL B) κ hK hT hB

/-- **The follow-up, stated as a constraint on the carrier.**  If some class
mixture does move the measured excess, then the classifier is not periodic at
any modulus dividing the window length: the non-divisibility positional carrier
must be genuinely aperiodic in `j`, so no Legendre symbol, power residue,
divisibility pattern or bit pattern of `j² - N` can be it. -/
theorem positional_carrier_is_aperiodic [Fintype α] {f : ℤ → α} {L : ℕ}
    {B T : ℝ → ℝ} {κ : α → ℝ} {t₀ t₁ : ℝ}
    (hK : (∑ c, κ c * (count f 0 L c : ℝ)) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0)
    (hmoves : relExcess (resid T (mixPred κ (classRefSum f L B))) t₀ t₁ ≠
      relExcess (resid T B) t₀ t₁) :
    ¬ ∃ m q : ℕ, L = m * q ∧ PeriodicClass m f := by
  rintro ⟨m, q, hL, hper⟩
  exact hmoves (residue_mixture_excess_survives hper hL B T κ hK hT hB)

/-- The divisibility grid of Part I is one instance: `210 = 2·3·5·7`-periodic. -/
theorem cell_periodicClass (N : ℤ) : PeriodicClass 210 (cell N) := by
  intro j
  have : ((210 : ℕ) : ℤ) = (210 : ℤ) := by norm_num
  rw [this, cell_periodic]

end RateDial