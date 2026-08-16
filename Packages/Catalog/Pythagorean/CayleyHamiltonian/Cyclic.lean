import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# Hamiltonian cycles in Cayley graphs from a single generator

Using the enumeration criterion of `Pythagorean.CayleyHamiltonian.Enumeration`, we show that
a Cayley graph whose connection set contains an element generating the whole group is
hamiltonian, and deduce the (already nontrivial) case of groups of prime order: *every*
connected Cayley graph of a group of odd prime order is hamiltonian.

Main results:

* `CayleyHamiltonian.isHamiltonian_of_orderOf_eq_card`
* `CayleyHamiltonian.isHamiltonian_of_prime_card`
* `CayleyHamiltonian.IsHamiltonian.of_subset` : hamiltonicity is inherited by larger
  connection sets.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S T : Set G}

/-- **Cyclic generator criterion.**  If the connection set contains an element whose order is
the order of the group, then the Cayley graph is hamiltonian: the cycle
`1, a, a², …, a^{n-1}, 1` does the job. -/
theorem isHamiltonian_of_orderOf_eq_card {a : G} (ha : a ∈ S)
    (hord : orderOf a = Fintype.card G) (hcard : 3 ≤ Fintype.card G) :
    (cayleyGraph G S).IsHamiltonian := by
  have ha1 : a ≠ 1 := by
    intro h
    rw [h, orderOf_one] at hord
    omega
  refine isHamiltonian_of_enum (n := Fintype.card G) hcard rfl (fun i => a ^ i) ?_ ?_ ?_
  · intro i
    show (cayleyGraph G S).Adj (a ^ i) (a ^ (i + 1))
    rw [pow_succ]
    exact adj_mul_of_mem ha ha1
  · intro i j hi hj hij
    have hmod : i ≡ j [MOD orderOf a] := pow_eq_pow_iff_modEq.1 hij
    rw [hord] at hmod
    have := hmod
    unfold Nat.ModEq at this
    rwa [Nat.mod_eq_of_lt hi, Nat.mod_eq_of_lt hj] at this
  · intro i
    show a ^ (i + Fintype.card G) = a ^ i
    rw [pow_add, ← hord, pow_orderOf_eq_one, mul_one]

/-- Hamiltonicity of a Cayley graph is inherited when the connection set grows. -/
theorem IsHamiltonian.of_subset (hST : S ⊆ T) (h : (cayleyGraph G S).IsHamiltonian) :
    (cayleyGraph G T).IsHamiltonian :=
  h.mono (cayleyGraph_mono hST)

/-- In a cyclic group, the Cayley graph on any connection set containing a generator is
hamiltonian. -/
theorem isHamiltonian_of_generator {a : G} (ha : a ∈ S) (hgen : ∀ g : G, g ∈ Subgroup.zpowers a)
    (hcard : 3 ≤ Fintype.card G) :
    (cayleyGraph G S).IsHamiltonian := by
  refine isHamiltonian_of_orderOf_eq_card ha ?_ hcard
  have hz : (Subgroup.zpowers a) = (⊤ : Subgroup G) := by
    ext g
    simp [hgen g]
  have hord : orderOf a = Nat.card G := by
    rw [← Nat.card_zpowers, hz]
    exact Nat.card_congr (Subgroup.topEquiv).toEquiv
  rw [hord, Nat.card_eq_fintype_card]

/-- **Groups of prime order.**  For a group of odd prime order every connected Cayley graph is
hamiltonian.  (For `p = 2` the Cayley graph is a single edge, which by convention is not
hamiltonian, so the hypothesis `p ≠ 2` is necessary.) -/
theorem isHamiltonian_of_prime_card {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hcard : Fintype.card G = p) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian := by
  have hple : 3 ≤ p := by
    have := hp.two_le
    omega
  -- the connection set contains a nonidentity element, since it generates a nontrivial group
  have hex : ∃ a ∈ S, a ≠ 1 := by
    by_contra hcon
    push_neg at hcon
    have hSsub : S ⊆ ({1} : Set G) := fun x hx => by simp [hcon x hx]
    have : Subgroup.closure S ≤ ⊥ := by
      rw [Subgroup.closure_le]
      intro x hx
      simp [hcon x hx]
    rw [hconn] at this
    have hcardle : Fintype.card G ≤ 1 := by
      have htop : (⊤ : Subgroup G) = ⊥ := le_antisymm this bot_le
      have : Subsingleton G := by
        constructor
        intro x y
        have hx : x ∈ (⊥ : Subgroup G) := htop ▸ Subgroup.mem_top x
        have hy : y ∈ (⊥ : Subgroup G) := htop ▸ Subgroup.mem_top y
        rw [Subgroup.mem_bot] at hx hy
        rw [hx, hy]
      exact Fintype.card_le_one_iff_subsingleton.2 this
    omega
  obtain ⟨a, haS, ha1⟩ := hex
  have hdvd : orderOf a ∣ p := by
    rw [← hcard]
    exact orderOf_dvd_card
  have hord : orderOf a = p := by
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
    · exact absurd (orderOf_eq_one_iff.1 h) ha1
    · exact h
  exact isHamiltonian_of_orderOf_eq_card haS (by rw [hord, hcard]) (by omega)

end CayleyHamiltonian