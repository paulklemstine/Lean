## Research Task: Berggren semigroup two-sided Ore obstruction and non-commutative collision-resistance for the SL₂(ℤ) SPB embedding

Research Mode: PROVE

Work in a new file
`Cryptography/SPB/BerggrenLeftOreObstruction.lean`.

The goal is to push the already-formalized Berggren/SPB semigroup structure from cancellation and left-divisibility into a sharp **left-Ore obstruction theorem** and then package the result into a clean **prefix anti-collision theorem** for protocol transcripts. The mathematically important point is that this gives a genuinely noncommutative security invariant: equal products cannot arise from incomparable left prefixes. This is different from right-cancellation phenomena and is exactly the sort of structural rigidity one wants for transcript encodings in the SPB Diffie–Hellman embedding.

### Core objects and intended setup

Use the same semigroup type already introduced for the Berggren generators in the SPB development. If the existing files represent elements directly as `Matrix (Fin 2) (Fin 2) ℤ`, keep that representation; if there is already a bundled subsemigroup or inductive closure type for the Berggren semigroup, use that instead.

You should expose and use a left-divisibility relation of the form
```lean
def LeftDivides (a b : S) : Prop := ∃ x : S, b = x * a
```
with notation if convenient:
```lean
infix:50 " ≤L " => LeftDivides
```

Likewise define existence of a common left multiple:
```lean
def HasCommonLeftMultiple (a b : S) : Prop :=
  ∃ c x y : S, c = x * a ∧ c = y * b
```
or equivalently
```lean
def HasCommonLeftMultiple (a b : S) : Prop :=
  ∃ x y : S, x * a = y * b
```
depending on which form interacts better with your existing lemmas.

For words in generators, use `List Generator` (or the exact generator type already present), together with the existing evaluation map into the Berggren semigroup:
```lean
def evalWord : List Generator → S
```
and a list-prefix relation:
```lean
l₁ <+: l₂
```
from `List.IsPrefix`, or an equivalent custom definition if already present.

### Main theorem: sharp left-Ore obstruction

The central statement should be formalized as close as possible to:

```lean
theorem hasCommonLeftMultiple_iff_comparable_leftDivides
    (a b : S) :
    HasCommonLeftMultiple a b ↔ a ≤L b ∨ b ≤L a := by
  ...
```

If the existing library already has a theorem that `≤L` is a partial order (or at least reflexive/transitive/antisymmetric using left-cancellation), explicitly reuse it.

A very useful equivalent formulation, worth proving as a separate lemma if needed, is:

```lean
theorem eq_mul_imp_comparable_leftDivides
    {a b x y : S} (h : x * a = y * b) :
    a ≤L b ∨ b ≤L a := by
  ...
```

Then the forward implication of the Ore obstruction is immediate from this lemma, while the reverse implication is just witnessed by reflexivity:
- if `b = x * a`, then `x * a = 1 * b` if an identity is available,
- or more semigroup-intrinsically, witness the common left multiple by `b` itself;
- similarly for the other branch.

If your Berggren structure is only a semigroup and not a monoid, phrase the reverse implication carefully so that you do not require a global identity element. For example:
```lean
theorem leftDivides_hasCommonLeftMultiple_left
    {a b : S} (h : a ≤L b) :
    HasCommonLeftMultiple a b := by
  rcases h with ⟨x, rfl⟩
  exact ⟨x, ?_, rfl, ?_⟩
```
or simply define `HasCommonLeftMultiple` using `∃ x y, x * a = y * b`.

### Proof strategy for the nontrivial implication

The key theorem is not a pure cancellation argument; it should use the **free-tree/normal-form geometry** of the Berggren semigroup. Concretely, if `x * a = y * b`, then the left prefixes encoded by `x` and `y` must be compatible in the rooted Berggren tree, forcing one suffix to extend the other. A robust route in Lean is:

1. **Choose normal-form words for all semigroup elements.**  
   Use the existing freeness/unique factorization theorem for the Berggren generators if already available. If the current development phrases this as injectivity of word evaluation, isolate a lemma:
   ```lean
   theorem evalWord_injective : Function.Injective evalWord := ...
   ```
   or the stronger “equal products imply equal generator lists”.

2. **Translate the equation `x * a = y * b` to an equation of concatenated words.**  
   Pick words `wx wa wy wb` with
   ```lean
   evalWord wx = x, evalWord wa = a, evalWord wy = y, evalWord wb = b
   ```
   then obtain
   ```lean
   evalWord (wx ++ wa) = evalWord (wy ++ wb)
   ```
   and by injectivity:
   ```lean
   wx ++ wa = wy ++ wb.
   ```

3. **Apply the list anti-unification lemma.**  
   Prove a purely combinatorial lemma on lists:
   ```lean
   theorem append_eq_append_implies_prefix_or_prefix
       {α : Type _} [DecidableEq α]
       {u v a b : List α}
       (h : u ++ a = v ++ b) :
       u <+: v ∨ v <+: u := by
     ...
   ```
   A stronger version is even better:
   ```lean
   theorem append_eq_append_decompose
       {α : Type _} [DecidableEq α]
       {u v a b : List α}
       (h : u ++ a = v ++ b) :
       (∃ t, v = u ++ t ∧ a = t ++ b) ∨
       (∃ t, u = v ++ t ∧ b = t ++ a) := by
     ...
   ```
   This is the exact combinatorial content needed. It is elementary but not trivial, and very useful downstream.

4. **Push the list decomposition back to semigroup divisibility.**  
   In the first branch, from `v = u ++ t` and `a = t ++ b`, conclude
   ```lean
   evalWord a = evalWord t * evalWord b
   ```
   or the orientation matching your multiplication convention, hence `b ≤L a` or `a ≤L b`.  
   Be very careful about whether `evalWord (u ++ v) = evalWord u * evalWord v` or the reverse convention is used in the current files. State and use the exact existing theorem.

5. **Use antisymmetry/cancellation only at the end.**  
   The comparability result should emerge from word-prefix geometry, not from any hidden commutativity. This is exactly what makes the theorem cryptographically meaningful.

### Essential combinatorial lemma on words

It is strongly recommended to formalize the list lemma independently, because it will likely be reusable:

```lean
theorem prefix_or_prefix_of_append_eq_append
    {α : Type _} [DecidableEq α]
    {u v a b : List α}
    (h : u ++ a = v ++ b) :
    u <+: v ∨ v <+: u := by
  ...
```

An even more useful strengthening:

```lean
theorem suffix_comparison_of_append_eq_append
    {α : Type _} [DecidableEq α]
    {u v a b : List α}
    (h : u ++ a = v ++ b) :
    (∃ t, v = u ++ t ∧ a = t ++ b) ∨
    (∃ t, u = v ++ t ∧ b = t ++ a) := by
  ...
```

This proof can be done by induction on `u` and case split on `v`, or by using existing `List` prefix lemmas if available in Mathlib. If there is a theorem already close to “two lists with equal extensions are prefix-comparable”, use it, but a self-contained proof is fine.

### Word-level anti-unification theorem

Once the semigroup theorem is established, derive the clean word statement:

```lean
theorem evalWord_mul_eq_evalWord_mul_implies_prefix
    {u v α β : List Generator}
    (h : evalWord u * evalWord α = evalWord v * evalWord β) :
    u <+: v ∨ v <+: u := by
  ...
```

If multiplication of evaluated words is represented via concatenation, this should be proved by rewriting:
```lean
evalWord (u ++ α) = evalWord (v ++ β)
```
then using injectivity and the list lemma.

A sharper decomposition theorem is better if you can prove it:

```lean
theorem evalWord_mul_eq_evalWord_mul_decompose
    {u v α β : List Generator}
    (h : evalWord u * evalWord α = evalWord v * evalWord β) :
    (∃ t, v = u ++ t ∧ evalWord α = evalWord t * evalWord β) ∨
    (∃ t, u = v ++ t ∧ evalWord β = evalWord t * evalWord α) := by
  ...
```

This is the exact algebraic anti-unification principle behind the Ore obstruction.

### Collision exclusion for incomparable prefixes

Package the cryptographic corollary in a directly usable form. For example:

```lean
theorem no_prefix_collision_of_incomparable
    {u v α β : List Generator}
    (huv : ¬ u <+: v ∧ ¬ v <+: u) :
    evalWord u * evalWord α ≠ evalWord v * evalWord β := by
  ...
```

A variant specialized to nonempty, distinct transcript prefixes is also useful:

```lean
theorem no_collision_of_distinct_incomparable_nonempty_prefixes
    {u v α β : List Generator}
    (hu : u ≠ [])
    (hv : v ≠ [])
    (hinc : ¬ u <+: v ∧ ¬ v <+: u) :
    evalWord u * evalWord α ≠ evalWord v * evalWord β := by
  ...
```

If the protocol layer already has a transcript type or a map from transcripts to Berggren words, restate the corollary there as well. But the semigroup/word theorem should be proved first in a self-contained algebraic form.

### Explicit incomparable pair with no common left multiple

To make the obstruction concrete, exhibit a pair of distinct generators with no common left multiple. Assuming the three Berggren generators are named something like `A B C`, prove a theorem of the form:

```lean
theorem not_hasCommonLeftMultiple_of_distinct_generators
    (hAB : A ≠ B) :
    ¬ HasCommonLeftMultiple A B := by
  ...
```

More explicitly, if the generators are available as constants:

```lean
theorem gen1_gen2_no_common_left_multiple :
    ¬ HasCommonLeftMultiple gen1 gen2 := by
  ...
```

The proof should be:
- if they had a common left multiple, then by the main theorem they would be left-divisibility comparable;
- by freeness / unique normal forms / generator irreducibility, neither generator left-divides the other unless equal;
- contradiction.

A supporting lemma likely needed is:

```lean
theorem generator_leftDivides_generator_iff_eq
    {g h : Generator} :
    LeftDivides (evalWord [g]) (evalWord [h]) ↔ g = h := by
  ...
```

or the semigroup-element version for the three named generators.

### Significance to the research program

This theorem should be presented in the file as a genuine structural strengthening of the Berggren/SPB theory, not just a list fact. The important consequences are:

1. **Failure of the left Ore condition in the sharpest possible way.**  
   Common left multiples exist exactly along chains in the left-divisibility poset. Thus the Berggren semigroup is highly non-Ore on the left, and the obstruction is completely classified.

2. **Tree geometry becomes algebraic security.**  
   The rooted-tree normal form implies that incomparable prefixes can never be equalized by appending suffixes. This is a strong noncommutative collision-resistance property for transcript prefixes.

3. **This is orthogonal to right-cancellation/common-right-multiple work.**  
   The result gives a new invariant on the opposite side of multiplication, so it broadens the SPB cryptographic foundation rather than duplicating existing cancellation lemmas.

4. **Reusable bridge between free semigroup combinatorics and matrix semantics.**  
   The file should leave behind reusable lemmas translating between list-prefix structure and divisibility/common-multiple structure in the concrete `SL₂(ℤ)` Berggren embedding.

### Suggested theorem order

A good implementation order is:

```lean
def LeftDivides ...
def HasCommonLeftMultiple ...

theorem suffix_comparison_of_append_eq_append ...
theorem prefix_or_prefix_of_append_eq_append ...

theorem eq_mul_imp_comparable_leftDivides ...
theorem hasCommonLeftMultiple_iff_comparable_leftDivides ...

theorem evalWord_mul_eq_evalWord_mul_implies_prefix ...
theorem no_prefix_collision_of_incomparable ...

theorem generator_leftDivides_generator_iff_eq ...
theorem gen1_gen2_no_common_left_multiple ...
```

### Technical Lean advice

- Keep the combinatorial list lemmas completely generic over `List α`; this will make the later algebraic arguments much shorter.
- Be explicit about the orientation of multiplication versus concatenation:
  ```lean
  evalWord (u ++ v) = evalWord u * evalWord v
  ```
  or its reverse, depending on the existing convention.
- If the semigroup is represented by matrices, avoid matrix-level calculations in the main theorem. The point is to derive the result from freeness/normal forms, not from entrywise arithmetic.
- If injectivity of `evalWord` is not already packaged, proving it cleanly may be the real bottleneck. Isolate that as a standalone lemma and let the rest of the file flow from it.
- Prefer proving the stronger decomposition theorem from an equality of appended words; the prefix theorem and the Ore obstruction then become easy corollaries.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Cryptography
Research mode: prove
