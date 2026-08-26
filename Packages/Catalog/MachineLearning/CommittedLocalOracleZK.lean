import Mathlib

/-!
# Committed local-oracle protocols: composing PCP locality with commitment hiding

A *committed local-oracle protocol* is the standard "PCP + commitment" compiler:

* the prover holds a (randomized) proof string `proof p : I → A` indexed by the
  coordinate set `I` over an alphabet `A`;
* it commits to the whole string with commitment randomness `ρ : Rc`, producing a
  commitment message `com (proof p) ρ : C`;
* the honest verifier tosses coins `r : Rv` and queries the **constant-size** set
  of coordinates `Q r` (`(Q r).card ≤ qbound`);
* the prover answers by revealing the queried symbols together with the opening
  data `openInfo (proof p) ρ (Q r) : O`.

The resulting *transcript* is
`(commitment, verifier coins, opened symbols, opening data)`,
where the "opened symbols" are recorded as the partial function
`restrictTo (Q r) (proof p) : I → Option A`, which is `none` off the query set —
so the transcript literally contains no information about unopened coordinates
beyond what the commitment and the openings carry.

## Main result

`perfect_hvzk` : if the commitment scheme

* **perfectly hides unopened coordinates** (`PerfectlyHidesUnopened`): for any two
  strings agreeing on a set `T` there is a bijection of the commitment randomness
  carrying the commitment *and the openings on `T`* of one to those of the other;
* and the local view of the queried symbols is **perfectly simulatable**
  (`PerfectlySimulatesOpened`): for every fixing of the verifier's coins the
  distribution of the opened symbols is reproduced exactly by a simulator that
  does not see the witness,

then the *full* transcript distribution of the real constant-query interaction
equals the simulator's transcript distribution exactly: the protocol is
**perfect honest-verifier zero knowledge**.

The proof is a genuine two-level distributional argument: the hiding hypothesis
shows that the number of commitment randomnesses consistent with a given
(commitment, opening) pair depends on the message *only through its restriction
to the opened set* (`fiberCount_congr`), and the local-simulation hypothesis then
matches the two counting measures fibre by fibre (`realCount_mul_card_sim`).

We also supply a nontrivial instance: the coordinate-wise one-time-pad
commitment over an arbitrary finite abelian group perfectly hides unopened
coordinates (`otpOracle_hides`), while opening a coordinate genuinely reveals the
pad there, so the openings are a real part of the transcript.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "hiding of the unopened part" and "simulatability of
the opened part" are *independent* resources, and their composition should be
exact (not merely statistical), because the transcript factorizes over the fibres
of the restriction map `u ↦ u|_{Q r}`.

Experiment (Experimenter): formalized both resources as finite counting
statements (no measure theory needed), and reduced the transcript count to
`∑_p [proof p |_{Q r} = t] · fiberCount (proof p)` (`realCount_eq_sum`). The
hiding hypothesis makes `fiberCount` constant on a fibre; the simulation
hypothesis equates fibre sizes after cross-multiplying by the two
randomness-space cardinalities.

Analysis (Analyst): the cross-multiplied form of `PerfectlySimulatesOpened` is
essential — dividing by `|P|`, `|S|` inside ℕ would be lossy, and the ℚ-valued
statement follows at the end in one step. A subtle corner case is the *empty
fibre*: there we must transport emptiness across the hypothesis, which needs
`0 < |P|` (`Nonempty P`). Note the commitment- and verifier-randomness spaces are
*not* assumed nonempty: if either is empty both distributions are identically
zero and the theorem still holds (the `div` convention `x/0 = 0` is used).

Critique (Critic): hiding is stated as an explicit bijection of the randomness
space rather than as equality of pushforward measures. These are equivalent for
finite randomness spaces up to the counting lemma proved here
(`fiberCount_congr`), and the bijection form is what every perfectly hiding
scheme actually provides — witness the one-time-pad instance, which is proved,
not assumed.

Synthesis (PI): perfect HVZK of the compiled protocol is a *composition theorem*:
hiding controls the vertical (commitment) direction, simulation the horizontal
(opened symbols) direction, and constant query complexity is what makes the
horizontal direction small enough to simulate at all.
-- !-- Lab Notes -- !--
-/

namespace MachineLearning.CommittedLocalOracleZK

open Finset

variable {I A C O Rc Rv P S : Type*}

/-- The partial view of a proof string obtained by opening exactly the
coordinates in `T`: `none` outside `T`. -/
def restrictTo [DecidableEq I] (T : Finset I) (f : I → A) : I → Option A :=
  fun i => if i ∈ T then some (f i) else none

theorem restrictTo_eq_iff [DecidableEq I] (T : Finset I) (f g : I → A) :
    restrictTo T f = restrictTo T g ↔ ∀ i ∈ T, f i = g i := by
  constructor
  · intro h i hi
    have := congrFun h i
    simp [restrictTo, hi] at this
    exact this
  · intro h
    funext i
    by_cases hi : i ∈ T
    · simp [restrictTo, hi, h i hi]
    · simp [restrictTo, hi]

/-- Only opened coordinates carry information in a restricted view. -/
theorem restrictTo_isSome_subset [DecidableEq I] (T : Finset I) (f : I → A) {i : I}
    (hi : (restrictTo T f i).isSome) : i ∈ T := by
  by_contra h
  simp [restrictTo, h] at hi

/-- A **committed local-oracle protocol**: a commitment scheme (`com`, `openInfo`)
applied to a randomized proof string (`proof`), queried at the constant-size
coordinate sets `Q r` chosen by the verifier's coins. -/
structure CommittedOracle (I A C O Rc Rv P : Type*) [DecidableEq I] where
  /-- The commitment message sent by the prover. -/
  com : (I → A) → Rc → C
  /-- The opening data revealed for the queried set. -/
  openInfo : (I → A) → Rc → Finset I → O
  /-- The coordinates queried on verifier randomness `r`. -/
  Q : Rv → Finset I
  /-- The query-complexity bound. -/
  qbound : ℕ
  /-- Constant query complexity. -/
  query_card_le : ∀ r, (Q r).card ≤ qbound
  /-- The prover's randomized proof string. -/
  proof : P → I → A

variable [DecidableEq I]

/-- The transcript of one execution: commitment, verifier coins, opened symbols
(as a partial assignment), and opening data. -/
abbrev Transcript (I A C O Rv : Type*) := C × Rv × (I → Option A) × O

/-- The honest transcript produced on prover randomness `p`, commitment
randomness `ρ` and verifier coins `r`. -/
def realTranscript (Pr : CommittedOracle I A C O Rc Rv P) (p : P) (ρ : Rc) (r : Rv) :
    Transcript I A C O Rv :=
  (Pr.com (Pr.proof p) ρ, r, restrictTo (Pr.Q r) (Pr.proof p),
    Pr.openInfo (Pr.proof p) ρ (Pr.Q r))

/-- The transcript produced by a simulator which, on coins `r` and its own
randomness `s`, invents a local assignment `sim r s` and honestly commits to and
opens it. -/
def simTranscript (Pr : CommittedOracle I A C O Rc Rv P) (sim : Rv → S → I → A)
    (s : S) (ρ : Rc) (r : Rv) : Transcript I A C O Rv :=
  (Pr.com (sim r s) ρ, r, restrictTo (Pr.Q r) (sim r s), Pr.openInfo (sim r s) ρ (Pr.Q r))

/-- **Constant-query locality of the transcript.** At most `qbound` symbols of the
proof string appear in a transcript, no matter how long the proof string is. -/
theorem transcript_opened_card_le [Fintype I] (Pr : CommittedOracle I A C O Rc Rv P)
    (p : P) (r : Rv) :
    (univ.filter fun i => (restrictTo (Pr.Q r) (Pr.proof p) i).isSome).card ≤ Pr.qbound := by
  refine le_trans (card_le_card ?_) (Pr.query_card_le r)
  intro i hi
  exact restrictTo_isSome_subset _ _ (mem_filter.mp hi).2

section Counting

variable [Fintype I] [Fintype Rc] [Fintype Rv] [Fintype P] [Fintype S]
variable [DecidableEq A] [DecidableEq C] [DecidableEq O] [DecidableEq Rv]

/-- Number of commitment randomnesses consistent with a given commitment `c` and
opening data `o` for the message `u` opened on `T`. -/
def fiberCount (Pr : CommittedOracle I A C O Rc Rv P) (u : I → A) (T : Finset I)
    (c : C) (o : O) : ℕ :=
  (univ.filter fun ρ => Pr.com u ρ = c ∧ Pr.openInfo u ρ T = o).card

/-- **Perfect hiding of unopened coordinates.** If two proof strings agree on the
opened set `T`, a bijection of the commitment randomness carries the commitment
*and* the opening data on `T` of the first to those of the second. -/
def PerfectlyHidesUnopened (Pr : CommittedOracle I A C O Rc Rv P) : Prop :=
  ∀ (T : Finset I) (u v : I → A), (∀ i ∈ T, u i = v i) →
    ∃ e : Rc ≃ Rc, ∀ ρ, Pr.com u ρ = Pr.com v (e ρ) ∧
      Pr.openInfo u ρ T = Pr.openInfo v (e ρ) T

/-- **Perfect simulation of the opened coordinates.** For every fixing of the
verifier's coins, the distribution of the opened symbols under the prover's
randomness is exactly reproduced by the simulator (stated by cross-multiplying
the two uniform distributions, so as to stay inside ℕ). -/
def PerfectlySimulatesOpened (Pr : CommittedOracle I A C O Rc Rv P)
    (sim : Rv → S → I → A) : Prop :=
  ∀ (r : Rv) (t : I → Option A),
    (univ.filter fun p : P => restrictTo (Pr.Q r) (Pr.proof p) = t).card * Fintype.card S
      = (univ.filter fun s : S => restrictTo (Pr.Q r) (sim r s) = t).card * Fintype.card P

omit [Fintype Rc] [Fintype Rv] [DecidableEq C] [DecidableEq O] [DecidableEq Rv] in
/-- **A structural criterion for perfect simulation.** If for every fixing of the
verifier's coins there is a *bijection* `Φ r` from the prover's randomness to the
simulator's randomness that preserves the opened view, then the opened
coordinates are perfectly simulated. This is the abstract form of "the prover's
rerandomization group acts sharply transitively on admissible local views". -/
theorem perfectlySimulates_of_bijection {Pr : CommittedOracle I A C O Rc Rv P}
    {sim : Rv → S → I → A} (Φ : Rv → P → S) (hbij : ∀ r, Function.Bijective (Φ r))
    (hview : ∀ r p, restrictTo (Pr.Q r) (Pr.proof p) = restrictTo (Pr.Q r) (sim r (Φ r p))) :
    PerfectlySimulatesOpened Pr sim := by
  intro r t
  have hcards : Fintype.card P = Fintype.card S := Fintype.card_of_bijective (hbij r)
  have hfib : (univ.filter fun p : P => restrictTo (Pr.Q r) (Pr.proof p) = t).card
      = (univ.filter fun s : S => restrictTo (Pr.Q r) (sim r s) = t).card := by
    refine Finset.card_bij (fun p _ => Φ r p) ?_ ?_ ?_
    · intro p hp
      rw [mem_filter] at hp ⊢
      exact ⟨mem_univ _, by rw [← hview r p]; exact hp.2⟩
    · intro p _ q _ h
      exact (hbij r).1 h
    · intro s hs
      obtain ⟨p, hp⟩ := (hbij r).2 s
      refine ⟨p, ?_, hp⟩
      rw [mem_filter] at hs ⊢
      exact ⟨mem_univ _, by rw [hview r p, hp]; exact hs.2⟩
  rw [hfib, hcards]

/-- Number of random executions producing a given transcript, in the real
interaction. -/
def realCount (Pr : CommittedOracle I A C O Rc Rv P) (τ : Transcript I A C O Rv) : ℕ :=
  (univ.filter fun x : P × Rc × Rv => realTranscript Pr x.1 x.2.1 x.2.2 = τ).card

/-- Number of random executions producing a given transcript, in the simulation. -/
def simCount (Pr : CommittedOracle I A C O Rc Rv P) (sim : Rv → S → I → A)
    (τ : Transcript I A C O Rv) : ℕ :=
  (univ.filter fun x : S × Rc × Rv => simTranscript Pr sim x.1 x.2.1 x.2.2 = τ).card

/-- The real transcript distribution (uniform prover, commitment and verifier
randomness). -/
def realProb (Pr : CommittedOracle I A C O Rc Rv P) (τ : Transcript I A C O Rv) : ℚ :=
  (realCount Pr τ : ℚ) / (Fintype.card P * Fintype.card Rc * Fintype.card Rv)

/-- The simulated transcript distribution. -/
def simProb (Pr : CommittedOracle I A C O Rc Rv P) (sim : Rv → S → I → A)
    (τ : Transcript I A C O Rv) : ℚ :=
  (simCount Pr sim τ : ℚ) / (Fintype.card S * Fintype.card Rc * Fintype.card Rv)

omit [Fintype I] [Fintype Rv] [Fintype P] [DecidableEq A] [DecidableEq Rv] in
/-- **Hiding ⟹ the commitment fibre depends only on the opened part of the
message.** -/
theorem fiberCount_congr {Pr : CommittedOracle I A C O Rc Rv P}
    (hH : PerfectlyHidesUnopened Pr) (T : Finset I) (u v : I → A)
    (huv : ∀ i ∈ T, u i = v i) (c : C) (o : O) :
    fiberCount Pr u T c o = fiberCount Pr v T c o := by
  obtain ⟨e, he⟩ := hH T u v huv
  refine Finset.card_bij' (fun ρ _ => e ρ) (fun σ _ => e.symm σ) ?_ ?_ ?_ ?_
  · intro ρ hρ
    rw [mem_filter] at hρ ⊢
    obtain ⟨hc, ho⟩ := hρ.2
    exact ⟨mem_univ _, by rw [← (he ρ).1, hc], by rw [← (he ρ).2, ho]⟩
  · intro σ hσ
    rw [mem_filter] at hσ ⊢
    obtain ⟨hc, ho⟩ := hσ.2
    refine ⟨mem_univ _, ?_, ?_⟩
    · rw [(he (e.symm σ)).1, Equiv.apply_symm_apply, hc]
    · rw [(he (e.symm σ)).2, Equiv.apply_symm_apply, ho]
  · intro ρ _; simp
  · intro σ _; simp

/-- Fibrewise decomposition of the real transcript count. -/
theorem realCount_eq_sum (Pr : CommittedOracle I A C O Rc Rv P)
    (c : C) (r₀ : Rv) (t : I → Option A) (o : O) :
    realCount Pr (c, r₀, t, o)
      = ∑ p : P, if restrictTo (Pr.Q r₀) (Pr.proof p) = t then
          fiberCount Pr (Pr.proof p) (Pr.Q r₀) c o else 0 := by
  rw [realCount, Finset.card_filter, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun p _ => ?_
  rw [Fintype.sum_prod_type]
  have hswap : ∀ ρ : Rc,
      (∑ r : Rv, if realTranscript Pr p ρ r = (c, r₀, t, o) then 1 else 0)
        = if Pr.com (Pr.proof p) ρ = c ∧ restrictTo (Pr.Q r₀) (Pr.proof p) = t ∧
            Pr.openInfo (Pr.proof p) ρ (Pr.Q r₀) = o then 1 else 0 := by
    intro ρ
    rw [Finset.sum_eq_single_of_mem r₀ (mem_univ _)]
    · simp [realTranscript, Prod.ext_iff]
    · intro r _ hr
      simp only [realTranscript, Prod.mk.injEq]
      rw [if_neg]
      rintro ⟨-, rfl, -⟩
      exact hr rfl
  simp only [hswap]
  by_cases ht : restrictTo (Pr.Q r₀) (Pr.proof p) = t
  · rw [if_pos ht, fiberCount, Finset.card_filter]
    exact Finset.sum_congr rfl fun ρ _ => by simp [ht]
  · rw [if_neg ht]
    exact Finset.sum_eq_zero fun ρ _ => by simp [ht]

omit [Fintype P] in
/-- Fibrewise decomposition of the simulated transcript count. -/
theorem simCount_eq_sum (Pr : CommittedOracle I A C O Rc Rv P) (sim : Rv → S → I → A)
    (c : C) (r₀ : Rv) (t : I → Option A) (o : O) :
    simCount Pr sim (c, r₀, t, o)
      = ∑ s : S, if restrictTo (Pr.Q r₀) (sim r₀ s) = t then
          fiberCount Pr (sim r₀ s) (Pr.Q r₀) c o else 0 := by
  rw [simCount, Finset.card_filter, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun s _ => ?_
  rw [Fintype.sum_prod_type]
  have hswap : ∀ ρ : Rc,
      (∑ r : Rv, if simTranscript Pr sim s ρ r = (c, r₀, t, o) then 1 else 0)
        = if Pr.com (sim r₀ s) ρ = c ∧ restrictTo (Pr.Q r₀) (sim r₀ s) = t ∧
            Pr.openInfo (sim r₀ s) ρ (Pr.Q r₀) = o then 1 else 0 := by
    intro ρ
    rw [Finset.sum_eq_single_of_mem r₀ (mem_univ _)]
    · simp [simTranscript, Prod.ext_iff]
    · intro r _ hr
      simp only [simTranscript, Prod.mk.injEq]
      rw [if_neg]
      rintro ⟨-, rfl, -⟩
      exact hr rfl
  simp only [hswap]
  by_cases ht : restrictTo (Pr.Q r₀) (sim r₀ s) = t
  · rw [if_pos ht, fiberCount, Finset.card_filter]
    exact Finset.sum_congr rfl fun ρ _ => by simp [ht]
  · rw [if_neg ht]
    exact Finset.sum_eq_zero fun ρ _ => by simp [ht]

/-- **The composition theorem, in counting form.** Hiding of the unopened
coordinates plus perfect simulation of the opened ones equate the two transcript
counting measures (cross-multiplied by the randomness-space sizes). -/
theorem realCount_mul_card_sim [Nonempty P] {Pr : CommittedOracle I A C O Rc Rv P}
    {sim : Rv → S → I → A} (hH : PerfectlyHidesUnopened Pr)
    (hS : PerfectlySimulatesOpened Pr sim) (τ : Transcript I A C O Rv) :
    realCount Pr τ * Fintype.card S = simCount Pr sim τ * Fintype.card P := by
  obtain ⟨c, r₀, t, o⟩ := τ
  rw [realCount_eq_sum, simCount_eq_sum, ← Finset.sum_filter, ← Finset.sum_filter]
  have hcard := hS r₀ t
  rcases Finset.eq_empty_or_nonempty
      (univ.filter fun p : P => restrictTo (Pr.Q r₀) (Pr.proof p) = t) with hemp | ⟨p₀, hp₀⟩
  · rw [hemp] at hcard ⊢
    have hPpos : 0 < Fintype.card P := Fintype.card_pos
    have hz : (univ.filter fun s : S => restrictTo (Pr.Q r₀) (sim r₀ s) = t).card = 0 := by
      simp only [Finset.card_empty, zero_mul] at hcard
      rcases Nat.mul_eq_zero.mp hcard.symm with h | h
      · exact h
      · omega
    rw [Finset.card_eq_zero.mp hz]
    simp
  · have ht0 : restrictTo (Pr.Q r₀) (Pr.proof p₀) = t := (mem_filter.mp hp₀).2
    set N := fiberCount Pr (Pr.proof p₀) (Pr.Q r₀) c o with hN
    have hreal : ∑ p ∈ univ.filter (fun p : P => restrictTo (Pr.Q r₀) (Pr.proof p) = t),
        fiberCount Pr (Pr.proof p) (Pr.Q r₀) c o
          = (univ.filter fun p : P => restrictTo (Pr.Q r₀) (Pr.proof p) = t).card * N := by
      rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, smul_eq_mul]
      have hp' : restrictTo (Pr.Q r₀) (Pr.proof p) = t := (mem_filter.mp hp).2
      exact fiberCount_congr hH _ _ _
        ((restrictTo_eq_iff _ _ _).mp (hp'.trans ht0.symm)) c o
    have hsim : ∑ s ∈ univ.filter (fun s : S => restrictTo (Pr.Q r₀) (sim r₀ s) = t),
        fiberCount Pr (sim r₀ s) (Pr.Q r₀) c o
          = (univ.filter fun s : S => restrictTo (Pr.Q r₀) (sim r₀ s) = t).card * N := by
      rw [Finset.sum_congr rfl (fun s hs => ?_), Finset.sum_const, smul_eq_mul]
      have hs' : restrictTo (Pr.Q r₀) (sim r₀ s) = t := (mem_filter.mp hs).2
      exact fiberCount_congr hH _ _ _
        ((restrictTo_eq_iff _ _ _).mp (hs'.trans ht0.symm)) c o
    rw [hreal, hsim]
    calc (univ.filter fun p : P => restrictTo (Pr.Q r₀) (Pr.proof p) = t).card * N
            * Fintype.card S
        = ((univ.filter fun p : P => restrictTo (Pr.Q r₀) (Pr.proof p) = t).card
            * Fintype.card S) * N := by ring
      _ = ((univ.filter fun s : S => restrictTo (Pr.Q r₀) (sim r₀ s) = t).card
            * Fintype.card P) * N := by rw [hcard]
      _ = (univ.filter fun s : S => restrictTo (Pr.Q r₀) (sim r₀ s) = t).card * N
            * Fintype.card P := by ring

/-- **Perfect honest-verifier zero knowledge of a committed local-oracle
protocol.** If the commitment perfectly hides unopened coordinates and the opened
coordinates are perfectly simulatable, then the full transcript distribution of
the real constant-query interaction is *identical* to the simulator's. -/
theorem perfect_hvzk [Nonempty P] [Nonempty S] {Pr : CommittedOracle I A C O Rc Rv P}
    {sim : Rv → S → I → A} (hH : PerfectlyHidesUnopened Pr)
    (hS : PerfectlySimulatesOpened Pr sim) (τ : Transcript I A C O Rv) :
    realProb Pr τ = simProb Pr sim τ := by
  have key := realCount_mul_card_sim hH hS τ
  have keyQ : (realCount Pr τ : ℚ) * Fintype.card S
      = (simCount Pr sim τ : ℚ) * Fintype.card P := by exact_mod_cast key
  have hP : (0 : ℚ) < Fintype.card P := by exact_mod_cast Fintype.card_pos (α := P)
  have hSc : (0 : ℚ) < Fintype.card S := by exact_mod_cast Fintype.card_pos (α := S)
  rw [realProb, simProb]
  rcases Nat.eq_zero_or_pos (Fintype.card Rc) with hRc | hRc
  · simp [hRc]
  rcases Nat.eq_zero_or_pos (Fintype.card Rv) with hRv | hRv
  · simp [hRv]
  have hRcQ : (0 : ℚ) < Fintype.card Rc := by exact_mod_cast hRc
  have hRvQ : (0 : ℚ) < Fintype.card Rv := by exact_mod_cast hRv
  rw [div_eq_div_iff (by positivity) (by positivity)]
  calc (realCount Pr τ : ℚ) * ((Fintype.card S : ℚ) * Fintype.card Rc * Fintype.card Rv)
      = ((realCount Pr τ : ℚ) * Fintype.card S) * (Fintype.card Rc * Fintype.card Rv) := by
        ring
    _ = ((simCount Pr sim τ : ℚ) * Fintype.card P) * (Fintype.card Rc * Fintype.card Rv) := by
        rw [keyQ]
    _ = (simCount Pr sim τ : ℚ) * ((Fintype.card P : ℚ) * Fintype.card Rc * Fintype.card Rv) := by
        ring

/-- **No event distinguishes the real interaction from the simulation.** Perfect
HVZK is inherited by every event (finite set of transcripts). -/
theorem event_prob_eq [Nonempty P] [Nonempty S] {Pr : CommittedOracle I A C O Rc Rv P}
    {sim : Rv → S → I → A} (hH : PerfectlyHidesUnopened Pr)
    (hS : PerfectlySimulatesOpened Pr sim) (Ev : Finset (Transcript I A C O Rv)) :
    ∑ τ ∈ Ev, realProb Pr τ = ∑ τ ∈ Ev, simProb Pr sim τ :=
  Finset.sum_congr rfl fun τ _ => perfect_hvzk hH hS τ

/-- **Zero distinguishing advantage.** Any (even unbounded, randomized-by-weights)
distinguisher `f` assigning a score to each transcript has exactly the same
expected score in the real interaction and in the simulation. -/
theorem distinguisher_advantage_zero [Nonempty P] [Nonempty S]
    {Pr : CommittedOracle I A C O Rc Rv P} {sim : Rv → S → I → A}
    (hH : PerfectlyHidesUnopened Pr) (hS : PerfectlySimulatesOpened Pr sim)
    (Ev : Finset (Transcript I A C O Rv)) (f : Transcript I A C O Rv → ℚ) :
    ∑ τ ∈ Ev, f τ * realProb Pr τ - ∑ τ ∈ Ev, f τ * simProb Pr sim τ = 0 := by
  rw [sub_eq_zero]
  exact Finset.sum_congr rfl fun τ _ => by rw [perfect_hvzk hH hS τ]

end Counting

/-! ## An instance: the coordinate-wise one-time-pad commitment

Over a finite abelian group `A`, commit to `u : I → A` with a uniformly random pad
`ρ : I → A` by sending `u + ρ`, and open a coordinate by revealing the pad there.
This perfectly hides every unopened coordinate, *even given* the openings of the
queried ones. -/

section OTP

variable [AddCommGroup A]

/-- The one-time-pad committed local-oracle protocol built from a proof-string
family `w : P → I → A` and a constant-size query family `Q`. -/
def otpOracle (w : P → I → A) (Q : Rv → Finset I) (qb : ℕ) (hq : ∀ r, (Q r).card ≤ qb) :
    CommittedOracle I A (I → A) (I → Option A) (I → A) Rv P where
  com u ρ := fun i => u i + ρ i
  openInfo _ ρ T := restrictTo T ρ
  Q := Q
  qbound := qb
  query_card_le := hq
  proof := w

/-- **The one-time-pad commitment perfectly hides unopened coordinates.** The
translation `ρ ↦ ρ + (u - v)` of the pad space is the required bijection: it fixes
the pad on the opened set (where `u = v`), hence preserves the opening data, and
carries the commitment to `u` to the commitment to `v`. -/
theorem otpOracle_hides (w : P → I → A) (Q : Rv → Finset I) (qb : ℕ)
    (hq : ∀ r, (Q r).card ≤ qb) :
    PerfectlyHidesUnopened (Rc := I → A) (otpOracle w Q qb hq) := by
  intro T u v huv
  refine ⟨Equiv.addRight (fun i => u i - v i), fun ρ => ⟨?_, ?_⟩⟩
  · funext i
    show u i + ρ i = v i + (ρ + fun i => u i - v i) i
    simp only [Pi.add_apply]
    abel
  · funext i
    by_cases hi : i ∈ T
    · show (if i ∈ T then some (ρ i) else none)
        = if i ∈ T then some ((ρ + fun i => u i - v i) i) else none
      simp only [if_pos hi, Pi.add_apply, huv i hi, sub_self, add_zero]
    · show (if i ∈ T then some (ρ i) else none)
        = if i ∈ T then some ((ρ + fun i => u i - v i) i) else none
      simp only [if_neg hi]

end OTP

end MachineLearning.CommittedLocalOracleZK