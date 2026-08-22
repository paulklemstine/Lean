import Cryptography.ResidueDial.Core

/-!
# Batteries of residue dials: CRT composition and the bit-currency separation

A *battery* is a family of residue dials on pairwise coprime moduli, read
simultaneously.  The Chinese Remainder Theorem says that the joint filter on the
product modulus is exactly the "AND" of the individual filters
(`mem_crtDial`), and that its density is the *product* of the individual
densities (`crtDial_density`).

Two consequences are proved here.

* **The battery cap is still `4/3`** (`crtDial_speedup_le_four_thirds`,
  `batteryDensity_speedup_le_four_thirds`): composing dials — any number of
  them, on any moduli — cannot beat a single dial.  Composition is *free* in the
  sense that it costs nothing and buys nothing beyond the universal cap.

* **Capacity bits and work bits are different currencies.**  A battery of `n`
  half-density dials advertises `n` bits of capacity
  (`capacityBits_half_pow`), yet the work it buys is
  `workBits ≤ logb 2 (4/3) < 1` bit (`workBits_le_cap`, `workBits_lt_one`),
  and in fact tends to `0` as the capacity grows
  (`workBits_tendsto_zero_of_capacity_atTop`).  So the measured "battery bits"
  of a residue battery cannot be converted into work bits at par: capacity is
  unbounded while work is capped at `logb 2 (4/3)`.
-/

namespace ResidueDial

open Finset

/-! ## CRT composition of two dials -/

/-- The CRT isomorphism on unit groups: `(ZMod (m*n))ˣ ≃* (ZMod m)ˣ × (ZMod n)ˣ`
for coprime `m`, `n`. -/
noncomputable def crtUnits {m n : ℕ} (h : Nat.Coprime m n) :
    (ZMod (m * n))ˣ ≃* (ZMod m)ˣ × (ZMod n)ˣ :=
  (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits

open scoped Classical in
/-- The composed dial: the residues mod `m*n` whose two CRT readings pass the
respective filters. -/
noncomputable def crtDial {m n : ℕ} (h : Nat.Coprime m n)
    (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) : Finset (ZMod (m * n))ˣ :=
  (K₁ ×ˢ K₂).image (crtUnits h).symm

open scoped Classical in
/-- Composition really is the logical AND of the two readings. -/
theorem mem_crtDial {m n : ℕ} (h : Nat.Coprime m n)
    (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) (u : (ZMod (m * n))ˣ) :
    u ∈ crtDial h K₁ K₂ ↔ (crtUnits h u).1 ∈ K₁ ∧ (crtUnits h u).2 ∈ K₂ := by
  classical
  simp only [crtDial, Finset.mem_image, Finset.mem_product]
  constructor
  · rintro ⟨⟨a, b⟩, hab, rfl⟩
    simpa using hab
  · intro hu
    exact ⟨crtUnits h u, hu, by simp⟩

open scoped Classical in
theorem crtDial_card {m n : ℕ} (h : Nat.Coprime m n)
    (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) :
    (crtDial h K₁ K₂).card = K₁.card * K₂.card := by
  classical
  rw [crtDial, Finset.card_image_of_injective _ (crtUnits h).symm.injective,
    Finset.card_product]

/-- **Densities multiply under CRT composition.**  The battery's density is the
product of the dial densities — this is the only way the composition enters the
law. -/
theorem crtDial_density {m n : ℕ} [NeZero m] [NeZero n] (h : Nat.Coprime m n)
    (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) :
    density (m * n) (crtDial h K₁ K₂) = density m K₁ * density n K₂ := by
  have hm : (0:ℝ) < (m.totient : ℝ) := by exact_mod_cast totient_pos_of_neZero m
  have hn : (0:ℝ) < (n.totient : ℝ) := by exact_mod_cast totient_pos_of_neZero n
  rw [density, density, density, crtDial_card, Nat.totient_mul h]
  push_cast
  field_simp

/-- **The battery cap for a composed pair: still `4/3`.** -/
theorem crtDial_speedup_le_four_thirds {m n : ℕ} [NeZero m] [NeZero n]
    (h : Nat.Coprime m n) (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) :
    speedup (density (m * n) (crtDial h K₁ K₂)) ≤ 4 / 3 :=
  speedup_le_four_thirds _

/-! ## Batteries of arbitrarily many dials -/

/-- The density of a battery is the product of the densities of its dials. -/
def batteryDensity (θs : List ℝ) : ℝ := θs.prod

@[simp] theorem batteryDensity_nil : batteryDensity [] = 1 := rfl

@[simp] theorem batteryDensity_cons (θ : ℝ) (θs : List ℝ) :
    batteryDensity (θ :: θs) = θ * batteryDensity θs := rfl

theorem batteryDensity_nonneg {θs : List ℝ} (h : ∀ θ ∈ θs, 0 ≤ θ) :
    0 ≤ batteryDensity θs := by
  induction θs with
  | nil => simp
  | cons a t ih =>
      have ha : 0 ≤ a := h a (List.mem_cons_self ..)
      have ht : 0 ≤ batteryDensity t := ih fun x hx => h x (List.mem_cons_of_mem _ hx)
      simpa using mul_nonneg ha ht

theorem batteryDensity_le_one {θs : List ℝ} (h : ∀ θ ∈ θs, 0 ≤ θ ∧ θ ≤ 1) :
    batteryDensity θs ≤ 1 := by
  induction θs with
  | nil => simp
  | cons a t ih =>
      obtain ⟨ha0, ha1⟩ := h a (List.mem_cons_self ..)
      have hsub : ∀ x ∈ t, 0 ≤ x ∧ x ≤ 1 := fun x hx => h x (List.mem_cons_of_mem _ hx)
      have ht1 : batteryDensity t ≤ 1 := ih hsub
      have ht0 : 0 ≤ batteryDensity t :=
        batteryDensity_nonneg fun x hx => (hsub x hx).1
      simpa using mul_le_one₀ ha1 ht0 ht1

/-- **Batteries compose for free.**  However many dials a battery contains, and
whatever their densities, its speedup obeys the same universal cap `4/3`. -/
theorem batteryDensity_speedup_le_four_thirds (θs : List ℝ) :
    speedup (batteryDensity θs) ≤ 4 / 3 :=
  speedup_le_four_thirds _

/-- …and in particular never reaches `2`: the barrier-`4` converse survives
composition. -/
theorem batteryDensity_speedup_lt_two (θs : List ℝ) :
    speedup (batteryDensity θs) < 2 :=
  speedup_lt_two _

/-- Adding a dial to a battery can only shrink its density. -/
theorem batteryDensity_cons_le {θ : ℝ} {θs : List ℝ} (h1 : θ ≤ 1)
    (hs : ∀ x ∈ θs, 0 ≤ x) :
    batteryDensity (θ :: θs) ≤ batteryDensity θs := by
  have ht : 0 ≤ batteryDensity θs := batteryDensity_nonneg hs
  have := mul_le_of_le_one_left ht h1
  simpa using this

/-! ## Capacity bits versus work bits -/

/-- The *capacity* of a dial of density `θ`, in bits: `log₂ (1/θ)`, the amount
of information the filter reveals about the target class. -/
noncomputable def capacityBits (θ : ℝ) : ℝ := -Real.logb 2 θ

/-- The *work* a dial of density `θ` buys, in bits: `log₂ (Speedup θ)`. -/
noncomputable def workBits (θ : ℝ) : ℝ := Real.logb 2 (speedup θ)

/-- A battery of `n` half-density dials advertises exactly `n` capacity bits. -/
theorem capacityBits_half_pow (n : ℕ) : capacityBits ((1 / 2 : ℝ) ^ n) = n := by
  have h2 : Real.logb 2 (1 / 2 : ℝ) = -1 := by
    rw [one_div, Real.logb_inv, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  rw [capacityBits, Real.logb_pow, h2]
  ring

/-- Capacity bits are unbounded: for every `B` there is a battery whose capacity
exceeds `B` bits. -/
theorem exists_battery_capacity_ge (B : ℝ) :
    ∃ n : ℕ, B ≤ capacityBits ((1 / 2 : ℝ) ^ n) := by
  obtain ⟨n, hn⟩ := exists_nat_ge B
  exact ⟨n, by rwa [capacityBits_half_pow]⟩

/-- **Work bits are capped.**  Whatever the density — hence whatever the
battery — the work bought is at most `logb 2 (4/3) ≈ 0.41504` bits. -/
theorem workBits_le_cap (θ : ℝ) : workBits θ ≤ Real.logb 2 (4 / 3) := by
  have hpos := speedup_pos θ
  exact Real.logb_le_logb_of_le (by norm_num) hpos (speedup_le_four_thirds θ)

/-- Consequently a residue battery never buys a full work bit. -/
theorem workBits_lt_one (θ : ℝ) : workBits θ < 1 := by
  have hcap : Real.logb 2 (4 / 3) < 1 := by
    rw [show (1:ℝ) = Real.logb 2 2 from (Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)).symm]
    exact Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  exact lt_of_le_of_lt (workBits_le_cap θ) hcap

/-- **Bit-currency separation.**  For every capacity budget `B` there is a
battery with at least `B` capacity bits whose work bits are still below the
universal cap `logb 2 (4/3) < 1`.  Capacity bits and work bits are different
currencies. -/
theorem capacity_bits_unbounded_work_bits_capped (B : ℝ) :
    ∃ n : ℕ, B ≤ capacityBits ((1 / 2 : ℝ) ^ n) ∧
      workBits ((1 / 2 : ℝ) ^ n) ≤ Real.logb 2 (4 / 3) ∧
      workBits ((1 / 2 : ℝ) ^ n) < 1 := by
  obtain ⟨n, hn⟩ := exists_battery_capacity_ge B
  exact ⟨n, hn, workBits_le_cap _, workBits_lt_one _⟩

/-- `speedup` is continuous wherever it is defined — the cost never vanishes. -/
theorem continuous_speedup : Continuous speedup := by
  unfold speedup dialCost
  apply Continuous.div continuous_const (by continuity)
  intro x
  simpa [dialCost] using dialCost_ne_zero x

/-- **Vanishing exchange rate.**  As the battery grows (capacity `n` bits), the
work it buys tends to `0`: not merely capped, the conversion rate collapses. -/
theorem workBits_tendsto_zero_of_capacity_atTop :
    Filter.Tendsto (fun n : ℕ => workBits ((1 / 2 : ℝ) ^ n)) Filter.atTop (nhds 0) := by
  have hθ : Filter.Tendsto (fun n : ℕ => (1 / 2 : ℝ) ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hs : Filter.Tendsto (fun n : ℕ => speedup ((1 / 2 : ℝ) ^ n)) Filter.atTop (nhds 1) := by
    have hcont : Filter.Tendsto speedup (nhds 0) (nhds (speedup 0)) :=
      continuous_speedup.tendsto 0
    have hcomp := hcont.comp hθ
    rwa [speedup_of_trivial (Or.inl rfl)] at hcomp
  have hlog : Filter.Tendsto (fun x : ℝ => Real.logb 2 x) (nhds 1) (nhds 0) := by
    have h1 : Filter.Tendsto (fun x : ℝ => Real.logb 2 x) (nhds 1) (nhds (Real.logb 2 1)) :=
      Real.continuousAt_logb (b := 2) (by norm_num)
    rwa [Real.logb_one] at h1
  exact hlog.comp hs

end ResidueDial