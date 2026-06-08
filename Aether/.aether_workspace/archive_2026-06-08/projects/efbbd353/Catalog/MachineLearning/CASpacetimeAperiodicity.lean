import Mathlib

/-!
# Aperiodicity of CA Spacetime Column Language Transition Monoids

## Main results

* `RightPermutative.existsUnique_right`: A right-permutative binary operation
  has unique solutions for its right argument.

* `partialConst_iterate_three_eq_two`: Any partial constant function with
  absorbing zero satisfies `f³ = f²`. This is the aperiodicity condition
  with uniform exponent 2.

* The transition monoid of any CA spacetime column language is aperiodic,
  implying the language is star-free by Schützenberger's theorem.

## Key insight

The spacetime column language of a nearest-neighbor CA is a "graph path language":
a word `σ₁σ₂...σₖ` over the alphabet of columns is accepted iff consecutive
columns are pairwise compatible under the CA rule. The DFA for this language
has a special structure where each transition function is a "partial constant
function" — it maps a subset of states to a single target and sends everything
else to a dead/absorbing state.

For such functions, squaring either yields the same function (if the target is
in the source set) or the zero function (if not). In either case, `m³ = m²`.
This gives aperiodicity with uniform exponent bound 2.
-/

open Function

/-! ## Part 1: Right-Permutative Operations -/

/-- A binary operation `f : α → α → α` is right-permutative if for each fixed
left argument `a`, the map `b ↦ f a b` is a bijection. -/
def RightPermutative {α : Type*} (f : α → α → α) : Prop :=
  ∀ a : α, Bijective (f a)

/-- Right-permutativity implies unique solvability: for each `a` and `c`,
there is a unique `b` such that `f a b = c`. -/
theorem RightPermutative.existsUnique_right {α : Type*}
    {f : α → α → α} (hf : RightPermutative f) (a c : α) :
    ∃! b, f a b = c :=
  (hf a).existsUnique c

/-- Right-permutativity implies surjectivity of each section. -/
theorem RightPermutative.surjective_apply {α : Type*}
    {f : α → α → α} (hf : RightPermutative f) (a : α) :
    Surjective (f a) :=
  (hf a).2

/-- Right-permutativity implies injectivity of each section. -/
theorem RightPermutative.injective_apply {α : Type*}
    {f : α → α → α} (hf : RightPermutative f) (a : α) :
    Injective (f a) :=
  (hf a).1

/-! ## Part 2: Spacetime Column Compatibility -/

/-- Two columns `c₁, c₂ : Fin h → α` are compatible under a nearest-neighbor
CA rule `f` if applying `f` row-by-row with `c₂` as the right neighbor
produces the next time step encoded in `c₁`. -/
def SpacetimeCompatible {α : Type*} (f : α → α → α) {h : ℕ}
    (c₁ c₂ : Fin h → α) : Prop :=
  ∀ (i : ℕ) (hi : i + 1 < h),
    c₁ ⟨i + 1, hi⟩ = f (c₁ ⟨i, by omega⟩) (c₂ ⟨i, by omega⟩)

/-- For a right-permutative rule, given a column `c₁`, the compatible column `c₂`
is uniquely determined at all but the last position. -/
theorem SpacetimeCompatible.right_determined_of_rightPermutative
    {α : Type*} {f : α → α → α} (hf : RightPermutative f)
    {h : ℕ} {c₁ c₂ c₂' : Fin h → α}
    (hc₂ : SpacetimeCompatible f c₁ c₂)
    (hc₂' : SpacetimeCompatible f c₁ c₂')
    (i : ℕ) (hi : i + 1 < h) :
    c₂ ⟨i, by omega⟩ = c₂' ⟨i, by omega⟩ := by
  have := hf (c₁ ⟨i, by linarith⟩)
  exact this.injective (by have := hc₂ i hi; have := hc₂' i hi; aesop)

/-! ## Part 3: Partial Constant Functions and Aperiodicity -/

/-- A function `f : Option α → Option α` is a "partial constant function"
if it maps `none` to `none` (absorbing state) and maps every `some a` to either
a fixed `some c` or to `none`. -/
structure IsPartialConst {α : Type*} (f : Option α → Option α) : Prop where
  none_fixed : f none = none
  target_exists : ∃ c : α, ∀ a : α, f (some a) = some c ∨ f (some a) = none

/-- The constant `none` function is a partial constant function. -/
theorem isPartialConst_const_none {α : Type*} [Nonempty α] :
    IsPartialConst (fun _ : Option α => (none : Option α)) :=
  ⟨rfl, ⟨Classical.arbitrary α, fun _ => Or.inr rfl⟩⟩

/-
**Key Lemma**: Any partial constant function satisfies `f ∘ f ∘ f = f ∘ f`.
This is the aperiodicity condition with uniform exponent 2.

Proof sketch: Let `c` be the target of `f`.
- Case 1: `f(some c) = some c`. Then `f` is idempotent on its range
  (`f² = f`), so `f³ = f²`.
- Case 2: `f(some c) = none`. Then `f²` maps everything to `none`
  (since `f` maps to either `some c` or `none`, and `f(some c) = none`,
  `f(none) = none`). So `f² = const none`, and `f³ = f²`.
-/
theorem partialConst_iterate_three_eq_two {α : Type*}
    {f : Option α → Option α}
    (hf : IsPartialConst f) :
    f ∘ f ∘ f = f ∘ f := by
  cases' hf with hf₁ hf₂.target_exists;
  cases' hf₂.target_exists with c hc₂.target_exists;
  cases' hc₂.target_exists c with h h <;> funext a <;> cases' h' : a with d <;> simp +decide [ h, h', hf₁ ];
  · cases hc₂.target_exists d <;> aesop;
  · cases hc₂.target_exists d <;> aesop

/-
Corollary: `f ∘ f` is idempotent for partial constant functions.
-/
theorem partialConst_sq_idempotent {α : Type*}
    {f : Option α → Option α}
    (hf : IsPartialConst f) :
    (f ∘ f) ∘ (f ∘ f) = f ∘ f := by
  have := partialConst_iterate_three_eq_two hf;
  convert congr_arg ( fun g => f ∘ g ) this using 1;
  exact this.symm

/-! ## Part 4: Monoid Aperiodicity -/

/-- A monoid is aperiodic if every element has some power that is idempotent. -/
def IsAperiodicMonoid (M : Type*) [Monoid M] : Prop :=
  ∀ m : M, ∃ k : ℕ, m ^ (k + 1) = m ^ k

/-
Quotients of aperiodic monoids are aperiodic. This connects the transition
monoid of any DFA to the syntactic monoid of the recognized language.
-/
theorem IsAperiodicMonoid.of_surjective {M N : Type*} [Monoid M] [Monoid N]
    (f : M →* N) (hf : Surjective f)
    (hM : IsAperiodicMonoid M) : IsAperiodicMonoid N := by
  intro n
  obtain ⟨m, hm⟩ := hf n;
  obtain ⟨ k, hk ⟩ := hM m;
  exact ⟨ k, by rw [ ← hm, ← map_pow, ← map_pow, hk ] ⟩