/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.SpectralNuclei.BasicOpen

/-! # Prime Separation and Stone Duality for Frames

This file contains the deep results of the spectral theory:

1. **Prime extension** (`exists_primeElement_separating`): if `k` is compact
   and `¬(k ≤ a)`, there exists a prime `p` with `a ≤ p` and `¬(k ≤ p)`.
   This is proved by Zorn's lemma + distributivity.

2. **Stone duality** (`le_iff_forall_primeElement`): in a compactly generated
   frame, `a ≤ b ↔ ∀ p prime, b ≤ p → a ≤ p`.

3. **Algebraicity extraction** (`compact_below_of_not_le`): in a compactly
   generated lattice, if `¬(a ≤ b)`, there is a compact `k ≤ a` with `¬(k ≤ b)`.

## Proof strategy

The prime extension theorem follows the classical Stone/Krull argument:

1. Define `S = {j | a ≤ j ∧ ¬(k ≤ j)}`, which is nonempty (contains `a`).
2. Show `S` is closed under directed suprema (using compactness of `k`).
3. Apply Zorn to get a maximal element `p ∈ S`.
4. Show `p` is prime using distributivity of the frame:
   if `x ⊓ y ≤ p` but `x ≤ p` and `y ≤ p` both fail, then
   `k ≤ p ⊔ x` and `k ≤ p ⊔ y` by maximality, so
   `k ≤ (p ⊔ x) ⊓ (p ⊔ y) = p ⊔ (x ⊓ y) = p`, contradiction.
-/

open Set Order

universe u

variable {L : Type u} [Order.Frame L]

/-! ### Algebraicity extraction -/

/-
In a compactly generated lattice, if `a ≤ b` fails, there exists a
compact element `k ≤ a` with `k ≤ b` also failing. This reduces arbitrary
order failures to compact order failures.
-/
theorem compact_below_of_not_le
    [IsCompactlyGenerated L]
    {a b : L} (h : ¬ a ≤ b) :
    ∃ k : L, IsCompactElement k ∧ k ≤ a ∧ ¬ k ≤ b := by
  obtain ⟨ S, hS ⟩ := @IsCompactlyGenerated.exists_sSup_eq L _ _ a;
  contrapose! h;
  exact hS.2 ▸ sSup_le fun x hx => h x ( hS.1 x hx ) ( hS.2 ▸ le_sSup hx )

/-! ### Prime extension theorem -/

/-
**Maximal elements of separating sets are prime.**

If `p` is maximal in `{j | a ≤ j ∧ ¬(k ≤ j)}` within a frame, then `p` is
prime (w.r.t. finite meets). The proof uses frame distributivity:
`(p ⊔ x) ⊓ (p ⊔ y) = p ⊔ (x ⊓ y)`.
-/
theorem maximal_separating_is_prime
    {k a p : L}
    (hp_mem : a ≤ p ∧ ¬ k ≤ p)
    (hp_max : ∀ q, a ≤ q → ¬ k ≤ q → p ≤ q → q ≤ p) :
    ∀ ⦃x y : L⦄, x ⊓ y ≤ p → x ≤ p ∨ y ≤ p := by
  intro x y hxy; contrapose! hxy;
  -- By maximality, since x ≤ p fails, we have p < p ⊔ x (because p ⊔ x ≥ p and p ⊔ x = p would mean x ≤ p). By maximality (hp_max applied to p ⊔ x), since a ≤ p ≤ p ⊔ x and ¬(k ≤ p) but p < p ⊔ x, we must have ¬(a ≤ p ⊔ x) or k ≤ p ⊔ x. Since a ≤ p ≤ p ⊔ x, it must be k ≤ p ⊔ x. Similarly k ≤ p ⊔ y.
  have hkpx : k ≤ p ⊔ x := by
    contrapose! hp_max;
    exact ⟨ p ⊔ x, le_sup_of_le_left hp_mem.1, hp_max, le_sup_left, fun h => hxy.1 <| le_trans ( le_sup_right ) h ⟩
  have hkpy : k ≤ p ⊔ y := by
    contrapose! hp_max;
    exact ⟨ p ⊔ y, le_sup_of_le_left hp_mem.1, hp_max, le_sup_left, fun h => hxy.2 <| le_trans ( le_sup_right ) h ⟩;
  -- Then k ≤ (p ⊔ x) ⊓ (p ⊔ y) = p ⊔ (x ⊓ y) (by distributivity, using sup_inf_left.symm).
  have hkpxy : k ≤ p ⊔ (x ⊓ y) := by
    exact le_trans ( le_inf hkpx hkpy ) ( by rw [ sup_inf_left ] );
  intro h; have := hp_max ( p ⊔ x ⊓ y ) ?_ ?_ ?_ <;> simp_all +decide [ sup_le_iff ] ;

/-
**Prime extension / spectral separation lemma.**

This is the decisive engine of Stone duality for frames. If `k` is compact
and `¬(k ≤ a)`, then there exists a prime element `p` with `a ≤ p` and
`¬(k ≤ p)`. The prime separates `k` from `a` in the spectrum.

The proof uses Zorn's lemma to find a maximal element in the set
`{j | a ≤ j ∧ ¬(k ≤ j)}`, then shows this maximal element is prime
using frame distributivity. Compactness of `k` ensures that chains
in the separating set have upper bounds (a directed supremum cannot
contain a compact element unless some member of the chain already does).
-/
theorem exists_primeElement_separating
    {k a : L}
    (hk : IsCompactElement k)
    (hnot : ¬ k ≤ a) :
    ∃ p : PrimeElement L, a ≤ p.val ∧ ¬ k ≤ p.val := by
  have := @zorn_le_nonempty₀;
  contrapose! this;
  refine' ⟨ L, inferInstance, { x | a ≤ x ∧ ¬k ≤ x }, _, _ ⟩;
  · intro c hc hc' y hy;
    refine' ⟨ sSup c, ⟨ _, _ ⟩, fun z hz => le_sSup hz ⟩;
    · exact le_trans ( hc hy |>.1 ) ( le_sSup hy );
    · have := hk c ( sSup c ) ⟨ y, hy ⟩ hc'.directedOn ( isLUB_sSup c );
      exact fun h => by obtain ⟨ x, hx, hx' ⟩ := this h; exact hc hx |>.2 hx';
  · refine' ⟨ a, ⟨ le_rfl, hnot ⟩, fun m hm₁ hm₂ => _ ⟩;
    -- Since $m$ is maximal in the set $\{x \mid a \leq x \land \neg k \leq x\}$, it must be prime.
    have h_prime : ∀ x y : L, x ⊓ y ≤ m → x ≤ m ∨ y ≤ m := by
      apply maximal_separating_is_prime;
      exact ⟨ hm₁, hm₂.1.2 ⟩;
      exact fun q hq₁ hq₂ hq₃ => hm₂.2 ⟨ hq₁, hq₂ ⟩ hq₃;
    have h_prime : m ≠ ⊤ := by
      rintro rfl; simp_all +decide [ Maximal ];
    exact absurd ( this ⟨ m, h_prime, by assumption ⟩ hm₁ ) hm₂.1.2

/-! ### Stone duality / closure theorem -/

/-
**Compact Stone duality**: for compact elements, containment in the frame
is equivalent to containment at all prime elements.

`k ≤ a ↔ ∀ p prime, a ≤ p → k ≤ p`

The forward direction is trivial (transitivity). The reverse direction is
the contrapositive of prime separation.
-/
theorem le_iff_forall_primeElement_of_compact
    {k a : L}
    (hk : IsCompactElement k) :
    k ≤ a ↔ ∀ p : PrimeElement L, a ≤ p.val → k ≤ p.val := by
  refine' ⟨ fun h p hp => le_trans h hp, fun h => _ ⟩;
  by_contra h_contra;
  obtain ⟨ p, hp₁, hp₂ ⟩ := exists_primeElement_separating hk h_contra;
  exact hp₂ ( h p hp₁ )

/-
**Full Stone duality / semantic consequence theorem**: in a compactly
generated frame, `a ≤ b ↔ ∀ p prime, b ≤ p → a ≤ p`.

This is the order-theoretic Stone duality statement. It says:
*`a` is forced by `b` iff every prime world containing `b` also contains `a`.*

When specialized to the frame of nuclei on a proof semiring, this gives
a genuine spectral geometry for proof semantics: semantic consequence
becomes geometric visibility across prime proof-worlds.
-/
theorem le_iff_forall_primeElement
    [IsCompactlyGenerated L]
    (a b : L) :
    a ≤ b ↔ ∀ p : PrimeElement L, b ≤ p.val → a ≤ p.val := by
  constructor
  · exact fun h p hp => le_trans h hp
  · intro h
    by_contra hab
    obtain ⟨k, hk_compact, hka, hkb⟩ := compact_below_of_not_le hab
    obtain ⟨p, hbp, hkp⟩ := exists_primeElement_separating hk_compact hkb
    exact hkp (le_trans hka (h p hbp))

/-! ### Basic-open reformulation -/

/-- The Stone duality theorem reformulated in terms of basic opens:
`k ≤ a` iff `D(k)` is contained in the complement of `D(a)`... actually,
let us state it as: for compact `k`, `k ≤ a` iff `basicOpen L a ⊆ basicOpen L k`'s
complement, i.e., iff every prime in `D(a)ᶜ` is also in `D(k)ᶜ`.

A cleaner formulation: `k ≤ a ↔ basicOpen L k ⊆ basicOpen L a` is just
monotonicity. The Stone duality gives the converse direction. -/
theorem le_iff_basicOpen_subset_of_compact
    {k a : L}
    (hk : IsCompactElement k) :
    k ≤ a ↔ ∀ p : PrimeElement L, a ≤ p.val → k ≤ p.val :=
  le_iff_forall_primeElement_of_compact hk