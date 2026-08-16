import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# Hamiltonian cycles in dihedral Cayley graphs

The dihedral groups are the basic non-cyclic examples of groups of squarefree order
(e.g. `D_{qrs}` has order `2qrs = pqrs`), so they are a genuine test case for the
theorem *Cayley graphs of order pqrs are hamiltonian*.

We exhibit an explicit hamiltonian cycle in `Cay(D_n, {r 1, sr 0})`:
```
1, r 1, r 2, …, r (n-1), sr 1, sr 2, …, sr (n-1), sr 0, 1 .
```
The first half is traversed by right multiplication with the rotation `r 1`; the reflection
`sr 0` is used exactly twice, once to jump between the two cosets of the rotation subgroup
and once to close the cycle.

Main result: `CayleyHamiltonian.dihedral_isHamiltonian`.
-/

namespace CayleyHamiltonian

open SimpleGraph DihedralGroup

/-- The cyclic enumeration of `DihedralGroup n` used to build the hamiltonian cycle:
rotations first, then reflections. -/
def dihedralEnum (n : ℕ) (k : ℕ) : DihedralGroup n :=
  if k % (2 * n) < n then r ((k % (2 * n) : ℕ) : ZMod n)
  else sr ((k % (2 * n) - n + 1 : ℕ) : ZMod n)

variable {n : ℕ}

private lemma succ_mod_two_mul (hn : 2 ≤ n) (k : ℕ) :
    (k + 1) % (2 * n) = if k % (2 * n) + 1 < 2 * n then k % (2 * n) + 1 else 0 := by
  have hM : 0 < 2 * n := by omega
  have h1 : (k + 1) % (2 * n) = (k % (2 * n) + 1) % (2 * n) := by
    conv_lhs => rw [Nat.add_mod, Nat.mod_eq_of_lt (by omega : 1 < 2 * n)]
  rw [h1]
  split_ifs with h
  · exact Nat.mod_eq_of_lt h
  · have hlt : k % (2 * n) < 2 * n := Nat.mod_lt _ hM
    have : k % (2 * n) + 1 = 2 * n := by omega
    rw [this, Nat.mod_self]

/-- Consecutive elements of the enumeration differ by a generator. -/
lemma dihedralEnum_adj (hn : 2 ≤ n) {S : Set (DihedralGroup n)} (hr : r 1 ∈ S) (hs : sr 0 ∈ S) :
    ∀ k, (cayleyGraph (DihedralGroup n) S).Adj (dihedralEnum n k) (dihedralEnum n (k + 1)) := by
  have hM : 0 < 2 * n := by omega
  have hr1 : (r 1 : DihedralGroup n) ≠ 1 := by
    intro h
    rw [one_def] at h
    have : (1 : ZMod n) = 0 := by injection h
    have hone : ((1 : ℕ) : ZMod n) = ((0 : ℕ) : ZMod n) := by simpa using this
    have := (ZMod.natCast_eq_natCast_iff' 1 0 n).1 hone
    simp [Nat.mod_eq_of_lt (show 1 < n by omega)] at this
  have hs1 : (sr 0 : DihedralGroup n) ≠ 1 := by
    intro h
    rw [one_def] at h
    simp only [reduceCtorEq] at h
  intro k
  set m := k % (2 * n) with hm
  have hmlt : m < 2 * n := Nat.mod_lt _ hM
  have hsucc := succ_mod_two_mul hn k
  rw [← hm] at hsucc
  rcases lt_or_ge m (n - 1) with hcase | hcase
  · -- inside the rotation coset
    have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
    have h1 : dihedralEnum n k = r ((m : ℕ) : ZMod n) := by
      rw [dihedralEnum, ← hm, if_pos (by omega)]
    have h2 : dihedralEnum n (k + 1) = r (((m + 1 : ℕ) : ZMod n)) := by
      rw [dihedralEnum, hs2, if_pos (by omega)]
    rw [h1, h2]
    have hmul : (r ((m : ℕ) : ZMod n) : DihedralGroup n) * r 1 = r (((m + 1 : ℕ) : ZMod n)) := by
      rw [r_mul_r]
      push_cast
      ring_nf
    rw [← hmul]
    exact adj_mul_of_mem hr hr1
  rcases eq_or_lt_of_le (show n - 1 ≤ m from hcase) with hcase' | hcase'
  · -- jumping from the rotation coset to the reflection coset
    have hmn : m + 1 = n := by omega
    have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
    have h1 : dihedralEnum n k = r ((m : ℕ) : ZMod n) := by
      rw [dihedralEnum, ← hm, if_pos (by omega)]
    have h2 : dihedralEnum n (k + 1) = sr ((1 : ℕ) : ZMod n) := by
      rw [dihedralEnum, hs2, if_neg (by omega)]
      congr 2
      omega
    have hcast : ((m : ℕ) : ZMod n) = -1 := by
      have : ((m + 1 : ℕ) : ZMod n) = ((n : ℕ) : ZMod n) := by rw [hmn]
      rw [ZMod.natCast_self] at this
      push_cast at this
      linear_combination this
    rw [h1, h2]
    have hmul : (r ((m : ℕ) : ZMod n) : DihedralGroup n) * sr 0 = sr ((1 : ℕ) : ZMod n) := by
      rw [r_mul_sr, hcast]
      push_cast
      ring_nf
    rw [← hmul]
    exact adj_mul_of_mem hs hs1
  rcases lt_or_ge m (2 * n - 1) with hcase'' | hcase''
  · -- inside the reflection coset
    have hs2 : (k + 1) % (2 * n) = m + 1 := by rw [hsucc, if_pos (by omega)]
    have h1 : dihedralEnum n k = sr (((m - n + 1 : ℕ) : ZMod n)) := by
      rw [dihedralEnum, ← hm, if_neg (by omega)]
    have h2 : dihedralEnum n (k + 1) = sr (((m + 1 - n + 1 : ℕ) : ZMod n)) := by
      rw [dihedralEnum, hs2, if_neg (by omega)]
    rw [h1, h2]
    have hidx : m + 1 - n + 1 = (m - n + 1) + 1 := by omega
    have hmul : (sr (((m - n + 1 : ℕ) : ZMod n)) : DihedralGroup n) * r 1
        = sr (((m + 1 - n + 1 : ℕ) : ZMod n)) := by
      rw [sr_mul_r, hidx]
      push_cast
      ring_nf
    rw [← hmul]
    exact adj_mul_of_mem hr hr1
  · -- closing the cycle
    have hmeq : m = 2 * n - 1 := by omega
    have hs2 : (k + 1) % (2 * n) = 0 := by rw [hsucc, if_neg (by omega)]
    have h1 : dihedralEnum n k = sr 0 := by
      rw [dihedralEnum, ← hm, if_neg (by omega)]
      congr 1
      have hnn : m - n + 1 = n := by omega
      rw [hnn, ZMod.natCast_self]
    have h2 : dihedralEnum n (k + 1) = r 0 := by
      rw [dihedralEnum, hs2, if_pos (by omega)]
      norm_num
    rw [h1, h2]
    have hmul : (sr 0 : DihedralGroup n) * sr 0 = r 0 := by
      rw [sr_mul_sr]
      simp
    rw [← hmul]
    exact adj_mul_of_mem hs hs1

/-- The enumeration is injective on one period. -/
lemma dihedralEnum_inj (hn : 2 ≤ n) :
    ∀ i j, i < 2 * n → j < 2 * n → dihedralEnum n i = dihedralEnum n j → i = j := by
  intro i j hi hj hij
  rw [dihedralEnum, dihedralEnum, Nat.mod_eq_of_lt hi, Nat.mod_eq_of_lt hj] at hij
  have hcast : ∀ a b : ℕ, a < n → b < n → ((a : ZMod n) = (b : ZMod n)) → a = b := by
    intro a b ha hb hab
    have := (ZMod.natCast_eq_natCast_iff' a b n).1 hab
    rwa [Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] at this
  rcases lt_or_ge i n with h1 | h1 <;> rcases lt_or_ge j n with h2 | h2
  · rw [if_pos h1, if_pos h2] at hij
    have : (i : ZMod n) = (j : ZMod n) := by injection hij
    exact hcast _ _ h1 h2 this
  · rw [if_pos h1, if_neg (by omega)] at hij
    simp only [reduceCtorEq] at hij
  · rw [if_neg (by omega), if_pos h2] at hij
    simp only [reduceCtorEq] at hij
  · rw [if_neg (by omega), if_neg (by omega)] at hij
    have hz : ((i - n + 1 : ℕ) : ZMod n) = ((j - n + 1 : ℕ) : ZMod n) := by injection hij
    -- both indices lie in `[1, n]`, so we compare them after reducing `n` to `0`
    rcases eq_or_lt_of_le (show i - n + 1 ≤ n by omega) with hi' | hi' <;>
      rcases eq_or_lt_of_le (show j - n + 1 ≤ n by omega) with hj' | hj'
    · omega
    · rw [hi', ZMod.natCast_self] at hz
      have : ((j - n + 1 : ℕ) : ZMod n) = ((0 : ℕ) : ZMod n) := by
        simpa using hz.symm
      have := hcast _ _ hj' (by omega) this
      omega
    · rw [hj', ZMod.natCast_self] at hz
      have : ((i - n + 1 : ℕ) : ZMod n) = ((0 : ℕ) : ZMod n) := by
        simpa using hz
      have := hcast _ _ hi' (by omega) this
      omega
    · have := hcast _ _ hi' hj' hz
      omega

lemma dihedralEnum_periodic (i : ℕ) :
    dihedralEnum n (i + 2 * n) = dihedralEnum n i := by
  rw [dihedralEnum, dihedralEnum, Nat.add_mod_right]

/-- **Dihedral Cayley graphs are hamiltonian.**  For `n ≥ 2`, every Cayley graph of the
dihedral group of order `2n` whose connection set contains the rotation `r 1` and the
reflection `sr 0` contains a hamiltonian cycle. -/
theorem dihedral_isHamiltonian (hn : 2 ≤ n) {S : Set (DihedralGroup n)}
    (hr : r 1 ∈ S) (hs : sr 0 ∈ S) :
    haveI : NeZero n := ⟨by omega⟩
    (cayleyGraph (DihedralGroup n) S).IsHamiltonian := by
  haveI : NeZero n := ⟨by omega⟩
  have hcard : Fintype.card (DihedralGroup n) = 2 * n := DihedralGroup.card
  refine isHamiltonian_of_enum (n := 2 * n) (by omega) hcard (dihedralEnum n)
    (dihedralEnum_adj hn hr hs) (dihedralEnum_inj hn) (fun i => dihedralEnum_periodic i)

end CayleyHamiltonian