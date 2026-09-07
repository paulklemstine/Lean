/-
  # Path Integrals along Evolutionary Paths

  This file closes Future Direction 4 ("Arithmetic Functions as Path Integrals")
  of the evolutionary-path research thread.

  Given a quotient system `Q` (see `Shared.EvolutionaryPathCore`) and a weight
  `w : Λ → M` on labels, the **path weight** of an object is the product of the
  weights of the labels of any complete evolutionary path out of it.  Because
  the label multiset is a well-defined invariant (`decomp`), the path weight is
  a *path-independent potential*:

  * `pathWeight_step`      : `pathWeight w x = w l * pathWeight w y` for a step `x --l--> y`;
  * `EvolPath.pathWeight_eq`: the weight of any path is the ratio of the potentials
                              at its endpoints (conservation law);
  * `pathAction_step`, `EvolPath.pathAction_eq` : the additive versions.

  Specialising to the arithmetic quotient system of `Shared.EvolutionaryPathArithmetic`
  gives an exact characterisation of the classical arithmetic function classes:

  * `natCompletelyMultiplicative_iff_pathWeight` : `g` is completely multiplicative
    (on positive integers) **iff** it is the path weight of its own restriction
    to the prime labels;
  * `natCompletelyAdditive_iff_pathAction`       : `f` is completely additive
    **iff** it is the path action of its restriction to the prime labels.

  Together with `natDecomp_count_eq_factorization` this says: completely
  additive arithmetic functions are exactly the conserved potentials of the
  multiplicative evolutionary flow.  Examples proved at the end: `Ω`
  (`natPathAction_one_eq_card_factors`) and the `p`-adic valuations.
-/
import Shared.EvolutionaryPathArithmetic

namespace Shared.EvolutionaryPath

universe u v

variable {α : Type u} {Λ : Type v} {Q : QuotientSystem α Λ}

section AbstractWeight

variable {M : Type*} [CommMonoid M]

/-- The **path weight** of `x` for the label weight `w`: the product of `w` over
the label multiset of any complete evolutionary path out of `x`. -/
noncomputable def pathWeight (Q : QuotientSystem α Λ) (w : Λ → M) (x : α) : M :=
  ((decomp Q x).map w).prod

theorem pathWeight_terminal {w : Λ → M} {x : α} (hx : Terminal Q x) :
    pathWeight Q w x = 1 := by
  simp [pathWeight, (terminal_iff_decomp_zero x).1 hx]

/-- One-step law: a quotient step multiplies the potential by the weight of its
label. -/
theorem pathWeight_step {w : Λ → M} {x y : α} {l : Λ} (h : Q.step x l y) :
    pathWeight Q w x = w l * pathWeight Q w y := by
  simp [pathWeight, decomp_step h]

/-- **Conservation law.**  The weight accumulated along *any* evolutionary path
from `x` to `y` depends only on the endpoints. -/
theorem EvolPath.pathWeight_eq {w : Λ → M} {x y : α} {ls : List Λ}
    (h : EvolPath Q x y ls) :
    pathWeight Q w x = (ls.map w).prod * pathWeight Q w y := by
  simp [pathWeight, h.labels_eq]

/-- Two evolutionary paths with the same endpoints accumulate the same weight. -/
theorem EvolPath.pathWeight_indep {w : Λ → M} {x y : α} {ls₁ ls₂ : List Λ}
    (h₁ : EvolPath Q x y ls₁) (h₂ : EvolPath Q x y ls₂) :
    (ls₁.map w).prod = (ls₂.map w).prod := by
  have := h₁.labels_unique h₂
  have h : ((ls₁ : Multiset Λ).map w).prod = ((ls₂ : Multiset Λ).map w).prod := by
    rw [this]
  simpa using h

end AbstractWeight

section AbstractAction

variable {M : Type*} [AddCommMonoid M]

/-- The **path action** of `x` for the label weight `w`: the sum of `w` over the
label multiset of any complete evolutionary path out of `x`. -/
noncomputable def pathAction (Q : QuotientSystem α Λ) (w : Λ → M) (x : α) : M :=
  ((decomp Q x).map w).sum

theorem pathAction_terminal {w : Λ → M} {x : α} (hx : Terminal Q x) :
    pathAction Q w x = 0 := by
  simp [pathAction, (terminal_iff_decomp_zero x).1 hx]

theorem pathAction_step {w : Λ → M} {x y : α} {l : Λ} (h : Q.step x l y) :
    pathAction Q w x = w l + pathAction Q w y := by
  simp [pathAction, decomp_step h]

/-- **Conservation law**, additive form. -/
theorem EvolPath.pathAction_eq {w : Λ → M} {x y : α} {ls : List Λ}
    (h : EvolPath Q x y ls) :
    pathAction Q w x = (ls.map w).sum + pathAction Q w y := by
  simp [pathAction, h.labels_eq]

theorem EvolPath.pathAction_indep {w : Λ → M} {x y : α} {ls₁ ls₂ : List Λ}
    (h₁ : EvolPath Q x y ls₁) (h₂ : EvolPath Q x y ls₂) :
    (ls₁.map w).sum = (ls₂.map w).sum := by
  have := h₁.labels_unique h₂
  have h : ((ls₁ : Multiset Λ).map w).sum = ((ls₂ : Multiset Λ).map w).sum := by
    rw [this]
  simpa using h

/-- Taking the constant weight `1` recovers the height. -/
theorem pathAction_one_eq_height (x : α) :
    pathAction Q (fun _ : Λ => (1 : ℕ)) x = height (Q := Q) x := by
  simp [pathAction, height]

end AbstractAction

section Arithmetic

/-- The arithmetic invariant is additive for products of positive integers. -/
theorem natDecomp_mul {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    decomp natSystem (m * n) = decomp natSystem m + decomp natSystem n := by
  have hmn : 0 < m * n := Nat.mul_pos hm hn
  rw [natDecomp_eq_primeFactorsList hmn, natDecomp_eq_primeFactorsList hm,
    natDecomp_eq_primeFactorsList hn]
  have hperm := Nat.perm_primeFactorsList_mul (a := m) (b := n) hm.ne' hn.ne'
  have : ((m * n).primeFactorsList : Multiset ℕ)
      = ((m.primeFactorsList ++ n.primeFactorsList : List ℕ) : Multiset ℕ) :=
    Quot.sound hperm
  rw [this]
  simp

variable {M : Type*} [CommMonoid M]

/-- The path weight of a product of primes is the product of the weights. -/
theorem natPathWeight_prod (w : ℕ → M) (L : List ℕ) (hL : ∀ p ∈ L, p.Prime) :
    pathWeight natSystem w L.prod = (L.map w).prod := by
  simp [pathWeight, natDecomp_prod L hL]

theorem natPathWeight_mul (w : ℕ → M) {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    pathWeight natSystem w (m * n)
      = pathWeight natSystem w m * pathWeight natSystem w n := by
  simp [pathWeight, natDecomp_mul hm hn]

theorem natPathWeight_prime (w : ℕ → M) {p : ℕ} (hp : p.Prime) :
    pathWeight natSystem w p = w p := by
  have := natPathWeight_prod w [p] (by simpa using hp)
  simpa using this

/-- A completely multiplicative function reproduces itself as a path weight. -/
theorem natPathWeight_of_completelyMultiplicative (g : ℕ → M) (hg1 : g 1 = 1)
    (hg : ∀ m n : ℕ, 0 < m → 0 < n → g (m * n) = g m * g n) {n : ℕ} (hn : 0 < n) :
    g n = pathWeight natSystem g n := by
  have key : ∀ L : List ℕ, (∀ p ∈ L, p.Prime) → g L.prod = (L.map g).prod := by
    intro L
    induction L with
    | nil => intro _; simpa using hg1
    | cons p L ih =>
        intro hL
        have hp : p.Prime := hL p (List.mem_cons_self ..)
        have hL' : ∀ q ∈ L, q.Prime := fun q hq => hL q (List.mem_cons_of_mem _ hq)
        have hpos : 0 < L.prod := List.prod_pos fun q hq => (hL' q hq).pos
        rw [List.prod_cons, hg p L.prod hp.pos hpos, ih hL', List.map_cons, List.prod_cons]
  have hprod : (n.primeFactorsList).prod = n := Nat.prod_primeFactorsList hn.ne'
  have hprime : ∀ p ∈ n.primeFactorsList, p.Prime :=
    fun p hp => Nat.prime_of_mem_primeFactorsList hp
  have h1 := key n.primeFactorsList hprime
  rw [hprod] at h1
  have h2 := natPathWeight_prod g n.primeFactorsList hprime
  rw [hprod] at h2
  rw [h1, h2]

/-- **Completely multiplicative functions are exactly the path weights** of the
multiplicative evolutionary flow. -/
theorem natCompletelyMultiplicative_iff_pathWeight (g : ℕ → M) :
    (g 1 = 1 ∧ ∀ m n : ℕ, 0 < m → 0 < n → g (m * n) = g m * g n) ↔
      ∀ n : ℕ, 0 < n → g n = pathWeight natSystem g n := by
  constructor
  · rintro ⟨hg1, hg⟩ n hn
    exact natPathWeight_of_completelyMultiplicative g hg1 hg hn
  · intro h
    refine ⟨?_, ?_⟩
    · rw [h 1 one_pos]
      exact pathWeight_terminal terminal_one
    · intro m n hm hn
      rw [h (m * n) (Nat.mul_pos hm hn), h m hm, h n hn, natPathWeight_mul g hm hn]

end Arithmetic

section ArithmeticAdditive

variable {M : Type*} [AddCommGroup M]

theorem natPathAction_prod (w : ℕ → M) (L : List ℕ) (hL : ∀ p ∈ L, p.Prime) :
    pathAction natSystem w L.prod = (L.map w).sum := by
  simp [pathAction, natDecomp_prod L hL]

theorem natPathAction_mul (w : ℕ → M) {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    pathAction natSystem w (m * n)
      = pathAction natSystem w m + pathAction natSystem w n := by
  simp [pathAction, natDecomp_mul hm hn]

theorem natPathAction_prime (w : ℕ → M) {p : ℕ} (hp : p.Prime) :
    pathAction natSystem w p = w p := by
  have := natPathAction_prod w [p] (by simpa using hp)
  simpa using this

/-- **Completely additive functions are exactly the path actions** of the
multiplicative evolutionary flow; the value at `1` is forced, so — unlike the
multiplicative case — no normalisation hypothesis is needed. -/
theorem natCompletelyAdditive_iff_pathAction (f : ℕ → M) :
    (∀ m n : ℕ, 0 < m → 0 < n → f (m * n) = f m + f n) ↔
      ∀ n : ℕ, 0 < n → f n = pathAction natSystem f n := by
  constructor
  · intro hf n hn
    have hf1 : f 1 = 0 := by
      have h := hf 1 1 one_pos one_pos
      simp only [Nat.mul_one] at h
      exact left_eq_add.mp h
    have key : ∀ L : List ℕ, (∀ p ∈ L, p.Prime) → f L.prod = (L.map f).sum := by
      intro L
      induction L with
      | nil => intro _; simpa using hf1
      | cons p L ih =>
          intro hL
          have hp : p.Prime := hL p (List.mem_cons_self ..)
          have hL' : ∀ q ∈ L, q.Prime := fun q hq => hL q (List.mem_cons_of_mem _ hq)
          have hpos : 0 < L.prod := List.prod_pos fun q hq => (hL' q hq).pos
          rw [List.prod_cons, hf p L.prod hp.pos hpos, ih hL', List.map_cons, List.sum_cons]
    have hprod : (n.primeFactorsList).prod = n := Nat.prod_primeFactorsList hn.ne'
    have hprime : ∀ p ∈ n.primeFactorsList, p.Prime :=
      fun p hp => Nat.prime_of_mem_primeFactorsList hp
    have h1 := key n.primeFactorsList hprime
    rw [hprod] at h1
    have h2 := natPathAction_prod f n.primeFactorsList hprime
    rw [hprod] at h2
    rw [h1, h2]
  · intro h m n hm hn
    rw [h (m * n) (Nat.mul_pos hm hn), h m hm, h n hn, natPathAction_mul f hm hn]

end ArithmeticAdditive

section Examples

/-- `Ω`, the number of prime factors with multiplicity, is the path action of
the constant weight `1`: it is the height of the arithmetic flow. -/
theorem natPathAction_one_eq_card_factors {n : ℕ} (hn : 0 < n) :
    pathAction natSystem (fun _ : ℕ => (1 : ℤ)) n = (n.primeFactorsList).length := by
  simp [pathAction, natDecomp_eq_primeFactorsList hn]

/-- The `p`-adic valuation is the path action of the indicator weight of the
label `p`; in particular it is completely additive. -/
theorem natPathAction_indicator_eq_factorization {p : ℕ} {n : ℕ} (hn : 0 < n) :
    pathAction natSystem (fun q : ℕ => if q = p then (1 : ℤ) else 0) n
      = n.factorization p := by
  have hcount := natDecomp_count_eq_factorization hn p
  have key : ∀ s : Multiset ℕ,
      (s.map (fun q : ℕ => if q = p then (1 : ℤ) else 0)).sum = (s.count p : ℤ) := by
    intro s
    induction s using Multiset.induction_on with
    | empty => simp
    | cons a s ih =>
        rcases eq_or_ne a p with rfl | h
        · simp [ih, add_comm]
        · simp [ih, h, Ne.symm h]
  rw [pathAction, key, hcount]

end Examples

end Shared.EvolutionaryPath