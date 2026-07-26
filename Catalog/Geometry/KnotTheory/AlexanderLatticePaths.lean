import Geometry.KnotTheory.Defs
import Geometry.KnotTheory.AlexanderSignedStateSum

/-!
# Alexander polynomials and monotone square-lattice paths

A monotone path from `(0,0)` to `(n,n)` is encoded by a Boolean word of length
`2n` containing exactly `n` north steps.  Its area is the number of ordered
`(east,north)` step pairs.  A forbidden region is deliberately modeled by an
arbitrary predicate on paths: this is more permissive than avoidance of a
geometric collection of cells, so an impossibility result here also applies to
every ordinary forbidden-region model.

The principal conclusion is a sharp correction to the proposed unsigned
interpretation. Every avoidance generating function has nonnegative
coefficients, whereas the Alexander polynomial of every `T(2,2k+1)`, `k ≥ 1`,
has coefficient `-1` in degree `k-1`. Thus no choice of forbidden region can
realize even this basic infinite knot family as an unsigned path count. The
signed state-sum interpretation survives, and the companion development proves
that finite signed state sums represent all integer Laurent polynomials.

**Target category: cross-domain bridge.** The development connects knot
polynomials with enumerative lattice-path combinatorics and isolates positivity
as the exact obstruction to the proposed bridge.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
1. Every Alexander polynomial is an unsigned forbidden-region path generating
   function (bold knot-theory/combinatorics bridge).
2. Adding local signs to paths suffices to recover every Alexander polynomial.
3. Connected sum corresponds to Cartesian product of signed path-state spaces.
4. Alexander reciprocity is induced by an area-reversing path involution.
5. For alternating knots, coefficient absolute values admit an unsigned path
   model after separating the alternating sign pattern.
6. The Jones and HOMFLY state sums admit analogous signed path models in higher
   dimensional step alphabets (bold multi-invariant extension).
Experiment (Experimenter): paths were encoded as balanced Boolean words, with
area counted by east-before-north pairs. The avoidance class was allowed to be
an arbitrary predicate, strengthening the proposed geometric setup. The entire
`T(2,2k+1)` family was tested symbolically at degree `k-1`.
Analysis (Analyst): Conjecture 1 is false, not merely difficult: unsigned counts
cannot create negative coefficients. Conjectures 2 and 3 survive in the signed
state-sum theory. Conjecture 4 needs a diagram-compatible involution rather than
an abstract coefficient symmetry. Conjectures 5 and 6 need different definitions
and remain testable.
Critique (Critic): the counterexample does not depend on a restrictive notion of
forbidden region; arbitrary deletion of balanced paths is permitted. It is an
infinite-family obstruction, not a finite table lookup. The conclusion does not
claim that the present balanced-word encoding captures crossing data; instead it
proves that no crossing-dependent choice of allowed paths can repair unsigned
coefficient positivity.
Synthesis (Principal Investigator): the unsigned conjecture is replaced by a
signed formulation. Positivity exactly characterizes ordinary finite area-count
generating functions, while signs supply the cancellation intrinsic to Alexander
state sums.
-/

open Finset

namespace KnotLatticePaths

open KnotLattice

/-- A monotone square path is a length-`2n` Boolean step word with exactly `n`
north steps (`true`); the other `n` steps are east steps. -/
def SquarePath (n : ℕ) :=
  {w : Fin (2 * n) → Bool // (Finset.univ.filter fun i => w i = true).card = n}

deriving DecidableEq, Fintype

/-- The area under a balanced step word, counted as east-before-north pairs. -/
def pathArea {n : ℕ} (p : SquarePath n) : ℤ :=
  ((Finset.univ.filter fun q : Fin (2 * n) × Fin (2 * n) =>
      q.1 < q.2 ∧ p.1 q.1 = false ∧ p.1 q.2 = true).card : ℤ)

/-- Paths surviving an arbitrary forbidden-region predicate.  Allowing every
predicate makes this model at least as expressive as geometric cell avoidance. -/
def allowedPaths (n : ℕ) (forbidden : SquarePath n → Prop)
    [DecidablePred forbidden] : Finset (SquarePath n) :=
  Finset.univ.filter fun p => ¬ forbidden p

/-- The coefficient function of the unsigned area generating function. -/
def latticePathGF (n : ℕ) (forbidden : SquarePath n → Prop)
    [DecidablePred forbidden] : ℤ → ℤ :=
  areaGF (allowedPaths n forbidden) pathArea

/-- Every forbidden-region lattice-path generating function has nonnegative
coefficients. -/
theorem latticePathGF_nonnegative (n : ℕ) (forbidden : SquarePath n → Prop)
    [DecidablePred forbidden] : NonnegGF (latticePathGF n forbidden) := by
  exact areaGF_nonneg (allowedPaths n forbidden) pathArea

/-- **Infinite-family obstruction.** For every nontrivial member of the
`T(2,2k+1)` family, no square size and no forbidden-region predicate can make
its Alexander polynomial an unsigned lattice-path area generating function. -/
theorem torusAlexander_not_latticePathGF {k : ℕ} (hk : 1 ≤ k)
    (n : ℕ) (forbidden : SquarePath n → Prop) [DecidablePred forbidden] :
    latticePathGF n forbidden ≠ torusAlex k := by
  exact torusAlex_not_areaGF hk (allowedPaths n forbidden) pathArea

/-- In particular, the reduced trefoil polynomial cannot be an unsigned
forbidden-region lattice-path generating function. -/
theorem trefoil_not_latticePathGF (n : ℕ)
    (forbidden : SquarePath n → Prop) [DecidablePred forbidden] :
    latticePathGF n forbidden ≠ trefoil := by
  intro h
  have htorus : latticePathGF n forbidden = torusAlex 1 := by
    simpa [torusAlex_one] using h
  exact torusAlexander_not_latticePathGF (k := 1) (by omega) n forbidden htorus

/-- The corrected signed statement remains available for every torus Alexander
polynomial: it is represented by a finite signed area-state family. -/
theorem torusAlexander_has_signed_state_model (k : ℕ) :
    ∃ (states : Finset (ℤ × ℕ)) (sign area : ℤ × ℕ → ℤ),
      signedGF states sign area = torusAlex k := by
  exact torusAlex_is_signedGF k

end KnotLatticePaths