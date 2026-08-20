import Catalog.NumberTheory.Basic

/-!
# Factorisation theory of the Möbius integers

This file tests the conjectures of the Möbius-arithmetic programme:

* **Class number one** (`Mobius.MInt.classGroup_subsingleton`): confirmed.
  `Z̃` is a principal ideal domain, so its class group is trivial.
* **Oriented primes double-cover the rational primes**
  (`Mobius.MInt.orientedPrimes_eq`, `Mobius.MInt.primes_over_card`): confirmed
  *at the level of elements*.  For every rational prime `p` there are exactly
  two prime elements of `Z̃` of norm `p`, namely `p⁺` and `p⁻ = -p⁺`.
* **The prime *spectrum* is a double cover** (`Mobius.MInt.span_pos_eq_span_neg`,
  `Mobius.MInt.primeSpectrum_pos_eq_neg`, `Mobius.MInt.specEquivZ`): **refuted**.
  The two oriented primes generate the *same* prime ideal, and the natural
  comparison map `Spec Z̃ → Spec ℤ` is an order isomorphism, not a two-to-one
  covering.  The doubling lives on elements (a `ℤ/2`-torsor of orientations),
  not on points of the spectrum.
* **`6` has two distinct factorisations** (`Mobius.MInt.six_factorizations`):
  confirmed as *ordered pairs of oriented primes* — there are exactly four,
  `(2⁺,3⁺), (3⁺,2⁺), (2⁻,3⁻), (3⁻,2⁻)` — but refuted as a failure of unique
  factorisation: the two unordered factorisations are associate
  (`Mobius.MInt.six_factorizations_associated`).
* **Unique factorisation up to orientation**
  (`Mobius.MInt.unique_factorization_up_to_orientation`,
  `Mobius.MInt.factorization_norms_unique`): confirmed, with the sharp form
  "any two prime factorisations agree up to a permutation and a sign, hence
  have identical multisets of norms".
* **`Z̃` is non-Ore** (`Mobius.MInt.ore_condition`): **refuted**.  `Z̃` is a
  commutative domain, so both Ore conditions hold; the conjectural explanation
  of off-critical-line zeros via non-Ore-ness collapses.
-/

namespace Mobius
namespace MInt

/-! ### Oriented primes and the norm -/

/-- The *norm* (magnitude) of a Möbius integer: the radius of the circle on the
Möbius band that it lies on. -/
def norm (x : MInt) : ℕ := (toZ x).natAbs

@[simp] theorem norm_mk (a : Oriented) : norm (mk a) = (value a).natAbs := rfl

theorem norm_mul (x y : MInt) : norm (x * y) = norm x * norm y := by
  simp [norm, Int.natAbs_mul]

@[simp] theorem norm_neg (x : MInt) : norm (-x) = norm x := by simp [norm]

theorem norm_eq_zero_iff (x : MInt) : norm x = 0 ↔ x = 0 := by
  rw [norm, Int.natAbs_eq_zero, toZ_eq_zero_iff]

/-- The positively oriented copy `n⁺` of a natural number. -/
def pos (n : ℕ) : MInt := mk ((n : ℤ), true)

/-- The negatively oriented copy `n⁻` of a natural number. -/
def neg (n : ℕ) : MInt := mk ((n : ℤ), false)

@[simp] theorem toZ_pos (n : ℕ) : toZ (pos n) = n := rfl
@[simp] theorem toZ_neg' (n : ℕ) : toZ (neg n) = -(n : ℤ) := rfl
@[simp] theorem norm_pos (n : ℕ) : norm (pos n) = n := by simp [norm, pos]
@[simp] theorem norm_neg' (n : ℕ) : norm (neg n) = n := by simp [norm, neg]

/-- Orientation reversal: `n⁻ = -n⁺`. -/
theorem neg_eq_neg_pos (n : ℕ) : neg n = -pos n := by
  apply toZ_injective; simp

theorem pos_ne_neg {n : ℕ} (hn : n ≠ 0) : pos n ≠ neg n := by
  intro h
  have := congrArg toZ h
  simp only [toZ_pos, toZ_neg'] at this
  omega

/-! ### Primality -/

/-- The prime elements of `Z̃` are exactly the elements of rationally prime
norm.  Orientation is invisible to primality. -/
theorem prime_iff (x : MInt) : Prime x ↔ (norm x).Prime := by
  constructor
  · intro hx
    have h : Prime (equivZ x) := (MulEquiv.prime_iff (equivZ : MInt ≃* ℤ)).2 hx
    exact Int.prime_iff_natAbs_prime.1 h
  · intro hx
    have hz : Prime (equivZ x) := Int.prime_iff_natAbs_prime.2 hx
    exact (MulEquiv.prime_iff (equivZ : MInt ≃* ℤ)).1 hz

theorem prime_pos {p : ℕ} (hp : p.Prime) : Prime (pos p) := by
  rw [prime_iff, norm_pos]; exact hp

theorem prime_neg {p : ℕ} (hp : p.Prime) : Prime (neg p) := by
  rw [prime_iff, norm_neg']; exact hp

/-- **Associates in `Z̃` are exactly orientation-flips.** -/
theorem associated_iff_orientation (x y : MInt) : Associated x y ↔ y = x ∨ y = -x := by
  constructor
  · rintro ⟨u, rfl⟩
    rcases units_eq_one_or u with rfl | rfl
    · exact Or.inl (by simp)
    · exact Or.inr (by simp)
  · rintro (rfl | rfl)
    · exact Associated.refl _
    · exact ⟨-1, by simp⟩

/-- **The fibres of the norm map.**  A radius `n` is realised by exactly the two
oriented points `n⁺` and `n⁻` (which coincide only for `n = 0`). -/
theorem norm_fiber_eq (n : ℕ) : {x : MInt | norm x = n} = {pos n, neg n} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro hnorm
    have hx : (toZ x).natAbs = n := hnorm
    rcases Int.natAbs_eq (toZ x) with h | h
    · left; apply toZ_injective; rw [h, hx]; rfl
    · right; apply toZ_injective; rw [h, hx]; rfl
  · rintro (rfl | rfl) <;> simp

/-- **Oriented primes over a rational prime.**  For each rational prime `p` the
fibre of the norm map over `p`, restricted to prime elements, is exactly the
two-element set `{p⁺, p⁻}`. -/
theorem orientedPrimes_eq {p : ℕ} (hp : p.Prime) :
    {x : MInt | Prime x ∧ norm x = p} = {pos p, neg p} := by
  rw [← norm_fiber_eq p]
  ext x
  simp only [Set.mem_setOf_eq, and_iff_right_iff_imp]
  intro hnorm
  rw [prime_iff, hnorm]
  exact hp

/-- **The prime elements of `Z̃` form a double cover of the rational primes.** -/
theorem primes_over_card {p : ℕ} (hp : p.Prime) :
    {x : MInt | Prime x ∧ norm x = p}.ncard = 2 := by
  rw [orientedPrimes_eq hp, Set.ncard_pair (pos_ne_neg hp.ne_zero)]

/-! ### Class number and unique factorisation -/

/-- **Class number one.**  `Z̃` is a principal ideal domain, so its ideal class
group is trivial. -/
theorem classGroup_subsingleton : Subsingleton (ClassGroup MInt) := inferInstance

/-- Explicit form of class number one: every ideal of `Z̃` is generated by a
single Möbius integer, unique up to orientation. -/
theorem ideal_isPrincipal (I : Ideal MInt) : ∃ x : MInt, I = Ideal.span {x} := by
  obtain ⟨x, hx⟩ := (IsPrincipalIdealRing.principal I).principal
  exact ⟨x, hx⟩

instance : UniqueFactorizationMonoid MInt := inferInstance

/-- **Unique factorisation up to orientation.**  Two prime factorisations of the
same element agree after a permutation, each matched pair differing at most by
an orientation flip (a sign). -/
theorem unique_factorization_up_to_orientation {f g : Multiset MInt}
    (hf : ∀ x ∈ f, Prime x) (hg : ∀ x ∈ g, Prime x) (h : f.prod = g.prod) :
    Multiset.Rel (fun x y => y = x ∨ y = -x) f g := by
  have := UniqueFactorizationMonoid.factors_unique (f := f) (g := g)
    (fun x hx => (hf x hx).irreducible) (fun x hx => (hg x hx).irreducible)
    (by rw [h])
  refine this.mono ?_
  intro a _ b _ hab
  exact (associated_iff_orientation a b).1 hab

/-- **The multiset of norms is a complete invariant of a factorisation**: any
two prime factorisations of the same Möbius integer carry the same multiset of
radii, so the underlying "unoriented" factorisation is genuinely unique. -/
theorem factorization_norms_unique {f g : Multiset MInt}
    (hf : ∀ x ∈ f, Prime x) (hg : ∀ x ∈ g, Prime x) (h : f.prod = g.prod) :
    f.map norm = g.map norm := by
  have hrel := unique_factorization_up_to_orientation hf hg h
  rw [← Multiset.rel_eq]
  refine Multiset.rel_map.2 (hrel.mono ?_)
  rintro a - b - (rfl | rfl) <;> simp

/-! ### The spectrum is *not* doubled -/

/-- The two oriented primes over `p` generate the same ideal. -/
theorem span_pos_eq_span_neg (n : ℕ) :
    Ideal.span {pos n} = Ideal.span {neg n} := by
  rw [neg_eq_neg_pos, Ideal.span_singleton_eq_span_singleton]
  exact ⟨-1, by simp⟩

/-- **Refutation of the "spectral double cover".**  Although `p⁺ ≠ p⁻` as
elements, they define the *same* point of `Spec Z̃`. -/
theorem primeSpectrum_pos_eq_neg {p : ℕ} (hp : p.Prime) :
    (⟨Ideal.span {pos p}, (Ideal.span_singleton_prime (prime_pos hp).ne_zero).2
        (prime_pos hp)⟩ : PrimeSpectrum MInt) =
      ⟨Ideal.span {neg p}, (Ideal.span_singleton_prime (prime_neg hp).ne_zero).2
        (prime_neg hp)⟩ := by
  apply PrimeSpectrum.ext
  exact span_pos_eq_span_neg p

/-- The comparison map on spectra is an order isomorphism: `Spec Z̃ ≅ Spec ℤ`,
a *single* cover. -/
def specEquivZ : PrimeSpectrum MInt ≃o PrimeSpectrum ℤ := PrimeSpectrum.comapEquiv equivZ

/-! ### Factoring `6` -/

/-- Classification of the ordered prime factorisations of `6` in `ℤ`. -/
theorem int_six_prime_pairs {a b : ℤ} (ha : Prime a) (hb : Prime b) (hab : a * b = 6) :
    (a = 2 ∧ b = 3) ∨ (a = 3 ∧ b = 2) ∨ (a = -2 ∧ b = -3) ∨ (a = -3 ∧ b = -2) := by
  have hna : a.natAbs.Prime := Int.prime_iff_natAbs_prime.1 ha
  have hnb : b.natAbs.Prime := Int.prime_iff_natAbs_prime.1 hb
  have h6 : a.natAbs * b.natAbs = 6 := by
    rw [← Int.natAbs_mul, hab]; rfl
  have ha2 : 2 ≤ a.natAbs := hna.two_le
  have hb2 : 2 ≤ b.natAbs := hnb.two_le
  have hle : a.natAbs ≤ 3 := by nlinarith
  have hcase : (a.natAbs = 2 ∧ b.natAbs = 3) ∨ (a.natAbs = 3 ∧ b.natAbs = 2) := by
    interval_cases h : a.natAbs
    · exact Or.inl ⟨rfl, by omega⟩
    · exact Or.inr ⟨rfl, by omega⟩
  rcases hcase with ⟨h1, -⟩ | ⟨h1, -⟩
  · rcases Int.natAbs_eq a with h | h <;> rw [h1] at h <;> push_cast at h <;> subst h
    · left; exact ⟨rfl, by omega⟩
    · right; right; left; exact ⟨rfl, by omega⟩
  · rcases Int.natAbs_eq a with h | h <;> rw [h1] at h <;> push_cast at h <;> subst h
    · right; left; exact ⟨rfl, by omega⟩
    · right; right; right; exact ⟨rfl, by omega⟩

/-- `6 = 2⁺ · 3⁺`. -/
theorem six_eq_pos : (6 : MInt) = pos 2 * pos 3 := by
  apply toZ_injective; simp [pos]; rfl

/-- `6 = 2⁻ · 3⁻`: the orientation-reversed factorisation. -/
theorem six_eq_neg : (6 : MInt) = neg 2 * neg 3 := by
  apply toZ_injective; simp [neg]; rfl

/-- The two factorisations of `6` really are different as *oriented* data. -/
theorem six_factorizations_distinct : (pos 2, pos 3) ≠ ((neg 2, neg 3) : MInt × MInt) := by
  intro h
  exact pos_ne_neg (n := 2) (by norm_num) (congrArg Prod.fst h)

/-- ... but they are associate, so unique factorisation is *not* violated. -/
theorem six_factorizations_associated :
    Associated (pos 2) (neg 2) ∧ Associated (pos 3) (neg 3) :=
  ⟨(associated_iff_orientation _ _).2 (Or.inr (neg_eq_neg_pos 2)),
   (associated_iff_orientation _ _).2 (Or.inr (neg_eq_neg_pos 3))⟩

/-- **Complete enumeration.**  There are exactly four ordered factorisations of
`6` into two prime Möbius integers. -/
theorem six_factorizations :
    {q : MInt × MInt | Prime q.1 ∧ Prime q.2 ∧ q.1 * q.2 = 6} =
      {(pos 2, pos 3), (pos 3, pos 2), (neg 2, neg 3), (neg 3, neg 2)} := by
  ext ⟨x, y⟩
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff, Prod.mk.injEq]
  constructor
  · rintro ⟨hx, hy, hxy⟩
    have hpx : Prime (toZ x) := (MulEquiv.prime_iff (equivZ : MInt ≃* ℤ)).2 hx
    have hpy : Prime (toZ y) := (MulEquiv.prime_iff (equivZ : MInt ≃* ℤ)).2 hy
    have h6 : toZ x * toZ y = 6 := by rw [← toZ_mul, hxy]; rfl
    rcases int_six_prime_pairs (by simpa using hpx) (by simpa using hpy) h6 with
      ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨toZ_injective (by rw [h1]; rfl), toZ_injective (by rw [h2]; rfl)⟩
    · exact Or.inr (Or.inl ⟨toZ_injective (by rw [h1]; rfl), toZ_injective (by rw [h2]; rfl)⟩)
    · exact Or.inr (Or.inr (Or.inl
        ⟨toZ_injective (by rw [h1]; rfl), toZ_injective (by rw [h2]; rfl)⟩))
    · exact Or.inr (Or.inr (Or.inr
        ⟨toZ_injective (by rw [h1]; rfl), toZ_injective (by rw [h2]; rfl)⟩))
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨prime_pos (by norm_num), prime_pos (by norm_num), six_eq_pos.symm⟩
    · exact ⟨prime_pos (by norm_num), prime_pos (by norm_num), by
        apply toZ_injective; simp [pos]; rfl⟩
    · exact ⟨prime_neg (by norm_num), prime_neg (by norm_num), six_eq_neg.symm⟩
    · exact ⟨prime_neg (by norm_num), prime_neg (by norm_num), by
        apply toZ_injective; simp [neg]; rfl⟩

/-! ### The Ore condition -/

/-- **Refutation of non-Ore-ness.**  `Z̃` is a commutative domain, hence
satisfies the (left and right) Ore condition: any two nonzero elements have a
nonzero common multiple. -/
theorem ore_condition (a b : MInt) (ha : a ≠ 0) (hb : b ≠ 0) :
    ∃ x y : MInt, x ≠ 0 ∧ y ≠ 0 ∧ a * x = b * y ∧ a * x ≠ 0 :=
  ⟨b, a, hb, ha, by ring, mul_ne_zero ha hb⟩

/-!
### Lab notes (experimental data behind the statements above)

Enumerating all pairs `(a, b)` of prime integers with `-7 ≤ a, b ≤ 7` and
`a * b = 6` returns

```
[(-3, -2), (-2, -3), (2, 3), (3, 2)]
```

exactly four ordered pairs, matching `six_factorizations`; the two unordered
factorisations differ by the unit `-1`, matching
`six_factorizations_associated`.  Counting `#{x : |x| ≤ N}` for `N = 0,…,5` gives
`[1, 3, 5, 7, 9, 11] = 2N + 1`, matching `Mobius.MInt.card_norm_le`; and
counting divisors of `n = 1,…,12` in `Z̃` against `2τ(n)` gives perfect agreement
`[(2,2), (4,4), (4,4), (6,6), (4,4), (8,8), …]`, matching
`Mobius.MInt.divisors_ncard`.  Full data in `ComputationalEvidence.md`.
-/

end MInt
end Mobius