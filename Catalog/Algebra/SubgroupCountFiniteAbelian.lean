/-
# Counting the subgroups of a finite group

This file settles the group-theoretic half of target 1 of the previous research cycle of the
conditional Hilbert class field thread.  By
`HilbertClassFieldDescent.card_intermediateField_eq_card_subgroup`, the number of intermediate
fields of a Hilbert class field `H/K` is the number of subgroups of the class group, so the
arithmetic question "how many intermediate fields?" becomes the group-theoretic question
"how many subgroups?".  The previous cycle answered it for elementary abelian class groups
`(ℤ/p)^r` (the Galois `p`-binomial count).  Here we prove:

* `Subgroup.eq_prod_of_coprime`, `subgroupProdOrderIsoOfCoprime`,
  `card_subgroup_prod_of_coprime` : **multiplicativity**.  If `Nat.card G` and `Nat.card H` are
  coprime then every subgroup of `G × H` is a product of subgroups, the subgroup lattice of
  `G × H` is the product of the two subgroup lattices, and
  `#Subgroup (G × H) = #Subgroup G * #Subgroup H`.  (No commutativity is needed.)
* `card_subgroup_cyclic` : a finite **cyclic** group of order `n` has exactly `d(n)` subgroups,
  `d` the number-of-divisors function.
* `card_subgroup_of_sq_prime_card` : a group of order `p²` of exponent `p` (`p` prime) has
  exactly `p + 3` subgroups: `⊥`, `⊤` and the `p + 1` "lines".
* `card_subgroup_zmod_four`, `card_subgroup_kleinFour`, `card_subgroup_ne_of_order_four` :
  the falsifiable contrast announced in the previous cycle — `ℤ/4` has `3` subgroups while
  `(ℤ/2)²` has `5`, so **the number of intermediate fields of the Hilbert class field is not a
  function of the class number alone**.

Everything is stated for multiplicative groups; the additive models `ZMod n` are reached through
`Multiplicative`.
-/

import Mathlib

open Subgroup

namespace SubgroupCount

instance finite_subgroup (G : Type*) [Group G] [Finite G] : Finite (Subgroup G) :=
  Finite.of_injective (fun K : Subgroup G => (K : Set G)) SetLike.coe_injective

/-! ## Multiplicativity over a coprime product -/

section Product

variable {G H : Type*} [Group G] [Group H] [Finite G] [Finite H]

/-- If a power `x ^ n` of `x` with `n` coprime to the order of `x` lies in a subgroup, so does
`x` itself. -/
theorem mem_of_pow_mem_of_coprime {A : Type*} [Group A] [Finite A] {K : Subgroup A} {x : A}
    {n : ℕ} (hcop : (orderOf x).Coprime n) (h : x ^ n ∈ K) : x ∈ K := by
  have hle : Subgroup.zpowers (x ^ n) ≤ Subgroup.zpowers x := by
    rw [Subgroup.zpowers_le]
    exact pow_mem (Subgroup.mem_zpowers x) n
  have hcard : Nat.card (Subgroup.zpowers x) ≤ Nat.card (Subgroup.zpowers (x ^ n)) := by
    rw [Nat.card_zpowers, Nat.card_zpowers, orderOf_pow, hcop, Nat.div_one]
  have heq : Subgroup.zpowers (x ^ n) = Subgroup.zpowers x :=
    Subgroup.eq_of_le_of_card_ge hle hcard
  have : x ∈ Subgroup.zpowers (x ^ n) := by rw [heq]; exact Subgroup.mem_zpowers x
  exact (Subgroup.zpowers_le.mpr h) this

/-- **Splitting the first coordinate.**  If the orders of `G` and `H` are coprime, then a
subgroup of `G × H` containing `(a, b)` contains `(a, 1)`. -/
theorem mk_one_mem_of_coprime (hco : (Nat.card G).Coprime (Nat.card H))
    {K : Subgroup (G × H)} {a : G} {b : H} (h : (a, b) ∈ K) : ((a, 1) : G × H) ∈ K := by
  set n := Nat.card H with hn
  have hb : b ^ n = 1 := pow_card_eq_one'
  have hpow : ((a, b) : G × H) ^ n = ((a ^ n, 1) : G × H) := by
    rw [Prod.pow_mk, hb]
  have hmem : ((a ^ n, 1) : G × H) ∈ K := by rw [← hpow]; exact pow_mem h n
  have hx : ((a, 1) : G × H) ^ n = ((a ^ n, 1) : G × H) := by rw [Prod.pow_mk, one_pow]
  refine mem_of_pow_mem_of_coprime (x := ((a, 1) : G × H)) ?_ (by rw [hx]; exact hmem)
  have hdvd : orderOf ((a, 1) : G × H) ∣ Nat.card G := by
    refine orderOf_dvd_of_pow_eq_one ?_
    rw [Prod.pow_mk, one_pow, pow_card_eq_one']
    rfl
  exact Nat.Coprime.coprime_dvd_left hdvd hco

/-- **Splitting the second coordinate.** -/
theorem one_mk_mem_of_coprime (hco : (Nat.card G).Coprime (Nat.card H))
    {K : Subgroup (G × H)} {a : G} {b : H} (h : (a, b) ∈ K) : ((1, b) : G × H) ∈ K := by
  set m := Nat.card G with hm
  have ha : a ^ m = 1 := pow_card_eq_one'
  have hpow : ((a, b) : G × H) ^ m = ((1, b ^ m) : G × H) := by
    rw [Prod.pow_mk, ha]
  have hmem : ((1, b ^ m) : G × H) ∈ K := by rw [← hpow]; exact pow_mem h m
  have hx : ((1, b) : G × H) ^ m = ((1, b ^ m) : G × H) := by rw [Prod.pow_mk, one_pow]
  refine mem_of_pow_mem_of_coprime (x := ((1, b) : G × H)) ?_ (by rw [hx]; exact hmem)
  have hdvd : orderOf ((1, b) : G × H) ∣ Nat.card H := by
    refine orderOf_dvd_of_pow_eq_one ?_
    rw [Prod.pow_mk, one_pow, pow_card_eq_one']
    rfl
  exact Nat.Coprime.coprime_dvd_left hdvd hco.symm

/-- **Every subgroup of a coprime product is a product of subgroups.** -/
theorem eq_prod_of_coprime (hco : (Nat.card G).Coprime (Nat.card H)) (K : Subgroup (G × H)) :
    K = (K.map (MonoidHom.fst G H)).prod (K.map (MonoidHom.snd G H)) := by
  ext x
  obtain ⟨a, b⟩ := x
  constructor
  · intro h
    exact ⟨⟨(a, b), h, rfl⟩, ⟨(a, b), h, rfl⟩⟩
  · rintro ⟨h1, h2⟩
    obtain ⟨⟨a₁, b₁⟩, hab₁, rfl⟩ := h1
    obtain ⟨⟨a₂, b₂⟩, hab₂, rfl⟩ := h2
    have hA : ((a₁, 1) : G × H) ∈ K := mk_one_mem_of_coprime hco hab₁
    have hB : ((1, b₂) : G × H) ∈ K := one_mk_mem_of_coprime hco hab₂
    have : ((a₁, 1) : G × H) * (1, b₂) ∈ K := mul_mem hA hB
    simpa [Prod.ext_iff] using this

omit [Finite G] [Finite H] in
theorem map_fst_prod (A : Subgroup G) (B : Subgroup H) :
    (A.prod B).map (MonoidHom.fst G H) = A := by
  ext a
  constructor
  · rintro ⟨⟨x, y⟩, ⟨hx, _⟩, rfl⟩; exact hx
  · intro ha; exact ⟨(a, 1), ⟨ha, one_mem B⟩, rfl⟩

omit [Finite G] [Finite H] in
theorem map_snd_prod (A : Subgroup G) (B : Subgroup H) :
    (A.prod B).map (MonoidHom.snd G H) = B := by
  ext b
  constructor
  · rintro ⟨⟨x, y⟩, ⟨_, hy⟩, rfl⟩; exact hy
  · intro hb; exact ⟨(1, b), ⟨one_mem A, hb⟩, rfl⟩

/-- **The subgroup lattice of a coprime product splits.** -/
def subgroupProdOrderIsoOfCoprime (hco : (Nat.card G).Coprime (Nat.card H)) :
    Subgroup (G × H) ≃o Subgroup G × Subgroup H where
  toFun K := (K.map (MonoidHom.fst G H), K.map (MonoidHom.snd G H))
  invFun AB := AB.1.prod AB.2
  left_inv K := (eq_prod_of_coprime hco K).symm
  right_inv AB := by
    obtain ⟨A, B⟩ := AB
    simp [map_fst_prod, map_snd_prod]
  map_rel_iff' := by
    intro K K'
    constructor
    · rintro ⟨h1, h2⟩
      rw [eq_prod_of_coprime hco K, eq_prod_of_coprime hco K']
      rintro ⟨a, b⟩ ⟨ha, hb⟩
      exact ⟨h1 ha, h2 hb⟩
    · intro h
      exact ⟨Subgroup.map_mono h, Subgroup.map_mono h⟩

/-- **Multiplicativity of the subgroup count over a coprime product.** -/
theorem card_subgroup_prod_of_coprime (hco : (Nat.card G).Coprime (Nat.card H)) :
    Nat.card (Subgroup (G × H)) = Nat.card (Subgroup G) * Nat.card (Subgroup H) := by
  rw [Nat.card_congr (subgroupProdOrderIsoOfCoprime hco).toEquiv, Nat.card_prod]

end Product

/-! ## Cyclic groups: the divisor count -/

section Cyclic

variable {G : Type*} [CommGroup G] [Finite G] [IsCyclic G]

/-- In a finite cyclic group there is a subgroup of each order dividing the order of the group. -/
theorem exists_subgroup_card_eq {d : ℕ} (hd : d ∣ Nat.card G) :
    ∃ K : Subgroup G, Nat.card K = d := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := G)
  refine ⟨Subgroup.zpowers (g ^ (Nat.card G / d)), ?_⟩
  rw [Nat.card_zpowers, orderOf_pow, hg]
  have hdvd : Nat.card G / d ∣ Nat.card G := Nat.div_dvd_of_dvd hd
  have hpos : 0 < Nat.card G := Nat.card_pos
  rw [Nat.gcd_eq_right hdvd, Nat.div_div_self hd (by omega)]

/-- In a finite cyclic group, the subgroup of order `d` (for `d` dividing the order) is the group
of `d`-th roots of unity; in particular a subgroup is determined by its order. -/
theorem eq_ker_powMonoidHom_of_card_eq {d : ℕ} {L : Subgroup G} (hL : Nat.card L = d) :
    L = (powMonoidHom d : G →* G).ker := by
  have hdvd : d ∣ Nat.card G := hL ▸ Subgroup.card_subgroup_dvd_card L
  have hker : Nat.card (powMonoidHom d : G →* G).ker = d := by
    rw [IsCyclic.card_powMonoidHom_ker, Nat.gcd_eq_right hdvd]
  refine Subgroup.eq_of_le_of_card_ge ?_ (by rw [hker, hL])
  intro x hx
  have h : ((⟨x, hx⟩ : L)) ^ Nat.card L = 1 := pow_card_eq_one'
  have hx' : x ^ d = 1 := by
    have := congrArg (Subtype.val) h
    simpa [hL] using this
  simpa [MonoidHom.mem_ker, powMonoidHom] using hx'

/-- In a finite cyclic group a subgroup is determined by its order. -/
theorem subgroup_injective_card :
    Function.Injective (fun K : Subgroup G => Nat.card K) := by
  intro K K' h
  rw [eq_ker_powMonoidHom_of_card_eq (L := K) rfl,
    eq_ker_powMonoidHom_of_card_eq (L := K') h.symm]

/-- **The subgroup count of a finite cyclic group is the number of divisors of its order.** -/
theorem card_subgroup_cyclic :
    Nat.card (Subgroup G) = (Nat.card G).divisors.card := by
  classical
  have hn : 0 < Nat.card G := Nat.card_pos
  let F : Subgroup G → {d : ℕ // d ∈ (Nat.card G).divisors} := fun K =>
    ⟨Nat.card K, by
      rw [Nat.mem_divisors]
      exact ⟨Subgroup.card_subgroup_dvd_card K, by omega⟩⟩
  have hinj : Function.Injective F := by
    intro K K' h
    exact subgroup_injective_card (congrArg Subtype.val h)
  have hsurj : Function.Surjective F := by
    rintro ⟨d, hd⟩
    obtain ⟨K, hK⟩ := exists_subgroup_card_eq (G := G) (Nat.mem_divisors.mp hd).1
    exact ⟨K, Subtype.ext hK⟩
  rw [Nat.card_eq_of_bijective F ⟨hinj, hsurj⟩, Nat.card_eq_finsetCard]

end Cyclic

/-! ## Elementary abelian groups of rank two -/

section Elementary

variable {G : Type*} [Group G] [Finite G] {p : ℕ}

omit [Finite G] in
/-- In a group of exponent `p` (`p` prime) every non-identity element generates a subgroup of
order `p`. -/
theorem card_zpowers_eq_of_exponent (hp : p.Prime) (hexp : ∀ x : G, x ^ p = 1) {x : G}
    (hx : x ≠ 1) : Nat.card (Subgroup.zpowers x) = p := by
  rw [Nat.card_zpowers]
  have hdvd : orderOf x ∣ p := orderOf_dvd_of_pow_eq_one (hexp x)
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
  · exact absurd (orderOf_eq_one_iff.mp h) hx
  · exact h

/-- A subgroup of order `p` is generated by any of its non-identity elements. -/
theorem zpowers_eq_of_card_eq (hp : p.Prime) {K : Subgroup G} (hK : Nat.card K = p) {x : G}
    (hxK : x ∈ K) (hx : x ≠ 1) : Subgroup.zpowers x = K := by
  have hle : Subgroup.zpowers x ≤ K := (Subgroup.zpowers_le).mpr hxK
  refine Subgroup.eq_of_le_of_card_ge hle ?_
  have hcard : Nat.card (Subgroup.zpowers x) = orderOf x := Nat.card_zpowers x
  have hdvd : orderOf x ∣ p := by
    rw [← hK]
    have h1 : orderOf ((⟨x, hxK⟩ : K)) ∣ Nat.card K := orderOf_dvd_natCard _
    rwa [Subgroup.orderOf_mk] at h1
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
  · exact absurd (orderOf_eq_one_iff.mp h) hx
  · omega

/-- **The `p + 1` lines.**  A group of order `p²` and exponent `p` has exactly `p + 1` subgroups
of order `p`. -/
theorem card_subgroup_card_eq_prime (hp : p.Prime) (hcard : Nat.card G = p ^ 2)
    (hexp : ∀ x : G, x ^ p = 1) :
    Nat.card {K : Subgroup G // Nat.card K = p} = p + 1 := by
  classical
  haveI : Fintype G := Fintype.ofFinite G
  haveI : Finite {K : Subgroup G // Nat.card K = p} := Finite.of_injective _ Subtype.val_injective
  haveI : Fintype {K : Subgroup G // Nat.card K = p} := Fintype.ofFinite _
  -- the map sending a non-identity element to the line it generates
  let F : {x : G // x ≠ 1} → {K : Subgroup G // Nat.card K = p} := fun x =>
    ⟨Subgroup.zpowers x.1, card_zpowers_eq_of_exponent hp hexp x.2⟩
  -- the fibre over a line `K` consists of the `p - 1` non-identity elements of `K`
  have hfib : ∀ K : {K : Subgroup G // Nat.card K = p},
      Nat.card {x : {x : G // x ≠ 1} // F x = K} = p - 1 := by
    intro K
    have hFK : ∀ x : {x : G // x ≠ 1}, F x = K ↔ x.1 ∈ K.1 := by
      intro x
      constructor
      · intro h
        have h' : Subgroup.zpowers x.1 = K.1 := congrArg Subtype.val h
        rw [← h']
        exact Subgroup.mem_zpowers _
      · intro h
        exact Subtype.ext (zpowers_eq_of_card_eq hp K.2 h x.2)
    have e : {x : {x : G // x ≠ 1} // F x = K} ≃ {y : K.1 // y ≠ 1} :=
      { toFun := fun x => ⟨⟨x.1.1, (hFK x.1).mp x.2⟩,
          fun h => x.1.2 (by simpa using congrArg Subtype.val h)⟩
        invFun := fun y => ⟨⟨y.1.1, fun h => y.2 (Subtype.ext h)⟩,
          (hFK ⟨y.1.1, fun h => y.2 (Subtype.ext h)⟩).mpr y.1.2⟩
        left_inv := fun x => rfl
        right_inv := fun y => rfl }
    rw [Nat.card_congr e]
    have : Nat.card {y : K.1 // y ≠ 1} = Nat.card K.1 - 1 := by
      haveI : Fintype K.1 := Fintype.ofFinite _
      rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card,
        Fintype.card_subtype_compl (p := fun y : K.1 => y = 1)]
      simp
    rw [this, K.2]
  -- count
  have hsum : Nat.card {x : G // x ≠ 1}
      = Nat.card {K : Subgroup G // Nat.card K = p} * (p - 1) := by
    rw [← Nat.card_congr (Equiv.sigmaFiberEquiv F), Nat.card_sigma]
    rw [Finset.sum_congr rfl fun K _ => hfib K, Finset.sum_const, smul_eq_mul,
      Finset.card_univ, ← Nat.card_eq_fintype_card]
  have hne : Nat.card {x : G // x ≠ 1} = p ^ 2 - 1 := by
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype_compl (p := fun x : G => x = 1)]
    simp [← Nat.card_eq_fintype_card, hcard]
  have hp2 : 2 ≤ p := hp.two_le
  have hkey : (p + 1) * (p - 1) = p ^ 2 - 1 := by
    obtain ⟨m, rfl⟩ : ∃ m, p = m + 1 := ⟨p - 1, by omega⟩
    have h : (m + 1) ^ 2 = m * m + 2 * m + 1 := by ring
    have h2 : (m + 1 + 1) * (m + 1 - 1) = m * m + 2 * m := by
      simp only [Nat.add_sub_cancel]; ring
    omega
  rw [hne, ← hkey] at hsum
  have hpos : 0 < p - 1 := by omega
  exact (Nat.eq_of_mul_eq_mul_right hpos hsum).symm

/-- **The subgroup count of an elementary abelian group of order `p²`.**  Such a group has
exactly `p + 3` subgroups: the trivial one, the whole group, and `p + 1` lines. -/
theorem card_subgroup_of_sq_prime_card (hp : p.Prime) (hcard : Nat.card G = p ^ 2)
    (hexp : ∀ x : G, x ^ p = 1) : Nat.card (Subgroup G) = p + 3 := by
  classical
  haveI : Fintype (Subgroup G) := Fintype.ofFinite _
  -- classify a subgroup by its order
  have horder : ∀ K : Subgroup G, Nat.card K = 1 ∨ Nat.card K = p ∨ Nat.card K = p ^ 2 := by
    intro K
    have hdvd : Nat.card K ∣ p ^ 2 := hcard ▸ Subgroup.card_subgroup_dvd_card K
    obtain ⟨i, hi, hK⟩ := (Nat.dvd_prime_pow hp).mp hdvd
    interval_cases i
    · exact Or.inl (by simpa using hK)
    · exact Or.inr (Or.inl (by simpa using hK))
    · exact Or.inr (Or.inr hK)
  have hp1 : p ≠ 1 := hp.ne_one
  have hp2 : 2 ≤ p := hp.two_le
  have hpsq : p ^ 2 ≠ p := by nlinarith [hp.two_le]
  let f : Subgroup G → Fin 3 := fun K =>
    if Nat.card K = 1 then 0 else if Nat.card K = p then 1 else 2
  have hfib0 : Nat.card {K : Subgroup G // f K = 0} = 1 := by
    have e : {K : Subgroup G // f K = 0} ≃ {K : Subgroup G // K = ⊥} := by
      refine Equiv.subtypeEquivRight fun K => ?_
      simp only [f]
      constructor
      · intro h
        by_cases h1 : Nat.card K = 1
        · exact Subgroup.card_eq_one.mp h1
        · simp only [h1, if_false] at h
          split at h <;> simp at h
      · intro h
        simp [h]
    rw [Nat.card_congr e]
    simp
  have hfib2 : Nat.card {K : Subgroup G // f K = 2} = 1 := by
    have e : {K : Subgroup G // f K = 2} ≃ {K : Subgroup G // K = ⊤} := by
      refine Equiv.subtypeEquivRight fun K => ?_
      simp only [f]
      constructor
      · intro h
        by_cases h1 : Nat.card K = 1
        · simp [h1] at h
        by_cases hpK : Nat.card K = p
        · simp [hpK, hp1] at h
        rcases horder K with h' | h' | h'
        · exact absurd h' h1
        · exact absurd h' hpK
        · rw [← Subgroup.card_eq_iff_eq_top, h', hcard]
      · rintro rfl
        rw [Subgroup.card_top, hcard]
        simp [hp1, hpsq]
    rw [Nat.card_congr e]
    simp
  have hfib1 : Nat.card {K : Subgroup G // f K = 1} = p + 1 := by
    have e : {K : Subgroup G // f K = 1} ≃ {K : Subgroup G // Nat.card K = p} := by
      refine Equiv.subtypeEquivRight fun K => ?_
      simp only [f]
      constructor
      · intro h
        by_cases h1 : Nat.card K = 1
        · simp [h1] at h
        by_cases hpK : Nat.card K = p
        · exact hpK
        · simp [h1, hpK] at h
      · intro h
        have h1 : Nat.card K ≠ 1 := by rw [h]; omega
        simp [h, hp1]
    rw [Nat.card_congr e]
    exact card_subgroup_card_eq_prime hp hcard hexp
  have := Nat.card_congr (Equiv.sigmaFiberEquiv f)
  rw [← this, Nat.card_sigma]
  rw [Fin.sum_univ_three]
  rw [hfib0, hfib1, hfib2]
  omega

end Elementary

/-! ## Cyclic versus elementary abelian at order `p²` -/

section Contrast

/-- A cyclic group of order `p^r` has exactly `r + 1` subgroups. -/
theorem card_subgroup_cyclic_prime_pow {G : Type*} [CommGroup G] [Finite G] [IsCyclic G]
    {p r : ℕ} (hp : p.Prime) (hcard : Nat.card G = p ^ r) :
    Nat.card (Subgroup G) = r + 1 := by
  rw [card_subgroup_cyclic, hcard, Nat.divisors_prime_pow hp]
  simp

/-- **The subgroup count separates the two abelian groups of order `p²`.**  The cyclic one has
`3` subgroups, the elementary abelian one has `p + 3`; in particular a Hilbert class field whose
class group has order `p²` has either `3` or `p + 3` intermediate fields, according to the
isomorphism type of the class group and not merely its order. -/
theorem card_subgroup_cyclic_ne_elementary {G H : Type*} [CommGroup G] [Finite G] [IsCyclic G]
    [Group H] [Finite H] {p : ℕ} (hp : p.Prime) (hG : Nat.card G = p ^ 2)
    (hH : Nat.card H = p ^ 2) (hexp : ∀ x : H, x ^ p = 1) :
    Nat.card (Subgroup G) = 3 ∧ Nat.card (Subgroup H) = p + 3 ∧
      Nat.card (Subgroup G) ≠ Nat.card (Subgroup H) := by
  have h1 : Nat.card (Subgroup G) = 3 := card_subgroup_cyclic_prime_pow hp hG
  have h2 : Nat.card (Subgroup H) = p + 3 := card_subgroup_of_sq_prime_card hp hH hexp
  have hp2 : 2 ≤ p := hp.two_le
  exact ⟨h1, h2, by omega⟩

end Contrast

/-! ## The falsifiable contrast at order four

Two abelian groups of the same order `4` with different subgroup counts: the cyclic group has
`3` subgroups, the Klein four group has `5`.  Consequently the number of intermediate fields of a
Hilbert class field is *not* determined by the class number. -/

section Examples

/-- `ℤ/4` has three subgroups. -/
theorem card_subgroup_zmod_four :
    Nat.card (Subgroup (Multiplicative (ZMod 4))) = 3 := by
  have hcard : Nat.card (Multiplicative (ZMod 4)) = 4 := by
    simp [Nat.card_eq_fintype_card]
  rw [card_subgroup_cyclic, hcard]
  decide

/-- The Klein four group has five subgroups; this is the case `p = 2` of
`card_subgroup_of_sq_prime_card`, and recovers `KleinFourClassField.card_subgroup_V` of the
previous cycle from a general theorem. -/
theorem card_subgroup_kleinFour :
    Nat.card (Subgroup (Multiplicative (ZMod 2 × ZMod 2))) = 5 := by
  have hcard : Nat.card (Multiplicative (ZMod 2 × ZMod 2)) = 2 ^ 2 := by
    simp [Nat.card_eq_fintype_card]
  have hexp : ∀ x : Multiplicative (ZMod 2 × ZMod 2), x ^ 2 = 1 := by decide
  have := card_subgroup_of_sq_prime_card (G := Multiplicative (ZMod 2 × ZMod 2))
    (p := 2) Nat.prime_two hcard hexp
  omega

/-- **The subgroup count is not a function of the order.**  Both groups have order `4`. -/
theorem card_subgroup_ne_of_order_four :
    Nat.card (Subgroup (Multiplicative (ZMod 4)))
      ≠ Nat.card (Subgroup (Multiplicative (ZMod 2 × ZMod 2))) := by
  rw [card_subgroup_zmod_four, card_subgroup_kleinFour]
  omega

/-- Consistency of the two counts: `ℤ/12 ≃ ℤ/4 × ℤ/3` has `3 * 2 = 6 = d(12)` subgroups. -/
theorem card_subgroup_prod_four_three :
    Nat.card (Subgroup (Multiplicative (ZMod 4) × Multiplicative (ZMod 3))) = 6 := by
  have h4 : Nat.card (Multiplicative (ZMod 4)) = 4 := by simp [Nat.card_eq_fintype_card]
  have h3 : Nat.card (Multiplicative (ZMod 3)) = 3 := by simp [Nat.card_eq_fintype_card]
  have hco : (Nat.card (Multiplicative (ZMod 4))).Coprime (Nat.card (Multiplicative (ZMod 3))) := by
    rw [h4, h3]; decide
  rw [card_subgroup_prod_of_coprime hco, card_subgroup_zmod_four]
  have h3' : Nat.card (Subgroup (Multiplicative (ZMod 3))) = (Nat.divisors 3).card := by
    rw [card_subgroup_cyclic, h3]
  rw [h3']
  decide

end Examples

end SubgroupCount