import Cryptography.UniversalPosets.LogBounds

/-!
# `U` is strictly increasing

`ExactSmall.lean` showed that `U` is monotone (adding an isolated point to a
poset).  Here the monotonicity is upgraded to a *strict* one:

`U(n) < U(n+1)` for every `n`.

The mechanism is a genuine structural one, not a counting one.  Let `H` be a
host containing every `(n+1)`-element poset, and let `m` be a maximal point of
`H`.  Given an `n`-element poset `r`, add to `r` a new element `⊤` above
everything (`extendTopRel`).  In any induced copy of `r + ⊤` inside `H` the
image of `⊤` is strictly above the images of the other `n` points, so *none* of
those `n` points can be the maximal point `m`.  Hence `H \ {m}`, which has one
point fewer, is already universal for the `n`-element posets.

Consequences: `U` is strictly monotone, and therefore injective; and any exact
value propagates, e.g. `U(n) ≥ n + 2` for `n ≥ 2` follows from `U(2) = 3`
(and is subsumed by the sharper `2n - 1` bound of `ExactSmall.lean`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Conjecture C4 of the previous cycle asked whether
`U` is strictly increasing.  The known values `1, 3, 5` are consistent with it,
and the natural mechanism is that a *top* point of the added element cannot be
reused as a maximal point of the host.

Experiment (Experimenter).  The mechanism was tested against the `300` five-point
hosts universal for three-element posets: deleting a maximal point of any one of
them leaves a four-point poset which is universal for the two-element posets
(`U(2) = 3 ≤ 4`), as the argument predicts.

Analysis (Analyst).  The argument only needs the *existence* of a maximal point,
so it works in any finite host, and it needs the extension by a global top,
which is the smallest extension whose embedding is forced away from the maximum.
The same argument with a minimal point and a global bottom gives the same bound.

Critique (Critic).  Strict monotonicity gives only `U(n) ≥ U(3) + n - 3`, weaker
than `2n - 1`; its value is qualitative (`U` is injective, no plateaux), and it
closes the "strictly increasing" half of conjecture C4 of the previous cycle.
The recursive half of C4 (`U(n+1) ≤ 2U(n) + 1`) remains open and is restated in
`FUTURE_DIRECTIONS.md`.
-/

namespace UniversalPosets

open Function

/-- Adjoining a new greatest element to an `n`-element order. -/
private def extendTopRel {n : ℕ} (r : Fin n → Fin n → Prop) :
    Fin (n + 1) → Fin (n + 1) → Prop :=
  fun x y => y = Fin.last n ∨ ∃ hx : (x : ℕ) < n, ∃ hy : (y : ℕ) < n, r ⟨x, hx⟩ ⟨y, hy⟩

private theorem extendTopRel_isPartialOrder {n : ℕ} (r : Fin n → Fin n → Prop)
    (hr : IsPartialOrder (Fin n) r) : IsPartialOrder (Fin (n + 1)) (extendTopRel r) :=
  haveI : Std.Refl (extendTopRel r) := by
    refine ⟨fun x => ?_⟩
    by_cases hx : (x : ℕ) < n
    · exact Or.inr ⟨hx, hx, refl_of r _⟩
    · refine Or.inl (Fin.ext ?_)
      have := x.isLt
      simp only [Fin.val_last]
      omega
  haveI : IsTrans (Fin (n + 1)) (extendTopRel r) := by
    refine ⟨?_⟩
    rintro x y z (rfl | ⟨hx, hy, hxy⟩) (hz | ⟨hy', hz', hyz⟩)
    · exact Or.inl hz
    · exact absurd hy' (by simp)
    · exact Or.inl hz
    · exact Or.inr ⟨hx, hz', trans_of r hxy (by simpa using hyz)⟩
  haveI : IsPreorder (Fin (n + 1)) (extendTopRel r) := ⟨⟩
  haveI : Std.Antisymm (extendTopRel r) := by
    refine ⟨?_⟩
    rintro x y (hy | ⟨hx, hy, hxy⟩) (hx' | ⟨hy', hx'', hyx⟩)
    · rw [hy, hx']
    · subst hy; exact absurd hy' (by simp)
    · subst hx'; exact absurd hx (by simp)
    · have : (⟨(x : ℕ), hx⟩ : Fin n) = ⟨(y : ℕ), hy⟩ :=
        antisymm_of r hxy (by simpa using hyx)
      exact Fin.ext (by simpa using congrArg Fin.val this)
  ⟨⟩

/--
**Deleting a maximal point.**  A host for the `(n+1)`-element posets remains
universal for the `n`-element posets after one of its maximal points is deleted.
-/
theorem isUniversalPosetOfSize_pred {N n : ℕ} (h : IsUniversalPosetOfSize N (n + 1)) :
    IsUniversalPosetOfSize (N - 1) n := by
  classical
  obtain ⟨H, hH, hu⟩ := h
  letI : PartialOrder (Pt N) :=
    { le := H
      lt := fun a b => H a b ∧ ¬ H b a
      le_refl := fun a => refl_of H a
      le_trans := fun _ _ _ h1 h2 => trans_of H h1 h2
      lt_iff_le_not_ge := fun _ _ => Iff.rfl
      le_antisymm := fun _ _ h1 h2 => antisymm_of H h1 h2 }
  -- the host is nonempty
  obtain ⟨f₀, -⟩ := hu (fun x y => x = y) (isPartialOrder_eq _)
  haveI : Nonempty (Pt N) := ⟨f₀ 0⟩
  -- pick a maximal point
  obtain ⟨m, hm⟩ := Finset.exists_maximal (s := (Finset.univ : Finset (Pt N)))
    Finset.univ_nonempty
  have hmax : ∀ z : Pt N, m ≤ z → z = m := fun z hz =>
    le_antisymm (hm.2 (Finset.mem_univ z) hz) hz
  -- the host with `m` deleted
  have hcard : Fintype.card {x : Pt N // x ≠ m} = N - 1 := by
    rw [Fintype.card_subtype_compl]
    simp
  refine isUniversalPosetOfSize_of_host (U := {x : Pt N // x ≠ m}) hcard ?_
  intro r hr
  haveI hpo : IsPartialOrder (Fin (n + 1)) (extendTopRel r) := extendTopRel_isPartialOrder r hr
  obtain ⟨F, hF⟩ := hu (extendTopRel r) hpo
  have hne : ∀ x : Fin n, F x.castSucc ≠ m := by
    intro x hx
    have hle : H (F x.castSucc) (F (Fin.last n)) := (hF _ _).2 (Or.inl rfl)
    rw [hx] at hle
    have : F (Fin.last n) = m := hmax _ hle
    have hcast : (x.castSucc : Fin (n + 1)) = Fin.last n := by
      have hFinj : Injective F := fun a b hab =>
        antisymm_of (extendTopRel r) ((hF a b).1 (by rw [hab]; exact refl_of H _))
          ((hF b a).1 (by rw [hab]; exact refl_of H _))
      exact hFinj (by rw [hx, this])
    have := congrArg Fin.val hcast
    simp at this
    omega
  refine ⟨fun x => ⟨F x.castSucc, hne x⟩, fun x y => ?_⟩
  show H (F x.castSucc) (F y.castSucc) ↔ r x y
  rw [hF]
  constructor
  · rintro (hlast | ⟨hx, hy, hxy⟩)
    · exact absurd (congrArg Fin.val hlast) (by simp; omega)
    · simpa using hxy
  · intro hxy
    exact Or.inr ⟨by simp, by simp, by simpa using hxy⟩

/-- **`U` is strictly increasing.** -/
theorem minUniversalSize_lt_succ (n : ℕ) : minUniversalSize n < minUniversalSize (n + 1) := by
  have h1 : minUniversalSize n ≤ minUniversalSize (n + 1) - 1 :=
    Nat.sInf_le (isUniversalPosetOfSize_pred (isUniversalPosetOfSize_minUniversalSize (n + 1)))
  have h2 : n + 1 ≤ minUniversalSize (n + 1) := self_le_minUniversalSize (n + 1)
  omega

theorem minUniversalSize_strictMono : StrictMono minUniversalSize :=
  strictMono_nat_of_lt_succ minUniversalSize_lt_succ

/-- Distinct numbers of points need distinct minimal hosts. -/
theorem minUniversalSize_injective : Injective minUniversalSize :=
  minUniversalSize_strictMono.injective

end UniversalPosets