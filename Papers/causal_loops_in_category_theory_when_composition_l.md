# Computational Evidence

We study the parenthesization category `PTree α`: binary trees with `α`-labelled leaves
(plus an empty tree `nil`), with tensor `s ⊗ t := node s t` and unit `nil`. Two trees are
declared isomorphic when they have the same underlying leaf-word `flatten s`.

## 1. On-the-nose failure of associativity (small cases)

Trees are a concrete inductive type with decidable equality, so associativity failure is
directly checkable. For the empty tree `e := nil`:

| expression                | tree                              |
|---------------------------|-----------------------------------|
| `(e ⊗ e) ⊗ e`             | `node (node nil nil) nil`         |
| `e ⊗ (e ⊗ e)`             | `node nil (node nil nil)`         |

These are **distinct** constructors' outputs (`decide` confirms
`node (node nil nil) nil ≠ node nil (node nil nil)`). More generally, for any `a b c`,
`node (node a b) c = node a (node b c)` would force `node a b = a`, impossible by a size
argument. This is `PTree.tensor_assoc_ne`.

## 2. The associativity is "repaired" after flattening

`flatten (node l r) = flatten l ++ flatten r`, and `++` on `List` is associative:

- `flatten ((a ⊗ b) ⊗ c) = (flatten a ++ flatten b) ++ flatten c`
- `flatten (a ⊗ (b ⊗ c)) = flatten a ++ (flatten b ++ flatten c)`

These are **equal**. So although the objects differ, there is a canonical morphism
(the associator) between them. Sample check (leaves = characters):

- `((x·y)·z)` flattens to `[x,y,z]`
- `(x·(y·z))` flattens to `[x,y,z]`  ✔ equal.

## 3. Counting bracketings (Catalog numbers) vs. isomorphism classes

The number of bracketings of a word of `n` leaves is the Catalan number
`C_{n-1} = 1, 1, 2, 5, 14, 42, …` (OEIS A000108). All `C_{n-1}` bracketings of a fixed
word lie in a **single isomorphism class** (they all `flatten` to the same word). This is
the concrete content of Mac Lane coherence: the reassociation groupoid on a fixed word is
*contractible* (thin + connected). Isomorphism classes of objects are therefore in
bijection with leaf-words `List α`, matching the skeleton `Discrete (List α)`.

- words of length 0: 1 bracketing, 1 iso class
- length 1: 1 bracketing, 1 iso class
- length 2: 1 bracketing, 1 iso class
- length 3: 2 bracketings `(ab)c`, `a(bc)`, 1 iso class
- length 4: 5 bracketings, 1 iso class
- length 5: 14 bracketings, 1 iso class

## 4. Counterexample hunt for the coherence claim

The universal claim is: *every* `MonoidalCategoryStruct` on a thin category satisfies all
coherence axioms (pentagon, triangle, naturality). Because parallel morphisms in a thin
category are equal, each axiom is an equation between two parallel morphisms and holds
automatically — there is no room for a counterexample. This is proved abstractly as
`CausalLoops.monoidalOfThin` and instantiated as `PTree.instMonoidalCategory`.

## Conclusion

The computations confirm: associativity fails on the nose (distinct trees), is repaired
up to unique isomorphism (equal flattenings), the reassociation classes are counted by
words rather than bracketings, and coherence is automatic from thinness. All of these are
then proved in Lean without `sorry`.
