import Mathlib

/-!
# Universal Mathematics: the invariant core shared by every consistent theory

Would a non-human intelligence — alien, artificial, or independently evolved —
discover *the same* mathematics that we do?  The question only becomes precise
once we fix what "the same mathematics" means.  Here we adopt the following
definition.  Fix a background notion of logical consequence, modelled by a
*consequence operator* `C` sending a set of assumptions to the set of statements
it entails.  A *theory* is a set of assumptions; its *theorems* are `C` of those
assumptions.  Given a base theory `base` (think: the axioms of arithmetic),
its **universal mathematics** is the intersection of the theorem-sets of *all*
consistent theories that extend it:

`Universal base = ⋂ { C Δ | base ⊆ Δ and Δ is consistent }`.

Intuitively this is the body of results that *survives* in every consistent way
of extending the base — the part of mathematics no consistent extension can
disown.

The central results of this file are:

* `peano_universal` — every theorem of the base is a theorem of every consistent
  extension.  Reading `base` as the Peano axioms, this is the precise sense in
  which *arithmetic is universal*: whatever richer consistent system a foreign
  intelligence adopts, it necessarily proves everything arithmetic proves.

* `universal_eq_base` — the universal mathematics of a consistent base is
  *exactly* its own theorem-set.  So the shared, extension-invariant core is
  neither larger nor smaller than the base theory: it is the base theory.

* `consistent_downward` — consistency is inherited by sub-theories.

Alongside these we record the structural fact that a consequence operator is a
*closure operator* in the order-theoretic sense (`toClosureOperator`), linking
the logic of provability to the lattice theory of closure systems, and we
exhibit an explicit model (`trivialSystem`) witnessing that the hypotheses are
satisfiable and that consistent extensions can be *strictly* larger than the
base while the universal core stays put.
-/

open Set

/-- A **consequence operator** on a type `S` of statements: `C Γ` is the set of
statements entailed by the assumptions `Γ`.  The three laws are Tarski's axioms
for a consequence relation — inclusion, monotonicity, and idempotence — which
are exactly the axioms of a closure operator on the powerset of `S`. -/
structure ConseqSystem (S : Type*) where
  /-- The consequence (deductive closure) operator. -/
  C : Set S → Set S
  /-- Every assumption is a consequence of itself: `Γ ⊆ C Γ`. -/
  subset_closure : ∀ Γ, Γ ⊆ C Γ
  /-- More assumptions entail more consequences. -/
  mono : ∀ ⦃Γ Δ : Set S⦄, Γ ⊆ Δ → C Γ ⊆ C Δ
  /-- Consequences of consequences are already consequences (cut). -/
  idem : ∀ Γ, C (C Γ) ⊆ C Γ

namespace ConseqSystem

variable {S : Type*} (L : ConseqSystem S)

/-- The deductive closure is genuinely idempotent: closing a theory twice is the
same as closing it once. -/
theorem C_idem_eq (Γ : Set S) : L.C (L.C Γ) = L.C Γ :=
  Set.Subset.antisymm (L.idem Γ) (L.subset_closure _)

/-- A consequence operator is precisely a closure operator on the powerset
lattice.  This bridges the logic of derivability with the order theory of
closure systems: theories closed under consequence are exactly the closed
elements of this closure operator, and hence form a complete lattice. -/
def toClosureOperator : ClosureOperator (Set S) where
  toOrderHom := ⟨L.C, fun _ _ h => L.mono h⟩
  le_closure' := L.subset_closure
  idempotent' := L.C_idem_eq

/-- A theory `Γ` is **consistent** when it does not entail *everything*: some
statement escapes its deductive closure. -/
def IsConsistent (Γ : Set S) : Prop := L.C Γ ≠ Set.univ

/-- The **universal mathematics** of a base theory: the theorems shared by every
consistent theory extending it. -/
def Universal (base : Set S) : Set S :=
  ⋂₀ {T | ∃ Δ, base ⊆ Δ ∧ L.IsConsistent Δ ∧ T = L.C Δ}

/-- **Universality of the base (e.g. arithmetic).**  Every theorem of the base
theory is a theorem of every consistent extension.  Reading `base` as the
axioms of arithmetic: any consistent system that contains arithmetic proves
everything arithmetic proves — no foreign intelligence adopting a richer
consistent framework can avoid the arithmetical theorems. -/
theorem peano_universal {base Δ : Set S} (h : base ⊆ Δ)
    (_hcon : L.IsConsistent Δ) : L.C base ⊆ L.C Δ :=
  L.mono h

/-- Consistency is inherited downward: a sub-theory of a consistent theory is
consistent. -/
theorem consistent_downward {base Δ : Set S} (h : base ⊆ Δ)
    (hcon : L.IsConsistent Δ) : L.IsConsistent base := by
  intro hbad
  apply hcon
  apply Set.eq_univ_of_univ_subset
  rw [← hbad]
  exact L.mono h

/-- The base theory's theorems are contained in its universal mathematics: they
are shared by every consistent extension. -/
theorem base_subset_universal (base : Set S) : L.C base ⊆ L.Universal base := by
  intro x hx
  rw [Universal, Set.mem_sInter]
  rintro T ⟨Δ, hΔ, _, rfl⟩
  exact L.mono hΔ hx

/-- Conversely, when the base is itself consistent, its universal mathematics is
contained in its theorems — because the base is a consistent extension of
itself, and so appears in the defining intersection. -/
theorem universal_subset_base {base : Set S} (hcon : L.IsConsistent base) :
    L.Universal base ⊆ L.C base := by
  intro x hx
  rw [Universal, Set.mem_sInter] at hx
  exact hx (L.C base) ⟨base, subset_rfl, hcon, rfl⟩

/-- **The universal core is exactly the base.**  For a consistent base theory,
the mathematics invariant across *all* consistent extensions coincides
precisely with the theorems of the base itself.  The shared, extension-proof
body of mathematics is neither more nor less than the base theory. -/
theorem universal_eq_base {base : Set S} (hcon : L.IsConsistent base) :
    L.Universal base = L.C base :=
  Set.Subset.antisymm (L.universal_subset_base hcon) (L.base_subset_universal base)

/-- The universal mathematics of a consistent base is itself a deductively
closed theory. -/
theorem universal_is_closed {base : Set S} (hcon : L.IsConsistent base) :
    L.C (L.Universal base) = L.Universal base := by
  rw [universal_eq_base L hcon, C_idem_eq]

/-- The universal mathematics of a consistent base is itself consistent: the
invariant core never collapses into triviality. -/
theorem universal_consistent {base : Set S} (hcon : L.IsConsistent base) :
    L.IsConsistent (L.Universal base) := by
  rw [IsConsistent, universal_eq_base L hcon, C_idem_eq]
  exact hcon

/-- Monotonicity of the universal-core construction in the base theory: a larger
base has a larger universal core (it has fewer consistent extensions, so their
intersection is bigger). -/
theorem universal_mono {base base' : Set S} (h : base ⊆ base') :
    L.Universal base ⊆ L.Universal base' := by
  intro x hx
  rw [Universal, Set.mem_sInter] at hx ⊢
  rintro T ⟨Δ, hΔ, hcon, rfl⟩
  exact hx (L.C Δ) ⟨Δ, h.trans hΔ, hcon, rfl⟩

end ConseqSystem

/-!
## An explicit model witnessing non-vacuity

The identity consequence operator on the natural numbers (where a statement is a
consequence of `Γ` exactly when it belongs to `Γ`) is a genuine consequence
system.  It shows the axioms are satisfiable, that consistent theories exist,
and — crucially — that a consistent extension can be *strictly* larger than the
base even though the universal (extension-invariant) core does not grow.
-/

/-- The identity ("no deduction") consequence system on `ℕ`: theorems are just
the assumptions.  A minimal but genuine model of the axioms. -/
def trivialSystem : ConseqSystem ℕ where
  C := id
  subset_closure _ := subset_rfl
  mono := fun _ _ h => h
  idem _ := subset_rfl

namespace trivialSystem

/-- The base theory `{0}` is consistent: it does not entail the statement `1`. -/
theorem base_consistent : trivialSystem.IsConsistent {0} := by
  intro h
  have : (1 : ℕ) ∈ (Set.univ : Set ℕ) := Set.mem_univ 1
  rw [← h] at this
  simp [trivialSystem] at this

/-- The universal mathematics of the consistent base `{0}` is exactly `{0}`. -/
theorem universal_base : trivialSystem.Universal {0} = {0} :=
  trivialSystem.universal_eq_base base_consistent

/-- A *strictly* larger consistent extension exists: the theory `{0, 1}` proves
strictly more than `{0}`.  So consistent extensions can genuinely add theorems,
yet by `universal_base` the extension-invariant core remains `{0}`.  A foreign
intelligence may prove more than we do, but the shared universal core is fixed. -/
theorem strict_extension :
    trivialSystem.C ({0} : Set ℕ) ⊂ trivialSystem.C ({0, 1} : Set ℕ) := by
  constructor
  · intro x hx; simp [trivialSystem] at hx ⊢; simp [hx]
  · intro h
    have : (1 : ℕ) ∈ trivialSystem.C ({0} : Set ℕ) := h (by simp [trivialSystem])
    simp [trivialSystem] at this

/-- The strict extension `{0, 1}` is still consistent (it does not entail `2`),
confirming that the enrichment in `strict_extension` is a *consistent* one. -/
theorem extension_consistent : trivialSystem.IsConsistent {0, 1} := by
  intro h
  have : (2 : ℕ) ∈ (Set.univ : Set ℕ) := Set.mem_univ 2
  rw [← h] at this
  simp [trivialSystem] at this

end trivialSystem

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  "Universal mathematics" — the theorems provable
in *any* sufficiently expressive consistent framework — should be a robust,
observer-independent object.  Bold conjecture: the invariant core shared by all
consistent extensions of a base theory is *exactly* the base theory, so that a
base such as arithmetic is "universal" in the strongest possible sense: present,
and only just present, in every consistent extension.

**Experiment (Experimenter).**  We modelled logical consequence abstractly by
Tarski's closure axioms (`ConseqSystem`), avoiding any commitment to a specific
syntax.  Consistency was captured as "does not entail everything"
(`C Γ ≠ univ`), which needs no negation symbol.  Universality (`peano_universal`)
fell straight out of monotonicity.  The equation `Universal = C base` split into
two inclusions: `base_subset_universal` (monotonicity again) and
`universal_subset_base` (the base is a consistent extension of itself, so it is
one of the sets being intersected).

**Analysis (Analyst).**  Two structural patterns unify the results.  (1) A
consequence operator *is* a closure operator; recording this
(`toClosureOperator`) imports the entire order theory of closure systems for
free and explains why closed theories form a complete lattice.  (2) The
universal core is a *fixed point* of closure that is also a lower bound of a
family of theories; the base achieves the bound because reflexivity places it
inside the family.

**Critique (Critic).**  Is `universal_eq_base` vacuous?  No: `trivialSystem`
supplies a concrete model where the base is consistent (`base_consistent`), yet
a *strictly* larger consistent extension exists (`strict_extension`,
`extension_consistent`).  Thus the intersection genuinely ranges over more than
the base, and the theorem asserts a real coincidence rather than a triviality.
Is consistency needed?  Yes: `universal_subset_base` uses it essentially — an
inconsistent base is not among the consistent extensions, and the intersection
can then overshoot.  The downward lemma `consistent_downward` shows the
hypothesis is well behaved under passing to sub-theories.

**Synthesis (Principal Investigator).**  The extension-invariant core of a
consistent theory is the theory itself.  Universality is therefore not a matter
of *how much* a system proves but of *what every consistent enrichment must
retain*.  This reframes the "would aliens discover our mathematics?" question:
the answer is that any consistent framework extending a common base necessarily
contains that base's theorems, and the shared part is precisely the base — no
more (extensions may diverge above it) and no less (nothing in the base can be
dropped).
-/