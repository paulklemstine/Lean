

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## Algebra–EML Congruence Quotient Reconstruction via Orbit-Cardinality Compression

Work in Lean 4 with `Mathlib`, and build a self-contained theory of quotient-observable dynamics for finite iterates. The central object is the orbit of `x` under `f`, viewed through the congruence lens `ρ`, with explicit finite-cardinality compression bounds. Treat this simultaneously as:

- an algebraic dynamical system on a finite quotient,
- an EML-style observable-state compression principle,
- a cryptographic collision certificate on quotient states,
- a certified robustness statement for quotient-observable trajectories.

You should produce a mathematically rich file centered on the following core theorem, but significantly deepen it with a web of new definitions and corollaries.

---

## Core target theorem

Prove the exact theorem:

```lean
theorem exists_iterate_rel_of_card_quotient
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
      ρ.r ((f^[m]) x) ((f^[n]) x) := by
```

This should be obtained by a quotient-valued pigeonhole principle applied to
`i ↦ Quotient.mk _ ((f^[i]) x)` on a carefully chosen finite index set of size `card (Quotient ρ) + 1`.

A highly recommended exact intermediate lemma is:

```lean
theorem exists_lt_lt_iterate_quotient_eq
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
      Quotient.mk (s := ρ) ((f^[m]) x) = Quotient.mk (s := ρ) ((f^[n]) x) := by
```

and then pass from quotient equality to the relation by:

```lean
theorem quotient_eq_implies_rel
    {α : Type*} (ρ : Setoid α) {a b : α} :
    Quotient.mk (s := ρ) a = Quotient.mk (s := ρ) b → ρ.r a b := by
```

using `Quotient.exact`.

---

## Observable orbit counting: exact definitions and sharp bounds

Introduce a finite observable-orbit count based on quotient classes visited in the first `card (Quotient ρ) + 1` iterates.

Define at least the following.

```lean
def quotientObservableTrace
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) (N : ℕ) :
    Fin (N + 1) → Quotient ρ :=
  fun i => Quotient.mk (s := ρ) ((f^[i.1]) x)

def observableOrbitSet
    {α : Type*} [DecidableEq (Quotient ρ)]
    (ρ : Setoid α) (f : α → α) (x : α) (N : ℕ) :
    Finset (Quotient ρ) :=
  Finset.univ.image (quotientObservableTrace ρ f x N)

def observableOrbitCount
    {α : Type*} [DecidableEq (Quotient ρ)]
    (ρ : Setoid α) (f : α → α) (x : α) (N : ℕ) : ℕ :=
  (observableOrbitSet ρ f x N).card
```

Then prove a sharp cardinality bound:

```lean
theorem eml_observable_orbit_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    [Fintype (Quotient ρ)] [DecidableEq (Quotient ρ)]
    (f : α → α) (x : α) (N : ℕ) :
    observableOrbitCount ρ f x N ≤ Fintype.card (Quotient ρ) := by
```

Also prove the compressed horizon version:

```lean
theorem eml_observable_orbit_bound_at_quotient_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    [Fintype (Quotient ρ)] [DecidableEq (Quotient ρ)]
    (f : α → α) (x : α) :
    observableOrbitCount ρ f x (Fintype.card (Quotient ρ)) ≤
      Fintype.card (Quotient ρ) := by
```

If your library setup makes `[Fintype (Quotient ρ)]` automatic from `[Fintype α]`, exploit that; otherwise instantiate it explicitly.

---

## Strengthen to first-repeat / minimal-repeat structure

Do not stop at existence. Define and prove a canonical first-collision package.

Introduce:

```lean
def isFirstQuotientRepeat
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) (m n : ℕ) : Prop :=
  m < n ∧
  ρ.r ((f^[m]) x) ((f^[n]) x) ∧
  ∀ a b : ℕ, a < b → b < n → ¬ ρ.r ((f^[a]) x) ((f^[b]) x)
```

Define the minimal repeat index:

```lean
def quotientRepeatTime
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) : ℕ :=
  Nat.find (exists_iterate_rel_of_card_quotient ρ f x |> ?_)
```

If this exact `Nat.find` packaging is awkward, define a Σ-structure instead:

```lean
structure QuotientRepeatCertificate
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) where
  m : ℕ
  n : ℕ
  strictMonoWitness : m < n
  horizonWitness : n ≤ Fintype.card (Quotient ρ)
  relatedWitness : ρ.r ((f^[m]) x) ((f^[n]) x)
```

Then prove existence:

```lean
theorem exists_QuotientRepeatCertificate
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    Nonempty (QuotientRepeatCertificate ρ f x) := by
```

And prove minimality/canonicality results such as:

```lean
theorem exists_first_quotient_repeat
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n, isFirstQuotientRepeat ρ f x m n ∧ n ≤ Fintype.card (Quotient ρ) := by
```

This theorem is especially valuable: it upgrades the coarse pigeonhole argument into a genuine orbit-structure theorem.

---

## Algebraic and computational compression layer

Define compression statistics that make the result useful beyond pure finiteness.

Suggested definitions:

```lean
def quotientCompressionGap
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) (m n : ℕ) : ℕ :=
  n - m

def quotientCollisionEntropy
    {α : Type*} [Fintype α] (ρ : Setoid α) : ℕ :=
  Fintype.card α - Fintype.card (Quotient ρ)

def orbitCompressionRatio
    {α : Type*} [Fintype α] (ρ : Setoid α) : ℚ :=
  (Fintype.card (Quotient ρ) : ℚ) / (Fintype.card α : ℚ)

def quotientObservableDiameter
    {α : Type*} [DecidableEq (Quotient ρ)]
    (ρ : Setoid α) (f : α → α) (x : α) (N : ℕ) : ℕ :=
  observableOrbitCount ρ f x N - 1
```

Prove explicit numerical bounds:

```lean
theorem quotientCollisionEntropy_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) :
    0 ≤ quotientCollisionEntropy ρ := by
```

```lean
theorem orbitCompressionRatio_le_one
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) :
    orbitCompressionRatio ρ ≤ 1 := by
```

```lean
theorem quotientObservableDiameter_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    [Fintype (Quotient ρ)] [DecidableEq (Quotient ρ)]
    (f : α → α) (x : α) (N : ℕ) :
    quotientObservableDiameter ρ f x N + 1 ≤ Fintype.card (Quotient ρ) := by
```

Use `omega`, `linarith`, and explicit arithmetic normalization where possible. Avoid reducing everything to `simp`.

---

## Cryptographic / certified robustness bridge theorems

Interpret quotient collisions as compressed observability certificates. Use these words explicitly in theorem names and doc comments.

Introduce a crypto-facing definition:

```lean
def lattice_crypto_collision_certificate
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) : Prop :=
  ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
    ρ.r ((f^[m]) x) ((f^[n]) x)
```

Then prove:

```lean
theorem post_quantum_security_collision_upper_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    lattice_crypto_collision_certificate ρ f x := by
```

Interpret this as a deterministic collision upper bound on quotient-observable states: after at most `|α/ρ| + 1` observations, a quotient collision must occur.

For ML/certified robustness language, define:

```lean
def certified_robustness_observable
    {α : Type*} (ρ : Setoid α) (f : α → α) : Prop :=
  ∀ x : α, ∃ m n : ℕ, m < n ∧
    n ≤ Fintype.card (Quotient ρ) ∧
    ρ.r ((f^[m]) x) ((f^[n]) x)
```

and prove:

```lean
theorem certified_robustness_via_quotient_compression
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) :
    certified_robustness_observable ρ f := by
```

This theorem should be stated with the quantifier alternation `∀ x, ∃ m, ∃ n, ...`, which is aesthetically important and mathematically stronger than a pointwise theorem.

---

## Semiconjugacy / functoriality under congruence-preserving maps

Connect the result to algebra and category-flavored dynamics.

Define congruence-respecting dynamics:

```lean
def RespectsSetoid
    {α : Type*} (ρ : Setoid α) (f : α → α) : Prop :=
  ∀ ⦃a b : α⦄, ρ.r a b → ρ.r (f a) (f b)
```

Prove iterated stability:

```lean
theorem respectsSetoid_iterate
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) :
    ∀ n : ℕ, ∀ ⦃a b : α⦄, ρ.r a b → ρ.r ((f^[n]) a) ((f^[n]) b) := by
```

This should use induction on `n`.

Construct the induced quotient map:

```lean
def quotientLiftMap
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) :
    Quotient ρ → Quotient ρ :=
  Quotient.map f (by
    intro a b hab
    exact hf hab)
```

Then prove semiconjugacy of iteration:

```lean
theorem quotientLiftMap_iterate_commutes
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) (x : α) (n : ℕ) :
    (quotientLiftMap ρ f hf^[n]) (Quotient.mk (s := ρ) x) =
      Quotient.mk (s := ρ) ((f^[n]) x) := by
```

If the notation `(quotientLiftMap ρ f hf^[n])` is inconvenient, define iterates separately. The important mathematical content is:
iteration before quotient = quotient-lift iteration after quotient.

Then derive the finite-orbit collision theorem directly on the quotient system as a second proof of the main theorem. This gives the file two genuinely different proof architectures.

---

## Symmetry and exactness results

Add special cases that identify when the quotient bound is sharp.

Define:

```lean
def QuotientOrbitSaturated
    {α : Type*} [Fintype (Quotient ρ)]
    (ρ : Setoid α) (f : α → α) (x : α) : Prop :=
  ∀ q : Quotient ρ, ∃ n : ℕ, n ≤ Fintype.card (Quotient ρ) ∧
    Quotient.mk (s := ρ) ((f^[n]) x) = q
```

Prove saturation implies maximal observable count:

```lean
theorem quotient_orbit_saturated_cardinality_exact
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    [Fintype (Quotient ρ)] [DecidableEq (Quotient ρ)]
    (f : α → α) (x : α)
    (hsat : QuotientOrbitSaturated ρ f x) :
    observableOrbitCount ρ f x (Fintype.card (Quotient ρ)) =
      Fintype.card (Quotient ρ) := by
```

And conversely prove a finite surjectivity lemma from cardinal equality, likely via `Finset.card_le_univ` and extensionality of the image set. This gives an exactness theorem rather than only an upper bound.

---

## Concrete finite models

Do not leave the development abstract only. Instantiate on explicit finite types.

### Model 1: modular arithmetic dynamics on `Fin k`

Define a simple affine map:

```lean
def finAffineMap (k a b : ℕ) : Fin k → Fin k
```

or, if simpler, use successor modulo `k`.

Define a setoid collapsing parity or residue classes modulo a divisor, and prove the main theorem concretely for this system. Example theorem:

```lean
theorem quantum_hash_orbit_collision_fin
    (k : ℕ) [NeZero k]
    (x : Fin k) :
    ∃ m n : ℕ, m < n ∧ n ≤ 2 ∧
      ((x + m) : Fin k).val % 2 = ((x + n) : Fin k).val % 2 := by
```

Adjust to whatever modular API is most robust in Lean. The point is to include one explicit finite computational example.

### Model 2: Boolean state compression on `Bool`

Define a nontrivial endomap `f : Bool → Bool` and the indiscrete / parity-like quotient. Prove exact orbit counts and first repeat times by case analysis with `decide`, `fin_cases`, `simp`, and `omega`.

---

## Required theorem inventory

Produce at least 20 theorems, including these 12 core statements or close variants with the same mathematical force:

1. `quotient_eq_implies_rel`
2. `exists_lt_lt_iterate_quotient_eq`
3. `exists_iterate_rel_of_card_quotient`
4. `eml_observable_orbit_bound`
5. `eml_observable_orbit_bound_at_quotient_card`
6. `exists_QuotientRepeatCertificate`
7. `exists_first_quotient_repeat`
8. `respectsSetoid_iterate`
9. `quotientLiftMap_iterate_commutes`
10. `post_quantum_security_collision_upper_bound`
11. `certified_robustness_via_quotient_compression`
12. `quotient_orbit_saturated_cardinality_exact`

Add at least 8 more nontrivial lemmas around:
- monotonicity in the horizon `N`,
- image-cardinality control,
- minimal repeat index uniqueness or partial uniqueness,
- exactness under saturation,
- concrete `Fin` / `Bool` examples,
- arithmetic bounds on compression gaps,
- transport across semiconjugacies.

---

## Recommended proof architecture

Use at least two distinct proof pathways for the core theorem family.

### Strategy A: direct finite pigeonhole on quotient traces
Most promising for the first theorem.

1. Consider the function
   `g : Fin (Fintype.card (Quotient ρ) + 1) → Quotient ρ`
   given by
   `g i = Quotient.mk _ ((f^[i.1]) x)`.
2. Since the domain has cardinality strictly greater than the codomain, invoke a finite pigeonhole theorem:
   either from `Fintype.card_lt_of_injective` contrapositive,
   `Finite.exists_ne_map_eq_of_card_lt`,
   or a `Finset`-image cardinality argument.
3. Extract distinct `i,j` with equal image, reorder to obtain `m < n` by `lt_or_gt_of_ne`.
4. Convert quotient equality to `ρ.r ... ...` via `Quotient.exact`.
5. Finish the arithmetic bound `n ≤ card (Quotient ρ)` from the fact that `j : Fin (card + 1)`.

Useful local lemmas to create if needed:

```lean
theorem fin_val_le_of_mem_horizon {N : ℕ} (i : Fin (N + 1)) : i.1 ≤ N := by
  exact Nat.le_of_lt_succ i.2
```

```lean
theorem exists_distinct_of_card_image_lt
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α]
    (g : α → β) (hcard : Fintype.card β < Fintype.card α) :
    ∃ a b : α, a ≠ b ∧ g a = g b := by
```

This auxiliary theorem is useful far beyond the present file.

### Strategy B: pass to the induced quotient dynamical system
Conceptually deeper and excellent for follow-up theorems.

1. Assume/define `RespectsSetoid ρ f` where needed.
2. Build `quotientLiftMap ρ f hf : Quotient ρ → Quotient ρ`.
3. Apply the already-known finite orbit repetition theorem on the quotient type itself.
4. Pull the resulting equality back to a relation on `α`.
5. Use this to prove functorial versions and saturation/exactness statements.

This strategy is more structural and should power the semiconjugacy theorems.

### Strategy C: minimal-counterexample / first-repeat extraction
Best for `exists_first_quotient_repeat`.

1. Use the existence theorem to show the set of repeat times `n` is nonempty.
2. Let `n₀` be the minimal repeat terminal index via `Nat.find` or `Nat.findX`.
3. Extract the corresponding `m₀ < n₀`.
4. Prove no earlier collision exists by minimality.
5. Package into `isFirstQuotientRepeat`.

This is the right place for `by_contra`, `Nat.find_spec`, and careful quantifier alternation.

---

## Lean-specific guidance

Use concrete signatures and keep universes simple. Helpful local declarations:

```lean
open Function
open scoped BigOperators
```

Possible imports if needed:

```lean
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Finset.Card
import Mathlib.Logic.Function.Iterate
import Mathlib.Data.Quot
import Mathlib.Tactic
```

Expect to need:
- `Function.iterate_succ_apply`
- `Quotient.exact`
- `Fintype.card_fin`
- `Fin.val_lt_iff`
- `Nat.lt_succ_iff`
- `Nat.le_of_lt_succ`
- `Finset.card_image_le`
- `Finset.card_univ`
- injective/noninjective cardinal lemmas
- `omega`, `linarith`, `nlinarith` for arithmetic cleanup.

Where a direct cardinal pigeonhole lemma is elusive, a robust alternative is:
- consider `Finset.univ.image g`,
- prove its card is at most the codomain card,
- prove strict inequality against the domain size,
- conclude `g` is not injective on `Fin (k+1)`,
- extract distinct indices.

---

## Significance to the research program

This file should make quotient-cardinality compression a reusable theorem schema, not a one-off lemma. The point is not merely “some iterates are related”; the point is:

- finite congruence quotients act as observable state spaces,
- every deterministic trajectory has a bounded-horizon quotient collision,
- the collision horizon is explicitly certified by `|α/ρ|`,
- this becomes a formal collision certificate for `post_quantum_security`,
- and a finite-state `certified_robustness` theorem for observable trajectories.

Bridge explicitly in doc comments:
- **Bridge: algebraic dynamics ↔ cryptographic collision bounds**
- **Bridge: quotient cardinality ↔ certified robustness observables**
- **Bridge: finite orbit theory ↔ EML state compression**
- **Bridge: semiring congruence functoriality ↔ quotient dynamical systems**

Use these keywords in theorem names or doc comments where natural:
`quantum`, `post_quantum`, `lattice_crypto`, `entropy`, `certified_robustness`, `observable`, `compression`, `hamiltonian`.

---

## File richness requirements inside the theorem development

Include at least 10 definitions/structures/abbreviations, for example:
- `quotientObservableTrace`
- `observableOrbitSet`
- `observableOrbitCount`
- `isFirstQuotientRepeat`
- `QuotientRepeatCertificate`
- `quotientCompressionGap`
- `quotientCollisionEntropy`
- `orbitCompressionRatio`
- `quotientObservableDiameter`
- `lattice_crypto_collision_certificate`
- `certified_robustness_observable`
- `RespectsSetoid`
- `quotientLiftMap`
- `QuotientOrbitSaturated`

At least one structure should carry data plus proofs (`QuotientRepeatCertificate` is ideal).

Use diverse tactics across the file:
- induction for iterate-respect lemmas,
- `rcases` for existential extraction,
- `by_contra` for minimality/uniqueness,
- `omega` and `linarith` for index arithmetic,
- `field_simp` if you formalize ratio bounds over `ℚ`,
- `simp` only as support, not as the whole proof style.

If a theorem is too ambitious in full generality, prove the strongest fully rigorous special case and state the exact stronger conjecture as a commented target. But the two named target theorems above must be fully proved with zero sorries.

---

## FUTURE_DIRECTIONS.md

Also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each specific enough to formalize next. Include at least:
1. quotient-period decomposition (`preperiod + period ≤ |α/ρ| + 1`);
2. semiring congruence dynamics on algebraic endomorphisms;
3. entropy-style lower/upper bounds comparing `card α` and `card (Quotient ρ)`;
4. lattice / post-quantum interpretation of quotient collision certificates;
5. certified robustness for quotient-observable neural or tropical state transitions.

Each future direction should name exact proposed definitions and target theorem signatures.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Develop a quotient-sensitive reconstruction principle for finitary closure dynamics: if an endomorphism or closure-respecting self-map acts on a finite algebraic/EML state space equipped with a decidable setoid or semiring congruence, then eventual orbit repetition and periodic compression are controlled by the cardinality of the quotient rather than the ambient space. The core target is to prove a sharp quotient-cardinality recurrence theorem and then transport it into EML closure systems as a computational compression principle for intrinsic state complexity. This extends Aristotle's top recommendation while opening a broader bridge from algebraic congruence structure to EML dynamical semantics, and it is distinct from current inflight jobs because it focuses on quotient-sensitive orbit bounds and reconstruction-by-compression rather than renormalization, trace formulas, zeta growth, or Tannaka/Lefschetz machinery.

            ### Precise Mathematical Framing
            Primary theorem: for a finite type α with decidable equality, a decidable setoid ρ on α, and f : α → α, prove ∀ x, ∃ m n, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧ ρ.r ((f^[m]) x) ((f^[n]) x). Strengthen this to a minimal obstruction horizon bounded by the quotient cardinality. Then define an EML closure dynamical system as a finite carrier with closure operator c and c-stable endomorphism f, together with a behavioral congruence ρ identifying states with the same closure observables. Prove that the induced quotient dynamics on Quotient ρ determines eventual periodicity witnesses and yields a reconstruction/compression bound: the number of distinct observable orbit profiles is at most Fintype.card (Quotient ρ). Secondary targets: monotonicity under refinement/coarsening of congruences; functorial transfer along SemiringCong/ProofCongruence-style quotients; and an algorithm extracting bounded recurrence certificates from quotient representatives. This creates a concrete pipeline from finite pigeonhole/orbit lemmas to EML state minimization via congruence compression.

            ### Lean 4 Sketch
theorem exists_iterate_rel_of_card_quotient {α : Type*} [Fintype α] [DecidableEq α] (ρ : Setoid α) [DecidableRel ρ.r] (f : α → α) (x : α) : ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧ ρ.r ((f^[m]) x) ((f^[n]) x) := by
  -- quotient-valued pigeonhole on i ↦ Quotient.mk _ ((f^[i]) x)
  sorry

theorem eml_observable_orbit_bound ... : observableOrbitCount f ρ x ≤ Fintype.card (Quotient ρ) := by
  ...

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `finite_field_state_space` : theorem finite_field_state_space
     (file: Bridges/ByzantineCertificate.lean)
  2. `finite_spectral_reconstruction_bridge` : theorem finite_spectral_reconstruction_bridge
     (file: Bridges/ClosureKoopmanReconstruction.lean)
  3. `finite_witness_of_eventual_growth_gap` : theorem finite_witness_of_eventual_growth_gap {α : Type*}
     (file: Bridges/EntropyClosureSeparation.lean)
  4. `closure_preserving_map_extends_to_stoneCech_certified` : theorem closure_preserving_map_extends_to_stoneCech_certified
     (file: Bridges/ProofStoneCechDynamics.lean)
  5. `cocycle_space_cardinality_bound` : theorem cocycle_space_cardinality_bound
     (file: Bridges/GaloisCohomologicalConsensus.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Berggren–Chronometric Reversible Automata via Primitive Triple Orbit Groupoids and Causal Entropy Separation, Algebra–EML Morita Equivalence via Closure Semimodule Bimodules and Capacity Invariance, Algebra–Speculative Fixed-Point Logic via Proof-Semiring Diagonalization and Chronometric Incompleteness Bounds


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.json** — MANDATORY JSON Data Package
               Bundle ALL artifacts into a single JSON file for the web frontend:
               • Output a strictly valid JSON object:
                 {
                   "title": "Title", "domain": "Domain",
                   "article": "Markdown content...",
                   "research_paper": "Markdown content...",
                   "future_directions": "Markdown content...",
                   "demos": [ { "name": "...", "code": "..." } ],
                   "algorithms": [ { "name": "...", "pseudocode": "..." } ],
                   "visualizations": [ { "name": "...", "data": "base64 URI or inline SVG" } ],
                   "lean_proofs": "Raw lean code..."
                 }
               • Ensure all Markdown and code is properly JSON-escaped.
               • ALL images MUST be embedded as base64 data URIs or inline SVG within the `data` field.
                 If you generate matplotlib/plotly charts, convert to base64.
                 NEVER reference external image files — they won't exist standalone.
               • This JSON file powers the dynamic web UI. Include ALL content.

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "..." } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
