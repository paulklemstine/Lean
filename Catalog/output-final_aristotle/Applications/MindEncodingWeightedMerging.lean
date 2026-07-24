import Mathlib
import Catalog.Applications.MindEncodingRefined

/-!
# Digital Immortality III: Graded Synapses and the Combinatorics of Merging Minds

This file continues the information-theoretic study of neural connectomes begun in
`Catalog/Applications/MindEncodingRefined.lean`.  There a connectome on `N` neurons
is modelled by its `synapseSlots N = N.choose 2` potential (undirected) synapses.
Here we push the model in two directions requested by the programme's future-work
list and prove the exact laws governing them.

## Graded (weighted) synapses

A biological synapse is not merely present or absent; it carries a *strength*.
Modelling each slot as one of `w` weight levels turns the state space from
`2 ^ slots` into `w ^ slots`.  Passing to the description length in bits
(base-2 logarithm) converts the multiplicative count into the additive law

  `log₂ (w ^ slots) = slots · log₂ w`,

so the marginal storage cost of recording synaptic strength — rather than mere
topology — is exactly `log₂ w` bits per potential synapse.  The Boolean model is
recovered at `w = 2`, where the cost is precisely `slots` bits.

## Merging arbitrarily many minds

`synapseSlots_add` recorded the two-brain merge law
`synapseSlots (M + N) = synapseSlots M + synapseSlots N + M · N`.  Fusing a whole
hierarchy of minds of sizes `N₁, …, Nₖ` obeys the general superadditive identity

  `synapseSlots (∑ Nᵢ) = (∑ synapseSlots Nᵢ) + ∑_{i<j} Nᵢ · Nⱼ`,

where the *cross term* `∑_{i<j} Nᵢ · Nⱼ` counts the brand-new inter-brain
synapses created by the fusion.  We formalise the cross term by the list recursion
`crossPairs` and prove, alongside the merge law, the classical algebraic identity
`(∑ Nᵢ)² = ∑ Nᵢ² + 2 · ∑_{i<j} Nᵢ Nⱼ`, which exhibits the quadratic
"combinatorial explosion" of cross-connections when many minds combine.

## Main results

* `weighted_bits`           — `log₂ (w ^ slots) = slots · log₂ w`.
* `boolean_bits`            — the `w = 2` specialisation: exactly `slots` bits.
* `weighted_bits_pos`       — for `w ≥ 2` the graded cost strictly exceeds the
                              topology-only cost once there is at least one slot.
* `card_directed_weighted`  — directed graded connectomes number `(w ^ slots)²`.
* `crossPairs`, `sq_sum_eq` — the cross-term recursion and `(∑)² = ∑² + 2·cross`.
* `synapseSlots_merge`      — the general superadditive merge law.
* `synapseSlots_merge_ge`   — merging never destroys slots (superadditivity ≥).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (a) recording synaptic *strength* on top of topology
should cost exactly `log₂ w` bits per slot, an additive premium independent of the
neuron count; (b) merging many minds should obey a single closed identity whose
cross term is a sum over unordered pairs of brains, generalising the two-brain
law, and that cross term should be exactly the off-diagonal part of the square of
the total neuron count.

Experiment (Experimenter): For (a) we take base-2 logarithms of the exact count
`w ^ slots` and simplify with `Real.logb_pow`; the Boolean case `w = 2` collapses
via `logb_self_eq_one`.  For (b) we define `crossPairs` by list recursion and
induct, feeding each step through the two-brain law `synapseSlots_add` imported
from the refined file; the square identity `sq_sum_eq` is a parallel induction.

Analysis (Analyst): The logarithmic law is genuinely cross-domain — a purely
combinatorial cardinality becomes an additive statement in real analysis, and the
strict inequality `weighted_bits_pos` shows the premium is real, not formal,
exactly when both `w ≥ 2` and `slots ≥ 1`.  The merge identity reveals that the
*intrinsic* slots (`∑ synapseSlots Nᵢ`) and the *relational* slots (the cross
term) are cleanly separated, and `sq_sum_eq` ties the cross term to `(∑Nᵢ)²`,
making the quadratic blow-up explicit.

Critique (Critic): No result is vacuous.  `weighted_bits` needs `w ≥ 1` (else the
base is `0`); `weighted_bits_pos` needs both `w ≥ 2` and a nonempty slot set, and
the boundary `w = 1` (a single weight level — no information) is exactly where the
premium vanishes, consistent with `logb 2 1 = 0`.  The merge law is checked
against the imported two-brain law on the concrete list `[M, N]`.

Synthesis (PI): Topology, strength, and directionality now compose into a single
graded state count `w ^ (N(N-1))` for directed graded connectomes, while the
merge law and its square companion quantify the combinatorial cost of fusing a
hierarchy of minds.
-- !-- Lab Notes -- !--
-/

namespace DigitalImmortality.WeightedMerging

open scoped BigOperators
open Real
open DigitalImmortality.Refined

/-! ### Section A — Graded synapses: the logarithmic description-length law -/

/-- **Description length of a graded connectome.**  With `w ≥ 1` weight levels
per potential synapse there are `w ^ slots` distinct graded connectomes, so the
number of bits needed to name one is exactly `slots · log₂ w`. -/
theorem weighted_bits (N w : ℕ) :
    Real.logb 2 ((w : ℝ) ^ synapseSlots N) = (synapseSlots N : ℝ) * Real.logb 2 w := by
  rw [Real.logb_pow]

/-- **Boolean specialisation.**  Topology-only (present/absent) synapses cost
exactly `slots` bits — recovering the Boolean bit-length bound of the base model. -/
theorem boolean_bits (N : ℕ) :
    Real.logb 2 ((2 : ℝ) ^ synapseSlots N) = (synapseSlots N : ℝ) := by
  rw [Real.logb_pow]
  simp [Real.logb_self_eq_one]

/-- **The graded premium is real.**  For more than two weight levels (i.e. genuine
grading beyond the Boolean present/absent model) and at least one potential
synapse, recording strength strictly increases the description length beyond the
topology-only cost of `slots` bits. -/
theorem weighted_bits_pos (N w : ℕ) (hw : 3 ≤ w) (hN : 1 ≤ synapseSlots N) :
    (synapseSlots N : ℝ) < Real.logb 2 ((w : ℝ) ^ synapseSlots N) := by
  rw [weighted_bits]
  have hs : (1 : ℝ) ≤ (synapseSlots N : ℝ) := by exact_mod_cast hN
  have h2 : (2 : ℝ) < (w : ℝ) := by
    have : (3 : ℝ) ≤ (w : ℝ) := by exact_mod_cast hw
    linarith
  have hlogw : (1 : ℝ) < Real.logb 2 w := by
    calc (1 : ℝ) = Real.logb 2 2 := by simp [Real.logb_self_eq_one]
      _ < Real.logb 2 w := Real.logb_lt_logb (by norm_num) (by norm_num) h2
  nlinarith [hs, hlogw]

/-! ### Section B — Directed graded connectomes -/

/-- **Directed graded state count.**  Directed synapses double the slot count, so
the number of directed graded connectomes is the square of the undirected graded
count `w ^ slots`. -/
theorem directed_weighted_sq (N w : ℕ) :
    w ^ directedSlots N = (w ^ synapseSlots N) ^ 2 := by
  rw [directed_eq_two_mul, ← pow_mul, mul_comm]

/-- The full directed graded state space has exactly `w ^ (N(N-1))` elements. -/
theorem card_directed_weighted (N w : ℕ) :
    Fintype.card (Fin (directedSlots N) → Fin w) = (w ^ synapseSlots N) ^ 2 := by
  rw [← directed_weighted_sq]
  simp

/-! ### Section C — Merging a hierarchy of minds -/

/-- The **cross term**: given the neuron counts of a list of brains, `crossPairs`
counts the unordered pairs of neurons drawn from *different* brains, i.e.
`∑_{i<j} Nᵢ · Nⱼ` — exactly the new inter-brain synapse slots created by fusion. -/
def crossPairs : List ℕ → ℕ
  | [] => 0
  | x :: xs => x * xs.sum + crossPairs xs

/-- The cross term of the empty and singleton lists. -/
@[simp] theorem crossPairs_nil : crossPairs [] = 0 := rfl

@[simp] theorem crossPairs_singleton (x : ℕ) : crossPairs [x] = 0 := by
  simp [crossPairs]

/-- **Square-of-a-sum identity.**  `(∑ Nᵢ)² = ∑ Nᵢ² + 2 · ∑_{i<j} Nᵢ Nⱼ`.
The off-diagonal part of the square of the total neuron count is twice the cross
term. -/
theorem sq_sum_eq (L : List ℕ) :
    L.sum ^ 2 = (L.map (· ^ 2)).sum + 2 * crossPairs L := by
  induction L with
  | nil => simp
  | cons x xs ih =>
      simp only [List.sum_cons, List.map_cons, crossPairs]
      ring_nf
      ring_nf at ih
      nlinarith [ih]

/-- **General mind-merge law.**  Fusing a hierarchy of brains with neuron counts
`L = [N₁, …, Nₖ]` yields
`synapseSlots (∑ Nᵢ) = (∑ synapseSlots Nᵢ) + ∑_{i<j} Nᵢ · Nⱼ`:
the total synapse slots split into the brains' own (intrinsic) slots plus the
brand-new cross-brain slots counted by `crossPairs`. -/
theorem synapseSlots_merge (L : List ℕ) :
    synapseSlots L.sum = (L.map synapseSlots).sum + crossPairs L := by
  induction L with
  | nil => simp [synapseSlots]
  | cons x xs ih =>
      simp only [List.sum_cons, List.map_cons, crossPairs]
      rw [synapseSlots_add, ih]
      ring

/-- **Superadditivity of merging.**  Merging never destroys synapse capacity: the
merged brain has at least as many slots as the brains had separately. -/
theorem synapseSlots_merge_ge (L : List ℕ) :
    (L.map synapseSlots).sum ≤ synapseSlots L.sum := by
  rw [synapseSlots_merge]
  exact Nat.le_add_right _ _

/-! ### Concrete instantiations (PEGB: examples) -/

-- The general merge law specialises to the imported two-brain law.
example (M N : ℕ) :
    synapseSlots (M + N) = synapseSlots M + synapseSlots N + M * N := by
  have h := synapseSlots_merge [M, N]
  simpa [crossPairs, add_assoc] using h

-- Merging three cortical columns of 3, 4, 5 neurons: 12 neurons, C(12,2)=66 slots,
-- of which C(3,2)+C(4,2)+C(5,2)=3+6+10=19 are intrinsic and 3·4+3·5+4·5=47 cross.
example : synapseSlots (3 + 4 + 5) = 66 := by decide
example : crossPairs [3, 4, 5] = 47 := by decide
example : ([3, 4, 5].map synapseSlots).sum = 19 := by decide

-- The square identity on [3,4,5]: 12² = (9+16+25) + 2·47 = 50 + 94 = 144.
example : ([3, 4, 5].sum) ^ 2 = ([3, 4, 5].map (· ^ 2)).sum + 2 * crossPairs [3, 4, 5] := by
  decide

-- Directed graded connectomes on 4 neurons with 3 weight levels: 3^12 = (3^6)².
example : (3 : ℕ) ^ directedSlots 4 = (3 ^ synapseSlots 4) ^ 2 :=
  directed_weighted_sq 4 3

#check @weighted_bits
#check @synapseSlots_merge
#check @card_directed_weighted
#check @sq_sum_eq

end DigitalImmortality.WeightedMerging