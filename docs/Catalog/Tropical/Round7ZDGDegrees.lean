import Mathlib
import Tropical.Round7ZeroDivisorGraph

/-!
# Round-7, cycle 2: the zero-divisor graph as a graph, and its degree sequence

`Catalog/Tropical/Round7ZeroDivisorGraph.lean` established the vertex/wing
counts of the zero-divisor graph of `ℤ/pqℤ` as `Finset` statements.  This file
upgrades the closure to an honest `SimpleGraph` and proves the sharper
structural facts that the round-7 note only asserted:

* `zdGraph` : the zero-divisor graph of `ℤ/Nℤ` as a `SimpleGraph ℕ` supported on
  the nonzero zero divisors below `N`.
* `adj_iff_cross` : **exact bipartite description** — two vertices are adjacent
  iff they lie in *different* wings.  (Both directions; the hard direction is
  the absence of intra-wing edges.)
* `neighbors_of_mem_wing_p`, `neighbors_of_mem_wing_q` : the neighbourhood of a
  vertex is precisely the opposite wing.
* `degree_of_mem_wing_p`, `degree_of_mem_wing_q` : hence the graph is regular on
  each wing, with degrees `p - 1` and `q - 1`.
* `factor_recovery_from_degrees` : the **degree sequence alone recovers the
  factorisation**: any vertex degree `d` gives a factor `d + 1` of `N`.  This is
  the precise form of the "structural witness" of experiment 327 — and it
  simultaneously exhibits its circularity, since exhibiting even one vertex
  already means exhibiting a nontrivial divisor of `N` (`vertex_gives_factor`).
-/

namespace Round7ZDG

open Finset

variable {p q : ℕ}

/-- The zero-divisor graph of `ℤ/Nℤ`, carried by `ℕ`: the vertices are the
nonzero zero divisors below `N` and `x ~ y` iff `x y ≡ 0 (mod N)`. -/
def zdGraph (N : ℕ) : SimpleGraph ℕ where
  Adj x y := x ∈ vertices N ∧ y ∈ vertices N ∧ x ≠ y ∧ N ∣ x * y
  symm := by
    rintro x y ⟨hx, hy, hxy, hdvd⟩
    exact ⟨hy, hx, hxy.symm, by rwa [Nat.mul_comm]⟩
  loopless := ⟨by rintro x ⟨-, -, hxx, -⟩; exact hxx rfl⟩

theorem zdGraph_adj {N x y : ℕ} :
    (zdGraph N).Adj x y ↔ x ∈ vertices N ∧ y ∈ vertices N ∧ x ≠ y ∧ N ∣ x * y := Iff.rfl

/-- Wing membership implies vertex membership. -/
theorem wing_p_subset_vertices (hp : p.Prime) (hq : q.Prime) :
    wing p (p * q) ⊆ vertices (p * q) := by
  rw [vertices_eq_wing_union hp hq]
  exact Finset.subset_union_left

theorem wing_q_subset_vertices (hp : p.Prime) (hq : q.Prime) :
    wing q (p * q) ⊆ vertices (p * q) := by
  rw [vertices_eq_wing_union hp hq]
  exact Finset.subset_union_right

/-- **Exact bipartite description of the zero-divisor graph.** -/
theorem adj_iff_cross (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x y : ℕ} :
    (zdGraph (p * q)).Adj x y ↔
      (x ∈ wing p (p * q) ∧ y ∈ wing q (p * q)) ∨
        (x ∈ wing q (p * q) ∧ y ∈ wing p (p * q)) := by
  constructor
  · rintro ⟨hx, hy, hxy, hdvd⟩
    rw [vertices_eq_wing_union hp hq, Finset.mem_union] at hx hy
    rcases hx with hx | hx <;> rcases hy with hy | hy
    · exact absurd hdvd (no_intra_edge_p hp hq hpq hx hy)
    · exact Or.inl ⟨hx, hy⟩
    · exact Or.inr ⟨hx, hy⟩
    · exact absurd hdvd (no_intra_edge_q hp hq hpq hx hy)
  · have hdisj := Finset.disjoint_left.mp (wings_disjoint hp hq hpq)
    rintro (⟨hx, hy⟩ | ⟨hx, hy⟩)
    · refine ⟨wing_p_subset_vertices hp hq hx, wing_q_subset_vertices hp hq hy, ?_,
        cross_edge hx hy⟩
      rintro rfl
      exact hdisj hx hy
    · refine ⟨wing_q_subset_vertices hp hq hx, wing_p_subset_vertices hp hq hy, ?_, ?_⟩
      · rintro rfl
        exact hdisj hy hx
      · rw [Nat.mul_comm x y]
        exact cross_edge hy hx

open Classical in
/-- The neighbourhood of a vertex, as a `Finset`. -/
noncomputable def nbhd (N x : ℕ) : Finset ℕ :=
  (vertices N).filter (fun y => (zdGraph N).Adj x y)

/-- The neighbours of a `p`-wing vertex are exactly the `q`-wing. -/
theorem neighbors_of_mem_wing_p (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ wing p (p * q)) : nbhd (p * q) x = wing q (p * q) := by
  classical
  ext y
  simp only [nbhd, Finset.mem_filter]
  constructor
  · rintro ⟨-, hadj⟩
    rcases (adj_iff_cross hp hq hpq).mp hadj with ⟨-, hy⟩ | ⟨hx', -⟩
    · exact hy
    · exact ((Finset.disjoint_left.mp (wings_disjoint hp hq hpq) hx) hx').elim
  · intro hy
    exact ⟨wing_q_subset_vertices hp hq hy, (adj_iff_cross hp hq hpq).mpr (Or.inl ⟨hx, hy⟩)⟩

/-- The neighbours of a `q`-wing vertex are exactly the `p`-wing. -/
theorem neighbors_of_mem_wing_q (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ wing q (p * q)) : nbhd (p * q) x = wing p (p * q) := by
  classical
  ext y
  simp only [nbhd, Finset.mem_filter]
  constructor
  · rintro ⟨-, hadj⟩
    rcases (adj_iff_cross hp hq hpq).mp hadj with ⟨hx', -⟩ | ⟨-, hy⟩
    · exact ((Finset.disjoint_left.mp (wings_disjoint hp hq hpq) hx') hx).elim
    · exact hy
  · intro hy
    exact ⟨wing_p_subset_vertices hp hq hy, (adj_iff_cross hp hq hpq).mpr (Or.inr ⟨hx, hy⟩)⟩

/-- **Degree on the `p`-wing.** -/
theorem degree_of_mem_wing_p (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ wing p (p * q)) : (nbhd (p * q) x).card + 1 = p := by
  rw [neighbors_of_mem_wing_p hp hq hpq hx]
  exact (factor_recovery hp hq).2

/-- **Degree on the `q`-wing.** -/
theorem degree_of_mem_wing_q (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ wing q (p * q)) : (nbhd (p * q) x).card + 1 = q := by
  rw [neighbors_of_mem_wing_q hp hq hpq hx]
  exact (factor_recovery hp hq).1

/-- **The degree sequence recovers the factorisation.** Every vertex degree,
incremented by one, is a prime factor of `N`. -/
theorem factor_recovery_from_degrees (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ vertices (p * q)) :
    ((nbhd (p * q) x).card + 1 = p ∨ (nbhd (p * q) x).card + 1 = q) ∧
      ((nbhd (p * q) x).card + 1) ∣ p * q := by
  rw [vertices_eq_wing_union hp hq, Finset.mem_union] at hx
  rcases hx with hx | hx
  · have hd := degree_of_mem_wing_p hp hq hpq hx
    exact ⟨Or.inl hd, by rw [hd]; exact ⟨q, rfl⟩⟩
  · have hd := degree_of_mem_wing_q hp hq hpq hx
    exact ⟨Or.inr hd, by rw [hd]; exact ⟨p, mul_comm p q⟩⟩

/-- **The circularity (barrier 6).** Producing a single vertex of the graph
already produces a nontrivial divisor of `N`: `gcd(x, N) ∈ {p, q}`.  The
structural witness therefore presupposes what it is meant to deliver. -/
theorem vertex_gives_factor (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x : ℕ}
    (hx : x ∈ vertices (p * q)) : Nat.gcd x (p * q) = p ∨ Nat.gcd x (p * q) = q := by
  have hxw := hx
  rw [vertices_eq_wing_union hp hq, Finset.mem_union] at hxw
  have hxlt := (mem_vertices.mp hx).1
  rcases hxw with hx' | hx'
  · left
    have hpx : p ∣ x := (mem_wing.mp hx').2
    have hqx : ¬ q ∣ x := fun h =>
      (Finset.disjoint_left.mp (wings_disjoint hp hq hpq) hx') (mem_wing.mpr ⟨hxlt, h⟩)
    have hdvd : p ∣ Nat.gcd x (p * q) := Nat.dvd_gcd hpx ⟨q, rfl⟩
    obtain ⟨k, hk⟩ := hdvd
    have hkq : k ∣ q := by
      have h1 : p * k ∣ p * q := hk ▸ Nat.gcd_dvd_right x (p * q)
      exact (mul_dvd_mul_iff_left hp.pos.ne').mp h1
    rcases hq.eq_one_or_self_of_dvd k hkq with h1 | h1
    · rw [hk, h1, mul_one]
    · exfalso
      apply hqx
      have hgx : Nat.gcd x (p * q) ∣ x := Nat.gcd_dvd_left x (p * q)
      have hqg : q ∣ Nat.gcd x (p * q) := by rw [hk, h1]; exact ⟨p, mul_comm p q⟩
      exact hqg.trans hgx
  · right
    have hqx : q ∣ x := (mem_wing.mp hx').2
    have hpx : ¬ p ∣ x := fun h =>
      (Finset.disjoint_left.mp (wings_disjoint hp hq hpq) (mem_wing.mpr ⟨hxlt, h⟩)) hx'
    have hdvd : q ∣ Nat.gcd x (p * q) := Nat.dvd_gcd hqx ⟨p, mul_comm p q⟩
    obtain ⟨k, hk⟩ := hdvd
    have hkp : k ∣ p := by
      have h1 : q * k ∣ q * p := by
        rw [Nat.mul_comm q p]
        exact hk ▸ Nat.gcd_dvd_right x (p * q)
      exact (mul_dvd_mul_iff_left hq.pos.ne').mp h1
    rcases hp.eq_one_or_self_of_dvd k hkp with h1 | h1
    · rw [hk, h1, mul_one]
    · exfalso
      apply hpx
      have hgx : Nat.gcd x (p * q) ∣ x := Nat.gcd_dvd_left x (p * q)
      have hpg : p ∣ Nat.gcd x (p * q) := by rw [hk, h1]; exact ⟨q, mul_comm q p⟩
      exact hpg.trans hgx

end Round7ZDG