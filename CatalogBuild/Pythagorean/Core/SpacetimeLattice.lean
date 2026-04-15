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

/-
PROBLEM
**Theorem (Lattice Discreteness)**: The integer lattice ℤ² is discrete.
    This is the foundational fact: spacetime built on ℤ has no continuous degrees of freedom.

PROVIDED SOLUTION
Use ε = 1. For any lattice point (a,b), any other lattice point (a',b') has at least one coordinate differing by ≥1, so dist ≥ 1. The distance between integer lattice points is at least 1 since the squared distance (a-a')²+(b-b')² ≥ 1 for distinct integer pairs.
-/

theorem intLattice2_discrete : IsDiscreteSet IntLattice2 := by
  intro p hp
  obtain ⟨a, b, hp_eq⟩ := hp
  use 1
  simp [hp_eq];
  intro x y hxy hne; obtain ⟨ c, d, hcd ⟩ := hxy; simp_all +decide [ Prod.dist_eq ];
  contrapose! hne; simp_all +decide [ Int.dist_eq ] ;
  norm_cast at hne; constructor <;> linarith [ abs_lt.mp hne.1, abs_lt.mp hne.2 ] ;

/-! ## Part 2: Pythagorean Triples on the Lattice -/

/-- A Pythagorean triple (a, b, c) satisfies a² + b² = c². -/

def IsPrimitivePythTriple (a b c : ℤ) : Prop :=
  IsPythTriple a b c ∧ 0 < a ∧ 0 < b ∧ 0 < c ∧ Int.gcd a (Int.gcd b c) = 1

/-
PROBLEM
(3, 4, 5) is a primitive Pythagorean triple.

PROVIDED SOLUTION
Unfold IsPrimitivePythTriple, IsPythTriple. All conditions are decidable, use decide or norm_num.
-/

inductive InBerggrenTree : ℤ → ℤ → ℤ → Prop where
  | root : InBerggrenTree 3 4 5
  | childA : InBerggrenTree a b c →
      InBerggrenTree (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c)
  | childB : InBerggrenTree a b c →
      InBerggrenTree (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c)
  | childC : InBerggrenTree a b c →
      InBerggrenTree (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c)

/-
PROBLEM
**Theorem (Tree Pythagorean)**: Every triple in the Berggren tree is Pythagorean.
    This means every photon path in the tree connects lattice points at valid distances.

PROVIDED SOLUTION
Induction on h : InBerggrenTree a b c. Base case: (3,4,5) is Pythagorean by norm_num. Inductive cases: use berggren_A_preserves, berggren_B_preserves, berggren_C_preserves with the inductive hypothesis.
-/

theorem berggrenTree_all_pythagorean {a b c : ℤ} (h : InBerggrenTree a b c) :
    IsPythTriple a b c := by
      induction h <;> simp_all +decide [ IsPythTriple ];
      · linarith;
      · grobner;
      · lia

/-
PROBLEM
**Theorem (Three Children)**: Each node in the Berggren tree produces exactly 3 children.
    This formalizes the ternary branching of light's discrete propagation.

PROVIDED SOLUTION
From h : InBerggrenTree a b c, apply the three constructors childA, childB, childC to get all three children. Use exact ⟨.childA h, .childB h, .childC h⟩.
-/

theorem berggren_three_children (a b c : ℤ) (h : InBerggrenTree a b c) :
    InBerggrenTree (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) ∧
    InBerggrenTree (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) ∧
    InBerggrenTree (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
      exact ⟨ InBerggrenTree.childA h, InBerggrenTree.childB h, InBerggrenTree.childC h ⟩

/-! ## Part 4: The Berggren Tree is Infinite -/

/-
PROBLEM
Helper: The hypotenuse strictly increases under all three Berggren transforms
    when a, b, c > 0 with a² + b² = c².

PROVIDED SOLUTION
We need to show at least one of the three children has hypotenuse > c. The second child has hypotenuse 2a+2b+3c. Since a > 0 and b > 0, we have 2a+2b+3c > 3c > c. So the middle disjunct holds. Use right; left; linarith.
-/

def berggrenDepth : ℕ → Set (ℤ × ℤ × ℤ)
  | 0 => {(3, 4, 5)}
  | n + 1 => { t | ∃ a b c, (a, b, c) ∈ berggrenDepth n ∧
      (t = berggrenA a b c ∨ t = berggrenB a b c ∨ t = berggrenC a b c) }

/-
PROBLEM
**Theorem (Infinitely Many Triples)**: There are infinitely many primitive
    Pythagorean triples, witnessed by the infinite depth of the Berggren tree.

PROVIDED SOLUTION
By induction on N. Use Euclid's formula with increasing m. For any N, take m = N+2, n = 1. Then c = m²+n² = (N+2)²+1 > N. Also a = m²-n² = (N+2)²-1 > 0 and b = 2mn = 2(N+2) > 0. Apply euclid_pythagorean to get the triple. Show N < c by computation: c = (N+2)² + 1 ≥ N+1 > N.
-/

def PhotonReachable (p : ℤ × ℤ) : Prop :=
  ∃ a b c : ℤ, IsPythTriple a b c ∧ p = (a, b) ∧ 0 < c

/-
PROBLEM
**Theorem (Photon Reach)**: Every Pythagorean pair (a,b) is photon-reachable.

PROVIDED SOLUTION
Unfold PhotonReachable. Use ⟨a, b, c, h, rfl, hc⟩.
-/

theorem photon_reach_from_triple {a b c : ℤ} (h : IsPythTriple a b c) (hc : 0 < c) :
    PhotonReachable (a, b) := by
      simpa using ⟨ a, b, |c|, by simpa [ abs_of_pos hc ] using h, rfl, abs_pos.mpr hc.ne' ⟩

/-! ## Part 6: Null-Cone Structure -/

/-- The null cone in 2+1 dimensional spacetime: points where t² = x² + y². -/

theorem pythagorean_is_null_cone (a b c : ℤ) :
    IsPythTriple a b c ↔ (a, b, c) ∈ NullCone := by
      unfold IsPythTriple NullCone; aesop;

/-- The rational light cone: directions (a/c, b/c) from Pythagorean triples. -/

def RationalLightDirection (x y : ℚ) : Prop :=
  x ^ 2 + y ^ 2 = 1

/-
PROBLEM
**Theorem (Pythagorean Directions on Unit Circle)**:
    Every Pythagorean triple gives a rational point on the unit circle.

PROVIDED SOLUTION
Unfold RationalLightDirection. We need (a/c)² + (b/c)² = 1. This is (a²+b²)/c² = 1. Since h : a²+b²=c², use field_simp and then use h or linarith.
-/

theorem pyth_gives_rational_circle_point (a b c : ℤ) (h : IsPythTriple a b c) (hc : c ≠ 0) :
    RationalLightDirection (a / c) (b / c) := by
      -- Substitute h into the equation to get (a² + b²)/c² = 1.
      have h_sub : (a ^ 2 + b ^ 2 : ℚ) / c ^ 2 = 1 := by
        field_simp;
        norm_cast;
      unfold RationalLightDirection; linear_combination' h_sub;

/-! ## Part 7: Discreteness of the Pythagorean Set -/

/-- The set of all Pythagorean triples. -/

def PythSet : Set (ℤ × ℤ × ℤ) :=
  { t | IsPythTriple t.1 t.2.1 t.2.2 }

/-
PROBLEM
**Theorem (Countability)**: The set of Pythagorean triples is countable.
    A discrete spacetime has countably many photon modes.

PROVIDED SOLUTION
PythSet is a subset of ℤ × ℤ × ℤ which is countable. Any subset of a countable type is countable. Use Set.countable_of_injective_of_countable or just note that ℤ × ℤ × ℤ is countable.
-/

theorem pythSet_countable : Set.Countable PythSet := by
  refine Set.countable_range ( fun t : ℤ × ℤ × ℤ => t ) |> Set.Countable.mono fun t ht => ?_ ; aesop

/-! ## Part 8: The Brahmagupta–Fibonacci Identity — Photon Composition -/

/-
PROBLEM
**Theorem (Photon Composition)**: The product of two sums of squares is a sum of squares.
    Physically: combining two photon modes produces another valid mode.

PROVIDED SOLUTION
This is the Brahmagupta-Fibonacci identity. Just use ring.
-/

theorem lattice_min_distance (p q : ℤ × ℤ) (hne : p ≠ q) :
    (1 : ℤ) ≤ (p.1 - q.1) ^ 2 + (p.2 - q.2) ^ 2 := by
      exact not_lt.1 fun contra => hne <| Prod.ext ( by nlinarith ) ( by nlinarith )

/-
PROBLEM
**Theorem (Pythagorean Triples Have Integer Hypotenuse)**:
    The distance between Pythagorean-connected lattice points is always an integer.

PROVIDED SOLUTION
This is just h itself. exact h.
-/

theorem pyth_integer_distance {a b c : ℤ} (h : IsPythTriple a b c) :
    (a : ℤ) ^ 2 + b ^ 2 = c ^ 2 := by
      exact h

/-
PROBLEM
**Theorem (No Pythagorean Triple with Leg 1)**:
    There is no Pythagorean triple (1, b, c) with b, c > 0.
    The minimum "photon step" has leg ≥ 3.

PROVIDED SOLUTION
Suppose (1, b, c) is a primitive Pythagorean triple. Then 1 + b² = c², so c² - b² = 1, i.e., (c-b)(c+b) = 1. Since c, b > 0 (both positive integers), c+b ≥ 2, so (c-b)(c+b) ≥ 2 > 1, contradiction. Formally: from h.1 we get c²-b²=1, factor as (c-b)(c+b)=1. Since c > 0 and b > 0, c+b ≥ 2. Also c-b ≥ 1 (since c² = 1+b² > b²). So product ≥ 2, contradiction with = 1. Use nlinarith or omega after clearing.
-/

theorem no_pyth_triple_leg_one :
    ¬ ∃ b c : ℤ, IsPrimitivePythTriple 1 b c := by
      norm_num [ IsPrimitivePythTriple ];
      intros b c h₁ h₂; unfold IsPythTriple at h₁; nlinarith [ show c ≥ -b by nlinarith, show c ≤ b by nlinarith ] ;

/-
PROBLEM
**Theorem (Minimum Primitive Triple)**: (3, 4, 5) is the smallest primitive triple
    by hypotenuse. This is the fundamental "photon" of the lattice.

PROVIDED SOLUTION
From h : IsPrimitivePythTriple a b c, we have a²+b²=c², a > 0, b > 0, c > 0. Since a ≥ 1 and b ≥ 1 (positive integers), a² ≥ 1 and b² ≥ 1, so c² ≥ 2. Actually we need c ≥ 5. Since a ≥ 1, b ≥ 2 (if b=1 there's no triple by no_pyth_triple_leg_one swapped, and if a=1 same), and since coprime we need a, b to be at least 3, 4. Actually the key insight: a ≥ 1, b ≥ 1, so c² = a²+b² ≥ 2, hence c ≥ 2. But we need 5. Since it's primitive and coprime with a²+b²=c², we need a, b of different parity. The smallest such pair with gcd 1 is (3,4) giving c=5. This requires more careful case analysis: if a ≤ 4 and b ≤ 4, check all cases. Use nlinarith with the constraint that a² + b² = c² and a ≥ 1, b ≥ 1, c > 0, and gcd = 1. Actually just use: c² = a²+b² ≥ 1+4 = 5 when one of a,b ≥ 2. And c ≥ 3 gives c² ≥ 9 ≥ 5. Hmm, we need c ≥ 5. Since primitive triple means gcd=1 and a²+b²=c², and a,b>0: can't have a=b (then gcd≥a>0, and 2a²=c² means c²  even so c even, then gcd(a,a,c)≥2 unless a=1, but 2=c² has no int solution). So WLOG a < b. If a=1: 1+b²=c², (c-b)(c+b)=1, impossible for positive integers. If a=2: 4+b²=c², need c²-b²=4, (c-b)(c+b)=4. Since c+b ≥ 4, c-b=1 gives c+b=4, so b=3/2, not integer. c-b=2 gives c+b=2, b=0, not positive. So no primitive triple with a=2 (actually (3,4,5) has a=3). So a ≥ 3 and b ≥ 4 (or vice versa), giving c² ≥ 9+16 = 25, so c ≥ 5. Use nlinarith after establishing a ≥ 3 and b ≥ 4 through case exhaustion, or use omega/interval_cases on small values.
-/

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
