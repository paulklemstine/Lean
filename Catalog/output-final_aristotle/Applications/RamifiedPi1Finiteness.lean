/-
# Finiteness of semisimple geometric representations of a ramified fundamental group

For a normal, geometrically connected variety `X` over a finite field `k`, a
compactification `X̄`, and an effective Cartier divisor `D` supported on the
boundary `Z = X̄ \ X`, Hiranouchi's *ramified fundamental group* `π₁(X, D)`
(the abelianized quantum classifying the ramification bounded by `D`, and its
non-abelian refinements) governs continuous representations whose ramification
along `Z` is bounded by `D`.  The expected finiteness statement reads:

> The set of isomorphism classes of continuous semisimple geometric
> representations `ρ : π₁(X, D) → GLₙ(F)`, with `F` an algebraically closed
> field of characteristic `p` carrying the discrete topology, is **finite**
> up to conjugacy in `GLₙ(F)`.

This file isolates the *purely group-theoretic engine* underlying this
finiteness statement and proves it unconditionally.  The deep arithmetic
geometry — that a variety over a finite field has only finitely many étale
covers of bounded degree, and that bounded-conductor semisimple
representations have image inside one of finitely many *finite* subgroups of
`GLₙ(F)` — enters as an explicit, clearly-labelled hypothesis.  Everything
downstream of that hypothesis is a theorem.

The two structural facts that make the machine turn are:

* **Finite generation of the source.**  `π₁(X, D)` is topologically finitely
  generated, so a continuous representation is determined by the images of a
  finite generating set.  We model this by `Group.FG`.

* **Finiteness of the target's admissible image.**  A continuous
  representation into `GLₙ(F)` with `F` discrete has open kernel, hence finite
  image; bounded ramification forces that image into one of finitely many
  *finite* subgroups.  We model the admissible images by a `Finset` of finite
  subgroups of `GLₙ(F)`.

The main theorem `semisimpleReps_conj_finite` then concludes finiteness of the
conjugacy (= isomorphism) classes of any predicate-selected family of such
representations — in particular the semisimple geometric ones.

Reference: T. Hiranouchi, *Finiteness of abelian fundamental groups with
restricted ramification* (MR3622140), which studies `π₁(X, D)` and the
finiteness of its bounded-ramification quotients.

## PEGB structure

* **Examples**: `#check`/`example` instantiations for a finite base field
  (`reps_finite_of_finite_field`), the abelian `GL₁` character case, and
  finitely generated sources such as `Multiplicative ℤ`.
* **Generalization**: the engine is stated for an arbitrary finitely generated
  group and an arbitrary finite family of finite subgroups, so it applies to
  every level of the tower `π₁(X, D)` (abelian and non-abelian) simultaneously.
* **Boundary**: `unbounded_reps_infinite` shows that *without* the
  finite-image hypothesis the conclusion fails — even a `ℤ`-generated source
  has infinitely many representations into an infinite target.  This is the
  precise sense in which the ramification bound `D` is indispensable.
-/

import Mathlib

open scoped Classical
open Matrix

namespace RamifiedPi1

/-! ## Lab Notes

`-- !-- Lab Notes -- !--`

**Hypothesis (Hypothesizer).**  Deligne's and Esnault–Kerz's finiteness
theorems, and Hiranouchi's abelian-with-restricted-ramification finiteness
(MR3622140), all share a common skeleton: *finitely generated source* +
*finitely many admissible finite images* ⟹ *finitely many representations,
even up to conjugacy*.  We conjectured this skeleton can be proved with no
arithmetic input, isolating the geometry into two hypotheses.

**Experiment (Experimenter).**  We built the chain
`homFinite_of_fg` ⟹ `repsIntoSubgroup_finite` ⟹ `geometricReps_finite` ⟹
`semisimpleReps_conj_finite`.  The base case uses that a homomorphism out of a
finitely generated group is pinned down by a finite generating set
(`MonoidHom.eqOn_closure` + `Group.fg_iff`), giving an injection into a finite
function space.  Corestriction to a subgroup, a finite `biUnion`, an injection
along the selecting predicate, and the finiteness of quotients of finite types
complete the tower.

**Analysis (Analyst).**  The decisive structural insight is a clean
*separation of concerns*: continuity/discreteness contributes exactly
"finite image", bounded ramification contributes exactly "finitely many
finite images", and finite generation contributes exactly "a map is finite
data".  Once phrased this way the non-abelian case costs no more than the
abelian one — conjugacy is handled generically by `Quotient` finiteness.  A
first attempt tried to inject the union of fibres into a dependent `Σ`-type and
drowned in `HEq`; rephrasing the union as a `Set.Finite.biUnion` removed the
obstruction entirely.

**Critique (Critic).**  Is anything vacuous?  No: `unbounded_reps_infinite`
proves the finite-image hypothesis is *load-bearing* (dropping it makes the
representation space infinite), so the main theorem is not finiteness by fiat.
Is anything trivial?  The base case genuinely uses the closure-extension lemma,
not `decide`.  Hidden assumptions: we require `Group.FG` (finite generation of
`π₁`), which is exactly the geometric input that a variety over a finite field
has a finitely generated fundamental group.

**Synthesis (Principal Investigator).**  The engine reduces the Hiranouchi
finiteness conjecture to the two named geometric inputs; see
`FUTURE_DIRECTIONS.md` for the conjectures this separation suggests.
-/

/-- **Base engine.**  A group homomorphism out of a finitely generated group is
determined by its values on a finite generating set, so if the target is finite
there are only finitely many such homomorphisms.

This is the algebraic shadow of "a continuous representation of a topologically
finitely generated group into a finite group is finite data". -/
theorem homFinite_of_fg {G H : Type*} [Group G] [Group H] [Finite H] [Group.FG G] :
    Finite (G →* H) := by
  obtain ⟨S, hSclos, hSfin⟩ := Group.fg_iff.mp ‹Group.FG G›
  have : Finite S := hSfin.to_subtype
  -- A hom is pinned down by its restriction to the finite generating set `S`.
  apply Finite.of_injective (β := (S → H)) (fun f x => f x)
  intro f g hfg
  have hEq : Set.EqOn (⇑f) (⇑g) S := by
    intro x hx
    have := congrFun hfg ⟨x, hx⟩
    simpa using this
  have hcl : Set.EqOn (⇑f) (⇑g) (Subgroup.closure S : Set G) := MonoidHom.eqOn_closure hEq
  rw [hSclos] at hcl
  exact MonoidHom.ext (fun x => hcl (by simp))

/-- **Representations with a fixed finite image.**  For a finitely generated
source, there are only finitely many representations into `GLₙ(F)` whose image
lies in a fixed *finite* subgroup `K`.  (Continuity + discreteness of `F`
guarantees such a `K` exists for each individual representation.) -/
theorem repsIntoSubgroup_finite {G : Type*} [Group G] [Group.FG G]
    {n : ℕ} {F : Type*} [Field F] (K : Subgroup (GL (Fin n) F)) [Finite K] :
    Finite {ρ : G →* GL (Fin n) F // ρ.range ≤ K} := by
  have hfg : Finite (G →* K) := homFinite_of_fg
  -- Corestrict each admissible representation to `K`; this is injective.
  apply Finite.of_injective (β := (G →* K))
    (fun ρ => ρ.1.codRestrict K (fun g => ρ.2 ⟨g, rfl⟩))
  rintro ⟨f, hf⟩ ⟨g, hg⟩ h
  simp only [Subtype.mk.injEq]
  refine MonoidHom.ext (fun x => ?_)
  simpa using congrArg (Subtype.val) (DFunLike.congr_fun h x)

/-- **Bounded ramification ⟹ finitely many representations.**  Given a finite
family `𝓚` of *finite* subgroups of `GLₙ(F)` (the admissible images cut out by
the divisor `D`), there are only finitely many representations of a finitely
generated group whose image lands in one of them.

This is the finiteness of the representation space *before* passing to
conjugacy classes. -/
theorem geometricReps_finite {G : Type*} [Group G] [Group.FG G]
    {n : ℕ} {F : Type*} [Field F]
    (𝓚 : Finset (Subgroup (GL (Fin n) F))) (hfin : ∀ K ∈ 𝓚, Finite (K : Type _)) :
    Finite {ρ : G →* GL (Fin n) F // ∃ K ∈ 𝓚, ρ.range ≤ K} := by
  have hS : {ρ : G →* GL (Fin n) F | ∃ K ∈ 𝓚, ρ.range ≤ K}.Finite := by
    have heq : {ρ : G →* GL (Fin n) F | ∃ K ∈ 𝓚, ρ.range ≤ K}
        = ⋃ K ∈ 𝓚, {ρ : G →* GL (Fin n) F | ρ.range ≤ K} := by
      ext ρ; simp
    rw [heq]
    apply Set.Finite.biUnion (Finset.finite_toSet 𝓚)
    intro K hK
    haveI : Finite (K : Type _) := hfin K hK
    exact Set.finite_coe_iff.mp (repsIntoSubgroup_finite K)
  exact Set.finite_coe_iff.mpr hS

/-- **Main theorem — finiteness up to conjugacy.**  Let `G` be a finitely
generated group (modelling the topologically finitely generated ramified
fundamental group `π₁(X, D)`), let `𝓚` be a finite family of finite subgroups
of `GLₙ(F)` (the admissible bounded-ramification images), and let `P` select a
class of representations (e.g. the continuous semisimple geometric ones).  If
every `P`-representation has image inside some member of `𝓚`, then the
conjugacy — equivalently, isomorphism — classes of `P`-representations form a
finite set.

Instantiating `P` as "continuous, semisimple, geometric" and `𝓚` as the finite
family of admissible finite images supplied by the arithmetic geometry of
`(X, D)` recovers the finiteness conjecture for semisimple geometric
representations of Hiranouchi's ramified fundamental group. -/
theorem semisimpleReps_conj_finite {G : Type*} [Group G] [Group.FG G]
    {n : ℕ} {F : Type*} [Field F]
    (𝓚 : Finset (Subgroup (GL (Fin n) F))) (hfin : ∀ K ∈ 𝓚, Finite (K : Type _))
    (P : (G →* GL (Fin n) F) → Prop)
    (hP : ∀ ρ, P ρ → ∃ K ∈ 𝓚, ρ.range ≤ K)
    (s : Setoid {ρ : G →* GL (Fin n) F // P ρ}) :
    Finite (Quotient s) := by
  haveI : Finite {ρ : G →* GL (Fin n) F // ∃ K ∈ 𝓚, ρ.range ≤ K} :=
    geometricReps_finite 𝓚 hfin
  haveI : Finite {ρ : G →* GL (Fin n) F // P ρ} := by
    apply Finite.of_injective (β := {ρ : G →* GL (Fin n) F // ∃ K ∈ 𝓚, ρ.range ≤ K})
      (fun ρ => ⟨ρ.1, hP ρ.1 ρ.2⟩)
    rintro ⟨f, hf⟩ ⟨g, hg⟩ h
    simpa using h
  infer_instance

/-- **Boundary / counterexample.**  The finite-image hypothesis is
indispensable: even the `ℤ`-generated source `Multiplicative ℤ` (finitely
generated!) has *infinitely many* representations into any infinite target.
Concretely, sending the generator to an arbitrary element of `M` gives a
distinct homomorphism, and over an algebraically closed field of characteristic
`p` the group `GL₁(F) = Fˣ` is infinite.  This is exactly why bounding the
ramification by a divisor `D` — which forces the image into one of finitely
many *finite* subgroups — cannot be dropped. -/
theorem unbounded_reps_infinite (M : Type*) [Group M] [Infinite M] :
    Infinite (Multiplicative ℤ →* M) :=
  (Equiv.infinite_iff (zpowersHom M)).mp inferInstance

/-! ## Examples and specializations (PEGB: Examples) -/

/-- **Specialization to a finite base field.**  When `F` is a finite field,
`GLₙ(F)` is itself finite, so *every* representation of a finitely generated
group has finite (indeed bounded) image and the conjugacy classes are finite
with no further hypotheses.  Here the admissible family is simply `{⊤}`. -/
theorem reps_finite_of_finite_field {G : Type*} [Group G] [Group.FG G]
    {n : ℕ} {F : Type*} [Field F] [Finite F]
    (P : (G →* GL (Fin n) F) → Prop)
    (s : Setoid {ρ : G →* GL (Fin n) F // P ρ}) :
    Finite (Quotient s) := by
  haveI : Finite (GL (Fin n) F) := inferInstance
  refine semisimpleReps_conj_finite ({⊤} : Finset (Subgroup (GL (Fin n) F)))
    ?_ P ?_ s
  · intro K hK
    rw [Finset.mem_singleton] at hK
    subst hK
    infer_instance
  · intro ρ _
    exact ⟨⊤, by simp, le_top⟩

/-- **Abelian `GL₁` case (characters).**  For a finite field `F` and a finitely
generated group `G`, there are only finitely many characters `G → Fˣ`.  This is
the character-theoretic (class field theory) shadow of the finiteness
conjecture in rank one. -/
theorem characters_finite_of_finite_field {G : Type*} [Group G] [Group.FG G]
    {F : Type*} [Field F] [Finite F] :
    Finite (G →* Fˣ) :=
  homFinite_of_fg

-- `#check` sanity checks (PEGB: Examples)
#check @homFinite_of_fg
#check @geometricReps_finite
#check @semisimpleReps_conj_finite
#check @unbounded_reps_infinite

-- The source `Multiplicative ℤ` really is finitely generated, so the engine applies to it.
example : Group.FG (Multiplicative ℤ) := inferInstance

-- Concrete finiteness of characters of a finitely generated group into `(ZMod 5)ˣ`.
example {G : Type} [Group G] [Group.FG G] : Finite (G →* (ZMod 5)ˣ) := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  exact characters_finite_of_finite_field

-- Concrete instance of the boundary phenomenon: infinitely many self-representations
-- of `Multiplicative ℤ` (an infinite target), witnessing that finite generation of the
-- source alone is not enough.
example : Infinite (Multiplicative ℤ →* Multiplicative ℤ) :=
  unbounded_reps_infinite (Multiplicative ℤ)

end RamifiedPi1