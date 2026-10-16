import Mathlib

/-!
# The p-adic obstruction: there is no `t ≠ 1` analogue of Smart / Satoh–Araki–Semaev

## Mathematical content

The Smart / Satoh–Araki–Semaev attack solves ECDLP in polynomial time on **anomalous**
curves, where `#E(F_p) = p + 1 − t = p`, i.e. where the trace is `t = 1`.  There the group law
is identified, via the `p`-adic logarithm, with the additive group of `F_p`.

The tempting "generalisation" is curves with small **nonzero** trace `t ≠ 1`; then
`#E(F_p) = p + 1 − t` is coprime to `p`.  This file proves that no such generalisation exists,
because a torsion obstruction forbids it.

* **(T1)** Any additive group homomorphism into an additively torsion-free group vanishes on
  every element of finite order — `hom_from_finOrder_to_IsAddTorsionFree_eq_zero`.
* **(T3)** Consequently, for a finite group `G` of order coprime to `p` — which is what
  `#E(F_p) = p + 1 − t` with `t ≠ 1` is — the *only* homomorphism `G →+ A` into a
  torsion-free target is the zero map — `hom_eq_zero_of_coprime_card`,
  `only_zero_hom_of_curve_order`.
* **(T2', the sharp ECDSA shape)** The obstruction only needs torsion-freeness at the primes
  that actually divide the order of the element being moved: if `A` has no `q`-torsion for
  every prime `q ≠ p`, then no homomorphism moves anything whose order is prime to `p` —
  `map_eq_zero_of_finOrder_and_coprime`.
* **(T2 as literally briefed is FALSE)** The statement "`A` has no `p`-torsion and `x` has
  order prime to `p` implies `f x = 0`" is refuted by a one-line counterexample
  (`G = A = ZMod 2`, `p = 3`, `f = id`) — see `brief_T2_is_false` below.  T2' is the
  repaired statement.
* **Off-by-one correction to the brief.** With `#E = p + 1 − t`, the *anomalous* case is
  `t = 1` (then `#E = p`), not `t = 0` (then `#E = p + 1`, which is already prime to `p`).
  See `card_coprime_of_trace_ne_one` and `p_divides_card_iff_trace_eq_one`.

## What is *not* formalised here

T1/T3 are pure abstract group theory.  They do not know what an elliptic curve is, and they
never mention the formal group, the ordinary/supersingular dichotomy, or the `p`-adic
logarithm.  In particular this file does **not** prove that the Smart/SAS map is a group
homomorphism on anomalous curves, nor that the formal group of an ordinary curve is
torsion-free (height 1) while the supersingular one has height 2 and contains the
`p`-torsion.  Those need a theory of formal groups over `F_p` and a definition of `#E(F_p)`,
none of which exists in Mathlib v4.28.  What *is* formalised is the universal obstruction
that any candidate map must satisfy.  See `RESULT.md`.

## Positive control

`ZMod 4 →+ ZMod 4` has a nonzero element (`id 1 = 1`), so T1's conclusion genuinely fails
without `IsAddTorsionFree`; and no homomorphism `ZMod 4 →+ ℚ` is nonzero.  `zmodOrder` is a
brute-force, `#eval`-able stand-in for `addOrderOf` (which is `noncomputable` in Mathlib, so
it cannot appear in an `#eval`).
-/

namespace PadicTorsionObstruction

/-! ## T1 — the torsion obstruction -/

/-- **T1.** An additive group homomorphism into an additively torsion-free group kills every
element of finite order.

Proof: `n • x = 0` with `n > 0`; then `n • f x = f (n • x) = 0`; `IsAddTorsionFree A` forces
`f x = 0`. -/
theorem hom_from_finOrder_to_IsAddTorsionFree_eq_zero
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : G →+ A) (x : G) (hx : IsOfFinAddOrder x) : f x = 0 := by
  obtain ⟨n, hn, hnx⟩ := IsOfFinAddOrder.exists_nsmul_eq_zero hx
  have hne : n ≠ 0 := by omega
  have h1 : n • (f x) = 0 := by
    rw [← AddMonoidHom.map_nsmul f x n, hnx, map_zero]
  exact (nsmul_eq_zero_iff_right hne).mp h1

/-- **T1, multiplicative-notation form.**  `IsOfFinOrder x` is *literally* the hypothesis of
the axis brief; Mathlib's `IsOfFinOrder` is a multiplicatively named predicate and Lean 4.28
has no `Monoid` instance on an `AddMonoid` (Mathlib avoids the `AddMonoid`/`Monoid` diamond),
so the additive statement above uses the `@[to_additive]` counterpart `IsOfFinAddOrder`.  The
transport is `Additive`. -/
theorem hom_from_finOrder_to_IsAddTorsionFree_eq_zero_mul
    {G : Type*} [CommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : Additive G →+ A) (x : G) (hx : IsOfFinOrder x) :
    f (Additive.ofMul x) = 0 :=
  hom_from_finOrder_to_IsAddTorsionFree_eq_zero f (Additive.ofMul x)
    (isOfFinAddOrder_ofMul_iff.mpr hx)

/-- **T1 in "annihilated by `n ≠ 0`" form**, which is what is needed for the finite-group
version (one does not have to carry an `IsOfFinAddOrder` witness around). -/
theorem map_eq_zero_of_nsmul_eq_zero
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : G →+ A) (x : G) {n : ℕ} (hn : n ≠ 0) (hx : n • x = 0) : f x = 0 := by
  have h1 : n • (f x) = 0 := by
    rw [← AddMonoidHom.map_nsmul f x n, hx, map_zero]
  exact (nsmul_eq_zero_iff_right hn).mp h1

/-- `IsOfFinAddOrder` from a period: `n • x = 0` with `n > 0`. -/
theorem isOfFinAddOrder_of_nsmul_eq_zero {A : Type*} [AddCommGroup A] {n : ℕ} (hn : n ≠ 0)
    (x : A) (hx : n • x = 0) : IsOfFinAddOrder x :=
  Function.mk_mem_periodicPts (Nat.pos_of_ne_zero hn)
    (by simp only [Function.IsPeriodicPt, Function.IsFixedPt, add_left_iterate, hx, add_zero])

/-- A useful reformulation: `m • x = 0` whenever `addOrderOf x = m`. -/
theorem nsmul_eq_zero_of_addOrderOf_eq {A : Type*} [AddCommGroup A] (x : A) (m : ℕ)
    (h : addOrderOf x = m) : m • x = 0 := by
  rw [← h]
  exact addOrderOf_dvd_iff_nsmul_eq_zero.mp (dvd_refl _)

/-! ## The sharp version of the obstruction (T2'): torsion-freeness at the *relevant* primes

The literal "T2" of the brief — *"`A` has no `p`-torsion and `x` has order prime to `p`, hence
`f x = 0`"* — is **false**: `ZMod 2` has no `3`-torsion, yet a homomorphism can still move an
element of order `2`, which is prime to `3` (`brief_T2_is_false`).

What is true, and what is actually needed, is that the obstruction only requires `A` to be
`q`-torsion-free for the primes `q` dividing the order of the element being moved.  In the
`p`-adic setting the relevant shape is "`A` has no `q`-torsion for `q ≠ p`", which holds for
any subgroup of a pro-`p` group (e.g. `p·ℤ_p ⊆ ℚ_p`) and a fortiori for any additively
torsion-free `A` — in which case T1 alone already settles it.
-/

/-- **Core lemma behind T2'.**  If `z` is killed by `n > 0` and `A` has no `q`-torsion for
every prime `q ∣ n`, then `z = 0`.

Proof: with `d = addOrderOf z` we have `0 < d ∣ n`.  If `d > 1`, take a prime `q ∣ d`.  Then
`(d / q) • z ≠ 0` (else `d ∣ d / q`, so `d ≤ d / q`, contradicting `d / q < d` for `q > 1`),
while `q • ((d / q) • z) = (q * (d / q)) • z = d • z = 0`, i.e. `(d / q) • z` is nonzero
`q`-torsion — contradicting the hypothesis.  Hence `d = 1` and `z = 0`. -/
theorem eq_zero_of_nsmul_eq_zero_of_torsionFree_at_primes
    {A : Type*} [AddCommGroup A] {n : ℕ} (hn : n ≠ 0)
    (hA : ∀ q, Nat.Prime q → q ∣ n → (∀ a : A, q • a = 0 → a = 0))
    (z : A) (hz : n • z = 0) : z = 0 := by
  have hdvd : addOrderOf z ∣ n := addOrderOf_dvd_iff_nsmul_eq_zero.mpr hz
  have hdne : addOrderOf z ≠ 0 := by
    intro h
    have h0 : (0 : ℕ) ∣ n := by rw [← h]; exact addOrderOf_dvd_iff_nsmul_eq_zero.mpr hz
    exact hn (zero_dvd_iff.mp h0)
  have hdzero : addOrderOf z • z = 0 := addOrderOf_dvd_iff_nsmul_eq_zero.mp (dvd_refl _)
  by_contra hz0
  have hd1 : addOrderOf z ≠ 1 := fun h => hz0 (AddMonoid.addOrderOf_eq_one_iff.mp h)
  obtain ⟨q, hq, hqd⟩ := Nat.exists_prime_and_dvd hd1
  -- `(d / q) • z ≠ 0`, otherwise `d ∣ d / q` and `d ≤ d / q < d`
  have hne : (addOrderOf z / q) • z ≠ 0 := by
    intro hcon
    have hdpos : 0 < addOrderOf z := Nat.pos_of_ne_zero hdne
    have hdgt : 0 < addOrderOf z / q := by
      rcases Nat.eq_zero_or_pos (addOrderOf z / q) with h | h
      · exfalso
        apply hdne
        have hm := Nat.mul_div_cancel' hqd
        rw [h, mul_zero] at hm
        exact hm.symm
      · exact h
    have h1 : addOrderOf z ∣ addOrderOf z / q := addOrderOf_dvd_iff_nsmul_eq_zero.mpr hcon
    have h2 : addOrderOf z ≤ addOrderOf z / q := Nat.le_of_dvd hdgt h1
    have h3 : addOrderOf z / q < addOrderOf z :=
      Nat.div_lt_self hdpos (Nat.Prime.one_lt hq)
    omega
  -- … but it *is* `q`-torsion, contradiction
  have hqt : q • ((addOrderOf z / q) • z) = 0 := by
    rw [← mul_nsmul' z q (addOrderOf z / q), Nat.mul_div_cancel' hqd, hdzero]
  exact hne (hA q hq (hqd.trans hdvd) ((addOrderOf z / q) • z) hqt)

/-- **T2' — the ECDSA shape, repaired.**  If `A` has no `q`-torsion for every prime `q ≠ p`
(the situation for a subgroup of a pro-`p` group such as `p·ℤ_p ⊆ ℚ_p`, and a fortiori for
any additively torsion-free `A`), then no homomorphism moves an element of order prime
to `p`. -/
theorem map_eq_zero_of_finOrder_and_coprime
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (f : G →+ A) (x : G) (hx : IsOfFinAddOrder x) (hcp : Nat.Coprime p (addOrderOf x)) :
    f x = 0 := by
  have hdpos : 0 < addOrderOf x := addOrderOf_pos_iff.mpr hx
  have hqp : ∀ q, Nat.Prime q → q ∣ addOrderOf x → q ≠ p := by
    intro q hq hqd h
    subst h
    exact Nat.not_coprime_of_dvd_of_dvd (Nat.Prime.one_lt hq) (dvd_refl q) hqd hcp
  have hdzero : addOrderOf x • x = 0 := addOrderOf_dvd_iff_nsmul_eq_zero.mp (dvd_refl _)
  refine eq_zero_of_nsmul_eq_zero_of_torsionFree_at_primes (n := addOrderOf x) (by omega)
    (fun q hq hqd => hA q hq (hqp q hq hqd)) (f x) ?_
  rw [← AddMonoidHom.map_nsmul f x (addOrderOf x), hdzero, map_zero]

/-- **T2' without the `IsOfFinAddOrder` witness**: useful when the source is only known to
have `n • x = 0` with `n` prime to `p` and `A` torsion-free away from `p`. -/
theorem map_eq_zero_of_coprime_period
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (f : G →+ A) (x : G) {n : ℕ} (hn : n ≠ 0) (hx : n • x = 0) (hcp : Nat.Coprime p n) :
    f x = 0 :=
  map_eq_zero_of_finOrder_and_coprime p hA f x (isOfFinAddOrder_of_nsmul_eq_zero hn x hx)
    (Nat.Coprime.coprime_dvd_right (addOrderOf_dvd_iff_nsmul_eq_zero.mpr hx) hcp)

/-! ## T3 — the finite-group version (the `#E(F_p)` shape) -/

/-- **T3.** For a finite group `G` whose order is coprime to `p`, and a target `A` with no
`q`-torsion for `q ≠ p`, every homomorphism `G →+ A` is the zero map. -/
theorem hom_eq_zero_of_coprime_card
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (hcp : Nat.Coprime p (Fintype.card G)) (f : G →+ A) : f = 0 := by
  have hcard : 0 < Fintype.card G := Fintype.card_pos
  ext x
  have hcx : Fintype.card G • x = 0 :=
    addOrderOf_dvd_iff_nsmul_eq_zero.mp (addOrderOf_dvd_card (x := x))
  refine map_eq_zero_of_coprime_period (n := Fintype.card G) p hA f x
    (by exact_mod_cast hcard.ne') hcx hcp

/-- **T3 for an additively torsion-free target** (the shape used by the `p`-adic
logarithm: its target lives inside `ℚ_p`, which is torsion-free).  This is the statement that
kills the claimed `t ≠ 1` generalisation of Smart/SAS.

Note that the coprimality hypothesis is only needed because we pass through the sharp T2'
route here: `IsAddTorsionFree A` gives "no `q`-torsion" for *every* `q ≠ 0`, so T1 alone
already annihilates every element of finite order.  The version with no `p` at all is
`hom_from_finOrder_to_IsAddTorsionFree_eq_zero`. -/
theorem hom_eq_zero_of_coprime_card_torsionFree
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (p : ℕ) (hcp : Nat.Coprime p (Fintype.card G)) (f : G →+ A) : f = 0 := by
  have hcard : 0 < Fintype.card G := Fintype.card_pos
  ext x
  have hcx : Fintype.card G • x = 0 :=
    addOrderOf_dvd_iff_nsmul_eq_zero.mp (addOrderOf_dvd_card (x := x))
  refine map_eq_zero_of_coprime_period (n := Fintype.card G) p
    (fun q hq _ a => (nsmul_eq_zero_iff_right (Nat.Prime.ne_zero hq)).mp) f x
    (by exact_mod_cast hcard.ne') hcx hcp

/-! ## The arithmetic bridge: `#E(F_p) = p + 1 − t` and when it is prime to `p`

With `#E = p + 1 − t`, the anomalous case is `t = 1`, giving `#E = p`.  (The brief writes
"`t = 0` ⇒ `#E = p`", which is off by one: `t = 0` gives `#E = p + 1`, already coprime to
`p`.)  For prime `p` and `1 ≤ t < p`, `p ∣ #E` holds exactly when `t = 1`.
-/

/-- For prime `p` and `2 ≤ t < p`, the order `p + 1 − t` is prime to `p`. -/
theorem card_coprime_of_trace_ne_one (p t : ℕ) (hp : Nat.Prime p) (ht : 2 ≤ t) (ht2 : t < p) :
    Nat.Coprime p (p + 1 - t) := by
  rw [Nat.Prime.coprime_iff_not_dvd hp]
  intro hdvd
  have h1 : 0 < p + 1 - t := by omega
  have h2 : p ≤ p + 1 - t := Nat.le_of_dvd h1 hdvd
  omega

/-- For prime `p` and `1 ≤ t < p`, `p ∣ p + 1 − t` iff `t = 1` (the anomalous case). -/
theorem p_divides_card_iff_trace_eq_one (p t : ℕ) (hp : Nat.Prime p) (ht : 1 ≤ t) (ht2 : t < p) :
    p ∣ p + 1 - t ↔ t = 1 := by
  have hp0 : 0 < p := Nat.Prime.pos hp
  constructor
  · intro hdvd
    have h1 : 0 < p + 1 - t := by omega
    have h2 : p ≤ p + 1 - t := Nat.le_of_dvd h1 hdvd
    by_contra hne
    have ht3 : 2 ≤ t := by omega
    omega
  · intro ht1
    subst ht1
    simp

/-- **The ECDSA shape.**  Let `G` be a finite additive group of order `p + 1 − t` with `p`
prime and `2 ≤ t < p` — e.g. `G = E(F_p)` for a curve with trace `t ≠ 1` — and let `A` be
additively torsion-free.  Then every homomorphism `G →+ A` is zero: the `p`-adic logarithm,
which is a homomorphism only on the (torsion-free) formal group, cannot compute logarithms on
such a curve.  The obstruction is structural, not a matter of cost. -/
theorem only_zero_hom_of_curve_order
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (p t : ℕ) (hp : Nat.Prime p) (ht : 2 ≤ t) (ht2 : t < p) (hcard : Fintype.card G = p + 1 - t)
    (f : G →+ A) : f = 0 :=
  hom_eq_zero_of_coprime_card_torsionFree p
    (by rw [hcard]; exact card_coprime_of_trace_ne_one p t hp ht ht2) f

/-! ## The literal "T2" of the brief is false -/

/-- `ZMod 2` has no `3`-torsion: `3 • a = a`. -/
theorem zmod_two_no_three_torsion : ∀ a : ZMod 2, 3 • a = 0 → a = 0 := by decide

/-- **The literal "T2" of the brief is false.**  It reads: "if `A` has no `p`-torsion in the
sense `(∀ a : A, p • a = 0 → a = 0)` and `x : G` has order prime to `p`, then `f x = 0`".
Take `p = 3`, `G = A = ZMod 2`, `x = 1`, `f = id`.  Then `ZMod 2` has no `3`-torsion
(`zmod_two_no_three_torsion`), `addOrderOf 1 = 2` is prime to `3` (`ZMod.addOrderOf_one`),
yet `f 1 = 1 ≠ 0`.  The repaired statement is `map_eq_zero_of_finOrder_and_coprime`. -/
theorem brief_T2_is_false :
    ¬ (∀ (p : ℕ) (G : Type) [AddCommGroup G] (A : Type) [AddCommGroup A],
        (∀ a : A, p • a = 0 → a = 0) →
        ∀ x : G, Nat.Coprime p (addOrderOf x) → ∀ f : G →+ A, f x = 0) := by
  intro h
  have hkey : (AddMonoidHom.id (M := ZMod 2)) (1 : ZMod 2) = 0 :=
    h 3 (ZMod 2) (ZMod 2) zmod_two_no_three_torsion 1
      (by rw [ZMod.addOrderOf_one 2]; decide)
      (AddMonoidHom.id (M := ZMod 2))
  exact absurd hkey (by decide)

/-! ## Positive controls -/

/-- **Positive control for the "target must be torsion-free" hypothesis.**  `ZMod 4 →+ ZMod 4`
has a nonzero element, so T1's conclusion genuinely fails without `IsAddTorsionFree`. -/
theorem nonzero_hom_ZMod4_self : ∃ f : ZMod 4 →+ ZMod 4, f 1 ≠ 0 :=
  ⟨AddMonoidHom.id (M := ZMod 4), by decide⟩

/-- **Positive control for the "order coprime to `p`" hypothesis.**  With `p = 2` and
`Fintype.card (ZMod 4) = 4` the hypothesis `Nat.Coprime 2 4` *fails*, and indeed there is a
nonzero homomorphism `ZMod 4 →+ ZMod 2`.  (Note `ZMod 2` has no `q`-torsion for `q ≠ 2`, so
T2' legitimately does not apply either.) -/
theorem nonzero_hom_ZMod4_ZMod2 : ∃ f : ZMod 4 →+ ZMod 2, f 1 ≠ 0 :=
  ⟨(ZMod.castHom (by decide : (2 : ℕ) ∣ 4) (ZMod 2) : ZMod 4 →+ ZMod 2), by decide⟩

/-- **Positive control for the "source must have finite order coprime to `p`" hypothesis.**
No homomorphism `ZMod 4 →+ ℚ` is nonzero — `ℚ` is additively torsion-free and every element of
`ZMod 4` is killed by `4`.  This is T1 doing its job on a concrete instance. -/
theorem hom_ZMod4_rat_eq_zero (f : ZMod 4 →+ ℚ) (x : ZMod 4) : f x = 0 := by
  refine map_eq_zero_of_nsmul_eq_zero (n := 4) f x (by decide) ?_
  have h := addOrderOf_dvd_card (x := (x : ZMod 4))
  rw [ZMod.card 4] at h
  exact addOrderOf_dvd_iff_nsmul_eq_zero.mp h

/-- The same control obtained through the sharp T2' route, with `p = 3` prime to `4`. -/
theorem hom_ZMod4_rat_eq_zero_via_sharp (f : ZMod 4 →+ ℚ) : f = 0 :=
  hom_eq_zero_of_coprime_card (G := ZMod 4) 3
    (fun q hq _ a h => (nsmul_eq_zero_iff_right (Nat.Prime.ne_zero hq)).mp h)
    (by decide : Nat.Coprime 3 4) f

/-- The additive orders used in the positive controls. -/
theorem addOrderOf_one_zmod4 : addOrderOf (1 : ZMod 4) = 4 := ZMod.addOrderOf_one 4
theorem addOrderOf_one_zmod2 : addOrderOf (1 : ZMod 2) = 2 := ZMod.addOrderOf_one 2

/-- Brute-force additive order of `k` in `ZMod n`: the least positive `m` with `n ∣ k * m`.
`#eval`-able, unlike Mathlib's `addOrderOf`, which is `noncomputable`. -/
def zmodOrder (n k : ℕ) : ℕ :=
  ((List.range (n + 1)).find? fun m => 0 < m && (k * m) % n == 0).getD 0

/-- `zmodOrder` really is the additive order on `ZMod 4` — checked by computation, while
`addOrderOf` is `noncomputable` and cannot be `#eval`ed. -/
example : zmodOrder 4 1 = 4 := by decide
example : zmodOrder 4 2 = 2 := by decide
example : zmodOrder 4 3 = 4 := by decide
example : zmodOrder 2 1 = 2 := by decide

#eval zmodOrder 4 1  -- expect 4
#eval zmodOrder 4 2  -- expect 2
#eval zmodOrder 4 3  -- expect 4
#eval zmodOrder 4 0  -- expect 1
#eval zmodOrder 2 1  -- expect 2  (the element that refutes the brief's T2)

-- the "target is torsion-free" control, computed
#eval 3 • (1 : ZMod 2)  -- expect 1  (nonzero: `ZMod 2` has no 3-torsion)
#eval 2 • (1 : ZMod 2)  -- expect 0
#eval (1 : ZMod 4) + (1 : ZMod 4)  -- expect 2  (a nonzero image under `id`)

-- coprimality table for `#E = p + 1 - t`: the value of `#E` is prime to `p` unless `t = 1`
#eval (decide (Nat.Coprime 3 4), decide (Nat.Coprime 2 4))  -- (true, false)
#eval (7 + 1 - 2, Nat.gcd 7 (7 + 1 - 2), decide (Nat.Coprime 7 (7 + 1 - 2)))  -- t = 2
#eval (7 + 1 - 1, Nat.gcd 7 (7 + 1 - 1), decide (Nat.Coprime 7 (7 + 1 - 1)))  -- t = 1 : anomalous
#eval (7 + 1 - 0, Nat.gcd 7 (7 + 1 - 0), decide (Nat.Coprime 7 (7 + 1 - 0)))  -- t = 0
#eval (11 + 1 - 2, Nat.gcd 11 (11 + 1 - 2), decide (Nat.Coprime 11 (11 + 1 - 2)))
#eval (11 + 1 - 1, Nat.gcd 11 (11 + 1 - 1), decide (Nat.Coprime 11 (11 + 1 - 1)))

/-! ## Verification: the theorems above depend on no extra axioms and contain no `sorry` -/

#print axioms hom_from_finOrder_to_IsAddTorsionFree_eq_zero
#print axioms hom_from_finOrder_to_IsAddTorsionFree_eq_zero_mul
#print axioms map_eq_zero_of_nsmul_eq_zero
#print axioms eq_zero_of_nsmul_eq_zero_of_torsionFree_at_primes
#print axioms map_eq_zero_of_finOrder_and_coprime
#print axioms map_eq_zero_of_coprime_period
#print axioms hom_eq_zero_of_coprime_card
#print axioms hom_eq_zero_of_coprime_card_torsionFree
#print axioms card_coprime_of_trace_ne_one
#print axioms p_divides_card_iff_trace_eq_one
#print axioms only_zero_hom_of_curve_order
#print axioms brief_T2_is_false
#print axioms nonzero_hom_ZMod4_self
#print axioms nonzero_hom_ZMod4_ZMod2
#print axioms hom_ZMod4_rat_eq_zero
#print axioms hom_ZMod4_rat_eq_zero_via_sharp

end PadicTorsionObstruction
