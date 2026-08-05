/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.Divisors
import Catalog.Pythagorean.BrillNoether.Reduced

/-!
# Uniqueness of `q`-reduced divisors and the effectivity criterion

`Catalog/Pythagorean/BrillNoether/Reduced.lean` produces, for every base vertex `q`
of a connected graph and every divisor `D`, a linearly equivalent `q`-reduced
divisor.  This file shows that this representative is *unique*, so that reduction
gives a canonical normal form for divisor classes, and uses it to characterise the
divisors of nonnegative Baker–Norine rank.

The two main results are:

* `BrillNoetherReducedUnique.reduced_unique` — two linearly equivalent `q`-reduced
  divisors are equal.  The proof is the classical maximum-principle argument: if
  `D' = D + L f` and `S` is the set where `f` attains its maximum, then every
  `v ∈ S` gains at least `outdeg S v` chips, so `S` could be fired from `D'`,
  contradicting reducedness — unless `f` is constant.
* `BrillNoetherReducedUnique.rankAtLeast_zero_iff_reduced_nonneg` — a divisor is
  linearly equivalent to an effective divisor if and only if its `q`-reduced
  representative already has a nonnegative number of chips at `q`.  The nontrivial
  direction uses `exists_reduced_effective`: reduction of an effective divisor can
  be carried out inside the effective cone, because firing a set avoiding `q` never
  decreases the number of chips at `q`.

Together they say that `D ↦ (its `q`-reduced form)` is a complete invariant of the
divisor class (`linEquiv_iff_reduced_eq`) and that this invariant decides
`r(D) ≥ 0`.  This is the theoretical content behind Dhar's burning algorithm and
makes the Baker–Norine rank at the half-canonical degree a finite computation.

A small but useful by-product is `IsReduced.lt_degree`: a `q`-reduced divisor
carries fewer than `deg v` chips at every vertex `v ≠ q`, since otherwise the
single vertex `v` could be fired.
-/

open Finset SimpleGraph

namespace BrillNoetherReducedUnique

open BrillNoetherDivisor BrillNoetherReduced

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- `IsReduced G q D` says that the divisor `D` is `q`-reduced: it is nonnegative
away from `q`, and no nonempty set of vertices avoiding `q` can legally be fired. -/
def IsReduced (q : V) (D : Divisor V) : Prop :=
  (∀ v, v ≠ q → 0 ≤ D v) ∧
    ∀ S : Finset V, S ⊆ univ.erase q → S.Nonempty → ∃ v ∈ S, D v < (outdeg G S v : ℤ)

/-- Existence of the `q`-reduced representative, restated with `IsReduced`. -/
theorem exists_isReduced (hG : G.Connected) (q : V) (D : Divisor V) :
    ∃ f : V → ℤ, IsReduced G q (D + lap G f) := by
  obtain ⟨f, h1, h2⟩ := exists_reduced G hG q D
  exact ⟨f, h1, h2⟩

/-- Firing a single vertex costs it its full degree. -/
lemma outdeg_singleton (v : V) : outdeg G {v} v = G.degree v := by
  rw [outdeg, Finset.sdiff_singleton_eq_erase,
    Finset.erase_eq_of_notMem (G.notMem_neighborFinset_self v),
    G.card_neighborFinset_eq_degree]

/-- **A reduced divisor is subcritical away from the base vertex.**  If `D` is
`q`-reduced then `D v < deg v` for every `v ≠ q`; otherwise `v` alone could fire. -/
theorem IsReduced.lt_degree {q : V} {D : Divisor V} (h : IsReduced G q D) {v : V}
    (hv : v ≠ q) : D v < (G.degree v : ℤ) := by
  obtain ⟨w, hw, hlt⟩ := h.2 {v} (by simp [hv]) ⟨v, Finset.mem_singleton_self v⟩
  rw [Finset.mem_singleton] at hw
  subst hw
  rwa [outdeg_singleton] at hlt

/-! ## The maximum principle -/

/-- **Maximum principle for chip firing.**  Let `D` be nonnegative away from `q`,
let `f : V → ℤ` attain its maximum value `M`, and let `S` be the set where the
maximum is attained.  Then every vertex `v ∈ S` other than `q` ends up in
`D + L f` with at least `outdeg S v` chips, i.e. `S` is a legal firing set for
`D + L f`. -/
lemma outdeg_le_of_argmax {q : V} {D : Divisor V} (hD : ∀ v, v ≠ q → 0 ≤ D v)
    (f : V → ℤ) (M : ℤ) (hM : ∀ u, f u ≤ M) {v : V} (hv : f v = M) (hvq : v ≠ q) :
    (outdeg G (univ.filter (fun u => f u = M)) v : ℤ) ≤ (D + lap G f) v := by
  classical
  set S : Finset V := univ.filter (fun u => f u = M) with hS
  have hcount : ((outdeg G S v : ℕ) : ℤ)
      = ∑ u ∈ G.neighborFinset v, (if u ∈ S then (0 : ℤ) else 1) := by
    rw [outdeg, Finset.sum_ite, Finset.sum_const, Finset.sum_const]
    simp [Finset.filter_not, Finset.sdiff_eq_filter]
  have hterm : ∀ u ∈ G.neighborFinset v, (if u ∈ S then (0 : ℤ) else 1) ≤ f v - f u := by
    intro u _
    by_cases hu : u ∈ S
    · simp only [hu, if_pos]
      have : f u = M := by simpa [hS] using hu
      rw [hv, this, sub_self]
    · have hne : f u ≠ M := by simpa [hS] using hu
      have hle := hM u
      simp only [hu, if_neg, not_false_iff]
      rw [hv]
      omega
  have hsum : ∑ u ∈ G.neighborFinset v, (if u ∈ S then (0 : ℤ) else 1)
      ≤ ∑ u ∈ G.neighborFinset v, (f v - f u) := Finset.sum_le_sum hterm
  have hlap : lap G f v = ∑ u ∈ G.neighborFinset v, (f v - f u) := lap_eq_sum_sub G f v
  have hDv := hD v hvq
  simp only [Pi.add_apply, hlap]
  rw [hcount]
  linarith

/-- If a function on the vertices of a connected graph attains the same maximum and
minimum, its Laplacian vanishes. -/
lemma lap_eq_zero_of_const (f : V → ℤ) (c : ℤ) (hf : ∀ u, f u = c) : lap G f = 0 := by
  funext v
  rw [lap_eq_sum_sub]
  simp [hf]

/-- **Uniqueness of the reduced representative.**  Two linearly equivalent
`q`-reduced divisors on a graph are equal. -/
theorem reduced_unique {q : V} {D D' : Divisor V} (hD : IsReduced G q D)
    (hD' : IsReduced G q D') (h : LinEquiv G D D') : D = D' := by
  classical
  obtain ⟨f, rfl⟩ := h
  obtain ⟨a, -, ha⟩ := Finset.exists_max_image (univ : Finset V) f ⟨q, Finset.mem_univ q⟩
  obtain ⟨b, -, hb⟩ := Finset.exists_min_image (univ : Finset V) f ⟨q, Finset.mem_univ q⟩
  have hamax : ∀ u, f u ≤ f a := fun u => ha u (Finset.mem_univ u)
  have hbmin : ∀ u, f b ≤ f u := fun u => hb u (Finset.mem_univ u)
  by_cases hconst : f a = f b
  · -- `f` is constant, so it fires nothing
    have : ∀ u, f u = f a := fun u => le_antisymm (hamax u) (hconst ▸ hbmin u)
    rw [lap_eq_zero_of_const G f (f a) this]
    simp
  · -- otherwise the maximum set or the minimum set avoids `q`, and can be fired
    exfalso
    set Smax : Finset V := univ.filter (fun u => f u = f a) with hSmax
    set Smin : Finset V := univ.filter (fun u => f u = f b) with hSmin
    have hqcase : q ∉ Smax ∨ q ∉ Smin := by
      by_contra hcon
      push_neg at hcon
      have h1 : f q = f a := by simpa [hSmax] using hcon.1
      have h2 : f q = f b := by simpa [hSmin] using hcon.2
      exact hconst (h1 ▸ h2)
    rcases hqcase with hq | hq
    · -- fire the maximum set from `D + L f`
      have hsub : Smax ⊆ univ.erase q := by
        intro x hx
        exact Finset.mem_erase.mpr ⟨fun hxq => hq (hxq ▸ hx), Finset.mem_univ x⟩
      have hne : Smax.Nonempty := ⟨a, by simp [hSmax]⟩
      obtain ⟨v, hv, hlt⟩ := hD'.2 Smax hsub hne
      have hvq : v ≠ q := (Finset.mem_erase.mp (hsub hv)).1
      have hvf : f v = f a := by simpa [hSmax] using hv
      exact absurd (outdeg_le_of_argmax G hD.1 f (f a) hamax hvf hvq) (not_le.mpr hlt)
    · -- fire the minimum set from `D = (D + L f) + L (-f)`
      have hsub : Smin ⊆ univ.erase q := by
        intro x hx
        exact Finset.mem_erase.mpr ⟨fun hxq => hq (hxq ▸ hx), Finset.mem_univ x⟩
      have hne : Smin.Nonempty := ⟨b, by simp [hSmin]⟩
      obtain ⟨v, hv, hlt⟩ := hD.2 Smin hsub hne
      have hvq : v ≠ q := (Finset.mem_erase.mp (hsub hv)).1
      have hvf : (-f) v = -f b := by
        have : f v = f b := by simpa [hSmin] using hv
        simp [this]
      have hmax : ∀ u, (-f) u ≤ -f b := fun u => by simpa using hbmin u
      have hkey := outdeg_le_of_argmax G hD'.1 (-f) (-f b) hmax hvf hvq
      have hset : (univ.filter (fun u => (-f) u = -f b)) = Smin := by
        apply Finset.filter_congr
        intro x _
        constructor
        · intro hx; simpa using neg_injective (by simpa using hx)
        · intro hx; simp [show f x = f b from hx]
      rw [hset] at hkey
      have hback : (D + lap G f + lap G (-f)) v = D v := by
        rw [lap_neg]
        simp
      rw [hback] at hkey
      exact absurd hkey (not_le.mpr hlt)

/-! ## Reduction inside the effective cone -/

/-- **Reduction of an effective divisor stays effective.**  Every effective divisor
is linearly equivalent to a `q`-reduced divisor which is still effective: the
minimisation of the potential `Φ` of `Reduced.lean` can be run inside the effective
cone, because firing a set avoiding `q` never decreases the number of chips at
`q`. -/
theorem exists_reduced_effective (hG : G.Connected) (q : V) {D : Divisor V}
    (hD : Effective D) :
    ∃ f : V → ℤ, Effective (D + lap G f) ∧ IsReduced G q (D + lap G f) := by
  classical
  set P : ℕ → Prop := fun m => ∃ f : V → ℤ, Effective (D + lap G f) ∧
      phi G q (D + lap G f) = (m : ℤ) with hP
  have hex : ∃ m, P m := by
    refine ⟨(phi G q (D + lap G 0)).toNat, 0, by simpa using hD, ?_⟩
    have : 0 ≤ phi G q (D + lap G 0) :=
      phi_nonneg G (fun v _ => by simpa using hD v)
    exact (Int.toNat_of_nonneg this).symm
  obtain ⟨f₀, hf₀eff, hf₀phi⟩ := Nat.find_spec hex
  refine ⟨f₀, hf₀eff, fun v _ => hf₀eff v, fun S hS hSne => ?_⟩
  by_contra hcon
  push_neg at hcon
  set D' : Divisor V := D + lap G f₀ with hD'
  set f₁ : V → ℤ := f₀ - ind S with hf₁
  have hDD : D + lap G f₁ = D' - lap G (ind S) := by
    rw [hD', hf₁, lap_sub G f₀ (ind S)]; abel
  have hnew : Effective (D + lap G f₁) := by
    intro u
    rw [hDD]
    simp only [Pi.sub_apply]
    by_cases huS : u ∈ S
    · have h1 := hcon u huS
      rw [lap_ind_mem G huS]
      simp only [hD'] at h1 ⊢
      linarith
    · have h1 := lap_ind_nonpos G huS
      have h2 := hf₀eff u
      simp only [hD'] at h2 ⊢
      linarith
  have hdec : phi G q (D + lap G f₁) = phi G q D' - ∑ v ∈ S, lap G (pot G q) v := by
    rw [hDD]; exact phi_fire G q D' S
  have hpos : (1 : ℤ) ≤ ∑ v ∈ S, lap G (pot G q) v := by
    have hcard : 1 ≤ #S := Finset.card_pos.mpr hSne
    have hterm : ∀ v ∈ S, (1 : ℤ) ≤ lap G (pot G q) v := fun v hv =>
      one_le_lap_pot G hG (Finset.ne_of_mem_erase (hS hv))
    calc (1 : ℤ) ≤ (#S : ℤ) := by exact_mod_cast hcard
      _ = ∑ _v ∈ S, (1 : ℤ) := by simp
      _ ≤ ∑ v ∈ S, lap G (pot G q) v := Finset.sum_le_sum hterm
  have hnn : 0 ≤ phi G q (D + lap G f₁) := phi_nonneg G (fun v _ => hnew v)
  set m₁ : ℕ := (phi G q (D + lap G f₁)).toNat with hm₁
  have hm₁val : phi G q (D + lap G f₁) = (m₁ : ℤ) := (Int.toNat_of_nonneg hnn).symm
  have hPm₁ : P m₁ := ⟨f₁, hnew, hm₁val⟩
  have hlt : m₁ < Nat.find hex := by
    have h1 : (m₁ : ℤ) < ((Nat.find hex : ℕ) : ℤ) := by
      rw [← hm₁val, ← hf₀phi, hdec, hD']
      linarith
    exact_mod_cast h1
  exact Nat.find_min hex hlt hPm₁

/-! ## The effectivity criterion -/

/-- **Effectivity is read off the reduced representative.**  A divisor `D` on a
connected graph has Baker–Norine rank at least `0`, i.e. it is linearly equivalent
to an effective divisor, if and only if its `q`-reduced representative `D₀` carries
a nonnegative number of chips at the base vertex `q`. -/
theorem rankAtLeast_zero_iff_reduced_nonneg (hG : G.Connected) {q : V} {D D₀ : Divisor V}
    (hlin : LinEquiv G D D₀) (hred : IsReduced G q D₀) :
    RankAtLeast G D 0 ↔ 0 ≤ D₀ q := by
  rw [rankAtLeast_zero_iff]
  constructor
  · rintro ⟨f, hf⟩
    obtain ⟨g, hg, hgred⟩ := exists_reduced_effective G hG q hf
    have hlin' : LinEquiv G D₀ (D + lap G f + lap G g) := by
      obtain ⟨f₀, hf₀⟩ := hlin
      refine ⟨f + g - f₀, ?_⟩
      rw [hf₀, lap_sub, lap_add]
      abel
    have := reduced_unique G hred hgred hlin'
    rw [this]
    exact hg q
  · intro hq
    obtain ⟨f, hf⟩ := hlin
    refine ⟨f, fun v => ?_⟩
    rw [← hf]
    by_cases hv : v = q
    · rwa [hv]
    · exact hred.1 v hv

/-- **Reduction is a complete invariant of the divisor class.**  Two divisors are
linearly equivalent if and only if their `q`-reduced representatives coincide. -/
theorem linEquiv_iff_reduced_eq {q : V} {D D' D₀ D₀' : Divisor V}
    (h : LinEquiv G D D₀) (h' : LinEquiv G D' D₀')
    (hred : IsReduced G q D₀) (hred' : IsReduced G q D₀') :
    LinEquiv G D D' ↔ D₀ = D₀' := by
  constructor
  · intro hDD
    exact reduced_unique G hred hred'
      (linEquiv_trans G (linEquiv_trans G (linEquiv_symm G h) hDD) h')
  · intro hEq
    refine linEquiv_trans G h ?_
    rw [hEq]
    exact linEquiv_symm G h'

end BrillNoetherReducedUnique