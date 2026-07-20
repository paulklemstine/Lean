import Catalog.Novelty.MegaSphereInverseLimit
import Catalog.Novelty.MegaSphereBernoulliDeepening
import Catalog.Novelty.MegaSphereStiefelWhitney

/-!
# The Mega-Sphere: a coherent object with all finite stages

A literal tower containing one copy of every topological sphere requires bonding maps,
and there is no canonical map `S^(n+1) → S^n`. Accordingly, the unguarded proposal is
not a well-defined inverse system. This article isolates a rigorous algebraic replacement:
the `n`th stage is the Boolean coordinate sphere `𝔽₂^(n+1)`, and bonding forgets the
last coordinate. Its inverse limit is proved equivalent to the countable Boolean product.
Thus every finite stage is recovered by a surjective projection, while one coherent object
stores all stages simultaneously.

The construction is then connected to two independent universal packages already present
in the surrounding theory: the Bernoulli exponential generating function and the
Stiefel–Whitney polynomial generator. These are algebraic encodings, not claims that the
homology of an inverse limit of ordinary spheres literally consists of Bernoulli numbers.
-/

namespace MegaSphereAllDimensions

open MegaSphere

/-- The finite Boolean stage with coordinates `0, …, n`. -/
abbrev Stage (n : ℕ) := Fin (n + 1) → ZMod 2

/-- The bonding map forgets the final coordinate. -/
def forgetLast (n : ℕ) : Stage (n + 1) →+ Stage n where
  toFun x i := x i.castSucc
  map_zero' := rfl
  map_add' _ _ := rfl

/-- Restriction of a countable Boolean sequence to its first `n+1` coordinates. -/
def restrict (a : ℕ → ZMod 2) (n : ℕ) : Stage n := fun i => a i.val

/-- Every countable sequence determines a coherent point of the inverse limit. -/
def assemble (a : ℕ → ZMod 2) :
    MegaSphere.invLimit (X := Stage) forgetLast :=
  ⟨fun n => restrict a n, by intro n; rfl⟩

@[simp] theorem projection_assemble (a : ℕ → ZMod 2) (n : ℕ) :
    MegaSphere.proj forgetLast n (assemble a) = restrict a n := rfl

/-- Every finite Boolean stage is genuinely recovered by the corresponding projection. -/
theorem projection_surjective (n : ℕ) :
    Function.Surjective (MegaSphere.proj forgetLast n) := by
  intro x
  let a : ℕ → ZMod 2 := fun k => if h : k < n + 1 then x ⟨k, h⟩ else 0
  refine ⟨assemble a, ?_⟩
  ext i
  change a i.val = x i
  dsimp [a]
  rw [if_pos i.isLt]

/-- A coherent family is determined by its diagonal coordinates. -/
def diagonal (x : MegaSphere.invLimit (X := Stage) forgetLast) : ℕ → ZMod 2 :=
  fun n => x.1 n (Fin.last n)

/-
Coherence transports every coordinate to the corresponding diagonal coordinate.
-/
theorem coordinate_eq_diagonal
    (x : MegaSphere.invLimit (X := Stage) forgetLast) (n : ℕ) (i : Fin (n + 1)) :
    x.1 n i = diagonal x i.val := by
  induction' n with n ih;
  · fin_cases i ; rfl;
  · induction i using Fin.lastCases <;> simp_all +decide;
    · rfl;
    · have := x.2 n; have := congrFun this ‹_›; simp_all +decide;
      exact ih _ ▸ congrFun this _

/-- Assembly followed by diagonal extraction is the identity. -/
theorem diagonal_assemble (a : ℕ → ZMod 2) : diagonal (assemble a) = a := by
  funext n
  change a n = a n
  rfl

/-- Diagonal extraction followed by assembly is the identity on coherent families. -/
theorem assemble_diagonal (x : MegaSphere.invLimit (X := Stage) forgetLast) :
    assemble (diagonal x) = x := by
  ext n i
  exact (coordinate_eq_diagonal x n i).symm

/-- The concrete mega-sphere is additively equivalent to the countable Boolean product. -/
noncomputable def inverseLimitEquiv :
    MegaSphere.invLimit (X := Stage) forgetLast ≃+ (ℕ → ZMod 2) where
  toFun := diagonal
  invFun := assemble
  left_inv := assemble_diagonal
  right_inv := diagonal_assemble
  map_add' x y := by
    funext n
    rfl

/-- The Bernoulli generating identity is a single algebraic package for every index. -/
theorem bernoulli_all_indices :
    bernoulliPowerSeries ℚ * (PowerSeries.exp ℚ - 1) = PowerSeries.X :=
  MegaSphereBernoulliDeep.mega_generating_function

/-- The universal Stiefel–Whitney generator has a nonzero class in every degree. -/
theorem stiefel_whitney_all_degrees (n : ℕ) :
    (Polynomial.X : Polynomial (ZMod 2)) ^ n ≠ 0 :=
  MegaSphereSW.sw_pow_ne_zero n

/-! ## Concrete instances -/

#check MegaSphere.proj_comp
#check MegaSphereBernoulliDeep.mega_generating_function

/-- At stage zero, the projection recovers either Boolean coordinate. -/
example (b : ZMod 2) :
    ∃ x : MegaSphere.invLimit (X := Stage) forgetLast,
      MegaSphere.proj forgetLast 0 x = fun _ => b := by
  apply projection_surjective

/-- A sparse sequence can be assembled and recovered without loss. -/
example (m : ℕ) :
    diagonal (assemble (fun k => if k = m then 1 else 0)) =
      (fun k => if k = m then 1 else 0) := by
  exact diagonal_assemble _

/-- The three rigorously surviving parts of the mega-sphere program: a nonempty inverse
limit recovering every finite stage, the Bernoulli generating identity, and nonvanishing
Stiefel–Whitney powers in every degree. -/
theorem mega_sphere_synthesis :
    Nonempty (MegaSphere.invLimit (X := Stage) forgetLast) ∧
    (∀ n, Function.Surjective (MegaSphere.proj forgetLast n)) ∧
    bernoulliPowerSeries ℚ * (PowerSeries.exp ℚ - 1) = PowerSeries.X ∧
    (∀ n, (Polynomial.X : Polynomial (ZMod 2)) ^ n ≠ 0) := by
  refine ⟨⟨0⟩, projection_surjective, bernoulli_all_indices, ?_⟩
  intro n
  exact stiefel_whitney_all_degrees n

-- !-- Lab Notes -- !--
/-
Hypotheses, ranked by structural impact:
(1) coordinate deletion admits a limit canonically equivalent to the countable Boolean
product; (2) every finite stage is a quotient of that limit; (3) the diagonal coordinates
are a complete invariant of coherent families; (4) the Bernoulli generating identity
provides an independent all-index arithmetic package; (5) the universal mod-two
characteristic-class generator has a nonzero power in every degree; (6) the three packages
can be stated simultaneously without identifying their underlying geometric meanings.
The first, third, and sixth are the bold cross-domain hypotheses: they concern a universal
classification, complete reconstruction, and compatibility of independent infinite
packages rather than isolated calculations.

Experiment: the inverse limit was constructed as coherent sequences, finite-stage
surjectivity was tested by extending a finite vector by zero, and reconstruction was
reduced to transport of a coordinate along the bonding maps. Stage zero and a sparse
single-coordinate sequence provide concrete examples. The imported generating-function
and characteristic-class identities were then combined with the limit construction.

Analysis: all six guarded hypotheses survive. Surjective coordinate deletion is the
decisive structural condition. It avoids the collapse seen in multiplication or zero-map
towers. The limit contains exactly one free Boolean choice per natural-numbered coordinate.
The broader generalization is to towers of finite products whose bonding maps delete one
coordinate; the same diagonal reconstruction applies over any additive group.

Critique: ordinary spheres of changing dimension do not form a canonical inverse system;
this is the principal boundary case and shows that the literal unguarded proposal needs a
different definition. Moreover Bernoulli numbers are not the homology groups of this
limit, and the polynomial Stiefel–Whitney ring belongs to the universal projective-space
model. Zero or expanding multiplication bonding maps supply counterexamples to any claim
that nontrivial stages alone force a useful limit. The synthesis therefore keeps the
arithmetic and characteristic-class statements as explicit bridges rather than asserting
a false literal identification.

Synthesis: the surviving core consists of an inverse-limit equivalence, surjective
projections to every finite stage, the Bernoulli generating identity, and a nonzero
Stiefel–Whitney power in every degree. Together these give a reusable all-indices package
while clearly recording the limit of the sphere analogy.
-/

end MegaSphereAllDimensions