import Mathlib

/-!
# Shamir secret sharing

This file formalizes the algebraic and information-theoretic core of Shamir's
scheme over an arbitrary field.  A sharing polynomial has its secret as its
value at zero.  Privacy is expressed without choosing a probability API: after
fixing any values at `t - 1` nonzero locations, every possible secret has
exactly one degree-`< t` polynomial extension.  Consequently a uniformly
random sharing polynomial induces exactly the same observation distribution
for every secret.
-/

namespace ShamirSecretSharing

open Polynomial

variable {F : Type*} [Field F]

/-- The share carried by location `x` is polynomial evaluation at `x`. -/
def share (p : F[X]) (x : F) : F := p.eval x

/-- A polynomial is valid for threshold `t` and secret `secret` when its degree
is below `t` and its constant evaluation is the secret. -/
def ValidPolynomial (t : ℕ) (secret : F) (p : F[X]) : Prop :=
  p.degree < (t : WithBot ℕ) ∧ p.eval 0 = secret

/-- The unique low-degree extension of prescribed observations and a prescribed
secret.  This is the exact-counting form of perfect privacy: any observation at
`t-1` nonzero locations is compatible with every secret in exactly one way. -/
theorem perfect_privacy_extension [DecidableEq F]
    (observed : Finset F) (hzero : 0 ∉ observed) (t : ℕ)
    (hcard : observed.card + 1 = t) (values : F → F) (secret : F) :
    ∃! p : F[X],
      p.degree < (t : WithBot ℕ) ∧ p.eval 0 = secret ∧
        ∀ x ∈ observed, p.eval x = values x := by
  -- Let s = observed ∪ {0} be the set of all interpolation points
  let s : Finset F := observed ∪ {0}
  have hs_card : s.card = t := by
    simp [s, hzero, hcard]
  -- Define the values function on s
  let f : F → F := fun x => if x = 0 then secret else values x
  -- Use Lagrange interpolation
  use Lagrange.interpolate s id f
  refine ⟨⟨?_, ?_, ?_⟩, ?_⟩
  · -- degree < t
    have hinj : Set.InjOn (id : F → F) s := Set.injOn_id _
    have : (Lagrange.interpolate s id f).degree < s.card := Lagrange.degree_interpolate_lt f hinj
    simp [hs_card] at this
    exact this
  · -- eval 0 = secret
    have h0in : 0 ∈ s := by simp [s]
    simp only [Lagrange.interpolate_apply]
    rw [eval_finset_sum]
    rw [Finset.sum_eq_single_of_mem 0 h0in]
    · simp [f]
      have hinj : Set.InjOn (id : F → F) (s : Set F) := Set.injOn_id _
      have heval := Lagrange.eval_basis_self hinj h0in
      simp at heval
      rw [heval]
      ring
    · intro b hb hne
      have heval := @Lagrange.eval_basis_of_ne F _ _ _ s id b 0 hne h0in
      simp at heval
      simp [heval]
  · -- eval x = values x
    intro x hx
    have hx0 : x ≠ 0 := fun h => hzero (h ▸ hx)
    simp only [Lagrange.interpolate_apply, eval_finset_sum]
    rw [Finset.sum_eq_single_of_mem x (by simp [s, hx] : x ∈ s)]
    · simp [f, hx0]
      have hinj : Set.InjOn (id : F → F) (s : Set F) := Set.injOn_id _
      have heval := @Lagrange.eval_basis_self F _ _ _ s id x hinj (by simp [s, hx] : x ∈ s)
      simp at heval
      rw [heval]
      ring
    · intro b hb hne
      have heval := @Lagrange.eval_basis_of_ne F _ _ _ s id b x hne (by simp [s, hx] : x ∈ s)
      simp at heval
      simp [heval]
  · -- uniqueness
    intro y ⟨hy_deg, hy_zero, hy_obs⟩
    have hinj : Set.InjOn (id : F → F) (s : Set F) := Set.injOn_id _
    have hs_card' : s.card = t := hs_card
    -- y agrees with the interpolating polynomial at all points in s
    have hy_eval : ∀ x ∈ s, y.eval x = f x := by
      intro x hx
      simp [s] at hx
      rcases hx with (hx | hx)
      · rw [hx, hy_zero]; simp [f]
      · have hx0 : x ≠ 0 := fun h => hzero (h ▸ hx)
        simp [f, hx0, hy_obs x hx]
    -- The interpolating polynomial also agrees with f at all points in s
    -- By uniqueness of interpolation, y = Lagrange.interpolate s id f
    refine (Lagrange.eq_interpolate_iff f hinj).mp ?_
    refine ⟨?_, ?_⟩
    · simp [hs_card]; exact hy_deg
    · intro i hi
      exact hy_eval i hi

/-- In particular, observations at `t-1` locations never rule out either of two
candidate secrets. -/
theorem observations_reveal_no_secret [DecidableEq F]
    (observed : Finset F) (hzero : 0 ∉ observed) (t : ℕ)
    (hcard : observed.card + 1 = t) (values : F → F) (secret₁ secret₂ : F) :
    (∃ p : F[X], ValidPolynomial t secret₁ p ∧
        ∀ x ∈ observed, share p x = values x) ∧
    (∃ q : F[X], ValidPolynomial t secret₂ q ∧
        ∀ x ∈ observed, share q x = values x) := by
  constructor
  · obtain ⟨p, hp, _⟩ := perfect_privacy_extension observed hzero t hcard values secret₁
    exact ⟨p, ⟨hp.1, hp.2.1⟩, hp.2.2⟩
  · obtain ⟨q, hq, _⟩ := perfect_privacy_extension observed hzero t hcard values secret₂
    exact ⟨q, ⟨hq.1, hq.2.1⟩, hq.2.2⟩

/-- Values at `d+1` distinct locations uniquely determine a polynomial of degree
at most `d`.  This is reconstruction at the Shamir threshold. -/
theorem reconstruct_from_degree_plus_one [DecidableEq F]
    (locations : Finset F) (d : ℕ) (hcard : locations.card = d + 1)
    (p q : F[X]) (hp : p.degree ≤ (d : WithBot ℕ))
    (hq : q.degree ≤ (d : WithBot ℕ))
    (hagrees : ∀ x ∈ locations, p.eval x = q.eval x) : p = q := by
  by_contra hne
  have hdiff : p - q ≠ 0 := sub_ne_zero.mpr hne
  have hdeg : (p - q).degree ≤ (d : WithBot ℕ) := by
    exact (Polynomial.degree_sub_le p q).trans (max_le hp hq)
  have hroots : ∀ x ∈ locations, (p - q).eval x = 0 := by
    intro x hx
    rw [Polynomial.eval_sub, hagrees x hx, sub_self]
  have hcard_roots : (p - q).roots.toFinset.card ≤ d := by
    have h1 : (p - q).roots.toFinset.card ≤ (p - q).roots.card := Multiset.toFinset_card_le _
    have h2 : (p - q).roots.card ≤ (p - q).degree := Polynomial.card_roots hdiff
    have hchain : (↑(p - q).roots.card : WithBot ℕ) ≤ ↑d := h2.trans hdeg
    exact Nat.le_trans h1 (WithBot.coe_le_coe.mp hchain)
  have hsubset : locations ⊆ (p - q).roots.toFinset := by
    intro x hx
    exact Multiset.mem_toFinset.mpr (Polynomial.mem_roots hdiff |>.mpr (hroots x hx))
  have hcard_le : locations.card ≤ (p - q).roots.toFinset.card := Finset.card_le_card hsubset
  omega

/-- With only `d` nonzero locations, uniqueness can fail for degree-`d`
polynomials: zero and the vanishing product agree at every supplied location
but encode different values at zero. -/
theorem degree_many_shares_do_not_reconstruct [DecidableEq F]
    (locations : Finset F) (d : ℕ) (hcard : locations.card = d)
    (hzero : 0 ∉ locations) :
    ∃ p q : F[X], p ≠ q ∧
      p.degree ≤ (d : WithBot ℕ) ∧ q.degree ≤ (d : WithBot ℕ) ∧
      (∀ x ∈ locations, p.eval x = q.eval x) ∧ p.eval 0 ≠ q.eval 0 := by
  -- Define p as the product of (X - x) for all x in locations
  let p : F[X] := locations.prod (fun x => Polynomial.X - Polynomial.C x)
  -- Use q = 0 as the other polynomial
  -- First show p.eval 0 ≠ 0
  have heval0 : p.eval 0 ≠ 0 := by
    simp [p, Polynomial.eval_prod]
    apply Finset.prod_ne_zero_iff.mpr
    intro x hx
    intro heq
    simp_all
  refine ⟨p, 0, ?_, ?_, ?_, ?_, ?_⟩
  · exact fun h => heval0 <| h.symm ▸ by simp
  · -- p.degree ≤ d
    simp [p]
    have hdeg : ∀ x ∈ locations, (X - C x : F[X]).degree ≤ 1 := fun x _ => by simp
    refine le_trans (Polynomial.degree_prod_le _ _) ?_
    calc (∑ x ∈ locations, (X - C x : F[X]).degree)
        ≤ ∑ _x ∈ locations, (1 : WithBot ℕ) := Finset.sum_le_sum hdeg
      _ = locations.card := by simp
      _ = d := congrArg _ hcard
  · -- degree 0 ≤ d
    exact le_trans bot_le (WithBot.coe_le_coe.mpr (Nat.zero_le d))
  · -- ∀ x ∈ locations, p.eval x = 0
    intro x hx
    simp [p, Polynomial.eval_prod]
    rw [Finset.prod_eq_zero hx]
    simp
  · -- p.eval 0 ≠ 0
    simpa using heval0

/-- Combining sufficiency and necessity: the reconstruction threshold for
polynomials of degree at most `d` is exactly `d+1`. -/
theorem reconstruction_threshold_exact [DecidableEq F]
    (locations : Finset F) (d : ℕ) (hcard : locations.card = d)
    (hzero : 0 ∉ locations) :
    (∀ (more : Finset F), more.card = d + 1 →
      ∀ p q : F[X], p.degree ≤ (d : WithBot ℕ) → q.degree ≤ (d : WithBot ℕ) →
        (∀ x ∈ more, p.eval x = q.eval x) → p = q) ∧
    (∃ p q : F[X], p ≠ q ∧
      p.degree ≤ (d : WithBot ℕ) ∧ q.degree ≤ (d : WithBot ℕ) ∧
      (∀ x ∈ locations, p.eval x = q.eval x) ∧ p.eval 0 ≠ q.eval 0) := by
  constructor
  · intro more hmore p q hp hq hagrees
    exact reconstruct_from_degree_plus_one more d hmore p q hp hq hagrees
  · exact degree_many_shares_do_not_reconstruct locations d hcard hzero

end ShamirSecretSharing