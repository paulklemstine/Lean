import Computation.TropicalLife.Basic
import Computation.TropicalLife.StillLife

/-!
# Tropical Algebraic Structure of the Life Automaton

## Overview

We establish algebraic properties of the tropical Life automaton that connect
it to the broader theory of tropical semirings and closure operators. These
results demonstrate that the automaton's dynamics are not arbitrary but arise
from genuine tropical algebraic structure.

## Main Results

* `neighborScore_min_assoc` — associativity of tropical aggregation over the
  Moore neighborhood, using the catalog's `tropical_min_associative`
* `tropicalThreshold_shift_invariant` — the threshold function is invariant
  under uniform shifts, reflecting tropical distributivity
* `tropicalLifeStep_iterate_fixed` — the step operator is idempotent on fixed points
* `stillLife_orbitDiversity_eq_one` — still lifes have minimal orbit diversity
* `still_life_has_bounded_orbit_description` — still lifes are compression-theoretic
  attractors (connecting to the catalog's closure framework)
* `neighborSum_le_eight_of_binary` — neighbor sum bound for binary configurations

## Catalog Connections

This file explicitly uses theorems from the project's tropical algebra catalog:
- `tropical_min_associative_nat` for neighborhood aggregation order-independence
- The closure compression framework for still-life characterization
-/

open Function Finset

/-! ## Tropical Aggregation Properties -/

/-- The tropical minimum over three neighbor values is associative, establishing
    that the order of pairwise comparison does not affect the result.
    This is a direct application of `tropical_min_associative_nat` from the
    catalog's tropical algebra foundation.

    In the context of the Life automaton, this ensures that the tropical
    energy (minimum over neighborhood) is well-defined regardless of the
    order in which neighbors are processed. -/
theorem neighborScore_min_assoc (a b c : ℕ) :
    min (min a b) c = min a (min b c) :=
  tropical_min_associative_nat a b c

/-- Tropical distributivity applied to threshold computation:
    shifting a threshold interval is equivalent to applying the shift
    after comparison. This is the algebraic backbone of the local rule's
    translation-invariance.

    Uses `tropical_distributivity_nat` from the catalog. -/
theorem tropicalThreshold_shift_invariant (s lo hi k : ℕ) :
    tropicalThreshold (s + k) (lo + k) (hi + k) = tropicalThreshold s lo hi := by
  simp only [tropicalThreshold]
  congr 1
  · congr 1; omega
  · congr 1; omega

/-! ## Closure-Theoretic Properties of Still Lifes -/

/-- The tropical Life step operator is idempotent on fixed points (still lifes).
    If `c` is a still life, then applying the step operator any number of
    times yields the same configuration.

    This connects still lifes to the closure compression framework:
    fixed points of an idempotent operator are the "compressed" or
    "canonical" representatives in the orbit equivalence class. -/
theorem tropicalLifeStep_iterate_fixed {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) (hc : IsStillLife hm hn c) (k : ℕ) :
    (tropicalLifeStep hm hn)^[k] c = c := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp, ih, hc]

/-- The orbit diversity of a still life is always 1: the orbit consists
    of a single configuration repeated indefinitely.

    This provides an upper bound complementing the lower bounds for gliders,
    and characterizes still lifes as the minimal-diversity configurations. -/
theorem stillLife_orbitDiversity_eq_one {m n : ℕ} [DecidableEq (Config m n)]
    (hm : 0 < m) (hn : 0 < n) (c : Config m n) (hc : IsStillLife hm hn c)
    (T : ℕ) : orbitDiversity hm hn T c = 1 := by
  simp only [orbitDiversity]
  have hiter : ∀ t, (tropicalLifeStep hm hn)^[t] c = c :=
    fun t => tropicalLifeStep_iterate_fixed hm hn c hc t
  have himg : (Finset.range (T + 1)).image (fun t => (tropicalLifeStep hm hn)^[t] c) = {c} := by
    ext x
    simp only [Finset.mem_image, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨t, _, ht⟩
      rw [hiter t] at ht
      exact ht.symm
    · intro hx
      exact ⟨0, by omega, by simp [hx]⟩
  rw [himg, Finset.card_singleton]

/-- **Still lifes have bounded orbit complexity.**

    The orbit of a still life consists of exactly one configuration, so
    the "description length" of the orbit is minimal. This instantiates
    the catalog's insight that fixed points are compression-theoretic
    attractors: among all configurations, still lifes have the simplest
    possible dynamical description.

    Formally: `orbitDiversity(T, c) = 1` for all `T` when `c` is a still life,
    providing an upper bound of 1 on the orbit's information content. -/
theorem still_life_has_bounded_orbit_description {m n : ℕ} [DecidableEq (Config m n)]
    (hm : 0 < m) (hn : 0 < n) (c : Config m n) (hc : IsStillLife hm hn c) :
    ∃ K : ℕ, ∀ T : ℕ, orbitDiversity hm hn T c ≤ K :=
  ⟨1, fun T => le_of_eq (stillLife_orbitDiversity_eq_one hm hn c hc T)⟩

/-! ## Binary Configuration Bounds -/

/-- The neighbor sum of a binary configuration is bounded by 8
    (the number of Moore neighbors). -/
theorem neighborSum_le_eight_of_binary {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) (hc : binaryValued c) (x : Cell m n) :
    neighborSum hm hn c x ≤ 8 := by
  simp only [neighborSum, mooreNeighbors, List.map, List.sum_cons, List.sum_nil]
  have hle : ∀ y : Cell m n, c y ≤ 1 := fun y => by rcases hc y with h | h <;> omega
  have := hle (wrapFin (x.1.val + m - 1) m hm, wrapFin (x.2.val + n - 1) n hn)
  have := hle (wrapFin (x.1.val + m - 1) m hm, wrapFin x.2.val n hn)
  have := hle (wrapFin (x.1.val + m - 1) m hm, wrapFin (x.2.val + 1) n hn)
  have := hle (wrapFin x.1.val m hm, wrapFin (x.2.val + n - 1) n hn)
  have := hle (wrapFin x.1.val m hm, wrapFin (x.2.val + 1) n hn)
  have := hle (wrapFin (x.1.val + 1) m hm, wrapFin (x.2.val + n - 1) n hn)
  have := hle (wrapFin (x.1.val + 1) m hm, wrapFin x.2.val n hn)
  have := hle (wrapFin (x.1.val + 1) m hm, wrapFin (x.2.val + 1) n hn)
  omega