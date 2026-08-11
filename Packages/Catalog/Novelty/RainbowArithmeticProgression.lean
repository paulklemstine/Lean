/-
# Finite foundations for rainbow arithmetic-progression thresholds

A three-term arithmetic progression is rainbow when its three positions receive distinct
colours.  This file isolates two ingredients that any threshold argument must use.  First,
the one-progression probability is computed exactly as a falling-factorial ratio.  Second,
an interval of length `3m` contains `m` canonically packed, pairwise disjoint progressions.
The latter turns local probability estimates into independent-block estimates in product
models.

The asymptotic threshold `Tₖ = Θ(k² log k)` depends on a precise choice of random model and
of the event defining `Tₖ`.  No such definition is implicit here.  Instead, the results below
provide model-independent finite components against which proposed definitions can be tested.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
1. For the intended random model, the sharp threshold is `Tₖ ~ C k² log k`, with a universal
   constant `C` determined by the dominant overlap type of two progressions. [Grand challenge]
2. A dependency-graph or hypergraph-container analysis transfers the disjoint-block estimates
   below to all three-term progressions without changing the `k² log k` scale. [Grand challenge]
3. After centering at `C k² log k`, the first-rainbow hitting time has a Gumbel limit law,
   linking additive combinatorics to extreme-value probability. [Grand challenge]
4. The one-progression rainbow probability is the falling-factorial ratio `(k)₃/k³`. [Proved]
5. Its collision complement is exactly `3/k - 2/k²` for nonzero `k`. [Proved]
6. Consecutive blocks provide `m` vertex-disjoint progressions inside `[0,3m)`. [Proved]
7. The local rainbow probability is strictly between zero and one exactly in the
   nondegenerate range `k ≥ 3`. [Proved]

Experiment (Experimenter): Exact rational values for `k = 1,...,10` were calculated before
proof development.  They agree with `(k-1)(k-2)/k²`; the collision probability decays like
`3/k`, not `1/k²`.  Thus a naive independent single-progression waiting-time argument cannot
by itself produce a `k² log k` threshold.

Analysis (Analyst): The `k² log k` scale, if correct, must arise from the global definition of
the event or from dependence/coverage structure, rather than from the rarity of a single
rainbow progression.  The block embedding separates arithmetic geometry from colour
probability and supplies independent coordinates for future lower-tail arguments.

Critique (Critic): The original framing does not define `Tₖ`, the probability space, or its
monotonic parameter, so its numerical constants are not yet a falsifiable theorem.  The file
does not silently choose a convenient interpretation.  Every stated result is non-vacuous;
the principal results use counting, rational-field normalization, and injectivity arguments.

Synthesis (Principal Investigator): The exact local law and the canonical AP packing form a
finite bridge between collision probability and additive combinatorics.  They also expose a
necessary boundary condition for any future threshold proof: its `k²` scale cannot be
explained by one-triple collision probability alone.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open scoped BigOperators

namespace RainbowAP

/-- Colour assignments to the three labelled positions of one progression that make it
rainbow.  Injectivity is precisely pairwise distinctness of the three colours. -/
abbrev RainbowTripleAssignment (k : ℕ) := CakeResearch.CherryConfiguration 3 k

/-- The exact probability that three independent uniform colours are pairwise distinct. -/
def rainbowTripleProbability (k : ℕ) : ℚ :=
  CakeResearch.collisionFreeProbability 3 k

/-
The number of rainbow assignments to one labelled progression is the falling factorial
`(k)₃`.
-/
theorem card_rainbowTripleAssignment (k : ℕ) :
    Fintype.card (RainbowTripleAssignment k) = k.descFactorial 3 := by
  convert CakeResearch.card_cherryConfiguration 3 k using 1

/-
For a nonempty palette, the falling-factorial ratio simplifies to
`(k-1)(k-2)/k²`.
-/
theorem rainbowTripleProbability_formula {k : ℕ} (hk : 0 < k) :
    rainbowTripleProbability k = ((k - 1 : ℕ) : ℚ) * (k - 2) / k ^ 2 := by
  unfold rainbowTripleProbability;
  rcases k with ( _ | _ | k ) <;> simp_all +decide;
  · native_decide +revert;
  · unfold CakeResearch.collisionFreeProbability
    norm_num [Nat.descFactorial]
    ring_nf
    grind

/-
With a nonempty palette, a rainbow progression has probability zero exactly when fewer
than three colours are available.
-/
theorem rainbowTripleProbability_eq_zero_iff {k : ℕ} (hk : 0 < k) :
    rainbowTripleProbability k = 0 ↔ k < 3 := by
  convert CakeResearch.collisionFreeProbability_eq_zero_iff ( show 0 < k from hk ) using 1

/-
Three or more colours give a genuinely positive local rainbow probability.
-/
theorem rainbowTripleProbability_pos {k : ℕ} (hk : 3 ≤ k) :
    0 < rainbowTripleProbability k := by
  rw [ rainbowTripleProbability_formula ( by linarith ) ] ; exact div_pos ( mul_pos ( by norm_num; linarith ) ( by norm_num; linarith ) ) ( by positivity ) ;

/-
The local rainbow probability is strictly below one for every nonempty finite palette.
-/
theorem rainbowTripleProbability_lt_one {k : ℕ} (hk : 0 < k) :
    rainbowTripleProbability k < 1 := by
  rcases k with ( _ | _ | _ | k ) <;> norm_num [ rainbowTripleProbability_formula ] at *;
  rw [ div_lt_iff₀ ] <;> ring_nf <;> nlinarith

/-
The exact collision probability is `3/k - 2/k²`.  This identity is the local
probabilistic input for dependency and second-moment calculations.
-/
theorem one_sub_rainbowTripleProbability {k : ℕ} (hk : 0 < k) :
    1 - rainbowTripleProbability k = 3 / (k : ℚ) - 2 / (k : ℚ) ^ 2 := by
  rw [ rainbowTripleProbability_formula hk ];
  field_simp;
  cases k <;> norm_num at * ; linarith

/-
For at least two colours, collision on a fixed progression has probability at most
`3/k`.
-/
theorem collisionProbability_le_three_div {k : ℕ} (hk : 2 ≤ k) :
    1 - rainbowTripleProbability k ≤ 3 / (k : ℚ) := by
  convert sub_le_self _ ( by positivity : ( 0 : ℚ ) ≤ 2 / ( k : ℚ ) ^ 2 ) using 1;
  exact one_sub_rainbowTripleProbability ( by positivity )

/-- Exact small-palette values used to audit the local probability law. -/
theorem rainbowTripleProbability_small_table :
    rainbowTripleProbability 1 = 0 ∧
    rainbowTripleProbability 2 = 0 ∧
    rainbowTripleProbability 3 = 2 / 9 ∧
    rainbowTripleProbability 4 = 3 / 8 ∧
    rainbowTripleProbability 5 = 12 / 25 ∧
    rainbowTripleProbability 6 = 5 / 9 ∧
    rainbowTripleProbability 7 = 30 / 49 ∧
    rainbowTripleProbability 8 = 21 / 32 ∧
    rainbowTripleProbability 9 = 56 / 81 ∧
    rainbowTripleProbability 10 = 18 / 25 := by
  norm_num [rainbowTripleProbability, CakeResearch.collisionFreeProbability,
    Nat.descFactorial]

/-- The coordinate embedding of `m` consecutive three-point blocks into `[0,3m)`.
Coordinate `j` in block `i` is sent to `3i+j`. -/
def blockVertex (m : ℕ) (x : Fin m × Fin 3) : Fin (3 * m) :=
  ⟨3 * x.1.val + x.2.val, by omega⟩

/-
Distinct block-coordinate pairs give distinct vertices.  Hence the canonical arithmetic
progressions are pairwise vertex-disjoint.
-/
theorem blockVertex_injective (m : ℕ) : Function.Injective (blockVertex m) := by
  intros x y hxy;
  simp_all +decide [ Fin.ext_iff, blockVertex ];
  exact Prod.ext ( Fin.ext ( by omega ) ) ( Fin.ext ( by omega ) )

/-
Every canonical block consists of a strict three-term arithmetic progression.
-/
theorem canonical_block_is_threeAP (m : ℕ) (i : Fin m) :
    let a := (blockVertex m (i, 0)).val
    let b := (blockVertex m (i, 1)).val
    let c := (blockVertex m (i, 2)).val
    a < b ∧ b < c ∧ a + c = 2 * b := by
  grind +locals

/-
**Finite local-to-global foundation.**  An interval with `3m` positions contains `m`
pairwise disjoint three-term arithmetic progressions, while each progression has exactly
`(k)₃` rainbow colour assignments and local probability strictly between zero and one when
`k ≥ 3`.
-/
theorem finite_rainbow_AP_foundation (m k : ℕ) (hk : 3 ≤ k) :
    Function.Injective (blockVertex m) ∧
    (∀ i : Fin m,
      let a := (blockVertex m (i, 0)).val
      let b := (blockVertex m (i, 1)).val
      let c := (blockVertex m (i, 2)).val
      a < b ∧ b < c ∧ a + c = 2 * b) ∧
    Fintype.card (RainbowTripleAssignment k) = k.descFactorial 3 ∧
    0 < rainbowTripleProbability k ∧ rainbowTripleProbability k < 1 := by
  exact ⟨ blockVertex_injective m, fun i => canonical_block_is_threeAP m i, card_rainbowTripleAssignment k, rainbowTripleProbability_pos hk, rainbowTripleProbability_lt_one ( by linarith ) ⟩

end RainbowAP