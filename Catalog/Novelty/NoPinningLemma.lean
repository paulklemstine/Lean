/-
# The Class-Wide No-Pinning Lemma

Phase A research file (Novelty domain).  This file generalises the
`Bridges.ResidueLeakage` Dirichlet no-pruning theorem (QRLEAK, Jacobi symbols
only) to the **entire class of modulus-`L` observables**: every predicate of a
semiprime `N` that can be evaluated from `N mod L` alone.  For
`L = 4 · lcm(1,…,B)` with `B = poly(log N)` this class contains

* all residues `N mod m` with `m ≤ B`,
* all Jacobi symbols `(a | N)` with `4a ∣ L`,
* all gcds `gcd(N, c)` with `c ∣ L` (and, by the barrier-1 lemma
  `gcd(f(N), N) = gcd(f(0), N)`, all polynomial gcds too).

## Setting

An *observable of modulus `L`* is any map `f : ℕ → β` with
`f m = f n` whenever `m` and `n` are odd and congruent mod `L`
(`IsModObs`).  A *battery* is a finite list of ℤ-valued observables.

## Main results

* `infinite_compensating_primes` — **the Dirichlet core**: for a target `N₀`
  and a candidate `p`, both coprime to `L`, there are infinitely many primes
  `q ≡ N₀ p⁻¹ (mod L)`; each of them satisfies `p·q ≡ N₀ (mod L)`.
* `no_pinning_universal` — **the class-wide no-pinning lemma**: for infinitely
  many primes `q`, *every* observable of modulus `L`, in *every* value type,
  agrees on `p·q` and on `N₀`.  A poly(log N)-computable congruence battery
  therefore never eliminates the candidate `p`.
* `battery_no_pinning` — the finite-battery form.
* `compensable_iff_not_dvd` — **exact description of the pinned set**: a prime
  `p` is eliminated by the modulus-`L` data if and only if `p ∣ L`.
* `pinnedPrimes_card_le_log` — the pinned set has at most `log₂ L` elements,
  and `unpinnedPrimes_infinite` — its complement inside the primes is infinite.
* `no_pinning_large_primes` — the ambiguity is not confined to small numbers:
  for every bound `M` there is a semiprime `p·q` with `p, q > M` carrying the
  same modulus-`L` data as `N₀`.
-/

import Mathlib

namespace Novelty.NoPinning

/-! ## Observables of a fixed modulus -/

/-- `IsModObs L f`: the observable `f` is a function of `N mod L` on odd inputs.
This is exactly the class of predicates a `poly(log N)`-time congruence battery
with modulus `L` can evaluate. -/
def IsModObs (L : ℕ) {β : Type} (f : ℕ → β) : Prop :=
  ∀ ⦃m n : ℕ⦄, Odd m → Odd n → m ≡ n [MOD L] → f m = f n

/-- The finest observable of modulus `L`: the residue itself. -/
theorem isModObs_residue_self (L : ℕ) : IsModObs L (fun N => N % L) :=
  fun _ _ _ _ h => h

/-- The value of a battery (a finite list of ℤ-valued observables) at `N`. -/
def batteryValue (Bat : List (ℕ → ℤ)) (N : ℕ) : List ℤ := Bat.map (fun f => f N)

@[simp] theorem batteryValue_length (Bat : List (ℕ → ℤ)) (N : ℕ) :
    (batteryValue Bat N).length = Bat.length := by simp [batteryValue]

/-! ## Elementary coprimality facts -/

theorem odd_of_coprime_of_two_dvd {L n : ℕ} (h2 : 2 ∣ L) (h : Nat.Coprime n L) :
    Odd n := by
  have : Nat.Coprime n 2 := Nat.Coprime.coprime_dvd_right h2 h
  exact Nat.coprime_two_right.mp this

/-! ## The Dirichlet core: compensating primes exist -/

/-- **Compensating-partner lemma.**  Let `L ≥ 1`, let the target `N₀` and the
candidate `p` be coprime to `L`.  Then infinitely many primes `q` satisfy
`p · q ≡ N₀ (mod L)`; i.e. the candidate `p` can always be completed to a
semiprime carrying exactly the residue data of `N₀`.

The analytic input is Dirichlet's theorem: `N₀ p⁻¹` is a unit of `ZMod L`, and
every unit class contains infinitely many primes. -/
theorem infinite_compensating_primes (L : ℕ) [NeZero L] {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ L) (hp : Nat.Coprime p L) :
    {q : ℕ | q.Prime ∧ Nat.Coprime q L ∧ p * q ≡ N₀ [MOD L]}.Infinite := by
  have hpu : IsUnit ((p : ZMod L)) := (ZMod.isUnit_iff_coprime p L).2 hp
  have hNu : IsUnit ((N₀ : ZMod L)) := (ZMod.isUnit_iff_coprime N₀ L).2 hN
  set u : (ZMod L)ˣ := hpu.unit with hu
  set a : ZMod L := ((u⁻¹ : (ZMod L)ˣ) : ZMod L) * (N₀ : ZMod L) with ha'
  have ha : IsUnit a := (Units.isUnit _).mul hNu
  refine (Nat.infinite_setOf_prime_and_eq_mod ha).mono ?_
  rintro q ⟨hq, hqa⟩
  have hqu : IsUnit ((q : ZMod L)) := by rw [hqa]; exact ha
  refine ⟨hq, (ZMod.isUnit_iff_coprime q L).1 hqu, ?_⟩
  rw [← ZMod.natCast_eq_natCast_iff]
  push_cast
  rw [hqa, ha']
  have hup : ((u : (ZMod L)ˣ) : ZMod L) = (p : ZMod L) := hpu.unit_spec
  calc (p : ZMod L) * (((u⁻¹ : (ZMod L)ˣ) : ZMod L) * (N₀ : ZMod L))
      = (((u : (ZMod L)ˣ) : ZMod L) * ((u⁻¹ : (ZMod L)ˣ) : ZMod L)) * (N₀ : ZMod L) := by
        rw [hup]; ring
    _ = (N₀ : ZMod L) := by
        rw [← Units.val_mul, mul_inv_cancel, Units.val_one, one_mul]

/-! ## The class-wide no-pinning lemma -/

/-- **The class-wide no-pinning lemma.**  Assume `2 ∣ L` (so that every residue
class coprime to `L` consists of odd numbers), and let `N₀` (target) and `p`
(candidate prime factor) be coprime to `L`.  Then for infinitely many primes `q`
*every* observable of modulus `L` — in every value type, hence in particular
every residue `N mod m` with `m ∣ L`, every Jacobi symbol `(a | N)` with
`4a ∣ L`, and every gcd `gcd(N, c)` with `c ∣ L` — takes the same value on the
semiprime `p·q` as on `N₀`.

Consequently no congruence battery of modulus `L` can pin, or even exclude, the
individual candidate factor `p`. -/
theorem no_pinning_universal (L : ℕ) [NeZero L] (h2 : 2 ∣ L) {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ L) (hp : Nat.Coprime p L) :
    {q : ℕ | q.Prime ∧ Nat.Coprime q L ∧
      ∀ {β : Type} (f : ℕ → β), IsModObs L f → f (p * q) = f N₀}.Infinite := by
  refine (infinite_compensating_primes L hN hp).mono ?_
  rintro q ⟨hq, hqL, hmod⟩
  have hNodd : Odd N₀ := odd_of_coprime_of_two_dvd h2 hN
  have hpodd : Odd p := odd_of_coprime_of_two_dvd h2 hp
  have hqodd : Odd q := odd_of_coprime_of_two_dvd h2 hqL
  exact ⟨hq, hqL, fun f hf => hf (hpodd.mul hqodd) hNodd hmod⟩

/-- Finite-battery form of the no-pinning lemma: the entire battery of ℤ-valued
observables agrees on `p·q` and `N₀`, for infinitely many primes `q`. -/
theorem battery_no_pinning (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    (Bat : List (ℕ → ℤ)) (hBat : ∀ f ∈ Bat, IsModObs L f) {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ L) (hp : Nat.Coprime p L) :
    {q : ℕ | q.Prime ∧ batteryValue Bat (p * q) = batteryValue Bat N₀}.Infinite := by
  refine (no_pinning_universal L h2 hN hp).mono ?_
  rintro q ⟨hq, -, hall⟩
  exact ⟨hq, List.map_congr_left fun f hf => hall f (hBat f hf)⟩

/-- Existence form, matching the COMPENSATING-PARTNER experiment: some prime `q`
makes `p·q` indistinguishable from `N₀` for the whole battery. -/
theorem exists_compensating_prime (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    (Bat : List (ℕ → ℤ)) (hBat : ∀ f ∈ Bat, IsModObs L f) {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ L) (hp : Nat.Coprime p L) :
    ∃ q : ℕ, q.Prime ∧ batteryValue Bat (p * q) = batteryValue Bat N₀ :=
  let ⟨q, hq⟩ := (battery_no_pinning L h2 Bat hBat hN hp).nonempty
  ⟨q, hq.1, hq.2⟩

/-! ## The pinned set is exactly the primes dividing `L` -/

/-- If `p ∣ L` and `p ∤ N₀`, the residue channel mod `p` already excludes `p`:
no completion `p·n` whatsoever has the modulus-`L` residue of `N₀`. -/
theorem pinned_of_dvd {L N₀ p : ℕ} (hdvd : p ∣ L) (hp : p.Prime)
    (hN : Nat.Coprime N₀ L) (n : ℕ) : ¬ (p * n ≡ N₀ [MOD L]) := by
  intro hmod
  have hmp : p * n ≡ N₀ [MOD p] := hmod.of_dvd hdvd
  have h0 : (0 : ℕ) ≡ p * n [MOD p] := (Nat.modEq_zero_iff_dvd.mpr ⟨n, rfl⟩).symm
  have : p ∣ N₀ := (Nat.modEq_zero_iff_dvd).mp (h0.trans hmp).symm
  have : p ∣ Nat.gcd N₀ L := Nat.dvd_gcd this hdvd
  rw [hN] at this
  exact hp.one_lt.ne' (Nat.dvd_one.mp this)

/-- **Exact description of the pinned set.**  For a target `N₀` coprime to `L`,
a prime candidate `p` survives the modulus-`L` data — indeed survives with
infinitely many compensating partners — precisely when `p ∤ L`. -/
theorem compensable_iff_not_dvd (L : ℕ) [NeZero L] {N₀ p : ℕ}
    (hN : Nat.Coprime N₀ L) (hp : p.Prime) :
    {q : ℕ | q.Prime ∧ Nat.Coprime q L ∧ p * q ≡ N₀ [MOD L]}.Infinite ↔ ¬ p ∣ L := by
  constructor
  · intro hinf hdvd
    obtain ⟨q, hq⟩ := hinf.nonempty
    exact pinned_of_dvd hdvd hp hN q hq.2.2
  · intro hdvd
    exact infinite_compensating_primes L hN ((Nat.Prime.coprime_iff_not_dvd hp).2 hdvd)

/-- The set of pinned candidates: primes dividing the modulus. -/
def pinnedPrimes (L : ℕ) : Finset ℕ := L.primeFactors

theorem mem_pinnedPrimes {L p : ℕ} (hL : L ≠ 0) :
    p ∈ pinnedPrimes L ↔ p.Prime ∧ p ∣ L := by
  simp [pinnedPrimes, Nat.mem_primeFactors, hL]

/-- **Quantitative smallness of the pinned set.**  At most `log₂ L` primes are
pinned.  For the poly(log N) batteries of the experiment, `L = 4·lcm(1,…,B)`
with `B = poly(log N)`, so this is `O(B) = poly(log N)` pinned candidates out of
`~ √N / log N` prime candidates. -/
theorem pinnedPrimes_card_le_log {L : ℕ} (hL : L ≠ 0) :
    (pinnedPrimes L).card ≤ Nat.log 2 L := by
  have hprod : 2 ^ (pinnedPrimes L).card ≤ ∏ p ∈ pinnedPrimes L, p := by
    calc 2 ^ (pinnedPrimes L).card = ∏ _p ∈ pinnedPrimes L, 2 := by
          rw [Finset.prod_const]
      _ ≤ ∏ p ∈ pinnedPrimes L, p :=
          Finset.prod_le_prod' fun p hp =>
            (Nat.prime_of_mem_primeFactors hp).two_le
  have hdvd : ∏ p ∈ pinnedPrimes L, p ≤ L :=
    Nat.le_of_dvd (Nat.pos_of_ne_zero hL) (Nat.prod_primeFactors_dvd L)
  exact (Nat.le_log_iff_pow_le one_lt_two hL).2 (hprod.trans hdvd)

/-- The unpinned candidates form an infinite set: no modulus-`L` battery
narrows the factor search to a finite list. -/
theorem unpinnedPrimes_infinite (L : ℕ) (hL : L ≠ 0) :
    {p : ℕ | p.Prime ∧ ¬ p ∣ L}.Infinite := by
  have hsub : {p : ℕ | p.Prime} \ (pinnedPrimes L : Set ℕ) ⊆ {p : ℕ | p.Prime ∧ ¬ p ∣ L} := by
    rintro p ⟨hp, hp2⟩
    refine ⟨hp, fun hdvd => hp2 ?_⟩
    exact (Finset.mem_coe).2 ((mem_pinnedPrimes hL).2 ⟨hp, hdvd⟩)
  exact Set.Infinite.mono hsub
    (Set.Infinite.diff Nat.infinite_setOf_prime (pinnedPrimes L).finite_toSet)

/-- **No pinning, global form.**  For every target `N₀` coprime to `L`, the set
of prime candidates that remain consistent with all modulus-`L` observables is
infinite (it is the complement of the `≤ log₂ L` primes dividing `L`). -/
theorem consistent_candidates_infinite (L : ℕ) [NeZero L] (h2 : 2 ∣ L) {N₀ : ℕ}
    (hN : Nat.Coprime N₀ L) :
    {p : ℕ | p.Prime ∧ ∃ q : ℕ, q.Prime ∧
      ∀ {β : Type} (f : ℕ → β), IsModObs L f → f (p * q) = f N₀}.Infinite := by
  refine (unpinnedPrimes_infinite L (NeZero.ne L)).mono ?_
  rintro p ⟨hp, hpL⟩
  obtain ⟨q, hq, -, hall⟩ :=
    (no_pinning_universal L h2 hN ((Nat.Prime.coprime_iff_not_dvd hp).2 hpL)).nonempty
  exact ⟨hp, q, hq, fun f hf => hall f hf⟩

/-- **The ambiguity is not confined to small numbers.**  For every bound `M`
there is a semiprime `p·q` with both factors exceeding `M` which is
indistinguishable from `N₀` by all modulus-`L` observables. -/
theorem no_pinning_large_primes (L : ℕ) [NeZero L] (h2 : 2 ∣ L) {N₀ : ℕ}
    (hN : Nat.Coprime N₀ L) (M : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ M < p ∧ M < q ∧
      ∀ {β : Type} (f : ℕ → β), IsModObs L f → f (p * q) = f N₀ := by
  obtain ⟨p, hpmem, hpM⟩ :=
    ((unpinnedPrimes_infinite L (NeZero.ne L)).exists_gt M)
  obtain ⟨hp, hpL⟩ := hpmem
  obtain ⟨q, hqmem, hqM⟩ :=
    ((no_pinning_universal L h2 hN ((Nat.Prime.coprime_iff_not_dvd hp).2 hpL)).exists_gt M)
  obtain ⟨hq, -, hall⟩ := hqmem
  exact ⟨p, q, hp, hq, hpM, hqM, fun f hf => hall f hf⟩

end Novelty.NoPinning