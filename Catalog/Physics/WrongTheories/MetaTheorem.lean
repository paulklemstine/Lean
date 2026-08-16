import Physics.WrongTheories.PerturbativeCore

/-!
# The meta-theorem on the unreasonable effectiveness of wrong theories

Building on `Physics.WrongTheories.PerturbativeCore`, this file formalises and
proves the meta-theorem:

> for any approximately correct physical theory `T` there is a class of
> phenomena on which `T` predicts better than a given competitor `C`,
> as soon as `C` is not exactly correct on those phenomena.

The key notions are the pointwise prediction error `predErr`, the strict
superiority relation `Beats`, and the *superiority region*
`superiorityRegion` — the class of phenomena on which one theory outpredicts
another.

Main results:

* `WrongTheory.meta_unreasonable_effectiveness` — the meta-theorem: for every
  error threshold `η > 0` there is a coupling window in which the perturbative
  theory beats *every* competitor on *every* phenomenon where the competitor's
  error is at least `η`;
* `WrongTheory.superiorityRegion_nonempty` — the class of phenomena promised by
  the meta-theorem is nonempty as soon as the competitor is inexact somewhere;
* `WrongTheory.closer_iff_halfplane` and `WrongTheory.worlds_favouring` — the
  *epistemic half-space theorem*: for any two distinct predictions, the set of
  possible worlds in which the first beats the second is a nonempty, open,
  unbounded half-line.  Superiority is never absolute, only world-relative;
* `WrongTheory.condorcet_cycle` and `WrongTheory.majorityBeats_not_transitive` —
  empirical adequacy is not a transitive relation: three explicit theories on
  three phenomena form a Condorcet cycle;
* `WrongTheory.exists_nowhere_exact_perturbation` — nowhere-exact ("wrong
  everywhere") theories are dense in theory space over a countable phenomenon
  space, so the hypotheses of the meta-theorem are generic;
* `WrongTheory.every_theory_is_optimal_in_some_world` — no theory is
  intrinsically inferior: each member of a family of rivals is strictly best in
  some world;
* `WrongTheory.pessimistic_meta_induction` — a sequence of theories that are all
  wrong at every phenomenon can still converge uniformly on the truth;
* `WrongTheory.wrongness_add`, `WrongTheory.wrongness_smul` — theory space
  carries a linear structure for which wrongness is linear.
-/

namespace WrongTheory

variable {Φ : Type*}

/-! ### Errors, superiority and superiority regions -/

/-- The prediction error of a theory at a phenomenon, relative to the truth. -/
noncomputable def predErr (T truth : Theory Φ) (p : Φ) : ℝ := |T p - truth p|

lemma predErr_nonneg (T truth : Theory Φ) (p : Φ) : 0 ≤ predErr T truth p :=
  abs_nonneg _

lemma predErr_eq_zero_iff (T truth : Theory Φ) (p : Φ) :
    predErr T truth p = 0 ↔ T p = truth p := by
  simp [predErr, sub_eq_zero]

/-- `T` **beats** `C` at the phenomenon `p` if it predicts strictly closer to
the truth there. -/
def Beats (T C truth : Theory Φ) (p : Φ) : Prop := predErr T truth p < predErr C truth p

/-- The class of phenomena on which `T` outpredicts `C`. -/
def superiorityRegion (T C truth : Theory Φ) : Set Φ := {p | Beats T C truth p}

lemma mem_superiorityRegion {T C truth : Theory Φ} {p : Φ} :
    p ∈ superiorityRegion T C truth ↔ predErr T truth p < predErr C truth p := Iff.rfl

/-- Superiority is irreflexive: no theory beats itself. -/
lemma not_beats_self (T truth : Theory Φ) (p : Φ) : ¬ Beats T T truth p :=
  lt_irrefl _

/-- Superiority is asymmetric. -/
lemma beats_asymm {T C truth : Theory Φ} {p : Φ} (h : Beats T C truth p) :
    ¬ Beats C T truth p := asymm h

/-- **Disagreement forces error.**  If two theories disagree at a phenomenon,
their combined error there is at least the size of the disagreement; so at least
one of them is wrong by half of it, whatever the truth may be. -/
theorem disagreement_forces_error (T C truth : Theory Φ) (p : Φ) :
    |T p - C p| ≤ predErr T truth p + predErr C truth p := by
  have h : T p - C p = (T p - truth p) + -(C p - truth p) := by ring
  calc |T p - C p| = |(T p - truth p) + -(C p - truth p)| := by rw [h]
    _ ≤ |T p - truth p| + |-(C p - truth p)| := abs_add_le _ _
    _ = predErr T truth p + predErr C truth p := by simp [predErr, abs_sub_comm]

/-! ### The meta-theorem -/

/-- **Meta-theorem: the unreasonable effectiveness of wrong theories.**

Let `T` be an approximately correct theory, i.e. a perturbative deformation of
the truth whose wrongness series converges (`Perturbative`).  Then for every
error threshold `η > 0` there is a window of couplings `|ε| < δ` such that the
(strictly wrong, since its wrongness is generally nonzero) theory `predict T ε`
beats **any** competing theory `C` on the whole class of phenomena where `C`'s
error is at least `η`.

Note the order of quantifiers: `δ` depends neither on the competitor nor on the
phenomenon; the class of phenomena on which the wrong theory wins is delimited
purely by how wrong the competitor is. -/
theorem meta_unreasonable_effectiveness (T : Perturbative Φ) {η : ℝ} (hη : 0 < η) :
    ∃ δ > 0, ∀ ε : ℝ, |ε| < δ → ∀ C : Theory Φ, ∀ p : Φ,
      η ≤ predErr C T.truth p → Beats (predict T ε) C T.truth p := by
  obtain ⟨δ, hδ, h⟩ := wrongness_small T hη
  refine ⟨δ, hδ, fun ε hε C p hp => ?_⟩
  have hw : predErr (predict T ε) T.truth p = |wrongness T ε p| := by
    simp [predErr, predict]
  rw [Beats, hw]
  exact lt_of_lt_of_le (h ε hε p) hp

/-- The class of phenomena promised by the meta-theorem is nonempty as soon as
the competitor is inexact at a single phenomenon: an approximately correct
theory outpredicts every imperfect rival somewhere. -/
theorem superiorityRegion_nonempty (T : Perturbative Φ) (C : Theory Φ) {p₀ : Φ}
    (hC : C p₀ ≠ T.truth p₀) :
    ∃ δ > 0, ∀ ε : ℝ, |ε| < δ → (superiorityRegion (predict T ε) C T.truth).Nonempty := by
  have hη : 0 < predErr C T.truth p₀ :=
    lt_of_le_of_ne (predErr_nonneg _ _ _)
      (fun h => hC ((predErr_eq_zero_iff C T.truth p₀).1 h.symm))
  obtain ⟨δ, hδ, h⟩ := meta_unreasonable_effectiveness T hη
  exact ⟨δ, hδ, fun ε hε => ⟨p₀, h ε hε C p₀ le_rfl⟩⟩

/-- Quantitative refinement: within the coupling window the wrong theory's error
is uniformly below the threshold, so its superiority region contains the entire
`η`-bad set of the competitor. -/
theorem badSet_subset_superiorityRegion (T : Perturbative Φ) {η : ℝ} (hη : 0 < η) :
    ∃ δ > 0, ∀ ε : ℝ, |ε| < δ → ∀ C : Theory Φ,
      {p : Φ | η ≤ predErr C T.truth p} ⊆ superiorityRegion (predict T ε) C T.truth := by
  obtain ⟨δ, hδ, h⟩ := meta_unreasonable_effectiveness T hη
  exact ⟨δ, hδ, fun ε hε C p hp => h ε hε C p hp⟩

/-! ### The epistemic half-space theorem -/

/-- Being closer to the unknown truth `t` than a rival is a half-line condition
in `t`. -/
lemma closer_iff_halfplane (a b t : ℝ) :
    |t - a| < |t - b| ↔ (b - a) * (2 * t - a - b) < 0 := by
  have hsq : |t - a| < |t - b| ↔ (t - a) ^ 2 < (t - b) ^ 2 := by
    rw [← sq_abs (t - a), ← sq_abs (t - b)]
    exact (pow_lt_pow_iff_left₀ (abs_nonneg _) (abs_nonneg _) two_ne_zero).symm
  rw [hsq]
  constructor <;> intro h <;> nlinarith [h]

/-- **Epistemic half-space theorem.**  For any two theories that disagree at a
phenomenon, the set of possible worlds (values of the truth at that phenomenon)
in which the first outpredicts the second is nonempty, open and unbounded.  No
amount of disagreement can make a theory unconditionally inferior: wrongness is
always relative to which world we are in. -/
theorem worlds_favouring {a b : ℝ} (hab : a ≠ b) :
    IsOpen {t : ℝ | |t - a| < |t - b|} ∧
      a ∈ {t : ℝ | |t - a| < |t - b|} ∧
      ∀ M : ℝ, ∃ t ∈ {t : ℝ | |t - a| < |t - b|}, M < |t| := by
  have hset : {t : ℝ | |t - a| < |t - b|} = {t : ℝ | (b - a) * (2 * t - a - b) < 0} := by
    ext t; exact closer_iff_halfplane a b t
  refine ⟨?_, ?_, ?_⟩
  · rw [hset]
    exact isOpen_lt (by fun_prop) continuous_const
  · show |a - a| < |a - b|
    simpa [sub_eq_zero] using hab
  · intro M
    have hM : M ≤ |M| := le_abs_self M
    rcases lt_or_gt_of_ne hab with h | h
    · -- `a < b`: all sufficiently negative worlds favour `a`
      refine ⟨min (-(|M| + 1)) ((a + b) / 2 - 1), ?_, ?_⟩
      · rw [hset]
        have h1 : min (-(|M| + 1)) ((a + b) / 2 - 1) ≤ (a + b) / 2 - 1 := min_le_right _ _
        have hba : 0 < b - a := by linarith
        simp only [Set.mem_setOf_eq]
        nlinarith
      · have h2 : min (-(|M| + 1)) ((a + b) / 2 - 1) ≤ -(|M| + 1) := min_le_left _ _
        have habs : -(min (-(|M| + 1)) ((a + b) / 2 - 1))
            ≤ |min (-(|M| + 1)) ((a + b) / 2 - 1)| := neg_le_abs _
        linarith
    · -- `b < a`: all sufficiently positive worlds favour `a`
      refine ⟨max (|M| + 1) ((a + b) / 2 + 1), ?_, ?_⟩
      · rw [hset]
        have h1 : (a + b) / 2 + 1 ≤ max (|M| + 1) ((a + b) / 2 + 1) := le_max_right _ _
        have hba : b - a < 0 := by linarith
        simp only [Set.mem_setOf_eq]
        nlinarith
      · have h2 : |M| + 1 ≤ max (|M| + 1) ((a + b) / 2 + 1) := le_max_left _ _
        have habs : max (|M| + 1) ((a + b) / 2 + 1) ≤ |max (|M| + 1) ((a + b) / 2 + 1)| :=
          le_abs_self _
        linarith

/-! ### Empirical adequacy is not transitive: a Condorcet cycle in theory space -/

section Condorcet

/-- Three phenomena with exact truth `0`. -/
def cTruth : Theory (Fin 3) := fun _ => 0

/-- First theory: errors `(1, 2, 3)`. -/
def theoryA : Theory (Fin 3) := ![1, 2, 3]
/-- Second theory: errors `(2, 3, 1)`. -/
def theoryB : Theory (Fin 3) := ![2, 3, 1]
/-- Third theory: errors `(3, 1, 2)`. -/
def theoryC : Theory (Fin 3) := ![3, 1, 2]

/-- `X` beats `Y` on a **majority** of the three phenomena. -/
def MajorityBeats (X Y : Theory (Fin 3)) : Prop :=
  ∃ p q : Fin 3, p ≠ q ∧ Beats X Y cTruth p ∧ Beats X Y cTruth q

/-- **Condorcet cycle in theory space.**  Majority empirical adequacy cycles:
`A` beats `B`, `B` beats `C`, and `C` beats `A`.  There is therefore no linear
ordering of theories by "closeness to truth" compatible with majority voting
over phenomena. -/
theorem condorcet_cycle :
    MajorityBeats theoryA theoryB ∧ MajorityBeats theoryB theoryC ∧
      MajorityBeats theoryC theoryA := by
  refine ⟨⟨0, 1, by decide, ?_, ?_⟩, ⟨0, 2, by decide, ?_, ?_⟩, ⟨1, 2, by decide, ?_, ?_⟩⟩ <;>
    simp [Beats, predErr, theoryA, theoryB, theoryC, cTruth] <;> norm_num

/-- `A` does **not** majority-beat `C`: it wins on only one phenomenon. -/
theorem not_majorityBeats_A_C : ¬ MajorityBeats theoryA theoryC := by
  rintro ⟨p, q, hpq, hp, hq⟩
  have key : ∀ r : Fin 3, Beats theoryA theoryC cTruth r → r = 0 := by
    intro r hr
    fin_cases r
    · rfl
    · exact absurd hr (by simp [Beats, predErr, theoryA, theoryC, cTruth])
    · exact absurd hr (by simp [Beats, predErr, theoryA, theoryC, cTruth]; norm_num)
  exact hpq ((key p hp).trans (key q hq).symm)

/-- Consequently majority empirical adequacy is **not transitive**: the
comparative notion of "closer to the truth" fails to be a preorder. -/
theorem majorityBeats_not_transitive :
    ¬ ∀ X Y Z : Theory (Fin 3), MajorityBeats X Y → MajorityBeats Y Z → MajorityBeats X Z := by
  intro h
  obtain ⟨hAB, hBC, _⟩ := condorcet_cycle
  exact not_majorityBeats_A_C (h theoryA theoryB theoryC hAB hBC)

end Condorcet

/-! ### Wrong theories are generic -/

/-- **Genericity of wrongness.**  Over a countable phenomenon space, every
theory can be perturbed by an arbitrarily small positive constant into a theory
that is wrong at *every* phenomenon.  Hence nowhere-exact theories are dense in
theory space, and the hypothesis "`C` is inexact somewhere" of
`superiorityRegion_nonempty` is generic rather than exceptional. -/
theorem exists_nowhere_exact_perturbation [Countable Φ] (T truth : Theory Φ)
    {δ : ℝ} (hδ : 0 < δ) :
    ∃ c : ℝ, 0 < c ∧ c < δ ∧ ∀ p : Φ, T p + c ≠ truth p := by
  classical
  set bad : Set ℝ := Set.range (fun p : Φ => truth p - T p) with hbad
  have hbadc : bad.Countable := Set.countable_range _
  have hunc : ¬ (Set.Ioo (0:ℝ) δ).Countable := by
    rw [← Cardinal.le_aleph0_iff_set_countable, Cardinal.mk_Ioo_real hδ]
    exact not_le.mpr Cardinal.aleph0_lt_continuum
  have hne : ¬ (Set.Ioo (0:ℝ) δ ⊆ bad) := fun hsub => hunc (hbadc.mono hsub)
  obtain ⟨c, hc, hcbad⟩ := Set.not_subset.1 hne
  refine ⟨c, hc.1, hc.2, fun p hp => hcbad ?_⟩
  exact ⟨p, show truth p - T p = c by linarith⟩

/-- **Every theory is optimal in some world.**  Given any family of rival
theories that are pairwise distinct at a phenomenon `p`, there is a world (an
assignment of truth values) in which the chosen member strictly outpredicts all
its rivals at `p`.  Combined with `worlds_favouring`, this says that empirical
inferiority is never intrinsic to a theory: it is a fact about which world we
happen to inhabit. -/
theorem every_theory_is_optimal_in_some_world {ι : Type*} (F : ι → Theory Φ) (p : Φ)
    (i : ι) (h : ∀ j, j ≠ i → F j p ≠ F i p) :
    ∃ truth : Theory Φ, ∀ j, j ≠ i → Beats (F i) (F j) truth p := by
  refine ⟨F i, fun j hj => ?_⟩
  have hzero : predErr (F i) (F i) p = 0 := by simp [predErr]
  have hpos : 0 < predErr (F j) (F i) p :=
    lt_of_le_of_ne (predErr_nonneg _ _ _)
      (fun hEq => h j hj ((predErr_eq_zero_iff (F j) (F i) p).1 hEq.symm))
  rw [Beats, hzero]
  exact hpos

/-- **Pessimistic meta-induction is compatible with convergence.**  There is an
infinite sequence of theories, *every one of which is wrong at every
phenomenon*, whose errors nevertheless tend uniformly to zero.  A history of
uniformly false theories is therefore no obstruction to convergence on the
truth. -/
theorem pessimistic_meta_induction (truth : Theory Φ) :
    ∃ F : ℕ → Theory Φ,
      (∀ k p, F k p ≠ truth p) ∧
      ∀ η > 0, ∃ K, ∀ k ≥ K, ∀ p, predErr (F k) truth p < η := by
  refine ⟨fun k p => truth p + 1 / (k + 1 : ℝ), fun k p => ?_, ?_⟩
  · have hk : 0 < 1 / (k + 1 : ℝ) := by positivity
    intro hEq
    have hz : 1 / (k + 1 : ℝ) = 0 := by linarith
    linarith
  · intro η hη
    obtain ⟨K, hK⟩ := exists_nat_gt (1 / η)
    refine ⟨K, fun k hk p => ?_⟩
    have hkpos : (0 : ℝ) < k + 1 := by positivity
    have hKk : (K : ℝ) ≤ k := by exact_mod_cast hk
    have hlt : 1 / η < (k : ℝ) + 1 := by linarith
    have hval : predErr (fun p => truth p + 1 / (k + 1 : ℝ)) truth p = 1 / (k + 1 : ℝ) := by
      rw [predErr]
      have : truth p + 1 / (k + 1 : ℝ) - truth p = 1 / (k + 1 : ℝ) := by ring
      rw [this, abs_of_pos (by positivity)]
    rw [hval, div_lt_iff₀ hkpos]
    have h1 : 1 / η * η = 1 := by field_simp
    nlinarith [mul_lt_mul_of_pos_right hlt hη]

/-! ### Linear structure on perturbative theory space -/

/-- The sum of two perturbative families: truths add and corrections add, with
the geometric bounds combining as expected. -/
noncomputable def Perturbative.add (T S : Perturbative Φ) : Perturbative Φ where
  truth := fun p => T.truth p + S.truth p
  coeff := fun n p => T.coeff n p + S.coeff n p
  bound := T.bound + S.bound
  ratio := max T.ratio S.ratio
  bound_nonneg := by linarith [T.bound_nonneg, S.bound_nonneg]
  ratio_nonneg := le_trans T.ratio_nonneg (le_max_left _ _)
  coeff_le := by
    intro n p
    have h1 : |T.coeff n p| ≤ T.bound * (max T.ratio S.ratio) ^ n := by
      refine le_trans (T.coeff_le n p) ?_
      have hp := pow_le_pow_left₀ T.ratio_nonneg (le_max_left T.ratio S.ratio) n
      nlinarith [T.bound_nonneg, pow_nonneg T.ratio_nonneg n]
    have h2 : |S.coeff n p| ≤ S.bound * (max T.ratio S.ratio) ^ n := by
      refine le_trans (S.coeff_le n p) ?_
      have hp := pow_le_pow_left₀ S.ratio_nonneg (le_max_right T.ratio S.ratio) n
      nlinarith [S.bound_nonneg, pow_nonneg S.ratio_nonneg n]
    calc |T.coeff n p + S.coeff n p| ≤ |T.coeff n p| + |S.coeff n p| := abs_add_le _ _
      _ ≤ T.bound * (max T.ratio S.ratio) ^ n + S.bound * (max T.ratio S.ratio) ^ n := by
          linarith
      _ = (T.bound + S.bound) * (max T.ratio S.ratio) ^ n := by ring

/-- Wrongness is additive for the linear structure on theory space. -/
theorem wrongness_add (T S : Perturbative Φ) (ε : ℝ) (p : Φ)
    (hT : T.ratio * |ε| < 1) (hS : S.ratio * |ε| < 1) :
    wrongness (Perturbative.add T S) ε p = wrongness T ε p + wrongness S ε p := by
  have hsum : ∀ n, wrongTerm (Perturbative.add T S) ε p n
      = wrongTerm T ε p n + wrongTerm S ε p n := by
    intro n
    simp [wrongTerm, Perturbative.add, add_mul]
  simp only [wrongness, hsum]
  exact Summable.tsum_add (summable_wrongTerm T ε p hT) (summable_wrongTerm S ε p hS)

/-- Predictions add as well: the perturbative structure is compatible with
superposition of theories. -/
theorem predict_add (T S : Perturbative Φ) (ε : ℝ) (p : Φ)
    (hT : T.ratio * |ε| < 1) (hS : S.ratio * |ε| < 1) :
    predict (Perturbative.add T S) ε p = predict T ε p + predict S ε p := by
  rw [predict, predict, predict, wrongness_add T S ε p hT hS]
  simp only [Perturbative.add]
  ring

/-- Rescaling a perturbative family by a real constant. -/
noncomputable def Perturbative.smul (c : ℝ) (T : Perturbative Φ) : Perturbative Φ where
  truth := fun p => c * T.truth p
  coeff := fun n p => c * T.coeff n p
  bound := |c| * T.bound
  ratio := T.ratio
  bound_nonneg := mul_nonneg (abs_nonneg c) T.bound_nonneg
  ratio_nonneg := T.ratio_nonneg
  coeff_le := by
    intro n p
    rw [abs_mul, mul_assoc]
    exact mul_le_mul_of_nonneg_left (T.coeff_le n p) (abs_nonneg c)

/-- Wrongness is homogeneous: rescaling the corrections rescales the wrongness. -/
theorem wrongness_smul (c : ℝ) (T : Perturbative Φ) (ε : ℝ) (p : Φ) :
    wrongness (Perturbative.smul c T) ε p = c * wrongness T ε p := by
  have hterm : ∀ n, wrongTerm (Perturbative.smul c T) ε p n = c * wrongTerm T ε p n := by
    intro n
    simp [wrongTerm, Perturbative.smul, mul_assoc]
  simp only [wrongness, hterm]
  exact tsum_mul_left

end WrongTheory