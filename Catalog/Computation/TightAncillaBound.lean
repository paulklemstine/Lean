/-
# Tight Ancilla Bound for Reversible Simulation

This file extends `Computation.ReversibleSortingBennett` (which proved Bennett's
reversible-witness theorem and the *lower* bound `rev_witness_aux_lower_bound`
in the special case of a genuine bijection `α ≃ β × Aux`) to the genuinely
general — and harder — situation of an arbitrary, possibly **non-surjective**
function.

A *reversible simulation* of `f : α → β` is an **injection**
`g : α → β × Aux` whose first component recovers `f`.  Unlike a `RevWitness`
(which demands a bijection, forcing `|β| ∣ |α|`), a reversible simulation
exists for every `f`, and the question becomes: how small can the ancilla
type `Aux` be?

## Main results

* `maxFiberSize_le_card_of_revSim` — **lower bound**: every reversible
  simulation needs ancilla space at least `maxFiberSize f`.
* `exists_revSim_fin_maxFiber` — **upper bound**: there is a reversible
  simulation with ancilla type `Fin (maxFiberSize f)`.
* `tight_ancilla_bound` — the two combine: `maxFiberSize f` is the exact
  minimal ancilla cardinality, and no simulation into `Fin (maxFiberSize f - 1)`
  exists once `f` has a nontrivial fiber.
* `maxFiberSize_le_one_iff_injective` — `f` is injective iff its largest
  fiber has size `≤ 1`, i.e. iff one ancilla state suffices.

These results reuse `maxFiberSize` from `ReversibleSortingBennett` and sharpen
`rev_witness_aux_lower_bound`.
-/

import Mathlib
import Computation.ReversibleSortingBennett

open Finset Function

namespace TightAncilla

-- !-- Lab Notebook --!--
-- Hypothesis: The Bennett witness in the catalog is restricted to bijections
--   `α ≃ β × Aux`, which only exist when `|β|` divides `|α|`. We conjectured the
--   right invariant for *arbitrary* functions is `maxFiberSize f`, realised by an
--   *injection* rather than a bijection.
-- Result: Proved both directions — `maxFiberSize f` ancilla states are necessary
--   (pigeonhole on a single fiber) and sufficient (sigma/fiber enumeration).
-- Insight: The fiber sigma-equivalence `Equiv.sigmaFiberEquiv` is the load-bearing
--   tool: it reduces the upper bound to embedding each fiber into `Fin k`.
-- Failure analysis: An earlier attempt tried to build the index function
--   `α → Fin k` by hand via `Finset.sort`; bounding the index was painful. Routing
--   through the sigma type and `Embedding.nonempty_of_card_le` removed all the
--   arithmetic.
-- !-- end Lab Notebook --!--

/-- A **reversible simulation** of `f : α → β`: an injection into `β × Aux`
whose first component recovers `f`.  The ancilla type `Aux` records exactly the
information lost by `f`. -/
structure RevSim {α β : Type*} (f : α → β) where
  /-- The ancilla ("history") type. -/
  Aux : Type*
  /-- The simulating injection. -/
  encode : α → β × Aux
  /-- The encoding is injective — this is what "reversible" means. -/
  enc_inj : Function.Injective encode
  /-- The first component recovers the original function. -/
  consistent : ∀ a, (encode a).1 = f a

/-
!-- sketch: a fiber injects into the ancilla via the second component of any
reversible simulation, since equal second components + equal first
components (both `= b`) force equal encodings, hence equal inputs. --!--

**Lower bound.** Any reversible simulation of `f` with a finite ancilla type
needs at least `maxFiberSize f` ancilla states.
-/
theorem maxFiberSize_le_card_of_revSim {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (s : RevSim f) [Fintype s.Aux] :
    maxFiberSize f ≤ Fintype.card s.Aux := by
  refine' Finset.sup_le _;
  intro b hb
  set S := Finset.filter (fun a => f a = b) Finset.univ with hS_def;
  -- Since `s` is a reversible simulation, the function `fun a : S => (s.encode a).2` is injective.
  have h_inj : Function.Injective (fun a : S => (s.encode a).2) := by
    intro a₁ a₂ h; have := s.enc_inj; simp_all +decide;
    have := s.consistent a₁; have := s.consistent a₂; aesop;
  simpa using Fintype.card_le_of_injective _ h_inj

/-
!-- sketch: route `α ≃ Σ b, {a // f a = b}` (sigmaFiberEquiv.symm), embed each
fiber into `Fin (maxFiberSize f)` via `Embedding.nonempty_of_card_le`
(card of a fiber ≤ sup = maxFiberSize), then `Σ _ , Fin k ≃ β × Fin k`. --!--

**Upper bound.** Every function admits a reversible simulation whose ancilla
type is `Fin (maxFiberSize f)`.
-/
theorem exists_revSim_fin_maxFiber {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    ∃ g : α → β × Fin (maxFiberSize f),
      Function.Injective g ∧ ∀ a, (g a).1 = f a := by
  obtain ⟨g, hg⟩ : ∃ g : α → (Σ b : β, {a : α | f a = b}), Function.Injective g ∧ ∀ a, (g a).1 = f a := by
    refine' ⟨ fun a => ⟨ f a, ⟨ a, rfl ⟩ ⟩, _, _ ⟩ <;> simp +decide [ Function.Injective ];
    grind;
  obtain ⟨emb, h_emb⟩ : ∃ emb : (b : β) × {a : α | f a = b} → β × Fin (maxFiberSize f), Function.Injective emb ∧ ∀ p, (emb p).1 = p.1 := by
    have h_emb : ∀ b : β, ∃ emb : {a : α | f a = b} ↪ Fin (maxFiberSize f), True := by
      intro b
      have h_card : Fintype.card {a : α | f a = b} ≤ maxFiberSize f := by
        exact Finset.le_sup ( f := fun b => Finset.card ( Finset.filter ( fun a => f a = b ) Finset.univ ) ) ( Finset.mem_univ b ) |> le_trans ( by simp +decide [ Fintype.card_subtype ] );
      exact ⟨ Function.Embedding.nonempty_of_card_le ( by simpa using h_card ) |> Classical.choice, trivial ⟩;
    choose emb h_emb using h_emb;
    refine' ⟨ fun p => ⟨ p.1, emb p.1 p.2 ⟩, _, _ ⟩ <;> simp +decide [ Function.Injective ];
    rintro ⟨ b₁, x₁ ⟩ ⟨ b₂, x₂ ⟩ rfl h; have := emb b₁ |>.injective h; aesop;
  exact ⟨ fun a => emb ( g a ), h_emb.1.comp hg.1, fun a => h_emb.2 _ ▸ hg.2 _ ⟩

/-
!-- sketch: forward — a fiber of size ≥ 2 gives two inputs collapsing to a
value, breaking injectivity; backward — injective `f` has every fiber a
subsingleton. --!--

One ancilla state suffices iff `f` is injective.
-/
theorem maxFiberSize_le_one_iff_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    maxFiberSize f ≤ 1 ↔ Function.Injective f := by
  constructor <;> intro h <;> simp_all +decide [ Function.Injective, maxFiberSize ];
  · intro a₁ a₂ h_eq; specialize h ( f a₁ ) ; rw [ Finset.card_le_one_iff ] at h; aesop;
  · exact fun b => Finset.card_le_one.mpr fun x hx y hy => h <| by aesop;

/-
!-- sketch: lower bound rules out `Fin (maxFiberSize f - 1)` since its
cardinality is one short; upper bound supplies the matching simulation. --!--

**Tightness.** `maxFiberSize f` is exactly the minimal ancilla cardinality:
the bound is achieved (by `Fin (maxFiberSize f)`) and cannot be improved — once
`f` has a fiber of size ≥ 1 there is no reversible simulation into
`Fin (maxFiberSize f - 1)`.
-/
theorem tight_ancilla_bound {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hpos : 1 ≤ maxFiberSize f) :
    (∃ g : α → β × Fin (maxFiberSize f),
        Function.Injective g ∧ ∀ a, (g a).1 = f a) ∧
    ¬ ∃ g : α → β × Fin (maxFiberSize f - 1),
        Function.Injective g ∧ ∀ a, (g a).1 = f a := by
  refine ⟨exists_revSim_fin_maxFiber f, ?_⟩
  · contrapose! hpos;
    obtain ⟨ g, hg₁, hg₂ ⟩ := hpos;
    have := maxFiberSize_le_card_of_revSim f ⟨ Fin ( maxFiberSize f - 1 ), g, hg₁, hg₂ ⟩;
    rcases n : maxFiberSize f with ( _ | _ | n ) <;> simp_all +decide

end TightAncilla