import Bridges.CRTSplitNoGoAverageUpper

/-!
# The CRT-Split No-Go, Part X: the straight-line rigidity dichotomy

Parts I–II proved Fact 2 for *polynomial* maps.  Conjecture A of the previous cycle asked for
the general form: let `F` be any function computed by a straight-line program over `ZMod N`
with the operations `+`, `−`, `×`, division, and constants read off `N`.  Then either `F` is
CRT-blind — the same program computes both reduced components, so no information about the
splitting `N = p q` is produced — or the program hits, at some intermediate node, a value that
is **not invertible mod `N`**, and such a value either vanishes or *is* a factorisation.

This file proves that dichotomy.

## The formalisation

`SLE` is the type of straight-line expressions in one variable: a variable node, integer
constants (the "digits of `N`" of the informal statement — any integers at all, so the theorem
is stronger), the ring operations, and an inversion node.  `SLE.eval` interprets an expression
in an arbitrary commutative ring, an inversion node being `Ring.inverse` (which returns `0` on
a non-unit).  `SLE.AllUnits e x` says that every inversion node of `e` is applied to a unit at
input `x`; `SLE.DivFree e` says there is no inversion node at all.

## Main results

* `SLE.eval_hom` — **CRT-blindness.**  If all inversions succeed, evaluation commutes with any
  ring homomorphism: `φ (eval e x) = eval e (φ x)`.  `SLE.eval_hom_of_divFree` is the
  division-free case, where no hypothesis is needed.
* `SLE.toPoly` / `SLE.eval_toPoly` — a division-free program is literally an integer
  polynomial, so every theorem of Parts I–V applies to it verbatim
  (`slp_reveal_iff_xor_closure`).
* `slpOrbit_crt` — the orbit of an `SLE`-iteration in `ZMod (p q)` maps, under the Chinese
  remainder isomorphism, to the pair of orbits of *the same* program in `ZMod p` and `ZMod q`.
  This is the exact sense in which an `N`-explicit map "does not split the CRT".
* `nonunit_reveals` — **the escape is a factorisation.**  A value of `ZMod N` that is neither
  zero nor a unit yields `RevealsFactor N`.
* `sle_dichotomy` — the two together: for every straight-line program and every input, either
  the computation is CRT-blind, or some intermediate value hands you a nontrivial factor of `N`
  (or is zero).  Escaping polynomiality by dividing therefore *presupposes* the factorisation:
  this is barrier 6 (circularity), now for arbitrary straight-line programs rather than for
  idempotents alone.
-/

namespace CRTSplitNoGo

/-! ## Straight-line expressions -/

/-- A straight-line expression in one variable: constants, the ring operations, and
inversion. -/
inductive SLE : Type
  | var : SLE
  | const : ℤ → SLE
  | add : SLE → SLE → SLE
  | sub : SLE → SLE → SLE
  | mul : SLE → SLE → SLE
  | inv : SLE → SLE
  deriving DecidableEq

namespace SLE

/-- Interpretation of a straight-line expression in a commutative ring; an inversion node is
`Ring.inverse`, which is the true inverse on units and `0` elsewhere. -/
noncomputable def eval {R : Type*} [CommRing R] : SLE → R → R
  | var, x => x
  | const c, _ => (c : R)
  | add a b, x => eval a x + eval b x
  | sub a b, x => eval a x - eval b x
  | mul a b, x => eval a x * eval b x
  | inv a, x => Ring.inverse (eval a x)

/-- Every inversion node of the expression is applied to a unit at the given input. -/
def AllUnits {R : Type*} [CommRing R] : SLE → R → Prop
  | var, _ => True
  | const _, _ => True
  | add a b, x => AllUnits a x ∧ AllUnits b x
  | sub a b, x => AllUnits a x ∧ AllUnits b x
  | mul a b, x => AllUnits a x ∧ AllUnits b x
  | inv a, x => AllUnits a x ∧ IsUnit (eval a x)

/-- The expression contains no inversion node. -/
def DivFree : SLE → Prop
  | var => True
  | const _ => True
  | add a b => DivFree a ∧ DivFree b
  | sub a b => DivFree a ∧ DivFree b
  | mul a b => DivFree a ∧ DivFree b
  | inv _ => False

/-- If some inversion fails, the program exhibits a non-unit as the value of a subexpression. -/
lemma exists_nonunit_of_not_allUnits {R : Type*} [CommRing R] :
    ∀ (e : SLE) (x : R), ¬ AllUnits e x → ∃ a : SLE, ¬ IsUnit (eval a x)
  | var, _, h => absurd trivial h
  | const _, _, h => absurd trivial h
  | add a b, x, h => by
      by_cases ha : AllUnits a x
      · exact exists_nonunit_of_not_allUnits b x (fun hb => h ⟨ha, hb⟩)
      · exact exists_nonunit_of_not_allUnits a x ha
  | sub a b, x, h => by
      by_cases ha : AllUnits a x
      · exact exists_nonunit_of_not_allUnits b x (fun hb => h ⟨ha, hb⟩)
      · exact exists_nonunit_of_not_allUnits a x ha
  | mul a b, x, h => by
      by_cases ha : AllUnits a x
      · exact exists_nonunit_of_not_allUnits b x (fun hb => h ⟨ha, hb⟩)
      · exact exists_nonunit_of_not_allUnits a x ha
  | inv a, x, h => by
      by_cases ha : AllUnits a x
      · exact ⟨a, fun hu => h ⟨ha, hu⟩⟩
      · exact exists_nonunit_of_not_allUnits a x ha

lemma allUnits_of_divFree {R : Type*} [CommRing R] :
    ∀ (e : SLE) (x : R), DivFree e → AllUnits e x
  | var, _, _ => trivial
  | const _, _, _ => trivial
  | add a b, x, h => ⟨allUnits_of_divFree a x h.1, allUnits_of_divFree b x h.2⟩
  | sub a b, x, h => ⟨allUnits_of_divFree a x h.1, allUnits_of_divFree b x h.2⟩
  | mul a b, x, h => ⟨allUnits_of_divFree a x h.1, allUnits_of_divFree b x h.2⟩
  | inv _, _, h => absurd h (by simp [DivFree])

/-! ## Ring homomorphisms commute with successful straight-line computation -/

/-- A ring homomorphism commutes with `Ring.inverse` at units. -/
lemma map_inverse_of_isUnit {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) {u : R}
    (hu : IsUnit u) : φ (Ring.inverse u) = Ring.inverse (φ u) := by
  have hfu : IsUnit (φ u) := hu.map φ
  have h1 : φ (Ring.inverse u) * φ u = 1 := by
    rw [← map_mul, Ring.inverse_mul_cancel u hu, map_one]
  have h2 : φ u * Ring.inverse (φ u) = 1 := Ring.mul_inverse_cancel _ hfu
  calc φ (Ring.inverse u) = φ (Ring.inverse u) * (φ u * Ring.inverse (φ u)) := by rw [h2, mul_one]
    _ = (φ (Ring.inverse u) * φ u) * Ring.inverse (φ u) := by ring
    _ = Ring.inverse (φ u) := by rw [h1, one_mul]

/-- **CRT-blindness of straight-line programs.**  If every inversion of the program succeeds at
the input `x`, then evaluation commutes with an arbitrary ring homomorphism: the reduced value
is computed by *the same* program applied to the reduced input.  A program built from `N` can
therefore not act differently in the two CRT components of `ZMod N`. -/
theorem eval_hom {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) :
    ∀ (e : SLE) (x : R), AllUnits e x → φ (eval e x) = eval e (φ x)
  | var, x, _ => rfl
  | const c, x, _ => by simp [eval]
  | add a b, x, h => by
      simp only [eval, map_add, eval_hom φ a x h.1, eval_hom φ b x h.2]
  | sub a b, x, h => by
      simp only [eval, map_sub, eval_hom φ a x h.1, eval_hom φ b x h.2]
  | mul a b, x, h => by
      simp only [eval, map_mul, eval_hom φ a x h.1, eval_hom φ b x h.2]
  | inv a, x, h => by
      simp only [eval]
      rw [map_inverse_of_isUnit φ h.2, eval_hom φ a x h.1]

/-- The division-free case of `eval_hom`: no hypothesis at all. -/
theorem eval_hom_of_divFree {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) (e : SLE)
    (he : DivFree e) (x : R) : φ (eval e x) = eval e (φ x) :=
  eval_hom φ e x (allUnits_of_divFree e x he)

/-! ## Division-free programs are exactly polynomials -/

open Polynomial

/-- The integer polynomial computed by a division-free straight-line expression. -/
noncomputable def toPoly : SLE → ℤ[X]
  | var => X
  | const c => C c
  | add a b => toPoly a + toPoly b
  | sub a b => toPoly a - toPoly b
  | mul a b => toPoly a * toPoly b
  | inv _ => 0

/-- A division-free program computes its polynomial. -/
theorem eval_toPoly : ∀ (e : SLE), DivFree e → ∀ x : ℤ, (toPoly e).eval x = eval e x
  | var, _, x => by simp [toPoly, eval]
  | const c, _, x => by simp [toPoly, eval]
  | add a b, h, x => by
      simp [toPoly, eval, eval_toPoly a h.1 x, eval_toPoly b h.2 x]
  | sub a b, h, x => by
      simp [toPoly, eval, eval_toPoly a h.1 x, eval_toPoly b h.2 x]
  | mul a b, h, x => by
      simp [toPoly, eval, eval_toPoly a h.1 x, eval_toPoly b h.2 x]
  | inv _, h, _ => absurd h (by simp [DivFree])

end SLE

/-! ## Straight-line iteration -/

/-- The orbit of a straight-line program iterated in a commutative ring. -/
noncomputable def slpOrbit {R : Type*} [CommRing R] (e : SLE) (x0 : R) (n : ℕ) : R :=
  (fun z => SLE.eval e z)^[n] x0

@[simp] lemma slpOrbit_zero {R : Type*} [CommRing R] (e : SLE) (x0 : R) :
    slpOrbit e x0 0 = x0 := rfl

lemma slpOrbit_succ {R : Type*} [CommRing R] (e : SLE) (x0 : R) (n : ℕ) :
    slpOrbit e x0 (n + 1) = SLE.eval e (slpOrbit e x0 n) := by
  simp [slpOrbit, Function.iterate_succ_apply']

/-- A division-free straight-line iteration *is* a polynomial iteration: its orbit over `ℤ`
coincides with `polyOrbit` of the polynomial it computes.  Every theorem of Parts I–V therefore
applies to straight-line programs verbatim. -/
theorem slpOrbit_eq_polyOrbit (e : SLE) (he : SLE.DivFree e) (x0 : ℤ) (n : ℕ) :
    slpOrbit e x0 n = polyOrbit (SLE.toPoly e) x0 n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [slpOrbit_succ, polyOrbit_succ, ih, SLE.eval_toPoly e he]

/-- **Fact 1 for straight-line programs.**  Along the orbit of any division-free straight-line
program, a nontrivial factor of `N = p q` appears in `gcd (x t − x s, N)` exactly at an
exclusive mod-`p` / mod-`q` cycle closure. -/
theorem slp_reveal_iff_xor_closure {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (e : SLE) (he : SLE.DivFree e) (x0 : ℤ) (s t : ℕ) :
    RevealsFactor (p * q) (slpOrbit e x0 t - slpOrbit e x0 s) ↔
      Xor' (modOrbit (SLE.toPoly e) p x0 t = modOrbit (SLE.toPoly e) p x0 s)
           (modOrbit (SLE.toPoly e) q x0 t = modOrbit (SLE.toPoly e) q x0 s) := by
  rw [slpOrbit_eq_polyOrbit e he, slpOrbit_eq_polyOrbit e he]
  exact reveal_iff_xor_closure hp hq hne _ x0 s t

/-- Homomorphic images of a straight-line orbit are orbits of the *same* program, provided
every inversion along the way succeeds. -/
theorem slpOrbit_hom {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) (e : SLE) (x0 : R) :
    ∀ n : ℕ, (∀ k < n, SLE.AllUnits e (slpOrbit e x0 k)) →
      φ (slpOrbit e x0 n) = slpOrbit e (φ x0) n := by
  intro n
  induction n with
  | zero => intro _; rfl
  | succ n ih =>
      intro h
      rw [slpOrbit_succ, slpOrbit_succ, SLE.eval_hom φ e _ (h n (by omega)),
        ih (fun k hk => h k (by omega))]

/-- **The CRT statement.**  For coprime `m₁, m₂` the orbit of a straight-line iteration in
`ZMod (m₁ m₂)` is carried by the Chinese remainder isomorphism to the pair of orbits of the
same program in `ZMod m₁` and `ZMod m₂`.  The two components evolve independently under one and
the same program: nothing in an `N`-explicit iteration distinguishes them, which is Fact 2. -/
theorem slpOrbit_crt {m₁ m₂ : ℕ} (h : Nat.Coprime m₁ m₂) (e : SLE) (x0 : ZMod (m₁ * m₂)) (n : ℕ)
    (hunits : ∀ k < n, SLE.AllUnits e (slpOrbit e x0 k)) :
    (ZMod.chineseRemainder h) (slpOrbit e x0 n)
      = (slpOrbit e ((ZMod.chineseRemainder h) x0).1 n,
         slpOrbit e ((ZMod.chineseRemainder h) x0).2 n) := by
  have h1 : (RingHom.fst (ZMod m₁) (ZMod m₂)).comp
      (ZMod.chineseRemainder h).toRingHom (slpOrbit e x0 n)
      = slpOrbit e (((ZMod.chineseRemainder h) x0).1) n :=
    slpOrbit_hom ((RingHom.fst (ZMod m₁) (ZMod m₂)).comp (ZMod.chineseRemainder h).toRingHom)
      e x0 n hunits
  have h2 : (RingHom.snd (ZMod m₁) (ZMod m₂)).comp
      (ZMod.chineseRemainder h).toRingHom (slpOrbit e x0 n)
      = slpOrbit e (((ZMod.chineseRemainder h) x0).2) n :=
    slpOrbit_hom ((RingHom.snd (ZMod m₁) (ZMod m₂)).comp (ZMod.chineseRemainder h).toRingHom)
      e x0 n hunits
  exact Prod.ext h1 h2

/-! ## The escape from polynomiality is a factorisation -/

/-- **A non-unit is a factorisation.**  If `v : ZMod N` is neither `0` nor invertible then the
integer `v.val` reveals a nontrivial factor of `N`.  Division is thus the only way for a
straight-line program to leave the polynomial world, and it can only do so by producing the
factorisation it was supposed to compute (barrier 6). -/
theorem nonunit_reveals {N : ℕ} (hN : 1 < N) (v : ZMod N) (hv0 : v ≠ 0) (hvu : ¬ IsUnit v) :
    RevealsFactor N (v.val : ℤ) := by
  haveI : NeZero N := ⟨by omega⟩
  have hval_lt : v.val < N := ZMod.val_lt v
  have hval_ne : v.val ≠ 0 := (ZMod.val_ne_zero v).mpr hv0
  have hcast : ((v.val : ℕ) : ZMod N) = v := ZMod.natCast_val v |>.trans (ZMod.cast_id N v)
  have hcop : ¬ Nat.Coprime v.val N := by
    intro hc
    exact hvu (by rw [← hcast]; exact (ZMod.isUnit_iff_coprime v.val N).mpr hc)
  have hgcd : Int.gcd (v.val : ℤ) (N : ℤ) = Nat.gcd v.val N := Int.gcd_natCast_natCast _ _
  refine ⟨?_, ?_⟩
  · rw [hgcd]
    have hne1 : Nat.gcd v.val N ≠ 1 := hcop
    have hpos : 0 < Nat.gcd v.val N := Nat.gcd_pos_of_pos_right _ (by omega)
    omega
  · rw [hgcd]
    have hdvd : Nat.gcd v.val N ∣ v.val := Nat.gcd_dvd_left _ _
    have hle : Nat.gcd v.val N ≤ v.val := Nat.le_of_dvd (by omega) hdvd
    omega

/-- **The straight-line rigidity dichotomy (Conjecture A).**  Fix `N > 1`, a straight-line
program `e` and an input `x` in `ZMod N`.  Then exactly one of the following happens.

* Every inversion of `e` succeeds at `x`.  Then the computation is CRT-blind: it commutes with
  every ring homomorphism out of `ZMod N`, in particular with both CRT projections, so the same
  program computes both components and nothing about the splitting is revealed.
* Some inversion fails, i.e. `e` produces at an intermediate node a value `v` that is not a
  unit.  Then `v = 0` or `v.val` reveals a nontrivial factor of `N`.

There is no third possibility: leaving polynomiality requires dividing, and a failed division
*is* a factorisation. -/
theorem sle_dichotomy {N : ℕ} (hN : 1 < N) (e : SLE) (x : ZMod N) :
    (∀ {S : Type} [CommRing S] (φ : ZMod N →+* S), φ (SLE.eval e x) = SLE.eval e (φ x))
      ∨ ∃ v : ZMod N, ¬ IsUnit v ∧ (v = 0 ∨ RevealsFactor N (v.val : ℤ)) := by
  by_cases h : SLE.AllUnits e x
  · exact Or.inl (fun {S} _ φ => SLE.eval_hom φ e x h)
  · obtain ⟨a, hnu⟩ := SLE.exists_nonunit_of_not_allUnits e x h
    refine Or.inr ⟨SLE.eval a x, hnu, ?_⟩
    by_cases hz : SLE.eval a x = 0
    · exact Or.inl hz
    · exact Or.inr (nonunit_reveals hN _ hz hnu)

/-! ## Instances of the dichotomy on the CTST demo modulus -/

/-- The straight-line program computing the CTST map `x ↦ x² + 1`. -/
def sleSq : SLE := SLE.add (SLE.mul SLE.var SLE.var) (SLE.const 1)

lemma sleSq_divFree : SLE.DivFree sleSq := ⟨⟨trivial, trivial⟩, trivial⟩

lemma sleSq_eval (x : ℤ) : SLE.eval sleSq x = x * x + 1 := by
  simp [sleSq, SLE.eval]

/-- The division-free program `sleSq` and its polynomial agree, and its orbit from the CTST
seed `2` is `2, 5, 26, 677, …` — the trajectory used in Parts I–V. -/
theorem sleSq_orbit_demo :
    slpOrbit sleSq (2 : ℤ) 3 = 677 ∧
      polyOrbit (SLE.toPoly sleSq) (2 : ℤ) 3 = 677 := by
  have h1 : slpOrbit sleSq (2 : ℤ) 3 = 677 := by
    rw [slpOrbit_succ, slpOrbit_succ, slpOrbit_succ]
    simp [sleSq_eval]
  exact ⟨h1, by rw [← slpOrbit_eq_polyOrbit sleSq sleSq_divFree]; exact h1⟩

/-- **A failed division on the demo modulus is the factorisation.**  `631` is a non-unit of
`ZMod 341371`, and an inversion node applied to it reveals the factor `631` of
`341371 = 631 · 541`. -/
theorem nonunit_reveals_demo : RevealsFactor 341371 (631 : ℤ) := by
  constructor <;> norm_num [RevealsFactor, Int.gcd]

end CRTSplitNoGo