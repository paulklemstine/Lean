/-
# BATTERY-SYNERGY, part VII: the `k`-dial overlap law

Part V settled two dials: `Δ = I(f ; g | L) − I(f ; g)`.  The verdict of
round-27 #1 claims more, namely that *"the converse's no-pinning scope covers
product batteries with their synergy excesses included: `k` dials give more than
`k · (marginal)` for structurally rich pairs and less for shared-structure
pairs"*.  That is a statement about batteries of arbitrary width, and this file
proves it exactly.

For a family of readings `f : ι → Ω → ℕ` and a finite set `S` of dials put

* `totalCorr f S = Σ_{i ∈ S} H(fᵢ) − H(joint)` — the **total correlation** of
  the readings: the shared structure of the dials (zero iff the readings are
  jointly independent);
* `condTotalCorr L f S = Σ_{i ∈ S} H(fᵢ | L) − H(joint | L)` — the same quantity
  measured inside the label classes;
* `multiSynergy L f S = I(L ; joint) − Σ_{i ∈ S} I(L ; fᵢ)` — the width-`k`
  analogue of the paper-91 `Δ`.

The results:

* `MultiDial.multi_coinformation_identity` — the **width-`k` co-information
  law**, an exact identity valid for every `k`:

  `multiSynergy = condTotalCorr − totalCorr`;

* `MultiDial.condTotalCorr_nonneg` and `MultiDial.totalCorr_nonneg` — both
  correlation terms are nonnegative (proved by induction on the battery from the
  data processing inequality of part I, via the two-dial conditional
  subadditivity `condH_pair_le`);

* `MultiDial.multiSynergy_ge_neg_totalCorr` — **the `k`-dial overlap bound**: a
  battery of any width can undershoot the additive prediction by at most the
  total correlation of its readings.  Dials that share structure (two cubics of
  the same discriminant) are exactly the dials with large `totalCorr`;

* `MultiDial.multiSynergy_nonneg_of_reads_independent` — a battery of
  *independent* readings is super-additive at every width: truly independent
  dials can only add value, and the `+0.129` of the first row is the generic
  behaviour, not an anomaly;

* `MultiDial.synergy_ge_neg_totalCorrb` and
  `MultiDial.synergy_nonneg_of_reads_independent` — the same statements for
  `BatterySynergy.synergy` of part II, i.e. for the measured quantity in bits.

Together with part VI (which realises both signs at their extreme values) this
closes the width question: the battery space is a two-sided object whose
deviation from additivity is *bracketed by the correlation of the dials*, in
both directions, at every width.
-/
import Mathlib
import MachineLearning.BatterySynergy.CoInformation

namespace BatterySynergy

namespace MultiDial

open TraceBattery Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} {ι : Type*} [DecidableEq ι]

/-! ## 1. The masked joint reading of a sub-battery -/

/-- The joint reading of the dials in `S`, presented as a total function on the
index type (dials outside `S` read `0`).  This is the same partition of the
population as `TraceBattery.joint`, in a form that supports induction on `S`. -/
def jread (f : ι → Ω → ℕ) (S : Finset ι) : Ω → (ι → ℕ) :=
  fun x i => if i ∈ S then f i x else 0

omit [Fintype Ω] [Nonempty Ω] in
theorem jread_empty (f : ι → Ω → ℕ) (x y : Ω) : jread f ∅ x = jread f ∅ y := by
  funext i
  simp [jread]

omit [Fintype Ω] [Nonempty Ω] in
/-- Adding one dial to a sub-battery refines the joint reading exactly as
pairing with that dial's reading does. -/
theorem jread_insert_fibers (f : ι → Ω → ℕ) {a : ι} {S : Finset ι} (ha : a ∉ S) (x y : Ω) :
    jread f (insert a S) x = jread f (insert a S) y ↔
      pair (f a) (jread f S) x = pair (f a) (jread f S) y := by
  constructor
  · intro h
    have hcoord : ∀ i, (if i ∈ insert a S then f i x else 0)
        = (if i ∈ insert a S then f i y else 0) := fun i => congrFun h i
    have hfa : f a x = f a y := by
      have := hcoord a
      rwa [if_pos (Finset.mem_insert_self a S), if_pos (Finset.mem_insert_self a S)] at this
    have hjs : jread f S x = jread f S y := by
      funext i
      show (if i ∈ S then f i x else 0) = (if i ∈ S then f i y else 0)
      by_cases hi : i ∈ S
      · have hc := hcoord i
        rw [if_pos (Finset.mem_insert_of_mem hi), if_pos (Finset.mem_insert_of_mem hi)] at hc
        simp [hi, hc]
      · simp [hi]
    simp only [pair, Prod.mk.injEq]
    exact ⟨hfa, hjs⟩
  · intro h
    have h1 : f a x = f a y := congrArg Prod.fst h
    have h2 : jread f S x = jread f S y := congrArg Prod.snd h
    funext i
    simp only [jread, Finset.mem_insert]
    by_cases hia : i = a
    · subst hia; simp [h1]
    · by_cases hi : i ∈ S
      · have := congrFun h2 i
        simp only [jread, if_pos hi] at this
        simp [hia, hi, this]
      · simp [hia, hi]

theorem H_jread_insert (f : ι → Ω → ℕ) {a : ι} {S : Finset ι} (ha : a ∉ S) :
    H (jread f (insert a S)) = H (pair (f a) (jread f S)) :=
  H_eq_of_same_fibers _ _ (jread_insert_fibers f ha)

theorem H_pr_jread_insert (L : Ω → Λ) (f : ι → Ω → ℕ) {a : ι} {S : Finset ι} (ha : a ∉ S) :
    H (pr (jread f (insert a S)) L) = H (pr (pair (f a) (jread f S)) L) := by
  refine H_eq_of_same_fibers _ _ fun x y => ?_
  simp only [pr, Prod.mk.injEq]
  constructor
  · rintro ⟨hj, hL⟩
    exact ⟨(jread_insert_fibers f ha x y).1 hj, hL⟩
  · rintro ⟨hp, hL⟩
    exact ⟨(jread_insert_fibers f ha x y).2 hp, hL⟩

/-! ## 2. Total correlation, conditional total correlation, width-`k` synergy -/

/-- The **total correlation** of the readings of a sub-battery: the shared
structure of its dials. -/
noncomputable def totalCorr (f : ι → Ω → ℕ) (S : Finset ι) : ℝ :=
  (∑ i ∈ S, H (f i)) - H (jread f S)

/-- The total correlation of the readings **inside the label classes**. -/
noncomputable def condTotalCorr (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) : ℝ :=
  (∑ i ∈ S, condH (f i) L) - condH (jread f S) L

/-- The **width-`k` synergy**: the excess of the joint capacity over the additive
prediction of the marginals. -/
noncomputable def multiSynergy (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) : ℝ :=
  MI L (jread f S) - ∑ i ∈ S, MI L (f i)

/-! ## 3. Conditional subadditivity for two statistics -/

/-- `H(u, v | L) ≤ H(u | L) + H(v | L)`: conditioning does not destroy
subadditivity.  Equivalent to the nonnegativity of the conditional dependence of
part V, hence ultimately to the data processing inequality. -/
theorem condH_pair_le {α β : Type*} (L : Ω → Λ) (u : Ω → α) (v : Ω → β) :
    condH (pair u v) L ≤ condH u L + condH v L := by
  have hcm := condMI_nonneg L u v
  have htri : H (pr (pair u v) L) = H (tri L u v) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, pair, tri, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨hu, hv⟩, hL⟩; exact ⟨hL, hu, hv⟩
    · rintro ⟨hL, hu, hv⟩; exact ⟨⟨hu, hv⟩, hL⟩
  have hu : H (pr u L) = H (pr L u) := H_swap_pr L u
  have hv : H (pr v L) = H (pr L v) := H_swap_pr L v
  simp only [condMI] at hcm
  simp only [condH, htri, hu, hv]
  linarith

/-! ## 4. Both correlation terms are nonnegative -/

/-- **Subadditivity of the battery code**: the joint reading of a sub-battery has
entropy at most the sum of the entropies of its dials. -/
theorem totalCorr_nonneg (f : ι → Ω → ℕ) (S : Finset ι) : 0 ≤ totalCorr f S := by
  classical
  induction S using Finset.induction_on with
  | empty =>
      have hH : H (jread f ∅) = 0 := by
        have h := MI_eq_zero_of_const (L := jread f ∅) (f := jread f ∅) (fun x y => jread_empty f x y)
        have hdet : ∀ x y : Ω, jread f ∅ x = jread f ∅ y → jread f ∅ x = jread f ∅ y :=
          fun _ _ h => h
        have hself : MI (jread f ∅) (jread f ∅) = H (jread f ∅) :=
          MI_eq_label_entropy_of_determines _ _ hdet
        rw [hself] at h
        exact h
      simp [totalCorr, hH]
  | insert a S ha ih =>
      have hstep : H (jread f (insert a S)) ≤ H (f a) + H (jread f S) := by
        rw [H_jread_insert f ha]
        exact H_pair_le (f a) (jread f S)
      rw [totalCorr, Finset.sum_insert ha]
      rw [totalCorr] at ih
      linarith

/-- **Conditional subadditivity of the battery code**: the same statement inside
the label classes.  Proved by induction from `condH_pair_le`. -/
theorem condTotalCorr_nonneg (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) :
    0 ≤ condTotalCorr L f S := by
  classical
  induction S using Finset.induction_on with
  | empty =>
      have hconst : ∀ x y : Ω, jread f ∅ x = jread f ∅ y := jread_empty f
      have hpr : H (pr (jread f ∅) L) = H L := by
        refine H_eq_of_same_fibers _ _ fun x y => ?_
        simp only [pr, Prod.mk.injEq]
        exact ⟨fun h => h.2, fun h => ⟨hconst x y, h⟩⟩
      simp [condTotalCorr, condH, hpr]
  | insert a S ha ih =>
      have hstep : condH (jread f (insert a S)) L ≤ condH (f a) L + condH (jread f S) L := by
        have hEq : condH (jread f (insert a S)) L = condH (pair (f a) (jread f S)) L := by
          simp only [condH, H_pr_jread_insert L f ha]
        rw [hEq]
        exact condH_pair_le L (f a) (jread f S)
      rw [condTotalCorr, Finset.sum_insert ha]
      rw [condTotalCorr] at ih
      linarith

/-! ## 5. The width-`k` co-information law -/

/-- **The width-`k` co-information law.**  For a battery of any width the excess
over the additive prediction is exactly the difference between the conditional
and the unconditional total correlation of its readings:

`I(L ; joint) − Σ I(L ; fᵢ) = TC(f | L) − TC(f)`.

For `|S| = 2` this is the identity of part V. -/
theorem multi_coinformation_identity (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) :
    multiSynergy L f S = condTotalCorr L f S - totalCorr f S := by
  classical
  have hmarg : ∀ i ∈ S, condH (f i) L = H (pr L (f i)) - H L := by
    intro i _
    rw [condH, H_swap_pr L (f i)]
  have hjoint : condH (jread f S) L = H (pr L (jread f S)) - H L := by
    rw [condH, H_swap_pr L (jread f S)]
  have hMI : ∀ i ∈ S, MI L (f i) = H L + H (f i) - H (pr L (f i)) := by
    intro i _
    exact MI_eq L (f i)
  rw [multiSynergy, condTotalCorr, totalCorr, Finset.sum_congr rfl hmarg,
    Finset.sum_congr rfl hMI, hjoint, MI_eq]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  simp only [Finset.sum_const, nsmul_eq_mul]
  ring

/-! ## 6. The `k`-dial overlap bound -/

/-- **The `k`-dial overlap bound.**  A battery of any width undershoots the
additive prediction by at most the total correlation of its dial readings: the
overlap of a battery is paid for out of the structure its dials share. -/
theorem multiSynergy_ge_neg_totalCorr (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) :
    -totalCorr f S ≤ multiSynergy L f S := by
  have h := condTotalCorr_nonneg L f S
  rw [multi_coinformation_identity]
  linarith

/-- **Independent dials are super-additive at every width.**  If the readings
carry no shared structure then a battery of any width carries at least the sum
of its marginals. -/
theorem multiSynergy_nonneg_of_reads_independent (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι)
    (h : totalCorr f S = 0) : 0 ≤ multiSynergy L f S := by
  have := multiSynergy_ge_neg_totalCorr L f S
  rw [h] at this
  linarith

/-- Synergy at width `k` is bounded above by the conditional total correlation:
the joint modulus can only extract what the label classes still correlate. -/
theorem multiSynergy_le_condTotalCorr (L : Ω → Λ) (f : ι → Ω → ℕ) (S : Finset ι) :
    multiSynergy L f S ≤ condTotalCorr L f S := by
  have h := totalCorr_nonneg f S
  rw [multi_coinformation_identity]
  linarith

/-! ## 7. The overlap bound is sharp at every width -/

omit [Fintype Ω] [Nonempty Ω] in
/-- A battery all of whose dials read the same statistic `u` reads exactly `u`. -/
theorem jread_const_fibers {u : Ω → ℕ} {f : ι → Ω → ℕ} {S : Finset ι} (hf : ∀ i ∈ S, f i = u)
    (hS : S.Nonempty) (x y : Ω) : jread f S x = jread f S y ↔ u x = u y := by
  obtain ⟨i₀, hi₀⟩ := hS
  constructor
  · intro h
    have hc := congrFun h i₀
    simp only [jread, if_pos hi₀] at hc
    rwa [hf i₀ hi₀] at hc
  · intro h
    funext i
    simp only [jread]
    by_cases hi : i ∈ S
    · simp [hi, hf i hi, h]
    · simp [hi]

/-- **Sharpness of the `k`-dial overlap bound.**  A battery of `k` copies of one
dial, read against that dial's own reading, has total correlation
`(k − 1) · H u` and synergy exactly `−(k − 1) · H u`: the bound
`multiSynergy ≥ -totalCorr` is attained at every width.  This is the width-`k`
form of "same subfield = same dial". -/
theorem multiSynergy_const_eq (u : Ω → ℕ) (f : ι → Ω → ℕ) (S : Finset ι)
    (hf : ∀ i ∈ S, f i = u) (hS : S.Nonempty) :
    totalCorr f S = ((S.card : ℝ) - 1) * H u ∧
      multiSynergy u f S = -(((S.card : ℝ) - 1) * H u) ∧
      multiSynergy u f S = -totalCorr f S := by
  have hfib := jread_const_fibers hf hS
  have hH : H (jread f S) = H u := H_eq_of_same_fibers _ _ hfib
  have hMIj : MI u (jread f S) = H u :=
    MI_eq_label_entropy_of_determines u _ fun x y h => (hfib x y).1 h
  have hMIi : ∀ i ∈ S, MI u (f i) = H u := by
    intro i hi
    rw [hf i hi]
    exact MI_eq_label_entropy_of_determines u u fun _ _ h => h
  have htc : totalCorr f S = ((S.card : ℝ) - 1) * H u := by
    rw [totalCorr, hH, Finset.sum_congr rfl (fun i hi => congrArg H (hf i hi)),
      Finset.sum_const, nsmul_eq_mul]
    ring
  have hms : multiSynergy u f S = -(((S.card : ℝ) - 1) * H u) := by
    rw [multiSynergy, hMIj, Finset.sum_congr rfl hMIi, Finset.sum_const, nsmul_eq_mul]
    ring
  exact ⟨htc, hms, by rw [hms, htc]⟩

/-! ## 8. Bridge to the measured quantity of part II -/

section Bridge

variable (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι)

omit [Fintype Ω] [Nonempty Ω] in
/-- The masked joint reading and `TraceBattery.joint` induce the same partition
of the population. -/
theorem joint_jread_fibers (x y : Ω) :
    joint d S x = joint d S y ↔
      jread (fun i => (d i).read) S x = jread (fun i => (d i).read) S y := by
  constructor
  · intro h
    funext i
    simp only [jread]
    by_cases hi : i ∈ S
    · simpa [hi] using congrFun h ⟨i, hi⟩
    · simp [hi]
  · intro h
    funext i
    have := congrFun h i.1
    simpa [jread, i.2] using this

theorem info_eq_multi : info d L S = MIb L (jread (fun i => (d i).read) S) := by
  rw [info, MIb, MIb, MI_eq_of_same_fibers L (joint d S) _ (joint_jread_fibers d S)]

/-- The measured synergy of part II is the width-`k` synergy of the readings, in
bits. -/
theorem synergy_eq_multiSynergyb :
    synergy d L S = multiSynergy L (fun i => (d i).read) S / Real.log 2 := by
  have hsingle : ∀ i ∈ S, info d L {i} = MI L (d i).read / Real.log 2 := by
    intro i _
    rw [info_singleton_eq d L i, MIb]
  rw [synergy, info_eq_multi, Finset.sum_congr rfl hsingle, MIb, multiSynergy,
    sub_div, Finset.sum_div]

/-- **The measured `k`-dial overlap bound**, in bits: a battery can fall short of
the additive prediction only by the total correlation of its dials. -/
theorem synergy_ge_neg_totalCorrb :
    -(totalCorr (fun i => (d i).read) S / Real.log 2) ≤ synergy d L S := by
  have hlog := log_two_pos
  rw [synergy_eq_multiSynergyb d L S, ← neg_div]
  exact (div_le_div_iff_of_pos_right hlog).mpr (multiSynergy_ge_neg_totalCorr L _ S)

/-- **Independent dials never overlap**, at any width: if the readings of the
battery carry no shared structure, the measured capacity is at least the sum of
the measured marginals. -/
theorem synergy_nonneg_of_reads_independent (h : totalCorr (fun i => (d i).read) S = 0) :
    0 ≤ synergy d L S := by
  have hlog := log_two_pos
  rw [synergy_eq_multiSynergyb d L S]
  exact div_nonneg (multiSynergy_nonneg_of_reads_independent L _ S h) hlog.le

end Bridge

end MultiDial

end BatterySynergy