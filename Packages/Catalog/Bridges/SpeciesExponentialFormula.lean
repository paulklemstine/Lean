/-
# The exponential formula for species

For a species `G`, the composite `E ∘ G` is the species whose structures on `A` are a
partition of `A` together with a `G`-structure on every block (recall that the blocks of
a `Blocking` are automatically nonempty, so `Species.comp set G` is Joyal's `E ∘ G₊`).

The main theorem of this file is the combinatorial heart of the *exponential formula*:
deleting the block of a distinguished ghost point exhibits a bijection

    (E ∘ G)′[A] ≃ Σ (S ⊆ A), G′[S] × (E ∘ G)[Aᶜ],

that is, `(E ∘ G)′` and `G′ · (E ∘ G)` have the same counting sequence.  Passing to
exponential generating series this is the differential equation

    (d/dX) (egf (E ∘ G)) = (d/dX) (egf G) · egf (E ∘ G),      egf (E ∘ G)(0) = 1,

which is the power-series form of `egf (E ∘ G) = exp (egf G)`.

Two applications close the file:

* the species of partitions `E ∘ E` is counted by the **Bell numbers**;
* the species `E ∘ C` of "sets of cycles" is counted by `n!`, i.e. the exponential
  formula recovers the cycle decomposition of permutations at the level of counts.
-/
import Bridges.SpeciesComposition
import Bridges.SpeciesCycles

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

open Blocking

variable (G : Species)

/-! ## The decomposition of `(E ∘ G)`-structures on `Option A` -/

/-- An `(E ∘ G)`-structure is a partition together with `G`-structures on the blocks. -/
def compSetObjEquiv (A : Type) :
    (set.comp G).obj A ≃ Σ p : Blocking A, ∀ c : p.Block, G.obj c.elems :=
  Equiv.sigmaCongrRight fun _ => Equiv.punitProd _

/-- Distributing a factor which does not depend on the index out of a sigma type. -/
def sigmaProdLeft {ι : Type} {Z : Type} {W : ι → Type} : (Σ i : ι, Z × W i) ≃ Z × Σ i : ι, W i where
  toFun x := (x.2.1, ⟨x.1, x.2.2⟩)
  invFun y := ⟨y.2.1, (y.1, y.2.2)⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- `G`-structures on the blocks of a reassembled blocking are the same thing as a
`G`-structure on the block of `none` together with `G`-structures on the blocks of the
complement. -/
def compFibreEquiv {A : Type} {q : A → Bool} (p : Blocking {a : A // q a = false}) :
    (∀ c : (ofDecomp q p).Block, G.obj c.elems) ≃
      G.obj (Option {a : A // q a = true}) × (∀ c : p.Block, G.obj c.elems) :=
  (Equiv.piCongrLeft (fun c : (ofDecomp q p).Block => G.obj c.elems)
      (blockOptionEquiv p)).symm.trans
    (Equiv.piOptionEquivProd.trans
      (Equiv.prodCongr (G.transport (noneBlockElemsEquiv p))
        (Equiv.piCongrRight fun c => G.transport (liftBlockElemsEquiv p c))))

/-- **The combinatorial exponential formula.**  An `(E ∘ G)`-structure on `Option A` is
the same thing as a subset `S` of `A`, a `G`-structure on `S ∪ {none}` (the block of the
ghost point `none`) and an `(E ∘ G)`-structure on the complement of `S`. -/
def derivCompSetEquiv (A : Type) :
    (set.comp G).obj (Option A) ≃
      Σ q : A → Bool,
        G.obj (Option {a : A // q a = true}) × (set.comp G).obj {a : A // q a = false} :=
  (compSetObjEquiv G (Option A)).trans
    ((Equiv.sigmaCongrLeft
        (β := fun p : Blocking (Option A) => ∀ c : p.Block, G.obj c.elems)
        (optionEquiv.symm)).symm.trans
      ((Equiv.sigmaAssoc
          (fun (q : A → Bool) (p : Blocking {a : A // q a = false}) =>
            ∀ c : (ofDecomp q p).Block, G.obj c.elems)).trans
        (Equiv.sigmaCongrRight fun _ =>
          ((Equiv.sigmaCongrRight fun p => compFibreEquiv G p).trans sigmaProdLeft).trans
            (Equiv.prodCongr (Equiv.refl _) (compSetObjEquiv G _).symm))))

/-- The derivative of `E ∘ G` and the product `G′ · (E ∘ G)` have the same structures. -/
def derivCompSetIsoObj (A : Type) :
    (set.comp G).deriv.obj A ≃ (G.deriv.mul (set.comp G)).obj A :=
  derivCompSetEquiv G A

/-- **`(E ∘ G)′` and `G′ · (E ∘ G)` are equipotent.** -/
theorem card_deriv_comp_set (n : ℕ) :
    (set.comp G).deriv.card n = (G.deriv.mul (set.comp G)).card n :=
  Nat.card_congr (derivCompSetIsoObj G (Fin n))

/-- **The recurrence of the exponential formula**: the block of the first point can be
any nonempty subset carrying a `G`-structure, and the rest is an `(E ∘ G)`-structure. -/
theorem card_comp_set_succ (n : ℕ) :
    (set.comp G).card (n + 1)
      = ∑ k ∈ Finset.range (n + 1), n.choose k * G.card (k + 1) * (set.comp G).card (n - k) := by
  have h := card_deriv_comp_set G n
  rw [card_deriv, card_mul] at h
  simpa using h

@[simp] theorem card_comp_set_zero : (set.comp G).card 0 = 1 := by
  rw [card_comp_zero, card_set]

/-! ## The generating series form -/

/-- **The exponential formula**, in the form of a differential equation:
`(egf (E ∘ G))′ = (egf G)′ · egf (E ∘ G)`.  Together with the initial condition
`egf (E ∘ G)(0) = 1` this says `egf (E ∘ G) = exp (egf G)`. -/
theorem deriv_egf_comp_set :
    d⁄dX ℚ (set.comp G).egf = d⁄dX ℚ G.egf * (set.comp G).egf := by
  have h : (set.comp G).deriv.egf = (G.deriv.mul (set.comp G)).egf :=
    (egf_eq_iff _ _).2 (card_deriv_comp_set G)
  rwa [egf_deriv, egf_mul, egf_deriv] at h

theorem coeff_zero_egf_comp_set : coeff 0 (set.comp G).egf = 1 := by
  rw [coeff_egf, card_comp_set_zero]
  simp

/-- The counting sequence of `E ∘ G` is determined by that of `G`: any two species with
the same counting sequence have the same "set of structures" composite. -/
theorem card_comp_set_congr {G H : Species} (h : ∀ n, G.card (n + 1) = H.card (n + 1)) (n : ℕ) :
    (set.comp G).card n = (set.comp H).card n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      match n with
      | 0 => simp
      | (m + 1) =>
          rw [card_comp_set_succ, card_comp_set_succ]
          refine Finset.sum_congr rfl fun k hk => ?_
          have hk' : k ≤ m := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
          rw [h, ih (m - k) (by omega)]

/-! ## The closed form `egf (E ∘ G) = exp (egf G)` -/

/-- Uniqueness for the linear differential equation `D′ = f · D`, `D(0) = 0`. -/
theorem eq_zero_of_derivative_eq_mul {f D : ℚ⟦X⟧} (h : d⁄dX ℚ D = f * D)
    (h0 : coeff 0 D = 0) : D = 0 := by
  ext n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      match n with
      | 0 => simpa using h0
      | (m + 1) =>
          have hcoeff : coeff m (d⁄dX ℚ D) = coeff (m + 1) D * (m + 1) :=
            PowerSeries.coeff_derivative D m
          rw [h, PowerSeries.coeff_mul] at hcoeff
          have hzero : ∑ x ∈ Finset.antidiagonal m, coeff x.1 f * coeff x.2 D = 0 := by
            refine Finset.sum_eq_zero fun x hx => ?_
            have hx2 : x.2 ≤ m := by
              have := Finset.mem_antidiagonal.1 hx
              omega
            have : coeff x.2 D = 0 := by simpa using ih x.2 (by omega)
            rw [this, mul_zero]
          rw [hzero] at hcoeff
          have hne : ((m : ℚ) + 1) ≠ 0 := by positivity
          have hmul : coeff (m + 1) D * ((m : ℚ) + 1) = 0 := hcoeff.symm
          rcases mul_eq_zero.1 hmul with h' | h'
          · simpa using h'
          · exact absurd h' hne

/-- Two solutions of `A′ = f · A` with the same constant term coincide. -/
theorem eq_of_derivative_eq_mul {f A₁ A₂ : ℚ⟦X⟧} (h₁ : d⁄dX ℚ A₁ = f * A₁)
    (h₂ : d⁄dX ℚ A₂ = f * A₂) (h0 : coeff 0 A₁ = coeff 0 A₂) : A₁ = A₂ := by
  have hd : A₁ - A₂ = 0 := by
    refine eq_zero_of_derivative_eq_mul (f := f) ?_ ?_
    · rw [map_sub, h₁, h₂, mul_sub]
    · rw [map_sub, h0, sub_self]
  exact sub_eq_zero.1 hd

/-- Uniqueness for `A′ · u = f · A` when `u` is invertible (i.e. has nonzero constant
term). -/
theorem eq_of_derivative_mul_eq {u f A₁ A₂ : ℚ⟦X⟧} (hu : PowerSeries.constantCoeff u ≠ 0)
    (h₁ : d⁄dX ℚ A₁ * u = f * A₁) (h₂ : d⁄dX ℚ A₂ * u = f * A₂)
    (h0 : coeff 0 A₁ = coeff 0 A₂) : A₁ = A₂ := by
  have hinv : u * u⁻¹ = 1 := PowerSeries.mul_inv_cancel u hu
  have step : ∀ A : ℚ⟦X⟧, d⁄dX ℚ A * u = f * A → d⁄dX ℚ A = f * u⁻¹ * A := by
    intro A h
    calc d⁄dX ℚ A = d⁄dX ℚ A * (u * u⁻¹) := by rw [hinv, mul_one]
      _ = (d⁄dX ℚ A * u) * u⁻¹ := by ring
      _ = (f * A) * u⁻¹ := by rw [h]
      _ = f * u⁻¹ * A := by ring
  exact eq_of_derivative_eq_mul (step A₁ h₁) (step A₂ h₂) h0

/-- The constant term of `exp` substituted into a series without constant term. -/
theorem coeff_zero_exp_subst {B : ℚ⟦X⟧} (hB : PowerSeries.constantCoeff B = 0) :
    coeff 0 ((PowerSeries.exp ℚ).subst B) = 1 := by
  have hsub : PowerSeries.HasSubst B := PowerSeries.HasSubst.of_constantCoeff_zero' hB
  rw [PowerSeries.coeff_zero_eq_constantCoeff]
  show MvPowerSeries.constantCoeff ((PowerSeries.exp ℚ).subst B) = 1
  rw [PowerSeries.constantCoeff_subst hsub, finsum_eq_single _ 0]
  · simp
  · intro d hd
    have hz : MvPowerSeries.constantCoeff (B ^ d) = 0 := by
      show PowerSeries.constantCoeff (B ^ d) = 0
      rw [map_pow, hB, zero_pow hd]
    simp [hz]

/-- **The exponential formula.**  The exponential generating series of `E ∘ G`
(partitions with a `G`-structure on each block) is the exponential of the series of `G`
with its constant term removed — the constant term is irrelevant because the blocks of a
partition are nonempty. -/
theorem egf_comp_set_sub_const :
    (set.comp G).egf = (PowerSeries.exp ℚ).subst (G.egf - PowerSeries.C (coeff 0 G.egf)) := by
  set B : ℚ⟦X⟧ := G.egf - PowerSeries.C (coeff 0 G.egf) with hBdef
  have hB : PowerSeries.constantCoeff B = 0 := by
    rw [← PowerSeries.coeff_zero_eq_constantCoeff, hBdef, map_sub, PowerSeries.coeff_zero_C,
      sub_self]
  have hderiv : d⁄dX ℚ B = d⁄dX ℚ G.egf := by
    rw [hBdef, map_sub, PowerSeries.derivative_C, sub_zero]
  have hsub : PowerSeries.HasSubst B := PowerSeries.HasSubst.of_constantCoeff_zero' hB
  refine eq_of_derivative_eq_mul (f := d⁄dX ℚ G.egf) (deriv_egf_comp_set G) ?_ ?_
  · rw [PowerSeries.derivative_subst (hg := hsub), PowerSeries.derivative_exp, hderiv]
    ring
  · rw [coeff_zero_egf_comp_set, coeff_zero_exp_subst hB]

/-- **The exponential formula** for a species with no structures on the empty set:
`egf (E ∘ G) = exp (egf G)`. -/
theorem egf_comp_set (hG : G.card 0 = 0) :
    (set.comp G).egf = (PowerSeries.exp ℚ).subst G.egf := by
  have h0 : coeff 0 G.egf = 0 := by rw [coeff_egf, hG]; simp
  rw [egf_comp_set_sub_const, h0]
  simp

/-! ## Partitions and the Bell numbers -/

/-- The species of partitions: `E ∘ E`, a partition with no extra structure on the
blocks. -/
abbrev partitions : Species := set.comp set

/-- The number of partitions of an `n`-element set is the `n`-th Bell number. -/
theorem card_partitions (n : ℕ) : partitions.card n = Nat.bell n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      match n with
      | 0 => simp
      | (m + 1) =>
          rw [card_comp_set_succ, Nat.bell_succ]
          rw [Finset.sum_range fun k => (m.choose k * set.card (k + 1) * partitions.card (m - k))]
          refine Finset.sum_congr rfl fun k _ => ?_
          rw [card_set, mul_one, ih (m - k.1) (by omega)]

/-- An `(E ∘ E)`-structure is nothing but a partition. -/
def compSetSetEquiv (A : Type) : (set.comp set).obj A ≃ Blocking A :=
  haveI : ∀ p : Blocking A, Unique (∀ c : p.Block, set.obj c.elems) := fun p =>
    inferInstanceAs (Unique (∀ _ : p.Block, PUnit))
  (compSetObjEquiv set A).trans
    (Equiv.sigmaUnique _ (fun p : Blocking A => ∀ c : p.Block, set.obj c.elems))

/-- **The number of partitions of an `n`-element set is the `n`-th Bell number.** -/
theorem card_blocking_eq_bell (n : ℕ) : Nat.card (Blocking (Fin n)) = Nat.bell n := by
  rw [← card_partitions n]
  exact (Nat.card_congr (compSetSetEquiv (Fin n))).symm

/-! ### `E ∘ X ≅ E` -/

open scoped Classical in
/-- The discrete partition of `A`: every block is a singleton. -/
noncomputable def discreteBlocking (A : Type) : Blocking A where
  rel a b := decide (a = b)
  self a := by simp
  glue a b h := by
    have hab : a = b := by simpa using h
    subst hab
    rfl

theorem subsingleton_sing_obj (X : Type) : Subsingleton (sing.obj X) :=
  ⟨fun x y => Subtype.ext (y.2 x.1)⟩

/-- A partition all of whose blocks are singletons is the discrete partition. -/
theorem blocking_eq_discrete {A : Type} (p : Blocking A) (v : ∀ c : p.Block, sing.obj c.elems) :
    p = discreteBlocking A := by
  classical
  refine Blocking.ext (funext fun a => funext fun b => ?_)
  have key : p.rel a b = true ↔ a = b := by
    constructor
    · intro h
      let c : p.Block := p.blockOf a
      have ha : c.1 a = true := p.self a
      have hb : c.1 b = true := h
      have := (v c).2
      have h1 : (⟨a, ha⟩ : c.elems) = (v c).1 := this _
      have h2 : (⟨b, hb⟩ : c.elems) = (v c).1 := this _
      have : (⟨a, ha⟩ : c.elems) = ⟨b, hb⟩ := by rw [h1, h2]
      exact congrArg Subtype.val this
    · rintro rfl
      exact p.self _
  show p.rel a b = decide (a = b)
  by_cases hab : a = b
  · subst hab
    simp [p.self]
  · have : p.rel a b ≠ true := fun h => hab (key.1 h)
    simp only [hab, decide_false]
    simpa using this

open scoped Classical in
noncomputable instance uniqueElemsDiscrete {A : Type} (c : (discreteBlocking A).Block) :
    Unique c.elems := by
  classical
  set a := Classical.choose c.2 with hadef
  have ha : (discreteBlocking A).rel a = c.1 := Classical.choose_spec c.2
  have hmem : c.1 a = true := by rw [← ha]; simp [discreteBlocking]
  refine ⟨⟨⟨a, hmem⟩⟩, fun x => Subtype.ext ?_⟩
  have hx : c.1 x.1 = true := x.2
  have hx' : (discreteBlocking A).rel a x.1 = true := by rw [ha]; exact hx
  have : a = x.1 := by simpa [discreteBlocking] using hx'
  exact this.symm

open scoped Classical in
noncomputable instance uniqueCompSetSing (A : Type) : Unique ((set.comp sing).obj A) where
  default := ⟨discreteBlocking A, PUnit.unit, fun c => ⟨default, fun y => Subsingleton.elim _ _⟩⟩
  uniq := by
    rintro ⟨p, u, v⟩
    have hp : p = discreteBlocking A := blocking_eq_discrete p v
    subst hp
    refine congrArg (Sigma.mk (discreteBlocking A))
      (Prod.ext (@Subsingleton.elim PUnit _ u PUnit.unit) ?_)
    funext c
    exact @Subsingleton.elim _ (subsingleton_sing_obj _) _ _

/-- **Substituting `X` into `E` gives back `E`**: the only partition all of whose blocks
are singletons is the discrete one. -/
noncomputable def compSetSingIso : (set.comp sing) ≃ₛ set where
  hom _ := (Equiv.equivPUnit _).trans (Equiv.refl _)
  naturality _ _ := @Subsingleton.elim PUnit _ _ _

/-- Substituting the singleton species into `E` gives back `E`, in counting form. -/
theorem card_comp_set_sing (n : ℕ) : (set.comp sing).card n = 1 := by
  rw [compSetSingIso.card_eq n, card_set]

/-- **The Bell recurrence**, obtained from the species of partitions: the block of a
distinguished point can be any subset containing it. -/
theorem bell_succ_choose (n : ℕ) :
    Nat.bell (n + 1) = ∑ k ∈ Finset.range (n + 1), n.choose k * Nat.bell k := by
  have h := card_comp_set_succ set n
  rw [card_partitions] at h
  have h2 : ∀ k ∈ Finset.range (n + 1),
      n.choose k * set.card (k + 1) * partitions.card (n - k) = n.choose k * Nat.bell (n - k) := by
    intro k _
    rw [card_set, mul_one, card_partitions]
  rw [Finset.sum_congr rfl h2] at h
  rw [h, ← Finset.sum_range_reflect]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
  rw [show n + 1 - 1 - k = n - k from rfl, Nat.choose_symm hk', Nat.sub_sub_self hk']

/-- The partitions species is counted by the Bell numbers, whose exponential generating
series therefore satisfies `B′ = exp(X) · B`, `B(0) = 1`. -/
theorem deriv_egf_partitions :
    d⁄dX ℚ partitions.egf = PowerSeries.exp ℚ * partitions.egf := by
  have h := deriv_egf_comp_set set
  rw [egf_set, PowerSeries.derivative_exp] at h
  exact h

/-- **The exponential generating series of the Bell numbers** is `exp (exp X - 1)`. -/
theorem egf_partitions : partitions.egf = (PowerSeries.exp ℚ).subst (PowerSeries.exp ℚ - 1) := by
  have h := egf_comp_set_sub_const set
  rw [egf_set] at h
  have h0 : coeff 0 (PowerSeries.exp ℚ) = 1 := by simp
  rw [h0] at h
  simpa using h

/-! ## Sets of cycles: the cycle decomposition of permutations, counted -/

/-- **`E ∘ C` is equipotent with the species of permutations**: a permutation is a set of
cycles.  Here this is deduced from the exponential formula rather than from an explicit
bijection. -/
theorem card_comp_set_cyc (n : ℕ) : (set.comp cyc).card n = n.factorial := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      match n with
      | 0 => simp
      | (m + 1) =>
          rw [card_comp_set_succ]
          have hterm : ∀ k ∈ Finset.range (m + 1),
              m.choose k * cyc.card (k + 1) * (set.comp cyc).card (m - k) = m.factorial := by
            intro k hk
            have hk' : k ≤ m := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
            rw [card_cyc (Nat.succ_le_succ (Nat.zero_le k)), ih (m - k) (by omega)]
            have hfac : m.choose k * k.factorial * (m - k).factorial = m.factorial :=
              Nat.choose_mul_factorial_mul_factorial hk'
            simpa [mul_assoc] using hfac
          rw [Finset.sum_congr rfl hterm, Finset.sum_const, Finset.card_range, smul_eq_mul,
            Nat.factorial_succ]

/-- Consequently `E ∘ C` has the same exponential generating series as the species of
permutations, namely `1/(1-X)`. -/
theorem egf_comp_set_cyc : (set.comp cyc).egf * (1 - PowerSeries.X) = 1 := by
  have h : (set.comp cyc).egf = perm.egf := by
    refine (egf_eq_iff _ _).2 fun n => ?_
    rw [card_comp_set_cyc, card_perm]
  rw [h, egf_perm]

/-- Substituting the series of the species of cycles into `exp` gives `1/(1-X)`: the
power-series identity `exp (log (1/(1-X))) = 1/(1-X)`, obtained combinatorially. -/
theorem exp_subst_egf_cyc :
    (PowerSeries.exp ℚ).subst cyc.egf * (1 - PowerSeries.X) = 1 := by
  rw [← egf_comp_set cyc card_cyc_zero]
  exact egf_comp_set_cyc

end Species

end SpeciesEGF