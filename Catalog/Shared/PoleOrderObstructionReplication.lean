import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionRoots

/-!
# Cycle 5: rigidity of the obstruction, and its behaviour under replication

Two questions are left open by cycles 1–4.

*Is the pole-order theorem sharp from below?*  Cycle 1 computes the pole order of
a product of normalized series.  Here we prove the **converse**: if `m` nonzero
Laurent series each have **at most** a simple pole and their product has a pole of
order exactly `m`, then every single factor has a pole of order exactly `1`
(`PoleOrderObstruction.order_eq_neg_one_of_prod_order_eq`).  So a Monster-sized
pole *certifies* that each of the `194` factors is genuinely singular: no
cancellation, and no factor can be regular
(`PoleOrderObstruction.each_factor_simple_pole_194`).

*Can the obstruction be removed?*  Cycle 3 showed that the Monster product has no
cube root because `3 ∤ 194`.  Here we show that the **replication operator**
`V_d : q ↦ q^d` (an injective ring endomorphism of `ℂ⸨X⸩`, the formal shadow of
the Hecke-type operators of Monstrous Moonshine) multiplies the pole order by
`d`, hence changes the root spectrum from the divisors of `194` to the divisors
of `194 d`.  In particular the *third replication* of the Monster product **does**
have a cube root (`PoleOrderObstruction.exists_cube_root_replicate_three_194`),
while the obstruction to `n`-th roots becomes exactly `n ∤ 194 d`
(`PoleOrderObstruction.exists_pow_eq_replicate_prod_traceLaurent_194_iff`).
-/

namespace PoleOrderObstruction

open HahnSeries Finset

variable {ι : Type*}

/-! ## 1. Rigidity: the pole order of the product controls every factor -/

/-- Order additivity over a finite family of nonzero series. -/
theorem order_prod_of_ne_zero (s : Finset ι) (f : ι → LC) (hne : ∀ i ∈ s, f i ≠ 0) :
    (∏ i ∈ s, f i).order = ∑ i ∈ s, (f i).order := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have hane : f a ≠ 0 := hne a (Finset.mem_insert_self a s)
      have hsub : ∀ i ∈ s, f i ≠ 0 := fun i hi => hne i (Finset.mem_insert_of_mem hi)
      have hprodne : (∏ i ∈ s, f i) ≠ 0 := Finset.prod_ne_zero_iff.mpr hsub
      rw [Finset.prod_insert ha, Finset.sum_insert ha,
        order_mul_of_ne_zero' hane hprodne, ih hsub]

/-- **Rigidity of the pole-order obstruction.**  Let `f i` (`i ∈ s`, `#s = m`) be
nonzero Laurent series each with at most a simple pole (`order ≥ -1`).  If the
product has a pole of order exactly `m`, then *every* factor has a pole of order
exactly `1`.  Maximal pole order in the product forces maximal pole order in each
factor: there is no room for cancellation or for a regular factor. -/
theorem order_eq_neg_one_of_prod_order_eq (s : Finset ι) (f : ι → LC)
    (hne : ∀ i ∈ s, f i ≠ 0) (hge : ∀ i ∈ s, (-1 : ℤ) ≤ (f i).order)
    (hprod : (∏ i ∈ s, f i).order = -(s.card : ℤ)) :
    ∀ i ∈ s, (f i).order = -1 := by
  have hsum : ∑ i ∈ s, (f i).order = -(s.card : ℤ) := by
    rw [← order_prod_of_ne_zero s f hne, hprod]
  have hzero : ∑ i ∈ s, ((f i).order + 1) = 0 := by
    rw [Finset.sum_add_distrib, hsum, Finset.sum_const, nsmul_eq_mul, mul_one]
    ring
  have hnonneg : ∀ i ∈ s, 0 ≤ (f i).order + 1 := by
    intro i hi
    have := hge i hi
    omega
  intro i hi
  have := (Finset.sum_eq_zero_iff_of_nonneg hnonneg).mp hzero i hi
  omega

/-- **The Monster-sized pole certifies simplicity of every factor.**  If `194`
nonzero series with at most simple poles multiply to something with a pole of
order `194`, each of them has a simple pole. -/
theorem each_factor_simple_pole_194 (T : Fin monsterClassCount → LC)
    (hne : ∀ i, T i ≠ 0) (hge : ∀ i, (-1 : ℤ) ≤ (T i).order)
    (hprod : (∏ i, T i).order = -194) :
    ∀ i, (T i).order = -1 := by
  intro i
  refine order_eq_neg_one_of_prod_order_eq Finset.univ T (fun j _ => hne j)
    (fun j _ => hge j) ?_ i (Finset.mem_univ i)
  simpa [monsterClassCount] using hprod

/-! ## 2. The replication operator `V_d : q ↦ q ^ d` -/

/-- Multiplication by `d` on the exponent lattice. -/
def scaleHom (d : ℕ) : ℤ →+ ℤ := AddMonoidHom.mulLeft (d : ℤ)

theorem scaleHom_apply (d : ℕ) (g : ℤ) : scaleHom d g = (d : ℤ) * g := rfl

theorem scaleHom_injective {d : ℕ} (hd : d ≠ 0) : Function.Injective (scaleHom d) := by
  intro a b hab
  have hd' : (d : ℤ) ≠ 0 := Nat.cast_ne_zero.mpr hd
  have : (d : ℤ) * a = (d : ℤ) * b := hab
  exact mul_left_cancel₀ hd' this

theorem scaleHom_le_iff {d : ℕ} (hd : d ≠ 0) (g g' : ℤ) :
    scaleHom d g ≤ scaleHom d g' ↔ g ≤ g' := by
  have hpos : (0 : ℤ) < (d : ℤ) := by
    exact_mod_cast Nat.pos_of_ne_zero hd
  simp only [scaleHom_apply]
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

/-- **The replication operator.**  `replicate d` substitutes `q ↦ q ^ d`; it is an
injective ring endomorphism of `ℂ⸨X⸩` (the formal shadow of the Hecke-type
operators `V_d` of Monstrous Moonshine). -/
noncomputable def replicate (d : ℕ) (hd : d ≠ 0) : LC →+* LC :=
  HahnSeries.embDomainRingHom (scaleHom d) (scaleHom_injective hd) (scaleHom_le_iff hd)

/-- Replication multiplies the pole order by `d`. -/
theorem orderTop_replicate {d : ℕ} (hd : d ≠ 0) (x : LC) (k : ℤ)
    (hx : x.orderTop = (k : WithTop ℤ)) :
    (replicate d hd x).orderTop = (((d : ℤ) * k : ℤ) : WithTop ℤ) := by
  have h : (replicate d hd x).orderTop
      = WithTop.map (⟨⟨scaleHom d, scaleHom_injective hd⟩, scaleHom_le_iff hd _ _⟩ :
          ℤ ↪o ℤ) x.orderTop :=
    HahnSeries.orderTop_embDomain
  rw [h, hx]
  rfl

/-- Replication of a Monster-type product: the pole order becomes `d · m`. -/
theorem orderTop_replicate_prod_normalized {d : ℕ} (hd : d ≠ 0) (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (replicate d hd (∏ i ∈ s, f i)).orderTop = ((-((d * s.card : ℕ) : ℤ) : ℤ) : WithTop ℤ) := by
  rw [orderTop_replicate hd _ _ (orderTop_prod_normalized s f h)]
  congr 1
  push_cast
  ring

theorem replicate_prod_normalized_ne_zero {d : ℕ} (hd : d ≠ 0) (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    replicate d hd (∏ i ∈ s, f i) ≠ 0 := by
  intro hzero
  have := orderTop_replicate_prod_normalized hd s f h
  rw [hzero, HahnSeries.orderTop_zero] at this
  exact (WithTop.top_ne_coe this)

/-- **Root spectrum after replication.**  The `d`-th replication of a product of
`m` normalized series has an `n`-th root exactly when `n ∣ d · m`: replication
*enlarges* the root spectrum in a completely controlled way. -/
theorem exists_pow_eq_replicate_prod_normalized_iff {d : ℕ} (hd : d ≠ 0) (s : Finset ι)
    (f : ι → LC) (h : ∀ i ∈ s, IsNormalized (f i)) {n : ℕ} (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = replicate d hd (∏ i ∈ s, f i)) ↔ n ∣ d * s.card := by
  have hne := replicate_prod_normalized_ne_zero hd s f h
  have hord : (replicate d hd (∏ i ∈ s, f i)).order = -((d * s.card : ℕ) : ℤ) := by
    have h1 := orderTop_replicate_prod_normalized hd s f h
    rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at h1
    exact_mod_cast h1
  rw [exists_pow_eq_iff_dvd_order hne hn, hord, dvd_neg]
  exact_mod_cast Iff.rfl

/-! ## 3. The Monster after replication -/

/-- The `d`-th replication of the Monstrous-Moonshine product has an `n`-th root
exactly when `n ∣ 194 d`. -/
theorem exists_pow_eq_replicate_prod_traceLaurent_194_iff {d : ℕ} (hd : d ≠ 0)
    (c : Fin monsterClassCount → ℕ → ℂ) {n : ℕ} (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = replicate d hd (∏ i, traceLaurent (c i))) ↔ n ∣ d * 194 := by
  have h := exists_pow_eq_replicate_prod_normalized_iff hd
    (Finset.univ : Finset (Fin monsterClassCount)) (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) hn
  rw [Finset.card_univ, Fintype.card_fin] at h
  simpa [monsterClassCount] using h

/-- **Replication removes the obstruction.**  Although the Monster product has no
cube root, its *third* replication does: `3 ∣ 3 · 194`. -/
theorem exists_cube_root_replicate_three_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃ y : LC, y ^ 3 = replicate 3 (by norm_num) (∏ i, traceLaurent (c i)) := by
  rw [exists_pow_eq_replicate_prod_traceLaurent_194_iff (by norm_num) c (by norm_num)]
  norm_num

/-- Replication by `d` never *destroys* a root: the divisors of `194` remain. -/
theorem exists_sq_root_replicate_194 {d : ℕ} (hd : d ≠ 0)
    (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃ y : LC, y ^ 2 = replicate d hd (∏ i, traceLaurent (c i)) := by
  rw [exists_pow_eq_replicate_prod_traceLaurent_194_iff hd c (by norm_num)]
  exact Dvd.dvd.mul_left (by norm_num) d

/-- The obstruction survives replication precisely when `n ∤ 194 d`; e.g. no
`5`-th root exists after replication by `3`, since `5 ∤ 582`. -/
theorem not_exists_fifth_root_replicate_three_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    ¬ ∃ y : LC, y ^ 5 = replicate 3 (by norm_num) (∏ i, traceLaurent (c i)) := by
  rw [exists_pow_eq_replicate_prod_traceLaurent_194_iff (by norm_num) c (by norm_num)]
  decide

/-! ## 4. The replication depth needed for an `n`-th root -/

/-- Arithmetic core: `n ∣ m d` iff `n / gcd(n, m)` divides `d`. -/
theorem dvd_mul_iff_div_gcd_dvd {n m d : ℕ} (hn : n ≠ 0) :
    n ∣ m * d ↔ (n / Nat.gcd n m) ∣ d := by
  set g : ℕ := Nat.gcd n m with hgdef
  have hg : 0 < g := Nat.gcd_pos_of_pos_left m (Nat.pos_of_ne_zero hn)
  obtain ⟨a, ha⟩ : g ∣ n := Nat.gcd_dvd_left n m
  obtain ⟨b, hb⟩ : g ∣ m := Nat.gcd_dvd_right n m
  have hna : n / g = a := by rw [ha, Nat.mul_div_cancel_left a hg]
  have hmb : m / g = b := by rw [hb, Nat.mul_div_cancel_left b hg]
  have hcop : Nat.Coprime a b := by
    have := Nat.coprime_div_gcd_div_gcd (m := n) (n := m) hg
    rwa [hna, hmb] at this
  rw [hna]
  constructor
  · intro h
    have h2 : g * a ∣ g * (b * d) := by
      rw [← mul_assoc, ← hb, ← ha]
      exact h
    exact hcop.dvd_of_dvd_mul_left ((mul_dvd_mul_iff_left hg.ne').mp h2)
  · rintro ⟨t, rfl⟩
    exact ⟨b * t, by rw [ha, hb]; ring⟩

/-- **Minimal replication depth.**  After replication by `d`, the Monster product
has an `n`-th root exactly when `d` is a multiple of `n / gcd(n, 194)`; that
quotient is therefore the minimal replication depth at which the `n`-th root
appears. -/
theorem exists_pow_eq_replicate_iff_depth (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) {d : ℕ} (hd : d ≠ 0) :
    (∃ y : LC, y ^ n = replicate d hd (∏ i, traceLaurent (c i)))
      ↔ (n / Nat.gcd n 194) ∣ d := by
  rw [exists_pow_eq_replicate_prod_traceLaurent_194_iff hd c hn, mul_comm d 194]
  exact dvd_mul_iff_div_gcd_dvd hn

/-- Minimal depths in small cases: a cube root needs depth `3`, a fourth root only
depth `2` (because `2 ∣ 194`), and a fifth root needs depth `5`. -/
theorem replication_depths_small (c : Fin monsterClassCount → ℕ → ℂ) :
    (3 / Nat.gcd 3 194 = 3) ∧ (4 / Nat.gcd 4 194 = 2) ∧ (5 / Nat.gcd 5 194 = 5) ∧
      (∃ y : LC, y ^ 4 = replicate 2 (by norm_num) (∏ i, traceLaurent (c i))) := by
  refine ⟨by decide, by decide, by decide, ?_⟩
  rw [exists_pow_eq_replicate_iff_depth c (by norm_num) (by norm_num)]
  decide

end PoleOrderObstruction