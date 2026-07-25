import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees
import Catalog.Logic.ProofComplexity.DegreeLattice

/-! # A representation theorem: the size-degrees are the pointwise min/max lattice of growth

This file deepens the order-theoretic core of the Cook–Reckhow program by exhibiting a
**representation / duality** between two a-priori different objects:

* the algebraic preorder of *growth functions* `ℕ → ℕ` under polynomial domination
  (`a ↦ b` iff `a` is pointwise below a monotone polynomial blow-up of `b`), with its
  *pointwise* lattice operations `min` and `max`; and
* the order-theoretic poset of *p-degrees* of proof systems, with its *abstract* lattice
  operations (greatest lower bounds / least upper bounds in the simulation preorder).

The bridge is the size-indexed construction `sysOfSize` and the master domination reduction
`ProofComplexity.simulates_sysOfSize_iff` from `DegreeLattice`.  We prove that `sysOfSize`
*represents* the pointwise lattice structure abstractly:

* **Meets are pointwise minima** (`isGLB_sysOfSize_min`): `sysOfSize (min a b)` is the
  greatest lower bound of `{sysOfSize a, sysOfSize b}` in the simulation preorder.
* **Joins are pointwise maxima** (`isLUB_sysOfSize_max`): `sysOfSize (max a b)` is the
  least upper bound of `{sysOfSize a, sysOfSize b}`.  (Note: the *general* simulation
  preorder has all binary meets via `isGLB_sumSystem`, but joins are not obvious in
  general; for size-indexed systems they exist and are computed pointwise.)
* **Bridge to the direct-sum meet** (`sumSystem_pEquiv_sysOfSize_min`): the concrete
  "run-both" meet `sumSystem (sysOfSize a) (sysOfSize b)` of `DegreeLattice` is
  p-equivalent to the pointwise-min meet `sysOfSize (min a b)` — two presentations of the
  same p-degree, identified by uniqueness of greatest lower bounds.
* **Capstone representation** (`sysOfSize_lattice_representation`): the single statement
  that `sysOfSize` carries pointwise `min`/`max` to abstract meets/joins; the size-degrees
  thus form a lattice, and it is *distributive* — pointwise `min`/`max` on `ℕ` satisfy the
  distributive law, transported to degrees via `sysOfSize_distrib`.

-- !-- Lab Notebook -- !--
Hypothesis : The simulation preorder restricted to size-indexed systems should be a
             *distributive lattice*, with abstract meet/join realised *pointwise* by `min`
             and `max` of the underlying size (growth) functions — a representation theorem
             identifying the order-theoretic p-degree lattice with the algebraic pointwise
             lattice of growth functions modulo polynomial domination.
Result     : Confirmed, `sorry = 0`.  `isGLB_sysOfSize_min` / `isLUB_sysOfSize_max` give
             meet = pointwise min, join = pointwise max; `sumSystem_pEquiv_sysOfSize_min`
             reconciles this with the catalog's direct-sum meet; the bundle
             `sysOfSize_lattice_representation` plus the pointwise law `sysOfSize_distrib`
             record distributivity.
Insight    : Both directions of every (in)equality reduce, via `simulates_sysOfSize_iff`,
             to the *same* arithmetic: the identity blow-up handles `min a b ≤ a`,
             `a ≤ max a b`, while the universal property uses `polyMono_max` to combine two
             blow-ups `f, g` into `fun n => max (f n) (g n)` — exactly the join of blow-ups.
             So "meet/join of degrees" is "min/max of growth functions" with the blow-up
             algebra `polyMono_max` as the only nontrivial ingredient; distributivity is
             then inherited for free from the distributive lattice `(ℕ, min, max)`.
Failure analysis : Trying to register a global `Lattice (ProofSystem ℕ)` instance fails:
             joins do *not* exist for arbitrary (non-size-indexed) systems, only meets do
             (`isGLB_sumSystem`).  Restricting joins to the size-indexed image keeps the
             statements honest — the representation is a lattice statement about the image
             of `sysOfSize`, not about all proof systems.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

/-! ## Meets are pointwise minima -/

/-
!-- comment: `sysOfSize (min a b)` is the GLB of the two size systems: lower bounds use
the identity blow-up (`min ≤ a, b`), the universal property combines two
blow-ups with `polyMono_max`. -- !--

**Meet = pointwise minimum.**  In the simulation preorder, `sysOfSize (fun n => min (a n)
(b n))` is the greatest lower bound of `{sysOfSize a, sysOfSize b}`.
-/
theorem isGLB_sysOfSize_min (a b : ℕ → ℕ) :
    IsGLB ({sysOfSize a, sysOfSize b} : Set (ProofSystem.{0, 0} ℕ))
      (sysOfSize (fun n => min (a n) (b n))) := by
  refine' ⟨ fun x hx => _, fun x hx => _ ⟩ <;> simp_all +decide [ lowerBounds ];
  · rcases hx with ( rfl | rfl ) <;> [ exact simulates_sysOfSize_iff _ _ |>.2 ⟨ id, polyMono_id, fun n => by simp +decide ⟩ ; exact simulates_sysOfSize_iff _ _ |>.2 ⟨ id, polyMono_id, fun n => by simp +decide ⟩ ];
  · obtain ⟨ f, hf, hfa ⟩ := hx.1
    obtain ⟨ g, hg, hgb ⟩ := hx.2;
    refine' ⟨ fun n => max ( f n ) ( g n ), polyMono_max hf hg, fun q => _ ⟩ ; cases le_total ( a q ) ( b q ) <;> simp_all +decide [ sysOfSize ];
    · exact Exists.elim ( hfa q ) fun p hp => ⟨ p, hp.1, Or.inl hp.2 ⟩;
    · exact Exists.elim ( hgb q ) fun p hp => ⟨ p, hp.1, Or.inr hp.2 ⟩

/-! ## Joins are pointwise maxima -/

/-
!-- comment: `sysOfSize (max a b)` is the LUB of the two size systems: it is an upper
bound via the identity blow-up (`a, b ≤ max`), and least via `polyMono_max`. -- !--

**Join = pointwise maximum.**  In the simulation preorder, `sysOfSize (fun n => max (a n)
(b n))` is the least upper bound of `{sysOfSize a, sysOfSize b}`.  (Joins are not available
for arbitrary proof systems; for size-indexed systems they exist and are pointwise.)
-/
theorem isLUB_sysOfSize_max (a b : ℕ → ℕ) :
    IsLUB ({sysOfSize a, sysOfSize b} : Set (ProofSystem.{0, 0} ℕ))
      (sysOfSize (fun n => max (a n) (b n))) := by
  refine' ⟨ _, fun u hu => _ ⟩;
  · rintro u ( rfl | rfl ) <;> [ exact simulates_sysOfSize_iff _ _ |>.2 ⟨ _, polyMono_id, fun n => le_max_left _ _ ⟩ ; exact simulates_sysOfSize_iff _ _ |>.2 ⟨ _, polyMono_id, fun n => le_max_right _ _ ⟩ ];
  · obtain ⟨ f, hf, hfa ⟩ := hu ( Set.mem_insert _ _ );
    obtain ⟨ g, hg, hgb ⟩ := hu ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) );
    refine' ⟨ fun n => max ( f n ) ( g n ), _, _ ⟩;
    · exact polyMono_max hf hg;
    · intro q; obtain ⟨ p, hp₁, hp₂ ⟩ := hfa q; obtain ⟨ q', hq₁, hq₂ ⟩ := hgb q; use u.proves q; simp_all +decide [ sysOfSize ] ;
      grind +extAll

/-! ## Bridge to the direct-sum meet of `DegreeLattice` -/

/-
!-- comment: Both `sumSystem (sysOfSize a) (sysOfSize b)` and `sysOfSize (min a b)` are
GLBs of the same pair, hence p-equivalent by uniqueness of GLB. -- !--

**The two meets agree.**  The direct-sum meet `sumSystem (sysOfSize a) (sysOfSize b)`
(from `DegreeLattice.isGLB_sumSystem`) and the pointwise-minimum meet `sysOfSize (min a b)`
are p-equivalent: they are two presentations of the same p-degree.
-/
theorem sumSystem_pEquiv_sysOfSize_min (a b : ℕ → ℕ) :
    PEquiv (sumSystem (sysOfSize a) (sysOfSize b))
      (sysOfSize (fun n => min (a n) (b n))) := by
  constructor;
  · obtain ⟨ f, hf ⟩ := isGLB_sysOfSize_min a b;
    exact hf ( isGLB_sumSystem ( sysOfSize a ) ( sysOfSize b ) |>.1 );
  · have := ProofComplexity.isGLB_sysOfSize_min a b; have := this.2; simp_all +decide [ lowerBounds, upperBounds ] ;
    grind +suggestions

/-! ## Distributivity, transported pointwise -/

/-
!-- comment: Pointwise `min`/`max` on `ℕ` are distributive, so the corresponding size
systems are *equal* (same size function), hence the size-degrees inherit
distributivity. -- !--

The pointwise distributive law for size systems: `sysOfSize` of `min a (max b c)` is
*equal* to `sysOfSize` of `max (min a b) (min a c)` — the distributive law of `(ℕ, min, max)`
lifted to proof systems.
-/
theorem sysOfSize_distrib (a b c : ℕ → ℕ) :
    sysOfSize (fun n => min (a n) (max (b n) (c n)))
      = sysOfSize (fun n => max (min (a n) (b n)) (min (a n) (c n))) := by
  grind +splitIndPred

/-! ## Capstone: the representation theorem -/

-- !-- comment: Bundling meet = min, join = max, and distributivity: `sysOfSize` represents
--             the pointwise growth-function lattice as the abstract p-degree lattice. -- !--
/-- **Representation theorem.**  The size-indexed construction `sysOfSize` represents the
pointwise lattice `(ℕ → ℕ, min, max)` inside the p-degree poset: pointwise minima are
abstract meets, pointwise maxima are abstract joins, and the distributive law holds.  Hence
the size-degrees form a distributive lattice, with operations computed pointwise on the
underlying growth functions. -/
theorem sysOfSize_lattice_representation (a b c : ℕ → ℕ) :
    IsGLB ({sysOfSize a, sysOfSize b} : Set (ProofSystem.{0, 0} ℕ))
        (sysOfSize (fun n => min (a n) (b n))) ∧
    IsLUB ({sysOfSize a, sysOfSize b} : Set (ProofSystem.{0, 0} ℕ))
        (sysOfSize (fun n => max (a n) (b n))) ∧
    sysOfSize (fun n => min (a n) (max (b n) (c n)))
      = sysOfSize (fun n => max (min (a n) (b n)) (min (a n) (c n))) :=
  ⟨isGLB_sysOfSize_min a b, isLUB_sysOfSize_max a b, sysOfSize_distrib a b c⟩

end ProofComplexity