/-
# An approximate Hennessy–Milner theorem for nominal probabilistic structures

`Probability/ModalResolution.lean` showed that in the *nominal* language (one atom
per world) agreement of two structures on the depth-one fragment forces an **exact**
structural analogy, hence agreement on all modal formulas.  This file makes that
recovery statement *stable*: an `η`-approximate agreement on the depth-one fragment
already forces an approximate structural analogy, with an explicit — and optimal —
dimension factor.

Main results.

* `Resolution.nominal_analogy_eq` : in nominal structures the naming bijection is
  forced; every approximate analogy *is* the naming map.  (So the quantitative
  statements below cannot be improved by choosing a cleverer bijection.)
* `Resolution.nominalApproxAnalogy` : if the depth-one truth probabilities agree up
  to `η` in the `ℓ^∞` sense, then the naming map is an `(n·η/2)`-approximate
  structural analogy, where `n` is the number of worlds.  This is the `ℓ^∞ → `
  total-variation conversion, and the factor `n` is the dimension cost.
* `Resolution.nominal_approx_transport` and `nominal_approx_transport_linear` :
  consequently all depth-`d` truth probabilities agree up to `1 - (1 - nη/2)^d`,
  hence up to `d·n·η/2`.
* `Resolution.HMSharp.hm_sharp` : the dimension factor is *necessary*.  For every
  even world count `n = 2m` and every admissible `η` there are two nominal
  structures whose depth-one fragments differ by exactly `η` at every pair, and for
  which **no** ε-approximate analogy exists with `ε < n·η/2`.

Together with `nominal_depth_one_recovers` this pins down the exact observational
cost of recovering a finite probabilistic structure from depth-one observations:
the recovery is Lipschitz, with Lipschitz constant exactly `n/2`.
-/
import Probability.CopycatGroupoid
import Probability.ModalResolution

namespace Catalog.Probability.QuantitativeCopycat

open Finset

namespace Resolution

variable {S S' : Type*} [Fintype S] [Fintype S'] [DecidableEq S] [DecidableEq S']

/-! ## The naming bijection is forced -/

/-- In nominal structures the atomic constraint of a structural analogy pins the
underlying bijection down to the naming map: there is no freedom left. -/
theorem nominal_analogy_eq (M : PModalStructure S S) (N : PModalStructure S S')
    (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S)) (hN : IsNominal N κ) {ε : ℝ}
    (A : ApproxAnalogy M N ε) (s : S) : A.toEquiv s = κ s := by
  have h := A.atoms s s
  rw [hN s (A.toEquiv s), hM s s] at h
  simp only [Equiv.refl_apply, if_pos] at h
  by_contra hne
  rw [if_neg hne] at h
  norm_num at h

/-! ## `ℓ^∞` depth-one agreement gives an approximate analogy -/

/-- Depth-one truth probabilities of a structure nominal for the identity naming are
exactly the kernel entries. -/
theorem eval_next_atom_refl (M : PModalStructure S S) (hM : IsNominal M (Equiv.refl S))
    (u t : S) : M.eval (.next (.atom t)) u = M.step u t := by
  simpa using eval_next_atom M (Equiv.refl S) hM u t

/-- **Approximate Hennessy–Milner theorem (nominal case).**  If two nominal
structures on `n` worlds agree on every depth-one formula up to `η`, then the naming
bijection is an `(n·η/2)`-approximate structural analogy.  The factor `n/2` is the
cost of converting an `ℓ^∞` bound on observations into a total-variation bound on
kernels. -/
def nominalApproxAnalogy (M : PModalStructure S S) (N : PModalStructure S S')
    (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S)) (hN : IsNominal N κ) {η : ℝ}
    (hagree : ∀ t u : S,
      |M.eval (.next (.atom t)) u - N.eval (.next (.atom t)) (κ u)| ≤ η) :
    ApproxAnalogy M N (Fintype.card S * η / 2) where
  toEquiv := κ
  atoms p s := by
    rw [hN p (κ s), hM p s]
    simp
  defect s := by
    set P : S → ℝ := fun t => M.step s t with hP
    set Q : S → ℝ := fun t => N.step (κ s) (κ t) with hQ
    have hPs : ∑ t, P t = 1 := M.step_sum s
    have hQs : ∑ t, Q t = 1 := by
      rw [hQ, show (∑ t, N.step (κ s) (κ t)) = ∑ u, N.step (κ s) u from
        Equiv.sum_comp κ (fun u => N.step (κ s) u)]
      exact N.step_sum (κ s)
    have hentry : ∀ t, |P t - Q t| ≤ η := by
      intro t
      have h1 : M.eval (.next (.atom t)) s = P t := eval_next_atom_refl M hM s t
      have h2 : N.eval (.next (.atom t)) (κ s) = Q t := eval_next_atom N κ hN s t
      have := hagree t s
      rwa [h1, h2] at this
    have hsum : ∑ t, |P t - Q t| ≤ Fintype.card S * η := by
      calc ∑ t, |P t - Q t| ≤ ∑ _t : S, η := Finset.sum_le_sum fun t _ => hentry t
        _ = Fintype.card S * η := by
            simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    have hgoal : 1 - ∑ t, min (P t) (Q t) = (∑ t, |P t - Q t|) / 2 := by
      have := overlapDefect_eq_half_l1 P Q hPs hQs
      simpa [overlapDefect] using this
    rw [hgoal]
    linarith

/-- Quantitative recovery: `η`-agreement on depth one yields the geometric transport
modulus at every depth. -/
theorem nominal_approx_transport (M : PModalStructure S S) (N : PModalStructure S S')
    (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S)) (hN : IsNominal N κ) {η : ℝ}
    (h0 : 0 ≤ η) (hcard : (Fintype.card S : ℝ) * η / 2 ≤ 1)
    (hagree : ∀ t u : S,
      |M.eval (.next (.atom t)) u - N.eval (.next (.atom t)) (κ u)| ≤ η)
    (φ : PForm S) (s : S) :
    |M.eval φ s - N.eval φ (κ s)|
      ≤ 1 - (1 - Fintype.card S * η / 2) ^ φ.depth := by
  have hnn : (0 : ℝ) ≤ Fintype.card S * η / 2 :=
    div_nonneg (mul_nonneg (Nat.cast_nonneg _) h0) (by norm_num)
  have h := M.transport_le N hnn hcard (nominalApproxAnalogy M N κ hM hN hagree) φ s
  simpa [nominalApproxAnalogy] using h

/-- The linear form of the approximate recovery bound. -/
theorem nominal_approx_transport_linear (M : PModalStructure S S)
    (N : PModalStructure S S') (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S))
    (hN : IsNominal N κ) {η : ℝ} (h0 : 0 ≤ η)
    (hcard : (Fintype.card S : ℝ) * η / 2 ≤ 1)
    (hagree : ∀ t u : S,
      |M.eval (.next (.atom t)) u - N.eval (.next (.atom t)) (κ u)| ≤ η)
    (φ : PForm S) (s : S) :
    |M.eval φ s - N.eval φ (κ s)| ≤ (φ.depth : ℝ) * (Fintype.card S * η / 2) := by
  refine le_trans (nominal_approx_transport M N κ hM hN h0 hcard hagree φ s) ?_
  have hnn : (0 : ℝ) ≤ Fintype.card S * η / 2 :=
    div_nonneg (mul_nonneg (Nat.cast_nonneg _) h0) (by norm_num)
  exact one_sub_pow_le_depth_mul _ (by linarith) φ.depth

/-! ## Optimality of the dimension factor

We exhibit, for every even world count `n = 2m`, two nominal structures whose
depth-one observations differ by exactly `η` everywhere and whose total variation
defect is exactly `m·η = n·η/2`. -/

namespace HMSharp

/-- The world set: `2 * m` worlds, split into a "positive" and a "negative" half. -/
abbrev W (m : ℕ) := Bool × Fin m

variable {m : ℕ} {η : ℝ}

theorem card_W (m : ℕ) : Fintype.card (W m) = 2 * m := by
  simp [W]

/-- Summing a function that only depends on the half a world lies in. -/
theorem sum_ite_fst (m : ℕ) (x y : ℝ) :
    ∑ t : W m, (if t.1 then x else y) = m * x + m * y := by
  rw [Fintype.sum_prod_type]
  simp only [Fintype.sum_bool, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, Bool.false_eq_true, if_false, if_true]

/-- The sum of an affine function of the half a world lies in. -/
theorem sum_const_add_ite (m : ℕ) (c x y : ℝ) :
    ∑ t : W m, (c + (if t.1 then x else y)) = 2 * m * c + (m * x + m * y) := by
  rw [Finset.sum_add_distrib, sum_ite_fst]
  simp only [Finset.sum_const, Finset.card_univ, card_W, nsmul_eq_mul]
  push_cast
  ring

/-- The uniform nominal structure on `2m` worlds. -/
noncomputable def unifSys (m : ℕ) (hm : 0 < m) : PModalStructure (W m) (W m) where
  step _ _ := 1 / (2 * m)
  step_nonneg _ _ := by positivity
  step_sum s := by
    have hm' : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hm.ne'
    simp only [Finset.sum_const, Finset.card_univ, card_W, nsmul_eq_mul]
    push_cast
    field_simp
  val u v := if v = u then 1 else 0
  val_nonneg _ _ := by split <;> norm_num
  val_le_one _ _ := by split <;> norm_num

/-- The tilted nominal structure: mass `η` is moved from every "negative" world onto
the corresponding "positive" one, uniformly from every source world. -/
noncomputable def tiltSys (m : ℕ) (hm : 0 < m) (η : ℝ) (h0 : 0 ≤ η)
    (hη : η ≤ 1 / (2 * m)) :
    PModalStructure (W m) (W m) where
  step _ t := 1 / (2 * m) + (if t.1 then η else -η)
  step_nonneg _ t := by
    have hpos : (0 : ℝ) ≤ 1 / (2 * m) := by positivity
    by_cases hb : t.1 = true
    · rw [if_pos hb]; linarith
    · rw [if_neg hb]; linarith
  step_sum s := by
    have hm' : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hm.ne'
    rw [sum_const_add_ite m (1 / (2 * m)) η (-η)]
    field_simp
    ring
  val u v := if v = u then 1 else 0
  val_nonneg _ _ := by split <;> norm_num
  val_le_one _ _ := by split <;> norm_num

theorem unifSys_step (hm : 0 < m) (s t : W m) :
    (unifSys m hm).step s t = 1 / (2 * m) := rfl

theorem tiltSys_step (hm : 0 < m) (h0 : 0 ≤ η) (hη : η ≤ 1 / (2 * m)) (s t : W m) :
    (tiltSys m hm η h0 hη).step s t = 1 / (2 * m) + (if t.1 then η else -η) := rfl

theorem unifSys_nominal (hm : 0 < m) : IsNominal (unifSys m hm) (Equiv.refl (W m)) := by
  intro u v; rfl

theorem tiltSys_nominal (hm : 0 < m) (h0 : 0 ≤ η) (hη : η ≤ 1 / (2 * m)) :
    IsNominal (tiltSys m hm η h0 hη) (Equiv.refl (W m)) := by
  intro u v; rfl

/-- The two structures differ by exactly `η` on every depth-one observation. -/
theorem depth_one_gap (hm : 0 < m) (h0 : 0 ≤ η) (hη : η ≤ 1 / (2 * m)) (t u : W m) :
    |(unifSys m hm).eval (.next (.atom t)) u
      - (tiltSys m hm η h0 hη).eval (.next (.atom t)) u| = η := by
  rw [eval_next_atom_refl _ (unifSys_nominal hm) u t,
    eval_next_atom_refl _ (tiltSys_nominal hm h0 hη) u t,
    unifSys_step hm u t, tiltSys_step hm h0 hη u t]
  rcases t with ⟨b, i⟩
  cases b <;> simp [abs_of_nonneg h0]

/-- The overlap defect of the two kernels is exactly `m · η = n · η / 2`. -/
theorem overlap_defect_eq (hm : 0 < m) (h0 : 0 ≤ η) (hη : η ≤ 1 / (2 * m))
    (s : W m) :
    1 - ∑ t, min ((unifSys m hm).step s t) ((tiltSys m hm η h0 hη).step s t)
      = m * η := by
  have hm' : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hm.ne'
  have hmin : ∀ t : W m,
      min ((unifSys m hm).step s t) ((tiltSys m hm η h0 hη).step s t)
        = 1 / (2 * m) + (if t.1 then 0 else -η) := by
    intro t
    rw [unifSys_step hm s t, tiltSys_step hm h0 hη s t]
    by_cases hb : t.1 = true
    · rw [if_pos hb, if_pos hb, min_eq_left (by linarith), add_zero]
    · rw [if_neg hb, if_neg hb, min_eq_right (by linarith)]
  rw [Finset.sum_congr rfl fun t _ => hmin t, sum_const_add_ite m (1 / (2 * m)) 0 (-η)]
  field_simp
  ring

/-- **Optimality of the dimension factor in the approximate Hennessy–Milner
theorem.**  For every even world count `n = 2m` and every admissible `η`, the two
nominal structures above differ by exactly `η` on all depth-one observations, yet
every ε-approximate structural analogy between them must have `ε ≥ n · η / 2`.
Hence the conversion constant `n/2` in `nominalApproxAnalogy` cannot be lowered. -/
theorem hm_sharp (hm : 0 < m) (h0 : 0 ≤ η) (hη : η ≤ 1 / (2 * m)) :
    (∀ t u : W m, |(unifSys m hm).eval (.next (.atom t)) u
        - (tiltSys m hm η h0 hη).eval (.next (.atom t)) u| = η) ∧
      ∀ {ε : ℝ}, ApproxAnalogy (unifSys m hm) (tiltSys m hm η h0 hη) ε →
        (Fintype.card (W m) : ℝ) * η / 2 ≤ ε := by
  refine ⟨depth_one_gap hm h0 hη, ?_⟩
  intro ε A
  obtain ⟨i0⟩ : Nonempty (Fin m) := ⟨⟨0, hm⟩⟩
  set s : W m := (true, i0) with hs
  have hid : ∀ x : W m, A.toEquiv x = x := fun x => by
    simpa using nominal_analogy_eq (unifSys m hm) (tiltSys m hm η h0 hη)
      (Equiv.refl (W m)) (unifSys_nominal hm) (tiltSys_nominal hm h0 hη) A x
  have hdef := A.defect s
  rw [show (∑ t, min ((unifSys m hm).step s t)
        ((tiltSys m hm η h0 hη).step (A.toEquiv s) (A.toEquiv t)))
      = ∑ t, min ((unifSys m hm).step s t) ((tiltSys m hm η h0 hη).step s t) from
    Finset.sum_congr rfl fun t _ => by rw [hid s, hid t]] at hdef
  rw [overlap_defect_eq hm h0 hη s] at hdef
  rw [card_W]
  push_cast
  linarith

end HMSharp

end Resolution

end Catalog.Probability.QuantitativeCopycat