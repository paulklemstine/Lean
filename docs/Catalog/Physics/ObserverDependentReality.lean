import Novelty.PhantomTopology

/-!
# Observer-dependent observable geometry

This file gives a precise topological model of observer-dependent geometry.  It
builds directly on the catalog's `PhantomTopology` and `consensus`: a perceptual
network is indexed by its finite collection of observer channels, and its
observable geometry is their consensus topology.

The result is a theorem about this mathematical model, not an assertion that
physical spacetime or biological neural networks satisfy the model's premises.
The explicit one-channel and two-channel networks show strict dependence on
network complexity: the former observes the lower-limit topology, whereas the
latter observes ordinary Euclidean geometry.
-/

open Phantom

namespace ObserverDependentReality

/-- A finite perceptual network of topological complexity `n`, using the
catalog's observer-family representation. -/
abbrev PerceptualNetwork (n : ℕ) (X : Type*) := PhantomTopology (Fin n) X

/-- The observable geometric state is the unanimous topology already defined by
`Phantom.consensus`. -/
def observableGeometry {n : ℕ} {X : Type*} (N : PerceptualNetwork n X) :
    TopologicalSpace X :=
  consensus N

/-- The one-channel network whose sole channel uses the lower-limit topology. -/
def oneChannelNetwork : PerceptualNetwork 1 ℝ := fun _ => lowerTop

/-- The two-channel network transports the catalog's Bool-indexed observers
along the standard equivalence `Fin 2 ≃ Bool`. -/
def twoChannelNetwork : PerceptualNetwork 2 ℝ := fun i =>
  observersℝ (finTwoEquiv i)

/-- A one-channel network has exactly its channel's geometry as observable
state. -/
theorem oneChannel_observable :
    observableGeometry oneChannelNetwork = lowerTop := by
  rw [observableGeometry, consensus]
  exact iSup_const

/-- A set is observable after adjoining one further channel precisely when it
is visible both to that channel and to every old channel. -/
theorem option_channel_isOpen_iff {ι X : Type*}
    (N : PhantomTopology ι X) (t : TopologicalSpace X) (U : Set X) :
    (consensus (fun i : Option ι => Option.elim i t N)).IsOpen U ↔
      t.IsOpen U ∧ (consensus N).IsOpen U := by
  rw [consensus_isOpen_iff, consensus_isOpen_iff]
  constructor
  · intro h
    exact ⟨h none, fun i => h (some i)⟩
  · rintro ⟨ht, hN⟩ i
    cases i with
    | none => exact ht
    | some i => exact hN i

/-- The two-channel network's observable geometry is the Euclidean topology.
This is the collapse from two one-sided resolutions to their two-sided
consensus. -/
theorem twoChannel_observable :
    observableGeometry twoChannelNetwork =
      (inferInstance : TopologicalSpace ℝ) := by
  change (⨆ i : Fin 2, observersℝ (finTwoEquiv i)) = _
  rw [finTwoEquiv.iSup_comp, ← consensus, consensus_pair_eq_standard]

/-- **Strict observer dependence.** Increasing topological complexity from one
channel to two changes the observable geometric state strictly.  In Mathlib's
order on topologies, `<` means that the left topology is strictly finer. -/
theorem observable_strictly_conditioned :
    observableGeometry oneChannelNetwork <
      observableGeometry twoChannelNetwork := by
  rw [oneChannel_observable, twoChannel_observable]
  apply lt_of_le_of_ne
  · rw [← consensus_pair_eq_standard, consensus]
    exact le_iSup observersℝ true
  · exact lowerTop_ne_standard

/-- Consequently, the same carrier `ℝ` admits finite perceptual networks of
complexities one and two with unequal observable geometric states. -/
theorem complexity_changes_observable :
    observableGeometry oneChannelNetwork ≠
      observableGeometry twoChannelNetwork :=
  ne_of_lt observable_strictly_conditioned

/-- The concrete collapse is nontrivial: the half-open interval `[0,1)` is
visible to the one-channel observer but ceases to be open in the two-channel
observable geometry. -/
theorem halfOpen_state_collapses :
    (observableGeometry oneChannelNetwork).IsOpen (Set.Ico (0 : ℝ) 1) ∧
      ¬(observableGeometry twoChannelNetwork).IsOpen (Set.Ico (0 : ℝ) 1) := by
  rw [oneChannel_observable, twoChannel_observable]
  exact ⟨lowerOpen_Ico, not_isOpen_Ico⟩

end ObserverDependentReality