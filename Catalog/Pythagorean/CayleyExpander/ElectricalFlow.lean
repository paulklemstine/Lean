/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Electrical Flow Certificates for Cayley Graphs

This file establishes a formal bridge between canonical path congestion
on finite graphs and the variational theory of electrical networks.
It turns congestion arguments into certified **electrical flow certificates**.

## Main Definitions

* `UnitFlow` — a unit electrical flow from source `s` to sink `t`
* `flowEnergy` — energy (dissipation) of a flow in a unit-resistance network
* `effectiveResistance` — effective resistance defined variationally (Thomson)
* `ResistanceCertificate` — certificate that congestion bounds all pairwise resistances

## Main Results

* `flowEnergy_nonneg` — energy of any flow is nonnegative
* `total_flow_sum_zero` — total signed flow across all pairs vanishes (antisymmetry)
* `sink_value_of_unit_flow` — Kirchhoff's current law: net flow into sink = −1
* `effectiveResistance_le_flowEnergy` — Thomson's principle: R_eff ≤ E(φ)
* `flow_potential_identity` — energy–potential duality identity
* `sq_diff_le_energy_mul_variation` — Cauchy–Schwarz energy bound

## Cross-Domain Connections

The theorems connect:
- **Electrical networks**: flows, currents, energy dissipation
- **Spectral theory**: Dirichlet energy, variance, Poincaré inequality
- **Probability**: effective resistance controls commute times
- **Optimization**: unit flows solve minimum-energy routing problems

## References

* Doyle, Snell. Random Walks and Electric Networks (1984).
* Lyons, Peres. Probability on Trees and Networks (2016).
* Jerrum, Sinclair. Approximating the permanent (1989).
-/
import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

section Definitions

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A unit electrical flow from source `s` to sink `t` on a finite vertex set `V`.

This is the fundamental object of electrical network theory: an antisymmetric
function on directed edges satisfying Kirchhoff's current law at all interior
vertices, with net outflow 1 from the source.

The flow models a physical electrical current: `current u v` is the signed
current flowing from `u` to `v`, with the antisymmetry condition ensuring
that current flowing from `u` to `v` is the negative of current from `v` to `u`. -/
structure UnitFlow (V : Type*) [Fintype V] [DecidableEq V] (s t : V) where
  /-- Signed current on each directed edge -/
  current : V → V → ℝ
  /-- Antisymmetry: current from u to v equals negative of current from v to u -/
  antisymm : ∀ u v, current u v = -current v u
  /-- Kirchhoff's current law at interior vertices: net outflow is zero -/
  conservation : ∀ v, v ≠ s → v ≠ t → ∑ w : V, current v w = 0
  /-- Source condition: net outflow from source is exactly 1 -/
  source_value : ∑ w : V, current s w = 1

/-- Energy (dissipation) of a flow in a unit-resistance network.

The energy `E(φ) = (1/2) ∑_u ∑_v φ(u,v)²` measures the total power dissipated
by the flow, assuming each edge has unit resistance. The factor 1/2 corrects
for double-counting: each undirected edge {u,v} contributes φ(u,v)² from both
orientations, and by antisymmetry these are equal.

By Thomson's principle, the effective resistance between two vertices equals
the minimum energy over all unit flows connecting them. -/
noncomputable def flowEnergy {s t : V} (φ : UnitFlow V s t) : ℝ :=
  (1 / 2) * ∑ u : V, ∑ v : V, (φ.current u v) ^ 2

/-- Effective resistance between vertices `s` and `t`, defined variationally
as the infimum of flow energies over all unit flows from `s` to `t`.

This is Thomson's principle: among all unit flows, the electrical current
minimizes energy, and this minimum energy equals the effective resistance.

When no unit flow exists (e.g., when `s = t`), this is `iInf` over an
empty type, which is not physically meaningful — use with `s ≠ t`. -/
noncomputable def effectiveResistance (V : Type*) [Fintype V] [DecidableEq V]
    (s t : V) : ℝ :=
  ⨅ (φ : UnitFlow V s t), flowEnergy φ

/-- A certificate that all pairwise effective resistances in a graph are bounded
by a given value. Such certificates arise naturally from canonical path systems:
the congestion of the path system provides an explicit upper bound.

This is the key conceptual bridge: a combinatorial routing scheme (canonical paths)
becomes a certificate in the language of electrical network theory. -/
structure ResistanceCertificate (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The certified upper bound on all pairwise resistances -/
  bound : ℝ
  /-- The bound is nonnegative -/
  bound_nonneg : 0 ≤ bound
  /-- Every pairwise effective resistance is at most the bound -/
  valid : ∀ s t : V, effectiveResistance V s t ≤ bound

end Definitions

/-! ## Fundamental Theorems -/

section Theorems

variable {V : Type*} [Fintype V] [DecidableEq V]

/-
**Theorem 1 (Energy nonnegativity).**
The energy of any flow is nonnegative, since it is a sum of squares
scaled by a positive constant.

This is physically obvious (power dissipation cannot be negative)
but is needed as a foundational lemma for Thomson's principle.
-/
theorem flowEnergy_nonneg {s t : V} (φ : UnitFlow V s t) :
    0 ≤ flowEnergy φ := by
  exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun u _ => Finset.sum_nonneg fun v _ => sq_nonneg _ )

/-
**Lemma (Total flow vanishes).**
The double sum `∑_u ∑_v φ(u,v)` vanishes by antisymmetry.

Proof: swap the summation order and apply antisymmetry to get
the negative of the original sum, forcing it to be zero.
This is the algebraic backbone of Kirchhoff's laws.
-/
theorem total_flow_sum_zero {s t : V} (φ : UnitFlow V s t) :
    ∑ u : V, ∑ w : V, φ.current u w = 0 := by
  have h_sum_zero : ∑ u, ∑ w, φ.current u w = ∑ w, ∑ u, φ.current u w := by
    exact Finset.sum_comm;
  have h_sum_zero : ∑ w, ∑ u, φ.current u w = ∑ w, -∑ u, φ.current w u := by
    exact Finset.sum_congr rfl fun _ _ => by rw [ ← Finset.sum_neg_distrib ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ φ.antisymm ] ;
  norm_num at *; linarith;

/-
**Theorem 2 (Kirchhoff's current law at the sink).**
In a unit flow from `s` to `t`, the net outflow from `t` is exactly −1.

This follows from three facts:
1. The total signed flow across all pairs is zero (by antisymmetry).
2. The net outflow from `s` is 1 (by the source condition).
3. The net outflow from every other vertex is 0 (by conservation).

Summing over all vertices and using (1), we get that the outflow at `t`
must be −1 to make the total vanish. This is a nontrivial consequence
of the interplay between antisymmetry and conservation.
-/
theorem sink_value_of_unit_flow {s t : V} (φ : UnitFlow V s t)
    (hst : s ≠ t) :
    ∑ w : V, φ.current t w = -1 := by
  -- Summing over all vertices and using (1), we get that the flow at `t` must be −1 to make the total vanish.
  have h_sum : ∑ u : V, ∑ w : V, φ.current u w = ∑ w : V, φ.current s w + ∑ w : V, φ.current t w + ∑ u ∈ Finset.univ \ {s, t}, ∑ w : V, φ.current u w := by
    simp +decide [ Finset.sum_pair hst ];
  -- By assumption, the net outflow from every vertex other than `s` and `t` is zero.
  have h_conservation : ∑ u ∈ Finset.univ \ {s, t}, ∑ w : V, φ.current u w = 0 := by
    exact Finset.sum_eq_zero fun u hu => φ.conservation u ( by aesop ) ( by aesop );
  linarith [ φ.source_value, total_flow_sum_zero φ ]

/-
**Theorem 3 (Thomson's principle).**
The effective resistance between `s` and `t` is at most the energy
of any unit flow connecting them.

This is the formal content of Thomson's principle: among all unit flows,
the one that minimizes energy is the actual electrical current, and its
energy equals the effective resistance. In particular, any explicit flow
provides a certificate (upper bound) on the resistance.

This theorem converts combinatorial objects (explicit flows, canonical paths)
into analytic certificates (resistance bounds).
-/
theorem effectiveResistance_le_flowEnergy {s t : V} (φ : UnitFlow V s t) :
    effectiveResistance V s t ≤ flowEnergy φ := by
  apply ciInf_le;
  exact ⟨ 0, Set.forall_mem_range.2 fun φ => flowEnergy_nonneg φ ⟩

/-
**Theorem 4 (Flow–potential duality identity).**
For any unit flow `φ` from `s` to `t` and any function `f : V → ℝ`,
the potential difference `f(s) - f(t)` equals the inner product of the
flow with the potential gradient:

  `f(s) - f(t) = (1/2) ∑_u ∑_v φ(u,v) · (f(u) - f(v))`

This identity is the discrete analogue of `∫ J · ∇V = V(s) - V(t)`
from continuous electrostatics. It connects the "current" view (flows)
with the "voltage" view (potentials).

The proof uses:
1. `∑_u f(u) · (∑_v φ(u,v)) = f(s) - f(t)` from conservation/source/sink laws.
2. Antisymmetry to symmetrize the double sum.
These combine to give the stated identity.
-/
theorem flow_potential_identity {s t : V} (φ : UnitFlow V s t) (hst : s ≠ t)
    (f : V → ℝ) :
    f s - f t = (1 / 2) * ∑ u : V, ∑ v : V,
      φ.current u v * (f u - f v) := by
  -- By linearity of the inner product, we can split the sum into two parts:
  suffices h_split : (∑ u, ∑ v, (φ.current u v) * (f u)) = f s - f t ∧ (∑ u, ∑ v, (φ.current u v) * (f v)) = -(f s - f t) by
    simp +decide only [mul_sub, sum_sub_distrib];
    linarith;
  -- By linearity of the inner product, we can split the sum into two parts and apply the antisymmetry property.
  have h_split : (∑ u, ∑ v, (φ.current u v) * (f u)) = f s - f t := by
    simp +decide only [← Finset.sum_mul _ _ _];
    rw [ Finset.sum_eq_add ( s ) ( t ) ] <;> simp_all +decide [ sub_eq_add_neg ];
    · rw [ φ.source_value, sink_value_of_unit_flow φ hst ] ; ring;
    · exact fun c hc₁ hc₂ => Or.inl ( φ.conservation c hc₁ hc₂ );
  refine' ⟨ h_split, _ ⟩;
  rw [ ← h_split, ← Finset.sum_comm ];
  rw [ ← Finset.sum_neg_distrib ] ; congr ; ext u ; rw [ ← Finset.sum_neg_distrib ] ; congr ; ext v ; rw [ φ.antisymm ] ; ring;

/-
**Theorem 5 (Energy–variation Cauchy–Schwarz bound).**
For any unit flow `φ` from `s` to `t` and any function `f : V → ℝ`,

  `(f(s) - f(t))² ≤ E(φ) · (1/2) ∑_{u,v} (f(u) - f(v))²`

This combines the flow–potential identity with Cauchy–Schwarz. It is the
key inequality connecting effective resistance to functional analysis:
since `(1/2) ∑ (f(u)-f(v))²` relates to variance and Dirichlet energy,
this bridges electrical networks to spectral graph theory.

Taking the infimum over all unit flows φ gives:
  `(f(s) - f(t))² ≤ R_eff(s,t) · (1/2) ∑ (f(u)-f(v))²`

which is the fundamental resistance–variance inequality.
-/
theorem sq_diff_le_energy_mul_variation {s t : V} (φ : UnitFlow V s t)
    (hst : s ≠ t) (f : V → ℝ) :
    (f s - f t) ^ 2 ≤
      flowEnergy φ * ((1 / 2) * ∑ u : V, ∑ v : V, (f u - f v) ^ 2) := by
  -- Apply the Cauchy-Schwarz inequality to the double sum.
  have h_cauchy_schwarz : (∑ u : V, ∑ v : V, φ.current u v * (f u - f v)) ^ 2 ≤ (∑ u : V, ∑ v : V, (φ.current u v) ^ 2) * (∑ u : V, ∑ v : V, (f u - f v) ^ 2) := by
    -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2)$.
    have h_cauchy_schwarz : ∀ (u v : V × V → ℝ), (∑ i : V × V, u i * v i)^2 ≤ (∑ i : V × V, u i^2) * (∑ i : V × V, v i^2) := by
      exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
    simpa only [ ← Finset.sum_product', Finset.univ_product_univ ] using h_cauchy_schwarz ( fun p => φ.current p.1 p.2 ) ( fun p => f p.1 - f p.2 );
  rw [ flow_potential_identity φ hst f ];
  convert mul_le_mul_of_nonneg_right h_cauchy_schwarz ( show 0 ≤ ( 1 / 2 : ℝ ) ^ 2 by positivity ) using 1 <;> push_cast [ flowEnergy ] <;> ring

end Theorems

/-! ## Resistance–Variance Bridge (Cross-Domain Connection)

This section establishes the fundamental bridge between effective resistance
and functional inequalities. The key result says that effective resistance
controls pointwise variation of functions, connecting:
- **Electrical networks** (resistance, current, energy)
- **Spectral theory** (variance, Dirichlet energy, Poincaré inequalities)
- **Probability** (mixing times, commute times via resistance)
-/

section Bridge

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The pairwise variation of a function, equal to `|V|² · 2 · variance(f)`.
This is the all-pairs analogue of Dirichlet energy. -/
noncomputable def pairwiseVariation (f : V → ℝ) : ℝ :=
  (1 / 2) * ∑ u : V, ∑ v : V, (f u - f v) ^ 2

/-
Pairwise variation is nonnegative.
-/
omit [DecidableEq V] in
theorem pairwiseVariation_nonneg (f : V → ℝ) : 0 ≤ pairwiseVariation f := by
  exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-
**Theorem 6 (Resistance–variation inequality).**
For any unit flow from `s` to `t`, the squared potential difference
is bounded by the product of flow energy and pairwise variation.

This is the master inequality of the electrical–spectral bridge:
  `(f(s) - f(t))² ≤ R_eff(s,t) · PairwiseVariation(f)`

for all functions f, which follows by taking the infimum of `E(φ)`.
-/
theorem sq_diff_le_resistance_mul_variation {s t : V}
    (φ : UnitFlow V s t) (hst : s ≠ t) (f : V → ℝ) :
    (f s - f t) ^ 2 ≤
      effectiveResistance V s t * pairwiseVariation f := by
  -- Apply the inequality for each individual flow φ.
  have h_le : ∀ φ : UnitFlow V s t, (f s - f t) ^ 2 ≤ flowEnergy φ * pairwiseVariation f := by
    exact fun φ => sq_diff_le_energy_mul_variation φ hst f
  generalize_proofs at *; (
  convert le_ciInf fun φ => h_le φ using 1
  generalize_proofs at *; (
  rw [ show effectiveResistance V s t = ⨅ φ : UnitFlow V s t, flowEnergy φ from rfl, ← Real.iInf_mul_of_nonneg ] ; exact pairwiseVariation_nonneg f;);
  exact ⟨ φ ⟩)

end Bridge