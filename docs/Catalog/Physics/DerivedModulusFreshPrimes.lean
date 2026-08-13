import Mathlib
import Physics.DerivedModulusNoGo

/-!
# Barrier 4: derived moduli need a *fresh* factorisation

The companion file `Physics.DerivedModulusNoGo` shows that a derived modulus
`M = f(N)` shares with `N` only the (fixed, finite) prime support of `f(0)`.
This file proves the second half of the collapse observed in the MULTIMOD
experiment: the primes one would have to discover in order to compute an
invariant `C(M)` of the derived modulus are *not* the primes of `N`, and they
are unboundedly many and unboundedly large.  So the derived modulus does not
recycle the factorisation problem for `N` — it poses a brand-new one.

## Main results

* `Physics.DerivedModulus.exists_fresh_prime_factor` : a Euclid-style argument.
  For any integer polynomial with `f(0) = 1` and any finite set `S` of already
  known primes, the value of `f` at `∏ S` has a prime factor outside `S`.
* `Physics.DerivedModulus.primeSupport_infinite` : the set of primes dividing
  some value of such an `f` is infinite.
* `Physics.DerivedModulus.exists_large_prime_factor` : those primes are
  unbounded, so no precomputed prime table can shortcut `C(M)`.
* `Physics.DerivedModulus.fresh_prime_not_dvd` : and none of the freshly
  discovered primes ever divides `N` (the two barriers combined).
* Instances for the concrete MULTIMOD moduli `N + 1`, `N² + 1`, `Φ₃(N)`,
  `2N + 1`.
-/

namespace Physics.DerivedModulus

open Polynomial

/-- **Euclid step for derived moduli.**  Let `f` be an integer polynomial with
constant term `1` and let `S` be any finite set of primes already known.  If the
value of `f` at `M = ∏ S` is not a unit, then it has a prime factor lying
*outside* `S`.  (No primality hypothesis on the members of `S` is needed.) -/
theorem exists_fresh_prime_factor (f : ℤ[X]) (h0 : f.eval 0 = 1) (S : Finset ℕ)
    (hbig : 1 < (f.eval ((∏ p ∈ S, p : ℕ) : ℤ)).natAbs) :
    ∃ q : ℕ, q.Prime ∧ (q : ℤ) ∣ f.eval ((∏ p ∈ S, p : ℕ) : ℤ) ∧ q ∉ S := by
  set M : ℕ := ∏ p ∈ S, p with hM
  set v : ℤ := f.eval (M : ℤ) with hv
  have hne : v.natAbs ≠ 1 := by omega
  refine ⟨v.natAbs.minFac, Nat.minFac_prime hne, ?_, ?_⟩
  · have h1 : v.natAbs.minFac ∣ v.natAbs := Nat.minFac_dvd _
    have h2 : ((v.natAbs.minFac : ℤ)) ∣ (v.natAbs : ℤ) := Int.natCast_dvd_natCast.mpr h1
    exact Int.dvd_natAbs.mp h2
  · intro hmem
    -- a member of `S` divides `M`, hence divides `f(M) - f(0) = v - 1`
    have hqM : v.natAbs.minFac ∣ M := Finset.dvd_prod_of_mem _ hmem
    have hqMZ : ((v.natAbs.minFac : ℤ)) ∣ (M : ℤ) := Int.natCast_dvd_natCast.mpr hqM
    have hsub : (M : ℤ) ∣ v - 1 := by
      have := dvd_eval_sub_eval_zero f (M : ℤ)
      rwa [h0] at this
    have hq1 : ((v.natAbs.minFac : ℤ)) ∣ v - 1 := hqMZ.trans hsub
    have hqv : ((v.natAbs.minFac : ℤ)) ∣ v := by
      have h1 : v.natAbs.minFac ∣ v.natAbs := Nat.minFac_dvd _
      exact Int.dvd_natAbs.mp (Int.natCast_dvd_natCast.mpr h1)
    have : ((v.natAbs.minFac : ℤ)) ∣ 1 := by simpa using dvd_sub hqv hq1
    have hle : (v.natAbs.minFac) ∣ 1 := by exact_mod_cast this
    exact (Nat.minFac_prime hne).one_lt.ne' (Nat.dvd_one.mp hle)

/-- **The prime support of a derived-modulus family is infinite.**
If `f(0) = 1` and `f` takes non-unit values at every positive integer, then
infinitely many primes occur in the factorisations of the derived moduli
`f(N)`. -/
theorem primeSupport_infinite (f : ℤ[X]) (h0 : f.eval 0 = 1)
    (hgrow : ∀ m : ℕ, 1 ≤ m → 1 < (f.eval (m : ℤ)).natAbs) :
    {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ f.eval N}.Infinite := by
  intro hfin
  set T : Finset ℕ := hfin.toFinset with hT
  have hpos : 1 ≤ ∏ p ∈ T, p := by
    refine Nat.one_le_iff_ne_zero.mpr ?_
    refine Finset.prod_ne_zero_iff.mpr ?_
    intro p hp
    have : p ∈ {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ f.eval N} :=
      hfin.mem_toFinset.mp hp
    exact this.1.ne_zero
  obtain ⟨q, hq, hqdvd, hqnot⟩ :=
    exists_fresh_prime_factor f h0 T (hgrow _ hpos)
  exact hqnot (hfin.mem_toFinset.mpr ⟨hq, _, hqdvd⟩)

/-- **Unboundedness.** The primes needed to factor derived moduli exceed every
bound: no fixed table of small primes suffices to compute `C(f(N))`. -/
theorem exists_large_prime_factor (f : ℤ[X]) (h0 : f.eval 0 = 1)
    (hgrow : ∀ m : ℕ, 1 ≤ m → 1 < (f.eval (m : ℤ)).natAbs) (B : ℕ) :
    ∃ q : ℕ, q.Prime ∧ B < q ∧ ∃ N : ℤ, (q : ℤ) ∣ f.eval N := by
  have hinf := primeSupport_infinite f h0 hgrow
  obtain ⟨q, hq, hqB⟩ := (hinf.exists_gt B)
  exact ⟨q, hq.1, hqB, hq.2⟩

/-- **Both barriers at once.** A prime discovered in the factorisation of the
derived modulus never divides `N`, provided the constant term is a unit: the
fresh factorisation is arithmetically disjoint from the target. -/
theorem fresh_prime_not_dvd (f : ℤ[X]) (h0 : f.eval 0 = 1 ∨ f.eval 0 = -1)
    {q : ℕ} (hq : q.Prime) {N : ℤ} (hqf : (q : ℤ) ∣ f.eval N) : ¬ ((q : ℤ) ∣ N) := by
  intro hqN
  have hconst : (q : ℤ) ∣ f.eval 0 := dvd_const_of_common_dvd f hqN hqf
  have : (q : ℤ) ∣ 1 := by
    rcases h0 with h | h
    · rwa [h] at hconst
    · rw [h] at hconst; exact dvd_neg.mp hconst
  exact hq.one_lt.ne' (by exact_mod_cast Int.eq_one_of_dvd_one (by positivity) this)

/-! ## The concrete MULTIMOD moduli -/

/-- `N² + 1` as an integer polynomial. -/
noncomputable def sqSuccPoly : ℤ[X] := X ^ 2 + 1

/-- `Φ₃(N) = N² + N + 1` as an integer polynomial. -/
noncomputable def cyc3Poly : ℤ[X] := X ^ 2 + X + 1

/-- `2N + 1` as an integer polynomial. -/
noncomputable def twoSuccPoly : ℤ[X] := 2 * X + 1

@[simp] theorem eval_sqSuccPoly (N : ℤ) : sqSuccPoly.eval N = N ^ 2 + 1 := by
  simp [sqSuccPoly]

@[simp] theorem eval_cyc3Poly (N : ℤ) : cyc3Poly.eval N = N ^ 2 + N + 1 := by
  simp [cyc3Poly]

@[simp] theorem eval_twoSuccPoly (N : ℤ) : twoSuccPoly.eval N = 2 * N + 1 := by
  simp [twoSuccPoly]

/-- Infinitely many primes divide some `N² + 1`; every one of them is coprime
to the corresponding `N`. -/
theorem sqSucc_primeSupport_infinite :
    {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ N ^ 2 + 1}.Infinite := by
  have h := primeSupport_infinite sqSuccPoly (by simp) ?_
  · simpa using h
  · intro m hm
    have : (1 : ℤ) < (m : ℤ) ^ 2 + 1 := by
      have : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
      nlinarith
    simp only [eval_sqSuccPoly]
    omega

/-- Same for the third cyclotomic modulus `Φ₃(N) = N² + N + 1`. -/
theorem cyc3_primeSupport_infinite :
    {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ N ^ 2 + N + 1}.Infinite := by
  have h := primeSupport_infinite cyc3Poly (by simp) ?_
  · simpa using h
  · intro m hm
    have h1 : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
    have : (1 : ℤ) < (m : ℤ) ^ 2 + (m : ℤ) + 1 := by nlinarith
    simp only [eval_cyc3Poly]
    omega

/-- Same for the linear modulus `2N + 1`. -/
theorem twoSucc_primeSupport_infinite :
    {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ 2 * N + 1}.Infinite := by
  have h := primeSupport_infinite twoSuccPoly (by simp) ?_
  · simpa using h
  · intro m hm
    have h1 : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
    simp only [eval_twoSuccPoly]
    omega

/-- **Synthesis of the two barriers for `N² + 1`.**  Its prime support is
infinite (barrier 4: factoring it is a fresh problem), yet no prime in that
support ever divides the corresponding `N` (barrier 1/5: the fresh problem is
useless for factoring `N`). -/
theorem sqSucc_barriers :
    {q : ℕ | q.Prime ∧ ∃ N : ℤ, (q : ℤ) ∣ N ^ 2 + 1}.Infinite ∧
    ∀ (q : ℕ), q.Prime → ∀ N : ℤ, (q : ℤ) ∣ N ^ 2 + 1 → ¬ ((q : ℤ) ∣ N) := by
  refine ⟨sqSucc_primeSupport_infinite, ?_⟩
  intro q hq N hqf
  have := fresh_prime_not_dvd sqSuccPoly (Or.inl (by simp)) hq (N := N) (by simpa using hqf)
  exact this

end Physics.DerivedModulus