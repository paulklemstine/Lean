## Research Task: Berggren semigroup right-cancellation and common-right-multiple structure for the SL₂(ℤ) SPB embedding

Research Mode: PROVE

Work in the concrete Berggren/SPB semigroup already formalized inside `SL(2, ℤ)` (or as `Matrix (Fin 2) (Fin 2) ℤ` with determinant `1` plus closure under multiplication, depending on the existing file design). Build explicitly on the already verified freeness / unique-normal-form theorem for the three Berggren generators. The goal is to push the combinatorics of free words all the way through to matrix-theoretic right ideals.

### Main theorem targets

You should aim to formalize a package of results in a new file

```lean
Cryptography/SPB/BerggrenRightCancellation.lean
```

with theorem statements as close as possible to the following Lean signatures, adapted to the exact existing names for the semigroup, generators, and normal-form map.

If the development already exposes:
- a type `BergWord := List (Fin 3)` or similar for generator words,
- an evaluation map `evalWord : BergWord → S`,
- a normal form map `normalForm : S → BergWord`,
- and inverse theorems `eval_normalForm` and `normalForm_eval`,
then the strongest clean statements are:

```lean
theorem right_cancel
    {x y z : S} :
    x * z = y * z ↔ x = y
```

```lean
theorem right_cancel'
    {x y z : S} :
    x * z = y * z → x = y
```

```lean
theorem exists_common_right_multiple_iff_prefixComparable
    (x y : S) :
    (∃ z₁ z₂ : S, x * z₁ = y * z₂) ↔
      PrefixComparable (normalForm x) (normalForm y)
```

where `PrefixComparable u v` should mean:

```lean
def PrefixComparable {α : Type _} (u v : List α) : Prop :=
  u <+: v ∨ v <+: u
```

A more structural ideal-theoretic version is preferable if the ambient API supports set multiplication / principal right ideals:

```lean
def rightIdeal (x : S) : Set S := {w | ∃ z : S, w = x * z}

theorem rightIdeal_inter_nonempty_iff_prefixComparable
    (x y : S) :
    (rightIdeal x ∩ rightIdeal y).Nonempty ↔
      PrefixComparable (normalForm x) (normalForm y)
```

and then the exact description of the intersection:

```lean
theorem rightIdeal_inter_eq_rightIdeal_of_prefix
    {x y : S}
    (h : normalForm x <+: normalForm y) :
    rightIdeal x ∩ rightIdeal y = rightIdeal y
```

```lean
theorem rightIdeal_inter_eq_rightIdeal_of_prefix'
    {x y : S}
    (h : normalForm y <+: normalForm x) :
    rightIdeal x ∩ rightIdeal y = rightIdeal x
```

A very strong canonical form of the intersection theorem is:

```lean
theorem rightIdeal_inter_eq_rightIdeal_longerWord
    (x y : S) :
    ∃ z : S,
      (rightIdeal x ∩ rightIdeal y = rightIdeal z) ∧
      ((normalForm x <+: normalForm y ∧ z = y) ∨
       (normalForm y <+: normalForm x ∧ z = x)) ↔
      PrefixComparable (normalForm x) (normalForm y)
```

If the library already defines a free semigroup object and the Berggren embedding as a semigroup homomorphism, then phrase the cancellation theorem first at the word level and transfer it via injectivity:

```lean
theorem evalWord_right_cancel
    {u v w : BergWord} :
    evalWord (u ++ w) = evalWord (v ++ w) ↔ u = v
```

followed by the matrix-level corollary.

### Concrete proof strategy

1. **Reduce matrix equalities to word equalities via normal forms.**  
   The key bridge should be:
   ```lean
   have hx : evalWord (normalForm x) = x := eval_normalForm x
   have hy : evalWord (normalForm y) = y := eval_normalForm y
   have hz : evalWord (normalForm z) = z := eval_normalForm z
   ```
   and the multiplication/concatenation compatibility:
   ```lean
   evalWord (u ++ v) = evalWord u * evalWord v
   ```
   From `x * z = y * z`, rewrite both sides as evaluations of
   `normalForm x ++ normalForm z` and `normalForm y ++ normalForm z`.

2. **Use injectivity of the evaluation map on reduced/normal words.**  
   The decisive step is:
   ```lean
   evalWord (normalForm x ++ normalForm z) =
   evalWord (normalForm y ++ normalForm z)
   ```
   hence by freeness / uniqueness:
   ```lean
   normalForm x ++ normalForm z = normalForm y ++ normalForm z
   ```
   Then conclude
   ```lean
   normalForm x = normalForm y
   ```
   by list right-cancellation. In Lean this is often available as a list lemma such as
   `List.append_right_inj`, `List.append_right_cancel`, or can be proved by taking lengths and prefix recursion if needed.

3. **Derive the semigroup-level right-cancellation theorem from word right-cancellation.**  
   Once `normalForm x = normalForm y`, use the inverse direction of normal-form uniqueness:
   ```lean
   x = evalWord (normalForm x) := (eval_normalForm x).symm
   _ = evalWord (normalForm y) := by simpa [*]
   _ = y := eval_normalForm y
   ```
   Package this both as an implication and as an iff.

4. **Characterize common right multiples by prefix comparability of normal forms.**  
   For the forward direction, assume
   ```lean
   h : ∃ z₁ z₂, x * z₁ = y * z₂
   ```
   Translate to words:
   ```lean
   normalForm x ++ normalForm z₁ = normalForm y ++ normalForm z₂
   ```
   Then apply the standard free-monoid overlap lemma:
   for lists `a,b,c,d`, if `a ++ b = c ++ d`, then `a <+: c ∨ c <+: a`.
   This is the core combinatorial lemma you may need to prove separately:
   ```lean
   theorem prefixComparable_of_append_eq_append
       {α : Type _} {a b c d : List α}
       (h : a ++ b = c ++ d) :
       a <+: c ∨ c <+: a
   ```
   A clean proof is by comparing lengths, using `List.isPrefix_iff_eq_append` (if available), or by induction on `a` and `c`.

5. **Show the converse and identify the exact intersection ideal.**  
   If `normalForm x <+: normalForm y`, write
   ```lean
   normalForm y = normalForm x ++ t
   ```
   for some suffix `t`. Let `u := evalWord t`. Then
   ```lean
   y = x * u
   ```
   so every right multiple of `y` is automatically a right multiple of `x`, i.e.
   ```lean
   rightIdeal y ⊆ rightIdeal x
   ```
   and hence
   ```lean
   rightIdeal x ∩ rightIdeal y = rightIdeal y.
   ```
   The symmetric case gives the full criterion:
   common right multiple exists iff one normal form is a prefix of the other, and the intersection is the principal right ideal generated by the element with longer normal form.

### Suggested intermediate lemmas

These are likely the right granularity for a robust Lean development:

```lean
def PrefixComparable {α : Type _} (u v : List α) : Prop :=
  u <+: v ∨ v <+: u
```

```lean
theorem prefixComparable_of_append_eq_append
    {α : Type _} {a b c d : List α}
    (h : a ++ b = c ++ d) :
    PrefixComparable a c
```

```lean
theorem evalWord_mul
    (u v : BergWord) :
    evalWord (u ++ v) = evalWord u * evalWord v
```

```lean
theorem normalForm_mul
    (x y : S) :
    normalForm (x * y) = normalForm x ++ normalForm y
```

This last theorem may already be available implicitly from uniqueness; if not, it is worth proving because it turns multiplication into literal concatenation and simplifies every downstream argument.

```lean
theorem eq_of_normalForm_eq
    {x y : S} :
    normalForm x = normalForm y → x = y
```

```lean
theorem prefix_iff_exists_right_factor
    {x y : S} :
    normalForm x <+: normalForm y ↔ ∃ z : S, y = x * z
```

```lean
theorem common_right_multiple_iff
    {x y : S} :
    (∃ w : S, w ∈ rightIdeal x ∩ rightIdeal y) ↔
      PrefixComparable (normalForm x) (normalForm y)
```

```lean
theorem rightIdeal_inter_eq_of_prefix
    {x y : S}
    (h : normalForm x <+: normalForm y) :
    rightIdeal x ∩ rightIdeal y = rightIdeal y
```

These intermediate lemmas should make the final theorems almost tautological from the free-word structure, but each still requires a real translation argument between syntax and matrices.

### Technical Lean guidance

- If `S` is implemented as a subtype of matrices, expect to use `ext` or `Subtype.ext` sparingly; the real proof should avoid matrix entry computations entirely and instead rely on the embedding/freeness theorem.
- If `normalForm` lands in a reduced-word subtype rather than raw `List`, formulate prefix order on the underlying list with coercions:
  ```lean
  (normalForm x : List (Fin 3))
  ```
- If there is no existing `PrefixComparable`, define it locally and prove elementary symmetry:
  ```lean
  theorem PrefixComparable.symm : PrefixComparable u v → PrefixComparable v u
  ```
- For principal right ideals as sets, a convenient definition is:
  ```lean
  def rightIdeal (x : S) : Set S := Set.range fun z => x * z
  ```
  Then membership is by `constructor` / `rfl` on `Set.mem_range`.
- The key list combinatorics may already exist under names involving `IsPrefix`, `List.Prefix`, or `<+:`; search before reproving.

### Why this matters

This theorem package is the missing right-sided analogue of the existing freeness / unique-normal-form infrastructure. It upgrades “distinct words evaluate to distinct semigroup elements” into a full **right-divisibility theory** inside the Berggren-positive subsemigroup of `SL₂(ℤ)`. That is mathematically significant because it shows the semigroup behaves like a genuinely free positive monoid not only at the level of equality, but also at the level of principal right ideals and overlap structure.

For the SPB cryptographic program, this gives a sharp collision-rigidity principle:

```lean
x * z = y * z  →  x = y
```

so appending a common secret suffix cannot hide or create a collision among public semigroup elements. The common-right-multiple criterion is even stronger: it reduces the existence and exact shape of shared right multiples to a purely syntactic prefix test on unique normal forms. This is precisely the kind of theorem that makes public-key normalization, divisibility checks, and protocol-side collision analysis computationally transparent and formally robust.

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
