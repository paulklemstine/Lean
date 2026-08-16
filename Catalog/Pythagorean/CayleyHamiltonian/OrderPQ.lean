import Pythagorean.CayleyHamiltonian.Metacyclic
import Pythagorean.CayleyHamiltonian.FactorGroupLemma

/-!
# A reduction theorem for Cayley graphs of order `pq`

Let `|G| = q * p` with `p ≠ q` prime and let `N = ⟨a⟩` be a *normal* subgroup of order `q`
(this is automatic for the Sylow `q`-subgroup when `q > p`).  Combining

* `CayleyHamiltonian.pq_isHamiltonian_of_normal_pair` (the connection set meets both `N` and a
  complement), and
* `CayleyHamiltonian.isHamiltonian_of_same_coset_pair` (two connection-set elements in one and
  the same coset of `N`),

with the cyclic case reduces the order-`pq` problem to a single configuration: a connection set
that is a *partial transversal* of the nontrivial cosets of `N`.

Main results:

* `CayleyHamiltonian.mem_normal_of_pow_prime_eq_one` : an element killed by `q` lies in `N`.
* `CayleyHamiltonian.orderOf_eq_or_of_notMem_normal` : elements outside `N` have order `p`
  or `q * p`.
* `CayleyHamiltonian.pq_isHamiltonian_of_mem_normal` : if the connection set meets `N`
  nontrivially, the Cayley graph is hamiltonian.
* `CayleyHamiltonian.pq_isHamiltonian_or_transversal` : **the reduction theorem** — either the
  Cayley graph is hamiltonian, or `S` misses `N` and its nonidentity elements lie in pairwise
  distinct cosets of `N`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

section OrderPQ

variable {p q : ℕ} {a : G}

omit [DecidableEq G] in
/-- In a group of order `q * p` with a normal subgroup `⟨a⟩` of prime order `q`, every element
killed by `q` already lies in `⟨a⟩`: the normal Sylow `q`-subgroup is the unique one. -/
lemma mem_normal_of_pow_prime_eq_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hnormal : (Subgroup.zpowers a).Normal) (horda : orderOf a = q)
    (hcard : Fintype.card G = q * p) {t : G} (ht : t ^ q = 1) :
    t ∈ Subgroup.zpowers a := by
  haveI := hnormal
  set N : Subgroup G := Subgroup.zpowers a with hN
  have hcardN : Nat.card N = q := by rw [hN, Nat.card_zpowers, horda]
  have hcardG : Nat.card G = q * p := by rw [Nat.card_eq_fintype_card, hcard]
  have hindex : N.index = p := by
    have h := Subgroup.card_mul_index N
    rw [hcardN, hcardG] at h
    exact Nat.eq_of_mul_eq_mul_left hq.pos h
  have hcardQ : Nat.card (G ⧸ N) = p := by rw [← Subgroup.index_eq_card, hindex]
  -- the image of `t` in `G ⧸ N` has order dividing both `q` and `p`
  set u : G ⧸ N := QuotientGroup.mk t with hu
  have h1 : orderOf u ∣ q := by
    refine orderOf_dvd_of_pow_eq_one ?_
    rw [hu, ← QuotientGroup.mk_pow, ht]
    rfl
  have h2 : orderOf u ∣ p := by
    have := orderOf_dvd_natCard u
    rwa [hcardQ] at this
  have hcop : Nat.Coprime q p := (Nat.coprime_primes hq hp).2 (Ne.symm hpq)
  have h3 : orderOf u ∣ 1 := hcop ▸ Nat.dvd_gcd h1 h2
  exact (QuotientGroup.eq_one_iff t).1 (orderOf_eq_one_iff.1 (Nat.dvd_one.1 h3))

omit [DecidableEq G] in
/-- Every element outside the normal subgroup `⟨a⟩` of order `q` has order `p` or `q * p`. -/
lemma orderOf_eq_or_of_notMem_normal (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hnormal : (Subgroup.zpowers a).Normal) (horda : orderOf a = q)
    (hcard : Fintype.card G = q * p) {t : G} (ht : t ∉ Subgroup.zpowers a) :
    orderOf t = p ∨ orderOf t = q * p := by
  have hdvd : orderOf t ∣ q * p := by
    have := orderOf_dvd_card (x := t)
    rwa [hcard] at this
  have hnq : ¬ orderOf t ∣ q := fun h =>
    ht (mem_normal_of_pow_prime_eq_one hp hq hpq hnormal horda hcard
      (orderOf_dvd_iff_pow_eq_one.1 h))
  -- `orderOf t` divides `q * p` but not `q`, hence `p ∣ orderOf t`
  have hp_dvd : p ∣ orderOf t := by
    by_contra hnp
    have hcop : Nat.Coprime (orderOf t) p := ((Nat.Prime.coprime_iff_not_dvd hp).2 hnp).symm
    exact hnq (Nat.Coprime.dvd_of_dvd_mul_right hcop hdvd)
  obtain ⟨m, hm⟩ := hp_dvd
  have hmdvd : m ∣ q := by
    have hpm : p * m ∣ p * q := by
      rw [← hm]
      simpa [mul_comm] using hdvd
    exact (mul_dvd_mul_iff_left hp.pos.ne').1 hpm
  rcases hq.eq_one_or_self_of_dvd m hmdvd with h | h
  · left; rw [hm, h, mul_one]
  · right; rw [hm, h, mul_comm]

/-- A product of two primes is at least three. -/
private lemma three_le_prime_mul_prime (hp : p.Prime) (hq : q.Prime) : 3 ≤ q * p := by
  have h1 := hp.two_le
  have h2 := hq.two_le
  nlinarith

/-- If the (generating) connection set contains a nonidentity element of the normal subgroup
`⟨a⟩` of prime order `q`, the Cayley graph of the order-`q p` group `G` is hamiltonian. -/
theorem pq_isHamiltonian_of_mem_normal (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (horda : orderOf a = q) (hnormal : (Subgroup.zpowers a).Normal)
    (hcard : Fintype.card G = q * p) (hconn : Subgroup.closure S = ⊤)
    {s : G} (hsS : s ∈ S) (hs1 : s ≠ 1) (hsN : s ∈ Subgroup.zpowers a) :
    (cayleyGraph G S).IsHamiltonian := by
  -- `s` has order `q` and hence generates `⟨a⟩`
  have hords : orderOf s = q := by
    have hdvd : orderOf s ∣ q := by
      rw [← horda]
      exact orderOf_dvd_of_mem_zpowers hsN
    rcases hq.eq_one_or_self_of_dvd _ hdvd with h | h
    · exact absurd (orderOf_eq_one_iff.1 h) hs1
    · exact h
  have hzs : Subgroup.zpowers s = Subgroup.zpowers a := by
    have hle : Subgroup.zpowers s ≤ Subgroup.zpowers a := by
      rw [Subgroup.zpowers_le]
      exact hsN
    have hcards : Nat.card (Subgroup.zpowers s) = Nat.card (Subgroup.zpowers a) := by
      rw [Nat.card_zpowers, Nat.card_zpowers, hords, horda]
    exact Subgroup.eq_of_le_of_card_ge hle (le_of_eq hcards.symm)
  -- since `S` generates `G ≠ ⟨a⟩`, some element of `S` lies outside `⟨a⟩`
  have hex : ∃ t ∈ S, t ∉ Subgroup.zpowers a := by
    by_contra hcon
    push_neg at hcon
    have hle : Subgroup.closure S ≤ Subgroup.zpowers a := (Subgroup.closure_le _).2 hcon
    rw [hconn, top_le_iff] at hle
    have htop : Nat.card (Subgroup.zpowers a) = Nat.card G := by
      rw [hle, Subgroup.card_top]
    rw [Nat.card_zpowers, horda, Nat.card_eq_fintype_card, hcard] at htop
    have h1 := hp.two_le
    have h2 := hq.pos
    nlinarith
  obtain ⟨t, htS, htN⟩ := hex
  rcases orderOf_eq_or_of_notMem_normal hp hq hpq hnormal horda hcard htN with hordt | hordt
  · -- `s` of order `q` normalized by `t` of order `p`: the metacyclic case
    refine pq_isHamiltonian_of_normal_pair hq hsS htS hp.two_le hords hordt
      ((Nat.coprime_primes hq hp).2 (Ne.symm hpq)) ?_ hcard
    rw [hzs]
    exact hnormal.conj_mem s hsN t
  · -- `t` generates the whole (necessarily cyclic) group
    exact isHamiltonian_of_orderOf_eq_card htS (by rw [hordt, hcard])
      (by rw [hcard]; exact three_le_prime_mul_prime hp hq)

/-- **Reduction theorem for order `pq`.**  Let `|G| = q p` with `p ≠ q` primes, let `⟨a⟩` be a
normal subgroup of order `q`, and let `S` be a generating (i.e. connected) connection set.
Then either `Cay(G, S)` is hamiltonian, or the connection set is a *partial transversal*:
no nonidentity element of `S` lies in `⟨a⟩`, and no two distinct nonidentity elements of `S`
lie in the same coset of `⟨a⟩`.

Thus the whole order-`pq` problem is reduced to connection sets meeting each nontrivial coset
of the normal Sylow subgroup at most once, and missing that subgroup entirely. -/
theorem pq_isHamiltonian_or_transversal (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (horda : orderOf a = q) (hnormal : (Subgroup.zpowers a).Normal)
    (hcard : Fintype.card G = q * p) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian ∨
      ((∀ s ∈ S, s ≠ 1 → s ∉ Subgroup.zpowers a) ∧
        (∀ x ∈ S, ∀ y ∈ S, x ≠ 1 → y ≠ 1 → y * x⁻¹ ∈ Subgroup.zpowers a → x = y)) := by
  classical
  by_cases hham : (cayleyGraph G S).IsHamiltonian
  · exact Or.inl hham
  refine Or.inr ⟨fun s hsS hs1 hsN =>
      hham (pq_isHamiltonian_of_mem_normal hp hq hpq horda hnormal hcard hconn hsS hs1 hsN),
    ?_⟩
  intro x hxS y hyS hx1 hy1 hmem
  by_contra hxy
  have hxN : x ∉ Subgroup.zpowers a := fun hxN =>
    hham (pq_isHamiltonian_of_mem_normal hp hq hpq horda hnormal hcard hconn hxS hx1 hxN)
  rcases orderOf_eq_or_of_notMem_normal hp hq hpq hnormal horda hcard hxN with hordx | hordx
  · -- `x` and `y` in the same coset: the factor-group construction applies
    obtain ⟨z, hz⟩ := hmem
    have hz' : a ^ z = y * x⁻¹ := hz
    obtain ⟨c, hc⟩ := exists_nat_pow_eq_zpow (a := a) horda hq.pos z
    have hyx : y = a ^ c * x := by
      rw [hc, hz']
      group
    have hac : a ^ c ≠ 1 := by
      intro h
      rw [h, one_mul] at hyx
      exact hxy hyx.symm
    exact hham (isHamiltonian_of_same_coset_pair hq hxS hyS hp.two_le horda hordx
      ((Nat.coprime_primes hq hp).2 (Ne.symm hpq)) hnormal hac hyx hcard)
  · exact hham (isHamiltonian_of_orderOf_eq_card hxS (by rw [hordx, hcard])
      (by rw [hcard]; exact three_le_prime_mul_prime hp hq))

/-- **A counting corollary.**  In a group of order `q p` with normal Sylow subgroup `⟨a⟩` of
order `q`, every connected Cayley graph whose connection set has at least `p` nonidentity
elements is hamiltonian: a partial transversal of the `p - 1` nontrivial cosets of `⟨a⟩` can
never be that large. -/
theorem pq_isHamiltonian_of_le_ncard (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (horda : orderOf a = q) (hnormal : (Subgroup.zpowers a).Normal)
    (hcard : Fintype.card G = q * p) (hconn : Subgroup.closure S = ⊤)
    (hS : p ≤ (S \ {1}).ncard) :
    (cayleyGraph G S).IsHamiltonian := by
  classical
  haveI := hnormal
  set N : Subgroup G := Subgroup.zpowers a with hN
  rcases pq_isHamiltonian_or_transversal hp hq hpq horda hnormal hcard hconn with h | ⟨h1, h2⟩
  · exact h
  -- the quotient has exactly `p` elements
  have hcardN : Nat.card N = q := by rw [hN, Nat.card_zpowers, horda]
  have hcardG : Nat.card G = q * p := by rw [Nat.card_eq_fintype_card, hcard]
  have hindex : N.index = p := by
    have h := Subgroup.card_mul_index N
    rw [hcardN, hcardG] at h
    exact Nat.eq_of_mul_eq_mul_left hq.pos h
  have hcardQ : Nat.card (G ⧸ N) = p := by rw [← Subgroup.index_eq_card, hindex]
  -- the projection is injective on `S \ {1}` and avoids the identity coset
  have hmaps : ∀ x ∈ S \ {1}, (QuotientGroup.mk x : G ⧸ N) ∈ ({1}ᶜ : Set (G ⧸ N)) := by
    rintro x ⟨hxS, hx1⟩
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    intro hcon
    exact h1 x hxS hx1 ((QuotientGroup.eq_one_iff x).1 hcon)
  have hinj : Set.InjOn (fun x : G => (QuotientGroup.mk x : G ⧸ N)) (S \ {1}) := by
    rintro x ⟨hxS, hx1⟩ y ⟨hyS, hy1⟩ hxy
    have hxy' : (QuotientGroup.mk x : G ⧸ N) = QuotientGroup.mk y := hxy
    have : y * x⁻¹ ∈ N := by
      rw [← QuotientGroup.eq_one_iff, QuotientGroup.mk_mul, QuotientGroup.mk_inv, ← hxy',
        mul_inv_cancel]
    exact h2 x hxS y hyS hx1 hy1 this
  have hle : (S \ {1}).ncard ≤ ({1}ᶜ : Set (G ⧸ N)).ncard :=
    Set.ncard_le_ncard_of_injOn _ hmaps hinj (Set.toFinite _)
  have heq : ({1}ᶜ : Set (G ⧸ N)).ncard = p - 1 := by
    rw [Set.ncard_compl, Set.ncard_singleton, hcardQ]
  have hp1 := hp.one_lt
  omega

end OrderPQ

end CayleyHamiltonian