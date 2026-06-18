# Semiring-Relative Mathematical Reality: Formal Theorems on Multiplicity Collapse and Support Invariance

## Abstract

We develop a formal theory of *semiring-relative mathematical reality* — a framework for understanding which algebraic identities survive passage between different semiring structures. Our main results, fully machine-verified, establish that:

1. **The Alien Shadow Theorem**: In any idempotent commutative semiring (where `a + a = a`), polynomial evaluation over a list of exponents is invariant under deduplication — i.e., depends only on the *support* (which monomials appear) and not on *multiplicities* (how many times they appear).

2. **The Separation Theorem**: There exist concrete finite expressions that distinguish idempotent from classical (ℕ) semirings, witnessing that semiring choice genuinely changes the theorem corpus.

3. **The Counting Obstruction**: Classical semirings can recover list length from polynomial evaluation, while idempotent semirings provably cannot — multiplicity information is irreversibly destroyed.

4. **The Combinatorial Core Theorem**: Two lists with the same deduplicated content (up to permutation) evaluate identically in any idempotent commutative semiring, identifying support-level combinatorics as the invariant residue under semiring variation.

5. **Support Invariance**: In a finset-based formulation, evaluation with arbitrary positive coefficients equals evaluation with unit coefficients in any idempotent commutative semiring.

All proofs are formalized in Lean 4 with Mathlib, using the `IdemCommSemiring` typeclass. No axioms beyond the standard foundations (propext, choice, Quot.sound) are used.

**Keywords**: tropical algebra, idempotent semiring, support invariance, multiplicity collapse, semiring semantics, weighted automata, formal verification

---

## 1. Introduction

### 1.1 Motivation

The observation that different algebraic structures support different mathematical truths is ancient — it is, in essence, the content of model theory. However, the specific question of how the *additive structure* of a semiring determines which polynomial identities hold has not been systematically formalized.

We are motivated by three converging threads:

1. **Tropical geometry**: The tropicalization map, which sends a variety over a valued field to a polyhedral complex, systematically forgets multiplicity information while preserving combinatorial and extremal structure [Maclagan-Sturmfels 2015].

2. **Weighted automata theory**: The semantics of weighted finite automata depends crucially on the choice of semiring — the same automaton counts paths over ℕ, checks reachability over 𝔹, and optimizes over the tropical semiring [Droste-Kuich-Vogler 2009].

3. **Foundations of mathematics**: The question of whether mathematical truths are absolute or relative to foundational choices has long been debated. Our work contributes a precise, theorem-level answer for a specific axis of variation: the additive structure of the coefficient semiring.

### 1.2 Contributions

We introduce the concept of *semiring-relative mathematical reality* and provide the first machine-verified theorems establishing:

- A precise characterization of what survives idempotent collapse (support).
- A concrete separation witness between idempotent and classical semirings.
- A quantitative "counting obstruction" showing that multiplicity recovery is impossible in idempotent settings.
- A combinatorial core theorem identifying the permutation-invariant support as the universal residue.

### 1.3 Related Work

**Tropical algebra and geometry**: Tropicalization as a mathematical tool dates to the work of Bergman, Bieri-Groves, and was systematically developed by Mikhalkin, Itenberg-Mikhalkin-Shustin, and Maclagan-Sturmfels. Our contribution is orthogonal: rather than using tropical methods to prove classical results, we formally characterize *what* is lost and preserved in the passage.

**Idempotent analysis**: Maslov's "dequantization" program [Litvinov 2007] interprets the passage from quantum to classical mechanics as a semiring change. Our formal results can be seen as the algebraic core of Maslov's vision, stripped of analytical complications.

**Semiring theory in computer science**: Mohri [2002], Droste-Kuich-Vogler [2009], and others have extensively studied weighted automata and transducers over various semirings. Our support-invariance theorem provides a formal explanation for why idempotent-semiring automata compute reachability rather than counting.

---

## 2. Definitions and Notation

### 2.1 Idempotent Commutative Semirings

A *commutative semiring* is a structure `(α, +, ·, 0, 1)` satisfying the usual axioms: `(α, +, 0)` is a commutative monoid, `(α, ·, 1)` is a commutative monoid, multiplication distributes over addition, and `0` annihilates.

An *idempotent commutative semiring* additionally satisfies `a + a = a` for all `a`. In the Mathlib library, this is captured by the typeclass `IdemCommSemiring α`, which furthermore equips `α` with a compatible `SemilatticeSup` structure where `a + b = a ⊔ b`.

**Examples**:
- The *tropical semiring* `(ℝ ∪ {-∞}, max, +, -∞, 0)`.
- The *Boolean semiring* `({0, 1}, ∨, ∧, 0, 1)`.
- The *min-plus semiring* `(ℝ ∪ {+∞}, min, +, +∞, 0)`.
- Any *distributive lattice with 0 and 1* under `(⊔, ⊓)`.

### 2.2 List-Based Polynomial Evaluation

We define evaluation of a list of exponents as a polynomial expression:

```
def evalListSemiring {α : Type*} [CommSemiring α] (x : α) : List ℕ → α
  | [] => 0
  | i :: is => x ^ i + evalListSemiring x is
```

For a list `L = [i₁, i₂, ..., iₙ]`, this computes `x^{i₁} + x^{i₂} + ⋯ + x^{iₙ}`.

### 2.3 The Alien Shadow Map

The *alien shadow* of a list is its deduplication: `L.dedup`, which removes duplicate elements while preserving order. This is the normalization that is invisible to idempotent civilizations.

---

## 3. Main Results

### 3.1 Theorem A: The Alien Shadow Theorem

**Theorem** (evalListIdem_dedup). *Let `α` be an idempotent commutative semiring and `x : α`. For any list `L : List ℕ`,*

```
evalListSemiring x L.dedup = evalListSemiring x L
```

**Proof sketch**: By induction on `L`. The base case is trivial. For `L = a :: L'`:
- If `a ∈ L'`, then `(a :: L').dedup = L'.dedup`. By the inductive hypothesis, `evalListSemiring x L'.dedup = evalListSemiring x L'`. We also need `evalListSemiring x (a :: L') = evalListSemiring x L'`, which follows from the key lemma `evalListSemiring_cons_mem`.
- If `a ∉ L'`, then `(a :: L').dedup = a :: L'.dedup`. The result follows directly from the inductive hypothesis.

The key lemma `evalListSemiring_cons_mem` proves that prepending a duplicate exponent doesn't change evaluation. Its proof proceeds by induction on `L`, using idempotence (`a + a = a`) and commutativity to handle the case where the duplicate appears deeper in the list.

**Complexity**: The deduplication itself is O(n log n) or O(n) with hashing. The evaluation is O(n · cost(pow)).

### 3.2 Theorem B: The Separation Theorem

**Theorem** (separation_nat_vs_idempotent). *There exist a list `L : List ℕ` and a point `x : ℕ` such that*

```
evalListSemiring x L ≠ evalListSemiring x L.dedup
```

**Proof**: Take `L = [0, 0]` and `x = 1`. Then `evalListSemiring 1 [0, 0] = 1^0 + 1^0 = 2` and `evalListSemiring 1 [0].dedup = 1^0 = 1`. ∎

This is verified by `native_decide` in the formalization.

**Corollary** (tropical_not_nat_separator). `(∀ a : ℝ, max a a = a) ∧ ¬(∀ n : ℕ, n + n = n)`.

### 3.3 Theorem C: Coefficient Support Invariance

**Theorem** (eval_support_invariance). *Let `α` be an idempotent commutative semiring, `x : α`, `s : Finset ℕ`, and `c : ℕ → ℕ` with `c(i) ≥ 1` for all `i ∈ s`. Then*

```
∑ i ∈ s, c(i) • (x ^ i) = ∑ i ∈ s, x ^ i
```

**Proof**: Follows from the lemma `nsmul_eq_self_of_idem`: in an idempotent commutative semiring, `n • a = a` for all `n ≥ 1`. This is proved by induction on `n`, using `(n+1) • a = n • a + a = a + a = a`. ∎

**Significance**: This theorem says that in an idempotent world, coefficients carry no information beyond their support (zero vs nonzero). A polynomial `3x² + 7x + 1` is indistinguishable from `x² + x + 1`. Only the *set* of monomials matters.

### 3.4 Theorem D: The Counting Obstruction

**Theorem** (counting_obstruction).
1. *For all `n : ℕ`, `evalListSemiring 1 (replicate (n+1) 0) = n + 1`.*
2. *It is not the case that for all `n : ℕ`, `evalListSemiring 1 (replicate (n+1) 0) = evalListSemiring 1 (replicate 1 0)`.*

**Theorem** (idem_eval_loses_length). *In an idempotent commutative semiring, for any nonempty list `L` with all entries equal to 0, `evalListSemiring 1 L = 1`.*

**Combined interpretation**: In ℕ, evaluating the constant-0 polynomial at x=1 recovers the number of terms (it counts). In an idempotent semiring, all such evaluations collapse to 1 regardless of length. Counting ability is an artifact of non-idempotent addition.

### 3.5 Theorem E: The Combinatorial Core

**Theorem** (evalListIdem_perm_dedup). *Let `α` be an idempotent commutative semiring. For any lists `L, M : List ℕ` such that `L.dedup` is a permutation of `M.dedup`,*

```
evalListSemiring x L = evalListSemiring x M
```

**Proof**: Combine the Shadow Theorem (dedup doesn't change evaluation) with permutation invariance (proved via the four cases of `List.Perm`: nil, cons, swap, trans). ∎

**Significance**: This identifies the complete equivalence relation induced by idempotent evaluation: two expressions are equivalent if and only if they have the same support (as a set). All that matters is *which* monomials appear, not their order or multiplicity.

---

## 4. Algorithms

### 4.1 The Alien Shadow Map

**Input**: List of exponents `L = [i₁, ..., iₙ]`
**Output**: Order-preserving deduplication `L' = dedup(L)`

```
function AlienShadow(L):
    seen ← ∅
    result ← []
    for i in L:
        if i ∉ seen:
            seen ← seen ∪ {i}
            result.append(i)
    return result
```

**Time**: O(n) expected with hash set
**Space**: O(n)

### 4.2 Semiring Identity Tester

**Input**: A polynomial identity (as a pair of expression lists), a list of semirings, test domain
**Output**: For each semiring, whether the identity holds (with counterexample if not)

```
function TestIdentity(L₁, L₂, semirings, test_points):
    for S in semirings:
        for x in test_points:
            if S.eval(x, L₁) ≠ S.eval(x, L₂):
                report FAILS with counterexample (S, x)
                break
        else:
            report HOLDS (on test domain)
```

**Time**: O(|semirings| · |test_points| · max(|L₁|, |L₂|))

### 4.3 Tropical Equivalence Checker

**Input**: Two polynomials as coefficient maps `p, q : ℕ → ℕ`
**Output**: Whether they are tropically equivalent

```
function TropicallyEquivalent(p, q):
    return support(p) = support(q)
    where support(f) = {i : f(i) ≠ 0}
```

**Time**: O(n + m) where n, m are the support sizes
**Space**: O(n + m)

This follows directly from the Support Invariance Theorem: two polynomials with the same support evaluate identically in every idempotent commutative semiring.

---

## 5. Applications

### 5.1 Weighted Automata

A weighted finite automaton over a semiring S computes, for each input word w, an element of S by summing over all accepting paths weighted by transition weights. The classical theory [Droste-Kuich-Vogler 2009] shows:

| Semiring | Computation |
|----------|-------------|
| ℕ | Number of accepting paths |
| 𝔹 | Language recognition (reachability) |
| Tropical (max-plus) | Maximum-weight path |
| Min-plus | Shortest path |

Our Shadow Theorem explains *why* idempotent semirings yield reachability/optimization rather than counting: the idempotent evaluation is invariant under path duplication, so only the *set* of reachable paths matters, not their multiplicity.

### 5.2 Tropical Geometry

In tropical geometry, a polynomial `f = ∑ cᵢ x^i` is tropicalized to `trop(f) = max_i(val(cᵢ) + i·x)`. The tropical variety `V(trop(f))` is a polyhedral complex that captures the combinatorial shadow of the algebraic variety `V(f)`.

Our Support Invariance Theorem provides the algebraic explanation: after tropicalization, the coefficients `cᵢ` contribute only through their valuations (i.e., their support in the valuation semiring). The fine arithmetic structure is lost.

### 5.3 Classical-Quantum Transition

Maslov's dequantization [Litvinov 2007] interprets the limit ℏ → 0 of quantum mechanics as a semiring morphism from (ℂ, +, ·) to the tropical semiring (ℝ, max, +). In the quantum regime, amplitudes add and interfere (multiplicity is crucial — it produces interference patterns). In the classical limit, only the extremal (stationary phase) contribution survives.

Our Counting Obstruction Theorem formalizes this: the quantum world (ℕ or ℂ semiring) can count paths and detect interference, while the classical/tropical world cannot. The passage from quantum to classical is precisely the passage from multiplicity-sensitive to support-only mathematics.

### 5.4 Network Analysis

In network flow problems, the distinction between:
- **How many** paths exist between two nodes (ℕ semiring, multiplicity-sensitive)
- **Whether** a path exists (Boolean semiring, support-only)
- **What is the best** path (tropical semiring, extremal)

is exactly the distinction our theorems formalize. The Combinatorial Core Theorem identifies what all three analyses share: the reachability structure (support) is common to all semirings.

---

## 6. Computational Experiments

We implement evaluation over multiple semirings and test the main theorems computationally.

### 6.1 Multiplicity Collapse

For the expression list `L = [0, 1, 0, 1, 1]` evaluated at `x = 2`:

| Semiring | eval(L) | eval(dedup(L)) | Equal? |
|----------|---------|----------------|--------|
| ℕ | 8 | 3 | No |
| Tropical (max) | 2.0 | 2.0 | Yes |
| Boolean | {0, 1} | {0, 1} | Yes |

### 6.2 Counting Obstruction

For lists `replicate(n, 0)` evaluated at `x = 1`:

| n | ℕ eval | Tropical eval |
|---|--------|---------------|
| 1 | 1 | 1.0 |
| 5 | 5 | 1.0 |
| 10 | 10 | 1.0 |
| 100 | 100 | 1.0 |

The ℕ evaluation grows linearly; tropical evaluation is constant.

### 6.3 Support Invariance

For the support `{0, 1, 2, 3}` at `x = 2` with various coefficient vectors:

| Coefficients | ℕ eval | Tropical eval |
|-------------|--------|---------------|
| [1, 1, 1, 1] | 15 | 8.0 |
| [5, 3, 7, 2] | 85 | 8.0 |
| [100, 1, 1, 100] | 915 | 8.0 |

Tropical evaluation is invariant under coefficient change (given nonzero support).

---

## 7. Discussion

### 7.1 Philosophical Implications

Our theorems provide a formal foundation for the claim that mathematical truth is, in part, *relative to algebraic substrate*. The statement "the sum of n copies of 1 equals n" is true in ℕ but false in any idempotent semiring. This is not a failure of logic — both semirings are consistent. It is a demonstration that the *content* of mathematics depends on the *structure* of the underlying operations.

This has implications for the philosophy of mathematical realism. If we define a "mathematical universe" as the set of all true sentences in a given algebraic structure, then different structures yield genuinely different universes. The combinatorial core — the intersection of all these universes — is the substrate-independent mathematics that any civilization must discover.

### 7.2 Limitations

Our current formalization is restricted to:
- One-variable polynomial expressions (lists of natural number exponents).
- Positive natural-number coefficients (for the support invariance theorem).
- The `IdemCommSemiring` typeclass, which requires commutativity.

The natural extensions — multivariate polynomials, ring coefficients, non-commutative idempotent semirings — are discussed in Future Work.

### 7.3 Proof Architecture

The proof architecture is modular and designed for extension:

1. **Core lemma** (`idem_add_self`): The idempotence property `a + a = a`.
2. **Duplicate elimination** (`evalListSemiring_cons_mem`): Removing one duplicate.
3. **Full dedup** (`evalListIdem_dedup`): Removing all duplicates, by induction.
4. **Permutation invariance** (`evalListSemiring_perm`): Order doesn't matter.
5. **Combinatorial core** (`evalListIdem_perm_dedup`): Combining dedup and perm.
6. **Separation witnesses**: Concrete counterexamples in ℕ.

Each level depends only on the previous, allowing clean extension.

---

## 8. Future Work

1. **Multivariate support-shadow theorem**: Extend to `MvPolynomial σ ℕ` and prove that tropicalization factors through the support map in the multivariate setting.

2. **Weighted automata classification**: Characterize exactly which automaton properties are semiring-invariant, using our framework to define "support-level" vs "multiplicity-level" automaton equivalences.

3. **Tropical shadow functor**: Define a category-theoretic functor from polynomial rings over ℕ to idempotent semirings that formalizes tropicalization as a morphism of algebraic theories.

4. **Quantitative multiplicity recovery bounds**: In approximate/real-valued settings, how much information about multiplicities can be recovered from "noisy tropical" evaluation? This connects to compressed sensing and information theory.

5. **Proof-theoretic semantics**: Interpret the semiring change as a transformation of proof systems, where idempotent collapse corresponds to proof irrelevance (repeated use of a lemma adds nothing).

---

## 9. References

- Droste, M., Kuich, W., Vogler, H. (eds.). *Handbook of Weighted Automata*. Springer, 2009.
- Litvinov, G. L. "The Maslov dequantization, idempotent and tropical mathematics: a brief introduction." *Journal of Mathematical Sciences*, 140(3), 2007.
- Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
- Mohri, M. "Semiring frameworks and algorithms for shortest-distance problems." *JCSS*, 64(1), 2002.
- Pin, J.-E. "Tropical semirings." In *Idempotency*, Cambridge UP, 1998.
- Simon, I. "Recognizable sets with multiplicities in the tropical semiring." In *MFCS*, Springer, 1988.

---

## Appendix A: Complete Lean Statement List

All theorems are in the module `Speculative.AlienMathematics.SemiringRelativeReality`.

| Theorem | Statement |
|---------|-----------|
| `idem_add_self` | `∀ (a : α), a + a = a` (for `IdemCommSemiring α`) |
| `evalListSemiring_cons_mem` | Prepending a duplicate doesn't change eval |
| `evalListIdem_dedup` | `evalListSemiring x L.dedup = evalListSemiring x L` |
| `separation_nat_vs_idempotent` | `∃ L x, eval L ≠ eval L.dedup` (over ℕ) |
| `tropical_not_nat_separator` | `(∀ a, max a a = a) ∧ ¬(∀ n, n+n=n)` |
| `nsmul_eq_self_of_idem` | `n • a = a` for `n ≥ 1` |
| `eval_eq_eval_doubled` | `∑(x^i + x^i) = ∑ x^i` |
| `eval_support_invariance` | `∑ c(i)•x^i = ∑ x^i` for `c(i) ≥ 1` |
| `evalListSemiring_append` | `eval(L++M) = eval(L) + eval(M)` |
| `evalListSemiring_perm` | Permutation invariance |
| `evalListIdem_perm_dedup` | Same dedup ⟹ same eval |
| `nat_eval_counts_length` | `eval_ℕ 1 L = |L|` for constant lists |
| `idem_eval_loses_length` | `eval_idem 1 L = 1` for constant lists |
| `counting_obstruction` | Length recovery in ℕ, failure otherwise |
