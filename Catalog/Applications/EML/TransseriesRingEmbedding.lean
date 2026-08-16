import Applications.EML.TransseriesEMLExpansion

/-!
# The EML exp-log algebra embeds into the transseries field and into germs at `+∞`

The finite ℝ-linear combinations of EML transmonomials form the group algebra
`EMLTS.EMLAlg = AddMonoidAlgebra ℝ Rank`.  This file upgrades the results of
`TransseriesEMLExpansion` from additive to *multiplicative* statements and packages them
as two injective ring homomorphisms out of `EMLAlg`:

* `EMLTS.toTSRingHom : EMLAlg →+* TS`, the formal transseries expansion;
* `EMLTS.emlGermHom  : EMLAlg →+* Germ atTop ℝ`, the actual EML function, taken as a germ
  at `+∞`.

The main theorem `EMLTS.germ_eq_iff_toTS_eq` says that the two homomorphisms have exactly
the same fibres: **an EML function is determined by its transseries expansion and
determines it**, while `EMLTS.germ_lt_iff_toTS_lt` records that the correspondence is an
order isomorphism onto its image.  In particular the germs of EML functions form an
ordered integral domain — a Hardy-field-style statement obtained here by transport of the
Hahn series ordering.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries

open scoped Topology

namespace EMLTS

/-- The algebra of finite ℝ-combinations of EML transmonomials. -/
abbrev EMLAlg := AddMonoidAlgebra ℝ Rank

/-! ## Monomials -/

theorem toTS_single (g : Rank) (c : ℝ) :
    toTS (Finsupp.single g c) = toLex (single g c) := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext k
  by_cases h : k = g
  · subst h; simp
  · simp [coeff_single_of_ne h, h]

theorem EMLFun_single (g : Rank) (c : ℝ) (x : ℝ) :
    EMLFun (Finsupp.single g c) x = c * rankFun g x := by
  simp [EMLFun, Finsupp.sum_single_index]

/-! ## Additive bundling -/

/-- The transseries expansion, as an additive homomorphism. -/
def toTSAddHom : (Rank →₀ ℝ) →+ TS where
  toFun := toTS
  map_zero' := toTS_zero
  map_add' := toTS_add

/-- Evaluation of an EML function at a point, as an additive homomorphism. -/
def EMLEvalAddHom (x : ℝ) : (Rank →₀ ℝ) →+ ℝ where
  toFun p := EMLFun p x
  map_zero' := EMLFun_zero x
  map_add' p q := EMLFun_add p q x

@[simp] theorem toTSAddHom_apply (p : Rank →₀ ℝ) : toTSAddHom p = toTS p := rfl

@[simp] theorem EMLEvalAddHom_apply (x : ℝ) (p : Rank →₀ ℝ) :
    EMLEvalAddHom x p = EMLFun p x := rfl

/-! ## Multiplicativity -/

theorem toTS_one : toTS (1 : EMLAlg) = 1 := by
  rw [show (1 : EMLAlg) = Finsupp.single (0 : Rank) (1 : ℝ) from rfl, toTS_single]
  rfl

theorem EMLFun_one (x : ℝ) : EMLFun (1 : EMLAlg) x = 1 := by
  rw [show (1 : EMLAlg) = Finsupp.single (0 : Rank) (1 : ℝ) from rfl, EMLFun_single]
  simp

theorem ofLex_sum_single (s : Finset Rank) (c : Rank → ℝ) :
    ofLex (∑ g ∈ s, (toLex (single g (c g)) : TS)) = ∑ g ∈ s, single g (c g) := by
  classical
  induction s using Finset.induction with
  | empty => rfl
  | insert g s hg ih => rw [Finset.sum_insert hg, Finset.sum_insert hg, ← ih]; rfl

/-- A finitely supported expansion is the finite sum of its transmonomials. -/
theorem toTS_eq_sum_single (p : Rank →₀ ℝ) :
    toTS p = ∑ g ∈ p.support, toLex (single g (p g)) := by
  classical
  refine ofLex.injective (HahnSeries.ext ?_)
  funext k
  rw [coeff_toTS, ofLex_sum_single, HahnSeries.coeff_sum]
  simp only [HahnSeries.coeff_single]
  symm
  rw [Finset.sum_eq_single k (fun b _ hb => by simp [Ne.symm hb])
    (fun hk => by simp [Finsupp.notMem_support_iff.mp hk])]
  simp

theorem toTS_mul (p q : EMLAlg) : toTS (p * q) = toTS p * toTS q := by
  classical
  have hmul : (p * q : EMLAlg)
      = p.sum fun g c => q.sum fun h e => Finsupp.single (g + h) (c * e) :=
    AddMonoidAlgebra.mul_def p q
  calc toTS (p * q) = toTSAddHom (p * q) := rfl
    _ = ∑ g ∈ p.support, ∑ h ∈ q.support, toLex (single (g + h) (p g * q h)) := by
        rw [hmul]
        simp only [Finsupp.sum]
        rw [map_sum]
        refine Finset.sum_congr rfl fun g _ => ?_
        rw [map_sum]
        exact Finset.sum_congr rfl fun h _ => by rw [toTSAddHom_apply, toTS_single]
    _ = (∑ g ∈ p.support, (toLex (single g (p g)) : TS))
          * ∑ h ∈ q.support, (toLex (single h (q h)) : TS) := by
        rw [Finset.sum_mul_sum]
        exact Finset.sum_congr rfl fun g _ => Finset.sum_congr rfl fun h _ => by
          rw [← toLex_mul, single_mul_single]
    _ = toTS p * toTS q := by rw [← toTS_eq_sum_single, ← toTS_eq_sum_single]

theorem EMLFun_mul (p q : EMLAlg) (x : ℝ) :
    EMLFun (p * q) x = EMLFun p x * EMLFun q x := by
  classical
  have hmul : (p * q : EMLAlg)
      = p.sum fun g c => q.sum fun h e => Finsupp.single (g + h) (c * e) :=
    AddMonoidAlgebra.mul_def p q
  calc EMLFun (p * q) x = EMLEvalAddHom x (p * q) := rfl
    _ = ∑ g ∈ p.support, ∑ h ∈ q.support, (p g * q h) * rankFun (g + h) x := by
        rw [hmul]
        simp only [Finsupp.sum]
        rw [map_sum]
        refine Finset.sum_congr rfl fun g _ => ?_
        rw [map_sum]
        exact Finset.sum_congr rfl fun h _ => by rw [EMLEvalAddHom_apply, EMLFun_single]
    _ = (∑ g ∈ p.support, p g * rankFun g x) * ∑ h ∈ q.support, q h * rankFun h x := by
        rw [Finset.sum_mul_sum]
        exact Finset.sum_congr rfl fun g _ => Finset.sum_congr rfl fun h _ => by
          rw [rankFun_add]; ring
    _ = EMLFun p x * EMLFun q x := by rw [← EMLFun_eq_sum, ← EMLFun_eq_sum]

/-! ## The two ring homomorphisms -/

/-- The formal transseries expansion of an element of the EML algebra. -/
def toTSRingHom : EMLAlg →+* TS where
  toFun := toTS
  map_one' := toTS_one
  map_mul' := toTS_mul
  map_zero' := toTS_zero
  map_add' := toTS_add

/-- The EML function of an element of the EML algebra, as a germ at `+∞`. -/
def emlGermHom : EMLAlg →+* Germ (atTop : Filter ℝ) ℝ where
  toFun p := (EMLFun p : Germ (atTop : Filter ℝ) ℝ)
  map_one' := by
    refine Germ.coe_eq.mpr (Eventually.of_forall fun x => ?_)
    exact EMLFun_one x
  map_mul' p q := by
    refine Germ.coe_eq.mpr (Eventually.of_forall fun x => ?_)
    exact EMLFun_mul p q x
  map_zero' := by
    refine Germ.coe_eq.mpr (Eventually.of_forall fun x => ?_)
    exact EMLFun_zero x
  map_add' p q := by
    refine Germ.coe_eq.mpr (Eventually.of_forall fun x => ?_)
    exact EMLFun_add p q x

@[simp] theorem toTSRingHom_apply (p : EMLAlg) : toTSRingHom p = toTS p := rfl

@[simp] theorem emlGermHom_apply (p : EMLAlg) :
    emlGermHom p = (EMLFun p : Germ (atTop : Filter ℝ) ℝ) := rfl

/-- **The transseries expansion is a faithful ring embedding.** -/
theorem toTSRingHom_injective : Function.Injective toTSRingHom := toTS_injective

/-- **An EML function determines and is determined by its transseries expansion.** -/
theorem germ_eq_iff_toTS_eq (p q : EMLAlg) :
    emlGermHom p = emlGermHom q ↔ toTSRingHom p = toTSRingHom q := by
  rw [emlGermHom_apply, emlGermHom_apply, Germ.coe_eq, toTSRingHom_apply, toTSRingHom_apply]
  exact eventuallyEq_iff_toTS_eq p q

/-- The germ homomorphism is injective: distinct formal EML expressions have distinct
germs at `+∞`. -/
theorem emlGermHom_injective : Function.Injective emlGermHom := by
  intro p q h
  exact toTS_injective ((germ_eq_iff_toTS_eq p q).mp h)

/-- The correspondence is an order embedding as well as a ring embedding. -/
theorem germ_lt_iff_toTS_lt (p q : EMLAlg) :
    (∀ᶠ x in atTop, EMLFun p x < EMLFun q x) ↔ toTSRingHom p < toTSRingHom q :=
  eventually_lt_iff_toTS_lt p q

/-- Germs of EML functions form an integral domain: a product of two EML functions that
vanishes identically near `+∞` has a factor vanishing identically near `+∞`. -/
theorem eventually_ne_zero_mul {p q : EMLAlg} (hp : p ≠ 0) (hq : q ≠ 0) :
    ∀ᶠ x in atTop, EMLFun p x * EMLFun q x ≠ 0 := by
  filter_upwards [eventually_ne_zero hp, eventually_ne_zero hq] with x h1 h2
  exact mul_ne_zero h1 h2

end EMLTS