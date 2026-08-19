/-
# The converse of Poisson summation on a finite abelian group

`Catalog.Shared.FourierSubgroupDuality` proves **Poisson summation** for a subgroup
`H ≤ G` of a finite abelian group `G`:

  `|G| * ∑_{x ∈ H} f x = |H| * ∑_{ψ ∈ H^⊥} f̂ ψ`   for every `f : G → ℂ`.

This file proves the **converse**, and in doing so classifies *all* pairs of finsets
`(S, T)`, `S ⊆ G`, `T ⊆ Ĝ`, for which the Poisson identity

  `|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} f̂ ψ`   for every `f : G → ℂ`   (`IsPoissonPair S T`)

holds.  The answer is as rigid as possible: apart from the degenerate pair `S = ∅`,
`S` must be a subgroup and `T` must be its annihilator.

The proof is exactly the "no new analytic input" argument: both sides of the identity are
already available (`FourierFA.poisson_summation`, `FourierFA.dft_delta`), so testing the
identity against Dirac deltas and against characters turns it into a *finite statement about
the character table*, which is then rigid because a sum of `n` complex numbers of modulus `1`
can equal `n` only if every summand is `1`.

## Main results

* `FourierFA.isPoissonPair_iff_matrix` — **only the deltas matter**: the Poisson identity for
  *all* `f` is equivalent to the finite family of character-table identities
  `|S| * ∑_{ψ ∈ T} conj (ψ a) = |G| * [a ∈ S]`, one for each `a ∈ G`.
* `FourierFA.poisson_char_test` — the dual test: `∑_{x ∈ S} ψ x = |S| * [ψ ∈ T]`.
* `FourierFA.mem_of_isPoissonPair` / `mem_dual_of_isPoissonPair` — the rigidity step:
  `a ∈ S ↔ ∀ ψ ∈ T, ψ a = 1` and `ψ ∈ T ↔ ∀ x ∈ S, ψ x = 1`.
* `FourierFA.isPoissonPair_converse` — **the converse of Poisson summation**: a nonempty
  Poisson pair consists of a subgroup and its annihilator.
* `FourierFA.isPoissonPair_iff_subgroup` — the resulting classification (a biconditional).
* `FourierFA.card_mul_card_of_isPoissonPair`, `FourierFA.card_dvd_of_isPoissonPair` —
  `|S| * |T| = |G|`; in particular Lagrange's theorem `|S| ∣ |G|` falls out of the analytic
  identity.
* `FourierFA.rectangle_card_le` — a combinatorial bound on the character table: an all-ones
  combinatorial rectangle `S × T` inside the character table has area `|S| * |T| ≤ |G|`.
* `FourierFA.isPoissonPair_iff_rectangle` — **Poisson pairs = maximal all-ones rectangles**:
  `(S, T)` is a nonempty Poisson pair iff the `S × T` block of the character table is
  identically `1` and has area exactly `|G|`.
* `FourierFA.preAnnih_annih` — biduality `H^⊥⊥ = H` for subgroups, obtained as a *corollary*
  of the converse rather than from Pontryagin duality.
* `FourierFA.isPoissonPair_unique_dual`, `isPoissonPair_unique_primal` — each side of a
  Poisson pair determines the other.

## Boundary of the theorem

`FourierFA.isPoissonPair_empty` shows that `S = ∅` is a genuine (and the only) degenerate
solution, so the nonemptiness hypothesis in the classification cannot be dropped.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## A rigidity lemma for sums of unimodular numbers -/

/-- If `n` complex numbers of modulus `1` sum to `n`, then each of them equals `1`.
This is the equality case of the triangle inequality, and it is the only "hard" ingredient
of the converse of Poisson summation. -/
lemma eq_one_of_sum_eq_card {ι : Type*} {s : Finset ι} {z : ι → ℂ}
    (hnorm : ∀ i ∈ s, ‖z i‖ = 1) (hsum : ∑ i ∈ s, z i = (s.card : ℂ)) :
    ∀ i ∈ s, z i = 1 := by
  have hre : ∑ i ∈ s, (1 - (z i).re) = 0 := by
    have h1 : (∑ i ∈ s, z i).re = (s.card : ℝ) := by rw [hsum]; simp
    rw [Complex.re_sum] at h1
    rw [Finset.sum_sub_distrib, h1]
    simp
  have hnn : ∀ i ∈ s, 0 ≤ 1 - (z i).re := by
    intro i hi
    have h2 : |(z i).re| ≤ ‖z i‖ := Complex.abs_re_le_norm _
    rw [hnorm i hi] at h2
    linarith [(abs_le.1 h2).2]
  have h0 := (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hre
  intro i hi
  have hre1 : (z i).re = 1 := by have := h0 i hi; linarith
  have hn : (z i).re ^ 2 + (z i).im ^ 2 = 1 := by
    have h3 : Complex.normSq (z i) = 1 := by
      rw [Complex.normSq_eq_norm_sq, hnorm i hi]; norm_num
    simpa [Complex.normSq_apply, sq] using h3
  have him : (z i).im = 0 := by nlinarith [sq_nonneg (z i).im]
  exact Complex.ext (by simp [hre1]) (by simp [him])

/-! ## Poisson pairs -/

/-- `IsPoissonPair S T` says that the Poisson summation identity
`|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} f̂ ψ` holds for **every** `f : G → ℂ`. -/
def IsPoissonPair (S : Finset G) (T : Finset (AddChar G ℂ)) : Prop :=
  ∀ f : G → ℂ, (Fintype.card G : ℂ) * ∑ x ∈ S, f x
    = (S.card : ℂ) * ∑ ψ ∈ T, dft f ψ

/-- The finite "character table" form of the Poisson relation: one identity for each group
element, involving only the entries of the character table. -/
def PoissonMatrix (S : Finset G) (T : Finset (AddChar G ℂ)) : Prop :=
  ∀ a : G, (S.card : ℂ) * ∑ ψ ∈ T, conj (ψ a)
    = (Fintype.card G : ℂ) * (if a ∈ S then 1 else 0)

/-- The annihilator, *inside the group*, of a set of characters: `T^⊥ = {a | ∀ ψ ∈ T, ψ a = 1}`.
This is the object that the converse of Poisson summation produces. -/
def preAnnih (T : Finset (AddChar G ℂ)) : AddSubgroup G where
  carrier := {a : G | ∀ ψ ∈ T, ψ a = 1}
  zero_mem' := by intro ψ _; simp
  add_mem' := by
    intro a b ha hb ψ hψ
    rw [ψ.map_add_eq_mul, ha ψ hψ, hb ψ hψ, one_mul]
  neg_mem' := by
    intro a ha ψ hψ
    rw [AddChar.map_neg_eq_conj, ha ψ hψ, map_one]

omit [DecidableEq G] in
@[simp] lemma mem_preAnnih {T : Finset (AddChar G ℂ)} {a : G} :
    a ∈ preAnnih T ↔ ∀ ψ ∈ T, ψ a = 1 := Iff.rfl

variable {S : Finset G} {T : Finset (AddChar G ℂ)}

/-! ## Reduction to the character table -/

/-- Testing Poisson summation against Dirac deltas already gives back the full identity:
the analytic statement `IsPoissonPair` is *equivalent* to the finite statement
`PoissonMatrix` about the character table. -/
theorem isPoissonPair_iff_matrix : IsPoissonPair S T ↔ PoissonMatrix S T := by
  constructor
  · intro h a
    have hd := h (delta a)
    have hL : ∑ x ∈ S, delta a x = (if a ∈ S then 1 else 0) := by
      simp only [delta]
      rw [Finset.sum_ite_eq' S a (fun _ => (1 : ℂ))]
    have hR : ∑ ψ ∈ T, dft (delta a) ψ = ∑ ψ ∈ T, conj (ψ a) :=
      Finset.sum_congr rfl fun ψ _ => dft_delta a ψ
    rw [hL, hR] at hd
    exact hd.symm
  · intro h f
    have hL : ∑ x ∈ S, f x = ∑ a : G, (if a ∈ S then 1 else 0) * f a := by
      simp [ite_mul, Finset.sum_ite_mem]
    have hR : ∑ ψ ∈ T, dft f ψ = ∑ a : G, (∑ ψ ∈ T, conj (ψ a)) * f a := by
      simp only [dft]
      rw [Finset.sum_comm]
      exact Finset.sum_congr rfl fun a _ => by rw [Finset.sum_mul]
    rw [hL, hR, Finset.mul_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl fun a _ => ?_
    calc (Fintype.card G : ℂ) * ((if a ∈ S then 1 else 0) * f a)
        = ((Fintype.card G : ℂ) * (if a ∈ S then 1 else 0)) * f a := by ring
      _ = ((S.card : ℂ) * ∑ ψ ∈ T, conj (ψ a)) * f a := by rw [h a]
      _ = (S.card : ℂ) * ((∑ ψ ∈ T, conj (ψ a)) * f a) := by ring

omit [DecidableEq G] in
/-- The dual test function: evaluating the Poisson identity at a character `ψ₀` shows that
`ψ₀` sums to `|S|` over `S` if `ψ₀ ∈ T`, and to `0` otherwise. -/
theorem poisson_char_test (h : IsPoissonPair S T) (ψ₀ : AddChar G ℂ) :
    ∑ x ∈ S, ψ₀ x = (S.card : ℂ) * (if ψ₀ ∈ T then 1 else 0) := by
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hd : ∀ χ : AddChar G ℂ,
      dft (fun x => ψ₀ x) χ = if ψ₀ = χ then (Fintype.card G : ℂ) else 0 := by
    intro χ
    rw [dft, ← sum_char_mul_conj ψ₀ χ]
    exact Finset.sum_congr rfl fun x _ => mul_comm _ _
  have key := h (fun x => ψ₀ x)
  rw [Finset.sum_congr rfl (fun χ (_ : χ ∈ T) => hd χ),
    Finset.sum_ite_eq T ψ₀ (fun _ => (Fintype.card G : ℂ))] at key
  refine mul_left_cancel₀ hcard ?_
  rw [key]
  by_cases hT : ψ₀ ∈ T
  · rw [if_pos hT, if_pos hT]; ring
  · rw [if_neg hT, if_neg hT]; ring

/-! ## Rigidity: the pair is a subgroup and its annihilator -/

omit [DecidableEq G] in
/-- If `S` is a nonempty Poisson set then the trivial character belongs to `T`. -/
lemma zero_mem_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty) :
    (0 : AddChar G ℂ) ∈ T := by
  have hc := poisson_char_test h 0
  simp only [AddChar.zero_apply, Finset.sum_const, nsmul_eq_mul, mul_one] at hc
  by_contra hT
  rw [if_neg hT, mul_zero] at hc
  exact (Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)) hc

omit [DecidableEq G] in
/-- A nonempty Poisson pair has `T` nonempty. -/
lemma nonempty_dual_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty) :
    T.Nonempty := ⟨0, zero_mem_of_isPoissonPair h hS⟩

/-- **The area identity**: a nonempty Poisson pair satisfies `|S| * |T| = |G|`. -/
theorem card_mul_card_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty) :
    S.card * T.card = Fintype.card G := by
  have hm := (isPoissonPair_iff_matrix.1 h) 0
  have hz : ∑ ψ ∈ T, conj (ψ (0 : G)) = (T.card : ℂ) := by
    simp
  rw [hz] at hm
  have hzS : (0 : G) ∈ S := by
    by_contra h0
    rw [if_neg h0, mul_zero] at hm
    rcases mul_eq_zero.1 hm with h1 | h2
    · exact (Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)) h1
    · have hT := nonempty_dual_of_isPoissonPair h hS
      exact (Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hT.choose_spec)) h2
  rw [if_pos hzS, mul_one] at hm
  exact_mod_cast hm

/-- **Lagrange's theorem, extracted from Poisson summation**: the size of a nonempty Poisson
set divides the order of the group. -/
theorem card_dvd_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty) :
    S.card ∣ Fintype.card G :=
  ⟨T.card, (card_mul_card_of_isPoissonPair h hS).symm⟩

/-- **Rigidity, primal side**: membership in `S` is detected by the character table —
`a ∈ S` exactly when every character of `T` is trivial at `a`. -/
theorem mem_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty) (a : G) :
    a ∈ S ↔ ∀ ψ ∈ T, ψ a = 1 := by
  have hm := (isPoissonPair_iff_matrix.1 h) a
  have hScard : (S.card : ℂ) ≠ 0 :=
    Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)
  have harea : (S.card : ℂ) * (T.card : ℂ) = (Fintype.card G : ℂ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℂ) (card_mul_card_of_isPoissonPair h hS)
  constructor
  · intro ha
    rw [if_pos ha, mul_one, ← harea] at hm
    have hsum : ∑ ψ ∈ T, conj (ψ a) = (T.card : ℂ) := mul_left_cancel₀ hScard hm
    intro ψ hψ
    have hnorm : ∀ ψ' ∈ T, ‖conj (ψ' a)‖ = 1 := by
      intro ψ' _; rw [RCLike.norm_conj]; exact AddChar.norm_apply _ _
    have := eq_one_of_sum_eq_card hnorm hsum ψ hψ
    have h2 : conj (conj (ψ a)) = conj (1 : ℂ) := congrArg conj this
    simpa using h2
  · intro hall
    by_contra ha
    rw [if_neg ha, mul_zero] at hm
    have hsum : ∑ ψ ∈ T, conj (ψ a) = (T.card : ℂ) := by
      rw [Finset.sum_congr rfl (fun ψ hψ => by rw [hall ψ hψ, map_one])]
      simp
    rw [hsum] at hm
    rcases mul_eq_zero.1 hm with h1 | h2
    · exact hScard h1
    · have hT := nonempty_dual_of_isPoissonPair h hS
      exact (Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hT.choose_spec)) h2

omit [DecidableEq G] in
/-- **Rigidity, dual side**: membership in `T` is detected by the character table —
`ψ ∈ T` exactly when `ψ` is trivial on all of `S`. -/
theorem mem_dual_of_isPoissonPair (h : IsPoissonPair S T) (hS : S.Nonempty)
    (ψ : AddChar G ℂ) : ψ ∈ T ↔ ∀ x ∈ S, ψ x = 1 := by
  have hc := poisson_char_test h ψ
  have hScard : (S.card : ℂ) ≠ 0 :=
    Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)
  constructor
  · intro hψ
    rw [if_pos hψ, mul_one] at hc
    exact eq_one_of_sum_eq_card (fun x _ => AddChar.norm_apply _ _) hc
  · intro hall
    by_contra hψ
    rw [if_neg hψ, mul_zero] at hc
    rw [Finset.sum_congr rfl (fun x hx => hall x hx)] at hc
    simp only [Finset.sum_const, nsmul_eq_mul, mul_one] at hc
    exact hScard hc

/-! ## The converse of Poisson summation -/

/-- **Converse of Poisson summation.**  If the Poisson identity
`|G| * ∑_{x ∈ S} f x = |S| * ∑_{ψ ∈ T} f̂ ψ` holds for all `f` and `S ≠ ∅`, then `S` is
(the underlying set of) a subgroup `H` of `G` and `T` is exactly the annihilator `H^⊥`. -/
theorem isPoissonPair_converse (h : IsPoissonPair S T) (hS : S.Nonempty) :
    ∃ H : AddSubgroup G, (∀ a : G, a ∈ S ↔ a ∈ H) ∧
      (∀ ψ : AddChar G ℂ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) := by
  refine ⟨preAnnih T, fun a => (mem_of_isPoissonPair h hS a).trans mem_preAnnih.symm, ?_⟩
  intro ψ
  rw [mem_dual_of_isPoissonPair h hS ψ]
  constructor
  · intro hall x hx
    exact hall x ((mem_of_isPoissonPair h hS x).2 (mem_preAnnih.1 hx))
  · intro hall x hx
    exact hall x (mem_preAnnih.2 ((mem_of_isPoissonPair h hS x).1 hx))

/-- The origin belongs to every nonempty Poisson set. -/
theorem zero_mem_of_isPoissonPair_primal (h : IsPoissonPair S T) (hS : S.Nonempty) :
    (0 : G) ∈ S :=
  (mem_of_isPoissonPair h hS 0).2 fun ψ _ => AddChar.map_zero_eq_one ψ

/-- Sharp form of the converse, primal side: `S` is exactly the annihilator of `T`. -/
theorem subFinset_preAnnih_eq (h : IsPoissonPair S T) (hS : S.Nonempty)
    [DecidablePred (· ∈ preAnnih T)] : subFinset (preAnnih T) = S := by
  ext a
  rw [mem_subFinset, mem_preAnnih, ← mem_of_isPoissonPair h hS a]

/-- Sharp form of the converse, dual side: `T` is exactly the annihilator of `T^⊥`. -/
theorem annih_preAnnih_eq (h : IsPoissonPair S T) (hS : S.Nonempty)
    [DecidablePred (· ∈ preAnnih T)] : annih (preAnnih T) = T := by
  ext ψ
  rw [mem_annih]
  constructor
  · intro hall
    refine (mem_dual_of_isPoissonPair h hS ψ).2 fun x hx => ?_
    exact hall x (mem_preAnnih.2 ((mem_of_isPoissonPair h hS x).1 hx))
  · intro hψ x hx
    exact mem_preAnnih.1 hx ψ hψ

/-- The forward direction, restated in the `IsPoissonPair` language: a subgroup together with
its annihilator is a Poisson pair.  (This is `FourierFA.poisson_summation`.) -/
theorem isPoissonPair_subgroup (H : AddSubgroup G) [DecidablePred (· ∈ H)] :
    IsPoissonPair (subFinset H) (annih H) := fun f => poisson_summation f

/-- **Classification of Poisson pairs.**  A pair `(S, T)` with `S ≠ ∅` satisfies the Poisson
identity for all test functions if and only if `S` is a subgroup and `T` is its annihilator. -/
theorem isPoissonPair_iff_subgroup (hS : S.Nonempty) :
    IsPoissonPair S T ↔ ∃ H : AddSubgroup G, (∀ a : G, a ∈ S ↔ a ∈ H) ∧
      (∀ ψ : AddChar G ℂ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) := by
  constructor
  · intro h; exact isPoissonPair_converse h hS
  · rintro ⟨H, hSH, hTH⟩
    classical
    have hS' : S = subFinset H := by
      ext a; rw [hSH a, mem_subFinset]
    have hT' : T = annih H := by
      ext ψ; rw [hTH ψ, mem_annih]
    rw [hS', hT']
    exact isPoissonPair_subgroup H

/-! ## Uniqueness -/

omit [DecidableEq G] in
/-- Each side of a nonempty Poisson pair determines the other: the dual side is unique. -/
theorem isPoissonPair_unique_dual {T' : Finset (AddChar G ℂ)} (h : IsPoissonPair S T)
    (h' : IsPoissonPair S T') (hS : S.Nonempty) : T = T' := by
  ext ψ
  rw [mem_dual_of_isPoissonPair h hS ψ, mem_dual_of_isPoissonPair h' hS ψ]

/-- Each side of a nonempty Poisson pair determines the other: the primal side is unique. -/
theorem isPoissonPair_unique_primal {S' : Finset G} (h : IsPoissonPair S T)
    (h' : IsPoissonPair S' T) (hS : S.Nonempty) (hS' : S'.Nonempty) : S = S' := by
  ext a
  rw [mem_of_isPoissonPair h hS a, mem_of_isPoissonPair h' hS' a]

/-! ## Biduality as a corollary -/

/-- **Biduality for subgroups**, `H^⊥⊥ = H`, obtained as a corollary of the converse of
Poisson summation rather than from Pontryagin duality. -/
theorem preAnnih_annih (H : AddSubgroup G) [DecidablePred (· ∈ H)] :
    preAnnih (annih H) = H := by
  have hS : (subFinset H).Nonempty := subFinset_nonempty
  have h := isPoissonPair_subgroup H
  ext a
  rw [mem_preAnnih, ← mem_of_isPoissonPair h hS a, mem_subFinset]

/-! ## Poisson pairs are the maximal all-ones rectangles of the character table -/

/-- **Rectangle bound for the character table.**  If every character in `T` is trivial on
every element of `S` — i.e. the `S × T` block of the character table is identically `1` —
then `|S| * |T| ≤ |G|`. -/
theorem rectangle_card_le (hones : ∀ x ∈ S, ∀ ψ ∈ T, ψ x = 1) :
    S.card * T.card ≤ Fintype.card G := by
  classical
  set H := preAnnih T with hH
  have hSsub : S ⊆ subFinset H := by
    intro x hx
    exact mem_subFinset.2 (mem_preAnnih.2 fun ψ hψ => hones x hx ψ hψ)
  have hTsub : T ⊆ annih H := by
    intro ψ hψ
    refine mem_annih.2 fun x hx => ?_
    exact mem_preAnnih.1 hx ψ hψ
  calc S.card * T.card ≤ (subFinset H).card * (annih H).card :=
        Nat.mul_le_mul (Finset.card_le_card hSsub) (Finset.card_le_card hTsub)
    _ = Fintype.card G := card_subgroup_mul_card_annihilator

/-- A pair of natural numbers dominated coordinatewise by another pair with the same product
must agree with it (the "no slack in a maximal rectangle" step). -/
private lemma eq_of_le_of_mul_eq {a b c d : ℕ} (hac : a ≤ c) (hbd : b ≤ d)
    (hpos : 0 < a) (hpos' : 0 < b) (heq : a * b = c * d) : a = c ∧ b = d := by
  have h1 : a * b ≤ c * b := Nat.mul_le_mul_right b hac
  have h2 : c * b ≤ c * d := Nat.mul_le_mul_left c hbd
  have hcb : c * b = c * d := le_antisymm h2 (by omega)
  have hab : a * b = c * b := le_antisymm h1 (by omega)
  have hc : 0 < c := lt_of_lt_of_le hpos hac
  exact ⟨Nat.eq_of_mul_eq_mul_right hpos' hab, Nat.eq_of_mul_eq_mul_left hc hcb⟩

/-- **Poisson pairs are exactly the all-ones rectangles of maximal area.**  A nonempty pair
`(S, T)` satisfies the analytic Poisson identity if and only if the `S × T` block of the
character table is identically `1` and its area is exactly `|G|`. -/
theorem isPoissonPair_iff_rectangle (hS : S.Nonempty) :
    IsPoissonPair S T ↔
      (∀ x ∈ S, ∀ ψ ∈ T, ψ x = 1) ∧ S.card * T.card = Fintype.card G := by
  classical
  constructor
  · intro h
    exact ⟨fun x hx ψ hψ => (mem_dual_of_isPoissonPair h hS ψ).1 hψ x hx,
      card_mul_card_of_isPoissonPair h hS⟩
  · rintro ⟨hones, harea⟩
    have hcardS : 0 < S.card := Finset.card_pos.2 hS
    have hcardT : 0 < T.card := by
      rcases Nat.eq_zero_or_pos T.card with h0 | h
      · rw [h0, Nat.mul_zero] at harea
        have hpos := Fintype.card_pos (α := G)
        omega
      · exact h
    set H := preAnnih T with hH
    have hSsub : S ⊆ subFinset H := fun x hx =>
      mem_subFinset.2 (mem_preAnnih.2 fun ψ hψ => hones x hx ψ hψ)
    have hTsub : T ⊆ annih H := fun ψ hψ =>
      mem_annih.2 fun x hx => mem_preAnnih.1 hx ψ hψ
    have hprod : (subFinset H).card * (annih H).card = Fintype.card G :=
      card_subgroup_mul_card_annihilator
    obtain ⟨h1, h2⟩ := eq_of_le_of_mul_eq (Finset.card_le_card hSsub)
      (Finset.card_le_card hTsub) hcardS hcardT (by rw [harea, hprod])
    have hSeq : S = subFinset H := Finset.eq_of_subset_of_card_le hSsub (le_of_eq h1.symm)
    have hTeq : T = annih H := Finset.eq_of_subset_of_card_le hTsub (le_of_eq h2.symm)
    rw [hSeq, hTeq]
    exact isPoissonPair_subgroup H

/-! ## The degenerate solution, and two extreme examples -/

omit [DecidableEq G] in
/-- The empty set is a (degenerate) Poisson set for *every* `T`: both sides of the identity
vanish.  Hence the nonemptiness hypothesis in the classification is necessary. -/
theorem isPoissonPair_empty (T : Finset (AddChar G ℂ)) :
    IsPoissonPair (∅ : Finset G) T := by
  intro f
  simp

/-- The trivial subgroup: the Dirac point `{0}` pairs with the whole dual group. -/
theorem isPoissonPair_zero_univ :
    IsPoissonPair ({0} : Finset G) (Finset.univ : Finset (AddChar G ℂ)) := by
  refine (isPoissonPair_iff_rectangle ⟨0, Finset.mem_singleton_self 0⟩).2 ⟨?_, ?_⟩
  · intro x hx ψ _
    rw [Finset.mem_singleton.1 hx, AddChar.map_zero_eq_one]
  · rw [Finset.card_singleton, one_mul, Finset.card_univ, AddChar.card_eq]

/-- The full group pairs with the trivial character alone. -/
theorem isPoissonPair_univ_zero :
    IsPoissonPair (Finset.univ : Finset G) ({0} : Finset (AddChar G ℂ)) := by
  refine (isPoissonPair_iff_rectangle ⟨0, Finset.mem_univ 0⟩).2 ⟨?_, ?_⟩
  · intro x _ ψ hψ
    rw [Finset.mem_singleton.1 hψ, AddChar.zero_apply]
  · rw [Finset.card_singleton, mul_one, Finset.card_univ]

end FourierFA