import Mathlib

/-! # Heine-Cantor Bridge

Proves the Heine-Cantor theorem and its consequences:

1. Continuous on compact → uniform continuous (Heine-Cantor)
2. Lipschitz implies uniform continuous (explicit modulus)
3. Isometric implies uniform continuous

This is fundamental for certified robustness: uniform continuity
guarantees small input perturbations → small output changes, UNIFORMLY.
-/

namespace HeineCantorBridge

/-! ## Section 1: Heine-Cantor Theorem -/

/-- Heine-Cantor theorem: a continuous function on a compact space
    is uniformly continuous.
    For certified robustness: ∃δ(ε) > 0 such that
    ‖x-y‖<δ → ‖f(x)-f(y)‖<ε, where δ depends ONLY on ε, not on x. -/
theorem heine_cantor {X : Type*} [MetricSpace X] [CompactSpace X]
    {Y : Type*} [MetricSpace Y] {f : X → Y} (hf : Continuous f) :
    UniformContinuous f :=
  CompactSpace.uniformContinuous_of_continuous hf

/-! ## Section 2: Implications -/

/-- Lipschitz implies uniform continuity.
    If Lip(f) ≤ K, then δ = ε/K gives the uniform modulus.
    This is STRONGER than Heine-Cantor (explicit δ from Lipschitz constant). -/
theorem lipschitz_implies_uniform {X : Type*} [MetricSpace X]
    {Y : Type*} [MetricSpace Y] {K : NNReal} {f : X → Y}
    (hf : LipschitzWith K f) : UniformContinuous f :=
  LipschitzWith.uniformContinuous hf

/-- Isometric implies uniform continuous. -/
theorem isometry_uniform {X : Type*} [MetricSpace X]
    {Y : Type*} [MetricSpace Y] {f : X → Y}
    (hf : Isometry f) : UniformContinuous f :=
  Isometry.uniformContinuous hf

/-- Closed interval [a,b] is compact in ℝ. -/
theorem Icc_compact (a b : ℝ) : IsCompact (Set.Icc a b) :=
  isCompact_Icc

/-- Uniform continuity of the identity: id is 1-Lipschitz. -/
theorem identity_lipschitz : LipschitzWith (1 : NNReal) (@id ℝ) :=
  LipschitzWith.id

/-- Composition of uniformly continuous functions is uniformly continuous. -/
theorem uniform_continuous_comp {X Y Z : Type*} [UniformSpace X]
    [UniformSpace Y] [UniformSpace Z] {f : Y → Z} {g : X → Y}
    (hf : UniformContinuous f) (hg : UniformContinuous g) :
    UniformContinuous (f ∘ g) :=
  UniformContinuous.comp hf hg

end HeineCantorBridge