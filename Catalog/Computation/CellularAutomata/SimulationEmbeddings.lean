import Mathlib
import Applications.CellularAutomataVariety.Basic
import Computation.CellularAutomata.ShiftsPolynomialsOrbits
import Computation.CellularAutomata.FixedPointCounts

/-!
# Simulation embeddings between cyclic lattices, and orbits of Rule 110

Turing universality is a statement about unbounded space-time evolution, so the
invariants that matter are orbit structures and embeddings of one dynamical system
into another, not fixed points alone.  This file provides both, for elementary
cellular automata on cyclic lattices.

## Main results

* `minimalPeriod_eq_of_injective_semiconj`: an injective semiconjugacy preserves exact
  orbit lengths.  This is the abstract engine.
* `step_pull`, `semiconj_pull`: for `d ∣ n`, the pullback `pull : Config d → Config n`
  is an injective *simulation embedding*: it intertwines the dynamics of any rule on
  the small lattice with its dynamics on the big one.
* `minimalPeriod_pull`: consequently a configuration and its pullback have the same
  exact period, so the whole orbit spectrum of a rule on `ZMod d` embeds into its
  orbit spectrum on `ZMod n` whenever `d ∣ n`.
* `minimalPeriod_shiftLeft`: shifting a configuration does not change its period.
* `exists_periodicPt`: *every* elementary rule has a periodic orbit on every nonempty
  cyclic lattice — even those, like rule 51, with no fixed configuration at all.
* `rule110_exists_minimalPeriod_two`: Rule 110 has a configuration of exact period two
  on every cyclic lattice whose size is divisible by `4`.  Together with
  `rule110_fixedPoints_ncard = 1` this shows that the fixed-point variety of the
  universal rule, though a single point, sits inside a genuinely nontrivial orbit
  structure.

-- !-- Lab Notes -- !--

HYPOTHESIS.  Fixed points are a poor invariant for universality, but *orbit spectra*
transported along lattice divisibility are not: if a rule has an exact `k`-orbit on
`ZMod d`, it should have one on every multiple of `d`.

EXPERIMENT.  Enumerating rule 110 on `ZMod n` for `n ≤ 8`, the number of `k`-periodic
configurations is `1` for every `k` unless `4 ∣ n`; for `n = 4` there are `5`
configurations with `f^[2] s = s` (the fixed `0` plus two 2-cycles
`1110 ↔ 1011` and `1101 ↔ 0111`), and for `n = 8` there are `5` for `k = 2` and `13`
for `k = 8`.

ANALYSIS.  The `n = 4` two-cycles are the smallest "glider-like" objects of rule 110.
The descent embedding `pull` transports them to every lattice of size divisible by
`4`, which the theorem `rule110_exists_minimalPeriod_two` records.  The data suggests
the sharper statement that `4 ∣ n` is also *necessary*; that is recorded as a
conjecture rather than a theorem.

CRITIQUE.  `rule110_t110_minimalPeriod` uses a kernel computation only for the two
finite facts `f^[2] t = t` and `f t ≠ t` on the four-site lattice; the passage from
`ZMod 4` to arbitrary multiples of `4` is a proof, not an enumeration.
-/

namespace CASimulationEmbeddings

open CellularAutomataVariety CAShiftsPolynomialsOrbits CAFixedPointCounts Function

variable {n d : ℕ}

/-! ## 1. Injective semiconjugacies preserve exact periods -/

/-- If `e` is injective and intertwines `f` with `u`, then `e x` and `x` have the same
exact period.  (Both sides are `0` when `x` is not a periodic point.) -/
theorem minimalPeriod_eq_of_injective_semiconj {α β : Type*} {f : α → α} {u : β → β}
    {e : α → β} (he : Injective e) (hsemi : ∀ x, e (f x) = u (e x)) (x : α) :
    minimalPeriod u (e x) = minimalPeriod f x := by
  have hit : ∀ (k : ℕ) (y : α), e (f^[k] y) = u^[k] (e y) := by
    intro k
    induction k with
    | zero => intro y; rfl
    | succ m ih =>
        intro y
        rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ih, hsemi]
  have hiff : ∀ k, IsPeriodicPt u k (e x) ↔ IsPeriodicPt f k x := by
    intro k
    constructor
    · intro h
      have hek : e (f^[k] x) = e x := by rw [hit]; exact h
      exact he hek
    · intro h
      show u^[k] (e x) = e x
      rw [← hit]
      exact congrArg e h
  have h1 : IsPeriodicPt u (minimalPeriod f x) (e x) :=
    (hiff _).mpr (isPeriodicPt_minimalPeriod f x)
  have h2 : IsPeriodicPt f (minimalPeriod u (e x)) x :=
    (hiff _).mp (isPeriodicPt_minimalPeriod u (e x))
  exact Nat.dvd_antisymm h1.minimalPeriod_dvd h2.minimalPeriod_dvd

/-! ## 2. The descent map is a simulation embedding -/

/-- The pullback along `ZMod n → ZMod d` intertwines the dynamics: it is a morphism of
dynamical systems, not merely of fixed-point sets. -/
theorem step_pull (h : d ∣ n) (g : LocalRule) (t : Config d) :
    step g (pull h t) = pull h (step g t) := by
  funext i
  have h1 : ZMod.castHom h (ZMod d) (i - 1) = ZMod.castHom h (ZMod d) i - 1 := by
    rw [map_sub, map_one]
  have h2 : ZMod.castHom h (ZMod d) (i + 1) = ZMod.castHom h (ZMod d) i + 1 := by
    rw [map_add, map_one]
  show g (pull h t (i - 1)) (pull h t i) (pull h t (i + 1)) = pull h (step g t) i
  simp only [pull_apply, h1, h2]
  rfl

theorem semiconj_pull (h : d ∣ n) (g : LocalRule) :
    Semiconj (pull h) (step g) (step (n := n) g) := fun t => (step_pull h g t).symm

/-- **Orbit lengths are preserved by the simulation embedding.** -/
theorem minimalPeriod_pull (h : d ∣ n) (g : LocalRule) (t : Config d) :
    minimalPeriod (step g) (pull h t) = minimalPeriod (step g) t :=
  minimalPeriod_eq_of_injective_semiconj (pull_injective h)
    (fun t => (step_pull h g t).symm) t

/-- The whole orbit spectrum of a rule on `ZMod d` occurs on `ZMod n` when `d ∣ n`. -/
theorem exists_minimalPeriod_of_dvd (h : d ∣ n) (g : LocalRule) {k : ℕ}
    (hk : ∃ t : Config d, minimalPeriod (step g) t = k) :
    ∃ s : Config n, minimalPeriod (step g) s = k := by
  obtain ⟨t, ht⟩ := hk
  exact ⟨pull h t, by rw [minimalPeriod_pull]; exact ht⟩

/-- The left shift is injective on configurations. -/
theorem shiftLeft_injective : Injective (shiftLeft n : Config n → Config n) := by
  intro a b hab
  have h := congrArg (shiftRight n) hab
  rwa [shiftRight_shiftLeft, shiftRight_shiftLeft] at h

/-- Shifting a configuration does not change its exact period. -/
theorem minimalPeriod_shiftLeft (g : LocalRule) (s : Config n) :
    minimalPeriod (step g) (shiftLeft n s) = minimalPeriod (step g) s :=
  minimalPeriod_eq_of_injective_semiconj (f := step g) (u := step g)
    (e := (shiftLeft n : Config n → Config n)) shiftLeft_injective
    (fun x => (step_shiftLeft g x).symm) s

/-! ## 3. Every rule has a periodic orbit -/

/-- **Existence of periodic orbits.**  On a nonempty cyclic lattice the phase space is
finite, so every elementary rule has at least one periodic configuration — even rules
such as 51 which have no fixed configuration whatsoever. -/
theorem exists_periodicPt [NeZero n] (g : LocalRule) :
    ∃ (s : Config n) (k : ℕ), 0 < k ∧ IsPeriodicPt (step g) k s := by
  have key : ∀ a b : ℕ, a < b → (step g)^[a] (0 : Config n) = (step g)^[b] (0 : Config n) →
      ∃ (s : Config n) (k : ℕ), 0 < k ∧ IsPeriodicPt (step g) k s := by
    intro a b hab hEq
    refine ⟨(step g)^[a] (0 : Config n), b - a, by omega, ?_⟩
    show (step g)^[b - a] ((step g)^[a] (0 : Config n)) = (step g)^[a] (0 : Config n)
    rw [← Function.iterate_add_apply]
    rw [show b - a + a = b from by omega]
    exact hEq.symm
  obtain ⟨a, b, hab, hEq⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun k : ℕ => (step g)^[k] (0 : Config n))
  rcases lt_or_gt_of_ne hab with hlt | hlt
  · exact key a b hlt hEq
  · exact key b a hlt hEq.symm

/-- Rule 51 realises the previous theorem nontrivially: it has periodic orbits but no
fixed configuration. -/
theorem rule51_periodic_but_no_fixed [NeZero n] :
    (∃ (s : Config n) (k : ℕ), 0 < k ∧ IsPeriodicPt (step rule51) k s) ∧
      ¬ ∃ s : Config n, IsFixed rule51 s := by
  refine ⟨exists_periodicPt rule51, ?_⟩
  rintro ⟨s, hs⟩
  exact rule51_not_isFixedPt s hs

/-! ## 4. A genuine period-two orbit of Rule 110 -/

/-- The four-site configuration `1110`, the smallest non-fixed periodic configuration
of rule 110. -/
def t110 : Config 4 := fun i => if i = 3 then 0 else 1

theorem rule110_t110_isPeriodicPt_two : IsPeriodicPt (step rule110) 2 t110 := by
  show (step rule110)^[2] t110 = t110
  decide

theorem rule110_t110_not_isFixedPt : ¬ IsFixedPt (step rule110) t110 := by
  show ¬ (step rule110 t110 = t110)
  decide

/-- The configuration `1110` on the four-site lattice has exact period two under rule
110. -/
theorem rule110_t110_minimalPeriod : minimalPeriod (step rule110) t110 = 2 := by
  have hdvd : minimalPeriod (step rule110) t110 ∣ 2 :=
    rule110_t110_isPeriodicPt_two.minimalPeriod_dvd
  rcases (Nat.dvd_prime Nat.prime_two).mp hdvd with h | h
  · have hp := isPeriodicPt_minimalPeriod (step rule110) t110
    rw [h] at hp
    have hfix : IsFixedPt (step rule110) t110 := hp
    exact absurd hfix rule110_t110_not_isFixedPt
  · exact h

/-- **Rule 110 has an exact two-cycle on every lattice of size divisible by `4`.**
The universal rule therefore has a one-point fixed-point variety and, simultaneously,
nontrivial periodic orbits on infinitely many lattices. -/
theorem rule110_exists_minimalPeriod_two (h : 4 ∣ n) :
    ∃ s : Config n, minimalPeriod (step rule110) s = 2 :=
  exists_minimalPeriod_of_dvd h rule110 ⟨t110, rule110_t110_minimalPeriod⟩

/-- On such lattices the periodic configuration is not the fixed one: rule 110 has at
least two distinct periodic configurations whenever `4 ∣ n`. -/
theorem rule110_periodic_ne_zero [NeZero n] (h : 4 ∣ n) :
    ∃ s : Config n, minimalPeriod (step rule110) s = 2 ∧ s ≠ 0 := by
  obtain ⟨s, hs⟩ := rule110_exists_minimalPeriod_two h
  refine ⟨s, hs, ?_⟩
  rintro rfl
  have hfix : IsFixed (n := n) rule110 0 := by
    have : ({s : Config n | IsFixed rule110 s}) = {0} := rule110_fixedPoints_eq_singleton_zero
    have h0 : (0 : Config n) ∈ ({0} : Set (Config n)) := rfl
    rwa [← this] at h0
  have h1 : minimalPeriod (step rule110) (0 : Config n) = 1 :=
    minimalPeriod_eq_one_iff_isFixedPt.mpr hfix
  rw [h1] at hs
  exact absurd hs (by norm_num)

end CASimulationEmbeddings