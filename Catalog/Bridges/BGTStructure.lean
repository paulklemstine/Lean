/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Breuillard–Green–Tao Structure Theorem: The K ≈ 1 Regime

This file establishes the first formal inverse theorems for product growth
in finite groups, specializing to the model case of `SL(2, 𝔽_p)`. The central
results prove that exact tripling rigidity (`|A³| = |A|`) forces subgroup
structure, and that small tripling under a strict-growth gap hypothesis forces
the set to be the entire group.

## Mathematical Context

The Breuillard–Green–Tao (BGT) structure theorem classifies approximate subgroups
of arbitrary groups. In the `K = 1` regime, the theorem becomes exact: a symmetric
set containing the identity with no tripling growth must be a subgroup. This file
formalizes this exact regime and the perturbative regime `K < 1 + δ` under a
strict-growth axiom.

## Main Definitions

* `ApproxSubgroupData` — structure encoding a symmetric set with identity
* `IsKApproxTripling` — predicate for K-approximate tripling
* `traceSet` — trace set of a subset of SL(2, 𝔽_p)

## Main Results

* `mul_self_eq_of_card_triple_eq` — |A³| = |A| implies A·A = A
* `subgroup_of_card_triple_eq_card` — exact tripling implies subgroup structure
* `eq_univ_of_card_triple_eq_card` — exact tripling + generation implies A = G
* `eq_univ_of_small_tripling_lt_gap` — small tripling under gap implies A = G
* `SL2_exact_tripling_generating_eq_univ` — SL₂ specialization

## Proof Architecture

The proofs follow **Strategy A** (cardinal rigidity → closure → subgroup):

1. From `1 ∈ A`, derive `A ⊆ A² ⊆ A³` (monotonicity of product towers).
2. From `|A³| = |A|` and step 1, deduce `A = A² = A³` by cardinality squeezing.
3. From `A² = A`, deduce multiplicative closure.
4. From closure + symmetry + identity, construct the subgroup.

**Strategy B** (strict growth contradiction) is used for the gap theorem:
the gap hypothesis directly contradicts small tripling for generating sets.

## References

* Breuillard, Green, Tao (2012). The structure of approximate groups.
* Helfgott (2008). Growth and generation in SL₂(ℤ/pℤ).
* Tao (2015). Expansion in finite simple groups of Lie type.
-/

import Mathlib

open Finset Subgroup Pointwise

/-! ## Definitions -/

/-- An **approximate subgroup datum** packages a symmetric subset of a group
containing the identity. This is the basic combinatorial object studied in
approximate group theory: the carrier of an approximate subgroup. -/
structure ApproxSubgroupData (G : Type*) [Group G] where
  /-- The underlying finite set -/
  carrier : Finset G
  /-- The identity belongs to the carrier -/
  one_mem : (1 : G) ∈ carrier
  /-- The carrier is closed under inversion -/
  symm_mem : ∀ {g : G}, g ∈ carrier → g⁻¹ ∈ carrier
  /-- The carrier is nonempty (follows from one_mem) -/
  nonempty : carrier.Nonempty := ⟨1, one_mem⟩

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- A set `A` has **K-approximate tripling** if `|A·A·A| ≤ K · |A|`. -/
def IsKApproxTripling (A : Finset G) (K : ℕ) : Prop :=
  (A * A * A).card ≤ K * A.card

/-- The **trace set** of a subset of `SL(2, 𝔽_p)`: the set of traces
`tr(g)` for `g ∈ A`. This bridges multiplicative structure in SL₂
to additive/multiplicative structure in the base field. -/
noncomputable def traceSet {p : ℕ} (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p))) :
    Finset (ZMod p) :=
  A.image fun g => Matrix.trace (g.1 : Matrix (Fin 2) (Fin 2) (ZMod p))

/-! ## Core Containment Lemmas -/

omit [Fintype G] in
/-- When `1 ∈ A`, we have `A ⊆ A * A` via the map `a ↦ a · 1`. -/
theorem BGT_subset_mul_sq (A : Finset G) (h1 : (1 : G) ∈ A) :
    A ⊆ A * A := by
  intro x hx
  rw [mem_mul]
  exact ⟨x, hx, 1, h1, mul_one x⟩

omit [Fintype G] in
/-- When `1 ∈ A`, we have `A * A ⊆ A * A * A` via right-multiplication by 1. -/
theorem BGT_mul_sq_subset_triple (A : Finset G) (h1 : (1 : G) ∈ A) :
    A * A ⊆ A * A * A := by
  intro x hx
  rw [mem_mul]
  exact ⟨x, hx, 1, h1, mul_one x⟩

omit [Fintype G] in
/-- Cardinal monotonicity: `|A| ≤ |A * A|` when `1 ∈ A`. -/
theorem BGT_card_le_card_mul_self (A : Finset G) (h1 : (1 : G) ∈ A) :
    A.card ≤ (A * A).card :=
  Finset.card_le_card (BGT_subset_mul_sq A h1)

omit [Fintype G] in
/-- Cardinal monotonicity: `|A * A| ≤ |A * A * A|` when `1 ∈ A`. -/
theorem BGT_card_mul_self_le_card_triple (A : Finset G) (h1 : (1 : G) ∈ A) :
    (A * A).card ≤ (A * A * A).card :=
  Finset.card_le_card (BGT_mul_sq_subset_triple A h1)

/-! ## The Rigidity Engine: Exact Tripling Forces Closure -/

/-
**Key rigidity lemma.** If `|A³| = |A|` and `1 ∈ A`, then `A * A = A`.
This is the engine of the exact inverse theorem: equal cardinality plus
containment forces equality at every level of the product tower.

*Proof.* From `1 ∈ A` we get `A ⊆ A² ⊆ A³`. Since `|A³| = |A|` and
`|A| ≤ |A²| ≤ |A³|`, all cardinalities are equal. Then `A ⊆ A²` with
`|A²| = |A|` forces `A = A²` by the finite pigeonhole principle.
-/
omit [Fintype G] in
theorem mul_self_eq_of_card_triple_eq
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (htriple : (A * A * A).card = A.card) :
    A * A = A := by
  refine' Finset.eq_of_subset_of_card_le _ _;
  · -- Since $|A * A| \leq |A * A * A| = |A|$, we have $A * A \subseteq A$ by the pigeonhole principle.
    have h_card_le : (A * A).card ≤ A.card := by
      exact htriple ▸ Finset.card_le_card ( BGT_mul_sq_subset_triple A h1 );
    exact Finset.eq_of_subset_of_card_le ( BGT_subset_mul_sq A h1 ) h_card_le ▸ Finset.Subset.refl _;
  · apply BGT_card_le_card_mul_self A h1

omit [Fintype G] in
/-
If `A * A = A`, then `A` is closed under multiplication.
-/
theorem mulClosed_of_mul_self_eq
    (A : Finset G) (h : A * A = A) :
    ∀ a b : G, a ∈ A → b ∈ A → a * b ∈ A := by
  exact fun a b ha hb => h ▸ Finset.mul_mem_mul ha hb

/-! ## Main Structure Theorems -/

/-
**Theorem 2: Exact tripling implies subgroup.**
If `A` is a finite symmetric subset containing `1` with `|A³| = |A|`,
then `A` is the carrier of a subgroup of `G`.

This is the exact inverse theorem at `K = 1`: the only symmetric sets
with no tripling growth are subgroups. The proof uses Strategy A:
cardinal rigidity forces `A = A²`, which gives multiplicative closure;
combined with symmetry and identity, this characterizes subgroups.
-/
omit [Fintype G] in
theorem subgroup_of_card_triple_eq_card
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ {g : G}, g ∈ A → g⁻¹ ∈ A)
    (htriple : (A * A * A).card = A.card) :
    ∃ H : Subgroup G, (A : Set G) = ↑H := by
  use { carrier := A, mul_mem' := by
          convert mulClosed_of_mul_self_eq A ( mul_self_eq_of_card_triple_eq A h1 htriple ), one_mem' := by
          exact h1, inv_mem' := by
          aesop };
  rfl

/-
**Theorem 1: Exact tripling rigidity.**
If `A` is symmetric, contains `1`, generates `G`, and `|A³| = |A|`,
then `A` must be the entire group.

Combined with `subgroup_of_card_triple_eq_card`, this shows that the only
symmetric generating set with exact tripling in a finite group is `G` itself.
-/
theorem eq_univ_of_card_triple_eq_card
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ {g : G}, g ∈ A → g⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (htriple : (A * A * A).card = A.card) :
    A = Finset.univ := by
  -- From Theorem 1, we know that $A$ is a subgroup of $G$.
  obtain ⟨H, hH⟩ : ∃ H : Subgroup G, (A : Set G) = ↑H := by
    convert subgroup_of_card_triple_eq_card A h1 hsym htriple;
  aesop

/-
**Theorem 3: Near-rigidity under strict growth gap.**
If `G` satisfies a strict growth theorem with gap `δ > 0` — every symmetric
generating set that isn't all of `G` has `|A³| ≥ (1+δ)|A|` — then any
symmetric generating set with `|A³| < (1+δ)|A|` must be the entire group.

This is the formal nucleus of the perturbative BGT theorem: small tripling
plus generation forces saturation when a gap theorem is available.
-/
theorem eq_univ_of_small_tripling_lt_gap
    (δ : ℚ)
    (_hδ : 0 < δ)
    (hgap :
      ∀ (B : Finset G),
        (1 : G) ∈ B →
        (∀ {g : G}, g ∈ B → g⁻¹ ∈ B) →
        Subgroup.closure (↑B : Set G) = ⊤ →
        B ≠ Finset.univ →
        ((B * B * B).card : ℚ) ≥ (1 + δ) * B.card)
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ {g : G}, g ∈ A → g⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (hsmall : ((A * A * A).card : ℚ) < (1 + δ) * A.card) :
    A = Finset.univ := by
  exact Classical.not_not.1 fun h => hsmall.not_ge <| hgap A h1 hsym hgen h

/-! ## SL₂(𝔽_p) Specialization -/

instance SL2_DecidableEq (p : ℕ) [Fact p.Prime] :
    DecidableEq (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)) :=
  Subtype.instDecidableEq

instance SL2_Fintype (p : ℕ) [Fact p.Prime] :
    Fintype (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)) :=
  Subtype.fintype _

/-
**Theorem 4: SL₂ exact tripling rigidity.**
For prime `p`, any symmetric subset of `SL(2, 𝔽_p)` containing the identity
that generates `SL(2, 𝔽_p)` and has exact tripling must be all of `SL(2, 𝔽_p)`.

This specializes the abstract rigidity theorem to the model case of
noncommutative growth theory.
-/
theorem SL2_exact_tripling_generating_eq_univ
    (p : ℕ) [hp : Fact p.Prime]
    (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)))
    (h1 : (1 : Matrix.SpecialLinearGroup (Fin 2) (ZMod p)) ∈ A)
    (hsym : ∀ {g : Matrix.SpecialLinearGroup (Fin 2) (ZMod p)}, g ∈ A → g⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set (Matrix.SpecialLinearGroup (Fin 2) (ZMod p))) = ⊤)
    (htriple : (A * A * A).card = A.card) :
    A = Finset.univ := by
  -- Since $A$ is symmetric and contains $1$, we have $A \subseteq A * A$.
  apply eq_univ_of_card_triple_eq_card A h1 hsym hgen htriple

/-! ## Cross-Domain Bridge: Subgroup Closure from Exact Tripling -/

/-
**Cayley graph reachability from exact tripling.**
If `A` is symmetric with `1 ∈ A` and `|A³| = |A|`, then the subgroup
generated by `A` equals `A` (as sets). This means the connected component
of `1` in the Cayley graph with generators `A` is exactly the subgroup
corresponding to `A`.

This bridges product growth to graph connectivity: exact tripling means
the Cayley ball of radius 1 already exhausts its connected component.
-/
omit [Fintype G] in
theorem closure_eq_coe_of_card_triple_eq
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ {g : G}, g ∈ A → g⁻¹ ∈ A)
    (htriple : (A * A * A).card = A.card) :
    (Subgroup.closure (↑A : Set G) : Set G) = ↑A := by
  -- From subgroup_of_card_triple_eq_card, get H with (A : Set G) = ↑H.
  obtain ⟨H, hH⟩ : ∃ H : Subgroup G, (A : Set G) = ↑H := by
    -- Apply the theorem that states if A has exact tripling, then A is the carrier of a subgroup.
    apply subgroup_of_card_triple_eq_card A h1 hsym htriple;
  simp +decide [hH]

/-
**Product stabilization chain.**
If `|A³| = |A|` and `1 ∈ A`, then the entire product tower collapses:
`A = A² = A³ = A⁴ = ...`. This is the noncommutative analogue of the
abelian fact that `|A+A+A| = |A|` forces `kA = A` for all `k`.
-/
omit [Fintype G] in
theorem pow_eq_of_card_triple_eq
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (htriple : (A * A * A).card = A.card)
    (k : ℕ) (hk : 1 ≤ k) :
    A ^ k = A := by
  induction hk <;> simp_all +decide [pow_succ']
  exact mul_self_eq_of_card_triple_eq A h1 htriple

/-! ## Approximate Subgroup Analysis -/

/-- An **approximate subgroup report** summarizes the structural analysis
of a finite subset: whether it is a subgroup, its tripling ratio, and
the controlling subgroup if one exists. -/
structure ApproxSubgroupReport (G : Type*) [Group G] where
  /-- The original set -/
  carrier : Finset G
  /-- Cardinality of A -/
  cardA : ℕ
  /-- Cardinality of A² -/
  cardAA : ℕ
  /-- Cardinality of A³ -/
  cardAAA : ℕ
  /-- Whether 1 ∈ A -/
  hasOne : Bool
  /-- Whether A is symmetric -/
  isSymmetric : Bool
  /-- Whether A is multiplication-closed -/
  isMulClosed : Bool
  /-- Whether A is a subgroup carrier -/
  isSubgroup : Bool

/-- Compute the approximate subgroup report for a finite subset. -/
def analyzeApproxSubgroup (A : Finset G) : ApproxSubgroupReport G where
  carrier := A
  cardA := A.card
  cardAA := (A * A).card
  cardAAA := (A * A * A).card
  hasOne := decide ((1 : G) ∈ A)
  isSymmetric := decide (∀ g ∈ A, g⁻¹ ∈ A)
  isMulClosed := decide (∀ a ∈ A, ∀ b ∈ A, a * b ∈ A)
  isSubgroup := decide ((1 : G) ∈ A) &&
    decide (∀ g ∈ A, g⁻¹ ∈ A) &&
    decide (∀ a ∈ A, ∀ b ∈ A, a * b ∈ A)

/-
The analyzer correctly reports subgroup status when exact tripling holds.
-/
theorem analyzeApproxSubgroup_isSubgroup_of_exact_tripling
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ {g : G}, g ∈ A → g⁻¹ ∈ A)
    (htriple : (A * A * A).card = A.card) :
    (analyzeApproxSubgroup A).isSubgroup = true := by
  convert mulClosed_of_mul_self_eq A ( mul_self_eq_of_card_triple_eq A h1 htriple );
  constructor <;> intro h <;> simp_all +decide [ analyzeApproxSubgroup ]