/-
# Combinatorial species as functors, and the exponential generating series bridge

Joyal's *species of structures* are functors from the groupoid of finite sets and
bijections to sets.  This file formalises them concretely as transport-of-structure
data on `Type`, links that description with the categorical one (functors out of
`CategoryTheory.Core Type`), and proves that the *exponential generating series*

    egf F = ∑ₙ |F[n]| Xⁿ / n!

turns the combinatorial operations of sum, product, derivative and pointing of
species into the corresponding algebraic operations on `ℚ⟦X⟧`.
-/
import Mathlib

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries CategoryTheory

/-! ## Species -/

/-- A (finitary) combinatorial species: a family of structure sets indexed by
types, together with transport along bijections satisfying the functoriality
laws.  This is exactly a functor from the groupoid of finite sets to `Type`
(see `Species.toFunctor` / `Species.ofFunctor` below). -/
structure Species where
  /-- The set of `F`-structures on a set `A`. -/
  obj : Type → Type
  /-- Transport of structures along a bijection. -/
  map : {A B : Type} → (A ≃ B) → obj A → obj B
  map_refl : ∀ {A : Type} (x : obj A), map (Equiv.refl A) x = x
  map_trans : ∀ {A B C : Type} (e : A ≃ B) (f : B ≃ C) (x : obj A),
      map f (map e x) = map (e.trans f) x
  finite : ∀ (A : Type) [Finite A], Finite (obj A)

attribute [simp] Species.map_refl

instance instFiniteObj (F : Species) (A : Type) [Finite A] : Finite (F.obj A) := F.finite A

namespace Species

variable (F G : Species)

/-- Transport of structures along a bijection is itself a bijection. -/
def transport {A B : Type} (e : A ≃ B) : F.obj A ≃ F.obj B where
  toFun := F.map e
  invFun := F.map e.symm
  left_inv x := by rw [F.map_trans, Equiv.self_trans_symm, F.map_refl]
  right_inv x := by rw [F.map_trans, Equiv.symm_trans_self, F.map_refl]

/-- The number of `F`-structures on an `n`-element set. -/
def card (n : ℕ) : ℕ := Nat.card (F.obj (Fin n))

/-- **Transport of structure**: the number of `F`-structures on a finite set depends
only on its cardinality. -/
theorem card_obj (A : Type) [Finite A] : Nat.card (F.obj A) = F.card (Nat.card A) :=
  Nat.card_congr (F.transport (Finite.equivFin A))

/-- The exponential generating series of a species. -/
def egf : ℚ⟦X⟧ := PowerSeries.mk fun n => (F.card n : ℚ) / (n).factorial

@[simp] theorem coeff_egf (n : ℕ) : coeff n F.egf = (F.card n : ℚ) / (n).factorial :=
  coeff_mk _ _

/-- The exponential generating series is a complete invariant of the counting
sequence of a species. -/
theorem egf_eq_iff : F.egf = G.egf ↔ ∀ n, F.card n = G.card n := by
  constructor
  · intro h n
    have hn := congrArg (coeff n) h
    rw [coeff_egf, coeff_egf] at hn
    have hfac : (n.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero n)
    field_simp at hn
    exact_mod_cast hn
  · intro h
    ext n
    rw [coeff_egf, coeff_egf, h]

/-! ## The categorical description -/

/-- A species, viewed as a functor from the core groupoid of `Type` to `Type`. -/
def toFunctor : Core Type ⥤ Type where
  obj A := F.obj A.of
  map f := F.map f.iso.toEquiv
  map_id A := by
    funext x
    exact F.map_refl x
  map_comp {A B C} f g := by
    funext x
    exact (F.map_trans f.iso.toEquiv g.iso.toEquiv x).symm

/-- A functor out of the core groupoid of `Type` which takes finite sets to finite
sets is a species. -/
def ofFunctor (Φ : Core Type ⥤ Type) (hfin : ∀ (A : Type) [Finite A], Finite (Φ.obj ⟨A⟩)) :
    Species where
  obj A := Φ.obj ⟨A⟩
  map e := Φ.map ⟨e.toIso⟩
  map_refl x := congrFun (Φ.map_id ⟨_⟩) x
  map_trans e f x := (congrFun (Φ.map_comp (X := ⟨_⟩) (Y := ⟨_⟩) (Z := ⟨_⟩)
      ⟨e.toIso⟩ ⟨f.toIso⟩) x).symm
  finite A _ := hfin A

/-- The two descriptions of a species agree. -/
theorem ofFunctor_toFunctor :
    ofFunctor F.toFunctor (fun A _ => F.finite A) = F := rfl

/-- ... and in the other direction as well: every finitary functor on the core groupoid
of `Type` arises from a unique species. -/
theorem toFunctor_ofFunctor (Φ : Core Type ⥤ Type)
    (hfin : ∀ (A : Type) [Finite A], Finite (Φ.obj ⟨A⟩)) :
    (ofFunctor Φ hfin).toFunctor = Φ := rfl

/-! ## Operations on species -/

/-- The sum of two species: an `F + G`-structure is an `F`-structure or a `G`-structure. -/
def add : Species where
  obj A := F.obj A ⊕ G.obj A
  map e := Sum.map (F.map e) (G.map e)
  map_refl x := by cases x <;> simp
  map_trans e f x := by cases x <;> simp [Sum.map, F.map_trans, G.map_trans]
  finite A _ := inferInstance

/-- The product of two species: an `F * G`-structure on `A` is a splitting of `A`
into two complementary parts, carrying an `F`-structure and a `G`-structure. -/
def mul : Species where
  obj A := Σ p : A → Bool, F.obj {a : A // p a = true} × G.obj {a : A // p a = false}
  map {A B} e x :=
    ⟨fun b => x.1 (e.symm b),
      F.map (e.subtypeEquiv (fun a => by simp)) x.2.1,
      G.map (e.subtypeEquiv (fun a => by simp)) x.2.2⟩
  map_refl := by
    rintro A ⟨p, u, v⟩
    dsimp only
    have h1 : ∀ (h : ∀ a, p a = true ↔ p ((Equiv.refl A).symm a) = true),
        (Equiv.refl A).subtypeEquiv h = Equiv.refl {a : A // p a = true} := by
      intro h; ext a; rfl
    have h2 : ∀ (h : ∀ a, p a = false ↔ p ((Equiv.refl A).symm a) = false),
        (Equiv.refl A).subtypeEquiv h = Equiv.refl {a : A // p a = false} := by
      intro h; ext a; rfl
    rw [h1, h2, F.map_refl, G.map_refl]
    rfl
  map_trans := by
    rintro A B C e f ⟨p, u, v⟩
    dsimp only
    rw [F.map_trans, G.map_trans]
    rfl
  finite A _ := inferInstance

instance : Add Species := ⟨add⟩
instance : Mul Species := ⟨mul⟩

/-- The empty species `0`: no structures at all. -/
def zero : Species where
  obj _ := Empty
  map _ x := x.elim
  map_refl x := x.elim
  map_trans _ _ x := x.elim
  finite _ _ := inferInstance

instance : Zero Species := ⟨zero⟩

/-- The species `1`: there is exactly one structure on the empty set and none elsewhere. -/
def one : Species where
  obj A := PLift (IsEmpty A)
  map e x := ⟨⟨fun b => x.down.elim (e.symm b)⟩⟩
  map_refl _ := Subsingleton.elim _ _
  map_trans _ _ _ := Subsingleton.elim _ _
  finite _ _ := inferInstance

instance : One Species := ⟨one⟩

/-- The singleton species `X`: a structure on `A` is a witness that `A` is a singleton. -/
def sing : Species where
  obj A := {a : A // ∀ b, b = a}
  map e x := ⟨e x.1, fun b => by rw [← e.apply_symm_apply b, x.2 (e.symm b)]⟩
  map_refl x := Subtype.ext rfl
  map_trans e f x := Subtype.ext rfl
  finite A _ := inferInstance

/-- The species `E` of sets: exactly one structure on every finite set. -/
def set : Species where
  obj _ := PUnit
  map _ x := x
  map_refl _ := rfl
  map_trans _ _ _ := rfl
  finite _ _ := inferInstance

/-- The species of permutations. -/
def perm : Species where
  obj A := A ≃ A
  map e s := (e.symm.trans s).trans e
  map_refl x := by ext a; simp
  map_trans e f x := by ext a; simp
  finite A _ := Equiv.finite_left

/-- The derivative of a species: `F'`-structures on `A` are `F`-structures on `A`
together with one extra distinguished "ghost" point. -/
def deriv : Species where
  obj A := F.obj (Option A)
  map e := F.map (Equiv.optionCongr e)
  map_refl := by
    intro A x
    have h : Equiv.optionCongr (Equiv.refl A) = Equiv.refl (Option A) := by
      ext a; cases a <;> rfl
    rw [h, F.map_refl]
  map_trans e f x := by
    rw [F.map_trans]
    congr 1
    ext a; cases a <;> rfl
  finite A _ := inferInstance

/-! ## Cardinalities of the basic species -/

@[simp] theorem card_add (n : ℕ) : (F.add G).card n = F.card n + G.card n := by
  simp [card, add, Nat.card_sum]

@[simp] theorem card_zero_species (n : ℕ) : (zero).card n = 0 := by
  simp [card, zero]

@[simp] theorem card_one_zero : (one).card 0 = 1 := by
  have : Unique (PLift (IsEmpty (Fin 0))) :=
    { default := ⟨inferInstance⟩, uniq := fun _ => Subsingleton.elim _ _ }
  simp [card, one]

@[simp] theorem card_one_succ (n : ℕ) : (one).card (n + 1) = 0 := by
  have : IsEmpty (PLift (IsEmpty (Fin (n + 1)))) :=
    ⟨fun x => (x.down.elim (0 : Fin (n + 1)))⟩
  simp [card, one]

@[simp] theorem card_set (n : ℕ) : set.card n = 1 := by
  simp [card, set]

@[simp] theorem card_sing (n : ℕ) : sing.card n = if n = 1 then 1 else 0 := by
  match n with
  | 0 =>
      have : IsEmpty {a : Fin 0 // ∀ b, b = a} := ⟨fun x => x.1.elim0⟩
      simp [card, sing]
  | 1 =>
      have : Unique {a : Fin 1 // ∀ b, b = a} :=
        { default := ⟨0, fun b => Subsingleton.elim _ _⟩
          uniq := fun _ => Subtype.ext (Subsingleton.elim _ _) }
      simp [card, sing]
  | (n + 2) =>
      have : IsEmpty {a : Fin (n + 2) // ∀ b, b = a} := by
        refine ⟨fun x => ?_⟩
        have h0 := x.2 0
        have h1 := x.2 1
        have h01 : (0 : Fin (n + 2)) = 1 := by rw [h0, h1]
        simp at h01
      simp [card, sing]

@[simp] theorem card_perm (n : ℕ) : perm.card n = n.factorial := by
  simp [card, perm, Nat.card_eq_fintype_card, Fintype.card_equiv (Equiv.refl (Fin n))]

@[simp] theorem card_deriv (n : ℕ) : F.deriv.card n = F.card (n + 1) := by
  have h := F.card_obj (Option (Fin n))
  simpa [card, deriv] using h

/-- Counting the splittings of an `n`-element set: the key combinatorial lemma
behind the product rule. -/
theorem card_bool_fibre (n k : ℕ) :
    Nat.card {p : Fin n → Bool // Nat.card {a // p a = true} = k} = n.choose k := by
  have key : {p : Fin n → Bool // Nat.card {a // p a = true} = k}
      ≃ {s : Finset (Fin n) // s.card = k} :=
    { toFun := fun p => ⟨Finset.univ.filter (fun a => p.1 a = true), by
        have hp := p.2
        rwa [Nat.card_eq_fintype_card, Fintype.card_subtype] at hp⟩
      invFun := fun s => ⟨fun a => decide (a ∈ s.1), by
        rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
        simp [s.2]⟩
      left_inv := by intro p; ext a; simp
      right_inv := by intro s; ext a; simp }
  rw [Nat.card_congr key, Nat.card_eq_fintype_card, Fintype.card_finset_len]
  simp

/-- The `false`-part of a Boolean splitting is the complement of the `true`-part. -/
theorem card_compl_subtype {n : ℕ} (p : Fin n → Bool) :
    Nat.card {a // p a = false} = n - Nat.card {a // p a = true} := by
  classical
  have e : ({a : Fin n // p a = true} ⊕ {a : Fin n // p a = false}) ≃ Fin n :=
    (Equiv.sumCongr (Equiv.refl _)
      (Equiv.subtypeEquivRight (fun a => by simp))).trans
      (Equiv.sumCompl (fun a : Fin n => p a = true))
  have h := Nat.card_congr e
  rw [Nat.card_sum] at h
  simp only [Nat.card_eq_fintype_card, Fintype.card_fin] at h ⊢
  omega

/-- **The product rule for species**, in its combinatorial (binomial convolution) form. -/
theorem card_mul (n : ℕ) :
    (F.mul G).card n = ∑ k ∈ Finset.range (n + 1), n.choose k * F.card k * G.card (n - k) := by
  classical
  have h1 : (F.mul G).card n
      = ∑ p : Fin n → Bool, F.card (Nat.card {a // p a = true})
          * G.card (n - Nat.card {a // p a = true}) := by
    rw [card]
    rw [show (F.mul G).obj (Fin n)
        = Σ p : Fin n → Bool, F.obj {a : Fin n // p a = true} × G.obj {a : Fin n // p a = false}
        from rfl]
    rw [Nat.card_sigma]
    refine Finset.sum_congr rfl fun p _ => ?_
    rw [Nat.card_prod, F.card_obj, G.card_obj, card_compl_subtype p]
  rw [h1]
  set κ : (Fin n → Bool) → ℕ := fun p => Nat.card {a : Fin n // p a = true} with hκ
  have hmaps : ∀ p ∈ (Finset.univ : Finset (Fin n → Bool)), κ p ∈ Finset.range (n + 1) := by
    intro p _
    have : Nat.card {a : Fin n // p a = true} ≤ n := by
      have := Nat.card_le_card_of_injective (α := {a : Fin n // p a = true}) (β := Fin n)
        Subtype.val Subtype.val_injective
      simpa using this
    simp only [Finset.mem_range, hκ]
    omega
  rw [← Finset.sum_fiberwise_of_maps_to hmaps
      (fun p => F.card (κ p) * G.card (n - κ p))]
  refine Finset.sum_congr rfl fun k hk => ?_
  have : ∑ p ∈ Finset.univ.filter (fun p => κ p = k), F.card (κ p) * G.card (n - κ p)
      = (Finset.univ.filter (fun p => κ p = k)).card * (F.card k * G.card (n - k)) := by
    rw [Finset.sum_congr rfl (fun p hp => by
      rw [(Finset.mem_filter.1 hp).2]), Finset.sum_const, smul_eq_mul]
  rw [this]
  have hcard : (Finset.univ.filter (fun p : Fin n → Bool => κ p = k)).card = n.choose k := by
    rw [← card_bool_fibre n k, Nat.card_eq_fintype_card, Fintype.card_subtype]
  rw [hcard, mul_assoc]

/-! ## The bridge: `egf` is a morphism of semirings -/

@[simp] theorem egf_zero_species : (zero : Species).egf = 0 := by
  ext n
  simp

@[simp] theorem egf_one : (one : Species).egf = 1 := by
  ext n
  match n with
  | 0 => simp
  | (n + 1) => simp

@[simp] theorem egf_sing : sing.egf = (PowerSeries.X : ℚ⟦X⟧) := by
  ext n
  rw [coeff_egf, PowerSeries.coeff_X, card_sing]
  match n with
  | 0 => simp
  | 1 => simp
  | (n + 2) => simp

/-- The exponential generating series of the species of sets is `exp`. -/
theorem egf_set : set.egf = PowerSeries.exp ℚ := by
  ext n
  rw [coeff_egf, PowerSeries.coeff_exp, card_set]
  simp

theorem egf_add : (F.add G).egf = F.egf + G.egf := by
  ext n
  rw [map_add, coeff_egf, coeff_egf, coeff_egf, card_add]
  push_cast
  ring

/-- **Main theorem.**  The exponential generating series of a product of species is the
product of their exponential generating series. -/
theorem egf_mul : (F.mul G).egf = F.egf * G.egf := by
  ext n
  rw [PowerSeries.coeff_mul, coeff_egf, card_mul,
    Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  rw [Nat.cast_sum, Finset.sum_div]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
  rw [coeff_egf, coeff_egf]
  have hn : (n.factorial : ℚ) = (n.choose k : ℚ) * k.factorial * (n - k).factorial := by
    exact_mod_cast (Nat.choose_mul_factorial_mul_factorial hk').symm
  have hchoose : (n.choose k : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.choose_pos hk').ne'
  have h1 : (k.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero k)
  have h2 : ((n - k).factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
  push_cast
  rw [hn]
  field_simp

/-- The exponential generating series of the derivative species is the derivative of the
exponential generating series. -/
theorem egf_deriv : F.deriv.egf = d⁄dX ℚ F.egf := by
  ext n
  rw [PowerSeries.coeff_derivative, coeff_egf, coeff_egf, card_deriv]
  rw [Nat.factorial_succ]
  push_cast
  have h : (n.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero n)
  field_simp

/-- The generating series of the species of permutations is `1/(1-X)`. -/
theorem egf_perm : perm.egf * (1 - PowerSeries.X) = 1 := by
  have hcoeff : ∀ n, coeff n perm.egf = 1 := by
    intro n
    rw [coeff_egf, card_perm]
    field_simp
  ext n
  match n with
  | 0 =>
      have h0 := hcoeff 0
      rw [PowerSeries.coeff_zero_eq_constantCoeff] at h0
      simp [h0]
  | (n + 1) =>
      rw [mul_sub, map_sub, mul_one, hcoeff, PowerSeries.coeff_succ_mul_X, hcoeff]
      simp

/-! ## Consequences -/

/-- Pointing: `X · F'`-structures on an `n`-set are `F`-structures with a marked point. -/
theorem card_pointing (n : ℕ) : (sing.mul F.deriv).card n = n * F.card n := by
  rw [card_mul]
  match n with
  | 0 => simp
  | (n + 1) =>
      rw [Finset.sum_eq_single 1]
      · simp [Nat.choose_one_right]
      · intro k _ hk
        simp [card_sing, hk]
      · intro h
        exact absurd (Finset.mem_range.2 (by omega)) h

/-- The species `E · E` of subsets has `2ⁿ` structures, whence the binomial identity
`∑ₖ C(n,k) = 2ⁿ` falls out of the product rule. -/
theorem card_subsets (n : ℕ) : (set.mul set).card n = 2 ^ n := by
  have : (set.mul set).obj (Fin n) = Σ _ : Fin n → Bool, PUnit × PUnit := rfl
  rw [card, this, Nat.card_sigma]
  simp

theorem sum_choose_eq (n : ℕ) : ∑ k ∈ Finset.range (n + 1), n.choose k = 2 ^ n := by
  have := card_mul set set n
  rw [card_subsets] at this
  simpa using this.symm

/-- `exp * exp` read off from the species of subsets. -/
theorem egf_subsets : (set.mul set).egf = PowerSeries.exp ℚ * PowerSeries.exp ℚ := by
  rw [egf_mul, egf_set]

end Species

end SpeciesEGF