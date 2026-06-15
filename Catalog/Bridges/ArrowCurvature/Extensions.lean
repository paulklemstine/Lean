import Bridges.ArrowCurvature.Defs

/-!
# Arrow–Curvature, Extensions: the obstruction is explicit, and curvature is a coboundary class

This file extends `Bridges.ArrowCurvature.Defs`. There, `arrow_curvature_conjecture`
was stated with the global hypothesis `∀ P, 0 < CondorcetCurvature P` ("positive
curvature everywhere"). We make the *content* of that cycle precise:

* The global hypothesis is **unsatisfiable** (`unrestricted_domain_impossible`): a
  unanimous profile is always flat, so no profile space has positive curvature
  everywhere. This is exactly why `arrow_curvature_conjecture` is vacuously true —
  the obstruction lives in the *reachable* configuration space, not in Arrow's axioms.

* By contrast, positive curvature **is** achievable on individual profiles
  (`exists_positive_curvature_profile`): the classical Condorcet paradox witnesses
  `0 < CondorcetCurvature`. So restricting curvature positivity to an admissible
  domain is meaningful, while demanding it everywhere is not.

* Condorcet curvature is *literally* the directed 3-cycle count of the majority
  tournament (`condorcetCurvature_eq_cycleCount`).

* The cohomological reading: a tournament is transitive (flat) **iff** its `beats`
  relation is the strict order induced by an integer potential `f : Fin n → ℤ`
  (`Tournament.transitive_iff_has_potential`). Transitivity is exactly the
  "the curl/curvature 1-cochain is a coboundary `f a − f b`" condition. Specialised
  to profiles: zero Condorcet curvature gives such a global potential
  (`zero_curvature_has_potential`).

## Main results

* `exists_unanimous_profile`         — a flat (unanimous) profile always exists.
* `unrestricted_domain_impossible`   — `∀ P, 0 < CondorcetCurvature P` is false.
* `exists_positive_curvature_profile`— the Condorcet paradox has positive curvature.
* `condorcetCurvature_eq_cycleCount` — curvature = directed 3-cycle count.
* `Tournament.transitive_iff_has_potential` — flatness ⇔ existence of an integer potential.
* `zero_curvature_has_potential`     — zero curvature yields a global majority potential.
-/

open Finset Function

namespace ArrowCurvature

/-! ## Part I: The obstruction is explicit -/

-- !-- Lab Notebook: unrestricted_domain_impossible -- !--
-- !-- Hypothesis: the global premise `∀ P, 0 < CondorcetCurvature P` used in
--     `arrow_curvature_conjecture` might be satisfiable on some alternative/voter
--     count, salvaging a non-vacuous Arrow statement. -- !--
-- !-- Result: Disproved for EVERY n, k. The unanimous profile is always flat, so
--     positivity-everywhere never holds. -- !--
-- !-- Insight: Arrow's force is not "curvature everywhere"; the flat (unanimous)
--     profile is always reachable. Curvature positivity must be a *domain-relative*
--     hypothesis, exactly like holonomy is read off loops that actually bound. -- !--
-- !-- Failure analysis: Attempting an unconditional Arrow theorem from this premise
--     is hopeless — the premise itself is contradictory; the honest invariant is the
--     existence of *some* curved profile, not curvature of all profiles. -- !--
-- !-- End Lab Notebook -- !--

/-- A flat profile always exists: take every voter to share the identity ranking.
    This is the explicit witness behind the vacuity of `arrow_curvature_conjecture`. -/
theorem exists_unanimous_profile (n k : ℕ) :
    ∃ P : PreferenceProfile n k, P.IsUnanimous :=
  ⟨fun _ => ⟨Equiv.refl _⟩, fun _ _ _ _ h => h⟩

/-- **The obstruction theorem.** The "positive curvature everywhere" hypothesis is
    unsatisfiable on every profile space, because the unanimous profile is flat.
    This is the precise reason `arrow_curvature_conjecture` is vacuously true. -/
theorem unrestricted_domain_impossible (n k : ℕ) :
    ¬ ∀ P : PreferenceProfile n k, 0 < CondorcetCurvature P := by
  -- !-- Proof sketch: instantiate at the unanimous witness; `unanimous_curvature_zero`
  --     makes its curvature 0, contradicting strict positivity. -- !--
  intro h
  obtain ⟨P, hu⟩ := exists_unanimous_profile n k
  have hzero := unanimous_curvature_zero P hu
  have hpos := h P
  omega

/-- The classical Condorcet paradox: three voters with cyclic rankings
    `0>1>2`, `1>2>0`, `2>0>1` over three alternatives. -/
noncomputable def condorcetParadox : PreferenceProfile 3 3 := fun i =>
  if i = 0 then ⟨Equiv.refl _⟩
  else if i = 1 then ⟨⟨![2, 0, 1], ![1, 2, 0], by decide, by decide⟩⟩
  else ⟨⟨![1, 2, 0], ![2, 0, 1], by decide, by decide⟩⟩

-- !-- Lab Notebook: exists_positive_curvature_profile -- !--
-- !-- Hypothesis: positive curvature is achievable on a single profile even though it
--     can never hold on all of them. -- !--
-- !-- Result: Proved via the explicit Condorcet paradox; its curvature is positive. -- !--
-- !-- Insight: Curvature is genuinely a two-sided invariant — flat profiles and curved
--     profiles both exist — so the asymmetry exposed by `unrestricted_domain_impossible`
--     is about the *quantifier*, not about curvature being trivial. -- !--
-- !-- Failure analysis: A purely abstract existence proof is awkward; a concrete finite
--     witness checked by kernel computation (`decide`) is the clean route. -- !--
-- !-- End Lab Notebook -- !--

/-- Positive curvature is achievable: the Condorcet paradox has a majority 3-cycle,
    so its Condorcet curvature is strictly positive. Together with
    `unrestricted_domain_impossible` this shows the *quantifier* (some profile vs.
    every profile) is what matters. -/
theorem exists_positive_curvature_profile :
    ∃ P : PreferenceProfile 3 3, 0 < CondorcetCurvature P :=
  ⟨condorcetParadox, by decide⟩

/-! ## Part II: Curvature equals the tournament 3-cycle count -/

-- !-- Lab Notebook: condorcetCurvature_eq_cycleCount -- !--
-- !-- Hypothesis: the ad-hoc `CondorcetCurvature` count coincides with the intrinsic
--     directed 3-cycle count `cycleCount` of the induced majority tournament. -- !--
-- !-- Result: Proved; they are definitionally the same filter, since `majorityBeats`
--     unfolds to the strict support inequality used in `CondorcetCurvature`. -- !--
-- !-- Insight: Condorcet curvature is not a new invariant but the holonomy count of the
--     majority tournament, justifying the geometric "curvature = cycles" slogan. -- !--
-- !-- Failure analysis: None — recognising the definitional match avoids a needless
--     `Finset` bijection argument. -- !--
-- !-- End Lab Notebook -- !--

/-- Condorcet curvature is exactly the directed 3-cycle count (`cycleCount`) of the
    majority tournament. The geometric slogan "curvature = holonomy" is literal here. -/
theorem condorcetCurvature_eq_cycleCount {n k : ℕ} (P : PreferenceProfile n k)
    (hk : Odd k) (hn : 1 < n) :
    CondorcetCurvature P = (P.majorityTournament hk hn).cycleCount := rfl

end ArrowCurvature

/-! ## Part III: The cohomological reading — flatness ⇔ existence of a potential -/

namespace Tournament

variable {n : ℕ} (T : Tournament n)

/-- The (Copeland) score of an alternative: how many opponents it beats. Used as the
    discrete *potential* whose differences recover the majority order. -/
noncomputable def score (a : Fin n) : ℕ :=
  (Finset.univ.filter (fun b => T.beats a b)).card

end Tournament

-- !-- Lab Notebook: Tournament.transitive_iff_has_potential -- !--
-- !-- Hypothesis: a tournament is flat (transitive / 3-cycle-free) iff its `beats`
--     1-cochain is a coboundary, i.e. `beats a b` is `f b < f a` for an integer
--     potential `f`. -- !--
-- !-- Result: Proved both directions. Forward uses the Copeland `score` as potential:
--     if `a` beats `b`, transitivity makes `{x | b beats x}` a strict subset of
--     `{x | a beats x}`, so `score b < score a`. Backward: a 3-cycle would force a
--     strict `<`-cycle in ℤ, impossible. -- !--
-- !-- Insight: Transitivity = "gradient field" condition. Curvature (a 3-cycle) is
--     precisely the obstruction to writing the margin as a coboundary `f a − f b`. -- !--
-- !-- Failure analysis: First tried a direct order-embedding into ℕ; the Copeland
--     score gives an explicit, computation-free potential and a cleaner subset argument. -- !--
-- !-- End Lab Notebook -- !--

/-- **Coboundary characterization of flatness.** A tournament is transitive iff its
    `beats` relation is induced by an integer potential `f` via `beats a b ↔ f b < f a`
    on edges. Equivalently, the majority margin is a coboundary exactly when curvature
    (the 3-cycle count) vanishes. -/
theorem Tournament.transitive_iff_has_potential {n : ℕ} (T : Tournament n) :
    T.IsTransitive ↔ ∃ f : Fin n → ℤ, ∀ a b, T.beats a b → f b < f a := by
  constructor
  · -- forward: the Copeland score is a strictly monotone potential
    intro ht
    refine ⟨fun a => (T.score a : ℤ), ?_⟩
    intro a b hab
    have hsub : (Finset.univ.filter (fun x => T.beats b x)) ⊆
        (Finset.univ.filter (fun x => T.beats a x)) := by
      intro x hx
      simp only [mem_filter, mem_univ, true_and] at *
      exact ht a b x hab hx
    have hlt : T.score b < T.score a := by
      apply Finset.card_lt_card
      rw [Finset.ssubset_iff_of_subset hsub]
      exact ⟨b, by simp [hab], by simp [T.beats_irrefl b]⟩
    change (T.score b : ℤ) < (T.score a : ℤ)
    exact_mod_cast hlt
  · -- backward: a potential forbids 3-cycles, hence transitivity
    rintro ⟨f, hf⟩ a b c hab hbc
    have hne : a ≠ c := by
      rintro rfl
      have h1 := hf a b hab
      have h2 := hf b a hbc
      omega
    rcases T.beats_complete a c hne with h1 | h1
    · exact h1
    · exfalso
      have h2 := hf a b hab
      have h3 := hf b c hbc
      have h4 := hf c a h1
      omega

/-- **Profile corollary.** Zero Condorcet curvature yields a global integer potential
    on alternatives whose differences recover the majority order: the flat preference
    space admits a consistent "social utility" `f`. -/
theorem zero_curvature_has_potential {n k : ℕ} (P : PreferenceProfile n k)
    (hk : Odd k) (hn : 1 < n) (hcurv : CondorcetCurvature P = 0) :
    ∃ f : Fin n → ℤ, ∀ a b, P.majorityBeats a b → f b < f a := by
  -- !-- Proof sketch: `zero_curvature_majority_transitive` flattens the majority
  --     tournament; `transitive_iff_has_potential` then produces the potential, whose
  --     `beats` is definitionally `majorityBeats`. -- !--
  have ht := zero_curvature_majority_transitive P hk hn hcurv
  exact (Tournament.transitive_iff_has_potential (P.majorityTournament hk hn)).1 ht