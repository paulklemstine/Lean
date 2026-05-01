import Mathlib

/-! # CatalogBuild.Speculative.SciFi.Topology

Unified from Topology and Topology_2.
Euler characteristic, planar and toroidal geometry, orientability.
-/}

/-- Euler's formula for connected planar graphs: V - E + F = 2
implies V + F = E + 2. -/
theorem euler_formula_planar (V E F : ℤ)
    (h_euler : V - E + F = 2) : V + F = E + 2 := by
  omega

/-- For a toroidal space station, the Euler characteristic is 0: V - E + F = 0. -/
theorem torus_euler (V E F : ℤ)
    (h_torus : V - E + F = 0) : E = V + F := by
  omega

/-- Corollary: a toroidal station built from triangular panels.
Each triangle has 3 edges, each edge shared by 2 triangles: E = 3F/2.
Combined with V - E + F = 0: V = F/2. -/
theorem torus_triangulation (V E F : ℤ)
    (h_torus : V - E + F = 0)
    (h_edges : 2 * E = 3 * F) :
    2 * V = F := by
  omega

/-- A surface that reverses orientation along some loop is non-orientable.
If traversing a closed path yields orientation reversal, we get a contradiction. -/
theorem orientation_reversal_implies_nonorientable
    {X : Type*} (orientation : X → Prop)
    (p : X)
    (h_reversed : orientation p ↔ ¬ orientation p) :
    False := by
  by_cases h : orientation p
  · exact (h_reversed.mp h) h
  · exact h (h_reversed.mpr h)
