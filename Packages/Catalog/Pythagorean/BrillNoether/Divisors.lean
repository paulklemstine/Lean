/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Divisors, linear equivalence and Baker–Norine rank on a finite graph

This file develops the divisor theory on a finite graph that underlies the
*Brill–Noether existence conjecture for graphs*.  A divisor on a graph is an
integer valued function on the vertices; two divisors are linearly equivalent
when they differ by an element of the *Laplacian lattice*, i.e. by a vector of
the form `L f` with `f : V → ℤ` (a chip-firing move).  The Baker–Norine rank of
a divisor `D` is at least `r` when `D - E` is linearly equivalent to an
effective divisor for **every** effective divisor `E` of degree `r`.

## Main definitions

* `BrillNoetherDivisor.deg` — the degree of a divisor.
* `BrillNoetherDivisor.lap` — the Laplacian (chip-firing) operator `f ↦ L f`.
* `BrillNoetherDivisor.LinEquiv` — linear equivalence of divisors.
* `BrillNoetherDivisor.Effective` — effectivity.
* `BrillNoetherDivisor.RankAtLeast` — the Baker–Norine rank inequality `r(D) ≥ r`.
* `BrillNoetherDivisor.genus` — the genus (first Betti number) `#E - #V + 1`.
* `BrillNoetherDivisor.canonical` — the canonical divisor `K(v) = deg(v) - 2`.

## Main results

* `deg_lap` — principal divisors have degree `0`, so `deg` descends to the
  Picard group (`deg_eq_of_linEquiv`).
* `rankAtLeast_of_linEquiv` — the rank inequality only depends on the divisor class.
* `rankAtLeast_antitone` and `deg_ge_of_rankAtLeast` — basic properties of the rank,
  in particular `r(D) ≤ deg D`.
* `deg_canonical` — the canonical divisor has degree `2g - 2`, so that the
  *half-canonical degree* is `g - 1`.
* `rankAtLeast_zero_of_covering`, `rankAtLeast_of_covering` and
  `rankAtLeast_halfCanonical_of_covering` — a covering radius hypothesis for the
  Laplacian lattice (`IsCoveringBound`) implies Riemann-type existence and
  Brill–Noether existence: if the lattice has `ℓ^∞`-covering radius `ρ` then every
  divisor of degree at least `n (ρ + r)` has rank at least `r`.
* `exists_divisor_deg_rankAtLeast` — for every `d` there is a divisor of degree `d`
  whose rank is at least `⌊d / #V⌋`; specialised at the half-canonical degree in
  `exists_halfCanonical_divisor`.  This is the elementary ("diagonal") lower bound
  towards Brill–Noether existence; the conjecture predicts the much stronger
  bound `r ≈ √g` at degree `g - 1`.
-/

open Finset Matrix

namespace BrillNoetherDivisor

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- A divisor on a graph with vertex set `V` is an integer vector indexed by `V`. -/
abbrev Divisor (V : Type*) := V → ℤ

/-- The degree of a divisor is the total number of chips. -/
def deg (D : Divisor V) : ℤ := ∑ v, D v

/-- The principal divisor (chip-firing move) attached to `f : V → ℤ`, i.e. the
image of `f` under the graph Laplacian `L = D - A`. -/
def lap (f : V → ℤ) : Divisor V := G.lapMatrix ℤ *ᵥ f

lemma lap_apply (f : V → ℤ) (v : V) :
    lap G f v = G.degree v * f v - ∑ u ∈ G.neighborFinset v, f u :=
  G.lapMatrix_mulVec_apply v f

@[simp] lemma lap_zero : lap G 0 = 0 := by simp [lap]

lemma lap_add (f g : V → ℤ) : lap G (f + g) = lap G f + lap G g := by
  simp [lap, mulVec_add]

lemma lap_neg (f : V → ℤ) : lap G (-f) = -lap G f := by simp [lap, mulVec_neg]

lemma lap_sub (f g : V → ℤ) : lap G (f - g) = lap G f - lap G g := by
  simp [lap, mulVec_sub]

omit [DecidableEq V] in
@[simp] lemma deg_zero : deg (0 : Divisor V) = 0 := by simp [deg]

omit [DecidableEq V] in
lemma deg_add (D D' : Divisor V) : deg (D + D') = deg D + deg D' := by
  simp [deg, Finset.sum_add_distrib]

omit [DecidableEq V] in
lemma deg_sub (D D' : Divisor V) : deg (D - D') = deg D - deg D' := by
  simp [deg, Finset.sum_sub_distrib]

/-- Every principal divisor has degree zero: firing chips conserves them. -/
theorem deg_lap (f : V → ℤ) : deg (lap G f) = 0 := by
  have h1 : deg (lap G f) = (fun _ : V => (1 : ℤ)) ⬝ᵥ (G.lapMatrix ℤ *ᵥ f) := by
    simp [deg, lap, dotProduct]
  rw [h1, dotProduct_mulVec]
  have h2 : vecMul (fun _ : V => (1 : ℤ)) (G.lapMatrix ℤ) = 0 := by
    rw [← mulVec_transpose, show (G.lapMatrix ℤ)ᵀ = G.lapMatrix ℤ from G.isSymm_lapMatrix]
    exact G.lapMatrix_mulVec_const_eq_zero
  rw [h2]; simp

/-- Two divisors are linearly equivalent when they differ by a principal divisor. -/
def LinEquiv (D D' : Divisor V) : Prop := ∃ f : V → ℤ, D' = D + lap G f

lemma linEquiv_refl (D : Divisor V) : LinEquiv G D D := ⟨0, by simp⟩

lemma linEquiv_symm {D D' : Divisor V} (h : LinEquiv G D D') : LinEquiv G D' D := by
  obtain ⟨f, rfl⟩ := h
  exact ⟨-f, by rw [lap_neg]; abel⟩

lemma linEquiv_trans {D D' D'' : Divisor V} (h : LinEquiv G D D') (h' : LinEquiv G D' D'') :
    LinEquiv G D D'' := by
  obtain ⟨f, rfl⟩ := h
  obtain ⟨g, rfl⟩ := h'
  exact ⟨f + g, by rw [lap_add]; abel⟩

/-- Linear equivalence preserves the degree. -/
theorem deg_eq_of_linEquiv {D D' : Divisor V} (h : LinEquiv G D D') : deg D = deg D' := by
  obtain ⟨f, rfl⟩ := h
  rw [deg_add, deg_lap, add_zero]

/-- A divisor is effective when it has no debt. -/
def Effective (D : Divisor V) : Prop := ∀ v, 0 ≤ D v

omit [DecidableEq V] in
lemma deg_nonneg_of_effective {D : Divisor V} (h : Effective D) : 0 ≤ deg D :=
  Finset.sum_nonneg fun v _ => h v

omit [DecidableEq V] in
lemma le_deg_of_effective {D : Divisor V} (h : Effective D) (v : V) : D v ≤ deg D :=
  Finset.single_le_sum (fun u _ => h u) (Finset.mem_univ v)

omit [DecidableEq V] in
/-- An effective divisor of degree `0` is the zero divisor. -/
lemma eq_zero_of_effective_of_deg_zero {D : Divisor V} (h : Effective D) (h0 : deg D = 0) :
    D = 0 := by
  funext v
  have := le_deg_of_effective h v
  simp only [h0] at this
  exact le_antisymm this (h v)

/-- **Baker–Norine rank inequality.** `RankAtLeast G D r` says that for every
effective divisor `E` of degree `r`, the divisor `D - E` is linearly equivalent
to an effective divisor.  For `r = 0` this says that `D` itself is equivalent to
an effective divisor. -/
def RankAtLeast (D : Divisor V) (r : ℕ) : Prop :=
  ∀ E : Divisor V, Effective E → deg E = r → ∃ f : V → ℤ, Effective (D - E + lap G f)

/-- `r(D) ≥ 0` means exactly that `D` is linearly equivalent to an effective divisor. -/
theorem rankAtLeast_zero_iff (D : Divisor V) :
    RankAtLeast G D 0 ↔ ∃ f : V → ℤ, Effective (D + lap G f) := by
  constructor
  · intro h
    obtain ⟨f, hf⟩ := h 0 (fun _ => le_refl 0) (by simp)
    exact ⟨f, by simpa using hf⟩
  · rintro ⟨f, hf⟩ E hE hdeg
    have : E = 0 := eq_zero_of_effective_of_deg_zero hE (by simpa using hdeg)
    subst this
    exact ⟨f, by simpa using hf⟩

/-- The rank inequality is a property of the divisor class. -/
theorem rankAtLeast_of_linEquiv {D D' : Divisor V} {r : ℕ} (h : LinEquiv G D D')
    (hr : RankAtLeast G D r) : RankAtLeast G D' r := by
  obtain ⟨g, rfl⟩ := h
  intro E hE hdeg
  obtain ⟨f, hf⟩ := hr E hE hdeg
  refine ⟨f - g, fun v => ?_⟩
  have := hf v
  rw [lap_sub]
  simp only [Pi.add_apply, Pi.sub_apply] at this ⊢
  linarith

/-- Adding an effective divisor cannot decrease the rank. -/
theorem rankAtLeast_add_effective {D E' : Divisor V} {r : ℕ} (h : RankAtLeast G D r)
    (hE' : Effective E') : RankAtLeast G (D + E') r := by
  intro E hE hdeg
  obtain ⟨f, hf⟩ := h E hE hdeg
  refine ⟨f, fun v => ?_⟩
  have := hf v
  have := hE' v
  simp only [Pi.add_apply, Pi.sub_apply] at *
  linarith

/-- The rank inequality for `r + 1` implies the one for `r`. -/
theorem rankAtLeast_of_succ [Nonempty V] {D : Divisor V} {r : ℕ}
    (h : RankAtLeast G D (r + 1)) : RankAtLeast G D r := by
  intro E hE hdeg
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  set δ : Divisor V := fun v => if v = v₀ then 1 else 0 with hδ
  have hδeff : Effective δ := by intro v; by_cases hv : v = v₀ <;> simp [hδ, hv]
  have hδdeg : deg δ = 1 := by simp [deg, hδ]
  obtain ⟨f, hf⟩ := h (E + δ) (fun v => add_nonneg (hE v) (hδeff v))
    (by rw [deg_add, hdeg, hδdeg]; push_cast; ring)
  refine ⟨f, fun v => ?_⟩
  have h1 := hf v
  have h2 := hδeff v
  simp only [Pi.add_apply, Pi.sub_apply] at *
  linarith

/-- Monotonicity of the rank inequality in `r`. -/
theorem rankAtLeast_antitone [Nonempty V] {D : Divisor V} {r s : ℕ} (hrs : r ≤ s)
    (h : RankAtLeast G D s) : RankAtLeast G D r := by
  induction s with
  | zero =>
      have : r = 0 := Nat.le_zero.mp hrs
      subst this; exact h
  | succ n ih =>
      rcases Nat.lt_or_ge r (n + 1) with hlt | hge
      · exact ih (by omega) (rankAtLeast_of_succ G h)
      · have : r = n + 1 := le_antisymm hrs hge
        subst this; exact h

/-- If `r(D) ≥ r` then `deg D ≥ r`: the rank never exceeds the degree. -/
theorem deg_ge_of_rankAtLeast [Nonempty V] {D : Divisor V} {r : ℕ}
    (h : RankAtLeast G D r) : (r : ℤ) ≤ deg D := by
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  set E : Divisor V := fun v => if v = v₀ then (r : ℤ) else 0 with hE
  have hEeff : Effective E := by
    intro v; by_cases hv : v = v₀ <;> simp [hE, hv]
  have hEdeg : deg E = r := by simp [deg, hE]
  obtain ⟨f, hf⟩ := h E hEeff hEdeg
  have h0 : 0 ≤ deg (D - E + lap G f) := deg_nonneg_of_effective hf
  rw [deg_add, deg_sub, deg_lap, hEdeg, add_zero] at h0
  linarith

/-- A divisor with at least `r` chips on every vertex has rank at least `r`. -/
theorem rankAtLeast_of_forall_le {D : Divisor V} {r : ℕ} (h : ∀ v, (r : ℤ) ≤ D v) :
    RankAtLeast G D r := by
  intro E hE hdeg
  refine ⟨0, fun v => ?_⟩
  have h1 : E v ≤ (r : ℤ) := by
    have := le_deg_of_effective hE v
    rwa [hdeg] at this
  have := h v
  simp only [Pi.add_apply, Pi.sub_apply, lap_zero, Pi.zero_apply]
  linarith

/-- The genus (first Betti number) of a graph: `#E - #V + 1`. -/
def genus : ℤ := (#G.edgeFinset : ℤ) - (Fintype.card V : ℤ) + 1

omit [DecidableEq V] in
/-- For a connected graph the genus is nonnegative. -/
theorem genus_nonneg (hG : G.Connected) : 0 ≤ genus G := by
  have h := hG.card_vert_le_card_edgeSet_add_one
  rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card] at h
  have h2 : Fintype.card G.edgeSet = #G.edgeFinset := by
    simp [SimpleGraph.edgeFinset]
  rw [h2] at h
  unfold genus
  omega

/-- The canonical divisor `K(v) = deg(v) - 2`. -/
def canonical : Divisor V := fun v => (G.degree v : ℤ) - 2

omit [DecidableEq V] in
/-- **The canonical divisor has degree `2g - 2`.**  Consequently the
*half-canonical degree* — half the degree of `K` — equals `g - 1`. -/
theorem deg_canonical : deg (canonical G) = 2 * genus G - 2 := by
  have hsum : ∑ v, (G.degree v : ℤ) = 2 * (#G.edgeFinset : ℤ) := by
    have := G.sum_degrees_eq_twice_card_edges
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) this
  unfold deg canonical genus
  rw [Finset.sum_sub_distrib, hsum]
  simp [Finset.card_univ]
  ring

/-- **Elementary Brill–Noether existence bound.**  On any nonempty graph with `n`
vertices and for any degree `d ≥ 0` there is a divisor of degree `d` whose
Baker–Norine rank is at least `⌊d / n⌋. -/
theorem exists_divisor_deg_rankAtLeast [Nonempty V] (d : ℕ) :
    ∃ D : Divisor V, deg D = d ∧ RankAtLeast G D (d / Fintype.card V) := by
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  set n := Fintype.card V with hn
  have hnpos : 0 < n := Fintype.card_pos
  set r := d / n with hr
  set s : ℤ := (d : ℤ) - (n : ℤ) * (r : ℤ) with hs
  have hspos : 0 ≤ s := by
    have h1 : r * n ≤ d := Nat.div_mul_le_self d n
    have h2 : (r : ℤ) * (n : ℤ) ≤ (d : ℤ) := by exact_mod_cast h1
    simp only [hs]; linarith
  set D : Divisor V := fun v => if v = v₀ then (r : ℤ) + s else (r : ℤ) with hD
  refine ⟨D, ?_, ?_⟩
  · have : deg D = ∑ v : V, ((r : ℤ) + if v = v₀ then s else 0) := by
      unfold deg
      refine Finset.sum_congr rfl fun v _ => ?_
      by_cases hv : v = v₀ <;> simp [hD, hv]
    rw [this, Finset.sum_add_distrib]
    simp only [Finset.sum_const, Finset.sum_ite_eq', Finset.mem_univ, if_true,
      Finset.card_univ, nsmul_eq_mul, ← hn, hs]
    ring
  · refine rankAtLeast_of_forall_le G fun v => ?_
    by_cases hv : v = v₀ <;> simp [hD, hv, hspos]

/-- Contrapositive of `deg_ge_of_rankAtLeast`: a divisor of degree smaller than `r`
cannot have rank `r`. -/
theorem not_rankAtLeast_of_deg_lt [Nonempty V] {D : Divisor V} {r : ℕ}
    (h : deg D < r) : ¬ RankAtLeast G D r := fun hr =>
  absurd (deg_ge_of_rankAtLeast G hr) (not_le.mpr h)

/-- **Brill–Noether existence bound at the half-canonical degree.**  On any graph
with at least as many edges as vertices there is a divisor of degree `g - 1`
(half the degree of the canonical divisor) whose Baker–Norine rank is at least
`⌊(#E - #V) / #V⌋`. -/
theorem exists_halfCanonical_divisor [Nonempty V] (h : Fintype.card V ≤ #G.edgeFinset) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧
      RankAtLeast G D ((#G.edgeFinset - Fintype.card V) / Fintype.card V) := by
  obtain ⟨D, hdeg, hrank⟩ := exists_divisor_deg_rankAtLeast G (#G.edgeFinset - Fintype.card V)
  refine ⟨D, ?_, hrank⟩
  rw [hdeg, Nat.cast_sub h]
  unfold genus
  ring

/-! ## From a covering radius bound to Brill–Noether existence -/

/-- `IsCoveringBound G ρ` says that `ρ` is an `ℓ^∞`-covering radius for the
Laplacian lattice inside the group of degree-zero divisors: every degree-zero
divisor is linearly equivalent to a divisor with at most `ρ` chips of debt at
each vertex.  This is the combinatorial shadow of the covering radius of the
Laplacian lattice with respect to the energy pairing. -/
def IsCoveringBound (rho : ℕ) : Prop :=
  ∀ A : Divisor V, deg A = 0 → ∃ f : V → ℤ, ∀ v, -(rho : ℤ) ≤ (A + lap G f) v

/-- **Covering radius implies Riemann-type existence.**  If `ρ` is an
`ℓ^∞`-covering radius of the Laplacian lattice, then every divisor of degree at
least `n · ρ` is linearly equivalent to an effective divisor. -/
theorem rankAtLeast_zero_of_covering [Nonempty V] {rho : ℕ} (hrho : IsCoveringBound G rho)
    (D : Divisor V) (h : (Fintype.card V : ℤ) * (rho : ℤ) ≤ deg D) :
    RankAtLeast G D 0 := by
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  set n : ℤ := (Fintype.card V : ℤ) with hn
  set B : Divisor V := fun v => if v = v₀ then (rho : ℤ) + (deg D - n * (rho : ℤ))
    else (rho : ℤ) with hB
  have hBdeg : deg B = deg D := by
    have hsplit : deg B = ∑ v : V, ((rho : ℤ) + if v = v₀ then deg D - n * (rho : ℤ) else 0) :=
      Finset.sum_congr rfl fun v _ => by by_cases hv : v = v₀ <;> simp [hB, hv]
    rw [hsplit, Finset.sum_add_distrib]
    simp only [Finset.sum_const, Finset.sum_ite_eq', Finset.mem_univ, if_true,
      Finset.card_univ, nsmul_eq_mul, ← hn]
    ring
  have hBge : ∀ v, (rho : ℤ) ≤ B v := by
    intro v
    by_cases hv : v = v₀
    · simp only [hB, if_pos hv]
      linarith
    · simp [hB, hv]
  set A : Divisor V := D - B with hA
  have hAdeg : deg A = 0 := by rw [hA, deg_sub, hBdeg, sub_self]
  obtain ⟨f, hf⟩ := hrho A hAdeg
  rw [rankAtLeast_zero_iff]
  refine ⟨f, fun v => ?_⟩
  have h1 := hf v
  have h2 := hBge v
  simp only [hA, Pi.add_apply, Pi.sub_apply] at h1 ⊢
  linarith

/-- **Covering radius implies Brill–Noether existence.**  If `ρ` is an
`ℓ^∞`-covering radius of the Laplacian lattice, then *every* divisor of degree at
least `n · (ρ + r)` has Baker–Norine rank at least `r`. -/
theorem rankAtLeast_of_covering [Nonempty V] {rho r : ℕ} (hrho : IsCoveringBound G rho)
    (D : Divisor V) (h : (Fintype.card V : ℤ) * ((rho : ℤ) + (r : ℤ)) ≤ deg D) :
    RankAtLeast G D r := by
  intro E hE hdeg
  have hn : (1 : ℤ) ≤ (Fintype.card V : ℤ) := by
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr Fintype.card_ne_zero
  have hr : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  have hdegDE : (Fintype.card V : ℤ) * (rho : ℤ) ≤ deg (D - E) := by
    rw [deg_sub, hdeg]
    nlinarith [h, hn, hr]
  have := rankAtLeast_zero_of_covering G hrho (D - E) hdegDE
  rw [rankAtLeast_zero_iff] at this
  obtain ⟨f, hf⟩ := this
  exact ⟨f, hf⟩

/-- **Conditional Brill–Noether existence at the half-canonical degree.**  If the
Laplacian lattice has `ℓ^∞`-covering radius at most `ρ` and `n · (ρ + r) ≤ g - 1`,
then *every* divisor of the half-canonical degree `g - 1` has rank at least `r`. -/
theorem rankAtLeast_halfCanonical_of_covering [Nonempty V] {rho r : ℕ}
    (hrho : IsCoveringBound G rho)
    (h : (Fintype.card V : ℤ) * ((rho : ℤ) + (r : ℤ)) ≤ genus G - 1)
    (D : Divisor V) (hD : deg D = genus G - 1) :
    RankAtLeast G D r :=
  rankAtLeast_of_covering G hrho D (by rw [hD]; exact h)

end BrillNoetherDivisor