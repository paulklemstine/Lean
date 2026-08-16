import Applications.EML.TransseriesAsymptoticComparison

/-!
# The field of constants of the EML derivation

The EML algebra `EMLTS.EMLAlg` carries the derivation `EMLTS.emlDeriv`
(see `Applications.EML.TransseriesDerivation`).  A basic structural question about any
differential ring is: *what is the kernel of the derivation?*

Here we prove that the kernel is exactly the line of real constants,

  `emlDeriv p = 0 ↔ p = c · 1` for some `c : ℝ`.

The proof is deliberately *cross-domain*: the algebraic statement is deduced from the
analytic one.  A formal EML expression with vanishing formal derivative gives a real
function on `(1, ∞)` with vanishing derivative, hence a constant function by the mean
value theorem; and the injectivity of the germ representation
(`EMLTS.eventually_ne_zero`) then forces the formal expression itself to be that constant.
No cancellation combinatorics in the transseries algebra is needed.

## Main results

* `EMLTS.emlDeriv_eq_zero_iff` : the kernel of the derivation is `ℝ · 1`.
* `EMLTS.constants_eq_ker` : the same statement as an equality of subgroups.
* `EMLTS.emlDeriv_eq_zero_iff_eventually_const` : a formal EML expression has zero
  derivative iff its germ at `+∞` is constant.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries Set

open scoped Topology

namespace EMLTS

/-! ## The constants are in the kernel -/

@[simp] theorem dlog_zero : dlog (0 : Rank) = 0 := by
  have h1 : rd (0 : Rank) = 0 := rfl
  have h2 : ra (0 : Rank) = 0 := rfl
  have h3 : rb (0 : Rank) = 0 := rfl
  have h4 : rc (0 : Rank) = 0 := rfl
  simp [dlog, h1, h2, h3, h4]

/-- Real constants are killed by the derivation. -/
theorem emlDeriv_const (c : ℝ) :
    emlDeriv (AddMonoidAlgebra.single (0 : Rank) c) = 0 := by
  rw [emlDeriv_single, dlog_zero, mul_zero]

theorem EMLFun_const (c : ℝ) (x : ℝ) :
    EMLFun (AddMonoidAlgebra.single (0 : Rank) c) x = c := by
  rw [EMLFun_single, rankFun_zero, mul_one]

/-! ## Zero derivative forces an eventually constant germ -/

/-- If the formal derivative vanishes then the associated real function is constant on
`[2, ∞)`. -/
theorem eq_const_of_emlDeriv_eq_zero {p : EMLAlg} (hp : emlDeriv p = 0) :
    ∀ x : ℝ, 2 ≤ x → EMLFun p x = EMLFun p 2 := by
  have hderiv : ∀ x : ℝ, 1 < x → HasDerivAt (EMLFun p) 0 x := by
    intro x hx
    have h := hasDerivAt_EMLFun p hx
    rwa [hp, show EMLFun (0 : EMLAlg) x = 0 by simp [EMLFun]] at h
  intro x hx
  have hmem : ∀ y ∈ Icc (2 : ℝ) x, (1 : ℝ) < y := by
    intro y hy
    linarith [hy.1]
  have hcont : ContinuousOn (EMLFun p) (Icc 2 x) := fun y hy =>
    ((hderiv y (hmem y hy)).continuousAt).continuousWithinAt
  have hd : ∀ y ∈ Ico (2 : ℝ) x, HasDerivWithinAt (EMLFun p) 0 (Ici y) y := by
    intro y hy
    exact (hderiv y (by linarith [hy.1])).hasDerivWithinAt
  exact constant_of_has_deriv_right_zero hcont hd x (right_mem_Icc.mpr hx)

/-! ## The kernel of the derivation -/

/-- **The constants of the EML derivation.**  A formal EML expression has vanishing
derivative if and only if it is a real constant. -/
theorem emlDeriv_eq_zero_iff (p : EMLAlg) :
    emlDeriv p = 0 ↔ ∃ c : ℝ, p = AddMonoidAlgebra.single (0 : Rank) c := by
  constructor
  · intro hp
    refine ⟨EMLFun p 2, ?_⟩
    set c : ℝ := EMLFun p 2 with hc
    set q : EMLAlg := p - AddMonoidAlgebra.single (0 : Rank) c with hq
    have hzero : ∀ x : ℝ, 2 ≤ x → EMLFun q x = 0 := by
      intro x hx
      rw [hq, EMLFun_sub, EMLFun_const, eq_const_of_emlDeriv_eq_zero hp x hx, sub_self]
    have hq0 : q = 0 := by
      by_contra hne
      obtain ⟨x, hx1, hx2⟩ :=
        ((eventually_ne_zero hne).and (eventually_ge_atTop (2 : ℝ))).exists
      exact hx1 (hzero x hx2)
    exact sub_eq_zero.mp hq0
  · rintro ⟨c, rfl⟩
    exact emlDeriv_const c

/-- The kernel of the derivation, as a set, is the line of real constants. -/
theorem constants_eq_ker :
    {p : EMLAlg | emlDeriv p = 0}
      = Set.range fun c : ℝ => (AddMonoidAlgebra.single (0 : Rank) c : EMLAlg) := by
  ext p
  simpa [Set.mem_range, eq_comm] using emlDeriv_eq_zero_iff p

/-- A formal EML expression has zero derivative iff its germ at `+∞` is a constant. -/
theorem emlDeriv_eq_zero_iff_eventually_const (p : EMLAlg) :
    emlDeriv p = 0 ↔ ∃ c : ℝ, ∀ᶠ x in atTop, EMLFun p x = c := by
  constructor
  · intro hp
    refine ⟨EMLFun p 2, ?_⟩
    filter_upwards [eventually_ge_atTop (2 : ℝ)] with x hx
    exact eq_const_of_emlDeriv_eq_zero hp x hx
  · rintro ⟨c, hc⟩
    have hEq : ∀ᶠ x in atTop, EMLFun p x = EMLFun (AddMonoidAlgebra.single (0 : Rank) c) x := by
      filter_upwards [hc] with x hx
      rw [hx, EMLFun_const]
    have : p = AddMonoidAlgebra.single (0 : Rank) c :=
      toTS_injective ((eventuallyEq_iff_toTS_eq _ _).mp hEq)
    rw [this]
    exact emlDeriv_const c

/-- Contrapositive form: a non-constant EML expression has a nonzero derivative. -/
theorem emlDeriv_ne_zero_of_ne_const {p : EMLAlg}
    (hp : ∀ c : ℝ, p ≠ AddMonoidAlgebra.single (0 : Rank) c) : emlDeriv p ≠ 0 := by
  intro h
  obtain ⟨c, hc⟩ := (emlDeriv_eq_zero_iff p).mp h
  exact hp c hc

/-! ## The fixed points of the derivation -/

theorem rankFun_rExp (x : ℝ) : rankFun rExp x = Real.exp x := by
  simp [rankFun, rankLog, rExp]

theorem EMLFun_single_rExp (c x : ℝ) :
    EMLFun (AddMonoidAlgebra.single rExp c) x = c * Real.exp x := by
  rw [EMLFun_single, rankFun_rExp]

/-- **The fixed points of the EML derivation.**  `p' = p` holds exactly for the real
multiples of `exp x`; the differential equation `y' = y` has no other EML solution. -/
theorem emlDeriv_eq_self_iff (p : EMLAlg) :
    emlDeriv p = p ↔ ∃ c : ℝ, p = AddMonoidAlgebra.single rExp c := by
  constructor
  · intro hp
    set f : ℝ → ℝ := fun x => EMLFun p x * Real.exp (-x) with hf
    have hderiv : ∀ x : ℝ, 1 < x → HasDerivAt f 0 x := by
      intro x hx
      have h1 : HasDerivAt (EMLFun p) (EMLFun p x) x := by
        have h := hasDerivAt_EMLFun p hx
        rwa [hp] at h
      have h2 : HasDerivAt (fun y : ℝ => Real.exp (-y)) (-Real.exp (-x)) x := by
        simpa using (Real.hasDerivAt_exp (-x)).comp x (hasDerivAt_neg x)
      have h3 := h1.mul h2
      have h4 : EMLFun p x * Real.exp (-x) + EMLFun p x * -Real.exp (-x) = 0 := by ring
      rwa [h4] at h3
    have hconst : ∀ x : ℝ, 2 ≤ x → f x = f 2 := by
      intro x hx
      have hcont : ContinuousOn f (Icc 2 x) := fun y hy =>
        ((hderiv y (by linarith [hy.1])).continuousAt).continuousWithinAt
      have hd : ∀ y ∈ Ico (2 : ℝ) x, HasDerivWithinAt f 0 (Ici y) y := fun y hy =>
        (hderiv y (by linarith [hy.1])).hasDerivWithinAt
      exact constant_of_has_deriv_right_zero hcont hd x (right_mem_Icc.mpr hx)
    refine ⟨f 2, ?_⟩
    refine toTS_injective ((eventuallyEq_iff_toTS_eq _ _).mp ?_)
    filter_upwards [eventually_ge_atTop (2 : ℝ)] with x hx
    have h := hconst x hx
    rw [hf] at h
    simp only at h
    have hf2 : f 2 = EMLFun p 2 * Real.exp (-2) := rfl
    rw [EMLFun_single_rExp, hf2, ← h, mul_assoc, ← Real.exp_add, neg_add_cancel,
      Real.exp_zero, mul_one]
  · rintro ⟨c, rfl⟩
    exact emlDeriv_exp c

end EMLTS