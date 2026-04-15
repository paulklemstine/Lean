/-! # CatalogBuild.Pythagorean.Core.SpacetimeLattice

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 19
-/

import Mathlib

/-- The integer lattice ℤ² as a subset of ℝ². -/
def IntLattice2 : Set (ℝ × ℝ) :=
  { p | ∃ a b : ℤ, p = (↑a, ↑b) }


/-- A set S ⊆ ℝ² is discrete if every point has a neighborhood containing no other points of S. -/
def IsDiscreteSet (S : Set (ℝ × ℝ)) : Prop :=
  ∀ p ∈ S, ∃ ε > 0, ∀ q ∈ S, q ≠ p → dist p q ≥ ε


theorem intLattice2_discrete : IsDiscreteSet IntLattice2 := by
  intro p hp
  obtain ⟨a, b, hp_eq⟩ := hp
  use 1
  simp [hp_eq];
  intro x y hxy hne; obtain ⟨ c, d, hcd ⟩ := hxy; simp_all +decide [ Prod.dist_eq ];
  contrapose! hne; simp_all +decide [ Int.dist_eq ] ;
  norm_cast at hne; constructor <;> linarith [ abs_lt.mp hne.1, abs_lt.mp hne.2 ] ;


/-- A Pythagorean triple is primitive if gcd(a, b, c) = 1 and all are positive. -/
def IsPrimitivePythTriple (a b c : ℤ) : Prop :=
  IsPythTriple a b c ∧ 0 < a ∧ 0 < b ∧ 0 < c ∧ Int.gcd a (Int.gcd b c) = 1


/-- The Berggren tree: all triples reachable from (3,4,5) by the three transforms. -/
inductive InBerggrenTree : ℤ → ℤ → ℤ → Prop where
  | root : InBerggrenTree 3 4 5
  | childA : InBerggrenTree a b c →
      InBerggrenTree (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c)
  | childB : InBerggrenTree a b c →
      InBerggrenTree (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c)
  | childC : InBerggrenTree a b c →
      InBerggrenTree (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c)


theorem berggrenTree_all_pythagorean {a b c : ℤ} (h : InBerggrenTree a b c) :
    IsPythTriple a b c := by
      induction h <;> simp_all +decide [ IsPythTriple ];
      · linarith;
      · grobner;
      · lia


theorem berggren_three_children (a b c : ℤ) (h : InBerggrenTree a b c) :
    InBerggrenTree (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) ∧
    InBerggrenTree (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) ∧
    InBerggrenTree (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
      exact ⟨ InBerggrenTree.childA h, InBerggrenTree.childB h, InBerggrenTree.childC h ⟩


/-- The depth-n triples in the Berggren tree. -/
def berggrenDepth : ℕ → Set (ℤ × ℤ × ℤ)
  | 0 => {(3, 4, 5)}
  | n + 1 => { t | ∃ a b c, (a, b, c) ∈ berggrenDepth n ∧
      (t = berggrenA a b c ∨ t = berggrenB a b c ∨ t = berggrenC a b c) }


/-- The photon graph connects the origin to all Pythagorean lattice points. -/
def PhotonReachable (p : ℤ × ℤ) : Prop :=
  ∃ a b c : ℤ, IsPythTriple a b c ∧ p = (a, b) ∧ 0 < c


theorem photon_reach_from_triple {a b c : ℤ} (h : IsPythTriple a b c) (hc : 0 < c) :
    PhotonReachable (a, b) := by
      simpa using ⟨ a, b, |c|, by simpa [ abs_of_pos hc ] using h, rfl, abs_pos.mpr hc.ne' ⟩


theorem pythagorean_is_null_cone (a b c : ℤ) :
    IsPythTriple a b c ↔ (a, b, c) ∈ NullCone := by
      unfold IsPythTriple NullCone; aesop;


/-- The rational light cone: directions (a/c, b/c) from Pythagorean triples. -/
def RationalLightDirection (x y : ℚ) : Prop :=
  x ^ 2 + y ^ 2 = 1


theorem pyth_gives_rational_circle_point (a b c : ℤ) (h : IsPythTriple a b c) (hc : c ≠ 0) :
    RationalLightDirection (a / c) (b / c) := by
      -- Substitute h into the equation to get (a² + b²)/c² = 1.
      have h_sub : (a ^ 2 + b ^ 2 : ℚ) / c ^ 2 = 1 := by
        field_simp;
        norm_cast;
      unfold RationalLightDirection; linear_combination' h_sub;


/-- The set of all Pythagorean triples. -/
def PythSet : Set (ℤ × ℤ × ℤ) :=
  { t | IsPythTriple t.1 t.2.1 t.2.2 }


theorem pythSet_countable : Set.Countable PythSet := by
  refine Set.countable_range ( fun t : ℤ × ℤ × ℤ => t ) |> Set.Countable.mono fun t ht => ?_ ; aesop


theorem lattice_min_distance (p q : ℤ × ℤ) (hne : p ≠ q) :
    (1 : ℤ) ≤ (p.1 - q.1) ^ 2 + (p.2 - q.2) ^ 2 := by
      exact not_lt.1 fun contra => hne <| Prod.ext ( by nlinarith ) ( by nlinarith )


theorem pyth_integer_distance {a b c : ℤ} (h : IsPythTriple a b c) :
    (a : ℤ) ^ 2 + b ^ 2 = c ^ 2 := by
      exact h


theorem no_pyth_triple_leg_one :
    ¬ ∃ b c : ℤ, IsPrimitivePythTriple 1 b c := by
      norm_num [ IsPrimitivePythTriple ];
      intros b c h₁ h₂; unfold IsPythTriple at h₁; nlinarith [ show c ≥ -b by nlinarith, show c ≤ b by nlinarith ] ;


theorem min_primitive_triple (a b c : ℤ)
    (h : IsPrimitivePythTriple a b c) : 5 ≤ c := by
      rcases h with ⟨ h₁, h₂, h₃, h₄, h₅ ⟩;
      by_contra h_contra;
      interval_cases c <;> unfold IsPythTriple at h₁ <;> norm_num at h₁;
      · nlinarith;
      · have : a ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; ( have : b ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; interval_cases a <;> interval_cases b <;> trivial; );
      · have : a ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; ( have : b ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; interval_cases a <;> interval_cases b <;> trivial; );
      · have : a ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; ( have : b ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h₁ ] ) ; interval_cases a <;> interval_cases b <;> trivial; )

#check @intLattice2_discrete
#check @berggrenTree_all_pythagorean
#check @berggren_three_children
#check @infinitely_many_pythagorean_triples
#check @pythagorean_is_null_cone
#check @pythSet_countable
#check @photon_composition
#check @lattice_min_distance
