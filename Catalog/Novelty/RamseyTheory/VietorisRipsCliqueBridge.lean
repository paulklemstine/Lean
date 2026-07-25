import Mathlib

/-!
# A cross-domain bridge: Vietoris–Rips complexes, extremal graph theory, and information theory

This file builds a bridge between three *a priori* unrelated areas, all meeting at the
combinatorial core of the √2-threshold exponential lower bound for Vietoris–Rips
approximations.

* **Topological data analysis / metric geometry.**  The Vietoris–Rips complex
  `VRcomplex D r` of a dissimilarity `D` at scale `r` is the set of subsets whose
  pairwise dissimilarities are `≤ r`.
* **Extremal graph theory.**  The Vietoris–Rips complex is exactly the *clique complex*
  (flag complex) of the proximity graph `proxGraph D r` whose edges join points within
  distance `r`.  The number of cliques of any graph on `n` vertices is at most `2 ^ n`,
  a bound attained precisely by the complete graph `K_n = ⊤`.
* **Information theory.**  The number of simplices at a level bounds below the number of
  bits needed to address them; via `Nat.clog` this is a genuine description-length
  (Shannon-style) quantity.

The equidistant configuration `equiD √2` — realised metrically by the `n` standard basis
vectors of Euclidean space, pairwise at distance `√2` — sits at the meeting point: its
proximity graph at scale `√2` is the *complete* graph, its Vietoris–Rips complex is the
full power set of `2 ^ n` cliques (the extremal maximum), and therefore every
`c`-approximation with `c < √2` must store a level of at least `n` bits.

## Main results

* `mem_allCliques` — membership in the finite set of all cliques of a graph.
* `VRcomplex_eq_allCliques_proxGraph` — **geometry ↔ graph theory**: the Vietoris–Rips
  complex is the clique complex of the proximity graph.
* `allCliques_card_le` — **extremal graph theory**: any graph on `n` vertices has at
  most `2 ^ n` cliques.
* `allCliques_top` / `card_allCliques_top` — the complete graph attains the maximum, with
  exactly `2 ^ n` cliques.
* `proxGraph_equiD_top` — the proximity graph of the equidistant metric above the gap is
  the complete graph.
* `card_le_two_pow_bitComplexity` / `bitComplexity_ge_of_pow_le` — **information theory**:
  `bitComplexity` really is the number of addressing bits, and it is bounded below by the
  log of the simplex count.
* `approx_bitComplexity_lower_bound` — every `c`-approximation of the equidistant
  Vietoris–Rips filtration has a level of at least `n` bits.
* `vietorisRips_clique_information_bridge` — the headline theorem tying all three
  viewpoints together for the `√2`-equidistant configuration.
-/

noncomputable section

open Finset Classical

namespace VRCliqueBridge

variable {n : ℕ}

/-! ## Vietoris–Rips core (self-contained) -/

/-- A subset `S` is a Vietoris–Rips simplex at scale `r` for `D` when every pair of its
vertices is within `r`. -/
def IsVRsimplex (D : Fin n → Fin n → ℝ) (r : ℝ) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, D i j ≤ r

/-- The Vietoris–Rips complex at scale `r`: the finite set of all its simplices. -/
def VRcomplex (D : Fin n → Fin n → ℝ) (r : ℝ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => IsVRsimplex D r S)

/-- The equidistant dissimilarity: distinct points are at distance `d`. -/
def equiD (d : ℝ) : Fin n → Fin n → ℝ := fun i j => if i = j then 0 else d

/-- A multiplicative `c`-interleaving (`c`-approximation) of the Vietoris–Rips filtration. -/
def IsCApprox (D : Fin n → Fin n → ℝ) (c : ℝ) (G : ℝ → Finset (Finset (Fin n))) : Prop :=
  1 ≤ c ∧
  (∀ t, 0 ≤ t → VRcomplex D t ⊆ G (c * t)) ∧
  (∀ t, 0 ≤ t → G t ⊆ VRcomplex D (c * t))

/-! ## The graph-theoretic side -/

/-- The **proximity graph** of a dissimilarity `D` at scale `r`: distinct points are
adjacent when they are mutually within `r`. -/
def proxGraph (D : Fin n → Fin n → ℝ) (r : ℝ) : SimpleGraph (Fin n) where
  Adj i j := i ≠ j ∧ D i j ≤ r ∧ D j i ≤ r
  symm := by rintro i j ⟨h1, h2, h3⟩; exact ⟨h1.symm, h3, h2⟩
  loopless := ⟨fun i hi => hi.1 rfl⟩

/-- The finite set of **all cliques** of a graph `H` on `Fin n` (its clique complex). -/
def allCliques (H : SimpleGraph (Fin n)) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => H.IsClique (↑S : Set (Fin n)))

/-- The Vietoris–Rips complex viewed as a clique complex. -/
def VRcliqueSet (D : Fin n → Fin n → ℝ) (r : ℝ) : Finset (Finset (Fin n)) :=
  allCliques (proxGraph D r)

/-! ## The information-theoretic side -/

/-- The **bit complexity** of a finite family: the number of bits needed to address its
members, `⌈log₂ |F|⌉`. -/
def bitComplexity {β : Type*} (F : Finset β) : ℕ := Nat.clog 2 F.card

/-! ## Basic membership -/

theorem mem_allCliques (H : SimpleGraph (Fin n)) (S : Finset (Fin n)) :
    S ∈ allCliques H ↔ H.IsClique (↑S : Set (Fin n)) := by
  unfold allCliques
  rw [Finset.mem_filter, Finset.mem_powerset]
  exact ⟨fun h => h.2, fun h => ⟨Finset.subset_univ _, h⟩⟩

/-! ## Geometry ↔ graph theory -/

/-- **Bridge (geometry ↔ graph theory).**  When `D` is within scale on the diagonal, the
Vietoris–Rips complex at scale `r` is exactly the clique complex of the proximity graph.
This is the flag/clique-complex identity underlying Vietoris–Rips homology. -/
theorem VRcomplex_eq_allCliques_proxGraph (D : Fin n → Fin n → ℝ) (r : ℝ)
    (hdiag : ∀ i, D i i ≤ r) :
    VRcomplex D r = allCliques (proxGraph D r) := by
  ext S
  rw [mem_allCliques]
  unfold VRcomplex
  rw [Finset.mem_filter, Finset.mem_powerset]
  constructor
  · rintro ⟨-, hS⟩
    intro i hi j hj hij
    simp only [Finset.mem_coe] at hi hj
    exact ⟨hij, hS i hi j hj, hS j hj i hi⟩
  · intro hS
    refine ⟨Finset.subset_univ _, ?_⟩
    intro i hi j hj
    by_cases hij : i = j
    · subst hij; exact hdiag i
    · exact (hS (Finset.mem_coe.mpr hi) (Finset.mem_coe.mpr hj) hij).2.1

/-! ## Extremal graph theory -/

/-- **Extremal bound.**  Any graph on `n` vertices has at most `2 ^ n` cliques. -/
theorem allCliques_card_le (H : SimpleGraph (Fin n)) :
    (allCliques H).card ≤ 2 ^ n := by
  unfold allCliques
  refine le_trans (Finset.card_filter_le _ _) ?_
  rw [Finset.card_powerset, Finset.card_univ, Fintype.card_fin]

/-- In the complete graph every subset is a clique. -/
theorem allCliques_top :
    allCliques (⊤ : SimpleGraph (Fin n)) = (Finset.univ : Finset (Fin n)).powerset := by
  ext S
  rw [mem_allCliques, Finset.mem_powerset]
  simp only [Finset.subset_univ, iff_true]
  intro i hi j hj hij
  exact (SimpleGraph.top_adj i j).mpr hij

/-- **Extremal maximum.**  The complete graph attains the maximum: it has exactly `2 ^ n`
cliques. -/
theorem card_allCliques_top :
    (allCliques (⊤ : SimpleGraph (Fin n))).card = 2 ^ n := by
  rw [allCliques_top, Finset.card_powerset, Finset.card_univ, Fintype.card_fin]

/-- The complete graph maximises the number of cliques. -/
theorem allCliques_card_le_top (H : SimpleGraph (Fin n)) :
    (allCliques H).card ≤ (allCliques (⊤ : SimpleGraph (Fin n))).card := by
  rw [card_allCliques_top]; exact allCliques_card_le H

/-! ## The equidistant configuration is the extremal case -/

/-- Above the gap, the proximity graph of the equidistant metric is the complete graph. -/
theorem proxGraph_equiD_top (d r : ℝ) (hr : d ≤ r) :
    proxGraph (equiD (n := n) d) r = (⊤ : SimpleGraph (Fin n)) := by
  ext i j
  simp only [SimpleGraph.top_adj]
  constructor
  · rintro ⟨h, -, -⟩; exact h
  · intro hij
    refine ⟨hij, ?_, ?_⟩
    · simp only [equiD, if_neg hij]; exact hr
    · simp only [equiD, if_neg (Ne.symm hij)]; exact hr

/-- Above the gap, the equidistant clique complex has exactly `2 ^ n` cliques. -/
theorem card_VRcliqueSet_equiD (d r : ℝ) (hr : d ≤ r) :
    (VRcliqueSet (equiD (n := n) d) r).card = 2 ^ n := by
  unfold VRcliqueSet
  rw [proxGraph_equiD_top d r hr, card_allCliques_top]

/-! ## Vietoris–Rips exponential count (self-contained) -/

theorem VRcomplex_equiD_eq_powerset (d r : ℝ) (hd : 0 ≤ d) (hr : d ≤ r) :
    VRcomplex (equiD (n := n) d) r = (Finset.univ : Finset (Fin n)).powerset := by
  refine Finset.filter_true_of_mem ?_
  intro S _ i hi j hj
  unfold equiD; split_ifs <;> linarith

theorem card_VRcomplex_equiD_eq (d r : ℝ) (hd : 0 ≤ d) (hr : d ≤ r) :
    (VRcomplex (equiD (n := n) d) r).card = 2 ^ n := by
  rw [VRcomplex_equiD_eq_powerset d r hd hr, Finset.card_powerset, Finset.card_univ,
    Fintype.card_fin]

/-- Any `c`-approximation of the equidistant Vietoris–Rips filtration has a level with at
least `2 ^ n` simplices. -/
theorem approx_card_lower_bound (d c : ℝ) (hd : 0 ≤ d)
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox (equiD d) c G) :
    2 ^ n ≤ (G (c * d)).card := by
  obtain ⟨-, hc₂, -⟩ := h
  have hmono := Finset.card_le_card (hc₂ d hd)
  rw [card_VRcomplex_equiD_eq d d hd le_rfl] at hmono
  exact hmono

/-! ## Information theory -/

/-- `bitComplexity` bits genuinely suffice to address all members of `F`. -/
theorem card_le_two_pow_bitComplexity {β : Type*} (F : Finset β) :
    F.card ≤ 2 ^ bitComplexity F := by
  unfold bitComplexity
  exact Nat.le_pow_clog (by norm_num) F.card

/-- If a family has at least `2 ^ k` members then its bit complexity is at least `k`. -/
theorem bitComplexity_ge_of_pow_le {β : Type*} (F : Finset β) (k : ℕ)
    (h : 2 ^ k ≤ F.card) : k ≤ bitComplexity F := by
  unfold bitComplexity
  have hb : (1 : ℕ) < 2 := by norm_num
  have h2 : (2 : ℕ) ^ k ≤ 2 ^ (Nat.clog 2 F.card) :=
    le_trans h (Nat.le_pow_clog hb F.card)
  exact (Nat.pow_le_pow_iff_right hb).1 h2

/-- **Bridge (→ information theory).**  Every `c`-approximation of the equidistant
Vietoris–Rips filtration has a level requiring at least `n` bits of storage. -/
theorem approx_bitComplexity_lower_bound (d c : ℝ) (hd : 0 ≤ d)
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox (equiD d) c G) :
    n ≤ bitComplexity (G (c * d)) := by
  exact bitComplexity_ge_of_pow_le _ n (approx_card_lower_bound d c hd G h)

/-! ## Headline connector -/

/-- **Headline theorem: a Vietoris–Rips / extremal-graph-theory / information-theory
bridge.**

For the `√2`-equidistant configuration on `n` points (the metric realised by the `n`
standard basis vectors of Euclidean space):

1. *(geometry ↔ graph theory)* its Vietoris–Rips complex at scale `√2` equals the clique
   complex of the complete graph `K_n`;
2. *(extremal graph theory)* the complete graph has exactly `2 ^ n` cliques, and this is
   the maximum possible over *all* graphs on `n` vertices;
3. *(information theory)* consequently every `c`-approximation with `1 ≤ c < √2` has a
   level requiring at least `n` bits of storage;
4. the effective exponent `γ(c) = ½ − log₂ c` governing the sharp √2 threshold is
   positive on the whole regime `1 ≤ c < √2`. -/
theorem vietorisRips_clique_information_bridge
    (c : ℝ) (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2)
    (G : ℝ → Finset (Finset (Fin n)))
    (hG : IsCApprox (equiD (Real.sqrt 2)) c G) :
    VRcomplex (equiD (Real.sqrt 2)) (Real.sqrt 2)
        = allCliques (⊤ : SimpleGraph (Fin n))
      ∧ (allCliques (⊤ : SimpleGraph (Fin n))).card = 2 ^ n
      ∧ (∀ H : SimpleGraph (Fin n), (allCliques H).card ≤ 2 ^ n)
      ∧ n ≤ bitComplexity (G (c * Real.sqrt 2))
      ∧ 0 < (1 : ℝ) / 2 - Real.logb 2 c := by
  have hdiag : ∀ i, equiD (n := n) (Real.sqrt 2) i i ≤ Real.sqrt 2 := by
    intro i; simp only [equiD]; positivity
  have hgamma : 0 < (1 : ℝ) / 2 - Real.logb 2 c := by
    rw [sub_pos, Real.logb_lt_iff_lt_rpow] <;> norm_num
    · rwa [Real.sqrt_eq_rpow] at hc2
    · linarith
  refine ⟨?_, card_allCliques_top, allCliques_card_le,
    approx_bitComplexity_lower_bound (Real.sqrt 2) c (Real.sqrt_nonneg 2) G hG, hgamma⟩
  rw [VRcomplex_eq_allCliques_proxGraph (equiD (Real.sqrt 2)) (Real.sqrt 2) hdiag,
    proxGraph_equiD_top (Real.sqrt 2) (Real.sqrt 2) le_rfl]

end VRCliqueBridge