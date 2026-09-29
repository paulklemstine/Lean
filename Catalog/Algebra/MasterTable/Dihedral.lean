/-
# MASTER-TABLE (paper 119) — the dihedral columns, for every degree `n`

The non-abelian rows of the master table are the radical fields `x^n - a` with
Galois group `D_n` acting on the `n` roots as on the vertices of the `n`-gon
(`D6TypeChannel.vertexAct`); the splitting type of `p` is the number of roots of
`x^n - a` mod `p`, i.e. `fixCount` of a uniformly random element of `D_n`.

The catalog had this channel only for `n = 6` (paper 122, by enumeration).  This
file computes it **for every `n ≥ 3`** in closed form:

* `fixCount_sr_of_odd` — for odd `n` every reflection fixes exactly one root
  (complementing the catalog's even law `fixCount_sr_of_even`);
* `typeCounts_odd`, `typeCounts_even` — the exact type distributions
  `{0 : n-1, 1 : n, n : 1}` (odd `n`) and `{0 : 3n/2 - 1, 2 : n/2, n : 1}` (even `n`);
* `typeEntropyDn_odd` — **`H(T) = 1 + pinEnt(n)/2` for odd `n`**;
* `typeEntropyDn_even` — `H(T) = log₂ 4m - ((3m-1) log₂ (3m-1) + m log₂ m)/(4m)`
  for `n = 2m`, `m ≥ 2`;
* `rotFibre_eq_rootCountEntropy` — **bridge**: the rotation fibre of the dihedral
  channel *is* the cyclic root-count channel of the same degree;
* `mutInfo_rotSign_odd` — for odd `n` the abelian (rotation-character) dial carries
  **exactly one bit**, and the non-abelian residue is `pinEnt(n)/2`;
* `condEnt_rotSign_even` — for even `n`, `H(T | rotSign) = pinEnt(n)/2 + 1/2`.
-/
import Algebra.MasterTable.Cyclic
import Algebra.D6TypeChannel.Channel

namespace MasterTable

open CyclicTypeChannel D6TypeChannel DihedralGroup Finset

/-! ## 1. Counting on `D_n` -/

section Counting

variable {n : ℕ} [NeZero n]

/-- `D_n` is the disjoint union of its rotations and its reflections. -/
def dihEquiv (n : ℕ) : ZMod n ⊕ ZMod n ≃ DihedralGroup n where
  toFun := Sum.elim r sr
  invFun
    | r i => Sum.inl i
    | sr i => Sum.inr i
  left_inv := by rintro (i | i) <;> rfl
  right_inv := by rintro (i | i) <;> rfl

theorem sum_dihedral {M : Type*} [AddCommMonoid M] (f : DihedralGroup n → M) :
    ∑ g, f g = ∑ i, f (r i) + ∑ i, f (sr i) := by
  rw [← (dihEquiv n).sum_comp, Fintype.sum_sum_type]
  rfl

theorem card_filter_dihedral (P : DihedralGroup n → Prop) [DecidablePred P] :
    #{g | P g} = #{i | P (r i)} + #{i | P (sr i)} := by
  simp only [card_filter]
  exact sum_dihedral _

lemma card_filter_val (P : ℕ → Prop) [DecidablePred P] :
    #{i : ZMod n | P i.val} = #{k ∈ range n | P k} := by
  refine card_nbij' (fun i => i.val) (fun k => (k : ZMod n)) ?_ ?_ ?_ ?_
  · intro i hi
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hi ⊢
    exact ⟨mem_range.2 (ZMod.val_lt i), hi⟩
  · intro k hk
    simp only [coe_filter, mem_range, Set.mem_setOf_eq, mem_univ, true_and] at hk ⊢
    rw [ZMod.val_natCast_of_lt hk.1]
    exact hk.2
  · intro i _
    simp
  · intro k hk
    simp only [coe_filter, mem_range, Set.mem_setOf_eq] at hk
    exact ZMod.val_natCast_of_lt hk.1

lemma card_even_range (m : ℕ) : #{k ∈ range (2 * m) | Even k} = m := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [show 2 * (m + 1) = 2 * m + 1 + 1 by ring, range_add_one, range_add_one, filter_insert,
      filter_insert]
    have h1 : ¬ Even (2 * m + 1) := by simp [parity_simps]
    have h2 : Even (2 * m) := by simp
    rw [if_neg h1, if_pos h2, card_insert_of_notMem (by simp), ih]

lemma card_even_zmod (hn : Even n) : #{i : ZMod n | Even i.val} = n / 2 := by
  rw [card_filter_val]
  obtain ⟨m, hm⟩ := hn
  rw [hm, show m + m = 2 * m by ring, card_even_range]
  omega

lemma card_odd_zmod (hn : Even n) : #{i : ZMod n | ¬ Even i.val} = n / 2 := by
  have h := card_filter_add_card_filter_not (s := (univ : Finset (ZMod n)))
    (fun i : ZMod n => Even i.val)
  rw [card_univ, ZMod.card, card_even_zmod hn] at h
  obtain ⟨m, hm⟩ := hn
  omega

lemma card_ne_zero_zmod : #{i : ZMod n | ¬ i = 0} = n - 1 := by
  rw [filter_not, filter_eq', if_pos (mem_univ _), card_sdiff, card_univ, ZMod.card]
  simp

lemma card_eq_zero_zmod : #{i : ZMod n | i = 0} = 1 := by
  rw [filter_eq', if_pos (mem_univ _), card_singleton]

end Counting

/-! ## 2. The fixed-point law of `D_n` -/

section FixedPoints

variable {n : ℕ} [NeZero n]

/-- **The reflection law for odd `n`**: every reflection of an odd polygon fixes
exactly one vertex (for `x^n - a`: exactly one root of a reflection Frobenius). -/
theorem fixCount_sr_of_odd (hn : Odd n) (i : ZMod n) : fixCount (sr i) = 1 := by
  rw [fixCount_sr_eq]
  have hu : IsUnit (2 : ZMod n) := by
    simpa using (ZMod.isUnit_iff_coprime 2 n).2 (Nat.coprime_two_left.2 hn)
  obtain ⟨u, hu⟩ := hu
  rw [card_eq_one]
  refine ⟨↑u⁻¹ * -i, ?_⟩
  ext x
  simp only [mem_filter, mem_univ, true_and, mem_singleton]
  rw [← hu, Units.eq_inv_mul_iff_mul_eq]

lemma fixCount_r_eq_zero_iff (i : ZMod n) : fixCount (r i) = 0 ↔ ¬ i = 0 := by
  rw [fixCount_r]
  split_ifs with h <;> simp [h, NeZero.ne n]

lemma fixCount_r_eq_self_iff (i : ZMod n) : fixCount (r i) = n ↔ i = 0 := by
  rw [fixCount_r]
  split_ifs with h <;> simp [h, (NeZero.ne n).symm]

lemma fixCount_r_ne {v : ℕ} (hv0 : v ≠ 0) (hvn : v ≠ n) (i : ZMod n) : fixCount (r i) ≠ v := by
  rw [fixCount_r]
  split_ifs <;> omega

/-- **Odd type distribution**: `{0 : n - 1, 1 : n, n : 1}` out of `2n`. -/
theorem typeCounts_odd (hn : Odd n) (h3 : 3 ≤ n) :
    #{g : DihedralGroup n | fixCount g = 0} = n - 1 ∧
    #{g : DihedralGroup n | fixCount g = 1} = n ∧
    #{g : DihedralGroup n | fixCount g = n} = 1 := by
  have h1n : (1 : ℕ) ≠ n := by omega
  refine ⟨?_, ?_, ?_⟩ <;> rw [card_filter_dihedral] <;>
    simp only [fixCount_r_eq_zero_iff, fixCount_r_eq_self_iff, fixCount_sr_of_odd hn,
      fixCount_r_ne one_ne_zero h1n]
  · rw [card_ne_zero_zmod]; simp
  · simp
  · rw [card_eq_zero_zmod]
    have : (1 : ℕ) ≠ n := by omega
    simp [this]

lemma fixCount_sr_eq_zero_iff (hn : Even n) (i : ZMod n) :
    fixCount (sr i) = 0 ↔ ¬ Even i.val := by
  rw [fixCount_sr_of_even (even_iff_two_dvd.1 hn)]
  split_ifs with h <;> simp [h]

lemma fixCount_sr_eq_two_iff (hn : Even n) (i : ZMod n) :
    fixCount (sr i) = 2 ↔ Even i.val := by
  rw [fixCount_sr_of_even (even_iff_two_dvd.1 hn)]
  split_ifs with h <;> simp [h]

lemma fixCount_sr_ne_self (hn : Even n) (h4 : 4 ≤ n) (i : ZMod n) : fixCount (sr i) ≠ n := by
  rw [fixCount_sr_of_even (even_iff_two_dvd.1 hn)]
  split_ifs <;> omega

/-- **Even type distribution**: `{0 : 3n/2 - 1, 2 : n/2, n : 1}` out of `2n`. -/
theorem typeCounts_even (hn : Even n) (h4 : 4 ≤ n) :
    #{g : DihedralGroup n | fixCount g = 0} = n - 1 + n / 2 ∧
    #{g : DihedralGroup n | fixCount g = 2} = n / 2 ∧
    #{g : DihedralGroup n | fixCount g = n} = 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [card_filter_dihedral]
  · simp only [fixCount_r_eq_zero_iff, fixCount_sr_eq_zero_iff hn]
    rw [card_ne_zero_zmod, card_odd_zmod hn]
  · have h2n : (2 : ℕ) ≠ n := by omega
    simp only [fixCount_r_ne two_ne_zero h2n, fixCount_sr_eq_two_iff hn]
    rw [card_even_zmod hn]
    simp
  · simp only [fixCount_r_eq_self_iff, fixCount_sr_ne_self hn h4]
    rw [card_eq_zero_zmod]
    simp

end FixedPoints

/-! ## 3. The dihedral type entropy -/

section Entropy

variable {n : ℕ} [NeZero n]

/-- The **dihedral type entropy** `H(T)` of the degree-`n` radical field
(`T = fixCount` of a uniformly random element of `D_n`). -/
noncomputable def typeEntropyDn (n : ℕ) [NeZero n] : ℝ :=
  uEnt (univ : Finset (DihedralGroup n)) fixCount

/-- The catalog's `D₆` entropy is the `n = 6` instance. -/
theorem typeEntropyDn_six : typeEntropyDn 6 = typeEntropyD6 := rfl

/-- Log-fibre sizes, split over rotations and reflections. -/
lemma typeEntropyDn_split :
    typeEntropyDn n = Real.logb 2 (2 * n)
      - (∑ i : ZMod n, Real.logb 2 (#{g : DihedralGroup n | fixCount g = fixCount (r i)} : ℝ)
        + ∑ i : ZMod n, Real.logb 2 (#{g : DihedralGroup n | fixCount g = fixCount (sr i)} : ℝ))
        / (2 * n) := by
  rw [typeEntropyDn, uEnt, card_univ, DihedralGroup.card, sum_dihedral]
  push_cast
  rfl

lemma logb_two_mul {x : ℝ} (hx : 0 < x) : Real.logb 2 (2 * x) = 1 + Real.logb 2 x := by
  rw [Real.logb_mul (by norm_num) hx.ne', Real.logb_self_eq_one (by norm_num)]

/-- The rotation part of the log-fibre sum: `F(n) + (n - 1) F(0)`. -/
lemma sum_rot_logb (F : ℕ → ℝ) :
    ∑ i : ZMod n, F (fixCount (r i)) = F n + ((n : ℝ) - 1) * F 0 := by
  simp only [fixCount_r, apply_ite F]
  rw [sum_ite, sum_const, sum_const, card_eq_zero_zmod, card_ne_zero_zmod,
    nsmul_eq_mul, nsmul_eq_mul, Nat.cast_sub (NeZero.one_le), Nat.cast_one, one_mul]

/-- **The odd dihedral type entropy**: `H(T) = 1 + pinEnt(n)/2` for odd `n ≥ 3`. -/
theorem typeEntropyDn_odd (hn : Odd n) (h3 : 3 ≤ n) :
    typeEntropyDn n = 1 + pinEnt n / 2 := by
  obtain ⟨c0, c1, cn⟩ := typeCounts_odd hn h3
  have hsr : ∀ i : ZMod n, fixCount (sr i) = 1 := fixCount_sr_of_odd hn
  rw [typeEntropyDn_split,
    sum_rot_logb (fun v => Real.logb 2 (#{g : DihedralGroup n | fixCount g = v} : ℝ))]
  simp only [hsr, c0, c1, cn, sum_const, card_univ, ZMod.card, nsmul_eq_mul,
    Nat.cast_one, Real.logb_one, zero_add, Nat.cast_sub (show 1 ≤ n by omega)]
  have hnR : (0 : ℝ) < n := by exact_mod_cast (show 0 < n by omega)
  rw [logb_two_mul hnR, pinEnt]
  field_simp
  ring

/-- **The even dihedral type entropy**: for `n = 2m`, `m ≥ 2`,
`H(T) = log₂ (4m) - ((3m - 1) log₂ (3m - 1) + m log₂ m) / (4m)`. -/
theorem typeEntropyDn_even {m : ℕ} (hnm : n = 2 * m) (hm : 2 ≤ m) :
    typeEntropyDn n = Real.logb 2 (4 * m)
      - ((3 * (m : ℝ) - 1) * Real.logb 2 (3 * (m : ℝ) - 1) + m * Real.logb 2 m) / (4 * m) := by
  have hn : Even n := ⟨m, by omega⟩
  obtain ⟨c0, c2, cn⟩ := typeCounts_even hn (by omega)
  have hsr : ∀ i : ZMod n, fixCount (sr i) = if Even i.val then 2 else 0 :=
    fixCount_sr_of_even (even_iff_two_dvd.1 hn)
  rw [typeEntropyDn_split,
    sum_rot_logb (fun v => Real.logb 2 (#{g : DihedralGroup n | fixCount g = v} : ℝ))]
  simp only [hsr, apply_ite (fun v => Real.logb 2 (#{g : DihedralGroup n | fixCount g = v} : ℝ))]
  rw [sum_ite, sum_const, sum_const, card_even_zmod hn, card_odd_zmod hn, c0, c2, cn]
  have h2 : n / 2 = m := by omega
  have hc0 : ((n - 1 + n / 2 : ℕ) : ℝ) = 3 * (m : ℝ) - 1 := by
    rw [h2, hnm, Nat.cast_add, Nat.cast_sub (by omega)]
    push_cast
    ring
  rw [hc0, h2, nsmul_eq_mul, nsmul_eq_mul, Nat.cast_one, Real.logb_one, zero_add, hnm]
  push_cast
  ring_nf

/-- The explicit rows `n = 3, 4, 5, 6` of the dihedral type column. -/
theorem typeEntropyDn_three : typeEntropyDn 3 = 2 / 3 + Real.logb 2 3 / 2 := by
  rw [typeEntropyDn_odd (by decide) le_rfl, pinEnt]
  norm_num [Real.logb_self_eq_one]
  ring

theorem typeEntropyDn_four : typeEntropyDn 4 = 11 / 4 - 5 / 8 * Real.logb 2 5 := by
  rw [typeEntropyDn_even (m := 2) rfl le_rfl]
  norm_num [lb_8, lb_two]
  ring

theorem typeEntropyDn_five : typeEntropyDn 5 = 1 / 5 + Real.logb 2 5 / 2 := by
  rw [typeEntropyDn_odd (by decide) (by norm_num), pinEnt]
  norm_num [lb_4]
  ring

/-- Independent re-derivation of the catalog's `D₆` value from the general law. -/
theorem typeEntropyDn_six_val : typeEntropyDn 6 = 3 / 4 * Real.logb 2 3 := by
  rw [typeEntropyDn_even (m := 3) rfl (by norm_num)]
  norm_num [lb_8, lb_12]
  ring

end Entropy

/-! ## 4. The rotation-character dial -/

section Dial

variable {n : ℕ} [NeZero n]

lemma image_rotSign : (univ : Finset (DihedralGroup n)).image rotSign = {0, 1} := by
  ext c
  simp only [mem_image, mem_univ, true_and, mem_insert, mem_singleton]
  constructor
  · rintro ⟨g, rfl⟩
    cases g <;> simp [rotSign]
  · rintro (rfl | rfl)
    · exact ⟨r 0, rfl⟩
    · exact ⟨sr 0, rfl⟩

lemma card_rotSign_zero : #{g : DihedralGroup n | rotSign g = 0} = n := by
  rw [card_filter_dihedral]
  simp [rotSign]

lemma card_rotSign_one : #{g : DihedralGroup n | rotSign g = 1} = n := by
  rw [card_filter_dihedral]
  simp [rotSign]

/-- **Rotation fibre**: conditioned on `p` being a rotation Frobenius, the type is
the pinning channel of the `n` rotations. -/
theorem uEnt_rotFibre :
    uEnt {g : DihedralGroup n | rotSign g = 0} fixCount = pinEnt n := by
  rw [uEnt_pinned (a₀ := r 0) (by simp only [mem_filter, mem_univ, true_and]; rfl),
    card_rotSign_zero]
  · intro x hx hfx
    simp only [mem_filter, mem_univ, true_and] at hx
    cases x with
    | r i =>
      rw [fixCount_r_eq_self_iff (0 : ZMod n) |>.2 rfl, fixCount_r_eq_self_iff] at hfx
      rw [hfx]
    | sr i => simp [rotSign] at hx
  · intro x hx y hy hx0 hy0
    simp only [mem_filter, mem_univ, true_and] at hx hy
    cases x with
    | sr i => simp [rotSign] at hx
    | r i =>
      cases y with
      | sr j => simp [rotSign] at hy
      | r j =>
        have hi : ¬ i = 0 := fun h => hx0 (by rw [h])
        have hj : ¬ j = 0 := fun h => hy0 (by rw [h])
        rw [(fixCount_r_eq_zero_iff i).2 hi, (fixCount_r_eq_zero_iff j).2 hj]

/-- **Bridge: dihedral rotation fibre = cyclic root-count channel.** -/
theorem rotFibre_eq_rootCountEntropy :
    uEnt {g : DihedralGroup n | rotSign g = 0} fixCount = rootCountEntropy n := by
  rw [uEnt_rotFibre, rootCountEntropy_eq_pinEnt (Nat.pos_of_ne_zero (NeZero.ne n))]

/-- Reflection fibre, odd `n`: the type is pinned (`T = 1`), no entropy. -/
theorem uEnt_reflFibre_odd (hn : Odd n) :
    uEnt {g : DihedralGroup n | rotSign g = 1} fixCount = 0 := by
  apply uEnt_const_on
  intro x hx y hy
  simp only [mem_filter, mem_univ, true_and] at hx hy
  cases x with
  | r i => simp [rotSign] at hx
  | sr i =>
    cases y with
    | r j => simp [rotSign] at hy
    | sr j => rw [fixCount_sr_of_odd hn, fixCount_sr_of_odd hn]

/-- Reflection fibre, even `n`: the type is a fair coin (`T ∈ {0, 2}`), one bit. -/
theorem uEnt_reflFibre_even (hn : Even n) :
    uEnt {g : DihedralGroup n | rotSign g = 1} fixCount = 1 := by
  have hn0 : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  have hne : ({g : DihedralGroup n | rotSign g = 1} : Finset _).Nonempty :=
    ⟨sr 0, by simp [rotSign]⟩
  rw [uEnt_uniform_fibres (c := n / 2) hne, card_rotSign_one]
  · obtain ⟨m, hm⟩ := hn
    have hm0 : (0 : ℝ) < m := by exact_mod_cast (show 0 < m by omega)
    rw [show n / 2 = m by omega, hm, show m + m = 2 * m by ring, Nat.cast_mul, Nat.cast_two,
      logb_two_mul hm0]
    ring
  · intro a ha
    simp only [mem_filter, mem_univ, true_and] at ha
    cases a with
    | r i => simp [rotSign] at ha
    | sr i =>
      rw [filter_filter, card_filter_dihedral]
      simp only [rotSign, zero_ne_one, false_and, filter_false, card_empty, zero_add, true_and]
      by_cases hi : Even i.val
      · rw [(fixCount_sr_eq_two_iff hn i).2 hi]
        simp only [fixCount_sr_eq_two_iff hn]
        exact card_even_zmod hn
      · rw [(fixCount_sr_eq_zero_iff hn i).2 hi]
        simp only [fixCount_sr_eq_zero_iff hn]
        exact card_odd_zmod hn

lemma condEnt_rotSign_split :
    condEnt (univ : Finset (DihedralGroup n)) fixCount rotSign
      = (uEnt {g : DihedralGroup n | rotSign g = 0} fixCount
        + uEnt {g : DihedralGroup n | rotSign g = 1} fixCount) / 2 := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne n)
  rw [condEnt, image_rotSign, sum_pair (by decide), card_rotSign_zero, card_rotSign_one,
    card_univ, DihedralGroup.card]
  push_cast
  field_simp

/-- **Odd `n`: `H(T | rotSign) = pinEnt(n)/2`** — the non-abelian residue. -/
theorem condEnt_rotSign_odd (hn : Odd n) :
    condEnt (univ : Finset (DihedralGroup n)) fixCount rotSign = pinEnt n / 2 := by
  rw [condEnt_rotSign_split, uEnt_rotFibre, uEnt_reflFibre_odd hn, add_zero]

/-- **Odd `n`: the abelian dial carries exactly one bit.** -/
theorem mutInfo_rotSign_odd (hn : Odd n) (h3 : 3 ≤ n) :
    mutInfo (univ : Finset (DihedralGroup n)) fixCount rotSign = 1 := by
  rw [mutInfo, condEnt_rotSign_odd hn]
  change typeEntropyDn n - _ = 1
  rw [typeEntropyDn_odd hn h3]
  ring

/-- **Even `n`: `H(T | rotSign) = pinEnt(n)/2 + 1/2`.** -/
theorem condEnt_rotSign_even (hn : Even n) :
    condEnt (univ : Finset (DihedralGroup n)) fixCount rotSign = pinEnt n / 2 + 1 / 2 := by
  rw [condEnt_rotSign_split, uEnt_rotFibre, uEnt_reflFibre_even hn]
  ring

/-- Consistency with the catalog's enumerated `D₆` value
`H(T | p mod 3) = 1 + L/2 - (5/12) L₅`. -/
theorem condEnt_rotSign_six_consistent :
    pinEnt 6 / 2 + 1 / 2 = 1 + Real.logb 2 3 / 2 - 5 / 12 * Real.logb 2 5 := by
  rw [pinEnt]
  norm_num [lb_6]
  ring

end Dial

end MasterTable