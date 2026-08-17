import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# All two-generator abelian Cayley graphs are hamiltonian

Let `G` be an abelian group which is the internal direct product of `⟨a⟩` (order `m ≥ 2`) and
`⟨b⟩` (order `k ≥ 2`), and let the connection set contain `a` and `b`.  The Cayley graph is
then the Cartesian product `C_m □ C_k` of two cycles, and we prove that it is *always*
hamiltonian — with no parity restriction.

The construction generalizes the boustrophedon: each of the `k` cosets `⟨a⟩bʲ` is traversed
completely, in direction `d j ∈ {+1, -1}`, *using the wrap-around of the cycle `C_m`*.  A
traversal in direction `d` shifts the entry column of the next coset by `-d`, so after all `k`
cosets the total shift is `-∑_{j<k} d j`, and the cycle closes exactly when
`m ∣ ∑_{j<k} d j`.

* If `k` is even, take `k/2` cosets in each direction: the sum is `0`.
* If `k` is odd, the sum is odd, so we need `m` odd as well; taking `(k+m)/2` cosets in the
  positive direction the sum is `m`.  This requires `m ≤ k`, which can always be arranged by
  exchanging the roles of `a` and `b`.

Main results:

* `CayleyHamiltonian.isHamiltonian_of_directions` : the criterion with an explicit direction
  sequence.
* `CayleyHamiltonian.isHamiltonian_of_abelian_directProduct` : the parity-free statement.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- Partial sums of the direction sequence, negated: `dirShift d j` is the entry column of the
`j`-th coset. -/
def dirShift (d : ℕ → ℤ) (j : ℕ) : ℤ := -∑ l ∈ Finset.range j, d l

@[simp] lemma dirShift_zero (d : ℕ → ℤ) : dirShift d 0 = 0 := by simp [dirShift]

lemma dirShift_succ (d : ℕ → ℤ) (j : ℕ) : dirShift d (j + 1) = dirShift d j - d j := by
  simp [dirShift, Finset.sum_range_succ]
  ring

/-- The wrap-around zigzag enumeration of `⟨a⟩ × ⟨b⟩` determined by a direction sequence. -/
def zigzagEnum (a b : G) (m k : ℕ) (d : ℕ → ℤ) (i : ℕ) : G :=
  a ^ (dirShift d ((i / m) % k) + d ((i / m) % k) * ((i % m : ℕ) : ℤ)) * b ^ ((i / m) % k)

omit [Fintype G] [DecidableEq G] in
private lemma zigzagEnum_val (a b : G) (m k : ℕ) (d : ℕ → ℤ) (i : ℕ) :
    zigzagEnum a b m k d i
      = a ^ (dirShift d ((i / m) % k) + d ((i / m) % k) * ((i % m : ℕ) : ℤ))
          * b ^ ((i / m) % k) := rfl

private lemma div_mod_succ_lt {m i : ℕ} (hm : 0 < m) (h : i % m + 1 < m) :
    (i + 1) % m = i % m + 1 ∧ (i + 1) / m = i / m := by
  have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
  have hrw : i + 1 = m * (i / m) + (i % m + 1) := by omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt h]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_eq_of_lt h, Nat.add_zero]

private lemma div_mod_succ_eq {m i : ℕ} (hm : 0 < m) (h : i % m + 1 = m) :
    (i + 1) % m = 0 ∧ (i + 1) / m = i / m + 1 := by
  have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
  have hrw : i + 1 = m * (i / m) + m := by omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_self]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_self hm]

/-- **Direction-sequence criterion.**  If the total signed number of coset traversals is
divisible by `m`, the wrap-around zigzag closes into a hamiltonian cycle. -/
theorem isHamiltonian_of_directions {a b : G} {m k : ℕ} {d : ℕ → ℤ} (hab : Commute a b)
    (ha : a ∈ S) (hb : b ∈ S)
    (hm : 2 ≤ m) (hk : 2 ≤ k)
    (horda : orderOf a = m) (hordb : orderOf b = k)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = m * k)
    (hd : ∀ l, d l = 1 ∨ d l = -1)
    (hsum : (m : ℤ) ∣ ∑ l ∈ Finset.range k, d l) :
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
  have ham : a ^ (m : ℤ) = 1 := by
    rw [zpow_natCast, ← horda, pow_orderOf_eq_one]
  have hbk : b ^ k = 1 := by rw [← hordb, pow_orderOf_eq_one]
  have hshift : ∀ (z : ℤ) (t : ℤ), a ^ (z + (m : ℤ) * t) = a ^ z := by
    intro z t
    rw [zpow_add, zpow_mul, ham, one_zpow, mul_one]
  -- the pairing `(z, j) ↦ a^z bʲ` is injective modulo the obvious relations
  have hpair : ∀ (z z' : ℤ) (j j' : ℕ), j < k → j' < k →
      a ^ z * b ^ j = a ^ z' * b ^ j' → (m : ℤ) ∣ (z - z') ∧ j = j' := by
    intro z z' j j' hj hj' heq
    have hcz : ∀ u v : ℤ, Commute (a ^ u) (b ^ v) := fun u v => (hab.zpow_left u).zpow_right v
    have hz : a ^ (z - z') = b ^ ((j' : ℤ) - (j : ℤ)) := by
      have h : a ^ z = a ^ z' * b ^ ((j' : ℤ) - (j : ℤ)) := by
        rw [zpow_sub, zpow_natCast, zpow_natCast, ← mul_assoc, ← heq, mul_assoc,
          mul_inv_cancel, mul_one]
      calc a ^ (z - z') = a ^ z * (a ^ z')⁻¹ := by rw [zpow_sub]
        _ = a ^ z' * b ^ ((j' : ℤ) - (j : ℤ)) * (a ^ z')⁻¹ := by rw [h]
        _ = b ^ ((j' : ℤ) - (j : ℤ)) * a ^ z' * (a ^ z')⁻¹ := by rw [(hcz z' _).eq]
        _ = b ^ ((j' : ℤ) - (j : ℤ)) := by rw [mul_assoc, mul_inv_cancel, mul_one]
    have h1 : a ^ (z - z') = 1 := hdisj _ _ hz
    have h2 : b ^ ((j' : ℤ) - (j : ℤ)) = 1 := by rw [← hz, h1]
    have hdx : (m : ℤ) ∣ (z - z') := by
      rw [← horda]
      exact orderOf_dvd_iff_zpow_eq_one.2 h1
    have hdj : (k : ℤ) ∣ ((j' : ℤ) - (j : ℤ)) := by
      rw [← hordb]
      exact orderOf_dvd_iff_zpow_eq_one.2 h2
    have hjj : (j' : ℤ) - (j : ℤ) = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdj (by rw [abs_lt]; omega)
    exact ⟨hdx, by omega⟩
  have hcard3 : 3 ≤ m * k := by nlinarith
  refine isHamiltonian_of_enum (n := m * k) hcard3 hcard (zigzagEnum a b m k d) ?_ ?_ ?_
  · -- consecutive vertices are adjacent
    intro i
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hjlt : (i / m) % k < k := Nat.mod_lt _ hk0
    set j := (i / m) % k with hjdef
    rcases lt_or_ge (i % m + 1) m with hcase | hcase
    · -- inside a coset: multiply by `a^{d j}`
      obtain ⟨hmod, hdiv⟩ := div_mod_succ_lt hm0 hcase
      rw [zigzagEnum_val, zigzagEnum_val, hmod, hdiv, ← hjdef]
      have hstep : a ^ (dirShift d j + d j * ((i % m : ℕ) : ℤ)) * b ^ j * a ^ (d j)
          = a ^ (dirShift d j + d j * ((i % m + 1 : ℕ) : ℤ)) * b ^ j := by
        have hsplit : a ^ (dirShift d j + d j * ((i % m + 1 : ℕ) : ℤ))
            = a ^ (dirShift d j + d j * ((i % m : ℕ) : ℤ)) * a ^ (d j) := by
          rw [← zpow_add]
          congr 1
          push_cast
          ring
        have hcb : Commute (b ^ j) (a ^ (d j)) := (hab.symm.pow_left j).zpow_right (d j)
        rw [hsplit]
        simp only [mul_assoc]
        rw [hcb.eq]
      rcases hd j with hdj | hdj
      · rw [← hstep, hdj, zpow_one]
        exact adj_mul_of_mem ha ha1
      · rw [← hstep, hdj]
        have : a ^ (-1 : ℤ) = a⁻¹ := by
          rw [zpow_neg, zpow_one]
        rw [this]
        exact adj_mul_inv_of_mem ha ha1
    · -- crossing to the next coset: multiply by `b`
      have hcase' : i % m + 1 = m := by omega
      obtain ⟨hmod, hdiv⟩ := div_mod_succ_eq hm0 hcase'
      have hnext : (i / m + 1) % k = if j + 1 < k then j + 1 else 0 := by
        have h1 : (i / m + 1) % k = (j + 1) % k := by
          rw [hjdef]
          conv_lhs => rw [Nat.add_mod, Nat.mod_eq_of_lt (show 1 < k by omega)]
        rw [h1]
        split_ifs with h
        · exact Nat.mod_eq_of_lt h
        · have hkk : j + 1 = k := by omega
          rw [hkk, Nat.mod_self]
      rw [zigzagEnum_val, zigzagEnum_val, hmod, hdiv, ← hjdef, hnext]
      have hexit : a ^ (dirShift d j + d j * ((i % m : ℕ) : ℤ)) * b ^ j * b
          = a ^ (dirShift d (j + 1)) * b ^ (j + 1) := by
        rw [mul_assoc, ← pow_succ]
        congr 1
        have hz : dirShift d j + d j * ((i % m : ℕ) : ℤ)
            = dirShift d (j + 1) + (m : ℤ) * d j := by
          rw [dirShift_succ]
          have : ((i % m : ℕ) : ℤ) = (m : ℤ) - 1 := by
            have : i % m = m - 1 := by omega
            rw [this]
            push_cast [Nat.cast_sub (by omega : 1 ≤ m)]
            ring
          rw [this]
          ring
        rw [hz, hshift]
      rcases lt_or_ge (j + 1) k with hwrap | hwrap
      · rw [if_pos hwrap]
        simp only [Nat.cast_zero, mul_zero, add_zero]
        rw [← hexit]
        simpa using adj_mul_of_mem (g := a ^ (dirShift d j + d j * ((i % m : ℕ) : ℤ)) * b ^ j)
          hb hb1
      · -- closing the cycle
        have hjk : j + 1 = k := by omega
        rw [if_neg (by omega : ¬ (j + 1 < k))]
        have hclose : a ^ (dirShift d j + d j * ((i % m : ℕ) : ℤ)) * b ^ j * b
            = a ^ (dirShift d 0 + d 0 * ((0 : ℕ) : ℤ)) * b ^ 0 := by
          rw [hexit, hjk, hbk]
          obtain ⟨t, ht⟩ := hsum
          have hdk : dirShift d k = -((m : ℤ) * t) := by rw [dirShift, ht]
          have hone : a ^ (dirShift d k) = 1 := by
            rw [hdk, zpow_neg, zpow_mul, ham, one_zpow, inv_one]
          simp [hone]
        rw [← hclose]
        exact adj_mul_of_mem hb hb1
  · -- injectivity on one period
    intro i i' hi hi' hEq
    have hdi : i / m < k := Nat.div_lt_of_lt_mul hi
    have hdi' : i' / m < k := Nat.div_lt_of_lt_mul hi'
    have hji : (i / m) % k = i / m := Nat.mod_eq_of_lt hdi
    have hji' : (i' / m) % k = i' / m := Nat.mod_eq_of_lt hdi'
    rw [zigzagEnum_val, zigzagEnum_val, hji, hji'] at hEq
    obtain ⟨hdvd, hjj⟩ := hpair _ _ _ _ hdi hdi' hEq
    rw [hjj] at hdvd
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hc' : i' % m < m := Nat.mod_lt _ hm0
    have hsub : (m : ℤ) ∣ (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by
      have hfac : (dirShift d (i' / m) + d (i' / m) * ((i % m : ℕ) : ℤ))
          - (dirShift d (i' / m) + d (i' / m) * ((i' % m : ℕ) : ℤ))
          = d (i' / m) * (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by ring
      rw [hfac] at hdvd
      rcases hd (i' / m) with hdj | hdj <;> rw [hdj] at hdvd
      · simpa using hdvd
      · have : (m : ℤ) ∣ -(((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by simpa using hdvd
        exact (dvd_neg.1 this)
    have hzero : ((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ) = 0 :=
      Int.eq_zero_of_abs_lt_dvd hsub (by rw [abs_lt]; omega)
    have h1 : i = m * (i' / m) + i % m := by
      rw [← hjj]; exact (Nat.div_add_mod i m).symm
    have h2 : i' = m * (i' / m) + i' % m := (Nat.div_add_mod i' m).symm
    omega
  · -- periodicity
    intro i
    have h1 : (i + m * k) % m = i % m := by rw [Nat.add_mul_mod_self_left]
    have h2 : (i + m * k) / m = i / m + k := by rw [Nat.add_mul_div_left _ _ hm0]
    rw [zigzagEnum_val, zigzagEnum_val, h1, h2, Nat.add_mod_right]

/-- The signed sum of the direction sequence `+1` (first `t` cosets) then `-1`. -/
private lemma sum_dirs (t k : ℕ) (h : t ≤ k) :
    ∑ l ∈ Finset.range k, (if l < t then (1 : ℤ) else -1) = 2 * (t : ℤ) - (k : ℤ) := by
  induction k with
  | zero =>
      simp at h
      simp [h]
  | succ k ih =>
      rw [Finset.sum_range_succ]
      rcases Nat.lt_or_ge k t with hlt | hge
      · have hkt : t = k + 1 := by omega
        subst hkt
        rw [if_pos (by omega)]
        rw [Finset.sum_congr rfl (fun l hl => if_pos (by simp at hl; omega))]
        simp
        ring
      · rw [if_neg (by omega), ih (by omega)]
        push_cast
        ring

/-- **Parity-free two-generator abelian criterion.**  If an abelian group is the internal
direct product of `⟨a⟩` and `⟨b⟩` with `a, b` in the connection set and both orders at least
`2`, then the Cayley graph (a torus grid graph) is hamiltonian. -/
theorem isHamiltonian_of_abelian_directProduct {a b : G} {m k : ℕ} (hab : Commute a b)
    (ha : a ∈ S) (hb : b ∈ S)
    (hm : 2 ≤ m) (hk : 2 ≤ k)
    (horda : orderOf a = m) (hordb : orderOf b = k)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = m * k) :
    (cayleyGraph G S).IsHamiltonian := by
  -- the symmetric form of the intersection hypothesis, used when exchanging `a` and `b`
  have hdisj' : ∀ z w : ℤ, b ^ z = a ^ w → b ^ z = 1 := by
    intro z w h
    rw [h]
    exact hdisj w z h.symm
  have hcard' : Fintype.card G = k * m := by rw [hcard, Nat.mul_comm]
  -- the criterion applied with `t` cosets traversed positively
  have main : ∀ (a b : G) (m k t : ℕ), Commute a b → a ∈ S → b ∈ S → 2 ≤ m → 2 ≤ k →
      orderOf a = m → orderOf b = k → (∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1) →
      Fintype.card G = m * k → t ≤ k → (m : ℤ) ∣ (2 * (t : ℤ) - (k : ℤ)) →
      (cayleyGraph G S).IsHamiltonian := by
    intro a b m k t hab ha hb hm hk horda hordb hdisj hcard ht hdvd
    refine isHamiltonian_of_directions (d := fun l => if l < t then (1 : ℤ) else -1)
      hab ha hb hm hk horda hordb hdisj hcard (fun l => by by_cases h : l < t <;> simp [h]) ?_
    rw [sum_dirs t k ht]
    exact hdvd
  rcases Nat.even_or_odd k with hkeven | hkodd
  · -- `k` even: half of the cosets in each direction
    obtain ⟨c, hc⟩ := hkeven
    refine main a b m k c hab ha hb hm hk horda hordb hdisj hcard (by omega) ?_
    have : 2 * (c : ℤ) - (k : ℤ) = 0 := by
      have : (k : ℤ) = 2 * (c : ℤ) := by exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) (by omega : k = 2 * c)
      omega
    rw [this]
    exact dvd_zero _
  · rcases Nat.even_or_odd m with hmeven | hmodd
    · -- `m` even, `k` odd: exchange the roles of `a` and `b`
      obtain ⟨c, hc⟩ := hmeven
      refine main b a k m c hab.symm hb ha hk hm hordb horda hdisj' hcard' (by omega) ?_
      have : 2 * (c : ℤ) - (m : ℤ) = 0 := by
        have : (m : ℤ) = 2 * (c : ℤ) := by
          exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) (by omega : m = 2 * c)
        omega
      rw [this]
      exact dvd_zero _
    · -- both odd: traverse `(k+m)/2` cosets positively, using the larger factor as the
      -- number of cosets
      rcases le_or_gt m k with hle | hgt
      · refine main a b m k ((k + m) / 2) hab ha hb hm hk horda hordb hdisj hcard (by omega) ?_
        have hpar : (k + m) % 2 = 0 := by
          rcases Nat.odd_iff.1 hkodd with hk1
          rcases Nat.odd_iff.1 hmodd with hm1
          omega
        have : 2 * (((k + m) / 2 : ℕ) : ℤ) - (k : ℤ) = (m : ℤ) := by
          have h2 : 2 * ((k + m) / 2) = k + m := by omega
          have := congrArg (Nat.cast : ℕ → ℤ) h2
          push_cast at this ⊢
          omega
        rw [this]
      · refine main b a k m ((m + k) / 2) hab.symm hb ha hk hm hordb horda hdisj' hcard'
          (by omega) ?_
        have hpar : (m + k) % 2 = 0 := by
          rcases Nat.odd_iff.1 hkodd with hk1
          rcases Nat.odd_iff.1 hmodd with hm1
          omega
        have : 2 * (((m + k) / 2 : ℕ) : ℤ) - (m : ℤ) = (k : ℤ) := by
          have h2 : 2 * ((m + k) / 2) = m + k := by omega
          have := congrArg (Nat.cast : ℕ → ℤ) h2
          push_cast at this ⊢
          omega
        rw [this]

/-- **Parity-free coprime form.**  In an abelian group, two connection-set elements of coprime
orders `m, k ≥ 2` with `m * k = |G|` always give a hamiltonian Cayley graph.  Neither element
needs to generate the group, and — unlike the boustrophedon version — no parity assumption is
required. -/
theorem isHamiltonian_of_coprime_pair {a b : G} {m k : ℕ} (hab : Commute a b)
    (ha : a ∈ S) (hb : b ∈ S)
    (hm : 2 ≤ m) (hk : 2 ≤ k)
    (horda : orderOf a = m) (hordb : orderOf b = k) (hcop : Nat.Coprime m k)
    (hcard : Fintype.card G = m * k) :
    (cayleyGraph G S).IsHamiltonian := by
  refine isHamiltonian_of_abelian_directProduct hab ha hb hm hk horda hordb ?_ hcard
  intro z w heq
  have h1 : (a ^ z) ^ m = 1 := by
    rw [← zpow_natCast (a ^ z) m, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← horda,
      pow_orderOf_eq_one, one_zpow]
  have h2 : (a ^ z) ^ k = 1 := by
    rw [heq, ← zpow_natCast (b ^ w) k, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← hordb,
      pow_orderOf_eq_one, one_zpow]
  have hd1 : orderOf (a ^ z) ∣ m := orderOf_dvd_of_pow_eq_one h1
  have hd2 : orderOf (a ^ z) ∣ k := orderOf_dvd_of_pow_eq_one h2
  have hone : orderOf (a ^ z) ∣ 1 := hcop ▸ Nat.dvd_gcd hd1 hd2
  exact orderOf_eq_one_iff.1 (Nat.dvd_one.1 hone)

end CayleyHamiltonian