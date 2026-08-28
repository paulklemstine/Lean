import Pythagorean.SeqHint.Adaptive

/-!
# Sequential hint pricing X: two channels, two currencies

`SeqHint/Battery.lean` priced a **fixed comparison battery** at `k + 1`
candidate classes (linear, paper-138) and `SeqHint/Adaptive.lean` priced an
**adaptive comparison strategy** at `2 ^ k` (geometric).  The natural reading of
that pair is "adaptivity is what compounds".  This file shows that reading is
*too coarse*: compounding is a property of the **channel**, not of adaptivity.

We price a third arm, the **residue battery**: the `k` non-adaptive queries
`p mod m₀ = ?`, …, `p mod m_{k-1} = ?` with pairwise coprime moduli.  The answers
are combined by the Chinese Remainder Theorem, and the resulting pricing is
**multiplicative**:

* `residue_battery_isolates` — a *non-adaptive* residue battery isolates the
  hidden factor exactly on any window of width `∏ mᵢ`;
* `residue_battery_geometric` — with the moduli `2, 3, 5, …` (or any moduli
  `≥ 2`) the isolated volume is at least `2 ^ k`, so a non-adaptive battery
  matches the adaptive comparison ceiling.

So the linear law of `nonadapt_linear_pricing` is **not** a tax on
non-adaptivity: it is a tax on the *order* channel, whose `k` thresholds cut the
line into only `k + 1` pieces no matter how they are placed.

The converse half is the part with teeth.  Residue information buys candidate
*count* but **no interval information at all**:

* `residue_class_reaches_top`, `residue_class_reaches_bottom` — every residue
  class meets both ends of the window, to within one period `m`;
* `residue_hints_carry_no_interval_information` — the class of the true factor
  spreads across all but `2 * m` of the window, so the downstream Fermat
  *interval* scan is not shortened at all;
* `two_channel_pricing` — the synthesis: one comparison query halves the
  interval but multiplies the count by only `1/2`; one residue query divides the
  count by `m` but leaves the interval essentially intact.

That is the refined taxonomy: **count currency** (residue channel,
multiplicative, non-adaptive) and **interval currency** (order channel,
geometric only under adaptivity).  A downstream algorithm is sped up only by the
currency it can actually spend.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## The residue battery -/

/-- The answer vector of the non-adaptive residue battery with moduli
`m 0, …, m (k-1)`: the list of residues of the hidden value. -/
def resSig (m : ℕ → ℕ) (k : ℕ) (x : ℕ) : List ℕ :=
  (List.range k).map (fun i => x % m i)

@[simp] lemma resSig_length (m : ℕ → ℕ) (k x : ℕ) : (resSig m k x).length = k := by
  simp [resSig]

/-- Two candidates give the same residue battery answers iff they agree modulo
every modulus. -/
lemma resSig_eq_iff (m : ℕ → ℕ) (k x y : ℕ) :
    resSig m k x = resSig m k y ↔ ∀ i < k, x % m i = y % m i := by
  simp [resSig, List.map_inj_left, List.mem_range]

/-! ## Chinese remaindering: the residue channel compounds multiplicatively -/

/-- If pairwise coprime numbers `m 0, …, m (k-1)` all divide `z`, so does their
product.  (Finset-free induction, kept in `ℕ` to avoid `IsCoprime` in a
non-Bézout monoid.) -/
lemma prod_dvd_of_pairwise_coprime (m : ℕ → ℕ)
    (hcop : ∀ i j, i ≠ j → Nat.Coprime (m i) (m j)) (z : ℕ) :
    ∀ k, (∀ i < k, m i ∣ z) → (∏ i ∈ Finset.range k, m i) ∣ z := by
  intro k
  induction k with
  | zero => intro _; simp
  | succ k ih =>
      intro h
      have hpk : ∀ i < k, m i ∣ z := fun i hi => h i (Nat.lt_succ_of_lt hi)
      have hprod : (∏ i ∈ Finset.range k, m i) ∣ z := ih hpk
      have hk : m k ∣ z := h k (Nat.lt_succ_self k)
      have hc : Nat.Coprime (∏ i ∈ Finset.range k, m i) (m k) :=
        Nat.Coprime.prod_left fun i hi => hcop i k (Finset.mem_range.mp hi).ne
      exact (Finset.prod_range_succ m k) ▸ Nat.Coprime.mul_dvd_of_dvd_of_dvd hc hprod hk

/-- **The residue battery isolates.**  On a window of width `∏ᵢ mᵢ` with pairwise
coprime moduli, the *non-adaptive* residue battery separates every pair of
candidates: `k` queries resolve `∏ᵢ mᵢ` candidates. -/
theorem residue_battery_isolates (m : ℕ → ℕ)
    (hcop : ∀ i j, i ≠ j → Nat.Coprime (m i) (m j)) (k lo : ℕ)
    {x y : ℕ} (hx : x ∈ Finset.Ico lo (lo + ∏ i ∈ Finset.range k, m i))
    (hy : y ∈ Finset.Ico lo (lo + ∏ i ∈ Finset.range k, m i))
    (h : resSig m k x = resSig m k y) : x = y := by
  rw [resSig_eq_iff] at h
  rw [Finset.mem_Ico] at hx hy
  -- symmetric core: if `x ≤ y` then `∏ m ∣ y - x` and `y - x < ∏ m`
  have core : ∀ a b : ℕ, a ≤ b → lo ≤ a → b < lo + ∏ i ∈ Finset.range k, m i →
      (∀ i < k, a % m i = b % m i) → a = b := by
    intro a b hab hlo hhi hres
    have hdvd : ∀ i < k, m i ∣ b - a := by
      intro i hi
      exact (Nat.modEq_iff_dvd' hab).mp (hres i hi)
    have hP : (∏ i ∈ Finset.range k, m i) ∣ b - a :=
      prod_dvd_of_pairwise_coprime m hcop _ k hdvd
    have hlt : b - a < ∏ i ∈ Finset.range k, m i := by omega
    have := Nat.eq_zero_of_dvd_of_lt hP hlt
    omega
  rcases le_total x y with hxy | hxy
  · exact core x y hxy hx.1 hy.2 h
  · exact (core y x hxy hy.1 hx.2 (fun i hi => (h i hi).symm)).symm

/-- **Non-adaptive can be geometric.**  If every modulus is at least `2`, the
window isolated by the `k`-query residue battery has width at least `2 ^ k`: a
*fixed* battery attains the adaptive comparison ceiling.  Contrast
`nonadapt_linear_pricing`, where a fixed battery of `k` *comparison* thresholds
never resolves more than `k + 1` classes. -/
theorem residue_battery_geometric (m : ℕ → ℕ) (hm : ∀ i, 2 ≤ m i) (k : ℕ) :
    2 ^ k ≤ ∏ i ∈ Finset.range k, m i := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.prod_range_succ, pow_succ]
      exact Nat.mul_le_mul ih (hm k)

/-! ## A concrete instance: the prime residue battery -/

/-- The `i`-th modulus of the **prime residue battery**: the `i`-th prime. -/
noncomputable def primeMod (i : ℕ) : ℕ := Nat.nth Nat.Prime i

lemma primeMod_prime (i : ℕ) : Nat.Prime (primeMod i) := Nat.prime_nth_prime i

lemma primeMod_two_le (i : ℕ) : 2 ≤ primeMod i := (primeMod_prime i).two_le

lemma primeMod_coprime {i j : ℕ} (h : i ≠ j) : Nat.Coprime (primeMod i) (primeMod j) :=
  (Nat.coprime_primes (primeMod_prime i) (primeMod_prime j)).mpr
    (fun he => h (Nat.nth_injective Nat.infinite_setOf_prime he))

/-- **The prime residue battery is a witness that the hypotheses above are
satisfiable**, and it isolates the *primorial* window `∏_{i<k} pᵢ ≥ 2 ^ k` with
`k` fixed, non-adaptive queries.  The hypotheses of `residue_battery_isolates`
are therefore not vacuous: a real battery meets them at every `k`. -/
theorem prime_residue_battery_isolates (k lo : ℕ) {x y : ℕ}
    (hx : x ∈ Finset.Ico lo (lo + ∏ i ∈ Finset.range k, primeMod i))
    (hy : y ∈ Finset.Ico lo (lo + ∏ i ∈ Finset.range k, primeMod i))
    (h : resSig primeMod k x = resSig primeMod k y) :
    x = y ∧ 2 ^ k ≤ ∏ i ∈ Finset.range k, primeMod i :=
  ⟨residue_battery_isolates primeMod (fun _ _ hij => primeMod_coprime hij) k lo hx hy h,
    residue_battery_geometric primeMod primeMod_two_le k⟩

/-! ## …but residue information is worthless to an interval scan -/

/-- Every residue class reaches within one period of the **top** of the window. -/
theorem residue_class_reaches_top {lo w m a : ℕ} (hm : 0 < m)
    (ha : a ∈ Finset.Ico lo (lo + w)) :
    ∃ b ∈ Finset.Ico lo (lo + w), b % m = a % m ∧ a ≤ b ∧ lo + w ≤ b + m := by
  rw [Finset.mem_Ico] at ha
  set d := lo + w - 1 - a with hd
  have h2 : m * (d / m) + d % m = d := Nat.div_add_mod d m
  have h3 : d % m < m := Nat.mod_lt _ hm
  refine ⟨a + m * (d / m), ?_, ?_, ?_, ?_⟩
  · rw [Finset.mem_Ico]; omega
  · simp
  · omega
  · omega

/-- Every residue class reaches within one period of the **bottom** of the
window. -/
theorem residue_class_reaches_bottom {lo w m a : ℕ} (hm : 0 < m)
    (ha : a ∈ Finset.Ico lo (lo + w)) :
    ∃ b ∈ Finset.Ico lo (lo + w), b % m = a % m ∧ b ≤ a ∧ b < lo + m := by
  rw [Finset.mem_Ico] at ha
  set e := a - lo with he
  have h2 : m * (e / m) + e % m = e := Nat.div_add_mod e m
  have h3 : e % m < m := Nat.mod_lt _ hm
  have h1 : m * (e / m) ≤ e := by omega
  refine ⟨a - m * (e / m), ?_, ?_, ?_, ?_⟩
  · rw [Finset.mem_Ico]; omega
  · have hsub : a - m * (e / m) + m * (e / m) = a := by omega
    calc (a - m * (e / m)) % m
        = ((a - m * (e / m)) + m * (e / m)) % m := by simp
      _ = a % m := by rw [hsub]
  · omega
  · omega

/-- **Residue hints carry no interval information.**  Knowing `p mod m` leaves
two live candidates whose separation is all but `2 * m` of the original window:
the downstream Fermat scan, which sweeps an *interval*, is not shortened.  This
is exactly the opposite profile to a comparison hint (`Window.step_width_le`),
which halves the interval while removing only half of the candidates. -/
theorem residue_hints_carry_no_interval_information {lo w m a : ℕ} (hm : 0 < m)
    (ha : a ∈ Finset.Ico lo (lo + w)) :
    ∃ b ∈ Finset.Ico lo (lo + w), ∃ c ∈ Finset.Ico lo (lo + w),
      b % m = a % m ∧ c % m = a % m ∧ b ≤ c ∧ w ≤ (c - b) + 2 * m := by
  obtain ⟨c, hc, hcm, hca, hctop⟩ := residue_class_reaches_top hm ha
  obtain ⟨b, hb, hbm, hab, hbbot⟩ := residue_class_reaches_bottom hm ha
  rw [Finset.mem_Ico] at hb hc
  refine ⟨b, Finset.mem_Ico.mpr hb, c, Finset.mem_Ico.mpr hc, hbm, hcm, ?_, ?_⟩ <;> omega

/-- **Two channels, two currencies.**  For a nonempty window and any modulus
`m ≥ 2`:

1. one *comparison* query at the lower median at most halves the **interval**
   (order channel: interval currency, but only `k + 1` classes for a fixed
   battery of `k` thresholds);
2. `k` *residue* queries with pairwise coprime moduli isolate a volume of
   `∏ᵢ mᵢ ≥ 2 ^ k` candidates non-adaptively (count currency, multiplicative);
3. yet a single residue class still spans all but `2 * m` of the interval.

So "hints compound" and "hints price linearly" are statements about *different
currencies*, and the reconciliation of paper 138 with rounds 70–71 does not
depend on adaptivity alone. -/
theorem two_channel_pricing (I : Window) (hI : 0 < I.width) (m : ℕ → ℕ)
    (hm : ∀ i, 2 ≤ m i) (hcop : ∀ i j, i ≠ j → Nat.Coprime (m i) (m j)) (k : ℕ)
    {a : ℕ} (ha : a ∈ Finset.Ico I.lo (I.lo + I.width)) :
    (∀ b : Bool, (I.step b).width ≤ (I.width + 1) / 2) ∧
    (2 ^ k ≤ ∏ i ∈ Finset.range k, m i ∧
      ∀ x ∈ Finset.Ico I.lo (I.lo + ∏ i ∈ Finset.range k, m i),
        ∀ y ∈ Finset.Ico I.lo (I.lo + ∏ i ∈ Finset.range k, m i),
          resSig m k x = resSig m k y → x = y) ∧
    (∃ b ∈ Finset.Ico I.lo (I.lo + I.width), ∃ c ∈ Finset.Ico I.lo (I.lo + I.width),
      b % m 0 = a % m 0 ∧ c % m 0 = a % m 0 ∧ b ≤ c ∧ I.width ≤ (c - b) + 2 * m 0) := by
  refine ⟨fun b => Window.step_width_le I b hI, ⟨residue_battery_geometric m hm k, ?_⟩, ?_⟩
  · intro x hx y hy hxy
    exact residue_battery_isolates m hcop k I.lo hx hy hxy
  · exact residue_hints_carry_no_interval_information (by have := hm 0; omega) ha

end Pythagorean.SeqHint