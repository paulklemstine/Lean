import Pythagorean.CayleyHamiltonian.AbelianTorusGeneral
import Pythagorean.CayleyHamiltonian.Cyclic

/-!
# Every connected Cayley graph of an abelian group of order `pq` is hamiltonian

Let `G` be abelian with `|G| = p * q` for two distinct primes.  A connection set `S` with
`⟪S⟫ = G` either contains a generator of `G` (order `pq`), or else it must contain an element
of order `p` *and* an element of order `q`: otherwise all of `S` would lie in the `p`-torsion
(resp. `q`-torsion) subgroup, which is proper because Cauchy's theorem supplies an element of
order `q` (resp. `p`).  In the second case the two elements have coprime orders with product
`|G|`, so the parity-free zigzag on the torus `C_p □ C_q` applies.

Main result: `CayleyHamiltonian.abelian_isHamiltonian_of_card_eq_prime_mul_prime`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

/-- The `n`-torsion subgroup of an abelian group. -/
def torsionBy (G : Type*) [CommGroup G] (n : ℕ) : Subgroup G where
  carrier := {g : G | g ^ n = 1}
  one_mem' := one_pow n
  mul_mem' := by
    intro x y hx hy
    simp only [Set.mem_setOf_eq] at *
    rw [mul_pow, hx, hy, mul_one]
  inv_mem' := by
    intro x hx
    simp only [Set.mem_setOf_eq] at *
    rw [inv_pow, hx, inv_one]

omit [Fintype G] [DecidableEq G] in
@[simp] lemma mem_torsionBy {n : ℕ} {g : G} : g ∈ torsionBy G n ↔ g ^ n = 1 := Iff.rfl

/-- **All connected Cayley graphs of an abelian group of order `pq` are hamiltonian.**
No hypothesis is imposed on the connection set beyond generating the group. -/
theorem abelian_isHamiltonian_of_card_eq_prime_mul_prime {p q : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hpq : p ≠ q) {S : Set G} (hcard : Fintype.card G = p * q)
    (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have h3 : 3 ≤ p * q := by nlinarith
  -- if the connection set contains a generator we are done
  by_cases hbig : ∃ g ∈ S, orderOf g = p * q
  · obtain ⟨g, hgS, hgo⟩ := hbig
    exact isHamiltonian_of_orderOf_eq_card hgS (by rw [hgo, hcard]) (by omega)
  push_neg at hbig
  -- otherwise every element of the connection set has order `1`, `p` or `q`
  have hcauchy : ∀ r : ℕ, r.Prime → r ∣ p * q → ∃ g : G, orderOf g = r := by
    intro r hr hrd
    haveI : Fact r.Prime := ⟨hr⟩
    exact exists_prime_orderOf_dvd_card r (by rw [hcard]; exact hrd)
  -- the connection set is not contained in the `r`-torsion for `r ∈ {p, q}`
  have hnotors : ∀ r r' : ℕ, r.Prime → r'.Prime → r ≠ r' → r' ∣ p * q →
      ¬ (S ⊆ (torsionBy G r : Set G)) := by
    intro r r' hr hr' hne hr'd hsub
    have htop : (⊤ : Subgroup G) ≤ torsionBy G r :=
      hconn ▸ (Subgroup.closure_le _).2 hsub
    obtain ⟨c, hc⟩ := hcauchy r' hr' hr'd
    have hcr : c ^ r = 1 := htop (Subgroup.mem_top c)
    have : r' ∣ r := hc ▸ orderOf_dvd_of_pow_eq_one hcr
    exact hne ((Nat.prime_dvd_prime_iff_eq hr' hr).1 this).symm
  -- extract an element of order `p` and an element of order `q`
  have hexists : ∀ r r' : ℕ, r.Prime → r'.Prime → r ≠ r' → r * r' = p * q →
      ∃ g ∈ S, orderOf g = r := by
    intro r r' hr hr' hne hmul
    by_contra hcon
    push_neg at hcon
    refine hnotors r' r hr' hr hne.symm ⟨r', hmul.symm⟩ ?_
    intro g hgS
    have hdvd : orderOf g ∣ p * q := by rw [← hcard]; exact orderOf_dvd_card
    have hg1 : orderOf g ≠ r := hcon g hgS
    have hgpq : orderOf g ≠ p * q := hbig g hgS
    -- `orderOf g` divides `r * r'` and is neither `r` nor `r * r'`, hence divides `r'`
    rw [← hmul] at hdvd hgpq
    have hfin : orderOf g ∣ r' := by
      -- the divisors of a product of two distinct primes are `1, r, r', r * r'`
      have hkey : orderOf g = 1 ∨ orderOf g = r ∨ orderOf g = r' ∨ orderOf g = r * r' := by
        by_cases hrd : r ∣ orderOf g
        · obtain ⟨e, he⟩ := hrd
          rw [he] at hdvd
          have hed : e ∣ r' := (mul_dvd_mul_iff_left hr.pos.ne').1 hdvd
          rcases (Nat.dvd_prime hr').1 hed with h | h
          · exact Or.inr (Or.inl (by rw [he, h, mul_one]))
          · exact Or.inr (Or.inr (Or.inr (by rw [he, h])))
        · have hcop : Nat.Coprime r (orderOf g) := (Nat.Prime.coprime_iff_not_dvd hr).2 hrd
          have hd' : orderOf g ∣ r' := Nat.Coprime.dvd_of_dvd_mul_left hcop.symm hdvd
          rcases (Nat.dvd_prime hr').1 hd' with h | h
          · exact Or.inl h
          · exact Or.inr (Or.inr (Or.inl h))
      rcases hkey with h | h | h | h
      · rw [h]; exact one_dvd _
      · exact absurd h hg1
      · rw [h]
      · exact absurd h hgpq
    simpa [mem_torsionBy, ← orderOf_dvd_iff_pow_eq_one] using hfin
  obtain ⟨a, haS, hao⟩ := hexists p q hp hq hpq rfl
  obtain ⟨b, hbS, hbo⟩ := hexists q p hq hp (Ne.symm hpq) (Nat.mul_comm q p)
  exact isHamiltonian_of_coprime_pair (Commute.all a b) haS hbS hp2 hq2 hao hbo
    ((Nat.coprime_primes hp hq).2 hpq) hcard

end CayleyHamiltonian