/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoice

/-!
# Tropical social choice II: the oligarchy classification

This file continues `Probability.TropicalSocialChoice`, where the *tropical Arrow
theorem* was proved: in the min-plus semiring `TR = Tropical (WithTop ℝ)`, a rule
`f : TRⁿ → TR` satisfying tropical IIA (`f (x ⊕ y) = f x ⊕ f y`), tropical Pareto
(`f (c,…,c) = c`) and tropical multiplicativity (`f (x ⊙ y) = f x ⊙ f y`) is the
projection onto a single voter.

Here we determine exactly what happens when tropical multiplicativity is replaced by two
strictly weaker requirements, resolving the first two conjectures recorded in
`FUTURE_DIRECTIONS.md` for tropically linear rules.

## Main results

* `TropDiagIdem`, `oligarchy_of_diagIdem`, `oligarchy_iff` : **diagonal idempotence**
  `f (x ⊙ x) = f x ⊙ f x` — multiplicativity restricted to the diagonal — replaces full
  multiplicativity, and the solution set jumps from the `n` dictators to the `2ⁿ − 1`
  *coalition (oligarchy) rules* `x ↦ ⨁_{i ∈ s} xᵢ`, `s ≠ ∅`.
* `tropCoalition_isTropDictatorial_iff` : a coalition rule is a dictatorship precisely
  when the coalition is a singleton, so for `n ≥ 2` the escape from Arrow's conclusion is
  genuine and its size is exactly `2ⁿ − 1 − n`
  (`card_nondictatorial_coalitions`).
* `TropConstScaleInv`, `isTropLinear_of_tropIIA_constScale`,
  `tropIIA_constScale_iff` : invariance under a *common* cost shift
  `f (c ⊙ x) = c ⊙ f x` still forces tropical linearity, but only pins the coefficients
  down to `⨁ᵢ aᵢ = 1`; the solution set is exactly the unanimous tropical linear forms,
  which for `n ≥ 2` contains non-dictatorial members
  (`exists_nondictatorial_tropConstScaleInv`).

* `softMin_le_sub_log_card_pivotal`, `softMin_lt_inf'_of_one_lt_card_pivotal` : a sharpened
  Maslov dequantisation bound.  The Boltzmann aggregator satisfies
  `min y − log (#s)/t ≤ softMin ≤ min y − log m / t`, where `m` is the number of *pivotal*
  (cost-minimising) voters; in particular a tie of two pivotal voters keeps the smoothed
  rule strictly below the tropical value by `log 2 / t` at every temperature.

Together with the tropical Arrow theorem this gives a complete picture of the axiom
hierarchy: full multiplicativity ⟹ dictator; diagonal multiplicativity ⟹ oligarchy;
scalar multiplicativity ⟹ arbitrary unanimous weights.
-/

namespace TropicalSocialChoice

open Tropical

/-! ## Tropical arithmetic lemmas -/

/-- The tropical idempotents for multiplication are exactly `0 = ⊤` and `1 = 0`: a cost
`c` with `c + c = c` is either infinite or zero. -/
theorem eq_zero_or_one_of_mul_self {c : TR} (h : c * c = c) : c = 0 ∨ c = 1 := by
  rcases eq_or_ne c 0 with h0 | h0
  · exact Or.inl h0
  · right
    have hu : untrop c ≠ ⊤ := fun ht => h0 (untrop_injective (by rw [ht]; rfl))
    obtain ⟨r, hr⟩ := WithTop.ne_top_iff_exists.mp hu
    have h1 := congrArg untrop h
    rw [untrop_mul, ← hr, ← WithTop.coe_add, WithTop.coe_eq_coe] at h1
    have hr0 : r = 0 := by linarith
    exact untrop_injective (by rw [← hr, hr0]; rfl)

/-- Tropical "squaring" is additive: `2·min (x, y) = min (2x, 2y)`. -/
theorem mul_self_add (x y : TR) : (x + y) * (x + y) = x * x + y * y := by
  apply untrop_injective
  simp only [untrop_mul, untrop_add]
  rcases le_total (untrop x) (untrop y) with h | h
  · rw [min_eq_left h, min_eq_left (add_le_add h h)]
  · rw [min_eq_right h, min_eq_right (add_le_add h h)]

/-! ## Diagonal idempotence and the oligarchy theorem -/

section Oligarchy

variable {n : ℕ}

/-- **Diagonal multiplicativity.**  Doubling everybody's cost doubles the social cost.
This is tropical multiplicativity `f (x ⊙ y) = f x ⊙ f y` restricted to `y = x`, and it is
the natural "no money illusion" requirement: the social aggregate is homogeneous of
degree one along the diagonal. -/
def TropDiagIdem (f : (Fin n → TR) → TR) : Prop := ∀ x, f (x * x) = f x * f x

/-- Tropical multiplicativity implies diagonal idempotence. -/
theorem TropScaleInv.tropDiagIdem {f : (Fin n → TR) → TR} (h : TropScaleInv f) :
    TropDiagIdem f := fun x => h x x

/-- Every coalition rule is diagonally idempotent: `minᵢ (2xᵢ) = 2 minᵢ xᵢ`. -/
theorem tropCoalition_tropDiagIdem (s : Finset (Fin n)) : TropDiagIdem (tropCoalition s) := by
  classical
  intro x
  show ∑ i ∈ s, (x * x) i = (∑ i ∈ s, x i) * (∑ i ∈ s, x i)
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, mul_self_add, ih, Pi.mul_apply]

/-- The unit profile `eⱼ` is a tropical idempotent. -/
theorem single_mul_single (j : Fin n) :
    (Pi.single j (1 : TR) : Fin n → TR) * Pi.single j 1 = Pi.single j 1 := by
  classical
  funext i
  by_cases hij : i = j
  · subst hij
    show (Pi.single i (1 : TR) : Fin n → TR) i * (Pi.single i (1 : TR) : Fin n → TR) i = _
    rw [Pi.single_eq_same, mul_one]
  · show (Pi.single j (1 : TR) : Fin n → TR) i * (Pi.single j (1 : TR) : Fin n → TR) i = _
    rw [Pi.single_eq_of_ne hij, mul_zero]

/-- **Key step.**  Diagonal idempotence forces every coefficient of a tropical linear form
to be `0` (the voter is ignored) or `1` (the voter enters with no handicap). -/
theorem coeff_eq_zero_or_one_of_diagIdem {a : Fin n → TR} (h : TropDiagIdem (tropForm a))
    (j : Fin n) : a j = 0 ∨ a j = 1 := by
  have h1 := h (Pi.single j 1)
  rw [single_mul_single, tropForm_apply_single] at h1
  exact eq_zero_or_one_of_mul_self h1.symm

/-- A tropical linear form with `0/1` coefficients is the coalition rule of its
oligarchy. -/
theorem tropForm_eq_tropCoalition_of_coeff {a : Fin n → TR} (h : ∀ i, a i = 0 ∨ a i = 1) :
    tropForm a = tropCoalition (tropSupport a) := by
  classical
  funext x
  have h1 : ∑ i ∈ tropSupport a, a i * x i = tropCoalition (tropSupport a) x :=
    Finset.sum_congr rfl fun i hi => by rw [(Finset.mem_filter.mp hi).2, one_mul]
  have h2 : ∑ i ∈ Finset.univ \ tropSupport a, a i * x i = 0 :=
    Finset.sum_eq_zero fun i hi => by
      have hne : a i ≠ 1 := by
        have := (Finset.mem_sdiff.mp hi).2
        simpa [tropSupport] using this
      rcases h i with h0 | h1'
      · rw [h0, zero_mul]
      · exact absurd h1' hne
  rw [tropForm, ← Finset.sum_sdiff (Finset.subset_univ (tropSupport a)), h1, h2, zero_add]

/-- **Oligarchy theorem.**  A tropically linear, unanimous, diagonally idempotent social
welfare function is the minimum rule of a nonempty coalition of voters.  This is the exact
analogue of the classical Gibbard oligarchy theorem, and it strictly weakens the
hypotheses of the tropical Arrow theorem. -/
theorem oligarchy_of_diagIdem {f : (Fin n → TR) → TR} (hlin : IsTropLinear f)
    (hpar : TropPareto f) (hidem : TropDiagIdem f) :
    ∃ s : Finset (Fin n), s.Nonempty ∧ f = tropCoalition s := by
  obtain ⟨a, ha⟩ := hlin
  have hf : f = tropForm a := funext ha
  subst hf
  have hsum : ∑ i, a i = 1 := (tropPareto_tropForm_iff a).mp hpar
  exact ⟨tropSupport a, tropSupport_nonempty hsum,
    tropForm_eq_tropCoalition_of_coeff (coeff_eq_zero_or_one_of_diagIdem hidem)⟩

/-- **Exact classification** of the rules satisfying tropical linearity, tropical Pareto
and diagonal idempotence: they are precisely the nonempty coalition rules. -/
theorem oligarchy_iff (f : (Fin n → TR) → TR) :
    (IsTropLinear f ∧ TropPareto f ∧ TropDiagIdem f) ↔
      ∃ s : Finset (Fin n), s.Nonempty ∧ f = tropCoalition s := by
  constructor
  · rintro ⟨hlin, hpar, hidem⟩
    exact oligarchy_of_diagIdem hlin hpar hidem
  · rintro ⟨s, hs, rfl⟩
    exact ⟨tropCoalition_isTropLinear s, tropCoalition_tropPareto hs,
      tropCoalition_tropDiagIdem s⟩

/-- The singleton coalition rule is the dictator. -/
theorem tropCoalition_singleton (k : Fin n) : tropCoalition {k} = tropDictator k := by
  funext x
  rw [tropCoalition, Finset.sum_singleton]
  rfl

/-- Evaluating a coalition rule at a unit profile detects membership. -/
theorem tropCoalition_single (s : Finset (Fin n)) {p : Fin n} (hp : p ∈ s) :
    tropCoalition s (Pi.single p 1) = 1 := by
  classical
  rw [tropCoalition, Finset.sum_eq_single p]
  · simp
  · intro b _ hb
    exact Pi.single_eq_of_ne hb 1
  · intro h; exact absurd hp h

/-- The empty coalition (the constant rule `x ↦ ⊤`) is not a dictatorship. -/
theorem tropCoalition_empty_not_dictatorial :
    ¬ IsTropDictatorial (tropCoalition (∅ : Finset (Fin n))) := by
  rintro ⟨m, hm⟩
  have h1 : tropCoalition (∅ : Finset (Fin n)) (Pi.single m 1) = 0 := by
    simp [tropCoalition]
  rw [hm] at h1
  have h2 : tropDictator m (Pi.single m (1 : TR)) = 1 := Pi.single_eq_same _ _
  rw [h2] at h1
  exact one_ne_zero h1

/-- **A coalition rule is a dictatorship exactly when the coalition is a singleton.**
Hence the non-dictatorial solutions of the weakened axiom system are exactly the coalition
rules whose coalition has size `≠ 1`. -/
theorem tropCoalition_isTropDictatorial_iff (s : Finset (Fin n)) :
    IsTropDictatorial (tropCoalition s) ↔ s.card = 1 := by
  classical
  constructor
  · intro hdict
    rcases Nat.lt_or_ge s.card 1 with hlt | hge
    · have hs : s = ∅ := Finset.card_eq_zero.mp (by omega)
      subst hs
      exact absurd hdict tropCoalition_empty_not_dictatorial
    · rcases eq_or_lt_of_le hge with heq | hlt2
      · exact heq.symm
      · obtain ⟨j, hj, k, hk, hjk⟩ := Finset.one_lt_card.mp hlt2
        exact absurd hdict (tropCoalition_not_dictatorial hj hk hjk)
  · intro hcard
    obtain ⟨k, hk⟩ := Finset.card_eq_one.mp hcard
    exact ⟨k, by rw [hk, tropCoalition_singleton]⟩

/-- **The size of the tropical escape.**  There are `2ⁿ` coalitions, one of which is empty
and `n` of which are singletons, so the weakened axiom system has exactly `2ⁿ − 1 − n`
non-dictatorial solutions. -/
theorem card_nondictatorial_coalitions (n : ℕ) :
    ((Finset.univ : Finset (Finset (Fin n))).filter
        (fun s => s.Nonempty ∧ s.card ≠ 1)).card = 2 ^ n - 1 - n := by
  classical
  have hsmall : (Finset.univ.filter (fun s : Finset (Fin n) => s.card ≤ 1))
      = insert ∅ (Finset.univ.image (fun k : Fin n => ({k} : Finset (Fin n)))) := by
    ext s
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_image]
    constructor
    · intro hs
      rcases Nat.lt_or_ge s.card 1 with h | h
      · exact Or.inl (Finset.card_eq_zero.mp (by omega))
      · obtain ⟨k, hk⟩ := Finset.card_eq_one.mp (show s.card = 1 by omega)
        exact Or.inr ⟨k, hk.symm⟩
    · rintro (rfl | ⟨k, rfl⟩) <;> simp
  have hcard : (Finset.univ.filter (fun s : Finset (Fin n) => s.card ≤ 1)).card = n + 1 := by
    rw [hsmall, Finset.card_insert_of_notMem, Finset.card_image_of_injective _
      Finset.singleton_injective, Finset.card_univ, Fintype.card_fin]
    simp
  have hfilter : (Finset.univ.filter (fun s : Finset (Fin n) => s.Nonempty ∧ s.card ≠ 1))
      = Finset.univ.filter (fun s : Finset (Fin n) => ¬ s.card ≤ 1) := by
    apply Finset.filter_congr
    intro s _
    constructor
    · rintro ⟨h1, h2⟩
      have := Finset.card_pos.mpr h1
      omega
    · intro h
      exact ⟨Finset.card_pos.mp (by omega), by omega⟩
  have htot := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset (Finset (Fin n)))) (p := fun s : Finset (Fin n) => s.card ≤ 1)
  rw [Finset.card_univ, Fintype.card_finset, Fintype.card_fin] at htot
  rw [hfilter]
  omega

end Oligarchy

/-! ## Scalar invariance: linearity without dictatorship -/

section ConstScale

variable {n : ℕ}

/-- **Scalar tropical invariance.**  Shifting every voter's costs by the same amount `c`
shifts the social cost by `c`.  This is tropical multiplicativity restricted to constant
profiles. -/
def TropConstScaleInv (f : (Fin n → TR) → TR) : Prop :=
  ∀ (c : TR) (x : Fin n → TR), f ((fun _ => c) * x) = c * f x

/-- Tropical multiplicativity together with unanimity implies scalar invariance. -/
theorem TropScaleInv.tropConstScaleInv {f : (Fin n → TR) → TR} (hmul : TropScaleInv f)
    (hpar : TropPareto f) : TropConstScaleInv f := fun c x => by
  rw [hmul, hpar]

/-- Tropical linear forms are scalar invariant. -/
theorem tropForm_tropConstScaleInv (a : Fin n → TR) : TropConstScaleInv (tropForm a) := by
  intro c x
  rw [tropForm, tropForm, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by
    show a i * (c * x i) = c * (a i * x i)
    ring

/-- **Linearity from scalar invariance.**  Tropical IIA, unanimity and scalar invariance
already force `f` to be a tropical linear form with coefficients `f (eᵢ)`; full
multiplicativity is not needed for this step. -/
theorem isTropLinear_of_tropIIA_constScale {f : (Fin n → TR) → TR} (hiia : TropIIA f)
    (hpar : TropPareto f) (hscale : TropConstScaleInv f) : IsTropLinear f := by
  refine ⟨fun i => f (Pi.single i 1), fun x => ?_⟩
  conv_lhs => rw [profile_decomposition x]
  rw [tropIIA_finset_sum hiia (TropPareto.map_zero hpar), tropForm]
  exact Finset.sum_congr rfl fun i _ => by rw [hscale, mul_comm]

/-- **Exact classification under the scalar axiom system.**  Tropical IIA + tropical
Pareto + scalar invariance characterise precisely the *unanimous tropical linear forms*
`x ↦ ⨁ᵢ aᵢ ⊙ xᵢ` with `⨁ᵢ aᵢ = 1` — a far larger family than the dictators. -/
theorem tropIIA_constScale_iff (f : (Fin n → TR) → TR) :
    (TropIIA f ∧ TropPareto f ∧ TropConstScaleInv f) ↔
      ∃ a : Fin n → TR, (∑ i, a i = 1) ∧ f = tropForm a := by
  constructor
  · rintro ⟨hiia, hpar, hscale⟩
    obtain ⟨a, ha⟩ := isTropLinear_of_tropIIA_constScale hiia hpar hscale
    have hf : f = tropForm a := funext ha
    subst hf
    exact ⟨a, (tropPareto_tropForm_iff a).mp hpar, rfl⟩
  · rintro ⟨a, hsum, rfl⟩
    exact ⟨(IsTropLinear.tropIIA ⟨a, fun _ => rfl⟩), (tropPareto_tropForm_iff a).mpr hsum,
      tropForm_tropConstScaleInv a⟩

/-- With at least two voters the scalar axiom system admits non-dictatorial solutions:
the Rawlsian rule again. -/
theorem exists_nondictatorial_tropConstScaleInv (hn : 2 ≤ n) :
    ∃ f : (Fin n → TR) → TR,
      TropIIA f ∧ TropPareto f ∧ TropConstScaleInv f ∧ ¬ IsTropDictatorial f := by
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  obtain ⟨a, ha⟩ := tropCoalition_isTropLinear (Finset.univ : Finset (Fin n))
  have hf : tropCoalition (Finset.univ : Finset (Fin n)) = tropForm a := funext ha
  refine ⟨tropCoalition Finset.univ, tropCoalition_tropIIA _,
    tropCoalition_tropPareto ⟨⟨0, h0⟩, Finset.mem_univ _⟩, ?_, ?_⟩
  · rw [hf]; exact tropForm_tropConstScaleInv a
  · refine tropCoalition_not_dictatorial (j := ⟨0, h0⟩) (k := ⟨1, h1⟩) (Finset.mem_univ _)
      (Finset.mem_univ _) ?_
    simp [Fin.ext_iff]

end ConstScale

/-! ## Sharpened dequantisation: the pivotal-voter correction -/

section Dequantisation

variable {ι : Type*}

open Finset in
/-- The *pivotal voters* of a profile: the members of the coalition whose cost attains the
minimum.  Their number is what measures the failure of the finite-temperature rule to be a
dictatorship. -/
noncomputable def pivotal (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) : Finset ι := by
  classical
  exact s.filter fun i => y i = s.inf' hs y

theorem pivotal_subset (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) :
    pivotal s hs y ⊆ s := by
  classical
  exact Finset.filter_subset _ _

theorem pivotal_nonempty (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) :
    (pivotal s hs y).Nonempty := by
  classical
  obtain ⟨i₀, hi₀s, hi₀⟩ := Finset.exists_mem_eq_inf' hs y
  exact ⟨i₀, Finset.mem_filter.mpr ⟨hi₀s, hi₀.symm⟩⟩

/-- **Sharpened upper bound for Maslov dequantisation.**  The Boltzmann aggregator is below
the tropical minimum by at least `log m / t`, where `m` is the number of *pivotal* voters.
Together with `softMin_bounds` this squeezes `softMin` between `min y − log (#s) / t` and
`min y − log m / t`: the deviation from the tropical (and, when `m = 1`, dictatorial) value
is governed by the number of tied voters. -/
theorem softMin_le_sub_log_card_pivotal (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t : ℝ}
    (ht : 0 < t) :
    softMin s t y ≤ s.inf' hs y - Real.log (pivotal s hs y).card / t := by
  classical
  set m := s.inf' hs y with hm
  set P := pivotal s hs y with hP
  have hPs : P ⊆ s := pivotal_subset s hs y
  have hPne : P.Nonempty := pivotal_nonempty s hs y
  have hsum : ∑ i ∈ P, Real.exp (-(t * y i)) = (P.card : ℝ) * Real.exp (-(t * m)) := by
    rw [Finset.sum_congr rfl fun i hi => by
      rw [show y i = m from (Finset.mem_filter.mp hi).2]]
    simp [Finset.sum_const, nsmul_eq_mul]
  have hle : (P.card : ℝ) * Real.exp (-(t * m)) ≤ ∑ i ∈ s, Real.exp (-(t * y i)) := by
    rw [← hsum]
    exact Finset.sum_le_sum_of_subset_of_nonneg hPs fun i _ _ => (Real.exp_pos _).le
  have hcard : (0 : ℝ) < P.card := by exact_mod_cast Finset.card_pos.mpr hPne
  have hposP : (0 : ℝ) < (P.card : ℝ) * Real.exp (-(t * m)) :=
    mul_pos hcard (Real.exp_pos _)
  have hlog : Real.log P.card + -(t * m) ≤ Real.log (∑ i ∈ s, Real.exp (-(t * y i))) := by
    have h := Real.log_le_log hposP hle
    rwa [Real.log_mul (ne_of_gt hcard) (Real.exp_ne_zero _), Real.log_exp] at h
  have hinv : (0 : ℝ) ≤ 1 / t := by positivity
  have h := mul_le_mul_of_nonneg_left hlog hinv
  have e : (1 / t) * (Real.log P.card + -(t * m)) = Real.log P.card / t - m := by
    field_simp; ring
  rw [e] at h
  simp only [softMin]
  linarith

/-- **A tie of pivotal voters is a quantitative obstruction to dictatoriality.**  If at
least two voters are pivotal, the Boltzmann aggregate is strictly below the tropical
minimum, by at least `log 2 / t`, at every finite temperature. -/
theorem softMin_lt_inf'_of_one_lt_card_pivotal (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ)
    {t : ℝ} (ht : 0 < t) (h2 : 2 ≤ (pivotal s hs y).card) :
    softMin s t y ≤ s.inf' hs y - Real.log 2 / t ∧ softMin s t y < s.inf' hs y := by
  have hcard : (2 : ℝ) ≤ (pivotal s hs y).card := by exact_mod_cast h2
  have hlog : Real.log 2 ≤ Real.log (pivotal s hs y).card :=
    Real.log_le_log (by norm_num) hcard
  have hdiv : Real.log 2 / t ≤ Real.log (pivotal s hs y).card / t := by
    apply div_le_div_of_nonneg_right hlog ht.le
  have hmain := softMin_le_sub_log_card_pivotal s hs y ht
  have hpos : 0 < Real.log 2 / t := div_pos (Real.log_pos (by norm_num)) ht
  exact ⟨by linarith, by linarith⟩

end Dequantisation

end TropicalSocialChoice