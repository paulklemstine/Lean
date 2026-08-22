import Cryptography.TernaryReversible.General

/-!
# Divisor monotonicity of cycle injectivity, and a factorial test

Cycle-bijectivity is a statement about *all* cycle lengths at once, so it is a priori an
infinite test.  This file isolates the first genuinely structural reduction of that test:
the lengths at which a radius-one rule fails to be injective form a set that is **closed
upwards under divisibility**.

The mechanism is that the reduction map `π : ZMod n → ZMod m` (for `m ∣ n`) is a
*surjective ring homomorphism*, hence commutes with the shifts `i ↦ i ± 1` that define the
global map.  Consequently `s ∘ π` is a configuration on the long cycle whose image under
the global map is the pull-back of the image of `s`:

`globalMapA g (s ∘ π) = (globalMapA g s) ∘ π`  (`globalMapA_castHom`).

Two distinct configurations on the short cycle therefore lift to two distinct
configurations on the long cycle with the same image, and non-injectivity propagates from
`m` to every multiple of `m`.

## Main results

* `globalMapA_castHom` — the intertwining identity for the reduction map;
* `injective_globalMapA_of_dvd` — injectivity at `n` implies injectivity at every divisor
  of `n`;
* `not_injective_globalMapA_of_dvd` — its contrapositive: failure propagates to multiples;
* `cycleBijectiveA_iff_factorial` — cycle-bijectivity is equivalent to injectivity on the
  *cofinal divisibility chain* of factorial lengths `1!, 2!, 3!, …`;
* `diag_injective_of_injective_at` — a single cycle length already forces the diagonal map
  `b ↦ g b b b` to be injective (the length-`1` divisor).
-/

namespace Cryptography
namespace TernaryReversible

variable {A : Type}

/-! ## The reduction map intertwines the global maps -/

/-- For `m ∣ n` the reduction `π : ZMod n → ZMod m` is a ring homomorphism, so it commutes
with the two shifts occurring in the global map: pulling a configuration back along `π`
pulls its image back along `π` as well. -/
theorem globalMapA_castHom (g : A → A → A → A) {m n : ℕ} (h : m ∣ n) (s : ZMod m → A) :
    globalMapA g (s ∘ (ZMod.castHom h (ZMod m))) =
      (globalMapA g s) ∘ (ZMod.castHom h (ZMod m)) := by
  funext i
  simp only [globalMapA, Function.comp_apply, map_sub, map_add, map_one]

/-- **Divisor monotonicity.** If the global map of `g` is injective on the cycle of length
`n`, it is injective on the cycle of every divisor length `m ∣ n`. -/
theorem injective_globalMapA_of_dvd {g : A → A → A → A} {m n : ℕ} (h : m ∣ n)
    (hn : Function.Injective (globalMapA (n := n) g)) :
    Function.Injective (globalMapA (n := m) g) := by
  intro s t hst
  set π := ZMod.castHom h (ZMod m) with hπ
  have hlift : globalMapA (n := n) g (s ∘ π) = globalMapA (n := n) g (t ∘ π) := by
    rw [globalMapA_castHom g h s, globalMapA_castHom g h t, hst]
  have hcomp : s ∘ π = t ∘ π := hn hlift
  funext j
  obtain ⟨i, rfl⟩ := ZMod.castHom_surjective h j
  exact congrFun hcomp i

/-- Contrapositive form: a failure of injectivity on the cycle of length `m` propagates to
**every** multiple of `m`.  In particular a single bad length produces infinitely many. -/
theorem not_injective_globalMapA_of_dvd {g : A → A → A → A} {m n : ℕ} (h : m ∣ n)
    (hm : ¬ Function.Injective (globalMapA (n := m) g)) :
    ¬ Function.Injective (globalMapA (n := n) g) :=
  fun hn => hm (injective_globalMapA_of_dvd h hn)

/-! ## A cofinal chain of test lengths -/

/-- On a nonempty finite cycle over a finite alphabet, bijectivity of the global map is the
same as injectivity. -/
theorem bijective_iff_injective_globalMapA [Fintype A] (g : A → A → A → A) {n : ℕ}
    (hn : 0 < n) :
    Function.Bijective (globalMapA (n := n) g) ↔ Function.Injective (globalMapA (n := n) g) := by
  haveI : NeZero n := ⟨hn.ne'⟩
  exact ⟨fun h => h.1, fun h => Finite.injective_iff_bijective.1 h⟩

/-- **Factorial test.** Because every positive `n` divides `n !`, the factorial lengths form
a cofinal chain for divisibility, and cycle-bijectivity is equivalent to injectivity along
that single chain. -/
theorem cycleBijectiveA_iff_factorial [Fintype A] (g : A → A → A → A) :
    CycleBijectiveA g ↔ ∀ k : ℕ, Function.Injective (globalMapA (n := (Nat.factorial (k + 1))) g) := by
  constructor
  · intro hg k
    exact (hg _ (Nat.factorial_pos _)).1
  · intro hfac n hn
    rw [bijective_iff_injective_globalMapA g hn]
    have hdvd : n ∣ (Nat.factorial (n - 1 + 1)) := by
      have : n - 1 + 1 = n := Nat.succ_pred_eq_of_pos hn
      rw [this]
      exact Nat.dvd_factorial hn le_rfl
    exact injective_globalMapA_of_dvd hdvd (hfac (n - 1))

/-- Specialisation of the factorial test to the ternary alphabet. -/
theorem cycleBijective_iff_factorial (g : LocalRule) :
    CycleBijective g ↔ ∀ k : ℕ, Function.Injective (globalMap (n := (Nat.factorial (k + 1))) g) :=
  cycleBijectiveA_iff_factorial g

/-! ## The length-one divisor -/

/-- Injectivity on *one* cycle, of any length, already forces the diagonal map
`b ↦ g b b b` to be injective: length `1` divides every length. -/
theorem diag_injective_of_injective_at {g : A → A → A → A} {n : ℕ}
    (hn : Function.Injective (globalMapA (n := n) g)) :
    Function.Injective (fun b : A => g b b b) := by
  have h1 : Function.Injective (globalMapA (n := 1) g) :=
    injective_globalMapA_of_dvd (one_dvd n) hn
  intro x y hxy
  have hfun : globalMapA (n := 1) g (fun _ => x) = globalMapA (n := 1) g (fun _ => y) := by
    funext i
    exact hxy
  have := h1 hfun
  exact congrFun this 0

end TernaryReversible
end Cryptography