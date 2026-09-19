/-
# CONVERSE-COST-CURVE, part VII: the idempotent ladder `2^ω(N)` (cycle 4)

Part III proved that a semiprime modulus carries exactly four idempotents and
that this number is therefore constant across the family — the W4 counter
carries no factorisation information.  Cycle 4 closes the conjecture that was
spun off from it: for an *arbitrary* modulus the idempotent count is
`2^{ω(N)}`, where `ω(N)` is the number of distinct prime factors.

So the W4 route, whose definition scan costs `Θ(N)`, returns exactly one
number: `ω(N)`.  It never distinguishes two moduli with the same number of
prime factors, in particular never two semiprimes.

* `ConverseCost.idempotent_of_prime_pow` — local rigidity: modulo a prime power
  the only idempotents are `0` and `1`.
* `ConverseCost.idempotent_card_prime_pow` — hence the count is `2`.
* `ConverseCost.idempotent_card_eq_two_pow_omega` — the ladder
  `#idempotents(ZMod N) = 2^{ω(N)}` for every `N > 0`.
-/
import Mathlib
import Combinatorics.ConverseCostIdempotentPlane

namespace ConverseCost

open Finset

/-- The value of an idempotent of `ZMod m` satisfies `m ∣ v (v-1)` in `ℕ`. -/
theorem idempotent_val_dvd {m : ℕ} [NeZero m] (x : ZMod m) (h : x * x = x) :
    m ∣ x.val * (x.val - 1) := by
  have hcast : ((x.val * x.val : ℕ) : ZMod m) = ((x.val : ℕ) : ZMod m) := by
    push_cast [ZMod.natCast_val, ZMod.cast_id]
    exact h
  have hmod : x.val ≡ x.val * x.val [MOD m] :=
    ((ZMod.natCast_eq_natCast_iff _ _ _).mp hcast).symm
  rcases Nat.eq_zero_or_pos x.val with h0 | h0
  · simp [h0]
  · have hle : x.val ≤ x.val * x.val := Nat.le_mul_of_pos_left _ h0
    have hd := (Nat.modEq_iff_dvd' hle).mp hmod
    rwa [Nat.mul_sub, Nat.mul_one]

/-- **Local rigidity.**  Modulo a prime power the only idempotents are the
trivial ones: the prime `p` cannot divide both `v` and `v - 1`. -/
theorem idempotent_of_prime_pow {p n : ℕ} (hp : p.Prime)
    (x : ZMod (p ^ n)) (h : x * x = x) : x = 0 ∨ x = 1 := by
  have hpos : 0 < p ^ n := pow_pos hp.pos n
  haveI : NeZero (p ^ n) := ⟨hpos.ne'⟩
  have hdvd := idempotent_val_dvd x h
  have hvlt : x.val < p ^ n := ZMod.val_lt x
  have hx : ((x.val : ℕ) : ZMod (p ^ n)) = x := by simp [ZMod.natCast_val, ZMod.cast_id]
  rcases Nat.eq_zero_or_pos x.val with h0 | h0
  · left
    rw [← hx, h0]; simp
  · by_cases hpv : p ∣ x.val
    · exfalso
      have hnd : ¬ p ∣ (x.val - 1) := by
        intro hc
        have h1 : p ∣ x.val - (x.val - 1) := Nat.dvd_sub hpv hc
        rw [show x.val - (x.val - 1) = 1 by omega] at h1
        exact absurd (Nat.le_of_dvd one_pos h1) (by have := hp.two_le; omega)
      have hcop : Nat.Coprime (p ^ n) (x.val - 1) :=
        Nat.Coprime.pow_left _ ((Nat.Prime.coprime_iff_not_dvd hp).mpr hnd)
      exact absurd (Nat.le_of_dvd h0 (hcop.dvd_of_dvd_mul_right hdvd)) (by omega)
    · right
      have hcop : Nat.Coprime (p ^ n) x.val :=
        Nat.Coprime.pow_left _ ((Nat.Prime.coprime_iff_not_dvd hp).mpr hpv)
      have hd : p ^ n ∣ (x.val - 1) := hcop.dvd_of_dvd_mul_left hdvd
      have hz : x.val - 1 = 0 := by
        rcases Nat.eq_zero_or_pos (x.val - 1) with h1 | h1
        · exact h1
        · exact absurd (Nat.le_of_dvd h1 hd) (by omega)
      have hv1 : x.val = 1 := by omega
      rw [← hx, hv1]; simp

/-- A prime-power modulus carries exactly two idempotents. -/
theorem idempotent_card_prime_pow {p n : ℕ} (hp : p.Prime) (hn : 0 < n) :
    Nat.card {x : ZMod (p ^ n) // x * x = x} = 2 := by
  have hpos : 0 < p ^ n := pow_pos hp.pos n
  haveI : NeZero (p ^ n) := ⟨hpos.ne'⟩
  haveI : Fintype (ZMod (p ^ n)) := ZMod.fintype _
  have hm1 : 1 < p ^ n := Nat.one_lt_pow (by omega) hp.one_lt
  haveI : Fact (1 < p ^ n) := ⟨hm1⟩
  haveI : Nontrivial (ZMod (p ^ n)) := ZMod.nontrivial _
  classical
  have hset : (Finset.univ.filter (fun x : ZMod (p ^ n) => x * x = x)) = {0, 1} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
    exact ⟨fun h => idempotent_of_prime_pow hp x h, by rintro (rfl | rfl) <;> ring⟩
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype, hset,
    Finset.card_insert_of_notMem (by simp [zero_ne_one]), Finset.card_singleton]

/-- **The idempotent ladder.**  For every positive modulus the number of
idempotents of `ZMod N` is `2^{ω(N)}`, where `ω(N) = #N.primeFactors`.

Consequently the W4 route is an `ω`-detector and nothing more: its `Θ(N)` scan
cannot distinguish any two moduli with the same number of distinct prime
factors, in particular no two semiprimes. -/
theorem idempotent_card_eq_two_pow_omega :
    ∀ N : ℕ, 0 < N → Nat.card {x : ZMod N // x * x = x} = 2 ^ N.primeFactors.card := by
  intro N
  induction N using Nat.recOnPosPrimePosCoprime with
  | prime_pow p n hp hn =>
      intro _
      rw [idempotent_card_prime_pow hp hn, Nat.primeFactors_pow _ hn.ne',
        hp.primeFactors, Finset.card_singleton, pow_one]
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | one =>
      intro _
      haveI : Subsingleton {x : ZMod 1 // x * x = x} :=
        ⟨fun a b => Subtype.ext (Subsingleton.elim _ _)⟩
      have hcard : Nat.card {x : ZMod 1 // x * x = x} = 1 :=
        Nat.card_eq_one_iff_unique.mpr ⟨inferInstance, ⟨⟨0, by ring⟩⟩⟩
      rw [hcard]
      simp
  | coprime a b ha hb hab iha ihb =>
      intro _
      have ha0 : 0 < a := by omega
      have hb0 : 0 < b := by omega
      rw [idempotent_card_crt hab, idempotent_card_prod, iha ha0, ihb hb0,
        Nat.primeFactors_mul ha0.ne' hb0.ne',
        Finset.card_union_of_disjoint (Nat.Coprime.disjoint_primeFactors hab),
        pow_add]

/-! ## Lab notes -/

/-- `N = 105 = 3·5·7` has `ω = 3`, hence `8` idempotents — matching the scan. -/
example : ((Finset.range 105).filter (fun x => x * x % 105 = x)).card = 8 := by decide

/-- `N = 49 = 7²` has `ω = 1`, hence only the two trivial idempotents. -/
example : ((Finset.range 49).filter (fun x => x * x % 49 = x)).card = 2 := by decide

end ConverseCost