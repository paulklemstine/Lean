import Mathlib
import Tropical.TraceLemmaExhaustiveness

/-!
# KROOT: the order channel is a free witness, and it reduces to the trace

The free-witness classification lists KROOT — counting the `k`-th roots of unity
modulo `N` — as a member whose local weight is the *order* datum `gcd(k, p - 1)`.
This file formalises that member from the group theory up, and then verifies the
trace lemma for it: the order channel, maximised over `k`, is Euler's `φ(N)`, and
`φ(N)` together with `N` *is* the trace `p + q`, which the previous catalog file
turns into the factors.

Contents:

* **CRT multiplicativity of the local count** (`card_kthRoots_semiprime`): for
  distinct primes `p, q`,
  `#{x ∈ (ZMod (pq))ˣ : x ^ k = 1} = gcd(p - 1, k) · gcd(q - 1, k)`.
  The proof composes the CRT ring isomorphism, the units functor, and the cyclic-group
  computation `Nat.card (powMonoidHom k).ker = gcd (Nat.card G) k`.  This is layer 1 of
  the classification (CRT decomposition) and layer 2 (non-polynomial local weight)
  simultaneously: `gcd(k, p-1)` is an order datum, not a polynomial in `p`.
* **Barrier 5 for `k = 2`** (`card_sqrtOne_semiprime`, `kroot_two_no_recovery`): the
  count of square roots of unity is the constant `4` for every odd semiprime, so this
  member of the family carries *zero* information; no function of it can return a
  factor.  This is the precise sense in which the order channel needs a *good* `k`.
* **The order channel reduces to the trace** (`kroot_max_eq_totient`,
  `kroot_recovers_small_factor`): the count is maximised at `k = φ(N)` where it equals
  `φ(N) = (p-1)(q-1)`, and then `p + q = N + 1 - φ(N)` recovers the smaller factor
  through the closed formula `TraceLemma.recoverSmallFactor` of
  `Tropical.TraceLemmaExhaustiveness`.  So KROOT is not a new information channel:
  it *is* the trace channel, exactly as the trace lemma predicts.
-/

namespace FreeWitnessOrder

open Finset

/-! ## 1. Counting `k`-th roots of unity in a finite abelian group -/

/-- In a finite cyclic group the number of `k`-th roots of unity is `gcd(|G|, k)`. -/
theorem card_torsion_cyclic (G : Type*) [CommGroup G] [Finite G] [IsCyclic G] (k : ℕ) :
    Nat.card {x : G // x ^ k = 1} = (Nat.card G).gcd k := by
  rw [← IsCyclic.card_powMonoidHom_ker (G := G) k]
  exact Nat.card_congr
    (Equiv.subtypeEquivRight (fun x => by simp [MonoidHom.mem_ker, powMonoidHom]))

/-- The count of `k`-th roots of unity is a group-isomorphism invariant. -/
theorem card_torsion_congr {G H : Type*} [Group G] [Group H] (e : G ≃* H) (k : ℕ) :
    Nat.card {x : G // x ^ k = 1} = Nat.card {y : H // y ^ k = 1} :=
  Nat.card_congr (Equiv.subtypeEquiv e.toEquiv (fun a => by simp [← map_pow]))

/-- The count of `k`-th roots of unity is multiplicative over direct products: this is
the abstract form of the CRT decomposition of the free-witness mechanism. -/
theorem card_torsion_prod {A B : Type*} [Group A] [Group B] (k : ℕ) :
    Nat.card {x : A × B // x ^ k = 1}
      = Nat.card {a : A // a ^ k = 1} * Nat.card {b : B // b ^ k = 1} := by
  rw [← Nat.card_prod]
  refine Nat.card_congr (Equiv.trans (Equiv.subtypeEquivRight (p := fun x : A × B => x ^ k = 1)
    (q := fun x : A × B => (fun a : A => a ^ k = 1) x.1 ∧ (fun b : B => b ^ k = 1) x.2) ?_)
    (Equiv.subtypeProdEquivProd (p := fun a : A => a ^ k = 1) (q := fun b : B => b ^ k = 1)))
  intro x
  simp only [Prod.pow_def, Prod.ext_iff, Prod.fst_one, Prod.snd_one]

/-! ## 2. The KROOT count for a semiprime -/

/-- The local KROOT weight: modulo a prime `p` there are exactly `gcd(p - 1, k)`
`k`-th roots of unity. -/
theorem card_kthRoots_prime {p : ℕ} (hp : p.Prime) (k : ℕ) :
    Nat.card {x : (ZMod p)ˣ // x ^ k = 1} = (p - 1).gcd k := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcard : Nat.card (ZMod p)ˣ = p - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hp]
  rw [card_torsion_cyclic ((ZMod p)ˣ) k, hcard]

/-- **The KROOT free witness.**  For distinct primes `p, q` the number of `k`-th roots
of unity modulo `N = pq` is the CRT product `gcd(p-1, k) · gcd(q-1, k)` of two order
data.  Both layers of the classification are visible: the count factors through the CRT
splitting, and each local factor is the non-polynomial quantity `gcd(k, p-1)`. -/
theorem card_kthRoots_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) :
    Nat.card {x : (ZMod (p * q))ˣ // x ^ k = 1} = (p - 1).gcd k * ((q - 1).gcd k) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have e : (ZMod (p * q))ˣ ≃* (ZMod p)ˣ × (ZMod q)ˣ :=
    (Units.mapEquiv (ZMod.chineseRemainder hcop).toMulEquiv).trans MulEquiv.prodUnits
  rw [card_torsion_congr e k, card_torsion_prod k, card_kthRoots_prime hp k,
    card_kthRoots_prime hq k]

/-! ## 3. `k = 2` is information-free (barrier 5) -/

/-- Modulo an odd semiprime there are exactly four square roots of unity, whatever the
primes are. -/
theorem card_sqrtOne_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    Nat.card {x : (ZMod (p * q))ˣ // x ^ 2 = 1} = 4 := by
  have hpodd : ¬ 2 ∣ p := fun h => hp2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).mp h).symm
  have hqodd : ¬ 2 ∣ q := fun h => hq2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hq).mp h).symm
  have hp1 : (p - 1).gcd 2 = 2 := by
    have h2 : 2 ∣ p - 1 := by
      have := hp.two_le
      omega
    exact Nat.gcd_eq_right h2
  have hq1 : (q - 1).gcd 2 = 2 := by
    have h2 : 2 ∣ q - 1 := by
      have := hq.two_le
      omega
    exact Nat.gcd_eq_right h2
  rw [card_kthRoots_semiprime hp hq hpq 2, hp1, hq1]

/-- **Barrier 5 for the square-root count.**  Since the `k = 2` order count is the
constant `4`, no function of it can return a prime factor: this member of the KROOT
family is a *non*-witness, and the classification's requirement that the local weight
separate primes is not vacuous. -/
theorem kroot_two_no_recovery :
    ¬ ∃ f : ℕ → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → 2 < x → x < y →
        f (Nat.card {u : (ZMod (x * y))ˣ // u ^ 2 = 1}) = x := by
  rintro ⟨f, hf⟩
  have h₁ := hf 3 5 Nat.prime_three (by norm_num) (by norm_num) (by norm_num)
  have h₂ := hf 5 7 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  rw [card_sqrtOne_semiprime Nat.prime_three (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)] at h₁
  rw [card_sqrtOne_semiprime (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)] at h₂
  omega

/-! ## 4. The order channel reduces to the trace channel -/

/-- The KROOT count never exceeds `φ(N) = (p-1)(q-1)`. -/
theorem kroot_le_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) :
    Nat.card {x : (ZMod (p * q))ˣ // x ^ k = 1} ≤ (p - 1) * (q - 1) := by
  rw [card_kthRoots_semiprime hp hq hpq k]
  have h1 : (p - 1).gcd k ≤ p - 1 := Nat.le_of_dvd (by have := hp.two_le; omega) (Nat.gcd_dvd_left _ _)
  have h2 : (q - 1).gcd k ≤ q - 1 := Nat.le_of_dvd (by have := hq.two_le; omega) (Nat.gcd_dvd_left _ _)
  exact Nat.mul_le_mul h1 h2

/-- **The maximum of the order channel is `φ(N)`**, attained at `k = φ(N)`. -/
theorem kroot_max_eq_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Nat.card {x : (ZMod (p * q))ˣ // x ^ ((p - 1) * (q - 1)) = 1} = (p - 1) * (q - 1) := by
  rw [card_kthRoots_semiprime hp hq hpq _]
  rw [Nat.gcd_eq_left ⟨q - 1, rfl⟩, Nat.gcd_eq_left ⟨p - 1, mul_comm _ _⟩]

/-- `φ(N)` and `N` give the trace: `p + q = N + 1 - (p-1)(q-1)`. -/
theorem trace_of_totient {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    p + q = p * q + 1 - (p - 1) * (q - 1) := by
  cases' Nat.exists_eq_add_of_le hp with a ha
  cases' Nat.exists_eq_add_of_le hq with b hb
  subst ha; subst hb
  simp only [Nat.add_sub_cancel_left]
  ring_nf
  omega

/-- **The trace lemma for KROOT.**  The order channel, maximised over `k`, delivers
`φ(N)`; feeding `N + 1 - φ(N)` into the closed-form recovery of
`Tropical.TraceLemmaExhaustiveness` returns the smaller prime.  Hence the KROOT witness
carries exactly one factor-secret coordinate — the trace — and nothing more. -/
theorem kroot_recovers_small_factor {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hle : p ≤ q) (Φ : ℕ)
    (hΦ : Φ = Nat.card {x : (ZMod (p * q))ˣ // x ^ ((p - 1) * (q - 1)) = 1}) :
    TraceLemma.recoverSmallFactor (p * q) (p * q + 1 - Φ) = p := by
  rw [hΦ, kroot_max_eq_totient hp hq hpq, ← trace_of_totient hp.pos hq.pos]
  exact TraceLemma.recoverSmallFactor_eq hle

end FreeWitnessOrder