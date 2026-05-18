/-
Copyright (c) 2025 Tropical Brill-Noether Formalization Project. All rights reserved.

# Tropical Brill–Noether Theory: Core Definitions

Foundational definitions for tropical Brill–Noether theory:

* The Brill–Noether number `ρ(g, r, d)`,
* Chain-of-loops model for tropical curves,
* Metric chain-of-loops with genericity conditions,
* Divisors, degree, effectiveness, linear equivalence on finite graphs,
* Baker–Norine divisor rank,
* Abstract specialization interface (Baker's lemma).

## References

* [Baker–Norine 2007] Riemann–Roch and Abel–Jacobi theory on a finite graph
* [Cools–Draisma–Payne–Robeva 2012] A tropical proof of the Brill–Noether theorem
* [Baker 2008] Specialization of linear series from curves to graphs
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: The Brill–Noether Number -/

/-- The **Brill–Noether number** `ρ(g, r, d) = g − (r + 1)(g − d + r)`,
    computed over ℤ to avoid truncated subtraction. This number governs the
    expected dimension of the space of divisor classes of degree `d` and
    rank at least `r` on a curve of genus `g`. -/
def brillNoetherNumber (g r d : ℕ) : ℤ :=
  (g : ℤ) - ((r : ℤ) + 1) * ((g : ℤ) - (d : ℤ) + (r : ℤ))

/-- Alternative expanded form: `ρ = (r+1)d − r·g − r(r+1)`. -/
def brillNoetherNumberAlt (g r d : ℕ) : ℤ :=
  ((r : ℤ) + 1) * (d : ℤ) - (r : ℤ) * (g : ℤ) - (r : ℤ) * ((r : ℤ) + 1)

/-! ## Section 2: Chain of Loops Model -/

/-- A **chain of loops** (banana graph): the canonical model for genus `g`.
    The graph has `g + 1` vertices connected in a path, with each consecutive
    pair joined by two edges, giving `g` independent cycles. -/
structure ChainOfLoops where
  genus : ℕ

/-- Vertex type: `Fin (g + 1)`. -/
def ChainOfLoops.VertexType (Γ : ChainOfLoops) : Type := Fin (Γ.genus + 1)

instance (Γ : ChainOfLoops) : Fintype Γ.VertexType := inferInstanceAs (Fintype (Fin _))
instance (Γ : ChainOfLoops) : DecidableEq Γ.VertexType := inferInstanceAs (DecidableEq (Fin _))

/-- A **metric chain of loops** with positive real edge lengths on top and bottom
    edges of each loop. -/
structure MetricChainOfLoops extends ChainOfLoops where
  topLen : Fin genus → ℝ
  botLen : Fin genus → ℝ
  hpos_top : ∀ i, 0 < topLen i
  hpos_bot : ∀ i, 0 < botLen i

/-- **Genericity**: all edge-length ratios `topLen i / botLen i` are pairwise distinct.
    This rules out resonance and ensures the Brill–Noether locus has expected
    dimension. -/
def MetricChainOfLoops.IsGeneric (Γ : MetricChainOfLoops) : Prop :=
  ∀ i j : Fin Γ.genus, i ≠ j → Γ.topLen i / Γ.botLen i ≠ Γ.topLen j / Γ.botLen j

/-- Generic metric chains exist for any positive genus. -/
theorem MetricChainOfLoops.generic_exists (g : ℕ) (_hg : 0 < g) :
    ∃ Γ : MetricChainOfLoops, Γ.genus = g ∧ Γ.IsGeneric := by
  refine ⟨⟨⟨g⟩, fun i => (i : ℝ) + 1, fun _ => 1, fun i => by positivity, fun _ => one_pos⟩,
    rfl, ?_⟩
  intro i j hij
  simp [div_one]
  exact_mod_cast Fin.val_ne_of_ne hij

/-! ## Section 3: Divisors on Finite Graphs -/

/-- A **divisor** on a finite set `V`: an integer-valued function on vertices.
    Represents a formal sum of points on a graph. -/
def GraphDivisor (V : Type*) := V → ℤ

instance {V : Type*} : Add (GraphDivisor V) := ⟨fun D₁ D₂ v => D₁ v + D₂ v⟩
instance {V : Type*} : Sub (GraphDivisor V) := ⟨fun D₁ D₂ v => D₁ v - D₂ v⟩
instance {V : Type*} : Neg (GraphDivisor V) := ⟨fun D v => -D v⟩
instance {V : Type*} : Zero (GraphDivisor V) := ⟨fun _ => 0⟩

@[simp] lemma GraphDivisor.add_apply {V : Type*} (D₁ D₂ : GraphDivisor V) (v : V) :
    (D₁ + D₂) v = D₁ v + D₂ v := rfl
@[simp] lemma GraphDivisor.sub_apply {V : Type*} (D₁ D₂ : GraphDivisor V) (v : V) :
    (D₁ - D₂) v = D₁ v - D₂ v := rfl

/-- The **degree** of a divisor is the sum of its values. -/
def GraphDivisor.degree {V : Type*} [Fintype V] (D : GraphDivisor V) : ℤ :=
  ∑ v, D v

/-- A divisor is **effective** if all vertex values are ≥ 0. -/
def GraphDivisor.isEffective {V : Type*} (D : GraphDivisor V) : Prop :=
  ∀ v, 0 ≤ D v

/-- The **graph Laplacian** of `f : V → ℤ` on a simple graph. -/
def graphLaplacian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : GraphDivisor V :=
  fun v => ∑ w ∈ G.neighborFinset v, (f v - f w)

/-- **Linear equivalence** via chip-firing: two divisors differ by a graph
    Laplacian. -/
def GraphDivisor.linearEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D E : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, E v = D v + graphLaplacian G f v

/-- The **Baker–Norine rank** of a divisor `D` on a graph `G`.
    `rank(D) = -1` if `D` is not linearly equivalent to any effective divisor.
    Otherwise, `rank(D)` is the largest `r` such that `D - E` is linearly
    equivalent to an effective divisor for every effective `E` of degree `r`. -/
noncomputable def GraphDivisor.bnRank {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) : ℤ :=
  sSup {r : ℤ | r = -1 ∨
    (0 ≤ r ∧ ∀ E : GraphDivisor V, E.isEffective → E.degree = r →
      ∃ D' : GraphDivisor V, D'.isEffective ∧ GraphDivisor.linearEquiv G (D - E) D')}

/-! ## Section 4: Abstract Specialization Interface -/

/-- An **abstract specialization datum** axiomatizing Baker's specialization lemma
    without requiring full scheme theory. -/
structure SpecializationDatum where
  /-- The algebraic divisor type. -/
  AlgDiv : Type*
  /-- The tropical divisor type. -/
  TropDiv : Type*
  /-- Degree on algebraic divisors. -/
  algDegree : AlgDiv → ℤ
  /-- Rank on algebraic divisors. -/
  algRank : AlgDiv → ℤ
  /-- Degree on tropical divisors. -/
  tropDegree : TropDiv → ℤ
  /-- Rank on tropical divisors. -/
  tropRank : TropDiv → ℤ
  /-- The specialization/tropicalization map. -/
  specialize : AlgDiv → TropDiv
  /-- Specialization preserves degree. -/
  degree_preserved : ∀ D, tropDegree (specialize D) = algDegree D
  /-- **Baker's specialization inequality**: rank does not decrease. -/
  rank_specialization : ∀ D, algRank D ≤ tropRank (specialize D)

/-- Baker's specialization lemma: existence of ranked divisors is preserved. -/
theorem specialization_preserves_ranked_divisors (S : SpecializationDatum)
    {d r : ℤ} (hD : ∃ D : S.AlgDiv, S.algDegree D = d ∧ r ≤ S.algRank D) :
    ∃ E : S.TropDiv, S.tropDegree E = d ∧ r ≤ S.tropRank E := by
  obtain ⟨D, hd, hr⟩ := hD
  exact ⟨S.specialize D, S.degree_preserved D ▸ hd, le_trans hr (S.rank_specialization D)⟩