import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder

/-! # The poset of p-degrees and a generic separation template

This file is the **second cycle** of the order-theoretic Cook–Reckhow development begun in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`.  That file proved that the
p-simulation relation `Simulates` on abstract proof systems is a `Preorder` and that
`PEquiv` (mutual simulation) is a `Setoid`.  Here we push the structure theory further and
make the separation phenomenon *concrete*:

* **Generic separation template** (`no_simulation_of_hard`).  The Fibonacci separation
  `ProofComplexity.no_simulation_of_fib_hard` used only one property of `Nat.fib`: that it
  is *not* polynomially bounded.  We abstract the hardness function to an arbitrary
  `s : ℕ → ℕ` with `¬ PolyBounded s`, recovering the Fibonacci statement as the special
  case `s = Nat.fib` (`not_polyBounded_fib`).  The engine is the monotonicity lemma
  `polyBounded_of_le`: domination by a polynomially bounded function is itself polynomially
  bounded.

* **Concrete witnesses** (`linSystem`, `fibSystem`, `exists_separated_pair`).  We exhibit
  two honest proof systems over `Thm = ℕ` — one with linear proof size, one with Fibonacci
  proof size — and prove the linear system is *not* p-simulated by the Fibonacci one.  This
  shows the simulation preorder is genuinely non-trivial: not all systems collapse to one
  p-degree.

* **Antisymmetrization** (`pEquiv_iff_antisymmRel`, `exists_two_distinct_pdegrees`).  We
  identify `PEquiv` with Mathlib's `AntisymmRel (· ≤ ·)`, so the canonical poset of
  *p-degrees* is exactly `Antisymmetrization (ProofSystem Thm) (· ≤ ·)` with its library
  `PartialOrder`.  The concrete separation upgrades to two genuinely distinct p-degrees,
  proving the poset has at least two points.

-- !-- Lab Notebook -- !--
Hypothesis : (1) The Fibonacci separation should be an instance of a purely growth-theoretic
             template parameterized by any non-polynomial hardness function.  (2) The
             abstract preorder should antisymmetrize to Mathlib's `Antisymmetrization`
             poset with no extra work, and the Fibonacci bound should furnish an explicit
             pair of distinct p-degrees, witnessing non-triviality.
Result     : Both confirmed with `sorry = 0`.  `no_simulation_of_hard` generalizes the
             Fibonacci separation; `exists_separated_pair` and `exists_two_distinct_pdegrees`
             give concrete witnesses; `pEquiv_iff_antisymmRel` is definitional.
Insight    : The *only* arithmetic input to any simulation separation is the closure
             fact `polyBounded_of_le` (a function below a polynomially-bounded one is
             polynomially bounded).  Everything else is order theory.  Hence "P fails to
             p-simulate Q" is equivalent to "the simulation blow-up would have to escape
             the polynomial class", which is a statement purely about growth classes — this
             is what makes the template parametric in the hardness function.
Failure analysis : A first instinct was to construct the concrete witnesses with `Fin`
             indexed proofs; using `Thm = ℕ` with `proves = id` (so completeness is just
             `Function.surjective_id`) removes all index bookkeeping and makes the hardness
             hypothesis `s n ≤ size pf` reduce to `rfl` after substitution.
-- !-- Lab Notebook -- !--
-/

namespace ProofComplexity

/-! ## Growth-class engine: domination is polynomially bounded -/

-- !-- comment: A function pointwise below a polynomially-bounded one is itself
--             polynomially bounded — the single arithmetic fact behind every separation. -- !--
/-- If `s n ≤ f n` for all `n` and `f` is polynomially bounded, so is `s`. -/
lemma polyBounded_of_le {s f : ℕ → ℕ} (hle : ∀ n, s n ≤ f n) (hf : PolyBounded f) :
    PolyBounded s := by
  obtain ⟨k, hk⟩ := hf
  exact ⟨k, fun n => le_trans (by have := hle n; omega) (hk n)⟩

/-! ## Generic separation template -/

-- !-- comment: The Fibonacci separation, freed of `Nat.fib`: any non-polynomial hardness
--             lower bound `s` separates `P` from `Q`. -- !--
/-- **Generic separation template.**  Suppose `Q` proves a family of theorems `t n` with
proofs of size `≤ n`, while every `P`-proof of `t n` has size `≥ s n` for some hardness
function `s` that is *not* polynomially bounded.  Then `P` does **not** p-simulate `Q`.
(`no_simulation_of_fib_hard` is the case `s = Nat.fib`.) -/
theorem no_simulation_of_hard {P Q : ProofSystem.{u, v} Thm}
    (t : ℕ → Thm) (q : ℕ → Q.Proof)
    (hq : ∀ n, Q.proves (q n) = t n) (hqs : ∀ n, Q.size (q n) ≤ n)
    (s : ℕ → ℕ) (hs : ¬ PolyBounded s)
    (hhard : ∀ n (pf : P.Proof), P.proves pf = t n → s n ≤ P.size pf) :
    ¬ Simulates P Q := by
  rintro ⟨f, ⟨hmono, hpb⟩, hsim⟩
  have hdom : ∀ n, s n ≤ f n := by
    intro n
    obtain ⟨p, hp_proves, hp_size⟩ := hsim (q n)
    have hp_t : P.proves p = t n := by rw [hp_proves, hq]
    have h1 : s n ≤ P.size p := hhard n p hp_t
    have h3 : f (Q.size (q n)) ≤ f n := hmono (hqs n)
    omega
  exact hs (polyBounded_of_le hdom hpb)

/-- The Fibonacci separation `no_simulation_of_fib_hard` recovered as the instance
`s = Nat.fib` of the generic template. -/
theorem no_simulation_of_fib_hard_via_template {P Q : ProofSystem.{u, v} Thm}
    (t : ℕ → Thm) (q : ℕ → Q.Proof)
    (hq : ∀ n, Q.proves (q n) = t n) (hqs : ∀ n, Q.size (q n) ≤ n)
    (hhard : ∀ n (pf : P.Proof), P.proves pf = t n → Nat.fib n ≤ P.size pf) :
    ¬ Simulates P Q :=
  no_simulation_of_hard t q hq hqs Nat.fib not_polyBounded_fib hhard

/-! ## Concrete witnesses over `Thm = ℕ` -/

-- !-- comment: A linear-size proof system over `ℕ`: a proof of `n` is `n` itself. -- !--
/-- The **linear** proof system over `ℕ`: proofs are theorems, size is the identity. -/
def linSystem : ProofSystem.{0, 0} ℕ where
  Proof := ℕ
  proves := id
  size := id
  complete := Function.surjective_id

-- !-- comment: A Fibonacci-size proof system over `ℕ`: a proof of `n` has size `F n`. -- !--
/-- The **Fibonacci** proof system over `ℕ`: proofs are theorems, but the size of the proof
of `n` is `F n`. -/
def fibSystem : ProofSystem.{0, 0} ℕ where
  Proof := ℕ
  proves := id
  size := Nat.fib
  complete := Function.surjective_id

-- !-- comment: The linear system is not p-simulated by the Fibonacci one — a concrete,
--             non-vacuous separation, so the preorder is non-trivial. -- !--
/-- **Concrete separation.**  The linear system `linSystem` is *not* p-simulated by the
Fibonacci system `fibSystem`: simulating it would force a polynomial bound on `F`. -/
theorem exists_separated_pair : ∃ P Q : ProofSystem.{0, 0} ℕ, ¬ Simulates P Q := by
  refine ⟨fibSystem, linSystem, ?_⟩
  refine no_simulation_of_hard (P := fibSystem) (Q := linSystem)
    (t := id) (q := id) (fun _ => rfl) (fun n => le_refl n) Nat.fib not_polyBounded_fib ?_
  intro n pf hpf
  -- `fibSystem.proves pf = pf` and `t n = n`, so `pf = n`; size is `F`.
  simp only [fibSystem, id] at hpf ⊢
  subst hpf
  exact le_refl _

/-! ## The poset of p-degrees (antisymmetrization) -/

-- !-- comment: p-equivalence is exactly Mathlib's `AntisymmRel` for `≤ = Simulates`. -- !--
/-- p-equivalence is exactly the antisymmetry relation of the simulation preorder.  Hence
the canonical poset of **p-degrees** is `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`, with
the `PartialOrder` instance supplied by Mathlib. -/
theorem pEquiv_iff_antisymmRel (P Q : ProofSystem.{u, v} Thm) :
    PEquiv P Q ↔ AntisymmRel (· ≤ ·) P Q := Iff.rfl

-- !-- comment: Two genuinely distinct p-degrees — the poset has ≥ 2 points. -- !--
/-- **The poset of p-degrees is non-trivial.**  `fibSystem` and `linSystem` map to distinct
points of `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, so the partial order of p-degrees
has at least two elements. -/
theorem exists_two_distinct_pdegrees :
    ∃ a b : Antisymmetrization (ProofSystem.{0, 0} ℕ) (· ≤ ·), a ≠ b := by
  refine ⟨Quotient.mk (AntisymmRel.setoid _ (· ≤ ·)) fibSystem,
          Quotient.mk (AntisymmRel.setoid _ (· ≤ ·)) linSystem, ?_⟩
  intro h
  rw [Quotient.eq] at h
  -- `h : AntisymmRel (· ≤ ·) fibSystem linSystem`, i.e. `PEquiv`; its first half is
  -- `Simulates fibSystem linSystem`, contradicting `exists_separated_pair`'s witness.
  have hsim : Simulates fibSystem linSystem := h.1
  refine no_simulation_of_hard (P := fibSystem) (Q := linSystem)
    (t := id) (q := id) (fun _ => rfl) (fun n => le_refl n) Nat.fib not_polyBounded_fib ?_ hsim
  intro n pf hpf
  simp only [fibSystem, id] at hpf ⊢
  subst hpf
  exact le_refl _

end ProofComplexity