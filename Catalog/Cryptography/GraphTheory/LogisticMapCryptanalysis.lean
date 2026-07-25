import Mathlib
import Computation.HilbertSpace.Bifurcation

/-!
# Structural Cryptanalysis of the Logistic Map

For the parameter-four logistic map, chaos does not imply cryptographic one-wayness.
This chapter isolates three exact structures: reflection collisions, a trigonometric
semiconjugacy to angle doubling, and short exceptional orbits.  Together they show
that orbit sensitivity and polynomial degree alone cannot establish pseudorandomness
or inversion hardness.
-/

noncomputable section

namespace LogisticMapCryptanalysis

/-- The parameter-four logistic map over a commutative ring. -/
def logistic {R : Type*} [CommRing R] (x : R) : R := 4 * x * (1 - x)

/-
Reflection about `1/2` is an exact, universal collision.
-/
theorem logistic_reflection {R : Type*} [CommRing R] (x : R) :
    logistic (1 - x) = logistic x := by
  unfold logistic; ring;

/-
Every reflected pair has identical orbit after the first sample.
-/
theorem reflected_orbits_merge {R : Type*} [CommRing R] (x : R) (n : ℕ) :
    (logistic^[n + 1]) (1 - x) = (logistic^[n + 1]) x := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact logistic_reflection x

/-
Over any nontrivial commutative ring, the logistic map is not injective.
-/
theorem logistic_not_injective {R : Type*} [CommRing R] [Nontrivial R] :
    ¬ Function.Injective (logistic : R → R) := by
  intro h;
  have := @h 0 1 ; simp_all +decide [ logistic ]

/-
Observing any nonempty orbit suffix cannot distinguish a seed from its reflection.
-/
theorem finite_keystream_collision (x : ℝ) (start length : ℕ) (hstart : 0 < start) :
    (List.range length).map (fun j => (logistic^[start + j]) x) =
      (List.range length).map (fun j => (logistic^[start + j]) (1 - x)) := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hstart)
  apply List.map_congr_left
  intro j _
  simpa [Nat.succ_add] using (reflected_orbits_merge x (k + j)).symm

/-
Every target at most one has an explicit lower-branch preimage. Thus one-step
inversion requires a square root rather than a generic polynomial solver.
-/
theorem logistic_explicit_preimage (y : ℝ) (hy1 : y ≤ 1) :
    logistic ((1 - Real.sqrt (1 - y)) / 2) = y := by
  unfold logistic; ring_nf; rw [ Real.sq_sqrt ] <;> linarith;

/-
The logistic map is semiconjugate to angle doubling through `sin²`.
-/
theorem logistic_sin_sq (θ : ℝ) :
    logistic (Real.sin θ ^ 2) = Real.sin (2 * θ) ^ 2 := by
  rw [ Real.sin_two_mul ] ; ring;
  unfold logistic; rw [ Real.cos_sq' ] ; ring;

/-
The semiconjugacy gives a closed form for every iterate.
-/
theorem logistic_iterate_sin_sq (θ : ℝ) (n : ℕ) :
    (logistic^[n]) (Real.sin θ ^ 2) = Real.sin ((2 : ℝ) ^ n * θ) ^ 2 := by
  induction' n with n ih;
  · norm_num;
  · rw [ Function.iterate_succ_apply', ih, logistic_sin_sq ] ; ring

/-
Zero is an absorbing state, so not every seed exhibits chaotic statistics.
-/
theorem zero_orbit (n : ℕ) : (logistic^[n]) (0 : ℝ) = 0 := by
  convert Function.iterate_fixed_of_fixed ( logistic : ℝ → ℝ ) _ n ; norm_num [ logistic ]

/-
The seed `1/2` reaches the absorbing state after exactly two updates.
-/
theorem half_seed_collapses (n : ℕ) :
    (logistic^[n + 2]) (1 / 2 : ℝ) = 0 := by
  unfold logistic; norm_num [ Function.iterate_add_apply ] ;
  exact Function.iterate_fixed ( by norm_num ) _

/-
A finite-state dynamical system always repeats within the size of its state space.
-/
theorem finite_state_eventual_collision {S : Type*} [Fintype S]
    (f : S → S) (x : S) :
    ∃ i j : Fin (Fintype.card S + 1), i < j ∧ (f^[i.val]) x = (f^[j.val]) x := by
  by_contra! h;
  exact absurd ( Fintype.card_le_of_injective ( fun i : Fin ( Fintype.card S + 1 ) => f^[i] x ) fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ( by simp +decide )

/-
In particular, a `p`-bit state machine repeats among its first `2^p+1` states;
this is an upper bound, not a lower bound on period.
-/
theorem bit_state_eventual_collision (p : ℕ) (f : (Fin p → Bool) → (Fin p → Bool))
    (x : Fin p → Bool) :
    ∃ i j : Fin (2 ^ p + 1), i < j ∧ (f^[i.val]) x = (f^[j.val]) x := by
  convert finite_state_eventual_collision f x using 1;
  · norm_num [ Fintype.card_pi ];
  · congr!; all_goals norm_num

/- !-- Lab Notes -- !--
Hypothesis: seven ranked, falsifiable possibilities were considered: (1) exact angle
doubling permits logarithmic-depth orbit evaluation; (2) every positive-length suffix
has reflection-related seed collisions; (3) generic inverse trees have binary branching;
(4) finite precision guarantees periods of at least the state width; (5) every seed has
the same limiting distribution; (6) polynomial degree forces exponential inversion;
and (7) standard statistical batteries imply next-bit security.
Experiment: rational seed tables, exact symbolic identities, and finite-state orbit
bounds were tested before security claims were formulated.
Analysis: hypotheses (1) and (2) survive in exact form. Reflection gives a two-to-one
collision before any asymptotic issue arises; angle doubling explains both chaotic
expansion and algebraic predictability; exceptional seeds give short orbits. Hypothesis
(3) requires branch and endpoint qualifications. Hypotheses (4)--(7) fail as stated.
Critique: sensitivity is not one-wayness, convergence cannot hold for every initial
condition because zero supports a fixed orbit, and a finite state count yields only an
upper bound on eventual repetition. High algebraic degree does not preclude structured
inversion, and statistical tests do not establish computational unpredictability.
Synthesis: the surviving result is a cryptanalytic obstruction, not a security theorem.
The exact semiconjugacy unifies collision and orbit formulas, an explicit square-root
preimage refutes the degree heuristic, and the catalog's general iterate-fixed theorem
supplies the absorbing-orbit argument.
-- !--/

end LogisticMapCryptanalysis