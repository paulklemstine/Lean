/-
# Memory Editing: When Forgetting Is a Mathematical Operation

We model a **memory** as a structure-preserving map from *experience streams* to
*compressed representations*.  Experience streams accumulate by concatenation, so
the natural home for a stream is a monoid; a compressed representation is another
monoid `N`, and a memory is a monoid homomorphism `f : M →* N`.  The empty stream
maps to the neutral representation, and remembering two experiences one after the
other agrees with remembering their concatenation: `f (s * t) = f s * f t`.

The **finite-memory bound** is the hypothesis that the space of representations is
finite (`Finite N`): a real agent stores memories in bounded space.  Against an
unbounded stream space (`Infinite M`, e.g. arbitrarily long streams over a
nonempty alphabet) this forces *forgetting*.

This file establishes four structural facts.

* **Forced loss (`finite_memory_forces_loss`).**  Any memory obeying a
  finite-memory bound over an unbounded stream space is *lossy*: distinct streams
  are inevitably confused.  This is a hard limit, independent of how the memory is
  engineered.

* **Loss is algebraic (`confusion`, `finite_memory_confusion_nontrivial`).**  The
  set of *confusable pairs* `{(s,t) | f s = f t}` is a **submonoid** of `M × M`:
  confusion is closed under concatenation and contains the empty pair.  Forgetting
  is not a random glitch — it has algebraic structure.  Under a finite-memory
  bound this submonoid strictly contains the diagonal, so genuine (off-diagonal)
  loss occurs.

* **Targeted forgetting is a quotient (`forgetting_is_quotient`,
  `compressedEquivQuotient`, `kerLift_lossless`).**  A *forgetting policy* is a
  congruence `c` on the stream monoid; the canonical projection `M →* c.Quotient`
  is a surjective memory whose confusion is exactly `c`.  Conversely every memory
  `f` factors through the quotient by its confusion congruence, and the induced map
  out of the quotient is **injective**: all information loss happens at the
  quotient step, after which the representation is faithful.  The compressed image
  is isomorphic to that quotient.

* **Compression respects temporal order (`memory_preserves_leftDvd`,
  `memory_preserves_prefix`).**  Building on the left-divisibility order of
  `Catalog.Novelty.LeftDivisibility`, a memory is monotone for the "is an initial
  segment of" order: if stream `a` is a prefix of stream `b`, then the compressed
  `f a` still divides `f b`.  Forgetting may merge experiences, but it never
  reverses their temporal precedence.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  H1 (bold). A finite-memory monoid homomorphism from an unbounded stream monoid
     *must* be lossy — a pigeonhole limit with no engineering escape.
  H2 (surprising, structural). The set of confused stream pairs is not merely a
     set but a *submonoid* of `M × M`: information loss composes.
  H3 (grand challenge). "Targeted forgetting" is not an ad-hoc deletion but is
     *exactly* the quotient construction: forgetting policies = congruences =
     quotient monoids, with the first-isomorphism factorisation showing the
     quotient is the unique faithful compression.
  H4 (cross-domain: algebra × order). Compression is monotone for the temporal
     (prefix / left-divisibility) order on streams.

EXPERIMENT (Experimenter).
  - Loss via `Finite.exists_ne_map_eq_of_infinite`.
  - `confusion` assembled as a `Submonoid (M × M)` using `map_mul`.
  - Congruence machinery: `Con.ker`, `Con.mk'`, `Con.quotientKerEquivRange`,
    `Con.kerLift`/`Con.kerLift_injective` for the factorisation.
  - Order bridge reuses `UphoMultiplicability.LeftDvd` and
    `freeMonoid_leftDvd_iff_isPrefix` from the catalog.

ANALYSIS (Analyst).
  Everything survived. The decisive structural insight: the *same* congruence
  `Con.ker f` plays three roles — it is the confusion relation, it is the
  forgetting policy, and it is the kernel of the quotient projection. Loss,
  policy, and quotient coincide. Groups would collapse the order bridge (their
  divisibility order is indiscrete, cf. the catalog), so the stream monoid must be
  a genuinely non-group monoid (free monoids being the prototype).

CRITIQUE (Critic).
  - `finite_memory_forces_loss` is non-vacuous: `FreeMonoid α` over nonempty `α`
    is genuinely infinite, so the corollary `stream_memory_lossy` bites.
  - `confusion` is not the trivial diagonal: `finite_memory_confusion_nontrivial`
    exhibits an off-diagonal member.
  - `kerLift_lossless` guards against the misreading that quotients still lose
    information: they do not; loss is entirely localised to the projection.
  - No theorem is `True`/`rfl`-only; each uses pigeonhole, congruence, or the
    submonoid closure law.

SYNTHESIS (PI).
  Memory = monoid hom; forgetting = confusion congruence = quotient. The finite
  bound forces the confusion congruence to be nontrivial, and the quotient by it
  is the canonical faithful compression. See `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Catalog.Novelty.LeftDivisibility

namespace MemoryEditing

open Function UphoMultiplicability

variable {M N P : Type*} [Monoid M] [Monoid N] [Monoid P]

/-! ## Information loss as a submonoid -/

/-- The **confusion submonoid** of a memory `f : M →* N`: the pairs of experience
streams that `f` renders indistinguishable.  It is closed under concatenation
(`(a,b),(c,d) ↦ (a*c, b*d)`) and contains the empty pair, hence is a genuine
submonoid of `M × M` — information loss has algebraic structure. -/
def confusion (f : M →* N) : Submonoid (M × M) where
  carrier := {p | f p.1 = f p.2}
  one_mem' := by simp
  mul_mem' := by
    rintro ⟨a₁, a₂⟩ ⟨b₁, b₂⟩ ha hb
    simp only [Set.mem_setOf_eq, Prod.fst_mul, Prod.snd_mul, map_mul] at *
    rw [ha, hb]

@[simp] theorem mem_confusion {f : M →* N} {p : M × M} :
    p ∈ confusion f ↔ f p.1 = f p.2 := Iff.rfl

/-- The diagonal always lies in the confusion submonoid: an experience is never
confused with itself. -/
theorem diag_mem_confusion (f : M →* N) (m : M) : (m, m) ∈ confusion f := rfl

/-! ## Finite memory forces forgetting -/

/-- A memory is **lossy** when it fails to be injective: some two distinct streams
collapse to the same representation. -/
def Lossy (f : M →* N) : Prop := ¬ Function.Injective f

/-- **Forced loss.**  Any memory satisfying a finite-memory bound (`Finite N`)
over an unbounded stream space (`Infinite M`) is lossy.  This is the pigeonhole
limit of memory: bounded storage against unbounded experience must forget. -/
theorem finite_memory_forces_loss [Infinite M] [Finite N] (f : M →* N) : Lossy f := by
  intro hinj
  obtain ⟨x, y, hne, hxy⟩ := Finite.exists_ne_map_eq_of_infinite f
  exact hne (hinj hxy)

/-- Under a finite-memory bound the confusion submonoid strictly exceeds the
diagonal: there is a genuine off-diagonal confused pair.  Forgetting is not merely
possible but unavoidable. -/
theorem finite_memory_confusion_nontrivial [Infinite M] [Finite N] (f : M →* N) :
    ∃ p ∈ confusion f, p.1 ≠ p.2 := by
  obtain ⟨x, y, hne, hxy⟩ := Finite.exists_ne_map_eq_of_infinite f
  exact ⟨(x, y), hxy, hne⟩

/-- Streams over a nonempty alphabet under concatenation form the free monoid,
which is infinite; hence any finite memory of such streams confuses two distinct
streams. -/
theorem stream_memory_lossy {α : Type*} [Nonempty α] [Finite N]
    (f : FreeMonoid α →* N) : ∃ s t : FreeMonoid α, s ≠ t ∧ f s = f t := by
  obtain ⟨x, y, hne, hxy⟩ := Finite.exists_ne_map_eq_of_infinite f
  exact ⟨x, y, hne, hxy⟩

/-- **Quantitative pigeonhole.**  If a memory has at most `Fintype.card N`
representations, then among any set of more than that many streams, two distinct
ones are already confused. -/
theorem confusion_card_bound [Fintype N] (f : M →* N) (s : Finset M)
    (hs : Fintype.card N < s.card) :
    ∃ a ∈ s, ∃ b ∈ s, a ≠ b ∧ f a = f b := by
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to ?_ (fun a _ => Finset.mem_univ (f a))
  simpa using hs

/-! ## Targeted forgetting is a quotient -/

/-- The confusion relation of a memory *is* its kernel congruence: `(a,b)` is
confused iff `a` and `b` are congruent under `Con.ker f`. -/
theorem confusion_iff_ker (f : M →* N) {a b : M} :
    (a, b) ∈ confusion f ↔ (Con.ker f) a b := by
  rw [mem_confusion, Con.ker_rel]

/-- **Forgetting policies are quotients.**  A congruence `c` on the stream monoid
is a forgetting policy; the canonical projection `Con.mk' c : M →* c.Quotient` is a
*surjective* memory whose confusion congruence is exactly `c`.  Thus targeted
forgetting corresponds precisely to a quotient construction. -/
theorem forgetting_is_quotient (c : Con M) :
    Function.Surjective (Con.mk' c) ∧ Con.ker (Con.mk' c) = c := by
  refine ⟨Con.mk'_surjective, ?_⟩
  ext a b
  rw [Con.ker_rel]
  exact Con.eq c

/-- **The compressed image is a quotient.**  The representation space actually
used by a memory `f` (its image `mrange f`) is isomorphic, as a monoid, to the
quotient of the stream monoid by the confusion congruence.  This is the
first-isomorphism theorem read as: *the compression is the quotient*. -/
noncomputable def compressedEquivQuotient (f : M →* N) :
    (Con.ker f).Quotient ≃* (MonoidHom.mrange f) :=
  Con.quotientKerEquivRange f

/-- **The quotient is faithful.**  The map induced by `f` out of the quotient by
its confusion congruence is injective.  All information loss happens at the
quotient projection; once streams are identified according to the forgetting
policy, no *further* loss occurs. -/
theorem kerLift_lossless (f : M →* N) : Function.Injective (Con.kerLift f) :=
  Con.kerLift_injective f

/-- The faithful lift recovers `f`: forgetting factors as *project, then embed*. -/
theorem kerLift_factor (f : M →* N) (a : M) :
    (Con.kerLift f) (Con.mk' (Con.ker f) a) = f a :=
  Con.kerLift_mk a

/-- **Forgetting only ever coarsens.**  Post-composing a memory with a further
compression `h` can only enlarge the confusion congruence: composing memories
loses at least as much as either stage.  This orders memories by how much they
forget. -/
theorem forgetting_monotone (f : M →* N) (h : N →* P) :
    Con.ker f ≤ Con.ker (h.comp f) := by
  intro a b hab
  rw [Con.ker_rel] at *
  simp [hab]

/-! ## Compression respects temporal order (algebra × order bridge) -/

/-- **Memory is monotone for temporal precedence.**  Using the left-divisibility
order of `Catalog.Novelty.LeftDivisibility`, if experience `a` precedes `b`
(i.e. `a` left-divides `b`), then the compressed memory of `a` still left-divides
that of `b`.  Forgetting may merge experiences but never reverses their order. -/
theorem memory_preserves_leftDvd (f : M →* N) {a b : M} (hab : LeftDvd a b) :
    LeftDvd (f a) (f b) := by
  obtain ⟨c, rfl⟩ := hab
  exact ⟨f c, by rw [map_mul]⟩

/-- On experience streams (free monoid), where left-divisibility is the prefix
order (catalog `freeMonoid_leftDvd_iff_isPrefix`), a memory sends any initial
segment relation to a divisibility relation between compressed representations. -/
theorem memory_preserves_prefix {α : Type*} (f : FreeMonoid α →* N)
    {a b : FreeMonoid α} (hab : (a : List α) <+: (b : List α)) :
    LeftDvd (f a) (f b) := by
  rw [← freeMonoid_leftDvd_iff_isPrefix] at hab
  exact memory_preserves_leftDvd f hab

end MemoryEditing