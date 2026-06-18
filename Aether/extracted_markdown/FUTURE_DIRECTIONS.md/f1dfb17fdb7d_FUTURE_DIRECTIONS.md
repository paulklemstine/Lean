# Future Directions

## Conjecture 1: Truncation Level Induction

**Precise statement:** For any type `A` in our HoTT fragment, define the truncation level `trunc_level(A)` inductively: `trunc_level(A) = -2` if `A` is contractible, `trunc_level(A) = n+1` if for all `a, b : A`, `trunc_level(a = b) = n`. Then for any finite discrete type with `k` elements, `trunc_level(A) = 0` (i.e., it is a set in the HoTT sense: all identity proofs are equal).

**Test:** Formalize truncation levels as an inductive definition in Lean 4, then:
- Computationally verify for `Fin n` with `n ≤ 100` that all identity proofs are equal (which Lean's kernel guarantees, but the test validates the framework).
- Attempt to prove `trunc_level(Fin n) = 0` formally using our `IdentitySystem` machinery.
- A refutation would require finding a type where our definition disagrees with the standard HoTT truncation level, which would indicate a mismatch in our encoding.

**Impact:** If true, this validates that our framework correctly captures HoTT's truncation hierarchy for concrete types, enabling formalization of the full n-type tower in Lean 4 without cubical infrastructure.

## Conjecture 2: Pushout Cardinality for Non-Injective Spans

**Precise statement:** For a finite span `A → B`, `A → C` where the legs are not necessarily injective, the cardinality of the quotient-based pushout satisfies:

    |Pushout(f,g)| = |B| + |C| - |image(f ×_A g)|

where `image(f ×_A g)` counts the number of distinct pairs `(f(a), g(a))` as `a` ranges over `A`.

**Test:**
- Enumerate all spans with `|A|, |B|, |C| ≤ 6`.
- For each, compute the pushout cardinality via union-find and compare with the formula.
- The formula is known to fail for the naive `|B| + |C| - |A|` when legs are non-injective (demonstrated in our `demo.py`). This refined formula may or may not hold.

**Impact:** If true, gives a complete combinatorial formula for pushout cardinality in the finite case, immediately useful for computational topology (cell complex Euler characteristics) and database theory (join cardinality estimation).

## Conjecture 3: Identity System Transport Preserves Algebraic Structure

**Precise statement:** Given an identity system `S` on a type `A` equipped with a binary operation `μ : A → A → A`, the equivalence `identity_system_equiv_path S` transports `μ` to a binary operation on `R` that satisfies the same algebraic laws (associativity, commutativity, etc.) as `μ`.

Formally: if `(A, μ)` is a monoid and `S` is an identity system at the unit element with `R(a) = (e = a)`, then the transported operation on `R` (via the equivalence) is also a monoid.

**Test:**
- Instantiate with `A = ℤ`, `μ = (+)`, `a₀ = 0`, `R(n) = (0 = n)`.
- Verify that the transported operation on paths satisfies the monoid laws.
- Try with non-abelian groups (e.g., `S₃`) to test robustness.
- Attempt formal verification in Lean using our `identity_system_equiv_path`.

**Impact:** If true, establishes that identity systems are not just logical curiosities but algebraic tools: they let you transport algebraic structure between equivalent representations. This would be a major step toward formalizing the "structure identity principle" from the HoTT book.

## Conjecture 4: Contractible Pi Types Without Base Contractibility

**Precise statement:** The hypothesis `Contractible A` in our `contractible_pi` theorem is not strictly necessary. Specifically: if `B : A → Type` is such that every fiber `B(a)` is contractible, then `(a : A) → B(a)` is contractible regardless of whether `A` itself is contractible.

**Test:**
- Try to prove this in Lean (remove the `_hA` hypothesis from `contractible_pi`).
- Computationally test with `A = Fin 3` (not contractible) and `B(i) = Unit` for all `i`: the function space `Fin 3 → Unit` has exactly one element.
- If provable, the original theorem statement can be strengthened.

**Impact:** If true, simplifies the contractibility infrastructure and shows that the "base contractibility" hypothesis is an artifact of certain proof strategies, not a mathematical necessity. This would streamline many downstream applications.

## Conjecture 5: Pushout Universal Property Determines Pushout Up To Equivalence

**Precise statement:** Any type `P` equipped with maps `iB : B → P`, `iC : C → P` satisfying `iB ∘ f = iC ∘ g` and the universal property (for any `X` with compatible maps, there exists a unique `P → X`) is equivalent (in our `Equiv'` sense) to the quotient-based `Pushout f g`.

**Test:**
- Define an abstract pushout interface (as a structure with maps and universal property).
- Construct the canonical comparison map `Pushout f g → P` using the universal property.
- Attempt to prove it is an `Equiv'` in Lean.
- Test computationally: for small spans, verify that the abstract interface is satisfied by our `Pushout` and that the comparison maps are bijections.

**Impact:** If true, validates that our quotient-based construction is "the right one" — it satisfies the expected categorical universal property uniquely. This is the key coherence result needed to build higher-dimensional gluing operations on top of our pushout surrogate.
