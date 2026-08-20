import Mathlib
import Catalog.NumberTheory.Basic
import Catalog.NumberTheory.Factorization

/-!
# The oriented double `O` of the integers: an honest Möbius twist

The first cycle of this project proved a sharp negative result: the Möbius
identification `(n,+1) ~ (−n,−1)` on `ℤ × {±1}` produces a ring `Z̃` that is
*isomorphic to `ℤ`* (`Mobius.MInt.equivZ`), so the promised double cover of the
prime spectrum collapses (`Mobius.MInt.primeSpectrum_pos_eq_neg`) and the
orientation survives only as the unit group `ℤ/2`.  The diagnosis recorded in
`FUTURE_DIRECTIONS.md` (Conjecture 1) was that a genuine twist has to be stored
in the **multiplication**, not in an identification of the underlying set.

This file carries out that programme and *confirms* the diagnosis.  We form the
**oriented double**

```
O = ℤ[τ]/(τ² − 1) ≅ { (u, v) ∈ ℤ × ℤ : u ≡ v (mod 2) },
```

the group ring of the orientation group `ℤ/2` (equivalently, the ring generated
by an abstract orientation symbol `τ` with `τ² = 1`), realised concretely as the
index-two subring of `ℤ × ℤ` cut out by the parity condition.  The two
coordinates are the two orientations, and the deck involution is the coordinate
swap `τ ↦ −τ`.

Main results.

* `Mobius.OInt.basis`, `Mobius.OInt.tau_sq`: `O = ℤ ⊕ ℤτ` with `τ² = 1`.
* `Mobius.OInt.not_isDomain`, `Mobius.OInt.isEmpty_ringEquiv_int`,
  `Mobius.OInt.isEmpty_ringEquiv_mInt`: unlike `Z̃`, the oriented double is
  **not** isomorphic to `ℤ` — the twist is now a genuine invariant.
* `Mobius.OInt.isUnit_iff`, `Mobius.OInt.units_ncard`: the orientation group
  grows from `ℤ/2` to the Klein four-group `{±1, ±τ}`.
* `Mobius.OInt.ringHom_int_eq`: there are **exactly two** ring maps `O → ℤ`, the
  two orientations, exchanged by the deck involution.  Each identifies the
  Möbius integers `Z̃` as an orientation-quotient of `O`.
* `Mobius.OInt.primeAt_ne` / `primeAt_eq_two`: the prime spectrum of `O`
  **really is** a double cover of `Spec ℤ`, *branched exactly at `2`*: for odd
  `p` the two maximal ideals `P⁺(p) ≠ P⁻(p)` both contract to `pℤ` and satisfy
  `P⁺(p) ⊓ P⁻(p) = (p)`, while `P⁺(2) = P⁻(2)` is ramified,
  `P⁺(2)² ⊆ (2) ⊊ P⁺(2)`.
* `Mobius.OInt.swap_primeAtPlus`: the deck involution exchanges the two points
  over an odd prime and fixes the point over `2` — the discrete shadow of the
  orientation double cover of the Möbius band, whose single branch point is the
  prime `2`.
* `Mobius.OInt.conductorQuotientEquiv`: `(ℤ × ℤ)/O ≃+ ℤ/2`, so `O` has conductor
  `2` inside its normalisation; the branch locus and the conductor agree.

Together with `Mobius.MInt.zetaTilde_ne_zeta_sq` this closes the loop: a
set-level `ℤ/2`-identification doubles the *zeta values* but not the
*spectrum*, whereas the multiplicative twist doubles the spectrum.
-/

namespace Mobius

/-- The **oriented double** of `ℤ`, realised as the index-two subring
`{(u, v) : u ≡ v mod 2}` of `ℤ × ℤ`.  Writing `u = a + b`, `v = a − b` this is
the ring `ℤ[τ]/(τ² − 1)`, the group ring of the orientation group. -/
def OZ : Subring (ℤ × ℤ) where
  carrier := {x : ℤ × ℤ | (2:ℤ) ∣ x.1 - x.2}
  zero_mem' := by simp
  one_mem' := by simp
  add_mem' := by
    rintro a b ⟨k, hk⟩ ⟨l, hl⟩
    exact ⟨k + l, by simp only [Prod.fst_add, Prod.snd_add]; linarith⟩
  neg_mem' := by
    rintro a ⟨k, hk⟩
    exact ⟨-k, by simp only [Prod.fst_neg, Prod.snd_neg]; linarith⟩
  mul_mem' := by
    rintro a b ⟨k, hk⟩ ⟨l, hl⟩
    refine ⟨a.1 * l + k * b.2, ?_⟩
    simp only [Prod.fst_mul, Prod.snd_mul]
    have h1 : a.1 = a.2 + 2 * k := by linarith
    have h2 : b.1 = b.2 + 2 * l := by linarith
    rw [h1, h2]; ring

/-- Elements of the oriented double. -/
abbrev OInt := OZ

namespace OInt

theorem mem_OZ {u v : ℤ} : (u, v) ∈ OZ ↔ (2:ℤ) ∣ u - v := Iff.rfl

theorem parity (x : OInt) : (2:ℤ) ∣ (x : ℤ × ℤ).1 - (x : ℤ × ℤ).2 := x.2

@[ext] theorem ext {x y : OInt} (h1 : (x : ℤ × ℤ).1 = (y : ℤ × ℤ).1)
    (h2 : (x : ℤ × ℤ).2 = (y : ℤ × ℤ).2) : x = y :=
  Subtype.ext (Prod.ext h1 h2)

/-- The diagonal embedding `ℤ → O`. -/
def iota : ℤ →+* OInt where
  toFun n := ⟨(n, n), by rw [mem_OZ]; simp⟩
  map_one' := rfl
  map_mul' := fun _ _ => rfl
  map_zero' := rfl
  map_add' := fun _ _ => rfl

/-- The orientation symbol `τ`, i.e. the element `(1, −1)`. -/
def tau : OInt := ⟨(1, -1), by rw [mem_OZ]; decide⟩

@[simp] theorem coe_iota (n : ℤ) : ((iota n : OInt) : ℤ × ℤ) = (n, n) := rfl
@[simp] theorem coe_tau : ((tau : OInt) : ℤ × ℤ) = (1, -1) := rfl
@[simp] theorem coe_mul (x y : OInt) :
    ((x * y : OInt) : ℤ × ℤ) = (x : ℤ × ℤ) * (y : ℤ × ℤ) := rfl
@[simp] theorem coe_add (x y : OInt) :
    ((x + y : OInt) : ℤ × ℤ) = (x : ℤ × ℤ) + (y : ℤ × ℤ) := rfl
@[simp] theorem coe_neg (x : OInt) : ((-x : OInt) : ℤ × ℤ) = -(x : ℤ × ℤ) := rfl
@[simp] theorem coe_one : ((1 : OInt) : ℤ × ℤ) = 1 := rfl
@[simp] theorem coe_zero : ((0 : OInt) : ℤ × ℤ) = 0 := rfl

theorem iota_injective : Function.Injective iota := by
  intro m n h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
  simpa using this

/-- `τ² = 1`: the orientation symbol is an involution. -/
@[simp] theorem tau_sq : tau * tau = 1 := by ext <;> rfl

/-- Coordinates of the canonical form `a + bτ`. -/
@[simp] theorem coe_repr (a b : ℤ) :
    ((iota a + iota b * tau : OInt) : ℤ × ℤ) = (a + b, a - b) := by
  simp only [coe_add, coe_mul, coe_iota, coe_tau, Prod.mk_mul_mk, Prod.mk_add_mk,
    Prod.mk.injEq]
  constructor <;> ring

/-- **Basis theorem.**  Every oriented double integer is uniquely `a + bτ`. -/
theorem basis (x : OInt) : ∃! ab : ℤ × ℤ, x = iota ab.1 + iota ab.2 * tau := by
  obtain ⟨⟨u, v⟩, h⟩ := x
  rw [mem_OZ] at h
  obtain ⟨k, hk⟩ := h
  refine ⟨(v + k, k), ?_, ?_⟩
  · apply Subtype.ext
    rw [coe_repr]
    have : u = v + k + k := by linarith
    rw [Prod.mk.injEq]
    constructor <;> omega
  · rintro ⟨a, b⟩ hab
    have h1 := congrArg (fun x : OInt => (x : ℤ × ℤ).1) hab
    have h2 := congrArg (fun x : OInt => (x : ℤ × ℤ).2) hab
    simp only [coe_repr] at h1 h2
    rw [Prod.mk.injEq]
    constructor <;> omega

/-! ### The oriented double is genuinely twisted: it is not `ℤ` -/

theorem one_add_tau_ne_zero : (1 : OInt) + tau ≠ 0 := by
  intro h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
  simp at this

theorem one_sub_tau_ne_zero : (1 : OInt) - tau ≠ 0 := by
  intro h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).2) h
  simp only [coe_zero, sub_eq_add_neg, coe_add, coe_neg, coe_one, coe_tau] at this
  norm_num at this

/-- The characteristic zero-divisor relation of the oriented double. -/
theorem zero_divisor : ((1 : OInt) + tau) * (1 - tau) = 0 := by
  have h : ((1 : OInt) + tau) * (1 - tau) = 1 - tau * tau := by ring
  rw [h, tau_sq, sub_self]

/-- `O` is **not** a domain: the two orientations are orthogonal directions.
This is the precise point where the oriented double departs from the Möbius
integers `Z̃`, which are a domain. -/
theorem not_isDomain : ¬ IsDomain OInt := by
  intro h
  rcases mul_eq_zero.1 zero_divisor with h1 | h1
  · exact one_add_tau_ne_zero h1
  · exact one_sub_tau_ne_zero h1

/-- Consequently `O ≇ ℤ`. -/
theorem isEmpty_ringEquiv_int : IsEmpty (OInt ≃+* ℤ) := by
  refine ⟨fun e => ?_⟩
  have h := congrArg e zero_divisor
  rw [map_mul, map_zero] at h
  rcases mul_eq_zero.1 h with h1 | h1
  · exact one_add_tau_ne_zero (e.injective (by rw [h1, map_zero]))
  · exact one_sub_tau_ne_zero (e.injective (by rw [h1, map_zero]))

/-- And `O ≇ Z̃`: the multiplicative twist is a strictly finer structure than
the set-level Möbius identification. -/
theorem isEmpty_ringEquiv_mInt : IsEmpty (OInt ≃+* MInt) :=
  ⟨fun e => (isEmpty_ringEquiv_int).elim (e.trans MInt.equivZ)⟩

/-! ### The orientation group grows to the Klein four-group -/

theorem isUnit_iff (x : OInt) : IsUnit x ↔ x = 1 ∨ x = -1 ∨ x = tau ∨ x = -tau := by
  constructor
  · rintro ⟨u, rfl⟩
    have h1 : ((u : OInt) : ℤ × ℤ) * ((↑u⁻¹ : OInt) : ℤ × ℤ) = 1 := by
      rw [← coe_mul, ← Units.val_mul, mul_inv_cancel, Units.val_one, coe_one]
    have hu1 : IsUnit ((u : OInt) : ℤ × ℤ).1 :=
      IsUnit.of_mul_eq_one _ (congrArg Prod.fst h1)
    have hu2 : IsUnit ((u : OInt) : ℤ × ℤ).2 :=
      IsUnit.of_mul_eq_one _ (congrArg Prod.snd h1)
    rcases Int.isUnit_iff.1 hu1 with hA | hA <;> rcases Int.isUnit_iff.1 hu2 with hB | hB
    · exact Or.inl (by ext <;> simp [hA, hB])
    · exact Or.inr (Or.inr (Or.inl (by ext <;> simp [hA, hB])))
    · exact Or.inr (Or.inr (Or.inr (by ext <;> simp [hA, hB])))
    · exact Or.inr (Or.inl (by ext <;> simp [hA, hB]))
  · rintro (rfl | rfl | rfl | rfl)
    · exact isUnit_one
    · exact isUnit_one.neg
    · exact IsUnit.of_mul_eq_one _ tau_sq
    · exact (IsUnit.of_mul_eq_one _ tau_sq).neg

theorem tau_ne_one : tau ≠ 1 := by
  intro h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).2) h
  simp at this

theorem tau_ne_neg_one : tau ≠ -1 := by
  intro h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
  simp at this

theorem one_ne_neg_one : (1 : OInt) ≠ -1 := by
  intro h
  have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
  simp at this

/-- **The oriented unit group.**  Exactly `{±1, ±τ}`, a Klein four-group.  The
Möbius integers only see the subgroup `{±1}`. -/
theorem units_eq : {x : OInt | IsUnit x} = {1, -1, tau, -tau} := by
  ext x
  simp only [Set.mem_setOf_eq, isUnit_iff, Set.mem_insert_iff, Set.mem_singleton_iff]

theorem units_ncard : {x : OInt | IsUnit x}.ncard = 4 := by
  rw [units_eq]
  have h1 : (1 : OInt) ≠ -1 := one_ne_neg_one
  have h2 : (1 : OInt) ≠ tau := fun h => tau_ne_one h.symm
  have h3 : (1 : OInt) ≠ -tau := by
    intro h
    have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
    simp at this
  have h4 : (-1 : OInt) ≠ tau := fun h => tau_ne_neg_one h.symm
  have h5 : (-1 : OInt) ≠ -tau := by
    intro h
    have := congrArg (fun x : OInt => (x : ℤ × ℤ).2) h
    simp at this
  have h6 : (tau : OInt) ≠ -tau := by
    intro h
    have := congrArg (fun x : OInt => (x : ℤ × ℤ).1) h
    simp at this
  rw [Set.ncard_insert_of_notMem (by simp [h1, h2, h3]),
    Set.ncard_insert_of_notMem (by simp [h4, h5]),
    Set.ncard_insert_of_notMem (by simp [h6]), Set.ncard_singleton]

/-! ### The deck involution -/

/-- The **deck involution** of the oriented double: swap the two orientations,
i.e. `τ ↦ −τ`. -/
def swap : OInt ≃+* OInt where
  toFun x := ⟨((x : ℤ × ℤ).2, (x : ℤ × ℤ).1), by
    obtain ⟨k, hk⟩ := parity x
    exact ⟨-k, by linarith⟩⟩
  invFun x := ⟨((x : ℤ × ℤ).2, (x : ℤ × ℤ).1), by
    obtain ⟨k, hk⟩ := parity x
    exact ⟨-k, by linarith⟩⟩
  left_inv x := by ext <;> rfl
  right_inv x := by ext <;> rfl
  map_add' x y := by ext <;> rfl
  map_mul' x y := by ext <;> rfl

@[simp] theorem coe_swap (x : OInt) :
    ((swap x : OInt) : ℤ × ℤ) = ((x : ℤ × ℤ).2, (x : ℤ × ℤ).1) := rfl

@[simp] theorem swap_iota (n : ℤ) : swap (iota n) = iota n := by ext <;> rfl

@[simp] theorem swap_tau : swap tau = -tau := by ext <;> rfl

theorem swap_involutive : Function.Involutive swap := fun x => by ext <;> rfl

/-- The fixed ring of the deck involution is exactly the diagonal copy of `ℤ`:
`O` is a `ℤ/2`-cover of `ℤ` in the Galois-theoretic sense. -/
theorem swap_fixed_iff (x : OInt) : swap x = x ↔ ∃ n : ℤ, x = iota n := by
  constructor
  · intro h
    refine ⟨(x : ℤ × ℤ).1, ?_⟩
    have h2 := congrArg (fun y : OInt => (y : ℤ × ℤ).1) h
    simp only [coe_swap] at h2
    refine ext rfl ?_
    rw [coe_iota]
    exact h2
  · rintro ⟨n, rfl⟩
    exact swap_iota n

/-! ### The two orientations: ring maps to `ℤ` -/

/-- The first orientation `a + bτ ↦ a + b`. -/
def orientPlus : OInt →+* ℤ := (RingHom.fst ℤ ℤ).comp OZ.subtype

/-- The second orientation `a + bτ ↦ a − b`. -/
def orientMinus : OInt →+* ℤ := (RingHom.snd ℤ ℤ).comp OZ.subtype

@[simp] theorem orientPlus_apply (x : OInt) : orientPlus x = (x : ℤ × ℤ).1 := rfl
@[simp] theorem orientMinus_apply (x : OInt) : orientMinus x = (x : ℤ × ℤ).2 := rfl

theorem orientPlus_ne_orientMinus : orientPlus ≠ orientMinus := by
  intro h
  have h2 := congrArg (fun f : OInt →+* ℤ => f tau) h
  simp only [orientPlus_apply, orientMinus_apply, coe_tau] at h2
  norm_num at h2

/-- **Exactly two orientations.**  Every ring map `O → ℤ` is one of the two
coordinate projections; they are exchanged by the deck involution.  This is the
sense in which the oriented double is a genuine two-fold cover: the Möbius
integers `Z̃ ≅ ℤ` arise from `O` in exactly two ways. -/
theorem ringHom_int_eq (f : OInt →+* ℤ) : f = orientPlus ∨ f = orientMinus := by
  have htau : f tau = 1 ∨ f tau = -1 := by
    have h : f tau * f tau = 1 := by rw [← map_mul, tau_sq, map_one]
    exact Int.isUnit_iff.1 (IsUnit.of_mul_eq_one _ h)
  have hiota : ∀ n : ℤ, f (iota n) = n := by
    intro n
    simp
  rcases htau with h | h
  · left
    ext x
    obtain ⟨⟨a, b⟩, hx, -⟩ := basis x
    subst hx
    rw [map_add, map_mul, hiota, hiota, h, mul_one, orientPlus_apply, coe_repr]
  · right
    ext x
    obtain ⟨⟨a, b⟩, hx, -⟩ := basis x
    subst hx
    rw [map_add, map_mul, hiota, hiota, h, orientMinus_apply, coe_repr]
    ring

theorem orientPlus_comp_swap : orientPlus.comp (swap : OInt →+* OInt) = orientMinus := by
  ext x; rfl

/-! ### The prime spectrum really is a branched double cover of `Spec ℤ` -/

variable (p : ℕ)

/-- The reduction `O → ℤ/p` through the first orientation. -/
def redPlus : OInt →+* ZMod p := (Int.castRingHom (ZMod p)).comp orientPlus

/-- The reduction `O → ℤ/p` through the second orientation. -/
def redMinus : OInt →+* ZMod p := (Int.castRingHom (ZMod p)).comp orientMinus

/-- The prime `P⁺(p)` of `O` above `p`, cut out by the first orientation. -/
def primeAtPlus : Ideal OInt := RingHom.ker (redPlus p)

/-- The prime `P⁻(p)` of `O` above `p`, cut out by the second orientation. -/
def primeAtMinus : Ideal OInt := RingHom.ker (redMinus p)

theorem mem_primeAtPlus {x : OInt} : x ∈ primeAtPlus p ↔ (p : ℤ) ∣ (x : ℤ × ℤ).1 := by
  rw [primeAtPlus, RingHom.mem_ker]
  exact ZMod.intCast_zmod_eq_zero_iff_dvd _ _

theorem mem_primeAtMinus {x : OInt} : x ∈ primeAtMinus p ↔ (p : ℤ) ∣ (x : ℤ × ℤ).2 := by
  rw [primeAtMinus, RingHom.mem_ker]
  exact ZMod.intCast_zmod_eq_zero_iff_dvd _ _

theorem redPlus_surjective : Function.Surjective (redPlus p) := by
  intro a
  obtain ⟨n, rfl⟩ := ZMod.intCast_surjective (n := p) a
  exact ⟨iota n, rfl⟩

theorem redMinus_surjective : Function.Surjective (redMinus p) := by
  intro a
  obtain ⟨n, rfl⟩ := ZMod.intCast_surjective (n := p) a
  exact ⟨iota n, rfl⟩

/-- `P⁺(p)` is a maximal ideal for every prime `p`. -/
theorem primeAtPlus_isMaximal (hp : p.Prime) : (primeAtPlus p).IsMaximal := by
  haveI : Fact p.Prime := ⟨hp⟩
  exact RingHom.ker_isMaximal_of_surjective (redPlus p) (redPlus_surjective p)

theorem primeAtMinus_isMaximal (hp : p.Prime) : (primeAtMinus p).IsMaximal := by
  haveI : Fact p.Prime := ⟨hp⟩
  exact RingHom.ker_isMaximal_of_surjective (redMinus p) (redMinus_surjective p)

/-- Both oriented primes lie over `pℤ`. -/
theorem comap_primeAtPlus : Ideal.comap iota (primeAtPlus p) = Ideal.span {(p : ℤ)} := by
  ext n
  rw [Ideal.mem_comap, mem_primeAtPlus, Ideal.mem_span_singleton, coe_iota]

theorem comap_primeAtMinus : Ideal.comap iota (primeAtMinus p) = Ideal.span {(p : ℤ)} := by
  ext n
  rw [Ideal.mem_comap, mem_primeAtMinus, Ideal.mem_span_singleton, coe_iota]

/-- **Splitting at odd primes.**  For an odd prime `p` the two oriented primes
are distinct: the fibre of `Spec O → Spec ℤ` over `p` has two points. -/
theorem primeAt_ne (hp : p.Prime) (hp2 : p ≠ 2) : primeAtPlus p ≠ primeAtMinus p := by
  intro h
  have hx : iota 1 + iota 1 * tau ∈ primeAtMinus p := by
    rw [mem_primeAtMinus, coe_repr]
    simp
  rw [← h, mem_primeAtPlus, coe_repr] at hx
  have hdvd : (p : ℤ) ∣ (2 : ℤ) := by simpa using hx
  have : p ∣ 2 := by exact_mod_cast hdvd
  exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 this)

/-- **Ramification at `2`.**  The two oriented primes over `2` coincide: the
fibre of `Spec O → Spec ℤ` over `2` is a single point, the branch point. -/
theorem primeAt_eq_two : primeAtPlus 2 = primeAtMinus 2 := by
  ext x
  rw [mem_primeAtPlus, mem_primeAtMinus]
  have h := parity x
  constructor <;> intro hd <;> · push_cast at hd ⊢; omega

/-- For an odd prime `p` the two oriented primes meet exactly in `(p)`: the
fibre is reduced, i.e. the cover is unramified at `p`. -/
theorem inf_primeAt (hp : p.Prime) (hp2 : p ≠ 2) :
    primeAtPlus p ⊓ primeAtMinus p = Ideal.span {iota (p : ℤ)} := by
  apply le_antisymm
  · intro x hx
    rw [Submodule.mem_inf] at hx
    obtain ⟨hx1, hx2⟩ := hx
    rw [mem_primeAtPlus] at hx1
    rw [mem_primeAtMinus] at hx2
    obtain ⟨a, ha⟩ := hx1
    obtain ⟨b, hb⟩ := hx2
    obtain ⟨k, hk⟩ : Odd p := hp.odd_of_ne_two hp2
    obtain ⟨m, hm⟩ := parity x
    have hpz : (p : ℤ) = 2 * k + 1 := by exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hk
    have hmem : ((a, b) : ℤ × ℤ) ∈ OZ := by
      rw [mem_OZ]
      refine ⟨m - k * (a - b), ?_⟩
      rw [ha, hb, hpz] at hm
      linear_combination hm
    rw [Ideal.mem_span_singleton]
    refine ⟨⟨(a, b), hmem⟩, ?_⟩
    refine ext ?_ ?_
    · show (x : ℤ × ℤ).1 = (p : ℤ) * a
      exact ha
    · show (x : ℤ × ℤ).2 = (p : ℤ) * b
      exact hb
  · rw [Ideal.span_le, Set.singleton_subset_iff, SetLike.mem_coe, Submodule.mem_inf]
    exact ⟨(mem_primeAtPlus p).2 (by simp), (mem_primeAtMinus p).2 (by simp)⟩

/-- At `2` the cover is **ramified**: the square of the unique prime over `2`
sits inside `(2)`. -/
theorem sq_primeAt_two_le : primeAtPlus 2 * primeAtPlus 2 ≤ Ideal.span {iota (2 : ℤ)} := by
  apply Ideal.mul_le.2
  intro x hx y hy
  rw [mem_primeAtPlus] at hx
  rw [mem_primeAtPlus] at hy
  have hpx := parity x
  have hpy := parity y
  have hx2 : (2:ℤ) ∣ (x : ℤ × ℤ).2 := by push_cast at hx; omega
  have hy2 : (2:ℤ) ∣ (y : ℤ × ℤ).2 := by push_cast at hy; omega
  push_cast at hx hy
  obtain ⟨a, ha⟩ := hx
  obtain ⟨b, hb⟩ := hx2
  obtain ⟨c, hc⟩ := hy
  obtain ⟨d, hd⟩ := hy2
  have hmem : ((2 * (a * c), 2 * (b * d)) : ℤ × ℤ) ∈ OZ := by
    rw [mem_OZ]; exact ⟨a * c - b * d, by ring⟩
  rw [Ideal.mem_span_singleton]
  refine ⟨⟨(2 * (a * c), 2 * (b * d)), hmem⟩, ?_⟩
  refine ext ?_ ?_
  · show (x : ℤ × ℤ).1 * (y : ℤ × ℤ).1 = 2 * (2 * (a * c))
    rw [ha, hc]; ring
  · show (x : ℤ × ℤ).2 * (y : ℤ × ℤ).2 = 2 * (2 * (b * d))
    rw [hb, hd]; ring

/-- ... and the inclusion `(2) ⊆ P⁺(2)` is strict, so `(2)` is not prime: the
branch point is genuine. -/
theorem span_two_lt_primeAt_two : Ideal.span {iota (2 : ℤ)} < primeAtPlus 2 := by
  refine lt_of_le_of_ne ?_ ?_
  · rw [Ideal.span_le, Set.singleton_subset_iff, SetLike.mem_coe]
    exact (mem_primeAtPlus 2).2 (by rw [coe_iota]; norm_num)
  · intro h
    have hmem : (⟨(2, 0), by rw [mem_OZ]; decide⟩ : OInt) ∈ primeAtPlus 2 := by
      rw [mem_primeAtPlus]
      exact ⟨1, by norm_num⟩
    rw [← h, Ideal.mem_span_singleton] at hmem
    obtain ⟨y, hy⟩ := hmem
    have h1 : (2 : ℤ) = 2 * (y : ℤ × ℤ).1 := congrArg (fun z : OInt => (z : ℤ × ℤ).1) hy
    have h2 : (0 : ℤ) = 2 * (y : ℤ × ℤ).2 := congrArg (fun z : OInt => (z : ℤ × ℤ).2) hy
    obtain ⟨k, hk⟩ := parity y
    omega

/-- The deck involution exchanges the two oriented primes. -/
theorem swap_primeAtPlus :
    Ideal.comap (swap : OInt →+* OInt) (primeAtPlus p) = primeAtMinus p := by
  ext x
  rw [Ideal.mem_comap, mem_primeAtPlus, mem_primeAtMinus]
  rfl

/-! ### The fibres of `Spec O → Spec ℤ` -/

/-- The fibre of `Spec O → Spec ℤ` over the prime `p`. -/
def fiberOver : Set (PrimeSpectrum OInt) :=
  {Q | Ideal.comap iota Q.asIdeal = Ideal.span {(p : ℤ)}}

/-- Every prime of `O` over `p` contains `iota p`. -/
theorem iota_mem_of_mem_fiber {Q : PrimeSpectrum OInt} (hQ : Q ∈ fiberOver p) :
    iota (p : ℤ) ∈ Q.asIdeal := by
  have h : (p : ℤ) ∈ Ideal.comap iota Q.asIdeal := by
    rw [hQ, Ideal.mem_span_singleton]
  exact h

/-- **The fibre over an odd prime has exactly the two oriented points.** -/
theorem mem_fiberOver_iff (hp : p.Prime) (hp2 : p ≠ 2) {Q : PrimeSpectrum OInt} :
    Q ∈ fiberOver p ↔ Q.asIdeal = primeAtPlus p ∨ Q.asIdeal = primeAtMinus p := by
  constructor
  · intro hQ
    have hmul : primeAtPlus p * primeAtMinus p ≤ Q.asIdeal := by
      refine le_trans (Ideal.mul_le_inf) ?_
      rw [inf_primeAt p hp hp2, Ideal.span_le, Set.singleton_subset_iff, SetLike.mem_coe]
      exact iota_mem_of_mem_fiber p hQ
    rcases Q.isPrime.mul_le.1 hmul with h | h
    · exact Or.inl (((primeAtPlus_isMaximal p hp).eq_of_le Q.isPrime.ne_top h).symm)
    · exact Or.inr (((primeAtMinus_isMaximal p hp).eq_of_le Q.isPrime.ne_top h).symm)
  · rintro (h | h) <;> · show Ideal.comap iota Q.asIdeal = _
                         rw [h]
                         simp [comap_primeAtPlus, comap_primeAtMinus]

/-- **Two points over an odd prime.**  The spectrum of the oriented double is a
genuine double cover of `Spec ℤ` away from `2`. -/
theorem fiberOver_ncard_odd (hp : p.Prime) (hp2 : p ≠ 2) : (fiberOver p).ncard = 2 := by
  have hset : fiberOver p =
      {(⟨primeAtPlus p, (primeAtPlus_isMaximal p hp).isPrime⟩ : PrimeSpectrum OInt),
        ⟨primeAtMinus p, (primeAtMinus_isMaximal p hp).isPrime⟩} := by
    ext Q
    rw [mem_fiberOver_iff p hp hp2]
    simp [PrimeSpectrum.ext_iff, Set.mem_insert_iff, Set.mem_singleton_iff]
  rw [hset, Set.ncard_pair]
  intro h
  exact primeAt_ne p hp hp2 (congrArg PrimeSpectrum.asIdeal h)

/-- **One point over `2`.**  The cover is branched at the prime `2`. -/
theorem fiberOver_ncard_two : (fiberOver 2).ncard = 1 := by
  have hp : Nat.Prime 2 := Nat.prime_two
  have hset : fiberOver 2 =
      {(⟨primeAtPlus 2, (primeAtPlus_isMaximal 2 hp).isPrime⟩ : PrimeSpectrum OInt)} := by
    ext Q
    simp only [Set.mem_singleton_iff, PrimeSpectrum.ext_iff]
    constructor
    · intro hQ
      have hmul : primeAtPlus 2 * primeAtPlus 2 ≤ Q.asIdeal := by
        refine le_trans sq_primeAt_two_le ?_
        rw [Ideal.span_le, Set.singleton_subset_iff, SetLike.mem_coe]
        exact iota_mem_of_mem_fiber 2 hQ
      rcases Q.isPrime.mul_le.1 hmul with h | h <;>
        exact ((primeAtPlus_isMaximal 2 hp).eq_of_le Q.isPrime.ne_top h).symm
    · intro h
      show Ideal.comap iota Q.asIdeal = _
      rw [h]
      exact comap_primeAtPlus 2
  rw [hset, Set.ncard_singleton]

/-! ### Local structure: split residue ring at odd primes, ramified at `2` -/

/-- The pair of reductions `O → ℤ/p × ℤ/p`. -/
def redPair : OInt →+* ZMod p × ZMod p := (redPlus p).prod (redMinus p)

@[simp] theorem redPair_apply (x : OInt) :
    redPair p x = ((((x : ℤ × ℤ).1 : ℤ) : ZMod p), (((x : ℤ × ℤ).2 : ℤ) : ZMod p)) := rfl

theorem ker_redPair : RingHom.ker (redPair p) = primeAtPlus p ⊓ primeAtMinus p := by
  ext x
  rw [RingHom.mem_ker, Submodule.mem_inf, mem_primeAtPlus, mem_primeAtMinus,
    redPair_apply, Prod.ext_iff]
  simp only [Prod.fst_zero, Prod.snd_zero]
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd, ZMod.intCast_zmod_eq_zero_iff_dvd]

/-- For an odd prime the pair of reductions is onto: the two orientations are
independent modulo `p`. -/
theorem redPair_surjective (hp : p.Prime) (hp2 : p ≠ 2) :
    Function.Surjective (redPair p) := by
  rintro ⟨a, b⟩
  obtain ⟨u, rfl⟩ := ZMod.intCast_surjective (n := p) a
  obtain ⟨w, rfl⟩ := ZMod.intCast_surjective (n := p) b
  obtain ⟨k, hk⟩ : Odd p := hp.odd_of_ne_two hp2
  have hpz : (p : ℤ) = 2 * k + 1 := by exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hk
  by_cases hpar : (2:ℤ) ∣ u - w
  · exact ⟨⟨(u, w), hpar⟩, rfl⟩
  · refine ⟨⟨(u, w + p), ?_⟩, ?_⟩
    · rw [mem_OZ]
      omega
    · have : (((w + (p:ℤ)) : ℤ) : ZMod p) = ((w : ℤ) : ZMod p) := by push_cast; simp
      rw [redPair_apply]
      exact Prod.ext rfl this

/-- **Split residue ring.**  For an odd prime `p` the residue ring of the
oriented double is `𝔽_p × 𝔽_p`: the prime `p` really splits into two points, so
its Euler factor is squared. -/
noncomputable def quotientEquivProd (hp : p.Prime) (hp2 : p ≠ 2) :
    (OInt ⧸ Ideal.span {iota (p : ℤ)}) ≃+* ZMod p × ZMod p :=
  (Ideal.quotEquivOfEq (by rw [← inf_primeAt p hp hp2, ← ker_redPair])).trans
    (RingHom.quotientKerEquivOfSurjective (redPair_surjective p hp hp2))

/-- **Ramification at `2`, residue form.**  The residue ring at `2` is *not*
reduced: the class of `τ − 1` is a nonzero nilpotent.  So `2` cannot split, and
the double cover is genuinely branched there. -/
theorem tau_sub_one_nilpotent_mod_two :
    (tau - 1) * (tau - 1) ∈ Ideal.span {iota (2 : ℤ)} ∧
      (tau - 1) ∉ Ideal.span {iota (2 : ℤ)} := by
  constructor
  · rw [Ideal.mem_span_singleton]
    refine ⟨1 - tau, ?_⟩
    refine ext ?_ ?_
    · show ((1:ℤ) - 1) * ((1:ℤ) - 1) = 2 * (1 - 1)
      ring
    · show ((-1:ℤ) - 1) * ((-1:ℤ) - 1) = 2 * (1 - (-1))
      ring
  · rw [Ideal.mem_span_singleton]
    rintro ⟨y, hy⟩
    have h1 : (0 : ℤ) = 2 * (y : ℤ × ℤ).1 := congrArg (fun z : OInt => (z : ℤ × ℤ).1) hy
    have h2 : (-2 : ℤ) = 2 * (y : ℤ × ℤ).2 := congrArg (fun z : OInt => (z : ℤ × ℤ).2) hy
    obtain ⟨k, hk⟩ := parity y
    omega

/-! ### Conductor: the branch locus is the prime `2` -/


/-- The parity difference `(u, v) ↦ u − v mod 2`, whose kernel is `O`. -/
def parityHom : (ℤ × ℤ) →+ ZMod 2 where
  toFun x := ((x.1 - x.2 : ℤ) : ZMod 2)
  map_zero' := by simp
  map_add' x y := by
    simp only [Prod.fst_add, Prod.snd_add]
    push_cast
    ring

theorem parityHom_ker : parityHom.ker = OZ.toAddSubgroup := by
  ext x
  rw [AddMonoidHom.mem_ker]
  show ((x.1 - x.2 : ℤ) : ZMod 2) = 0 ↔ _
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd]
  exact Iff.rfl

theorem parityHom_surjective : Function.Surjective parityHom := by
  intro a
  obtain ⟨n, rfl⟩ := ZMod.intCast_surjective (n := 2) a
  refine ⟨(n, 0), ?_⟩
  show ((n - 0 : ℤ) : ZMod 2) = (n : ZMod 2)
  simp

/-- **Conductor two.**  `O` has index two in its normalisation `ℤ × ℤ`, the
quotient being `ℤ/2`.  The conductor of the order and the branch locus of the
double cover are the same prime, namely `2`. -/
noncomputable def conductorQuotientEquiv : ((ℤ × ℤ) ⧸ OZ.toAddSubgroup) ≃+ ZMod 2 :=
  (QuotientAddGroup.quotientAddEquivOfEq parityHom_ker.symm).trans
    (QuotientAddGroup.quotientKerEquivOfSurjective parityHom parityHom_surjective)

end OInt
end Mobius