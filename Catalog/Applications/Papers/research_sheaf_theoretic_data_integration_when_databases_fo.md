# The Algebra of Sheaf Imputation: Partial Sections, Left-Regular Bands, and the Local Certificate of Consistent Completion

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Algebra

## Abstract

We model a database row with missing entries as a *partial section* of a
discrete sheaf of records, `PartialSection ι α := ι → Option α`, and study the
left-biased merge operation `glue` that overlays one record on another. We prove
that partial sections form an **idempotent monoid** under `glue` with the
all-missing row `emptySection` as two-sided identity, and that they satisfy the
two defining identities of a **left-regular band**, `glue (glue f g) f = glue f g`
and `glue f (glue g f) = glue f g`. We then establish the **sheaf condition for
databases**: a family of records admits a global section — a consistent
completion extending every member — *if and only if* it is pairwise compatible
(`compatible_iff_exists_common_extension`, `glue_family_exists`). We complement
existence with **uniqueness** (`glue_unique`): the greedy merge is the unique
global section whose support lies within the union of the records' supports, and
with a **locality** principle (`restrict_locality`) showing a record is
determined by its cell values. All results are stated for an arbitrary index type
`ι` and value type `α` with no finiteness, ordering, or topological assumptions.
We give proof sketches, an imputation algorithm with complexity analysis, and a
probabilistic model `P(consistent) = (1-r)^N` predicting an exponential
feasibility cliff in the number of overlapping constraints. The contribution is a
fully elementary, certificate-bearing reformulation of consistent data imputation
as a sheaf-gluing problem.

## 1. Introduction

Imputation — the completion of missing entries in a dataset — is ubiquitous and
usually treated heuristically (mean substitution, k-nearest-neighbor copying,
chained equations). We argue that the *combinatorial backbone* of imputation is
algebraic and sheaf-theoretic, and that this backbone is both clean and useful:
it yields a local, checkable certificate for the existence of a consistent
completion and a canonical, unique completion when one exists.

Our objects are deliberately minimal. A record over a column-index set `ι` with
values in `α` is a function `ι → Option α`. The overlay merge `glue` is the
operation a practitioner performs without thinking when they layer one record
over another. Our thesis is that this operation is a genuine algebraic structure
— a left-regular band — and that the sheaf gluing axiom, specialized to this
setting, is exactly the statement that *local (pairwise) compatibility implies
global consistency*.

### 1.1 Contributions

1. **Monoid and band structure** of `(PartialSection ι α, glue, emptySection)`:
   identity, associativity, idempotence, and both left-regular band laws.
2. **Sheaf condition**: existence of a global section is equivalent to pairwise
   compatibility, with an explicit greedy construction.
3. **Uniqueness and locality**: support-bounded global sections are unique, and
   records are determined by their cell values.
4. **A probabilistic model** for feasibility decay, `P(consistent) = (1-r)^N`,
   with monotonicity and an exponential-cliff conjecture.

## 2. Definitions

Throughout, `ι` is a type of column indices, `α` a type of values, and `κ` an
index type for families of records. We use `Option α` with constructors `some a`
(a present value) and `none` (a missing value).

**Definition 1 (Partial section).** `PartialSection ι α := ι → Option α`. A
partial section (record) assigns to each column either a value or "missing".

**Definition 2 (Support).** `Support f := {i | f i ≠ none}`, the set of filled
columns.

**Definition 3 (Compatibility).** `Compatible f g :⇔ ∀ i, f i ≠ none → g i ≠ none
→ f i = g i`. Two records are compatible iff they agree on every column where
both are defined.

**Definition 4 (Extension).** `Extends g f :⇔ ∀ i, f i ≠ none → g i = f i`. The
record `g` extends `f` iff it agrees with `f` on `f`'s support (it may fill in
more, but never overwrites).

**Definition 5 (Binary glue).**
`glue f g := fun i => match f i with | some a => some a | none => g i`.
The overlay merge: take `f`'s value where present, otherwise `g`'s.

**Definition 6 (Pairwise compatibility).** For `s : κ → PartialSection ι α`,
`PairwiseCompatible s :⇔ ∀ j k, Compatible (s j) (s k)`.

**Definition 7 (Family glue).** Using choice,
`familyGlue s := fun i => if h : ∃ j, s j i ≠ none then s (choose h) i else none`.
At each column, take the value of any member defined there, if one exists.

**Definition 8 (Empty section).** `emptySection := fun _ => none`, the
all-missing record.

**Definition 9 (Global section).** `HasGlobalSection s :⇔ ∃ h, ∀ j, Extends h (s
j)`. A family has a global section iff some record extends all of its members.

The basic pointwise behavior of `glue` is recorded as:

**Lemma 1 (`glue_apply`).** `(glue f g) i = if f i ≠ none then f i else g i`.
*Proof.* Case split on `f i`. ∎

## 3. The monoid and band structure

**Theorem 10 (Identity — `glue_emptySection_left`, `glue_emptySection_right`).**
For every record `f`, `glue emptySection f = f` and `glue f emptySection = f`.

*Proof sketch.* By functional extensionality it suffices to check at each column
`i`. For the left law, `emptySection i = none`, so by `glue_apply` the merge falls
through to `f i`. For the right law, case split on `f i`: if `f i = some a` the
merge returns `some a = f i`; if `f i = none` the merge returns `emptySection i =
none = f i`. ∎

**Theorem 11 (Associativity — `glue_assoc`).**
`glue (glue f g) h = glue f (glue g h)`.

*Proof sketch.* Pointwise, perform the nested case analysis on `f i` and `g i`.
If `f i = some a`, both sides yield `some a`. If `f i = none` and `g i = some b`,
both yield `some b`. If `f i = none = g i`, both yield `h i`. All three branches
agree. ∎

**Theorem 12 (Idempotence — `glue_idem`).** `glue f f = f`.

*Proof sketch.* Pointwise: if `f i = some a` the merge returns `some a`; if `f i =
none` the merge falls through to the second copy, again `none`. Either way the
result equals `f i`. ∎

Theorems 10–12 give:

**Corollary (Idempotent monoid).** `(PartialSection ι α, glue, emptySection)` is
a monoid in which every element is idempotent.

**Theorem 13 (Left-regular band laws — `glue_band_left`, `glue_band_right`).**
`glue (glue f g) f = glue f g` and `glue f (glue g f) = glue f g`.

*Proof sketch.* Both are pointwise case splits on `f i` and `g i`. For
`glue_band_left`: if `f i = some a`, the outer `glue (·) f` already returns `some
a` from the left argument, which equals `glue f g` at `i`; if `f i = none`, the
left law's inner `glue f g` reduces to `g i` and re-gluing `f` (still `none`)
leaves `g i`. The companion law is symmetric in structure. The two identities,
together with idempotence and associativity, are exactly the axioms of a
left-regular band. ∎

**Remark (Non-commutativity).** `glue` is *not* commutative: when `f i` and `g i`
are both defined and unequal, `glue f g` and `glue g f` differ. Hence
commutative-monoid simplifications do not apply, and the band laws are the precise
record of left-biased precedence. This is the correct semantics for conflicting
data sources, where trust order matters.

## 4. The sheaf condition: existence of consistent completions

We first record how `glue` interacts with support and extension.

**Proposition 2 (`support_glue_eq_union`).** `(glue f g).Support = f.Support ∪
g.Support`. *Proof.* Pointwise: `glue f g` is defined at `i` iff `f` or `g` is. ∎

**Lemma 3 (`glue_extends_left`).** `Extends (glue f g) f`. *Proof.* Where `f i =
some a`, `glue` returns `some a`. ∎

**Lemma 4 (`glue_extends_right`).** If `Compatible f g` then `Extends (glue f g)
g`. *Proof.* At a column where `g i = some b`: if `f i = none`, `glue` returns `g
i`; if `f i = some a`, compatibility forces `a = b`, so `glue` returns `some a =
some b = g i`. ∎

These combine into the binary sheaf condition.

**Theorem 5 (Binary sheaf condition — `compatible_iff_exists_common_extension`).**
`Compatible f g ↔ ∃ h, Extends h f ∧ Extends h g`.

*Proof sketch.* (⇐) If a common extension `h` exists, then at any column where
both `f` and `g` are defined, `f i = h i = g i` (`compatible_of_common_extension`),
so they agree. (⇒) If `f, g` are compatible, take `h := glue f g`; by Lemma 3 it
extends `f`, and by Lemma 4 (using compatibility) it extends `g`. ∎

The arbitrary-family version is the genuine gluing axiom.

**Lemma 8 (`familyGlue_extends`).** If `PairwiseCompatible s`, then for every `j`,
`Extends (familyGlue s) (s j)`. *Proof sketch.* At a column `i` with `s j i =
some a`, `familyGlue` selects the value of some member `s k` defined at `i`;
pairwise compatibility of `s k` and `s j` forces that value to equal `a`. ∎

**Theorem 9 (Sheaf gluing — `glue_family_exists`).** If `PairwiseCompatible s`,
then `∃ h, ∀ j, Extends h (s j)`; equivalently `HasGlobalSection s`. *Proof.*
Take `h := familyGlue s` and apply Lemma 8. ∎

**Interpretation.** Theorem 9 is the headline: *global consistency is certified by
local (pairwise) checks.* No higher-order conflict can exist that pairwise
compatibility fails to detect. The certificate of feasibility is a quadratic-time
all-pairs comparison; the witness is the greedy merge `familyGlue`.

## 5. Uniqueness and locality

A global section, when it exists, is canonical under a minimality condition.

**Theorem 7 (Uniqueness — `glue_unique`).** Let `f, g` be records and `h` any
record with `Extends h f`, `Extends h g`, and `h.Support ⊆ f.Support ∪
g.Support`. Then `h = glue f g`.

*Proof sketch.* Pointwise. If `f i = some a`, then `h i = f i = glue f g` at `i`.
If `f i = none` but `g i = some b`, then `h i = g i = glue f g` at `i`. If both `f
i` and `g i` are `none`, the support bound forces `h i = none` (otherwise `i ∈
h.Support` but `i ∉ f.Support ∪ g.Support`, contradiction), matching `glue f g`. ∎

**Remark (Load-bearing support bound).** Without `h.Support ⊆ f.Support ∪
g.Support`, uniqueness fails: any extension that *invents* values in columns no
record mentions is still a common extension. The bound encodes the honest
imputation principle — fill only cells the data speaks to. It is therefore
necessary, not cosmetic.

**Theorem 6 (Locality — `restrict_locality`).** If `Extends f g` and `Extends g
f`, then `f = g`. *Proof sketch.* Pointwise: if both are `none` at `i` they
agree; otherwise the defined side is preserved by the mutual extension, forcing
equality. ∎

Locality is the sheaf "identity/separation" axiom: a section is determined by its
restrictions (here, its individual cell values).

## 6. The Sheaf Imputation algorithm

Given a family of records `s_1, …, s_m` over columns `ι` with `|ι| = n`:

```
SheafImpute(s_1, ..., s_m):
  # 1. Feasibility certificate (sheaf condition, Theorem 9)
  for each pair (j, k) with j < k:
    for each column i:
      if s_j[i] != missing and s_k[i] != missing and s_j[i] != s_k[i]:
        report CONFLICT at (rows j,k, column i); return INFEASIBLE
  # 2. Canonical completion (familyGlue, Theorem 9 + uniqueness, Theorem 7)
  h := record with all columns missing            # emptySection
  for each column i:
    for j in 1..m:
      if s_j[i] != missing:
        h[i] := s_j[i]; break
  return h     # unique global section bounded by the union of supports
```

**Complexity.** The feasibility check is `O(m^2 n)` (all pairs, all columns); the
completion is `O(m n)`. By Theorem 9 the pairwise scan is *sound and complete* —
it returns INFEASIBLE exactly when no global section exists — and by Theorem 7 the
returned `h` is the unique support-bounded completion. Conflicts are reported as
concrete `(row, row, column)` triples, an explanatory diagnostic absent from
mean/KNN imputation.

## 7. A probabilistic model of feasibility

Beyond the deterministic algebra, we model when feasibility holds at random.
Suppose a table of `n` columns and `k` rows induces `N` overlapping pairwise
constraints (e.g. `N = C(n,k)` in the concept framing), and each constraint is
independently satisfied with probability `1 - r`, where `r` is the
missingness/corruption rate. By independence,

```
P(consistent) = (1 - r)^N.
```

This closed form is monotone: decreasing in `r`, decreasing in `N`, and (since
the number of constraints grows with the number of columns `n`) decreasing in `n`.
As `N → ∞` with `r > 0`, `P(consistent) → 0` exponentially. We state as a
**conjecture** (Phase A "Conjecture 3") that this induces a *sharp threshold*:
feasibility is `≈ 1` below a critical rate `r* = 1 - N^{-1/N}` and `≈ 0` above it
as `n → ∞`, because `(1-r)^N` crosses any fixed level within an `O(1/N)` window of
`r`. The relevant monotonicity and `tendsto_zero` facts are flagged in Phase A as
`consistencyProb_antitone_columns` and `consistencyProb_tendsto_zero`; we treat
the formula and threshold here strictly as a model/conjecture, not as a theorem of
the verified core of Sections 3–5.

**Practical reading.** Sheaf imputation imposes exponentially many consistency
constraints. When `r` is small and `n` is large, the surviving consistent
completion is highly informative — far more so than mean or KNN imputation, which
ignore cross-column constraints. When `r` is large, the sheaf condition fails
*loudly* (a reported conflict) rather than silently fabricating averages.

## 8. Applications

- **Data fusion / record linkage.** Merging records about the same entities from
  multiple sources is exactly `familyGlue`; the pairwise check (Theorem 9) is a
  principled conflict detector with locatable certificates.
- **Federated and streaming integration.** Associativity (Theorem 11) and
  idempotence (Theorem 12) make `glue` safe to apply incrementally and with
  at-least-once delivery: re-merging a duplicate record is a no-op.
- **Provenance and precedence.** The left-regular band laws (Theorem 13) formalize
  "first source wins," giving a clean semantics for trust-ordered merges.
- **Constraint diagnostics.** Infeasibility is always witnessed by a concrete
  conflicting cell pair, supporting human-in-the-loop data repair.

## 9. Discussion

The development is intentionally elementary: no topology, no category theory, no
finiteness. All laws reduce to a per-column case split on `Option`. Yet the
structure recovered — idempotent monoid, left-regular band, sheaf gluing,
support-bounded uniqueness, locality — is precisely the structure that sheaf
theory predicts for sections of a (discrete) sheaf of records. The conceptual
payoff is that *imputability is a local property*: pairwise agreement is the
cocycle condition, and its failure is the obstruction to gluing.

## 10. Future work

The Phase A program identifies four directions, summarized here: (1) prove that
the gluing band is the *free* left-regular band on singleton cell-assignments,
with a normal-form/uniqueness theorem; (2) interpret the obstruction to imputation
cohomologically, with `H^0` the space of global sections and `dim H^1` the conflict
count over the overlap nerve; (3) establish the sharp feasibility threshold `r* =
1 - C(n,k)^{-1/C(n,k)}` from the proven monotonicity and exponential decay; and
(4) characterize non-support-bounded extensions as band extensions of `familyGlue`,
making the support bound minimally necessary. The full statements appear in the
package's future-directions record.

## 11. Conclusion

Consistent data imputation, stripped to its combinatorial core, is the gluing of
partial sections of a sheaf. The merge operation is an idempotent, left-regular
band with the empty record as identity; consistent completion exists exactly when
records are pairwise compatible; and the completion is unique on the cells the
data actually mentions. These are not metaphors but proved theorems, and they
turn "fill in the blanks" into a problem with certificates, canonical answers, and
a predictive theory of when it can be solved at all.
