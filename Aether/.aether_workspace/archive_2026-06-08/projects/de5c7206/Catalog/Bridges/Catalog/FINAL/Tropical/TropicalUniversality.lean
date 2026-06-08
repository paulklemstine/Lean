/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Universality Theory for Computation DAGs

This file formalizes a mathematically rigorous universality principle based on
tropical geometry: architectures with the same "tropical profile" (finite max
of affine forms) have identical asymptotic scaling exponents.

## Main Definitions

* `AffineForm` — a linear function `slope * x + bias`
* `TropicalProfile` — a nonempty finite set of affine forms
* `TropicalProfile.evalMax` — the pointwise maximum envelope
* `TropicalEquivalent` — pointwise equality of envelopes
* `TropicalProfile.maxSlope` — the maximum slope in a profile
* `ParallelCompose` — union of two profiles (residual architecture)
* `DominantMultiplicity` — cardinality of max-slope forms

## Main Results

* `tropical_equiv_implies_same_maxSlope` — Tropical equivalence preserves
  the asymptotic slope (Theorem 1).
* `evalMax_parallel_compose` — The envelope of a parallel composition is
  the pointwise max of the component envelopes (Theorem 3a).
* `asymptotic_slope_parallel_compose` — The asymptotic slope of a parallel
  composition is the max of the component slopes (Theorem 3b).
* `tropical_equiv_preserves_essential_bias` — Tropical equivalence preserves
  the essential dominant bias (the max bias among max-slope forms).
* `tropical_equiv_eventual_linear` — Tropical equivalence preserves both
  the asymptotic slope and the essential bias (full eventual invariance).
* `eventual_slope_dominance` — Forms with the steepest slope eventually
  dominate all others.

## Architecture and Strategy

The key insight is that a finite max of affine forms is a piecewise-linear
convex function whose large-x behavior is controlled by the steepest-slope
forms. Two profiles with equal envelopes must therefore share slope structure.
This factors architecture-level asymptotics through a tropical invariant.
-/
import Mathlib

open Classical

noncomputable section

/-! ## Core Definitions -/

/-- An affine form `f(x) = slope * x + bias`. -/
structure AffineForm where
  slope : ℝ
  bias  : ℝ

namespace AffineForm

/-- Evaluate the affine form at a point. -/
def eval (f : AffineForm) (x : ℝ) : ℝ := f.slope * x + f.bias

@[simp]
theorem eval_def (f : AffineForm) (x : ℝ) : f.eval x = f.slope * x + f.bias := rfl

/-- The difference of two affine evaluations. -/
theorem eval_sub (f g : AffineForm) (x : ℝ) :
    f.eval x - g.eval x = (f.slope - g.slope) * x + (f.bias - g.bias) := by
  simp [eval]; ring

/-
An affine form with steeper slope eventually dominates.
-/
theorem eventually_dominates_of_slope_lt {f g : AffineForm} (h : g.slope < f.slope) :
    ∃ X0 : ℝ, ∀ x ≥ X0, g.eval x < f.eval x := by
  exact ⟨ ( g.bias - f.bias ) / ( f.slope - g.slope ) + 1, fun x hx ↦ by rw [ AffineForm.eval_def, AffineForm.eval_def ] ; nlinarith [ mul_div_cancel₀ ( g.bias - f.bias ) ( sub_ne_zero_of_ne h.ne' ) ] ⟩

/-
An affine form with steeper slope eventually dominates (≤ version).
-/
theorem eventually_ge_of_slope_lt {f g : AffineForm} (h : g.slope < f.slope) :
    ∃ X0 : ℝ, ∀ x ≥ X0, g.eval x ≤ f.eval x := by
  exact ⟨ ( g.bias - f.bias ) / ( f.slope - g.slope ), fun x hx => by rw [ AffineForm.eval, AffineForm.eval ] ; nlinarith [ mul_div_cancel₀ ( g.bias - f.bias ) ( sub_ne_zero.mpr h.ne' ) ] ⟩

end AffineForm

/-! ## Tropical Profiles -/

/-- A tropical profile: a nonempty finite set of affine forms.
    Represents the "tropical semantics" of a computation DAG. -/
structure TropicalProfile where
  forms : Finset AffineForm
  nonempty : forms.Nonempty

namespace TropicalProfile

/-- The tropical envelope: pointwise maximum of all affine forms. -/
def evalMax (P : TropicalProfile) (x : ℝ) : ℝ :=
  P.forms.sup' P.nonempty (fun f => f.eval x)

/-- The maximum slope among all forms in the profile.
    This is the asymptotic growth rate of the envelope. -/
def maxSlope (P : TropicalProfile) : ℝ :=
  P.forms.sup' P.nonempty (fun f => f.slope)

/-- The set of forms achieving the maximum slope. -/
def dominantForms (P : TropicalProfile) : Finset AffineForm :=
  P.forms.filter (fun f => f.slope = P.maxSlope)

/-
The dominant set is nonempty.
-/
theorem dominantForms_nonempty (P : TropicalProfile) :
    (P.dominantForms).Nonempty := by
  -- By definition of `maxSlope`, there exists a form `f` in `P` such that `f.slope = P.maxSlope`.
  obtain ⟨f, hf⟩ : ∃ f ∈ P.forms, f.slope = P.maxSlope := by
    have := Finset.exists_max_image P.forms ( fun f => f.slope ) P.nonempty;
    exact ⟨ this.choose, this.choose_spec.1, le_antisymm ( Finset.le_sup' ( fun f => f.slope ) this.choose_spec.1 ) ( Finset.sup'_le _ _ fun x hx => this.choose_spec.2 x hx ) ⟩;
  exact ⟨ f, Finset.mem_filter.mpr ⟨ hf.1, hf.2 ⟩ ⟩

/-
Every form's slope is at most the max slope.
-/
theorem slope_le_maxSlope (P : TropicalProfile) {f : AffineForm}
    (hf : f ∈ P.forms) : f.slope ≤ P.maxSlope := by
  exact Finset.le_sup' ( fun f => f.slope ) hf

/-
evalMax is at least any individual form's value.
-/
theorem le_evalMax (P : TropicalProfile) (f : AffineForm)
    (hf : f ∈ P.forms) (x : ℝ) : f.eval x ≤ P.evalMax x := by
  exact Finset.le_sup' ( fun f => f.eval x ) hf

/-
evalMax is achieved by some form.
-/
theorem evalMax_achieved (P : TropicalProfile) (x : ℝ) :
    ∃ f ∈ P.forms, P.evalMax x = f.eval x := by
  exact Finset.exists_mem_eq_sup' P.nonempty fun f => f.eval x

/-
For large enough x, the maximum is achieved by a dominant (max-slope) form.
-/
theorem eventual_slope_dominance (P : TropicalProfile) :
    ∃ X0 : ℝ, ∀ x ≥ X0, ∃ f ∈ P.forms, f.slope = P.maxSlope ∧
      P.evalMax x = f.eval x := by
  -- By definition of $P.maxSlope$, for any $g \in P.forms$ with $g.slope < P.maxSlope$, there exists $X_g$ such that for all $x \geq X_g$, $g.eval x < f.eval x$ for any $f \in P.forms$ with $f.slope = P.maxSlope$.
  have h_eventually_zero : ∀ g ∈ P.forms, g.slope < P.maxSlope → ∃ X_g, ∀ x ≥ X_g, g.eval x < P.evalMax x := by
    intro g hg hgt
    obtain ⟨f, hf_dom, hf_slope⟩ : ∃ f ∈ P.forms, f.slope = P.maxSlope := by
      have := Finset.exists_max_image _ ( fun f => f.slope ) P.nonempty;
      exact ⟨ this.choose, this.choose_spec.1, le_antisymm ( Finset.le_sup' ( fun f => f.slope ) this.choose_spec.1 ) ( Finset.sup'_le _ _ fun f hf => this.choose_spec.2 f hf ) ⟩;
    obtain ⟨ X_g, hX_g ⟩ := AffineForm.eventually_dominates_of_slope_lt ( show g.slope < f.slope from by linarith ) ; exact ⟨ X_g, fun x hx ↦ lt_of_lt_of_le ( hX_g x hx ) ( TropicalProfile.le_evalMax _ _ hf_dom _ ) ⟩ ;
  -- By taking the maximum of all $X_g$ for $g \in P.forms$ with $g.slope < P.maxSlope$, we obtain an $X0$ such that for all $x \geq X0$, $g.eval x < P.evalMax x$ for all $g \in P.forms$ with $g.slope < P.maxSlope$.
  obtain ⟨X0, hX0⟩ : ∃ X0, ∀ g ∈ P.forms, g.slope < P.maxSlope → ∀ x ≥ X0, g.eval x < P.evalMax x := by
    choose! X hX using h_eventually_zero;
    exact ⟨ Finset.max' ( P.forms.image X ) ⟨ _, Finset.mem_image_of_mem X ( Classical.choose_spec ( P.dominantForms_nonempty ) |> fun h => Finset.mem_filter.mp h |>.1 ) ⟩, fun g hg hg' x hx => hX g hg hg' x <| le_trans ( Finset.le_max' _ _ <| Finset.mem_image_of_mem X hg ) hx ⟩;
  use X0;
  intro x hx;
  obtain ⟨ f, hf₁, hf₂ ⟩ := TropicalProfile.evalMax_achieved P x;
  exact ⟨ f, hf₁, le_antisymm ( slope_le_maxSlope P hf₁ ) ( le_of_not_gt fun h => by linarith [ hX0 f hf₁ h x hx ] ), hf₂ ⟩

/-
The evalMax for large x equals the max among dominant forms.
-/
theorem evalMax_eventually_eq_dominant (P : TropicalProfile) :
    ∃ X0 : ℝ, ∀ x ≥ X0,
      P.evalMax x = P.dominantForms.sup' P.dominantForms_nonempty
        (fun f => f.eval x) := by
  -- By definition of `eventual_slope_dominance`, we know that for sufficiently large x, `P.evalMax x` is achieved by a dominant form.
  obtain ⟨X0, hX⟩ : ∃ X0 : ℝ, ∀ x ≥ X0, ∃ f ∈ P.forms, f.slope = P.maxSlope ∧ P.evalMax x = f.eval x := by
    exact eventual_slope_dominance P;
  refine' ⟨ X0, fun x hx => le_antisymm _ _ ⟩ <;> simp_all +decide [ TropicalProfile.dominantForms ];
  · exact Exists.elim ( hX x hx ) fun f hf => ⟨ f, ⟨ hf.1, hf.2.1 ⟩, hf.2.2 ▸ le_rfl ⟩;
  · intro f hf hf'; rw [ TropicalProfile.evalMax ] ; exact Finset.le_sup' ( fun f => f.eval x ) hf |> le_trans ( by simp +decide [ hf', AffineForm.eval ] ) ;

end TropicalProfile

/-! ## Tropical Equivalence -/

/-- Two tropical profiles are equivalent if their envelopes agree everywhere. -/
def TropicalEquivalent (P Q : TropicalProfile) : Prop :=
  ∀ x : ℝ, P.evalMax x = Q.evalMax x

theorem TropicalEquivalent.symm {P Q : TropicalProfile}
    (h : TropicalEquivalent P Q) : TropicalEquivalent Q P :=
  fun x => (h x).symm

theorem TropicalEquivalent.refl (P : TropicalProfile) :
    TropicalEquivalent P P :=
  fun _ => rfl

/-! ## Theorem 1: Tropical Equivalence Preserves Asymptotic Slope -/

/-
**Main Theorem 1**: Tropically equivalent profiles have the same maximum slope.
    This is the core universality result: the asymptotic exponent is a tropical invariant.

    **Proof strategy**: For large x, `evalMax P x = α_P * x + β_P` and
    `evalMax Q x = α_Q * x + β_Q`. Taking the difference quotient
    `(evalMax(x₂) - evalMax(x₁))/(x₂ - x₁)` for large x₁, x₂ extracts the slope.
    Since `evalMax P = evalMax Q`, the slopes must match.
-/
theorem tropical_equiv_implies_same_maxSlope
    (P Q : TropicalProfile)
    (hPQ : TropicalEquivalent P Q) :
    P.maxSlope = Q.maxSlope := by
  -- By definition of TropicalEquivalent, we have ∀ x, P.evalMax x = Q.evalMax x.
  unfold TropicalEquivalent at hPQ;
  -- By definition of TropicalEquivalent, we have ∀ x, P.evalMax x = Q.evalMax x. This implies that for large enough x, the slopes of the dominant forms must be equal.
  have h_slope_eq : ∀ x : ℝ, P.evalMax x = Q.evalMax x → P.maxSlope = Q.maxSlope := by
    intro x hx;
    obtain ⟨X0P, hX0P⟩ := TropicalProfile.evalMax_eventually_eq_dominant P
    obtain ⟨X0Q, hX0Q⟩ := TropicalProfile.evalMax_eventually_eq_dominant Q;
    -- By definition of $P.dominantForms$ and $Q.dominantForms$, we know that for $x \geq \max(X0P, X0Q)$, $P.evalMax x = P.maxSlope * x + \sup' (fun f => f.bias)$ and $Q.evalMax x = Q.maxSlope * x + \sup' (fun f => f.bias)$.
    have h_evalMax_eq : ∀ x ≥ max X0P X0Q, P.evalMax x = P.maxSlope * x + (P.dominantForms.sup' P.dominantForms_nonempty (fun f => f.bias)) ∧ Q.evalMax x = Q.maxSlope * x + (Q.dominantForms.sup' Q.dominantForms_nonempty (fun f => f.bias)) := by
      simp_all +decide [ AffineForm.eval ];
      intro x hxP hxQ
      have hP_max_slope : ∀ f ∈ P.dominantForms, f.slope = P.maxSlope := by
        exact fun f hf => Finset.mem_filter.mp hf |>.2
      have hQ_max_slope : ∀ f ∈ Q.dominantForms, f.slope = Q.maxSlope := by
        exact fun f hf => Finset.mem_filter.mp hf |>.2;
      grind +suggestions;
    linarith [ hPQ ( Max.max X0P X0Q ), hPQ ( Max.max X0P X0Q + 1 ), h_evalMax_eq ( Max.max X0P X0Q ) le_rfl, h_evalMax_eq ( Max.max X0P X0Q + 1 ) ( by linarith [ le_max_left X0P X0Q, le_max_right X0P X0Q ] ) ];
  exact h_slope_eq 0 ( hPQ 0 )

/-! ## Parallel Composition (Residual Architecture) -/

/-- Parallel composition of two profiles: the union of their forms.
    Models a residual/skip architecture where branches compete. -/
def ParallelCompose (P Q : TropicalProfile) : TropicalProfile where
  forms := P.forms ∪ Q.forms
  nonempty := P.nonempty.mono Finset.subset_union_left

/-
**Theorem 3a**: The envelope of a parallel composition is the pointwise
    maximum of the component envelopes.
-/
theorem evalMax_parallel_compose (P Q : TropicalProfile) (x : ℝ) :
    (ParallelCompose P Q).evalMax x =
      max (P.evalMax x) (Q.evalMax x) := by
  convert Finset.sup'_union _ _ _ using 1

/-
**Theorem 3b**: The asymptotic slope of a parallel composition is the
    maximum of the component slopes.

    This formalizes the "fastest-growing branch wins" principle for
    residual architectures.
-/
theorem asymptotic_slope_parallel_compose (P Q : TropicalProfile) :
    (ParallelCompose P Q).maxSlope = max P.maxSlope Q.maxSlope := by
  convert Finset.sup'_union P.nonempty Q.nonempty _

/-! ## Dominant Multiplicity -/

/-- The dominant multiplicity: number of forms achieving the max slope. -/
def DominantMultiplicity (P : TropicalProfile) : ℕ :=
  P.dominantForms.card

/- Note: the naive statement `DominantMultiplicity P = DominantMultiplicity Q`
   under `TropicalEquivalent P Q` is FALSE. Counterexample: P = {(0,0), (0,1)}
   and Q = {(0,1)} are tropically equivalent but have multiplicities 2 vs 1.
   The issue is that dominated forms within the max-slope class don't affect
   the envelope. The correct invariant is the "essential" dominant bias,
   i.e., the maximum bias among max-slope forms. -/

/-- The essential dominant bias: the maximum bias among forms with max slope.
    This determines the eventual constant in the envelope. -/
def EssentialDominantBias (P : TropicalProfile) : ℝ :=
  P.dominantForms.sup' P.dominantForms_nonempty (fun f => f.bias)

/-
**Essential Bias Invariance**: Tropically equivalent profiles have
    the same essential dominant bias. Together with slope invariance,
    this completely determines the eventual linear behavior of the envelope.
-/
theorem tropical_equiv_preserves_essential_bias
    (P Q : TropicalProfile)
    (hPQ : TropicalEquivalent P Q) :
    EssentialDominantBias P = EssentialDominantBias Q := by
  -- By evalMax_eventually_eq_dominant, for large x, P.evalMax x = sup' over dominant forms of (f.eval x). All dominant forms have slope α = P.maxSlope. So P.evalMax x = α * x + sup' over dominant forms of (f.bias) = α * x + EssentialDominantBias P.
  have hP : ∃ X0P : ℝ, ∀ x ≥ X0P, P.evalMax x = P.maxSlope * x + EssentialDominantBias P := by
    -- By definition of `dominantForms`, we know that for any $x \geq X0$, $P.evalMax x$ is achieved by some form in `dominantForms`.
    obtain ⟨X0, hX0⟩ : ∃ X0 : ℝ, ∀ x ≥ X0, ∃ f ∈ P.dominantForms, P.evalMax x = f.eval x := by
      have := TropicalProfile.eventual_slope_dominance P;
      exact ⟨ this.choose, fun x hx => by obtain ⟨ f, hf₁, hf₂, hf₃ ⟩ := this.choose_spec x hx; exact ⟨ f, Finset.mem_filter.mpr ⟨ hf₁, hf₂ ⟩, hf₃ ⟩ ⟩;
    -- Since $f \in P.dominantForms$, we have $f.eval x = P.maxSlope * x + f.bias$.
    have h_eval : ∀ x ≥ X0, ∀ f ∈ P.dominantForms, f.eval x = P.maxSlope * x + f.bias := by
      intros x hx f hf
      have h_slope : f.slope = P.maxSlope := by
        exact Finset.mem_filter.mp hf |>.2
      rw [AffineForm.eval_def]
      rw [h_slope];
    use X0;
    intros x hx
    obtain ⟨f, hf_dom, hf_eq⟩ := hX0 x hx
    have hf_bias : f.bias ≤ EssentialDominantBias P := by
      exact Finset.le_sup' ( fun f => f.bias ) hf_dom
    have hf_max : P.evalMax x ≤ P.maxSlope * x + EssentialDominantBias P := by
      linarith [ h_eval x hx f hf_dom ]
    have hf_min : P.evalMax x ≥ P.maxSlope * x + EssentialDominantBias P := by
      have hf_min : ∃ g ∈ P.dominantForms, g.bias = EssentialDominantBias P := by
        exact Finset.exists_max_image _ _ ⟨ f, hf_dom ⟩ |> fun ⟨ g, hg₁, hg₂ ⟩ => ⟨ g, hg₁, le_antisymm ( Finset.le_sup' ( fun f => f.bias ) hg₁ ) ( Finset.sup'_le _ _ fun f hf => hg₂ f hf ) ⟩
      obtain ⟨g, hg_dom, hg_bias⟩ := hf_min
      have hg_eval : g.eval x = P.maxSlope * x + g.bias := by
        exact h_eval x hx g hg_dom
      have hg_max : P.evalMax x ≥ g.eval x := by
        exact TropicalProfile.le_evalMax P g ( Finset.mem_filter.mp hg_dom |>.1 ) x
      linarith [hg_eval, hg_max]
    linarith;
  -- Similarly, Q.evalMax x = α * x + EssentialDominantBias Q.
  have hQ : ∃ X0Q : ℝ, ∀ x ≥ X0Q, Q.evalMax x = Q.maxSlope * x + EssentialDominantBias Q := by
    have hQ : ∃ X0Q : ℝ, ∀ x ≥ X0Q, Q.evalMax x = Q.dominantForms.sup' Q.dominantForms_nonempty (fun f => f.eval x) := by
      exact TropicalProfile.evalMax_eventually_eq_dominant Q;
    have hQ_slope : ∀ f ∈ Q.dominantForms, f.slope = Q.maxSlope := by
      exact fun f hf => Finset.mem_filter.mp hf |>.2;
    have hQ_eval : ∀ x : ℝ, Q.dominantForms.sup' Q.dominantForms_nonempty (fun f => f.eval x) = Q.maxSlope * x + Q.dominantForms.sup' Q.dominantForms_nonempty (fun f => f.bias) := by
      intro x
      have hQ_eval : ∀ f ∈ Q.dominantForms, f.eval x = Q.maxSlope * x + f.bias := by
        exact fun f hf => by rw [ ← hQ_slope f hf, AffineForm.eval ] ;
      refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
      · exact fun f hf => ⟨ f, hf, le_rfl ⟩;
      · exact Finset.exists_max_image _ _ ( TropicalProfile.dominantForms_nonempty Q );
    exact ⟨ hQ.choose, fun x hx => hQ.choose_spec x hx ▸ hQ_eval x ⟩;
  nontriviality;
  obtain ⟨ X0P, hX0P ⟩ := hP; obtain ⟨ X0Q, hX0Q ⟩ := hQ; have := hPQ ( Max.max X0P X0Q ) ; simp_all +decide;
  rw [ tropical_equiv_implies_same_maxSlope P Q hPQ ] at this ; linarith

/-- **Eventual Envelope Theorem**: Tropically equivalent profiles have
    identical eventual linear functions. That is, for large x, both
    envelopes equal `α * x + β` for the same α and β. -/
theorem tropical_equiv_eventual_linear
    (P Q : TropicalProfile)
    (hPQ : TropicalEquivalent P Q) :
    P.maxSlope = Q.maxSlope ∧ EssentialDominantBias P = EssentialDominantBias Q := by
  exact ⟨tropical_equiv_implies_same_maxSlope P Q hPQ,
         tropical_equiv_preserves_essential_bias P Q hPQ⟩

/-! ## Concrete Example: Two Non-Isomorphic DAGs with Equal Tropical Profile -/

/-- Profile A: three affine forms modeling a three-branch architecture.
    Forms: {2x + 1, x + 5, 3x - 2} -/
def exampleProfileA : TropicalProfile where
  forms := {⟨2, 1⟩, ⟨1, 5⟩, ⟨3, -2⟩}
  nonempty := ⟨⟨2, 1⟩, by simp⟩

/-- Profile B: different internal structure but same envelope.
    Forms: {3x - 2, 2x + 1, x + 5, 2.5*x - 1}
    The extra form 2.5x - 1 is always dominated, so the envelope is unchanged. -/
def exampleProfileB : TropicalProfile where
  forms := {⟨3, -2⟩, ⟨2, 1⟩, ⟨1, 5⟩, ⟨2.5, -1⟩}
  nonempty := ⟨⟨3, -2⟩, by simp⟩

/-
The two example profiles have the same maximum slope (= 3).
-/
theorem example_same_maxSlope :
    exampleProfileA.maxSlope = exampleProfileB.maxSlope := by
  unfold TropicalProfile.maxSlope;
  unfold exampleProfileA exampleProfileB;
  norm_num [ Finset.fold, Finset.fold_singleton ]

/-
The example profiles are tropically equivalent because the extra form
    in profile B (2.5x - 1) is always dominated by max(2x+1, 3x-2).
-/
theorem example_tropical_equivalent :
    TropicalEquivalent exampleProfileA exampleProfileB := by
  unfold exampleProfileA exampleProfileB TropicalEquivalent;
  unfold TropicalProfile.evalMax;
  simp +decide [ Finset.sup'_insert ];
  grind

/-! ## Finitely Many Branches (Generalized Residual) -/

/-- Compose finitely many profiles via union. -/
def ParallelComposeFinset {ι : Type*} [DecidableEq ι]
    (A : ι → TropicalProfile) (S : Finset ι) (hS : S.Nonempty) :
    TropicalProfile where
  forms := S.biUnion (fun i => (A i).forms)
  nonempty := by
    obtain ⟨i, hi⟩ := hS
    exact ((A i).nonempty).mono
      (Finset.subset_biUnion_of_mem (fun i => (A i).forms) hi)

/-
The max slope of a finite parallel composition is the max of component slopes.
-/
theorem maxSlope_parallel_finset {ι : Type*} [DecidableEq ι]
    (A : ι → TropicalProfile) (S : Finset ι) (hS : S.Nonempty) :
    (ParallelComposeFinset A S hS).maxSlope =
      S.sup' hS (fun i => (A i).maxSlope) := by
  refine' le_antisymm _ _;
  · refine' Finset.sup'_le _ _ _;
    intro b hb;
    obtain ⟨ i, hi, hi' ⟩ := Finset.mem_biUnion.mp hb;
    exact le_trans ( TropicalProfile.slope_le_maxSlope _ hi' ) ( Finset.le_sup' ( fun i => ( A i ).maxSlope ) hi );
  · simp +decide [ TropicalProfile.maxSlope ];
    -- By definition of `ParallelComposeFinset`, there exists some `i ∈ S` such that `maxSlope (A i)` is maximal.
    obtain ⟨i, hi⟩ : ∃ i ∈ S, ∀ j ∈ S, (A j).maxSlope ≤ (A i).maxSlope := by
      exact Finset.exists_max_image _ _ hS;
    obtain ⟨ f, hf ⟩ := ( A i ).dominantForms_nonempty;
    refine' ⟨ f, _, _ ⟩ <;> simp_all +decide [ TropicalProfile.dominantForms ];
    · exact Finset.mem_biUnion.mpr ⟨ i, hi.1, hf.1 ⟩;
    · exact fun j hj g hg => le_trans ( TropicalProfile.slope_le_maxSlope _ hg ) ( hi.2 j hj )

end