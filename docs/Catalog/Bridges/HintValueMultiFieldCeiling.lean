/-
# HINT-VALUE-JOINT, cycle 2: one orientation bit **per field**

Cycle 1 (`Bridges.HintValueJointCompounding`) proved the *one-bit law*: over a single odd
prime modulus the conditional hint synergy of a factor-residue battery never exceeds one bit,
and the bound is attained.  That immediately raises the question the round-30 experiment
actually lives in, since paper 101 measures a **2-field** joint hint value of `+2.4291` bits
against a per-dial sum of `+1.0288`, i.e. a synergy of `+1.40` bits — *above* the one-field
ceiling.

This file settles the scaling law.  The synergy ceiling is not a universal constant: it is
`log₂` of the number of sign patterns available to the coefficient ring, i.e. **one bit per
field**.

* `HintValueMultiField.SignSelector` — the structure abstracted from cycle 1: a map
  `sel : R → F` separating the two square roots of every square.  A ring carrying a
  selector into `F` has "at most `|F|` sign patterns".
* `HintValueMultiField.MIb_le_add_logb_of_refinement` — the general refinement ceiling: if a
  reading `f` refines `g` and an `F`-valued function of `f` separates the points of a
  `g`-fibre, then `f` carries at most `log₂ |F|` bits more than `g`.
* `HintValueMultiField.hintValue_le_sumHint_add_logb`,
  `hintValue_le_gapHint_add_logb`,
  `HintValueMultiField.hintSynergy_le_logb` — **the `log₂ |F|` law**: conditional hint synergy
  is at most `log₂ |F|` bits.  Cycle 1 is the case `F = Bool`.
* `HintValueMultiField.SignSelector.prod`, `SignSelector.pi`, `zmodSelector` — selectors
  compose: a product of `k` odd prime fields carries a selector into `Bool^k`.
* `HintValueMultiField.hintSynergy_le_two_fields`,
  `HintValueMultiField.hintSynergy_le_num_fields` — **THE-ORIENTATION-BIT-PER-FIELD:** over a
  product of `k` odd prime fields the conditional hint synergy is at most `k` bits.
* `HintValueMultiField.TwoFieldWitness` — a sixteen-sample battery over `ZMod 7 × ZMod 7` whose
  two conditional dial hints read exactly `0` bits and whose joint hint value reads exactly
  `2` bits: the two-field ceiling is attained exactly.
* `HintValueMultiField.one_point_four_bits_needs_two_fields` — the quantitative verdict on
  paper 101: a conditional hint synergy of `1.4` bits is **impossible over a single prime
  field** and **realisable over two**.  The round-30 number is therefore not evidence that
  "hints compound like capacities" (capacity synergy has no such ceiling, paper 92); it is
  evidence of nothing more than the number of fields in the modulus.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 2): (H4) the one-bit ceiling of cycle 1 is an artefact of working
  over a single prime and the true law is `ceiling = number of prime fields`;  (H5) the
  ceiling is attained for every `k`, by a product of `k` copies of the mod-`7` orientation
  battery;  (H6) the `+1.40` bits of paper 101 are below the 2-field ceiling, so they carry no
  information about compounding beyond the arity of the modulus.
Experiment (Stage 2, cycle 2): exact recomputation (see `ComputationalEvidence.md`).  The
  16-sample product battery over `ZMod 7 × ZMod 7` reads `H(T) = 2`, `I(T;N) = 0`,
  `I(T;N,s) = 0`, `I(T;N,d) = 0`, `I(T;s,d) = 2`; hence `sumHint = gapHint = 0`,
  `jointHint = 2`, synergy `= +2.000000` — exactly the two-field ceiling.  Randomised search
  over single-prime batteries (`200 000` trials, `m ∈ {5,7,11,13}`, up to `12` samples and `6`
  labels) never produced synergy above `1.000000`.
Analysis (Stage 3, cycle 2): (H4) and (H6) are theorems below; (H5) is verified for `k = 1`
  and `k = 2` and left as conjecture C2 of `FUTURE_DIRECTIONS.md` for general `k` — the general
  case needs an entropy-additivity lemma for product populations, which the catalog does not
  yet have.  The structural picture: the `(s,d)` view refines the `(N,s)` view exactly along
  the involution `d ↦ -d`, whose fixed-point-free part has `2^k` orbits of size ... in a
  product of `k` fields the sign group is `{±1}^k`, and `log₂ |{±1}^k| = k` is the whole
  story.  "Hints compound" is therefore a statement about the sign group of the modulus, not
  about information at all.
Critique (Stage 4, cycle 2): the selector hypothesis is not cosmetic — over a ring with
  nilpotents (e.g. `ZMod 9`, where `3² = 0² `) no selector exists and the ceiling genuinely
  fails to be `log₂` of anything small; this is why every theorem carries an explicit
  `SignSelector`.  All witness entropies are exact rationals computed from fibre counts;
  no `native_decide` and no floating-point input anywhere.
-/
import Mathlib
import Bridges.HintValueJointCompounding

namespace HintValueMultiField

open TraceBattery BatterySynergy SumDiffSplit HintValueJoint

/-! ## 1. Sign selectors -/

/-- A **sign selector** for a commutative ring `R` with values in `F`: a map that separates the
square roots of every square.  Over a field it is a choice of "positive" square root; over a
product of `k` fields the natural target is `Bool^k`. -/
structure SignSelector (R : Type*) [CommRing R] (F : Type*) where
  /-- The selecting map. -/
  sel : R → F
  /-- Two elements with the same square and the same selector value are equal. -/
  sound : ∀ a b : R, a * a = b * b → sel a = sel b → a = b

/-- The sign selector of an odd prime modulus: the lower half of the representatives. -/
def zmodSelector {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1) : SignSelector (ZMod p) Bool :=
  ⟨zsel, zsel_sound hp⟩

/-- **Selectors multiply.**  A product ring inherits a selector with values in the product of
the targets: the sign patterns of `R × S` are pairs of sign patterns. -/
def SignSelector.prod {R S F G : Type*} [CommRing R] [CommRing S]
    (S₁ : SignSelector R F) (S₂ : SignSelector S G) : SignSelector (R × S) (F × G) where
  sel a := (S₁.sel a.1, S₂.sel a.2)
  sound a b h hs := by
    have h1 : a.1 * a.1 = b.1 * b.1 := congrArg Prod.fst h
    have h2 : a.2 * a.2 = b.2 * b.2 := congrArg Prod.snd h
    exact Prod.ext (S₁.sound _ _ h1 (congrArg Prod.fst hs))
      (S₂.sound _ _ h2 (congrArg Prod.snd hs))

/-- **Selectors are closed under arbitrary finite products of fields.** -/
def SignSelector.pi {ι : Type*} {R : ι → Type*} {F : ι → Type*} [∀ i, CommRing (R i)]
    (S : ∀ i, SignSelector (R i) (F i)) : SignSelector (∀ i, R i) (∀ i, F i) where
  sel a := fun i => (S i).sel (a i)
  sound a b h hs := by
    funext i
    exact (S i).sound _ _ (congrFun h i) (congrFun hs i)

/-! ## 2. The `log₂ |F|` refinement ceiling -/

section Calculus

variable {Ω : Type*} [Fintype Ω] {α β Λ F : Type*} [Fintype F]

private theorem logb_le_logb_nat {c k : ℕ} (hc : c ≤ k) :
    Real.logb 2 (c : ℝ) ≤ Real.logb 2 (k : ℝ) := by
  rcases Nat.eq_zero_or_pos c with rfl | hpos
  · simp only [Nat.cast_zero, Real.logb_zero]
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp
    · exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hk)
  · exact Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast hpos) (by exact_mod_cast hc)

/-- An `F`-valued statistic carries at most `log₂ |F|` bits. -/
theorem Hb_le_logb_card (e : Ω → F) : Hb e ≤ Real.logb 2 (Fintype.card F) := by
  classical
  refine le_trans (Hb_le_logb_card_img e) (logb_le_logb_nat ?_)
  simpa [Finset.card_univ] using Finset.card_le_univ (img e)

/-- **The refinement ceiling.**  If `f` refines `g`, and an `F`-valued function of `f`
separates the points of every `g`-fibre, then `f` carries at most `log₂ |F|` bits more than
`g` about any label.  Cycle 1's binary ceiling is the case `F = Bool`. -/
theorem MIb_le_add_logb_of_refinement [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β)
    (e : α → F)
    (hcoarse : ∀ x y, f x = f y → g x = g y)
    (hsplit : ∀ x y, g x = g y → e (f x) = e (f y) → f x = f y) :
    MIb L f ≤ MIb L g + Real.logb 2 (Fintype.card F) := by
  have hsame : ∀ x y, f x = f y ↔ (g x, e (f x)) = (g y, e (f y)) := by
    intro x y
    refine ⟨fun h => Prod.ext (hcoarse x y h) (by rw [h]), fun h =>
      hsplit x y (congrArg Prod.fst h) (congrArg Prod.snd h)⟩
  rw [MIb_eq_of_same_fibers L f (fun x => (g x, e (f x))) hsame]
  have h1 := MIb_pair_le_add_Hb L g (fun x => e (f x))
  have h2 := Hb_le_logb_card (fun x => e (f x))
  linarith

end Calculus

/-! ## 3. The `log₂ |F|` law for hint synergy -/

section Law

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} {R F : Type*} [CommRing R]
  [Invertible (2 : R)] [Fintype F]

/-- **The sum form of the `log₂ |F|` law.** -/
theorem hintValue_le_sumHint_add_logb (L : Ω → Λ) (P Q : Ω → R) (S : SignSelector R F) :
    hintValue L P Q ≤ sumHint L P Q + Real.logb 2 (Fintype.card F) := by
  have key : MIb L (residueView P Q)
      ≤ MIb L (sumHintView P Q) + Real.logb 2 (Fintype.card F) := by
    refine MIb_le_add_logb_of_refinement L (residueView P Q) (sumHintView P Q)
      (fun v => S.sel v.2) ?_ ?_
    · intro x y h
      rw [sumHintView_comp]
      simp only [Function.comp_apply, h]
    · intro x y hg he
      exact Prod.ext (congrArg Prod.snd hg)
        (S.sound _ _ (gap_sq_eq_of_sumHintView_eq P Q hg) he)
  simp only [hintValue, sumHint]; linarith

/-- **The gap form of the `log₂ |F|` law.** -/
theorem hintValue_le_gapHint_add_logb (L : Ω → Λ) (P Q : Ω → R) (S : SignSelector R F) :
    hintValue L P Q ≤ gapHint L P Q + Real.logb 2 (Fintype.card F) := by
  have key : MIb L (residueView P Q)
      ≤ MIb L (gapHintView P Q) + Real.logb 2 (Fintype.card F) := by
    refine MIb_le_add_logb_of_refinement L (residueView P Q) (gapHintView P Q)
      (fun v => S.sel v.1) ?_ ?_
    · intro x y h
      rw [gapHintView_comp]
      simp only [Function.comp_apply, h]
    · intro x y hg he
      have hd : gapView P Q x = gapView P Q y := congrArg Prod.snd hg
      have hs : sumView P Q x = sumView P Q y :=
        S.sound _ _ (sum_sq_eq_of_gapHintView_eq P Q hg) he
      exact Prod.ext hs hd
  simp only [hintValue, gapHint]; linarith

/-- **THE-ORIENTATION-BITS.**  Conditional hint synergy is at most `log₂` of the number of sign
patterns of the coefficient ring.  Nothing about the population, the label alphabet or the
size of the residues enters. -/
theorem hintSynergy_le_logb (L : Ω → Λ) (P Q : Ω → R) (S : SignSelector R F) :
    hintSynergy L P Q ≤ Real.logb 2 (Fintype.card F) := by
  have h := hintValue_le_sumHint_add_logb L P Q S
  have h1 := sumHint_nonneg L P Q
  have h2 := gapHint_nonneg L P Q
  simp only [hintSynergy]; linarith

end Law

/-! ## 4. Products of odd prime fields: one bit per field -/

section Fields

/-- `2` is invertible in a product ring as soon as it is invertible in both factors. -/
instance invertibleTwoProd {R S : Type*} [CommRing R] [CommRing S] [Invertible (2 : R)]
    [Invertible (2 : S)] : Invertible (2 : R × S) where
  invOf := (⅟(2 : R), ⅟(2 : S))
  invOf_mul_self := Prod.ext (by simp) (by simp)
  mul_invOf_self := Prod.ext (by simp) (by simp)

/-- `2` is invertible in a product of rings in which it is invertible. -/
instance invertibleTwoPi {ι : Type*} {R : ι → Type*} [∀ i, CommRing (R i)]
    [∀ i, Invertible (2 : R i)] : Invertible (2 : ∀ i, R i) where
  invOf := fun i => ⅟(2 : R i)
  invOf_mul_self := by funext i; simp
  mul_invOf_self := by funext i; simp

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*}

/-- **Two fields, two bits.**  Over a product of two odd prime fields the conditional hint
synergy is at most `2` bits — and, by `two_field_ceiling_attained`, exactly `2` is reached. -/
theorem hintSynergy_le_two_fields {p q : ℕ} [Fact p.Prime] [Fact q.Prime]
    (hp : p % 2 = 1) (hq : q % 2 = 1) (L : Ω → Λ) (P Q : Ω → ZMod p × ZMod q) :
    hintSynergy L P Q ≤ 2 := by
  letI := invertibleTwoOfOdd hp
  letI := invertibleTwoOfOdd hq
  have h := hintSynergy_le_logb L P Q ((zmodSelector hp).prod (zmodSelector hq))
  have hcard : (Fintype.card (Bool × Bool) : ℝ) = 4 := by simp
  rw [hcard] at h
  have hl : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have h4 : Real.logb 2 (4 : ℝ) = 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num]
    simp only [Real.logb, Real.log_pow]
    field_simp
    norm_num
  linarith [h, h4.le]

/-- **One orientation bit per field.**  Over a product of `k` odd prime fields the conditional
hint synergy is at most `k` bits.  The ceiling is `log₂` of the order of the sign group
`{±1}^k`: hints do not "compound like capacities" — they compound like square roots. -/
theorem hintSynergy_le_num_fields {k : ℕ} (p : Fin k → ℕ) [∀ i, Fact (p i).Prime]
    (hp : ∀ i, p i % 2 = 1) (L : Ω → Λ) (P Q : Ω → ∀ i, ZMod (p i)) :
    hintSynergy L P Q ≤ (k : ℝ) := by
  letI : ∀ i, Invertible (2 : ZMod (p i)) := fun i => invertibleTwoOfOdd (hp i)
  have h := hintSynergy_le_logb L P Q (SignSelector.pi fun i => zmodSelector (hp i))
  have hcard : (Fintype.card (Fin k → Bool) : ℝ) = 2 ^ k := by simp
  rw [hcard] at h
  have hl : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hlog : Real.logb 2 ((2 : ℝ) ^ k) = k := by
    simp only [Real.logb, Real.log_pow]
    field_simp
  rw [hlog] at h
  exact h

end Fields

/-! ## 5. The two-field ceiling is attained exactly -/

namespace TwoFieldWitness

/-- Sixteen samples over `ZMod 7 × ZMod 7`: the product of two copies of the mod-`7`
orientation battery of cycle 1.  Both coordinates sit on the hyperbola `p q = 1`. -/
def P : Fin 16 → ZMod 7 × ZMod 7 :=
  ![(2, 2), (2, 4), (2, 3), (2, 5), (4, 2), (4, 4), (4, 3), (4, 5),
    (3, 2), (3, 4), (3, 3), (3, 5), (5, 2), (5, 4), (5, 3), (5, 5)]

def Q : Fin 16 → ZMod 7 × ZMod 7 :=
  ![(4, 4), (4, 2), (4, 5), (4, 3), (2, 4), (2, 2), (2, 5), (2, 3),
    (5, 4), (5, 2), (5, 5), (5, 3), (3, 4), (3, 2), (3, 5), (3, 3)]

/-- The label is the pair of orientation bits, one per field. -/
def L : Fin 16 → Fin 4 :=
  ![0, 1, 1, 0, 2, 3, 3, 2, 2, 3, 3, 2, 0, 1, 1, 0]

theorem product_const (x y : Fin 16) : productView P Q x = productView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem cnt_L (x : Fin 16) : cnt L (L x) = 4 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_sumHint (x : Fin 16) : cnt (sumHintView P Q) (sumHintView P Q x) = 4 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_gapHint (x : Fin 16) : cnt (gapHintView P Q) (gapHintView P Q x) = 4 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_sumHint (x : Fin 16) :
    cnt (pr L (sumHintView P Q)) (pr L (sumHintView P Q) x) = 1 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_gapHint (x : Fin 16) :
    cnt (pr L (gapHintView P Q)) (pr L (gapHintView P Q) x) = 1 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem residue_determines (x y : Fin 16) :
    residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem log_sixteen : Real.log 16 = 4 * Real.log 2 := by
  rw [show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, Real.log_pow]
  push_cast; ring

theorem H_L : H L = Real.log 16 - Real.log 4 := by
  have h := SumDiffSynergy.H_eq_of_uniform_counts L 4 (by norm_num) cnt_L
  norm_num at h
  rw [h]

theorem Hb_L : Hb L = 2 := by
  rw [Hb, H_L, log_sixteen, SumDiffSynergy.log_four]
  field_simp
  ring

theorem MIb_product : MIb L (productView P Q) = 0 := by
  rw [MIb, MI_eq_zero_of_const L _ product_const, zero_div]

/-- The sum hint reads exactly zero bits on the two-field battery. -/
theorem MIb_sumHintView : MIb L (sumHintView P Q) = 0 := by
  have hf : H (sumHintView P Q) = Real.log 16 - Real.log 4 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (sumHintView P Q) 4 (by norm_num) cnt_sumHint
    norm_num at h
    rw [h]
  have hpr : H (pr L (sumHintView P Q)) = Real.log 16 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (pr L (sumHintView P Q)) 1 (by norm_num)
      cnt_pr_sumHint
    norm_num at h
    rw [h]
  have : MI L (sumHintView P Q) = 0 := by
    rw [MI_eq, H_L, hf, hpr, log_sixteen, SumDiffSynergy.log_four]; ring
  rw [MIb, this, zero_div]

/-- The gap hint reads exactly zero bits on the two-field battery. -/
theorem MIb_gapHintView : MIb L (gapHintView P Q) = 0 := by
  have hf : H (gapHintView P Q) = Real.log 16 - Real.log 4 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (gapHintView P Q) 4 (by norm_num) cnt_gapHint
    norm_num at h
    rw [h]
  have hpr : H (pr L (gapHintView P Q)) = Real.log 16 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (pr L (gapHintView P Q)) 1 (by norm_num)
      cnt_pr_gapHint
    norm_num at h
    rw [h]
  have : MI L (gapHintView P Q) = 0 := by
    rw [MI_eq, H_L, hf, hpr, log_sixteen, SumDiffSynergy.log_four]; ring
  rw [MIb, this, zero_div]

theorem sumHint_eq_zero : sumHint L P Q = 0 := by
  rw [sumHint, MIb_sumHintView, MIb_product]; ring

theorem gapHint_eq_zero : gapHint L P Q = 0 := by
  rw [gapHint, MIb_gapHintView, MIb_product]; ring

/-- The joint residue view reads exactly two bits: one orientation bit per field. -/
theorem hintValue_eq_two : hintValue L P Q = 2 := by
  rw [hintValue, MIb_eq_label_entropy_of_determines L _ residue_determines, Hb_L, MIb_product]
  ring

/-- **The two-field ceiling is attained: synergy exactly `+2`.** -/
theorem hintSynergy_eq_two : hintSynergy L P Q = 2 := by
  rw [hintSynergy, hintValue_eq_two, sumHint_eq_zero, gapHint_eq_zero]
  ring

end TwoFieldWitness

/-- **Sharpness of the two-field law.** -/
theorem two_field_ceiling_attained :
    ∃ (L : Fin 16 → Fin 4) (P Q : Fin 16 → ZMod 7 × ZMod 7),
      sumHint L P Q = 0 ∧ gapHint L P Q = 0 ∧ hintValue L P Q = 2 ∧ hintSynergy L P Q = 2 :=
  ⟨TwoFieldWitness.L, TwoFieldWitness.P, TwoFieldWitness.Q, TwoFieldWitness.sumHint_eq_zero,
    TwoFieldWitness.gapHint_eq_zero, TwoFieldWitness.hintValue_eq_two,
    TwoFieldWitness.hintSynergy_eq_two⟩

/-- **The verdict on the round-30 number.**  A conditional hint synergy of `1.4` bits cannot
occur over a single odd prime field, and does occur over two.  So `+1.40` bits is not a
measurement of "compounding": it is a measurement of the arity of the modulus, and the honest
statement of THE-HINTS-COMPOUND is *one orientation bit per field*. -/
theorem one_point_four_bits_needs_two_fields :
    (∀ (p : ℕ) (_ : Fact p.Prime) (_ : p % 2 = 1) {Ω : Type} [Fintype Ω] [Nonempty Ω]
        {Λ : Type} (L : Ω → Λ) (P Q : Ω → ZMod p), hintSynergy L P Q < 1.4) ∧
    (∃ (L : Fin 16 → Fin 4) (P Q : Fin 16 → ZMod 7 × ZMod 7), (1.4 : ℝ) ≤ hintSynergy L P Q) := by
  constructor
  · intro p hfact hp Ω _ _ Λ L P Q
    have h := hintSynergy_le_one_zmod hp L P Q
    linarith
  · exact ⟨TwoFieldWitness.L, TwoFieldWitness.P, TwoFieldWitness.Q, by
      rw [TwoFieldWitness.hintSynergy_eq_two]; norm_num⟩

end HintValueMultiField