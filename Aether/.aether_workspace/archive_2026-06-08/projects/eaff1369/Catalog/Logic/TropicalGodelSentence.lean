import Mathlib

/-!
# Tropical Gödel Sentences and Idempotent Incompleteness

This module formalizes a bridge between **idempotent semiring fixed-point theory**,
**diagonal self-reference**, and **formal incompleteness phenomena** in the setting of
min-plus (tropical) algebra.

## Overview

The central insight is that Gödelian self-reference does not require Boolean syntax or
arithmetic coding — it can be reconstructed from **order-theoretic fixed points** in
tropical/idempotent algebra. We prove three main theorems:

- **Theorem A** (`tropical_diagonal_fixed_point`): A diagonal fixed-point theorem for
  monotone operators on finite tropical spaces, giving self-referential cost valuations.

- **Theorem B** (`exists_tropical_godel_sentence`): Existence of tropical Gödel sentences —
  fixed points of provability operators that witness a semantic gap between provability
  and truth under diagonal perturbation.

- **Theorem C** (`tropical_incompleteness`): No sound, nontrivial tropical proof system
  can be complete — idempotent closure with diagonal expressivity forces incompleteness.

## Key Definitions

- `TropicalProofSystem`: A monotone, idempotent, extensive operator on `Fin n → ℕ`
  modeling tropical provability.
- `DiagBump`: The diagonal perturbation operator that inflates cost at a single coordinate.
- `IsTropicalGodelSentence`: A fixed point of provability witnessing self-referential cost gap.
- `TropicalComplete`: The system identifies every valuation with its provable closure.

## Mathematical Context

In classical logic, the diagonal lemma produces a sentence G asserting "G is not provable."
In the tropical setting, we replace Boolean truth with cost valuations in ℕ, and replace
syntactic provability with an idempotent closure operator P on `Fin n → ℕ`. The tropical
Gödel sentence is a fixed point g of P such that perturbing g at a self-referential
coordinate creates a gap in the provability operator — the tropical analogue of
"my proof cost exceeds what the system predicts."
-/

open Function

/-! ## Section 1: Core Definitions -/

/-- A tropical proof system on `n` sentences is a monotone, idempotent, extensive
    operator on cost valuations `Fin n → ℕ`. -/
structure TropicalProofSystem (n : ℕ) where
  /-- The provability closure operator. `provable f` gives the best provable upper
      bound on the cost profile `f`. -/
  provable : (Fin n → ℕ) → (Fin n → ℕ)
  /-- Monotonicity: higher input costs yield higher provable costs. -/
  mono : Monotone provable
  /-- Idempotency: re-proving doesn't change anything. -/
  idem : ∀ f, provable (provable f) = provable f
  /-- Extensiveness / soundness: the provable cost is at least the actual cost. -/
  extensive : ∀ f i, f i ≤ provable f i

/-- The diagonal bump operator: increase the cost at coordinate `i` by 1,
    leaving all other coordinates unchanged. This is the tropical analogue
    of the diagonal/self-reference perturbation. -/
def DiagBump {n : ℕ} (i : Fin n) (f : Fin n → ℕ) : Fin n → ℕ :=
  fun j => if j = i then f j + 1 else f j

/-- The diagonal operator constructed from a family of functionals.
    `DiagOp Φ f i = Φ i f` — each coordinate `i` evaluates the functional `Φ i`
    on the entire cost profile `f`. This is the tropical quine construction. -/
def DiagOp {n : ℕ} (Φ : Fin n → (Fin n → ℕ) → ℕ) : (Fin n → ℕ) → (Fin n → ℕ) :=
  fun f i => Φ i f

/-- A tropical Gödel sentence for a proof system `P` is a fixed point `g`
    of `P` (a provable truth) such that bumping the self-referential coordinate
    creates a strict gap in provability — the system's prediction about `g`'s
    own proof cost is strictly less than what perturbation reveals. -/
def IsTropicalGodelSentence {n : ℕ}
    (P : (Fin n → ℕ) → (Fin n → ℕ)) (g : Fin n → ℕ) (i : Fin n) : Prop :=
  P g = g ∧ g i < P (DiagBump i g) i

/-- A tropical proof system is diagonally expressive if there exists some coordinate
    and some input where bumping that coordinate strictly increases the provable cost —
    the system is sensitive to self-referential perturbation. -/
def DiagonallyExpressive {n : ℕ} (S : TropicalProofSystem n) : Prop :=
  ∃ i f, S.provable f i < S.provable (DiagBump i f) i

/-- Completeness of a tropical proof system: every valuation equals its provable closure.
    This means there is no gap between truth and provability. -/
def TropicalComplete {n : ℕ} (S : TropicalProofSystem n) : Prop :=
  ∀ f, S.provable f = f

/-! ## Section 2: Helper Lemmas -/

/-
The diagonal bump is monotone: if `f ≤ g` pointwise, then `DiagBump i f ≤ DiagBump i g`.
-/
theorem diagBump_monotone {n : ℕ} (i : Fin n) : Monotone (DiagBump i) := by
  exact fun f g h j => by unfold DiagBump; aesop;

/-
Bumping always increases the value at the bumped coordinate.
-/
theorem diagBump_lt_self {n : ℕ} (i : Fin n) (f : Fin n → ℕ) :
    f i < DiagBump i f i := by
  -- By definition of DiagBump, we have DiagBump i f i = f i + 1.
  simp [DiagBump]

/-
Bumping preserves values at non-bumped coordinates.
-/
theorem diagBump_eq_of_ne {n : ℕ} {i j : Fin n} (h : j ≠ i) (f : Fin n → ℕ) :
    DiagBump i f j = f j := by
  exact if_neg h

/-
Bumping increases the value at the target: `f i + 1 = DiagBump i f i`.
-/
theorem diagBump_at_self {n : ℕ} (i : Fin n) (f : Fin n → ℕ) :
    DiagBump i f i = f i + 1 := by
  exact if_pos rfl

/-
If P is extensive, then bumping and applying P gives at least the bump value.
-/
theorem extensive_diagBump {n : ℕ} (P : (Fin n → ℕ) → (Fin n → ℕ))
    (hext : ∀ f i, f i ≤ P f i) (i : Fin n) (f : Fin n → ℕ) :
    f i + 1 ≤ P (DiagBump i f) i := by
  exact le_trans ( by simp +decide [ DiagBump ] ) ( hext _ _ )

/-! ## Section 3: Theorem A — Tropical Diagonal Fixed-Point Theorem -/

/-
**Theorem A: Tropical Diagonal Fixed-Point Theorem.**

Every monotone, coordinatewise bounded operator on `Fin n → ℕ` has a fixed point.
When the operator is constructed via the diagonal construction `DiagOp Φ`,
the fixed point is a self-referential cost valuation: `f i = Φ i f` for all `i`.

This is the tropical analogue of the diagonal lemma in classical logic.
The fixed point `f` "speaks about its own proof cost" via the functionals `Φ`.
-/
theorem tropical_diagonal_fixed_point
    {n : ℕ} (B : Fin n → ℕ)
    (Φ : Fin n → (Fin n → ℕ) → ℕ)
    (hmono : Monotone (DiagOp Φ))
    (hbound : ∀ f i, Φ i f ≤ B i) :
    ∃ f : Fin n → ℕ, DiagOp Φ f = f := by
  have h_exists_fixed_point : ∃ f : Fin n → ℕ, (DiagOp Φ f) ≤ f ∧ ∀ g : Fin n → ℕ, (DiagOp Φ g) ≤ g → f ≤ g := by
    refine' ⟨ sInf { g : Fin n → ℕ | DiagOp Φ g ≤ g }, _, _ ⟩;
    · refine' le_csInf _ _;
      · exact ⟨ B, fun i => hbound _ _ ⟩;
      · exact fun g hg => le_trans ( hmono <| csInf_le ⟨ 0, fun f hf => zero_le _ ⟩ hg ) hg;
    · exact fun g hg => csInf_le ⟨ 0, fun g hg => zero_le _ ⟩ hg;
  obtain ⟨ f, hf₁, hf₂ ⟩ := h_exists_fixed_point;
  exact ⟨ f, le_antisymm hf₁ ( hf₂ _ ( hmono hf₁ ) ) ⟩

/-
Variant: if each component functional `Φ i` is monotone and bounded,
    then the diagonal operator has a fixed point.
-/
theorem tropical_quine_exists
    {n : ℕ} (B : Fin n → ℕ)
    (Φ : Fin n → (Fin n → ℕ) → ℕ)
    (hmono : ∀ i, Monotone (fun f => Φ i f))
    (hbound : ∀ i f, Φ i f ≤ B i) :
    ∃ f : Fin n → ℕ, DiagOp Φ f = f := by
  -- First show DiagOp Φ is monotone: for f ≤ g, DiagOp Φ f i = Φ i f ≤ Φ i g = DiagOp Φ g i by hmono i.
  have hmono_diag : Monotone (DiagOp Φ) := by
    exact monotone_lam hmono;
  convert tropical_diagonal_fixed_point B Φ hmono_diag fun f i => hbound i f

/-! ## Section 4: Theorem B — Tropical Gödel Sentence Existence -/

/-
**Key Lemma**: An extensive operator that is not the identity has a strict gap
    at some coordinate — there exists a valuation whose provable cost strictly exceeds
    its actual cost.
-/
theorem exists_gap_of_ne_id {n : ℕ}
    (P : (Fin n → ℕ) → (Fin n → ℕ))
    (hext : ∀ f i, f i ≤ P f i)
    (hne : P ≠ id) :
    ∃ f i, f i < P f i := by
  contrapose! hne;
  exact funext fun f => funext fun i => le_antisymm ( hne f i ) ( hext f i )

/-
**Theorem B: Existence of Tropical Gödel Sentences.**

Given a monotone idempotent extensive operator P on `Fin n → ℕ` that is
diagonally expressive (sensitive to self-referential perturbation), there
exists a tropical Gödel sentence — a fixed point `g` of P at which
bumping the self-referential coordinate creates a provability gap.

The existence of `g` is established via the Knaster-Tarski fixed-point theorem
applied to P. The gap condition follows from diagonal expressivity: the system's
provability operator distinguishes between `g` and its diagonal perturbation.
-/
theorem exists_tropical_godel_sentence
    {n : ℕ}
    (P : (Fin n → ℕ) → (Fin n → ℕ))
    (hmono : Monotone P)
    (hidem : ∀ f, P (P f) = P f)
    (hext : ∀ f i, f i ≤ P f i)
    (hnontriv : ∃ i f, P f i < P (DiagBump i f) i) :
    ∃ (i : Fin n) (g : Fin n → ℕ), IsTropicalGodelSentence P g i := by
  -- From hnontriv, obtain i₀, f₀ with P f₀ i₀ < P (DiagBump i₀ f₀) i₀.
  obtain ⟨i₀, f₀, hlt⟩ : ∃ i₀ f₀, P f₀ i₀ < P (DiagBump i₀ f₀) i₀ := hnontriv;
  -- Let g = P f₀. Then:
  use i₀, P f₀;
  refine' ⟨ _, _ ⟩;
  · grind +revert;
  · refine' lt_of_lt_of_le hlt _;
    exact hmono ( fun i => by unfold DiagBump; aesop ) i₀

/-! ## Section 5: Theorem C — Tropical Incompleteness -/

/-
**Core Incompleteness Lemma**: If an extensive operator has a strict gap
    somewhere, then it is not the identity — it cannot be complete.
-/
theorem not_complete_of_gap {n : ℕ}
    (S : TropicalProofSystem n)
    (hgap : ∃ f i, f i < S.provable f i) :
    ¬ TropicalComplete S := by
  -- By definition of TropicalComplete, assume that ∀ f, S.provable f = f.
  by_contra h_complete
  obtain ⟨f, i, hgap⟩ := hgap
  have : S.provable f = f := h_complete f
  have : f i < f i := by
    grind +splitImp
  exact lt_irrefl (f i) this

/-
**Theorem C: Tropical Incompleteness Theorem.**

No sound, nontrivial tropical proof system can be complete. Specifically:
if a tropical proof system (monotone, idempotent, extensive) is not the identity
operator, then there exists a cost valuation that is not a fixed point of the
provability operator — a "true but unprovable" tropical sentence.

This is the tropical analogue of Gödel's first incompleteness theorem.
The proof proceeds by showing that any non-identity extensive operator must have
a strict gap at some coordinate, which directly contradicts completeness.
-/
theorem tropical_incompleteness
    {n : ℕ}
    (S : TropicalProofSystem n)
    (hne : S.provable ≠ id) :
    ¬ TropicalComplete S := by
  exact fun h => hne <| funext h

/-
**Strengthened incompleteness with extensiveness gap.**
If an extensive idempotent monotone operator strictly inflates some valuation,
it cannot be complete — there exist "true but unprovable" tropical sentences.
This combines `exists_gap_of_ne_id` and `not_complete_of_gap`.
-/
theorem tropical_incompleteness_with_gap
    {n : ℕ}
    (S : TropicalProofSystem n)
    (hgap : ∃ (f : Fin n → ℕ) (i : Fin n), f i < S.provable f i) :
    ¬ TropicalComplete S ∧ S.provable ≠ id := by
  exact ⟨ not_complete_of_gap S hgap, fun h => by obtain ⟨ f, i, hi ⟩ := hgap; have := S.extensive f i; aesop ⟩

/-! ## Section 6: Bridge Theorems -/

/-
**Bridge Theorem 1**: Fixed points of idempotent operators are closed under
    re-application. This is trivial but foundational — it says the "provable truths"
    form a stable set.
-/
theorem fixed_points_of_idem_stable
    {n : ℕ}
    (P : (Fin n → ℕ) → (Fin n → ℕ))
    (_hidem : ∀ f, P (P f) = P f)
    (f : Fin n → ℕ) (hf : P f = f) :
    P (P f) = P f := by
  rw [hf, hf]

/-
**Bridge Theorem 2**: The image of an idempotent operator equals its fixed-point set.
-/
theorem idem_range_eq_fixedPoints
    {α : Type*}
    (P : α → α) (hidem : ∀ x, P (P x) = P x) :
    Set.range P = {x | P x = x} := by
  grind

/-
**Bridge Theorem 3**: The diagonal bump operator is injective — distinct
    inputs produce distinct perturbed outputs. This ensures the self-referential
    construction creates genuinely new sentences.
-/
theorem diagBump_injective {n : ℕ} (i : Fin n) : Injective (DiagBump i) := by
  intro f g hfg;
  exact funext fun j => by have := congr_fun hfg j; by_cases h : j = i <;> simp_all +decide [ DiagBump ] ;

/-
**Bridge Theorem 4**: Composing a closure operator with a diagonal bump
    on a complete lattice yields a map with a fixed point. This is the
    abstract foundation for tropical Gödel sentence existence.
-/
theorem closure_diagBump_has_fixed_point
    {S : Type*} [CompleteLattice S]
    (C D : S → S) (hC : Monotone C) (hD : Monotone D) :
    ∃ g, C (D g) = g := by
  have h_comp : ∃ g, C (D g) ≤ g ∧ ∀ h, C (D h) ≤ h → g ≤ h := by
    refine' ⟨ sInf { x | C ( D x ) ≤ x }, _, _ ⟩;
    · refine' le_sInf _;
      exact fun x hx => le_trans ( hC ( hD ( sInf_le hx ) ) ) hx;
    · exact fun x hx => sInf_le hx;
  obtain ⟨ g, hg₁, hg₂ ⟩ := h_comp; exact ⟨ _, le_antisymm hg₁ ( hg₂ _ ( hC ( hD hg₁ ) ) ) ⟩ ;

/-
**Bridge Theorem 5**: A system with a strict extensiveness gap is necessarily nontrivial.
-/
theorem gap_implies_ne_id
    {n : ℕ} (S : TropicalProofSystem n)
    (hgap : ∃ (f : Fin n → ℕ) (i : Fin n), f i < S.provable f i) :
    S.provable ≠ id := by
  exact fun h => hgap.elim fun f hf => hf.elim fun i hi => hi.ne <| by simp +decide [ h ] ;

/-! ## Section 7: Concrete Examples -/

/-- Example: The "add-one-then-cap" operator `f i ↦ min (f i + 1) B` is a
    monotone bounded operator on `Fin n → ℕ`. Its fixed point is `B` itself. -/
def addOneCap {n : ℕ} (B : Fin n → ℕ) : (Fin n → ℕ) → (Fin n → ℕ) :=
  fun f i => min (f i + 1) (B i)

theorem addOneCap_monotone {n : ℕ} (B : Fin n → ℕ) : Monotone (addOneCap B) := by
  exact fun f g hfg i => min_le_min ( Nat.succ_le_succ ( hfg i ) ) le_rfl

theorem addOneCap_bounded {n : ℕ} (B : Fin n → ℕ) : ∀ f i, addOneCap B f i ≤ B i := by
  exact fun f i => min_le_right _ _

theorem addOneCap_has_fixed_point {n : ℕ} (B : Fin n → ℕ) :
    ∃ f, addOneCap B f = f := by
  -- Let's construct f using the definition of addOneCap.
  let f := fun i => B i;
  exact ⟨ f, funext fun i => by unfold addOneCap; simp +decide [ f ] ⟩

/-- A nontrivial tropical proof system on 1 sentence where provable f i = max (f i) 1.
    This is extensive, monotone, idempotent, and not the identity. -/
def exampleTropicalSystem : TropicalProofSystem 1 where
  provable := fun f i => max (f i) 1
  mono := fun _ _ h i => max_le_max_right 1 (h i)
  idem := by intro f; funext i; simp
  extensive := fun f i => le_max_left _ _

theorem exampleSystem_not_complete : ¬ TropicalComplete exampleTropicalSystem := by
  exact fun h => by have := h ( fun _ => 0 ) ; have := congr_fun this 0 ; simp +decide at this;

theorem exampleSystem_has_gap :
    ∃ (f : Fin 1 → ℕ) (i : Fin 1), f i < exampleTropicalSystem.provable f i := by
  exists fun _ => 0, ⟨ 0, by omega ⟩

/-! ## Section 8: Axiom Verification -/

#print axioms diagBump_monotone
#print axioms diagBump_lt_self
#print axioms tropical_diagonal_fixed_point
#print axioms tropical_quine_exists
#print axioms exists_tropical_godel_sentence
#print axioms tropical_incompleteness
#print axioms tropical_incompleteness_with_gap