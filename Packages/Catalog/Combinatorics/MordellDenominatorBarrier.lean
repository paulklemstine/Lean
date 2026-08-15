import Mathlib
import Combinatorics.MordellDenominatorTripling

/-!
# An information barrier: denominator data below `B` cannot detect compositeness

The previous two files show that the denominator primes of `x(2P)` and `x(3P)` on the Mordell
curve `E_N : y² = x³ + N` are governed, prime by prime, by purely local data:

* layer 2 : `ℓ ∣ den x(2P) ↔ ℓ ∣ x³ + N` (the criterion `ℓ ∣ y`);
* layer 3 : `ℓ ∣ den x(3P) ↔ ℓ ∣ ψ₃(x) = 3x⁴ + 12Nx`.

Both conditions depend on `N` **only through `N mod ℓ`**.  This file turns that observation
into a quantitative obstruction for the "factor `N` by looking at denominators" programme:

> For every bound `B` and every semiprime `N = pq` whose factors exceed `B`, there is a
> **prime** `M > N` whose layer-2 and layer-3 denominator criteria agree with those of `N` at
> *every* prime `ℓ ≤ B` simultaneously.

So the denominator data collected at all primes below `B` cannot distinguish the semiprime `N`
from a prime `M`; a fortiori it cannot reveal `p` or `q`.  The proof combines the local
congruence lemmas with Dirichlet's theorem on primes in arithmetic progressions, applied to the
modulus `B!`.

## Main results

* `dvd_layer2_congr`, `dvd_psi3_congr` : the two criteria depend only on `N mod ℓ`.
* `exists_prime_congr_mod_factorial` : Dirichlet's theorem in the form needed — for `N` coprime
  to `B!` there are primes `M > n` with `M ≡ N (mod B!)`.
* `denominator_data_barrier` : the barrier theorem stated above.
* `denominator_data_barrier_classes` : the same statement at the level of the residue-class
  Finsets `vanishingClasses` and `vanishingClasses3`.

-- !-- Lab Notes -- !--
Hypothesizer: if every layer-`n` criterion is a polynomial congruence in `x` with coefficients
  depending only on `N mod ℓ`, then the *entire* denominator profile below `B` is a function of
  `N mod B!`, and Dirichlet should let one replace `N` by a prime with the same profile.
Experimenter: proved below for layers 2 and 3, with modulus `B!`; the coprimality
  hypothesis `p, q > B` is exactly what makes `N = pq` invertible mod `B!`.
Analyst: this is the sharpest form of the "barrier 5" of the earlier cycle (denominators are a
  function of `N` alone): they are in fact a function of `N` modulo the primes one is willing
  to test, and the class of integers with a given profile contains primes.  Any factoring
  attack must therefore use primes `ℓ` of size comparable to the factors themselves.
Critic: the theorem does *not* say that no factoring information exists — it says none exists
  in the layer-2/3 profile below `B`.  Layers `n > 3` obey criteria `ℓ ∣ ψ_n(x)` with
  coefficients again depending only on `N mod ℓ`, which is why the barrier is expected to
  persist; that general statement is left as a conjecture in `FUTURE_DIRECTIONS.md`.
-/

namespace MordellPointCount

open Finset MordellDenominators

/-! ## The criteria depend only on `N mod ℓ` -/

/-- The layer-2 criterion `ℓ ∣ x³ + N` (equivalently `ℓ ∣ y`) depends only on `N mod ℓ`. -/
theorem dvd_layer2_congr {N M x : ℤ} {ℓ : ℕ} (h : (ℓ : ℤ) ∣ N - M) :
    ((ℓ : ℤ) ∣ x ^ 3 + N ↔ (ℓ : ℤ) ∣ x ^ 3 + M) := by
  constructor
  · intro hd
    have hs : (ℓ : ℤ) ∣ (x ^ 3 + N) - (N - M) := dvd_sub hd h
    have he : (x ^ 3 + N) - (N - M) = x ^ 3 + M := by ring
    rwa [he] at hs
  · intro hd
    have hs : (ℓ : ℤ) ∣ (x ^ 3 + M) + (N - M) := dvd_add hd h
    have he : (x ^ 3 + M) + (N - M) = x ^ 3 + N := by ring
    rwa [he] at hs

/-- The layer-3 criterion `ℓ ∣ ψ₃(x)` depends only on `N mod ℓ`. -/
theorem dvd_psi3_congr {N M x : ℤ} {ℓ : ℕ} (h : (ℓ : ℤ) ∣ N - M) :
    ((ℓ : ℤ) ∣ psi3 N x ↔ (ℓ : ℤ) ∣ psi3 M x) := by
  have hdiff : psi3 N x - psi3 M x = 12 * x * (N - M) := by rw [psi3, psi3]; ring
  constructor
  · intro hd
    have hs : (ℓ : ℤ) ∣ psi3 N x - 12 * x * (N - M) := dvd_sub hd (h.mul_left _)
    rwa [← hdiff, sub_sub_cancel] at hs
  · intro hd
    have hs : (ℓ : ℤ) ∣ psi3 M x + 12 * x * (N - M) := dvd_add hd (h.mul_left _)
    rwa [← hdiff, add_sub_cancel] at hs

/-- Both residue-class Finsets depend only on `N mod ℓ`. -/
theorem vanishingClasses_congr {ℓ : ℕ} [Fact ℓ.Prime] {N M : ℤ}
    (h : ((N : ZMod ℓ)) = ((M : ZMod ℓ))) :
    vanishingClasses N ℓ = vanishingClasses M ℓ ∧
      vanishingClasses3 N ℓ = vanishingClasses3 M ℓ := by
  constructor
  · ext t
    rw [mem_vanishingClasses_iff, mem_vanishingClasses_iff, h]
  · ext t
    rw [mem_vanishingClasses3_iff, mem_vanishingClasses3_iff, h]

/-! ## Dirichlet's theorem in the shape we need -/

/-- **Primes in the progression `N mod B!`.**  If `N` is coprime to `B!` then for every `n`
there is a prime `M > n` with `M ≡ N (mod B!)`. -/
theorem exists_prime_congr_mod_factorial {N B n : ℕ} (hcop : Nat.Coprime N (Nat.factorial B)) :
    ∃ M : ℕ, M.Prime ∧ n < M ∧ M ≡ N [MOD Nat.factorial B] := by
  haveI : NeZero (Nat.factorial B) := ⟨Nat.factorial_ne_zero B⟩
  have hunit : IsUnit ((N : ℕ) : ZMod (Nat.factorial B)) :=
    (ZMod.isUnit_iff_coprime N (Nat.factorial B)).mpr hcop
  obtain ⟨M, hMgt, hMp, hMeq⟩ := Nat.forall_exists_prime_gt_and_eq_mod hunit n
  exact ⟨M, hMp, hMgt, (ZMod.natCast_eq_natCast_iff M N (Nat.factorial B)).mp hMeq⟩

/-- A semiprime whose factors exceed `B` is coprime to `B!`. -/
theorem coprime_factorial_of_semiprime {p q B : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpB : B < p) (hqB : B < q) : Nat.Coprime (p * q) (Nat.factorial B) := by
  refine Nat.Coprime.mul_left ?_ ?_
  · rw [hp.coprime_iff_not_dvd]
    intro hdvd
    exact absurd ((Nat.Prime.dvd_factorial hp).mp hdvd) (by omega)
  · rw [hq.coprime_iff_not_dvd]
    intro hdvd
    exact absurd ((Nat.Prime.dvd_factorial hq).mp hdvd) (by omega)

/-! ## The barrier -/

/-- **Denominator data below `B` cannot detect compositeness.**  Let `N = pq` be a semiprime
whose prime factors both exceed `B`.  Then there is a *prime* `M > N` such that for every prime
`ℓ ≤ B` and every integer `x`, the layer-2 criterion `ℓ ∣ x³ + N` and the layer-3 criterion
`ℓ ∣ ψ₃(x)` hold for `E_N` exactly when they hold for `E_M`.

Hence the whole layer-2/layer-3 denominator profile at primes `ℓ ≤ B` is identical for the
semiprime `N` and the prime `M`: it contains no information about the factorisation of `N`. -/
theorem denominator_data_barrier (B : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpB : B < p) (hqB : B < q) :
    ∃ M : ℕ, M.Prime ∧ p * q < M ∧
      ∀ ℓ : ℕ, ℓ.Prime → ℓ ≤ B → ∀ x : ℤ,
        (((ℓ : ℤ) ∣ x ^ 3 + ((p * q : ℕ) : ℤ) ↔ (ℓ : ℤ) ∣ x ^ 3 + ((M : ℕ) : ℤ)) ∧
          ((ℓ : ℤ) ∣ psi3 ((p * q : ℕ) : ℤ) x ↔ (ℓ : ℤ) ∣ psi3 ((M : ℕ) : ℤ) x)) := by
  obtain ⟨M, hMp, hMgt, hMmod⟩ :=
    exists_prime_congr_mod_factorial (N := p * q) (B := B) (n := p * q)
      (coprime_factorial_of_semiprime hp hq hpB hqB)
  refine ⟨M, hMp, hMgt, ?_⟩
  intro ℓ hl hlB x
  have hlfac : ℓ ∣ Nat.factorial B := Nat.dvd_factorial hl.pos hlB
  have hmod : M ≡ p * q [MOD ℓ] := hMmod.of_dvd hlfac
  have hdvd : (ℓ : ℤ) ∣ ((p * q : ℕ) : ℤ) - ((M : ℕ) : ℤ) := by
    have := (Nat.modEq_iff_dvd (n := ℓ) (a := M) (b := p * q)).mp hmod
    exact this
  exact ⟨dvd_layer2_congr hdvd, dvd_psi3_congr hdvd⟩

/-- **The barrier at the level of residue classes.**  With `N` and `M` as above, the
denominator-producing residue classes at layer 2 and at layer 3 coincide for `E_N` and `E_M`
at every prime `ℓ ≤ B`. -/
theorem denominator_data_barrier_classes (B : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpB : B < p) (hqB : B < q) :
    ∃ M : ℕ, M.Prime ∧ p * q < M ∧
      ∀ (ℓ : ℕ) [Fact ℓ.Prime], ℓ ≤ B →
        (vanishingClasses ((p * q : ℕ) : ℤ) ℓ = vanishingClasses ((M : ℕ) : ℤ) ℓ ∧
          vanishingClasses3 ((p * q : ℕ) : ℤ) ℓ = vanishingClasses3 ((M : ℕ) : ℤ) ℓ) := by
  obtain ⟨M, hMp, hMgt, hMmod⟩ :=
    exists_prime_congr_mod_factorial (N := p * q) (B := B) (n := p * q)
      (coprime_factorial_of_semiprime hp hq hpB hqB)
  refine ⟨M, hMp, hMgt, ?_⟩
  intro ℓ hl hlB
  have hlfac : ℓ ∣ Nat.factorial B := Nat.dvd_factorial hl.out.pos hlB
  have hmod : M ≡ p * q [MOD ℓ] := hMmod.of_dvd hlfac
  have hcast : ((((p * q : ℕ) : ℤ)) : ZMod ℓ) = ((((M : ℕ) : ℤ)) : ZMod ℓ) := by
    push_cast
    exact_mod_cast ((ZMod.natCast_eq_natCast_iff (p * q) M ℓ).mpr hmod.symm)
  exact vanishingClasses_congr hcast

end MordellPointCount