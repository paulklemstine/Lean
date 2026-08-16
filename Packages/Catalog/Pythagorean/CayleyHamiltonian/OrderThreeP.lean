import Pythagorean.CayleyHamiltonian.OrderPQ
import Pythagorean.CayleyHamiltonian.OrderTwoP

/-!
# Every connected Cayley graph of a group of order `3q` is hamiltonian

This file closes the case `p = 3` of the order-`pq` problem, the next case after the
order-`2p` theorem of `OrderTwoP.lean`.

The new ingredient is the observation that the Cayley graph only depends on the *symmetric
closure* `S ∪ S⁻¹` of the connection set (`cayleyGraph_union_inv`).  Consequently the
same-coset criterion `isHamiltonian_of_same_coset_pair` of `FactorGroupLemma.lean` applies not
only when two elements of `S` lie in one coset of the normal subgroup `N = ⟨a⟩`, but also when
two elements lie in *mutually inverse* cosets — one simply replaces `y` by `y⁻¹`.  This is
`isHamiltonian_of_inverse_coset_pair`.

Feeding that into the reduction theorem `pq_isHamiltonian_or_transversal` upgrades the
dichotomy to its symmetric form (`pq_isHamiltonian_or_symmetric_transversal`): a connected
Cayley graph of a group of order `q p` is hamiltonian unless the nonidentity elements of `S`
lie in pairwise distinct cosets of `N` *and* no two of them lie in mutually inverse cosets,
except for genuinely inverse pairs `y = x⁻¹`.

For `p = 3` this configuration is empty: the quotient `G/N` has order `3`, so its two
nonidentity elements are inverse to each other, whence `S ⊆ {1, x, x⁻¹}` for a single `x` of
order `3`, and such an `S` cannot generate a group of order `3q`.

Main results:

* `CayleyHamiltonian.cayleyGraph_union_inv` : `Cay(G, S ∪ S⁻¹) = Cay(G, S)`.
* `CayleyHamiltonian.isHamiltonian_of_same_coset_pair'` : the same-coset criterion with the
  coset shift given as an element of `⟨a⟩` rather than as an explicit power.
* `CayleyHamiltonian.isHamiltonian_of_inverse_coset_pair` : the inverse-coset criterion.
* `CayleyHamiltonian.pq_isHamiltonian_or_symmetric_transversal` : the symmetric reduction
  theorem for order `pq`.
* `CayleyHamiltonian.isHamiltonian_of_card_eq_three_mul_prime` : **every connected Cayley graph
  of a group of order `3q` (`q` a prime other than `3`) is hamiltonian.**
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

omit [Fintype G] [DecidableEq G] in
/-- A Cayley graph depends only on the symmetric closure of its connection set. -/
lemma cayleyGraph_union_inv : cayleyGraph G (S ∪ S⁻¹) = cayleyGraph G S := by
  ext g h
  simp only [cayleyGraph_adj, Set.mem_union, Set.mem_inv, mul_inv_rev, inv_inv]
  tauto

/-- The same-coset criterion of `isHamiltonian_of_same_coset_pair`, with the coset shift
presented as an arbitrary nonidentity element of the normal subgroup `⟨a⟩`. -/
theorem isHamiltonian_of_same_coset_pair' {a x y z : G} {q k : ℕ}
    (hq : q.Prime) (hx : x ∈ S) (hy : y ∈ S) (hk : 2 ≤ k)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hz : z ∈ Subgroup.zpowers a) (hz1 : z ≠ 1) (hyx : y = z * x)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  obtain ⟨w, hw⟩ := Subgroup.mem_zpowers_iff.1 hz
  obtain ⟨c, hc⟩ := exists_nat_pow_eq_zpow (a := a) horda hq.pos w
  exact isHamiltonian_of_same_coset_pair hq hx hy hk horda hordx hcop hnormal
    (by rw [hc, hw]; exact hz1) (by rw [hyx, hc, hw]) hcard

/-- **Two connection-set elements in mutually inverse cosets.**  If `x ∈ S` has order `k` with
`|G| = q k`, `q` prime and coprime to `k`, and some `y ∈ S` satisfies `y⁻¹ = z x` for a
nonidentity `z` of the normal subgroup `⟨a⟩` of order `q`, then `Cay(G, S)` is hamiltonian.

This is the same-coset criterion applied to the symmetric closure `S ∪ S⁻¹`, which defines the
same graph. -/
theorem isHamiltonian_of_inverse_coset_pair {a x y z : G} {q k : ℕ}
    (hq : q.Prime) (hx : x ∈ S) (hy : y ∈ S) (hk : 2 ≤ k)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hz : z ∈ Subgroup.zpowers a) (hz1 : z ≠ 1) (hyx : y⁻¹ = z * x)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  rw [← cayleyGraph_union_inv]
  exact isHamiltonian_of_same_coset_pair' (S := S ∪ S⁻¹) hq (Set.mem_union_left _ hx)
    (Set.mem_union_right _ (by simpa using hy)) hk horda hordx hcop hnormal hz hz1 hyx hcard

section OrderPQ

variable {p q : ℕ} {a : G}

/-- **The symmetric reduction theorem for order `pq`.**  Let `|G| = q p` with `p ≠ q` primes,
let `⟨a⟩` be normal of order `q`, and let `S` generate `G`.  Then either `Cay(G, S)` is
hamiltonian, or

* no nonidentity element of `S` lies in `⟨a⟩`;
* two nonidentity elements of `S` in the same coset of `⟨a⟩` are equal;
* two nonidentity elements of `S` in mutually inverse cosets of `⟨a⟩` are inverse to each
  other.

The last clause strengthens `pq_isHamiltonian_or_transversal`. -/
theorem pq_isHamiltonian_or_symmetric_transversal (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (horda : orderOf a = q) (hnormal : (Subgroup.zpowers a).Normal)
    (hcard : Fintype.card G = q * p) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian ∨
      ((∀ s ∈ S, s ≠ 1 → s ∉ Subgroup.zpowers a) ∧
        (∀ x ∈ S, ∀ y ∈ S, x ≠ 1 → y ≠ 1 → y * x⁻¹ ∈ Subgroup.zpowers a → x = y) ∧
        (∀ x ∈ S, ∀ y ∈ S, x ≠ 1 → y ≠ 1 → y * x ∈ Subgroup.zpowers a → y = x⁻¹)) := by
  classical
  by_cases hham : (cayleyGraph G S).IsHamiltonian
  · exact Or.inl hham
  obtain ⟨h1, h2⟩ :=
    (pq_isHamiltonian_or_transversal hp hq hpq horda hnormal hcard hconn).resolve_left hham
  refine Or.inr ⟨h1, h2, ?_⟩
  intro x hxS y hyS hx1 hy1 hmem
  by_contra hne
  have hxN : x ∉ Subgroup.zpowers a := h1 x hxS hx1
  have h3 : 3 ≤ q * p := by nlinarith [hp.two_le, hq.two_le]
  have hordx : orderOf x = p := by
    rcases orderOf_eq_or_of_notMem_normal hp hq hpq hnormal horda hcard hxN with h | h
    · exact h
    · exact absurd (isHamiltonian_of_orderOf_eq_card hxS (by rw [h, hcard])
        (by rw [hcard]; exact h3)) hham
  have hz : x * (y * x)⁻¹ * x⁻¹ ∈ Subgroup.zpowers a :=
    hnormal.conj_mem _ (Subgroup.inv_mem _ hmem) x
  have hz1 : x * (y * x)⁻¹ * x⁻¹ ≠ 1 := by
    intro h
    have hyx1 : y * x = 1 := by
      have h' : (y * x)⁻¹ = 1 := by
        have := congrArg (fun g => x⁻¹ * g * x) h
        simpa [mul_assoc] using this
      simpa using congrArg (fun g : G => g⁻¹) h'
    exact hne (mul_eq_one_iff_eq_inv.1 hyx1)
  have hyinv : y⁻¹ = x * (y * x)⁻¹ * x⁻¹ * x := by group
  exact hham (isHamiltonian_of_inverse_coset_pair hq hxS hyS hp.two_le horda hordx
    ((Nat.coprime_primes hq hp).2 (Ne.symm hpq)) hnormal hz hz1 hyinv hcard)

end OrderPQ

/-- In a group with exactly three elements, any two nonidentity elements are equal or
inverse. -/
private lemma eq_or_eq_inv_of_natCard_three {Q : Type*} [Group Q] (hQ : Nat.card Q = 3)
    {u v : Q} (hu : u ≠ 1) (hv : v ≠ 1) : v = u ∨ v = u⁻¹ := by
  haveI : Finite Q := Nat.finite_of_card_ne_zero (by omega)
  haveI := Fintype.ofFinite Q
  classical
  have hcard : Fintype.card Q = 3 := by rwa [Nat.card_eq_fintype_card] at hQ
  have hordu : orderOf u = 3 := by
    have hdvd : orderOf u ∣ 3 := hQ ▸ orderOf_dvd_natCard u
    rcases (Nat.dvd_prime (by norm_num)).1 hdvd with h | h
    · exact absurd (orderOf_eq_one_iff.1 h) hu
    · exact h
  have huinv : u ≠ u⁻¹ := by
    intro h
    have h2 : u ^ 2 = 1 := by
      rw [pow_two]
      nth_rewrite 1 [h]
      exact inv_mul_cancel u
    have := orderOf_dvd_of_pow_eq_one h2
    rw [hordu] at this
    omega
  have huinv1 : u⁻¹ ≠ 1 := fun h => hu (by simpa using congrArg (fun g : Q => g⁻¹) h)
  have h3 : ({1, u, u⁻¹} : Finset Q).card = 3 := by
    rw [Finset.card_insert_of_notMem (by simp [Ne.symm hu, Ne.symm huinv1]),
      Finset.card_insert_of_notMem (by simp [huinv]), Finset.card_singleton]
  have huniv : ({1, u, u⁻¹} : Finset Q) = Finset.univ :=
    Finset.eq_univ_of_card _ (by rw [h3, hcard])
  have hmem : v ∈ ({1, u, u⁻¹} : Finset Q) := by rw [huniv]; exact Finset.mem_univ v
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with h | h | h
  · exact absurd h hv
  · exact Or.inl h
  · exact Or.inr h

/-- **All connected Cayley graphs of a group of order `3q` (`q` a prime other than `3`) are
hamiltonian.**  No hypothesis is imposed on the connection set other than that it generates
the group.

For `q = 2` this is the order-`2p` theorem.  For `q ≥ 5` the Sylow `q`-subgroup `N = ⟨a⟩` has
index `3`, the smallest prime factor of `|G|`, hence is normal, and the symmetric reduction
theorem applies: were the graph not hamiltonian, all nonidentity elements of `S` would lie in
the two nonidentity cosets of `N`, which are inverse to each other, forcing
`S ⊆ {1, x, x⁻¹}` with `orderOf x = 3` — too small to generate `G`. -/
theorem isHamiltonian_of_card_eq_three_mul_prime {q : ℕ} (hq : q.Prime) (hq3 : q ≠ 3)
    (hcard : Fintype.card G = 3 * q) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian := by
  classical
  rcases eq_or_ne q 2 with rfl | hq2
  · exact isHamiltonian_of_card_eq_two_mul_prime (p := 3) (by norm_num) (by norm_num)
      (by omega) hconn
  haveI : Fact q.Prime := ⟨hq⟩
  have hq4 : q ≠ 4 := by
    intro h
    rw [h] at hq
    norm_num at hq
  have hq5 : 5 ≤ q := by
    have := hq.two_le
    omega
  have hcard' : Fintype.card G = q * 3 := by omega
  have hGcard : Nat.card G = q * 3 := by rw [Nat.card_eq_fintype_card, hcard']
  obtain ⟨a, ha⟩ : ∃ a : G, orderOf a = q :=
    exists_prime_orderOf_dvd_card q (by rw [hcard]; exact dvd_mul_left q 3)
  have hNcard : Nat.card (Subgroup.zpowers a) = q := by rw [Nat.card_zpowers, ha]
  have hindex : (Subgroup.zpowers a).index = 3 := by
    have h := Subgroup.card_mul_index (Subgroup.zpowers a)
    rw [hNcard, hGcard] at h
    exact Nat.eq_of_mul_eq_mul_left hq.pos h
  -- `3` is the smallest prime factor of `|G| = 3q`, so the index-`3` subgroup is normal
  have hminfac : (Nat.card G).minFac = 3 := by
    have hprime : (Nat.card G).minFac.Prime := Nat.minFac_prime (by rw [hGcard]; omega)
    have hle : (Nat.card G).minFac ≤ 3 :=
      Nat.minFac_le_of_dvd (by norm_num) (by rw [hGcard]; exact dvd_mul_left 3 q)
    have hne2 : (Nat.card G).minFac ≠ 2 := by
      intro h
      have hdvd : (2 : ℕ) ∣ Nat.card G := h ▸ Nat.minFac_dvd _
      rw [hGcard] at hdvd
      rcases (Nat.Prime.dvd_mul Nat.prime_two).1 hdvd with h2 | h2
      · exact hq2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hq).1 h2).symm
      · omega
    have := hprime.two_le
    omega
  haveI hnormal : (Subgroup.zpowers a).Normal :=
    Subgroup.normal_of_index_eq_minFac_card (by rw [hindex, hminfac])
  by_cases hham : (cayleyGraph G S).IsHamiltonian
  · exact hham
  exfalso
  obtain ⟨h1, h2, h3⟩ :=
    (pq_isHamiltonian_or_symmetric_transversal (p := 3) (q := q) (by norm_num) hq
      (Ne.symm hq3) ha hnormal hcard' hconn).resolve_left hham
  -- the connection set contains a nonidentity element
  have hex : ∃ x ∈ S, x ≠ 1 := by
    by_contra hcon
    push_neg at hcon
    have hle : Subgroup.closure S ≤ ⊥ :=
      (Subgroup.closure_le _).2 fun s hs => by simp [hcon s hs]
    rw [hconn] at hle
    have hone : ∀ g : G, g = 1 := fun g => by
      simpa using hle (Subgroup.mem_top g)
    have : Fintype.card G = 1 := Fintype.card_eq_one_iff.2 ⟨1, fun g => hone g⟩
    omega
  obtain ⟨x, hxS, hx1⟩ := hex
  have hxN : x ∉ Subgroup.zpowers a := h1 x hxS hx1
  have hordx : orderOf x = 3 := by
    rcases orderOf_eq_or_of_notMem_normal (p := 3) (q := q) (by norm_num) hq (Ne.symm hq3)
      hnormal ha hcard' hxN with h | h
    · exact h
    · exact absurd (isHamiltonian_of_orderOf_eq_card hxS (by rw [h, hcard']) (by omega)) hham
  have hQ : Nat.card (G ⧸ Subgroup.zpowers a) = 3 := by
    rw [← Subgroup.index_eq_card]; exact hindex
  have hux : (QuotientGroup.mk x : G ⧸ Subgroup.zpowers a) ≠ 1 := fun hc =>
    hxN ((QuotientGroup.eq_one_iff x).1 hc)
  -- every element of `S` is `1`, `x` or `x⁻¹`
  have hkey : ∀ y ∈ S, y = 1 ∨ y = x ∨ y = x⁻¹ := by
    intro y hyS
    rcases eq_or_ne y 1 with rfl | hy1
    · exact Or.inl rfl
    refine Or.inr ?_
    have hyN : y ∉ Subgroup.zpowers a := h1 y hyS hy1
    have huy : (QuotientGroup.mk y : G ⧸ Subgroup.zpowers a) ≠ 1 := fun hc =>
      hyN ((QuotientGroup.eq_one_iff y).1 hc)
    rcases eq_or_eq_inv_of_natCard_three hQ hux huy with h | h
    · have hmem : y * x⁻¹ ∈ Subgroup.zpowers a := by
        rw [← QuotientGroup.eq_one_iff, QuotientGroup.mk_mul, QuotientGroup.mk_inv, h,
          mul_inv_cancel]
      exact Or.inl (h2 x hxS y hyS hx1 hy1 hmem).symm
    · have hmem : y * x ∈ Subgroup.zpowers a := by
        rw [← QuotientGroup.eq_one_iff, QuotientGroup.mk_mul, h, inv_mul_cancel]
      exact Or.inr (h3 x hxS y hyS hx1 hy1 hmem)
  -- hence `S` generates only `⟨x⟩`, of order `3`
  have hle : Subgroup.closure S ≤ Subgroup.zpowers x := by
    refine (Subgroup.closure_le _).2 ?_
    intro s hs
    rcases hkey s hs with h | h | h
    · rw [h]; exact one_mem _
    · rw [h]; exact Subgroup.mem_zpowers x
    · rw [h]; exact Subgroup.inv_mem _ (Subgroup.mem_zpowers x)
  rw [hconn] at hle
  have htop : Subgroup.zpowers x = ⊤ := eq_top_iff.2 hle
  have h3card : Nat.card (Subgroup.zpowers x) = 3 := by rw [Nat.card_zpowers, hordx]
  rw [htop, Subgroup.card_top, hGcard] at h3card
  omega

end CayleyHamiltonian