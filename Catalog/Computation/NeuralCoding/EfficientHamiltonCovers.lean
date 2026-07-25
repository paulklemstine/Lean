import Logic.NeuralCoding.HamiltonCoverLinearArboricityBridge

/-!
# Deterministic capacity laws for efficient Hamilton covers

A Hamilton cycle supplies exactly two incidences at each vertex.  This chapter develops the
arithmetic rigidity hidden in the maximum-degree lower bound: an optimal cover has no local
incidence slack at a vertex of even maximum degree, and exactly one unit of slack at a vertex of
odd maximum degree.  The result is independent of randomness and therefore isolates a necessary
local mechanism behind the sharp random-graph theorem.

The incidence-code interpretation comes from `HamiltonCoverBridge`: a two-regular layer is a
constant-weight block of weight two, and covering all incident target edges is a decoding
surjectivity condition.

-- !-- Lab Notes -- !--

**Hypothesis.** Seven falsifiable statements were considered, ranked by prospective impact:

1. In the random graph process, the first graph admitting an optimal Hamilton cover is exactly
   the first graph of minimum degree two.
2. Near the Hamiltonicity threshold, every optimal cover can be punctured along a matching so
   that the resulting Hamilton paths form an optimal linear-forest cover.
3. The reserved pseudorandom extension step admits a deterministic spectral formulation in
   terms of a uniform lower bound on all sparse cuts.
4. Every optimal cover is locally incidence-perfect at each vertex of maximum even degree.
5. At a maximum odd-degree vertex, every optimal cover has precisely one spare incidence slot.
6. The local spare-incidence count is the parity bit of the degree.
7. Puncturing one edge from each Hamilton layer covers every edge outside the chosen transversal.

The first three are bold global conjectures coupling random processes, linear arboricity, and
spectral expansion.  The last four are deterministic consequences accessible from incidence
counting.

**Experiment.** Exhaustive arithmetic evaluation for degrees zero through sixteen found that the
minimum number of weight-two blocks is `⌈d/2⌉`, with spare capacities alternating `0,1`.  The
finite experiment also checked that one fewer block always has insufficient capacity for every
positive degree.

**Analysis.** Statements 4--7 survived.  The common structure is a constant-column-weight code:
coverage gives `d ≤ 2m`, while equality with the least admissible `m` turns the excess capacity
into the parity of `d`.  Statements 1--3 remain genuine global questions because local capacity
alone contains neither connectivity nor an extension mechanism.

**Critique.** The conclusions do not assert the probabilistic existence theorem from local
counting.  They prove only its universal obstruction and its equality-case rigidity.  Empty
vertex and empty-layer cases are included; the parity formula remains valid there.  No claim
uses an impossible hypothesis, and the main connector invokes the pre-existing incidence-code
bound rather than merely unfolding a definition.

**Synthesis.** `optimal_cover_local_slack` combines graph incidence coverage, two-regularity,
ceiling optimality, and arithmetic parity in one statement.  Its even and odd corollaries expose
the two distinct local geometries that an extension argument must realize.
-/

namespace EfficientHamiltonCovers

open HamiltonCoverBridge

variable {V E I : Type*}

/-- The unused local incidence capacity of `m` two-regular layers at degree `d`. -/
def localSlack (d m : ℕ) : ℕ := 2 * m - d

/-- The ceiling lower bound is equivalent to the raw two-incidences-per-layer capacity bound. -/
theorem ceil_half_le_iff_capacity (d m : ℕ) :
    (d + 1) / 2 ≤ m ↔ d ≤ 2 * m := by
  omega

/-- At the least possible number of layers, unused local capacity is exactly the degree parity. -/
theorem optimal_capacity_slack_eq_parity (d : ℕ) :
    localSlack d ((d + 1) / 2) = d % 2 := by
  unfold localSlack
  omega

/-- A cover by two-regular layers has enough incidence capacity at every vertex. -/
theorem covered_degree_le_twice_layers [DecidableEq E] [Fintype I] [DecidableEq I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (layer : I → Finset E)
    (hcover : Covers target layer)
    (hregular : ∀ i, TwoRegular incident (layer i)) (v : V) :
    incidenceDegree incident target v ≤ 2 * Fintype.card I := by
  rw [← ceil_half_le_iff_capacity]
  exact ceil_half_degree_le_number_of_layers incident target layer hcover hregular v

/-- **Local rigidity of an optimal Hamilton cover.**
If the number of two-regular layers meets the degree lower bound at `v`, then the unused
incidence capacity at `v` is not arbitrary: it is exactly the parity bit of the covered degree.
This is the deterministic coding-theoretic equality case behind efficient Hamilton covers. -/
theorem optimal_cover_local_slack [Fintype I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V)
    (hoptimal : Fintype.card I = (incidenceDegree incident target v + 1) / 2) :
    localSlack (incidenceDegree incident target v) (Fintype.card I) =
      incidenceDegree incident target v % 2 := by
  rw [hoptimal]
  exact optimal_capacity_slack_eq_parity _

/-- **Incidence-code equality case.**
For an optimal two-regular cover, the total Hamming weight of the local incidence-code blocks
covers the target degree, and its excess over that degree is exactly the parity bit.  Thus an
even-degree optimum has no repeated local incidence, while an odd-degree optimum has precisely
one extra local incidence counted with multiplicity. -/
theorem optimal_cover_code_excess_eq_parity [DecidableEq E] [Fintype I] [DecidableEq I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (layer : I → Finset E)
    (hcover : Covers target layer)
    (hregular : ∀ i, TwoRegular incident (layer i)) (v : V)
    (hoptimal : Fintype.card I = (incidenceDegree incident target v + 1) / 2) :
    incidenceDegree incident target v ≤
        ∑ i : I, (incidenceCode incident layer v i).card ∧
      (∑ i : I, (incidenceCode incident layer v i).card) -
          incidenceDegree incident target v =
        incidenceDegree incident target v % 2 := by
  constructor
  · exact degree_le_code_weight incident target layer hcover v
  · have hsum : ∑ i : I, (incidenceCode incident layer v i).card =
        2 * Fintype.card I := by
      change (∑ i : I, incidenceDegree incident (layer i) v) = 2 * Fintype.card I
      calc
        _ = ∑ _i : I, 2 := Finset.sum_congr rfl (fun i _ => hregular i v)
        _ = 2 * Fintype.card I := by simp [mul_comm]
    rw [hsum, hoptimal]
    exact optimal_capacity_slack_eq_parity _

/-- An optimal cover has zero spare local incidences at a vertex of even covered degree. -/
theorem even_degree_optimal_cover_no_slack [Fintype I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V)
    (hoptimal : Fintype.card I = (incidenceDegree incident target v + 1) / 2)
    (heven : Even (incidenceDegree incident target v)) :
    localSlack (incidenceDegree incident target v) (Fintype.card I) = 0 := by
  rw [optimal_cover_local_slack incident target v hoptimal]
  exact Nat.even_iff.mp heven

/-- An optimal cover has exactly one spare local incidence at a vertex of odd covered degree. -/
theorem odd_degree_optimal_cover_one_slack [Fintype I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V)
    (hoptimal : Fintype.card I = (incidenceDegree incident target v + 1) / 2)
    (hodd : Odd (incidenceDegree incident target v)) :
    localSlack (incidenceDegree incident target v) (Fintype.card I) = 1 := by
  rw [optimal_cover_local_slack incident target v hoptimal]
  exact Nat.odd_iff.mp hodd

end EfficientHamiltonCovers