/-
# SEXTIC-HINT-VALUE: the hint map extends beyond degree 5

FACT round-31 #2 (paper 121) reads the unordered splitting-type pair `{T(p), T(q)}` of a
semiprime `N = p q` in the cyclic sextic field `Q(ζ₁₃)⁺` (Galois group `C₆`, conductor `13`)
through the four residue views of the factor pair `(p mod 13, q mod 13)` and reports

| view                          | reported | exact (this file)                 |
|-------------------------------|----------|-----------------------------------|
| product view `N mod 13`       | 1.4704   | `log₂ 3 - 1/9      = 1.47385…`    |
| joint residue view `(s, d)`   | 3.1110   | `2 log₂ 3 - 1/18   = 3.11437…`    |
| **hint value**                | +1.6407  | `log₂ 3 + 1/18     = 1.64052…`    |

This file proves every entry of that table as a theorem about the *actual* battery: the
population is the `12 × 12` pairs of units of `ZMod 13`, the labels are the unordered pairs of
residue degrees `realDeg 13` in `Q(ζ₁₃)⁺` (from `Shared.AbelianLadderRealCyclotomic`), and the
hint value is literally the catalog's `SumDiffSplit.hintValue`.

## Main results

* `Hb_eq_uEnt`, `MIb_eq_mutInfo` — **the bridge between the two information calculi of the
  catalog**: the trace-battery entropy `TraceBattery.Hb` (nats rescaled to bits over a
  `Fintype` population) coincides with the counting entropy `CyclicTypeChannel.uEnt` over
  `univ`, and `BatterySynergy.MIb` with `CyclicTypeChannel.mutInfo`.  This lets the exact
  cyclic-type-channel values be read off inside the hint-value framework.
* `MIb_product_eq`, `MIb_residue_eq`, `hintValue_eq` — the three rows of the table in closed
  form; `hintValue_eq_condPairEntropy` — the field-level hint value equals the abstract `C₆`
  conditional pair entropy `condPairEntropy 6`: **field model = exponent model**.
* `sumHintView_pins`, `gapHintView_pins` — **both single dials already pin the label**.  The
  sum dial pins by Vieta (`vieta_sum`: `N` and `s` determine `{p, q}`), the gap dial pins by
  Vieta *plus the reality of the field* (`vieta_gap`: `N` and `d` determine `{p,q}` only up
  to `(p, q) ↦ (-q, -p)`, and `realDeg_neg` says residue degrees in the real subfield are
  blind to that sign).
* `sumHint_eq`, `gapHint_eq`, `hintSynergy_eq`, `redundancy_wall_attained` — each dial alone
  carries the whole hint value, so the hint synergy is `-(log₂ 3 + 1/18)`, i.e. **the
  redundancy wall `-min(sumHint, gapHint)` of `HintValueJoint.neg_min_le_hintSynergy` is
  attained exactly**, and the one-bit upper wall is respected with room to spare.
* `MIb_sum_eq` — the sum dial *without* `N` reads `2 log₂ 3 + 29/36 - (11/12) log₂ 11`
  (`≈ 0.80434` bits): a `log₂ 11` term enters from the `p + q = 0` fibre.
* `hintMap`, `hintMap_eq_condPairEntropy`, `hintMap_two` … `hintMap_six` — **the hint map**
  `n ↦ I(pair ; (p,q)) - I(pair ; N)` of the cyclic type channel, its values on degrees
  `2, …, 6`, the verdict `hintMap_six_gt_lower` (the degree-6 value strictly exceeds every
  lower-degree value), and `hintMap_not_monotone` (`hintMap 5 < hintMap 4`).
* `hintMap_nonneg`, `hintMap_le_pairEntropy`, `hintMap_le_logb` — the walls: the hint map is
  non-negative, never exceeds the label entropy, and never exceeds `log₂ n`.
* `hintMap_crt_six`, `hintMap_crt_ten`, `hintMap_crt_twelve`, `hintMap_crt_fifteen` —
  **the CRT defect law**: over coprime factors the hint map is *superadditive* with defect
  exactly the product of the two type-distinctness probabilities,
  `hintMap (m n) = hintMap m + hintMap n + δ(m) δ(n)`; at degree `6` the defect is
  `δ(2) δ(3) = (1/2)(4/9) = 2/9`.
* numerical certificates `hintValue_bracket`, `reported_hint_above_exact`,
  `reported_joint_below_exact`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (S1) the round-31 hint value is exactly `H(pair | N mod 13)`;
  (S2) its closed form is `log₂ 3 + 1/18`; (S3) the single sum dial and the single gap dial
  each carry the whole hint (maximal redundancy), the gap dial because the field is real;
  (S4) the hint map is CRT-superadditive with defect `δ(m) δ(n)`.
Experiment (Stage 2): exact recomputation over the `144` unit pairs (Lean `#eval`, recorded in
  `ComputationalEvidence.md`): label fibres `{4,8,16,16,4,16,16,16,16,32}`, `(label, N)` fibres
  `12 × 2, 26 × 4, 2 × 8`, giving `I(pair;N) = 1.473851`, `I(pair;s,d) = 3.114369`,
  `I(pair;N,s) = I(pair;N,d) = 3.114369`, `I(pair;s) = I(pair;d) = 0.804335`.
Analysis (Stage 3): (S1)–(S4) are theorems below; (S4) is proved here at the four coprime
  degrees available in the catalog (`6, 10, 12, 15`), and as a general law for all coprime
  `m, n` in `Physics.HintMapCRTDefect` (`hintMap_mul_of_coprime`).
Critique (Stage 4): the reported `1.6407` is *not* the exact hint value (it overshoots by more
  than `10⁻⁴`); the reported joint row `3.1110` undershoots the exact `3.11437` by more than
  `3 · 10⁻³`, i.e. the experiment's own rows are finite-sample estimates.  Every entropy below
  is an exact real number obtained from kernel-checked fibre counts; no `native_decide`.
-/
import Physics.AbelianLadderCyclicSextic
import Shared.CyclicTypeChannelCRT
import Shared.CyclicTypeChannelCRTLaw
import Shared.CyclicTypeChannelNonneg
import Bridges.HintValueJointCompounding

namespace SexticHintValue

open Finset CyclicTypeChannel AbelianLadder TraceBattery BatterySynergy SumDiffSplit
  HintValueJoint

set_option maxRecDepth 100000

/-! ## 1. The bridge between the trace-battery and the counting entropies -/

/-- **Bridge.**  The trace-battery entropy in bits is the counting entropy over `univ`. -/
theorem Hb_eq_uEnt {Ω α : Type*} [Fintype Ω] [DecidableEq α] (f : Ω → α) :
    Hb f = uEnt (univ : Finset Ω) f := by
  classical
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [Hb, H, uEnt, img]
  have hN : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  have himg : img f = univ.image f := by
    unfold img; congr 1; exact Subsingleton.elim _ _
  have hcnt : ∀ a, (cnt f a : ℝ) = (#{x ∈ (univ : Finset Ω) | f x = a} : ℕ) := by
    intro a; unfold cnt fib; congr 2; ext x; simp
  have hsum : ∑ a ∈ univ.image f, (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ)
      = Fintype.card Ω := by
    have := Finset.card_eq_sum_card_image f (univ : Finset Ω)
    rw [card_univ] at this
    exact_mod_cast this.symm
  rw [uEnt, sum_logb_fiber, Hb, H, himg, card_univ]
  simp_rw [hcnt]
  have key : ∑ a ∈ univ.image f, (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ) / (Fintype.card Ω) *
      (Real.log (Fintype.card Ω) - Real.log (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ))
      = Real.log (Fintype.card Ω) - (∑ a ∈ univ.image f,
          (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ) *
            Real.log (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ)) / Fintype.card Ω := by
    have e1 : ∑ a ∈ univ.image f, (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ) / (Fintype.card Ω) *
        (Real.log (Fintype.card Ω) - Real.log (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ))
        = (∑ a ∈ univ.image f, (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ)) / Fintype.card Ω
            * Real.log (Fintype.card Ω)
          - (∑ a ∈ univ.image f, (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ) *
            Real.log (#{x ∈ (univ : Finset Ω) | f x = a} : ℝ)) / Fintype.card Ω := by
      rw [Finset.sum_div, Finset.sum_div, Finset.sum_mul, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a _ => ?_
      ring
    rw [e1, hsum, div_self hN.ne']
    ring
  rw [key]
  simp only [Real.logb, Finset.sum_div]
  rw [sub_div, Finset.sum_div]
  congr 1
  refine Finset.sum_congr rfl fun a _ => ?_
  field_simp

/-- **Bridge.**  The trace information in bits is the counting mutual information. -/
theorem MIb_eq_mutInfo {Ω Λ α : Type*} [Fintype Ω] [DecidableEq Λ] [DecidableEq α]
    (L : Ω → Λ) (f : Ω → α) : MIb L f = mutInfo (univ : Finset Ω) L f := by
  have hl2 : Real.log 2 ≠ 0 := (Real.log_pos (by norm_num)).ne'
  have e : MIb L f = Hb L + Hb f - Hb (pr L f) := by
    rw [MIb, MI_eq, Hb, Hb, Hb]
    field_simp
  rw [e, Hb_eq_uEnt, Hb_eq_uEnt, Hb_eq_uEnt, mutInfo_eq_symm_form]
  rfl

/-! ## 2. Vieta pinning -/

/-- **Vieta for the sum dial.**  In an integral domain the product and the sum determine the
unordered pair of factors. -/
theorem vieta_sum {R : Type*} [CommRing R] [IsDomain R] {p q p' q' : R}
    (hN : p * q = p' * q') (hs : p + q = p' + q') :
    (p' = p ∧ q' = q) ∨ (p' = q ∧ q' = p) := by
  have h : (p' - p) * (p' - q) = 0 := by linear_combination (-p') * hs + hN
  rcases mul_eq_zero.1 h with h1 | h1
  · exact Or.inl ⟨by linear_combination h1, by linear_combination -hs - h1⟩
  · exact Or.inr ⟨by linear_combination h1, by linear_combination -hs - h1⟩

/-- **Vieta for the gap dial.**  The product and the gap determine the factor pair only up to
the sign flip `(p, q) ↦ (-q, -p)`. -/
theorem vieta_gap {R : Type*} [CommRing R] [IsDomain R] {p q p' q' : R}
    (hN : p * q = p' * q') (hd : q - p = q' - p') :
    (p' = p ∧ q' = q) ∨ (p' = -q ∧ q' = -p) := by
  have h : (p' - p) * (p' + q) = 0 := by linear_combination p' * hd - hN
  rcases mul_eq_zero.1 h with h1 | h1
  · exact Or.inl ⟨by linear_combination h1, by linear_combination h1 - hd⟩
  · exact Or.inr ⟨by linear_combination h1, by linear_combination h1 - hd⟩

/-! ## 3. The round-31 battery over `Q(ζ₁₃)⁺` -/

instance fact_prime_13 : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-- The population: ordered pairs of unit residues `(p mod 13, q mod 13)`. -/
abbrev Pop := (ZMod 13)ˣ × (ZMod 13)ˣ

/-- First factor residue. -/
def P13 : Pop → ZMod 13 := fun x => (x.1 : ZMod 13)

/-- Second factor residue. -/
def Q13 : Pop → ZMod 13 := fun x => (x.2 : ZMod 13)

/-- **The labels**: the unordered pair of residue degrees of `p` and `q` in `Q(ζ₁₃)⁺`. -/
noncomputable def typeLabel (x : Pop) : ℕ × ℕ :=
  (min (realDeg 13 x.1) (realDeg 13 x.2), max (realDeg 13 x.1) (realDeg 13 x.2))

/-- The computable form of the labels, through the splitting law `realDeg_13_eq`. -/
def typeLabelC (x : Pop) : ℕ × ℕ :=
  (min (sexticType (x.1 : ZMod 13).val) (sexticType (x.2 : ZMod 13).val),
    max (sexticType (x.1 : ZMod 13).val) (sexticType (x.2 : ZMod 13).val))

theorem typeLabel_eq : typeLabel = typeLabelC := by
  funext x
  simp only [typeLabel, typeLabelC, realDeg_13_eq]

/-- The labels are `p ↔ q` symmetric. -/
theorem typeLabel_swap (a b : (ZMod 13)ˣ) : typeLabel (b, a) = typeLabel (a, b) := by
  simp only [typeLabel, min_comm, max_comm]

/-- The labels are blind to the sign flip `(p, q) ↦ (-q, -p)` (reality of the field). -/
theorem typeLabel_negswap (a b : (ZMod 13)ˣ) : typeLabel (-b, -a) = typeLabel (a, b) := by
  simp only [typeLabel, realDeg_neg, min_comm, max_comm]

private theorem lb2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

theorem card_pop : (univ : Finset Pop).card = 144 := by
  rw [card_univ, Fintype.card_prod, card_units_13]

/-- **Label entropy**: `H({T(p), T(q)}) = 2 log₂ 3 - 1/18`. -/
theorem uEnt_typeLabel : uEnt (univ : Finset Pop) typeLabel = 2 * Real.logb 2 3 - 1 / 18 := by
  rw [typeLabel_eq, uEnt_eq_countSum _ _ (↑[4, 8, 16, 16, 4, 16, 16, 16, 16, 32] : Multiset ℕ)
    (by decide), card_pop]
  norm_num [lb2, lb_4, lb_8, lb_16, lb_32, lb_144]
  ring

/-- Entropy of the product view: `N mod 13` is uniform on the `12` units. -/
theorem uEnt_product : uEnt (univ : Finset Pop) (productView P13 Q13) = 2 + Real.logb 2 3 := by
  have h : ((univ : Finset Pop).image (productView P13 Q13)).val.map
      (fun v => (#{x ∈ (univ : Finset Pop) | productView P13 Q13 x = v} : ℕ))
      = (↑[12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_pop]
  norm_num [lb_12, lb_144]
  ring

/-- Joint entropy of labels and product. -/
theorem uEnt_label_product :
    uEnt (univ : Finset Pop) (fun x => (typeLabel x, productView P13 Q13 x))
      = 4 + 2 * Real.logb 2 3 - 35 / 18 := by
  rw [typeLabel_eq]
  have h : ((univ : Finset Pop).image (fun x => (typeLabelC x, productView P13 Q13 x))).val.map
      (fun v => (#{x ∈ (univ : Finset Pop) | (typeLabelC x, productView P13 Q13 x) = v} : ℕ))
      = (↑[2, 2, 2, 4, 4, 2, 2, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 2, 2, 4, 8, 4, 4, 4, 4, 8, 4, 2, 2,
          4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_pop]
  norm_num [lb2, lb_4, lb_8, lb_144]

/-- **The product row**: `I(pair ; N mod 13) = log₂ 3 - 1/9` (reported `1.4704`). -/
theorem MIb_product_eq : MIb typeLabel (productView P13 Q13) = Real.logb 2 3 - 1 / 9 := by
  rw [MIb_eq_mutInfo, mutInfo_eq_symm_form, uEnt_typeLabel, uEnt_product, uEnt_label_product]
  ring

/-- The factor-pair view separates the population. -/
theorem pairView_injective : Function.Injective (pairView P13 Q13) := by
  intro x y h
  simp only [pairView, P13, Q13, Prod.mk.injEq] at h
  exact Prod.ext (Units.ext h.1) (Units.ext h.2)

/-- The joint residue view `(s, d)` separates the population (`2` is invertible mod `13`). -/
theorem residueView_injective : Function.Injective (residueView P13 Q13) := by
  intro x y h
  simp only [residueView, sd, Prod.mk.injEq] at h
  have h2 : (2 : ZMod 13) * P13 x = 2 * P13 y := by linear_combination h.1 - h.2
  have hP : P13 x = P13 y := by
    have := congrArg (fun t => (7 : ZMod 13) * t) h2
    simp only at this
    have e : ∀ t : ZMod 13, (7 : ZMod 13) * (2 * t) = t := fun t => by
      rw [← mul_assoc, show (7 : ZMod 13) * 2 = 1 from by decide, one_mul]
    rwa [e, e] at this
  have hQ : Q13 x = Q13 y := by linear_combination h.1 - hP
  exact pairView_injective (by simp only [pairView, hP, hQ])

/-- **The joint residue row**: `I(pair ; (s, d)) = H(pair) = 2 log₂ 3 - 1/18`
(reported `3.1110`). -/
theorem MIb_residue_eq : MIb typeLabel (residueView P13 Q13) = 2 * Real.logb 2 3 - 1 / 18 := by
  rw [MIb_eq_mutInfo, mutInfo_comm, mutInfo_eq_uEnt_of_determines, uEnt_typeLabel]
  intro x _ y _ h
  rw [residueView_injective h]

/-- **THE-HINT-EXTENDS-BEYOND-DEGREE-5.**  The round-31 hint value in closed form:
`log₂ 3 + 1/18` bits (reported `+1.6407`). -/
theorem hintValue_eq : hintValue typeLabel P13 Q13 = Real.logb 2 3 + 1 / 18 := by
  rw [hintValue, MIb_residue_eq, MIb_product_eq]
  ring

/-- **Field model = exponent model.**  The three rows coincide with the abstract `C₆`
type-pair channel of `Shared.CyclicTypeChannel`: the product row is `Ipair 6`, the joint row
is `pairEntropy 6`, and the hint value is the conditional pair entropy `condPairEntropy 6`. -/
theorem field_eq_exponent_model :
    MIb typeLabel (productView P13 Q13) = Ipair 6 ∧
    MIb typeLabel (residueView P13 Q13) = pairEntropy 6 ∧
    hintValue typeLabel P13 Q13 = condPairEntropy 6 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [MIb_product_eq, Ipair_val_6]; ring
  · rw [MIb_residue_eq, pairEntropy_val_6]; ring
  · rw [hintValue_eq, condPairEntropy_val_6]; ring

theorem hintValue_eq_condPairEntropy : hintValue typeLabel P13 Q13 = condPairEntropy 6 :=
  field_eq_exponent_model.2.2

/-! ## 4. Both single dials pin the label: maximal redundancy -/

/-- **The sum dial pins** (Vieta + `p ↔ q` symmetry of the labels). -/
theorem sumHintView_pins (x y : Pop) (h : sumHintView P13 Q13 x = sumHintView P13 Q13 y) :
    typeLabel x = typeLabel y := by
  simp only [sumHintView, productView, sumView, P13, Q13, Prod.mk.injEq] at h
  rcases vieta_sum h.1 h.2 with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [show y = x from Prod.ext (Units.ext h1) (Units.ext h2)]
  · rw [show y = (x.2, x.1) from Prod.ext (Units.ext h1) (Units.ext h2)]
    exact (typeLabel_swap x.1 x.2).symm

/-- **The gap dial pins** (Vieta + the reality of `Q(ζ₁₃)⁺`: `realDeg (-u) = realDeg u`). -/
theorem gapHintView_pins (x y : Pop) (h : gapHintView P13 Q13 x = gapHintView P13 Q13 y) :
    typeLabel x = typeLabel y := by
  simp only [gapHintView, productView, gapView, P13, Q13, Prod.mk.injEq] at h
  rcases vieta_gap h.1 h.2 with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [show y = x from Prod.ext (Units.ext h1) (Units.ext h2)]
  · rw [show y = (-x.2, -x.1) from Prod.ext (Units.ext (by simpa using h1))
      (Units.ext (by simpa using h2))]
    exact (typeLabel_negswap x.1 x.2).symm

theorem MIb_sumHintView_eq :
    MIb typeLabel (sumHintView P13 Q13) = 2 * Real.logb 2 3 - 1 / 18 := by
  rw [MIb_eq_mutInfo, mutInfo_comm, mutInfo_eq_uEnt_of_determines, uEnt_typeLabel]
  intro x _ y _ h
  exact sumHintView_pins x y h

theorem MIb_gapHintView_eq :
    MIb typeLabel (gapHintView P13 Q13) = 2 * Real.logb 2 3 - 1 / 18 := by
  rw [MIb_eq_mutInfo, mutInfo_comm, mutInfo_eq_uEnt_of_determines, uEnt_typeLabel]
  intro x _ y _ h
  exact gapHintView_pins x y h

/-- The conditional hint of the sum dial is the whole hint value. -/
theorem sumHint_eq : sumHint typeLabel P13 Q13 = Real.logb 2 3 + 1 / 18 := by
  rw [sumHint, MIb_sumHintView_eq, MIb_product_eq]; ring

/-- The conditional hint of the gap dial is the whole hint value. -/
theorem gapHint_eq : gapHint typeLabel P13 Q13 = Real.logb 2 3 + 1 / 18 := by
  rw [gapHint, MIb_gapHintView_eq, MIb_product_eq]; ring

/-- **Maximal redundancy**: the hint synergy is `-(log₂ 3 + 1/18) ≈ -1.6405` bits. -/
theorem hintSynergy_eq : hintSynergy typeLabel P13 Q13 = -(Real.logb 2 3 + 1 / 18) := by
  rw [hintSynergy, hintValue_eq, sumHint_eq, gapHint_eq]; ring

/-- **Walls clean.**  The lower (redundancy) wall `-min(sumHint, gapHint)` is attained with
equality, the upper one-bit wall holds strictly, and the hint value sits strictly between the
floor `0` and the label-entropy ceiling. -/
theorem redundancy_wall_attained :
    hintSynergy typeLabel P13 Q13
        = -min (sumHint typeLabel P13 Q13) (gapHint typeLabel P13 Q13) ∧
      hintSynergy typeLabel P13 Q13 < 1 ∧
      0 < hintValue typeLabel P13 Q13 ∧
      hintValue typeLabel P13 Q13 < Hb typeLabel := by
  have hl := lb_three_gt
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [hintSynergy_eq, sumHint_eq, gapHint_eq, min_self]
  · rw [hintSynergy_eq]; linarith
  · rw [hintValue_eq]; linarith
  · rw [hintValue_eq, Hb_eq_uEnt, uEnt_typeLabel]; linarith

/-! ## 5. The sum dial without the product -/

theorem uEnt_sum : uEnt (univ : Finset Pop) (sumView P13 Q13)
    = 4 + 2 * Real.logb 2 3 - (132 * Real.logb 2 11 + 12 * (2 + Real.logb 2 3)) / 144 := by
  have h : ((univ : Finset Pop).image (sumView P13 Q13)).val.map
      (fun v => (#{x ∈ (univ : Finset Pop) | sumView P13 Q13 x = v} : ℕ))
      = (↑[12, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_pop]
  norm_num [lb_12, lb_144]
  ring

theorem uEnt_label_sum :
    uEnt (univ : Finset Pop) (fun x => (typeLabel x, sumView P13 Q13 x))
      = 4 + 2 * Real.logb 2 3 - (148 + 12 * Real.logb 2 3) / 144 := by
  rw [typeLabel_eq]
  have h : ((univ : Finset Pop).image (fun x => (typeLabelC x, sumView P13 Q13 x))).val.map
      (fun v => (#{x ∈ (univ : Finset Pop) | (typeLabelC x, sumView P13 Q13 x) = v} : ℕ))
      = (↑[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
          2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
          2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_pop]
  norm_num [lb2, lb_4, lb_144]
  ring

/-- **The sum dial alone** reads `2 log₂ 3 + 29/36 - (11/12) log₂ 11 ≈ 0.80434` bits. -/
theorem MIb_sum_eq : MIb typeLabel (sumView P13 Q13)
    = 2 * Real.logb 2 3 + 29 / 36 - (11 / 12) * Real.logb 2 11 := by
  rw [MIb_eq_mutInfo, mutInfo_eq_symm_form, uEnt_typeLabel, uEnt_sum, uEnt_label_sum]
  ring

/-! ## 6. The hint map of the cyclic type channel -/

/-- **The hint map** of the cyclic type channel of degree `n`: what the factor-pair view
`(p, q)` (equivalently the joint residue view `(s, d)`) reads about the unordered type pair,
beyond the product view `N`. -/
noncomputable def hintMap (n : ℕ) : ℝ := mutInfo (box n) (typePair n) id - Ipair n

/-- The factor-pair view reads the full label entropy. -/
theorem mutInfo_box_id (n : ℕ) : mutInfo (box n) (typePair n) id = pairEntropy n := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ Function.injective_id.injOn, sub_zero]
  rfl

/-- **The hint map is the conditional entropy of the label given the product.** -/
theorem hintMap_eq_condPairEntropy (n : ℕ) : hintMap n = condPairEntropy n := by
  rw [hintMap, mutInfo_box_id, Ipair_eq]
  ring

theorem hintMap_two : hintMap 2 = 1 / 2 := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy_val_2]

theorem hintMap_three : hintMap 3 = Real.logb 2 3 - 2 / 3 := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy_val_3]; ring

theorem hintMap_four : hintMap 4 = 9 / 8 := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy_val_4]

theorem hintMap_five :
    hintMap 5 = Real.logb 2 5 - (12 / 25) * Real.logb 2 3 - 16 / 25 := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy_val_5]; ring

/-- **The degree-6 value of the hint map** is `log₂ 3 + 1/18`. -/
theorem hintMap_six : hintMap 6 = Real.logb 2 3 + 1 / 18 := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy_val_6]; ring

/-- The round-31 hint value is the degree-6 value of the hint map. -/
theorem hintValue_eq_hintMap_six : hintValue typeLabel P13 Q13 = hintMap 6 := by
  rw [hintValue_eq, hintMap_six]

/-- **THE-HINT-EXTENDS-BEYOND-DEGREE-5.**  The complete order of the hint map on the first
five rungs: `hintMap 2 < hintMap 3 < hintMap 5 < hintMap 4 < hintMap 6`.  In particular the
degree-6 value strictly exceeds every lower-degree value, and the prime rung `5` sits between
the prime rung `3` and the prime-power rung `4` (by less than `3 · 10⁻³` above `hintMap 3`). -/
theorem hintMap_order :
    hintMap 2 < hintMap 3 ∧ hintMap 3 < hintMap 5 ∧ hintMap 5 < hintMap 4 ∧
      hintMap 4 < hintMap 6 := by
  obtain ⟨h3l, h3u⟩ := logb_three_fine
  obtain ⟨h5l, h5u⟩ := logb_five_fine
  rw [hintMap_two, hintMap_three, hintMap_four, hintMap_five, hintMap_six]
  refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith

theorem hintMap_six_gt_lower : ∀ n ∈ ({2, 3, 4, 5} : Finset ℕ), hintMap n < hintMap 6 := by
  obtain ⟨h1, h2, h3, h4⟩ := hintMap_order
  intro n hn
  simp only [mem_insert, mem_singleton] at hn
  rcases hn with rfl | rfl | rfl | rfl <;> linarith

/-- The hint map is **not monotone** in the degree. -/
theorem hintMap_not_monotone : ¬ Monotone hintMap := by
  intro h
  have := h (show (4 : ℕ) ≤ 5 by norm_num)
  linarith [hintMap_order.2.2.1]

/-! ## 7. The walls of the hint map -/

/-- **Floor.**  The hint map is non-negative. -/
theorem hintMap_nonneg (n : ℕ) : 0 ≤ hintMap n := by
  rw [hintMap_eq_condPairEntropy]
  exact Finset.sum_nonneg fun c _ => mul_nonneg (by positivity) (uEnt_nonneg _ _)

/-- **Label ceiling.**  The hint map never exceeds the label entropy. -/
theorem hintMap_le_pairEntropy (n : ℕ) : hintMap n ≤ pairEntropy n := by
  have := mutInfo_nonneg (CyclicTypeChannel.box n) (typePair n) (prodRes n)
  rw [hintMap, mutInfo_box_id]
  exact sub_le_self _ this

/-- A conditional entropy is bounded by `log₂` of any common bound on the fibre sizes. -/
theorem condEnt_le_logb_of_fibre_le {α β γ : Type*} [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ) (B : ℕ)
    (hB : ∀ c ∈ s.image k, #{x ∈ s | k x = c} ≤ B) :
    condEnt s g k ≤ Real.logb 2 B := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp only [condEnt, image_empty, sum_empty]
    rcases Nat.eq_zero_or_pos B with rfl | hB0
    · simp
    · exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hB0)
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hw : ∑ c ∈ s.image k, ((#{x ∈ s | k x = c} : ℝ) / s.card) = 1 := by
    rw [← Finset.sum_div]
    have := Finset.card_eq_sum_card_image k s
    rw [div_eq_one_iff_eq hN.ne']
    exact_mod_cast this.symm
  calc condEnt s g k
      ≤ ∑ c ∈ s.image k, ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 B := by
        refine Finset.sum_le_sum fun c hc => mul_le_mul_of_nonneg_left ?_ (by positivity)
        refine (uEnt_le_logb_card _ _).trans ?_
        obtain ⟨a, ha, rfl⟩ := Finset.mem_image.1 hc
        have hpos : (0 : ℝ) < #{x ∈ s | k x = k a} := by
          exact_mod_cast card_pos.2 ⟨a, by simp [ha]⟩
        exact Real.logb_le_logb_of_le (by norm_num) hpos (by exact_mod_cast hB _ hc)
    _ = Real.logb 2 B := by rw [← Finset.sum_mul, hw, one_mul]

/-- Every product fibre of the exponent box has at most `n` points. -/
theorem card_prodRes_fibre_le (n c : ℕ) : #{x ∈ CyclicTypeChannel.box n | prodRes n x = c} ≤ n := by
  have hinj : Set.InjOn Prod.fst
      (↑({x ∈ CyclicTypeChannel.box n | prodRes n x = c} : Finset (ℕ × ℕ)) : Set (ℕ × ℕ)) := by
    intro x hx y hy hxy
    simp only [coe_filter, CyclicTypeChannel.box, mem_product, mem_range, prodRes, Set.mem_setOf_eq] at hx hy
    have h1 : x.1 = y.1 := hxy
    have hmod : (x.1 + x.2) % n = (x.1 + y.2) % n := by rw [hx.2, h1, hy.2]
    have h2 : x.2 = y.2 := by
      have := Nat.ModEq.add_left_cancel' x.1 hmod
      rwa [Nat.ModEq, Nat.mod_eq_of_lt hx.1.2, Nat.mod_eq_of_lt hy.1.2] at this
    exact Prod.ext h1 h2
  calc #{x ∈ CyclicTypeChannel.box n | prodRes n x = c}
      = (({x ∈ CyclicTypeChannel.box n | prodRes n x = c} : Finset (ℕ × ℕ)).image Prod.fst).card :=
        (card_image_of_injOn hinj).symm
    _ ≤ (range n).card := by
        refine card_le_card fun a ha => ?_
        obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 ha
        simp only [mem_filter, CyclicTypeChannel.box, mem_product] at hx
        exact hx.1.1
    _ = n := card_range n

/-- **Fibre ceiling.**  The hint map never exceeds `log₂ n`: once the product residue is
known, only the `n` factorisations of that residue remain. -/
theorem hintMap_le_logb (n : ℕ) : hintMap n ≤ Real.logb 2 n := by
  rw [hintMap_eq_condPairEntropy, condPairEntropy]
  exact condEnt_le_logb_of_fibre_le _ _ _ n fun c _ => card_prodRes_fibre_le n c

/-! ## 8. The CRT defect law of the hint map -/

/-- The probability that the two primes of a random semiprime have *different* splitting
types in the cyclic channel of degree `n`. -/
noncomputable def distinctProb (n : ℕ) : ℝ :=
  (#{x ∈ CyclicTypeChannel.box n | ordType n x.1 ≠ ordType n x.2} : ℝ) / (n : ℝ) ^ 2

theorem distinctProb_two : distinctProb 2 = 1 / 2 := by
  rw [distinctProb, show #{x ∈ CyclicTypeChannel.box 2 | ordType 2 x.1 ≠ ordType 2 x.2} = 2 from by decide]
  norm_num

theorem distinctProb_three : distinctProb 3 = 4 / 9 := by
  rw [distinctProb, show #{x ∈ CyclicTypeChannel.box 3 | ordType 3 x.1 ≠ ordType 3 x.2} = 4 from by decide]
  norm_num

theorem distinctProb_four : distinctProb 4 = 5 / 8 := by
  rw [distinctProb, show #{x ∈ CyclicTypeChannel.box 4 | ordType 4 x.1 ≠ ordType 4 x.2} = 10 from by decide]
  norm_num

theorem distinctProb_five : distinctProb 5 = 8 / 25 := by
  rw [distinctProb, show #{x ∈ CyclicTypeChannel.box 5 | ordType 5 x.1 ≠ ordType 5 x.2} = 8 from by decide]
  norm_num

/-- **CRT defect at degree 6**: `hintMap 6 = hintMap 2 + hintMap 3 + δ(2) δ(3)`, with
defect `δ(2) δ(3) = 2/9`.  The hint map is strictly superadditive over `C₆ ≅ C₂ × C₃`, although
the product channel `Ipair` is exactly additive (`Ipair_mul_of_coprime`). -/
theorem hintMap_crt_six :
    hintMap 6 = hintMap 2 + hintMap 3 + distinctProb 2 * distinctProb 3 := by
  rw [hintMap_six, hintMap_two, hintMap_three, distinctProb_two, distinctProb_three]
  ring

/-- CRT defect at degree `10 = 2 · 5`. -/
theorem hintMap_crt_ten :
    hintMap 10 = hintMap 2 + hintMap 5 + distinctProb 2 * distinctProb 5 := by
  rw [hintMap_eq_condPairEntropy 10, condPairEntropy_val_10, hintMap_two, hintMap_five,
    distinctProb_two, distinctProb_five]
  ring

/-- CRT defect at degree `12 = 4 · 3`. -/
theorem hintMap_crt_twelve :
    hintMap 12 = hintMap 4 + hintMap 3 + distinctProb 4 * distinctProb 3 := by
  rw [hintMap_eq_condPairEntropy 12, condPairEntropy_val_12, hintMap_four, hintMap_three,
    distinctProb_four, distinctProb_three]
  ring

/-- CRT defect at degree `15 = 3 · 5`. -/
theorem hintMap_crt_fifteen :
    hintMap 15 = hintMap 3 + hintMap 5 + distinctProb 3 * distinctProb 5 := by
  rw [hintMap_eq_condPairEntropy 15, condPairEntropy_val_15, hintMap_three, hintMap_five,
    distinctProb_three, distinctProb_five]
  ring

/-- The defect is the *label-entropy* defect: `Ipair` is CRT-additive, so the whole
superadditivity of the hint map at degree `6` comes from the unordered pair entropy. -/
theorem crt_defect_is_pairEntropy_defect :
    hintMap 6 - hintMap 2 - hintMap 3 = pairEntropy 6 - pairEntropy 2 - pairEntropy 3 := by
  have hI := Ipair_mul_of_coprime (m := 2) (n := 3) (by norm_num) (by norm_num) (by norm_num)
  simp only [hintMap, mutInfo_box_id]
  norm_num at hI
  rw [hI]
  ring

/-! ## 9. Numerical certificates -/

/-- `hintValue = 1.64052…`. -/
theorem hintValue_bracket :
    1.64051 < hintValue typeLabel P13 Q13 ∧ hintValue typeLabel P13 Q13 < 1.64053 := by
  obtain ⟨h1, h2⟩ := logb_three_fine
  rw [hintValue_eq]
  constructor <;> norm_num <;> linarith

/-- **The reported `+1.6407` is not the exact hint value**: it overshoots by more than
`10⁻⁴` bits. -/
theorem reported_hint_above_exact : hintValue typeLabel P13 Q13 + 0.0001 < 1.6407 := by
  linarith [hintValue_bracket.2]

/-- **The reported joint row `3.1110` under-estimates** the exact `2 log₂ 3 - 1/18 = 3.11437…`
by more than `3 · 10⁻³` bits. -/
theorem reported_joint_below_exact :
    (3.1110 : ℝ) + 0.003 < MIb typeLabel (residueView P13 Q13) := by
  obtain ⟨h1, -⟩ := logb_three_fine
  rw [MIb_residue_eq]
  norm_num
  linarith

private theorem logb_eleven_bracket :
    (83 : ℝ) / 24 < Real.logb 2 11 ∧ Real.logb 2 11 < (45 : ℝ) / 13 := by
  have l2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)
  constructor
  · have h : ((2 : ℝ) ^ 83) < (11 : ℝ) ^ 24 := by norm_num
    have hlt := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
    rw [Real.logb_pow, Real.logb_pow, l2] at hlt
    push_cast at hlt
    linarith
  · have h : ((11 : ℝ) ^ 13) < (2 : ℝ) ^ 45 := by norm_num
    have hlt := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
    rw [Real.logb_pow, Real.logb_pow, l2] at hlt
    push_cast at hlt
    linarith

/-- The sum dial alone reads `0.80 < I(pair ; s) < 0.81` bits. -/
theorem MIb_sum_bracket :
    0.80 < MIb typeLabel (sumView P13 Q13) ∧ MIb typeLabel (sumView P13 Q13) < 0.81 := by
  obtain ⟨h1, h2⟩ := logb_three_fine
  obtain ⟨h3, h4⟩ := logb_eleven_bracket
  rw [MIb_sum_eq]
  constructor <;> norm_num <;> linarith

end SexticHintValue