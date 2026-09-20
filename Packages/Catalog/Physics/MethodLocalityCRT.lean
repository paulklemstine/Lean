import Mathlib
import Physics.MethodLocalityFactorLocal
import Physics.MethodLocalityNaturality

/-!
# Cycle 4: the two shadows, and when a factor-local run actually reveals the factor

Cycles 1–3 showed that the cost of a natural method modulo `N = p·q` is carried by the
mod-`p` shadow alone.  What the shadow does *not* by itself decide is whether the run
**succeeds**: the gcd taken at a mod-`p` collision is a proper factor only if the same
pair of states does not also collide modulo `q`.  This file resolves that interaction
exactly, for arbitrary state sequences and hence for every uniform method.

* `zmod_eq_of_shadows_eq` — two states modulo `p·q` (coprime factors) are equal as soon
  as both shadows agree: CRT injectivity in the form needed here.
* `seqColl_iff_shadows` — **collision decomposition**: a sequence modulo `p·q` collides
  at time `n` iff both shadows collide at `n` *with a common witness index*.  This is
  the exact converse of the inequality `collTime_map_le` of cycle 2, and it explains why
  the modulus-level collision is generally strictly later than either shadow's.
* `shadow_collTime_le` — each shadow is never slower than the modulus run.
* `val_congr_of_shadow_eq` — a mod-`p` agreement of states is a congruence of their
  integer representatives.
* `reveal_of_shadow_strictly_earlier` — **the success criterion**: whenever the mod-`p`
  shadow collides strictly before the modulus run does, the gcd computed at that
  collision is a nontrivial proper divisor of `N` divisible by `p`.  Combined with
  `MethodLocalityNat.reveal_dichotomy` this closes the loop: factor-local cost *plus* a
  strictly earlier shadow equals a factor, deterministically.
* `success_criterion` — the synthesis for uniform methods.
-/

namespace MethodLocalityCRT

open MethodLocality MethodLocalityNat

/-! ## 1. CRT: the two shadows determine the state -/

/-- Reduction to the first factor. -/
abbrev fstHom (p q : ℕ) : ZMod (p * q) →+* ZMod p := ZMod.castHom (Dvd.intro q rfl) (ZMod p)

/-- Reduction to the second factor. -/
abbrev sndHom (p q : ℕ) : ZMod (p * q) →+* ZMod q := ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)

/-- **CRT injectivity.**  Agreement of both shadows is agreement of the states. -/
theorem zmod_eq_of_shadows_eq {p q : ℕ} (hco : Nat.Coprime p q) {x y : ZMod (p * q)}
    (hp : fstHom p q x = fstHom p q y) (hq : sndHom p q x = sndHom p q y) : x = y := by
  refine (ZMod.chineseRemainder hco).injective ?_
  ext
  · simpa [ZMod.chineseRemainder] using hp
  · simpa [ZMod.chineseRemainder] using hq

/-! ## 2. Collision decomposition -/

/-- **The modulus collides exactly when both shadows collide together.**  Note the
quantifier: a *common* witness index is required, which is why the modulus-level
collision time is in general strictly larger than both shadow times. -/
theorem seqColl_iff_shadows {p q : ℕ} (hco : Nat.Coprime p q) (s : ℕ → ZMod (p * q)) (n : ℕ) :
    SeqColl s n ↔ ∃ i < n, fstHom p q (s i) = fstHom p q (s n) ∧
      sndHom p q (s i) = sndHom p q (s n) := by
  constructor
  · rintro ⟨i, hi, hEq⟩
    exact ⟨i, hi, by rw [hEq], by rw [hEq]⟩
  · rintro ⟨i, hi, h1, h2⟩
    exact ⟨i, hi, zmod_eq_of_shadows_eq hco h1 h2⟩

/-- Each shadow collides no later than the modulus run. -/
theorem shadow_collTime_le {p q : ℕ} [NeZero (p * q)] (s : ℕ → ZMod (p * q)) :
    collTime (fun n => fstHom p q (s n)) ≤ collTime s :=
  collTime_map_le _ _

/-! ## 3. From a shadow collision to a factor -/

/-- A mod-`p` agreement of two states modulo `N` is a congruence of their canonical
integer representatives. -/
theorem val_congr_of_shadow_eq {p N : ℕ} [NeZero N] (h : p ∣ N) {x y : ZMod N}
    (hEq : (ZMod.castHom h (ZMod p)) x = (ZMod.castHom h (ZMod p)) y) :
    x.val ≡ y.val [MOD p] := by
  have hcast : ∀ z : ZMod N, (ZMod.castHom h (ZMod p)) z = ((z.val : ℕ) : ZMod p) := by
    intro z
    have hz : ((z.val : ℕ) : ZMod N) = z := ZMod.natCast_rightInverse z
    calc (ZMod.castHom h (ZMod p)) z
        = (ZMod.castHom h (ZMod p)) ((z.val : ℕ) : ZMod N) := by rw [hz]
      _ = ((z.val : ℕ) : ZMod p) := map_natCast _ _
  rw [hcast x, hcast y] at hEq
  exact (ZMod.natCast_eq_natCast_iff _ _ _).mp hEq

/-- **Success criterion.**  If the mod-`p` shadow of a run modulo `N` collides strictly
before the run itself does, then at the shadow's first collision the two states are
distinct modulo `N`, and the gcd of their difference with `N` is a nontrivial proper
divisor of `N` that is a multiple of `p`: the factor is out. -/
theorem reveal_of_shadow_strictly_earlier {p N : ℕ} [NeZero N] (hp : 2 ≤ p) (h : p ∣ N)
    (s : ℕ → ZMod N)
    (hlt : collTime (fun n => (ZMod.castHom h (ZMod p)) (s n)) < collTime s) :
    ∃ d : ℕ, 0 < d ∧ d < N ∧ p ∣ Nat.gcd d N ∧ Nat.gcd d N < N ∧ 2 ≤ Nat.gcd d N := by
  haveI : NeZero p := ⟨by omega⟩
  set t : ℕ → ZMod p := fun n => (ZMod.castHom h (ZMod p)) (s n) with ht
  obtain ⟨i, hi, hEq⟩ := collTime_mem t
  have hne : s i ≠ s (collTime t) := by
    intro hcontra
    exact not_seqColl_of_lt_collTime (s := s) hlt ⟨i, hi, hcontra⟩
  have hvne : (s i).val ≠ (s (collTime t)).val := fun hv => hne (ZMod.val_injective N hv)
  have hcong : (s i).val ≡ (s (collTime t)).val [MOD p] := val_congr_of_shadow_eq h hEq
  rcases lt_or_gt_of_ne hvne with hlt' | hlt'
  · refine ⟨(s (collTime t)).val - (s i).val, by omega, by
      have := ZMod.val_lt (s (collTime t)); omega, ?_⟩
    obtain ⟨h1, -, h3, h4⟩ :=
      factor_revealed hp h hlt' (ZMod.val_lt (s (collTime t))) hcong.symm
    exact ⟨h1, h3, h4⟩
  · refine ⟨(s i).val - (s (collTime t)).val, by omega, by
      have := ZMod.val_lt (s i); omega, ?_⟩
    obtain ⟨h1, -, h3, h4⟩ := factor_revealed hp h hlt' (ZMod.val_lt (s i)) hcong
    exact ⟨h1, h3, h4⟩

/-- **Uniform methods succeed as soon as their shadow is strictly faster.**  For any
natural state update, if the factor's shadow closes before the modulus run does, the
run outputs a nontrivial proper factor of `N` divisible by `p`. -/
theorem success_criterion (M : UniformStep) {p N : ℕ} [NeZero N] (hp : 2 ≤ p) (h : p ∣ N)
    (x0 : ℤ)
    (hlt : uniformTime M p N h x0 < collTime (M.orbit (ZMod N) ((x0 : ZMod N)))) :
    ∃ d : ℕ, 0 < d ∧ d < N ∧ p ∣ Nat.gcd d N ∧ Nat.gcd d N < N ∧ 2 ≤ Nat.gcd d N :=
  reveal_of_shadow_strictly_earlier hp h _ hlt

end MethodLocalityCRT