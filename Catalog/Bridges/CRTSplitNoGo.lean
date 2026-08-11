import Mathlib

/-!
# The CRT-Split No-Go, Part I: the reveal mechanism

This file formalises the two structural facts underlying the claim that no classical
iteration built from `N` alone can factor `N = p * q` in `poly(log N)` steps.

* **Fact 1 (CRT-split collision is the only reveal mechanism).**
  For `N = p * q` with `p ≠ q` prime and any integer `d`,
  `gcd d N` is a *nontrivial* divisor of `N` if and only if **exactly one** of
  `p ∣ d`, `q ∣ d` holds (`crt_reveal_iff`).  Applied to `d = x t - x s` along a
  trajectory this says: a factor appears exactly when two trajectory values agree
  on **one** CRT component.

* **Fact 2 (`N`-explicit maps do not split the CRT).**
  An `N`-explicit map is a polynomial with integer coefficients (ring operations and
  constants manufactured from the digits of `N`).  Its orbit reduced mod `p` is the
  orbit of the *reduced* polynomial started at the *reduced* seed
  (`polyOrbit_cast`, `modOrbit_congr`): the mod-`p` dynamics depends on nothing
  except `f mod p` and `x₀ mod p`.  In particular the map itself carries no
  information about which of the two CRT components it is being run in.

* **Consequence.** The factor-revealing event in any such iteration is *exactly* an
  exclusive mod-`p` / mod-`q` cycle closure (`reveal_iff_xor_closure`), and no reveal
  can happen before the first closure (`no_reveal_before_closure`).  Closures do
  exist, but the only unconditional guarantee is the pigeonhole bound `t ≤ p`
  (`exists_closure_le`), and after a closure the orbit is eventually periodic
  (`modOrbit_eventually_periodic`) — the rho shape.

Quantitative lower bounds for the three regimes are in `CRTSplitNoGoBounds.lean`.
-/

namespace CRTSplitNoGo

open Polynomial

/-! ## Fact 1: a nontrivial gcd is exactly an exclusive CRT collision -/

/-- `d` reveals a nontrivial factor of `N`: `gcd d N` is neither `1` nor `N`. -/
def RevealsFactor (N : ℕ) (d : ℤ) : Prop :=
  1 < Int.gcd d (N : ℤ) ∧ Int.gcd d (N : ℤ) < N

/-- For a divisor `r` of `N`, `r` divides `gcd d N` iff `r` divides `d`. -/
lemma dvd_gcd_iff_of_dvd {N : ℕ} {d : ℤ} {r : ℕ} (hrN : r ∣ N) :
    r ∣ Int.gcd d (N : ℤ) ↔ (r : ℤ) ∣ d := by
  constructor
  · intro h
    have : ((r : ℕ) : ℤ) ∣ ((Int.gcd d (N : ℤ) : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr h
    exact this.trans (Int.gcd_dvd_left d (N : ℤ))
  · intro h
    have hrN' : (r : ℤ) ∣ (N : ℤ) := Int.natCast_dvd_natCast.mpr hrN
    exact Int.dvd_gcd h hrN'

/-- **Fact 1.**  With `N = p * q` a product of two distinct primes, `d` reveals a
nontrivial factor of `N` if and only if exactly one of `p`, `q` divides `d`. -/
theorem crt_reveal_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) (d : ℤ) :
    RevealsFactor (p * q) d ↔ Xor' ((p : ℤ) ∣ d) ((q : ℤ) ∣ d) := by
  have hppos : 0 < p := hp.pos
  have hqpos : 0 < q := hq.pos
  have hNpos : 0 < p * q := Nat.mul_pos hppos hqpos
  set g : ℕ := Int.gcd d ((p * q : ℕ) : ℤ) with hg
  have hgN : g ∣ p * q := by
    have : ((g : ℕ) : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right d ((p * q : ℕ) : ℤ)
    exact Int.ofNat_dvd.mp this
  have hgle : g ≤ p * q := Nat.le_of_dvd hNpos hgN
  have hpdvdN : p ∣ p * q := Dvd.intro q rfl
  have hqdvdN : q ∣ p * q := Dvd.intro_left p rfl
  have hP : p ∣ g ↔ (p : ℤ) ∣ d := dvd_gcd_iff_of_dvd hpdvdN
  have hQ : q ∣ g ↔ (q : ℤ) ∣ d := dvd_gcd_iff_of_dvd hqdvdN
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  rw [← hP, ← hQ]
  constructor
  · rintro ⟨h1, h2⟩
    by_cases hpg : p ∣ g
    · refine Or.inl ⟨hpg, ?_⟩
      intro hqg
      have : p * q ∣ g := hcop.mul_dvd_of_dvd_of_dvd hpg hqg
      have := Nat.le_of_dvd (by omega) this
      omega
    · by_cases hqg : q ∣ g
      · exact Or.inr ⟨hqg, hpg⟩
      · -- neither prime divides `g`, so `g` is coprime to `N` and hence `g = 1`
        exfalso
        have hcp : Nat.Coprime g p := (Nat.coprime_comm.mp ((Nat.Prime.coprime_iff_not_dvd hp).mpr hpg))
        have hcq : Nat.Coprime g q := (Nat.coprime_comm.mp ((Nat.Prime.coprime_iff_not_dvd hq).mpr hqg))
        have : Nat.Coprime g (p * q) := Nat.Coprime.mul_right hcp hcq
        have hg1 : g = 1 := this.eq_one_of_dvd hgN
        omega
  · intro h
    rcases h with ⟨hpg, hqg⟩ | ⟨hqg, hpg⟩
    · have hgpos : 0 < g := by
        rcases Nat.eq_zero_or_pos g with h0 | h0
        · exfalso; rw [h0] at hgN; exact absurd (Nat.eq_zero_of_zero_dvd hgN) (by omega)
        · exact h0
      have h1 : 1 < g := lt_of_lt_of_le hp.one_lt (Nat.le_of_dvd hgpos hpg)
      refine ⟨h1, ?_⟩
      rcases lt_or_eq_of_le hgle with h | h
      · exact h
      · exact absurd (h ▸ hqdvdN) hqg
    · have hgpos : 0 < g := by
        rcases Nat.eq_zero_or_pos g with h0 | h0
        · exfalso; rw [h0] at hgN; exact absurd (Nat.eq_zero_of_zero_dvd hgN) (by omega)
        · exact h0
      have h1 : 1 < g := lt_of_lt_of_le hq.one_lt (Nat.le_of_dvd hgpos hqg)
      refine ⟨h1, ?_⟩
      rcases lt_or_eq_of_le hgle with h | h
      · exact h
      · exact absurd (h ▸ hpdvdN) hpg

/-! ## Fact 2: an `N`-explicit map is functorial for reduction mod `p` -/

/-- The orbit of the seed `x₀` under the integer polynomial map `f`. -/
def polyOrbit (f : ℤ[X]) (x0 : ℤ) (n : ℕ) : ℤ := (fun z => f.eval z)^[n] x0

@[simp] lemma polyOrbit_zero (f : ℤ[X]) (x0 : ℤ) : polyOrbit f x0 0 = x0 := rfl

lemma polyOrbit_succ (f : ℤ[X]) (x0 : ℤ) (n : ℕ) :
    polyOrbit f x0 (n + 1) = f.eval (polyOrbit f x0 n) := by
  simp [polyOrbit, Function.iterate_succ_apply']

/-- The orbit of the reduced seed under the reduced polynomial map, in `ZMod m`. -/
noncomputable def modOrbit (f : ℤ[X]) (m : ℕ) (x0 : ℤ) (n : ℕ) : ZMod m :=
  (fun z => (f.map (Int.castRingHom (ZMod m))).eval z)^[n] ((x0 : ℤ) : ZMod m)

lemma modOrbit_succ (f : ℤ[X]) (m : ℕ) (x0 : ℤ) (n : ℕ) :
    modOrbit f m x0 (n + 1) =
      (f.map (Int.castRingHom (ZMod m))).eval (modOrbit f m x0 n) := by
  simp [modOrbit, Function.iterate_succ_apply']

/-- **Fact 2 (functoriality).** Reducing the integer orbit mod `m` gives the orbit of the
reduced polynomial: the mod-`m` dynamics is computed entirely inside `ZMod m`. -/
theorem polyOrbit_cast (f : ℤ[X]) (m : ℕ) (x0 : ℤ) (n : ℕ) :
    ((polyOrbit f x0 n : ℤ) : ZMod m) = modOrbit f m x0 n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [polyOrbit_succ, modOrbit_succ, ← ih]
      simp [Polynomial.eval_map]

/-- **Fact 2 (blindness).** The mod-`m` orbit depends only on the reduction of the map and
of the seed: two `N`-explicit maps whose coefficients agree mod `m`, started at seeds
congruent mod `m`, have identical mod-`m` orbits.  A map "built from `N`" therefore
cannot behave differently in the two CRT components. -/
theorem modOrbit_congr {f g : ℤ[X]} {m : ℕ} {x0 y0 : ℤ}
    (hfg : f.map (Int.castRingHom (ZMod m)) = g.map (Int.castRingHom (ZMod m)))
    (hxy : ((x0 : ℤ) : ZMod m) = ((y0 : ℤ) : ZMod m)) (n : ℕ) :
    modOrbit f m x0 n = modOrbit g m y0 n := by
  unfold modOrbit
  rw [hfg, hxy]

/-- Congruent seeds give congruent trajectories: the classical "no CRT split" statement
in divisibility form. -/
theorem dvd_sub_polyOrbit_of_dvd_sub (f : ℤ[X]) (m : ℤ) {x0 y0 : ℤ} (h : m ∣ x0 - y0) (n : ℕ) :
    m ∣ polyOrbit f x0 n - polyOrbit f y0 n := by
  induction n with
  | zero => simpa using h
  | succ n ih =>
      rw [polyOrbit_succ, polyOrbit_succ]
      exact ih.trans (Polynomial.sub_dvd_eval_sub _ _ f)

/-! ## Consequence: the reveal event is an exclusive mod-`p` cycle closure -/

lemma intCast_sub_eq_zero_iff (m : ℕ) (a b : ℤ) :
    ((a : ZMod m) = (b : ZMod m)) ↔ (m : ℤ) ∣ a - b := by
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd (a - b) m, Int.cast_sub, sub_eq_zero]

/-- **The reveal characterisation.**  Along the orbit of *any* integer polynomial map,
`gcd (x t - x s) N` is a nontrivial factor of `N = p * q` if and only if the mod-`p` orbit
closes up between times `s` and `t` **exclusive-or** the mod-`q` orbit does. -/
theorem reveal_iff_xor_closure {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) (s t : ℕ) :
    RevealsFactor (p * q) (polyOrbit f x0 t - polyOrbit f x0 s) ↔
      Xor' (modOrbit f p x0 t = modOrbit f p x0 s)
           (modOrbit f q x0 t = modOrbit f q x0 s) := by
  rw [crt_reveal_iff hp hq hne]
  rw [← intCast_sub_eq_zero_iff p, ← intCast_sub_eq_zero_iff q,
    polyOrbit_cast, polyOrbit_cast, polyOrbit_cast, polyOrbit_cast]

/-- No factor can be revealed before one of the two reduced orbits closes up. -/
theorem no_reveal_before_closure {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) (T : ℕ)
    (hpinj : ∀ s t, s < t → t ≤ T → modOrbit f p x0 t ≠ modOrbit f p x0 s)
    (hqinj : ∀ s t, s < t → t ≤ T → modOrbit f q x0 t ≠ modOrbit f q x0 s) :
    ∀ s t, s < t → t ≤ T → ¬ RevealsFactor (p * q) (polyOrbit f x0 t - polyOrbit f x0 s) := by
  intro s t hst htT hrev
  rcases (reveal_iff_xor_closure hp hq hne f x0 s t).mp hrev with ⟨h, -⟩ | ⟨h, -⟩
  · exact hpinj s t hst htT h
  · exact hqinj s t hst htT h

/-! ## The rho shape: closures exist, but pigeonhole only gives `t ≤ p` -/

/-- Pigeonhole: the mod-`p` orbit of any integer polynomial map closes up within `p` steps. -/
theorem exists_closure_le (f : ℤ[X]) (m : ℕ) [NeZero m] (x0 : ℤ) :
    ∃ s t, s < t ∧ t ≤ m ∧ modOrbit f m x0 t = modOrbit f m x0 s := by
  have hcard : Fintype.card (ZMod m) < Fintype.card (Fin (m + 1)) := by
    simp [ZMod.card m]
  obtain ⟨i, j, hij, hval⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (m + 1) => modOrbit f m x0 (i : ℕ)) hcard
  have hi := i.isLt
  have hj := j.isLt
  rcases lt_or_gt_of_ne (fun h : (i : ℕ) = (j : ℕ) => hij (Fin.ext h)) with h | h
  · exact ⟨i, j, h, by omega, hval.symm⟩
  · exact ⟨j, i, h, by omega, hval⟩

/-- After a closure at `(s, t)` the reduced orbit is periodic with period `t - s` from time
`s` on: the classical "rho" shape (tail of length `s`, cycle of length `t - s`). -/
theorem modOrbit_eventually_periodic (f : ℤ[X]) (m : ℕ) (x0 : ℤ) {s t : ℕ} (hst : s ≤ t)
    (h : modOrbit f m x0 t = modOrbit f m x0 s) (n : ℕ) (hn : s ≤ n) :
    modOrbit f m x0 (n + (t - s)) = modOrbit f m x0 n := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hn
  set F : ZMod m → ZMod m := fun z => (f.map (Int.castRingHom (ZMod m))).eval z with hF
  have key : ∀ j : ℕ, modOrbit f m x0 j = F^[j] ((x0 : ℤ) : ZMod m) := fun j => rfl
  simp only [key] at h ⊢
  have h1 : s + k + (t - s) = k + t := by omega
  rw [h1, Function.iterate_add_apply, h, ← Function.iterate_add_apply, Nat.add_comm]

end CRTSplitNoGo