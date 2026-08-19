/-
# Arithmetic structure of the extremal class, and the bridge to Poisson rigidity

Two converse theorems were established earlier in this development:

* `FourierFA.poisson_converse` — a Poisson pair `(S, T)` with `S` nonempty consists of a
  subgroup and its annihilator;
* `FourierFA.isExtremal_iff_coset_modulation` — a nonzero `f` with
  `|supp f| · |supp f̂| = |G|` is a scalar times a character times the indicator of a coset.

This file draws the *arithmetic* consequences of the second one and connects it to the first.

Main results:

* `FourierFA.card_supp_eq_card_of_coset` : a set that is a coset of `K` has cardinality `|K|`.
* `FourierFA.coset_subgroup_unique` : the subgroup and the coset representative of an
  extremal function are unique (the subgroup absolutely, the representative modulo `K`).
* `FourierFA.isExtremal_subgroup_eq_diffSet` : that subgroup is the difference set of the
  support — a purely combinatorial description of `K`.
* `FourierFA.card_supp_dvd_card` / `FourierFA.card_supp_dft_dvd_card` : **Lagrange rigidity**,
  the support sizes of an extremal function divide `|G|`.
* `FourierFA.uncertainty_gap_of_not_dvd` : consequently the uncertainty inequality is *strict*
  — indeed off by at least one — whenever `|supp f|` fails to divide `|G|`; and
  `FourierFA.uncertainty_prime_gap`, the resulting gap `|G| + 1` on groups of prime order.
* `FourierFA.card_supp_isExtremal_iff` : the achievable extremal support sizes are exactly the
  subgroup orders of `G`.
* `FourierFA.exists_isExtremal_diffSet_eq` : every subgroup is realised this way, so the
  extremal class surjects onto the subgroup lattice.
* `FourierFA.isPoissonPair_of_delta_test` : Poisson summation is a *finite* test — the `|G|`
  Dirac identities already give the identity for all test functions, hence
  `FourierFA.poisson_converse_of_delta_test`.
* `FourierFA.zmod_card_supp_isExtremal_iff` : on `ℤ/n` the extremal support sizes are exactly
  the divisors of `n`.
* `FourierFA.poisson_pair_isExtremal` : every Poisson pair is the support pair of an extremal
  function, and `FourierFA.isPoissonPair_unique_subgroup` : the subgroup witnessing a Poisson
  pair is unique — so the two converse theorems describe one and the same object.
-/
import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierRigidity
import Probability.FourierExtremalConverse

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## Cosets and cardinalities -/

omit [DecidableEq G] in
/-- The finset of a subgroup has `Nat.card K` elements. -/
lemma card_subFinset (K : AddSubgroup G) [DecidablePred (· ∈ K)] :
    (subFinset K).card = Nat.card K := by
  classical
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
  simp [subFinset]

/-- A finset that is a coset `a + K` has exactly `|K|` elements. -/
lemma card_supp_eq_card_of_coset {S : Finset G} {K : AddSubgroup G} {a : G}
    (h : ∀ x, x ∈ S ↔ x - a ∈ K) : S.card = Nat.card K := by
  classical
  letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
  have himg : S = (subFinset K).image (fun t => t + a) := by
    ext x
    simp only [Finset.mem_image, mem_subFinset]
    constructor
    · intro hx
      exact ⟨x - a, (h x).1 hx, by abel⟩
    · rintro ⟨t, ht, rfl⟩
      exact (h _).2 (by simpa using ht)
  rw [himg, Finset.card_image_of_injective _ (add_left_injective a), card_subFinset]

/-! ## Uniqueness of the coset data -/

omit [Fintype G] [DecidableEq G] in
/-- **Uniqueness of the coset presentation.**  A nonempty finset can be a coset of at most one
subgroup, and its two representatives then differ by an element of that subgroup. -/
theorem coset_subgroup_unique {S : Finset G} {K₁ K₂ : AddSubgroup G} {a₁ a₂ : G}
    (h₁ : ∀ x, x ∈ S ↔ x - a₁ ∈ K₁) (h₂ : ∀ x, x ∈ S ↔ x - a₂ ∈ K₂) :
    K₁ = K₂ ∧ a₁ - a₂ ∈ K₂ := by
  have ha₁ : a₁ ∈ S := (h₁ a₁).2 (by simp)
  have hd : a₁ - a₂ ∈ K₂ := (h₂ a₁).1 ha₁
  refine ⟨?_, hd⟩
  ext t
  constructor
  · intro ht
    have hmem : t + a₁ ∈ S := (h₁ _).2 (by simpa using ht)
    have h' : t + a₁ - a₂ ∈ K₂ := (h₂ _).1 hmem
    have : t = (t + a₁ - a₂) - (a₁ - a₂) := by abel
    rw [this]
    exact K₂.sub_mem h' hd
  · intro ht
    have h' : t + a₁ - a₂ ∈ K₂ := by
      have : t + a₁ - a₂ = t + (a₁ - a₂) := by abel
      rw [this]
      exact K₂.add_mem ht hd
    have hmem : t + a₁ ∈ S := (h₂ _).2 h'
    have := (h₁ _).1 hmem
    simpa using this

omit [Fintype G] [DecidableEq G] in
/-- **The subgroup is the difference set of the support.**  If `S` is a coset of `K` then `K`
consists exactly of the differences of elements of `S`; in particular `K` is determined by `S`
combinatorially, with no reference to the analytic hypothesis. -/
theorem coset_subgroup_eq_diffSet {S : Finset G} {K : AddSubgroup G} {a : G}
    (h : ∀ x, x ∈ S ↔ x - a ∈ K) (t : G) :
    t ∈ K ↔ ∃ x ∈ S, x + t ∈ S := by
  constructor
  · intro ht
    refine ⟨a, (h a).2 (by simp), ?_⟩
    exact (h _).2 (by simpa using ht)
  · rintro ⟨x, hx, hxt⟩
    have h1 : x - a ∈ K := (h x).1 hx
    have h2 : x + t - a ∈ K := (h _).1 hxt
    have : t = (x + t - a) - (x - a) := by abel
    rw [this]
    exact K.sub_mem h2 h1

/-- The subgroup attached to an extremal function is the difference set of its support. -/
theorem isExtremal_subgroup_eq_diffSet (f : G → ℂ) (hf : f ≠ 0) (hext : IsExtremal f) :
    ∃ (K : AddSubgroup G) (a : G),
      (∀ x, x ∈ supp f ↔ x - a ∈ K) ∧ (∀ t, t ∈ K ↔ ∃ x ∈ supp f, x + t ∈ supp f) := by
  obtain ⟨K, a, hK⟩ := isExtremal_support_coset f hf hext
  exact ⟨K, a, hK, fun t => coset_subgroup_eq_diffSet hK t⟩

/-! ## Lagrange rigidity of the extremal support sizes -/

/-- **Lagrange rigidity.**  The support of an extremal function has cardinality dividing `|G|`.
This is a genuine restriction: it rules out, for instance, any extremal function with a
`3`-element support on `ℤ/4`. -/
theorem card_supp_dvd_card (f : G → ℂ) (hf : f ≠ 0) (hext : IsExtremal f) :
    (supp f).card ∣ Fintype.card G := by
  obtain ⟨K, a, hK⟩ := isExtremal_support_coset f hf hext
  rw [card_supp_eq_card_of_coset hK, ← Nat.card_eq_fintype_card]
  exact AddSubgroup.card_addSubgroup_dvd_card K

omit [DecidableEq G] in
/-- The frequency support of an extremal function also has cardinality dividing `|G|`, and the
two sizes are exactly complementary divisors. -/
theorem card_supp_dft_dvd_card (f : G → ℂ) (hext : IsExtremal f) :
    (supp (dft f)).card ∣ Fintype.card G :=
  Dvd.intro_left _ hext

omit [DecidableEq G] in
/-- The frequency support size of an extremal function is the complementary divisor. -/
theorem card_supp_dft_eq_div (f : G → ℂ) (hf : f ≠ 0) (hext : IsExtremal f) :
    (supp (dft f)).card = Fintype.card G / (supp f).card := by
  have hpos : 0 < (supp f).card :=
    Finset.card_pos.2 (supp_nonempty_of_ne_zero hf)
  rw [← hext, Nat.mul_div_cancel_left _ hpos]

/-- **A gap in the uncertainty principle.**  If the support size of `f` does not divide `|G|`,
then equality is impossible in `|supp f| · |supp f̂| ≥ |G|`, so the product is at least
`|G| + 1`. -/
theorem uncertainty_gap_of_not_dvd (f : G → ℂ) (hf : f ≠ 0)
    (hnd : ¬ (supp f).card ∣ Fintype.card G) :
    Fintype.card G + 1 ≤ (supp f).card * (supp (dft f)).card := by
  have hge := uncertainty f hf
  rcases lt_or_eq_of_le hge with h | h
  · omega
  · exact absurd (card_supp_dvd_card f hf h.symm) hnd

/-- **The prime gap.**  On a group of prime order, a function whose support is neither a single
point nor everything cannot come close to the uncertainty bound: its uncertainty product is at
least `p + 1`. -/
theorem uncertainty_prime_gap {p : ℕ} (hp : p.Prime) (hcard : Fintype.card G = p)
    (f : G → ℂ) (hf : f ≠ 0) (h1 : (supp f).card ≠ 1) (hp' : (supp f).card ≠ p) :
    p + 1 ≤ (supp f).card * (supp (dft f)).card := by
  refine hcard ▸ uncertainty_gap_of_not_dvd f hf ?_
  rw [hcard]
  intro hdvd
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
  · exact h1 h
  · exact hp' h

/-! ## Which support sizes occur -/

omit [Fintype G] [DecidableEq G] in
/-- The indicator of a subgroup is not the zero function. -/
lemma indic_ne_zero (K : AddSubgroup G) [DecidablePred (· ∈ K)] : indic K ≠ (0 : G → ℂ) := by
  intro h
  have := congrFun h 0
  simp [indic, K.zero_mem] at this

/-- **The spectrum of extremal support sizes.**  A natural number `m` is the support size of
some extremal function on `G` if and only if `G` has a subgroup of order `m`.  Combined with
`card_supp_dvd_card`, this pins the possible sizes down to the orders of subgroups — for a
cyclic group, exactly the divisors of `|G|`. -/
theorem card_supp_isExtremal_iff (m : ℕ) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = m) ↔
      ∃ K : AddSubgroup G, Nat.card K = m := by
  classical
  constructor
  · rintro ⟨f, hf, hext, hcard⟩
    obtain ⟨K, a, hK⟩ := isExtremal_support_coset f hf hext
    exact ⟨K, by rw [← card_supp_eq_card_of_coset hK, hcard]⟩
  · rintro ⟨K, hK⟩
    letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
    refine ⟨indic K, indic_ne_zero K, isExtremal_indic K, ?_⟩
    rw [supp_indic, card_subFinset, hK]

/-- **Every subgroup is realised, and recovered, by an extremal function.**  Together with
`isExtremal_subgroup_eq_diffSet` this makes the assignment "extremal function ↦ difference set of
its support" a surjection from the extremal class onto the subgroup lattice of `G`. -/
theorem exists_isExtremal_diffSet_eq (K : AddSubgroup G) :
    ∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ ∀ t, t ∈ K ↔ ∃ x ∈ supp f, x + t ∈ supp f := by
  classical
  letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
  refine ⟨indic K, indic_ne_zero K, isExtremal_indic K, ?_⟩
  have hcoset : ∀ x, x ∈ supp (indic K) ↔ x - 0 ∈ K := by
    intro x
    rw [supp_indic, mem_subFinset, sub_zero]
  exact fun t => coset_subgroup_eq_diffSet hcoset t

/-! ## The bridge: Poisson pairs are support pairs of extremals -/

/-- **Every Poisson pair is the support pair of an extremal function.**  This identifies the two
rigidity theorems of the development: the pairs `(S, T)` for which Poisson summation holds are
exactly the pairs `(supp f, supp f̂)` of extremal *indicator* functions. -/
theorem poisson_pair_isExtremal {S : Finset G} {T : Finset (AddChar G ℂ)}
    (h : IsPoissonPair S T) (hS : S.Nonempty) :
    ∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ supp f = S ∧ supp (dft f) = T := by
  classical
  obtain ⟨H, hSH, hTH⟩ := poisson_converse h hS
  letI : DecidablePred (· ∈ H) := fun _ => Classical.dec _
  refine ⟨indic H, indic_ne_zero H, isExtremal_indic H, ?_, ?_⟩
  · rw [supp_indic]
    ext x
    rw [mem_subFinset, ← hSH x]
  · rw [supp_dft_indic]
    ext ψ
    rw [mem_annih, ← hTH ψ]

/-- Conversely, the support pair of an extremal indicator is a Poisson pair: Poisson summation
characterises exactly this class. -/
theorem isPoissonPair_of_subgroup (H : AddSubgroup G) [DecidablePred (· ∈ H)] :
    IsPoissonPair (supp (indic H)) (supp (dft (indic H))) := by
  rw [supp_indic, supp_dft_indic]
  intro f
  exact poisson_summation f

/-- **Uniqueness of the subgroup behind a Poisson pair.**  A nonempty Poisson pair determines
its subgroup uniquely, so the correspondence `H ↦ (H, H^⊥)` between subgroups and Poisson pairs
is a bijection. -/
theorem isPoissonPair_unique_subgroup {S : Finset G} {T : Finset (AddChar G ℂ)}
    (h : IsPoissonPair S T) (hS : S.Nonempty) :
    ∃! H : AddSubgroup G, (∀ x, x ∈ S ↔ x ∈ H) ∧ (∀ ψ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) := by
  obtain ⟨H, hSH, hTH⟩ := poisson_converse h hS
  refine ⟨H, ⟨hSH, hTH⟩, ?_⟩
  rintro H' ⟨hSH', -⟩
  ext x
  rw [← hSH' x, hSH x]

/-- The cardinality of a Poisson set divides `|G|` — Lagrange's theorem, read off from the
analytic identity alone. -/
theorem poisson_card_dvd {S : Finset G} {T : Finset (AddChar G ℂ)}
    (h : IsPoissonPair S T) (hS : S.Nonempty) : S.card ∣ Fintype.card G :=
  Dvd.intro _ (poisson_card_mul h hS).2

/-! ## Poisson summation is a finite test: Dirac functions suffice -/

/-- **Dirac functions are a sufficient test family.**  If the Poisson identity holds for the
`|G|` Dirac deltas, it holds for *every* test function: both sides are linear in `f` and the
deltas span `G → ℂ`.  So `IsPoissonPair` — an a priori infinite family of conditions — is a
finite linear system. -/
theorem isPoissonPair_of_delta_test {S : Finset G} {T : Finset (AddChar G ℂ)}
    (h : ∀ y : G, (Fintype.card G : ℂ) * (if y ∈ S then 1 else 0)
        = (S.card : ℂ) * ∑ ψ ∈ T, conj (ψ y)) :
    IsPoissonPair S T := by
  classical
  intro f
  have h1 : ∑ y : G, f y * (if y ∈ S then (1 : ℂ) else 0) = ∑ x ∈ S, f x := by
    simp [mul_ite, Finset.sum_ite_mem, Finset.univ_inter]
  have h2 : ∑ ψ ∈ T, dft f ψ = ∑ y : G, f y * ∑ ψ ∈ T, conj (ψ y) := by
    simp only [dft]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun ψ _ => by ring
  calc (Fintype.card G : ℂ) * ∑ x ∈ S, f x
      = ∑ y : G, f y * ((Fintype.card G : ℂ) * (if y ∈ S then 1 else 0)) := by
        rw [← h1, Finset.mul_sum]
        exact Finset.sum_congr rfl fun y _ => by ring
    _ = ∑ y : G, f y * ((S.card : ℂ) * ∑ ψ ∈ T, conj (ψ y)) :=
        Finset.sum_congr rfl fun y _ => by rw [h y]
    _ = (S.card : ℂ) * ∑ y : G, f y * ∑ ψ ∈ T, conj (ψ y) := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun y _ => by ring
    _ = (S.card : ℂ) * ∑ ψ ∈ T, dft f ψ := by rw [h2]

/-- **Finite-test rigidity.**  A nonempty `S` and a set `T` of characters satisfying the `|G|`
Dirac Poisson identities are already a subgroup together with its annihilator: the whole
structure theorem is forced by finitely many scalar equations. -/
theorem poisson_converse_of_delta_test {S : Finset G} {T : Finset (AddChar G ℂ)}
    (h : ∀ y : G, (Fintype.card G : ℂ) * (if y ∈ S then 1 else 0)
        = (S.card : ℂ) * ∑ ψ ∈ T, conj (ψ y)) (hS : S.Nonempty) :
    ∃ H : AddSubgroup G, (∀ x, x ∈ S ↔ x ∈ H) ∧ (∀ ψ, ψ ∈ T ↔ ∀ x ∈ H, ψ x = 1) :=
  poisson_converse (isPoissonPair_of_delta_test h) hS

/-! ## The cyclic case: the extremal spectrum is the divisor lattice -/

/-- A cyclic group has a subgroup of every order dividing its own. -/
lemma exists_addSubgroup_card_of_dvd {n d : ℕ} [NeZero n] (hd : d ∣ n) :
    ∃ K : AddSubgroup (ZMod n), Nat.card K = d := by
  have hn : n ≠ 0 := NeZero.ne n
  obtain ⟨e, he⟩ := hd
  have he0 : e ≠ 0 := by
    rintro rfl
    exact hn (by simpa using he)
  refine ⟨AddSubgroup.zmultiples ((e : ℕ) : ZMod n), ?_⟩
  rw [Nat.card_zmultiples, ZMod.addOrderOf_coe _ hn]
  have hgcd : n.gcd e = e := Nat.gcd_eq_right ⟨d, by rw [he]; ring⟩
  rw [hgcd, he, Nat.mul_div_cancel _ (Nat.pos_of_ne_zero he0)]

/-- **The extremal spectrum of a cyclic group.**  On `ℤ/n`, a number `d` is the support size of
some extremal function precisely when `d` divides `n`: the classification collapses to the
divisor lattice.  (On `ℤ/4` this predicts support sizes `1, 2, 4` and forbids `3`, exactly as
the exhaustive computation in `FourierExtremalEvidence` finds.) -/
theorem zmod_card_supp_isExtremal_iff (n : ℕ) [NeZero n] (d : ℕ) :
    (∃ f : ZMod n → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = d) ↔ d ∣ n := by
  classical
  rw [card_supp_isExtremal_iff]
  constructor
  · rintro ⟨K, rfl⟩
    have := AddSubgroup.card_addSubgroup_dvd_card K
    rwa [Nat.card_eq_fintype_card (α := ZMod n), ZMod.card n] at this
  · exact fun hd => exists_addSubgroup_card_of_dvd hd

end FourierFA