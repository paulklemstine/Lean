import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration
import Pythagorean.CayleyHamiltonian.AbelianTorusGeneral
import Pythagorean.CayleyHamiltonian.PQRS

/-!
# The twisted direction-sequence criterion: metacyclic Cayley graphs

Let `G` contain a cyclic normal subgroup `⟨a⟩` of order `m`, and an element `b` of order `k`
with `⟨a⟩ ∩ ⟨b⟩ = 1` and `|G| = m * k`, so that `G = ⟨a⟩ ⋊ ⟨b⟩` is metacyclic, the action being
`b a b⁻¹ = a ^ e`.

This file is the *twisted* analogue of `AbelianTorusGeneral.lean`.  The vertices `a ^ z * b ^ j`
are traversed coset by coset: inside the coset `⟨a⟩ b ^ j` we repeatedly multiply on the right
by `a ^ (d j)` with `d j = ±1`.  Because of the twist, right multiplication by `a ^ (d j)`
shifts the exponent `z` by `d j * e ^ j` rather than by `d j`, so a complete traversal of the
`j`-th coset moves the entry column by `- d j * e ^ j` and the closing condition becomes the
*geometric* congruence

`m ∣ ∑_{j < k} d j * e ^ j`.

Main results:

* `CayleyHamiltonian.conj_zpow_pow` : the commutation rule `bʲ aᶻ = a^(z eʲ) bʲ`.
* `CayleyHamiltonian.isHamiltonian_of_twisted_directions` : the criterion above.
* `CayleyHamiltonian.isHamiltonian_of_metacyclic_coprime_twist` : if `e - 1` is invertible
  modulo `m` the criterion is *automatically* satisfied by the constant sequence `d ≡ 1`,
  because `(e - 1) ∑_{j<k} e ^ j = e ^ k - 1 ≡ 0`.
* `CayleyHamiltonian.isHamiltonian_of_metacyclic_prime_normal` : consequently, if `m` is prime
  and `a`, `b` do **not** commute, the Cayley graph is hamiltonian.
* `CayleyHamiltonian.pq_isHamiltonian_of_normal_pair` : every Cayley graph of a group of order
  `pq` whose connection set contains a generator of a normal Sylow subgroup together with an
  element of the complementary prime order is hamiltonian — abelian or not.
* `CayleyHamiltonian.pqrs_metacyclic_isHamiltonian` : the corresponding statement in order
  `pqrs`.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

section Conjugation

variable {a b : G} {e : ℕ}

omit [Fintype G] [DecidableEq G] in
/-- The basic commutation rule: `b aᶻ = a^(e z) b`. -/
lemma conj_zpow_one (hconj : b * a * b⁻¹ = a ^ e) (z : ℤ) :
    b * a ^ z = a ^ ((e : ℤ) * z) * b := by
  have h : b * a ^ z * b⁻¹ = a ^ ((e : ℤ) * z) := by
    rw [← conj_zpow, hconj, ← zpow_natCast a e, ← zpow_mul]
  calc b * a ^ z = b * a ^ z * b⁻¹ * b := by group
    _ = a ^ ((e : ℤ) * z) * b := by rw [h]

omit [Fintype G] [DecidableEq G] in
/-- Iterating the commutation rule: `bʲ aᶻ = a^(z eʲ) bʲ`. -/
lemma conj_zpow_pow (hconj : b * a * b⁻¹ = a ^ e) (j : ℕ) (z : ℤ) :
    b ^ j * a ^ z = a ^ (z * (e : ℤ) ^ j) * b ^ j := by
  induction j generalizing z with
  | zero => simp
  | succ j ih =>
      calc b ^ (j + 1) * a ^ z = b ^ j * (b * a ^ z) := by rw [pow_succ, mul_assoc]
        _ = b ^ j * (a ^ ((e : ℤ) * z) * b) := by rw [conj_zpow_one hconj]
        _ = (b ^ j * a ^ ((e : ℤ) * z)) * b := by rw [mul_assoc]
        _ = a ^ (((e : ℤ) * z) * (e : ℤ) ^ j) * b ^ j * b := by rw [ih]
        _ = a ^ (z * (e : ℤ) ^ (j + 1)) * b ^ (j + 1) := by
              rw [mul_assoc, ← pow_succ]
              congr 2
              ring

omit [Fintype G] [DecidableEq G] in
/-- The twist exponent is coprime to the order of `a`: conjugation is an automorphism. -/
lemma coprime_of_conj (hconj : b * a * b⁻¹ = a ^ e) {m : ℕ} (hm : 2 ≤ m)
    (horda : orderOf a = m) : Nat.Coprime m e := by
  have ha1 : a ≠ 1 := by
    intro h
    rw [h, orderOf_one] at horda
    omega
  have he0 : e ≠ 0 := by
    intro h
    rw [h, pow_zero] at hconj
    exact ha1 (by simpa using (mul_inv_eq_one.1 hconj))
  have hord : orderOf (a ^ e) = m := by
    have hinj : Function.Injective (MulAut.conj b) := (MulAut.conj b).injective
    have h1 : orderOf ((MulAut.conj b) a) = orderOf a :=
      orderOf_injective (MulAut.conj b).toMonoidHom hinj a
    have h2 : (MulAut.conj b) a = a ^ e := by simpa [MulAut.conj] using hconj
    rw [← h2, h1, horda]
  have hgcd : m / Nat.gcd m e = m := by
    have h := orderOf_pow' a he0
    rw [horda, hord] at h
    exact h.symm
  rcases Nat.div_eq_self.1 hgcd with h | h
  · omega
  · exact h

end Conjugation

section Criterion

/-- The entry column of the `j`-th coset for the twisted traversal: the negated partial sum of
the *geometrically weighted* directions. -/
def twistShift (e : ℕ) (d : ℕ → ℤ) (j : ℕ) : ℤ := -∑ l ∈ Finset.range j, d l * (e : ℤ) ^ l

@[simp] lemma twistShift_zero (e : ℕ) (d : ℕ → ℤ) : twistShift e d 0 = 0 := by simp [twistShift]

lemma twistShift_succ (e : ℕ) (d : ℕ → ℤ) (j : ℕ) :
    twistShift e d (j + 1) = twistShift e d j - d j * (e : ℤ) ^ j := by
  simp [twistShift, Finset.sum_range_succ]
  ring

/-- The twisted zigzag enumeration of a metacyclic group. -/
def twistEnum (a b : G) (m k e : ℕ) (d : ℕ → ℤ) (i : ℕ) : G :=
  a ^ (twistShift e d ((i / m) % k)
        + d ((i / m) % k) * (e : ℤ) ^ ((i / m) % k) * ((i % m : ℕ) : ℤ))
    * b ^ ((i / m) % k)

omit [Fintype G] [DecidableEq G] in
private lemma twistEnum_val (a b : G) (m k e : ℕ) (d : ℕ → ℤ) (i : ℕ) :
    twistEnum a b m k e d i
      = a ^ (twistShift e d ((i / m) % k)
          + d ((i / m) % k) * (e : ℤ) ^ ((i / m) % k) * ((i % m : ℕ) : ℤ))
        * b ^ ((i / m) % k) := rfl

private lemma tw_div_mod_succ_lt {m i : ℕ} (hm : 0 < m) (h : i % m + 1 < m) :
    (i + 1) % m = i % m + 1 ∧ (i + 1) / m = i / m := by
  have hrw : i + 1 = m * (i / m) + (i % m + 1) := by
    have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
    omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt h]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_eq_of_lt h, Nat.add_zero]

private lemma tw_div_mod_succ_eq {m i : ℕ} (hm : 0 < m) (h : i % m + 1 = m) :
    (i + 1) % m = 0 ∧ (i + 1) / m = i / m + 1 := by
  have hrw : i + 1 = m * (i / m) + m := by
    have hi : i = m * (i / m) + i % m := (Nat.div_add_mod i m).symm
    omega
  refine ⟨?_, ?_⟩
  · rw [hrw, Nat.mul_add_mod, Nat.mod_self]
  · rw [hrw, Nat.mul_add_div hm, Nat.div_self hm]

/-- **Twisted direction-sequence criterion.**  In the metacyclic group `⟨a⟩ ⋊ ⟨b⟩` with
`b a b⁻¹ = a ^ e`, a direction sequence `d : ℕ → {±1}` whose geometrically weighted sum
`∑_{j<k} d j eʲ` vanishes modulo `m` produces a hamiltonian cycle in every Cayley graph whose
connection set contains `a` and `b`. -/
theorem isHamiltonian_of_twisted_directions {a b : G} {m k e : ℕ} {d : ℕ → ℤ}
    (ha : a ∈ S) (hb : b ∈ S) (hm : 2 ≤ m) (hk : 2 ≤ k)
    (horda : orderOf a = m) (hordb : orderOf b = k)
    (hconj : b * a * b⁻¹ = a ^ e)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = m * k)
    (hd : ∀ l, d l = 1 ∨ d l = -1)
    (hsum : (m : ℤ) ∣ ∑ l ∈ Finset.range k, d l * (e : ℤ) ^ l) :
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
  have ham : a ^ (m : ℤ) = 1 := by rw [zpow_natCast, ← horda, pow_orderOf_eq_one]
  have hbk : b ^ k = 1 := by rw [← hordb, pow_orderOf_eq_one]
  have hshift : ∀ (z : ℤ) (t : ℤ), a ^ (z + (m : ℤ) * t) = a ^ z := by
    intro z t
    rw [zpow_add, zpow_mul, ham, one_zpow, mul_one]
  have hcop : Nat.Coprime m e := coprime_of_conj hconj hm horda
  have hIC : IsCoprime (m : ℤ) (e : ℤ) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    simpa [Int.gcd_natCast_natCast] using hcop
  -- the coordinates `(z mod m, j)` of a vertex are well defined
  have hpair : ∀ (z z' : ℤ) (j j' : ℕ), j < k → j' < k →
      a ^ z * b ^ j = a ^ z' * b ^ j' → (m : ℤ) ∣ (z - z') ∧ j = j' := by
    intro z z' j j' hj hj' heq
    have h3 : (a ^ z')⁻¹ * a ^ z * b ^ j = b ^ j' := by
      rw [mul_assoc, heq, ← mul_assoc, inv_mul_cancel, one_mul]
    have h4 : (a ^ z')⁻¹ * a ^ z = b ^ (j' : ℤ) * (b ^ (j : ℤ))⁻¹ := by
      rw [zpow_natCast, zpow_natCast, ← h3]
      group
    have h5 : a ^ (z - z') = b ^ ((j' : ℤ) - (j : ℤ)) := by
      rw [zpow_sub, zpow_sub, ← h4]
      group
    have h1 : a ^ (z - z') = 1 := hdisj _ _ h5
    have h2 : b ^ ((j' : ℤ) - (j : ℤ)) = 1 := by rw [← h5, h1]
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
  refine isHamiltonian_of_enum (n := m * k) hcard3 hcard (twistEnum a b m k e d) ?_ ?_ ?_
  · -- consecutive vertices are adjacent
    intro i
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hjlt : (i / m) % k < k := Nat.mod_lt _ hk0
    set j := (i / m) % k with hjdef
    rcases lt_or_ge (i % m + 1) m with hcase | hcase
    · -- inside a coset: right multiplication by `a ^ (d j)`
      obtain ⟨hmod, hdiv⟩ := tw_div_mod_succ_lt hm0 hcase
      rw [twistEnum_val, twistEnum_val, hmod, hdiv, ← hjdef]
      set x : ℤ := twistShift e d j + d j * (e : ℤ) ^ j * ((i % m : ℕ) : ℤ) with hx
      have hstep : a ^ x * b ^ j * a ^ (d j)
          = a ^ (twistShift e d j + d j * (e : ℤ) ^ j * ((i % m + 1 : ℕ) : ℤ)) * b ^ j := by
        rw [mul_assoc, conj_zpow_pow hconj j (d j), ← mul_assoc, ← zpow_add]
        congr 2
        rw [hx]
        push_cast
        ring
      rcases hd j with hdj | hdj
      · rw [← hstep, hdj, zpow_one]
        exact adj_mul_of_mem ha ha1
      · rw [← hstep, hdj, show a ^ (-1 : ℤ) = a⁻¹ by rw [zpow_neg, zpow_one]]
        exact adj_mul_inv_of_mem ha ha1
    · -- crossing to the next coset: right multiplication by `b`
      have hcase' : i % m + 1 = m := by omega
      obtain ⟨hmod, hdiv⟩ := tw_div_mod_succ_eq hm0 hcase'
      have hnext : (i / m + 1) % k = if j + 1 < k then j + 1 else 0 := by
        have h1 : (i / m + 1) % k = (j + 1) % k := by
          rw [hjdef]
          conv_lhs => rw [Nat.add_mod, Nat.mod_eq_of_lt (show 1 < k by omega)]
        rw [h1]
        split_ifs with h
        · exact Nat.mod_eq_of_lt h
        · have hkk : j + 1 = k := by omega
          rw [hkk, Nat.mod_self]
      rw [twistEnum_val, twistEnum_val, hmod, hdiv, ← hjdef, hnext]
      have hexit : a ^ (twistShift e d j + d j * (e : ℤ) ^ j * ((i % m : ℕ) : ℤ)) * b ^ j * b
          = a ^ (twistShift e d (j + 1)) * b ^ (j + 1) := by
        rw [mul_assoc, ← pow_succ]
        congr 1
        have hz : twistShift e d j + d j * (e : ℤ) ^ j * ((i % m : ℕ) : ℤ)
            = twistShift e d (j + 1) + (m : ℤ) * (d j * (e : ℤ) ^ j) := by
          rw [twistShift_succ]
          have hcast : ((i % m : ℕ) : ℤ) = (m : ℤ) - 1 := by
            have : i % m = m - 1 := by omega
            rw [this]
            push_cast [Nat.cast_sub (by omega : 1 ≤ m)]
            ring
          rw [hcast]
          ring
        rw [hz, hshift]
      rcases lt_or_ge (j + 1) k with hwrap | hwrap
      · rw [if_pos hwrap]
        simp only [Nat.cast_zero, mul_zero, add_zero]
        rw [← hexit]
        simpa using adj_mul_of_mem
          (g := a ^ (twistShift e d j + d j * (e : ℤ) ^ j * ((i % m : ℕ) : ℤ)) * b ^ j) hb hb1
      · -- closing the cycle
        have hjk : j + 1 = k := by omega
        rw [if_neg (by omega : ¬ (j + 1 < k))]
        have hclose : a ^ (twistShift e d j + d j * (e : ℤ) ^ j * ((i % m : ℕ) : ℤ)) * b ^ j * b
            = a ^ (twistShift e d 0 + d 0 * (e : ℤ) ^ 0 * ((0 : ℕ) : ℤ)) * b ^ 0 := by
          rw [hexit, hjk, hbk]
          obtain ⟨t, ht⟩ := hsum
          have hdk : twistShift e d k = -((m : ℤ) * t) := by rw [twistShift, ht]
          have hone : a ^ (twistShift e d k) = 1 := by
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
    rw [twistEnum_val, twistEnum_val, hji, hji'] at hEq
    obtain ⟨hdvd, hjj⟩ := hpair _ _ _ _ hdi hdi' hEq
    rw [hjj] at hdvd
    have hc : i % m < m := Nat.mod_lt _ hm0
    have hc' : i' % m < m := Nat.mod_lt _ hm0
    have hsub : (m : ℤ) ∣ (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by
      have hfac : (twistShift e d (i' / m)
            + d (i' / m) * (e : ℤ) ^ (i' / m) * ((i % m : ℕ) : ℤ))
          - (twistShift e d (i' / m)
            + d (i' / m) * (e : ℤ) ^ (i' / m) * ((i' % m : ℕ) : ℤ))
          = (d (i' / m) * (e : ℤ) ^ (i' / m))
              * (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by ring
      rw [hfac] at hdvd
      have hcope : IsCoprime (m : ℤ) ((e : ℤ) ^ (i' / m)) := hIC.pow_right
      rcases hd (i' / m) with hdj | hdj <;> rw [hdj] at hdvd
      · rw [one_mul] at hdvd
        exact hcope.dvd_of_dvd_mul_left hdvd
      · have hdvd' : (m : ℤ) ∣ (e : ℤ) ^ (i' / m)
            * (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ)) := by
          have : (-1 : ℤ) * (e : ℤ) ^ (i' / m) * (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ))
              = -((e : ℤ) ^ (i' / m) * (((i % m : ℕ) : ℤ) - ((i' % m : ℕ) : ℤ))) := by ring
          rw [this] at hdvd
          exact (dvd_neg.1 hdvd)
        exact hcope.dvd_of_dvd_mul_left hdvd'
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
    rw [twistEnum_val, twistEnum_val, h1, h2, Nat.add_mod_right]

end Criterion

section Corollaries

variable {a b : G} {m k e : ℕ}

omit [Fintype G] [DecidableEq G] in
/-- The twist has multiplicative order dividing `k` modulo `m`: `eᵏ ≡ 1`. -/
lemma pow_twist_congr_one (hconj : b * a * b⁻¹ = a ^ e) (hordb : orderOf b = k)
    (horda : orderOf a = m) : (m : ℤ) ∣ (e : ℤ) ^ k - 1 := by
  have hbk : b ^ k = 1 := by rw [← hordb, pow_orderOf_eq_one]
  have h := conj_zpow_pow hconj k (1 : ℤ)
  simp only [hbk, one_mul, mul_one, zpow_one] at h
  have h1 : a ^ ((e : ℤ) ^ k - 1) = 1 := by
    rw [zpow_sub, zpow_one, ← h, mul_inv_cancel]
  rw [← horda]
  exact orderOf_dvd_iff_zpow_eq_one.2 h1

/-- **The twist is enough.**  If `e - 1` is invertible modulo `m`, the constant direction
sequence already closes: `(e - 1) ∑_{j<k} eʲ = eᵏ - 1 ≡ 0 (mod m)`.  Hence every Cayley graph
of the metacyclic group `⟨a⟩ ⋊ ⟨b⟩` whose connection set contains `a` and `b` is
hamiltonian. -/
theorem isHamiltonian_of_metacyclic_coprime_twist
    (ha : a ∈ S) (hb : b ∈ S) (hm : 2 ≤ m) (hk : 2 ≤ k)
    (horda : orderOf a = m) (hordb : orderOf b = k)
    (hconj : b * a * b⁻¹ = a ^ e)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = m * k)
    (htwist : IsCoprime (m : ℤ) ((e : ℤ) - 1)) :
    (cayleyGraph G S).IsHamiltonian := by
  refine isHamiltonian_of_twisted_directions (d := fun _ => 1) ha hb hm hk horda hordb hconj
    hdisj hcard (fun _ => Or.inl rfl) ?_
  have hgeom : ((e : ℤ) - 1) * ∑ l ∈ Finset.range k, (e : ℤ) ^ l = (e : ℤ) ^ k - 1 := by
    rw [mul_comm]
    exact geom_sum_mul (e : ℤ) k
  have hdvd : (m : ℤ) ∣ ((e : ℤ) - 1) * ∑ l ∈ Finset.range k, (e : ℤ) ^ l := by
    rw [hgeom]
    exact pow_twist_congr_one hconj hordb horda
  have := htwist.dvd_of_dvd_mul_left hdvd
  simpa using this

/-- **Nonabelian metacyclic groups with cyclic normal subgroup of prime order.**  If `a` has
prime order `q`, `⟨a⟩` is normalized by `b`, and `a` and `b` do *not* commute, then the Cayley
graph is hamiltonian.  No condition whatsoever on `k = |b|` is needed: the twist itself closes
the cycle. -/
theorem isHamiltonian_of_metacyclic_prime_normal {q : ℕ} (hq : q.Prime)
    (ha : a ∈ S) (hb : b ∈ S) (hk : 2 ≤ k)
    (horda : orderOf a = q) (hordb : orderOf b = k)
    (hconj : b * a * b⁻¹ = a ^ e)
    (hncomm : ¬ Commute a b)
    (hdisj : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  have hq2 := hq.two_le
  have hne : a ^ e ≠ a := by
    intro h
    apply hncomm
    have : b * a = a * b := by
      have h1 : b * a * b⁻¹ = a := by rw [hconj, h]
      calc b * a = b * a * b⁻¹ * b := by group
        _ = a * b := by rw [h1]
    exact this.symm
  have hnd : ¬ ((q : ℤ) ∣ (e : ℤ) - 1) := by
    intro hdvd
    apply hne
    have h1 : a ^ ((e : ℤ) - 1) = 1 := by
      rw [← horda] at hdvd
      exact orderOf_dvd_iff_zpow_eq_one.1 hdvd
    have h2 : a ^ ((e : ℤ) - 1 + 1) = a ^ ((e : ℤ) - 1) * a ^ (1 : ℤ) := zpow_add a _ _
    rw [h1, one_mul, zpow_one, sub_add_cancel] at h2
    rw [← zpow_natCast]
    exact h2
  have htwist : IsCoprime (q : ℤ) ((e : ℤ) - 1) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    have hl : ((Int.gcd (q : ℤ) ((e : ℤ) - 1) : ℕ) : ℤ) ∣ (q : ℤ) := Int.gcd_dvd_left _ _
    have hr : ((Int.gcd (q : ℤ) ((e : ℤ) - 1) : ℕ) : ℤ) ∣ (e : ℤ) - 1 := Int.gcd_dvd_right _ _
    have h1 : Int.gcd (q : ℤ) ((e : ℤ) - 1) ∣ q := Int.ofNat_dvd.mp hl
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq _ h1) with h2 | h2
    · exact h2
    · exact absurd (h2 ▸ hr) hnd
  exact isHamiltonian_of_metacyclic_coprime_twist ha hb hq2 hk horda hordb hconj hdisj hcard
    htwist

omit [Fintype G] [DecidableEq G] in
/-- Trivial intersection of two cyclic subgroups of coprime orders. -/
lemma zpow_eq_one_of_coprime_orders (horda : orderOf a = m) (hordb : orderOf b = k)
    (hcop : Nat.Coprime m k) : ∀ z w : ℤ, a ^ z = b ^ w → a ^ z = 1 := by
  intro z w heq
  have h1 : (a ^ z) ^ m = 1 := by
    rw [← zpow_natCast (a ^ z) m, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← horda,
      pow_orderOf_eq_one, one_zpow]
  have h2 : (a ^ z) ^ k = 1 := by
    rw [heq, ← zpow_natCast (b ^ w) k, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast, ← hordb,
      pow_orderOf_eq_one, one_zpow]
  have hone : orderOf (a ^ z) ∣ 1 :=
    hcop ▸ Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one h1) (orderOf_dvd_of_pow_eq_one h2)
  exact orderOf_eq_one_iff.1 (Nat.dvd_one.1 hone)

omit [Fintype G] [DecidableEq G] in
/-- A `ℤ`-power of `a` is a natural power of `a`, with exponent reduced modulo the order. -/
lemma exists_nat_pow_eq_zpow (horda : orderOf a = m) (hm : 0 < m) (z : ℤ) :
    ∃ e : ℕ, a ^ e = a ^ z := by
  refine ⟨(z % (m : ℤ)).toNat, ?_⟩
  have hnn : 0 ≤ z % (m : ℤ) := Int.emod_nonneg z (by exact_mod_cast hm.ne')
  have ham : a ^ (m : ℤ) = 1 := by rw [zpow_natCast, ← horda, pow_orderOf_eq_one]
  rw [← zpow_natCast, Int.toNat_of_nonneg hnn]
  conv_rhs => rw [← Int.mul_ediv_add_emod z (m : ℤ)]
  rw [zpow_add, zpow_mul, ham, one_zpow, one_mul]

/-- **Order `pq`, normal-subgroup case.**  Let `|G| = q * k` with `q` prime and `k ≥ 2` coprime
to `q`, let `a` be an element of order `q` whose cyclic group is normalized by `b`, and let `b`
have order `k`.  Then every Cayley graph whose connection set contains `a` and `b` is
hamiltonian — whether or not `G` is abelian.  (For `k` prime this is the order-`pq` theorem for
connection sets meeting both Sylow subgroups.) -/
theorem pq_isHamiltonian_of_normal_pair {q : ℕ} (hq : q.Prime)
    (ha : a ∈ S) (hb : b ∈ S) (hk : 2 ≤ k)
    (horda : orderOf a = q) (hordb : orderOf b = k)
    (hcop : Nat.Coprime q k)
    (hnorm : b * a * b⁻¹ ∈ Subgroup.zpowers a)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  have hq2 := hq.two_le
  have hdisj := zpow_eq_one_of_coprime_orders horda hordb hcop
  by_cases hcomm : Commute a b
  · exact isHamiltonian_of_coprime_pair hcomm ha hb hq2 hk horda hordb hcop hcard
  · obtain ⟨z, hz⟩ := hnorm
    obtain ⟨e, he⟩ := exists_nat_pow_eq_zpow horda (by omega) z
    have hz' : a ^ z = b * a * b⁻¹ := hz
    have hconj : b * a * b⁻¹ = a ^ e := by rw [he, hz']
    exact isHamiltonian_of_metacyclic_prime_normal hq ha hb hk horda hordb hconj hcomm hdisj
      hcard

end Corollaries

section PQRS

variable {p q r s : ℕ}

/-- **A metacyclic `pqrs` theorem.**  Let `|G| = p q r s` for four distinct primes, let `a` be
an element whose cyclic group is normalized by `b`, with `|a| * |b| = pqrs`, and assume the
twist `e` satisfies `gcd(e - 1, |a|) = 1` (automatic when `|a|` is prime and `a`, `b` do not
commute).  Then every Cayley graph containing `a` and `b` in its connection set is
hamiltonian. -/
theorem pqrs_metacyclic_isHamiltonian (hp : p.Prime) (hq : q.Prime) (hr : r.Prime)
    (hs : s.Prime) (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s) (hqr : q ≠ r) (hqs : q ≠ s)
    (hrs : r ≠ s) {a b : G} {e : ℕ} (ha : a ∈ S) (hb : b ∈ S)
    (hoa : 2 ≤ orderOf a) (hob : 2 ≤ orderOf b)
    (hcard : Fintype.card G = p * q * r * s)
    (hprod : orderOf a * orderOf b = p * q * r * s)
    (hconj : b * a * b⁻¹ = a ^ e)
    (htwist : IsCoprime ((orderOf a : ℕ) : ℤ) ((e : ℤ) - 1)) :
    (cayleyGraph G S).IsHamiltonian := by
  have hsq : Squarefree (orderOf a * orderOf b) := by
    rw [hprod]
    exact squarefree_pqrs hp hq hr hs hpq hpr hps hqr hqs hrs
  have hcop : Nat.Coprime (orderOf a) (orderOf b) := (Nat.squarefree_mul_iff.1 hsq).1
  exact isHamiltonian_of_metacyclic_coprime_twist ha hb hoa hob rfl rfl hconj
    (zpow_eq_one_of_coprime_orders rfl rfl hcop) (by rw [hcard, hprod]) htwist

end PQRS

section Witness

open DihedralGroup

/-- **Non-vacuity of the twisted criterion.**  The hypotheses of
`isHamiltonian_of_metacyclic_prime_normal` are satisfiable: in the dihedral group of order
`14 = 2 · 7` the rotation `r 1` has prime order `7`, is normalized by the reflection `sr 0`
with twist `e = 6`, and the two do *not* commute, so every Cayley graph containing both is
hamiltonian by the twisted criterion alone. -/
theorem dihedral7_twisted_isHamiltonian {S : Set (DihedralGroup 7)}
    (hrot : (r 1 : DihedralGroup 7) ∈ S) (hrefl : (sr 0 : DihedralGroup 7) ∈ S) :
    ¬ Commute (r 1 : DihedralGroup 7) (sr 0) ∧
      (cayleyGraph (DihedralGroup 7) S).IsHamiltonian := by
  have hncomm : ¬ Commute (r 1 : DihedralGroup 7) (sr 0) := by
    intro h
    have h' : (r 1 : DihedralGroup 7) * sr 0 = sr 0 * r 1 := h
    revert h'
    decide
  refine ⟨hncomm, ?_⟩
  have hconj : (sr 0 : DihedralGroup 7) * r 1 * (sr 0)⁻¹ = (r 1) ^ 6 := by decide
  have hcard : Fintype.card (DihedralGroup 7) = 7 * 2 := by
    rw [DihedralGroup.card]
  exact isHamiltonian_of_metacyclic_prime_normal (by norm_num) hrot hrefl le_rfl
    orderOf_r_one (orderOf_sr 0) hconj hncomm
    (zpow_eq_one_of_coprime_orders orderOf_r_one (orderOf_sr 0) (by norm_num)) hcard

end Witness

end CayleyHamiltonian