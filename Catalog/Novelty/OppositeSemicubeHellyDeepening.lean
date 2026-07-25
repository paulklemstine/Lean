/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Deepening: canonical matchings, parity, and the finite-family product law
for the opposite-semicube Helly property

This development deepens the theory of the **opposite-semicube Helly property** of
partial cubes.  A partial cube is an isometric subgraph of a hypercube; in the
coordinate model a vertex of the hypercube on coordinate set `α` is a sign vector
`α → Bool`, a partial cube is a finite set `V : Finset (α → Bool)`, and the
*semicube* of coordinate `i` with sign `b` is `{v ∈ V | v i = b}`.  Two structural
notions organise the theory:

* **Harmonic-evenness** — every coordinate (Θ-class) splits `V` into two
  equal-sized opposite semicubes; the exact discrete analogue of a mean-value
  (harmonic) symmetry.
* **The opposite-semicube Helly property** — for every coordinate the two opposite
  semicubes admit a matching (a bijection); a Hall/transversal-type condition.

The base characterisation `OppositeSemicubeHelly V ↔ HarmonicEven V` (a matching of
a cut exists iff its two sides are equinumerous) and the *binary* product law are
recorded in the companion development; here we build three deeper layers.

## 1. A canonical matching from antipodal symmetry

The Helly property only asserts *existence* of a matching.  We exhibit a canonical
one whenever the vertex set is closed under the coordinatewise complement (the
antipodal involution `v ↦ ¬ v`): the complement maps each semicube bijectively
onto its opposite.  This upgrades the existence statement to an explicit,
involutive system of representatives and proves harmonic-evenness constructively
(`antipodalClosed_harmonicEven`).

## 2. Parity of the vertex count

Harmonic-evenness forces an even number of vertices, since a single balanced cut
partitions the vertices into two equinumerous halves (`harmonicEven_even_card`).
As boundary cases, a single vertex is never harmonic-even
(`not_harmonicEven_singleton`) while the full hypercube always is
(`harmonicEven_univ`).

## 3. The finite-family product law

The central result generalises the binary product law to an **arbitrary finite
family** of partial cubes indexed by a finite type `ι`.  The product cube lives on
the disjoint union `Σ k, β k` of coordinate sets, and its `⟨k, i⟩`-semicube has
cardinality `|Semicube (V k) i c| · ∏_{j ≠ k} |V j|`.  Cancelling the (positive,
by nonemptiness) product factor yields:

* `harmonicEven_piCube` — the family product is harmonic-even iff every factor is;
* `oppositeSemicubeHelly_piCube` — the family product satisfies the
  opposite-semicube Helly property iff every factor is harmonic-even.

The binary theorem is the special case `ι = Bool`.

## References

* Djoković–Winkler theory of Θ-classes and semicubes of partial cubes.
* Polat's theorems on Helly properties in partial cubes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The binary product law is the shadow of a fully
multiplicative law over finite families; moreover the mere *existence* of cut
matchings hides a canonical, symmetry-induced matching whenever the cube is
antipodally closed.  Bold form: harmonic-evenness is exactly the "each cut halves
the mass" condition and is therefore simultaneously a parity constraint and a
product-stable invariant.

Experiment (Experimenter): Model the family product on `Σ k, β k` via the merge
map `f ↦ (fun s => f s.1 s.2)`, injective by extensionality.  The one-coordinate
slice of `Fintype.piFinset V` is again a `piFinset` with the `k`-th factor
replaced by its semicube (`Function.update`), so `Fintype.card_piFinset` together
with `Finset.prod_update_of_mem` yield the product cardinality formula.  Positivity
of `∏_{j ≠ k} |V j|` (all factors nonempty) licenses cancellation.

Analysis (Analyst): Harmonic-evenness is (a) coordinate-local, (b) multiplicative
across products, (c) a parity obstruction, and (d) automatic under antipodal
closure.  Nonemptiness of every factor is load-bearing exactly at the cancellation
step; the antipodal route needs no nonemptiness because it builds the bijection
directly.

Critique (Critic): None of the results are definitional.  The product law needs
genuine cancellation of a positive natural-number product; the parity result uses
the disjoint two-block decomposition of a cut; the antipodal matching is a real
involution, not a renaming.  The binary theorem is recovered as an instance, so
the family law strictly extends the earlier development.

Synthesis (PI): The opposite-semicube Helly property is governed by a single
harmonic-balance invariant that is at once local, multiplicative,
parity-constraining, and symmetry-canonical; see `FUTURE_DIRECTIONS.md`.
-/

open Finset

namespace OSHDeepening

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ### Base notions -/

/-- The **semicube** of coordinate `i` with sign `b`: the vertices of `V` whose
`i`-th coordinate equals `b`. -/
def Semicube (V : Finset (α → Bool)) (i : α) (b : Bool) : Finset (α → Bool) :=
  V.filter (fun v => v i = b)

/-- A coordinate `i` is **balanced** in `V` if its two opposite semicubes are
equinumerous. -/
def Balanced (V : Finset (α → Bool)) (i : α) : Prop :=
  (Semicube V i true).card = (Semicube V i false).card

/-- `V` is **harmonic-even** if every coordinate splits `V` into two equal-sized
opposite semicubes. -/
def HarmonicEven (V : Finset (α → Bool)) : Prop := ∀ i, Balanced V i

/-- The **opposite-semicube Helly property**: for every coordinate the two opposite
semicubes admit a matching (a bijection between them). -/
def OppositeSemicubeHelly (V : Finset (α → Bool)) : Prop :=
  ∀ i, Nonempty (↥(Semicube V i true) ≃ ↥(Semicube V i false))

omit [Fintype α] [DecidableEq α] in
/-- **Characterisation.** A partial cube satisfies the opposite-semicube Helly
property exactly when it is harmonic-even: each cut can be matched iff its two
sides are equinumerous. -/
theorem osh_iff_harmonicEven (V : Finset (α → Bool)) :
    OppositeSemicubeHelly V ↔ HarmonicEven V := by
  constructor
  · intro h i
    obtain ⟨e⟩ := h i
    have h2 := Fintype.card_congr e
    rw [Fintype.card_coe, Fintype.card_coe] at h2
    exact h2
  · intro h i
    refine ⟨Fintype.equivOfCardEq ?_⟩
    rw [Fintype.card_coe, Fintype.card_coe]
    exact h i

/-! ### Layer 1: canonical matching from antipodal symmetry -/

/-- The coordinatewise complement (antipodal involution) on sign vectors. -/
def antipode (v : α → Bool) : α → Bool := fun i => !(v i)

omit [Fintype α] [DecidableEq α] in
@[simp] lemma antipode_antipode (v : α → Bool) : antipode (antipode v) = v := by
  funext i; simp [antipode]

omit [Fintype α] [DecidableEq α] in
lemma antipode_injective : Function.Injective (antipode (α := α)) := by
  intro v w h; have := congrArg antipode h; simpa using this

/-- A vertex set is **antipodally closed** if it is stable under the coordinatewise
complement. -/
def AntipodalClosed (V : Finset (α → Bool)) : Prop :=
  ∀ v ∈ V, antipode v ∈ V

omit [DecidableEq α] in
/-- The antipodal involution sends the opposite semicube of a coordinate onto its
partner: `Semicube V i false = (Semicube V i true).image antipode` for an
antipodally closed vertex set. -/
lemma semicube_false_eq_image_antipode {V : Finset (α → Bool)}
    (hV : AntipodalClosed V) (i : α) :
    Semicube V i false = (Semicube V i true).image antipode := by
  ext w; simp only [Semicube, Finset.mem_filter, Finset.mem_image]
  constructor
  · rintro ⟨hwV, hwi⟩
    exact ⟨antipode w, ⟨hV _ hwV, by simp only [antipode, hwi, Bool.not_false]⟩,
      antipode_antipode w⟩
  · rintro ⟨a, ⟨ha₁, ha₂⟩, rfl⟩
    exact ⟨hV a ha₁, by simp only [antipode, ha₂, Bool.not_true]⟩

omit [DecidableEq α] in
/-- **Canonical matching.** If a vertex set is antipodally closed then every cut is
balanced, i.e. the set is harmonic-even, with the antipodal involution as the
matching. -/
theorem antipodalClosed_harmonicEven {V : Finset (α → Bool)}
    (hV : AntipodalClosed V) : HarmonicEven V := by
  intro i;
  rw [ Balanced, semicube_false_eq_image_antipode hV i, Finset.card_image_of_injective _ ( antipode_injective ) ]

/-- The full hypercube is antipodally closed. -/
lemma antipodalClosed_univ : AntipodalClosed (Finset.univ : Finset (α → Bool)) := by
  intro v _; exact Finset.mem_univ _

/-- The full hypercube is harmonic-even: every cut halves it. -/
theorem harmonicEven_univ : HarmonicEven (Finset.univ : Finset (α → Bool)) :=
  antipodalClosed_harmonicEven antipodalClosed_univ

/-! ### Layer 2: parity of the vertex count -/

omit [Fintype α] [DecidableEq α] in
/-- **Parity obstruction.** If `α` is nonempty and `V` is harmonic-even then `V`
has an even number of vertices, because any single cut splits it into two
equinumerous halves. -/
theorem harmonicEven_even_card [Nonempty α] {V : Finset (α → Bool)}
    (hV : HarmonicEven V) : Even V.card := by
  -- By definition of Balanced, we have that the cardinalities of the two semicubes are equal.
  have h_card_eq : ∀ i, (Finset.filter (fun v => v i = true) V).card = (Finset.filter (fun v => v i = false) V).card := by
    exact hV;
  obtain ⟨ i ⟩ := ‹Nonempty α›; have := h_card_eq i; simp_all +decide ;
  exact even_iff_two_dvd.mpr ⟨ Finset.card ( Finset.filter ( fun v => v i = true ) V ), by linarith [ h_card_eq i, show Finset.card ( Finset.filter ( fun v => v i = true ) V ) + Finset.card ( Finset.filter ( fun v => v i = false ) V ) = Finset.card V from by rw [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; exact Finset.card_eq_sum_ones V ▸ by congr; ext x; aesop ] ⟩

omit [Fintype α] [DecidableEq α] in
/-- A single vertex is never harmonic-even when there is at least one coordinate:
its unique cut is maximally unbalanced. -/
theorem not_harmonicEven_singleton [Nonempty α] (v : α → Bool) :
    ¬ HarmonicEven ({v} : Finset (α → Bool)) := by
  intro h
  have := harmonicEven_even_card h
  simp at this

/-! ### Layer 3: the finite-family product law -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {β : ι → Type*} [∀ k, Fintype (β k)] [∀ k, DecidableEq (β k)]

/-- The merge map assembling a family of sign vectors into a single sign vector on
the disjoint union `Σ k, β k` of coordinate sets. -/
def mergePi (f : ∀ k, β k → Bool) : (Σ k, β k) → Bool := fun s => f s.1 s.2

omit [Fintype ι] [DecidableEq ι] [∀ k, Fintype (β k)] [∀ k, DecidableEq (β k)] in
lemma mergePi_injective : Function.Injective (mergePi (β := β)) := by
  intro f g h
  funext k i
  exact congrFun h ⟨k, i⟩

/-- The **finite-family Cartesian product** of partial cubes, realised on the
disjoint-union coordinate set `Σ k, β k`. -/
def piCube (V : ∀ k, Finset (β k → Bool)) : Finset ((Σ k, β k) → Bool) :=
  (Fintype.piFinset V).image mergePi

omit [∀ k, Fintype (β k)] [∀ k, DecidableEq (β k)] in
/-- The one-coordinate slice of `Fintype.piFinset V` is again a product family,
with the `k`-th factor replaced by its semicube. -/
lemma piFinset_slice (V : ∀ k, Finset (β k → Bool)) (k : ι) (i : β k) (c : Bool) :
    (Fintype.piFinset V).filter (fun f => f k i = c)
      = Fintype.piFinset (Function.update V k (Semicube (V k) i c)) := by
  ext f;
  simp +decide [ Fintype.mem_piFinset, Semicube ];
  constructor <;> intro h;
  · intro a; by_cases ha : a = k <;> aesop;
  · grind

omit [∀ k, DecidableEq (β k)] in
/-- Cardinality of a `⟨k, i⟩`-semicube of the family product. -/
lemma card_semicube_piCube (V : ∀ k, Finset (β k → Bool)) (k : ι) (i : β k) (c : Bool) :
    (Semicube (piCube V) ⟨k, i⟩ c).card
      = (Semicube (V k) i c).card * ∏ j ∈ Finset.univ.erase k, (V j).card := by
  convert congr_arg Finset.card ( show Semicube ( piCube V ) ⟨ k, i ⟩ c = Finset.image mergePi ( Fintype.piFinset ( Function.update V k ( Semicube ( V k ) i c ) ) ) from ?_ ) using 1;
  · rw [ Finset.card_image_of_injective _ mergePi_injective, Fintype.card_piFinset ];
    rw [ ← Finset.mul_prod_erase _ _ ( Finset.mem_univ k ) ];
    exact congr_arg₂ _ ( by simp +decide ) ( Finset.prod_congr rfl fun j hj => by aesop );
  · convert congr_arg ( Finset.image mergePi ) ( piFinset_slice V k i c ) using 1;
    unfold Semicube piCube;
    ext; aesop

omit [∀ k, DecidableEq (β k)] in
/-- **Finite-family harmonic-evenness law.** For a family of nonempty partial
cubes, the family product is harmonic-even iff every factor is. -/
theorem harmonicEven_piCube (V : ∀ k, Finset (β k → Bool))
    (hV : ∀ k, (V k).Nonempty) :
    HarmonicEven (piCube V) ↔ ∀ k, HarmonicEven (V k) := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · intro k i
    have := h ⟨k, i⟩
    simp at *;
    simp_all +decide [ Balanced, card_semicube_piCube ];
    exact this.resolve_right ( Finset.prod_ne_zero_iff.mpr fun j hj => Finset.card_ne_zero_of_mem ( hV j |> Classical.choose_spec ) );
  · intro ⟨ k, i ⟩;
    rw [ Balanced, card_semicube_piCube, card_semicube_piCube ];
    exact congr_arg₂ _ ( h k i ) rfl

omit [∀ k, DecidableEq (β k)] in
/-- **Finite-family opposite-semicube Helly law.** For a family of nonempty partial
cubes, the family product satisfies the opposite-semicube Helly property iff every
factor is harmonic-even. -/
theorem oppositeSemicubeHelly_piCube (V : ∀ k, Finset (β k → Bool))
    (hV : ∀ k, (V k).Nonempty) :
    OppositeSemicubeHelly (piCube V) ↔ ∀ k, HarmonicEven (V k) := by
  rw [osh_iff_harmonicEven]
  exact harmonicEven_piCube V hV

end OSHDeepening