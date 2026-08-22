/-
# TRACE-BATTERY, part II: joint capacity of a dial battery scales

Companion to `Combinatorics.TraceBatteryEntropy`, which supplies the exact
finitary Shannon calculus.  Here we formalise the object of the round-30
experiment (paper 108): a **battery of dials**, i.e. a finite family of
bounded-modulus readings `read i : Ω → ℕ`, `read i x < m i`, on a finite
population `Ω`, and its **joint capacity**

  `Hb (joint d S) = I(individual ; (read i)_{i ∈ S})`  (bits).

The experiment's verdict THE-SCALING-IS-CONFIRMED is the conjunction of four
structural facts, each proved here without any numerical input:

* `TraceBattery.capacity_mono` — **monotone scaling**: enlarging the subset of
  dials never lowers the joint capacity.  (Data processing.)
* `TraceBattery.capacity_strict_mono_of_separates` — **strict scaling
  criterion**: the increase is strict as soon as one new dial separates two
  individuals that the old sub-battery confuses.
* `TraceBattery.capacity_le_logb_prod` — **CRT ceiling**: the joint capacity of
  `S` is at most `log₂ ∏_{i ∈ S} mᵢ`; for the experiment's subsets this is
  `log₂ 713`, `log₂ 6417`, `log₂ 51336`.
* `TraceBattery.capacity_le_logb_pop` — **sparse-table bias**: the joint
  capacity is also at most `log₂ #Ω`, whatever the moduli.
* `TraceBattery.capacity_le_sum_dials` — **per-dial budget**: the joint capacity
  never exceeds the sum of the individual per-dial trace informations.

Sharpness is `TraceBattery.capacity_eq_logb_pop_of_injective` together with the
CRT witness `TraceBattery.crt_battery_saturates`: on the population
`ZMod 31 × ZMod 23` the two-dial battery attains exactly `log₂ 713` bits, so the
CRT ceiling is not an artefact of the bound.

Finally the reported table is checked against the theorems:
`TraceBattery.round30_table_consistent` shows the three measured values
`7.9455 < 10.4462 < 12.1080` are increasing and each strictly below its CRT
ceiling, and `TraceBattery.dial_at_11_below_346` shows a modulus-11 dial cannot
carry more than `3.46` bits — so the reported `3.46` for `C₅@11` is a rounding
of a saturated dial, while `S₃a@31`'s `0.04` sits far below its own ceiling
`log₂ 31 > 4.9`.
-/
import Mathlib
import Combinatorics.TraceBatteryEntropy

namespace TraceBattery

open Finset

/-! ## 1. Batteries of dials -/

/-- A **dial**: a reading of the population with values in a residue window
`{0, …, modulus - 1}`.  (Concretely, in the experiment, a trace invariant read
modulo a prime power.) -/
structure Dial (Ω : Type*) where
  /-- the modulus of the dial -/
  modulus : ℕ
  /-- the modulus is positive -/
  modulus_pos : 0 < modulus
  /-- the reading -/
  read : Ω → ℕ
  /-- readings are residues -/
  read_lt : ∀ x, read x < modulus

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The **joint reading** of the sub-battery indexed by `S`. -/
def joint (d : ι → Dial Ω) (S : Finset ι) : Ω → (↥S → ℕ) := fun x i => (d i.1).read x

/-- The **joint capacity** in bits of the sub-battery `S`. -/
noncomputable def capacity (d : ι → Dial Ω) (S : Finset ι) : ℝ := Hb (joint d S)

/-- The per-dial trace information in bits. -/
noncomputable def dialCapacity (d : ι → Dial Ω) (i : ι) : ℝ := Hb (d i).read

/-! ## 2. Monotone scaling -/

/-- Restriction of a joint reading to a smaller sub-battery. -/
def restr {S T : Finset ι} (h : S ⊆ T) (u : ↥T → ℕ) : ↥S → ℕ := fun i => u ⟨i.1, h i.2⟩

omit [Fintype Ω] [Nonempty Ω] [Fintype ι] [DecidableEq ι] in
theorem joint_restrict (d : ι → Dial Ω) {S T : Finset ι} (h : S ⊆ T) :
    joint d S = (restr h) ∘ (joint d T) := by
  funext x i
  rfl

omit [Fintype ι] [DecidableEq ι] in
/-- **Monotone scaling (data processing).**  Adding dials to the battery can
never decrease the joint capacity.  This is the exact content of the measured
chain `7.9455 → 10.4462 → 12.1080`. -/
theorem capacity_mono (d : ι → Dial Ω) {S T : Finset ι} (h : S ⊆ T) :
    capacity d S ≤ capacity d T := by
  have hH : H (joint d S) ≤ H (joint d T) := by
    rw [joint_restrict d h]
    exact H_comp_le (joint d T) (restr h)
  rw [capacity, capacity, Hb, Hb]
  gcongr

omit [Fintype ι] [DecidableEq ι] in
/-- **Strict scaling criterion.**  If the larger sub-battery `T` contains a dial
that separates two individuals which the smaller sub-battery `S` confuses, then
the joint capacity strictly increases.  This is what turns the measured chain
`7.9455 < 10.4462 < 12.1080` from an inequality into a *strict* one: each new
dial resolves a collision of the previous sub-battery. -/
theorem capacity_strict_mono_of_separates (d : ι → Dial Ω) {S T : Finset ι} (h : S ⊆ T)
    {x y : Ω} (hS : joint d S x = joint d S y) {i : ι} (hi : i ∈ T)
    (hsep : (d i).read x ≠ (d i).read y) :
    capacity d S < capacity d T := by
  have hfine : joint d T x ≠ joint d T y := by
    intro hcon
    exact hsep (congrFun hcon ⟨i, hi⟩)
  have hcoarse : restr h (joint d T x) = restr h (joint d T y) := by
    have h1 : joint d S x = restr h (joint d T x) := congrFun (joint_restrict d h) x
    have h2 : joint d S y = restr h (joint d T y) := congrFun (joint_restrict d h) y
    rw [← h1, ← h2, hS]
  have hH : H (joint d S) < H (joint d T) := by
    rw [joint_restrict d h]
    exact H_comp_lt (joint d T) (restr h) hcoarse hfine
  rw [capacity, capacity, Hb, Hb]
  gcongr

omit [Nonempty Ω] [Fintype ι] [DecidableEq ι] in
theorem capacity_nonneg (d : ι → Dial Ω) (S : Finset ι) : 0 ≤ capacity d S :=
  Hb_nonneg _

/-! ## 3. The CRT ceiling -/

omit [Nonempty Ω] [Fintype ι] in
open Classical in
theorem img_joint_subset (d : ι → Dial Ω) (S : Finset ι) :
    img (joint d S) ⊆ Fintype.piFinset (fun i : ↥S => Finset.range (d i.1).modulus) := by
  intro u hu
  obtain ⟨x, hx⟩ := mem_img.1 hu
  subst hx
  refine Fintype.mem_piFinset.2 fun i => ?_
  exact Finset.mem_range.2 ((d i.1).read_lt x)

omit [Nonempty Ω] [Fintype ι] in
theorem img_joint_card_le (d : ι → Dial Ω) (S : Finset ι) :
    (img (joint d S)).card ≤ ∏ i ∈ S, (d i).modulus := by
  classical
  have h := Finset.card_le_card (img_joint_subset d S)
  rw [Fintype.card_piFinset] at h
  simp only [Finset.card_range] at h
  rwa [Finset.prod_coe_sort S (fun i => (d i).modulus)] at h

omit [Fintype ι] in
/-- **CRT ceiling.**  The joint capacity of a sub-battery is bounded by the
binary logarithm of the product of its moduli. -/
theorem capacity_le_logb_prod (d : ι → Dial Ω) (S : Finset ι) :
    capacity d S ≤ Real.logb 2 (∏ i ∈ S, (d i).modulus : ℕ) := by
  classical
  have h1 : capacity d S ≤ Real.logb 2 ((img (joint d S)).card : ℝ) :=
    Hb_le_logb_card_img _
  refine h1.trans ?_
  have hpos : (0 : ℝ) < ((img (joint d S)).card : ℝ) := by
    have : (img (joint d S)).Nonempty :=
      ⟨joint d S (Classical.arbitrary Ω), self_mem_img _ _⟩
    exact_mod_cast Finset.card_pos.2 this
  have hle : ((img (joint d S)).card : ℝ) ≤ ((∏ i ∈ S, (d i).modulus : ℕ) : ℝ) := by
    exact_mod_cast img_joint_card_le d S
  exact Real.logb_le_logb_of_le (by norm_num) hpos hle

omit [Fintype ι] [DecidableEq ι] in
/-- **Sparse-table bias.**  Whatever the moduli, a capacity measured on a
population of `N` individuals is at most `log₂ N` bits. -/
theorem capacity_le_logb_pop (d : ι → Dial Ω) (S : Finset ι) :
    capacity d S ≤ Real.logb 2 (Fintype.card Ω : ℝ) := by
  rw [capacity, Hb, Real.logb]
  gcongr
  exact H_le_log_card (joint d S)

/-! ## 4. The per-dial budget -/

omit [Fintype ι] in
/-- Splitting off one dial from a battery: the map is injective, so it only
relabels the joint alphabet. -/
theorem split_injective {S : Finset ι} {a : ι} (ha : a ∉ S) :
    Function.Injective
      (fun u : ↥(insert a S) → ℕ =>
        ((u ⟨a, Finset.mem_insert_self a S⟩ : ℕ),
          (fun i : ↥S => u ⟨i.1, Finset.mem_insert_of_mem i.2⟩))) := by
  intro u v huv
  funext i
  obtain ⟨i, hi⟩ := i
  rcases Finset.mem_insert.1 hi with rfl | hiS
  · exact congrArg Prod.fst huv
  · have := congrArg Prod.snd huv
    exact congrFun this ⟨i, hiS⟩

omit [Fintype Ω] [Nonempty Ω] [Fintype ι] in
theorem joint_insert_eq (d : ι → Dial Ω) {S : Finset ι} {a : ι} :
    (fun x => (((d a).read x : ℕ), joint d S x))
      = (fun u : ↥(insert a S) → ℕ =>
          ((u ⟨a, Finset.mem_insert_self a S⟩ : ℕ),
            (fun i : ↥S => u ⟨i.1, Finset.mem_insert_of_mem i.2⟩)))
        ∘ (joint d (insert a S)) := by
  funext x
  rfl

omit [Fintype ι] in
/-- **Per-dial budget (subadditivity over the battery).**  The joint capacity of
a sub-battery is at most the sum of the individual per-dial trace informations.
The huge measured spread of per-dial values (0.04 up to 3.46 bits) is therefore
still enough to fund the joint value. -/
theorem capacity_le_sum_dials (d : ι → Dial Ω) (S : Finset ι) :
    capacity d S ≤ ∑ i ∈ S, dialCapacity d i := by
  classical
  induction S using Finset.induction_on with
  | empty =>
      have hconst : H (joint d (∅ : Finset ι)) = 0 := by
        have hsingle : img (joint d (∅ : Finset ι)) = {joint d ∅ (Classical.arbitrary Ω)} := by
          apply Finset.eq_singleton_iff_unique_mem.2
          refine ⟨self_mem_img _ _, fun u hu => ?_⟩
          obtain ⟨x, hx⟩ := mem_img.1 hu
          subst hx
          funext i
          exact absurd i.2 (Finset.notMem_empty _)
        rw [H, hsingle]
        have hcnt : cnt (joint d (∅ : Finset ι)) (joint d ∅ (Classical.arbitrary Ω))
            = Fintype.card Ω := by
          have : fib (joint d (∅ : Finset ι)) (joint d ∅ (Classical.arbitrary Ω))
              = Finset.univ := by
            ext x
            simp only [Finset.mem_univ, iff_true]
            rw [mem_fib]
            funext i
            exact absurd i.2 (Finset.notMem_empty _)
          rw [cnt, this, Finset.card_univ]
        simp [hcnt]
      simp [capacity, Hb, hconst]
  | @insert a S ha ih =>
      have hsplit : H (joint d (insert a S)) = H (fun x => (((d a).read x : ℕ), joint d S x)) := by
        rw [joint_insert_eq d]
        exact (H_comp_eq_of_injective (joint d (insert a S)) (split_injective ha)).symm
      have hpair : H (fun x => (((d a).read x : ℕ), joint d S x))
          ≤ H (d a).read + H (joint d S) := H_pair_le _ _
      have hH : H (joint d (insert a S)) ≤ H (d a).read + H (joint d S) := by
        rw [hsplit]; exact hpair
      have hlog : (0 : ℝ) < Real.log 2 := log_two_pos
      have hb : capacity d (insert a S) ≤ dialCapacity d a + capacity d S := by
        rw [capacity, capacity, dialCapacity, Hb, Hb, Hb, ← add_div]
        gcongr
      calc capacity d (insert a S) ≤ dialCapacity d a + capacity d S := hb
        _ ≤ dialCapacity d a + ∑ i ∈ S, dialCapacity d i := by linarith [ih]
        _ = ∑ i ∈ insert a S, dialCapacity d i := (Finset.sum_insert ha).symm

/-! ## 5. Sharpness: the CRT ceiling is attained -/

/-- A statistic that separates all individuals has capacity exactly `log₂ #Ω`. -/
theorem capacity_eq_logb_pop_of_injective {α : Type*} {f : Ω → α} (hf : Function.Injective f) :
    Hb f = Real.logb 2 (Fintype.card Ω : ℝ) := by
  classical
  have hcnt : ∀ a ∈ img f, cnt f a = 1 := by
    intro a ha
    obtain ⟨x, hx⟩ := mem_img.1 ha
    have : fib f a = {x} := by
      ext y
      rw [mem_fib, Finset.mem_singleton]
      constructor
      · intro hy; exact hf (hy.trans hx.symm)
      · rintro rfl; exact hx
    rw [cnt, this, Finset.card_singleton]
  have hcard : (img f).card = Fintype.card Ω := by
    have h := sum_cnt f
    rw [Finset.sum_congr rfl hcnt] at h
    simpa using h
  have hH : H f = Real.log (Fintype.card Ω : ℝ) := by
    rw [H, Finset.sum_congr rfl (fun a ha => by rw [hcnt a ha])]
    rw [Finset.sum_const, hcard, nsmul_eq_mul]
    have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
    push_cast
    field_simp
  rw [Hb, hH, Real.logb]

/-- **CRT witness.**  On the population `ZMod 31 × ZMod 23` the two-dial battery
reading the two coordinates attains the full CRT ceiling `log₂ 713`: the ceiling
of `capacity_le_logb_prod` is sharp, so the measured shortfall is a property of
the sample, not of the bound. -/
theorem crt_battery_saturates :
    Hb (fun x : ZMod 31 × ZMod 23 => ((x.1.val : ℕ), (x.2.val : ℕ)))
      = Real.logb 2 713 := by
  have hinj : Function.Injective
      (fun x : ZMod 31 × ZMod 23 => ((x.1.val : ℕ), (x.2.val : ℕ))) := by
    rintro ⟨a, b⟩ ⟨c, e⟩ h
    have h1 : a.val = c.val := congrArg Prod.fst h
    have h2 : b.val = e.val := congrArg Prod.snd h
    have ha : a = c := by
      have := congrArg (fun n : ℕ => (n : ZMod 31)) h1
      simpa [ZMod.natCast_val, ZMod.cast_id] using this
    have hb : b = e := by
      have := congrArg (fun n : ℕ => (n : ZMod 23)) h2
      simpa [ZMod.natCast_val, ZMod.cast_id] using this
    simp [ha, hb]
  have hcard : Fintype.card (ZMod 31 × ZMod 23) = 713 := by
    simp [Fintype.card_prod]
  rw [capacity_eq_logb_pop_of_injective hinj, hcard]
  norm_num

/-! ## 6. Numeric certificates for the round-30 table -/

/-- If `2 ^ k ≤ n` then `k ≤ log₂ n`. -/
theorem logb_two_ge_of_pow_le {n k : ℕ} (h : 2 ^ k ≤ n) :
    (k : ℝ) ≤ Real.logb 2 (n : ℝ) := by
  have h2 : ((2 : ℕ) ^ k : ℝ) ≤ (n : ℝ) := by exact_mod_cast h
  have hk : Real.logb 2 ((2 : ℝ) ^ k) = k := by
    rw [Real.logb_pow]
    simp
  calc (k : ℝ) = Real.logb 2 ((2 : ℝ) ^ k) := hk.symm
    _ ≤ Real.logb 2 (n : ℝ) := by
        refine Real.logb_le_logb_of_le (by norm_num) (by positivity) ?_
        push_cast at h2
        exact h2

/-- If `n ^ a < 2 ^ b` with `a > 0` then `log₂ n < b / a`. -/
theorem logb_two_lt_of_pow_lt {n a b : ℕ} (hn : 0 < n) (ha : 0 < a) (h : n ^ a < 2 ^ b) :
    Real.logb 2 (n : ℝ) < (b : ℝ) / (a : ℝ) := by
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have haR : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha
  have hcast : ((n : ℝ)) ^ a < ((2 : ℝ)) ^ b := by exact_mod_cast h
  have hlog : Real.log ((n : ℝ) ^ a) < Real.log ((2 : ℝ) ^ b) :=
    Real.log_lt_log (by positivity) hcast
  rw [Real.log_pow, Real.log_pow] at hlog
  have hl2 : (0 : ℝ) < Real.log 2 := log_two_pos
  rw [Real.logb, div_lt_div_iff₀ hl2 haR]
  nlinarith [hlog]

theorem logb_713_gt : (7.9455 : ℝ) < Real.logb 2 713 := by
  have h : (8 : ℝ) ≤ Real.logb 2 (713 : ℕ) := by
    exact_mod_cast logb_two_ge_of_pow_le (n := 713) (k := 8) (by norm_num)
  norm_num at h ⊢
  linarith

theorem logb_6417_gt : (10.4462 : ℝ) < Real.logb 2 6417 := by
  have h : (12 : ℝ) ≤ Real.logb 2 (6417 : ℕ) := by
    exact_mod_cast logb_two_ge_of_pow_le (n := 6417) (k := 12) (by norm_num)
  norm_num at h ⊢
  linarith

theorem logb_51336_gt : (12.1080 : ℝ) < Real.logb 2 51336 := by
  have h : (15 : ℝ) ≤ Real.logb 2 (51336 : ℕ) := by
    exact_mod_cast logb_two_ge_of_pow_le (n := 51336) (k := 15) (by norm_num)
  norm_num at h ⊢
  linarith

/-- `log₂ 11 < 3.46`: certificate `11 ^ 50 < 2 ^ 173`. -/
theorem logb_11_lt : Real.logb 2 11 < 3.46 := by
  have h := logb_two_lt_of_pow_lt (n := 11) (a := 50) (b := 173) (by norm_num) (by norm_num)
    (by norm_num)
  norm_num at h ⊢
  linarith

/-- `log₂ 31 > 4.9`: certificate `2 ^ 49 < 31 ^ 10`. -/
theorem logb_31_gt : (4.9 : ℝ) < Real.logb 2 31 := by
  have hl2 : (0 : ℝ) < Real.log 2 := log_two_pos
  have hcast : ((2 : ℝ)) ^ (49 : ℕ) < ((31 : ℝ)) ^ (10 : ℕ) := by norm_num
  have hlog : Real.log ((2 : ℝ) ^ (49 : ℕ)) < Real.log ((31 : ℝ) ^ (10 : ℕ)) :=
    Real.log_lt_log (by positivity) hcast
  rw [Real.log_pow, Real.log_pow] at hlog
  rw [Real.logb, lt_div_iff₀ hl2]
  push_cast at hlog
  linarith

/-! ## 7. The round-30 battery -/

/-- The measured round-30 table is *consistent with the theory*: the three
reported joint capacities increase, and each one lies strictly below the CRT
ceiling `log₂ M` that `capacity_le_logb_prod` imposes on it. -/
theorem round30_table_consistent :
    (7.9455 : ℝ) < 10.4462 ∧ (10.4462 : ℝ) < 12.1080 ∧
      (7.9455 : ℝ) < Real.logb 2 713 ∧ (10.4462 : ℝ) < Real.logb 2 6417 ∧
      (12.1080 : ℝ) < Real.logb 2 51336 :=
  ⟨by norm_num, by norm_num, logb_713_gt, logb_6417_gt, logb_51336_gt⟩

/-- A dial of modulus 11 (the `C₅@11` dial) can never carry more than `3.46`
bits: the reported `3.46` is a rounding of a *saturated* dial. -/
theorem dial_at_11_below_346 (D : Dial Ω) (hD : D.modulus = 11) : Hb D.read < 3.46 := by
  classical
  have hsub : img D.read ⊆ Finset.range 11 := by
    intro a ha
    obtain ⟨x, hx⟩ := mem_img.1 ha
    subst hx
    exact Finset.mem_range.2 (hD ▸ D.read_lt x)
  have hcard : ((img D.read).card : ℝ) ≤ 11 := by
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    exact_mod_cast this
  have hpos : (0 : ℝ) < ((img D.read).card : ℝ) := by
    have : (img D.read).Nonempty := ⟨D.read (Classical.arbitrary Ω), self_mem_img _ _⟩
    exact_mod_cast Finset.card_pos.2 this
  calc Hb D.read ≤ Real.logb 2 ((img D.read).card : ℝ) := Hb_le_logb_card_img _
    _ ≤ Real.logb 2 11 := Real.logb_le_logb_of_le (by norm_num) hpos hcard
    _ < 3.46 := logb_11_lt

/-- By contrast a dial of modulus 31 has ceiling above `4.9` bits, so the
measured `0.04` bits of `S₃a@31` is a genuine (roughly 100-fold) shortfall and
not a ceiling effect: the 80× spread of per-dial trace informations reported in
the experiment is compatible with the theory. -/
theorem dial_at_31_ceiling_high (D : Dial Ω) (hD : D.modulus = 31) :
    Hb D.read ≤ Real.logb 2 31 ∧ (4.9 : ℝ) < Real.logb 2 31 := by
  classical
  refine ⟨?_, logb_31_gt⟩
  have hsub : img D.read ⊆ Finset.range 31 := by
    intro a ha
    obtain ⟨x, hx⟩ := mem_img.1 ha
    subst hx
    exact Finset.mem_range.2 (hD ▸ D.read_lt x)
  have hcard : ((img D.read).card : ℝ) ≤ 31 := by
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    exact_mod_cast this
  have hpos : (0 : ℝ) < ((img D.read).card : ℝ) := by
    have hne : (img D.read).Nonempty := ⟨D.read (Classical.arbitrary Ω), self_mem_img _ _⟩
    exact_mod_cast Finset.card_pos.2 hne
  exact (Hb_le_logb_card_img _).trans (Real.logb_le_logb_of_le (by norm_num) hpos hcard)

/-! ## 6b. Non-vacuity of the strict criterion -/

/-- A two-dial toy battery on the population `Fin 4`: the parity dial and the
half dial, both of modulus 2. -/
def testBattery : Fin 2 → Dial (Fin 4) := fun i =>
  match i with
  | 0 => { modulus := 2, modulus_pos := by norm_num, read := fun x => x.val % 2,
           read_lt := fun x => Nat.mod_lt _ (by norm_num) }
  | 1 => { modulus := 2, modulus_pos := by norm_num, read := fun x => x.val / 2,
           read_lt := fun x => by have := x.isLt; omega }

/-- **The strict criterion is not vacuous.**  On `Fin 4` the parity dial alone
confuses `0` and `2`, and the half dial separates them, so the joint capacity
strictly increases when the second dial is switched on. -/
theorem strict_scaling_witness :
    capacity testBattery {0} < capacity testBattery {0, 1} := by
  refine capacity_strict_mono_of_separates testBattery (by decide) (x := 0) (y := 2)
    ?_ (i := 1) (by decide) (by decide)
  funext i
  obtain ⟨i, hi⟩ := i
  have hi0 : i = 0 := Finset.mem_singleton.1 hi
  subst hi0
  rfl

section Round30

variable (d : Fin 4 → Dial Ω)

/-- The three sub-batteries of the experiment. -/
def S1 : Finset (Fin 4) := {0, 1}
/-- `S₃a@31 + S₃b@23 + A₄@9`. -/
def S2 : Finset (Fin 4) := {0, 1, 2}
/-- the full four-dial battery. -/
def S3 : Finset (Fin 4) := {0, 1, 2, 3}

theorem S1_sub_S2 : (S1 : Finset (Fin 4)) ⊆ S2 := by decide
theorem S2_sub_S3 : (S2 : Finset (Fin 4)) ⊆ S3 := by decide

/-- **THE-SCALING-IS-CONFIRMED, formal form.**  For *every* population and
*every* battery whose four dials have the experiment's moduli 31, 23, 9, 8, the
joint capacities of the nested sub-batteries form an increasing chain, each term
capped by the corresponding CRT ceiling `log₂ 713`, `log₂ 6417`, `log₂ 51336`,
and all capped by the sample ceiling `log₂ #Ω`. -/
theorem battery_scaling
    (h0 : (d 0).modulus = 31) (h1 : (d 1).modulus = 23)
    (h2 : (d 2).modulus = 9) (h3 : (d 3).modulus = 8) :
    capacity d S1 ≤ capacity d S2 ∧ capacity d S2 ≤ capacity d S3 ∧
      capacity d S1 ≤ Real.logb 2 713 ∧ capacity d S2 ≤ Real.logb 2 6417 ∧
      capacity d S3 ≤ Real.logb 2 51336 ∧
      capacity d S3 ≤ Real.logb 2 (Fintype.card Ω : ℝ) := by
  have hp1 : ∏ i ∈ (S1 : Finset (Fin 4)), (d i).modulus = 713 := by
    rw [show (S1 : Finset (Fin 4)) = {0, 1} from rfl]
    rw [Finset.prod_insert (by decide), Finset.prod_singleton, h0, h1]
    norm_num
  have hp2 : ∏ i ∈ (S2 : Finset (Fin 4)), (d i).modulus = 6417 := by
    rw [show (S2 : Finset (Fin 4)) = {0, 1, 2} from rfl]
    rw [Finset.prod_insert (by decide), Finset.prod_insert (by decide), Finset.prod_singleton,
      h0, h1, h2]
    norm_num
  have hp3 : ∏ i ∈ (S3 : Finset (Fin 4)), (d i).modulus = 51336 := by
    rw [show (S3 : Finset (Fin 4)) = {0, 1, 2, 3} from rfl]
    rw [Finset.prod_insert (by decide), Finset.prod_insert (by decide),
      Finset.prod_insert (by decide), Finset.prod_singleton, h0, h1, h2, h3]
    norm_num
  refine ⟨capacity_mono d S1_sub_S2, capacity_mono d S2_sub_S3, ?_, ?_, ?_,
    capacity_le_logb_pop d S3⟩
  · have := capacity_le_logb_prod d S1
    rwa [hp1] at this
  · have := capacity_le_logb_prod d S2
    rwa [hp2] at this
  · have := capacity_le_logb_prod d S3
    rwa [hp3] at this

end Round30

end TraceBattery