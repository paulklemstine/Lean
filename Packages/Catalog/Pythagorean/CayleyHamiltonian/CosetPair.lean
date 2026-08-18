import Pythagorean.CayleyHamiltonian.OrderPQ

/-!
# The general coset-pair criterion

This file settles the *transversal configuration* left open by the reduction theorem
`pq_isHamiltonian_or_transversal`: the connection set contains an element `x` of order `k`
together with an element `y = A xᵐ` lying in the coset `xᵐ ⟨a⟩` of the normal subgroup
`N = ⟨a⟩` of prime order `q`, with `A ∈ N`, `A ≠ 1`.

The hamiltonian cycle is produced by the factor group lemma from the `k`-periodic word

`x, …, x, y, x⁻¹, …, x⁻¹, y, x, …, x`   (`m` copies of `x`, then `y`, then `m - 1` copies of
`x⁻¹`, then `y`, then `k - 2m - 1` copies of `x`),

whose projection to the quotient `G / N ≅ ℤ/k` visits the cosets in the order

`0, 1, …, m, 2m, 2m-1, …, m+1, 2m+1, 2m+2, …, k-1`,

a hamiltonian cycle of the quotient whenever `2m + 1 ≤ k`.  Its voltage is `A₁ A₂` with
`A₁ = xᵐ A x⁻ᵐ` and `A₂ = x^{m+1} A x^{-(m+1)}`, and the key point is that this voltage is
*never* trivial: `A₁ A₂ = 1` forces `x A₁ x⁻¹ = A₁⁻¹`, hence — since `k` is odd and `x^k = 1` —
`A₁ = A₁⁻¹`, which is impossible for an element of odd prime order `q ≠ 2`.

The condition `2m + 1 ≤ k` is harmless: replacing `x` by `x⁻¹` replaces `m` by `k - m`, and
since `k` is odd one of `m`, `k - m` is at most `(k-1)/2`.

Main results:

* `CayleyHamiltonian.pow_notMem_zpowers_of_coprime` : `xʲ ∉ ⟨a⟩` for `0 < j < k`.
* `CayleyHamiltonian.eq_of_coset_pow_mem` : two elements `B xᵘ`, `B' xᵛ` of `N ⟨x⟩` lie in the
  same coset of `N` only if `u = v` (for `u, v < k`).
* `CayleyHamiltonian.conj_odd_pow_eq_inv` : the parity computation behind the voltage bound.
* `CayleyHamiltonian.isHamiltonian_of_coset_pair_le` : the criterion for `2m + 1 ≤ k`.
* `CayleyHamiltonian.isHamiltonian_of_coset_pair` : **the general coset-pair criterion.**
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

section CosetPair

variable {a x y A : G} {q k m : ℕ}

omit [Fintype G] [DecidableEq G] in
/-- Powers `xʲ` with `0 < j < k` avoid the normal subgroup `⟨a⟩`, because `orderOf x = k` is
coprime to `orderOf a = q`. -/
theorem pow_notMem_zpowers_of_coprime (horda : orderOf a = q) (hordx : orderOf x = k)
    (hcop : Nat.Coprime q k) {j : ℕ} (hj0 : 0 < j) (hjk : j < k) :
    x ^ j ∉ Subgroup.zpowers a := by
  intro hmemx
  have haq : a ^ q = 1 := by rw [← horda, pow_orderOf_eq_one]
  have hxk : x ^ k = 1 := by rw [← hordx, pow_orderOf_eq_one]
  obtain ⟨w, hw⟩ := hmemx
  have h1 : (x ^ j) ^ q = 1 := by
    rw [← hw, ← zpow_natCast (a ^ w) q, ← zpow_mul, mul_comm, zpow_mul, zpow_natCast,
      haq, one_zpow]
  have h2 : (x ^ j) ^ k = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, hxk, one_pow]
  have hone : orderOf (x ^ j) ∣ 1 :=
    hcop ▸ Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one h1) (orderOf_dvd_of_pow_eq_one h2)
  have hxj : x ^ j = 1 := orderOf_eq_one_iff.1 (Nat.dvd_one.1 hone)
  have hdvd : k ∣ j := hordx ▸ orderOf_dvd_of_pow_eq_one hxj
  have := Nat.le_of_dvd hj0 hdvd
  omega

omit [Fintype G] [DecidableEq G] in
/-- Elements of the form `B xᵘ` with `B ∈ ⟨a⟩` and `u < k` represent pairwise distinct cosets
of `⟨a⟩`. -/
theorem eq_of_coset_pow_mem (horda : orderOf a = q) (hordx : orderOf x = k)
    (hcop : Nat.Coprime q k) {B B' : G} (hB : B ∈ Subgroup.zpowers a)
    (hB' : B' ∈ Subgroup.zpowers a) {u v : ℕ} (hu : u < k) (hv : v < k)
    (hmem : B' * x ^ v * (B * x ^ u)⁻¹ ∈ Subgroup.zpowers a) : u = v := by
  -- the statement is symmetric in `(B, u)` and `(B', v)`, so we may assume `u ≤ v`
  have key : ∀ (C C' : G), C ∈ Subgroup.zpowers a → C' ∈ Subgroup.zpowers a →
      ∀ s t : ℕ, s ≤ t → t < k → C' * x ^ t * (C * x ^ s)⁻¹ ∈ Subgroup.zpowers a → s = t := by
    intro C C' hC hC' s t hst htk hmem'
    have hpow : x ^ (t - s) ∈ Subgroup.zpowers a := by
      have hstep : C'⁻¹ * (C' * x ^ t * (C * x ^ s)⁻¹) * C = x ^ (t - s) := by
        have hts : x ^ t = x ^ (t - s) * x ^ s := by
          rw [← pow_add]
          congr 1
          omega
        rw [hts]
        group
      have : C'⁻¹ * (C' * x ^ t * (C * x ^ s)⁻¹) * C ∈ Subgroup.zpowers a :=
        Subgroup.mul_mem _ (Subgroup.mul_mem _ (Subgroup.inv_mem _ hC') hmem') hC
      rwa [hstep] at this
    by_contra hne
    exact pow_notMem_zpowers_of_coprime horda hordx hcop (by omega) (by omega) hpow
  rcases le_total u v with hle | hle
  · exact key B B' hB hB' u v hle hv hmem
  · refine (key B' B hB' hB v u hle hu ?_).symm
    have hinv := Subgroup.inv_mem _ hmem
    rw [mul_inv_rev, inv_inv] at hinv
    simpa [mul_assoc] using hinv

omit [Fintype G] [DecidableEq G] in
/-- If conjugation by `x` inverts `D`, then conjugation by any odd power of `x` inverts `D`. -/
theorem conj_odd_pow_eq_inv {D : G} (hD : x * D * x⁻¹ = D⁻¹) :
    ∀ j : ℕ, x ^ (2 * j + 1) * D * (x ^ (2 * j + 1))⁻¹ = D⁻¹ := by
  have hstep : ∀ (E : G) (j : ℕ), x ^ (j + 1) * E * (x ^ (j + 1))⁻¹
      = x * (x ^ j * E * (x ^ j)⁻¹) * x⁻¹ := by
    intro E j
    have hxj : x ^ (j + 1) = x * x ^ j := by group
    rw [hxj]
    group
  have hDinv : x * D⁻¹ * x⁻¹ = D := by
    calc x * D⁻¹ * x⁻¹ = (x * D * x⁻¹)⁻¹ := by group
      _ = D := by rw [hD, inv_inv]
  intro j
  induction j with
  | zero => simpa using hD
  | succ j ih =>
      have h2 : 2 * (j + 1) + 1 = ((2 * j + 1) + 1) + 1 := by ring
      rw [h2, hstep, hstep, ih, hDinv, hD]

omit [Fintype G] [DecidableEq G] in
/-- An element of a subgroup of prime order `q` generated by `a` is either trivial or of
order `q`. -/
theorem orderOf_eq_of_mem_zpowers_prime (hq : q.Prime) (horda : orderOf a = q) {g : G}
    (hg : g ∈ Subgroup.zpowers a) (hg1 : g ≠ 1) : orderOf g = q := by
  have hdvd : orderOf g ∣ q := horda ▸ orderOf_dvd_of_mem_zpowers hg
  rcases hq.eq_one_or_self_of_dvd _ hdvd with h | h
  · exact absurd (orderOf_eq_one_iff.1 h) hg1
  · exact h

/-- **The coset-pair criterion, small-`m` case.**  Under the standing hypotheses, and assuming
`2m + 1 ≤ k`, the Cayley graph is hamiltonian.  Only membership of `x` and `y` in the
*symmetrised* connection set is required. -/
theorem isHamiltonian_of_coset_pair_le (hq : q.Prime) (hq2 : q ≠ 2) (hkodd : Odd k)
    (hm0 : 0 < m) (hk2m : 2 * m + 1 ≤ k)
    (hx : x ∈ S ∨ x⁻¹ ∈ S) (hy : y ∈ S ∨ y⁻¹ ∈ S)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hA : A ∈ Subgroup.zpowers a) (hA1 : A ≠ 1) (hyx : y = A * x ^ m)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  classical
  have hk3 : 3 ≤ k := by omega
  have hxk : x ^ k = 1 := by rw [← hordx, pow_orderOf_eq_one]
  have hx1 : x ≠ 1 := by
    intro h
    rw [h, orderOf_one] at hordx
    omega
  -- the two conjugates of `A` that make up the voltage
  set A₁ : G := x ^ m * A * (x ^ m)⁻¹ with hA₁def
  set A₂ : G := x ^ (m + 1) * A * (x ^ (m + 1))⁻¹ with hA₂def
  have hA₁mem : A₁ ∈ Subgroup.zpowers a := hnormal.conj_mem A hA (x ^ m)
  have hA₂mem : A₂ ∈ Subgroup.zpowers a := hnormal.conj_mem A hA (x ^ (m + 1))
  have hA₁1 : A₁ ≠ 1 := by
    intro h
    apply hA1
    have : A = (x ^ m)⁻¹ * (x ^ m * A * (x ^ m)⁻¹) * x ^ m := by group
    rw [← hA₁def, h] at this
    simpa using this
  have hA₂conj : A₂ = x * A₁ * x⁻¹ := by
    rw [hA₁def, hA₂def, pow_succ]
    group
  -- the voltage is nontrivial
  have hvolt : A₁ * A₂ ≠ 1 := by
    intro hone
    have hinv : A₂ = A₁⁻¹ := by
      have := congrArg (fun g : G => A₁⁻¹ * g) hone
      simpa [← mul_assoc] using this
    have hflip : x * A₁ * x⁻¹ = A₁⁻¹ := by rw [← hA₂conj, hinv]
    obtain ⟨t, ht⟩ := hkodd
    have hxk' : x ^ (2 * t + 1) = 1 := by
      rw [show 2 * t + 1 = k by omega, hxk]
    have hself : x ^ (2 * t + 1) * A₁ * (x ^ (2 * t + 1))⁻¹ = A₁ := by
      rw [hxk']
      group
    have hAinv : A₁ = A₁⁻¹ := by
      have hconj := conj_odd_pow_eq_inv (D := A₁) hflip t
      rw [hself] at hconj
      exact hconj
    have hsq : A₁ ^ 2 = 1 := by
      rw [pow_two]
      nth_rewrite 2 [hAinv]
      exact mul_inv_cancel A₁
    have hord : orderOf A₁ = q := orderOf_eq_of_mem_zpowers_prime hq horda hA₁mem hA₁1
    have hdvd : q ∣ 2 := hord ▸ orderOf_dvd_of_pow_eq_one hsq
    rcases (Nat.Prime.eq_one_or_self_of_dvd Nat.prime_two _ hdvd) with h | h
    · exact absurd h hq.ne_one
    · exact hq2 h
  -- `y` is not the identity
  have hy1 : y ≠ 1 := by
    intro h
    rw [hyx] at h
    have hxeq : x ^ m = A⁻¹ := by
      calc x ^ m = A⁻¹ * (A * x ^ m) := by group
        _ = A⁻¹ := by rw [h, mul_one]
    have hxm : x ^ m ∈ Subgroup.zpowers a := by
      rw [hxeq]
      exact Subgroup.inv_mem _ hA
    exact pow_notMem_zpowers_of_coprime horda hordx hcop hm0 (by omega) hxm
  -- the periodic word
  set s : ℕ → G := fun i =>
    if i % k < m then x
    else if i % k = m then y
    else if i % k < 2 * m then x⁻¹
    else if i % k = 2 * m then y
    else x with hs
  have hsper : ∀ i, s (i + k) = s i := by
    intro i
    simp only [hs, Nat.add_mod_right]
  have hmem : ∀ i, s i ∈ S ∨ (s i)⁻¹ ∈ S := by
    intro i
    simp only [hs]
    split_ifs
    · exact hx
    · exact hy
    · rcases hx with h | h
      · exact Or.inr (by simpa using h)
      · exact Or.inl h
    · exact hy
    · exact hx
  have hne : ∀ i, s i ≠ 1 := by
    intro i
    simp only [hs]
    split_ifs
    · exact hx1
    · exact hy1
    · simpa using hx1
    · exact hy1
    · exact hx1
  -- the coset positions and the normal-subgroup parts of the prefix products
  set cf : ℕ → ℕ := fun i => if i ≤ m then i else if i ≤ 2 * m then 3 * m + 1 - i else i
    with hcf
  set Bf : ℕ → G := fun i => if i ≤ m then 1 else if i ≤ 2 * m then A₁ else A₁ * A₂ with hBf
  have hBfmem : ∀ i, Bf i ∈ Subgroup.zpowers a := by
    intro i
    simp only [hBf]
    split_ifs
    · exact Subgroup.one_mem _
    · exact hA₁mem
    · exact Subgroup.mul_mem _ hA₁mem hA₂mem
  have hcflt : ∀ i, i ≤ k → cf i ≤ k := by
    intro i hi
    simp only [hcf]
    split_ifs <;> omega
  have hcfinj : ∀ i i', i < k → i' < k → cf i = cf i' → i = i' := by
    intro i i' hi hi' h
    simp only [hcf] at h
    split_ifs at h <;> omega
  -- the prefix products of the word
  have hpref : ∀ i, i ≤ k → prefixProd s i = Bf i * x ^ cf i := by
    intro i
    induction i with
    | zero => intro _; simp [hBf, hcf]
    | succ i ih =>
        intro hik
        have hi : i ≤ k := by omega
        have hmod : i % k = i := Nat.mod_eq_of_lt (by omega)
        rw [prefixProd_succ, ih hi]
        rcases lt_or_ge i m with h1 | h1
        · -- an `x` step inside the initial run
          have hsx : s i = x := by simp only [hs, hmod, if_pos h1]
          rw [hsx]
          simp only [hBf, hcf, if_pos (show i ≤ m by omega), if_pos (show i + 1 ≤ m by omega)]
          rw [one_mul, one_mul, pow_succ]
        rcases eq_or_lt_of_le h1 with h2 | h2
        · -- the first `y` step
          have him : i = m := h2.symm
          subst him
          have hsy : s i = y := by
            simp only [hs, hmod, if_neg (by omega : ¬ i < i)]
            simp
          rw [hsy, hyx]
          simp only [hBf, hcf, if_pos (le_refl i), if_neg (by omega : ¬ i + 1 ≤ i),
            if_pos (by omega : i + 1 ≤ 2 * i)]
          rw [show 3 * i + 1 - (i + 1) = i + i by omega, pow_add, hA₁def]
          group
        rcases lt_or_ge i (2 * m) with h3 | h3
        · -- an `x⁻¹` step
          have hsx : s i = x⁻¹ := by
            simp only [hs, hmod, if_neg (by omega : ¬ i < m), if_neg (by omega : ¬ i = m),
              if_pos h3]
          rw [hsx]
          simp only [hBf, hcf, if_neg (by omega : ¬ i ≤ m), if_pos (by omega : i ≤ 2 * m),
            if_neg (by omega : ¬ i + 1 ≤ m), if_pos (by omega : i + 1 ≤ 2 * m)]
          rw [show 3 * m + 1 - i = (3 * m + 1 - (i + 1)) + 1 by omega, pow_succ]
          group
        rcases eq_or_lt_of_le h3 with h4 | h4
        · -- the second `y` step
          have him : i = 2 * m := h4.symm
          subst him
          have hsy : s (2 * m) = y := by
            simp only [hs, hmod, if_neg (by omega : ¬ 2 * m < m),
              if_neg (by omega : ¬ 2 * m = m), if_neg (by omega : ¬ 2 * m < 2 * m)]
            simp
          rw [hsy, hyx]
          simp only [hBf, hcf, if_neg (by omega : ¬ 2 * m ≤ m),
            if_pos (le_refl (2 * m)), if_neg (by omega : ¬ 2 * m + 1 ≤ m),
            if_neg (by omega : ¬ 2 * m + 1 ≤ 2 * m)]
          rw [show 3 * m + 1 - 2 * m = m + 1 by omega,
            show 2 * m + 1 = (m + 1) + m by omega, pow_add, hA₂def]
          group
        · -- an `x` step in the final run
          have hsx : s i = x := by
            simp only [hs, hmod, if_neg (by omega : ¬ i < m), if_neg (by omega : ¬ i = m),
              if_neg (by omega : ¬ i < 2 * m), if_neg (by omega : ¬ i = 2 * m)]
          rw [hsx]
          simp only [hBf, hcf, if_neg (by omega : ¬ i ≤ m), if_neg (by omega : ¬ i ≤ 2 * m),
            if_neg (by omega : ¬ i + 1 ≤ m), if_neg (by omega : ¬ i + 1 ≤ 2 * m)]
          rw [pow_succ, mul_assoc]
  -- the voltage of one turn
  have hzval : prefixProd s k = A₁ * A₂ := by
    rw [hpref k le_rfl]
    simp only [hBf, hcf, if_neg (by omega : ¬ k ≤ m), if_neg (by omega : ¬ k ≤ 2 * m)]
    rw [hxk, mul_one]
  have hordz : orderOf (prefixProd s k) = q := by
    rw [hzval]
    exact orderOf_eq_of_mem_zpowers_prime hq horda
      (Subgroup.mul_mem _ hA₁mem hA₂mem) hvolt
  have hzpow : Subgroup.zpowers (prefixProd s k) = Subgroup.zpowers a := by
    refine Subgroup.eq_of_le_of_card_ge ?_ ?_
    · exact Subgroup.zpowers_le.2 (by rw [hzval]; exact Subgroup.mul_mem _ hA₁mem hA₂mem)
    · rw [Nat.card_zpowers, Nat.card_zpowers, hordz, horda]
  have hdistinct : ∀ i i', i < k → i' < k →
      prefixProd s i' * (prefixProd s i)⁻¹ ∈ Subgroup.zpowers (prefixProd s k) → i = i' := by
    intro i i' hi hi' hmemc
    rw [hzpow, hpref i (le_of_lt hi), hpref i' (le_of_lt hi')] at hmemc
    have hcfi : cf i < k := by
      simp only [hcf]; split_ifs <;> omega
    have hcfi' : cf i' < k := by
      simp only [hcf]; split_ifs <;> omega
    exact hcfinj i i' hi hi'
      (eq_of_coset_pow_mem horda hordx hcop (hBfmem i) (hBfmem i') hcfi hcfi' hmemc)
  have h3 : 3 ≤ q * k := by
    have := hq.two_le
    nlinarith
  exact isHamiltonian_of_factorGroup (by omega) h3 hmem hne hsper hordz hdistinct hcard

/-- **The general coset-pair criterion.**  Let `|G| = q k` with `q` an odd prime coprime to the
odd number `k`, let `⟨a⟩` be normal of order `q`, let `x ∈ S` have order `k`, and let
`y = A xᵐ ∈ S` with `A ∈ ⟨a⟩`, `A ≠ 1` and `0 < m < k`.  Then `Cay(G, S)` is hamiltonian. -/
theorem isHamiltonian_of_coset_pair (hq : q.Prime) (hq2 : q ≠ 2) (hkodd : Odd k)
    (hm0 : 0 < m) (hmlt : m < k)
    (hx : x ∈ S) (hy : y ∈ S)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hA : A ∈ Subgroup.zpowers a) (hA1 : A ≠ 1) (hyx : y = A * x ^ m)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian := by
  have hxk : x ^ k = 1 := by rw [← hordx, pow_orderOf_eq_one]
  rcases le_or_gt (2 * m + 1) k with hle | hgt
  · exact isHamiltonian_of_coset_pair_le hq hq2 hkodd hm0 hle (Or.inl hx) (Or.inl hy)
      horda hordx hcop hnormal hA hA1 hyx hcard
  · -- pass to the inverse generator: `y = A (x⁻¹)^(k-m)` and `2(k-m) + 1 ≤ k`
    have hkm : 2 * (k - m) + 1 ≤ k := by
      rcases hkodd with ⟨t, ht⟩
      omega
    have hordxinv : orderOf x⁻¹ = k := by rw [orderOf_inv, hordx]
    have hmul : x ^ m * x ^ (k - m) = 1 := by
      rw [← pow_add, show m + (k - m) = k by omega, hxk]
    have hyx' : y = A * (x⁻¹) ^ (k - m) := by
      rw [inv_pow, inv_eq_of_mul_eq_one_left hmul, hyx]
    exact isHamiltonian_of_coset_pair_le hq hq2 hkodd (by omega) hkm
      (Or.inr (by simpa using hx)) (Or.inl hy) horda hordxinv hcop hnormal hA hA1 hyx' hcard

end CosetPair

end CayleyHamiltonian