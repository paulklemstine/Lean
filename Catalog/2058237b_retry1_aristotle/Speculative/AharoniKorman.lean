import Mathlib

/-!
# The Aharoni–Korman ("fishbone") conjecture and a proposed characterization

The **Aharoni–Korman conjecture** states: every poset with no infinite antichain (a *FAC*
poset) admits a chain `C` meeting every maximal antichain.

This file formalizes a *proposed* characterization for countable FAC posets:

> a countable FAC poset satisfies AK iff it does **not** contain a saturated chain `D`
> such that `D` or its order dual is a countable direct sum of infinite co-wellfounded posets.

## What is proved here

* Basic definitions: `IsFAC`, `SatisfiesAK`, `CoWellFounded`, `IsDirectSumOf`,
  `IsAKObstruction`.
* `finite_of_wellFounded_coWellFounded`: a linear order that is both well-founded and
  co-wellfounded is finite.
* `exists_strictAnti_of_infinite_coWellFounded`: an infinite co-wellfounded chain has an
  infinite strictly descending sequence.
* `sigma_not_isFAC`: a countably-infinite *disjoint* (incomparable) sum of nonempty posets
  is not FAC (a transversal is an infinite antichain).
* `isFAC_of_linearOrder`, `satisfiesAK_of_linearOrder`: every chain is FAC and every
  nonempty chain satisfies AK.

## A correction to the requested statement

The requested "obstruction direction",
`IsAKObstruction P → ¬ SatisfiesAK P`, is **false** as stated.  The reason is elementary:
*every* chain (linear order) satisfies AK — take `C = univ`, which meets every maximal
antichain because in a linear order every maximal antichain is a (nonempty) singleton.
But a chain can perfectly well *be* a countable direct sum of infinite co-wellfounded
posets: e.g. `Σₗ (_ : ℕ), ℕᵒᵈ`, the lexicographic sum of countably many copies of the
co-wellfounded order `ℕᵒᵈ`.  This poset is countable, FAC (being a chain), an AK obstruction,
*and* satisfies AK.  Hence the implication cannot hold.

This is made precise and *proved* below as `obstruction_direction_false`.  The original
(false) statement is preserved, commented out, as `ak_obstruction_fails`.

The genuinely open content is the reverse implication
`¬ IsAKObstruction P → SatisfiesAK P` (`ak_characterization_reverse`), which is a form of
the still-open Aharoni–Korman conjecture and is left as `sorry`.
-/

open Order

universe u v

/-- A partial order is **FAC** ("finite antichain condition") if it has no infinite
antichain, i.e. every antichain is finite. -/
class IsFAC (P : Type*) [PartialOrder P] : Prop where
  finite_antichain : ∀ s : Set P, IsAntichain (· ≤ ·) s → s.Finite

/-- An antichain `A` is **maximal** if it is not properly contained in another antichain. -/
def IsMaximalAntichain (P : Type*) [PartialOrder P] (A : Set P) : Prop :=
  IsAntichain (· ≤ ·) A ∧ ∀ B : Set P, IsAntichain (· ≤ ·) B → A ⊆ B → A = B

/-- A poset **satisfies AK** if there is a chain meeting every maximal antichain.  (A chain
cannot meet *every* antichain — e.g. the empty one — so the faithful reading of the
Aharoni–Korman conjecture uses maximal antichains.) -/
def SatisfiesAK (P : Type*) [PartialOrder P] : Prop :=
  ∃ C : Set P, IsChain (· ≤ ·) C ∧ ∀ A : Set P, IsMaximalAntichain P A → (A ∩ C).Nonempty

/-- A type with a `<` relation is **co-wellfounded** if `>` is well-founded, i.e. there is
no infinite strictly ascending sequence. -/
def CoWellFounded (α : Type*) [LT α] : Prop :=
  WellFounded (fun x y : α => x > y)

/-- `IsDirectSumOf C ι f` means the chain `C` is order-isomorphic to the lexicographic
(ordinal) sum `Σₗ i, f i` of the family `f`.  This is the order sum that keeps `C` linear. -/
def IsDirectSumOf (C : Type*) [LinearOrder C] (ι : Type*) [LinearOrder ι]
    (f : ι → Type*) [∀ i, LinearOrder (f i)] : Prop :=
  Nonempty (C ≃o Σₗ i, f i)

/-- `C` is a **countable direct sum of infinite co-wellfounded posets**. -/
def IsCountableDirectSumOfInfiniteCoWellFounded (C : Type*) [LinearOrder C] : Prop :=
  ∃ (ι : Type) (_ : LinearOrder ι), Countable ι ∧
    ∃ (f : ι → Type) (_ : ∀ i, LinearOrder (f i)),
      (∀ i, Infinite (f i)) ∧ (∀ i, CoWellFounded (f i)) ∧ IsDirectSumOf C ι f

/-- An order embedding `e : D ↪o P` from a linear order `D` presents a **saturated chain**
in `P` if its image is a maximal chain: every `x : P` comparable to all of the image is
itself in the image. -/
def IsSaturatedChainEmb {P : Type*} [PartialOrder P] {D : Type*} [Preorder D]
    (e : D ↪o P) : Prop :=
  ∀ x : P, (∀ d : D, e d ≤ x ∨ x ≤ e d) → ∃ d, e d = x

/-- `P` has an **AK obstruction**: it contains a saturated chain `D` such that `D` or its
order dual is a countable direct sum of infinite co-wellfounded posets. -/
def IsAKObstruction (P : Type*) [PartialOrder P] [Countable P] [IsFAC P] : Prop :=
  ∃ (D : Type) (_ : LinearOrder D) (e : D ↪o P),
    IsSaturatedChainEmb e ∧
      (IsCountableDirectSumOfInfiniteCoWellFounded D ∨
       IsCountableDirectSumOfInfiniteCoWellFounded Dᵒᵈ)

/-! ## Task 2: the auxiliary lemmas -/

/-
**An infinite co-wellfounded chain has an infinite strictly descending sequence.**

Sketch: from `Infinite α` obtain an injection `f : ℕ ↪ α`.  Apply the Erdős–Szekeres
lemma `exists_increasing_or_nonincreasing_subseq (· < ·) f` to obtain a subsequence index
`g`.  In the "increasing" case `f ∘ g` is `StrictMono`, contradicting co-wellfoundedness via
`not_strictMono_of_wellFoundedGT`.  Hence we are in the "no two related" case: for `m < n`,
`¬ f (g m) < f (g n)`; since `f ∘ g` is injective, linearity gives `f (g n) < f (g m)`, so
`f ∘ g` is `StrictAnti` (use `strictAnti_nat_of_succ_lt`).
-/
theorem exists_strictAnti_of_infinite_coWellFounded (α : Type*) [LinearOrder α]
    [Infinite α] (hcowf : CoWellFounded α) : ∃ f : ℕ → α, StrictAnti f := by
  -- By the Erdős–Szekeres theorem, there exists a subsequence of `f` which is either strictly increasing or strictly decreasing.
  obtain ⟨g, hg⟩ : ∃ g : ℕ → ℕ, StrictMono g ∧ ( (∀ m n, m < n → (Infinite.natEmbedding α (g m)) < (Infinite.natEmbedding α (g n))) ∨ (∀ m n, m < n → (Infinite.natEmbedding α (g n)) < (Infinite.natEmbedding α (g m))) ) := by
    obtain ⟨g, hg⟩ : ∃ g : ℕ → ℕ, StrictMono g ∧ (∀ m n, m < n → (Infinite.natEmbedding α (g m)) ≤ (Infinite.natEmbedding α (g n))) ∨ StrictMono g ∧ (∀ m n, m < n → (Infinite.natEmbedding α (g n)) ≤ (Infinite.natEmbedding α (g m))) := by
      convert exists_increasing_or_nonincreasing_subseq ( · ≤ · ) ( fun n => Infinite.natEmbedding α n );
      constructor <;> intro h;
      · convert exists_increasing_or_nonincreasing_subseq ( · ≤ · ) ( fun n => Infinite.natEmbedding α n );
      · obtain ⟨ g, hg ⟩ := h;
        exact ⟨ g, Or.imp ( fun h => ⟨ g.strictMono, h ⟩ ) ( fun h => ⟨ g.strictMono, fun m n mn => le_of_not_ge fun hmn => h m n mn hmn ⟩ ) hg ⟩;
    cases' hg with hg hg <;> [ refine' ⟨ g, hg.1, Or.inl fun m n mn => lt_of_le_of_ne ( hg.2 m n mn ) _ ⟩ ; refine' ⟨ g, hg.1, Or.inr fun m n mn => lt_of_le_of_ne ( hg.2 m n mn ) _ ⟩ ] <;> intro h <;> have := hg.1 mn <;> simp_all +decide [ Function.Injective.eq_iff ( show Function.Injective ( Infinite.natEmbedding α ) from Infinite.natEmbedding α |>.injective ) ] ;
  cases' hg.2 with h h;
  · haveI : WellFoundedGT α := ⟨hcowf⟩;
    exact False.elim ( not_strictMono_of_wellFoundedGT ( fun n => Infinite.natEmbedding α ( g n ) ) ( fun m n mn => h m n mn ) );
  · exact ⟨ _, fun m n mn => h _ _ mn ⟩

/-
**A linear order that is both well-founded and co-wellfounded is finite.**

Sketch: contrapositive.  If `α` were infinite then by
`exists_strictAnti_of_infinite_coWellFounded` (using `hcowf`) it has a strictly descending
sequence, contradicting well-foundedness via `not_strictAnti_of_wellFoundedLT`.
-/
theorem finite_of_wellFounded_coWellFounded (α : Type*) [LinearOrder α]
    (hwf : WellFounded (· < · : α → α → Prop)) (hcowf : CoWellFounded α) : Finite α := by
  -- Assume for contradiction that α is infinite.
  have h_inf : Infinite α → False := by
    intro h_inf
    obtain ⟨f, hf⟩ : ∃ f : ℕ → α, StrictAnti f := exists_strictAnti_of_infinite_coWellFounded α hcowf
    have h_wf : WellFoundedLT α := ⟨hwf⟩
    exact not_strictAnti_of_wellFoundedLT f hf
  exact not_infinite_iff_finite.mp h_inf

/-
**A countably-infinite disjoint (incomparable) sum of nonempty posets is not FAC.**

In the default order on `Σ i, f i` elements of different fibers are incomparable
(`Sigma.le_def`).  Choosing one point `g i` in each fiber yields a *transversal*
`{⟨i, g i⟩ | i}`, which is an infinite antichain when the index type is infinite.

(The prompt's parenthetical "each component is an antichain" is imprecise: in the order sum a
single component keeps its internal order, so it is generally *not* an antichain; it is the
transversal across components that forms the antichain.)
-/
theorem sigma_not_isFAC (ι : Type*) [Infinite ι] (f : ι → Type*)
    [∀ i, PartialOrder (f i)] [∀ i, Nonempty (f i)] : ¬ IsFAC (Σ i, f i) := by
  rintro ⟨ h ⟩;
  contrapose! h with h;
  refine' ⟨ Set.range fun i => ⟨ i, Classical.arbitrary ( f i ) ⟩, _, _ ⟩;
  · rintro _ ⟨ i, rfl ⟩ _ ⟨ j, rfl ⟩ hij;
    exact fun h => hij <| by cases h; aesop;
  · exact Set.infinite_range_of_injective fun i j h => by injection h;

/-! ### On the requested lemma 4

> If `C` is a saturated chain in `P` that is a direct sum of infinite posets, then each
> summand induces an antichain in `P`.

This is **false** under the (only sensible) reading in which the direct sum of a *chain* is
the lexicographic/ordinal sum: each summand is then a *sub-chain* of `C`, hence a chain, not
an antichain (unless the summand is a singleton).  There is therefore no faithful theorem to
prove here, and the statement is intentionally omitted. -/

/-! ## Every chain is FAC and satisfies AK -/

/-
Every linearly ordered type is FAC: an antichain in a linear order is a subsingleton.
-/
instance isFAC_of_linearOrder (P : Type*) [LinearOrder P] : IsFAC P := by
  constructor;
  intro s hs; by_contra h_inf; exact (by
  obtain ⟨a, b, hab⟩ : ∃ a b : P, a ∈ s ∧ b ∈ s ∧ a ≠ b := by
    obtain ⟨ a, ha ⟩ := Set.Infinite.nonempty h_inf; obtain ⟨ b, hb ⟩ := Set.Infinite.exists_notMem_finite h_inf ( Set.finite_singleton a ) ; use a, b; aesop;
  cases le_total a b <;> [ exact hs hab.1 hab.2.1 hab.2.2 ‹_›; exact hs hab.2.1 hab.1 hab.2.2.symm ‹_› ]);

/-
Every nonempty chain satisfies AK: the whole space is a chain meeting every maximal
antichain (which, in a linear order, is a nonempty singleton).
-/
theorem satisfiesAK_of_linearOrder (P : Type*) [LinearOrder P] [Nonempty P] :
    SatisfiesAK P := by
  refine' ⟨ Set.univ, _, _ ⟩;
  · exact fun x _ y _ _ => by cases le_total x y <;> tauto;
  · intro A hA;
    by_cases hA_empty : A = ∅;
    · have := hA.2 { Classical.arbitrary P } ?_ <;> simp_all +decide [ IsAntichain ];
    · exact Set.nonempty_iff_ne_empty.2 hA_empty |> fun ⟨ x, hx ⟩ => ⟨ x, hx, Set.mem_univ x ⟩

/-! ## The counterexample refuting the obstruction direction -/

/-- The counterexample poset: the lexicographic sum of countably many copies of `ℕᵒᵈ`.
It is a countable chain (hence FAC and satisfying AK) that is *also* a countable direct sum
of infinite co-wellfounded posets, i.e. an AK obstruction. -/
abbrev CounterP : Type := Σₗ (_ : ℕ), ℕᵒᵈ

instance : Countable CounterP := by
  -- The type Σₗ (_ : ℕ), ℕᵒᵈ is equivalent to the product type ℕ × ℕ, which is countable.
  have h_equiv : CounterP ≃ (ℕ × ℕ) := by
    exact ⟨ fun x => ⟨ x.1, x.2 ⟩, fun x => ⟨ x.1, x.2 ⟩, fun x => rfl, fun x => rfl ⟩;
  exact h_equiv.countable_iff.mpr ( by infer_instance )

instance : IsFAC CounterP := isFAC_of_linearOrder _

/-- `ℕᵒᵈ` is co-wellfounded. -/
theorem coWellFounded_natOrderDual : CoWellFounded ℕᵒᵈ := wellFounded_gt

theorem counterP_satisfiesAK : SatisfiesAK CounterP :=
  satisfiesAK_of_linearOrder CounterP

theorem counterP_isAKObstruction : IsAKObstruction CounterP := by
  refine ⟨CounterP, inferInstance, (OrderIso.refl CounterP).toOrderEmbedding, ?_, Or.inl ?_⟩
  · -- saturation: the embedding is the identity, so `x` itself is a preimage of `x`.
    intro x _
    exact ⟨x, rfl⟩
  · -- `CounterP` is literally `Σₗ (_ : ℕ), ℕᵒᵈ`.
    exact ⟨ℕ, inferInstance, inferInstance, (fun _ => ℕᵒᵈ), inferInstance,
      (fun _ => inferInstance), (fun _ => coWellFounded_natOrderDual),
      ⟨OrderIso.refl _⟩⟩

/-- **The requested obstruction direction is false.**  Concretely, `CounterP` is a countable
FAC poset that is an AK obstruction yet satisfies AK, so no such universal implication can
hold. -/
theorem obstruction_direction_false :
    ¬ (∀ (P : Type) [PartialOrder P] [Countable P] [IsFAC P],
        IsAKObstruction P → ¬ SatisfiesAK P) := by
  intro h
  exact h CounterP counterP_isAKObstruction counterP_satisfiesAK

/-!
## Task 3 (as requested): the obstruction direction

The following is the theorem requested in the task.  As proved above
(`obstruction_direction_false`) it is **false**, so it is preserved only as documentation,
commented out.

```
theorem ak_obstruction_fails : ∀ (P : Type*) [PartialOrder P] [Countable P] [IsFAC P],
    IsAKObstruction P → ¬ SatisfiesAK P := by
  sorry -- FALSE: refuted by `obstruction_direction_false`
```
-/

/-! ## Task 4: the characterization

The full characterization

```
ak_characterization : ∀ (P) [FAC] [Countable], SatisfiesAK P ↔ ¬ IsAKObstruction P
```

is **not** a theorem: its forward direction is `ak_obstruction_fails` above, which is false
(`obstruction_direction_false`).  We therefore only record the *reverse* implication, which
is the genuinely open content (a form of the Aharoni–Korman conjecture), left as `sorry`. -/

/-- The **reverse (open) direction** of the proposed characterization: a countable FAC poset
with no AK obstruction satisfies AK.  This is a form of the still-open Aharoni–Korman
conjecture and is left unproved. -/
theorem ak_characterization_reverse (P : Type) [PartialOrder P] [Countable P] [IsFAC P]
    (h : ¬ IsAKObstruction P) : SatisfiesAK P := by
  sorry