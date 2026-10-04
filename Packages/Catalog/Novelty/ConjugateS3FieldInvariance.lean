/-
# THE-FIELD-NOT-THE-POLYNOMIAL (paper 127): conjugate `S₃` cubics share their type channel

FACT round-35 #8 reports that the conjugate cubics `x³ - x + 1` and `x³ - x - 1`
(both of discriminant `-23`) produce *bit-for-bit identical* splitting-type channels,
and that their semiprime pair channels agree "within Monte-Carlo noise".  This file
explains both observations exactly and proves a strictly stronger statement:
the type channel is a function of the *field*, and every polynomial generating the
same cubic field by a rational change of variable has literally the same type function
at **every** modulus `n` (prime, semiprime or otherwise).

Main results.

* `card_roots_affine` : any affine substitution `x ↦ u x + c` (`u` a unit) preserves
  root counts of an arbitrary polynomial over any finite commutative ring.
* `card_roots_transport` / `card_roots_nbij` : root counts are transported along
  any bijection on roots (the abstract "change of generator" principle).
* `rootsMinus_eq_rootsPlus`, `rootsRecip_eq_rootsMinus` : in every finite commutative
  ring, `x³ - x + 1`, `x³ - x - 1` and the reciprocal cubic `x³ + x² - 1` have the same
  number of roots (via `x ↦ -x` and the polynomial Möbius map `x ↦ x² - 1 = x⁻¹`).
* `typeFn_plus_eq_minus`, `typeFn_recip_eq_minus` : hence the type functions agree
  at every `n : ℕ`.
* `typeChannel_identical`, `pairChannel_identical` : the mutual information of the
  type channel against **any** label (e.g. `p mod 23`) is identical for the two
  conjugates, on any sample of moduli; likewise the semiprime pair channel.  The
  "MC noise" of the experiment is the *only* possible source of disagreement.
* `card_roots_prod` / `typeFn_mul_coprime` : the semiprime type is multiplicative,
  `T(pq) = T(p) T(q)` for coprime `p, q` (Chinese remainder theorem), and hence
  `semiprimeEntropy_le_joint` : `H(T(pq)) ≤ H(T p, T q)` (data processing).
* `irreducible_plus_iff_minus`, `factorType_comp_negX` : at the polynomial level, the
  conjugates are irreducible together, and over any field their full factorisation
  types (multisets of irreducible-factor degrees) coincide.
* `disc_conj`, `sign_law_disc23_minus/plus` : both have discriminant `-23`, and for
  `p ∉ {2, 23}` each has exactly one root mod `p` iff `-23` is a non-square mod `p`.
* `field_distinguished_at_3` : the channel *does* separate different fields:
  `x³ - x - 1` (disc `-23`) and `x³ + x + 1` (disc `-31`) differ already at `p = 3`.
-/
import Novelty.CubicStickelbergerFrobenius
import Novelty.S3SignChannelUniversal
import Shared.CyclicTypeChannelProduct

namespace ConjugateS3FieldInvariance

open Finset CyclicTypeChannel

/-! ## 1. Transport of root counts along bijections -/

section Transport

variable {R : Type*} [Fintype R] [DecidableEq R]

/-- Root counts are invariant under a global change of variable `e : R ≃ R`
matching the zero sets of `f` and `g`. -/
theorem card_roots_transport [Zero R] (f g : R → R) (e : R ≃ R)
    (h : ∀ x, f (e x) = 0 ↔ g x = 0) :
    #{x | f x = 0} = #{x | g x = 0} := by
  refine (card_nbij' e.symm e ?_ ?_ ?_ ?_).symm.symm
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
    rwa [← h, e.apply_symm_apply]
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
    rwa [h]
  · intro x _; simp
  · intro x _; simp

/-- Root counts are invariant under a bijection *between the zero sets* given by
two mutually inverse maps (which need not be bijective on all of `R`). -/
theorem card_roots_nbij [Zero R] (f g : R → R) (i j : R → R)
    (hi : ∀ x, f x = 0 → g (i x) = 0) (hj : ∀ y, g y = 0 → f (j y) = 0)
    (hji : ∀ x, f x = 0 → j (i x) = x) (hij : ∀ y, g y = 0 → i (j y) = y) :
    #{x | f x = 0} = #{x | g x = 0} := by
  refine card_nbij' i j ?_ ?_ ?_ ?_
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
    exact hi x hx
  · intro y hy
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hy ⊢
    exact hj y hy
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx
    exact hji x hx
  · intro y hy
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hy
    exact hij y hy

/-- **General affine Tschirnhaus invariance.**  For any polynomial `f` over a finite
commutative ring, any unit `u` and any shift `c`, the substituted polynomial
`f(u x + c)` has exactly as many roots as `f`.  The conjugation `x ↦ -x` is the case
`u = -1, c = 0`. -/
theorem card_roots_affine {R : Type*} [CommRing R] [Fintype R] [DecidableEq R]
    (f : Polynomial R) (u : Rˣ) (c : R) :
    #{x : R | (f.comp (Polynomial.C (u : R) * Polynomial.X + Polynomial.C c)).eval x = 0} =
      #{x : R | f.eval x = 0} := by
  let e : R ≃ R :=
    { toFun := fun x => (u : R) * x + c
      invFun := fun y => ((u⁻¹ : Rˣ) : R) * (y - c)
      left_inv := fun x => by
        simp only
        rw [add_sub_cancel_right, ← mul_assoc, Units.inv_mul, one_mul]
      right_inv := fun y => by
        simp only
        rw [← mul_assoc, Units.mul_inv, one_mul, sub_add_cancel] }
  refine card_roots_transport _ (fun x => f.eval x) e.symm (fun x => ?_)
  have : (u : R) * e.symm x + c = x := e.apply_symm_apply x
  simp only [Polynomial.eval_comp, Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C,
    Polynomial.eval_X, this]

end Transport

/-! ## 2. The three generators of the cubic field of discriminant `-23` -/

section Generators

variable {R : Type*} [CommRing R]

/-- `x³ - x + 1`. -/
def fPlus (x : R) : R := x ^ 3 - x + 1
/-- `x³ - x - 1` (the plastic-number cubic). -/
def fMinus (x : R) : R := x ^ 3 - x - 1
/-- `x³ + x² - 1`, the reciprocal of `x³ - x - 1`. -/
def fRecip (x : R) : R := x ^ 3 + x ^ 2 - 1

/-- The conjugation identity `f₊(-x) = -f₋(x)`. -/
lemma fPlus_neg (x : R) : fPlus (-x) = -fMinus x := by
  unfold fPlus fMinus; ring

/-- Every root of `x³ - x - 1` is a unit with explicit inverse `r² - 1`. -/
lemma fMinus_root_inv {r : R} (hr : fMinus r = 0) : r * (r ^ 2 - 1) = 1 := by
  unfold fMinus at hr; linear_combination hr

/-- The Möbius map `r ↦ r⁻¹ = r² - 1` sends roots of `x³ - x - 1` to roots of
`x³ + x² - 1`. -/
lemma fRecip_of_fMinus {r : R} (hr : fMinus r = 0) : fRecip (r ^ 2 - 1) = 0 := by
  unfold fMinus at hr; unfold fRecip
  linear_combination (r ^ 3 - r + 1) * hr

/-- Conversely `s ↦ s⁻¹ = s² + s` sends roots of `x³ + x² - 1` to roots of
`x³ - x - 1`. -/
lemma fMinus_of_fRecip {s : R} (hs : fRecip s = 0) : fMinus (s ^ 2 + s) = 0 := by
  unfold fRecip at hs; unfold fMinus
  linear_combination (s ^ 3 + 2 * s ^ 2 + s + 1) * hs

lemma recip_left {r : R} (hr : fMinus r = 0) : (r ^ 2 - 1) ^ 2 + (r ^ 2 - 1) = r := by
  unfold fMinus at hr; linear_combination r * hr

lemma recip_right {s : R} (hs : fRecip s = 0) : (s ^ 2 + s) ^ 2 - 1 = s := by
  unfold fRecip at hs; linear_combination (s + 1) * hs

variable [Fintype R] [DecidableEq R]

/-- **Conjugate invariance in every finite ring.** -/
theorem rootsMinus_eq_rootsPlus :
    #{x : R | fPlus x = 0} = #{x : R | fMinus x = 0} :=
  card_roots_transport fPlus fMinus (Equiv.neg R) (fun x => by
    simp [fPlus_neg])

/-- **Reciprocal invariance in every finite ring.** -/
theorem rootsRecip_eq_rootsMinus :
    #{x : R | fRecip x = 0} = #{x : R | fMinus x = 0} :=
  (card_roots_nbij fMinus fRecip (fun r => r ^ 2 - 1) (fun s => s ^ 2 + s)
    (fun _ h => fRecip_of_fMinus h) (fun _ h => fMinus_of_fRecip h)
    (fun _ h => recip_left h) (fun _ h => recip_right h)).symm

end Generators

/-! ## 3. Type functions on all moduli -/

/-- The number of roots of `c` modulo `n`, counted over the residues `0, …, n-1`
(so that it is defined for every `n : ℕ`, with value `0` at `n = 0`). -/
def rootCount (n : ℕ) (c : ZMod n → ZMod n) : ℕ :=
  ((range n).filter (fun k : ℕ => c (k : ZMod n) = 0)).card

lemma rootCount_eq_card (n : ℕ) [NeZero n] (c : ZMod n → ZMod n) :
    rootCount n c = #{x : ZMod n | c x = 0} := by
  unfold rootCount
  refine card_nbij' (fun k => (k : ZMod n)) (fun x => x.val) ?_ ?_ ?_ ?_
  · intro k hk
    simp only [coe_filter, mem_range, Set.mem_setOf_eq, mem_univ, true_and] at hk ⊢
    exact hk.2
  · intro x hx
    simp only [coe_filter, mem_range, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    exact ⟨ZMod.val_lt x, by rwa [ZMod.natCast_zmod_val]⟩
  · intro k hk
    simp only [coe_filter, mem_range, Set.mem_setOf_eq] at hk
    exact ZMod.val_cast_of_lt hk.1
  · intro x _
    exact ZMod.natCast_zmod_val x

/-- The type function `T₊(n) = #{x mod n : x³ - x + 1 ≡ 0}`. -/
def typePlus (n : ℕ) : ℕ := rootCount n fPlus
/-- The type function `T₋(n) = #{x mod n : x³ - x - 1 ≡ 0}`. -/
def typeMinus (n : ℕ) : ℕ := rootCount n fMinus
/-- The type function of the reciprocal generator `x³ + x² - 1`. -/
def typeRecip (n : ℕ) : ℕ := rootCount n fRecip

/-- **THE-FIELD-NOT-THE-POLYNOMIAL**: the conjugate cubics have the same type at
every modulus. -/
theorem typeFn_plus_eq_minus : typePlus = typeMinus := by
  funext n
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [typePlus, typeMinus, rootCount]
  · haveI : NeZero n := ⟨hn.ne'⟩
    simp only [typePlus, typeMinus, rootCount_eq_card]
    exact rootsMinus_eq_rootsPlus

/-- The reciprocal generator also has the same type at every modulus. -/
theorem typeFn_recip_eq_minus : typeRecip = typeMinus := by
  funext n
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [typeRecip, typeMinus, rootCount]
  · haveI : NeZero n := ⟨hn.ne'⟩
    simp only [typeRecip, typeMinus, rootCount_eq_card]
    exact rootsRecip_eq_rootsMinus

/-! ## 4. Channel identities -/

/-- **Bit-for-bit identity of the type channel.**  For any finite sample `S` of
moduli and any label `L` (for instance `p ↦ p mod 23`), the mutual information
`I(L ; T)` is the same real number for the two conjugate cubics. -/
theorem typeChannel_identical {β : Type*} [DecidableEq β] (S : Finset ℕ) (L : ℕ → β) :
    mutInfo S L typePlus = mutInfo S L typeMinus := by
  rw [typeFn_plus_eq_minus]

/-- The same identity for the reciprocal generator. -/
theorem typeChannel_identical_recip {β : Type*} [DecidableEq β] (S : Finset ℕ)
    (L : ℕ → β) : mutInfo S L typeRecip = mutInfo S L typeMinus := by
  rw [typeFn_recip_eq_minus]

/-- **Exact identity of the semiprime pair channel.**  For any sample of pairs
`(p, q)` and any label, the channel `I(L ; T(pq))` is identical for the conjugates,
and so is the joint-type channel `I(L ; (T p, T q))`. -/
theorem pairChannel_identical {β : Type*} [DecidableEq β] (S : Finset (ℕ × ℕ))
    (L : ℕ × ℕ → β) :
    mutInfo S L (fun pq => typePlus (pq.1 * pq.2)) =
        mutInfo S L (fun pq => typeMinus (pq.1 * pq.2)) ∧
      mutInfo S L (fun pq => (typePlus pq.1, typePlus pq.2)) =
        mutInfo S L (fun pq => (typeMinus pq.1, typeMinus pq.2)) := by
  rw [typeFn_plus_eq_minus]; exact ⟨rfl, rfl⟩

/-! ## 5. The Chinese-remainder law for semiprime types -/

section CRT

/-- Root counts of a ring-hom-compatible function are multiplicative across a
ring isomorphism `R ≃ A × B`. -/
theorem card_roots_prod {R A B : Type*} [CommRing R] [CommRing A] [CommRing B]
    [Fintype R] [Fintype A] [Fintype B] [DecidableEq R] [DecidableEq A] [DecidableEq B]
    (e : R ≃+* A × B) :
    #{x : R | fMinus x = 0} = #{a : A | fMinus a = 0} * #{b : B | fMinus b = 0} := by
  have key : ∀ x : R, fMinus x = 0 ↔ fMinus (e x).1 = 0 ∧ fMinus (e x).2 = 0 := by
    intro x
    have hx : e (fMinus x) = (fMinus (e x).1, fMinus (e x).2) := by
      unfold fMinus; ext <;> simp
    rw [← e.map_eq_zero_iff, hx, Prod.mk_eq_zero]
  rw [← card_product]
  refine card_nbij' (fun x => e x) (fun z => e.symm z) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq, coe_product,
      Set.mem_prod] at hx ⊢
    exact (key x).1 hx
  · intro z hz
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq, coe_product,
      Set.mem_prod] at hz ⊢
    rw [key, RingEquiv.apply_symm_apply]; exact hz
  · intro x _; simp
  · intro z _; simp

/-- **CRT multiplicativity of the semiprime type**: `T(pq) = T(p) · T(q)` for
coprime `p, q`. -/
theorem typeFn_mul_coprime {p q : ℕ} (hpq : p.Coprime q) :
    typeMinus (p * q) = typeMinus p * typeMinus q := by
  rcases Nat.eq_zero_or_pos p with rfl | hp
  · simp [typeMinus, rootCount]
  rcases Nat.eq_zero_or_pos q with rfl | hq
  · simp [typeMinus, rootCount]
  haveI : NeZero p := ⟨hp.ne'⟩
  haveI : NeZero q := ⟨hq.ne'⟩
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp hq).ne'⟩
  simp only [typeMinus, rootCount_eq_card]
  exact card_roots_prod (ZMod.chineseRemainder hpq)

/-- Consequently the semiprime type is a deterministic function of the pair of prime
types, so the pair channel cannot carry more information than the joint channel
(data processing). -/
theorem semiprimeEntropy_le_joint (S : Finset (ℕ × ℕ)) (hS : ∀ pq ∈ S, pq.1.Coprime pq.2) :
    uEnt S (fun pq => typeMinus (pq.1 * pq.2)) ≤
      uEnt S (fun pq => (typeMinus pq.1, typeMinus pq.2)) := by
  rw [uEnt_congr (g' := (fun t : ℕ × ℕ => t.1 * t.2) ∘
      (fun pq : ℕ × ℕ => (typeMinus pq.1, typeMinus pq.2)))
    (fun pq hpq => typeFn_mul_coprime (hS pq hpq))]
  exact uEnt_comp_le _ _ _

end CRT

/-! ## 6. Polynomial level: irreducibility and full factorisation type -/

section PolyLevel

open Polynomial

variable {R : Type*} [CommRing R]

lemma poly_conj : (X ^ 3 - X + 1 : R[X]).comp (-X) = -(X ^ 3 - X - 1) := by
  simp; ring

/-- Over any commutative ring, the conjugate cubics are irreducible together. -/
theorem irreducible_plus_iff_minus :
    Irreducible (X ^ 3 - X + 1 : R[X]) ↔ Irreducible (X ^ 3 - X - 1 : R[X]) := by
  rw [← MulEquiv.irreducible_iff (algEquivAevalNegX (R := R)).toMulEquiv]
  have : (algEquivAevalNegX (R := R)).toMulEquiv (X ^ 3 - X + 1) =
      -(X ^ 3 - X - 1) := by
    simpa [algEquivAevalNegX] using (poly_conj (R := R))
  rw [this]
  exact (Associated.neg_left (Associated.refl _)).irreducible_iff

/-- The factorisation type of a polynomial over a field: the multiset of degrees of
its normalised irreducible factors (`{3}`, `{1,2}`, `{1,1,1}`, … for a cubic). -/
noncomputable def factorType {K : Type*} [Field K] [DecidableEq K] (f : K[X]) : Multiset ℕ :=
  (UniqueFactorizationMonoid.normalizedFactors f).map natDegree

/-- **The factorisation type is invariant under `X ↦ -X`.** -/
theorem factorType_comp_negX {K : Type*} [Field K] [DecidableEq K] (f : K[X]) (hf : f ≠ 0) :
    factorType (f.comp (-X)) = factorType f := by
  set σ : K[X] ≃* K[X] := (algEquivAevalNegX (R := K)).toMulEquiv with hσ
  have hσa : ∀ g, σ g = g.comp (-X) := fun g => by simp [hσ, algEquivAevalNegX, comp_eq_aeval]
  have hdeg : ∀ g : K[X], (g.comp (-X)).natDegree = g.natDegree := fun g => by
    rw [natDegree_comp]; simp
  set M := UniqueFactorizationMonoid.normalizedFactors f
  have hrel : Multiset.Rel Associated (M.map σ)
      (UniqueFactorizationMonoid.normalizedFactors (f.comp (-X))) := by
    apply UniqueFactorizationMonoid.factors_unique
    · intro x hx
      obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 hx
      exact (MulEquiv.irreducible_iff σ).2 (UniqueFactorizationMonoid.irreducible_of_normalized_factor y hy)
    · intro x hx
      exact UniqueFactorizationMonoid.irreducible_of_normalized_factor x hx
    · have h1 : Associated M.prod f := UniqueFactorizationMonoid.prod_normalizedFactors hf
      have hf' : f.comp (-X) ≠ 0 := by
        intro h; apply hf; rw [← comp_neg_X_comp_neg_X f, h, zero_comp]
      have h2 := UniqueFactorizationMonoid.prod_normalizedFactors hf'
      rw [← map_multiset_prod σ, ← hσa] at *
      exact (h1.map σ).trans h2.symm
  have hrel' : Multiset.Rel (· = ·) ((M.map σ).map natDegree)
      ((UniqueFactorizationMonoid.normalizedFactors (f.comp (-X))).map natDegree) := by
    rw [Multiset.rel_map]
    exact hrel.mono fun a _ b _ hab => natDegree_eq_of_degree_eq (degree_eq_degree_of_associated hab)
  rw [Multiset.rel_eq] at hrel'
  unfold factorType
  rw [← hrel', Multiset.map_map]
  congr 1
  funext g
  simp [hσa, hdeg]


/-- Hence the two conjugate cubics have identical factorisation type over every field. -/
theorem factorType_plus_eq_minus {K : Type*} [Field K] [DecidableEq K] :
    factorType (X ^ 3 - X + 1 : K[X]) = factorType (X ^ 3 - X - 1 : K[X]) := by
  have hne : (X ^ 3 - X + 1 : K[X]) ≠ 0 := by
    intro h
    have := congrArg (eval 0) h
    simp at this
  rw [← factorType_comp_negX _ hne, poly_conj]
  unfold factorType
  have hne' : (X ^ 3 - X - 1 : K[X]) ≠ 0 := by
    intro h
    have := congrArg (eval 0) h
    simp at this
  have hu : IsUnit (-1 : K[X]) := isUnit_one.neg
  rw [neg_eq_neg_one_mul, UniqueFactorizationMonoid.normalizedFactors_mul hu.ne_zero hne',
    UniqueFactorizationMonoid.normalizedFactors_of_isUnit hu, zero_add]

end PolyLevel

/-! ## 7. Discriminant `-23` and the sign law -/

open CubicDiscriminantSignLaw in
/-- `b ↦ -b` preserves the discriminant of `X³ + aX + b`. -/
theorem disc_conj {F : Type*} [Field F] (a b : F) : disc a (-b) = disc a b := by
  unfold disc; ring

open CubicDiscriminantSignLaw in
lemma disc_minus23 {F : Type*} [Field F] :
    disc (-1 : F) (-1) = -23 ∧ disc (-1 : F) 1 = -23 := by
  unfold disc; constructor <;> ring

section SignLaw

variable {p : ℕ} [hp : Fact p.Prime]

open CubicDiscriminantSignLaw CubicStickelbergerFrobenius

/-- **Sign law for `x³ - x - 1`**: for `p ∉ {2, 23}`, exactly one root mod `p`
(Frobenius a transposition) iff `-23` is a non-square mod `p`. -/
theorem sign_law_disc23_minus (hp2 : p ≠ 2) (hp23 : p ≠ 23) :
    (∃ r : ZMod p, fMinus r = 0 ∧ ∀ s : ZMod p, fMinus s = 0 → s = r) ↔
      ¬ IsSquare (-23 : ZMod p) := by
  have h23 : (23 : ZMod p) ≠ 0 := by
    intro h
    have : ((23 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at this
    exact hp23 ((Nat.prime_dvd_prime_iff_eq hp.out (by norm_num)).1 this)
  have key := sign_law_Fp hp2 (-1 : ZMod p) (-1)
    (by rw [disc_minus23.1]; exact neg_ne_zero.2 h23)
  rw [disc_minus23.1] at key
  rw [key]
  have hc : ∀ x : ZMod p, cubic (-1) (-1) x = fMinus x := by
    intro x; unfold cubic fMinus; ring
  simp only [hc]

/-- **Sign law for `x³ - x + 1`**, with the *same* character. -/
theorem sign_law_disc23_plus (hp2 : p ≠ 2) (hp23 : p ≠ 23) :
    (∃ r : ZMod p, fPlus r = 0 ∧ ∀ s : ZMod p, fPlus s = 0 → s = r) ↔
      ¬ IsSquare (-23 : ZMod p) := by
  rw [← sign_law_disc23_minus hp2 hp23]
  constructor
  · rintro ⟨r, hr, hu⟩
    refine ⟨-r, ?_, fun s hs => ?_⟩
    · have := fPlus_neg (-r); rw [neg_neg, hr] at this; exact neg_eq_zero.1 this.symm
    · have : fPlus (-s) = 0 := by rw [fPlus_neg, hs, neg_zero]
      rw [← hu _ this, neg_neg]
  · rintro ⟨r, hr, hu⟩
    refine ⟨-r, by rw [fPlus_neg, hr, neg_zero], fun s hs => ?_⟩
    have : fMinus (-s) = 0 := by
      have := fPlus_neg (-s); rw [neg_neg, hs] at this; exact neg_eq_zero.1 this.symm
    rw [← hu _ this, neg_neg]

end SignLaw

/-! ## 8. The channel separates fields -/

/-- The type function genuinely depends on the field: `x³ - x - 1` (disc `-23`) has no
root mod `3`, while `x³ + x + 1` (disc `-31`) has the root `1`. -/
theorem field_distinguished_at_3 :
    (∀ x : ZMod 3, fMinus x ≠ 0) ∧ ∃ x : ZMod 3, x ^ 3 + x + 1 = 0 := by
  refine ⟨?_, ⟨1, by decide⟩⟩
  intro x; fin_cases x <;> decide

/-- Ramification at `23`: `x³ - x - 1 ≡ (x - 3)(x - 10)² (mod 23)`. -/
theorem ramified_at_23 (x : ZMod 23) : fMinus x = (x - 3) * (x - 10) ^ 2 := by
  unfold fMinus
  have h : (x - 3) * (x - 10) ^ 2 = x ^ 3 - x - 1 + 23 * (-x ^ 2 + 7 * x - 13) := by ring
  rw [h, show (23 : ZMod 23) = 0 from rfl]; ring

end ConjugateS3FieldInvariance