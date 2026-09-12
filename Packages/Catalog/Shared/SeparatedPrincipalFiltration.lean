/-
# Separated principal filtrations

This file generalises the elementary fact `⋂ n, (2^n : Ideal ℤ) = 0` to an arbitrary
element `a` of a commutative domain `R`, and isolates hypotheses under which the
principal filtration `n ↦ (aⁿ)` is *separated*, i.e.

  `⨅ n, (aⁿ) = ⊥`.

Two genuinely different sufficient conditions are proved:

* a **chain condition** (`WfDvdMonoid`, which covers all Noetherian domains and all
  UFDs): every non-unit `a` gives a separated filtration — this is the principal-ideal
  case of the Krull intersection theorem, and is *not* a new ascending-chain invariant;
* a **height function** condition: the mere existence of an `ℕ`-valued function `v`
  that strictly increases along multiplication by `a` forces separation.  This
  hypothesis is strictly weaker in the sense that it never mentions any chain
  condition, and it is what makes the classical examples (`ℤ` at `2`, `k[X]` at `X`)
  completely elementary.

We also record the structural calculus of the predicate: it is monotone under
divisibility, stable under powers and products, transfers along injective ring maps,
and — in a `WfDvdMonoid` domain — is *exactly* the failure of `a` to be a unit.

The companion file `SeparatedPrincipalFiltrationCounterexample.lean` shows that some
hypothesis is genuinely needed: in the domain `ℤ + X·ℚ[X]` the element `2` is a
nonzero non-unit whose principal filtration is *not* separated.
-/
import Mathlib

namespace SeparatedPrincipalFiltration

variable {R : Type*} [CommRing R]

/-! ## The filtration and the separation predicate -/

/-- The principal `a`-adic filtration `n ↦ (aⁿ)` of a commutative ring. -/
def filt (a : R) (n : ℕ) : Ideal R := Ideal.span {a ^ n}

@[simp] lemma filt_zero (a : R) : filt a 0 = ⊤ := by
  simp [filt]

lemma filt_eq_pow (a : R) (n : ℕ) : filt a n = Ideal.span {a} ^ n :=
  (Ideal.span_singleton_pow a n).symm

lemma mem_filt {a x : R} {n : ℕ} : x ∈ filt a n ↔ a ^ n ∣ x := Ideal.mem_span_singleton

lemma filt_antitone (a : R) : Antitone (filt a) := by
  intro m n hmn x hx
  rw [mem_filt] at hx ⊢
  exact dvd_trans (pow_dvd_pow a hmn) hx

/-- The principal filtration at `a` is *separated* when `⨅ n, (aⁿ) = ⊥`. -/
def IsSeparated (a : R) : Prop := ⨅ n, filt a n = ⊥

lemma mem_iInf_filt_iff {a x : R} : x ∈ ⨅ n, filt a n ↔ ∀ n, a ^ n ∣ x := by
  simp [Submodule.mem_iInf, mem_filt]

/-- Separation, unwound: the only element divisible by every power of `a` is `0`. -/
lemma isSeparated_iff {a : R} : IsSeparated a ↔ ∀ x : R, (∀ n, a ^ n ∣ x) → x = 0 := by
  constructor
  · intro h x hx
    have : x ∈ ⨅ n, filt a n := mem_iInf_filt_iff.mpr hx
    rw [h] at this
    simpa using this
  · intro h
    refine le_antisymm (fun x hx => ?_) bot_le
    simpa using h x (mem_iInf_filt_iff.mp hx)

lemma IsSeparated.eq_zero {a : R} (h : IsSeparated a) {x : R} (hx : ∀ n, a ^ n ∣ x) :
    x = 0 := isSeparated_iff.mp h x hx

/-! ## Degenerate elements -/

/-- The zero element always has separated filtration (in a nontrivial ring the filtration
drops to `⊥` after the first step). -/
theorem isSeparated_zero : IsSeparated (0 : R) := by
  refine isSeparated_iff.mpr fun x hx => ?_
  simpa using hx 1

/-- A unit never has separated filtration, unless the ring is trivial: the filtration is
constantly `⊤`. -/
theorem iInf_filt_eq_top_of_isUnit {a : R} (ha : IsUnit a) : ⨅ n, filt a n = ⊤ := by
  refine top_le_iff.mp fun x _ => mem_iInf_filt_iff.mpr fun n => ?_
  exact (ha.pow n).dvd

theorem not_isSeparated_of_isUnit [Nontrivial R] {a : R} (ha : IsUnit a) :
    ¬ IsSeparated a := by
  intro h
  have : (1 : R) = 0 := h.eq_zero fun n => (ha.pow n).dvd
  exact one_ne_zero this

/-! ## Criterion I: height functions (no chain condition) -/

/-- If `x ≠ 0` and multiplication by `a` strictly raises the height `v`, then
`v (aⁿ * x) ≥ n + v x`. -/
lemma le_height_pow_mul [IsDomain R] {a : R} (ha : a ≠ 0) (v : R → ℕ)
    (hv : ∀ x : R, x ≠ 0 → v x < v (a * x)) :
    ∀ (n : ℕ) (x : R), x ≠ 0 → n + v x ≤ v (a ^ n * x) := by
  intro n
  induction n with
  | zero => intro x _; simp
  | succ n ih =>
      intro x hx
      have hax : a ^ n * x ≠ 0 := mul_ne_zero (pow_ne_zero _ ha) hx
      have h1 : n + v x ≤ v (a ^ n * x) := ih x hx
      have h2 : v (a ^ n * x) < v (a * (a ^ n * x)) := hv _ hax
      have h3 : a * (a ^ n * x) = a ^ (n + 1) * x := by ring
      rw [h3] at h2
      omega

/-- **Height criterion.**  In a domain, the existence of *any* `ℕ`-valued function that
strictly increases under multiplication by `a` forces the principal `a`-adic filtration
to be separated.  No finiteness or chain hypothesis on `R` is required. -/
theorem isSeparated_of_height [IsDomain R] (a : R) (v : R → ℕ)
    (hv : ∀ x : R, x ≠ 0 → v x < v (a * x)) : IsSeparated a := by
  rcases eq_or_ne a 0 with rfl | ha
  · exact isSeparated_zero
  refine isSeparated_iff.mpr fun x hx => ?_
  by_contra hx0
  obtain ⟨y, hy⟩ := hx (v x + 1)
  have hy0 : y ≠ 0 := by
    rintro rfl; exact hx0 (by simpa using hy)
  have := le_height_pow_mul ha v hv (v x + 1) y hy0
  rw [← hy] at this
  omega

/-! ## Criterion II: chain conditions (Krull intersection, principal case) -/

/-- Separation is exactly the statement that every nonzero element has finite
`a`-multiplicity. -/
theorem isSeparated_iff_finiteMultiplicity {a : R} :
    IsSeparated a ↔ ∀ x : R, x ≠ 0 → FiniteMultiplicity a x := by
  rw [isSeparated_iff]
  constructor
  · intro h x hx
    by_contra hfin
    exact hx (h x (FiniteMultiplicity.not_iff_forall.mp hfin))
  · intro h x hx
    by_contra hx0
    exact (FiniteMultiplicity.not_iff_forall.mpr hx) (h x hx0)

/-- **Krull separation for principal filtrations.**  In a domain satisfying the
well-founded divisibility condition (in particular any Noetherian domain and any UFD),
the principal filtration at a non-unit is separated. -/
theorem isSeparated_of_not_isUnit [IsDomain R] [WfDvdMonoid R] {a : R} (ha : ¬ IsUnit a) :
    IsSeparated a :=
  isSeparated_iff_finiteMultiplicity.mpr fun _ hx => FiniteMultiplicity.of_not_isUnit ha hx

/-- **Trichotomy-free characterisation.**  In a nontrivial domain with well-founded
divisibility, separation of the principal filtration at `a` is *equivalent* to `a` not
being a unit. -/
theorem isSeparated_iff_not_isUnit [Nontrivial R] [IsDomain R] [WfDvdMonoid R] {a : R} :
    IsSeparated a ↔ ¬ IsUnit a :=
  ⟨fun h hu => not_isSeparated_of_isUnit hu h, isSeparated_of_not_isUnit⟩

/-- Noetherian specialisation (the classical Krull intersection theorem in the principal
case). -/
theorem isSeparated_of_isNoetherian [IsDomain R] [IsNoetherianRing R] {a : R}
    (ha : ¬ IsUnit a) : IsSeparated a :=
  isSeparated_of_not_isUnit ha

/-- Unique-factorisation specialisation.  Note that UFDs need not be Noetherian, so this
is not covered by the previous statement. -/
theorem isSeparated_of_uniqueFactorization [IsDomain R] [UniqueFactorizationMonoid R]
    {a : R} (ha : ¬ IsUnit a) : IsSeparated a :=
  isSeparated_of_not_isUnit ha

/-- Reformulation as vanishing of the intersection of the ideal powers, i.e. the form in
which the Krull intersection theorem is usually stated. -/
theorem iInf_span_pow_eq_bot [IsDomain R] [WfDvdMonoid R] {a : R} (ha : ¬ IsUnit a) :
    ⨅ n, (Ideal.span {a}) ^ n = ⊥ := by
  have := isSeparated_of_not_isUnit ha
  simpa [IsSeparated, filt_eq_pow] using this

/-! ## The converse: separation manufactures its own height function

The two criteria above are not independent: in a domain, separation of the principal
filtration at `a` is *equivalent* to the existence of an `ℕ`-valued height function, the
canonical choice being the `a`-adic order `multiplicity a ·`. -/

/-- In a domain, multiplying by a nonzero `a` raises the `a`-adic order by exactly one.
The upper bound is the nontrivial half and uses cancellation. -/
theorem multiplicity_mul_self [IsDomain R] {a : R} (ha : a ≠ 0) {x : R}
    (hfin : FiniteMultiplicity a x) (hfin' : FiniteMultiplicity a (a * x)) :
    multiplicity a (a * x) = multiplicity a x + 1 := by
  refine hfin'.multiplicity_eq_iff.mpr ⟨?_, ?_⟩
  · obtain ⟨c, hc⟩ := hfin.pow_dvd_iff_le_multiplicity.mpr le_rfl
    refine ⟨c, ?_⟩
    calc a * x = a * (a ^ multiplicity a x * c) := by rw [← hc]
      _ = a ^ (multiplicity a x + 1) * c := by ring
  · rintro ⟨c, hc⟩
    have hx : x = a ^ (multiplicity a x + 1) * c := by
      apply mul_left_cancel₀ ha
      rw [hc]; ring
    have : multiplicity a x + 1 ≤ multiplicity a x :=
      hfin.le_multiplicity_of_pow_dvd ⟨c, hx⟩
    omega

/-- **Separation is exactly the existence of a height function.**  Combining the two
criteria: over a domain the (chain-condition-free) height criterion is not merely
sufficient, it is necessary. -/
theorem isSeparated_iff_exists_height [IsDomain R] {a : R} :
    IsSeparated a ↔ ∃ v : R → ℕ, ∀ x : R, x ≠ 0 → v x < v (a * x) := by
  constructor
  · intro h
    rcases eq_or_ne a 0 with rfl | ha
    · classical
      refine ⟨fun x => if x = 0 then 1 else 0, fun x hx => ?_⟩
      show (if x = 0 then 1 else 0) < (if (0 : R) * x = 0 then 1 else 0)
      simp [hx]
    refine ⟨fun x => multiplicity a x, fun x hx => ?_⟩
    have hfin : FiniteMultiplicity a x := isSeparated_iff_finiteMultiplicity.mp h x hx
    have hfin' : FiniteMultiplicity a (a * x) :=
      isSeparated_iff_finiteMultiplicity.mp h _ (mul_ne_zero ha hx)
    show multiplicity a x < multiplicity a (a * x)
    rw [multiplicity_mul_self ha hfin hfin']
    omega
  · rintro ⟨v, hv⟩
    exact isSeparated_of_height a v hv

/-! ## Structural calculus of separated elements -/

/-- Separation propagates upward along divisibility: if `a ∣ b` and `a` is separated,
so is `b`. -/
theorem IsSeparated.of_dvd {a b : R} (h : IsSeparated a) (hab : a ∣ b) : IsSeparated b := by
  refine isSeparated_iff.mpr fun x hx => ?_
  exact h.eq_zero fun n => dvd_trans (pow_dvd_pow_of_dvd hab n) (hx n)

/-- Separation is stable under taking positive powers. -/
theorem IsSeparated.pow {a : R} (h : IsSeparated a) {k : ℕ} (hk : k ≠ 0) :
    IsSeparated (a ^ k) :=
  h.of_dvd (dvd_pow_self a hk)

/-- Separation is stable under multiplying by an arbitrary element. -/
theorem IsSeparated.mul_right {a : R} (h : IsSeparated a) (b : R) : IsSeparated (a * b) :=
  h.of_dvd ⟨b, rfl⟩

/-- Separation is invariant under multiplication by a unit. -/
theorem isSeparated_mul_unit_iff {a u : R} (hu : IsUnit u) :
    IsSeparated (a * u) ↔ IsSeparated a := by
  obtain ⟨v, hv⟩ := hu.exists_right_inv
  refine ⟨fun h => h.of_dvd ⟨v, by rw [mul_assoc, hv, mul_one]⟩, fun h => h.mul_right u⟩

/-- Separation descends along an injective ring homomorphism: if the image of `a` has a
separated filtration downstream, so does `a`. -/
theorem isSeparated_of_injective {S : Type*} [CommRing S] (f : R →+* S)
    (hf : Function.Injective f) {a : R} (h : IsSeparated (f a)) : IsSeparated a := by
  refine isSeparated_iff.mpr fun x hx => ?_
  have : f x = 0 := h.eq_zero fun n => by
    obtain ⟨y, hy⟩ := hx n
    exact ⟨f y, by rw [hy]; push_cast [map_mul, map_pow]; ring⟩
  simpa using hf (by simpa using this)

/-- Separation for a subring element, read off from the ambient ring. -/
theorem isSeparated_subring {S : Subring R} {a : S} (h : IsSeparated (a : R)) :
    IsSeparated a :=
  isSeparated_of_injective S.subtype Subtype.val_injective h

/-! ## Classical instances, proved by the elementary height criterion -/

/-- `⋂ n, (2ⁿ) = 0` in `ℤ`, proved with the height function `|·|` — this is the
statement the whole file generalises. -/
theorem int_two_isSeparated : IsSeparated (2 : ℤ) := by
  refine isSeparated_of_height 2 (fun x => x.natAbs) fun x hx => ?_
  show x.natAbs < (2 * x).natAbs
  have h1 : (1 : ℕ) ≤ x.natAbs := Int.natAbs_pos.mpr hx
  have h2 : (2 * x).natAbs = 2 * x.natAbs := by
    simpa using Int.natAbs_mul 2 x
  omega

/-- More generally every integer of absolute value at least `2` is separated. -/
theorem int_isSeparated_of_two_le {a : ℤ} (ha : 2 ≤ a.natAbs) : IsSeparated a := by
  refine isSeparated_of_height a (fun x => x.natAbs) fun x hx => ?_
  show x.natAbs < (a * x).natAbs
  have h1 : (1 : ℕ) ≤ x.natAbs := Int.natAbs_pos.mpr hx
  have h2 : (a * x).natAbs = a.natAbs * x.natAbs := Int.natAbs_mul a x
  nlinarith [h2]

/-- In a polynomial ring over a domain, `X` has separated filtration, via the degree
height function. -/
theorem polynomial_X_isSeparated {k : Type*} [CommRing k] [IsDomain k] :
    IsSeparated (Polynomial.X : Polynomial k) := by
  refine isSeparated_of_height Polynomial.X (fun p => p.natDegree) fun p hp => ?_
  show p.natDegree < (Polynomial.X * p).natDegree
  rw [Polynomial.natDegree_mul Polynomial.X_ne_zero hp, Polynomial.natDegree_X]
  omega

end SeparatedPrincipalFiltration