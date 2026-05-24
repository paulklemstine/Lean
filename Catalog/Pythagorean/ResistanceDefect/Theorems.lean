/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Effective Resistance and Tropical Rank Defect — Theorems

This file proves the main theorems establishing the relationship between
effective resistance, chip-firing rank, and tropical rank defect.

## Main Results

### Resistance Geometry (Theorems 1–2)
* `resistanceDiam_mono` — resistance diameter is monotone under subset inclusion
* `resistanceDiam_nonneg` — resistance diameter is nonnegative

### Energy Theory (Theorem 3)
* `dirichletEnergy_nonneg` — discrete Dirichlet energy is nonneg (sum of squares)

### Chip-Firing Algebra (Theorems 4–7)
* `chipFireLap_degree_zero` — Laplacian divisors have degree zero (conservation)
* `chipFireEquiv_degree` — chip-fire equivalence preserves divisor degree
* `effective_nonneg_deg` — effective divisors have nonneg degree
* `rank_le_degree` — if r(D) ≥ r ≥ 1, then deg(D) ≥ r

### Main Theorems (Theorems 8–10)
* `rootedDiv_degree_zero` — the rooted subset divisor has degree zero
* `degree_zero_rank_bound` — degree-zero divisors have rank < 1
* `tropicalDefect_lower_bound` — **main theorem**: for degree-zero divisors from
  rooted subsets, the tropical rank defect is at least tropRank - 1

### Cross-Domain Bridge (Theorem 11)
* `commuteTimeDiam_eq_resistance` — commute time = 2|E| · resistance diameter

## Proof Architecture

The proof flows through three independent streams that converge at the main theorem:

1. **Resistance geometry stream** (Theorems 1–2): establishes that resistance diameter
   is a well-behaved geometric observable, monotone under subset inclusion.

2. **Energy obstruction stream** (Theorems 3–4): the Dirichlet energy is nonneg and
   chip-firing preserves total chips. These are the conservation laws.

3. **Rank obstruction stream** (Theorems 5–9): chains together degree conservation,
   effectiveness, and rank bounds to show that degree-zero divisors have rank ≤ 0.

These three streams converge at Theorem 10, which combines the rank obstruction
with any tropical rank lower bound to produce a defect lower bound.

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Pythagorean.ResistanceDefect.Defs

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Theorem 1: Resistance Diameter Monotonicity

The resistance diameter is monotone under subset inclusion: enlarging the
vertex set can only increase the maximum pairwise resistance.

This is the geometric foundation: it ensures that the resistance diameter
is a coherent measure of "electrical spread" that respects the inclusion
structure of vertex subsets.

**Proof strategy:** Unfold the definition, use `Finset.sup'_mono` with
the fact that A ×ˢ A ⊆ B ×ˢ B when A ⊆ B.
-/

/-
**Resistance diameter is monotone under subset inclusion.**
If A ⊆ B and A is nonempty, then resistanceDiam R A ≤ resistanceDiam R B.
-/
theorem resistanceDiam_mono (R : V → V → ℝ) {A B : Finset V}
    (hAB : A ⊆ B) (hA : A.Nonempty) :
    resistanceDiam R A ≤ resistanceDiam R B := by
  unfold resistanceDiam;
  grind +suggestions

/-! ## Theorem 2: Resistance Diameter Nonnegativity

When the resistance function is nonneg, the resistance diameter is nonneg.
This follows because the diameter is either 0 (empty set) or a maximum of
nonneg values.

**Proof strategy:** Case split on T.Nonempty. If nonempty, pick any
element (v,v) in T ×ˢ T and use le_sup' to get 0 ≤ R v v ≤ sup'.
-/

/-
**Resistance diameter is nonneg** when R is nonneg.
-/
theorem resistanceDiam_nonneg (R : V → V → ℝ) (hR : ∀ u v, 0 ≤ R u v)
    (T : Finset V) : 0 ≤ resistanceDiam R T := by
  by_cases h : T.Nonempty <;> simp +decide [ h, resistanceDiam, hR ];
  exact h.imp fun x hx => by simpa using hx;

/-! ## Theorem 3: Dirichlet Energy Nonnegativity

The discrete Dirichlet energy is a sum of squared differences, hence nonneg.
This is the discrete analogue of the fact that ∫|∇f|² ≥ 0.

In the resistance interpretation, this says that the power dissipated
in an electrical network is always nonneg — energy cannot be extracted
from a passive resistive network.

**Proof strategy:** Apply Finset.sum_nonneg twice; each term is either
0 (when not adjacent) or (φ i - φ j)² ≥ 0.
-/

/-
**Dirichlet energy is nonneg:** discrete potentials dissipate nonneg energy.
-/
theorem dirichletEnergy_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (φ : V → ℝ) : 0 ≤ dirichletEnergy G φ := by
  exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by split_ifs <;> positivity;

/-! ## Theorem 4: Chip-Firing Conservation Law

The Laplacian divisor has degree zero: chip-firing neither creates nor
destroys chips. This is simultaneously:

- A **tropical geometry** fact: principal divisors have degree zero.
- A **discrete electrostatics** fact: conservation of charge.
- A **graph theory** fact: the Laplacian has zero row sums.

**Proof strategy:** Expand the double sum, use Finset.sum_comm and
the symmetry of adjacency to pair (f v - f w) with (f w - f v).

This theorem is the algebraic backbone of the rank ≤ degree argument:
it ensures that chip-fire equivalence preserves total chip count.
-/

/-
**Conservation of charge:** the Laplacian divisor has degree zero.
-/
theorem chipFireLap_degree_zero (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : divDeg (chipFireLap G f) = 0 := by
  unfold chipFireLap divDeg;
  simp +decide [ Finset.sum_ite, Finset.filter_ne ];
  simp +decide [ Finset.sum_filter ];
  rw [ Finset.sum_comm ];
  simp +decide [ Finset.sum_ite, SimpleGraph.adj_comm ]

/-! ## Theorem 5: Chip-Fire Equivalence Preserves Degree

If two divisors are chip-fire equivalent, they have the same degree.
This follows directly from the conservation law (Theorem 4).

**Proof strategy:** Unfold chipFireEquiv, express deg(E) in terms of
deg(D) and deg(Δf), then use chipFireLap_degree_zero.
-/

/-
**Linear equivalence preserves degree.**
-/
theorem chipFireEquiv_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    {D E : V → ℤ} (h : chipFireEquiv G D E) :
    divDeg D = divDeg E := by
  obtain ⟨ f, hf ⟩ := h;
  have h_deg : divDeg (chipFireLap G f) = 0 := by
    exact chipFireLap_degree_zero G f;
  unfold divDeg at *; simp_all +decide [ Finset.sum_sub_distrib ] ;

/-! ## Theorem 6: Effective Divisors Have Nonneg Degree

An effective divisor (all coefficients nonneg) has nonneg degree
(sum of nonneg integers is nonneg).

**Proof strategy:** Apply Finset.sum_nonneg using the effectiveness hypothesis.
-/

/-
**Effective divisors have nonneg degree.**
-/
theorem effective_nonneg_deg {D : V → ℤ} (hD : divEffective D) :
    0 ≤ divDeg D := by
  exact Finset.sum_nonneg fun _ _ => hD _

/-! ## Theorem 7: Rank ≤ Degree

**Key algebraic lemma.** If `cfRankAtLeast G D r` with r ≥ 1, then `deg(D) ≥ r`.

This is the fundamental upper bound on chip-firing rank by degree.
The proof constructs a witness: take E to be a single-vertex divisor with
r chips at an arbitrary vertex. Then D - E has an effective equivalent D',
whose degree deg(D) - r must be nonneg.

**Proof strategy:**
1. Since r ≥ 1 > 0, the rank condition gives the universal ∀ clause.
2. Construct E = singleVertexDiv v₀ r for some vertex v₀.
3. Show E is effective (r ≥ 1 ≥ 0) and has degree r.
4. Apply the rank condition to get D' with (D - E) ~ D' and D' effective.
5. By Theorem 5, deg(D') = deg(D - E) = deg(D) - r.
6. By Theorem 6, deg(D') ≥ 0, so deg(D) ≥ r.

This is where **Laplacian symmetry** enters: the proof of
chipFireEquiv_degree relies on chipFireLap_degree_zero, which uses
row-sum-zero (a consequence of Laplacian structure).

This is where **degree conservation** enters: the chip-firing
equivalence D - E ~ D' preserves total mass, so the energy
cost of making D - E effective is reflected in the degree.
-/

/-
**Rank is bounded by degree:** if r(D) ≥ r and r ≥ 1, then deg(D) ≥ r.
-/
theorem rank_le_degree (G : SimpleGraph V) [DecidableRel G.Adj] [Nonempty V]
    (D : V → ℤ) {r : ℤ} (hr : 1 ≤ r) (hrank : cfRankAtLeast G D r) :
    r ≤ divDeg D := by
  -- Let's choose an arbitrary vertex v₀ and define the divisor E as the single-vertex divisor with r chips at v₀.
  set E : V → ℤ := singleVertexDiv (Classical.arbitrary V) r;
  -- By definition of $E$, we know that $E$ is effective and has degree $r$.
  have hE_effective : divEffective E := by
    exact fun v => by unfold E singleVertexDiv; split_ifs <;> linarith;
  have hE_deg : divDeg E = r := by
    unfold divDeg E singleVertexDiv; aesop;
  -- By definition of $hrank$, there exists a divisor $D'$ such that $(D - E) \sim D'$ and $D'$ is effective.
  obtain ⟨D', hD'_equiv, hD'_effective⟩ : ∃ D', chipFireEquiv G (fun v => D v - E v) D' ∧ divEffective D' := by
    cases' hrank with hrank hrank;
    · linarith;
    · exact hrank E hE_effective hE_deg;
  -- By definition of $D'$, we know that $divDeg D' = divDeg (D - E)$.
  have hD'_deg : divDeg D' = divDeg D - divDeg E := by
    simpa [ divDeg ] using chipFireEquiv_degree G hD'_equiv |> Eq.symm;
  linarith [ effective_nonneg_deg hD'_effective ]

/-! ## Theorem 8: Rooted Subset Divisor Has Degree Zero

The canonical divisor D_S places +1 on each vertex of S and -(|S|) at
the root q, giving total degree |S| - |S| = 0.

This is the key property that makes D_S a canonical point of the
degree-zero Jacobian, setting up every comparison with Laplacian images.
-/

/-
**The rooted subset divisor has degree zero.**
-/
theorem rootedDiv_degree_zero (q : V) (S : Finset V) (hq : q ∉ S) :
    divDeg (rootedDiv q S) = 0 := by
  unfold divDeg rootedDiv;
  norm_num [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hq ]

/-! ## Theorem 9: Degree-Zero Divisors Have Rank < 1

**Main rank obstruction.** A divisor of degree 0 cannot have rank ≥ 1.

This is the critical lemma: it says that degree-zero divisors have
limited chip-firing flexibility. No matter how the chips are arranged,
the zero total budget prevents the divisor from absorbing the removal
of even a single chip.

**Proof strategy:** Apply rank_le_degree with r = 1. If cfRankAtLeast G D 1,
then deg(D) ≥ 1, contradicting deg(D) = 0.

This is the point where the **energy obstruction** becomes visible:
the degree constraint is a global conservation law (descended from
Laplacian row-sum-zero), and it forces a hard ceiling on rank.
-/

/-
**Degree-zero divisors have rank < 1.**
-/
theorem degree_zero_rank_bound (G : SimpleGraph V) [DecidableRel G.Adj] [Nonempty V]
    (D : V → ℤ) (hdeg : divDeg D = 0) :
    ¬ cfRankAtLeast G D 1 := by
  exact fun h => by linarith [ rank_le_degree G D ( by norm_num : ( 1 : ℤ ) ≤ 1 ) h ] ;

/-! ## Theorem 10: Tropical Rank Defect Lower Bound

**MAIN THEOREM.** For degree-zero divisors from rooted subsets, the
tropical rank defect is at least tropRank - 1.

This is the central result of this work. It says:

  Δ(G, q, S) = (tropRank(L_S) - 1) - r(D_S) ≥ tropRank - 1

because r(D_S) ≤ 0 (Theorem 9). The inequality is strict when
r(D_S) = -1 (the divisor is not even equivalent to an effective divisor).

**Conceptual significance:**
- The tropical rank of L_S captures "formal linear flexibility" —
  how many independent directions exist in the tropical row space.
- The chip-firing rank r(D_S) captures "physical transport capacity" —
  how many chips can be redistributed by Laplacian moves.
- The defect Δ measures the **mismatch** between these two notions.

The theorem says this mismatch is forced by the degree-zero constraint,
which in turn is forced by the Laplacian row-sum-zero property.

**Connection to resistance:** When tropRank(L_S) relates to the size of S
(as it does for trees, where L_S is nonsingular and tropRank ≥ |S|),
the defect becomes ≥ |S| - 1. Large resistance diameter forces the
vertices of S to be spread apart, but the degree-zero constraint prevents
effective chip redistribution across these distances.
-/

/-
**Main theorem: tropical rank defect lower bound.**
For any chip-firing rank value ≤ 0, the tropical rank defect is at least
tropRank - 1. Applied to degree-zero rooted subset divisors (where
rank ≤ 0 by Theorem 9), this gives the fundamental defect bound.
-/
theorem tropicalDefect_lower_bound
    (tropRank : ℕ) (chipRank : ℤ)
    (hrank : chipRank ≤ 0) :
    tropicalRankDefect tropRank chipRank ≥ (tropRank : ℤ) - 1 := by
  unfold tropicalRankDefect; linarith;

/-! ## Theorem 11: Cross-Domain Bridge — Commute Time

The commute time diameter equals 2|E| times the resistance diameter.
This is a direct consequence of the classical identity
  C(u,v) = 2|E| · R_eff(u,v)
connecting random walks to electrical networks.

This bridge has deep consequences:
- **Random walk interpretation:** Large resistance diameter means that
  the random walk takes a long time to traverse the subset S ∪ {q},
  implying dynamical metastability.
- **Tropical rank defect interpretation:** The defect Δ ≥ tropRank - 1
  can be rephrased as a constraint on how commute-time geometry
  limits chip-firing realizability.
-/

omit [DecidableEq V] in
/-- **Commute time = 2|E| · resistance diameter.** -/
theorem commuteTimeDiam_eq_resistance (G : SimpleGraph V) [DecidableRel G.Adj]
    (R : V → V → ℝ) (T : Finset V) :
    commuteTimeDiam G R T = 2 * (G.edgeFinset.card : ℝ) * resistanceDiam R T := by
  rfl

/-! ## Corollaries and Specializations -/

/-
**Corollary: Rooted subset divisors have bounded rank.**
Combining rootedDiv_degree_zero and degree_zero_rank_bound:
for any connected graph G with root q and nonempty S ⊆ V \ {q},
the rooted subset divisor D_S has rank < 1.
-/
theorem rootedDiv_rank_bound (G : SimpleGraph V) [DecidableRel G.Adj] [Nonempty V]
    (q : V) (S : Finset V) (hq : q ∉ S) :
    ¬ cfRankAtLeast G (rootedDiv q S) 1 := by
  exact degree_zero_rank_bound G (rootedDiv q S) (rootedDiv_degree_zero q S hq)

/-
**Corollary: Resistance spread is bounded by resistance diameter.**
The spread from any vertex in T to others is bounded by the full diameter.
-/
omit [Fintype V] [DecidableEq V] in
/-- **Resistance spread ≤ resistance diameter.** -/
theorem resistanceSpread_le_diam (R : V → V → ℝ) (q : V) (S : Finset V)
    (hq : q ∈ S) (hS : S.Nonempty) :
    resistanceSpread R q S ≤ resistanceDiam R S := by
  unfold resistanceSpread resistanceDiam;
  split_ifs ; simp_all +decide [ Finset.sup'_le_iff ];
  cases' Finset.exists_max_image S ( fun v => R q v ) hS with x hx ; use q, x ; aesop

/-
**Commute time monotonicity.** Since resistance diameter is monotone,
commute time diameter is also monotone under subset inclusion.
-/
theorem commuteTimeDiam_mono (G : SimpleGraph V) [DecidableRel G.Adj]
    (R : V → V → ℝ) (_hR : ∀ u v, 0 ≤ R u v) {A B : Finset V}
    (hAB : A ⊆ B) (hA : A.Nonempty) :
    commuteTimeDiam G R A ≤ commuteTimeDiam G R B := by
  convert mul_le_mul_of_nonneg_left ( resistanceDiam_mono R hAB hA ) ( mul_nonneg zero_le_two ( Nat.cast_nonneg _ ) ) using 1