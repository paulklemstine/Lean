import MachineLearning.CommittedLocalOracleZK

/-!
# Boundary of the composition theorem: both hypotheses are load-bearing

`MachineLearning/CommittedLocalOracleZK.lean` proves that

  *perfect hiding of unopened coordinates* + *perfect simulation of opened
  coordinates* ⟹ *perfect honest-verifier zero knowledge*.

This file shows that **neither hypothesis may be dropped**, by exhibiting two
explicit tiny committed local-oracle protocols:

* `leakyOracle` — a 1-query protocol whose *opened* coordinate is perfectly
  simulated (`leaky_simulates`) but whose commitment is the identity, so unopened
  coordinates leak (`leaky_not_hiding`). Its real and simulated transcript
  distributions differ maximally: `1` versus `0` (`leaky_hvzk_fails`).
* `padOracle` — a one-time-padded protocol, hence perfectly hiding
  (`pad_hides`), equipped with a simulator that guesses the wrong colour for the
  *opened* coordinate (`badSim_not_simulating`); again the transcript
  distributions differ, `1/2` versus `0` (`pad_hvzk_fails`).

Together with the positive theorem these delimit exactly what the composition
needs: hiding controls the unopened part, simulation the opened part, and each
failure is visible already at query complexity one.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two hypotheses of `perfect_hvzk` are independent;
neither implies the other, and each alone is insufficient.

Experiment (Experimenter): the two protocols below are the minimal witnesses —
two coordinates over `ZMod 2` for the hiding failure (one opened, one unopened,
so that the leak is invisible in the opened view), one coordinate for the
simulation failure. The probabilities are computed by direct evaluation of the
counting definitions.

Analysis (Analyst): the hiding counterexample shows the failure is *not*
detectable from the opened view alone — `leaky_simulates` holds — so the
composition theorem really is a statement about the commitment, not about the
query pattern.

Critique (Critic): both counterexamples are non-vacuous (all randomness spaces
are nonempty and the transcripts exhibited actually occur in the real
interaction, with probability `1` and `1/2` respectively).

Synthesis (PI): the composition theorem is tight.
-- !-- Lab Notes -- !--
-/

namespace MachineLearning.CommittedLocalOracleZKBoundary

open Finset MachineLearning.CommittedLocalOracleZK

/-! ## Hiding is necessary: a perfectly simulatable but leaking protocol -/

/-- A 1-query protocol on two coordinates over `ZMod 2` whose "commitment" is the
identity map: it publishes the whole proof string. The queried coordinate is
always coordinate `0`, whose value is constantly `0`; coordinate `1` is never
opened and carries the value `1`. -/
def leakyOracle : CommittedOracle (Fin 2) (ZMod 2) (Fin 2 → ZMod 2) Unit Unit Unit Unit where
  com u _ := u
  openInfo _ _ _ := ()
  Q _ := {0}
  qbound := 1
  query_card_le := by intro _; simp
  proof _ := fun i => if i = 0 then 0 else 1

/-- The simulator for `leakyOracle`: it writes `0` everywhere, which reproduces
the opened coordinate exactly. -/
def leakySim : Unit → Unit → Fin 2 → ZMod 2 := fun _ _ _ => 0

theorem leaky_view_eq (r : Unit) (u : Unit) :
    restrictTo (leakyOracle.Q r) (leakyOracle.proof u)
      = restrictTo (leakyOracle.Q r) (leakySim r u) := by
  rw [restrictTo_eq_iff]
  intro i hi
  have : i = 0 := by simpa [leakyOracle] using hi
  simp [this, leakyOracle, leakySim]

/-- **The opened coordinate is perfectly simulated.** -/
theorem leaky_simulates : PerfectlySimulatesOpened leakyOracle leakySim := by
  intro r t
  have hf : (univ.filter fun p : Unit => restrictTo (leakyOracle.Q r) (leakyOracle.proof p) = t)
      = (univ.filter fun s : Unit => restrictTo (leakyOracle.Q r) (leakySim r s) = t) := by
    refine Finset.filter_congr fun u _ => ?_
    rw [leaky_view_eq r u]
  rw [hf]

/-- **But the unopened coordinate is not hidden at all.** -/
theorem leaky_not_hiding : ¬ PerfectlyHidesUnopened leakyOracle := by
  intro h
  obtain ⟨e, he⟩ := h {0} (leakyOracle.proof ()) (fun _ => 0) (by
    intro i hi
    have : i = 0 := by simpa using hi
    simp [this, leakyOracle])
  have h1 := (he ()).1
  have h2 : leakyOracle.proof () 1 = (fun _ : Fin 2 => (0 : ZMod 2)) 1 := congrFun h1 1
  simp [leakyOracle] at h2

/-- **Perfect HVZK fails**: the honest transcript occurs with probability `1` in
the real interaction and with probability `0` in the simulation. -/
theorem leaky_hvzk_fails :
    realProb leakyOracle (realTranscript leakyOracle () () ()) = 1 ∧
      simProb leakyOracle leakySim (realTranscript leakyOracle () () ()) = 0 := by
  constructor
  · have h : realCount leakyOracle (realTranscript leakyOracle () () ()) = 1 := by decide
    simp [realProb, h]
  · have h : simCount leakyOracle leakySim (realTranscript leakyOracle () () ()) = 0 := by decide
    simp [simProb, h]

theorem leaky_hvzk_ne :
    realProb leakyOracle (realTranscript leakyOracle () () ())
      ≠ simProb leakyOracle leakySim (realTranscript leakyOracle () () ()) := by
  rw [leaky_hvzk_fails.1, leaky_hvzk_fails.2]
  norm_num

/-! ## Simulation is necessary: a perfectly hiding protocol with a wrong simulator -/

/-- A one-coordinate one-time-padded protocol whose proof string is constantly
`0`. -/
def padOracle : CommittedOracle (Fin 1) (ZMod 2) (Fin 1 → ZMod 2) (Fin 1 → Option (ZMod 2))
    (Fin 1 → ZMod 2) Unit Unit :=
  otpOracle (fun _ _ => 0) (fun _ => {0}) 1 (by intro _; simp)

/-- A simulator that opens the *wrong* value at the queried coordinate. -/
def badSim : Unit → Unit → Fin 1 → ZMod 2 := fun _ _ _ => 1

/-- The one-time pad hides all unopened coordinates. -/
theorem pad_hides : PerfectlyHidesUnopened (Rc := Fin 1 → ZMod 2) padOracle :=
  otpOracle_hides _ _ _ _

/-- **The opened coordinate is not simulated.** -/
theorem badSim_not_simulating : ¬ PerfectlySimulatesOpened padOracle badSim := by
  intro h
  have h0 := h () (restrictTo (padOracle.Q ()) (padOracle.proof ()))
  revert h0
  decide

/-- **Perfect HVZK fails**: an honest transcript occurring with probability `1/2`
is never produced by the simulator. -/
theorem pad_hvzk_fails :
    realProb padOracle (realTranscript padOracle () (fun _ => 0) ()) = 1 / 2 ∧
      simProb padOracle badSim (realTranscript padOracle () (fun _ => 0) ()) = 0 := by
  constructor
  · have h : realCount padOracle (realTranscript padOracle () (fun _ => 0) ()) = 1 := by decide
    have hc : Fintype.card (Fin 1 → ZMod 2) = 2 := by decide
    simp [realProb, h, hc]
  · have h : simCount padOracle badSim (realTranscript padOracle () (fun _ => 0) ()) = 0 := by
      decide
    simp [simProb, h]

theorem pad_hvzk_ne :
    realProb padOracle (realTranscript padOracle () (fun _ => 0) ())
      ≠ simProb padOracle badSim (realTranscript padOracle () (fun _ => 0) ()) := by
  rw [pad_hvzk_fails.1, pad_hvzk_fails.2]
  norm_num

/-! ## Sharp 2-transitivity is necessary: cyclic rerandomization leaks

In the 3-colouring protocol the prover rerandomizes its colouring with a uniform
element of the *symmetric* group `S₃`. Replacing `S₃` by the cyclic subgroup of
colour shifts (order 3, still transitive on colours!) destroys zero knowledge:
the opened pair then determines the colour *difference* along the challenged
edge. We prove this as a genuine impossibility statement: **no** simulator
whatsoever — with arbitrary randomness space — can simulate the shift-based
protocol for both of two colourings simultaneously, so no witness-independent
simulator exists. -/

/-- A two-vertex, one-edge instance queried at both endpoints, where the prover
rerandomizes its colouring by a *cyclic shift* `c ↦ c + d` instead of a full
colour permutation. -/
def shiftOracle (c : Fin 2 → ZMod 3) :
    CommittedOracle (Fin 2) (ZMod 3) (Fin 2 → ZMod 3) (Fin 2 → Option (ZMod 3))
      (Fin 2 → ZMod 3) Unit (ZMod 3) :=
  otpOracle (fun d v => c v + d) (fun _ => {0, 1}) 2
    (by intro _; exact le_trans (card_insert_le _ _) (by simp))

/-- The proper colouring `(0, 1)` of the single edge. -/
def colA : Fin 2 → ZMod 3 := fun v => if v = 0 then 0 else 1

/-- The proper colouring `(0, 2)` of the single edge. -/
def colB : Fin 2 → ZMod 3 := fun v => if v = 0 then 0 else 2

/-- The opened view targeted in the separation: colour `0` on the first endpoint
and `1` on the second. -/
def viewAB : Fin 2 → Option (ZMod 3) := fun v => if v = 0 then some 0 else some 1

/-- **Cyclic rerandomization is not simulatable.** No simulator (over any finite,
nonempty randomness space) perfectly simulates the opened view of the
shift-randomized protocol for both proper colourings `colA` and `colB`: the view
`(0,1)` has probability `1/3` under `colA` and `0` under `colB`. Hence the
zero-knowledge property of the 3-colouring protocol genuinely uses the *sharply
2-transitive* action of the full symmetric group, not mere transitivity. -/
theorem cyclic_not_simulatable {S : Type} [Fintype S] [Nonempty S]
    (sim : Unit → S → Fin 2 → ZMod 3) :
    ¬ (PerfectlySimulatesOpened (shiftOracle colA) sim ∧
        PerfectlySimulatesOpened (shiftOracle colB) sim) := by
  rintro ⟨h1, h2⟩
  have e1 := h1 () viewAB
  have e2 := h2 () viewAB
  have c1 : (univ.filter fun d : ZMod 3 =>
      restrictTo ((shiftOracle colA).Q ()) ((shiftOracle colA).proof d) = viewAB).card = 1 := by
    decide
  have c2 : (univ.filter fun d : ZMod 3 =>
      restrictTo ((shiftOracle colB).Q ()) ((shiftOracle colB).proof d) = viewAB).card = 0 := by
    decide
  have hQ : (shiftOracle colB).Q () = (shiftOracle colA).Q () := rfl
  rw [c1] at e1
  rw [c2, hQ] at e2
  have hcard3 : Fintype.card (ZMod 3) = 3 := ZMod.card 3
  have hSpos : 0 < Fintype.card S := Fintype.card_pos
  rw [hcard3] at e1 e2
  omega

end MachineLearning.CommittedLocalOracleZKBoundary