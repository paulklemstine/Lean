/-
# Dials are closed under tensoring: stacking discriminants does not help

Cycle 3.  A natural attempt to rescue the extrinsic class-group idea is *hint
amplification*: instead of one discriminant `D`, use many discriminants
`D₁, …, D_k` and record the concatenated representation vector.  This file
proves that this cannot escape the collapse: **a product of residue dials is a
residue dial**.

* `ClassGroupResidueDial.ResidueDial.prod` : the joint family
  `N ↦ (class of N for d₁, class of N for d₂)` is a residue dial modulo
  `m₁ * m₂`.
* `ClassGroupResidueDial.joint_factor_blind` : consequently the joint observation is still a
  function of `N mod m₁m₂` alone.
* `ClassGroupResidueDial.dial20_84` : the concrete stacking of `D = -20` (2 classes) and
  `D = -84` (4 classes) is a dial mod `1680` with `8` positions, and
  `ClassGroupResidueDial.stacked_pp_nn_blind` shows the PP/NN collision of cycle 1 survives
  stacking.

Interpretation: the set of "residue dial" observables is closed under products,
so no finite family of extrinsic discriminants gives an asymmetric handle on
`N`; the whole extrinsic corner collapses at once, not one discriminant at a
time.
-/
import Mathlib
import Algebra.ClassGroupResidueDialD84

namespace ClassGroupResidueDial

variable {m₁ m₂ : ℕ} {ι₁ ι₂ : Type*}

private theorem dvd_left : m₁ ∣ m₁ * m₂ := ⟨m₂, rfl⟩

private theorem dvd_right : m₂ ∣ m₁ * m₂ := ⟨m₁, mul_comm m₁ m₂⟩

/-- **Tensor product of residue dials.**  Observing two dials simultaneously is
again a single dial, modulo the product of the two moduli. -/
def ResidueDial.prod [NeZero (m₁ * m₂)] (d₁ : ResidueDial m₁ ι₁) (d₂ : ResidueDial m₂ ι₂) :
    ResidueDial (m₁ * m₂) (ι₁ × ι₂) where
  repr i N := d₁.repr i.1 N ∧ d₂.repr i.2 N
  res i := Finset.univ.filter fun a : ZMod (m₁ * m₂) =>
    ZMod.castHom dvd_left (ZMod m₁) a ∈ d₁.res i.1 ∧
      ZMod.castHom dvd_right (ZMod m₂) a ∈ d₂.res i.2
  sound := by
    rintro i N ⟨u, hu⟩ ⟨h1, h2⟩
    have e1 : ZMod.castHom dvd_left (ZMod m₁) ((N : ℤ) : ZMod (m₁ * m₂)) = (N : ZMod m₁) :=
      map_intCast _ N
    have e2 : ZMod.castHom dvd_right (ZMod m₂) ((N : ℤ) : ZMod (m₁ * m₂)) = (N : ZMod m₂) :=
      map_intCast _ N
    have u1 : ∃ w : ZMod m₁, w * (N : ZMod m₁) = 1 := by
      refine ⟨ZMod.castHom dvd_left (ZMod m₁) u, ?_⟩
      have := congrArg (ZMod.castHom dvd_left (ZMod m₁)) hu
      rw [map_mul, map_one, e1] at this
      exact this
    have u2 : ∃ w : ZMod m₂, w * (N : ZMod m₂) = 1 := by
      refine ⟨ZMod.castHom dvd_right (ZMod m₂) u, ?_⟩
      have := congrArg (ZMod.castHom dvd_right (ZMod m₂)) hu
      rw [map_mul, map_one, e2] at this
      exact this
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, e1, e2]
    exact ⟨d₁.sound i.1 N u1 h1, d₂.sound i.2 N u2 h2⟩
  disj := by
    rintro ⟨i₁, i₂⟩ ⟨j₁, j₂⟩ hij a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
    intro hb
    by_cases h : i₁ = j₁
    · subst h
      have h2 : i₂ ≠ j₂ := fun h2 => hij (by rw [h2])
      exact d₂.disj i₂ j₂ h2 _ ha.2 hb.2
    · exact d₁.disj i₁ j₁ h _ ha.1 hb.1

/-- **Stacking discriminants stays factor-blind.**  The joint class index of `N`
under two dials is a function of `N mod m₁m₂`. -/
theorem joint_factor_blind [NeZero (m₁ * m₂)] (d₁ : ResidueDial m₁ ι₁) (d₂ : ResidueDial m₂ ι₂)
    {N M : ℤ} (hN : ∃ u : ZMod (m₁ * m₂), u * (N : ZMod (m₁ * m₂)) = 1)
    (hM : ∃ u : ZMod (m₁ * m₂), u * (M : ZMod (m₁ * m₂)) = 1)
    (hres : ((N : ℤ) : ZMod (m₁ * m₂)) = ((M : ℤ) : ZMod (m₁ * m₂)))
    {i j : ι₁ × ι₂} (hi : (d₁.prod d₂).repr i N) (hj : (d₁.prod d₂).repr j M) : i = j :=
  (d₁.prod d₂).factor_blind hN hM hres hi hj

/-- The stacked `(-20, -84)` dial: eight positions, modulus `1680`. -/
def dial20_84 : ResidueDial (20 * 84) (Bool × (Bool × Bool)) := dial20.prod dial84

/-- **The PP/NN collision survives stacking.**  If `p, q` are principal for both
discriminants and `p', q'` are non-principal for both (in the classes `Q` and
`f₂`), then `pq` and `p'q'` are reported identically by the *joint*
`(-20, -84)` observation. -/
theorem stacked_pp_nn_blind {p q p' q' : ℤ}
    (hp : ReprP p ∧ Reprf1 p) (hq : ReprP q ∧ Reprf1 q)
    (hp' : ReprQ p' ∧ Reprf2 p') (hq' : ReprQ q' ∧ Reprf2 q') :
    (dial20_84.repr (false, false, false) (p * q)) ∧
      (dial20_84.repr (false, false, false) (p' * q')) := by
  refine ⟨⟨reprP_mul_reprP hp.1 hq.1, ?_⟩, ⟨reprQ_mul_reprQ hp'.1 hq'.1, ?_⟩⟩
  · exact sq_principal (false, false) p q hp.2 hq.2
  · exact sq_principal (true, false) p' q' hp'.2 hq'.2

/-- The hypotheses of `stacked_pp_nn_blind` are satisfiable: `109` and `421` are
principal for both discriminants, `23` and `107` are non-principal for both.  So
the stacked observation really does confuse `109 · 421` with `23 · 107`. -/
theorem stacked_witness :
    (ReprP 109 ∧ Reprf1 109) ∧ (ReprP 421 ∧ Reprf1 421) ∧
      (ReprQ 23 ∧ Reprf2 23) ∧ (ReprQ 107 ∧ Reprf2 107) :=
  ⟨⟨⟨8, 3, by norm_num⟩, ⟨5, 2, by norm_num⟩⟩,
   ⟨⟨4, 9, by norm_num⟩, ⟨20, 1, by norm_num⟩⟩,
   ⟨⟨-1, 3, by norm_num⟩, ⟨2, 1, by norm_num⟩⟩,
   ⟨⟨5, 3, by norm_num⟩, ⟨1, 3, by norm_num⟩⟩⟩

end ClassGroupResidueDial