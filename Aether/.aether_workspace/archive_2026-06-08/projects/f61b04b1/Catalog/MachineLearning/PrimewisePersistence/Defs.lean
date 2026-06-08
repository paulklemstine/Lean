/-
Copyright (c) 2025. All rights reserved.
Arithmetic Universality Class for Primewise Persistent Homology of Rational Dynamics.

This file defines the core structures for studying mod-p dynamics of rational maps
via orbit-preimage statistics, laying groundwork for a topological classifier of
algebraic dynamical systems.

Keywords: arithmetic_dynamics, persistent_homology, orbit_statistics, mod_p_dynamics,
          rational_maps, conjugacy_invariant
-/
import Mathlib

open Finset BigOperators

/-! ## Core Definitions for Mod-p Dynamical Systems

We model the action of a rational map on P^1(F_p) as a function on Fin (p+1),
and extract orbit-preimage statistics that serve as persistence invariants. -/

/-- A mod-p dynamical system: a self-map of the projective line P^1(F_p),
    modeled as a function on Fin (p+1). The parameter `p` is a prime. -/
structure ModPDynamics (p : ℕ) where
  /-- The dynamical map on Fin (p+1), representing the action on P^1(F_p) -/
  mapFn : Fin (p + 1) → Fin (p + 1)

/-- The k-th iterate of a mod-p dynamical system. -/
def ModPDynamics.iterate {p : ℕ} (dyn : ModPDynamics p) : ℕ → Fin (p + 1) → Fin (p + 1)
  | 0 => id
  | n + 1 => dyn.mapFn ∘ dyn.iterate n

/-- The set of fixed points of a mod-p dynamical system. -/
def ModPDynamics.fixedPoints {p : ℕ} (dyn : ModPDynamics p) : Finset (Fin (p + 1)) :=
  Finset.univ.filter (fun x => dyn.mapFn x = x)

/-- The set of periodic points of exact period k. -/
def ModPDynamics.periodicPoints {p : ℕ} (dyn : ModPDynamics p) (k : ℕ) : Finset (Fin (p + 1)) :=
  Finset.univ.filter (fun x => dyn.iterate k x = x)

/-- The preimage of a point under the dynamical map. -/
def ModPDynamics.preimage {p : ℕ} (dyn : ModPDynamics p) (y : Fin (p + 1)) : Finset (Fin (p + 1)) :=
  Finset.univ.filter (fun x => dyn.mapFn x = y)

/-- The preimage size function: for each point, how many points map to it. -/
def ModPDynamics.preimageSize {p : ℕ} (dyn : ModPDynamics p) (y : Fin (p + 1)) : ℕ :=
  (dyn.preimage y).card

/-- The orbit-preimage profile: the multiset of preimage sizes across all points.
    This is a fundamental invariant of the mod-p dynamics. -/
def ModPDynamics.preimageProfile {p : ℕ} (dyn : ModPDynamics p) : Fin (p + 1) → ℕ :=
  fun y => dyn.preimageSize y

/-- The image set of the dynamical map. -/
def ModPDynamics.imageSet {p : ℕ} (dyn : ModPDynamics p) : Finset (Fin (p + 1)) :=
  Finset.univ.image dyn.mapFn

/-- The dynamical degree sequence: multiset of preimage sizes, a conjugacy invariant. -/
def ModPDynamics.degreeSequence {p : ℕ} (dyn : ModPDynamics p) : Multiset ℕ :=
  (Finset.univ : Finset (Fin (p + 1))).val.map dyn.preimageSize

/-- The tail count at level k: number of points with preimage size > k.
    This gives the "persistence" of large preimage structure. -/
def ModPDynamics.tailCount {p : ℕ} (dyn : ModPDynamics p) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun y => dyn.preimageSize y > k)).card

/-- A persistence profile records orbit statistics at multiple filtration levels.
    This is the novel mathematical structure connecting TDA to arithmetic dynamics. -/
structure PersistenceProfile where
  /-- Number of filtration levels -/
  depth : ℕ
  /-- Periodic point count at each level: |{x : f^k(x) = x}| -/
  periodicCounts : Fin depth → ℕ
  /-- Tail count at each level: |{y : preimageSize(y) > k}| -/
  tailCounts : Fin depth → ℕ

/-- Extract a persistence profile from a mod-p dynamical system. -/
def ModPDynamics.toPersistenceProfile {p : ℕ} (dyn : ModPDynamics p) (d : ℕ) :
    PersistenceProfile where
  depth := d
  periodicCounts := fun k => (dyn.periodicPoints (k.val + 1)).card
  tailCounts := fun k => dyn.tailCount k.val

/-- The orbit entropy of a mod-p dynamical system, measuring the information content
    of the orbit structure. Connects dynamics to information theory.
    Defined as log(p+1) minus the normalized sum of log(preimage sizes + 1). -/
noncomputable def ModPDynamics.orbitEntropy {p : ℕ} (dyn : ModPDynamics p) : ℝ :=
  Real.log (p + 1 : ℝ) - (1 / (p + 1 : ℝ)) *
    ∑ y : Fin (p + 1), Real.log (dyn.preimageSize y + 1 : ℝ)