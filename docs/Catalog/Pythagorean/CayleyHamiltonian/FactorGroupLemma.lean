import Pythagorean.CayleyHamiltonian.Basic
import Pythagorean.CayleyHamiltonian.Enumeration

/-!
# The factor group lemma

This file formalizes the central tool of the literature on hamiltonian cycles in Cayley graphs
(the "factor group lemma", used throughout *Cayley graphs of order pqrs are hamiltonian*), in a
form that avoids quotient groups entirely.

Let `s : ℕ → G` be a `k`-periodic sequence of nonidentity elements of `S ∪ S⁻¹` and let
`P i = s 0 * s 1 * ⋯ * s (i-1)` be its prefix products.  Put `z = P k` (the *voltage* of the
closed walk) and assume

* `z` has order `m` and `|G| = m * k`;
* the prefix products `P 0, …, P (k-1)` lie in pairwise distinct cosets of `⟨z⟩`, i.e. the walk
  projects to a hamiltonian cycle of the quotient.

Then `P` itself, run `m` times around, is a hamiltonian cycle of `Cay(G, S)`:
`P (k t + i) = zᵗ * P i`, so the walk sweeps out each coset of `⟨z⟩` exactly once.

Main results:

* `CayleyHamiltonian.prefixProd_mul_period` : `P (k t + i) = zᵗ * P i`.
* `CayleyHamiltonian.isHamiltonian_of_factorGroup` : the factor group lemma.
* `CayleyHamiltonian.isHamiltonian_of_same_coset_pair` : its first application — if the
  connection set contains two distinct elements of one and the same coset of a normal subgroup
  of prime order `q`, and one of them has order `k` with `|G| = q * k`, then the Cayley graph
  is hamiltonian.  This case is *not* covered by the (twisted) direction-sequence criteria,
  since the connection set may avoid the normal subgroup completely.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- The prefix products `P i = s 0 * s 1 * ⋯ * s (i-1)` of a sequence of group elements. -/
def prefixProd (s : ℕ → G) : ℕ → G
  | 0 => 1
  | (i + 1) => prefixProd s i * s i

omit [Fintype G] [DecidableEq G] in
@[simp] lemma prefixProd_zero (s : ℕ → G) : prefixProd s 0 = 1 := rfl

omit [Fintype G] [DecidableEq G] in
@[simp] lemma prefixProd_succ (s : ℕ → G) (i : ℕ) :
    prefixProd s (i + 1) = prefixProd s i * s i := rfl

omit [Group G] [Fintype G] [DecidableEq G] in
/-- A `k`-periodic sequence is invariant under shifting by any multiple of `k`. -/
lemma periodic_shift {s : ℕ → G} {k : ℕ} (hper : ∀ i, s (i + k) = s i) (t i : ℕ) :
    s (k * t + i) = s i := by
  induction t with
  | zero => simp
  | succ t ih =>
      have h : k * (t + 1) + i = (k * t + i) + k := by ring
      rw [h, hper, ih]

omit [Fintype G] [DecidableEq G] in
/-- Prefix products split at multiples of the period. -/
lemma prefixProd_period_add {s : ℕ → G} {k : ℕ} (hper : ∀ i, s (i + k) = s i) (t i : ℕ) :
    prefixProd s (k * t + i) = prefixProd s (k * t) * prefixProd s i := by
  induction i with
  | zero => simp
  | succ i ih =>
      have h : k * t + (i + 1) = (k * t + i) + 1 := by ring
      rw [h, prefixProd_succ, ih, periodic_shift hper t i, prefixProd_succ, mul_assoc]

omit [Fintype G] [DecidableEq G] in
/-- **The voltage rule.**  After `t` full turns the walk has been translated by the `t`-th power
of the voltage `z = P k`. -/
lemma prefixProd_mul_period {s : ℕ → G} {k : ℕ} (hper : ∀ i, s (i + k) = s i) (t i : ℕ) :
    prefixProd s (k * t + i) = (prefixProd s k) ^ t * prefixProd s i := by
  induction t generalizing i with
  | zero => simp
  | succ t ih =>
      have h : k * (t + 1) + i = k * t + (k + i) := by ring
      have hstep : prefixProd s (k + i) = prefixProd s k * prefixProd s i := by
        simpa using prefixProd_period_add hper 1 i
      rw [h, ih (k + i), hstep, pow_succ, mul_assoc]

/-- **Factor group lemma.**  A closed walk in the quotient which lifts to a walk whose voltage
generates a subgroup of the complementary order produces a hamiltonian cycle. -/
theorem isHamiltonian_of_factorGroup {s : ℕ → G} {m k : ℕ}
    (hk : 0 < k) (h3 : 3 ≤ m * k)
    (hmem : ∀ i, s i ∈ S ∨ (s i)⁻¹ ∈ S) (hne : ∀ i, s i ≠ 1)
    (hper : ∀ i, s (i + k) = s i)
    (hordz : orderOf (prefixProd s k) = m)
    (hdistinct : ∀ i i', i < k → i' < k →
      prefixProd s i' * (prefixProd s i)⁻¹ ∈ Subgroup.zpowers (prefixProd s k) → i = i')
    (hcard : Fintype.card G = m * k) :
    (cayleyGraph G S).IsHamiltonian := by
  set z : G := prefixProd s k with hz
  set P : ℕ → G := prefixProd s with hP
  have hm : 0 < m := by
    rcases Nat.eq_zero_or_pos m with h | h
    · exfalso; rw [h] at h3; omega
    · exact h
  have hzm : z ^ m = 1 := by rw [← hordz, pow_orderOf_eq_one]
  refine isHamiltonian_of_enum (n := m * k) h3 hcard P ?_ ?_ ?_
  · -- consecutive vertices differ by a generator
    intro i
    have hstep : P (i + 1) = P i * s i := rfl
    rw [hstep]
    rcases hmem i with hs | hs
    · exact adj_mul_of_mem hs (hne i)
    · have hinv : (s i)⁻¹ ≠ 1 := by
        intro h
        exact hne i (by simpa using congrArg (·⁻¹) h)
      have := adj_mul_inv_of_mem (g := P i) hs hinv
      simpa using this
  · -- injectivity on one period
    intro i i' hi hi' hEq
    have hik : i % k < k := Nat.mod_lt _ hk
    have hik' : i' % k < k := Nat.mod_lt _ hk
    have hdi : i / k < m := Nat.div_lt_of_lt_mul (by rwa [Nat.mul_comm] at hi)
    have hdi' : i' / k < m := Nat.div_lt_of_lt_mul (by rwa [Nat.mul_comm] at hi')
    have hsplit : ∀ j : ℕ, P j = z ^ (j / k) * P (j % k) := by
      intro j
      have h := prefixProd_mul_period (s := s) hper (j / k) (j % k)
      rw [← hP, ← hz] at h
      rw [← h, Nat.div_add_mod j k]
    rw [hsplit i, hsplit i'] at hEq
    -- first: the cosets of `⟨z⟩` agree, so the positions inside the period agree
    have hcos : P (i' % k) * (P (i % k))⁻¹ ∈ Subgroup.zpowers z := by
      refine ⟨((i / k : ℕ) : ℤ) - ((i' / k : ℕ) : ℤ), ?_⟩
      show z ^ (((i / k : ℕ) : ℤ) - ((i' / k : ℕ) : ℤ)) = P (i' % k) * (P (i % k))⁻¹
      have h1 : z ^ (i / k) * P (i % k) = z ^ (i' / k) * P (i' % k) := hEq
      have h2 : P (i' % k) * (P (i % k))⁻¹
          = (z ^ (i' / k))⁻¹ * (z ^ (i / k)) := by
        have h3' : (z ^ (i' / k))⁻¹ * (z ^ (i / k) * P (i % k)) = P (i' % k) := by
          rw [h1, ← mul_assoc, inv_mul_cancel, one_mul]
        rw [← h3']
        group
      rw [h2, zpow_sub, zpow_natCast, zpow_natCast]
      group
    have hii : i % k = i' % k := hdistinct _ _ hik hik' hcos
    -- second: the powers of `z` agree
    rw [hii] at hEq
    have hpow : z ^ (i / k) = z ^ (i' / k) := by
      have := mul_right_cancel hEq
      exact this
    obtain ⟨u, hu⟩ : ∃ u, i / k = u := ⟨_, rfl⟩
    obtain ⟨u', hu'⟩ : ∃ u', i' / k = u' := ⟨_, rfl⟩
    rw [hu] at hpow hdi
    rw [hu'] at hpow hdi'
    have hdd : u = u' := by
      have hone : z ^ ((u : ℤ) - (u' : ℤ)) = 1 := by
        rw [zpow_sub, zpow_natCast, zpow_natCast, hpow, mul_inv_cancel]
      have h1 : (m : ℤ) ∣ (u : ℤ) - (u' : ℤ) := by
        rw [← hordz]
        exact orderOf_dvd_iff_zpow_eq_one.2 hone
      have hzero : (u : ℤ) - (u' : ℤ) = 0 :=
        Int.eq_zero_of_abs_lt_dvd h1 (by rw [abs_lt]; omega)
      omega
    have h1 : i = k * (i / k) + i % k := (Nat.div_add_mod i k).symm
    have h2 : i' = k * (i' / k) + i' % k := (Nat.div_add_mod i' k).symm
    rw [hu, hdd, hii] at h1
    rw [hu'] at h2
    omega
  · -- periodicity
    intro i
    have h : i + m * k = k * m + i := by ring
    rw [h]
    have := prefixProd_mul_period (s := s) hper m i
    rw [← hP, ← hz] at this
    rw [this, hzm, one_mul]

/-- **Two connection-set elements in the same coset.**  Let `a` generate a normal subgroup of
prime order `q`, let `x` have order `k` with `|G| = q * k` and `q` coprime to `k`, and suppose
the connection set contains both `x` and `y = aᶜ x` for some `aᶜ ≠ 1`.  Then the Cayley graph is
hamiltonian: run once through the coset sequence using `y` first and `x` afterwards; the
voltage of the resulting closed walk is exactly `aᶜ`, which generates the normal subgroup.

Note that the connection set need not meet the normal subgroup at all, so this case is
inaccessible to the (twisted) direction-sequence criteria. -/
theorem isHamiltonian_of_same_coset_pair {a x y : G} {q k c : ℕ}
    (hq : q.Prime) (hx : x ∈ S) (hy : y ∈ S) (hk : 2 ≤ k)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hac : a ^ c ≠ 1) (hyx : y = a ^ c * x)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  have hq2 := hq.two_le
  classical
  -- the walk: `y` once, then `x` repeatedly
  set s : ℕ → G := fun i => if i % k = 0 then y else x with hs
  have hsper : ∀ i, s (i + k) = s i := by
    intro i
    simp only [hs, Nat.add_mod_right]
  have haq : a ^ q = 1 := by rw [← horda, pow_orderOf_eq_one]
  have hxk : x ^ k = 1 := by rw [← hordx, pow_orderOf_eq_one]
  have hacq : (a ^ c) ^ q = 1 := by rw [← pow_mul, mul_comm, pow_mul, haq, one_pow]
  have hx1 : x ≠ 1 := by
    intro h
    rw [h, orderOf_one] at hordx
    omega
  have hy1 : y ≠ 1 := by
    intro h
    have : a ^ c = x⁻¹ := by
      rw [hyx] at h
      exact eq_inv_of_mul_eq_one_left h
    -- `a ^ c` lies in `⟨a⟩ ∩ ⟨x⟩ = 1`
    have h2 : (a ^ c) ^ k = 1 := by
      rw [this, inv_pow, hxk, inv_one]
    have hone : orderOf (a ^ c) ∣ 1 :=
      hcop ▸ Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one hacq) (orderOf_dvd_of_pow_eq_one h2)
    exact hac (orderOf_eq_one_iff.1 (Nat.dvd_one.1 hone))
  have hmem : ∀ i, s i ∈ S ∨ (s i)⁻¹ ∈ S := by
    intro i
    simp only [hs]
    split_ifs
    · exact Or.inl hy
    · exact Or.inl hx
  have hne : ∀ i, s i ≠ 1 := by
    intro i
    simp only [hs]
    split_ifs
    · exact hy1
    · exact hx1
  -- the prefix products: `P 0 = 1`, `P (i+1) = y * x ^ i`
  have hpref : ∀ i, i ≤ k → prefixProd s i = if i = 0 then 1 else a ^ c * x ^ i := by
    intro i
    induction i with
    | zero => intro _; simp
    | succ i ih =>
        intro hik
        rw [prefixProd_succ, ih (by omega)]
        rcases Nat.eq_zero_or_pos i with hi0 | hi0
        · subst hi0
          simp only [hs, Nat.zero_mod]
          rw [hyx]
          simp
        · have hmod : i % k ≠ 0 := by
            rw [Nat.mod_eq_of_lt (by omega)]
            omega
          simp only [hs, if_neg hmod, if_neg (by omega : ¬ i = 0),
            if_neg (by omega : ¬ i + 1 = 0)]
          rw [mul_assoc, ← pow_succ]
  have hzval : prefixProd s k = a ^ c := by
    rw [hpref k le_rfl, if_neg (by omega), hxk, mul_one]
  have hacmem : a ^ c ∈ Subgroup.zpowers a := Subgroup.pow_mem _ (Subgroup.mem_zpowers a) c
  have hordac : orderOf (a ^ c) = q := by
    have hdvd : orderOf (a ^ c) ∣ q := orderOf_dvd_of_pow_eq_one hacq
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq _ hdvd) with h | h
    · exact absurd (orderOf_eq_one_iff.1 h) hac
    · exact h
  have hordz : orderOf (prefixProd s k) = q := by rw [hzval]; exact hordac
  -- distinctness of the cosets of `⟨a⟩ = ⟨a ^ c⟩` visited by the walk
  have hzpow : Subgroup.zpowers (prefixProd s k) = Subgroup.zpowers a := by
    rw [hzval]
    have hle : Subgroup.zpowers (a ^ c) ≤ Subgroup.zpowers a := Subgroup.zpowers_le.2 hacmem
    have hcard1 : Nat.card (Subgroup.zpowers (a ^ c)) = q := by rw [Nat.card_zpowers, hordac]
    have hcard2 : Nat.card (Subgroup.zpowers a) = q := by rw [Nat.card_zpowers, horda]
    exact Subgroup.eq_of_le_of_card_ge hle (by rw [hcard1, hcard2])
  have hxnotmem : ∀ j : ℕ, 0 < j → j < k → x ^ j ∉ Subgroup.zpowers a := by
    intro j hj0 hjk hmemx
    obtain ⟨w, hw⟩ := hmemx
    have h1 : (x ^ j) ^ q = 1 := by
      rw [← hw, ← zpow_natCast (a ^ w) q, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast,
        haq, one_zpow]
    have h2 : (x ^ j) ^ k = 1 := by
      rw [← pow_mul, mul_comm, pow_mul, hxk, one_pow]
    have hone : orderOf (x ^ j) ∣ 1 :=
      hcop ▸ Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one h1) (orderOf_dvd_of_pow_eq_one h2)
    have hxj : x ^ j = 1 := orderOf_eq_one_iff.1 (Nat.dvd_one.1 hone)
    have : k ∣ j := hordx ▸ orderOf_dvd_of_pow_eq_one hxj
    have := Nat.le_of_dvd hj0 this
    omega
  have hdistinct : ∀ i i', i < k → i' < k →
      prefixProd s i' * (prefixProd s i)⁻¹ ∈ Subgroup.zpowers (prefixProd s k) → i = i' := by
    intro i i' hi hi' hmemc
    rw [hzpow] at hmemc
    rw [hpref i (le_of_lt hi), hpref i' (le_of_lt hi')] at hmemc
    -- reduce to `x ^ (i' - i) ∈ ⟨a⟩`
    have key : ∀ u v : ℕ, u < k → v < k → u ≤ v →
        (if v = 0 then (1 : G) else a ^ c * x ^ v) * ((if u = 0 then (1 : G) else a ^ c * x ^ u))⁻¹
          ∈ Subgroup.zpowers a → u = v := by
      intro u v hu hv huv hmem'
      rcases Nat.eq_zero_or_pos u with hu0 | hu0
      · subst hu0
        rcases Nat.eq_zero_or_pos v with hv0 | hv0
        · exact hv0.symm
        · exfalso
          rw [if_pos rfl, if_neg (by omega), inv_one, mul_one] at hmem'
          have hxv : x ^ v ∈ Subgroup.zpowers a := by
            have : (a ^ c)⁻¹ * (a ^ c * x ^ v) ∈ Subgroup.zpowers a :=
              Subgroup.mul_mem _ (Subgroup.inv_mem _ hacmem) hmem'
            simpa [← mul_assoc] using this
          exact hxnotmem v hv0 hv hxv
      · rcases Nat.eq_zero_or_pos v with hv0 | hv0
        · omega
        · rw [if_neg (by omega), if_neg (by omega)] at hmem'
          -- `hmem' : (a^c x^v) (a^c x^u)⁻¹ ∈ ⟨a⟩`, and `⟨a⟩` is normal
          have hconj : x ^ (v - u) ∈ Subgroup.zpowers a := by
            have hrw : a ^ c * x ^ v * (a ^ c * x ^ u)⁻¹
                = a ^ c * (x ^ (v - u)) * (a ^ c)⁻¹ := by
              have hvu : v - u + u = v := by omega
              calc a ^ c * x ^ v * (a ^ c * x ^ u)⁻¹
                  = a ^ c * x ^ (v - u + u) * (a ^ c * x ^ u)⁻¹ := by rw [hvu]
                _ = a ^ c * (x ^ (v - u)) * (a ^ c)⁻¹ := by
                    rw [pow_add, mul_inv_rev]
                    group
            rw [hrw] at hmem'
            have := hnormal.conj_mem _ hmem' (a ^ c)⁻¹
            simpa [mul_assoc] using this
          rcases Nat.eq_zero_or_pos (v - u) with h0 | h0
          · omega
          · exact absurd hconj (hxnotmem _ h0 (by omega))
    rcases le_total i i' with hle | hle
    · exact key i i' hi hi' hle hmemc
    · have hsymm : (if i = 0 then (1 : G) else a ^ c * x ^ i) *
          ((if i' = 0 then (1 : G) else a ^ c * x ^ i'))⁻¹ ∈ Subgroup.zpowers a := by
        have hinv := Subgroup.inv_mem _ hmemc
        rw [mul_inv_rev, inv_inv] at hinv
        exact hinv
      exact (key i' i hi' hi hle hsymm).symm
  have h3 : 3 ≤ q * k := by nlinarith
  exact isHamiltonian_of_factorGroup (by omega) h3 hmem hne hsper hordz hdistinct hcard

section Witness

open DihedralGroup

/-- **Non-vacuity of the same-coset criterion.**  In the dihedral group of order `14` the two
reflections `sr 0` and `sr 6 = r 1 * sr 0` lie in one and the same coset of the rotation
subgroup, so `Cay(D₇, {sr 0, sr 6})` is hamiltonian by `isHamiltonian_of_same_coset_pair` even
though the connection set misses the (normal) rotation subgroup entirely. -/
theorem dihedral7_same_coset_isHamiltonian {S : Set (DihedralGroup 7)}
    (h0 : (sr 0 : DihedralGroup 7) ∈ S) (h6 : (sr 6 : DihedralGroup 7) ∈ S) :
    (cayleyGraph (DihedralGroup 7) S).IsHamiltonian := by
  have hnormal : (Subgroup.zpowers (r 1 : DihedralGroup 7)).Normal := by
    refine Subgroup.normal_of_index_eq_two ?_
    have h1 : Nat.card (Subgroup.zpowers (r 1 : DihedralGroup 7)) = 7 := by
      rw [Nat.card_zpowers, DihedralGroup.orderOf_r_one]
    have h2 : Nat.card (DihedralGroup 7) = 14 := by
      simp [Nat.card_eq_fintype_card, DihedralGroup.card]
    have h3 := Subgroup.card_mul_index (Subgroup.zpowers (r 1 : DihedralGroup 7))
    rw [h1, h2] at h3
    omega
  have hcard : Fintype.card (DihedralGroup 7) = 7 * 2 := by rw [DihedralGroup.card]
  exact isHamiltonian_of_same_coset_pair (a := r 1) (x := sr 0) (y := sr 6) (c := 1)
    (by norm_num) h0 h6 le_rfl DihedralGroup.orderOf_r_one (DihedralGroup.orderOf_sr 0)
    (by norm_num) hnormal (by decide) (by decide) hcard

end Witness

end CayleyHamiltonian