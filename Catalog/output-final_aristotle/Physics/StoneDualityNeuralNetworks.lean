/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Stone duality for neural networks: activation patterns as a finite Boolean algebra

This file develops, from first principles, the finite-Boolean-algebra core of *Stone duality*
applied to a single fully-connected (ReLU-type) layer of a neural network, evaluated on a finite
sample of input points.

## Set-up

Fix a finite input sample `X` (a `Fintype`) and a layer of `n` neurons.  Evaluating the `n`
neurons at a point `x` and recording *which neurons are active* (pre-activation `> 0`) yields an
**activation pattern**
```
act x : Fin n → Bool.
```
The pattern-space `Fin n → Bool` is a finite Boolean algebra with `2 ^ n` elements — the *syntax*.
The realized patterns, `linearRegions act = image act univ`, are the distinct **linear regions**
cut out on the sample.  Each subset `S` of pattern-space determines a **decision region**
`decisionRegion act S = { x | act x ∈ S }`; the collection of all decision regions is the
Boolean algebra `decisionAlgebra act` — the *semantics*.

## Main results (a builder chain, each step using the previous)

* `linearRegions_card_le_pow`   — at most `2 ^ n` linear regions (bound by the syntax);
* `linearRegions_card_le_card`  — at most `|X|` linear regions (bound by the sample);
* `linearRegions_card_le_min`   — the combined bound (uses the two above);
* `decisionRegion_union / compl / ...` — `decisionRegion` is a Boolean-algebra homomorphism
  from pattern-space to subsets of `X` (Stone duality: syntax ↦ semantics);
* `decisionRegion_inter_linearRegions` — every decision region only depends on realized patterns;
* `decisionAlgebra_eq_image_powerset_linearRegions` — no decision region is lost by restricting
  attention to realized patterns;
* `decisionRegion_injOn_linearRegions` — distinct subsets of realized patterns give distinct
  regions (the atoms are the linear regions);
* `decisionAlgebra_card` — **Stone duality**: the decision algebra has exactly
  `2 ^ (number of linear regions)` elements;
* `decisionAlgebra_card_le` and `card_le_of_shatters` — consequences relating the size of the
  decision algebra, the sample size, and full shattering (VC-style).

## A concrete ReLU layer

`neuronActivation` builds `act` from explicit weights and biases, and
`sampleActivation` evaluates it on a finite sample, so every abstract theorem specializes to an
actual neural-network layer.
-/

namespace StoneDualityNN

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X] {n : ℕ}

/-- The **activation pattern** map is any assignment of a `Bool` vector (which neurons fire) to
each input point.  `linearRegions act` collects the realized patterns; its cardinality is the
number of distinct linear regions cut out on the sample. -/
def linearRegions (act : X → (Fin n → Bool)) : Finset (Fin n → Bool) :=
  Finset.image act Finset.univ

/-- The **decision region** selected by a set `S` of activation patterns: the points whose
pattern lies in `S`.  This is the semantic counterpart (a subset of the sample) of the syntactic
object `S`. -/
def decisionRegion (act : X → (Fin n → Bool)) (S : Finset (Fin n → Bool)) : Finset X :=
  Finset.univ.filter (fun x => act x ∈ S)

/-- The **decision algebra** of the layer: the Boolean algebra of all decision regions. -/
def decisionAlgebra (act : X → (Fin n → Bool)) : Finset (Finset X) :=
  (Finset.univ : Finset (Fin n → Bool)).powerset.image (decisionRegion act)

/-! ### Bounds on the number of linear regions -/

/-
There are at most `2 ^ n` linear regions: the number of realized activation patterns is
bounded by the size `2 ^ n` of pattern-space (the syntax).
-/
omit [DecidableEq X] in
theorem linearRegions_card_le_pow (act : X → (Fin n → Bool)) :
    (linearRegions act).card ≤ 2 ^ n := by
  exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ Finset.card_univ ] )

/-
There are at most `|X|` linear regions: the image of a function has at most as many elements
as its (finite) domain.
-/
omit [DecidableEq X] in
theorem linearRegions_card_le_card (act : X → (Fin n → Bool)) :
    (linearRegions act).card ≤ Fintype.card X := by
  exact Finset.card_image_le.trans_eq ( Finset.card_univ )

omit [DecidableEq X] in
/-- Combined bound: the number of linear regions is at most `min (2 ^ n) |X|`.  Uses the two
previous bounds. -/
theorem linearRegions_card_le_min (act : X → (Fin n → Bool)) :
    (linearRegions act).card ≤ min (2 ^ n) (Fintype.card X) :=
  le_min (linearRegions_card_le_pow act) (linearRegions_card_le_card act)

/-! ### `decisionRegion` is a Boolean-algebra homomorphism (Stone duality) -/

theorem decisionRegion_union (act : X → (Fin n → Bool)) (S T : Finset (Fin n → Bool)) :
    decisionRegion act (S ∪ T) = decisionRegion act S ∪ decisionRegion act T := by
  ext x; simp [decisionRegion]

theorem decisionRegion_inter (act : X → (Fin n → Bool)) (S T : Finset (Fin n → Bool)) :
    decisionRegion act (S ∩ T) = decisionRegion act S ∩ decisionRegion act T := by
  grind +locals

omit [DecidableEq X] in
theorem decisionRegion_empty (act : X → (Fin n → Bool)) :
    decisionRegion act ∅ = ∅ := by
  -- The decision region of the empty set is empty because there are no points whose activation pattern lies in the empty set.
  ext x
  simp [decisionRegion]

omit [DecidableEq X] in
theorem decisionRegion_univ (act : X → (Fin n → Bool)) :
    decisionRegion act Finset.univ = Finset.univ := by
  -- By definition of decisionRegion, we have decisionRegion act univ = Finset.univ.filter (fun x => act x ∈ univ).
  ext x
  simp [decisionRegion]

/-
Monotonicity of the syntax-to-semantics map.
-/
omit [DecidableEq X] in
theorem decisionRegion_subset (act : X → (Fin n → Bool)) {S T : Finset (Fin n → Bool)}
    (h : S ⊆ T) : decisionRegion act S ⊆ decisionRegion act T := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-! ### Decision regions only depend on realized patterns -/

/-
A decision region depends only on the intersection of `S` with the realized patterns: no point
carries an unrealized pattern.
-/
omit [DecidableEq X] in
theorem decisionRegion_inter_linearRegions (act : X → (Fin n → Bool))
    (S : Finset (Fin n → Bool)) :
    decisionRegion act (S ∩ linearRegions act) = decisionRegion act S := by
  ext x; simp [decisionRegion, linearRegions]

/-
Restricting the generating subsets to realized patterns loses no decision region:
the decision algebra is the image of the powerset of the *linear regions*.
-/
theorem decisionAlgebra_eq_image_powerset_linearRegions (act : X → (Fin n → Bool)) :
    decisionAlgebra act = (linearRegions act).powerset.image (decisionRegion act) := by
  ext S;
  constructor;
  · simp +decide [ decisionAlgebra ];
    intro T hT
    use T ∩ linearRegions act;
    exact ⟨ Finset.inter_subset_right, hT ▸ decisionRegion_inter_linearRegions act T ⟩;
  · exact fun h => Finset.mem_image.mpr <| by rcases Finset.mem_image.mp h with ⟨ T, hT, rfl ⟩ ; exact ⟨ T, Finset.mem_powerset.mpr <| Finset.subset_univ _, rfl ⟩ ;

/-! ### The atoms are the linear regions; Stone duality count -/

/-
Distinct subsets of the realized patterns give distinct decision regions.  Equivalently, the
atoms of the decision algebra are exactly the (nonempty) linear-region fibers.
-/
omit [DecidableEq X] in
theorem decisionRegion_injOn_linearRegions (act : X → (Fin n → Bool)) :
    Set.InjOn (decisionRegion act) ↑(linearRegions act).powerset := by
  intro S hS T hT h_eq; ext p; simp_all +decide [ Finset.ext_iff ] ;
  constructor <;> intro hp <;> contrapose! h_eq <;> simp_all +decide [ Finset.subset_iff, decisionRegion ];
  · obtain ⟨ x, hx ⟩ := Finset.mem_image.mp ( hS hp ) ; use x; aesop;
  · obtain ⟨ x, hx ⟩ := Finset.mem_image.mp ( hT hp ) ; use x; aesop;

/-
**Stone duality for a neural-network layer.**  The Boolean algebra of decision regions has
exactly `2 ^ (number of linear regions)` elements.  In Stone-duality terms: the decision algebra
is the clopen algebra of the finite discrete Stone space whose points (atoms) are the linear
regions, so its cardinality is `2 ^ (#atoms)`.
-/
theorem decisionAlgebra_card (act : X → (Fin n → Bool)) :
    (decisionAlgebra act).card = 2 ^ (linearRegions act).card := by
  rw [ decisionAlgebra_eq_image_powerset_linearRegions ];
  rw [ Finset.card_image_of_injOn ( decisionRegion_injOn_linearRegions act ) ] ; simp +decide ;

/-! ### Consequences -/

/-
The decision algebra has at most `2 ^ |X|` elements: it embeds in the powerset of the sample.
Uses `decisionAlgebra_card` and `linearRegions_card_le_card`.
-/
theorem decisionAlgebra_card_le (act : X → (Fin n → Bool)) :
    (decisionAlgebra act).card ≤ 2 ^ Fintype.card X := by
  rw [ decisionAlgebra_card ];
  exact Nat.pow_le_pow_right ( by decide ) ( linearRegions_card_le_card act )

/-- The layer **shatters** the sample `X` when every subset of `X` is a decision region. -/
def Shatters (act : X → (Fin n → Bool)) : Prop :=
  decisionAlgebra act = Finset.univ.powerset

/-
If the layer shatters the sample, then the number of linear regions equals the sample size,
hence (by the syntactic bound) `|X| ≤ 2 ^ n`.  This is a VC-style constraint: a layer of `n`
neurons can shatter a sample of size at most `2 ^ n`.
-/
theorem card_le_of_shatters (act : X → (Fin n → Bool)) (h : Shatters act) :
    Fintype.card X ≤ 2 ^ n := by
  have h_card : (linearRegions act).card = Fintype.card X := by
    have := congr_arg Finset.card h; norm_num [ Finset.card_univ, decisionAlgebra_card ] at this; aesop;
  exact h_card ▸ linearRegions_card_le_pow act

/-! ### A concrete ReLU layer -/

variable {d : ℕ}

/-- The activation pattern of a layer of `n` neurons with weight rows `W` and biases `b`,
evaluated at a point `x ∈ ℝ^d`: neuron `i` fires iff its pre-activation `⟨W i, x⟩ + b i` is
positive. -/
noncomputable def neuronActivation (W : Fin n → (Fin d → ℝ)) (b : Fin n → ℝ) (x : Fin d → ℝ) :
    Fin n → Bool :=
  fun i => decide (0 < (∑ j, W i j * x j) + b i)

/-- Evaluate the ReLU layer on a finite sample `pts : X → ℝ^d`, giving an activation-pattern map
to which all abstract results apply. -/
noncomputable def sampleActivation (W : Fin n → (Fin d → ℝ)) (b : Fin n → ℝ) (pts : X → (Fin d → ℝ)) :
    X → (Fin n → Bool) :=
  fun x => neuronActivation W b (pts x)

omit [DecidableEq X] in
/-- A concrete corollary: a ReLU layer of `n` neurons realizes at most `min (2 ^ n) |X|` linear
regions on any finite sample of inputs. -/
theorem sampleActivation_linearRegions_le
    (W : Fin n → (Fin d → ℝ)) (b : Fin n → ℝ) (pts : X → (Fin d → ℝ)) :
    (linearRegions (sampleActivation W b pts)).card ≤ min (2 ^ n) (Fintype.card X) :=
  linearRegions_card_le_min _

/-- The Stone-duality count specialized to a concrete ReLU layer: its decision algebra has exactly
`2 ^ (#linear regions realized on the sample)` elements. -/
theorem sampleActivation_decisionAlgebra_card
    (W : Fin n → (Fin d → ℝ)) (b : Fin n → ℝ) (pts : X → (Fin d → ℝ)) :
    (decisionAlgebra (sampleActivation W b pts)).card
      = 2 ^ (linearRegions (sampleActivation W b pts)).card :=
  decisionAlgebra_card _

end StoneDualityNN