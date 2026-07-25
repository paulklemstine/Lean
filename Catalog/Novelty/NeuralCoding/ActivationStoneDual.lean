import Mathlib

/-!
# A finite Stone model for neural activation patterns

This file isolates the rigorous finite theorem behind the proposed Stone-duality
picture.  A network with `k` Boolean gates has an activation map
`a : X → (Fin k → Bool)`.  Its feasible Stone space is the range of `a`, not in
general the whole Boolean cube.  Hence it has at most `2^k` points, with equality
exactly when every activation pattern is feasible.

Classifiers constant on activation fibres factor uniquely through this finite
space.  Subsets of the feasible space form a Boolean algebra; their pullbacks are
exactly activation-invariant decision regions.  Finally, the full powerset concept
class on this space has VC dimension equal to its number of points.  This last
statement concerns the *full algebra of regions*, not a single fixed classifier.
-/

open Function Set
open scoped BigOperators

namespace ActivationStoneDual

/-- The Boolean activation cube of `k` gates. -/
abbrev Pattern (k : ℕ) := Fin k → Bool

/-- Feasible activation patterns of a concrete activation map. -/
def Feasible {X : Type*} {k : ℕ} (a : X → Pattern k) := Set.range a

/-- The canonical projection from inputs to feasible patterns. -/
def toFeasible {X : Type*} {k : ℕ} (a : X → Pattern k) (x : X) : Feasible a :=
  ⟨a x, x, rfl⟩

/-
The feasible-pattern projection is onto.
-/
theorem toFeasible_surjective {X : Type*} {k : ℕ} (a : X → Pattern k) :
    Surjective (toFeasible a) := by
  intro ⟨ p, x, hx ⟩;
  exact ⟨ x, Subtype.ext hx ⟩

/-
There are exactly `2^k` formal activation patterns.
-/
theorem pattern_card (k : ℕ) : Fintype.card (Pattern k) = 2 ^ k := by
  simp +decide [ Pattern ]

/-
The finite Stone space has at most `2^k` points.
-/
theorem feasible_card_le {X : Type*} [Fintype X] {k : ℕ} (a : X → Pattern k) :
    Fintype.card (Feasible a) ≤ 2 ^ k := by
  convert Set.card_le_card ( Set.range_subset_iff.mpr fun x => Set.mem_univ ( a x ) );
  simp +decide [ Fintype.card_subtype ]

/-
The commonly claimed `2^k` count is valid precisely under feasibility of
all formal activation patterns.
-/
theorem feasible_card_eq_pow_iff {X : Type*} [Fintype X] {k : ℕ}
    (a : X → Pattern k) :
    Fintype.card (Feasible a) = 2 ^ k ↔ Surjective a := by
  constructor;
  · intro h
    have h_card : Fintype.card (Feasible a) = Fintype.card (Set.range a) := by
      congr!;
    have h_range : Set.range a = Set.univ := by
      exact Set.eq_of_subset_of_card_le ( Set.subset_univ _ ) ( by aesop );
    exact Set.range_eq_univ.mp h_range;
  · intro ha
    have h_card : Fintype.card (Set.range a) = 2 ^ k := by
      simp +decide [ ha.range_eq ];
    convert h_card

/-- A classifier is activation-invariant when equal patterns force equal labels. -/
def ActivationInvariant {X Y : Type*} {k : ℕ}
    (a : X → Pattern k) (f : X → Y) : Prop :=
  ∀ ⦃x y⦄, a x = a y → f x = f y

/-- An activation-invariant classifier descends to the feasible Stone space. -/
noncomputable def descend {X Y : Type*} {k : ℕ} (a : X → Pattern k) (f : X → Y) :
    Feasible a → Y := fun p => f p.property.choose

/-
Descending and then projecting recovers the original classifier.
-/
theorem descend_toFeasible {X Y : Type*} {k : ℕ} (a : X → Pattern k) (f : X → Y)
    (h : ActivationInvariant a f) (x : X) :
    descend a f (toFeasible a x) = f x := by
  exact h ( Exists.choose_spec ( Set.mem_range.mp ( toFeasible a x ).2 ) )

/-
The descended classifier is unique.
-/
theorem descend_unique {X Y : Type*} {k : ℕ} (a : X → Pattern k) (f : X → Y)
    (g : Feasible a → Y) (hg : g ∘ toFeasible a = f) :
    g = descend a f := by
  funext p;
  convert congrFun hg p.2.choose using 1;
  convert rfl;
  exact congr_arg g ( Subtype.ext p.2.choose_spec )

/-- Pullback of a feasible-pattern region to input space. -/
def realize {X : Type*} {k : ℕ} (a : X → Pattern k) (U : Set (Feasible a)) : Set X :=
  (toFeasible a) ⁻¹' U

/-
Realization preserves complements: Boolean negation of syntax becomes
complement of the geometric decision region.
-/
theorem realize_compl {X : Type*} {k : ℕ} (a : X → Pattern k)
    (U : Set (Feasible a)) : realize a Uᶜ = (realize a U)ᶜ := by
  ext x; simp [realize]

/-
Realization preserves intersections.
-/
theorem realize_inter {X : Type*} {k : ℕ} (a : X → Pattern k)
    (U V : Set (Feasible a)) : realize a (U ∩ V) = realize a U ∩ realize a V := by
  exact Set.preimage_inter

/-
Realization is injective because every feasible pattern has an input witness.
-/
theorem realize_injective {X : Type*} {k : ℕ} (a : X → Pattern k) :
    Injective (realize a) := by
  intro U V; simp +decide [ Set.ext_iff, realize ] ;
  rintro h _ ⟨ x, rfl ⟩ ; exact h x;

/-
Every activation-invariant binary decision region is the realization of a
unique subset of feasible patterns.
-/
theorem invariant_region_iff_unique_realization {X : Type*} {k : ℕ}
    (a : X → Pattern k) (R : Set X) :
    (∀ ⦃x y⦄, a x = a y → (x ∈ R ↔ y ∈ R)) ↔
      ∃! U : Set (Feasible a), realize a U = R := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · refine' ⟨ { p : Feasible a | p.property.choose ∈ R }, _, _ ⟩ <;> simp_all +decide [ Set.ext_iff ];
    · intro x; specialize h ( show a x = a ( Exists.choose ( Set.mem_range_self x ) ) from Exists.choose_spec ( Set.mem_range_self x ) |> Eq.symm ) ; aesop;
    · intro y hy p hp; specialize hy ( Exists.choose hp ) ; simp_all +decide [ realize ] ;
      convert hy using 2;
      exact Subtype.ext ( hp.choose_spec.symm );
  · obtain ⟨ U, hU₁, hU₂ ⟩ := h; simp_all +decide [ Set.ext_iff, ActivationStoneDual.realize ] ;
    intro x y hxy; have := hU₁ x; have := hU₁ y; simp_all +decide [ toFeasible ] ;

/-- A family of concepts shatters `S` if every subset of `S` is its trace. -/
def Shatters {α : Type*} (C : Set (Set α)) (S : Set α) : Prop :=
  ∀ T, T ⊆ S → ∃ c ∈ C, c ∩ S = T

/-
The full Boolean algebra of subsets shatters every set.
-/
theorem powerset_shatters {α : Type*} (S : Set α) :
    Shatters (Set.univ : Set (Set α)) S := by
  intro T hT; use T; aesop;

/-
Consequently, on a finite Stone space the full clopen/powerset concept class
has VC dimension exactly the number of Stone points (expressed as the sharp
cardinality bound on shattered finite sets).
-/
theorem powerset_vc_exact {α : Type*} [Fintype α] :
    (∀ S : Finset α, Shatters (Set.univ : Set (Set α)) (↑S : Set α)) ∧
    (∀ S : Finset α, Shatters (Set.univ : Set (Set α)) (↑S : Set α) →
      S.card ≤ Fintype.card α) ∧
    ∃ S : Finset α, Shatters (Set.univ : Set (Set α)) (↑S : Set α) ∧
      S.card = Fintype.card α := by
  refine' ⟨ _, _, Finset.univ, _, _ ⟩;
  · exact fun S => powerset_shatters _;
  · exact fun S hS => Finset.card_le_univ S;
  · exact fun S _ => ⟨ S, Set.mem_univ _, by aesop ⟩;
  · rfl

/-
A single fixed decision region cannot shatter any nonempty set.  Thus VC
dimension belongs to a *family* of classifiers; assigning it to one fixed network
without specifying a parameterized hypothesis class is a category error.
-/
theorem singleton_concept_not_shatter_nonempty {α : Type*} (R S : Set α)
    (hS : S.Nonempty) : ¬ Shatters ({R} : Set (Set α)) S := by
  obtain ⟨ x, hx ⟩ := hS;
  by_contra h;
  obtain ⟨ c, hc, hc' ⟩ := h { x } ( by simpa );
  cases h ∅ ( by simp +decide ) ; aesop

/-- In the powerset Boolean algebra, the atoms are exactly singleton regions.
We state atomicity directly to avoid conflating it with the number of all clopens. -/
def RegionAtom {α : Type*} (A : Set α) : Prop :=
  A.Nonempty ∧ ∀ B, B ⊆ A → B.Nonempty → B = A

theorem regionAtom_iff_singleton {α : Type*} (A : Set α) :
    RegionAtom A ↔ ∃ x, A = {x} := by
  constructor;
  · intro hA;
    rcases hA with ⟨ ⟨ x, hx ⟩, hA ⟩;
    exact ⟨x, hA {x} (Set.singleton_subset_iff.mpr hx) (by simp) ▸ rfl⟩
  · rintro ⟨ x, rfl ⟩ ; exact ⟨ by simp +decide, fun B hB hB' => by obtain ⟨ y, hy ⟩ := hB'; have := hB hy; aesop ⟩ ;

/-
Thus atoms of the feasible-region algebra correspond bijectively to feasible
activation patterns.
-/
noncomputable def atomEquiv {α : Type*} : α ≃ {A : Set α // RegionAtom A} where
  toFun x := ⟨{x}, (regionAtom_iff_singleton {x}).2 ⟨x, rfl⟩⟩
  invFun A := (regionAtom_iff_singleton A.1).1 A.2 |>.choose
  left_inv x := by
    convert Set.ext_iff.mp ?_ x ; aesop;
    convert rfl
  right_inv A := by
    grind

/-
The number of atoms therefore equals the number of feasible patterns, and is
at most `2^k` for a `k`-gate network.
-/
theorem atom_card_le_pow {X : Type*} [Fintype X] {k : ℕ} (a : X → Pattern k) :
    Fintype.card {A : Set (Feasible a) // RegionAtom A} ≤ 2 ^ k := by
  refine' le_trans _ ( feasible_card_le a );
  convert Fintype.card_le_of_embedding ( atomEquiv ( α := Feasible a ) |> Equiv.symm |> Equiv.toEmbedding ) using 1

end ActivationStoneDual