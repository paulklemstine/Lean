import Cryptography.UniversalPosets.SmallCases

/-!
# The universal-poset size function `U(n)`

This file packages the bounds of `Bounds.lean` and `SmallCases.lean` into a
single numerical invariant:

`minUniversalSize n` is the least `N` such that some partial order on `N` points
contains every partial order on `n` points as an induced subposet.

Proved here:

* `minUniversalSize_le_two_pow`   :  `U(n) ≤ 2 ^ n`   (Boolean lattice);
* `self_le_minUniversalSize`      :  `n ≤ U(n)`       (the `n`-antichain);
* `two_pow_le_minUniversalSize_sq`:  `2 ^ m ≤ U(2m)²`, i.e. `U(n) ≥ 2^{n/4}`;
* `minUniversalSize_two`          :  `U(2) = 3` exactly.

The theorem of the motivating paper says `U(n) ≤ 2^{(1+η)n/2}` for large `n`;
the exponent therefore lies in `[1/4, 1/2]`, and pinning it down is open.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  `U` is a well-defined `ℕ`-valued function (the set of
admissible sizes is nonempty because the Boolean lattice works), squeezed
between `2^{n/4}` and `2^n`, with `U(1) = 1`, `U(2) = 3` and (experimentally)
`U(3) = 5`.

Experiment (Experimenter).  `U(2) = 3` is *proved* here.  `U(3) = 5` was found by
exhaustive machine search over all `219` partial orders on `4` points and all
`4231` partial orders on `5` points (see `ComputationalEvidence.md`); it is
recorded as computational evidence only, not as a theorem, since the kernel
cannot replay a search of that size.

Analysis (Analyst).  Carrying the host on the *synonym* `Pt N` of `Fin N` rather
than on `Fin N` itself is essential: `Fin N` already carries its own order, and
a transported order must not be silently overwritten by it.  This is the formal
counterpart of the informal phrase "a poset on `N` points".

Critique (Critic).  `minUniversalSize` is a genuine `sInf` over a nonempty set of
naturals, so all four theorems are statements about an attained minimum, not
about a vacuous infimum: nonemptiness is supplied by
`isUniversalPosetOfSize_two_pow`.
-/

namespace UniversalPosets

/-- An `N`-point carrier with **no** ambient order (a synonym of `Fin N`). -/
def Pt (N : ℕ) : Type := Fin N

instance (N : ℕ) : Fintype (Pt N) := inferInstanceAs (Fintype (Fin N))
instance (N : ℕ) : DecidableEq (Pt N) := inferInstanceAs (DecidableEq (Fin N))

@[simp] theorem card_Pt (N : ℕ) : Fintype.card (Pt N) = N := Fintype.card_fin N

/--
`IsUniversalPosetOfSize N n` : there is a partial order on `N` points containing
every partial order on `n` points as an induced subposet.
-/
def IsUniversalPosetOfSize (N n : ℕ) : Prop :=
  ∃ H : Pt N → Pt N → Prop, IsPartialOrder (Pt N) H ∧
    ∀ r : Fin n → Fin n → Prop, IsPartialOrder (Fin n) r →
      ∃ f : Fin n → Pt N, ∀ x y, H (f x) (f y) ↔ r x y

/-- The size of a smallest universal poset for the `n`-element posets. -/
noncomputable def minUniversalSize (n : ℕ) : ℕ :=
  sInf {N | IsUniversalPosetOfSize N n}

/-- Transport of a universal host along an equivalence of the host type. -/
theorem isUniversalPosetOfSize_of_host {U : Type} [PartialOrder U] [Fintype U] {N n : ℕ}
    (hcard : Fintype.card U = N) (h : IsUniversalHost U (Fin n)) :
    IsUniversalPosetOfSize N n := by
  classical
  let e : U ≃ Pt N := (Fintype.equivFin U).trans (finCongr hcard)
  refine ⟨fun a b => e.symm a ≤ e.symm b, ?_, ?_⟩
  · exact
      haveI : Std.Refl (fun a b : Pt N => e.symm a ≤ e.symm b) := ⟨fun _ => le_refl _⟩
      haveI : IsTrans (Pt N) (fun a b : Pt N => e.symm a ≤ e.symm b) :=
        ⟨fun _ _ _ h1 h2 => le_trans h1 h2⟩
      haveI : IsPreorder (Pt N) (fun a b : Pt N => e.symm a ≤ e.symm b) := ⟨⟩
      haveI : Std.Antisymm (fun a b : Pt N => e.symm a ≤ e.symm b) :=
        ⟨fun _ _ h1 h2 => e.symm.injective (le_antisymm h1 h2)⟩
      ⟨⟩
  · intro r hr
    obtain ⟨f, hf⟩ := h r hr
    exact ⟨fun x => e (f x), fun x y => by simpa using hf x y⟩

/-- The Boolean lattice witnesses `2 ^ n` as an admissible size. -/
theorem isUniversalPosetOfSize_two_pow (n : ℕ) : IsUniversalPosetOfSize (2 ^ n) n := by
  classical
  refine isUniversalPosetOfSize_of_host (U := Set (Fin n)) ?_ (setHost_isUniversalHost _)
  simp

/-- **Upper bound**: `U(n) ≤ 2 ^ n`. -/
theorem minUniversalSize_le_two_pow (n : ℕ) : minUniversalSize n ≤ 2 ^ n :=
  Nat.sInf_le (isUniversalPosetOfSize_two_pow n)

/-- The infimum is attained. -/
theorem isUniversalPosetOfSize_minUniversalSize (n : ℕ) :
    IsUniversalPosetOfSize (minUniversalSize n) n := by
  have hne : {N | IsUniversalPosetOfSize N n}.Nonempty :=
    ⟨2 ^ n, isUniversalPosetOfSize_two_pow n⟩
  exact Nat.sInf_mem hne

/-- **Lower bound (trivial part)**: a host has at least `n` points. -/
theorem self_le_minUniversalSize (n : ℕ) : n ≤ minUniversalSize n := by
  obtain ⟨H, hH, hu⟩ := isUniversalPosetOfSize_minUniversalSize n
  obtain ⟨f, hf⟩ := hu (fun x y => x = y)
    (haveI : Std.Refl (fun x y : Fin n => x = y) := ⟨fun _ => rfl⟩
     haveI : IsTrans (Fin n) (fun x y : Fin n => x = y) := ⟨fun _ _ _ h1 h2 => h1.trans h2⟩
     haveI : IsPreorder (Fin n) (fun x y : Fin n => x = y) := ⟨⟩
     haveI : Std.Antisymm (fun x y : Fin n => x = y) := ⟨fun _ _ h1 _ => h1⟩
     ⟨⟩)
  have hinj : Function.Injective f := by
    intro x y hxy
    exact (hf x y).1 (by rw [hxy]; exact refl_of H _)
  simpa using Fintype.card_le_of_injective f hinj

/--
**Lower bound**: `2 ^ m ≤ U(2m) ^ 2`, i.e. `U(n) ≥ 2 ^ (n/4)`.
-/
theorem two_pow_le_minUniversalSize_sq {m : ℕ} (hm : 1 ≤ m) :
    2 ^ m ≤ (minUniversalSize (m + m)) ^ 2 := by
  obtain ⟨H, hH, hu⟩ := isUniversalPosetOfSize_minUniversalSize (m + m)
  letI : LE (Pt (minUniversalSize (m + m))) := ⟨H⟩
  have huniv : IsUniversalHost (Pt (minUniversalSize (m + m))) (Fin (m + m)) := hu
  simpa using two_pow_le_card_sq_of_isUniversalHost hm huniv

/-- The three-point host, transported to a three-point carrier. -/
theorem isUniversalPosetOfSize_three_two : IsUniversalPosetOfSize 3 2 :=
  isUniversalPosetOfSize_of_host card_bipHost_one_one bipHost_one_one_isUniversalHost

/-- **Exact value**: `U(2) = 3`. -/
theorem minUniversalSize_two : minUniversalSize 2 = 3 := by
  refine le_antisymm (Nat.sInf_le isUniversalPosetOfSize_three_two) ?_
  obtain ⟨H, hH, hu⟩ := isUniversalPosetOfSize_minUniversalSize 2
  letI : PartialOrder (Pt (minUniversalSize 2)) :=
    { le := H
      lt := fun a b => H a b ∧ ¬ H b a
      le_refl := fun a => refl_of H a
      le_trans := fun _ _ _ h1 h2 => trans_of H h1 h2
      lt_iff_le_not_ge := fun _ _ => Iff.rfl
      le_antisymm := fun _ _ h1 h2 => antisymm_of H h1 h2 }
  have huniv : IsUniversalHost (Pt (minUniversalSize 2)) (Fin 2) := hu
  simpa using exact_universal_two.2.2 (Pt (minUniversalSize 2)) huniv

end UniversalPosets