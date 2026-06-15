import Mathlib
import Bridges.CoalgebraicNeuralMyhillNerode
import Algebra.ProofSpectra.Core

/-! # A Functor from Neural Observation Pseudometrics to Proof-Spectrum Congruence Kernels

This file builds an explicit **bridge** between two prior catalog developments:

* `Bridges.CoalgebraicNeuralMyhillNerode` — coalgebraic behavioral equivalence of
  neural observation systems (the Myhill–Nerode quotient / "compression" theory), and
* `Algebra.ProofSpectra.Core` — semiring congruences `SRCong R` and their proof spectra
  (the "proof-theoretic algebraic geometry" of prime congruences).

## The bridge in one sentence

If a neural observation system is *algebraic* — its state space `R` and its output space
`K` are semirings and every layer (`step a`) together with the read-out (`observe`) is a
semiring map — then the coalgebraic **behavioral equivalence kernel** is not just an
equivalence relation but a genuine **semiring congruence** `SRCong R`, i.e. a point of the
proof-spectrum world. The assignment `N ↦ behaviorCongruence N` is *functorial*:
intertwining morphisms of algebraic neural systems push the congruence forward.

On the analytic side, the same kernel is realised as the zero-set of an **observation
pseudometric** `obsDist`. The punchline theorem `pseudometric_kernel_eq_congruence`
identifies the metric kernel `{(x,y) | obsDist N x y = 0}` with the semiring congruence
`behaviorCongruence N`, closing the loop:

  neural observation pseudometric  ⟶  congruence kernel  ⟶  proof-spectrum congruence.

## Main results

* `algBehavior_add`, `algBehavior_mul`, `algBehavior_zero` — the behavior map is a
  semiring map in its state argument.
* `behaviorCongruence` — the functor object: behavioral equivalence as an `SRCong R`.
* `behaviorCongruence_rel_iff_weighted_equiv` — it coincides with the catalog's
  `weighted_neural_equiv`.
* `behaviorCongruence_zeroClass` — the congruence kernel's zero-class is the set of
  behaviorally-null states.
* `behaviorRel_iff_all_depth` — the kernel is the intersection of the depth filtration
  (`neural_equiv_upto`), tying it to partition refinement.
* `algBehavior_map`, `behaviorCongruence_map` — functoriality along intertwining
  morphisms of algebraic neural systems.
* `obsDist_*` — `obsDist` is a pseudometric (nonneg, self-zero, symmetric, triangle).
* `pseudometric_kernel_eq_congruence` — the metric kernel equals the semiring congruence.

## Bridges
- **Coalgebra / Myhill–Nerode ↔ Proof-Theoretic Algebraic Geometry**: behavioral
  equivalence of an algebraic neural system *is* a semiring congruence (a proof-spectrum
  point datum).
- **Metric geometry ↔ Universal algebra**: the kernel of a behavioral pseudometric
  is a congruence; the analytic and algebraic quotients agree.
- **Certified compression ↔ Functoriality**: semantics-preserving architecture maps act
  functorially on congruence kernels.
-/

noncomputable section
open Classical
open Bridges.AlgebraMachineLearning

namespace Bridges.NeuralProofSpectrum

universe u v w

/-! ## Section 1: Algebraic (semiring-compatible) neural observation systems

-- !-- Lab Notes -- !--
-- Hypothesis H1: the coalgebraic behavioral equivalence of the Myhill–Nerode file is
-- "really" a congruence whenever the dynamics are algebraic.  To test it we need the
-- weakest structure that makes the behavior map `x ↦ (w ↦ observe (foldl step x w))` a
-- semiring homomorphism in `x`.  Pointwise that requires each `step a` and `observe` to
-- preserve `0`, `+`, `*`.  We do NOT require preservation of `1`: behavioral equivalence
-- never inspects the multiplicative unit of the *state* space, only sums and products of
-- states, so demanding `step a 1 = 1` would be an unused (and false-in-general)
-- hypothesis.  This minimality is confirmed below: every congruence axiom goes through
-- with the six laws stated here.
-/

/-- An **algebraic neural observation system**: a `NeuralObservationSystem`/
    `WeightedNeuralObservationSystem` whose state space `R` and output space `K` are
    semirings and whose layers `step a` and read-out `observe` are semiring maps
    (preserving `0`, `+`, `*`). -/
structure AlgNeuralSystem (R K : Type*) (α : Type*) [Semiring R] [Semiring K] where
  /-- One layer of dynamics for each input symbol. -/
  step : R → α → R
  /-- The read-out map into the output semiring. -/
  observe : R → K
  /-- Each layer kills `0`. -/
  step_zero : ∀ a, step 0 a = 0
  /-- Each layer is additive. -/
  step_add : ∀ a x y, step (x + y) a = step x a + step y a
  /-- Each layer is multiplicative. -/
  step_mul : ∀ a x y, step (x * y) a = step x a * step y a
  /-- The read-out kills `0`. -/
  observe_zero : observe 0 = 0
  /-- The read-out is additive. -/
  observe_add : ∀ x y, observe (x + y) = observe x + observe y
  /-- The read-out is multiplicative. -/
  observe_mul : ∀ x y, observe (x * y) = observe x * observe y

variable {R S K : Type*} {α : Type*}

/-- The underlying (catalog) weighted observation system. -/
def AlgNeuralSystem.toWeighted [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) : WeightedNeuralObservationSystem R α K where
  step := N.step
  observe := N.observe

/-- The behavior map of an algebraic neural system: it is exactly the catalog's
    `weighted_neural_behavior` of the underlying weighted system. -/
def algBehavior [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x : R) (w : List α) : K :=
  weighted_neural_behavior N.toWeighted x w

theorem algBehavior_def [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x : R) (w : List α) :
    algBehavior N x w = N.observe (w.foldl N.step x) := rfl

/-! ## Section 2: The behavior map is a semiring map in its state argument -/

/-
`foldl` of the layers kills `0`.
-/
theorem foldl_step_zero [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (w : List α) :
    w.foldl N.step 0 = 0 := by
      induction w <;> simp +decide [ *, N.step_zero ]

/-
`foldl` of the layers is additive in the start state.
-/
theorem foldl_step_add [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (w : List α) (x y : R) :
    w.foldl N.step (x + y) = w.foldl N.step x + w.foldl N.step y := by
      induction w using List.reverseRecOn <;> simp_all +decide
      exact N.step_add _ _ _

/-
`foldl` of the layers is multiplicative in the start state.
-/
theorem foldl_step_mul [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (w : List α) (x y : R) :
    w.foldl N.step (x * y) = w.foldl N.step x * w.foldl N.step y := by
      induction' w using List.reverseRecOn with w a ih <;> simp +decide [ * ]
      exact N.step_mul a _ _

/-
The behavior of the zero state is identically `0`.
-/
theorem algBehavior_zero [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (w : List α) :
    algBehavior N 0 w = 0 := by
      exact N.observe_zero ▸ by rw [ algBehavior_def, foldl_step_zero ] ;

/-
The behavior map is additive in its state argument.
-/
theorem algBehavior_add [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) (w : List α) :
    algBehavior N (x + y) w = algBehavior N x w + algBehavior N y w := by
      convert N.observe_add ( w.foldl N.step x ) ( w.foldl N.step y ) using 1;
      exact congr_arg _ ( foldl_step_add N w x y )

/-
The behavior map is multiplicative in its state argument.
-/
theorem algBehavior_mul [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) (w : List α) :
    algBehavior N (x * y) w = algBehavior N x w * algBehavior N y w := by
      simp [algBehavior, weighted_neural_behavior, AlgNeuralSystem.toWeighted, foldl_step_mul, N.observe_mul]

/-! ## Section 3: The behavior congruence — the functor object

-- !-- Lab Notes -- !--
-- Result R1 (the bridge): with Section 2 in hand, the kernel relation
-- `behaviorRel N x y := ∀ w, algBehavior N x w = algBehavior N y w` satisfies the four
-- `SRCong` compatibility laws.  Symmetry/transitivity/reflexivity are formal; the
-- substantive content is `add_compat`/`mul_compat`, which are immediate from
-- `algBehavior_add`/`algBehavior_mul`.  So the coalgebraic behavioral equivalence of the
-- Myhill–Nerode file is upgraded to a *semiring congruence* — a datum of the proof
-- spectrum.
-/

/-- The behavioral equivalence kernel relation of an algebraic neural system. -/
def behaviorRel [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) : Prop :=
  ∀ w : List α, algBehavior N x w = algBehavior N y w

theorem behaviorRel_refl [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x : R) : behaviorRel N x x := by
      exact fun _ => rfl

theorem behaviorRel_symm [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) {x y : R} (h : behaviorRel N x y) :
    behaviorRel N y x := by
      exact fun w => Eq.symm ( h w )

theorem behaviorRel_trans [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) {x y z : R}
    (hxy : behaviorRel N x y) (hyz : behaviorRel N y z) : behaviorRel N x z := by
      exact fun w => hxy w ▸ hyz w ▸ rfl

theorem behaviorRel_add [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) {a b c d : R}
    (hab : behaviorRel N a b) (hcd : behaviorRel N c d) :
    behaviorRel N (a + c) (b + d) := by
      intro w
      rw [algBehavior_add, algBehavior_add, hab w, hcd w]

theorem behaviorRel_mul [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) {a b c d : R}
    (hab : behaviorRel N a b) (hcd : behaviorRel N c d) :
    behaviorRel N (a * c) (b * d) := by
      intro w
      rw [algBehavior_mul, algBehavior_mul]
      generalize_proofs at *;
      rw [ hab w, hcd w ]

/-- **The functor object.** The behavioral equivalence kernel of an algebraic neural
    observation system, packaged as a semiring congruence `SRCong R`, i.e. as a datum of
    proof-theoretic algebraic geometry. -/
def behaviorCongruence [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) : SRCong R where
  rel := behaviorRel N
  refl := behaviorRel_refl N
  symm := behaviorRel_symm N
  trans := behaviorRel_trans N
  add_compat := behaviorRel_add N
  mul_compat := behaviorRel_mul N

/-- The semiring congruence coincides with the catalog's coalgebraic behavioral
    equivalence of the underlying weighted system. -/
theorem behaviorCongruence_rel_iff_weighted_equiv [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) :
    (behaviorCongruence N).rel x y ↔ weighted_neural_equiv N.toWeighted x y := Iff.rfl

/-
The zero-class of the behavior congruence is exactly the set of behaviorally-null
    states (states whose every observation vanishes).
-/
theorem behaviorCongruence_zeroClass [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) :
    (behaviorCongruence N).zeroClass = {x : R | ∀ w : List α, algBehavior N x w = 0} := by
  ext x; simp [SRCong.zeroClass, behaviorCongruence];
  exact ⟨ fun h w => by simpa [ algBehavior_zero ] using h w, fun h w => by simpa [ algBehavior_zero ] using h w ⟩

/-! ## Section 4: The kernel is the limit of the depth filtration

-- !-- Lab Notes -- !--
-- Insight I1: the congruence kernel is the *intersection over depth* of the partition
-- refinement filtration `neural_equiv_upto k` from the Myhill–Nerode file.  This reuses
-- `neural_equiv_of_all_upto` and `neural_equiv_implies_upto` verbatim through the
-- definitional identity `algBehavior N = neural_behavior (weighted_to_neural N.toWeighted)`.
-- Bridge meaning: the proof-spectrum congruence is reconstructed by a converging sequence
-- of finite-depth observers (the O(|α|^k) budget of the source file).
-/

theorem behaviorRel_iff_all_depth [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) :
    behaviorRel N x y ↔
      ∀ k : ℕ, neural_equiv_upto (weighted_to_neural N.toWeighted) k x y := by
  constructor
  · exact fun h k => neural_equiv_implies_upto _ h
  · exact fun h => neural_equiv_of_all_upto _ h

/-! ## Section 5: Functoriality along intertwining morphisms

-- !-- Lab Notes -- !--
-- Result R2 (functoriality): a state map intertwining `step` and `observe` is precisely a
-- `NeuralHom` of the underlying coalgebras, so `neural_hom_preserves_behavior` gives
-- `algBehavior N x = algBehavior M (f x)` for free.  Hence `f` carries `behaviorCongruence N`
-- into `behaviorCongruence M`: the assignment `N ↦ behaviorCongruence N` is functorial.
-- (We phrase functoriality as a pushforward of the relation; we deliberately do NOT
-- assume `f` is a ring hom — only that it intertwines the dynamics — because that is all
-- behavior preservation needs.)
-/

/-- A morphism of algebraic neural systems over a common alphabet and output semiring:
    a state map intertwining the layers and the read-out. -/
structure AlgNeuralHom [Semiring R] [Semiring S] [Semiring K]
    (N : AlgNeuralSystem R K α) (M : AlgNeuralSystem S K α) where
  /-- The underlying state map. -/
  toFun : R → S
  /-- Intertwines the layers. -/
  map_step : ∀ x a, toFun (N.step x a) = M.step (toFun x) a
  /-- Intertwines the read-out. -/
  map_observe : ∀ x, N.observe x = M.observe (toFun x)

/-- The underlying coalgebra morphism of the catalog file. -/
def AlgNeuralHom.toNeuralHom [Semiring R] [Semiring S] [Semiring K]
    {N : AlgNeuralSystem R K α} {M : AlgNeuralSystem S K α} (f : AlgNeuralHom N M) :
    NeuralHom (weighted_to_neural N.toWeighted) (weighted_to_neural M.toWeighted) where
  toFun := f.toFun
  map_step := f.map_step
  map_observe := f.map_observe

/-
An intertwining morphism preserves behavior on every context.
-/
theorem algBehavior_map [Semiring R] [Semiring S] [Semiring K]
    {N : AlgNeuralSystem R K α} {M : AlgNeuralSystem S K α} (f : AlgNeuralHom N M)
    (x : R) (w : List α) :
    algBehavior N x w = algBehavior M (f.toFun x) w := by
      convert neural_hom_preserves_behavior ( f.toNeuralHom ) x w using 1

/-
**Functoriality.** An intertwining morphism pushes the source congruence into the
    target congruence.
-/
theorem behaviorCongruence_map [Semiring R] [Semiring S] [Semiring K]
    {N : AlgNeuralSystem R K α} {M : AlgNeuralSystem S K α} (f : AlgNeuralHom N M)
    {x y : R} (h : (behaviorCongruence N).rel x y) :
    (behaviorCongruence M).rel (f.toFun x) (f.toFun y) := by
      exact fun w => by rw [ ← algBehavior_map f x w, ← algBehavior_map f y w, h w ] ;

/-! ## Section 6: The observation pseudometric and its kernel

-- !-- Lab Notes -- !--
-- Hypothesis H2 (analytic realisation): the congruence kernel is the zero-set of a
-- pseudometric.  We use the canonical pseudometric induced by an equivalence relation:
-- `obsDist x y = 0` if behaviorally equal, else `1`.  This is genuinely a pseudometric
-- (not a metric: distinct-but-equivalent states are at distance 0), and it descends to a
-- metric exactly on the Myhill–Nerode quotient.  The triangle inequality is the only
-- non-formal axiom and follows from transitivity of `behaviorRel`.
--
-- Failure analysis F1 (why not a graded ultrametric here): the natural depth-graded
-- ultrametric `2^{-(first separating depth)}` requires a least-separating-depth, which is
-- only well defined when some finite depth separates the states; encoding the `sInf` of a
-- possibly-empty set forces the degenerate value `0` and breaks the "distance > 0 ⇒
-- distinguishable" direction.  The discrete pseudometric avoids this cleanly while still
-- exposing the kernel = congruence identity, which is the point of the bridge.  The graded
-- version is recorded as a conjecture in FUTURE_DIRECTIONS.md.
--
-- Failure analysis F2 (primality is NOT automatic): one might hope `behaviorCongruence N`
-- is a *prime* congruence when `K` is an integral domain.  It is not, in general: from
-- `∀ w, algBehavior N (a*b) w = 0` and no zero-divisors we only get, for *each* `w`,
-- `algBehavior N a w = 0` ∨ `algBehavior N b w = 0` — a pointwise disjunction that does
-- not factor through to `(∀ w, … a … = 0) ∨ (∀ w, … b … = 0)`.  Primality therefore needs
-- a genuine extra hypothesis (see FUTURE_DIRECTIONS.md).
-/

/-- The **observation pseudometric** induced by behavioral equivalence: distance `0` for
    behaviorally indistinguishable states, distance `1` otherwise. -/
def obsDist [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) : ℝ :=
  if behaviorRel N x y then 0 else 1

theorem obsDist_nonneg [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) : 0 ≤ obsDist N x y := by
      unfold obsDist; split_ifs <;> norm_num;

theorem obsDist_self [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x : R) : obsDist N x x = 0 := by
      -- By definition of `obsDist`, we know that `obsDist N x x = 0` if and only if `behaviorRel N x x` holds.
      simp [obsDist, behaviorRel_refl]

theorem obsDist_comm [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) : obsDist N x y = obsDist N y x := by
      grind +locals

theorem obsDist_triangle [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y z : R) :
    obsDist N x z ≤ obsDist N x y + obsDist N y z := by
      grind +locals

theorem obsDist_eq_zero_iff [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) :
    obsDist N x y = 0 ↔ behaviorRel N x y := by
      unfold obsDist; aesop;

/-
**Punchline.** The kernel of the observation pseudometric is exactly the
    proof-spectrum semiring congruence: the analytic and algebraic quotients agree.
-/
theorem pseudometric_kernel_eq_congruence [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) :
    obsDist N x y = 0 ↔ (behaviorCongruence N).rel x y := by
      convert obsDist_eq_zero_iff N x y using 1

/-! ## Section 7: Capstone — the functorial comparison

-- !-- Lab Notes -- !--
-- Summary S1: bundling the three identities exhibits the full bridge.  Reading left to
-- right: the metric kernel equals the coalgebraic behavioral equivalence equals the
-- semiring-congruence relation.  All three live over the *same* relation on states, so the
-- pseudometric quotient, the Myhill–Nerode quotient, and the proof-spectrum congruence
-- coincide.
-/

/-
The three faces of the same kernel: observation pseudometric, coalgebraic behavioral
    equivalence, and proof-spectrum semiring congruence all agree.
-/
theorem neural_pseudometric_congruence_comparison [Semiring R] [Semiring K]
    (N : AlgNeuralSystem R K α) (x y : R) :
    (obsDist N x y = 0 ↔ weighted_neural_equiv N.toWeighted x y) ∧
    (weighted_neural_equiv N.toWeighted x y ↔ (behaviorCongruence N).rel x y) := by
  unfold obsDist;
  unfold behaviorRel; aesop;

end Bridges.NeuralProofSpectrum