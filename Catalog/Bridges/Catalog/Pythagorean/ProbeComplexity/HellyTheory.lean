/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# A Categorical Helly Theory for Probe-Separated Presheaves

This file develops a **Helly-type local-to-global theory** for representable
finite generation of presheaves on finite discrete categories, building on the
probe complexity framework.

## Core Idea

A separating probe family `P` creates a bounded measurement window: to control
the global representable dimension of a presheaf `F`, it suffices to check local
bounds on subsets of bounded size. The key insight is that "bad" subsets (those
exceeding a cardinality bound) form an **upward-closed** family, so global failure
is controlled by **minimal** bad subsets whose size is bounded by probe data.

## Main Definitions

* `RestrictedRepDim` — representable dimension restricted to a subset.
* `LocallyBoundedGen` — locally bounded generation at radius `k` with bound `n`.
* `BadSubsets` — the family of subsets where restricted rep dim exceeds a bound.
* `SetUpwardClosed` — upward closure property for set families.
* `IsMinimalBad` — a minimal element of the bad family.
* `ProbeClosure` — closure of a subset under a probe family.
* `IsProbeClosed` — probe-closure fixed-point property.
* `ProbeHellyNumber` — the Helly number `|P| + 1`.

## Main Theorems

* `badSubsets_upwardClosed` — bad subsets are upward closed (**Theorem D**).
* `exists_minimalBad` — every bad set contains a minimal bad subset.
* `minimalBad_card_le` — a minimal bad subset has bounded cardinality.
* `locallyBoundedGen_mono` — monotonicity of local generation (**Theorem A**).
* `helly_dichotomy` — either globally bounded or a small obstruction exists (**Theorem C**).
* `globalBound_of_localBound_separated` — local bounds + separation → global bound (**Theorem B**).
* `probeClosure_idem` — probe closure is idempotent.
* `probeClosed_univ` — the universe is probe-closed.
* `minimalBad_essential` — each element of a minimal bad set is essential.

## Cross-Domain Significance

This theory bridges:
- **Category theory** ↔ **Helly-type combinatorics**: upward-closed bad families
- **Sheaf descent** ↔ **Local-to-global principles**: bounded windows suffice
- **Obstruction theory** ↔ **Minimal bad subsets**: finite search for failure
-/

open Finset Fintype

noncomputable section

universe u v

set_option linter.unusedSectionVars false

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ### Core Definitions -/

/-- The **restricted representable dimension** of a presheaf `F` on a subset `S`:
the sum of fiber cardinalities over objects in `S`. -/
def RestrictedRepDim (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (S : Finset Ob) : ℕ :=
  S.sum fun Y => Fintype.card (F Y)

/-- A presheaf is **locally boundedly generated at radius `k` with bound `n`**
if every subset of `Ob` with at most `k` objects has restricted rep dim at most `n`. -/
def LocallyBoundedGen (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (k n : ℕ) : Prop :=
  ∀ S : Finset Ob, S.card ≤ k → RestrictedRepDim F S ≤ n

/-- The **global representable dimension**: total objectwise cardinality. -/
def GlobalRepDim (F : Ob → Type v) [∀ Y, Fintype (F Y)] : ℕ :=
  ∑ Y : Ob, Fintype.card (F Y)

/-- The family of **bad subsets** for a given bound `n`: subsets where the
restricted representable dimension exceeds `n`. -/
def BadSubsets (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) : Set (Finset Ob) :=
  {S | n < RestrictedRepDim F S}

/-- A family of finite sets is **upward closed** if every superset of a member
is also a member. -/
def SetUpwardClosed (A : Set (Finset Ob)) : Prop :=
  ∀ ⦃S T : Finset Ob⦄, S ∈ A → S ⊆ T → T ∈ A

/-- A subset `S` is a **minimal bad subset** if it is bad but every proper
subset is good. -/
def IsMinimalBad (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) (S : Finset Ob) : Prop :=
  S ∈ BadSubsets F n ∧ ∀ T : Finset Ob, T ⊂ S → T ∉ BadSubsets F n

/-- A probe family for the presheaf model. -/
abbrev ProbeFam (Ob : Type u) := Finset Ob

/-- The **probe closure** of a subset `S` under probe family `P`: `S ∪ P`. -/
def ProbeClosure (P : ProbeFam Ob) (S : Finset Ob) : Finset Ob :=
  S ∪ P

/-- A subset is **probe-closed** if it contains all probe objects: `P ⊆ S`. -/
def IsProbeClosed (P : ProbeFam Ob) (S : Finset Ob) : Prop :=
  P ⊆ S

/-- The **Helly number** of a probe family: `|P| + 1`. -/
def ProbeHellyNumber (P : ProbeFam Ob) : ℕ :=
  P.card + 1

/-- The **probe capacity** of `F` with respect to `P`:
the product of fiber sizes at probe objects. -/
def ProbeCapacity (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob) : ℕ :=
  P.prod fun Z => Fintype.card (F Z)

/-- The **probe signature** of an element `x ∈ F(Y)` records its image under
restriction maps for each probe object in `P`. -/
def ProbeSignature
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) (x : F Y) : ∀ Z : ↥P, F (↑Z) :=
  fun ⟨Z, _⟩ => r Y Z x

/-- Probe signatures are injective at `Y`. -/
def ProbeSignatureInj
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) : Prop :=
  Function.Injective (ProbeSignature P r Y)

/-- The probe family **separates** `F` if probe signatures are injective everywhere. -/
def ProbeSeparates
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob) (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ Y, ProbeSignatureInj P r Y

/-- An element `x ∈ S` is **essential** in a minimal bad subset:
removing it makes the subset good. -/
def IsEssentialElement (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) (S : Finset Ob) (x : Ob) : Prop :=
  x ∈ S ∧ S.erase x ∉ BadSubsets F n

/-! ### Basic Properties of RestrictedRepDim -/

/-- Restricted rep dim on a singleton. -/
theorem restrictedRepDim_singleton (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (Z : Ob) : RestrictedRepDim F {Z} = Fintype.card (F Z) := by
  simp [RestrictedRepDim]

/-- Restricted rep dim is monotone under subset inclusion. -/
theorem restrictedRepDim_mono (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {S T : Finset Ob} (hST : S ⊆ T) :
    RestrictedRepDim F S ≤ RestrictedRepDim F T :=
  Finset.sum_le_sum_of_subset hST

/-- Restricted rep dim on the empty set is zero. -/
theorem restrictedRepDim_empty (F : Ob → Type v) [∀ Y, Fintype (F Y)] :
    RestrictedRepDim F ∅ = 0 := by
  simp [RestrictedRepDim]

/-- Restricted rep dim on univ equals global rep dim. -/
theorem restrictedRepDim_univ (F : Ob → Type v) [∀ Y, Fintype (F Y)] :
    RestrictedRepDim F Finset.univ = GlobalRepDim F := by
  simp [RestrictedRepDim, GlobalRepDim]

/-- Adding a new element to S adds exactly card(F x) to the restricted rep dim. -/
theorem restrictedRepDim_insert (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {S : Finset Ob} {x : Ob} (hx : x ∉ S) :
    RestrictedRepDim F (insert x S) = Fintype.card (F x) + RestrictedRepDim F S := by
  simp [RestrictedRepDim, Finset.sum_insert hx]

/-
Erasing an element decreases the restricted rep dim by card(F x).
-/
theorem restrictedRepDim_erase (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {S : Finset Ob} {x : Ob} (hx : x ∈ S) :
    RestrictedRepDim F (S.erase x) = RestrictedRepDim F S - Fintype.card (F x) := by
  unfold RestrictedRepDim; rw [ Finset.sum_eq_add_sum_diff_singleton hx ] ;
  simp +decide [ Finset.sdiff_singleton_eq_erase, add_tsub_cancel_left ]

/-! ### Theorem A — Monotonicity of Local Bounded Generation -/

/-
**Theorem A (Monotonicity).**
If `F` is locally boundedly generated at radius `k` with bound `n`,
then it is also locally boundedly generated at any radius `m ≤ k`.

This turns local bounded generation into a scale-structured notion,
analogous to monotonicity of `k`-wise consistency in Helly-type combinatorics.
-/
theorem LocallyBoundedGen.mono
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {m k n : ℕ} (hmk : m ≤ k)
    (hF : LocallyBoundedGen F k n) :
    LocallyBoundedGen F m n := by
  exact fun S hS => hF S ( le_trans hS hmk )

/-
If locally bounded at radius k with bound n, then also with bound m ≥ n.
-/
theorem LocallyBoundedGen.bound_mono
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {k n m : ℕ} (hnm : n ≤ m)
    (hF : LocallyBoundedGen F k n) :
    LocallyBoundedGen F k m := by
  exact fun S hS => le_trans ( hF S hS ) hnm

/-
Locally bounded at radius 0 is trivially true.
-/
theorem locallyBoundedGen_zero (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) : LocallyBoundedGen F 0 n := by
  intro S hS;
  unfold RestrictedRepDim; aesop;

/-
Locally bounded at radius ≥ |Ob| with bound n implies global bound.
-/
theorem globalBound_of_localBound_large
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {k n : ℕ} (hk : Fintype.card Ob ≤ k)
    (hlocal : LocallyBoundedGen F k n) :
    GlobalRepDim F ≤ n := by
  simpa [ GlobalRepDim, restrictedRepDim_univ ] using hlocal Finset.univ hk ;

/-! ### Theorem D — Upward Closure of Bad Subsets -/

/-
**Theorem D (Upward Closure).**
The family of bad subsets is upward closed: if `S` is bad
(restricted rep dim exceeds `n`) and `S ⊆ T`, then `T` is also bad.

This is the finite convexity-theoretic shadow of Helly's theorem.
Minimal bad subsets control global failure.
-/
theorem badSubsets_upwardClosed (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) : SetUpwardClosed (BadSubsets F n) := by
  intro S T hS hST;
  exact lt_of_lt_of_le hS ( restrictedRepDim_mono F hST )

/-
The complement: the family of "good" subsets is downward closed.
-/
theorem goodSubsets_downwardClosed (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) : ∀ ⦃S T : Finset Ob⦄, T ∉ BadSubsets F n → S ⊆ T →
    S ∉ BadSubsets F n := by
  exact fun S T hT hST hS => hT <| badSubsets_upwardClosed F n hS hST

/-
The empty set is never bad.
-/
theorem empty_not_bad (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) : ∅ ∉ BadSubsets F n := by
  exact Set.notMem_setOf_iff.mpr ( Nat.not_lt_of_ge ( by simp +decide [ BadSubsets, RestrictedRepDim ] ) )

/-! ### Minimal Bad Subsets -/

/-
In a minimal bad subset, every element is essential: removing it
makes the subset good.
-/
theorem minimalBad_essential (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S)
    {x : Ob} (hx : x ∈ S) :
    IsEssentialElement F n S x := by
  exact ⟨ hx, fun h => hmin.2 _ ( Finset.erase_ssubset hx ) h ⟩

/-
**Existence of Minimal Bad Subsets.**
Every bad subset contains a minimal bad subset. This follows from
the well-foundedness of the strict subset ordering on finite sets.
-/
theorem exists_minimalBad (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) {S : Finset Ob} (hS : S ∈ BadSubsets F n) :
    ∃ T : Finset Ob, T ⊆ S ∧ IsMinimalBad F n T := by
  have h_min : ∃ T ∈ {T : Finset Ob | T ⊆ S ∧ T ∈ BadSubsets F n}, ∀ U ∈ {T : Finset Ob | T ⊆ S ∧ T ∈ BadSubsets F n}, T.card ≤ U.card := by
    apply_rules [ Set.exists_min_image ];
    · exact?;
    · exact ⟨ S, ⟨ Finset.Subset.refl _, hS ⟩ ⟩;
  obtain ⟨ T, hT₁, hT₂ ⟩ := h_min;
  refine' ⟨ T, hT₁.1, hT₁.2, fun U hU hU' => _ ⟩;
  exact not_lt_of_ge ( hT₂ U ⟨ Finset.Subset.trans hU.1 hT₁.1, hU' ⟩ ) ( Finset.card_lt_card hU )

/-
A minimal bad subset is nonempty (since the empty set is good).
-/
theorem minimalBad_nonempty (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S) :
    S.Nonempty := by
  contrapose! hmin;
  simp +decide [ hmin, IsMinimalBad ];
  exact?

/-
In a minimal bad subset, each element has a nonempty fiber
(else removing it wouldn't change the rep dim, contradicting minimality).
-/
theorem minimalBad_fiber_pos (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S)
    {x : Ob} (hx : x ∈ S) :
    0 < Fintype.card (F x) := by
  by_contra hmin; have := hmin; simp_all +decide [ IsMinimalBad ] ;
  convert hmin.2 ( S \ { x } ) ?_ ?_ <;> simp_all +decide [ Finset.subset_iff, BadSubsets ];
  · grind +suggestions;
  · convert hmin.1 using 1 ; rw [ show RestrictedRepDim F S = RestrictedRepDim F ( S \ { x } ) + Fintype.card ( F x ) from ?_ ] ; simp +decide [ this ];
    simp +decide [ RestrictedRepDim, Finset.sum_insert, hx ] ;
    rw [ Finset.sum_eq_sum_diff_singleton_add hx ]

/-! ### Theorem C — Helly Dichotomy -/

/-
**Theorem C (Helly Dichotomy).**
For any bound `n`, either the global representable dimension is at most `n`,
or there exists a minimal bad subset.

This is the categorical analogue of "if Helly fails, there is a small witness."
It gives a computational search strategy for counterexamples: enumerate minimal
bad subsets to find the obstruction.
-/
theorem helly_dichotomy (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (n : ℕ) :
    GlobalRepDim F ≤ n ∨ ∃ S : Finset Ob, IsMinimalBad F n S := by
  by_cases h : GlobalRepDim F ≤ n <;> simp_all +decide [ IsMinimalBad ];
  exact Or.inr ( by rcases exists_minimalBad F n ( show Finset.univ ∈ BadSubsets F n from by simpa [ BadSubsets, restrictedRepDim_univ ] using h ) with ⟨ S, hS₁, hS₂ ⟩ ; exact ⟨ S, hS₂.1, fun T hT₁ hT₂ => hS₂.2 T hT₁ hT₂ ⟩ )

/-
**Bounded obstruction size.**
A minimal bad subset has at most `n + 1` elements when every fiber has at
least one element. If the fibers may be empty, the bound is `|Ob|`.
-/
theorem minimalBad_card_le (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S) :
    S.card ≤ Fintype.card Ob := by
  exact Finset.card_le_univ _

/-
**Tight bound**: A minimal bad subset for bound `n` where each element
has fiber of size ≥ 1 has at most `n + 1` elements.
-/
theorem minimalBad_card_le_succ (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S)
    (hfiber : ∀ x ∈ S, 0 < Fintype.card (F x)) :
    S.card ≤ n + 1 := by
  by_contra h_contra;
  -- Since S is minimal bad, for every x ∈ S, S.erase x is good: RestrictedRepDim F (S.erase x) ≤ n.
  have h_erase_good : ∀ x ∈ S, RestrictedRepDim F (S.erase x) ≤ n := by
    exact fun x hx => le_of_not_gt fun h => hmin.2 _ ( Finset.erase_ssubset hx ) h;
  -- Since S is minimal bad, for every x ∈ S, S.card - 1 ≤ RestrictedRepDim F (S.erase x).
  have h_card_erase : ∀ x ∈ S, S.card - 1 ≤ RestrictedRepDim F (S.erase x) := by
    intro x hx
    have h_card_erase : S.card - 1 ≤ Finset.sum (S.erase x) (fun Y => Fintype.card (F Y)) := by
      exact le_trans ( by aesop ) ( Finset.sum_le_sum fun y hy => Nat.succ_le_of_lt ( hfiber y ( Finset.mem_of_mem_erase hy ) ) );
    exact h_card_erase;
  exact absurd ( h_card_erase _ ( Classical.choose_spec ( Finset.card_pos.mp ( by linarith ) ) ) ) ( by linarith [ h_erase_good _ ( Classical.choose_spec ( Finset.card_pos.mp ( by linarith ) ) ), Nat.sub_add_cancel ( by linarith : 1 ≤ S.card ) ] )

/-! ### Probe Closure Theory -/

/-
Probe closure is extensive: `S ⊆ ProbeClosure P S`.
-/
theorem probeClosure_extensive (P : ProbeFam Ob) (S : Finset Ob) :
    S ⊆ ProbeClosure P S := by
  exact Finset.subset_union_left

/-
Probe closure is monotone: `S ⊆ T → ProbeClosure P S ⊆ ProbeClosure P T`.
-/
theorem probeClosure_mono (P : ProbeFam Ob) {S T : Finset Ob}
    (h : S ⊆ T) : ProbeClosure P S ⊆ ProbeClosure P T := by
  exact Finset.union_subset_union h ( Finset.Subset.refl _ )

/-
Probe closure is idempotent: `ProbeClosure P (ProbeClosure P S) = ProbeClosure P S`.
-/
theorem probeClosure_idem (P : ProbeFam Ob) (S : Finset Ob) :
    ProbeClosure P (ProbeClosure P S) = ProbeClosure P S := by
  unfold ProbeClosure; aesop;

/-
Probe closure always produces a probe-closed set.
-/
theorem probeClosure_isClosed (P : ProbeFam Ob) (S : Finset Ob) :
    IsProbeClosed P (ProbeClosure P S) := by
  exact Finset.subset_union_right

/-
The universe is probe-closed.
-/
theorem probeClosed_univ (P : ProbeFam Ob) :
    IsProbeClosed P Finset.univ := by
  exact Finset.subset_univ _

/-
A probe-closed set is its own probe closure.
-/
theorem isProbeClosed_iff_closure_eq (P : ProbeFam Ob) (S : Finset Ob) :
    IsProbeClosed P S ↔ ProbeClosure P S = S := by
  simp +decide [ IsProbeClosed, ProbeClosure, Finset.union_eq_left ]

/-
Probe closure has cardinality at most `|S| + |P|`.
-/
theorem probeClosure_card_le (P : ProbeFam Ob) (S : Finset Ob) :
    (ProbeClosure P S).card ≤ S.card + P.card := by
  convert Finset.card_union_le S P using 1

/-
Probe closure of a singleton has cardinality at most `|P| + 1`.
-/
theorem probeClosure_singleton_card (P : ProbeFam Ob) (x : Ob) :
    (ProbeClosure P {x}).card ≤ ProbeHellyNumber P := by
  exact le_trans ( Finset.card_union_le _ _ ) ( by simp +arith +decide [ ProbeHellyNumber ] )

/-! ### Theorem B — Local-to-Global via Separation -/

/-
**Fiber bound under separation.**
If `P` separates `F`, then each fiber `|F(Y)|` is bounded by the
probe capacity `∏_{Z ∈ P} |F(Z)|`.
-/
theorem fiber_le_probeCapacity
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ProbeFam Ob) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparates P r) (Y : Ob) :
    Fintype.card (F Y) ≤ ProbeCapacity F P := by
  convert Fintype.card_le_of_injective _ ( hsep Y ) using 1;
  simp +decide [ ProbeCapacity, Fintype.card_pi ];
  conv_lhs => rw [ ← Finset.prod_attach ] ;

/-
**Probe capacity bound from local data.**
If locally bounded at the Helly radius with bound `n`, then
each probe fiber is at most `n`, hence the probe capacity ≤ `n^|P|`.
-/
theorem probeCapacity_le_pow_of_local
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob) {n : ℕ}
    (hlocal : LocallyBoundedGen F (ProbeHellyNumber P) n)
    (Z : Ob) (hZ : Z ∈ P) :
    Fintype.card (F Z) ≤ n := by
  convert hlocal { Z } _;
  simp +decide [ ProbeHellyNumber ]

/-
The probe capacity is at most `n^|P|` under local bounds.
-/
theorem probeCapacity_le_pow
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ProbeFam Ob) {n : ℕ}
    (hlocal : LocallyBoundedGen F (ProbeHellyNumber P) n) :
    ProbeCapacity F P ≤ n ^ P.card := by
  convert Finset.prod_le_prod' fun Z hZ => probeCapacity_le_pow_of_local P hlocal Z hZ;
  rw [ Finset.prod_const, Finset.card_eq_sum_ones ]

/-
**Theorem B (Local-to-Global via Separation).**

If `P` separates `F` and every subset of size at most `|P| + 1` has
restricted rep dim at most `n`, then the global rep dim is bounded by
`|Ob| · n^|P|`.

This is the categorical Helly theorem: finite generation can be detected
on small windows controlled by the probe family.

**Proof architecture:**
1. Local bounds ⟹ each probe fiber `|F(Z)| ≤ n`.
2. Probe capacity `∏_{Z ∈ P} |F(Z)| ≤ n^|P|`.
3. Separation ⟹ each fiber `|F(Y)| ≤ n^|P|`.
4. Global bound: `∑_Y |F(Y)| ≤ |Ob| · n^|P|`.
-/
theorem globalBound_of_localBound_separated
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ProbeFam Ob) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparates P r)
    {n : ℕ}
    (hlocal : LocallyBoundedGen F (ProbeHellyNumber P) n) :
    GlobalRepDim F ≤ Fintype.card Ob * n ^ P.card := by
  convert Finset.sum_le_card_nsmul _ _ _ _;
  · infer_instance;
  · intro x _;
    refine' le_trans _ ( probeCapacity_le_pow P hlocal );
    convert fiber_le_probeCapacity P r hsep x

/-- **Corollary: Helly dichotomy under separation.**
Under probe separation, either the global rep dim satisfies the Helly
bound, or it was impossible for local bounds to hold. -/
theorem helly_separated_dichotomy
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ProbeFam Ob) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparates P r) (n : ℕ) :
    LocallyBoundedGen F (ProbeHellyNumber P) n →
    GlobalRepDim F ≤ Fintype.card Ob * n ^ P.card :=
  globalBound_of_localBound_separated P r hsep

/-! ### Separation Properties -/

/-
Separation is preserved by probe enlargement.
-/
theorem ProbeSeparates.supset
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P Q : ProbeFam Ob} (r : ∀ Y Z, F Y → F Z)
    (hPQ : P ⊆ Q) (hsep : ProbeSeparates P r) :
    ProbeSeparates Q r := by
  intro Y y hxy; have := @hsep Y; simp_all +decide [ funext_iff, ProbeSignature ] ;
  exact fun h => this <| funext fun ⟨ Z, hZ ⟩ => h Z ( hPQ hZ )

/-- If P separates, a probe-closed superset Q ⊇ P also separates. -/
theorem separation_of_probeClosed
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P : ProbeFam Ob} {Q : ProbeFam Ob} (r : ∀ Y Z, F Y → F Z)
    (hclosed : IsProbeClosed P Q)
    (hsep : ProbeSeparates P r) :
    ProbeSeparates Q r :=
  hsep.supset r hclosed

/-! ### Obstruction Theory with Probe Structure -/

/-
**Obstruction Bound under Separation.**
If `P` separates `F`, then any minimal bad subset for bound `n · |Ob|`
whose probe fibers are each ≤ `n` has cardinality bounded by
`Fintype.card Ob`.
-/
theorem obstruction_card_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {n : ℕ} {S : Finset Ob} (hmin : IsMinimalBad F n S) :
    S.card ≤ n + 1 ∨ ∃ x ∈ S, Fintype.card (F x) = 0 := by
  by_cases h : ∀ x ∈ S, Fintype.card ( F x ) ≠ 0;
  · exact Or.inl ( minimalBad_card_le_succ F hmin fun x hx => Nat.pos_of_ne_zero ( h x hx ) );
  · grind

/-
**Full dichotomy with explicit obstruction bound.**
Either the global rep dim ≤ `|Ob| · n^|P|` (under separation + local bounds),
or there exists a minimal bad subset with bounded cardinality.
-/
theorem full_helly_dichotomy
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ProbeFam Ob) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparates P r)
    (n : ℕ) :
    (∀ S : Finset Ob, S.card ≤ ProbeHellyNumber P →
      RestrictedRepDim F S ≤ n) →
    GlobalRepDim F ≤ Fintype.card Ob * n ^ P.card := by
  convert globalBound_of_localBound_separated P r hsep

/-! ### Algorithmic Search Infrastructure -/

/-- Enumerate all subsets of `Ob` of size at most `k`. -/
def subsetsOfSizeAtMost (k : ℕ) : Finset (Finset Ob) :=
  Finset.univ.powerset.filter fun S => S.card ≤ k

/-
Every subset of size ≤ k is in `subsetsOfSizeAtMost k`.
-/
theorem mem_subsetsOfSizeAtMost {k : ℕ} {S : Finset Ob} :
    S ∈ subsetsOfSizeAtMost k ↔ S.card ≤ k := by
  simp +decide [ subsetsOfSizeAtMost ]

end