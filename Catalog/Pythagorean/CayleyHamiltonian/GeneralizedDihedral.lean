import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# An abstract dihedral-type hamiltonicity criterion

This file proves an abstract, presentation-free version of the dihedral construction: if a
group `G` of order `2n` contains an element `a` of order `n`, an involution `b` outside
`⟨a⟩` inverting `a`, and both `a` and `b` belong to the connection set `S`, then
`Cay(G, S)` is hamiltonian, via the explicit cycle

```
1, a, a², …, a^{n-1}, a^{n-1}b, a^{n-2}b, …, ab, b, 1 .
```

This covers, for instance, every dihedral group of order `2qrs = pqrs`, which is the basic
non-abelian family occurring in the theorem *Cayley graphs of order pqrs are hamiltonian*.

Main result: `CayleyHamiltonian.isHamiltonian_of_dihedral_pair`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- The cyclic enumeration `1, a, …, a^{n-1}, a^{n-1}b, …, ab, b` of a group of order `2n`
with a cyclic subgroup `⟨a⟩` of index two and a reflection `b`. -/
def dihedralPairEnum (a b : G) (n : ℕ) (k : ℕ) : G :=
  if k % (2 * n) < n then a ^ (k % (2 * n)) else a ^ (2 * n - 1 - k % (2 * n)) * b

private lemma succ_mod_two_mul' {n : ℕ} (hn : 2 ≤ n) (k : ℕ) :
    (k + 1) % (2 * n) = if k % (2 * n) + 1 < 2 * n then k % (2 * n) + 1 else 0 := by
  have hM : 0 < 2 * n := by omega
  have h1 : (k + 1) % (2 * n) = (k % (2 * n) + 1) % (2 * n) := by
    conv_lhs => rw [Nat.add_mod, Nat.mod_eq_of_lt (by omega : 1 < 2 * n)]
  rw [h1]
  split_ifs with h
  · exact Nat.mod_eq_of_lt h
  · have hlt : k % (2 * n) < 2 * n := Nat.mod_lt _ hM
    have hEq : k % (2 * n) + 1 = 2 * n := by omega
    rw [hEq, Nat.mod_self]

/-- **Abstract dihedral criterion.**  Let `G` be a group of order `2n` (`n ≥ 2`) containing
an element `a` of order `n` and an involution `b ∉ ⟨a⟩` with `b * a = a⁻¹ * b`.  If both
generators lie in the connection set, the Cayley graph is hamiltonian. -/
theorem isHamiltonian_of_dihedral_pair {a b : G} {n : ℕ} (hn : 2 ≤ n)
    (ha : a ∈ S) (hb : b ∈ S) (hord : orderOf a = n) (hcard : Fintype.card G = 2 * n)
    (hb2 : b * b = 1) (hba : b * a = a⁻¹ * b) (hbnot : b ∉ Subgroup.zpowers a) :
    (cayleyGraph G S).IsHamiltonian := by
  have hM : 0 < 2 * n := by omega
  have ha1 : a ≠ 1 := by
    intro h
    rw [h, orderOf_one] at hord
    omega
  have hb1 : b ≠ 1 := by
    intro h
    exact hbnot (by rw [h]; exact Subgroup.one_mem _)
  -- powers of `a` are distinct below `n`
  have hpow : ∀ i j : ℕ, i < n → j < n → a ^ i = a ^ j → i = j := by
    intro i j hi hj hij
    have hmod : i ≡ j [MOD orderOf a] := pow_eq_pow_iff_modEq.1 hij
    rw [hord] at hmod
    unfold Nat.ModEq at hmod
    rwa [Nat.mod_eq_of_lt hi, Nat.mod_eq_of_lt hj] at hmod
  -- the key commutation rule, in the form needed to walk down the second coset
  have hstep : ∀ s : ℕ, 1 ≤ s → a ^ s * b * a = a ^ (s - 1) * b := by
    intro s hs
    have hsplit : a ^ s = a ^ (s - 1) * a := by
      conv_lhs => rw [show s = (s - 1) + 1 by omega]
      rw [pow_succ]
    calc a ^ s * b * a = a ^ s * (b * a) := by rw [mul_assoc]
      _ = a ^ s * (a⁻¹ * b) := by rw [hba]
      _ = (a ^ (s - 1) * a) * (a⁻¹ * b) := by rw [hsplit]
      _ = a ^ (s - 1) * b := by group
  refine isHamiltonian_of_enum (n := 2 * n) (by omega) hcard (dihedralPairEnum a b n) ?_ ?_ ?_
  · -- consecutive vertices are adjacent
    intro k
    set m := k % (2 * n) with hm
    have hmlt : m < 2 * n := Nat.mod_lt _ hM
    have hsucc := succ_mod_two_mul' hn k
    rw [← hm] at hsucc
    rcases lt_or_ge m (n - 1) with hcase | hcase
    · have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
      have h1 : dihedralPairEnum a b n k = a ^ m := by
        rw [dihedralPairEnum, ← hm, if_pos (by omega)]
      have h2 : dihedralPairEnum a b n (k + 1) = a ^ (m + 1) := by
        rw [dihedralPairEnum, hs2, if_pos (by omega)]
      rw [h1, h2, pow_succ]
      exact adj_mul_of_mem ha ha1
    rcases eq_or_lt_of_le (show n - 1 ≤ m from hcase) with hcase' | hcase'
    · -- crossing to the second coset
      have hmn : m + 1 = n := by omega
      have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
      have h1 : dihedralPairEnum a b n k = a ^ m := by
        rw [dihedralPairEnum, ← hm, if_pos (by omega)]
      have h2 : dihedralPairEnum a b n (k + 1) = a ^ m * b := by
        rw [dihedralPairEnum, hs2, if_neg (by omega)]
        congr 2
        omega
      rw [h1, h2]
      exact adj_mul_of_mem hb hb1
    rcases lt_or_ge m (2 * n - 1) with hcase'' | hcase''
    · -- walking back down the second coset
      have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
      have h1 : dihedralPairEnum a b n k = a ^ (2 * n - 1 - m) * b := by
        rw [dihedralPairEnum, ← hm, if_neg (by omega)]
      have h2 : dihedralPairEnum a b n (k + 1) = a ^ (2 * n - 1 - m - 1) * b := by
        rw [dihedralPairEnum, hs2, if_neg (by omega),
          show 2 * n - 1 - (m + 1) = 2 * n - 1 - m - 1 from by omega]
      rw [h1, h2, ← hstep (2 * n - 1 - m) (by omega)]
      exact adj_mul_of_mem ha ha1
    · -- closing the cycle
      have hmeq : m = 2 * n - 1 := by omega
      have hs2 : (k + 1) % (2 * n) = 0 := by rw [hsucc, if_neg (by omega)]
      have h1 : dihedralPairEnum a b n k = b := by
        rw [dihedralPairEnum, ← hm, if_neg (by omega), hmeq]
        simp
      have h2 : dihedralPairEnum a b n (k + 1) = 1 := by
        rw [dihedralPairEnum, hs2, if_pos (by omega)]
        simp
      rw [h1, h2, ← hb2]
      exact adj_mul_of_mem hb hb1
  · -- the enumeration is injective on one period
    intro i j hi hj hij
    rw [dihedralPairEnum, dihedralPairEnum, Nat.mod_eq_of_lt hi, Nat.mod_eq_of_lt hj] at hij
    have hmix : ∀ s t : ℕ, a ^ s ≠ a ^ t * b := by
      intro s t hcon
      refine hbnot ⟨-(t : ℤ) + (s : ℤ), ?_⟩
      show a ^ (-(t : ℤ) + (s : ℤ)) = b
      rw [zpow_add, zpow_neg, zpow_natCast, zpow_natCast, hcon]
      group
    rcases lt_or_ge i n with h1 | h1 <;> rcases lt_or_ge j n with h2 | h2
    · rw [if_pos h1, if_pos h2] at hij
      exact hpow _ _ h1 h2 hij
    · rw [if_pos h1, if_neg (by omega)] at hij
      exact absurd hij (hmix _ _)
    · rw [if_neg (by omega), if_pos h2] at hij
      exact absurd hij.symm (hmix _ _)
    · rw [if_neg (by omega), if_neg (by omega)] at hij
      have hcancel : a ^ (2 * n - 1 - i) = a ^ (2 * n - 1 - j) := by
        have := mul_right_cancel hij
        exact this
      have := hpow _ _ (by omega) (by omega) hcancel
      omega
  · -- periodicity
    intro i
    rw [dihedralPairEnum, dihedralPairEnum, Nat.add_mod_right]

end CayleyHamiltonian