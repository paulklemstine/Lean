import Pythagorean.CayleyHamiltonian.CosetPair
import Pythagorean.CayleyHamiltonian.OrderTwoP

/-!
# Every connected Cayley graph of a group of order `pq` is hamiltonian

This is the complete order-`pq` theorem, the two-prime case of the programme of the paper
*Cayley graphs of order `pqrs` are hamiltonian*.  No hypothesis is placed on the connection set
beyond generating the group, and the group is not assumed abelian.

The proof combines the three ingredients developed in this directory.

* If `p = 2` this is `isHamiltonian_of_card_eq_two_mul_prime`.
* Otherwise write `|G| = q p` with `3 ≤ p < q`.  The Sylow `q`-subgroup `N = ⟨a⟩` has index `p`,
  which is the smallest prime factor of `|G|`, so `N` is normal.
* The reduction theorem `pq_isHamiltonian_or_transversal` says that a non-hamiltonian example
  must have `S ∩ N = {1}`.  Pick `x ∈ S \ {1}`: it has order `p` (or order `pq`, in which case
  it generates and we are done).  Since `⟨x⟩ ≠ G`, some `y ∈ S` lies outside `⟨x⟩`; its image in
  the quotient of order `p` is `x̄^m` for some `0 < m < p`, so `y = A x^m` with `A ∈ N`,
  `A ≠ 1`.
* The coset-pair criterion `isHamiltonian_of_coset_pair` now produces a hamiltonian cycle — a
  contradiction, so no non-hamiltonian example exists.

Main results:

* `CayleyHamiltonian.isHamiltonian_of_card_eq_prime_mul_prime` : **the order-`pq` theorem.**
* `CayleyHamiltonian.isHamiltonian_of_card_eq_mul_of_prime_of_prime` : the same statement with
  the group order given as `Nat.card`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- The order-`pq` theorem in the normalised form `p < q`. -/
private theorem isHamiltonian_of_card_eq_prime_mul_prime_aux {p q : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hpq : p < q) (hcard : Fintype.card G = p * q)
    (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian := by
  classical
  rcases eq_or_ne p 2 with rfl | hp2
  · exact isHamiltonian_of_card_eq_two_mul_prime hq (by omega) hcard hconn
  have hp3 : 3 ≤ p := by
    have h2 := hp.two_le
    have h4 : p ≠ 4 := by intro h; rw [h] at hp; norm_num at hp
    omega
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hq2 : q ≠ 2 := by omega
  haveI : Fact q.Prime := ⟨hq⟩
  have hcard' : Fintype.card G = q * p := by rw [hcard]; ring
  have hGcard : Nat.card G = q * p := by rw [Nat.card_eq_fintype_card, hcard']
  obtain ⟨a, ha⟩ : ∃ a : G, orderOf a = q :=
    exists_prime_orderOf_dvd_card q (by rw [hcard]; exact dvd_mul_left q p)
  have hNcard : Nat.card (Subgroup.zpowers a) = q := by rw [Nat.card_zpowers, ha]
  have hindex : (Subgroup.zpowers a).index = p := by
    have h := Subgroup.card_mul_index (Subgroup.zpowers a)
    rw [hNcard, hGcard] at h
    exact Nat.eq_of_mul_eq_mul_left hq.pos h
  -- `p` is the smallest prime factor of `|G| = q p`, so the index-`p` subgroup is normal
  have hminfac : (Nat.card G).minFac = p := by
    have hprime : (Nat.card G).minFac.Prime := Nat.minFac_prime (by rw [hGcard]; nlinarith)
    have hle : (Nat.card G).minFac ≤ p :=
      Nat.minFac_le_of_dvd hp.two_le (by rw [hGcard]; exact dvd_mul_left p q)
    have hdvd : (Nat.card G).minFac ∣ q * p := by
      rw [← hGcard]; exact Nat.minFac_dvd _
    rcases (Nat.Prime.dvd_mul hprime).1 hdvd with h | h
    · have := (Nat.prime_dvd_prime_iff_eq hprime hq).1 h
      omega
    · exact (Nat.prime_dvd_prime_iff_eq hprime hp).1 h
  haveI hnormal : (Subgroup.zpowers a).Normal :=
    Subgroup.normal_of_index_eq_minFac_card (by rw [hindex, hminfac])
  by_cases hham : (cayleyGraph G S).IsHamiltonian
  · exact hham
  exfalso
  obtain ⟨h1, -⟩ :=
    (pq_isHamiltonian_or_transversal hp hq (by omega) ha hnormal hcard' hconn).resolve_left hham
  -- a nonidentity element of `S`
  have hex : ∃ x ∈ S, x ≠ 1 := by
    by_contra hcon
    push_neg at hcon
    have hle : Subgroup.closure S ≤ ⊥ :=
      (Subgroup.closure_le _).2 fun s hs => by simp [hcon s hs]
    rw [hconn] at hle
    have hone : ∀ g : G, g = 1 := fun g => by simpa using hle (Subgroup.mem_top g)
    have hcard1 : Fintype.card G = 1 := Fintype.card_eq_one_iff.2 ⟨1, fun g => hone g⟩
    rw [hcard] at hcard1
    nlinarith [hp.two_le, hq.two_le]
  obtain ⟨x, hxS, hx1⟩ := hex
  have hxN : x ∉ Subgroup.zpowers a := h1 x hxS hx1
  have hordx : orderOf x = p := by
    rcases orderOf_eq_or_of_notMem_normal hp hq (by omega) hnormal ha hcard' hxN with h | h
    · exact h
    · refine absurd (isHamiltonian_of_orderOf_eq_card hxS (by rw [h, hcard']) ?_) hham
      rw [hcard']
      nlinarith [hq.two_le]
  have hcop : Nat.Coprime q p := (Nat.coprime_primes hq hp).2 (by omega)
  -- the connection set is not contained in `⟨x⟩`
  have hex2 : ∃ y ∈ S, y ∉ Subgroup.zpowers x := by
    by_contra hcon
    push_neg at hcon
    have hle : Subgroup.closure S ≤ Subgroup.zpowers x := (Subgroup.closure_le _).2 hcon
    rw [hconn] at hle
    have htop : Subgroup.zpowers x = ⊤ := eq_top_iff.2 hle
    have hpc : Nat.card (Subgroup.zpowers x) = p := by rw [Nat.card_zpowers, hordx]
    rw [htop, Subgroup.card_top, hGcard] at hpc
    nlinarith [hq.two_le]
  obtain ⟨y, hyS, hyx⟩ := hex2
  have hy1 : y ≠ 1 := fun h => hyx (by rw [h]; exact Subgroup.one_mem _)
  have hyN : y ∉ Subgroup.zpowers a := h1 y hyS hy1
  -- locate `y` in the quotient, which is cyclic of order `p`
  have hQ : Nat.card (G ⧸ Subgroup.zpowers a) = p := by
    rw [← Subgroup.index_eq_card]; exact hindex
  have hux : (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) ≠ 1 := fun hc =>
    hxN ((QuotientGroup.eq_one_iff x).1 hc)
  have hordxQ : orderOf (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) = p := by
    have hdvd : orderOf (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) ∣ p :=
      hQ ▸ orderOf_dvd_natCard _
    rcases (Nat.dvd_prime hp).1 hdvd with h | h
    · exact absurd (orderOf_eq_one_iff.1 h) hux
    · exact h
  have htopQ : Subgroup.zpowers (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) = ⊤ := by
    refine Subgroup.eq_of_le_of_card_ge le_top ?_
    rw [Subgroup.card_top, Nat.card_zpowers, hordxQ, hQ]
  obtain ⟨m, hmlt, hmk⟩ : ∃ m : ℕ, m < p ∧
      (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) ^ m = QuotientGroup.mk y := by
    obtain ⟨w, hw⟩ : ∃ w : ℤ, (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) ^ w
        = QuotientGroup.mk y :=
      Subgroup.mem_zpowers_iff.1 (htopQ ▸ Subgroup.mem_top (QuotientGroup.mk y))
    obtain ⟨e, he⟩ := exists_nat_pow_eq_zpow
      (a := (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a)) hordxQ hp.pos w
    exact ⟨e % p, Nat.mod_lt _ hp.pos, by rw [← hordxQ, pow_mod_orderOf, he, hw]⟩
  have hcoset : y * (x ^ m)⁻¹ ∈ Subgroup.zpowers a := by
    rw [← QuotientGroup.eq_one_iff, QuotientGroup.mk_mul, QuotientGroup.mk_inv,
      QuotientGroup.mk_pow, hmk, mul_inv_cancel]
  have hm0 : 0 < m := by
    rcases Nat.eq_zero_or_pos m with hm | hm
    · exact absurd (by simpa [hm] using hcoset) hyN
    · exact hm
  have hA1 : y * (x ^ m)⁻¹ ≠ 1 := by
    intro h
    have hyeq : y = x ^ m := by
      have := congrArg (fun g : G => g * x ^ m) h
      simpa using this
    exact hyx (by rw [hyeq]; exact Subgroup.pow_mem _ (Subgroup.mem_zpowers x) m)
  exact hham (isHamiltonian_of_coset_pair (a := a) (x := x) (y := y) (A := y * (x ^ m)⁻¹)
    hq hq2 hp3 hpodd hm0 hmlt hxS hyS ha hordx hcop hnormal hcoset hA1 (by group) hcard')

/-- **The order-`pq` theorem.**  For distinct primes `p` and `q`, every connected Cayley graph
of a group of order `pq` is hamiltonian.  No restriction whatsoever is placed on the connection
set beyond generating the group, and the group is not assumed abelian. -/
theorem isHamiltonian_of_card_eq_prime_mul_prime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hcard : Fintype.card G = p * q) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian := by
  rcases lt_or_gt_of_ne hpq with h | h
  · exact isHamiltonian_of_card_eq_prime_mul_prime_aux hp hq h hcard hconn
  · exact isHamiltonian_of_card_eq_prime_mul_prime_aux hq hp h (by rw [hcard]; ring) hconn

/-- The order-`pq` theorem, with the order given as `Nat.card`. -/
theorem isHamiltonian_of_natCard_eq_prime_mul_prime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hcard : Nat.card G = p * q) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian :=
  isHamiltonian_of_card_eq_prime_mul_prime hp hq hpq
    (by rwa [Nat.card_eq_fintype_card] at hcard) hconn

end CayleyHamiltonian