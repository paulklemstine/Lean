import Mathlib

/-!
# Universal mathematics and operation-relative arithmetic

This file separates three claims that are often conflated in discussions of
non-human mathematics. First, consequence is monotone: every theorem of a base
formal system remains a theorem of every extension. Second, a sentence and its
negation need not be shared by all consistent extensions. Third, primality is
invariant under multiplicative renaming, whereas changing multiplication to
tropical addition changes the irreducibles completely.
-/

open Set

namespace RuckerSaucerWisdom

/-- A Tarskian consequence operation on statements. -/
structure Consequence (Statement : Type*) where
  closure : Set Statement → Set Statement
  extensive : ∀ Γ, Γ ⊆ closure Γ
  monotone : Monotone closure
  idempotent : ∀ Γ, closure (closure Γ) = closure Γ

namespace Consequence

variable {Statement : Type*} (C : Consequence Statement)

/-- A theory is consistent when its closure is not the set of all statements. -/
def Consistent (Γ : Set Statement) : Prop := C.closure Γ ≠ Set.univ

/-- The universal core over a base is the intersection of all consistent extensions. -/
def Universal (base : Set Statement) : Set Statement :=
  {φ | ∀ Δ, base ⊆ Δ → C.Consistent Δ → φ ∈ C.closure Δ}

/-- Every theorem of a base theory belongs to every extension's theorem set. -/
theorem theorem_survives_extension {base Δ : Set Statement} (h : base ⊆ Δ) :
    C.closure base ⊆ C.closure Δ := by
  exact C.monotone h

/-- Every theorem of the base belongs to its universal core. -/
theorem closure_subset_universal (base : Set Statement) :
    C.closure base ⊆ C.Universal base := by
  intro φ hφ Δ hΔ hCΔ
  have h_subset : C.closure base ⊆ C.closure Δ := by
    exact C.monotone hΔ
  exact h_subset hφ

/-- If the base is consistent, its universal core contains no extra statements. -/
theorem universal_eq_closure {base : Set Statement} (hbase : C.Consistent base) :
    C.Universal base = C.closure base := by
  refine' Set.Subset.antisymm _ _;
  · intro φ hφ;
    exact hφ base ( Set.Subset.refl _ ) hbase;
  · exact C.closure_subset_universal base

/-- Consistency descends from an extension to its base. -/
theorem consistent_of_subset {base Δ : Set Statement} (h : base ⊆ Δ)
    (hΔ : C.Consistent Δ) : C.Consistent base := by
  exact fun h => hΔ <| by
    exact Set.eq_univ_of_forall fun x => C.monotone ‹_› ( h.symm ▸ Set.mem_univ x )

end Consequence

section SemanticIndependence

variable {World : Type*}

/-- A sentence is a property of possible mathematical worlds. -/
abbrev Sentence (World : Type*) := World → Prop

/-- A semantic theory is a set of sentences. -/
abbrev Theory (World : Type*) := Set (Sentence World)

/-- A world models a theory when it satisfies every sentence in it. -/
def IsModel (T : Theory World) (w : World) : Prop := ∀ φ ∈ T, φ w

/-- Semantic consequence means truth in every model. -/
def Entails (T : Theory World) (φ : Sentence World) : Prop :=
  ∀ w, IsModel T w → φ w

/-- A semantic theory is consistent when it has a model. -/
def SemanticallyConsistent (T : Theory World) : Prop := ∃ w, IsModel T w

/-- A sentence is extension-universal when every consistent extension entails it. -/
def ExtensionUniversal (T : Theory World) (φ : Sentence World) : Prop :=
  ∀ U, T ⊆ U → SemanticallyConsistent U → Entails U φ

/-- A countermodel to a sentence yields a consistent extension by its negation. -/
theorem countermodel_gives_nonuniversality {T : Theory World} {φ : Sentence World}
    (w : World) (hT : IsModel T w) (hφ : ¬ φ w) : ¬ ExtensionUniversal T φ := by
  -- Assume that φ is extension-universal.
  by_contra h_ext_univ;
  convert h_ext_univ ( T ∪ { fun w => ¬φ w } ) ?_ ?_ w ?_ using 1 <;> simp_all +decide [ IsModel ];
  exact ⟨ w, fun ψ hψ => by aesop ⟩

/-- Models on both sides of a sentence show that neither orientation is universal. -/
theorem two_models_give_independence {T : Theory World} {φ : Sentence World}
    (positive negative : World) (hpT : IsModel T positive) (hp : φ positive)
    (hnT : IsModel T negative) (hn : ¬ φ negative) :
    ¬ ExtensionUniversal T φ ∧ ¬ ExtensionUniversal T (fun w => ¬ φ w) := by
  constructor;
  · exact countermodel_gives_nonuniversality negative hnT hn;
  · apply countermodel_gives_nonuniversality;
    exacts [ hpT, by simpa using hp ]

/-- Over a consistent base, extension-universality is exactly semantic consequence. -/
theorem extensionUniversal_iff_entails {T : Theory World} {φ : Sentence World}
    (hT : SemanticallyConsistent T) : ExtensionUniversal T φ ↔ Entails T φ := by
  constructor;
  · exact fun h => h T Set.Subset.rfl hT;
  · intro h w hw;
    exact fun hw' => fun w' hw'' => h w' ( fun φ hφ => hw'' φ ( hw hφ ) )

/-- The claim that one orientation is universal is exactly the claim that the base
semantically decides the sentence. Thus an RH-style universality claim is not a
consequence of consistency alone; it is a completeness/decidability assertion. -/
theorem universal_orientation_iff_decided {T : Theory World} {φ : Sentence World}
    (hT : SemanticallyConsistent T) :
    ExtensionUniversal T φ ∨ ExtensionUniversal T (fun w => ¬ φ w) ↔
      Entails T φ ∨ Entails T (fun w => ¬ φ w) := by
  rw [ extensionUniversal_iff_entails hT, extensionUniversal_iff_entails hT ]

end SemanticIndependence

namespace ParallelGeometry

/-- Two finite incidence worlds: one has a parallel through every external point;
the other has three lines meeting at a common point. -/
inductive World where
  | affine
  | intersecting
  deriving DecidableEq

/-- Both witness geometries have three points. -/
abbrev Point (_ : World) := Fin 3

/-- Both witness geometries have three lines. -/
abbrev Line (_ : World) := Fin 3

/-- In the affine witness, each line contains its correspondingly numbered point.
In the intersecting witness, every line additionally contains point `0`. -/
def Incidence : (w : World) → Point w → Line w → Prop
  | .affine, p, l => p = l
  | .intersecting, p, l => p = 0 ∨ p = l

/-- Two lines are parallel when they have no common incident point. -/
def Parallel (w : World) (l m : Line w) : Prop :=
  ∀ p, ¬ (Incidence w p l ∧ Incidence w p m)

/-- Playfair's parallel postulate: through every point external to a line there is
exactly one parallel line. -/
def Playfair (w : World) : Prop :=
  ∀ p l, ¬ Incidence w p l → ∃! m, Incidence w p m ∧ Parallel w m l

/-- The finite affine incidence world satisfies Playfair's postulate. -/
theorem affine_playfair : Playfair .affine := by
  simp +decide [ Playfair, Parallel, Incidence ];
  exact fun p l h => ⟨ p, ⟨ rfl, h ⟩, fun m hm => hm.1.symm ▸ rfl ⟩

/-- The finite intersecting incidence world refutes Playfair's postulate. -/
theorem intersecting_not_playfair : ¬ Playfair .intersecting := by
  simp +decide [ Playfair ];
  simp +decide [ ExistsUnique, Incidence, Parallel ]

/-- With no background axioms, the parallel postulate and its negation both have
models, so neither orientation is extension-universal. -/
theorem parallel_postulate_not_universal :
    ¬ ExtensionUniversal (∅ : Theory World) Playfair ∧
      ¬ ExtensionUniversal (∅ : Theory World) (fun w => ¬ Playfair w) := by
  convert two_models_give_independence _ _ _ _ _ _ using 1;
  exacts [ .affine, .intersecting, by tauto, affine_playfair, by tauto, intersecting_not_playfair ]

end ParallelGeometry

section AlienPrimes

/-- Any multiplicative recoding preserves prime elements. -/
theorem prime_invariant_under_alien_encoding
    {M N : Type*} [CommMonoidWithZero M] [CommMonoidWithZero N]
    (e : M ≃* N) (x : M) : Prime (e x) ↔ Prime x := by
  exact MulEquiv.prime_iff e

/-- No multiplicative recoding of natural arithmetic can hide all large primes:
for every bound, the alien presentation contains the image of a larger prime. -/
theorem aliens_discover_unbounded_primes (e : ℕ ≃* ℕ) (bound : ℕ) :
    ∃ p, bound < p ∧ Nat.Prime p ∧ Prime (e p) := by
  obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_infinite_primes ( bound + 1 );
  exact ⟨ p, hp₁, hp₂, prime_invariant_under_alien_encoding e p |>.2 hp₂.prime ⟩

/-- In the min-plus tropical natural numbers, multiplication is ordinary addition.
This predicate is the corresponding notion of a nonzero irreducible element. -/
def TropicalIrreducible (n : ℕ) : Prop :=
  n ≠ 0 ∧ ∀ a b : ℕ, n = a + b → a = 0 ∨ b = 0

/-- Tropical natural arithmetic has exactly one irreducible: the tropical unit step.
This contrasts with the infinitely many primes forced by ordinary multiplication. -/
theorem tropicalIrreducible_iff (n : ℕ) : TropicalIrreducible n ↔ n = 1 := by
  constructor;
  · intro hn
    by_contra h_contra
    have h_ge_two : 2 ≤ n := by
      exact Nat.lt_of_le_of_ne ( Nat.pos_of_ne_zero hn.1 ) ( Ne.symm h_contra );
    exact absurd ( hn.2 1 ( n - 1 ) ( by omega ) ) ( by omega );
  · rintro rfl; exact ⟨ by decide, by intros a b h; omega ⟩ ;

/-- Consequently, any two tropical irreducibles are equal. -/
theorem tropical_irreducibles_unique {m n : ℕ}
    (hm : TropicalIrreducible m) (hn : TropicalIrreducible n) : m = n := by
  rw [ tropicalIrreducible_iff m |>.1 hm, tropicalIrreducible_iff n |>.1 hn ]

end AlienPrimes

end RuckerSaucerWisdom