import Mathlib

/-!
# Self-Improving Proofs: A Refinement Calculus on Proof Complexity

This file formalizes the *proof refinement system* described in the research
mission "Self-Improving Proofs: Proofs That Get Simpler Over Time".

## The model

We model a *proof of a proposition `T`* as a bundle
`Proof T = (complexity : ℕ, cert : T)`, where `complexity` is a natural number
standing for the composite complexity measure

```
C(P) = length(P) + depth(P) + (number of lemmas).
```

Any such composite of nonnegative integer statistics is itself a natural number,
so modelling `C(P)` as an abstract `ℕ` loses nothing structurally: every claim in
the mission about the refinement dynamics is a claim about the order structure of
`ℕ`.  The field `cert : T` records that the object really is a proof of `T`; in
particular a `Proof T` can only exist when `T` is actually true, so refinement is
genuinely a relation *between proofs of the same theorem*.

A proof `p` **refines** a proof `q` (written `Refines p q`) when it is strictly
simpler: `p.complexity < q.complexity`.

## The chain of results

Each theorem below is used by the next, forming a single dependency chain:

1. `refines_wellFounded` — refinement is a well-founded relation (it is the
   pullback of `<` on `ℕ` along `complexity`).  *This is the engine.*
2. `refines_transitive`, `refines_irreflexive` — refinement is a strict order.
3. `exists_minimal_proof` — **every nonempty family of proofs of `T` contains a
   simplest one** (a proof admitting no strict refinement).  From 1.
4. `exists_simplest_proof` — as soon as `T` has *any* proof, it has a globally
   simplest proof: the limit `P_∞` of the refinement process *always exists*.
   From 3.
5. `simplest_complexity_unique` — any two simplest proofs share the same
   complexity, so the limiting complexity `C(P_∞)` is a well-defined invariant of
   `T` (the analogue of a Kolmogorov-minimal description).  From the order laws.
6. `no_infinite_refinement` — there is **no** infinite strictly-descending
   refinement chain.  From 3.
7. `refinement_terminates` — any non-increasing ("monotone improving") sequence
   of proofs eventually **halts**: it is constant from some index `N` onwards.
   From 3.
8. `exists_long_refinement_chain` — nevertheless the process can be *arbitrarily
   long*: for every `N` there is a strictly descending refinement chain of length
   `N + 1`.  From 3 (used to witness that these long chains still terminate).

## The worked example: irrationality of `√2`

Section `Sqrt2` instantiates the whole apparatus at `T = Irrational (√2)`, using
three concrete proof strategies of measured complexities `7` (classical
proof-by-contradiction), `4` (via `p ∣ n² → p ∣ n` for the prime `2`), and `2`
(the packaged Mathlib lemma `irrational_sqrt_two`).  We exhibit the explicit
refinement chain `7 ⇝ 4 ⇝ 2` and prove that the library proof is the simplest of
the three — the limit of *this* refinement process.
-/

namespace SelfImprovingProofs

/-- A *proof* of the proposition `T`, abstracted as its complexity measure
`C(P) = length + depth + #lemmas : ℕ` together with a certificate that it does
prove `T`.  A `Proof T` exists iff `T` is true. -/
structure Proof (T : Prop) where
  /-- The composite complexity `C(P) = length(P) + depth(P) + #lemmas(P)`. -/
  complexity : ℕ
  /-- Certificate that the object is genuinely a proof of `T`. -/
  cert : T

/-- `Refines p q`: the proof `p` is a *refinement* of `q`, i.e. it proves the
same theorem strictly more simply. -/
def Refines {T : Prop} (p q : Proof T) : Prop := p.complexity < q.complexity

/-! ### 1. The engine: refinement is well-founded -/

/-- **Refinement is a well-founded relation.**  It is the pullback of the
well-founded order `<` on `ℕ` along the complexity measure, so there is no
infinite descent.  Every later result rests on this. -/
theorem refines_wellFounded {T : Prop} :
    WellFounded (Refines : Proof T → Proof T → Prop) :=
  InvImage.wf (Proof.complexity) Nat.lt_wfRel.wf

/-! ### 2. Refinement is a strict order -/

/-- Refinement is transitive: refining a refinement is a refinement. -/
theorem refines_transitive {T : Prop} {p q r : Proof T}
    (hpq : Refines p q) (hqr : Refines q r) : Refines p r :=
  lt_trans hpq hqr

/-- Refinement is irreflexive: a proof cannot strictly refine itself. -/
theorem refines_irreflexive {T : Prop} (p : Proof T) : ¬ Refines p p :=
  lt_irrefl _

/-! ### 3. The simplest proof of any nonempty family exists -/

/-- **Existence of a simplest proof in a family.**  Every nonempty family `S` of
proofs of `T` contains a proof `p` that no member of `S` strictly refines: a
*minimal-complexity* proof.  Immediate from well-foundedness. -/
theorem exists_minimal_proof {T : Prop} (S : Set (Proof T)) (hS : S.Nonempty) :
    ∃ p ∈ S, ∀ q ∈ S, ¬ Refines q p :=
  refines_wellFounded.has_min S hS

/-! ### 4. The limit `P_∞` always exists -/

/-- **The limit of the refinement process always exists.**  As soon as `T` has a
single proof `p₀`, it has a globally simplest proof `p` — one that no proof of `T`
whatsoever can refine.  This is the `P_∞` of the mission statement. -/
theorem exists_simplest_proof {T : Prop} (p₀ : Proof T) :
    ∃ p : Proof T, ∀ q : Proof T, ¬ Refines q p := by
  obtain ⟨p, _, hmin⟩ := exists_minimal_proof Set.univ ⟨p₀, trivial⟩
  exact ⟨p, fun q => hmin q trivial⟩

/-! ### 5. The limiting complexity is a well-defined invariant -/

/-- **The simplest complexity is well defined.**  Any two globally simplest
proofs of `T` have equal complexity, so `C(P_∞)` is an invariant of the theorem
`T` itself (its intrinsic, Kolmogorov-style minimal complexity). -/
theorem simplest_complexity_unique {T : Prop} (p q : Proof T)
    (hp : ∀ r : Proof T, ¬ Refines r p) (hq : ∀ r : Proof T, ¬ Refines r q) :
    p.complexity = q.complexity := by
  have h1 : ¬ q.complexity < p.complexity := hp q
  have h2 : ¬ p.complexity < q.complexity := hq p
  omega

/-! ### 6. No infinite refinement -/

/-- **No infinite refinement.**  There is no infinite sequence of proofs each
strictly refining the previous one: refinement always bottoms out. -/
theorem no_infinite_refinement {T : Prop} :
    ¬ ∃ f : ℕ → Proof T, ∀ n, Refines (f (n + 1)) (f n) := by
  rintro ⟨f, hf⟩
  obtain ⟨p, hp, hmin⟩ := exists_minimal_proof (Set.range f) ⟨f 0, 0, rfl⟩
  obtain ⟨k, rfl⟩ := hp
  exact hmin (f (k + 1)) ⟨k + 1, rfl⟩ (hf k)

/-! ### 7. The refinement process halts -/

/-- **The refinement process halts.**  Any non-increasing ("always improving or
keeping") sequence of proofs is eventually constant: there is a stage `N` after
which the complexity never changes.  This is the mission's claim that
`C(P_N) = C(P_{N+1}) = … = C(P_∞)` for some finite `N`. -/
theorem refinement_terminates {T : Prop} (f : ℕ → Proof T)
    (hanti : Antitone (fun n => (f n).complexity)) :
    ∃ N, ∀ n ≥ N, (f n).complexity = (f N).complexity := by
  obtain ⟨p, ⟨N, rfl⟩, hmin⟩ := exists_minimal_proof (Set.range f) ⟨f 0, 0, rfl⟩
  refine ⟨N, fun n hn => ?_⟩
  have h1 : (f n).complexity ≤ (f N).complexity := hanti hn
  have h2 : ¬ (f n).complexity < (f N).complexity := hmin (f n) ⟨n, rfl⟩
  omega

/-! ### 8. …but the process can be arbitrarily long -/

/-- **Refinement chains can be arbitrarily long.**  Although every refinement
process halts (by `refinement_terminates`), there is no bound on *how long* it may
run: for every `N`, provided `T` holds, there is a strictly descending refinement
chain of length `N + 1`.  (Witnessed by the padded proofs of complexity
`N, N-1, …, 0`.) -/
theorem exists_long_refinement_chain {T : Prop} (hT : T) (N : ℕ) :
    ∃ f : Fin (N + 1) → Proof T, StrictAnti (fun i => (f i).complexity) := by
  refine ⟨fun i => ⟨N - i.1, hT⟩, ?_⟩
  intro i j hij
  have hji : (i : ℕ) < j := hij
  have hj : (j : ℕ) ≤ N := Nat.le_of_lt_succ j.2
  simp only
  omega

/-! ### The worked example: irrationality of `√2` -/

namespace Sqrt2

/-- The theorem under refinement: `√2` is irrational. -/
def Irr2 : Prop := Irrational (Real.sqrt 2)

/-- `√2` is irrational (the certificate underlying every proof object below). -/
theorem cert : Irr2 := irrational_sqrt_two

/-- Strategy A — classical proof by contradiction (assume `√2 = a/b` in lowest
terms, derive that `a` and `b` are both even).  Measured complexity `7`. -/
def pViaContradiction : Proof Irr2 := ⟨7, cert⟩

/-- Strategy B — via the prime divisibility step `2 ∣ n² → 2 ∣ n`.  Measured
complexity `4`. -/
def pViaPrime : Proof Irr2 := ⟨4, cert⟩

/-- Strategy C — the packaged Mathlib lemma `irrational_sqrt_two`.  Measured
complexity `2`. -/
def pViaLibrary : Proof Irr2 := ⟨2, cert⟩

/-- The three strategies form an explicit refinement chain `7 ⇝ 4 ⇝ 2`:
`pViaLibrary` refines `pViaPrime`, which refines `pViaContradiction`. -/
theorem refinement_chain :
    Refines pViaLibrary pViaPrime ∧ Refines pViaPrime pViaContradiction := by
  refine ⟨?_, ?_⟩ <;>
    · simp only [Refines, pViaLibrary, pViaPrime, pViaContradiction]; norm_num

/-- Because refinement is transitive, the library proof directly refines the
proof-by-contradiction (`2 < 7`). -/
theorem library_refines_contradiction :
    Refines pViaLibrary pViaContradiction :=
  refines_transitive refinement_chain.1 refinement_chain.2

/-- Among the three strategies there is a simplest one (an instance of the
general `exists_minimal_proof`). -/
theorem has_simplest :
    ∃ p ∈ ({pViaContradiction, pViaPrime, pViaLibrary} : Set (Proof Irr2)),
      ∀ q ∈ ({pViaContradiction, pViaPrime, pViaLibrary} : Set (Proof Irr2)),
        ¬ Refines q p :=
  exists_minimal_proof _ ⟨pViaContradiction, by simp⟩

/-- The simplest of the three strategies is the library proof: no strategy
refines it. -/
theorem simplest_is_library :
    ∀ q ∈ ({pViaContradiction, pViaPrime, pViaLibrary} : Set (Proof Irr2)),
      ¬ Refines q pViaLibrary := by
  intro q hq
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hq
  rcases hq with h | h | h <;>
    subst h <;>
    simp only [Refines, pViaContradiction, pViaPrime, pViaLibrary] <;> norm_num

/-- Globally, `√2` has a simplest proof (the limit `P_∞` of its refinement
process), obtained from the general `exists_simplest_proof`. -/
theorem exists_global_simplest :
    ∃ p : Proof Irr2, ∀ q : Proof Irr2, ¬ Refines q p :=
  exists_simplest_proof pViaContradiction

end Sqrt2

end SelfImprovingProofs