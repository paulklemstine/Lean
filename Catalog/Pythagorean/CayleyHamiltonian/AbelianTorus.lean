import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# Two-generator abelian Cayley graphs: the torus (boustrophedon) construction

If an abelian group `G` of order `m * k` is the internal direct product of `⟨a⟩` (of order `m`)
and `⟨b⟩` (of order `k`), then `Cay(G, {a, b})` is the Cartesian product of two cycles, i.e. a
torus grid graph.  When `k` is even, the classical *boustrophedon* ("ox-plough") cycle

```
1, a, a², …, a^{m-1}, a^{m-1}b, a^{m-2}b, …, b, b², ab², …
```

traverses each coset `⟨a⟩bʲ` alternately left-to-right and right-to-left, and closes up because
the number `k` of cosets is even.  This gives hamiltonicity in cases *not* covered by the
cyclic-generator criterion: neither `a` nor `b` needs to generate `G`.

Main result: `CayleyHamiltonian.isHamiltonian_of_abelian_pair`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G] {S : Set G}

/-- The boustrophedon enumeration of `⟨a⟩ × ⟨b⟩`: the `j`-th coset `⟨a⟩bʲ` is traversed
left-to-right for even `j` and right-to-left for odd `j`. -/
def torusEnum (a b : G) (m k : ℕ) (i : ℕ) : G :=
  a ^ (if ((i / m) % k) % 2 = 0 then i % m else m - 1 - i % m) * b ^ ((i / m) % k)

omit [Fintype G] [DecidableEq G] in
private lemma torusEnum_val (a b : G) (m k i : ℕ) :
    torusEnum a b m k i
      = a ^ (if ((i / m) % k) % 2 = 0 then i % m else m - 1 - i % m) * b ^ ((i / m) % k) := rfl

omit [Fintype G] [DecidableEq G] in
private lemma mul_right_swap' (x y z : G) : x * y * z = x * z * y := by
  rw [mul_assoc, mul_comm y z, ← mul_assoc]

private lemma div_mod_succ_of_lt {m i : ℕ} (hm : 0 < m) (h : i % m + 1 < m) :
    (i + 1) % m = i % m + 1 ∧ (i + 1) / m = i / m := by
  have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
  have hrw : i + 1 = m * (i / m) + (i % m + 1) := by omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt h]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_eq_of_lt h, Nat.add_zero]

private lemma div_mod_succ_of_eq {m i : ℕ} (hm : 0 < m) (h : i % m + 1 = m) :
    (i + 1) % m = 0 ∧ (i + 1) / m = i / m + 1 := by
  have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
  have hrw : i + 1 = m * (i / m) + m := by omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_self]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_self hm]

/-- **Boustrophedon criterion.**  Let `G` be abelian of order `m * k` with `m, k ≥ 2` and `k`
even, let `a, b` belong to the connection set with `orderOf a = m`, `orderOf b = k`, and assume
that `⟨a⟩ ∩ ⟨b⟩` is trivial.  Then the Cayley graph is hamiltonian. -/
theorem isHamiltonian_of_abelian_pair {a b : G} {m k : ℕ} (ha : a ∈ S) (hb : b ∈ S)
    (hm : 2 ≤ m) (hk : 2 ≤ k) (hkeven : k % 2 = 0)
    (horda : orderOf a = m) (hordb : orderOf b = k)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = m * k) :
    (cayleyGraph G S).IsHamiltonian := by
  have hm0 : 0 < m := by omega
  have hk0 : 0 < k := by omega
  have ha1 : a ≠ 1 := by
    intro h
    rw [h, orderOf_one] at horda
    omega
  have hb1 : b ≠ 1 := by
    intro h
    rw [h, orderOf_one] at hordb
    omega
  have hbk : b ^ k = 1 := by rw [← hordb, pow_orderOf_eq_one]
  -- injectivity of the pairing `(x, j) ↦ aˣ bʲ`
  have hpair : ∀ x x' j j' : ℕ, x < m → x' < m → j < k → j' < k →
      a ^ x * b ^ j = a ^ x' * b ^ j' → x = x' ∧ j = j' := by
    intro x x' j j' hx hx' hj hj' heq
    have hz : a ^ ((x : ℤ) - (x' : ℤ)) = b ^ ((j' : ℤ) - (j : ℤ)) := by
      rw [zpow_sub, zpow_sub, zpow_natCast, zpow_natCast, zpow_natCast, zpow_natCast]
      refine mul_right_cancel (b := a ^ x' * b ^ j) ?_
      have hl : (a ^ x * (a ^ x')⁻¹) * (a ^ x' * b ^ j) = a ^ x * b ^ j := by
        rw [mul_assoc, inv_mul_cancel_left]
      have hrr : (b ^ j' * (b ^ j)⁻¹) * (a ^ x' * b ^ j) = a ^ x' * b ^ j' := by
        rw [mul_assoc, mul_comm (a ^ x') (b ^ j), inv_mul_cancel_left]
        exact mul_comm _ _
      rw [hl, hrr, heq]
    have h1 : a ^ ((x : ℤ) - (x' : ℤ)) = 1 := hdisj _ _ hz
    have h2 : b ^ ((j' : ℤ) - (j : ℤ)) = 1 := by rw [← hz, h1]
    have hdx : (m : ℤ) ∣ ((x : ℤ) - (x' : ℤ)) := by
      rw [← horda]
      exact orderOf_dvd_iff_zpow_eq_one.2 h1
    have hdj : (k : ℤ) ∣ ((j' : ℤ) - (j : ℤ)) := by
      rw [← hordb]
      exact orderOf_dvd_iff_zpow_eq_one.2 h2
    have hxx : (x : ℤ) - (x' : ℤ) = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdx (by rw [abs_lt]; omega)
    have hjj : (j' : ℤ) - (j : ℤ) = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdj (by rw [abs_lt]; omega)
    omega
  have hcard3 : 3 ≤ m * k := by nlinarith
  refine isHamiltonian_of_enum (n := m * k) hcard3 hcard (torusEnum a b m k) ?_ ?_ ?_
  · -- consecutive vertices are adjacent
    intro i
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hjlt : (i / m) % k < k := Nat.mod_lt _ hk0
    rcases lt_or_ge (i % m + 1) m with hcase | hcase
    · -- staying inside a coset of `⟨a⟩`
      obtain ⟨hmod, hdiv⟩ := div_mod_succ_of_lt hm0 hcase
      rw [torusEnum_val, torusEnum_val, hmod, hdiv]
      rcases Nat.even_or_odd ((i / m) % k) with hpar | hpar
      · -- even coset: move right, multiplying by `a`
        have hp : ((i / m) % k) % 2 = 0 := Nat.even_iff.1 hpar
        rw [if_pos hp, if_pos hp]
        have hstep : a ^ (i % m) * b ^ ((i / m) % k) * a
            = a ^ (i % m + 1) * b ^ ((i / m) % k) := by
          rw [mul_right_swap', ← pow_succ]
        rw [← hstep]
        exact adj_mul_of_mem ha ha1
      · -- odd coset: move left, multiplying by `a⁻¹`
        have hp : ¬ (((i / m) % k) % 2 = 0) := by
          have := Nat.odd_iff.1 hpar
          omega
        rw [if_neg hp, if_neg hp]
        have hsplit : a ^ (m - 1 - i % m) = a ^ (m - 1 - (i % m + 1)) * a := by
          rw [← pow_succ]
          congr 1
          omega
        have hstep : a ^ (m - 1 - i % m) * b ^ ((i / m) % k) * a⁻¹
            = a ^ (m - 1 - (i % m + 1)) * b ^ ((i / m) % k) := by
          rw [mul_right_swap', hsplit]
          group
        rw [← hstep]
        exact adj_mul_inv_of_mem ha ha1
    · -- moving to the next coset, multiplying by `b`
      have hcase' : i % m + 1 = m := by omega
      obtain ⟨hmod, hdiv⟩ := div_mod_succ_of_eq hm0 hcase'
      have hnext : (i / m + 1) % k = if (i / m) % k + 1 < k then (i / m) % k + 1 else 0 := by
        have h1 : (i / m + 1) % k = ((i / m) % k + 1) % k := by
          conv_lhs => rw [Nat.add_mod, Nat.mod_eq_of_lt (show 1 < k by omega)]
        rw [h1]
        split_ifs with h
        · exact Nat.mod_eq_of_lt h
        · have : (i / m) % k + 1 = k := by omega
          rw [this, Nat.mod_self]
      rw [torusEnum_val, torusEnum_val, hmod, hdiv, hnext]
      rcases lt_or_ge ((i / m) % k + 1) k with hwrap | hwrap
      · -- an ordinary change of coset
        rw [if_pos hwrap]
        rcases Nat.even_or_odd ((i / m) % k) with hpar | hpar
        · have hp : ((i / m) % k) % 2 = 0 := Nat.even_iff.1 hpar
          have hp' : ¬ (((i / m) % k + 1) % 2 = 0) := by omega
          rw [if_pos hp, if_neg hp']
          have hstep : a ^ (i % m) * b ^ ((i / m) % k) * b
              = a ^ (m - 1 - 0) * b ^ ((i / m) % k + 1) := by
            rw [mul_assoc, ← pow_succ]
            congr 2
            omega
          rw [← hstep]
          exact adj_mul_of_mem hb hb1
        · have hp : ¬ (((i / m) % k) % 2 = 0) := by
            have := Nat.odd_iff.1 hpar
            omega
          have hp' : ((i / m) % k + 1) % 2 = 0 := by
            have := Nat.odd_iff.1 hpar
            omega
          rw [if_neg hp, if_pos hp']
          have hstep : a ^ (m - 1 - i % m) * b ^ ((i / m) % k) * b
              = a ^ 0 * b ^ ((i / m) % k + 1) := by
            rw [mul_assoc, ← pow_succ]
            congr 2
            omega
          rw [← hstep]
          exact adj_mul_of_mem hb hb1
      · -- closing the cycle: the last coset is odd because `k` is even
        have hlast : (i / m) % k + 1 = k := by omega
        have hp : ¬ (((i / m) % k) % 2 = 0) := by omega
        rw [if_neg (by omega : ¬ ((i / m) % k + 1 < k)), if_neg hp,
          if_pos (by norm_num : (0 : ℕ) % 2 = 0)]
        have hzero : m - 1 - i % m = 0 := by omega
        have hstep : a ^ (m - 1 - i % m) * b ^ ((i / m) % k) * b = a ^ 0 * b ^ 0 := by
          rw [mul_assoc, ← pow_succ, hlast, hbk, hzero]
          simp
        rw [← hstep]
        exact adj_mul_of_mem hb hb1
  · -- injectivity on one period
    intro i i' hi hi' hEq
    have hdi : i / m < k := Nat.div_lt_of_lt_mul hi
    have hdi' : i' / m < k := Nat.div_lt_of_lt_mul hi'
    have hji : (i / m) % k = i / m := Nat.mod_eq_of_lt hdi
    have hji' : (i' / m) % k = i' / m := Nat.mod_eq_of_lt hdi'
    rw [torusEnum_val, torusEnum_val, hji, hji'] at hEq
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hc' : i' % m < m := Nat.mod_lt _ hm0
    have hbound : (if (i / m) % 2 = 0 then i % m else m - 1 - i % m) < m := by
      split_ifs <;> omega
    have hbound' : (if (i' / m) % 2 = 0 then i' % m else m - 1 - i' % m) < m := by
      split_ifs <;> omega
    obtain ⟨hX, hJ⟩ := hpair _ _ _ _ hbound hbound' hdi hdi' hEq
    rw [hJ] at hX
    have hcc : i % m = i' % m := by
      by_cases hpar : (i' / m) % 2 = 0
      · rw [if_pos hpar, if_pos hpar] at hX
        exact hX
      · rw [if_neg hpar, if_neg hpar] at hX
        omega
    have h1 : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
    have h2 : i' = m * (i' / m) + i' % m := (Nat.div_add_mod i' m).symm
    rw [h1, h2, hJ, hcc]
  · -- periodicity
    intro i
    have h1 : (i + m * k) % m = i % m := by
      rw [Nat.add_mul_mod_self_left]
    have h2 : (i + m * k) / m = i / m + k := by
      rw [Nat.add_mul_div_left _ _ hm0]
    rw [torusEnum_val, torusEnum_val, h1, h2, Nat.add_mod_right]

/-- **Boustrophedon criterion, coprime form.**  In an abelian group, two connection-set
elements of coprime orders `m` and `k` with `m * k = |G|` and `k` even give a hamiltonian
Cayley graph.  Neither element needs to generate the group. -/
theorem isHamiltonian_of_abelian_pair_coprime {a b : G} {m k : ℕ} (ha : a ∈ S) (hb : b ∈ S)
    (hm : 2 ≤ m) (hk : 2 ≤ k) (hkeven : k % 2 = 0)
    (horda : orderOf a = m) (hordb : orderOf b = k) (hcop : Nat.Coprime m k)
    (hcard : Fintype.card G = m * k) :
    (cayleyGraph G S).IsHamiltonian := by
  refine isHamiltonian_of_abelian_pair ha hb hm hk hkeven horda hordb ?_ hcard
  intro z w heq
  have h1 : (a ^ z) ^ m = 1 := by
    rw [← zpow_natCast (a ^ z) m, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← horda,
      pow_orderOf_eq_one, one_zpow]
  have h2 : (a ^ z) ^ k = 1 := by
    rw [heq, ← zpow_natCast (b ^ w) k, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← hordb,
      pow_orderOf_eq_one, one_zpow]
  have hd1 : orderOf (a ^ z) ∣ m := orderOf_dvd_of_pow_eq_one h1
  have hd2 : orderOf (a ^ z) ∣ k := orderOf_dvd_of_pow_eq_one h2
  have : orderOf (a ^ z) ∣ 1 := hcop ▸ Nat.dvd_gcd hd1 hd2
  exact orderOf_eq_one_iff.1 (Nat.dvd_one.1 this)

end CayleyHamiltonian