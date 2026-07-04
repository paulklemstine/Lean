/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# List colouring (choosability) of finite graphs — core definitions

This file introduces the notion of **`k`-choosability** (list colourability) of a
simple graph and relates it to ordinary colourability.

Given a graph `G`, a *list assignment* is a map `L : V → Finset ℕ` giving each vertex a
set of admissible colours.  An `L`-colouring is a proper colouring `c` that respects the
lists (`c v ∈ L v` for every `v`).  `G` is **`k`-choosable** (`Choosable G k`) when *every*
list assignment whose lists all have size at least `k` admits a proper `L`-colouring.

Main results in this file:

* `Choosable`                : the definition of `k`-choosability.
* `colorable_of_choosable`   : `k`-choosability implies ordinary `k`-colourability
                               (list colouring genuinely generalises colouring).
* `choosable_mono`           : choosability is monotone in the number of colours.

The colour universe is fixed to `ℕ`; since every finite list embeds into `ℕ`, this is
without loss of generality and avoids quantifying over an arbitrary colour type.
-/
import Mathlib

open SimpleGraph Finset

namespace ListChoosability

variable {V : Type*}

/-- `Choosable G k` : `G` is `k`-choosable (list colourable).  For every assignment `L`
of colour lists, each of size at least `k`, there is a proper colouring choosing a colour
of `L v` at each vertex `v`. -/
def Choosable (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ L : V → Finset ℕ, (∀ v, k ≤ (L v).card) →
    ∃ c : V → ℕ, (∀ v, c v ∈ L v) ∧ ∀ u v, G.Adj u v → c u ≠ c v

/-- **List colouring generalises colouring.**  A `k`-choosable graph is `k`-colourable:
apply choosability to the constant list assignment `v ↦ {0, 1, …, k-1}`. -/
theorem colorable_of_choosable {G : SimpleGraph V} {k : ℕ}
    (h : Choosable G k) : G.Colorable k := by
  obtain ⟨c, hmem, hadj⟩ := h (fun _ => Finset.range k) (by intro v; simp)
  rw [colorable_iff_exists_bdd_nat_coloring]
  refine ⟨SimpleGraph.Coloring.mk c (fun {u v} huv => hadj u v huv), ?_⟩
  intro v
  have := hmem v
  simpa using this

/-- **Monotonicity of choosability.**  If a graph is `k`-choosable and `k ≤ m`, then it is
`m`-choosable: lists of size `≥ m` are in particular of size `≥ k`. -/
theorem choosable_mono {G : SimpleGraph V} {k m : ℕ}
    (h : Choosable G k) (hkm : k ≤ m) : Choosable G m := by
  intro L hL
  exact h L (fun v => le_trans hkm (hL v))

end ListChoosability

-- !-- Lab Notes -- !--
/-
## Lab Notes (Defs)

**Hypothesis (Hypothesizer).**  The topic claim "every 3-colourable planar graph is
4-choosable" is a known-false conjecture (Mirzakhani's 63-vertex example).  We reframed the
mission around the honest, provable core: build a faithful formal notion of choosability and
locate exactly *where* colourability and choosability diverge.

**Experiment (Experimenter).**  We fixed the colour universe to `ℕ` (WLOG, as any finite
list embeds into `ℕ`), which removes an awkward quantifier over colour types while keeping
the definition faithful.  Sanity checks: constant lists `range k` recover ordinary
`k`-colouring; enlarging every list can only make colouring easier.

**Analysis (Analyst).**  `colorable_of_choosable` confirms choosability refines
colourability (`ch(G) ≥ χ(G)`), so any counterexample to the topic conjecture must live in
the *gap* between the two invariants.  `choosable_mono` shows choosability is an upward-closed
property in the number of colours, as expected of a genuine "at least `k` colours" notion.

**Critique (Critic).**  The definition is not vacuous: the existential colouring must both
respect the lists and be proper, and `colorable_of_choosable` uses it non-trivially via the
`range k` instantiation.  No `native_decide`, no `True`-style wrappers.

**Synthesis.**  A reusable choosability layer on top of Mathlib's `SimpleGraph`, ready to
host both positive (degree bound) and negative (`K_{2,4}`) results.
-/