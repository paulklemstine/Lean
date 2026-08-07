/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors

/-!
# Reduction of divisors and an unconditional covering radius for the Laplacian lattice

`Catalog/Pythagorean/BrillNoether/Divisors.lean` derives Brill–Noether type
existence statements from the hypothesis `IsCoveringBound G ρ`: every degree-zero
divisor is linearly equivalent to a divisor with at most `ρ` chips of debt at each
vertex.  This file *removes the hypothesis*: every connected graph satisfies
`IsCoveringBound G g`, where `g = #E - #V + 1` is the genus.  Along the way it
proves Riemann's theorem for graphs: a divisor of degree at least `g` is linearly
equivalent to an effective divisor, so `r(D) ≥ deg D - g`.

The proof is a chip-firing argument organised by a strictly decreasing potential.
Fix a vertex `q`.  The key gadget is an explicit integer function `pot q` which
vanishes at `q`, is nonnegative, and is *strictly superharmonic away from `q`*:

`pot q v = (n+1)^n - (n+1)^(n - dist q v)`,  `lap (pot q) v ≥ 1` for `v ≠ q`.

Superharmonicity has two consequences.

* Adding a large multiple of `pot q` to any divisor makes it nonnegative away from
  `q` (`exists_nonneg_off`).
* The pairing `Φ(D) = ∑ v, pot q v * D v` is a nonnegative integer on divisors that
  are nonnegative away from `q`, and firing a set `S` of vertices avoiding `q`
  decreases it by `∑_{v ∈ S} lap (pot q) v ≥ #S` (`phi_fire`).  Hence a divisor
  minimising `Φ` in its linear equivalence class admits no legal set firing, i.e.
  it is `q`-reduced (`exists_reduced`).

For a `q`-reduced divisor one peels the vertices off `V \ {q}` one at a time, each
time using the reducedness condition on the set that is left; the vertex removed
at each step carries fewer chips than the number of edges it sends to the already
removed part, and these edge sets are disjoint.  Summing gives at most
`#E - (#V - 1) = g` chips away from `q` (`sum_le_genus_of_reduced`), which is both
Riemann's theorem and the covering bound.

## Main definitions

* `BrillNoetherReduced.wt` — the exponential weight `(n+1)^(n - dist q v)`.
* `BrillNoetherReduced.pot` — the superharmonic potential `wt q q - wt q v`.
* `BrillNoetherReduced.phi` — the pairing `Φ(D) = ∑ v, pot q v * D v`.
* `BrillNoetherReduced.ind`, `BrillNoetherReduced.outdeg` — set firing data.
* `BrillNoetherReduced.pairCount` — twice the number of edges avoiding a vertex set.

## Main results

* `BrillNoetherReduced.one_le_lap_pot` — strict superharmonicity of `pot q` off `q`.
* `BrillNoetherReduced.exists_nonneg_off` — every divisor is linearly equivalent to
  one that is nonnegative away from `q`.
* `BrillNoetherReduced.exists_reduced` — existence of `q`-reduced divisors in every
  linear equivalence class.
* `BrillNoetherReduced.sum_le_genus_of_reduced` — a `q`-reduced divisor carries at
  most `g` chips away from `q`.
* `BrillNoetherReduced.exists_effective_of_genus_le_deg` — **Riemann's theorem**:
  every divisor of degree at least `g` is linearly equivalent to an effective one.
* `BrillNoetherReduced.rankAtLeast_of_genus_add_le` — **Riemann's inequality**
  `r(D) ≥ deg D - g`.
* `BrillNoetherReduced.isCoveringBound` — **unconditional covering bound**: every
  connected graph satisfies `IsCoveringBound G g`; combined with the mechanism of
  `Divisors.lean` this gives `rankAtLeast_of_deg_large`.
-/

open Finset Matrix BrillNoetherDivisor

namespace BrillNoetherReduced

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Distances in a connected graph -/

omit [DecidableRel G.Adj] in
/-- In a connected graph every distance is smaller than the number of vertices. -/
theorem dist_lt_card (hG : G.Connected) (u v : V) : G.dist u v < Fintype.card V := by
  obtain ⟨p, hlen⟩ := hG.exists_walk_length_eq_dist u v
  have h1 : (p.bypass).length ≤ p.length := SimpleGraph.Walk.length_bypass_le p
  have h2 := (p.bypass_isPath).length_lt
  have h3 : G.dist u v ≤ (p.bypass).length := SimpleGraph.dist_le _
  omega

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Every vertex at positive distance from `q` has a neighbour strictly closer to `q`. -/
theorem exists_adj_dist_lt {q v : V} (h : G.dist q v ≠ 0) :
    ∃ u, G.Adj u v ∧ G.dist q u < G.dist q v := by
  rw [SimpleGraph.dist_comm] at h
  obtain ⟨p, hp⟩ := SimpleGraph.exists_walk_of_dist_ne_zero h
  cases p with
  | nil => simp at h
  | @cons _ w _ hadj r =>
      refine ⟨w, hadj.symm, ?_⟩
      have h1 : G.dist w q ≤ r.length := SimpleGraph.dist_le r
      simp only [SimpleGraph.Walk.length_cons] at hp
      have e1 : G.dist q w = G.dist w q := SimpleGraph.dist_comm
      have e2 : G.dist q v = G.dist v q := SimpleGraph.dist_comm
      omega

/-! ## The superharmonic potential -/

/-- The exponential weight `(n+1) ^ (n - dist q v)`, where `n = #V`. -/
noncomputable def wt (q v : V) : ℤ := ((Fintype.card V : ℤ) + 1) ^ (Fintype.card V - G.dist q v)

/-- The potential attached to the base vertex `q`: it vanishes at `q`, is
nonnegative, and is strictly superharmonic away from `q`. -/
noncomputable def pot (q v : V) : ℤ := wt G q q - wt G q v

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma one_le_wt (q v : V) : 1 ≤ wt G q v := by
  refine one_le_pow₀ ?_
  have : (0 : ℤ) ≤ (Fintype.card V : ℤ) := Int.natCast_nonneg _
  linarith

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma wt_le_wt_self (q v : V) : wt G q v ≤ wt G q q := by
  have hb : (1 : ℤ) ≤ (Fintype.card V : ℤ) + 1 := by
    have : (0 : ℤ) ≤ (Fintype.card V : ℤ) := Int.natCast_nonneg _
    linarith
  refine pow_le_pow_right₀ hb ?_
  simp

omit [DecidableEq V] [DecidableRel G.Adj] in
@[simp] lemma pot_self (q : V) : pot G q q = 0 := by simp [pot]

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma pot_nonneg (q v : V) : 0 ≤ pot G q v := by
  have := wt_le_wt_self G q v
  simp only [pot]; linarith

/-- The Laplacian of a function, written as a sum of differences over the
neighbourhood. -/
lemma lap_eq_sum_sub (f : V → ℤ) (v : V) :
    lap G f v = ∑ u ∈ G.neighborFinset v, (f v - f u) := by
  rw [lap_apply, Finset.sum_sub_distrib]
  simp [SimpleGraph.card_neighborFinset_eq_degree, mul_comm]

/-- **Strict superharmonicity.**  For every vertex `v ≠ q` of a connected graph,
`lap (pot q) v ≥ 1`. -/
theorem one_le_lap_pot (hG : G.Connected) {q v : V} (hv : v ≠ q) :
    1 ≤ lap G (pot G q) v := by
  have hdist : G.dist q v ≠ 0 := by
    intro h
    exact hv ((hG.dist_eq_zero_iff).mp h).symm
  obtain ⟨u₀, hadj, hlt⟩ := exists_adj_dist_lt G hdist
  -- rewrite the Laplacian as `∑_{u ~ v} wt u - deg v * wt v`
  have hlap : lap G (pot G q) v
      = (∑ u ∈ G.neighborFinset v, wt G q u) - (G.degree v : ℤ) * wt G q v := by
    rw [lap_eq_sum_sub]
    have : ∀ u ∈ G.neighborFinset v, pot G q v - pot G q u = wt G q u - wt G q v := by
      intro u _; simp only [pot]; ring
    rw [Finset.sum_congr rfl this, Finset.sum_sub_distrib]
    simp [SimpleGraph.card_neighborFinset_eq_degree, mul_comm]
  -- the neighbour `u₀` closer to `q` carries a weight `(n+1)` times larger
  have hu₀mem : u₀ ∈ G.neighborFinset v := by
    simpa [SimpleGraph.mem_neighborFinset] using hadj.symm
  have hbig : ((Fintype.card V : ℤ) + 1) * wt G q v ≤ wt G q u₀ := by
    have hb : (1 : ℤ) ≤ (Fintype.card V : ℤ) + 1 := by
      have : (0 : ℤ) ≤ (Fintype.card V : ℤ) := Int.natCast_nonneg _
      linarith
    have hdv : G.dist q v < Fintype.card V := dist_lt_card G hG q v
    have hexp : Fintype.card V - G.dist q v + 1 ≤ Fintype.card V - G.dist q u₀ := by omega
    calc ((Fintype.card V : ℤ) + 1) * wt G q v
        = ((Fintype.card V : ℤ) + 1) ^ (Fintype.card V - G.dist q v + 1) := by
          rw [wt, pow_succ]; ring
      _ ≤ ((Fintype.card V : ℤ) + 1) ^ (Fintype.card V - G.dist q u₀) :=
          pow_le_pow_right₀ hb hexp
      _ = wt G q u₀ := rfl
  have hsum : wt G q u₀ ≤ ∑ u ∈ G.neighborFinset v, wt G q u :=
    Finset.single_le_sum (fun u _ => le_trans zero_le_one (one_le_wt G q u)) hu₀mem
  -- the degree is at most `n - 1`
  have hdeg : (G.degree v : ℤ) + 1 ≤ (Fintype.card V : ℤ) := by
    have := G.degree_lt_card_verts v
    exact_mod_cast this
  have hwt1 : 1 ≤ wt G q v := one_le_wt G q v
  nlinarith [hsum, hbig, hwt1, hdeg]

/-! ## Making a divisor nonnegative away from `q` -/

lemma lap_const_mul (c : ℤ) (f : V → ℤ) (v : V) :
    lap G (fun u => c * f u) v = c * lap G f v := by
  simp only [lap_apply]
  rw [← Finset.mul_sum]
  ring

/-- **Every divisor is linearly equivalent to one that is nonnegative away from
`q`.**  Add a large multiple of the superharmonic potential. -/
theorem exists_nonneg_off (hG : G.Connected) (q : V) (D : Divisor V) :
    ∃ f : V → ℤ, ∀ v, v ≠ q → 0 ≤ (D + lap G f) v := by
  classical
  set c : ℤ := ∑ u, |D u| with hc
  have hcnn : 0 ≤ c := Finset.sum_nonneg fun u _ => abs_nonneg _
  refine ⟨fun u => c * pot G q u, fun v hv => ?_⟩
  have h1 : 1 ≤ lap G (pot G q) v := one_le_lap_pot G hG hv
  have h2 : lap G (fun u => c * pot G q u) v = c * lap G (pot G q) v :=
    lap_const_mul G c (pot G q) v
  have h3 : |D v| ≤ c := Finset.single_le_sum (fun u _ => abs_nonneg (D u)) (Finset.mem_univ v)
  have h4 : -D v ≤ |D v| := neg_le_abs _
  have h5 : c ≤ c * lap G (pot G q) v := le_mul_of_one_le_right hcnn h1
  simp only [Pi.add_apply, h2]
  linarith

/-! ## The energy pairing with the potential, and reduced divisors -/

/-- The pairing `Φ(D) = ∑ v, pot q v * D v`. -/
noncomputable def phi (q : V) (D : Divisor V) : ℤ := ∑ v, pot G q v * D v

omit [DecidableRel G.Adj] in
/-- On divisors that are nonnegative away from `q`, the pairing is nonnegative. -/
lemma phi_nonneg {q : V} {D : Divisor V} (h : ∀ v, v ≠ q → 0 ≤ D v) : 0 ≤ phi G q D := by
  refine Finset.sum_nonneg fun v _ => ?_
  by_cases hv : v = q
  · subst hv; simp
  · exact mul_nonneg (pot_nonneg G q v) (h v hv)

/-- The Laplacian is self-adjoint for the standard pairing. -/
lemma lap_self_adjoint (x y : V → ℤ) : ∑ v, x v * lap G y v = ∑ v, lap G x v * y v := by
  have h1 : ∑ v, x v * lap G y v = x ⬝ᵥ (G.lapMatrix ℤ *ᵥ y) := rfl
  have h2 : ∑ v, lap G x v * y v = (G.lapMatrix ℤ *ᵥ x) ⬝ᵥ y := rfl
  rw [h1, h2, Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose,
    show (G.lapMatrix ℤ)ᵀ = G.lapMatrix ℤ from G.isSymm_lapMatrix]

/-! ## Firing sets of vertices -/

/-- The indicator divisor of a set of vertices. -/
def ind (S : Finset V) : Divisor V := fun u => if u ∈ S then 1 else 0

/-- The number of edges joining `v` to a vertex outside `S`. -/
def outdeg (S : Finset V) (v : V) : ℕ := #(G.neighborFinset v \ S)

lemma sum_ind_neighbors (S : Finset V) (v : V) :
    ∑ u ∈ G.neighborFinset v, ind S u = (#(G.neighborFinset v ∩ S) : ℤ) := by
  simp [ind]

/-- Firing `S` costs a vertex of `S` exactly the number of its edges leaving `S`. -/
lemma lap_ind_mem {S : Finset V} {v : V} (hv : v ∈ S) :
    lap G (ind S) v = (outdeg G S v : ℤ) := by
  have h2 : #(G.neighborFinset v \ S) + #(G.neighborFinset v ∩ S) = G.degree v := by
    rw [Finset.card_sdiff_add_card_inter]
    exact G.card_neighborFinset_eq_degree v
  rw [lap_apply, sum_ind_neighbors, outdeg]
  have h1 : ind S v = 1 := by simp [ind, hv]
  rw [h1, ← h2]
  push_cast
  ring

/-- Firing `S` never harms a vertex outside `S`. -/
lemma lap_ind_nonpos {S : Finset V} {v : V} (hv : v ∉ S) : lap G (ind S) v ≤ 0 := by
  rw [lap_apply, sum_ind_neighbors]
  have h1 : ind S v = 0 := by simp [ind, hv]
  rw [h1]
  simp

/-- Firing the set `S` decreases the pairing by `∑_{v ∈ S} lap (pot q) v`. -/
lemma phi_fire (q : V) (D : Divisor V) (S : Finset V) :
    phi G q (D - lap G (ind S)) = phi G q D - ∑ v ∈ S, lap G (pot G q) v := by
  have hsplit : phi G q (D - lap G (ind S))
      = phi G q D - ∑ v, pot G q v * lap G (ind S) v := by
    simp only [phi, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]
  rw [hsplit, lap_self_adjoint]
  congr 1
  simp [ind, mul_ite, Finset.sum_ite_mem]

/-- **Existence of `q`-reduced divisors.**  Every divisor of a connected graph is
linearly equivalent to a divisor `D'` which is nonnegative away from `q` and which
cannot be fired: for every nonempty set `S` of vertices avoiding `q` there is a
vertex `v ∈ S` with fewer chips than edges leaving `S`. -/
theorem exists_reduced (hG : G.Connected) (q : V) (D : Divisor V) :
    ∃ f : V → ℤ, (∀ v, v ≠ q → 0 ≤ (D + lap G f) v) ∧
      (∀ S : Finset V, S ⊆ univ.erase q → S.Nonempty →
        ∃ v ∈ S, (D + lap G f) v < (outdeg G S v : ℤ)) := by
  classical
  set P : ℕ → Prop := fun m => ∃ f : V → ℤ, (∀ v, v ≠ q → 0 ≤ (D + lap G f) v) ∧
      phi G q (D + lap G f) = (m : ℤ) with hP
  have hex : ∃ m, P m := by
    obtain ⟨f, hf⟩ := exists_nonneg_off G hG q D
    refine ⟨(phi G q (D + lap G f)).toNat, f, hf, ?_⟩
    exact (Int.toNat_of_nonneg (phi_nonneg G hf)).symm
  obtain ⟨f₀, hf₀nonneg, hf₀phi⟩ := Nat.find_spec hex
  refine ⟨f₀, hf₀nonneg, fun S hS hSne => ?_⟩
  by_contra hcon
  push_neg at hcon
  set D' : Divisor V := D + lap G f₀ with hD'
  set f₁ : V → ℤ := f₀ - ind S with hf₁
  have hDD : D + lap G f₁ = D' - lap G (ind S) := by
    rw [hD', hf₁, lap_sub G f₀ (ind S)]; abel
  -- firing `S` keeps the divisor nonnegative away from `q`
  have hnew : ∀ u, u ≠ q → 0 ≤ (D + lap G f₁) u := by
    intro u hu
    rw [hDD]
    simp only [Pi.sub_apply]
    by_cases huS : u ∈ S
    · have h1 := hcon u huS
      rw [lap_ind_mem G huS]
      simp only [hD'] at h1 ⊢
      linarith
    · have h1 := lap_ind_nonpos G huS
      have h2 := hf₀nonneg u hu
      simp only [hD'] at h2 ⊢
      linarith
  -- but strictly decreases the pairing
  have hdec : phi G q (D + lap G f₁) = phi G q D' - ∑ v ∈ S, lap G (pot G q) v := by
    rw [hDD]; exact phi_fire G q D' S
  have hpos : (1 : ℤ) ≤ ∑ v ∈ S, lap G (pot G q) v := by
    have hcard : 1 ≤ #S := Finset.card_pos.mpr hSne
    have hterm : ∀ v ∈ S, (1 : ℤ) ≤ lap G (pot G q) v := fun v hv =>
      one_le_lap_pot G hG (Finset.ne_of_mem_erase (hS hv))
    calc (1 : ℤ) ≤ (#S : ℤ) := by exact_mod_cast hcard
      _ = ∑ _v ∈ S, (1 : ℤ) := by simp
      _ ≤ ∑ v ∈ S, lap G (pot G q) v := Finset.sum_le_sum hterm
  have hnn : 0 ≤ phi G q (D + lap G f₁) := phi_nonneg G hnew
  set m₁ : ℕ := (phi G q (D + lap G f₁)).toNat with hm₁
  have hm₁val : phi G q (D + lap G f₁) = (m₁ : ℤ) := (Int.toNat_of_nonneg hnn).symm
  have hPm₁ : P m₁ := ⟨f₁, hnew, hm₁val⟩
  have hlt : m₁ < Nat.find hex := by
    have h1 : (m₁ : ℤ) < ((Nat.find hex : ℕ) : ℤ) := by
      rw [← hm₁val, ← hf₀phi, hdec, hD']
      linarith
    exact_mod_cast h1
  exact Nat.find_min hex hlt hPm₁

/-! ## Counting the edges met by a set of vertices -/

/-- Twice the number of edges with both endpoints outside `S`. -/
def pairCount (S : Finset V) : ℤ := ∑ i ∈ Sᶜ, ∑ j ∈ Sᶜ, if G.Adj i j then 1 else 0

lemma pairCount_nonneg (S : Finset V) : 0 ≤ pairCount G S :=
  Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => by positivity

lemma sum_adj_indicator (i : V) (T : Finset V) :
    ∑ j ∈ T, (if G.Adj i j then (1 : ℤ) else 0) = (#(G.neighborFinset i ∩ T) : ℤ) := by
  rw [Finset.sum_boole]
  have hfilter : T.filter (fun j => G.Adj i j) = G.neighborFinset i ∩ T := by
    ext j
    simp [SimpleGraph.mem_neighborFinset, and_comm]
  rw [hfilter]

/-- With no vertices removed, the count is twice the number of edges. -/
lemma pairCount_empty : pairCount G ∅ = 2 * (#G.edgeFinset : ℤ) := by
  have hdeg : ∀ i : V, ∑ j : V, (if G.Adj i j then (1 : ℤ) else 0) = (G.degree i : ℤ) := by
    intro i
    rw [sum_adj_indicator, Finset.inter_univ, SimpleGraph.card_neighborFinset_eq_degree]
  have hsum : ∑ i : V, (G.degree i : ℤ) = 2 * (#G.edgeFinset : ℤ) := by
    have := G.sum_degrees_eq_twice_card_edges
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) this
  rw [pairCount, Finset.compl_empty]
  rw [Finset.sum_congr rfl fun i _ => hdeg i, hsum]

/-- Removing a vertex `v` from `S` frees exactly the `outdeg S v` edges from `v` to
the complement of `S`, each counted in both orders. -/
lemma pairCount_erase {S : Finset V} {v : V} (hv : v ∈ S) :
    pairCount G (S.erase v) = pairCount G S + 2 * (outdeg G S v : ℤ) := by
  classical
  have hcompl : (S.erase v)ᶜ = insert v Sᶜ := by
    ext u
    by_cases h : u = v <;> simp [h, hv]
  have hvnot : v ∉ (Sᶜ : Finset V) := by simp [hv]
  have hX : ∑ j ∈ (Sᶜ : Finset V), (if G.Adj v j then (1 : ℤ) else 0)
      = (outdeg G S v : ℤ) := by
    rw [sum_adj_indicator, outdeg]
    congr 2
    ext j
    simp [Finset.mem_sdiff]
  have hY : ∑ i ∈ (Sᶜ : Finset V), (if G.Adj i v then (1 : ℤ) else 0)
      = (outdeg G S v : ℤ) := by
    rw [← hX]
    exact Finset.sum_congr rfl fun i _ => by simp [G.adj_comm]
  have hloop : (if G.Adj v v then (1 : ℤ) else 0) = 0 := by simp
  rw [pairCount, hcompl]
  simp only [Finset.sum_insert hvnot]
  rw [Finset.sum_add_distrib, hloop, hX, hY]
  simp only [pairCount]
  ring

/-! ## The degree of a reduced divisor and Riemann's theorem -/

/-- The greedy edge count: peeling off the vertices supplied by the reducedness
condition one at a time bounds the number of chips outside `q`. -/
lemma sum_le_of_reduced {q : V} {D : Divisor V}
    (hred : ∀ S : Finset V, S ⊆ univ.erase q → S.Nonempty →
      ∃ v ∈ S, D v < (outdeg G S v : ℤ)) :
    ∀ S : Finset V, S ⊆ univ.erase q →
      2 * (∑ v ∈ S, D v) + pairCount G S + 2 * (#S : ℤ) ≤ pairCount G ∅ := by
  intro S
  induction S using Finset.strongInduction with
  | _ S ih =>
    intro hS
    rcases S.eq_empty_or_nonempty with rfl | hSne
    · simp
    · obtain ⟨v, hvS, hv⟩ := hred S hS hSne
      have hsub : S.erase v ⊂ S := Finset.erase_ssubset hvS
      have hIH := ih (S.erase v) hsub (subset_trans (Finset.erase_subset _ _) hS)
      have hsum : ∑ u ∈ S, D u = D v + ∑ u ∈ S.erase v, D u :=
        (Finset.add_sum_erase _ _ hvS).symm
      have hcard : (#S : ℤ) = (#(S.erase v) : ℤ) + 1 := by
        have h1 : #(S.erase v) + 1 = #S := by
          rw [Finset.card_erase_of_mem hvS]
          have : 1 ≤ #S := Finset.card_pos.mpr hSne
          omega
        exact_mod_cast h1.symm
      have hpc := pairCount_erase G hvS
      linarith

/-- **A reduced divisor carries at most `g` chips away from `q`.** -/
theorem sum_le_genus_of_reduced [Nonempty V] {q : V} {D : Divisor V}
    (hred : ∀ S : Finset V, S ⊆ univ.erase q → S.Nonempty →
      ∃ v ∈ S, D v < (outdeg G S v : ℤ)) :
    ∑ v ∈ univ.erase q, D v ≤ genus G := by
  have h := sum_le_of_reduced G hred (univ.erase q) (subset_refl _)
  have h0 := pairCount_nonneg G (univ.erase q)
  have he := pairCount_empty G
  have hc : (#(univ.erase q) : ℤ) = (Fintype.card V : ℤ) - 1 := by
    have h1 : #(univ.erase q) + 1 = Fintype.card V := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ q), Finset.card_univ]
      have : 1 ≤ Fintype.card V := Fintype.card_pos
      omega
    have h2 : ((#(univ.erase q) + 1 : ℕ) : ℤ) = (Fintype.card V : ℤ) := by exact_mod_cast h1
    push_cast at h2
    linarith
  rw [genus]
  linarith

/-- **Riemann's theorem for graphs.**  On a connected graph, every divisor of
degree at least the genus `g = #E - #V + 1` is linearly equivalent to an effective
divisor. -/
theorem exists_effective_of_genus_le_deg [Nonempty V] (hG : G.Connected) (D : Divisor V)
    (h : genus G ≤ deg D) : ∃ f : V → ℤ, Effective (D + lap G f) := by
  classical
  obtain ⟨q⟩ := ‹Nonempty V›
  obtain ⟨f, hnn, hred⟩ := exists_reduced G hG q D
  set D' : Divisor V := D + lap G f with hD'
  have hdeg : deg D' = deg D := by rw [hD', deg_add, deg_lap, add_zero]
  have hsplit : D' q + ∑ u ∈ univ.erase q, D' u = deg D := by
    have hd : deg D' = D' q + ∑ u ∈ univ.erase q, D' u :=
      (Finset.add_sum_erase _ _ (Finset.mem_univ q)).symm
    rw [← hd, hdeg]
  have hle : ∑ u ∈ univ.erase q, D' u ≤ genus G := sum_le_genus_of_reduced G hred
  refine ⟨f, fun v => ?_⟩
  by_cases hv : v = q
  · subst hv
    simp only [hD'] at hsplit ⊢
    linarith
  · exact hnn v hv

/-- **Riemann's inequality.**  On a connected graph, every divisor of degree at
least `g + r` has Baker–Norine rank at least `r`; equivalently `r(D) ≥ deg D - g`. -/
theorem rankAtLeast_of_genus_add_le [Nonempty V] (hG : G.Connected) {r : ℕ} (D : Divisor V)
    (h : genus G + (r : ℤ) ≤ deg D) : RankAtLeast G D r := by
  intro E hE hdegE
  have hsub : genus G ≤ deg (D - E) := by
    rw [deg_sub, hdegE]; linarith
  obtain ⟨f, hf⟩ := exists_effective_of_genus_le_deg G hG (D - E) hsub
  exact ⟨f, hf⟩

/-! ## The unconditional covering bound -/

/-- **Unconditional covering bound for the Laplacian lattice.**  Every connected
graph satisfies `IsCoveringBound G g`, where `g` is the genus: every degree-zero
divisor is linearly equivalent to a divisor with at most `g` chips of debt at each
vertex. -/
theorem isCoveringBound [Nonempty V] (hG : G.Connected) :
    IsCoveringBound G (genus G).toNat := by
  classical
  intro A hA
  obtain ⟨q⟩ := ‹Nonempty V›
  obtain ⟨f, hnn, hred⟩ := exists_reduced G hG q A
  set A' : Divisor V := A + lap G f with hA'
  have hgnn : 0 ≤ genus G := genus_nonneg G hG
  have hgcast : ((genus G).toNat : ℤ) = genus G := Int.toNat_of_nonneg hgnn
  have hdeg : deg A' = 0 := by rw [hA', deg_add, deg_lap, hA, add_zero]
  have hsplit : A' q + ∑ u ∈ univ.erase q, A' u = 0 := by
    have hd : deg A' = A' q + ∑ u ∈ univ.erase q, A' u :=
      (Finset.add_sum_erase _ _ (Finset.mem_univ q)).symm
    rw [← hd, hdeg]
  have hle : ∑ u ∈ univ.erase q, A' u ≤ genus G := sum_le_genus_of_reduced G hred
  refine ⟨f, fun v => ?_⟩
  rw [hgcast]
  by_cases hv : v = q
  · subst hv
    simp only [hA'] at hsplit ⊢
    linarith
  · have h1 := hnn v hv
    simp only [hA'] at h1 ⊢
    linarith

/-- **Unconditional Brill–Noether-type existence via the covering bound.**  On a
connected graph, every divisor of degree at least `n · (g + r)` has Baker–Norine
rank at least `r`.  (Riemann's inequality `rankAtLeast_of_genus_add_le` is sharper;
this is the statement obtained from the covering radius mechanism of
`Divisors.lean`.) -/
theorem rankAtLeast_of_deg_large [Nonempty V] (hG : G.Connected) {r : ℕ} (D : Divisor V)
    (h : (Fintype.card V : ℤ) * (genus G + (r : ℤ)) ≤ deg D) :
    RankAtLeast G D r := by
  refine rankAtLeast_of_covering G (isCoveringBound G hG) D ?_
  rwa [Int.toNat_of_nonneg (genus_nonneg G hG)]

end BrillNoetherReduced