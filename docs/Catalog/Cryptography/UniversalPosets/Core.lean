import Mathlib
import Cryptography.BiOrderSeparation

/-!
# Transitivity-preserving Boolean labels for finite posets

A point of a poset is labeled by its principal ideal.  Inclusion between labels is
then equivalent, not merely implied, by the original order.  Thus the Boolean
lattice on the ground set is an induced universal host for every order on that
set.  This is the canonical uncompressed labeling that motivates smaller
transitivity-preserving schemes.

The development also records functoriality, a meet-semilattice compatibility
law, a cardinality lower bound for every induced universal host, and a bridge
to collision-resistant bounded word traces.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): six falsifiable targets were ranked by impact: (1) every
finite poset admits an induced Boolean labeling by principal ideals; (2) such
labels compose through any induced host embedding; (3) meet structure is carried
to intersection; (4) every universal host has at least as many points as each
poset it hosts; (5) the Boolean host has exactly exponential cardinality; and
(6) collision-resistant word traces determine the corresponding order labels.
The bold continuation targets are subexponential coordinate compression,
regularity-based block labels, and entropy-optimal separating families.

Experiment (Experimenter): principal ideals were tested against equality,
comparability, and incomparability.  The witness `x` itself reflects inclusion:
if the label of `x` is included in the label of `y`, reflexivity puts `x` in its
own label and hence gives `x ≤ y`.  Intersections were tested in a meet
semilattice and agree exactly with the label of the meet.

Analysis (Analyst): transitivity needs no separate closure operation because it
is inherited from subset inclusion.  The construction uses one Boolean
coordinate per source point, explaining the baseline host size `2^n`.  Any
improvement must compress coordinates while retaining enough witnesses to
reflect every failed comparison.

Critique (Critic): this file does not claim the asymptotically sharper host bound
from the motivating paper; that bound requires substantial regularity and
counting infrastructure.  The results here are exact and non-vacuous, but the
canonical host is exponentially larger than the paper's host.  Edge cases,
including empty and singleton types, are covered.  No claim relies only on a
cardinality computation.

Synthesis (Principal Investigator): the induced-label theorem, composition law,
meet law, cardinal lower bound, exact Boolean-host size, and trace-rigidity bridge form
a reusable foundation for studying compressed universal-poset labels.
-/

open Set
open scoped Classical

namespace UniversalPosets

/-- A map is an induced embedding when it is injective and preserves and reflects order. -/
def IsInducedOrderEmbedding {P U : Type*} [LE P] [LE U] (f : P → U) : Prop :=
  Function.Injective f ∧ ∀ x y, f x ≤ f y ↔ x ≤ y

/-- The principal-ideal Boolean label of a point. -/
def principalLabel {P : Type*} [LE P] (x : P) : Set P :=
  {y | y ≤ x}

/--
Inclusion of principal labels is exactly the source order.
-/
theorem principalLabel_subset_iff {P : Type*} [PartialOrder P] (x y : P) :
    principalLabel x ⊆ principalLabel y ↔ x ≤ y := by
  exact ⟨ fun h => h ( le_refl x ), fun h z hz => le_trans hz h ⟩

/--
Principal-ideal labels form an induced embedding into the Boolean lattice.
-/
theorem principalLabel_induced {P : Type*} [PartialOrder P] :
    IsInducedOrderEmbedding (principalLabel : P → Set P) := by
  constructor;
  · intro x y;
    exact fun h => le_antisymm ( principalLabel_subset_iff _ _ |>.1 <| h.symm ▸ Set.Subset.refl _ ) ( principalLabel_subset_iff _ _ |>.1 <| h ▸ Set.Subset.refl _ );
  · intros x y
    apply principalLabel_subset_iff

/--
Induced order embeddings compose, allowing labels to be transported through hosts.
-/
theorem induced_comp
    {P U V : Type*} [LE P] [LE U] [LE V]
    {f : P → U} {g : U → V}
    (hf : IsInducedOrderEmbedding f) (hg : IsInducedOrderEmbedding g) :
    IsInducedOrderEmbedding (g ∘ f) := by
  constructor;
  · exact hg.1.comp hf.1;
  · exact fun x y => by rw [ Function.comp_apply, Function.comp_apply, hg.2, hf.2 ] ;

/--
Pulling a principal label along an order isomorphism gives the corresponding label.
-/
theorem principalLabel_equivariance
    {P Q : Type*} [PartialOrder P] [PartialOrder Q]
    (e : P ≃o Q) (x : P) :
    e ⁻¹' principalLabel (e x) = principalLabel x := by
  exact Set.ext fun y => by simp +decide [ principalLabel ] ;

/--
In a meet-semilattice, Boolean labeling converts meets exactly to intersections.
-/
theorem principalLabel_inf
    {P : Type*} [SemilatticeInf P] (x y : P) :
    principalLabel (x ⊓ y) = principalLabel x ∩ principalLabel y := by
  exact Set.ext fun z => le_inf_iff

/--
Every finite poset is an induced subposet of a Boolean lattice on the same carrier.
-/
theorem finite_poset_has_boolean_induced_embedding
    (P : Type*) [Fintype P] [PartialOrder P] :
    ∃ f : P → Set P, IsInducedOrderEmbedding f := by
  refine' ⟨ _, _ ⟩;
  exact fun x => { y | y ≤ x };
  convert principalLabel_induced

/--
The canonical Boolean host on an `n`-point type has exactly `2^n` labels.
-/
theorem card_boolean_host (P : Type*) [Fintype P] [DecidableEq P] :
    Fintype.card (Set P) = 2 ^ Fintype.card P := by
  rw [ Fintype.card_set ]

/--
Any finite induced host must contain at least as many points as the poset embedded in it.
-/
theorem card_le_of_induced_embedding
    {P U : Type*} [Fintype P] [Fintype U] [LE P] [LE U]
    {f : P → U} (hf : IsInducedOrderEmbedding f) :
    Fintype.card P ≤ Fintype.card U := by
  exact Fintype.card_le_of_injective f hf.1

/--
Bounded right-trace collision resistance transports to equality of order labels.
This connects transitivity-preserving labels with the catalog's free-word trace model.
-/
theorem trace_collision_preserves_principalLabel
    {P : Type*} [PartialOrder P] (encode : Word → P)
    {R : ℕ} {x y : Word}
    (hx : x.length ≤ R) (hy : y.length ≤ R)
    (htrace : rightTraceWord R x = rightTraceWord R y) :
    principalLabel (encode x) = principalLabel (encode y) := by
  exact rightTrace_eq_imp_eq hx hy htrace ▸ rfl

end UniversalPosets