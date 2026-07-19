import Mathlib

/-!
# A rigorous algebraic shadow of the cobordism hypothesis

The literal claim that *every* physical theory must be an `(∞,2)`-category is not a
mathematical proposition until “physical theory” and “must” are specified.  This file
therefore isolates a precise, falsifiable core: a freely generated dualizable sector has
an integer-valued charge group, and every additive shadow out of it is uniquely fixed by
its values on generators.  This is the decategorified universal-property pattern of the
cobordism hypothesis.

The last results separate two often conflated questions about computability.  Evaluation
is an explicit finite sum once generator data are available, but unrestricted generator
data can encode an arbitrary predicate.  Thus universality alone implies neither
computability nor noncomputability.
-/

namespace CategoricalPhysics

/-- The decategorified object group of a freely generated dualizable theory.
`Finsupp` enforces that each expression uses only finitely many generators, while
integer coefficients model tensor powers and formal duals. -/
abbrev DualCharge (G : Type*) := G →₀ ℤ

/-- The positively generated, non-dual fragment. -/
abbrev PositiveCharge (G : Type*) := G →₀ ℕ

/-- A decategorified additive shadow of a dualizable theory. -/
abbrev AdditiveShadow (G A : Type*) [AddCommGroup A] := DualCharge G →+ A

/-- The value assigned to an individual fully dualizable generator. -/
noncomputable def generatorValue {G A : Type*} [AddCommGroup A]
    (Z : AdditiveShadow G A) (g : G) : A := Z (Finsupp.single g 1)

/-- Explicit extension of generator data to all finite formal tensor/dual expressions. -/
noncomputable def extendShadow {G A : Type*} [AddCommGroup A]
    (v : G → A) : AdditiveShadow G A :=
  Finsupp.liftAddHom (fun g =>
    { toFun := fun n : ℤ => n • v g
      map_zero' := zero_zsmul (v g)
      map_add' := fun m n => add_zsmul (v g) m n })

/-
**Universal property (existence).** Any assignment on generators extends to a
shadow, including negative coefficients corresponding to duals.
-/
theorem extendShadow_generator {G A : Type*} [AddCommGroup A] (v : G → A) (g : G) :
    generatorValue (extendShadow v) g = v g := by
  unfold generatorValue; unfold extendShadow; simp +decide ;

/-
**Universal property (uniqueness).** A shadow is completely determined by its
values on the fully dualizable generators.
-/
theorem shadow_ext {G A : Type*} [AddCommGroup A] (Z W : AdditiveShadow G A)
    (h : ∀ g, generatorValue Z g = generatorValue W g) : Z = W := by
  ext x;
  exact h x

/-
The promised universal property, phrased as unique existence.
-/
theorem decategorified_cobordism_universal_property
    {G A : Type*} [AddCommGroup A] (v : G → A) :
    ∃! Z : AdditiveShadow G A, ∀ g, generatorValue Z g = v g := by
  exact ⟨ extendShadow v, fun g => extendShadow_generator v g, fun Z hZ => shadow_ext Z ( extendShadow v ) fun g => hZ g ▸ extendShadow_generator v g ▸ rfl ⟩

/-
Three named sectors (for example, decategorified TQFT, CFT, and string
sectors) can be bundled into one universal shadow. Each component is retained in the
product rather than being identified without justification.
-/
theorem three_sectors_single_shadow
    {G A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (tqft : G → A) (cft : G → B) (string : G → C) :
    ∃! Z : AdditiveShadow G (A × B × C),
      ∀ g, generatorValue Z g = (tqft g, cft g, string g) := by
  convert decategorified_cobordism_universal_property _

/-
Duality is visible in every additive shadow as negation.
-/
theorem shadow_of_dual {G A : Type*} [AddCommGroup A]
    (Z : AdditiveShadow G A) (x : DualCharge G) : Z (-x) = -Z x := by
  exact map_neg Z x

/-
Tensor composition is visible in every additive shadow as addition.
-/
theorem shadow_of_tensor {G A : Type*} [AddCommGroup A]
    (Z : AdditiveShadow G A) (x y : DualCharge G) : Z (x + y) = Z x + Z y := by
  exact Z.map_add x y

/-- A deliberately smaller “theory” with no duals, used to refute the unqualified
necessity claim.  Its tensor product is addition of natural multiplicities. -/
structure PlainTensorTheory where
  Generator : Type
  charge : PositiveCharge Generator

/-- A concrete nonempty tensor theory whose charge monoid is `ℕ`; it is meaningful as
an algebraic theory but does not come equipped with inverses/duals. -/
noncomputable def oneGeneratorNoDual : PlainTensorTheory where
  Generator := Unit
  charge := Finsupp.single () 1

/-
The generator in the positive theory has no additive inverse.  This is a formal
counterexample to the bare algebraic assertion that every tensor theory already has
all duals; additional physical/categorical hypotheses are indispensable.
-/
theorem positive_generator_has_no_dual :
    ¬ ∃ y : PositiveCharge Unit,
      Finsupp.single () 1 + y = 0 := by
  simp +zetaDelta at *

/-
Evaluation of the universal extension is a finite sum.  This equation is the
computational content: no search over an infinite category is involved.
-/
theorem finite_evaluation_formula {G A : Type*} [AddCommGroup A]
    (v : G → A) (x : DualCharge G) :
    extendShadow v x = x.sum fun g n => n • v g := by
  convert Finsupp.liftAddHom_apply ( fun g ↦ AddMonoidHom.mk' ( fun n ↦ n • v g ) ?_ ) x using 1;
  simp +decide [ add_smul ]

/-- An unrestricted bit assignment gives an additive shadow on positive charges. -/
noncomputable def bitOracleShadow (p : ℕ → Bool) : PositiveCharge ℕ →+ ZMod 2 :=
  Finsupp.liftAddHom (fun n =>
    { toFun := fun k : ℕ => k • (if p n then 1 else 0)
      map_zero' := zero_nsmul _
      map_add' := fun a b => add_nsmul _ a b })

/-
Every bit of the supplied assignment can be recovered by probing a singleton.
Consequently the universal construction can carry arbitrary oracle information when
its generator assignment is itself unrestricted.
-/
theorem bitOracleShadow_recovers (p : ℕ → Bool) (n : ℕ) :
    bitOracleShadow p (Finsupp.single n 1) = if p n then 1 else 0 := by
  convert Finsupp.liftAddHom_apply_single _ _ _;
  aesop

/-
Two oracle assignments induce the same shadow exactly when they are the same.
This strengthens recoverability to an embedding result.
-/
theorem bitOracleShadow_injective : Function.Injective bitOracleShadow := by
  intro p q h;
  ext n;
  replace h := congr_arg ( fun f => f ( Finsupp.single n 1 ) ) h ; simp_all +decide [ bitOracleShadow_recovers ];
  grind

end CategoricalPhysics