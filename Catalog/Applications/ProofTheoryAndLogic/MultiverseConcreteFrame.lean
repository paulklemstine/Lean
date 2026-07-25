/-
# A Concrete Two-Branch Multiverse

This finite semantic model witnesses that the abstract multiverse interface is
consistent as a Kripke structure.  Its two universes represent a CH world and a
non-CH world; every world accesses both branches, while the sole background
sentence is true everywhere.  The construction is a semantic model of the
frame laws, not a construction of models of ZFC.
-/
import Applications.MultiverseTruthForcing.MultiverseSetTheory

namespace MultiverseSetTheory.Concrete

open Set

/-- The two-world frame: `true` is the CH branch and `false` the non-CH branch. -/
def twoBranchFrame : Frame Bool where
  Universe := Bool
  member := Set.univ
  satisfies := fun u φ => if φ then u = true else True
  background := {false}
  CH := true
  forces := fun _ _ => True
  background_sound := by
    intro u _ φ hφ
    simp only [Set.mem_singleton_iff] at hφ
    subst φ
    simp
  forcing_closed := by
    intro _ _ _ _
    trivial
  forces_refl := by
    intro _
    trivial
  forces_trans := by
    intro _ _ _ _ _
    trivial
  forces_confluent := by
    intro _ _ _ _ _
    exact ⟨false, trivial, trivial⟩
  ch_forceable := by
    intro _ _
    exact ⟨true, trivial, by simp⟩
  not_ch_forceable := by
    intro _ _
    exact ⟨false, trivial, by simp⟩

/-- The concrete frame is inhabited by an admitted universe. -/
theorem twoBranchFrame_inhabited : ∃ u, twoBranchFrame.member u := by
  exact ⟨false, Set.mem_univ false⟩

/-- In the concrete frame, every background sentence is multiverse-true, while
CH and its negation both fail to be multiverse-true and every world has both
forcing branches. -/
theorem twoBranchFrame_realizes_multiverse_independence :
    (∀ φ ∈ twoBranchFrame.background, MultiverseTrue twoBranchFrame φ) ∧
    ¬ MultiverseTrue twoBranchFrame twoBranchFrame.CH ∧
    ¬ (∀ v, twoBranchFrame.member v →
      ¬ twoBranchFrame.satisfies v twoBranchFrame.CH) ∧
    ∀ u, twoBranchFrame.member u →
      (∃ v, twoBranchFrame.member v ∧ twoBranchFrame.forces u v ∧
        twoBranchFrame.satisfies v twoBranchFrame.CH) ∧
      (∃ v, twoBranchFrame.member v ∧ twoBranchFrame.forces u v ∧
        ¬ twoBranchFrame.satisfies v twoBranchFrame.CH) := by
  exact multiverse_truth_and_ch_independence twoBranchFrame
    twoBranchFrame_inhabited

/-- Every admitted universe in the concrete frame is a common ground, because
accessibility is total. -/
theorem twoBranchFrame_every_world_commonGround
    (g : Admitted twoBranchFrame) : CommonGround twoBranchFrame g := by
  intro u
  trivial

/-- The false Boolean world, viewed as an admitted universe, is an explicit
common ground for the concrete multiverse. -/
def twoBranchGround : Admitted twoBranchFrame :=
  ⟨false, Set.mem_univ false⟩

/-- The designated Boolean ground accesses every admitted universe. -/
theorem twoBranchGround_is_commonGround :
    CommonGround twoBranchFrame twoBranchGround := by
  exact twoBranchFrame_every_world_commonGround twoBranchGround

/-- The concrete admitted-universe frame is globally directed.  This is derived
from its explicit common ground and the abstract confluence theorem. -/
theorem twoBranchFrame_globallyDirected :
    GloballyDirected twoBranchFrame := by
  exact globallyDirected_of_commonGround twoBranchFrame twoBranchGround
    twoBranchGround_is_commonGround

/-- In the concrete frame, any forcing-invariant predicate true at one world is
true at both worlds. -/
theorem twoBranchFrame_invariant_global {P : Admitted twoBranchFrame → Prop}
    (hinv : ForcingInvariant twoBranchFrame P)
    {u : Admitted twoBranchFrame} (hu : P u) :
    ∀ v, P v := by
  exact forcingInvariant_global_of_witness twoBranchFrame
    twoBranchFrame_globallyDirected hinv hu

/-- Invariant predicates can be propagated directly from the designated common
ground to every concrete universe. -/
theorem twoBranchFrame_invariant_from_ground
    {P : Admitted twoBranchFrame → Prop}
    (hinv : ForcingInvariant twoBranchFrame P) (hground : P twoBranchGround) :
    ∀ u, P u := by
  exact forcingInvariant_global_of_commonGround twoBranchFrame twoBranchGround
    twoBranchGround_is_commonGround hinv hground

/-- CH is not forcing-invariant in the concrete two-branch frame. -/
theorem twoBranchFrame_ch_not_invariant :
    ¬ ForcingInvariant twoBranchFrame
      (fun v => twoBranchFrame.satisfies v.1 twoBranchFrame.CH) := by
  intro hinv
  exact forcingInvariant_not_independent twoBranchFrame
    twoBranchFrame_globallyDirected hinv
    (ch_multiverseIndependent twoBranchFrame twoBranchFrame_inhabited)

/-- Every background sentence of the concrete frame is forcing-invariant. -/
theorem twoBranchFrame_background_invariant {φ : Bool}
    (hφ : φ ∈ twoBranchFrame.background) :
    ForcingInvariant twoBranchFrame
      (fun v => twoBranchFrame.satisfies v.1 φ) := by
  intro u v huv
  have htrue : MultiverseTrue twoBranchFrame φ :=
    background_is_multiverse_true twoBranchFrame hφ
  exact ⟨fun _ => htrue v.1 v.2, fun _ => htrue u.1 u.2⟩

/-- The admitted-universe accessibility relation of the concrete frame validates
`.2` for every predicate. -/
theorem twoBranchFrame_validates_dot_two
    {P : Admitted twoBranchFrame → Prop} {u : Admitted twoBranchFrame}
    (h : MultiverseAsymmetricForcing.Dia (AdmittedForces twoBranchFrame)
      (MultiverseAsymmetricForcing.Box (AdmittedForces twoBranchFrame) P) u) :
    MultiverseAsymmetricForcing.Box (AdmittedForces twoBranchFrame)
      (MultiverseAsymmetricForcing.Dia (AdmittedForces twoBranchFrame) P) u := by
  exact admitted_forcing_dot_two twoBranchFrame h

-- !-- Lab Notes -- !--
-- Hypothesis: a two-world total-accessibility frame is sufficient to witness
-- the joint consistency of background invariance and permanent CH branching.
-- Experiment: Bool supplies explicit CH and non-CH worlds, while total
-- accessibility makes both branches available above every ground.
-- Analysis: the construction realizes all abstract frame obligations and shows
-- that the global conclusions are not consequences of an empty universe class.
-- Critique: these worlds encode only the selected sentence values; they are not
-- internal models of ZFC and do not establish relative consistency of CH.
-- Synthesis: the abstract theorems specialize to a finite, inhabited model in
-- which background truth, CH contingency, forcing closure, and `.2` coexist.
-- !-- End Lab Notes -- !--

end MultiverseSetTheory.Concrete