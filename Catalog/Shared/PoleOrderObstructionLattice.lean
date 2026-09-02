import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionRoots
import Shared.PoleOrderObstructionReplication
import Shared.PoleOrderObstructionPuiseux

/-!
# Cycle 8: interpolating the root spectrum by the value group `(1/N)ℤ`

Cycle 3 computed the root spectrum of the Monster-sized product over the value
group `ℤ`: an `n`-th root exists iff `n ∣ 194`.  Cycle 6 computed it over the
divisible group `ℚ`: every `n` works.  Cycle 5 computed the spectrum after the
replication `V_d : q ↦ q^d`: an `n`-th root exists iff `n ∣ 194 d`.

This cycle proves that the two hierarchies are **one** hierarchy.  Working inside
the Puiseux field `ℂ⟦q^ℚ⟧` and constraining the root to have exponents in the
lattice `(1/N)ℤ`, we show

`(∃ y, y ^ n = ∏ T_g with support ⊆ (1/N)ℤ) ↔ n ∣ 194 N`

(`PoleOrderObstruction.exists_lattice_root_iff`), which is literally the
replication criterion of cycle 5 with `d = N`
(`PoleOrderObstruction.lattice_root_iff_replicate_root`).  Letting `N = 1`
recovers cycle 3 and letting `N` absorb any denominator recovers cycle 6, so the
value-group refinement and the replication depth are the *same* invariant.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

/-! ## 1. The lattice `(1/N)ℤ ⊆ ℚ` -/

/-- The subgroup `(1/N)ℤ` of `ℚ`, described as a set of exponents. -/
def latticeQ (N : ℕ) : Set ℚ := {r : ℚ | ∃ k : ℤ, r = (k : ℚ) / (N : ℚ)}

theorem intCast_mem_latticeQ {N : ℕ} (hN : N ≠ 0) (m : ℤ) : ((m : ℚ)) ∈ latticeQ N := by
  refine ⟨m * (N : ℤ), ?_⟩
  have : (N : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hN
  field_simp
  push_cast
  ring

theorem add_mem_latticeQ {N : ℕ} {a b : ℚ} (ha : a ∈ latticeQ N) (hb : b ∈ latticeQ N) :
    a + b ∈ latticeQ N := by
  obtain ⟨k, rfl⟩ := ha
  obtain ⟨l, rfl⟩ := hb
  exact ⟨k + l, by push_cast; ring⟩

/-- The support of a series coming from integer exponents lies in any set of
exponents containing the integers. -/
theorem support_puiseuxEmb_subset_of_intCast {S : Set ℚ}
    (hint : ∀ m : ℤ, ((m : ℚ)) ∈ S) (x : LC) :
    ↑(puiseuxEmb x).support ⊆ S := by
  intro r hr
  have hsub : (puiseuxEmb x).support ⊆
      (fun k : ℤ => ((k : ℚ))) '' x.support := HahnSeries.support_embDomain_subset
  obtain ⟨k, _, rfl⟩ := hsub hr
  exact hint k

/-- The support of a series coming from integer exponents lies in every lattice
`(1/N)ℤ`. -/
theorem support_puiseuxEmb_subset {N : ℕ} (hN : N ≠ 0) (x : LC) :
    ↑(puiseuxEmb x).support ⊆ latticeQ N :=
  support_puiseuxEmb_subset_of_intCast (intCast_mem_latticeQ hN) x

/-! ## 2. The order of the embedded Monster product -/

theorem puiseuxEmb_prod_traceLaurent_194_ne_zero (c : Fin monsterClassCount → ℕ → ℂ) :
    puiseuxEmb (∏ i, traceLaurent (c i)) ≠ 0 := by
  intro h
  have hne : (∏ i, traceLaurent (c i)) ≠ 0 :=
    prod_normalized_ne_zero _ _ (fun i _ => isNormalized_traceLaurent (c i))
  exact hne (puiseuxEmb_injective (by simpa using h))

theorem order_puiseuxEmb_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    (puiseuxEmb (∏ i, traceLaurent (c i))).order = (-194 : ℚ) := by
  have hne := puiseuxEmb_prod_traceLaurent_194_ne_zero c
  have h := orderTop_puiseuxEmb (∏ i, traceLaurent (c i)) (-194)
    (orderTop_prod_traceLaurent_194 c)
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at h
  exact_mod_cast h

/-! ## 3. The interpolation theorem -/

/-- **The value group decides the root spectrum.**  For *any* set `S` of
rational exponents that contains the integers and is closed under addition, the
Monster-sized product has an `n`-th root supported in `S` if and only if the
single exponent `-194/n` belongs to `S`.  The obstruction is therefore located
in one element of the value group, never in the series. -/
theorem exists_root_support_subset_iff {S : Set ℚ} (hint : ∀ m : ℤ, ((m : ℚ)) ∈ S)
    (hadd : ∀ a ∈ S, ∀ b ∈ S, a + b ∈ S) (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) :
    (∃ y : PC, y ^ n = puiseuxEmb (∏ i, traceLaurent (c i)) ∧ ↑y.support ⊆ S)
      ↔ (-(194 : ℚ)) / (n : ℚ) ∈ S := by
  have hnQ : (n : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  constructor
  · rintro ⟨y, hy, hsupp⟩
    have hy0 : y ≠ 0 := by
      intro h
      rw [h, zero_pow hn] at hy
      exact puiseuxEmb_prod_traceLaurent_194_ne_zero c hy.symm
    have hord : (n : ℕ) • y.order = (-194 : ℚ) := by
      rw [← HahnSeries.order_pow, hy]
      exact order_puiseuxEmb_prod_traceLaurent_194 c
    have hmem : y.order ∈ y.support := by
      rw [HahnSeries.mem_support]
      intro h
      exact hy0 (HahnSeries.coeff_order_eq_zero.mp h)
    have horder : y.order = (-(194 : ℚ)) / (n : ℚ) := by
      rw [nsmul_eq_mul] at hord
      field_simp
      linarith [hord]
    rw [← horder]
    exact hsupp hmem
  · intro hS
    obtain ⟨W, hW1, hWn⟩ := exists_pow_eq_of_constantCoeff_one
      (∏ i : Fin monsterClassCount, normalizedPart (traceLaurent (c i)))
      (constantCoeff_prod_normalizedPart Finset.univ _
        (fun i _ => isNormalized_traceLaurent (c i))) hn
    refine ⟨HahnSeries.single ((-(194 : ℚ)) / (n : ℚ)) (1 : ℂ) *
      puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W), ?_, ?_⟩
    · have hmap : (puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W)) ^ n
          = puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ
              (∏ i : Fin monsterClassCount, normalizedPart (traceLaurent (c i)))) := by
        rw [← map_pow, ← map_pow, hWn]
      have hcard : ((Finset.univ : Finset (Fin monsterClassCount)).card : ℤ) = 194 := by
        rw [Finset.card_univ, Fintype.card_fin]
        norm_num [monsterClassCount]
      rw [mul_pow, HahnSeries.single_pow, one_pow, hmap,
        show (n • ((-(194 : ℚ)) / (n : ℚ)))
            = (((-((Finset.univ : Finset (Fin monsterClassCount)).card : ℤ)) : ℤ) : ℚ) by
          rw [nsmul_eq_mul]; field_simp; push_cast [hcard]; ring,
        ← puiseuxEmb_single, ← map_mul]
      exact congrArg puiseuxEmb
        (prod_normalized_factorization Finset.univ _
          (fun i _ => isNormalized_traceLaurent (c i))).symm
    · intro r hr
      have hmem := HahnSeries.support_mul_subset hr
      rw [Set.mem_add] at hmem
      obtain ⟨a, ha, b, hb, rfl⟩ := hmem
      have ha' : a = (-(194 : ℚ)) / (n : ℚ) :=
        Set.mem_singleton_iff.mp (HahnSeries.support_single_subset ha)
      refine hadd a ?_ b (support_puiseuxEmb_subset_of_intCast hint _ hb)
      rw [ha']
      exact hS

/-- Membership of the critical exponent `-194/n` in the lattice `(1/N)ℤ` is the
divisibility `n ∣ 194 N`. -/
theorem neg_div_mem_latticeQ_iff {N n : ℕ} (hN : N ≠ 0) (hn : n ≠ 0) :
    (-(194 : ℚ)) / (n : ℚ) ∈ latticeQ N ↔ n ∣ 194 * N := by
  have hNQ : (N : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hN
  have hnQ : (n : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  constructor
  · rintro ⟨k, hk⟩
    rw [div_eq_div_iff hnQ hNQ] at hk
    have hkeyZ : (-194 : ℤ) * (N : ℤ) = k * (n : ℤ) := by exact_mod_cast hk
    have : (n : ℤ) ∣ (194 * N : ℤ) := ⟨-k, by linarith [hkeyZ]⟩
    exact_mod_cast this
  · rintro ⟨t, ht⟩
    refine ⟨-t, ?_⟩
    have h : (194 : ℚ) * (N : ℚ) = (n : ℚ) * (t : ℚ) := by
      exact_mod_cast congrArg (Nat.cast : ℕ → ℚ) ht
    rw [div_eq_div_iff hnQ hNQ]
    push_cast
    linarith [h]

/-- **Graded interpolation of the root spectrum.**  Inside the Puiseux field, the
Monster-sized product has an `n`-th root whose exponents lie in the lattice
`(1/N)ℤ` if and only if `n ∣ 194 N`.  For `N = 1` this is the `ℤ`-graded answer
of cycle 3; letting `N` grow recovers the unobstructed `ℚ`-graded answer of
cycle 6. -/
theorem exists_lattice_root_iff {N : ℕ} (hN : N ≠ 0) (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) :
    (∃ y : PC, y ^ n = puiseuxEmb (∏ i, traceLaurent (c i)) ∧
        ↑y.support ⊆ latticeQ N) ↔ n ∣ 194 * N := by
  rw [exists_root_support_subset_iff (intCast_mem_latticeQ hN)
      (fun a ha b hb => add_mem_latticeQ ha hb) c hn,
    neg_div_mem_latticeQ_iff hN hn]

/-- The value-group refinement and the replication depth are the *same*
invariant: having an `n`-th root with exponents in `(1/N)ℤ` is equivalent to
having an `n`-th root of the `N`-th replication. -/
theorem lattice_root_iff_replicate_root {N : ℕ} (hN : N ≠ 0)
    (c : Fin monsterClassCount → ℕ → ℂ) {n : ℕ} (hn : n ≠ 0) :
    (∃ y : PC, y ^ n = puiseuxEmb (∏ i, traceLaurent (c i)) ∧
        ↑y.support ⊆ latticeQ N)
      ↔ (∃ z : LC, z ^ n = replicate N hN (∏ i, traceLaurent (c i))) := by
  rw [exists_lattice_root_iff hN c hn,
    exists_pow_eq_replicate_prod_traceLaurent_194_iff hN c hn, mul_comm N 194]

/-- `N = 1` recovers the `ℤ`-graded root spectrum of cycle 3: only the divisors
of `194`. -/
theorem exists_lattice_root_one_iff (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) :
    (∃ y : PC, y ^ n = puiseuxEmb (∏ i, traceLaurent (c i)) ∧
        ↑y.support ⊆ latticeQ 1) ↔ n ∣ 194 := by
  rw [exists_lattice_root_iff one_ne_zero c hn, mul_one]

/-- A cube root appears exactly at the lattices `(1/N)ℤ` with `3 ∣ N`. -/
theorem exists_lattice_cube_root_iff {N : ℕ} (hN : N ≠ 0)
    (c : Fin monsterClassCount → ℕ → ℂ) :
    (∃ y : PC, y ^ 3 = puiseuxEmb (∏ i, traceLaurent (c i)) ∧
        ↑y.support ⊆ latticeQ N) ↔ 3 ∣ N := by
  rw [exists_lattice_root_iff hN c (by norm_num)]
  constructor
  · intro h
    have h3 : Nat.Coprime 3 194 := by decide
    exact (Nat.Coprime.dvd_of_dvd_mul_left h3 h)
  · intro h
    exact Dvd.dvd.mul_left h 194

end PoleOrderObstruction