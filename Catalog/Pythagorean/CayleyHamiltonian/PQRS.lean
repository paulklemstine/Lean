import Pythagorean.CayleyHamiltonian.AbelianTorus
import Pythagorean.CayleyHamiltonian.AbelianTorusGeneral
import Pythagorean.CayleyHamiltonian.Cyclic
import Pythagorean.CayleyHamiltonian.Dihedral
import Pythagorean.CayleyHamiltonian.GeneralizedDihedral

/-!
# Cayley graphs of groups of order `pqrs`

This file collects the statements about groups of order `pqrs` (`p, q, r, s` distinct primes)
that follow from the general machinery developed in this directory, together with the sharpness
statements that delimit them.

Main results:

* `CayleyHamiltonian.pqrs_isHamiltonian_of_orderOf_eq_card` : the cyclic-generator case.
* `CayleyHamiltonian.pqrs_abelian_isCyclic` : an abelian group of order `pqrs` is cyclic
  (squarefree order).
* `CayleyHamiltonian.pqrs_abelian_exists_hamiltonian_cayley` : every abelian group of order
  `pqrs` has a generator all of whose Cayley graphs are hamiltonian.
* `CayleyHamiltonian.pqrs_dihedral_isHamiltonian` : for the dihedral group of order
  `2qrs = pqrs` the standard Cayley graph is hamiltonian.
* `CayleyHamiltonian.exists_orderOf_eq_of_prime_dvd_pqrs` : Cauchy elements for each of the
  four primes.
* `CayleyHamiltonian.not_isHamiltonian_of_closure_ne_top` : connectivity is necessary.
-/

namespace CayleyHamiltonian

open SimpleGraph

section Sharpness

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- A Cayley graph whose connection set does not generate the group is not hamiltonian:
connectivity is a genuinely necessary hypothesis. -/
theorem not_isHamiltonian_of_closure_ne_top (h : Subgroup.closure S ≠ ⊤) :
    ¬ (cayleyGraph G S).IsHamiltonian := by
  intro hham
  exact h (cayleyGraph_connected_iff.1 hham.connected)

/-- For a group of order two no Cayley graph is hamiltonian (Mathlib's convention: a
hamiltonian cycle has length equal to the number of vertices, and a single edge is not a
cycle).  This is why the prime `2` has to be treated separately. -/
theorem not_isHamiltonian_of_card_eq_two (h : Fintype.card G = 2) :
    ¬ (cayleyGraph G S).IsHamiltonian :=
  SimpleGraph.not_isHamiltonian_of_card_eq_two h

end Sharpness

section PQRS

variable {p q r s : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime) (hs : s.Prime)

include hp hq hr hs

lemma three_le_pqrs : 3 ≤ p * q * r * s := by
  have h1 := hp.two_le
  have h2 := hq.two_le
  have h3 := hr.two_le
  have h4 := hs.two_le
  calc 3 ≤ 2 * 2 * 2 * 2 := by norm_num
    _ ≤ p * q * r * s := by
        exact Nat.mul_le_mul (Nat.mul_le_mul (Nat.mul_le_mul h1 h2) h3) h4

/-- A product of four distinct primes is squarefree. -/
lemma squarefree_pqrs (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s) (hqr : q ≠ r) (hqs : q ≠ s)
    (hrs : r ≠ s) : Squarefree (p * q * r * s) := by
  have cpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have cpr : Nat.Coprime p r := (Nat.coprime_primes hp hr).2 hpr
  have cps : Nat.Coprime p s := (Nat.coprime_primes hp hs).2 hps
  have cqr : Nat.Coprime q r := (Nat.coprime_primes hq hr).2 hqr
  have cqs : Nat.Coprime q s := (Nat.coprime_primes hq hs).2 hqs
  have crs : Nat.Coprime r s := (Nat.coprime_primes hr hs).2 hrs
  have h1 : Squarefree (p * q) := (Nat.squarefree_mul cpq).2 ⟨hp.squarefree, hq.squarefree⟩
  have h2 : Squarefree (p * q * r) :=
    (Nat.squarefree_mul (Nat.Coprime.mul_left cpr cqr)).2 ⟨h1, hr.squarefree⟩
  exact (Nat.squarefree_mul
    (Nat.Coprime.mul_left (Nat.Coprime.mul_left cps cqs) crs)).2 ⟨h2, hs.squarefree⟩

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- **The cyclic-generator case of the `pqrs` theorem.**  If a group of order `pqrs` has a
connection set containing an element of order `pqrs`, its Cayley graph is hamiltonian. -/
theorem pqrs_isHamiltonian_of_orderOf_eq_card (hcard : Fintype.card G = p * q * r * s)
    {a : G} (ha : a ∈ S) (hord : orderOf a = p * q * r * s) :
    (cayleyGraph G S).IsHamiltonian :=
  isHamiltonian_of_orderOf_eq_card ha (by rw [hord, hcard])
    (by rw [hcard]; exact three_le_pqrs hp hq hr hs)

omit [DecidableEq G] in
/-- Cauchy's theorem in the `pqrs` setting: elements of each of the four prime orders exist. -/
theorem exists_orderOf_eq_of_prime_dvd_pqrs (hcard : Fintype.card G = p * q * r * s) :
    (∃ a : G, orderOf a = p) ∧ (∃ a : G, orderOf a = q) ∧ (∃ a : G, orderOf a = r) ∧
      ∃ a : G, orderOf a = s := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  haveI : Fact r.Prime := ⟨hr⟩
  haveI : Fact s.Prime := ⟨hs⟩
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact exists_prime_orderOf_dvd_card p (by rw [hcard]; exact ⟨q * r * s, by ring⟩)
  · exact exists_prime_orderOf_dvd_card q (by rw [hcard]; exact ⟨p * r * s, by ring⟩)
  · exact exists_prime_orderOf_dvd_card r (by rw [hcard]; exact ⟨p * q * s, by ring⟩)
  · exact exists_prime_orderOf_dvd_card s (by rw [hcard]; exact ⟨p * q * r, by ring⟩)

end PQRS

section Abelian

variable {p q r s : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime) (hs : s.Prime)
  (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s) (hqr : q ≠ r) (hqs : q ≠ s) (hrs : r ≠ s)

include hp hq hr hs hpq hpr hps hqr hqs hrs

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

omit [DecidableEq G] in
/-- An abelian group of order `pqrs` (four distinct primes) is cyclic, because `pqrs` is
squarefree. -/
theorem pqrs_abelian_isCyclic (hcard : Fintype.card G = p * q * r * s) : IsCyclic G := by
  have hsq : Squarefree (Nat.card G) := by
    rw [Nat.card_eq_fintype_card, hcard]
    exact squarefree_pqrs hp hq hr hs hpq hpr hps hqr hqs hrs
  haveI : IsZGroup G := IsZGroup.of_squarefree hsq
  haveI : IsCyclic (Abelianization G) := IsZGroup.isCyclic_abelianization
  exact isCyclic_of_surjective (Abelianization.equivOfComm (H := G)).symm.toMonoidHom
    (Abelianization.equivOfComm (H := G)).symm.surjective

/-- **The abelian case of the `pqrs` theorem.**  An abelian group of order `pqrs` has an
element `a` generating the whole group, and *every* Cayley graph whose connection set
contains `a` is hamiltonian.  (In particular such a Cayley graph is connected.) -/
theorem pqrs_abelian_exists_hamiltonian_cayley (hcard : Fintype.card G = p * q * r * s) :
    ∃ a : G, Subgroup.closure ({a} : Set G) = ⊤ ∧
      ∀ S : Set G, a ∈ S → (cayleyGraph G S).IsHamiltonian := by
  haveI : IsCyclic G := pqrs_abelian_isCyclic hp hq hr hs hpq hpr hps hqr hqs hrs hcard
  obtain ⟨a, hgen⟩ := IsCyclic.exists_generator (α := G)
  have h3 : 3 ≤ Fintype.card G := by
    rw [hcard]; exact three_le_pqrs hp hq hr hs
  refine ⟨a, ?_, fun S haS => isHamiltonian_of_generator haS hgen h3⟩
  ext x
  simp only [Subgroup.mem_top, iff_true]
  rw [Subgroup.mem_closure_singleton]
  obtain ⟨n, hn⟩ := hgen x
  exact ⟨n, hn⟩

/-- **The two-generator abelian case of the `pqrs` theorem.**  If an abelian group of order
`pqrs` has a connection set containing two elements `a, b` of nontrivial orders whose product
is the order of the group, then the Cayley graph is hamiltonian — *no* parity, coprimality or
generator hypothesis is needed.  Coprimality comes for free from squarefreeness of `pqrs`, and
the cycle is the parity-free zigzag on the torus `C_{|a|} □ C_{|b|}`. -/
theorem pqrs_abelian_pair_isHamiltonian {S : Set G} (hcard : Fintype.card G = p * q * r * s)
    {a b : G} (ha : a ∈ S) (hb : b ∈ S) (hoa : 2 ≤ orderOf a) (hob : 2 ≤ orderOf b)
    (hprod : orderOf a * orderOf b = p * q * r * s) :
    (cayleyGraph G S).IsHamiltonian := by
  have hsq : Squarefree (orderOf a * orderOf b) := by
    rw [hprod]
    exact squarefree_pqrs hp hq hr hs hpq hpr hps hqr hqs hrs
  have hcop : Nat.Coprime (orderOf a) (orderOf b) := (Nat.squarefree_mul_iff.1 hsq).1
  exact isHamiltonian_of_coprime_pair (Commute.all a b) ha hb hoa hob rfl rfl hcop
    (by rw [hcard, hprod])

end Abelian

section Dihedral

open DihedralGroup

/-- **The dihedral case of the `pqrs` theorem.**  For distinct odd primes `q, r, s`, the
dihedral group of order `2qrs = pqrs` (with `p = 2`) has a hamiltonian Cayley graph for every
connection set containing the standard rotation and reflection. -/
theorem pqrs_dihedral_isHamiltonian {q r s : ℕ} (hq : q.Prime) (hr : r.Prime) (hs : s.Prime)
    {S : Set (DihedralGroup (q * r * s))}
    (hrot : DihedralGroup.r 1 ∈ S) (hrefl : DihedralGroup.sr 0 ∈ S) :
    haveI : NeZero (q * r * s) :=
      ⟨Nat.mul_ne_zero (Nat.mul_ne_zero hq.pos.ne' hr.pos.ne') hs.pos.ne'⟩
    Fintype.card (DihedralGroup (q * r * s)) = 2 * q * r * s ∧
      (cayleyGraph (DihedralGroup (q * r * s)) S).IsHamiltonian := by
  have hq2 := hq.two_le
  have hr2 := hr.two_le
  have hs2 := hs.two_le
  haveI : NeZero (q * r * s) :=
    ⟨Nat.mul_ne_zero (Nat.mul_ne_zero hq.pos.ne' hr.pos.ne') hs.pos.ne'⟩
  have hn : 2 ≤ q * r * s := by
    calc 2 ≤ 2 * 2 * 2 := by norm_num
      _ ≤ q * r * s := Nat.mul_le_mul (Nat.mul_le_mul hq2 hr2) hs2
  refine ⟨?_, dihedral_isHamiltonian hn hrot hrefl⟩
  rw [DihedralGroup.card]
  ring

end Dihedral

section ConcreteWitness

/-- A concrete abelian group of order `210 = 2 · 3 · 5 · 7`. -/
abbrev G210 : Type := Multiplicative (ZMod 105) × Multiplicative (ZMod 2)

/-- The two-element connection set `{a, b}` of `G210`, where `a` has order `105` and `b` has
order `2`. -/
def S210 : Set G210 := {(Multiplicative.ofAdd 1, 1), (1, Multiplicative.ofAdd 1)}

/-- **A `pqrs` example beyond the cyclic-generator criterion.**  On the abelian group of order
`210 = 2 · 3 · 5 · 7` the two-element connection set `S210` yields a hamiltonian Cayley graph
even though *neither* of its two elements generates the group; hamiltonicity comes from the
boustrophedon cycle on the `105 × 2` torus. -/
theorem cayley_G210_isHamiltonian :
    Fintype.card G210 = 2 * 3 * 5 * 7 ∧
      (cayleyGraph G210 S210).IsHamiltonian ∧
      ∀ g ∈ S210, Subgroup.zpowers g ≠ ⊤ := by
  have horda : orderOf ((Multiplicative.ofAdd 1, 1) : G210) = 105 := by
    rw [Prod.orderOf_mk]
    simp [orderOf_ofAdd_eq_addOrderOf]
  have hordb : orderOf ((1, Multiplicative.ofAdd 1) : G210) = 2 := by
    rw [Prod.orderOf_mk]
    simp [orderOf_ofAdd_eq_addOrderOf]
  have hcard : Fintype.card G210 = 105 * 2 := by simp
  have hnotgen : ∀ g : G210, orderOf g = 105 ∨ orderOf g = 2 → Subgroup.zpowers g ≠ ⊤ := by
    intro g hg hcon
    have h1 : Nat.card (Subgroup.zpowers g) = orderOf g := Nat.card_zpowers g
    have h2 : Nat.card (⊤ : Subgroup G210) = Nat.card G210 :=
      Nat.card_congr (Subgroup.topEquiv).toEquiv
    rw [hcon, h2] at h1
    rcases hg with hg | hg <;> rw [hg] at h1 <;> simp [Nat.card_eq_fintype_card] at h1
  refine ⟨by simp, ?_, ?_⟩
  · exact isHamiltonian_of_abelian_pair_coprime
      (a := (Multiplicative.ofAdd 1, 1)) (b := (1, Multiplicative.ofAdd 1))
      (by simp [S210]) (by simp [S210]) (by norm_num) (by norm_num) (by norm_num)
      horda hordb (by decide) hcard
  · intro g hgS
    rcases hgS with h | h
    · exact hnotgen g (Or.inl (by rw [h, horda]))
    · exact hnotgen g (Or.inr (by rw [h, hordb]))

end ConcreteWitness

end CayleyHamiltonian