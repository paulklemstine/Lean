import Mathlib

/-!
# Analogy as a finite combinatorial optimization problem

This file gives a deliberately finite model of analogy-making.  A structured map between
**discrete categories** is just a function, so an analogy is represented by a forward map
and a backward map.  Its source round trip is compared with the identity by counting fixed
points.  This makes “choose the best analogy” an exact finite optimization problem.

The development forms a chain: similarity is bounded by source size; equality is
characterized by a perfect round trip; Copycat attains equality; consequently it is a
global maximizer; finite candidate families attain optima; any family containing Copycat
has the perfect optimum; and perfect analogies compose, including finite lists of
self-analogies.

This does not claim to formalize psychological creativity.  It isolates a precise,
non-vacuous mathematical core of the proposed optimization picture.
-/

namespace AnalogyOptimization

/-- A bidirectional analogy between finite carriers.  Equivalently, these are the object
maps of two functors between the corresponding discrete categories. -/
structure Analogy (A B : Type*) where
  forward : A → B
  backward : B → A

namespace Analogy

variable {A B C : Type*}

/-- Source-side round trip. -/
def roundTrip (f : Analogy A B) : A → A := f.backward ∘ f.forward

/-- Composition reverses the backward maps. -/
def comp (g : Analogy B C) (f : Analogy A B) : Analogy A C where
  forward := g.forward ∘ f.forward
  backward := f.backward ∘ g.backward

/-- Hofstadter's Copycat case: both structures are the same carrier and both maps are
identity maps. -/
def copycat (A : Type*) : Analogy A A where
  forward := id
  backward := id

/-- A perfect analogy loses no source information. -/
def Perfect (f : Analogy A B) : Prop := ∀ a, f.roundTrip a = a

/-- Fixed points of the source round trip. -/
def fixedPoints [Fintype A] [DecidableEq A] (f : Analogy A B) : Finset A :=
  Finset.univ.filter fun a => f.roundTrip a = a

/-- Structural similarity is the number of source concepts recovered exactly. -/
def similarity [Fintype A] [DecidableEq A] (f : Analogy A B) : ℕ :=
  f.fixedPoints.card

/-
First bound: no analogy can recover more source concepts than exist.
-/
theorem similarity_le_card [Fintype A] [DecidableEq A] (f : Analogy A B) :
    f.similarity ≤ Fintype.card A := by
  exact Finset.card_le_univ _

/-
The upper bound is attained exactly by perfect source round trips.
-/
theorem similarity_eq_card_iff_perfect [Fintype A] [DecidableEq A] (f : Analogy A B) :
    f.similarity = Fintype.card A ↔ f.Perfect := by
  constructor <;> intro h <;> simp_all +decide [ Analogy.Perfect ];
  · contrapose! h;
    exact ne_of_lt ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ h.choose, Finset.mem_univ _, h.choose_spec ⟩ ) );
  · exact congr_arg Finset.card ( Finset.eq_univ_of_forall fun x => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h x ⟩ )

/-
Copycat is perfect, as witnessed through the preceding optimization criterion.
-/
theorem copycat_similarity [Fintype A] [DecidableEq A] :
    (copycat A).similarity = Fintype.card A := by
  convert similarity_eq_card_iff_perfect _ |>.2 _;
  exact fun a => rfl

/-
Copycat globally maximizes structural similarity among all self-analogies.
-/
theorem copycat_isGreatest [Fintype A] [DecidableEq A] :
    IsGreatest (Set.range (similarity : Analogy A A → ℕ)) (Fintype.card A) := by
  refine' ⟨ _, _ ⟩;
  · exact ⟨ _, copycat_similarity ⟩;
  · rintro _ ⟨ f, rfl ⟩ ; exact Analogy.similarity_le_card f;

/-
Every nonempty finite candidate pool has a similarity-maximizing analogy.
-/
theorem finite_pool_has_best [Fintype A] [DecidableEq A]
    (pool : Finset (Analogy A B)) (hpool : pool.Nonempty) :
    ∃ best ∈ pool, ∀ candidate ∈ pool, candidate.similarity ≤ best.similarity := by
  exact Finset.exists_max_image _ _ hpool

/-
If a pool of self-analogies contains Copycat, every optimizer reaches the absolute
upper bound (and hence has a perfect source round trip).
-/
theorem best_is_perfect_of_copycat_mem [Fintype A] [DecidableEq A]
    (pool : Finset (Analogy A A)) (hcopy : copycat A ∈ pool)
    {best : Analogy A A}
    (hoptimal : ∀ candidate ∈ pool, candidate.similarity ≤ best.similarity) :
    best.Perfect := by
  convert similarity_eq_card_iff_perfect best |>.1 _;
  exact le_antisymm ( similarity_le_card best ) ( by simpa [ copycat_similarity ] using hoptimal _ hcopy )

/-
The optimization theorem is constructive at the level of existence: a finite pool
containing Copycat has an attained best candidate and that candidate is perfect.
-/
theorem finite_pool_with_copycat_has_perfect_best [Fintype A] [DecidableEq A]
    (pool : Finset (Analogy A A)) (hcopy : copycat A ∈ pool) :
    ∃ best ∈ pool,
      (∀ candidate ∈ pool, candidate.similarity ≤ best.similarity) ∧ best.Perfect := by
  have := @finite_pool_has_best A;
  exact Exists.elim ( this pool ⟨ _, hcopy ⟩ ) fun best hbest => ⟨ best, hbest.1, hbest.2, best_is_perfect_of_copycat_mem pool hcopy hbest.2 ⟩

/-
Perfect analogies compose: a sequence of lossless round trips remains lossless.
-/
theorem Perfect.comp {f : Analogy A B} {g : Analogy B C}
    (hf : f.Perfect) (hg : g.Perfect) : (g.comp f).Perfect := by
  intro a;
  have := hf a; have := hg ( f.forward a ) ; simp_all +decide [ Analogy.roundTrip, Analogy.comp ] ;

/-
Composition therefore preserves the maximum possible similarity.
-/
theorem similarity_comp_eq_card [Fintype A] [DecidableEq A]
    {f : Analogy A B} {g : Analogy B C} (hf : f.Perfect) (hg : g.Perfect) :
    (g.comp f).similarity = Fintype.card A := by
  convert similarity_eq_card_iff_perfect ( g.comp f ) |>.2 ( Perfect.comp hf hg )

/-- Fold a finite sequence of self-analogies into one analogy operation. -/
def composeList (fs : List (Analogy A A)) : Analogy A A :=
  fs.foldr comp (copycat A)

/-
A finite sequence of perfect analogy operations is itself perfect.  This is a precise
limited version of “an insight decomposes into analogy operations”: the theorem applies
to any supplied finite decomposition, without asserting that all creative insights have
one.
-/
theorem composeList_perfect (fs : List (Analogy A A))
    (hfs : ∀ f ∈ fs, f.Perfect) : (composeList fs).Perfect := by
  induction fs with
  | nil =>
      intro a
      rfl
  | cons f fs ih =>
      apply Perfect.comp
      · exact ih (fun g hg => hfs g (List.mem_cons_of_mem f hg))
      · exact hfs f (List.mem_cons_self)

/-
The finite sequence consequently retains every source concept.
-/
theorem composeList_similarity [Fintype A] [DecidableEq A]
    (fs : List (Analogy A A)) (hfs : ∀ f ∈ fs, f.Perfect) :
    (composeList fs).similarity = Fintype.card A := by
  exact similarity_eq_card_iff_perfect _ |>.2 ( composeList_perfect _ hfs )

end Analogy

/-! ## Executable two-point sanity checks -/

/-- A nontrivial perfect symmetry of the two-element concept space. -/
def boolFlip : Analogy Bool Bool where
  forward := not
  backward := not

/-- A lossy analogy that collapses both concepts to `false`. -/
def boolCollapse : Analogy Bool Bool where
  forward := fun _ => false
  backward := id

#eval Analogy.similarity (Analogy.copycat Bool) -- 2
#eval Analogy.similarity boolFlip              -- 2
#eval Analogy.similarity boolCollapse          -- 1

end AnalogyOptimization