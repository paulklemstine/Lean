import Mathlib
import Shared.QSFactorBaseDimension

/-!
# Round 42, item 3: `Q` is not a free parameter — the factor base *is* the split set

Measurement (round 42, `realqs` execution): every one of the 2,215 smooth sieve
values had all its prime factors in the split set.  This file proves that this is
not an empirical regularity but a theorem, so the quantity `Q(N,B)` that proposal
P4 wanted to move is already *fixed* by the sieve polynomial.

* `legendreSym_eq_one_of_dvd_qsValue` — a prime `r ∤ N` dividing `x² - N` forces
  the Legendre symbol `(N / r) = +1` (for every prime, including `r = 2`).
* `sieveReachable` / `sieveReachable_eq_admissiblePrimes` — the primes `≤ B`
  that divide **some** sieve value are *exactly* the admissible primes of
  `Catalog.Shared.QSFactorBaseDimension`: nothing outside is ever hit, and every
  admissible prime is hit.
* `admissiblePrimes_eq_ramified_union_split` — the admissible set is the
  disjoint union of the ramified primes `r ∣ N` and the split primes
  `(N / r) = +1`.
* `qs_smooth_iff_admissible_support` — a sieve value is `B`-smooth iff its prime
  support lies in the admissible (split ∪ ramified) set; so the column space of the
  relation matrix is pinned to the split set, independently of any design choice
  short of changing `B` or the polynomial.
* `admissible_card_le_factorBase` — `Q(N,B) ≤ π(B)` with the exact deficit being
  the inert primes.
-/

namespace QSSplitForcing

open Finset QSDimension QSRelationPool SmoothSparsity

/-- **Sieve divisibility forces a split prime.**  If a prime `r` with `r ∤ N`
divides a sieve value `x² - N`, then `(N / r) = +1`. -/
theorem legendreSym_eq_one_of_dvd_qsValue {r : ℕ} [Fact r.Prime] {N x : ℤ}
    (hdvd : (r : ℤ) ∣ qsValue N x) (hN : ¬ (r : ℤ) ∣ N) :
    legendreSym r N = 1 := by
  have hne : ((N : ZMod r)) ≠ 0 := by
    rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  exact (legendreSym.eq_one_iff r hne).2 (isSquare_of_dvd_qsValue hdvd)

open Classical in
/-- The *sieve-reachable* primes: primes `≤ B` dividing at least one value
`x² - N`.  This is the set of columns a single-polynomial sieve can ever touch. -/
noncomputable def sieveReachable (N : ℤ) (B : ℕ) : Finset ℕ :=
  (factorBase B).filter (fun p => ∃ x : ℤ, (p : ℤ) ∣ qsValue N x)

/-- **The factor base is the split set.**  The primes hit by the sieve are
exactly the admissible primes. -/
theorem sieveReachable_eq_admissiblePrimes (N : ℤ) (B : ℕ) :
    sieveReachable N B = admissiblePrimes N B := by
  classical
  ext p
  simp only [sieveReachable, admissiblePrimes, Finset.mem_filter]
  constructor
  · rintro ⟨hp, x, hx⟩
    exact ⟨hp, isSquare_of_dvd_qsValue hx⟩
  · rintro ⟨hp, hsq⟩
    have hpr : p.Prime := (mem_factorBase.1 hp).1
    haveI : NeZero p := ⟨hpr.ne_zero⟩
    exact ⟨hp, (exists_dvd_qsValue_iff_isSquare N).2 hsq⟩

open Classical in
/-- **Ramified ∪ split decomposition.**  The admissible primes are exactly the
primes `r ≤ B` with `r ∣ N` together with those with `(N / r) = +1`. -/
theorem admissiblePrimes_eq_ramified_union_split (N : ℤ) (B : ℕ) :
    admissiblePrimes N B =
      (factorBase B).filter (fun r : ℕ => (r : ℤ) ∣ N) ∪
      (factorBase B).filter (fun r : ℕ => ∃ h : r.Prime,
        @legendreSym r ⟨h⟩ N = 1) := by
  ext r
  simp only [admissiblePrimes, Finset.mem_union, Finset.mem_filter]
  constructor
  · rintro ⟨hr, hsq⟩
    have hpr : r.Prime := (mem_factorBase.1 hr).1
    haveI : Fact r.Prime := ⟨hpr⟩
    by_cases hN : (r : ℤ) ∣ N
    · exact Or.inl ⟨hr, hN⟩
    · refine Or.inr ⟨hr, hpr, ?_⟩
      have hne : ((N : ZMod r)) ≠ 0 := by
        rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
      exact (legendreSym.eq_one_iff r hne).2 hsq
  · rintro (⟨hr, hN⟩ | ⟨hr, hpr, hleg⟩)
    · refine ⟨hr, ⟨0, ?_⟩⟩
      rw [(ZMod.intCast_zmod_eq_zero_iff_dvd N r).2 hN]; ring
    · haveI : Fact r.Prime := ⟨hpr⟩
      refine ⟨hr, ?_⟩
      have hne : ((N : ZMod r)) ≠ 0 := by
        intro h0
        have : legendreSym r N = 0 := (legendreSym.eq_zero_iff r N).2 h0
        rw [this] at hleg; exact absurd hleg (by norm_num)
      exact (legendreSym.eq_one_iff r hne).1 hleg

/-- **Smoothness of a sieve value is smoothness over the split set.**  For a
sieve value `v = x² - N`, being `B`-smooth is equivalent to having its
whole prime support inside the admissible set. -/
theorem qs_smooth_iff_admissible_support {B : ℕ} {N x : ℤ} {v : ℕ}
    (hval : (v : ℤ) = x ^ 2 - N) :
    (∀ p ∈ v.primeFactors, p ≤ B) ↔ v.primeFactors ⊆ admissiblePrimes N B := by
  constructor
  · intro hsm p hp
    have hfac : v.factorization p ≠ 0 := by
      rw [← Finsupp.mem_support_iff, Nat.support_factorization]; exact hp
    exact smooth_qsValue_support hval hsm p hfac
  · intro hsub p hp
    exact (mem_factorBase.1 (admissiblePrimes_subset N B (hsub hp))).2

open Classical in
/-- `Q(N,B) ≤ π(B)`, with the deficit counted exactly by the primes that are
neither ramified nor split (the inert primes). -/
theorem admissible_card_add_inert (N : ℤ) (B : ℕ) :
    (admissiblePrimes N B).card +
      ((factorBase B).filter (fun p => ¬ IsSquare ((N : ZMod p)))).card =
      (factorBase B).card := by
  classical
  unfold admissiblePrimes
  exact Finset.card_filter_add_card_filter_not _

theorem admissible_card_le_factorBase (N : ℤ) (B : ℕ) :
    (admissiblePrimes N B).card ≤ (factorBase B).card :=
  Finset.card_le_card (admissiblePrimes_subset N B)

/-! ## Lab notes: an explicit instance

For `N = 103764863` (the toy-run modulus of `Catalog.Computation.ToyQSFactorization`)
and `x = 10188`: `x² - N = 30481 = 11 · 17 · 163`.  Each prime factor is split,
as the theorem forces: `(N/11) = (N/17) = (N/163) = +1`. -/

example : (10188 : ℤ) ^ 2 - 103764863 = 11 * 17 * 163 := by norm_num

example : haveI : Fact (Nat.Prime 163) := ⟨by norm_num⟩
    legendreSym 163 103764863 = 1 := by
  haveI : Fact (Nat.Prime 163) := ⟨by norm_num⟩
  exact legendreSym_eq_one_of_dvd_qsValue (x := 10188)
    (by unfold qsValue; norm_num) (by norm_num)

end QSSplitForcing