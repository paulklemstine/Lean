import Mathlib
import Applications.Combinatorics.HypercubeNoStretch

/-!
# Finite packing and thickened transversals

This develops the finite combinatorial engine behind far-apart Erdős--Pósa
statements.  Objects carry finite vertex supports in a space with an integer-valued
distance.  A maximal family whose supports are pairwise farther than `d` controls
all remaining objects: every support meets the radius-`d` neighbourhood of the
union of the packed supports.  When supports have size at most `ℓ`, that union has
size at most `ℓ` times the packing number.

The formulation applies beyond graph cycles, including finite hypergraphs and
families of geometric or coding-theoretic objects.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
  1. The far-apart long-cycle theorem factors through a metric-hypergraph packing
     principle plus a bounded-anchor theorem for long cycles.
  2. The optimal `O(ℓ k log k)` centre bound follows from a multiscale hierarchy
     of bounded anchors whose scale depth is logarithmic in `k`.
  3. The linear neighbourhood radius persists for weighted graph metrics and
     coarse-Lipschitz graph maps, linking cycle packing to metric embeddings.
  4. Bounded-expansion graph classes have an `O(ℓ k)` centre bound because their
     anchor hierarchies have uniformly bounded branching.
  5. A homological extension controls far-apart one-dimensional persistence
     classes by thickened representatives in filtered cell complexes.
  6. Symmetric distance can be replaced by a symmetric proximity relation in the
     maximal-packing step; metric axioms enter only in constructing anchors.
  These targets were selected in response to the supplied arXiv abstract's
  simultaneous linear-radius and `O(ℓ k log k)` bounds.

Experiment (Experimenter):
  Supports were represented by finite vertex sets and separation by the assertion
  that every cross-pair of support vertices has distance greater than `d`.
  Inserting an uncovered object into an inclusion-maximal packing gives the key
  contradiction.  A union-cardinality induction supplies the quantitative bound.

Analysis (Analyst):
  Two layers separate cleanly.  Maximality alone proves domination, while bounded
  support size alone controls the size of the resulting centre set.  The imported
  hypercube no-stretch theorem supplies a concrete graph-metric source for the
  integer distance used here.

Critique (Critic):
  This is not the full long-cycle theorem: long cycles do not have bounded support,
  so the paper's structural reduction must first replace each long cycle by a
  bounded certificate.  Thus conjectures 2--5 remain true-but-hard rather than
  established here.  The attempted asymmetric insertion principle was false:
  separation from a new support to old supports need not imply the reverse, so a
  symmetry hypothesis was added.  The boundary case `P = ∅` is handled: maximality
  then forces the finite universe of objects to be empty.  No triangle inequality
  is silently assumed.

Synthesis (Principal Investigator):
  The resulting theorem identifies a reusable interface for the difficult graph
  theory: construct bounded anchors for cycles and prove that anchor-separation
  reflects cycle-separation.  The finite packing-to-thickened-cover argument then
  follows from the results below.
-- !-- End Lab Notes -- !--
-/

namespace FarApartErdosPosa

variable {V C : Type*} [DecidableEq V] [DecidableEq C]

/-- Two finite supports are farther than `d` when every cross-pair is farther
than `d`.  No metric axioms are required for the packing argument. -/
def SupportsFar (ρ : V → V → ℕ) (d : ℕ) (A B : Finset V) : Prop :=
  ∀ ⦃a⦄, a ∈ A → ∀ ⦃b⦄, b ∈ B → d < ρ a b

/-- A family of objects has pairwise far supports. -/
def IsFarPacking (ρ : V → V → ℕ) (d : ℕ) (support : C → Finset V)
    (P : Finset C) : Prop :=
  ∀ ⦃a⦄, a ∈ P → ∀ ⦃b⦄, b ∈ P → a ≠ b →
    SupportsFar ρ d (support a) (support b)

/-- The vertices lying within radius `d` of a set of centres. -/
def InBall (ρ : V → V → ℕ) (d : ℕ) (X : Finset V) (v : V) : Prop :=
  ∃ x ∈ X, ρ v x ≤ d

/-- A finite support meets the radius-`d` neighbourhood of `X`. -/
def MeetsBall (ρ : V → V → ℕ) (d : ℕ) (X A : Finset V) : Prop :=
  ∃ v ∈ A, InBall ρ d X v

/-- The centre set obtained by taking the union of all packed supports. -/
def packedSupport (support : C → Finset V) (P : Finset C) : Finset V :=
  P.biUnion support

omit [DecidableEq C] in
lemma packedSupport_card_le (support : C → Finset V) (P : Finset C) (ℓ : ℕ)
    (hsize : ∀ c ∈ P, (support c).card ≤ ℓ) :
    (packedSupport support P).card ≤ ℓ * P.card := by
  exact le_trans ( Finset.card_biUnion_le ) ( by simpa [ mul_comm ] using Finset.sum_le_sum hsize )

/-
Insertion preserves far packing precisely when the new support is far from
all old supports.
-/
omit [DecidableEq V] in
lemma isFarPacking_insert {ρ : V → V → ℕ} {d : ℕ} {support : C → Finset V}
    {P : Finset C} {c : C} (hsymm : ∀ x y, ρ x y = ρ y x)
    (hP : IsFarPacking ρ d support P)
    (hfar : ∀ p ∈ P, SupportsFar ρ d (support c) (support p)) :
    IsFarPacking ρ d support (insert c P) := by
  grind +locals

/-
**Maximal packing dominates.**  Every object outside an inclusion-maximal far
packing has a support vertex within distance `d` of the packed support union.
-/
theorem maximal_far_packing_meets_ball
    (ρ : V → V → ℕ) (hsymm : ∀ x y, ρ x y = ρ y x) (d : ℕ)
    (support : C → Finset V) (U P : Finset C)
    (hpack : IsFarPacking ρ d support P)
    (hmax : ∀ c ∈ U, c ∉ P → ¬ IsFarPacking ρ d support (insert c P)) :
    ∀ c ∈ U, c ∉ P → MeetsBall ρ d (packedSupport support P) (support c) := by
  grind +locals

/-
**Quantitative thickened transversal principle.**  A maximal packing of
bounded supports produces a bounded centre set meeting every unpacked support
within radius `d`.
-/
theorem bounded_maximal_packing_cover
    (ρ : V → V → ℕ) (hsymm : ∀ x y, ρ x y = ρ y x) (d ℓ : ℕ)
    (support : C → Finset V) (U P : Finset C)
    (hpack : IsFarPacking ρ d support P)
    (hmax : ∀ c ∈ U, c ∉ P → ¬ IsFarPacking ρ d support (insert c P))
    (hsize : ∀ c ∈ P, (support c).card ≤ ℓ) :
    ∃ X : Finset V, X.card ≤ ℓ * P.card ∧
      ∀ c ∈ U, c ∉ P → MeetsBall ρ d X (support c) := by
  refine' ⟨ _, packedSupport_card_le support P ℓ hsize, _ ⟩;
  apply maximal_far_packing_meets_ball ρ hsymm d support U P hpack hmax

/-
**Packing-cover dichotomy, maximal-family form.**  If a maximal far packing
has fewer than `k` members, every object in the finite universe meets a ball
around at most `ℓ(k-1)` centres.  Packed objects are covered because their own
nonempty supports are included among the centres.
-/
theorem far_packing_or_thickened_cover
    (ρ : V → V → ℕ) (hsymm : ∀ x y, ρ x y = ρ y x)
    (hrefl : ∀ x, ρ x x = 0) (d ℓ k : ℕ)
    (support : C → Finset V) (U P : Finset C)
    (hpack : IsFarPacking ρ d support P)
    (hmax : ∀ c ∈ U, c ∉ P → ¬ IsFarPacking ρ d support (insert c P))
    (hsize : ∀ c ∈ P, (support c).card ≤ ℓ)
    (hne : ∀ c ∈ P, (support c).Nonempty) (hsmall : P.card < k) :
    ∃ X : Finset V, X.card ≤ ℓ * (k - 1) ∧
      ∀ c ∈ U, MeetsBall ρ d X (support c) := by
  refine' ⟨ P.biUnion support, _, _ ⟩;
  · exact le_trans ( Finset.card_biUnion_le ) ( by simpa [ mul_comm ] using Finset.sum_le_sum hsize |> le_trans <| by simpa [ mul_comm ] using Nat.mul_le_mul_left ℓ ( Nat.le_sub_one_of_lt hsmall ) );
  · intro c hc; by_cases hcP : c ∈ P <;> simp_all +decide [ MeetsBall ] ;
    · exact Exists.elim ( hne c hcP ) fun v hv => ⟨ v, hv, v, Finset.mem_biUnion.mpr ⟨ c, hcP, hv ⟩, by simp +decide [ hrefl ] ⟩;
    · exact maximal_far_packing_meets_ball ρ hsymm d support U P hpack hmax c hc hcP

/-- A concrete two-object instance: singleton supports at `0` and `3` are
farther than radius `2` in the natural-number line. -/
example : IsFarPacking Nat.dist 2
    (fun b : Bool => if b then {0} else {3}) {true, false} := by
  intro a ha b hb hab
  fin_cases a <;> fin_cases b <;> simp_all [SupportsFar, Nat.dist]

/-- The no-stretching theorem gives a source of distance comparisons for
hypercube-valued labels, connecting this packing interface to graph metrics. -/
example {V : Type*} {G : SimpleGraph V} {k : ℕ}
    (label : V → HypercubeNoStretch.Cube k) (hG : G.Connected)
    (hlabel : ∀ {u v}, G.Adj u v → label u = label v ∨
      HypercubeNoStretch.HammingDist (label u) (label v) = 1) (u v : V) :
    (HypercubeNoStretch.hypercube k).dist (label u) (label v) ≤ G.dist u v := by
  exact HypercubeNoStretch.no_stretching hG hlabel u v

end FarApartErdosPosa