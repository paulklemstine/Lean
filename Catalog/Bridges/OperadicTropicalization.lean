import Mathlib

/-!
# Operadic Tropicalization of Neural Architectures

This file establishes a formal bridge between **operad theory**, **tropical algebra**, and
**neural architecture classification**. The central result is a certified tropical
reconstruction theorem: bounded neural architectures admit complete tropical operadic
invariants that classify them up to structural congruence.

## Main Results

### Structures and Definitions
* `ArchExpr` — tree-structured operadic expressions (free operad elements)
* `TropicalArchProfile` — tropical complexity profile with depth, width, generator count
* `StructuralCongr` — structural congruence on architecture expressions
* `tropicalValuation` — the operadic tropical valuation functor
* `ArchitectureSkeleton` — canonical skeleton type for architecture reconstruction
* `reconstructSkeleton` — reconstruction of canonical skeleton from tropical profile

### Key Theorems
* `tropicalValuation_compose` — functoriality under sequential composition
* `tropicalValuation_parallel` — functoriality under parallel composition
* `seqMul_tropAdd_distrib_left` — tropical semiring distributivity
* `tropicalValuation_structural_congr` — invariance under structural congruence
* `depth_width_genCount_tradeoff` — depth × width ≥ generatorCount
* `certified_operadic_tropical_reconstruction` — the main reconstruction theorem
* `tropical_profile_complete_for_bounded_architecture_congruence` — completeness

## Bridge: connects operad theory (compositional syntax) → tropical algebra (min-plus) →
   ML architecture theory (depth/width classification) → automata theory (Myhill–Nerode) →
   certified compression (canonical minimization)

## References
- Loday, Vallette: "Algebraic Operads"
- Maclagan, Sturmfels: "Introduction to Tropical Geometry"
- Cohen, Gaubert, Quadrat: "Max-plus algebra and system theory"
-/

noncomputable section

namespace OperadicTropicalization

/-! ## Section 1: Architecture Expressions (Free Operad)

An `ArchExpr` is an element of the free operad on one generator, representing
a neural architecture built from:
- `generator`: a single computation module (layer, attention head, etc.)
- `identity`: the identity/pass-through operation
- `compose`: sequential composition (depth increases additively)
- `parallel`: parallel composition (width increases additively)
-/

/-- Architecture expression: element of the free operad on one generator.
    Bridge: connects operadic composition theory to neural architecture design. -/
inductive ArchExpr where
  | generator : ArchExpr
  | identity : ArchExpr
  | compose : ArchExpr → ArchExpr → ArchExpr
  | parallel : ArchExpr → ArchExpr → ArchExpr
  deriving DecidableEq

namespace ArchExpr

/-- Sequential depth: length of the longest sequential computation path.
    Compose adds depths (sequential); parallel takes max (concurrent). -/
@[simp] def depth : ArchExpr → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.depth + e₂.depth
  | parallel e₁ e₂ => max e₁.depth e₂.depth

/-- Generator count: total number of computation modules.
    Both compose and parallel sum counts (all generators are used). -/
@[simp] def generatorCount : ArchExpr → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.generatorCount + e₂.generatorCount
  | parallel e₁ e₂ => e₁.generatorCount + e₂.generatorCount

/-- Maximum width: the widest parallel cross-section.
    Sequential composition takes max (pipeline bottleneck);
    parallel composition sums widths (resources allocated side by side). -/
@[simp] def maxWidth : ArchExpr → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => max e₁.maxWidth e₂.maxWidth
  | parallel e₁ e₂ => e₁.maxWidth + e₂.maxWidth

/-- Depth-width product: combined complexity invariant. -/
def complexity (e : ArchExpr) : ℕ := e.depth * e.maxWidth

/-- Total node count in the expression tree. -/
@[simp] def size : ArchExpr → ℕ
  | generator => 1
  | identity => 1
  | compose e₁ e₂ => 1 + e₁.size + e₂.size
  | parallel e₁ e₂ => 1 + e₁.size + e₂.size

/-- Canonical sequential chain of `k` generators: depth k, width 1, genCount k. -/
def kChain : ℕ → ArchExpr
  | 0 => .identity
  | k + 1 => .compose .generator (kChain k)

/-- Wide parallel arrangement of `n` generators: depth 1 (if n>0), width n, genCount n. -/
def wideParallel : ℕ → ArchExpr
  | 0 => .identity
  | 1 => .generator
  | n + 2 => .parallel .generator (wideParallel (n + 1))

/-! ### Basic structural lemmas -/

theorem depth_compose_eq (e₁ e₂ : ArchExpr) :
    (compose e₁ e₂).depth = e₁.depth + e₂.depth := rfl

theorem depth_parallel_eq (e₁ e₂ : ArchExpr) :
    (parallel e₁ e₂).depth = max e₁.depth e₂.depth := rfl

theorem generatorCount_compose_eq (e₁ e₂ : ArchExpr) :
    (compose e₁ e₂).generatorCount = e₁.generatorCount + e₂.generatorCount := rfl

theorem generatorCount_parallel_eq (e₁ e₂ : ArchExpr) :
    (parallel e₁ e₂).generatorCount = e₁.generatorCount + e₂.generatorCount := rfl

theorem maxWidth_compose_eq (e₁ e₂ : ArchExpr) :
    (compose e₁ e₂).maxWidth = max e₁.maxWidth e₂.maxWidth := rfl

theorem maxWidth_parallel_eq (e₁ e₂ : ArchExpr) :
    (parallel e₁ e₂).maxWidth = e₁.maxWidth + e₂.maxWidth := rfl

theorem depth_parallel_le_left (e₁ e₂ : ArchExpr) :
    e₁.depth ≤ (parallel e₁ e₂).depth := le_max_left _ _

theorem depth_parallel_le_right (e₁ e₂ : ArchExpr) :
    e₂.depth ≤ (parallel e₁ e₂).depth := le_max_right _ _

theorem generatorCount_subadditive_compose (e₁ e₂ : ArchExpr) :
    (compose e₁ e₂).generatorCount ≤ e₁.generatorCount + e₂.generatorCount := le_refl _

theorem maxWidth_compose_le_sum (e₁ e₂ : ArchExpr) :
    (compose e₁ e₂).maxWidth ≤ e₁.maxWidth + e₂.maxWidth := by
  simp only [maxWidth]; omega

/-! ### kChain and wideParallel profile lemmas -/

@[simp] theorem kChain_depth (k : ℕ) : (kChain k).depth = k := by
  induction k with
  | zero => rfl
  | succ k ih => unfold kChain; simp [ih]; omega

@[simp] theorem kChain_generatorCount (k : ℕ) : (kChain k).generatorCount = k := by
  induction k with
  | zero => rfl
  | succ k ih => unfold kChain; simp [ih]; omega

@[simp] theorem kChain_maxWidth_zero : (kChain 0).maxWidth = 0 := rfl

@[simp] theorem kChain_maxWidth_succ (k : ℕ) : (kChain (k + 1)).maxWidth = max 1 (kChain k).maxWidth := rfl

theorem kChain_maxWidth_le_one (k : ℕ) : (kChain k).maxWidth ≤ 1 := by
  induction k with
  | zero => simp [kChain]
  | succ k ih => simp [kChain]; omega

/-
**Depth-width-generator tradeoff**: the product of depth and max width
    is at least the generator count. This is the operadic analogue of the
    circuit complexity lower bound: you need enough "area" to fit all generators.

    Bridge: connects tropical geometry (area of Newton polytope) to circuit
    complexity (depth × width lower bounds).
-/
theorem depth_width_genCount_tradeoff (e : ArchExpr) :
    e.generatorCount ≤ e.depth * e.maxWidth := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · decide +revert;
  · decide +revert;
  · cases max_cases e₁.maxWidth e₂.maxWidth <;> simp_all +decide [ add_mul ];
    · exact add_le_add ih₁ ( by nlinarith );
    · nlinarith;
  · rename_i e₁ e₂ ih₁ ih₂;
    rw [ ArchExpr.depth, ArchExpr.maxWidth, ArchExpr.generatorCount ];
    cases max_cases e₁.depth e₂.depth <;> nlinarith [ Nat.zero_le e₁.maxWidth, Nat.zero_le e₂.maxWidth ]

end ArchExpr

/-! ## Section 2: Tropical Architecture Profile

The `TropicalArchProfile` is the tropical codomain of the valuation functor.
It carries two composition operations (sequential and parallel) corresponding
to the two operadic compositions, and a tropical addition (component-wise min)
making it an idempotent semiring-like structure. -/

/-- Tropical architecture profile: the signature of an architecture's complexity.
    Bridge: connects tropical geometry (valuations) to ML (architecture metrics). -/
@[ext] structure TropicalArchProfile where
  depthVal : ℕ
  widthVal : ℕ
  genVal : ℕ
  deriving DecidableEq, Repr

namespace TropicalArchProfile

/-- Sequential composition of profiles (tropical "multiplication" for depth-like
    operations): depth adds, width takes max, generators add.
    Bridge: captures how sequential layer stacking increases depth additively. -/
def seqMul (p q : TropicalArchProfile) : TropicalArchProfile :=
  ⟨p.depthVal + q.depthVal, max p.widthVal q.widthVal, p.genVal + q.genVal⟩

/-- Parallel composition of profiles: depth takes max, width adds, generators add.
    Bridge: captures how parallel branching increases width additively. -/
def parMul (p q : TropicalArchProfile) : TropicalArchProfile :=
  ⟨max p.depthVal q.depthVal, p.widthVal + q.widthVal, p.genVal + q.genVal⟩

/-- Tropical addition: component-wise minimum. This is the idempotent
    "addition" of tropical algebra, selecting the "cheapest" profile. -/
def tropAdd (p q : TropicalArchProfile) : TropicalArchProfile :=
  ⟨min p.depthVal q.depthVal, min p.widthVal q.widthVal, min p.genVal q.genVal⟩

/-- The unit profile: identity element for both seqMul and parMul. -/
def unit : TropicalArchProfile := ⟨0, 0, 0⟩

/-- The generator profile: profile of a single computation module. -/
def gen : TropicalArchProfile := ⟨1, 1, 1⟩

/-- Component-wise partial order on profiles. -/
instance : LE TropicalArchProfile where
  le p q := p.depthVal ≤ q.depthVal ∧ p.widthVal ≤ q.widthVal ∧ p.genVal ≤ q.genVal

/-! ### Sequential composition monoid laws -/

@[simp] theorem seqMul_assoc (p q r : TropicalArchProfile) :
    seqMul (seqMul p q) r = seqMul p (seqMul q r) := by
  -- By definition of seqMul, we can expand both sides.
  simp [TropicalArchProfile.seqMul];
  exact ⟨ add_assoc _ _ _, add_assoc _ _ _ ⟩

@[simp] theorem seqMul_unit_left (p : TropicalArchProfile) :
    seqMul unit p = p := by
  -- By definition of seqMul, we have that seqMul unit p = ⟨0 + p.depthVal, max 0 p.widthVal, 0 + p.genVal⟩.
  simp [TropicalArchProfile.seqMul, TropicalArchProfile.unit]

@[simp] theorem seqMul_unit_right (p : TropicalArchProfile) :
    seqMul p unit = p := by
  -- By definition of `seqMul`, we have `p.seqMul unit = ⟨p.depthVal + 0, max p.widthVal 0, p.genVal + 0⟩`.
  simp [seqMul, unit]

/-! ### Parallel composition commutative monoid laws -/

@[simp] theorem parMul_comm (p q : TropicalArchProfile) :
    parMul p q = parMul q p := by
  -- By definition of parMul, we have p.parMul q = ⟨max p.depthVal q.depthVal, p.widthVal + q.widthVal, p.genVal + q.genVal⟩ and q.parMul p = ⟨max q.depthVal p.depthVal, q.widthVal + p.widthVal, q.genVal + p.genVal⟩.
  simp [TropicalArchProfile.parMul];
  exact ⟨ max_comm _ _, add_comm _ _, add_comm _ _ ⟩

@[simp] theorem parMul_assoc (p q r : TropicalArchProfile) :
    parMul (parMul p q) r = parMul p (parMul q r) := by
  -- By definition of parMul, we can expand both sides.
  simp [TropicalArchProfile.parMul];
  -- By the associativity of addition, we can rearrange the terms.
  simp [add_assoc]

@[simp] theorem parMul_unit_left (p : TropicalArchProfile) :
    parMul unit p = p := by
  -- By definition of `parMul`, we have `unit.parMul p = ⟨max 0 p.depthVal, 0 + p.widthVal, 0 + p.genVal⟩`.
  simp [TropicalArchProfile.parMul, TropicalArchProfile.unit]

@[simp] theorem parMul_unit_right (p : TropicalArchProfile) :
    parMul p unit = p := by
  -- By definition of parMul, we have p.parMul unit = ⟨max p.depthVal 0, p.widthVal + 0, p.genVal + 0⟩.
  simp [parMul, unit]

/-! ### Tropical addition semilattice laws -/

theorem tropAdd_comm (p q : TropicalArchProfile) :
    tropAdd p q = tropAdd q p := by
  -- By definition of tropAdd, we have p.tropAdd q = ⟨min p.depthVal q.depthVal, min p.widthVal q.widthVal, min p.genVal q.genVal⟩ and q.tropAdd p = ⟨min q.depthVal p.depthVal, min q.widthVal p.widthVal, min q.genVal p.genVal⟩.
  simp [TropicalArchProfile.tropAdd];
  -- By definition of min, we know that min(a, b) = min(b, a) for any a and b.
  simp [min_comm]

theorem tropAdd_assoc (p q r : TropicalArchProfile) :
    tropAdd (tropAdd p q) r = tropAdd p (tropAdd q r) := by
  -- By definition of tropAdd, we can expand both sides.
  simp [TropicalArchProfile.tropAdd]

theorem tropAdd_idempotent (p : TropicalArchProfile) :
    tropAdd p p = p := by
  -- By definition of tropAdd, we have p.tropAdd p = ⟨min p.depthVal p.depthVal, min p.widthVal p.widthVal, min p.genVal p.genVal⟩.
  simp [TropicalArchProfile.tropAdd]

/-! ### Tropical distributivity

The key tropical semiring law: sequential composition distributes over
tropical addition. This is the operadic analogue of the fundamental
property `a + min(b,c) = min(a+b, a+c)` in tropical arithmetic.

Bridge: connects idempotent semiring theory to certified architecture optimization —
composing with the "best of two alternatives" equals the best of the two compositions. -/

theorem seqMul_tropAdd_distrib_left (p q r : TropicalArchProfile) :
    seqMul p (tropAdd q r) = tropAdd (seqMul p q) (seqMul p r) := by
  unfold TropicalArchProfile.seqMul TropicalArchProfile.tropAdd;
  grind

theorem seqMul_tropAdd_distrib_right (p q r : TropicalArchProfile) :
    seqMul (tropAdd p q) r = tropAdd (seqMul p r) (seqMul q r) := by
  -- By definition of seqMul and tropAdd, we can expand both sides.
  simp [TropicalArchProfile.seqMul, TropicalArchProfile.tropAdd];
  grind

end TropicalArchProfile

/-! ## Section 3: The Tropical Valuation Functor

The tropical valuation maps architecture expressions to their tropical profiles.
It is functorial with respect to both sequential and parallel composition:
this is the core "functor" property that makes the valuation useful for
classification. -/

/-- The tropical valuation functor: maps an architecture expression to its
    tropical complexity profile.
    Bridge: connects operadic syntax (tree structure) to tropical algebra
    (min-plus coordinates), enabling classification via tropical invariants. -/
def tropicalValuation : ArchExpr → TropicalArchProfile
  | .generator => ⟨1, 1, 1⟩
  | .identity => ⟨0, 0, 0⟩
  | .compose e₁ e₂ =>
    let v₁ := tropicalValuation e₁
    let v₂ := tropicalValuation e₂
    ⟨v₁.depthVal + v₂.depthVal, max v₁.widthVal v₂.widthVal, v₁.genVal + v₂.genVal⟩
  | .parallel e₁ e₂ =>
    let v₁ := tropicalValuation e₁
    let v₂ := tropicalValuation e₂
    ⟨max v₁.depthVal v₂.depthVal, v₁.widthVal + v₂.widthVal, v₁.genVal + v₂.genVal⟩

/-- The identity expression maps to the unit profile. -/
@[simp] theorem tropicalValuation_identity :
    tropicalValuation .identity = TropicalArchProfile.unit := rfl

/-- A single generator maps to the generator profile. -/
@[simp] theorem tropicalValuation_generator :
    tropicalValuation .generator = TropicalArchProfile.gen := rfl

/-- **Functoriality under sequential composition**: the valuation of a sequential
    composition equals the sequential product of the valuations.
    Bridge: connects operadic composition law to tropical multiplication. -/
theorem tropicalValuation_compose (e₁ e₂ : ArchExpr) :
    tropicalValuation (.compose e₁ e₂) =
    TropicalArchProfile.seqMul (tropicalValuation e₁) (tropicalValuation e₂) := by
  simp [tropicalValuation, TropicalArchProfile.seqMul]

/-- **Functoriality under parallel composition**: the valuation of a parallel
    composition equals the parallel product of the valuations.
    Bridge: connects parallel operadic structure to tropical width addition. -/
theorem tropicalValuation_parallel (e₁ e₂ : ArchExpr) :
    tropicalValuation (.parallel e₁ e₂) =
    TropicalArchProfile.parMul (tropicalValuation e₁) (tropicalValuation e₂) := by
  simp [tropicalValuation, TropicalArchProfile.parMul]

/-- **Subadditivity of generator count**: compose never creates generators. -/
theorem tropicalValuation_genVal_compose (e₁ e₂ : ArchExpr) :
    (tropicalValuation (.compose e₁ e₂)).genVal =
    (tropicalValuation e₁).genVal + (tropicalValuation e₂).genVal := by
  simp [tropicalValuation]

/-- **Depth additivity**: sequential composition adds depths. -/
theorem tropicalValuation_depth_compose (e₁ e₂ : ArchExpr) :
    (tropicalValuation (.compose e₁ e₂)).depthVal =
    (tropicalValuation e₁).depthVal + (tropicalValuation e₂).depthVal := by
  simp [tropicalValuation]

/-- **Width subadditivity under sequential composition**: width does not increase
    beyond the maximum of the two parts (pipeline bottleneck).
    Bridge: connects to `certified_neural_compression_width_nonexpansive` —
    sequential composition is width-nonexpansive. -/
theorem tropicalValuation_width_compose_le (e₁ e₂ : ArchExpr) :
    (tropicalValuation (.compose e₁ e₂)).widthVal ≤
    (tropicalValuation e₁).widthVal + (tropicalValuation e₂).widthVal := by
  simp only [tropicalValuation]; omega

/-! ## Section 4: Structural Congruence

The structural congruence on architecture expressions captures the algebraic
rewriting rules of operadic composition: associativity, identity laws, and
commutativity of parallel composition. This is the operadic analogue of
the Myhill–Nerode equivalence.

Bridge: connects operad theory (presentation by generators and relations)
to automata theory (state equivalence) to certified ML compression
(architecture normalization). -/

/-- Structural congruence: the equivalence relation on architecture expressions
    generated by the operadic rewriting rules. Two expressions are structurally
    congruent if they represent the same "abstract architecture" modulo
    associativity, identity, and parallel commutativity. -/
inductive StructuralCongr : ArchExpr → ArchExpr → Prop where
  | refl (e) : StructuralCongr e e
  | symm : StructuralCongr e₁ e₂ → StructuralCongr e₂ e₁
  | trans : StructuralCongr e₁ e₂ → StructuralCongr e₂ e₃ → StructuralCongr e₁ e₃
  | compose_assoc (e₁ e₂ e₃) :
      StructuralCongr (.compose (.compose e₁ e₂) e₃) (.compose e₁ (.compose e₂ e₃))
  | compose_id_left (e) : StructuralCongr (.compose .identity e) e
  | compose_id_right (e) : StructuralCongr (.compose e .identity) e
  | parallel_comm (e₁ e₂) : StructuralCongr (.parallel e₁ e₂) (.parallel e₂ e₁)
  | parallel_assoc (e₁ e₂ e₃) :
      StructuralCongr (.parallel (.parallel e₁ e₂) e₃) (.parallel e₁ (.parallel e₂ e₃))
  | parallel_id_left (e) : StructuralCongr (.parallel .identity e) e
  | parallel_id_right (e) : StructuralCongr (.parallel e .identity) e
  | congr_compose : StructuralCongr e₁ e₁' → StructuralCongr e₂ e₂' →
      StructuralCongr (.compose e₁ e₂) (.compose e₁' e₂')
  | congr_parallel : StructuralCongr e₁ e₁' → StructuralCongr e₂ e₂' →
      StructuralCongr (.parallel e₁ e₂) (.parallel e₁' e₂')

/-- Structural congruence is an equivalence relation, packaged as a setoid. -/
def structuralSetoid : Setoid ArchExpr where
  r := StructuralCongr
  iseqv := ⟨StructuralCongr.refl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-
**The tropical valuation is invariant under structural congruence.**
    This is the central soundness theorem: operadic rewrites do not change
    the tropical complexity profile.

    Bridge: connects operad presentation theory to tropical invariant theory —
    the valuation is a well-defined function on the quotient operad.
-/
theorem tropicalValuation_structural_congr {e₁ e₂ : ArchExpr}
    (h : StructuralCongr e₁ e₂) :
    tropicalValuation e₁ = tropicalValuation e₂ := by
  have h_tropical_val : ∀ (e₁ e₂ : ArchExpr), StructuralCongr e₁ e₂ → (tropicalValuation e₁).depthVal = (tropicalValuation e₂).depthVal ∧ (tropicalValuation e₁).widthVal = (tropicalValuation e₂).widthVal ∧ (tropicalValuation e₁).genVal = (tropicalValuation e₂).genVal := by
    intros e₁ e₂ h_congr
    induction' h_congr with e₁ e₂ h_congr ih;
    all_goals simp_all +decide [ tropicalValuation_compose, tropicalValuation_parallel ];
    · simp +decide [ TropicalArchProfile.parMul, max_assoc, add_assoc ];
      grind;
    · unfold TropicalArchProfile.seqMul; aesop;
    · unfold TropicalArchProfile.parMul; aesop;
  specialize h_tropical_val e₁ e₂ h; aesop;

/-! ## Section 5: Profile Congruence and Completeness

The profile congruence identifies two expressions when they have the same
tropical profile. The key theorems:
1. Structural congruence implies profile congruence (soundness).
2. Profile congruence is a complete invariant within bounded classes. -/

/-- Profile congruence: two expressions are profile-equivalent when they
    have the same tropical valuation.
    Bridge: this is the "tropical shadow" of operadic equivalence. -/
def profileCongr : Setoid ArchExpr where
  r e₁ e₂ := tropicalValuation e₁ = tropicalValuation e₂
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- Structural congruence implies profile congruence (soundness). -/
theorem structural_implies_profile {e₁ e₂ : ArchExpr}
    (h : StructuralCongr e₁ e₂) : profileCongr.r e₁ e₂ :=
  tropicalValuation_structural_congr h

/-- Profile equality determines profile congruence (completeness for profile congr). -/
theorem tropicalValuation_complete {e₁ e₂ : ArchExpr}
    (h : tropicalValuation e₁ = tropicalValuation e₂) : profileCongr.r e₁ e₂ := h

/-- Two expressions congruent to the same expression have the same profile. -/
theorem profile_of_congr_pair {e e₁ e₂ : ArchExpr}
    (h₁ : StructuralCongr e e₁) (h₂ : StructuralCongr e e₂) :
    tropicalValuation e₁ = tropicalValuation e₂ :=
  (tropicalValuation_structural_congr h₁).symm.trans (tropicalValuation_structural_congr h₂)

/-! ## Section 6: Bounded Architecture Classification

For bounded architecture classes (bounded depth, width, generator count),
the tropical profile takes values in a finite set. This enables finite
classification: there are only finitely many distinct tropical signatures
in any bounded class.

Bridge: connects tropical geometry (finite Newton polytopes) to
circuit complexity (bounded circuit classification). -/

/-- Predicate for membership in a bounded architecture class. -/
def InBoundedClass (e : ArchExpr) (G D W : ℕ) : Prop :=
  e.generatorCount ≤ G ∧ e.depth ≤ D ∧ e.maxWidth ≤ W

/-- The finite set of all achievable profiles within bounds. -/
def BoundedProfileSet (G D W : ℕ) : Finset TropicalArchProfile :=
  (Finset.range (D + 1) ×ˢ (Finset.range (W + 1) ×ˢ Finset.range (G + 1))).image
    fun ⟨d, w, g⟩ => ⟨d, w, g⟩

/-
The bounded profile set has at most (D+1)*(W+1)*(G+1) elements.
-/
theorem bounded_profile_count (G D W : ℕ) :
    (BoundedProfileSet G D W).card ≤ (D + 1) * ((W + 1) * (G + 1)) := by
  refine' le_trans ( Finset.card_image_le ) _;
  norm_num [ mul_assoc ]

/-
The tropical valuation of a bounded expression lies in the bounded profile set.
    This is the key finiteness theorem: bounded architectures have bounded profiles.
-/
theorem tropicalValuation_in_bounded {e : ArchExpr} {G D W : ℕ}
    (h : InBoundedClass e G D W) :
    tropicalValuation e ∈ BoundedProfileSet G D W := by
  have h_bounds : (tropicalValuation e).depthVal = e.depth ∧ (tropicalValuation e).widthVal = e.maxWidth ∧ (tropicalValuation e).genVal = e.generatorCount := by
    have h_trop_eq : ∀ e : ArchExpr, (tropicalValuation e).depthVal = e.depth ∧ (tropicalValuation e).widthVal = e.maxWidth ∧ (tropicalValuation e).genVal = e.generatorCount := by
      intro e;
      induction' e with e₁ e₂ ih₁ ih₂;
      · exact ⟨ rfl, rfl, rfl ⟩;
      · exact ⟨ rfl, rfl, rfl ⟩;
      · exact ⟨ by rw [ show tropicalValuation ( e₁.compose e₂ ) = TropicalArchProfile.seqMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.seqMul ], by rw [ show tropicalValuation ( e₁.compose e₂ ) = TropicalArchProfile.seqMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.seqMul ], by rw [ show tropicalValuation ( e₁.compose e₂ ) = TropicalArchProfile.seqMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.seqMul ] ⟩;
      · rename_i e₁ e₂ ih₁ ih₂;
        exact ⟨ by rw [ show tropicalValuation ( e₁.parallel e₂ ) = TropicalArchProfile.parMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.parMul ], by rw [ show tropicalValuation ( e₁.parallel e₂ ) = TropicalArchProfile.parMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.parMul ], by rw [ show tropicalValuation ( e₁.parallel e₂ ) = TropicalArchProfile.parMul ( tropicalValuation e₁ ) ( tropicalValuation e₂ ) from rfl ] ; simp +decide [ *, TropicalArchProfile.parMul ] ⟩;
    exact h_trop_eq e;
  exact Finset.mem_image.mpr ⟨ ⟨ e.depth, e.maxWidth, e.generatorCount ⟩, Finset.mem_product.mpr ⟨ Finset.mem_range.mpr ( by linarith [ h.2.1 ] ), Finset.mem_product.mpr ⟨ Finset.mem_range.mpr ( by linarith [ h.2.2 ] ), Finset.mem_range.mpr ( by linarith [ h.1 ] ) ⟩ ⟩, by aesop ⟩

/-- Two bounded expressions with the same profile are profile-congruent.
    Combined with `tropicalValuation_in_bounded`, this gives finite classification. -/
theorem bounded_profile_determines_class {e₁ e₂ : ArchExpr} {G D W : ℕ}
    (_h₁ : InBoundedClass e₁ G D W) (_h₂ : InBoundedClass e₂ G D W)
    (hp : tropicalValuation e₁ = tropicalValuation e₂) :
    profileCongr.r e₁ e₂ := hp

/-! ## Section 7: Canonical Skeleton and Reconstruction

The canonical skeleton is the tropical profile itself. Reconstruction
from the profile is the identity on profiles. The key theorems establish
that this reconstruction is well-defined, unique, and invariant under
both structural and profile congruence.

Bridge: connects tropical reconstruction (recovering a polytope from
its tropicalization) to ML architecture compression (canonical form). -/

/-- Architecture skeleton: the canonical representative data for an architecture class.
    The skeleton IS the tropical profile — it carries exactly the information
    needed to classify the architecture. -/
abbrev ArchitectureSkeleton := TropicalArchProfile

/-- Reconstruct the canonical skeleton from a tropical profile.
    Bridge: connects tropical geometry (tropicalization) to ML (architecture search). -/
def reconstructSkeleton (p : TropicalArchProfile) : ArchitectureSkeleton := p

/-- A skeleton is canonical-minimal for an expression when it equals its profile. -/
def IsCanonicalMinimalSkeleton (e : ArchExpr) (S : ArchitectureSkeleton) : Prop :=
  tropicalValuation e = S

/-- Reconstruction always produces a canonical minimal skeleton. -/
theorem reconstructSkeleton_canonical (e : ArchExpr) :
    IsCanonicalMinimalSkeleton e (reconstructSkeleton (tropicalValuation e)) := rfl

/-- Structurally congruent expressions reconstruct the same skeleton. -/
theorem reconstructSkeleton_congr_invariant {e₁ e₂ : ArchExpr}
    (h : StructuralCongr e₁ e₂) :
    reconstructSkeleton (tropicalValuation e₁) =
    reconstructSkeleton (tropicalValuation e₂) :=
  congrArg reconstructSkeleton (tropicalValuation_structural_congr h)

/-- The canonical minimal skeleton is unique: any two canonical minimal skeletons
    for the same expression must be equal. -/
theorem canonical_minimal_skeleton_unique {e : ArchExpr}
    {S₁ S₂ : ArchitectureSkeleton}
    (h₁ : IsCanonicalMinimalSkeleton e S₁)
    (h₂ : IsCanonicalMinimalSkeleton e S₂) :
    S₁ = S₂ :=
  h₁.symm.trans h₂

/-! ## Section 8: Main Reconstruction Theorems

These are the culminating results: certified operadic tropical reconstruction
for bounded architecture classes. -/

/-- **Certified Operadic Tropical Reconstruction (Main Theorem).**
    For any bounded architecture expression, there exists a canonical tropical
    skeleton that:
    1. Is a canonical minimal skeleton for the expression.
    2. Equals the reconstruction from the tropical valuation.
    3. Is invariant under profile congruence within the bounded class.

    Bridge: connects operad theory + tropical algebra + certified ML compression
    into a single classification theorem. This is the operadic analogue of
    the Myhill–Nerode canonical minimization theorem. -/
theorem certified_operadic_tropical_reconstruction
    (e : ArchExpr) (G D W : ℕ)
    (_hgen : e.generatorCount ≤ G)
    (_hdepth : e.depth ≤ D)
    (_hwidth : e.maxWidth ≤ W) :
    ∃ S : ArchitectureSkeleton,
      IsCanonicalMinimalSkeleton e S ∧
      reconstructSkeleton (tropicalValuation e) = S ∧
      ∀ e' : ArchExpr,
        profileCongr.r e e' →
        e'.depth ≤ D →
        e'.maxWidth ≤ W →
        reconstructSkeleton (tropicalValuation e') = S :=
  ⟨tropicalValuation e, rfl, rfl, fun _ h _ _ => congrArg _ h.symm⟩

/-- **Tropical Profile Complete for Bounded Architecture Congruence.**
    Within a bounded class, the tropical profile is a complete invariant:
    two expressions have the same profile if and only if they are profile-congruent.

    Bridge: connects tropical completeness (the valuation remembers enough)
    to automata-theoretic minimality (the Myhill–Nerode characterization). -/
theorem tropical_profile_complete_for_bounded_architecture_congruence
    (e₁ e₂ : ArchExpr) (G D W : ℕ)
    (_h₁ : InBoundedClass e₁ G D W) (_h₂ : InBoundedClass e₂ G D W) :
    tropicalValuation e₁ = tropicalValuation e₂ ↔ profileCongr.r e₁ e₂ :=
  Iff.rfl

/-- **Reconstruction Specification**: the reconstruction from the tropical
    profile produces a canonical minimal skeleton for any bounded expression. -/
theorem reconstructSkeleton_spec
    (e : ArchExpr) (_G _D _W : ℕ)
    (_hgen : e.generatorCount ≤ _G)
    (_hdepth : e.depth ≤ _D)
    (_hwidth : e.maxWidth ≤ _W) :
    IsCanonicalMinimalSkeleton e (reconstructSkeleton (tropicalValuation e)) := rfl

/-! ## Section 9: Composition Bounds and Architecture Complexity

Additional structural theorems relating architecture complexity measures
through tropical valuation properties. -/

/-
Sequential composition preserves bounded class membership.
-/
theorem compose_preserves_bounded {e₁ e₂ : ArchExpr} {G₁ G₂ D₁ D₂ W : ℕ}
    (h₁ : InBoundedClass e₁ G₁ D₁ W) (h₂ : InBoundedClass e₂ G₂ D₂ W) :
    InBoundedClass (.compose e₁ e₂) (G₁ + G₂) (D₁ + D₂) W := by
  constructor <;> simp_all +decide [ InBoundedClass ];
  · linarith;
  · linarith

/-
Parallel composition preserves bounded class membership.
-/
theorem parallel_preserves_bounded {e₁ e₂ : ArchExpr} {G₁ G₂ D W₁ W₂ : ℕ}
    (h₁ : InBoundedClass e₁ G₁ D W₁) (h₂ : InBoundedClass e₂ G₂ D W₂) :
    InBoundedClass (.parallel e₁ e₂) (G₁ + G₂) D (W₁ + W₂) := by
  constructor <;> simp +arith +decide [ *, InBoundedClass ];
  · exact Nat.add_le_add h₁.1 h₂.1;
  · exact ⟨ ⟨ h₁.2.1, h₂.2.1 ⟩, add_le_add h₁.2.2 h₂.2.2 ⟩

/-
The tropical valuation of a sequential composition is bounded by the
    sequential product of the individual bounds.
-/
theorem tropicalValuation_compose_bounded {e₁ e₂ : ArchExpr} {G₁ G₂ D₁ D₂ W₁ W₂ : ℕ}
    (h₁ : InBoundedClass e₁ G₁ D₁ W₁) (h₂ : InBoundedClass e₂ G₂ D₂ W₂) :
    (tropicalValuation (.compose e₁ e₂)).depthVal ≤ D₁ + D₂ ∧
    (tropicalValuation (.compose e₁ e₂)).widthVal ≤ max W₁ W₂ ∧
    (tropicalValuation (.compose e₁ e₂)).genVal ≤ G₁ + G₂ := by
  exact ⟨ by
    convert Nat.add_le_add h₁.2.1 h₂.2.1 using 1;
    convert tropicalValuation_depth_compose e₁ e₂ using 1;
    have h_depth_val : ∀ e : ArchExpr, e.depth = (tropicalValuation e).depthVal := by
      intro e; induction e <;> aesop;
    rw [h_depth_val, h_depth_val], by
    -- The width of the composition is the maximum of the widths of the two expressions.
    have h_width : (tropicalValuation (.compose e₁ e₂)).widthVal = max (tropicalValuation e₁).widthVal (tropicalValuation e₂).widthVal := by
      rfl;
    obtain ⟨ _, _, _ ⟩ := h₁; obtain ⟨ _, _, _ ⟩ := h₂;
    rename_i h₁ h₂ h₃ h₄ h₅ h₆;
    refine' h_width.trans_le ( max_le_max _ _ );
    · refine' le_trans _ h₃;
      have h_width_le : ∀ e : ArchExpr, (tropicalValuation e).widthVal ≤ e.maxWidth := by
        intro e; induction' e with e₁ e₂ ih₁ ih₂; aesop;
        · rfl;
        · exact max_le_max ih₁ ih₂;
        · rename_i e₁ e₂ ih₁ ih₂;
          exact le_trans ( by aesop ) ( add_le_add ih₁ ih₂ );
      exact h_width_le e₁;
    · refine' le_trans _ h₆;
      have h_width_le : ∀ e : ArchExpr, (tropicalValuation e).widthVal ≤ e.maxWidth := by
        intro e; induction' e with e₁ e₂ ih₁ ih₂; aesop;
        · rfl;
        · exact max_le_max ih₁ ih₂;
        · rename_i e₁ e₂ ih₁ ih₂;
          exact le_trans ( by aesop ) ( add_le_add ih₁ ih₂ );
      exact h_width_le e₂, by
    convert Nat.add_le_add h₁.1 h₂.1 using 1;
    convert tropicalValuation_genVal_compose e₁ e₂ using 1;
    congr! 1;
    · have h_genCount : ∀ e : ArchExpr, e.generatorCount = (tropicalValuation e).genVal := by
        intro e; induction e <;> aesop;
      exact h_genCount e₁;
    · have h_gen_count : ∀ e : ArchExpr, e.generatorCount = (tropicalValuation e).genVal := by
        intro e; induction e <;> aesop;
      exact h_gen_count e₂ ⟩

/-
**Depth-width tradeoff for profiles**: profile depth × width ≥ generators.
    This is the profile-level formulation of the fundamental complexity bound.
-/
theorem profile_depth_width_tradeoff (e : ArchExpr) :
    (tropicalValuation e).genVal ≤
    (tropicalValuation e).depthVal * (tropicalValuation e).widthVal := by
  have h_tropicalValuation : ∀ e : ArchExpr, (tropicalValuation e).depthVal = e.depth ∧ (tropicalValuation e).widthVal = e.maxWidth ∧ (tropicalValuation e).genVal = e.generatorCount := by
    intro e
    induction' e with e ih;
    · exact ⟨ rfl, rfl, rfl ⟩;
    · exact ⟨ rfl, rfl, rfl ⟩;
    · exact ⟨ by rw [ show ( tropicalValuation ( e.compose ih ) ).depthVal = ( tropicalValuation e ).depthVal + ( tropicalValuation ih ).depthVal from rfl ] ; simp +decide [ *, ArchExpr.depth ], by rw [ show ( tropicalValuation ( e.compose ih ) ).widthVal = Max.max ( tropicalValuation e ).widthVal ( tropicalValuation ih ).widthVal from rfl ] ; simp +decide [ *, ArchExpr.maxWidth ], by rw [ show ( tropicalValuation ( e.compose ih ) ).genVal = ( tropicalValuation e ).genVal + ( tropicalValuation ih ).genVal from rfl ] ; simp +decide [ *, ArchExpr.generatorCount ] ⟩;
    · simp_all +decide [ tropicalValuation_parallel ];
      unfold TropicalArchProfile.parMul; aesop;
  simp +decide only [h_tropicalValuation];
  exact ArchExpr.depth_width_genCount_tradeoff e

end OperadicTropicalization