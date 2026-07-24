import Mathlib
import Algebra.HypercubeRegularity

/-!
# Rank windows avoiding weak Boolean cubes

A weak copy of the Boolean lattice `B_d` in a family of finite sets is an injective map
from subsets of `Fin d` which sends strict inclusion to strict inclusion.  The maximal
chain of `B_d` therefore forces `d+1` distinct ranks.  Consequently, any family supported
on only `d` consecutive ranks is weakly `B_d`-free.

For `d = 3`, this gives the basic three-middle-layer construction underlying lower bounds
for the extremal size of weakly `B₃`-free families.  A companion statement connects this
rank-window construction to the catalog's Hamming-cube model: its ambient Boolean cube
is regular of degree `n`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): rank is a universal obstruction to weak Boolean-lattice copies;
a weak `B_d` copy must cross at least `d+1` ranks, independently of all comparabilities
outside a maximal chain.  Ranked by expected impact, the six testable targets were:
(1) stability of asymptotically extremal weakly `B₃`-free families near a bounded union
of middle layers; (2) a strict asymptotic improvement over the three-layer construction;
(3) an entropy characterization of optimal Lubell-mass profiles; (4) a spectral certificate
for Boolean-cube avoidance; (5) a tropical rank potential detecting every weak cube; and
(6) a homological obstruction extracted from the order complex.  Targets (1)--(3) serve
named extremal-poset problems, while (4)--(6) bridge posets respectively with spectral
graph theory, tropical geometry, and topology.

Experiment (Experimenter): follow the canonical chain consisting of the first `k`
coordinates.  Strict inclusion under a weak embedding makes cardinality increase at each
step.  Summing these `d` strict increases contradicts confinement to an interval from `r`
to `r+d-1`.  The argument also handles `d=0`: the proposed rank interval is empty, so no
image family can satisfy rank confinement.

Analysis (Analyst): the obstruction uses only the graded structure of the target Boolean
lattice, not induced incomparability.  It therefore applies to weak copies and hence also
to strong copies.  The argument generalizes from middle layers to every consecutive rank
window of width `d`.

Critique (Critic): rank confinement is sufficient but far from necessary, so this does not
characterize extremal families or establish the improved constant sought in the paper.
The proof is non-vacuous: strict inclusion, cardinality growth, and a maximal-chain
induction all contribute.  The graph bridge records ambient degree but makes no unsupported spectral
claim.

Synthesis (Principal Investigator): the general rank-window theorem, its `B₃` specialization,
and hypercube regularity together isolate the classical baseline construction against
which any strict improvement must be measured.
-/

open Finset
open scoped Classical

namespace BooleanPoset

/-- A weak copy of `B_d` inside a family `F`: comparabilities of the source are preserved,
without requiring incomparable source elements to remain incomparable. -/
def ContainsWeakBooleanCube {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ∃ ι : Finset (Fin d) → Finset α,
    Function.Injective ι ∧
    (∀ A, ι A ∈ F) ∧
    ∀ ⦃A B : Finset (Fin d)⦄, A ⊂ B → ι A ⊂ ι B

/-- A family is weakly `B_d`-free. -/
def WeakBooleanCubeFree {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ¬ ContainsWeakBooleanCube d F

/-- A strong copy preserves and reflects strict inclusion. -/
def ContainsStrongBooleanCube {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ∃ ι : Finset (Fin d) → Finset α,
    Function.Injective ι ∧
    (∀ A, ι A ∈ F) ∧
    ∀ A B : Finset (Fin d), (A ⊂ B ↔ ι A ⊂ ι B)

/-- A family is strongly `B_d`-free. -/
def StrongBooleanCubeFree {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ¬ ContainsStrongBooleanCube d F

lemma strongCopy_is_weakCopy
    {α : Type*} [DecidableEq α] {d : ℕ} {F : Finset (Finset α)} :
    ContainsStrongBooleanCube d F → ContainsWeakBooleanCube d F := by
  intro h;
  exact ⟨ h.choose, h.choose_spec.1, h.choose_spec.2.1, fun A B hAB => h.choose_spec.2.2 A B |>.1 hAB ⟩

/-- The canonical maximal chain in `B_d`, represented by initial segments. -/
def initialSegment (d k : ℕ) : Finset (Fin d) :=
  Finset.univ.filter (fun i => (i : ℕ) < k)

lemma initialSegment_strictMono {d k : ℕ} (hk : k < d) :
    initialSegment d k ⊂ initialSegment d (k + 1) := by
  simp +decide [ initialSegment, Finset.ssubset_def, Finset.subset_iff ];
  exact ⟨ fun x hx => le_of_lt hx, ⟨ ⟨ k, hk ⟩, le_rfl, le_rfl ⟩ ⟩

lemma card_strictMono_of_weakCopy
    {α : Type*} [DecidableEq α] {d : ℕ}
    (ι : Finset (Fin d) → Finset α)
    (horder : ∀ ⦃A B : Finset (Fin d)⦄, A ⊂ B → ι A ⊂ ι B)
    {k : ℕ} (hk : k < d) :
    (ι (initialSegment d k)).card < (ι (initialSegment d (k + 1))).card := by
  exact Finset.card_lt_card ( horder ( initialSegment_strictMono hk ) )

/-
Along the canonical chain of a weak `B_d` copy, rank grows by at least the chain
index.
-/
lemma chain_rank_lower_bound
    {α : Type*} [DecidableEq α] {d : ℕ}
    (ι : Finset (Fin d) → Finset α)
    (horder : ∀ ⦃A B : Finset (Fin d)⦄, A ⊂ B → ι A ⊂ ι B) :
    ∀ k ≤ d, (ι (initialSegment d 0)).card + k ≤
      (ι (initialSegment d k)).card := by
  intro k hk; induction' k with k ih <;> simp_all +arith +decide;
  exact lt_of_le_of_lt ( ih hk.le ) ( Finset.card_lt_card ( horder ( initialSegment_strictMono hk ) ) )

/-
**Consecutive-rank obstruction.** A family supported on `d` consecutive ranks cannot
contain a weak copy of `B_d`.
-/
theorem rankWindow_weakBooleanCubeFree
    {α : Type*} [DecidableEq α] {d r : ℕ}
    (F : Finset (Finset α))
    (hrank : ∀ A ∈ F, r ≤ A.card ∧ A.card < r + d) :
    WeakBooleanCubeFree d F := by
  intro h;
  obtain ⟨ι, _, hι_F, hι_order⟩ := h;
  linarith [ hrank _ ( hι_F ( initialSegment d 0 ) ), hrank _ ( hι_F ( initialSegment d d ) ), chain_rank_lower_bound ι hι_order d le_rfl ]

/-
In particular, any family supported on three consecutive ranks is weakly `B₃`-free.
-/
theorem threeLayers_weakB3Free
    {α : Type*} [DecidableEq α] {r : ℕ} (F : Finset (Finset α))
    (hrank : ∀ A ∈ F, r ≤ A.card ∧ A.card < r + 3) :
    WeakBooleanCubeFree 3 F := by
  convert rankWindow_weakBooleanCubeFree F hrank using 1

/-
Three consecutive ranks also exclude strong copies of `B₃`.
-/
theorem threeLayers_strongB3Free
    {α : Type*} [DecidableEq α] {r : ℕ} (F : Finset (Finset α))
    (hrank : ∀ A ∈ F, r ≤ A.card ∧ A.card < r + 3) :
    StrongBooleanCubeFree 3 F := by
  exact fun h => threeLayers_weakB3Free F hrank ( strongCopy_is_weakCopy h )

/-
The three-rank `B₃`-free construction lives inside an `n`-regular Hamming cube.
This combines the poset rank obstruction with the catalog's combinatorial regularity
result for the same Boolean-cube model.
-/
theorem threeLayers_free_in_regularHypercube
    (n r : ℕ)
    (F : Finset (Finset (Fin n)))
    (hrank : ∀ A ∈ F, r ≤ A.card ∧ A.card < r + 3) :
    WeakBooleanCubeFree 3 F ∧
      ∀ A : Finset (Fin n),
        (Finset.univ.filter (fun B => DaisyCube.Adj A B)).card = n := by
  exact ⟨ threeLayers_weakB3Free F hrank, fun A => hypercube_regular n A ⟩

end BooleanPoset